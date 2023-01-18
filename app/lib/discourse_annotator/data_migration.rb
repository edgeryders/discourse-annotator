module DiscourseAnnotator
  module DataMigration
    class << self

      # reload!; DiscourseAnnotator::DataMigration.migrate_discourse_ethno_tags_to_projects
      def migrate_discourse_ethno_tags_to_projects
        DiscourseAnnotator::Project.all.each { |p| p.fast_delete } if Rails.env.development?

        # Remove corrupted data.
        DiscourseAnnotator::Annotation.find_by(id: 13130)&.destroy
        DiscourseAnnotator::Code.find_by(id: 4209)&.destroy

        ethno_tags = Tag.where("name LIKE 'ethno-%'")

        # Required to exclude newly created annotations.
        max_annotation_id = DiscourseAnnotator::Annotation.maximum(:id)

        migrate_annotations_to_project(
          DiscourseAnnotator::Annotation.where.not(topic_id: ethno_tags.map(&:topic_ids).flatten).all,
          DiscourseAnnotator::Project.find_or_create_by!(name: 'z--orphaned-annotations')
        )

        ethno_tags.each do |tag|
          all_project_annotations = []
          tag.topics.each { |topic| all_project_annotations = all_project_annotations.union(topic.annotations.where("discourse_annotator_annotations.id <= ?", max_annotation_id)) }
          migrate_annotations_to_project(all_project_annotations, DiscourseAnnotator::Project.find_or_create_by(name: tag.name))
        end
      end


      private

      def migrate_annotations_to_project(project_annotations, project)
        project_annotations_by_code = {}
        project_annotations.each do |annotation|
          path_ids = annotation.code.path_ids
          (project_annotations_by_code[path_ids.join('/')] ||= []) << annotation
          # Add all missing codes that are in the path.
          path_ids.each_with_index do |e, index|
            path = path_ids[0..index].join('/')
            project_annotations_by_code[path] = [] unless project_annotations_by_code.key?(path)
          end
        end
        project_annotations_by_code = Hash[project_annotations_by_code.sort_by { |k, v| k.length }]
        code_id_mapping = {} # {old_code_id: new_code_id}
        project_annotations_by_code.each do |path, annotations|
          code = DiscourseAnnotator::Code.where(project_id: nil).find(path.split('/').last.to_i)
          # https://github.com/moiristo/deep_cloneable
          # NOTE: localized_codes must not be included as they are created by a callback (after_save :update_localized_codes).
          cloned_code = code.deep_clone include: [:names],
                                        preprocessor: ->(original, kopy) {
                                          # See: https://github.com/edgeryders/discourse-annotator/issues/220
                                          kopy.annotations_count = 0 if kopy.respond_to?(:annotations_count)
                                          kopy.created_at = original.created_at if kopy.respond_to?(:created_at)
                                          kopy.updated_at = original.updated_at if kopy.respond_to?(:updated_at)
                                          if kopy.is_a?(DiscourseAnnotator::Code)
                                            kopy.project_id = project.id
                                            kopy.parent_id = code_id_mapping[original.parent_id] if original.parent_id
                                            kopy.annotations = annotations.map { |a|
                                              a.deep_clone include: [:ranges], preprocessor: ->(o, k) {
                                                k.created_at = o.created_at if k.respond_to?(:created_at)
                                                k.updated_at = o.updated_at if k.respond_to?(:updated_at)
                                              }
                                            }
                                          end
                                        }
          cloned_code.save
          code_id_mapping[code.id] = cloned_code.id
        end
      end

    end
  end
end

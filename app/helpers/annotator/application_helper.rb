require 'current_user'

module Annotator
  module ApplicationHelper

    require_relative '../../../lib/helpers/markdown_renderer'
    include CurrentUser

    def markdown(content)
      @markdown ||= Redcarpet::Markdown.new(MarkdownRenderer, autolink: true)
      @markdown.render(content).html_safe
    end

    # created_by:
    def nested_dropdown_tags(args = {})
      language = ::AnnotatorStore::UserSetting.language_for_user(current_user)
      r = ActiveRecord::Base.connection.execute("
        SELECT t.id, lt.path, ta.annotations_count, users.username
        FROM (
         SELECT t.id, count(a.id) AS annotations_count
         FROM annotator_store_tags t
         LEFT OUTER JOIN annotator_store_annotations a ON a.tag_id = t.id
         GROUP BY t.id
        ) ta
        JOIN annotator_store_tags t ON ta.id = t.id
        JOIN annotator_store_localized_tags lt ON t.id = lt.tag_id
        JOIN users ON t.creator_id = users.id
        WHERE lt.language_id = #{language.id}
        #{args[:created_by].present? ? "AND t.creator_id = #{args[:created_by].id}" : '' }
        ORDER BY lt.path ASC
      ")
      r.map {|t| ["#{t['path']} (#{t['annotations_count']}) by #{t['username']}", t['id']] }
    end

    def annotation_type_view(type)
      case type
      when 'TextAnnotation' then
        'Text'
      when 'ImageAnnotation' then
        'Image'
      when 'VideoAnnotation' then
        'Video'
      else
        type
      end
    end


  end
end


# NOTE: Not in use. Too slow.
# # tags:
# def nested_dropdown_tags(args={})
#   result = []
#   args[:tags].each do |item, sub_items|
#     path = (item.depth > 0) ? item.ancestors.includes(:annotations, :names).map(&:name).join(' → ') + ' → ' : ''
#
#     result << [path + "#{item.name} (#{item.annotations_count}) by #{item.creator.username}", item.id]
#     result += nested_dropdown_tags(tags: sub_items) unless sub_items.blank?
#   end
#   result
# end

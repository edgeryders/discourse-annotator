require 'current_user'

module Annotator
  module ApplicationHelper

    require_relative '../../../lib/helpers/markdown_renderer'
    include CurrentUser

    def markdown(content)
      @markdown ||= Redcarpet::Markdown.new(MarkdownRenderer, autolink: true)
      @markdown.render(content).html_safe
    end


    # tags:
    def nested_dropdown_tags(args={})
      result = []
      args[:tags].each do |item, sub_items|
        path = (item.depth > 0) ? item.ancestors.includes(:annotations, :names).map(&:name).join(' → ') + ' → ' : ''

        result << [path + "#{item.name} (#{item.annotations_count}) by #{item.creator.username}", item.id]
        result += nested_dropdown_tags(tags: sub_items) unless sub_items.blank?
      end
      result
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
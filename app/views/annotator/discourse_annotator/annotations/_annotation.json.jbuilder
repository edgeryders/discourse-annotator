json.id annotation.id
json.uri annotation.uri


language = defined?(@current_user) ? DiscourseAnnotator::UserSetting.language_for_user(@current_user) : nil


json.created_at annotation.created_at
json.updated_at annotation.updated_at

json.post_id annotation.post_id
# See: https://github.com/edgeryders/discourse-annotator/issues/201
json.post_creator_id annotation.post&.user_id
json.creator_id annotation.creator_id
json.type annotation.type
json.topic_id annotation.topic_id
json.code_id annotation.code_id


if annotation.text_annotation?
  json.annotator_schema_version annotation.version
  json.text annotation.text
  json.quote annotation.quote
  json.ranges do
    json.array! annotation.ranges do |range|
      json.start range.start
      json.end range.end
      json.startOffset range.start_offset
      json.endOffset range.end_offset
    end
  end
elsif annotation.video_annotation?
  json.id annotation.id
  json.ranges []
  json.target do
    json.container annotation.container
    json.src annotation.src
    json.ext annotation.ext
  end
  json.rangeTime do
    json.start annotation.start
    json.end annotation.end
  end
  json.media 'video'
  json.text ''
  json.deleted false
  json.archived false
  json.priority '0'
  json.imagePreview ''
  # {
  #   "id":4078,
  #   "ranges":[],
  #   "created":"2019-02-04T15:37:24+0000",
  #   "updated":"2019-02-04T15:37:24+0000",
  #   "target":{
  #     "container":"vid1",
  #     "ext":".mp4",
  #     "src":"\/dashboard\/video\/3.mp4"
  #   },
  #   "rangeTime":{
  #     "start":12.4063953,
  #     "end":51.36715641
  #   },
  #   "uri":"",
  #
  #   "media":"video",
  #   "text":" "ted talk<\/p>",
  #   "deleted":false,
  #   "archived":false,
  #   "priority":"0",
  #   "imagePreview":"",
  # },
elsif annotation.image_annotation?
  json.url annotation.src
  json.page_url ''
  json.text ''
  json.ranges []
  json.quote ''
  json.l do
    json.array! [0] do
      json.type annotation.shape
      json.units annotation.units
      geometry = JSON.parse(annotation.geometry)
      json.a do
        json.x geometry['x']
        json.y geometry['y']
        json.width geometry['width']
        json.height geometry['height']
      end
    end
  end
  # {
  #   "url": "http://lloydbleekcollection.cs.uct.ac.za/images/stow/STOW_001.JPG",
  #   "text": "sdfdfasdf",
  #   "ranges": [],
  #   "quote": "",
  #   "closure_uid_k7l337": 6,
  #   "l": [
  #     {
  #       "type": "rect",
  #       "a": {
  #         "x": 314,
  #         "width": 261,
  #         "y": 207,
  #         "height": 188
  #       }
  #     }
  #   ]
  # }
end

json.codes annotation.code.present? ? [annotation.code.path.map {|t| t.localized_name(language)}.join(DiscourseAnnotator::LocalizedCode.path_separator)] : []

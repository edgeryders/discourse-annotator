# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :discourse_annotator_annotation, class: DiscourseAnnotator::Annotation do
    version "v#{Faker::App.version}"
    text Faker::Lorem.sentence
    quote Faker::Lorem.sentence
    uri Faker::Internet.url
  end
end

module DiscourseAnnotator
  RSpec.describe Range, type: :model do
    let(:range) { FactoryGirl.create :discourse_annotator_range }

    it 'has a valid factory' do
      expect(range).to be_valid
    end
  end
end

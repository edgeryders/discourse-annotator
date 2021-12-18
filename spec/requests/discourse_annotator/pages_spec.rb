module DiscourseAnnotator
  RSpec.describe 'Pages', type: :request do
    describe 'GET /' do
      it 'returns response status 200' do
        get discourse_annotator.root_path
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET /search' do
      it 'returns response status 200' do
        get discourse_annotator.search_path
        expect(response).to have_http_status(200)
      end
    end
  end
end

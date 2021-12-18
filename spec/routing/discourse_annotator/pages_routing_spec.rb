module DiscourseAnnotator
  RSpec.describe PagesController, type: :routing do
    routes { DiscourseAnnotator::Engine.routes }

    describe 'routing' do
      it 'routes GET / to #index' do
        expect(get: '/').to route_to('discourse-annotator/pages#index', format: :json)
      end

      it 'routes GET /search to #search' do
        expect(get: '/search').to route_to('discourse-annotator/pages#search', format: :json)
      end
    end
  end
end

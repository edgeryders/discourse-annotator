module DiscourseAnnotator
  RSpec.describe AnnotationsController, type: :routing do
    routes { DiscourseAnnotator::Engine.routes }

    describe 'routing' do
      it 'routes POST /annotations to #create' do
        expect(post: '/annotations').to route_to('discourse-annotator/annotations#create', format: :json)
      end

      it 'routes GET /annotations/1 to #show' do
        expect(get: '/annotations/1').to route_to('discourse-annotator/annotations#show', id: '1', format: :json)
      end

      it 'routes PUT /annotations/1 to #update' do
        expect(put: '/annotations/1').to route_to('discourse-annotator/annotations#update', id: '1', format: :json)
      end

      it 'routes DELETE /annotations/1 to #destroy' do
        expect(delete: '/annotations/1').to route_to('discourse-annotator/annotations#destroy', id: '1', format: :json)
      end

      it 'routes OPTIONS /annotations/1 to #options' do
        expect(options: '/annotations/1').to route_to('discourse-annotator/annotations#options', id: '1', format: :json)
      end

      it 'routes OPTIONS /annotations to #options' do
        expect(options: '/annotations').to route_to('discourse-annotator/annotations#options', format: :json)
      end

      it 'routes OPTIONS /search to #options' do
        expect(options: '/search').to route_to('discourse-annotator/annotations#options', format: :json)
      end
    end
  end
end

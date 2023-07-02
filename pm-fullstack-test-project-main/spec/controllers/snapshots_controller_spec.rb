require 'rails_helper'

RSpec.describe SnapshotsController, type: :controller do
  describe 'GET #show' do
    let(:snapshot) { Snapshot.create!(data: "some data") }

    before do
      allow(Snapshot).to receive(:last).and_return(snapshot)
      get :show
    end

    it 'assigns @snapshot' do
      expect(assigns(:snapshot)).to eq(snapshot)
    end

    it 'responds successfully with an HTTP 200 status code' do
      expect(response).to be_successful
      expect(response).to have_http_status(200)
    end

    it 'renders the show template' do
      expect(response).to render_template(:show)
    end
  end
end

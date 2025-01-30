require 'rails_helper'


RSpec.describe "Drumracks", type: :request do

  # Load seed once at the beginning of the test suite
  before(:all) do
    Rails.application.load_seed
  end

  let!(:drumrack) { Drumrack.first }
  let!(:user) { User.first }

  describe 'GET /drumracks' do

    it 'displays templates and drumracks' do
      get drumracks_path
      expect(response).to have_http_status(:success)

    end
  end

  describe 'GET /drumracks/:id' do

    it 'shows drumrack' do
      get drumrack_path(drumrack)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /drumracks/:id/soundbox' do
    before do
      sign_in user
    end

    it 'shows the soundbox' do
      get soundbox_drumrack_path(drumrack)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /drumracks/:id/duplicate' do
    before do
      sign_in user
    end

    it 'duplicates the drumrack' do
      expect {
        get duplicate_drumrack_path(drumrack)
      }.to change(Drumrack, :count).by(1)
      expect(response).to redirect_to(soundbox_drumrack_path(Drumrack.last))
    end

    it 'duplicates samples and their associations' do
      get duplicate_drumrack_path(drumrack)
      new_drumrack = Drumrack.last

      expect(new_drumrack.samples.count).to eq(drumrack.samples.count)
      expect(new_drumrack.pads.count).to eq(drumrack.pads.count)
      expect(new_drumrack.drumrack_samples.first.pad_drumrack_samples.where(active: true).count)
      .to eq(drumrack.drumrack_samples.first.pad_drumrack_samples.where(active: true).count)
      expect(new_drumrack.user).to eq(user)
      expect(new_drumrack.is_template).to be false
    end
  end

  describe 'GET /drumracks/search' do
    before do
      sign_in user
    end

    it 'returns filtered results when query is present' do
      drumrack.genre = 'Rspec Test Hip Hop Drumrack'
      get search_drumracks_path, params: { query: 'Rspec Test Hip Hop Drumrack' }, xhr: true
      expect(response).to have_http_status(:success)
    end

    it 'returns all non-template drumracks when no query' do
      get search_drumracks_path, xhr: true
      expect(response).to have_http_status(:success)
    end
  end
end

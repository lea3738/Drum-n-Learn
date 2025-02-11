require 'rails_helper'

RSpec.describe "Drumracks", type: :request do
  # Load seed once at the beginning of the test suite
  before(:all) do
    Rails.application.load_seed
  end

  let!(:drumrack) { Drumrack.first }

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
    include_context 'with authenticated user'

    # it 'shows the soundbox' do
    #   get soundbox_drumrack_path(drumrack)
    #   expect(response).to have_http_status(:success)
    # end

    before do
      get soundbox_drumrack_path(drumrack)
    end

    it_behaves_like 'successful status'
  end

  describe 'GET /drumracks/:id/duplicate' do
    include_context 'with authenticated user'

    it 'duplicates the drumrack' do
      expect do
        get duplicate_drumrack_path(drumrack)
      end.to change(Drumrack, :count).by(1)
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


  describe 'PATCH /drumracks/:id' do
    include_context 'with authenticated user'

    let(:updated_name) { "Rspec Test Drumrack" }
    let(:updated_bpm) { 100 }
    let(:pads_data) {
      [
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]",
        "[{\"active\":true,\"category\":\"bass\"},{\"active\":false,\"category\":\"kick\"},{\"active\":false,\"category\":\"snare\"},{\"active\":false,\"category\":\"hihat\"},{\"active\":false,\"category\":\"oneshot\"}]"
      ]
    }

    let(:valid_params) do
      {
        name: updated_name,
        bpm: updated_bpm,
        pads: pads_data
      }
    end

    it "updates the drumrack attributes" do
      patch drumrack_path(drumrack), params: valid_params, as: :json

      expect(response).to have_http_status(:ok)
      drumrack.reload
      expect(drumrack.name).to eq(updated_name)
      expect(drumrack.bpm).to eq(updated_bpm)
      expect(drumrack.is_template).to be_falsey
    end

    it "updates pad_drumrack_samples' active status" do
      patch drumrack_path(drumrack), params: valid_params, as: :json

      drumrack.pads.each_with_index do |pad, index|
        parsed_pad_json = JSON.parse(pads_data[index])

        pad.pad_drumrack_samples.each do |pad_drumrack_sample|
          expected_active = parsed_pad_json.find { |sample_json| sample_json["category"] == pad_drumrack_sample.sample.category }["active"]
          expect(pad_drumrack_sample.reload.active).to eq(expected_active)
        end
      end
    end

    it "returns JSON success response" do
      patch drumrack_path(drumrack), params: valid_params, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match("status" => "ok")
    end
  end

  describe 'GET /drumracks/search' do
    include_context 'with authenticated user'

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

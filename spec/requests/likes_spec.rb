require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let(:drumrack) { create(:drumrack, user: user) }
  let!(:like) { create(:like, user: user, drumrack: drumrack) }

  before do
    sign_in user
  end

  describe "GET /drumracks/:drumrack_id/likes/new" do
    it "renders the new like form" do
      get new_drumrack_like_path(drumrack_id: drumrack.id)
      expect(response).to be_successful
      expect(response.body).to include("new like")
    end
  end

  describe "POST /drumracks/:drumrack_id/likes" do
    it "creates a new like" do
      expect {
        post drumrack_likes_path(drumrack_id: drumrack.id)
      }.to change { drumrack.likes.count }.by(1)

      expect(response).to redirect_to(root_path).or redirect_to(/.+/)
      follow_redirect!
      expect(response).to be_successful # Check if the redirected page loads successfully
    end

    it "renders turbo stream update" do
      post drumrack_likes_path(drumrack_id: drumrack.id)

      expect(response.content_type).to include("text/vnd.turbo-stream.html")
      expect(response.body).to include("drumrack_#{drumrack.id}")
    end
  end

  describe "DELETE /drumracks/:drumrack_id/likes/:id" do
    it "destroys a like" do
      expect {
        delete drumrack_like_path(drumrack_id: drumrack.id, id: like.id)
      }.to change { drumrack.likes.count }.by(-1)

      expect(response).to redirect_to(root_path).or redirect_to(/.+/)
      follow_redirect!
      expect(response).to be_successful
    end

    it "renders turbo stream update after destroy" do
      delete drumrack_like_path(drumrack_id: drumrack.id, id: like.id)

      expect(response.content_type).to include("text/vnd.turbo-stream.html")
      expect(response.body).to include("drumrack_#{drumrack.id}")
    end
  end
end

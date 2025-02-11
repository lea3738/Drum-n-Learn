class LikesController < ApplicationController
  def new
    @drumrack = Drumrack.find(params[:drumrack_id])
    @like = Like.new
  end

  def create
    @drumrack = Drumrack.find(params[:drumrack_id])
    @like = Like.new(drumrack: @drumrack, user: current_user).save

    Rails.logger.debug "Drumrack: #{@drumrack.inspect}"

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "drumrack_#{@drumrack.id}",
          partial: "shared/music_card",
          locals: {
            drumrack: @drumrack,
            liked_by_current_user: true,
            display_like_button: true,
            display_share_link: false
          }
        )
      end
    end
  end

  def destroy
    @like = Like.find(params[:id])
    @drumrack = @like.drumrack
    @like.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "drumrack_#{@drumrack.id}",
          partial: "shared/music_card",
          locals: {
            drumrack: @drumrack,
            liked_by_current_user: false,
            display_like_button: true,
            display_share_link: false
          }
        )
      end
    end
  end
end

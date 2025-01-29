require 'json'

class DrumracksController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show templates]
  skip_before_action :verify_authenticity_token
  before_action :set_drumrack, only: %i[show soundbox update duplicate]

  def index
    @templates = Drumrack.where(is_template: true)

    @drumracks = Drumrack.joins(:user)
                         .where(is_template: false)

    if params[:query].present?
      sql_subquery = <<~SQL
        drumracks.genre @@ :query
        OR users.username @@ :query
        AND drumracks.is_template = false
      SQL
      @drumracks = @drumracks.where(sql_subquery, query: "%#{params[:query]}%")
    end

    # sort by number of likes and add pagination
    @drumracks = @drumracks.left_joins(:likes)
                           .group('drumracks.id')
                           .order('COUNT(likes.id) DESC')
                           .paginate(page: params[:page], per_page: 10)

    # Respond with HTML for Turbo
    respond_to do |format|
      format.html do
        if request.headers["Turbo-Frame"]
          # Only render the partial for the Turbo Frame when requested via Turbo
          render partial: "shared/community", locals: { drumracks: @drumracks }
        else
          render :index
        end
      end
    end
  end

  def after_sign_up_path_for(resource)
    user_path(resource)
  end

  def after_sign_in_path_for(resource)
    user_path(resource)
  end

  def soundbox
    @samples_from_drumrack = @drumrack.samples.each_with_object({}) do |sample, hash|
      hash[sample.category] = sample.sound.url
    end.to_json
  end

  def show
    @samples_from_drumrack = @drumrack.samples.each_with_object({}) do |sample, hash|
      hash[sample.category] = sample.sound.url
    end.to_json
  end

  def duplicate
    duplicated_drumrack = @drumrack.dup
    duplicated_drumrack.is_template = false
    duplicated_drumrack_samples = []

    @drumrack.samples.each do |sample|
      duplicated_drumrack_sample = DrumrackSample.create(sample: sample, drumrack: duplicated_drumrack)
      duplicated_drumrack_samples << duplicated_drumrack_sample
    end

    duplicated_drumrack.pads.each_with_index do |pad, pad_index|
      duplicated_drumrack_samples.each_with_index do |drumrack_sample, i|
        active = @drumrack.pads[pad_index].pad_drumrack_samples[i].active
        PadDrumrackSample.create(pad: pad, drumrack_sample: drumrack_sample, active: active)
      end
    end

    duplicated_drumrack.user = current_user
    duplicated_drumrack.save
    redirect_to soundbox_drumrack_path(duplicated_drumrack)
  end

  def edit
    @drumrack = Drumrack.find(params[:id])
  end

  def update
    data = params[:pads]

    @drumrack.update(name: params[:name], bpm: params[:bpm], user: current_user, is_template: false)

    data.each_with_index do |pad_json, index|
      pad_json = JSON.parse(pad_json)
      pad = @drumrack.pads[index]
      next unless pad

      pad.pad_drumrack_samples.each do |pad_drumrack_sample|
        pad_sample_json = pad_json.is_a?(Array) ? pad_json.find { |l| l["category"] == pad_drumrack_sample.sample.category } : nil

        if pad_sample_json
          pad_drumrack_sample.update(active: pad_sample_json["active"])
        else
          Rails.logger.warn "Aucune correspondance trouvée pour la catégorie #{pad_drumrack_sample.sample.category}"
        end
      end
    end

    respond_to do |format|
      format.json { render json: { status: 'ok' } }
      format.html { redirect_to soundbox_drumrack_path(@drumrack) }
    end
  end

  def templates
    @templates = Drumrack.where(is_template: true)
  end

  private

  def set_drumrack
    @drumrack = Drumrack.find(params[:id])
  end

  def drumrack_params
    params.require(:drumrack).permit(:name, :pads)
  end
end

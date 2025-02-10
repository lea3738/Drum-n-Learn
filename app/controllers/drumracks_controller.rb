require 'json'

class DrumracksController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show templates search]
  skip_before_action :verify_authenticity_token
  before_action :set_drumrack, only: %i[show soundbox update duplicate]

  def index
    @templates = Drumrack.templates
    @drumracks = Drumrack.joins(:user)
                         .user_drumracks
                         .ordered_by_likes
                         .paginate(page: params[:page], per_page: 10)
  end

  def search
    @drumracks = search_drumracks.paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html { render partial: "shared/community", locals: { drumracks: @drumracks } }
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
      hash[sample.category] = Rails.application.routes.url_helpers.rails_blob_path(sample.sound, only_path: true)
    end.to_json
  end

  def show
    @samples_from_drumrack = @drumrack.samples.each_with_object({}) do |sample, hash|
      hash[sample.category] = Rails.application.routes.url_helpers.rails_blob_path(sample.sound, only_path: true)
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
      duplicated_drumrack_samples.each do |duplicated_drumrack_sample|
        is_active = @drumrack.pads[pad_index].pad_drumrack_samples.find do |pad_drumrack_sample|
          pad_drumrack_sample.sample == duplicated_drumrack_sample.sample
        end["active"]
        PadDrumrackSample.create(pad: pad, drumrack_sample: duplicated_drumrack_sample, active: is_active)
      end
    end

    duplicated_drumrack.user = current_user
    if duplicated_drumrack.save
      redirect_to soundbox_drumrack_path(duplicated_drumrack)
    else
      # Handle failure
      redirect_to drumrack_path(@drumrack), alert: 'Duplicate failed'
    end
  end

  def edit
    @drumrack = Drumrack.find(params[:id])
  end

  def update
    data = params[:pads]
    Rails.logger.debug "Received pads: #{data.inspect}"

    @drumrack.update(name: params[:name], bpm: params[:bpm], user: current_user, is_template: false)

    # for each pad in the data
    data.each_with_index do |pad_json, index|
      # parse the data pad json
      parsed_pad_json = JSON.parse(pad_json)
      # get the corresponding pad in the drumrack
      pad = @drumrack.pads[index]
      next unless pad

      pad.pad_drumrack_samples.each do |pad_drumrack_sample|
        is_active = parsed_pad_json.find do |pad_sample_json|
          pad_sample_json["category"] == pad_drumrack_sample.sample.category
        end["active"]
        pad_drumrack_sample.update(active: is_active)
      end
    end

    respond_to do |format|
      format.json { render json: { status: 'ok' } }
      format.html { redirect_to soundbox_drumrack_path(@drumrack) }
    end
  end

  def templates
    @templates = Drumrack.templates
  end

  private

  def set_drumrack
    @drumrack = Drumrack.find(params[:id])
  end

  def drumrack_params
    params.require(:drumrack).permit(:name, :pads)
  end

  def search_drumracks
    @drumracks = Drumrack.joins(:user).user_drumracks

    if params[:query].present?
      sql_subquery = <<~SQL
        drumracks.genre ILIKE :query
        OR users.username ILIKE :query
        AND drumracks.is_template = false
      SQL
      @drumracks = @drumracks.where(sql_subquery, query: "#{params[:query]}%")
    end

    @drumracks
  end
end

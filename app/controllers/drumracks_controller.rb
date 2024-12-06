require 'json'

class DrumracksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :templates]
  skip_before_action :verify_authenticity_token
  before_action :set_drumrack, only: [:show, :soundbox, :update, :duplicate]

  def index
    @templates = Drumrack.where(is_template: true)
    if params[:query].present?
      sql_subquery = <<~SQL
        drumracks.genre @@ :query
        OR users.username @@ :query
        AND drumracks.is_template = false
      SQL
      @drumracks = @drumracks.joins(:user)
                             .where(sql_subquery, query: "%#{params[:query]}%")
                             .sort_by { |drumrack| drumrack.likes.count }.reverse
    end
    @drumracks = Drumrack.all.where(is_template: false).sort_by { |drumrack| drumrack.likes.count }.reverse
  end

  def after_sign_up_path_for(resource)
    user_path(resource)
  end

  def after_sign_in_path_for(resource)
    root_path
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

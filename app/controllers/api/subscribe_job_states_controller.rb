##
# Controller to query the state of SubscribeUserWorker instances enqued for the user.

class Api::SubscribeJobStatesController < ApplicationController

  before_filter :authenticate_user!

  respond_to :json

  ##
  # Return JSON indicating the state of the subscribe jobs initiated by the current user

  def index
    if SubscribeJobState.exists? user_id: current_user.id
      @job_states = SubscribeJobState.where user_id: current_user.id
      Rails.logger.debug "User #{current_user.id} - #{current_user.email} has #{@job_states.count} SubscribeJobState instances"
      render 'index', locals: {job_states: @job_states}
    else
      head status: 404
    end
  rescue => e
    handle_error e
  end

  ##
  # Return JSON indicating the state of a single subscribe job initiated by the current user

  def show
    @job_state = current_user.find_subscribe_job_state params[:id]
    # If job state has not changed, return a 304
    if stale? last_modified: @job_state.updated_at
      render 'show', locals: {job_state: @job_state}
    end
  rescue => e
    handle_error e
  end

  ##
  # Remove job state from the database. This will make its alert disappear from the start page as well.

  def destroy
    @job_state = current_user.find_subscribe_job_state params[:id]
    Rails.logger.debug "Destroying subscribe_job_state #{@job_state.id} for user #{current_user.id} - #{current_user.email}"
    @job_state.destroy!
    head status: 200
  rescue => e
    handle_error e
  end

end
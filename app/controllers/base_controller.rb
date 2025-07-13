class BaseController < ApplicationController
  rescue_from StandardError do |e|
    return_error(status: 500, code: 50_001, error: e, message: e.message)
  end

  private

  def return_error(status:, code:, error:, message:)
    Rails.logger.error({ api_error: { code: code, error: error, message: error.message, backtrace: error.backtrace } })
    render status: status, json: { code: code, message: message }
  end

  def return_success(status:, code:, data: nil)
    render status: status, json: { code: code, data: data }
  end
end

class Device < ApplicationRecord
  def self.log_headers
    push_token = request.headers['HTTP_X_PUSH_TOKEN']
    device_uid = request.headers['HTTP_X_DEVICE_UID']
    access_token = request.headers['HTTP_X_ACCESS_TOKEN']
    user_agent = request.user_agent

    Rails.logger.debug("PUSH_TOKEN: #{push_token}")
    Rails.logger.debug("DEVICE_UID: #{device_uid}")
    Rails.logger.debug("ACCESS_TOKEN: #{access_token}")
    Rails.logger.debug("USER_AGENT #{user_agent}")
  end
end
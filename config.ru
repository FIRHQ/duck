# encoding: utf-8
# Usage: cd faye_server && bundle exec thin start -C thin.yml

require 'faye'
require 'redis'
require 'json'
require 'redis-namespace'

Faye::WebSocket.load_adapter('thin')

REDIS_HOST = ENV["DUCK_REDIS_HOST"] || "127.0.0.1"
REDIS_PORT = ENV["DUCK_REDIS_PORT"] || "6379"
REDIS_PASSWORD = ENV["DUCK_REDIS_PASSWORD"]
MSG_TOKEN = ENV["DUCK_MSG_TOKEN"] || "operation cwal"
DUCK_LOCAL_URL = ENV["DUCK_LOCAL_URL"] || "http://127.0.0.1:8080/faye"

$redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT, password: REDIS_PASSWORD)

app = Faye::RackAdapter.new(mount: '/faye', timeout: 25)

class ServerAuth
  def valid?(_user_id, _time_stamp, _key)
    true
  end

  def send_saved_log
    log = $redis.zrange("#{job_step.job_id}-#{job_step.index}", 0, -1) || []
    log.map { |l| l[6..-1] }.join("")
  end

  def incoming(message, _request, callback)
    puts "from faye: #{message}"
    if message['channel'] == '/meta/subscribe'
      message['ext'] ||= {}
      user_id = message['ext']['user_id']
      time_stamp = message['ext']['time_stamp']
      key = message['ext']['key']
      message['error'] = '403::Faye authorize faild' unless valid?(user_id, time_stamp, key)
      if valid?(user_id, time_stamp, key) 
        log = $redis.zrange(message['subscription'][1..-1], 0, -1) || []
        message['ext']['cached_log'] = log.map { |l| l[6..-1] }.join("")
      else
        message['error'] = '403::Faye authorize faild' unless valid?(user_id, time_stamp, key)
      end

    end
    #
    # 发送消息，目前只需要服务器发消息
    if message['channel'] !~ %r{^/meta/}
      message['ext'] ||= {}
      msg_token =  message['ext']['token']
      if msg_token != MSG_TOKEN
        message['error'] = "403::Faye authorize faild #{message}"
      end
      message['ext']['token'] = 'love and peace'
    end
    callback.call(message)
  end
end

app.add_extension(ServerAuth.new)

run app

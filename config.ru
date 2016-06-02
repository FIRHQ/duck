# encoding: utf-8
# Usage: cd faye_server && bundle exec thin start -C thin.yml

require 'faye'
require 'redis'
require 'redis-namespace'

Faye::WebSocket.load_adapter('thin')

REDIS_HOST = ENV["DUCK_REDIS_HOST"] || "127.0.0.1"
REDIS_PORT = ENV["DUCK_REDIS_PORT"] || "6379"
REDIS_PASSWORD = ENV["DUCK_REDIS_PASSWORD"]
MSG_TOKEN = ENV["DUCK_MSG_TOKEN"] || "operation cwal"

$redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT, password: REDIS_PASSWORD)
$online_user_redis = Redis::Namespace.new(:flow_api_online_users, redis: $redis) # 保存在线用户

app = Faye::RackAdapter.new(mount: '/faye', timeout: 25)

class ServerAuth
  def valid?(user_id, time_stamp, key)
    true
  end

  def incoming(message, _request, callback)
    if message['channel'] == '/meta/subscribe'
      message['ext'] ||= {}
      user_id = message['ext']['user_id']
      time_stamp = message['ext']['time_stamp']
      key = message['ext']['key']
      message['error'] = '403::Faye authorize faild' unless valid?(user_id, time_stamp, key)
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

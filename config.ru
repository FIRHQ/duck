# encoding: utf-8
# Usage: cd faye_server && bundle exec thin start -C thin.yml

require 'faye'
require 'redis'
require 'redis-namespace'
Faye::WebSocket.load_adapter('thin')

REDIS_HOST = ENV["DUCK_REDIS_HOST"] || "127.0.0.1"
REDIS_PORT = ENV["DUCK_REDIS_PORT"] || "6379"
MSG_TOKEN = ENV["DUCK_MSG_TOKEN"] || "Hello World"

$redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)
$online_user_redis = Redis::Namespace.new(:flow_api_online_users, redis: $redis) # 保存在线用户

app = Faye::RackAdapter.new(mount: '/faye', timeout: 25)

class ServerAuth
  def incoming(message, _request, callback)
    if message['channel'] == '/meta/subscribe'
      message['ext'] ||= {}
      msg_token = message['ext']['socket_token']
      user_id = message['ext']['user_id']
      message['error'] = '403::Faye authorize faild' if $online_user_redis.get(user_id) != msg_token
    end
    #
    # 发送消息，目前只需要服务器发消息
    if message['channel'] !~ %r{^/meta/}
      # msg_token = message['data'] && message['data']['token']
      message['data'] ||= {}
      msg_token =  message['data']['token']
      if msg_token != MSG_TOKEN
        message['error'] = "403::Faye authorize faild #{message}"
      end
    end
    callback.call(message)
  end
end

app.add_extension(ServerAuth.new)

run app

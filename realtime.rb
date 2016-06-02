require 'sinatra'
require 'net/http'
require 'json'
require 'redis'
require 'redis-namespace'


REDIS_HOST = ENV["DUCK_REDIS_HOST"] || "127.0.0.1"
REDIS_PORT = ENV["DUCK_REDIS_PORT"] || "6379"
REDIS_PASSWORD = ENV["DUCK_REDIS_PASSWORD"]
MSG_TOKEN = ENV["DUCK_MSG_TOKEN"] || "operation cwal"
DUCK_LOCAL_URL = ENV["DUCK_LOCAL_URL"] || "http://127.0.0.1:8080/faye"

$redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT, password: REDIS_PASSWORD)

configure {
    set :server, :puma
}

class Pumatra < Sinatra::Base
  def save_log_to_cache(hash)
    key = "#{hash['job_id']}-#{hash['index']}"
    # line 仅作为换行来使用,
    $redis.zadd(key, hash['line'], "#{Time.now.strftime('%6N')}#{hash['log']}")
    $redis.expire(key, 3600 * 5)
  end

  def send_log_to_channel(hash)
    # 这里不查询数据库的原因是为了提高效率
    channel = "/#{hash['job_id']}-#{hash['index']}"
    Thread.new do
      message = { channel: channel, data: hash, ext: { token: MSG_TOKEN } }
      uri = URI.parse(DUCK_LOCAL_URL)
      Net::HTTP.post_form(uri, message: message.to_json)
    end
  end

  def valid?(params)
    puts params
    true
  end

  get '/' do
    "show me the money"
  end

  post '/message/realtime' do
    hash = JSON.parse(request.body.read)
    return 403 unless valid?(hash)
    save_log_to_cache(hash)
    send_log_to_channel(hash)
    "ok"
  end
end

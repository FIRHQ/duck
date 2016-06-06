# duck

> When I see a bird that walks like a duck and swims like a duck and quacks like a duck, I call that bird a duck.
> Whitcomb Riley

![duck](http://7xsrs3.com2.z0.glb.qiniucdn.com/5b55b3743e4f5d39c8b0a5725c5c10a5.png)




## 简述
此项目用来告诉 api 日志信息

## cap 部署方式

部署前请确保以下环境变量在机器当中，否则会进行默认设置

REDIS_HOST = ENV["DUCK_REDIS_HOST"] || "127.0.0.1"
REDIS_PORT = ENV["DUCK_REDIS_PORT"] || "6379"
REDIS_PASSWORD = ENV["DUCK_REDIS_PASSWORD"]
MSG_TOKEN = ENV["DUCK_MSG_TOKEN"] || "operation cwal"
DUCK_LOCAL_URL = ENV["DUCK_LOCAL_URL"] || "http://127.0.0.1:8080/faye"


## docker 部署方式

### 为何使用docker
faye 本身无状态，特别适合使用docker 进行性能横向扩展

### 安装前提
- 成功安装 docker

### 安装运行流程
docker built -t image名字 .
docker run -p 映射的端口:8080 -e 要替换的环境变量 image名字

```
eg:
docker built -t flow/faye .
docker run -d -p 3001:8080 -e DUCK_REDIS_HOST="192.168.31.206" flow/faye:latest
```
### 配置项
使用环境变量控制以下信息
```
REDIS_HOST = ENV["DUCK_REDIS_HOST"] || "127.0.0.1"
REDIS_PORT = ENV["DUCK_REDIS_PORT"] || "6379"
REDIS_PASSWORD = ENV["DUCK_REDIS_PASSWORD"]
MSG_TOKEN = ENV["DUCK_MSG_TOKEN"] || "Hello World"
```
其中 `MSG_TOKEN` 为发送消息时的验证。
`REDIS_HOST` 和 `REDIS_PORT` 为redis 服务器。特别注意，这个redis 服务器必须对这个容器可见（`默认安装的redis 只对127.0.0.1 可见`）

## 使用示例
### 发送端
``` bash
curl -X POST http://192.168.1.249:8080/faye -H 'Content-Type: application/json' -d '{"channel": "/foo", "data": {"he":"h2"}, "ext": {"token": "Hello World"}}'
```

### 接收端
``` javascript
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Test</title>
</head>
<body>
    <script type="text/javascript" src="http://192.168.99.100:3001/faye.js"></script>
    <script charset="utf-8">
    var client = new Faye.Client('http://192.168.99.100:3001/faye');

    var USER_ID    = "test",
        USER_TOKEN = '123456';

    client.addExtension({
      outgoing: function(message, callback) {
        if (message.channel !== '/meta/subscribe')
          return callback(message);
        message.ext = message.ext || {};
        message.ext.user_id = USER_ID;
        message.ext.socket_token = USER_TOKEN;
        callback(message);
      }
    });

    var subscription = client.subscribe('/foo', function(message) {
      alert("ok")
      alert(message)
    });

    </script>
</body>
</html>

```

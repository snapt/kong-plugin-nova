Kong Nova Plugin
====================

## Install the plugin
git clone https://github.com/snapt/kong-plugin-nova.git
cd kong-plugin-nova
luarocks make
luarocks pack kong-plugin-nova 0.1.0
luarocks install kong-plugin-nova-0.1.0-1.all.rock

## Add plugin to kong.conf
```
plugins = bundled, nova
```

```
kong restart
```

## Create example service
```
curl -i -X POST \
  --url http://localhost:8001/services/ \
  --data 'name=novatest-service' \
  --data 'url=http://mockbin.org'
```

## Add example route
```
curl -i -X POST \
  --url http://localhost:8001/services/novatest-service/routes \
  --data 'hosts[]=novatest.com'
```


## Configure Nova plugin for novatest-service
Important: set the config.novaService URL to point to a Nova Kong WAF.

```
curl -i -XPOST \
    --url http://localhost:8001/services/novatest-service/plugins/ \
    --data 'name=nova&config.novaService=http://159.65.209.14'
```

## Test a legitimate request
```
curl -i -X GET \
  --url http://localhost:8000/ \
  --header 'Host: novatest.com'
```  

## Test a blocked request
```
curl -i -X GET \
  --url "http://localhost:8000/?test=/etc/passwd" \
  --header 'Host: novatest.com'
```

If everything is working you will see: 
```
$ curl -i -X GET \
  --url "http://localhost:8000/?test=/etc/passwd" \
  --header 'Host: novatest.com'
  
HTTP/1.1 403 Forbidden
Date: Thu, 09 Jun 2022 08:20:53 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Content-Length: 70
x-nova-response: YES
X-Kong-Response-Latency: 80
Server: kong/2.8.1.1-enterprise-edition

{
  "message":"Your request has been blocked by the Snapt Nova WAF."
}
```

## Using the Nova Plugin

You can now configure the "nova" plugin on any services as shown above. 


Details
-------

* *Kong plugin name*: `nova`
* *Kong plugin version*: `0.1.0`

local http          = require "resty.http"
local kong_meta     = require "kong.meta"

local kong          = kong
local var           = ngx.var

local function send(status, content, headers)
  return kong.response.exit(status, content, headers)
end

local nova = {
  PRIORITY = 950,
  VERSION = '0.1.0',
}

function nova:access(config)
  -- set our kong header (to the backend)
  kong.service.request.set_header(config.request_header, "YES")
  
  local block_status = config.status or 403
  local block_message = config.message or "Your request has been blocked by the Snapt Nova WAF."

  local request_method = kong.request.get_method()
  local request_body = kong.request.get_raw_body()
  local request_headers = kong.request.get_headers()
  local request_args = kong.request.get_query()

  local client = http.new()
  client:set_timeout(20000)
  local novaRes, err = client:request_uri(config.novaService, {
    method = request_method,
    path = var.upstream_uri,
    body = request_body,
    query = request_args,
    headers = request_headers
  })

  if not novaRes then
    kong.log.err(err)
    return kong.response.exit(500, { message = "Failed to communicate with Nova" })
  end

  local response_status = novaRes.status

  -- if nova returns > 399 we return the Nova block page
  if response_status > 399 then
    return kong.response.error(block_status, block_message)
  end
  
end

function nova:header_filter(config)
  -- set our kong header (to the client)
  kong.response.set_header(config.response_header, "YES")
end

return nova

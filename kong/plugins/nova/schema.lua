local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "nova"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          -- a standard defined field (typedef), with some customizations
          { request_header = typedefs.header_name {
              required = true,
              default = "x-nova-request" } },
          { response_header = typedefs.header_name {
              required = true,
              default = "x-nova-response" } },
          { novaService = {
              type = "string",
              default = "http://traefik.nova-adc.com",
              required = true } }, 
          { status = {
            type = "integer",
            default = 403 } }, 
          { message = {
            type = "string",
            default = "Your request has been blocked by the Snapt Nova WAF." } }, 
        },
        entity_checks = {
          -- add some validation rules across fields
          -- the following is silly because it is always true, since they are both required
          { at_least_one_of = { "request_header", "response_header" }, },
          -- We specify that both header-names cannot be the same
          { distinct = { "request_header", "response_header"} },
        },
      },
    },
  },
}

return schema

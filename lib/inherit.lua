---@diagnostic disable: undefined-global, lowercase-global

local base = include 'lib/base'

local inherit = setmetatable({}, {__index = base})
inherit.__index = inherit

function inherit.new()
    local self = setmetatable(base.new(), inherit)
    return self
end

return inherit
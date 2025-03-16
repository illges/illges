---@diagnostic disable: undefined-global, lowercase-global

local base = {}
base.__index = base

function base.new()
    local self = setmetatable({}, base)
    return self
end

return base
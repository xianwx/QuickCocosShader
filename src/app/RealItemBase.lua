-- RealItemBase.lua
-- Author: xianwx
-- Date: 2016-08-28 16:07:28
-- 确实要显示的元素，继承这个即可
local RealItemBase = class("RealItemBase", function ()
    return display.newNode()
end)

function RealItemBase:ctor(info)
    self:_layout(info)
end

-- protected
function RealItemBase:_update(event)
    return event
end

function RealItemBase:_layout(info)
    -- craete every thing
    return info
end

return RealItemBase

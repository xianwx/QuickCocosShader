-- UnlimitedScroll.lua
-- Author: xianwx
-- Date: 2016-08-28 09:33:59
-- 无限滚动条
-- 暂时只做向左向右滑动，在屏幕指定位置放大（选中）
local UnlimitedScroll = class("UnlimitedScroll", function ()
    return display.newNode()
end)

return UnlimitedScroll
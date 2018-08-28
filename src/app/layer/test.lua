-- test.lua
-- Author: xianwx
-- Date: 2016-08-28 14:22:36
--
local base = require "app.RealItemBase"
local SYSFONT = "Font/minijiancuyuan.ttf"
local test = class("test", base)

function test:_layout(info)
    info = info or 0
    self:setContentSize(80, 80)
    display.newSprite("UI/Bag/none.png", 0, 0):addTo(self):setAnchorPoint(0, 0)
    self.label = cc.ui.UILabel.new({UILabelType = 2, font = SYSFONT, text = info, size = 24, color = cc.c3b(255, 255, 255)}):addTo(self):pos(30, 10)
end

function test:_update(event)
    local label = event.arg
    self.label:setString(label)
end

return test
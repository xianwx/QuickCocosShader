-- CoinNotice.lua
-- Author: xianwx
-- Date: 2016-07-13 14:37:51
-- 通知玩家有银两可以收取的图标
local clickFactory = require "app.helper.building.Factory"
local CoinNotice = class("CoinNotice", function ()
    return display.newNode()
end)

function CoinNotice:ctor(scale)
    self:setAnchorPoint(0.5, 0.5)
    display.newSprite("Icon/icongetmoney.png"):addTo(self):setAnchorPoint(0, 0)
    display.newSprite("Icon/common/silver.png", 32, 49):addTo(self)
    self:setContentSize(68, 85)
    addTouchEvent(self, {endCallback = function ()
        if self.state == "stop" then
            return
        end
        
        clickFactory.instance():collect(2)
    end, moveFix = true})
    self:setScale(1 / scale)
end

function CoinNotice:play()
    self.state = "play"
    self:setVisible(true)
    local sequence = transition.sequence({
        cc.MoveBy:create(0.4, cc.p(0, -10)),
        cc.MoveTo:create(0.4, cc.p(0, 10)),
    })
    self:runAction(cc.RepeatForever:create(sequence))
end

function CoinNotice:stop()
    self.state = "stop"
    self:stopAllActions()
    self:setPosition(0, 0)
    self:setVisible(false)
end

return CoinNotice

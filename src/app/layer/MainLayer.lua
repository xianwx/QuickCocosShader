-- MainLayer.lua
-- Author: xianwx
-- Date: 2016-08-28 10:27:13
-- 主界面
local effects = {
    "LightEffect",
    "InvertColorEffect",
    "GlowCircleEffect",
    "GrassyEffect",
    "CloudEffect",
    "FlameEffect",
    "DissolveEffect",
    "SearchLightEffect",
    "TransferEffect",
    "FluxayEffect_1",
    "FluxayEffect_2",
    "WaterWaveEffect",
}

local EffectLayer = require "app.layer.EffectLayer"
local MainLayer = class("MainLayer", function ()
    return display.newLayer()
end)

function MainLayer:ctor()
    local rBtn = display.newSprite("UI/ArmyDetail/labelArrow.png", 0, 0):addTo(self, 1)
    local lBtn = display.newSprite("UI/ArmyDetail/labelArrow.png", 0, 0):addTo(self, 1)
    rBtn:setAnchorPoint(0.5, 0.5)
    lBtn:setAnchorPoint(0.5, 0.5)
    lBtn:setRotation(180)
    local size = rBtn:getContentSize()
    rBtn:setPosition(display.width - size.width / 2, display.cy)
    lBtn:setPosition(size.width / 2, display.cy)

    local max = #effects

    addTouchEvent(rBtn, { endCallback = function ()
        local idx = self._idx + 1
        idx = idx > max and 1 or idx
        self:_displayLayer(idx)
    end, moveFix = true })

    addTouchEvent(lBtn, { endCallback = function ()
        local idx = self._idx - 1
        idx = idx < 1 and max or idx
        self:_displayLayer(idx)
    end, moveFix = true })

    self:_displayLayer(1)
end

function MainLayer:_displayLayer(idx)
    local effectName = effects[idx]
    if not effectName then
        return
    end

    self._idx = idx
    safeRemoveNode(self._layer)

    local layer = EffectLayer.new(effectName)
    layer:setAnchorPoint(0.5, 0.5)
    layer:setPosition(display.cx, display.cy)
    self:addChild(layer)

    self._layer = layer
end

return MainLayer

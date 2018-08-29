-- LightEffect.lua
-- Author: xianwx
-- Date: 2018-08-29 15:22:17
-- 模拟真实光照效果
local LightEffect = class("LightEffect")

function LightEffect.getDescText()
    return "模拟真实光照效果\n请随意点击或者拖动移动光源"
end

function LightEffect:init(node)
    -- 光照测试
    local light = LightEffect:create()

    light:retain()
    light:setLightPos({ x = display.cx + 100, y = display.cy + 100, z = 100 });
    light:setLightCutoffRadius(1000);
    light:setBrightness(2.0);

    local sp = EffectSprite:create("foreground_01.png")

    -- 参数：光源，法线图，法线图可以通过软件导出
    sp:setEffect(light, "foreground_01_n.png")

    sp:setPosition(display.cx, display.cy)
    node:addChild(sp)

    addTouchEvent(node, { endCallback = function (touch)
        light:setLightPos({ x = touch:getLocation().x, y = touch:getLocation().y, z = 100 })
    end, moveCallback = function (touch)
        light:setLightPos({ x = touch:getLocation().x, y = touch:getLocation().y, z = 100 })
    end, moveFix = true })
end

return LightEffect

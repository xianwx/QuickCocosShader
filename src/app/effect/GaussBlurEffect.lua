-- GaussBlurEffect.lua
-- Author: xianwx
-- Date: 2018-08-21 16:55:35
-- 高斯模糊效果

local test_sp = "startbg.jpg"

local shader = {
    fs = require "app.shader.GaussBlurFS",
    vert = require "app.shader.NormalVS",
}

local GaussBlurEffect = class("GaussBlurEffect", function ()
    return display.newLayer()
end)

function GaussBlurEffect:ctor()
    local label = createSimpleLabel({ text = "高斯模糊效果" }):addTo(self, 1)
    label:setAnchorPoint(0.5, 0.5)
    label:setPosition(display.cx, display.height - label:getContentSize().height / 2)

    local sp = display.newSprite(test_sp, display.cx, display.cy):addTo(self)
    local bluramount = 0
    local name = "gaussblur"

    -- 创建GLProgram
    local cache = cc.GLProgramCache:getInstance()
    local p = cc.GLProgram:createWithByteArrays(shader.vert, shader.fs)
    p:link()
    p:updateUniforms()
    p:use()
    cache:addGLProgram(p, name)

    -- set uniform value
    local glState = cc.GLProgramState:getOrCreateWithGLProgram(p)
    glState:setUniformFloat("bluramount", bluramount)

    sp:setGLProgramState(glState)
    sp:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function ()
        bluramount = bluramount + 0.01

        -- 避免这个值变得太大
        if bluramount > 10 then
            bluramount = 0
        end

        glState:setUniformFloat("bluramount", bluramount)
    end)
    -- sp:scheduleUpdate()
end

return GaussBlurEffect


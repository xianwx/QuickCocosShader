-- DissolveEffect.lua
-- Author: xianwx
-- Date: 2018-08-20 17:35:39
-- 溶解特效demo
local test_sp = "wcard.png"
local noise_sp = "noisetexture.png"

local shader = {
    fs = require "app.shader.DissolveFS",
    vert = require "app.shader.NormalVS",
}

local DissolveEffect = class("DissolveEffect")

function DissolveEffect.getDescText()
    return "溶解特效\n请尝试点击一下图片"
end

function DissolveEffect:init(node)
    node:spTouchUseShader(test_sp, "dissolve")
end

function DissolveEffect:setUniform(glState, time)
    -- 创建噪音图片
    local noise = display.newSprite(noise_sp, 0, 0)

    -- 获取gl id
    local tex = noise:getTexture():getName()

    glState:setUniformFloat("time", time)
    glState:setUniformTexture("texture1", tex)
end

function DissolveEffect:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function DissolveEffect.getVert()
    return shader.vert
end

function DissolveEffect.needRefresh()
    return true
end

function DissolveEffect.getFS()
    return shader.fs
end

function DissolveEffect:resetTime(time)
    return time + 0.008
end

return DissolveEffect

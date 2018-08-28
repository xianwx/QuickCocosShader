-- TransferEffect.lua
-- Author: xianwx
-- Date: 2018-08-21 16:36:03
-- 两张图片转换效果
local test_sp = "startbg.jpg"
local other_sp = "game_bg.jpg"
local shader = {
    fs = require "app.shader.TransferFS",
    vert = require "app.shader.NormalVS",
}

local TransferEffect = class("TransferEffect")

function TransferEffect.getDescText()
    return "图片变换特效\n请尝试点击一下图片"
end

function TransferEffect:init(node)
    display.newSprite(other_sp, display.cx, display.cy):addTo(node, -1)
    node:spTouchUseShader(test_sp, "transfer")
end

function TransferEffect:setUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function TransferEffect:resetUniform(glState, time)
    glState:setUniformFloat("time", time)
end

function TransferEffect:resetTime(time)
    return time + 0.02
end

function TransferEffect.needRefresh()
    return true
end

function TransferEffect.getVert()
    return shader.vert
end

function TransferEffect.getFS()
    return shader.fs
end

return TransferEffect

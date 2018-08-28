-- SearchLightEffect.lua
-- Author: xianwx
-- Date: 2018-08-21 17:13:51
-- 战争迷雾效果
local test_sp = "monster.jpg"

local shader = {
    fs = require "app.shader.SearchLightFS",
    vert = require "app.shader.NormalVS",
}

local SearchLightEffect = class("SearchLightEffect")

function SearchLightEffect.getDescText()
    return "战争迷雾效果\n请随意点击或移动"
end

function SearchLightEffect:init(node)
    local sp = node:spUseShader(test_sp, "search_light")

    local function resetUniform(touch)
        if not self._glState then
            return
        end
        local touchPos = touch:getLocation()
        local nodeP = cc.p(sp:convertToNodeSpace(cc.p(touchPos)))
        self._glState:setUniformVec2("mouse", nodeP)
    end

    addTouchEvent(node, { endCallback = function (touch)
        resetUniform(touch)
    end, moveCallback = function (touch)
        resetUniform(touch)
    end, beginCallback = function (touch)
        resetUniform(touch)
    end, moveFix = true })
end

function SearchLightEffect:setUniform(glState, _, sp)
    local size = sp:getContentSize()
    self._glState = glState

    -- set uniform value
    glState:setUniformVec2("resolution", { x = size.width, y = size.height })
    glState:setUniformVec2("mouse", { x = 150, y = 40 }) -- 随便写个初始位置
end

function SearchLightEffect.needRefresh()
    return false
end

function SearchLightEffect.getVert()
    return shader.vert
end

function SearchLightEffect.getFS()
    return shader.fs
end

return SearchLightEffect

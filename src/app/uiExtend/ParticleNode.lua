--
-- Author: xianwx
-- Date: 2016-08-23 15:20:49
--
local ParticleNode = class("ParticleNode", function ()
    return display.newNode()
end)

-- 如果设置parent，就直接取parent的大小
function ParticleNode:ctor(params)
    params = params or {}
    params.type = params.type or "circle"

    if params.type == "circle" then
        local particle1 = cc.ParticleSystemQuad:create("UISpine/lizi.plist"):addTo(self)
        local particle2 = cc.ParticleSystemQuad:create("UISpine/lizi.plist"):addTo(self)
        if params.radius == nil and params.parent then
            params.radius = params.parent:getContentSize().width / 2
        end
        params.radius = params.radius or 0
        self:setContentSize(params.radius * 2, params.radius * 2)
        particle1:setPosition(params.radius, params.radius * 2)
        particle2:setPosition(params.radius, 0)
        self:setAnchorPoint(0.5, 0.5)
        self:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 150)))
    else
        if params.width == nil and params.height == nil and params.parent then
            params.width = params.parent:getContentSize().width
            params.height = params.parent:getContentSize().height
        end

        params.width = params.width or 0
        params.height = params.height or 0

        -- todo
    end
end

return ParticleNode
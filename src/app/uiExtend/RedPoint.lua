-- RedPoint.lua
-- Author: xianwx
-- Date: 2016-08-14 15:24:10
-- 红点
local RedPoint = class("RedPoint", function ()
    return display.newNode()
end)

function RedPoint:ctor(func, spineName)
    assert(type(func) == "function", "must pass check show point function!")
    spineName = spineName or "hongdianxin"
    display.newCircle(8, {
        fillColor = cc.c4f(1, 0, 0, 1),
        borderColor = cc.c4f(0, 0, 0, 1),
        borderWidth = 1}):addTo(self)
    self:setVisible(false)
    self:showSpine(spineName)
    self:initStateMachine()
    func(self)
end

function RedPoint:initStateMachine()
    self.fsm = {}
    cc(self.fsm)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()

    self.fsmState = {
        initial = "hide",
        events = {
            { name = "show", from = "hide", to = "show" },
            { name = "hide", from = "show", to = "hide" },
        },
        callbacks = {
            onentershow = function ()
                self:setVisible(true)
            end,
            onenterhide = function ()
                self:setVisible(false)
            end
        }
    }
    self.fsm:setupState(self.fsmState)
end

function RedPoint:showSpine(name)
    local skeleteonNode = sp.SkeletonAnimation:create("redspine/" .. name .. ".json","redspine/" .. name .. ".atlas", 1)  
    skeleteonNode:setAnimation(0, "animation", true)
    skeleteonNode:setPosition(0, 0)
    skeleteonNode:setAnchorPoint(0.5, 0.5)
    self:addChild(skeleteonNode, 1)
end

function RedPoint:toState(name)
    if name == self.fsm:getState() then
        return
    end

    self.fsm:doEvent(name)
end

function RedPoint:forceHide()
    if "hide" == self.fsm:getState() then
        return
    end

    self.fsm:doEvent("hide")
end

function RedPoint:setTabIndex(index)
    self.index = index
end

function RedPoint:getTabIndex()
    return self.index
end

return RedPoint
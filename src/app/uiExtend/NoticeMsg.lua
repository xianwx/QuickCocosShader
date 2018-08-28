-- NoticeMsg.lua
-- Author: xianwx
-- Date: 2016-05-09 14:30:09
-- 提示消息

local NoticeMsg = class("NoticeMsg", function()
    return display.newLayer()
end)

function NoticeMsg:ctor(message, duration, stayDuration, delayT)

    local str = createSimpleLabel({ text = message, size = 20, align = cc.ui.TEXT_ALIGN_CENTER, valign = cc.ui.TEXT_VALIGN_TOP, dimensions = cc.size(400, 200), x = display.cx, y = 500 - 30, outLine = true }):addTo(self):setAnchorPoint(0.5, 0.5):setVisible(false)

    transition.execute(str, cc.CallFunc:create(function ()
        str:setVisible(true)
    end), {onComplete = function ()
        transition.execute(str, cc.MoveTo:create(duration, cc.p(display.cx, 500)), {easing = "backInIn", onComplete = function ()
                transition.execute(str, cc.MoveTo:create(duration, cc.p(display.cx, 500 + 30)), {easing = "backInIn", delay = stayDuration + 0.2, onComplete = function ()
                self:removeSelf()
            end})
        end})
    end, delay = delayT})
end


return NoticeMsg

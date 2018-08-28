--
-- Author: xianwx
-- Date: 2018-08-25 10:09:23
--
local fontSize = 40
local NumberLayer = class("NumberLayer", function ()
    return display.newLayer()
end)

function NumberLayer:ctor()
    math.randomseed(os.time())

    addTouchEvent(self, { endCallback = function ()
        self:scheduleUpdate()
    end, moveFix = true })

    local count = 0
    local showNum = 0
    self._total = 0
    local enable = true
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function ()
        if not enable then
            return
        end

        self:removeAllChildren()
        count = count + 1
        if count == 4 then
            -- 创建一个真正的数字
            self:_createImportantNum()
            count = 0
            showNum = showNum + 1
        end

        -- 创建一堆干扰数字
        self:_createInterferenceNum()

        if showNum == 15 then
            self:unscheduleUpdate()
            self:_showResult()
            showNum = 0
            self._total = 0
            count = 0
            enable = true
        end
    end)
end

function NumberLayer:_showResult()
    self:removeAllChildren()
    local child = createSimpleLabel({ text = "结果是：" .. self._total })
    self:addChild(child)
    child:setAnchorPoint(0.5, 0.5)
    child:setPosition(display.cx, display.cy)
end

function NumberLayer:_createImportantNum()
    local num = math.random(10000, 99999)
    print("num: ", num)
    self._total = self._total + num
    local numNode = createSimpleLabel({ text = num, color = cc.c3b(255, 255, 255), size = fontSize + 10 })
    local pos = cc.p(math.random(display.cx - 100, display.cx + 100), math.random(display.cy - 100, display.cy + 100))
    numNode:setAnchorPoint(0.5, 0.5)
    self:addChild(numNode, 99)
    numNode:setPosition(pos)
end

function NumberLayer:_createInterferenceNum()
    -- 创建40-50个干扰数字
    local count = math.random(40, 50)
    for _=1,count do
        local num = createSimpleLabel({ text = math.random(1, 100000), color = cc.c3b(0, 150, 0), size = fontSize })
        local pos = cc.p(math.random(0, display.width), math.random(0, display.height))
        num:setOpacity(255 * 0.85)
        num:setAnchorPoint(0.5, 0.5)
        self:addChild(num)
        num:setPosition(pos)
    end
end

return NumberLayer

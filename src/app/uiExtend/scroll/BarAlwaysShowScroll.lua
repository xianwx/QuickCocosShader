-- BarAlwaysShowScroll.lua
-- Author: xianwx
-- Date: 2016-04-21 12:05:18
-- 需要一直显示滚动条进度的滚动控件

local BarAlwaysShowScroll = class("BarAlwaysShowScroll", function ()
    return display.newLayer()
end)

-- @params barDisX          bar的x坐标
-- @params barDisUpY        bar的上限y坐标
-- @params barDisDownY      bar的下限y坐标
-- @params rect             可视区域
-- @params scrollDisX       滚动控件的x位置
-- @params scrollDisY       滚动控件的y位置
-- @params lineNumLimit     每行显示的控件数量
-- @params itemNum          要创建的元素的总数
function BarAlwaysShowScroll:ctor(params)
    
    if params.barDisX and params.barDisUpY then
        -- 滚动圆球
        self.scrollBar = display.newSprite("UI/GeneralSelected/scrollBarV.png", params.barDisX, params.barDisUpY):addTo(self)

        addTouchEvent(self.scrollBar, {moveCallback = function (touch)
            self:moveBar(touch)
        end})
    end
    
    -- 可视区域
    local clippingRect = display.newClippingRegionNode(params.rect):addTo(self)
    self.showRect = params.rect

    -- 拖动控件
    self.scrollNode = display.newNode():addTo(clippingRect)
    self.scrollNode:setAnchorPoint(0, 0)

    addTouchEvent(self.scrollNode, {moveCallback = function (touch)
        if self:checkOnShowRect(touch) then
            self:onMovedEvent(touch)
        end
    end, endCallback = function ()
        self.onMove = false
    end, moveFix = true, notSwallowTouches = true})

    -- 初始化参数
    self:initParams(params)
    self:setNodeEventEnabled(true)
    self:initSelf()

    -- 设置界面元素界限等
    self:setLimit(params)

    -- 用于处理传入数据
    self:dealData(params)

    -- 计算一下初始位置
    self:disPosRemark()
    self.onMove = false
    -- local black = cc.LayerColor:create(cc.c4b(100, 100, 100, 200)):addTo(self.scrollNode)
    -- black:setContentSize(self.scrollNode:getContentSize())
    -- black:setAnchorPoint(cc.p(0, 0))
    -- black:setPosition(0, 0)
    -- self:addItemToScroll()
end

function BarAlwaysShowScroll:initParams(params)
    self.barDisUpY = params.barDisUpY
    self.barDisDownY = params.barDisDownY
    self.lineNumLimit = params.lineNumLimit
    self.itemNum = params.itemNum
    self.count = 0
    self.itemHDis = 0
    self.itemVDis = 0
    self.lineNum = 1
    self.curLine = 1
end

function BarAlwaysShowScroll:dealData(params)
    return params
    -- body
end

function BarAlwaysShowScroll:initSelf()
    -- todo 设置itemHDis, itemVDis的值
end

-- 具体的添加元素到界面的方法
function BarAlwaysShowScroll:addItemToScroll()
end

function BarAlwaysShowScroll:updateMyInfo()
end

function BarAlwaysShowScroll:newItem(...)
    return ...
end

function BarAlwaysShowScroll:disPosRemark()
    self.disX = 0
    self.disY = self.scrollNode:getContentSize().height - self.itemVDis
end

-- 设置界面元素界限
function BarAlwaysShowScroll:setLimit(params)
    self.scrollNode:setContentSize(params.rect.width, self.itemVDis * math.ceil(self.itemNum / self.lineNumLimit))
    self.scrollNode:setPosition(params.rect.x, (params.rect.y + params.rect.height) - self.scrollNode:getContentSize().height - (display.height - 720) / 2)
    self.upLimit = (params.rect.y + params.rect.height) - self.scrollNode:getContentSize().height
    self.downLimit = params.rect.y
end

-- 元素位置设置
function BarAlwaysShowScroll:countLinePostion()
    if self.lineNum % self.lineNumLimit == 0 then
        self.disX = 0
        self.disY = self.disY - self.itemVDis
        self.lineNum = 1
        self.curLine = self.curLine + 1
    else
        self.disX = self.disX + self.itemHDis
        self.lineNum = self.lineNum + 1
    end
end

function BarAlwaysShowScroll:onClicked(touch)
    return touch
end

-- 重新计算滚动条的位置
function BarAlwaysShowScroll:reloadBarVLocation()

    if not self.scrollBar then
        return
    end

    self.scrollBar:setPosition(self.scrollBar:getPositionX(), self.barDisUpY + (self.scrollNode:getPositionY() - self.upLimit) / (self.upLimit - self.downLimit) * (self.barDisUpY - self.barDisDownY))
end

-- 重新计算滚动控件的位置
function BarAlwaysShowScroll:reloadScrollNodeLocation()
    if not self.scrollBar then
        return
    end

    self.scrollNode:setPosition(self.scrollNode:getPositionX(), self.upLimit + (self.scrollBar:getPositionY() - self.barDisUpY) / (self.barDisUpY - self.barDisDownY) * (self.upLimit - self.downLimit))
end

function BarAlwaysShowScroll:onMovedEvent(touch)
    -- self.scrollNode:setPosition(self.scrollNode:getPositionX(), self.scrollNode:getPositionY() + touch:getDelta().y)
    self.onMove = true

    if self.scrollNode:getContentSize().height <= self.showRect.height then
        return
    end

    if self.scrollNode:getPositionY() + touch:getDelta().y < self.upLimit then
        self.scrollNode:setPosition(self.scrollNode:getPositionX(), self.upLimit)
    elseif self.scrollNode:getPositionY() + touch:getDelta().y > self.downLimit then
        self.scrollNode:setPosition(self.scrollNode:getPositionX(), self.downLimit)
    else
        self.scrollNode:setPosition(self.scrollNode:getPositionX(), self.scrollNode:getPositionY() + touch:getDelta().y)
    end

    if touch:getDelta().y > 0 then
        self:moveDownHandler(touch)
    else
        self:moveUpHandler(touch)
    end

    self:reloadBarVLocation()
end

function BarAlwaysShowScroll:moveUpHandler(touch)
    -- body
    -- print("move up")
    return touch
end

function BarAlwaysShowScroll:moveDownHandler(touch)
    return touch
    -- print("move down")
end

function BarAlwaysShowScroll:moveBar(touch)

    -- if self.scrollNode:getContentSize().height <= self.showRect.height then
    --     return
    -- end
    
    -- if self.scrollBar:getPositionY() + touch:getDelta().y > self.barDisUpY then
    --     self.scrollBar:setPosition(self.scrollBar:getPositionX(), self.barDisUpY)
    -- elseif self.scrollBar:getPositionY() + touch:getDelta().y < self.barDisDownY then
    --     self.scrollBar:setPosition(self.scrollBar:getPositionX(), self.barDisDownY)
    -- else
    --     self.scrollBar:setPosition(self.scrollBar:getPositionX(), self.scrollBar:getPositionY() + touch:getDelta().y)
    -- end

    -- self:reloadScrollNodeLocation()
    return touch
end

function BarAlwaysShowScroll:clickPreconditions(cascadeBound, touch)
    return self:checkOnShowRect(touch) and cc.rectContainsPoint(cascadeBound, cc.p(touch:getLocation().x, touch:getLocation().y))
end

function BarAlwaysShowScroll:checkOnShowRect(touch)

    local x, y
    if tolua.type(touch) == "table" then
        x = touch.x
        y = touch.y
    else
        x = touch:getLocation().x
        y = touch:getLocation().y
    end
    return cc.rectContainsPoint(self.showRect, cc.p(x, y))
end

-- 重新排版
function BarAlwaysShowScroll:reload()
end

-- 移动到最下层
function BarAlwaysShowScroll:gotoDown()

    if self.scrollBar then
        self.scrollBar:setPosition(self.scrollBar:getPositionX(), self.barDisDownY)
    end
    
    self.scrollNode:setPosition(self.scrollNode:getPositionX(), self.downLimit)
end

-- 移动到最上层
function BarAlwaysShowScroll:gotoTop()

    if self.scrollBar then
        self.scrollBar:setPosition(self.scrollBar:getPositionX(), self.barDisUpY)
    end
    
    self.scrollNode:setPosition(self.scrollNode:getPositionX(), self.upLimit)
end

function BarAlwaysShowScroll:moveEnd()
    self.onMove = false
end

return BarAlwaysShowScroll
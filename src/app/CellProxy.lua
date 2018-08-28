-- CellProxy.lua
-- Author: xianwx
-- Date: 2016-08-28 10:44:28
-- 元素代理类
local CellProxy = class("CellProxy", function ()
    return display.newNode()
end)

function CellProxy:ctor(itemClass, index)
    cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self._item = itemClass.new(index):addTo(self)
    self._item:setAnchorPoint(0, 0)
    self:addEventListener("update", handler(self._item, self._item._update))
    self._index = index
    self:setAnchorPoint(0.5, 0.5)
    self:setContentSize(self._item:getContentSize())
end

function CellProxy:checkSelf(point, longGap, maxScale, diffGap)
    -- 因为锚点是0, 0，所以要取中间点
    local halfWidth = self:getContentSize().width / 2
    local position = self:convertToWorldSpace(cc.p(halfWidth, 0))
    
    -- 分段函数，当距离超过一段距离的时候，缩放的值为1
    if math.abs(position.x - point) >= longGap then
        self:setScale(1)
        self._item:setPositionX(0)
        self:setContentSize(self._item:getContentSize())
    else
        -- 当x距离设定的点的距离绝对值小于longGap的时候，
        -- s的值为 - coe * x² + maxScale, x为距离，当x等于0的时候最大，等于longGap的时候为1
        local disX = position.x - point
        local coeS = -((1 - maxScale) / (longGap * longGap))
        local s = -(disX * disX) * coeS + maxScale

        -- 当x等于0的时候最大，为diff的一半，等于longGap的时候最小，为0
        local coeX = diffGap / ((longGap * longGap) * 2)
        local itemDisX = -coeX * (disX * disX) + diffGap / 2
        self._item:setPositionX(itemDisX)
        self:setContentSize(self._item:getContentSize().width + itemDisX * 2, self:getContentSize().height)
        self:setScale(s)
    end
end

function CellProxy:setInfo(info)
    self:dispatchEvent({ name = "update", arg = info })
end

-- setter, getter index
function CellProxy:setIndex(index)
    self._index = index
end

function CellProxy:getIndex()
    return self._index
end

return CellProxy
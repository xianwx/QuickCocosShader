-- UnilimitedScroll.lua
-- Author: xianwx
-- Date: 2016-08-28 10:43:36
-- 无限滚动条
local LEFT = 1
local RIGHT = 2
local CellProxy = import(".CellProxy")
local UnilimitedScroll = class("UnilimitedScroll", function ()
    return display.newClippingRegionNode()
end)

function UnilimitedScroll:ctor(params)
    params = params or {}

    -- 必须设置滚动条的长宽以及元素的列表
    assert(params.width and params.height and params.itemList and params.class, "size, itemList, class must not nil.")

    self._gap = params.gap or 5
    self._itemNum = #params.itemList
    self._size = { width = params.width, height = params.height }
    self._itemList = params.itemList
    self._itemClass = params.class

    self:_createViewport()
    self:_initCells()

    self._showEffect = params.showEffect
    if self._showEffect then
        assert(params.hugePointX and params.longGap, "hugePointX, longGap must be set if you want show effect.")
        self._maxScale = params.scale or 1.2
        self._hugePointX = params.hugePointX
        self._longGap = params.longGap
    end

    addTouchEvent(self, {
        moveCallback = function (touch)
            self:_onScroll(touch)
        end,
        moveEndCallback = function (touch)
            self:_onMoveEnd(touch)
        end,
        moveFix = true,
        notSwallowTouches = params.notSwallowTouches,
    })

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._update))
    self:scheduleUpdate()
end

function UnilimitedScroll:_createViewport()
    self:setClippingRegion(cc.rect(0, 0, self._size.width, self._size.height))
    self:setContentSize(self._size)
end

function UnilimitedScroll:_checkNeedScroll()
    if not self._cells then
        return false
    end

    local count = 0
    for _, cell in ipairs(self._cells) do
        count = count + cell:getContentSize().width + self._gap
    end
    return count > self._size.width
end

local function scrollDirection(touch)
    if touch:getDelta().x < 0 then
        return LEFT
    else
        return RIGHT
    end
end

function UnilimitedScroll:_leftFrontHide()
    local node = self._cells[1]
    if node and node:getPositionX() + node:getContentSize().width / 2 + self._gap <= 0 then
        return true
    end
    return false
end

function UnilimitedScroll:_rightEndHide()
    local node = self._cells[self._cellsNum]
    if node and node:getPositionX() - node:getContentSize().width / 2 > self._size.width then
        return true
    end
    return false
end

function UnilimitedScroll:_leftToRight(toIndex)
    local node = self._cells[1]
    local last = self._cells[self._cellsNum]
    local toX = last:getPositionX() + last:getContentSize().width + self._gap
    node:setPositionX(toX)
    node:setIndex(toIndex)
    node:setInfo(self._itemList[toIndex])
    table.remove(self._cells, 1)
    table.insert(self._cells, node)
end

function UnilimitedScroll:_rightToLeft(toIndex)
    local node = self._cells[self._cellsNum]
    local toX = self._cells[1]:getPositionX() - self._gap - node:getContentSize().width
    node:setPositionX(toX)
    node:setIndex(toIndex)
    node:setInfo(self._itemList[toIndex])
    table.remove(self._cells)
    table.insert(self._cells, 1, node)
end

function UnilimitedScroll:_getToIndex(dire)
    local index
    if dire == LEFT then
        local last = self._cells[self._cellsNum]:getIndex()
        index = last + 1
    else
        local first = self._cells[1]:getIndex()
        index = first - 1
    end

    if index <= 0 then
        index = self._itemNum
    elseif index > self._itemNum then
        index = 1
    end
    return index
end

function UnilimitedScroll:_update()
    for i = 2, self._cellsNum do
        local cell = self._cells[i]
        local cellLast = self._cells[i - 1]
        local x = cellLast:getPositionX() + (cellLast:getContentSize().width * cellLast:getScale() / 2) + self._gap + (cell:getContentSize().width * cell:getScale() / 2)
        cell:setPositionX(x)
    end
end

function UnilimitedScroll:_getDeltaX(dire, touch)
    return touch:getDelta().x
    -- if self:_checkNeedScroll() then
    --     return touch:getDelta().x
    -- end

    -- local node
    -- if dire == LEFT then
    --     node = self._cells[self._cellsNum]
    --     if self._showEffect then
    --         -- 最后一个如果已经在特效播放位置，则不让移动了
    --         if node:convertToWorldSpace(cc.p(node:getContentSize().width / 2, 0)).x <= self._hugePointX then
    --             return node:convertToWorldSpace(cc.p(node:getContentSize().width / 2, 0)).x - self._hugePointX
    --         else
    --             return touch:getDelta().x
    --         end
    --     else
    --         -- 最后一个如果已经到最左边，则不让移动了
    --         if node:getPositionX() - node:getContentSize().width * node:getScale() / 2 <= 0 then
    --             return 0
    --         else
    --             return touch:getDelta().x
    --         end
    --     end
    -- else
    --     node = self._cells[1]
    --     if self._showEffect then
    --         -- 第一个如果已经在特效位置，则不让移动了
    --         if node:convertToWorldSpace(cc.p(node:getContentSize().width / 2, 0)).x >= self._hugePointX then
    --             return self._hugePointX - node:convertToWorldSpace(cc.p(node:getContentSize().width / 2, 0)).x
    --         else
    --             return touch:getDelta().x
    --         end
    --     else
    --         -- 最后一个如果已经到最右边，则不让移动了
    --         if node:getPositionX() + node:getContentSize().width * node:getScale() / 2 >= self._size.width then
    --             return 0
    --         else
    --             return touch:getDelta().x
    --         end
    --     end
    -- end
end

function UnilimitedScroll:_autoSelected(index)
    
end

-- 计算位置
function UnilimitedScroll:_onScroll(touch)
    if not self._cells then
        return
    end

    local direction = scrollDirection(touch)

    for _, cell in ipairs(self._cells) do
        local x = cell:getPositionX()
        local deltaX = self:_getDeltaX(direction, touch)
        cell:setPositionX(x + deltaX)
        if self._showEffect then
            cell:checkSelf(self._hugePointX, self._longGap * 2.5, self._maxScale, self._longGap - self._gap)
        end
    end

    if direction == LEFT then
        if self:_leftFrontHide() then
            self:_leftToRight(self:_getToIndex(direction))
        end
    else
        if self:_rightEndHide() then
            self:_rightToLeft(self:_getToIndex(direction))
        end
    end
end

-- 移动结束，自动计算
function UnilimitedScroll:_onMoveEnd(touch)
    return touch
end

-- 计算要创建的滚动元素数量
function UnilimitedScroll:_countDisplayCellNum()
    if (not self._itemList) or (not self._itemClass) then
        return
    end

    local num
    local preload = self._itemClass.new()
    dump(preload)
    local unitWidth = preload:getContentSize().width
    assert(unitWidth > 0, "must set A positive number of item's width!!!")

    num = math.ceil(self._size.width / (unitWidth + self._gap))
    -- 多创建一个
    num = num + 1
    return num > self._itemNum and self._itemNum or num
end

-- 设置元素
function UnilimitedScroll:_initCells()
    -- 不设置这个不显示任何元素
    if not self._itemList then
        return
    end

    -- 计算要创建并渲染多少个元素
    local num = self:_countDisplayCellNum()
    self._cellsNum = num
    self._cells = {}
    local disX = 0
    -- 创建元素
    for i = 1, num do
        local cell = CellProxy.new(self._itemClass, i)
        cell:setPosition(cell:getContentSize().width / 2 + disX, cell:getContentSize().height / 2 + (self._size.height - cell:getContentSize().height) / 2)
        -- cell:pos(disX, 0)
        self:addChild(cell)
        disX = disX + cell:getContentSize().width + self._gap
        table.insert(self._cells, cell)
    end
end

return UnilimitedScroll

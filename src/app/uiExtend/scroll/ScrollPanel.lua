-- 
-- Author : Chen Qingqing 
-- Date : 2016-06-15 11:38:09
-- 根据添加的 cell 的 content size 进行布局，可以自定义布局类

local CellProxy = require "app.uiExtend.layout.CellProxy"
local Layouts = {
    horz = require "app.uiExtend.layout.HorzLayout",
    vert = require "app.uiExtend.layout.VertLayout",
    grid = require "app.uiExtend.layout.GridLayout",
}

local ScrollPanel = class("ScrollPanel", function ()
    return display.newClippingRegionNode()
end)

-- @param params
--  size : the viewport size
--  scroll_vert : true(default) or false, enable or disable vert scroll
--  scroll_horz : true(default) or false, enable or disable horz scroll
--  layout : "vert"(default), "horz", "grid" (you can add it by yourself, such as flow)
--           other layout param ...
--  gap : the gap(default is 2) between cell, affecting layout
--  moveCallback : touch callback
--  endCallback : touch callback
function ScrollPanel:ctor(params)
    params = params or {}
    params.gap = params.gap or 2
    params.moveCallback = params.moveCallback or function () end
    params.moveEndCallback = params.moveEndCallback or function () end
    params.endCallback = params.endCallback or function () end
    self._params = params

    self._vertEnabled = params.scroll_vert == nil and true or params.scroll_vert
    self._horzEnabled = params.scroll_horz == nil and true or params.scroll_horz

    local resize = handler(self, self._resize)
    self._layout = Layouts[params.layout or "vert"].new(resize, params)
    self:_createViewport(params.size)
    addTouchEvent(self, { 
        moveCallback = function (touch)
            local delta = self:_onScroll(touch)
            params.moveCallback(touch, delta)
        end,
        moveEndCallback = function (touch)
            params.moveEndCallback(touch)
        end,
        endCallback = function (touch) 
            params.endCallback(touch) 
        end,
        moveFix = true,
        notSwallowTouches = params.notSwallowTouches,
    })

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._update))
    self:scheduleUpdate()
end

local function inRange(x, min, max)
    if min >= max then
        min, max = max, min
    end
    
    return min <= x and x <= max
end

function ScrollPanel:_update(delta)
    if not self._targetPos then
        return
    end

    local panel = self._panel
    local speed = self._speed

    local targetPos = self._targetPos
    local currPos = cc.p(panel:getPosition())

    local dir = cc.pSub(targetPos, currPos)
    dir = cc.pNormalize(dir)
    dir = cc.pMul(dir, speed * delta)

    local nextPos = cc.pAdd(currPos, dir)

    for _,axis in ipairs({ "x", "y" }) do
        if inRange(targetPos[axis], currPos[axis], nextPos[axis]) then
            nextPos[axis] = targetPos[axis]
        end
    end
    self._params.moveCallback(nil, cc.pSub(nextPos, currPos))

    panel:setPosition(nextPos.x, nextPos.y)
    if currPos.x == nextPos.x and currPos.y == nextPos.y then
        self._targetPos = nil
        self._speed = nil
        self._params.moveEndCallback()
    end    
end

function ScrollPanel:_createViewport(size)
    self:setClippingRegion(cc.rect(0, 0, size.width, size.height))
    self:setContentSize(size)

    local panel = display.newNode():addTo(self)
    panel:setAnchorPoint(0, 1)
    panel:setPosition(0, size.height)
    panel:setContentSize(size)

    self._viewport = size
    self._panel = panel
    self._cells = {}
end

function ScrollPanel:_addCellImpl(creator)
    local node = CellProxy.new(creator, self._panel)
    table.insert(self._cells, node)
end

function ScrollPanel:getCount()
    return #self._cells
end

function ScrollPanel:getPanel()
    return self._panel
end

-- public
-- 如果 Cell 自己想添加触摸事件，则需要设置参数： notSwallowTouches = true, moveFix = true
function ScrollPanel:addCell(nodeCreator)
    self:_addCellImpl(nodeCreator)
    self:_onScroll()
end

-- public
-- 一开始初始化最好使用 addCells 而不是 addCell，每增删一个 cell 都会引起重新布局
function ScrollPanel:addCells(nodeCreators)
    if #nodeCreators == 0 then
        return
    end

    for _,creator in ipairs(nodeCreators) do
        self:_addCellImpl(creator)
    end
    self:_onScroll()
end

-- public
function ScrollPanel:removeCell(cell)
    local index
    for i,v in ipairs(self._cells) do
        if v:isProxyFor(cell) then
            index = i
            break
        end
    end

    if not index then
        return 
    end

    table.remove(self._cells, index)
    cell:removeSelf()
    self:_onScroll()
end

-- public
-- 方便用于删除某个控件之后的所有控件
function ScrollPanel:removeCellsAfterIndex(index)
    if index >= #self._cells then
        return
    end

    local count = #self._cells
    for i = index + 1, count do
        self._cells[i]:removeSelf()
        self._cells[i] = nil
    end

    self:_onScroll()
end

-- public
function ScrollPanel:removeAllCells()
    if not next(self._cells) then
        return
    end

    for _,cell in pairs(self._cells) do
        cell:removeSelf()
    end

    self._cells = {}
    self:_onScroll()
end

-- public
function ScrollPanel:containsPoint(point)
    local pos = self:convertToNodeSpace(point)
    local rect = self:getClippingRegion()
    return cc.rectContainsPoint(rect, pos)
end

-- public, 可以用于恢复scroll位置
function ScrollPanel:getScrollDelta()
    return cc.p(self._panel:getPositionX(), 
        self._panel:getPositionY() - self._viewport.height)
end

-- public
function ScrollPanel:scroll(delta, speed)
    self:_onScrollImpl(delta, speed and math.abs(speed))
end

-- public
function ScrollPanel:getCellByIndex(index)
    return self._cells[index] and self._cells[index]:getTarget()
end

function ScrollPanel:scrollToLT()
    self:_onScrollImpl(cc.p(math.huge, -math.huge))
    self:_onScrollImpl(cc.p(0, 0))
end

function ScrollPanel:scrollToLB()
    self:_onScrollImpl(cc.p(math.huge, math.huge))
    self:_onScrollImpl(cc.p(0, 0))
end

function ScrollPanel:scrollToRT()
    self:_onScrollImpl(cc.p(-math.huge, -math.huge))
    self:_onScrollImpl(cc.p(0, 0))
end

function ScrollPanel:scrollToRB()
    self:_onScrollImpl(cc.p(-math.huge, math.huge))
    self:_onScrollImpl(cc.p(0, 0))
end

local function getVisibleRect(self, delta)
    delta = delta or cc.p(0, 0)
    local panel = self._panel
    local viewport = self._viewport
    local pos = cc.pAdd(cc.p(panel:getPosition()), delta)
    local rect = cc.rect(
        -pos.x, pos.y - viewport.height, 
        viewport.width, viewport.height)

    return pos, rect
end

-- @return an indices table
function ScrollPanel:getVisibleCells()
    assert(self._layout.getVisibleCells, 
        "This layout has not supported it yet, please implement it yourself.")
    local _, rect = getVisibleRect(self)
    return self._layout:getVisibleCells(self._cells, rect)
end

function ScrollPanel:_resize(width, height)
    local panelSize = self._panel:getContentSize()
    panelSize.width = math.max(width, self._viewport.width)
    panelSize.height = math.max(height, self._viewport.height)
    self._panel:setContentSize(panelSize)

    return panelSize
end

function ScrollPanel:_onScroll(touch)
    local delta = touch and touch:getDelta() or cc.p(0, 0)
    return self:_onScrollImpl(delta)
end

function ScrollPanel:_onScrollImpl(delta, speed)
    delta.x = self._horzEnabled and delta.x or 0
    delta.y = self._vertEnabled and delta.y or 0

    local panel = self._panel
    local originPos = cc.p(panel:getPosition())

    local viewport = self._viewport
    local pos, rect = getVisibleRect(self, delta)
    self._layout:relayout(self._cells, rect)

    local size = panel:getContentSize()
    local x = cc.clampf(pos.x, viewport.width - size.width, 0)
    local y = cc.clampf(pos.y, viewport.height, size.height)

    if speed and not (x == originPos.x and y == originPos.y) then
        self._speed = speed
        self._targetPos = cc.p(x, y)
    else
        self._targetPos = nil
        self._speed = nil
        panel:setPosition(x, y)
    end

    return cc.p(x - originPos.x, y - originPos.y)
end

return ScrollPanel

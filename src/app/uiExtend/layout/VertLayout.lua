-- 
-- Author : Chen Qingqing 
-- Date : 2016-07-30 19:58:08
-- 纵向布局

local VertLayout = class("VertLayout")

function VertLayout:ctor(onResize, params)
	self._onResize = onResize
	self._gap = params.gap
end

function VertLayout:relayout(nodes, viewRect)
	local width = 0
    local height = 0
    for _,node in ipairs(nodes) do
        if height > cc.rectGetMaxY(viewRect) then
            break
        end

        node:load()
        width, height = self:_accumulateSize(width, height, node)
    end

    local panelSize = self._onResize(width, height)
    height = 0

    for _,node in ipairs(nodes) do
        _, height = self:_accumulateSize(0, height, node)
        node:setPosition(0, panelSize.height - height)
    end
end

function VertLayout:_accumulateSize(width, height, node)
    local size = node:getContentSize()
    height = height + size.height + self._gap
    width = math.max(width, size.width)
    
    return width, height 
end

return VertLayout
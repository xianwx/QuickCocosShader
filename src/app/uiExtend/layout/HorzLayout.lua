-- 
-- Author : Chen Qingqing 
-- Date : 2016-07-30 19:58:04
-- 横向布局

local HorzLayout = class("HorzLayout")

function HorzLayout:ctor(onResize, params)
	self._onResize = onResize
	self._gap = params.gap
end

function HorzLayout:relayout(nodes, viewRect)
	local width = 0
    local height = 0
    for _,node in ipairs(nodes) do
        if width > cc.rectGetMaxX(viewRect) then
            break
        end

        node:load()
        node:setPosition(width, 0)
        width, height = self:_accumulateSize(width, height, node)
    end

    self._onResize(width, height)
end

function HorzLayout:_accumulateSize(width, height, node)
    local size = node:getContentSize()
    width = width + size.width + self._gap
    height = math.max(height, size.height)

    return width, height
end

return HorzLayout
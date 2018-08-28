-- 
-- Author : Chen Qingqing 
-- Date : 2016-08-06 22:16:30
-- 网格布局，每个网格的大小是一样的，为达到最优，不能动态插入，否则位置会重叠

local GridLayout = class("GridLayout")

function GridLayout:ctor(onResize, params)
	self._onResize = onResize
	self._vgap = params.gridVgap or params.gap
	self._hgap = params.gridHgap or params.gap
	self._gridSize = params.gridSize or cc.size(100, 100)
	self._col = params.gridCol or 2

	self._gridSize.width = self._gridSize.width + self._hgap
	self._gridSize.height = self._gridSize.height + self._vgap
end

local function getBoundary(viewRect, size, col, row)
	local minGridX = cc.clampf(math.ceil(cc.rectGetMinX(viewRect) / size.width), 1, col)
	local maxGridX = cc.clampf(math.ceil(cc.rectGetMaxX(viewRect) / size.width), 1, col)
	local minGridY = cc.clampf(math.ceil(cc.rectGetMinY(viewRect) / size.height), 1, row)
	local maxGridY = cc.clampf(math.ceil(cc.rectGetMaxY(viewRect) / size.height), 1, row)

	return minGridX, maxGridX, minGridY, maxGridY
end

function GridLayout:relayout(nodes, viewRect)
	local size = self._gridSize
	local col = self._col
	local row = math.ceil(#nodes / col)

	local panelSize = self._onResize(
		col * size.width - self._hgap, 
		row * size.height - self._vgap)

	local minGridX, maxGridX, minGridY, maxGridY = getBoundary(viewRect, size, col, row)

	for i=minGridX,maxGridX do
		for j=minGridY, maxGridY do
			local index = (j - 1) * col + i
			local node = nodes[index]
			if node and node:load()then
				node:setPosition(
					(i - 1) * size.width, 
					panelSize.height - j * size.height + self._vgap)
			end
		end
	end
end

function GridLayout:getVisibleCells(nodes, viewRect)
	local size = self._gridSize
	local col = self._col
	local row = math.ceil(#nodes / col)

	local minGridX, maxGridX, minGridY, maxGridY = getBoundary(viewRect, size, col, row)

	local indices = {}
	for i=minGridX,maxGridX do
		for j=minGridY, maxGridY do
			table.insert(indices, (j - 1) * col + i)
		end
	end

	return indices
end

return GridLayout
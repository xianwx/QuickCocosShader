-- 
-- Author : Chen Qingqing 
-- Date : 2016-07-30 22:37:51
-- 代理类，延迟加载
local CellProxy = class("CellProxy")

function CellProxy:ctor(creator, parent)
	self._creator = creator
	self._parent = parent
end

function CellProxy:load()
	if self._target then
		return
	end

	local target = self._creator()
	assert(target, "Don't forget to return an node!!!")

	target:setAnchorPoint(0, 0)
	self._parent:addChild(target)
	self._target = target
	return true
end

function CellProxy:getContentSize()
	return self._target and self._target:getContentSize() or cc.size(0, 0)
end

function CellProxy:setPosition(x, y)
	if self._target then
		self._target:setPosition(x, y)
	end
end

function CellProxy:removeSelf()
	if self._target then
		self._target:removeSelf()
	end
end

function CellProxy:isProxyFor(target)
	return self._target == target
end

function CellProxy:getTarget()
	return self._target
end

return CellProxy

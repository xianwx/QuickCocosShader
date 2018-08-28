-- BattleInfoListScroll.lua
-- Author: xianwx
-- Date: 2016-06-14 19:14:47
-- 战报滚动条

local BarAlwaysShowScroll = import(".BarAlwaysShowScroll")
local BattleInfoListScroll = class("BattleInfoListScroll", BarAlwaysShowScroll)

function BattleInfoListScroll:initSelf()
    self.curPoint = 1
    self.itemHDis = 0
    self.itemVDis = 95
    self.lineNumLimit = 1
end

function BattleInfoListScroll:dealData(params)
    self.allReports = params.reports
end

function BattleInfoListScroll:onEnter()
    self:frameAdd()
end

function BattleInfoListScroll:frameAdd()

    if self.count < self.itemNum then
        self:performWithDelay(function ()
            self:addItemToScroll()
            self:frameAdd()
        end, 0.01)
    end
end

function BattleInfoListScroll:addItemToScroll()

    for i = self.curPoint, self.curPoint + 5 do
        if self.itemNum < i then
            break
        end

        self:newItem(self.allReports[i])
        
        self.curPoint = self.curPoint + 1
    end
end

function BattleInfoListScroll:newItem(info)

    local item = require("app.uiExtend.scroll.BattleInfoListCell").new(info):addTo(self.scrollNode)
    item:setPosition(self.disX, self.disY)
    item:addMovedListener(handler(self, self.onMovedEvent))
    item:addTouchEnableListener(handler(self, self.checkOnShowRect))
    self.count = self.count + 1
    item:setTag(self.count)
    self:countLinePostion()
    return item
end

return BattleInfoListScroll

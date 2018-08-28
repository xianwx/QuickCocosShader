-- MilitaryTabScroll.lua
-- Author: xianwx
-- Date: 2016-07-12 15:29:06
-- 军工分页滚动条

local BarAlwaysShowScroll = import(".BarAlwaysShowScroll")
local MilitaryTabScroll = class("MilitaryTabScroll", BarAlwaysShowScroll)

function MilitaryTabScroll:initSelf()
    self.curPoint = 1
    self.itemHDis = 563
    self.itemVDis = 188
    self.lineNumLimit = 2

    local technologyConf = getConfigByName("technology")
    self.itemNum = #technologyConf
    self.infoList = {}
    for id, _ in pairs(technologyConf) do
        table.insert(self.infoList, id)
    end
end

function MilitaryTabScroll:setLimit(params)
    self.scrollNode:setContentSize(params.rect.width, self.itemVDis * math.ceil(self.itemNum / self.lineNumLimit))
    self.scrollNode:setPosition(params.rect.x, (params.rect.y + params.rect.height) - self.scrollNode:getContentSize().height)
    self.upLimit = (params.rect.y + params.rect.height) - self.scrollNode:getContentSize().height
    self.downLimit = params.rect.y
end

function MilitaryTabScroll:onEnter()
    self:frameAdd()
end

function MilitaryTabScroll:frameAdd()

    if self.count < self.itemNum then
        self:performWithDelay(function ()
            self:addItemToScroll()
            self:frameAdd()
        end, 0.01)
    end
end

function MilitaryTabScroll:addItemToScroll()

    for i = self.curPoint, self.curPoint + 2 do
        if self.itemNum < i then
            break
        end

        self:newItem(self.infoList[i])
        
        self.curPoint = self.curPoint + 1
    end
end

function MilitaryTabScroll:newItem(id)

    local item = require("app.uiExtend.scroll.MilitaryTabCell").new(id):addTo(self.scrollNode)
    item:setPosition(self.disX, self.disY)
    -- item:addMovedListener(handler(self, self.onMovedEvent))
    -- item:addTouchEnableListener(handler(self, self.checkOnShowRect))
    self.count = self.count + 1
    item:setTag(self.count)
    self:countLinePostion()
    return item
end

return MilitaryTabScroll

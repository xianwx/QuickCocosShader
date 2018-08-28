-- EmailCellNode.lua
-- Author:zyt
-- 邮件元素

local EmailCellNode = class("EmailCellNode", function ()
	return display.newNode()
end)


function EmailCellNode:ctor(info)
	layerLoadControl:loadCsb(self, "emailcellLayer")
	self:setContentSize(768, 128)

	self.txtMail = layerLoadControl:getChildNodeByName(self, {"labelEmailFloor", "txtEmail"})
	self.txtMail:setString("【"..info.mailfrom.."】"..info.mailContent)

	self.iconUnread = layerLoadControl:getChildNodeByName(self, {"labelEmailFloor","iconUnread"})
	self.iconRead = layerLoadControl:getChildNodeByName(self, {"labelEmailFloor","iconRead"})

	self.txtDeleteTime = layerLoadControl:getChildNodeByName(self, {"labelEmailFloor","txtDeleteTime"})
	local delTimesInfo = string.format(getStringFormatById(60000087), info.delTimes)
	self.txtDeleteTime:setString(delTimesInfo)

	layerLoadControl:labelEnableOutLine(self, {"labelEmailFloor", "txtEmail"})
	layerLoadControl:labelEnableOutLine(self, {"labelEmailFloor","txtDeleteTime"})

	-- 邮件详情
	layerLoadControl:setButtonEvent(self, {"labelEmailFloor","btnInfo"}, function() self:btnInfo() end)

	self.items = info.items
	self.mailDetailPanel = info.mailDetailPanel
	self.mailId = info.mailId

	self.info = info

	if self.items ~= nil then 
		self:addItems(self.iconUnread)
	end

	self:readStatus()
end

function EmailCellNode:btnInfo()
	self.mailDetailPanel:setVisible(true)
	self:mailRead(self.mailId)
	self:showDetailInfomation()
end

-- 添加附件 
-- whichPanel:添加到那个界面
function EmailCellNode:addItems(positionIcon)
	local itemId, itemAmount
	for index = 1, #self.items, 2 do
		itemId = self.items[index]
		itemAmount = self.items[index + 1]

		local item = self:addItem(itemId, itemAmount, index, positionIcon)
		item:pos(item:getPositionX()-10, item:getPositionY()-15)
		positionIcon:addChild(item)
	end
end

function EmailCellNode:addItem(itemId, itemAmount, index, positionIcon)
	local itemBackground = display.newSprite("UI/EmailUI/emailitembg.png")
	local itemIcon = display.newSprite(getValueInConfig("prop", itemId, "icon")):setScale(0.7,0.7)
	
	itemIcon:pos(itemBackground:getContentSize().width/2, itemBackground:getContentSize().height/2)

	createSimpleLabel({text=itemAmount,size = 32, align = cc.ui.TEXT_ALIGN_CENTER, outLine=true})
	:setAnchorPoint(0.5, 0.5):pos(itemIcon:getContentSize().width/2, 10)
	:addTo(itemIcon)

	itemBackground:pos(positionIcon:getPositionX() + positionIcon:getContentSize().width 
	+ (index - 1) * itemBackground:getContentSize().width * 2/3, 
	itemIcon:getContentSize().height/2)

	itemBackground:addChild(itemIcon)

	return itemBackground
end

-- 设置邮件已读
function EmailCellNode:mailRead(id)
	local req=netDataControl:mails_read(id)
	netControl:sendData(req, self, self.mailReadCallback)
end

function EmailCellNode:mailReadCallback(event)
	netControl:removeEvent(event.name)
	gameData.readId = event.data.id
	gameData:updateMailRead(event.data.id)
end

-- 设置邮件是否已读状态
function EmailCellNode:readStatus()
	if self.info.isRead == true then
		layerLoadControl:getChildNodeByName(self, {"labelEmailFloor","iconRead"}):setVisible(true)
	end
end

-- 显示详细信息
function EmailCellNode:showDetailInfomation()
	local showDetail = self.info.showDetail
	showDetail.detailInfoTitle:setString(self.info.subject)
	showDetail.emailInfo:setString(self.info.mailContent)

	if self.items ~= nil then 
		for index = 1, #self.items, 2 do
			print(self.items[index])
		end
		self:addItems(showDetail.attachIcon)
	end

	if self.items ~= nil then
		showDetail.btnEmailReceiver:setVisible(true)
		showDetail.btnDetailDelete:setVisible(false)
	else
		showDetail.btnEmailReceiver:setVisible(false)
		showDetail.btnDetailDelete:setVisible(true)
	end
end

return EmailCellNode
--
-- Author: xuewenjie
-- Date: 2016-04-06 14:01:52
--
--地图:10880*5376 格子：75*75 145*71

local mainPath="battleMap/"
local ScaleMoveMap = class("ScaleMoveMap", function()
	
	-- local layer = display.newNode()
 --        layer:setContentSize(1280,720)
 --        layer:setTouchEnabled(true)

	-- local layer=display.newLayer()
	-- layer:setClippingEnabled(true)
	-- layer:setContentSize(cc.p(1280,720))
	return display.newLayer()
end)

--params.map
function ScaleMoveMap:ctor(params)
	local mapRes=mainPath..params.mapRes
	-- self.bg=ccexp.TMXTiledMap:create(mapRes)
	self.bg=cc.TMXTiledMap:create(mapRes)

	self.bg:setPosition(display.width/2,display.height/2)
	self.bg:setAnchorPoint(cc.p(0.5,0.5))
	self:add(self.bg)
	-- self.bg:setScale(0.15)
	self.bg:setScale(0.3)
	-- self.bg:setScale(0.4)
	-- self.bg:setScale(0.5)
	-- self.bg:setScale(1)

	self.layerCount=1
	if device.platform == "ios" then
		self:iosTouch(self.bg)
	else
		self:androidTouch(self.bg)
	end

	-- self:setInnerContainerSize(cc.p(1280,720))
	-- self:addLine()
end

function ScaleMoveMap:getMapScale()
	return self.bg:getScaleX()
end


function ScaleMoveMap:addLayerToBg(layer)
	self.layerCount=self.layerCount+1
	layer:addTo(self.bg,self.layerCount)
end

function ScaleMoveMap:addLine()
	for i=1,250 do
		for j=1,200 do
			local line=display.newSprite("line.png",i*50,j*50)
			line:setAnchorPoint(1,1)
			line:addTo(self.bg,9999)
		end
	end
end



function ScaleMoveMap:iosTouch(bg)
	local distance;
	local mscale = bg:getScale();
	local firsttouch = true;
	
 	local function onTouchBegin()
	    firsttouch = true; 
	    self:unscheduleUpdate();
	    return true;
	end

	local function onTouchMove(touch)
	    if(#touch == 1)then --single touch
	        --重置标志位 防止开始用户使用2个手指缩放 
	        --松开一个手指拖动 再用2个手指缩放 不会触发 onTouchBegin 的问题
	        firsttouch = true

	        local d = touch[1]:getDelta()
	        local scale = bg:getScale();
			local anchorPointX=bg:getAnchorPoint().x-d.x/(bg:getContentSize().width*scale)
			local anchorPointY=bg:getAnchorPoint().y-d.y/(bg:getContentSize().height*scale)
			if anchorPointX<=(display.width/2)/(bg:getContentSize().width*scale) then
				anchorPointX=(display.width/2)/(bg:getContentSize().width*scale)
			end
			if anchorPointY<=(display.height/2)/(bg:getContentSize().height*scale) then
				anchorPointY=(display.height/2)/(bg:getContentSize().height*scale)
			end

			if anchorPointX>=(1-(display.width/2)/(bg:getContentSize().width*scale)) then
				anchorPointX=(1-(display.width/2)/(bg:getContentSize().width*scale))
			end
			if anchorPointY>=(1-(display.height/2)/(bg:getContentSize().height*scale))  then
				anchorPointY=(1-(display.height/2)/(bg:getContentSize().height*scale))
			end
			
			bg:setAnchorPoint(anchorPointX,anchorPointY)



	    else --multi touch
	        -- lastMove = nil
	        
	        local p1 = touch[1]:getLocation();
	        local p2 = touch[2]:getLocation();
	        -- local pMid = cc.pMidpoint(p1,p2);

	        if(firsttouch)then
	            firsttouch = false
	            distance = cc.pGetDistance(p1,p2)
	            return 
	        end

	        local mdistance = cc.pGetDistance(p1,p2);
	        mscale = mdistance/distance * mscale;
	        distance = mdistance;

			if mscale<=1 and mscale>=1/4 then
				bg:setScale(mscale)
				local anchorPointX=bg:getAnchorPoint().x
				local anchorPointY=bg:getAnchorPoint().y
				if anchorPointX<=(display.width/2)/(bg:getContentSize().width*bg:getScale()) then
					anchorPointX=(display.width/2)/(bg:getContentSize().width*bg:getScale())
				end
				if anchorPointY<=(display.height/2)/(bg:getContentSize().height*bg:getScale()) then
					anchorPointY=(display.height/2)/(bg:getContentSize().height*bg:getScale())
				end

				if anchorPointX>=(1-(display.width/2)/(bg:getContentSize().width*bg:getScale())) then
					anchorPointX=(1-(display.width/2)/(bg:getContentSize().width*bg:getScale()))
				end
				if anchorPointY>=(1-(display.height/2)/(bg:getContentSize().height*bg:getScale()))  then
					anchorPointY=(1-(display.height/2)/(bg:getContentSize().height*bg:getScale()))
				end
				bg:setAnchorPoint(anchorPointX,anchorPointY)
			end
	    end
	end

	local function onTouchEnd()
	    
	end

	local listener = cc.EventListenerTouchAllAtOnce:create();
	listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCHES_BEGAN);
	listener:registerScriptHandler(onTouchMove,cc.Handler.EVENT_TOUCHES_MOVED);
	listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCHES_ENDED);
	local eventDispatcher = bg:getEventDispatcher()-- 时间派发器  
	-- 绑定触摸事件到层当中
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
end

function ScaleMoveMap:androidTouch(bg)
	self.mapAnchorPointX=0
	self.mapAnchorPointY=0
	self.startTouch1X=-1
	self.startTouch2X=-1
	self.mapScale=1
	self.touchCount=0
	self.touchEndCount=0
	local function onTouchBegan(touchs)
		-- print("onTouchBegan")
		local pt=bg:convertToNodeSpace(touchs[#touchs]:getLocation())
		local s=bg:getContentSize()
		local rect=cc.rect(0,0,s.width,s.height)
		if cc.rectContainsPoint(rect, pt) then
			-- print("11111")
			self.mapAnchorPointX=bg:getAnchorPoint().x
			self.mapAnchorPointY=bg:getAnchorPoint().y
			self.startTouch1X=-1
			self.startTouch2X=-1
			self.mapScale=bg:getScale()
			self.touchCount=self.touchCount+1
			return true
		end
		return false
	end

	local function onTouchMoved(touchs)
		if self.touchCount==0 then
			return 
		end
		-- print("onTouchMoved")
		if #touchs-self.touchEndCount==1 then
			local startLocation=touchs[#touchs]:getStartLocation()
			local location = touchs[#touchs]:getLocation()
			local flagX=startLocation.x-location.x
			local flagY=startLocation.y-location.y
			local anchorPointX=self.mapAnchorPointX+flagX/(bg:getContentSize().width*self.mapScale)
			local anchorPointY=self.mapAnchorPointY+flagY/(bg:getContentSize().height*self.mapScale)
			if anchorPointX<=(display.width/2)/(bg:getContentSize().width*self.mapScale) then
				anchorPointX=(display.width/2)/(bg:getContentSize().width*self.mapScale)
			end
			if anchorPointY<=(display.height/2)/(bg:getContentSize().height*self.mapScale) then
				anchorPointY=(display.height/2)/(bg:getContentSize().height*self.mapScale)
			end

			if anchorPointX>=(1-(display.width/2)/(bg:getContentSize().width*self.mapScale)) then
				anchorPointX=(1-(display.width/2)/(bg:getContentSize().width*self.mapScale))
			end
			if anchorPointY>=(1-(display.height/2)/(bg:getContentSize().height*self.mapScale))  then
				anchorPointY=(1-(display.height/2)/(bg:getContentSize().height*self.mapScale))
			end
			
			bg:setAnchorPoint(anchorPointX,anchorPointY)

		elseif #touchs-self.touchEndCount==2 and #touchs>=2 then
			if self.startTouch1X==-1 then
				self.startTouch1X=touchs[#touchs-1]:getLocation().x
			end
			if self.startTouch2X==-1 then
				self.startTouch2X=touchs[#touchs]:getLocation().x
			end

			local location1 = touchs[#touchs-1]:getLocation()
			local location2 = touchs[#touchs]:getLocation()
			if self.mapScale*math.abs(location2.x-location1.x)/math.abs(self.startTouch2X-self.startTouch1X)<=1 and self.mapScale*math.abs(location2.x-location1.x)/math.abs(self.startTouch2X-self.startTouch1X)>=1/4 then
				bg:setScale(self.mapScale*math.abs(location2.x-location1.x)/math.abs(self.startTouch2X-self.startTouch1X))
				local anchorPointX=bg:getAnchorPoint().x
				local anchorPointY=bg:getAnchorPoint().y
				if anchorPointX<=(display.width/2)/(bg:getContentSize().width*bg:getScale()) then
					anchorPointX=(display.width/2)/(bg:getContentSize().width*bg:getScale())
				end
				if anchorPointY<=(display.height/2)/(bg:getContentSize().height*bg:getScale()) then
					anchorPointY=(display.height/2)/(bg:getContentSize().height*bg:getScale())
				end

				if anchorPointX>=(1-(display.width/2)/(bg:getContentSize().width*bg:getScale())) then
					anchorPointX=(1-(display.width/2)/(bg:getContentSize().width*bg:getScale()))
				end
				if anchorPointY>=(1-(display.height/2)/(bg:getContentSize().height*bg:getScale()))  then
					anchorPointY=(1-(display.height/2)/(bg:getContentSize().height*bg:getScale()))
				end
				bg:setAnchorPoint(anchorPointX,anchorPointY)
			end
		end
	end

	local function onTouchEnded()
		if self.touchCount==0 then
			return 
		end
		self.touchCount=self.touchCount-1
		self.touchEndCount=self.touchCount
	end

	local listener = cc.EventListenerTouchAllAtOnce:create()
	
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCHES_MOVED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCHES_ENDED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCHES_CANCELLED )
		
	-- listener:setFixedPriority(0)
	local eventDispatcher = bg:getEventDispatcher()-- 时间派发器  
	-- 绑定触摸事件到层当中
	-- eventDispatcher:addEventListenerWithFixedPriority(listener, -256)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, bg)
    -- eventDispatcher:setPriority(listener,-128)
end

return ScaleMoveMap
--
-- Author: xuewenjie
-- Date: 2016-03-10 13:46:14
--
--
-- Author: xuewenjie
-- Date: 2015-08-26 15:55:34
--
local scheduler = require("framework.scheduler")

--node
--params.beginCallback
--params.longTouchCallback
--params.longTouchCloseCallback
--params.moveCallback
--params.endCallback
--params.notSwallowTouches
--params.moveFix
-- params.interval
function addTouchEvent(node,params)
	params=params or {}
	local isMoved=false
	local schedulerToLongTouch=nil
	local showlongTouch=false
    --添加touch事件
	local function onTouchBegan(touch) 
        local location = touch:getLocation() 
		local pt=node:convertToNodeSpace(location)
		local s=node:getContentSize()
		local rect=cc.rect(0,0,s.width,s.height)
        local clipper = node.touchClipper

		if (not clipper or not clipper(location)) and cc.rectContainsPoint(rect, pt) then
			isMoved=false
			showlongTouch=false
			schedulerToLongTouch=nil
			if params.beginCallback then
				params.beginCallback(touch)
			end
			if params.longTouchCallback then
				local function onInterval()
					showlongTouch=true
					params.longTouchCallback(touch)
					scheduler.unscheduleGlobal(schedulerToLongTouch)
				end
				schedulerToLongTouch=scheduler.scheduleGlobal(onInterval, params.interval == nil and 0.6 or params.interval) 
			end
			return true
		end
        return false  
    end

    --添加touch事件
	local function onTouchMoved(touch)
		if params.moveFix then
			if isMoved then
				if params.moveCallback then
					params.moveCallback(touch)
				end
			else
				local startLocation=touch:getStartLocation()
				local location = touch:getLocation() 
				if math.abs(startLocation.x-location.x)>10 or math.abs(startLocation.y-location.y)>10 then
					isMoved=true
					if params.moveCallback then
						params.moveCallback(touch)
					end
				end
			end
		else
			if params.moveCallback then
				params.moveCallback(touch)
			end
		end
        return true
    end

    -- 触摸结束  
    local function onTouchEnded(touch)
    	if showlongTouch then
    		if params.longTouchCloseCallback then
    			params.longTouchCloseCallback(touch)
    		end
    	else
            if not isMoved and params.endCallback then
                params.endCallback(touch,isMoved)
            end

            if isMoved and params.moveEndCallback then
                params.moveEndCallback(touch)
            end
    	end

    	if schedulerToLongTouch then
			scheduler.unscheduleGlobal(schedulerToLongTouch)
		end 
    end

    local function onTouchCancelled()  
		if schedulerToLongTouch then
			scheduler.unscheduleGlobal(schedulerToLongTouch)
		end
    end

	local listener = cc.EventListenerTouchOneByOne:create()
	if params.notSwallowTouches then
        listener:setSwallowTouches(false)
    else
        listener:setSwallowTouches(true)
    end
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )

	local eventDispatcher = node:getEventDispatcher()-- 时间派发器

    -- 绑定触摸事件到层当中  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

end

--params.endCallback
-- notShowPressedAction 是否播放点击按钮效果，默认是开
function addButtonEvent(button,params,notShowPressedAction)
    if not button then
        return
    end

    button:setPressedActionEnabled(notShowPressedAction == nil and true or notShowPressedAction)

	params=params or {}
	button:addTouchEventListener(function(btn,eventType)
        local clipper = btn.touchClipper
        if clipper and clipper(btn:getTouchBeganPosition()) then
            return
        end

		if(eventType == ccui.TouchEventType.ended) then 
			if params.endCallback then
				params.endCallback(btn)
			end
        elseif eventType == ccui.TouchEventType.began then
            if params.beginCallback then
                params.beginCallback(btn)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if params.cancelCallback then
                params.cancelCallback(btn)
            end
        elseif eventType == ccui.TouchEventType.moved then
            if params.moveCallback then
                params.moveCallback(btn)
            end
		end
    end)
end

--params.bg
--params.pre
function createProgress(params)
	local probg = display.newSprite(params.bg)
    local  progress = display.newProgressTimer(params.pre, kCCProgressTimerTypeBar):addTo(probg)
    progress:setAnchorPoint(cc.p(0, 0.5))
    progress:setPosition(cc.p(0, probg:getContentSize().height/2))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setMidpoint(cc.p(0, 1))
    progress:setPercentage(0)

    probg.progress=progress
    
    return probg
end

function setSpriteGray(sp)
    local filterData = {
    "CUSTOM",
    json.encode({frag = "shader/gray.fsh",
            })
    }

    local filters, param = unpack(filterData)
    local newFilter = filter.newFilter(filters, param)
    sp:setFilter(newFilter)
end

function setCCSpriteGray(ccSp)
    local pProgram = cc.GLProgram:create("shader/gray.vsh", "shader/gray.fsh")
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    ccSp:setGLProgram(pProgram)
end

function setCCSpriteNormal(ccSp)
    local pProgram = cc.GLProgram:create("shader/gray.vsh", "shader/normal.fsh")
     
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    ccSp:setGLProgram(pProgram)
end

-- 停止节点及所有子节点动画
function stopAllNodeActions(parent)
    if checkNodeExist(parent) then
        parent:pause()
        parent:stopAllActions()
        if parent:getChildrenCount() < 1 then
            return
        end
        for _,node in pairs(parent:getChildren()) do
            node:pause()
            parent:stopAllActions()
            stopAllNodeActions(node)
        end
    end
end

-- 检查节点是否存在
function checkNodeExist(node)
    return node and not tolua.isnull(node) and node:getParent()
end

-- 安全移除节点
function safeRemoveNode(node)
    if checkNodeExist(node) then
        stopAllNodeActions(node)
        node:removeSelf()
        node = nil
        return node
    end
end

-- 创建个按钮使用系统字体
-- @params.normal       普通状态下的图片
-- @params.selected     按下装改的图片
-- @params.disable      未激活状态下的图片
-- @params.size         文本的字体大小
-- @params.outlinesize  描边粗细
function newButton(str, params)
    local SYSFONT = "Font/minijiancuyuan.ttf"
    params.size = params.size or 24
    params.outlinesize = params.outlinesize or 3
    local btn = ccui.Button:create(params.normal, params.selected, params.disable):setTitleText(str):setTitleFontSize(params.size)
    btn:setTitleFontName(SYSFONT)
    local label = btn:getTitleRenderer()
    label:enableOutline(cc.c4b(0, 0, 0, 255), params.outlinesize)
    return btn
end


function getFixScreenH()
    local a1=display.sizeInPixels.height/720
    local a2=display.sizeInPixels.width/1280
    local f
    if a1<a2 then
        f=a1
    else
        f=a2
    end
    local h=(display.sizeInPixels.height/f-720)/2
    return h
end

-- @params text         要创建的文字
-- @params x            x坐标
-- @params y            y坐标
-- @params size         字体大小（默认20）
-- @params align        文本水平对齐方式
-- @params valign       文本竖直对齐方式
-- @params dimensions   文字显示对象的尺寸，使用 cc.size() 指定
-- @params outLine      是否描边（默认为false）
-- @params color        文本颜色（默认白色）
-- @params outLineColor 描边颜色（默认黑色
-- @params outlineSize  描边宽度（默认1）
-- 创建一个普通文本
function createSimpleLabel(params)

    -- 参数预判
    params.text = params.text or ""
    params.x = params.x or 0
    params.y = params.y or 0
    params.size = params.size or 20
    params.color = params.color or cc.c3b(255, 255, 255)
    params.outLineColor = params.outLineColor or cc.c4b(0, 0, 0, 255)
    params.outlineSize = params.outlineSize or 1
    local font = params.font or "Font/minijiancuyuan.ttf"

    local label = cc.ui.UILabel.new({
                    UILabelType = 2,
                    font = font,
                    text = params.text,
                    size = params.size,
                    color = params.color,
                    align = params.align,
                    valign = params.valign,
                    dimensions = params.dimensions
                })
    label:setPosition(params.x, params.y)
    if params.outLine then
        label:enableOutline(params.outLineColor, params.outlineSize)
    end

    if params.maxLine then
        label:setMaxLineWidth(params.maxLine)
    end
    return label
end

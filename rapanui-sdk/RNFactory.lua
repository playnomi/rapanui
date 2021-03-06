--[[
--
-- RapaNui
--
-- by Ymobe ltd  (http://ymobe.co.uk)
--
-- LICENSE:
--
-- RapaNui uses the Common Public Attribution License Version 1.0 (CPAL) http://www.opensource.org/licenses/cpal_1.0.
-- CPAL is an Open Source Initiative approved
-- license based on the Mozilla Public License, with the added requirement that you attribute
-- Moai (http://getmoai.com/) and RapaNui in the credits of your program.
]]

RNFactory = {}

contentCenterX = nil
contentCenterY = nil
contentHeight = nil
contentWidth = nil
contentScaleX = nil
contentScaleY = nil
screenOriginX = nil
screenOriginY = nil
statusBarHeight = nil
viewableContentHeight = nil
viewableContentWidth = nil
HiddenStatusBar = "HiddenStatusBar"
CenterReferencePoint = "CenterReferencePoint"

RNFactory.screen = RNScreen:new()

groups = {}
groups_size = 0

RNFactory.mainGroup = RNGroup:new()
RNFactory.mainGroup.name = "mainGroup"

RNFactory.stageWidth = 0
RNFactory.stageHeight = 0
RNFactory.width = 0
RNFactory.height = 0

function RNFactory.init()

    -- S.S. alternate screen scaling
    local lwidth, lheight, screenlwidth, screenHeight
    local screenX, screenY

    local name = rawget(_G, 'name') -- looking for *global* 'name'
    if name == nil then
        name = "mainwindow"
    end

    -- for zoom mode on iphone 6+?
    if(MOAIEnvironment.osVersion >= "8.9" and MOAIEnvironment.osBrand == "iOS") then
        if (MOAIEnvironment.horizontalResolution == 1704 or MOAIEnvironment.verticalResolution == 1704) then
            MOAIEnvironment.iosRetinaDisplay = true;
        end
    end

    if (MOAIEnvironment.osBrand == "iOS") then
        screenX, screenY = MOAIGfxDevice.getViewSize()

        print("We are in iosVersion ", MOAIEnvironment.osVersion, " ", MOAIEnvironment.osVersion >= "7.9", MOAIEnvironment.horizontalResolution,  MOAIEnvironment.verticalResolution, screenX, screenY)

        if(MOAIEnvironment.osVersion >= "7.9") then
            screenX, screenY = MOAIEnvironment.horizontalResolution, MOAIEnvironment.verticalResolution
        end

    else
        screenX, screenY = MOAIEnvironment.horizontalResolution, MOAIEnvironment.verticalResolution
        print("setting screen variables for android using MOAIEnvironment.screenWidth, MOAIEnvironment.screenHeight")
    end

    print ("new setting screen x", screenX, "screen y", screenY)
    lwidth, lheight, screenlwidth, screenHeight = screenX, screenY, screenX, screenY

    landscape, device, sizes, screenX, screenY = nil

    --  lwidth, lheight from the SDConfig.lua

    RNFactory.width = lwidth
    RNFactory.height = lheight

    contentWidth = lwidth
    contentHeight = lheight

    RNFactory.outWidth = RNFactory.width
    RNFactory.outHeight = RNFactory.height

    RNFactory.screenXOffset = 0
    RNFactory.screenYOffset = 0

    RNFactory.screenUnitsX = 0
    RNFactory.screenUnitsY = 0

    --if we have to stretch graphics to screen
    print ("now stretching the screen", config.stretch.graphicsDesign.w, config.stretch.graphicsDesign.h)

    TARGET_WIDTH = config.stretch.graphicsDesign.w
    TARGET_HEIGHT = config.stretch.graphicsDesign.h
    DEVICE_WIDTH = lwidth
    DEVICE_HEIGHT = lheight

    local gameAspect = TARGET_WIDTH / TARGET_HEIGHT
    local realAspect = DEVICE_WIDTH / DEVICE_HEIGHT

    print("TARGET_WIDTH", TARGET_WIDTH, "TARGET_HEIGHT", TARGET_HEIGHT)
    print("DEVICE_WIDTH", DEVICE_WIDTH, "DEVICE_HEIGHT", DEVICE_HEIGHT)

    if realAspect > gameAspect then

        print("realAspect > gameAspect", realAspect, gameAspect)
        SCREEN_UNITS_Y = TARGET_HEIGHT
        SCREEN_UNITS_X = TARGET_HEIGHT * realAspect

    elseif realAspect < gameAspect then

        print("realAspect < gameAspect", realAspect, gameAspect)
        SCREEN_UNITS_X = TARGET_WIDTH 
        SCREEN_UNITS_Y = TARGET_WIDTH / realAspect

    else

        print("realAspect = gameAspect")
        SCREEN_UNITS_X = TARGET_WIDTH 
        SCREEN_UNITS_Y = TARGET_HEIGHT	

    end

    print("openWindow screenlwidth, screenHeight", screenlwidth, screenHeight)
    print ("SCREEN_UNITS_X", SCREEN_UNITS_X, "SCREEN_UNITS_Y", SCREEN_UNITS_Y)

    -- need to reverse screen height and width for ios 9
    if (MOAIEnvironment.osVersion >= "8.9")  then

        MOAISim.openWindow(name, screenlwidth, screenHeight)
        RNFactory.screen:initWith(SCREEN_UNITS_X, SCREEN_UNITS_Y, screenHeight, screenlwidth)

    else

        MOAISim.openWindow(name, screenlwidth*2, screenHeight*2)
        RNFactory.screen:initWith(SCREEN_UNITS_X, SCREEN_UNITS_Y, screenlwidth, screenHeight)

    end

    contentWidth = SCREEN_UNITS_X
    contentHeight = SCREEN_UNITS_Y
    
    RNFactory.outWidth = config.stretch.graphicsDesign.w
    RNFactory.outHeight = config.stretch.graphicsDesign.h

    RNFactory.screenUnitsX = SCREEN_UNITS_X
    RNFactory.screenUnitsY = SCREEN_UNITS_Y

    RNFactory.calculateTouchValues()

    RNInputManager.setGlobalRNScreen(RNFactory.screen)    
       
end

function RNFactory.calculateTouchValues()

print("touch values", RNFactory.screenXOffset, 
                      RNFactory.screenYOffset,
                      RNFactory.screenUnitsX,
                      RNFactory.screenUnitsY,
                      RNFactory.width,
                      RNFactory.height)

    local ofx = RNFactory.screenXOffset
    local ofy = RNFactory.screenYOffset

    local gx = RNFactory.screenUnitsX
    local gy = RNFactory.screenUnitsY
    local tx = RNFactory.width
    local ty = RNFactory.height

    --screen aspect without calculating offsets
    local Ax = gx / (tx - ofx * 2)
    local Ay = gy / (ty - ofy * 2)

    print("calculated values", ofx, ofy, gx, gy, tx, ty, Ax, Ay)

    local statusBar = 0

    if config.iosStatusBar then
        if MOAIEnvironment.iosRetinaDisplay then
            statusBar = 40
        else
            statusBar = 20
        end
    end

    RNFactory.statusBarHeight = statusBar
    RNFactory.ofx = ofx
    RNFactory.ofy = ofy
    RNFactory.Ax = Ax
    RNFactory.Ay = Ay
end

-- extra method call to setup the underlying system
RNFactory.init()

function RNFactory.removeAsset(path)
    RNGraphicsManager:deallocateGfx(path)
end


function RNFactory.showDebugLines()
    MOAIDebugLines.setStyle(MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 1)
    MOAIDebugLines.setStyle(MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75)
end

function RNFactory.getCurrentScreen()
    return RNFactory.screen
end



function RNFactory.createList(name, params)
    local list = RNListView:new()
    list.name = name
    list.options = params.options
    list.elements = params.elements
    list.x = params.x
    list.y = params.y
    if params.canScrollY ~= nil then list.canScrollY = params.canScrollY else list.canScrollY = true end
    list:init()
    return list
end

-- S.S. add fast list view
function RNFactory.createFastList(name, params)
    local list = RNFastListView:new()
    list.name = name
    list.options = params.options
    list.elements = params.elements
    list.x = params.x
    list.y = params.y
    if params.canScrollY ~= nil then list.canScrollY = params.canScrollY else list.canScrollY = true end
    list:init()
    return list
end


function RNFactory.createPageSwipe(name, params)
    local pSwipe = RNPageSwipe:new()
    pSwipe.options = params.options
    pSwipe.elements = params.elements
    pSwipe:init()
    return pSwipe
end

function RNFactory.createImage(image, params)
    return RNFactory.createImageFrom(image, RNFactory.screen.layers:get(RNLayer.MAIN_LAYER), params)
end

function RNFactory.loadImage(image, params)
    return RNFactory.createImageFrom(image, RNFactory.screen.layers:get(RNLayer.MAIN_LAYER), params, false)
end

function RNFactory.createImageFrom(image, layer, params, putOnScreen)
    if putOnScreen == nil then
        putOnScreen = true
    end

    local parentGroup, left, top

    top = 0
    left = 0

    if (params ~= nil) then
        if (params.top ~= nil) then
            top = params.top
        end

        if (params.left ~= nil) then
            left = params.left
        end

        if (params.parentGroup ~= nil) then
            parentGroup = params.parentGroup
        else
            parentGroup = RNFactory.mainGroup
        end
    end

    if (parentGroup == nil) then
        parentGroup = RNFactory.mainGroup
    end


    local o = RNObject:new()
    local o, deck = o:initWithImage2(image)

    --print("createImage", o.originalWidth, left, o.originalHeight, top)

    o.x = o.originalWidth / 2 + left
    o.y = o.originalHeight / 2 + top

    if putOnScreen == true then
        RNFactory.screen:addRNObject(o, nil, layer)
        o.layer = layer
    end

    if parentGroup ~= nil then
        parentGroup:insert(o)
    end


    return o, deck
end

function RNFactory.createButton(image, params)
    return RNFactory.createButtonFrom(image, RNFactory.screen.layers:get(RNLayer.MAIN_LAYER), params)
end

function RNFactory.loadButton(image, params)
    return RNFactory.createButtonFrom(image, RNFactory.screen.layers:get(RNLayer.MAIN_LAYER), params, false)
end


function RNFactory.createButtonFrom(image, layer, params, putOnScreen)
    if putOnScreen == nil then
        putOnScreen = true
    end

    local parentGroup, left, top

    local top, left, size, font

    local xOffset, yOffset = 0, 0

    font =  "Helvetica"
    size = 14


    top = 0
    left = 0

    if (params ~= nil) then

        if (params.top ~= nil) then
            top = params.top
        end

        if (params.left ~= nil) then
            left = params.left
        end

        if (params.parentGroup ~= nil) then
            parentGroup = params.parentGroup
        else
            parentGroup = RNFactory.mainGroup
        end

        if (params.top ~= nil) then
            top = params.top
        end

        if (params.left ~= nil) then
            left = params.left
        end

        if (params.font ~= nil) then
            font = params.font
        end

        if (params.size ~= nil) then
            size = params.size
        end

        --[[
      if (params.height ~= nil) then
          height = params.height
      end

      if (params.width ~= nil) then
          width = params.width
      end
        ]] --

    end

    if (params.xOffset ~= nil) then
        xOffset = params.xOffset
    end

    if (params.yOffset ~= nil) then
        yOffset = params.yOffset
    end

    -- init of default RNButtonImage
    local rnButtonImage = RNObject:new()
    local rnButtonImage, deck = rnButtonImage:initWithImage2(image)

    rnButtonImage.x = rnButtonImage.originalWidth / 2 + left
    rnButtonImage.y = rnButtonImage.originalHeight / 2 + top
    if putOnScreen == true then
        RNFactory.screen:addRNObject(rnButtonImage, nil, layer)
    end


    local rnButtonImageOver

    if params.imageOver ~= nil then

        rnButtonImageOver = RNObject:new()
        rnButtonImageOver, deck = rnButtonImageOver:initWithImage2(params.imageOver)

        rnButtonImageOver.x = rnButtonImageOver.originalWidth / 2 + left
        rnButtonImageOver.y = rnButtonImageOver.originalHeight / 2 + top

        rnButtonImageOver:setVisible(false)

        if putOnScreen == true then
            RNFactory.screen:addRNObject(rnButtonImageOver, nil, layer)
        end
    end


    local rnButtonImageDisabled

    if params.imageDisabled ~= nil then

        rnButtonImageDisabled = RNObject:new()
        rnButtonImageDisabled, deck = rnButtonImageDisabled:initWithImage2(params.imageDisabled)

        rnButtonImageDisabled.x = rnButtonImageDisabled.originalWidth / 2 + left
        rnButtonImageDisabled.y = rnButtonImageDisabled.originalHeight / 2 + top

        rnButtonImageDisabled:setVisible(false)

        if putOnScreen == true then
            RNFactory.screen:addRNObject(rnButtonImageDisabled, nil, layer)
        end
    end

    local rnText

    local gFont

    if params.text == nil then
        params.text = ""
    end

    rnText = RNText:new()
    rnText, gFont = rnText:initWithText2(params.text, font, size, rnButtonImage.originalWidth, rnButtonImage.originalHeight, vAlignment, hAlignment)
    if putOnScreen == true then
        RNFactory.screen:addRNObject(rnText, nil, layer)
    end

    --     RNFactory.mainGroup:insert(rnText)
    rnText.x = left
    rnText.y = top




    local rnButton = RNButton:new()
    rnButton.xOffset = xOffset
    rnButton.yOffset = yOffset
    rnButton:initWith(rnButtonImage, rnButtonImageOver, rnButtonImageDisabled, rnText)


    if parentGroup ~= nil then
        parentGroup:insert(rnButton)
    end



    rnButton.x = rnButtonImage.originalWidth / 2 + left
    rnButton.y = rnButtonImage.originalHeight / 2 + top

    if params.onTouchUp ~= nil then
        rnButton:setOnTouchUp(params.onTouchUp)
    end

    if params.onTouchDown ~= nil then
        rnButton:setOnTouchDown(params.onTouchDown)
    end

    if putOnScreen == true then
        rnButton.layer = layer
    end

    return rnButton, deck
end

function RNFactory.createImageFromMoaiImage(moaiImage, params)

    local parentGroup, left, top

    top = 0
    left = 0
    layer = nil

    if (params ~= nil) then
        if (params.top ~= nil) then
            top = params.top
        end

        if (params.left ~= nil) then
            left = params.left
        end

        if (params.parentGroup ~= nil) then
            parentGroup = params.parentGroup
        else
            parentGroup = RNFactory.mainGroup
        end

        if (params.layer) then
            layer = params.layer
        end
    end
    


    if (parentGroup == nil) then
        parentGroup = RNFactory.mainGroup
    end


    local image = RNObject:new()
    image:initWithMoaiImage(moaiImage)
    RNFactory.screen:addRNObject(image, nil, layer)
    image.x = image.originalWidth / 2 + left
    image.y = image.originalHeight / 2 + top

    if parentGroup ~= nil then
        parentGroup:insert(image)
    end


    return image
end


function RNFactory.createImageFromMoaiSlotsImage(moaiImage, params)
    
    local parentGroup, left, top
    
    top = 0
    left = 0
    layer = nil
    
    if (params ~= nil) then        
        if (params.layer) then
            layer = params.layer
        end
    end
    
    if (parentGroup == nil) then
        parentGroup = RNFactory.mainGroup
    end
    
    
    local image = RNObject:new()
    image:initWithMoaiSlotsImage(moaiImage)
    RNFactory.screen:addRNObject(image, nil, layer)
    image.x = image.originalWidth / 2 + left
    image.y = image.originalHeight / 2 + top
    
    if parentGroup ~= nil then
        parentGroup:insert(image)
    end
    
    
    return image
end



function RNFactory.createMoaiImage(filename)
    local image = MOAIImage.new()
    image:load(filename, MOAIImage.TRUECOLOR + MOAIImage.PREMULTIPLY_ALPHA)
    return image
end

function RNFactory.createBlankMoaiImage(width, height)
    local image = MOAIImage.new()
    image:init(width, height)
    return image
end

function RNFactory.createAtlasFromTexturePacker(image, file)
    RNGraphicsManager:allocateTexturePackerAtlas(image, file)
end

function RNFactory.createCopyRect(moaiimage, params)

    local parentGroup, left, top

    top = 0
    left = 0

    if (params ~= nil) then
        if (params.top ~= nil) then
            top = params.top
        end

        if (params.left ~= nil) then
            left = params.left
        end

        if (params.parentGroup ~= nil) then
            parentGroup = params.parentGroup
        else
            parentGroup = RNFactory.mainGroup
        end
    end

    if (parentGroup == nil) then
        parentGroup = RNFactory.mainGroup
    end


    local image = RNObject:new()
    image:initCopyRect(moaiimage, params)
    RNFactory.screen:addRNObject(image)
    image.x = image.originalWidth / 2 + left
    image.y = image.originalHeight / 2 + top

    if parentGroup ~= nil then
        parentGroup:insert(image)
    end


    return image
end

function RNFactory.createAnim(image, sizex, sizey, left, top, scaleX, scaleY)

    if scaleX == nil then
        scaleX = 1
    end

    if scaleY == nil then
        scaleY = 1
    end

    if left == nil then
        left = 0
    end

    if top == nil then
        top = 0
    end

    local parentGroup = RNFactory.mainGroup


    local o = RNObject:new()
    local o, deck = o:initWithAnim2(image, sizex, sizey, scaleX, scaleY)

    o.x = left
    o.y = top

    local parentGroup = RNFactory.mainGroup

    RNFactory.screen:addRNObject(o)

    if parentGroup ~= nil then
        parentGroup:insert(o)
    end


    return o, deck
end


function RNFactory.createBitmapText(text, params)

    --[[ params.image
params.charset
params.top
params.left
params.letterWidth
params.letterHeight
    ]]

    local charcodes, endsizex, sizey, sizex, left, top, scaleX, scaleY, charWidth, charHeight, image, parentGroup
    local hAlignment, vAlignment

    if params.image ~= nil then
        image = params.image
    end

    if params.charcodes ~= nil then
        charcodes = params.charcodes
    end

    if params.top ~= nil then
        top = params.top
    end

    if params.left ~= nil then
        left = params.left
    end

    if params.charWidth ~= nil then
        charWidth = params.charWidth
    end

    if params.charHeight ~= nil then
        charHeight = params.charHeight
    end

    if params.parentGroup ~= nil then
        parentGroup = params.parentGroup
    else
        parentGroup = RNFactory.mainGroup
    end

    if params.hAlignment ~= nil then
        hAlignment = params.hAlignment
    end

    if params.vAlignment ~= nil then
        vAlignment = params.vAlignment
    end

    local o = RNBitmapText:new()
    local o, deck = o:initWith(text, image, charcodes, charWidth, charHeight, top, left, hAlignment, vAlignment)

    o.x = left
    o.y = top



    parentGroup:insert(o)

    return o, deck
end

function RNFactory.createText(text, params)

    local text = tostring(text)
    return RNFactory.createTextFrom(text, RNFactory.screen.layers:get(RNLayer.MAIN_LAYER), params)
end

function RNFactory.loadText(text, params)
    local text = tostring(text)
    return RNFactory.createTextFrom(text, RNFactory.screen.layers:get(RNLayer.MAIN_LAYER), params, false)
end

function RNFactory.createTextFrom(text, layer, params, putOnScreen)
    local text = tostring(text)
    if putOnScreen == nil then
        putOnScreen = true
    end

    local top, left, size, font, height, width, alignment, vAlignment, hAlignment

    font = "Helvetica"
    size = 14
    alignment = MOAITextBox.CENTER_JUSTIFY
    --LEFT_JUSTIFY, CENTER_JUSTIFY or RIGHT_JUSTIFY.

    params.size = params.size

    if (params ~= nil) then
        if (params.top ~= nil) then
            top = params.top
            top = math.floor(top)
        end

        if (params.left ~= nil) then
            left = params.left
            left = math.floor(left)
        end

        if (params.font ~= nil) then
            font = params.font
        end

        if (params.size ~= nil) then
            size = params.size
        end

        if (params.height ~= nil) then
            height = params.height
        end

        if (params.width ~= nil) then
            width = params.width
        end

        if (params.alignment ~= nil) then
            hAlignment = params.alignment
        end

        -- S.S. Adjustments for text alignment
        if (params.vAlignment ~= nil) then
            vAlignment = params.vAlignment
        end  
        
        if (params.hAlignment ~= nil) then
            hAlignment = params.hAlignment
        end 

        if hAlignment == nil then
            hAlignment = alignment
        end


    end

    local rntext = RNText:new()
    local gFont

    rntext, gFont = rntext:initWithText2(text, font, size, width, height,  hAlignment, vAlignment )

    if putOnScreen == true then
        RNFactory.screen:addRNObject(rntext, nil, layer)
        rntext.layer = layer
    end

    RNFactory.mainGroup:insert(rntext)


    if (params.x) then
        --rntext:getProp():setPiv(params.x, params.y)
        rntext.x = params.x
        rntext.y = params.y
    else
        rntext.x = left
        rntext.y = top
    end

    return rntext, gFont
end

function RNFactory.createRectFrom(x,y,width,height,params)

    return RNFactory.createRect(x,y,width,height,params)

end


function RNFactory.createRect(x, y, width, height, params)
    local parentGroup, top, left
    local rgb = { 255, 255, 255 }

    if params then
        parentGroup = params.parentGroup or RNFactory.mainGroups
        rgb = params.rgb or rgb
    end

    local shape = RNObject:new()
    shape:initWithRect(width, height, rgb)
    
    if (params) then
    
        --print("create rect with params", params.layer )

        RNFactory.screen:addRNObject(shape, nil, params.layer)
    else
        RNFactory.screen:addRNObject(shape)    
    end
    
    shape.x = shape.originalWidth * .5 + x
    shape.y = shape.originalHeight * .5 + y
    shape.rotation = 0

    if parentGroup ~= nil then
        parentGroup:insert(shape)
    end
    return shape
end

function RNFactory.createCircle(x, y, r, params)
    local parentGroup, top, left
    local rgb = { 255, 255, 255 }

    if params then
        if type(params) == "table" then
            parentGroup = params.parentGroup or RNFactory.mainGroups
            top = params.top or 0
            left = params.left or 0
            rgb = params.rgb or rgb
        end
    end

    local shape = RNObject:new()
    shape:initWithCircle(x, y, r, rgb)
    RNFactory.screen:addRNObject(shape)
    shape.x = x
    shape.y = y
    shape.rotation = 0

    if parentGroup ~= nil then
        parentGroup:insert(shape)
    end
    return shape
end

return RNFactory
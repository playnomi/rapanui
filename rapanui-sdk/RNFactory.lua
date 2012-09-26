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
contentWidth = nil
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

    local lwidth, lheight, screenlwidth, screenHeight
    local screenX, screenY

    if config.landscape == false then

        screenX, screenY = MOAIEnvironment.horizontalResolution, MOAIEnvironment.verticalResolution
    
    else

        screenX, screenY = MOAIEnvironment.horizontalResolution, MOAIEnvironment.verticalResolution

    end

    print ("screen resolution", screenX, screenY)
    
    if (MOAIEnvironment.osBrand == "iOS") then
    
        screenX, screenY = MOAIGfxDevice.getViewSize() 

    else 
    
        print("setting screen variables for android using MOAIEnvironment.screenWidth, MOAIEnvironment.screenHeight")
        --screenX, screenY = MOAIEnvironment.screenWidth, MOAIEnvironment.screenHeight
        --screenX, screenY = 480, 800
            
    end

    print ("new setting screen x", screenX, "screen y", screenY)

    if screenX ~= nil then --if physical screen
        lwidth, lheight, screenlwidth, screenHeight = screenX, screenY, screenX, screenY
    else
        lwidth, lheight, screenlwidth, screenHeight = config.sizes[config.device][1], config.sizes[config.device][2], config.sizes[config.device][3], config.sizes[config.device][4]
    end

   -- if config.landscape == true then -- flip lwidths and Hieghts
   --     lwidth, lheight = lheight, lwidth
   --     screenlwidth, screenHeight = screenHeight, screenlwidth
   -- end

    landscape, device, sizes, screenX, screenY = nil


    if name == nil then
        name = "mainwindow"
    end

    --  lwidth, lheight from the SDConfig.lua

    if config.stretch == true then

        print ("now stretching the screen")

        TARGET_WIDTH = config.graphicsDesign.w
        TARGET_HEIGHT = config.graphicsDesign.h
        DEVICE_WIDTH = lwidth
        DEVICE_HEIGHT = lheight

        local gameAspect = TARGET_WIDTH / TARGET_HEIGHT
        local realAspect = DEVICE_WIDTH / DEVICE_HEIGHT

        if realAspect > gameAspect then

        SCREEN_UNITS_Y = TARGET_HEIGHT
        SCREEN_UNITS_X = TARGET_HEIGHT * realAspect

        elseif realAspect < gameAspect then

        SCREEN_UNITS_X = TARGET_WIDTH 
        SCREEN_UNITS_Y = TARGET_WIDTH / realAspect

        else

        SCREEN_UNITS_X = TARGET_WIDTH 
        SCREEN_UNITS_Y = TARGET_HEIGHT	

        end

        print("openWindow screenlwidth, screenHeight", screenlwidth, screenHeight)
        print ("SCREEN_UNITS_X", SCREEN_UNITS_X, "SCREEN_UNITS_Y", SCREEN_UNITS_Y)


        MOAISim.openWindow(name, screenlwidth, screenHeight)
        RNFactory.screen:initWith(SCREEN_UNITS_X, SCREEN_UNITS_Y, screenlwidth, screenHeight)

        RNFactory.width = screenlwidth
        RNFactory.height = screenHeight

        contentlwidth = SCREEN_UNITS_X
        contentHeight = SCREEN_UNITS_Y

    else

        print ("no screen scretch")
        print("openWindow screenlwidth, screenHeight", screenlwidth, screenHeight)

        MOAISim.openWindow(name, screenlwidth, screenHeight)
        RNFactory.screen:initWith(lwidth, lheight, screenlwidth, screenHeight)

        RNFactory.width = lwidth
        RNFactory.height = lheight

        contentlwidth = lwidth
        contentHeight = lheight

    end


   --if we have to stretch graphics to screen
    --if config.stretch == true then
    --    RNFactory.screen.viewport:setSize(0, 0, lwidth, lheight)
    --    RNFactory.screen.viewport:setScale(config.graphicsDesign.w, -config.graphicsDesign.h)
    --end


    RNInputManager.setGlobalRNScreen(screen)
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
    
    local imageFilenameToLoad = image
    
if (MOAIEnvironment.osBrand == "iOS") then

    -- HD asserts
    --if (MOAIEnvironment.iosRetinaDisplay) then
        
        -- we need to add -hd to the filename 
        imageFilenameToLoad, replacements = string.gsub(image, ".png", "-hd.png")
            
   -- else
        -- just use the filename given
    
   -- end

else

    -- HD asserts
    --if (MOAIEnvironment.screenWidth > 2000) then

        -- we need to add -hd to the filename 
        imageFilenameToLoad, replacements = string.gsub(image, ".png", "-hd.png")
        
    --else
        -- just use the filename given

    --end


end
   
    --print ("image to load", imageFilenameToLoad) 
    
    local o, deck = o:initWithImage2(imageFilenameToLoad)

    o.x = o.originalWidth / 2 + left
    o.y = o.originalHeight / 2 + top

    RNFactory.screen:addRNObject(o)

    if parentGroup ~= nil then
        parentGroup:insert(o)
    end


    return o, deck
end

function RNFactory.createImageFromMoaiImage(moaiImage, params)

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
    image:initWithMoaiImage(moaiImage)
    RNFactory.screen:addRNObject(image)
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

function RNFactory.createText(text, params)

    if (text == nil) then
    
        text = ""
    
    end


    local top, left, size, font, height, width, alignment

    -- defaults
    --COOLVETI
    --font = "COOLVETI"
    --font = "HelveticaNeue"
    font = "Helvetica"
    --font = "arial-rounded"
    size = 14
    alignment = MOAITextBox.CENTER_JUSTIFY
    --LEFT_JUSTIFY, CENTER_JUSTIFY or RIGHT_JUSTIFY.

    if (params ~= nil) then
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

        if (params.height ~= nil) then
            height = params.height
        end

        if (params.width ~= nil) then
            width = params.width
        end

        if (params.alignment ~= nil) then
            alignment = params.alignment
        end
    end

    local RNText = RNText:new()
    local gFont
    RNText, gFont = RNText:initWithText2(text, font, size, width, height, alignment)
    RNFactory.screen:addRNObject(RNText)
    RNFactory.mainGroup:insert(RNText)

    RNText.x = left
    RNText.y = top

    return RNText, gFont
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
    RNFactory.screen:addRNObject(shape)
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
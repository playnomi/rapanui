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

local background = RNFactory.createImage("images/background-blue.png")
local toDisable = false

button = RNFactory.createButton("images/button-plain.png", {
    text = "Main Button 1",
    imageOver = "images/button-over.png",
    imageDisabled = "images/button-disabled.png",
    top = 50,
    left = 10,
    size = 16,
    width = 200,
    height = 50
})

button:disable()

trn = RNTransition:new()

function goToPointA()
    trn:run(button, { type = "move", time = 1500, alpha = 0, x = 200, y = 200, onComplete = goToPointB })
end

function goToPointB()
    trn:run(button, { type = "move", time = 1500, alpha = 0, x = 0, y = 0, onComplete = goToPointA })
end

goToPointA()


function button1TouchDown(event)
    print("Button 1 touch down!")
end

function button1UP(event)
    print("Button 1 touch up")
end

button:setOnTouchDown(button1TouchDown)
button:setOnTouchUp(button1UP)



button2 = RNFactory.createButton("images/button-plain.png", {
    text = "Disable Main Button",
    top = 250,
    left = 10,
    size = 16,
    width = 200,
    height = 50
})



function button2UP(event)
    if toDisable == true then
        button:disable()
        toDisable = false
    else
        button:enable()
        toDisable = true
    end
end

button2:setOnTouchUp(button2UP)

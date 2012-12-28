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
--]]

--create images and a tiled map

local img1 = RNFactory.createImage("images/tile1.png")
img1.x = 100
img1.y = 32
local img2 = RNFactory.createImage("images/tile2.png")
img2.x = 140
img2.y = 32
local img3 = RNFactory.createImage("images/tile3.png")
img3.x = 180
img3.y = 32
local img4 = RNFactory.createImage("images/tile4.png")
img4.x = 100
img4.y = 64
local img5 = RNFactory.createImage("images/tile5.png")
img5.x = 140
img5.y = 64
local img6 = RNFactory.createImage("images/tile6.png")
img6.x = 180
img6.y = 64
local mapOne = RNMapFactory.loadMap(RNMapFactory.TILED, "rapanui-samples/groups/mapone.tmx")
local aTileset = mapOne:getTileset(0)
aTileset:updateImageSource("rapanui-samples/groups/tilesetdemo.png")
mapOne:drawMapAt(100, 200, aTileset)



local group1 = RNGroup:new()
local group2 = RNGroup:new()
local group3 = RNGroup:new()
-- name groups if you want
group1.name = "group1"
group2.name = "group2"
group3.name = "group3"


--insert images and map into groups
group1:insert(img1, true) --true means resetTransform (object will be placed to group origin)
group1:insert(img2)
group2:insert(img3)
group2:insert(mapOne)
group3:insert(img4)
group3:insert(img5)

--nest groups as shown the scheme above
group1:insert(group2)
group2:insert(group3)


-- remove a group and all its children
--group1:remove()
--group2:remove()
--group3:remove()

RNUnit.assertEquals(3, #group1.displayObjects, "wrong number of objects in group")
RNUnit.assertEquals(3, #group2.displayObjects, "wrong number of objects in group")
RNUnit.assertEquals(2, #group3.displayObjects, "wrong number of objects in group")
-- mainGroup is the basic group in which all objects are inserted
-- here's how to get objects, non group objects and all objects
RNUnit.assertEquals(2, #RNFactory.mainGroup.displayObjects, "wrong number of objects in group")
RNUnit.assertEquals(7, #RNFactory.mainGroup:getAllNonGroupChildren(), "wrong number of objects in group")
RNUnit.assertEquals(10, #RNFactory.mainGroup:getAllChildren(), "wrong number of objects in group")

RNUnit.assertEquals(6, #group1:getAllNonGroupChildren(), "wrong number of objects in group")
RNUnit.assertEquals(4, #group2:getAllNonGroupChildren(), "wrong number of objects in group")
RNUnit.assertEquals(2, #group3:getAllNonGroupChildren(), "wrong number of objects in group")

--applying transition to groups
local trn = RNTransition:new()

-- uncommet the transition you want to use
-- move
--trn:run(group1, { type = "move", y = 100, x = 100 })

local function check()

    local mapX, mapY = mapOne:getLoc()
    RNUnit.assertEquals(200, mapX, "The Map position x was wrong")
    RNUnit.assertEquals(300, mapY, "The Map position y was wrong")
    print("All test done")
end

trn:run(group2, { type = "move", y = 100, x = 100, onComplete = check })


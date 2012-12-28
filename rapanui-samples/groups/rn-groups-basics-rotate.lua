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



--[[
  Children Tree starting from RNFactory.mainGroup

  MG
     img6
     G1
        img1
        img2
        G2
           img3
           mapOne
           G3
                img4
                img5

 ]] --

-- create groups
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

--print some values
print("# # # # # # # # # # # #")
print("objects in group1 = " .. #group1.displayObjects)
print("objects in group2 = " .. #group2.displayObjects)
print("objects in group3 = " .. #group3.displayObjects)
print("# # # # # # # # # # # #")
-- mainGroup is the basic group in which all objects are inserted
-- here's how to get objects, non group objects and all objects
print("displayObjects in mainGroup = " .. #RNFactory.mainGroup.displayObjects)
print("non group objects in mainGroup = " .. #RNFactory.mainGroup:getAllNonGroupChildren())
print("all children in mainGroup = " .. #RNFactory.mainGroup:getAllChildren())
print("# # # # # # # # # # # #")
print("non group objects in group1 = " .. #group1:getAllNonGroupChildren())
print("non group objects in group2 = " .. #group2:getAllNonGroupChildren())
print("non group objects in group3 = " .. #group3:getAllNonGroupChildren())
print("# # # # # # # # # # # #")



-- flattern (this will place all the group's elements (and sub-elements) at the same drawing priority

group1:flattern(100)
group2:flattern(50)
group3:flattern(1)
-- note: when an object is inserted in a group, its priority is reset to 1.
-- also if its already in a group, or if a group is inserted.
-- so: first of all nest groups. Then use flattern function. Reuse flattern if you add a new object to a group
-- or something might be wrong.


--how to get an element from a group:
--each element has
print(img1.idInGroup)
--so you can get if from group like this:
print(group1:getChild(img1.idInGroup))
--but the above method won't work for nested group (when for example img1 is in group2 and group2 in group1)
--if you want to get a child from its name you can do like this:
--set a name (by default image name is it's source path)
img4.name = "image4"
print(group1:getChild("image4"))
--this will work with nested groups (image4 is in group3 under group2 in group1) and if you need to get a group, too:
group3.name = "group3"
print(group1:getChild("group3"))



--applying transition to groups
local trn = RNTransition:new()

-- uncommet the transition you want to use
-- rotate
--trn:run(group1, { type = "rotate", angle = 370 })
trn:run(group2, { type = "rotate", angle = 370 })
--trn:run(group3, { type = "rotate", angle = 370 })

--recursive transition for specified group [for testing purpose] :
--[[
local stGr = group2

function moo()
    stGr.x = 100
    stGr.y = 100
    trn:run(stGr, { type = "move", y = 200, x = 200, onComplete = moo })
end

stGr.x = 0
stGr.y = 0

moo()

]] --










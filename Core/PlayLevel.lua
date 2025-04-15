-- $$$$$$$\  $$\                     $$\                                    $$\     $$\                          
-- $$  __$$\ $$ |                    $$ |                                   $$ |    $$ |                         
-- $$ |  $$ |$$ | $$$$$$\  $$\   $$\ $$ |      $$$$$$\ $$\    $$\  $$$$$$\  $$ |    $$ |     $$\   $$\  $$$$$$\  
-- $$$$$$$  |$$ | \____$$\ $$ |  $$ |$$ |     $$  __$$\\$$\  $$  |$$  __$$\ $$ |    $$ |     $$ |  $$ | \____$$\ 
-- $$  ____/ $$ | $$$$$$$ |$$ |  $$ |$$ |     $$$$$$$$ |\$$\$$  / $$$$$$$$ |$$ |    $$ |     $$ |  $$ | $$$$$$$ |
-- $$ |      $$ |$$  __$$ |$$ |  $$ |$$ |     $$   ____| \$$$  /  $$   ____|$$ |    $$ |     $$ |  $$ |$$  __$$ |
-- $$ |      $$ |\$$$$$$$ |\$$$$$$$ |$$$$$$$$\\$$$$$$$\   \$  /   \$$$$$$$\ $$ |$$\ $$$$$$$$\\$$$$$$  |\$$$$$$$ |
-- \__|      \__| \_______| \____$$ |\________|\_______|   \_/     \_______|\__|\__|\________|\______/  \_______|
--                         $$\   $$ |                                                                            
--                         \$$$$$$  |                                                                            
--                          \______/                                                                             



------------------------------------------------------------------------------------
-- Important
------------------------------------------------------------------------------------

local cx, cy = display.contentCenterX, display.contentCenterY
local playing = true

local tileSize = 100
local isMoving = false
local interactable = false

local rows = 0
local curRow = 0

local rectTable = {}

local facing = "U" -- U - Up, D - Down, L - left, R - Right

local followCamBackGrp = display.newGroup() -- Background
local followCamMiddGrp = display.newGroup() -- Middleground
local followCamForeGrp = display.newGroup() -- Foreground
local moveRight, moveLeft = false, false
local moveUp, moveDown = false, false



------------------------------------------------------------------------------------
-- Player
------------------------------------------------------------------------------------

-- Make player
local player = display.newRect(followCamMiddGrp, cx, cy, tileSize, tileSize)
player:setFillColor(0, 1, 1)



------------------------------------------------------------------------------------
-- Virtual Camera
------------------------------------------------------------------------------------

local camDiffX = 0
local camDiffY = 0
local camDiffX = 0
local camDiffY = 0
local function moveCamera()
    if playing then
        camDiffX = cx - player.x
        camDiffY = cy - player.y

        followCamMiddGrp.x = camDiffX
        followCamMiddGrp.y = camDiffY
    end
end

Runtime:addEventListener("enterFrame", moveCamera) -- never got used



------------------------------------------------------------------------------------
-- Move Player -- Keyboard
------------------------------------------------------------------------------------

local pressedKeys = {}

local function movePlayerGrid(dx, dy)
    if isMoving or not playing then return end
    isMoving = true

    -- Check if player can move in that direction

    local newX = player.x + (dx * tileSize)
    local newY = player.y + (dy * tileSize)

    -- Optional: Add bounds / collision check here

    -- Find target tile's grid position
    local targetX = math.floor((newX - cx) / tileSize)
    local targetY = math.floor((newY - cy) / tileSize)

    -- Check for wall at that position
    local isBlocked = false
    for i = 2, #rows do
        local rx = tonumber(rows[i][1])
        local ry = tonumber(rows[i][2])
        local solid = rows[i][3] == "true"

        if rx == targetX and ry == targetY and solid then
            isBlocked = true
            break
        end
    end

    -- Only move if not blocked
    if not isBlocked then
        transition.to(player, {
            time = 150,
            x = newX,
            y = newY,
            onComplete = function()
                isMoving = false
            end
        })
    else
        isMoving = false -- cancel movement
    end


    -- Make Shuffle Sound

end

local function onKeyEvent(event)
    if event.phase == "down" then
        -- Move
        if event.keyName == "right" or event.keyName == "d" then
            movePlayerGrid(1, 0)
            facing = "R"
        elseif event.keyName == "left" or event.keyName == "a" then
            movePlayerGrid(-1, 0)
            facing = "L"
        elseif event.keyName == "up" or event.keyName == "w" then
            movePlayerGrid(0, -1)
            facing = "U"
        elseif event.keyName == "down" or event.keyName == "s" then
            movePlayerGrid(0, 1)
            facing = "D"
        end

        -- Interact
        if event.keyName == "space" and interactable then
            -- Interact with object
        end
    end
    return false
end


-- Event listeners
Runtime:addEventListener("key", onKeyEvent)



------------------------------------------------------------------------------------
-- Build Level
------------------------------------------------------------------------------------

local function replace_commas_with_forex(text)
    local result = ""
    local in_string = false
    for i = 1, #text do
        local char = text:sub(i, i)
        if char == '"' then
            in_string = not in_string
        elseif char == ',' and in_string then
            char = '¤'
        end
        result = result .. char
    end
    return result
end

function parse_csv_to_array(oldCsv)
    local csv = replace_commas_with_forex(oldCsv)
    local array = {}
    for line in csv:gmatch("[^\r\n]+") do
        local row = {}
        for cell in line:gmatch("[^,]+") do
            table.insert(row, cell)
        end
        table.insert(array, row)
    end
    return array
end


local function buildLevel(build)
    if curRow <= #rows then
        -- Start from the second row (since row 1 is the header)
        for i = 2, #rows do
            local id = tostring(i)
            local x = tonumber(rows[i][1])
            local y = tonumber(rows[i][2])
            local isSolid = rows[i][3] == "true"
            local special = rows[i][4]

            local xOffset = cx + x * 100
            local yOffset = cy + y * 100

            if tostring(build) == "YES" then
                -- Choose tile based on special or solid
                local image = "Assets/OLD_tiles1.png"
                if special == "spawn" then
                    player.x = xOffset
                    player.y = yOffset
                elseif special == "loot" then
                    image = "Assets/loot_tile.png"
                elseif special == "guard" then
                    image = "Assets/guard_tile.png"
                elseif special == "camera" then
                    image = "Assets/camera_tile.png"
                elseif isSolid then
                    image = "Assets/wall_tile.png"
                else
                    image = "Assets/floor_tile.png"
                end

                -- rectTable[id] = display.newImageRect(image, 100, 100)
                rectTable[id] = display.newRect(0, 0, 100, 100)
                rectTable[id].x, rectTable[id].y = xOffset, yOffset
                followCamMiddGrp:insert(rectTable[id])

                if isSolid then
                    rectTable[id]:setFillColor(0.4, 0.4, 0.4) -- dark gray for walls
                else
                    rectTable[id]:setFillColor(0.8, 0.8, 0.8) -- light gray for floor
                end

                -- rectTable[id].fill = {1,1,1}
                rectTable[id].alpha = 1

            elseif tostring(build) == "NO" then
                display.remove(rectTable[id])
                rectTable[id] = nil
            end
        end
    end
end

local path = system.pathForFile("Levels/Debug.csv", system.ResourceDirectory)
local file = io.open(path, "r")

if file then
    local contents = file:read("*a")
    io.close(file)

    rows = parse_csv_to_array(contents)
    curRow = 2 -- skip header row
    buildLevel("YES")
    player:toFront()
else
    print("Error: CSV file not found!")
end


------------------------------------------------------------------------------------
-- Function Calling
------------------------------------------------------------------------------------

local movement = {}

function movement.Start()
    -- call functions from here 
end

return movement
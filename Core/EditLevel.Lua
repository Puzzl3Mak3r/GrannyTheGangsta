-- ASCII ART HERE
-- https://www.fancytextpro.com/BigTextGenerator
-- 3 Empty lines between each "section"
-- Function Calling as the last one



------------------------------------------------------------------------------------
-- Section 1
------------------------------------------------------------------------------------

-- csv_level_editor.lua

local widget = require("widget")
local json = require("json")

local tileSize = 50
local gridWidth, gridHeight = 10, 20 -- adjust as needed
local tiles = {}
local currentTileType = 0
local tileColors = {
    {0.8, 0.8, 0.8},    -- 0: Empty (White)
    {0.2, 0.2, 0.2},    -- 1: Wall (Black)
    {1, 1, 0},          -- 2: Loot (Yellow)
    {1, 0, 0},          -- 3: Guard spawn (Red)
    {0, 0, 1},          -- 4: Player spawn (Blue)
}

local function getTileTypeFromColor(color)
    for i, col in ipairs(tileColors) do
        if color[1] == col[1] and color[2] == col[2] and color[3] == col[3] then
            return i - 1
        end
    end
    return 0
end

local function updateTileColor(tile, tileType)
    tile.fill = tileColors[tileType + 1]
    tile.tileType = tileType
end

local function exportToCSV(filename)
    local lines = {"x,y,isSolid,special"}
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local tile = tiles[y][x]
            local solid = (tile.tileType == 1) and "true" or "false"
            local special = ""
            if tile.tileType == 2 then special = "loot" end
            if tile.tileType == 3 then special = "guard" end
            if tile.tileType == 4 then special = "player" end
            table.insert(lines, string.format("%d,%d,%s,%s", x - 1, y - 1, solid, special))
        end
    end
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    file:write(table.concat(lines, "\n"))
    io.close(file)
    print("Exported to:", path)
end

local function onTileTouch(event)
    local tile = event.target
    if event.isPrimaryButtonDown then
        updateTileColor(tile, currentTileType)
    elseif event.isSecondaryButtonDown then
        tile.tileType = (tile.tileType + 1) % #tileColors
        updateTileColor(tile, tile.tileType)
    end
    return true
end

-- Draw grid
for y = 1, gridHeight do
    tiles[y] = {}
    for x = 1, gridWidth do
        local rect = display.newRect(x * tileSize, y * tileSize, tileSize - 2, tileSize - 2)
        rect.anchorX, rect.anchorY = 0, 0
        updateTileColor(rect, 0)
        rect:addEventListener("touch", onTileTouch)
        tiles[y][x] = rect
    end
end

-- Export button
local exportButton = widget.newButton({
    label = "Export CSV",
    x = display.contentCenterX,
    y = display.contentHeight - 30,
    shape = "roundedRect",
    width = 200,
    height = 40,
    onRelease = function()
        exportToCSV("level_output.csv")
    end
})



------------------------------------------------------------------------------------
-- Function Calling
------------------------------------------------------------------------------------

local guide = {}

function guide.Start()
    -- call functions from here 
end

return guide
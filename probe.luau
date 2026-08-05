local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local out = {}

local function add(s)
    out[#out + 1] = tostring(s)
end

local function attr(inst, name)
    local ok, v = pcall(inst.GetAttribute, inst, name)
    return ok and v or nil
end

local function pathOf(inst)
    local p = {}
    local cur = inst
    while cur and cur ~= game do
        table.insert(p, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(p, ".")
end

add("=== AFTERMATH v3 PROBE ===")
add("place " .. tostring(game.PlaceId))
add("job " .. tostring(game.JobId))
add("time " .. os.date("%Y-%m-%d %H:%M:%S"))
add("")

add("--- 1. LOCAL RIG ---")
do
    local candidates = {}
    local char = LP.Character
    if char then
        candidates[#candidates + 1] = char
        add("LP.Character: " .. pathOf(char))
        add("  root: " .. tostring(char:FindFirstChild("HumanoidRootPart")))
        add("  humanoid: " .. tostring(char:FindFirstChildOfClass("Humanoid")))
    else
        add("LP.Character = nil")
    end
    local ents = Workspace:FindFirstChild("game_assets") and Workspace.game_assets:FindFirstChild("Entities")
    if ents then
        add("Entities children: " .. #ents:GetChildren())
        for _, m in ipairs(ents:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then
                add("  " .. m.Name .. "  fullName=" .. pathOf(m))
            end
        end
    else
        add("Entities folder MISSING")
    end
    add("camera mode: " .. tostring(LP.CameraMode))
    add("camera maxzoom: " .. tostring(LP.CameraMaxZoomDistance))
    add("camera minzoom: " .. tostring(LP.CameraMinZoomDistance))
    local cam = Workspace.CurrentCamera
    add("camera subject: " .. tostring(cam and cam.CameraSubject))
    if cam and cam.CameraSubject then
        add("camera subject class: " .. cam.CameraSubject.ClassName)
        if cam.CameraSubject:IsA("Humanoid") then
            pcall(function()
                add("camera humanoid parent: " .. pathOf(cam.CameraSubject.Parent))
            end)
        end
    end
end
add("")

add("--- 2. MOVEMENT / CHARACTER ---")
do
    local movement = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
    if movement then
        local ctrl = movement:FindFirstChild("ControlModule")
        if ctrl then
            local ok, v = pcall(function() return require(ctrl) end)
            add("ControlModule require: " .. tostring(ok and type(v) or v))
        end
    end

    local stats = LP:FindFirstChild("PlayerStats") or LP:FindFirstChild("Data") or LP:FindFirstChild("Stats")
    if stats then
        add("stats container: " .. pathOf(stats))
        for _, c in ipairs(stats:GetChildren()) do
            add("  " .. c.ClassName .. " " .. c.Name)
        end
    end

    add("BasePlayerStats attr on LP:")
    for _, name in ipairs({"WalkSpeedMultiplier","JumpPowerMultiplier","ClimbSpeedMultiplier","MaxStamina","MaxHunger","MaxThirst","MaxHealth","Health"}) do
        add("  " .. name .. " = " .. tostring(attr(LP, name)))
    end
end
add("")

add("--- 3. GUN SLOTS ---")
do
    local cnt = 0
    for _, d in ipairs(LP:GetDescendants()) do
        if d.Name == "InventorySlot" and d:IsA("ObjectValue") then
            cnt += 1
            add("  " .. pathOf(d) .. "  Value=" .. tostring(d.Value))
            if cnt >= 4 then break end
        end
    end
    add("inventory slots found: " .. cnt)
end
add("")

add("--- 4. CONSUMABLES ---")
do
    local inv = LP:FindFirstChild("Inventory") or LP:FindFirstChild("Backpack")
    if inv then
        add("inventory container: " .. pathOf(inv) .. "  (" .. #inv:GetChildren() .. " children)")
        for _, c in ipairs(inv:GetChildren()) do
            add("  " .. c.ClassName .. " " .. c.Name .. "  DisplayName=" .. tostring(attr(c, "DisplayName")))
        end
    else
        add("no Inventory/Backpack under LP")
    end
end
add("")

add("--- 5. ITEM SPAWNER ---")
do
    local lib = ReplicatedStorage:FindFirstChild("GunSystem") and ReplicatedStorage.GunSystem:FindFirstChild("GunLibrary")
    if lib then
        add("GunLibrary children:")
        for _, c in ipairs(lib:GetChildren()) do
            add("  " .. c.ClassName .. " " .. c.Name)
        end
    end
end
add("")

add("--- 6. VEHICLES ---")
do
    local cnt = 0
    for _, m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m.Name == "WorldModel" and m:FindFirstChild("States") then
            cnt += 1
            if cnt <= 3 then
                add("  " .. pathOf(m) .. "  Health=" .. tostring(attr(m:FindFirstChild("States"), "Health")))
            end
        end
    end
    add("vehicles: " .. cnt)
end
add("")

add("--- 7. GODMODE / REMOTES ---")
do
    local rs = ReplicatedStorage
    local gunSystem = rs:FindFirstChild("GunSystem")
    if gunSystem then
        local ev = gunSystem:FindFirstChild("Event")
        if ev then
            local ge = ev:FindFirstChild("GunEvent")
            if ge then
                add("GunEvent contents:")
                for _, c in ipairs(ge:GetChildren()) do
                    add("  " .. c.ClassName .. " " .. c.Name)
                end
            end
        end
    end
end
add("")

add("--- 8. WORKSPACE ROOT ---")
do
    add("workspace children (" .. #Workspace:GetChildren() .. "):")
    for _, c in ipairs(Workspace:GetChildren()) do
        add("  " .. c.ClassName .. " " .. c.Name)
    end
end

local body = table.concat(out, "\n")
print(body)

if writefile then
    pcall(writefile, "AftermathProbe.txt", body)
end
if setclipboard then
    pcall(setclipboard, body)
end

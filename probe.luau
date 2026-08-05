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
    if not inst then return "?" end
    local p = {}
    local cur = inst
    while cur and cur ~= game do
        table.insert(p, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(p, ".")
end

add("=== AFTERMATH v3 PROBE (build 2) ===")
add("place " .. tostring(game.PlaceId))
add("job " .. tostring(game.JobId))
add("time " .. os.date("%Y-%m-%d %H:%M:%S"))
add("")

add("--- 1. LOCAL RIG ---")
do
    local char = LP.Character
    if char then
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
                local root = m:FindFirstChild("HumanoidRootPart")
                local cam = Workspace.CurrentCamera
                local dist = cam and (root.Position - cam.CFrame.Position).Magnitude or 0
                add("  " .. m.Name .. "  dist=" .. string.format("%.1f", dist))
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
    end
end
add("")

add("--- 2. MOVEMENT / CHARACTER ---")
do
    add("attributes on LP (subset):")
    for _, name in ipairs({"WalkSpeedMultiplier","JumpPowerMultiplier","ClimbSpeedMultiplier","MaxStamina","MaxHunger","MaxThirst","MaxHealth","Health","Hunger","Thirst","Stamina","Bleeding","BrokenLeg","Infection"}) do
        add("  " .. name .. " = " .. tostring(attr(LP, name)))
    end

    local rs = ReplicatedStorage
    local gc = rs:FindFirstChild("GameConfig")
    if gc then
        local settings = gc:FindFirstChild("Settings")
        if settings then
            local bps = settings:FindFirstChild("BasePlayerStats")
            if bps then
                add("")
                add("BasePlayerStats at " .. pathOf(bps))
                for _, c in ipairs(bps:GetChildren()) do
                    add("  " .. c.ClassName .. " " .. c.Name)
                end
            end
        end
    end
end
add("")

add("--- 3. GUN SLOTS ---")
do
    local cnt = 0
    for _, d in ipairs(LP:GetDescendants()) do
        if d:IsA("ObjectValue") and d.Name == "InventorySlot" then
            cnt = cnt + 1
            add("  " .. pathOf(d) .. "  Value=" .. tostring(d.Value))
            if cnt >= 6 then break end
        end
    end
    add("LP.InventorySlot objects: " .. cnt)
    local ents = Workspace:FindFirstChild("game_assets") and Workspace.game_assets:FindFirstChild("Entities")
    if ents then
        local found = 0
        for _, m in ipairs(ents:GetChildren()) do
            if m:IsA("Model") then
                for _, d in ipairs(m:GetDescendants()) do
                    if d:IsA("ObjectValue") and d.Name == "InventorySlot" then
                        found = found + 1
                        add("  ENT " .. m.Name .. " -> " .. d:GetFullName() .. "  Value=" .. tostring(d.Value))
                        if found >= 6 then break end
                    end
                end
                if found >= 6 then break end
            end
        end
        add("Entities.InventorySlot objects: " .. found)
    end
end
add("")

add("--- 4. CONSUMABLES ---")
do
    local inv = LP:FindFirstChild("Inventory") or LP:FindFirstChild("Backpack")
    if inv then
        add("inventory container: " .. pathOf(inv) .. "  (" .. #inv:GetChildren() .. " children)")
        for _, c in ipairs(inv:GetChildren()) do
            add("  " .. c.ClassName .. " " .. c.Name)
        end
    else
        add("no Inventory/Backpack under LP")
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        add("backpack children: " .. #bp:GetChildren())
    end
end
add("")

add("--- 5. ITEM SPAWNER ---")
do
    local lib = ReplicatedStorage:FindFirstChild("Assets")
    if lib then
        local sd = lib:FindFirstChild("SpawnData")
        if sd then
            add("SpawnData children:")
            for _, c in ipairs(sd:GetChildren()) do
                add("  " .. c.ClassName .. " " .. c.Name .. "  (" .. (c:IsA("Folder") and #c:GetChildren() or 0) .. ")")
            end
            local refs = sd:FindFirstChild("ItemReferences")
            if refs then
                add("ItemReferences: " .. #refs:GetChildren())
            end
        end
    end
end
add("")

add("--- 6. VEHICLES ---")
do
    local v = 0
    for _, m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m.Name == "WorldModel" and m:FindFirstChild("States") then
            v = v + 1
            if v <= 4 then
                add("  " .. pathOf(m))
            end
        end
    end
    add("live WorldModel vehicles in workspace root: " .. v)

    local a = ReplicatedStorage:FindFirstChild("Assets")
    if a then
        local vdir = a:FindFirstChild("Vehicles")
        if vdir then
            add("vehicle library: " .. #vdir:GetChildren())
            for _, c in ipairs(vdir:GetChildren()) do
                if c:IsA("Folder") then
                    add("  " .. c.Name)
                end
            end
        end
    end
end
add("")

add("--- 7. GODMODE / REMOTES ---")
do
    local gunSystem = ReplicatedStorage:FindFirstChild("GunSystem")
    if gunSystem then
        local ev = gunSystem:FindFirstChild("Event")
        local ge = ev and ev:FindFirstChild("GunEvent")
        if ge then
            add("GunEvent children:")
            for _, c in ipairs(ge:GetChildren()) do
                add("  " .. c.ClassName .. " " .. c.Name)
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

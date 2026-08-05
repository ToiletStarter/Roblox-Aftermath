local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local out = {}

local function add(s) out[#out + 1] = tostring(s) end
local function attr(inst, name) local ok, v = pcall(inst.GetAttribute, inst, name) return ok and v or nil end
local function pathOf(inst) local p, cur = {}, inst while cur and cur ~= game do table.insert(p, 1, cur.Name) cur = cur.Parent end return table.concat(p, ".") end

add("=== BasePlayerStats hunt ===")

for _, d in ipairs(LP:GetDescendants()) do
    if d.Name == "BasePlayerStats" and d:IsA("Folder") then
        add("FOUND in LP descendants: " .. pathOf(d))
        for k, c in ipairs(d:GetChildren()) do add("  " .. c.ClassName .. " " .. c.Name) end
    end
end

local ents = Workspace:FindFirstChild("game_assets") and Workspace.game_assets:FindFirstChild("Entities")
if ents then
    for _, m in ipairs(ents:GetChildren()) do
        if m:IsA("Model") then
            local owner = attr(m, "Player")
            if owner and tostring(owner) == tostring(LP.UserId) then
                local bps = m:FindFirstChild("BasePlayerStats")
                if bps then add("FOUND under entity rig: " .. pathOf(bps)) end
            end
        end
    end
end

for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
    if d.Name == "BasePlayerStats" and d:IsA("Folder") then
        add("FOUND under ReplicatedStorage: " .. pathOf(d))
        for _, c in ipairs(d:GetChildren()) do add("  " .. c.ClassName .. " " .. c.Name) end
    end
end

add("")
add("=== gun slot ObjectValue deep search (LP+entity) ===")
local cnt = 0
local function scan(root, label)
    if not root then return end
    for _, d in ipairs(root:GetDescendants()) do
        if d.Name == "InventorySlot" and d:IsA("ObjectValue") then
            cnt += 1
            add(label .. " -> " .. pathOf(d) .. "  Value=" .. tostring(d.Value))
            if cnt >= 4 then return end
        end
    end
end
scan(LP, "LP")
if ents then
    local lpEntity
    for _, m in ipairs(ents:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then
            local owner = attr(m, "Player")
            local d = attr(m, "DisplayName")
            if owner and tostring(owner) == tostring(LP.UserId) then
                lpEntity = m
                break
            end
            if d and tostring(d) == LP.DisplayName then
                lpEntity = m
            end
        end
    end
    if lpEntity then
        scan(lpEntity, "ENTITY")
    end
end
add("total inventory slots: " .. cnt)

print(table.concat(out, "\n"))

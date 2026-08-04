local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local L = {}
local function say(s) L[#L+1] = s print(s) end

say("=== DEEP LINK HUNT ===")
say("Players: " .. #Players:GetPlayers())

local ga = Workspace:FindFirstChild("game_assets")
local ents = ga and ga:FindFirstChild("Entities")
say("Entities children: " .. (ents and #ents:GetChildren() or -1))
say("NOTE: 33 players but only 15 entity models -> player bodies are NOT all here")

-- Where do character-like models with a HumanoidRootPart actually live?
say("")
say("--- WHERE ARE CHARACTER RIGS IN THE WHOLE WORKSPACE? ---")
local buckets = {}
local scanned = 0
for _, d in ipairs(Workspace:GetDescendants()) do
    scanned = scanned + 1
    if scanned > 60000 then break end
    if d:IsA("Model") and d:FindFirstChild("HumanoidRootPart") then
        local parent = d.Parent
        local key = parent and parent:GetFullName() or "nil"
        buckets[key] = (buckets[key] or 0) + 1
    end
end
for k, v in pairs(buckets) do
    say(string.format("  %-60s %d rigs", k:sub(1, 60), v))
end

-- Does the local player have a body anywhere? Find it by proximity to camera.
say("")
say("--- LOCATE LOCAL BODY (nearest rig to camera) ---")
local cam = Workspace.CurrentCamera
if cam then
    local origin = cam.CFrame.Position
    local best, bestD
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Model") then
            local r = d:FindFirstChild("HumanoidRootPart")
            if r then
                local dist = (r.Position - origin).Magnitude
                if not bestD or dist < bestD then best, bestD = d, dist end
            end
        end
    end
    if best then
        say(string.format("nearest rig: %s  dist=%.1f", best:GetFullName(), bestD))
        say("  parent: " .. tostring(best.Parent and best.Parent:GetFullName()))
        say("  name looks like GUID: " .. tostring(best.Name:match("^{?%x%x%x%x%x%x%x%x") ~= nil))
        for _, c in ipairs(best:GetChildren()) do
            if c:IsA("ObjectValue") or c:IsA("StringValue") or c:IsA("IntValue") then
                say("  value child: " .. c.ClassName .. " " .. c.Name .. " = " .. tostring(c.Value))
            end
        end
        local ok, map = pcall(best.GetAttributes, best)
        if ok then for k, v in pairs(map) do say("  @attr " .. k .. " = " .. tostring(v)) end end
    end
end

-- Is there a client-side registry module holding the mapping?
say("")
say("--- SEARCH LOADED MODULES FOR A PLAYER REGISTRY ---")
if getloadedmodules then
    local hits = 0
    for _, m in ipairs(getloadedmodules()) do
        local n = m.Name:lower()
        if n:find("character") or n:find("player") or n:find("replication") or n:find("entity") then
            hits = hits + 1
            if hits <= 25 then say("  module: " .. m:GetFullName()) end
        end
    end
    say("  total candidate modules: " .. hits)
else
    say("  getloadedmodules unavailable")
end

-- Search the GC for a table mapping Player -> Model
say("")
say("--- GC SCAN: table mapping Player -> Model ---")
local scanner = (filtergc and "filtergc") or (getgc and "getgc") or nil
say("  scanner: " .. tostring(scanner))
if getgc then
    local found = 0
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" then
            local ok = pcall(function()
                for k, v in pairs(obj) do
                    if typeof(k) == "Instance" and k:IsA("Player")
                       and typeof(v) == "Instance" and v:IsA("Model") then
                        found = found + 1
                        if found <= 5 then
                            say(string.format("  MAP! [%s] -> %s", k.Name, v:GetFullName()))
                        end
                        error("done")
                    end
                    if typeof(v) == "Instance" and v:IsA("Player") and typeof(k) == "Instance" and k:IsA("Model") then
                        found = found + 1
                        if found <= 5 then
                            say(string.format("  REVERSE MAP! [%s] -> %s", k:GetFullName(), v.Name))
                        end
                        error("done")
                    end
                end
            end)
        end
        if found > 8 then break end
    end
    say("  player<->model tables found: " .. found)
end

local out = table.concat(L, "\n")
if writefile then writefile("AftermathDeep.txt", out) print("[deep] wrote AftermathDeep.txt") end
if setclipboard then pcall(setclipboard, out) end

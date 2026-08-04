local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local L = {}
local function say(s) L[#L+1] = tostring(s) print(s) end

say("===== AFTERMATH v3 FEATURE PROBE =====")

say("")
say("--- 1. LIGHTING OWNERSHIP (fullbright loop) ---")
local gc = ReplicatedStorage:FindFirstChild("GameConfig")
local settings = gc and gc:FindFirstChild("Settings")
local weather = settings and settings:FindFirstChild("Weather")
say("Weather config found: " .. tostring(weather ~= nil))
if weather then
    for k, v in pairs(weather:GetAttributes()) do
        say(string.format("   @%s = %s (%s)", k, tostring(v), typeof(v)))
    end
end
say("Lighting.ClockTime now: " .. tostring(Lighting.ClockTime))
say("Lighting.Brightness now: " .. tostring(Lighting.Brightness))
local helper = Workspace:FindFirstChild("DayNightLightingHelper")
say("DayNightLightingHelper in workspace: " .. tostring(helper ~= nil))

say("")
say("--- 2. LOCAL CHARACTER / MOVEMENT SURFACE ---")
local cam = Workspace.CurrentCamera
local myRig, myDist
if cam then
    local origin = cam.CFrame.Position
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Model") then
            local r = d:FindFirstChild("HumanoidRootPart")
            if r then
                local dist = (r.Position - origin).Magnitude
                if dist < 15 and (not myDist or dist < myDist) then
                    myRig, myDist = d, dist
                end
            end
        end
    end
end
say("local rig: " .. tostring(myRig and myRig:GetFullName() or "NOT FOUND"))
if myRig then
    say("  dist from camera: " .. string.format("%.2f", myDist))
    say("  children:")
    for _, c in ipairs(myRig:GetChildren()) do
        say("     " .. c.ClassName .. " : " .. c.Name)
    end
    local root = myRig:FindFirstChild("HumanoidRootPart")
    if root then
        say("  root class: " .. root.ClassName)
        say("  root anchored: " .. tostring(root.Anchored))
        say("  root velocity: " .. tostring(root.AssemblyLinearVelocity))
        say("  root constraints/children:")
        for _, c in ipairs(root:GetChildren()) do
            say("     " .. c.ClassName .. " : " .. c.Name)
        end
    end
    say("  rig attributes:")
    for k, v in pairs(myRig:GetAttributes()) do
        say(string.format("     @%s = %s", k, tostring(v)))
    end
end

say("")
say("--- 3. PLAYER ATTRIBUTES (self mods surface) ---")
for k, v in pairs(LP:GetAttributes()) do
    say(string.format("   @%-24s = %s (%s)", k, tostring(v), typeof(v)))
end

say("")
say("--- 4. BASE PLAYER STATS (server-side defaults) ---")
local bps = settings and settings:FindFirstChild("BasePlayerStats")
if bps then
    for k, v in pairs(bps:GetAttributes()) do
        say(string.format("   @%-26s = %s", k, tostring(v)))
    end
end

say("")
say("--- 5. CHARACTER CONTROLLER MODULES ---")
if getloadedmodules then
    local n = 0
    for _, m in ipairs(getloadedmodules()) do
        local full = m:GetFullName()
        if full:find("CustomCharacter") or full:find("Character") or full:find("Movement")
           or full:find("Stamina") or full:find("Camera") then
            n = n + 1
            if n <= 30 then say("   " .. full) end
        end
    end
    say("   total matching modules: " .. n)
else
    say("   getloadedmodules unavailable")
end

say("")
say("--- 6. GUN INVENTORY (weapon mods surface) ---")
local inv = LP:FindFirstChild("GunInventory")
say("GunInventory: " .. tostring(inv ~= nil))
if inv then
    local guns = inv:GetChildren()
    say("  gun entries: " .. #guns)
    local g = guns[1]
    if g then
        say("  sample gun: " .. g.Name .. " (" .. g.ClassName .. ")")
        say("    Value -> " .. tostring(g.Value and g.Value:GetFullName() or "nil"))
        for _, c in ipairs(g:GetChildren()) do
            local val = ""
            if c:IsA("ValueBase") then val = " = " .. tostring(c.Value) end
            say("    " .. c.ClassName .. " : " .. c.Name .. val)
        end
        for k, v in pairs(g:GetAttributes()) do
            say("    @attr " .. k .. " = " .. tostring(v))
        end
    end
end
say("CurrentSelected: " .. tostring(LP:FindFirstChild("CurrentSelected") and LP.CurrentSelected.Value))
local cso = LP:FindFirstChild("CurrentSelectedObject")
say("CurrentSelectedObject: " .. tostring(cso and cso.Value and cso.Value.Name or "nil"))

say("")
say("--- 7. GUN MODIFIER READBACK (do client writes stick?) ---")
local gs = ReplicatedStorage:FindFirstChild("GunSystem")
local ev = gs and gs:FindFirstChild("Event")
local mods = ev and ev:FindFirstChild("GunModifiers")
if mods then
    local readers = {}
    for _, m in ipairs(mods:GetChildren()) do
        if m:IsA("BindableFunction") then readers[#readers+1] = m end
    end
    for _, r in ipairs(readers) do
        local ok, val = pcall(function() return r:Invoke() end)
        say(string.format("   %-34s = %s", r.Name, ok and tostring(val) or "INVOKE FAILED"))
    end
end

say("")
say("--- 8. LOOT CONTAINERS (peek inside) ---")
local containers = {}
for _, c in ipairs(Workspace:GetChildren()) do
    if c:IsA("Model") and c.Name == "Container" then containers[#containers+1] = c end
end
say("workspace Containers: " .. #containers)
if containers[1] then
    local c = containers[1]
    say("  sample: " .. c.Name)
    for k, v in pairs(c:GetAttributes()) do say("    @" .. k .. " = " .. tostring(v)) end
    for _, ch in ipairs(c:GetChildren()) do say("    " .. ch.ClassName .. " : " .. ch.Name) end
end
local ga = Workspace:FindFirstChild("game_assets")
local spawns = ga and ga:FindFirstChild("item_spawns")
if spawns then
    local folders = spawns:GetChildren()
    say("item_spawns children: " .. #folders)
    local f = folders[1]
    if f then
        say("  sample group: " .. f.Name .. " (" .. f.ClassName .. ") kids=" .. #f:GetChildren())
        local first = f:GetChildren()[1]
        if first then
            say("    first: " .. first.Name .. " (" .. first.ClassName .. ")")
            for k, v in pairs(first:GetAttributes()) do say("      @" .. k .. " = " .. tostring(v)) end
        end
    end
end

local out = table.concat(L, "\n")
if writefile then
    pcall(writefile, "AftermathProbe3.txt", out)
    print("[probe] wrote AftermathProbe3.txt (" .. #out .. " bytes)")
end
if setclipboard then pcall(setclipboard, out) end

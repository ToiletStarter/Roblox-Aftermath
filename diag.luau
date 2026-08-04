local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

local lines = {}
local function say(s)
    lines[#lines + 1] = s
    print(s)
end

say("=== AFTERMATH ESP DIAGNOSTIC ===")

local ga = Workspace:FindFirstChild("game_assets")
local ents = ga and ga:FindFirstChild("Entities")
say("Entities folder: " .. tostring(ents ~= nil))
if not ents then
    if writefile then writefile("AftermathDiag.txt", table.concat(lines, "\n")) end
    return
end

local kids = ents:GetChildren()
say("Entities children: " .. #kids)
say("Players in server: " .. #Players:GetPlayers())

-- 1. Does LP.Character exist and where does it live?
say("")
say("--- LOCAL PLAYER ---")
say("LP.Character: " .. tostring(LP.Character and LP.Character:GetFullName() or "nil"))
if LP.Character then
    say("LP.Character.Parent: " .. tostring(LP.Character.Parent and LP.Character.Parent:GetFullName()))
    say("LP.Character in Entities: " .. tostring(LP.Character:IsDescendantOf(ents)))
end

-- 2. Union of attribute keys across entity models
say("")
say("--- ENTITY ATTRIBUTE KEYS (count across models) ---")
local keys = {}
for i, m in ipairs(kids) do
    local ok, map = pcall(m.GetAttributes, m)
    if ok and type(map) == "table" then
        for k, v in pairs(map) do
            keys[k] = keys[k] or { n = 0, sample = tostring(v), t = typeof(v) }
            keys[k].n = keys[k].n + 1
        end
    end
    if i > 150 then break end
end
local anyKey = false
for k, info in pairs(keys) do
    anyKey = true
    say(string.format("  %-22s x%-4d  type=%-10s eg=%s", k, info.n, info.t, info.sample:sub(1, 40)))
end
if not anyKey then say("  (no attributes on any entity model)") end

-- 3. How do we link a Player to a model? Try every plausible strategy.
say("")
say("--- PLAYER -> MODEL LINK STRATEGIES ---")

local function countMatches(label, fn)
    local n = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, res = pcall(fn, plr)
        if ok and res then n = n + 1 end
    end
    say(string.format("  %-34s matched %d/%d", label, n, #Players:GetPlayers()))
    return n
end

countMatches("Player.Character (direct)", function(p) return p.Character end)
countMatches("Character is under Entities", function(p)
    return p.Character and p.Character:IsDescendantOf(ents) or nil
end)
countMatches("Entities child named plr.Name", function(p) return ents:FindFirstChild(p.Name) end)
countMatches("model attr 'Player' == plr", function(p)
    for _, m in ipairs(kids) do
        if m:GetAttribute("Player") == p then return m end
    end
    return nil
end)
countMatches("model attr 'UserId' == plr.UserId", function(p)
    for _, m in ipairs(kids) do
        if m:GetAttribute("UserId") == p.UserId then return m end
    end
    return nil
end)
countMatches("model attr 'Owner' == plr", function(p)
    for _, m in ipairs(kids) do
        if m:GetAttribute("Owner") == p then return m end
    end
    return nil
end)
countMatches("ObjectValue child -> Player", function(p)
    for _, m in ipairs(kids) do
        for _, c in ipairs(m:GetChildren()) do
            if c:IsA("ObjectValue") and c.Value == p then return m end
        end
    end
    return nil
end)

-- 4. What is actually inside an entity model?
say("")
say("--- SAMPLE ENTITY STRUCTURE (first 3) ---")
for i = 1, math.min(3, #kids) do
    local m = kids[i]
    say(string.format("[%d] %s (%s)", i, m.Name, m.ClassName))
    local shown = 0
    for _, c in ipairs(m:GetChildren()) do
        shown = shown + 1
        if shown <= 12 then
            say("      " .. c.ClassName .. " : " .. c.Name)
        end
    end
    if shown > 12 then say("      ... +" .. (shown - 12) .. " more") end
    local ok, map = pcall(m.GetAttributes, m)
    if ok then
        for k, v in pairs(map) do
            say("      @attr " .. k .. " = " .. tostring(v) .. " (" .. typeof(v) .. ")")
        end
    end
end

-- 5. Which models would my current isCharacterModel() accept?
say("")
say("--- CLASSIFICATION ---")
local charLike, withHum, withAnim = 0, 0, 0
for _, m in ipairs(kids) do
    if m:IsA("Model") then
        local h = m:FindFirstChild("Humanoid")
        local a = m:FindFirstChildOfClass("AnimationController")
        if h then withHum = withHum + 1 end
        if a then withAnim = withAnim + 1 end
        if h or a then charLike = charLike + 1 end
    end
end
say("  models with child named 'Humanoid': " .. withHum)
say("  models with AnimationController:    " .. withAnim)
say("  character-like total:               " .. charLike)

-- 6. Root part resolution
say("")
say("--- ROOT PART RESOLUTION ---")
local rootOk, rootFail = 0, 0
local failNames = {}
for _, m in ipairs(kids) do
    if m:IsA("Model") then
        local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
              or m:FindFirstChildWhichIsA("BasePart")
        if r then rootOk = rootOk + 1
        else
            rootFail = rootFail + 1
            if #failNames < 5 then failNames[#failNames + 1] = m.Name end
        end
    end
end
say("  resolved: " .. rootOk .. "   failed: " .. rootFail)
if #failNames > 0 then say("  failures: " .. table.concat(failNames, ", ")) end

local out = table.concat(lines, "\n")
if writefile then
    writefile("AftermathDiag.txt", out)
    print("[diag] wrote AftermathDiag.txt (" .. #out .. " bytes)")
end
if setclipboard then
    pcall(setclipboard, out)
    print("[diag] copied to clipboard")
end

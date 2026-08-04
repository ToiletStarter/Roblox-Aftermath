local REPO = "ToiletStarter/Roblox-Aftermath"
local FILE = "script.txt"

local function get(url)
    local ok, body = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and type(body) == "string" and #body > 0 then
        return body
    end
    return nil
end

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Aftermath Loader",
            Text = text,
            Duration = 8,
        })
    end)
end

local sha
local meta = get("https://api.github.com/repos/" .. REPO .. "/commits/main")
if meta then
    sha = meta:match('"sha"%s*:%s*"(%x+)"')
end

local sources = {}
if sha then
    sources[#sources + 1] = "https://raw.githubusercontent.com/" .. REPO .. "/" .. sha .. "/" .. FILE
    sources[#sources + 1] = "https://cdn.jsdelivr.net/gh/" .. REPO .. "@" .. sha .. "/" .. FILE
end
sources[#sources + 1] = "https://raw.githubusercontent.com/" .. REPO .. "/refs/heads/main/" .. FILE
    .. "?cb=" .. tostring(os.time())
sources[#sources + 1] = "https://cdn.jsdelivr.net/gh/" .. REPO .. "@main/" .. FILE

local source, usedIndex
for i, url in ipairs(sources) do
    source = get(url)
    if source then
        usedIndex = i
        break
    end
end

if not source then
    notify("Could not download the script. Check your connection.")
    return error("[Aftermath] all sources failed", 0)
end

local chunk, compileErr = loadstring(source)
if not chunk then
    notify("Downloaded script failed to compile.")
    return error("[Aftermath] compile: " .. tostring(compileErr), 0)
end

local version = source:match('VERSION%s*=%s*"([^"]+)"') or "?"
print(string.format("[Aftermath] loading v%s (%s, source %d)",
    version, sha and sha:sub(1, 7) or "branch", usedIndex or 0))

local ok, err = pcall(chunk)
if not ok then
    notify("Script error: " .. tostring(err))
    return error("[Aftermath] runtime: " .. tostring(err), 0)
end

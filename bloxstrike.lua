local ok, err = pcall(function()
    local BASE = "https://raw.githubusercontent.com/dyxmy49-dev/bs/main"
    local function get(url)
        if syn and syn.request then return syn.request({Url=url,Method="GET"}).Body end
        if http and http.request then return http.request({Url=url,Method="GET"}).Body end
        if game and game.HttpGet then return game:HttpGet(url) end
        error("No HTTP function")
    end
    print("[BS] Fetching main.lua...")
    local src = get(BASE.."/main.lua")
    print("[BS] Got main.lua, running...")
    assert(loadstring(src, "@main.lua"))({baseUrl=BASE, DEFAULT_BASE_URL=BASE})
end)
if not ok then
    warn("[BS] Error: "..tostring(err))
    print("[BS] Error: "..tostring(err))
end
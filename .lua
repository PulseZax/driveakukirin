--hello skidder / discord.gg/pulsezone

local PULSE_VERSION = "v1.0"
local G = (getgenv and getgenv()) or _G
if type(G.__pulseKuk) == "table" and type(G.__pulseKuk.unload) == "function" then
    pcall(G.__pulseKuk.unload)
end
local K = { alive = true, conns = {}, busy = false, task = "Idle" }
G.__pulseKuk = K

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local Remotes = RS:WaitForChild("ScooterRemotes", 30)

local function conn(sig, fn)
    local c = sig:Connect(fn)
    table.insert(K.conns, c)
    return c
end

local Nova = (function()
            local Nova = { Version = "1.0.0", Windows = {}, Conns = {} }

            function Nova.tr(text)
                return text
            end

            function Nova.trace(msg)
                local ok, g = pcall(getgenv)
                if ok and g and g.NOVA_TRACE and appendfile then
                    pcall(appendfile, "PulseHub/nova_trace.txt", string.format("%.3f %s\n", os.clock(), tostring(msg)))
                end
            end

            local Players = game:GetService("Players")
            local TweenService = game:GetService("TweenService")
            local UserInputService = game:GetService("UserInputService")
            local RunService = game:GetService("RunService")
            local TextService = game:GetService("TextService")
            local HttpService = game:GetService("HttpService")
            local Lighting = game:GetService("Lighting")
            local LocalPlayer = Players.LocalPlayer

            Nova.Services = { Players = Players, TweenService = TweenService, UserInputService = UserInputService, RunService = RunService, TextService = TextService, HttpService = HttpService, Lighting = Lighting }

            do
                local U = {}
                Nova.U = U

                local regs, strikes = {}, {}

                function U.newReg()
                    local t = {}
                    table.insert(regs, t)
                    return t
                end

                local function regAlive(inst, pc)
                    local par = inst.Parent
                    if par == nil then return false end
                    local v = pc[par]
                    if v == nil then
                        v = inst:FindFirstAncestorWhichIsA("ScreenGui") ~= nil
                        pc[par] = v
                    end
                    return v
                end

                function U.sweep()
                    local items = {}
                    for _, t in ipairs(regs) do
                        for inst in pairs(t) do
                            items[#items + 1] = inst
                            items[#items + 1] = t
                        end
                    end
                    local pc = {}
                    local t0 = os.clock()
                    for i = 1, #items, 2 do
                        local inst, t = items[i], items[i + 1]
                        if t[inst] ~= nil then
                            local okc, ok = pcall(regAlive, inst, pc)
                            if okc and ok then
                                strikes[inst] = nil
                            elseif strikes[inst] then
                                t[inst] = nil
                                strikes[inst] = nil
                            else
                                strikes[inst] = true
                            end
                        end
                        if os.clock() - t0 > 0.001 then
                            task.wait()
                            t0 = os.clock()
                            pc = {}
                        end
                    end
                end

                function U.regCount()
                    local n = 0
                    for _, t in ipairs(regs) do
                        for _ in pairs(t) do n += 1 end
                    end
                    return n
                end

                function U.startSweep()
                    if U.sweeping then return end
                    U.sweeping = true
                    task.spawn(function()
                        while true do
                            task.wait(15)
                            local any = false
                            for _, w in ipairs(Nova.Windows) do
                                if not w.Destroyed then any = true end
                            end
                            U.sweep()
                            if not any then
                                U.sweeping = false
                                return
                            end
                        end
                    end)
                end

                U.textReg = U.newReg()
                U.cornerReg = U.newReg()
                U.radiusMult = 1
                U.textScale = 1
                local TEXT_CLASS = { TextLabel = true, TextButton = true, TextBox = true }

                function U.new(class, props, children)
                    local inst = Instance.new(class)
                    local parent
                    for k, v in pairs(props or {}) do
                        if k == "Parent" then
                            parent = v
                        else
                            inst[k] = v
                        end
                    end
                    for _, child in ipairs(children or {}) do
                        child.Parent = inst
                    end
                    if TEXT_CLASS[class] then
                        local ff = inst.FontFace
                        local base = inst.TextSize
                        U.textReg[inst] = { weight = ff.Weight, style = ff.Style, size = base }
                        if U.textScale ~= 1 then inst.TextSize = math.max(8, math.floor(base * U.textScale + 0.5)) end
                    elseif class == "UICorner" then
                        local base = inst.CornerRadius
                        U.cornerReg[inst] = base
                        if U.radiusMult ~= 1 and base.Scale == 0 then
                            inst.CornerRadius = UDim.new(0, math.floor(base.Offset * U.radiusMult + 0.5))
                        end
                    end
                    if parent then inst.Parent = parent end
                    return inst
                end

                function U.setTextSize(inst, size)
                    local info = U.textReg[inst]
                    if info then info.size = size end
                    inst.TextSize = math.max(8, math.floor(size * U.textScale + 0.5))
                end

                function U.corner(parent, radius)
                    return U.new("UICorner", { CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius or 8), Parent = parent })
                end

                function U.radiusOne(inst)
                    local base = U.cornerReg[inst]
                    if base and base.Scale == 0 then
                        inst.CornerRadius = UDim.new(0, math.floor(base.Offset * U.radiusMult + 0.5))
                    end
                end

                function U.setRadius(mult)
                    U.radiusMult = math.clamp(mult, 0, 2)
                    Nova.Refresh.run("radius", U.radiusOne, function()
                        for inst in pairs(U.cornerReg) do
                            if inst.Parent then U.radiusOne(inst) end
                        end
                    end)
                end

                function U.stroke(parent, color, thickness, transparency, mode)
                    return U.new("UIStroke", {
                        Color = color or Color3.new(1, 1, 1),
                        Thickness = thickness or 1,
                        Transparency = transparency or 0,
                        ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border,
                        Parent = parent,
                    })
                end

                function U.pad(parent, top, right, bottom, left)
                    return U.new("UIPadding", {
                        PaddingTop = UDim.new(0, top or 0),
                        PaddingRight = UDim.new(0, right or top or 0),
                        PaddingBottom = UDim.new(0, bottom or top or 0),
                        PaddingLeft = UDim.new(0, left or right or top or 0),
                        Parent = parent,
                    })
                end

                function U.list(parent, padding, direction, halign, valign)
                    return U.new("UIListLayout", {
                        Padding = UDim.new(0, padding or 0),
                        FillDirection = direction or Enum.FillDirection.Vertical,
                        HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
                        VerticalAlignment = valign or Enum.VerticalAlignment.Top,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = parent,
                    })
                end

                function U.shadow(parent, transparency, blur, offsetY, spread)
                    local ok, s = pcall(function()
                        return U.new("UIShadow", {
                            Color = Color3.new(0, 0, 0),
                            Transparency = transparency or 0.5,
                            BlurRadius = UDim.new(0, blur or 12),
                            Offset = UDim2.fromOffset(0, offsetY or 2),
                            Spread = UDim2.fromOffset(spread or 0, spread or 0),
                            Parent = parent,
                        })
                    end)
                    return ok and s or nil
                end

                function U.clamp(v, a, b)
                    if v < a then return a end
                    if v > b then return b end
                    return v
                end

                function U.round(v, decimals)
                    local m = 10 ^ (decimals or 0)
                    return math.floor(v * m + 0.5) / m
                end

                function U.fmt(v, decimals)
                    decimals = decimals or 0
                    if decimals <= 0 then return tostring(math.floor(v + 0.5)) end
                    return string.format("%." .. decimals .. "f", v)
                end

                function U.textWidth(text, font, size)
                    local ok, res = pcall(function()
                        local params = Instance.new("GetTextBoundsParams")
                        params.Text = tostring(text)
                        params.Font = font
                        params.Size = size
                        params.Width = 10000
                        return TextService:GetTextBoundsAsync(params)
                    end)
                    if ok and res then return res.X end
                    return #tostring(text) * size * 0.5
                end

                function U.connect(signal, fn, bucket)
                    local conn = signal:Connect(fn)
                    table.insert(bucket or Nova.Conns, conn)
                    return conn
                end

                function U.hostGui()
                    local host
                    pcall(function() if gethui then host = gethui() end end)
                    if typeof(host) ~= "Instance" then
                        pcall(function() host = game:GetService("CoreGui") end)
                        local ok = pcall(function()
                            local probe = Instance.new("Folder")
                            probe.Parent = host
                            probe:Destroy()
                        end)
                        if not ok then host = nil end
                    end
                    if typeof(host) ~= "Instance" then host = LocalPlayer:WaitForChild("PlayerGui") end
                    return host
                end

                function U.protect(gui)
                    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
                    pcall(function() if protectgui then protectgui(gui) end end)
                end

                function U.lighten(c, amount)
                    local h, s, v = c:ToHSV()
                    return Color3.fromHSV(h, math.max(0, s - amount * 0.35), math.min(1, v + amount))
                end

                function U.darken(c, amount)
                    local h, s, v = c:ToHSV()
                    return Color3.fromHSV(h, s, math.max(0, v - amount))
                end

                function U.mouse()
                    return UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
                end

                function U.leave(gui, fn)
                    local conn = gui.MouseLeave:Connect(fn)
                    gui.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then task.delay(0.12, fn) end
                    end)
                    return conn
                end

                function U.isClick(input)
                    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
                end

                function U.isMove(input)
                    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
                end

                function U.sameMove(input, began)
                    if began and began.UserInputType == Enum.UserInputType.Touch then return input == began end
                    if began then return input.UserInputType == Enum.UserInputType.MouseMovement end
                    return U.isMove(input)
                end

                function U.sameEnd(input, began)
                    if began and began.UserInputType == Enum.UserInputType.Touch then return input == began end
                    return U.isClick(input)
                end

                function U.at(began)
                    if began and began.UserInputType == Enum.UserInputType.Touch then return Vector2.new(began.Position.X, began.Position.Y) end
                    return U.mouse()
                end
            end

            do
                local M = {}
                Nova.Motion = M
                local U = Nova.U

                M.Presets = {
                    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    Base = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    Slow = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    Pop = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    PopSmall = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    Exit = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    Linear = TweenInfo.new(0.2, Enum.EasingStyle.Linear),
                    Spin = TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, -1),
                }
                M.enabled = true

                function M.tween(inst, info, props)
                    if typeof(inst) ~= "Instance" then return nil end
                    if type(info) == "string" then info = M.Presets[info] or M.Presets.Base end
                    if not M.enabled then
                        for k, v in pairs(props) do pcall(function() inst[k] = v end) end
                        return nil
                    end
                    local ok, tw = pcall(TweenService.Create, TweenService, inst, info, props)
                    if ok and tw then
                        tw:Play()
                        return tw
                    end
                    for k, v in pairs(props) do pcall(function() inst[k] = v end) end
                    return nil
                end

                function M.ripple(parent, color, fromMouse)
                    if not M.enabled or typeof(parent) ~= "Instance" then return end
                    local abs, size = parent.AbsolutePosition, parent.AbsoluteSize
                    local point = size / 2
                    if fromMouse then
                        local m = U.mouse()
                        point = Vector2.new(U.clamp(m.X - abs.X, 0, size.X), U.clamp(m.Y - abs.Y, 0, size.Y))
                    end
                    local reach = math.max(size.X, size.Y) * 1.6
                    local ring = U.new("Frame", {
                        Name = "Ripple",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromOffset(point.X, point.Y),
                        Size = UDim2.fromOffset(4, 4),
                        BackgroundColor3 = color or Color3.new(1, 1, 1),
                        BackgroundTransparency = 0.8,
                        ZIndex = parent.ZIndex + 5,
                        Parent = parent,
                    })
                    U.corner(ring, UDim.new(1, 0))
                    M.tween(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(reach, reach), BackgroundTransparency = 1 })
                    task.delay(0.5, function() ring:Destroy() end)
                end
            end

            do
                local R = { gen = 0, names = {}, full = {}, busy = 0, budget = 0.003 }
                Nova.Refresh = R

                local function roots()
                    local out = {}
                    for _, w in ipairs(Nova.Windows or {}) do
                        if not w.Destroyed and w.Gui and w.Gui.Parent then out[#out + 1] = w.Gui end
                    end
                    return out
                end

                function R.run(name, fn, fallback)
                    R.gen += 1
                    R.names[name] = (R.names[name] or 0) + 1
                    local my = R.names[name]
                    local list = roots()
                    if #list == 0 then
                        if fallback then fallback() end
                        return
                    end
                    R.busy += 1
                    task.spawn(function()
                        local t0 = os.clock()
                        for _, root in ipairs(list) do
                            local items = root:GetDescendants()
                            for i = 1, #items do
                                if R.names[name] ~= my then
                                    R.busy -= 1
                                    return
                                end
                                fn(items[i])
                                if i % 40 == 0 and os.clock() - t0 > R.budget then
                                    task.wait()
                                    t0 = os.clock()
                                end
                            end
                        end
                        R.busy -= 1
                    end)
                end

                function R.sync(root)
                    if not root then return end
                    local items = root:GetDescendants()
                    items[#items + 1] = root
                    for _, fn in ipairs(R.full) do
                        for i = 1, #items do fn(items[i]) end
                    end
                end
            end

            do
                local T = { registry = Nova.U.newReg(), listeners = {} }
                Nova.Theme = T

                T.Presets = {
                    Crimson = Color3.fromHex("d64458"),
                    Ember = Color3.fromHex("ff7a3d"),
                    Gold = Color3.fromHex("f5b94a"),
                    Mint = Color3.fromHex("3ddc97"),
                    Ocean = Color3.fromHex("3d9bff"),
                    Violet = Color3.fromHex("8b6cff"),
                    Rose = Color3.fromHex("ff5fa2"),
                    Ice = Color3.fromHex("7fe0ff"),
                }

                T.tokens = {
                    Background = Color3.fromHex("0c0d10"),
                    Sidebar = Color3.fromHex("0f1014"),
                    Surface = Color3.fromHex("14161b"),
                    Surface2 = Color3.fromHex("1b1e25"),
                    Elevated = Color3.fromHex("22252d"),
                    Line = Color3.fromHex("1f2229"),
                    Text = Color3.fromHex("eceef3"),
                    Muted = Color3.fromHex("8a8f9e"),
                    Faint = Color3.fromHex("575c69"),
                    Accent = T.Presets.Crimson,
                    OnAccent = Color3.fromHex("ffffff"),
                    Success = Color3.fromHex("3ddc97"),
                    Warning = Color3.fromHex("f5b94a"),
                    Danger = Color3.fromHex("f0506e"),
                    Glass = Color3.fromHex("ffffff"),
                }

                local function resolve(token)
                    if typeof(token) == "Color3" then return token end
                    if type(token) == "function" then return token(T.tokens) end
                    return T.tokens[token] or T.tokens.Text
                end
                T.resolve = resolve

                function T.bind(inst, prop, token)
                    if typeof(inst) ~= "Instance" then return inst end
                    local map = T.registry[inst]
                    if not map then
                        map = {}
                        T.registry[inst] = map
                    end
                    map[prop] = token
                    pcall(function() inst[prop] = resolve(token) end)
                    return inst
                end

                local function applyOne(inst, match)
                    local m = T.registry[inst]
                    if not m then return end
                    for prop, token in pairs(m) do
                        if not match or match(token) then
                            local ok, value = pcall(resolve, token)
                            if ok and value ~= nil then pcall(function() inst[prop] = value end) end
                        end
                    end
                end
                T.applyOne = applyOne

                local function applyLater(match, channel)
                    Nova.Refresh.run("theme:" .. tostring(channel or "all"), function(inst) applyOne(inst, match) end, function()
                        for inst in pairs(T.registry) do
                            if inst.Parent then applyOne(inst, match) end
                        end
                    end)
                end

                function T.set(key, color)
                    if typeof(color) ~= "Color3" then return end
                    T.tokens[key] = color
                    applyLater(function(token) return token == key or type(token) == "function" end, "one:" .. tostring(key))
                    for _, fn in ipairs(T.listeners) do pcall(fn, key, color) end
                end

                function T.setMany(map)
                    for k, c in pairs(map) do
                        if typeof(c) == "Color3" then T.tokens[k] = c end
                    end
                    local keys = {}
                    for k in pairs(map) do keys[#keys + 1] = tostring(k) end
                    table.sort(keys)
                    applyLater(function(token) return type(token) == "function" or (type(token) == "string" and map[token] ~= nil) end, "many:" .. table.concat(keys, ","))
                    for _, fn in ipairs(T.listeners) do
                        for k, c in pairs(map) do pcall(fn, k, c) end
                    end
                end

                T.Bases = {
                    { "Midnight", { Background = "0c0d10", Sidebar = "0f1014", Surface = "14161b", Surface2 = "1b1e25", Elevated = "22252d", Line = "1f2229", Text = "eceef3", Muted = "8a8f9e", Faint = "575c69" } },
                    { "Graphite", { Background = "111214", Sidebar = "141517", Surface = "1a1b1e", Surface2 = "232427", Elevated = "2b2d31", Line = "2a2c30", Text = "f0f1f3", Muted = "9a9da4", Faint = "62656c" } },
                    { "Amoled", { Background = "000000", Sidebar = "040405", Surface = "0b0c0e", Surface2 = "111216", Elevated = "181a1f", Line = "16181c", Text = "f2f3f6", Muted = "8f94a1", Faint = "545965" } },
                    { "Deep Sea", { Background = "090d13", Sidebar = "0b1119", Surface = "101823", Surface2 = "162131", Elevated = "1d2b3e", Line = "1a2433", Text = "e8eef8", Muted = "8794ab", Faint = "55627a" } },
                    { "Plum", { Background = "0e0b12", Sidebar = "110d16", Surface = "17121d", Surface2 = "1f1927", Elevated = "271f32", Line = "221b2b", Text = "efe9f6", Muted = "9a8fa8", Faint = "625870" } },
                    { "Forest", { Background = "0b0f0d", Sidebar = "0d1210", Surface = "121815", Surface2 = "19211d", Elevated = "202a25", Line = "1c241f", Text = "e9f0ec", Muted = "8a9a92", Faint = "56645d" } },
                }
                T.base = "Midnight"

                function T.setBase(name)
                    for _, b in ipairs(T.Bases) do
                        if b[1] == name then
                            local map = {}
                            for k, hex in pairs(b[2]) do map[k] = Color3.fromHex(hex) end
                            T.setMany(map)
                            T.base = name
                            return true
                        end
                    end
                    return false
                end

                function T.panelFrom(c)
                    local h, s, v = c:ToHSV()
                    s = math.min(s, 0.9)
                    v = math.clamp(v, 0.025, 0.3)
                    local function tone(dv, ds)
                        return Color3.fromHSV(h, math.clamp(s * (ds or 1), 0, 1), math.clamp(v + dv, 0, 1))
                    end
                    return {
                        Background = tone(0),
                        Sidebar = tone(0.014),
                        Surface = tone(0.042),
                        Surface2 = tone(0.08, 0.92),
                        Elevated = tone(0.112, 0.86),
                        Line = tone(0.096, 0.9),
                        Text = Color3.fromHSV(h, s * 0.07, 0.95),
                        Muted = Color3.fromHSV(h, s * 0.16, 0.62),
                        Faint = Color3.fromHSV(h, s * 0.18, 0.41),
                    }
                end

                function T.onChange(fn)
                    table.insert(T.listeners, fn)
                end

                function T.accentSoft(amount)
                    return function(tokens)
                        return tokens.Surface2:Lerp(tokens.Accent, amount)
                    end
                end
            end

            do
                local F = {}
                Nova.Font = F
                local U = Nova.U

                F.Families = {
                    { "Builder Sans", "BuilderSans" },
                    { "Montserrat", "Montserrat" },
                    { "Nunito", "Nunito" },
                    { "Roboto", "Roboto" },
                    { "Ubuntu", "Ubuntu" },
                    { "Titillium Web", "TitilliumWeb" },
                    { "Josefin Sans", "JosefinSans" },
                    { "Jura", "Jura" },
                    { "Source Sans", "SourceSansPro" },
                    { "Oswald", "Oswald" },
                    { "Roboto Mono", "RobotoMono" },
                    { "Michroma", "Michroma" },
                }
                F.name = "Builder Sans"
                F.id = "BuilderSans"
                local cache = {}

                local function path(id)
                    return "rbxasset://fonts/families/" .. id .. ".json"
                end

                function F.get(weight, style)
                    weight = weight or Enum.FontWeight.Medium
                    style = style or Enum.FontStyle.Normal
                    local key = F.id .. "|" .. weight.Name .. "|" .. style.Name
                    if not cache[key] then
                        local ok, font = pcall(Font.new, path(F.id), weight, style)
                        cache[key] = ok and font or Font.fromEnum(Enum.Font.GothamMedium)
                    end
                    return cache[key]
                end
                F.Regular = function() return F.get(Enum.FontWeight.Regular) end
                F.Medium = function() return F.get(Enum.FontWeight.Medium) end
                F.Semi = function() return F.get(Enum.FontWeight.SemiBold) end
                F.Bold = function() return F.get(Enum.FontWeight.Bold) end
                F.Heavy = function() return F.get(Enum.FontWeight.ExtraBold) end

                function F.fontOne(inst)
                    local info = U.textReg[inst]
                    if info then pcall(function() inst.FontFace = F.get(info.weight, info.style) end) end
                end

                function F.sizeOne(inst)
                    local info = U.textReg[inst]
                    if info then pcall(function() inst.TextSize = math.max(8, math.floor(info.size * U.textScale + 0.5)) end) end
                end

                function F.setFamily(display)
                    for _, f in ipairs(F.Families) do
                        if f[1] == display or f[2] == display then
                            F.name, F.id = f[1], f[2]
                            Nova.Refresh.run("font", F.fontOne, function()
                                for inst in pairs(U.textReg) do if inst.Parent then F.fontOne(inst) end end
                            end)
                            return true
                        end
                    end
                    return false
                end

                function F.setScale(mult)
                    U.textScale = math.clamp(mult, 0.8, 1.3)
                    Nova.Refresh.run("textsize", F.sizeOne, function()
                        for inst in pairs(U.textReg) do if inst.Parent then F.sizeOne(inst) end end
                    end)
                end
            end

            do
                local I = { module = nil, tried = false, waiting = {} }
                Nova.Icons = I
                local LUCIDE_SHEETS = { "rbxassetid://104502745253902", "rbxassetid://89421818506275" }
                local LUCIDE_RECT = Vector2.new(24, 24)
                local LUCIDE_N = "align-vertical-distribute-center,chevron-down,list-restart,table-cells-split,gavel,dna-off,refresh-ccw-dot,venus,bean,circle-question-mark,folder-code,bolt,heater,feather,align-horizontal-distribute-center,grip-vertical,pill-bottle,person-standing,badge-swiss-franc,between-horizontal-end,file-braces-corner,rotate-cw,house-plus,bus-front,shield-ellipsis,between-vertical-end,globe-lock,tags,concierge-bell,bookmark-minus,plant-pot,file-down,picture-in-picture,messages-square,scissors,file-check-corner,phone-call,anchor,hand-helping,text-wrap,birdhouse,wifi-off,cloud-alert,message-square,cloud-download,folder-plus,cctv-off,notebook-dot,mirror-round,user-round,pointer,between-horizontal-start,chevrons-up-down,brush,message-circle-more,parentheses,book-up-2,flame,chevrons-up,square-dashed,square-mouse-pointer,superscript,signal,wifi-cog,hexagon,navigation-2-off,eye-off,arrows-up-from-line,file-code-corner,square-centerline-dashed-horizontal,panels-right-bottom,scaling,hash,arrow-left-from-line,ship,ticket-percent,calendar-clock,x,non-binary,voicemail,presentation,tree-palm,badge,captions-off,align-vertical-justify-center,download,mouse-right,lens-convex,shrimp-off,focus,diamond-percent,arrow-big-up,volume-x,mouse-pointer-click,face-slightly-smiling-plus,hard-drive,grid-2x2-x,package-minus,cloud,pipette,corner-left-down,badge-cent,cloud-lightning,user-round-pen,arrow-left-to-line,book-open-text,monitor-cloud,parking-meter,cat,heart-handshake,dam,trees,ham,circle-pause,chess-king,bean-off,clef-alto,separator-horizontal,ambulance,globe-code,citrus,phone-missed,calendar-off,chart-column,battery-medium,square-minus,star-check,decimals-arrow-left,folder-output,menu,bangladeshi-taka,image-down,terminal,building-complex-plus,circle-dot-dashed,medal,cake-slice,git-graph,armchair,tickets,qr-code,copy,goal,book-bookmark,trending-down,creative-commons,layers-arrow-down,ev-charger,user-star,road,nfc,align-center-horizontal,car,notebook-tabs,ear,videotape,sun-moon,chart-scatter,podium,toolbox,calendar,calendar-cog,gallery-horizontal,clipboard-x,list-sort-ascending,book-open,circle-pile,rectangle-ellipsis,badge-plus,badge-info,file-headphone,bow-arrow,clipboard-pen-line,user-round-key,folder-search,utensils-crossed,arrow-up,arrow-up-from-dot,align-vertical-justify-start,layers-minus,pause,shrub,flag,biceps-flexed,align-horizontal-distribute-end,donut,calendar-plus-2,move-vertical,file-pen-line,badge-russian-ruble,radius,pilcrow,corner-left-up,georgian-lari,cable,book-user,square-arrow-down,circle-plus,view,cctv,circle-arrow-left,square-off,octagon-alert,panel-bottom-dashed,book-a,align-end-vertical,thumbs-up,globe,rabbit,layers-plus,door-stairwell,banknote-arrow-down,message-square-off,dice-4,message-circle-x,folder-x,message-circle-warning,map,move,arrow-up-left,award,arrow-down-wide-narrow,unfold-horizontal,lens-concave,zoom-out,motorbike,music-4,zoom-in,shield-x,file-volume,disc-3,file-signal,columns-4,archive-x,zodiac-virgo,square-dashed-kanban,mouse-pointer-2,clock-arrow-up,clock-fading,pencil-sparkles,library-big,vegan,star-plus,file-check,clef-bass,message-circle-plus,user-key,credit-card-plus,zodiac-pisces,fast-forward,user-pen,chess-knight,wifi-pen,files,send-to-back,alarm-clock,microscope,zodiac-libra,zodiac-leo,zodiac-gemini,shopping-basket,send,smartphone,square-dashed-bottom,zodiac-aries,zodiac-aquarius,land-plot,wind-arrow-down,germ-off,brush-cleaning,skip-back,x-line-top,book-audio,octagon-minus,file-scan,cupcake,midi-port,message-square-dashed,shield-check,worm,chevrons-left,workflow,umbrella,skip-forward,clipboard-copy,map-pin-off,arrow-up-from-line,circle-chevron-up,wine-off,wine,circle-small,align-vertical-space-between,lamp-desk,circle-arrow-up,zap,beaker,timeline,panel-left-right-dashed,wifi-sync,paintbrush,sliders-vertical,broccoli,wifi-high,wifi,chevron-up,triangles-centerline-dashed-horizontal,whistle,pen-tool,database-check,wheat-off,form,pencil-ruler,dna,arrow-big-down-dash,chart-area,bug-off,wheat,weight-tilde,card-sim,weight,server-crash,map-pin-search,flask-round,eye-dashed,webcam-off,ellipse,spell-check,webcam,waypoints,popcorn,blocks,waves-vertical,layer-arrow-up,microchip,waves-ladder,badge-minus,cloud-sun,circle,shield-alert,waves-horizontal,phone-incoming,map-minus,waves-arrow-down,watch,separator-vertical,washing-machine,heart-minus,scan-square,ampersands,wand-sparkles,user-search,magnet,fence,wallpaper,square-user-round,wallet-minimal,wallet-cards,sunrise,strikethrough,calendar-days,folder-bookmark,wallet,banknote-arrow-up,layout-arrow-right,vote,dollar-sign,message-square-quote,volume-off,ruler-dimension-line,volume-1,list-minus,cloud-hail,volume,eye-closed,app-window-mac,volleyball,ellipsis,copy-check,clock-arrow-right,satellite,bookmark-plus,virus,folder-key,coffee,circle-power,ligature,hourglass,tickets-plane,folder-git,video,bomb,layers-2,battery-full,sparkle,line-dot-bottom-vertical,chart-gantt,folder-tree,command,badge-dollar-sign,align-start-vertical,briefcase-conveyor-belt,message-circle-question-mark,vibrate,bluetooth-off,venus-and-mars,square-square,cannabis,equal-approximately-not,book,grip-horizontal,circle-minus,audio-waveform,moon-star,arrow-down-narrow-wide,ghost,database-backup,wand,receipt-turkish-lira,vector-polygon,calendar-minus-2,copy-minus,vault,folder-input,book-image,badge-x,mouse-left,tag-plus,shirt,van,server-off,move-up,message-circle-dashed,utensils,plug-2,users-round,chess-rook,brackets,calendar-heart,list-ordered,users,star-x,mic-off,user-x,arrow-big-left,square-split-horizontal,triangle-alert,user-round-x,clover,sun-snow,sofa,user-round-search,handbag,funnel-x,map-pin,clock-2,calendar-fold,fish-off,baby,database-x,fold-vertical,user-round-group,hop,face-angry,user-round-cog,cigarette,calendar-chevrons-right,user-round-check,user-round-arrow-left,diamond-plus,refrigerator,file-chart-column,triangle-dashed,git-pull-request-closed,badge-check,user-minus,user-lock,layers-arrow-up,plug-zap,heading-4,chess-queen,graduation-cap,grid-3x2,zodiac-sagittarius,square-dashed-x-corner,square-dashed-bottom-code,clock-7,ethernet-port,scan-text,user-group,shower-head,equal-not,user-cog,move-down,clock-arrow-down,ticket-slash,ruler,settings-2,user,circle-user-round,usb-c-port,layers,list-filter,map-pin-check,egg-off,upload,cog,dog,unplug,swords,spotlight,panel-right-dashed,signal-zero,paper-bag,truck-electric,unlink,check-line,university,bubbles,bot,chart-bar-increasing,ungroup,playing-card,air-vent,unfold-vertical,dot,ice-cream-cone,mouth,file-symlink,clipboard-paste,chevron-last,book-heart,undo-2,circle-parking,globe-check,cloud-check,panel-left,circle-chevron-right,undo,underline,squares-unite,arrow-down-up,git-fork,forward,brain-circuit,between-vertical-start,database,panel-right,umbrella-off,type-outline,flower,log-out,git-branch-plus,clipboard-minus,file-text,trending-up,fire-extinguisher,fan,table-rows-split,milk-off,tv-minimal,cloud-upload,banknote,turntable,message-circle-dashed-check,drumstick,turkish-lira,calendar-search,tube-lotion,line-dot-top-vertical,bell-ring,circle-chevron-left,truck,arrow-down,arrow-up-down,folder-dot,trophy,case-lower,whole-word,monitor,disc-2,trending-up-down,folder-cog,user-shield,triangle,tv-minimal-play,circle-stop,align-vertical-space-around,switch-camera,tree-deciduous,square-chart-gantt,arrow-big-down,circle-parking-off,calendar-x-2,user-plus,move-diagonal-2,bandage,gallery-horizontal-end,panel-top-dashed,transgender,chess-bishop,tram-front,train-front-tunnel,train-front,refresh-cw-off,audio-lines,traffic-cone,tractor,toothbrush,tower-control,rocket,fish,ear-off,touchpad-off,save-check,touchpad,torus,printer,megaphone-off,tornado,arrow-big-right,section,file-clock,toothbrush-sparkles,toy-brick,square-chevron-down,dice-1,drill,app-window,robot-vacuum,hand-metal,tool-case,spell-check-2,toilet,squirrel,list-plus,toggle-left,rotate-ccw-key,timer-reset,chart-pie,paw-print,timer,copy-slash,wind,ticket-x,layout-panel-left,moon,circle-percent,ticket-minus,circle-arrow-out-down-right,square-x,italic,chart-column-increasing,layout-freeform,step-forward,message-square-diff,a-arrow-down,broom-sparkles,sticker,tic-tac-toe,move-left,thermometer-sun,thermometer-snowflake,thermometer,theater,import,badge-turkish-lira,square-terminal,file-music,logs,beef,faucet,file-user,text-quote,square-radical,lightbulb,image-upscale,book-type,text-cursor-input,signpost-big,text-cursor,cloudy,helicopter,square-percent,text-align-justify,navigation-off,arrow-left,car-taxi-front,text-align-end,mouth-off,chevrons-right-left,text-align-center,test-tubes,test-tube-diagonal,brick-wall-fire,square-stack,tent,square-dimensions,face-slightly-smiling,align-end-horizontal,layer-arrow-down,equal,megaphone,calendar-x,telescope,ice-cream-bowl,egg,tangent,save-off,ship-cargo,circle-pound-sterling,video-off,japanese-yen,tally-3,tag,tally-1,library,file-terminal,circle-chevron-down,accessibility,route,square-library,amphora,hourglass-cog,tally-2,tablets,tablet-smartphone,building-complex,remove-formatting,sheet,circle-check-big,table-properties,table-of-contents,map-pinned,corner-down-left,circuit-board,table-columns-split,table-cells-merge,table-2,table,folder-open-dot,book-dashed,syringe,lasso,bluetooth,tree-pine,receipt-indian-rupee,swiss-franc,shield-plus,sunset,sun-medium,sun-dim,can-soda,flask-conical,power,funnel,square-star,folder-sync,monitor-pc,zodiac-ophiuchus,subscript,stretch-vertical,arrow-up-narrow-wide,fishing-hook,stretch-horizontal,maximize-2,stone,frame,calendar-arrow-down,clock-12,star-minus,heart,sticky-note-x,images,lollipop,book-text,chart-no-axes-column-increasing,lamp-floor,file-plus-corner,image,equal-approximately,badge-euro,bike,angle,gap-vertical,sticky-note-check,sticky-note,stethoscope,step-back,star-off,option,banknote-check,scroll-text,server-plus,repeat,star,stamp,toggle-right,file-x,ferris-wheel,camera-off,squircle,search-slash,repeat-off,squares-exclude,square-user,group,square-text,battery,mic-audio-lines,tent-tree,square-split-vertical,rectangle-horizontal,spade,square-slash,screen-share-off,bitcoin,square-scissors,battery-plus,database-search,square-round-corner,file-diff,joystick,square-plus,square-play,spline-pointer,square-pilcrow,axis-3d,square-pi,message-square-share,binoculars,square-pause,calendar-range,square-parking,rose,euro,mail-minus,square-m,square-kanban,square-function,pyramid,clipboard-pen,bottle-wine,alarm-clock-off,square-equal,list,square-dot,square-arrow-right,dome,badge-pound-sterling,bookmark-check,square-divide,wrench-off,shopping-bag,a-arrow-up,clock-check,shrink,chevrons-down,vibrate-off,face-grinning,zodiac-cancer,square-code,file-code,square-chevron-up,carton-off,credit-card-reader,paintbrush-vertical,cassette-tape,battery-low,square-chevron-left,receipt-japanese-yen,signpost,snail,calendar-arrow-up,landmark,fish-symbol,trash-off,loader,bold,dice-2,file-type,clipboard-clock,beer,lectern,square-centerline-dashed-vertical,square-bottom-dashed-scissors,square-bookmark,binary,move-diagonal,square-asterisk,door-closed,square-arrow-up-right,layout-template,rows-4,piano,square-arrow-right-exit,bookmark-off,hand-heart,square-arrow-right-enter,scan-qr-code,message-square-check,square-arrow-out-up-right,square-arrow-out-up-left,monitor-play,brain,square-arrow-out-down-left,server-cog,square-arrow-down-right,key,clock-11,gap-horizontal,ticket-plus,arrow-up-0-1,bell-electric,square,heading,book-open-check,panel-top-close,lasso-select,sprout,spray-can,sport-shoe,shield-off,bus,search-alert,audio-lines-x,chart-no-axes-gantt,file-spreadsheet,percent,clipboard-list,speech,contact-round,speaker,keyboard-off,sparkles,file-badge,battery-warning,mail-question-mark,arrow-down-from-line,briefcase,biohazard,rectangle-circle,braces,scale-3d,panel-top-bottom-dashed,mail-x,square-dashed-mouse-pointer,square-sparkles,lock-open,file-play,pizza,list-indent-decrease,arrow-up-wide-narrow,soup,clock-5,solar-panel,rotate-ccw,align-horizontal-justify-center,soap-dispenser-droplet,antenna,memory-stick,scan-eye,snowflake,square-check,heart-plus,smartphone-nfc,map-pin-minus-inside,git-merge,gallery-vertical-end,square-dashed-plus,hand-coins,zodiac-capricorn,wifi-low,sliders-horizontal,clock,file-pen,git-compare-arrows,cloud-sun-rain,align-horizontal-justify-start,power-off,mail-badge,skull,calendar-plus,siren,arrow-down-z-a,bath,signature,unlink-2,signal-medium,shopping-cart-minus,folder-check,signal-low,book-key,ribbon,microwave,calculator,gallery-vertical,sigma,shuffle,square-dashed-text,map-pin-pen,move-up-left,shrimp,folder-heart,hard-drive-upload,monitor-speaker,shopping-cart-plus,arrow-up-a-z,package,square-dashed-top-solid,ship-wheel,shield-user,shield-question-mark,swatch-book,receipt-cent,spool,folder-archive,folder-symlink,can,ban,message-square-x,paint-roller,git-pull-request-draft,archive,shield-lock,shield-keyhole,shield-half,circle-slash-2,shield-cog-corner,cake,cloud-rain,chart-bar,shield-cog,wrench,shield-ban,shield,shelving-unit,flag-triangle-right,shell,gamepad-directional,bell,share,shapes,music-3,chart-bar-big,user-check,proportions,settings,plane,webhook-off,carrot,square-arrow-left,file-cog,circle-dashed,server,send-horizontal,search-x,germ,squares-subtract,search-code,dices,split,list-sort-descending,search,forklift,scroll,alarm-clock-minus,heart-x,eraser,square-sigma,screen-share,bluetooth-connected,rotate-ccw-square,chart-no-axes-column,cannabis-off,folder-kanban,lighthouse,mars-stroke,roller-coaster,school,scan-search,file-box,pickaxe,paint-bucket,glass-water,mic,glasses,piggy-bank,scan-face,cuboid,cloud-off,check-check,activity,axe,plane-takeoff,scan-box,cloud-rain-wind,scan-barcode,scan,copy-x,file-axis-3d,radical,chart-column-decreasing,play-off,bug-play,align-vertical-distribute-start,save-plus,waves-arrow-up,tally-5,headset,save,saudi-riyal,circle-divide,satellite-dish,sandwich,salad,life-buoy,sailboat,external-link,volume-2,battery-charging,russian-ruble,square-arrow-up-left,brick-wall-shield,footprints,rows-3,building,rows-2,router,route-off,tag-x,book-alert,link-2,astroid,bell-minus,image-up,closed-caption,drum,arrow-up-z-a,sun,rotate-cw-fading-clock,rotate-cw-clock,file-key,rotate-ccw-clock,rotate-3d,scissors-line-dashed,house-wifi,robot-arm,rewind,ticket-check,combine,reply,replace-all,mountain,mars,picture-in-picture-2,radio-off,flower-2,replace,squares-intersect,repeat-2,repeat-1,keyboard-music,star-half,playing-cards-fan,code-xml,pencil-line,mails,brain-cog,tablet,regex,pi,trash,book-down,hdmi-port,trailer,case-upper,circle-fading-arrow-up,refresh-cw,croissant,phone,computer,barcode,pin,redo,bed,circle-arrow-right,divide,grape,rectangle-vertical,party-popper,file-chart-pie,rectangle-goggles,file-x-corner,dice-6,receipt-swiss-franc,blender,receipt-russian-ruble,zap-off,square-check-big,receipt-euro,receipt,ratio,laptop-minimal,rat,rainbow,map-pin-minus,omega,chart-spline,message-square-more,radio-receiver,chart-candlestick,radio,arrow-down-a-z,radiation,radar,move-horizontal,file-sliders,quote,square-exclamation-point,cup-soda,puzzle,projector,sword,printer-check,map-pin-x,earth,slice,dice-3,milk,mouse-pointer-ban,crown,circle-slash,circle-star,rotate-cw-square,atom,package-x,bed-double,pound-sterling,circle-dot,file-exclamation-point,hand-fist,message-circle-code,folder-git-2,message-square-code,popsicle,towel-rack,layout-grid,arrow-big-left-dash,plus,dumbbell,plug,playing-cards,houses,scale,play,flashlight,panel-top-open,plane-landing,pin-off,notebook,redo-2,pill,square-menu,pilcrow-left,monitor-smartphone,laptop,scan-line,clock-4,square-arrow-up,book-minus,file-question-mark,chevrons-left-right,phone-off,save-pen,arrow-down-to-line,phone-forwarded,refresh-ccw,venetian-mask,calendar-check-2,phi,spline,banknote-x,git-pull-request-create-arrow,pentagon,circle-check,pencil-off,caravan,pen-off,pen-line,hand-platter,pc-case,timer-off,arrow-big-right-dash,bed-single,parasol,paperclip,backpack,calendar-minus,panels-left-bottom,panel-top,panel-right-open,mic-signal,arrow-down-right,panel-right-close,letters,wifi-zero,panel-left-open,panel-left-dashed,map-pin-plus,hard-drive-download,image-off,panel-bottom-close,panel-bottom,panda,engine,square-chevron-right,mail-search,package-search,bone-fracture,package-plus,package-open,crop,package-2,lambda,ampersand,ad,shopping-cart,align-vertical-justify-end,origami,alarm-smoke,orbit,file-input,clock-8,hand-grab,cloud-cog,blend,hd,radio-tower,list-tree,droplet,line-squiggle,eye,octagon-pause,square-dashed-x,banana,gpu,message-square-heart,nut-off,circle-equal,face-slightly-frowning,nut,notepad-text-dashed,notepad-text,text-initial,arrow-up-right,maximize,leafy-green,message-square-dot,file-chart-line,columns-3-cog,newspaper,network,minimize-2,nepali-rupee,navigation-2,cone,navigation,file-image,music-2,palette,barrel,gallery-thumbnails,move-up-right,cpu,move-right,thumbs-down,merge,hamburger,move-down-right,hat-glasses,code,move-down-left,move-3d,mail-check,mouse-pointer,carton,mouse-off,kanban,bone,apple,rocking-chair,bot-off,circle-arrow-out-down-left,database-arrow-down,folder,circle-arrow-out-up-left,mop,cable-car,arrow-down-left,square-activity,message-square-text,cigarette-off,monitor-up,message-circle,circle-arrow-out-up-right,car-battery,monitor-stop,fold-horizontal,shovel,calendar-1,cloud-moon,square-arrow-out-down-right,monitor-pause,clock-plus,circle-euro,cloud-snow,anvil,arrow-big-up-dash,monitor-off,log-in,monitor-dot,monitor-cog,monitor-check,list-checks,chevrons-down-up,clipboard-plus,circle-x,list-end,minus,list-collapse,chevrons-right,audio-lines-off,message-square-reply,corner-down-right,milestone,summary,lamp-wall-down,mic-vocal,layout-arrow-down,ellipsis-vertical,globe-off,square-stop,arrow-up-1-0,align-horizontal-justify-end,scan-heart,align-vertical-distribute-end,heart-crack,airplay,case-sensitive,messages-circle,message-square-warning,monitor-x,bell-check,database-minus,square-pen,message-square-plus,message-square-lock,dice-5,octagon,ticket,folder-lock,message-circle-off,briefcase-plus,bookmark,message-circle-heart,utility-pole,message-circle-check,chart-bar-decreasing,database-plus,calendar-sync,funnel-plus,store,circle-arrow-down,notebook-pen,egg-fried,compass,keyboard,corner-right-up,map-pin-x-inside,printer-3d,user-round-plus,panel-left-close,crosshair,pilcrow-right,user-round-minus,mailbox,indian-rupee,mail-plus,mail-pen,bell-off,mail-clock,mouse-pointer-2-off,drone,slash,credit-card-x,aperture,arrow-right-left,mail,vector-square,circle-gauge,circle-alert,check,text-search,arrow-down-to-dot,monitor-down,lock-keyhole-open,chef-hat,lock-keyhole,lock,file-archive,signal-high,inbox,locate-fixed,locate,image-play,align-horizontal-space-between,loader-pinwheel,calendar-check,database-zap,droplets,loader-circle,broom,corner-right-down,layout-list,file-search,list-video,alarm-clock-plus,circle-dollar-sign,usb,house,receipt-pound-sterling,list-music,list-indent-increase,id-card,mouse,minimize,list-clock,list-chevrons-up-down,galaxy,list-chevrons-down-up,book-x,mirror-rectangular,list-check,link-2-off,link,headphone-off,asterisk,line-style,octagon-x,languages,line-dot-right-horizontal,alarm-clock-check,guitar,dock,beer-off,scooter,square-parking-off,notebook-text,arrow-right-to-line,clef-treble,tally-4,zodiac-taurus,leaf,door-open,flag-triangle-left,grid-3x3,file,layout-panel-top,pocket-knife,book-copy,castle,car-front,clock-alert,reply-all,cloud-moon-rain,clipboard-type,layout-dashboard,list-todo,printer-x,bird,list-start,lamp-wall-up,a-large-small,lamp-ceiling,lamp,map-plus,key-square,file-chart-column-increasing,kayak,database-arrow-up,arrow-right-from-line,flame-kindling,square-power,iv-bag,bring-to-front,iteration-cw,iteration-ccw,bell-plus,inspection-panel,info,infinity,folders,mail-warning,image-plus,image-minus,id-card-lanyard,bridge,chart-line,file-lock,cast,circle-fading-plus,clock-10,undo-dot,target,list-filter-plus,house-plug,drama,house-heart,baseline,martini,contrast,hotel,candy-off,hospital,book-check,heart-off,book-lock,highlighter,briefcase-medical,calendars,text-align-start,heart-pulse,hop-off,warehouse,sticky-notes,drafting-compass,save-all,file-braces,heading-6,heading-5,heading-3,heading-2,fishing-rod,book-headphones,credit-card,heading-1,haze,hard-hat,shredder,panel-bottom-open,door-closed-package,eject,credit-card-check,balloon,map-pin-plus-inside,bookmark-x,badge-question-mark,pen,hand,candy-cane,hammer,grip,gamepad-2,file-type-corner,grid-2x2-check,grid-2x2,globe-x,shield-minus,circle-off,dessert,eclipse,church,git-pull-request-create,cylinder,badge-japanese-yen,columns-3,receipt-text,git-merge-conflict,git-compare,git-commit-vertical,git-commit-horizontal,file-output,disc-album,circle-ellipsis,arrow-down-0-1,captions,git-branch,gift,philippine-peso,badge-alert,gem,folder-pen,cross,gauge,chevron-right,sticky-note-minus,square-arrow-down-left,share-2,gamepad,fullscreen,fuel,folder-up,folder-search-2,folder-root,chess-pawn,folder-open,briefcase-business,folder-minus,message-circle-reply,cloud-sync,triangle-right,folder-clock,folder-closed,mop-sparkles,type,webhook,flask-conical-off,align-horizontal-distribute-start,flashlight-off,flag-off,pointer-off,turtle,camera,fingerprint-pattern,film,git-pull-request,bluetooth-searching,arrow-up-to-line,squircle-dashed,clock-3,badge-percent,face-expressionless,file-video-camera,file-up,grid-2x2-plus,file-stack,box,file-search-corner,clock-1,file-heart,house-cog,space,file-minus-corner,file-minus,file-digit,corner-up-left,clock-6,zodiac-scorpio,key-round,headphones,tv,factory,face-neutral,rss,expand,at-sign,map-pin-check-inside,sticky-note-off,music,handshake,earth-lock,circle-user,copy-plus,droplet-off,virus-off,line-dot-left-horizontal,disc,diff,search-check,clipboard-check,columns-2,diamond-minus,clipboard,align-center-vertical,diameter,delete,club,cloud-fog,mosque,currency,map-pin-house,package-check,chevron-first,pencil,boxes,list-x,copyright,copyleft,corner-up-right,cookie,clock-arrow-left,container,contact,badge-indian-rupee,construction,redo-dot,component,align-start-horizontal,chart-column-stacked,file-plus,git-pull-request-arrow,coins,decimals-arrow-right,bell-dot,folder-down,cloud-drizzle,cloud-backup,align-horizontal-space-around,door-closed-locked,clock-9,diamond,blinds,clapperboard,circle-play,book-search,git-branch-minus,circle-dashed-check,recycle,mountain-snow,luggage,chevrons-left-right-ellipsis,bot-message-square,phone-outgoing,smartphone-charging,chevron-left,train-track,cherry,chart-bar-stacked,sticky-note-plus,chart-no-axes-column-decreasing,chart-network,chart-column-big,chart-no-axes-combined,metronome,triangles-centerline-dashed-vertical,arrow-down-1-0,credit-card-minus,candy,arrow-left-right,lightbulb-off,panels-top-left,beef-off,locate-off,bug,test-tube,brick-wall,cooking-pot,boom-box,book-up,book-plus,laptop-minimal-check,mail-open,park,baggage-claim,variable,arrow-right,archive-restore"
                local LUCIDE_R = "1,175,0;1,650,0;1,850,250;2,150,0;1,250,700;1,600,225;1,575,800;2,225,225;1,50,350;1,675,25;1,500,425;1,50,400;1,75,925;1,825,50;1,50,75;1,175,800;1,375,925;1,850,450;1,325,50;1,100,325;1,650,225;1,950,475;1,725,300;1,425,125;1,650,850;1,50,375;1,550,425;2,50,125;1,25,725;1,300,200;1,825,500;1,300,575;1,500,800;1,950,225;1,525,925;1,500,375;1,775,525;1,100,100;1,900,100;2,200,50;1,325,125;2,100,400;1,175,550;1,175,975;1,75,650;1,100,825;1,225,375;1,525,700;1,500,675;2,225,200;1,500,825;1,75,350;1,325,325;1,50,475;1,775,375;1,600,675;1,450,50;1,900,25;1,300,350;1,775,900;1,775,925;2,50,50;1,750,800;2,175,325;1,25,975;1,750,475;1,250,600;1,250,75;1,425,450;1,925,725;1,725,550;1,875,575;1,650,350;1,100,175;1,800,725;2,250,25;1,100,450;2,225,300;1,550,675;2,0,450;1,350,975;2,25,300;1,250,125;1,50,525;1,100,75;1,275,550;1,525,675;1,775,300;1,550,975;1,700,225;1,150,650;1,150,100;2,375,100;1,575,625;1,75,775;1,700,300;1,300,675;1,775,475;1,475,275;1,950,375;1,350,425;1,250,100;1,750,0;2,325,100;1,50,225;1,75,400;1,450,725;1,550,725;1,250,350;1,250,750;1,575,225;2,350,0;1,75,900;1,125,550;1,100,525;1,75,325;1,350,350;1,650,825;1,200,0;1,575,400;1,400,300;1,700,600;1,525,50;1,550,75;1,200,200;1,800,900;1,950,875;1,300,500;1,150,775;1,950,200;1,100,275;1,525,500;2,0,200;1,500,50;1,425,250;1,200,925;1,325,225;1,875,100;1,75,150;2,100,175;1,775,575;1,475,300;1,450,525;1,375,100;2,325,25;1,175,600;1,300,750;1,375,475;2,150,275;1,750,650;1,575,650;1,0,100;1,550,50;1,475,750;1,850,0;2,100,350;2,50,25;1,300,325;1,550,775;2,200,100;1,325,250;1,75,475;1,500,450;1,25,675;1,825,275;1,50,425;1,75,600;1,775,600;1,25,325;1,125,225;1,250,625;1,50,450;1,125,575;2,375,50;1,25,900;2,25,400;1,275,50;1,125,175;1,50,125;1,250,800;1,500,775;1,925,625;1,0,900;1,0,425;1,25,100;1,450,375;1,500,75;1,900,325;1,0,875;1,350,25;1,525,825;1,400,900;1,325,450;1,200,750;1,350,200;1,400,100;1,950,675;1,25,650;2,75,375;1,200,400;1,150,500;1,750,950;1,300,925;1,450,800;1,450,25;1,75,50;2,50,200;1,475,500;1,725,625;1,225,825;1,325,500;1,75,300;1,375,775;1,0,800;1,625,525;1,875,75;1,650,500;1,350,775;1,875,350;1,75,225;1,25,300;1,175,100;2,50,325;1,800,275;2,250,300;1,775,425;1,800,425;2,275,275;1,900,625;1,400,500;1,700,125;1,700,200;1,175,575;1,125,100;2,300,250;1,950,725;1,625,575;1,325,400;1,275,450;1,950,350;1,725,350;2,300,150;1,850,975;1,475,400;1,325,375;1,725,425;2,150,250;1,100,675;2,400,150;1,875,0;2,75,325;1,75,550;2,75,425;1,300,600;1,700,775;1,50,50;1,750,425;2,450,100;2,475,75;2,50,475;1,725,800;1,675,800;1,825,750;1,975,700;2,125,400;2,150,375;1,575,475;2,450,75;1,175,775;1,75,450;1,625,925;2,250,275;1,400,75;1,275,950;1,775,125;1,650,150;1,700,475;1,525,625;1,725,775;2,325,200;1,400,250;2,350,175;2,175,200;1,600,950;1,225,475;1,600,525;1,100,200;1,550,125;2,400,125;2,375,150;1,600,100;1,0,175;1,700,350;1,0,650;2,175,350;1,100,300;2,75,200;1,300,950;2,50,450;1,550,700;1,900,675;1,150,375;2,150,350;2,475,50;1,525,125;2,150,200;2,225,275;1,375,900;1,475,325;2,275,225;1,750,200;1,975,325;1,575,250;1,50,175;1,175,425;1,0,525;2,250,250;2,325,175;1,500,100;2,300,200;1,575,900;1,500,625;1,775,150;1,275,575;2,425,75;1,650,200;1,875,725;2,400,100;2,450,50;1,475,850;1,200,250;2,475,25;1,350,700;1,775,400;2,0,475;1,75,275;1,550,200;1,450,250;1,775,725;2,25,450;1,725,575;1,750,375;2,75,400;2,100,375;1,625,850;2,125,350;1,225,775;1,650,800;1,150,50;2,200,275;2,200,225;1,250,850;1,800,75;2,225,250;1,875,900;2,275,200;2,300,175;2,100,0;2,0,25;1,50,500;1,600,325;2,250,225;1,50,325;1,150,900;2,325,150;1,500,325;1,325,825;2,400,75;1,750,675;2,450,25;1,950,150;1,0,725;2,350,125;1,300,550;1,225,0;2,475,0;1,600,250;1,600,175;1,350,375;1,575,850;1,250,250;2,25,425;1,275,650;1,325,425;1,700,0;1,650,425;1,825,200;2,125,150;1,375,550;2,125,325;1,25,425;1,325,725;1,250,150;1,600,975;1,550,525;1,525,100;1,925,25;1,125,625;1,200,150;1,0,150;1,275,250;1,700,450;2,175,275;1,150,300;2,250,200;1,800,950;1,75,500;1,550,300;1,350,150;1,200,775;1,225,450;1,50,275;1,900,300;1,0,250;1,125,825;1,500,300;2,175,300;1,850,525;2,350,100;1,575,0;1,575,200;2,375,75;1,325,600;1,200,275;1,275,100;1,700,500;2,125,50;1,775,750;2,425,25;1,550,925;1,925,300;1,825,325;2,0,425;1,675,650;2,75,350;1,0,625;1,500,25;1,0,550;1,900,200;2,50,375;1,975,875;1,875,300;2,125,300;1,250,0;1,850,900;2,250,100;2,250,175;1,425,325;2,25,50;1,725,850;2,275,150;1,800,200;1,600,350;1,425,700;1,625,100;1,25,525;1,200,700;1,325,25;1,375,425;1,650,275;2,400,25;1,925,100;1,200,650;2,425,0;1,225,425;1,125,425;2,0,400;2,25,375;1,125,675;1,475,900;1,575,300;2,225,125;1,775,200;1,225,125;2,100,300;2,125,275;1,275,775;1,650,675;1,450,550;1,25,600;1,400,575;1,250,725;2,375,175;1,825,850;1,675,975;1,500,225;1,425,425;1,625,825;2,175,225;1,600,925;1,500,350;2,200,200;1,300,900;1,400,325;2,200,75;1,725,700;1,975,525;2,100,325;1,525,175;2,275,125;1,200,850;1,125,950;1,700,425;1,725,125;2,300,100;1,300,450;1,525,300;2,325,75;2,75,50;1,725,875;1,950,325;1,775,775;1,675,600;2,75,275;2,350,50;1,225,400;2,400,0;1,25,500;1,100,400;1,100,500;2,0,375;1,750,575;1,75,0;2,25,350;1,300,525;1,600,425;1,450,750;1,600,300;1,150,550;1,600,50;1,225,250;2,125,250;1,150,525;1,600,375;1,125,600;1,275,975;1,575,100;2,75,300;2,150,225;1,900,900;1,200,75;1,900,75;1,725,225;1,475,50;1,25,400;1,325,475;1,900,375;2,200,175;2,250,125;1,725,200;1,350,750;1,50,900;1,175,525;1,550,350;2,275,75;1,225,675;1,0,850;2,50,100;1,650,525;2,300,75;1,500,250;1,400,0;2,375,0;1,850,300;1,50,775;2,0,350;1,425,150;2,25,325;1,475,600;1,150,275;1,600,75;2,50,300;1,125,150;1,150,150;1,450,475;2,100,250;1,400,200;2,200,300;1,925,275;1,725,100;2,300,50;1,475,450;2,175,250;2,175,175;2,325,50;1,550,150;1,25,150;2,125,0;2,50,275;1,875,775;1,25,200;1,175,500;1,375,200;2,50,350;1,400,800;1,125,250;1,525,425;1,825,450;2,125,200;1,125,500;2,150,175;2,225,100;2,200,125;1,525,850;1,75,250;2,275,50;2,300,25;2,150,150;2,0,300;1,675,725;1,150,750;1,0,825;2,75,225;1,500,925;2,50,250;2,100,200;1,900,450;1,175,950;2,125,175;1,200,50;1,750,725;1,450,425;2,175,125;2,325,0;1,800,850;1,75,725;1,200,625;1,200,25;1,700,700;1,875,125;2,225,75;1,900,700;2,250,50;1,825,975;1,875,225;2,300,0;1,525,875;2,25,250;1,325,300;1,475,800;2,0,275;1,525,250;2,425,100;2,175,100;1,950,125;1,875,325;1,100,575;2,275,0;1,100,550;1,825,950;1,150,875;1,600,25;1,100,950;1,900,950;1,500,650;1,0,0;1,125,400;1,975,900;2,25,225;1,250,950;2,125,125;2,150,100;2,100,150;2,175,75;1,300,725;1,300,75;1,925,850;1,50,825;1,325,775;1,375,50;1,850,25;1,450,450;2,250,0;1,750,975;1,600,475;1,375,650;1,475,25;2,50,175;1,700,850;2,25,200;1,450,300;1,50,950;1,900,825;2,100,125;1,700,525;1,25,250;1,575,25;2,125,100;1,475,725;1,375,275;2,150,75;2,175,50;2,225,0;1,400,125;1,775,975;2,25,175;1,750,925;1,50,800;1,100,25;1,375,675;1,475,375;1,150,975;1,350,225;2,75,125;1,625,400;1,700,150;2,125,75;1,475,950;1,850,675;1,0,675;2,150,300;1,50,975;2,200,0;2,75,100;2,25,150;1,700,375;1,575,325;1,625,50;1,50,0;1,900,525;1,875,825;1,125,75;1,850,175;2,0,175;2,150,25;2,0,150;1,475,75;1,425,950;1,850,650;1,675,0;2,75,75;2,100,50;1,400,725;1,400,375;1,425,275;2,125,25;2,0,125;2,25,100;2,25,125;1,200,725;1,300,175;2,50,75;1,400,650;1,100,350;2,0,325;1,375,975;2,0,100;1,975,550;2,75,25;2,75,0;2,0,50;1,225,350;1,800,125;1,375,950;1,575,375;1,975,800;1,950,0;1,300,875;2,425,125;2,50,0;2,25,0;1,50,250;1,125,775;2,0,0;1,250,875;1,950,975;1,700,250;1,225,325;1,650,75;1,900,925;1,100,900;1,950,950;1,325,700;1,300,800;1,500,0;1,425,200;1,675,375;1,850,50;1,350,675;1,525,325;1,175,175;1,450,0;1,75,125;1,300,650;1,950,925;1,925,975;1,875,975;1,925,925;1,875,950;1,900,350;1,25,350;1,950,525;1,525,950;1,925,475;1,950,900;1,975,850;2,275,25;1,350,550;1,775,100;1,275,300;1,850,950;1,825,650;1,950,450;1,975,825;1,850,925;1,125,850;1,900,875;1,125,275;1,900,275;2,50,150;1,825,925;1,725,650;1,625,950;1,900,850;1,475,975;1,300,150;1,950,800;1,175,225;1,400,400;1,975,775;1,350,525;1,975,75;1,800,925;1,825,900;1,850,750;1,850,875;1,350,0;1,875,850;1,275,875;1,400,50;1,950,775;1,450,125;1,975,750;1,600,800;1,400,450;1,150,950;1,850,850;1,900,800;1,925,775;1,800,550;1,100,600;1,75,425;1,100,0;1,975,725;1,650,450;1,700,975;1,750,875;1,475,350;1,0,350;1,325,175;1,725,950;2,300,225;1,750,775;1,25,0;1,300,425;1,950,600;1,475,175;2,200,250;1,150,700;2,100,425;1,700,950;1,400,475;1,725,925;1,450,150;1,75,700;1,575,675;1,325,275;1,225,175;1,775,875;1,975,400;1,675,875;1,800,775;1,200,350;1,550,500;1,175,725;2,100,225;1,575,525;1,75,375;1,50,750;1,500,400;1,250,450;1,325,100;1,825,250;1,900,750;1,950,700;1,975,675;1,425,25;1,375,825;1,650,975;1,375,450;1,700,925;1,900,175;1,800,625;1,575,725;1,775,850;1,275,225;1,925,75;1,800,825;1,700,750;1,575,575;1,825,800;1,850,775;1,275,900;1,425,100;1,900,725;1,600,875;1,975,650;1,850,200;1,675,50;1,325,625;2,225,50;1,225,75;1,250,175;1,800,975;1,375,625;1,100,375;1,850,425;1,425,625;1,675,925;1,700,900;1,750,850;1,525,975;1,400,150;1,900,575;1,100,225;1,350,275;1,650,250;1,875,425;1,200,500;1,925,675;1,750,25;1,950,650;1,800,250;1,975,625;1,700,175;1,150,250;1,925,200;1,50,200;1,200,325;1,375,75;1,800,575;1,525,0;1,925,525;1,875,400;1,850,275;1,925,750;1,875,875;1,425,675;1,875,25;1,925,400;1,100,975;1,325,0;1,675,900;1,550,175;1,700,875;1,475,925;1,150,0;1,750,825;1,50,150;1,975,175;1,800,650;1,775,800;1,825,825;1,175,825;1,850,725;1,650,475;1,825,150;1,450,500;1,900,775;1,0,975;2,75,450;2,125,375;1,925,650;1,225,500;1,900,0;1,950,25;1,575,175;1,100,50;1,400,925;1,225,875;1,575,975;1,475,100;1,650,900;1,150,125;1,300,100;1,725,825;2,375,25;1,800,750;1,700,825;1,575,350;1,825,725;1,175,300;1,775,625;1,725,450;1,275,275;1,425,525;1,875,675;1,900,650;1,875,800;1,575,550;1,975,250;1,975,575;1,350,575;1,725,275;1,225,950;1,675,850;1,175,125;1,650,600;1,850,825;1,825,700;1,925,600;1,950,575;2,25,75;1,425,925;1,775,825;1,625,300;1,0,925;1,200,375;1,175,200;1,200,950;1,600,650;1,700,275;1,100,125;1,575,925;1,600,900;1,625,875;1,650,50;1,700,800;1,300,250;1,625,125;1,50,550;1,675,825;2,275,250;1,750,750;1,875,650;1,800,700;1,25,875;1,825,675;1,375,575;1,125,300;1,875,625;1,925,575;1,825,400;1,150,450;2,225,175;1,850,500;1,950,550;1,850,475;2,375,125;1,475,125;1,925,700;1,375,500;1,500,175;1,500,975;1,725,750;1,800,675;1,150,800;1,925,875;1,850,625;1,775,50;1,800,800;1,800,300;1,775,700;1,775,175;1,925,550;1,0,75;1,125,875;1,450,400;1,925,825;1,975,500;1,175,275;1,500,900;1,400,225;1,100,475;1,300,625;1,575,500;1,325,800;1,625,775;1,575,875;1,675,775;1,675,200;1,550,750;1,625,625;1,650,325;1,800,375;1,625,350;1,475,825;1,775,675;1,700,100;1,675,75;1,250,375;1,25,25;1,0,325;1,875,450;1,825,625;1,650,100;1,850,600;1,600,850;1,500,275;1,725,150;1,650,700;1,625,0;1,800,525;1,550,0;1,125,50;1,975,475;2,50,425;2,150,50;1,300,700;1,950,500;1,550,875;1,475,200;1,600,825;1,625,800;1,650,775;1,675,400;1,675,750;1,325,525;2,425,50;1,275,125;1,700,725;1,725,900;1,375,150;1,800,150;1,825,600;1,450,100;1,850,575;1,875,550;1,925,500;2,100,75;1,425,50;1,375,700;1,200,125;1,225,200;1,400,625;1,200,525;1,75,750;1,300,25;2,0,75;1,425,975;1,450,950;1,150,725;1,550,850;1,575,825;1,550,900;1,700,325;1,725,675;1,800,600;2,0,250;1,150,600;1,825,575;1,900,500;1,725,475;1,300,825;1,525,775;1,625,725;1,750,175;1,875,525;1,950,850;1,975,425;1,400,975;1,825,225;1,925,900;1,725,600;1,375,375;1,325,950;1,775,350;1,450,75;2,175,0;1,450,925;1,600,700;2,75,250;1,275,200;1,550,450;2,250,75;1,350,250;1,300,375;1,500,875;1,0,775;1,625,675;1,50,700;1,375,25;1,975,350;1,600,775;1,425,0;1,25,625;1,625,200;1,375,600;1,700,675;1,525,750;1,525,350;1,750,625;1,375,525;1,800,25;1,900,475;1,250,200;1,925,450;2,200,325;1,850,800;1,400,950;1,825,550;1,450,900;1,475,575;1,475,875;1,500,850;1,625,500;1,925,325;1,275,350;1,400,750;1,600,750;1,25,575;1,550,800;1,75,175;1,675,675;1,700,650;1,275,925;1,675,225;1,750,600;1,950,750;1,675,125;1,825,525;1,875,475;2,100,25;1,950,400;1,450,675;1,800,50;1,950,625;1,25,775;1,625,550;1,600,600;1,725,75;1,625,75;1,575,125;1,975,450;1,150,175;1,675,575;1,25,375;1,425,900;1,400,275;1,275,600;1,975,25;1,875,275;1,400,525;1,550,600;1,450,875;2,25,275;1,75,975;1,0,225;1,600,725;1,25,800;1,625,700;1,700,625;1,650,375;1,900,550;1,775,550;1,850,75;1,800,475;1,900,425;1,325,975;1,425,800;1,650,725;1,350,950;1,825,875;1,450,850;1,250,925;1,450,600;1,725,725;1,575,150;1,675,950;1,125,350;1,800,100;1,425,225;1,675,625;1,450,975;1,225,50;1,750,550;1,550,825;2,275,175;1,175,375;1,825,475;1,825,775;1,0,375;1,750,225;1,900,400;1,650,25;1,300,975;1,525,75;1,400,875;1,425,850;1,850,150;1,450,825;2,50,225;1,225,25;1,0,400;1,625,650;1,650,625;1,300,50;1,550,25;1,750,525;1,775,500;1,925,350;1,850,325;1,275,0;1,975,300;1,750,325;2,25,475;1,325,925;1,350,900;1,525,600;1,750,250;1,475,550;1,475,775;1,400,850;1,500,750;1,575,275;1,750,900;1,900,225;1,700,550;1,0,450;1,725,525;1,750,500;1,800,0;1,825,425;1,750,300;1,175,25;1,0,50;1,650,875;1,75,100;1,850,400;1,25,75;1,875,375;1,175,700;1,475,250;1,950,50;1,100,625;1,275,175;1,575,425;1,575,775;1,725,375;1,125,700;1,450,625;1,225,625;1,250,975;1,800,875;1,150,225;1,425,550;1,450,700;1,350,875;1,350,325;1,100,750;1,325,900;1,400,825;1,375,850;2,0,225;1,25,275;1,225,900;1,850,225;1,475,675;1,550,325;1,225,525;1,600,625;1,625,600;1,600,575;1,650,575;1,725,500;1,0,750;1,675,550;1,200,675;1,850,375;1,525,725;1,350,50;1,475,475;1,950,275;1,200,575;1,225,975;2,75,175;1,925,225;1,50,925;1,325,875;1,625,375;1,350,400;1,350,850;1,425,775;1,200,900;1,550,650;1,425,175;1,675,525;1,950,100;1,475,0;1,175,50;1,650,750;1,125,375;1,125,525;1,550,250;1,850,100;1,75,575;1,825,375;1,375,175;1,25,225;1,650,950;1,250,900;1,250,400;1,975,225;1,600,550;1,50,600;1,0,575;1,200,975;1,675,250;1,625,900;1,250,300;1,700,50;1,875,750;1,325,850;1,250,475;1,325,350;1,600,150;1,25,175;1,175,75;1,350,825;1,375,725;1,400,775;1,425,750;1,475,700;1,300,775;1,500,150;1,75,625;1,475,225;1,175,900;1,550,625;1,200,875;1,350,300;1,125,200;1,300,850;1,375,400;1,675,500;2,25,25;1,650,400;1,825,350;1,175,875;1,625,225;1,525,450;1,950,825;1,200,100;1,125,25;1,750,700;1,150,25;1,275,725;1,50,25;1,375,225;1,975,200;1,225,925;1,950,250;1,300,125;1,450,350;1,925,800;1,350,800;1,425,725;1,825,0;1,950,300;2,150,125;1,250,675;1,750,400;1,225,300;1,200,300;1,800,350;2,450,0;1,900,250;1,125,475;1,425,375;1,400,175;1,625,325;1,975,975;1,175,475;1,500,725;1,750,100;1,100,650;1,775,275;1,275,500;1,475,650;1,975,375;2,300,125;1,375,875;1,750,50;1,425,875;2,350,75;1,800,325;1,250,775;1,950,175;1,975,150;1,200,225;1,175,925;1,650,550;1,175,650;1,975,600;1,50,725;1,0,200;1,300,0;1,825,300;2,325,125;1,250,425;1,200,450;1,200,425;2,225,25;1,250,25;1,375,800;1,475,625;1,175,450;1,450,650;1,400,700;1,750,125;1,850,700;1,275,750;1,550,550;1,500,600;1,450,575;1,50,100;1,600,500;1,150,400;1,350,450;1,100,725;1,625,475;1,100,425;1,300,475;1,975,100;1,725,175;1,700,400;1,75,25;1,450,225;2,250,150;1,675,350;1,950,425;1,925,175;1,975,125;1,550,475;1,500,700;1,575,600;1,225,850;1,250,825;1,550,400;1,275,800;1,375,125;1,525,650;1,325,750;1,400,675;1,350,725;1,350,650;1,225,100;1,425,650;1,975,275;1,525,525;1,500,575;1,25,50;1,100,875;1,550,275;1,350,75;1,500,950;1,725,975;1,450,775;1,275,25;1,300,400;2,175,25;2,325,225;1,875,200;1,350,475;1,50,850;1,225,750;1,325,575;1,925,150;1,575,750;1,325,150;1,275,325;1,600,0;1,425,300;1,850,550;1,725,25;1,50,650;1,125,925;1,750,350;1,925,425;1,350,100;1,775,325;1,625,425;1,0,25;1,725,325;1,600,450;1,375,750;1,875,175;1,600,275;1,925,125;1,525,275;1,0,275;1,925,0;1,775,950;1,75,950;1,175,350;1,100,925;1,125,900;1,175,250;1,175,850;1,200,825;1,225,800;1,825,125;1,875,250;1,425,600;1,500,525;1,575,450;1,325,200;1,500,125;1,125,750;1,300,300;1,275,400;1,700,25;2,100,275;2,100,100;1,150,925;1,750,275;1,225,600;1,775,250;1,325,75;1,275,850;1,675,100;1,875,150;1,150,425;1,900,125;1,350,125;1,200,800;1,150,325;1,975,50;1,250,275;1,300,275;2,75,150;1,150,850;1,950,75;2,150,325;1,975,950;1,250,575;1,525,900;1,625,250;1,400,600;1,425,575;1,475,525;1,500,500;1,100,800;1,250,225;1,25,750;1,525,475;1,600,400;1,675,325;1,575,950;1,425,825;1,400,425;1,675,175;1,150,625;1,200,175;1,550,575;1,225,275;1,375,0;1,350,925;1,825,175;1,175,400;1,25,950;1,150,825;1,400,550;1,525,375;1,350,625;1,275,700;1,500,475;1,550,950;1,200,475;1,225,575;1,775,75;1,275,375;1,725,250;1,600,200;1,100,250;1,200,550;1,875,500;1,850,125;1,925,50;1,975,0;1,0,950;1,25,850;1,675,150;1,375,300;1,125,125;1,25,550;1,25,925;1,100,850;1,800,500;1,275,75;1,225,725;1,125,800;1,775,25;1,275,675;1,550,100;1,925,950;1,625,975;1,900,600;1,350,600;1,650,300;1,675,275;1,900,50;1,50,875;1,75,850;1,50,575;1,175,750;1,300,225;1,225,700;1,675,475;1,525,225;2,200,150;1,550,375;1,525,400;1,850,350;2,225,150;2,350,150;1,825,100;1,0,125;1,875,50;1,75,825;1,525,800;2,350,25;1,250,325;1,250,650;1,275,625;1,675,300;1,125,325;1,0,300;1,875,925;1,600,125;1,50,300;1,175,675;1,425,475;1,475,425;1,325,650;1,625,275;1,25,475;1,750,150;1,725,0;1,225,650;1,800,225;1,650,925;1,100,775;1,75,800;1,325,550;1,250,525;1,525,200;2,350,200;1,900,150;1,325,675;2,275,100;1,25,825;1,125,725;1,775,650;1,350,500;1,175,150;1,725,400;1,900,975;1,775,450;1,775,225;1,825,25;1,500,200;1,550,225;1,150,675;2,50,400;1,525,550;1,650,175;1,750,75;1,875,600;1,275,425;1,250,500;1,175,625;1,0,700;1,125,0;1,200,600;1,250,550;1,400,350;1,25,700;1,800,400;1,625,175;1,675,450;1,800,450;1,625,25;1,925,375;1,0,500;1,675,425;1,425,350;1,450,325;1,225,550;1,650,125;1,375,350;1,700,75;1,725,50;1,150,200;1,775,0;1,625,750;1,75,675;1,25,125;1,575,50;1,825,75;1,800,175;1,275,475;1,275,525;1,275,150;1,425,500;1,50,675;1,150,575;1,75,75;1,425,400;1,450,275;1,100,700;1,225,225;1,375,325;1,50,625;1,0,475;1,75,875;1,525,150;1,675,700;1,750,450;1,275,825;1,450,200;1,150,350;1,650,650;1,875,700;1,575,75;2,175,150;1,150,475;1,75,525;1,975,925;1,450,175;1,475,150;1,0,600;1,375,250;1,925,250;2,125,225;1,100,150;1,125,650;1,125,450;1,75,200;1,625,450;1,700,575;1,400,25;1,525,575;1,525,25;2,200,25;1,350,175;1,625,150;1,175,325;1,425,75;1,25,450;1,500,550;1,125,975;1,575,700;1,225,150;2,400,50;1,250,50;1,150,75"

                local LUCIDE_ALIAS = { ["trash-2"] = "trash", ["gear"] = "settings", ["grid"] = "grid-3x3", ["person-running"] = "footprints", ["alert-triangle"] = "triangle-alert", ["alert-circle"] = "circle-alert", ["check-circle"] = "circle-check", ["check-circle-2"] = "circle-check-big", ["x-circle"] = "circle-x", ["help-circle"] = "circle-question-mark", ["more-horizontal"] = "ellipsis", ["more-vertical"] = "ellipsis-vertical", ["edit"] = "pencil", ["edit-2"] = "pencil", ["edit-3"] = "pencil-line", ["home"] = "house", ["unlock"] = "lock-open", ["bar-chart"] = "chart-bar", ["bar-chart-2"] = "chart-bar", ["loader-2"] = "loader-circle", ["sliders"] = "sliders-horizontal", ["filter"] = "funnel", ["wand-2"] = "wand-sparkles", ["play-circle"] = "circle-play", ["pause-circle"] = "circle-pause", ["stop-circle"] = "circle-stop", ["user-circle"] = "circle-user", ["plus-circle"] = "circle-plus", ["minus-circle"] = "circle-minus", ["pie-chart"] = "chart-pie", ["line-chart"] = "chart-line", ["shield-close"] = "shield-x", ["sort-asc"] = "arrow-up-narrow-wide", ["sort-desc"] = "arrow-down-wide-narrow", ["verified"] = "badge-check", ["file-warning"] = "file-exclamation-point" }

                function I.load()
                    if I.module then return I.module end
                    I.tried = true
                    local idx = {}
                    for i, n in ipairs(string.split(LUCIDE_N, ",")) do idx[n] = i end
                    local regs = string.split(LUCIDE_R, ";")
                    I.module = {
                        GetAsset = function(name)
                            local i = idx[name] or idx[LUCIDE_ALIAS[name] or ""]
                            local r = i and regs[i]
                            if not r then return nil end
                            local p = string.split(r, ",")
                            return { IconName = name, Url = LUCIDE_SHEETS[tonumber(p[1])], ImageRectSize = LUCIDE_RECT,
                                ImageRectOffset = Vector2.new(tonumber(p[2]), tonumber(p[3])) }
                        end,
                    }
                    local waiting = I.waiting
                    I.waiting = {}
                    for _, fn in ipairs(waiting) do pcall(fn) end
                    return I.module
                end

                function I.resolve(name)
                    if not name or name == "" then return nil end
                    if type(name) == "number" or tostring(name):match("^%d+$") then
                        return { Url = "rbxassetid://" .. tostring(name), ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
                    end
                    if tostring(name):match("^rbx") then
                        return { Url = tostring(name), ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
                    end
                    if not I.module then I.load() end
                    if not I.module then return nil end
                    local ok, icon = pcall(I.module.GetAsset, name)
                    if ok and type(icon) == "table" then return icon end
                    return nil
                end

                function I.apply(img, name)
                    if typeof(img) ~= "Instance" then return end
                    local function set()
                        local icon = I.resolve(name)
                        if icon then
                            img.Image = icon.Url
                            img.ImageRectOffset = icon.ImageRectOffset or Vector2.zero
                            img.ImageRectSize = icon.ImageRectSize or Vector2.zero
                            img.Visible = true
                        end
                    end
                    if not I.module then I.load() end
                    set()
                end
            end

            do
                local S = { volume = 0.5, enabled = true, cache = {}, folder = "PulseHub/nova" }
                Nova.Sound = S

                local RATE = 22050

                local function clampUnit(v)
                    if v < -1 then return -1 end
                    if v > 1 then return 1 end
                    return v
                end

                local function wav(samples)
                    local n = #samples
                    local parts = { "RIFF", string.pack("<I4", 36 + n * 2), "WAVE", "fmt ", string.pack("<I4I2I2I4I4I2I2", 16, 1, 1, RATE, RATE * 2, 2, 16), "data", string.pack("<I4", n * 2) }
                    local body = table.create(n)
                    for i = 1, n do
                        local v = math.floor(clampUnit(samples[i]) * 32767)
                        body[i] = string.pack("<i2", v)
                    end
                    return table.concat(parts) .. table.concat(body)
                end

                local function synth(spec)
                    local dur = spec.dur
                    local n = math.floor(RATE * dur)
                    local out = table.create(n)
                    local phase = {}
                    for i = 1, n do
                        local t = (i - 1) / RATE
                        local p = t / dur
                        local v = 0
                        for k, tone in ipairs(spec.tones) do
                            local f = tone.f0 + (tone.f1 - tone.f0) * math.min(1, p / (tone.glide or 1))
                            phase[k] = (phase[k] or 0) + 2 * math.pi * f / RATE
                            local env = math.exp(-t * (tone.decay or 30)) * math.min(1, t / (tone.attack or 0.002))
                            if tone.start and t < tone.start then env = 0 end
                            if tone.start and t >= tone.start then env = math.exp(-(t - tone.start) * (tone.decay or 30)) * math.min(1, (t - tone.start) / (tone.attack or 0.002)) end
                            v = v + math.sin(phase[k]) * env * (tone.amp or 0.5)
                        end
                        if spec.noise then v = v + (math.random() * 2 - 1) * spec.noise * math.exp(-t * 90) end
                        out[i] = v
                    end
                    return out
                end

                S.specs = {
                    click = { dur = 0.07, tones = { { f0 = 1900, f1 = 1300, decay = 70, amp = 0.55 }, { f0 = 3800, f1 = 2600, decay = 120, amp = 0.18 } }, noise = 0.05 },
                    hover = { dur = 0.035, tones = { { f0 = 2600, f1 = 2400, decay = 160, amp = 0.22 } } },
                    on = { dur = 0.12, tones = { { f0 = 880, f1 = 880, decay = 40, amp = 0.4 }, { f0 = 1320, f1 = 1320, decay = 40, amp = 0.4, start = 0.045 } } },
                    off = { dur = 0.12, tones = { { f0 = 1320, f1 = 1320, decay = 40, amp = 0.35 }, { f0 = 880, f1 = 880, decay = 40, amp = 0.35, start = 0.045 } } },
                    open = { dur = 0.22, tones = { { f0 = 520, f1 = 980, glide = 0.5, decay = 16, amp = 0.35 }, { f0 = 1040, f1 = 1960, glide = 0.5, decay = 22, amp = 0.12 } } },
                    close = { dur = 0.18, tones = { { f0 = 980, f1 = 520, glide = 0.6, decay = 20, amp = 0.3 } } },
                    notify = { dur = 0.45, tones = { { f0 = 1175, f1 = 1175, decay = 9, amp = 0.3 }, { f0 = 1568, f1 = 1568, decay = 9, amp = 0.28, start = 0.09 } } },
                    tick = { dur = 0.025, tones = { { f0 = 3200, f1 = 3000, decay = 220, amp = 0.16 } } },
                }

                function S.asset(name)
                    if S.cache[name] ~= nil then return S.cache[name] end
                    S.cache[name] = false
                    local ok, id = pcall(function()
                        if not (writefile and getcustomasset) then return nil end
                        if isfolder and makefolder then
                            if not isfolder("PulseHub") then makefolder("PulseHub") end
                            if not isfolder(S.folder) then makefolder(S.folder) end
                        end
                        local path = S.folder .. "/" .. name .. ".wav"
                        if not (isfile and isfile(path)) then writefile(path, wav(synth(S.specs[name]))) end
                        return getcustomasset(path)
                    end)
                    if ok and id then S.cache[name] = id end
                    return S.cache[name]
                end

                function S.play(name, volume)
                    if not S.enabled or S.volume <= 0 then return end
                    local id = S.asset(name)
                    if not id then return end
                    local host = S.host
                    if not host then return end
                    local snd = Instance.new("Sound")
                    snd.SoundId = id
                    snd.Volume = S.volume * (volume or 1)
                    snd.Parent = host
                    snd:Play()
                    task.delay(1, function() snd:Destroy() end)
                end

                function S.preload()
                    task.spawn(function()
                        for name in pairs(S.specs) do pcall(S.asset, name) end
                    end)
                end
            end

            do
                local St = {}
                Nova.Store = St
                local Http = Nova.Services.HttpService

                function St.new(path)
                    local self = { path = path, data = {}, dirty = false }
                    pcall(function()
                        if path and isfile and readfile and isfile(path) then
                            local raw = Http:JSONDecode(readfile(path))
                            if type(raw) == "table" then self.data = raw end
                        end
                    end)
                    function self.get(key, default)
                        local v = self.data[key]
                        if v == nil then return default end
                        return v
                    end
                    function self.set(key, value)
                        if self.data[key] == value then return end
                        self.data[key] = value
                        self.save()
                    end
                    function self.save()
                        if self.dirty then return end
                        self.dirty = true
                        task.delay(0.6, function()
                            self.dirty = false
                            pcall(function()
                                if not (path and writefile) then return end
                                if isfolder and makefolder then
                                    if not isfolder("PulseHub") then makefolder("PulseHub") end
                                    if not isfolder("PulseHub/nova") then makefolder("PulseHub/nova") end
                                end
                                writefile(path, Http:JSONEncode(self.data))
                            end)
                        end)
                    end
                    return self
                end
            end

            do
                local R = Nova.Refresh
                table.insert(R.full, function(inst) Nova.Theme.applyOne(inst) end)
                table.insert(R.full, Nova.U.radiusOne)
                table.insert(R.full, Nova.Font.fontOne)
                table.insert(R.full, Nova.Font.sizeOne)
            end

            do
                local X = { cache = {}, folder = "PulseHub/nova/tex", version = "v7" }
                Nova.Tex = X

                local crcTable
                local function crc32(s)
                    if not crcTable then
                        crcTable = table.create(256)
                        for i = 0, 255 do
                            local c = i
                            for _ = 1, 8 do
                                if bit32.band(c, 1) == 1 then
                                    c = bit32.bxor(0xEDB88320, bit32.rshift(c, 1))
                                else
                                    c = bit32.rshift(c, 1)
                                end
                            end
                            crcTable[i] = c
                        end
                    end
                    local b = buffer.fromstring(s)
                    local c = 0xFFFFFFFF
                    for i = 0, buffer.len(b) - 1 do
                        c = bit32.bxor(crcTable[bit32.band(bit32.bxor(c, buffer.readu8(b, i)), 0xFF)], bit32.rshift(c, 8))
                    end
                    return bit32.bxor(c, 0xFFFFFFFF)
                end

                local function chunk(kind, data)
                    return string.pack(">I4", #data) .. kind .. data .. string.pack(">I4", crc32(kind .. data))
                end

                function X.encode(w, h, pixel)
                    local rowLen = w * 4 + 1
                    local raw = buffer.create(rowLen * h)
                    local o = 0
                    for y = 0, h - 1 do
                        buffer.writeu8(raw, o, 0)
                        o += 1
                        for x = 0, w - 1 do
                            local r, g, b, a = pixel(x, y)
                            buffer.writeu8(raw, o, math.clamp(math.floor(r + 0.5), 0, 255))
                            buffer.writeu8(raw, o + 1, math.clamp(math.floor(g + 0.5), 0, 255))
                            buffer.writeu8(raw, o + 2, math.clamp(math.floor(b + 0.5), 0, 255))
                            buffer.writeu8(raw, o + 3, math.clamp(math.floor(a + 0.5), 0, 255))
                            o += 4
                        end
                    end
                    local n = buffer.len(raw)
                    local s1, s2 = 1, 0
                    for i = 0, n - 1 do
                        s1 = (s1 + buffer.readu8(raw, i)) % 65521
                        s2 = (s2 + s1) % 65521
                    end
                    local parts = { "\120\1" }
                    local pos = 0
                    while pos < n do
                        local len = math.min(65535, n - pos)
                        local final = (pos + len >= n) and 1 or 0
                        table.insert(parts, string.char(final) .. string.pack("<I2I2", len, bit32.bxor(len, 0xFFFF)))
                        table.insert(parts, buffer.readstring(raw, pos, len))
                        pos += len
                    end
                    table.insert(parts, string.pack(">I4", s2 * 65536 + s1))
                    local ihdr = string.pack(">I4I4", w, h) .. string.char(8, 6, 0, 0, 0)
                    return "\137PNG\r\n\26\n" .. chunk("IHDR", ihdr) .. chunk("IDAT", table.concat(parts)) .. chunk("IEND", "")
                end

                local function smooth(e0, e1, x)
                    local t = math.clamp((x - e0) / (e1 - e0), 0, 1)
                    return t * t * (3 - 2 * t)
                end

                local function sdBox(px, py, cx, cy, hw, hh, r)
                    local dx = math.abs(px - cx) - (hw - r)
                    local dy = math.abs(py - cy) - (hh - r)
                    local ox, oy = math.max(dx, 0), math.max(dy, 0)
                    return math.sqrt(ox * ox + oy * oy) + math.min(math.max(dx, dy), 0) - r
                end

                local function cover(sd)
                    return math.clamp(0.5 - sd, 0, 1)
                end

                local function hash(x, y, seed)
                    local n = math.sin(x * 127.1 + y * 311.7 + seed * 74.7) * 43758.5453
                    return n - math.floor(n)
                end

                local function blobs(list)
                    return function(nx, ny)
                        local sum = 0
                        for _, b in ipairs(list) do
                            local dx, dy = (nx - b[1]) / b[3], (ny - b[2]) / b[4]
                            sum += b[5] * math.exp(-(dx * dx + dy * dy))
                        end
                        return sum
                    end
                end

                X.specs = {
                    grain = { w = 128, h = 128, tile = true, px = function()
                        return function(x, y)
                            local v = hash(x, y, 3.3) * 0.7 + hash(x * 0.5, y * 0.5, 9.1) * 0.3
                            return 255, 255, 255, v * v * 64
                        end
                    end },
                    glow = { w = 256, h = 256, px = function()
                        return function(x, y)
                            local d = math.sqrt(((x + 0.5) / 128 - 1) ^ 2 + ((y + 0.5) / 128 - 1) ^ 2)
                            local a = math.max(0, 1 - d)
                            return 255, 255, 255, (a ^ 2.3) * 255
                        end
                    end },
                    vignette = { w = 256, h = 256, px = function()
                        return function(x, y)
                            local dx, dy = (x + 0.5) / 128 - 1, (y + 0.5) / 128 - 1
                            local d = math.sqrt(dx * dx * 0.8 + dy * dy)
                            return 0, 0, 0, smooth(0.45, 1.35, d) * 255
                        end
                    end },
                    knob = { w = 128, h = 128, px = function()
                        return function(x, y)
                            local cx, cy = x + 0.5 - 64, y + 0.5 - 64
                            local d = math.sqrt(cx * cx + cy * cy)
                            local m = math.clamp(63 - d + 0.5, 0, 1)
                            local v = 1 - 0.2 * ((cy + 63) / 126)
                            v = v * (1 - 0.14 * math.clamp((d - 52) / 11, 0, 1))
                            local sx, sy = (cx + 14) / 34, (cy + 30) / 22
                            local spec = math.max(0, 1 - (sx * sx + sy * sy))
                            v = math.min(1, v + 0.1 * spec ^ 1.5)
                            return 255 * v, 255 * v, 255 * v, 255 * m
                        end
                    end },
                    pillfill = { w = 96, h = 48, px = function()
                        return function(x, y)
                            return 255, 255, 255, 255 * cover(sdBox(x + 0.5, y + 0.5, 48, 24, 48, 24, 24))
                        end
                    end },
                    trackshade = { w = 96, h = 48, px = function()
                        return function(x, y)
                            local px, py = x + 0.5, y + 0.5
                            local sd = sdBox(px, py, 48, 24, 48, 24, 24)
                            local depth = -sd
                            local m = cover(sd)
                            local v = py / 48
                            local topW = math.clamp(1.15 - 1.6 * v, 0, 1)
                            local s = 0.55 * (1 - smooth(0, 11, depth)) * topW + 0.16 * (1 - smooth(0, 5, depth))
                            s = math.clamp(s, 0, 0.7)
                            local l = 0.1 * (1 - smooth(0, 5, depth)) * math.clamp((v - 0.5) * 3, 0, 1)
                            local a = s + l * (1 - s)
                            local rgb = a > 0 and (255 * l * (1 - s) / a) or 0
                            return rgb, rgb, rgb, 255 * a * m
                        end
                    end },
                    dots = { w = 24, h = 24, tile = true, px = function()
                        return function(x, y)
                            local d = math.sqrt((x + 0.5 - 12) ^ 2 + (y + 0.5 - 12) ^ 2)
                            return 255, 255, 255, 255 * math.clamp(1.25 - d, 0, 1)
                        end
                    end },
                    grid = { w = 40, h = 40, tile = true, px = function()
                        return function(x, y)
                            local a = (x == 0 or y == 0) and 1 or 0
                            if x == 0 and y == 0 then a = 1 end
                            return 255, 255, 255, 255 * a
                        end
                    end },
                    diag = { w = 20, h = 20, tile = true, px = function()
                        return function(x, y)
                            local t = ((x + y) % 10) / 10
                            return 255, 255, 255, 255 * (1 - smooth(0.12, 0.3, math.abs(t - 0.06) * 2))
                        end
                    end },
                    crosses = { w = 32, h = 32, tile = true, px = function()
                        return function(x, y)
                            local dx, dy = math.abs(x + 0.5 - 16), math.abs(y + 0.5 - 16)
                            local arm = (dx < 0.9 and dy < 4.2) or (dy < 0.9 and dx < 4.2)
                            return 255, 255, 255, arm and 255 or 0
                        end
                    end },
                    scan = { w = 4, h = 4, tile = true, px = function()
                        return function(x, y)
                            return 255, 255, 255, y == 0 and 255 or 0
                        end
                    end },
                    stripes = { w = 32, h = 32, tile = true, px = function()
                        return function(x, y)
                            local t = math.sin((x + y) / 16 * math.pi * 2) * 0.5 + 0.5
                            return 255, 255, 255, 255 * t * t
                        end
                    end },
                    checker = { w = 16, h = 16, tile = true, px = function()
                        return function(x, y)
                            local c = ((math.floor(x / 8) + math.floor(y / 8)) % 2 == 0) and 74 or 52
                            return c, c, c + 4, 255
                        end
                    end },
                    meshA = { w = 256, h = 160, px = function()
                        local f = blobs({ { 0.12, 0.18, 0.42, 0.55, 1.0 }, { 0.62, 0.05, 0.32, 0.4, 0.6 }, { 0.88, 0.72, 0.4, 0.55, 0.9 }, { 0.35, 0.95, 0.5, 0.35, 0.55 } })
                        return function(x, y)
                            local a = math.clamp(f((x + 0.5) / 256, (y + 0.5) / 160), 0, 1)
                            local u, v = (x + 0.5) / 256, (y + 0.5) / 160
                            local edge = smooth(0, 0.2, u) * smooth(0, 0.2, 1 - u) * smooth(0, 0.2, v) * smooth(0, 0.2, 1 - v)
                            return 255, 255, 255, 255 * a ^ 1.15 * edge
                        end
                    end },
                    meshB = { w = 256, h = 160, px = function()
                        local f = blobs({ { 0.85, 0.15, 0.36, 0.5, 0.95 }, { 0.2, 0.85, 0.45, 0.5, 0.85 }, { 0.55, 0.5, 0.3, 0.3, 0.35 } })
                        return function(x, y)
                            local a = math.clamp(f((x + 0.5) / 256, (y + 0.5) / 160), 0, 1)
                            local u, v = (x + 0.5) / 256, (y + 0.5) / 160
                            local edge = smooth(0, 0.2, u) * smooth(0, 0.2, 1 - u) * smooth(0, 0.2, v) * smooth(0, 0.2, 1 - v)
                            return 255, 255, 255, 255 * a ^ 1.15 * edge
                        end
                    end },
                    shadow9 = { w = 96, h = 96, slice = Rect.new(40, 40, 56, 56), px = function()
                        return function(x, y)
                            local sd = sdBox(x + 0.5, y + 0.5, 48, 48, 16, 16, 10)
                            local a = 1 / (1 + math.exp(sd / 4.6))
                            return 0, 0, 0, 255 * a * 0.9
                        end
                    end },
                }

                local RB = { 3, 5, 7, 9, 12, 15, 19, 24, 30, 38 }
                local KINDS = { rim9 = 14, gloss9 = 14, tile9 = 15, plate9 = 14 }
                X.buckets = RB
                X.kinds = KINDS
                X.tracked = Nova.U.newReg()

                local function roundSpec(kind, r)
                    local slice = r + 4
                    local S = math.max(64, 2 * (slice) + 24)
                    local half = S / 2
                    local k = S / 64
                    local px
                    if kind == "rim9" then
                        px = function()
                            return function(x, y)
                                local ax, ay = x + 0.5, y + 0.5
                                local sd = sdBox(ax, ay, half, half, half - 0.6, half - 0.6, r)
                                local line = math.clamp(1 - math.abs(sd + 0.5) / 1.05, 0, 1)
                                local g = 0.95 - 0.86 * smooth(0, S, ay)
                                local side = 0.75 + 0.25 * (1 - math.abs(ax - half) / half)
                                return 255, 255, 255, 255 * line * g * side
                            end
                        end
                    elseif kind == "gloss9" then
                        px = function()
                            return function(x, y)
                                local ax, ay = x + 0.5, y + 0.5
                                local sd = sdBox(ax, ay, half, half, half, half, r)
                                local m = cover(sd)
                                local hl = 1 - smooth(0, 34 * k, ay)
                                local edge = (1 - smooth(0, 2.4, -sd)) * (1 - smooth(0, 34 * k, ay))
                                local a = 0.2 * hl + 0.16 * edge
                                return 255, 255, 255, 255 * a * m
                            end
                        end
                    elseif kind == "tile9" then
                        px = function()
                            return function(x, y)
                                local ax, ay = x + 0.5, y + 0.5
                                local sd = sdBox(ax, ay, half, half, half, half, r)
                                local m = cover(sd)
                                local v = 1 - 0.24 * smooth(0, S, ay)
                                v = math.min(1, v + 0.16 * (1 - smooth(0, 3.2, ay)))
                                v = v * (1 - 0.1 * (1 - smooth(0, 3, -sd)) * smooth(S * 0.47, S, ay))
                                return 255 * v, 255 * v, 255 * v, 255 * m
                            end
                        end
                    else
                        px = function()
                            return function(x, y)
                                local ax, ay = x + 0.5, y + 0.5
                                local sd = sdBox(ax, ay, half, half, half, half, r)
                                local m = cover(sd)
                                local v = 1 - 0.1 * smooth(0, S, ay)
                                return 255 * v, 255 * v, 255 * v, 255 * m
                            end
                        end
                    end
                    return { w = S, h = S, slice = Rect.new(slice, slice, S - slice, S - slice), px = px }
                end

                function X.resolve(kind, base)
                    local target = base * Nova.U.radiusMult
                    local best, bestErr = RB[1], math.huge
                    for _, rb in ipairs(RB) do
                        local err = math.abs(math.log(math.max(target, 0.5) / rb))
                        if err < bestErr then best, bestErr = rb, err end
                    end
                    return kind .. "@" .. best, math.max(target / best, 0.3)
                end

                function X.cleanup()
                    pcall(function()
                        if not (listfiles and delfile and isfolder and isfolder(X.folder)) then return end
                        for _, f in ipairs(listfiles(X.folder)) do
                            if f:match("_v%d+%.png$") and not f:match("_" .. X.version .. "%.png$") then
                                pcall(delfile, f)
                            end
                        end
                    end)
                end

                function X.get(name)
                    local cached = X.cache[name]
                    if cached ~= nil then return cached or nil end
                    X.cache[name] = false
                    local spec = X.specs[name]
                    if not spec then
                        local kind, r = string.match(name, "^(%a+%d)@(%d+)$")
                        if kind and KINDS[kind] then
                            spec = roundSpec(kind, tonumber(r))
                            X.specs[name] = spec
                        end
                    end
                    if not spec then return nil end
                    local ok, id = pcall(function()
                        if not (writefile and getcustomasset and buffer) then return nil end
                        if isfolder and makefolder then
                            if not isfolder("PulseHub") then makefolder("PulseHub") end
                            if not isfolder("PulseHub/nova") then makefolder("PulseHub/nova") end
                            if not isfolder(X.folder) then makefolder(X.folder) end
                        end
                        local path = X.folder .. "/" .. string.gsub(name, "@", "_r") .. "_" .. X.version .. ".png"
                        if not (isfile and isfile(path)) then
                            writefile(path, X.encode(spec.w, spec.h, spec.px()))
                        end
                        return getcustomasset(path)
                    end)
                    if ok and id then X.cache[name] = id end
                    return X.cache[name] or nil
                end

                function X.image(parent, name, props)
                    props = props or {}
                    local kind = KINDS[name] and name or nil
                    local base, tname, sscale
                    if kind then
                        base = KINDS[kind] * (props.SliceScale or 0.5)
                        tname, sscale = X.resolve(kind, base)
                    else
                        tname = name
                    end
                    local id = X.get(tname)
                    if not id then return nil end
                    local spec = X.specs[tname]
                    local img = Instance.new("ImageLabel")
                    img.Name = props.Name or ("Tex_" .. name)
                    img.BackgroundTransparency = 1
                    img.BorderSizePixel = 0
                    img.Image = id
                    if spec.slice then
                        img.ScaleType = Enum.ScaleType.Slice
                        img.SliceCenter = spec.slice
                        img.SliceScale = sscale or props.SliceScale or 0.5
                    elseif spec.tile then
                        img.ScaleType = Enum.ScaleType.Tile
                        img.TileSize = UDim2.fromOffset(spec.w, spec.h)
                    end
                    for k, v in pairs(props) do
                        if k ~= "Name" and k ~= "SliceScale" and k ~= "Parent" then img[k] = v end
                    end
                    img.Parent = parent
                    if kind then X.tracked[img] = { kind = kind, base = base } end
                    return img
                end

                function X.retarget(img)
                    local info = X.tracked[img]
                    if not info then return end
                    local tname, sscale = X.resolve(info.kind, info.base)
                    local id = X.get(tname)
                    local spec = X.specs[tname]
                    if id and spec then
                        img.Image = id
                        img.SliceCenter = spec.slice
                        img.SliceScale = sscale
                    end
                end

                function X.setRadius()
                    Nova.Refresh.run("texradius", X.retarget, function()
                        for img in pairs(X.tracked) do X.retarget(img) end
                    end)
                end

                table.insert(Nova.Refresh.full, X.retarget)

                function X.preload()
                    if X.preloading then return end
                    X.preloading = true
                    X.cleanup()
                    task.spawn(function()
                        for name in pairs(X.specs) do
                            pcall(X.get, name)
                            task.wait()
                        end
                        for kind in pairs(KINDS) do
                            for _, rb in ipairs(RB) do
                                pcall(X.get, kind .. "@" .. rb)
                                task.wait()
                            end
                        end
                    end)
                end
            end

            do
                local U, M, T, F, I, S, X = Nova.U, Nova.Motion, Nova.Theme, Nova.Font, Nova.Icons, Nova.Sound, Nova.Tex
                local new, tween, bind = U.new, M.tween, T.bind
                local UIS, RunService = Nova.Services.UserInputService, Nova.Services.RunService

                local Window = {}
                Window.__index = Window
                Nova.WindowClass = Window

                local HEADER = 64
                Window.HEADER = HEADER
                Window.BackgroundStyles = { "Aurora", "Grid", "Dots", "Diagonal", "Crosses", "Scanlines", "Noise", "Plain" }

                local function label(props)
                    local l = new("TextLabel", {
                        BackgroundTransparency = 1,
                        FontFace = props.Font or F.Medium(),
                        TextSize = props.Size or 14,
                        Text = props.Text or "",
                        TextXAlignment = props.AlignX or Enum.TextXAlignment.Left,
                        TextYAlignment = props.AlignY or Enum.TextYAlignment.Center,
                        TextTruncate = props.Truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
                        TextWrapped = props.Wrap or false,
                        RichText = props.Rich or false,
                        Size = props.Box or UDim2.new(1, 0, 0, 18),
                        Position = props.Pos or UDim2.new(),
                        AnchorPoint = props.Anchor or Vector2.zero,
                        AutomaticSize = props.Auto or Enum.AutomaticSize.None,
                        ZIndex = props.Z or 1,
                        Name = props.Name or "Label",
                        Parent = props.Parent,
                    })
                    bind(l, "TextColor3", props.Color or "Text")
                    return l
                end
                Nova.label = label

                local function icon(props)
                    local img = new("ImageLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(props.Size or 18, props.Size or 18),
                        Position = props.Pos or UDim2.new(),
                        AnchorPoint = props.Anchor or Vector2.zero,
                        Visible = false,
                        ZIndex = props.Z or 1,
                        Name = props.Name or "Icon",
                        Parent = props.Parent,
                    })
                    bind(img, "ImageColor3", props.Color or "Text")
                    I.apply(img, props.Icon)
                    return img
                end
                Nova.icon = icon

                function Nova.tile(parent, props)
                    local t = X.image(parent, props.Tex or "tile9", {
                        Name = props.Name or "Tile",
                        Size = props.Size or UDim2.fromOffset(30, 30),
                        Position = props.Pos or UDim2.new(),
                        AnchorPoint = props.Anchor or Vector2.zero,
                        SliceScale = props.SliceScale or 0.5,
                        ImageTransparency = props.Alpha or 0,
                        ZIndex = props.Z or 1,
                    })
                    if t then
                        bind(t, "ImageColor3", props.Color or "Accent")
                        return t, true
                    end
                    local f = new("Frame", {
                        Name = props.Name or "Tile",
                        Size = props.Size or UDim2.fromOffset(30, 30),
                        Position = props.Pos or UDim2.new(),
                        AnchorPoint = props.Anchor or Vector2.zero,
                        BorderSizePixel = 0,
                        BackgroundTransparency = props.Alpha or 0,
                        ZIndex = props.Z or 1,
                        Parent = parent,
                    })
                    U.corner(f, props.Radius or math.floor(15 * (props.SliceScale or 0.5) + 0.5))
                    bind(f, "BackgroundColor3", props.Color or "Accent")
                    return f, false
                end

                function Nova:CreateWindow(opts)
                    opts = opts or {}
                    local self = setmetatable({}, Window)
                    self.Tabs, self.TabList, self.Groups = {}, {}, {}
                    self.Conns = {}
                    self.Popups, self.Floats = {}, {}
                    self.Key = opts.Key or Enum.KeyCode.RightControl
                    self.Size = opts.Size or Vector2.new(860, 620)
                    self.MinSize = opts.MinSize or Vector2.new(660, 420)
                    self.IsOpen = false
                    self.FloatZ = 10
                    self.Initial = tostring(opts.Initial or string.sub(opts.Title or "N", 1, 1))
                    self.LogoAsset, self.LogoGlow = opts.Logo, opts.LogoGlow
                    table.insert(Nova.Windows, self)
                    U.startSweep()

                    local guiName = opts.GuiName or "NovaUI"
                    local st = Nova.Store.new(opts.StateFile or ("PulseHub/nova/ui_" .. guiName .. ".json"))
                    self.State = st
                    self.StateDefaults = type(opts.StateDefaults) == "table" and opts.StateDefaults or nil
                    if type(opts.StateDefaults) == "table" then
                        local H = Nova.Services.HttpService
                        for k, v in pairs(opts.StateDefaults) do
                            if st.data[k] == nil then
                                if type(v) == "table" then
                                    local okc, c = pcall(function() return H:JSONDecode(H:JSONEncode(v)) end)
                                    st.data[k] = okc and c or v
                                else
                                    st.data[k] = v
                                end
                            end
                        end
                    end
                    do
                        local sv = st.get("size", nil)
                        if type(sv) == "table" and tonumber(sv[1]) and tonumber(sv[2]) then
                            self.Size = Vector2.new(math.max(self.MinSize.X, tonumber(sv[1])), math.max(self.MinSize.Y, tonumber(sv[2])))
                        end
                    end
                    local accentHex = st.get("accent", nil)
                    if type(accentHex) == "string" then
                        pcall(function() T.set("Accent", Color3.fromHex(accentHex)) end)
                    elseif opts.Accent then
                        T.set("Accent", opts.Accent)
                    end
                    local baseName = st.get("base", opts.Base or "Midnight")
                    if baseName ~= "Midnight" then T.setBase(baseName) end
                    local panelHex = st.get("panel", nil)
                    if type(panelHex) == "string" then
                        local ok, pc = pcall(Color3.fromHex, panelHex)
                        if ok and typeof(pc) == "Color3" then
                            self.PanelColor = pc
                            T.setMany(T.panelFrom(pc))
                            T.base = "Custom"
                        end
                    end
                    U.setRadius(tonumber(st.get("radius", opts.Radius or 1)) or 1)
                    F.setFamily(st.get("font", opts.Font or "Builder Sans"))
                    F.setScale(tonumber(st.get("textScale", 1)) or 1)
                    S.enabled = st.get("sounds", true) ~= false
                    S.volume = tonumber(st.get("volume", 0.5)) or 0.5
                    M.enabled = st.get("motion", true) ~= false
                    self.DefaultScale = math.clamp(tonumber(opts.Scale) or 1, 0.6, 1.5)
                    self.UserScale = math.clamp(tonumber(st.get("scale", self.DefaultScale)) or self.DefaultScale, 0.6, 1.5)
                    self.BlurEnabled = st.get("blur", opts.Blur == true) == true
                    self.BgStyle = st.get("bgStyle", opts.Background or "Aurora")
                    self.CardStyle = st.get("cardStyle", opts.CardStyle or "Glass")
                    self.BgIntensity = math.clamp(tonumber(st.get("bgIntensity", 1)) or 1, 0, 1.5)
                    self.Opacity = math.clamp(tonumber(st.get("opacity", 1)) or 1, 0.5, 1)
                    self.TooltipsOn = st.get("tooltips", true) ~= false
                    self.LauncherOn = st.get("launcher", opts.Launcher ~= false) ~= false
                    self.BaseSize = self.Size
                    self.AutoFit = st.get("autoFit", opts.AutoFit ~= false) ~= false
                    self.ScaleHooks = {}
                    self.ScreenFactor, self.OverlayScale = 1, 1
                    local forceTouch = false
                    pcall(function() forceTouch = getgenv().NOVA_FORCE_TOUCH == true end)
                    self.IsTouch = forceTouch or (UIS.TouchEnabled and not UIS.KeyboardEnabled)
                    do
                        local tsz = st.get("touchSize", nil)
                        if self.IsTouch and type(tsz) == "table" and tonumber(tsz[1]) and tonumber(tsz[2]) then
                            self.TouchSize = Vector2.new(tonumber(tsz[1]), tonumber(tsz[2]))
                        end
                    end

                    I.load()
                    S.preload()
                    X.preload()

                    local gui = new("ScreenGui", {
                        Name = guiName,
                        IgnoreGuiInset = true,
                        ResetOnSpawn = false,
                        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                        DisplayOrder = 999999,
                    })
                    U.protect(gui)
                    gui.Parent = opts.Parent or U.hostGui()
                    self.Gui = gui
                    local parking = new("ScreenGui", { Name = guiName .. "_Parked", Enabled = false, ResetOnSpawn = false })
                    U.protect(parking)
                    parking.Parent = gui.Parent
                    self.Parking = parking
                    S.host = gui

                    local rootPos = UDim2.fromScale(0.5, 0.5)
                    do
                        local wp = st.get(self.IsTouch and "touchPos" or "winPos", nil)
                        if type(wp) == "table" and tonumber(wp[1]) and tonumber(wp[2]) then
                            rootPos = UDim2.new(0.5, math.floor(tonumber(wp[1])), 0.5, math.floor(tonumber(wp[2])))
                        end
                    end
                    local root = new("Frame", {
                        Name = "Root",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = rootPos,
                        Size = UDim2.fromOffset(self.Size.X, self.Size.Y),
                        BackgroundTransparency = 1,
                        Visible = false,
                        ZIndex = 1,
                        Parent = gui,
                    })
                    self.Root = root
                    self.Scale = new("UIScale", { Parent = root })

                    local shadow = X.image(root, "shadow9", { Name = "WindowShadow", Position = UDim2.fromOffset(-40, -30), Size = UDim2.new(1, 80, 1, 90), SliceScale = 1.2, ImageTransparency = 0.45, ZIndex = 0 })
                    self.WindowShadow = shadow

                    local win = new("CanvasGroup", {
                        Name = "Window",
                        Size = UDim2.fromScale(1, 1),
                        BorderSizePixel = 0,
                        GroupTransparency = 1,
                        BackgroundTransparency = 1 - self.Opacity,
                        ZIndex = 1,
                        Parent = root,
                    })
                    bind(win, "BackgroundColor3", "Background")
                    U.corner(win, 14)
                    self.Win = win

                    self:_buildBackdrop()
                    self:_buildSidebar(opts)

                    local sw = self.SidebarWidth
                    local main = new("Frame", { Name = "Main", Position = UDim2.fromOffset(sw, 0), Size = UDim2.new(1, -sw, 1, 0), BackgroundTransparency = 1, ZIndex = 1, Parent = win })
                    self.Main = main
                    local header = new("Frame", { Name = "Header", Size = UDim2.new(1, 0, 0, HEADER), BackgroundTransparency = 1, Parent = main })
                    self.Header = header
                    self.HeaderTitle = label({ Parent = header, Text = "", Font = F.Bold(), Size = 21, Pos = UDim2.fromOffset(24, 13), Box = UDim2.new(1, -110, 0, 26), Truncate = true })
                    self.HeaderDesc = label({ Parent = header, Text = "", Font = F.Medium(), Size = 12, Pos = UDim2.fromOffset(24, 39), Box = UDim2.new(1, -110, 0, 14), Color = "Muted", Truncate = true })

                    local line = new("Frame", { Name = "Line", Position = UDim2.fromOffset(20, HEADER - 1), Size = UDim2.new(1, -40, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.88, Parent = header })
                    bind(line, "BackgroundColor3", "Glass")
                    new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0), NumberSequenceKeypoint.new(0.85, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = line })

                    self:_buildClose(header)

                    local body = new("Frame", { Name = "Body", Position = UDim2.fromOffset(0, HEADER), Size = UDim2.new(1, 0, 1, -HEADER), BackgroundTransparency = 1, ClipsDescendants = true, Parent = main })
                    self.Body = body

                    local grip = new("TextButton", { Name = "Resize", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -5, 1, -5), Size = UDim2.fromOffset(18, 18), ZIndex = 40, Parent = win })
                    for i = 0, 2 do
                        for j = 0, 2 - i do
                            local dot = new("Frame", { Size = UDim2.fromOffset(2, 2), Position = UDim2.fromOffset(13 - i * 4, 13 - j * 4), BorderSizePixel = 0, ZIndex = 40, Parent = grip })
                            bind(dot, "BackgroundColor3", "Faint")
                            U.corner(dot, UDim.new(1, 0))
                        end
                    end

                    local edge = X.image(win, "rim9", { Name = "WindowRim", Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.55, ZIndex = 45 })
                    if edge then bind(edge, "ImageColor3", "Glass") end

                    self.FloatLayer = new("Frame", { Name = "Floats", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Visible = true, Parent = gui })
                    self.FloatScale = new("UIScale", { Parent = self.FloatLayer })
                    self.PopLayer = new("Frame", { Name = "Popups", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Parent = gui })
                    self.PopScale = new("UIScale", { Parent = self.PopLayer })
                    self.Overlay = self.PopLayer
                    local catcher = new("TextButton", { Name = "Catcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 1, Parent = self.PopLayer })
                    catcher.MouseButton1Click:Connect(function() self:ClosePopups() end)
                    catcher.MouseButton2Click:Connect(function() self:ClosePopups() end)
                    self.Catcher = catcher

                    self:_drag(header)
                    self:_drag(self.BrandFrame)
                    self:_resize(grip)
                    if self.IsTouch then
                        grip.Size = UDim2.fromOffset(30, 30)
                        grip.Position = UDim2.new(1, -4, 1, -4)
                        grip.BackgroundTransparency = 0.35
                        bind(grip, "BackgroundColor3", "Elevated")
                        U.corner(grip, 9)
                        for _, dot in ipairs(grip:GetChildren()) do
                            if dot:IsA("Frame") then
                                dot.Size = UDim2.fromOffset(3, 3)
                                dot.Position = UDim2.fromOffset(dot.Position.X.Offset + 8, dot.Position.Y.Offset + 8)
                                bind(dot, "BackgroundColor3", "Text")
                            end
                        end
                    end

                    local toasts = new("Frame", { Name = "Toasts", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, -20), Size = UDim2.new(0, 300, 1, -40), BackgroundTransparency = 1, ZIndex = 30, Parent = gui })
                    self.ToastScale = new("UIScale", { Parent = toasts })
                    self.Toasts = toasts
                    self.ToastList = {}

                    local tip = new("Frame", { Name = "Tooltip", Size = UDim2.fromOffset(10, 28), AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, Visible = false, ZIndex = 200, Parent = gui })
                    bind(tip, "BackgroundColor3", "Elevated")
                    U.corner(tip, 8)
                    local tipRim = X.image(tip, "rim9", { Position = UDim2.fromOffset(-11, 0), Size = UDim2.new(1, 22, 1, 0), SliceScale = 0.57, ImageTransparency = 0.5, ZIndex = 201 })
                    if tipRim then bind(tipRim, "ImageColor3", "Glass") else bind(U.stroke(tip, Color3.new(1, 1, 1), 1, 0.88), "Color", "Glass") end
                    U.pad(tip, 0, 11, 0, 11)
                    self.TipLabel = label({ Parent = tip, Text = "", Font = F.Medium(), Size = 12, Box = UDim2.new(0, 0, 1, 0), Auto = Enum.AutomaticSize.X, Z = 202, Color = "Text" })
                    self.Tip = tip
                    local tipScale = new("UIScale", { Parent = tip })
                    self:OnScreenScale(function(s)
                        if not tip.Parent then return false end
                        tipScale.Scale = s
                    end)

                    self:_launcher(opts)
                    self:_input()
                    self:_autoScale()
                    self:_applyBackground()
                    T.onChange(function(key)
                        if key == "Accent" and self.CardStyle == "Tinted" and not self.Destroyed then
                            for _, tab in ipairs(self.TabList) do
                                for _, sec in ipairs(tab.Sections) do pcall(function() self:_applyCardStyle(sec) end) end
                            end
                        end
                    end)
                    if self._initCards then self:_initCards() end
                    local savedKey = st.get("menuKey", nil)
                    if type(savedKey) == "string" and Enum.KeyCode[savedKey] then self.Key = Enum.KeyCode[savedKey] end
                    self:_syncFooter()
                    if self.SetWatermark and st.get("watermark", false) == true then self:SetWatermark(true) end
                    if self.SetKeybindList and st.get("keybindList", self.IsTouch == true) == true then self:SetKeybindList(true) end
                    return self
                end

                function Window:_buildBackdrop()
                    local win = self.Win
                    local bd = new("Frame", { Name = "Backdrop", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 0, Parent = win })
                    self.Backdrop = bd
                    local L = {}
                    L.meshA = X.image(bd, "meshA", { Name = "MeshA", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.25, 0.18), Size = UDim2.fromScale(1.5, 1.5), ImageTransparency = 0.84, ZIndex = 0 })
                    if L.meshA then bind(L.meshA, "ImageColor3", "Accent") end
                    L.meshB = X.image(bd, "meshB", { Name = "MeshB", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.85, 0.9), Size = UDim2.fromScale(1.4, 1.4), ImageTransparency = 0.9, ZIndex = 0 })
                    if L.meshB then bind(L.meshB, "ImageColor3", function(t) return t.Accent:Lerp(Color3.fromRGB(80, 110, 255), 0.55) end) end
                    L.auraA = X.image(bd, "glow", { Name = "AuraA", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(60, 10), Size = UDim2.fromOffset(640, 540), ImageTransparency = 0.84, ZIndex = 0 })
                    if L.auraA then bind(L.auraA, "ImageColor3", "Accent") end
                    L.auraB = X.image(bd, "glow", { Name = "AuraB", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 40, 1, 60), Size = UDim2.fromOffset(660, 480), ImageTransparency = 0.9, ZIndex = 0 })
                    if L.auraB then bind(L.auraB, "ImageColor3", "Accent") end
                    L.pattern = new("ImageLabel", { Name = "Pattern", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ImageTransparency = 1, ZIndex = 0, Parent = bd })
                    bind(L.pattern, "ImageColor3", "Glass")
                    L.vignette = X.image(bd, "vignette", { Name = "Vignette", Size = UDim2.fromScale(1, 1), ImageTransparency = 0.3, ZIndex = 0 })
                    L.grain = X.image(bd, "grain", { Name = "Grain", Size = UDim2.fromScale(1, 1), ImageTransparency = 0.82, ZIndex = 0 })
                    self.BgLayers = L
                    task.spawn(function()
                        local t = 0
                        while not self.Destroyed do
                            task.wait(0.08)
                            if self.IsOpen and M.enabled and (self.BgStyle == "Aurora") then
                                t += 0.08
                                if L.auraA then L.auraA.Position = UDim2.fromOffset(60 + math.sin(t * 0.35) * 34, 10 + math.cos(t * 0.27) * 22) end
                                if L.auraB then L.auraB.Position = UDim2.new(1, 40 + math.cos(t * 0.22) * 38, 1, 60 + math.sin(t * 0.31) * 24) end
                                if L.meshA then L.meshA.Position = UDim2.fromScale(0.25 + math.sin(t * 0.11) * 0.06, 0.18 + math.cos(t * 0.09) * 0.05) end
                                if L.meshB then L.meshB.Position = UDim2.fromScale(0.85 + math.cos(t * 0.1) * 0.06, 0.9 + math.sin(t * 0.12) * 0.05) end
                            end
                        end
                    end)
                end

                local PATTERNS = {
                    Grid = { tex = "grid", alpha = 0.955 },
                    Dots = { tex = "dots", alpha = 0.9 },
                    Diagonal = { tex = "diag", alpha = 0.965 },
                    Crosses = { tex = "crosses", alpha = 0.93 },
                    Scanlines = { tex = "scan", alpha = 0.955 },
                }

                function Window:_applyBackground()
                    local L = self.BgLayers
                    if not L then return end
                    local style, k = self.BgStyle, self.BgIntensity
                    local function a(base)
                        return math.clamp(1 - (1 - base) * k, 0, 1)
                    end
                    local aurora = style == "Aurora"
                    if L.meshA then L.meshA.ImageTransparency = a(aurora and 0.84 or 0.965) end
                    if L.meshB then L.meshB.ImageTransparency = a(aurora and 0.9 or 0.975) end
                    if L.auraA then L.auraA.ImageTransparency = a(aurora and 0.84 or 0.9) end
                    if L.auraB then L.auraB.ImageTransparency = a(aurora and 0.9 or 0.94) end
                    local pat = PATTERNS[style]
                    if pat then
                        local id = X.get(pat.tex)
                        if id then
                            L.pattern.Image = id
                            L.pattern.ScaleType = Enum.ScaleType.Tile
                            local spec = X.specs[pat.tex]
                            L.pattern.TileSize = UDim2.fromOffset(spec.w, spec.h)
                            L.pattern.ImageTransparency = a(pat.alpha)
                        end
                    else
                        L.pattern.ImageTransparency = 1
                    end
                    if L.grain then L.grain.ImageTransparency = a(style == "Noise" and 0.55 or 0.82) end
                end

                function Window:SetBackground(style)
                    Nova.trace("SetBackground")
                    for _, s in ipairs(Window.BackgroundStyles) do
                        if s == style then
                            self.BgStyle = style
                            self.State.set("bgStyle", style)
                            self:_applyBackground()
                            return
                        end
                    end
                end

                function Window:SetBackgroundIntensity(v)
                    Nova.trace("SetBackgroundIntensity")
                    self.BgIntensity = math.clamp(tonumber(v) or 1, 0, 1.5)
                    self.State.set("bgIntensity", self.BgIntensity)
                    self:_applyBackground()
                end

                function Window:SetOpacity(v)
                    Nova.trace("SetOpacity")
                    self.Opacity = math.clamp(tonumber(v) or 1, 0.5, 1)
                    self.State.set("opacity", self.Opacity)
                    self.Win.BackgroundTransparency = 1 - self.Opacity
                    if self.Sidebar then self.Sidebar.BackgroundTransparency = 0.3 + (1 - self.Opacity) * 0.7 end
                end

                function Window:SetCornerRadius(mult)
                    Nova.trace("SetCornerRadius")
                    mult = math.clamp(tonumber(mult) or 1, 0, 2)
                    self.State.set("radius", mult)
                    U.setRadius(mult)
                    X.setRadius()
                end

                function Window:SetFont(name)
                    Nova.trace("SetFont")
                    if F.setFamily(name) then self.State.set("font", F.name) end
                end

                function Window:SetTextScale(v)
                    Nova.trace("SetTextScale")
                    v = math.clamp(tonumber(v) or 1, 0.8, 1.3)
                    self.State.set("textScale", v)
                    F.setScale(v)
                end

                function Window:SetSounds(on)
                    S.enabled = on and true or false
                    self.State.set("sounds", S.enabled)
                end

                function Window:SetVolume(v)
                    S.volume = math.clamp(tonumber(v) or 0.5, 0, 1)
                    self.State.set("volume", S.volume)
                end

                function Window:SetMotion(on)
                    M.enabled = on and true or false
                    self.State.set("motion", M.enabled)
                end

                function Window:SetTooltips(on)
                    self.TooltipsOn = on and true or false
                    self.State.set("tooltips", self.TooltipsOn)
                    if not self.TooltipsOn then self:HideTip() end
                end

                function Window:SetLauncher(on)
                    self.LauncherOn = on and true or false
                    self.State.set("launcher", self.LauncherOn)
                    if self.Launcher then self.Launcher.Visible = self.LauncherOn and not (self.IsTouch and self.IsOpen) end
                end

                function Window:SetAccent(color)
                    Nova.trace("SetAccent")
                    if typeof(color) ~= "Color3" then return end
                    T.set("Accent", color)
                    self.State.set("accent", color:ToHex())
                end

                function Window:_syncFooter()
                    local keyText = Nova.keyName and Nova.keyName(self.Key) or self.Key.Name
                    if self.FooterKey then
                        self.FooterKey.Text = keyText
                    end
                    if self.LauncherParts and self.LauncherParts.key then
                        self.LauncherParts.key.Text = keyText
                    end
                    if self.SidebarCollapsed and self.FooterText then
                        self.FooterText.TextTransparency = 1
                        self.FooterChip.AnchorPoint = Vector2.new(0.5, 0.5)
                        self.FooterChip.Position = UDim2.new(0.5, 0, 0.5, 1)
                    end
                end

                function Window:SetBase(name)
                    Nova.trace("SetBase")
                    if T.setBase(name) then
                        self.State.set("base", name)
                        self.State.set("panel", nil)
                        self.PanelColor = nil
                    end
                end

                function Window:SetPanelColor(color)
                    Nova.trace("SetPanelColor")
                    if typeof(color) ~= "Color3" then return end
                    self.PanelColor = color
                    self.State.set("panel", color:ToHex())
                    T.base = "Custom"
                    if self._panelQueued then return end
                    self._panelQueued = true
                    task.delay(0.06, function()
                        self._panelQueued = false
                        if self.PanelColor and not self.Destroyed then
                            T.setMany(T.panelFrom(self.PanelColor))
                            T.base = "Custom"
                        end
                    end)
                end

                function Window:OnKeyChanged(fn)
                    self.KeyListeners = self.KeyListeners or {}
                    table.insert(self.KeyListeners, fn)
                end

                function Window:SetKey(key)
                    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
                        self.Key = key
                        self.State.set("menuKey", key.Name)
                        self:_syncFooter()
                        for _, fn in ipairs(self.KeyListeners or {}) do task.spawn(pcall, fn, key) end
                    end
                end

                function Window:SetTitle(title, subtitle)
                    if title then self.TitleLabel.Text = title end
                    if subtitle then self.SubtitleLabel.Text = subtitle end
                end

                function Window:ResetAppearance()
                    for _, key in ipairs({ "accent", "radius", "font", "textScale", "scale", "autoFit", "blur", "bgStyle", "bgIntensity", "opacity", "tooltips", "launcher", "base", "cardStyle", "density", "watermark", "keybindList", "sidebarWidth", "panel" }) do
                        self.State.data[key] = nil
                    end
                    self.State.save()
                    self.PanelColor = nil
                    local d = self.StateDefaults
                    if type(d) == "table" then
                        if d.base then self:SetBase(d.base) end
                        if d.panel then pcall(function() self:SetPanelColor(Color3.fromHex(d.panel)) end) end
                        if d.accent then pcall(function() self:SetAccent(Color3.fromHex(d.accent)) end) end
                        self:SetCornerRadius(tonumber(d.radius) or 1)
                        if d.font then self:SetFont(d.font) end
                        self:SetTextScale(tonumber(d.textScale) or 1)
                        self:SetScale(tonumber(d.scale) or self.DefaultScale)
                        self:SetAutoFit(d.autoFit ~= false)
                        self:SetBlur(d.blur == true)
                        if d.bgStyle then self:SetBackground(d.bgStyle) end
                        self:SetBackgroundIntensity(tonumber(d.bgIntensity) or 1)
                        if d.cardStyle then self:SetCardStyle(d.cardStyle) end
                        if d.density then self:SetDensity(d.density) end
                        self:SetSidebarWidth(tonumber(d.sidebarWidth) or self.DefaultSidebarWidth)
                        self:SetOpacity(tonumber(d.opacity) or 1)
                        if d.groupLabels ~= nil and self.SetGroupLabels then self:SetGroupLabels(d.groupLabels) end
                        if self.SetTooltips then self:SetTooltips(d.tooltips ~= false) end
                        if d.launcher ~= nil and self.SetLauncher then self:SetLauncher(d.launcher) end
                        self.State.save()
                        if self.OnReset then pcall(self.OnReset) end
                        return
                    end
                    T.setBase("Midnight")
                    T.set("Accent", T.Presets.Crimson)
                    self:SetCornerRadius(1)
                    self:SetFont("Builder Sans")
                    self:SetTextScale(1)
                    self:SetScale(self.DefaultScale)
                    self:SetAutoFit(true)
                    self:SetBlur(false)
                    self:SetBackground("Aurora")
                    self:SetBackgroundIntensity(1)
                    self:SetCardStyle("Glass")
                    self:SetDensity("Comfortable")
                    self:SetSidebarWidth(self.DefaultSidebarWidth)
                    self:SetOpacity(1)
                    self.State.data.accent = nil
                    self.State.data.radius = nil
                    self.State.data.font = nil
                    self.State.data.textScale = nil
                    self.State.data.scale = nil
                    self.State.data.blur = nil
                    self.State.data.bgStyle = nil
                    self.State.data.bgIntensity = nil
                    self.State.data.opacity = nil
                    self.State.save()
                    if self.OnReset then pcall(self.OnReset) end
                end

                function Window:_buildClose(header)
                    local btn = new("TextButton", { Name = "Close", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -20, 0, HEADER / 2 - 1), Size = UDim2.fromOffset(34, 34), ZIndex = 5, Parent = header })
                    local bs = new("UIScale", { Parent = btn })
                    local glow = X.image(btn, "glow", { Name = "Glow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(84, 84), ImageTransparency = 1, ZIndex = 4 })
                    if glow then bind(glow, "ImageColor3", "Danger") end
                    local tile, textured = Nova.tile(btn, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.05, SliceScale = 0.6, Z = 5 })
                    local rim = X.image(btn, "rim9", { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.64, ImageTransparency = 0.72, ZIndex = 7 })
                    if rim then bind(rim, "ImageColor3", "Glass") end
                    local ic = icon({ Parent = btn, Icon = "x", Size = 16, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 8 })
                    local colorProp = textured and "ImageColor3" or "BackgroundColor3"
                    btn.MouseEnter:Connect(function()
                        tween(tile, "Quick", { [colorProp] = T.resolve("Danger") })
                        tween(ic, "Quick", { ImageColor3 = Color3.new(1, 1, 1) })
                        if glow then tween(glow, "Quick", { ImageTransparency = 0.72 }) end
                        tween(bs, "Quick", { Scale = 1.06 })
                        S.play("hover", 0.6)
                        self:ShowTip("Close")
                    end)
                    U.leave(btn, function()
                        tween(tile, "Quick", { [colorProp] = T.resolve("Elevated") })
                        tween(ic, "Quick", { ImageColor3 = T.resolve("Muted") })
                        if glow then tween(glow, "Quick", { ImageTransparency = 1 }) end
                        tween(bs, "Quick", { Scale = 1 })
                        self:HideTip()
                    end)
                    btn.MouseButton1Down:Connect(function() tween(bs, "Quick", { Scale = 0.9 }) end)
                    btn.MouseButton1Up:Connect(function() tween(bs, "PopSmall", { Scale = 1.06 }) end)
                    btn.MouseButton1Click:Connect(function()
                        S.play("click")
                        self:HideTip()
                        self:Close()
                    end)
                    self.CloseButton = btn
                    if self.IsTouch then
                        btn.Size = UDim2.fromOffset(42, 42)
                        btn.Position = UDim2.new(1, -16, 0, HEADER / 2 - 1)
                        ic.Size = UDim2.fromOffset(19, 19)
                        if glow then glow.Size = UDim2.fromOffset(70, 70) end
                        local pad = new("TextButton", { Name = "HitPad", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(56, 56), ZIndex = 9, Parent = btn })
                        pad.MouseButton1Down:Connect(function() tween(bs, "Quick", { Scale = 0.9 }) end)
                        pad.MouseButton1Up:Connect(function() tween(bs, "PopSmall", { Scale = 1 }) end)
                        pad.MouseButton1Click:Connect(function()
                            S.play("click")
                            self:HideTip()
                            self:Close()
                        end)
                    end
                    T.onChange(function(key)
                        if key == "Elevated" or key == "Danger" then
                            pcall(function() tile[colorProp] = T.resolve("Elevated") end)
                        end
                    end)
                end

                function Window:AddHeaderButton(opts)
                    opts = opts or {}
                    local header = self.CloseButton and self.CloseButton.Parent
                    if not header then return nil end
                    self.HeaderButtons = self.HeaderButtons or {}
                    local idx = #self.HeaderButtons + 1
                    local touch = self.IsTouch
                    local size = touch and 42 or 34
                    local step = size + 8
                    local right = touch and 16 or 20
                    local hot = opts.HoverColor or T.resolve("Accent")
                    local btn = new("TextButton", { Name = opts.Name or "HeaderButton", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -(right + step * idx), 0, HEADER / 2 - 1), Size = UDim2.fromOffset(size, size), ZIndex = 5, Parent = header })
                    local bs = new("UIScale", { Parent = btn })
                    local glow = X.image(btn, "glow", { Name = "Glow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(touch and 70 or 84, touch and 70 or 84), ImageTransparency = 1, ZIndex = 4 })
                    if glow then glow.ImageColor3 = hot end
                    local tile, textured = Nova.tile(btn, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.05, SliceScale = 0.6, Z = 5 })
                    local rim = X.image(btn, "rim9", { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.64, ImageTransparency = 0.72, ZIndex = 7 })
                    if rim then bind(rim, "ImageColor3", "Glass") end
                    local ic
                    if opts.Image then
                        local w = opts.ImageSize and opts.ImageSize.X or 18
                        local h = opts.ImageSize and opts.ImageSize.Y or 14
                        if touch then w, h = math.floor(w * 1.2 + 0.5), math.floor(h * 1.2 + 0.5) end
                        ic = new("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, Image = opts.Image, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, h), ScaleType = Enum.ScaleType.Fit, ImageColor3 = T.resolve("Muted"), ZIndex = 8, Parent = btn })
                    else
                        ic = icon({ Parent = btn, Icon = opts.Icon or "circle", Size = touch and 19 or 16, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 8 })
                    end
                    local colorProp = textured and "ImageColor3" or "BackgroundColor3"
                    local hovering = false
                    btn.MouseEnter:Connect(function()
                        hovering = true
                        tween(tile, "Quick", { [colorProp] = hot })
                        tween(ic, "Quick", { ImageColor3 = Color3.new(1, 1, 1) })
                        if glow then tween(glow, "Quick", { ImageTransparency = 0.72 }) end
                        tween(bs, "Quick", { Scale = 1.06 })
                        S.play("hover", 0.6)
                        if opts.Tip then self:ShowTip(opts.Tip) end
                    end)
                    U.leave(btn, function()
                        hovering = false
                        tween(tile, "Quick", { [colorProp] = T.resolve("Elevated") })
                        tween(ic, "Quick", { ImageColor3 = T.resolve("Muted") })
                        if glow then tween(glow, "Quick", { ImageTransparency = 1 }) end
                        tween(bs, "Quick", { Scale = 1 })
                        self:HideTip()
                    end)
                    btn.MouseButton1Down:Connect(function() tween(bs, "Quick", { Scale = 0.9 }) end)
                    btn.MouseButton1Up:Connect(function() tween(bs, "PopSmall", { Scale = 1.06 }) end)
                    btn.MouseButton1Click:Connect(function()
                        S.play("click")
                        self:HideTip()
                        if opts.Callback then task.spawn(opts.Callback) end
                    end)
                    T.onChange(function(key)
                        if hovering then return end
                        if key == "Elevated" or key == "Muted" then
                            pcall(function()
                                tile[colorProp] = T.resolve("Elevated")
                                ic.ImageColor3 = T.resolve("Muted")
                            end)
                        end
                    end)
                    table.insert(self.HeaderButtons, btn)
                    return btn
                end

                function Window:_drag(handle)
                    if typeof(handle) ~= "Instance" then return end
                    local dragging, start, origin, dragIn
                    handle.InputBegan:Connect(function(input)
                        if not U.isClick(input) then return end
                        dragging, start, origin, dragIn = true, input.Position, self.Root.Position, input
                        local conn
                        conn = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                                conn:Disconnect()
                                self:_savePos()
                            end
                        end)
                    end)
                    U.connect(UIS.InputChanged, function(input)
                        if dragging and U.sameMove(input, dragIn) then
                            local d = input.Position - start
                            self.Root.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
                        end
                    end, self.Conns)
                end

                function Window:_savePos()
                    if not (self.State and self.Root) then return end
                    local p = self.Root.Position
                    if math.abs(p.X.Scale - 0.5) > 0.001 or math.abs(p.Y.Scale - 0.5) > 0.001 then return end
                    pcall(self.State.set, self.IsTouch and "touchPos" or "winPos", { math.floor(p.X.Offset + 0.5), math.floor(p.Y.Offset + 0.5) })
                end

                function Window:_resize(grip)
                    local sizing, start, origin, startPos, sizeIn
                    grip.InputBegan:Connect(function(input)
                        if not U.isClick(input) then return end
                        sizing, start, origin, startPos, sizeIn = true, input.Position, self.Root.AbsoluteSize / math.max(self.Scale.Scale, 0.1), self.Root.Position, input
                        local conn
                        conn = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                sizing = false
                                conn:Disconnect()
                                if self.IsTouch then
                                    self.TouchSize = self.Size
                                    if self.State then pcall(self.State.set, "touchSize", { math.floor(self.Size.X + 0.5), math.floor(self.Size.Y + 0.5) }) end
                                elseif self.State then
                                    pcall(self.State.set, "size", { math.floor(self.Size.X + 0.5), math.floor(self.Size.Y + 0.5) })
                                end
                                self:_savePos()
                            end
                        end)
                    end)
                    U.connect(UIS.InputChanged, function(input)
                        if sizing and U.sameMove(input, sizeIn) then
                            local d = (input.Position - start) / math.max(self.Scale.Scale, 0.1)
                            local minX, minY = self.MinSize.X, self.MinSize.Y
                            if self.IsTouch then
                                local cam = workspace.CurrentCamera
                                local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
                                local sc = math.max(self.Scale.Scale, 0.1)
                                minX, minY = 360, 240
                                d = Vector2.new(math.min(d.X, (vp.X - 16) / sc - origin.X), math.min(d.Y, (vp.Y - 16) / sc - origin.Y))
                            end
                            local w = math.max(minX, origin.X + d.X)
                            local h = math.max(minY, origin.Y + d.Y)
                            self.Size = Vector2.new(w, h)
                            self.Root.Size = UDim2.fromOffset(w, h)
                            local sc = self.Scale.Scale
                            self.Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (w - origin.X) * sc / 2, startPos.Y.Scale, startPos.Y.Offset + (h - origin.Y) * sc / 2)
                        end
                    end, self.Conns)
                end

                function Window:_syncLayers()
                    local s = math.max((self.AutoScale or 1) * self.UserScale, 0.1)
                    for _, pair in ipairs({ { self.FloatLayer, self.FloatScale }, { self.PopLayer, self.PopScale } }) do
                        pair[2].Scale = s
                        pair[1].Size = UDim2.fromScale(1 / s, 1 / s)
                    end
                end

                function Nova.screenFactor(vp)
                    if not vp then
                        local cam = workspace.CurrentCamera
                        vp = cam and cam.ViewportSize or Vector2.new(1920, 1000)
                    end
                    local f = math.min(vp.X / 1920, vp.Y / 1000)
                    if math.abs(f - 1) < 0.04 then f = 1 end
                    return U.clamp(f, 0.5, 1.3)
                end

                function Window:_placeOnScreen(pos)
                    local cam = workspace.CurrentCamera
                    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
                    pos = pos or self.Root.Position
                    local s = (self.AutoScale or 1) * self.UserScale
                    local px = Vector2.new(self.Root.Size.X.Offset, self.Root.Size.Y.Offset) * s
                    local cx = pos.X.Scale * vp.X + pos.X.Offset
                    local cy = pos.Y.Scale * vp.Y + pos.Y.Offset
                    local hx, hy, m = px.X / 2, px.Y / 2, 8
                    local nx = (px.X + m * 2 >= vp.X) and vp.X / 2 or math.clamp(cx, hx + m, vp.X - hx - m)
                    local ny = (px.Y + m * 2 >= vp.Y) and vp.Y / 2 or math.clamp(cy, hy + m, vp.Y - hy - m)
                    if math.abs(nx - cx) < 0.5 and math.abs(ny - cy) < 0.5 then return pos end
                    return UDim2.new(pos.X.Scale, math.floor(pos.X.Offset + (nx - cx) + 0.5), pos.Y.Scale, math.floor(pos.Y.Offset + (ny - cy) + 0.5))
                end

                function Window:OnScreenScale(fn)
                    table.insert(self.ScaleHooks, fn)
                    local cam = workspace.CurrentCamera
                    local ok, keep = pcall(fn, self.OverlayScale or 1, cam and cam.ViewportSize or Vector2.new(1280, 720))
                    if ok and keep == false then
                        local i = table.find(self.ScaleHooks, fn)
                        if i then table.remove(self.ScaleHooks, i) end
                    end
                end

                function Window:SetAutoFit(on)
                    Nova.trace("SetAutoFit")
                    self.AutoFit = on and true or false
                    self.State.set("autoFit", self.AutoFit)
                    if not self.AutoFit and not self.IsTouch then
                        self.Root.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)
                    end
                    if self._applyScale then self._applyScale(true) end
                end

                function Window:_autoScale()
                    local cam = workspace.CurrentCamera
                    local function apply(animate)
                        local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
                        local sf = self.AutoFit and Nova.screenFactor(vp) or 1
                        self.ScreenFactor = sf
                        self.OverlayScale = self.AutoFit and U.clamp(sf, 0.6, 1.2) or 1
                        if self.IsTouch then
                            local fit = U.clamp((vp.Y - 16) / 440, 0.55, 1)
                            local sc = U.clamp(fit * self.UserScale / math.max(self.DefaultScale or 1, 0.1), 0.45, 1.3)
                            local maxW = math.floor(math.min(self.BaseSize.X, (vp.X - 16) / sc))
                            local maxH = math.floor(math.min(self.BaseSize.Y, (vp.Y - 16) / sc))
                            local ts = self.TouchSize
                            local w, h
                            if ts then
                                w = math.floor(U.clamp(ts.X, math.min(360, maxW), maxW))
                                h = math.floor(U.clamp(ts.Y, math.min(240, maxH), maxH))
                            else
                                w = math.min(maxW, math.floor(vp.X * 0.72 / sc))
                                h = math.min(maxH, math.floor(vp.Y * 0.86 / sc))
                            end
                            if self.Size.X ~= w or self.Size.Y ~= h then
                                self.Size = Vector2.new(w, h)
                                self.Root.Size = UDim2.fromOffset(w, h)
                            end
                            self.AutoScale = sc / math.max(self.UserScale, 0.1)
                        elseif self.AutoFit then
                            local user = math.max(self.UserScale, 0.1)
                            local want = math.max(user * sf, math.min(0.6, user))
                            local availX, availY = vp.X - 24, vp.Y - 24
                            local w, h = self.Size.X, self.Size.Y
                            w = math.max(math.min(self.MinSize.X, w), math.min(w, math.floor(availX / want)))
                            h = math.max(math.min(self.MinSize.Y, h), math.min(h, math.floor(availY / want)))
                            local fit = math.min(1, availX / (w * want), availY / (h * want))
                            local rs = UDim2.fromOffset(w, h)
                            if self.Root.Size ~= rs then self.Root.Size = rs end
                            self.AutoScale = U.clamp(want * fit, 0.3, 1.8) / user
                        else
                            local auto = math.min(1, (vp.X - 30) / self.Size.X, (vp.Y - 30) / self.Size.Y)
                            self.AutoScale = U.clamp(auto, 0.45, 1)
                        end
                        self.Scale.Scale = self.AutoScale * self.UserScale
                        self.ToastScale.Scale = U.clamp(math.min(self.OverlayScale, vp.X / 900), 0.55, 1.2)
                        self:_syncLayers()
                        if not self.Scaling and not self.HomePos then
                            local p = self:_placeOnScreen(self.Root.Position)
                            if p ~= self.Root.Position then self.Root.Position = p end
                        end
                        for i = #self.ScaleHooks, 1, -1 do
                            local ok, keep = pcall(self.ScaleHooks[i], self.OverlayScale, vp)
                            if ok and keep == false then table.remove(self.ScaleHooks, i) end
                        end
                    end
                    apply()
                    if cam then U.connect(cam:GetPropertyChangedSignal("ViewportSize"), apply, self.Conns) end
                    self._applyScale = apply
                end

                function Window:SetScale(mult)
                    Nova.trace("SetScale")
                    self.UserScale = U.clamp(tonumber(mult) or 1, 0.6, 1.5)
                    self.State.set("scale", self.UserScale)
                    if self._applyScale then self._applyScale(true) end
                end

                function Window:_launcher(opts)
                    local st = self.State
                    local saved = st.get("launcherPos", nil)
                    local pos = UDim2.fromOffset(16, 70)
                    if type(saved) == "table" and tonumber(saved[1]) and tonumber(saved[2]) then pos = UDim2.fromOffset(saved[1], saved[2]) end
                    local btn = new("TextButton", { Name = "Launcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = pos, Size = UDim2.fromOffset(150, 42), Visible = self.LauncherOn, ZIndex = 25, Parent = self.Gui })
                    local ls = new("UIScale", { Parent = btn })
                    self.LauncherBase = 1
                    local shadow = X.image(btn, "shadow9", { Name = "Shadow", Position = UDim2.fromOffset(-22, -14), Size = UDim2.new(1, 44, 1, 46), SliceScale = 1, ImageTransparency = 0.5, ZIndex = 24 })
                    local card = new("Frame", { Name = "Card", Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, BackgroundTransparency = 0.04, ZIndex = 26, Parent = btn })
                    bind(card, "BackgroundColor3", "Surface")
                    U.corner(card, 14)
                    new("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(206, 208, 216)), Rotation = 90, Parent = card })
                    local glow = X.image(card, "glow", { Name = "Glow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 22, 0.5, 0), Size = UDim2.fromOffset(120, 90), ImageTransparency = 0.85, ZIndex = 26 })
                    if glow then
                        if opts.Logo and opts.LogoGlow then glow.ImageColor3 = opts.LogoGlow else bind(glow, "ImageColor3", "Accent") end
                    end
                    X.image(card, "gloss9", { Name = "Gloss", Size = UDim2.fromScale(1, 1), SliceScale = 0.79, ImageTransparency = 0.9, ZIndex = 27 })
                    local rim = X.image(card, "rim9", { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.79, ImageTransparency = 0.45, ZIndex = 34 })
                    if rim then bind(rim, "ImageColor3", "Glass") else bind(U.stroke(card, Color3.new(1, 1, 1), 1, 0.85), "Color", "Glass") end
                    local row = new("Frame", { Name = "Row", Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 28, Parent = card })
                    U.pad(row, 0, 7, 0, 6)
                    U.list(row, 9, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
                    local logo = new("Frame", { Name = "Logo", Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, LayoutOrder = 1, ZIndex = 28, Parent = row })
                    if opts.Logo then
                        new("ImageLabel", { Name = "Mark", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(34, 34), Image = opts.Logo, ScaleType = Enum.ScaleType.Fit, ZIndex = 29, Parent = logo })
                    else
                        Nova.tile(logo, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Accent", SliceScale = 0.5, Z = 28 })
                        label({ Parent = logo, Text = tostring(opts.Initial or string.sub(opts.Title or "N", 1, 1)), Font = F.Heavy(), Size = 15, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = "OnAccent", Z = 30 })
                    end
                    local title = label({ Parent = row, Text = tostring(opts.Title or "Nova"), Font = F.Bold(), Size = 14, Box = UDim2.new(0, 0, 1, 0), Auto = Enum.AutomaticSize.X, Z = 29, Name = "Title" })
                    title.LayoutOrder = 2
                    local keyChip, keyLabel
                    if not self.IsTouch then
                        keyChip = new("Frame", { Name = "Key", Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, BackgroundTransparency = 0.45, LayoutOrder = 3, ZIndex = 29, Parent = row })
                        bind(keyChip, "BackgroundColor3", "Elevated")
                        U.corner(keyChip, 6)
                        U.pad(keyChip, 0, 7, 0, 7)
                        bind(U.stroke(keyChip, Color3.new(1, 1, 1), 1, 0.88), "Color", "Glass")
                        keyLabel = label({ Parent = keyChip, Text = Nova.keyName and Nova.keyName(self.Key) or self.Key.Name, Font = F.Semi(), Size = 11, Box = UDim2.new(0, 0, 1, 0), Auto = Enum.AutomaticSize.X, Color = "Muted", Z = 30 })
                    end
                    local orb = new("Frame", { Name = "Orb", Size = UDim2.fromOffset(28, 28), BorderSizePixel = 0, BackgroundTransparency = 0.35, LayoutOrder = 4, ZIndex = 29, Parent = row })
                    bind(orb, "BackgroundColor3", "Elevated")
                    U.corner(orb, UDim.new(1, 0))
                    local orbStroke = U.stroke(orb, Color3.new(1, 1, 1), 1, 0.85)
                    bind(orbStroke, "Color", "Glass")
                    local chev = icon({ Parent = orb, Icon = "chevron-down", Size = 15, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 30 })
                    self.LauncherParts = { btn = btn, card = card, orb = orb, orbStroke = orbStroke, chev = chev, glow = glow, rim = rim, key = keyLabel, scale = ls, shadow = shadow }
                    local function fitSize()
                        local s2 = math.max(ls.Scale, 0.1)
                        local w = math.ceil(card.AbsoluteSize.X / s2)
                        if w > 0 and btn.Size.X.Offset ~= w then btn.Size = UDim2.fromOffset(w, 42) end
                    end
                    card:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitSize)
                    task.defer(fitSize)

                    local PRESS = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local RELEASE = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    local moved, down, start, origin, downIn = false, false, nil, nil, nil
                    btn.InputBegan:Connect(function(input)
                        if not U.isClick(input) then return end
                        down, moved, start, origin, downIn = true, false, input.Position, btn.Position, input
                        tween(ls, PRESS, { Scale = self.LauncherBase * 0.95 })
                    end)
                    U.connect(UIS.InputChanged, function(input)
                        if down and U.sameMove(input, downIn) then
                            local d = input.Position - start
                            if d.Magnitude > 6 then moved = true end
                            if moved then
                                local vp = workspace.CurrentCamera.ViewportSize
                                local x = math.clamp(origin.X.Offset + d.X, 4, math.max(4, vp.X - btn.AbsoluteSize.X - 4))
                                local y = math.clamp(origin.Y.Offset + d.Y, 4, math.max(4, vp.Y - btn.AbsoluteSize.Y - 4))
                                btn.Position = UDim2.fromOffset(x, y)
                            end
                        end
                    end, self.Conns)
                    U.connect(UIS.InputEnded, function(input)
                        if down and U.sameEnd(input, downIn) then
                            down = false
                            tween(ls, RELEASE, { Scale = self.LauncherBase })
                            if moved then
                                st.set("launcherPos", { math.floor(btn.Position.X.Offset), math.floor(btn.Position.Y.Offset) })
                            else
                                S.play("click")
                                self:Toggle()
                            end
                        end
                    end, self.Conns)
                    btn.MouseEnter:Connect(function()
                        if rim then tween(rim, "Quick", { ImageTransparency = 0.2 }) end
                        if shadow then tween(shadow, "Quick", { ImageTransparency = 0.35 }) end
                        if not down then tween(ls, "Quick", { Scale = self.LauncherBase * 1.03 }) end
                        Nova.paint(title, "TextColor3", "Text", "Quick")
                        if not self.IsOpen then Nova.paint(chev, "ImageColor3", "Text", "Quick") end
                    end)
                    U.leave(btn, function()
                        if rim then tween(rim, "Quick", { ImageTransparency = 0.45 }) end
                        if shadow then tween(shadow, "Quick", { ImageTransparency = 0.5 }) end
                        if not down then tween(ls, RELEASE, { Scale = self.LauncherBase }) end
                        if not self.IsOpen then Nova.paint(chev, "ImageColor3", "Muted", "Quick") end
                    end)
                    self.Launcher = btn
                    self:OnScreenScale(function(s)
                        if not btn.Parent then return false end
                        self.LauncherBase = s
                        if not down then ls.Scale = s end
                        task.defer(function()
                            local vp = workspace.CurrentCamera.ViewportSize
                            local p = btn.Position
                            local x = math.clamp(p.X.Offset, 4, math.max(4, vp.X - btn.AbsoluteSize.X - 4))
                            local y = math.clamp(p.Y.Offset, 4, math.max(4, vp.Y - btn.AbsoluteSize.Y - 4))
                            if x ~= p.X.Offset or y ~= p.Y.Offset then btn.Position = UDim2.fromOffset(x, y) end
                        end)
                    end)
                    self:_launcherState(false, true)
                end

                function Window:_launcherState(open, instant)
                    local L = self.LauncherParts
                    if not L then return end
                    local info = instant and TweenInfo.new(0) or TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    tween(L.chev, info, { Rotation = open and 180 or 0 })
                    Nova.paint(L.chev, "ImageColor3", open and "Accent" or "Muted", info)
                    Nova.paint(L.orb, "BackgroundColor3", open and "Accent" or "Elevated", info)
                    tween(L.orb, info, { BackgroundTransparency = open and 0.8 or 0.35 })
                    Nova.paint(L.orbStroke, "Color", open and "Accent" or "Glass", info)
                    tween(L.orbStroke, info, { Transparency = open and 0.45 or 0.85 })
                    if L.glow then tween(L.glow, info, { ImageTransparency = open and 0.62 or 0.85 }) end
                end

                function Window:_input()
                    U.connect(UIS.InputBegan, function(input)
                        if self.Destroyed or self.Listening then return end
                        if input.KeyCode == self.Key and self.Key ~= Enum.KeyCode.Unknown then
                            if UIS:GetFocusedTextBox() then return end
                            self:Toggle()
                        end
                    end, self.Conns)
                    U.connect(Nova.Services.RunService.RenderStepped, function()
                        if not self.Tip.Visible then return end
                        local m = UIS:GetMouseLocation()
                        local vp = workspace.CurrentCamera.ViewportSize
                        local sz = self.Tip.AbsoluteSize
                        local x = math.min(m.X + 14, vp.X - sz.X - 6)
                        local y = math.min(m.Y + 18, vp.Y - sz.Y - 6)
                        self.Tip.Position = UDim2.fromOffset(x, y)
                    end, self.Conns)
                end

                function Window:ShowTip(text)
                    if not text or text == "" or not self.TooltipsOn or self.IsTouch then return end
                    self.TipToken = (self.TipToken or 0) + 1
                    local token = self.TipToken
                    task.delay(0.35, function()
                        if self.TipToken ~= token or self.Destroyed then return end
                        self.TipLabel.Text = Nova.tr(text)
                        self.Tip.Visible = true
                        self.Tip.BackgroundTransparency = 1
                        self.TipLabel.TextTransparency = 1
                        tween(self.Tip, "Quick", { BackgroundTransparency = 0 })
                        tween(self.TipLabel, "Quick", { TextTransparency = 0 })
                    end)
                end

                function Window:HideTip()
                    self.TipToken = (self.TipToken or 0) + 1
                    self.Tip.Visible = false
                end

                function Window:_acrylicStep()
                    local part, mesh, cam = self.AcrylicPart, self.AcrylicMesh, workspace.CurrentCamera
                    if not (part and mesh and cam) then return end
                    if part.Parent ~= cam then part.Parent = cam end
                    local root = self.Root
                    local p, s = root.AbsolutePosition, root.AbsoluteSize
                    if not root.Visible or s.X < 8 or s.Y < 8 then
                        mesh.Scale = Vector3.zero
                        return
                    end
                    local inset = math.floor(14 * (U.radiusMult or 1) * math.max(self.Scale.Scale, 0.1) * 0.3 + 0.5) + 2
                    local function at(x, y)
                        local ray = cam:ScreenPointToRay(x, y)
                        return ray.Origin + ray.Direction * 0.001
                    end
                    local tl = at(p.X + inset, p.Y + inset)
                    local tr = at(p.X + s.X - inset, p.Y + inset)
                    local br = at(p.X + s.X - inset, p.Y + s.Y - inset)
                    local c = cam.CFrame
                    part.CFrame = CFrame.fromMatrix((tl + br) / 2, c.XVector, c.YVector, c.ZVector)
                    mesh.Scale = Vector3.new((tr - tl).Magnitude, (tr - br).Magnitude, 0)
                end

                function Window:_blur(on)
                    local RS = Nova.Services.RunService
                    self.AcrylicToken = (self.AcrylicToken or 0) + 1
                    local token = self.AcrylicToken
                    if on and self.BlurEnabled and not self.Destroyed then
                        local cam = workspace.CurrentCamera
                        if not cam then return end
                        if not (self.AcrylicDof and self.AcrylicDof.Parent) then
                            self.AcrylicDof = new("DepthOfFieldEffect", { Name = "NovaDepth", FarIntensity = 0, FocusDistance = 51.6, InFocusRadius = 50, NearIntensity = 0, Parent = Nova.Services.Lighting })
                        end
                        if not (self.AcrylicPart and self.AcrylicPart.Parent) then
                            local part = Instance.new("Part")
                            part.Name = "NovaGlass"
                            part.Material = Enum.Material.Glass
                            part.Transparency = 0.98
                            part.Color = Color3.new(0, 0, 0)
                            part.Anchored = true
                            part.CanCollide = false
                            part.CanQuery = false
                            part.CanTouch = false
                            part.CastShadow = false
                            part.Size = Vector3.new(1, 1, 0)
                            local mesh = Instance.new("SpecialMesh")
                            mesh.MeshType = Enum.MeshType.Brick
                            mesh.Scale = Vector3.zero
                            mesh.Parent = part
                            part.Parent = cam
                            self.AcrylicPart, self.AcrylicMesh = part, mesh
                        end
                        if not self.AcrylicBound then
                            self.AcrylicBound = "NovaAcrylic_" .. tostring(self.Gui and self.Gui.Name or "Nova")
                            pcall(function() RS:UnbindFromRenderStep(self.AcrylicBound) end)
                            RS:BindToRenderStep(self.AcrylicBound, Enum.RenderPriority.Camera.Value + 1, function() self:_acrylicStep() end)
                        end
                        tween(self.AcrylicDof, "Slow", { NearIntensity = 1 })
                        return
                    end
                    if self.AcrylicDof then tween(self.AcrylicDof, "Quick", { NearIntensity = 0 }) end
                    local function clear()
                        if self.AcrylicToken ~= token then return end
                        if self.AcrylicBound then
                            local name = self.AcrylicBound
                            self.AcrylicBound = nil
                            pcall(function() RS:UnbindFromRenderStep(name) end)
                        end
                        if self.AcrylicPart then pcall(function() self.AcrylicPart:Destroy() end) self.AcrylicPart, self.AcrylicMesh = nil, nil end
                        if self.AcrylicDof then pcall(function() self.AcrylicDof:Destroy() end) self.AcrylicDof = nil end
                    end
                    if self.Destroyed then clear() else task.delay(0.22, clear) end
                end

                function Window:SetBlur(on)
                    Nova.trace("SetBlur")
                    self.BlurEnabled = on and true or false
                    self.State.set("blur", self.BlurEnabled)
                    if self.IsOpen then self:_blur(self.BlurEnabled) end
                end

                local GENIE_IN = TweenInfo.new(0.44, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local GENIE_OUT = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                local FADE_IN = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local FADE_OUT = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

                function Window:_launcherPoint()
                    local L = self.Launcher
                    if not (L and L.Visible and L.Parent and M.enabled) then return nil end
                    local c = L.AbsolutePosition + L.AbsoluteSize / 2 - self.Gui.AbsolutePosition
                    return UDim2.fromOffset(math.floor(c.X), math.floor(c.Y))
                end

                function Window:_scalingDefer(fn)
                    self.ScaleDeferred = self.ScaleDeferred or {}
                    self.ScaleDeferred[fn] = true
                end

                function Window:_endScaling()
                    self.Scaling = false
                    local list = self.ScaleDeferred
                    self.ScaleDeferred = nil
                    if list then
                        for fn in pairs(list) do pcall(fn) end
                    end
                end

                function Window:_stopGenie()
                    for _, key in ipairs({ "GeniePos", "GenieScale" }) do
                        if self[key] then
                            pcall(function() self[key]:Cancel() end)
                            self[key] = nil
                        end
                    end
                end

                function Window:Open()
                    Nova.trace("Open")
                    if self.Destroyed or self.IsOpen then return end
                    self.IsOpen = true
                    self.OpenToken = (self.OpenToken or 0) + 1
                    local token = self.OpenToken
                    self:_stopGenie()
                    local home = self:_placeOnScreen(self.HomePos or self.Root.Position)
                    self.HomePos = nil
                    self.Root.Position = home
                    local from = self.GenieAnim and self:_launcherPoint() or nil
                    if self.IsTouch and self.Launcher then self.Launcher.Visible = false end
                    local target = self.AutoScale * self.UserScale
                    self.Win.GroupTransparency = 1
                    if from then
                        self.Scaling = true
                        self.Root.Position = from
                        self.Scale.Scale = target * 0.12
                        self:_syncLayers()
                        self.Root.Visible = true
                        self.FloatLayer.Visible = true
                        self.GeniePos = tween(self.Root, GENIE_IN, { Position = home })
                        self.GenieScale = tween(self.Scale, GENIE_IN, { Scale = target })
                        tween(self.Win, FADE_IN, { GroupTransparency = 0 })
                        task.delay(GENIE_IN.Time + 0.03, function()
                            if self.OpenToken == token then self:_endScaling() end
                        end)
                    else
                        self:_endScaling()
                        self.Scale.Scale = target
                        self:_syncLayers()
                        self.Root.Visible = true
                        self.FloatLayer.Visible = true
                        tween(self.Win, FADE_IN, { GroupTransparency = 0 })
                    end
                    if self.WindowShadow then
                        self.WindowShadow.ImageTransparency = 1
                        tween(self.WindowShadow, "Slow", { ImageTransparency = 0.45 })
                    end
                    self:_blur(true)
                    self:_launcherState(true)
                    S.play("open")
                    if not self.Current and self.TabList[1] then self:SelectTab(self.TabList[1]) end
                    task.defer(function() self:_layoutTabs(false) end)
                end

                function Window:Close()
                    Nova.trace("Close")
                    if self.Destroyed or not self.IsOpen then return end
                    self.IsOpen = false
                    self.OpenToken = (self.OpenToken or 0) + 1
                    local token = self.OpenToken
                    self:ClosePopups()
                    self:HideTip()
                    self:_stopGenie()
                    if self.Launcher then self.Launcher.Visible = self.LauncherOn end
                    local target = self.AutoScale * self.UserScale
                    local into = self.GenieAnim and self:_launcherPoint() or nil
                    local delay = 0.2
                    if into then
                        self.Scaling = true
                        self.HomePos = self.Root.Position
                        self.GeniePos = tween(self.Root, GENIE_OUT, { Position = into })
                        self.GenieScale = tween(self.Scale, GENIE_OUT, { Scale = target * 0.12 })
                        tween(self.Win, FADE_OUT, { GroupTransparency = 1 })
                        delay = GENIE_OUT.Time + 0.03
                        local L = self.LauncherParts
                        if L then
                            task.delay(0.24, function()
                                if self.OpenToken ~= token then return end
                                tween(L.scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = self.LauncherBase * 1.08 })
                                task.delay(0.12, function() tween(L.scale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = self.LauncherBase }) end)
                            end)
                        end
                    else
                        tween(self.Win, "Exit", { GroupTransparency = 1 })
                    end
                    if self.WindowShadow then tween(self.WindowShadow, "Exit", { ImageTransparency = 1 }) end
                    self:_blur(false)
                    self:_launcherState(false)
                    S.play("close")
                    task.delay(delay, function()
                        if self.IsOpen or self.OpenToken ~= token then return end
                        self:_stopGenie()
                        self.Root.Visible = false
                        if self.HomePos then
                            self.Root.Position = self.HomePos
                            self.HomePos = nil
                        end
                        self.Scale.Scale = target
                        task.defer(function()
                            if not self.IsOpen and self.OpenToken == token then self:_endScaling() end
                        end)
                    end)
                end

                function Window:RegistryCount()
                    return U.regCount()
                end

                function Window:Toggle()
                    if self.IsOpen then self:Close() else self:Open() end
                end

                function Window:Destroy()
                    if self.Destroyed then return end
                    self.Destroyed = true
                    self:_blur(false)
                    for _, c in ipairs(self.Conns) do pcall(function() c:Disconnect() end) end
                    pcall(function() self.Gui:Destroy() end)
                    pcall(function() self.Parking:Destroy() end)
                    if self.OnDestroy then pcall(self.OnDestroy) end
                end

                function Window:ClosePopups()
                    for _, p in ipairs(self.Popups) do pcall(p.close) end
                    self.Popups = {}
                    self.Catcher.Visible = false
                end

                function Window:OpenPopup(popup)
                    Nova.trace("OpenPopup")
                    self:ClosePopups()
                    table.insert(self.Popups, popup)
                    self.Catcher.Visible = true
                end

                function Window:PointerOverUI()
                    if self.Destroyed then return false end
                    local m = U.mouse()
                    local function inside(g)
                        if not g or not g.Visible then return false end
                        local p, s = g.AbsolutePosition, g.AbsoluteSize
                        return m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + s.Y
                    end
                    if self.IsOpen and inside(self.Root) then return true end
                    for _, layer in ipairs({ self.FloatLayer, self.PopLayer }) do
                        for _, c in ipairs(layer:GetChildren()) do
                            if c:IsA("GuiObject") and inside(c) then return true end
                        end
                    end
                    if inside(self.KeybindFrame) or inside(self.WatermarkFrame) or inside(self.FlingFrame) then return true end
                    return inside(self.Launcher)
                end

                Nova.WindowClass.PopIn = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                Nova.WindowClass.PopOut = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

                function Window:PopupShell(width, height)
                    local frame = new("Frame", { Name = "PopupFrame", BackgroundTransparency = 1, Size = UDim2.fromOffset(width, height), ZIndex = 2, Parent = self.PopLayer })
                    local sh = X.image(frame, "shadow9", { Name = "Shadow", Position = UDim2.fromOffset(-30, -22), Size = UDim2.new(1, 60, 1, 64), SliceScale = 1, ImageTransparency = 0.4, ZIndex = 1 })
                    local shell = new("CanvasGroup", { Name = "Popup", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, GroupTransparency = 1, ZIndex = 2, Parent = frame })
                    bind(shell, "BackgroundColor3", "Elevated")
                    U.corner(shell, 12)
                    local gloss = X.image(shell, "gloss9", { Size = UDim2.fromScale(1, 1), SliceScale = 0.86, ImageTransparency = 0.88, ZIndex = 2 })
                    local rim = X.image(shell, "rim9", { Size = UDim2.fromScale(1, 1), SliceScale = 0.86, ImageTransparency = 0.45, ZIndex = 300 })
                    if rim then bind(rim, "ImageColor3", "Glass") else bind(U.stroke(shell, Color3.new(1, 1, 1), 1, 0.85), "Color", "Glass") end
                    local sc = new("UIScale", { Scale = 0.92, Parent = shell })
                    return frame, shell, sc
                end

                function Window:PopupPlace(anchor, width, height, align)
                    local scale = math.max(self.PopScale.Scale, 0.1)
                    local origin = self.PopLayer.AbsolutePosition
                    local pos = (anchor.AbsolutePosition - origin) / scale
                    local size = anchor.AbsoluteSize / scale
                    local screen = self.PopLayer.AbsoluteSize / scale
                    local x = (align == "left") and pos.X or (pos.X + size.X - width)
                    x = math.clamp(x, 8, math.max(8, screen.X - width - 8))
                    local y = pos.Y + size.Y + 6
                    local up = false
                    if y + height > screen.Y - 8 then
                        y = math.max(8, pos.Y - height - 6)
                        up = true
                    end
                    return x, y, (align == "left") and 0 or 1, up and 1 or 0
                end

                local REVEAL = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local REVEAL_FADE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local CONCEAL = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

                function Window:PopupReveal(frame, shell, sc, up)
                    local oy = up and 1 or 0
                    if sc then sc.Scale = 1 end
                    shell.AnchorPoint = Vector2.new(0, oy)
                    shell.Position = UDim2.fromScale(0, oy)
                    shell.Size = UDim2.new(1, 0, 0, 0)
                    shell.GroupTransparency = 1
                    tween(shell, REVEAL, { Size = UDim2.fromScale(1, 1) })
                    tween(shell, REVEAL_FADE, { GroupTransparency = 0 })
                    local sh = frame:FindFirstChild("Shadow")
                    if sh then
                        sh.ImageTransparency = 1
                        tween(sh, REVEAL, { ImageTransparency = 0.4 })
                    end
                end

                function Window:PopupConceal(frame, shell)
                    tween(shell, CONCEAL, { Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1 })
                    local sh = frame:FindFirstChild("Shadow")
                    if sh then tween(sh, CONCEAL, { ImageTransparency = 1 }) end
                end

                function Window:PopupOrigin(shell, ox, oy)
                    shell.AnchorPoint = Vector2.new(ox or 0.5, oy or 0.5)
                    shell.Position = UDim2.fromScale(ox or 0.5, oy or 0.5)
                end

                function Window:ConfirmPopup(anchor, conf, onAccept)
                    conf = type(conf) == "table" and conf or {}
                    local width = 296
                    local textW = width - 32
                    local body = tostring(conf.Text or "")
                    local bodyH = 0
                    if body ~= "" then
                        local px = math.ceil(13 * (tonumber(U.textScale) or 1))
                        local ok, size = pcall(function()
                            return Nova.Services.TextService:GetTextSize(body, px, Enum.Font.GothamMedium, Vector2.new(textW / 1.12, 1000))
                        end)
                        bodyH = ((ok and size) and size.Y or 40) + 6
                    end
                    local btnY = 50 + (bodyH > 0 and (bodyH + 8) or 0)
                    local height = btnY + 34 + 14
                    local frame, shell, sc = self:PopupShell(width, height)
                    local px, py, _, oy = self:PopupPlace(anchor, width, height, "right")
                    frame.Position = UDim2.fromOffset(px, py)
                    self:PopupReveal(frame, shell, sc, oy == 1)
                    local danger = conf.Danger == true
                    local WHITE_TOKEN = function() return Color3.new(1, 1, 1) end
                    local badge = new("Frame", { Name = "Badge", Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(28, 28), BorderSizePixel = 0, BackgroundTransparency = 0.8, ZIndex = 61, Parent = shell })
                    bind(badge, "BackgroundColor3", danger and "Danger" or "Accent")
                    U.corner(badge, 9)
                    Nova.icon({ Parent = badge, Icon = conf.Icon or (danger and "triangle-alert" or "info"), Size = 15, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = danger and "Danger" or "Accent", Z = 62 })
                    Nova.label({ Parent = shell, Text = tostring(conf.Title or "Are you sure?"), Font = F.Semi(), Size = 15, Pos = UDim2.fromOffset(50, 15), Box = UDim2.new(1, -64, 0, 26), Truncate = true, Color = "Text", Z = 61 })
                    local bodyLabel
                    if bodyH > 0 then
                        bodyLabel = Nova.label({ Parent = shell, Text = body, Font = F.Medium(), Size = 13, Pos = UDim2.fromOffset(16, 50), Box = UDim2.new(1, -32, 0, bodyH), Wrap = true, AlignY = Enum.TextYAlignment.Top, Color = "Muted", Z = 61 })
                    end
                    local closed = false
                    local function close()
                        if closed then return end
                        closed = true
                        self:ClosePopups()
                    end
                    local function makeBtn(text, x, w, primary)
                        local b = new("TextButton", { Name = primary and "Accept" or "Cancel", Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(x, btnY), Size = UDim2.fromOffset(w, 34), BorderSizePixel = 0, ZIndex = 61, Parent = shell })
                        bind(b, "BackgroundColor3", primary and (danger and "Danger" or "Accent") or "Surface2")
                        U.corner(b, 9)
                        local st = U.stroke(b, Color3.new(1, 1, 1), 1, primary and 0.78 or 0.88)
                        bind(st, "Color", "Glass")
                        Nova.label({ Parent = b, Text = text, Font = F.Semi(), Size = 14, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = primary and (danger and WHITE_TOKEN or "OnAccent") or "Text", Z = 62 })
                        local bsc = new("UIScale", { Parent = b })
                        b.MouseEnter:Connect(function()
                            tween(b, "Quick", { BackgroundTransparency = 0.14 })
                            S.play("hover", 0.6)
                        end)
                        U.leave(b, function()
                            tween(b, "Quick", { BackgroundTransparency = 0 })
                            tween(bsc, "Quick", { Scale = 1 })
                        end)
                        b.MouseButton1Down:Connect(function() tween(bsc, "Quick", { Scale = 0.97 }) end)
                        b.MouseButton1Up:Connect(function() tween(bsc, "Quick", { Scale = 1 }) end)
                        return b
                    end
                    local half = math.floor((width - 32 - 8) / 2)
                    local cancel = makeBtn(tostring(conf.Cancel or "Cancel"), 16, half, false)
                    local accept = makeBtn(tostring(conf.Accept or "OK"), 16 + half + 8, half, true)
                    if bodyLabel then
                        task.delay(0.05, function()
                            if closed or not bodyLabel.Parent then return end
                            local need = math.ceil(bodyLabel.TextBounds.Y) + 6
                            if need > bodyH then
                                local extra = need - bodyH
                                bodyH = need
                                bodyLabel.Size = UDim2.new(1, -32, 0, need)
                                frame.Size = UDim2.fromOffset(width, height + extra)
                                cancel.Position = UDim2.fromOffset(cancel.Position.X.Offset, btnY + extra)
                                accept.Position = UDim2.fromOffset(accept.Position.X.Offset, btnY + extra)
                                if oy == 1 then frame.Position = UDim2.fromOffset(px, py - extra) end
                            end
                        end)
                    end
                    cancel.MouseButton1Click:Connect(function()
                        S.play("click")
                        close()
                    end)
                    accept.MouseButton1Click:Connect(function()
                        S.play("click")
                        close()
                        if type(onAccept) == "function" then task.defer(onAccept) end
                    end)
                    self:OpenPopup({
                        close = function()
                            closed = true
                            self:PopupConceal(frame, shell)
                            task.delay(0.18, function() frame:Destroy() end)
                        end,
                    })
                end
            end

            do
                local U, M, T, F, I, S, X = Nova.U, Nova.Motion, Nova.Theme, Nova.Font, Nova.Icons, Nova.Sound, Nova.Tex
                local new, tween, bind = U.new, M.tween, T.bind
                local label, icon = Nova.label, Nova.icon
                local Window = Nova.WindowClass
                local UIS = Nova.Services.UserInputService
                local WHITE = Color3.new(1, 1, 1)

                local W_EXP, W_COL = 228, 64
                local W_MIN, W_MAX = 188, 340
                local ROW_H, ROW_C, GAP = 40, 36, 2
                local CAP_H, CAP_C = 30, 12
                local TILE_C, ICON_C = 32, 17
                local ROWINFO = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                Window.SIDEBAR_EXPANDED, Window.SIDEBAR_COLLAPSED = W_EXP, W_COL

                local function paint(inst, prop, token, info)
                    local map = T.registry[inst]
                    if not map then
                        map = {}
                        T.registry[inst] = map
                    end
                    map[prop] = token
                    tween(inst, info or "Base", { [prop] = T.resolve(token) })
                end
                Nova.paint = paint

                local function kp(t, v) return NumberSequenceKeypoint.new(t, v) end

                local function railGeo(collapsed)
                    if collapsed then return { logoX = (W_COL - 36) / 2, logoY = 10, searchY = 52, tabTop = 92, foot = 44 } end
                    return { logoX = 16, logoY = 14, searchY = 68, tabTop = 112, foot = 50 }
                end

                local function firstCap(self)
                    for _, x in ipairs(self.Groups) do
                        if x.Row then return x end
                    end
                end

                local function tileAlpha(self, hover)
                    if self.SidebarCollapsed then return 1 end
                    return hover and 0.05 or 0.4
                end

                Window.Densities = { "Comfortable", "Compact" }

                function Window.applyDensity(self)
                    if self.Density == "Compact" then
                        self.RowH, self.CapH, self.TileS, self.LabelX = 31, 22, 22, 36
                    else
                        self.Density = "Comfortable"
                        self.RowH, self.CapH, self.TileS, self.LabelX = ROW_H, CAP_H, 30, 46
                    end
                end

                function Window:_buildSidebar(opts)
                    local win, st = self.Win, self.State
                    local savedCollapsed = st.get("sidebarCollapsed", nil)
                    if savedCollapsed == nil then
                        local cam = workspace.CurrentCamera
                        savedCollapsed = cam ~= nil and cam.ViewportSize.X < 760
                    end
                    local collapsed = savedCollapsed == true
                    local geo = railGeo(collapsed)
                    self.SidebarCollapsed = collapsed
                    self.Density = st.get("density", opts.Density or "Comfortable")
                    Window.applyDensity(self)
                    self.GroupLabels = st.get("groupLabels", true) ~= false
                    self.DefaultSidebarWidth = math.clamp(tonumber(opts.SidebarWidth) or W_EXP, W_MIN, W_MAX)
                    self.ExpandedWidth = math.clamp(tonumber(st.get("sidebarWidth", self.DefaultSidebarWidth)) or self.DefaultSidebarWidth, W_MIN, W_MAX)
                    local width = collapsed and W_COL or self.ExpandedWidth
                    self.SidebarWidth = width

                    local sidebar = new("Frame", {
                        Name = "Sidebar",
                        Size = UDim2.new(0, width, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 0.3 + (1 - self.Opacity) * 0.7,
                        ClipsDescendants = true,
                        ZIndex = 2,
                        Parent = win,
                    })
                    bind(sidebar, "BackgroundColor3", "Sidebar")
                    self.Sidebar = sidebar
                    local edge = new("Frame", { Name = "Edge", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, BackgroundTransparency = 0.84, ZIndex = 3, Parent = sidebar })
                    bind(edge, "BackgroundColor3", "Glass")
                    new("UIGradient", { Transparency = NumberSequence.new({ kp(0, 1), kp(0.1, 0), kp(0.9, 0), kp(1, 1) }), Rotation = 90, Parent = edge })

                    local brand = new("Frame", { Name = "Brand", Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1, ZIndex = 3, Parent = sidebar })
                    self.BrandFrame = brand
                    local logo = new("TextButton", { Name = "Logo", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(geo.logoX, geo.logoY), Size = UDim2.fromOffset(36, 36), ZIndex = 4, Parent = brand })
                    self.LogoButton = logo
                    local logoGlow = X.image(logo, "glow", { Name = "Glow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(96, 96), ImageTransparency = 0.6, ZIndex = 4 })
                    if logoGlow then
                        if opts.Logo then logoGlow.Visible = false else bind(logoGlow, "ImageColor3", "Accent") end
                    end
                    if opts.Logo then
                        new("ImageLabel", { Name = "Mark", BackgroundTransparency = 1, Size = UDim2.fromOffset(42, 42), Position = UDim2.fromOffset(-3, -3), Image = opts.Logo, ScaleType = Enum.ScaleType.Fit, ZIndex = 6, Parent = logo })
                    else
                        Nova.tile(logo, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Accent", Z = 5 })
                        label({ Parent = logo, Text = tostring(opts.Initial or string.sub(opts.Title or "N", 1, 1)), Font = F.Heavy(), Size = 19, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = "OnAccent", Z = 6 })
                    end
                    local textX = opts.Logo and 66 or 60
                    self.TitleLabel = label({ Parent = brand, Text = opts.Title or "Nova", Font = F.Bold(), Size = 17, Pos = UDim2.fromOffset(textX, 16), Box = UDim2.new(1, -(textX + 44), 0, 19), Truncate = true, Z = 4 })
                    self.SubtitleLabel = label({ Parent = brand, Text = opts.Subtitle or "", Font = F.Medium(), Size = 11, Pos = UDim2.fromOffset(textX, 36), Box = UDim2.new(1, -(textX + 44), 0, 14), Color = "Muted", Truncate = true, Z = 4 })

                    if collapsed then
                        self.TitleLabel.TextTransparency, self.SubtitleLabel.TextTransparency = 1, 1
                    end
                    local edge = new("TextButton", { Name = "SidebarEdge", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0, width, 0, 0), Size = UDim2.new(0, 10, 1, 0), Visible = not collapsed, ZIndex = 42, Parent = win })
                    local edgeLine = new("Frame", { Name = "Line", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(0, 2, 1, 0), BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 43, Parent = edge })
                    bind(edgeLine, "BackgroundColor3", "Accent")
                    new("UIGradient", { Transparency = NumberSequence.new({ kp(0, 1), kp(0.18, 0), kp(0.82, 0), kp(1, 1) }), Rotation = 90, Parent = edgeLine })
                    self.SidebarEdge = edge
                    local edgeDrag, edgeStart, edgeW, edgeLast, edgeIn = false, 0, 0, 0, nil
                    edge.MouseEnter:Connect(function()
                        if not edgeDrag then tween(edgeLine, "Quick", { BackgroundTransparency = 0.45 }) end
                        self:ShowTip("Drag to resize")
                    end)
                    U.leave(edge, function()
                        if not edgeDrag then tween(edgeLine, "Quick", { BackgroundTransparency = 1 }) end
                        self:HideTip()
                    end)
                    edge.InputBegan:Connect(function(input)
                        if not U.isClick(input) or self.SidebarCollapsed then return end
                        self:HideTip()
                        if os.clock() - edgeLast < 0.35 then
                            edgeLast = 0
                            self:SetSidebarWidth(self.DefaultSidebarWidth)
                            return
                        end
                        edgeLast = os.clock()
                        edgeDrag, edgeStart, edgeW, edgeIn = true, input.Position.X, self.SidebarWidth, input
                        tween(edgeLine, "Quick", { BackgroundTransparency = 0.05 })
                    end)
                    U.connect(UIS.InputChanged, function(input)
                        if edgeDrag and U.sameMove(input, edgeIn) then
                            local sc = math.max(self.Scale.Scale, 0.1)
                            self:SetSidebarWidth(edgeW + (input.Position.X - edgeStart) / sc, true)
                        end
                    end, self.Conns)
                    U.connect(UIS.InputEnded, function(input)
                        if edgeDrag and U.sameEnd(input, edgeIn) then
                            edgeDrag = false
                            tween(edgeLine, "Base", { BackgroundTransparency = 1 })
                            self.State.set("sidebarWidth", math.floor(self.ExpandedWidth + 0.5))
                        end
                    end, self.Conns)

                    local fold = new("TextButton", { Name = "Fold", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 19), Size = UDim2.fromOffset(28, 28), ZIndex = 5, Parent = brand })
                    local foldTile, foldTextured = Nova.tile(fold, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.35, Z = 5 })
                    local foldIcon = icon({ Parent = fold, Icon = "panel-left-close", Size = 15, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 6 })
                    local foldProp = foldTextured and "ImageColor3" or "BackgroundColor3"
                    fold.MouseEnter:Connect(function()
                        tween(foldTile, "Quick", { [foldProp] = T.resolve("Elevated") })
                        tween(foldIcon, "Quick", { ImageColor3 = T.resolve("Text") })
                        self:ShowTip("Collapse sidebar")
                    end)
                    U.leave(fold, function()
                        tween(foldIcon, "Quick", { ImageColor3 = T.resolve("Muted") })
                        self:HideTip()
                    end)
                    fold.MouseButton1Click:Connect(function()
                        S.play("click")
                        self:HideTip()
                        self:SetSidebarCollapsed(true)
                    end)
                    self.FoldButton = fold
                    logo.MouseButton1Click:Connect(function()
                        if self.SidebarCollapsed then
                            S.play("click")
                            self:SetSidebarCollapsed(false)
                        end
                    end)
                    logo.MouseEnter:Connect(function()
                        if self.SidebarCollapsed then self:ShowTip("Expand sidebar") end
                    end)
                    U.leave(logo, function() self:HideTip() end)

                    local searchHolder = new("Frame", { Name = "SearchHolder", Position = UDim2.fromOffset(0, geo.searchY), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, ZIndex = 3, Parent = sidebar })
                    local search = new("Frame", { Name = "Search", Position = UDim2.fromOffset(12, 3), Size = UDim2.new(1, -24, 0, 34), BorderSizePixel = 0, ZIndex = 3, Parent = searchHolder })
                    bind(search, "BackgroundColor3", "Elevated")
                    U.corner(search, 10)
                    new("UIGradient", { Color = ColorSequence.new(WHITE, Color3.fromRGB(190, 193, 202)), Rotation = 90, Parent = search })
                    local searchStroke = U.stroke(search, WHITE, 1, 0.86)
                    bind(searchStroke, "Color", "Glass")
                    icon({ Parent = search, Icon = "search", Size = 15, Pos = UDim2.new(0, 11, 0.5, 0), Anchor = Vector2.new(0, 0.5), Color = "Faint", Z = 4 })
                    local searchBox = new("TextBox", {
                        Name = "Box",
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(34, 0),
                        Size = UDim2.new(1, -44, 1, 0),
                        FontFace = F.Medium(),
                        TextSize = 13,
                        PlaceholderText = opts.SearchText or "Search",
                        Text = "",
                        ClearTextOnFocus = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 4,
                        Parent = search,
                    })
                    bind(searchBox, "TextColor3", "Text")
                    bind(searchBox, "PlaceholderColor3", "Faint")
                    self.SearchBox, self.SearchField = searchBox, search
                    search.Visible = not collapsed
                    fold.Visible = not collapsed
                    searchBox.Focused:Connect(function()
                        paint(searchStroke, "Color", "Accent", "Quick")
                        tween(searchStroke, "Quick", { Transparency = 0.35 })
                    end)
                    searchBox.FocusLost:Connect(function()
                        paint(searchStroke, "Color", "Glass", "Quick")
                        tween(searchStroke, "Quick", { Transparency = 0.86 })
                    end)
                    searchBox:GetPropertyChangedSignal("Text"):Connect(function() self:Search(searchBox.Text) end)
                    searchBox.Focused:Connect(function()
                        if string.find(searchBox.Text, "%S") and not self.SearchPop then self:Search(searchBox.Text) end
                    end)
                    searchBox.FocusLost:Connect(function(enter, input)
                        local pop = self.SearchPop
                        if enter then
                            if pop and pop.Items and pop.Items[pop.Sel or 1] then self:_searchJump(pop.Items[pop.Sel or 1]) end
                        elseif input and input.KeyCode == Enum.KeyCode.Escape then
                            searchBox.Text = ""
                        end
                    end)
                    U.connect(UIS.InputBegan, function(input)
                        local pop = self.SearchPop
                        if not pop then return end
                        local kc = input.KeyCode
                        if (kc == Enum.KeyCode.Down or kc == Enum.KeyCode.Up) and searchBox:IsFocused() then
                            self:_searchSelect((pop.Sel or 1) + (kc == Enum.KeyCode.Down and 1 or -1))
                            return
                        end
                        local t = input.UserInputType
                        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                            local m = U.mouse()
                            local function inside(g)
                                if not g or not g.Parent then return false end
                                local p, s = g.AbsolutePosition, g.AbsoluteSize
                                return m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + s.Y
                            end
                            if not inside(pop.Frame) and not inside(search) then self:_searchClose() end
                        end
                    end, self.Conns)

                    local sTile = new("TextButton", { Name = "SearchTile", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 3), Size = UDim2.fromOffset(TILE_C + 8, 34), Visible = collapsed, ZIndex = 3, Parent = searchHolder })
                    local sFace = new("Frame", { Name = "Face", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 3, Parent = sTile })
                    bind(sFace, "BackgroundColor3", "Elevated")
                    U.corner(sFace, 10)
                    local sIcon = icon({ Parent = sTile, Icon = "search", Size = ICON_C, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 4 })
                    sTile.MouseButton1Click:Connect(function()
                        S.play("click")
                        self:SetSidebarCollapsed(false)
                        task.delay(0.2, function() searchBox:CaptureFocus() end)
                    end)
                    sTile.MouseEnter:Connect(function()
                        tween(sFace, "Quick", { BackgroundTransparency = 0.55 })
                        paint(sIcon, "ImageColor3", "Text", "Quick")
                        self:ShowTip("Search")
                    end)
                    U.leave(sTile, function()
                        tween(sFace, "Quick", { BackgroundTransparency = 1 })
                        paint(sIcon, "ImageColor3", "Muted", "Quick")
                        self:HideTip()
                    end)
                    self.SearchTile = sTile

                    local tabClip = new("CanvasGroup", { Name = "TabsClip", Position = UDim2.fromOffset(0, geo.tabTop), Size = UDim2.new(1, 0, 1, -(geo.tabTop + geo.foot + 2)), BackgroundTransparency = 1, ZIndex = 3, Parent = sidebar })
                    self.TabClip = tabClip
                    local tabScroll = new("ScrollingFrame", {
                        Name = "Tabs",
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ScrollBarThickness = 0,
                        ScrollBarImageTransparency = 1,
                        CanvasSize = UDim2.new(),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ZIndex = 3,
                        Parent = tabClip,
                    })
                    bind(tabScroll, "ScrollBarImageColor3", "Faint")
                    local tabFade = new("UIGradient", { Rotation = 90, Parent = tabClip })
                    local function updateTabFade()
                        if self.Scaling then self:_scalingDefer(updateTabFade) return end
                        local h = tabClip.AbsoluteSize.Y
                        if h < 60 then return end
                        local topK = math.clamp(tabScroll.CanvasPosition.Y / 10, 0, 1)
                        local botK = math.clamp((tabScroll.AbsoluteCanvasSize.Y - tabScroll.CanvasPosition.Y - tabScroll.AbsoluteWindowSize.Y) / 10, 0, 1)
                        local f = math.min(18 / h, 0.25)
                        tabFade.Transparency = NumberSequence.new({ kp(0, topK * 0.92), kp(f, 0), kp(1 - f, 0), kp(1, botK * 0.92) })
                    end
                    tabScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateTabFade)
                    tabScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateTabFade)
                    tabScroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateTabFade)
                    task.defer(updateTabFade)
                    local tabCanvas = new("Frame", { Name = "Canvas", Size = UDim2.new(1, 0, 0, 10), BackgroundTransparency = 1, Parent = tabScroll })
                    self.TabScroll, self.TabCanvas = tabScroll, tabCanvas
                    self.TabListFrame = tabCanvas

                    local foot = new("Frame", { Name = "Footer", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, geo.foot), BackgroundTransparency = 1, ZIndex = 3, Parent = sidebar })
                    local fline = new("Frame", { Name = "Line", Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.88, ZIndex = 3, Parent = foot })
                    bind(fline, "BackgroundColor3", "Glass")
                    new("UIGradient", { Transparency = NumberSequence.new({ kp(0, 1), kp(0.2, 0), kp(0.8, 0), kp(1, 1) }), Parent = fline })
                    self.FooterText = label({ Parent = foot, Text = tostring(opts.Footer or ""), Font = F.Medium(), Size = 11, Pos = UDim2.fromOffset(18, 1), Box = UDim2.new(1, -96, 1, -1), Color = "Faint", Truncate = true, Z = 4, Name = "Version" })
                    local chip = new("TextButton", { Name = "KeyChip", Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 1), Size = UDim2.fromOffset(34, 22), BackgroundTransparency = 1, ZIndex = 4, Parent = foot })
                    local chipFace = Nova.tile(chip, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.2, SliceScale = 0.45, Z = 4 })
                    local chipRim = X.image(chip, "rim9", { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.45, ImageTransparency = 0.6, ZIndex = 6 })
                    if chipRim then bind(chipRim, "ImageColor3", "Glass") end
                    self.FooterKey = label({ Parent = chip, Text = "", Font = F.Semi(), Size = 11, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = "Muted", Z = 7, Name = "Key" })
                    self.FooterKey:GetPropertyChangedSignal("TextBounds"):Connect(function()
                        chip.Size = UDim2.fromOffset(math.max(30, math.ceil(self.FooterKey.TextBounds.X) + 18), 22)
                    end)
                    self.FooterChip = chip
                    self.Footer = foot
                    chip.Visible = not self.IsTouch
                    local chipListening, chipPulse, chipIdleAt = false, nil, 0
                    local function chipIdle()
                        chipListening = false
                        chipIdleAt = os.clock()
                        if chipPulse then chipPulse:Cancel() chipPulse = nil end
                        if chipRim then
                            paint(chipRim, "ImageColor3", "Glass", "Quick")
                            tween(chipRim, "Quick", { ImageTransparency = 0.6 })
                        end
                        paint(self.FooterKey, "TextColor3", "Muted", "Quick")
                        self:_syncFooter()
                        task.defer(function() if not chipListening then self.Listening = false end end)
                    end
                    chip.MouseEnter:Connect(function()
                        if chipListening then return end
                        paint(self.FooterKey, "TextColor3", "Text", "Quick")
                        if chipRim then tween(chipRim, "Quick", { ImageTransparency = 0.35 }) end
                    end)
                    U.leave(chip, function()
                        if chipListening then return end
                        paint(self.FooterKey, "TextColor3", "Muted", "Quick")
                        if chipRim then tween(chipRim, "Quick", { ImageTransparency = 0.6 }) end
                    end)
                    chip.MouseButton1Click:Connect(function()
                        if chipListening or os.clock() - chipIdleAt < 0.3 then return end
                        S.play("click")
                        chipListening = true
                        self.FooterKey.Text = "\226\128\166"
                        paint(self.FooterKey, "TextColor3", "Accent", "Quick")
                        if chipRim then
                            paint(chipRim, "ImageColor3", "Accent", "Quick")
                            chipRim.ImageTransparency = 0.5
                            chipPulse = Nova.Services.TweenService:Create(chipRim, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { ImageTransparency = 0.05 })
                            chipPulse:Play()
                        end
                        task.defer(function() if chipListening then self.Listening = true end end)
                    end)
                    U.connect(UIS.InputBegan, function(input)
                        if not chipListening or not self.Listening then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local k = input.KeyCode
                            if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Unknown then
                                chipIdle()
                                return
                            end
                            self:SetKey(k)
                            S.play("tick")
                            chipIdle()
                        elseif U.isClick(input) or input.UserInputType == Enum.UserInputType.MouseButton2 then
                            chipIdle()
                        end
                    end, self.Conns)

                    U.connect(UIS.InputChanged, function(input)
                        if not U.sameMove(input, self.PressInput) then return end
                        self:_reorderMove()
                    end, self.Conns)
                    U.connect(UIS.InputEnded, function(input)
                        if U.sameEnd(input, self.PressInput) then self:_reorderEnd() end
                    end, self.Conns)
                end

                function Window:_ensureGroup()
                    if self.CurGroup then return self.CurGroup end
                    local g = { Key = "_", Tabs = {}, Collapsed = false }
                    table.insert(self.Groups, g)
                    self.CurGroup = g
                    return g
                end

                function Window:TabGroup(text)
                    text = tostring(text or "")
                    local saved = self.State.get("groups", {})
                    local g = { Key = text, Tabs = {}, Collapsed = type(saved) == "table" and saved[text] == true }
                    local row = new("Frame", { Name = "Group_" .. text, Size = UDim2.new(1, -16, 0, self.CapH), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1, Parent = self.TabCanvas })
                    local hit = new("TextButton", { Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = row })
                    g.Row = row
                    g.Label = label({ Parent = row, Text = text, Font = F.Bold(), Size = 11, Pos = UDim2.fromOffset(10, 2), Box = UDim2.new(1, -36, 1, -2), Color = "Faint", Z = 2, Name = "Caption" })
                    g.Chev = icon({ Parent = row, Icon = "chevron-down", Size = 13, Pos = UDim2.new(1, -10, 0.5, 1), Anchor = Vector2.new(1, 0.5), Color = "Faint", Z = 2 })
                    g.Line = new("Frame", { Name = "Divider", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(22, 2), BorderSizePixel = 0, BackgroundTransparency = 1, Parent = row })
                    bind(g.Line, "BackgroundColor3", "Glass")
                    U.corner(g.Line, UDim.new(1, 0))
                    if g.Collapsed then g.Chev.Rotation = -90 end
                    hit.MouseEnter:Connect(function()
                        paint(g.Label, "TextColor3", "Muted", "Quick")
                        paint(g.Chev, "ImageColor3", "Muted", "Quick")
                    end)
                    U.leave(hit, function()
                        paint(g.Label, "TextColor3", "Faint", "Quick")
                        paint(g.Chev, "ImageColor3", "Faint", "Quick")
                    end)
                    hit.MouseButton1Click:Connect(function()
                        if self.SidebarCollapsed then return end
                        S.play("tick")
                        self:SetGroupCollapsed(g, not g.Collapsed)
                    end)
                    table.insert(self.Groups, g)
                    self.CurGroup = g
                    if self.SidebarCollapsed then
                        g.Label.TextTransparency, g.Chev.ImageTransparency, g.Line.BackgroundTransparency = 1, 1, firstCap(self) == g and 1 or 0.88
                    end
                    self:_layoutTabs(false)
                    return g.Label
                end

                function Window:SetGroupCollapsed(g, v)
                    if type(g) == "string" then
                        for _, x in ipairs(self.Groups) do if x.Key == g then g = x break end end
                    end
                    if type(g) ~= "table" then return end
                    g.Collapsed = v and true or false
                    local saved = self.State.get("groups", {})
                    if type(saved) ~= "table" then saved = {} end
                    saved[g.Key] = g.Collapsed or nil
                    self.State.data.groups = saved
                    self.State.save()
                    if g.Chev then tween(g.Chev, "Base", { Rotation = g.Collapsed and -90 or 0 }) end
                    self:_layoutTabs(true)
                end

                local function rank(order, name)
                    if type(order) ~= "table" then return math.huge end
                    for i, n in ipairs(order) do if n == name then return i end end
                    return math.huge
                end

                function Window:_addTabRow(tab, opts)
                    local g = self:_ensureGroup()
                    tab.Group = g
                    local collapsed = self.SidebarCollapsed
                    local rowH = collapsed and ROW_C or self.RowH
                    local row = new("CanvasGroup", { Name = tab.Name, Size = UDim2.new(1, -16, 0, rowH), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1, Parent = self.TabCanvas })
                    tab.Row = row
                    U.corner(row, 12)

                    local bg = new("Frame", { Name = "Bg", Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Parent = row })
                    bind(bg, "BackgroundColor3", "Elevated")
                    U.corner(bg, 11)
                    local bgStroke = U.stroke(bg, WHITE, 1, 1)
                    bind(bgStroke, "Color", "Accent")
                    tab.Bg, tab.BgStroke = bg, bgStroke
                    tab.BgGrad = new("UIGradient", { Transparency = NumberSequence.new({ kp(0, 0), kp(0.5, 0.12), kp(1, 0.92) }), Enabled = not collapsed, Parent = bg })
                    tab.StrokeGrad = new("UIGradient", { Transparency = NumberSequence.new({ kp(0, 0), kp(0.4, 0.35), kp(0.85, 1), kp(1, 1) }), Enabled = not collapsed, Parent = bgStroke })

                    local tileSize = collapsed and TILE_C or self.TileS
                    local tileX = collapsed and ((W_COL - 16 - TILE_C) / 2) or 6
                    local glow = X.image(row, "glow", { Name = "Glow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, tileX + tileSize / 2, 0.5, 0), Size = UDim2.new(0, 72, 1, 0), ImageTransparency = 1, ZIndex = 1 })
                    if glow then bind(glow, "ImageColor3", "Accent") end
                    tab.Glow = glow

                    local tile, textured = Nova.tile(row, { Name = "Tile", Size = UDim2.fromOffset(tileSize, tileSize), Pos = UDim2.new(0, tileX, 0.5, 0), Anchor = Vector2.new(0, 0.5), Color = "Elevated", Alpha = collapsed and 1 or 0.4, Z = 2 })
                    tab.Tile, tab.TileProp, tab.TileAlphaProp = tile, textured and "ImageColor3" or "BackgroundColor3", textured and "ImageTransparency" or "BackgroundTransparency"
                    tab.IconImg = icon({ Parent = tile, Icon = opts.Icon, Size = collapsed and ICON_C or 16, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 3 })

                    tab.Label = label({ Parent = row, Text = tab.Name, Font = F.Semi(), Size = 14, Pos = UDim2.fromOffset(self.LabelX, 0), Box = UDim2.new(1, -(self.LabelX + 10), 1, 0), Color = "Muted", Truncate = true, Z = 2 })
                    if collapsed then tab.Label.TextTransparency = 1 end

                    if opts.Badge then
                        local text = tostring(opts.Badge)
                        local bw = math.max(20, #text * 6.4 + 12)
                        local badge = new("Frame", { Name = "Badge", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0), Size = UDim2.fromOffset(bw, 18), BorderSizePixel = 0, ZIndex = 3, Parent = row })
                        bind(badge, "BackgroundColor3", "Accent")
                        U.corner(badge, UDim.new(1, 0))
                        tab.BadgeLabel = label({ Parent = badge, Text = text, Font = F.Bold(), Size = 10, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = "OnAccent", Z = 4 })
                        tab.Badge, tab.BadgeWidth = badge, bw
                        tab.BadgeRing = U.stroke(badge, WHITE, 2, collapsed and 0 or 1)
                        bind(tab.BadgeRing, "Color", "Sidebar")
                        if collapsed then
                            badge.Size = UDim2.fromOffset(10, 10)
                            badge.Position = UDim2.new(0, tileX + tileSize - 2, 0.5, -tileSize / 2 + 4)
                            tab.BadgeLabel.TextTransparency = 1
                        end
                    end

                    local hit = new("TextButton", { Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 8, Parent = row })
                    tab.Hit = hit
                    hit.MouseEnter:Connect(function()
                        tab.Hover = true
                        if self.DraggingTab then return end
                        if self.Current ~= tab then
                            tween(bg, "Quick", { BackgroundTransparency = 0.6 })
                            paint(tab.Label, "TextColor3", "Text", "Quick")
                            tween(tile, "Quick", { [tab.TileAlphaProp] = tileAlpha(self, true) })
                            paint(tab.IconImg, "ImageColor3", "Text", "Quick")
                        end
                        S.play("hover", 0.4)
                        if self.SidebarCollapsed then self:ShowTip(tab.Name) end
                    end)
                    U.leave(hit, function()
                        tab.Hover = false
                        self:HideTip()
                        if self.DraggingTab == tab then return end
                        if self.Current ~= tab then
                            tween(bg, "Quick", { BackgroundTransparency = 1 })
                            paint(tab.Label, "TextColor3", "Muted", "Quick")
                            tween(tile, "Quick", { [tab.TileAlphaProp] = tileAlpha(self, false) })
                            paint(tab.IconImg, "ImageColor3", "Muted", "Quick")
                        end
                    end)
                    hit.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                        self.PressTab = tab
                        self.PressTime = os.clock()
                        self.PressInput = input
                        self.PressAt = U.at(input)
                    end)
                    hit.MouseButton1Click:Connect(function()
                        if self.DraggingTab or os.clock() - (self.LastDragEnd or 0) < 0.3 then return end
                        if self.Current ~= tab then S.play("click", 0.8) end
                        self:SelectTab(tab)
                    end)

                    local saved = self.State.get("tabOrder", {})
                    local order = type(saved) == "table" and saved[g.Key] or nil
                    local myRank = rank(order, tab.Name)
                    local at = #g.Tabs + 1
                    if myRank ~= math.huge then
                        for i, other in ipairs(g.Tabs) do
                            if rank(order, other.Name) > myRank then at = i break end
                        end
                    end
                    table.insert(g.Tabs, at, tab)
                    self:_layoutTabs(false)
                end

                function Window:_styleTab(tab, active, animate)
                    if not tab.Row then return end
                    local quick = animate and "Base" or TweenInfo.new(0)
                    local prop, aprop = tab.TileProp, tab.TileAlphaProp
                    if active then
                        paint(tab.Tile, prop, "Accent", quick)
                        tween(tab.Tile, quick, { [aprop] = 0 })
                        paint(tab.IconImg, "ImageColor3", "OnAccent", quick)
                        paint(tab.Label, "TextColor3", "Text", quick)
                        local flat = self.SidebarCollapsed
                        tween(tab.Bg, quick, { BackgroundTransparency = flat and 1 or 0.42 })
                        paint(tab.BgStroke, "Color", "Accent", quick)
                        tween(tab.BgStroke, quick, { Transparency = flat and 1 or 0.72 })
                        if tab.Glow then tween(tab.Glow, quick, { ImageTransparency = 0.5 }) end
                    else
                        paint(tab.Tile, prop, "Elevated", quick)
                        tween(tab.Tile, quick, { [aprop] = tileAlpha(self, tab.Hover) })
                        paint(tab.IconImg, "ImageColor3", tab.Hover and "Text" or "Muted", quick)
                        paint(tab.Label, "TextColor3", tab.Hover and "Text" or "Muted", quick)
                        tween(tab.Bg, quick, { BackgroundTransparency = tab.Hover and 0.6 or 1 })
                        tween(tab.BgStroke, quick, { Transparency = 1 })
                        if tab.Glow then tween(tab.Glow, quick, { ImageTransparency = 1 }) end
                    end
                end

                local function moveRow(tab, y, hidden, animate, h)
                    local row = tab.Row
                    tab.TargetY = y
                    tab.RowToken = (tab.RowToken or 0) + 1
                    local token = tab.RowToken
                    local pos = UDim2.fromOffset(8, y)
                    local size = UDim2.new(1, -16, 0, h)
                    if not animate then
                        row.Position, row.Size = pos, size
                        row.GroupTransparency = hidden and 1 or 0
                        row.Visible = not hidden
                        return
                    end
                    if not hidden then row.Visible = true end
                    tween(row, ROWINFO, { Position = pos, Size = size, GroupTransparency = hidden and 1 or 0 })
                    if hidden then
                        task.delay(0.36, function()
                            if tab.RowToken == token then row.Visible = false end
                        end)
                    end
                end

                function Window:_layoutTabs(animate)
                    if not self.TabCanvas then return end
                    if not M.enabled then animate = false end
                    local collapsed = self.SidebarCollapsed
                    local rowH = collapsed and ROW_C or self.RowH
                    local labels = self.GroupLabels ~= false
                    local y = 4
                    for _, g in ipairs(self.Groups) do
                        if g.Row and not labels then
                            g.Row.Visible = false
                            g.Row.Position = UDim2.fromOffset(8, y)
                            g.Row.Size = UDim2.new(1, -16, 0, 0)
                        elseif g.Row then
                            g.Row.Visible = true
                            local capH = collapsed and (g == firstCap(self) and 6 or CAP_C) or self.CapH
                            g.Row.Position = UDim2.fromOffset(8, y)
                            if animate then
                                tween(g.Row, ROWINFO, { Position = UDim2.fromOffset(8, y), Size = UDim2.new(1, -16, 0, capH) })
                            else
                                g.Row.Size = UDim2.new(1, -16, 0, capH)
                            end
                            y += capH
                        end
                        local hidden = g.Collapsed and not collapsed and labels
                        local anchorY = y
                        for _, tab in ipairs(g.Tabs) do
                            if tab ~= self.DraggingTab then
                                moveRow(tab, hidden and anchorY or y, hidden, animate, rowH)
                            end
                            if not hidden then y += rowH + GAP end
                        end
                        if #g.Tabs > 0 and not hidden and labels then y += 4 end
                    end
                    self.TabCanvas.Size = UDim2.new(1, 0, 0, y + 6)
                end

                function Window:SetGroupLabels(v)
                    v = v ~= false
                    if v == (self.GroupLabels ~= false) then return end
                    self.GroupLabels = v
                    self.State.set("groupLabels", v)
                    if v and not self.SidebarCollapsed then
                        for _, g in ipairs(self.Groups) do
                            if g.Row then
                                g.Label.TextTransparency, g.Chev.ImageTransparency = 1, 1
                                tween(g.Label, "Base", { TextTransparency = 0 })
                                tween(g.Chev, "Base", { ImageTransparency = 0 })
                            end
                        end
                    end
                    self:_layoutTabs(true)
                    if self.OnGroupLabels then pcall(self.OnGroupLabels, v) end
                end

                function Window:_revealTab(tab)
                    local scroll, row = self.TabScroll, tab and tab.Row
                    if not scroll or not row then return end
                    local top = row.Position.Y.Offset
                    local bottom = top + row.Size.Y.Offset
                    local view = scroll.AbsoluteWindowSize.Y / math.max(self.Scale.Scale, 0.1)
                    local pos = scroll.CanvasPosition.Y
                    local target = pos
                    if top - 6 < pos then target = math.max(0, top - 6)
                    elseif bottom + 6 > pos + view then target = bottom + 6 - view end
                    if math.abs(target - pos) < 1 then return end
                    tween(scroll, "Base", { CanvasPosition = Vector2.new(0, target) })
                end

                function Window:SetSidebarCollapsed(v, instant)
                    v = v and true or false
                    if v == self.SidebarCollapsed and not instant then return end
                    self.SidebarCollapsed = v
                    self.State.set("sidebarCollapsed", v)
                    local w = v and W_COL or self.ExpandedWidth
                    self.SidebarWidth = w
                    local info = instant and TweenInfo.new(0) or TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    tween(self.Sidebar, info, { Size = UDim2.new(0, w, 1, 0) })
                    self.Main.Size = UDim2.new(1, -w, 1, 0)
                    tween(self.Main, info, { Position = UDim2.fromOffset(w, 0) })
                    tween(self.SidebarEdge, info, { Position = UDim2.new(0, w, 0, 0) })
                    self.SidebarEdge.Visible = not v
                    local quick = instant and TweenInfo.new(0) or "Base"
                    local geo = railGeo(v)
                    tween(self.LogoButton, info, { Position = UDim2.fromOffset(geo.logoX, geo.logoY) })
                    tween(self.SearchField.Parent, info, { Position = UDim2.fromOffset(0, geo.searchY) })
                    tween(self.TabClip, info, { Position = UDim2.fromOffset(0, geo.tabTop), Size = UDim2.new(1, 0, 1, -(geo.tabTop + geo.foot + 2)) })
                    tween(self.Footer, info, { Size = UDim2.new(1, 0, 0, geo.foot) })
                    tween(self.TitleLabel, quick, { TextTransparency = v and 1 or 0 })
                    tween(self.SubtitleLabel, quick, { TextTransparency = v and 1 or 0 })
                    tween(self.FooterText, quick, { TextTransparency = v and 1 or 0 })
                    tween(self.FooterChip, info, { AnchorPoint = v and Vector2.new(0.5, 0.5) or Vector2.new(1, 0.5), Position = v and UDim2.new(0.5, 0, 0.5, 1) or UDim2.new(1, -14, 0.5, 1) })
                    self.FoldButton.Visible = not v
                    self.SearchField.Parent.Visible = true
                    self.SearchField.Visible = not v
                    self.SearchTile.Visible = v
                    for _, g in ipairs(self.Groups) do
                        if g.Row then
                            tween(g.Label, quick, { TextTransparency = v and 1 or 0 })
                            tween(g.Chev, quick, { ImageTransparency = v and 1 or 0 })
                            tween(g.Line, quick, { BackgroundTransparency = v and (firstCap(self) == g and 1 or 0.88) or 1 })
                        end
                        for _, tab in ipairs(g.Tabs) do
                            local ts = v and TILE_C or self.TileS
                            local tx = v and ((W_COL - 16 - TILE_C) / 2) or 6
                            tab.BgGrad.Enabled, tab.StrokeGrad.Enabled = not v, not v
                            tween(tab.Tile, info, { Size = UDim2.fromOffset(ts, ts), Position = UDim2.new(0, tx, 0.5, 0) })
                            tween(tab.IconImg, info, { Size = UDim2.fromOffset(v and ICON_C or 16, v and ICON_C or 16) })
                            self:_styleTab(tab, self.Current == tab, not instant)
                            tween(tab.Label, quick, { TextTransparency = v and 1 or 0 })
                            if tab.Glow then tween(tab.Glow, info, { Position = UDim2.new(0, tx + ts / 2, 0.5, 0) }) end
                            if tab.Badge then
                                if v then
                                    tween(tab.Badge, info, { Size = UDim2.fromOffset(10, 10), Position = UDim2.new(0, tx + ts - 2, 0.5, -ts / 2 + 4) })
                                    tween(tab.BadgeLabel, quick, { TextTransparency = 1 })
                                    tween(tab.BadgeRing, quick, { Transparency = 0 })
                                else
                                    tween(tab.Badge, info, { Size = UDim2.fromOffset(tab.BadgeWidth, 18), Position = UDim2.new(1, -9, 0.5, 0) })
                                    tween(tab.BadgeLabel, quick, { TextTransparency = 0 })
                                    tween(tab.BadgeRing, quick, { Transparency = 1 })
                                end
                            end
                        end
                    end
                    self:_layoutTabs(not instant)
                    if self.OnSidebarChanged then pcall(self.OnSidebarChanged, v) end
                end

                function Window:SetDensity(name)
                    local valid = false
                    for _, d in ipairs(Window.Densities) do if d == name then valid = true end end
                    if not valid then return end
                    self.Density = name
                    self.State.set("density", name)
                    Window.applyDensity(self)
                    if not self.SidebarCollapsed then
                        for _, g in ipairs(self.Groups) do
                            for _, tab in ipairs(g.Tabs) do
                                local ts = self.TileS
                                tween(tab.Tile, "Base", { Size = UDim2.fromOffset(ts, ts) })
                                tween(tab.Label, "Base", { Position = UDim2.fromOffset(self.LabelX, 0), Size = UDim2.new(1, -(self.LabelX + 10), 1, 0) })
                                if tab.Glow then tween(tab.Glow, "Base", { Position = UDim2.new(0, 6 + ts / 2, 0.5, 0) }) end
                            end
                        end
                    end
                    self:_layoutTabs(true)
                end

                function Window:SetSidebarWidth(w, live)
                    Nova.trace("SetSidebarWidth")
                    local maxW = math.min(W_MAX, math.max(W_MIN, (self.Size and self.Size.X or 860) - 420))
                    w = math.clamp(tonumber(w) or W_EXP, W_MIN, maxW)
                    self.ExpandedWidth = w
                    if not live then self.State.set("sidebarWidth", math.floor(w + 0.5)) end
                    if self.OnSidebarWidth then pcall(self.OnSidebarWidth, w) end
                    if self.SidebarCollapsed then return end
                    self.SidebarWidth = w
                    local info = live and TweenInfo.new(0) or TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    tween(self.Sidebar, info, { Size = UDim2.new(0, w, 1, 0) })
                    self.Main.Size = UDim2.new(1, -w, 1, 0)
                    tween(self.Main, info, { Position = UDim2.fromOffset(w, 0) })
                    tween(self.SidebarEdge, info, { Position = UDim2.new(0, w, 0, 0) })
                end

                function Window:ToggleSidebar()
                    self:SetSidebarCollapsed(not self.SidebarCollapsed)
                end

                local function canvasY(self)
                    return (U.at(self.PressInput).Y - self.TabCanvas.AbsolutePosition.Y) / math.max(self.Scale.Scale, 0.1)
                end

                function Window:_reorderMove()
                    local tab = self.PressTab
                    if not tab and not self.DraggingTab then return end
                    if not self.DraggingTab then
                        local m = U.at(self.PressInput)
                        if self.IsTouch and os.clock() - (self.PressTime or 0) < 0.35 then
                            if (m - self.PressAt).Magnitude >= 9 then self.PressTab = nil end
                            return
                        end
                        if (m - self.PressAt).Magnitude < 9 then return end
                        self.DraggingTab = tab
                        self.DragOffset = canvasY(self) - (tab.TargetY or 0)
                        tab.Row.ZIndex = 10
                        self:HideTip()
                        tween(tab.Bg, "Quick", { BackgroundTransparency = 0.25 })
                        paint(tab.BgStroke, "Color", "Accent", "Quick")
                        tween(tab.BgStroke, "Quick", { Transparency = 0.35 })
                        if tab.Glow then tween(tab.Glow, "Quick", { ImageTransparency = 0.5 }) end
                        S.play("tick")
                    end
                    local dragging = self.DraggingTab
                    if not dragging then return end
                    self:_tabPopFeedback(dragging)
                    local g = dragging.Group
                    local rowH = self.SidebarCollapsed and ROW_C or self.RowH
                    local top = (g.Tabs[1] and g.Tabs[1].TargetY) or 0
                    local minY = top
                    local maxY = top + math.max(0, (#g.Tabs - 1)) * (rowH + GAP)
                    local y = math.clamp(canvasY(self) - self.DragOffset, minY - 8, maxY + 8)
                    dragging.Row.Position = UDim2.fromOffset(8, y)
                    local center = y + rowH / 2
                    local target = 1
                    local slot = top
                    for i = 1, #g.Tabs do
                        if g.Tabs[i] ~= dragging then
                            if center > slot + rowH / 2 then target += 1 end
                            slot += rowH + GAP
                        end
                    end
                    target = math.clamp(target, 1, #g.Tabs)
                    local current
                    for i, t in ipairs(g.Tabs) do if t == dragging then current = i end end
                    if current and current ~= target then
                        table.remove(g.Tabs, current)
                        table.insert(g.Tabs, target, dragging)
                        self:_layoutTabs(true)
                        S.play("tick", 0.6)
                    end
                end

                function Window:_tabPopFeedback(tab)
                    local m = U.at(self.PressInput)
                    local edge = self.Sidebar.AbsolutePosition.X + self.Sidebar.AbsoluteSize.X
                    local intent = m.X > edge + 46 * math.max(self.Scale.Scale, 0.1) and #tab.Sections > 0
                    if not self.TabGhost then
                        local ghost = new("CanvasGroup", { Name = "TabGhost", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(160, 44), BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 400, Parent = self.FloatLayer })
                        bind(ghost, "BackgroundColor3", "Elevated")
                        U.corner(ghost, 14)
                        local rim = X.image(ghost, "rim9", { Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.3, ZIndex = 402 })
                        if rim then bind(rim, "ImageColor3", "Accent") else bind(U.stroke(ghost, WHITE, 1, 0.4), "Color", "Accent") end
                        local sh = X.image(self.FloatLayer, "shadow9", { Name = "TabGhostShadow", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(220, 100), SliceScale = 1, ImageTransparency = 1, Visible = false, ZIndex = 399 })
                        Nova.tile(ghost, { Name = "Tile", Size = UDim2.fromOffset(28, 28), Pos = UDim2.fromOffset(8, 8), Color = "Accent", Z = 401 })
                        local gi = icon({ Parent = ghost, Icon = "layout-panel-top", Size = 15, Pos = UDim2.fromOffset(22, 22), Anchor = Vector2.new(0.5, 0.5), Color = "OnAccent", Z = 403 })
                        local gl = label({ Parent = ghost, Text = "", Font = F.Semi(), Size = 13, Pos = UDim2.fromOffset(44, 0), Box = UDim2.new(1, -52, 1, 0), Truncate = true, Z = 403 })
                        self.TabGhost = { Frame = ghost, Shadow = sh, Icon = gi, Label = gl }
                    end
                    local g = self.TabGhost
                    local scale = math.max(self.FloatScale.Scale, 0.1)
                    local pos = (m - self.FloatLayer.AbsolutePosition) / scale
                    g.Frame.Position = UDim2.fromOffset(pos.X + 96, pos.Y)
                    if g.Shadow then g.Shadow.Position = UDim2.fromOffset(pos.X + 96, pos.Y + 6) end
                    if intent ~= self.TabPopIntent then
                        self.TabPopIntent = intent
                        g.Label.Text = tab.Label and tab.Label.Text or tab.Name
                        if tab.IconImg and tab.IconImg.Image ~= "" then
                            g.Icon.Image, g.Icon.ImageRectOffset, g.Icon.ImageRectSize = tab.IconImg.Image, tab.IconImg.ImageRectOffset, tab.IconImg.ImageRectSize
                            g.Icon.Visible = true
                        end
                        if intent then
                            g.Frame.Visible = true
                            if g.Shadow then g.Shadow.Visible = true end
                            S.play("click", 0.7)
                        end
                        tween(g.Frame, "Base", { GroupTransparency = intent and 0 or 1 })
                        if g.Shadow then tween(g.Shadow, "Base", { ImageTransparency = intent and 0.45 or 1 }) end
                        tween(tab.Row, "Quick", { GroupTransparency = intent and 0.45 or 0 })
                        if not intent then
                            task.delay(0.2, function()
                                if not self.TabPopIntent then
                                    g.Frame.Visible = false
                                    if g.Shadow then g.Shadow.Visible = false end
                                end
                            end)
                        end
                    end
                end

                function Window:_reorderEnd()
                    local tab = self.DraggingTab
                    self.PressTab = nil
                    if not tab then return end
                    self.DraggingTab = nil
                    self.LastDragEnd = os.clock()
                    if self.TabPopIntent then
                        self.TabPopIntent = false
                        local g = self.TabGhost
                        if g then
                            tween(g.Frame, "Quick", { GroupTransparency = 1 })
                            if g.Shadow then tween(g.Shadow, "Quick", { ImageTransparency = 1 }) end
                            task.delay(0.2, function()
                                g.Frame.Visible = false
                                if g.Shadow then g.Shadow.Visible = false end
                            end)
                        end
                        tween(tab.Row, "Quick", { GroupTransparency = 0 })
                        local scale = math.max(self.FloatScale.Scale, 0.1)
                        local pos = (U.at(self.PressInput) - self.FloatLayer.AbsolutePosition) / scale
                        self:FloatTab(tab, pos - Vector2.new(80, 20))
                    end
                    tab.Row.ZIndex = 1
                    self:_styleTab(tab, self.Current == tab, true)
                    self:_layoutTabs(true)
                    local order = {}
                    for _, g in ipairs(self.Groups) do
                        local names = {}
                        for _, t in ipairs(g.Tabs) do table.insert(names, t.Name) end
                        order[g.Key] = names
                    end
                    self.State.data.tabOrder = order
                    self.State.save()
                    if self.OnTabOrder then pcall(self.OnTabOrder, order) end
                end
            end

            do
                local U, M, T, F, I, S, X = Nova.U, Nova.Motion, Nova.Theme, Nova.Font, Nova.Icons, Nova.Sound, Nova.Tex
                local new, tween, bind = U.new, M.tween, T.bind
                local label, icon, paint = Nova.label, Nova.icon, Nova.paint
                local Window = Nova.WindowClass
                local UIS = Nova.Services.UserInputService
                local WHITE = Color3.new(1, 1, 1)
                local HEAD_H = 44

                local Tab = {}
                Tab.__index = Tab
                Nova.TabClass = Tab

                local Section = {}
                Section.__index = Section
                Nova.SectionClass = Section

                local BODYINFO = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                function Window:Tab(opts)
                    if type(opts) == "string" then opts = { Name = opts } end
                    opts = opts or {}
                    local tab = setmetatable({}, Tab)
                    tab.Window = self
                    tab.Name = opts.Name or ("Tab " .. (#self.TabList + 1))
                    tab.Title = opts.Title or tab.Name
                    tab.Desc = opts.Desc or ""
                    tab.Icon = opts.Icon
                    tab.Rows, tab.Sections, tab.Pages, tab.Loads = {}, {}, {}, {}
                    tab.Columns = opts.Columns or 2
                    self.Tabs[tab.Name] = tab
                    table.insert(self.TabList, tab)
                    self:_addTabRow(tab, opts)

                    local frame = new("CanvasGroup", { Name = tab.Name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = self.Parking or self.Body })
                    tab.Frame = frame
                    tab.RefreshGen = Nova.Refresh.gen
                    tab.PageHost = new("Frame", { Name = "Pages", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = frame })
                    return tab
                end

                function Tab:_setActive(on)
                    self.Window:_styleTab(self, on, true)
                end

                function Window:SelectTab(tab)
                    Nova.trace("SelectTab")
                    if type(tab) == "string" then tab = self.Tabs[tab] end
                    if not tab or tab == self.Current then return end
                    local prev = self.Current
                    self.Current = tab
                    self:ClosePopups()
                    if tab.Group and tab.Group.Collapsed and not self.SidebarCollapsed then
                        self:SetGroupCollapsed(tab.Group, false)
                    end
                    if prev then
                        self:_styleTab(prev, false, true)
                        local old = prev.Frame
                        tween(old, "Quick", { GroupTransparency = 1, Position = UDim2.fromOffset(-14, 0) })
                        task.delay(0.16, function()
                            if self.Current ~= prev then
                                old.Visible = false
                                if self.Parking then
                                    old.Parent = self.Parking
                                    prev.RefreshGen = Nova.Refresh.gen
                                end
                            end
                        end)
                    end
                    self:_styleTab(tab, true, true)
                    self:_revealTab(tab)
                    local fr = tab.Frame
                    if fr.Parent ~= self.Body then
                        fr.Parent = self.Body
                        if tab.RefreshGen ~= Nova.Refresh.gen then
                            Nova.Refresh.sync(fr)
                            tab.RefreshGen = Nova.Refresh.gen
                        end
                    end
                    fr.Visible = true
                    fr.GroupTransparency = 1
                    fr.Position = UDim2.fromOffset(18, 0)
                    tween(fr, "Base", { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
                    task.delay(0.2, function() if self.Current == tab then tab:_balanceActive() end end)
                    self.HeaderTitle.Text = tab.Title
                    self.HeaderDesc.Text = tab.Desc or ""
                    if self.OnTabChanged then pcall(self.OnTabChanged, tab) end
                end

                local SR_ROW, SR_VIS, SR_MAX, SR_W, SR_SEP = 46, 7, 40, 360, "  ›  "
                local SR_KIND = { tab = 30, sub = 22, section = 10, row = 0 }

                local function srLower(s)
                    s = string.lower(tostring(s or ""))
                    s = string.gsub(s, "<[^>]->", "")
                    s = string.gsub(s, "\208([\144-\159])", function(c) return "\208" .. string.char(string.byte(c) + 32) end)
                    s = string.gsub(s, "\208([\160-\175])", function(c) return "\209" .. string.char(string.byte(c) - 32) end)
                    s = string.gsub(s, "\208([\129\132\134\135])", function(c) return "\209" .. string.char(string.byte(c) + 16) end)
                    return s
                end

                local function srPlain(s)
                    return (string.gsub(tostring(s or ""), "<[^>]->", ""))
                end

                local function srEscape(s)
                    s = string.gsub(s, "&", "&amp;")
                    s = string.gsub(s, "<", "&lt;")
                    s = string.gsub(s, ">", "&gt;")
                    return s
                end

                local function srMark(title, q, hex)
                    local a, b = string.find(srLower(title), q, 1, true)
                    if not a then return srEscape(title) end
                    return srEscape(string.sub(title, 1, a - 1)) .. '<font color="#' .. hex .. '">' .. srEscape(string.sub(title, a, b)) .. "</font>" .. srEscape(string.sub(title, b + 1))
                end

                function Window:_searchSubLabel(tab, page)
                    local key = page and page.Key
                    if not key or key == "_" or not tab.SubButtons then return nil end
                    local e = tab.SubButtons[key]
                    return srPlain(e and e.Label and e.Label.Text or key)
                end

                function Window:_searchCollect()
                    local items = {}
                    for _, tab in ipairs(self.TabList) do
                        local tabText = srPlain(tab.Label and tab.Label.Text or tab.Name)
                        local tabHay = srLower(tabText .. " " .. tostring(tab.Name))
                        table.insert(items, { kind = "tab", tab = tab, title = tabText, path = Nova.tr("Tab"), hay = tabHay, titleL = srLower(tabText) })
                        if tab.SubDefs and tab.SubButtons then
                            for _, d in ipairs(tab.SubDefs) do
                                local e = tab.SubButtons[d.key]
                                local subText = srPlain(e and e.Label and e.Label.Text or d.label or d.key)
                                table.insert(items, { kind = "sub", tab = tab, sub = d.key, title = subText, path = tabText, hay = srLower(subText .. " " .. tostring(d.key)) .. " " .. tabHay, titleL = srLower(subText) })
                            end
                        end
                        for _, sec in ipairs(tab.Sections) do
                            if not sec.Hidden and sec.TitleLabel and not sec.ParentSection then
                                local subText = self:_searchSubLabel(tab, sec.Page)
                                local secText = srPlain(sec.TitleLabel.Text)
                                local where = subText and (tabText .. SR_SEP .. subText) or tabText
                                table.insert(items, { kind = "section", tab = tab, sec = sec, title = secText, path = where, hay = srLower(secText .. " " .. tostring(sec.Key) .. " " .. where), titleL = srLower(secText) })
                            end
                        end
                        for _, entry in ipairs(tab.Rows) do
                            local row = entry.row
                            if row and row.Title and not row.selfHidden and not row.parentHidden and row.Frame and row.Frame.Parent then
                                local sec, chain, ok = entry.sec, {}, true
                                while sec and sec.ParentSection do
                                    if sec.OwnerRow and (sec.OwnerRow.selfHidden or sec.OwnerRow.parentHidden) then ok = false end
                                    table.insert(chain, sec)
                                    sec = sec.ParentSection
                                end
                                local title = srPlain(row.Title.Text)
                                if ok and sec and not sec.Hidden and title ~= "" then
                                    local parts = { tabText }
                                    local subText = self:_searchSubLabel(tab, sec.Page)
                                    if subText then table.insert(parts, subText) end
                                    if sec.TitleLabel then table.insert(parts, srPlain(sec.TitleLabel.Text)) end
                                    for i = #chain, 1, -1 do
                                        local owner = chain[i].OwnerRow
                                        if owner and owner.Title then table.insert(parts, srPlain(owner.Title.Text)) end
                                    end
                                    local path = table.concat(parts, SR_SEP)
                                    local extra = (row.Desc and row.Desc.Text or "") .. " " .. tostring(row.Opts and row.Opts.Text or "")
                                    if row.SearchOptions then
                                        local okOpt, opt = pcall(row.SearchOptions)
                                        if okOpt and type(opt) == "string" then extra = extra .. " " .. opt end
                                    end
                                    table.insert(items, { kind = "row", tab = tab, sec = sec, row = row, chain = chain, title = title, path = path, hay = srLower(title .. " " .. extra .. " " .. path), titleL = srLower(title) })
                                end
                            end
                        end
                    end
                    return items
                end

                function Window:_searchRank(query)
                    local q = srLower(query)
                    q = string.gsub(q, "^%s+", "")
                    q = string.gsub(q, "%s+$", "")
                    if q == "" then return {}, q end
                    local tokens = {}
                    for w in string.gmatch(q, "%S+") do table.insert(tokens, w) end
                    local out, seen = {}, {}
                    for _, it in ipairs(self:_searchCollect()) do
                        local score = 0
                        local at = string.find(it.titleL, q, 1, true)
                        if at == 1 then score = 120 elseif at then score = 70 end
                        local ok, inTitle = true, at ~= nil
                        for _, tok in ipairs(tokens) do
                            if string.find(it.titleL, tok, 1, true) then
                                score += 18
                                inTitle = true
                            elseif string.find(it.hay, tok, 1, true) then
                                score += 4
                            else
                                ok = false
                                break
                            end
                        end
                        if ok and (inTitle or it.kind ~= "row") then
                            local key = it.kind .. "|" .. it.title .. "|" .. it.path
                            if not seen[key] then
                                seen[key] = true
                                it.score = score + SR_KIND[it.kind] - #it.titleL / 40
                                table.insert(out, it)
                            end
                        end
                    end
                    table.sort(out, function(a, b) return a.score > b.score end)
                    while #out > SR_MAX do table.remove(out) end
                    return out, q
                end

                function Window:_searchClose()
                    local pop = self.SearchPop
                    if not pop then return end
                    self.SearchPop = nil
                    self:PopupConceal(pop.Frame, pop.Shell)
                    task.delay(0.18, function() pcall(function() pop.Frame:Destroy() end) end)
                end

                function Window:_searchOpen(h)
                    if self.SearchPop then return self.SearchPop end
                    local frame, shell, sc = self:PopupShell(SR_W, h)
                    frame.Name = "SearchResults"
                    local list = new("ScrollingFrame", { Name = "List", Position = UDim2.fromOffset(0, 5), Size = UDim2.new(1, 0, 1, -10), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 61, Parent = shell })
                    bind(list, "ScrollBarImageColor3", "Faint")
                    U.list(list, 2)
                    U.pad(list, 0, 5, 0, 5)
                    local empty = label({ Parent = shell, Text = Nova.tr("Nothing found"), Font = F.Medium(), Size = 13, Color = "Muted", AlignX = Enum.TextXAlignment.Center, Box = UDim2.fromScale(1, 1), Z = 62 })
                    empty.Visible = false
                    local pop = { Frame = frame, Shell = shell, List = list, Empty = empty, Rows = {}, Items = {}, Sel = 1, H = h }
                    self.SearchPop = pop
                    local px, py, _, oy = self:PopupPlace(self.SearchField, SR_W, h, "left")
                    frame.Position = UDim2.fromOffset(px, py)
                    self:PopupReveal(frame, shell, sc, oy == 1)
                    table.insert(self.Popups, { close = function() if self.SearchPop == pop then self:_searchClose() end end })
                    return pop
                end

                function Window:_searchSelect(i)
                    local pop = self.SearchPop
                    if not pop or #pop.Rows == 0 then return end
                    i = math.clamp(i, 1, #pop.Rows)
                    pop.Sel = i
                    for k, b in ipairs(pop.Rows) do
                        tween(b, "Quick", { BackgroundTransparency = k == i and 0.84 or 1 })
                    end
                    local list = pop.List
                    local scale = math.max(self.PopScale.Scale, 0.1)
                    local top = (i - 1) * (SR_ROW + 2)
                    local view = list.AbsoluteWindowSize.Y / scale
                    local pos = list.CanvasPosition.Y
                    if top < pos then
                        list.CanvasPosition = Vector2.new(0, top)
                    elseif view > 1 and top + SR_ROW > pos + view then
                        list.CanvasPosition = Vector2.new(0, top + SR_ROW - view)
                    end
                end

                function Window:_searchRender(results, q)
                    local pop = self.SearchPop
                    if not pop then return end
                    for _, b in ipairs(pop.Rows) do b:Destroy() end
                    pop.Rows, pop.Items = {}, results
                    pop.Empty.Visible = #results == 0
                    local hex = T.resolve("Accent"):ToHex()
                    for i, it in ipairs(results) do
                        local b = new("TextButton", { Name = "Result", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, SR_ROW), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 62, Parent = pop.List })
                        bind(b, "BackgroundColor3", "Accent")
                        U.corner(b, 9)
                        local tile = new("Frame", { Name = "Tile", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(30, 30), BorderSizePixel = 0, BackgroundTransparency = 0.82, ZIndex = 63, Parent = b })
                        bind(tile, "BackgroundColor3", "Accent")
                        U.corner(tile, 9)
                        icon({ Parent = tile, Icon = it.tab.Icon or "search", Size = 15, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Accent", Z = 64 })
                        label({ Parent = b, Text = srMark(it.title, q, hex), Rich = true, Font = F.Semi(), Size = 13, Pos = UDim2.fromOffset(48, 6), Box = UDim2.new(1, -58, 0, 18), Truncate = true, Z = 63 })
                        label({ Parent = b, Text = srEscape(it.path), Rich = true, Font = F.Medium(), Size = 11, Color = "Muted", Pos = UDim2.fromOffset(48, 24), Box = UDim2.new(1, -58, 0, 15), Truncate = true, Z = 63 })
                        b.MouseEnter:Connect(function()
                            if pop.Sel ~= i then self:_searchSelect(i) end
                        end)
                        b.MouseButton1Click:Connect(function()
                            self:_searchJump(it)
                        end)
                        table.insert(pop.Rows, b)
                    end
                    local h = #results == 0 and 56 or (math.min(#results, SR_VIS) * (SR_ROW + 2) + 8)
                    if pop.H ~= h then
                        pop.H = h
                        tween(pop.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(SR_W, h) })
                    end
                    pop.List.CanvasPosition = Vector2.zero
                    pop.Sel = 1
                    self:_searchSelect(1)
                end

                function Window:_searchFlash(target)
                    if not target or not target.Parent then return end
                    local glow = new("Frame", { Name = "SearchFlash", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 0, Parent = target })
                    bind(glow, "BackgroundColor3", "Accent")
                    U.corner(glow, 10)
                    local st = U.stroke(glow, WHITE, 1.5, 1)
                    bind(st, "Color", "Accent")
                    local up = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local down = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    task.spawn(function()
                        for _ = 1, 2 do
                            tween(glow, up, { BackgroundTransparency = 0.8 })
                            tween(st, up, { Transparency = 0.25 })
                            task.wait(0.24)
                            tween(glow, down, { BackgroundTransparency = 1 })
                            tween(st, down, { Transparency = 1 })
                            task.wait(0.56)
                        end
                        glow:Destroy()
                    end)
                end

                function Window:_searchScroll(sec, target)
                    if not sec or sec.Floating then return end
                    local scroll = sec.Page and sec.Page.Scroll
                    if not scroll or not target or not target.Parent then return end
                    local scale = math.max(self.Scale.Scale, 0.1)
                    local rel = (target.AbsolutePosition.Y - scroll.AbsolutePosition.Y) / scale + scroll.CanvasPosition.Y
                    local view = scroll.AbsoluteWindowSize.Y / scale
                    local maxY = math.max(0, scroll.AbsoluteCanvasSize.Y / scale - view)
                    local want = math.clamp(rel - view * 0.3, 0, maxY)
                    tween(scroll, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { CanvasPosition = Vector2.new(0, want) })
                end

                function Window:_searchJump(item)
                    if not item or not item.tab then return end
                    local tab = item.tab
                    self:_searchClose()
                    self.SearchBox.Text = ""
                    pcall(function() self.SearchBox:ReleaseFocus() end)
                    S.play("click")
                    if self.Current ~= tab then self:SelectTab(tab) end
                    if item.kind == "tab" then return end
                    local sec = item.sec
                    local subKey = item.sub or (sec and sec.Page and sec.Page.Key)
                    if subKey and tab.SubButtons and tab.SubButtons[subKey] and tab.ActiveSub ~= subKey then tab:SelectSub(subKey) end
                    if item.kind == "sub" then return end
                    if sec and sec.Collapsed then sec:SetCollapsed(false) end
                    local chain = item.chain or {}
                    for i = #chain, 1, -1 do
                        local owner = chain[i].OwnerToggle
                        if owner and owner.SetDrawer and owner.IsDrawerOpen and not owner:IsDrawerOpen() then owner:SetDrawer(true) end
                    end
                    local target = item.kind == "row" and item.row.Frame or (sec and sec.Wrap)
                    local flash = item.kind == "row" and item.row.Frame or (sec and sec.Card)
                    task.delay(0.4, function()
                        if self.Destroyed or not target or not target.Parent then return end
                        self:_searchScroll(sec, target)
                        task.delay(0.35, function() self:_searchFlash(flash) end)
                    end)
                end

                function Window:Search(query)
                    Nova.trace("Search")
                    if self.Query ~= "" then
                        for _, tab in ipairs(self.TabList) do
                            for _, entry in ipairs(tab.Rows) do
                                if entry.searchHidden then
                                    entry.searchHidden = false
                                    entry.refresh()
                                end
                            end
                            for _, sec in ipairs(tab.Sections) do sec:_refreshVisibility() end
                            if tab.Label and not self.SidebarCollapsed then tween(tab.Label, "Quick", { TextTransparency = 0 }) end
                            if tab.IconImg then tween(tab.IconImg, "Quick", { ImageTransparency = 0 }) end
                        end
                    end
                    self.Query = ""
                    local text = tostring(query or "")
                    if not string.find(text, "%S") then
                        self:_searchClose()
                        return
                    end
                    local results, q = self:_searchRank(text)
                    local h = #results == 0 and 56 or (math.min(#results, SR_VIS) * (SR_ROW + 2) + 8)
                    self:_searchOpen(h)
                    self:_searchRender(results, q)
                end

                function Tab:_page(key)
                    key = key or "_"
                    local page = self.Pages[key]
                    if page then return page end
                    local one = self.Columns == 1 or (self.PageColumns ~= nil and self.PageColumns[key] == 1)
                    local top = self.SubBar and 48 or 0
                    local root = new("CanvasGroup", { Name = "Clip_" .. tostring(key), Position = UDim2.fromOffset(0, top), Size = UDim2.new(1, 0, 1, -top), BackgroundTransparency = 1, Visible = key == "_" or key == self.ActiveSub, Parent = self.PageHost })
                    local scroll = new("ScrollingFrame", {
                        Name = "Page_" .. tostring(key),
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ScrollBarThickness = 3,
                        ScrollBarImageTransparency = 0.4,
                        CanvasSize = UDim2.new(),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        Parent = root,
                    })
                    local fade = new("UIGradient", { Rotation = 90, Parent = root })
                    local function updateFade()
                        if self.Window.Scaling then self.Window:_scalingDefer(updateFade) return end
                        local h = root.AbsoluteSize.Y
                        if h < 60 then return end
                        local topK = math.clamp(scroll.CanvasPosition.Y / 12, 0, 1)
                        local botK = math.clamp((scroll.AbsoluteCanvasSize.Y - scroll.CanvasPosition.Y - scroll.AbsoluteWindowSize.Y) / 12, 0, 1)
                        local f = math.min(22 / h, 0.3)
                        fade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, topK * 0.9), NumberSequenceKeypoint.new(f, 0), NumberSequenceKeypoint.new(1 - f, 0), NumberSequenceKeypoint.new(1, botK * 0.9) })
                    end
                    scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateFade)
                    scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateFade)
                    scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateFade)
                    task.defer(updateFade)
                    bind(scroll, "ScrollBarImageColor3", "Faint")
                    U.pad(scroll, 6, 0, 22, 0)
                    local cols = new("Frame", { Name = "Columns", Position = UDim2.fromOffset(22, 0), Size = UDim2.new(1, -44, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = scroll })
                    local left = new("Frame", { Name = "Left", Size = UDim2.new(one and 1 or 0.5, one and 0 or -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = cols })
                    U.list(left, 16)
                    local right = new("Frame", { Name = "Right", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.5, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = not one, Parent = cols })
                    U.list(right, 16)
                    page = { Root = root, Scroll = scroll, Left = left, Right = right, Load = { 0, 0 }, Key = key, Cols = cols, One = one }
                    local stack = new("UIListLayout", { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder })
                    local narrow = false
                    local function relayout()
                        if self.Window.Scaling then self.Window:_scalingDefer(relayout) return end
                        local scale = math.max(self.Window.Scale.Scale, 0.1)
                        local w = scroll.AbsoluteSize.X / scale
                        local want = not one and w < 440
                        if want == narrow then return end
                        narrow = want
                        if want then
                            left.Size = UDim2.new(1, 0, 0, 0)
                            right.AnchorPoint, right.Position, right.Size = Vector2.zero, UDim2.new(), UDim2.new(1, 0, 0, 0)
                            left.LayoutOrder, right.LayoutOrder = 1, 2
                            stack.Parent = cols
                        else
                            stack.Parent = nil
                            left.Size = UDim2.new(0.5, -8, 0, 0)
                            right.AnchorPoint, right.Position, right.Size = Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.new(0.5, -8, 0, 0)
                        end
                    end
                    scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
                    task.defer(relayout)
                    self.Pages[key] = page
                    return page
                end

                function Tab:SubTabs(defs)
                    if self.SubBar then return end
                    local list = {}
                    for _, d in ipairs(defs or {}) do
                        if type(d) == "string" then d = { key = d, label = d } end
                        if type(d) == "table" and d.key then table.insert(list, d) end
                    end
                    if #list == 0 then return end
                    self.SubDefs = list
                    for _, d in ipairs(list) do
                        if d.Columns then
                            self.PageColumns = self.PageColumns or {}
                            self.PageColumns[d.key] = d.Columns
                        end
                    end
                    local bar = new("Frame", { Name = "SubBar", Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Parent = self.Frame })
                    self.SubBar = bar
                    local shell = new("Frame", { Name = "Shell", Position = UDim2.fromOffset(22, 6), Size = UDim2.fromOffset(0, 36), AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, Parent = bar })
                    bind(shell, "BackgroundColor3", "Surface")
                    U.corner(shell, 11)
                    bind(U.stroke(shell, WHITE, 1, 0.9), "Color", "Glass")
                    local pill = new("Frame", { Name = "Pill", Size = UDim2.fromOffset(60, 30), Position = UDim2.fromOffset(3, 3), BorderSizePixel = 0, ZIndex = 2, Parent = shell })
                    bind(pill, "BackgroundColor3", "Elevated")
                    U.corner(pill, 9)
                    bind(U.stroke(pill, WHITE, 1, 0.88), "Color", "Glass")
                    self.SubPill = pill
                    local row = new("Frame", { Name = "Row", Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 3, Parent = shell })
                    U.list(row, 2, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
                    U.pad(row, 3, 3, 3, 3)
                    self.SubButtons = {}
                    for i, d in ipairs(list) do
                        local b = new("TextButton", { Name = d.key, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = i, ZIndex = 4, Parent = row })
                        local bpad = U.pad(b, 0, 15, 0, 15)
                        local l = label({ Parent = b, Text = d.label or d.key, Font = F.Semi(), Size = 13, Box = UDim2.new(0, 0, 1, 0), Auto = Enum.AutomaticSize.X, Color = "Muted", Z = 4 })
                        local lreg = U.textReg[l]
                        self.SubButtons[d.key] = { Button = b, Label = l, Def = d, Pad = bpad, Base = lreg and lreg.size or 13 }
                        b.MouseEnter:Connect(function()
                            if self.ActiveSub ~= d.key then paint(l, "TextColor3", "Text", "Quick") end
                            S.play("hover", 0.4)
                        end)
                        U.leave(b, function()
                            if self.ActiveSub ~= d.key then paint(l, "TextColor3", "Muted", "Quick") end
                        end)
                        b.MouseButton1Click:Connect(function()
                            if self.ActiveSub ~= d.key then S.play("tick") end
                            self:SelectSub(d.key)
                        end)
                    end
                    for _, page in pairs(self.Pages) do
                        page.Root.Position = UDim2.fromOffset(0, 48)
                        page.Root.Size = UDim2.new(1, 0, 1, -48)
                    end
                    self.ActiveSub = list[1].key
                    local function replacePill() self:_placePill(true) end
                    shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                        self:_queueFitSubs()
                        if self.Window.Scaling then self.Window:_scalingDefer(replacePill) return end
                        replacePill()
                    end)
                    bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:_queueFitSubs() end)
                    task.defer(function() self:_placePill(true) end)
                    self:_queueFitSubs()
                end

                function Tab:_queueFitSubs()
                    if self.FitQueued then return end
                    self.FitQueued = true
                    task.delay(0.06, function()
                        self.FitQueued = false
                        local win = self.Window
                        if not win or win.Destroyed then return end
                        if win.Scaling then win:_scalingDefer(function() self:_queueFitSubs() end) return end
                        pcall(self._fitSubs, self)
                    end)
                end

                function Tab:_fitSubs()
                    local bar, pill = self.SubBar, self.SubPill
                    local shell = pill and pill.Parent
                    if not (bar and shell and self.SubButtons) then return end
                    local k = shell.AbsoluteSize.Y / 36
                    if k <= 0.01 then return end
                    local avail = bar.AbsoluteSize.X / k
                    if avail < 60 then return end
                    if not self.SubFitAvail or math.abs(self.SubFitAvail - avail) > 2 then self.SubFitAdj = 1 end
                    self.SubFitAvail = avail
                    local adj = self.SubFitAdj or 1
                    local n, sumT = 0, 0
                    for _, e in pairs(self.SubButtons) do
                        local ts = e.Label.TextSize
                        if ts <= 0 then return end
                        n += 1
                        sumT += (e.Label.AbsoluteSize.X / k) * (e.Base * U.textScale) / ts
                    end
                    if n == 0 or sumT <= 0 then return end
                    sumT = sumT / adj
                    local fixed = (n - 1) * 2 + 6
                    local margin, pad, f = 22, 15, 1
                    if sumT + n * 30 + fixed + 44 > avail then
                        margin = 10
                        pad = math.floor((avail - margin * 2 - fixed - sumT) / (2 * n))
                        if pad >= 6 then
                            pad = math.min(pad, 15)
                        else
                            pad = 6
                            f = (avail - margin * 2 - fixed - n * 12) / sumT
                            if f < 0.75 then
                                pad, margin = 3, 4
                                f = (avail - margin * 2 - fixed - n * 6) / sumT
                            end
                            f = math.clamp(f, 0.6, 1)
                        end
                    end
                    local changed = false
                    if shell.Position.X.Offset ~= margin then
                        shell.Position = UDim2.fromOffset(margin, 6)
                        changed = true
                    end
                    for _, e in pairs(self.SubButtons) do
                        if e.Pad and e.Pad.PaddingLeft.Offset ~= pad then
                            e.Pad.PaddingLeft, e.Pad.PaddingRight = UDim.new(0, pad), UDim.new(0, pad)
                            changed = true
                        end
                        local sz = math.max(8, math.floor(e.Base * f + 0.5))
                        local reg = U.textReg[e.Label]
                        if reg and reg.size ~= sz then
                            reg.size = sz
                            F.sizeOne(e.Label)
                            changed = true
                        end
                    end
                    self.SubFit = { margin = margin, pad = pad, f = f }
                    if changed then task.defer(function() self:_placePill(true) end) end
                    task.delay(0.08, function()
                        if not (shell.Parent and bar.Parent) then return end
                        local kk = shell.AbsoluteSize.Y / 36
                        if kk <= 0.01 then return end
                        local right = (shell.AbsolutePosition.X + shell.AbsoluteSize.X - bar.AbsolutePosition.X) / kk
                        if right > bar.AbsoluteSize.X / kk - 2 and (self.SubFitAdj or 1) > 0.8 then
                            self.SubFitAdj = (self.SubFitAdj or 1) - 0.04
                            pcall(self._fitSubs, self)
                        end
                    end)
                end

                function Tab:_placePill(instant)
                    local entry = self.SubButtons and self.SubButtons[self.ActiveSub]
                    if not entry or not self.SubPill or not self.SubPill.Parent then return end
                    local shell = self.SubPill.Parent
                    local k = shell.AbsoluteSize.Y / 36
                    if k <= 0.01 then return end
                    local x = (entry.Button.AbsolutePosition.X - shell.AbsolutePosition.X) / k
                    local w = entry.Button.AbsoluteSize.X / k
                    if w <= 1 then return end
                    local target = { Position = UDim2.fromOffset(x, 3), Size = UDim2.fromOffset(w, 30) }
                    if instant then
                        self.SubPill.Position, self.SubPill.Size = target.Position, target.Size
                    else
                        tween(self.SubPill, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), target)
                    end
                    for key, e in pairs(self.SubButtons) do
                        paint(e.Label, "TextColor3", key == self.ActiveSub and "Text" or "Muted", instant and TweenInfo.new(0) or "Quick")
                    end
                end

                function Tab:SelectSub(key)
                    if not self.SubButtons or not self.SubButtons[key] or key == self.ActiveSub then return end
                    local prev = self.ActiveSub
                    self.ActiveSub = key
                    self.Window:ClosePopups()
                    self:_placePill(false)
                    local old = self.Pages[prev]
                    local cur = self:_page(key)
                    if old then old.Root.Visible = false end
                    cur.Root.Visible = true
                    cur.Root.Position = UDim2.fromOffset(18, 48)
                    tween(cur.Root, "Base", { Position = UDim2.fromOffset(0, 48) })
                    task.delay(0.2, function() if self.ActiveSub == key then self:_balanceActive() end end)
                    if self.OnSubChanged then pcall(self.OnSubChanged, key) end
                end

                function Tab:_balance(page, attempt)
                    if not page or page.One or self.Columns == 1 then return end
                    local win = self.Window
                    if win.Destroyed or not page.Root.Visible then return end
                    if win.Scaling then
                        if (attempt or 0) < 12 then task.delay(0.25, function() self:_balance(page, (attempt or 0) + 1) end) end
                        return
                    end
                    local scale = math.max(win.Scale.Scale, 0.1)
                    local list, free = {}, 0
                    for k, sec in ipairs(self.Sections) do
                        if sec.Page == page and not sec.ParentSection and sec.Wrap and sec.Wrap.Parent then
                            table.insert(list, { sec = sec, k = k })
                            if not sec.Pinned and not sec.Floating then free += 1 end
                        end
                    end
                    if free == 0 then return end
                    local sizes = {}
                    for _, e in ipairs(list) do
                        local sec = e.sec
                        local h = 0
                        if sec.Floating then
                            h = sec.Slot and sec.Slot.Visible and sec.Slot.AbsoluteSize.Y / scale or 0
                        elseif not sec.Hidden and sec.Wrap.Visible then
                            h = sec.Wrap.AbsoluteSize.Y / scale
                            if h < 2 then
                                if (attempt or 0) < 12 then task.delay(0.25, function() self:_balance(page, (attempt or 0) + 1) end) end
                                return
                            end
                        end
                        sizes[sec] = h
                    end
                    local h = { 0, 0 }
                    for _, e in ipairs(list) do
                        local sec = e.sec
                        local side
                        if sec.Pinned or sec.Floating then
                            side = sec.Side or 1
                        else
                            side = h[1] <= h[2] + 1 and 1 or 2
                            local col = side == 1 and page.Left or page.Right
                            if sec.Wrap.Parent ~= col then sec.Wrap.Parent = col end
                            sec.Side = side
                        end
                        local holder = sec.Floating and sec.Slot or sec.Wrap
                        if holder then holder.LayoutOrder = e.k end
                        if sizes[sec] > 0 then h[side] += sizes[sec] + 16 end
                    end
                    page.BalancedCount = #list
                end

                function Tab:_balanceActive(force)
                    local page = self.Pages[self.ActiveSub or "_"] or self.Pages["_"]
                    if not page then return end
                    local count = 0
                    for _, sec in ipairs(self.Sections) do
                        if sec.Page == page and not sec.ParentSection then count += 1 end
                    end
                    if not force and page.BalancedCount == count then return end
                    self:_balance(page)
                end

                function Tab:_queueBalance(page)
                    if page.BalanceQueued then return end
                    page.BalanceQueued = true
                    task.delay(0.4, function()
                        page.BalanceQueued = false
                        if self.Window.Current == self and page.Root.Visible then self:_balanceActive() end
                    end)
                end

                function Tab:Section(opts)
                    if type(opts) == "string" then opts = { Title = opts } end
                    opts = opts or {}
                    local win = self.Window
                    local page = self:_page(opts.Sub or (self.SubDefs and (opts.Sub or self.BuildSub or self.SubDefs[1].key)) or "_")
                    local side = opts.Side
                    local col
                    if self.Columns == 1 or page.One then
                        col = page.Left
                    elseif side == "Right" then
                        col = page.Right
                    elseif side == "Left" then
                        col = page.Left
                    else
                        col = page.Load[1] <= page.Load[2] and page.Left or page.Right
                    end
                    local sec = setmetatable({}, Section)
                    sec.Tab, sec.Window, sec.Page = self, win, page
                    sec.Side = col == page.Left and 1 or 2
                    sec.Pinned = side ~= nil
                    sec.Rows = {}
                    sec.Order = 0
                    sec.Key = self.Name .. "/" .. tostring(opts.Title or "Section")
                    table.insert(self.Sections, sec)

                    local wrap = new("Frame", { Name = opts.Title or "Section", Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundTransparency = 1, LayoutOrder = #col:GetChildren(), Parent = col })
                    sec.Wrap = wrap
                    sec.Shadow = X.image(wrap, "shadow9", { Name = "Shadow", Position = UDim2.fromOffset(-28, -18), Size = UDim2.new(1, 56, 1, 58), SliceScale = 1, ImageTransparency = 0.62, ZIndex = 0 })
                    local card = new("Frame", { Name = "Card", Size = UDim2.new(1, 0, 0, HEAD_H), BorderSizePixel = 0, BackgroundTransparency = 0.03, ClipsDescendants = true, ZIndex = 1, Parent = wrap })
                    bind(card, "BackgroundColor3", "Surface")
                    U.corner(card, 14)
                    sec.CardGrad = new("UIGradient", { Color = ColorSequence.new(WHITE, Color3.fromRGB(208, 210, 218)), Rotation = 90, Parent = card })
                    sec.Card = card
                    sec.Gloss = X.image(card, "gloss9", { Name = "Gloss", Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.9, ZIndex = 1 })
                    sec.Grain = X.image(card, "grain", { Name = "Grain", Size = UDim2.fromScale(1, 1), ImageTransparency = 0.94, ZIndex = 1 })
                    sec.Spot = X.image(card, "glow", { Name = "Spot", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(300, 220), ImageTransparency = 1, ZIndex = 1 })
                    if sec.Spot then bind(sec.Spot, "ImageColor3", "Accent") end
                    sec.Rim = X.image(card, "rim9", { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.5, ZIndex = 8 })
                    if sec.Rim then bind(sec.Rim, "ImageColor3", "Glass") else bind(U.stroke(card, WHITE, 1, 0.92), "Color", "Glass") end

                    local stack = new("Frame", { Name = "Stack", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 2, Parent = card })
                    U.list(stack, 0)
                    function sec._sync()
                        if win.Scaling and not sec.Floating then win:_scalingDefer(sec._sync) return end
                        local h = math.ceil(stack.AbsoluteSize.Y / math.max(win.Scale.Scale, 0.1))
                        if h < 1 then return end
                        card.Size = UDim2.new(1, 0, 0, h)
                        wrap.Size = UDim2.new(wrap.Size.X.Scale, wrap.Size.X.Offset, 0, h)
                    end
                    stack:GetPropertyChangedSignal("AbsoluteSize"):Connect(sec._sync)

                    local head = new("Frame", { Name = "Head", Size = UDim2.new(1, 0, 0, HEAD_H), BackgroundTransparency = 1, LayoutOrder = 0, ZIndex = 3, Parent = stack })
                    sec.Head = head
                    local x = 16
                    if opts.Icon then
                        local tile = Nova.tile(head, { Name = "IconTile", Size = UDim2.fromOffset(26, 26), Pos = UDim2.new(0, 12, 0.5, 0), Anchor = Vector2.new(0, 0.5), Color = "Accent", Alpha = 0.78, Z = 3 })
                        sec.IconTile = tile
                        sec.HeadIcon = icon({ Parent = head, Icon = opts.Icon, Size = 15, Pos = UDim2.new(0, 25, 0.5, 0), Anchor = Vector2.new(0.5, 0.5), Color = "Accent", Z = 4 })
                        x = 46
                    end
                    sec.TitleLabel = label({ Parent = head, Text = opts.Title or "Section", Font = F.Bold(), Size = 14, Pos = UDim2.new(0, x, 0, 0), Box = UDim2.new(1, -x - 52, 1, 0), Truncate = true, Z = 4 })
                    sec.Accessory = new("Frame", { Name = "Accessory", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 9, Parent = head })
                    U.list(sec.Accessory, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
                    sec.Chev = icon({ Parent = head, Icon = "chevron-down", Size = 14, Pos = UDim2.new(1, -16, 0.5, 0), Anchor = Vector2.new(0.5, 0.5), Color = "Faint", Z = 4 })
                    sec.HeadLine = new("Frame", { Name = "Line", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, -28, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.5, ZIndex = 3, Parent = head })
                    bind(sec.HeadLine, "BackgroundColor3", "Line")
                    new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0), NumberSequenceKeypoint.new(0.88, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = sec.HeadLine })

                    local hit = new("TextButton", { Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6, Parent = head })
                    sec.HeadHit = hit
                    hit.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                        win:_cardPress(sec, input)
                    end)
                    hit.MouseButton1Click:Connect(function()
                        if win.CardDrag or os.clock() - (win.LastCardDrag or 0) < 0.3 then return end
                        if opts.Collapsible == false then return end
                        S.play("tick")
                        sec:SetCollapsed(not sec.Collapsed)
                    end)
                    hit.MouseEnter:Connect(function()
                        if opts.Collapsible ~= false then paint(sec.Chev, "ImageColor3", "Text", "Quick") end
                        win:ShowTip("Drag out to float · click to fold")
                    end)
                    U.leave(hit, function()
                        paint(sec.Chev, "ImageColor3", "Faint", "Quick")
                        win:HideTip()
                    end)
                    if opts.Collapsible == false then sec.Chev.Visible = false end

                    local body = new("Frame", { Name = "Body", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ClipsDescendants = true, LayoutOrder = 1, ZIndex = 2, Parent = stack })
                    sec.Body = body
                    local content = new("Frame", { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 2, Parent = body })
                    U.list(content, 0)
                    U.pad(content, 6, 6, 10, 6)
                    sec.Content = content

                    card.MouseMoved:Connect(function()
                        if not sec.Spot or sec.Floating and false then return end
                        local m = U.mouse()
                        local scale = math.max(win.Scale.Scale, 0.1)
                        local p = (m - card.AbsolutePosition) / scale
                        sec.Spot.Position = UDim2.fromOffset(p.X, p.Y)
                    end)
                    card.MouseEnter:Connect(function()
                        if sec.Spot then tween(sec.Spot, "Base", { ImageTransparency = 0.9 }) end
                        if sec.Rim then tween(sec.Rim, "Quick", { ImageTransparency = 0.25 }) end
                    end)
                    U.leave(card, function()
                        if sec.Spot then tween(sec.Spot, "Base", { ImageTransparency = 1 }) end
                        if sec.Rim then tween(sec.Rim, "Quick", { ImageTransparency = sec.Floating and 0.3 or 0.5 }) end
                    end)

                    page.Load[sec.Side] += 1
                    self:_queueBalance(page)
                    win:_applyCardStyle(sec)
                    local saved = win.State.get("collapsed", {})
                    if type(saved) == "table" and saved[sec.Key] then sec:SetCollapsed(true, true) end
                    local floats = win.State.get("floats", {})
                    if type(floats) == "table" and floats[sec.Key] then
                        local fp = floats[sec.Key]
                        task.delay(0.8, function()
                            if not sec.Floating and not win.Destroyed then
                                pcall(function() win:FloatSection(sec, Vector2.new(tonumber(fp[1]) or 40, tonumber(fp[2]) or 40)) end)
                            end
                        end)
                    end
                    return sec
                end

                function Section:SetTitle(text)
                    self.TitleLabel.Text = tostring(text)
                end

                function Section:_refreshVisibility()
                    local any = false
                    for _, row in ipairs(self.Rows) do
                        if row.Frame.Visible then any = true break end
                    end
                    local q = self.Window.Query or ""
                    if self.Floating then
                        self.Wrap.Visible = not self.Hidden
                    else
                        self.Wrap.Visible = (not self.Hidden) and (q == "" or any)
                    end
                end

                function Section:SetVisible(v)
                    self.Hidden = not v
                    self:_refreshVisibility()
                end

                function Section:SetCollapsed(v, instant)
                    v = v and true or false
                    if v == self.Collapsed then return end
                    self.Collapsed = v
                    local win = self.Window
                    local saved = win.State.get("collapsed", {})
                    if type(saved) ~= "table" then saved = {} end
                    saved[self.Key] = v or nil
                    win.State.data.collapsed = saved
                    win.State.save()
                    local body, content = self.Body, self.Content
                    local scale = math.max(win.Scale.Scale, 0.1)
                    self.BodyToken = (self.BodyToken or 0) + 1
                    local token = self.BodyToken
                    local quick = (instant or not M.enabled) and TweenInfo.new(0) or "Base"
                    tween(self.Chev, quick, { Rotation = v and -90 or 0 })
                    tween(self.HeadLine, quick, { BackgroundTransparency = v and 1 or 0.5 })
                    local h = math.ceil(content.AbsoluteSize.Y / scale) + 16
                    if v then
                        body.AutomaticSize = Enum.AutomaticSize.None
                        body.Size = UDim2.new(1, 0, 0, instant and 0 or h)
                        if not instant then tween(body, BODYINFO, { Size = UDim2.new(1, 0, 0, 0) }) end
                    else
                        body.AutomaticSize = Enum.AutomaticSize.None
                        if instant then
                            body.AutomaticSize = Enum.AutomaticSize.Y
                            body.Size = UDim2.new(1, 0, 0, 0)
                        else
                            tween(body, BODYINFO, { Size = UDim2.new(1, 0, 0, h) })
                            task.delay(0.34, function()
                                if self.BodyToken == token and not self.Collapsed then
                                    body.AutomaticSize = Enum.AutomaticSize.Y
                                    body.Size = UDim2.new(1, 0, 0, 0)
                                end
                            end)
                        end
                    end
                end

                function Section:IsCollapsed()
                    return self.Collapsed == true
                end

                function Section:Float(pos)
                    self.Window:FloatSection(self, pos)
                end

                function Section:Dock()
                    self.Window:DockSection(self)
                end

                function Section:_row(opts)
                    self.Order += 1
                    self.Tab.Loads[self.Page.Key] = (self.Tab.Loads[self.Page.Key] or 0) + 1
                    if not self.ParentSection then self.Page.Load[self.Side] += 1 end
                    local win = self.Window
                    local desc = opts.Desc
                    local nested = self.Nested == true
                    local height = opts.Height or (desc and (nested and 46 or 50) or (nested and 33 or 38))
                    local indent = (opts.Indent or 0) * 14
                    local frame = new("Frame", { Name = opts.Name or "Row", Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, LayoutOrder = opts.Order or self.Order, Parent = opts.Parent or self.Content })
                    local hover = new("Frame", { Name = "Hover", Position = UDim2.fromOffset(indent, 1), Size = UDim2.new(1, -indent, 1, -2), BorderSizePixel = 0, BackgroundTransparency = 1, Parent = frame })
                    bind(hover, "BackgroundColor3", "Elevated")
                    U.corner(hover, 9)
                    if indent > 0 then
                        local guide = new("Frame", { Name = "Guide", Position = UDim2.fromOffset(indent - 6, 8), Size = UDim2.new(0, 2, 1, -16), BorderSizePixel = 0, Parent = frame })
                        bind(guide, "BackgroundColor3", T.accentSoft(0.45))
                        U.corner(guide, UDim.new(1, 0))
                    end
                    local row = { Frame = frame, Hover = hover, Section = self, Opts = opts, Indent = indent }
                    local textX = 10 + indent
                    row.Title = label({ Parent = frame, Text = opts.Text or "", Font = F.Medium(), Size = nested and 13 or 14, Color = nested and function(tk) return tk.Text:Lerp(tk.Muted, 0.22) end or nil, Pos = UDim2.fromOffset(textX, desc and 8 or 0), Box = UDim2.new(1, -(textX + (opts.Reserve or 70)), 0, desc and 18 or height), Truncate = true, Rich = opts.Rich })
                    if desc then
                        row.Desc = label({ Parent = frame, Text = desc, Font = F.Regular(), Size = 12, Pos = UDim2.fromOffset(textX, 27), Box = UDim2.new(1, -(textX + (opts.Reserve or 70)), 0, 16), Color = "Muted", Truncate = true })
                    end
                    row.Right = new("Frame", { Name = "Right", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 2, Parent = frame })
                    U.list(row.Right, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

                    local function fitTitle()
                        if win.Scaling then win:_scalingDefer(fitTitle) return end
                        local scale = math.max(win.Scale.Scale, 0.1)
                        if row.OnWidth then row.OnWidth(frame.AbsoluteSize.X / scale) end
                        if opts.Reserve == 0 or not row.Right.Visible then return end
                        local rw = row.Right.AbsoluteSize.X / scale
                        local w = frame.AbsoluteSize.X / scale - textX - rw - 16
                        row.Title.Size = UDim2.new(0, math.max(w, 40), row.Title.Size.Y.Scale, row.Title.Size.Y.Offset)
                        if row.Desc then row.Desc.Size = UDim2.new(0, math.max(w, 40), 0, 16) end
                    end
                    row.fitTitle = fitTitle
                    row.Right:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitTitle)
                    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitTitle)
                    task.defer(fitTitle)

                    row.selfHidden = false
                    row.parentHidden = false
                    row.searchHidden = false
                    local entry = { sec = self, searchHidden = false, row = row }
                    function entry.text()
                        local t = row.Title and row.Title.Text or ""
                        if row.Desc then t = t .. " " .. row.Desc.Text end
                        if row.SearchExtra then t = t .. " " .. row.SearchExtra() end
                        return string.lower(t)
                    end
                    function row.isVisible()
                        return not (row.selfHidden or row.parentHidden or entry.searchHidden)
                    end
                    function entry.refresh()
                        frame.Visible = row.isVisible()
                        if row.OnRefresh then row.OnRefresh() end
                    end
                    row.Entry = entry
                    table.insert(self.Tab.Rows, entry)
                    table.insert(self.Rows, row)

                    function row.setHover(on)
                        tween(hover, "Quick", { BackgroundTransparency = on and 0.55 or 1 })
                    end
                    frame.MouseEnter:Connect(function()
                        row.setHover(true)
                        if opts.Tooltip then win:ShowTip(opts.Tooltip) end
                    end)
                    U.leave(frame, function()
                        row.setHover(false)
                        if opts.Tooltip then win:HideTip() end
                    end)

                    function row.SetText(text)
                        row.Title.Text = tostring(text)
                    end
                    function row.SetDesc(text)
                        if row.Desc then row.Desc.Text = tostring(text) end
                    end
                    function row.SetVisible(v)
                        row.selfHidden = not v
                        entry.refresh()
                        self:_refreshVisibility()
                    end
                    function row.SetParentHidden(v)
                        row.parentHidden = v and true or false
                        entry.refresh()
                        self:_refreshVisibility()
                    end
                    function row.hit()
                        local b = new("TextButton", { Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = frame })
                        return b
                    end
                    return row
                end

                Window.CardStyles = { "Glass", "Frosted", "Tinted", "Flat" }

                function Window:_applyCardStyle(sec)
                    local style = self.CardStyle or "Glass"
                    local card = sec.Card
                    if not card then return end
                    local accent = T.resolve("Accent")
                    if style == "Flat" then
                        card.BackgroundTransparency = 0
                        sec.CardGrad.Color = ColorSequence.new(WHITE)
                        if sec.Gloss then sec.Gloss.ImageTransparency = 1 end
                        if sec.Grain then sec.Grain.ImageTransparency = 1 end
                    elseif style == "Frosted" then
                        card.BackgroundTransparency = 0.32
                        sec.CardGrad.Color = ColorSequence.new(WHITE, Color3.fromRGB(220, 222, 230))
                        if sec.Gloss then sec.Gloss.ImageTransparency = 0.72 end
                        if sec.Grain then sec.Grain.ImageTransparency = 0.9 end
                    elseif style == "Tinted" then
                        card.BackgroundTransparency = 0.03
                        sec.CardGrad.Color = ColorSequence.new(WHITE:Lerp(accent, 0.05), WHITE:Lerp(accent, 0.34))
                        if sec.Gloss then sec.Gloss.ImageTransparency = 0.88 end
                        if sec.Grain then sec.Grain.ImageTransparency = 0.94 end
                    else
                        card.BackgroundTransparency = 0.03
                        sec.CardGrad.Color = ColorSequence.new(WHITE, Color3.fromRGB(208, 210, 218))
                        if sec.Gloss then sec.Gloss.ImageTransparency = 0.9 end
                        if sec.Grain then sec.Grain.ImageTransparency = 0.94 end
                    end
                end

                function Window:SetCardStyle(style)
                    Nova.trace("SetCardStyle")
                    for _, s in ipairs(Window.CardStyles) do
                        if s == style then
                            self.CardStyle = style
                            self.State.set("cardStyle", style)
                            for _, tab in ipairs(self.TabList) do
                                for _, sec in ipairs(tab.Sections) do self:_applyCardStyle(sec) end
                            end
                            return
                        end
                    end
                end

                function Window:_nextZ()
                    self.FloatZ += 1
                    return self.FloatZ
                end

                function Window:_initCards()
                    U.connect(UIS.InputChanged, function(input)
                        if self.CardPress and U.sameMove(input, self.CardPress.input) then self:_cardMove() end
                    end, self.Conns)
                    U.connect(UIS.InputEnded, function(input)
                        if U.sameEnd(input, self.CardPress and self.CardPress.input) then self:_cardEnd() end
                    end, self.Conns)
                end

                function Window:_cardPress(sec, input)
                    self.CardPress = { sec = sec, at = U.at(input), t = os.clock(), input = input }
                    if sec.Floating then sec.Wrap.ZIndex = self:_nextZ() end
                end

                function Window:_cardMove()
                    local press = self.CardPress
                    if not press then return end
                    local sec = press.sec
                    local m = U.at(press.input)
                    local scale = math.max(self.FloatScale.Scale, 0.1)
                    if not self.CardDrag then
                        local d = (m - press.at).Magnitude
                        if sec.Floating then
                            if d < 4 then return end
                        else
                            if self.IsTouch and os.clock() - press.t < 0.35 then
                                if d >= 10 then self.CardPress = nil end
                                return
                            end
                            if d < 12 or os.clock() - press.t < 0.08 then return end
                            local p = (sec.Card.AbsolutePosition - self.FloatLayer.AbsolutePosition) / scale
                            self:FloatSection(sec, p)
                            S.play("click", 0.8)
                        end
                        local origin = (sec.Wrap.AbsolutePosition - self.FloatLayer.AbsolutePosition) / scale
                        self.CardDrag = { sec = sec, grab = (m - self.FloatLayer.AbsolutePosition) / scale - origin, fresh = not sec.WasFloating }
                        self:HideTip()
                        tween(sec.Shadow, "Quick", { ImageTransparency = 0.25 })
                    end
                    local drag = self.CardDrag
                    local target = (m - self.FloatLayer.AbsolutePosition) / scale - drag.grab
                    local screen = self.FloatLayer.AbsoluteSize / scale
                    local wsz = sec.Wrap.AbsoluteSize / scale
                    target = Vector2.new(math.clamp(target.X, 8 - wsz.X + 80, screen.X - 80), math.clamp(target.Y, 4, screen.Y - 40))
                    sec.Wrap.Position = UDim2.fromOffset(target.X, target.Y)
                    if sec.Slot and sec.SlotStroke then
                        local slotCenter = sec.Slot.AbsolutePosition + sec.Slot.AbsoluteSize / 2
                        local cardCenter = sec.Wrap.AbsolutePosition + Vector2.new(sec.Wrap.AbsoluteSize.X / 2, math.min(sec.Wrap.AbsoluteSize.Y / 2, 40))
                        local near = self.IsOpen and sec.Tab == self.Current and (slotCenter - cardCenter).Magnitude < 110 * scale
                        if near ~= sec.NearSlot then
                            sec.NearSlot = near
                            tween(sec.SlotStroke, "Quick", { Transparency = near and 0.2 or 0.86 })
                            if sec.SlotGlow then tween(sec.SlotGlow, "Quick", { ImageTransparency = near and 0.7 or 1 }) end
                        end
                    end
                end

                function Window:_cardEnd()
                    local press = self.CardPress
                    self.CardPress = nil
                    local drag = self.CardDrag
                    if not drag then return end
                    self.CardDrag = nil
                    self.LastCardDrag = os.clock()
                    local sec = drag.sec
                    tween(sec.Shadow, "Base", { ImageTransparency = 0.3 })
                    if sec.NearSlot then
                        sec.NearSlot = false
                        self:DockSection(sec)
                        return
                    end
                    local p = sec.Wrap.Position
                    local floats = self.State.get("floats", {})
                    if type(floats) ~= "table" then floats = {} end
                    floats[sec.Key] = { math.floor(p.X.Offset), math.floor(p.Y.Offset) }
                    self.State.data.floats = floats
                    self.State.save()
                end

                function Window:FloatSection(sec, pos)
                    Nova.trace("FloatSection")
                    if sec.Floating or self.Destroyed then return end
                    local wrap, card = sec.Wrap, sec.Card
                    local scale = math.max(self.FloatScale.Scale, 0.1)
                    local size = wrap.AbsoluteSize / scale
                    local ph = new("Frame", { Name = "Slot", Size = UDim2.new(1, 0, 0, math.max(HEAD_H, size.Y)), LayoutOrder = wrap.LayoutOrder, BackgroundTransparency = 1, Parent = wrap.Parent })
                    local ghost = new("Frame", { Name = "Ghost", Size = UDim2.new(1, -4, 1, -4), Position = UDim2.fromOffset(2, 2), BorderSizePixel = 0, BackgroundTransparency = 0.6, Parent = ph })
                    bind(ghost, "BackgroundColor3", "Surface")
                    U.corner(ghost, 14)
                    sec.SlotStroke = U.stroke(ghost, WHITE, 1, 0.86)
                    bind(sec.SlotStroke, "Color", "Accent")
                    sec.SlotGlow = X.image(ph, "glow", { Name = "Glow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 60, 1, 60), ImageTransparency = 1 })
                    if sec.SlotGlow then bind(sec.SlotGlow, "ImageColor3", "Accent") end
                    local mark = icon({ Parent = ghost, Icon = "picture-in-picture-2", Size = 20, Pos = UDim2.fromScale(0.5, 0.42), Anchor = Vector2.new(0.5, 0.5), Color = "Faint" })
                    label({ Parent = ghost, Text = Nova.tr("Floating · drag back to dock"), Font = F.Medium(), Size = 12, Pos = UDim2.fromScale(0, 0.42), Box = UDim2.new(1, 0, 0, 16), AlignX = Enum.TextXAlignment.Center, Color = "Faint" }).Position = UDim2.new(0, 0, 0.42, 16)
                    sec.Slot = ph
                    wrap.Parent = self.FloatLayer
                    wrap.Size = UDim2.new(0, math.floor(size.X), 0, math.floor(size.Y))
                    local p = pos or ((wrap.AbsolutePosition - self.FloatLayer.AbsolutePosition) / scale)
                    wrap.Position = UDim2.fromOffset(p.X, p.Y)
                    wrap.ZIndex = self:_nextZ()
                    sec.Floating = true
                    sec.WasFloating = true
                    table.insert(self.Floats, sec)
                    if sec.Shadow then sec.Shadow.ImageTransparency = 0.3 end
                    if sec.Rim then sec.Rim.ImageTransparency = 0.3 end
                    local dock = new("TextButton", { Name = "Dock", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(24, 24), LayoutOrder = 9, ZIndex = 7, Parent = sec.Accessory })
                    local dockTile, dockTextured = Nova.tile(dock, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.3, Z = 7 })
                    local dockIcon = icon({ Parent = dock, Icon = "undo-2", Size = 13, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 8 })
                    dock.MouseEnter:Connect(function()
                        paint(dockIcon, "ImageColor3", "Text", "Quick")
                        self:ShowTip("Return to window")
                    end)
                    U.leave(dock, function()
                        paint(dockIcon, "ImageColor3", "Muted", "Quick")
                        self:HideTip()
                    end)
                    dock.MouseButton1Click:Connect(function()
                        self:HideTip()
                        S.play("click")
                        self:DockSection(sec)
                    end)
                    sec.DockButton = dock
                    sec:_refreshVisibility()
                    local floats = self.State.get("floats", {})
                    if type(floats) ~= "table" then floats = {} end
                    floats[sec.Key] = { math.floor(p.X), math.floor(p.Y) }
                    self.State.data.floats = floats
                    self.State.save()
                    self:_refreshTabState(sec.Tab)
                end

                function Window:FloatTab(tab, pos)
                    Nova.trace("FloatTab")
                    if type(tab) == "string" then tab = self.Tabs[tab] end
                    if not tab or self.Destroyed then return end
                    local scale = math.max(self.FloatScale.Scale, 0.1)
                    local screen = self.FloatLayer.AbsoluteSize / scale
                    local origin = Vector2.new(math.max(12, pos.X), math.max(12, pos.Y))
                    local parked = self.Parking and tab.Frame.Parent == self.Parking
                    if parked then
                        tab.Frame.Visible = false
                        tab.Frame.Parent = self.Body
                        if tab.RefreshGen ~= Nova.Refresh.gen then
                            Nova.Refresh.sync(tab.Frame)
                            tab.RefreshGen = Nova.Refresh.gen
                        end
                    end
                    local x, y, rowH = origin.X, origin.Y, 0
                    local maxX = math.min(origin.X + 640, screen.X - 24)
                    for _, sec in ipairs(tab.Sections) do
                        if not sec.Floating and not sec.Hidden then
                            local size = sec.Wrap.AbsoluteSize / math.max(self.Scale.Scale, 0.1)
                            if x + size.X > maxX and x > origin.X then
                                x = origin.X
                                y += rowH + 14
                                rowH = 0
                            end
                            self:FloatSection(sec, Vector2.new(math.clamp(x, 8, math.max(8, screen.X - size.X - 8)), math.clamp(y, 8, math.max(8, screen.Y - 80))))
                            x += size.X + 14
                            rowH = math.max(rowH, size.Y)
                        end
                    end
                    if parked and self.Current ~= tab then tab.Frame.Parent = self.Parking end
                    self:_refreshTabState(tab)
                end

                function Window:DockTab(tab)
                    Nova.trace("DockTab")
                    if type(tab) == "string" then tab = self.Tabs[tab] end
                    if not tab then return end
                    for _, sec in ipairs(tab.Sections) do
                        if sec.Floating then self:DockSection(sec) end
                    end
                    self:_refreshTabState(tab)
                end

                function Window:_refreshTabState(tab)
                    if not tab or not tab.PageHost then return end
                    local total, floating = 0, 0
                    for _, sec in ipairs(tab.Sections) do
                        if not sec.Hidden then
                            total += 1
                            if sec.Floating then floating += 1 end
                        end
                    end
                    local show = total > 0 and floating == total
                    if show and not tab.EmptyState then
                        local holder = new("Frame", { Name = "Popped", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(240, 150), BackgroundTransparency = 1, ZIndex = 3, Parent = tab.PageHost })
                        local glow = X.image(holder, "glow", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.35), Size = UDim2.fromOffset(200, 200), ImageTransparency = 0.86, ZIndex = 2 })
                        if glow then bind(glow, "ImageColor3", "Accent") end
                        icon({ Parent = holder, Icon = "picture-in-picture-2", Size = 30, Pos = UDim2.new(0.5, 0, 0, 28), Anchor = Vector2.new(0.5, 0.5), Color = "Faint", Z = 4 })
                        label({ Parent = holder, Text = Nova.tr("Panels are floating"), Font = F.Semi(), Size = 14, Pos = UDim2.fromOffset(0, 56), Box = UDim2.new(1, 0, 0, 20), AlignX = Enum.TextXAlignment.Center, Color = "Muted", Z = 4, Name = "Caption" })
                        local btn = new("TextButton", { Name = "DockAll", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 92), Size = UDim2.fromOffset(150, 34), ZIndex = 4, Parent = holder })
                        Nova.tile(btn, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Accent", SliceScale = 0.6, Z = 4 })
                        local rim = X.image(btn, "rim9", { Size = UDim2.fromScale(1, 1), SliceScale = 0.64, ImageTransparency = 0.6, ZIndex = 6 })
                        if rim then bind(rim, "ImageColor3", "Glass") end
                        label({ Parent = btn, Text = Nova.tr("Dock all"), Font = F.Semi(), Size = 13, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = "OnAccent", Z = 7, Name = "Caption" })
                        local bs = new("UIScale", { Parent = btn })
                        btn.MouseEnter:Connect(function() tween(bs, "Quick", { Scale = 1.05 }) end)
                        U.leave(btn, function() tween(bs, "Quick", { Scale = 1 }) end)
                        btn.MouseButton1Click:Connect(function()
                            S.play("click")
                            self:DockTab(tab)
                        end)
                        tab.EmptyState = holder
                    end
                    if tab.EmptyState then tab.EmptyState.Visible = show end
                    for _, sec in ipairs(tab.Sections) do
                        if sec.Slot then sec.Slot.Visible = not show end
                    end
                end

                function Window:DockSection(sec)
                    Nova.trace("DockSection")
                    if not sec.Floating then return end
                    sec.Floating = false
                    for i, f in ipairs(self.Floats) do
                        if f == sec then table.remove(self.Floats, i) break end
                    end
                    local wrap = sec.Wrap
                    local slot = sec.Slot
                    if slot and slot.Parent then
                        wrap.LayoutOrder = slot.LayoutOrder
                        wrap.Parent = slot.Parent
                        slot:Destroy()
                    end
                    sec.Slot, sec.SlotStroke, sec.SlotGlow = nil, nil, nil
                    wrap.Position = UDim2.new()
                    wrap.Size = UDim2.new(1, 0, 0, wrap.AbsoluteSize.Y / math.max(self.Scale.Scale, 0.1))
                    wrap.ZIndex = 1
                    if sec.DockButton then sec.DockButton:Destroy() sec.DockButton = nil end
                    if sec.Shadow then tween(sec.Shadow, "Base", { ImageTransparency = 0.62 }) end
                    if sec.Rim then sec.Rim.ImageTransparency = 0.5 end
                    task.defer(function() if sec._sync then sec._sync() end end)
                    sec:_refreshVisibility()
                    local floats = self.State.get("floats", {})
                    if type(floats) == "table" then
                        floats[sec.Key] = nil
                        self.State.data.floats = floats
                        self.State.save()
                    end
                    self:_refreshTabState(sec.Tab)
                end
            end

            do
                local U, M, T, F, I, S = Nova.U, Nova.Motion, Nova.Theme, Nova.Font, Nova.Icons, Nova.Sound
                local new, tween, bind = U.new, M.tween, T.bind
                local label, icon = Nova.label, Nova.icon
                local Section = Nova.SectionClass
                local UIS = Nova.Services.UserInputService
                local WHITE = Color3.new(1, 1, 1)

                local X = Nova.Tex

                local function paint(inst, prop, token, info)
                    local map = T.registry[inst]
                    if not map then
                        map = {}
                        T.registry[inst] = map
                    end
                    map[prop] = token
                    tween(inst, info or "Base", { [prop] = T.resolve(token) })
                end
                Nova.paint = paint

                local function safe(fn, ...)
                    if type(fn) ~= "function" then return end
                    local ok, err = pcall(fn, ...)
                    if not ok then warn("[Nova] " .. tostring(err)) end
                end
                Nova.safe = safe

                local function keyName(k)
                    if typeof(k) ~= "EnumItem" then return "None" end
                    if k.EnumType == Enum.UserInputType then
                        if k == Enum.UserInputType.MouseButton1 then return "MB1" end
                        if k == Enum.UserInputType.MouseButton2 then return "MB2" end
                        if k == Enum.UserInputType.MouseButton3 then return "MB3" end
                        return "None"
                    end
                    local short = { LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl", LeftAlt = "LAlt", RightAlt = "RAlt", Backquote = "`", Return = "Enter", F13 = "MB4", F14 = "MB5" }
                    return short[k.Name] or k.Name
                end
                Nova.keyName = keyName

                function Nova.keyHeld(k)
                    if typeof(k) ~= "EnumItem" then return false end
                    local ok, v = pcall(function()
                        if k.EnumType == Enum.UserInputType then return UIS:IsMouseButtonPressed(k) end
                        return UIS:IsKeyDown(k)
                    end)
                    return ok and v or false
                end

                function Nova.bindHit(win, input, key, processed)
                    if typeof(key) ~= "EnumItem" then return false end
                    if key.EnumType == Enum.UserInputType then
                        if input.UserInputType ~= key or processed then return false end
                        if win and win.PointerOverUI and win:PointerOverUI() then return false end
                        return true
                    end
                    return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key
                end

                local function pulseStroke(stroke)
                    local tw = Nova.Services.TweenService:Create(stroke, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.15 })
                    tw:Play()
                    return tw
                end

                local FIELD_LIGHT = Color3.fromRGB(190, 193, 202)

                local function field(parent, props)
                    local f = new(props.Class or "Frame", {
                        Name = props.Name or "Field",
                        Size = props.Size,
                        BorderSizePixel = 0,
                        LayoutOrder = props.Order or 10,
                        ZIndex = props.Z or 2,
                        Parent = parent,
                    })
                    if props.Class == "TextButton" then
                        f.Text = ""
                        f.AutoButtonColor = false
                    end
                    bind(f, "BackgroundColor3", "Elevated")
                    U.corner(f, props.Radius or 8)
                    new("UIGradient", { Color = ColorSequence.new(WHITE, FIELD_LIGHT), Rotation = 90, Parent = f })
                    local st = U.stroke(f, WHITE, 1, 0.84)
                    bind(st, "Color", "Glass")
                    return f, st
                end
                Nova.field = field

                local function makeChip(win, parent, current, onChanged, order)
                    local FACE = 23
                    local chip = new("TextButton", { Name = "Bind", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 26), LayoutOrder = order or 5, ZIndex = 3, Parent = parent })
                    local base = new("Frame", { Name = "Base", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(6, 7, 10), ZIndex = 3, Parent = chip })
                    U.corner(base, 7)
                    local bst = U.stroke(base, WHITE, 1, 0.9)
                    bind(bst, "Color", "Glass")
                    local face = new("Frame", { Name = "Face", Size = UDim2.new(1, 0, 0, FACE), BorderSizePixel = 0, ZIndex = 4, Parent = chip })
                    bind(face, "BackgroundColor3", "Elevated")
                    U.corner(face, 7)
                    new("UIGradient", { Color = ColorSequence.new(WHITE, Color3.fromRGB(196, 199, 208)), Rotation = 90, Parent = face })
                    local st = U.stroke(face, WHITE, 1, 0.82)
                    bind(st, "Color", "Glass")
                    local l = label({ Parent = face, Text = "", Font = F.Semi(), Size = 12, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = "Muted", Z = 5 })
                    local obj = { Key = current, Chip = chip }
                    local listening, pulse, hovered = false, nil, false
                    local function shown()
                        if typeof(obj.Key) ~= "EnumItem" then return "\226\128\148" end
                        return keyName(obj.Key)
                    end
                    local function fit()
                        local txt = shown()
                        chip.Size = UDim2.fromOffset(math.max(34, math.floor((utf8.len(txt) or #txt) * 7.4 + 18)), 26)
                        l.Text = txt
                    end
                    fit()
                    local function idle()
                        listening = false
                        task.defer(function() if not listening then win.Listening = false end end)
                        if pulse then pulse:Cancel() pulse = nil end
                        paint(st, "Color", "Glass", "Quick")
                        tween(st, "Quick", { Transparency = hovered and 0.6 or 0.82 })
                        paint(bst, "Color", "Glass", "Quick")
                        tween(bst, "Quick", { Transparency = 0.9 })
                        paint(l, "TextColor3", obj.Key and "Text" or "Faint", "Quick")
                        fit()
                    end
                    paint(l, "TextColor3", obj.Key and "Text" or "Faint", TweenInfo.new(0))
                    function obj.Set(k, silent)
                        obj.Key = k
                        if not listening then idle() else fit() end
                        if not silent then safe(onChanged, k) end
                    end
                    chip.MouseEnter:Connect(function()
                        hovered = true
                        if not listening then tween(st, "Quick", { Transparency = 0.6 }) end
                    end)
                    U.leave(chip, function()
                        hovered = false
                        if not listening then tween(st, "Quick", { Transparency = 0.82 }) end
                        tween(face, "Quick", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, FACE) })
                    end)
                    chip.MouseButton1Down:Connect(function()
                        tween(face, "Quick", { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, FACE - 2) })
                    end)
                    chip.MouseButton1Up:Connect(function()
                        tween(face, "PopSmall", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, FACE) })
                    end)
                    chip.MouseButton2Click:Connect(function()
                        if listening or obj.Key == nil or os.clock() - (obj.BoundAt or 0) < 0.3 then return end
                        S.play("tick")
                        obj.Key = nil
                        idle()
                        safe(onChanged, nil)
                    end)
                    chip.MouseButton1Click:Connect(function()
                        if listening or os.clock() - (obj.BoundAt or 0) < 0.3 then return end
                        S.play("click")
                        listening = true
                        l.Text = Nova.tr("Press") .. " \226\128\166"
                        chip.Size = UDim2.fromOffset(66, 26)
                        paint(l, "TextColor3", "Accent", "Quick")
                        paint(st, "Color", "Accent", "Quick")
                        paint(bst, "Color", "Accent", "Quick")
                        tween(bst, "Quick", { Transparency = 0.55 })
                        pulse = pulseStroke(st)
                        task.defer(function() win.Listening = true end)
                    end)
                    U.connect(UIS.InputBegan, function(input)
                        if not listening or not win.Listening then return end
                        local k
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then idle() return end
                            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                                obj.Key = nil
                                idle()
                                safe(onChanged, nil)
                                return
                            end
                            k = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.Touch then
                            idle()
                            return
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            k = input.UserInputType
                            obj.BoundAt = os.clock()
                        end
                        if k then
                            obj.Key = k
                            idle()
                            S.play("tick")
                            safe(onChanged, k)
                        end
                    end, win.Conns)
                    return obj
                end

                function Section:Toggle(opts)
                    opts = opts or {}
                    local win = self.Window
                    local row = self:_row({ Text = opts.Text, Desc = opts.Desc, Tooltip = opts.Tooltip, Reserve = (opts.Keybind ~= nil or opts.Bind) and 128 or 70, Indent = opts.Indent, Order = opts.Order, Parent = opts.Parent })
                    local state = opts.Default and true or false
                    local hit = row.hit()
                    local TW, TH, KH = 48, 24, 18
                    if self.Nested then TW, TH, KH = 38, 20, 14 end
                    local track = new("Frame", { Name = "Switch", Size = UDim2.fromOffset(TW, TH), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 10, ZIndex = 2, Parent = row.Right })
                    U.corner(track, UDim.new(1, 0))
                    local tst = U.stroke(track, WHITE, 1, 0.86)
                    bind(tst, "Color", "Glass")
                    local tglow = X.image(track, "glow", { Name = "Glow", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(TW + 36, TH + 32), ImageTransparency = 1, ZIndex = 1 })
                    if tglow then bind(tglow, "ImageColor3", "Accent") end
                    local tfill = X.image(track, "pillfill", { Name = "Fill", Size = UDim2.fromScale(1, 1), ZIndex = 2 })
                    local tshade = X.image(track, "trackshade", { Name = "Shade", Size = UDim2.fromScale(1, 1), ZIndex = 3 })
                    if not tfill then track.BackgroundTransparency = 0 end
                    local knob = new("Frame", { Name = "Knob", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(KH, KH), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4, Parent = track })
                    local kimg = X.image(knob, "knob", { Name = "Face", Size = UDim2.fromScale(1, 1), ZIndex = 4 })
                    if kimg then
                        U.shadow(kimg, 0.45, 5, 1.5, 0)
                    else
                        knob.BackgroundTransparency = 0
                        U.corner(knob, UDim.new(1, 0))
                    end
                    local pressed = false
                    local function place(instant)
                        local w = pressed and (KH + 6) or KH
                        local x = state and (TW - w - 3) or 3
                        local info = instant and TweenInfo.new(0) or TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        local quick = instant and TweenInfo.new(0) or "Quick"
                        tween(knob, info, { Position = UDim2.new(0, x, 0.5, 0), Size = UDim2.fromOffset(w, KH) })
                        local fillTarget = tfill or track
                        local prop = tfill and "ImageColor3" or "BackgroundColor3"
                        paint(fillTarget, prop, state and "Accent" or "Elevated", quick)
                        paint(kimg or knob, kimg and "ImageColor3" or "BackgroundColor3", state and "OnAccent" or function(tk) return tk.Muted:Lerp(tk.Text, 0.5) end, quick)
                        if tglow then tween(tglow, quick, { ImageTransparency = state and 0.6 or 1 }) end
                        paint(tst, "Color", state and "Accent" or "Glass", quick)
                        tween(tst, quick, { Transparency = state and 0.55 or 0.86 })
                    end
                    place(true)
                    local obj = { Row = row.Frame, Type = "Toggle" }
                    local function set(v, fire)
                        v = v and true or false
                        local changed = v ~= state
                        state = v
                        place(false)
                        if changed then win:_kbDirty() end
                        if changed and obj.Changed then safe(obj.Changed, state) end
                        if fire ~= false then safe(opts.Callback, state) end
                    end
                    hit.MouseButton1Down:Connect(function()
                        pressed = true
                        place(false)
                    end)
                    hit.MouseButton1Up:Connect(function()
                        pressed = false
                    end)
                    U.leave(hit, function()
                        if pressed then
                            pressed = false
                            place(false)
                        end
                    end)
                    hit.MouseButton1Click:Connect(function()
                        if opts.Locked then return end
                        pressed = false
                        S.play(state and "off" or "on")
                        set(not state)
                    end)
                    if opts.Keybind ~= nil or opts.Bind then
                        obj.Bind = makeChip(win, row.Right, typeof(opts.Keybind) == "EnumItem" and opts.Keybind or nil, function(k)
                            safe(opts.OnBind, k)
                            win:_kbDirty()
                        end, 5)
                        win:RegisterKeybind({
                            kind = "toggle",
                            name = function() return row.Title.Text end,
                            key = function() return obj.Bind.Key end,
                            active = function() return state end,
                            set = function(k) obj.Bind.Set(k) end,
                            toggle = function()
                                if opts.Locked then return end
                                S.play(state and "off" or "on")
                                set(not state)
                            end,
                            alive = function() return row.Frame.Parent ~= nil end,
                        })
                        if opts.KeyToggle then
                            U.connect(UIS.InputBegan, function(input, processed)
                                if win.Destroyed or win.Listening or opts.Locked then return end
                                if UIS:GetFocusedTextBox() then return end
                                local key = obj.Bind.Key
                                if Nova.bindHit(win, input, key, processed) then
                                    S.play(state and "off" or "on")
                                    set(not state)
                                end
                            end, win.Conns)
                        end
                    end
                    if opts.Drawer then
                        local chev = icon({ Parent = row.Right, Icon = "settings", Size = 13, Color = "Faint", Z = 3 })
                        chev.LayoutOrder = 8
                        self.Order += 1
                        local indentPx = row.Indent
                        local tile = new("Frame", { Name = "Tile", Position = UDim2.fromOffset(indentPx + 2, 1), Size = UDim2.new(1, -(indentPx + 4), 0, row.Frame.Size.Y.Offset - 2), BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 0, Parent = row.Frame })
                        bind(tile, "BackgroundColor3", "Elevated")
                        U.corner(tile, 10)
                        local drawer = new("Frame", { Name = "Drawer", Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, LayoutOrder = self.Order, Parent = opts.Parent or self.Content })
                        local panel = new("Frame", { Name = "Panel", Position = UDim2.fromOffset(indentPx, 0), Size = UDim2.new(1, -indentPx, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = drawer })
                        local inner = new("Frame", { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = panel })
                        U.list(inner, 0)
                        local rule = new("Frame", { Name = "Rule", Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.92, ZIndex = 2, Parent = panel })
                        bind(rule, "BackgroundColor3", "Glass")
                        U.pad(inner, 3, 2, 4, 2)
                        local sub = setmetatable({ Tab = self.Tab, Window = win, Page = self.Page, Side = self.Side, Rows = self.Rows, Order = 0, Content = inner, Card = self.Card, ParentSection = self, Nested = true }, Nova.SectionClass)
                        local parent = self
                        sub.OwnerToggle = obj
                        sub.OwnerRow = row
                        sub._refreshVisibility = function() parent:_refreshVisibility() end
                        local childRows = {}
                        sub._row = function(s2, o)
                            local r = Nova.SectionClass._row(s2, o)
                            table.insert(childRows, r)
                            return r
                        end
                        row.SearchExtra = function()
                            local out = {}
                            for _, r in ipairs(childRows) do table.insert(out, r.Entry.text()) end
                            return table.concat(out, " ")
                        end
                        local open, searchForced = false, false
                        local function expanded() return open or searchForced end
                        local function measure()
                            local scale = math.max(win.Scale.Scale, 0.1)
                            return math.floor(panel.AbsoluteSize.Y / scale + 10)
                        end
                        local function tileSize(target)
                            return UDim2.new(1, -(indentPx + 4), 0, row.Frame.Size.Y.Offset - 2 + math.max(target - 8, 0))
                        end
                        local function render(instant)
                            local on = expanded()
                            paint(chev, "ImageColor3", on and "Accent" or "Faint", instant and TweenInfo.new(0) or "Quick")
                            local target = on and measure() or 0
                            local tt = on and 0.42 or 1
                            if instant then
                                drawer.Size = UDim2.new(1, 0, 0, target)
                                tile.Size = tileSize(target)
                                tile.BackgroundTransparency = tt
                            else
                                local ti = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                                tween(drawer, ti, { Size = UDim2.new(1, 0, 0, target) })
                                tween(tile, ti, { Size = tileSize(target), BackgroundTransparency = tt })
                            end
                        end
                        local function setOpen(v, instant)
                            open = v and true or false
                            render(instant)
                        end
                        row.OnRefresh = function()
                            local q = win.Query or ""
                            local any = q == ""
                            if not any then
                                for _, r in ipairs(childRows) do
                                    if r.isVisible() then any = true break end
                                end
                            end
                            drawer.Visible = row.isVisible() and any
                            tile.Visible = drawer.Visible
                            local want = q ~= "" and any and row.isVisible()
                            if want ~= searchForced then
                                searchForced = want
                                render(false)
                            end
                        end
                        local function fitDrawer()
                            if win.Scaling then win:_scalingDefer(fitDrawer) return end
                            if expanded() then
                                local t = measure()
                                drawer.Size = UDim2.new(1, 0, 0, t)
                                tile.Size = tileSize(t)
                            end
                        end
                        panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitDrawer)
                        obj.Drawer = sub
                        obj.DrawerFrame = drawer
                        function obj:SetDrawer(v, instant) setOpen(v, instant) end
                        function obj:IsDrawerOpen() return open end
                        obj.Changed = function(v) setOpen(v, false) end
                        task.defer(function() setOpen(state, true) end)
                    end
                    function obj:Set(v) set(v, true) end
                    function obj:SetValue(v) set(v, true) end
                    function obj:SetSilent(v) set(v, false) end
                    function obj:Get() return state end
                    function obj:SetText(t) row.SetText(t) end
                    function obj:SetDesc(t) row.SetDesc(t) end
                    function obj:SetVisible(v) row.SetVisible(v) end
                    function obj:SetParentHidden(v) row.SetParentHidden(v) end
                    function obj:SetLocked(v) opts.Locked = v end
                    obj.RowObj = row
                    obj.Title = row.Title
                    obj.DescLabel = row.Desc
                    return obj
                end

                function Section:Slider(opts)
                    opts = opts or {}
                    local min, max = tonumber(opts.Min) or 0, tonumber(opts.Max) or 100
                    if max <= min then max = min + 1 end
                    local dec = tonumber(opts.Decimals) or tonumber(opts.Rounding) or 0
                    local row = self:_row({ Text = opts.Text, Tooltip = opts.Tooltip, Height = 56, Reserve = 90, Indent = opts.Indent, Order = opts.Order, Parent = opts.Parent })
                    row.Title.Position = UDim2.fromOffset(10 + row.Indent, 7)
                    row.Title.Size = UDim2.new(1, -(100 + row.Indent), 0, 20)
                    local valueLabel = label({ Parent = row.Frame, Text = "", Font = F.Semi(), Size = 13, Anchor = Vector2.new(1, 0), Pos = UDim2.new(1, -12, 0, 7), Box = UDim2.fromOffset(90, 20), AlignX = Enum.TextXAlignment.Right, Color = "Muted" })
                    row.Right.Visible = false
                    row.OnWidth = function(w)
                        local s = math.max(self.Window.Scale.Scale, 0.1)
                        local vw = valueLabel.TextBounds.X / s
                        row.Title.Size = UDim2.new(0, math.max(w - (10 + row.Indent) - vw - 28, 40), 0, 20)
                    end
                    valueLabel:GetPropertyChangedSignal("TextBounds"):Connect(function() if row.fitTitle then row.fitTitle() end end)
                    local trackHolder = new("TextButton", { Name = "Track", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.new(0, 12 + row.Indent, 0, 30), Size = UDim2.new(1, -(24 + row.Indent), 0, 20), ZIndex = 2, Parent = row.Frame })
                    local track = new("Frame", { Name = "Bar", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 8), BorderSizePixel = 0, ZIndex = 2, Parent = trackHolder })
                    bind(track, "BackgroundColor3", "Elevated")
                    U.corner(track, UDim.new(1, 0))
                    do
                        local shade = new("Frame", { Name = "Shade", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 2, Parent = track })
                        U.corner(shade, UDim.new(1, 0))
                        new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.6, 0.9), NumberSequenceKeypoint.new(1, 1) }), Rotation = 90, Parent = shade })
                        bind(U.stroke(track, WHITE, 1, 0.9), "Color", "Glass")
                    end
                    local fill = new("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, ZIndex = 3, Parent = track })
                    bind(fill, "BackgroundColor3", "Accent")
                    U.corner(fill, UDim.new(1, 0))
                    new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(200, 200, 200), WHITE), Parent = fill })
                    local glow = U.shadow(fill, 0.55, 8, 0, 0)
                    if glow then bind(glow, "Color", "Accent") end
                    local knob = new("Frame", { Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(16, 16), BorderSizePixel = 0, ZIndex = 4, Parent = track })
                    bind(knob, "BackgroundColor3", "OnAccent")
                    U.corner(knob, UDim.new(1, 0))
                    local kface = X.image(knob, "knob", { Name = "Face", Size = UDim2.fromScale(1, 1), ZIndex = 4 })
                    if kface then knob.BackgroundTransparency = 1 end
                    local kst = U.stroke(knob, WHITE, 2, 0.1)
                    bind(kst, "Color", "Accent")
                    U.shadow(knob, 0.35, 6, 1, 0)
                    local kscale = new("UIScale", { Parent = knob })

                    local value = U.clamp(tonumber(opts.Default) or min, min, max)
                    local obj = { Row = row.Frame, Type = "Slider" }
                    local function text(v)
                        if opts.Display then
                            local ok, t = pcall(opts.Display, v)
                            if ok and type(t) == "string" then return t end
                        end
                        return U.fmt(v, dec) .. (opts.Suffix or "")
                    end
                    local function render(instant)
                        local p = (value - min) / (max - min)
                        local info = instant and TweenInfo.new(0) or TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        tween(fill, info, { Size = UDim2.fromScale(p, 1) })
                        tween(knob, info, { Position = UDim2.fromScale(p, 0.5) })
                        valueLabel.Text = text(value)
                    end
                    render(true)
                    local function set(v, fire)
                        v = U.round(U.clamp(tonumber(v) or min, min, max), dec)
                        if opts.Step then v = U.round(math.floor((v - min) / opts.Step + 0.5) * opts.Step + min, dec) end
                        if v == value and fire ~= "force" then return end
                        local last = value
                        value = v
                        render(false)
                        if fire ~= false then safe(opts.Callback, value) end
                        if last ~= value and obj.Changed then safe(obj.Changed, value) end
                    end
                    local dragging, dragIn = false, nil
                    local arm, rel = nil, nil
                    local lastTick = 0
                    local function tick(before)
                        if value ~= before and os.clock() - lastTick > 0.04 then
                            lastTick = os.clock()
                            S.play("tick", 0.5)
                        end
                    end
                    local function fromInput(pos)
                        local ax, aw = track.AbsolutePosition.X, track.AbsoluteSize.X
                        local p = U.clamp((pos.X - ax) / math.max(aw, 1), 0, 1)
                        local before = value
                        set(min + (max - min) * p, true)
                        tick(before)
                    end
                    local function fromRel(pos)
                        local aw = math.max(track.AbsoluteSize.X, 1)
                        local p = U.clamp((rel.v - min) / (max - min) + (pos.X - rel.x) / aw, 0, 1)
                        local before = value
                        set(min + (max - min) * p, true)
                        tick(before)
                    end
                    trackHolder.InputBegan:Connect(function(input)
                        if not U.isClick(input) or opts.Locked then return end
                        if input.UserInputType == Enum.UserInputType.Touch then
                            arm = { input = input, x = input.Position.X, y = input.Position.Y }
                            return
                        end
                        dragging, dragIn, rel = true, input, nil
                        tween(kscale, "Quick", { Scale = 1.3 })
                        paint(valueLabel, "TextColor3", "Text", "Quick")
                        fromInput(input.Position)
                    end)
                    U.connect(UIS.InputChanged, function(input)
                        if arm and input == arm.input then
                            local dx, dy = input.Position.X - arm.x, input.Position.Y - arm.y
                            if math.abs(dy) > 10 and math.abs(dy) > math.abs(dx) then
                                arm = nil
                            elseif math.abs(dx) > 8 then
                                arm = nil
                                dragging, dragIn = true, input
                                rel = { x = input.Position.X, v = value }
                                tween(kscale, "Quick", { Scale = 1.3 })
                                paint(valueLabel, "TextColor3", "Text", "Quick")
                            end
                            return
                        end
                        if dragging and U.sameMove(input, dragIn) then
                            if rel then fromRel(input.Position) else fromInput(input.Position) end
                        end
                    end, self.Window.Conns)
                    U.connect(UIS.InputEnded, function(input)
                        if arm and input == arm.input then arm = nil end
                        if dragging and U.sameEnd(input, dragIn) then
                            dragging = false
                            rel = nil
                            tween(kscale, "PopSmall", { Scale = 1 })
                            paint(valueLabel, "TextColor3", "Muted", "Quick")
                            safe(opts.Released, value)
                        end
                    end, self.Window.Conns)
                    row.Frame.MouseEnter:Connect(function() if not dragging then tween(kscale, "Quick", { Scale = 1.15 }) end end)
                    U.leave(row.Frame, function() if not dragging then tween(kscale, "Quick", { Scale = 1 }) end end)
                    function obj:Set(v) set(v, true) end
                    function obj:SetValue(v) set(v, true) end
                    function obj:SetSilent(v) set(v, false) end
                    function obj:Get() return value end
                    function obj:SetMax(v) max = tonumber(v) or max set(value, false) render(true) end
                    function obj:SetMin(v) min = tonumber(v) or min set(value, false) render(true) end
                    function obj:Refresh() render(true) end
                    function obj:SetText(t) row.SetText(t) end
                    function obj:SetVisible(v) row.SetVisible(v) end
                    function obj:SetParentHidden(v) row.SetParentHidden(v) end
                    obj.RowObj = row
                    obj.Title = row.Title
                    return obj
                end

                local function normalize(list)
                    local out = {}
                    for _, o in ipairs(list or {}) do
                        if type(o) == "table" then
                            table.insert(out, { value = o.code ~= nil and o.code or o.value or o[1], label = tostring(o.label or o.Text or o.code or o.value or o[2] or o[1]) })
                        else
                            table.insert(out, { value = o, label = tostring(o) })
                        end
                    end
                    return out
                end

                function Section:Dropdown(opts)
                    opts = opts or {}
                    local win = self.Window
                    local stacked = self.Nested == true and opts.Inline ~= true
                    local row = self:_row({ Text = opts.Text, Desc = opts.Desc, Tooltip = opts.Tooltip, Reserve = stacked and 0 or 190, Height = stacked and (opts.Desc and 74 or 60) or nil, Indent = opts.Indent, Order = opts.Order, Parent = opts.Parent })
                    local options = normalize(opts.Options or opts.Values)
                    local multi = opts.Multi == true
                    local selected = {}
                    local current = nil
                    if multi then
                        for _, v in ipairs(type(opts.Default) == "table" and opts.Default or {}) do selected[v] = true end
                    else
                        current = opts.Default
                    end
                    local box, bst
                    if stacked then
                        local tx = 10 + row.Indent
                        box, bst = field(row.Frame, { Class = "TextButton", Name = "Box", Size = UDim2.new(1, -(tx + 10), 0, 28) })
                        box.Position = UDim2.fromOffset(tx, row.Frame.Size.Y.Offset - 33)
                        row.Title.Position = UDim2.fromOffset(tx, 5)
                        row.Title.Size = UDim2.new(1, -(tx + 10), 0, 18)
                        if row.Desc then row.Desc.Position = UDim2.fromOffset(tx, 24) row.Desc.Size = UDim2.new(1, -(tx + 10), 0, 16) end
                        row.Right.Visible = false
                    else
                        box, bst = field(row.Right, { Class = "TextButton", Name = "Box", Size = UDim2.fromOffset(150, 30) })
                    end
                    local titleNeed
                    local function measureTitle()
                        task.spawn(function()
                            local txt = row.Title.Text
                            local w = U.textWidth(txt, row.Title.FontFace, 14)
                            if row.Title.Text == txt then
                                titleNeed = w
                                if row.fitTitle then row.fitTitle() end
                            end
                        end)
                    end
                    row.OnWidth = function(w)
                        if stacked then return end
                        local bw = w * 0.44
                        if titleNeed then bw = math.max(bw, w - (10 + row.Indent) - titleNeed - 36) end
                        bw = math.floor(U.clamp(bw, 100, 190))
                        if box.Size.X.Offset ~= bw then box.Size = UDim2.fromOffset(bw, 30) end
                    end
                    row.Title:GetPropertyChangedSignal("Text"):Connect(measureTitle)
                    row.Title:GetPropertyChangedSignal("FontFace"):Connect(measureTitle)
                    measureTitle()
                    local valueLabel = label({ Parent = box, Text = "", Font = F.Medium(), Size = 13, Pos = UDim2.fromOffset(12, 0), Box = UDim2.new(1, -46, 1, 0), Truncate = true, Z = 3 })
                    local divider = new("Frame", { Name = "Divider", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.new(0, 1, 1, -12), BorderSizePixel = 0, BackgroundColor3 = WHITE, BackgroundTransparency = 0.9, ZIndex = 3, Parent = box })
                    local chev = icon({ Parent = box, Icon = "chevron-down", Size = 14, Pos = UDim2.new(1, -15, 0.5, 0), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 3 })
                    local obj = { Row = row.Frame, Type = "Dropdown" }
                    local function labelFor(v)
                        for _, o in ipairs(options) do if o.value == v then return o.label end end
                        return v ~= nil and tostring(v) or nil
                    end
                    local function refreshLabel()
                        if multi then
                            local names = {}
                            for _, o in ipairs(options) do if selected[o.value] then table.insert(names, o.label) end end
                            local joined = table.concat(names, ", ")
                            valueLabel.Text = #names == 0 and (opts.Placeholder or Nova.tr("None")) or ((#names == 1 or #joined <= 13) and joined or (#names .. " " .. Nova.tr("selected")))
                        else
                            valueLabel.Text = labelFor(current) or (opts.Placeholder or Nova.tr("Select"))
                        end
                    end
                    refreshLabel()
                    row.SearchExtra = function() return valueLabel.Text end
                    row.SearchOptions = function()
                        local out = {}
                        for _, o in ipairs(options) do table.insert(out, tostring(o.label)) end
                        return table.concat(out, " ")
                    end
                    local function getValue()
                        if not multi then return current end
                        local out = {}
                        for _, o in ipairs(options) do if selected[o.value] then table.insert(out, o.value) end end
                        return out
                    end
                    local isOpen = false
                    local function open()
                        if isOpen then win:ClosePopups() return end
                        isOpen = true
                        S.play("click")
                        local scale = math.max(win.PopScale.Scale, 0.1)
                        local need = 96
                        for _, o in ipairs(options) do need = math.max(need, U.textWidth(o.label, F.Medium(), 13) + 56) end
                        local width = math.min(math.max(box.AbsoluteSize.X / scale, need), 280)
                        local count = #options
                        local searchH = count > 8 and 42 or 0
                        local listH = math.min(count, 8) * 32 + 8
                        local height = listH + searchH
                        local frame, shell, sc = win:PopupShell(width, height)
                        local px, py, _, oy = win:PopupPlace(box, width, height, "right")
                        frame.Position = UDim2.fromOffset(px, py)
                        win:PopupReveal(frame, shell, sc, oy == 1)
                        tween(chev, "Base", { Rotation = 180 })
                        paint(bst, "Color", "Accent", "Quick")
                        tween(bst, "Quick", { Transparency = 0.25 })
                        paint(chev, "ImageColor3", "Accent", "Quick")
                        local filter = ""
                        local list = new("ScrollingFrame", { Name = "List", Position = UDim2.fromOffset(0, searchH), Size = UDim2.new(1, 0, 1, -searchH), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 61, Parent = shell })
                        bind(list, "ScrollBarImageColor3", "Faint")
                        U.list(list, 2)
                        U.pad(list, 5, 5, 5, 5)
                        local items = {}
                        local function build()
                            for _, it in ipairs(items) do it:Destroy() end
                            items = {}
                            for i, o in ipairs(options) do
                                if filter == "" or string.find(string.lower(o.label), filter, 1, true) then
                                    local on = multi and selected[o.value] or (not multi and o.value == current)
                                    local b = new("TextButton", { Name = "Opt", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = on and 0.8 or 1, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 62, Parent = list })
                                    bind(b, "BackgroundColor3", on and "Accent" or "Surface2")
                                    U.corner(b, 8)
                                    local l = label({ Parent = b, Text = o.label, Font = on and F.Semi() or F.Medium(), Size = 13, Pos = UDim2.fromOffset(11, 0), Box = UDim2.new(1, -38, 1, 0), Truncate = true, Color = "Text", Z = 62 })
                                    local chk = icon({ Parent = b, Icon = "check", Size = 14, Pos = UDim2.new(1, -10, 0.5, 0), Anchor = Vector2.new(1, 0.5), Color = "Accent", Z = 62 })
                                    if not on then chk.ImageTransparency = 1 end
                                    local hovered = false
                                    local function style()
                                        local now = multi and selected[o.value] or (not multi and o.value == current)
                                        paint(b, "BackgroundColor3", now and "Accent" or "Surface2", "Quick")
                                        tween(b, "Quick", { BackgroundTransparency = hovered and (now and 0.68 or 0.5) or (now and 0.8 or 1) })
                                    end
                                    b.MouseEnter:Connect(function()
                                        hovered = true
                                        style()
                                    end)
                                    U.leave(b, function()
                                        hovered = false
                                        style()
                                    end)
                                    b.MouseButton1Click:Connect(function()
                                        S.play("tick")
                                        if multi then
                                            selected[o.value] = not selected[o.value] or nil
                                            local now = selected[o.value] == true
                                            tween(chk, "Quick", { ImageTransparency = now and 0 or 1 })
                                            l.FontFace = now and F.Semi() or F.Medium()
                                            style()
                                            refreshLabel()
                                            safe(opts.Callback, getValue())
                                            if obj.Changed then safe(obj.Changed, getValue()) end
                                        else
                                            current = o.value
                                            refreshLabel()
                                            win:ClosePopups()
                                            safe(opts.Callback, current)
                                            if obj.Changed then safe(obj.Changed, current) end
                                        end
                                    end)
                                    table.insert(items, b)
                                end
                            end
                        end
                        if searchH > 0 then
                            local sb = new("TextBox", { Name = "Filter", Position = UDim2.fromOffset(6, 7), Size = UDim2.new(1, -12, 0, 28), BorderSizePixel = 0, Text = "", PlaceholderText = Nova.tr("Search") .. "...", FontFace = F.Medium(), TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 62, Parent = shell })
                            bind(sb, "BackgroundColor3", "Surface")
                            bind(sb, "TextColor3", "Text")
                            bind(sb, "PlaceholderColor3", "Faint")
                            U.corner(sb, 7)
                            U.pad(sb, 0, 8, 0, 8)
                            sb:GetPropertyChangedSignal("Text"):Connect(function()
                                filter = string.lower(sb.Text)
                                build()
                            end)
                        end
                        build()
                        win:OpenPopup({
                            close = function()
                                isOpen = false
                                tween(chev, "Base", { Rotation = 0 })
                                paint(bst, "Color", "Glass", "Quick")
                                tween(bst, "Quick", { Transparency = 0.84 })
                                paint(chev, "ImageColor3", "Muted", "Quick")
                                win:PopupConceal(frame, shell)
                                task.delay(0.18, function() frame:Destroy() end)
                            end,
                        })
                    end
                    box.MouseButton1Click:Connect(open)
                    box.MouseEnter:Connect(function()
                        if isOpen then return end
                        paint(bst, "Color", "Accent", "Quick")
                        tween(bst, "Quick", { Transparency = 0.62 })
                        paint(chev, "ImageColor3", "Text", "Quick")
                    end)
                    U.leave(box, function()
                        if isOpen then return end
                        paint(bst, "Color", "Glass", "Quick")
                        tween(bst, "Quick", { Transparency = 0.84 })
                        paint(chev, "ImageColor3", "Muted", "Quick")
                    end)

                    function obj:Set(v, silent)
                        if multi then
                            selected = {}
                            for _, x in ipairs(type(v) == "table" and v or {}) do selected[x] = true end
                        else
                            current = v
                        end
                        refreshLabel()
                        if not silent then safe(opts.Callback, getValue()) end
                    end
                    function obj:SetValue(v) obj:Set(v) end
                    function obj:SetSilent(v) obj:Set(v, true) end
                    function obj:Get() return getValue() end
                    function obj:SetOptions(list)
                        options = normalize(list)
                        refreshLabel()
                    end
                    obj.Refresh = obj.SetOptions
                    function obj:SetText(t) row.SetText(t) end
                    function obj:SetVisible(v) row.SetVisible(v) end
                    function obj:SetParentHidden(v) row.SetParentHidden(v) end
                    obj.RowObj = row
                    obj.Title = row.Title
                    return obj
                end

                function Section:Button(opts)
                    opts = opts or {}
                    local win = self.Window
                    local row = self:_row({ Text = "", Tooltip = opts.Tooltip, Height = 44, Reserve = 0, Indent = opts.Indent, Order = opts.Order, Parent = opts.Parent })
                    row.Title.Visible = false
                    row.Right.Visible = false
                    row.Hover.Visible = false
                    local primary = opts.Style == "Primary"
                    local btn = new("TextButton", { Name = "Button", Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(8 + row.Indent, 5), Size = UDim2.new(1, -(16 + row.Indent), 0, 34), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2, Parent = row.Frame })
                    bind(btn, "BackgroundColor3", primary and "Accent" or "Surface2")
                    U.corner(btn, 9)
                    local st = U.stroke(btn, WHITE, 1, 0.9)
                    bind(st, "Color", "Glass")
                    local shadow = U.shadow(btn, 0.7, 10, 3, 0)
                    local sc = new("UIScale", { Parent = btn })
                    new("UIGradient", { Color = ColorSequence.new(WHITE, Color3.fromRGB(205, 207, 214)), Rotation = 90, Parent = btn })
                    local bevel = new("Frame", { Name = "Bevel", Size = UDim2.new(1, -16, 0, 1), Position = UDim2.fromOffset(8, 1), BorderSizePixel = 0, BackgroundColor3 = WHITE, BackgroundTransparency = primary and 0.55 or 0.8, ZIndex = 3, Parent = btn })
                    new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = bevel })
                    local SPOT_IDLE, SPOT_HOVER = 1, primary and 0.76 or 0.66
                    local spotClip = new("CanvasGroup", { Name = "SpotClip", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, Parent = btn })
                    U.corner(spotClip, 9)
                    local spot = X.image(spotClip, "glow", { Name = "Spot", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(190, 120), ImageTransparency = SPOT_IDLE, ZIndex = 2 })
                    if spot then bind(spot, "ImageColor3", primary and "OnAccent" or "Accent") end
                    local edgeGrad = new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.85) }), Enabled = false, Parent = st })
                    local HOVER_IN = TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    local HOVER_OUT = TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    local FOLLOW = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local PRESS = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local RELEASE = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    local hovering = false
                    local function follow(instant)
                        local abs, size = btn.AbsolutePosition, btn.AbsoluteSize
                        if size.X < 1 then return end
                        local p = U.clamp((U.mouse().X - abs.X) / size.X, 0, 1)
                        if spot then
                            if instant then spot.Position = UDim2.fromScale(p, 0.5) else tween(spot, FOLLOW, { Position = UDim2.fromScale(p, 0.5) }) end
                        end
                        if instant then edgeGrad.Offset = Vector2.new(p - 0.5, 0) else tween(edgeGrad, FOLLOW, { Offset = Vector2.new(p - 0.5, 0) }) end
                    end
                    local content = new("Frame", { Name = "Content", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = btn })
                    local text = label({ Parent = content, Text = opts.Text or "Button", Font = F.Semi(), Size = 14, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = primary and "OnAccent" or "Text", Z = 3 })
                    if opts.Icon then
                        text.Size = UDim2.new(1, -24, 1, 0)
                        text.Position = UDim2.fromOffset(24, 0)
                        icon({ Parent = content, Icon = opts.Icon, Size = 15, Pos = UDim2.new(0.5, -math.floor(U.textWidth(opts.Text or "", F.Semi(), 14) / 2) - 2, 0.5, 0), Anchor = Vector2.new(1, 0.5), Color = primary and "OnAccent" or "Accent", Z = 3 })
                    end
                    local armed, token = false, 0
                    local obj = { Row = row.Frame, Type = "Button", Base = btn }
                    local function disarm()
                        armed = false
                        text.Text = opts.Text or "Button"
                        edgeGrad.Enabled = hovering
                        paint(st, "Color", hovering and (primary and "OnAccent" or "Accent") or "Glass", "Quick")
                        tween(st, "Quick", { Transparency = hovering and (primary and 0.55 or 0.4) or 0.9 })
                    end
                    btn.MouseEnter:Connect(function()
                        if opts.Locked then return end
                        hovering = true
                        follow(true)
                        if spot then tween(spot, HOVER_IN, { ImageTransparency = SPOT_HOVER }) end
                        if not primary then paint(btn, "BackgroundColor3", "Elevated", HOVER_IN) end
                        if shadow then tween(shadow, HOVER_IN, { Transparency = 0.55 }) end
                        if not armed then
                            edgeGrad.Enabled = true
                            paint(st, "Color", primary and "OnAccent" or "Accent", HOVER_IN)
                            tween(st, HOVER_IN, { Transparency = primary and 0.55 or 0.4 })
                        end
                        S.play("hover", 0.6)
                        if opts.Tooltip then win:ShowTip(opts.Tooltip) end
                    end)
                    btn.MouseMoved:Connect(function()
                        if hovering then follow(false) end
                    end)
                    U.leave(btn, function()
                        hovering = false
                        if spot then tween(spot, HOVER_OUT, { ImageTransparency = SPOT_IDLE }) end
                        if not primary then paint(btn, "BackgroundColor3", "Surface2", HOVER_OUT) end
                        if shadow then tween(shadow, HOVER_OUT, { Transparency = 0.75 }) end
                        if not armed then
                            paint(st, "Color", "Glass", HOVER_OUT)
                            tween(st, HOVER_OUT, { Transparency = 0.9 })
                            task.delay(0.32, function() if not hovering and not armed then edgeGrad.Enabled = false end end)
                        end
                        tween(sc, RELEASE, { Scale = 1 })
                        win:HideTip()
                    end)
                    btn.MouseButton1Down:Connect(function()
                        if opts.Locked then return end
                        tween(sc, PRESS, { Scale = 0.975 })
                        if spot then tween(spot, PRESS, { ImageTransparency = SPOT_HOVER - 0.14 }) end
                    end)
                    btn.MouseButton1Up:Connect(function()
                        tween(sc, RELEASE, { Scale = 1 })
                        if spot then tween(spot, RELEASE, { ImageTransparency = hovering and SPOT_HOVER or SPOT_IDLE }) end
                    end)
                    btn.MouseButton1Click:Connect(function()
                        if opts.Locked then return end
                        S.play("click")
                        if opts.Confirm and type(win.ConfirmPopup) == "function" then
                            win:ConfirmPopup(btn, opts.Confirm, function() safe(opts.Callback) end)
                            return
                        end
                        if opts.DoubleClick and not armed then
                            armed = true
                            token += 1
                            local my = token
                            text.Text = opts.ConfirmText or "Click again to confirm"
                            edgeGrad.Enabled = false
                            paint(st, "Color", "Danger", "Quick")
                            tween(st, "Quick", { Transparency = 0.3 })
                            task.delay(2.5, function() if armed and token == my then disarm() end end)
                            return
                        end
                        if armed then disarm() end
                        safe(opts.Callback)
                    end)
                    function obj:SetText(t)
                        opts.Text = tostring(t)
                        if not armed then text.Text = opts.Text end
                    end
                    function obj:SetVisible(v) row.SetVisible(v) end
                    function obj:SetParentHidden(v) row.SetParentHidden(v) end
                    function obj:SetLocked(v)
                        opts.Locked = v
                        text.TextTransparency = v and 0.5 or 0
                    end
                    row.SearchExtra = function() return opts.Text or "" end
                    obj.RowObj = row
                    obj.Label = text
                    return obj
                end

                function Section:Keybind(opts)
                    opts = opts or {}
                    local win = self.Window
                    local row = self:_row({ Text = opts.Text, Desc = opts.Desc, Tooltip = opts.Tooltip, Reserve = 110, Indent = opts.Indent, Order = opts.Order, Parent = opts.Parent })
                    local obj = { Row = row.Frame, Type = "Keybind" }
                    local chip = makeChip(win, row.Right, opts.Default, function(k)
                        obj.Key = k
                        win:_kbDirty()
                        safe(opts.Callback, k)
                        safe(opts.ChangedCallback, k)
                    end, 10)
                    obj.Key = opts.Default
                    U.connect(UIS.InputBegan, function(input, processed)
                        if win.Listening or not opts.Pressed or not obj.Key then return end
                        if UIS:GetFocusedTextBox() then return end
                        if Nova.bindHit(win, input, obj.Key, processed) then safe(opts.Pressed, obj.Key) end
                    end, win.Conns)
                    function obj:Set(k)
                        obj.Key = k
                        chip.Set(k, true)
                        win:_kbDirty()
                    end
                    if not opts.NoList then
                        win:RegisterKeybind({
                            kind = "key",
                            name = function() return row.Title.Text end,
                            key = function() return obj.Key end,
                            active = function()
                                if type(opts.Active) == "function" then return opts.Active() and true or false end
                                return Nova.keyHeld(obj.Key)
                            end,
                            set = function(k) chip.Set(k) end,
                            alive = function() return row.Frame.Parent ~= nil end,
                        })
                    end
                    obj.SetValue = obj.Set
                    function obj:Get() return obj.Key end
                    function obj:SetText(t) row.SetText(t) end
                    function obj:SetVisible(v) row.SetVisible(v) end
                    function obj:SetParentHidden(v) row.SetParentHidden(v) end
                    row.SearchExtra = function() return keyName(obj.Key) end
                    obj.RowObj = row
                    obj.Title = row.Title
                    return obj
                end

                function Section:Input(opts)
                    opts = opts or {}
                    local row = self:_row({ Text = opts.Text, Desc = opts.Desc, Tooltip = opts.Tooltip, Reserve = 200, Indent = opts.Indent, Order = opts.Order, Parent = opts.Parent })
                    local holder, st = field(row.Right, { Name = "Input", Size = UDim2.fromOffset(opts.Width or 150, 30) })
                    if not opts.Width then
                        row.OnWidth = function(w)
                            local bw = math.floor(U.clamp(w * 0.5, 118, 200))
                            if holder.Size.X.Offset ~= bw then holder.Size = UDim2.fromOffset(bw, 30) end
                        end
                    end
                    local tb = new("TextBox", { Name = "Box", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), Text = tostring(opts.Default or ""), PlaceholderText = opts.Placeholder or "", FontFace = F.Medium(), TextSize = 13, ClearTextOnFocus = opts.ClearOnFocus == true, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = holder })
                    bind(tb, "TextColor3", "Text")
                    bind(tb, "PlaceholderColor3", "Faint")
                    local obj = { Row = row.Frame, Type = "Input", Box = tb }
                    local last = tb.Text
                    tb.Focused:Connect(function()
                        paint(st, "Color", "Accent", "Quick")
                        tween(st, "Quick", { Transparency = 0.25 })
                    end)
                    tb.FocusLost:Connect(function(enter)
                        paint(st, "Color", "Glass", "Quick")
                        tween(st, "Quick", { Transparency = 0.84 })
                        if opts.Numeric and tb.Text ~= "" and not tonumber(tb.Text) then tb.Text = last end
                        if tb.Text ~= last or enter then
                            last = tb.Text
                            safe(opts.Callback, opts.Numeric and tonumber(tb.Text) or tb.Text)
                            safe(opts.Finished, opts.Numeric and tonumber(tb.Text) or tb.Text, enter)
                        end
                    end)
                    if opts.Live then
                        tb:GetPropertyChangedSignal("Text"):Connect(function()
                            if opts.Numeric and tb.Text ~= "" and not tonumber(tb.Text) and tb.Text ~= "-" and tb.Text ~= "." then return end
                            safe(opts.Callback, opts.Numeric and tonumber(tb.Text) or tb.Text)
                        end)
                    end
                    function obj:Set(v)
                        tb.Text = tostring(v or "")
                        last = tb.Text
                    end
                    obj.SetValue = obj.Set
                    function obj:Get() return opts.Numeric and tonumber(tb.Text) or tb.Text end
                    function obj:SetText(t) row.SetText(t) end
                    function obj:SetVisible(v) row.SetVisible(v) end
                    function obj:SetParentHidden(v) row.SetParentHidden(v) end
                    obj.RowObj = row
                    obj.Title = row.Title
                    return obj
                end

                local function hex6(c)
                    return "#" .. string.upper(c:ToHex())
                end

                function Section:Colorpicker(opts)
                    opts = opts or {}
                    local win = self.Window
                    local row = self:_row({ Text = opts.Text, Desc = opts.Desc, Tooltip = opts.Tooltip, Reserve = 150, Indent = opts.Indent, Order = opts.Order, Parent = opts.Parent })
                    local color = typeof(opts.Default) == "Color3" and opts.Default or Color3.new(1, 1, 1)
                    local alpha = math.clamp(tonumber(opts.DefaultAlpha) or 1, 0, 1)
                    local useAlpha = opts.Alpha ~= false
                    local h, s, v = color:ToHSV()

                    local function valueText()
                        if useAlpha and alpha < 0.995 then return hex6(color) .. "  " .. math.floor(alpha * 100 + 0.5) .. "%" end
                        return hex6(color)
                    end
                    local hexLabel = label({ Parent = row.Right, Text = valueText(), Font = F.Semi(), Size = 12, Box = UDim2.new(0, 0, 0, 20), Auto = Enum.AutomaticSize.X, AlignX = Enum.TextXAlignment.Right, Color = "Faint", Z = 3, Name = "Hex" })
                    hexLabel.LayoutOrder = 5
                    local titleNeed
                    local function measureTitle()
                        task.spawn(function()
                            local txt = row.Title.Text
                            local w = U.textWidth(txt, row.Title.FontFace, 14)
                            if row.Title.Text == txt then
                                titleNeed = w
                                if row.fitTitle then row.fitTitle() end
                            end
                        end)
                    end
                    row.OnWidth = function(w)
                        if not titleNeed then return end
                        local hexW = math.max(hexLabel.TextBounds.X / math.max(win.Scale.Scale, 0.1), 52)
                        local fits = w - (10 + row.Indent) - titleNeed - 44 - hexW - 32 >= 0
                        if hexLabel.Visible ~= fits then hexLabel.Visible = fits end
                    end
                    row.Title:GetPropertyChangedSignal("Text"):Connect(measureTitle)
                    row.Title:GetPropertyChangedSignal("FontFace"):Connect(measureTitle)
                    measureTitle()
                    local swatch = new("TextButton", { Name = "Swatch", Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(44, 24), BackgroundTransparency = 1, LayoutOrder = 10, ZIndex = 3, Parent = row.Right })
                    local sscale = new("UIScale", { Parent = swatch })
                    local checker = X.image(swatch, "checker", { Name = "Checker", Size = UDim2.fromScale(1, 1), ZIndex = 3 })
                    if checker then U.corner(checker, 8) end
                    local fill = new("Frame", { Name = "Fill", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = color, BackgroundTransparency = useAlpha and (1 - alpha) or 0, ZIndex = 4, Parent = swatch })
                    U.corner(fill, 8)
                    local gl = X.image(swatch, "gloss9", { Size = UDim2.fromScale(1, 1), SliceScale = 0.57, ImageTransparency = 0.75, ZIndex = 5 })
                    local srim = X.image(swatch, "rim9", { Size = UDim2.fromScale(1, 1), SliceScale = 0.57, ImageTransparency = 0.3, ZIndex = 6 })
                    if srim then bind(srim, "ImageColor3", "Glass") else bind(U.stroke(swatch, WHITE, 1, 0.7), "Color", "Glass") end
                    local obj = { Row = row.Frame, Type = "Colorpicker" }
                    local refreshPopup

                    local function apply(fire)
                        color = Color3.fromHSV(h, s, v)
                        fill.BackgroundColor3 = color
                        fill.BackgroundTransparency = useAlpha and (1 - alpha) or 0
                        hexLabel.Text = valueText()
                        if refreshPopup then refreshPopup() end
                        if fire ~= false then
                            safe(opts.Callback, color, alpha)
                            if obj.Changed then safe(obj.Changed, color, alpha) end
                        end
                    end

                    local function knob(parent, size)
                        local k = new("Frame", { Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundColor3 = color, ZIndex = 10, Parent = parent })
                        U.corner(k, UDim.new(1, 0))
                        U.stroke(k, WHITE, 2, 0, Enum.ApplyStrokeMode.Border)
                        local ring = new("Frame", { Name = "Shade", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 6, 1, 6), BackgroundTransparency = 1, ZIndex = 9, Parent = k })
                        U.corner(ring, UDim.new(1, 0))
                        U.stroke(ring, Color3.new(0, 0, 0), 1, 0.7, Enum.ApplyStrokeMode.Border)
                        return k
                    end

                    local function open()
                        S.play("click")
                        local PAD, SVH = 12, 124
                        local width = 236
                        local IW = width - PAD * 2
                        local rowY = PAD + SVH + 12
                        local fieldY = rowY + 34 + 12
                        local height = fieldY + 28 + PAD
                        local frame, shell, sc = win:PopupShell(width, height)
                        local px, py, _, oy = win:PopupPlace(swatch, width, height, "right")
                        frame.Position = UDim2.fromOffset(px, py)
                        win:PopupReveal(frame, shell, sc, oy == 1)
                        tween(sscale, "Quick", { Scale = 0.94 })
                        local original, originalAlpha = color, alpha

                        local sv = new("TextButton", { Name = "SV", Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(PAD, PAD), Size = UDim2.fromOffset(IW, SVH), BorderSizePixel = 0, BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 5, Parent = shell })
                        U.corner(sv, 9)
                        local white = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = WHITE, ZIndex = 6, Parent = sv })
                        U.corner(white, 9)
                        new("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
                        local black = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 7, Parent = sv })
                        U.corner(black, 9)
                        new("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = black })
                        local svRim = X.image(sv, "rim9", { Size = UDim2.fromScale(1, 1), SliceScale = 0.71, ImageTransparency = 0.6, ZIndex = 8 })
                        if svRim then bind(svRim, "ImageColor3", "Glass") end
                        local cursor = knob(sv, 14)

                        local prev = new("Frame", { Name = "Preview", Position = UDim2.fromOffset(PAD, rowY), Size = UDim2.fromOffset(34, 34), BackgroundTransparency = 1, ZIndex = 5, Parent = shell })
                        local prevCk = X.image(prev, "checker", { Size = UDim2.fromScale(1, 1), ZIndex = 5 })
                        if prevCk then U.corner(prevCk, UDim.new(1, 0)) end
                        local prevFill = new("Frame", { Name = "Fill", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = color, ZIndex = 6, Parent = prev })
                        U.corner(prevFill, UDim.new(1, 0))
                        bind(U.stroke(prevFill, WHITE, 1, 0.75, Enum.ApplyStrokeMode.Border), "Color", "Glass")

                        local barX = PAD + 34 + 14
                        local barW = IW - 48 - 7
                        local hueY = useAlpha and (rowY + 2) or (rowY + 12)
                        local hue = new("TextButton", { Name = "Hue", Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(barX, hueY), Size = UDim2.fromOffset(barW, 10), BorderSizePixel = 0, BackgroundColor3 = WHITE, ZIndex = 5, Parent = shell })
                        U.corner(hue, UDim.new(1, 0))
                        local keys = {}
                        for i = 0, 6 do table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1))) end
                        new("UIGradient", { Color = ColorSequence.new(keys), Parent = hue })
                        local hueKnob = knob(hue, 14)

                        local alphaBar, alphaKnob, alphaCover
                        if useAlpha then
                            alphaBar = new("TextButton", { Name = "Alpha", Text = "", AutoButtonColor = false, Position = UDim2.fromOffset(barX, rowY + 22), Size = UDim2.fromOffset(barW, 10), BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 5, Parent = shell })
                            U.corner(alphaBar, UDim.new(1, 0))
                            local ck = X.image(alphaBar, "checker", { Size = UDim2.fromScale(1, 1), ZIndex = 5 })
                            if ck then U.corner(ck, UDim.new(1, 0)) end
                            alphaCover = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = color, ZIndex = 6, Parent = alphaBar })
                            U.corner(alphaCover, UDim.new(1, 0))
                            new("UIGradient", { Transparency = NumberSequence.new(1, 0), Parent = alphaCover })
                            alphaKnob = knob(alphaBar, 14)
                        end

                        local revertW = 28
                        local aW = useAlpha and 56 or 0
                        local hexW = IW - revertW - 6 - (useAlpha and (aW + 6) or 0)
                        local hexField, hexStroke = Nova.field(shell, { Name = "HexField", Size = UDim2.fromOffset(hexW, 28), Z = 5 })
                        hexField.Position = UDim2.fromOffset(PAD, fieldY)
                        label({ Parent = hexField, Text = "#", Font = F.Semi(), Size = 12, Pos = UDim2.fromOffset(9, 0), Box = UDim2.fromOffset(10, 28), Color = "Faint", Z = 6 })
                        local hexBox = new("TextBox", { BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -26, 1, 0), Text = "", FontFace = F.Semi(), TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = hexField })
                        bind(hexBox, "TextColor3", "Text")

                        local aBox, aStroke
                        if useAlpha then
                            local aField
                            aField, aStroke = Nova.field(shell, { Name = "AlphaField", Size = UDim2.fromOffset(aW, 28), Z = 5 })
                            aField.Position = UDim2.fromOffset(PAD + hexW + 6, fieldY)
                            aBox = new("TextBox", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -24, 1, 0), Text = "", FontFace = F.Semi(), TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6, Parent = aField })
                            bind(aBox, "TextColor3", "Text")
                            label({ Parent = aField, Text = "%", Font = F.Semi(), Size = 12, Anchor = Vector2.new(1, 0), Pos = UDim2.new(1, -8, 0, 0), Box = UDim2.fromOffset(12, 28), AlignX = Enum.TextXAlignment.Right, Color = "Faint", Z = 6 })
                        end

                        local revert, revertStroke = Nova.field(shell, { Class = "TextButton", Name = "Revert", Size = UDim2.fromOffset(revertW, 28), Z = 5 })
                        revert.Position = UDim2.fromOffset(PAD + IW - revertW, fieldY)
                        local revertIcon = icon({ Parent = revert, Icon = "rotate-ccw", Size = 13, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 6 })
                        revert.MouseEnter:Connect(function()
                            paint(revertIcon, "ImageColor3", "Text", "Quick")
                            paint(revertStroke, "Color", "Accent", "Quick")
                            tween(revertStroke, "Quick", { Transparency = 0.5 })
                        end)
                        U.leave(revert, function()
                            paint(revertIcon, "ImageColor3", "Muted", "Quick")
                            paint(revertStroke, "Color", "Glass", "Quick")
                            tween(revertStroke, "Quick", { Transparency = 0.84 })
                        end)

                        local FOLLOW = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        local firstRefresh = true
                        refreshPopup = function()
                            local info = firstRefresh and TweenInfo.new(0) or FOLLOW
                            firstRefresh = false
                            tween(cursor, info, { Position = UDim2.fromScale(s, 1 - v) })
                            cursor.BackgroundColor3 = color
                            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                            tween(hueKnob, info, { Position = UDim2.fromScale(h, 0.5) })
                            hueKnob.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                            prevFill.BackgroundColor3 = color
                            prevFill.BackgroundTransparency = useAlpha and (1 - alpha) or 0
                            if alphaBar then
                                alphaCover.BackgroundColor3 = color
                                tween(alphaKnob, info, { Position = UDim2.fromScale(alpha, 0.5) })
                                alphaKnob.BackgroundColor3 = color
                                if not aBox:IsFocused() then aBox.Text = tostring(math.floor(alpha * 100 + 0.5)) end
                            end
                            if not hexBox:IsFocused() then hexBox.Text = string.sub(hex6(color), 2) end
                        end
                        refreshPopup()

                        local mode = nil
                        local function update(pos)
                            if mode == "sv" then
                                s = U.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
                                v = 1 - U.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
                            elseif mode == "hue" then
                                h = U.clamp((pos.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 0.999)
                            elseif mode == "alpha" and alphaBar then
                                alpha = U.clamp((pos.X - alphaBar.AbsolutePosition.X) / math.max(alphaBar.AbsoluteSize.X, 1), 0, 1)
                            end
                            apply(true)
                        end
                        local modeIn
                        local function grab(which, knobInst, input)
                            mode = which
                            modeIn = input
                            if knobInst then tween(knobInst, "Quick", { Size = UDim2.fromOffset(17, 17) }) end
                        end
                        local function release()
                            for _, k in ipairs({ cursor, hueKnob, alphaKnob }) do
                                if k then tween(k, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(14, 14) }) end
                            end
                            mode = nil
                        end
                        local conns = {}
                        sv.InputBegan:Connect(function(input) if U.isClick(input) then grab("sv", cursor, input) update(input.Position) end end)
                        hue.InputBegan:Connect(function(input) if U.isClick(input) then grab("hue", hueKnob, input) update(input.Position) end end)
                        if alphaBar then alphaBar.InputBegan:Connect(function(input) if U.isClick(input) then grab("alpha", alphaKnob, input) update(input.Position) end end) end
                        table.insert(conns, UIS.InputChanged:Connect(function(input) if mode and U.sameMove(input, modeIn) then update(input.Position) end end))
                        table.insert(conns, UIS.InputEnded:Connect(function(input) if mode and U.sameEnd(input, modeIn) then release() end end))
                        revert.MouseButton1Click:Connect(function()
                            h, s, v = original:ToHSV()
                            alpha = originalAlpha
                            apply(true)
                            S.play("tick")
                            tween(revertIcon, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = -360 })
                            task.delay(0.36, function() revertIcon.Rotation = 0 end)
                        end)
                        hexBox.Focused:Connect(function() paint(hexStroke, "Color", "Accent", "Quick") tween(hexStroke, "Quick", { Transparency = 0.25 }) end)
                        hexBox.FocusLost:Connect(function()
                            paint(hexStroke, "Color", "Glass", "Quick")
                            tween(hexStroke, "Quick", { Transparency = 0.84 })
                            local raw = hexBox.Text
                            local rr, gg, bb = string.match(raw, "^%s*(%d+)%s*[,;%s]%s*(%d+)%s*[,;%s]%s*(%d+)%s*$")
                            if rr then
                                h, s, v = Color3.fromRGB(math.clamp(tonumber(rr), 0, 255), math.clamp(tonumber(gg), 0, 255), math.clamp(tonumber(bb), 0, 255)):ToHSV()
                                apply(true)
                                refreshPopup()
                                return
                            end
                            local txt = raw:gsub("#", ""):gsub("%s", "")
                            if #txt == 3 then txt = txt:sub(1, 1):rep(2) .. txt:sub(2, 2):rep(2) .. txt:sub(3, 3):rep(2) end
                            local ok, c = pcall(Color3.fromHex, txt)
                            if ok and typeof(c) == "Color3" and #txt == 6 then
                                h, s, v = c:ToHSV()
                                apply(true)
                            end
                            refreshPopup()
                        end)
                        if aBox then
                            aBox.Focused:Connect(function() paint(aStroke, "Color", "Accent", "Quick") tween(aStroke, "Quick", { Transparency = 0.25 }) end)
                            aBox.FocusLost:Connect(function()
                                paint(aStroke, "Color", "Glass", "Quick")
                                tween(aStroke, "Quick", { Transparency = 0.84 })
                                local n = tonumber((aBox.Text:gsub("%%", "")))
                                if n then
                                    alpha = math.clamp(n, 0, 100) / 100
                                    apply(true)
                                end
                                refreshPopup()
                            end)
                        end
                        win:OpenPopup({
                            close = function()
                                for _, c in ipairs(conns) do c:Disconnect() end
                                refreshPopup = nil
                                tween(sscale, "Quick", { Scale = 1 })
                                win:PopupConceal(frame, shell)
                                task.delay(0.18, function() frame:Destroy() end)
                            end,
                        })
                    end
                    swatch.MouseButton1Click:Connect(open)
                    swatch.MouseEnter:Connect(function() if not sscale:GetAttribute("open") then tween(sscale, "Quick", { Scale = 1.06 }) end end)
                    U.leave(swatch, function() tween(sscale, "Quick", { Scale = 1 }) end)
                    function obj:Set(c, a)
                        if typeof(c) ~= "Color3" then return end
                        h, s, v = c:ToHSV()
                        if a ~= nil then alpha = math.clamp(tonumber(a) or 1, 0, 1) end
                        apply(true)
                    end
                    obj.SetValue = obj.Set
                    obj.SetValueRGB = obj.Set
                    function obj:SetSilent(c, a)
                        if typeof(c) ~= "Color3" then return end
                        h, s, v = c:ToHSV()
                        if a ~= nil then alpha = math.clamp(tonumber(a) or 1, 0, 1) end
                        apply(false)
                    end
                    function obj:Get() return color, alpha end
                    function obj:SetText(t) row.SetText(t) end
                    function obj:SetVisible(v2) row.SetVisible(v2) end
                    function obj:SetParentHidden(v2) row.SetParentHidden(v2) end
                    obj.RowObj = row
                    obj.Title = row.Title
                    return obj
                end

                function Section:Label(opts)
                    if type(opts) == "string" then opts = { Text = opts } end
                    opts = opts or {}
                    self.Order += 1
                    local frame = new("Frame", { Name = "Label", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = opts.Order or self.Order, Parent = opts.Parent or self.Content })
                    U.pad(frame, 6, 10, 6, 10 + (opts.Indent or 0) * 14)
                    local l = label({ Parent = frame, Text = opts.Text or "", Font = F.Regular(), Size = opts.Size or 13, Box = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y, Wrap = true, Rich = true, Color = opts.Color or "Muted" })
                    local row = { Frame = frame, Title = l, selfHidden = false, parentHidden = false, searchHidden = false }
                    local entry = {
                        text = function() return string.lower(l.Text) end,
                        refresh = function() frame.Visible = not (row.selfHidden or row.parentHidden or row.searchHidden) end,
                    }
                    table.insert(self.Tab.Rows, entry)
                    table.insert(self.Rows, row)
                    row.Entry = entry
                    local obj = { Row = frame, Type = "Label", Label = l }
                    function obj:SetText(t) l.Text = tostring(t) end
                    function obj:SetVisible(v)
                        row.selfHidden = not v
                        entry.refresh()
                    end
                    function obj:SetParentHidden(v)
                        row.parentHidden = v and true or false
                        entry.refresh()
                    end
                    obj.Title = l
                    return obj
                end

                function Section:Paragraph(opts)
                    opts = opts or {}
                    self.Order += 1
                    local frame = new("Frame", { Name = "Paragraph", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = opts.Order or self.Order, Parent = opts.Parent or self.Content })
                    U.pad(frame, 8, 10, 8, 10)
                    U.list(frame, 3)
                    local t = label({ Parent = frame, Text = opts.Title or "", Font = F.Semi(), Size = 14, Box = UDim2.new(1, 0, 0, 18) })
                    local b = label({ Parent = frame, Text = opts.Text or "", Font = F.Regular(), Size = 13, Box = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y, Wrap = true, Rich = true, Color = "Muted" })
                    b.LayoutOrder = 1
                    local obj = { Row = frame, Type = "Paragraph" }
                    function obj:SetTitle(x) t.Text = tostring(x) end
                    function obj:SetText(x) b.Text = tostring(x) end
                    function obj:SetVisible(v) frame.Visible = v end
                    return obj
                end

                function Section:Divider(text)
                    self.Order += 1
                    local frame = new("Frame", { Name = "Divider", Size = UDim2.new(1, 0, 0, text and 30 or 13), BackgroundTransparency = 1, LayoutOrder = self.Order, Parent = self.Content })
                    local line = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -6), Size = UDim2.new(1, -20, 0, 1), BorderSizePixel = 0, Parent = frame })
                    bind(line, "BackgroundColor3", "Line")
                    local l
                    if text then
                        l = label({ Parent = frame, Text = string.upper(text), Font = F.Bold(), Size = 11, Pos = UDim2.fromOffset(10, 4), Box = UDim2.new(1, -20, 0, 14), Color = "Faint" })
                    end
                    local obj = { Row = frame, Type = "Divider", Label = l }
                    function obj:SetText(t) if l then l.Text = string.upper(tostring(t)) end end
                    function obj:SetVisible(v) frame.Visible = v end
                    return obj
                end

                function Section:Container(opts)
                    opts = opts or {}
                    self.Order += 1
                    local frame = new("Frame", { Name = "Container", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = opts.Order or self.Order, Parent = opts.Parent or self.Content })
                    U.pad(frame, opts.Pad or 4, 8, opts.Pad or 4, 8)
                    U.list(frame, opts.Gap or 6)
                    return frame
                end
            end

            do
                local U, M, T, F, I, S, X = Nova.U, Nova.Motion, Nova.Theme, Nova.Font, Nova.Icons, Nova.Sound, Nova.Tex
                local new, tween, bind = U.new, M.tween, T.bind
                local label, icon = Nova.label, Nova.icon
                local Window = Nova.WindowClass

                local KINDS = {
                    info = { token = "Accent", icon = "bell" },
                    success = { token = "Success", icon = "circle-check" },
                    warning = { token = "Warning", icon = "triangle-alert" },
                    danger = { token = "Danger", icon = "circle-x" },
                    error = { token = "Danger", icon = "circle-x" },
                }

                local MIN_H = 52
                local SLIDE_IN = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local SLIDE_OUT = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

                function Window:Notify(opts)
                    if type(opts) == "string" then opts = { Title = opts } end
                    opts = opts or {}
                    local kind = KINDS[string.lower(tostring(opts.Kind or opts.Type or "info"))] or KINDS.info
                    local duration = math.max(tonumber(opts.Duration) or 4, 0.5)
                    if not self.ToastLayout then
                        self.ToastLayout = U.list(self.Toasts, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
                    end
                    self.ToastOrder = (self.ToastOrder or 0) + 1
                    local holder = new("Frame", { Name = "Toast", Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = self.ToastOrder, Parent = self.Toasts })
                    local slide = new("Frame", { Name = "Slide", Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, 0, 0, MIN_H), BackgroundTransparency = 1, Parent = holder })
                    local shadow = X.image(slide, "shadow9", { Name = "Shadow", Position = UDim2.fromOffset(-22, -14), Size = UDim2.new(1, 44, 1, 46), SliceScale = 1, ImageTransparency = 1, ZIndex = 0 })
                    local card = new("CanvasGroup", { Name = "Card", Size = UDim2.new(1, 0, 0, MIN_H), BorderSizePixel = 0, GroupTransparency = 1, Parent = slide })
                    bind(card, "BackgroundColor3", "Surface")
                    U.corner(card, 12)
                    new("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(214, 216, 224)), Rotation = 90, Parent = card })
                    X.image(card, "gloss9", { Name = "Gloss", Size = UDim2.fromScale(1, 1), SliceScale = 0.86, ImageTransparency = 0.92, ZIndex = 1 })
                    local tint = X.image(card, "glow", { Name = "Tint", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 30, 0.5, 0), Size = UDim2.fromOffset(150, 110), ImageTransparency = 0.86, ZIndex = 1 })
                    if tint then bind(tint, "ImageColor3", kind.token) end
                    local rim = X.image(card, "rim9", { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.86, ImageTransparency = 0.5, ZIndex = 9 })
                    if rim then bind(rim, "ImageColor3", "Glass") else bind(U.stroke(card, Color3.new(1, 1, 1), 1, 0.88), "Color", "Glass") end

                    local badge = new("Frame", { Name = "Badge", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 13, 0.5, 0), Size = UDim2.fromOffset(30, 30), BorderSizePixel = 0, BackgroundTransparency = 0.84, ZIndex = 3, Parent = card })
                    bind(badge, "BackgroundColor3", kind.token)
                    U.corner(badge, UDim.new(1, 0))
                    local bst = U.stroke(badge, Color3.new(1, 1, 1), 1, 0.62)
                    bind(bst, "Color", kind.token)
                    icon({ Parent = badge, Icon = opts.Icon or kind.icon, Size = 15, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = kind.token, Z = 4 })

                    local body = new("Frame", { Name = "Body", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 54, 0.5, 0), Size = UDim2.new(1, -86, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 3, Parent = card })
                    U.pad(body, 11, 0, 11, 0)
                    U.list(body, 2)
                    label({ Parent = body, Text = opts.Title or Nova.tr("Notification"), Font = F.Semi(), Size = 14, Box = UDim2.new(1, 0, 0, 17), Truncate = true, Z = 4, Name = "Title" })
                    if opts.Text and opts.Text ~= "" then
                        local t = label({ Parent = body, Text = opts.Text, Font = F.Regular(), Size = 12, Box = UDim2.new(1, 0, 0, 0), Auto = Enum.AutomaticSize.Y, Wrap = true, Rich = true, Color = "Muted", Z = 4, Name = "Text" })
                        t.LayoutOrder = 1
                    end

                    local closeBtn = new("TextButton", { Name = "Close", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(22, 22), ZIndex = 11, Parent = card })
                    local closeFace = new("Frame", { Name = "Face", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 11, Parent = closeBtn })
                    bind(closeFace, "BackgroundColor3", "Elevated")
                    U.corner(closeFace, 7)
                    local closeIcon = icon({ Parent = closeBtn, Icon = "x", Size = 12, Pos = UDim2.fromScale(0.5, 0.5), Anchor = Vector2.new(0.5, 0.5), Color = "Muted", Z = 12 })
                    closeIcon.ImageTransparency = 1

                    local bar = new("Frame", { Name = "Timer", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, BackgroundTransparency = 0.35, ZIndex = 8, Parent = card })
                    bind(bar, "BackgroundColor3", kind.token)

                    local hit = new("TextButton", { Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = card })

                    local function fitCard()
                        local h = math.ceil(body.AbsoluteSize.Y / math.max(self.ToastScale.Scale, 0.1))
                        if h > 0 then
                            local size = UDim2.new(1, 0, 0, math.max(MIN_H, h))
                            card.Size = size
                            slide.Size = size
                        end
                    end
                    body:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitCard)
                    task.defer(fitCard)

                    local gone, hovered = false, false
                    local function dismiss()
                        if gone then return end
                        gone = true
                        tween(slide, SLIDE_OUT, { Position = UDim2.fromOffset(60, 0) })
                        tween(card, SLIDE_OUT, { GroupTransparency = 1 })
                        if shadow then tween(shadow, SLIDE_OUT, { ImageTransparency = 1 }) end
                        task.delay(0.2, function()
                            tween(holder, "Base", { Size = UDim2.new(1, 0, 0, 0) })
                            task.delay(0.28, function() holder:Destroy() end)
                        end)
                    end
                    hit.MouseButton1Click:Connect(function()
                        if opts.OnClick then task.spawn(opts.OnClick) end
                        dismiss()
                    end)
                    closeBtn.MouseButton1Click:Connect(dismiss)
                    local function hover(on)
                        hovered = on
                        tween(closeIcon, "Quick", { ImageTransparency = on and 0.1 or 1 })
                        tween(closeFace, "Quick", { BackgroundTransparency = on and 0.35 or 1 })
                        if rim then tween(rim, "Quick", { ImageTransparency = on and 0.3 or 0.5 }) end
                    end
                    hit.MouseEnter:Connect(function() hover(true) end)
                    U.leave(hit, function() hover(false) end)
                    closeBtn.MouseEnter:Connect(function()
                        hover(true)
                        tween(closeIcon, "Quick", { ImageColor3 = T.resolve("Text") })
                    end)
                    U.leave(closeBtn, function()
                        tween(closeIcon, "Quick", { ImageColor3 = T.resolve("Muted") })
                    end)

                    local function fit(animated)
                        if gone then return end
                        local h = slide.AbsoluteSize.Y / math.max(self.ToastScale.Scale, 0.1)
                        if animated then
                            tween(holder, "Base", { Size = UDim2.new(1, 0, 0, h) })
                        else
                            holder.Size = UDim2.new(1, 0, 0, h)
                        end
                    end
                    slide:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() fit(false) end)
                    task.defer(function()
                        task.wait()
                        fit(true)
                        tween(slide, SLIDE_IN, { Position = UDim2.fromOffset(0, 0) })
                        tween(card, SLIDE_IN, { GroupTransparency = 0 })
                        if shadow then tween(shadow, SLIDE_IN, { ImageTransparency = 0.45 }) end
                        local left = duration
                        while not gone and left > 0 do
                            local dt = task.wait()
                            if not hovered then left -= dt end
                            bar.Size = UDim2.new(math.clamp(left / duration, 0, 1), 0, 0, 2)
                        end
                        dismiss()
                    end)
                    if opts.Sound ~= false then S.play("notify") end
                    return { Dismiss = dismiss }
                end

                function Nova:Notify(opts)
                    local w = Nova.Windows[#Nova.Windows]
                    if w and not w.Destroyed then return w:Notify(opts) end
                    return nil
                end
            end

            do
                local U, M, T, F, I, S, X = Nova.U, Nova.Motion, Nova.Theme, Nova.Font, Nova.Icons, Nova.Sound, Nova.Tex
                local new, tween, bind = U.new, M.tween, T.bind
                local label, icon, paint, safe = Nova.label, Nova.icon, Nova.paint, Nova.safe
                local Window, Section = Nova.WindowClass, Nova.SectionClass
                local WHITE = Color3.new(1, 1, 1)

                function Section:Palette(opts)
                    opts = opts or {}
                    local win = self.Window
                    local list = {}
                    for _, o in ipairs(opts.Options or {}) do
                        if type(o) == "table" and typeof(o[2]) == "Color3" then table.insert(list, { name = o[1], color = o[2] }) end
                    end
                    local row = self:_row({ Text = opts.Text, Desc = "", Height = 74, Reserve = 0, Name = "Palette", Order = opts.Order, Parent = opts.Parent })
                    if row.Desc then row.Desc.Visible = false end
                    row.Title.Position = UDim2.fromOffset(10, 9)
                    row.Title.Size = UDim2.new(1, -20, 0, 18)
                    local strip = new("Frame", { Name = "Swatches", Position = UDim2.fromOffset(10, 36), Size = UDim2.new(1, -20, 0, 30), BackgroundTransparency = 1, ZIndex = 3, Parent = row.Frame })
                    U.list(strip, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
                    local nameLabel = label({ Parent = row.Frame, Text = "", Font = F.Semi(), Size = 12, Anchor = Vector2.new(1, 0), Pos = UDim2.new(1, -10, 0, 10), Box = UDim2.fromOffset(120, 16), AlignX = Enum.TextXAlignment.Right, Color = "Muted", Z = 3 })
                    local obj = { Type = "Palette", Row = row.Frame, Items = {} }
                    local current

                    local function mark(name, animate)
                        current = name
                        for n, it in pairs(obj.Items) do
                            local on = n == name
                            tween(it.ring, animate and "Base" or TweenInfo.new(0), { Transparency = on and 0 or 1 })
                            tween(it.scale, animate and "PopSmall" or TweenInfo.new(0), { Scale = on and 1 or 0.86 })
                            tween(it.check, animate and "Base" or TweenInfo.new(0), { ImageTransparency = on and 0 or 1 })
                        end
                        nameLabel.Text = name or ""
                    end

                    for i, o in ipairs(list) do
                        local b = new("TextButton", { Name = o.name, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(28, 28), LayoutOrder = i, ZIndex = 3, Parent = strip })
                        local sc = new("UIScale", { Scale = 0.86, Parent = b })
                        local halo = X.image(b, "glow", { Name = "Halo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(64, 64), ImageTransparency = 1, ImageColor3 = o.color, ZIndex = 2 })
                        local dot = new("Frame", { Name = "Dot", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.72, 0.72), BorderSizePixel = 0, BackgroundColor3 = o.color, ZIndex = 4, Parent = b })
                        U.corner(dot, UDim.new(1, 0))
                        new("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 190, 200)), Rotation = 90, Parent = dot })
                        local gl = X.image(dot, "gloss9", { Size = UDim2.fromScale(1, 1), SliceScale = 0.7, ImageTransparency = 0.7, ZIndex = 5 })
                        local ringHolder = new("Frame", { Name = "Ring", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = b })
                        U.corner(ringHolder, UDim.new(1, 0))
                        local ring = U.stroke(ringHolder, o.color, 2, 1, Enum.ApplyStrokeMode.Border)
                        local check = new("ImageLabel", { Name = "Check", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, ImageColor3 = WHITE, ImageTransparency = 1, Visible = false, ZIndex = 6, Parent = dot })
                        I.apply(check, "check")
                        obj.Items[o.name] = { ring = ring, scale = sc, check = check, halo = halo, button = b }
                        b.MouseEnter:Connect(function()
                            if current ~= o.name then tween(sc, "Quick", { Scale = 1.1 }) end
                            if halo then tween(halo, "Quick", { ImageTransparency = 0.72 }) end
                            S.play("hover", 0.4)
                            nameLabel.Text = o.name
                        end)
                        U.leave(b, function()
                            if current ~= o.name then tween(sc, "Quick", { Scale = 0.86 }) end
                            if halo then tween(halo, "Quick", { ImageTransparency = 1 }) end
                            nameLabel.Text = current or ""
                        end)
                        b.MouseButton1Click:Connect(function()
                            S.play("tick")
                            mark(o.name, true)
                            safe(opts.Callback, o.name, o.color)
                            if obj.Changed then safe(obj.Changed, o.name, o.color) end
                        end)
                    end
                    row.OnWidth = function(w)
                        local n = math.max(#list, 1)
                        local cell = math.floor(U.clamp((w - 20 - (n - 1) * 8) / n, 18, 28))
                        for _, it in pairs(obj.Items) do it.button.Size = UDim2.fromOffset(cell, cell) end
                    end
                    function obj:Set(name, silent)
                        if not obj.Items[name] then mark(nil, true) return end
                        mark(name, true)
                        if not silent then
                            for _, o in ipairs(list) do
                                if o.name == name then safe(opts.Callback, o.name, o.color) end
                            end
                        end
                    end
                    obj.SetValue = obj.Set
                    function obj:SetSilent(name) obj:Set(name, true) end
                    function obj:Get() return current end
                    function obj:SetVisible(v) row.SetVisible(v) end
                    function obj:SetParentHidden(v) row.SetParentHidden(v) end
                    obj.RowObj = row
                    obj.Title = row.Title
                    local start = opts.Default
                    if typeof(start) == "Color3" then
                        for _, o in ipairs(list) do
                            if o.color:ToHex() == start:ToHex() then start = o.name break end
                        end
                    end
                    for n, it in pairs(obj.Items) do it.check.Visible = true end
                    mark(obj.Items[start] and start or nil, false)
                    return obj
                end

                local function presetList()
                    local out = {}
                    local order = { "Crimson", "Ember", "Gold", "Mint", "Ocean", "Violet", "Rose", "Ice" }
                    for _, n in ipairs(order) do
                        if T.Presets[n] then table.insert(out, { n, T.Presets[n] }) end
                    end
                    for n, c in pairs(T.Presets) do
                        local seen = false
                        for _, o in ipairs(out) do if o[1] == n then seen = true end end
                        if not seen then table.insert(out, { n, c }) end
                    end
                    return out
                end

                function Window:AddAppearance(tab, opts)
                    opts = opts or {}
                    local st = self.State
                    local refs = {}
                    self.AppearanceRefs = refs

                    local look = tab:Section({ Title = "Interface", Icon = "layout-panel-left", Sub = opts.Sub, Side = opts.Side1 })
                    if not opts.SkipKey then
                        refs.key = look:Keybind({ Text = "Menu key", Default = self.Key, Callback = function(k) if k then self:SetKey(k) end end })
                        self:OnKeyChanged(function(k) if refs.key and refs.key.Get and refs.key:Get() ~= k then refs.key:Set(k) end end)
                    end
                    refs.scale = look:Slider({ Text = "UI scale", Min = 0.6, Max = 1.4, Decimals = 2, Default = self.UserScale, Suffix = "x", Callback = function() end, Released = function(v) self:SetScale(v) end })
                    refs.autofit = look:Toggle({ Text = "Fit to screen", Default = self.AutoFit, Callback = function(v) self:SetAutoFit(v) end })
                    refs.radius = look:Slider({ Text = "Corner radius", Min = 0, Max = 2, Decimals = 2, Default = tonumber(st.get("radius", 1)) or 1, Suffix = "x", Callback = function(v) self:SetCornerRadius(v) end })
                    refs.textScale = look:Slider({ Text = "Text size", Min = 0.85, Max = 1.25, Decimals = 2, Default = tonumber(st.get("textScale", 1)) or 1, Suffix = "x", Callback = function(v) self:SetTextScale(v) end })
                    local fonts = {}
                    for _, f in ipairs(F.Families) do table.insert(fonts, f[1]) end
                    refs.font = look:Dropdown({ Text = "Font", Options = fonts, Default = F.name, Callback = function(v) self:SetFont(v) end })
                    refs.opacity = look:Slider({ Text = "Window opacity", Min = 0.5, Max = 1, Decimals = 2, Default = self.Opacity, Callback = function(v) self:SetOpacity(v) end })
                    refs.sbWidth = look:Slider({ Text = "Sidebar width", Min = 188, Max = 340, Decimals = 0, Default = self.ExpandedWidth, Suffix = " px", Callback = function() end, Released = function(v) self:SetSidebarWidth(v) end })
                    self.OnSidebarWidth = function(w) if refs.sbWidth then refs.sbWidth:SetSilent(w) end end
                    refs.density = look:Dropdown({ Text = "Sidebar density", Options = Window.Densities, Default = self.Density, Callback = function(v) self:SetDensity(v) end })
                    refs.compact = look:Toggle({ Text = "Compact sidebar", Default = self.SidebarCollapsed == true, Callback = function(v) self:SetSidebarCollapsed(v) end })
                    self.OnSidebarChanged = function(v) if refs.compact then refs.compact:SetSilent(v) end end
                    refs.groupLabels = look:Toggle({ Text = "Group labels", Default = self.GroupLabels ~= false, Callback = function(v) self:SetGroupLabels(v) end })
                    self.OnGroupLabels = function(v) if refs.groupLabels then refs.groupLabels:SetSilent(v) end end

                    local theme = tab:Section({ Title = "Theme", Icon = "palette", Sub = opts.Sub, Side = opts.Side2 })
                    refs.palette = theme:Palette({ Text = "Accent", Options = presetList(), Default = T.tokens.Accent, Callback = function(_, c) self:SetAccent(c) if refs.accent then refs.accent:SetSilent(c) end end })
                    refs.accent = theme:Colorpicker({ Text = "Custom accent", Alpha = false, Default = T.tokens.Accent, Callback = function(c) self:SetAccent(c) if refs.palette then refs.palette:Set(nil, true) end end })
                    local styles = {}
                    for _, s in ipairs(Window.BackgroundStyles) do table.insert(styles, s) end
                    local bases = {}
                    for _, b in ipairs(T.Bases) do table.insert(bases, b[1]) end
                    refs.base = theme:Dropdown({ Text = "Base theme", Options = bases, Default = T.base, Callback = function(v)
                        self:SetBase(v)
                        if refs.panel then refs.panel:SetSilent(T.tokens.Background) end
                    end })
                    refs.panel = theme:Colorpicker({ Text = "Panel color", Alpha = false, Default = T.tokens.Background, Callback = function(c)
                        self:SetPanelColor(c)
                        if refs.base then refs.base:SetSilent("Custom") end
                    end })
                    local cardStyles = {}
                    for _, c in ipairs(Window.CardStyles) do table.insert(cardStyles, c) end
                    refs.cards = theme:Dropdown({ Text = "Card style", Options = cardStyles, Default = self.CardStyle, Callback = function(v) self:SetCardStyle(v) end })
                    refs.bg = theme:Dropdown({ Text = "Background", Options = styles, Default = self.BgStyle, Callback = function(v) self:SetBackground(v) end })
                    refs.bgInt = theme:Slider({ Text = "Background intensity", Min = 0, Max = 1.5, Decimals = 2, Default = self.BgIntensity, Callback = function(v) self:SetBackgroundIntensity(v) end })
                    refs.blur = theme:Toggle({ Text = "Blur behind menu", Default = self.BlurEnabled, Callback = function(v) self:SetBlur(v) end })

                    local fx = tab:Section({ Title = "Behavior", Icon = "sliders-horizontal", Sub = opts.Sub, Side = opts.Side3 })
                    refs.motion = fx:Toggle({ Text = "Animations", Default = M.enabled, Callback = function(v) self:SetMotion(v) end })
                    refs.sounds = fx:Toggle({ Text = "Interface sounds", Default = S.enabled, Callback = function(v) self:SetSounds(v) end })
                    refs.volume = fx:Slider({ Text = "Sound volume", Min = 0, Max = 1, Decimals = 2, Default = S.volume, Callback = function(v) self:SetVolume(v) end })
                    refs.tips = fx:Toggle({ Text = "Tooltips", Default = self.TooltipsOn, Callback = function(v) self:SetTooltips(v) end })
                    refs.launcher = fx:Toggle({ Text = "Launcher button", Default = self.LauncherOn, Callback = function(v) self:SetLauncher(v) end })
                    if opts.Overlays ~= false then
                        refs.watermark = fx:Toggle({ Text = "Show FPS / Ping", Default = st.get("watermark", false) == true, Callback = function(v) self:SetWatermark(v) end })
                        refs.kblist = fx:Toggle({ Text = "Keybind list", Default = st.get("keybindList", self.IsTouch == true) == true, Callback = function(v) self:SetKeybindList(v) end })
                    end
                    local tr = opts.Translate or function(text) return text end
                    refs.reset = fx:Button({ Text = "Reset appearance", Icon = "rotate-ccw", DoubleClick = true, Callback = function()
                        self:ResetAppearance()
                        self:SyncAppearance()
                        self:Notify({ Title = tr("Appearance reset"), Kind = "success" })
                    end })
                    return { look, theme, fx }
                end

                function Window:SyncAppearance()
                    local r = self.AppearanceRefs
                    if not r then return end
                    local st = self.State
                    r.scale:SetSilent(self.UserScale)
                    if r.autofit then r.autofit:SetSilent(self.AutoFit) end
                    r.radius:SetSilent(tonumber(st.get("radius", 1)) or 1)
                    r.textScale:SetSilent(tonumber(st.get("textScale", 1)) or 1)
                    r.font:SetSilent(F.name)
                    r.opacity:SetSilent(self.Opacity)
                    r.density:SetSilent(self.Density)
                    r.sbWidth:SetSilent(self.ExpandedWidth)
                    r.compact:SetSilent(self.SidebarCollapsed == true)
                    if r.groupLabels then r.groupLabels:SetSilent(self.GroupLabels ~= false) end
                    r.palette:Set(nil, true)
                    for name, c in pairs(T.Presets) do
                        if c:ToHex() == T.tokens.Accent:ToHex() then r.palette:Set(name, true) end
                    end
                    r.accent:SetSilent(T.tokens.Accent)
                    r.base:SetSilent(T.base)
                    r.panel:SetSilent(self.PanelColor or T.tokens.Background)
                    r.cards:SetSilent(self.CardStyle)
                    r.bg:SetSilent(self.BgStyle)
                    r.bgInt:SetSilent(self.BgIntensity)
                    r.blur:SetSilent(self.BlurEnabled)
                    r.motion:SetSilent(M.enabled)
                    r.sounds:SetSilent(S.enabled)
                    r.volume:SetSilent(S.volume)
                    r.tips:SetSilent(self.TooltipsOn)
                    r.launcher:SetSilent(self.LauncherOn)
                    if r.watermark then r.watermark:SetSilent(st.get("watermark", false) == true) end
                    if r.kblist then r.kblist:SetSilent(st.get("keybindList", false) == true) end
                end
            end

            do
                local U, M, T, F, I, S, X = Nova.U, Nova.Motion, Nova.Theme, Nova.Font, Nova.Icons, Nova.Sound, Nova.Tex
                local new, tween, bind = U.new, M.tween, T.bind
                local label, icon = Nova.label, Nova.icon
                local Window = Nova.WindowClass
                local UIS, RunService = Nova.Services.UserInputService, Nova.Services.RunService
                local WHITE = Color3.new(1, 1, 1)

                local function makeShell(win, name, pos, auto)
                    local frame = new("Frame", { Name = name, Position = pos, Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Visible = false, ZIndex = 6, Parent = win.Gui })
                    local shadow = X.image(frame, "shadow9", { Name = "Shadow", Position = UDim2.fromOffset(-24, -16), Size = UDim2.new(1, 48, 1, 52), SliceScale = 1, ImageTransparency = 0.5, ZIndex = 5 })
                    local card = new("Frame", { Name = "Card", Size = auto and UDim2.new(0, 0, 1, 0) or UDim2.fromScale(1, 1), AutomaticSize = auto and Enum.AutomaticSize.X or Enum.AutomaticSize.None, BorderSizePixel = 0, BackgroundTransparency = 0.04, ZIndex = 6, Parent = frame })
                    bind(card, "BackgroundColor3", "Surface")
                    U.corner(card, 11)
                    new("UIGradient", { Color = ColorSequence.new(WHITE, Color3.fromRGB(208, 210, 218)), Rotation = 90, Parent = card })
                    X.image(card, "gloss9", { Name = "Gloss", Size = UDim2.fromScale(1, 1), SliceScale = 0.79, ImageTransparency = 0.9, ZIndex = 6 })
                    local rim = X.image(card, "rim9", { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.79, ImageTransparency = 0.45, ZIndex = 12 })
                    if rim then bind(rim, "ImageColor3", "Glass") else bind(U.stroke(card, WHITE, 1, 0.85), "Color", "Glass") end
                    local sc = new("UIScale", { Parent = frame })
                    local function keep()
                        if not frame.Parent then return end
                        local vp = workspace.CurrentCamera.ViewportSize
                        local p, sz = frame.Position, frame.AbsoluteSize
                        if sz.X <= 0 or sz.Y <= 0 then return end
                        local x = math.clamp(p.X.Offset, 4, math.max(4, vp.X - sz.X - 4))
                        local y = math.clamp(p.Y.Offset, 4, math.max(4, vp.Y - sz.Y - 4))
                        if x ~= p.X.Offset or y ~= p.Y.Offset then frame.Position = UDim2.fromOffset(x, y) end
                    end
                    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.defer(keep) end)
                    frame:GetPropertyChangedSignal("Visible"):Connect(function() if frame.Visible then task.defer(keep) end end)
                    win:OnScreenScale(function(s)
                        if not frame.Parent then return false end
                        sc.Scale = s
                        task.defer(keep)
                    end)
                    return frame, card
                end

                local function draggable(win, handle, frame, key)
                    local dragging, start, origin, dragIn = false, nil, nil, nil
                    handle.InputBegan:Connect(function(input)
                        if not U.isClick(input) then return end
                        dragging, start, origin, dragIn = true, input.Position, frame.Position, input
                        local conn
                        conn = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                                conn:Disconnect()
                                local p = frame.Position
                                win.State.data[key] = { math.floor(p.X.Offset), math.floor(p.Y.Offset) }
                                win.State.save()
                            end
                        end)
                    end)
                    U.connect(UIS.InputChanged, function(input)
                        if dragging and U.sameMove(input, dragIn) then
                            local d = input.Position - start
                            local vp = workspace.CurrentCamera.ViewportSize
                            local x = math.clamp(origin.X.Offset + d.X, 4, math.max(4, vp.X - frame.AbsoluteSize.X - 4))
                            local y = math.clamp(origin.Y.Offset + d.Y, 4, math.max(4, vp.Y - frame.AbsoluteSize.Y - 4))
                            frame.Position = UDim2.fromOffset(x, y)
                        end
                    end, win.Conns)
                end

                local function savedPos(win, key, default)
                    local v = win.State.get(key, nil)
                    if type(v) == "table" and tonumber(v[1]) and tonumber(v[2]) then return UDim2.fromOffset(v[1], v[2]) end
                    return default
                end

                function Window:SetWatermark(on)
                    Nova.trace("SetWatermark")
                    on = on and true or false
                    self.State.set("watermark", on)
                    if on then
                        if not self.WatermarkFrame then self:_buildWatermark() end
                        self.WatermarkFrame.Visible = true
                    elseif self.WatermarkFrame then
                        self.WatermarkFrame.Visible = false
                    end
                end

                function Window:SetWatermarkTitle(text)
                    self.WatermarkTitleText = text
                    local l = self.WatermarkTitle
                    if not l then return end
                    if text then
                        if l.AutomaticSize ~= Enum.AutomaticSize.None then
                            l.AutomaticSize = Enum.AutomaticSize.None
                            l.Size = UDim2.new(0, 38, 1, 0)
                            l.TextXAlignment = Enum.TextXAlignment.Center
                        end
                        if l.Text ~= text then l.Text = text end
                    else
                        local def = tostring(self.TitleLabel and self.TitleLabel.Text or "Nova")
                        if l.AutomaticSize ~= Enum.AutomaticSize.X then
                            l.Size = UDim2.new(0, 0, 1, 0)
                            l.AutomaticSize = Enum.AutomaticSize.X
                            l.TextXAlignment = Enum.TextXAlignment.Left
                        end
                        if l.Text ~= def then l.Text = def end
                    end
                end

                local function health(v, good, bad, invert)
                    if invert then
                        if v <= good then return "Success" elseif v <= bad then return "Warning" end
                        return "Danger"
                    end
                    if v >= good then return "Success" elseif v >= bad then return "Warning" end
                    return "Danger"
                end

                local function readPing()
                    local ms
                    pcall(function() ms = Nova.Services.Players.LocalPlayer:GetNetworkPing() * 1000 end)
                    if not ms then
                        pcall(function()
                            ms = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                        end)
                    end
                    return ms
                end

                function Window:_buildWatermark()
                    local frame, card = makeShell(self, "Watermark", savedPos(self, "watermarkPos", UDim2.fromOffset(16, 16)), true)
                    frame.Size = UDim2.fromOffset(0, 34)
                    U.corner(card, 12)
                    local row = new("Frame", { Name = "Row", Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 7, Parent = card })
                    U.pad(row, 0, 12, 0, 8)
                    U.list(row, 10, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
                    local logo = new("Frame", { Name = "Logo", Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, LayoutOrder = 1, ZIndex = 7, Parent = row })
                    if self.LogoAsset then
                        new("ImageLabel", { Name = "Mark", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(26, 26), Image = self.LogoAsset, ScaleType = Enum.ScaleType.Fit, ZIndex = 8, Parent = logo })
                    else
                        Nova.tile(logo, { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Accent", SliceScale = 0.4, Z = 7 })
                        label({ Parent = logo, Text = tostring(self.Initial or "N"), Font = F.Heavy(), Size = 11, Box = UDim2.fromScale(1, 1), AlignX = Enum.TextXAlignment.Center, Color = "OnAccent", Z = 9 })
                    end
                    local wmTitle = label({ Parent = row, Text = tostring(self.TitleLabel and self.TitleLabel.Text or "Nova"), Font = F.Bold(), Size = 13, Box = UDim2.new(0, 0, 1, 0), Auto = Enum.AutomaticSize.X, Z = 8, Name = "Title" })
                    wmTitle.LayoutOrder = 2
                    self.WatermarkTitle = wmTitle
                    if self.WatermarkTitleText then self:SetWatermarkTitle(self.WatermarkTitleText) end
                    local function sep(order)
                        local s = new("Frame", { Name = "Sep", Size = UDim2.fromOffset(1, 14), BorderSizePixel = 0, BackgroundTransparency = 0.82, LayoutOrder = order, ZIndex = 8, Parent = row })
                        bind(s, "BackgroundColor3", "Glass")
                    end
                    local function stat(order, iconName, suffix, width)
                        local seg = new("Frame", { Name = "Stat", Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = order, ZIndex = 8, Parent = row })
                        U.list(seg, 5, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
                        local ic = icon({ Parent = seg, Icon = iconName, Size = 14, Color = "Muted", Z = 8 })
                        ic.LayoutOrder = 1
                        local val = label({ Parent = seg, Text = "--", Font = F.Bold(), Size = 13, Box = UDim2.new(0, width, 1, 0), AlignX = Enum.TextXAlignment.Right, Color = "Text", Z = 8, Name = "Value" })
                        val.LayoutOrder = 2
                        local suf = label({ Parent = seg, Text = suffix, Font = F.Medium(), Size = 10, Box = UDim2.new(0, 0, 1, 0), Auto = Enum.AutomaticSize.X, Color = "Faint", Z = 8, Name = "Suffix" })
                        suf.LayoutOrder = 3
                        return { icon = ic, value = val, tone = nil }
                    end
                    sep(3)
                    local fps = stat(4, "gauge", "FPS", 28)
                    sep(5)
                    local ping = stat(6, "wifi", "MS", 30)
                    local function tone(seg, token)
                        if seg.tone == token then return end
                        seg.tone = token
                        Nova.paint(seg.icon, "ImageColor3", token, "Base")
                        Nova.paint(seg.value, "TextColor3", token, "Base")
                    end
                    draggable(self, card, frame, "watermarkPos")
                    if self.State.get("watermarkPos", nil) == nil then
                        task.defer(function()
                            local vp = workspace.CurrentCamera.ViewportSize
                            local wv = card.AbsoluteSize.X
                            if wv > 0 then frame.Position = UDim2.fromOffset(math.floor(vp.X - wv - 16), 16) end
                        end)
                    end
                    local frames, t0 = 0, os.clock()
                    U.connect(RunService.RenderStepped, function()
                        if not frame.Visible then
                            frames, t0 = 0, os.clock()
                            return
                        end
                        frames += 1
                        local now = os.clock()
                        local span = now - t0
                        if span >= 0.5 then
                            local f = math.floor(frames / span + 0.5)
                            frames, t0 = 0, now
                            fps.value.Text = tostring(f)
                            tone(fps, health(f, 55, 30, false))
                            local ms = readPing()
                            if ms then
                                local m = math.floor(ms + 0.5)
                                ping.value.Text = tostring(m)
                                tone(ping, health(m, 90, 180, true))
                            else
                                ping.value.Text = "--"
                            end
                        end
                    end, self.Conns)
                    self.WatermarkFrame = frame
                    frame.Visible = false
                end

                local KW, KHEAD, KROW, KGAP, KMAXH = 190, 32, 26, 3, 280
                local KB_ICONS = {
                    { "Fly", "plane" }, { "Spin", "rotate-cw" }, { "Bhop", "rabbit" }, { "Invisible", "eye-off" },
                    { "Shot Murder", "crosshair" }, { "Pick Up Gun", "hand-grab" }, { "Menu key", "menu" }, { "No Clip", "ghost" }, { "Wall Hop", "arrow-up-from-line" }, { "Infinite Jumps", "chevrons-up" },
                    { "Auto Bomb Jump", "bomb" }, { "Bomb Jump", "bomb" },
                }
                local function kbIcon(name)
                    for _, e in ipairs(KB_ICONS) do
                        if name == e[1] or name == Nova.tr(e[1]) then return e[2] end
                    end
                    return "keyboard"
                end
                local KB_WHITE, KB_DIM, KB_BADGE = Color3.new(1, 1, 1), Color3.fromRGB(200, 203, 214), Color3.fromRGB(16, 16, 20)

                local function call(fn, ...)
                    if type(fn) ~= "function" then return false, nil end
                    return pcall(fn, ...)
                end

                function Window:RegisterKeybind(entry)
                    self.KeybindEntries = self.KeybindEntries or {}
                    table.insert(self.KeybindEntries, entry)
                    self:_kbDirty()
                end

                function Window:_kbDirty()
                    if self.KbPending or self.Destroyed then return end
                    self.KbPending = true
                    task.defer(function()
                        self.KbPending = false
                        if self.KeybindFrame and not self.Destroyed then self:_kbRebuild() end
                    end)
                end

                function Window:SetKeybindList(on)
                    Nova.trace("SetKeybindList")
                    on = on and true or false
                    self.State.set("keybindList", on)
                    if on then
                        if not self.KeybindFrame then self:_buildKeybindList() end
                        self.KeybindFrame.Visible = true
                        self:_kbRebuild(true)
                    elseif self.KeybindFrame then
                        self:_kbCancel()
                        self.KeybindFrame.Visible = false
                    end
                end

                function Window:_kbCapture(r)
                    if self.KbCap == r then return end
                    self:_kbCancel()
                    self.KbCap = r
                    r.capture(true)
                    task.defer(function() if self.KbCap == r then self.Listening = true end end)
                end

                function Window:_kbCancel()
                    local r = self.KbCap
                    if not r then return end
                    self.KbCap = nil
                    r.capture(false)
                    task.defer(function() if not self.KbCap then self.Listening = false end end)
                end

                local function kbRow(win, entry)
                    local r = { entry = entry, on = false }
                    local touch = win.IsTouch == true
                    local canToggle = type(entry.toggle) == "function"
                    local fr = new("TextButton", { Name = "Entry", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, KROW), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 8, Parent = win.KeybindList })
                    local bar = new("Frame", { Name = "Bar", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 0), BorderSizePixel = 0, ZIndex = 9, Parent = fr })
                    U.corner(bar, UDim.new(1, 0))
                    bind(bar, "BackgroundColor3", "Accent")
                    local slide = new("Frame", { Name = "Slide", Position = UDim2.fromOffset(5, 0), Size = UDim2.new(1, -5, 1, 0), BackgroundTransparency = 1, ZIndex = 8, Parent = fr })
                    local bg = new("Frame", { Name = "Bg", Size = UDim2.fromScale(1, 1), BackgroundColor3 = KB_WHITE, BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = 8, Parent = slide })
                    U.corner(bg, UDim.new(1, 0))
                    new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.6, 0.3), NumberSequenceKeypoint.new(1, 0.85) }), Parent = bg })
                    local ic = new("Frame", { Name = "Ic", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0.5, 0), Size = UDim2.fromOffset(KROW - 8, KROW - 8), BackgroundColor3 = KB_WHITE, BackgroundTransparency = 0.87, BorderSizePixel = 0, ZIndex = 9, Parent = slide })
                    U.corner(ic, UDim.new(1, 0))
                    local ist = new("UIStroke", { Color = KB_WHITE, Transparency = 0.75, Thickness = 1, Parent = ic })
                    local glyph = new("ImageLabel", { Name = "Glyph", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(11, 11), BackgroundTransparency = 1, ImageColor3 = KB_WHITE, Visible = false, ZIndex = 10, Parent = ic })
                    Nova.Icons.apply(glyph, "keyboard")
                    local NX = KROW + 2
                    local nm = new("TextLabel", { Name = "Name", BackgroundTransparency = 1, Position = UDim2.fromOffset(NX, 0), Size = UDim2.new(1, -(NX + 60), 1, 0), FontFace = F.Semi(), TextSize = 11, TextColor3 = KB_DIM, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", ZIndex = 10, Parent = slide })
                    local SWW, SWH = 24, 14
                    local sw = new("TextButton", { Name = "Switch", Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -5, 0.5, 0), Size = UDim2.fromOffset(SWW, SWH), BackgroundColor3 = KB_WHITE, BackgroundTransparency = 0.8, BorderSizePixel = 0, Visible = canToggle, ZIndex = 10, Parent = slide })
                    U.corner(sw, UDim.new(1, 0))
                    local knob = new("Frame", { Name = "Knob", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(SWH - 4, SWH - 4), BackgroundColor3 = KB_WHITE, BorderSizePixel = 0, ZIndex = 11, Parent = sw })
                    U.corner(knob, UDim.new(1, 0))
                    local KEYR = 5 + SWW + 5
                    local chip = new("TextButton", { Name = "Key", Text = "", AutoButtonColor = false, BackgroundColor3 = KB_WHITE, BackgroundTransparency = 0.88, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -KEYR, 0.5, 0), Size = UDim2.fromOffset(18, 15), BorderSizePixel = 0, Visible = not touch, ZIndex = 10, Parent = slide })
                    U.corner(chip, 4)
                    local cst = new("UIStroke", { Color = KB_WHITE, Transparency = 0.8, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = chip })
                    local kl = new("TextLabel", { Name = "Text", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), FontFace = F.Bold(), TextSize = 10, TextColor3 = KB_WHITE, Text = "", ZIndex = 11, Parent = chip })
                    local hovered, pulse, iconName = false, nil, nil
                    r.frame = fr

                    local function fit(txt, instant)
                        local w = math.max(18, math.floor(#txt * 6 + 10))
                        kl.Text = txt
                        local size = UDim2.fromOffset(w, 15)
                        if instant then chip.Size = size else tween(chip, "Quick", { Size = size }) end
                        local right = touch and KEYR or (KEYR + w + 6)
                        nm.Size = UDim2.new(1, -(NX + right), 1, 0)
                    end

                    local function apply(instant)
                        local info = instant and TweenInfo.new(0) or "Quick"
                        local on, hot = r.on, hovered and win.KbCap ~= r
                        local acc = T.resolve("Accent")
                        tween(bg, info, { BackgroundColor3 = on and acc or KB_WHITE, BackgroundTransparency = on and (hot and 0.08 or 0.2) or (hot and 0.85 or 0.92) })
                        tween(slide, info, { Position = UDim2.fromOffset(hot and 8 or 5, 0) })
                        tween(bar, info, { Size = UDim2.fromOffset(3, on and 14 or (hot and 8 or 0)) })
                        tween(ic, info, { BackgroundTransparency = on and 0 or (hot and 0.78 or 0.87) })
                        tween(ist, info, { Transparency = on and 1 or 0.75 })
                        tween(glyph, info, { ImageColor3 = on and acc or KB_WHITE, ImageTransparency = (on or hot) and 0 or 0.15 })
                        tween(nm, info, { TextColor3 = (on or hot) and KB_WHITE or KB_DIM })
                        tween(sw, info, { BackgroundTransparency = on and 0 or 0.8 })
                        tween(knob, info, { Position = on and UDim2.new(1, -(SWH - 2), 0.5, 0) or UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = on and acc or KB_WHITE })
                        if win.KbCap ~= r then
                            tween(chip, info, { BackgroundTransparency = on and 0.72 or 0.88 })
                            tween(cst, info, { Color = KB_WHITE, Transparency = on and 0.55 or 0.8 })
                            tween(kl, info, { TextTransparency = r.key and 0 or 0.55 })
                        end
                    end

                    function r.refresh(instant)
                        local okK, k = call(entry.key)
                        if not okK or typeof(k) ~= "EnumItem" then k = nil end
                        if k == nil and win.KbCap ~= r and not win.KbEdit and not touch then return true end
                        local okL, live = true, true
                        if entry.alive then okL, live = call(entry.alive) end
                        if okL and live == false then return true end
                        local okN, n = call(entry.name)
                        n = okN and tostring(n) or ""
                        if nm.Text ~= n then
                            nm.Text = n
                            local want = kbIcon(n)
                            if want ~= iconName then
                                iconName = want
                                Nova.Icons.apply(glyph, want)
                            end
                        end
                        local okA, a = call(entry.active)
                        a = okA and a and true or false
                        local changed = r.key ~= k and r.key ~= nil and not touch
                        local keyFlip = (r.key == nil) ~= (k == nil)
                        r.key = k
                        if a ~= r.on or instant or keyFlip then
                            r.on = a
                            apply(instant)
                        end
                        if win.KbCap ~= r then
                            local t = k and Nova.keyName(k) or "\226\128\148"
                            if t ~= r.keyTxt then
                                r.keyTxt = t
                                fit(t, instant)
                            end
                        end
                        return changed
                    end

                    function r.capture(on)
                        if on then
                            r.keyTxt = nil
                            fit("\226\128\166")
                            tween(kl, "Quick", { TextTransparency = 0 })
                            tween(cst, "Quick", { Color = T.resolve("Accent"), Transparency = 0 })
                            if pulse then pulse:Cancel() end
                            pulse = Nova.Services.TweenService:Create(cst, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.6 })
                            pulse:Play()
                        else
                            if pulse then pulse:Cancel() pulse = nil end
                            r.keyTxt = nil
                            r.refresh()
                            apply()
                        end
                    end

                    local function flip()
                        if win.KbCap or not canToggle then return end
                        Nova.safe(entry.toggle)
                        task.defer(function() if r.refresh() then win:_kbDirty() end end)
                    end
                    fr.MouseEnter:Connect(function()
                        hovered = true
                        apply()
                    end)
                    U.leave(fr, function()
                        hovered = false
                        apply()
                    end)
                    fr.MouseButton1Click:Connect(flip)
                    sw.MouseButton1Click:Connect(flip)
                    chip.MouseEnter:Connect(function()
                        if win.KbCap ~= r then tween(chip, "Quick", { BackgroundTransparency = 0.66 }) end
                    end)
                    U.leave(chip, function()
                        if win.KbCap ~= r then tween(chip, "Quick", { BackgroundTransparency = r.on and 0.72 or 0.88 }) end
                    end)
                    chip.MouseButton1Click:Connect(function()
                        if not entry.set or win.KbCap == r or os.clock() - (win.KbBoundAt or 0) < 0.3 then return end
                        S.play("click")
                        win:_kbCapture(r)
                    end)
                    chip.MouseButton2Click:Connect(function()
                        if not entry.set or win.KbCap or os.clock() - (win.KbBoundAt or 0) < 0.3 then return end
                        S.play("tick")
                        Nova.safe(entry.set, nil)
                        win:_kbRebuild()
                    end)
                    r.apply = apply
                    r.refresh(true)
                    apply(true)
                    return r
                end

                local function kbButton(parent, iconName, pos, touch)
                    local D, H = touch and 24 or 18, touch and 34 or 18
                    local b = new("TextButton", { Name = "Btn", Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = touch and (pos + UDim2.fromOffset(math.floor((H - D) / 2), 0)) or pos, Size = UDim2.fromOffset(H, H), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 9, Parent = parent })
                    local face = new("Frame", { Name = "Face", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(D, D), BackgroundColor3 = KB_WHITE, BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 9, Parent = b })
                    U.corner(face, UDim.new(1, 0))
                    local st = new("UIStroke", { Color = KB_WHITE, Transparency = 0.78, Thickness = 1, Parent = face })
                    local ic = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(touch and 13 or 10, touch and 13 or 10), BackgroundTransparency = 1, ImageColor3 = KB_WHITE, Visible = false, ZIndex = 10, Parent = face })
                    Nova.Icons.apply(ic, iconName)
                    local lit, hover = false, false
                    local function look()
                        local acc = T.resolve("Accent")
                        tween(face, "Quick", { BackgroundColor3 = lit and KB_WHITE or KB_WHITE, BackgroundTransparency = lit and 0 or (hover and 0.78 or 0.88) })
                        tween(st, "Quick", { Transparency = lit and 1 or 0.78 })
                        tween(ic, "Quick", { ImageColor3 = lit and acc or KB_WHITE })
                    end
                    b.MouseEnter:Connect(function() hover = true look() end)
                    U.leave(b, function() hover = false look() end)
                    return b, ic, function(v) if v ~= nil then lit = v and true or false end look() end
                end

                function Window:_buildKeybindList()
                    local frame, card = makeShell(self, "KeybindList", savedPos(self, "keybindPos", UDim2.fromOffset(16, 190)))
                    frame.AutomaticSize = Enum.AutomaticSize.None
                    frame.Size = UDim2.fromOffset(KW, KHEAD + 30)
                    card.AutomaticSize = Enum.AutomaticSize.None
                    card.ClipsDescendants = true
                    U.corner(card, 14)
                    local head = new("Frame", { Name = "Head", Size = UDim2.new(1, 0, 0, KHEAD), BackgroundTransparency = 1, ZIndex = 7, Parent = card })
                    local tl = new("TextLabel", { Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(11, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, FontFace = F.Bold(), TextSize = 13, TextColor3 = KB_WHITE, TextXAlignment = Enum.TextXAlignment.Left, Text = Nova.tr("Keybinds"), ZIndex = 8, Parent = head })
                    local pill = new("Frame", { Name = "Count", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 11 + math.ceil(tl.TextBounds.X) + 7, 0.5, 0), Size = UDim2.fromOffset(0, 15), AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, ZIndex = 8, Parent = head })
                    bind(pill, "BackgroundColor3", "Accent")
                    U.corner(pill, UDim.new(1, 0))
                    local count = new("TextLabel", { Name = "Value", BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, FontFace = F.Bold(), TextSize = 10, Text = "0/0", ZIndex = 9, Parent = pill })
                    bind(count, "TextColor3", "OnAccent")
                    U.pad(count, 0, 6, 0, 6)
                    tl:GetPropertyChangedSignal("TextBounds"):Connect(function()
                        pill.Position = UDim2.new(0, 11 + math.ceil(tl.TextBounds.X) + 7, 0.5, 0)
                    end)
                    local fold, foldIc = kbButton(head, self.State.get("keybindFold", false) == true and "chevron-down" or "chevron-up", UDim2.new(1, -8, 0.5, 0), self.IsTouch)
                    local edit, _, editLit = kbButton(head, "pencil", UDim2.new(1, -30, 0.5, 0), self.IsTouch)
                    edit.Visible = not self.IsTouch
                    local list = new("ScrollingFrame", { Name = "List", Position = UDim2.fromOffset(0, KHEAD), Size = UDim2.new(1, 0, 1, -KHEAD), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 7, Parent = card })
                    bind(list, "ScrollBarImageColor3", "Faint")
                    U.list(list, KGAP)
                    U.pad(list, 5, 6, 6, 5)
                    local empty = label({ Parent = list, Text = "\226\128\148", Font = F.Medium(), Size = 11, Box = UDim2.new(1, 0, 0, 18), AlignX = Enum.TextXAlignment.Center, Color = "Faint", Z = 8, Name = "Empty" })
                    empty.LayoutOrder = 1e6
                    draggable(self, head, frame, "keybindPos")
                    self.KeybindFrame, self.KeybindCard, self.KeybindList = frame, card, list
                    self.KbRows, self.KbEmpty, self.KbCountLabel = {}, empty, count
                    self.KbEdit = false
                    self.KbFold = self.State.get("keybindFold", false) == true
                    T.onChange(function(key)
                        if key ~= "Accent" or self.Destroyed or not self.KbRows then return end
                        for _, r in pairs(self.KbRows) do
                            if r.apply and r.frame.Parent then pcall(r.apply) end
                        end
                        pcall(editLit)
                    end)

                    edit.MouseButton1Click:Connect(function()
                        S.play("click")
                        self:_kbCancel()
                        self.KbEdit = not self.KbEdit
                        if self.KbEdit and self.KbFold then
                            self.KbFold = false
                            self.State.set("keybindFold", false)
                            Nova.Icons.apply(foldIc, "chevron-up")
                        end
                        editLit(self.KbEdit)
                        self:_kbRebuild()
                    end)
                    fold.MouseButton1Click:Connect(function()
                        S.play("tick")
                        self:_kbCancel()
                        self.KbFold = not self.KbFold
                        if self.KbFold and self.KbEdit then
                            self.KbEdit = false
                            editLit(false)
                        end
                        self.State.set("keybindFold", self.KbFold)
                        Nova.Icons.apply(foldIc, self.KbFold and "chevron-down" or "chevron-up")
                        self:_kbRebuild()
                    end)

                    U.connect(UIS.InputBegan, function(input)
                        local r = self.KbCap
                        if not r or not self.Listening then return end
                        local t = input.UserInputType
                        local k
                        if t == Enum.UserInputType.Keyboard then
                            local kc = input.KeyCode
                            if kc == Enum.KeyCode.Escape then self:_kbCancel() return end
                            if kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then
                                S.play("tick")
                                Nova.safe(r.entry.set, nil)
                                self:_kbCancel()
                                self:_kbRebuild()
                                return
                            end
                            if kc ~= Enum.KeyCode.Unknown then k = kc end
                        elseif t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then
                            k = t
                            self.KbBoundAt = os.clock()
                        elseif t == Enum.UserInputType.MouseButton1 then
                            self.KbBoundAt = os.clock()
                            self:_kbCancel()
                            return
                        elseif t == Enum.UserInputType.Touch then
                            self:_kbCancel()
                            return
                        end
                        if k then
                            S.play("tick")
                            Nova.safe(r.entry.set, k)
                            self:_kbCancel()
                            self:_kbRebuild()
                        end
                    end, self.Conns)

                    local acc = 0
                    U.connect(RunService.Heartbeat, function(dt)
                        if self.Destroyed or not frame.Visible then return end
                        acc += dt
                        if acc < 0.08 then return end
                        acc = 0
                        local dirty, act, total = false, 0, 0
                        for _, r in pairs(self.KbRows) do
                            if r.refresh() then dirty = true end
                            if r.key or self.IsTouch then
                                total += 1
                                if r.on then act += 1 end
                            end
                        end
                        if dirty then self:_kbDirty() else self:_kbCount(act, total) end
                    end, self.Conns)
                end

                function Window:_kbCount(act, total)
                    local lbl = self.KbCountLabel
                    if not lbl then return end
                    local txt = tostring(act) .. "/" .. tostring(total)
                    if lbl.Text ~= txt then lbl.Text = txt end
                end

                function Window:_kbRebuild(instant)
                    local frame = self.KeybindFrame
                    if not frame or self.Destroyed then return end
                    local live = {}
                    for _, e in ipairs(self.KeybindEntries or {}) do
                        local ok, a = true, true
                        if e.alive then ok, a = call(e.alive) end
                        if not ok or a ~= false then table.insert(live, e) end
                    end
                    self.KeybindEntries = live
                    local rows, used, show = self.KbRows, {}, {}
                    local shown, total, act = 0, 0, 0
                    for i, e in ipairs(live) do
                        local okK, k = call(e.key)
                        if not okK or typeof(k) ~= "EnumItem" then k = nil end
                        local okN, n = call(e.name)
                        local nmTxt = okN and tostring(n) or ""
                        local id = nmTxt .. "|" .. (k and tostring(k) or (self.KbEdit and "" or "-"))
                        local capturing = self.KbCap ~= nil and self.KbCap.entry == e
                        local want
                        if self.IsTouch then
                            id = nmTxt
                            want = type(e.toggle) == "function" and nmTxt ~= "" and not used[id]
                        else
                            want = capturing or (k ~= nil and not used[id]) or (self.KbEdit and e.set ~= nil and nmTxt ~= "" and not used[id])
                        end
                        if want then
                            used[id] = true
                            show[e] = true
                            local r = rows[e]
                            if not r then
                                r = kbRow(self, e)
                                rows[e] = r
                            else
                                r.refresh()
                            end
                            r.frame.LayoutOrder = ((k or self.IsTouch) and 0 or 100000) + i
                            shown += 1
                            if k or self.IsTouch then
                                total += 1
                                if r.on then act += 1 end
                            end
                        end
                    end
                    local drop = {}
                    for e in pairs(rows) do
                        if not show[e] then table.insert(drop, e) end
                    end
                    for _, e in ipairs(drop) do
                        local r = rows[e]
                        rows[e] = nil
                        if self.KbCap == r then self:_kbCancel() end
                        r.frame:Destroy()
                    end
                    self.KbEmpty.Visible = shown == 0
                    self:_kbCount(act, total)
                    local fold = self.KbFold == true
                    self.KeybindList.Visible = not fold
                    local body = shown > 0 and (shown * KROW + (shown - 1) * KGAP) or 18
                    local h = fold and KHEAD or (KHEAD + math.min(5 + body + 6, KMAXH))
                    local size = UDim2.fromOffset(KW, h)
                    if instant or not frame.Visible then frame.Size = size else tween(frame, "Base", { Size = size }) end
                end
            end

            return Nova
end)()

local Fs = {}
function Fs.folder(p)
    pcall(function()
        if makefolder and isfolder and not isfolder(p) then makefolder(p) end
    end)
end
Fs.folder("PulseHub")
Fs.folder("PulseHub/nova")
Fs.folder("PulseHubKukirin")
function Fs.b64(text)
    for _, fn in ipairs({ crypt and crypt.base64decode, crypt and crypt.base64 and crypt.base64.decode, base64decode, base64_decode, base64 and base64.decode }) do
        if type(fn) == "function" then
            local ok, r = pcall(fn, text)
            if ok and type(r) == "string" and #r > 0 then return r end
        end
    end
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {}
    for i = 1, 64 do map[string.byte(chars, i)] = i - 1 end
    local out, n, acc, bits = {}, 0, 0, 0
    for i = 1, #text do
        local v = map[string.byte(text, i)]
        if v then
            acc = acc * 64 + v
            bits += 6
            if bits >= 8 then
                bits -= 8
                local p = 2 ^ bits
                n += 1
                out[n] = string.char(math.floor(acc / p) % 256)
                acc = acc % p
            end
        end
    end
    return table.concat(out)
end
function Fs.asset(path, data)
    local ok, a = pcall(function()
        if not (writefile and getcustomasset) then return nil end
        if not (isfile and isfile(path)) then writefile(path, Fs.b64(data)) end
        return getcustomasset(path)
    end)
    if ok and type(a) == "string" and a ~= "" then return a end
    return nil
end

local CFG = "PulseHubKukirin/config.json"
local S = {
    autoDrive = false, driveSpeed = 97, driveSpot = "City Lot", wheelie = false,
    autoDelivery = false, autoQuests = false, autoPumpkins = false,
    autoBuy = false, spawnBest = true, autoCodes = false, codesDone = {}, autoRace = false,
    wsOn = false, walkSpeed = 32, jpOn = false, jumpPower = 75, infJump = false, noclip = false, antiAfk = true,
    espPlayers = false, espPumpkins = false, espDelivery = false, fullbright = false, noFog = false,
}
pcall(function()
    if isfile and isfile(CFG) then
        local d = Http:JSONDecode(readfile(CFG))
        if type(d) == "table" then
            for k, v in pairs(d) do
                if S[k] ~= nil and type(v) == type(S[k]) then S[k] = v end
            end
        end
    end
end)
K.saving = false
K.S = S
local function save()
    if K.saving then return end
    K.saving = true
    task.delay(0.8, function()
        K.saving = false
        pcall(function() writefile(CFG, Http:JSONEncode(S)) end)
    end)
end
local function set(k, v)
    S[k] = v
    save()
end

local Kk = {}
function Kk.cash()
    local ls = lp:FindFirstChild("leaderstats")
    local c = ls and ls:FindFirstChild("Cash")
    return c and tonumber(c.Value) or 0
end
function Kk.money(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return "$" .. out:gsub("^,", "")
end
function Kk.clock(sec)
    sec = math.max(0, math.floor(sec))
    return string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
end
function Kk.scooter()
    for _, m in ipairs(workspace:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("OwnerUserId") == lp.UserId and m:FindFirstChild("Body") then return m end
    end
    return nil
end
function Kk.mounted()
    return lp:GetAttribute("ScooterMountedForControls") == true
end
function Kk.root()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
function Kk.hum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
function Kk.parts(m)
    local t = {}
    for _, p in ipairs(m:GetDescendants()) do
        if p:IsA("BasePart") then t[#t + 1] = p end
    end
    return t
end
function Kk.still(m)
    for _, p in ipairs(Kk.parts(m)) do
        p.AssemblyLinearVelocity = Vector3.zero
        p.AssemblyAngularVelocity = Vector3.zero
    end
end
function Kk.yaw(cf)
    local _, y = cf:ToOrientation()
    return CFrame.Angles(0, y, 0)
end
function Kk.ignore()
    local t = {}
    for _, m in ipairs(workspace:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("OwnerUserId") ~= nil then t[#t + 1] = m end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then t[#t + 1] = p.Character end
    end
    return t
end
function Kk.ground(pos, up, down)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = Kk.ignore()
    local hit = workspace:Raycast(pos + Vector3.new(0, up or 8, 0), Vector3.new(0, -((up or 8) + (down or 40)), 0), rp)
    if hit then return Vector3.new(pos.X, hit.Position.Y, pos.Z) end
    return pos
end
function Kk.beside(root, dist)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = Kk.ignore()
    local cf = root.CFrame
    for _, dir in ipairs({ cf.LookVector, cf.RightVector, -cf.RightVector, -cf.LookVector }) do
        local flat = Vector3.new(dir.X, 0, dir.Z)
        if flat.Magnitude > 0.1 then
            flat = flat.Unit
            local o = root.Position + Vector3.new(0, 1, 0)
            if not workspace:Raycast(o, flat * (dist + 3), rp) then return root.Position + flat * dist end
        end
    end
    return root.Position + Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit * dist
end
function Kk.goto(pos, rot)
    local m = Kk.mounted() and Kk.scooter()
    if m then
        m:PivotTo(CFrame.new(pos + Vector3.new(0, 2.5, 0)) * (rot or Kk.yaw(m:GetPivot())))
        Kk.still(m)
        return true
    end
    local r = Kk.root()
    if r then
        r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) * (rot or Kk.yaw(r.CFrame))
        r.AssemblyLinearVelocity = Vector3.zero
        return true
    end
    return false
end
function Kk.owned(name)
    local f = lp:FindFirstChild("OwnedScooters")
    local v = f and f:FindFirstChild(name)
    return v ~= nil and v:IsA("BoolValue") and v.Value == true
end
function Kk.catalog()
    local list = {}
    local f = RS:FindFirstChild("Scooters")
    for _, m in ipairs(f and f:GetChildren() or {}) do
        local price = tonumber(m:GetAttribute("ShopPrice"))
        if m:IsA("Model") and price and price >= 0 and m:GetAttribute("HideFromShop") ~= true then
            list[#list + 1] = { name = m.Name, price = price, kmh = tonumber(m:GetAttribute("TopSpeedKmh")) or 0 }
        end
    end
    table.sort(list, function(a, b)
        if a.price == b.price then return a.kmh < b.kmh end
        return a.price < b.price
    end)
    return list
end
function Kk.best()
    local best
    for _, s in ipairs(Kk.catalog()) do
        if Kk.owned(s.name) and (not best or s.kmh > best.kmh) then best = s end
    end
    return best
end
function Kk.spawn(name)
    local old = Kk.scooter()
    pcall(function() Remotes.SpawnScooter:FireServer(name) end)
    for _ = 1, 60 do
        task.wait(0.1)
        local m = Kk.scooter()
        if m and m ~= old and m.Name == name then return m end
    end
    return Kk.scooter()
end
function Kk.trigger(pr, check, wait1)
    if not pr then return false end
    pcall(function()
        pr:InputHoldBegin()
        task.wait(math.max(tonumber(pr.HoldDuration) or 0, 0) + 0.05)
        pr:InputHoldEnd()
    end)
    for _ = 1, math.floor((wait1 or 1.2) * 10) do
        task.wait(0.1)
        if check() then return true end
    end
    pcall(fireproximityprompt, pr)
    for _ = 1, 20 do
        task.wait(0.1)
        if check() then return true end
    end
    return false
end
function Kk.mount()
    if Kk.mounted() then return Kk.scooter() end
    for attempt = 1, 3 do
        local m = Kk.scooter()
        if not m or attempt > 1 then
            local b = Kk.best()
            local name = (S.spawnBest and b and b.name) or (m and m.Name) or (b and b.name)
            if name then m = Kk.spawn(name) end
            task.wait(0.6)
        end
        local r = Kk.root()
        if m and m:FindFirstChild("Body") and r then
            r.CFrame = m.Body.CFrame * CFrame.new(3, 2, 0)
            r.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.4)
            if Kk.trigger(m:FindFirstChild("MountPrompt", true), Kk.mounted, 1.2) then return Kk.scooter() end
        end
        if not K.alive then return nil end
    end
    return nil
end

if not G.__pulseKukInputHook and hookmetamethod and getnamecallmethod and newcclosure and checkcaller then
    local SI = Remotes:FindFirstChild("ScooterInput")
    if SI then
        G.__pulseKukInputHook = true
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            if self == SI and not checkcaller() and getnamecallmethod() == "FireServer" then
                local k = G.__pulseKuk
                local f = type(k) == "table" and k.input
                if type(f) == "function" then
                    local ok, packet = pcall(f)
                    if ok and type(packet) == "table" then return old(self, packet) end
                end
            end
            return old(self, ...)
        end))
    end
end

local Ctl = { ok = false, state = {} }
function Ctl.load()
    if Ctl.ok then return true end
    if not (getgc and debug and debug.info and debug.getupvalue and debug.setupvalue) then return false end
    local by = {}
    for _, f in ipairs(getgc(false)) do
        if type(f) == "function" and islclosure(f) then
            local ok, src, line = pcall(debug.info, f, "sl")
            if ok and type(src) == "string" and line and line >= 383 and line <= 390 and src:find("ScooterClient", 1, true) and not src:find("Replicator", 1, true) then
                by[line] = by[line] or {}
                table.insert(by[line], f)
            end
        end
    end
    local function pair(line)
        local t = by[line]
        if not t or #t ~= 2 then return nil end
        local a, b = t[1], t[2]
        local ok = pcall(a)
        if not ok then return nil end
        if debug.getupvalue(a, 1) == true then
            pcall(b)
            return a, b
        end
        return b, a
    end
    local f = {}
    f.leftOn, f.leftOff = pair(383)
    f.rightOn, f.rightOff = pair(384)
    f.thrOn, f.thrOff = pair(385)
    f.brakeOn, f.brakeOff = pair(386)
    f.lift = by[387] and #by[387] == 1 and by[387][1]
    f.liftOff = by[390] and #by[390] == 1 and by[390][1]
    if not (f.leftOn and f.rightOn and f.thrOn and f.brakeOn and f.lift and f.liftOff) then return false end
    Ctl.f = f
    Ctl.state = {}
    Ctl.ok = true
    return true
end
function Ctl.set(key, on)
    if Ctl.state[key] == on then return end
    Ctl.state[key] = on
    if on then Ctl.active = true end
    local f = Ctl.f
    if key == "lift" then
        pcall(debug.setupvalue, f.lift, 1, on)
        pcall(debug.setupvalue, f.lift, 2, 0)
        return
    end
    local fn = f[key .. (on and "On" or "Off")]
    if fn then pcall(fn) end
end
function Ctl.release()
    if not (Ctl.ok and Ctl.active) then return end
    Ctl.active = false
    for _, k in ipairs({ "lift", "brake", "left", "right", "thr" }) do
        Ctl.state[k] = nil
        Ctl.set(k, false)
    end
end
function Ctl.alive()
    if not Ctl.ok then return false end
    Ctl.state.thr = nil
    Ctl.set("thr", true)
    task.wait(0.25)
    local v = tonumber(lp:GetAttribute("ScooterLocalThrottle")) or 0
    if v > 0 then return true end
    Ctl.ok = false
    return Ctl.load()
end

local Drive = { conn = nil, SPOTS = { Vector3.new(1600, 0, -1325), Vector3.new(1875, 0, -1600), Vector3.new(1675, 0, -1875) }, R = 32, center = nil }
Drive.SPOT = Drive.SPOTS[1]
function Drive.clear(x, z, R)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local ex = Kk.ignore()
    local pn = workspace:FindFirstChild("PumpkinNight")
    if pn then ex[#ex + 1] = pn end
    rp.FilterDescendantsInstances = ex
    local N = 64
    local minY, maxY = math.huge, -math.huge
    for i = 0, N - 1 do
        local a = i / N * math.pi * 2
        for _, rr in ipairs({ R - 10, R - 5, R, R + 5, R + 10 }) do
            local h = workspace:Raycast(Vector3.new(x + math.cos(a) * rr, 150, z + math.sin(a) * rr), Vector3.new(0, -200, 0), rp)
            if not h then return false end
            minY, maxY = math.min(minY, h.Position.Y), math.max(maxY, h.Position.Y)
            if maxY - minY > 0.8 then return false end
        end
    end
    for _, rr in ipairs({ R - 10, R, R + 10 }) do
        local pts = {}
        for i = 0, N - 1 do
            local a = i / N * math.pi * 2
            pts[i + 1] = Vector3.new(x + math.cos(a) * rr, 0, z + math.sin(a) * rr)
        end
        for i = 1, N do
            local a, b = pts[i], pts[i % N + 1]
            local dir = (b - a).Unit
            for _, hy in ipairs({ 0.8, 2.5, 5 }) do
                if workspace:Raycast(a + Vector3.new(0, minY + hy, 0), (b - a) + dir * 2, rp) then return false end
            end
        end
    end
    return true, minY
end
function Drive.find(origin)
    local ok, y = Drive.clear(origin.X, origin.Z, Drive.R)
    if ok then return Vector3.new(origin.X, y, origin.Z) end
    local step = 25
    for ring = 1, 10 do
        local best, bestD
        for i = -ring, ring do
            for j = -ring, ring do
                if math.max(math.abs(i), math.abs(j)) == ring then
                    local x, z = origin.X + i * step, origin.Z + j * step
                    local ok2, y2 = Drive.clear(x, z, Drive.R)
                    if ok2 then
                        local d = i * i + j * j
                        if not bestD or d < bestD then best, bestD = Vector3.new(x, y2, z), d end
                    end
                end
            end
            task.wait()
        end
        if best then return best end
        if not (K.alive and S.autoDrive) then return nil end
    end
    return nil
end
function Drive.pick()
    if S.driveSpot == "Current Position" then
        local m = Kk.scooter()
        local base = (m and m:GetPivot().Position) or (Kk.root() and Kk.root().Position)
        return base and Drive.find(base)
    end
    for _, s in ipairs(Drive.SPOTS) do
        local ok, y = Drive.clear(s.X, s.Z, Drive.R)
        if ok then return Vector3.new(s.X, y, s.Z) end
    end
    return Drive.find(Drive.SPOT)
end
function Drive.place(m)
    local c = Drive.center
    local p = c + Vector3.new(Drive.R, 1.5, 0)
    m:PivotTo(CFrame.lookAt(p, p + Vector3.new(0, 0, 1)))
    Kk.still(m)
end
function Drive.stop()
    if Drive.conn then
        Drive.conn:Disconnect()
        Drive.conn = nil
    end
    Ctl.release()
    if K.input then
        K.input = nil
        pcall(function() Remotes.ScooterInput:FireServer({ throttle = 0, brake = 0, steer = 0, dismount = false, wheelie = 0, stamp = os.clock() }) end)
        local m = Kk.scooter()
        if m then pcall(Kk.still, m) end
    end
end
function Drive.start()
    if Drive.conn then return true end
    if not Drive.center then
        K.task = "Finding a clear spot"
        Drive.center = Drive.pick()
        if not Drive.center then
            K.task = "No clear spot"
            Drive.retryAt = os.clock() + 10
            return false
        end
    end
    local m = Kk.mount()
    if not m then
        Drive.retryAt = os.clock() + 3
        return false
    end
    if not (Ctl.load() and Ctl.alive()) then return Drive.startTp(m) end
    Drive.place(m)
    task.wait(0.2)
    local body = m:FindFirstChild("Body")
    if not body then return false end
    local center, R = Drive.center, Drive.R
    local st = { lastA = 0, rate = 0, slow = 0, t = 0 }
    Ctl.set("thr", true)
    Drive.mode = "Real"
    Drive.conn = Run.Heartbeat:Connect(function(dt)
        if not body.Parent or not Kk.mounted() or lp:GetAttribute("InRace") == true then
            Drive.stop()
            return
        end
        st.t += dt
        Ctl.set("thr", true)
        local cf = body.CFrame
        local p = cf.Position
        local r = Vector3.new(p.X - center.X, 0, p.Z - center.Z)
        local d = r.Magnitude
        local speed = Vector3.new(body.AssemblyLinearVelocity.X, 0, body.AssemblyLinearVelocity.Z).Magnitude
        if speed < 3 and st.t > 3 then st.slow += dt else st.slow = 0 end
        if d > R + 30 or st.slow > 2.5 then
            st.slow, st.t = 0, 0
            Ctl.set("lift", false)
            Ctl.set("brake", false)
            Drive.place(m)
            return
        end
        local ru = d > 0.1 and r / d or Vector3.new(1, 0, 0)
        local tan = Vector3.new(-ru.Z, 0, ru.X)
        local want = (tan - ru * math.clamp((d - R) / 12, -1.2, 1.2)).Unit
        local h = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        h = h.Magnitude > 0.01 and h.Unit or want
        local y = h:Cross(want).Y
        Ctl.set("left", y > 0.06)
        Ctl.set("right", y < -0.06)
        local a = math.deg(math.atan2(cf.LookVector.Y, cf.UpVector.Y))
        st.rate += ((a - st.lastA) / math.max(dt, 1e-3) - st.rate) * 0.35
        st.lastA = a
        if S.wheelie and st.t > 2.5 and speed > 8 then
            local pred = a + st.rate * 0.35
            Ctl.set("lift", pred < 20)
            Ctl.set("brake", pred > 26)
        else
            Ctl.set("lift", false)
            Ctl.set("brake", a > 6)
        end
    end)
    return true
end
function Drive.packet()
    return { throttle = 1, brake = 0, steer = 0, dismount = false, wheelie = S.wheelie and 1 or 0, stamp = os.clock() }
end
function Drive.startTp(m)
    local center, R = Drive.center, 48
    local parts = Kk.parts(m)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = Kk.ignore()
    local ang, beat, refresh, t = 0, 0, 0, 0
    K.input = Drive.packet
    Drive.mode = "Teleport"
    Drive.conn = Run.Heartbeat:Connect(function(dt)
        if not m.Parent or not Kk.mounted() then
            Drive.stop()
            return
        end
        t += dt
        refresh += dt
        if refresh > 2 then
            refresh = 0
            rp.FilterDescendantsInstances = Kk.ignore()
        end
        local kmh = tonumber(m:GetAttribute("TopSpeedKmh")) or 25
        local v = kmh / 3.6 / 0.28 * 0.97
        ang += v / R * dt
        local c, s = math.cos(ang), math.sin(ang)
        local p = center + Vector3.new(c * R, 0, s * R)
        local dir = Vector3.new(-s, 0, c)
        local hit = workspace:Raycast(p + Vector3.new(0, 30, 0), Vector3.new(0, -90, 0), rp)
        p = Vector3.new(p.X, (hit and hit.Position.Y or center.Y) + (S.wheelie and 1.7 or 1.2), p.Z)
        local cf = CFrame.lookAt(p, p + dir)
        if S.wheelie then cf = cf * CFrame.Angles(math.rad(30 + 4 * math.sin(t * 1.7)), 0, 0) end
        m:PivotTo(cf)
        local vel = dir * v
        for _, part in ipairs(parts) do
            part.AssemblyLinearVelocity = vel
            part.AssemblyAngularVelocity = Vector3.zero
        end
        beat += dt
        if beat >= 0.12 then
            beat = 0
            pcall(function() Remotes.ScooterInput:FireServer(Drive.packet()) end)
        end
    end)
    return true
end

local Race = { phase = "Idle", last = nil, conn = nil, earned = 0, count = 0 }
function Race.fire(...)
    local args = { ... }
    pcall(function() Remotes.RaceRemote:FireServer(table.unpack(args)) end)
end
function Race.answer(delay)
    task.delay(delay or 0.8, function()
        if not (K.alive and S.autoRace and Race.phase == "Invite") then return end
        if not Kk.mounted() then
            Drive.stop()
            K.busy = true
            pcall(Kk.mount)
            K.busy = false
        end
        if Race.phase == "Invite" then Race.fire("Answer", true) end
    end)
end
function Race.nextIn()
    local now = workspace:GetServerTimeNow()
    local admin = workspace:GetAttribute("AdminRaceAt")
    if type(admin) == "number" and admin > now - 1 then return admin - now end
    return math.ceil(now / 300) * 300 - now
end
function Race.stop()
    if Race.conn then
        Race.conn:Disconnect()
        Race.conn = nil
        Ctl.release()
    end
end
function Race.drive()
    Race.stop()
    if not Ctl.load() then return end
    local m = Kk.scooter()
    local body = m and m:FindFirstChild("Body")
    if not body then return end
    local look = body.CFrame.LookVector
    local dir = Vector3.new(look.X, 0, look.Z)
    if dir.Magnitude < 0.1 then return end
    dir = dir.Unit
    local t0 = os.clock()
    Ctl.set("thr", true)
    Race.conn = Run.Heartbeat:Connect(function()
        if not body.Parent or Race.phase ~= "Racing" or os.clock() - t0 > 60 then
            Race.stop()
            return
        end
        local cf = body.CFrame
        local h = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        h = h.Magnitude > 0.01 and h.Unit or dir
        local y = h:Cross(dir).Y
        Ctl.set("thr", true)
        Ctl.set("left", y > 0.02)
        Ctl.set("right", y < -0.02)
        local a = math.deg(math.atan2(cf.LookVector.Y, cf.UpVector.Y))
        Ctl.set("brake", a > 6)
    end)
end
if Remotes:FindFirstChild("RaceRemote") then
    conn(Remotes.RaceRemote.OnClientEvent, function(kind, data)
        data = type(data) == "table" and data or {}
        if kind == "Invite" then
            Race.phase = "Invite"
            if S.autoRace then Race.answer(0.6 + math.random() * 0.8) end
        elseif kind == "Sync" then
            if data.phase == "Invite" and data.raceAt and not data.answered then
                Race.phase = "Invite"
                if S.autoRace then Race.answer(0.8) end
            end
        elseif kind == "InviteClosed" then
            if Race.phase == "Invite" then Race.phase = "Idle" end
        elseif kind == "JoinFailed" then
            if data.retry then
                if S.autoRace then Race.answer(2.5) end
            else
                Race.phase = "Idle"
            end
        elseif kind == "Joined" then
            Race.phase = "Joined"
        elseif kind == "Select" then
            Race.phase = "Select"
            if S.autoRace then
                local best, bk = nil, -1
                local f = RS:FindFirstChild("Scooters")
                for _, n in ipairs(data.options or {}) do
                    local sc = f and f:FindFirstChild(tostring(n))
                    local k = sc and tonumber(sc:GetAttribute("TopSpeedKmh")) or 0
                    if k > bk then best, bk = n, k end
                end
                if best then task.delay(0.9, function() Race.fire("Pick", best) end) end
            end
        elseif kind == "Countdown" then
            Race.phase = "Countdown"
        elseif kind == "Go" then
            Race.phase = "Racing"
            if S.autoRace then task.spawn(Race.drive) end
        elseif kind == "Finished" then
            if data.place then
                Race.count += 1
                Race.earned += tonumber(data.prize) or 0
                Race.last = string.format("#%s/%s  %s  +%s", tostring(data.place), tostring(data.racers or "?"), type(data.time) == "number" and string.format("%.2fs", data.time) or "--", Kk.money(data.prize or 0))
                Race.phase = "Finished"
                Race.stop()
            end
        elseif kind == "Disqualified" then
            Race.last = "Disqualified"
            Race.phase = "Finished"
            Race.stop()
        elseif kind == "Returned" or kind == "Cancelled" then
            Race.phase = "Idle"
            Race.stop()
        end
    end)
end

local Delivery = { count = 0, earned = 0, readyAt = 0, last = nil }
if Remotes:FindFirstChild("DeliveryEvent") then
    conn(Remotes.DeliveryEvent.OnClientEvent, function(kind, data)
        if kind == "Delivered" and type(data) == "table" then
            local got = (tonumber(data.pay) or 0) + (tonumber(data.tip) or 0)
            Delivery.count += 1
            Delivery.earned += got
            Delivery.last = tostring(data.name or "?") .. " +" .. Kk.money(got)
        elseif kind == "Busy" then
            local n = tonumber(tostring(data):match("(%d+)"))
            if n then Delivery.readyAt = math.max(Delivery.readyAt, os.clock() + n) end
        end
    end)
end
function Delivery.target()
    local t = lp:GetAttribute("DeliveryTarget")
    if type(t) == "string" and t ~= "" then return t end
    return nil
end
function Delivery.cooldown()
    local u = tonumber(lp:GetAttribute("DeliveryCooldownUntil")) or 0
    return math.max(0, u - workspace:GetServerTimeNow(), Delivery.readyAt - os.clock())
end
function Delivery.ready()
    return Delivery.target() ~= nil or Delivery.cooldown() <= 0
end
function Delivery.run()
    local m = Kk.mount()
    if not m then return end
    local tgt = Delivery.target()
    if not tgt then
        local dj = workspace:FindFirstChild("DeliveryJOB")
        local pr = dj and dj:FindFirstChild("DeliveryJobPrompt", true)
        if not (dj and pr) then
            Delivery.readyAt = os.clock() + 5
            return
        end
        K.task = "Taking a delivery job"
        Kk.goto(dj.Position + Vector3.new(4, 0, 0))
        task.wait(0.6)
        Kk.trigger(pr, function() return Delivery.target() ~= nil end, 1.5)
        tgt = Delivery.target()
        if not tgt then
            Delivery.readyAt = math.max(Delivery.readyAt, os.clock() + 4)
            return
        end
    end
    local npc = workspace:FindFirstChild(tgt, true)
    local root = npc and (npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart)
    if not root then
        Delivery.readyAt = os.clock() + 3
        return
    end
    K.task = "Delivering to " .. tgt
    Kk.goto(Kk.beside(root, 5))
    local dp
    for _ = 1, 30 do
        task.wait(0.1)
        dp = npc:FindFirstChild("DeliverPrompt", true)
        if dp and dp.Enabled then break end
    end
    task.wait(0.3)
    if dp then
        local stop = os.clock() + 20
        repeat
            Kk.trigger(dp, function() return Delivery.target() == nil end, 1.2)
        until not Delivery.target() or os.clock() > stop or not (K.alive and S.autoDelivery)
    end
end

local Pumpkin = { got = 0 }
if Remotes:FindFirstChild("HalloweenEvent") then
    conn(Remotes.HalloweenEvent.OnClientEvent, function(kind)
        if kind == "Collected" then Pumpkin.got += 1 end
    end)
end
function Pumpkin.left()
    local le = RS:FindFirstChild("LiveEvents")
    local u = le and tonumber(le:GetAttribute("PumpkinNightUntil")) or 0
    return math.max(0, u - workspace:GetServerTimeNow())
end
function Pumpkin.nextIn()
    local now = workspace:GetServerTimeNow()
    return 3600 - (now % 3600)
end
function Pumpkin.list()
    local f = workspace:FindFirstChild("PumpkinNight")
    local t = {}
    if f then
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("BasePart") and c.Transparency < 1 then t[#t + 1] = c end
        end
    end
    table.sort(t, function(a, b)
        return a:GetAttribute("Golden") == true and b:GetAttribute("Golden") ~= true
    end)
    return t
end
function Pumpkin.ready()
    return Pumpkin.left() > 0 and #Pumpkin.list() > 0
end
function Pumpkin.run()
    if not Kk.mount() then return end
    for _, c in ipairs(Pumpkin.list()) do
        if not (K.alive and S.autoPumpkins) or Pumpkin.left() <= 0 then break end
        if c.Parent and c.Transparency < 1 then
            K.task = c:GetAttribute("Golden") == true and "Golden pumpkin" or "Collecting pumpkins"
            Kk.goto(c.Position + Vector3.new(0, 0.5, 0))
            task.wait(0.65)
        end
    end
end

local Quests = { pending = {} }
function Quests.cards()
    local pg = lp:FindFirstChild("PlayerGui")
    local qm = pg and pg:FindFirstChild("QuestMenu")
    local t, seen = {}, {}
    if qm then
        for _, d in ipairs(qm:GetDescendants()) do
            local id = d:GetAttribute("QuestId")
            if id and not seen[id] then
                seen[id] = true
                t[#t + 1] = d
            end
        end
    end
    table.sort(t, function(a, b)
        local ca, cb = tostring(a:GetAttribute("Category")), tostring(b:GetAttribute("Category"))
        if ca ~= cb then return ca < cb end
        return tostring(a:GetAttribute("QuestId")) < tostring(b:GetAttribute("QuestId"))
    end)
    return t
end
function Quests.claim()
    local n = 0
    for _, d in ipairs(Quests.cards()) do
        local id, cat = d:GetAttribute("QuestId"), d:GetAttribute("Category")
        local prog, goal = tonumber(d:GetAttribute("Progress")) or 0, tonumber(d:GetAttribute("Goal")) or math.huge
        if d:GetAttribute("Claimed") ~= true and prog >= goal and os.clock() - (Quests.pending[id] or -99) > 12 then
            Quests.pending[id] = os.clock()
            pcall(function() Remotes.QuestRemote:FireServer("Claim", cat, id) end)
            n += 1
            task.wait(0.4)
        end
    end
    return n
end
function Quests.text()
    local lines = {}
    for _, d in ipairs(Quests.cards()) do
        local prog, goal = tonumber(d:GetAttribute("Progress")) or 0, tonumber(d:GetAttribute("Goal")) or 0
        local title = tostring(d:GetAttribute("Title") or d:GetAttribute("QuestId"))
        local suf = tostring(d:GetAttribute("Suffix") or "")
        local mark
        if d:GetAttribute("Claimed") == true then
            mark = "<font color=\"#6b7280\">done</font>"
        elseif prog >= goal then
            mark = "<font color=\"#4ade80\">ready</font>"
        else
            mark = string.format("%d%%", math.floor(prog / math.max(goal, 1) * 100))
        end
        lines[#lines + 1] = string.format("%s  %s", title:sub(1, 1) .. title:sub(2):lower(), mark)
    end
    if #lines == 0 then return "No quests loaded" end
    return table.concat(lines, "\n")
end

local Codes = { list = { "BUGFIX", "SPOOKY", "UPDATE", "RESTART", "PATCH" }, running = false }
function Codes.done(code)
    for _, c in ipairs(S.codesDone) do
        if c == code then return true end
    end
    return false
end
function Codes.redeem(code)
    local ok, a, b, c = pcall(function() return Remotes.RedeemCode:InvokeServer(code) end)
    if not ok then return false, "Error", 0 end
    return a == true, tostring(b), tonumber(c) or 0
end
function Codes.all(notify)
    if Codes.running then return end
    Codes.running = true
    local total, n = 0, 0
    for _, code in ipairs(Codes.list) do
        if not Codes.done(code) then
            local ok, why, amt = Codes.redeem(code)
            if why == "TooFast" then
                task.wait(2.7)
                ok, why, amt = Codes.redeem(code)
            end
            if ok then
                total += amt
                n += 1
            end
            if ok or why:lower():find("already") or why:lower():find("used") or why:lower():find("redeemed") then
                table.insert(S.codesDone, code)
                save()
            end
            task.wait(2.7)
        end
    end
    Codes.running = false
    if notify then notify(n, total) end
end

local Shop = { lastTry = 0 }
function Shop.next()
    for _, s in ipairs(Kk.catalog()) do
        if not Kk.owned(s.name) and s.price > 0 then return s end
    end
    return nil
end
function Shop.buy(name)
    if Kk.owned(name) then return false, "AlreadyOwned" end
    local m = Kk.mount()
    local back = m and m:GetPivot() or (Kk.root() and Kk.root().CFrame)
    local shop = workspace:FindFirstChild("OpenShop")
    if not shop then return false, "NoDealership" end
    K.task = "Buying " .. name
    Kk.goto(shop.Position + Vector3.new(0, 0, 6))
    task.wait(1.2)
    local ok, a, b = pcall(function() return Remotes.PurchaseScooter:InvokeServer(name) end)
    task.wait(0.3)
    if back then
        Kk.goto(back.Position - Vector3.new(0, 2.5, 0), Kk.yaw(back))
    end
    if ok and a == true then return true, "Purchased" end
    return false, ok and tostring(b or a) or "Error"
end

local Esp = { tags = {}, holder = nil }
function Esp.root()
    if Esp.holder and Esp.holder.Parent then return Esp.holder end
    local host
    pcall(function() host = gethui and gethui() end)
    if typeof(host) ~= "Instance" then host = game:GetService("CoreGui") end
    local f = Instance.new("Folder")
    f.Name = "PulseKukirinEsp"
    f.Parent = host
    Esp.holder = f
    return f
end
function Esp.tag(key, adornee, text, color)
    local t = Esp.tags[key]
    if not t or not t.gui.Parent then
        local bg = Instance.new("BillboardGui")
        bg.Name = "Tag"
        bg.AlwaysOnTop = true
        bg.Size = UDim2.fromOffset(220, 22)
        bg.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
        bg.LightInfluence = 0
        bg.MaxDistance = 100000
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.fromScale(1, 1)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 13
        l.TextStrokeTransparency = 0.35
        l.Parent = bg
        bg.Parent = Esp.root()
        t = { gui = bg, label = l }
        Esp.tags[key] = t
    end
    t.seen = true
    if t.gui.Adornee ~= adornee then t.gui.Adornee = adornee end
    if t.label.Text ~= text then t.label.Text = text end
    t.label.TextColor3 = color
end
function Esp.sweep()
    for k, t in pairs(Esp.tags) do
        if not t.seen then
            pcall(function() t.gui:Destroy() end)
            Esp.tags[k] = nil
        else
            t.seen = false
        end
    end
end
function Esp.clear()
    for k, t in pairs(Esp.tags) do
        pcall(function() t.gui:Destroy() end)
        Esp.tags[k] = nil
    end
end
function Esp.update()
    local me = Kk.root()
    local origin = me and me.Position or workspace.CurrentCamera.CFrame.Position
    local function dist(p) return math.floor((p - origin).Magnitude * 0.28) end
    if S.espPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            local r = p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then Esp.tag("p" .. p.UserId, r, p.DisplayName .. "  " .. dist(r.Position) .. "m", Color3.fromRGB(235, 235, 245)) end
        end
    end
    if S.espPumpkins then
        for _, c in ipairs(Pumpkin.list()) do
            local gold = c:GetAttribute("Golden") == true
            Esp.tag(c, c, (gold and "Golden Pumpkin  " or "Pumpkin  ") .. dist(c.Position) .. "m", gold and Color3.fromRGB(255, 214, 64) or Color3.fromRGB(255, 140, 40))
        end
    end
    if S.espDelivery then
        local tgt = Delivery.target()
        local npc = tgt and workspace:FindFirstChild(tgt, true)
        local r = npc and (npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart)
        if r then Esp.tag("delivery", r, "Deliver  " .. dist(r.Position) .. "m", Color3.fromRGB(74, 222, 128)) end
        local dj = workspace:FindFirstChild("DeliveryJOB")
        if not tgt and dj and dj:IsA("BasePart") then Esp.tag("job", dj, "Delivery Job  " .. dist(dj.Position) .. "m", Color3.fromRGB(96, 165, 250)) end
    end
    Esp.sweep()
end

local Light = { saved = nil }
function Light.capture()
    if Light.saved then return end
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    Light.saved = {
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        atm = atm, density = atm and atm.Density, haze = atm and atm.Haze,
    }
end
function Light.apply()
    if not (S.fullbright or S.noFog) then
        if Light.saved then
            local s = Light.saved
            pcall(function()
                Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.FogStart = s.Brightness, s.ClockTime, s.FogEnd, s.FogStart
                Lighting.GlobalShadows, Lighting.Ambient, Lighting.OutdoorAmbient = s.GlobalShadows, s.Ambient, s.OutdoorAmbient
                if s.atm and s.atm.Parent then s.atm.Density, s.atm.Haze = s.density, s.haze end
            end)
            Light.saved = nil
        end
        return
    end
    Light.capture()
    local s = Light.saved
    pcall(function()
        if S.fullbright then
            Lighting.Brightness = 2.2
            Lighting.ClockTime = 13.5
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = s.Brightness, s.ClockTime, s.GlobalShadows
            Lighting.Ambient, Lighting.OutdoorAmbient = s.Ambient, s.OutdoorAmbient
        end
        if S.noFog then
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 1e6
            if s.atm and s.atm.Parent then
                s.atm.Density = 0
                s.atm.Haze = 0
            end
        else
            Lighting.FogEnd, Lighting.FogStart = s.FogEnd, s.FogStart
            if s.atm and s.atm.Parent then s.atm.Density, s.atm.Haze = s.density, s.haze end
        end
    end)
end

local Server = {}
function Server.rejoin()
    local TPS = game:GetService("TeleportService")
    if #Players:GetPlayers() <= 1 then
        TPS:Teleport(game.PlaceId, lp)
    else
        TPS:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end
end
function Server.hop()
    local TPS = game:GetService("TeleportService")
    local ok, body = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    end)
    if ok then
        local okj, data = pcall(function() return Http:JSONDecode(body) end)
        if okj and type(data) == "table" and type(data.data) == "table" then
            local pool = {}
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and tonumber(s.playing) and tonumber(s.maxPlayers) and s.playing < s.maxPlayers then pool[#pool + 1] = s.id end
            end
            if #pool > 0 then
                TPS:TeleportToPlaceInstance(game.PlaceId, pool[math.random(1, #pool)], lp)
                return true
            end
        end
    end
    return false
end

local DEFAULTS = {
    blur = true, tooltips = true, sidebarWidth = 199, base = "Midnight", size = { 676, 585 }, radius = 0.45,
    font = "Roboto", accent = "595959", menuKey = "LeftControl", sidebarCollapsed = false, autoFit = true,
    opacity = 0.66, textScale = 1.12, bgIntensity = 1.13, volume = 1, bgStyle = "Grid", panel = "0c0c0c",
    motion = true, density = "Comfortable", groupLabels = false, scale = 0.74, sounds = true, cardStyle = "Frosted",
}

local W = Nova:CreateWindow({
    Title = "Pulse Hub",
    Subtitle = "Drive A Kukirin",
    Initial = "P",
    Logo = Fs.asset("PulseHub/nova/pulse_logo_v2.png", "iVBORw0KGgoAAAANSUhEUgAAAMAAAADACAYAAABS3GwHAABnNklEQVR42u2ddZhkZ5X/P+e9Utre0+NukYnrQEJCiEACBAKERQJLcFh0F5bdH+6LLxYsuC7uRInbTJKJTWaScW/vri698p7fH/fWdE+IAQmZkDrPc5+W6ZqqunXOeY98z/dAS1rSkpa0pCUtaUlLWtKSlrSkJS1pSUta0pKWtKQlLWlJS1rSkpa0pCUtaUlLWtKSlrSkJS1pSUta0pKWtKQlLWlJS1rSkpa0pCUtaUlLWtKSlrSkJS1pSUta0pKWtKQlLWlJS1rSkpa0pCUtaUlLWtKSlrSkJS1pSUta0pKWtKQlLXm0RVq3oCWPvZppywBa8nhXbgGRKT8roAiK6sNQcGPSx6aPVwVs+rVlAE9ApdL99HVNVXQFjR/m4zzAAdxU5yxgFRrp9w/0UAFxEkNQ+4jfl5YB7HdiHlwhHguFx4A8kLIboMfAzAze3Hba580wbfPm+u3TZ2e7ps3LdLRPc7s7+ty2XFc272RM1stgIM5o3AijsBGWR2phfaI8MbI1Hh3YzMD2TezasJnBDf2M3lMmHNz3ZoiTnhCPjDG0DGB/VH5vToZosIE2HqPXIKmDv6/CO8AcDw6e5nYdvCgz78gTCvOWn1CcO2tFdlbH3PzcrMlNg0w7eEXI5qGQA82An4VODwoOdJjk6hbosOBYEAujIWwrweYBWL8F7l27Z+POO++9tL7++t+x8ZLrGVs1AuO6jzH8nYbQMoD9JrpwEoXLHtcjvW/6ju58xTPR8B+s9PeNuXPAgUXxj12emXvMCW3LjjzTXz732PyKnk7TAzafKFAYQqMWBLXARo262kgg8hSbEePkDG4Gkyko+aJQyGPa89CeUWZmsbMdZRYwQ7C+YAWwIqZqjBur75cnYNM2uGcN3LVq263bVl37Xe7+3g+YuHgQ4n3vXcsAHu9hzzRn/hnXr5/Yc8ctI7c999xHP7wx96P0c1xYuSA755Qz/BUn/kvmsCUnuAszmE4wChMDlvpAWK0PW8u4GCIxIAYHQza1mYJAmyLpV6cNsu2QK0ChKLQXlfY8dBagJwudBnygoVCyMBoJE5HSiLGqNsp5aqd7xnXDTHZiC2y+Au793S0/rdz8xfdQ/uH65KQ0exPvlgE8zhJeEQOaka4jfvmdp7/79PN++oZPvj3sf+dn/x7P9pDenqn/76KM8U49PLvs9H/JrXzyi7OHzOizXVBrQH1nGDS2RoEOiKEihjBVdkcRT8AluTwSLc4AWUELCm1AO0gHeJ2Qb4diATrboasNOvPQ5kPBKAahYaEUwHhDKNeVUg3KDTGVAFsJldio7Wi30exOYzqrmWz1clj/vTt+P3HL+99A8Ittk2Haw79nbksBH/vQRzWCjve+8LyPnX7etZXQhv07Nj2y5fHU2xNPSbC7HeHU5ZkDn/da/yknnp8/dGZR81AeUEbvCqt2WwzjYrDqYsiKq8lp4QqKgJUkQpvqdB0gAmKFOMmbAYyAGEGM4rtCxgPXKM7eVyXUY5howHgDSjVlvAoTZag3IAoVCQQaYoa3ij8cC9LWqM85wdrFJxxy1p7v/3zrngt/+A5G3/IZdMj+NUbQMoDHPO6PIHPW7Ke9/t9/FD+lNrL6HXSLbLz3kSl/T1X8OP35+F637znPz5541n9kn3TA4niaQ3WPjSZWBWXdag1VdTGRL64FL0ZtBJGgDZNquAPGTcqTTrOa2TSA9HeaPJWmT29dcDzI+kIhKxR9peBBxoAnYC3UAig3oFwTxirKRBlqNTGNCtgG2JqiNZAAxCo6KO72e1y2T6vXO8/Fzj/uxZ8cfO9hz6yu/ddnw+rSwzWCVgj0WMf9zhx3+lNvWPufP5m+8NPjtr7z1cNFufwZvaq3Df/tJVHDZK0doNMIzzzKP+L578icdvILnOUd1CagsTas6pYQSqGLBEZMkBZVDIgPjg/GA+Mn4U0WJJd8JZ9+7yffkwXJg8mAWwCnoMbJWWuy4OXA96CQhbYsFLNKT0bocpJXWomUsbpQqsFIBUbLSqUq1MuYaFzQqrVaJgn1QyBITpq9LbdYKBwX1afPzRX7/31orHL985bBVYMPxwhaJ8Bj5v0NgoWlX/3kWz44e+n1xUp552X5vBnZVra6a+JvgwjcV/HnZpzsuU8vnvSCD7tPPXJFvdejck9Uj39WtgyHLsb6uEDGBVNAs+1IziB+hLoNRMZRahBPIFpGiSw2gIkAKUWJi7cemBwY3+C3QaaAU8iT6cjbXEeWjh6XaT0xM2cK8zqFrg4oFCDjKCWEDY3E81cDqDSgEkCtLjQqSlTG2opCBSgD1TRTDgWiND0yIC5ULnGzW5bVqzM/0dPuvuuH94xfe84iuGn0oZxIywAeE+V3QSO0461Pfv7rz3yrd1S9/Ie1ni9bY6PDm+6F8fBvD3UAFuVM4SUvyZ3xgv/Jn7KiO7AwckulrPeUXWLHJe8jvT54FnEqoHvQYJelvsMyus3qRL+lXEPrARpgiDGqnptYim8QHxU/Vfw8uAWLKVhMLoqdnA1N1pbdImS6zQ633ZDJG6Z5pjDL0jNHWLQcVsyDhX2Ww7qF6Z2wOqvsrArlktKoClFVsJVE6bWsiQHUgRoQapprTIZa4oO93fj95aA+7UOzO8uv/+YN8fpTD0b6I/SBjaBlAI9V3J89pv2Acz5y6SmvCqufHsCvrDfWHY2IJjbeDoE+PDjEfWP8RTnT9vKXZc849zNm5ZJ8o6a2clmjTL/6FPysTFMwI1Ya2y3ja60O32l1fCtUR11thFliA+onMYybAyeThD+eB0iEMXXEVpGggigYMTjGxXEKuJl2HFwcB7wM4hcg44Gn4BjUUq0MWlupirttmzFXuGpwhW4XlnbBtMOFOYc7VObD6NoYnVCkIdiaJkpfSw0gkAQ90XzLNrlHWkvCsWi9+LtzQbn4nwcvq7zpfe/Vyuvf+2CRfssAHgOMjzFt4hzxrd++8d257JVOUN94mxjZYwMdnIDqljUPDw/U9Gox0OdK7mXPz57xrxd6TzkgXxuVKLw2rlI2rmQrvnTfaxldHeimNYaxzVlbHjGEEYiXxPmuC8bbjqcbsPW12NIdxME2wvoubDCChhW0UUPjGKxFY0USC0gaaJ7BZFwkn8Fpy+P3Tdfs/MXkFh5MYfmTKS4/iuKSbvFzSew+FlsJg6qG4o401L2xZuE3ER09IYWn+vQ8Oc+Y4xCsiaCk0EiVvp7mAI0pBa04vU0mPRXyAjeTjZ8VVrtf9qL3DF/w06/C5TsfKB9oGcBj4P3t4k++4nXvOvgpu+fUyr++1cnKDpAy2IEBCLbc+ZBGJE0sTFGQc1b6T371d52nHb84xES1G6Myo2XXcDs6em3AzlV5O7bT0Kglz+94VURX48dXilZuVltZR6O2G1urQBQ/7L7DvrYZExOmfnqMGrsY51bgZ0l1qMujcNB07Tz2GDqe/FwtHvcCsjOL2AoSDFfFlg1uzR3fXWP8qxb/R1n8M/vgmIUEa4DhAAKTJL+BJqdAPFluBU0PQkleVwZqV4N3Vrs1v3/95+z2K1+Q3K9WFeixhzp0Pnfuk/7jF9te845a+aO73ew9V1rMBlAjdS69sqjXvn0Z3Hnv/SdvU3/3lMXuiv/4tnvWWSdEGUN8T32Mnbe4jF7q69Aqn9EdEIVgnLIYe7HS+B124lri0pYkuLePQnFQJhGcTSu5v+dxpmfoOGUl3We+g8IBZ0IAwXBVbM2ggau1OpQU74hZyLlPItjQAVtCsAI1TRQ9SsMfGyfPYZzkckm60QbkTBP5d45mG1981jS4cej+ToHWCfCPqvioRdwZTvvTvnDxa14VRr8PjXvvnYIMC3YXmJnq6/AOYLj/L12smVJwn5WVnjf/d+a5r3pPvKiHxp07hvT2P7Uz8udOGb8XrVcAewlO+DNM+c/Y8jaNqo37x9XLA7j0v7UJoQ/w8CkQao0h7m8w8qMrGPnRFWSPXkDnM95D4YDzVUNojJURm5UOS7h6F3LPnTgvfh62bxG6qQGRScMfC3EMNkiUWp2kFhs5SaiUA73dRhzWZSV/6tlavfHCVg7wGMb+ikWXf/k9b3zr7AN2d9eqF9/k+LrZInuAwLHEVZ+h3UMwUf1LBGYT9PXCU7On/vcP9KRD+4J7Vlft1z6TZ+imXoI9EbbxPUzwbWT8JuKJMnH8AMr+SCj632AY+xiggJjEGOqrt7Bn9SvxD/4I7Wf/mMzsYwhHy2obPrm60dIw8Te/jnnJK9HOJbA7SB4fxxDXQIMUqu0kJwTZpEzqAwO4UdY1svjIF+kdzoWtHOAxLHnS+9rDTjnvue9bfmyt/PHtTnZ8PcgeRQcTcLvTmCAq9d+DqUd7o5ymkjAra+a+5xPZs57/prCxjvDrb4LtN2Rh+HuY8BswsYpovKYPqvD704DN1NmCFMQW3LWJoXuPp3D6mygc+zlsrU5cBT821Evojz+DOec92OGZUG2AhqD19KsmzTs0cRjiJyFSDUNVrbN80Up7R48HA2HLAP7BoQ8aIf7yzLSnffzyl70mqP+yYfy1awQZBB0RGLfQo5axMTTYeV3yyaVeXxX8ZxwkR777WjPPdtYv/xD2nst/D4Ofxa1dT1Sq7psm7DuO+PgQO8UQAkvld/9LsPVaimesAq0T1sALjI4MwTUXIEe8H71HwISJY9E0BMJJ+wIeqAexAUcN5Tjw5/bmQ6YXYWC0ZQD/yJKnCo7xiA/86gWvf1tn9/pivXrJDcZlo8IegXGgAjJTrd02CAzdgaRxMj7S/Zb/YPEpn2TsV7ujG/7wXtj2Y5z6IHGY2MnjVukfyBDSPCG8YzUT9YMpPO0uCKpEVZeca/Tuq5BZv4HO58BII8FE2LQmKk5SlbUBSAixD7GgFbXSXQB6O4CWAfxjvX9M3PueZ5z5rye9ouuIWvmLW91s+R6QQUWH0gZPAKYDGN4NjN2DKpg5WSm85f/IxH265u3HEa6/OSl3NNOBfxalv78kWpPTILp3LRU9nOxxayCuika+GkHv/BFm5enYETf1/uGUqbAw+Z3GyY9WwWJtBsD1W0nwP7rkmV/ZufC0//7DqefXqz+acPyNq0B2g44KVBXqyYdtcqGJB3cCQ5sx0zzcE1+ptR++jYlbNz6+w5u/5zQwEG24jaDjreLP/ZzG1Sqe4zOwGUrXI7nj0HKDtB6aXFaSEIgwKQNZQMVoFAGNoGUA/7DQRzFeu5glX/jVuW917ep8bG69RIxuUaQfKJGU6hoKRQdlxNfhHRGmWkJDS/DjL4Emp8hfdITlEa7fP1zOHp1CV/KPMMAUUx3e+QU1XW9E7EJELbE1uvsKmPVkKMXgWrApME8Bk01OBLUWYwxtYuxQHRgvP8ENwNynSSMPk6RJ/8rad4LNsW3/8Zpnvvyok8LD6tVL1zh+sA5kWNBRTbx/kHQypVOtlAd9ndi9FlOpEU1xVGr3UxtPqUqa5c1H5XU2hwoalmjz63DnXYatljFOlsG7YXYlTXjrac6UviajCceQEYOj1nSIkbUTFsYqT3ADsP+gamAMxdMWLzzxtV9Z/ppG9feDxh9YBdKv6DAJpDeY4kl7gOEhsNEEUpwOVQs5Ad8kmmYUPEEcSQcIkg/euAZxDRiT4Pcd9tbXjSuoCMaRJGJSxfiCOAaRGDWC8RzETf4GERyjieIoiLWIKhLF0AiJRqtoJaDW35D6cKRxJanA7ONf3KbnfYSNAIh3XYWZ1i9ie9TBamXISDiazCpoPJk3NE9MY8AxkLXW6TDZ+J5ta6G//sQ1AJMRyS3v0tgz1DsL5HsKmGJW3KJPpljAy+UlU8g5XtYX12RxTUb8jG/IZCVQQxAicewQRYaoYTCBVVszVhoS6bjGUhds5GDFICr5/LnnP/f9vdGNmdBdfzXITtBRYCIFcmmcVCyM4EwTwz0bI0x0jJl79h5nWje5aXPpLnTRJh6eKWC8PK54uI6H62YRN0tkXXAcHMfFGIOIB8YQY7DGxXEFNQaRBDukxkUdB00Z2Iyb2I1KgiCwHkQyiSiA5N/qcXJVNKJaq/QPjwzcGw5uXMWuO69iy823suuW3YzeE2CjyeS/2fF9xOygFmFLX1en7d1IXCWq+MaOEpsOCOP0TUwJzcRJDvguxxpXCTbcfXGScP0lwNB9QsTkApI/8UWLXva+L3Y+o4tMVehud5IpJS9hJvB9sAa6HejwIXIT2PlEDGMhTEQwHkE1hoEgiSgrIzGlnRWCwZB4ywTO9lsIb7uJp71lEQOHEt1+jZh4PciowoQkQC4bg8RJg8x3yPRBsHsduGOWhS8J5ORn2fhJDpmlsKgd8k1n5kDGmZw4rMXp+WCmBl4Q2Ml+5z5pswFrLarpyKxVxICnWCdVikx6ZYEOoCiYItAuYnpFjI3apteDjukD0dITNtSf/rZ1I3D9ndXSjmtu+xmrL/4B9/ziekZur/1Ft/eRYMnTid9D57uR2Cb3sApOV3JPm/H/3tAssWCzWK2/u0JtcNUv9r1LTygDUIgbage/9KWt3w53jMz5+K/s6bkxvSskVut6eYNxLepY1DV4viHjiiFUwjo0ahBUlagkxOMOtgQ6WofxURjZAqNboTqEqe0m3HE7R538Mma+eaH7yw2hGVttMKOCHY+T0CeySeggBlwDBRfiEeyubeD76Par3eB3YwSrn8T67jmsn+5Cn5PQjGRIBmiN7ouSkPSDd/Q+0B6ZdHZGm1gcgxGbxMnp/K4jyVSBQMaHvAu+p+Sz0JYTenIwK6vMcWGOGwbLc9inKPZfCmqDXsydy/zitU9bef5Vd688/6bL3lnd8+fLP8naL1/A0B/6E+VvDg7/vbFndaMIqBqzF2TXVHqmXukRZiCz2M3Gv7wrQK9e9UDxr/uEqcyIEA1/7dejbxt+Uu4VH7uu/owFkd5sIiZwE+VyEyy5k1RxiGwKvxWoC1QFynWojCL17VDfBtUt0NiJRBPoyAa6u4/h5M+dzZUNZfAKYLfFjgvUTOqaw3SGxUnwK9OAyhB2qB+6ihBVobINJmYimTYY6E2w8DmTvC5XDa5aHEmcmZkyE+PJ3jQABLW61wknR4UkjxW7V/nVgLiaPM4VwrpScaHuJmOJ5RqUczCcg40Z6MyKudHHzPKELsC3SqfYaElnwy47TqMzjnCzN51y1vtu+NVZ71v/5z9/jq0f+zCjlwz/veRVie4GFVVrQV2Mhxh/b2tk7xsVF9xM8v10CUwmytYvv+gC2FFPbox9ohpAWq0QB/Tn19e+tXWWu/NLt8v5x/RGtzWq7BBfCoKOp5UXqwnWnBR224jQxjhSH0Abu9DGDqS6G+q7Iaoi9UHseIbTP/9q7l2U467fhOg2g0yAVmxSlo6j9DV4KXuC4vWBVxpA4yqCC3Ed0QjCEtQGUJOHOA9enJwYGTPJxjBV+Z10ON1NwoW9bMzNaCDNhTEgjqDe5OPVTV6SOIo62DijkBEjgBMrQQyBFXIKNQsjMUyEEKsSJH7CFDCmU3DzOZi1sl594XFiNl3x1Lde+e2nvnX71d94JUPv+jaNYfvXcvbs+xHaCNE61vhk8thsN4yl5c+mU3HcZIpNBXclcOseEw3/5jMPFP488foAe4/k1buji1++2Bn87KXeW089xvbYcrRasxidMmqX/n1cN9RHLOEAxEMQDCDVnVDdA+EYJp4g3j3I8S97m/FfciBXrG7Y2u0GGVe0TOLBw2gy9DEpUtGAOw3sjZuTpoDpTCsrFuIGWpsARpLM1M2AJ4ZGOoaI2r0ngJOeWj6oTAmDUq+ujqalQWxT4fcaUHpy4CrqQuxjFEEUYqsEmURBHKM4IkSR0mikob0FrBBFwq5QKUeKqjCt4Phzp0PHKfXqSUdhtn/rVRde992nvDTc8prnU75y5G83AhGMY7ARUui06nQZ4l3J/ZxaiSID053IX6DZxicvuQxZveXBknLnideoShGDDDZ0z5++pTdOW5J7xoqj4kWmqmuti6bNxbABjXGo9yvhAAT9UN+N1PuhtgeCEUQb2JF+Zi55Gif86I1yXdWy7feishu0lOB8CGyKWZfkA/INkkti+rZDHfTy39LYshYptCdlPb8d3CI4+cQ/aaJoxEaJjRAZiEQTQ5VJY40kOWmiKaOCUfO9pHl3LIhK8u/h5Dhhkx1R0ji6ebBIM7IQQVEsEEQQBFCrw0RNKFVhoqLU60nYtGNM2bRHaEw4jt8jpvfERnXxgTOWD97z4nfURnb/iuDm/slU/q9o1Jl8Dm/Oewlrgcw52KHzNBjbmYDihMT7+z2g7XjPMFFmw3a/9qsPPgs2D07SJrY6wZO1ehxgOLK73/zSypu23lF47xs/1nhhdzX8tbpMWENQg3AE4kGIxiAYRBqDEAyijTEkqkFYwtWZPOUzr+eubsdu+r8Q3WWQiqb1fgUbToZfrgN+egIUDG4moL5jN/hJ8K6qiLVoHEJUA6cOppoaQQyRbzEuOJ5BHLs3/IlkcizQneLd3cm8UKMkGZaQfUOoKC39xGJQbKLogjWKBEk1rJH4DRvbpM4ZR0ocC40QwgCiWIiCFJwZQ6TKnYOwfSssXeRlO06u14+cbsy97/rGbVuubH8ylc9el7y46K84ALKdGB/QiOmHu1qpA+NJuOpkk9lm8jDDi3KL4mz947/9E3L92oSd64F7Ew5PWNEmBBeiq64JLxu8OT//6Je7z+yMw7UmZqJskGGIxyEYQoJBaAxCMAJxHUcr2P46p/zHfyOvOZSbrgyo3WCQMUXLksAcojC5+cZN6pWegaxARmGWy6xpw4z86OdYU0L8AmJc8NomTwDxEHGQZg5jUxx9rIo1ycnQLH9HTJ4Wdkrv734umdob1MTDi6ju/Ye0r9YssxpHECtiIzRqII0A6nWhUVOCqhBXlbgCtgxaTRganAbUqrBrl+CNGyPLVOefFjV041mvG9nRuI7gqk2JEdiHdwK4M4/HtJ8nGa3LQf/q6Z4RkmEKm7Bx+Z1AL9mXupG54m6/dvl7nwK7yw/m/acyKT1Bxe6tICjf+d3EZ157RPyta437bM3S0xnQsGBrSFSBoATBBBqWMRIRj1ZZ+uSzmfm+k1hzT8jEtQ5SAp0g6bnYGEycUIp4HngOeCAZwFMyM8AfGSaaGEe8NCtNYRrSHBixDTSqo3EdbNUQVSFOIcA2QOIwyS+axf+IpHkRplCLJotaI71SRjVtfm8xRCmaIJ0xIRKIBBskEJsoEKKGEoRKrYapVaBWhsaEEo5DXFJsSZL3PZE4ZcbBjoEZAzOm3HML7LzYmN2ucRd8rFFdsPJjF5N9/qKEIsJ5eN1gp/MsGmWYvcIl6oHapsTSJE5YLWwbHJMLnGwlX77wW++D23c/HGa9J7gBTB3cNsBFaxq/et1s+4XvbHdOjPIye2mdWsKMRlhCowpGLVofp5A/mGO/9BrutrDrEqBfk7i/AcRpvd9zk8K6M8maTCHpMLXPAWfXAGhsxfWTQHzKSxINEQ0QDRKljwK7F+4bB2DrqA2SUyYMk+eMuR9DSL5KlNKGNA0joRexSd6ge/MEouQxkubtGilxA4Jq0hOpVyEsQ1RKPL6dAJ3QRPkngDJJ8l8CHQMdATNh2bkWhi4VM1bAPfozUX3asV+/mcyK3F56tweN/4sebsdLoRHJwtN9O7AVZDSxUOOC0waFXls8w7jhp/48oPUffjxxJvqwufRagk0jwrsH7Kr/WmY/94HfmgXVItMPqVIbgbiaKKVE6HgbJ77/9ew6pIO7/xgQbRGkTApys0BkEMdIm0npw9O4P5de7dDeCeHGYcikpJo2jWEkPbLjeuLp9xpACFGDJDepQVifvIIaNOrQaEA9PREaus+ldYVG+vt6CshrKNLQlHCqWbECsUlyrZEkT91InjIoC2Ep8Qe2pOgESFWSZD9lcWvSGOpEagQTYMcEU4Xtt8Hw5cbsmRXaI9/Z2WnmX/gd4/gPjUr1ph9DUO6WWfPreMtg9G6QlBzUzUI0E/eF2Uj/dJcf3PiZp8JgkMT+D20ATkvx7y8vqESMr/6x3nGnlblHPx2np6qldcYxocTjloOf/Urm/s9TueXagJFLBSlJGvdbiOoQq0ohI2oDxfWSMmROkBxIO+g04bClhsGfr2F8z90qrlWMq5KfKeRmol4X+DPAnwluFzgd4LaDU0y+97qSmNfJJbmC27z8hIXWcdO6eHo1GwJu+rM0KUTSn12DuJNKqFbRWPd2kDWWJOqqNxnaBBqC1kHqSRVXg+bpoukJM6UqlR5cBhgbEKYXjDP/aUG9q7bg8M23li6meu2OvejS+5up9g/4IdHoHDnyFaqDkaGxJamYeW2gC5FTFtf9ueVC/b8/9U7057/+a0iFW/MADziaFyoTF32Qq0Y2seTl35O2JTYevtG29z2JAz/5TO7aE7PnMoOMg44r1C1EQRKTd7SDN2GlmE9An0Fak88omgW3T5ipcPuoAxnPYGIrbfOMdC6FXB+Sn4MpTkezDuqTVI5EwFhEahDXUVU0TouWzURYJE2U079PgZ6qSbdXnbSy6oHkDKYoaMY1psPHdHlWfRd1Dca6aBVsFbQSY8M4oUgPBYkEAtBGougaTim3xs0kfAp3pyXpekuaZ+SFdVfB8oMd//Tzw+DO2975k+Gf/2Ah4Z5Y9zYYpmCA3L5FNMonyIIjqjjLfYb/BJ6fdtOnGRYsCbInkw/+7WdrNP7ep5ORUm0tyHhEsOiA1lZ9n3WDa8385/0GTpp2wsfPY/ccz9z7lRAdkCmclWHyjVvELKwie/6MnfVc2B5DRsDXlEJc6JsO2ZGQsTKQa7c6vttS3mN1z3VpuTSfFHhEEg8oblqWSWFrzbKq8VFM+nJNUg1pgsFM1qZw6STNEUXFQUweERd1PWO9TvC7iP0uYn8G5DuRooX2BrYrQGa0YTpmYPGTPl4QJl4/kn2SaqLU6KYqfZPAVlOMjlHUAWOUiSFhzeWGc84NgpeeN23u525661ls+s/f7BuRa/K+nekXYGoRC88xun0VYhqo5MHrhvzyyHtZG/FnLq7HWz5+MpTsww19WgbwsI3AQLjlFjsw9qujXv3qN7Y9p6+6+uLQD+4UpKJohcTrSwANFzkui9z0UZzFS9GCQSVMKkA5weQUm4VF06DtTsWG4IgYi/jEaYtVDNgAKy5iMiAuirPXAJK/8RDHQ607BQufSV18Oi9g3clOFinewfio8ZO6uVtEnSIiOau2GBBKxPCw0e2DxtaGXeqDICWk3cC8xZhlT0ILs9PR2zAJg5reP5YEOqKSGEM8dVJRpySzCZ+VoNy9Bm470fGPWhnbjmUv+dT4lo//FjuqUzGs4s09mbB8Ogc9r6zDE1km1qHZXvDaIVqC87K5gfndbcXG5R87HDaP/y37FFoG8FCTT2qhuPLQWUf/6xtXvHdxffVG6w/8WZBK2u1tREkgXLPIgT24Y38ivuK38JJfYLel4YszSVcjOVjUrtTHkmK7BJUycX194tpsI6E5FnD8GBtYcEOUANMc+HAF47lYx0G0mgb3iPGNqtopKLkYxzdIinwz2QyO5yHGYLIOblc3fmcv0juNTG8WYxMMkhkFd7BOdsTSGHG1f8Sw42bszb9EFp+MHPQibLYtScxDs2/X2Ta71iQG0VyXpJraafJvYhJo1I//aMzzXhnUj3vy7KUXX3nGEmo/vncve7bbmdc490vpmV8nf4jPjj+Dl+Y59TnIuYfUzYbNxcY3P/I8uOa2v3WZSMsAHqxAphaT6/Hcae+85JSPHBPtdMWs/7XCoKR89THYGkQR9PTi9m0k/NSHyC1dij9rLsF6m4D5myeKK3gutDsua+8dCLATeW0MvFcra74ARpLMU+9TAddHZHDzfq1bfFGTcXE7i2RmzCez4MnkFrxAnMJTiMoQlKxSreNGvtYn0NXfRLZeihzxAbTnQHCDlKpQp5DVpqeBbf4cT3bDcSHysLGBrLLpRrjpTKH3SWql+IyXae3H70EtiIuYOd/A8TuZe3aVPde7YkC9DASzkaefUDeZUjH62KfeCb/8xd+zXNw8cWnKzUP+jTFgi2//6HFvPb3PHmWCW34Rm2izSbx/1SZwhbgBThFzSJX4hx+Gyh6KK1ag4kIUT8LV042kYpRyGTatG7RIGQ1Hr0toPCKdxM1PvR61EE/RhiUuBTS2jVC66VYG/++LbPvESbr9S306/OfXE1XqYiVPWK5jG5DJoQOb0Ktfj9m5Bgn9RPGmJsLNfkNkk1MirqedtirYtIZaD5AahP3C2qvEHViI6V1w/EuS9dkWcRe8DLUvYuE5VUY2+ASDCSCw1os8+Wl1M98p2o99/qvKdz75cOv9LQO474TRg3kMSRCLtvDc4+c/9dX/sex1bvm2VdYfuQlMOd1YEtWSTmToYw7Po5d/HrvxLsCj45ADaTQHYKY8pY0SQFl5NGRkz6gLY2ijf/Njey9kCp4+VYdoYJDqLV/RsT/1aX3z57AUsY1I4hqS8aE6gd76DmR0Z7JQQ1IIuU1t2KazD3GaKWsd4kqi/NEo2FEIGlBVRleLGSaudx7UuxCW5E2md4la5zvMOrlMo+zrxL2oW0AbXcghp9XN8t6i/cgFv9D6F96Q0CLSMoC/7u0qmJxQPPuQ+3376RifZBflCgs+cNFTP9xV3ziMf/fvBRlPGkAEqUerKbKsB3b8Ar36T1D0cJ0i3iEHE4ySliAnKyM2Aj8jhEORnRgZyBIOjmg0Xnrsiaj0PgPtqVHYcoXarW+jce/TUcmCBsR1K56Lju5C7/oUEpDMKkizHKtJV9qm7WatJcpvKxBVICpDNI7GwxDVCTYJAwNiwiXWIis/ozZ/lfQcFSF5n9E1iJdDojY44Iy6HLKkaD/x1T9o6ePnQsU+vC06LQOY0vOzIDlh/o++Ib3nfnCy5j+V0weM56I9H/nWyf+9or2xQO2qn4mxuyTh82nUQSsQhMjMmZjMzdhffwUpAtUhijPm4c2ej44mwydJLJzWz0PI5hwqW8etlgcwcWk1thbtl+S1e6tgAtGOiwg2r0TJq0aB2gZk2tAd18DQ9ext9pG+XxsnnS9bTRic47SVHJZTAyhBYxh0BDsaMXKPmMqsnBV37qu1cPBMdTvQ0TVGnRxEOWTBaVWzfEVRv/r1i7X04bMTQiDziNwz84RhaiMGd7rrLv7Vd45+4dnnm3Bk/f16fyy2+KbnH3zOC14455ywfO3F1q/crkgZtBomXsw2INuDzOnH/uozCQFuNAxRmY7lK6gXClAJE4Vo7rGKE0xOIQtDW8YttooG/ZdO7Tnsv1SFArb/Bg13nZ9AVdOqlFXY/auEjM1pbq7RSdLauJHmSdUU2pFgmIhqiSHEo2hQJdwOoW8wxUwdkw2orE8wPpFBFjy1yoKj2vV7F/xexz9wZjIG9rcnvU88AxC3GdJkmPX7y17yhdPPm1gQRPFQxdl3q0nKYFBcOaP7kP/66cnvttXVGzS77SLBTAg6EUE4kSC9bA4z30Uv+Sw6vDtJDIJBoI3uw1Yw1kgRofEUCHI6wFJ0oLJ10MIEUt9z7eNjUU/TCPZ8izi8EslnQSLcPAzdi8hIukiv+V7ipEXcxE/YFCch9dQYKqlBlCGeQEeTdEkysUttyAgOxA4y59Q6fSe3219//Xta/ugUz28fabq0f3Ju/sLhBVn6x5ve+tmjnlI+qTay/hZc8QbG/yL08duN9H70l6e/vyfaU7Dm9v8TZATshIUgVf7QIHN60XVfRjfdjGQUqe9CjSBmGvnDD6A0mA7TR5PbDDVi71z28PZhg5TRYGjj/hf+8OAwER18g4hvwLW4LlpvJISnuamLMNLSp21M+dq8EijH3lMhnEAnQupVsI4HkkVtjMw8pU5hZdFe9KnPUv3Iy6H8iCv/P7cBNJW//eQe//A/rX/3l5YdOvKsWvXXd7pZd+MmVLYP3HcFkS2+4+1PetXJx+dOCINLvy9uuAmY0AQDrBWIIqRjFoz9Eb3t90jWgfoOILCqGZPrXoAunUd9TwIB0Fj2VjbVAjmDW6vZ6sBAFp0Y0mhsmMdVZxywo+tUw82Im8fNWmwGlVIC896LS7JTToApp0CUfo3rSW4Q1ZM8oRqgVUFtNWHG6Dm2jnNkUW/61FuJvvj2BMIqj7jy//MaQFP5u541K3/Cb7d85H+nzd58fL363atc3xlSa/s3AyN79skP2s9YNmPlv33ykH8PylddJf74tZoMuJQDiMeSYzvTi2Q2oqu+jbgZCAYsUTkSMT42F/QsPpioqxOGwiQnbMICNMHGmLyhOli2jVLJoKO37Z8J8EOVTSML1R/j5sDNR0gWsnFSBJDme0lDIE3noePGlLAnmJzAsUFSJYrU2FJoNByxdB8XSHxQUdd+5qXY7//vZKHi0blH7j+t8ve9bFnbqV+/++PvEbtmSVj/3tXGdyYcvPIYwchW0NGhRPciJDPN8+Z8+PKnfbwtuGNP6G/8P4OUDFqqgx1OQh/NIm0xuuYrKSZ/wNIYjIA8En8Dm9/Yd8ShHxsztk5Z3X2G1NPowStCbdeo1XoJMWPX6aP84T56kVDjenHaUcezuEXczg4ibxL1mUyzhSn8c2oekMaCapOtgXtLpYJO1C3quwTtvu758pPhhuvuf69Z6wR4EPKrFEcy+01HTnvhd9Zf8DEN7lxkowtXGddsS5uR2/qNTmwDLQ+DYDxB2/7f549/0xGzS8ttdOPXjGFQ0XII8Uji/cMQOrrRrT9Ex3aDVq3W+yOIXYgH0NKb8GbM7Tl0IcPjQE1SuLAmp0CKl3Ez0Ni8y2InIBy69vHbTpEBnCKYApKfgTe9O5kHaDJv2yA9AeKUujxMK0CN9BRI1xvF6aBAqNaUQ8tEY4Sxbx88qfyPPhW7+edR/rSKs/iDp896+edv/up76vXbZ4j55hrjslWxA4rjg925G8LdoPUSKDZ37tkHPePlr5tzfly+/JvWj+4WpGohHAI7ksSquWkwehXsugUIkMpWhNACPnZihRW34XYsO99b1mfHd4hJBkTSEyDWZNrRpjiubbsMTh3CkbWPzy46YHwnGd5vt27PHOvN7UpYs0RShW9MgUHUENs8CRpN6gibhEZBylmUrTNQ8iVY9WLshrV/HW3KEz0Eag5RaAzLPnXOkpf9+8+/+G/16h99435jjZh4M8k+rmHFXQC6bacL40g4PKL+7EJ+9ut+dcRHCtXrb8avXIyVami0MZoof1QGvxviPbD7hgSkVdlkk1Yw7WjtJNVgEKbP6J67PBvPaatHl8auRIIGJlUGi0Yp27ltEO4Z9NGJQMOxgYdL6fj3l0qVBwwn9OH2Aqa6zeIsMp0QZCgsXW5MVx7KMYJBbT0JeTRMKj1RDdXmQrsorQY0dwY3QDycrBjdswdl2x3Jnq9/XEjo7rdeJmV13ufn+/tQ1OL5WcIl33jTipe+5POfeHOt/HN1sj++XQi3Qrwj3cdVNaiNbLTtbh8d6RfPd9R/xy9P+tCxdq2nZtPXrJGKWK2XwA4mSZtkEwUcuA6RDIzfBXYiQLUdrb9JbfkqA1iZceD0ZUspeSZiRF2JTIJti9MwQDPQ5iGNcRsNjfpoaRW20nhwDZT72a+7n1SC/DknkilCY4Y761kHsq0B1C1qU5qZJv6nqfg2AJsM+auNE1JSJ6FEEbfLom6WPevLMDTyj06H3H+cQt+fct/3g7b7ruTRh5Pzdkt40A8+/qSXP/2d73xNtXxhw83+7g6wWyHaqWhzJZHrQHUEO7gb447vto2nvffYV55zWvZsr377f8UuOxRtDBmigSRZIAa/C8bXJq39kRsg3BOALaL176ud+CIIFgUz76QZhy9gS00M5XRMMAwTdjk0mUHMQzg8EtlSyRcmrtLmVhP0AZXf5Hqz1lm8iNCNE85LV3FcEJNQtUGyCCNhwzXEVtEwToZ6NUG32cgm99aYBAHarFVOJQvS5soau/d3rmdxcjmiPbuItw7tfa2SNdK29Gzosh3LDnc7T+7g7t9ECA4apPCHqJFUfmzTAcRpItxcaOciqqhxIT/LarVqdPCWP0Ep2Bfc9kCoXeWR2oHsPiKe+n6PaE03eD/AZnJ9sJdUEEy7g9Pp4fbm8LoKeN3t5GZMI9PTR3vvTIoz5uIUZzrejAOPO3PBEa95Y616wYSXvXgNmE1KvBvoB0oKFUX6QKojhvGdkdUZh/Ye/OLDZ7xvVnD5N60b3+4g4Qja2JmAtogg0wWNoeT70VVQvidCjI+t3at2/BXNNyCuQQtLT5u+opdbhsRQT6lIoiiJccWkJVCI9uyxGtZARq948CEcxeQ6XTvvgzcuPvTUQ6fP9VGnDc91MJ6H4zt4RrBxssgFoxBGWBuDKJaYSGMiG6OS7AGIRXCwBBoRa4xK0qYO4phYLEqDOI5oNCImIkPjpiFqt9+wnejbh+7TKW8/5gjpOXi+LS0qH/OGJdn1ZUW3JwNxhE3UZ4r/0SDFBCVVIG2yOUsyeI+fRTN96KYbYWx4AOZkoRJBOUoSKH34PKJ7F3M8UPj2V1EjygMrtuiUtZQPYX1NSmJyAnkHOj1oz0JHAaZ14nZ14Pf2ke2d7eSmLfA7+2Zm2ntmF9o7Z+Y7in1t09o62/qydPRATyf09kBvJ+SLCRuGn4E4A/Xuev2ju1x//Z3gboNoOzCkUEpnV6sWkwUZ2YUGVbz80+2RXz4lWrVGzfhPYkTHE+WPSslx7WWROEA9DwZuRkZushhjiRsGO3FCEtynTMzSnmmbceDR8aJCNLZG3SQC0LQSki69ji0mB7p1CLSBxGN36QMu2EuY2Gzvay9Ydsy5h374i4WxOO/4w1PaQM05+2psbMNCPYSGuoQ2GVCrRWKCWG2tAVEoBgtRrLZZfGnOp8Qx1IIE3yd1iGtiGhpW61fd1Bvc/YufUvv5i9BK3BwOQjxxZp3zzZijouOfNc/tPUm49CeK1EHLFuJycjXzABskBF42QG3Kjt306hqD0wPqupmDbeS2P/t1bv0Vr7Pj9UEt17fEjca2sFrdEQUT24jGdsDgLhgagtESjFdhvJ6uLLGTq1IfsRPgQcpPe3+dESgYaPegOw+dbdDXi+mabrye6U5++lyvrWeB39E7L9PRPtPvbuvLd3b0Op1Z/M4M+b4cHV0OXjf4bdCeh/Z2yOaTbS04MY6JIuvUImvEotZGCqMibI2F3XXMeChmuCxmx2bHHd4MstUS9QPjJvH81XQ4ow4UIN6zHo3aOPr/vYDds9rM7jdFSFhCg60QjiVVChFQg/rdMHE17PgNaiQQGxbVjh2ONgamemqYPnP68gP9sQ6nGu+2vokMNkrBYBo2y4bgWuLtu7OYeqDB+J4HG8HU6S99fXb+ea96zfvbyhd7WvzZdRBXlaDJixUmBRYa6Xurpv2Gmuzl+0kMP8UkhRaiOFknFEfJ6WSjBLdvU6bbzAzL7EbAXV/vZfNvPgG3/1fyQLP3dTlzX/XmuPDsQ2ctn1k967+M/7nVIDtSNrhGNW0YVpNrH/hDShranAoTJ+HydJeDFyMnrsSddaIt+lA0TG/3zPS86nFhRSEQTFUJx0Mq4zG1kQZaDaiNl+u1kfHdwVhpdzQ+tCWeGLzXVoe3aTiwjXD3TuzQCAyXiQfqaM1iK/rw6NElJzg9HqboIW0ZnK52vOm9+L19kpk132S755JtX+B09s4n1z7b6WybWehq892ODH5XBrfdIdPhkGtzkTzJvh0PAlHiMI6CiKgaqR0KYhs3YqIxSzQIsRUTRWrCSIgsJmFEkCRbSji6U8rvFNkcS/LhV0hCnAlBhwTGk5AnYWpIDTkQ3HZoXD3KnKPPQc5fyh3vCJHhALV7oDGSeC6RBOyYW4JwL6z/CqpxXbBFbOnlaPW2v7hf3qLDZx06n4GGWobT54zSEqCNUk5QB5Gqtf39PozdSlyp/8XpmVaznN4Tjolnvu3L7/zg0vLm+Zr97sVCsFUxE7JX4TVMSW4DQQKdZGcIbMrLE0MUolHShRWtorY2aZSaciZKI4nH5x5lne49UXztx4q67epXqtn+TaydUl6OcKY/55h4/kc/1zcvV/23D+F/eysM30KyAWc0gmAIwtEEMBhVUiOo7+0HiKapiLjJMgNvAWSXIKW7qf/PFuq56Yxn2iDXHtCRgaJjTc5Yr83g+ljjKVJwcafljZctQrbHeI6Z67lmYSQ8KY4gHIdoCOyukHj7KGzdCaPrVxHd9UtqP/sS4frSQ+8Ic2flyJ1+Ft7ClbizjiE/93DpnV6kpw3pzeF0O5hOD+lyiT2DdZUKJtJGVNd6HMQ7Y6sbY2wlNDomhppxiY1LwxoiTZ7T0cnoypGUNiRlUHMUfEE8Se6VIfmdOyUyc9NYrwFan2QMpCyTXi+wBo1tkvu5xFGNzkYHs7/0PFZ/3cJtddTdntCe20r6QQm4i5F2B1Z9HIKJuhgpajTxBWzpu/edKASgsOK07kN7uHdIDJWUdzNKAV82TobEu1yIhiI7vNvHjlydlIj+cv7YbZvXE3W/7fLzXn9gNfcU/O9eJgRrwQwlU2haa4LsUvaFMEajtNkUpceCRoniNRUwaiRlyCYkQdPlYrYKcR5ZcGJEeJ0b/e6zeZ3YcArs+nMSa5k0yotwpp99ZLzwgpsWHl2ofuA/rPvNceGeK8D0K3YIqE4kfZOglAzW75MHRKDWqlqTDucnDbTiSsiGJFQwNSQaANsJ9YLRoQxQNNbttg23YBu+b2nLQ0EMLj5e7GICqFegUofqGJR2lSjtvJXKztU0dqyisWMd8dbtMFjCjkeJ95eHcQKEG6uEF/wU+GnygLzo5jYPOgpKd3dAZx/0LUKmLcXvOYhM2wKKPYtpa++mLQuFTqSjHSm4kM8h03KYrIeKY4mdAGsDbQjU04ZRw7hEQEWMRvFkddPYZLmDO2ULipNsC9Um7tymDGSRJJ6vodCIIawaNEySQ5sFz8OWqsx818ls2NxJ8H91i7vbUNsJdjxxn4ZE+WfMg7VvQoe3R+L5RcKRa7Ajb/3LZdUKjif+9MPPaFuUZXBj4FI3aBgmgK64nvKAKORcdGibpTICTuWafUczE5CXk+vyo663rnrSs07MH/JyL/ifq62ZWCOYPYodbYYzcbLw3KYJdtzYS/KZKFu4t+Q4SaKb/q7ZlSWCuIJklyMHHBvo5gvydvW3qjC+HEY27dtbAZnzr2fGsz/3++PPyNbPf0vsXrjDMVdeBc5uiAeAchminanyj6W8ifW9TS+xU2r/TjGhgfQXIvk5SLiaeCKAXK9Vd4aV9mmWQpeVomco+r4pOL5KLaGlD0swsgO7Z8DK+PBaHdu5ivKeG2gM3q529yYYGIHx4MErQg9rR5iwbxu6olAJYE8AjAIbgeubHpiGJ5QKDhSzUCwKXX1Kx1ykOA+/Y7Hmew+I8z3LpNA5n47uLJ1daDGHtOehJw+5LOIY1MvWjZ+LRF1sJIaaMQRiNCQxlmrq8Ss2OeojnSwSxOl0XFyDqGqSGnSQ4PCdIlrP0X1cB7uzPYx9rA6y29DYCdF4UvI0AjoLWXQ0DHwG3XRVJBnfEI7uVjt8ehIs30+N3pnVNn3+QYujHhtEV2AkYNIAbJzMysaaUH/2b03YnRm/5S+G7x0h7j3vwoXHvmDhM97bWf3f1ZE/fKWDGVDsSMLUSKMMYRpfN0OZprI34QZN8JlNt1/EwZS/SVezBlXoPBJZsrDObW8v6rqLb8apnUpcGptsUFkkU3S0743/ZWa9/UNnvzpfPeDZsfuBmxyz82bF9EO8R2CsAbWdUE9p46N9lR+N0ST2N0gO3D7IzIDcSuzsIJJSX+Qe+yw39oIsJgJbQqob0cF+dOMwdrz/HsaHbrTV4ZuIhu+C/vVQHlEqjTS+fQjCg4cmF3AfOgG+v3KnTqERDDWZ0hkrA2WFPcDtqlNouUczohR9aCtC1zTomKe0LYOOQ/E7D9dMfjnFznbaCmjBTwpF7XmkowgdHZHpaw+kvd2aTM6okzGxzRrBM5RTrNoIsLWRjiuO2b2teDQptxW7qIzkqf2wDuWtSeYWjUwqv80hi05AzB+xN/3ASiZriUq+xoNHomHt/pNVIHvogfMOXsywxAEDZBMDaAK/6glRVWShCNy7w0fLlri0675xv/ae+drCzJe+9AUf7yv/ZLvN7vyNWDMQGzsOlCvQGE3DimrqzVP2aRs1yzoWYpMoXTjZGbfRlGpUDA1wFp+F9FTq0WUvLjK45Rc45RcSV6dMWSm0HTBP82/+1czD/+WIJ7+pUN7dZbO/+J6BnYoZI+GvmqgmO9IaAxCMJQF4XE3r/w3ERslKVpsO27szwevBKazEXdxrg8EfZPXeNcQaotXybmqDN9EYWaUMr4byPVDpV6q1RL8eDpJnalUyfiT7AA9V7nywVn3TmBqaUBcPN2DLMLAOuBiAyIOo4FFpa9P+zjnY7EIoLIPi4SrFw3EyS2Ink8fPIhmD5HwoZNE2iUy7G4ibReYs9WXpWcSrvIS9NZpIFyeYJDlsq1L7jQfbt4C3LfnAdCJR5DiLzDkJmbsF+6NPgngBtlwkHjgOre950HuSP/LEaYe1sa5UN5QNGtjE+2vqAU0MxsF4Fav9232c4E7ien1qxcf0HHEs7a/9ytnvP7h8sSPZO3+ANQNgR2JLZdzQGEoSy7CaKHZUTxdvTIUWWJMofZCePJocWs29WAqYNsxhp1vRm6L4t+8vUhl9B874p4kbuteZ+W0u3qmvzcx82RcXvegk8qcVq5fcYbPjqwQJBGqKrURQn0iyzUZ/kvjGpcnOr21M2d6YLgbxZ0NmLnhLiHtnBWJvyesVP/4WrPmcUtsGjYkkvlMeuiw/VR/t/tAJfjjduAdpltmQZBX12AhsHwFu3/vPTkaQnI8WOwnbF2lYOFZLmaOx5nBiOcCq5iEApxB5rz4Cm+lBKyn8VoPE+5gYRkagtAFkKJ3sqk7G3+2HYA7PYn/9fqjW6+KFRa33vxRbvulBNhYixiA9R57eswz27MYQmAQitNdLp2uYfB90NNLBbT6mfj1hqHtJt4ozeq3zvOuf8W8rq9uOzfhr/ifC7FRjJwKojiSJZVie5B+KLNK1AlPIJ8T+krwOVJI9xzT3AU/lFzIYz4UOL9J1n3ajay7MI+7TkdGLkk2YgPEEWbzSFE/7ftspL1nY8fxDqgPVjDv81dhnVDDGYutBMtgejRuiEZsSZyXOJq5P0rmnAxBKymvqTYPiQdC+DJx5kZndn49+9t2bkStflZArPRBq4L669bieB/hrT5H0DUfNk2OsP+3rXp9+YAYnl0W8Il7f6dTMl8Kd12SZ9gLDOMnitLiWngIVGB1LDaKWtpDS3T8yH3PCIdgb/tvq5s0BRaeotcEvYUd+8FC8Qmp6vK65BxznzVA7vraJAK2lc65pDK4GKfgwts1qaRAoXdv0tiZT9K1z1g0HPPsZdvzFXea6L1hjtgp2ogTVgWQv2d6QIvW6vcdAfnPE1j8kQ+PaSMku4jTh1GRTpMY2BeIZ4hA1YUQ4UdTNt5Yw0ZHY0sb0PoKdtlT8g77kHXH6ad5ZzyXsmV/d9qfYZ3MFcUPQOjZORxltGcJKcspF1clqj22kpc6k2aXipYS+bZA7FOk9EDWzrXNwHX7zhzITP39a0sAy/xAlfxyA4R7MQOQvf7ahxYZVpLcL4zwXLbez6dZAjn8BuqEIDKSJYj1FFqaA/GY1ws1ANA05/iTYeiF64xURbbkitZ03Eu15y0OjT2PwD+ybvXR2e78fVbVffBNabFybnHoSTSjFsx4Mb0uST69yYzKE5orNnviTmUc+Z3HHuw+pXndB7Mutig1LUN2VxPxR2lFN2rhI+yHQU7V68fuzcWV8r8IkQzXRlIrSVJxPlP5NDMQ34wQnE1fLydBQfhHO7I86K57xQv/U52O7lpard9d93bjRx8SIH6NhmkjvTaarhrBup3Z592L/bYiqIHgJS7XpgNwhyPxDUafTOofYSH//57zd+vklsHv80Zjv/SeFQ+t9DMECuQze0f8Pr/s9hBtAth0vmzb9r3PKyHFx27RAS5vMpMePpwx0C7gp18yipyC5q7G/+qGlkDMSDg1ptONpCUDgYUjx2CPnHlpgd7luGTJJ03Rv2TFdjheBZCx2971ZNLLY+nYAzSx/a773ac+Z/j9PLa/+jZOVa0LUDkCwJwnRgnLqWdOTxJmHWTg7sn/+tyzVgR+S0QGseindlpeuoFdE42SXYzM50DjpwIY70cpXia2Cs0y82e+Txc94sRzyLOg9oFrbPG646uYsRpFsBrWCNmzax0jHG+M6xA2Lpptqmkm4bbKzCZBB3UyyBSR3KHLAIWg+Y53lccDvbi3a2z71FLhz4/6i/I+jeYCpN2zFYVI8/o9qxmdSWwvRjsPQ8du1NvSdeNeu47R7YcCol23G6klnyiYLFUwWJItMOw5ZPoT+9NMWx4mwY3ltbF6CNioPPaKYvo7uY5/edyDcPqiGsqCNlCjXpl05SQbiNWetDG7yobaWaKJCft5THT3+M7M+8Lzy3Wtz2fg31WTbYX1HWk1pdlDTWcqwiBx8ZN3e+t6i7rnkaTiV6wn85yRA1DhxtyIJ3kLUnYT+GwfUiLghTsFRKfy3ZHtPl/mnP4VZK9HsvKoOjRldf62PaLJ0ggxaCyYp1+PUqEkVPU6/38v6cJ8av5MBZkDXCjhoAdolNnsAUfjt9cX4uvc/Fa68en9S/seJATRvWM6I99x303v8BzRcW6W0HuI9J6Pjtyd/sv0XumHTlzlsmcuGdnAGUmduJ5djOz44SzBHT8de8XZ0ohZIJipqZdOTsJWdD638Kf7HaTP52Yec0TFX6b9RXKqgQWMKBiZKYRV5XFuN4qGNPoz9UDLt06kdePn0j5xf3pOdl21cUEZ0F1rbnZQRw1LKlBCmBpTFWXFG3e78VlHX/ej9OKUriLM3Sc/Ko9TNAAZJhtPB+ODmkp9NBrxcchkP9QqI4yGej0quqsMDhto1frImKZ/E63F9shsuThpJRekW7Shd/ZTCm5vxupgE52K8ZFGdzkdmHYAe3Quz46ij19D4/NZ8fON/PQX+tN8p/35uAGZKLHvofOn4l5/SM/8YHbl8gMqaPuLSv2KHr0xyAgW297Nh7Y1y7GnHaa6vTmO7m1CWpdU1kwE7G3PUMdi1n0I3bKxScNu1vO484tHrH9ZwehMA5y9rm7N84eJGMayHO40rgaBhSgO4t+4ukC2gOmZ0fJsVP7NIG11/yr70bDt+6HF+5bOjEO5Co4GkgxqMp/CBIHmuQJFFZwXENxT1mv/9Cab6QeLMt6Tn2KM0P22M6m5/L6OFbVjEgyiLFddgMuBmEUk3yOAkhqBqIPTx25L9YuKCjQ2arK1AZYoBNNkd0sGeqdh+JFF6k02WbTANcRbCivnoETn8hY2gUM3lKx+62wbr/u1guDwdc4z3Oy1z92/lN4g8/7nM+5dfaDaCoatGqNzZh068D7vtO/sutougsv4CRsaOk77uSLflXEwuMQ7jgO3ALH8KRL9Gr7s0oFBsp7L+C0R7vv/wmRnS15U/eumCgzNsq1UjBj1XAjsJNqM5ACIYL4eO3OESjlrVGef7x5+Be+4ro/KXxg21zWCHEsUPSwmArGk4cYj0nhyZznE//t1/7IRdL8LKs6V9xcspLixLdUsR0RQSEidlUBFEkzKkqKCxRaWRbuaQZCjHySZKayW5X4JJBpbTpRo2NokR7K31ppCTtKRr0pPB8ZLlfNoJZi7O3AXER3bA0sjOWtQIvJtzxV0fvenesP+1J8Ka/v1V+fdDA5BJ+jTm5KT45q/J8pNeqrUNVYbujJi4rRstfY9o4wfv/yi97Y9s2ooedKTL1i5wK2m50IXuE2HWVvSXFwbk2vNS3/JbDTe/9a+bKEr/bvoJp84/GG4YSyEaQZDi4FOcjiZcoDaTQcbXgtYwsxcHzhv/k8r3a4aRe4AhaIwnpcS92CGACMkeas3iRdZe+mKX2oYDERaRmfsrulaUtb4zKwgYH2mWG42DmAyabn9UcRLnkWyKQVUmB0ZSqEP6VhKIpujkoACSALGaYDgkzZ38dDNjAbQDtBe3Zzoc0U10nKFnQT1YXPf9Pd/xi9t+/IMvafVtb4PBcH9W/v3MAKbij45bbGa/41pdesB0239DlbEdSHlVu9qxa4g3vWIS2Xff8uk9A7rx7hvluGOO0+yMOvGYi2mAsxg5sID++b8irasv3vCQNu55wV9ifB7i9WkM+Ljzj3pW1xLYdjdJ/T8MUkWuT1aA1MUp+OjOzWB6yfznB0zjmm703uvAH4X6lCaSDZKTSkBkOrLkxMDe9PaiDlx3AMaGSPcG6XtSVcNRX2wM4qFikiF9cdPdS02ld/YqvTb5/vcu2vNTOHK6s0llyu2TFKtv0l1kXvrVRdw8KgXQHnCm4/V0wSFZwqOEtgPC6OCc2MJ1+fyaL/eXhm/7wDnYCy5LdH7/Vv79yACaIY8L/Mu5zlFv+In2ZK1uuKJKHBhKN7pEY1uxm09Lyi33DVnSJJcASqu+KKPPO077uiP25F1sD+bQFejaD1ndsSsiL75W7jwsyVr/ClKqZvyfWZqdc9CCo2kPovF+40pD0Kg+2bBqelTjgR/B9rVk3vBBgp1HYlevBm8IauNTlD+NswWIsrD8uXXd8ZWibvj5y3Hi9dj8HTLjuEiJDGHZ7N0EKe6kIRh37+9U3EkcfxraiPFRk0tw+Hjpwjx3UvFT40EcmxQLMuAUkoVm0oZqF8Ztw5nVjjnSJzwGehZH0cEZtV135vLrvhVxw2U/+gRj7/8A0T3VfUhy93Nx9x/l73El+6YvOE978etsdbBs11/q4+Rchv5sCYfReNOx2HL9gZW2+bvr/6Cbd2CWLXftrnnIgkVQ/jW65vqAfKFIdfUR2Ildfz0jW/o624+Yu3BFzh+MamX6naw0NIn/CfbdhOHliffcQ+4ZZxH1vIL4N9eDtxPqo0hYSelDojTpTDBLMvecQMJrinb1F74HE98lzn9Rph2zArejSm23L8afVHJpbn700pPA7A199hqIcdPNkNl0haqfVIucTHoSSOrpm5sks0AeTDc4XYibx3TnMUt9OMziHGLt/BlBdDCOyd+Zza79NVz1+8t+ard/9O2El++Y3MMQ83hhu3P3D+U/sNvMeOcfzEmnHhdvX1fSrdfnJT8NHbiiTjRSJN5+APHIwIMrbTOaWT/CxrWXccTSp9G5sE7fZtf+5pd1st1F6re+mHhozd9FR9h7zJGLlsG9o8CoJKOGUzujGqR7sxzM4vkEfYcT/3Y1yGaolSGqoHEtxean4UkcIt1nRKZj1LcXv2sdjLwcMs+RjsPeSGFeicr2fBLju4iTSao7aZgi4qHGTao9xp+i/EnMLk4uUXiTRU0mHUjJQuwnuZFkgRy4BSTbhunI4szMYBY42CVK23K1s+c3ooWe2pkD2WLpKt9fc3HM2j9f9i12fvEjBL/amNx6edx4/f3AAKZ2dZ+6wj3s3bfKsYe44U1XlRi+M09hLjp4XZ3GriJx/3OJd69/eErrABE6cs1XGDvraXJkNtJLfx1R94u4695FuPlHf7vyx8kjZx31jJ658Mft4lIRtBGm+J8mDj5Mwo6ci+k6iOia1RCtTf+mMZko2yhRUrWQPcyaRQusvfylrja2HAnRfHJLf0nHshK1PVk1WYvxDcYBJ4uKn5Y4vUnPrplEmdVLwhzNAUVUc6B5MDnwiwmTgJNBCllMWwbp8HG7HZhusH3GypzYts+3tqc9tAsx/qKxjF+7Dn/DjXDN9bu3D9/1x88y8M3v0rh2eN/7Hj/+OE4fGwOYqoDnnu6d9O8XccC8enjlFQHlNXny82D0joDq+iJa/hjRhl89fKVtjpNdfbkMloC70E27i2R3/Zr67Z/425U/xe07s52+hQc+3emI7Z6bxFBRtFGbggCNkgZtFCD5HPHNN8P47Ul4FFUnlR+bemsDMhOz/JRIb35HXodvXI5RcGbfS89RVa0PZMGYpFlVALcTNQVwCqjbBl4Xmm0HL4d4WchkET+LyWeRYsaafAaT83EKGaKcY20BNAtk1bpFIKOWDGQKYnzfuG7s+MWKQ9t14N8LmzeEXL1h3c3lLdf/mLFLf0ftsnuJ++N9Nu9o/Ljz+o+hATRDHg+Rf3uH+5w3fCIu5sr2kot84g0uudlIpT/S0qo8El9H467/99eVKZth0NoRe/N1f0JGTscb30hw4wv3lln+5oXZQMcx05ce3j19jFrV7nZ8U1fs3vnfBBqgGiDGQce3o8FY2hMIJiESqonXdnyI8pjlZ9fZ/pWi3fSzF2Ma90LXeplxilHbMCgmSUhnIYvPi+iYZsUzqOdYdQWyrsF3wAOyAi4Gxxp8NergWleMGouVKlbAlh3MeFIcjSsx1DzcAOxgjcZQicp4uX9ofM8Nwej6K6ncfj3hrXcTry1BTffl32Fy6OZxLu4/Xvk7jGTe/D/eS171H3EpLNmrL8tjtoJTQMLQ6sifLY5bpn7nM5JpoL/Wa6fHcfmyryEHPR37+2OwE42/j4Y8NZye445ctAw2TqilREo3Uk4xQI1JRmRAazsSCpIm652mDBEmm3j/0EUWnxMQXFu0q7/4HWTsR2jHF2X6k5eicRVb9cXtha4TLItOixi7LM/Nl6COv/dEanZqRZ0kHNIYVZvi5EwV7ASRKYNTIWIM9SasdUeI6gMaVHYg8a5AyzuJRwbRbTthoHq/o4biTFF6yz+TuP9Y5e91pO2Dv/Re+vxnhTvHynrz5Xm83WAFcXvRgV8GQJFgw2HY8dLfprTpB6SXXgo3H4wdHP37MSipp5u78tnzl8ANw8YwLglwzJZSHM1keKM2BhsZNKUl1LRbbb0kIbUezDgtMh0j2fg3H1yDDP0rmnmRdB76RvxpZa1ty4o7GxafH5gZM3275mt53fSba9DRLwNl0BE0biBaAltP6AEk2stHqJrCOMM4OfnSztxDIZ28J8/T+I4dyeB12pBU/afw9I+hATSVb4bndH7gd+75Lzg9uKO/rOuvyZIZTOC/mYXoyI0BYamIjr2baOftf7vHbk74bZoA1v79q3WaALhppnvugWc2upXN68RlHLRem8T/7J3PbZCUZJqzqc1F1G7i/XGh/VjrLp5h4z+8DBp3rcS4S6TtqB9SXFTW8sas9JwaMe/Zltrt+fjiD5corTsPs+d3CQfMX8Ps/CCfScr3k2jBKQuQM96l9ucfTBai8bhMaPdDA2gq/2zfdH/0SvOKZx0f3DFY1ntvyOKlw9SZWUh9MNLyXT5i7iRc/7FH5gN4hLaLNAdgciu6Fi6ZNnvABPVop7imBra5AHov/01kxMbpkMqUgW2TSeDCJgvuQuTAw4P4+v9X1KFr5iMK/oJ7tTi/KnHoy4JX1WmfU9R7vw7b//Rh2PFRqNQmS41/6zzFfaAmaoG+vJn+ro/TWPJ0O/72I9EN5cflxpr9c0FGU/lnek7XJ6/0Xnn28dEtI2W996YsTjrobTIIeXTkOovJuET3nImG9pFZG/pIjdilr6XzmOWzDxQ2l21Ev0A9SjhwmnuDkz5AArLR2KJR8j5MLkFeOllgOubI0+psvLCo937vbEx5G+78VXQcFGFyAfP+xWg4XtTr3nYJ276zEF3/HrRS+4tR0b/qum/1zQKeI+3nvsQc/NMKdC6w4y8/KFF+84RS/kfxBEiVX6Y5UvzUJe7rnnF8cNt4VTffksUbTKgINYDsgejgVQG2nkdH3kw8uH3/80BpRNC38vTuxbBqF4ZRSajA44l07U9jLwZIie1kmOEntXmvDeJO5IDTAhm/rGiv/9LnYOg3aO8FtC1dQeexY2RmduqmH5cYvOgFMHYJRPqXZeNH4iQ85gRz4Ku+rh0nHaB3ffX1OvHZr/zl0FHLAP7+Or/kRLz3Xui+8syTgttrZV13axZ/ABqlhJbPn4VU91itrHfFyfVrfdMF7I/LOtSCFKR9zopn60yl/zpxqYDWy8kpFteTWF+mKJk4IDmDyVrcYgIbXnBKZNq2Z+Mff/BmZOPboO3Z0n386+g6Cq30d7LpO+8mvOczyQa++4IDHwnF71tE9zmfdo5703N0Tw298a1PQv90/eTfPvGU/1EwgGbCp4j+53u9l53z8nDAKevd61LPP5bEzJJB3D60/2eRmGxew60vQuvRfuf9mwC47Iq2hSvmHzbiBYHdboypWWw0kXKKBpPrf5o5g8mkmJucwXRYeo+y7jJD/MMPBwRrViIyj46Vvya/FN1z+e8pr3kdTOx4ZBT/vqdGdx/m6PfKyn97o8w9Hnv1H27VnR85E+7dMxnyKE9UcR/50CcGfdGp3jkveX/kdZf1pjuyZHdDLfX8GiDZhVDeHBEOZVWcW4l2XLF/Vh6aAzBHLu87wDObStWA3V5Wq42UB7O2d1JKSAdvcFGnAG6bxXQYssuM86RFgf7ivXkdvGQOJoLsMVtFzVbd9X+vJN55eXpkPgJJ+1TjyWcwS14vC17yWfOUV6CjE+ivP/Q5rX3rnVAOn6ghz6NoAKnyc8x096i3XBIvnlO2v93h421Nqf3KaTOoAKYTxi+OMPks0aY3JPHu/lh9SBVk2lPO7FwON+2UpP5fr+7F9ohGaQiUojElm0CJ/Wmgs6xzyhEBq36cj+/+4ak4pV24h91JXHqnVld9LqV4e4Ti/Kbi+w5m0TnSe9aX5dh/7WXBUuy1F0V662fOgisvfiLH+4+iAaRHqfQ60v1fl3LGiii+qOLCRkM4lmxe0XriKbPz0cpOSzCSF8fbqdHum/ZP75/G/6YoncuOOjeYp4z/2XGlatGgtDf8UY2T/VjiJEmvk4dMD9gZyIlHB4yuzscXf+XTODsuw8w7l2jb04mHtj9ycX7z8a4gs1eazid/S5e/YhnHPTWQ6hD64/+5TocufA5sG9wXhNiSR/gEUIQ3/Jdz7gkrottMmbGNSbkzSkcFASQDpgsmrg4wWV/jgY8kVM/7offfOwB/QNvcg+YfNJgJA3aIkXoDjcYtcc1ggwT8JsmQuJgCmukBZiFHHBa5vUP58GNfuAq5+Z2oa4h2/SwhEH0kFd8DZhwhnUd+Vua98CQOfVYgi3OBXnedH1/6+dejv/sa1G3L6z9qBtC8sSfONye98EPW6yizrj+L258QPDW3hGDBm5GwJ9R2G9wChIO/YH9npcgfsbjrYJ9NI7WAHW5W61WISoaolnDfQzpxlUH9TqAPWXyA9Z7kEL//i2PU/nAmNOykrssjpPgOMG2ZtB36WVn43DN10XPQAzpGTFDq1u98a51u+caZcPvmVsjzqBpAs+RZFNP5hh/KyfOj+Pfq4u1JueKrkwhIFPF70YntFkweG61Dm8ui98cqRKIwTt+TzrAHwu6NGEYVDSeS+n9cTyA3TYiD2wHONCgsxD29O7AXfrMY7/jR4TBeuf/55b9R8cUBnbZY8ss/KMue82Kd82x0ycwR0+t16w3XdNuLvv/fGv78UwnhsHnEWJRbBvCgVZ9zTnLPPuVJ4U6vTGk4ixmfgpEJEnIlcuD3IMEtkZqij478EQ330/pbs/6flbbFR72oNhPiVcaVoIEGo+mSimhy+sptS+J+nY/3vHl1c8VlxcZ13/gX2Lb+7/O+f6H4C6Vw6AdZctpLmXcmtndxyawQ44yPdMff/PU6u+mrZ8Ot97S8/j9sT3CceP+Zz/uCPbAj0p+qjz+W7G7aOyObIiHdNpQCNMaTnaFR5ZZHpgLyaMb/y4p9h8xbMSZxwA5jCKrpIohU+Z204pPtgnAG8vSlQWZwXbHy/S9/AeeWnxD/rQ2mfZJboG+R5A56P4tOP08WPxPbvrhsDrSRO8N22t/cTvSrb75J+b+vJItKWl7/H2QATe//1APktJUr4m2mSq3mJ2jdOhBOsiOIAacbiWI0qiXJsDa27b+3Ja2W5I5aUVjRbjYOhAEDktWw+d7S0MdxIdMBdiZy2MFRoa8/W33X5+5ULn97gj6Wv7Fz21T86QdLxxEfkcWnnc2C07DekqrOsZFzhMk7G8bd+D2/vCze+eWXw207W17/H24AyY2W4plvdg7vwv5RwW1Ao7mOM91GiJc0iNw2cFNouvEhWfu2f0q6AdLtOf6Z8XJhYpMaKjYFvoUgBnGyqJtHmIbOXWZzJ4oN3vP1ui3/+kSo/hVd7fs2wDIG+o6UjsM+IsuecbosfjqxzK3SodZZqbhi2+2Ft1SDP3/tXPjJr5JprZbX/wcbQNPTzMn4R698mTpEOoqfLK+dMhytMrniUXIJNTm5pFkk2eL+GQKlYYtpN50HHvuSaBboFcaVqIbaavJqjY86HpguNLuQ4vMKgV74s2Kw9SdHwvDYw/PE9y2F5jKY2U+XzqM/wZIzlsn8U1BvZtU6YpyjQ1s8KFOMfz9O9Wvf/ZKtfu4/YUul5fUfMwNoeq2jlvjHLspXt9kyShaxydI5x0/YCTQdCRQP1ADtSR9AFKTjAOCK/S/+by7AOGhax5Fz549EUZ1d4jaZn9U4IIVk+6TOx3lWX50rry1WLv78v8H6Wx8cWHbfapAB8r14C/9Vek/4f8x7Wqf0HYM6M8o2NC4HhHSf4Lm5jZns6BuvvLl6zydfivxxHXtHP21L+R/LKpB4R53qzM0T3xwn4Y2VJNwRPwGEaZMpzQMVTHsXsd9liEbAmX0OmK/stx9g8ehjMkd1sGOHjRgTV8NawqQoWXAzaDwTc9KcIFvbUqx85dM/waz6UkI6qw/D27sOpuswcsveJX0nvoDZJ0LbEovtKtsJ3+fA0O14tkdPLZcf/8yW8q6LvnSe8vXfwLhNTlV5XDMx/BMYQHLzpWvBcXGHgUrk4gpEZi9TGcYD9VN25nyyDy+bQzrnujowWsef81SCGe3Eu0v7VS8gHfr2ph//7MZSl8bqhpHAolEjLXlmQHvhwLk2v3TCbfz7F/pV//zyvYsiHtDbA2Q7cWf8i7SteCc9xy+k63C0bXod8S2jnst03y2em486Znv5+Gdltv/oW+8PK5/6BGyoPd75d/6JDED2VilMZ+dczcnkZ2NSqj7jJkRNJs3PTDbh1amHyNIjDQP9Ab7Nkln5Rqo//9j+M4nUfG89bvuBh57daFfLFuMmW1I0ZUZug+IMCqc7UfSxC/PhwI+PhGrj/vlKAVwfaT+a7Lw3S8eKF9JxEOTno16hjAldJuoubfOs+8zOoOdIv1i4ocGe9/7uJ9Wdn3obXLl733Cn5fX3oxDIFckWc07Ct2rwgdCHON1YQrjvTKzrwXgNOWYZrN/sa+XuOoUj3k/jpguIt4/tF8lcM/73VsxqO2Ze38hEVGVAfI3TGV+nA7QH55mZuv35H4r1Vd98Jgzu+svXbgxSWIrT83Jy814rHQd2074IFT9ACAgHfaI4i7/MylEr6u6TC8XcrjF/4i2XXdV/74Vvgl/cPpkj0FL8/dMAYiW0oWSADFZ8jNbTxQk2fx+mZD9JjLHYcQ9zyjFG/280YnrFhdddyvCnVmJHw0mmscfYDjqPPylzdDuVraGlnJZF/QIEecyphcDbfGux9oNPfh7W/X6yJGwMkpuL23EOmemvk+ycZWSmgd9hMU5Z63tcnKyL6criz7ey+Ii6HDO3SHXYjz996brS7T98Nfz62mSp+OODWvwJagDNoz2EsdHtDhxPm6AjgGsgbk+IojRKKkIaJ2ERPvgKW+rIGdMpnH2aX7nopkCmzzpK/f/6JXs+8hzi8ShZ4fkYxbmp8RUWHv+CeLEQ/xFXVFHHgagdDi9Yt6vfD9/3uYsxq96Kug6SnYsUnidux2vU714mmU7U6wDVMvG40UbDxStmkTx406zMOirgoOVFkYrPT3+11a752RvgkougFO+r+C3l349PgORDikbuvdaM6PNkNpHuxMUjCYG0K8H/WDcdFncSdgTjIxkhvjki84IZtBWe4u+5aEeVvsVnmY7l19lt7z+T8q1DSRThpqt59B8Y/lhwFubzxx12xohjI/bg4glEHsw0ZI6vE77zY9jyNVeL3/VO1eybxGRnq5MDrwjGq2qy8MJVJ5vFyaUbVjoimXl0JAsOLxKrr5f9YaNd9+M3wg2XQSlqxfmP0zKoNm6+NF4XGvcwCNcA+bQSpG3gGIizKWmsk1KDtKOOgxgYuSJi3os6OWB5m3/PLxpVWzjoGDPjhEHZ+umz7eYv/FbthP4FLd+jYgyyb3Mve/Sh2eNn+LsHojIVsnjJ0/pnODjf/oFprLvESkY/pLaQlnypoiEaVV0xWV9N0vkWcVC3PZLuQ63MPD6vgWKv/MWd7Lzo7bD6cpiI9xkmain+YyLO3/fw4VGtnfWGwrl9xfomLIFI8jkaIOWid3LgFhNiKNdLSFyLguRhfNCSfzo89XTXceth0N+ej/TA085j3jlnOGTXy8SWXRqV7D7LsiVd+rZXceUBMDfyEBf3C+1wZ5//LueNTz62vI1IdoqjdYs5xcO962pqF3wavAEVq6EYDUSMIo4rxnfEyYmKC45jyfaG0n6Ymu6VWeJ2T+/+4++5+4svYeLn74MNGxP+TQNPIAa2f0IDMEDZxnv6RgvHn/icxiKt6YY0DBJJ4n9J1nPi+uA5kElPiYJApyA9wnhdqC1UnnuWmKcfosabH9YHls1YWF94+vna+7JX4h1kiBrbJRquENf0/kmf/ub34OAUO3B7lojXfQaZw/+z/bhXn+ecO0urt6gjAzGywifbsYfgnR9G4zsQrKi4RoznqPgixkXFQYwbSaY7kI6Dc5Jf4VGNXN1+8dfZ8Z3nU7/4y9C/K5l9bik++x/s8e+ZA57teQf8cU/x+0vzo78TIzvEaA2oarJUvNkfctIVVTmgQ6AXpA9ys5WuaTBjpvKkPuFZvmBCtRf32+DqO/3ivbcahu8A3bhhOwPX/4mJqy+hfuftRP0D2PEqthFBaO+nepQuyTIeeFlMph2TmYZTXIhTPBCneAwmd7gYMxsi0BIaHMDcd70/Gn/pfEo/isAVMida4td+gOiO/0O8asLCLE4yB2zcCL8tkkyvT2a2j+bRytB2yus+QrTxpzA+8hf3q6X4/ywGMBWI9bLju1/+5evlnW5p+NtOXkqKBpqMBDTL2S7J+GqbQDdID7i9UJwG03ugr13pLCjtGSGrgquKF6ttlG20ZZewYVM2P7YF6ptqBDu2Eg/dDeVNgVb7R4kmhiVu1FBrkTgpORmvA5w2nLZ23Pa0OZcqYDQK4SgajkCjvy7aiNQRTO4F7qLvvcndmM2hV4a4p2cwX/gZwfc/gngD6RYWYzFOhFcw+D1ZnM7E9uqD36G+5QvYPbdBGN1/R7gl/2QTYTZ17d+9YeR7S9/Q3fvvXy6eR6n8a5NnRJK5kuZeCk+gALSBdIHfDdl2pa0oFHOK50Jshf4JGK0pg2UYrRhTLxufCcUzjUCWaESfY6WyCBmc6zLRcKVSm04jnC61CGpVCANsvQH1KoRlS2M0oDFgtbHbEoxa4lGISkbimhEbGtXIRXCxnXQsOxyzNIdeG+CckMW/7maq3/8K4o1E4Efqeq6YfBa3zUcyaK18McHmbxAPXASV0gNj+1vyTzwUn250570XjHzGa58ev+3jxTdS7b8eV7eKaS4hVF+ggKGoNtMGhTZoaxPa2zD5rFhEKdehGghjE1AaVRqjSjwqxMNC0C+GIfUZt8kkQd2B0LUoAdEEBEOWeNgQjkBcgmgc4nEknjAaV00yntlIL0VxEEm2qgsRGnUz7dilhL6BLodiYyCqffDrEe4GH8lm1W0DDKrBjdR2fZVo5Hfo+OCDg95a8gQwAN1bpRTvv/+n/wulrT0b3vWjBe8tUjqyXh5e7/haF+PkFTeHdX3oKEJbHtpykPWxxkAUwXgNRirK+BjURiEcBh0DRhUmSNAVmtbrpQo6ZLAjEI9CPGSIUvY5WyWJvyyKYxEv2UOqU5ZCK8kiCxVwXUtmudGVveyuQeciJ2qc97NsMLoKyXWhNvoT4eB3iUuXYSuDzWUTLW/fMoApH76kM+4f/fHwH1ZdV177yd8e8JbDDj35OTGb3aB855jj21BMhwczs1DwIeMpYoRGCJVQKNWhXFbqKfECFUFKoOV0fqwK1IAwTKnJq8mAelSFOEgaZzaa3NjYVPDmRnTSvVYaWgSLU4hErK/q+22LT46CZQXCnI3a/ndVdmz1774p2V3f1KBxO3ZiYt/VQC2lb5VBH+y/1A3jcflnX++/Ir6jdNMBJx6V7+w580DHWTEvqPd1aexlkExGxBgIVagHUA6gVIVyTQhKgo4LOq4wLjAhadgDNGKIKxCW0m3rFUNc14SjM0wVP93VZUOwNUm4+jXGyQXid1m8Xh9vuofb44vGDpXswLRTz8tlzu8I5JfDuZH3fOLr6vzy1QTl7WgjaBr4I7O3oCX/RFWgh1hUB+DM9eh+zWmdR5734WNPnH/ECafCihUQZxr1TdZGt4mYdRNitg+JGR8SEwwDAwpDwJjAODCuUNbECBpxMpsbjUI4knwfNhfVlS1x1aKBRUzSQHNyLm4+SxwiUR2CfqhuLmmw83eEu38m8a7L1DznxAN+cOHvsieY+vpjfrattvtVB6OVqFW6bBnA3/lfm0lDcDuEwmlzWHzui/uOPu6FKw6dd8Thy2HaHBjqgE2Z2N4Ta7C7pHZit9poN2g/MCCGMRJDqAB1tUQkSYM2kksCg1gXE/sShxBZpDqKrQ4htQG0cs92yusuJdx6EdGuVej4DoiCvXHg3G986hlXn/+2m99yj9n163Pnwu07WrO2LQN45J6iibNviukQikd20nfiYfQee1pb9+KTu7t6V/jT29qDHkO501LPCoGjxLGFSNFqBA0LExFMBMh4A+p1dKyEVkaR6gCU9gxodXATlR1rqG28lmjgDuzoNpgY/8v9nmmZVvu8WS9ftXXmEX0zb37rq58J3/t9C4rcMoBHzxCS8su+/2RyYKZ7ML0Ifd043dNxir2Y7DTx3HbV2McGHram2EqJuFwlqkyg5QFsaSjpuJYnoFbbtwn1YG81OZ3EP23OjDddvH3wR1/7RLT7tf+JtpS/Jf8QY0hpBcU8Snb9EOC3FGUqcz75Guegddugy3nU9wa2pCUPejqIs++VDBo/jEv+tiqN5KDnoqsxK2e0lL8lT7zIz5nlkTllXkv5W/IEl5byt6QlLWlJS1rSkpa0pCUtaUlLWtKSlrSkJS1pSUta0pKWtKQlLWlJS1rSkpa0pCUtaUlLWtKSlrSkJS1pSUta0pKWtKQlLWlJS1rSkpa0pCUtaUlLWtKSlrSkJS1pSUta0pKWtKQlLWlJS1rSkpa0pCUtaUlLWtKSlrSkJY++/H8HZPlBWVz+ZgAAAABJRU5ErkJggg==") or "rbxassetid://102076719808486",
    LogoGlow = Color3.fromRGB(45, 120, 255),
    Footer = PULSE_VERSION,
    Accent = Color3.fromHex("595959"),
    Key = Enum.KeyCode.LeftControl,
    Size = Vector2.new(676, 585),
    Scale = 0.74,
    SidebarWidth = 199,
    Density = "Comfortable",
    Base = "Midnight",
    CardStyle = "Frosted",
    Background = "Grid",
    GuiName = "PulseKukirinHub",
    Blur = true,
    SearchText = "Search",
    StateDefaults = DEFAULTS,
})
K.W = W
local function toast(title, text, kind)
    pcall(function() W:Notify({ Title = title, Text = text, Kind = kind or "info" }) end)
end

pcall(function()
    local logo = Fs.asset("PulseHubKukirin/discord_logo_v1.png", "iVBORw0KGgoAAAANSUhEUgAAAIAAAABhCAYAAAAeJqnsAAAO8klEQVR42u2daZBcVRXHf+/1DAkJCZnImqGSMmyShBDWKhbZLMpCBRWoKJuAJRW1RJaUfhBLCsG1KigQQSjcZZMSBEpBhQ9GAUkQUFmiEsRoAgkkkIEQZqb7XT/cczNnbl739PK2nrxb1dU9Pa/fO/ee/z3n3HPPOTcwxlDQFsgrlL9rgIm5xhSAzji6KvI5kv8XcqCDggHAMTwAqjH/7wVmA4fL/+/IGQTu2WfL5z8DrwKbYq7tkWujIoGhCAAI5WVkluu2D3AocCRwBLAHMEtJhTnAShn8KGO6K/LMucDflZR6XWhaDjwGPA28EPNbR3O0PQLAMd0fgD2AQ4ThJwEHAzvE/H4QmADcDpwlA1rLAQA14BfAGcCQ0OS3IeAfwD0iIZYDG2LURS5gyBIAgZrpuqPvBk4HjgGOBfq83zndH6gXSq/OkwFuVgoEY/zftDD7FwBPKFAbT+9rW8C19cAjwB+B+z3pEKp+mPECANcpPUP3B04GPggcBUxS/3MzIfQY7req6NVbgXPkcxTzG+Mxplma9bt/r1DZIB9TtNQDlFF9Cj3p8DhwN3Av8G8PZCZtqZAWAAIl4t0D+oBTgY8DJ3jisuoZgM00d99hAdRLLdK4s2JGVMdwa9TmAU8qfd4K3W5cNGg2A8tErT0AvJaFVEgDAKGH2oOBc2WmzPBEOy0yvZ4UWAJ8BdgNmCnP2QPoB/aS7wF2V4M+XX2uil4OxL5wg78WeAVYI+9rgdVi6V8PXDDG7G8WDHiqYr1IhZ+I3VBvbAsHALcs2kHE8rnA8QkzPa69A2wUKbNjyiptC/AGsIssS5Nq9cDwa5EKd4nKSHTZmyQAHDoPFILneoxPmun1WpzjJYgxAIMGxp+J+c53TKXZ3JJYS5ZngTNlyZmYJEgKAFp/LxexPyzfVTIaMNOiLu7kWWQEZjd5IpE2z8oyuZaUTRAmOPtrwOWK+b0ZMZ82DMgkXNRZ+ht6ZUznAt9SErUQEsA5ROYDf8mYGdtT02rhGPEldOwACxOYDa7doHRWyfz0JI+Rse5NYqw7BYAT/YuAo2VJVCl5lbr7eT5wSRKqoBMV4B68G/A8MDVhu6JsjQ3eN4H3iM+AdlcFYYciKQKuAqYpV2fZ0lcFEdaTebVyf2cqAZwoOhDrDi0Nv+ylgGP8YcBT7RqEnc7YJaXhl5sUcPxb0sIuZiIAcEg7EbtnXysNv1wNwhOwm2xRO3xoRwW4fe8V2GidEgD5NbcKeEpUQcuRUWGbYVCnlswvjBSIsO7htqRAqxLAzf4nsC7fqARAd0uBsM3Zf0jJ/PEhBVqRAA4sK8rZP36kQLMSwMXbvb+c/eNLCoQtBFkAfKGoGS5l2+oL+FIrfoGwBXQdIWtOU87+wkoBI3w6rlkp0IoReFEnmw5ly6Q53ixOygh0sWczsckXE0q3b+FVgHufjw0haxg/GDYpIS4AJoq1WTKfQu8RuBXBpc1M1kYSwP1wgsz+meWWb9dIgQAbuj4bm6xaN5Q8HMOoADhFmF8rmd9VUmAaNvUuaGQMhk3E119YLv26VhKcO1Z+YT0VoI2/laL/S+Ov+9TAFmBfbGpbrDEYjiEZTsOmWpXGX/epgarw7oxGGU3hGOvJ08qZ3/VRQ2c0UgNxKsCJitki/nuVSClb9/kEqsABwKo4NRA2KOhwqjC/WgDmu6yYWtGKLMUEatbqVDTLazXQi03Nj+V32MD6/2jO4t+oSmFuKVNRADUFGGjjlbAJFZ2BmoEmZzXwYUan59dVAU5E9AP/EiMiD/FfiymYsBoYYKQIxNQG1+dB44DQuF5om6kKU+RFo+PdO9iKa9usBnrq6P8TlPVfySHrpQK8DNwC/Ap4EevZQlX62A84H5sznzWt7llbsLUQfgz8E1inrpkmdtRHgE8Be9apYZSFGpiI3SW8Z5tnG2P0q0fef2RsGzbZtUhexhhzjTGmz6MtMMaE3ncYY/Y1xjyYIb3uGQ/Ks316QqFVf9cnffL7aTKk9zsejzHG4A8wxpiKMWal/KiWIfOr8n6xB8i4AQ2ETt2ZazMAgbv3tR6NlTo0hh6NF3t9zaI5Hq7w+LwNANzs2l8INBkS6Z53jtDQGzOg9V6hon2pd780aFwa89yxXoH0CemjyRAE7hlbjDH9Hq9HrQLc5yNFv2W1/HP69Frg56oahmmxJlAPNmjloRQqhzoaH5Jn9LRYw89In3aQPn5VRVplbQeMWtnFLQOPINsIllAMqC8q4LVrPBrg8zLYSVXTcpb0sNxbP6vVNix9vFpWWWFGIHC0HtsIAG7GHJrh+t9Zxd+j8xJornzK88BtqnhFUiHXt8m9ezq4rwbT1zKsdO74fIzvD3B+AEfIdGy50qkZrP/d/TdiCx281kmWK6MDWI/E1tBJIoDF3eNobPXvToHlxnSyjPUuGY7127I0Xed47tfEnSPMjzKQAG4Qf4OtvBkmMBsilbq2KgER65i/Su6ZRO1eV2v4LeC39Tx0KZ1rMEkAsJXnoYfKw3KI/H0kQeeIcyINqSrenQIAudeQCr1OquDTnzL2XIKtq7yV5754PIhszwxAxGCSR6o4IK1MkNaVCdtFrr+rcqirNCeOCbHoyGijYiCl+68u6L3iZmWWG0MHaFtL76xNxh7ekAUijVfoGZK3hqsFvVeciskSAPsqQzbQhZ1mMHr3KquTtvpSkjrTCnqvuPuaDAHQLyuPbcq2z1BWc5Chc2LPFAAQMLpaeadtbgr0aX2cZbzATtizFPAlwF4ZiyXX6eMSHtyaOkuoU2AF6nQQk6DOdn0/MIcIIc3rWABkvQo4PMHBDZVUWZCAPeN+u0BJqjChQo8TgPdmvAowSg1sBYBr78oBAJEsPU9KKO08VMkskxLY0HLh1ZNUgkyYUBr3B4QReWRczdIAMKrmLzmFLH2zzqke7QBqOvCZhJilQbUIG3nUiY0UqD5fTn7NrfaMBsCuOQSBum3bQ4DzYo5JaaW5MjZLxMiJEgRAJEbyVer0jnZprElf8yizF6gDOgEi7SufTn5Hx9aA62RQhtsY4F6sq/YUbJxg0gPraFwszxhqk8Zh6eN1OSfbVog57XJ6TmHgzi8+BXuS5jwZqJ4mBqgi1w0LY25PKYVdn4N4OzZnwtFYaQI8jsZ50scpORw9o3m7u5YAqFh2cpQCkVjay7Bx7FWlbx2je7xBr8l1FwL3Yb2ZaQ2su+9k7Cmfl8mzax4YNY3O4q9Kn5ap6OAw5/Ee9WGqWgUEOYOgDxsKfit2X98oRle9QT9JZtTN3slhaXswjdga9wMfUirCp9GIfXOr9KmvaEU2XEBIHzb2floB8gD9Y9lWYGvdPIeNG+gXD9pctXuZx6DqZz4D/E1oXCMG9Rzsxsth3jZyUIC08Q3YuICBIgKAFjJpTM5FK5s9ELMoRbUdbzcJADb2QKHr3tEg/y/M8GDKsWiM6rjQgwLQ2CgegSIDgJhzdIvawm6tn1QWfdrOWwmAEgBlKwFQtu0eAHm4JctGrkWljQbAILbYQdnYLgpHvS6+gK0A2MxIBQ6TFxq309M/82gDzimk168bcwCA9qRVtxMgGBWpFGacG6AlwDYxgetyAEAFm3XzBtYpFRS8FFwSJeQC6esb0vdKDgB4NQ4AmzIsuxZhgyq+j93QOQj4rhBW8aRCrUvBoHcxtUv4Vemr6/fNCvRZ0bQ5Lij0OTX4aYolJ/ZvxMbuDWFTry7F7vB9GniU0QEX3QIGn+k6YOVR6dtc6etq6fsimQhpj3ukQPjs1tWfqhkz0RhzhSoqNJxy3Zo3jTG3GGNm1qmrs58xZrEx5jFjzGBM4aNhec+y4lZcPzQtug0K7YulL3F9nCljMJByP4bVuF1hjNnR1QmKqxV8NHANtlRMlIHDaAPwQ3nmK4wET+p8vP2x5U5PZqSGgY/uyPNpBClk8+os5rgNoAGRpA8Ad2JPWiGmT/3AxcAnSTccX/PvOZG4y2hQKdQR2YuNeLlIJUdWUnAW6X3y9dgCSjcwkjbdq4wnVNLHfGw00PuwFTB3amKZaRrEyJkGIWCNwP8W8ALwMPB7bFDIy56RG4oKANgb+Cz2IIddU4wVMF6E9VLseYJv+pMrTgLoClvHY+v3zMmQ2M3YmLsbGSmgEKr4Op/gGdiqoQdhgy5ny3ezsHH8SbQtwH+AtdjAmWeAv2KLW62NAU7Fk0rHYQ/eWqhoymJSvQh8TiQScdXT6p0YEqiKXVOwSQyXYNOZak3MjCSAgBhO14s4Db1nBw3StgMRsztjI2B3k/ddVVrUZCV+NyjLeI1Y6utEKq2TFdKaBgaoLhtnVLT1WTLjj2J0qnkajI9UdtWgrDS+IbRX6i2txzo3UCNmAfB10cOuI2GKQHADuxC4q0Htv8ALy4pSXFLp/poG/gpH60IBb1V9nwbjIzVxHhBx/3S9Wd/q6eGBV7/vdODLKvkyDUQ7MfY77IHVrRZ70gZgPWPQeIGaY13TahkbR/PDwIkpqE9fYj6NrT/4Sy8LySR9fLzLbD0fW9xxdsISwQ30O6LTX2rlOHSKd6L3odjyckGTAaStzvgXgW9jK5YPenxKNB4gUhG4g8BN0rkrxanRo/R0lICjaCm2gFTYpecVu348IXZMp+VrIzXJemTMrxQe3CQ8qbSqAluRAI3UQh+2Jv4iWergZcy0um7dKJb9pi4/sNpNsJ1ludjXRtayP44vyVL5FkY2dXra9ZK2C4B6QJiEzXy9EDjY01XNqAenJ8cy/LpNFdSAc4CfNWkLaGnrVMaT2HK1P2Bk676nU/d4pwCoB4QK9si5T2BTp/ylSpwudAPzoKw0xgPzfRA0Mgh1fID+373AT+W9lhTjkwaAvySredXHF2KTI/eJEW16WfW2OJ3+16WG31hFJmaJt3Cyt2z1mf6CMPwu4PGY+gIm6dxAUkqn1qieiHXfXiaGyxR1/aCsLM4TtI+n2e9LgQuwex9D2PMDUKXkHxFr/k5VPzH0CjylkhyaRdaM9tr1Y/34Z2LdzRNFv50dsxE0nprr293YY/newrq77wCWY8vR+xVPoiyyg8moOEEY4z3bG5sGfh92s4JxHBrm0sv7sEe7/wH4bxNjNC4AECcVUkd4F+UV5jIW/we9TuCEp/oqEQAAAABJRU5ErkJggg==")
    local clip = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    W:AddHeaderButton({ Name = "Discord", Image = logo, Icon = logo == nil and "message-circle" or nil, ImageSize = Vector2.new(19, 14), Tip = "Discord", HoverColor = Color3.fromRGB(88, 101, 242), Callback = function()
        if clip and pcall(clip, "https://discord.gg/pulsezone") then
            toast("Discord", "Link copied: discord.gg/pulsezone", "success")
        else
            toast("Discord", "discord.gg/pulsezone", "warning")
        end
    end })
end)

local UI = {}

W:TabGroup("Farm")
local tFarm = W:Tab({ Name = "Auto Farm", Icon = "coins" })
local tRewards = W:Tab({ Name = "Rewards", Icon = "gift" })
W:TabGroup("Garage")
local tShop = W:Tab({ Name = "Scooters", Icon = "bike" })
W:TabGroup("World")
local tTp = W:Tab({ Name = "Teleports", Icon = "map-pin" })
local tPlayer = W:Tab({ Name = "Player", Icon = "user-round" })
local tVis = W:Tab({ Name = "Visuals", Icon = "eye" })
W:TabGroup("System")
local tServer = W:Tab({ Name = "Server", Icon = "server" })
local tSet = W:Tab({ Name = "Settings", Icon = "settings" })

do
    local sec = tFarm:Section({ Title = "Drive Farm", Icon = "route", Side = "Left" })
    local t = sec:Toggle({ Text = "Auto Drive", Default = S.autoDrive, Drawer = true, Callback = function(v)
        set("autoDrive", v)
        if not v then
            Drive.stop()
            Drive.center = nil
        end
    end })
    t.Drawer:Dropdown({ Text = "Spot", Options = { "City Lot", "Current Position" }, Default = S.driveSpot, Callback = function(v)
        set("driveSpot", v)
        Drive.center = nil
        if Drive.conn then
            Drive.stop()
        end
    end })
    t.Drawer:Toggle({ Text = "Wheelie", Default = S.wheelie, Callback = function(v) set("wheelie", v) end })
    UI.drive = t

    local rc = tFarm:Section({ Title = "Race", Icon = "flag", Side = "Left" })
    rc:Toggle({ Text = "Auto Race", Default = S.autoRace, Callback = function(v)
        set("autoRace", v)
        if v and Race.phase == "Invite" then Race.answer(0.3) end
        if not v then Race.stop() end
    end })
    UI.race = rc:Label({ Text = "" })

    local del = tFarm:Section({ Title = "Deliveries", Icon = "truck", Side = "Left" })
    UI.delivery = del:Toggle({ Text = "Auto Delivery", Default = S.autoDelivery, Callback = function(v) set("autoDelivery", v) end })
    UI.deliveryStatus = del:Label({ Text = "Idle" })

    local st = tFarm:Section({ Title = "Session", Icon = "chart-bar", Side = "Right" })
    UI.session = st:Paragraph({ Title = "Earned", Text = "$0" })
    UI.task = st:Label({ Text = "Idle" })

    local sh = tFarm:Section({ Title = "Scooter", Icon = "zap", Side = "Right" })
    sh:Toggle({ Text = "Auto Buy", Default = S.autoBuy, Callback = function(v) set("autoBuy", v) end })
    sh:Toggle({ Text = "Best Scooter", Default = S.spawnBest, Callback = function(v) set("spawnBest", v) end })
    sh:Button({ Text = "Mount", Icon = "bike", Callback = function()
        task.spawn(function()
            if Kk.mount() then toast("Scooter", "Mounted", "success") else toast("Scooter", "No scooter", "warning") end
        end)
    end })
end

do
    local q = tRewards:Section({ Title = "Quests", Icon = "trophy", Side = "Left" })
    q:Toggle({ Text = "Auto Claim", Default = S.autoQuests, Callback = function(v) set("autoQuests", v) end })
    q:Button({ Text = "Claim Ready", Icon = "gift", Callback = function()
        task.spawn(function()
            local n = Quests.claim()
            toast("Quests", n > 0 and ("Claimed " .. n) or "Nothing ready", n > 0 and "success" or "info")
        end)
    end })
    UI.quests = q:Paragraph({ Title = "Progress", Text = "" })

    local pk = tRewards:Section({ Title = "Pumpkin Night", Icon = "ghost", Side = "Right" })
    pk:Toggle({ Text = "Auto Pumpkins", Default = S.autoPumpkins, Callback = function(v) set("autoPumpkins", v) end })
    UI.pumpkin = pk:Label({ Text = "" })
    local items = {}
    pcall(function()
        local cfg = require(RS:FindFirstChild("HalloweenConfig"))
        for _, it in ipairs(cfg.items or {}) do
            items[#items + 1] = { code = it.key, label = tostring(it.name) .. "  " .. tostring(it.price) .. " tokens" }
        end
    end)
    if #items == 0 then
        items = { { code = "PumpkinHelmet", label = "PUMPKIN HELMET  60 tokens" }, { code = "SpookyHorns", label = "SPOOKY HORNS  35 tokens" } }
    end
    local pick = items[1].code
    pk:Dropdown({ Text = "Item", Options = items, Default = pick, Callback = function(v) pick = v end })
    pk:Button({ Text = "Buy", Icon = "shopping-cart", Callback = function()
        task.spawn(function()
            local ok, a, b = pcall(function() return Remotes.HalloweenRemote:InvokeServer("Buy", pick) end)
            local good = ok and (a == true or (type(a) == "table" and a.ok == true))
            local why = ok and (type(a) == "table" and tostring(a.reason or a.error or a.message or "") or tostring(b or a)) or "Error"
            toast("Halloween Shop", good and "Purchased" or why, good and "success" or "warning")
        end)
    end })

    local cd = tRewards:Section({ Title = "Codes", Icon = "ticket", Side = "Right" })
    cd:Toggle({ Text = "Auto Redeem", Default = S.autoCodes, Callback = function(v)
        set("autoCodes", v)
        if v then task.spawn(Codes.all) end
    end })
    cd:Button({ Text = "Redeem All", Icon = "ticket", Callback = function()
        task.spawn(function()
            toast("Codes", "Redeeming…", "info")
            Codes.all(function(n, total)
                toast("Codes", n > 0 and (n .. " codes · " .. Kk.money(total)) or "No new codes", n > 0 and "success" or "info")
            end)
        end)
    end })
    local custom = ""
    cd:Input({ Text = "Code", Placeholder = "CODE", Callback = function(v) custom = tostring(v or "") end })
    cd:Button({ Text = "Redeem", Icon = "check", Callback = function()
        task.spawn(function()
            local code = custom:gsub("%s", "")
            if code == "" then return end
            local ok, why, amt = Codes.redeem(code)
            toast("Codes", ok and (code .. " · " .. Kk.money(amt)) or (code .. " · " .. why), ok and "success" or "warning")
        end)
    end })
end

do
    local dl = tShop:Section({ Title = "Dealership", Icon = "store", Side = "Left" })
    local function options()
        local t = {}
        for _, s in ipairs(Kk.catalog()) do
            t[#t + 1] = { code = s.name, label = s.name:gsub("^[Kk]u[Kk]irin ", "") .. "  " .. (Kk.owned(s.name) and "owned" or Kk.money(s.price)) .. "  " .. s.kmh .. " km/h" }
        end
        return t
    end
    local first = Shop.next()
    local pick = first and first.name or (Kk.catalog()[1] or {}).name
    local dd = dl:Dropdown({ Text = "Scooter", Options = options(), Default = pick, Callback = function(v) pick = v end })
    UI.shopDropdown = dd
    UI.shopOptions = options
    dl:Button({ Text = "Buy", Icon = "shopping-cart", Style = "Primary", Callback = function()
        task.spawn(function()
            if not pick then return end
            K.busy = true
            Drive.stop()
            local ok, why = Shop.buy(pick)
            K.busy = false
            K.task = "Idle"
            toast("Dealership", ok and (pick .. " purchased") or (pick .. " · " .. why), ok and "success" or "warning")
            pcall(function() dd:SetOptions(options()) end)
        end)
    end })
    dl:Button({ Text = "Ride", Icon = "bike", Callback = function()
        task.spawn(function()
            if not (pick and Kk.owned(pick)) then
                toast("Garage", "Not owned", "warning")
                return
            end
            K.busy = true
            Drive.stop()
            Kk.spawn(pick)
            Kk.mount()
            K.busy = false
        end)
    end })
    UI.next = dl:Label({ Text = "" })

    local up = tShop:Section({ Title = "Customization", Icon = "wrench", Side = "Right" })
    up:Button({ Text = "Go To Garage", Icon = "wrench", Callback = function()
        task.spawn(function()
            Drive.stop()
            Kk.goto(Kk.ground(Vector3.new(2069, 4, -1472), 20, 40))
        end)
    end })
end

do
    local spots = {
        { "Dealership", "store", function() local o = workspace:FindFirstChild("OpenShop") return o and o.Position + Vector3.new(0, 0, 6) end },
        { "Delivery Job", "truck", function() local o = workspace:FindFirstChild("DeliveryJOB") return o and o.Position + Vector3.new(4, 0, 0) end },
        { "Spawn", "flag", function() local o = workspace:FindFirstChild("SpawnLocation") return o and Kk.ground(o.Position + Vector3.new(0, 0, -10), 10, 20) end },
        { "Garage", "wrench", function() return Kk.ground(Vector3.new(2069, 4, -1472), 20, 40) end },
        { "House", "house", function() local o = workspace:FindFirstChild("HOUSETP") return o and Kk.ground(o.Position + Vector3.new(0, 0, -8), 10, 20) end },
        { "Events Machine", "sparkles", function() local o = workspace:FindFirstChild("EventsMachine") return o and Kk.ground(o:GetPivot().Position + Vector3.new(0, 0, 10), 10, 20) end },
        { "Race Board", "flag", function() local o = workspace:FindFirstChild("RaceBoard") return o and Kk.ground(o:GetPivot().Position + Vector3.new(-10, 0, 0), 10, 20) end },
        { "Farm Lot", "route", function() return Drive.SPOT end },
    }
    local sec = tTp:Section({ Title = "Locations", Icon = "map", Side = "Left" })
    for _, s in ipairs(spots) do
        sec:Button({ Text = s[1], Icon = s[2], Callback = function()
            task.spawn(function()
                set("autoDrive", false)
                pcall(function() UI.drive:SetSilent(false) end)
                Drive.stop()
                local p = s[3]()
                if p then Kk.goto(p) end
            end)
        end })
    end

    local ps = tTp:Section({ Title = "Players", Icon = "user-round", Side = "Right" })
    local function names()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then t[#t + 1] = { code = p.Name, label = p.DisplayName .. " (@" .. p.Name .. ")" } end
        end
        return t
    end
    local target
    local dd = ps:Dropdown({ Text = "Player", Options = names(), Callback = function(v) target = v end })
    local function refresh() pcall(function() dd:SetOptions(names()) end) end
    conn(Players.PlayerAdded, refresh)
    conn(Players.PlayerRemoving, function() task.defer(refresh) end)
    ps:Button({ Text = "Teleport", Icon = "navigation", Callback = function()
        task.spawn(function()
            local p = target and Players:FindFirstChild(target)
            local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if not r then
                toast("Teleport", "Player not found", "warning")
                return
            end
            set("autoDrive", false)
            pcall(function() UI.drive:SetSilent(false) end)
            Drive.stop()
            Kk.goto(r.Position + r.CFrame.RightVector * 6)
        end)
    end })
end

do
    local mv = tPlayer:Section({ Title = "Movement", Icon = "footprints", Side = "Left" })
    local ws = mv:Toggle({ Text = "Walk Speed", Default = S.wsOn, Drawer = true, Callback = function(v)
        set("wsOn", v)
        if not v then
            local h = Kk.hum()
            if h then h.WalkSpeed = 16 end
        end
    end })
    ws.Drawer:Slider({ Text = "Speed", Min = 16, Max = 150, Default = S.walkSpeed, Callback = function(v) set("walkSpeed", v) end })
    local jp = mv:Toggle({ Text = "Jump Power", Default = S.jpOn, Drawer = true, Callback = function(v)
        set("jpOn", v)
        if not v then
            local h = Kk.hum()
            if h then
                h.UseJumpPower = true
                h.JumpPower = 50
            end
        end
    end })
    jp.Drawer:Slider({ Text = "Power", Min = 50, Max = 250, Default = S.jumpPower, Callback = function(v) set("jumpPower", v) end })
    mv:Toggle({ Text = "Infinite Jump", Default = S.infJump, Callback = function(v) set("infJump", v) end })
    mv:Toggle({ Text = "Noclip", Default = S.noclip, Callback = function(v) set("noclip", v) end })

    local ms = tPlayer:Section({ Title = "Misc", Icon = "settings", Side = "Right" })
    ms:Toggle({ Text = "Anti AFK", Default = S.antiAfk, Callback = function(v) set("antiAfk", v) end })
    ms:Button({ Text = "Reset Character", Icon = "rotate-ccw", DoubleClick = true, Callback = function()
        local h = Kk.hum()
        if h then h.Health = 0 end
    end })
end

do
    local es = tVis:Section({ Title = "ESP", Icon = "scan-eye", Side = "Left" })
    es:Toggle({ Text = "Players", Default = S.espPlayers, Callback = function(v) set("espPlayers", v) end })
    es:Toggle({ Text = "Pumpkins", Default = S.espPumpkins, Callback = function(v) set("espPumpkins", v) end })
    es:Toggle({ Text = "Delivery Target", Default = S.espDelivery, Callback = function(v) set("espDelivery", v) end })
    local wd = tVis:Section({ Title = "World", Icon = "sun", Side = "Right" })
    wd:Toggle({ Text = "Fullbright", Default = S.fullbright, Callback = function(v)
        set("fullbright", v)
        Light.apply()
    end })
    wd:Toggle({ Text = "No Fog", Default = S.noFog, Callback = function(v)
        set("noFog", v)
        Light.apply()
    end })
end

do
    local sv = tServer:Section({ Title = "Server", Icon = "server", Side = "Left" })
    sv:Button({ Text = "Rejoin", Icon = "refresh-cw", Callback = function() pcall(Server.rejoin) end })
    sv:Button({ Text = "Server Hop", Icon = "shuffle", Callback = function()
        task.spawn(function()
            if not Server.hop() then toast("Server", "No servers found", "warning") end
        end)
    end })
    local info = tServer:Section({ Title = "Job ID", Icon = "hash", Side = "Right" })
    info:Label({ Text = string.sub(game.JobId, 1, 18) .. "…" })
    info:Button({ Text = "Copy Job ID", Icon = "copy", Callback = function()
        local clip = setclipboard or toclipboard
        if clip and pcall(clip, game.JobId) then toast("Server", "Job ID copied", "success") end
    end })
end

pcall(function() W:AddAppearance(tSet, {}) end)
do
    local hb = tSet:Section({ Title = "Pulse Hub", Icon = "info", Side = "Right" })
    hb:Label({ Text = "Drive A Kukirin · " .. PULSE_VERSION })
    hb:Button({ Text = "Unload", Icon = "log-out", DoubleClick = true, Callback = function()
        task.defer(function() pcall(K.unload) end)
    end })
end

function K.unload()
    K.alive = false
    pcall(Drive.stop)
    pcall(Race.stop)
    K.input = nil
    for _, c in ipairs(K.conns) do pcall(function() c:Disconnect() end) end
    K.conns = {}
    pcall(Esp.clear)
    pcall(function() if Esp.holder then Esp.holder:Destroy() end end)
    S.fullbright, S.noFog = false, false
    pcall(Light.apply)
    pcall(function() W:Destroy() end)
    if G.__pulseKuk == K then G.__pulseKuk = nil end
end

conn(UIS.JumpRequest, function()
    if not S.infJump then return end
    local h = Kk.hum()
    if h and not Kk.mounted() then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
conn(Run.Stepped, function()
    if not S.noclip or Kk.mounted() then return end
    local c = lp.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
    end
end)
conn(Run.Heartbeat, function()
    local h = Kk.hum()
    if not h then return end
    if S.wsOn and h.WalkSpeed ~= S.walkSpeed then h.WalkSpeed = S.walkSpeed end
    if S.jpOn then
        h.UseJumpPower = true
        if h.JumpPower ~= S.jumpPower then h.JumpPower = S.jumpPower end
    end
end)
conn(lp.Idled, function()
    if not S.antiAfk then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

K.session = { start = os.clock(), earned = 0, last = Kk.cash() }
task.spawn(function()
    while K.alive do
        local c = Kk.cash()
        if c > K.session.last then K.session.earned += c - K.session.last end
        K.session.last = c
        pcall(function()
            local mins = math.max((os.clock() - K.session.start) / 60, 1 / 60)
            UI.session:SetTitle(Kk.money(K.session.earned) .. "  ·  " .. Kk.money(K.session.earned / mins) .. "/min")
            UI.session:SetText(string.format("Cash %s · %s\nWheelie ×%.2f\nDeliveries %d · %s\nPumpkins %d", Kk.money(c), Kk.clock(os.clock() - K.session.start), tonumber(lp:GetAttribute("WheelieCashMultiplier")) or 1, Delivery.count, Kk.money(Delivery.earned), Pumpkin.got))
            UI.task:SetText(K.task)
            local tgt = Delivery.target()
            local cdl = Delivery.cooldown()
            UI.deliveryStatus:SetText(tgt and ("Target: " .. tgt) or (cdl > 0 and ("Next job in " .. math.ceil(cdl) .. "s") or "Job ready") .. (Delivery.last and ("  ·  " .. Delivery.last) or ""))
            local left = Pumpkin.left()
            UI.pumpkin:SetText(left > 0 and string.format("Night · %s · %d left", Kk.clock(left), #Pumpkin.list()) or ("Next night in " .. Kk.clock(Pumpkin.nextIn())))
            UI.quests:SetText(Quests.text())
            local rs = Race.phase ~= "Idle" and ("Race: " .. Race.phase) or ("Next race in " .. Kk.clock(Race.nextIn()))
            UI.race:SetText(rs .. (Race.last and ("\nLast: " .. Race.last) or "") .. (Race.count > 0 and ("\nRaces " .. Race.count .. " · " .. Kk.money(Race.earned)) or ""))
            local nx = Shop.next()
            UI.next:SetText(nx and ("Next: " .. nx.name .. " · " .. Kk.money(nx.price)) or "All scooters owned")
        end)
        pcall(Esp.update)
        if S.fullbright or S.noFog then pcall(Light.apply) end
        task.wait(1)
    end
end)

task.spawn(function()
    local lastQuest, lastBuy, lastBest = 0, 0, 0
    if S.autoCodes then task.spawn(Codes.all) end
    while K.alive do
        local ok, err = pcall(function()
            if K.busy then return end
            if lp:GetAttribute("InRace") == true or (S.autoRace and Race.phase ~= "Idle" and Race.phase ~= "Invite") then
                if Drive.conn then Drive.stop() end
                K.task = "Race · " .. Race.phase
                return
            end
            if S.autoPumpkins and Pumpkin.ready() then
                Drive.stop()
                K.busy = true
                Pumpkin.run()
                K.busy = false
            elseif S.autoDelivery and Delivery.ready() then
                Drive.stop()
                K.busy = true
                Delivery.run()
                K.busy = false
            end
            if S.autoQuests and os.clock() - lastQuest > 6 then
                lastQuest = os.clock()
                Quests.claim()
            end
            if S.autoBuy and os.clock() - lastBuy > 8 then
                lastBuy = os.clock()
                local nx = Shop.next()
                if nx and Kk.cash() >= nx.price then
                    Drive.stop()
                    K.busy = true
                    local bought, why = Shop.buy(nx.name)
                    K.busy = false
                    toast("Dealership", bought and (nx.name .. " purchased") or (nx.name .. " · " .. tostring(why)), bought and "success" or "warning")
                    pcall(function() UI.shopDropdown:SetOptions(UI.shopOptions()) end)
                end
            end
            if S.spawnBest and os.clock() - lastBest > 10 then
                lastBest = os.clock()
                local b = Kk.best()
                local m = Kk.scooter()
                if b and m and m.Name ~= b.name then
                    Drive.stop()
                    K.busy = true
                    K.task = "Spawning " .. b.name
                    Kk.spawn(b.name)
                    Kk.mount()
                    K.busy = false
                end
            end
            if S.autoDrive then
                if not Drive.conn and os.clock() >= (Drive.retryAt or 0) then
                    if Drive.start() then K.task = Drive.mode == "Real" and "Driving" or "Driving (teleport)" end
                end
            elseif Drive.conn then
                Drive.stop()
            end
            if not Drive.conn and not K.busy then
                if S.autoDelivery then
                    K.task = "Waiting for delivery job"
                elseif S.autoPumpkins then
                    K.task = "Waiting for pumpkin night"
                else
                    K.task = "Idle"
                end
            end
        end)
        if not ok then
            K.busy = false
            warn("[Pulse Kukirin] " .. tostring(err))
        end
        task.wait(0.4)
    end
end)

W:Open()
task.delay(0.6, function()
    toast("Pulse Hub", "Drive A Kukirin · " .. W.Key.Name, "success")
end)

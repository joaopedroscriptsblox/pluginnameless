local Plugin = {
    ["PluginName"] = "Custom Remake UI",
    ["PluginDescription"] = "Remake de UI com pesquisa e suporte completo de comandos para Nameless Admin",
    ["Commands"] = {}
}

-- Servicos do Roblox
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Lista de atalhos pre-configurados com valores
local presetCommands = {
    "mobilefly 100",
    "unfly",
    "speed 50",
    "speed 16",
    "jumppower 100",
    "hipheight 5",
    "noclip",
    "clip",
    "god",
    "ungod",
    "invisible",
    "visible",
    "esp",
    "unesp",
    "btools",
    "fling ",
    "goto ",
    "bring ",
    "view "
}

-- Captura e unifica todos os comandos disponiveis no ambiente
local function getAllCommands()
    local allCmds = {}
    local addedMap = {}

    -- Adiciona os atalhos customizados
    for _, cmd in ipairs(presetCommands) do
        if not addedMap[cmd] then
            table.insert(allCmds, cmd)
            addedMap[cmd] = true
        end
    end

    -- Importa comandos nativos do Infinite Yield / Nameless Admin se disponiveis
    if Commands then
        for name, _ in pairs(Commands) do
            if not addedMap[name] then
                table.insert(allCmds, name)
                addedMap[name] = true
            end
        end
    end

    table.sort(allCmds)
    return allCmds
end

-- Função para executar comandos no Nameless Admin / Infinite Yield
local function executeCmd(cmdText)
    if execCmd then
        execCmd(cmdText)
    else
        -- Fallback caso seja executado diretamente pelo executor
        if LocalPlayer and LocalPlayer.Character then
            game:GetService("Players").LocalPlayer.Chatted:Fire(";" .. cmdText)
        end
    end
end

-- Função para tornar a janela arrastavel
local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Construção da Interface
local function buildUI()
    local parentFolder = gethui and gethui() or (syn and syn.protect_gui and CoreGui) or CoreGui

    if parentFolder:FindFirstChild("NamelessRemakeUI") then
        parentFolder.NamelessRemakeUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NamelessRemakeUI"
    ScreenGui.Parent = parentFolder

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -160, 0.4, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- Barra Superior
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = "Nameless Remake UI"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    makeDraggable(MainFrame, TitleBar)

    -- Caixa de Pesquisa
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -20, 0, 35)
    SearchBox.Position = UDim2.new(0, 10, 0, 45)
    SearchBox.PlaceholderText = "Pesquisar ou digite o comando..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 13
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = MainFrame

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    -- Botao de Executar
    local ExecBtn = Instance.new("TextButton")
    ExecBtn.Size = UDim2.new(1, -20, 0, 30)
    ExecBtn.Position = UDim2.new(0, 10, 0, 85)
    ExecBtn.Text = "Executar Digitado"
    ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecBtn.TextSize = 13
    ExecBtn.Font = Enum.Font.SourceSansBold
    ExecBtn.BackgroundColor3 = Color3.fromRGB(60, 110, 240)
    ExecBtn.Parent = MainFrame

    local ExecCorner = Instance.new("UICorner")
    ExecCorner.CornerRadius = UDim.new(0, 6)
    ExecCorner.Parent = ExecBtn

    ExecBtn.MouseButton1Click:Connect(function()
        if SearchBox.Text ~= "" then
            executeCmd(SearchBox.Text)
        end
    end)

    -- Scroll de Comandos
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -130)
    Scroll.Position = UDim2.new(0, 10, 0, 122)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Scroll
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    local commandList = getAllCommands()

    -- Atualizador da Lista
    local function updateList(filterText)
        for _, child in pairs(Scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        filterText = filterText:lower()

        for _, cmd in ipairs(commandList) do
            if filterText == "" or cmd:lower():find(filterText, 1, true) then
                local CmdBtn = Instance.new("TextButton")
                CmdBtn.Size = UDim2.new(1, -5, 0, 32)
                CmdBtn.Text = "  > " .. cmd
                CmdBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
                CmdBtn.TextSize = 13
                CmdBtn.Font = Enum.Font.SourceSans
                CmdBtn.TextXAlignment = Enum.TextXAlignment.Left
                CmdBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
                CmdBtn.Parent = Scroll

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 5)
                BtnCorner.Parent = CmdBtn

                CmdBtn.MouseButton1Click:Connect(function()
                    SearchBox.Text = cmd
                    executeCmd(cmd)
                end)
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateList(SearchBox.Text)
    end)

    updateList("")
end

buildUI()

return Plugin

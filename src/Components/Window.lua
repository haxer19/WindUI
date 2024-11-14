
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Creator = require("../Creator")
local New = Creator.New
local Tween = Creator.Tween

local Notified = false

return function(Config)
    local Window = {
        Title = Config.Title or "UI Library",
        Author = Config.Author,
        Icon = Config.Icon,
        Folder = Config.Folder,
        Size = Config.Size or UDim2.fromOffset(560, 460),
        ToggleKey = Config.ToggleKey or Enum.KeyCode.G,
        Transparent = Config.Transparent or false,
        Position = UDim2.new(
			0.5, 0,
			0.5, 0
		),
		UICorner = 9,
		UIPadding = 14,
		SideBarWidth = Config.SideBarWidth or 200,
		UIElements = {},
		Theme = Config.Theme,
		CanDropdown = true,
		Closed = false,
		HasOutline = Config.HasOutline or false,
		SuperParent = Config.Parent
    }
    
    if Window.Folder then
        makefolder("WindUI/" .. Window.Folder)
    end
    
    local UICorner = New("UICorner", {
        CornerRadius = UDim.new(0,Window.UICorner)
    })
    local UIStroke = New("UIStroke", {
        Thickness = 0.6,
        Color = Color3.fromHex(Config.Theme.Outline),
        ThemeTag = {
            Color = "Outline",
        },
        Transparency = 1, -- 0.8
    })

    local ResizeHandle = New("Frame", {
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,0,1,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        ZIndex = 99,
        Active = true
    })
    local FullScreenIcon = New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, -- .85
        BackgroundColor3 = Color3.new(0,0,0),
        ZIndex = 98,
        Active = false,
    }, {
        New("ImageLabel", {
            Size = UDim2.new(0,70,0,70),
            Image = Creator.Icon("expand")[1],
            ImageRectOffset = Creator.Icon("expand")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("expand")[2]._Size,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ImageTransparency = 1,
        }),
        New("UICorner", {
            CornerRadius = UDim.new(0,Window.UICorner)
        })
    })

    Window.UIElements.SideBar = New("ScrollingFrame", {
        Size = UDim2.new(0,Window.SideBarWidth,1,-Window.UIPadding*4),
        Position = UDim2.new(0,0,0,Window.UIPadding*4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
    }, {
        New("UIPadding", {
            PaddingTop = UDim.new(0,Window.UIPadding),
            PaddingLeft = UDim.new(0,Window.UIPadding+4),
            PaddingRight = UDim.new(0,Window.UIPadding+4),
            PaddingBottom = UDim.new(0,Window.UIPadding),
        }),
        New("UIListLayout", {
            SortOrder = "LayoutOrder",
            Padding = UDim.new(0,8)
        })
    })

    Window.UIElements.MainBar = New("Frame", {
        Size = UDim2.new(1,-Window.UIElements.SideBar.AbsoluteSize.X,1,-Window.UIPadding*4),
        Position = UDim2.new(0,Window.UIElements.SideBar.AbsoluteSize.X,0,Window.UIPadding*4),
        BackgroundTransparency = 1,
    })
    
    local Gradient = New("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, -- Window.Transparent and 0.15 or 0
        ZIndex = 3,
        Name = "Gradient"
    }, {
        New("UIGradient", {
            Color = ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0)),
            Rotation = 90,
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1), 
                NumberSequenceKeypoint.new(1, Window.Transparent and 0.85 or 0.7),
            }
        }),
        New("UICorner", {
            CornerRadius = UDim.new(0,Window.UICorner)
        })
    })
    
    local Blur = New("ImageLabel", {
        Image = "rbxassetid://8992230677",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 1, -- 0.7
        Size = UDim2.new(1,120,1,116),
        Position = UDim2.new(0,-120/2,0,-116/2),
        ScaleType = "Slice",
        SliceCenter = Rect.new(99,99,99,99),
        BackgroundTransparency = 1,
    })

    local CloseButton = New("ImageButton", {
        Image = Creator.Icon("x")[1],
        ImageRectOffset = Creator.Icon("x")[2].ImageRectPosition,
        ImageRectSize = Creator.Icon("x")[2]._Size,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-6,1,-6),
        ThemeTag = {
            ImageColor3 = "Text"
        },
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
    })

    local MinimizeButton = New("ImageButton", {
        Image = Creator.Icon("minus")[1],
        ImageRectOffset = Creator.Icon("minus")[2].ImageRectPosition,
        ImageRectSize = Creator.Icon("minus")[2]._Size,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-6,1,-6),
        ThemeTag = {
            ImageColor3 = "Text"
        },
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
    })

    local IsPC

    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        IsPC = false
    elseif UserInputService.KeyboardEnabled then
        IsPC = true
    else
        IsPC = nil
    end
    
    local OpenButtonContainer
    local OpenButton
    local OpenButtonIcon
    local Glow
    
    if not IsPC then
        OpenButtonIcon = New("ImageLabel", {
            Image = "",
            Size = UDim2.new(0,22,0,22),
            Position = UDim2.new(0.5,0,0.5,0),
            LayoutOrder = -1,
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            Name = "Icon"
        })
    
        OpenButtonTitle = New("TextLabel", {
            Text = Window.Title,
            TextSize = 17,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            AutomaticSize = "XY",
        })
        
        OpenButtonContainer = New("Frame", {
            Size = UDim2.new(0,0,0,0),
            Position = UDim2.new(0.5,0,0,6+44/2),
            AnchorPoint = Vector2.new(0.5,0.5),
            Parent = Config.Parent,
            BackgroundTransparency = 1,
            Active = true,
            Visible = false,
        })
        OpenButton = New("TextButton", {
            Size = UDim2.new(0,0,0,44),
            AutomaticSize = "XY",
            Parent = OpenButtonContainer,
            Active = false,
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = .3,
            ZIndex = 99,
        }, {
            New("UIScale", {
                Scale = 1.05,
            }),
		    New("UICorner", {
                CornerRadius = UDim.new(1,0)
            }),
            New("UIStroke", {
                Thickness = 1,
                ApplyStrokeMode = "Border",
                Color = Color3.new(1,1,1),
                Transparency = 0,
            }, {
                New("UIGradient", {
                    Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff"))
                })
            }),
            New("ImageLabel", {
                Image = Creator.Icon("grab")[1],
                ImageRectOffset = Creator.Icon("grab")[2].ImageRectPosition,
                ImageRectSize = Creator.Icon("grab")[2]._Size,
                Size = UDim2.new(0,20,0,20),
                BackgroundTransparency = 1,
                Position = UDim2.new(0,0,0.5,0),
                AnchorPoint = Vector2.new(0,0.5),
            }),
            New("Frame", {
                Size = UDim2.new(0,1,1,-16),
                Position = UDim2.new(0,20+16,0.5,0),
                AnchorPoint = Vector2.new(0,0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = .86,
            }),
            New("TextButton",{
                AutomaticSize = "XY",
                Active = true,
                BackgroundTransparency = 1,
                Size = UDim2.new(0,0,1,0),
                Position = UDim2.new(0,20+16+16+1,0,0)
            }, {
                OpenButtonIcon,
                New("UIListLayout", {
                    Padding = UDim.new(0, Window.UIPadding),
                    FillDirection = "Horizontal",
                    VerticalAlignment = "Center",
                }),
                OpenButtonTitle,
            }),
            New("UIPadding", {
                PaddingTop = UDim.new(0,0),
                PaddingLeft = UDim.new(0,16),
                PaddingRight = UDim.new(0,16),
                PaddingBottom = UDim.new(0,0),
            })
        })
        local uiGradient = OpenButton.UIStroke.UIGradient
    
        Glow = New("ImageLabel", {
            Image = "rbxassetid://93831937596979", -- UICircle Glow
            ScaleType = "Slice",
            SliceCenter = Rect.new(375,375,375,375),
            BackgroundTransparency = 1,
            Size = UDim2.new(1,21,1,21),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ImageTransparency = .5,
            Parent = OpenButtonContainer,
        }, {
            New("UIGradient", {
                Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff"))
            })
        })
        
        RunService.RenderStepped:Connect(function(deltaTime)
            if uiGradient then
                uiGradient.Rotation = (uiGradient.Rotation + 1) % 360
            end
            if Glow and Glow.UIGradient then
                Glow.UIGradient.Rotation = (Glow.UIGradient.Rotation + 1) % 360
            end
        end)
        
        OpenButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            OpenButtonContainer.Size = UDim2.new(
                0, OpenButton.AbsoluteSize.X,
                0, OpenButton.AbsoluteSize.Y
            )
        end)
        
        OpenButton.TextButton.MouseEnter:Connect(function()
            Tween(OpenButton.UIScale, .1, {Scale = .95}):Play()
        end)
        OpenButton.TextButton.MouseLeave:Connect(function()
            Tween(OpenButton.UIScale, .1, {Scale = 1.05}):Play()
        end)
    end
    
    local Outline1
    local Outline2
    if Window.HasOutline then
        Outline1 = New("Frame", {
            Name = "Outline",
            Size = UDim2.new(1,Window.UIPadding*2,0,1),
            Position = UDim2.new(0.5,0,1,Window.UIPadding),
            BackgroundTransparency= .8,
            AnchorPoint = Vector2.new(0.5,0.5),
            ThemeTag = {
                BackgroundColor3 = "Outline"
            },
        })
        Outline2 = New("Frame", {
            Name = "Outline",
            Size = UDim2.new(0,1,1,-Window.UIPadding*4),
            Position = UDim2.new(0,Window.SideBarWidth,0,Window.UIPadding*4),
            BackgroundTransparency= .8,
            AnchorPoint = Vector2.new(0.5,0),
            ThemeTag = {
                BackgroundColor3 = "Outline"
            },
        })
    end
    
    Window.UIElements.Main = New("Frame", {
        Size = UDim2.new(
                    0, math.clamp(Window.Size.X.Offset, 400, 700),
                    0, math.clamp(Window.Size.Y.Offset, 350, 520)),
        Position = Window.Position,
        BackgroundTransparency = 1,
        Parent = Config.Parent,
        AnchorPoint = Vector2.new(0.5,0.5),
        Active = true,
    }, {
        Blur,
        Gradient,
        New("Frame", {
            BackgroundColor3 = Color3.fromHex(Config.Theme.Accent),
            BackgroundTransparency = 1, -- Window.Transparent and 0.15 or 0
            Size = UDim2.new(1,0,1,0),
            Name = "Background",
            ThemeTag = {
                BackgroundColor3 = "Accent"
            },
            ZIndex = 2,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,Window.UICorner)
            })
        }),
        UIStroke,
        UICorner,
        ResizeHandle,
        FullScreenIcon,
        New("UIScale", {
            Scale = 0.9,
        }),
        New("CanvasGroup", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Name = "Main",
            GroupTransparency = 1,
            ZIndex = 97,
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0,Window.UICorner)
            }),
            Window.UIElements.SideBar,
            Window.UIElements.MainBar,
            Outline2,
            New("Frame", { -- Topbar
                Size = UDim2.new(1,0,0,Window.UIPadding*4),
                BackgroundTransparency = 1,
                Name = "Topbar"
            }, {
                Outline1,
                --[[New("Frame", { -- Outline
                    Size = UDim2.new(1,Window.UIPadding*2, 0, 1),
                    Position = UDim2.new(0,-Window.UIPadding, 1,Window.UIPadding-2),
                    BackgroundTransparency = 0.9,
                    BackgroundColor3 = Color3.fromHex(Config.Theme.Outline),
                }),]]
                New("Frame", { -- Topbar Left Side
                    AutomaticSize = "X",
                    Size = UDim2.new(0,0,1,0),
                    BackgroundTransparency = 1,
                    Name = "Left"
                }, {
                    New("UIListLayout", {
                        Padding = UDim.new(0,10),
                        SortOrder = "LayoutOrder",
                        FillDirection = "Horizontal",
                        VerticalAlignment = "Center",
                    }),
                    New("Frame", {
                        AutomaticSize = "XY",
                        BackgroundTransparency = 1,
                        Name = "Title",
                        LayoutOrder= 2,
                    }, {
                        New("UIListLayout", {
                            Padding = UDim.new(0,0),
                            SortOrder = "LayoutOrder",
                            FillDirection = "Vertical",
                            VerticalAlignment = "Top",
                        }),
                        New("TextLabel", {
                            Text = Window.Title,
                            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                            BackgroundTransparency = 1,
                            AutomaticSize = "XY",
                            TextXAlignment = "Left",
                            TextSize = 16,
                            TextColor3 = Color3.fromHex(Config.Theme.Text),
                            ThemeTag = {
                                TextColor3 = "Text"
                            }
                        }),
                    }),
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0,4)
                    })
                }),
                New("Frame", { -- Topbar Right Side
                    AutomaticSize = "XY",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1,0,0.5,0),
                    AnchorPoint = Vector2.new(1,0.5)
                }, {
                    New("UIListLayout", {
                        Padding = UDim.new(0,12),
                        FillDirection = "Horizontal",
                        SortOrder = "LayoutOrder",
                    }),
                    New("TextButton", {
                        Size = UDim2.new(0,24,0,24),
                        BackgroundTransparency = 1,
                        LayoutOrder = 1,
                    }, {
                        CloseButton,
                    }),
                    New("TextButton", {
                        Size = UDim2.new(0,24,0,24),
                        BackgroundTransparency = 1,
                        
                    }, {
                        MinimizeButton,
                    })
                }),
                New("UIPadding", {
                    PaddingTop = UDim.new(0,Window.UIPadding),
                    PaddingLeft = UDim.new(0,Window.UIPadding),
                    PaddingRight = UDim.new(0,Window.UIPadding),
                    PaddingBottom = UDim.new(0,Window.UIPadding),
                })
            })
        })
    })

    local Dragged = false

    Creator.Drag(Window.UIElements.Main)
    
    --Creator.Blur(Window.UIElements.Main.Background)
    
    if not IsPC then
        Creator.Drag(OpenButtonContainer, function(v) Dragged = v end)
    end
    
    if Window.Author then
        New("TextLabel", {
            Text = "by " .. Window.Author,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
            BackgroundTransparency = 1,
            TextTransparency = 0.4,
            AutomaticSize = "XY",
            Parent = Window.UIElements.Main.Main.Topbar.Left.Title,
            TextXAlignment = "Left",
            TextSize = 14,
            LayoutOrder = 2,
            TextColor3 = Color3.fromHex(Config.Theme.Text),
            ThemeTag = {
                TextColor3 = "Text"
            }
        })
    end
    
    task.spawn(function()
        if Window.Icon then
            local ImageLabel = New("ImageLabel", {
                Parent = Window.UIElements.Main.Main.Topbar.Left,
                Size = UDim2.new(0,24,0,24),
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                ThemeTag = {
                    ImageColor3 = "Text"
                }
            })
            if Creator.Icon(Window.Icon)[2] then
                ImageLabel.Image = Creator.Icon(Window.Icon)[1]
                ImageLabel.ImageRectOffset = Creator.Icon(Window.Icon)[2].ImageRectPosition
                ImageLabel.ImageRectSize = Creator.Icon(Window.Icon)[2]._Size
                OpenButtonIcon.Image = Creator.Icon(Window.Icon)[1]
                OpenButtonIcon.ImageRectOffset = Creator.Icon(Window.Icon)[2].ImageRectPosition
                OpenButtonIcon.ImageRectSize = Creator.Icon(Window.Icon)[2]._Size
            end
            if string.find(Window.Icon,"http") then
                if not isfile("WindUI" .. Window.Folder .. "/Assets/Icon.png") then
                    local response = request({
                        Url = Window.Icon,
                        Method = "GET",
                    }).Body
                    writefile("WindUI" .. Window.Folder .. "/Assets/Icon.png", response)
                end
                ImageLabel.Image = getcustomasset("WindUI" .. Window.Folder .. "/Assets/Icon.png")
                OpenButtonIcon.Image = getcustomasset("WindUI" .. Window.Folder .. "/Assets/Icon.png")
            elseif string.find(Window.Icon,"rbxassetid") then
                ImageLabel.Image = Window.Icon
                OpenButtonIcon.Image = Window.Icon
            end
        else
            OpenButtonIcon.Visible = false
        end
    end)
    
    function Window:Open()
        Window.Closed = false
        
        Tween(Window.UIElements.Main.Background, 0.25, {BackgroundTransparency = Config.Transparent and 0.15 or 0}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Window.UIElements.Main.Main, 0.25, {GroupTransparency = 0}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Window.UIElements.Main.UIScale, 0.25, {Scale = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Gradient, 0.25, {BackgroundTransparency = 0}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Blur, 0.25, {ImageTransparency = .7}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(UIStroke, 0.25, {Transparency = .8}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        
        Window.CanDropdown = true
        
        Window.UIElements.Main.Visible = true
    end
    function Window:Close()
        local Close = {}
        
        Window.CanDropdown = false
        Window.Closed = true
        
        Tween(Window.UIElements.Main.Background, 0.25, {BackgroundTransparency = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Window.UIElements.Main.Main, 0.25, {GroupTransparency = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Window.UIElements.Main.UIScale, 0.25, {Scale = .9}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Gradient, 0.25, {BackgroundTransparency = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(Blur, 0.25, {ImageTransparency = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        Tween(UIStroke, 0.25, {Transparency = 1}, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out):Play()
        
        task.spawn(function()
            task.wait(0.25)
            Window.UIElements.Main.Visible = false
        end)
        
        function Close:Destroy()
            task.wait(0.25)
            Config.Parent.Parent:Destroy()
        end
        
        return Close
    end
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Window:Close()
        task.spawn(function()
            task.wait(.3)
            if not IsPC then
                OpenButtonContainer.Visible = true
            end
        end)
        
        local NotifiedText = IsPC and "Press " .. Window.Name .. " to open the Window" or "Click the Button to open the Window"
        
        if not Notified then
            Notified = not Notified
            Config.WindUI:Notify({
                Title = "Minimize",
                Content = "You've closed the Window. " .. NotifiedText,
                Duration = 5,
            })
        end
    end)
    if not IsPC then
        OpenButton.TextButton.MouseButton1Click:Connect(function()
            Window:Open()
            OpenButtonContainer.Visible = false
        end)
    end
    
    UserInputService.InputBegan:Connect(function(input, isProcessed)
        if isProcessed then return end
        
        if input.KeyCode == Window.ToggleKey then
            if Window.Closed then
                Window:Open()
            else
                Window:Close()
            end
        end
    end)
    
    task.spawn(function()
        --task.wait(1.38583)
        Window:Open()
    end)
    
    function Window:EditOpenButton(OpenButtonConfig)
        local OpenButtonModule = {
            Title = OpenButtonConfig.Title or Window.Title,
            Icon = OpenButtonConfig.Icon or Window.Icon,
            Color = OpenButtonConfig.Color 
                or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
        }
        
        OpenButtonTitle.Text = OpenButtonModule.Title
        
        OpenButtonIcon.Image = Creator.Icon(OpenButtonModule.Icon)[1]
        OpenButtonIcon.ImageRectOffset = Creator.Icon(OpenButtonModule.Icon)[2].ImageRectPosition
        OpenButtonIcon.ImageRectSize = Creator.Icon(OpenButtonModule.Icon)[2]._Size
        
        OpenButton.UIStroke.UIGradient.Color = OpenButtonModule.Color
        Glow.UIGradient.Color = OpenButtonModule.Color
    end
    
    local TabModule = require("./Tab").Init(Window)
    function Window:Tab(TabConfig)
        RunService.Heartbeat:Wait()
        return TabModule.New({ Title = TabConfig.Title, Icon = TabConfig.Icon, Parent = Window.UIElements.SideBar })
    end
    
    function Window:SelectTab(Tab)
        TabModule:SelectTab(Tab)
    end
    
    function Window:Divider()
        local Divider = New("Frame", {
            Size = UDim2.new(1,0,0,1),
            Position = UDim2.new(0.5,0,0,0),
            AnchorPoint = Vector2.new(0.5,0),
            BackgroundTransparency = .8,
            ThemeTag = {
                BackgroundColor3 = "Text"
            }
        })
        New("Frame", {
            Parent = Window.UIElements.SideBar,
            AutomaticSize = "Y",
            Size = UDim2.new(1,0,0,0),
            BackgroundTransparency = 1,
        }, {
            Divider
        })
    end
    
    local DialogModule = require("./Dialog").Init(Window)
    function Window:Dialog(DialogConfig)
        local DialogTable = {
            Title = DialogConfig.Title or "Dialog",
            Content = DialogConfig.Content,
            Buttons = DialogConfig.Buttons or {},
        }
        local Dialog = DialogModule.Create()
        
        
        Dialog.UIElements.UIListLayout = New("UIListLayout", {
            Padding = UDim.new(0,8*2.3),
            FillDirection = "Vertical",
            HorizontalAlignment = "Center",
            Parent = Dialog.UIElements.Main
        })
    
        New("UISizeConstraint", {
			MinSize = Vector2.new(50, 20),
			MaxSize = Vector2.new(620, math.huge),
			Parent = Dialog.UIElements.Main,
		})
        
        Dialog.UIElements.Title = New("TextLabel", {
            Text = DialogTable.Title,
            TextSize = 20,
            FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
            TextXAlignment = "Left",
            TextWrapped = true,
            RichText = true,
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            ThemeTag = {
                TextColor3 = "Text"
            },
            BackgroundTransparency = 1,
            Parent = Dialog.UIElements.Main
        })
        if DialogTable.Content then
            local Content = New("TextLabel", {
                Text = DialogTable.Content,
                TextSize = 16,
                TextTransparency = .4,
                TextWrapped = true,
                RichText = true,
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                TextXAlignment = "Left",
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = "Y",
                LayoutOrder = 2,
                ThemeTag = {
                    TextColor3 = "Text"
                },
                BackgroundTransparency = 1,
                Parent = Dialog.UIElements.Main
            })
        end
        
        New("Frame", {
            Name = "Line",
            Size = UDim2.new(1, Dialog.UIPadding*2, 0, 1),
            Parent = Dialog.UIElements.Main,
            LayoutOrder = 3,
            BackgroundTransparency = .8,
            ThemeTag = {
                BackgroundColor3 = "Text",
            }
        })
        
        local ButtonsContent = New("Frame", {
            Size = UDim2.new(1,0,0,0),
            AutomaticSize = "Y",
            BackgroundTransparency = 1,
            Parent = Dialog.UIElements.Main,
            LayoutOrder = 4,
        }, {
            New("UIListLayout", {
			    Padding = UDim.new(0, 10),
			    FillDirection = "Horizontal",
			    HorizontalAlignment = "Center",
		    }),
        })
        
        for _,Button in next, DialogTable.Buttons do
            local ButtonFrame = New("TextButton", {
                Text = Button.Title or "Button",
                TextSize = 14,
                FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
                ThemeTag = {
                    TextColor3 = "Text",
                    BackgroundColor3 = "Text",
                },
                BackgroundTransparency = .93,
                Parent = ButtonsContent,
                Size = UDim2.new(1 / #DialogTable.Buttons, -(((#DialogTable.Buttons - 1) * 10) / #DialogTable.Buttons), 0, 0),
                AutomaticSize = "Y",
            }, {
                New("UICorner", {
                    CornerRadius = UDim.new(0, Dialog.UICorner-7),
                }),
                New("UIPadding", {
                    PaddingTop = UDim.new(0, Dialog.UIPadding/1.85),
                    PaddingLeft = UDim.new(0, Dialog.UIPadding/1.85),
                    PaddingRight = UDim.new(0, Dialog.UIPadding/1.85),
                    PaddingBottom = UDim.new(0, Dialog.UIPadding/1.85),
                }),
                New("Frame", {
                    Size = UDim2.new(1,(Dialog.UIPadding/1.85)*2,1,(Dialog.UIPadding/1.85)*2),
                    Position = UDim2.new(0.5,0,0.5,0),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    ThemeTag = {
                        BackgroundColor3 = "Text"
                    },
                    BackgroundTransparency = 1, -- .9
                }, {
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Dialog.UICorner-7),
                    }),
                })
            })
            
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame.Frame, 0.1, {BackgroundTransparency = .9}):Play()
            end)
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame.Frame, 0.1, {BackgroundTransparency = 1}):Play()
            end)
            ButtonFrame.MouseButton1Click:Connect(function()
                Dialog:Close()
                task.spawn(function()
                    pcall(Button.Callback)
                end)
            end)
        end
        
        --Dialog:Open()
        
        return Dialog
    end
    
    local CloseDialog = Window:Dialog({
        Title = "Warning",
        Content = "Do you want to close this window?",
        Buttons = {
            {
                Title = "No",
                Callback = function() end
            },
            {
                Title = "Yes",
                Callback = function() Window:Close():Destroy() end
            }
        }
    })
    CloseButton.MouseButton1Click:Connect(function()
        CloseDialog:Open()
    end)

    local function startResizing(input)
        isResizing = true
        FullScreenIcon.Active = true
        initialSize = Window.UIElements.Main.Size
        initialInputPosition = input.Position
        Tween(FullScreenIcon, 0.2, {BackgroundTransparency = .65}):Play()
        Tween(FullScreenIcon.ImageLabel, 0.2, {ImageTransparency = 0}):Play()
    
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isResizing = false
                FullScreenIcon.Active = false
                Tween(FullScreenIcon, 0.2, {BackgroundTransparency = 1}):Play()
                Tween(FullScreenIcon.ImageLabel, 0.2, {ImageTransparency = 1}):Play()
            end
        end)
    end
    
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startResizing(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isResizing then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - initialInputPosition
                local newSize = UDim2.new(0, initialSize.X.Offset + delta.X*2, 0, initialSize.Y.Offset + delta.Y*2)
                
                Tween(Window.UIElements.Main, 0.06, {
                    Size = UDim2.new(
                    0, math.clamp(newSize.X.Offset, 400, 700),
                    0, math.clamp(newSize.Y.Offset, 350, 520)
                )}):Play()
            end
        end
    end)
    
    return Window
end
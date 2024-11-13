local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local lighting = game:GetService("Lighting")
local workspace = game.Workspace
local terrain = workspace.Terrain

-- Function to remove all other players' characters
local function removeOtherPlayers()
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            player.Character:Destroy()  -- Removes the character
        end
    end
end

-- Function to set up a grey sky without grey textures
local function setGreySky()
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    sky.SkyboxUp, sky.SkyboxDn, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxFt, sky.SkyboxBk = "", "", "", "", "", ""
    sky.SunAngularSize, sky.MoonAngularSize = 0, 0
    lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    lighting.Brightness = 0
    lighting.GlobalShadows = false
end

-- Function to remove stars and clouds from the sky
local function removeStarsAndClouds()
    -- Find or create a Sky instance in the Lighting service
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    
    -- Remove stars and clouds by setting the corresponding properties to empty or invisible values
    sky.StarCount = 0  -- Remove stars
    sky.SkyboxUp = ""  -- Remove clouds (set all skybox textures to empty)
    sky.SkyboxDn = ""
    sky.SkyboxLf = ""
    sky.SkyboxRt = ""
    sky.SkyboxFt = ""
    sky.SkyboxBk = ""
end

-- Function to remove particles, adjust textures and modify environment settings
local function modifyEnvironment()
    local decalsyeeted = true
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj:Destroy()
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1  -- Hide decals/textures
        elseif obj:IsA("Part") or obj:IsA("Union") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then
            obj.Material = "Plastic"
            obj.Reflectance = 0
        elseif obj:IsA("Explosion") then
            obj.BlastPressure = 1
            obj.BlastRadius = 1
        elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") then
            obj.Enabled = false
        elseif obj:IsA("MeshPart") then
            obj.Material = "Plastic"
            obj.Reflectance = 0
            obj.TextureID = 10385902758728957
        end
    end

    -- Disable visual effects
    for _, effect in pairs(lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
end

-- Initial setup (remove players, set sky, modify environment, and remove stars/clouds)
removeOtherPlayers()
setGreySky()
removeStarsAndClouds()
modifyEnvironment()

-- Connect to PlayerAdded to remove new players when they join
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        removeOtherPlayers()
    end)
end)

-- Connect to DescendantAdded to handle new objects and particles
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj:Destroy()
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1  -- Hide new decals/textures
    end
end)

-- Function to remove all water by setting all terrain to Air
local function removeWater()
    terrain:Clear()  -- Clears all terrain, effectively removing any existing water
end

-- Terrain settings to make it invisible
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
terrain.WaterTransparency = 1        -- Fully transparent water
terrain.Transparency = 1             -- Fully transparent terrain
terrain.CastShadow = false           -- No shadows for terrain

-- Lighting settings to reduce visuals
lighting.GlobalShadows = false
lighting.FogEnd = 0                   -- Extreme fog for complete darkness
lighting.Brightness = 0

-- Rendering quality setting for a potential FPS boost
settings().Rendering.QualityLevel = "Level01"

-- Function to hide all objects in the Workspace, except tools in the player's character
local function hideWorkspaceObjects()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent ~= localPlayer.Character then
            v.Transparency = 1  -- Make parts invisible
            v.CastShadow = false  -- Disable shadows
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1  -- Hide all decals and textures
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false  -- Turn off particles and trails
        elseif v:IsA("MeshPart") and v.Parent ~= localPlayer.Character then
            v.Transparency = 1
            v.CastShadow = false
        end
    end
end

-- Function to hide other players' avatars, but not the local player
local function hideOtherAvatars()
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            player.Character:Destroy()  -- Remove the character model of other players
        end
    end
end

-- Connect PlayerAdded to hide avatars when new players join
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        hideOtherAvatars()
    end)
end)

-- Initial calls to hide everything, remove water, and hide other avatars
removeWater()
hideWorkspaceObjects()
hideOtherAvatars()

-- Hide newly added objects in the Workspace, excluding tools
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Parent ~= localPlayer.Character then
        obj.Transparency = 1
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = false
    end
end)

-- Disable all post-processing effects for additional visual simplicity
for _, effect in pairs(lighting:GetChildren()) do
    if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") 
    or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
end

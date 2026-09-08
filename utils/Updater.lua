--[[
    CUZAO HUB - Updater
    Auto-update via GitHub Releases
]]

local Updater = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

Updater.Config = {
    GitHubUser = "SEU_USER",
    GitHubRepo = "CUZAO-HUB",
    Branch = "main",
    CheckOnStart = true,
    AutoUpdate = false,
    NotifyOnUpdate = true,
}

Updater.CurrentVersion = getgenv().CUZAO_VERSION or "1.0.0"
Updater.LatestVersion = nil
Updater.UpdateAvailable = false

-- ═══════════════════════════════════════════
-- VERSION COMPARISON
-- ═══════════════════════════════════════════
local function ParseVersion(version)
    local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
    return {
        major = tonumber(major) or 0,
        minor = tonumber(minor) or 0,
        patch = tonumber(patch) or 0,
    }
end

function Updater:CompareVersions(v1, v2)
    local a = ParseVersion(v1)
    local b = ParseVersion(v2)

    if a.major ~= b.major then return a.major > b.major end
    if a.minor ~= b.minor then return a.minor > b.minor end
    if a.patch ~= b.patch then return a.patch > b.patch end
    return false
end

-- ═══════════════════════════════════════════
-- CHECK FOR UPDATES
-- ═══════════════════════════════════════════
function Updater:CheckForUpdates()
    local url = string.format(
        "https://api.github.com/repos/%s/%s/releases/latest",
        self.Config.GitHubUser,
        self.Config.GitHubRepo
    )

    local success, response = pcall(function()
        if request then
            return request({
                Url = url,
                Method = "GET",
                Headers = { ["Accept"] = "application/vnd.github.v3+json" },
            })
        elseif http_request then
            return http_request({
                Url = url,
                Method = "GET",
                Headers = { ["Accept"] = "application/vnd.github.v3+json" },
            })
        end
        return nil
    end)

    if success and response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        self.LatestVersion = data.tag_name

        if self:CompareVersions(self.LatestVersion, self.CurrentVersion) then
            self.UpdateAvailable = true
            return {
                Available = true,
                Version = self.LatestVersion,
                Changelog = data.body or "",
                URL = data.html_url or "",
                Assets = data.assets or {},
            }
        end
    end

    self.UpdateAvailable = false
    return { Available = false }
end

-- ═══════════════════════════════════════════
-- GET LATEST FILES
-- ═══════════════════════════════════════════
function Updater:GetFiles()
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents?ref=%s",
        self.Config.GitHubUser,
        self.Config.GitHubRepo,
        self.Config.Branch
    )

    local success, response = pcall(function()
        if request then
            return request({
                Url = url,
                Method = "GET",
            })
        end
        return nil
    end)

    if success and response and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body)
    end
    return nil
end

-- ═══════════════════════════════════════════
-- DOWNLOAD FILE
-- ═══════════════════════════════════════════
function Updater:DownloadFile(path)
    local url = string.format(
        "https://raw.githubusercontent.com/%s/%s/%s/%s",
        self.Config.GitHubUser,
        self.Config.GitHubRepo,
        self.Config.Branch,
        path
    )

    local success, response = pcall(function()
        if httpget or (syn and syn.request) then
            if httpget then
                return httpget(url)
            else
                return syn.request({ Url = url, Method = "GET" }).Body
            end
        end
        return nil
    end)

    if success and response then
        return response
    end
    return nil
end

-- ═══════════════════════════════════════════
-- AUTO UPDATE
-- ═══════════════════════════════════════════
function Updater:AutoUpdate()
    local updateInfo = self:CheckForUpdates()

    if updateInfo.Available then
        print(string.format(
            "[CUZAO] Atualização disponível: %s (atual: %s)",
            updateInfo.Version,
            self.CurrentVersion
        ))

        if self.Config.NotifyOnUpdate and getgenv().CUZAO then
            pcall(function()
                local Notifications = getgenv().CUZAO.Modules["Notifications"]
                if Notifications then
                    Notifications:Show(
                        "Atualização Disponível",
                        "v" .. updateInfo.Version .. " disponível!",
                        "Info",
                        10
                    )
                end
            end)
        end

        if self.Config.AutoUpdate then
            self:UpdateFiles()
        end

        return updateInfo
    end

    return nil
end

function Updater:UpdateFiles()
    local files = self:GetFiles()
    if not files then return false end

    local updated = 0
    for _, file in ipairs(files) do
        if file.type == "file" and file.name:match("%.lua$") then
            local content = self:DownloadFile(file.path)
            if content and writefile then
                pcall(writefile, file.path, content)
                updated = updated + 1
                print("[CUZAO] Atualizado: " .. file.path)
            end
        end
    end

    print(string.format("[CUZAO] %d arquivos atualizados!", updated))
    return updated > 0
end

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
function Updater:Init()
    if self.Config.CheckOnStart then
        task.spawn(function()
            task.wait(3) -- Wait for hub to load
            self:AutoUpdate()
        end)
    end
end

return Updater
--- === BrowserManager ===
---
---
local hslogger = require("hs.logger")
local hschooser = require("hs.chooser")
local hsapplication = require("hs.application")
local hssettings = require("hs.settings")
local hsspaces = require("hs.spaces")
local hsinspect = require("hs.inspect")
local hswindow = require("hs.window")
local hscanvas = require("hs.canvas")
local hsdrawing = require("hs.drawing")
local hslayout = require("hs.layout")
local hsscreen = require("hs.screen")
local hstimer = require("hs.timer")
local hsfnutils = require("hs.fnutils")
local hseventtap = require("hs.eventtap")
local hsosascript = require("hs.osascript")
local hsnotify = require("hs.notify")
local hsurlEvent = require("hs.urlevent")

local m = {}
m.__index = m

-- Metadata
m.name = "BrowserManager"
m.version = "0.1"
m.author = "crumley@gmail.com"
m.license = "MIT"
m.homepage = "https://github.com/Hammerspoon/Spoons"

m.logger = hslogger.new('BrowserManager', 'info')

-- Settings

function m:init()
    m.logger.d('init')

    if hsurlevent.getDefaultHandler('http') ~= 'org.hammerspoon.hammerspoon' then
        return
    end

    hsurlevent.httpCallback = function(scheme, host, params, fullURL)
        local browser = "Google Chrome"
        local safari_app = hsapp.get(browser)
        local w = 0
        if safari_app == nil then
            w = 0
        else
            w = safari_app:allWindows()
            w = table.filter(w, hs.window.isVisible)
            w = #w
        end
        if (w > 0) then
            hs.alert.show("window on screen")
            hs.osascript.applescript('tell application "' .. browser .. '" to open location "' .. fullURL .. '"')
        else
            hs.alert.show("no window")
            hs.osascript.applescript('tell application "' .. browser .. '" to make new document with properties' ..
                                         ' {URL:"' .. fullURL .. '"}')
        end
        hs.osascript.applescript('tell application "' .. browser .. '" to activate')
    end
end

function m:start()

end

return m

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
local hsurlevent = require("hs.urlevent")

-- Name Chrome windows https://www.reddit.com/r/hammerspoon/comments/pcn425/psa_assign_stable_names_to_windows_in_chrome/
-- Long applescript for finding specific chrome window https://gist.github.com/wsoyka/8e0497379b9598dfe5116f04282247d1
-- display dialog (get index of window (windowID of browserInfo))

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
m.browserAppName = "Google Chrome"

function m:init()

end

function m:start()
    local defaultHandler = hsurlevent.getDefaultHandler('http')
    m.logger.i('start', defaultHandler, m.browserAppName)

    m.filter = hswindow.filter.new(false):setAppFilter(m.browserAppName, {
        visible = true,
        currentSpace = true
    }):setSortOrder(hswindow.filter.sortByFocusedLast)

    if defaultHandler ~= 'org.hammerspoon.Hammerspoon' then
        m.logger.i('Not the default handler, refusing to set callback')
        return
    end

    hsurlevent.httpCallback = function(scheme, host, params, fullURL)
        m.logger.d('httpCallback', scheme, host, params, fullURL)

        -- local browser = "Google Chrome"
        -- local w = hswindow.filter.new("Google Chrome"):getWindows()

        -- w = #w
        -- if (w > 0) then
        --     m.logger.d("window on screen")
        --     hsosascript.applescript('tell application "' .. browser .. '" to open location "' .. fullURL .. '"')
        -- else
        --     m.logger.d("no window")
        --     hsosascript.applescript('tell application "' .. browser .. '" to make new document with properties' ..
        --                                 ' {URL:"' .. fullURL .. '"}')
        -- end
        -- hs.osascript.applescript('tell application "' .. browser .. '" to activate')
        -- m:defaultOpenStrategy(fullURL)
        m:closestWindowOpenStrategy(fullURL)
    end
end

function m:defaultOpenStrategy(url)
    hsosascript.applescript('tell application "' .. m.browserAppName .. ' to open location "' .. url .. '"')
end

function m:closestWindowOpenStrategy(url)
    local w = m.filter:getWindows()
    if #w > 0 then
        m.logger.d('closest window found: ' .. hsinspect(w[1]))
        w[1]:focus()
        hsosascript.applescript('tell application "Google Chrome" to open location "' .. url .. '"')
    end
end

function foo()
    return function(browserName)
        local function open()
            hs.application.launchOrFocus(browserName)
        end
        local function jump(url)
            local script = ([[(function() {
      var browser = Application('%s');
      browser.activate();

      for (win of browser.windows()) {
        var tabIndex =
          win.tabs().findIndex(tab => tab.url().match(/%s/));

        if (tabIndex != -1) {
          win.activeTabIndex = (tabIndex + 1);
          win.index = 1;
        }
      }
    })();
  ]]):format(browserName, url)
            hs.osascript.javascript(script)
        end
        return {
            open = open,
            jump = jump
        }
    end

end

return m

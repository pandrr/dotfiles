-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")


-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
--require("awful.hotkeys_popup.keys")

local volumebar_widget = require("volume")


-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- local switcher = require("awesome-switcher")

local cyclefocus = require('cyclefocus')



-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = "subl"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    -- awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
   { "sleep", function() awful.util.spawn("systemctl suspend") end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
-- mytextclock = wibox.widget.textclock({font="Arial 16",format=" %a %b %d", refresh=60, timezone="local timezone"})

-- mytextclock = wibox.widget.textclock();
mytextclock = awful.widget.textclock('<span color="#ffffff" font="monospace 12" >%a %d.%m %H:%M </span>')


function cycleClientWidth(c)

    if c.width == math.floor(c.screen.workarea.width*0.33) then c.width=c.screen.workarea.width*0.5
      else if c.width == math.floor(c.screen.workarea.width*0.5) then c.width=c.screen.workarea.width*0.66	
        else c.width=math.floor(c.screen.workarea.width*0.33) end
      end

end

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                     	-- awful.menu.client_list({ theme = { width = 500 }},{},awful.widget.tasklist.filter.currenttags)
                     	awful.menu.client_list({ theme = { width = 600 } })
                                              -- if c == client.focus then
                                              --     c.minimized = true
                                              -- else
                                              --     c:emit_signal(
                                              --         "request::activate",
                                              --         "tasklist",
                                              --         {raise = true}
                                              --     )
                                              -- end
                                          end),
                     awful.button({ }, 3, function()
                                              -- awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 8, function ()
                                              awful.client.focus.byidx(1)
                                         end),
                     awful.button({ }, 9, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)


    -- Each screen has its own tag table.
    awful.tag({ "  1  ", "  2  ", "  3  ", "  4  ", "  5  ", "  6  ", "  7  ", "  8  " }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        -- filter  = awful.widget.tasklist.filter.currenttags,
        filter = awful.widget.tasklist.filter.focused,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s,height = 30,bg="#222222",ontop=true })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
          expand = "none",
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing=15,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
            s.mytasklist,
        },
        {
        	-- Middle widget	
			layout = wibox.layout.fixed.horizontal,
         	
        },
        
        
        { -- Right widge
        	
			spacing=10,
            layout = wibox.layout.fixed.horizontal,
            -- mykeyboardlayout,
            -- wibox.widget.systray(),
            
            wibox.layout.margin(wibox.widget.systray(), 4, 4, 4, 4),

            wibox.layout.margin(
            volumebar_widget({
                main_color = '#888888',
                mute_color = '#555555',
                width = 80,
                -- shape = 'rounded_bar', -- octogon, hexagon, powerline, etc
                -- bar's height = wibar's height minus 2x margins
                margins = 10
            })
            ,0,5,0,0),
            mytextclock
            -- s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, "Mod1"          }, "Escape",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
    --           {description = "view previous", group = "tag"}),
    -- awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
    --           {description = "view next", group = "tag"}),

    awful.key({ modkey,           }, "[",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "]",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),

    -- awful.key({ modkey,           }, "[",
    --     function ()
    --         awful.client.focus.byidx( 1)
    --     end, {description = "focus next by index", group = "Window navigation"}
    -- ),
    -- awful.key({ modkey,           }, "]",
    --     function ()
    --         awful.client.focus.byidx(-1)
    --     end, {description = "focus previous by index", group = "Window navigation"}
    -- ),
    -- awful.key({ modkey,           }, "r", function () mymainmenu:show() end,
              -- {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    -- awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
    --           {description = "swap with next client by index", group = "Window"}),
    -- awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
    --           {description = "swap with previous client by index", group = "Window"}),
    -- awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
    --           {description = "focus the next screen", group = "screen"}),
    -- awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
    --           {description = "focus the previous screen", group = "screen"}),
    -- awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
    --           {description = "jump to urgent client", group = "Window"}),
    -- awful.key({ modkey,           }, "Tab",
    --     function ()
    --         awful.client.focus.history.previous()
    --         if client.focus then
    --             client.focus:raise()
    --         end
    --     end,
    --     {description = "go back", group = "Window"}),


-- modkey+Tab: cycle through all clients.
awful.key({ modkey }, "Tab", function(c)
    cyclefocus.cycle({modifier="Super_L"})
end),
-- modkey+Shift+Tab: backwards
awful.key({ modkey, "Shift" }, "Tab", function(c)
    cyclefocus.cycle({modifier="Super_L"})
end),

-- awful.key({ modkey,           }, "Tab",
--     function ()
--         -- awful.client.focus.history.previous()
--         awful.client.focus.byidx(-1)
--         if client.focus then
--             client.focus:raise()
--         end
--     end,{description = "tab", group = "Window navigation"}),

-- awful.key({ modkey, "Shift"   }, "Tab",
--     function ()
--         -- awful.client.focus.history.previous()
--         awful.client.focus.byidx(1)
--         if client.focus then
--             client.focus:raise()
--         end
--     end,{description = "tab", group = "Window navigation"}),


    -- awful.key({ modkey,           }, "Tab",
    --   function ()
    --       switcher.switch( 1, "Super_L", "Super_L", "Shift", "Tab")
    --   end),
    
    -- awful.key({ modkey, "Shift"   }, "Tab",
    --   function ()
    --       switcher.switch(-1, "Super_L", "Super_L", "Shift", "Tab")
    --   end),

    -- Standard program
    awful.key({ modkey,           }, "\\", function () awful.spawn("kitty ranger") end,
              {description = "open ranger", group = "launcher"}),

    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- awful.key({ modkey   }, "c", function()

	    -- awful.util.spawn("sh -c 'xdotool sleep 0.1 key --clearmodifiers Down'") 
        -- root.fake_input('key_release', modkey)

  -- root.fake_input('key_release'  , 'Super_L')
  --       root.fake_input('key_press'  , "Control_L")
  --        root.fake_input('key_press'  , "c")
		--  root.fake_input('key_release', "c")
  --       root.fake_input('key_release', "Control_L")

  --       --root.fake_input("key_press", 64)
		-- end,
  --       {description = "quit awesome", group = "awesome"}),




  --   awful.key({ modkey   }, "c", function()
  --   	awful.util.spawn("xdotool key ctrl+c")
		-- end,
  --       {description = "quit awesome", group = "awesome"}),

  --   awful.key({ modkey   }, "v", function()
  --   	awful.util.spawn("xdotool key ctrl+v")
		-- end,
  --       {description = "quit awesome", group = "awesome"}),



    -- awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
    --           {description = "increase master width factor", group = "layout"}),
    -- awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
    --           {description = "decrease master width factor", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    --           {description = "increase the number of master clients", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    --           {description = "decrease the number of master clients", group = "layout"}),
    -- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    --           {description = "increase the number of columns", group = "layout"}),
    -- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    --           {description = "decrease the number of columns", group = "layout"}),
    -- awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              -- {description = "select next", group = "layout"}),
    -- awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    --           {description = "select previous", group = "layout"}),

    -- awful.key({ modkey, "Control" }, "n",
    --           function ()
    --               local c = awful.client.restore()
    --               -- Focus restored client
    --               if c then
    --                 c:emit_signal(
    --                     "request::activate", "key.unminimize", {raise = true}
    --                 )
    --               end
    --           end,
    --           {description = "restore minimized", group = "Window"}),

    -- Prompt
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),

    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run {
    --                 prompt       = "Run Lua code: ",
    --                 textbox      = awful.screen.focused().mypromptbox.widget,
    --                 exe_callback = awful.util.eval,
    --                 history_path = awful.util.get_cache_dir() .. "/history_eval"
    --               }
    --           end,
    --           {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
              -- {description = "show the menubar", group = "launcher"}),







-- my keys....


    awful.key({ modkey           }, "Escape", function()
        awful.spawn("rofi -show")
      end,
              {description = "rofi list of windows", group = "Window navigation"}),


        awful.key(
          { modkey }, 
          "space", 
          function () 
            awful.spawn("rofi -show run")
          end,
              {description = "ROFI", group = "launcher"})

)

clientkeys = gears.table.join(
    -- awful.key({ modkey,           }, "f",
    --     function (c)
    --         c.fullscreen = not c.fullscreen
    --         c:raise()
    --     end,
    --     {description = "toggle fullscreen", group = "Window"}),
    awful.key({ modkey   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "Window"}),
    -- awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
    --           {description = "toggle floating", group = "Window"}),
    -- awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
    --           {description = "move to master", group = "Window"}),
    -- awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              -- {description = "move to screen", group = "Window"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "Window"}),
    awful.key({ modkey,           }, "h",
        function (c)
            c.minimized = true
        end ,
        {description = "minimize current", group = "Window"}),
    awful.key({ modkey,"Mod1"           }, "h",
        function (c)
			local clients = awful.tag.selected(1):clients()
			for k,ic in pairs(clients) do
    			if c == ic then else ic.minimized = true end
			end
        end ,
        {description = "minimize others", group = "Window"}),

    awful.key({ modkey,"Shift"           }, "h",
        function (c)
			local clients = awful.tag.selected(1):clients()
			for k,ic in pairs(clients) do
    			ic.minimized = false
			end
        end ,
        {description = "unminimize all", group = "Window"}),

    -- awful.key({ modkey, "Control" }, "m",
    --     function (c)
    --         c.maximized_vertical = not c.maximized_vertical
    --         c:raise()
    --     end ,
    --     {description = "(un)maximize vertically", group = "Window"}),

    awful.key({ modkey, "Mod1" }, "4",
        function (c)

        	awful.spawn.easy_async_with_shell("maim -s ~/Pictures/screenshot_$(date +%s).png &")
        end,
        {description = "screenshot area", group = "screenshot"}),

        awful.key({ modkey, "Mod1" }, "3", function (c)
        	awful.util.spawn("gnome-screenshot")
        end ,
      {description = "screenshot of whole screen", group = "screenshot"}),




    awful.key({ modkey, "Mod1" }, "Up",
        function (c)
            -- awful.placement.top(c)
            c.height=c.screen.workarea.height/2
            c.y=c.screen.workarea.y
            c:raise()
        end ,
        {description = "Move to Left and resize ", group = "Window positioning"}),

    awful.key({ modkey, "Mod1" }, "Down",
        function (c)

            c.height=c.screen.workarea.height/2+8*2
            c.y=c.screen.workarea.height/2
            c:raise()
        end ,
        {description = "Move to Left and resize ", group = "Window positioning"}),



    awful.key({ modkey, "Mod1" }, "Left",
        function (c)
         	local oldX=c.x;
            awful.placement.left(c)

            if oldX==c.x then cycleClientWidth(c) end

            c.height=c.screen.workarea.height-(8*2)
            c.y=c.screen.workarea.y
            c:raise()
        end ,
        {description = "Move to Left and resize ", group = "Window positioning"}),


    awful.key({ modkey, "Mod1" }, "c",
        function (c)
            local oldX=c.x
            awful.placement.centered(c)

            if oldX == c.x then
            	cycleClientWidth(c)
            	awful.placement.centered(c)
            end

            c.height=c.screen.workarea.height-(8*2)
            c.y=c.screen.workarea.y
            c:raise()
        end ,
        {description = "Center Window", group = "Window positioning"}),



    awful.key({ modkey, "Mod1" }, "Right",
        function (c)
        	
        	local oldX=c.x
            awful.placement.right(c)

            if oldX==c.x then
            	cycleClientWidth(c) 
            	awful.placement.right(c)
            end

            c.height=c.screen.workarea.height-(8*2)
            c.y=c.screen.workarea.y
            c:raise()
        end ,
        {description = "Move to Right and resize", group = "Window positioning"}),



    awful.key({ modkey,"Mod1"        }, "f",

        function (c)
        	if c.width==c.screen.workarea.width-(8*2)
    		then
    			c.width=c.widthBeforeFullscreen
    			c.height=c.heightBeforeFullscreen
    			c.x=c.xBeforeFullscreen or c.screen.workarea.x
    			c.y=c.yBeforeFullscreen or c.screen.workarea.y
    		else
    			c.widthBeforeFullscreen=c.width
    			c.heightBeforeFullscreen=c.height
    			c.xBeforeFullscreen=c.x
    			c.yBeforeFullscreen=c.y

  				c.width=c.screen.workarea.width-(8*2)
  				c.height=c.screen.workarea.height-(8*2)
  				c.x=c.screen.workarea.x
  				c.y=c.screen.workarea.y
    		end

            c:raise()
        end ,

        {description = "Toggle Fullscreen", group = "Window positioning"})

    -- awful.key({ modkey, "Mod1" }, "f",
    --     function (c)

    --         c.width = c.screen.workarea.width
    --         c.height = c.screen.workarea.height
    --         c.y=c.screen.workarea.y
    --         c.x=c.screen.workarea.x
    --         c:raise()
    --     end ,
    --     {description = "(un)maximize vertically", group = "Window"}),

    -- awful.key({ modkey, "Mod1"   }, "Left", awful.placement.left),
    -- awful.key({ modkey, "Mod1"   }, "Right", awful.placement.right),
    -- awful.key({ modkey, "Mod1"   }, "c", awful.placement.centered),


    -- awful.key({ modkey, "Shift"   }, "m",
    --     function (c)
    --         c.maximized_horizontal = not c.maximized_horizontal
    --         c:raise()
    --     end ,
    --     {description = "(un)maximize horizontally", group = "Window"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        -- awful.key({ modkey, "Control" }, "#" .. i + 9,
        --           function ()
        --               local screen = awful.screen.focused()
        --               local tag = screen.tags[i]
        --               if tag then
        --                  awful.tag.viewtoggle(tag)
        --               end
        --           end,
        --           {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
        -- Toggle tag on focused client.
        -- awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
        --           function ()
        --               if client.focus then
        --                   local tag = client.focus.screen.tags[i]
        --                   if tag then
        --                       client.focus:toggle_tag(tag)
        --                   end
        --               end
        --           end,
        --           {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )


-- local top_titlebar = awful.titlebar(c, {
-- });

--     -- awful.titlebar(c) : setup {
--     top_titlebar : setup {

--         -- { -- Left
--         --     awful.titlebar.widget.iconwidget(c),
--         --     buttons = buttons,
--         --     layout  = wibox.layout.fixed.horizontal
--         --   },
--         -- { -- Middle
--         --     { -- Title
--         --         align  = "center",
--         --         widget = awful.titlebar.widget.titlewidget(c)
--         --     },
--         --     buttons = buttons,
--         --     layout  = wibox.layout.flex.horizontal
--         -- },
--         { -- Right
--             -- awful.titlebar.widget.floatingbutton (c),
--             awful.titlebar.widget.maximizedbutton(c),
--             -- awful.titlebar.widget.stickybutton   (c),
--             -- awful.titlebar.widget.ontopbutton    (c),
--             awful.titlebar.widget.closebutton    (c),
--             layout = wibox.layout.fixed.horizontal(),

--         },
--         layout = wibox.layout.align.horizontal

--     }
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- end)

client.connect_signal("focus", function(c) 
    c.border_color = beautiful.border_focus
    c.border_width = 8
  end)
client.connect_signal("unfocus", function(c) 
  c.border_color = beautiful.border_normal 
  c.border_width = 8
end)
-- }}}










-- globalkeys = gears.table.join(
-- )

--     awful.key({ modkey, }, "space", function () awful.util.spawn("rofi -show")                end)
--     {description = "rofi", group = "layout"}),
 
-- beautiful.tasklist_bg_focus="#333333";
-- beautiful.tagList_font = "Arial 22"

beautiful.hotkeys_font="Monospace 13"
beautiful.hotkeys_description_font="Monospace 13"

beautiful.notification_font="Monospace 12"
beautiful.notification_margin=40
beautiful.notification_max_width=500
beautiful.notification_icon_size=50



mymainmenu.menu_font="Monospace 13"
beautiful.menu_height=30
mymainmenu.menu_width=730
beautiful.menu_border_width=8
beautiful.menu_bg_focus="#444444"
beautiful.menu_fg_focus="#ffffff"
beautiful.menu_fg_normal="#999999"

beautiful.taglist_bg_focus="#555555"
beautiful.taglist_fg_focus="#ffffff"

beautiful.taglist_fg_empty="#ffffff"
beautiful.taglist_fg_occupied="#ffffff"

beautiful.taglist_bg_occupied="#333333"
beautiful.taglist_bg_empty="#222222"

beautiful.tasklist_font="Monospace 12"
beautiful.tasklist_disable_icon=true
-- beautiful.tasklist_bg_normal="#333333"

beautiful.border_normal="#181818"
beautiful.titlebar_bg="#181818"

beautiful.border_focus="#333333"
beautiful.titlebar_bg_focus="#333333"

beautiful.systray_icon_spacing=10

beautiful.bg_normal="#222222"

gears.wallpaper.set("#222222");

beautiful.border_width = 0

awful.util.spawn("compton  --backend glx --vsync opengl-swc ")
awful.util.spawn("nitrogen --restore &")

awful.util.spawn("conky -c dotfiles/conkyrc")
awful.util.spawn("setxkbmap eurkey")


cyclefocus.display_next_count = 3
cyclefocus.display_prev_count = 1

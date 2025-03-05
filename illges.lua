-- illges' default norns script

---@diagnostic disable: undefined-global, lowercase-global, duplicate-set-field

SCRIPT_NAME = "illges"
local _grid = include 'lib/_grid'
local _dm = include 'device_manager/lib/device_manager' -- install from https://github.com/illges/device_manager

engine.name = 'PolyPerc'

message_count = 0

function init()
    message = SCRIPT_NAME
    device_manager = _dm.new({adv=false, debug=false})
    g=_grid:new()

    screen_redraw_clock()
    grid_redraw_clock()
end

function screen_redraw_clock()
    screen_drawing=metro.init()
    screen_drawing.time=0.1
    screen_drawing.count=-1
    screen_drawing.event=function()
        if message_count>0 then
            message_count=message_count-1
        else
            message = SCRIPT_NAME
            screen_dirty = true
        end
        if screen_dirty == true then
            redraw()
            screen_dirty = false
        end
    end
    screen_drawing:start()
end

function set_message(msg, count)
    message = msg
    message_count = count and count or 8
    screen_dirty = true
end

function grid_redraw_clock()
    grid_drawing=metro.init()
    grid_drawing.time=0.1
    grid_drawing.count=-1
    grid_drawing.event=function()
        if grid_dirty == true then
            g:grid_redraw()
            grid_dirty = false
        end
    end
    grid_drawing:start()
end

function enc(e, d)
    if e == 1 then turn(e, d) end
    if e == 2 then turn(e, d) end
    if e == 3 then turn(e, d) end
    screen_dirty = true
end

function turn(e, d)
    set_message("encoder " .. e .. ", delta " .. d)
end

function key(k, z)
    if z == 0 then return end
    if k == 2 then press_down(2) end
    if k == 3 then press_down(3) end
    screen_dirty = true
end

function press_down(i)
    set_message("press down " .. i)
end

function redraw()
    screen.clear()
    screen.aa(1)
    screen.font_face(1)
    screen.font_size(8)
    screen.level(15)
    screen.move(64, 32)
    screen.text_center(message)
    screen.pixel(0, 0)
    screen.pixel(127, 0)
    screen.pixel(127, 63)
    screen.pixel(0, 63)
    screen.fill()
    screen.update()
end

function midi_event_note_on(d)
    set_message(d.note)
end

function midi_event_note_off(d) end

function midi_event_start(d) end

function midi_event_stop(d) end

function midi_event_cc(d) end

function r() ----------------------------- execute r() in the repl to quickly rerun this script
    norns.script.load(norns.state.script) -- https://github.com/monome/norns/blob/main/lua/core/state.lua
end

function cleanup() --------------- cleanup() is automatically called on script close
    clock.cancel(redraw_clock_id) -- melt our clock vie the id we noted
    clock.cancel(grid_redraw_clock_id) -- melt our clock vie the id we noted
end
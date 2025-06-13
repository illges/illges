-- illges' default norns script template

---@diagnostic disable: undefined-global, lowercase-global, duplicate-set-field

SCRIPT_NAME = "illges"
local _grid = include 'lib/_grid'
local _dm = include 'device_manager/lib/_device_manager' -- install from https://github.com/illges/device_manager
local _pacifist = include 'pacifist_dev/lib/_pacifist' -- install from https://github.com/illges/pacifist_dev

engine.name = 'PolyPerc'

message_count = 0

function init()
    message = SCRIPT_NAME
    dm = _dm.new({adv=false, debug=false})
    mft = _pacifist:new({devices=dm.devices, debug=false})
    g=_grid:new()

    screen_dirty = true
    grid_dirty = true
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
        mft:activity_countdown()
        if grid_dirty == true then
            g:grid_redraw()
            redraw_mft()
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

function redraw_mft()
    --mft:all(0)
    for i=1,16 do
        mft:led(i, mft.color[i]) --color is optional
        mft:send(i, mft.ind[i])
    end
end

function mft_enc(n,d)
    set_message("mft enc "..n.." turned")
    mft.last_turned = n
    mft.enc_activity_count = 15
    mft.activity_count = 15
    mft:delta_color(n,d)
    if n<9 then
        mft.ind[n] = util.clamp(mft.ind[n]+d,0,127)
    else
        mft.ind[n] = util.wrap(mft.ind[n]+d,0,127)
    end
    screen_dirty = true
    grid_dirty=true
end

function mft_key(n,z)
    local on = z==1
    mft.momentary[n] = on and 1 or 0
    if on then
        set_message("mft key "..n.." pressed")
        mft.last_pressed = n
        mft.key_activity_count = 15
        mft.activity_count = 15
        if n>=1 and n<=4 then
            mft:set_color(n,64)
        elseif n>=5 and n<=8 then
            mft:toggle_color(n,1,64)
        elseif n>=9 and n<=16 then
            mft:delta_color(n,10)
        elseif n==17 then
        elseif n==18 then
        elseif n==19 then
        elseif n==20 then
        elseif n==21 then
        elseif n==22 then
        end
    else
        if n>=1 and n<=4 then
            mft:toggle_color(n,1)
        end
    end
    screen_dirty = true
    grid_dirty=true
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

end
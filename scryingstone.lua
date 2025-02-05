---scryingstone
--
-- “So shall my word be that 
-- goeth forth out of my 
-- mouth: it shall not 
-- return unto me void, but 
-- it shall accomplish that 
-- which I please, and it 
-- shall prosper in the 
-- thing whereto I sent it.” 
--
-- Isaiah 55:11

_lfos = require 'lfo'
engine.name='scryingstone'
colors = {"white","pink","brown"}
shift = false
function enc(n, d)
    for i=1,3 do
        if n == i then
            if shift then
                params:delta(colors[i].."_noise_pan",d)
            else
                params:delta(colors[i].."_noise_level",d)
            end
        end
    end
end 
function key(n,z)
    for i=1,3 do
        if z == 1 then
            shift = true
        else 
            shift = false
        end
    end
end
function add_parameters()
    params:add_separator("scryingstone")
    params:add_group('levels',6)
    for i=1,3 do
        params:add_control(colors[i].."_noise_level",colors[i].." noise level",controlspec.AMP)
        params:set_action(colors[i].."_noise_level",function(value) osc.send({"localhost","57120"},"/amps",{i-1,value}) end)
        params:set(colors[i].."_noise_level",0.2)
        params:add {
            type = "trigger",
            id = colors[i].."_noise_level_rand",
            name = "   randomize",
            action = function() params:set(colors[i].."_noise_level",math.random(1,10)*0.1) end}
    end
    params:add_group('panning',6)
    for i=1,3 do
        params:add_control(colors[i].."_noise_pan",colors[i].." noise pan",controlspec.PAN)
        params:set_action(colors[i].."_noise_pan",function(value) osc.send({"localhost","57120"},"/pans",{i-1,value}) end)
        params:add {
            type = "trigger",
            id = colors[i].."_noise_pan_rand",
            name = "   randomize",
            action = function() params:set(colors[i].."_noise_pan",math.random(-10,10)*0.1) end}
    end
    amp_lfo = {}
    pan_lfo = {}
    lfo_periods = {20,21,22,23,24,25}
    for i = 1,3 do
        amp_lfo[i] = _lfos:add{min = 0, max = 1, depth = 1, mode = 'free', period = lfo_periods[i+3]}
        pan_lfo[i] = _lfos:add{min = -1, max = 1, depth = 1, mode = 'free', period = lfo_periods[i]}
    end
    params:add_group('lfos',96)
    for i=1,3 do
        amp_lfo[i]:add_params(colors[i]..'_noise_amp_lfo',colors[i]..' noise amp')
        amp_lfo[i]:set('action', function(scaled, raw) params:set(colors[i].."_noise_level",scaled) end)
        pan_lfo[i]:add_params(colors[i]..'_noise_pan_lfo',colors[i]..' noise pan')
        pan_lfo[i]:set('action', function(scaled, raw) params:set(colors[i].."_noise_pan",scaled) end)
    end
end
function redraw(x,y)
    screen.clear()
    for i=1,128 do
        for j=1,64 do
            if math.random(0,1) == 1 then
                screen.level(math.random(1,15))
                screen.pixel(i,j)
                screen.fill()
            end
        end
    end
    screen.update()
end
function init()
    add_parameters()
    redrawtimer = metro.init(function() redraw() end, 1/15, -1)
    redrawtimer:start()  -- start the timer
end

-- Red Light version 1.1
-- by Hopper and Sharkie Lino

Triggers = { }

function Triggers.init()
  gamestate = "Red"
  ticksleft = 0
end

function Triggers.idle()
  -- update state machine
  ticksleft = ticksleft - 1
  if ticksleft < 1 then
    if gamestate == "Red" then
      gamestate = "Green"
      ticksleft = rsecs(3, 30)
      do_sound("puzzle switch")
    elseif gamestate == "Green" then
      gamestate = "Yellow"
      ticksleft = 80
      do_sound("alarm")
    elseif gamestate == "Yellow" then
      gamestate = "Red"
      ticksleft = rsecs(0, 9)
      do_sound("siren")
    end
    set_color(gamestate)
  end
  
  -- punish movement or firing on red state
  if gamestate == "Red" then
    for p in Players() do
      if not p.dead then
        if (not (p.internal_velocity.forward == 0)) or (not (p.internal_velocity.perpendicular == 0)) or (p.action_flags.left_trigger == true) or (p.action_flags.right_trigger == true) then
          punish_player(p)
        end
      end
    end
  end
end

function do_sound(name)
  local snd = Sounds[name]
  for p in Players() do
    p:play_sound(snd)
  end
end

function punish_player(player)
  player.invincibility_duration = 0
  player.life = 0
  player:damage(1)
  Players.print("Hey, " .. player.name .. ". Red means stop!")
end

function set_color(state)
  local clr = 0
  if state == "Red" then clr = 2 end
  if state == "Yellow" then clr = 5 end
--  clr = OverlayColors[state].index
  for p in Players() do
    for i = 0,5 do
      p.overlays[i].text = state
      p.overlays[i]:fill_icon(clr)
    end
  end
end

function rsecs(min, max)
  return math.floor((min * 30) + Game.global_random(max * 30))
end

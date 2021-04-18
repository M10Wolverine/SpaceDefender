note
	description: "Summary description for {MESSAGES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGES

create
	make

feature{NONE}
	make(states: ARRAY[STRING])
	do
		COL_LIST:=<<"A","B","C","D","E","F","G","H","I","J">>
		--game_states:=<<"not started","weapon setup","armour setup","engine setup","power setup","setup summary","in game">>
		play_summary:=<<"Weapon Selected:","Armour Selected:","Engine Selected:","Power Selected:">>
		GAME_STATES:=states
		weapon_list:=<<"Standard","Spread","Snipe","Rocket","Splitter">>
		engine_list:=<<"Standard","Light","Armoured">>
		armour_list:=<<"None","Light","Medium","Heavy">>
		power_list:=<<"Recall (50 energy): Teleport back to spawn.","Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.",
		"Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.","Deploy Drones (100 energy): Clear all projectiles.",
		"Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.">>

	end

feature --message constants
	COL_LIST: ARRAY[STRING]
	GAME_STATES: ARRAY[STRING]
	num_row, num_col: INTEGER

	NOT_STARTED: INTEGER=1
	WEAPON_SETUP: INTEGER=2
	ARMOUR_SETUP: INTEGER=3
	ENGINE_SETUP: INTEGER=4
	POWER_SETUP: INTEGER=5
	SETUP_SUMMARY: INTEGER=6
	IN_GAME: INTEGER=7

	--common
	not_ingame: STRING = "Command can only be used in game."
	not_insetup: STRING="Command can only be used in setup mode."

	--setup
	not_insetup_no_sum: STRING="Command can only be used in setup mode (excluding summary in setup)."
	setup_out_of_range: STRING="Menu option selected out of range."

	set_grid_size(rows, cols: INTEGER)
	do
		num_row:=rows
		num_col:=cols
	end

feature	--abort command
	abort_not_ingame: STRING="Command can only be used in setup mode or in game."
	abort_exited(current_state: INTEGER): STRING
	local
		message: STRING
	do
		create message.make_from_string ("Exited from ")
		if current_state=IN_GAME then
			message.append ("game.")
		else
			message.append ("setup mode.")
		end
		Result:=message
	end


feature	--movement messages
	move_outsid: STRING = "Cannot move outside of board."
	move_present: STRING="Already there."
	move_toofar: STRING="Out of movement range."
	move_noresource: STRING="Not enough resources to move."

feature	--play command messages
	play_summary: ARRAY[STRING]
	play_already_ingame: STRING="Already in a game. Please abort to start a new one."
	play_not_decrease: STRING= "Threshold values are not non-decreasing."
	play_already_setup: STRING="Already in setup mode."
	play_weapon_info: STRING=
	"{
1:Standard (A single projectile is fired in front)
    Health:10, Energy:10, Regen:0/1, Armour:0, Vision:1, Move:1, Move Cost:1,
    Projectile Damage:70, Projectile Cost:5 (energy)
  2:Spread (Three projectiles are fired in front, two going diagonal)
    Health:0, Energy:60, Regen:0/2, Armour:1, Vision:0, Move:0, Move Cost:2,
    Projectile Damage:50, Projectile Cost:10 (energy)
  3:Snipe (Fast and high damage projectile, but only travels via teleporting)
    Health:0, Energy:100, Regen:0/5, Armour:0, Vision:10, Move:3, Move Cost:0,
    Projectile Damage:1000, Projectile Cost:20 (energy)
  4:Rocket (Two projectiles appear behind to the sides of the Starfighter and accelerates)
    Health:10, Energy:0, Regen:10/0, Armour:2, Vision:2, Move:0, Move Cost:3,
    Projectile Damage:100, Projectile Cost:10 (health)
  5:Splitter (A single mine projectile is placed in front of the Starfighter)
    Health:0, Energy:100, Regen:0/10, Armour:0, Vision:0, Move:0, Move Cost:5,
    Projectile Damage:150, Projectile Cost:70 (energy)
	}"
	play_armour_info: STRING=
	"{
1:None
    Health:50, Energy:0, Regen:1/0, Armour:0, Vision:0, Move:1, Move Cost:0
  2:Light
    Health:75, Energy:0, Regen:2/0, Armour:3, Vision:0, Move:0, Move Cost:1
  3:Medium
    Health:100, Energy:0, Regen:3/0, Armour:5, Vision:0, Move:0, Move Cost:3
  4:Heavy
    Health:200, Energy:0, Regen:4/0, Armour:10, Vision:0, Move:-1, Move Cost:5
	}"
	play_engine_info: STRING=
	"{
1:Standard
    Health:10, Energy:60, Regen:0/2, Armour:1, Vision:12, Move:8, Move Cost:2
  2:Light
    Health:0, Energy:30, Regen:0/1, Armour:0, Vision:15, Move:10, Move Cost:1
  3:Armoured
    Health:50, Energy:100, Regen:0/3, Armour:3, Vision:6, Move:4, Move Cost:5
	}"
	play_power_info: STRING=
	"{
1:Recall (50 energy): Teleport back to spawn.
  2:Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.
  3:Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.
  4:Deploy Drones (100 energy): Clear all projectiles.
  5:Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.
	}"

	weapon_list: ARRAY[STRING]
	engine_list:ARRAY[STRING]
	armour_list: ARRAY[STRING]
	power_list: ARRAY[STRING]

	play_out(game_state: INTEGER; module_selection: ARRAY[INTEGER]): STRING
	local
		message: STRING
	do
		create message.make_empty
		if game_state = WEAPON_SETUP then
			message.append ("%N  "+play_weapon_info)
			message.append ("%N  "+play_summary[game_state-1].out+weapon_list[module_selection[game_state-1]])
		elseif game_state = ARMOUR_SETUP then
			message.append("%N  "+play_armour_info)
			message.append ("%N  "+play_summary[game_state-1].out+armour_list[module_selection[game_state-1]])
		elseif game_state = ENGINE_SETUP then
			message.append("%N  "+play_engine_info)
			message.append ("%N  "+play_summary[game_state-1].out+engine_list[module_selection[game_state-1]])
		elseif game_state = POWER_SETUP then
			message.append("%N  "+play_power_info)
			message.append ("%N  "+play_summary[game_state-1].out+power_list[module_selection[game_state-1]])
		elseif game_state = SETUP_SUMMARY then
			message.append ("%N  "+play_summary[1].out+weapon_list[module_selection[1]])
			message.append ("%N  "+play_summary[2].out+armour_list[module_selection[2]])
			message.append ("%N  "+play_summary[3].out+engine_list[module_selection[3]])
			message.append ("%N  "+play_summary[4].out+power_list[module_selection[4]])
		end
		Result:=message
	end


feature	--fire command messages
	fire_noresource: STRING="Not enough resources to fire."

	--menu
	init: STRING="Welcome to Space Defender Version 2."
	game_over: STRING="The game is over. Better luck next time!"

	--special
	special_noresource: STRING="Not enough resources to use special."

feature --debug messages
	is_debug_out(debug_mode: BOOLEAN):STRING
	do
		if debug_mode then
			Result:="In debug mode."
		else
			Result:="Not in debug mode."
		end
	end

feature --ingame abstract outs
	player_out(player: PLAYER; score: INTEGER): STRING
	local
		message: STRING
	do
		create message.make_from_string ("Starfighter:")
		message.append ("%N    ["+player.id.out+",S]->")
		message.append ("health:"+player.current_health.out+"/"+player.max_health.out+", ")
		message.append ("energy:"+player.current_energy.out+"/"+player.max_energy.out+", ")
		message.append ("Regen:"+player.max_health_regen.out+"/"+player.max_energy_regen.out+", ")
		message.append ("Armour:"+player.max_armour.out+", Vision:"+player.max_vision.out+", ")
		message.append ("Move:"+player.max_moves.out+", Move Cost:"+player.move_cost.out+", ")
		message.append ("location:["+col_list[player.y]+","+player.x.out+"]" )
		message.append ("%N      Projectile Pattern:"+player.weapon.name+", Projectile Damage:"+player.weapon.damage.out)
		message.append (", Projectile Cost:"+player.weapon.cost.out+" ("+player.weapon.cost_type+")")
		message.append ("%N      Power:"+power_list[player.power])
		message.append ("%N      score:"+score.out)
		Result:=message
	end

	enemies_out(ships: ARRAY[SHIP]): STRING
	do
		create Result.make_from_string("Enemy:")
		across
			ships is l_ship
		loop
			if l_ship.within_board and not l_ship.is_destroyed then
				check attached {ENEMY} l_ship as ship then
					--Format the enemies status out
					Result.append ("%N    ["+ship.id.out+","+ship.symbol.out+"]->")
					Result.append ("health:"+ship.current_health.out+"/"+ship.max_health.out+", ")
					Result.append ("Regen:"+ship.max_health_regen.out+", ")
					Result.append ("Armour:"+ship.max_armour.out+", Vision:"+ship.max_vision.out+", ")
					Result.append ("seen_by_Starfighter:")
					if ship.seen_by_Starfighter then
						Result.append("T, ")
					else
						Result.append("F, ")
					end
					Result.append ("can_see_Starfighter:")
					if ship.can_see_Starfighter then
						Result.append("T, ")
					else
						Result.append("F, ")
					end
					Result.append ("location:["+col_list[ship.y].out+","+ship.x.out+"]")
				end
			end
		end
	end

	projectiles_out(projectiles: ARRAY[PROJECTILE]): STRING
	do
		create Result.make_from_string("Projectile:")
		across
			projectiles is proj
		loop
			--Format projectile status out
			if not proj.is_destroyed then
				Result.append("%N    ["+proj.id.out+","+proj.symbol+"]->damage:"+proj.damage.out+", move:"+proj.speed.out+", location:["+col_list[proj.y].out+","+proj.x.out+"]")
			end
		end
	end

	fprojectile_action_out(projectiles: ARRAY[PROJECTILE]; max_x, max_y: INTEGER):STRING
	do
		create Result.make_from_string("Friendly Projectile Action:")
		across
			projectiles is proj
		loop
			if proj.moved then
				if not proj.within_board then --Projectile moves outside of board
					if proj.old_y <= max_y and proj.old_x<=max_x and proj.old_y>0 then --projectiles whose old values are still on board
						Result.append("%N    A friendly projectile(id:"+proj.id.out+") moves: ["+col_list[proj.old_y].out+","+proj.old_x.out+"] -> out of board")
					end
				else --projectile moves and stys within board
					if proj.old_y=proj.y and proj.old_x=proj.x then --projectile does not move (splitter)
						Result.append("%N    A friendly projectile(id:"+proj.id.out+") stays at: ["+col_list[proj.old_y].out+","+proj.old_x.out+"]")
					elseif not(proj.old_y=0 and proj.old_x=0) then --proj is not newly spawned
						Result.append("%N    A friendly projectile(id:"+proj.id.out+") moves: ["+col_list[proj.old_y].out+","+proj.old_x.out+"] -> ["+col_list[proj.y].out+","+proj.x.out+"]")
					end
				end
				if not proj.collision_messages.is_empty then
					Result.append(proj.collision_messages)
				end

			end
		end
	end

	eprojectile_action_out(projectiles: ARRAY[PROJECTILE]):STRING
	do
		create Result.make_from_string("Enemy Projectile Action:")
		across
			projectiles is proj
		loop
			if (proj.moved) then
				if not proj.within_board then --Projectile moves outside of board (but is still alive)
					if proj.old_x>=1 then --projectiles whose old values are still on board (just moved off board this turn)
						Result.append("%N    A enemy projectile(id:"+proj.id.out+") moves: ["+col_list[proj.old_y].out+","+proj.old_x.out+"] -> out of board")
						if not proj.collision_messages.is_empty then
							Result.append(proj.collision_messages)
						end
					end
				else --projectile moves and stys within board
					if not(proj.old_y=0 and proj.old_x=0) then --proj is not newly spawned
						Result.append("%N    A enemy projectile(id:"+proj.id.out+") moves: ["+col_list[proj.old_y].out+","+proj.old_x.out+"] -> ["+col_list[proj.y].out+","+proj.x.out+"]")
						if not proj.collision_messages.is_empty then
							Result.append(proj.collision_messages)
						end
					end
				end
			end
		end
	end

	player_action_out(player: PLAYER):STRING
	do
		create Result.make_from_string("Starfighter Action:")
		if player.acted then
			if player.last_action = player.passed then
				Result.append("%N    The Starfighter(id:0) passes at location ["+col_list[player.y].out+","+player.x.out+"], doubling regen rate.")
			elseif player.last_action = player.moved then
				Result.append("%N    The Starfighter(id:0) moves: ["+col_list[player.old_y].out+","+player.old_x.out+"] -> ["+col_list[player.y].out+","+player.x.out+"]")
				if not player.collision_messages.is_empty then
					Result.append(player.collision_messages)
				end
			elseif player.last_action = player.fired then
				Result.append("%N    The Starfighter(id:0) fires at location ["+col_list[player.y].out+","+player.x.out+"].")
				across
					player.last_projectiles is proj
				loop
					if proj.within_board then
						Result.append("%N      A friendly projectile(id:"+proj.id.out+") spawns at location ["+col_list[proj.y].out+","+proj.x.out+"].")
						if not proj.collision_messages.is_empty then
							Result.append(proj.collision_messages)
						end
					elseif not proj.within_board then
						Result.append("%N      A friendly projectile(id:"+proj.id.out+") spawns at location out of board.")
					end
				end
			elseif player.last_action=player.specialed then
				Result.append (player.special_message)
			end
		end
	end

	enemy_action_out(ships:ARRAY[SHIP]): STRING
	local
		player: PLAYER
		i: INTEGER
	do
		create Result.make_from_string("Enemy Action:")
		check attached {PLAYER} ships[1] as l_player then
			player:=l_player
		end

		--Phase 1: Preemptive actions
		from
			i:=2
		until
			i>ships.count
		loop
			if (not ships[i].is_destroyed) or (ships[i].is_destroyed and ships[i].within_board) then
				if ships[i].old_x>0 then --check that its not a new spawn and still within board/just moved off
					if attached {ENEMY} ships[i] as enemy then
						if not enemy.preempt_message.is_empty then
							Result.append (enemy.preempt_message)
							if enemy.only_preempt and not enemy.last_projectiles.is_empty then --append any projectiles fired during preempt action
								across
									enemy.last_projectiles is p
								loop
									Result.append("%N      A enemy projectile"+p.id_out+" spawns at location "+p.coord_out+".")
									if not p.collision_messages.is_empty then
										Result.append(p.collision_messages)
									end
								end
							end
							if attached {CARRIER} enemy as ca then
								if ca.only_preempt and not ca.last_spawns.is_empty then
									across
										ca.last_spawns is ls
									loop
										if not ls.within_board then
											Result.append("%N      A Interceptor"+ls.id_out+" spawns at location out of board.")
										else
											Result.append("%N      A Interceptor"+ls.id_out+" spawns at location "+ls.coord_out+".")
											if not ls.collision_messages.is_empty then
												Result.append(ls.collision_messages)
											end
										end
									end
								end
							end
						end
					end
				end
			end

			i:=i+1
		end

		--Phase 2: Turn actions if preemptive didn't end turn
		from
			i:=2
		until
			i>ships.count
		loop
			if (not ships[i].is_destroyed) or (ships[i].is_destroyed and ships[i].within_board) then
				if ships[i].old_x>0 then --check that its not a new spawn and still on board/just moved off
--					if attached {GRUNT} ships[i] as enemy then --if grunt append grunt specific messages
--						if enemy.within_board then --still on board
--							Result.append("%N    A Grunt"+enemy.id_out+" moves: "+coord_out(enemy.old_x,enemy.old_y)+" -> "+coord_out(enemy.x,enemy.y))
--							if not enemy.collision_messages.is_empty then
--								Result.append(enemy.collision_messages)
--							end
--							if not enemy.last_projectiles.is_empty then
--								Result.append("%N      A enemy projectile"+enemy.last_projectiles[1].id_out+" spawns at location "+coord_out(enemy.last_projectiles[1].x, enemy.last_projectiles[1].y)+".")
--								if not enemy.last_projectiles[1].collision_messages.is_empty then
--									Result.append(enemy.last_projectiles[1].collision_messages)
--								end
--							end
--						else --just moved off board
--							Result.append("%N    A Grunt"+enemy.id_out+" moves: "+coord_out(enemy.old_x,enemy.old_y)+" -> out of board")
--						end
--					end
					if attached {ENEMY} ships[i] as enemy then
						if not enemy.only_preempt then
							Result.append (enemy.turn_message)
							if not enemy.only_preempt and not enemy.last_projectiles.is_empty then
								across
									enemy.last_projectiles is p
								loop
									Result.append("%N      A enemy projectile"+p.id_out+" spawns at location "+p.coord_out+".")
									if not p.collision_messages.is_empty then
										Result.append(p.collision_messages)
									end
								end
							end
							if attached {CARRIER} enemy as ca then
								if not ca.only_preempt and not ca.last_spawns.is_empty then
									across
										ca.last_spawns is ls
									loop
										if not ls.within_board then
											Result.append("%N      A Interceptor"+ls.id_out+" spawns at location out of board.")
										else
											Result.append("%N      A Interceptor"+ls.id_out+" spawns at location "+ls.coord_out+".")
											if not ls.collision_messages.is_empty then
												Result.append(ls.collision_messages)
											end
										end
									end
								end
							end
						end
					end
				end
			end

			i:=i+1
		end
	end

	enemy_spawn_out(ships:ARRAY[SHIP]): STRING
	local
		--enemy: ENEMY
	do
		create Result.make_from_string("Natural Enemy Spawn:")
		if ships.count>1 then
			check attached {ENEMY} ships.at (ships.count) as l_enemy then
				if (l_enemy.old_x=0 and l_enemy.old_y=0 and not l_enemy.carrier_spawn) then
					Result.append ("%N    A "+l_enemy.name+"(id:"+l_enemy.id.out+") spawns at location ["+col_list[l_enemy.y].out+","+l_enemy.x.out+"].")
					if not l_enemy.collision_messages.is_empty then
						Result.append(l_enemy.collision_messages)
					end
				end
			end
		end

	end

	grid_out(player: PLAYER; ht:HASH_TABLE[ENTITY,STRING]; is_debug: BOOLEAN): STRING
	local
		j, k: INTEGER
		xy_pair: PAIR[INTEGER,INTEGER]
	do
		create Result.make_empty
		--append the column numbers
		Result.append ("  ")
		from
			j:=1
		until
			j>num_col
		loop
			if j>9 then
				Result.append(" "+j.out)
			else
				Result.append("  "+j.out)
			end
			j:=j+1
		end

		--append the rows
		from --go down through the rows (y value)
			j:=1
		until
			j>num_row
		loop
			from --go to the right for columns (x value)
				k:=0
			until
				k>num_col
			loop
				if k=0 then
					Result.append("%N    "+COL_LIST.at (j))
				else
					create xy_pair.make(k,j)
					if ((j-player.y).abs + (k-player.x).abs)>player.max_vision and not is_debug then --if out of player vision print ?
							Result.append(" ?")
					elseif ht.has_key (xy_pair.out) then --print the symbol
						if attached ht.at (xy_pair.out) as entity then
							if not entity.is_destroyed then --only print if its not destroyed
								Result.append(" "+entity.symbol.out)
							end
						end
					else
						Result.append(" _")
					end
				end
				if k>0 and k<num_col then
					Result.append(" ")
				end
				k:=k+1
			end
			j:=j+1
		end
	end

	status_out(game_state: STRING; turns, errors: INTEGER; debug_mode, turn_ok, toggled_debug: BOOLEAN): STRING
	local
		message: STRING
	do
		create message.make_from_string ("  state:")
		message.append (game_state)
		if game_state ~ "in game" then
			message.append ("("+turns.out+"."+errors.out+")")
		end
		message.append(", ")
		if debug_mode then
			message.append ("debug, ")
		else
			message.append ("normal, ")
		end
		if turn_ok or (toggled_debug and not turn_ok) then
			message.append ("ok")
		else
			message.append ("error")
		end

		Result:=message
	end

	coord_out(x, y: INTEGER): STRING
	do
		create Result.make_from_string("["+col_list[y].out+","+x.out+"]")
	end

end


note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	GAME_ENGINE

inherit
	ANY
		redefine
			out
		end

create {GAME_ENGINE_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
--			create s.make_empty
--			i := 0

			game_states:=<<"not started","weapon setup","armour setup","engine setup","power setup","setup summary","in game","not started">>
			create m.make(game_states)

			create abstract_out.make_empty
			update_abstract_out(m.init.out)
			turns:=0
			errors:=0
			turn_ok:=true
			debug_mode:=false
			current_state:=1
			module_selection:=<<1,1,1,1>>
			create thresholds.make_empty

			projectile_IDs:=-1
			enemy_IDs:=1
			create player.make (module_selection, 0, 0)

			create ships.make_empty
			create friendly_projs.make(0)
			create enemy_projs.make(0)
		end

feature{ETF_COMMAND} -- model attributes
	abstract_out: STRING
	turns: INTEGER
	errors: INTEGER
	current_state: INTEGER --to track the game state
	debug_mode: BOOLEAN
	toggled_debug: BOOLEAN
	turn_ok: BOOLEAN

	num_row: INTEGER
	num_col: INTEGER

	projectile_IDs: INTEGER --the next available ID
	enemy_IDs: INTEGER

	m: MESSAGES --messages object

	random : RANDOM_GENERATOR_ACCESS

	--pass a hashmap of coord -> symbol to message when outputting grid
	ships: ARRAY[SHIP]
	friendly_projs: ARRAYED_LIST[PROJECTILE]
	enemy_projs: ARRAYED_LIST[PROJECTILE]
	thresholds: ARRAY[INTEGER] --to hold the thresholds for enemy spawn
	score: INTEGER

	--to hold ship module decisions
	module_selection: ARRAY[INTEGER]

feature{ETF_COMMAND} --game constants

	--game states
	NOT_STARTED: INTEGER=1
	WEAPON_SETUP: INTEGER=2
	ARMOUR_SETUP: INTEGER=3
	ENGINE_SETUP: INTEGER=4
	POWER_SETUP: INTEGER=5
	SETUP_SUMMARY: INTEGER=6
	IN_GAME: INTEGER=7
	GAME_OVER: INTEGER=8
	game_states: ARRAY[STRING]

feature --player
	player: PLAYER

feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			--i := i + 1
		end

	reset
			-- Reset model state.
		do
			make
		end

	play(rows, cols, g_threshold, f_threshold, c_threshold, i_threshold, p_threshold: INTEGER) --enter into the setup state
	do
		current_state:=WEAPON_SETUP
		num_row:=rows
		num_col:=cols
		m.set_grid_size(num_row, num_col)
		thresholds:=<<g_threshold, f_threshold, c_threshold, i_threshold, p_threshold>>
		command_ok
	end

	setup_next(value: INTEGER)
	do
		current_state:=current_state+value
		if current_state > IN_GAME then
			current_state:=IN_GAME
		end
		command_ok
		if current_state=IN_GAME then --if in game create player and reset the variables
			turns:=0
			errors:=0

			--reset the variables
			projectile_IDs:=-1
			enemy_IDs:=1
			ships.make_empty
			friendly_projs.make(0)
			enemy_projs.make(0)

			create player.make(module_selection, 1, ((num_row+1)/2).truncated_to_integer)
			--player.tp_to (((num_row+1)/2).truncated_to_integer, 1)
			ships.force (player, ships.count+1)
		end
	end

	setup_back(value:INTEGER)
	do
		current_state:=current_state-value
		if current_state<NOT_STARTED then
			current_state:=NOT_STARTED
		end
		if current_state = NOT_STARTED then --use welcome to space invaders message
			update_abstract_out(m.init)
		end
		command_ok
	end

	setup_select(value:INTEGER)
	do
		module_selection.at (current_state-1):=value
		command_ok
	end

	abort
	do
		update_abstract_out(m.abort_exited (current_state))
		current_state:=NOT_STARTED
		command_ok
	end

	move(row, col: INTEGER)
	do

		pre_action(false)
		if player.current_health>0 then
			player.go_to (row, col, create_ht(player))
			player.did_act
		end
		if player.current_health <= 0 then
			current_state:=GAME_OVER
		end
		command_ok
		post_action
	end

	pass
	do
		pre_action(true)
		if player.current_health>0 then
			player.did_act
		end
		command_ok
		post_action
	end

	fire
	local
		new_projs: ARRAY[PROJECTILE]
	do
		pre_action(false)
		if player.current_health>0 then
			new_projs:=player.fire(create_ht(void))
			player.did_act
			--add the projectiles to the list of friendly projectiles
			across
				new_projs is proj
			loop
				proj.assign_id(projectile_ids)
				projectile_ids:=projectile_ids-1
				if proj.get_coord.first > num_col or proj.get_coord.second > num_row or proj.get_coord.first<1 or proj.get_coord.second<1 then
					proj.out_of_board --set proj status to out of board (in case of rocket firing in col. 1)
				end
				friendly_projs.force (proj)
			end
		end
		command_ok
		post_action
	end

	use_special
	do
		pre_action(false)
		if player.current_health>0 then
			player.use_special (create_ht(player),create_proj_array(friendly_projs, enemy_projs),ships)
			player.did_act
		end
		command_ok
		post_action
	end

	toggle_debug
	do
		toggled_debug:=true
		if debug_mode then
			debug_mode:=false
		else
			debug_mode:=true
		end
	end

feature --turn advancement functions
	pre_action(is_pass: BOOLEAN) --actions to take before executing starfighter command
	local
		destroyed_enemies: ARRAY[ENEMY]
		score_added: BOOLEAN
		i: INTEGER
	do
		--After successfully invoking a command:
		--1. Move friendly projectiles
		from
			i:=1
		until
			i>friendly_projs.count
		loop
			if player.current_health>0 then
				create destroyed_enemies.make_empty
				destroyed_enemies:=friendly_projs[i].advance_proj(create_ht(friendly_projs[i]))
				if friendly_projs[i].get_coord.first > num_col or friendly_projs[i].get_coord.second > num_row or friendly_projs[i].get_coord.first<1 or friendly_projs[i].get_coord.second<1 then
					friendly_projs[i].out_of_board
				end
				if not destroyed_enemies.is_empty then --check the list of destroyed enemies and add their score
					across
						destroyed_enemies is de
					loop
						score_added:=player.score.add_score (de.score)
					end
				end
			end
			if player.current_health<=0 then
				current_state:=GAME_OVER
			end
			i:=i+1
		end

		--2. Move enemy projectiles
		create destroyed_enemies.make_empty
		across
			enemy_projs is eproj
		loop
			if player.current_health>0 then
				destroyed_enemies:=eproj.advance_proj(create_ht(eproj))
				if eproj.get_coord.first > num_col or eproj.get_coord.second > num_row or eproj.get_coord.first<1 or eproj.get_coord.second<1 then
					eproj.out_of_board
				end
			end
			if player.current_health<=0 then
				current_state:=GAME_OVER
			end

		end
		--3. Apply starfighter regeneration (twice if pass)
		if player.current_health>0 then
			player.regenerate
			if is_pass then
				player.regenerate
			end
		end

		--4. Execute the starfighter command (in each player action method)
		player.did_not_act
	end

	post_action --actions after executing starfighter command
	local
		new_entities: ARRAY[ENTITY]
		i,j: INTEGER
		score_added: BOOLEAN
		list_end: INTEGER
	do
		--determine number of ships that need to act (exclude any interceptors that might spawn)
		list_end:=ships.count

		--5. Update enemy vision
		if player.current_health>0 then
			from
				i:=2
			until
				i>list_end
			loop
				check attached {ENEMY} ships[i] as enemy then
					enemy.update_sight (player)
					if enemy.is_destroyed then--also update on board status
						enemy.out_of_board
					end
				end
				i:=i+1
			end
		end

		--6. Preempt enemy actions from oldest to newest
		from
			--i:=2
			i:=2
		until
			i>list_end
		loop
			if player.current_health>0 then
				check attached {ENEMY} ships[i] as enemy then --cast to an enemy
					create new_entities.make_empty
					if not enemy.is_destroyed then --if not enemy.is_destroyed then
						new_entities:=enemy.preempt_action (player,create_ht(void)) --do preempt action and save array of new enemies or projectiles
						if enemy.is_destroyed then --if the action causes enemy to be destroyed
							score_added:=player.score.add_score (enemy.score)
						end
					end
					if enemy.x > num_col or enemy.y > num_row or enemy.x<1 or enemy.y<1 then --check if enemy is still within board
						enemy.out_of_board
					end
					if not new_entities.is_empty then
						from
							j:=1
						until
							j>new_entities.count --add the new entities to the appropriate list
						loop
							if attached {PROJECTILE} new_entities[j] as proj then
								proj.assign_id(projectile_ids) --give the projectile an id and add it to the list
								projectile_ids:=projectile_ids-1
								if proj.get_coord.first > num_col or proj.get_coord.second > num_row or proj.get_coord.first<1 or proj.get_coord.second<1 then
									proj.out_of_board --set proj status to out of board
								end
								enemy_projs.force (proj)
							elseif attached {ENEMY} new_entities[j] as new_enemy then
								new_enemy.assign_id(enemy_ids) --give new enemy an id and add it to the list
								enemy_ids:=enemy_ids+1
								if new_enemy.get_coord.first > num_col or new_enemy.get_coord.second > num_row or new_enemy.get_coord.first<1 or new_enemy.get_coord.second<1 then
									new_enemy.out_of_board
								end
								ships.force (new_enemy, ships.count+1)
								new_enemy.update_sight (player)
								if new_enemy.is_destroyed then
									score_added:=player.score.add_score (new_enemy.score)
								end
							end
							j:=j+1
						end
					end
				end
			else
				check attached {ENEMY} ships[i] as enemy then
					enemy.skip_preempt
				end
			end
			i:=i+1
		end


		--7. Execute enemy actions
		from
			i:=2
		until
			i>list_end
		loop
			if player.current_health>0 then
				check attached {ENEMY} ships[i] as enemy then --cast to an enemy
					create new_entities.make_empty
					if not enemy.is_destroyed then --if not enemy.is_destroyed then
						new_entities:=enemy.turn_action(create_ht(void)) --do action and save array of new enemies or projectiles
						if enemy.is_destroyed then --if the action causes enemy to be destroyed
							score_added:=player.score.add_score (enemy.score)
						end
					end
					if enemy.x > num_col or enemy.y > num_row or enemy.x<1 or enemy.y<1 then --check if enemy is still within board
						enemy.out_of_board
					end
					if not new_entities.is_empty then
						from
							j:=1
						until
							j>new_entities.count
						loop
							if attached {PROJECTILE} new_entities[j] as proj then
								proj.assign_id(projectile_ids) --give the projectile an id and add it to the list
								projectile_ids:=projectile_ids-1
								if proj.get_coord.first > num_col or proj.get_coord.second > num_row or proj.get_coord.first<1 or proj.get_coord.second<1 then
									proj.out_of_board --set proj status to out of board
								end
								enemy_projs.force (proj)
							elseif attached {ENEMY} new_entities[j] as new_enemy then
								new_enemy.assign_id(enemy_ids) --give new enemy an id and add it to the list
								enemy_ids:=enemy_ids+1
								if new_enemy.get_coord.first > num_col or new_enemy.get_coord.second > num_row or new_enemy.get_coord.first<1 or new_enemy.get_coord.second<1 then
									new_enemy.out_of_board
								end
								ships.force (new_enemy, ships.count+1)
								new_enemy.update_sight (player)
								if new_enemy.is_destroyed then
									score_added:=player.score.add_score (new_enemy.score)
								end
							end
							j:=j+1
						end
					end
				end
			else
				check attached {ENEMY} ships[i] as enemy then
					enemy.skip_turn
				end
			end
			i:=i+1
		end

			--8. Update enemy vision
		if player.current_health>0 then
			from
			i:=2
			until
				i>ships.count
			loop
				check attached {ENEMY} ships[i] as enemy then
					enemy.update_sight (player)
				end
				i:=i+1
			end
			--9. Spawn new enemy if able to
			spawn_enemy
		end

		if player.current_health<=0 then
			current_state:=GAME_OVER
		end
	end

	spawn_enemy
	local
		spawn_row:INTEGER
		rthreshold: INTEGER --the random threshold value to determine enemy to spawn
		new_enemy: ENEMY
		ht: HASH_TABLE[ENTITY,STRING]
		xy_pair: PAIR[INTEGER,INTEGER]
		score_added: BOOLEAN
	do
		spawn_row:=random.rchoose(1,num_row)
		rthreshold:=random.rchoose (1, 100)

		ht:=create_ht(void)
		create xy_pair.make(num_col,spawn_row)

		if (not attached {ENEMY} ht.at (xy_pair.out)) then --if the spot is not occupied by an enemy
			if rthreshold>=1 and rthreshold<thresholds[1] then
				create {GRUNT} new_enemy.make (num_col, spawn_row)
			elseif rthreshold>=thresholds[1] and rthreshold<thresholds[2] then
				create {FIGHTER} new_enemy.make (num_col, spawn_row)
			elseif rthreshold>=thresholds[2] and rthreshold<thresholds[3] then
				create {CARRIER} new_enemy.make (num_col, spawn_row)
			elseif rthreshold>=thresholds[3] and rthreshold<thresholds[4] then
				create {INTERCEPTOR} new_enemy.make(num_col, spawn_row)
			elseif rthreshold>=thresholds[4] and rthreshold<thresholds[5] then
				create {PYLON} new_enemy.make (num_col, spawn_row)
			end

			if attached new_enemy then --update the necessary fields
				new_enemy.assign_id(enemy_ids)
				enemy_ids:=enemy_ids+1
				new_enemy.update_sight (player)
				ships.force (new_enemy, ships.count+1)

				if attached ht.at (xy_pair.out) as entity then --do collision if necessary
					new_enemy.do_collision (entity)
					if new_enemy.is_destroyed then
						score_added:=player.score.add_score (new_enemy.score)
					end
				end
			end
		end
	end

feature --auxillary functions
	command_ok
	do
		toggled_debug:=false -- in case previous command was to toggle debug mode
		turn_ok:=true
		if current_state=IN_GAME then
			errors:=0
			turns:=turns+1
		end
	end

	command_error
	do
		turn_ok := false
		if current_state = IN_GAME then
			errors:=errors+1
		end
		toggled_debug:=false --in case previous command was to toggle debug
	end

	update_abstract_out(mes: STRING)
	do
		abstract_out:=mes.out
	end

	create_ht(current_entity: detachable ENTITY): HASH_TABLE[ENTITY,STRING]
	--return a hashtable of all entites on the map. Do not include current_entity in list if attached
	local
		ht: HASH_TABLE[ENTITY,STRING]
	do
		create ht.make (1)
		across
			friendly_projs is fproj
		loop
			if attached current_entity as ce then
				if not (ce ~ fproj) then --if current_entity is specififed do not include it
					if fproj.get_coord.first <= num_col and fproj.get_coord.second <= num_row and fproj.get_coord.first>0 and fproj.get_coord.second>0 and fproj.within_board and not fproj.is_destroyed then
						ht.extend (fproj,fproj.get_coord.out)
					end
				end
			else
				if fproj.get_coord.first <= num_col and fproj.get_coord.second <= num_row and fproj.get_coord.first>0 and fproj.get_coord.second>0 and fproj.within_board and not fproj.is_destroyed then
					ht.extend (fproj,fproj.get_coord.out)
				end
			end

		end
		--add enemy projectiles
		across
			enemy_projs is eproj
		loop
			if attached current_entity as ce then
				if not (ce~eproj) then
					if eproj.get_coord.first <= num_col and eproj.get_coord.second <= num_row and eproj.get_coord.first>0 and eproj.get_coord.second>0 and eproj.within_board and not eproj.is_destroyed then
						ht.extend (eproj,eproj.get_coord.out)
					end
				end
			else
				if eproj.get_coord.first <= num_col and eproj.get_coord.second <= num_row and eproj.get_coord.first>0 and eproj.get_coord.second>0 and eproj.within_board and not eproj.is_destroyed then
					ht.extend (eproj,eproj.get_coord.out)
				end
			end
		end
		--add enemy ships
		across
			ships is ship
		loop
			if attached current_entity as ce then
				if not (ce~ship) then
					if ship.get_coord.first <= num_col and ship.get_coord.second <= num_row and ship.get_coord.first>0 and ship.get_coord.second>0 and ship.within_board and not ship.is_destroyed then
						ht.extend (ship,ship.get_coord.out)
					end
				end
			else
				if ship.get_coord.first <= num_col and ship.get_coord.second <= num_row and ship.get_coord.first>0 and ship.get_coord.second>0 and ship.within_board and not ship.is_destroyed then
					ht.extend (ship,ship.get_coord.out)
				end
			end
		end

		Result:=ht
	end

	create_proj_array(fprojectiles, eprojectiles:ARRAYED_LIST[PROJECTILE]): ARRAY[PROJECTILE]
	local
		fcursor, ecursor: INTEGER
		combined_array: ARRAY[PROJECTILE]
	do
		fcursor:=1
		ecursor:=1
		create combined_array.make_empty
		from
			fcursor:=1
		until
			fcursor>fprojectiles.count and ecursor>eprojectiles.count
		loop
			if fprojectiles.is_empty or fcursor>fprojectiles.count then --if fprojectiles is empty or counter is at the end only look at eprojectiles
				if eprojectiles[ecursor].within_board then
					combined_array.force (eprojectiles[ecursor], combined_array.count+1)
				end
				ecursor:=ecursor+1
			elseif eprojectiles.is_empty or ecursor>eprojectiles.count then --if eprojectiles is empty/counter at the end
				if fprojectiles[fcursor].within_board then
					combined_array.force (fprojectiles[fcursor], combined_array.count+1)
				end
				fcursor:=fcursor+1
			else
				if fprojectiles[fcursor].id>eprojectiles[ecursor].id then --current fprojectile has larger (less negative) id
					if fprojectiles[fcursor].within_board then
						combined_array.force (fprojectiles[fcursor], combined_array.count+1)
					end
					fcursor:=fcursor+1
				elseif fprojectiles[fcursor].id<eprojectiles[ecursor].id then --eprojectile is larger
					if eprojectiles[ecursor].within_board then
						combined_array.force (eprojectiles[ecursor], combined_array.count+1)
					end
					ecursor:=ecursor+1
				end
			end
		end
		Result:=combined_array
	end

feature -- queries
	out : STRING
		do
			create Result.make_empty
			Result.append(m.status_out (game_states.at (current_state), turns, errors, debug_mode, turn_ok, toggled_debug))
			if turn_ok = false then
				Result.append ("%N  "+abstract_out)
			else
				if current_state = NOT_STARTED then
					Result.append("%N  "+abstract_out)
				elseif current_state = IN_GAME or current_state=GAME_OVER then
				--in game abstract state
					Result.append ("%N  "+m.player_out (player, player.score.get_score))
					if debug_mode then
						Result.append("%N  "+m.enemies_out (ships.subarray (2, ships.count)))
						Result.append("%N  "+m.projectiles_out (create_proj_array(friendly_projs, enemy_projs)))
						Result.append("%N  "+m.fprojectile_action_out (friendly_projs.to_array, num_col, num_row))
						Result.append("%N  "+m.eprojectile_action_out (enemy_projs.to_array))
						Result.append ("%N  "+m.player_action_out (player))
						Result.append ("%N  "+m.enemy_action_out(ships))
						Result.append ("%N  "+m.enemy_spawn_out(ships))
					end
					Result.append ("%N  "+m.grid_out (player, create_ht(void), debug_mode))
					if current_state=GAME_OVER then
						Result.append("%N  "+m.game_over)
					end
				else
					Result.append (m.play_out (current_state, module_selection))
				end
			end
		end

invariant
	valid_proj_id:projectile_IDs<0
	valid_enemy_id:enemy_IDs>0
end

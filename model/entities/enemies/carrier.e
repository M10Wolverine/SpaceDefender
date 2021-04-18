note
	description: "Summary description for {CARRIER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CARRIER

inherit
	ENEMY

create
	make

feature
	last_spawns: ARRAY[INTERCEPTOR]

feature {NONE} -- Initialization

	make(col,row:INTEGER)
			-- Initialization for `Current'.
		do
			symbol:=carrier.out
			name:="Carrier"
			max_health:=200
			max_vision:=15
			max_armour:=15
			max_health_regen:=10
			current_health:=max_health
			create last_projectiles.make_empty
			create last_spawns.make_empty
			x:=col
			y:=row
			old_x:=0
			old_y:=0
			seen_by_Starfighter:=false
			can_see_Starfighter:=false
			within_board:=true
			create collision_messages.make_empty
			create turn_message.make_empty
			create preempt_message.make_empty
			create {FOCUS} score.make (diamond)
			max_moves:=2 --set the default as starfighter not seen values
			weapon_damage:=0
			proj_speed:=0
		end

feature
	turn_action(ht: HASH_TABLE[ENTITY,STRING]): ARRAY[ENEMY]
	local
		temp_coord: PAIR[INTEGER,INTEGER]
		i1: INTERCEPTOR
	do
		turn_message.make_empty
		create Result.make_empty
		if not only_preempt then
			last_spawns.make_empty
			regenerate
			go_to(ht, void)
			if within_board then
				if old_x = x and old_y = y then
					turn_message:="%N    A "+name.out+id_out+" stays at: "+coord_out
				else
					turn_message:="%N    A "+name.out+id_out+" moves: "+old_coord_out+" -> "+coord_out
				end
			else
				turn_message:="%N    A "+name.out+id_out+" moves: "+old_coord_out+" -> out of board"
			end
			if not collision_messages.is_empty then
				turn_message.append(collision_messages)
			end
			if within_board and can_see_starfighter and not is_destroyed then
				--spawn interceptor to the left
				create temp_coord.make (x-1, y)
				if attached ht.at (temp_coord.out) as e then
					if not attached {ENEMY} e then--if the spot above carrier is occupied by non enemy
						create i1.make (x-1, y)
						i1.carrier_spawned
						last_spawns.force (i1, last_spawns.count+1)
						i1.do_collision (e)
					end
				else
					create i1.make (x-1, y)
					i1.carrier_spawned
					last_spawns.force (i1, last_spawns.count+1)
				end
				Result:=last_spawns
			end
--			Result:=fire(ht)
		end
	end

	preempt_action(player: PLAYER; ht: HASH_TABLE[ENTITY,STRING]):ARRAY[ENEMY]
	local
		i1, i2: INTERCEPTOR
		temp_coord: PAIR[INTEGER,INTEGER]
	do
		last_spawns.make_empty
		create Result.make_empty
		preempt_message.make_empty
		only_preempt:=false
		if player.last_action=player.passed then
			regenerate
			create temp_coord.make (x-2, y)
			go_to(ht, temp_coord)
			if within_board then
				if old_x = x and old_y = y then
					preempt_message:="%N    A "+name.out+id_out+" stays at: "+coord_out

				else
					preempt_message:="%N    A "+name.out+id_out+" moves: "+old_coord_out+" -> "+coord_out
				end
				--Do interceptor spawning
				if not is_destroyed then
					create temp_coord.make (x, y-1)
					if attached ht.at (temp_coord.out) as e then
						if not attached {ENEMY} e then--if the spot above carrier is occupied by non enemy
							create i1.make (x, y-1)
							i1.carrier_spawned
							last_spawns.force (i1, last_spawns.count+1)
							i1.do_collision (e)
						end
					else
						create i1.make (x, y-1)
						i1.carrier_spawned
						last_spawns.force (i1, last_spawns.count+1)
					end


					temp_coord.make (x, y+1)
					if attached ht.at (temp_coord.out) as e then
						if not attached {ENEMY} e then
							create i2.make (x, y+1)
							i2.carrier_spawned
							last_spawns.force (i2, last_spawns.count+1)
							i2.do_collision (e)
						end
					else
						create i2.make (x, y+1)
						i2.carrier_spawned
						last_spawns.force (i2, last_spawns.count+1)
					end
					Result:=last_spawns
				end
			else
				preempt_message:="%N    A "+name.out+id_out+" moves: "+old_coord_out+" -> out of board"
			end
			if not collision_messages.is_empty then
				preempt_message.append(collision_messages)
			end
			only_preempt:=true
		elseif player.last_action=player.specialed then
			max_health_regen:=max_health_regen+10
			preempt_message:="%N    A "+name.out+id_out+" gains 10 regen."
		end
	end

	update_sight(player: PLAYER) --check and update the seen fields
	do
		if ((y-player.y).abs + (x-player.x).abs)<=player.max_vision then
			seen_by_Starfighter:=true
		else
			seen_by_Starfighter:=false
		end
		if ((y-player.y).abs + (x-player.x).abs)<=max_vision then
			can_see_Starfighter:=true
		else
			can_see_Starfighter:=false
		end

		--also update the movement fields
		if can_see_starfighter then
			max_moves:=1
		else
			max_moves:=2
		end
	end


end

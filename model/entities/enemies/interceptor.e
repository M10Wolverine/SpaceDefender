note
	description: "Summary description for {INTERCEPTOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	INTERCEPTOR

inherit
	ENEMY

create
	make

feature {NONE} -- Initialization

	make(col,row:INTEGER)
			-- Initialization for `Current'.
		do
			symbol:=intercept.out
			name:="Interceptor"
			max_health:=50
			max_vision:=5
			max_armour:=0
			max_health_regen:=0
			current_health:=max_health
			create last_projectiles.make_empty
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
			create {ORB} score.make (bronze)
			max_moves:=3
			weapon_damage:=0
			proj_speed:=0
		end

feature
	turn_action(ht: HASH_TABLE[ENTITY,STRING]): ARRAY[PROJECTILE]
	do
		create Result.make_empty
		turn_message.make_empty
		if not only_preempt and within_board then
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
		end
	end

	preempt_action(player: PLAYER; ht: HASH_TABLE[ENTITY,STRING]):ARRAY[PROJECTILE]
	local
		new_coord: PAIR[INTEGER,INTEGER]
	do
		create Result.make_empty --Return any empty array for interceptor
		create preempt_message.make_empty
		only_preempt:=false
		if player.last_action=player.fired and within_board then
			create new_coord.make (x, player.y)
			go_to(ht,new_coord)
			if within_board then
				if old_x = x and old_y = y then
					preempt_message:="%N    A "+name.out+id_out+" stays at: "+coord_out
				else
					preempt_message:="%N    A "+name.out+id_out+" moves: "+old_coord_out+" -> "+coord_out
				end
			else
				preempt_message:="%N    A "+name.out+id_out+" moves: "+old_coord_out+" -> out of board"
			end
			if not collision_messages.is_empty then
				preempt_message.append(collision_messages)
			end
			only_preempt:=true
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
	end

	carrier_spawned
	do
		carrier_spawn:=true
	end

end

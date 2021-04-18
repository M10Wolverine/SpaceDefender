note
	description: "Summary description for {FIGHTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FIGHTER

inherit
	ENEMY

create
	make

feature {NONE} -- Initialization

	make(col,row:INTEGER)
			-- Initialization for `Current'.
		do
			symbol:=fighter.out
			name:="Fighter"
			max_health:=150
			max_vision:=10
			max_armour:=10
			max_health_regen:=5
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
			create {ORB} score.make (gold)
			max_moves:=3 --set the default as starfighter not seen values
			weapon_damage:=20
			proj_speed:=3
		end

feature
	turn_action(ht: HASH_TABLE[ENTITY,STRING]): ARRAY[PROJECTILE]
	do
		create Result.make_empty
		turn_message.make_empty
		if not only_preempt then
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
			Result:=fire(ht)
		end

	end

	preempt_action(player: PLAYER; ht: HASH_TABLE[ENTITY,STRING]):ARRAY[PROJECTILE]
	do
		create Result.make_empty
		preempt_message.make_empty
		only_preempt:=false
		if player.last_action=player.passed then
			regenerate
			max_moves:=6
			go_to(ht, void)
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
			proj_speed:=10
			weapon_damage:=100
			Result:=fire(ht)
			only_preempt:=true
		elseif player.last_action=player.fired then
			max_armour:=max_armour+1
			preempt_message:="%N    A "+name.out+id_out+" gains 1 armour."
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
			weapon_damage:=50
			proj_speed:=6
		else
			max_moves:=3
			weapon_damage:=20
			proj_speed:=3
		end
	end


end

note
	description: "Summary description for {GRUNT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GRUNT

inherit
	ENEMY

create
	make

feature {NONE} -- Initialization

	make(col,row:INTEGER)
			-- Initialization for `Current'.
		do
			symbol:=grunt.out
			name:="Grunt"
			max_health:=100
			max_vision:=5
			max_armour:=1
			max_health_regen:=1
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
			create {ORB} score.make (silver)
			max_moves:=2
			weapon_damage:=15
			proj_speed:=4
		end

feature
	turn_action(ht: HASH_TABLE[ENTITY,STRING]): ARRAY[PROJECTILE]
	do
		create Result.make_empty
		create turn_message.make_empty
		regenerate
		go_to(ht, void)
		if within_board then
			if old_x = x and old_y = y then
				turn_message:="%N    A "+name.out+id_out+" stays at: "+coord_out
			else
				turn_message:="%N    A Grunt"+id_out+" moves: "+old_coord_out+" -> "+coord_out
			end
		else
			turn_message:="%N    A Grunt"+id_out+" moves: "+old_coord_out+" -> out of board"
		end
		Result:=fire(ht)
		if not collision_messages.is_empty then
			turn_message.append(collision_messages)
		end
	end

	preempt_action(player: PLAYER; ht: HASH_TABLE[ENTITY,STRING]):ARRAY[PROJECTILE]
	do
		create Result.make_empty --Return any empty array for grunt
		create preempt_message.make_empty
		if player.last_action=player.passed then
			max_health:=max_health+10
			current_health:=current_health+10
			preempt_message:="%N    A Grunt"+id_out+" gains 10 total health."
		elseif player.last_action=player.specialed then
			max_health:=max_health+20
			current_health:=current_health+20
			preempt_message:="%N    A Grunt"+id_out+" gains 20 total health."
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
			max_moves:=4
		else
			max_moves:=2
		end
	end

end

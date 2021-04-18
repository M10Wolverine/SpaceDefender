note
	description: "Summary description for {PYLON}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PYLON

inherit
	ENEMY

create
	make

feature {NONE} -- Initialization

	make(col,row:INTEGER)
			-- Initialization for `Current'.
		do
			symbol:=pylon.out
			name:="Pylon"
			max_health:=300
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
			create {FOCUS} score.make (platinum)
			max_moves:=2 --set the default as starfighter not seen values
			weapon_damage:=70
			proj_speed:=2
		end
feature
	turn_action(ht: HASH_TABLE[ENTITY,STRING]): ARRAY[PROJECTILE]
	do
		create Result.make_empty
		turn_message.make_empty
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
		if can_see_starfighter then
			Result:=fire(ht)
		else
			if within_board and not is_destroyed then
				across
					ht is entity
				loop
					if attached {ENEMY} entity as enemy then
						if ((enemy.x-x).abs + (enemy.y-y).abs)<=max_vision then
							enemy.set_health(enemy.current_health+10)
							if enemy.current_health>enemy.max_health then
								enemy.set_health(enemy.max_health)
							end
							turn_message.append ("%N      The Pylon heals "+enemy.name.out+enemy.id_out+" at location "+enemy.coord_out+" for 10 damage.")
						end
					end
				end
			end
		end


	end

	preempt_action(player: PLAYER; ht: HASH_TABLE[ENTITY,STRING]):ARRAY[PROJECTILE]
	do
		create Result.make_empty
		--Pylon has no preempt action
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

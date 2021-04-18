note
	description: "Summary description for {ENEMY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENEMY

inherit
	SHIP

feature --common attributes
	seen_by_Starfighter: BOOLEAN
	can_see_Starfighter: BOOLEAN
	carrier_spawn: BOOLEAN
	weapon_damage:INTEGER
	proj_speed:INTEGER
	only_preempt: BOOLEAN --flag set to true if only the prempt action occured

	preempt_message: STRING
	turn_message:STRING

feature --accessible common methods
	update_sight(player: PLAYER) --check and update the seen fields
	deferred
	end

	turn_action(ht: HASH_TABLE[ENTITY,STRING]):ARRAY[ENTITY] --enemy turn may either spawn a projetile or a ship (interceptor)
	deferred
	end

	preempt_action(player: PLAYER; ht: HASH_TABLE[ENTITY,STRING]):ARRAY[ENTITY]
	deferred
	end

	do_collision(other: ENTITY)
	local
		damage_after_armour: INTEGER
		message: STRING
	do
		--create Result.make_empty
		create message.make_empty
		if attached {PROJECTILE} other as proj then
			if proj.symbol~ proj.friend_proj then--collision with friendly proj
				proj.destroy --TODO: Check for the 3 cases
				damage_after_armour:=proj.damage-max_armour
				if damage_after_armour<0 then
					damage_after_armour:=0
				end
				if damage_after_armour >0 then
					current_health:=current_health-damage_after_armour
				end
				message:="%N      The "+name.out+" collides with friendly projectile"+proj.id_out+" at location "+proj.coord_out+", taking "+damage_after_armour.out+" damage."
				if current_health<1 then
					destroy
					x:=proj.x
					y:=proj.y
					message.append("%N      The "+name.out+" at location "+proj.coord_out+" has been destroyed.")
				end
			elseif proj.symbol~enemy_proj then --collision with enemy proj
				current_health:=current_health+proj.damage
				if current_health>max_health then
					current_health:=max_health
				end
				message:="%N      The "+name.out+" collides with enemy projectile"+proj.id_out+" at location "+proj.coord_out+", healing "+proj.damage.out+" damage."
				proj.destroy
			end
		elseif attached {PLAYER} other as player then --collision with player
			player.set_health (player.current_health-current_health)
			destroy
			x:=player.x
			y:=player.y
			message:="%N      The "+name.out+" collides with Starfighter(id:0) at location "+player.coord_out+", trading "+current_health.out+" damage."
			current_health:=0
			message.append("%N      The "+name.out+" at location "+player.coord_out+" has been destroyed.")
			if player.current_health<1 then
				--player.set_health (0)
				player.destroy
				message.append("%N      The Starfighter at location "+player.coord_out+" has been destroyed.")
			end
		end
		collision_messages.append(message)
	end

	skip_turn --if the player died call this method instead to reset all the fields and skip the turn
	do
		if not only_preempt then --if the preempt action ended the turn do not clear these fields
			last_projectiles.make_empty
			collision_messages.make_empty
		end
		create turn_message.make_empty
		old_y:=y
		old_y:=x
	end

	skip_preempt
	do
		last_projectiles.make_empty
		collision_messages.make_empty
		preempt_message.make_empty
		old_y:=y
		old_y:=x
	end

feature{NONE} --hidden common methods
	regenerate
	do
		current_health:=current_health+max_health_regen
		if current_health>max_health then
			current_health:=max_health
		end
	end

	fire(ht: HASH_TABLE[ENTITY,STRING]):ARRAY[PROJECTILE]
	local
		projectile: NORM_PROJ
	do
		create last_projectiles.make_empty
		if within_board and current_health>0 and not is_destroyed then
			create projectile.make (x-1, y, proj_speed, weapon_damage, false)
			last_projectiles.force(projectile, 1)
			if attached ht.at (projectile.get_coord.out) as ent then
				projectile.do_collision (ent)
			end
		end
		Result:=last_projectiles
	end


	go_to(ht: HASH_TABLE[ENTITY,STRING]; new_coord: detachable PAIR[INTEGER,INTEGER])
	--travel to the specified new_coord, or travel left by max_moves if detached
	local
		collides_with: LIST[ENTITY]
		i: INTEGER
	do
		old_x:=x
		old_y:=y
		if attached new_coord  then
			x:=new_coord.first
			y:=new_coord.second
		else
			x:=x-max_moves
		end

		collides_with:=check_collision(ht)
		create collision_messages.make_empty
		from
			i:=1
		until
			i>collides_with.count
		loop
			if current_health>0 and not is_destroyed then
				if attached {ENEMY} collides_with[i] as e then --if collision is another enemy stop moving
					if old_y=y then --a horizontal movement
						x:=e.x+1
					elseif old_x=x then --verticle movemment(only interceptor)
						if old_y<y then --moved down
							y:=e.y-1
						else --otherwise moved up
							y:=e.y+1
						end
					end
					i:=collides_with.count+1 --stop checking any other entities
				else
					do_collision(collides_with[i])
				end
			end
			i:=i+1
		end

		if x<1 then --check if enemy is still within board
			out_of_board
		end
	end

end

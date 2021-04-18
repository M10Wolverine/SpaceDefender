note
	description: "Summary description for {PROJECTILE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PROJECTILE

inherit
	ENTITY

feature
	speed: INTEGER
	damage: INTEGER
	moved: BOOLEAN

feature
	advance_proj(ht: HASH_TABLE[ENTITY,STRING]):ARRAY[ENEMY]
	--move the projectile forward
	deferred
	end

	set_damage(new_damage: INTEGER)
	do
		damage:=new_damage
	end

	do_collision(other: ENTITY)
	local
		current_damage, other_damage: INTEGER
		message:STRING
	do
		--create Result.make_empty
		create message.make_empty
		if attached {PROJECTILE} other as proj then
			if (symbol~friend_proj and proj.symbol~enemy_proj)or (symbol~enemy_proj and proj.symbol~friend_proj) then --if enemy and friend collide
				current_damage:=damage-proj.damage
				other_damage:=proj.damage-damage
				if current_damage < 1 then
					current.destroy
					if (proj.symbol~proj.friend_proj) then
						message:="%N      The projectile collides with friendly projectile"+proj.id_out+" at location "+proj.coord_out+", negating damage."
					elseif proj.symbol~enemy_proj then
						message:="%N      The projectile collides with enemy projectile"+proj.id_out+" at location "+proj.coord_out+", negating damage."
					end
					x:=proj.x
					y:=proj.y
				else
					damage:=current_damage
				end
				if other_damage < 1 then
					proj.destroy
					if proj.symbol~friend_proj then
						message:="%N      The projectile collides with friendly projectile"+proj.id_out+" at location "+proj.coord_out+", negating damage."
					elseif proj.symbol~enemy_proj then
						message:="%N      The projectile collides with enemy projectile"+proj.id_out+" at location "+proj.coord_out+", negating damage."
					end
				else
					proj.set_damage(other_damage)
				end
			elseif (symbol~friend_proj and proj.symbol~friend_proj)or (symbol~enemy_proj and proj.symbol~enemy_proj) then --if enemy and friend collide then
				damage:=damage+proj.damage
				proj.destroy
				if symbol~friend_proj then
					message:="%N      The projectile collides with friendly projectile"+proj.id_out+" at location "+proj.coord_out+", combining damage."
				elseif symbol~enemy_proj then
					message:="%N      The projectile collides with enemy projectile"+proj.id_out+" at location "+proj.coord_out+", combining damage."
				end
			end
		elseif attached {SHIP} other as ship then
			if (symbol ~ friend_proj) then
				destroy
				x:=ship.x
				y:=ship.y
				current_damage:=damage-ship.max_armour
				if current_damage<0 then
					current_damage:=0
				end
				message:="%N      The projectile collides with "+ship.name.out+ship.id_out+" at location "+ship.coord_out+", dealing "+current_damage.out+" damage."
				if current_damage>0 then
					ship.set_health (ship.current_health-current_damage)
				end
				if ship.current_health<1 then
					ship.set_health (0)
					ship.destroy
					message.append("%N      The "+ship.name+" at location "+ship.coord_out+" has been destroyed.")
				end
			elseif symbol ~ enemy_proj then
				destroy
				x:=ship.x
				y:=ship.y
				current_damage:=damage-ship.max_armour
				if current_damage<0 then
					current_damage:=0
				end
				if ship.symbol~ship.starfighter then
					message:="%N      The projectile collides with "+ship.name+ship.id_out+" at location "+ship.coord_out+", dealing "+current_damage.out+" damage."
					if current_damage>0 then
						ship.set_health (ship.current_health-current_damage)
					end
					if ship.current_health<1 then
						symbol:=destroyed
						ship.set_health (0)
						ship.destroy
						message.append("%N      The "+ship.name+" at location "+ship.coord_out+" has been destroyed.")
					end
				else
					message:="%N      The projectile collides with "+ship.name+ship.id_out+" at location "+ship.coord_out+", healing "+damage.out+" damage."
					ship.set_health(ship.current_health+damage)
					if ship.current_health>ship.max_health then
						ship.set_health (ship.max_health)
					end
				end
			end
		end
		collision_messages.append(message)
	end

	did_not_move
	do
		moved:=false
	end

end

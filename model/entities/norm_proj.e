note
	description: "For projectiles that do not teleport and require collision check each block of the way."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NORM_PROJ

inherit
	PROJECTILE

create
	make

feature
	is_rocket: BOOLEAN


feature {NONE} -- Initialization
	--make(col, row, proj_speed, weapon_damage, spread_num: INTEGER; rocket, friendly: BOOLEAN)
	make(col, row, proj_speed, weapon_damage: INTEGER; friendly: BOOLEAN)
			-- Initialization for `Current'.
		do
			if friendly then
				symbol:=friend_proj
			else
				symbol:=enemy_proj
			end
			damage:=weapon_damage
			old_x:=0
			old_y:=0
			x:=col
			y:=row
			speed:=proj_speed
			within_board:=true
			if speed=1 then
				is_rocket:=true
			end
			create collision_messages.make_empty
		end

feature
	advance_proj(ht: HASH_TABLE[ENTITY,STRING]):ARRAY[ENEMY]
	--move the projectile forward
	local
		collides_with: ARRAYED_LIST[ENTITY]
		destroyed_enemies: ARRAY[ENEMY]
		i: INTEGER
	do
		create destroyed_enemies.make_empty
		if is_destroyed or not within_board then --if it was destroyed previously remove from board
			out_of_board
			moved:=false
		else
			moved:=true
			if is_rocket then
				if x>0 then
					old_x:=x
					old_y:=y
					x:=x+speed
					speed:=speed*2
				end
			else
				inspect speed
				when 2 then --pylon projectile
					old_y:=y
					old_x:=x
					x:=x-speed
				when 3 then --fighter (unseen) projectile
					old_y:=y
					old_x:=x
					x:=x-speed
				when 4 then	--grint projectile
					old_y:=y
					old_x:=x
					x:=x-speed
				when 5 then --standard
					old_y:=y
					old_x:=x
					x:=x+speed
				when 6 then --fighter (seen) projectile
					old_y:=y
					old_x:=x
					x:=x-speed
				when 10 then --fighter (preempt) projectile
					old_y:=y
					old_x:=x
					x:=x-speed
				end
			end

			collides_with:=check_collision(ht)
			create collision_messages.make_empty

			from
				i:=1
			until
				i>collides_with.count
			loop
				if not is_destroyed then
					do_collision(collides_with[i])
				end
				if attached {ENEMY} collides_with[i] as enemy and collides_with[i].is_destroyed then --return any destroyed enemies to add to score
					destroyed_enemies.force (enemy, destroyed_enemies.count+1)
				end
				i:=i+1
			end
		end
		Result:=destroyed_enemies
	end
end

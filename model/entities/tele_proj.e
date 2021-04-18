note
	description: "Projectiles that do not need collision check for every block travelled (or does not move)"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TELE_PROJ

inherit
	PROJECTILE

create
	make

feature
	spread_proj_num: INTEGER --for tracking spread projectiles

feature {NONE} -- Initialization

	make(col, row, proj_speed, weapon_damage, spread_num: INTEGER)
			-- Initialization for `Current'.
		do
			symbol:=friend_proj
			x:=col
			y:=row
			old_x:=0
			old_y:=0
			speed:=proj_speed
			damage:=weapon_damage
			within_board:=true
			spread_proj_num:=spread_num
			create collision_messages.make_empty
		end

feature

	advance_proj(ht: HASH_TABLE[ENTITY,STRING]):ARRAY[ENEMY]
	do
		create Result.make_empty
		if is_destroyed then
			out_of_board
			moved:=false
		else
			moved:=true
			--do not do collision check along the way
			old_x:=x
			old_y:=y
			if speed=1 then
				x:=x+speed
				if spread_proj_num = 1 then --first proj move upwards
					y:=y-1
				elseif spread_proj_num=3 then --third proj moves downwards
					y:=y+1
				end
			else
				x:=x+speed
			end
			create collision_messages.make_empty
			if attached ht.at (get_coord.out) as entity then
				if not (entity ~ current) then --and entry is not the current projectile
					--collision_messages.append(do_collision(entity))
					do_collision(entity)
				end
				if attached {ENEMY} entity as enemy and entity.is_destroyed then
					Result.force(enemy, result.count+1)
				end
			end
		end
	end
end

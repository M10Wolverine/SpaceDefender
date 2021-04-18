note
	description: "Summary description for {ROCKET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ROCKET

inherit
	WEAPON

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Rocket"
			health:=10
			energy:=0
			health_regn:=10
			energy_regn:=0
			armour:=2
			vision:=2
			move:=0
			move_cost:=3
			damage:= 100
			cost:=10 --rocket uses 10 health instead
			cost_type:=health_cost_type
			proj_speed:=1 --doubles speed every turn
		end

feature


	fire(x,y:INTEGER):ARRAY[PROJECTILE]
	local
		projectile1, projectile2: NORM_PROJ
		new_projectiles: ARRAY[PROJECTILE]
	do
		create projectile1.make(x-1, y-1, proj_speed,damage, true);
		create projectile2.make(x-1, y+1, proj_speed,damage, true);
		create new_projectiles.make_empty
		new_projectiles.force (projectile1, 1)
		new_projectiles.force (projectile2, 2)
		Result:=new_projectiles
	end

end

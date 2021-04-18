note
	description: "Summary description for {SPREAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SPREAD

inherit
	WEAPON

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Spread"
			health:=0
			energy:=60
			health_regn:=0
			energy_regn:=2
			armour:=1
			vision:=0
			move:=0
			move_cost:=2
			damage:= 50
			cost:=10
			cost_type:=energy_cost_type
			proj_speed:=1
		end

feature


	fire(x,y:INTEGER):ARRAY[PROJECTILE]
	local
		projectile1, projectile2, projectile3: TELE_PROJ
		new_projectiles: ARRAY[PROJECTILE]
	do
		create projectile1.make(x+1, y-1, proj_speed, damage,1);
		create projectile2.make(x+1, y, proj_speed, damage,2);
		create projectile3.make(x+1, y+1, proj_speed,damage,3);
		create new_projectiles.make_empty
		new_projectiles.force (projectile1, 1)
		new_projectiles.force (projectile2, 2)
		new_projectiles.force (projectile3, 3)
		Result:=new_projectiles
	end

end

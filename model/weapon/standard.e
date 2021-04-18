note
	description: "Summary description for {STANDARD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STANDARD

inherit
	WEAPON

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Standard"
			health:=10
			energy:=10
			health_regn:=0
			energy_regn:=1
			armour:=0
			vision:=1
			move:=1
			move_cost:=1
			damage:= 70
			cost:=5
			cost_type:=energy_cost_type
			proj_speed:=5
		end

feature


	fire(x,y:INTEGER):ARRAY[PROJECTILE]
	local
		projectile1: NORM_PROJ
		new_projectiles: ARRAY[PROJECTILE]
	do
		create projectile1.make(x+1, y, proj_speed, damage, true);
		create new_projectiles.make_empty
		new_projectiles.force (projectile1, 1)
		Result:=new_projectiles
	end

end

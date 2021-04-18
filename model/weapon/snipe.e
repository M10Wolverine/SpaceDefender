note
	description: "Summary description for {SNIPE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SNIPE

inherit
	WEAPON

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Snipe"
			health:=0
			energy:=100
			health_regn:=0
			energy_regn:=5
			armour:=0
			vision:=10
			move:=3
			move_cost:=0
			damage:= 1000
			cost:=20
			cost_type:=energy_cost_type
			proj_speed:=8
		end
feature


	fire(x,y:INTEGER):ARRAY[PROJECTILE]
	local
		projectile: TELE_PROJ
		new_projectiles: ARRAY[PROJECTILE]
	do
		create projectile.make(x+1, y, proj_speed, damage,0);
		create new_projectiles.make_empty
		new_projectiles.force (projectile, 1)
		Result:=new_projectiles
	end

end

note
	description: "Summary description for {SPLITTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SPLITTER

inherit
	WEAPON

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Splitter"
			health:=0
			energy:=100
			health_regn:=0
			energy_regn:=10
			armour:=0
			vision:=0
			move:=0
			move_cost:=5
			damage:= 150
			cost:=70
			cost_type:=energy_cost_type
			proj_speed:=0
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

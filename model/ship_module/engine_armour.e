note
	description: "Summary description for {ENGINE_ARMOUR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINE_ARMOUR

inherit
	SHIP_MODULE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Armoured"
			health:=50
			energy:=100
			health_regn:=0
			energy_regn:=3
			armour:=3
			vision:=6
			move:=4
			move_cost:=5
		end

end

note
	description: "Summary description for {ARMOUR_LIGHT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_LIGHT

inherit
	SHIP_MODULE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Light"
			health:=75
			energy:=0
			health_regn:=2
			energy_regn:=0
			armour:=3
			vision:=0
			move:=-0
			move_cost:=1
		end

end

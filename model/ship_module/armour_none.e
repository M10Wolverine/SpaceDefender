note
	description: "Summary description for {ARMOUR_NONE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_NONE

inherit
	SHIP_MODULE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="None"
			health:=50
			energy:=0
			health_regn:=1
			energy_regn:=0
			armour:=0
			vision:=0
			move:=1
			move_cost:=0
		end

end

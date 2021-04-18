note
	description: "Summary description for {ARMOUR_MEDIUM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_MEDIUM

inherit
	SHIP_MODULE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Medium"
			health:=100
			energy:=0
			health_regn:=3
			energy_regn:=0
			armour:=5
			vision:=0
			move:=0
			move_cost:=3
		end

end

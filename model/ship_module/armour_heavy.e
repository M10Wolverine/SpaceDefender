note
	description: "Summary description for {ARMOUR_HEAVY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARMOUR_HEAVY

inherit
	SHIP_MODULE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Heavy"
			health:=200
			energy:=0
			health_regn:=4
			energy_regn:=0
			armour:=10
			vision:=0
			move:=-1
			move_cost:=5
		end

end

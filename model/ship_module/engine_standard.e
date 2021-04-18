note
	description: "Summary description for {ENGINE_STANDARD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINE_STANDARD

inherit
	SHIP_MODULE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Standard"
			health:=10
			energy:=60
			health_regn:=0
			energy_regn:=2
			armour:=1
			vision:=12
			move:=8
			move_cost:=2
		end

end

note
	description: "Summary description for {ENGINE_LIGHT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENGINE_LIGHT

inherit
	SHIP_MODULE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			name:="Light"
			health:=0
			energy:=30
			health_regn:=0
			energy_regn:=1
			armour:=0
			vision:=15
			move:=10
			move_cost:=1
		end

end

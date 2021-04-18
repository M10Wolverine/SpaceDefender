note
	description: "Summary description for {WEAPON}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	WEAPON
inherit
	SHIP_MODULE

feature --constants
	energy_cost_type: STRING="energy"
	health_cost_type: STRING="health"

feature
	--proj_type: PROJECTILE
	damage: INTEGER
	cost: INTEGER
	cost_type: STRING
	proj_speed: INTEGER
	--fires_rocket: BOOLEAN

	fire(x,y: INTEGER):ARRAY[PROJECTILE]
	--take the player xy coord and create projectile accordingly
	deferred
	end


end

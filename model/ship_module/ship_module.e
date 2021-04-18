note
	description: "Summary description for {SHIP_MODULE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SHIP_MODULE

feature --module constants
	standard: INTEGER=1
	spread:INTEGER=2
	snipe:INTEGER=3
	rocket: INTEGER=4
	splitter: INTEGER=5

	arm_none: INTEGER=1
	arm_light: INTEGER=2
	arm_medium: INTEGER=3
	arm_heavy: INTEGER=4

	eng_stand: INTEGER=1
	eng_light: INTEGER=2
	eng_armoured: INTEGER=3

	recall:INTEGER=1
	repair:INTEGER=2
	overcharge:INTEGER=3
	drone:INTEGER=4
	orb_strike:INTEGER=5

feature --module attributes
	health: INTEGER
	energy: INTEGER
	health_regn: INTEGER
	energy_regn: INTEGER
	armour: INTEGER
	vision: INTEGER
	move: INTEGER
	move_cost: INTEGER

	name: STRING


end

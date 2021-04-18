note
	description: "Summary description for {SHIP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SHIP

inherit
	ENTITY

feature --common scoring values
	bronze: INTEGER=1
	silver: INTEGER=2
	gold: INTEGER=3

	platinum: INTEGER=3
	diamond: INTEGER=4

feature --common attributes
	max_health: INTEGER
	max_vision: INTEGER
	max_armour: INTEGER
	max_health_regen: INTEGER
	max_moves: INTEGER

	name: STRING

	current_health: INTEGER

	last_projectiles: ARRAY[PROJECTILE]

	score: SCORING

feature
	fire(ht: HASH_TABLE[ENTITY,STRING]): ARRAY[PROJECTILE] --wraper to fire weapon
	deferred
	end

	regenerate
	deferred
	ensure
		health_case_noregen: old current_health >= max_health implies current_health = old current_health
		health_case_regen: old current_health<max_health implies current_health= old current_health+max_health_regen or current_health=max_health
	end

	set_health(new_health: INTEGER)
	do
		current_health:=new_health
	end

	old_coord_out: STRING
	--return string representation of coord in [X,Y] form
	do
		create Result.make_empty
		inspect old_y
		when 1 then
			Result:="[A,"+old_x.out+"]"
		when 2 then
			Result:="[B,"+old_x.out+"]"
		when 3 then
			Result:="[C,"+old_x.out+"]"
		when 4 then
			Result:="[D,"+old_x.out+"]"
		when 5 then
			Result:="[E,"+old_x.out+"]"
		when 6 then
			Result:="[F,"+old_x.out+"]"
		when 7 then
			Result:="[G,"+old_x.out+"]"
		when 8 then
			Result:="[H,"+old_x.out+"]"
		when 9 then
			Result:="[I,"+old_x.out+"]"
		when 10 then
			Result:="[J,"+old_x.out+"]"
		end
	end

end

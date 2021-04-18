note
	description: "Summary description for {PLAYER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PLAYER

inherit
	SHIP
	redefine
		destroy
	end

create
	make

feature
	max_energy: INTEGER
	max_energy_regen: INTEGER
	move_cost: INTEGER
	current_energy: INTEGER
	power_cost: INTEGER
	acted: BOOLEAN
	special_message: STRING

	weapon: WEAPON
	armour: SHIP_MODULE
	engine: SHIP_MODULE
	power: INTEGER

	last_action: INTEGER
	PASSED:INTEGER=1
	FIRED:INTEGER=2
	MOVED:INTEGER=3
	SPECIALED: INTEGER=4

	RECALL: INTEGER=1
	REPAIR: INTEGER=2
	OVERCHARGE: INTEGER=3
	DRONES: INTEGER=4
	STRIKE: INTEGER=5

	spawn: PAIR[INTEGER,INTEGER]

feature {NONE} -- Initialization

	make(modules: ARRAY[INTEGER]; spawn_x, spawn_y: INTEGER)
			-- Initialization for `Current'.
		do
			--create weapon module
			create {STANDARD} weapon.make
			if modules[1]=weapon.spread then
				create {SPREAD} weapon.make
			elseif modules[1]=weapon.snipe then
				create {SNIPE} weapon.make
			elseif modules[1]=weapon.rocket then
				create {ROCKET} weapon.make
			elseif modules[1]=weapon.splitter then
				create {SPLITTER} weapon.make
			end

			--create armour module
			create {ARMOUR_NONE} armour.make
			if modules[2]=armour.arm_light then
				create {ARMOUR_LIGHT} armour.make
			elseif modules[2]=armour.arm_medium then
				create {ARMOUR_MEDIUM} armour.make
			elseif modules[2]=armour.arm_heavy then
				create {ARMOUR_HEAVY} armour.make
			end

			create {ENGINE_STANDARD} engine.make
			if modules[3]=engine.eng_light then
				create {ENGINE_LIGHT} engine.make
			elseif modules[3]=engine.eng_armoured then
				create {ENGINE_ARMOUR} engine.make
			end

			power:=modules[4]
			if power=RECALL or power=REPAIR then
				power_cost:=50
			elseif power=DRONES or power=STRIKE then
				power_cost:=100
			else
				power_cost:=0 --Overcharge uses health instead
			end

			max_health:=weapon.health+armour.health+engine.health
			max_vision:=weapon.vision+armour.vision+engine.vision
			max_armour:=weapon.armour+armour.armour+engine.armour
			max_health_regen:=weapon.health_regn+armour.health_regn+engine.health_regn
			max_energy:=weapon.energy+armour.energy+engine.energy
			max_energy_regen:=weapon.energy_regn+armour.energy_regn+engine.energy_regn
			max_moves:=weapon.move+armour.move+engine.move
			move_cost:=weapon.move_cost+armour.move_cost+engine.move_cost

			current_health:=max_health
			current_energy:=max_energy

			id:=0
			symbol:=starfighter
			name:="Starfighter"
			x:=spawn_x
			y:=spawn_y
			create spawn.make (x, y)
			create special_message.make_empty

			within_board:=true

			create last_projectiles.make_empty
			create collision_messages.make_empty
			create {FOCUS} score.make (5)
		end

feature --Features to manipulate Player
	tp_to(row, col: INTEGER) --teleport player to location without checking collision or using energy
	do
		old_x:=x
		x:=col
		old_y:=y
		y:=row
	end

	go_to(row, col: INTEGER; ht: HASH_TABLE[ENTITY,STRING])
	local
		total_move_cost: INTEGER
		collides_with: LIST[ENTITY]
	do
		last_action:=MOVED
		old_x:=x
		x:=col
		old_y:=y
		y:=row

		collides_with:=check_collision(ht)
		create collision_messages.make_empty
		across
			collides_with is e
		loop
			if current_health>0 then
				do_collision(e)
			end

		end
		total_move_cost:=((y-old_y).abs+(x-old_x).abs)*move_cost
		current_energy:=current_energy-total_move_cost
	ensure
		player_not_dead: current_health>0 implies x=col and y=row
	end

	regenerate
	do
		last_action:=PASSED --when passing this is the last player action

		if current_health<max_health then --only apply regen if less than max
			current_health:=current_health+max_health_regen
			if current_health > max_health then --if not check that regen does not take it above max
				current_health:=max_health
			end
		end

		if current_energy<max_energy then
			current_energy:=current_energy+max_energy_regen
			if current_energy > max_energy then
				current_energy:=max_energy
			end
		end
	ensure then
		energy_case_noregen: old current_energy >= max_energy implies current_energy = old current_energy
		energy_case_regen: old current_energy<max_energy implies current_energy=old current_energy+max_energy_regen or current_energy=max_energy
	end

	fire(ht: HASH_TABLE[ENTITY,STRING]):ARRAY[PROJECTILE]
	local
		score_added: BOOLEAN
	do
		last_action:=FIRED
		if weapon.cost_type ~ weapon.energy_cost_type then --subtract energy cost
			current_energy:=current_energy-weapon.cost
		else
			current_health:=current_health-weapon.cost --subtract health cost if using rocket
		end
		last_projectiles:=weapon.fire (x, y)
		--do spawning collision check
		across
			last_projectiles is projectile
		loop
			if attached ht.at (projectile.get_coord.out) as ent then
				projectile.do_collision(ent)
				if attached {ENEMY} ent as enemy then
					if enemy.is_destroyed then
						score_added:=score.add_score (enemy.score)
					end
				end
			end
		end
		Result:=last_projectiles
	end

	do_collision(other: ENTITY)
	local
		damage_after_armour: INTEGER
		added_score: BOOLEAN
		message: STRING
	do
		create message.make_empty
		if attached {PROJECTILE} other as proj then --do projectile collision (take into account armour)
			proj.destroy
			damage_after_armour:=proj.damage-max_armour
			if damage_after_armour<0 then
					damage_after_armour:=0
				end
			if proj.symbol=proj.friend_proj then --return the string description of collision
				message:="%N      The Starfighter collides with friendly projectile"+proj.id_out+" at location "+proj.coord_out+", taking "+damage_after_armour.out+" damage."
			elseif proj.symbol=proj.enemy_proj then --return the string description of collision
				message:="%N      The Starfighter collides with enemy projectile"+proj.id_out+" at location "+proj.coord_out+", taking "+damage_after_armour.out+" damage."
			end
			if damage_after_armour>0 then
				current_health:=current_health-damage_after_armour
			end
		elseif attached {ENEMY} other as enemy then --do enemy collision (no armour)
			enemy.destroy
			added_score:=current.score.add_score(enemy.score)
			current_health:=current_health-enemy.current_health
			message:="%N      The Starfighter collides with "+enemy.name+enemy.id_out+" at location "+enemy.coord_out+", trading "+enemy.current_health.out+" damage."
			message.append("%N      The "+enemy.name+" at location "+enemy.coord_out+" has been destroyed.")
		end
		if current_health<0 then --set death spot
			x:=other.x
			y:=other.y
			destroy
			message.append ("%N      The Starfighter at location "+coord_out+" has been destroyed.")
		end
		collision_messages.append(message)
	end

	use_special(ht: HASH_TABLE[ENTITY, STRING]; projectiles: ARRAY[PROJECTILE]; ships: ARRAY[SHIP])
	local
		s,i: INTEGER
		score_added: BOOLEAN
	do
		last_action:=SPECIALED
		special_message.make_empty
		inspect power
		when RECALL then --Recall
			x:=spawn.first
			y:=spawn.second
			if attached ht.at (spawn.out) as entity then
				do_collision(entity)
			end
			special_message:="%N    The Starfighter(id:0) uses special, teleporting to: "+coord_out
		when REPAIR then --Repair
			current_health:=current_health+50
			special_message:="%N    The Starfighter(id:0) uses special, gaining 50 health."
		when OVERCHARGE then--Overcharge
			if current_health>50 then
				s:=50
			else
				s:=current_health-1
			end
			current_health:=current_health-s
			current_energy:=current_energy+(s*2)
			special_message:="%N    The Starfighter(id:0) uses special, gaining "+(s*2).out+" energy at the expense of "+s.out+" health."
		when DRONES then --Deploy Drone
			special_message:="%N    The Starfighter(id:0) uses special, clearing projectiles with drones."
			across
				projectiles is p
			loop
				p.destroy
				special_message.append("%N      A projectile"+p.id_out+" at location "+p.coord_out+" has been neutralized.")
			end
		when STRIKE then --Orbital Strike
			special_message:="%N    The Starfighter(id:0) uses special, unleashing a wave of energy."
			from
				i:=2
			until
				i>ships.count
			loop
				if ships[i].within_board and not ships[i].is_destroyed then
					s:=100-ships[i].max_armour
					if s<0 then
						s:=0
					end
					special_message.append ("%N      A "+ships[i].name.out+ships[i].id_out+" at location "+ships[i].coord_out+" takes "+s.out+" damage.")
					if s>0 then
						ships[i].set_health(ships[i].current_health-s)
						if ships[i].current_health<1 then
							ships[i].set_health(0)
							ships[i].destroy
							score_added:=score.add_score (ships[i].score)
							special_message.append("%N      The "+ships[i].name.out+" at location "+ships[i].coord_out+" has been destroyed.")
						end
					end
				end
				i:=i+1
			end
		end
		current_energy:=current_energy-power_cost
	end

	destroy
	do
		symbol:=destroyed
		current_health:=0
	end

	did_not_act
	do
		acted:=false
	end
	did_act
	do
		acted:=true
	end

end

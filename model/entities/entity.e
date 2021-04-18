note
	description: "Summary description for {ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENTITY

feature
	id: INTEGER
	symbol: STRING

	x, old_x: INTEGER
	y, old_y:INTEGER

	within_board: BOOLEAN
	is_destroyed: BOOLEAN

	collision_messages: STRING

feature --entity constants
	starfighter: STRING="S"
	grunt: STRING = "G"
	fighter: STRING="F"
	carrier: STRING="C"
	intercept: STRING="I"
	pylon: STRING="P"
	enemy_proj: STRING="<"
	friend_proj: STRING="*"
	destroyed: STRING="X"

feature
	get_coord:PAIR[INTEGER, INTEGER]
	--get the xy coord as a pair
	local
		pair: PAIR[INTEGER, INTEGER]
	do
		create pair.make(x, y)
		Result :=pair
	end

	assign_id(new_id: INTEGER)
	--id assigner
	do
		id:=new_id
	end

	id_out: STRING
	--create string representation of id in form: (id:x)
	do
		create Result.make_from_string("(id:")
		Result.append(id.out)
		Result.append(")")
	end

	out_of_board
	--toggle within_board to false
	do
		within_board:=false
	end

	destroy
	do
		is_destroyed:=true
	end

	check_collision(entities: TABLE[ENTITY, STRING]): ARRAYED_LIST[ENTITY]
	--give the hash table of all entities on the board return a list of those in the path in collision order
	local
		path_entities: ARRAYED_LIST[ENTITY]
		temp_array1, temp_array2: ARRAY[ENTITY]
		i: INTEGER
	do
		create path_entities.make (10)
		across
			entities is e
		loop
			if not (e ~ current) then --check that the cursor is not on the current entity itself
				--before using first move the entity so old x,y and x,y are updated but do not subtract energy cost (if player)
				--first check along the vertical path (check each y value along an x column)
				--if e.x=current x and is b/w start y and end y
					--iterate through path_entities and place in the spot where collision will occur
				--else if e.y = current y and b/w start x and end x
					--place in path_entities. Precedence is smaller y if same x (if moving down), then smaller x if same y(if moving right)
				if e.x = old_x and ((e.y > old_y and e.y<=y)) then --moving downwards
					if path_entities.is_empty then
						path_entities.extend (e)
					else
						across
							path_entities is pe
						loop
							if pe.x = e.x then --first check through entries where pe.x = e.x
								if e.y<pe.y and (not path_entities.has(e)) then
									if path_entities.before then
										path_entities.put_front (e)
									else
										path_entities.put_left (e)
									end
								end
							else --if e.y is the largest place at the end before second part of the list
								if not path_entities.has (e) then
									path_entities.put_left (e)
								end
							end
							if not path_entities.has (e) then --in situation where e needs to go to the end but second part of list is empty (no same y)
								path_entities.extend (e)
							end
						end
					end
				elseif e.x = old_x and (e.y<old_y and e.y>=y) then --moving upwards --NEW
					if path_entities.is_empty then
						path_entities.extend (e)
					else
						across
							path_entities is pe
						loop
							if pe.x = e.x then --first check through entries where pe.x = e.x
								if e.y>pe.y and (not path_entities.has(e)) then
									if path_entities.before then
										path_entities.put_front (e)
									else
										path_entities.put_left (e)
									end
								end
							else --if e.y is the largest place at the end before second part of the list
								if not path_entities.has (e) then
									path_entities.put_left (e)
								end
							end
							if not path_entities.has (e) then --in situation where e needs to go to the end but second part of list is empty (no same y)
								path_entities.extend (e)
							end
						end
					end
				elseif e.y=y and ((e.x>old_x and e.x<=x)) then --moving to the right
					if path_entities.is_empty then
						path_entities.extend (e)
					elseif path_entities[1].x>e.x then
						path_entities.put_front (e)
					else
--						across
--							path_entities is pe
--						loop
--							if pe.y = e.y then
--								if e.x<pe.x and (not path_entities.has(e)) then
----									if path_entities.before then
----										path_entities.put_front (e)
----									else
----										path_entities.put_left (e)
----									end
--								end
--							end
--						end
						from
							i:=2
						until
							i>path_entities.count
						loop
							if path_entities[i].y = e.y then
								if e.x<path_entities[i].x and (not path_entities.has(e)) then
									create temp_array1.make_from_array (path_entities.to_array.subarray (1, i)) --split path_entities where  should go
									temp_array1.force (e, temp_array1.count+1)
									create temp_array2.make_from_array (path_entities.to_array.subarray (i, path_entities.count))
									across
										temp_array2 is entry
									loop
										temp_array1.force (entry, temp_array1.count) --recreate the list with e
									end
									create path_entities.make_from_array (temp_array1)
									i:=i+1 --increase i an extra time as new item was added before
								end
							end
							i:=i+1
						end
						if not path_entities.has (e) then --place e at the end if not previously placed (e.i. e is the largest x among same y)
							path_entities.extend (e)
						end
					end
				elseif e.y=y and (e.x<old_x and e.x >=x) then --moving to the left --NEW
					if path_entities.is_empty then
						path_entities.extend (e)
					elseif path_entities[1].x<e.x then
						path_entities.put_front (e)
					else
						from
							i:=2
						until
							i>path_entities.count
						loop
							if path_entities[i].y = e.y then
								if e.x>path_entities[i].x and (not path_entities.has(e)) then
									create temp_array1.make_from_array (path_entities.to_array.subarray (1, i)) --split path_entities where  should go
									temp_array1.force (e, temp_array1.count+1)
									create temp_array2.make_from_array (path_entities.to_array.subarray (i, path_entities.count))
									across
										temp_array2 is entry
									loop
										temp_array1.force (entry, temp_array1.count) --recreate the list with e
									end
									create path_entities.make_from_array (temp_array1)
									i:=i+1 --increase i an extra time as new item was added before
								end
							end
							i:=i+1
						end
						if not path_entities.has (e) then --place e at the end if not previously placed (e.i. e is the largest x among same y)
							path_entities.extend (e)
						end
					end
				end
			end
		end

		Result:=path_entities
	end

	do_collision(other: ENTITY)
	deferred
	end

	coord_out: STRING
	--return string representation of coord in [X,Y] form
	do
		create Result.make_empty
		inspect y
		when 1 then
			Result:="[A,"+x.out+"]"
		when 2 then
			Result:="[B,"+x.out+"]"
		when 3 then
			Result:="[C,"+x.out+"]"
		when 4 then
			Result:="[D,"+x.out+"]"
		when 5 then
			Result:="[E,"+x.out+"]"
		when 6 then
			Result:="[F,"+x.out+"]"
		when 7 then
			Result:="[G,"+x.out+"]"
		when 8 then
			Result:="[H,"+x.out+"]"
		when 9 then
			Result:="[I,"+x.out+"]"
		when 10 then
			Result:="[J,"+x.out+"]"
		else
			Result:="out of board"
		end
		if x<1 then
			Result:="out of board"
		end
	end

	set_collision_messages(st: STRING)
	do
		collision_messages:=st
	end

end

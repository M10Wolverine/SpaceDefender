note
	description: "Summary description for {FOCUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FOCUS

inherit
	SCORING

create
	make

feature {NONE} -- Initialization

	make(type: INTEGER)
			-- Initialization for `Current'.
		local
			first_orb: ORB
		do
			size:=type
			if size=5 then
				is_player:=true
			end
			create slots.make (size)
			if size=diamond then
				create first_orb.make(gold)
				slots.force (first_orb)
			elseif size=platinum then
				create first_orb.make(bronze)
				slots.force (first_orb)
			end
		end

feature
	size: INTEGER
	slots: ARRAYED_LIST[SCORING]
	is_player: BOOLEAN

feature--method to add/get score
	add_score(s: SCORING): BOOLEAN
	local
		i: INTEGER
		deposited: BOOLEAN
	do
		deposited:=false
		from
			i:=1
		until
			i>slots.count or deposited --i>slots.count
		loop
			if attached {ORB} slots[i] as orb then
				--skip
			elseif attached {FOCUS} slots[i] as subfocus then
				deposited:=subfocus.add_score(s)--check if the focus has any open spots
			else
				slots.put_i_th (s, i) --if not an orb or a focus put in the slot
				deposited:=true
			end
			i:=i+1
		end
		if ((not deposited) and (slots.count < slots.capacity or is_player)) then --add the orb if there's spare capacity. if player add the orb
			slots.force (s)
			deposited:=true
		end
		Result:=deposited
	end

	get_score: INTEGER
	local
		count: INTEGER
		i: INTEGER
	do
		count:=0
		from
			i:=1
		until
			i>slots.count
		loop
			count:=count+slots[i].get_score
			i:=i+1
		end
		if slots.count=size then
			if size=diamond then
				count:=count*3
			elseif size=platinum then
				count:=count*2
			end
		end
		Result:=count
	end

invariant

	valid_size:(size=diamond or size=platinum) implies slots.capacity=size
end

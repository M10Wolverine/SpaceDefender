note
	description: "Summary description for {ORB}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ORB

inherit
	SCORING

create
	make

feature {NONE} -- Initialization

	make(type: INTEGER)
			-- Initialization for `Current'.
		do
			value:=type
		end

feature{FOCUS} --orb attribute
	value: INTEGER

	add_score(s: SCORING):BOOLEAN
	do
		--do nothing
	end

	get_score:INTEGER
	do
		Result:=value
	end

end

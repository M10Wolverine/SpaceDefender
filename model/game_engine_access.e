note
	description: "Singleton access to the default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

expanded class
	GAME_ENGINE_ACCESS

feature
	m: GAME_ENGINE
		once
			create Result.make
		end

invariant
	m = m
end





note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PASS
inherit
	ETF_PASS_INTERFACE
create
	make
feature -- command
	pass
    	do
			-- perform some update on the model state
			if not (model.current_state = model.in_game) then
				model.command_error
				model.update_abstract_out (model.m.not_ingame)
			else
				model.pass
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

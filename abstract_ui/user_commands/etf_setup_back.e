note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_BACK
inherit
	ETF_SETUP_BACK_INTERFACE
create
	make
feature -- command
	setup_back(state: INTEGER_32)
		require else
			setup_back_precond(state)
    	do
			-- perform some update on the model state
			--model.default_update
			if model.current_state = model.not_started or model.current_state= model.in_game then
				model.command_error
				model.update_abstract_out (model.m.not_insetup)
			else
				model.setup_back (state)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

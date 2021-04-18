note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_NEXT
inherit
	ETF_SETUP_NEXT_INTERFACE
create
	make
feature -- command
	setup_next(state: INTEGER_32)
		require else
			setup_next_precond(state)
    	do
			-- perform some update on the model state
--			model.default_update
			if model.current_state = model.not_started or model.current_state= model.in_game then
				model.command_error
				model.update_abstract_out (model.m.not_insetup)
			else
				model.setup_next (state)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ABORT
inherit
	ETF_ABORT_INTERFACE
create
	make
feature -- command
	abort
    	do
			-- perform some update on the model state
			if model.current_state = model.not_started then
				model.command_error
				model.update_abstract_out (model.m.abort_not_ingame)
			else
				model.abort
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

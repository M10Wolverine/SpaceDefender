note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_TOGGLE_DEBUG_MODE
inherit
	ETF_TOGGLE_DEBUG_MODE_INTERFACE
create
	make
feature -- command
	toggle_debug_mode
    	do
			-- perform some update on the model state
			model.command_error
			model.toggle_debug
			model.update_abstract_out (model.m.is_debug_out (model.debug_mode))
			etf_cmd_container.on_change.notify ([Current])
    	end

end

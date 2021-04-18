note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SETUP_SELECT
inherit
	ETF_SETUP_SELECT_INTERFACE
create
	make
feature -- command
	setup_select(value: INTEGER_32)
		require else
			setup_select_precond(value)
    	do
			-- perform some update on the model state
			--model.default_update
			if (model.current_state<model.weapon_setup or model.current_state>model.power_setup) then
				--command can only be used in setup excluding summary
				model.command_error
				model.update_abstract_out (model.m.not_insetup_no_sum)
			elseif model.current_state=model.armour_setup and value>4 then
					--armor setup only has 4 options
					model.command_error
					model.update_abstract_out (model.m.setup_out_of_range)
			elseif model.current_state=model.engine_setup and value>3 then
					--engine setup only has 3 options
					model.command_error
					model.update_abstract_out (model.m.setup_out_of_range)
			else
				model.setup_select (value)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

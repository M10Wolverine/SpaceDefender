note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SPECIAL
inherit
	ETF_SPECIAL_INTERFACE
create
	make
feature -- command
	special
    	do
			-- perform some update on the model state
			if not (model.current_state = model.in_game) then
				model.command_error
				model.update_abstract_out (model.m.not_ingame)
			elseif model.player.power_cost > model.player.current_energy+model.player.max_energy_regen then
				model.command_error
				model.update_abstract_out (model.m.special_noresource)
			else
				model.use_special
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

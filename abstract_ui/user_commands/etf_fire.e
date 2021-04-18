note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_FIRE
inherit
	ETF_FIRE_INTERFACE
create
	make
feature -- command
	fire
    	do
			-- perform some update on the model state
			if not (model.current_state = model.in_game) then
				model.command_error
				model.update_abstract_out (model.m.not_ingame)
			elseif (model.module_selection[1]=model.player.weapon.rocket)and(model.player.current_health+model.player.max_health_regen<model.player.weapon.cost) then
				model.command_error
				model.update_abstract_out (model.m.fire_noresource)
			elseif(model.player.current_energy+model.player.max_energy_regen<model.player.weapon.cost) then
				model.command_error
				model.update_abstract_out (model.m.fire_noresource)
			else
				model.fire
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

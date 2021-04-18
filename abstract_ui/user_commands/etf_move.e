note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE
inherit
	ETF_MOVE_INTERFACE
create
	make
feature -- command
	move(row: INTEGER_32 ; column: INTEGER_32)
		require else
			move_precond(row, column)
		local
			move_distance:INTEGER
    	do
			-- perform some update on the model state
			move_distance:=((model.player.x-column).abs + (model.player.y-row).abs)
			if not (model.current_state = model.in_game) then
				model.command_error
				model.update_abstract_out (model.m.not_ingame)
			elseif row<1 or column<1 or row>model.num_row or column > model.num_col then
				model.command_error
				model.update_abstract_out (model.m.move_outsid)
			elseif row=model.player.y and column=model.player.x then
				model.command_error
				model.update_abstract_out (model.m.move_present)
			elseif move_distance > model.player.max_moves then
				model.command_error
				model.update_abstract_out (model.m.move_toofar)
			elseif move_distance*model.player.move_cost > model.player.current_energy+model.player.max_energy_regen then
				model.command_error
				model.update_abstract_out (model.m.move_noresource)
			else
				model.move(row,column)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

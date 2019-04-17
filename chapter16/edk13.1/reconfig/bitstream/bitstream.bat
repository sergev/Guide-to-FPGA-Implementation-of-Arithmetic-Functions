@echo **********Deleting files*********************
del *.bmm
del *.bit

@echo **********Copying BIT, BMM files********
copy ..\PlanAhead\system_bd.bmm
copy ..\PlanAhead\PlanAhead.runs\config_dummy\config_dummy.bit system_dummy.bit

@echo **********Partial bitstreams*****************
copy ..\PlanAhead\PlanAhead.runs\config_dummy\config_dummy_rcopro_module_dummy_partial.bit partial_dummy.bit
copy ..\PlanAhead\PlanAhead.runs\config_adder\config_adder_rcopro_module_adder_partial.bit partial_adder.bit
copy ..\PlanAhead\PlanAhead.runs\config_multiplier\config_multiplier_rcopro_module_multiplier_partial.bit partial_multiplier.bit
copy ..\PlanAhead\PlanAhead.runs\config_scalar_multiplier\config_scalar_multiplier_rcopro_module_scalar_multiplier_partial.bit partial_scalar_multiplier.bit
copy ..\PlanAhead\PlanAhead.runs\config_determinant\config_determinant_rcopro_module_determinant_partial.bit partial_determinant.bit

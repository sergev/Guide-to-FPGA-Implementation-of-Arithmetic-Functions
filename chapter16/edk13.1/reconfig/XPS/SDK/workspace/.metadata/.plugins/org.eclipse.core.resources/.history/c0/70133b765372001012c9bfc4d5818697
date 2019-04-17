################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include src/subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
test_reconfig.elf.size \

ELFCHECK += \
test_reconfig.elf.elfcheck \


# All Target
all: test_reconfig.elf secondary-outputs

# Tool invocations
test_reconfig.elf: $(OBJS)  $(USER_OBJS)
	@echo Building target: $@
	@echo Invoking: MicroBlaze g++ linker
	mb-g++ -L../../standalone_bsp_0/microblaze_0/lib -mxl-barrel-shift -mxl-pattern-compare -mcpu=v8.10.a -mno-xl-soft-mul -o"test_reconfig.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo Finished building target: $@
	@echo ' '

test_reconfig.elf.size: test_reconfig.elf
	@echo Invoking: MicroBlaze Print Size
	mb-size test_reconfig.elf  |tee "test_reconfig.elf.size"
	@echo Finished building: $@
	@echo ' '

test_reconfig.elf.elfcheck: test_reconfig.elf
	@echo Invoking: Xilinx ELF Check
	elfcheck test_reconfig.elf -hw ../../hw_platform_0/system.xml -pe microblaze_0  |tee "test_reconfig.elf.elfcheck"
	@echo Finished building: $@
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(CC_DEPS)$(CPP_DEPS)$(EXECUTABLES)$(ELFSIZE)$(CXX_DEPS)$(C_UPPER_DEPS)$(ELFCHECK)$(S_UPPER_DEPS) test_reconfig.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets

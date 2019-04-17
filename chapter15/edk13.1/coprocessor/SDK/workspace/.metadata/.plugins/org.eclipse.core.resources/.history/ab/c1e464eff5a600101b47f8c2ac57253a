################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CC_SRCS += \
../src/caes128.cc \
../src/profiling_app.cc 

OBJS += \
./src/caes128.o \
./src/profiling_app.o 

CC_DEPS += \
./src/caes128.d \
./src/profiling_app.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cc
	@echo Building file: $<
	@echo Invoking: MicroBlaze g++ compiler
	mb-g++ -Wall -O2 -pg -c -fmessage-length=0 -I../../standalone_bsp_0/microblaze_0/include -mxl-barrel-shift -mxl-pattern-compare -mcpu=v8.10.a -mno-xl-soft-mul -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo Finished building: $<
	@echo ' '



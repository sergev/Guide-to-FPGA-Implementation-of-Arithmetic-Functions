################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CC_SRCS += \
../src/application.cc \
../src/led7seg.cc 

OBJS += \
./src/application.o \
./src/led7seg.o 

CC_DEPS += \
./src/application.d \
./src/led7seg.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cc
	@echo Building file: $<
	@echo Invoking: MicroBlaze g++ compiler
	mb-g++ -Wall -O3 -c -fmessage-length=0 -I../../standalone_bsp_0/microblaze_0/include -mxl-barrel-shift -mxl-pattern-compare -mcpu=v8.10.a -mno-xl-soft-mul -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo Finished building: $<
	@echo ' '



# STM32F4 Project Template
This is a template project for any STM32F4 microcontroller. The sources are taken from STM32CubeF4. In order to select the appropiate microcontroller model, you need to:
*Change the $(CPU) alias in the Makefile to match your MCU.
*Change the $(LDSCRIPT) alias in Makefile to match your corresponding MCU. STM32F401VEHx_FLASH.ld is provided, if you need other just get it from STM32CubeF4.
*Change -D option in CFLAGS to match your MCU.
*Change the startup_stm32f4**.s accordingly. They are located in cmsis/device/src/

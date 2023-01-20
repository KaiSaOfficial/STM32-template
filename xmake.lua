local project_name = "Project"
local target_dir = "xmake-build"
local download_cfg = "D:\\compiler\\OpenOCD-20210301-0.10.0\\share\\openocd\\scripts\\board\\stm32f411rc-stlink.cfg"

set_project(project_name)
set_version("v0.2")

add_rules("mode.debug", "mode.release", "mode.releasedbg", "mode.minsizerel") 
set_defaultmode("releasedbg")

toolchain("arm-none-eabi")
    set_kind("standalone")
    
    set_toolset("cc", "arm-none-eabi-gcc")
    set_toolset("as", "arm-none-eabi-gcc")
    set_toolset("ld", "arm-none-eabi-gcc")
toolchain_end()

-- basic board info
target(project_name)
    local CPU = "-mcpu=cortex-m4"
    local FPU = "-mfpu=fpv4-sp-d16"
    local FLOAT_ABI = "-mfloat-abi=hard"    
    local LDSCRIPT = "STM32F411RCTx_FLASH.ld"

    add_defines("USE_HAL_DRIVER", "STM32F411xE")
    add_cflags(CPU, "-mthumb", FPU, FLOAT_ABI, "-fdata-sections", "-ffunction-sections", {force = true})
    add_asflags(CPU, "-mthumb", FPU, FLOAT_ABI, "-fdata-sections", "-ffunction-sections", {force = true})
    add_ldflags(CPU, "-mthumb", FPU, FLOAT_ABI, "-specs=nano.specs", "-T"..LDSCRIPT, "-lm -lc -lnosys", "-Wl,-Map=" .. target_dir .. "/" .. project_name .. ".map,--cref -Wl,--gc-sections", {force = true})
    add_syslinks("m", "c", "nosys")
    
target_end()

-- add files
target(project_name)
    add_files("Core/Src/*.c",
    "Drivers/STM32F4xx_HAL_Driver/Src/*.c",
    "Middlewares/Third_Party/FreeRTOS/Source/**.c",
    "Hardwrea_driver/*.c",
    "startup_stm32f411xe.s")

    add_includedirs("Core/Inc",
    "Drivers/STM32F4xx_HAL_Driver/Inc",
    "Drivers/STM32F4xx_HAL_Driver/Inc/Legacy",
    "Middlewares/Third_Party/FreeRTOS/Source/include",
    "Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2",
    "Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F",
    "Drivers/CMSIS/Device/ST/STM32F4xx/Include",
    "Drivers/CMSIS/Include",
    "Hardwrea_driver")

target_end()

-- other config
target(project_name)
    set_targetdir(target_dir)
    set_objectdir(target_dir .. "/obj")
    set_dependir(target_dir .. "/dep")
    set_kind("binary")
    set_extension(".elf")

    add_toolchains("arm-none-eabi")
    set_warnings("all")
    set_languages("c11", "cxx17")

    if is_mode("debug") then 
        set_symbols("debug")
        add_cxflags("-Og", "-gdwarf-2", {force = true})
        add_asflags("-Og", "-gdwarf-2", {force = true})
    elseif is_mode("release") then 
        set_symbols("hidden")
        set_optimize("fastest")
        set_strip("all")
    elseif is_mode("releasedbg") then 
        set_optimize("fastes")
        set_symbols("debug")
        set_strip("all")
    elseif is_mode() then 
        set_symbols("hidden")
        set_optimize("smallest")
        set_strip("all")
    end

target_end()

after_build(function(target)
    import("core.project.task")
    cprint("${bright black onwhite}********************储存空间占用情况*****************************")
    os.exec(string.format("arm-none-eabi-objcopy -O ihex %s.elf %s.hex", target_dir .. '/' .. project_name, target_dir .. '/' .. project_name))
    os.exec(string.format("arm-none-eabi-objcopy -O binary %s.elf %s.bin", target_dir .. '/' .. project_name, target_dir .. '/' .. project_name))
    os.exec(string.format("arm-none-eabi-size -Ax %s.elf", target_dir .. '/' .. project_name))
    os.exec(string.format("arm-none-eabi-size -Bd %s.elf", target_dir .. '/' .. project_name))
    cprint("${bright black onwhite}heap-堆、stack-栈、.data-已初始化的变量全局/静态变量，bss-未初始化的data、.text-代码和常量")
end)

on_run(function(target)
    os.exec("openocd -f %s -c 'program ./%s/%s.elf verify reset exit'", download_cfg, target_dir, project_name)
end)

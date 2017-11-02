# Create user defined variables 
set CLK_PORT [get_ports clk]
set CLK_PERIOD 10 
set CLK_SKEW 0.14

set DRIVE_CELL NAND2X1

set DRIVE_PIN {Y}

set MAX_OUTPUT_LOAD [load_of gscl45nm/INVX1/A]

set OUTPUT_DELAY 1.0

set MAX_AREA 0


# Time Budget 
create_clock -period $CLK_PERIOD -name my_clock $CLK_PORT
set_dont_touch_network my_clock
set_clock_uncertainty $CLK_SKEW [get_clocks my_clock]

set_output_delay $OUTPUT_DELAY -clock my_clock [all_outputs]

#  Area Constraint
set_max_area $MAX_AREA

set_driving_cell -library gscl45nm -lib_cell $DRIVE_CELL -pin $DRIVE_PIN -multiply_by 2 [all_inputs]
set_drive .25 {clk}

set_load  [expr 10 * $MAX_OUTPUT_LOAD] [all_outputs]

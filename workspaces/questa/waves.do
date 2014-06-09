configure wave -signalnamewidth 1

add wave -position end  sim:/testbench/clk
add wave -position end  sim:/testbench/reset
add wave -position end  sim:/testbench/fifoInterface.writeRequest
add wave -position end  sim:/testbench/fifoInterface.readRequest
add wave -position end  sim:/testbench/memoryDepth
add wave -position end -hexadecimal -expand sim:/testbench/fifoInterface.writeRequest
#add wave -position end -hexadecimal -expand sim:/testbench/duv/i_writeRequest
add wave -position end -hexadecimal sim:/testbench/fifoInterface.writeResponse
add wave -position end -hexadecimal sim:/testbench/fifoInterface.readRequest
add wave -position end -hexadecimal sim:/testbench/fifoInterface.readResponse
add wave -position end -hexadecimal sim:/testbench/duv/ptr
add wave -position end -decimal sim:/testbench/duv/fifoInterface.pctFilled
add wave -position end  sim:/testbench/duv/write
add wave -position end  sim:/testbench/duv/read
add wave -position end  sim:/testbench/duv/fifoInterface.nearFull
add wave -position end  sim:/testbench/duv/fifoInterface.full
add wave -position end  sim:/testbench/duv/fifoInterface.nearEmpty
add wave -position end  sim:/testbench/duv/fifoInterface.empty
add wave -position end  sim:/testbench/duv/fifoInterface.overflow
add wave -position end  sim:/testbench/duv/fifoInterface.underflow
add wave -position end -hexadecimal sim:/testbench/duv/memory

run 80 ns;

wave zoomfull
#.wave.tree zoomfull	# with some versions of ModelSim

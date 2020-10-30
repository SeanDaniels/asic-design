# vsim work.tb_top
# add wave -position insertpoint  \
# sim:/tb_top/clk
# add wave -position insertpoint  \
# sim:/tb_top/dut/reset_b
# add wave -position insertpoint  \
# sim:/tb_top/dut/dut_run
# add wave -position insertpoint  \
# sim:/tb_top/dut/dut_busy
# add wave -position insertpoint  \
# sim:/tb_top/dut/dut_sram_write_address
# add wave -position insertpoint  \
# sim:/tb_top/dut/dut_sram_write_data
# add wave -position insertpoint  \
# sim:/tb_top/dut/dut_sram_read_address
# add wave -position insertpoint  \
# sim:/tb_top/dut/dut_wmem_read_address
# add wave -position insertpoint  \
# sim:/tb_top/dut/wmem_dut_read_data
# add wave -position insertpoint  \
# sim:/tb_top/dut/sram_dut_read_data
# add wave -position insertpoint  \
# sim:/tb_top/dut/input_value
# add wave -position insertpoint  \
# sim:/tb_top/dut/weight_value
# add wave -position insertpoint  \
# sim:/tb_top/dut/number_of_inputs \
# sim:/tb_top/dut/number_of_weights \
# sim:/tb_top/dut/number_of_input_reads \
# sim:/tb_top/dut/number_of_weight_reads
run 600ps
run

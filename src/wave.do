onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/clk
add wave -noupdate -radix decimal /tb_top/dut/reset_b
add wave -noupdate -radix decimal /tb_top/dut/dut_run
add wave -noupdate /tb_top/dut/dut_busy
add wave -noupdate /tb_top/dut/dut_sram_write_address
add wave -noupdate -radix decimal /tb_top/dut/dut_sram_write_data
add wave -noupdate -radix decimal /tb_top/dut/dut_sram_read_address
add wave -noupdate -radix decimal /tb_top/dut/dut_wmem_read_address
add wave -noupdate -radix decimal /tb_top/dut/wmem_dut_read_data
add wave -noupdate -radix decimal /tb_top/dut/sram_dut_read_data
add wave -noupdate -radix decimal /tb_top/dut/input_value
add wave -noupdate -radix decimal /tb_top/dut/weight_value
add wave -noupdate -radix decimal /tb_top/dut/number_of_inputs
add wave -noupdate -radix decimal /tb_top/dut/number_of_weights
add wave -noupdate -radix decimal /tb_top/dut/number_of_input_reads
add wave -noupdate /tb_top/dut/number_of_weight_reads
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {501 ps} {627 ps}

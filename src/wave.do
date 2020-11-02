onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/clk
add wave -noupdate /tb_top/dut/main_state_machine_current_state
add wave -noupdate /tb_top/dut/secondary_state_machine_current_state
add wave -noupdate /tb_top/dut/dut_wmem_read_address
add wave -noupdate /tb_top/dut/wmem_dut_read_data
add wave -noupdate /tb_top/dut/sram_dut_read_data
add wave -noupdate /tb_top/dut/dut_sram_read_address
add wave -noupdate /tb_top/dut/input_input
add wave -noupdate /tb_top/dut/size_of_inputs
add wave -noupdate /tb_top/dut/size_of_weights
add wave -noupdate /tb_top/dut/number_of_inputs
add wave -noupdate /tb_top/dut/number_of_weights
add wave -noupdate /tb_top/dut/number_of_weight_reads
add wave -noupdate /tb_top/dut/input_read_complete_signal
add wave -noupdate /tb_top/dut/number_of_input_reads
add wave -noupdate /tb_top/dut/number_of_input_reads_needed
add wave -noupdate /tb_top/dut/weight_matrix_dimensions
add wave -noupdate /tb_top/dut/idle_process_signal
add wave -noupdate /tb_top/dut/weight_input
add wave -noupdate /tb_top/dut/current_weight_bits
add wave -noupdate /tb_top/dut/start_mac
add wave -noupdate /tb_top/dut/input_coef
add wave -noupdate /tb_top/dut/accumulated_inputs
add wave -noupdate /tb_top/dut/weight_coef
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {778 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 310
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
WaveRestoreZoom {607 ps} {832 ps}

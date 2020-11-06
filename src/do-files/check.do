onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/clk
add wave -noupdate /tb_top/dut/reset_b
add wave -noupdate /tb_top/dut/dut_run
add wave -noupdate /tb_top/dut/dut_busy
add wave -noupdate -expand -group {State Machines} /tb_top/dut/main_state_machine_current_state
add wave -noupdate -expand -group {State Machines} /tb_top/dut/secondary_state_machine_current_state
add wave -noupdate -expand -group {Input/Weight Read Value} /tb_top/dut/input_input
add wave -noupdate -expand -group {Input/Weight Read Value} /tb_top/dut/weight_input
add wave -noupdate -expand -group Setup /tb_top/dut/setup_count
add wave -noupdate -expand -group Setup /tb_top/dut/setup_done
add wave -noupdate -expand -group Setup /tb_top/dut/size_of_inputs
add wave -noupdate -expand -group Setup /tb_top/dut/size_of_weights
add wave -noupdate -expand -group Setup /tb_top/dut/number_of_inputs
add wave -noupdate -expand -group Setup /tb_top/dut/number_of_weights
add wave -noupdate -expand -group Setup /tb_top/dut/number_of_input_reads
add wave -noupdate -expand -group Setup /tb_top/dut/weight_bits_per_row
add wave -noupdate -expand -group Setup /tb_top/dut/number_of_input_reads_needed
add wave -noupdate -expand -group Setup /tb_top/dut/get_weight_matrix_dimensions
add wave -noupdate -expand -group Setup /tb_top/dut/weight_matrix_dimensions
add wave -noupdate /tb_top/dut/dut_sram_write_address
add wave -noupdate /tb_top/dut/dut_sram_write_data
add wave -noupdate /tb_top/dut/dut_sram_write_enable
add wave -noupdate /tb_top/dut/dut_sram_read_address
add wave -noupdate /tb_top/dut/dut_wmem_read_address
add wave -noupdate /tb_top/dut/wmem_dut_read_data
add wave -noupdate /tb_top/dut/sram_dut_read_data
add wave -noupdate -group Flags /tb_top/dut/processing_done
add wave -noupdate -group Flags /tb_top/dut/input_read_complete_signal
add wave -noupdate -group Flags /tb_top/dut/weight_read_complete_signal
add wave -noupdate -group Flags /tb_top/dut/process_flag
add wave -noupdate -group Flags /tb_top/dut/write_flag
add wave -noupdate -group Flags /tb_top/dut/all_done
add wave -noupdate /tb_top/dut/number_of_weight_reads
add wave -noupdate /tb_top/dut/next_x_address
add wave -noupdate /tb_top/dut/next_y_address
add wave -noupdate /tb_top/dut/number_of_weight_reads_needed
add wave -noupdate /tb_top/dut/accumulated_inputs
add wave -noupdate -group Multiplication /tb_top/dut/weight_coef
add wave -noupdate -group Multiplication /tb_top/dut/input_coef
add wave -noupdate -group Multiplication /tb_top/dut/product
add wave -noupdate -group Multiplication /tb_top/dut/accumulation
add wave -noupdate -group Multiplication /tb_top/dut/weight_row_done
add wave -noupdate -group Multiplication /tb_top/dut/get_next_weight_read
add wave -noupdate -group Multiplication /tb_top/dut/current_weight_bits
add wave -noupdate -group Multiplication /tb_top/dut/weight_bits_read
add wave -noupdate -group Multiplication /tb_top/dut/mac_count
add wave -noupdate -group Multiplication /tb_top/dut/saved_weight_bit_start_index
add wave -noupdate /tb_top/dut/value_to_write_to_golden_output
add wave -noupdate /tb_top/dut/pause_flag
add wave -noupdate /tb_top/dut/row_weight_bits_read
add wave -noupdate /tb_top/dut/weight_coef_bits_read
add wave -noupdate /tb_top/dut/total_weight_bits_read
add wave -noupdate /tb_top/dut/number_of_rows_accumulated
add wave -noupdate /tb_top/dut/matrix_elements_needed
add wave -noupdate /tb_top/dut/number_of_mac_runs
add wave -noupdate /tb_top/dut/mac_input_address
add wave -noupdate /tb_top/dut/weight_bit_start_index
add wave -noupdate /tb_top/dut/result_address
add wave -noupdate /tb_top/dut/clear_accumulation
add wave -noupdate /tb_top/dut/number_of_accumulated_input_bits
add wave -noupdate /tb_top/dut/update_read_address
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 272
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
WaveRestoreZoom {576 ps} {617 ps}

module project(
               // control signals
               input wire        clk, // clock signal
               input             reset_b, // reset signal
               input wire        dut_run, // signal for communication between sram and dut, this signal low when reading
               output reg        dut_busy, // this signal high when computing

               // input and output sram
               output reg [11:0] dut_sram_write_address,
               output reg [15:0] dut_sram_write_data,
               output reg        dut_sram_write_enable,
               output reg [11:0] dut_sram_read_address,
               output reg [11:0] dut_wmem_read_address,
               input wire [15:0] wmem_dut_read_data,
               input reg [15:0]  sram_dut_read_data
               );

   reg                           processing_done = 1'b0;
   reg [2:0]                     main_state_machine_current_state, main_state_machine_next_state;


   reg [15:0]                    input_input = 16'd0, weight_input = 16'd0, size_of_inputs = 16'b0, size_of_weights = 16'b0, number_of_inputs = 16'b0;

   reg [15:0]                    next_x_address = 0, next_y_address = 0;
   reg [15:0]                    number_of_input_reads_needed = 16'd0;
   reg [1023:0]                   accumulated_inputs = 1024'd0;
   reg [15:0]                    weight_coef = 16'b0, input_coef = 16'b0;
   reg [34:0]                    product = 35'd0, accumulation = 35'b0, value_to_write_to_golden_output = 35'b0;
   reg                           weight_row_done = 1'b0;
   reg [15:0]                        current_weight_bits = 16'b0;
   reg [255:0]                       weight_bits_per_row = 256'b0,weight_bits_read = 256'b0;
   reg [15:0]                        weight_matrix_dimensions = 16'b0;
   reg [11:0]                         row_weight_bits_read = 12'b0, weight_coef_bits_read = 12'b0;
   reg [15:0]                          number_of_rows_accumulated = 16'b0, matrix_elements_needed = 16'b0;
   reg [4:0]                           elements_per_read = 5'b0, matrix_complete = 5'b0;
   integer                                   number_of_mac_runs = 0;
   integer                                   mac_input_address = 0;
   integer                                   weight_bit_start_index = 0, saved_weight_bit_start_index = 0;
   reg [11:0]                                result_address = 12'd0;
   reg                                       write_flag = 1'b0;
   reg clear_accumulation = 1'b0;

   reg [15:0]                                number_of_accumulated_input_bits = 16'b0;
   reg                                            setup_done = 1'b0;
   reg [2:0]                                      setup_count = 3'b0, mac_count = 3'b0;

















   // top level sm
   localparam RESET_WAIT = 3'b000; // state 0
   localparam RUN_WAIT = 3'b001; // state 1
   localparam SETUP = 3'b010; //state 2
   localparam PROCESS = 3'b011; //state 2
   localparam CHECK_DONE = 3'b100;
   localparam SYNC = 3'b011; // state 3
   localparam MAIN_STATE_END = 3'b101; // state 5
   //interior sm states
   localparam SYNC_READ = 4'b0000;
   localparam READ_ONE = 4'b0001;
   localparam READ_TWO = 4'b0010;
   localparam COLLECT_INPUTS = 4'b0011;
   localparam MAC = 4'b0100;
   localparam WRITE_RESULT = 4'b0101;
   localparam IDLE = 4'b0111;


   always@(posedge clk)
     begin
        main_state_machine_current_state <= (!reset_b) ? RESET_WAIT : main_state_machine_next_state;
     end

   /* Weights[n][n] * input[n][1]    */
   /* Get the single column of inputs    */
   /* Determine number of bits per row    */
   /* get *a* single row of weights
   /* test case 0 weights: 16 2 bit entries    */
   /* weights[2][8], single entry spans from weight[bitStart][bitStart+2]    */
   /* single row spans row complete when bitStart = 16    */
   /* test case 0 inputs: 16 entries, 8 bits per entry    */
   /* single entry spans from input[bitStart:bitStart+7]    */
   /* test case 0 outputs: sum += weight[bitstart:bitStart+size-1]*input[bitStart:bitStart+size-1]    */
   /* weightBitStart = bitStart+size    */
   /* weightRowComplete if(bitStart = 16)    */
   /* if(rowComplete), write result
    */
   always@(*)
     begin
        case(main_state_machine_current_state)
          RESET_WAIT:begin
             // signal used to control reading from memory
             dut_busy = 1'b0;
             main_state_machine_next_state = RUN_WAIT;
             dut_sram_read_address = 0;
             dut_wmem_read_address = 0;
             result_address = 0;
             dut_sram_write_address = 0;
          end
          RUN_WAIT: begin
             if(dut_run) // Message sent from top level module to indicate process start
               begin
                  dut_busy = 1'b1;
                  main_state_machine_next_state = SETUP;
               end
             else
               begin
                  main_state_machine_next_state = RUN_WAIT;
                  //dut_busy = 1'b0;
               end
          end
          SETUP: begin
             dut_busy = 1'b1;
             if(setup_done == 1'b1) begin
                main_state_machine_next_state = PROCESS;
             end
             if(setup_done == 1'b0) begin
                main_state_machine_next_state = SETUP;
                end
             end
          PROCESS: begin
             dut_busy = 1'b1;
             if(processing_done == 1'b1) begin
                main_state_machine_next_state = CHECK_DONE;
             end
             if(processing_done == 1'b0)begin
                main_state_machine_next_state = PROCESS;
                end
          end
          CHECK_DONE: begin
             if(input_input == 16'hFF)begin
                main_state_machine_next_state = MAIN_STATE_END;
             end
             else begin
                dut_busy = 1'b1;
                main_state_machine_next_state = SETUP;
             end
          end
          MAIN_STATE_END: begin
             dut_busy = 1'b0;
             main_state_machine_next_state = RESET_WAIT;
          end
          default: begin
             main_state_machine_next_state = RUN_WAIT;
             dut_busy = 1'b1;
          end
        endcase
     end


   always@(posedge clk)
     begin
        dut_sram_write_enable <= 1'b0;
        case(main_state_machine_current_state)
          RESET_WAIT: begin
             setup_count <= 0;
             next_x_address <= dut_sram_read_address;
             next_y_address <= dut_wmem_read_address;
             end
          SETUP: begin
             next_x_address <= next_x_address;
             next_y_address <= next_y_address;
             setup_count <= setup_count + 3'b1;
             setup_done <= 1'b0;
             if(setup_count == 3'b001)begin
                weight_coef <= 0;
                input_coef <= 0;
                weight_coef_bits_read <= 0;
                row_weight_bits_read <= 0;
                number_of_rows_accumulated <= 0;
                mac_count <= 0;
                next_x_address <= dut_sram_read_address + 1'b1;
                next_y_address <= dut_wmem_read_address + 1'b1;
                accumulated_inputs <= 0;
             end
             if(setup_count == 3'b010)begin
                number_of_inputs <= input_input;
                weight_matrix_dimensions <= weight_input;
                next_x_address <= dut_sram_read_address + 1'b1;
                next_y_address <= dut_wmem_read_address + 1'b1;
             end
             if(setup_count == 3'b011)begin
                size_of_inputs<= input_input;
                size_of_weights<= weight_input;
                next_x_address <= dut_sram_read_address + 1'b1;
             end
             if(setup_count == 3'b100)begin
                next_x_address <= dut_sram_read_address + 1'b1;
                weight_bits_per_row <= size_of_weights * weight_matrix_dimensions;
                matrix_elements_needed <= weight_matrix_dimensions * weight_matrix_dimensions;
                number_of_accumulated_input_bits <= size_of_inputs * number_of_inputs - 1'b1;
                if(size_of_inputs == 2)begin
                   number_of_input_reads_needed <= (number_of_inputs >> 3) - 2;
                   accumulated_inputs <= {accumulated_inputs, input_input[1:0], input_input[3:2], input_input[5:4], input_input[7:6], input_input[9:8], input_input[11:10], input_input[13:12], input_input[15:14]};
                end
                if(size_of_inputs == 4)begin
                   number_of_input_reads_needed <= (number_of_inputs >> 2) - 2;
                   accumulated_inputs <= {accumulated_inputs, input_input[3:0], input_input[7:4], input_input[11:8], input_input[15:12]};
                end
                if(size_of_inputs == 8)begin
                   number_of_input_reads_needed <= (number_of_inputs >> 1) - 2;
                   accumulated_inputs <= {accumulated_inputs, input_input[7:0], input_input[15:8]};
                end
                if(size_of_inputs == 16)begin
                   number_of_input_reads_needed <= number_of_inputs - 1;
                end
             end
             if(setup_count == 3'b101)begin
                setup_count <= setup_count + 1'b1;
                if(size_of_inputs == 8)begin
                   accumulated_inputs <= {accumulated_inputs, input_input[7:0], input_input[15:8]};
                end
                if(size_of_inputs == 4)begin
                   accumulated_inputs <= {accumulated_inputs, input_input[3:0], input_input[7:4], input_input[11:8], input_input[15:12]};
                end
                if(size_of_inputs == 2)begin
                   accumulated_inputs <= {accumulated_inputs, input_input[1:0], input_input[3:2], input_input[5:4], input_input[7:6], input_input[9:8], input_input[11:10], input_input[13:12], input_input[15:14]};
                end
                if(number_of_input_reads_needed > 0)begin
                   number_of_input_reads_needed <= number_of_input_reads_needed - 1'b1;
                   setup_count <= setup_count;
                   next_x_address <= dut_sram_read_address + 1'b1;
                end
                else begin
                   setup_done <= 1'b1;
                end
             end
          end
          PROCESS: begin
             mac_count <= mac_count + 1;
             processing_done <= 1'b0;
             if(mac_count==3'b000) begin
                current_weight_bits <= weight_input;
                number_of_mac_runs <= 0;
                weight_row_done <= 1'b0;
                next_y_address <= dut_wmem_read_address + 1'b1;
                if(size_of_weights==2)begin
                   weight_bit_start_index = 1;
                   elements_per_read = 5'd8;
                end
                if(size_of_weights==4)begin
                   weight_bit_start_index = 3;
                   elements_per_read = 5'd4;
                end
                if(size_of_weights==8)begin
                   weight_bit_start_index = 7;
                   elements_per_read = 5'd2;
                end
                if(size_of_weights==16)begin
                   weight_bit_start_index = 15;
                end
                saved_weight_bit_start_index = weight_bit_start_index;
                mac_input_address <= number_of_accumulated_input_bits;
             end
             if(mac_count == 3'b011) begin
                mac_count <= mac_count;
                if (number_of_mac_runs == (weight_matrix_dimensions - 1'b1))begin
                   weight_row_done <= 1'b1;
                end
                else begin
                   weight_row_done <= 1'b0;
                end
                case(weight_row_done)
                  1:begin
                     weight_row_done <= 1'b0;
                     number_of_rows_accumulated <= number_of_rows_accumulated + 1'b1;
                     value_to_write_to_golden_output <= accumulation;
                     accumulation <= 0;
                     write_flag <=1;
                     if(number_of_rows_accumulated==(weight_matrix_dimensions - 1'b1))begin
                        matrix_complete <= matrix_complete + 5'b1;
                        processing_done <= 1'b1;
                        end
                     if(number_of_rows_accumulated<weight_matrix_dimensions)begin
                        number_of_mac_runs <= 0;
                        end
                  end
                  0: begin
                     // logic for indexing input bits
                     if(size_of_inputs==2)begin
                        mac_input_address = number_of_accumulated_input_bits - 2*number_of_mac_runs;
                        input_coef = {{14{1'b0}},accumulated_inputs[mac_input_address-:2]};
                     end
                     if(size_of_inputs==4)begin
                        mac_input_address = number_of_accumulated_input_bits - 4*number_of_mac_runs;
                        input_coef = {{12{1'b0}},accumulated_inputs[mac_input_address-:4]};
                     end
                     if(size_of_inputs==8)begin
                        mac_input_address = number_of_accumulated_input_bits - 8*number_of_mac_runs;
                        input_coef = {{8{1'b0}},accumulated_inputs[mac_input_address-:8]};
                     end
                     if(size_of_inputs==16)begin
                        mac_input_address = number_of_accumulated_input_bits - 16*number_of_mac_runs;
                        input_coef = accumulated_inputs[mac_input_address-:16];
                     end
                     // logic for indexing bits for weight coefficient
                     if(size_of_weights==2)begin
                        weight_coef = {{14{1'b0}},current_weight_bits[weight_bit_start_index-:2]};
                        weight_bit_start_index = weight_bit_start_index + 2;
                        row_weight_bits_read = row_weight_bits_read + 2;
                        weight_coef_bits_read = weight_coef_bits_read + 2;
                     end
                     if(size_of_weights==4)begin
                        weight_coef = {{12{1'b0}},current_weight_bits[weight_bit_start_index-:4]};
                        weight_bit_start_index = weight_bit_start_index + 4;
                        row_weight_bits_read = row_weight_bits_read + 4;
                        weight_coef_bits_read = weight_coef_bits_read + 4;
                     end
                     if(size_of_weights==8)begin
                        weight_coef = {{8{1'b0}},current_weight_bits[weight_bit_start_index-:8]};
                        weight_bit_start_index = weight_bit_start_index + 8;
                        row_weight_bits_read = row_weight_bits_read + 8;
                        weight_coef_bits_read = weight_coef_bits_read + 8;
                     end
                     if(size_of_weights==16) begin
                        weight_coef = current_weight_bits[weight_bit_start_index-:16];
                        weight_bit_start_index = weight_bit_start_index + 16;
                        row_weight_bits_read = row_weight_bits_read + 16;
                        weight_coef_bits_read = weight_coef_bits_read + 16;
                     end

                     //$display("Input coef.: %d  Weight coef. %d",input_coef, weight_coef);

                     // ** get product ** //
                     //temp_product = input_coef * weight_coef;
                     accumulation <= accumulation + input_coef*weight_coef;
                     //product <= input_coef * weight_coef;

                     if(weight_coef_bits_read==12'd16)begin
                        current_weight_bits <= weight_input;
                        weight_coef_bits_read <= 0;
                        weight_bit_start_index = saved_weight_bit_start_index;
                        matrix_elements_needed <= matrix_elements_needed - elements_per_read;
                        if(matrix_elements_needed>elements_per_read)begin
                           next_y_address <= dut_wmem_read_address + 1;
                        end
                     end
                     if(write_flag == 1'b1)begin
                        write_flag <= 1'b0;
                        dut_sram_write_data <= 1'b1;
                        dut_sram_write_enable <= 1'b1;
                     end
                     if(write_flag == 1'b1)begin
                        write_flag <= 1'b0;
                        dut_sram_write_data <= value_to_write_to_golden_output;
                        dut_sram_write_enable <= 1'b1;
                        dut_sram_write_address <= result_address;
                        result_address <= result_address + 12'd1;
                     end
                     if(write_flag == 1'b0)begin
                        dut_sram_write_enable <= 1'b0;
                        dut_sram_write_data <= 0;
                        result_address <= result_address;
                     end
                     number_of_mac_runs <= number_of_mac_runs + 1;

                  end
                endcase
             end
          end
          endcase
     end

   always@(*)
     begin
        weight_input = wmem_dut_read_data;
        input_input = sram_dut_read_data;
        dut_sram_read_address = next_x_address;
        dut_wmem_read_address = next_y_address;
        if(clear_accumulation == 1'b1)begin
           clear_accumulation = 1'b0;
           product = 0;
           accumulation = 0;
        end
        else begin
           accumulation = accumulation + product;
        end
     end


endmodule

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

   reg                           processing_done = 1'b0, input_read_complete_signal = 1'b0, weight_read_complete_signal, start_matrix_mult_signal = 1'b0;
   reg [2:0]                     main_state_machine_current_state, main_state_machine_next_state;
   reg [3:0]                     secondary_state_machine_current_state, secondary_state_machine_next_state = 4'b0111, secondary_state_machine_return_state = 4'b0111;


   reg [15:0]                    input_input = 16'd0, weight_input = 16'd0, size_of_inputs = 16'b0, size_of_weights = 16'b0, number_of_inputs = 16'b0, number_of_weights = 16'b0;
 //  reg [11:0]                    input_sram_addr, weight_sram_addr;
//   reg [15:0]                    counter = 16'b0;
 //  reg [5:0]                     sram_read_count = 6'b0;
   reg [15:0]                    number_of_input_reads = 0, number_of_weight_reads = 0;
   reg [15:0]                    number_of_input_reads_needed = 16'd0;
   reg [127:0]                   accumulated_inputs = 128'd0;
   reg [15:0]                    weight_coef = 16'b0, input_coef = 16'b0;
   reg                           process_flag;
   reg [34:0]                        product = 35'd0, accumulation = 35'b0, mult;
   reg                               read_weight = 1'b0;
   reg                               weight_row_done = 1'b0, pause_flag = 1'b0;
   reg [15:0]                        current_weight_bits = 16'b0;
   reg [255:0]                       weight_bits_per_row = 256'b0,weight_bits_read = 256'b0;
   reg                               processing_flag = 1'b0;
   reg                               get_number_inputs = 1'b0;
   reg                               get_weight_matrix_dimensions = 1'b0;
   reg [15:0]                        weight_matrix_dimensions = 16'b0;
   reg                               get_size_inputs = 1'b0;
   reg                               get_size_weights = 1'b0;
   reg                               start_mac = 1'b0;
   reg                               get_next_weight_read = 1'b0;
   reg [5:0]                         row_weight_bits_read = 6'd16;
   reg [255:0]                         total_weight_bits_read = 256'd0;
   reg                                 idle_process_signal = 1'b0;
   reg [2:0]                                 sync_flag = 3'd0;










   // top level sm
   localparam RESET_WAIT = 3'b000; // state 0
   localparam RUN_WAIT = 3'b001; // state 1
   localparam PROCESS = 3'b010; //state 2
   localparam SYNC = 3'b011; // state 3
   localparam MAIN_STATE_END = 3'b101; // state 5
   //interior sm states
   localparam SYNC_READ = 4'b0000;
   localparam READ_ONE = 4'b0001;
   localparam READ_TWO = 4'b0010;
   localparam COLLECT_INPUTS = 4'b0011;
   localparam MAC = 4'b0100;
   localparam IDLE = 4'b0111;


   always@(posedge clk)
     begin
        main_state_machine_current_state <= (!reset_b) ? RESET_WAIT : main_state_machine_next_state;
        secondary_state_machine_current_state <= secondary_state_machine_next_state;
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
          end
          RUN_WAIT: begin
             if(dut_run) // Message sent from top level module to indicate process start
               begin
                  dut_busy = 1'b1;
                  process_flag = 1'b0;
                  main_state_machine_next_state = PROCESS;
               end
             else
               begin
                  main_state_machine_next_state = RUN_WAIT;
                  dut_busy = 1'b0;
               end
          end
          PROCESS: begin
             dut_busy = 1'b1;
             if(processing_done) main_state_machine_next_state = MAIN_STATE_END;
             else
               begin
                  main_state_machine_next_state = PROCESS;
                  if(process_flag == 1'b0)begin
                     process_flag = 1'b1;
                     secondary_state_machine_next_state = SYNC_READ;
                  end
                  else begin
                     secondary_state_machine_next_state = secondary_state_machine_current_state;
                     end
               end
          end
          default: begin
             main_state_machine_next_state = RESET_WAIT;
             dut_busy = 1'b0;
          end
        endcase
     end


   always@(posedge clk)
     begin
        dut_sram_write_enable <= 1'b0;
        idle_process_signal <= 1'b0;
        case(secondary_state_machine_current_state)
          SYNC_READ:
            begin
               if(sync_flag < 3'd2)begin
                  if(sync_flag == 3'd0)begin
                     number_of_input_reads <= number_of_input_reads;
                     number_of_weight_reads <= number_of_weight_reads;
                  end
                  sync_flag = sync_flag + 3'd1;
                  secondary_state_machine_next_state <= SYNC_READ;
               end
               else begin
                  sync_flag = 3'd0;
                  start_matrix_mult_signal <= 1'b0;
                  get_number_inputs <= 1'b1;
                  get_weight_matrix_dimensions <= 1'b1;
                  get_size_inputs <= 1'b1;
                  get_size_weights <= 1'b1;
                  secondary_state_machine_next_state <= READ_ONE;
               end
            end
          READ_ONE:begin
             if(get_number_inputs==1'b1)begin
                number_of_inputs <= input_input;
                $display("Number of inputs: %d", number_of_inputs);
                get_number_inputs <= 1'b0;
                $display("Current input read adress: %d", number_of_input_reads);
                number_of_input_reads <= number_of_input_reads + 1'b1;
                $display("Next input read adress: %d", number_of_input_reads);
             end
             if(get_weight_matrix_dimensions==1'b1)begin
                weight_matrix_dimensions <= weight_input;
                get_weight_matrix_dimensions <= 1'b0;
                $display("Current weight read adress: %d", number_of_weight_reads);
                number_of_weight_reads <= number_of_weight_reads + 1'b1;
                $display("Next weight read adress: %d", number_of_weight_reads);
             end
             secondary_state_machine_next_state <= READ_TWO;
          end
          READ_TWO: begin
             if(get_size_inputs==1'b1)begin
                size_of_inputs = input_input;
                $display("Size of inputs: %d bits", size_of_inputs);
                get_size_inputs = 1'b0;
                case(size_of_inputs)
                  2:begin
                     number_of_input_reads_needed = (number_of_inputs >> 3);
                  end
                  4:begin
                     number_of_input_reads_needed = (number_of_inputs >> 2);
                  end
                  8:begin
                     number_of_input_reads_needed = (number_of_inputs >> 1);
                     $display("Number of memory reads: %d", (number_of_inputs >> 1));
                  end
                  default:begin
                     number_of_input_reads_needed = size_of_inputs;
                  end
                endcase
                $display("Current input read adress: %d", number_of_input_reads);
                number_of_input_reads <= number_of_input_reads + 1'b1;
                $display("Next input read adress: %d", number_of_input_reads);
             end
             if(get_size_weights == 1'b1)begin
                size_of_weights=weight_input;
                $display("Size of inputs: %d bits", size_of_weights);
                get_size_weights = 1'b0;
                weight_bits_per_row = size_of_weights * weight_matrix_dimensions;
                $display("Current weight read adress: %d", number_of_weight_reads);
                number_of_weight_reads <= number_of_weight_reads+1'b1;
                $display("Next weight read adress: %d", number_of_weight_reads);
             end
             secondary_state_machine_next_state <= COLLECT_INPUTS;
             sync_flag = 3'd1;
          end
          COLLECT_INPUTS: begin
             $display("Number of memory reads: %d", number_of_input_reads);
             $display("Number of memory reads needed: %d", number_of_input_reads_needed);
             if(sync_flag == 3'd1)begin
                sync_flag = 3'd0;
                number_of_input_reads <= number_of_input_reads + 1'b1;
                secondary_state_machine_next_state <= COLLECT_INPUTS;
                end
             else begin
                if(number_of_input_reads>number_of_input_reads_needed)begin
                   input_read_complete_signal = 1'b1;
                   secondary_state_machine_next_state = MAC;
                   total_weight_bits_read = 256'd0;
                   if (size_of_weights == 2)begin
                      current_weight_bits = {weight_input[1],weight_input[0], weight_input[3], weight_input[2], weight_input[5], weight_input[4], weight_input[7], weight_input[6], weight_input[9], weight_input[8], weight_input[11], weight_input[10], weight_input[13], weight_input[12], weight_input[15], weight_input[14]};
                      end
                   start_mac = 1'b1;
                   accumulated_inputs <= {accumulated_inputs, input_input[7:0], input_input[15:8]};
                end
                else begin
                   start_mac = 1'b0;
                   secondary_state_machine_next_state <= COLLECT_INPUTS;
                   accumulated_inputs <= {accumulated_inputs, input_input[7:0], input_input[15:8]};
                   number_of_input_reads <= number_of_input_reads + 1'b1;
                   // $display("Adding Current input read adress: %d", number_of_input_reads);
                   // $display("Current input read adress: %d", number_of_input_reads);
                   // $display("Next input read adress: %d", number_of_input_reads);
                end
             end
          end
          MAC: begin
             if(start_mac==1'b1)begin
                $display("Current weight bits: %d", current_weight_bits);
                get_next_weight_read = 1'b1;
                start_mac = 1'b0;
                row_weight_bits_read = 0;
                number_of_weight_reads <= number_of_weight_reads + 1'b1;
                product = 35'b0;
             end
             else begin
                case(size_of_inputs)
                  2:begin
                     input_coef <= {{14{1'b0}},accumulated_inputs[127-:2]};
                     accumulated_inputs <= accumulated_inputs << 2;
                  end
                  4:begin
                     input_coef <= {{12{1'b0}},accumulated_inputs[127-:4]};
                     accumulated_inputs <= accumulated_inputs << 4;
                  end
                  8:begin
                     input_coef = {{8{1'b0}},accumulated_inputs[127-:8]};
                     accumulated_inputs = accumulated_inputs << 8;
                  end
                  default: begin
                     input_coef <= accumulated_inputs[127-:16];
                     accumulated_inputs <= accumulated_inputs << 16;
                  end
                endcase
                case(size_of_weights)
                  2:begin
                     weight_coef = {{14{1'b0}},current_weight_bits[15-:2]};
                     current_weight_bits = current_weight_bits << 2;
                     row_weight_bits_read = row_weight_bits_read + 2;
                     total_weight_bits_read = total_weight_bits_read + 2;
                  end
                  4:begin
                     weight_coef <= {{12{1'b0}},current_weight_bits[15-:4]};
                     current_weight_bits <= current_weight_bits << 4;
                     row_weight_bits_read <= row_weight_bits_read + 4;
                     total_weight_bits_read <= total_weight_bits_read + 4;
                  end
                  8:begin
                     weight_coef <= {{8{1'b0}},current_weight_bits[15-:8]};
                     current_weight_bits <= current_weight_bits << 8;
                     row_weight_bits_read <= row_weight_bits_read + 8;
                     total_weight_bits_read <= total_weight_bits_read + 8;
                  end
                  default: begin
                     weight_coef <= current_weight_bits;
                     row_weight_bits_read <= row_weight_bits_read + 16;
                     total_weight_bits_read <= total_weight_bits_read + 16;
                  end
                endcase
                $display("Number of weight row bits read: %d", row_weight_bits_read);
                $display("Number of total row bits read: %d", total_weight_bits_read);
                $display("Mult value: %d", mult);
                product <= weight_coef*input_coef;
                if(row_weight_bits_read == 14)begin
                   get_next_weight_read = 1'b0;
                   current_weight_bits <= weight_input;
                   row_weight_bits_read <= 6'd0;
                   start_mac = 1'b1;
                end
                if(total_weight_bits_read==weight_bits_per_row)begin
                   weight_row_done = 1'b1;
                   total_weight_bits_read <= 256'd0;
                end
             end
          end
          IDLE: begin
             idle_process_signal <= 1'b1;
             secondary_state_machine_next_state <= IDLE;
             end
          default: begin
             idle_process_signal = 1'b1;
             secondary_state_machine_next_state <= IDLE;
          end
        endcase
     end

   always@(*)
     begin
        weight_input = wmem_dut_read_data;
        input_input = sram_dut_read_data;
        dut_sram_read_address = number_of_input_reads;
        dut_wmem_read_address = number_of_weight_reads;
        accumulation = accumulation + product;
     end


endmodule

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

   reg                           sram_read_flag, accumulation_complete, processing_done, input_read_complete_signal, weight_read_complete_signal, start_matrix_mult_signal = 1'b0;
   reg [2:0]                     main_state_machine_current_state, main_state_machine_next_state;
   reg [2:0]                     secondary_state_machine_current_state, secondary_state_machine_next_state;
   reg [15:0]                    input_input, weight_input;
   reg [11:0]                    input_sram_addr, weight_sram_addr;
   reg [15:0]                    counter = 16'b0;
   reg [5:0]                     sram_read_count = 6'b0;
//   reg [4:0]                     number_of_input_reads_needed, number_of_weight_reads_needed;
   reg [15:0]                    size_of_inputs = 16'b0, size_of_weights = 16'b0;
   reg [15:0]                    number_of_inputs = 16'b0, number_of_weights = 16'b0;
   reg [15:0]                    number_of_input_reads, number_of_weight_reads;
   reg [15:0]                    input_value, weight_value, number_of_input_reads_needed, number_of_weight_reads_needed;
   reg [128:0]                   accumulated_inputs = 128'b0, accumulated_weights = 128'b0;
   reg [7:0]                     mark_start = 8'b0;
   reg [5:0]                     mark_increment = 8'b0, mark_end = 8'b0;
   reg [15:0]                    x = 16'b0, y = 16'b0;


   // top level sm
   localparam RESET_WAIT = 3'b000; // state 0
   localparam RUN_WAIT = 3'b001; // state 1
   localparam PROCESS = 3'b010; //state 2
   localparam SYNC = 3'b011; // state 3
   localparam MAIN_STATE_END = 3'b101; // state 5
   //interior sm states
   localparam SYNC_READ = 3'b000;
   localparam GET_NUMBER_OF_INPUTS = 3'b001;
   localparam GET_SIZE_OF_INPUTS = 3'b010;
   localparam ACCUM = 3'b011;
   localparam DONE_ACCUM = 3'b100;

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
             secondary_state_machine_next_state = SYNC_READ;
          end
          RUN_WAIT: begin
             if(dut_run) // Message sent from top level module to indicate process start
               begin
                  dut_busy = 1'b1;
                  number_of_input_reads = 16'b0;
                  number_of_weight_reads = 16'b0;
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
        if(main_state_machine_current_state == PROCESS)
          begin
             // always reading in a 16 bit value, the only difference is how many mults we do
             // after all inputs are read we can start multing
             dut_sram_write_enable <= 1'b0;
             case(number_of_input_reads)
               0: begin
                  input_read_complete_signal <= 0;
                  weight_read_complete_signal <= 0;
                  mark_start <= 8'b0;
               end
               1: begin
                  number_of_inputs <= input_input;
                  number_of_weights <= weight_input;
               end
               2: begin
                  size_of_inputs <= input_input;
                  size_of_weights <= weight_input;
                  mark_end <= size_of_inputs[5:0];
               end
               3: begin
                  //determine how many reads are needed to get all inputs
                  case(size_of_inputs)
                    8:begin
                        number_of_input_reads_needed = number_of_inputs >> 1;
                     end
                    4:begin
                       number_of_input_reads_needed <= number_of_inputs >> 2;
                    end
                    2:begin
                       number_of_input_reads_needed <= number_of_inputs >> 3;
                       end
                    default: begin
                       number_of_input_reads_needed = number_of_inputs;
                    end
                  endcase
                  //determine how many reads are needed to get all weights
                  case(size_of_weights)
                    8: begin
                       number_of_weight_reads_needed = number_of_weights >> 1;
                    end
                    4: begin
                       number_of_weight_reads_needed = number_of_weights >> 2;
                    end
                    2:begin
                       number_of_weight_reads_needed = number_of_weights >> 3;
                    end
                    default: begin
                       number_of_weight_reads_needed = number_of_weights;
                    end
                  endcase
                  // sum number of reads needed with number reads that have already occured
                  // determine how many *more* reads are needed
                  number_of_weight_reads_needed <= number_of_weight_reads_needed + number_of_weight_reads;
                  number_of_input_reads_needed <= number_of_input_reads_needed + number_of_input_reads;
                  // regardless, store value
                  input_value <= input_input;
                  accumulated_inputs <= {accumulated_inputs, input_input};
                  weight_value <= weight_input;
                  accumulated_weights <= {accumulated_weights, weight_input};
               end
               default: begin
                  if(number_of_input_reads<number_of_input_reads_needed)begin
                     input_value <= input_input;
                     accumulated_inputs <= {accumulated_inputs, input_input};
                     mark_start <= mark_end;
                     mark_end <= mark_end + size_of_inputs;
                  end
                  else begin
                     input_read_complete_signal = 1'b1;
                  end
                  if(number_of_weight_reads<number_of_weight_reads_needed)begin
                     weight_value <= weight_input;
                     accumulated_weights <= {accumulated_weights, weight_input};
                     end
                  else begin
                     weight_read_complete_signal = 1'b1;
                     end
               end
             endcase
             if(input_read_complete_signal==1'b0)begin
                number_of_input_reads <= number_of_input_reads + 1'b1;
             end
             if(weight_read_complete_signal==1'b0)begin
                number_of_weight_reads <= number_of_weight_reads + 1'b1;
             end
             if(weight_read_complete_signal==1&input_read_complete_signal==1)begin
                start_matrix_mult_signal = 1'b1;
             end
          end
        end

   always@(*)
     begin
        input_input = sram_dut_read_data;
        weight_input = wmem_dut_read_data;
        dut_sram_read_address = number_of_input_reads;
        dut_wmem_read_address = number_of_weight_reads;
     end


endmodule

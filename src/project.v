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

   reg                           sram_read_flag, accumulation_complete, processing_done;
   reg [2:0]                     main_state_machine_current_state, main_state_machine_next_state;
   reg [1:0]                     secondary_state_machine_current_state, secondary_state_machine_next_state;
   reg [15:0]                    some_input;
   reg [11:0]                    sram_addr;
   reg [15:0]                    counter = 16'b0;
   reg [5:0]                     sram_read_count = 6'b0;
   reg [15:0]                    size_of_inputs = 16'b0;
   reg [15:0]                    number_of_inputs = 16'b0;
   reg [15:0]                    number_of_sram_reads;
   reg [15:0]                    x;





   // top level sm
   localparam RESET_WAIT = 3'b000; // state 0
   localparam RUN_WAIT = 3'b001; // state 1
   localparam PROCESS = 3'b010; //state 2
   localparam SYNC = 3'b011; // state 3
   localparam MAIN_STATE_END = 3'b101; // state 5
   //interior sm states
   localparam GET_NUMBER_OF_INPUTS = 2'b00;
   localparam GET_SIZE_OF_INPUTS = 2'b01;
   localparam ACCUM = 2'b10;
   localparam DONE_ACCUM = 2'b11;

   always@(posedge clk)
     begin
        main_state_machine_current_state <= (!reset_b) ? RESET_WAIT : main_state_machine_next_state;
        secondary_state_machine_current_state <= secondary_state_machine_next_state;
     end

   always@(*)
     begin
        case(main_state_machine_current_state)
          RESET_WAIT:begin
             // signal used to control reading from memory
             dut_busy = 1'b0;
             main_state_machine_next_state = RUN_WAIT;
             secondary_state_machine_next_state = GET_NUMBER_OF_INPUTS;
          end
          RUN_WAIT: begin
             if(dut_run) // Message sent from top level module to indicate process start
               begin
                  dut_busy = 1'b1;
                  number_of_sram_reads = 16'b0;
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
             dut_sram_write_enable <= 1'b0;
             case(secondary_state_machine_current_state)
               GET_NUMBER_OF_INPUTS:begin
                  number_of_inputs <= some_input;
                  secondary_state_machine_next_state <= GET_SIZE_OF_INPUTS;
                  number_of_sram_reads <= number_of_sram_reads + 1;
               end
               GET_SIZE_OF_INPUTS:begin
                  size_of_inputs <= some_input;
                  secondary_state_machine_next_state <= ACCUM;
                  number_of_sram_reads <= number_of_sram_reads + 1;
               end
               ACCUM: begin
                  if(number_of_sram_reads == 100) secondary_state_machine_next_state<=DONE_ACCUM;
                  x <= some_input;
                  number_of_sram_reads <= number_of_sram_reads + 1;
                  end
               DONE_ACCUM:begin
                  processing_done = 1'b1;
                end
             endcase
          end
     end

   always@(*)
     begin
        some_input = sram_dut_read_data;
        dut_sram_read_address = number_of_sram_reads;
     end


endmodule

module project(
               // control signals
               input wire        clk,
               input             reset_b,
               input wire        dut_run,
               output reg        dut_busy,
               // input and output sram
               input wire [15:0] dut_sram_read_data,
               output reg        dut_sram_write_enable,
               output reg [11:0] sram_dut_read_addr,
               output reg [11:0] dut_sram_write_addr,
               output reg [15:0] dut_sram_write_data
               );

   reg                           sram_read_flag;
   reg [1:0]                     next;
   reg [1:0]                     current;
   reg [15:0]                    some_input;
   reg [11:0]                    sram_addr;
   reg [12:0]                    counter = 13'b0;
   reg [5:0]                     sram_read_count = 5'b0;
   reg [15:0]                    x;




   localparam WAIT = 2'b00;
   localparam GET = 2'b01;
   localparam END = 2'b11;

   always@(posedge clk)
     begin
        current <= (!reset_b) ? WAIT : next;
     end

   always@(posedge clk)
     begin
        if(current == GET)
          begin
             sram_read_flag = 1'b1;
             dut_sram_write_enable <= 1'b0;
             sram_dut_read_addr <= sram_read_count;
             sram_read_count = sram_read_count + 1'b1;
             counter <= counter + 13'b1;
          end
        else if(sram_read_count > 5'd10)
          begin
             sram_read_count = 5'd0;
             sram_read_flag = 1'b0;
          end
     end

   always@(posedge clk)
     begin
        some_input <= dut_sram_read_data;
     end

   always@(*)
     begin
        sram_dut_read_addr = sram_addr;
        x = dut_sram_read_data;
        dut_sram_write_data = some_input;
     end

endmodule

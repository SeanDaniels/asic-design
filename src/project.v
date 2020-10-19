module project(
               input wire        clk,
               input             reset,
               input wire        dut_run,
               output reg        dut_busy,

               input wire [15:0] sram_read_data,
               output reg        sram_we,
               output reg [11:0] sram_read_addr,
               output reg [11:0] sram_write_addr,
               output reg [15:0] sram_write_data,
               );

   reg                           sram_read_flag;
   reg [1:0]                     next;
   reg [1:0]                     current;
   reg [15:0]                    some_input;
   reg [5:0]                     sram_read_count = 5'b0;



   localparam WAIT = 2'b00;
   localparam GET = 2'b01;
   localparam END = 2'b11;

   always@(posedge clk)
     begin
        current <= (!reset) ? WAIT : next;
     end

   always@(posedge clk)
     begin
        if(current == GET)
          begin
             sram_read_flag = 1'b1;
             sram_we <= 1'b0;
             sram_read_addr <= sram_read_count;
             sram_read_count = sram_read_count + 1'b1;
          end
        else if(sram_read_count > 5'd10)
          begin
             sram_read_count = 5'd0;
             sram_read_flag = 1'b0;
          end
     end

   always@(posedge clk)
     begin
        some_input <= sram_read_data;
     end

   always@(*)
     begin
        sram_read_addr = sram_addr;
        x = sram_read_data;
        sram_write_data = some_input;
     end

endmodule

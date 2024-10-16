`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2024 15:13:50
// Design Name: 
// Module Name: Hazard_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Hazard_unit(
 input rst,                   // Reset sinyali
   input MemReadM,              // Bellekten okuma (load) sinyali
   input Ready,                 // Bellekten okuma işleminin tamamlanıp tamamlanmadığını gösteren sinyal
   input RegWriteM,             // Memory aşamasında register yazma sinyali
   input RegWriteW,             // Write-back aşamasında register yazma sinyali
   input [4:0] Rd_M,            // Memory aşamasındaki hedef register (Rd)
   input [4:0] Rd_W,            // Write-back aşamasındaki hedef register (Rd)
   input [4:0] Rs1_D, Rs2_D,    // Decode aşamasındaki kaynak register'lar (Rs1 ve Rs2)
   input [4:0] Rs1_E, Rs2_E,    // Execute aşamasındaki kaynak register'lar (Rs1 ve Rs2)
   output reg [1:0] ForwardAE,  // Forwarding sinyali A (ALU'nun ilk girdisi)
   output reg [1:0] ForwardBE,  // Forwarding sinyali B (ALU'nun ikinci girdisi)
   output reg StallF,           // Fetch aşamasını durdurma sinyali
   output reg StallD            // Decode aşamasını durdurma sinyali

    );
    
    
    always @(*) begin
            // Varsayılan değerler
            StallF = 1'b0;
            StallD = 1'b0;
            ForwardAE = 2'b00;  // 00: register'dan gelen veri
            ForwardBE = 2'b00;  // 00: register'dan gelen veri
    
            // Reset durumu
            if (rst) begin
                StallF = 1'b0;
                StallD = 1'b0;
                ForwardAE = 2'b00;
                ForwardBE = 2'b00;
            end else begin
                // Load-use hazard: Load sonrası kullanıma yönelik stall
                if (MemReadM && ((Rd_M == Rs1_D) || (Rd_M == Rs2_D)) && !Ready) begin
                    // Eğer Memory aşamasında bir load komutu varsa ve Rs1 veya Rs2'de bağımlılık varsa
                    StallF = 1'b1;  // Fetch aşamasını durdur
                    StallD = 1'b1;  // Decode aşamasını durdur
                end
    
                // Forwarding Logic
                // ForwardAE (ALU'nun ilk girdisi için)
                if (RegWriteM && (Rd_M != 5'h00) && (Rd_M == Rs1_E)) begin
                    ForwardAE = 2'b10;  // Memory aşamasından ALU'ya forwarding
                end else if (RegWriteW && (Rd_W != 5'h00) && (Rd_W == Rs1_E)) begin
                    ForwardAE = 2'b01;  // Write-back aşamasından ALU'ya forwarding
                end
    
                // ForwardBE (ALU'nun ikinci girdisi için)
                if (RegWriteM && (Rd_M != 5'h00) && (Rd_M == Rs2_E)) begin
                    ForwardBE = 2'b10;  // Memory aşamasından ALU'ya forwarding
                end else if (RegWriteW && (Rd_W != 5'h00) && (Rd_W == Rs2_E)) begin
                    ForwardBE = 2'b01;  // Write-back aşamasından ALU'ya forwarding
                end
            end
        end

    
endmodule

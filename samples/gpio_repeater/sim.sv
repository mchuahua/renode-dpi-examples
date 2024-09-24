//
//  Copyright 2024 Antmicro
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

`timescale 1ns / 1ps

module repeater (
  input  wire [1:0] in,
  output wire [1:0] out
);
  assign out = in;
endmodule

module sim;
  parameter int ClockPeriod = 100;
  parameter int ReceiverPort = 0;
  parameter int SenderPort = 0;
  parameter string Address = "";

  logic clk = 1;

  logic [1:0] renode_inputs;
  logic [1:0] renode_outputs;

  renode #(
    .RenodeInputsCount(2),
    .RenodeOutputsCount(2)
  ) renode (
    .clk(clk),
    .renode_inputs(renode_inputs),
    .renode_outputs(renode_outputs)
  );

  initial begin
    if (Address != "") renode.connection.connect(ReceiverPort, SenderPort, Address);
    renode.reset();
  end

  always @(posedge clk) begin
    // The receive method blocks execution of the simulation.
    // It waits until a message is received from Renode
    renode.receive_and_handle_message();
    if (!renode.connection.is_connected()) $finish;
  end

  always #(ClockPeriod / 2) clk = ~clk;

  repeater repeater (
    .in(renode_outputs),
    .out(renode_inputs)
  );

endmodule
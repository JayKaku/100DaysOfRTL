// Scoreboard

`ifndef DAY14_SB
`define DAY14_SB

`include "day14_item.sv"
class day14_sb #(parameter NUM_PORTS=8);

  // Mailbox to get transaction from monitor
  // Used for sampling the outputs from RTL
  mailbox sb_mx;
  // Mailbox to get transaction from driver
  // Used for sampling inputs to the RTL
  mailbox drv_mx;
  
  // Function to generate grant
  function logic[NUM_PORTS-1:0] gnt (logic[NUM_PORTS-1:0] req);
    gnt = '0;
    // LSB has highest priority
    for (int i=0; i<NUM_PORTS; i++) begin
      if (req[i]) begin
        gnt = NUM_PORTS'(1<<i);
        break;
      end
    end
    return gnt;
  endfunction
  
  task run();
    // Item to get from mailbox
    day14_item #(.NUM_PORTS(NUM_PORTS)) mon_item;
    day14_item #(.NUM_PORTS(NUM_PORTS)) drv_item;
    $display("%t [SCOREBOARD] Starting now...", $time);
    forever begin
      // Get the item from monitor and driver
      fork
        sb_mx.get(mon_item);
        drv_mx.get(drv_item);
      join
      // Print the received item
      mon_item.print("SCOREBOARD");
      drv_item.print("DRIVER");

      // Compare the item
      if (mon_item.gnt !== gnt(drv_item.req)) begin
        $fatal(1, "%t Output doesn't match! Expected: 0x%8x Got: 0x%8x", $time, mon_item.gnt, gnt(drv_item.req));
      end
    end

  endtask

endclass

`endif

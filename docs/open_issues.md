# Open Issues

These are the design decisions still to close.

1. **Cycle schedule and staging:** confirm the 12-clock latency budget,
   `REQUEST_LEAD=8` and `STAGING_DEPTH=4` against the measured minimum and
   maximum latency before integration RTL.
2. **Protocol recovery FSM:** implement old-frame error capture on assembled SOF,
   lock reacquisition and request-phase checks. Ports already carry
   `previous_frame_bad`; verify it cannot clear before bbox consumes it.
3. **Timing and area:** the budget is 2x2 tiles, about 900 flip-flops plus the
   hue and contrast multipliers. Track each module's yosys estimate against the
   table in [Module Interface Contracts](modules/colourplay_if.md); the GDS flow
   checks 50 MHz closure.
4. **VGA compatibility:** confirm 25 MHz timing with the intended viewer/monitor.
5. **Source driver:** the protocol is specified; the cycle-exact source driver
   and frame capture are task 6.
6. **Hue area:** the direct form needs nine products per pixel, well over
   budget. Reducing the multiplier count is task 3's main design decision;
   measure it early.
7. **Recovery and stale geometry:** specify exact frame-abort behavior, hold
   display geometry per frame and test recovery across prefetched SOF.

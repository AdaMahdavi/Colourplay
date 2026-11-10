# Open Issues

These are design gates, not hidden implementation assumptions.

1. **Cycle schedule and staging:** prove the draft four-clock source response,
   assembler latency, IPU stage count and `REQUEST_LEAD=16`. Freeze exact
   occupancy and local storage depth before integration RTL.
2. **Protocol recovery FSM:** implement old-frame error capture on assembled SOF,
   lock reacquisition and request-phase checks. Ports already carry
   `previous_frame_bad`; verify it cannot clear before bbox consumes it.
3. **Timing and area:** 50 MHz, the tile size in metadata and staging depth are
   provisional. No area fit or IHP pad/clock sign-off is claimed.
4. **VGA compatibility:** confirm 25 MHz timing with the intended viewer/monitor.
5. **Source driver:** the protocol is specified; the cycle-exact source driver
   and frame capture are task 6.
6. **Hue area:** nine products per pixel. Measure multiplier count and area
   early; table-size and sharing trade-offs are part of task 3.
7. **Recovery and stale geometry:** specify exact frame-abort behavior, hold
   display geometry per frame and test recovery across prefetched SOF.

No final buffer-depth, protocol-lock FSM or fabrication-readiness claim should be
made until these gates are closed.

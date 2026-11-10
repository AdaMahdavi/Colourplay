# `io` - Receives Prepared Pixels and Configuration

## Overview

This module translates the prepared input beats into RGB888 pixels. It associates
each pixel with VGA's request coordinates and receives configuration writes.
It is a parallel input adapter, not a UART receiver.

## Parameters

No public parameters in the initial skeleton. Response timing follows
[Input Encoding](../../encoding/input.md).

## Ports

| Group | Signals |
|---|---|
| Clock/reset | `clk`, `rst_n` |
| Input pins | `i_data[11:0]`, `i_valid`, `i_sof`, `i_config` |
| VGA requests | `i_request`, `i_request_x[9:0]`, `i_request_y[9:0]`, `i_request_sof`, `i_request_eof` |
| Pixel source to IPU | `o_colour[23:0]`, `o_valid`, `i_ready`, `o_x[9:0]`, `o_y[9:0]`, `o_sof`, `o_eof` |
| Frame qualification to IPU | `o_previous_frame_bad`, sampled with accepted SOF |
| Configuration | `o_configuration[127:0]` |
| Status | `o_error` |

## Architecture Overview

Store beat 0, combine it with beat 1 and present the complete pixel through the
pixel holding register. Save request metadata through the same response delay.
The 4-clock source latency allows multiple requests to be outstanding; delay
their metadata in request order rather than retaining only the newest request.
Budget three 22-bit request metadata entries, or an equivalent delay pipeline.

Configuration writes update shadow registers. Commit the active copy before
the first pixel of the next frame. Under the baseline's bounded pipeline,
vertical blanking provides a drain interval.

## Reset and Errors

Reset clears valid, pending requests, partial beats and lock. Configuration
returns to its documented defaults. Missing beats, unexpected SOF and illegal
configuration raise sticky error until reset; rejected writes leave the shadow
register unchanged. Track reception errors per frame separately. Attach that
old history to the next SOF as `o_previous_frame_bad` before clearing it.
Reacquire lock at a valid frame start, not at an
arbitrary byte boundary.

The skeleton drives `o_error=1`, `o_valid=0` and zero payloads intentionally.

## Implementation Tasks

Implement assembly before configuration. Verify consecutive requests, backpressure
at the output, first/last pixels, request metadata delay and malformed transfers.
The physical source cannot be stalled after a request; an occupied output slot
is a protocol failure, not permission to overwrite a held pixel.

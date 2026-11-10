# Simulation

Run `make -C test` from the repository root with Icarus Verilog, Make and the
packages in [requirements.txt](requirements.txt) installed. The smoke test checks
reset outputs and the request-pin output enable; replace its checks with module
acceptance tests as modules are implemented.

`python3 test/colourplay_model.py` runs the model self-check and regenerates the
pipeline GIF.

See [verification objectives](verification.md) and
[implementation tasks](../docs/tasks.md).

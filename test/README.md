# Scaffold simulation

Run `make -C test` from the repository root with Icarus Verilog, Make and the
packages in [requirements.txt](requirements.txt) installed.

The current test verifies only elaboration, constant safe outputs and the
request-pin output enable. It does not claim that filtering or VGA works.
`REQUIRE_FUNCTIONAL=1 make -C test` deliberately fails until functional
acceptance tests are implemented.

See [verification objectives](../docs/verification.md) and
[implementation tasks](../docs/tasks.md). Replace scaffold checks as modules
become functional; do not make real functionality satisfy obsolete tie-off tests.

The inherited gate-level build remains available through the manual GDS workflow
but is not a functional sign-off for these skeletons.

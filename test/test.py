"""Scaffold checks only. These do not verify image-processing functionality."""

import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def scaffold_smoke(dut):
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 4)
    assert int(dut.uio_oe.value) == 0x80
    assert int(dut.uo_out.value) == 0
    assert int(dut.uio_out.value) == 0
    dut._log.warning("SCAFFOLD ONLY: functional image processing is not implemented")
    if os.environ.get("REQUIRE_FUNCTIONAL") == "1":
        raise AssertionError(
            "NOT IMPLEMENTED: replace scaffold assertions with the acceptance "
            "tests in test/verification.md before enabling functional sign-off"
        )

# ttsky25a-tinyqv

Tiny Tapeout's [TinyQV "Asteroids"](https://github.com/TinyTapeout/ttsky25a-tinyQV), a crowdsourced SoC on SKY130: Michael Bell's RV32EC TinyQV core with thirty-odd peripherals from the Tiny Tapeout RISC-V challenge, taken as a black box.

![maturity](https://img.shields.io/badge/maturity-planned-lightgrey) ![license](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0%20OR%20MulanPSL--2.0-blue) ![upstream](https://img.shields.io/badge/upstream-Apache--2.0-lightgrey)

Part of the [Tape-Out](https://github.com/Tape-Out) IP library, wired up by [`xirang`](https://github.com/Tape-Out/xirang). One submodule, not modified: `third_party/ttsky25a-tinyqv`, which carries the core as its own submodule `src/tinyQV`.

## What this repository adds

The `flist` setup task writes the file list from `source_files` in upstream's `info.yaml`, the list the Tiny Tapeout flow hardens. The top is `tt_um_tt_tinyQV` with the standard Tiny Tapeout pins: eight inputs, eight outputs and eight bidirectional pins. The QSPI flash and the two PSRAMs sit on the bidirectional pins; UART and the two interrupts are on the inputs and outputs.

```console
$ ran run ttsky25a-tinyqv flist
$ ran test ttsky25a-tinyqv
```

## Testing

The `cocotb` task runs every target of upstream's `.github/workflows/test.yaml` with upstream's makefiles and cocotb tests: `core`, `prog` and the peripheral slots `peri_num_2` to `peri_num_39`. Each target runs in its own copy of `test/`, since upstream's makefiles start with `make clean`. A target passes when its `results.xml` has test cases and no failure; the slots upstream leaves empty write an empty `testsuites` line and are counted apart.

## Limits

`CLOCK_MHZ` is not a knob: upstream's tests run the clock at 64 MHz, and the UART and WS2812 dividers follow it. The latch-based files (the register file, the counters, the configuration of `vga_gfx`) take their generic branch, negative-edge flip-flops; upstream hardens them as SKY130 latch cells and simulates them with the latch models under `SIM`. `prism` and the `pwl_synth` storage have no generic branch and instantiate SKY130 cells directly; `vendor/sky130_cells.v` gives behavioural models of the latch, clock gate and gates they use, to be replaced with this process's latch cells for a tape-out. `peri_uart.v` uses a signal before declaring it, so slang's `UsedBeforeDeclared` is relaxed. Program and data live in the external QSPI flash and PSRAM; the chip has no on-chip memory.

## License

This repository: 任选其一 [MIT](LICENSE-MIT) · [Apache 2.0](LICENSE-APACHE) · [木兰宽松许可证 第2版](LICENSE-MULAN).

`third_party/ttsky25a-tinyqv` stays under **Apache-2.0**; see its licence file. The peripherals carry their authors' SPDX headers.

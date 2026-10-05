# Module 4: CRC-8 error locator

This design finds a single corrupted pixel in a 32 × 32 greyscale image. It works out a CRC-8 for every row and every column, and compares them with reference CRCs taken from the original image. If one pixel has changed, one row and one column won't match, and that gives you its position.

The design is split into a controller, which is a state machine that decides what happens each clock cycle, and a datapath that does the actual work.

| File | What it is |
|---|---|
| `crc8_locator.slx` | The design |
| `run_demo.m` | The demo (see below) |
| `check_image.m` | Works out the row and column CRCs of an image in MATLAB. The demo uses it to make the reference CRCs |
| `crc8_line.m` | CRC-8 of a list of bytes, with polynomial 0x07 |
| `ctrl_state.m` | The controller's states: `IDLE`, `LOAD`, `HOLD`, `ACC`, `STORE`, `SWAP`, `CMP` and `DONE` |
| `capybara32.png` | The test image |

## Inside the model

The design is the `crc_locator` subsystem, and each part of it is a MATLAB Function block.

- `controller` is the state machine. It goes through the image one row at a time, then one column at a time, and then compares all 64 results.
- `datapath/imem` holds the image, 1024 bytes, and takes two cycles to read.
- `datapath/crc` builds up the CRC of the current row or column.
- `datapath/store` keeps the 64 finished CRCs.
- `datapath/cmp` holds the reference CRCs, compares them with the stored ones, and remembers which row and column didn't match.

The image goes in through `img_wr_addr`, `img_wr_data` and `img_wr_en`, and the reference CRCs through `ref_wr_addr`, `ref_wr_data` and `ref_wr_en`. Raising `start` begins a run. When it's finished, `done` goes high and `err_row`, `err_col` and `err_valid` hold the answer.

## Running it

```matlab
run_demo
```

This runs the design six times: once on the clean image, then on five copies with one pixel changed in each. It prints a table of where the model found the error next to where it actually was, then the number of clock cycles per run, then PASS or FAIL.

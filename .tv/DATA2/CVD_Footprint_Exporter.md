<!-- tradingview-pine-id: PUB;ad8fc681a5254b159f63f57be8fd812b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CVD Footprint Exporter

Source: https://www.tradingview.com/script/VJc0v9Qe-CVD-Footprint-Exporter/

## Description

Proposed public title: Footprint CSV Exporter for CVD Research
Saved Pine script: CVD Footprint Exporter
Suggested publication settings: Public, Open-source
Status: Draft only. Not published.

DESCRIPTION

This utility exposes TradingView footprint data as Data Window plots that can be included in the native Download chart data CSV export. It is intended for people building candle-by-candle datasets for volume delta and cumulative volume delta research.

The script follows the current chart symbol and timeframe. It exports candle buy volume, sell volume, delta, total footprint volume, Point of Control price bounds and buy/sell volume, value-area boundaries, footprint row count, row size, trading-day timestamp, and chart volume. It also exports detailed price rows in batches of 12.

HOW TO EXPORT
1. Add the indicator to your chart and choose the symbol and timeframe you want to study.
2. Set Ticks per row. Price-row size equals this setting multiplied by the symbol's minimum tick. The default is 30 ticks; on GC with a 0.1 tick, that is 3.0 price points. This is a fixed setting, not automatic ATR sizing.
3. Load the historical candles you need by navigating backward on the chart.
4. Leave First row index at 0 and use the chart layout menu's Download chart data option. UNIX timestamps make it straightforward to join multiple exports.
5. Check FP_row_count. If any candle has more than 12 rows, set First row index to 12 and export again, then 24, 36, and so on until all rows are covered. Keep the symbol, timeframe, history, and row-size settings unchanged between batches.
6. Join batches by candle timestamp. A batch's FP_r0 fields refer to the row at FP_row_offset, and FP_r11 refers to offset plus 11. Rows run from lowest to highest price. Each row's upper boundary is its exported lower boundary plus FP_row_size.

READING THE FIELDS
FP_available is 1 when TradingView returns a footprint, otherwise 0. Unavailable volumes are blank, not zero.
FP_delta is buy volume minus sell volume.
FP_POC_low and FP_POC_high describe a price range rather than a single exact price.
FP_VAH and FP_VAL describe the value-area boundaries. The script uses 70% value area and a 300% imbalance threshold.
The row imbalance code is 0 for neither, 1 for buy imbalance, 2 for sell imbalance, and 3 for both.
FP_chart_volume is included separately so source differences can be detected rather than concealed.

CUMULATIVE DELTA AND RESEARCH EXAMPLES
This version exports raw per-candle delta. It does not plot CVD or calculate a cumulative series inside Pine. To calculate CVD after export, sort by timestamp and take a running sum of FP_delta. Record the starting timestamp and reset rule, such as the first available footprint or each trading day. Missing footprint history must not be treated as zero delta.
Other calculations include red candles with positive delta, green candles with negative delta, imbalance counts, and the POC's position relative to the candle body.

LIMITATIONS
The script prepares exportable fields; it does not automatically download files or load unlimited history. TradingView account features and data availability determine access to footprint requests and CSV export. Footprint data may cover less history than ordinary OHLCV.
The price footprints visible on the chart are TradingView's native chart type, not graphics drawn by this indicator. The indicator's outputs appear in the Data Window and CSV.
Buy/sell values use TradingView's footprint classifications and are not an independent verification of exchange bid/ask trades. Live candles can change before closing.
A price row may overlap a candle's body and wick. The script does not split that row's volume into exact wick-only quantities.
This is a data collection utility with no entries, exits, alerts, or backtest results.

AUTHOR PREPARATION NOTE (not part of the public description)
Use a clean publication chart containing the exporter and only the visuals needed to demonstrate it. Exclude unrelated strategies, private indicators, trading/account information, and drawings. Explain that the native footprint chart provides the displayed footprint graphics. Verify the final screenshot and available public/open-source settings before submission.

---

## Source Code

````pine
//@version=6
indicator("CVD Footprint Exporter", overlay=true, precision=8)
int ticks = input.int(30, "Ticks per row", minval=1)
int offset = input.int(0, "First row index", minval=0)
footprint fp = request.footprint(ticks, 70, 300)
float b = na(fp) ? na : fp.buy_volume()
float s = na(fp) ? na : fp.sell_volume()
float d = na(fp) ? na : fp.delta()
array<volume_row> rows = na(fp) ? array.new<volume_row>() : fp.rows()
volume_row poc = na(fp) ? na : fp.poc()
volume_row vah = na(fp) ? na : fp.vah()
volume_row val = na(fp) ? na : fp.val()
plot(na(fp) ? 0 : 1, "FP_available", display=display.data_window)
plot(b, "FP_buy", display=display.data_window)
plot(s, "FP_sell", display=display.data_window)
plot(d, "FP_delta", display=display.data_window)
plot(na(fp) ? na : fp.total_volume(), "FP_total", display=display.data_window)
plot(na(poc) ? na : poc.down_price(), "FP_POC_low", display=display.data_window)
plot(na(poc) ? na : poc.up_price(), "FP_POC_high", display=display.data_window)
plot(na(poc) ? na : poc.buy_volume(), "FP_POC_buy", display=display.data_window)
plot(na(poc) ? na : poc.sell_volume(), "FP_POC_sell", display=display.data_window)
plot(na(vah) ? na : vah.up_price(), "FP_VAH", display=display.data_window)
plot(na(val) ? na : val.down_price(), "FP_VAL", display=display.data_window)
plot(array.size(rows), "FP_row_count", display=display.data_window)
plot(ticks * syminfo.mintick, "FP_row_size", display=display.data_window)
plot(offset, "FP_row_offset", display=display.data_window)
plot(time_tradingday, "FP_tradingday_ms", display=display.data_window)
plot(volume, "FP_chart_volume", display=display.data_window)
volume_row r0 = array.size(rows) > offset + 0 ? array.get(rows, offset + 0) : na
plot(na(r0) ? na : r0.down_price(), "FP_r0_low", display=display.data_window)
plot(na(r0) ? na : r0.buy_volume(), "FP_r0_buy", display=display.data_window)
plot(na(r0) ? na : r0.sell_volume(), "FP_r0_sell", display=display.data_window)
plot(na(r0) ? na : (r0.has_buy_imbalance() ? 1 : 0) + (r0.has_sell_imbalance() ? 2 : 0), "FP_r0_imbalance", display=display.data_window)
volume_row r1 = array.size(rows) > offset + 1 ? array.get(rows, offset + 1) : na
plot(na(r1) ? na : r1.down_price(), "FP_r1_low", display=display.data_window)
plot(na(r1) ? na : r1.buy_volume(), "FP_r1_buy", display=display.data_window)
plot(na(r1) ? na : r1.sell_volume(), "FP_r1_sell", display=display.data_window)
plot(na(r1) ? na : (r1.has_buy_imbalance() ? 1 : 0) + (r1.has_sell_imbalance() ? 2 : 0), "FP_r1_imbalance", display=display.data_window)
volume_row r2 = array.size(rows) > offset + 2 ? array.get(rows, offset + 2) : na
plot(na(r2) ? na : r2.down_price(), "FP_r2_low", display=display.data_window)
plot(na(r2) ? na : r2.buy_volume(), "FP_r2_buy", display=display.data_window)
plot(na(r2) ? na : r2.sell_volume(), "FP_r2_sell", display=display.data_window)
plot(na(r2) ? na : (r2.has_buy_imbalance() ? 1 : 0) + (r2.has_sell_imbalance() ? 2 : 0), "FP_r2_imbalance", display=display.data_window)
volume_row r3 = array.size(rows) > offset + 3 ? array.get(rows, offset + 3) : na
plot(na(r3) ? na : r3.down_price(), "FP_r3_low", display=display.data_window)
plot(na(r3) ? na : r3.buy_volume(), "FP_r3_buy", display=display.data_window)
plot(na(r3) ? na : r3.sell_volume(), "FP_r3_sell", display=display.data_window)
plot(na(r3) ? na : (r3.has_buy_imbalance() ? 1 : 0) + (r3.has_sell_imbalance() ? 2 : 0), "FP_r3_imbalance", display=display.data_window)
volume_row r4 = array.size(rows) > offset + 4 ? array.get(rows, offset + 4) : na
plot(na(r4) ? na : r4.down_price(), "FP_r4_low", display=display.data_window)
plot(na(r4) ? na : r4.buy_volume(), "FP_r4_buy", display=display.data_window)
plot(na(r4) ? na : r4.sell_volume(), "FP_r4_sell", display=display.data_window)
plot(na(r4) ? na : (r4.has_buy_imbalance() ? 1 : 0) + (r4.has_sell_imbalance() ? 2 : 0), "FP_r4_imbalance", display=display.data_window)
volume_row r5 = array.size(rows) > offset + 5 ? array.get(rows, offset + 5) : na
plot(na(r5) ? na : r5.down_price(), "FP_r5_low", display=display.data_window)
plot(na(r5) ? na : r5.buy_volume(), "FP_r5_buy", display=display.data_window)
plot(na(r5) ? na : r5.sell_volume(), "FP_r5_sell", display=display.data_window)
plot(na(r5) ? na : (r5.has_buy_imbalance() ? 1 : 0) + (r5.has_sell_imbalance() ? 2 : 0), "FP_r5_imbalance", display=display.data_window)
volume_row r6 = array.size(rows) > offset + 6 ? array.get(rows, offset + 6) : na
plot(na(r6) ? na : r6.down_price(), "FP_r6_low", display=display.data_window)
plot(na(r6) ? na : r6.buy_volume(), "FP_r6_buy", display=display.data_window)
plot(na(r6) ? na : r6.sell_volume(), "FP_r6_sell", display=display.data_window)
plot(na(r6) ? na : (r6.has_buy_imbalance() ? 1 : 0) + (r6.has_sell_imbalance() ? 2 : 0), "FP_r6_imbalance", display=display.data_window)
volume_row r7 = array.size(rows) > offset + 7 ? array.get(rows, offset + 7) : na
plot(na(r7) ? na : r7.down_price(), "FP_r7_low", display=display.data_window)
plot(na(r7) ? na : r7.buy_volume(), "FP_r7_buy", display=display.data_window)
plot(na(r7) ? na : r7.sell_volume(), "FP_r7_sell", display=display.data_window)
plot(na(r7) ? na : (r7.has_buy_imbalance() ? 1 : 0) + (r7.has_sell_imbalance() ? 2 : 0), "FP_r7_imbalance", display=display.data_window)
volume_row r8 = array.size(rows) > offset + 8 ? array.get(rows, offset + 8) : na
plot(na(r8) ? na : r8.down_price(), "FP_r8_low", display=display.data_window)
plot(na(r8) ? na : r8.buy_volume(), "FP_r8_buy", display=display.data_window)
plot(na(r8) ? na : r8.sell_volume(), "FP_r8_sell", display=display.data_window)
plot(na(r8) ? na : (r8.has_buy_imbalance() ? 1 : 0) + (r8.has_sell_imbalance() ? 2 : 0), "FP_r8_imbalance", display=display.data_window)
volume_row r9 = array.size(rows) > offset + 9 ? array.get(rows, offset + 9) : na
plot(na(r9) ? na : r9.down_price(), "FP_r9_low", display=display.data_window)
plot(na(r9) ? na : r9.buy_volume(), "FP_r9_buy", display=display.data_window)
plot(na(r9) ? na : r9.sell_volume(), "FP_r9_sell", display=display.data_window)
plot(na(r9) ? na : (r9.has_buy_imbalance() ? 1 : 0) + (r9.has_sell_imbalance() ? 2 : 0), "FP_r9_imbalance", display=display.data_window)
volume_row r10 = array.size(rows) > offset + 10 ? array.get(rows, offset + 10) : na
plot(na(r10) ? na : r10.down_price(), "FP_r10_low", display=display.data_window)
plot(na(r10) ? na : r10.buy_volume(), "FP_r10_buy", display=display.data_window)
plot(na(r10) ? na : r10.sell_volume(), "FP_r10_sell", display=display.data_window)
plot(na(r10) ? na : (r10.has_buy_imbalance() ? 1 : 0) + (r10.has_sell_imbalance() ? 2 : 0), "FP_r10_imbalance", display=display.data_window)
volume_row r11 = array.size(rows) > offset + 11 ? array.get(rows, offset + 11) : na
plot(na(r11) ? na : r11.down_price(), "FP_r11_low", display=display.data_window)
plot(na(r11) ? na : r11.buy_volume(), "FP_r11_buy", display=display.data_window)
plot(na(r11) ? na : r11.sell_volume(), "FP_r11_sell", display=display.data_window)
plot(na(r11) ? na : (r11.has_buy_imbalance() ? 1 : 0) + (r11.has_sell_imbalance() ? 2 : 0), "FP_r11_imbalance", display=display.data_window)
````

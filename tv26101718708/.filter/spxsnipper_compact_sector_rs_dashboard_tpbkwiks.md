# SpxSnipper - Compact Sector RS Dashboard

- url: https://www.tradingview.com/script/TPBKWIKS-SpxSnipper-Compact-Sector-RS-Dashboard/
- type: indicator
- pine_id: PUB;7bbbd15ebb3a4f278b357c3242c9f20c
- version: 1.0

## Description

SpxSnipper - Compact Sector RS Dashboard

This indicator displays a compact sector relative strength dashboard using the major SPDR sector ETFs and SPY as the benchmark.

The dashboard ranks sectors based on recent performance and relative strength. It shows each sector ETF’s performance over three timeframes:

• 6 months
• 3 months
• 1 month

The default sector list includes:
XLY, XLP, XLE, XLF, XLV, XLI, XLB, XLRE, XLK, XLC, and XLU.

Benchmark:
SPY is used as the default benchmark for relative strength calculations.

Main columns:

6M / 3M / 1M:
These columns show the absolute percentage return of each sector ETF over the selected lookback periods.

RS Score:
The RS Score is a weighted relative strength score versus SPY. It compares each sector’s performance against SPY across the 6M, 3M, and 1M periods, with more weight given to recent performance.

Formula:

RS Score =
Relative 6M × 20%
+ Relative 3M × 30%
+ Relative 1M × 50%

Where:

Relative Return = Sector ETF Return - SPY Return

A positive RS Score means the sector has outperformed SPY on a weighted relative basis.
A negative RS Score means the sector has underperformed SPY on a weighted relative basis.

RS Trend:
RS Trend evaluates whether the sector’s relative strength versus SPY is improving, weakening, or mixed across the three timeframes.

The logic is:

RS ↑:
Relative strength is improving from 6M to 3M to 1M.
This means:
Rel 1M > Rel 3M > Rel 6M

RS ↓:
Relative strength is weakening from 6M to 3M to 1M.
This means:
Rel 1M < Rel 3M < Rel 6M

Mixed:
There is no clear sequential improvement or deterioration in relative strength.

How to use:
This dashboard is intended to help visually compare sector performance and sector rotation. It can be used to identify sectors that are outperforming or underperforming SPY across multiple timeframes.

The RS Score is useful for ranking sectors by weighted relative strength, while RS Trend helps identify whether that relative strength is improving or deteriorating.

Suggested interpretation:
• High RS Score + RS ↑ may indicate improving relative leadership.
• High RS Score + Mixed may indicate strong performance but less consistent relative acceleration.
• Low or negative RS Score + RS ↓ may indicate relative weakness.
• Positive absolute performance does not always mean sector leadership; relative performance versus SPY is also important.

Customization:
Users can adjust:
• Benchmark symbol
• Sector ETF symbols
• Lookback periods for 6M, 3M, and 1M
• Sorting method
• Table position

Important note:
This indicator is designed for market analysis and sector comparison only. It does not provide buy or sell recommendations. Users should combine sector analysis with their own trading plan, risk management, and additional confirmation tools.

This script is for educational and analytical purposes only and does not provide financial advice.

## Source Code

````pine
//@version=6
indicator("SpxSnipper - Compact Sector RS Dashboard", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
benchmarkSymbol = input.symbol("AMEX:SPY", "Benchmark - SPY")

sortBy = input.string(
     "RS Score",
     "Sort Sectors By",
     options = ["RS Score", "6M", "3M", "1M"]
)

lookback6M = input.int(126, "6M Lookback - Trading Days", minval=20, maxval=300)
lookback3M = input.int(63, "3M Lookback - Trading Days", minval=10, maxval=150)
lookback1M = input.int(21, "1M Lookback - Trading Days", minval=5, maxval=80)

showOnlyLastBar = input.bool(true, "Update Table Only On Last Bar")

tablePosition = input.string(
     "Top Right",
     "Table Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"]
)

sector1  = input.symbol("AMEX:XLY",  "Consumer Discretionary - XLY")
sector2  = input.symbol("AMEX:XLP",  "Consumer Staples - XLP")
sector3  = input.symbol("AMEX:XLE",  "Energy - XLE")
sector4  = input.symbol("AMEX:XLF",  "Financials - XLF")
sector5  = input.symbol("AMEX:XLV",  "Health Care - XLV")
sector6  = input.symbol("AMEX:XLI",  "Industrials - XLI")
sector7  = input.symbol("AMEX:XLB",  "Materials - XLB")
sector8  = input.symbol("AMEX:XLRE", "Real Estate - XLRE")
sector9  = input.symbol("AMEX:XLK",  "Technology - XLK")
sector10 = input.symbol("AMEX:XLC",  "Communication Services - XLC")
sector11 = input.symbol("AMEX:XLU",  "Utilities - XLU")

// ─────────────────────────────────────────────
// Helper functions
// ─────────────────────────────────────────────
f_tablePosition(string pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     pos == "Bottom Left" ? position.bottom_left :
     position.top_right

f_return(string sym, int lb) =>
    request.security(
         sym,
         "D",
         (close / close[lb] - 1.0) * 100.0,
         barmerge.gaps_off,
         barmerge.lookahead_off
    )

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

f_scoreText(float value) =>
    na(value) ? "n/a" : value >= 0 ? "+" + str.tostring(value, "#.##") : str.tostring(value, "#.##")

f_bgReturn(float value) =>
    na(value) ? color.new(color.gray, 85) :
     value > 10 ? color.new(color.lime, 65) :
     value > 3 ? color.new(color.lime, 78) :
     value >= 0 ? color.new(color.lime, 88) :
     value > -3 ? color.new(color.red, 88) :
     value > -10 ? color.new(color.red, 78) :
     color.new(color.red, 65)

f_bgScore(float value) =>
    na(value) ? color.new(color.gray, 85) :
     value > 5 ? color.new(color.lime, 60) :
     value > 0 ? color.new(color.lime, 80) :
     value > -5 ? color.new(color.red, 80) :
     color.new(color.red, 60)

f_directionText(float rel6, float rel3, float rel1) =>
    bool improving = rel1 > rel3 and rel3 > rel6
    bool weakening = rel1 < rel3 and rel3 < rel6
    improving ? "RS ↑" : weakening ? "RS ↓" : "Mixed"

f_directionColor(float rel6, float rel3, float rel1) =>
    bool improving = rel1 > rel3 and rel3 > rel6
    bool weakening = rel1 < rel3 and rel3 < rel6
    improving ? color.new(color.lime, 75) :
     weakening ? color.new(color.red, 75) :
     color.new(color.blue, 80)

f_cleanSymbol(string sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : sym

f_rsScore(float rel6, float rel3, float rel1) =>
    rel6 * 0.20 + rel3 * 0.30 + rel1 * 0.50

// ─────────────────────────────────────────────
// Benchmark returns
// ─────────────────────────────────────────────
spy6M = f_return(benchmarkSymbol, lookback6M)
spy3M = f_return(benchmarkSymbol, lookback3M)
spy1M = f_return(benchmarkSymbol, lookback1M)

// ─────────────────────────────────────────────
// Sector returns
// ─────────────────────────────────────────────
r1_6  = f_return(sector1,  lookback6M)
r1_3  = f_return(sector1,  lookback3M)
r1_1  = f_return(sector1,  lookback1M)

r2_6  = f_return(sector2,  lookback6M)
r2_3  = f_return(sector2,  lookback3M)
r2_1  = f_return(sector2,  lookback1M)

r3_6  = f_return(sector3,  lookback6M)
r3_3  = f_return(sector3,  lookback3M)
r3_1  = f_return(sector3,  lookback1M)

r4_6  = f_return(sector4,  lookback6M)
r4_3  = f_return(sector4,  lookback3M)
r4_1  = f_return(sector4,  lookback1M)

r5_6  = f_return(sector5,  lookback6M)
r5_3  = f_return(sector5,  lookback3M)
r5_1  = f_return(sector5,  lookback1M)

r6_6  = f_return(sector6,  lookback6M)
r6_3  = f_return(sector6,  lookback3M)
r6_1  = f_return(sector6,  lookback1M)

r7_6  = f_return(sector7,  lookback6M)
r7_3  = f_return(sector7,  lookback3M)
r7_1  = f_return(sector7,  lookback1M)

r8_6  = f_return(sector8,  lookback6M)
r8_3  = f_return(sector8,  lookback3M)
r8_1  = f_return(sector8,  lookback1M)

r9_6  = f_return(sector9,  lookback6M)
r9_3  = f_return(sector9,  lookback3M)
r9_1  = f_return(sector9,  lookback1M)

r10_6 = f_return(sector10, lookback6M)
r10_3 = f_return(sector10, lookback3M)
r10_1 = f_return(sector10, lookback1M)

r11_6 = f_return(sector11, lookback6M)
r11_3 = f_return(sector11, lookback3M)
r11_1 = f_return(sector11, lookback1M)

// ─────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────
// Columns:
// 0 #
// 1 ETF
// 2 6M
// 3 3M
// 4 1M
// 5 RS Score
// 6 RS Trend

var table t = table.new(f_tablePosition(tablePosition), 7, 14, border_width=1)

f_addSector(
     array<string> symbols,
     array<float> ret6,
     array<float> ret3,
     array<float> ret1,
     array<float> rel6,
     array<float> rel3,
     array<float> rel1,
     array<float> scores,
     array<float> sortValues,
     string sym,
     float r6,
     float r3,
     float r1
) =>
    float sr6 = r6 - spy6M
    float sr3 = r3 - spy3M
    float sr1 = r1 - spy1M
    float score = f_rsScore(sr6, sr3, sr1)

    float sortVal =
         sortBy == "6M" ? r6 :
         sortBy == "3M" ? r3 :
         sortBy == "1M" ? r1 :
         score

    array.push(symbols, f_cleanSymbol(sym))
    array.push(ret6, r6)
    array.push(ret3, r3)
    array.push(ret1, r1)
    array.push(rel6, sr6)
    array.push(rel3, sr3)
    array.push(rel1, sr1)
    array.push(scores, score)
    array.push(sortValues, sortVal)

// ─────────────────────────────────────────────
// Draw table
// ─────────────────────────────────────────────
shouldUpdate = showOnlyLastBar ? barstate.islast : true

if shouldUpdate
    array<string> symbols = array.new_string()
    array<float> ret6 = array.new_float()
    array<float> ret3 = array.new_float()
    array<float> ret1 = array.new_float()
    array<float> rel6 = array.new_float()
    array<float> rel3 = array.new_float()
    array<float> rel1 = array.new_float()
    array<float> scores = array.new_float()
    array<float> sortValues = array.new_float()

    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector1, r1_6, r1_3, r1_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector2, r2_6, r2_3, r2_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector3, r3_6, r3_3, r3_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector4, r4_6, r4_3, r4_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector5, r5_6, r5_3, r5_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector6, r6_6, r6_3, r6_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector7, r7_6, r7_3, r7_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector8, r8_6, r8_3, r8_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector9, r9_6, r9_3, r9_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector10, r10_6, r10_3, r10_1)
    f_addSector(symbols, ret6, ret3, ret1, rel6, rel3, rel1, scores, sortValues, sector11, r11_6, r11_3, r11_1)

    array<int> sorted = array.sort_indices(sortValues, order.descending)

    table.clear(t, 0, 0, 6, 13)

    headerBg = color.new(color.black, 0)
    headerTxt = color.white

    table.cell(t, 0, 0, "#", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 1, 0, "ETF", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 2, 0, "6M", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 3, 0, "3M", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 4, 0, "1M", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 5, 0, "RS Score", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 6, 0, "RS Trend", text_color=headerTxt, bgcolor=headerBg)

    for row = 0 to array.size(sorted) - 1
        idx = array.get(sorted, row)

        sym = array.get(symbols, idx)

        v6 = array.get(ret6, idx)
        v3 = array.get(ret3, idx)
        v1 = array.get(ret1, idx)

        rs6 = array.get(rel6, idx)
        rs3 = array.get(rel3, idx)
        rs1 = array.get(rel1, idx)

        score = array.get(scores, idx)

        rowNum = row + 1

        table.cell(t, 0, rowNum, str.tostring(rowNum), text_color=color.white, bgcolor=color.new(color.black, 15))
        table.cell(t, 1, rowNum, sym, text_color=color.white, bgcolor=color.new(color.black, 15))

        table.cell(t, 2, rowNum, f_pct(v6), text_color=color.white, bgcolor=f_bgReturn(v6))
        table.cell(t, 3, rowNum, f_pct(v3), text_color=color.white, bgcolor=f_bgReturn(v3))
        table.cell(t, 4, rowNum, f_pct(v1), text_color=color.white, bgcolor=f_bgReturn(v1))

        table.cell(t, 5, rowNum, f_scoreText(score), text_color=color.white, bgcolor=f_bgScore(score))
        table.cell(t, 6, rowNum, f_directionText(rs6, rs3, rs1), text_color=color.white, bgcolor=f_directionColor(rs6, rs3, rs1))

    spyRow = 12
    table.cell(t, 0, spyRow, "", bgcolor=color.new(color.gray, 70))
    table.cell(t, 1, spyRow, f_cleanSymbol(benchmarkSymbol), text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(t, 2, spyRow, f_pct(spy6M), text_color=color.white, bgcolor=f_bgReturn(spy6M))
    table.cell(t, 3, spyRow, f_pct(spy3M), text_color=color.white, bgcolor=f_bgReturn(spy3M))
    table.cell(t, 4, spyRow, f_pct(spy1M), text_color=color.white, bgcolor=f_bgReturn(spy1M))
    table.cell(t, 5, spyRow, "Base", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(t, 6, spyRow, "Base", text_color=color.white, bgcolor=color.new(color.gray, 70))

    noteRow = 13
    table.cell(t, 0, noteRow, "", bgcolor=color.new(color.black, 25))
    table.cell(t, 1, noteRow, "Sort", text_color=color.white, bgcolor=color.new(color.black, 25))
    table.cell(t, 2, noteRow, sortBy, text_color=color.yellow, bgcolor=color.new(color.black, 25))
    table.cell(t, 3, noteRow, "", bgcolor=color.new(color.black, 25))
    table.cell(t, 4, noteRow, "", bgcolor=color.new(color.black, 25))
    table.cell(t, 5, noteRow, "", bgcolor=color.new(color.black, 25))
    table.cell(t, 6, noteRow, "", bgcolor=color.new(color.black, 25))
````

<!-- tradingview-pine-id: PUB;0c650658f7f949c396e22c8e5aaac71f -->
<!-- tradingviewscripts-format: 1 -->
# Single Timeframe Multi-EMA Trend Table

Source: https://www.tradingview.com/script/r3mu6yZ9-Single-Timeframe-Multi-EMA-Trend-Table/

## Description

### Overview
The **Single Timeframe Multi-EMA Trend Table** displays the directional bias of 7 customizable Exponential Moving Averages (EMAs) calculated from a single, higher timeframe of your choice.

This allows traders working on lower execution timeframes (e.g., 1-minute or 5-minute charts) to effortlessly monitor macro trend alignment and EMA support/resistance zones from higher timeframes (e.g., 15m, 1h, or 4h) without switching charts.

---

### Key Features
* **Selectable Target Timeframe:** Choose any timeframe (1m, 5m, 15m, 1h, 4h, 1D, etc.) to fetch EMA data from.
* **7 Customizable EMAs:** Define 7 individual EMA lengths (e.g., EMA 9, 20, 50, 100, 150, 200, 800) to monitor full trend structure.
* **Consolidation Detection:** Identifies when price is compressing or trading close to a specific EMA line, marking it as a **RANGE 🟡** state.
* **Clean UI:** Displays chosen timeframe in the table header alongside active EMA lengths and clear color-coded statuses.

---

### How to Use
1. **Set Target Timeframe:** In the settings, choose the macro timeframe you want to base your analysis on (e.g., 15m).
2. **Configure EMAs:** Input your preferred EMA lengths.
3. **Gauge Trend Strength:** 
   * **Full Bullish Alignment:** All or most EMAs show `BULLISH 🟢`.
   * **Compression/Ranging:** Multiple EMAs show `RANGE 🟡`, warning of choppy price action.

---

## Source Code

````pine
//@version=6
indicator("Single Timeframe Multi-EMA Trend Table", overlay=true)

// --- INPUT PARAMETERS ---
selectedTf = input.timeframe("15", "Select Target Timeframe", group="Timeframe Settings")

// 7 Custom EMA Lengths
ema1Len = input.int(10,   "EMA 1 Length", minval=1, group="EMA Lengths")
ema2Len = input.int(20,  "EMA 2 Length", minval=1, group="EMA Lengths")
ema3Len = input.int(50,  "EMA 3 Length", minval=1, group="EMA Lengths")
ema4Len = input.int(100, "EMA 4 Length", minval=1, group="EMA Lengths")
ema5Len = input.int(150, "EMA 5 Length", minval=1, group="EMA Lengths")
ema6Len = input.int(200, "EMA 6 Length", minval=1, group="EMA Lengths")
ema7Len = input.int(400, "EMA 7 Length", minval=1, group="EMA Lengths")

// Consolidation Settings
useConsol   = input.bool(false, "Enable Consolidation Detection", group="Trend Settings")
consolRange = input.float(0.15, "Consolidation Threshold (%)", minval=0.01, step=0.05, group="Trend Settings")

// Table Display Settings
tablePosInput = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Table Display")
textSizeInput = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Table Display")

// --- HELPER FUNCTION FOR BIAS CALCULATION ---
calcBias(float tfClose, float tfEma) =>
    if na(tfClose) or na(tfEma)
        ["WAIT", color.gray]
    else
        diffPcnt = math.abs(tfClose - tfEma) / tfEma * 100
        
        if useConsol and diffPcnt < consolRange
            ["RANGE 🟡", color.orange]
        else if tfClose > tfEma
            ["BULLISH 🟢", color.green]
        else
            ["BEARISH 🔴", color.red]

// --- DATA REQUESTS FROM SELECTED TIMEFRAME ---
[tfClose, e1, e2, e3, e4, e5, e6, e7] = request.security(
     syminfo.tickerid, 
     selectedTf, 
     [close, ta.ema(close, ema1Len), ta.ema(close, ema2Len), ta.ema(close, ema3Len), ta.ema(close, ema4Len), ta.ema(close, ema5Len), ta.ema(close, ema6Len), ta.ema(close, ema7Len)]
 )

// --- BIAS EVALUATION ---
[s1, col1] = calcBias(tfClose, e1)
[s2, col2] = calcBias(tfClose, e2)
[s3, col3] = calcBias(tfClose, e3)
[s4, col4] = calcBias(tfClose, e4)
[s5, col5] = calcBias(tfClose, e5)
[s6, col6] = calcBias(tfClose, e6)
[s7, col7] = calcBias(tfClose, e7)

// --- TABLE POSITIONING AND SIZE MAPPING ---
pos = tablePosInput == "Top Right" ? position.top_right : tablePosInput == "Top Left" ? position.top_left : tablePosInput == "Bottom Right" ? position.bottom_right : position.bottom_left
txtSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : textSizeInput == "Normal" ? size.normal : size.large

var table statusTable = table.new(position=pos, columns=2, rows=8, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    table.set_position(statusTable, pos)

    // Table Header with Dynamic Timeframe Display
    table.cell(statusTable, 0, 0, "EMA (" + selectedTf + " TF)", text_color=color.white, text_size=txtSize, bgcolor=color.new(color.gray, 50))
    table.cell(statusTable, 1, 0, "TREND", text_color=color.white, text_size=txtSize, bgcolor=color.new(color.gray, 50))

    // 7 EMA Rows
    table.cell(statusTable, 0, 1, "EMA " + str.tostring(ema1Len), text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 1, s1,                              text_color=col1,        text_size=txtSize)

    table.cell(statusTable, 0, 2, "EMA " + str.tostring(ema2Len), text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 2, s2,                              text_color=col2,        text_size=txtSize)

    table.cell(statusTable, 0, 3, "EMA " + str.tostring(ema3Len), text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 3, s3,                              text_color=col3,        text_size=txtSize)

    table.cell(statusTable, 0, 4, "EMA " + str.tostring(ema4Len), text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 4, s4,                              text_color=col4,        text_size=txtSize)

    table.cell(statusTable, 0, 5, "EMA " + str.tostring(ema5Len), text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 5, s5,                              text_color=col5,        text_size=txtSize)

    table.cell(statusTable, 0, 6, "EMA " + str.tostring(ema6Len), text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 6, s6,                              text_color=col6,        text_size=txtSize)

    table.cell(statusTable, 0, 7, "EMA " + str.tostring(ema7Len), text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 7, s7,                              text_color=col7,        text_size=txtSize)
````

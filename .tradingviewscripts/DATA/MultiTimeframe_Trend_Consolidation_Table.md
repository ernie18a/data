<!-- tradingview-pine-id: PUB;0f393cefdcbe4cb1b26f5f674fc73e84 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Timeframe Trend & Consolidation Table

Source: https://www.tradingview.com/script/FgOtl7qF-Multi-Timeframe-Trend-Consolidation-Table/

## Description

### Overview
The **Multi-Timeframe Trend & Consolidation Table** is a lightweight dashboard indicator designed to give traders a quick, multi-timeframe overview of the market trend and consolidation status directly on their chart. 

Instead of switching between multiple timeframes or cluttering your chart with dozens of moving averages, this tool consolidates trend data across 10 different timeframes into a clean, customizable table.

---

### Key Features
* **Multi-Timeframe Analysis:** Monitors **1m, 3m, 5m, 10m, 15m, 1h, 4h, 1D, 1W, and 1M** timeframes simultaneously.
* **Customizable EMA Periods:** Set unique Exponential Moving Average (EMA) lengths for every individual timeframe (e.g., EMA 10 for 1m, EMA 50 for 1h, EMA 200 for 1D).
* **Consolidation Detection:** Built-in threshold logic identifies when price is hovering extremely close to the EMA line, signaling potential range-bound/chop market conditions.
* **Dynamic Table UI:** Displays the specific EMA length assigned to each timeframe directly inside the table for clear tracking. Fully customizable position (Top Right, Bottom Left, etc.) and text sizes.

---

### How It Works
The indicator compares the price of each timeframe against its assigned EMA line:

1. **BULLISH 🟢:** Current close price is above the timeframe's EMA (outside the consolidation zone).
2. **BEARISH 🔴:** Current close price is below the timeframe's EMA (outside the consolidation zone).
3. **RANGE 🟡:** Price percentage difference from the EMA is smaller than the set threshold (e.g., within 0.15%), indicating market consolidation or flat movement.

---

### How to Use
1. **Trend Alignment:** Look for timeframes aligning in the same direction (e.g., 1h, 4h, and 1D all green) to trade with the macro trend.
2. **Avoiding Chop:** When lower timeframes show `RANGE 🟡`, it indicates low volatility or moving average compression, warning you to avoid breakout trades or wait for confirmation.
3. **Execution Timeframes:** Tune lower timeframes (1m, 3m, 5m) to fast EMAs for scalp setups, while keeping higher timeframes (1D, 1W) on key levels like the 200 EMA.

---

### Settings & Inputs
* **EMA Lengths per Timeframe:** Set custom EMA periods for all 10 available timeframes.
* **Enable Consolidation Detection:** Toggle range detection on or off based on your strategy preference.
* **Consolidation Threshold (%):** Adjust the distance percentage between close price and EMA to define a range zone (default is 0.15%).
* **Table Display:** Adjust table placement on your screen and text font size.

---

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Trend & Consolidation Table", overlay=true)

// --- INPUT PARAMETERS FOR EMA LENGTHS ---
ema1m  = input.int(10,  "EMA 1m Length",  minval=1, group="EMA Lengths per Timeframe")
ema3m  = input.int(10,  "EMA 3m Length",  minval=1, group="EMA Lengths per Timeframe")
ema5m  = input.int(10,  "EMA 5m Length",  minval=1, group="EMA Lengths per Timeframe")
ema10m = input.int(10,  "EMA 10m Length", minval=1, group="EMA Lengths per Timeframe")
ema15m = input.int(20,  "EMA 15m Length", minval=1, group="EMA Lengths per Timeframe")
ema1h  = input.int(20,  "EMA 1h Length",  minval=1, group="EMA Lengths per Timeframe")
ema4h  = input.int(50, "EMA 4h Length",  minval=1, group="EMA Lengths per Timeframe")
ema1d  = input.int(50, "EMA 1D Length",  minval=1, group="EMA Lengths per Timeframe")
ema1w  = input.int(20, "EMA 1W Length",  minval=1, group="EMA Lengths per Timeframe")
ema1M  = input.int(20, "EMA 1M Length",  minval=1, group="EMA Lengths per Timeframe")

// --- OTHER TREND SETTINGS ---
useConsol   = input.bool(true, "Enable Consolidation Detection", group="Trend Settings")
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

// --- DATA REQUESTS ---
[c_1m,   e_1m]   = request.security(syminfo.tickerid, "1",   [close, ta.ema(close, ema1m)])
[c_3m,   e_3m]   = request.security(syminfo.tickerid, "3",   [close, ta.ema(close, ema3m)])
[c_5m,   e_5m]   = request.security(syminfo.tickerid, "5",   [close, ta.ema(close, ema5m)])
[c_10m,  e_10m]  = request.security(syminfo.tickerid, "10",  [close, ta.ema(close, ema10m)])
[c_15m,  e_15m]  = request.security(syminfo.tickerid, "15",  [close, ta.ema(close, ema15m)])
[c_1h,   e_1h]   = request.security(syminfo.tickerid, "60",  [close, ta.ema(close, ema1h)])
[c_4h,   e_4h]   = request.security(syminfo.tickerid, "240", [close, ta.ema(close, ema4h)])
[c_1d,   e_1d]   = request.security(syminfo.tickerid, "D",   [close, ta.ema(close, ema1d)])
[c_1w,   e_1w]   = request.security(syminfo.tickerid, "W",   [close, ta.ema(close, ema1w)])
[c_1M,   e_1M]   = request.security(syminfo.tickerid, "M",   [close, ta.ema(close, ema1M)])

// --- BIAS EVALUATION ---
[s_1m,   col_1m]   = calcBias(c_1m, e_1m)
[s_3m,   col_3m]   = calcBias(c_3m, e_3m)
[s_5m,   col_5m]   = calcBias(c_5m, e_5m)
[s_10m,  col_10m]  = calcBias(c_10m, e_10m)
[s_15m,  col_15m]  = calcBias(c_15m, e_15m)
[s_1h,   col_1h]   = calcBias(c_1h, e_1h)
[s_4h,   col_4h]   = calcBias(c_4h, e_4h)
[s_1d,   col_1d]   = calcBias(c_1d, e_1d)
[s_1w,   col_1w]   = calcBias(c_1w, e_1w)
[s_1M,   col_1M]   = calcBias(c_1M, e_1M)

// --- TABLE POSITIONING AND SIZE MAPPING ---
pos = tablePosInput == "Top Right" ? position.top_right : tablePosInput == "Top Left" ? position.top_left : tablePosInput == "Bottom Right" ? position.bottom_right : position.bottom_left
txtSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : textSizeInput == "Normal" ? size.normal : size.large

var table statusTable = table.new(position=pos, columns=2, rows=11, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    table.set_position(statusTable, pos)

    // Table Header
    table.cell(statusTable, 0, 0, "TIMEFRAME", text_color=color.white, text_size=txtSize, bgcolor=color.new(color.gray, 50))
    table.cell(statusTable, 1, 0, "BIAS", text_color=color.white, text_size=txtSize, bgcolor=color.new(color.gray, 50))

    // Data Rows with Dynamic EMA Display
    table.cell(statusTable, 0, 1, "1m (EMA "   + str.tostring(ema1m)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 1, s_1m,                                       text_color=col_1m,     text_size=txtSize)

    table.cell(statusTable, 0, 2, "3m (EMA "   + str.tostring(ema3m)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 2, s_3m,                                       text_color=col_3m,     text_size=txtSize)

    table.cell(statusTable, 0, 3, "5m (EMA "   + str.tostring(ema5m)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 3, s_5m,                                       text_color=col_5m,     text_size=txtSize)

    table.cell(statusTable, 0, 4, "10m (EMA "  + str.tostring(ema10m)  + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 4, s_10m,                                      text_color=col_10m,    text_size=txtSize)

    table.cell(statusTable, 0, 5, "15m (EMA "  + str.tostring(ema15m)  + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 5, s_15m,                                      text_color=col_15m,    text_size=txtSize)

    table.cell(statusTable, 0, 6, "1h (EMA "   + str.tostring(ema1h)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 6, s_1h,                                       text_color=col_1h,     text_size=txtSize)

    table.cell(statusTable, 0, 7, "4h (EMA "   + str.tostring(ema4h)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 7, s_4h,                                       text_color=col_4h,     text_size=txtSize)

    table.cell(statusTable, 0, 8, "1D (EMA "   + str.tostring(ema1d)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 8, s_1d,                                       text_color=col_1d,     text_size=txtSize)

    table.cell(statusTable, 0, 9, "1W (EMA "   + str.tostring(ema1w)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 9, s_1w,                                       text_color=col_1w,     text_size=txtSize)

    table.cell(statusTable, 0, 10, "1M (EMA "  + str.tostring(ema1M)   + ")", text_color=color.white, text_size=txtSize)
    table.cell(statusTable, 1, 10, s_1M,                                      text_color=col_1M,     text_size=txtSize)
````

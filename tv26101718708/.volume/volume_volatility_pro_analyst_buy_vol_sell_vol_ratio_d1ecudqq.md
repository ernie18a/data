# Volume & Volatility Pro Analyst Buy Vol: Sell Vol Ratio

- url: https://www.tradingview.com/script/D1ECUDQQ-Volume-Volatility-Pro-Analyst-Buy-Vol-Sell-Vol-Ratio/
- type: indicator
- pine_id: PUB;3021b0a25daf4e8597cab640ff9c2231
- version: 1.0

## Description

### Overview
The **Volume & Volatility Pro Analyst (V&V-Surge) ** is an all-in-one analysis tool designed to look beyond basic volume bars. Instead of coloring volume strictly by whether a candle closed up or down, this indicator breaks down the internal structure of each candlestick to isolate buying and selling pressure. It pairs volume diagnostics with an Intrinsic Daily Volatility matrix (ADR%) to evaluate market exhaustion and trend sustainability in real-time.

### Key Features
1. **Intraday Volume Breakdown: ** Deconstructs standard transaction volume into **Buy Volume** and **Sell Volume** by mathematically evaluating the candlestick's body size and wicks (lower wick pressure indicates buying; upper wick pressure indicates selling).
2. **Real-Time Buy: Sell Ratio (B:S):** A live updating quotient tracking dominant market participant control. 
   - A ratio **> 1.0x (Green)** indicates bulls are driving the order book.
   - A ratio **< 1.0x (Red)** indicates bears are in absolute control.
3. **Institutional Volume Surge Warnings: ** Automatically flags institutional blocks or sudden retail frenzies when current volume surpasses an n-period average by a customizable multiplier (Default: 2x). Bars flash **Yellow** during surges.
4. **Volatility Exhaustion Matrix (ADR%): ** Compares the instrument's current intraday move percentage against its Average Daily Range percentage over a specified lookback. 
   - **Green Text/Cell: ** Current move is below the ADR limit (Room to run).
   - **Red Text/Cell: ** Current move has exceeded normal statistical volatility limits (High probability of exhaustion or consolidation).
5. **Localization-Friendly Dashboard: ** Features an integrated toggle switch to format large numerical volume figures into either standard Western Notation (Billions/Millions) or Indian Financial Format (Crores/Lakhs).

### How to Trade with This Tool
- **Trend Confirmation: ** Look for a sustained breakout accompanied by a B:S ratio greater than 1.5x, accompanied by normal ADR levels.
- **Exhaustion Tells: ** If a massive breakout occurs, but "Today's Move" is deeply Red (Exceeding historical ADR%) while a Yellow "Volume Surge" bar prints, it strongly points toward a climax run or trap scenario rather than a clean entry point.
- **Reversal Signals: *[image]https://www.tradingview.com/x/QOQplpo6/[/image]* Watch for institutional volume surges (Yellow bars) forming on key support or resistance zones where the B:S ratio dramatically flips sides on sub-component timeframes.

### Disclaimer
Past performance does not guarantee future results. This tool is meant purely for quantitative visual aid and educational purposes. It does not constitute direct financial advice. Always practice strict risk management.

## Source Code

````pine
//@version=5
// @description Provides a comprehensive intraday breakdown of Buying vs. Selling volume based on price-action wicks, computes real-time Buy/Sell ratios, tracks institutional volume surges, and measures daily volatility against the Average Daily Range (ADR%).
indicator("Volume & Volatility Pro Analyst", shorttitle="V&V-Surge", overlay=false, precision=2)

// --- Inputs ---
g_vol       = "Volume Logic"
lookbackVol = input.int(20, "Volume Lookback Period", minval=1, group=g_vol, tooltip="Number of bars used to calculate average volume.")
surgeMult   = input.float(2.0, "Volume Surge Threshold (x)", minval=0.1, step=0.1, group=g_vol, tooltip="Multiplier for average volume to detect anomalous/institutional activity.")

g_adr       = "Volatility (ADR%) Logic"
lookbackADR = input.int(14, "ADR% Lookback Period", minval=1, group=g_adr, tooltip="Lookback period for calculating Average Daily Range percentage.")

g_disp      = "Units & Visuals"
useCrores   = input.bool(true, "Use Indian Units (Cr/L)", group=g_disp, tooltip="Toggle between Indian formatting (Crores/Lakhs) and Western formatting (Billions/Millions).")
upColor     = input.color(color.new(color.green, 50), "Buy Volume Color", group=g_disp)
downColor   = input.color(color.new(color.red, 50), "Sell Volume Color", group=g_disp)
surgeColor  = input.color(color.yellow, "Volume Surge Color", group=g_disp)

// --- Formatting Function ---
formatVol(val) =>
    absVal = math.abs(val)
    res = ""
    if useCrores
        if absVal >= 10000000 
            res := str.tostring(absVal / 10000000, "#.##") + "Cr"
        else if absVal >= 100000 
            res := str.tostring(absVal / 100000, "#.##") + "L"
        else 
            res := str.tostring(absVal, "#")
    else
        if absVal >= 1000000000 
            res := str.tostring(absVal / 1000000000, "#.##") + "B"
        else if absVal >= 1000000 
            res := str.tostring(absVal / 1000000, "#.##") + "M"
        else 
            res := str.tostring(absVal, "#")
    res

// --- Calculations ---
totalVol  = volume
rangeVal  = high - low
divisor   = rangeVal == 0 ? 1 : rangeVal

bodySize  = math.abs(close - open)
lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

// Volume attribution using candle structure
buyVol    = totalVol * ((bodySize + lowerWick) / divisor)
sellVol   = totalVol * ((bodySize + upperWick) / divisor)

// Buy to Sell Ratio Calculation (Handles division by zero safely)
bsRatio   = sellVol == 0 ? buyVol : buyVol / sellVol

avgVol    = ta.sma(totalVol, lookbackVol)
isSurge   = totalVol > (avgVol * surgeMult)

// ADR% Logic (Intrinsic Daily Volatility)
dailyRangePct  = ((high - low) / (low == 0 ? 1 : low)) * 100
adrPct         = ta.sma(dailyRangePct, lookbackADR)
currentMovePct = ((high - low) / (low == 0 ? 1 : low)) * 100

// --- Plotting ---
plot(buyVol, title="Buy Vol", style=plot.style_columns, color=isSurge ? surgeColor : upColor)
plot(-sellVol, title="Sell Vol", style=plot.style_columns, color=isSurge ? surgeColor : downColor)
hline(0, "Zero Line", color=color.new(color.gray, 50))

// --- Dashboard ---
var table tb = table.new(position.top_right, 5, 2, border_width=1, border_color=color.gray)

if barstate.islast
    // Header
    table.cell(tb, 0, 0, "Buy Vol", bgcolor=color.new(color.green, 70), text_color=color.white)
    table.cell(tb, 1, 0, "Sell Vol", bgcolor=color.new(color.red, 70), text_color=color.white)
    table.cell(tb, 2, 0, "B:S Ratio", bgcolor=color.new(color.purple, 70), text_color=color.white)
    table.cell(tb, 3, 0, "ADR (Avg)", bgcolor=color.new(color.blue, 70), text_color=color.white)
    table.cell(tb, 4, 0, "Today's Move", bgcolor=color.new(color.orange, 70), text_color=color.white)
    
    // Values
    table.cell(tb, 0, 1, formatVol(buyVol), text_color=color.white, bgcolor=color.new(color.black, 40))
    table.cell(tb, 1, 1, formatVol(sellVol), text_color=color.white, bgcolor=color.new(color.black, 40))
    
    // Dynamic Ratio Background Color (Green if Buy > Sell, Red if Sell > Buy)
    color ratioColor = bsRatio >= 1.0 ? color.new(color.green, 30) : color.new(color.red, 30)
    table.cell(tb, 2, 1, str.tostring(bsRatio, "#.##") + "x", bgcolor=ratioColor, text_color=color.white)
    
    table.cell(tb, 3, 1, str.tostring(adrPct, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 40))
    
    // Move % Logic: Green if under average (room to run), Red if over (exhausted)
    color moveColor = currentMovePct > adrPct ? color.new(color.red, 30) : color.new(color.green, 30)
    table.cell(tb, 4, 1, str.tostring(currentMovePct, "#.##") + "%", bgcolor=moveColor, text_color=color.white)
````

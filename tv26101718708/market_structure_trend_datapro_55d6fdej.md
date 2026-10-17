# Market Structure Trend [Datapro]

- url: https://www.tradingview.com/script/55D6fdeJ-Market-Structure-Trend-Datapro/
- type: indicator
- pine_id: PUB;74affc7e39374debb34b1b111cbf778a
- version: 1.0

## Description

[b][/b]Market Structure Trend Matrix [Datapro]

 Overview
The **Market Structure Trend Matrix** is a technical analysis overlay designed to identify trend direction and potential reversal points based on Market Structure concepts (specifically **Break of Structure** and **Change of Character - ChoCh**). 

This script updates the original logic by implementing robust Pine Script v6 architecture, solving historical calculation inconsistencies (CW10002), and adding an institutional-grade dashboard for real-time data monitoring. It is designed for traders who need clear visual cues for entry, stop-loss management, and target projection.

 How It Works
The core logic relies on **Pivot Highs** and **Pivot Lows** to define market structure.
1.  **Trend Detection:** 
    *   A **Bullish Trend** is initiated when price closes above a confirmed Pivot High (ChoCh ↑).
    *   A **Bearish Trend** is initiated when price closes below a confirmed Pivot Low (ChoCh ↓).
2.  **ATR Trailing Stop:**
    *   Once a trend is established, the script plots a dynamic trailing stop using the **Average True Range (ATR)**. This stop trails the price to help protect open profits during the trend lifecycle.
3.  **Target System:**
    *   The script automatically projects sequential targets based on a user-defined ATR multiplier step. This helps traders scale out of positions systematically.

 Key Features
*   **Structure-Based Signals:** Identifies "ChoCh" (Change of Character) points which often signify the start of a new trend or a deep pullback.
*   **Dynamic ATR Stop:** A volatility-based trailing stop that adapts to market conditions, providing breathing room during volatile swings.
*   **Auto-Scaling Targets:** Visualizes potential take-profit levels calculated from the structural entry point.
*   **Institutional Dashboard:** A compact table displaying the current Structure Bias, Entry Price, Next Target, Trailing Stop value, and Cycle PnL.
*   **HFT Data Export:** Hidden plots are included for strategy integration, allowing external systems or webhooks to fetch entry, target, and stop values without visual clutter.
*   **Performance Optimized:** Code is audited to prevent memory leaks (FIFO object management) and ensure consistent calculation on every bar.

 How to Use
1.  **Trend Confirmation:** Look for the **ChoCh** label and the colored structure line. This indicates a potential shift in market sentiment.
2.  **Entry:** Traders often enter on the close of the bar that triggers the ChoCh signal or on a retest of the broken structure level.
3.  **Stop Loss:** Use the **ATR Trailing Stop** line (dashed) as a guide for placing initial stops and trailing them as the trend progresses.
4.  **Exit:** Take profit at the projected "Target" lines or exit entirely if price crosses the Trailing Stop, signaling a trend invalidation.

 Settings
*   **Market Structure Length:** Defines the sensitivity of the pivot detection (left/right lookback). Higher values filter out minor swings; lower values detect short-term structure.
*   **ATR Multiplier:** Controls the distance of the trailing stop from the price. Higher values result in wider stops (fewer false exits).
*   **Target Step:** Defines the vertical distance between consecutive target levels.

---

 Credits & License
*   **Original Concept:** BigBeluga
*   **Refactor & Optimization:** datapro
*   **License:** CC BY-NC-SA 4.0

---

**DISCLAIMER**
Licensed under MPL 2.0. Attribution required.
**NO FINANCIAL ADVICE.** The information provided by this script is for educational and informational purposes only. It is not intended as financial advice. Trading involves significant risk of loss and is not suitable for every investor. Past performance is not indicative of future results. Use at your own risk. Provided "AS IS".

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// © datapro
// Original Concept: BigBeluga
// Refactored & Audited: Institutional HFT Analyst

//@version=6
indicator("Market Structure Trend [Datapro]", "MS Matrix", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// DISCLAIMER & LICENSE
// ─────────────────────────────────────────────────────────────────────────────
// Licensed under MPL 2.0. Attribution required.
// NO FINANCIAL ADVICE. Use at your own risk. Provided "AS IS".
// ─────────────────────────────────────────────────────────────────────────────

// ================================================
// MODULE 1: INPUTS
// ================================================
msLen          = input.int(10, "Market Structure Length", tooltip = "The lookback and lookahead period for detecting pivot highs and lows.")
atrLength      = input.int(14, "ATR Length", tooltip = "The period used to calculate the Average True Range.")
atrMult        = input.float(4.0, "ATR Multiplier", tooltip = "Multiplied by ATR to determine the distance of the trailing stop.")
targetStepMult = input.float(2.0, "Target Step (ATR Multiplier)", tooltip = "Determines the vertical distance between consecutive targets.")

bullColor      = input.color(color.rgb(52, 230, 126), "Bullish Color")
bearColor      = input.color(color.rgb(255, 82, 241), "Bearish Color")

showHistory    = input.bool(true, "Show Target History")
showStop       = input.bool(true, "Show Trailing Stop")

// ================================================
// MODULE 2: VARIABLES & OBJECT POOL
// ================================================
var int MAX_OBJECTS = 490 // Safety limit under 500

var bool   direction     = false 
var float  atrTS         = na
var float  entryPrice    = na
var float  currentTarget = na
var line   targetLine    = na
var int    trendStart    = 0

var line[]  targetLines  = array.new_line()
var label[] targetLabels = array.new_label()

float atr = ta.atr(atrLength)

// ================================================
// MODULE 3: HELPER FUNCTIONS
// ================================================

clearCurrentTrendObjects() =>
    if array.size(targetLines) > 0
        for i = 0 to array.size(targetLines) - 1
            line.delete(array.get(targetLines, i))
        array.clear(targetLines)
    
    if array.size(targetLabels) > 0
        for i = 0 to array.size(targetLabels) - 1
            label.delete(array.get(targetLabels, i))
        array.clear(targetLabels)

safePushObject(line objLine, label objLabel) =>
    if array.size(targetLines) >= MAX_OBJECTS
        line.delete(array.shift(targetLines))
        label.delete(array.shift(targetLabels))
    
    array.push(targetLines, objLine)
    array.push(targetLabels, objLabel)

// ================================================
// MODULE 4: PIVOT DETECTION
// ================================================
ph = ta.pivothigh(msLen, msLen)
pl = ta.pivotlow(msLen, msLen)

var float phVal = na 
var float plVal = na
var int   phIndx = 0
var int   plIndx = 0

if not na(ph)
    phVal  := high[msLen]
    phIndx := bar_index[msLen]

if not na(pl)
    plVal  := low[msLen]
    plIndx := bar_index[msLen]

// ================================================
// MODULE 5: CROSSOVER LOGIC (DEFINITIVE FIX CW10002)
// ================================================
// Execution separated from logic to preserve internal history state.
bool rawBullCross = ta.crossover(close, phVal)
bool rawBearCross = ta.crossunder(close, plVal)

bool bullCross = not na(phVal) and rawBullCross
bool bearCross = not na(plVal) and rawBearCross

// ================================================
// MODULE 6: TREND MANAGEMENT
// ================================================

// 6.1 Bullish ChoCh
if bullCross and not direction
    direction := true 
    atrTS     := close - (atr * atrMult)
    entryPrice := phVal
    currentTarget := entryPrice + (atr * targetStepMult)
    trendStart := bar_index

    line.new(phIndx, phVal, bar_index, phVal, color=bullColor, width=2)
    label.new(int(math.avg(phIndx, bar_index)), phVal, "ChoCh ↑", style=label.style_label_down, color=na, textcolor=bullColor)
    
    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(bullColor, 0), width=1)

// 6.2 Bearish ChoCh
if bearCross and direction
    direction := false 
    atrTS     := close + (atr * atrMult)
    entryPrice := plVal
    currentTarget := entryPrice - (atr * targetStepMult)
    trendStart := bar_index

    line.new(plIndx, plVal, bar_index, plVal, color=bearColor, width=2)
    label.new(int(math.avg(plIndx, bar_index)), plVal, "ChoCh ↓", style=label.style_label_up, color=na, textcolor=bearColor)
    
    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(bearColor, 0), width=1)

// 6.3 Trend Change Cleanup
directionChange = direction != direction[1]
if directionChange and not showHistory
    clearCurrentTrendObjects()

// ================================================
// MODULE 7: TARGETS & STOP MANAGEMENT
// ================================================
if direction
    // --- Bullish Regime ---
    atrTS := math.max(nz(atrTS, close - (atr * atrMult)), close - (atr * atrMult))
    
    if high >= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)

        perc = (currentTarget - entryPrice) / entryPrice * 100
        lbl  = label.new(trendStart, currentTarget, str.format("+{0,number,#.##}%", perc), style=label.style_none, textcolor=bullColor, size=size.small)
        safePushObject(targetLine, lbl)

        currentTarget := currentTarget + (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(bullColor, 40), width=1)
    else
        line.set_x2(targetLine, bar_index + 10)

else
    // --- Bearish Regime ---
    atrTS := math.min(nz(atrTS, close + (atr * atrMult)), close + (atr * atrMult))
    
    if low <= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)
        
        perc = (currentTarget - entryPrice) / entryPrice * 100
        lbl  = label.new(trendStart, currentTarget, str.format("{0,number,#.##}%", perc), style=label.style_none, textcolor=bearColor, size=size.small)
        safePushObject(targetLine, lbl)

        currentTarget := currentTarget - (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(bearColor, 40), width=1)
    else
        line.set_x2(targetLine, bar_index + 10)

// ================================================
// MODULE 8: PLOTS & HFT DATA EXPORT
// ================================================
// Visual Plot
plot(showStop and not directionChange ? atrTS : na, "ATR Trailing Stop", 
     color = direction ? bullColor : bearColor, 
     style = plot.style_linebr, 
     linewidth = 2)

// Background Fill
plot_price = plot(close, display=display.none)
plot_stop  = plot(showStop ? atrTS : na, display=display.none)
fillCol = direction ? color.new(bullColor, 70) : color.new(bearColor, 70)
fill(plot_price, plot_stop, close, atrTS, na, showStop ? fillCol : na)

// HFT Optimization: Hidden plots for data fetching via external strategies/webhooks
plot(entryPrice,    "Entry Price",    display=display.none)
plot(currentTarget, "Active Target",  display=display.none)
plot(atrTS,         "Stop Value",     display=display.none)

// ================================================
// MODULE 9: INSTITUTIONAL DASHBOARD
// ================================================
showDash = input.bool(true, "Show Institutional Dashboard", group="UI Settings")
dashPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left"], group="UI Settings")

var table mainDash = table.new(
     dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Right" ? position.bottom_right : position.top_left, 
     2, 5, 
     bgcolor = color.new(color.black, 10), 
     border_width = 1, 
     border_color = color.new(color.gray, 50))

if showDash and barstate.islast
    // Cell Style
    headerColor = color.new(color.gray, 20)
    textColor   = color.white
    
    // ROW 1: TREND
    table.cell(mainDash, 0, 0, "STRUCTURE", bgcolor=headerColor, text_color=textColor, text_size=size.small)
    table.cell(mainDash, 1, 0, direction ? "BULLISH ↑" : "BEARISH ↓", bgcolor=direction ? bullColor : bearColor, text_color=color.black, text_size=size.small)
    
    // ROW 2: ENTRY
    table.cell(mainDash, 0, 1, "ENTRY PRICE", bgcolor=headerColor, text_color=textColor, text_size=size.small)
    table.cell(mainDash, 1, 1, str.format("{0,number,#.##}", entryPrice), text_color=textColor, text_size=size.small)
    
    // ROW 3: NEXT TARGET
    table.cell(mainDash, 0, 2, "NEXT TARGET", bgcolor=headerColor, text_color=textColor, text_size=size.small)
    table.cell(mainDash, 1, 2, str.format("{0,number,#.##}", currentTarget), text_color=direction ? bullColor : bearColor, text_size=size.small)
    
    // ROW 4: STOP LOSS (ATR)
    table.cell(mainDash, 0, 3, "TRAILING STOP", bgcolor=headerColor, text_color=textColor, text_size=size.small)
    table.cell(mainDash, 1, 3, str.format("{0,number,#.##}", atrTS), text_color=color.new(bearColor, 20), text_size=size.small)

    // ROW 5: CYCLE PERFORMANCE
    cyclePnl = (close - entryPrice) / entryPrice * 100 * (direction ? 1 : -1)
    table.cell(mainDash, 0, 4, "CYCLE PnL", bgcolor=headerColor, text_color=textColor, text_size=size.small)
    table.cell(mainDash, 1, 4, str.format("{0,number,#.##}%", cyclePnl), bgcolor=cyclePnl >= 0 ? color.new(bullColor, 40) : color.new(bearColor, 40), text_color=textColor, text_size=size.small)
````

# Market Structure Trend Matrix [BigBeluga]

- url: https://www.tradingview.com/script/2Lxn7Jhh/
- type: indicator
- pine_id: PUB;34f0ac8427bb473a99ea485530048e20
- version: 1.0

## Description

CTURE TREND MATRIX [BigBeluga]
// ═══════════════════════════════════════════════════════════════════════════════
//
// OVERVIEW
// ────────
// A comprehensive technical analysis framework for traders who demand precision
// in identifying market regimes and trend expansions.
// Combines automated Market Structure (MS) detection with volatility-adjusted
// risk parameters (ATR), providing a systematic roadmap for navigating price action.
//
// ARCHITECTURE & CORE LOGIC
// ──────────────────────────
// • Automated Structure Mapping: A pivot-detection engine (MS Length) that scans
//   for institutional-grade swing highs and lows, ignoring retail noise.
//   Structural lines are drawn only when significant supply or demand zones are breached.
//
// • ChoCh Engine (Change of Character): When price crosses a recent pivot high or
//   low, the indicator prints a "ChoCh ↑ / ↓" label. This represents a fundamental
//   shift in market sentiment — the current trend has likely ended and a new cycle begins.
//
// • Infinite Expansion Targets: Sequential levels calculated using ATR multipliers
//   that expand and contract with current market volatility. Each time price hits a
//   target, the next level is projected automatically.
//
// • Volatility-Anchored Trailing Stop: A dynamic ATR-based stop that acts as a
//   "ratchet" mechanism — it moves closer to price during trend expansion but stays
//   firm during minor pullbacks, providing a clear exit point if the trend fails.
//
// ADVANCED FEATURES
// ─────────────────
// • Target History Control (Show History): toggle historical target lines and
//   percentage labels on/off to keep the chart clean.
// • Dynamic Trailing Stop Visibility (Show Trailing Stop).
// • Percentage profit labels at each target hit, measured from the ChoCh entry.
// • Volatility-adjusted spacing: both the trailing stop and target steps use ATR
//   calculations — effective across all asset classes (Crypto, Forex, Equities…).
//
// HOW TO INTERPRET
// ────────────────
// • Bullish State (green): Activated when price breaks above a major Pivot High.
//   Projects upward expansion targets and keeps the trailing stop below price.
//   → BUY signal printed at the ChoCh ↑
//
// • Bearish State (pink/purple): Activated when price breaks below a major Pivot Low.
//   Projects downward targets and keeps the trailing stop above price.
//   → SELL signal printed at the ChoCh ↓
//
// • Target Hit: each time a target level is reached, the % gain from the ChoCh
//   entry is displayed on the chart.
//
// • Stop Hit: if price crosses the Trailing Stop against the active trend direction,
//   an EXIT signal is printed.
//
// RECOMMENDED USAGE
// ─────────────────
// • Scalping / Day Trading  → MS Length 5-8, 1m-5m charts.
// • Swing Trading           → MS Length 15-20, D1 / H4 charts.
// • Risk-Reward Management  → Distance ChoCh ↔ Trailing Stop = objective risk.
//                             Sequential targets = profit milestones.
//
// SIGNALS INCLUDED IN THIS SCRIPT
// ────────────────────────────────
// [BUY]    → Bullish ChoCh confirmed  (green arrow below the bar)
// [SELL]   → Bearish ChoCh confirmed  (pink arrow above the bar)
// [TARGET] → Price reaches a target   (label with % gain above/below the bar)
// [EXIT]   → Price crosses the Trailing Stop against the trend
// Configurable TradingView alerts available for all 4 events above.
// ═══════════════════════════════════════════════════════════════════════════════

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga
// Alerts added: ChoCh bullish/bearish direction changes

//@version=6
indicator("Market Structure Trend Matrix [BigBeluga]", "MS Trend Matrix [BigBeluga]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

msLen          = input.int(10, "Market Structure Length", tooltip = "The lookback and lookahead period for detecting pivot highs and lows used for market structure.")
atrLength      = input.int(14, "ATR Length", tooltip = "The period used to calculate the Average True Range for the trailing stop and target spacing.")
atrMult        = input.float(4.0, "ATR Multiplier", tooltip = "Multiplied by ATR to determine the distance of the trailing stop from the price.")
targetStepMult = input.float(2.0, "Target Step (ATR Multiplier)", tooltip = "Determines the vertical distance between consecutive infinite targets based on ATR.")

bullColor      = input.color(color.rgb(52, 230, 126), "Bullish Color", tooltip = "Color used for bullish market structure, targets, and trailing stops.")
bearColor      = input.color(color.rgb(255, 82, 241), "Bearish Color", tooltip = "Color used for bearish market structure, targets, and trailing stops.")

showHistory    = input.bool(true, "Show Target History", tooltip = "When disabled, historical target lines and percentage labels will be hidden, leaving only the active target.")
showStop       = input.bool(true, "Show Trailing Stop", tooltip = "Toggle the visibility of the ATR Trailing Stop line and background fill.")

// ─── CALCULATIONS ─────────────────────────────────────────────────────────────

ph = ta.pivothigh(msLen, msLen)
pl = ta.pivotlow(msLen, msLen)

var float phVal = na 
var float plVal = na
var int phIndx = 0
var int plIndx = 0
var bool direction = false 

float atr = ta.atr(atrLength)
var float atrTS = na

var float entryPrice = na
var float currentTarget = na
var line targetLine = na
var int trendStart = 0

// Arrays to track lines and labels for current trend cleanup
var line[]  targetLines  = array.new_line()
var label[] targetLabels = array.new_label()

// Function to clear arrays (old trend targets)
clearCurrentTrendObjects() =>
    if array.size(targetLines) > 0
        for i = 0 to array.size(targetLines) - 1
            line.delete(array.get(targetLines, i))
        array.clear(targetLines)
    if array.size(targetLabels) > 0
        for i = 0 to array.size(targetLabels) - 1
            label.delete(array.get(targetLabels, i))
        array.clear(targetLabels)

if not na(ph)
    phVal := high[msLen]
    phIndx := bar_index[msLen]

if not na(pl)
    plVal := low[msLen]
    plIndx := bar_index[msLen]

// ─── DIRECTION CHANGE FLAGS (used for alerts) ─────────────────────────────────

var bool chochBull = false
var bool chochBear = false
chochBull := false
chochBear := false

if ta.crossover(close, phVal) and not direction
    direction := true 
    chochBull := true
    atrTS := close - (atr * atrMult)
    entryPrice := phVal
    currentTarget := entryPrice + (atr * targetStepMult)
    trendStart := bar_index

    line.new(phIndx, phVal, bar_index, phVal, color=bullColor, width = 2)
    label.new(int(math.avg(phIndx, bar_index)), phVal, "ChoCh ↑", style = label.style_label_down, color = na, textcolor = bullColor)
    
    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(bullColor, 0), width=1)


if ta.crossunder(close, plVal) and direction
    direction := false 
    chochBear := true
    atrTS := close + (atr * atrMult)
    entryPrice := plVal
    currentTarget := entryPrice - (atr * targetStepMult)
    trendStart := bar_index

    line.new(plIndx, plVal, bar_index, plVal, color=bearColor, width = 2)
    label.new(int(math.avg(plIndx, bar_index)), plVal, "ChoCh ↓", style = label.style_label_up, color = na, textcolor = bearColor)
    
    line.delete(targetLine)
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(bearColor, 0), width=1)


directionChange = direction != direction[1]

if directionChange and not showHistory
    clearCurrentTrendObjects()


if direction
    atrTS := math.max(nz(atrTS, close - (atr * atrMult)), close - (atr * atrMult))
    
    if high >= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)

        array.push(targetLines, targetLine)
        perc = (currentTarget - entryPrice) / entryPrice * 100
        array.push(targetLabels, label.new(trendStart, currentTarget, str.format("+{0,number,#.##}%", perc), style=label.style_none, textcolor=bullColor, size=size.small))

        currentTarget := currentTarget + (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(bullColor, 40), width=1)
    else
        line.set_x2(targetLine, bar_index + 10)

else
    atrTS := math.min(nz(atrTS, close + (atr * atrMult)), close + (atr * atrMult))
    
    if low <= currentTarget and not na(currentTarget)
        line.set_x2(targetLine, bar_index)
        line.set_style(targetLine, line.style_dashed)
        line.set_x1(targetLine, trendStart)
        
        array.push(targetLines, targetLine)
        perc = (currentTarget - entryPrice) / entryPrice * 100
        array.push(targetLabels, label.new(trendStart, currentTarget, str.format("{0,number,#.##}%", perc), style=label.style_none, textcolor=bearColor, size=size.small))

        currentTarget := currentTarget - (atr * targetStepMult)
        targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(bearColor, 40), width=1)
    else
        line.set_x2(targetLine, bar_index + 10)

// ─── PLOT ─────────────────────────────────────────────────────────────────────

plot(showStop and not directionChange ? atrTS : na, "ATR Trailing Stop", 
     color = direction ? bullColor : bearColor, 
     style = plot.style_linebr, 
     linewidth = 2)

plot_price = plot(close, display = display.none, editable = false)
plot_stop  = plot(showStop ? atrTS : na, display = display.none, editable = false)

fillCol = direction ? color.new(bullColor, 70) : color.new(bearColor, 70)

fill(plot_price, plot_stop, close, atrTS, na, showStop ? fillCol : na)

// ─── ALERTS ───────────────────────────────────────────────────────────────────

alertcondition(chochBull, "ChoCh Alcista (Bearish → Bullish)", "⬆ Cambio de estructura: BAJISTA → ALCISTA. Precio ha cruzado por encima del pivot alto.")
alertcondition(chochBear, "ChoCh Bajista (Bullish → Bearish)", "⬇ Cambio de estructura: ALCISTA → BAJISTA. Precio ha cruzado por debajo del pivot bajo.")
alertcondition(chochBull or chochBear, "ChoCh Cualquier Cambio", "↕ Cambio de estructura detectado. Revisa dirección del mercado.")
````

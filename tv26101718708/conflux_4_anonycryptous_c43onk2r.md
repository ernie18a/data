# Conflux 4 | Anonycryptous

- url: https://www.tradingview.com/script/C43oNk2R-Conflux-4-Anonycryptous/
- type: indicator
- pine_id: PUB;8bd8f693497f4ee380eb08c58abd6537
- version: 1.0

## Description

Conflux 4 | Anonycryptous
Description & user manual

Why this indicator is different
Most signal indicators fire on one condition. Price crosses a moving average. RSI hits a level. A candle closes above a line. One condition. One trigger. And because one condition alone is never enough, the signals come constantly — in trends, against trends, in chop, in news spikes — with no filter for whether the setup actually makes sense.

Conflux 4 works differently.
It does not fire on one condition. It requires four independent filters to agree at the same moment, in the same direction, before anything appears on the chart. Trend, momentum, volatility structure, and trend strength. All four. If one filter disagrees, nothing is drawn. Not a reduced signal. Nothing.
The result is an indicator that is quiet most of the time — and deliberate when it speaks.
When a signal does appear, Conflux 4 does not just mark a dot and leave you to figure out the rest. It draws a complete trade block automatically: entry, stop, and up to four take profit levels. The stop trails dynamically after the first target is reached, moving to breakeven and continuing from there. The trade is managed visually until it resolves.
The dashboard shows the live state of every filter at all times, so you always know why a signal appeared — or why it did not.

Important notice
Conflux 4 generates signals based on technical filter alignment.
These signals are not financial advice.
They do not predict the future.
They do not guarantee profitability.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
Conflux 4 is a four-filter confluence signal indicator. A signal only fires when all four filters align simultaneously in the same direction. When that happens, a complete trade block is drawn including entry, stop, and take profit levels.

What it includes:
- Four-filter confluence engine: trend, momentum, volatility structure, and trend strength
- Four presets: scalp, daytrader, swing, and manual
- Three stop modes: Supertrend trailing, ATR cap, and fixed percentage
- Automatic trade block with up to four take profit levels
- Dynamic trailing stop that activates after TP1 and moves to breakeven
- Live dashboard showing the state of every filter in real time
- Configurable signal cooldown, bar coloring, and background shading
- Alerts for bullish and bearish signal events

2. The four filters
A signal is only valid when all four conditions align.

2.1 Trend filter — VWMA and EMA alignment
Price must be above the volume weighted moving average and the fast EMA must be above the slow EMA for a bullish signal. Reverse for bearish. This confirms alignment with the prevailing macro trend before anything else is evaluated.

2.2 Momentum filter — RSI threshold
RSI must be above the configured bullish threshold (default 55) for long signals, or below the bearish threshold (default 45) for short signals. This filters out setups forming in low-momentum environments where follow-through is less reliable.

2.3 Volatility filter — Supertrend
The Supertrend indicator must confirm the same direction as the trend filter. Because Supertrend adapts to volatility using ATR, it naturally avoids triggering during minor fluctuations and choppy price action.

2.4 Trend strength filter — ADX
ADX must be above the configured threshold (default 25) to confirm a directional environment. Below this level, price is typically ranging and confluence signals carry less weight. The ADX filter can be disabled if you prefer to evaluate trend strength manually.
If any single filter is not in agreement, no signal is generated.

3. Presets
Conflux 4 includes four preset configurations that adjust the stop mode and risk/reward levels to suit different trading styles.

-Scalp
Designed for short timeframes and futures scalping.
Stop mode: ATR cap.
Take profit levels: 0.5R / 1.0R / 1.5R / 2.0R.

-Daytrader
Designed for mid-timeframe trading on 15 minute to 1 hour charts.
Stop mode: Supertrend trailing.
Take profit levels: 0.5R / 1.0R / 2.0R / 3.0R.

-Swing
Designed for higher timeframe trading on 4 hour and daily charts.
Stop mode: Fixed percentage.
Take profit levels: 1.0R / 1.5R / 2.5R / 3.5R.

-Manual
Full control over all parameters. No preset overrides apply.

4. Stop modes
4.1 Supertrend
The stop follows the Supertrend line dynamically for the duration of the trade. This allows the stop to trail price as long as momentum holds.

4.2 ATR cap
The stop is based on the Supertrend level but capped at a maximum distance defined by an ATR multiplier. This prevents the stop from becoming too wide in volatile conditions.

4.3 Fixed percentage
The stop is placed at a fixed percentage below the entry for long trades and above the entry for short trades. The distance does not change after entry.

5. Trade block logic
When a signal fires, the trade block is drawn automatically:
- Entry line at the signal bar close
- Stop line at the calculated level based on the active stop mode
- Up to four take profit lines at configurable risk/reward ratios
- Visual zone shading between entry and stop, and between entry and each take profit
Trailing behavior:
Before TP1 is reached, the stop holds its initial position. After TP1 is reached, the stop moves to breakeven and begins trailing dynamically. The stop only moves in the direction of the trade — it never moves against it.
The trade block remains active until the stop is hit or the Supertrend flips direction. After resolution, the block is cleared and the indicator is ready for the next setup.

6. Dashboard
The dashboard displays the live state of every filter and the current trade situation. It updates on every bar close.
Rows displayed:
- Trend — overall direction from VWMA and EMA alignment
- VWMA — whether price is above or below the VWMA
- EMA — whether the fast EMA is above or below the slow EMA
- RSI — current RSI value and whether the momentum threshold is met
- Supertrend — current Supertrend direction
- ADX — current ADX value and whether the trend strength threshold is met
- Confluence — number of filters currently in agreement
- Stop mode — active stop mode in use
- Last signal — how many bars since the last signal fired
- Cooldown — whether the cooldown period is still active
- Trade — current trade state: none, long, or short
- TP progress — which take profit levels have been reached
The dashboard header color reflects the current trend direction.

7. Settings
Trend filters
- VWMA length: period of the volume weighted moving average used as the primary trend filter
- Fast EMA / Slow EMA: periods of the two exponential moving averages used for secondary trend confirmation
- Show EMA lines: toggle EMA visibility on the chart
- EMA colors and line width: visual styling options

Momentum
- RSI length: period for the RSI calculation
- Bullish threshold: RSI must be above this level for a long signal (default 55)
- Bearish threshold: RSI must be below this level for a short signal (default 45)

Volatility and Supertrend
- ATR length: period for the ATR calculation used by the Supertrend
- Supertrend multiplier: sensitivity of the Supertrend — higher values produce fewer flips
- Show Supertrend line, fill, and color options

ADX
- Enable ADX filter: toggle the trend strength requirement on or off
- ADX length: period for the ADX calculation
- ADX threshold: minimum ADX value required for a signal (default 25)

Signal settings
- Signal cooldown: minimum number of bars between two signals
- Show signals, signal text, background shading, and bar coloring

Trade block
- Show trade block: toggle the full trade block visualization
- Stop mode: Supertrend, ATR cap, or fixed percentage
- ATR cap multiplier and fixed percentage stop size
- Take profit levels: four configurable RR ratios
- Visual styling for stop, entry, and take profit lines

Dashboard
- Position: top left, top right, bottom left, or bottom right
- Size: tiny, small, or normal
- Visibility toggle

8. How to use
Select a preset or switch to manual and configure the filters to match your trading style and timeframe.
Choose a stop mode. Supertrend is best for trending markets where you want the stop to follow price. ATR cap limits the maximum stop size. Fixed percentage suits swing trades where a known maximum loss matters more than trailing.
Set your risk/reward take profit levels.
Monitor the dashboard. When all four filters align, the confluence count reaches four and a signal fires. The trade block is drawn automatically.
A green marker indicates a bullish signal. A red marker indicates a bearish signal.
The trade block shows the full setup from entry to each take profit level. Decision-making remains entirely with the user.

9. Notes
Low signal frequency is intentional. Four filters aligning simultaneously is a selective condition. Signals will not appear on every bar or even every session. That is by design.
Higher timeframes generally produce more stable signals. On lower timeframes the ADX threshold may need to be lowered or disabled to account for faster price structure.
Signals are more meaningful when they form at key structural levels such as support, resistance, or liquidity zones. Conflux 4 does not evaluate those levels — that context comes from the trader.
The ADX threshold can be adjusted for markets that tend to range. Lowering it increases signal frequency. Raising it makes the filter more selective.

10. Disclaimer
This indicator is provided for educational and informational purposes only.
All outputs are based on historical price action calculations and do not guarantee future results.
Trading financial instruments involves significant risk of loss.
Past performance does not indicate future results.
Use at your own discretion.

## Source Code

````pine


// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Anonycryptous

//@version=6
indicator("Conflux 4 | Anonycryptous", shorttitle="Conflux 4", overlay=true, max_labels_count=100, max_lines_count=100, max_boxes_count=50)

//══════════════════════════════════════════════════════════════════════════════
// GROUP CONSTANTS
//══════════════════════════════════════════════════════════════════════════════
var string G_PRE = "════════ Preset ════════"
var string G_TREND = "════════ Trend Filters ════════"
var string G_MOM = "════════ Momentum Filter ════════"
var string G_VOL = "════════ Volatility & Supertrend ════════"
var string G_ADX = "════════ ADX Trend Strength Filter ════════"
var string G_SIG = "════════ Signal Settings ════════"
var string G_RR = "════════ Trade Block (RR Levels) ════════"
var string G_DASH = "════════ Dashboard ════════"

//══════════════════════════════════════════════════════════════════════════════
// BRAND COLORS
//══════════════════════════════════════════════════════════════════════════════
color BULL_COLOR = #00ff00
color BEAR_COLOR = #ff0000
color NEUT_COLOR = #808080
color GOLD_COLOR = #f5c518

//══════════════════════════════════════════════════════════════════════════════
// PRESET
//══════════════════════════════════════════════════════════════════════════════
preset = input.string("Manual", "Preset", group=G_PRE,
  options=["Manual", "Scalp", "Daytrader", "Swing"],
  tooltip="Scalp = futures/lage TF. Daytrader = 15m-1H. Swing = 4H+. Manual = volledige controle.")

isScalp = preset == "Scalp"
isDay = preset == "Daytrader"
isSwing = preset == "Swing"
isMan = preset == "Manual"

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — TREND FILTERS
//══════════════════════════════════════════════════════════════════════════════
vwmaLen = input.int(200, "VWMA Length", group=G_TREND, minval=1, tooltip="Volume Weighted Moving Average — primary macro trend filter.")
emaFast = input.int(21, "Fast EMA", group=G_TREND, minval=1)
emaSlow = input.int(50, "Slow EMA", group=G_TREND, minval=1)
showEMAs = input.bool(true, "Show EMA Lines", group=G_TREND)
col_emaFast = input.color(#00ff00, "Fast EMA Color", group=G_TREND)
col_emaSlow = input.color(color.rgb(255, 84, 4), "Slow EMA Color", group=G_TREND)
emaWidth = input.int(1, "EMA Line Width", group=G_TREND, minval=1, maxval=4)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — MOMENTUM FILTER
//══════════════════════════════════════════════════════════════════════════════
rsiLen = input.int(14, "RSI Length", group=G_MOM, minval=1)
rsiBullLvl = input.int(55, "RSI Bull Threshold", group=G_MOM, minval=1, maxval=100)
rsiBearLvl = input.int(45, "RSI Bear Threshold", group=G_MOM, minval=1, maxval=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — VOLATILITY & SUPERTREND
//══════════════════════════════════════════════════════════════════════════════
atrLen = input.int(10, "ATR Length", group=G_VOL, minval=1)
stMult = input.float(3.5, "Supertrend Multiplier", group=G_VOL, minval=0.1, step=0.1)
showST = input.bool(true, "Show Supertrend Line", group=G_VOL)
col_stBull = input.color(#00ff00, "Bull Supertrend", group=G_VOL)
col_stBear = input.color(#ff0000, "Bear Supertrend", group=G_VOL)
stWidth = input.int(1, "Supertrend Width", group=G_VOL, minval=1, maxval=4)
showFill = input.bool(true, "Show Fill", group=G_VOL)
fillOp = input.int(40, "Fill Opacity", group=G_VOL, minval=0, maxval=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — ADX FILTER
//══════════════════════════════════════════════════════════════════════════════
useADX = input.bool(true, "Enable ADX Filter", group=G_ADX)
adxLen = input.int(14, "ADX Length", group=G_ADX, minval=1)
adxThr = input.int(25, "ADX Threshold", group=G_ADX, minval=1, maxval=100)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — SIGNAL SETTINGS
//══════════════════════════════════════════════════════════════════════════════
cooldown = input.int(5, "Signal Cooldown (bars)", group=G_SIG, minval=0, maxval=50)
showSignals = input.bool(true, "Show Signals", group=G_SIG)
showSigTxt = input.bool(true, "Show Signal Text", group=G_SIG)
showBG = input.bool(true, "Show Background Color", group=G_SIG)
bgOp = input.int(85, "Background Opacity", group=G_SIG, minval=0, maxval=100)
showBarCol = input.bool(true, "Show Bar Color", group=G_SIG)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — TRADE BLOCK
//══════════════════════════════════════════════════════════════════════════════
showBlock = input.bool(true, "Show Trade Block", group=G_RR)
showEntry = input.bool(true, "Show Entry Line", group=G_RR)
col_entry = input.color(#ffffff, "Entry Color", group=G_RR)
entryWidth = input.int(1, "Entry Width", group=G_RR, minval=1, maxval=4)

// Stop Mode
stopMode = input.string("Supertrend", "Stop Mode", group=G_RR,
  options=["Supertrend", "ATR Cap", "Fixed %"],
  tooltip="Supertrend = stop volgt supertrend. ATR Cap = max ATR × multiplier. Fixed % = vaste % van close.")
stopAtrMult = input.float(1.5, "ATR Cap Multiplier", group=G_RR, minval=0.1, step=0.1,
  tooltip="Alleen actief bij ATR Cap mode. Stop = ATR × multiplier.")
stopFixedPct = input.float(0.3, "Fixed Stop %", group=G_RR, minval=0.01, step=0.05,
  tooltip="Alleen actief bij Fixed % mode. Stop = % van close prijs.")

showTP1 = input.bool(true, "Show TP1", group=G_RR, inline="tp1")
rr1 = input.float(0.5, "RR", group=G_RR, inline="tp1", minval=0.1, step=0.5)
col_tp1 = input.color(color.rgb(0,180,80), "", group=G_RR, inline="tp1")
tp1Width = input.int(1, "", group=G_RR, inline="tp1", minval=1, maxval=4)

showTP2 = input.bool(true, "Show TP2", group=G_RR, inline="tp2")
rr2 = input.float(1.0, "RR", group=G_RR, inline="tp2", minval=0.1, step=0.5)
col_tp2 = input.color(color.rgb(0,210,90), "", group=G_RR, inline="tp2")
tp2Width = input.int(1, "", group=G_RR, inline="tp2", minval=1, maxval=4)

showTP3 = input.bool(true, "Show TP3", group=G_RR, inline="tp3")
rr3 = input.float(1.5, "RR", group=G_RR, inline="tp3", minval=0.1, step=0.5)
col_tp3 = input.color(color.rgb(0,235,100), "", group=G_RR, inline="tp3")
tp3Width = input.int(1, "", group=G_RR, inline="tp3", minval=1, maxval=4)

showTP4 = input.bool(true, "Show TP4", group=G_RR, inline="tp4")
rr4 = input.float(2.0, "RR", group=G_RR, inline="tp4", minval=0.1, step=0.5)
col_tp4 = input.color(color.rgb(0,255,110), "", group=G_RR, inline="tp4")
tp4Width = input.int(2, "", group=G_RR, inline="tp4", minval=1, maxval=4)

showRiskZ = input.bool(true, "Show Risk Zone", group=G_RR)
showRewZ = input.bool(true, "Show Reward Zone", group=G_RR)
rrExtend = input.int(5, "Line Extend (bars right)", group=G_RR, minval=1, maxval=200)
rrLblSz = input.string("Small", "Label Size", group=G_RR, options=["Tiny","Small","Normal"])

//══════════════════════════════════════════════════════════════════════════════
// INPUTS — DASHBOARD
//══════════════════════════════════════════════════════════════════════════════
showDash = input.bool(true, "Show Dashboard", group=G_DASH)
dashPos = input.string("Bottom Right", "Position", group=G_DASH, options=["Top Right","Top Left","Bottom Right","Bottom Left"])
dashSize = input.string("Tiny", "Size", group=G_DASH, options=["Tiny","Small","Normal"])

//══════════════════════════════════════════════════════════════════════════════
// PRESET OVERRIDES
//══════════════════════════════════════════════════════════════════════════════
p_cooldown = isScalp ? 3 : isDay ? 5 : isSwing ? 10 : cooldown
p_adxThr = isScalp ? 20 : isDay ? 25 : isSwing ? 20 : adxThr
p_stopMode = isScalp ? "ATR Cap" : isDay ? "Supertrend" : isSwing ? "Fixed %" : stopMode
p_stopAtrMult = isScalp ? 1.0 : isDay ? 1.5 : isSwing ? 1.5 : stopAtrMult
p_stopFixedPct= isScalp ? 0.2 : isDay ? 0.3 : isSwing ? 0.5 : stopFixedPct

// RR presets
p_rr1 = isScalp ? 0.5 : isDay ? 0.5 : isSwing ? 1.0 : rr1
p_rr2 = isScalp ? 1.0 : isDay ? 1.0 : isSwing ? 1.5 : rr2
p_rr3 = isScalp ? 1.5 : isDay ? 2.0 : isSwing ? 2.5 : rr3
p_rr4 = isScalp ? 2.0 : isDay ? 3.0 : isSwing ? 3.5 : rr4

//══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS — TREND
//══════════════════════════════════════════════════════════════════════════════
vwmaVal = ta.vwma(close, vwmaLen)
emaFastVal = ta.ema(close, emaFast)
emaSlowVal = ta.ema(close, emaSlow)

trendBull = close > vwmaVal and emaFastVal > emaSlowVal
trendBear = close < vwmaVal and emaFastVal < emaSlowVal

//══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS — MOMENTUM
//══════════════════════════════════════════════════════════════════════════════
rsiVal = ta.rsi(close, rsiLen)
momBull = rsiVal > rsiBullLvl
momBear = rsiVal < rsiBearLvl

//══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS — SUPERTREND
//══════════════════════════════════════════════════════════════════════════════
[stVal, stDir] = ta.supertrend(stMult, atrLen)
stBull = stDir < 0
stBear = stDir > 0

//══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS — ADX
//══════════════════════════════════════════════════════════════════════════════
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxOk = not useADX or adxVal > p_adxThr

//══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS — TREND STATE
//══════════════════════════════════════════════════════════════════════════════
isFullBull = trendBull and momBull and stBull and adxOk
isFullBear = trendBear and momBear and stBear and adxOk

var int trend = 0
if isFullBull
    trend := 1
else if isFullBear
    trend := -1
else if (trend == 1 and close < stVal) or (trend == -1 and close > stVal)
    trend := 0

//══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS — SIGNALS WITH COOLDOWN
//══════════════════════════════════════════════════════════════════════════════
var int barsCD = 999
barsCD += 1

rawBull = isFullBull and trend[1] != 1
rawBear = isFullBear and trend[1] != -1

sigBull = rawBull and barsCD >= p_cooldown
sigBear = rawBear and barsCD >= p_cooldown

if sigBull or sigBear
    barsCD := 0

//══════════════════════════════════════════════════════════════════════════════
// STOP DISTANCE CALCULATION
//══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)

getStopDist(isBull) =>
    float rawD = math.abs(close - stVal)
    float d = switch p_stopMode
        "ATR Cap" => math.min(rawD, atrVal * p_stopAtrMult)
        "Fixed %" => close * (p_stopFixedPct / 100)
        => rawD
    d

getStopLevel(isBull) =>
    float d = getStopDist(isBull)
    isBull ? close - d : close + d

//══════════════════════════════════════════════════════════════════════════════
// TRADE BLOCK STATE
//══════════════════════════════════════════════════════════════════════════════
var float entryPx = na
var float stopPx = na
var float tp1Px = na
var float tp2Px = na
var float tp3Px = na
var float tp4Px = na
var int tDir = 0
var int signalBar = na

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool tp4Hit = false

if sigBull
    float d = getStopDist(true)
    entryPx := close
    stopPx := getStopLevel(true)
    tDir := 1
    signalBar := bar_index
    tp1Px := close + d * p_rr1
    tp2Px := close + d * p_rr2
    tp3Px := close + d * p_rr3
    tp4Px := close + d * p_rr4
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp4Hit := false

if sigBear
    float d = getStopDist(false)
    entryPx := close
    stopPx := getStopLevel(false)
    tDir := -1
    signalBar := bar_index
    tp1Px := close - d * p_rr1
    tp2Px := close - d * p_rr2
    tp3Px := close - d * p_rr3
    tp4Px := close - d * p_rr4
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp4Hit := false

// Update stop live
if tDir == 1
    if tp1Hit and stBull
        stopPx := math.max(stopPx, stVal)
    else if tp1Hit
        stopPx := math.max(stopPx, entryPx)
    else if p_stopMode == "Supertrend" and stBull
        stopPx := stVal

if tDir == -1
    if tp1Hit and stBear
        stopPx := math.min(stopPx, stVal)
    else if tp1Hit
        stopPx := math.min(stopPx, entryPx)
    else if p_stopMode == "Supertrend" and stBear
        stopPx := stVal

// Track TP hits
if tDir == 1 and not na(tp1Px)
    if high >= tp1Px
        tp1Hit := true
    if high >= tp2Px
        tp2Hit := true
    if high >= tp3Px
        tp3Hit := true
    if high >= tp4Px
        tp4Hit := true

if tDir == -1 and not na(tp1Px)
    if low <= tp1Px
        tp1Hit := true
    if low <= tp2Px
        tp2Hit := true
    if low <= tp3Px
        tp3Hit := true
    if low <= tp4Px
        tp4Hit := true

// Stop hit check
stopHit = (tDir == 1 and not na(stopPx) and low <= stopPx) or
          (tDir == -1 and not na(stopPx) and high >= stopPx)

// Clear wanneer stop geraakt of supertrend flipt
clearTrade = stopHit or (tDir == 1 and not stBull) or (tDir == -1 and not stBear)

if clearTrade and not (sigBull or sigBear)
    entryPx := na
    stopPx := na
    tp1Px := na
    tp2Px := na
    tp3Px := na
    tp4Px := na
    tDir := 0
    signalBar := na
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp4Hit := false

tradeActive = not na(entryPx)

//══════════════════════════════════════════════════════════════════════════════
// VISUALS — EMA LINES
//══════════════════════════════════════════════════════════════════════════════
plot(showEMAs ? emaFastVal : na, "EMA Fast", color=col_emaFast, linewidth=emaWidth)
plot(showEMAs ? emaSlowVal : na, "EMA Slow", color=col_emaSlow, linewidth=emaWidth)

//══════════════════════════════════════════════════════════════════════════════
// VISUALS — SUPERTREND + FILL
//══════════════════════════════════════════════════════════════════════════════
stColor = stBull ? col_stBull : col_stBear
pClose = plot(close, "Close", color=na, display=display.none)
pST = plot(showST ? stVal : na, "Supertrend", color=stColor, linewidth=stWidth, style=plot.style_linebr)

fill(pST, pClose,
     stBull ? close : stVal,
     stBull ? stVal : close,
     showFill ? (stBull ? color.new(BULL_COLOR, fillOp) : na) : na,
     showFill ? (stBull ? na : color.new(BEAR_COLOR, fillOp)) : na)

//══════════════════════════════════════════════════════════════════════════════
// VISUALS — BAR COLOR + BACKGROUND
//══════════════════════════════════════════════════════════════════════════════
bullBar = showBarCol and trend == 1
bearBar = showBarCol and trend == -1
barcolor(bullBar ? color.from_gradient(rsiVal, rsiBullLvl, 80, color.new(BULL_COLOR, 60), BULL_COLOR) :
         bearBar ? color.from_gradient(rsiVal, 20, rsiBearLvl, BEAR_COLOR, color.new(BEAR_COLOR, 60)) : na)
bgcolor(showBG ? (trend == 1 ? color.new(BULL_COLOR, bgOp) : trend == -1 ? color.new(BEAR_COLOR, bgOp) : na) : na)

//══════════════════════════════════════════════════════════════════════════════
// VISUALS — SIGNALS
//══════════════════════════════════════════════════════════════════════════════
bullAnchor = low - atrVal * 0.5
bearAnchor = high + atrVal * 0.5

plotshape(showSignals and sigBull ? bullAnchor : na, "Bull Strike Glow", shape.triangleup, location.absolute, color.new(BULL_COLOR, 50), size=size.small)
plotshape(showSignals and sigBull and not showSigTxt ? bullAnchor : na, "Bull Strike", shape.triangleup, location.absolute, BULL_COLOR, size=size.tiny)
plotshape(showSignals and sigBull and showSigTxt ? bullAnchor : na, "Bull Strike Text", shape.triangleup, location.absolute, BULL_COLOR, size=size.tiny, text="BULL 4", textcolor=BULL_COLOR)

plotshape(showSignals and sigBear ? bearAnchor : na, "Bear Strike Glow", shape.triangledown, location.absolute, color.new(BEAR_COLOR, 50), size=size.small)
plotshape(showSignals and sigBear and not showSigTxt ? bearAnchor : na, "Bear Strike", shape.triangledown, location.absolute, BEAR_COLOR, size=size.tiny)
plotshape(showSignals and sigBear and showSigTxt ? bearAnchor : na, "Bear Strike Text", shape.triangledown, location.absolute, BEAR_COLOR, size=size.tiny, text="BEAR 4", textcolor=BEAR_COLOR)

//══════════════════════════════════════════════════════════════════════════════
// TRADE BLOCK LINES
//══════════════════════════════════════════════════════════════════════════════
lblSz = rrLblSz == "Tiny" ? size.tiny : rrLblSz == "Normal" ? size.normal : size.small

var line ln_entry = na
var line ln_stop = na
var line ln_tp1 = na
var line ln_tp2 = na
var line ln_tp3 = na
var line ln_tp4 = na
var label lb_entry = na
var label lb_stop = na
var label lb_tp1 = na
var label lb_tp2 = na
var label lb_tp3 = na
var label lb_tp4 = na
var box bx_risk = na
var box bx_rew = na

if showBlock and tradeActive and not na(signalBar)
    extR = bar_index + rrExtend
    stopCol = tDir == 1 ? BEAR_COLOR : BULL_COLOR

    if sigBull or sigBear
        if not na(ln_entry) 
            line.delete(ln_entry)
        if not na(ln_stop) 
            line.delete(ln_stop)
        if not na(ln_tp1) 
            line.delete(ln_tp1)
        if not na(ln_tp2) 
            line.delete(ln_tp2)
        if not na(ln_tp3) 
            line.delete(ln_tp3)
        if not na(ln_tp4) 
            line.delete(ln_tp4)
        if not na(lb_entry) 
            label.delete(lb_entry)
        if not na(lb_stop) 
            label.delete(lb_stop)
        if not na(lb_tp1) 
            label.delete(lb_tp1)
        if not na(lb_tp2) 
            label.delete(lb_tp2)
        if not na(lb_tp3) 
            label.delete(lb_tp3)
        if not na(lb_tp4) 
            label.delete(lb_tp4)
        if not na(bx_risk) 
            box.delete(bx_risk)
        if not na(bx_rew) 
            box.delete(bx_rew)

        if showEntry
            ln_entry := line.new(signalBar, entryPx, extR, entryPx, color=col_entry, width=entryWidth)
            lb_entry := label.new(extR, entryPx, "ENTRY — " + str.tostring(entryPx, format.mintick), style=label.style_label_left, color=color.new(col_entry, 80), textcolor=col_entry, size=lblSz)

        ln_stop := line.new(signalBar, stopPx, extR, stopPx, color=stopCol, width=2)
        lb_stop := label.new(extR, stopPx, "STOP — " + str.tostring(stopPx, format.mintick), style=label.style_label_left, color=color.new(stopCol, 80), textcolor=stopCol, size=lblSz)

        if showTP1
            ln_tp1 := line.new(signalBar, tp1Px, extR, tp1Px, color=col_tp1, width=tp1Width)
            lb_tp1 := label.new(extR, tp1Px, "TP1 " + str.tostring(p_rr1, "#.#") + "R — " + str.tostring(tp1Px, format.mintick), style=label.style_label_left, color=color.new(col_tp1, 80), textcolor=col_tp1, size=lblSz)

        if showTP2
            ln_tp2 := line.new(signalBar, tp2Px, extR, tp2Px, color=col_tp2, width=tp2Width)
            lb_tp2 := label.new(extR, tp2Px, "TP2 " + str.tostring(p_rr2, "#.#") + "R — " + str.tostring(tp2Px, format.mintick), style=label.style_label_left, color=color.new(col_tp2, 80), textcolor=col_tp2, size=lblSz)

        if showTP3
            ln_tp3 := line.new(signalBar, tp3Px, extR, tp3Px, color=col_tp3, width=tp3Width)
            lb_tp3 := label.new(extR, tp3Px, "TP3 " + str.tostring(p_rr3, "#.#") + "R — " + str.tostring(tp3Px, format.mintick), style=label.style_label_left, color=color.new(col_tp3, 80), textcolor=col_tp3, size=lblSz)

        if showTP4
            ln_tp4 := line.new(signalBar, tp4Px, extR, tp4Px, color=col_tp4, width=tp4Width)
            lb_tp4 := label.new(extR, tp4Px, "TP4 " + str.tostring(p_rr4, "#.#") + "R — " + str.tostring(tp4Px, format.mintick), style=label.style_label_left, color=color.new(col_tp4, 80), textcolor=col_tp4, size=lblSz)

        if showRiskZ
            riskTop = math.max(entryPx, stopPx)
            riskBot = math.min(entryPx, stopPx)
            bx_risk := box.new(signalBar, riskTop, extR, riskBot, bgcolor=color.new(BEAR_COLOR, 88), border_color=color.new(BEAR_COLOR, 80), border_width=1)

        if showRewZ and showTP1
            rewTop = math.max(entryPx, tp1Px)
            rewBot = math.min(entryPx, tp1Px)
            bx_rew := box.new(signalBar, rewTop, extR, rewBot, bgcolor=color.new(BULL_COLOR, 88), border_color=color.new(BULL_COLOR, 80), border_width=1)

    else
        extR2 = bar_index + rrExtend

        if not na(ln_stop)
            line.set_y1(ln_stop, stopPx)
            line.set_y2(ln_stop, stopPx)
            line.set_x2(ln_stop, extR2)
        if not na(lb_stop)
            label.set_y(lb_stop, stopPx)
            label.set_x(lb_stop, extR2)
            label.set_text(lb_stop, "STOP — " + str.tostring(stopPx, format.mintick))

        if not na(ln_entry)
            line.set_x2(ln_entry, extR2)
        if not na(lb_entry)
            label.set_x(lb_entry, extR2)

        if not na(ln_tp1)
            line.set_x2(ln_tp1, extR2)
            line.set_color(ln_tp1, tp1Hit ? col_tp1 : color.new(col_tp1, 60))
        if not na(lb_tp1)
            label.set_x(lb_tp1, extR2)
            label.set_textcolor(lb_tp1, tp1Hit ? col_tp1 : color.new(col_tp1, 60))

        if not na(ln_tp2)
            line.set_x2(ln_tp2, extR2)
            line.set_color(ln_tp2, tp2Hit ? col_tp2 : color.new(col_tp2, 60))
        if not na(lb_tp2)
            label.set_x(lb_tp2, extR2)
            label.set_textcolor(lb_tp2, tp2Hit ? col_tp2 : color.new(col_tp2, 60))

        if not na(ln_tp3)
            line.set_x2(ln_tp3, extR2)
            line.set_color(ln_tp3, tp3Hit ? col_tp3 : color.new(col_tp3, 60))
        if not na(lb_tp3)
            label.set_x(lb_tp3, extR2)
            label.set_textcolor(lb_tp3, tp3Hit ? col_tp3 : color.new(col_tp3, 60))

        if not na(ln_tp4)
            line.set_x2(ln_tp4, extR2)
            line.set_color(ln_tp4, tp4Hit ? col_tp4 : color.new(col_tp4, 60))
        if not na(lb_tp4)
            label.set_x(lb_tp4, extR2)
            label.set_textcolor(lb_tp4, tp4Hit ? col_tp4 : color.new(col_tp4, 60))

        if not na(bx_risk)
            box.set_right(bx_risk, extR2)
            box.set_top(bx_risk, math.max(entryPx, stopPx))
            box.set_bottom(bx_risk, math.min(entryPx, stopPx))
        if not na(bx_rew)
            box.set_right(bx_rew, extR2)


//══════════════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════════════
alertcondition(sigBull, "Conflux 4 — Bull", "BULL 4: Bullish confluence — all filters aligned.")
alertcondition(sigBear, "Conflux 4 — Bear", "BEAR 4: Bearish confluence — all filters aligned.")
alertcondition(sigBull or sigBear, "Conflux 4 — Any", "CONFLUX: Signal fired.")
alertcondition(trend == 0, "Conflux 4 — Neutral", "Conflux 4 FLIP: Trend gone neutral — supertrend flipped.")

//══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════════════
dashPosVal = dashPos == "Top Right" ? position.top_right :
             dashPos == "Top Left" ? position.top_left :
             dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(dashPosVal, 2, 13,
     bgcolor=color.new(#0d1117, 10),
     border_color=color.new(#30363d, 20), border_width=1,
     frame_color=color.new(#30363d, 40), frame_width=1)

if showDash and barstate.islast
    dSz = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal
    cMuted = color.new(#8b949e, 0)
    cWhite = color.new(#ffffff, 0)
    cPanel = color.new(#161b22, 0)
    cBull = color.new(BULL_COLOR, 0)
    cBear = color.new(BEAR_COLOR, 0)
    cNeut = color.new(NEUT_COLOR, 0)
    cGold = color.new(GOLD_COLOR, 0)

    hdrCol = trend == 1 ? color.new(BULL_COLOR, 75) : trend == -1 ? color.new(BEAR_COLOR, 75) : color.new(#30363d, 75)

    table.cell(dash, 0, 0, "Conflux 4", text_color=cWhite, text_size=dSz, bgcolor=hdrCol, text_halign=text.align_left)
    table.cell(dash, 1, 0, preset, text_color=cMuted, text_size=dSz, bgcolor=hdrCol, text_halign=text.align_right)

    tStr = trend == 1 ? "▲ BULL" : trend == -1 ? "▼ BEAR" : "— NEUTRAL"
    tCol = trend == 1 ? cBull : trend == -1 ? cBear : cNeut
    table.cell(dash, 0, 1, "Trend", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 1, tStr, text_color=tCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    vStr = close > vwmaVal ? "▲ ABOVE" : "▼ BELOW"
    vCol = close > vwmaVal ? cBull : cBear
    table.cell(dash, 0, 2, "VWMA " + str.tostring(vwmaLen), text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 2, vStr, text_color=vCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    eStr = emaFastVal > emaSlowVal ? "▲ ALIGNED" : "▼ CROSSED"
    eCol = emaFastVal > emaSlowVal ? cBull : cBear
    table.cell(dash, 0, 3, "EMA " + str.tostring(emaFast) + "/" + str.tostring(emaSlow), text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 3, eStr, text_color=eCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    rStr = rsiVal > rsiBullLvl ? "▲ BULL (" + str.tostring(math.round(rsiVal)) + ")" : rsiVal < rsiBearLvl ? "▼ BEAR (" + str.tostring(math.round(rsiVal)) + ")" : "— MID (" + str.tostring(math.round(rsiVal)) + ")"
    rCol = rsiVal > rsiBullLvl ? cBull : rsiVal < rsiBearLvl ? cBear : cNeut
    table.cell(dash, 0, 4, "RSI " + str.tostring(rsiLen), text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 4, rStr, text_color=rCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    sStr = stBull ? "▲ BULL" : "▼ BEAR"
    sCol = stBull ? cBull : cBear
    table.cell(dash, 0, 5, "Supertrend", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 5, sStr, text_color=sCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    aStr = adxVal > p_adxThr ? "TRENDING (" + str.tostring(math.round(adxVal)) + ")" : "RANGING (" + str.tostring(math.round(adxVal)) + ")"
    aCol = adxVal > p_adxThr ? cBull : cGold
    table.cell(dash, 0, 6, "ADX " + str.tostring(adxLen), text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 6, useADX ? aStr : "— OFF", text_color=useADX ? aCol : cNeut, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    conf = (trendBull or trendBear ? 1 : 0) + (momBull or momBear ? 1 : 0) + (stBull or stBear ? 1 : 0) + (adxOk ? 1 : 0)
    cStr = str.tostring(conf) + " / 4 FILTERS"
    cCol = conf == 4 ? cBull : conf >= 3 ? cGold : cBear
    table.cell(dash, 0, 7, "Confluence", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 7, cStr, text_color=cCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    smStr = p_stopMode
    table.cell(dash, 0, 8, "Stop Mode", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 8, smStr, text_color=cWhite, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    lStr = sigBull ? "▲ BULL 4" : sigBear ? "▼ BEAR 4" : "— NONE"
    lCol = sigBull ? cBull : sigBear ? cBear : cNeut
    table.cell(dash, 0, 9, "Last Signal", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 9, lStr, text_color=lCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    cdStr = barsCD < p_cooldown ? str.tostring(p_cooldown - barsCD) + " bars" : "— READY"
    cdCol = barsCD < p_cooldown ? cGold : cBull
    table.cell(dash, 0, 10, "Cooldown", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 10, cdStr, text_color=cdCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    trStr = tradeActive ? (tDir == 1 ? "▲ LONG" : "▼ SHORT") : "— NO TRADE"
    trCol = tradeActive ? (tDir == 1 ? cBull : cBear) : cNeut
    table.cell(dash, 0, 11, "Trade Block", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 11, trStr, text_color=trCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)

    hitSym = tDir == 1 ? "▲" : "▼"
    missSym = tDir == 1 ? "△" : "▽"
    hitCol = tDir == 1 ? BULL_COLOR : BEAR_COLOR
    tp1Sym = tradeActive and showTP1 ? (tp1Hit ? hitSym : missSym) : "○"
    tp2Sym = tradeActive and showTP2 ? (tp2Hit ? hitSym : missSym) : "○"
    tp3Sym = tradeActive and showTP3 ? (tp3Hit ? hitSym : missSym) : "○"
    tp4Sym = tradeActive and showTP4 ? (tp4Hit ? hitSym : missSym) : "○"
    tpDisplayCol = (tp1Hit or tp2Hit or tp3Hit or tp4Hit) ? color.new(hitCol, 0) : cNeut

    table.cell(dash, 0, 12, "TP Progress", text_color=cMuted, text_size=dSz, bgcolor=cPanel, text_halign=text.align_left)
    table.cell(dash, 1, 12, tp1Sym + " " + tp2Sym + " " + tp3Sym + " " + tp4Sym, text_color=tpDisplayCol, text_size=dSz, bgcolor=cPanel, text_halign=text.align_right)
````

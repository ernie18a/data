<!-- tradingview-pine-id: PUB;e75d298c8ae54b23b2f550d1aba4251d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI + S/R + FVG + BOS + CHoCH Setup

Source: https://www.tradingview.com/script/L4g13PVw-RSI-S-R-FVG-BOS-CHoCH-Setup/

## Description

RSI + Support/Resistance + FVG + BOS + CHoCH

This indicator combines five popular technical analysis concepts into one structured market setup: RSI, Support & Resistance, Fair Value Gaps (FVG), Break of Structure (BOS), and Change of Character (CHoCH).

The goal is to identify higher-quality potential long and short setups by requiring multiple confirmations instead of relying on a single indicator.

How the Indicator Works
🟢 Long / BUY Setup

A bullish setup is generated when the following conditions align:

Support: Price is trading near a recent swing-low support area.
BOS / CHoCH: The market confirms bullish structural strength by breaking a previous swing high.
Bullish FVG: A bullish Fair Value Gap is detected or price returns into the latest bullish FVG.
RSI: RSI is above the configured bullish level, confirming bullish momentum.
When the required conditions are satisfied, the indicator displays a BUY signal.

Basic flow:

Support → Bullish BOS/CHoCH → Bullish FVG → RSI Confirmation → BUY

🔴 Short / SELL Setup

A bearish setup is generated when:

Resistance: Price is trading near a recent swing-high resistance area.
BOS / CHoCH: The market confirms bearish structural weakness by breaking a previous swing low.
Bearish FVG: A bearish Fair Value Gap is detected or price returns into the latest bearish FVG.
RSI: RSI is below the configured bearish level, confirming bearish momentum.
When the required conditions are satisfied, the indicator displays a SELL signal.

Basic flow:

Resistance → Bearish BOS/CHoCH → Bearish FVG → RSI Confirmation → SELL

Main Features

RSI Confirmation
Uses RSI to help determine whether bullish or bearish momentum is present. The RSI levels can be customized according to your trading style.

Support & Resistance
Recent swing highs and swing lows are used to identify potential resistance and support areas.

BOS — Break of Structure
Detects when price breaks an important recent swing high or swing low, helping identify continuation or structural changes.

CHoCH — Change of Character
Helps identify potential changes in market direction when price breaks structure against the previously established trend.

FVG — Fair Value Gap
Identifies three-candle price imbalances and displays bullish and bearish FVG zones directly on the chart.

Signal Window
The structure confirmation can remain valid for a configurable number of bars, allowing price time to return toward an FVG or key level.

Alerts
BUY and SELL alert conditions are included so you can create TradingView alerts when a setup is confirmed.

Recommended Usage

The indicator is designed to be used as a confluence-based confirmation tool, rather than as a standalone automatic trading system.

For example, a trader could wait for:

1. Price to approach support.
2. A liquidity reaction or market-structure shift.
3. Bullish BOS/CHoCH confirmation.
4. A bullish FVG to form or become available for a retracement.
5. RSI to confirm bullish momentum.
6. BUY signal to appear.
7. Stop-loss to be placed below the relevant swing/support.
8. Take-profit to be based on a predefined risk/reward ratio or the next major resistance/liquidity area.

The opposite process can be used for short trades.

Important Note

This indicator does not guarantee profitable trades. Market conditions, volatility, timeframe, spread, liquidity and execution can significantly affect results.

BOS, CHoCH, FVG, support/resistance and RSI are interpreted using predefined mathematical rules in the script. These definitions may differ from how individual traders manually identify them.

Always test the indicator on your preferred market and timeframe before using it with real money, and use appropriate risk management.

Best practice: combine the signals with higher-timeframe market structure, liquidity levels and disciplined risk management rather than taking every BUY or SELL signal automatically.

---

## Source Code

````pine
//@version=6
indicator("RSI + S/R + FVG + BOS + CHoCH Setup", overlay=true, max_boxes_count=100, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupRSI = "RSI"
rsiLength = input.int(14, "RSI Length", minval=2, group=groupRSI)
rsiBull = input.float(50.0, "Bullish RSI Level", group=groupRSI)
rsiBear = input.float(50.0, "Bearish RSI Level", group=groupRSI)

groupStructure = "Market Structure"
swingLen = input.int(5, "Swing Length", minval=2, group=groupStructure)
showBOS = input.bool(true, "Show BOS", group=groupStructure)
showCHoCH = input.bool(true, "Show CHoCH", group=groupStructure)

groupSR = "Support / Resistance"
showSR = input.bool(true, "Show Support / Resistance", group=groupSR)
srTolerance = input.float(0.5, "S/R Tolerance %", minval=0.1, step=0.1, group=groupSR)

groupFVG = "Fair Value Gap"
showFVG = input.bool(true, "Show FVG", group=groupFVG)
fvgExtend = input.int(20, "FVG Extension Bars", minval=1, group=groupFVG)

groupSetup = "Setup"
requireFVG = input.bool(true, "Require FVG", group=groupSetup)
requireStructure = input.bool(true, "Require BOS/CHoCH", group=groupSetup)
signalWindow = input.int(10, "Bars Allowed After Structure Break", minval=1, group=groupSetup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsi = ta.rsi(close, rsiLength)

bullRSI = rsi > rsiBull
bearRSI = rsi < rsiBear

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SWING HIGH / LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh

if not na(pivotLow)
    lastSwingLow := pivotLow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPPORT / RESISTANCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
support = lastSwingLow
resistance = lastSwingHigh

nearSupport = not na(support) and close <= support * (1 + srTolerance / 100) and close >= support * (1 - srTolerance / 100)
nearResistance = not na(resistance) and close <= resistance * (1 + srTolerance / 100) and close >= resistance * (1 - srTolerance / 100)

plot(showSR ? support : na, "Support", color=color.new(color.green, 25), linewidth=2, style=plot.style_linebr)
plot(showSR ? resistance : na, "Resistance", color=color.new(color.red, 25), linewidth=2, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BOS / CHoCH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int structureTrend = 0
// 1 = bullish
// -1 = bearish
// 0 = neutral

bullBreak = not na(lastSwingHigh) and close > lastSwingHigh
bearBreak = not na(lastSwingLow) and close < lastSwingLow

bullCHoCH = bullBreak and structureTrend == -1
bearCHoCH = bearBreak and structureTrend == 1

bullBOS = bullBreak and structureTrend != -1
bearBOS = bearBreak and structureTrend != 1

if bullBreak
    structureTrend := 1

if bearBreak
    structureTrend := -1

if showBOS and bullBOS
    label.new(bar_index, low, "BOS ↑", style=label.style_label_up, color=color.green, textcolor=color.white)

if showBOS and bearBOS
    label.new(bar_index, high, "BOS ↓", style=label.style_label_down, color=color.red, textcolor=color.white)

if showCHoCH and bullCHoCH
    label.new(bar_index, low, "CHoCH ↑", style=label.style_label_up, color=color.blue, textcolor=color.white)

if showCHoCH and bearCHoCH
    label.new(bar_index, high, "CHoCH ↓", style=label.style_label_down, color=color.orange, textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bullish FVG: current low > high from 2 bars ago
bullFVG = low > high[2]

// Bearish FVG: current high < low from 2 bars ago
bearFVG = high < low[2]

var float bullFVGTop = na
var float bullFVGBottom = na
var float bearFVGTop = na
var float bearFVGBottom = na

var int bullFVGBar = na
var int bearFVGBar = na

if bullFVG
    bullFVGTop := low
    bullFVGBottom := high[2]
    bullFVGBar := bar_index

    if showFVG
        box.new(
             left=bar_index - 2,
             top=low,
             right=bar_index + fvgExtend,
             bottom=high[2],
             bgcolor=color.new(color.green, 85),
             border_color=color.new(color.green, 40)
         )

if bearFVG
    bearFVGTop := low[2]
    bearFVGBottom := high
    bearFVGBar := bar_index

    if showFVG
        box.new(
             left=bar_index - 2,
             top=low[2],
             right=bar_index + fvgExtend,
             bottom=high,
             bgcolor=color.new(color.red, 85),
             border_color=color.new(color.red, 40)
         )

// Price inside latest FVG
inBullFVG = not na(bullFVGTop) and not na(bullFVGBottom) and close <= bullFVGTop and close >= bullFVGBottom
inBearFVG = not na(bearFVGTop) and not na(bearFVGBottom) and close >= bearFVGBottom and close <= bearFVGTop

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRUCTURE WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int lastBullStructureBar = na
var int lastBearStructureBar = na

if bullBreak
    lastBullStructureBar := bar_index

if bearBreak
    lastBearStructureBar := bar_index

bullStructureRecent = not na(lastBullStructureBar) and bar_index - lastBullStructureBar <= signalWindow
bearStructureRecent = not na(lastBearStructureBar) and bar_index - lastBearStructureBar <= signalWindow

structureBullOK = requireStructure ? bullStructureRecent : true
structureBearOK = requireStructure ? bearStructureRecent : true

fvgBullOK = requireFVG ? (bullFVG or inBullFVG) : true
fvgBearOK = requireFVG ? (bearFVG or inBearFVG) : true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL SETUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longSetup =
     nearSupport and
     bullRSI and
     structureBullOK and
     fvgBullOK

shortSetup =
     nearResistance and
     bearRSI and
     structureBearOK and
     fvgBearOK

// Prevent repeated signals on every candle
longSignal = longSetup and not longSetup[1]
shortSignal = shortSetup and not shortSetup[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     longSignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.small
 )

plotshape(
     shortSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
 )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longSignal, "BUY Setup", "BUY: RSI + Support + BOS/CHoCH + Bullish FVG")
alertcondition(shortSignal, "SELL Setup", "SELL: RSI + Resistance + BOS/CHoCH + Bearish FVG")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIONAL BAR COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
barcolor(longSetup ? color.new(color.green, 70) : shortSetup ? color.new(color.red, 70) : na)
````

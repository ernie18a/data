# OTE   Power Bands

- url: https://www.tradingview.com/script/qJ8qvSNF/
- type: indicator
- pine_id: PUB;bc24f495eed24ce89d6fd4cf1e10fa13
- version: 1.0

## Description

OTE  Power Bands

This indicator combines regression flow analysis with dynamic power measurement to visualize trend structure, pullback zones, and market strength in a single framework.

Instead of using static Fibonacci levels, the bands are built around a flowing regression core that continuously adapts to market direction, volatility, and price behavior. The result is a dynamic structure that expands and contracts with changing market conditions.

Key Features:

• Flowing Regression Core
A curved regression engine that tracks the underlying market flow rather than simple moving averages.

• Dynamic Flow Bands
Adaptive upper and lower flow zones calculated from volatility and price deviation. The bands automatically adjust to changing market environments.

• Trend Flow Detection
The regression core determines whether the market is in a bullish, bearish, or neutral flow state.

• Power Engine
Measures trend quality using:

* Regression slope strength
* Regression curvature
* Price distance from the flow core
* Volatility expansion

• AVG Power
Calculates the average strength of the flow over time, helping identify whether the current trend is stronger or weaker than its own historical behavior.

• Edge Measurement
Displays the difference between current Power and AVG Power.

Positive Edge:
Current flow strength is above average.

Negative Edge:
Current flow strength is below average.

Panel Information:

Flow
Current market flow direction.

Power
Current flow strength.

AVG
Average flow strength.

Edge
Difference between current and average strength.

This tool is designed to help traders visualize trend structure, flow quality, and dynamic market behavior without relying on fixed support and resistance levels.

## Source Code

````pine
//@version=6
indicator("OTE • Flowing Regression Power Bands", overlay=true, max_lines_count=500, max_labels_count=200)

//━━━━━━━━━━━━ INPUTS
regLen     = input.int(120, "Regression Length", minval=20, maxval=300)
atrLen     = input.int(14, "ATR Length", minval=1)
bandSmooth = input.int(5, "Band Smooth", minval=1)

showCore   = input.bool(true, "Show Regression Core")
showOTE    = input.bool(true, "Show Flow Band")
showTP     = input.bool(true, "Show Target Band")
showZone   = input.bool(true, "Show Flow Zone Fill")
showPanel  = input.bool(true, "Show Power Panel")

oteMult    = input.float(2.4, "Flow Band Width", step=0.1)
tpMult     = input.float(1.4, "Target Band Width", step=0.1)

powerLen   = input.int(34, "Power Smooth", minval=1)
avgLen     = input.int(55, "AVG Power Length", minval=5)

bullCol = color.lime
bearCol = color.red
oteCol  = color.yellow
tpCol   = color.aqua
midCol  = color.gray
goldCol = color.yellow

//━━━━━━━━━━━━ HELPERS
clamp(x, lo, hi) =>
    math.max(math.min(x, hi), lo)

normalize(src, len) =>
    lo = ta.lowest(src, len)
    hi = ta.highest(src, len)
    hi != lo ? 100.0 * (src - lo) / (hi - lo) : 50.0

//━━━━━━━━━━━━ REGRESSION CORE
src = hl2

reg0 = ta.linreg(src, regLen, 0)
reg1 = ta.linreg(src, regLen, 1)
reg2 = ta.linreg(src, regLen, 2)

slope = reg0 - reg1
curve = (reg0 - reg1) - (reg1 - reg2)

coreRaw = reg0 + slope * 2.0 + curve * regLen * 0.25
core = ta.ema(coreRaw, bandSmooth)

//━━━━━━━━━━━━ DIRECTION
coreBull = core > core[1]
coreBear = core < core[1]

mainCol = coreBull ? bullCol : coreBear ? bearCol : midCol

//━━━━━━━━━━━━ DYNAMIC WIDTH
atr = ta.atr(atrLen)
dev = ta.ema(math.abs(close - core), regLen)

widthBase = math.max(dev, atr)

oteWidth = widthBase * oteMult
tpWidth  = widthBase * tpMult

bullOTE = core - oteWidth * 0.886
bullTP  = core + tpWidth  * 0.618

bearOTE = core + oteWidth * 0.886
bearTP  = core - tpWidth  * 0.618

oteLine = coreBull ? bullOTE : coreBear ? bearOTE : na
tpLine  = coreBull ? bullTP  : coreBear ? bearTP  : na

//━━━━━━━━━━━━ POWER ENGINE
slopePowerRaw = normalize(math.abs(slope), powerLen)
curvePowerRaw = normalize(math.abs(curve), powerLen)

distRaw = math.abs(close - core) / math.max(widthBase, syminfo.mintick)
distPowerRaw = clamp(distRaw * 50.0, 0.0, 100.0)

atrPowerRaw = normalize(atr, powerLen)

flowPowerRaw =
     slopePowerRaw * 0.40 +
     curvePowerRaw * 0.20 +
     distPowerRaw  * 0.25 +
     atrPowerRaw   * 0.15

power = ta.ema(flowPowerRaw, 5)
power := clamp(power, 0.0, 100.0)

avgPower = ta.ema(power, avgLen)
edge = power - avgPower

edgeBull = edge >= 0
powerCol = edgeBull ? bullCol : bearCol

flowTxt = coreBull ? "BULL" : coreBear ? "BEAR" : "FLAT"
flowCol = coreBull ? bullCol : coreBear ? bearCol : midCol

edgeTxt = edge >= 0 ? "+" + str.tostring(edge, "#.0") : str.tostring(edge, "#.0")

//━━━━━━━━━━━━ PLOTS
pCore = plot(showCore ? core : na, title="Regression Core", color=color.new(mainCol, 0), linewidth=3)

pOTE = plot(showOTE ? oteLine : na, title="Flow Band", color=color.new(oteCol, 0), linewidth=3)
pTP  = plot(showTP ? tpLine : na, title="Target Band", color=color.new(tpCol, 0), linewidth=2)
 
fill(pOTE, pCore, color=showZone and coreBull ? color.new(bullCol, 90) : na, title="Bull Flow Zone")
fill(pOTE, pCore, color=showZone and coreBear ? color.new(bearCol, 90) : na, title="Bear Flow Zone")

//━━━━━━━━━━━━ POWER BOX
var label powerBox = na

if barstate.islast
    label.delete(powerBox)

    boxTxt =
         "Flow   = " + flowTxt + "\n" +
         "Power  = " + str.tostring(power, "#.0") + "\n" +
         "AVG    = " + str.tostring(avgPower, "#.0") + "\n" +
         "Edge   = " + edgeTxt

    boxY = coreBull ? low - atr : high + atr

    powerBox := label.new(
         bar_index + 5,
         boxY,
         boxTxt,
         xloc=xloc.bar_index,
         style=label.style_label_left,
         color=color.new(powerCol, 0),
         textcolor=color.black,
         size=size.normal)

//━━━━━━━━━━━━ PANEL
var table pan = table.new(position.top_right, 2, 5, border_width=1)

if showPanel and barstate.islast
    table.cell(pan, 0, 0, "FLOW", text_color=color.white, bgcolor=color.black)
    table.cell(pan, 1, 0, "POWER BANDS", text_color=powerCol, bgcolor=color.black)

    table.cell(pan, 0, 1, "Flow", text_color=color.white)
    table.cell(pan, 1, 1, flowTxt, text_color=flowCol)

    table.cell(pan, 0, 2, "Power", text_color=color.white)
    table.cell(pan, 1, 2, str.tostring(power, "#.0"), text_color=powerCol)

    table.cell(pan, 0, 3, "AVG", text_color=color.white)
    table.cell(pan, 1, 3, str.tostring(avgPower, "#.0"), text_color=goldCol)

    table.cell(pan, 0, 4, "Edge", text_color=color.white)
    table.cell(pan, 1, 4, edgeTxt, text_color=powerCol)
````

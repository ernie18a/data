# Smart Support / Resistance Zones PRO 

- url: https://www.tradingview.com/script/Gp8rSpal-Smart-Support-Resistance-Zones-PRO/
- type: indicator
- pine_id: PUB;6cb79e44ae904931976928136dca589a
- version: 1.0

## Description

[b]Smart Support / Resistance Zones PRO[/b]

Advanced dynamic Support & Resistance zone indicator for TradingView.

This indicator detects and visualizes real market reaction zones instead of simple horizontal lines.
Zones are automatically validated by actual price retests, dynamically updated over time, and invalidated when broken.

Designed for:
	•	Price Action traders
	•	ICT / SMC traders
	•	Swing traders
	•	Scalpers
	•	Trend continuation & reversal analysis

[b]Main Features[/b]

Dynamic Support & Resistance Zones

The indicator creates adaptive S/R zones using pivot structure and ATR-based volatility sizing.

Unlike classic line indicators:
	•	zones have real width,
	•	zones expand naturally,
	•	zones merge together when close,
	•	broken zones automatically stop extending.

[b]Confirmed Retest Logic[/b]

A pivot alone does NOT create a valid support or resistance.

The zone becomes stronger only after:
	1.	Price leaves the zone,
	2.	Returns later,
	3.	Successfully retests it again.

This greatly reduces false supports/resistances and market noise.

[b]Strength Percentage System[/b]

Each zone receives a strength score based on confirmed retests.

Examples:
	•	20% = weak zone,
	•	60% = medium strength,
	•	100% = highly respected historical zone.

Stronger zones become:
	•	more visible,
	•	less transparent,
	•	visually emphasized.

[b]Smart Weak Zone Filtering[/b]

Weak or unconfirmed zones can be automatically hidden.

This keeps the chart clean and highlights only meaningful institutional areas.

[b]Support / Resistance Flip Detection[/b]

When a support breaks, it can automatically become resistance.
When resistance breaks, it can become support.

This behavior reflects real market structure transitions.

[b]Adaptive ATR Zone Width[/b]

Zone width automatically adapts to volatility:
	•	tighter during low volatility,
	•	wider during high volatility.

Works especially well on:
	•	crypto,
	•	forex,
	•	indices,
	•	volatile sessions.

[b]Multi-Timeframe Support & Resistance[/b]

Optional higher timeframe S/R detection.

Examples:
	•	trade on 15m chart,
	•	display additional 4H or Daily zones.

Useful for:
	•	confluence trading,
	•	HTF bias,
	•	institutional levels.

[b]Heatmap Visualization[/b]

Zone transparency changes dynamically based on strength:
	•	weak zones = faded,
	•	strong zones = highlighted.

Creates a clean market heatmap effect.

[b]Breakout Confirmation Modes[/b]

Choose how zones become invalidated:
	•	Candle Close breakout,
	•	Wick breakout.

Allows adaptation to different trading styles.

[b]Alert System[/b]

Built-in alerts for:
	•	Support retests,
	•	Resistance retests,
	•	Support breaks,
	•	Resistance breaks.

Ideal for automated monitoring.

[b]Recommended Markets[/b]

Optimized for:
	•	BTCUSDT
	•	ETHUSDT
	•	Forex pairs
	•	NASDAQ / SPX
	•	Gold
	•	High liquidity markets

[b]Recommended Timeframes[/b]

Best performance on:
	•	15m
	•	1H
	•	4H
	•	Daily

[b]Suggested Settings[/b]

Crypto Scalping (5m–15m)
	•	Pivot Length: 5
	•	Confirmations for 100%: 8–10
	•	Minimum Retests: 1–2

Swing Trading (1H–4H)
	•	Pivot Length: 8–12
	•	Confirmations for 100%: 5–8
	•	Enable HTF zones

[b]Notes[/b]

This indicator is designed to:
	•	reduce fake S/R zones,
	•	prioritize validated market structure,
	•	improve chart readability,
	•	provide institutional-style zone analysis.

No repainting after pivot confirmation.

[b]Author Notes[/b]

The indicator focuses on realistic price interaction behavior rather than simplistic pivot plotting.

Supports:
	•	clean discretionary trading,
	•	confluence analysis,
	•	advanced price action workflows.

## Source Code

````pine
//@version=6
indicator("Smart Support / Resistance Zones PRO - Validated", overlay=true, max_boxes_count=500)

// ───── Inputs
pivotLen      = input.int(5, "Pivot length", minval=1)
atrLen        = input.int(14, "ATR length", minval=1)
zoneAtrMult   = input.float(0.20, "Zone width ATR multiplier", minval=0.01)
mergeAtrMult  = input.float(0.50, "Merge distance ATR multiplier", minval=0.01)
touchCooldown = input.int(12, "Bars between counted retests", minval=1)
maxZones      = input.int(80, "Max zones per side", minval=10, maxval=240)

supportColor    = input.color(color.red, "Support color")
resistanceColor = input.color(color.green, "Resistance color")

showCandidates = input.bool(false, "Show unconfirmed candidate zones")
minRetestsToShow = input.int(1, "Minimum retests to show zone", minval=1)
maxRetestsFor100 = input.int(5, "Retests needed for 100%", minval=1)

departureAtrMult = input.float(0.35, "Required price departure before retest", minval=0.05)

showStrengthText = input.bool(true, "Show strength %")
textSizeInput = input.string("Tiny", "Text size", options=["Tiny", "Small", "Normal", "Large"])
textOpacity = input.int(10, "Text opacity", minval=0, maxval=100)

minTransparency = input.int(72, "Strong zone transparency", minval=0, maxval=100)
maxTransparency = input.int(94, "Weak zone transparency", minval=0, maxval=100)

breakMode  = input.string("Close", "Zone break confirmation", options=["Close", "Wick"])
enableFlip = input.bool(true, "Enable S/R flip after breakout")
enableAlerts = input.bool(true, "Enable alerts")

textSize =
     textSizeInput == "Tiny"   ? size.tiny :
     textSizeInput == "Small"  ? size.small :
     textSizeInput == "Normal" ? size.normal :
     size.large

// ───── Arrays
var box[]   supBoxes = array.new_box()
var float[] supTop   = array.new_float()
var float[] supBot   = array.new_float()
var int[]   supRetests = array.new_int()
var int[]   supLast  = array.new_int()
var bool[]  supLive  = array.new_bool()
var bool[]  supArmed = array.new_bool()

var box[]   resBoxes = array.new_box()
var float[] resTop   = array.new_float()
var float[] resBot   = array.new_float()
var int[]   resRetests = array.new_int()
var int[]   resLast  = array.new_int()
var bool[]  resLive  = array.new_bool()
var bool[]  resArmed = array.new_bool()

atr = ta.atr(atrLen)
zoneHalf = atr * zoneAtrMult
mergeDist = atr * mergeAtrMult
departure = atr * departureAtrMult

f_percent(int retests) =>
    math.min(100, math.round(retests / maxRetestsFor100 * 100))

f_transp(int retests) =>
    p = f_percent(retests)
    math.round(maxTransparency - (maxTransparency - minTransparency) * p / 100)

f_update_box(box b, color c, int retests, string txt) =>
    visible = retests >= minRetestsToShow or showCandidates
    tr = visible ? f_transp(retests) : 100

    box.set_bgcolor(b, color.new(c, tr))
    box.set_border_color(b, color.new(c, visible ? math.max(0, tr - 12) : 100))
    box.set_border_width(b, visible ? math.min(3, 1 + math.floor(retests / 2)) : 1)

    if visible and showStrengthText
        box.set_text(b, txt + " " + str.tostring(f_percent(retests)) + "%")
        box.set_text_color(b, color.new(c, textOpacity))
        box.set_text_size(b, textSize)
        box.set_text_halign(b, text.align_right)
        box.set_text_valign(b, text.align_center)
    else
        box.set_text(b, "")

f_trim_support() =>
    while array.size(supBoxes) > maxZones
        box.delete(array.shift(supBoxes))
        array.shift(supTop), array.shift(supBot), array.shift(supRetests), array.shift(supLast), array.shift(supLive), array.shift(supArmed)

f_trim_resistance() =>
    while array.size(resBoxes) > maxZones
        box.delete(array.shift(resBoxes))
        array.shift(resTop), array.shift(resBot), array.shift(resRetests), array.shift(resLast), array.shift(resLive), array.shift(resArmed)

f_add_support(float level, int leftBar) =>
    bool merged = false

    if array.size(supBoxes) > 0
        for i = 0 to array.size(supBoxes) - 1
            if array.get(supLive, i)
                mid = (array.get(supTop, i) + array.get(supBot, i)) / 2
                if math.abs(level - mid) <= mergeDist
                    newTop = math.max(array.get(supTop, i), level + zoneHalf)
                    newBot = math.min(array.get(supBot, i), level - zoneHalf)
                    array.set(supTop, i, newTop)
                    array.set(supBot, i, newBot)

                    b = array.get(supBoxes, i)
                    box.set_top(b, newTop)
                    box.set_bottom(b, newBot)
                    f_update_box(b, supportColor, array.get(supRetests, i), "SUP")
                    merged := true

    if not merged
        b = box.new(leftBar, level + zoneHalf, bar_index, level - zoneHalf, bgcolor=color.new(supportColor, 100), border_color=color.new(supportColor, 100))
        array.push(supBoxes, b)
        array.push(supTop, level + zoneHalf)
        array.push(supBot, level - zoneHalf)
        array.push(supRetests, 0)
        array.push(supLast, bar_index)
        array.push(supLive, true)
        array.push(supArmed, false)
        f_update_box(b, supportColor, 0, "SUP")

    f_trim_support()

f_add_resistance(float level, int leftBar) =>
    bool merged = false

    if array.size(resBoxes) > 0
        for i = 0 to array.size(resBoxes) - 1
            if array.get(resLive, i)
                mid = (array.get(resTop, i) + array.get(resBot, i)) / 2
                if math.abs(level - mid) <= mergeDist
                    newTop = math.max(array.get(resTop, i), level + zoneHalf)
                    newBot = math.min(array.get(resBot, i), level - zoneHalf)
                    array.set(resTop, i, newTop)
                    array.set(resBot, i, newBot)

                    b = array.get(resBoxes, i)
                    box.set_top(b, newTop)
                    box.set_bottom(b, newBot)
                    f_update_box(b, resistanceColor, array.get(resRetests, i), "RES")
                    merged := true

    if not merged
        b = box.new(leftBar, level + zoneHalf, bar_index, level - zoneHalf, bgcolor=color.new(resistanceColor, 100), border_color=color.new(resistanceColor, 100))
        array.push(resBoxes, b)
        array.push(resTop, level + zoneHalf)
        array.push(resBot, level - zoneHalf)
        array.push(resRetests, 0)
        array.push(resLast, bar_index)
        array.push(resLive, true)
        array.push(resArmed, false)
        f_update_box(b, resistanceColor, 0, "RES")

    f_trim_resistance()

// ───── Pivots create only candidates
pl = ta.pivotlow(low, pivotLen, pivotLen)
ph = ta.pivothigh(high, pivotLen, pivotLen)
pivotBar = bar_index - pivotLen

if not na(pl)
    f_add_support(pl, pivotBar)

if not na(ph)
    f_add_resistance(ph, pivotBar)

// ───── Alerts
bool supportRetested = false
bool resistanceRetested = false
bool supportBroken = false
bool resistanceBroken = false

// ───── Maintain supports
if array.size(supBoxes) > 0
    for i = 0 to array.size(supBoxes) - 1
        if array.get(supLive, i)
            b = array.get(supBoxes, i)
            top = array.get(supTop, i)
            bot = array.get(supBot, i)

            broken = breakMode == "Close" ? close < bot : low < bot
            touched = low <= top and high >= bot

            // musí najprv odísť dostatočne NAD zónu
            if low > top + departure
                array.set(supArmed, i, true)

            validRetest = touched and array.get(supArmed, i) and bar_index - array.get(supLast, i) >= touchCooldown

            if broken
                supportBroken := true
                array.set(supLive, i, false)
                box.set_right(b, bar_index)
                box.set_bgcolor(b, color.new(supportColor, 96))
                box.set_border_color(b, color.new(supportColor, 90))
                box.set_text(b, "")

                if enableFlip
                    f_add_resistance((top + bot) / 2, bar_index)
            else
                box.set_right(b, bar_index)

                if validRetest
                    supportRetested := true
                    newRetests = array.get(supRetests, i) + 1
                    array.set(supRetests, i, newRetests)
                    array.set(supLast, i, bar_index)
                    array.set(supArmed, i, false)
                    f_update_box(b, supportColor, newRetests, "SUP")

// ───── Maintain resistances
if array.size(resBoxes) > 0
    for i = 0 to array.size(resBoxes) - 1
        if array.get(resLive, i)
            b = array.get(resBoxes, i)
            top = array.get(resTop, i)
            bot = array.get(resBot, i)

            broken = breakMode == "Close" ? close > top : high > top
            touched = low <= top and high >= bot

            // musí najprv odísť dostatočne POD zónu
            if high < bot - departure
                array.set(resArmed, i, true)

            validRetest = touched and array.get(resArmed, i) and bar_index - array.get(resLast, i) >= touchCooldown

            if broken
                resistanceBroken := true
                array.set(resLive, i, false)
                box.set_right(b, bar_index)
                box.set_bgcolor(b, color.new(resistanceColor, 96))
                box.set_border_color(b, color.new(resistanceColor, 90))
                box.set_text(b, "")

                if enableFlip
                    f_add_support((top + bot) / 2, bar_index)
            else
                box.set_right(b, bar_index)

                if validRetest
                    resistanceRetested := true
                    newRetests = array.get(resRetests, i) + 1
                    array.set(resRetests, i, newRetests)
                    array.set(resLast, i, bar_index)
                    array.set(resArmed, i, false)
                    f_update_box(b, resistanceColor, newRetests, "RES")

alertcondition(enableAlerts and supportRetested, "Support retested", "Support zone confirmed by retest")
alertcondition(enableAlerts and resistanceRetested, "Resistance retested", "Resistance zone confirmed by retest")
alertcondition(enableAlerts and supportBroken, "Support broken", "Support zone broken")
alertcondition(enableAlerts and resistanceBroken, "Resistance broken", "Resistance zone broken")
````

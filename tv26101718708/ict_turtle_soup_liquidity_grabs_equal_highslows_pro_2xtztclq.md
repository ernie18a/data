# ICT Turtle Soup + Liquidity Grabs + Equal Highs/Lows [Pro]

- url: https://www.tradingview.com/script/2xtZtCLq-ICT-Turtle-Soup-Liquidity-Grabs-Equal-Highs-Lows-Pro/
- type: indicator
- pine_id: PUB;eb682d4b91c343ff99f4739fae0c3347
- version: 1.0

## Description

1. Overview
This indicator combines three powerful ICT tools in one:

FeaturePurposeWhen to UseTurtle SoupDetects strong reversals after false breakoutsMain entry signalLiquidity Grabs + %Shows when liquidity is swept and how much remainsHigh-probability zonesEqual Highs/Lows (EQH/EQL)Identifies strong liquidity pools (multiple touches)Key levels for reversals
You can now turn the Equal Highs/Lows feature completely on or off using the new toggle.

2. How to Use It (Step-by-Step)
Recommended Daily Workflow:

Turn on Equal Highs/Lows (or keep it off if you want a cleaner chart)
Identify Key Levels
Look for EQH (blue lines) → Potential resistance
Look for EQL (purple lines) → Potential support

Wait for Liquidity Grab
Watch for LG-H (red) or LG-L (green) near these levels
Pay attention to the % Left label

Confirm with Turtle Soup
The strongest setups are when Turtle Soup forms at or near an EQH/EQL

Enter the Trade
Enter on the Turtle Soup signal
Use the SL line (if shown)
Target previous swing high/low or 1:2–1:3 RR

3. How to Customize (Full Breakdown)
A. Equal Highs & Lows (Most Important Section)

SettingRecommended ValueEffectEnable Equal Highs/Lows FeatureON (default)Turn OFF to completely remove EQH/EQLEqual High/Low Lookback12 – 18Higher = stronger, fewer levelsMinimum Touches for Equal Level22 = good balance, 3 = very strong onlyEqual Tolerance %0.12 – 0.15How close levels need to beMax Active Equal Lines3 – 5Keeps chart cleanLine Extension Bars50 – 70How far lines extend to the rightShow Extending LinesONShows the horizontal linesShow Equal Highs / LowsONShows EQH / EQL labels
Pro Tip: Start with Lookback = 15 and Minimum Touches = 2. Increase Lookback if you want fewer but stronger levels.
B. Turtle Soup (Main Entry Signals)

SettingRecommended ValueEffectSwing Lookback5Higher = stronger reversalsMin Body % of Range0.30Filters weak candlesShow Turtle Soup LabelsONShows "Turtle Soup (Bearish/Bullish)"
C. Liquidity Grabs

SettingRecommended ValueEffectLiquidity Lookback20Standard for most timeframesShow Liquidity GrabsONShows LG-H and LG-LShow % Remaining LabelONVery useful for decision makingLiquidity Box Transparency88 – 92Lower = more visible
D. Visual Mode (Overall Look)


ModeWhat You SeeBest ForMinimalOnly triangles + minimal labelsVery clean chartCleanMost useful elements (Recommended)Daily tradingFullEverything (boxes, SL lines, etc.)Learning / analysis

4. Recommended Settings for NQ / ES (15m & 30m)
Equal Highs & Lows

Enable Feature: ON
Lookback: 15
Minimum Touches: 2
Max Active Lines: 4
Line Extension: 60

Turtle Soup

Swing Lookback: 5
Min Body %: 0.30

Liquidity

Lookback: 20
Show % Label: ON

Visual

Visual Mode: Clean
Show Labels: ON


5. Pro Tips

Strongest Setups: Turtle Soup + Equal High/Low + Liquidity Grab at the same level
Best Time to Trade: First 2–3 hours after NY Open
When to Skip Trades:
No EQH/EQL levels nearby
Strong trending market with no respect for equal levels

Use with Higher Timeframe: Always check 1H or 4H bias first
Quick Switch: Turn "Enable Equal Highs/Lows Feature" OFF when you want a simpler chart


6. Quick Reference

You See ThisMeaningActionEQH + Blue LineStrong resistanceWatch for shortsEQL + Purple LineStrong supportWatch for longsLG-H + Red Box + %Liquidity swept abovePotential shortLG-L + Green Box + %Liquidity swept belowPotential longTurtle Soup (Bearish)Reversal after false high breakoutShort entryTurtle Soup (Bullish)Reversal after false low breakoutLong entry

## Source Code

````pine
//@version=6
indicator("ICT Turtle Soup + Liquidity Grabs + Equal Highs/Lows [Pro]", overlay=true)

// ==================== INPUTS ====================
liqLookback     = input.int(20, "Liquidity Lookback Period", group="Liquidity Grab", minval=5)
liqBoxLength    = input.int(8, "Liquidity Box Length (bars)", group="Liquidity Grab", minval=3, maxval=30)
liqBoxTransp    = input.int(90, "Liquidity Box Transparency %", group="Liquidity Grab", minval=70, maxval=95)
showLiqGrab     = input.bool(true, "Show Liquidity Grabs", group="Liquidity Grab")
showLiqPercent  = input.bool(true, "Show % Remaining Label", group="Liquidity Grab")
bullLiqColor    = input.color(color.green, "Bullish Liquidity Color", group="Liquidity Grab")
bearLiqColor    = input.color(color.red, "Bearish Liquidity Color", group="Liquidity Grab")

swingLookback   = input.int(5, "Swing Lookback", group="Turtle Soup", minval=1, maxval=20)
bodyPercent     = input.float(0.30, "Min Body % of Range", group="Turtle Soup", minval=0.1, maxval=0.8, step=0.05)
bullColor       = input.color(color.green, "Bullish Color", group="Turtle Soup")
bearColor       = input.color(color.red, "Bearish Color", group="Turtle Soup")
tsLabelSize     = input.string("small", "Turtle Soup Label Size", group="Turtle Soup", options=["tiny", "small", "normal", "large"])

// Equal Highs & Lows
showEqualHighLow = input.bool(true, "Enable Equal Highs/Lows Feature", group="Equal Highs & Lows")
eqLookback       = input.int(10, "Equal High/Low Lookback", group="Equal Highs & Lows", minval=3, maxval=30)
eqTolerance      = input.float(0.15, "Equal Tolerance %", group="Equal Highs & Lows", minval=0.01, maxval=1.0, step=0.01)
showEqualHighs   = input.bool(true, "Show Equal Highs (EQH)", group="Equal Highs & Lows")
showEqualLows    = input.bool(true, "Show Equal Lows (EQL)", group="Equal Highs & Lows")
showEqLines      = input.bool(true, "Show Extending Lines", group="Equal Highs & Lows")
eqLineExtension  = input.int(50, "Line Extension Bars", group="Equal Highs & Lows", minval=10, maxval=300)
maxEqLines       = input.int(5, "Max Active Equal Lines", group="Equal Highs & Lows", minval=1, maxval=20)
eqHighColor      = input.color(color.new(color.blue, 0), "Equal High Color", group="Equal Highs & Lows")
eqLowColor       = input.color(color.new(color.purple, 0), "Equal Low Color", group="Equal Highs & Lows")
eqLineWidth      = input.int(2, "Line Width", group="Equal Highs & Lows", minval=1, maxval=5)
eqLineStyle      = input.string("Solid", "Line Style", group="Equal Highs & Lows", options=["Solid", "Dashed", "Dotted"])

visualMode      = input.string("Clean", "Visual Mode", group="Visuals", options=["Minimal", "Clean", "Full"])
showLabels      = input.bool(true, "Show Turtle Soup Text Labels", group="Visuals")
showOB          = input.bool(false, "Show Order Blocks", group="Visuals")
showSL          = input.bool(false, "Show SL Lines", group="Visuals")

// ==================== LOGIC ====================
swingHigh = ta.pivothigh(high, swingLookback, swingLookback)
swingLow  = ta.pivotlow(low, swingLookback, swingLookback)

var float prevHigh = na
var float prevLow  = na

if not na(swingHigh)
    prevHigh := swingHigh
if not na(swingLow)
    prevLow := swingLow

isStrongBull = close > open and (close - open) > (high - low) * bodyPercent
isStrongBear = open > close and (open - close) > (high - low) * bodyPercent

bearTS = not na(prevHigh) and high > prevHigh and close < prevHigh and isStrongBear
bullTS = not na(prevLow) and low < prevLow and close > prevLow and isStrongBull

liqHigh = ta.highest(high, liqLookback)
liqLow  = ta.lowest(low, liqLookback)

liqGrabHigh = high > liqHigh[1] and close < liqHigh[1]
liqGrabLow  = low < liqLow[1] and close > liqLow[1]

liqRemainingHigh = (liqHigh - close) / (liqHigh - liqLow) * 100
liqRemainingLow  = (close - liqLow) / (liqHigh - liqLow) * 100

var labelSize = size.small
if tsLabelSize == "tiny"
    labelSize := size.tiny
else if tsLabelSize == "small"
    labelSize := size.small
else if tsLabelSize == "normal"
    labelSize := size.normal
else if tsLabelSize == "large"
    labelSize := size.large
else
    labelSize := size.huge

// ==================== EQUAL HIGHS & LOWS (with toggle) ====================
if showEqualHighLow
    eqSwingHigh = ta.pivothigh(high, eqLookback, eqLookback)
    eqSwingLow  = ta.pivotlow(low, eqLookback, eqLookback)

    var float lastEqHigh = na
    var float lastEqLow  = na

    if not na(eqSwingHigh)
        lastEqHigh := eqSwingHigh
    if not na(eqSwingLow)
        lastEqLow := eqSwingLow

    isEqualHigh = not na(lastEqHigh) and not na(eqSwingHigh) and 
                  math.abs(lastEqHigh - eqSwingHigh) / lastEqHigh * 100 <= eqTolerance

    isEqualLow = not na(lastEqLow) and not na(eqSwingLow) and 
                 math.abs(lastEqLow - eqSwingLow) / lastEqLow * 100 <= eqTolerance

    lineStyle = eqLineStyle == "Solid" ? line.style_solid : eqLineStyle == "Dashed" ? line.style_dashed : line.style_dotted

    // Limited Equal Lines
    var line[] eqHighLines = array.new_line()
    var line[] eqLowLines  = array.new_line()

    if showEqLines and isEqualHigh
        newLine = line.new(bar_index, eqSwingHigh, bar_index + eqLineExtension, eqSwingHigh, color=eqHighColor, width=eqLineWidth, style=lineStyle, extend=extend.right)
        array.push(eqHighLines, newLine)
        if array.size(eqHighLines) > maxEqLines
            line.delete(array.shift(eqHighLines))

    if showEqLines and isEqualLow
        newLine = line.new(bar_index, eqSwingLow, bar_index + eqLineExtension, eqSwingLow, color=eqLowColor, width=eqLineWidth, style=lineStyle, extend=extend.right)
        array.push(eqLowLines, newLine)
        if array.size(eqLowLines) > maxEqLines
            line.delete(array.shift(eqLowLines))

    // Labels
    if showEqualHighs and isEqualHigh
        label.new(bar_index, high, "EQH", style=label.style_label_down, color=eqHighColor, textcolor=color.white, size=size.small)
    if showEqualLows and isEqualLow
        label.new(bar_index, low, "EQL", style=label.style_label_up, color=eqLowColor, textcolor=color.white, size=size.small)

// ==================== DYNAMIC LIQUIDITY BOXES ====================
var box[] activeLiqBoxes = array.new_box()
var float[] liqTargets = array.new_float()
var bool[] isBullishLiq = array.new_bool()

if showLiqGrab
    if liqGrabHigh
        newBox = box.new(left=bar_index, right=bar_index + liqBoxLength, top=liqHigh, bottom=close, border_color=bearLiqColor, bgcolor=color.new(bearLiqColor, liqBoxTransp))
        array.push(activeLiqBoxes, newBox)
        array.push(liqTargets, liqHigh)
        array.push(isBullishLiq, false)
        if showLiqPercent
            label.new(bar_index, liqHigh, "LG-H\n" + str.tostring(liqRemainingHigh, "#.#") + "% Left", style=label.style_label_down, color=bearLiqColor, textcolor=color.white, size=size.tiny)

    if liqGrabLow
        newBox = box.new(left=bar_index, right=bar_index + liqBoxLength, top=close, bottom=liqLow, border_color=bullLiqColor, bgcolor=color.new(bullLiqColor, liqBoxTransp))
        array.push(activeLiqBoxes, newBox)
        array.push(liqTargets, liqLow)
        array.push(isBullishLiq, true)
        if showLiqPercent
            label.new(bar_index, liqLow, "LG-L\n" + str.tostring(liqRemainingLow, "#.#") + "% Left", style=label.style_label_up, color=bullLiqColor, textcolor=color.white, size=size.tiny)

i = array.size(activeLiqBoxes) - 1
while i >= 0
    if array.size(activeLiqBoxes) == 0
        break
    boxObj = array.get(activeLiqBoxes, i)
    target = array.get(liqTargets, i)
    isBull = array.get(isBullishLiq, i)
    fullyTaken = isBull ? high > target : low < target
    if fullyTaken
        box.delete(boxObj)
        array.remove(activeLiqBoxes, i)
        array.remove(liqTargets, i)
        array.remove(isBullishLiq, i)
    i := i - 1

// ==================== VISUALS ====================
plotshape(bearTS, location=location.abovebar, style=shape.labeldown, color=bearColor, size=size.tiny, title="Bearish Turtle Soup", text="🐢🔻")
plotshape(bullTS, location=location.belowbar, style=shape.labelup, color=bullColor, size=size.tiny, title="Bullish Turtle Soup", text="🐢🔺")

if showLabels and visualMode != "Minimal"
    if bearTS
        label.new(bar_index, high, "Turtle Soup\n(Bearish)", style=label.style_label_down, color=bearColor, textcolor=color.white, size=labelSize)
    if bullTS
        label.new(bar_index, low, "Turtle Soup\n(Bullish)", style=label.style_label_up, color=bullColor, textcolor=color.white, size=labelSize)

if visualMode == "Full" and showOB
    if bullTS
        box.new(left=bar_index, right=bar_index + 8, top=high, bottom=low, border_color=bullColor, bgcolor=color.new(bullColor, 92))
    if bearTS
        box.new(left=bar_index, right=bar_index + 8, top=high, bottom=low, border_color=bearColor, bgcolor=color.new(bearColor, 92))

if visualMode == "Full" and showSL
    if bullTS
        line.new(bar_index, prevLow, bar_index + 12, prevLow, color=color.new(color.red, 40), width=1)
    if bearTS
        line.new(bar_index, prevHigh, bar_index + 12, prevHigh, color=color.new(color.red, 40), width=1)

// ==================== ALERTS ====================
alertcondition(bearTS, title="Bearish Turtle Soup", message="Bearish Turtle Soup detected!")
alertcondition(bullTS, title="Bullish Turtle Soup", message="Bullish Turtle Soup detected!")
alertcondition(liqGrabHigh, title="Liquidity Grab High", message="Liquidity Grab High - {{ticker}}")
alertcondition(liqGrabLow, title="Liquidity Grab Low", message="Liquidity Grab Low - {{ticker}}")
````

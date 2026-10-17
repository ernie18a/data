# LiquidityPulse Defended Order Levels ATR Adaptive Non-Repaint

- url: https://www.tradingview.com/script/aBlzO7i5-LiquidityPulse-Defended-Order-Levels-ATR-Adaptive-Non-Repaint/
- type: indicator
- pine_id: PUB;d816725220d44a9d81a3afc59deee79f
- version: 1.0

## Description

[b]LiquidityPulse Defended Order Levels ATR Adaptive Non-Repaint[/b]

[i]Non-repainting: [/i]This indicator only evaluates completed (closed) bars. Once a level is identified, it does not move, resize, or disappear based on future price action. The level line draws back to the bar where the formation originated — this is visual context showing you where the level was formed, not repainting. The identification logic itself runs strictly on confirmed bars.

[b]What This Indicator Does[/b]

This indicator automatically identifies price levels where the market has touched multiple times without ever closing through — areas where resting orders appear to be defending a price. It draws these levels on your chart and removes them when they are eventually broken.

Unlike most support/resistance indicators that use fixed parameters, this indicator uses an adaptive ATR-based tolerance that automatically adjusts to any instrument and timeframe. This means it works across futures, forex, crypto, and equities without manual adjustment.

[b]How It Works[/b]

[i]1. Price Clustering Detection[/i]
The indicator looks back over a formation window (default 15 bars) and examines each open and close price as a candidate level. For each candidate, it counts how many other opens and closes within the window land within tolerance of that price.

[i]2. Minimum Hit Threshold[/i]
If enough prices cluster at the same level (default 4 hits), the price is flagged as a potential defended level.

[i]3. Defended Validation[/i]
The indicator checks whether price has remained on one side of the level throughout the formation window. If all closes are above the level — this is support. If all closes are below — this is resistance. The level was touched repeatedly but never broken.

[i]4. ATR Adaptive Tolerance[/i]
The indicator uses a dual ATR system (fast and slow) to automatically determine what counts as "the same price." This adapts to the instrument and current volatility meaning that the threshold remains tight during calm markets and wider during volatile conditions.

[i]5. Level Lifecycle[/i]
Unbroken levels extend forward in real time. When price closes through a level, it stops extending — giving you a clear visual of which levels are still active and which have been invalidated.

https://www.tradingview.com/x/kaIJyeOU/
[i]Image shows defended support and resistance levels identified automatically: Green levels mark areas where price touched multiple times without closing below (support). Red levels mark areas where price touched without closing above (resistance). Levels stop extending when price eventually closes through them.[/i]

https://www.tradingview.com/x/o0wEEY62/
[i]Image shows multiple defended levels clustering at a similar price area: When several independent levels form at nearby prices, it can suggest repeated and sustained defence of that area — potentially indicating a more significant structural level that traders may want to pay closer attention to.[/i]

[b]Key Settings[/b]
[i]Formation Window[/i]
How many bars the indicator looks back to find clustering prices. Default: 15.
[i]Min Hits[/i]
How many opens/closes must land at the same price to qualify as a level. Default: 4. Higher values produce fewer but potentially stronger levels.
[i]ATR Tolerance[/i]
When enabled (default), tolerance adapts automatically to the instrument and volatility. When disabled, a manual tick-based tolerance is used instead.
[i]ATR Length / ATR Multiplier[/i]
Controls the sensitivity of the adaptive tolerance. Default: 50 / 0.15.
[i]Require No Close-Through[/i]
When enabled (default), levels only qualify if no bar closed on the opposite side during formation. This is what makes them "defended."
[i]Max Levels[/i]
The maximum number of levels displayed. Oldest levels are removed when exceeded. Default: 50.
[i]Extend Levels Indefinitely[/i]
When enabled, levels extend regardless of whether they have been broken. Default: off.
[i]Level Width[/i]
The thickness of the level lines in pixels. Default: 2.
[i]Show Origin Marker[/i]
Displays a small dot at the bar where the level was first identified. Default: on.

[b]Alerts[/b]
Separate alert conditions trigger when a new support or resistance level is identified.

[b]How Traders Can Use This Indicator[/b]

This indicator is not a buy/sell signal generator. It is a structural tool that helps you identify:
[list]
[*]Where price has been repeatedly defended without being broken
[*]Whether multiple defended levels cluster at similar prices, suggesting a significant area
[*]How price behaves when it revisits a previously defended level
[*]Which levels are still active versus broken
[/list]
Combine it with volume-based indicators and price action analysis to build context around the levels it identifies.

[b]Disclaimer[/b]
This indicator does not measure true order flow or liquidity. It uses price clustering and close-through validation as interpretive tools. The plotted levels do not represent signals or predictions. All analysis is user-interpreted, and past behaviour does not imply future results.

## Source Code

````pine
//@version=6
indicator("LiquidityPulse Defended Order Levels ATR Adaptive Non-Repaint", overlay=true, max_lines_count=500, max_labels_count=500)

//────────────────────────────────────
// Inputs
//────────────────────────────────────

// Formation
windowBars = input.int(15, "Formation Window", minval=5, maxval=50, group="Formation")
minHits    = input.int(4,  "Min Hits", minval=2, maxval=20, group="Formation")

// Hit Source
useOpen  = input.bool(true,  "Use Open",  group="Hit Source")
useClose = input.bool(true,  "Use Close", group="Hit Source")

// Tolerance
useATRTolerance = input.bool(true, "ATR Tolerance", group="Tolerance")
atrLength       = input.int(50, "ATR Length", minval=5, maxval=500, group="Tolerance")
atrMultiplier   = input.float(0.15, "ATR Multiplier", minval=0.01, maxval=2.0, step=0.01, group="Tolerance")
manualTicks     = input.int(2, "Manual Tolerance (ticks)", minval=0, maxval=50, group="Tolerance")

// Rules
requireNoCloseThrough = input.bool(true, "Require No Close-Through", group="Rules")

// Display
maxLevels     = input.int(50, "Max Levels", minval=5, maxval=200, group="Display")
extendForever = input.bool(false, "Extend Levels Indefinitely", group="Display")
levelWidth    = input.int(2, "Level Width", minval=1, maxval=5, group="Display")
showOrigin    = input.bool(true, "Show Origin Marker", group="Display")

// Colours
colSupport = input.color(color.new(#1B8A6B, 0), "Support", group="Colours")
colResist  = input.color(color.new(#B22234, 0), "Resistance", group="Colours")

//────────────────────────────────────
// ATR Tolerance
//────────────────────────────────────
tick = syminfo.mintick

fastATR = ta.atr(atrLength)
slowLen = atrLength * 5
slowATR = ta.atr(slowLen)
baseATR = math.min(fastATR, slowATR)

float tol = useATRTolerance ? baseATR * atrMultiplier : manualTicks * tick
if tol <= 0
    tol := tick

//────────────────────────────────────
// Level Storage
//────────────────────────────────────
var levelPrices    = array.new_float()
var levelStartBars = array.new_int()
var levelIsBullish = array.new_bool()
var levelBroken    = array.new_bool()
var levelLines     = array.new_line()
var levelLabels    = array.new_label()

//────────────────────────────────────
// Alert Tracking
//────────────────────────────────────
bool newSupport = false
bool newResistance = false

//────────────────────────────────────
// Check for broken levels
//────────────────────────────────────
if barstate.isconfirmed and levelPrices.size() > 0
    for i = levelPrices.size() - 1 to 0
        if levelBroken.get(i)
            continue

        float lvlPrice = levelPrices.get(i)
        bool  isBull   = levelIsBullish.get(i)

        bool broken = isBull ? (close < lvlPrice - tol) : (close > lvlPrice + tol)

        if broken
            levelBroken.set(i, true)

            if not extendForever
                line lvlLine = levelLines.get(i)
                lvlLine.set_x2(bar_index)

//────────────────────────────────────
// Extend unbroken levels to current bar
//────────────────────────────────────
if barstate.isconfirmed and not extendForever and levelPrices.size() > 0
    for i = 0 to levelPrices.size() - 1
        if not levelBroken.get(i)
            line lvlLine = levelLines.get(i)
            lvlLine.set_x2(bar_index)

//────────────────────────────────────
// Trim old levels beyond max
//────────────────────────────────────
while levelPrices.size() > maxLevels
    levelPrices.shift()
    levelStartBars.shift()
    levelIsBullish.shift()
    levelBroken.shift()

    line oldLine = levelLines.shift()
    oldLine.delete()

    label oldLabel = levelLabels.shift()
    if not na(oldLabel)
        oldLabel.delete()

//────────────────────────────────────
// Core Detection
//────────────────────────────────────
if barstate.isconfirmed

    float detectedLevel = na
    int   detectedStart = na
    int   closesAbove   = 0
    int   closesBelow   = 0

    for i = 0 to windowBars - 1

        float priceCandidate = na
        if useClose
            priceCandidate := close[i]
        else if useOpen
            priceCandidate := open[i]

        if na(priceCandidate)
            continue

        int localHits  = 0
        int localStart = bar_index
        int above      = 0
        int below      = 0

        for j = 0 to windowBars - 1

            if useOpen and math.abs(open[j] - priceCandidate) <= tol
                localHits  += 1
                localStart := math.min(localStart, bar_index - j)

            if useClose and math.abs(close[j] - priceCandidate) <= tol
                localHits  += 1
                localStart := math.min(localStart, bar_index - j)

            if close[j] > priceCandidate + tol
                above += 1
            if close[j] < priceCandidate - tol
                below += 1

        if localHits >= minHits
            detectedLevel := priceCandidate
            detectedStart := localStart
            closesAbove   := above
            closesBelow   := below
            break

    // Defended logic
    bool oneSidedAbove = closesAbove > 0 and closesBelow == 0
    bool oneSidedBelow = closesBelow > 0 and closesAbove == 0

    bool defended = requireNoCloseThrough ? (oneSidedAbove or oneSidedBelow) : true

    if defended and not na(detectedLevel)

        // Duplicate check
        bool duplicate = false
        if levelPrices.size() > 0
            for i = 0 to levelPrices.size() - 1
                if math.abs(levelPrices.get(i) - detectedLevel) <= tol and not levelBroken.get(i)
                    duplicate := true
                    break

        if not duplicate
            bool isBullish = oneSidedAbove
            color lvlCol = isBullish ? colSupport : colResist

            line newLine = na
            if extendForever
                newLine := line.new(x1=detectedStart, y1=detectedLevel, x2=detectedStart, y2=detectedLevel, xloc=xloc.bar_index, extend=extend.right, color=lvlCol, width=levelWidth)
            else
                newLine := line.new(x1=detectedStart, y1=detectedLevel, x2=bar_index, y2=detectedLevel, xloc=xloc.bar_index, extend=extend.none, color=lvlCol, width=levelWidth)

            label newLabel = na
            if showOrigin
                newLabel := label.new(detectedStart, detectedLevel, "●", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=color.new(lvlCol, 85), textcolor=lvlCol, size=size.tiny)

            // Store
            levelPrices.push(detectedLevel)
            levelStartBars.push(detectedStart)
            levelIsBullish.push(isBullish)
            levelBroken.push(false)
            levelLines.push(newLine)
            levelLabels.push(newLabel)

            // Alert flags
            if isBullish
                newSupport := true
            else
                newResistance := true

//────────────────────────────────────
// Alerts
//────────────────────────────────────
alertcondition(newSupport, "New Support Level", "Defended support level detected")
alertcondition(newResistance, "New Resistance Level", "Defended resistance level detected")
alertcondition(newSupport or newResistance, "New Level (Any)", "Defended level detected")
````

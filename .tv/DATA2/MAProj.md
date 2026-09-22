<!-- tradingview-pine-id: PUB;8f622c3804384434b7d33e48a24c70c0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MA.Proj

Source: https://www.tradingview.com/script/q6jJpTzt-MA-Proj-collinplancy/

## Description

MA.Proj — Moving Average with Dynamic Forward Projections

Traditional moving averages stop dead at the current candle. MA.Proj extends your moving average forward into unformed chart space using momentum extrapolation, Heikin-Ashi directional vectors, and mathematical window roll-off modeling.

4 Projection Modes

[*]Linear Momentum (Straight Line) (Default) — Classical Dow Theory tangent-vector projection continuing the moving average's immediate slope.
[*]Damped Momentum (Exhaustion) — Applies an asymptotic decay curve to recent momentum. Decelerates incoming price while historical candles drop out of the sliding window, highlighting where the MA is mathematically likely to crest, flatten, or roll over.
[*]True Induction (Window Roll-off) — Pure mechanical sliding-window simulation. Shows the exact path the MA will take if price stalls at current levels, taking into account old extreme candles rolling out of the calculation.
[*]Heikin Ashi Induction — Uses the directional (haClose - haOpen) spread to project future momentum for sustained trend continuation.

Key Features

[*]Multi-Timeframe Engine (MTF) — Set any timeframe (defaults to 1D) with automatic timeframe dilation scaling.
[*]Configurable Horizons — Project forward 1/2x (default), 1x, 2x, 4x, or 16x the base MA length.
[*]Clean Status Line — Formats cleanly in your chart header as MA.Proj (Length, Timeframe) (e.g., MA.Proj (50, 1D)) without parameter clutter.
[*]Optimized Visuals — High-visibility 4px dotted projection paired with a 50% transparent base MA line to keep underlying price candles clear.

Pro Tip
Stack two instances on your chart (e.g., length 50 and 200, or 9 and 21). The projected dotted lines intersect in advance into empty chart space, giving you early visual notice of upcoming Golden or Death Crosses before the candles actually close.

---

## Source Code

````pine
//@version=6
indicator(title="MA.Proj", shorttitle="MA.Proj", overlay=true, max_bars_back=5000, max_lines_count=100, max_polylines_count=100)

// --- Active Header Inputs ---
len         = input.int(50, minval=1, title="Length")
tfInput     = input.timeframe("1D", title="Timeframe")

// --- Appearance Inputs ---
maColor     = input.color(color.blue, "Color", inline="style", display=display.none)
maWidth     = input.int(4, "MA Width", minval=1, maxval=4, inline="style", display=display.none)
maOpacity   = input.int(50, "MA Opacity %", minval=0, maxval=100, inline="style", display=display.none)
dotWidth    = input.int(4, "Dot Width", minval=1, maxval=10, inline="style2", display=display.none)

// --- Projection Engine ---
projMode    = input.string("Linear Momentum (Straight Line)", "Projection Mode", 
              options=["Linear Momentum (Straight Line)", "Damped Momentum (Exhaustion)", "True Induction (Window Roll-off)", "Heikin Ashi Induction"], display=display.none)
projMultStr = input.string("1/2 (Default)", "Projection Horizon", 
              options=["1/2 (Default)", "1x", "2x", "4x", "16x"], display=display.none)

// --- Internal Constants ---
src         = close
slopeBars   = 3
decayFactor = 0.92

// --- Horizon Mapping ---
float projMult = switch projMultStr
    "1/2 (Default)" => 0.5
    "1x"            => 1.0
    "2x"            => 2.0
    "4x"            => 4.0
    "16x"           => 16.0
    => 0.5

// --- Calculations ---
calcSMA() => ta.sma(src, len)
out = tfInput == "" ? calcSMA() : request.security(syminfo.tickerid, tfInput, calcSMA(), gaps=barmerge.gaps_on)

// MA plot at 50% opacity and max thickness
color maPlotColor = color.new(maColor, 100 - maOpacity)
plot(out, color=maPlotColor, linewidth=maWidth, title="MA", display=display.all - display.status_line)

// Native Heikin-Ashi Bias
float haCloseVal = (open + high + low + close) / 4
var float haOpenVal = na
haOpenVal := na(haOpenVal[1]) ? (open + close) / 2 : (nz(haOpenVal[1]) + nz(haCloseVal[1])) / 2
float haBiasPerBar = (haCloseVal - haOpenVal) / 2

// Timeframe Scaling
chartSec = nz(timeframe.in_seconds(""), 1)
htfSec   = tfInput == "" ? chartSec : nz(timeframe.in_seconds(tfInput), chartSec)
barRatio = (chartSec > 0 and htfSec > chartSec) ? math.max(1, math.round(htfSec / chartSec)) : 1

// --- Projection Geometry ---
validOut     = ta.valuewhen(not na(out), out, 0)
prevValidOut = ta.valuewhen(not na(out), out, slopeBars)
barsSinceOut = ta.barssince(not na(out))

rawProjLen      = math.max(1, math.round(len * projMult))
projBarsOnChart = rawProjLen * barRatio

int startX   = math.max(0, bar_index - nz(barsSinceOut, 0))
float startY = validOut

int maxAllowedBar    = bar_index + 500
int endX             = math.min(startX + projBarsOnChart, maxAllowedBar)
int effectiveProjLen = math.max(0, endX - startX)

hasSufficientData = not na(validOut) and (projMode != "Linear Momentum (Straight Line)" or not na(prevValidOut))

// Drawing Handles
var line projLine     = na
var polyline projPoly = na

isTargetBar = barstate.islast or (barstate.islastconfirmedhistory and not barstate.isrealtime)

if isTargetBar and hasSufficientData and effectiveProjLen > 0 and startX < maxAllowedBar
    if projMode == "Linear Momentum (Straight Line)"
        if not na(projPoly)
            polyline.delete(projPoly)
            projPoly := na

        int slopeChartBars = math.max(1, slopeBars * barRatio)
        float slope        = (validOut - prevValidOut) / slopeChartBars
        float endY         = startY + (slope * effectiveProjLen)

        if na(projLine)
            projLine := line.new(
                 x1=startX, y1=startY,
                 x2=endX,   y2=endY,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=maColor,
                 style=line.style_dotted,
                 width=dotWidth
             )
        else
            line.set_xy1(projLine, startX, startY)
            line.set_xy2(projLine, endX, endY)
            line.set_color(projLine, maColor)
            line.set_width(projLine, dotWidth)
            line.set_style(projLine, line.style_dotted)

    else // Polylines with Corrected Drop-Off Arithmetic
        if not na(projLine)
            line.delete(projLine)
            projLine := na
        if not na(projPoly)
            polyline.delete(projPoly)
            projPoly := na

        chart.point[] points   = array.new<chart.point>()
        float[] simPriceBuffer = array.new<float>()

        array.push(points, chart.point.from_index(startX, startY))

        float simSMA    = startY
        float baseSrc   = nz(src, close)
        float safeDenom = math.max(0.001, 1.0 - decayFactor)

        for step = 1 to effectiveProjLen
            int futureBar = startX + step
            float progress = step / barRatio

            // Dynamic incoming price simulation
            float incomingPrice = baseSrc
            if projMode == "Heikin Ashi Induction"
                incomingPrice := baseSrc + (haBiasPerBar * progress)
            else if projMode == "Damped Momentum (Exhaustion)"
                float decaySum = (1.0 - math.pow(decayFactor, progress)) / safeDenom
                incomingPrice := baseSrc + (haBiasPerBar * decaySum)

            // Mathematically exact drop-off index resolution
            float dropVal = incomingPrice
            int htfStep = math.floor(progress)

            if htfStep < len
                // Historical drop-off: step 1 drops src[len - 1], step len drops src[0]
                int dropIndex = math.max(0, len - htfStep)
                dropVal := (dropIndex < bar_index and dropIndex <= 4999) ? nz(src[dropIndex], baseSrc) : baseSrc
            else
                // Projected forward drop-off (> 1x): step len + 1 drops simPriceBuffer[0]
                int simDropIdx = htfStep - len - 1
                if simDropIdx >= 0 and simDropIdx < array.size(simPriceBuffer)
                    dropVal := array.get(simPriceBuffer, simDropIdx)

            if step % barRatio == 0
                array.push(simPriceBuffer, incomingPrice)

            simSMA += (incomingPrice - dropVal) / (len * barRatio)

            if futureBar <= maxAllowedBar
                array.push(points, chart.point.from_index(futureBar, simSMA))

        if array.size(points) >= 2
            projPoly := polyline.new(
                 points=points,
                 curved=false,
                 closed=false,
                 xloc=xloc.bar_index,
                 line_color=maColor,
                 line_style=line.style_dotted,
                 line_width=dotWidth
             )
````

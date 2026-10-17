# Clean Trendline ELITE (3 Touch + Strength)

- url: https://www.tradingview.com/script/V0IQZ1zf-Clean-Trendline-ELITE-3-Touch-Strength/
- type: indicator
- pine_id: PUB;415828e2819b4434af0ad4bbcdc574ae
- version: 1.0

## Description

**Clean Trendline ELITE (3 Touch + Strength Filter)**

This indicator automatically detects and draws high-quality trendlines using a strict 3-touch validation model combined with a dynamic strength scoring system. It is designed to replicate how experienced traders identify clean, respected trendlines while filtering out noise and weak structures.

The script identifies pivot highs and lows using a configurable pivot length, then constructs trendlines only when three consecutive points form a valid trend (higher lows for uptrends, lower highs for downtrends). The second pivot must align closely with the projected trendline, ensuring true geometric confirmation rather than just sequential pivots.

A built-in strength scoring system evaluates each trendline based on alignment accuracy, slope strength, and structural consistency. Users can define a minimum score threshold to filter out weaker trendlines, allowing only the most reliable setups to be displayed.

The indicator also includes a toggle to switch between wick-based and body-based calculations. Wick mode captures precise market extremes, while body mode provides cleaner, noise-reduced trendlines based on candle bodies.

Breakout signals are generated when price decisively moves beyond a validated trendline, using an ATR-based tolerance to reduce false signals caused by minor price fluctuations.

**Key Features:**

* Automatic 3-touch validated trendline detection
* Strength scoring system to filter high-quality trends
* Wick vs body mode toggle for flexible analysis
* ATR-based tolerance for realistic touch and breakout detection
* Clean breakout signals with optional alerts
* Minimal, clutter-free chart design

This tool is ideal for traders who want objective, rule-based trendline analysis without the subjectivity of manual drawing.

## Source Code

````pine
//@version=5
indicator("Clean Trendline ELITE (3 Touch + Strength)", overlay=true)

// === Inputs ===
pivotLen   = input.int(5, "Pivot Length", minval=2)
useWicks   = input.bool(true, "Use Wicks (ON) or Bodies (OFF)")
showBreaks = input.bool(true, "Show Break Signals")
tolerance  = input.float(0.2, "Touch Tolerance (ATR Multiplier)", step=0.1)
minScore   = input.float(0.6, "Minimum Trend Strength (0–1)", step=0.1)

// === Price Source ===
bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

highSrc = useWicks ? high : bodyHigh
lowSrc  = useWicks ? low  : bodyLow

// === Pivot Detection ===
pivotLow  = ta.pivotlow(lowSrc, pivotLen, pivotLen)
pivotHigh = ta.pivothigh(highSrc, pivotLen, pivotLen)

// === Arrays ===
var float[] lows = array.new_float()
var int[] lowBars = array.new_int()

var float[] highs = array.new_float()
var int[] highBars = array.new_int()

f_push(arr, val) =>
    array.push(arr, val)
    if array.size(arr) > 3
        array.shift(arr)

// Store pivots
if not na(pivotLow)
    f_push(lows, pivotLow)
    f_push(lowBars, bar_index - pivotLen)

if not na(pivotHigh)
    f_push(highs, pivotHigh)
    f_push(highBars, bar_index - pivotLen)

// === Variables ===
var line upLine = na
var line downLine = na

atr = ta.atr(14)
tol = atr * tolerance

// === Strength Function ===
f_score(p1, p2, p3, slope, expected, tol) =>
    // alignment score
    align = 1 - math.min(math.abs(p2 - expected) / tol, 1)

    // slope strength (normalized)
    slopeScore = math.min(math.abs(slope) * 1000, 1)

    // structure score
    structure = (p1 < p2 and p2 < p3) or (p1 > p2 and p2 > p3) ? 1 : 0

    (align * 0.5) + (slopeScore * 0.3) + (structure * 0.2)

// === Uptrend ===
if array.size(lows) == 3
    l1 = array.get(lows, 0)
    l2 = array.get(lows, 1)
    l3 = array.get(lows, 2)

    b1 = array.get(lowBars, 0)
    b2 = array.get(lowBars, 1)
    b3 = array.get(lowBars, 2)

    if l1 < l2 and l2 < l3
        slope = (l3 - l1) / (b3 - b1)
        expected = l1 + slope * (b2 - b1)

        validTouch = math.abs(l2 - expected) < tol
        score = f_score(l1, l2, l3, slope, expected, tol)

        if validTouch and score >= minScore
            line.delete(upLine)
            upLine := line.new(b1, l1, b3, l3, extend=extend.right, color=color.green, width=2)

// === Downtrend ===
if array.size(highs) == 3
    h1 = array.get(highs, 0)
    h2 = array.get(highs, 1)
    h3 = array.get(highs, 2)

    b1 = array.get(highBars, 0)
    b2 = array.get(highBars, 1)
    b3 = array.get(highBars, 2)

    if h1 > h2 and h2 > h3
        slope = (h3 - h1) / (b3 - b1)
        expected = h1 + slope * (b2 - b1)

        validTouch = math.abs(h2 - expected) < tol
        score = f_score(h1, h2, h3, slope, expected, tol)

        if validTouch and score >= minScore
            line.delete(downLine)
            downLine := line.new(b1, h1, b3, h3, extend=extend.right, color=color.red, width=2)

// === Break Detection ===
breakUp = false
breakDown = false

if not na(upLine)
    upPrice = line.get_price(upLine, bar_index)
    breakDown := close < upPrice - tol

if not na(downLine)
    downPrice = line.get_price(downLine, bar_index)
    breakUp := close > downPrice + tol

// === Signals ===
plotshape(showBreaks and breakUp, title="Break Up", location=location.belowbar, color=color.lime, style=shape.triangleup, size=size.small)
plotshape(showBreaks and breakDown, title="Break Down", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

// === Alerts ===
alertcondition(breakUp, title="Trendline Break Up", message="Break above downtrend")
alertcondition(breakDown, title="Trendline Break Down", message="Break below uptrend")
````

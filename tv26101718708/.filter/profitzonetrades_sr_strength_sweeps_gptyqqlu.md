# profitzonetrades S/R + Strength + Sweeps

- url: https://www.tradingview.com/script/GpTYQqlu-profitzonetrades-S-R-Strength-Sweeps/
- type: indicator
- pine_id: PUB;ac84a4ff19e546588245963db92a6d05
- version: 1.0

## Description

profitzonetrades S/R + Strength + Sweeps

profitzonetrades S/R + Strength + Sweeps is a technical analysis indicator designed to identify dynamic support and resistance zones, liquidity sweep rejections, and market reaction strength using price structure, candle behavior, and optional trend confirmation filters.

The script combines several technical analysis concepts into a single workflow focused on liquidity behavior and market structure analysis.

Technical Components Used

This indicator uses the following concepts and calculations:

Pivot Highs & Pivot Lows
Support & Resistance analysis
Liquidity sweep / fake breakout detection
Candle wick rejection analysis
Volume confirmation
EMA200 trend filtering
Dynamic level strength tracking
Dynamic Support & Resistance

The script automatically detects support and resistance levels using pivot-based swing structure.

These levels are:

updated dynamically
extended with price action
ranked by reaction strength
automatically removed when no longer significant

This helps traders focus on active market reaction zones.

Strength-Based Level System

The indicator tracks how often price reacts to each level.

The script measures:

repeated touches
reaction persistence
level interaction frequency

Stronger levels are visually emphasized using:

stronger colors
thicker lines
optional percentage labels

This allows traders to quickly identify more significant support and resistance areas.

Liquidity Sweep Detection

The indicator includes a liquidity sweep detection model designed to identify potential fake breakouts above resistance or below support.

The script evaluates:

breakouts beyond recent highs or lows
wick rejection size
candle body structure
close position relative to previous liquidity zones

Bearish sweeps occur when:

price moves above previous highs
then rejects back below resistance

Bullish sweeps occur when:

price moves below previous lows
then rejects back above support

These conditions may help traders identify liquidity grabs or failed breakout behavior.

Wick Rejection Analysis

The script compares:

candle body size
upper wick size
lower wick size

This helps identify stronger rejection candles and filter weaker breakout attempts.

Volume Confirmation Filter

An optional volume filter compares current volume against average market volume.

This filter may help:

validate stronger rejection candles
reduce weaker signals
improve signal quality during active market participation
EMA200 Trend Filter

The script optionally uses the Exponential Moving Average 200 (EMA200) as a directional trend filter.

EMA200 may be used to:

identify broader trend direction
filter counter-trend sweep signals
align setups with higher timeframe market bias

Bullish sweep signals can be filtered above EMA200, while bearish sweep signals can be filtered below EMA200.

Alerts

Custom alert conditions are included for:

bullish liquidity sweeps
bearish liquidity sweeps

These alerts can be connected to TradingView notifications or external automation systems.

Suggested Usage

This indicator may be useful for:

support and resistance analysis
liquidity sweep identification
fake breakout detection
trend continuation analysis
discretionary intraday trading
swing trading workflows

Many traders may choose to combine the script with:

higher timeframe analysis
market structure confirmation
independent risk management strategies
additional technical confluence
Notes
This script is designed as a technical analysis and chart visualization tool.
The indicator does not guarantee future results or profitable performance.
Market conditions, volatility, and liquidity may affect signal quality.
Users should test settings and parameters according to their own trading approach and market preferences.
Signals and levels may update dynamically during live candle formation until candle close.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © profitzonetrades

//@version=5
indicator("profitzonetrades S/R + Strength + Sweeps", overlay=true, max_lines_count=50, max_labels_count=50)

// === SETTINGS ===
swingLen   = input.int(20, "Swing Length", minval=2)
touchTicks = input.int(20, "Touch Distance", minval=1)
maxLevels  = input.int(6, "Max Levels", minval=1, maxval=20)

// === SWEEP SETTINGS ===
sweepLookback = input.int(20, "Sweep Lookback")
wickMultiplier = input.float(
     1.5,
     "Wick Strength",
     step=0.1,
     tooltip="Higher values require stronger rejection candles.")

useVolumeFilter = input.bool(true, "Use Volume Filter")
useEMAFilter = input.bool(true, "Use EMA200 Filter")

// === EXTRA SETTINGS ===
showStrengthLabels = input.bool(true, "Show Strength Labels")

// === FILTERS ===
ema200 = ta.ema(close, 200)

avgVolume = ta.sma(volume, 20)
highVolume = volume > avgVolume

// === STORAGE ===
var float[] levels = array.new_float()
var int[] touches = array.new_int()
var bool[] isSupport = array.new_bool()
var line[] lines = array.new_line()
var label[] nums = array.new_label()

// === FUNCTIONS ===
f_strength(_t) =>
    int s = 10

    if _t <= 1
        s := 100
    else if _t == 2
        s := 75
    else if _t == 3
        s := 50
    else if _t == 4
        s := 25

    s

f_color(_strength, _isSupport) =>
    color c = color.gray

    if _isSupport
        if _strength >= 75
            c := color.lime
        else if _strength >= 50
            c := color.new(color.lime, 35)
        else if _strength >= 25
            c := color.new(color.green, 55)
        else
            c := color.new(color.green, 75)
    else
        if _strength >= 75
            c := color.red
        else if _strength >= 50
            c := color.orange
        else if _strength >= 25
            c := color.new(color.red, 55)
        else
            c := color.new(color.red, 75)

    c

f_add(_price, _isSupport) =>

    if array.size(levels) >= maxLevels
        oldLine = array.shift(lines)
        oldLabel = array.shift(nums)

        array.shift(levels)
        array.shift(touches)
        array.shift(isSupport)

        line.delete(oldLine)
        label.delete(oldLabel)

    newLine = line.new(
         bar_index - swingLen,
         _price,
         bar_index,
         _price,
         extend=extend.both,
         width=2)

    newLabel = label.new(
         bar_index,
         _price,
         "100%",
         style=label.style_none,
         size=size.small)

    array.push(levels, _price)
    array.push(touches, 1)
    array.push(isSupport, _isSupport)
    array.push(lines, newLine)
    array.push(nums, newLabel)

// === PIVOTS ===
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

if not na(ph)
    f_add(ph, false)

if not na(pl)
    f_add(pl, true)

// === UPDATE LEVELS ===
sizeLevels = array.size(levels)

if sizeLevels > 0
    for i = sizeLevels - 1 to 0

        lvl = array.get(levels, i)
        t = array.get(touches, i)
        sup = array.get(isSupport, i)
        ln = array.get(lines, i)
        lb = array.get(nums, i)

        dist = syminfo.mintick * touchTicks

        touched = high >= lvl - dist and low <= lvl + dist

        if touched
            t += 1
            array.set(touches, i, t)

        strength = f_strength(t)

        if strength <= 10
            line.delete(ln)
            label.delete(lb)

            array.remove(levels, i)
            array.remove(touches, i)
            array.remove(isSupport, i)
            array.remove(lines, i)
            array.remove(nums, i)

        else
            col = f_color(strength, sup)

            line.set_color(ln, col)

            line.set_width(
                 ln,
                 strength >= 75 ? 3 :
                 strength >= 50 ? 2 : 1)

            label.set_xy(lb, bar_index + 3, lvl)

            label.set_text(
                 lb,
                 showStrengthLabels ? str.tostring(strength) + "%" : "")

            label.set_textcolor(lb, col)

// =====================================================
// IMPROVED SWEEP LOGIC
// =====================================================

// Previous liquidity
prevHigh = ta.highest(high, sweepLookback)[1]
prevLow  = ta.lowest(low, sweepLookback)[1]

// Candle structure
bodySize = math.abs(close - open)

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

// =====================================================
// FAKE BREAKOUT ABOVE RESISTANCE (BEARISH SWEEP)
// =====================================================
sweepHigh =
     high > prevHigh and
     close < prevHigh and
     upperWick > bodySize * wickMultiplier

// Filters
sweepHigh := sweepHigh and
     (not useVolumeFilter or highVolume) and
     (not useEMAFilter or close < ema200)

// =====================================================
// FAKE BREAKOUT BELOW SUPPORT (BULLISH SWEEP)
// =====================================================
sweepLow =
     low < prevLow and
     close > prevLow and
     lowerWick > bodySize * wickMultiplier

// Filters
sweepLow := sweepLow and
     (not useVolumeFilter or highVolume) and
     (not useEMAFilter or close > ema200)

// =====================================================
// PLOT SIGNALS
// =====================================================
plotshape(
     sweepHigh,
     title="Fake Breakout High",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small)

plotshape(
     sweepLow,
     title="Fake Breakout Low",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small)

// =====================================================
// ALERTS
// =====================================================
alertcondition(
     sweepHigh,
     title="Bearish Sweep",
     message="Bearish liquidity sweep detected on {{ticker}} {{interval}}")

alertcondition(
     sweepLow,
     title="Bullish Sweep",
     message="Bullish liquidity sweep detected on {{ticker}} {{interval}}")
````

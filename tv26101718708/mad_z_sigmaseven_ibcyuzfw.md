# MAD Z [SigmaSeven]

- url: https://www.tradingview.com/script/IBCYUZfw-MAD-Z-SigmaSeven/
- type: indicator
- pine_id: PUB;0ddfa98872864bfbb1e26efda414e753
- version: 2.0

## Description

MAD Z [SIGMASEVEN]

WHAT IT DOES

MAD Z is a regime oscillator that measures how far price has deviated from its recent median, using the Modified Z-Score, a robust statistical method based on the Median Absolute Deviation (MAD) instead of the classical mean/standard deviation. It classifies the market into three persistent states: Risk-On, Risk-Off, and Hold, and colors the oscillator and (optionally) the price bars accordingly.

WHY MAD INSTEAD OF A CLASSICAL Z-SCORE

A classical z-score uses the mean and standard deviation. Both are heavily distorted by outliers: a single large candle (news spike, liquidation wick) inflates the standard deviation and compresses the score exactly when you need it most. The Modified Z-Score replaces:

- the mean with the rolling median (robust location estimate), and
- the standard deviation with the Median Absolute Deviation (robust scale estimate).

The formula is:

z = 0.6745 * (price - median) / MAD

where MAD = median( |price[i] - median| ) over the lookback window. The constant 0.6745 rescales MAD so the output is comparable to a standard z-score under a normal distribution (0.6745 is the 75th percentile of the standard normal). The practical effect: the score reacts to genuine directional displacement but is far less distorted by single-bar outliers than a standard-deviation-based z-score.

HOW THE STATE LOGIC WORKS

The raw score alone would flip constantly around zero. MAD Z therefore uses a hysteresis state machine with two asymmetric thresholds:

- Score crosses ABOVE the Long Threshold (default +1.30) → state switches to Risk-On and stays there.
- Score crosses BELOW the Short Threshold (default -0.20) → state switches to Risk-Off and stays there.
- Between the thresholds, the last state is held (Hold Zone, shaded band).

The asymmetry (a high bar for entering Risk-On, a much closer bar for exiting into Risk-Off) is deliberate: it demands strong statistical displacement before calling a bullish regime, but exits early when the displacement fades. Both thresholds are fully adjustable, so the behavior can be inverted or symmetrized.

HOW TO READ IT

- Oscillator line: the Modified Z-Score of the selected source (default hlcc4) over the Baseline Length (default 50 bars). Colored by current state.
- Threshold lines and shaded Hold Zone: the hysteresis band described above.
- Gradient fills: visual emphasis of displacement above/below zero.
- Bar Coloring (optional): paints price candles in the current regime color so the state is visible on the main chart without reading the pane.

Typical use: as a regime filter for other strategies (only take longs while Risk-On), or as a standalone mean-displacement gauge on higher timeframes. It is NOT a complete trading system and issues no entries or exits by itself.

SETTINGS

- Source: input series (default hlcc4)
- Baseline Length: lookback for median and MAD (default 50)
- Smoothing / Smoothing (EMA): optional EMA smoothing of the raw score (off by default)
- Long / Short Threshold: hysteresis levels (defaults +1.30 / -0.20)
- Color Mode: 8 preset palettes, or custom Risk-On/Risk-Off colors
- Bar Coloring: toggle candle coloring on the main chart

LIMITATIONS

- The score is computed on the current bar's value and can change until the bar closes; the state can therefore also change intrabar. For confirmed signals, evaluate on bar close.
- The median/MAD baseline needs the full lookback window; the first "Baseline Length" bars show no score.
- Like any displacement measure, it is descriptive of the recent window, not predictive. In prolonged low-volatility ranges MAD becomes small and the score can appear exaggerated.
- Default thresholds were chosen as reasonable general-purpose values, not optimized per market. Adjust them to your instrument and timeframe.

The calculation uses no higher-timeframe requests and no lookahead; it does not repaint past bars.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © S7RESEARCH

//@version=6
indicator("MAD Z [SIGMASEVEN]", overlay = false)

// =============================================================================
// [Σ7] VISUALS
// =============================================================================

simple string colorMode = input.string(defval = "Cyberpunk", title = "Color Mode",
     options = ["Arctic", "Aurora", "Cherry", "Cobalt", "Cyberpunk", "Grape", "Sunset", "Voltage"],
     group = "[Σ7] VISUALS")

simple bool  useCustomColors       = input.bool(false,    title = "Custom Colors?",  group = "[Σ7] VISUALS")
simple color custom_risk_on_color  = input.color(#4CAF50, title = "Risk On Color",   group = "[Σ7] VISUALS")
simple color custom_risk_off_color = input.color(#ff0000, title = "Risk Off Color",  group = "[Σ7] VISUALS")

barColoring = input.bool(true, "Bar Coloring", group = "[Σ7] VISUALS")

// =============================================================================
// [Σ7] COLOR LOGIC
// =============================================================================

getOnColor(simple string mode) =>
    switch mode
        "Arctic"    => #2962ff
        "Aurora"    => #00c853
        "Cherry"    => #e91e63
        "Cobalt"    => #2979ff
        "Cyberpunk" => #00e5ff
        "Grape"     => #ab47bc
        "Sunset"    => #ff7043
        "Voltage"   => #7c4dff
        =>             #e0e0e0

getOffColor(simple string mode) =>
    switch mode
        "Arctic"    => #6b6b6b
        "Aurora"    => #651fff
        "Cherry"    => #78909c
        "Cobalt"    => #ff9100
        "Cyberpunk" => #ff1744
        "Grape"     => #26c6da
        "Sunset"    => #5c6bc0
        "Voltage"   => #ff6d00
        =>             #303030

color risk_on_color  = useCustomColors ? custom_risk_on_color  : getOnColor(colorMode)
color risk_off_color = useCustomColors ? custom_risk_off_color : getOffColor(colorMode)

// =============================================================================
// [Σ7] CONFIGURATION
// =============================================================================

src                   = input.source (hlcc4, "Source"         )
simple int  len       = input.int    (50,    "Baseline Length")
simple bool useSmooth = input.bool   (false, "Smoothing"      )
simple int  smoothLen = input.int    (1,     "Smoothing (EMA)")

// =============================================================================
// [Σ7] THRESHOLDS
// =============================================================================

longThr  = input.float(1.30, "Long Threshold",  step = 0.01, group = "[Σ7] THRESHOLDS")
shortThr = input.float(-0.2, "Short Threshold", step = 0.01, group = "[Σ7] THRESHOLDS")

// =============================================================================
// [Σ7] MODIFIED Z-SCORE
// =============================================================================
// z = 0.6745 * (src - median) / MAD

float med = ta.median(src, len)

float mad = na
if bar_index >= len
    array<float> devs = array.new<float>()
    for i = 0 to len - 1
        array.push(devs, math.abs(src[i] - med))
    mad := array.median(devs)

float zRaw   = mad > 0 ? 0.6745 * (src - med) / mad : na
float signal = useSmooth ? ta.ema(zRaw, smoothLen) : zRaw

// =============================================================================
// [Σ7] STATE
// =============================================================================

var int state = 0
if barstate.isconfirmed
    if signal > longThr
        state := 1
    else if signal < shortThr
        state := -1

bool riskOn  = state ==  1
bool riskOff = state == -1

// =============================================================================
// [Σ7] OSCILLATOR PLOT
// =============================================================================

color scoreCol = riskOn ? risk_on_color : riskOff ? risk_off_color : color.new(#a9a9a9, 0)

pLong  = plot(longThr,  "Long Threshold",  color.new(risk_on_color,  40), 2, plot.style_line,
     display = display.all - display.price_scale - display.status_line)
pShort = plot(shortThr, "Short Threshold", color.new(risk_off_color, 40), 2, plot.style_line,
     display = display.all - display.price_scale - display.status_line)
fill(pLong, pShort, color.new(#787B86, 93), title = "Hold Zone Background")

p0      = plot(0.0,    "Zero",  color.new(#787B86, 30), 1,
     display = display.all - display.price_scale - display.status_line)
pSignal = plot(signal, "MAD-Z", scoreCol, 2)

fill(pSignal, p0, 3.5, 0.0,
     top_color = color.new(risk_on_color, 0), bottom_color = color.new(risk_on_color, 100),
     title = "Risk On Gradient")

fill(pSignal, p0, 0.0, -3.5,
     top_color = color.new(risk_off_color, 100), bottom_color = color.new(risk_off_color, 0),
     title = "Risk Off Gradient")

// =============================================================================
// [Σ7] BAR COLORING
// =============================================================================

var color coloring = na
if riskOn
    coloring := risk_on_color
if riskOff
    coloring := risk_off_color

color barCol = barColoring ? coloring : na
plotcandle(open, high, low, close, "BarColor", color = barCol, bordercolor = barCol, wickcolor = barCol, force_overlay = true)
````

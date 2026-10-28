# Oscillator Suite

- url: https://www.tradingview.com/script/H7oJq2M2-Oscillator-Suite/
- type: indicator
- pine_id: PUB;d3dc5bd32fce4b249e22f316c0dbc6e1
- version: 1.0

## Description

Multi-Oscillator Selector (30-in-1 Dynamic Indicator)
Description:

The Multi-Oscillator Selector is a comprehensive technical analysis tool that consolidates over 30 distinct momentum, trend, and volume oscillators into a single, dynamically adjusting indicator pane. Originally developed for academic and empirical analysis at the B.K. School of Business Management (Gujarat University), this script is designed to eliminate chart clutter, optimize workspace real estate, and streamline comparative technical studies.

Rather than loading multiple scripts and wrestling with overlapping panes, users can seamlessly toggle between vastly different mathematical models using a single dropdown menu.

Core Features
Dynamic Baseline & Threshold Engine: The script does not just swap the plotted mathematical formula; it automatically adjusts the underlying environment. Overbought (OB) and Oversold (OS) levels mathematically lock to the correct parameters for the chosen study (e.g., 70/30 for RSI, 80/20 for Stochastics, 100/-100 for CCI).

Contextual Zero-Lines: For center-oscillating indicators (like MACD, Momentum, or TRIX), the script automatically renders and scales to a zero-line reference. For bound oscillators (like RSI or Williams %R), the zero-line is smartly disabled to prevent visual distortion.

Visual State Highlighting: To aid rapid visual processing, the background pane automatically tints red or green when the selected oscillator breaches its respective mathematical OB/OS bounds.

Universal Parameter Control: A unified "Common Settings" block controls the primary length, secondary length, and signal/smoothing parameters, passing these variables globally to whichever formula is currently active.

Included Mathematical Models
The selector provides instant access to a broad spectrum of market indicators, categorizable into three main groups:

Momentum & Range Bound:
RSI, Stochastic %K, Stochastic RSI, Williams %R, Connors RSI, Ultimate Oscillator, Relative Vigor Index (RVI), Chande Momentum (CMO), Balance of Power (BOP).

Trend & Center-Crossing:
MACD, MACD Histogram, PPO, TRIX, TSI, ROC, Awesome Oscillator, Detrended Price (DPO), Coppock Curve, KST, Vortex, Elder Bull-Bear Power, Aroon Oscillator, Fisher Transform, Ease of Movement (EOM).

Volume & Money Flow:
Money Flow Index (MFI), Chaikin Oscillator, Klinger Oscillator, Percentage Volume Oscillator (PVO).

How to Use
Add to Chart: The indicator will load in a standard lower pane.

Select Indicator: Open the indicator settings and use the "Oscillator" dropdown to switch between the 30+ available models.

Tune Inputs: Adjust the standard lengths (Primary: 14, Secondary: 28, Signal: 9) to fit your specific asset's volatility profile. These lengths will mathematically apply to the selected indicator's primary calculation vectors.

Display Toggles: You can manually disable the OB/OS threshold lines or the zero-line via the "Display" settings if you prefer a minimalist plot.

Release Notes:
Compiled in Pine Script v6. Optimized for minimal calculation overhead despite the extensive library of internal functions.

## Source Code

````pine
//@version=6
// =====================================================================
//  MULTI-OSCILLATOR SELECTOR
//  Select any one of 30+ oscillators from the Settings dropdown.
//  Plots in a separate pane. Overbought/Oversold + Zero reference lines
//  adjust automatically to the chosen oscillator.
//
//  Built for Prof. (B.K. School of Business Management, Gujarat Univ.)
//  Pine Script v6
// =====================================================================
indicator("Multi-Oscillator Selector", shorttitle="MultiOsc", overlay=false)

// ---------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------
osc = input.string("RSI", "Oscillator", group="Selection", options=[
     "RSI",
     "Stochastic %K",
     "Stochastic RSI",
     "Williams %R",
     "CCI",
     "ROC",
     "Momentum",
     "TSI",
     "Ultimate Oscillator",
     "Awesome Oscillator",
     "Chande Momentum (CMO)",
     "Relative Vigor Index (RVI)",
     "Fisher Transform",
     "Detrended Price (DPO)",
     "Coppock Curve",
     "KST",
     "Connors RSI",
     "MACD",
     "MACD Histogram",
     "PPO",
     "Aroon Oscillator",
     "TRIX",
     "Vortex (VI+ minus VI-)",
     "Elder Bull-Bear Power",
     "Chaikin Oscillator",
     "Money Flow Index (MFI)",
     "Klinger Oscillator",
     "Ease of Movement (EOM)",
     "Percentage Volume Osc (PVO)",
     "Balance of Power (BOP)"
     ])

src   = input.source(close, "Source",         group="Common Settings")
len   = input.int(14,      "Primary Length",   group="Common Settings", minval=1)
len2  = input.int(28,      "Secondary Length", group="Common Settings", minval=1)
sig   = input.int(9,       "Signal/Smoothing", group="Common Settings", minval=1)

showOBOS = input.bool(true, "Show Overbought/Oversold lines",       group="Display")
showZero = input.bool(true, "Show Zero line (centered oscillators)", group="Display")

// ---------------------------------------------------------------------
// HELPER FUNCTIONS
// ---------------------------------------------------------------------
f_tsi(s, long, short) =>
    pc  = ta.change(s)
    ds  = ta.ema(ta.ema(pc, long), short)
    dap = ta.ema(ta.ema(math.abs(pc), long), short)
    dap != 0 ? 100 * (ds / dap) : 0.0

f_cmo(s, l) =>
    mom = ta.change(s)
    up  = math.sum(mom > 0 ?  mom : 0.0, l)
    dn  = math.sum(mom < 0 ? -mom : 0.0, l)
    (up + dn) == 0 ? 0.0 : 100 * (up - dn) / (up + dn)

f_fisher(l) =>
    hh   = ta.highest(hl2, l)
    ll   = ta.lowest(hl2, l)
    rng  = hh - ll
    val  = 0.0
    raw  = rng != 0 ? (hl2 - ll) / rng - 0.5 : 0.0
    val := 0.66 * math.max(math.min(2 * raw, 0.999), -0.999) + 0.67 * nz(val[1])
    fish = 0.0
    fish := 0.5 * math.log((1 + val) / (1 - val)) + 0.5 * nz(fish[1])
    fish

// ---------------------------------------------------------------------
// OSCILLATOR COMPUTATIONS
// ---------------------------------------------------------------------
plotVal = 0.0      // main oscillator line
obLevel = float(na) // overbought line
osLevel = float(na) // oversold line
useZero = false    // whether a zero line is meaningful

if osc == "RSI"
    plotVal := ta.rsi(src, len)
    obLevel := 70
    osLevel := 30

else if osc == "Stochastic %K"
    plotVal := ta.stoch(close, high, low, len)
    obLevel := 80
    osLevel := 20

else if osc == "Stochastic RSI"
    rsiv = ta.rsi(src, len)
    plotVal := ta.stoch(rsiv, rsiv, rsiv, len)
    obLevel := 80
    osLevel := 20

else if osc == "Williams %R"
    plotVal := ta.wpr(len)               // ranges -100..0
    obLevel := -20
    osLevel := -80

else if osc == "CCI"
    plotVal := ta.cci(src, len)
    obLevel := 100
    osLevel := -100
    useZero := true

else if osc == "ROC"
    plotVal := ta.roc(src, len)
    useZero := true

else if osc == "Momentum"
    plotVal := ta.mom(src, len)
    useZero := true

else if osc == "TSI"
    plotVal := f_tsi(src, len2, len)
    obLevel := 25
    osLevel := -25
    useZero := true

else if osc == "Ultimate Oscillator"
    bp   = close - math.min(low, close[1])
    tr_  = math.max(high, close[1]) - math.min(low, close[1])
    avg7  = math.sum(bp, 7)  / math.sum(tr_, 7)
    avg14 = math.sum(bp, 14) / math.sum(tr_, 14)
    avg28 = math.sum(bp, 28) / math.sum(tr_, 28)
    plotVal := 100 * (4 * avg7 + 2 * avg14 + avg28) / 7
    obLevel := 70
    osLevel := 30

else if osc == "Awesome Oscillator"
    plotVal := ta.sma(hl2, 5) - ta.sma(hl2, 34)
    useZero := true

else if osc == "Chande Momentum (CMO)"
    plotVal := f_cmo(src, len)
    obLevel := 50
    osLevel := -50
    useZero := true

else if osc == "Relative Vigor Index (RVI)"
    co   = close - open
    hlr  = high - low
    num  = ta.swma(co)
    den  = ta.swma(hlr)
    plotVal := ta.sma(den, len) != 0 ? ta.sma(num, len) / ta.sma(den, len) : 0.0
    useZero := true

else if osc == "Fisher Transform"
    plotVal := f_fisher(len)
    useZero := true

else if osc == "Detrended Price (DPO)"
    barsback = len / 2 + 1
    plotVal := src - ta.sma(src, len)[barsback]
    useZero := true

else if osc == "Coppock Curve"
    plotVal := ta.wma(ta.roc(src, 14) + ta.roc(src, 11), 10)
    useZero := true

else if osc == "KST"
    rcma1 = ta.sma(ta.roc(src, 10), 10)
    rcma2 = ta.sma(ta.roc(src, 15), 10)
    rcma3 = ta.sma(ta.roc(src, 20), 10)
    rcma4 = ta.sma(ta.roc(src, 30), 15)
    plotVal := rcma1 * 1 + rcma2 * 2 + rcma3 * 3 + rcma4 * 4
    useZero := true

else if osc == "Connors RSI"
    rsi3   = ta.rsi(src, 3)
    streak = 0.0
    streak := close > close[1] ? (nz(streak[1]) > 0 ? nz(streak[1]) + 1 : 1) : close < close[1] ? (nz(streak[1]) < 0 ? nz(streak[1]) - 1 : -1) : 0
    rsiStreak = ta.rsi(streak, 2)
    pctRank   = ta.percentrank(ta.roc(src, 1), 100)
    plotVal := (rsi3 + rsiStreak + pctRank) / 3
    obLevel := 90
    osLevel := 10

else if osc == "MACD"
    [macdLine, _, _] = ta.macd(src, len, len2, sig)
    plotVal := macdLine
    useZero := true

else if osc == "MACD Histogram"
    [_, _, hist] = ta.macd(src, len, len2, sig)
    plotVal := hist
    useZero := true

else if osc == "PPO"
    fastMa = ta.ema(src, len)
    slowMa = ta.ema(src, len2)
    plotVal := slowMa != 0 ? 100 * (fastMa - slowMa) / slowMa : 0.0
    useZero := true

else if osc == "Aroon Oscillator"
    upA   = 100 * (ta.highestbars(high, len + 1) + len) / len
    dnA   = 100 * (ta.lowestbars(low, len + 1) + len) / len
    plotVal := upA - dnA
    obLevel := 50
    osLevel := -50
    useZero := true

else if osc == "TRIX"
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    plotVal := e3 != 0 ? 10000 * ta.change(e3) / e3 : 0.0
    useZero := true

else if osc == "Vortex (VI+ minus VI-)"
    vmp = math.sum(math.abs(high - low[1]), len)
    vmm = math.sum(math.abs(low - high[1]), len)
    strn = math.sum(ta.tr(true), len)
    plotVal := strn != 0 ? (vmp / strn) - (vmm / strn) : 0.0
    useZero := true

else if osc == "Elder Bull-Bear Power"
    emaV = ta.ema(close, len)
    plotVal := (high - emaV) + (low - emaV)
    useZero := true

else if osc == "Chaikin Oscillator"
    mfm = (high == low) ? 0.0 : ((close - low) - (high - close)) / (high - low)
    adl = ta.cum(mfm * volume)
    plotVal := ta.ema(adl, 3) - ta.ema(adl, 10)
    useZero := true

else if osc == "Money Flow Index (MFI)"
    plotVal := ta.mfi(hlc3, len)
    obLevel := 80
    osLevel := 20

else if osc == "Klinger Oscillator"
    sv = volume * (ta.change(hlc3) >= 0 ? 1 : -1)
    plotVal := ta.ema(sv, 34) - ta.ema(sv, 55)
    useZero := true

else if osc == "Ease of Movement (EOM)"
    dm   = hl2 - hl2[1]
    boxR = (high - low) != 0 ? (volume / 100000000) / (high - low) : 0.0
    plotVal := boxR != 0 ? ta.sma(dm / boxR, len) : 0.0
    useZero := true

else if osc == "Percentage Volume Osc (PVO)"
    fastV = ta.ema(volume, len)
    slowV = ta.ema(volume, len2)
    plotVal := slowV != 0 ? 100 * (fastV - slowV) / slowV : 0.0
    useZero := true

else if osc == "Balance of Power (BOP)"
    plotVal := (high == low) ? 0.0 : (close - open) / (high - low)
    obLevel := 0.5
    osLevel := -0.5
    useZero := true

// ---------------------------------------------------------------------
// PLOTTING
// ---------------------------------------------------------------------
plot(plotVal, title="Oscillator", color=color.new(#2962FF, 0), linewidth=2)

obPlot = showOBOS ? obLevel : na
osPlot = showOBOS ? osLevel : na
hline(0, "Zero", color = showZero and useZero ? color.new(color.gray, 0) : na, linestyle=hline.style_dashed)
plot(obPlot, "Overbought", color=color.new(color.red, 0),   style=plot.style_linebr)
plot(osPlot, "Oversold",   color=color.new(color.green, 0), style=plot.style_linebr)

// Background tint when in OB/OS zone
bgcolor(showOBOS and not na(obLevel) and plotVal > obLevel ? color.new(color.red, 90)   : na, title="OB tint")
bgcolor(showOBOS and not na(osLevel) and plotVal < osLevel ? color.new(color.green, 90) : na, title="OS tint")
````

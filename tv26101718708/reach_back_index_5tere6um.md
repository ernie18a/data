# Reach Back Index

- url: https://www.tradingview.com/script/5TErE6uM-Reach-Back-Index/
- type: indicator
- pine_id: PUB;392e2e44d5d84009b5eda0f3870263d4
- version: 1.0

## Description

.RBI — Reach Back Index.

RBI (Reach Back Index) is a streamlined confluence indicator designed to help traders read the Reach Back rather than rely on a single buy or sell signal.

RBI combines three components into one clean oscillator:

FTDZ — Main Line: The primary directional and turning-behavior component.
Ultimate RSI — Signal Line: Acts like an EMA-style confirmation line, helping identify whether momentum is supporting the FTDZ movement.
Reach Back Wave — Timing Dots: Uses the original WaveTrend dot logic to highlight significant bullish and bearish momentum shifts. Blue dots represent bullish signals from oversold conditions, while red dots represent bearish signals from overbought conditions.
RBI Philosophy

RBI is built around the idea that a Reach Back should be evaluated as a process, not simply an entry signal.

FTDZ → Momentum → WaveTrend Timing

The indicator is designed to help traders answer:

“Is this Reach Back developing, confirming, weakening, or potentially changing direction?”

RBI intentionally avoids excessive signals, arrows, and overlapping indicators. It focuses on clarity, confluence, and timing.

RBI  Read the Reach Back.

## Source Code

````pine
//@version=6
indicator("RBI — Reach Back Index", shorttitle="RBI", overlay=false, max_bars_back=500)

//──────────────────────────────────────────────────────────────────────────────
// RBI — Reach Back Index
// FTDZ = main line
// Ultimate RSI = EMA-style signal line
// Reach Back Wave = ORIGINAL WaveTrend DOT LOGIC ONLY
// No FTDZ triangles. No WaveTrend line.
//──────────────────────────────────────────────────────────────────────────────

//==============================
// FTDZ SETTINGS
//==============================
groupFTDZ = "FTDZ — Main Line"

ftdzLen      = input.int(10, "FTDZ Length", minval=1, group=groupFTDZ)
ftdzSmooth   = input.int(1, "FTDZ Smoothing", minval=1, group=groupFTDZ)
zoneLen      = input.int(50, "Dynamic Zone Length", minval=10, group=groupFTDZ)
zonePercent  = input.float(70.0, "Zone Percentile", minval=50.0, maxval=99.0, step=0.5, group=groupFTDZ)

src = hl2

var float value = 0.0
var float fish  = 0.0

hh = ta.highest(src, ftdzLen)
ll = ta.lowest(src, ftdzLen)
rng = hh - ll

raw = rng != 0.0 ? 2.0 * ((src - ll) / rng - 0.5) : 0.0
rawClamped = math.max(-0.999, math.min(0.999, raw))

value := 0.33 * rawClamped + 0.67 * nz(value[1])
fish  := 0.5 * math.log((1.0 + value) / (1.0 - value)) + 0.5 * nz(fish[1])

ftdz = ta.ema(fish, ftdzSmooth)

upperZone = ta.percentile_linear_interpolation(ftdz, zoneLen, zonePercent)
lowerZone = ta.percentile_linear_interpolation(ftdz, zoneLen, 100.0 - zonePercent)
midZone   = 0.0

ftdzBull = ftdz >= ftdz[1]
ftdzColor = ftdzBull ? color.lime : color.red

plot(upperZone, "FTDZ Upper Zone", color=color.new(color.gray, 65))
plot(lowerZone, "FTDZ Lower Zone", color=color.new(color.gray, 65))
plot(midZone,   "FTDZ Mid Zone",   color=color.new(color.gray, 75))
plot(ftdz, "FTDZ — Main Line", color=ftdzColor, linewidth=3)

//==============================
// ULTIMATE RSI SETTINGS
//==============================
groupRSI = "Ultimate RSI — Signal Line"

rsiLen       = input.int(14, "Length", minval=1, group=groupRSI)
rsiSmooth    = input.int(14, "Signal Smoothing", minval=1, group=groupRSI)
rsiSrc       = input.source(close, "Source", group=groupRSI)

upper = ta.rma(math.max(ta.change(rsiSrc), 0), rsiLen)
lower = ta.rma(-math.min(ta.change(rsiSrc), 0), rsiLen)

rs = lower == 0.0 ? 100.0 :
     upper == 0.0 ? 0.0 :
     100.0 - (100.0 / (1.0 + upper / lower))

ftdzAbs = ta.highest(math.abs(ftdz), zoneLen)
rsiMapped = ((rs - 50.0) / 50.0) * ftdzAbs
rsiSignal = ta.ema(rsiMapped, rsiSmooth)

plot(rsiSignal, "Ultimate RSI — Signal", color=color.orange, linewidth=3)

//==============================
// ORIGINAL WAVETREND DOT LOGIC
//==============================
groupWT = "Reach Back Wave — ORIGINAL Dot Logic"

n1 = input.int(10, "WT Channel Length", minval=1, group=groupWT)
n2 = input.int(21, "WT Average Length", minval=1, group=groupWT)

// These two options reproduce the original script's default behavior.
// Original defaults: TRUE / TRUE.
salesOnlyOB = input.bool(true, "Only Red Dots in Overbought", group=groupWT)
buysOnlyOS  = input.bool(true, "Only Blue Dots in Oversold", group=groupWT)

nsc = input.float(53.0, "Overbought Level", minval=0.0, group=groupWT)
nsv = input.float(-53.0, "Oversold Level", maxval=0.0, group=groupWT)

showDots = input.bool(true, "Show Blue/Red Dots", group=groupWT)

// Original WaveTrend engine:
// ap = hlc3
// esa = ema(ap, n1)
// d = ema(abs(ap - esa), n1)
// ci = (ap - esa) / (0.015 * d)
// tci = ema(ci, n2)
// wt1 = tci
// wt2 = sma(wt1, 4)

ap = hlc3
esa = ta.ema(ap, n1)
d = ta.ema(math.abs(ap - esa), n1)
ci = d != 0.0 ? (ap - esa) / (0.015 * d) : 0.0
wt1 = ta.ema(ci, n2)
wt2 = ta.sma(wt1, 4)

// EXACT ORIGINAL DOT CONDITIONS:
//
// Red:
// crossunder(wt1, wt2) AND wt1 >= nsc
// OR all bearish crosses when the OB-only filter is disabled.
//
// Blue:
// crossover(wt1, wt2) AND wt1 <= nsv
// OR all bullish crosses when the OS-only filter is disabled.

redDot = salesOnlyOB ? ta.crossunder(wt1, wt2) and wt1 >= nsc : ta.crossunder(wt1, wt2)
blueDot = buysOnlyOS ? ta.crossover(wt1, wt2) and wt1 <= nsv : ta.crossover(wt1, wt2)

// Keep the RBI panel clean. The WaveTrend itself is NOT plotted.
// Only the filtered timing dots are shown.
plotshape(showDots and blueDot,
     title="RBI Blue Dot",
     style=shape.circle,
     location=location.bottom,
     color=color.blue,
     size=size.tiny)

plotshape(showDots and redDot,
     title="RBI Red Dot",
     style=shape.circle,
     location=location.top,
     color=color.red,
     size=size.tiny)

//==============================
// ALERTS
//==============================
alertcondition(blueDot,
     title="RBI Blue Dot",
     message="RBI — Reach Back Index: BLUE WaveTrend dot printed.")

alertcondition(redDot,
     title="RBI Red Dot",
     message="RBI — Reach Back Index: RED WaveTrend dot printed.")

alertcondition(blueDot or redDot,
     title="RBI WaveTrend Dot",
     message="RBI — Reach Back Index: WaveTrend timing dot printed.")
````

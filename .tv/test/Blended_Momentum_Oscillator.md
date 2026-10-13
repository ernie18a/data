<!-- tradingview-pine-id: PUB;7b3d2d0f47be45b5a736f024a96d7d90 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Blended Momentum Oscillator

Source: https://www.tradingview.com/script/CA6LjhT5/

## Description

Blended Momentum Oscillator

Overview

A bounded momentum indicator plotted in a separate pane below the chart. It blends two normalized momentum measures into a single 0–100 line, smoothing out the whipsaw that either measure produces on its own.

How it works

The output is the arithmetic mean of two components:

1. **Smoothed RSI** — a 14-period RSI passed through a 14-period Hull Moving Average. The HMA reduces lag compared to a simple or exponential smoothing of the same length while cutting the noise of raw RSI.
2. **Slow Stochastic** — a 200-period Stochastic of close against the 200-bar high/low range, smoothed with a 50-period EMA. The long lookback makes this component a slow-moving positional reference rather than a fast trigger.

Both components are natively bounded to 0–100, so their average is too. Missing values are substituted with the neutral midpoint of 50 so the line stays continuous on new symbols or thin history.

The fast RSI leg supplies responsiveness; the slow Stochastic leg anchors the reading to where price sits within its longer-term range. A high combined value therefore requires both recent momentum *and* an elevated position in the 200-bar range.

Reading the indicator

**Color gradient.** The line is continuously colored by its own value, dark green at the bottom of the scale through green, lime, yellow, orange, red, to maroon at the top. Color alone communicates the current regime without reading the number.

**Levels.** Dashed lines mark 80 and 20; a dotted line marks the 50 midpoint. The 20–80 band is lightly shaded. Because both components are long-period and averaged, excursions past 80 or below 20 are comparatively rare — these are not the frequent, low-signal touches typical of a standalone 14-period RSI.

**Pivot markers.** An X cross is plotted at each confirmed local extreme of the oscillator that occurs in an extreme zone: pivot highs above 80 (maroon) and pivot lows below 20 (teal). Detection uses one bar left and one bar right, so a marker is confirmed one bar after the fact and is drawn back at the pivot bar. These mark the point where an extended reading actually turns, rather than the moment it first enters the zone.

**Scale.** Two invisible anchor plots at 0 and 100 pin the pane to the full range. The vertical scale never rescales to the visible data, so the distance between readings is comparable across symbols and timeframes.

Notes

- No inputs. All periods are fixed by design; the component lengths are chosen to be deliberately mismatched in speed, and altering them changes the character of the blend.
- Requires roughly 200 bars of history before the slow component is fully seeded.
- Timeframe-agnostic. It works on any chart period, but the 200-bar Stochastic means the effective lookback in calendar time scales with the chart's timeframe.
- This is an analytical tool, not a signal system. Extreme readings and pivot markers describe conditions; they are not entry or exit instructions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wick_vaporup

//@version=6
indicator("Blended Momentum Oscillator", overlay = false, precision = 2, scale = scale.right)

// --- Oscillator  -------------------------------------------
f_osc() =>
    stoch_raw = ta.stoch(close, high, low, 200)
    (nz(ta.hma(ta.rsi(close, 14), 14), 50.0) + nz(ta.ema(nz(stoch_raw, 50.0), 50), 50.0)) / 2

// --- Color logic ---------------------------
f_get_color(val) =>
    switch
        val >= 80 => color.from_gradient(val, 80, 81, color.red,    color.maroon)
        val >= 70 => color.from_gradient(val, 70, 80, color.orange, color.red)
        val >= 50 => color.from_gradient(val, 50, 70, color.yellow, color.orange)
        val >= 30 => color.from_gradient(val, 30, 50, color.lime,   color.yellow)
        val >= 20 => color.from_gradient(val, 20, 30, color.green,  color.lime)
        => color.from_gradient(val, 19, 20, color.rgb(3, 69, 5), color.green)

osc = f_osc()
col = na(osc) ? color.gray : f_get_color(osc)

// --- Plot -------------------------------------------------------------
plot(osc, "Osc", color = col, linewidth = 2)

hUp  = hline(80, "OB",  color = color.new(color.red,   50), linestyle = hline.style_dashed)
hMid = hline(50, "Mid", color = color.new(color.gray,  70), linestyle = hline.style_dotted)
hDn  = hline(20, "OS",  color = color.new(color.green, 50), linestyle = hline.style_dashed)
fill(hUp, hDn, color = color.new(color.gray, 96))

// --- Scale anchors: fix the pane to 0-100 -----------------------------
plot(0,   "A0",   color = color.new(color.white, 100), display = display.none, editable = false)
plot(100, "A100", color = color.new(color.white, 100), display = display.none, editable = false)

// --- Pivot signal  -------------------------------
ph = ta.pivothigh(osc, 1, 1)
pl = ta.pivotlow(osc, 1, 1)
plotshape(not na(ph) and ph > 80 ? ph : na, "PH", shape.xcross, location.absolute, color.new(color.maroon, 0), offset = -1, size = size.tiny)
plotshape(not na(pl) and pl < 20 ? pl : na, "PL", shape.xcross, location.absolute, color.new(color.teal,   0), offset = -1, size = size.tiny)
````

<!-- tradingview-pine-id: PUB;0b8e6227c4cb4159a436fed672554186 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HARSI Fisher Transform & Divergence

Source: https://www.tradingview.com/script/tjwslEiX/

## Description

# HARSI Fisher Transform & Divergence — Publication Description

## Description
This indicator runs a Heikin-Ashi RSI (HARSI) based oscillator through a
single-pole Fisher Transform filter to produce a cleaner, lower-lag turning/
momentum line. HARSI candles are plotted on the same visual scale as the
Fisher line (auto-scaled to volatility), so you can read both the raw HARSI
candles and the smoothed Fisher line in a single pane.

The indicator includes two independent divergence engines — one running on
the Fisher line, the other on the raw HARSI candles. Both engines compare
against real price highs/lows to detect regular (reversal) and hidden
(continuation) bullish/bearish divergence, with an optional maximum
pivot-distance filter and a separate alert condition for every signal type.

## Source Code & Credits
- **HARSI (Heikin-Ashi RSI) calculation** (`f_zrsi`, `f_rsiHeikinAshi`
  functions): based on **JayRogers'** open-source **"Heikin Ashi RSI
  Oscillator"** (Pine v4) script, ported to Pine v6 for this indicator. See
  the original author's TradingView profile for the source script.
- **Fisher Transform concept**: developed by John Ehlers and considered
  public domain; this script contains its own continuous, single-pole
  implementation of the technique.

## Original Contributions Added In This Version
Beyond the underlying HARSI calculation, the following parts are original
to this script and constitute a significant improvement:
- A continuous single-pole Fisher Transform layer applied to HARSI HL2
- A dual divergence engine running **separately** on the Fisher line and on
  the HARSI candle (regular + hidden, bullish + bearish — 8 signal types
  total)
- An optional maximum pivot-distance filter to discard stale pivot pairs
  and reduce false signals
- Auto-scaling of the HARSI candle body to share the Fisher line's pane
  (a `ta.stdev`-based ratio, floored/capped against sudden spikes)
- A dedicated `alertcondition` for every signal type
- Pine v4 → v6 port and general code cleanup

These additions go beyond a minor style or naming change to the HARSI base —
they add an independent layer that extends the indicator's function and
purpose.

## Open-Source Note
This script is **open-source**; because it builds on JayRogers' original
open-source HARSI logic, it is published as open-source rather than
protected/invite-only.

## How to Use
Settings are organized into four groups: HARSI candle settings, Fisher
Transform settings, divergence settings, and display settings. Defaults are
suitable for general use; the pivot left/right bar counts and maximum pivot
distance can be adjusted to tune signal frequency and lag.

*This indicator is for educational and analytical purposes only and does
not constitute investment advice.*

---

## Source Code

````pine
//@version=6

// =====================================================================
// HARSI Fisher Transform & Divergence
// =====================================================================
// Applies a Heikin-Ashi transform to a zero-centered RSI (HARSI), then
// runs a single continuous Fisher Transform over the HARSI midpoint to
// produce a smoothed, more clearly-defined oscillator line. HARSI candles
// are plotted alongside the Fisher line, auto-scaled (via a rolling
// standard-deviation ratio) to share one visual scale with the Fisher
// line and its overbought/oversold levels.
//
// Two independent divergence engines run against real price highs/lows:
//   - Fisher line divergence: pivots on the Fisher line vs. price
//   - HARSI candle divergence: pivots on the raw HARSI close vs. price
// Each detects regular (reversal) and hidden (continuation) bullish and
// bearish divergence, with an optional maximum-pivot-distance filter and
// an alertcondition for every signal type.
//
// CREDITS:
// The Heikin-Ashi RSI (HARSI) calculation (f_zrsi, f_rsiHeikinAshi) is
// based on JayRogers' open-source "Heikin Ashi RSI Oscillator" (Pine v4).
// Ported to Pine v6 and combined here with a continuous single-pole Fisher
// Transform (concept: John Ehlers, public domain) plus original dual-engine
// regular/hidden divergence detection (Fisher line + HARSI candle) added
// by this author.
// =====================================================================
indicator(title="HARSI Fisher Transform & Divergence", shorttitle="HARSI Fisher Div", format=format.price, precision=2)

// ==========================================
// 1. INPUTS
// ==========================================
string GROUP_CAND   = "HARSI Candle Settings"
i_lenHARSI          = input.int(14, "HARSI Length", minval=1, group=GROUP_CAND)
i_smoothing         = input.int(1, "Open Smoothing", minval=1, maxval=100, group=GROUP_CAND)

string GROUP_FISH   = "Fisher Transform Settings"
i_lenFisher         = input.int(9, "Fisher Length", minval=1, group=GROUP_FISH)

string GROUP_DIV    = "Divergence Settings"
i_checkReg          = input.bool(true, "Show Regular Divergences", group=GROUP_DIV)
i_checkHid          = input.bool(true, "Show Hidden Divergences", group=GROUP_DIV)
i_divOnFisher       = input.bool(true, "Search Divergence on Fisher Line", group=GROUP_DIV)
i_divOnCandle       = input.bool(true, "Search Divergence on HARSI Candle", group=GROUP_DIV)
i_lbRight           = input.int(2, "Pivot Right Bars", minval=1, group=GROUP_DIV)
i_lbLeft            = input.int(5, "Pivot Left Bars", minval=1, group=GROUP_DIV)
i_useMaxLookback    = input.bool(true, "Limit Maximum Pivot Distance", group=GROUP_DIV)
i_maxLookback       = input.int(60, "Maximum Pivot Distance (bars)", minval=1, group=GROUP_DIV)

string GROUP_VIS     = "Display Settings"
i_showHARSI         = input.bool(true, "Show HARSI Candles", group=GROUP_VIS)
i_autoScale         = input.bool(true, "Auto-Scale Candle to Fisher Line", group=GROUP_VIS)
i_scaleLookback      = input.int(200, "Scale Calculation Period", minval=20, group=GROUP_VIS)
i_manualScale        = input.float(0.06, "Manual Scale Multiplier (when Auto is off)", minval=0.001, step=0.01, group=GROUP_VIS)
i_sizeOption         = input.string("Small", "Candle Marker Size", options=["Tiny", "Small", "Normal"], group=GROUP_VIS)
i_colUp             = input.color(color.teal, "Bullish Color", group=GROUP_VIS, inline="col")
i_colDown           = input.color(color.red, "Bearish Color", group=GROUP_VIS, inline="col")
i_colWick           = input.color(color.gray, "Wick Color", group=GROUP_VIS, inline="col")

// ==========================================
// 2. FUNCTIONS & CALCULATIONS
// ==========================================
f_zrsi(_src, _len) =>
    ta.rsi(_src, _len) - 50.0

f_rsiHeikinAshi(_len) =>
    float _closeRSI    = f_zrsi(close, _len)
    float _openRSI     = nz(_closeRSI[1], _closeRSI)

    float _highRSI_raw = f_zrsi(high, _len)
    float _lowRSI_raw  = f_zrsi(low, _len)

    float _highRSI     = math.max(_highRSI_raw, _lowRSI_raw)
    float _lowRSI      = math.min(_highRSI_raw, _lowRSI_raw)

    float _close       = (_openRSI + _highRSI + _lowRSI + _closeRSI) / 4.0

    var float _open    = na
    _open             := na(_open[1]) ? (_openRSI + _closeRSI) / 2.0 : ((_open[1] * i_smoothing) + _close[1]) / (i_smoothing + 1)

    float _high        = math.max(_highRSI, math.max(_open, _close))
    float _low         = math.min(_lowRSI, math.min(_open, _close))

    [_open, _high, _low, _close]

[O, H, L, C] = f_rsiHeikinAshi(i_lenHARSI)

harsi_hl2 = (H + L) / 2.0

highest_harsi = ta.highest(harsi_hl2, i_lenFisher)
lowest_harsi  = ta.lowest(harsi_hl2, i_lenFisher)

f_round_val(_val) =>
    _val > 0.99 ? 0.999 : _val < -0.99 ? -0.999 : _val

var float fishValue = 0.0
rawVal = (highest_harsi - lowest_harsi) != 0 ? (harsi_hl2 - lowest_harsi) / (highest_harsi - lowest_harsi) : 0.5
fishValue := f_round_val(0.66 * (rawVal - 0.5) + 0.67 * nz(fishValue[1]))

var float fish1 = 0.0
fish1 := 0.5 * math.log((1 + fishValue) / math.max(1 - fishValue, 1e-10)) + 0.5 * nz(fish1[1])
fish2 = fish1[1]

// ==========================================
// 3. DISPLAY SCALE
// ==========================================
// NOTE: ta.highest() is highly sensitive to a single outlier bar; when
// harsiAmplitude collapses near zero (RSI hovering near 50 / a quiet
// market), the ratio can spike and blow up the candle scale, forcing the
// pane's autoscale to squash the Fisher line/hlines to near-zero visually.
// ta.stdev is far more stable, plus a meaningful floor on the denominator
// and a clamp on the final ratio prevent both blow-up and flattening.
harsiAmplitude  = ta.stdev(harsi_hl2, i_scaleLookback)
fisherAmplitude = ta.stdev(fish1, i_scaleLookback)
rawRatio        = fisherAmplitude / math.max(harsiAmplitude, 0.5)
autoRatio       = math.min(math.max(rawRatio, 0.005), 2.0)
dispScale       = i_autoScale ? autoRatio : i_manualScale

dispO = O * dispScale
dispH = H * dispScale
dispL = L * dispScale
dispC = C * dispScale

// ==========================================
// 4. DIVERGENCE LOGIC
// ==========================================
// Regular Bullish  : price makes a lower low  + oscillator makes a higher low  -> weakening downside momentum
// Regular Bearish  : price makes a higher high + oscillator makes a lower high  -> weakening upside momentum
// Hidden Bullish   : price makes a higher low  + oscillator makes a lower low   -> uptrend continuation
// Hidden Bearish   : price makes a lower high  + oscillator makes a higher high -> downtrend continuation
// An optional maximum-pivot-distance filter discards pairs of pivots that are too far apart.
f_calcDivergence(src, priceHigh, priceLow, _lbLeft, _lbRight, _useMaxLB, _maxLB) =>
    ph = ta.pivothigh(src, _lbLeft, _lbRight)
    pl = ta.pivotlow(src, _lbLeft, _lbRight)

    bull = false
    if not na(pl)
        val_pl = src[_lbRight]
        price_val_pl = priceLow[_lbRight]
        prev_pl = ta.valuewhen(not na(pl), src[_lbRight], 1)
        prev_price_pl = ta.valuewhen(not na(pl), priceLow[_lbRight], 1)
        prev_bar_pl = ta.valuewhen(not na(pl), bar_index[_lbRight], 1)
        distOk_pl = not _useMaxLB or (bar_index[_lbRight] - prev_bar_pl <= _maxLB)
        if price_val_pl < prev_price_pl and val_pl > prev_pl and distOk_pl
            bull := true

    bear = false
    if not na(ph)
        val_ph = src[_lbRight]
        price_val_ph = priceHigh[_lbRight]
        prev_ph = ta.valuewhen(not na(ph), src[_lbRight], 1)
        prev_price_ph = ta.valuewhen(not na(ph), priceHigh[_lbRight], 1)
        prev_bar_ph = ta.valuewhen(not na(ph), bar_index[_lbRight], 1)
        distOk_ph = not _useMaxLB or (bar_index[_lbRight] - prev_bar_ph <= _maxLB)
        if price_val_ph > prev_price_ph and val_ph < prev_ph and distOk_ph
            bear := true

    hiddenBull = false
    if not na(pl)
        val_pl2 = src[_lbRight]
        price_val_pl2 = priceLow[_lbRight]
        prev_pl2 = ta.valuewhen(not na(pl), src[_lbRight], 1)
        prev_price_pl2 = ta.valuewhen(not na(pl), priceLow[_lbRight], 1)
        prev_bar_pl2 = ta.valuewhen(not na(pl), bar_index[_lbRight], 1)
        distOk_pl2 = not _useMaxLB or (bar_index[_lbRight] - prev_bar_pl2 <= _maxLB)
        if price_val_pl2 > prev_price_pl2 and val_pl2 < prev_pl2 and distOk_pl2
            hiddenBull := true

    hiddenBear = false
    if not na(ph)
        val_ph2 = src[_lbRight]
        price_val_ph2 = priceHigh[_lbRight]
        prev_ph2 = ta.valuewhen(not na(ph), src[_lbRight], 1)
        prev_price_ph2 = ta.valuewhen(not na(ph), priceHigh[_lbRight], 1)
        prev_bar_ph2 = ta.valuewhen(not na(ph), bar_index[_lbRight], 1)
        distOk_ph2 = not _useMaxLB or (bar_index[_lbRight] - prev_bar_ph2 <= _maxLB)
        if price_val_ph2 < prev_price_ph2 and val_ph2 > prev_ph2 and distOk_ph2
            hiddenBear := true

    [bull, bear, hiddenBull, hiddenBear]

[bullCond, bearCond, hiddenBullCond, hiddenBearCond] = f_calcDivergence(fish1, high, low, i_lbLeft, i_lbRight, i_useMaxLookback, i_maxLookback)
// Candle-based engine compares against the real chart's high/low, consistent
// with the Fisher-line engine -> both engines detect genuine price-vs-oscillator divergence.
[bullCondC, bearCondC, hiddenBullCondC, hiddenBearCondC] = f_calcDivergence(C, high, low, i_lbLeft, i_lbRight, i_useMaxLookback, i_maxLookback)

// ==========================================
// 5. PLOTS & VISUALIZATION
// ==========================================
color bodyColor = C > O ? i_colUp : i_colDown
plotcandle(i_showHARSI ? dispO : na, i_showHARSI ? dispH : na, i_showHARSI ? dispL : na, i_showHARSI ? dispC : na, title="HARSI (Scaled Display)", color=bodyColor, wickcolor=i_colWick, bordercolor=bodyColor)

hline(1.5, "Overbought (+1.5)", color=#E91E63)
hline(0.75, "Upper Band (0.75)", color=#787B86, linestyle=hline.style_dashed)
hline(0, "Neutral (0)", color=color.gray)
hline(-0.75, "Lower Band (-0.75)", color=#787B86, linestyle=hline.style_dashed)
hline(-1.5, "Oversold (-1.5)", color=#E91E63)

plot(fish1, color=#2962FF, title="HARSI Fisher", linewidth=2)
plot(fish2, color=#FF6D00, title="Trigger Line", linewidth=1)

// --- Divergence Markers: Fisher Line (Label) ---
plotshape(i_divOnFisher and i_checkReg and bullCond ? fish1[i_lbRight] : na, title="Fisher Regular Bullish Divergence", style=shape.labelup, location=location.absolute, color=color.green, text="R.BULL", textcolor=color.white, offset=-i_lbRight)
plotshape(i_divOnFisher and i_checkReg and bearCond ? fish1[i_lbRight] : na, title="Fisher Regular Bearish Divergence", style=shape.labeldown, location=location.absolute, color=color.red, text="R.BEAR", textcolor=color.white, offset=-i_lbRight)
plotshape(i_divOnFisher and i_checkHid and hiddenBullCond ? fish1[i_lbRight] : na, title="Fisher Hidden Bullish Divergence", style=shape.labelup, location=location.absolute, color=color.lime, text="H.BULL", textcolor=color.black, offset=-i_lbRight)
plotshape(i_divOnFisher and i_checkHid and hiddenBearCond ? fish1[i_lbRight] : na, title="Fisher Hidden Bearish Divergence", style=shape.labeldown, location=location.absolute, color=color.maroon, text="H.BEAR", textcolor=color.white, offset=-i_lbRight)

// --- Divergence Markers: HARSI Candle ---
isTiny   = i_sizeOption == "Tiny"
isSmall  = i_sizeOption == "Small"
isNormal = i_sizeOption == "Normal"

// Tiny Size Plots
plotshape(i_divOnCandle and i_checkReg and bullCondC and isTiny ? dispL[i_lbRight] : na, title="Candle Regular Bullish (Tiny)", style=shape.triangleup, location=location.absolute, color=color.green, size=size.tiny, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkReg and bearCondC and isTiny ? dispH[i_lbRight] : na, title="Candle Regular Bearish (Tiny)", style=shape.triangledown, location=location.absolute, color=color.red, size=size.tiny, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkHid and hiddenBullCondC and isTiny ? dispL[i_lbRight] : na, title="Candle Hidden Bullish (Tiny)", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.tiny, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkHid and hiddenBearCondC and isTiny ? dispH[i_lbRight] : na, title="Candle Hidden Bearish (Tiny)", style=shape.triangledown, location=location.absolute, color=color.maroon, size=size.tiny, offset=-i_lbRight)

// Small Size Plots
plotshape(i_divOnCandle and i_checkReg and bullCondC and isSmall ? dispL[i_lbRight] : na, title="Candle Regular Bullish (Small)", style=shape.triangleup, location=location.absolute, color=color.green, size=size.small, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkReg and bearCondC and isSmall ? dispH[i_lbRight] : na, title="Candle Regular Bearish (Small)", style=shape.triangledown, location=location.absolute, color=color.red, size=size.small, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkHid and hiddenBullCondC and isSmall ? dispL[i_lbRight] : na, title="Candle Hidden Bullish (Small)", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.small, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkHid and hiddenBearCondC and isSmall ? dispH[i_lbRight] : na, title="Candle Hidden Bearish (Small)", style=shape.triangledown, location=location.absolute, color=color.maroon, size=size.small, offset=-i_lbRight)

// Normal Size Plots
plotshape(i_divOnCandle and i_checkReg and bullCondC and isNormal ? dispL[i_lbRight] : na, title="Candle Regular Bullish (Normal)", style=shape.triangleup, location=location.absolute, color=color.green, size=size.normal, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkReg and bearCondC and isNormal ? dispH[i_lbRight] : na, title="Candle Regular Bearish (Normal)", style=shape.triangledown, location=location.absolute, color=color.red, size=size.normal, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkHid and hiddenBullCondC and isNormal ? dispL[i_lbRight] : na, title="Candle Hidden Bullish (Normal)", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.normal, offset=-i_lbRight)
plotshape(i_divOnCandle and i_checkHid and hiddenBearCondC and isNormal ? dispH[i_lbRight] : na, title="Candle Hidden Bearish (Normal)", style=shape.triangledown, location=location.absolute, color=color.maroon, size=size.normal, offset=-i_lbRight)

// ==========================================
// 6. ALERTS
// ==========================================
alertcondition(bullCond, title="Fisher Regular Bullish Divergence", message="HARSI Fisher: Regular Bullish Divergence")
alertcondition(bearCond, title="Fisher Regular Bearish Divergence", message="HARSI Fisher: Regular Bearish Divergence")
alertcondition(hiddenBullCond, title="Fisher Hidden Bullish Divergence", message="HARSI Fisher: Hidden Bullish Divergence")
alertcondition(hiddenBearCond, title="Fisher Hidden Bearish Divergence", message="HARSI Fisher: Hidden Bearish Divergence")

alertcondition(bullCondC, title="Candle Regular Bullish Divergence", message="HARSI Candle: Regular Bullish Divergence")
alertcondition(bearCondC, title="Candle Regular Bearish Divergence", message="HARSI Candle: Regular Bearish Divergence")
alertcondition(hiddenBullCondC, title="Candle Hidden Bullish Divergence", message="HARSI Candle: Hidden Bullish Divergence")
alertcondition(hiddenBearCondC, title="Candle Hidden Bearish Divergence", message="HARSI Candle: Hidden Bearish Divergence")
````

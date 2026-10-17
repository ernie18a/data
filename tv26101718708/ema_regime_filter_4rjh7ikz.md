# EMA Regime Filter

- url: https://www.tradingview.com/script/4RJH7IKZ-EMA-Regime-Filter/
- type: indicator
- pine_id: PUB;507ef074a04e48249971f6f97ee0795b
- version: 1.0

## Description

EMA Regime Filter is a trade/no-trade filter built on the spread between a fast
and a slow EMA. Instead of treating every EMA cross as a signal, it asks two
questions on every bar: *is the spread big enough to matter?* and *is it still
expanding?* Only when both answers are yes does it mark the market as tradeable
in that direction. Everything else is flagged as chop.

It's meant to sit underneath your existing entry method and keep you out of
the flat, whipsaw stretches where EMA-based systems give most of their losses
back.

**How it works**

1. **EMA spread.** The main line is Fast EMA − Slow EMA (9 and 21 by default).
   Above zero the fast EMA leads, below zero it lags.
2. **Dead zone.** A band around zero (the dashed yellow lines) marks spreads
   too small to trust. You can size the band three ways:
   - **% of Price** (default, 0.04%): scales with the instrument, so one setting
     works on ES, NQ, CL, stocks and crypto.
   - **Absolute**: a fixed point distance.
   - **ATR**: a fraction of ATR, so the band widens in volatile markets and
     tightens in quiet ones.
3. **Momentum confirmation.** The spread has to widen bar over bar by at least
   the *Min Spread Growth %* (10% by default) for *Lookback Bars* consecutive
   bars (3 by default). One stalled or shrinking bar resets the count. That
   separates a trend that's building from one that's rolling over, even when
   the spread is still outside the dead zone.

**Regime output**

- **OK Long (1)**: spread above the upper band *and* expanding upward for the
  required bars. The line turns green and the background shades green.
- **OK Short (−1)**: spread below the lower band *and* expanding downward. The
  line turns red and the background shades red.
- **No Trade (0)**: anything else, whether that's inside the dead zone, a
  spread that has stopped widening, or a direction that disagrees. The line
  turns gray.

The regime value is shown in the Data Window, so you can read it at a glance or
reference it in your own workflow.

**Markers**

- ◆ Diamond: an OK Long or OK Short regime begins
- ■ Square: an OK Long or OK Short regime ends
- ▲ / ▼ Triangle on the zero line: the fast EMA crosses above or below the
  slow EMA

**Alerts**

OK Long start/end, OK Short start/end, entered No-Trade, and zero-line crosses
up/down. Set alerts to *Once Per Bar Close* to match the indicator's bar-close
logic.

**Tips**

- The regime is strict on purpose. It usually confirms a few bars into a move
  and drops out as soon as expansion stalls. Use it as a gate ("am I allowed to
  take longs right now?") rather than as a standalone entry or exit.
- If it's too restrictive for your timeframe, lower *Lookback Bars* or *Min
  Spread Growth %* first. If it lets through too much chop, raise the dead
  zone.
- % of Price is the easiest mode for switching between symbols. ATR mode suits
  instruments whose volatility changes a lot from session to session.

**Settings**

- EMA Settings: Fast / Slow EMA length
- Dead Zone: mode, %, absolute threshold, ATR multiplier, ATR length
- Momentum Confirmation: lookback bars, minimum spread growth %
- Visuals: background shading, markers, and all colors

This indicator is a filter for market conditions. It does not predict price and
is not financial advice. Always test settings on your own instruments and
timeframes before trading with them.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("EMA Regime Filter", shorttitle = "EMA Regime", overlay = false, precision = 4)

// Port of the NinjaTrader 8 EMARegimeFilter indicator.
// Fast/Slow EMA spread with a dead zone + momentum (spread-expansion) confirmation.
// Regime: 1 = OK Long, -1 = OK Short, 0 = No Trade.

// === INPUTS ===
grpEma  = "EMA Settings"
fastLen = input.int(9,  "Fast EMA Length", minval = 1, group = grpEma)
slowLen = input.int(21, "Slow EMA Length", minval = 1, group = grpEma)

grpDz     = "Dead Zone"
dzMode    = input.string("% of Price", "Dead Zone Mode", options = ["% of Price", "Absolute", "ATR"], group = grpDz,
     tooltip = "% of Price = works across all instruments. Absolute = fixed point threshold. ATR = scales with volatility.")
dzPct     = input.float(0.04, "Dead Zone %", minval = 0, step = 0.01, group = grpDz,
     tooltip = "EMAs must differ by at least this % of price. Only used in % of Price mode.")
dzAbs     = input.float(10.0, "Absolute Threshold", minval = 0, group = grpDz,
     tooltip = "Fixed point difference. Only used in Absolute mode.")
dzAtrMult = input.float(0.1, "ATR Multiplier", minval = 0, step = 0.05, group = grpDz,
     tooltip = "Fraction of ATR. Only used in ATR mode.")
atrLen    = input.int(14, "ATR Length", minval = 1, group = grpDz)

grpMom    = "Momentum Confirmation"
momBars   = input.int(3, "Lookback Bars", minval = 1, maxval = 20, group = grpMom,
     tooltip = "Number of consecutive bars the spread must widen.")
minExpPct = input.float(10.0, "Min Spread Growth %", minval = 0, maxval = 200, group = grpMom,
     tooltip = "Spread must widen by at least this % bar-over-bar. 0 = any widening.")

grpVis         = "Visuals"
showBackground = input.bool(true, "Show Background Color", group = grpVis)
showMarkers    = input.bool(true, "Show Regime / Zero-Cross Markers", group = grpVis)
okLongColor    = input.color(color.green,                  "OK Long Color",   group = grpVis)
okShortColor   = input.color(color.red,                    "OK Short Color",  group = grpVis)
deadZoneColor  = input.color(color.gray,                   "Dead Zone Color", group = grpVis)
bgLongColor    = input.color(color.new(color.green, 85),   "BG Long Color",   group = grpVis)
bgShortColor   = input.color(color.new(color.red, 85),     "BG Short Color",  group = grpVis)
dzBandColor    = input.color(color.yellow,                 "DZ Band Color",   group = grpVis)

// === CALCULATIONS ===
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atr     = ta.atr(atrLen)

emaDiff     = emaFast - emaSlow
emaDiffPrev = nz(emaDiff[1])

dzThresh = switch dzMode
    "ATR"      => atr * dzAtrMult
    "Absolute" => dzAbs
    => close * dzPct / 100.0

// Warm-up (matches NT8: skip until slow EMA / ATR have settled + momentum lookback)
ready = bar_index >= math.max(slowLen, atrLen) + momBars

// Momentum: bar-over-bar spread growth
spreadNow  = math.abs(emaDiff)
spreadPrev = math.abs(emaDiffPrev)
barGrowth  = spreadPrev > 0 ? (spreadNow - spreadPrev) / spreadPrev * 100.0 : 0.0
barWidening = barGrowth >= minExpPct

var int wideningUpCount   = 0
var int wideningDownCount = 0

if ready
    if emaDiff > emaDiffPrev and barWidening
        wideningUpCount   += 1
        wideningDownCount := 0
    else if emaDiff < emaDiffPrev and barWidening
        wideningDownCount += 1
        wideningUpCount   := 0
    else
        wideningUpCount   := 0
        wideningDownCount := 0

okLong  = ready and emaDiff >  dzThresh and wideningUpCount   >= momBars
okShort = ready and emaDiff < -dzThresh and wideningDownCount >= momBars
regime  = okLong ? 1 : okShort ? -1 : 0
prevRegime = nz(regime[1])

// === OUTPUT ===
diffColor = regime == 1 ? okLongColor : regime == -1 ? okShortColor : deadZoneColor

plot(ready ? emaDiff   : na, "EMA Diff", diffColor, 2)
plot(ready ? dzThresh  : na, "DZ Upper", dzBandColor, 1, linestyle = plot.linestyle_dashed)
plot(ready ? -dzThresh : na, "DZ Lower", dzBandColor, 1, linestyle = plot.linestyle_dashed)
plot(ready ? regime    : na, "Regime", display = display.data_window)
hline(0, "Zero", color.new(color.white, 50), hline.style_dotted)

bgcolor(showBackground and regime == 1 ? bgLongColor : showBackground and regime == -1 ? bgShortColor : na, title = "Regime Background")

// Regime transition markers
longStart  = ready and regime == 1  and prevRegime != 1
shortStart = ready and regime == -1 and prevRegime != -1
longEnd    = ready and regime != 1  and prevRegime == 1
shortEnd   = ready and regime != -1 and prevRegime == -1
zeroUp     = ready and emaDiff > 0 and emaDiffPrev <= 0
zeroDown   = ready and emaDiff < 0 and emaDiffPrev >= 0

plotshape(showMarkers and longStart  ? emaDiff : na, "OK Long Start",  shape.diamond,      location.absolute, color.lime,             size = size.tiny)
plotshape(showMarkers and shortStart ? emaDiff : na, "OK Short Start", shape.diamond,      location.absolute, color.red,              size = size.tiny)
plotshape(showMarkers and longEnd    ? emaDiff : na, "OK Long End",    shape.square,       location.absolute, color.new(#006400, 0), size = size.tiny)
plotshape(showMarkers and shortEnd   ? emaDiff : na, "OK Short End",   shape.square,       location.absolute, color.new(#8B0000, 0), size = size.tiny)
plotshape(showMarkers and zeroUp     ? 0.0     : na, "Zero Cross Up",   shape.triangleup,   location.absolute, color.lime,             size = size.tiny)
plotshape(showMarkers and zeroDown   ? 0.0     : na, "Zero Cross Down", shape.triangledown, location.absolute, color.red,              size = size.tiny)

// === ALERTS ===
alertcondition(longStart,  "OK Long Start",   "EMA Regime: OK Long started on {{ticker}} {{interval}}")
alertcondition(shortStart, "OK Short Start",  "EMA Regime: OK Short started on {{ticker}} {{interval}}")
alertcondition(longEnd,    "OK Long End",     "EMA Regime: OK Long ended on {{ticker}} {{interval}}")
alertcondition(shortEnd,   "OK Short End",    "EMA Regime: OK Short ended on {{ticker}} {{interval}}")
alertcondition(regime == 0 and prevRegime != 0, "Entered No-Trade", "EMA Regime: No Trade zone on {{ticker}} {{interval}}")
alertcondition(zeroUp,     "Zero Cross Up",   "EMA Regime: fast EMA crossed above slow EMA on {{ticker}} {{interval}}")
alertcondition(zeroDown,   "Zero Cross Down", "EMA Regime: fast EMA crossed below slow EMA on {{ticker}} {{interval}}")
````

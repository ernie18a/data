# MHIDa Candle-Structure Pullback

- url: https://www.tradingview.com/script/NpaCtfTk/
- type: indicator
- pine_id: PUB;298b52e6c24b400485a4273be2509b5d
- version: 1.0

## Description

Candle-Structure Pullback highlights classic bullish re-entry candles - the bullish engulfing and the hammer - but only when the market is in an underlying uptrend.

WHAT IT DOES
- Detects bullish engulfing candles: the previous bar is red, the current bar is green, and its body engulfs the previous red body (open <= previous close and close >= previous open).
- Detects hammers: a green candle with a small body (default <= 40% of the candle range), a long lower wick (default >= 2 times the body) and a short upper wick (default <= 35% of the range).
- Filters both through a trend gate: a pattern only counts while the close is above a slow EMA (default length 100, the "bull gate").
- Draws the gate EMA, shades the background lightly while price is above it, and marks valid re-entries below the bar (ENG = engulfing, HAM = hammer). Patterns that appear outside the bull are shown as small grey crosses so you can see they were ignored on purpose.

WHY THESE PIECES ARE COMBINED
Candle patterns alone appear everywhere and mean very little. A re-entry candle is only useful as "the dip is exhausting and buyers are responding", and that reading only makes sense inside an underlying uptrend. In a falling market the same candle is far more often a trap. The EMA gate is therefore not an extra: it is what gives the pattern its meaning.

HOW IT IS CALCULATED
All conditions are evaluated on closed bars only. The gate is ta.ema(close, length). Engulfing and hammer are pure comparisons of open, high, low and close of the current and previous bar. Nothing repaints.

HOW TO USE
Add it to a standard candlestick chart. Look at the markers as a prompt to study the pullback: check where price is relative to the gate, how deep the dip was and what the larger structure looks like. Adjust the EMA length and the hammer ratios to the symbol and timeframe you study; the defaults are a starting point, not a tested configuration. An optional alert fires when a valid re-entry appears inside the bull. Markers are drawn only on standard chart types (not Heikin Ashi, Renko, Kagi, Point and Figure or Range).

LIMITS
This is a context tool, not a signal and not financial advice. No trades are simulated and no performance is computed. Candlestick patterns taken blindly are not enough; even with the gate this is an aid to read the chart, and the decision is always yours.

## Source Code

````pine
//@version=6
// Candle-Structure Pullback - a support for evaluating what you see on the chart,
// NOT a signal or financial advice, and not a winning tool on its own. You always decide.
//
// WHAT IT DOES (in plain words):
//   It looks for classic "re-entry" candles - the BULLISH ENGULFING (the green candle
//   engulfs the body of the previous red one) and the HAMMER (small body near the top,
//   long lower wick, a sign that sellers pushed price down but were rejected). On their
//   own these candles appear everywhere and don't mean much. Here they only count when
//   the market is already in an underlying uptrend, i.e. when price is ABOVE the slow
//   EMA100 (the "bull gate"). Outside the trend the tool ignores them on purpose, because
//   the same candle in a falling market is much more often a trap.
//
// WHY the EMA100 gate:
//   A re-entry candle is useful as "the dip is exhausting, buyers are responding": this
//   only makes sense inside an underlying uptrend. The EMA100 filter is therefore an
//   integral part of the tool, not an extra: it stops it from showing re-entry patterns
//   while the market is dropping hard.
//
// HONESTY: this is a visual SUPPORT for reading the chart, NOT a system that wins on its
//   own. Candlestick patterns taken blindly are not enough. Even with the bull gate they
//   remain an AID to frame a pullback inside a bullish context, not an order to buy.
//   No performance numbers: nothing is simulated here, only the context is drawn. The
//   defaults are a STARTING POINT, not "the" correct configuration.
//
// LOGIC: a long-side "buy the dip" idea (long-only mean reversion). The re-entry comes
//   after a move down, with confirmation on the bar (the candle closes back up), causal
//   and on a closed bar. Markers are drawn only on standard chart types.

indicator("MHIDa Candle-Structure Pullback", shorttitle="Candle-PB", overlay=true)

// ---------------- INPUTS (default = starting point, not truth) ----------------
lenTrend   = input.int(100, "Bull gate: EMA length", minval=2, tooltip="The slow average that defines the 'underlying bull'. Re-entry candles only count above this average. Default 100 as a starting point.")

usaEngulf  = input.bool(true,  "Look for bullish engulfing")
usaHammer  = input.bool(true,  "Look for hammer")

cordaMin   = input.float(2.0, "Hammer: lower wick >= N times the body", minval=0.5, step=0.1, tooltip="How long the lower wick must be relative to the body for it to be a hammer. Default 2.0 as a starting point.")
corpoMaxPct= input.float(40.0, "Hammer: body <= % of the candle range", minval=5.0, maxval=90.0, step=1.0, tooltip="Small body relative to the whole candle = buying pressure from below. Default 40% as a starting point.")
codaSupMax = input.float(35.0, "Hammer: upper wick <= % of the range", minval=0.0, maxval=90.0, step=1.0, tooltip="Little wick on top = the bounce held. Default 35% as a starting point.")

mostraGate = input.bool(true,  "Show the gate average (EMA)")
ombreggia  = input.bool(true,  "Shade the background when above the gate (bull)")

// ---------------- BULL GATE CALCULATION ----------------
emaTrend = ta.ema(close, lenTrend)
inToro   = close > emaTrend                 // gate: only count inside the underlying bull

// ---------------- CANDLE STRUCTURE (causal, on closed bar) ----------------
corpo    = math.abs(close - open)
rangeTot = high - low
codaGiu  = math.min(open, close) - low      // lower wick
codaSu   = high - math.max(open, close)     // upper wick

// BULLISH ENGULFING: previous bar red, current bar green,
//   the green body engulfs the previous red body (opens <= prev close, closes >= prev open).
rossaPrec      = close[1] < open[1]
verdeOra       = close > open
inghiotteCorpo = (open <= close[1]) and (close >= open[1])
engulf = usaEngulf and rossaPrec and verdeOra and inghiotteCorpo

// HAMMER: small body, long lower wick, little wick on top, and a non-bearish candle.
hammer = usaHammer and rangeTot > 0 and verdeOra and (codaGiu >= cordaMin * corpo) and (corpo <= (corpoMaxPct / 100.0) * rangeTot) and (codaSu <= (codaSupMax / 100.0) * rangeTot)

// raw pattern (before the gate) - only for internal clarity
patternGrezzo = engulf or hammer

// THE POINT: the pattern only counts inside the bull (EMA100 gate)
pullbackValido = patternGrezzo and inToro

// ---------------- DRAWING ----------------
plot(mostraGate ? emaTrend : na, "Bull gate (EMA)", color=color.new(color.orange, 0), linewidth=2)

// very light background when inside the bull: the context in which patterns count
bgcolor(ombreggia and inToro ? color.new(color.teal, 92) : na, title="Above the gate (bull)")

// marker: valid engulfing (inside the bull)
plotshape(pullbackValido and engulf and chart.is_standard, title="Bullish engulfing (in bull)", style=shape.triangleup, location=location.belowbar, color=color.new(color.teal, 0), size=size.tiny, text="ENG")

// marker: valid hammer (inside the bull)
plotshape(pullbackValido and hammer and not engulf and chart.is_standard, title="Hammer (in bull)", style=shape.diamond, location=location.belowbar, color=color.new(color.green, 0), size=size.tiny, text="HAM")

// visual reminder: pattern present BUT outside the bull = ignored on purpose
plotshape(patternGrezzo and not inToro and chart.is_standard, title="Pattern outside the bull (ignored)", style=shape.xcross, location=location.belowbar, color=color.new(color.gray, 40), size=size.tiny)

// non-intrusive alert: it is meant to make you LOOK at the chart, not to act automatically
alertcondition(pullbackValido, title="Candle-PB: re-entry in bull", message="Candle-Structure Pullback: re-entry candle (engulfing/hammer) INSIDE the bull (above EMA100). A support for evaluation, not a signal. Look at the chart and decide for yourself.")
````

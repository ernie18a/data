# The Setup Factory Short-Term Extension

- url: https://www.tradingview.com/script/kpdxpDHC-The-Setup-Factory-Short-Term-Extension/
- type: indicator
- pine_id: PUB;bd7e60ae0369461391f3bc9c8c1b788e
- version: 1.0

## Description

The Setup Factory Short-Term Extension

This indicator marks the bars where a stock's close is stretched far above its short-term moving averages, measured in ATRs. It shows two levels of extension, one against the 9 EMA and one against the 21 EMA.

WHAT IT SHOWS
- Red marker: the close is 2 or more ATRs above the 9 EMA.
- Teal marker: the close is 2.5 or more ATRs above the 21 EMA. When both apply, the teal marker sits above the red one.
- Only extension to the upside is marked.

HOW IT IS CALCULATED
The distance of the close above the EMA, as a percentage of the EMA, is divided by the ATR(14) as a percentage of the close:
Extension = ((Close - EMA) / EMA) / (ATR / Close)
A marker appears when that value reaches the threshold for its EMA.

HOW TO USE IT
Use the markers to see when a move has become stretched in the short term, for example before adding to a position or when deciding whether to take some profit into strength. The markers describe how extended price is. They are not buy or sell signals. A marker on the current bar is final once the bar closes.

SETTINGS
Each marker can be switched on or off, and its EMA length, ATR threshold, colour and shape can be changed. The ATR length can also be changed.

This is the extension formula and calibration used in The Setup Factory's own tools, published as one fixed standard. All rules it applies are stated above.

## Source Code

````pine
//@version=6
indicator("The Setup Factory Short-Term Extension", shorttitle = "TSF ST Ext", overlay = true)

// ── Inputs ──────────────────────────────────────────────────────────────────
// Short term: marker when the close is at least this many ATRs above the fast EMA
showFast  = input.bool(true, "Show fast")
fastLen   = input.int(9, "Fast EMA", minval = 1)
fastMult  = input.float(2.0, "Fast x ATR", minval = 0.1, step = 0.1)
fastColor = input.color(#E53935, "Fast colour")
fastShape = input.string("Diamond", "Fast shape", options = ["Diamond", "Triangle", "Square", "Dot"])

// Intermediate term: marker when the close is at least this many ATRs above the slow EMA
showSlow  = input.bool(true, "Show slow")
slowLen   = input.int(21, "Slow EMA", minval = 1)
slowMult  = input.float(2.5, "Slow x ATR", minval = 0.1, step = 0.1)
slowColor = input.color(#4FB8B2, "Slow colour")
slowShape = input.string("Diamond", "Slow shape", options = ["Diamond", "Triangle", "Square", "Dot"])

atrLen    = input.int(14, "ATR length", minval = 1)

// ── Fixed values ────────────────────────────────────────────────────────────
FAST_GAP = 0.3      // red marker: distance above the candle's high, in ATRs
SLOW_GAP = 0.8      // teal marker: distance above the candle's high, in ATRs

// ── Values ──────────────────────────────────────────────────────────────────
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atrNow  = ta.atr(atrLen)

// Extension in ATRs (same form as the TSF screener spec):
//   A = ATR / Close x 100
//   B = (Close - EMA) / EMA x 100
//   Extension = B / A
atrPct  = atrNow / close * 100
extFast = ((close - emaFast) / emaFast * 100) / atrPct
extSlow = ((close - emaSlow) / emaSlow * 100) / atrPct

fastHit = showFast and extFast >= fastMult
slowHit = showSlow and extSlow >= slowMult

// ── Marker shapes, taken from the settings ──────────────────────────────────
fastStyle = fastShape == "Diamond" ? shape.diamond : fastShape == "Triangle" ? shape.triangledown : fastShape == "Square" ? shape.square : shape.circle
slowStyle = slowShape == "Diamond" ? shape.diamond : slowShape == "Triangle" ? shape.triangledown : slowShape == "Square" ? shape.square : shape.circle

// ── Markers above the candle, on the main price chart ───────────────────────
// Each marker has its own height, so the two never cover each other: red first, teal above it.
plotshape(fastHit ? high + FAST_GAP * atrNow : na, title = "Extended from fast EMA", style = fastStyle,
     location = location.absolute, color = fastColor, size = size.tiny, force_overlay = true)
plotshape(slowHit ? high + SLOW_GAP * atrNow : na, title = "Extended from slow EMA", style = slowStyle,
     location = location.absolute, color = slowColor, size = size.tiny, force_overlay = true)

// ── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(fastHit, "Extended from the fast EMA", "The close is extended above the fast EMA")
alertcondition(slowHit, "Extended from the slow EMA", "The close is extended above the slow EMA")
````

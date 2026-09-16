<!-- tradingview-pine-id: PUB;ed75338784ae4fa295d1167987fc39b2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pin bar + sweep poprzedniej świecy

Source: https://www.tradingview.com/script/CSckeTDY-Sweep-Reject-Pin-Bars/

## Description

Marks candles that push beyond the previous bar's extreme, then close back at the opposite end of their own range — a sweep followed by immediate rejection within a single bar.

A bullish signal requires the low to break below the previous low, a lower wick at least twice the body, and a close at or near the high. The bearish signal is the mirror image.

Three inputs let you adapt it to any instrument. Close tolerance sets how far the close may sit from the extreme, expressed in ticks — set it to 0 for an exact match, or raise it on instruments where a perfect close is rare. Max body/wick ratio controls how dominant the wick must be; lower values are stricter. Min body size filters out doji, whose near-zero body would otherwise satisfy the ratio test.

Note that tick-based inputs scale differently across instruments: 20 ticks is 2 pips on a 5-digit FX pair but a very different distance on indices or metals. Adjust after switching markets.

The script marks bar patterns only. It does not account for context, trend, or level confluence, and it is not a trading system on its own.

---

## Source Code

````pine
//@version=6
indicator("Pin bar + sweep poprzedniej świecy", overlay = true)

tol     = input.float(20, "Tolerancja close (ticki)", minval = 0) * syminfo.mintick
maxBody = input.float(0.5, "Maks. korpus / knot", minval = 0.05, step = 0.05)
minBody = input.float(1, "Min. korpus (ticki)", minval = 0) * syminfo.mintick

body      = math.abs(close - open)
wickLower = open - low
wickUpper = high - open

// byczy: zamknięcie przy maksimum, długi dolny knot, low pod poprzednim low
bull = math.abs(high - close) <= tol
   and body <= maxBody * wickLower
   and body >= minBody
   and low < low[1]

// niedźwiedzi: zamknięcie przy minimum, długi górny knot, high nad poprzednim high
bear = math.abs(close - low) <= tol
   and body <= maxBody * wickUpper
   and body >= minBody
   and high > high[1]

plotshape(bull, title = "Byczy pin", style = shape.triangleup,
          location = location.belowbar, color = color.lime, size = size.small)
plotshape(bear, title = "Niedźwiedzi pin", style = shape.triangledown,
          location = location.abovebar, color = color.red, size = size.small)

alertcondition(bull, "Byczy pin bar", "Pin bar z sweepem dołka")
alertcondition(bear, "Niedźwiedzi pin bar", "Pin bar ze sweepem szczytu")
````

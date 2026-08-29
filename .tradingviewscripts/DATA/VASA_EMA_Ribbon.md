<!-- tradingview-pine-id: PUB;04b7841fc5fe498fbabc2f7e7417e8a6 -->
<!-- tradingviewscripts-format: 1 -->
# VASA EMA Ribbon

Source: https://www.tradingview.com/script/RFEbunir-VASA-EMA-Ribbon-vF/

## Description

A ribbon of exponential moving averages that tells you two things instantly: which way the trend is pointing, and how much conviction is behind it. When the bands fan apart and stack cleanly, the trend is strong. When they squeeze together, momentum is fading — often right before a turn or a range.

What it does: • 2 to 8 stacked EMAs, spacing you control • Ribbon colours green in an uptrend, red in a downtrend • Highlights compression when the ribbon squeezes tight • Alerts on trend turn and on compression • Every EMA is calculated on closed values — non-repainting

How to use: trade with the ribbon, not against it. A wide, rising green ribbon is trend-continuation territory; pullbacks into the ribbon can be entries in that direction. When the ribbon compresses and the amber shade appears, tighten up — the trend is running out of fuel and chop is common. Widen the spacing for swing trading, tighten it for intraday.

Educational only — not financial advice. Trading involves substantial risk of loss.

---

## Source Code

````pine
//@version=6

// ============================================================================

//  VASA EMA Ribbon

//  A stack of EMAs that reads trend and momentum at a glance. When the ribbon

//  fans out and aligns, one side is in control; when it compresses, trend

//  conviction is fading and a turn or range may be near.

//

//  NON-REPAINTING: every EMA is calculated on closed values. The live bar

//  updates as it forms (as any moving average must), but confirmed history

//  does not change. No signals, no lookahead.

//  Educational only — not financial advice. Trading involves substantial risk.

// ============================================================================

indicator("VASA EMA Ribbon", "VASA Ribbon", overlay = true)

// ---------- Inputs ----------

grpA = "Ribbon"

src      = input.source(close, "Source", group = grpA)

baseLen  = input.int(8, "Base (fastest) length", minval = 1, group = grpA)

emaStep  = input.int(8, "Step between EMAs", minval = 1, group = grpA)

count    = input.int(6, "Number of EMAs (2-8)", minval = 2, maxval = 8, group = grpA)

grpB = "Style"

colUp    = input.color(#15803d, "Bull colour", group = grpB)

colDn    = input.color(#b91c1c, "Bear colour", group = grpB)

shadeComp = input.bool(true, "Shade compression", group = grpB)

compPct   = input.float(0.5, "Compression threshold (% of price)", minval = 0.01, step = 0.05, group = grpB)

// ---------- EMAs (fixed 8, shown up to `count`) ----------

len1 = baseLen

len2 = baseLen + emaStep

len3 = baseLen + emaStep * 2

len4 = baseLen + emaStep * 3

len5 = baseLen + emaStep * 4

len6 = baseLen + emaStep * 5

len7 = baseLen + emaStep * 6

len8 = baseLen + emaStep * 7

e1 = ta.ema(src, len1)

e2 = ta.ema(src, len2)

e3 = ta.ema(src, len3)

e4 = ta.ema(src, len4)

e5 = ta.ema(src, len5)

e6 = ta.ema(src, len6)

e7 = ta.ema(src, len7)

e8 = ta.ema(src, len8)

// Slowest active EMA depends on `count`.

slowLen = baseLen + emaStep * (count - 1)

eSlow   = ta.ema(src, slowLen)

trendUp = e1 > eSlow

ribCol  = trendUp ? colUp : colDn

// Compression: spread of ribbon relative to price.

spreadPct = close != 0 ? math.abs(e1 - eSlow) / close * 100.0 : na

compressed = not na(spreadPct) and spreadPct < compPct

// ---------- Plots (each EMA shown only if within `count`) ----------

plot(count >= 1 ? e1 : na, "EMA 1", color = ribCol)

plot(count >= 2 ? e2 : na, "EMA 2", color = ribCol)

plot(count >= 3 ? e3 : na, "EMA 3", color = ribCol)

plot(count >= 4 ? e4 : na, "EMA 4", color = ribCol)

plot(count >= 5 ? e5 : na, "EMA 5", color = ribCol)

plot(count >= 6 ? e6 : na, "EMA 6", color = ribCol)

plot(count >= 7 ? e7 : na, "EMA 7", color = ribCol)

plot(count >= 8 ? e8 : na, "EMA 8", color = ribCol)

// ---------- Ribbon fill + compression shade ----------

pFast = plot(e1, "Fast edge", color = na, display = display.none)

pSlow = plot(eSlow, "Slow edge", color = na, display = display.none)

fillCol = compressed and shadeComp ? color.new(#f59e0b, 80) : color.new(ribCol, 92)

fill(pFast, pSlow, color = fillCol, title = "Ribbon fill")

// ---------- Alerts (confirmed) ----------

turnedUp = trendUp and not trendUp[1]

turnedDn = not trendUp and trendUp[1]

alertcondition(turnedUp, "Ribbon turned UP",   "VASA Ribbon: ribbon turned up")

alertcondition(turnedDn, "Ribbon turned DOWN", "VASA Ribbon: ribbon turned down")

alertcondition(compressed and not compressed[1], "Ribbon compressed", "VASA Ribbon: ribbon compressed — trend losing conviction")
````

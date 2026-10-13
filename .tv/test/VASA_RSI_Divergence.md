<!-- tradingview-pine-id: PUB;c8c24892235f4de6a8774729face9da6 -->
<!-- tradingviewscripts-format: 1 -->
# VASA RSI + Divergence

Source: https://www.tradingview.com/script/0XvCvqer-VASA-RSI-Divergence-vF/

## Description

The Relative Strength Index with confirmed regular divergence — labelled only once it is valid, so the markers never appear and then vanish. A bullish divergence prints when price makes a lower low while RSI makes a higher low (selling with less force behind it); a bearish divergence is the mirror.

How it works: divergences compare two consecutive confirmed RSI pivots against price at those same pivots. A pivot only counts once the required number of candles have closed to its right, so a signal prints a few bars late but is never redrawn or removed afterward. Overbought, oversold, and midline guides are shown, and an optional line connects the two diverging pivots.

How to use: treat divergence as a warning that momentum is fading, not a standalone entry. It is strongest at the extremes (oversold for bullish, overbought for bearish) and when it lines up with a level from your other analysis. Wait for price to confirm — for example a break of a short-term high after a bullish divergence — rather than acting on the divergence alone.

Non-repainting: divergence is detected on confirmed pivots only. Set alerts to "Once Per Bar Close."

Educational only — not financial advice. Trading involves substantial risk of loss.

---

## Source Code

````pine
//@version=6

// ============================================================================

//  VASA RSI + Divergence

//  RSI momentum with honest, confirmed regular divergence. A bullish

//  divergence prints when price makes a lower low while RSI makes a higher

//  low (selling is losing steam); a bearish divergence is the mirror.

//

//  NON-REPAINTING: divergences are detected only on CONFIRMED pivots. A pivot

//  needs `Pivot right bars` closed candles to its right before it is valid, so

//  a label appears a few bars late but NEVER moves or disappears afterwards.

//  This is the opposite of realtime-pivot indicators that repaint.

//  Educational only — not financial advice. Trading involves substantial risk.

// ============================================================================

indicator("VASA RSI + Divergence", "VASA RSI+Div", overlay = false)

// ---------- Inputs ----------

grpR = "RSI"

srcR    = input.source(close, "Source", group = grpR)

lenR    = input.int(14, "RSI length", minval = 2, group = grpR)

obLevel = input.int(70, "Overbought", minval = 50, maxval = 100, group = grpR)

osLevel = input.int(30, "Oversold",   minval = 0,  maxval = 50,  group = grpR)

grpD = "Divergence (regular)"

lb   = input.int(5, "Pivot left bars",  minval = 1, group = grpD)

rb   = input.int(5, "Pivot right bars", minval = 1, group = grpD)

rngMax = input.int(60, "Max bars between pivots", minval = 5, group = grpD)

drawLn = input.bool(true, "Draw divergence line", group = grpD)

grpS = "Style"

colUp = input.color(#15803d, "Bullish", group = grpS)

colDn = input.color(#b91c1c, "Bearish", group = grpS)

// ---------- RSI ----------

r = ta.rsi(srcR, lenR)

hline(obLevel, "Overbought", color = color.new(#b91c1c, 55))

hline(osLevel, "Oversold",   color = color.new(#15803d, 55))

hline(50, "Midline", color = color.new(color.gray, 75))

plot(r, "RSI", color = #2563eb, linewidth = 2)

// ---------- Confirmed pivots on RSI (non-repainting) ----------

ph = ta.pivothigh(r, lb, rb)

pl = ta.pivotlow(r, lb, rb)

var float prevPLrsi   = na

var float prevPLprice = na

var int   prevPLbar   = na

var float prevPHrsi   = na

var float prevPHprice = na

var int   prevPHbar   = na

bullDiv = false

bearDiv = false

if not na(pl)

    plPrice = low[rb]

    plBar   = bar_index - rb

    if not na(prevPLrsi) and (plBar - prevPLbar) <= rngMax

        // regular bullish: price lower low, RSI higher low

        if plPrice < prevPLprice and pl > prevPLrsi

            bullDiv := true

            if drawLn

                line.new(prevPLbar, prevPLrsi, plBar, pl, color = colUp, width = 2)

    prevPLrsi   := pl

    prevPLprice := plPrice

    prevPLbar   := plBar

if not na(ph)

    phPrice = high[rb]

    phBar   = bar_index - rb

    if not na(prevPHrsi) and (phBar - prevPHbar) <= rngMax

        // regular bearish: price higher high, RSI lower high

        if phPrice > prevPHprice and ph < prevPHrsi

            bearDiv := true

            if drawLn

                line.new(prevPHbar, prevPHrsi, phBar, ph, color = colDn, width = 2)

    prevPHrsi   := ph

    prevPHprice := phPrice

    prevPHbar   := phBar

if bullDiv

    label.new(bar_index - rb, r[rb], "Bull", yloc = yloc.price, style = label.style_label_up,   color = colUp, textcolor = color.white, size = size.small)

if bearDiv

    label.new(bar_index - rb, r[rb], "Bear", yloc = yloc.price, style = label.style_label_down, color = colDn, textcolor = color.white, size = size.small)

// ---------- Alerts (fire on confirmed divergence only) ----------

alertcondition(bullDiv, "Bullish divergence", "VASA RSI+Div: confirmed regular BULLISH divergence")

alertcondition(bearDiv, "Bearish divergence", "VASA RSI+Div: confirmed regular BEARISH divergence")
````

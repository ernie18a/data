# Cumulative Volume Delta

- url: https://www.tradingview.com/script/RBT4yMfz-Cumulative-Volume-Delta/
- type: indicator
- pine_id: PUB;8366a3c0fa744e1cb82b7e16baa936ac
- version: 1.0

## Description

Cumulative Volume Delta (CVD)

OVERVIEW
This indicator approximates the net balance between buying and selling pressure and accumulates it through the session, so you can see whether buyers or sellers
are in control and spot momentum that disagrees with price (divergence).

HOW IT WORKS
- Per-bar delta is estimated two ways (selectable): "Range-based" splits each bar's volume by where price closed within its range (smoother), and "Bar direction" assigns the full bar volume by candle colour.
- The running total is the CVD line, which can reset each day (intraday session delta) or run continuously.
- Divergences are flagged when price makes a higher pivot high while CVD does not (bearish), or a lower pivot low while CVD does not (bullish).

WHAT YOU SEE
- A CVD line with a soft fill, coloured by direction, around a zero baseline.
- "Div" labels at qualifying pivots.
- A status box with the current CVD value and whether buyers or sellers lead.

HOW TO USE
- Rising CVD supports up-moves; falling CVD supports down-moves.
- If price pushes to new highs while CVD stalls or falls, the move may be weak - a caution for longs and a potential reversal context.
- Combine with your own levels and risk plan.

NOTES
- This is an approximation from standard OHLCV bars, not true tick-by-tick order flow. Results depend on a reliable volume feed (futures and liquid stocks work  best). For research and education only; not financial advice.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
//   CUMULATIVE VOLUME DELTA (CVD)
//   Approximates net buying vs selling pressure and accumulates it.
//   Divergence = price and CVD disagree → momentum is fading.
//   Note: approximation from bar data, not true tick order-flow.
// ════════════════════════════════════════════════════════════════════
indicator("Cumulative Volume Delta", overlay = false)

// ───────────────────────────── INPUTS ──────────────────────────────
gE = "Engine"
method = input.string("Range-based", "Delta Method", options = ["Range-based", "Bar direction"], group = gE, tooltip = "Range-based = uses close position in the bar (smoother). Bar direction = full volume by candle color.")
reset  = input.string("Daily", "Reset", options = ["Daily", "Never"], group = gE, tooltip = "Daily = intraday session CVD (resets each day).")

gD = "Divergence"
showDiv = input.bool(true, "Show Divergences", group = gD)
divPiv  = input.int(5, "Pivot Lookback", minval = 2, group = gD)

gS = "Style"
upCol   = input.color(#26a69a, "Up", group = gS)
dnCol   = input.color(#ef5350, "Down", group = gS)
showTbl = input.bool(true, "Show Status Box", group = gS)

// ───────────────────────────── DELTA ───────────────────────────────
rng = high - low
delta = method == "Range-based" ? (rng > 0 ? volume * (2 * close - high - low) / rng : 0.0) : (close > open ? volume : close < open ? -volume : 0.0)

tch = ta.change(time("D"))
isNew = na(tch) or tch != 0

var float cvd = 0.0
cvd := (reset == "Daily" and isNew) ? delta : cvd + delta
cvdUp = cvd >= cvd[1]

// ───────────────────────────── PLOT ────────────────────────────────
pZero = plot(0, "Zero", color = color.new(color.gray, 60), display = display.none)
pCvd  = plot(cvd, "CVD", color = cvdUp ? upCol : dnCol, linewidth = 2)
fill(pCvd, pZero, color = cvd >= 0 ? color.new(upCol, 85) : color.new(dnCol, 85))
hline(0, "", color = color.new(color.gray, 50))

// ───────────────────────────── DIVERGENCE ──────────────────────────
ph = ta.pivothigh(close, divPiv, divPiv)
pl = ta.pivotlow(close, divPiv, divPiv)

var float lastPH = na, var float lastPHc = na
var float lastPL = na, var float lastPLc = na

if showDiv and not na(ph)
    cAt = cvd[divPiv]
    if not na(lastPH) and ph > lastPH and cAt < lastPHc
        label.new(bar_index - divPiv, cAt, "Div", style = label.style_label_down, color = color.new(dnCol, 0), textcolor = color.white, size = size.tiny)
    lastPH := ph
    lastPHc := cAt

if showDiv and not na(pl)
    cAt = cvd[divPiv]
    if not na(lastPL) and pl < lastPL and cAt > lastPLc
        label.new(bar_index - divPiv, cAt, "Div", style = label.style_label_up, color = color.new(upCol, 0), textcolor = color.white, size = size.tiny)
    lastPL := pl
    lastPLc := cAt

// ───────────────────────────── STATUS BOX ──────────────────────────
var table tb = table.new(position.top_right, 2, 2, border_width = 1)
if showTbl and barstate.islast
    table.cell(tb, 0, 0, "CVD", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tb, 1, 0, str.tostring(cvd, format.volume), text_color = color.white, bgcolor = color.new(cvd >= 0 ? upCol : dnCol, 10), text_size = size.small)
    table.cell(tb, 0, 1, "Pressure", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tb, 1, 1, cvdUp ? "▲ Buyers" : "▼ Sellers", text_color = color.white, bgcolor = color.new(cvdUp ? upCol : dnCol, 10), text_size = size.small)

// ───────────────────────────── ALERTS ──────────────────────────────
alertcondition(ta.crossunder(cvd, 0), "CVD turned negative", "CVD flipped negative — sellers in control {{ticker}}")
alertcondition(ta.crossover(cvd, 0),  "CVD turned positive", "CVD flipped positive — buyers in control {{ticker}}")
````

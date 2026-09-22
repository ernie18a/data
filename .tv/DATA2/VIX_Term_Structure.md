<!-- tradingview-pine-id: PUB;79f634d7691f4924998361104305c87a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VIX Term Structure

Source: https://www.tradingview.com/script/3BQ5rtnq-VIX-Term-Structure/

## Description

VIX at 14 does not tell you whether volatility is cheap. The curve does.
A single VIX print is one number on one horizon. What actually tells you something is the shape across horizons: whether the market is asking more for protection next week than for protection in three months, or less. That shape is where the information is, and it is free public data that almost nobody puts on a chart.

This plots the four CBOE volatility indices as a curve you can read at a glance -- 9-day, 30-day, 3-month and 6-month -- and reduces it to the one ratio that matters, 30-day over 3-month.
Below 1, the curve is in contango. Near-dated volatility is cheaper than deferred, which is the normal state and roughly two thirds of all trading days. The lower the ratio, the steeper the curve, and the calmer the market thinks the next month will be relative to the next quarter.
Above 1, the curve is inverted, or in backwardation. Near-dated volatility is bid over deferred, which means the market is paying up for protection it needs soon rather than eventually. That is a stress reading and it does not persist for long.

The dashboard shows each tenor, both ratios, and a plain verdict: STEEP CONTANGO, CONTANGO, or BACKWARDATION. The 9-day over 30-day ratio sits alongside it as the very front of the curve, which moves first and moves hardest.

What the shape is actually telling an option seller. A rich premium reading and a steep contango curve are the same market saying two things that agree: insurance is expensive relative to what has happened, and the market does not expect that to change soon. A rich premium reading against an inverted curve is a different animal. The premium is rich because something is coming, and selling into it is selling insurance to somebody who knows they need it. The IV-minus-RV gap looks identical in both cases. The curve is what separates them.

There is a trap on the other side too, and it is the more common one. The urge to sell premium is strongest when the tape is calm, and a calm tape is exactly what a steep contango curve looks like from the inside. Steep contango means the front is cheap, and cheap is the least you will ever be paid to take the risk. The moment selling feels safest is the moment it pays least.
Pairing. This answers a question my other two volatility scripts do not. Vol Premium Gauge answers whether you are paid, by comparing implied against realized. Expected Move Bands answers which strike, by drawing the one-standard-deviation range. Term structure answers whether the premium is there for a good reason or a bad one. Paid, why, where -- three different questions, three different reads.

Scope. Equity indices only. There is no term structure for crypto volatility, because DVOL publishes a single tenor rather than a curve, so unlike the other two this script does not auto-detect crypto. On a crypto chart the dashboard will read NO CURVE, which is honest rather than broken.

Alerts fire on the flip in each direction: into backwardation, and back into contango.
The thresholds are inputs, defaulting to 0.90 for steep and 1.00 for the inversion. The symbols are inputs too, so if CBOE changes a ticker the script keeps working.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IvanLabrie

//@version=6
indicator("VIX Term Structure", "VIX Term", overlay = false, precision = 2)

// ─────────────────────────────────────────────────────────────────────────────
// DRAFT — NOT COMPILED. Ivan finalizes.
// 🔴 VERIFY-POINT 1: the four CBOE ticker strings below. Each is requested with
//    ignore_invalid_symbol=true, so a WRONG SYMBOL FAILS SILENTLY as na rather
//    than erroring — the same class of trap as the "Legacy (Combined)" COTType
//    that returned no data on the COT script. Put each on a chart once and
//    confirm it prints before publishing.
// 🔴 VERIFY-POINT 2: VIX3M was VXV and VIX6M was VXMT. If the modern strings do
//    not resolve, the fallbacks are in the inputs so they can be swapped without
//    touching logic.
// ─────────────────────────────────────────────────────────────────────────────

grpS = "Symbols"
symFront = input.symbol("CBOE:VIX9D", "9-day  (front)",  group = grpS)
symSpot  = input.symbol("CBOE:VIX",   "30-day (spot)",   group = grpS)
sym3M    = input.symbol("CBOE:VIX3M", "3-month",         group = grpS)
sym6M    = input.symbol("CBOE:VIX6M", "6-month",         group = grpS)

grpC = "Curve"
rankLen  = input.int(252, "Rank lookback (bars)", minval = 20, group = grpC)
steepThr = input.float(0.90, "Steep-contango threshold (30d / 3m)", step = 0.01, group = grpC,
     tooltip = "Below this, the front is cheap relative to 3 month. Default 0.90.")
flatThr  = input.float(1.00, "Backwardation threshold (30d / 3m)", step = 0.01, group = grpC)
showTbl  = input.bool(true, "Show dashboard", group = grpC)

f_get(sym) => request.security(sym, "D", close, ignore_invalid_symbol = true)

v9  = f_get(symFront)
v30 = f_get(symSpot)
v3m = f_get(sym3M)
v6m = f_get(sym6M)

haveCurve = not na(v30) and not na(v3m)

// The classic gauge. < 1 = contango (front cheaper than deferred, the normal
// state). > 1 = backwardation (front bid over deferred, the stress state).
ratio   = haveCurve ? v30 / v3m : na
ratioFr = not na(v9) and not na(v30) ? v9 / v30 : na

// Where does today's curve sit against its own last year, not against a fixed 1.00.
// ta.percentrank must be called on EVERY bar to keep its internal state, so it is hoisted
// out of the conditional and the guard is applied to the result instead.
rankRaw = ta.percentrank(ratio, rankLen)
rank    = haveCurve and bar_index > rankLen ? rankRaw : na

state = not haveCurve ? "NO CURVE" :
     ratio >= flatThr  ? "BACKWARDATION" :
     ratio >= steepThr ? "CONTANGO" : "STEEP CONTANGO"

cCon  = color.new(color.teal, 0)
cBack = color.new(color.maroon, 0)
cCurve = state == "BACKWARDATION" ? cBack : cCon

plot(ratio,   "30d / 3m",  color = cCurve, linewidth = 2)
plot(ratioFr, "9d / 30d",  color = color.new(color.gray, 65), linewidth = 1)
hline(1.0,  "Flat",  color = color.new(color.gray, 50), linestyle = hline.style_dashed)
hline(steepThr, "Steep", color = color.new(color.gray, 70), linestyle = hline.style_dotted)

// ── dashboard ────────────────────────────────────────────────────────────────
// Styled to match Expected Move Bands and Vol Premium Gauge, since the three publish
// as a set and an unstyled table reads as unfinished next to them. Text uses
// chart.fg_color so it stays legible on both the light and the dark theme -- the
// first draft used gray-on-transparent and the values washed out to invisible.
cHdrTxt = color.new(color.white, 0)
cLbl    = color.new(chart.fg_color, 35)
cVal    = color.new(chart.fg_color, 0)
cBg     = color.new(chart.bg_color, 10)

var table tbl = table.new(position.top_right, 2, 8, border_width = 1,
     frame_color = color.new(chart.fg_color, 70), frame_width = 1,
     border_color = color.new(chart.fg_color, 80))

f_row(r, k, v, col) =>
    table.cell(tbl, 0, r, k, text_color = cLbl, text_size = size.small,
         text_halign = text.align_left,  bgcolor = cBg)
    table.cell(tbl, 1, r, v, text_color = col, text_size = size.small,
         text_halign = text.align_right, bgcolor = cBg)

if showTbl and barstate.islast
    // header carries the verdict, the way the other two carry theirs
    table.cell(tbl, 0, 0, "VIX TERM STRUCTURE", text_color = cHdrTxt,
         text_size = size.small, text_halign = text.align_left,  bgcolor = cCurve)
    table.cell(tbl, 1, 0, state, text_color = cHdrTxt,
         text_size = size.small, text_halign = text.align_right, bgcolor = cCurve)
    f_row(1, "9-day",   na(v9)  ? "n/a" : str.tostring(v9,  "#.##"), cVal)
    f_row(2, "30-day",  na(v30) ? "n/a" : str.tostring(v30, "#.##"), cVal)
    f_row(3, "3-month", na(v3m) ? "n/a" : str.tostring(v3m, "#.##"), cVal)
    f_row(4, "6-month", na(v6m) ? "n/a" : str.tostring(v6m, "#.##"), cVal)
    f_row(5, "30d / 3m", na(ratio)   ? "n/a" : str.tostring(ratio,   "#.###"), cCurve)
    f_row(6, "9d / 30d", na(ratioFr) ? "n/a" : str.tostring(ratioFr, "#.###"), cVal)
    f_row(7, "Ratio %ile (1y)", na(rank) ? "n/a" : str.tostring(rank, "#") + "%", cVal)

// ── alerts ───────────────────────────────────────────────────────────────────
flipToBack = haveCurve and ratio >= flatThr and ratio[1] < flatThr
flipToCon  = haveCurve and ratio <  flatThr and ratio[1] >= flatThr

alertcondition(flipToBack, "Curve inverted (backwardation)",
     "VIX term structure flipped into backwardation: front vol bid over 3 month.")
alertcondition(flipToCon, "Curve back into contango",
     "VIX term structure returned to contango: front vol back below 3 month.")
````

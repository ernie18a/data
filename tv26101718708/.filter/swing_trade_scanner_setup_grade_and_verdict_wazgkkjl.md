# Swing Trade Scanner     Setup Grade and Verdict

- url: https://www.tradingview.com/script/WAZgKKJl-Swing-Trade-Scanner-Setup-Grade-and-Verdict/
- type: indicator
- pine_id: PUB;d853137af5ae42e99a22ab2e8bafb7b5
- version: 4.0

## Description

[b]Grades the stock on your chart as a long swing setup — a 0–100 score, an A+ to D grade, and a plain-English verdict.[/b]


You've found a stock. Is it actually a setup? Swing Trade Scanner grades the chart in front of you the way a swing trader reads it — trend, momentum, relative strength, volume — and gives you one honest answer: a score, a grade, and a verdict in plain English.

It works on its own — nothing else required.

[b]Why one score instead of five separate indicators?[/b]

Every check in this script exists on its own — but alone, each one whipsaws. What makes a swing setup is confluence: trend, momentum, proximity to highs, relative strength, and volume confirming each other at the same time. 
The Scanner's contribution is the weighting and the interaction between the checks: MA alignment counts most because trend is what pays swing traders, and the extension penalty can override an otherwise perfect score — because the same chart that grades well near the fast MA is a bad entry 8% above it. That interaction is what a stack of separate indicators won't show you.

[b]What goes into the score (0–100)[/b]

Five checks, each weighted by how much it matters:

[list]
[*] [b]MA alignment[/b] (up to 35 pts) — is price stacked cleanly above the 4-MA ribbon? A full bull stack (price > fast MA > each slower MA) earns full points.
[*] [b]Momentum[/b] (up to 20) — how far price has moved over the lookback (60 bars by default).
[*] [b] Distance from the recent high[/b] (up to 20) — leaders sit near their highs; a stock 10% below its high has repair work to do first.
[*] [b]Relative strength vs SPY[/b] (up to 15) — is the stock beating the market (SPY = S&P 500 ETF), not just rising with it?
[*] [b]Volume[/b] (up to 10) — is it trading above its 20-day average?
[*]
[/list]
Then one guardrail: the [b]extension penalty[/b]. More than 6% above the fast MA and the score gets docked (−12 points, −20 past 10%). Chasing a stretched chart is how good setups become bad entries — the Scanner won't grade one highly.

[b]The verdict reads in plain English[/b] 

[list]
[*] [b]HIGH QUALITY[/b] (score 75+) — everything lined up.
[*] [b]MODERATE[/b] (55–74) — decent, not complete.
[*] [b]WEAK[/b] (40–54) — most of the checklist is missing.
[*] [b]AVOID[/b] (under 40) — not a long setup right now.
[*] [b]EXTENDED / WAIT[/b] — the setup grades well BUT price is stretched more than 6% above the fast MA. Good stock, bad moment. Let it pull in.
[/list]

[b]What you see on the chart[/b]

[list]
[*] [b]The 4-MA ribbon[/b] — four moving averages (EMA 20 / 50 / 100 / 200 by default; EMA, SMA or WMA), with the zone between the two fastest shaded green in an uptrend, red in a downtrend.
[*] [b]Candle coloring[/b] (optional) — green in a full bull stack, teal in a partial one, red in a full bear stack, so the trend state reads at a glance.
[*] [b] The dashboard[/b] — grade + score up top, then the four core metrics (MA Alignment, 60-bar Momentum, RS vs SPY, Volume Ratio) and the Verdict row.
[/list]

[b]Long setups only[/b]

This tool grades the long (buy) side. On a downtrending chart it won't invent an opportunity — it shows Full Bear and AVOID and tells you to look elsewhere.

[b]Settings — defaults work out of the box[/b]

[list]
[*] MA ribbon — four lengths, MA type, and colors.
[*] Lookback (60 bars) — the window for momentum, relative strength, and the recent high.
[*] Volume MA length (20).
[*] Table position, text size, dark/light theme, and status colors.
[*]
[/list]

⚠ Educational tool for reading and grading charts. The grade measures how complete a setup is by these rules — it does not generate buy/sell signals or predict price. Not financial advice.

## Source Code

````pine
//@version=6
// Swing Trade Scanner — a 4-MA ribbon plus a 0-100 setup score, letter grade and plain-English verdict.
// Long side only: it grades how complete a long swing setup is on the chart in front of you.
// Five weighted checks (MA alignment, momentum, distance from the recent high, RS vs SPY, volume),
// with an extension penalty so a stretched chart can't grade well.
//
// 2026-08-12 — display fix. Momentum %, RS vs SPY % and Volume Ratio were formatted
// with "#.1" / "#.2". Only # and 0 are digit placeholders in a Pine format string, so
// the digit after the decimal was printed literally and the value was rounded to a
// whole number: 5.86% displayed as "6.1%", and every volume ratio read "1.2x avg".
// The underlying calculations were always correct — only the printed text was wrong.
// 2026-08-12b — republished to restore the listing's cover chart. No code change.
// 2026-08-29 — verdict fix. "EXTENDED / WAIT" was gated on the score AFTER the extension
// penalty was applied, so the penalty pushed the total under the threshold the warning needed
// and the warning disappeared: a chart 23.9% above its fast MA reported "WEAK" with no mention
// of extension. The verdict now tests the setup score BEFORE the penalty. Scores, grades and
// the penalty itself are unchanged — only the verdict wording is affected.
indicator("Swing Trade Scanner — Setup Grade & Verdict", shorttitle="STS", overlay=true)

// ══════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════
g_ma      = "MA Ribbon"
ma1_len   = input.int(20,  "Fast MA",   minval=1, group=g_ma)
ma2_len   = input.int(50,  "MA 2",      minval=1, group=g_ma)
ma3_len   = input.int(100, "MA 3",      minval=1, group=g_ma)
ma4_len   = input.int(200, "Slow MA",   minval=1, group=g_ma)
ma_type   = input.string("EMA", "Type", options=["EMA","SMA","WMA"], group=g_ma)
ma1_col   = input.color(#ffb74d, "Fast MA color", group=g_ma)
ma2_col   = input.color(#4789d1, "MA 2 color",    group=g_ma)
ma3_col   = input.color(#ef5350, "MA 3 color",    group=g_ma)
ma4_col   = input.color(#b0bec5, "Slow MA color", group=g_ma)

g_scr    = "Screening"
lookback = input.int(60, "Lookback Bars",    minval=5, group=g_scr)
vol_len  = input.int(20, "Volume MA Length", minval=5, group=g_scr)

g_disp     = "Display"
show_table = input.bool(true, "Show Table",    group=g_disp)
show_color = input.bool(true, "Color Candles", group=g_disp)
tablePos   = input.string("Top Right", "Table position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=g_disp)
tableSize  = input.string("Small", "Table text size", options=["Tiny","Small","Normal","Large"], group=g_disp)

g_theme  = "Theme & Colors"
darkMode = input.bool(true, "Dark theme (uncheck for light charts)", group=g_theme)
colGood  = input.color(#089981, "Strong",   group=g_theme, inline="c1")
colMid   = input.color(#f5c84b, "Moderate", group=g_theme, inline="c1")
colWarn  = input.color(#ff9800, "Caution",  group=g_theme, inline="c1")
colBad   = input.color(#f23645, "Weak",     group=g_theme, inline="c1")

// Table chrome: navy #0a1527 · gold #c0a571
c_navy   = #0a1527
c_gold   = #c0a571
c_bodyBg = darkMode ? color.new(#0e1a2f, 6) : color.new(#ffffff, 4)
c_lbl    = darkMode ? #9aa4b2 : #5b6470
c_txt    = darkMode ? #e8e8ec : #0a1527
c_grid   = darkMode ? color.new(#2a3950, 0) : color.new(#d0d4dc, 0)

// ══════════════════════════════════════════════════════════════
// MA RIBBON
// ══════════════════════════════════════════════════════════════
f_ma(src, len, t) =>
    switch t
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        =>       ta.ema(src, len)

ma1 = f_ma(close, ma1_len, ma_type)
ma2 = f_ma(close, ma2_len, ma_type)
ma3 = f_ma(close, ma3_len, ma_type)
ma4 = f_ma(close, ma4_len, ma_type)

p1 = plot(ma1, "MA1 Fast", color=ma1_col, linewidth=1)
p2 = plot(ma2, "MA2",      color=ma2_col, linewidth=1)
p3 = plot(ma3, "MA3",      color=ma3_col, linewidth=2)
p4 = plot(ma4, "MA4 Slow", color=ma4_col, linewidth=2)
fill(p1, p2, color=ma1 > ma2 ? color.new(colGood, 88) : color.new(colBad, 88))

// ══════════════════════════════════════════════════════════════
// SCREENING METRICS (Long)
// ══════════════════════════════════════════════════════════════
bull_full    = close > ma1 and ma1 > ma2 and ma2 > ma3 and ma3 > ma4
bull_partial = close > ma1 and ma1 > ma2 and ma2 > ma3
bear_full    = close < ma1 and ma1 < ma2 and ma2 < ma3 and ma3 < ma4

momentum_pct  = (close - close[lookback]) / close[lookback] * 100
high_lb       = ta.highest(high, lookback)
pct_from_high = high_lb > 0 ? (high_lb - close) / high_lb * 100 : 0.0
vol_avg       = ta.sma(volume, vol_len)
vol_ratio     = vol_avg > 0 ? volume / vol_avg : 1.0

spy_c  = request.security("SPY", timeframe.period, close)
spy_lb = request.security("SPY", timeframe.period, close[lookback])
spy_m  = spy_lb > 0 ? (spy_c - spy_lb) / spy_lb * 100 : 0.0
rs_spy = momentum_pct - spy_m

ext_pct = ma1 > 0 ? (close - ma1) / ma1 * 100 : 0.0

// ══════════════════════════════════════════════════════════════
// COMPOSITE SCORE (0-100)
// ══════════════════════════════════════════════════════════════
// Each check is weighted by how much it matters to a swing entry: trend alignment carries the
// most weight, volume the least. Confluence is the point — one check passing means little.
ma_score    = bull_full ? 35.0 : bull_partial ? 18.0 : 0.0
mom_score   = momentum_pct > 30 ? 20.0 : momentum_pct > 20 ? 16.0 : momentum_pct > 10 ? 10.0 : momentum_pct > 5 ? 5.0 : 0.0
high_score  = pct_from_high <= 1.0 ? 20.0 : pct_from_high <= 3.0 ? 15.0 : pct_from_high <= 5.0 ? 10.0 : pct_from_high <= 10.0 ? 4.0 : 0.0
vol_score   = vol_ratio >= 2.0 ? 10.0 : vol_ratio >= 1.5 ? 7.0 : vol_ratio >= 1.0 ? 3.0 : 0.0
rs_score    = rs_spy > 15.0 ? 15.0 : rs_spy > 5.0 ? 10.0 : rs_spy > 0.0 ? 5.0 : 0.0
// Extension guardrail: >6% above the fast MA is the blow-off zone — penalized, and the penalty
// can override an otherwise complete setup. The same chart is a bad entry once it's stretched.
ext_penalty = ext_pct > 10 ? -20.0 : ext_pct > 6 ? -12.0 : 0.0
// base_score is the setup BEFORE the extension penalty. The verdict tests against this, not
// against the final score — see the Verdict block below for why.
base_score  = ma_score + mom_score + high_score + vol_score + rs_score
score       = base_score + ext_penalty

score_r = math.round(score)
grade   = score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B+" : score >= 55 ? "B" : score >= 40 ? "C" : "D"
s_col   = score >= 75 ? colGood : score >= 55 ? colMid : score >= 40 ? colWarn : colBad
s_bg    = color.new(s_col, 25)

// Verdict — the plain-English read of the grade (Extended guard included)
// The "EXTENDED / WAIT" test uses base_score, NOT score. Gating it on the final score meant the
// extension penalty pushed the total under 55 and so suppressed the very warning that penalty
// existed to raise — the more stretched the chart, the more likely it read "WEAK" with no reason
// given. base_score keeps the original intent (only say "good stock, bad moment" when the setup
// really is good) without letting the penalty silence itself.
is_extended = ext_pct > 6
verdict = is_extended and base_score >= 55 ? "EXTENDED / WAIT" : score >= 75 ? "HIGH QUALITY" : score >= 55 ? "MODERATE" : score >= 40 ? "WEAK" : "AVOID"
v_col   = is_extended and base_score >= 55 ? colWarn : score >= 75 ? colGood : score >= 55 ? colMid : score >= 40 ? colWarn : colBad

// ══════════════════════════════════════════════════════════════
// CANDLE COLOR
// ══════════════════════════════════════════════════════════════
barcolor(show_color ? (bull_full ? color.new(colGood, 55) : bull_partial ? color.new(color.teal, 65) : bear_full ? color.new(colBad, 55) : na) : na)

// ══════════════════════════════════════════════════════════════
// INFO TABLE  (grade + four core grading metrics + verdict)
// ══════════════════════════════════════════════════════════════
tblPos = switch tablePos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    =>                 position.bottom_right
tsz = switch tableSize
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    =>         size.normal

var table tbl = na

if barstate.islast and show_table
    table.delete(tbl)
    tbl := table.new(tblPos, 2, 6, bgcolor=c_bodyBg, border_color=c_grid, border_width=1, frame_color=c_gold, frame_width=1)
    table.cell(tbl, 0, 0, "SWING SCANNER", text_color=c_gold, bgcolor=c_navy, text_size=tsz, text_halign=text.align_left)
    table.cell(tbl, 1, 0, grade + "  " + str.tostring(score_r) + "/100", text_color=color.white, bgcolor=s_bg, text_size=tsz, text_halign=text.align_center)
    ma_txt = bull_full ? "Full Bull Stack" : bull_partial ? "Partial Bull" : bear_full ? "Full Bear" : "Mixed"
    ma_col = bull_full ? colGood : bull_partial ? colMid : colBad
    table.cell(tbl, 0, 1, "MA Alignment", text_color=c_lbl, text_size=tsz, text_halign=text.align_left)
    table.cell(tbl, 1, 1, ma_txt, text_color=ma_col, text_size=tsz, text_halign=text.align_right)
    mom_col = momentum_pct > 15 ? colGood : momentum_pct > 5 ? colMid : colBad
    table.cell(tbl, 0, 2, str.tostring(lookback) + "d Momentum", text_color=c_lbl, text_size=tsz, text_halign=text.align_left)
    table.cell(tbl, 1, 2, (momentum_pct >= 0 ? "+" : "") + str.tostring(momentum_pct, "0.0") + "%", text_color=mom_col, text_size=tsz, text_halign=text.align_right)
    rs_col = rs_spy > 10 ? colGood : rs_spy > 0 ? colMid : colBad
    table.cell(tbl, 0, 3, "RS vs SPY", text_color=c_lbl, text_size=tsz, text_halign=text.align_left)
    table.cell(tbl, 1, 3, (rs_spy >= 0 ? "+" : "") + str.tostring(rs_spy, "0.0") + "%", text_color=rs_col, text_size=tsz, text_halign=text.align_right)
    vol_col = vol_ratio >= 1.5 ? colGood : vol_ratio >= 0.8 ? colMid : colBad
    table.cell(tbl, 0, 4, "Volume Ratio", text_color=c_lbl, text_size=tsz, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(vol_ratio, "0.00") + "x avg", text_color=vol_col, text_size=tsz, text_halign=text.align_right)
    table.cell(tbl, 0, 5, "Verdict", text_color=c_lbl, text_size=tsz, text_halign=text.align_left)
    table.cell(tbl, 1, 5, verdict, text_color=v_col, text_size=tsz, text_halign=text.align_right)
````

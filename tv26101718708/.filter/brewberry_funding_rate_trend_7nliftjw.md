# Brewberry Funding Rate Trend

- url: https://www.tradingview.com/script/7nlIFtjW-Brewberry-Funding-Rate-Trend/
- type: indicator
- pine_id: PUB;50f1ea65df98471baa5c96f269eb5ef7
- version: 1.0

## Description

What it shows:
Histogram bars — the raw funding rate per 8-hour interval. Color-coded: bright red above 0.05%, orange above 0.03%, faded green for mild positive, blue for negative. The visual weight makes the current regime immediately obvious.
Yellow line (7-day MA) — this is the important one. The course says repeatedly that a single reading means nothing — it's the trend over 3-7+ days that tells you whether the structure is fragile. This line is that trend.
Purple line (21-day MA) — structural trend. Where the 7-day is above the 21-day and both are elevated, you're in a sustained crowding regime.
Background shading — red tint when 7-day MA crosses above 0.03% (danger zone), deeper red above 0.05% (extreme zone), blue tint when MA goes negative.
Threshold lines — dashed horizontal lines at 0.01%, 0.03%, and 0.05% per 8h with labels showing the annualized equivalent (10.95%, 32.85%, 54.75%).
Cumulative cost box — sums the actual funding paid over your lookback window. Shows the real dollar drain on a long position over the period.
Top-right table — current rate, annualized rate, 7-day avg APR, 21-day avg APR, cumulative cost. All in one glance.
Four built-in alerts — 7d MA enters danger zone, exits danger zone, hits extreme zone, and crosses below zero (short squeeze setup building).
To use on different assets: Change the Asset input from BTCUSDT to ETHUSDT, SOLUSDT, etc.

## Source Code

````pine
//@version=5
indicator("Brewberry Funding Rate Trend", shorttitle="BB Funding", overlay=false, max_bars_back=500)

// Try the direct ticker first - this is the confirmed working format
fr_raw = request.security("BINANCE:BTCUSDTPERP_FUNDINGRATE", "480", close, ignore_invalid_symbol=true)

// Fallback: some TV accounts need the premium index instead
premium = request.security("BINANCE:BTCUSDTPERP", "480", close - open, ignore_invalid_symbol=true)

// Use whichever has data
fr = not na(fr_raw) and fr_raw != 0 ? fr_raw : na(premium) ? 0.0 : premium * 0.001

ma1     = ta.sma(fr, 21)
ma2     = ta.sma(fr, 63)
fr_ann  = fr  * 3 * 365
ma1_ann = ma1 * 3 * 365
ma2_ann = ma2 * 3 * 365
cum     = math.sum(fr, 63)

bar_col = fr >= 0.05 ? color.new(#ef4444, 0) : fr >= 0.03 ? color.new(#f97316, 0) : fr >= 0 ? color.new(#22c55e, 50) : color.new(#3b82f6, 40)

bgcolor(ma1 >= 0.05 ? color.new(#ef4444, 85) : na, title="Extreme Zone")
bgcolor(ma1 >= 0.03 and ma1 < 0.05 ? color.new(#ef4444, 93) : na, title="Danger Zone")
bgcolor(ma1 <= -0.01 ? color.new(#3b82f6, 93) : na, title="Negative Zone")

hline(0,     "Zero",       color=color.new(#555555, 0), linewidth=1)
hline(0.01,  "10.95% APR", color=color.new(#22c55e, 50), linestyle=hline.style_dashed, linewidth=1)
hline(0.03,  "32.85% APR", color=color.new(#f97316, 50), linestyle=hline.style_dashed, linewidth=1)
hline(0.05,  "54.75% APR", color=color.new(#ef4444, 50), linestyle=hline.style_dashed, linewidth=1)
hline(-0.01, "-10.95% APR",color=color.new(#3b82f6, 50), linestyle=hline.style_dashed, linewidth=1)

plot(fr,  "Funding Rate (8h)", style=plot.style_histogram, color=bar_col, linewidth=2)
plot(ma1, "7-Day MA",          color=color.new(#fbbf24, 0), linewidth=2)
plot(ma2, "21-Day MA",         color=color.new(#a855f7, 0), linewidth=1)
plot(cum,  "Cumulative Cost",  color=color.new(#06b6d4, 60), linewidth=1, style=plot.style_area)

if barstate.islast
    lbl_col = ma1 >= 0.05 ? color.new(#ef4444, 70) : ma1 >= 0.03 ? color.new(#f97316, 70) : ma1 < 0 ? color.new(#3b82f6, 70) : color.new(#22c55e, 70)
    label.new(bar_index, fr, "Rate: " + str.tostring(math.round(fr_ann, 2)) + "% APR\n7d MA: " + str.tostring(math.round(ma1_ann, 2)) + "% APR", color=lbl_col, textcolor=color.white, style=label.style_label_left, size=size.small)

if barstate.islast
    tbl = table.new(position.top_right, 2, 6, bgcolor=color.new(#0a0a0a, 5), border_color=color.new(#333333, 0), border_width=1, frame_color=color.new(#333333, 0), frame_width=1)
    table.cell(tbl, 0, 0, "BB FUNDING",    text_color=color.new(#fbbf24, 0), text_size=size.small, bgcolor=color.new(#111111, 0))
    table.cell(tbl, 1, 0, "BINANCE:BTC",   text_color=color.new(#fbbf24, 0), text_size=size.small, bgcolor=color.new(#111111, 0))
    rc  = fr  >= 0.05 ? #ef4444 : fr  >= 0.03 ? #f97316 : fr  >= 0 ? #22c55e : #3b82f6
    mc1 = ma1 >= 0.05 ? #ef4444 : ma1 >= 0.03 ? #f97316 : ma1 >= 0 ? #fbbf24 : #3b82f6
    mc2 = ma2 >= 0.05 ? #ef4444 : ma2 >= 0.03 ? #f97316 : ma2 >= 0 ? #a855f7 : #3b82f6
    cc  = cum > 0 ? #ef4444 : #3b82f6
    table.cell(tbl, 0, 1, "Current 8h",  text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(math.round(fr * 100, 4)) + "%",     text_color=color.new(rc,  0), text_size=size.small)
    table.cell(tbl, 0, 2, "Annualized",  text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(math.round(fr_ann,   2)) + "% APR", text_color=color.new(rc,  0), text_size=size.small)
    table.cell(tbl, 0, 3, "7-Day Avg",   text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(math.round(ma1_ann,  2)) + "% APR", text_color=color.new(mc1, 0), text_size=size.small)
    table.cell(tbl, 0, 4, "21-Day Avg",  text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(math.round(ma2_ann,  2)) + "% APR", text_color=color.new(mc2, 0), text_size=size.small)
    table.cell(tbl, 0, 5, "Cum Cost",    text_color=color.new(#888888, 0), text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(math.round(cum * 100, 4)) + "%",    text_color=color.new(cc,  0), text_size=size.small)

alertcondition(ta.crossover(ma1,  0.03), "Funding — Danger Zone",    "7d MA above 0.03%. Structure fragile.")
alertcondition(ta.crossunder(ma1, 0.03), "Funding — Exiting Danger", "7d MA dropped below 0.03%.")
alertcondition(ta.crossover(ma1,  0.05), "Funding — EXTREME",        "7d MA above 0.05%. Cascade risk elevated.")
alertcondition(ta.crossunder(ma1,  0),   "Funding — Gone Negative",  "7d MA below zero. Squeeze setup building.")
````

# JP Gap-Up Scanner v2

- url: https://www.tradingview.com/script/NbS1mnvg-JP-Gap-Up-Scanner-v2/
- type: indicator
- pine_id: PUB;1fdc93a309f84e6aa99d34d2efee6617
- version: 1.0

## Description

trying out signal of opening gap up for the next day
getting a help from claude to craft the strategy and scanner

## Source Code

````pine
//@version=5
indicator("JP Gap-Up Scanner v2", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════
rvol_thresh   = input.float(1.8,  "Min Relative Volume",     step=0.1)
rsi_low       = input.int(55,     "RSI Min")
rsi_high      = input.int(78,     "RSI Max")
near_high_pct = input.float(0.15, "Near Day High (top %)",   step=0.05)
score_thresh  = input.int(4,      "Min Score to Alert",      minval=1, maxval=6)

// ═══════════════════════════════════════════
// TIME GATE — Tokyo timezone explicit
// Only scan 13:30–14:45 JST
// ═══════════════════════════════════════════
tokyo_hour   = hour(time,   "Asia/Tokyo")
tokyo_minute = minute(time, "Asia/Tokyo")

in_window = (tokyo_hour == 13 and tokyo_minute >= 30) or (tokyo_hour == 14 and tokyo_minute <= 45)

// ═══════════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════════

// S1 — Relative Volume
avg_vol = ta.sma(volume, 20)
rvol    = avg_vol > 0 ? volume / avg_vol : 0.0

// S2 — RSI
rsi = ta.rsi(close, 14)

// S3 — Price vs VWAP
vwap_val = ta.vwap(hlc3)

// S4 — Price near day high (top 15% of today's range)
day_high  = ta.highest(high,  390)  // 390 mins = full TSE session on 1min
day_low   = ta.lowest(low,    390)
day_range = day_high - day_low
near_high = day_range > 0 ? (close - day_low) / day_range >= (1.0 - near_high_pct) : false

// S5 — Bullish candle (close > open)
bull_candle = close > open

// S6 — Price rising last 3 bars
rising = close > close[3]

// ═══════════════════════════════════════════
// SCORE — each condition = 1 point
// ═══════════════════════════════════════════
s1 = rvol >= rvol_thresh                          ? 1 : 0
s2 = rsi  >= rsi_low and rsi <= rsi_high          ? 1 : 0
s3 = close > vwap_val                             ? 1 : 0
s4 = near_high                                    ? 1 : 0
s5 = bull_candle                                  ? 1 : 0
s6 = rising                                       ? 1 : 0

score = s1 + s2 + s3 + s4 + s5 + s6

// ═══════════════════════════════════════════
// SIGNAL — must be in window AND score enough
// ═══════════════════════════════════════════
signal = in_window and score >= score_thresh

// ═══════════════════════════════════════════
// BACKGROUND — green tint during signal window
// ═══════════════════════════════════════════
bgcolor(in_window    ? color.new(color.blue,  92) : na, title="Scan Window")
bgcolor(signal       ? color.new(color.green, 80) : na, title="Signal Active")

// ═══════════════════════════════════════════
// GAP↑ ARROW — only on signal bars
// ═══════════════════════════════════════════
plotshape(signal,
     style    = shape.labelup,
     location = location.belowbar,
     color    = color.new(color.green, 0),
     text     = "GAP↑",
     textcolor= color.white,
     size     = size.small,
     title    = "Gap-Up Signal")

// ═══════════════════════════════════════════
// SCORE TABLE — top right corner
// Shows live ✓/✗ for all 6 conditions
// ═══════════════════════════════════════════
var table score_table = table.new(
     position   = position.top_right,
     columns    = 3,
     rows       = 9,
     bgcolor    = color.new(color.black, 20),
     border_width = 1,
     border_color = color.new(color.gray, 60))

// Header
table.cell(score_table, 0, 0, "Condition",  text_color=color.white,  text_size=size.small, bgcolor=color.new(color.navy,  20))
table.cell(score_table, 1, 0, "Value",      text_color=color.white,  text_size=size.small, bgcolor=color.new(color.navy,  20))
table.cell(score_table, 2, 0, "Status",     text_color=color.white,  text_size=size.small, bgcolor=color.new(color.navy,  20))

// Helper function — tick or cross color
f_color(v) => v == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
f_icon(v)  => v == 1 ? "✓" : "✗"

// Row 1 — RVOL
table.cell(score_table, 0, 1, "Rel Volume",               text_color=color.white, text_size=size.small)
table.cell(score_table, 1, 1, str.tostring(math.round(rvol, 1)) + "x", text_color=color.white, text_size=size.small)
table.cell(score_table, 2, 1, f_icon(s1),                 text_color=f_color(s1), text_size=size.small)

// Row 2 — RSI
table.cell(score_table, 0, 2, "RSI (55–78)",              text_color=color.white, text_size=size.small)
table.cell(score_table, 1, 2, str.tostring(math.round(rsi, 1)), text_color=color.white, text_size=size.small)
table.cell(score_table, 2, 2, f_icon(s2),                 text_color=f_color(s2), text_size=size.small)

// Row 3 — VWAP
table.cell(score_table, 0, 3, "Above VWAP",               text_color=color.white, text_size=size.small)
table.cell(score_table, 1, 3, str.tostring(math.round(close - vwap_val, 1)), text_color=color.white, text_size=size.small)
table.cell(score_table, 2, 3, f_icon(s3),                 text_color=f_color(s3), text_size=size.small)

// Row 4 — Near High
table.cell(score_table, 0, 4, "Near Day High",            text_color=color.white, text_size=size.small)
table.cell(score_table, 1, 4, str.tostring(math.round((close - day_low) / math.max(day_range, 1) * 100, 1)) + "%", text_color=color.white, text_size=size.small)
table.cell(score_table, 2, 4, f_icon(s4),                 text_color=f_color(s4), text_size=size.small)

// Row 5 — Bull candle
table.cell(score_table, 0, 5, "Bull Candle",              text_color=color.white, text_size=size.small)
table.cell(score_table, 1, 5, close > open ? "Green" : "Red", text_color=color.white, text_size=size.small)
table.cell(score_table, 2, 5, f_icon(s5),                 text_color=f_color(s5), text_size=size.small)

// Row 6 — Rising
table.cell(score_table, 0, 6, "Rising 3 bars",            text_color=color.white, text_size=size.small)
table.cell(score_table, 1, 6, str.tostring(math.round(close - close[3], 1)), text_color=color.white, text_size=size.small)
table.cell(score_table, 2, 6, f_icon(s6),                 text_color=f_color(s6), text_size=size.small)

// Row 7 — divider / total
score_color = score >= score_thresh ? color.new(color.green, 20) : color.new(color.red, 40)
table.cell(score_table, 0, 7, "TOTAL SCORE",              text_color=color.white, text_size=size.small, bgcolor=score_color)
table.cell(score_table, 1, 7, str.tostring(score) + " / 6", text_color=color.white, text_size=size.small, bgcolor=score_color)
table.cell(score_table, 2, 7, score >= score_thresh ? "BUY?" : "SKIP", text_color=color.white, text_size=size.small, bgcolor=score_color)

// Row 8 — window status
win_color = in_window ? color.new(color.teal, 40) : color.new(color.gray, 60)
table.cell(score_table, 0, 8, "Scan Window",              text_color=color.white, text_size=size.small, bgcolor=win_color)
table.cell(score_table, 1, 8, in_window ? "ACTIVE" : "CLOSED", text_color=color.white, text_size=size.small, bgcolor=win_color)
table.cell(score_table, 2, 8, in_window ? "✓" : "–",     text_color=color.white, text_size=size.small, bgcolor=win_color)
````

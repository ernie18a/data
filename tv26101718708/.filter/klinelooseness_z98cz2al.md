# KLineLooseness

- url: https://www.tradingview.com/script/z98CZ2al/
- type: indicator
- pine_id: PUB;5b2f6fdfcfe14b10a2586607b622ca3b
- version: 2.0

## Description

衡量K线松散程度，判断行情

## Source Code

````pine
//@version=6
indicator("K线松散度", "松", max_labels_count=300)

length       = input.int(3,       "EMA周期",      minval=1,  maxval=50)
use_volume   = input.bool(true,   "成交量加权")
use_body     = input.bool(true,   "影线因子")
loose_level  = input.float(60,    "松散阈值 %",   minval=0,  maxval=100, step=1)
tight_level  = input.float(40,    "紧密阈值 %",   minval=0,  maxval=100, step=1)
show_bg      = input.bool(true,   "背景高亮")
show_histo   = input.bool(true,   "柱状图模式")

// ── Non-overlap between consecutive candles ──
f_gap(hi, lo, hi_prev, lo_prev) =>
    overlap     = math.min(hi, hi_prev) - math.max(lo, lo_prev)
    total_range = math.max(hi, hi_prev) - math.min(lo, lo_prev)
    // How much of the combined range is NOT overlapping
    (1.0 - math.max(0.0, overlap) / math.max(total_range, 0.000001)) * 100.0

raw_gap_score = f_gap(high, low, high[1], low[1])
// Very short smoothing — keep it reactive
gap_score = length <= 1 ? raw_gap_score : ta.ema(raw_gap_score, length)

// ── Wick dominance ──
body_ratio  = math.abs(close - open) / math.max(high - low, 0.000001)
wick_score  = (1.0 - body_ratio) * 100.0
wick_smooth = length <= 1 ? wick_score : ta.ema(wick_score, length)

// ── Volume scarcity ──
vol_avg  = ta.sma(volume, length * 2)
rel_vol  = volume / math.max(vol_avg, 1)
vol_score = math.max(0.0, 1.0 - math.min(rel_vol, 1.5) / 1.5) * 100.0
vol_smooth = length <= 1 ? vol_score : ta.ema(vol_score, length)

// ── Composite with optional factors ──
w_gap  = use_body ? (use_volume ? 0.45 : 0.60) : (use_volume ? 0.65 : 1.00)
w_wick = use_body ? (use_volume ? 0.25 : 0.40) : 0.00
w_vol  = use_volume ? 0.30 : 0.00

looseness = gap_score * w_gap + wick_smooth * w_wick + vol_smooth * w_vol
osc = looseness - 50

// ── Colors ──
col = looseness > loose_level ? color.new(#ff4444, 20) :
      looseness < tight_level ? color.new(#44ff44, 20) :
      looseness > 50           ? color.new(#ffaa00, 20) : color.new(#888888, 30)

col_line = looseness > loose_level ? #ff4444 :
           looseness < tight_level ? #44cc44 :
           looseness > 50           ? #ffaa00 : #888888

// ── Lines ──
hline(0,  "零轴",   color=color.new(#888888, 0),  linestyle=hline.style_solid)
hline(+15, "松散", color=color.new(#ff4444, 80), linestyle=hline.style_dotted)
hline(-15, "紧密", color=color.new(#00cc00, 80), linestyle=hline.style_dotted)
h1 = hline(+25, "", color=color.new(#ff4444, 90), linestyle=hline.style_dashed)
h2 = hline(-25, "", color=color.new(#00cc00, 90), linestyle=hline.style_dashed)

// ── Plots ──
p_hist = plot(show_histo ? osc : na, "摆动值",
         color = col, style = plot.style_columns, histbase = 0)
p_line = plot(osc, "摆动值线",
         color = col_line, linewidth = 2)

p_0 = plot(0, "零轴", color=na, editable=false, display=display.none)
fill(p_line, p_0, color.new(#888888, 85))

// ── Background ──
bgcolor(show_bg and looseness > loose_level  ? color.new(#ff4444, 92) : na, title = "高度松散")
bgcolor(show_bg and looseness < tight_level  ? color.new(#00cc00, 92) : na, title = "高度紧密")

// ── Labels ──
var label last_label = na
if (ta.crossover(looseness, loose_level))
    if (not na(last_label))
        label.delete(last_label)
    last_label := label.new(bar_index, osc + 2,
         text = "⚠ 松散", color = #ff4444,
         textcolor = color.white, size = size.small,
         style = label.style_label_down)
if (ta.crossunder(looseness, tight_level))
    if (not na(last_label))
        label.delete(last_label)
    last_label := label.new(bar_index, osc - 2,
         text = "✓ 紧密", color = #00cc00,
         textcolor = color.white, size = size.small,
         style = label.style_label_up)

// ── Alerts ──
alertcondition(looseness > loose_level,  "高度松散", "K线松散度超过阈值")
alertcondition(looseness < tight_level, "高度紧密", "K线紧密性高于阈值")
alertcondition(ta.crossover(looseness, loose_level),  "进入松散", "K线开始变松散")
alertcondition(ta.crossunder(looseness, tight_level), "进入紧密", "K线开始变紧密")
alertcondition(looseness > 75, "极度松散", "K线极度松散，关注极端行情风险")
````

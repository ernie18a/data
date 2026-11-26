# Momentum Screener [TSXV/CSE/NEO]

- url: https://www.tradingview.com/script/hKQTjrrw-Momentum-Screener-TSXV-CSE-NEO/
- type: indicator
- pine_id: PUB;41f5047a3ccf421b8ec405be5cb2524e
- version: 1.0

## Description

I have made a screener for people who want to make progress and save time in shortlisting stocks. This screener only works best in TXSV CES NEO it is specifically for small cap and newly listed stocks. you guys can try it and let me know what needs to be improved. I am a momentum swing trader who works in small cap or newly listed stocks.

## Source Code

````pine
//@version=5
indicator("Momentum Screener [TSXV/CSE/NEO]", shorttitle="MS-Screen", overlay=false, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp1 = "Core Settings"
sma_len         = input.int(10,   "SMA Length",                group=grp1)
sma_ext_pct     = input.float(25, "Max Extended % from SMA",   group=grp1, step=1)
vol_avg_len     = input.int(20,   "Volume Average Length",     group=grp1)
vol_spike_mult  = input.float(2.0,"Volume Spike Multiplier",   group=grp1, step=0.5)
vol_ignition    = input.float(5.0,"Early Ignition Multiplier", group=grp1, step=0.5)
base_len        = input.int(20,   "Base Lookback (bars)",      group=grp1)
tight_pct       = input.float(15, "Tight Base % Range",        group=grp1, step=1)
delta_len       = input.int(5,    "Delta Trend Lookback",      group=grp1)
delta_weak_days = input.int(3,    "Consecutive Weak Delta Days",group=grp1)

grp2 = "Screener Filter"
min_score       = input.int(6,    "Minimum Score to Highlight (0-10)", group=grp2, minval=0, maxval=10)
show_score_only = input.bool(false,"Show Score Only (no chart noise)",  group=grp2)

// ─────────────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

// 10 SMA
sma10           = ta.sma(close, sma_len)
sma10_rising    = sma10 > sma10[3]
above_sma       = close > sma10
pct_from_sma    = ((close - sma10) / sma10) * 100
extended        = pct_from_sma > sma_ext_pct
reclaiming      = close > sma10 and close[1] <= sma10[1]

// Volume
avg_vol         = ta.sma(volume, vol_avg_len)
vol_ratio       = volume / avg_vol
vol_spike       = vol_ratio >= vol_spike_mult
vol_ignition_signal = vol_ratio >= vol_ignition

// Base
base_high       = ta.highest(high, base_len)
base_low        = ta.lowest(low, base_len)
base_range_pct  = ((base_high - base_low) / base_low) * 100
tight_base      = base_range_pct <= tight_pct
hl1             = low > low[5]
hl2             = low[5] > low[10]
higher_lows     = hl1 and hl2
base_midpoint   = (base_high + base_low) / 2
in_upper_half   = close >= base_midpoint

// Delta approximation
candle_range    = high - low
body_size       = math.abs(close - open)
body_ratio      = candle_range > 0 ? body_size / candle_range : 0
upper_close     = close > (high + low) / 2
delta_pos       = upper_close ? volume * body_ratio : -volume * body_ratio
delta_sma       = ta.sma(delta_pos, delta_len)
delta_positive  = delta_sma > 0
delta_rising    = delta_sma > delta_sma[3]
neg_delta_day   = delta_pos < 0
consec_neg      = 0
consec_neg     := neg_delta_day ? nz(consec_neg[1]) + 1 : 0
delta_weakness  = consec_neg >= delta_weak_days

// ─────────────────────────────────────────────────────────────────────────────
// QUALITY SCORE (0-10)
// ─────────────────────────────────────────────────────────────────────────────
quality_score = 0
quality_score := quality_score + (sma10_rising  ? 2 : 0)
quality_score := quality_score + (above_sma     ? 1 : 0)
quality_score := quality_score + (tight_base    ? 1 : 0)
quality_score := quality_score + (higher_lows   ? 1 : 0)
quality_score := quality_score + (delta_positive ? 2 : 0)
quality_score := quality_score + (vol_spike     ? 1 : 0)
quality_score := quality_score + (in_upper_half ? 1 : 0)
quality_score := quality_score + (not extended  ? 1 : 0)

// Penalty for warnings
quality_score := quality_score - (delta_weakness ? 3 : 0)
quality_score := quality_score - (extended       ? 2 : 0)
quality_score := quality_score - (not above_sma  ? 2 : 0)
quality_score := math.max(quality_score, 0)

// Grade
grade_num = quality_score >= 8 ? 4 : quality_score >= 6 ? 3 : quality_score >= 4 ? 2 : 1
grade_str = quality_score >= 8 ? "A" : quality_score >= 6 ? "B" : quality_score >= 4 ? "C" : "D"

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL DETECTION
// ─────────────────────────────────────────────────────────────────────────────
signal_base_breakout = tight_base and vol_spike and above_sma and delta_positive and higher_lows and not extended and close > base_high[1]
signal_stabilization = close > sma10 * 0.95 and close < ta.highest(close, 10) * 0.95 and volume < avg_vol and delta_positive and sma10_rising and higher_lows and not delta_weakness
was_quiet            = avg_vol < 200000
signal_ignition      = vol_ignition_signal and close > open and close > ta.highest(close, base_len)[1] and was_quiet
signal_continuation  = sma10_rising and above_sma and reclaiming and vol_spike and delta_positive and not extended
any_signal           = signal_base_breakout or signal_stabilization or signal_ignition or signal_continuation

// Active signal type as number (for screener sorting)
// 4=Ignition, 3=Breakout, 2=Continuation, 1=Stabilization, 0=None
signal_rank = signal_ignition ? 4 : signal_base_breakout ? 3 : signal_continuation ? 2 : signal_stabilization ? 1 : 0

// ─────────────────────────────────────────────────────────────────────────────
// COMPOSITE SCREENER VALUE
// This is the KEY output — used in TradingView Screener
// Higher = better setup. Range 0-14
// ─────────────────────────────────────────────────────────────────────────────
screener_value = quality_score + signal_rank
plot(screener_value, "Screener Score", color=color.new(color.blue, 0), display=display.all)
plot(quality_score,  "Quality Score",  color=color.new(color.green, 0), display=display.all)
plot(signal_rank,    "Signal Rank",    color=color.new(color.orange, 0), display=display.all)

// ─────────────────────────────────────────────────────────────────────────────
// VISUAL OUTPUT — Score Panel
// ─────────────────────────────────────────────────────────────────────────────

// Score bar chart — shows quality over time
score_color = quality_score >= 8 ? color.new(#00E676, 0) : quality_score >= 6 ? color.new(#2196F3, 0) : quality_score >= 4 ? color.new(#FFD700, 0) : color.new(#FF6B6B, 0)
plot(quality_score, "Quality Score Bar", style=plot.style_columns, color=score_color)

// Minimum score threshold line
hline(min_score, "Min Score Threshold", color=color.new(#FF6D00, 70), linestyle=hline.style_dashed, linewidth=2)
hline(8, "A Grade",  color=color.new(#00E676, 70), linestyle=hline.style_dotted)
hline(6, "B Grade",  color=color.new(#2196F3, 70), linestyle=hline.style_dotted)

// Signal markers on score panel
plotshape(signal_base_breakout, title="BB Signal",    location=location.top, style=shape.triangleup,  size=size.small, color=color.new(#00E676, 0))
plotshape(signal_ignition,      title="EI Signal",    location=location.top, style=shape.labelup,     size=size.small, color=color.new(#FFD700, 0))
plotshape(signal_continuation,  title="Cont Signal",  location=location.top, style=shape.diamond,     size=size.tiny,  color=color.new(#00BCD4, 0))
plotshape(signal_stabilization and not signal_base_breakout, title="Stab Signal", location=location.top, style=shape.circle, size=size.tiny, color=color.new(#2196F3, 0))

// Warning markers
plotshape(delta_weakness, title="Delta Weak", location=location.bottom, style=shape.xcross, size=size.tiny, color=color.new(#FF1744, 0))

// ─────────────────────────────────────────────────────────────────────────────
// SCREENER TABLE — Current bar summary
// ─────────────────────────────────────────────────────────────────────────────
var table scr = table.new(position.top_right, 2, 7, bgcolor=color.new(#0D1117, 5), border_color=color.new(#30363D, 0), border_width=1, frame_color=color.new(#30363D,0), frame_width=1)

table.cell(scr, 0, 0, "SCREENER", text_color=color.white, text_size=size.small, bgcolor=color.new(#161B22,0), text_halign=text.align_center)
table.merge_cells(scr, 0, 0, 1, 0)

score_color_tbl = quality_score >= 8 ? #00E676 : quality_score >= 6 ? #2196F3 : quality_score >= 4 ? #FFD700 : #FF6B6B
table.cell(scr, 0, 1, "SCORE", text_color=color.new(#8B949E,0), text_size=size.small)
table.cell(scr, 1, 1, grade_str + " (" + str.tostring(quality_score) + "/10)", text_color=score_color_tbl, text_size=size.small, text_halign=text.align_center)

passes = quality_score >= min_score
table.cell(scr, 0, 2, "FILTER", text_color=color.new(#8B949E,0), text_size=size.small)
table.cell(scr, 1, 2, passes ? "PASS" : "FAIL", text_color=passes ? #00E676 : #FF1744, text_size=size.small, text_halign=text.align_center)

sig_str = signal_ignition ? "EARLY IGNITION" : signal_base_breakout ? "BASE BREAKOUT" : signal_continuation ? "CONTINUATION" : signal_stabilization ? "STABILIZATION" : "NONE"
sig_col = signal_ignition ? #FFD700 : signal_base_breakout ? #00E676 : signal_continuation ? #00BCD4 : signal_stabilization ? #2196F3 : color.new(#8B949E,0)
table.cell(scr, 0, 3, "SIGNAL", text_color=color.new(#8B949E,0), text_size=size.small)
table.cell(scr, 1, 3, sig_str, text_color=sig_col, text_size=size.small, text_halign=text.align_center)

table.cell(scr, 0, 4, "DELTA", text_color=color.new(#8B949E,0), text_size=size.small)
table.cell(scr, 1, 4, delta_weakness ? "WEAK !" : delta_positive and delta_rising ? "STRONG +" : delta_positive ? "POSITIVE" : "NEGATIVE", text_color=delta_weakness ? #FF1744 : delta_positive ? #00E676 : #FF6B6B, text_size=size.small, text_halign=text.align_center)

table.cell(scr, 0, 5, "VOLUME", text_color=color.new(#8B949E,0), text_size=size.small)
vol_ratio_str2 = str.tostring(math.round(vol_ratio, 1))
table.cell(scr, 1, 5, vol_ignition_signal ? "IGNITION " + vol_ratio_str2 + "x" : vol_spike ? "SPIKE " + vol_ratio_str2 + "x" : vol_ratio_str2 + "x", text_color=vol_ignition_signal ? #FFD700 : vol_spike ? #00E676 : color.new(#8B949E,0), text_size=size.small, text_halign=text.align_center)

warn_str = delta_weakness ? "DELTA WEAK !" : not above_sma ? "BELOW SMA !" : extended ? "EXTENDED !" : "CLEAR"
warn_col = (delta_weakness or not above_sma) ? #FF1744 : extended ? #FF6D00 : #00E676
table.cell(scr, 0, 6, "STATUS", text_color=color.new(#8B949E,0), text_size=size.small)
table.cell(scr, 1, 6, warn_str, text_color=warn_col, text_size=size.small, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(quality_score >= 8 and any_signal, title="A-Grade Signal", message="{{ticker}} -- A-Grade setup detected on {{exchange}}. Score 8+. Check chart immediately.")
alertcondition(signal_base_breakout, title="Base Breakout", message="{{ticker}} -- Base Breakout signal on {{exchange}}. Close: {{close}}.")
alertcondition(signal_ignition, title="Early Ignition", message="{{ticker}} -- Early Ignition signal on {{exchange}}. Volume spike. Close: {{close}}.")
alertcondition(signal_continuation, title="Continuation", message="{{ticker}} -- Continuation signal on {{exchange}}. Close: {{close}}.")
alertcondition(signal_stabilization, title="Stabilization", message="{{ticker}} -- Stabilization entry on {{exchange}}. Close: {{close}}.")
alertcondition(delta_weakness, title="Delta Weakness", message="{{ticker}} -- Delta weakness 3+ days on {{exchange}}. Review position.")
````

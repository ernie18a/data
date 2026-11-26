# Double Supertrend Strategy (25m + 125m)

- url: https://www.tradingview.com/script/rS35qgDc-Double-Supertrend-Strategy-25m-125m/
- type: indicator
- pine_id: PUB;129dfa6c6bcc46b68482e5cfef7a266f
- version: 1.0

## Description

Double supertred we can say that multi time frame stratergy

## Source Code

````pine
//@version=6
indicator(title="Double Supertrend Strategy (25m + 125m)", shorttitle="DST Strategy", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// Higher Timeframe Supertrend (125 min)
htf_tf         = input.timeframe("125",  title="Higher Timeframe",          group="HTF Supertrend (125 min)")
htf_atr_len    = input.int(10,           title="ATR Length",    minval=1,    group="HTF Supertrend (125 min)")
htf_factor     = input.float(3.0,        title="ATR Factor",    minval=0.1,  group="HTF Supertrend (125 min)")

// Current Timeframe Supertrend (25 min)
ctf_atr_len    = input.int(10,           title="ATR Length",    minval=1,    group="CTF Supertrend (25 min)")
ctf_factor     = input.float(3.0,        title="ATR Factor",    minval=0.1,  group="CTF Supertrend (25 min)")

// Risk / Reward
rr_ratio       = input.float(2.0,        title="Risk:Reward Ratio",         group="Trade Settings", minval=1.0, step=0.5)

// Display
show_htf_st    = input.bool(true,  title="Show HTF Supertrend",             group="Display")
show_ctf_st    = input.bool(true,  title="Show CTF Supertrend",             group="Display")
show_signals   = input.bool(true,  title="Show Entry Signals",              group="Display")
show_levels    = input.bool(true,  title="Show SL / TP Lines",              group="Display")
show_labels    = input.bool(true,  title="Show SL / TP Labels",             group="Display")

// ─────────────────────────────────────────────────────────────────────────────
// SUPERTREND FUNCTION
// ─────────────────────────────────────────────────────────────────────────────
supertrend(src, factor, atr_len) =>
    atr     = ta.atr(atr_len)
    upperBand = src + factor * atr
    lowerBand = src - factor * atr

    prevUpperBand = nz(upperBand[1], upperBand)
    prevLowerBand = nz(lowerBand[1], lowerBand)

    upperBand := upperBand < prevUpperBand or close[1] > prevUpperBand ? upperBand : prevUpperBand
    lowerBand := lowerBand > prevLowerBand or close[1] < prevLowerBand ? lowerBand : prevLowerBand

    var int  trend = 1
    var float st  = na
    if na(st[1])
        trend := 1
        st    := lowerBand
    else
        if trend[1] == 1
            if close < lowerBand
                trend := -1
                st    := upperBand
            else
                trend := 1
                st    := lowerBand
        else
            if close > upperBand
                trend := 1
                st    := lowerBand
            else
                trend := -1
                st    := upperBand
    [st, trend]

// ─────────────────────────────────────────────────────────────────────────────
// CURRENT TIMEFRAME SUPERTREND
// ─────────────────────────────────────────────────────────────────────────────
[ctf_st, ctf_trend] = supertrend(hl2, ctf_factor, ctf_atr_len)

// ─────────────────────────────────────────────────────────────────────────────
// HIGHER TIMEFRAME SUPERTREND  (request.security keeps it non-repainting)
// ─────────────────────────────────────────────────────────────────────────────
[htf_st_raw, htf_trend_raw] = request.security(syminfo.tickerid, htf_tf, supertrend(hl2, htf_factor, htf_atr_len), lookahead=barmerge.lookahead_off)

htf_st    = htf_st_raw
htf_trend = htf_trend_raw

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL LOGIC
// ─────────────────────────────────────────────────────────────────────────────
htf_bull  = htf_trend == 1
ctf_bull  = ctf_trend == 1

// CTF just turned bullish this bar
ctf_turned_bull = ctf_trend == 1 and ctf_trend[1] == -1

// Entry: HTF bullish AND CTF just turned bullish
buy_signal = htf_bull and ctf_turned_bull

// Exit: CTF turns bearish
ctf_turned_bear = ctf_trend == -1 and ctf_trend[1] == 1

// ─────────────────────────────────────────────────────────────────────────────
// TRADE STATE — track active trade SL / TP
// ─────────────────────────────────────────────────────────────────────────────
var float  entry_price = na
var float  sl_price    = na
var float  tp_price    = na
var bool   in_trade    = false

var line   sl_line     = na
var line   tp_line     = na
var label  sl_lbl      = na
var label  tp_lbl      = na
var label  entry_lbl   = na

if buy_signal and not in_trade
    entry_price := close
    sl_price    := ctf_st                           // CTF Supertrend line = stop loss
    risk        = entry_price - sl_price
    tp_price    := entry_price + risk * rr_ratio    // 1:2 RR target

    in_trade    := true

    // Draw entry label
    if show_signals
        entry_lbl := label.new(bar_index, low, "BUY\n" + str.tostring(entry_price, format.mintick),
             style=label.style_label_up, color=color.new(color.green, 10),
             textcolor=color.white, size=size.small)

    // Draw SL / TP lines
    if show_levels
        sl_line := line.new(bar_index, sl_price, bar_index + 1, sl_price,
             color=color.new(color.red, 20), width=2, style=line.style_dashed)
        tp_line := line.new(bar_index, tp_price, bar_index + 1, tp_price,
             color=color.new(color.teal, 20), width=2, style=line.style_dashed)

    if show_labels
        sl_lbl := label.new(bar_index, sl_price, "SL: " + str.tostring(sl_price, format.mintick),
             style=label.style_label_right, color=color.new(color.red, 10),
             textcolor=color.white, size=size.tiny)
        tp_lbl := label.new(bar_index, tp_price, "TP: " + str.tostring(tp_price, format.mintick),
             style=label.style_label_right, color=color.new(color.teal, 10),
             textcolor=color.white, size=size.tiny)

// Extend SL / TP lines while in trade
if in_trade and not na(sl_line)
    line.set_x2(sl_line, bar_index + 1)
    line.set_x2(tp_line, bar_index + 1)

// ─── EXIT CONDITIONS ───────────────────────────────────────────────────────

// Exit via Stop Loss (price touches/crosses below CTF Supertrend while it was still bullish)
sl_hit = in_trade and low <= sl_price

// Exit via Target
tp_hit = in_trade and high >= tp_price

// Exit via CTF Supertrend turning bearish
st_exit = in_trade and ctf_turned_bear

exit_triggered = sl_hit or tp_hit or st_exit

if exit_triggered
    exit_reason = sl_hit ? "SL HIT" : tp_hit ? "TP HIT ✓" : "ST EXIT"
    exit_col    = sl_hit ? color.red : tp_hit ? color.teal : color.orange

    if show_signals
        label.new(bar_index, high, exit_reason,
             style=label.style_label_down, color=color.new(exit_col, 10),
             textcolor=color.white, size=size.small)

    in_trade    := false
    entry_price := na
    sl_price    := na
    tp_price    := na

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────

// CTF Supertrend
ctf_bull_color = color.new(color.green, 30)
ctf_bear_color = color.new(color.red,   30)
plot(show_ctf_st ? ctf_st : na, title="CTF Supertrend",
     color=ctf_trend == 1 ? ctf_bull_color : ctf_bear_color,
     linewidth=2, style=plot.style_linebr)

// HTF Supertrend
htf_bull_color = color.new(color.blue,   20)
htf_bear_color = color.new(color.orange, 20)
plot(show_htf_st ? htf_st : na, title="HTF Supertrend (125m)",
     color=htf_trend == 1 ? htf_bull_color : htf_bear_color,
     linewidth=3, style=plot.style_linebr)

// Background tint: both bullish = light green, otherwise neutral
bgcolor(htf_bull and ctf_bull ? color.new(color.green, 90) : na, title="Bullish Alignment BG")

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(buy_signal,       title="Buy Entry",       message="Double ST: BUY signal — HTF + CTF both bullish. Entry: {{close}}")
alertcondition(ctf_turned_bear,  title="Supertrend Exit", message="Double ST: CTF Supertrend turned bearish — EXIT trade.")
alertcondition(sl_hit,           title="Stop Loss Hit",   message="Double ST: Stop Loss hit.")
alertcondition(tp_hit,           title="Target Hit",      message="Double ST: Target hit — TP reached!")
````

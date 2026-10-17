# LTA Confirmations: EMA + ADX + VWAP

- url: https://www.tradingview.com/script/1e4Yhfsg-LTA-Confirmations-EMA-ADX-VWAP/
- type: indicator
- pine_id: PUB;e3ed792d634a416fbe00a29b3813e15f
- version: 1.0

## Description

📊 LTA CONFIRMATIONS — WHAT IT SHOWS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This is our second indicator (slot 2 of 5)
It merges 3 tools into one script:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📉 EMA 9 / EMA 21
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Two moving averages on the chart
→ Green fill = EMA 9 above EMA 21
   = bullish momentum
→ Red fill = EMA 9 below EMA 21
   = bearish momentum
→ Labels appear on crossovers
→ Alerts fire on every EMA cross

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💧 VWAP (Volume Weighted Avg Price)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Orange line — resets every session
→ Price above VWAP = intraday bullish
→ Price below VWAP = intraday bearish
→ Bands show ±1 standard deviation
   (fair value zone)
→ Alerts fire when price crosses VWAP

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ADX (Trend Strength Filter)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ Table bottom-right of chart shows:
   • ADX number (0–100)
   • ⚠️ Weak / Ranging  = ADX below 25
   • ✅ Trending         = ADX above 25
   • 🔥 Very Strong      = ADX above 40
   • Direction: DI+ vs DI−
     (bullish or bearish pressure)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔥 CONFLUENCE ALERT (Most Powerful)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fires ONLY when ALL THREE line up:
→ EMA 9 crosses EMA 21
→ ADX is above 25 (trending)
→ DI direction matches the cross

= Strongest signal the indicator gives
= Only trade when this fires

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IN SIMPLE TERMS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LTA All-In-One  = WHERE to trade
                  (levels + structure)

LTA Confirmations = WHETHER to trade
                    (trend + momentum)

Use them together — levels first,
then confirmations before entry ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
indicator("LTA Confirmations: EMA + ADX + VWAP", overlay=true, max_bars_back=500)

// ══════════════════════════════════════════
// GROUP 1 — EMA 9 / 21
// ══════════════════════════════════════════
grp_ema = "📉 EMA 9 / 21"
show_ema      = input.bool(true, "Show EMAs", group=grp_ema)
ema_fast_len  = input.int(9,  "Fast EMA Length", minval=1, group=grp_ema)
ema_slow_len  = input.int(21, "Slow EMA Length", minval=1, group=grp_ema)
ema_fast_col  = input.color(color.new(#26A69A, 0),  "EMA 9 Colour",  group=grp_ema)
ema_slow_col  = input.color(color.new(#EF5350, 0),  "EMA 21 Colour", group=grp_ema)
ema_fast_wid  = input.int(2, "EMA 9 Width",  minval=1, maxval=4, group=grp_ema)
ema_slow_wid  = input.int(2, "EMA 21 Width", minval=1, maxval=4, group=grp_ema)
show_ema_fill = input.bool(true, "Fill Between EMAs", group=grp_ema)
show_ema_cross_label = input.bool(true, "Show Cross Labels", group=grp_ema)

ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)

p_ema_fast = plot(show_ema ? ema_fast : na, "EMA 9",  color=ema_fast_col, linewidth=ema_fast_wid)
p_ema_slow = plot(show_ema ? ema_slow : na, "EMA 21", color=ema_slow_col, linewidth=ema_slow_wid)

fill(p_ema_fast, p_ema_slow,
     color = show_ema and show_ema_fill
             ? (ema_fast > ema_slow
                ? color.new(#26A69A, 88)
                : color.new(#EF5350, 88))
             : na,
     title = "EMA Fill")

ema_bull_cross = ta.crossover(ema_fast,  ema_slow)
ema_bear_cross = ta.crossunder(ema_fast, ema_slow)

if show_ema and show_ema_cross_label
    if ema_bull_cross
        label.new(bar_index, low - syminfo.mintick * 8,
                  "EMA ▲", style=label.style_label_up,
                  color=color.new(#26A69A, 5),
                  textcolor=color.white, size=size.tiny)
    if ema_bear_cross
        label.new(bar_index, high + syminfo.mintick * 8,
                  "EMA ▼", style=label.style_label_down,
                  color=color.new(#EF5350, 5),
                  textcolor=color.white, size=size.tiny)

// ══════════════════════════════════════════
// GROUP 2 — ADX
// ══════════════════════════════════════════
grp_adx = "📊 ADX (Strength Filter)"
show_adx      = input.bool(true,  "Show ADX Table", group=grp_adx)
adx_len       = input.int(14,     "ADX Length", minval=1, group=grp_adx)
adx_smooth    = input.int(14,     "ADX Smoothing", minval=1, group=grp_adx)
adx_strong    = input.float(25.0, "Strong Trend Level", minval=10.0, step=1.0, group=grp_adx)
adx_very_str  = input.float(40.0, "Very Strong Level",  minval=20.0, step=1.0, group=grp_adx)
show_adx_bg   = input.bool(true,  "Highlight Strong Trend Candles", group=grp_adx)

[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_smooth)

adx_trending    = adx_val >= adx_strong
adx_very_strong = adx_val >= adx_very_str
adx_dir_bull    = diplus > diminus

bgcolor(show_adx and show_adx_bg and adx_very_strong
        ? (adx_dir_bull
           ? color.new(#26A69A, 93)
           : color.new(#EF5350, 93))
        : na,
        title="ADX Strong Trend BG")

if show_adx and barstate.islast
    var table adx_tbl = table.new(position.bottom_right, 1, 3,
                                   bgcolor=color.new(color.black, 70),
                                   border_width=1)
    string adx_str = adx_very_strong ? "🔥 VERY STRONG" : adx_trending ? "✅ TRENDING" : "⚠️ WEAK / RANGING"
    color  adx_col = adx_very_strong ? color.new(#F5C842, 0) : adx_trending ? color.new(#26A69A, 0) : color.new(#888888, 0)
    string dir_str = adx_dir_bull ? "▲ DI+ > DI−  (Bullish Pressure)" : "▼ DI− > DI+  (Bearish Pressure)"
    color  dir_col = adx_dir_bull ? color.new(#26A69A, 0) : color.new(#EF5350, 0)
    table.cell(adx_tbl, 0, 0, "ADX: " + str.tostring(math.round(adx_val, 1)), text_color=adx_col, text_size=size.small)
    table.cell(adx_tbl, 0, 1, adx_str,  text_color=adx_col, text_size=size.small)
    table.cell(adx_tbl, 0, 2, dir_str,  text_color=dir_col, text_size=size.small)

// ══════════════════════════════════════════
// GROUP 3 — VWAP
// ══════════════════════════════════════════
grp_vwap = "💧 VWAP"
show_vwap       = input.bool(true, "Show VWAP", group=grp_vwap)
vwap_col        = input.color(color.new(#FF9800, 0), "VWAP Colour", group=grp_vwap)
vwap_width      = input.int(2, "VWAP Width", minval=1, maxval=4, group=grp_vwap)
show_vwap_bands = input.bool(true, "Show VWAP Bands (±1 StdDev)", group=grp_vwap)
vwap_band_col   = input.color(color.new(#FF9800, 75), "Band Colour", group=grp_vwap)
show_vwap_label = input.bool(true, "Show VWAP Label", group=grp_vwap)

// Session VWAP (resets daily)
vwap_src = hlc3
var float vwap_cum_pv = 0.0
var float vwap_cum_v  = 0.0
var float vwap_cum_pv2 = 0.0

new_day = ta.change(time("D")) != 0
if new_day or barstate.isfirst
    vwap_cum_pv  := 0.0
    vwap_cum_v   := 0.0
    vwap_cum_pv2 := 0.0

vwap_cum_pv  += vwap_src * volume
vwap_cum_v   += volume
vwap_cum_pv2 += vwap_src * vwap_src * volume

vwap_line = vwap_cum_v > 0 ? vwap_cum_pv / vwap_cum_v : na
vwap_var  = vwap_cum_v > 0 ? math.max(0.0, vwap_cum_pv2 / vwap_cum_v - vwap_line * vwap_line) : na
vwap_std  = not na(vwap_var) ? math.sqrt(vwap_var) : na

vwap_upper = not na(vwap_line) ? vwap_line + vwap_std : na
vwap_lower = not na(vwap_line) ? vwap_line - vwap_std : na

p_vwap_line  = plot(show_vwap ? vwap_line  : na, "VWAP",        color=vwap_col,      linewidth=vwap_width)
p_vwap_upper = plot(show_vwap and show_vwap_bands ? vwap_upper : na, "VWAP +1σ", color=vwap_band_col, linewidth=1)
p_vwap_lower = plot(show_vwap and show_vwap_bands ? vwap_lower : na, "VWAP −1σ", color=vwap_band_col, linewidth=1)

fill(p_vwap_upper, p_vwap_lower,
     color = show_vwap and show_vwap_bands ? color.new(#FF9800, 94) : na,
     title = "VWAP Band Fill")

if show_vwap and show_vwap_label and barstate.islast and not na(vwap_line)
    label.new(bar_index + 2, vwap_line,
              "VWAP  " + str.tostring(vwap_line, format.mintick),
              style=label.style_label_left,
              color=color.new(#FF9800, 5),
              textcolor=color.black, size=size.small)

// ══════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════
alertcondition(ema_bull_cross,
               title="EMA Bullish Cross (9 over 21)",
               message="{{ticker}} EMA 9 crossed ABOVE EMA 21 ({{close}}). Bullish momentum signal.")

alertcondition(ema_bear_cross,
               title="EMA Bearish Cross (9 under 21)",
               message="{{ticker}} EMA 9 crossed BELOW EMA 21 ({{close}}). Bearish momentum signal.")

alertcondition(ta.crossover(close, vwap_line),
               title="Price Crossed ABOVE VWAP",
               message="{{ticker}} crossed above VWAP at {{close}}. Intraday bullish bias.")

alertcondition(ta.crossunder(close, vwap_line),
               title="Price Crossed BELOW VWAP",
               message="{{ticker}} crossed below VWAP at {{close}}. Intraday bearish bias.")

alertcondition(not adx_trending[1] and adx_trending,
               title="ADX Entered Trend (crossed above 25)",
               message="{{ticker}} ADX crossed above 25 — trend is starting. Check direction with DI+ / DI−.")

alertcondition(adx_trending[1] and not adx_trending,
               title="ADX Dropped Below 25 — Trend Weakening",
               message="{{ticker}} ADX dropped below 25. Trend losing strength — consider tighter stops.")

alertcondition(ema_bull_cross and adx_trending and adx_dir_bull,
               title="🔥 CONFLUENCE — Bullish EMA Cross + ADX Trending",
               message="{{ticker}} FULL BULL CONFLUENCE: EMA 9 over 21 AND ADX trending AND DI+ dominant at {{close}}.")

alertcondition(ema_bear_cross and adx_trending and not adx_dir_bull,
               title="🔥 CONFLUENCE — Bearish EMA Cross + ADX Trending",
               message="{{ticker}} FULL BEAR CONFLUENCE: EMA 9 under 21 AND ADX trending AND DI− dominant at {{close}}.")
````

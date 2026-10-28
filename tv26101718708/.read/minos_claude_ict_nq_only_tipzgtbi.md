# Mino's Claude ICT NQ ONLY

- url: https://www.tradingview.com/script/tipzGtBI-Mino-s-Claude-ICT-NQ-ONLY/
- type: indicator
- pine_id: PUB;7b18b505f38e49e8a7fa4283f37a97bc
- version: 1.0

## Description

Claude + ChatGPT ICT, Marks out everything, ONLY AVAILABLE ON NQ

## Source Code

````pine
//@version=5
indicator("ICT NQ Suite", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)
 
// ═══════════════════════════════════════════════════════════════
//  ICT NQ SUITE — Fair Value Gaps · Order Blocks · BOS/CHoCH
//                 Liquidity Sweeps · Sessions · VWAP · Alerts
//
//  Recommended: NQ1! or MNQ1! on 1m / 3m / 5m chart
// ═══════════════════════════════════════════════════════════════
 
// ── Fair Value Gaps ─────────────────────────────────────────────
g_fvg         = "── Fair Value Gaps ──"
i_fvg         = input.bool(true,  "Show FVGs",           group=g_fvg)
i_fvg_extend  = input.int(25,     "Extend (bars)",        group=g_fvg, minval=1, maxval=100)
i_fvg_bull    = input.color(color.new(color.teal,  78),  "Bullish FVG color", group=g_fvg)
i_fvg_bear    = input.color(color.new(color.red,   78),  "Bearish FVG color", group=g_fvg)
 
// ── Order Blocks ────────────────────────────────────────────────
g_ob          = "── Order Blocks ──"
i_ob          = input.bool(true,  "Show Order Blocks",   group=g_ob)
i_ob_bull     = input.color(color.new(color.blue,  75),  "Bullish OB color",  group=g_ob)
i_ob_bear     = input.color(color.new(color.orange,75),  "Bearish OB color",  group=g_ob)
 
// ── Market Structure ────────────────────────────────────────────
g_ms          = "── Market Structure ──"
i_bos         = input.bool(true, "Show BOS",             group=g_ms)
i_mss         = input.bool(true, "Show MSS / CHoCH",     group=g_ms)
i_swing_len   = input.int(10,    "Swing Length",          group=g_ms, minval=3, maxval=50)
 
// ── Liquidity ───────────────────────────────────────────────────
g_liq         = "── Liquidity Sweeps ──"
i_liq         = input.bool(true,  "Show Liquidity Sweeps", group=g_liq)
i_liq_tf      = input.timeframe("15", "Timeframe (min or higher)", group=g_liq)
i_liq_thr     = input.float(0.05, "Equal Level Threshold %", group=g_liq, minval=0.01, maxval=2.0, step=0.01)
i_liq_lb      = input.int(30,     "Lookback (HTF bars)",  group=g_liq, minval=5, maxval=100)
 
// ── Sessions & VWAP ─────────────────────────────────────────────
g_ses         = "── Sessions & VWAP ──"
i_london      = input.bool(true, "Show London Session",  group=g_ses)
i_ny          = input.bool(true, "Show NY Session",      group=g_ses)
i_vwap        = input.bool(true, "Show VWAP",            group=g_ses)
 
// ═══════════════════════════════════════════════════════════════
//  SESSIONS
// ═══════════════════════════════════════════════════════════════
 
london_time = time(timeframe.period, "0300-0830", "America/New_York")
ny_time     = time(timeframe.period, "0930-1600", "America/New_York")
 
in_london   = not na(london_time)
in_ny       = not na(ny_time)
 
bgcolor(i_london and in_london ? color.new(color.yellow, 92) : na, title="London Session BG")
bgcolor(i_ny     and in_ny     ? color.new(color.blue,   93) : na, title="NY Session BG")
 
// Track London High/Low and draw level lines when session closes
var float ldn_hi   = na
var float ldn_lo   = na
var bool  ldn_prev = false
 
if in_london and not ldn_prev
    ldn_hi := high
    ldn_lo := low
else if in_london
    ldn_hi := math.max(ldn_hi, high)
    ldn_lo := math.min(ldn_lo, low)
 
if ldn_prev and not in_london and i_london and not na(ldn_hi)
    line.new(bar_index, ldn_hi, bar_index + 100, ldn_hi,
         color=color.new(color.yellow, 10), style=line.style_dashed, width=1)
    line.new(bar_index, ldn_lo, bar_index + 100, ldn_lo,
         color=color.new(color.yellow, 10), style=line.style_dashed, width=1)
    label.new(bar_index, ldn_hi, "LDN H  " + str.tostring(ldn_hi, "#.00"),
         style=label.style_label_left, size=size.tiny,
         color=color.new(color.yellow, 55), textcolor=color.black)
    label.new(bar_index, ldn_lo, "LDN L  " + str.tostring(ldn_lo, "#.00"),
         style=label.style_label_left, size=size.tiny,
         color=color.new(color.yellow, 55), textcolor=color.black)
 
ldn_prev := in_london
 
// ═══════════════════════════════════════════════════════════════
//  VWAP
// ═══════════════════════════════════════════════════════════════
 
plot(i_vwap ? ta.vwap(hlc3) : na, "VWAP", color=#9C27B0, linewidth=2)
 
// ═══════════════════════════════════════════════════════════════
//  FAIR VALUE GAPS
// ═══════════════════════════════════════════════════════════════
 
// Bullish FVG: current candle's low is above 2-bars-ago high (upward price gap)
bull_fvg_cond = low > high[2]
// Bearish FVG: current candle's high is below 2-bars-ago low (downward price gap)
bear_fvg_cond = high < low[2]
 
var box[] b_fvg = array.new<box>()
var box[] s_fvg = array.new<box>()
 
if i_fvg
    if bull_fvg_cond
        b = box.new(bar_index - 2, high[2], bar_index + i_fvg_extend, low,
             bgcolor=i_fvg_bull, border_color=color.new(color.teal, 40), border_width=1)
        array.push(b_fvg, b)
 
    if bear_fvg_cond
        b = box.new(bar_index - 2, high, bar_index + i_fvg_extend, low[2],
             bgcolor=i_fvg_bear, border_color=color.new(color.red, 40), border_width=1)
        array.push(s_fvg, b)
 
// Detect price tapping into a live FVG zone
bull_fvg_tap = false
bear_fvg_tap = false
 
for b in b_fvg
    if low <= box.get_top(b) and close >= box.get_bottom(b)
        bull_fvg_tap := true
 
for b in s_fvg
    if high >= box.get_bottom(b) and close <= box.get_top(b)
        bear_fvg_tap := true
 
// ═══════════════════════════════════════════════════════════════
//  MARKET STRUCTURE — BOS & CHoCH (MSS)
// ═══════════════════════════════════════════════════════════════
 
ph = ta.pivothigh(high, i_swing_len, i_swing_len)
pl = ta.pivotlow (low,  i_swing_len, i_swing_len)
 
var float last_ph    = na
var float last_pl    = na
var int   trend_dir  = 0   // 1 = bullish, -1 = bearish
 
if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl
 
bull_bos = not na(last_ph) and close > last_ph and close[1] <= last_ph
bear_bos = not na(last_pl) and close < last_pl and close[1] >= last_pl
 
bull_choch = bull_bos and trend_dir == -1
bear_choch = bear_bos and trend_dir == 1
 
if bull_bos
    lbl   = bull_choch ? "CHoCH ↑" : "BOS ↑"
    col   = bull_choch ? color.lime : color.green
    show  = bull_choch ? i_mss : i_bos
    if show
        label.new(bar_index, low, lbl, yloc=yloc.belowbar,
             style=label.style_label_up, size=size.small,
             color=color.new(col, 15), textcolor=color.white)
    trend_dir := 1
 
if bear_bos
    lbl   = bear_choch ? "CHoCH ↓" : "BOS ↓"
    col   = bear_choch ? color.red : color.maroon
    show  = bear_choch ? i_mss : i_bos
    if show
        label.new(bar_index, high, lbl, yloc=yloc.abovebar,
             style=label.style_label_down, size=size.small,
             color=color.new(col, 15), textcolor=color.white)
    trend_dir := -1
 
// ═══════════════════════════════════════════════════════════════
//  ORDER BLOCKS
// ═══════════════════════════════════════════════════════════════
 
var float bull_ob_h = na
var float bull_ob_l = na
var float bear_ob_h = na
var float bear_ob_l = na
 
if i_ob
    // Bullish OB: last bearish candle before a bullish BOS
    if bull_bos
        for i = 1 to 15
            if close[i] < open[i]
                bull_ob_h := high[i]
                bull_ob_l := low[i]
                box.new(bar_index - i, low[i], bar_index + 30, high[i],
                     bgcolor=i_ob_bull, border_color=color.new(color.blue, 30), border_width=1)
                label.new(bar_index - i, high[i], "Bull OB",
                     style=label.style_label_down, size=size.tiny,
                     color=color.new(color.blue, 30), textcolor=color.white)
                break
 
    // Bearish OB: last bullish candle before a bearish BOS
    if bear_bos
        for i = 1 to 15
            if close[i] > open[i]
                bear_ob_h := high[i]
                bear_ob_l := low[i]
                box.new(bar_index - i, low[i], bar_index + 30, high[i],
                     bgcolor=i_ob_bear, border_color=color.new(color.orange, 30), border_width=1)
                label.new(bar_index - i, low[i], "Bear OB",
                     style=label.style_label_up, size=size.tiny,
                     color=color.new(color.orange, 30), textcolor=color.white)
                break
 
// OB retest detection (price returns into OB zone with momentum)
bull_ob_retest = not na(bull_ob_h) and low <= bull_ob_h and close >= bull_ob_l and close > close[1]
bear_ob_retest = not na(bear_ob_h) and high >= bear_ob_l and close <= bear_ob_h and close < close[1]
 
// ═══════════════════════════════════════════════════════════════
//  LIQUIDITY SWEEPS  (equal highs/lows detected on HTF — default 15m)
// ═══════════════════════════════════════════════════════════════
 
// Pull high/low from the selected higher timeframe so equal levels
// are meaningful structure, not 1m noise
htf_high = request.security(syminfo.tickerid, i_liq_tf, high, lookahead=barmerge.lookahead_off)
htf_low  = request.security(syminfo.tickerid, i_liq_tf, low,  lookahead=barmerge.lookahead_off)
 
liq_sweep_hi = false
liq_sweep_lo = false
 
if i_liq
    thr = i_liq_thr / 100.0
    for i = 2 to i_liq_lb
        // Equal highs on HTF swept by current bar
        if not na(htf_high[i]) and not na(htf_high[i + 1])
            if math.abs(htf_high[i] - htf_high[i + 1]) / htf_high[i] < thr
                ref = math.max(htf_high[i], htf_high[i + 1])
                if high > ref and close < ref
                    liq_sweep_hi := true
 
        // Equal lows on HTF swept by current bar
        if not na(htf_low[i]) and not na(htf_low[i + 1])
            if math.abs(htf_low[i] - htf_low[i + 1]) / htf_low[i] < thr
                ref = math.min(htf_low[i], htf_low[i + 1])
                if low < ref and close > ref
                    liq_sweep_lo := true
 
    if liq_sweep_hi
        label.new(bar_index, high, "⚡ Liq Sweep", yloc=yloc.abovebar,
             style=label.style_label_down, size=size.small,
             color=color.new(color.red, 10), textcolor=color.white)
 
    if liq_sweep_lo
        label.new(bar_index, low, "⚡ Liq Sweep", yloc=yloc.belowbar,
             style=label.style_label_up, size=size.small,
             color=color.new(color.green, 10), textcolor=color.white)
 
// ═══════════════════════════════════════════════════════════════
//  ALERT CONDITIONS
//  After adding this script: click the 🔔 (Alerts) button on any
//  condition below, set "Once Per Bar Close", and route to
//  App Notifications, Email, or Webhook (for SMS via Twilio).
// ═══════════════════════════════════════════════════════════════
 
alertcondition(bull_fvg_tap,
     title   = "[ICT] 🟢 Bull FVG Tap",
     message = "NQ — Price entering Bullish FVG. Potential long setup. Check for confluence.")
 
alertcondition(bear_fvg_tap,
     title   = "[ICT] 🔴 Bear FVG Tap",
     message = "NQ — Price entering Bearish FVG. Potential short setup. Check for confluence.")
 
alertcondition(bull_ob_retest,
     title   = "[ICT] 🟦 Bull OB Retest",
     message = "NQ — Price retesting Bullish Order Block with bullish close. Watch for entry.")
 
alertcondition(bear_ob_retest,
     title   = "[ICT] 🟧 Bear OB Retest",
     message = "NQ — Price retesting Bearish Order Block with bearish close. Watch for entry.")
 
alertcondition(bull_bos and not bull_choch,
     title   = "[ICT] ↑ Bullish BOS",
     message = "NQ — Bullish Break of Structure confirmed. Bias shifts long.")
 
alertcondition(bear_bos and not bear_choch,
     title   = "[ICT] ↓ Bearish BOS",
     message = "NQ — Bearish Break of Structure confirmed. Bias shifts short.")
 
alertcondition(bull_choch,
     title   = "[ICT] 🔄 Bullish CHoCH / MSS",
     message = "NQ — Bullish Change of Character (Market Structure Shift). Possible reversal long.")
 
alertcondition(bear_choch,
     title   = "[ICT] 🔄 Bearish CHoCH / MSS",
     message = "NQ — Bearish Change of Character (Market Structure Shift). Possible reversal short.")
 
alertcondition(liq_sweep_hi,
     title   = "[ICT] ⚡ Liquidity Sweep — Highs",
     message = "NQ — Equal highs swept and rejected. Watch for reversal short / displacement down.")
 
alertcondition(liq_sweep_lo,
     title   = "[ICT] ⚡ Liquidity Sweep — Lows",
     message = "NQ — Equal lows swept and rejected. Watch for reversal long / displacement up.")
````

# ICT Confluence Entry [ES/NQ]

- url: https://www.tradingview.com/script/YpJpQ7VI-ICT-Confluence-Entry-ES-NQ/
- type: indicator
- pine_id: PUB;ae38654fc73947ec8f2070cd82d3f358
- version: 1.0

## Description

ICT trading stands for Inner Circle Trader trading, a style of trading created by Michael J. Huddleston. It’s mainly used in forex, indices, and crypto markets and focuses on understanding how large institutions (banks, hedge funds) move the market.

🧠 Core Idea of ICT Trading

ICT teaches that the market doesn’t move randomly—it’s driven by “smart money” (big players). Retail traders often lose because they trade against these institutions. ICT aims to help you trade with them instead.

📊 Key Concepts in ICT

Here are the main building blocks:

1. Market Structure
Identifying trends (higher highs/lows or lower highs/lows)
Helps you know if the market is bullish or bearish
2. Liquidity
Areas where many stop-losses are sitting
Institutions often push price to these zones to “grab liquidity”
3. Order Blocks
Zones where big institutions placed large orders
These areas often act as support/resistance
4. Fair Value Gaps (FVG)
Price imbalances where the market moved too fast
Price often comes back to “fill” these gaps
5. Kill Zones
Specific times of day (like London or New York sessions) when volatility is high
📈 Simple Example

Imagine price is rising:

Retail traders place buy orders and stop-losses below
Institutions push price down briefly to trigger those stops (liquidity grab)
Then price reverses and goes up strongly

ICT traders try to anticipate this move and enter at better prices.

⚠️ Reality Check

ICT concepts can be powerful, but:

They are complex and take time to master
Not guaranteed to work every time
Require strong discipline and risk management
👍 Who Uses ICT?
Forex traders (most common)
Crypto traders
Index traders (e.g., NASDAQ, S&P 500)

## Source Code

````pine
// ICT Confluence Entry Indicator for ES/NQ Futures
// Full build - correct IFVG, diagonal SMT, $$ at wick tip, SPX entry line with tooltip

//@version=6
indicator("ICT Confluence Entry [ES/NQ]", overlay=true, max_bars_back=500, max_lines_count=50, max_boxes_count=50, max_labels_count=50)

// ============================================================
// INPUTS
// ============================================================
grp0 = "General Settings"
show_losing   = input.bool(true,  "Show Lower Grade Setups (C/B)", group=grp0)
max_setups    = input.int(10,     "Max Setups to Display",  minval=1, maxval=50, group=grp0)
bias          = input.string("Both", "Trade Bias", options=["Both", "Long Only", "Short Only"], group=grp0)
grade_filter  = input.string("Show All", "Minimum Grade",
  options=["Show All", "C and above", "B and above", "B+ and above", "A and above", "A+ Only"], group=grp0)

grp1 = "HTF Fair Value Gaps"
show_fvg_15m  = input.bool(true,  "Show 15min FVGs", group=grp1)
show_fvg_1h   = input.bool(true,  "Show 1H FVGs",    group=grp1)
show_fvg_4h   = input.bool(true,  "Show 4H FVGs",    group=grp1)

grp2 = "Liquidity Sweep"
liq_lookback  = input.int(20, "Swing Lookback (bars)", minval=5, maxval=50, group=grp2)
min_sweep_pts = input.float(5.0, "Min Sweep Wick Size (points)", minval=1.0, group=grp2)

grp3 = "SMT Divergence"
smt_symbol    = input.symbol("CME_MINI:ES1!", "Correlated Instrument", group=grp3)
smt_lookback  = input.int(10, "SMT Lookback (bars)", minval=3, maxval=30, group=grp3)

grp4 = "IFVG Entry"
ifvg_min_size = input.float(0.25, "Min IFVG Size (points)", minval=0.0, group=grp4)
long_col      = input.color(color.new(color.blue, 0),  "Long Entry Color",  group=grp4)
short_col     = input.color(color.new(color.red,  0),  "Short Entry Color", group=grp4)
show_entry    = input.bool(true, "Show Entry Lines", group=grp4)
show_be       = input.bool(true, "Show Break Even Level", group=grp4)
show_sl       = input.bool(true, "Show Stop Loss Level",  group=grp4)

grp7 = "Killzones"
show_kz       = input.bool(true,  "Show Killzone Boxes", group=grp7)
show_kz_text  = input.bool(true,  "Display Text",        group=grp7)
kz_only       = input.bool(false, "Only Show Signals Inside Killzones", group=grp7)
asia_on       = input.bool(true,  "Asia",     group=grp7, inline="asia")
asia_sess     = input.session("1800-0200",    "", group=grp7, inline="asia")
asia_col      = input.color(color.new(color.blue,  80), "", group=grp7, inline="asia")
london_on     = input.bool(true,  "London",   group=grp7, inline="lon")
london_sess   = input.session("0200-0900",    "", group=grp7, inline="lon")
london_col    = input.color(color.new(color.red,   80), "", group=grp7, inline="lon")
ny_on         = input.bool(true,  "New York", group=grp7, inline="ny")
ny_sess       = input.session("0930-1600",    "", group=grp7, inline="ny")
ny_col        = input.color(color.new(color.green, 80), "", group=grp7, inline="ny")

grp8 = "15 EMA"
show_ema      = input.bool(true, "Show 15 EMA", group=grp8)
ema_col_bull  = input.color(color.lime, "Bullish EMA Color", group=grp8)
ema_col_bear  = input.color(color.red,  "Bearish EMA Color", group=grp8)

grp6 = "Dashboard"
show_dash     = input.bool(true, "Show Dashboard", group=grp6)
dash_pos      = input.string("Bottom Right", "Position",
  options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp6)

// ============================================================
// STYLE
// ============================================================
box_bg  = color.new(color.gray, 29)
box_bd  = color.new(color.gray, 100)
box_txt = color.black

// ============================================================
// 15 EMA
// ============================================================
ema15     = ta.ema(close, 15)
ema_color = close > ema15 ? ema_col_bull : ema_col_bear
plot(show_ema ? ema15 : na, "15 EMA", color=ema_color, linewidth=2)
above_ema = close > ema15

// ============================================================
// KILLZONES + SESSION TRACKING
// ============================================================
in_asia   = asia_on   and not na(time(timeframe.period, asia_sess,   "America/New_York"))
in_london = london_on and not na(time(timeframe.period, london_sess, "America/New_York"))
in_ny     = ny_on     and not na(time(timeframe.period, ny_sess,     "America/New_York"))
in_any_kz = in_asia or in_london or in_ny

kz_col  = in_asia ? asia_col : in_london ? london_col : in_ny ? ny_col : color.new(color.gray,95)
kz_name = in_asia ? "Asia" : in_london ? "London" : in_ny ? "New York" : "—"

var box    kz_box    = na
var string kz_active = ""

if show_kz
    if in_any_kz
        if kz_active != kz_name
            kz_box    := box.new(bar_index, high + syminfo.mintick, bar_index, low - syminfo.mintick, border_width=0, bgcolor=kz_col)
            kz_active := kz_name
        else
            box.set_right(kz_box, bar_index)
            box.set_top(kz_box, math.max(box.get_top(kz_box), high + syminfo.mintick))
            box.set_bottom(kz_box, math.min(box.get_bottom(kz_box), low - syminfo.mintick))
        if show_kz_text and barstate.islast
            box.set_text(kz_box, kz_name)
            box.set_text_color(kz_box, color.new(color.white,20))
            box.set_text_size(kz_box, size.small)
            box.set_text_halign(kz_box, text.align_left)
            box.set_text_valign(kz_box, text.align_top)
    else
        kz_active := ""

// Session high/low for TP
var float asia_high   = na
var float asia_low    = na
var float london_high = na
var float london_low  = na

if in_asia
    asia_high := na(asia_high) ? high : math.max(asia_high, high)
    asia_low  := na(asia_low)  ? low  : math.min(asia_low,  low)
if in_london
    london_high := na(london_high) ? high : math.max(london_high, high)
    london_low  := na(london_low)  ? low  : math.min(london_low,  low)
if hour(time, "America/New_York") == 18 and minute(time, "America/New_York") == 0
    asia_high   := na
    asia_low    := na
    london_high := na
    london_low  := na

tp_long  = na(asia_high) and na(london_high) ? na : na(asia_high) ? london_high : na(london_high) ? asia_high : math.max(asia_high, london_high)
tp_short = na(asia_low)  and na(london_low)  ? na : na(asia_low)  ? london_low  : na(london_low)  ? asia_low  : math.min(asia_low,  london_low)

// ============================================================
// 1. LIQUIDITY SWEEP — $$ label at TIP of wick, black line at level
// ============================================================
swing_high = ta.highest(high, liq_lookback)[1]
swing_low  = ta.lowest(low,   liq_lookback)[1]

bull_wick = swing_low - low
bear_wick = high - swing_high

raw_bull_sweep = low < swing_low  and close > swing_low and bull_wick >= min_sweep_pts
raw_bear_sweep = high > swing_high and close < swing_high and bear_wick >= min_sweep_pts

bull_sweep = raw_bull_sweep and (bias == "Both" or bias == "Long Only")
bear_sweep = raw_bear_sweep and (bias == "Both" or bias == "Short Only")

var int sweep_bars_ago = 999
sweep_bars_ago := (bull_sweep or bear_sweep) ? 0 : sweep_bars_ago + 1
confluence_sweep = sweep_bars_ago <= 15

var line  sweep_line  = na
var label sweep_label = na

if bull_sweep
    line.delete(sweep_line)
    label.delete(sweep_label)
    sweep_line  := line.new(bar_index - liq_lookback, swing_low, bar_index + 20, swing_low, color=color.black, width=1, style=line.style_solid)
    sweep_label := label.new(bar_index, low, "$$", color=color.new(color.black,100), textcolor=color.black, style=label.style_label_up, size=size.small)

if bear_sweep
    line.delete(sweep_line)
    label.delete(sweep_label)
    sweep_line  := line.new(bar_index - liq_lookback, swing_high, bar_index + 20, swing_high, color=color.black, width=1, style=line.style_solid)
    sweep_label := label.new(bar_index, high, "$$", color=color.new(color.black,100), textcolor=color.black, style=label.style_label_down, size=size.small)

// ============================================================
// 2. HTF FVG
// ============================================================
[h15, l15] = request.security(syminfo.tickerid, "15",  [high, low], lookahead=barmerge.lookahead_off)
[h1h, l1h] = request.security(syminfo.tickerid, "60",  [high, low], lookahead=barmerge.lookahead_off)
[h4h, l4h] = request.security(syminfo.tickerid, "240", [high, low], lookahead=barmerge.lookahead_off)

fvg15_bull = l15 > h15[2]
fvg15_bear = h15 < l15[2]
fvg1h_bull = l1h > h1h[2]
fvg1h_bear = h1h < l1h[2]
fvg4h_bull = l4h > h4h[2]
fvg4h_bear = h4h < l4h[2]

fvg15_bull_top = l15
fvg15_bull_bot = h15[2]
fvg15_bear_top = l15[2]
fvg15_bear_bot = h15
fvg1h_bull_top = l1h
fvg1h_bull_bot = h1h[2]
fvg1h_bear_top = l1h[2]
fvg1h_bear_bot = h1h
fvg4h_bull_top = l4h
fvg4h_bull_bot = h4h[2]
fvg4h_bear_top = l4h[2]
fvg4h_bear_bot = h4h

var box b15_bull = na
var box b15_bear = na
var box b1h_bull = na
var box b1h_bear = na
var box b4h_bull = na
var box b4h_bear = na

if show_fvg_15m and fvg15_bull
    box.delete(b15_bull)
    b15_bull := box.new(bar_index-2, fvg15_bull_top, bar_index+40, fvg15_bull_bot, border_color=box_bd, bgcolor=box_bg, text="15MIN FVG", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)
if show_fvg_15m and fvg15_bear
    box.delete(b15_bear)
    b15_bear := box.new(bar_index-2, fvg15_bear_top, bar_index+40, fvg15_bear_bot, border_color=box_bd, bgcolor=box_bg, text="15MIN FVG", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)
if show_fvg_1h and fvg1h_bull
    box.delete(b1h_bull)
    b1h_bull := box.new(bar_index-2, fvg1h_bull_top, bar_index+40, fvg1h_bull_bot, border_color=box_bd, bgcolor=box_bg, text="1H FVG", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)
if show_fvg_1h and fvg1h_bear
    box.delete(b1h_bear)
    b1h_bear := box.new(bar_index-2, fvg1h_bear_top, bar_index+40, fvg1h_bear_bot, border_color=box_bd, bgcolor=box_bg, text="1H FVG", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)
if show_fvg_4h and fvg4h_bull
    box.delete(b4h_bull)
    b4h_bull := box.new(bar_index-2, fvg4h_bull_top, bar_index+40, fvg4h_bull_bot, border_color=box_bd, bgcolor=box_bg, text="4H FVG", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)
if show_fvg_4h and fvg4h_bear
    box.delete(b4h_bear)
    b4h_bear := box.new(bar_index-2, fvg4h_bear_top, bar_index+40, fvg4h_bear_bot, border_color=box_bd, bgcolor=box_bg, text="4H FVG", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)

htf_fvg_bull = fvg15_bull or fvg1h_bull or fvg4h_bull
htf_fvg_bear = fvg15_bear or fvg1h_bear or fvg4h_bear

active_bull_top = fvg4h_bull ? fvg4h_bull_top : fvg1h_bull ? fvg1h_bull_top : fvg15_bull_top
active_bull_bot = fvg4h_bull ? fvg4h_bull_bot : fvg1h_bull ? fvg1h_bull_bot : fvg15_bull_bot
active_bear_top = fvg4h_bear ? fvg4h_bear_top : fvg1h_bear ? fvg1h_bear_top : fvg15_bear_top
active_bear_bot = fvg4h_bear ? fvg4h_bear_bot : fvg1h_bear ? fvg1h_bear_bot : fvg15_bear_bot

bull_fvg_reject = htf_fvg_bull and low <= active_bull_top and close > active_bull_top
bear_fvg_reject = htf_fvg_bear and high >= active_bear_bot and close < active_bear_bot

var int fvg_bars_ago = 999
fvg_bars_ago := (bull_fvg_reject or bear_fvg_reject) ? 0 : fvg_bars_ago + 1
confluence_fvg = fvg_bars_ago <= 10
fvg_tf_label = fvg4h_bull or fvg4h_bear ? "4H FVG" : fvg1h_bull or fvg1h_bear ? "1H FVG" : fvg15_bull or fvg15_bear ? "15m FVG" : "—"

// ============================================================
// 3. SMT — DIAGONAL line
// ============================================================
corr_low  = request.security(smt_symbol, timeframe.period, low,  lookahead=barmerge.lookahead_off)
corr_high = request.security(smt_symbol, timeframe.period, high, lookahead=barmerge.lookahead_off)

loc_low_self  = ta.lowest(low,        smt_lookback)
loc_low_corr  = ta.lowest(corr_low,   smt_lookback)
loc_high_self = ta.highest(high,      smt_lookback)
loc_high_corr = ta.highest(corr_high, smt_lookback)

smt_bull = low  == loc_low_self and corr_low  > loc_low_corr  * 0.9995
smt_bear = high == loc_high_self and corr_high < loc_high_corr * 1.0005

var int smt_bars_ago = 999
smt_bars_ago := (smt_bull or smt_bear) ? 0 : smt_bars_ago + 1
confluence_smt = smt_bars_ago <= 15

var line  smt_line  = na
var label smt_label = na

prev_low_val  = ta.lowest(low,  smt_lookback)[smt_lookback]
prev_high_val = ta.highest(high, smt_lookback)[smt_lookback]

if smt_bull
    line.delete(smt_line)
    label.delete(smt_label)
    smt_line  := line.new(bar_index - smt_lookback, prev_low_val, bar_index, low, color=color.black, width=2, style=line.style_dashed)
    smt_label := label.new(bar_index, low, "SMT", color=color.new(color.black,100), textcolor=color.black, style=label.style_label_up, size=size.small)

if smt_bear
    line.delete(smt_line)
    label.delete(smt_label)
    smt_line  := line.new(bar_index - smt_lookback, prev_high_val, bar_index, high, color=color.black, width=2, style=line.style_dashed)
    smt_label := label.new(bar_index, high, "SMT", color=color.new(color.black,100), textcolor=color.black, style=label.style_label_down, size=size.small)

// ============================================================
// 4. IFVG — candle CLOSE triggers, box drawn
// ============================================================
curr_bear_fvg_formed = high[0] < low[2] and (low[2] - high[0]) >= ifvg_min_size
curr_bull_fvg_formed = low[0]  > high[2] and (low[0] - high[2]) >= ifvg_min_size

var float stored_bear_top = na
var float stored_bear_bot = na
var float stored_bull_top = na
var float stored_bull_bot = na
var bool  bear_fvg_active = false
var bool  bull_fvg_active = false

if curr_bear_fvg_formed
    stored_bear_top := low[2]
    stored_bear_bot := high[0]
    bear_fvg_active := true

if curr_bull_fvg_formed
    stored_bull_top := low[0]
    stored_bull_bot := high[2]
    bull_fvg_active := true

// Entry: candle CLOSE above bearish FVG top = LONG
// Entry: candle CLOSE below bullish FVG bot = SHORT
bull_ifvg = bear_fvg_active and not na(stored_bear_top) and close > stored_bear_top
bear_ifvg = bull_fvg_active and not na(stored_bull_bot) and close < stored_bull_bot

if bull_ifvg
    bear_fvg_active := false
if bear_ifvg
    bull_fvg_active := false

var int ifvg_bars_ago = 999
ifvg_bars_ago := (bull_ifvg or bear_ifvg) ? 0 : ifvg_bars_ago + 1
confluence_ifvg = ifvg_bars_ago <= 3

var box ifvg_box = na

if bull_ifvg and not na(stored_bear_top)
    box.delete(ifvg_box)
    ifvg_box := box.new(bar_index-3, stored_bear_top, bar_index+10, stored_bear_bot, border_color=box_bd, bgcolor=color.new(color.blue,80), text=timeframe.period + "MIN IFVG BULL", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)

if bear_ifvg and not na(stored_bull_bot)
    box.delete(ifvg_box)
    ifvg_box := box.new(bar_index-3, stored_bull_top, bar_index+10, stored_bull_bot, border_color=box_bd, bgcolor=color.new(color.red,80), text=timeframe.period + "MIN IFVG BEAR", text_color=box_txt, text_size=size.normal, text_halign=text.align_right, text_valign=text.align_center)

// ============================================================
// 5. GRADING
// ============================================================
c_sweep = confluence_sweep
c_fvg   = confluence_fvg
c_smt   = confluence_smt
c_ifvg  = bull_ifvg or bear_ifvg

extra_count = (c_sweep ? 1 : 0) + (c_fvg ? 1 : 0) + (c_smt ? 1 : 0)

grade_aplus = c_ifvg and c_sweep and c_fvg and c_smt
grade_a     = c_ifvg and c_fvg and c_sweep and not c_smt
grade_bplus = c_ifvg and c_fvg and c_smt   and not c_sweep
grade_b     = c_ifvg and extra_count == 1
grade_c     = c_ifvg and extra_count == 0

grade_num  = grade_aplus ? 5 : grade_a ? 4 : grade_bplus ? 3 : grade_b ? 2 : grade_c ? 1 : 0
filter_min = grade_filter == "A+ Only" ? 5 : grade_filter == "A and above" ? 4 : grade_filter == "B+ and above" ? 3 : grade_filter == "B and above" ? 2 : grade_filter == "C and above" ? 1 : 0

// Hide C/B if show_losing is off
effective_min = show_losing ? filter_min : math.max(filter_min, 3)

bias_allows_long  = bias == "Both" or bias == "Long Only"
bias_allows_short = bias == "Both" or bias == "Short Only"
kz_ok        = not kz_only or in_any_kz
show_signal  = c_ifvg and grade_num >= effective_min and grade_num > 0 and kz_ok
signal_bull  = show_signal and bull_ifvg and bias_allows_long
signal_bear  = show_signal and bear_ifvg and bias_allows_short

grade_txt   = grade_aplus ? "A+" : grade_a ? "A" : grade_bplus ? "B+" : grade_b ? "B" : grade_c ? "C" : ""
grade_color = grade_aplus ? color.lime : grade_a ? color.green : grade_bplus ? color.yellow : grade_b ? color.orange : grade_c ? color.gray : color.white

// ============================================================
// 6. ENTRY LINE (SPX label) + TOOLTIP with confluences + TP/SL
// ============================================================
sl_bull = close - 40
sl_bear = close + 40
be_bull = close + 20
be_bear = close - 20

var line  entry_line = na
var label entry_lbl  = na
var line  tp_line    = na
var line  sl_line    = na
var line  be_line    = na
var label tp_label   = na
var label sl_label   = na
var int   setup_count = 0

if signal_bull or signal_bear
    if setup_count < max_setups
        setup_count += 1

        line.delete(entry_line)
        label.delete(entry_lbl)
        line.delete(tp_line)
        line.delete(sl_line)
        line.delete(be_line)
        label.delete(tp_label)
        label.delete(sl_label)

        tt = "GRADE: " + grade_txt + "\n"
        tt += "━━━━━━━━━━━━━━\n"
        tt += (c_sweep ? "✅" : "❌") + " Liquidity Sweep\n"
        tt += (c_fvg   ? "✅" : "❌") + " HTF FVG Rejection\n"
        tt += (c_smt   ? "✅" : "❌") + " SMT Divergence\n"
        tt += (c_ifvg  ? "✅" : "❌") + " IFVG Entry\n"
        tt += "━━━━━━━━━━━━━━\n"
        tt += (signal_bull ? "▲ LONG" : "▼ SHORT") + " @ " + str.tostring(close, "#.##")

        if signal_bull
            entry_line := line.new(bar_index, close, bar_index + 8, close, color=long_col, width=3, style=line.style_solid)
            entry_lbl  := label.new(bar_index, close, "SPX", color=long_col, textcolor=color.white, style=label.style_label_right, size=size.tiny, tooltip=tt)

            if show_sl
                sl_line  := line.new(bar_index, sl_bull, bar_index + 8, sl_bull, color=color.red, width=1, style=line.style_dashed)
                sl_label := label.new(bar_index + 8, sl_bull, "SL", color=color.new(color.red,100), textcolor=color.red, style=label.style_label_right, size=size.tiny)
            if show_be
                be_line  := line.new(bar_index, be_bull, bar_index + 8, be_bull, color=color.orange, width=1, style=line.style_dotted)
            if not na(tp_long)
                tp_line  := line.new(bar_index, tp_long, bar_index + 8, tp_long, color=color.green, width=1, style=line.style_dashed)
                tp_label := label.new(bar_index + 8, tp_long, "TP", color=color.new(color.green,100), textcolor=color.green, style=label.style_label_right, size=size.tiny)

        if signal_bear
            entry_line := line.new(bar_index, close, bar_index + 8, close, color=short_col, width=3, style=line.style_solid)
            entry_lbl  := label.new(bar_index, close, "SPX", color=short_col, textcolor=color.white, style=label.style_label_right, size=size.tiny, tooltip=tt)

            if show_sl
                sl_line  := line.new(bar_index, sl_bear, bar_index + 8, sl_bear, color=color.red, width=1, style=line.style_dashed)
                sl_label := label.new(bar_index + 8, sl_bear, "SL", color=color.new(color.red,100), textcolor=color.red, style=label.style_label_right, size=size.tiny)
            if show_be
                be_line  := line.new(bar_index, be_bear, bar_index + 8, be_bear, color=color.orange, width=1, style=line.style_dotted)
            if not na(tp_short)
                tp_line  := line.new(bar_index, tp_short, bar_index + 8, tp_short, color=color.green, width=1, style=line.style_dashed)
                tp_label := label.new(bar_index + 8, tp_short, "TP", color=color.new(color.green,100), textcolor=color.green, style=label.style_label_right, size=size.tiny)

bgcolor(grade_aplus and show_signal ? color.new(color.lime,92) : grade_a and show_signal ? color.new(color.green,92) : grade_bplus and show_signal ? color.new(color.yellow,92) : na)

alertcondition(signal_bull and grade_aplus, "A+ LONG",  "A+ LONG on {{ticker}} {{interval}}")
alertcondition(signal_bear and grade_aplus, "A+ SHORT", "A+ SHORT on {{ticker}} {{interval}}")
alertcondition(signal_bull and grade_a,     "A LONG",   "A LONG on {{ticker}} {{interval}}")
alertcondition(signal_bear and grade_a,     "A SHORT",  "A SHORT on {{ticker}} {{interval}}")
alertcondition(signal_bull and grade_bplus, "B+ LONG",  "B+ LONG on {{ticker}} {{interval}}")
alertcondition(signal_bear and grade_bplus, "B+ SHORT", "B+ SHORT on {{ticker}} {{interval}}")
alertcondition(signal_bull, "Any LONG",  "LONG on {{ticker}} {{interval}}")
alertcondition(signal_bear, "Any SHORT", "SHORT on {{ticker}} {{interval}}")

// ============================================================
// 7. DASHBOARD
// ============================================================
tpos = dash_pos == "Top Right" ? position.top_right : dash_pos == "Top Left" ? position.top_left : dash_pos == "Bottom Left" ? position.bottom_left : position.bottom_right
var table dash = table.new(tpos, 3, 10, bgcolor=color.new(color.black,20), border_color=color.new(color.gray,40), border_width=1, frame_color=color.new(color.white,60), frame_width=1)

if show_dash and barstate.islast
    table.cell(dash, 0, 0, "CONFLUENCE",  bgcolor=color.new(color.navy,20), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "STATUS",      bgcolor=color.new(color.navy,20), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 0, "DETAIL",      bgcolor=color.new(color.navy,20), text_color=color.white, text_size=size.small)

    sweep_bg = c_sweep ? color.new(color.green,30) : color.new(color.gray,60)
    table.cell(dash, 0, 1, "Liq Sweep",   bgcolor=color.new(color.black,40), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, c_sweep ? "✅ HIT" : "⬜ WAIT", bgcolor=sweep_bg, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 1, bull_sweep ? "Bull $$" : bear_sweep ? "Bear $$" : "—", bgcolor=color.new(color.black,60), text_color=color.silver, text_size=size.small)

    fvg_bg = c_fvg ? color.new(color.green,30) : color.new(color.gray,60)
    table.cell(dash, 0, 2, "HTF FVG",     bgcolor=color.new(color.black,40), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, c_fvg ? "✅ HIT" : "⬜ WAIT", bgcolor=fvg_bg, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 2, fvg_tf_label,  bgcolor=color.new(color.black,60), text_color=color.silver, text_size=size.small)

    smt_bg = c_smt ? color.new(color.green,30) : color.new(color.gray,60)
    table.cell(dash, 0, 3, "SMT ES/NQ",   bgcolor=color.new(color.black,40), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, c_smt ? "✅ HIT" : "⬜ WAIT", bgcolor=smt_bg, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 3, smt_bull ? "Bull Div" : smt_bear ? "Bear Div" : "—", bgcolor=color.new(color.black,60), text_color=color.silver, text_size=size.small)

    ifvg_bg = c_ifvg ? color.new(color.green,30) : color.new(color.gray,60)
    table.cell(dash, 0, 4, "IFVG Entry",  bgcolor=color.new(color.black,40), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, c_ifvg ? "✅ HIT" : "⬜ WAIT", bgcolor=ifvg_bg, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 4, bull_ifvg ? "Bull Close" : bear_ifvg ? "Bear Close" : "—", bgcolor=color.new(color.black,60), text_color=color.silver, text_size=size.small)

    ema_bg = above_ema ? color.new(color.green,30) : color.new(color.red,30)
    table.cell(dash, 0, 5, "15 EMA",      bgcolor=color.new(color.black,40), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, above_ema ? "✅ ABOVE" : "🔴 BELOW", bgcolor=ema_bg, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 5, above_ema ? "Bullish" : "Bearish", bgcolor=color.new(color.black,60), text_color=color.silver, text_size=size.small)

    kz_bg = in_any_kz ? color.new(color.green,30) : color.new(color.gray,60)
    table.cell(dash, 0, 6, "Killzone",    bgcolor=color.new(color.black,40), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, in_any_kz ? "✅ ACTIVE" : "⬜ OFF", bgcolor=kz_bg, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 6, kz_name,       bgcolor=color.new(color.black,60), text_color=color.silver, text_size=size.small)

    table.cell(dash, 0, 7, "", bgcolor=color.new(color.gray,80), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 7, "", bgcolor=color.new(color.gray,80), text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 7, "", bgcolor=color.new(color.gray,80), text_color=color.white, text_size=size.small)

    score_bg   = grade_aplus ? color.new(color.lime,10) : grade_a ? color.new(color.green,20) : grade_bplus ? color.new(color.yellow,20) : grade_b ? color.new(color.orange,30) : grade_c ? color.new(color.gray,40) : color.new(color.gray,60)
    score_icon = grade_aplus ? "🔥 TRADE" : grade_a ? "✅ TRADE" : grade_bplus ? "⚡ TRADE" : grade_b ? "👀 WATCH" : grade_c ? "⬜ WEAK" : "🔍 WAIT"
    dir_txt    = bull_ifvg and c_ifvg ? "▲ LONG" : bear_ifvg and c_ifvg ? "▼ SHORT" : "—"
    dir_col    = bull_ifvg and c_ifvg ? color.lime : bear_ifvg and c_ifvg ? color.red : color.white
    bias_col   = bias == "Long Only" ? color.lime : bias == "Short Only" ? color.red : color.yellow

    table.cell(dash, 0, 8, score_icon,    bgcolor=score_bg, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 8, "GRADE: " + (grade_txt == "" ? "—" : grade_txt), bgcolor=score_bg, text_color=grade_color, text_size=size.normal)
    table.cell(dash, 2, 8, dir_txt,       bgcolor=score_bg, text_color=dir_col, text_size=size.small)

    table.cell(dash, 0, 9, "Bias: " + bias,           bgcolor=color.new(color.black,60), text_color=bias_col,     text_size=size.tiny)
    table.cell(dash, 1, 9, "Filter: " + grade_filter, bgcolor=color.new(color.black,60), text_color=color.yellow, text_size=size.tiny)
    table.cell(dash, 2, 9, kz_only ? "KZ Only" : "All Hours", bgcolor=color.new(color.black,60), text_color=color.silver, text_size=size.tiny)
````

# Structure Break Chain (SBC) [SharpStrat]

- url: https://www.tradingview.com/script/qvGuJ01z-Structure-Break-Chain-SBC-SharpStrat/
- type: indicator
- pine_id: PUB;75f7780259294848a383dde830786544
- version: 1.0

## Description

[i][b]Structure Break Chain (SBC)[/b][/i]

Every trader has been there. You're in a trade, the trend looks healthy, and then suddenly price flips on you. You had no warning. You held too long. The trend was already breaking down you just couldn't see it clearly enough.
That's exactly what Structure Break Chain was built to solve.
SBC is a market structure tracking tool that reads how price is actually moving swing by swing, break by break and builds a real-time picture of trend health. Not with a smoothed line or a lagging oscillator, but by watching the raw structure of the market, the sequence of higher highs and lower lows that every trend is made of.

[b]What is a Break of Structure (BOS)?[/b]

In any uptrend, price makes a series of higher highs. Every time price closes above a previous swing high, that's a Break of Structure confirmation that the bull trend is still alive and continuing. In a downtrend, it's the opposite: price keeps breaking below previous swing lows.
SBC detects every single one of these breaks automatically and marks them on your chart with a labeled arrow green for bullish, red for bearish. No manual drawing. No guessing.
[image]https://www.tradingview.com/x/ro8uQX6P/[/image]
[b]What is a CHoCH (Change of Character)?[/b]

A CHoCH fires when price breaks structure in the opposite direction to the current trend for the first time. In a bull trend, that means price has just broken below a prior swing low. That single event doesn't confirm a full reversal but it's the earliest possible warning that something has changed in the market's behavior.
Most indicators won't catch this until several bars later. SBC marks it the moment it happens, in yellow so it stands out from the regular BOS signals as shown in the image below.
[image]https://www.tradingview.com/x/0K3AlJaZ/[/image]
[b]The Chain Counter[/b] 

Here's what makes SBC different from a standard structure indicator.
Every time a BOS happens in the same direction without interruption, the chain count goes up by 1. When a CHoCH happens, the chain resets to 1 and starts counting in the new direction.
A chain of 4 means price has broken structure 4 times in a row in the same direction. That's a mature, committed trend. A chain of 1 after a CHoCH means the new trend is unproven and fragile you should be cautious about entries.
A live label on the right edge of your chart shows the current chain count in real time as shown in image above. It updates every bar.

[b]Break Quality Score [/b]

When price barely scrapes past a swing level by a few ticks on low momentum, that's a very different signal from a strong, high-volume candle closing well beyond the level.
SBC scores every break as STRONG, NORMAL, or WEAK based on two factors:
[list]
[*]How far price closed beyond the broken level (relative to ATR)
[*]How large and decisive the breaking candle's body was
[/list]
STRONG breaks have brighter, more vivid label colors. WEAK breaks are dimmed and semi-transparent as shown in image below. This lets you visually filter the breaks that matter from the noise.
[image]https://www.tradingview.com/x/Pt7hwLhO/[/image]
[b]Failed BOS[/b] 

Sometimes price breaks a level, you get excited, and then it immediately reverses back inside. That's a trap and it's one of the most common ways retail traders get hurt.
SBC watches every confirmed break for the next 1-3 bars (adjustable). If price closes back inside the broken level within that window, the indicator marks it as a FAILED break in purple as shown in image above. This is your earliest possible warning that the breakout wasn't real, often appearing few bars before the CHoCH confirms the reversal.
Using Failed BOS + CHoCH together gives you two layers of confirmation before you act on a potential trend change.

[b]Pullback Entry Zones[/b]

After every confirmed BOS, SBC draws a semi-transparent box between the broken level and the previous swing reference as shown in image below. This is the area where price is most likely to pull back before continuing in the trend direction, the optimal entry zone.
The box extends forward by a user defined number of bars and disappears automatically when a new BOS or CHoCH occurs.
[image]https://www.tradingview.com/x/PZwJFwpL/[/image]
[b]Multi-Timeframe Overlay[/b]

You can optionally enable a higher timeframe (HTF) structure overlay. When turned on, SBC also tracks BOS and CHoCH events from your chosen higher timeframe and plots them directly on your current chart as dimmed labels as shown in image above, so you always know what the bigger picture is doing.
Note: HTF labels are designed to appear only once per HTF bar, not on every sub-bar. So on a 15-minute chart with a 1-hour HTF, you'll see the HTF label appear once on the first 15-minute candle of that hour not repeated across all four candles.
The dashboard also shows whether your current timeframe trend and the HTF trend are aligned or in conflict. Trading a bull BOS on the 15-minute chart while the 1-hour is bearish is a generally riskier than when both are pointing in same direction.

[b]The Dashboard Panel[/b]

A compact information table sits in the corner of your chart (position is adjustable). It shows everything at a glance without you having to read the price action:
[list]
[*]Current trend direction (Bullish / Bearish / Neutral)
[*]Live chain count
[*]Quality of the last break (STRONG / NORMAL / WEAK)
[*]HTF direction and alignment status
[*]HTF chain count
[*]Maximum chain ever recorded on this chart
[*]Average chain length across all completed trends
[*]Total BOS count
[*]Total CHoCH count
[/list]
The chain count in the table turns yellow when it reaches your milestone number (customizable in settings) a visual nudge that the trend is mature.

[b]How to use SBC[/b]
[list=1]
[*]Wait for a CHoCH, this is your signal that the previous trend is over and a new one may be starting. Don't trade it immediately.
[*]Watch the first BOS in the new direction if it's STRONG quality, that's confirmation the new trend has real momentum behind it.
[*]Look for a pullback into the entry zone, the green or red dashed box SBC draws is your optimal entry area.
[*]Check the chain count, if you're entering at chain count 1 you're probably early. If you're entering at 6 or 7 the trend is probably mature and a reversal is likely so adjust your expectations accordingly.
[*]Check HTF alignment, if both your timeframe and the higher timeframe are showing the same direction, the trade has more conviction behind it.
[*]Watch for Failed BOS and CHoCH these are your exit warnings. A Failed BOS followed by a CHoCH is a reliable signal to close or tighten your stop.
[/list]

[b]Settings guide[/b]

[i]Structure settings[/i]
[list]
[*]Pivot Length - how many bars left and right are needed to confirm a swing high or low. Higher values = fewer but cleaner pivots.
[*]BOS Confirmation - "Close" waits for a candle to close beyond the level (safer, recommended). "High/Low" triggers on the wick (faster but noisier).
[*]Failed BOS Window - how many bars after a break to watch for failure.
[*]Show Swing Lines - draws dashed horizontal lines at each detected pivot.
[*]Show Pullback Entry Zones - draws the dashed box after each BOS.
[*]Zone Extend Right - how far the zone box extends to the right in bars.
[*]Shade Trend Background - adds a background color based on current trend direction. 
[/list]
[i]Visual settings[/i]
[list]
[*]Full color customization for Bull, Bear, CHoCH, Failed BOS, and Swing Lines.
[*]Toggle quality labels, chain bubble, and dashboard panel on/off.
[*]Choose dashboard position (Top Right / Top Left / Bottom Right / Bottom Left).
[*]Adjust label size.
[/list]
[i]Multi-timeframe settings[/i]
[list]
[*]Enable or disable HTF overlay.
[*]Choose any HTF timeframe.
[*]Adjust HTF label transparency.
[/list]

[b]Why this is better than basic Structure break indicators[/b] 
Most structure indicators on TradingView detect BOS and CHoCH but stop there. SBC adds three things:
[list=1]
[*]A chain counter that tracks consecutive structural breaks turning raw signals into a measure of trend maturity and health over time.
[*]A break quality scoring system that grades every break on two factors so you aren't chasing noise.
[*]A Failed BOS detector that watches the confirmed break for the next few bars and warns you before the CHoCH even happens giving you a head start that most traders don't have.
[/list]
Note - Works on all markets and timeframes. Stocks, forex, crypto, indices, futures etc, if it has candles SBC probably works on it. The pivot length and ATR based quality scoring adapt automatically to the volatility of whatever asset you apply it to.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SharpStrat
//@version=6
indicator("Structure Break Chain [SBC]", shorttitle="SBC", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

//  INPUT

GS = "Structure "
GV = "Visuals"
GM = "Multi-Timeframe"
GA = "Alerts"

i_pivot_len = input.int   (15, "Pivot Length",minval=2, maxval=100, group=GS,  tooltip="Bars left + right to confirm a swing pivot.\nLower = more signals. Higher = cleaner.")
i_confirm  = input.string("Close", "BOS Confirmation", options=["Close","High/Low"], group=GS, tooltip="Close = wait for candle close beyond level.\nHigh/Low = confirm on wick (faster, noisier).")
i_fail_win  = input.int   (3, "Failed BOS Window (bars)",  minval=0, maxval=100, group=GS, tooltip="If price closes back inside the broken level within N bars, mark as FAILED.")
i_show_swings = input.bool  (true,"Show Swing Level Lines",  group=GS)
i_show_zones= input.bool  (true,"Show Pullback Entry Zones", group=GS)
i_zone_ext = input.int   (20, "Zone Extend Right (bars)", minval=1, maxval=100, group=GS)
i_show_bg = input.bool  (false, "Shade Trend Background", group=GS)

i_bull_col = input.color (#00e676, "Bull Color", group=GV)
i_bear_col= input.color (#ff1744, "Bear Color", group=GV)
i_choch_col = input.color (#ffab00, "CHoCH Color",  group=GV)
i_fail_col = input.color (#d500f9, "Failed BOS Color", group=GV)
i_swing_col= input.color (#455a64, "Swing Line Color", group=GV)
i_show_qual = input.bool  (true, "Show Break Quality on Labels", group=GV)
i_show_chain = input.bool  (true,"Show Chain Counter Bubble",  group=GV)
i_show_dash = input.bool  (true,"Show Dashboard Panel",   group=GV)
i_dash_pos = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GV)
i_lbl_size = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large"], group=GV)

i_htf_on = input.bool  (false, "Enable HTF Structure Overlay", group=GM)
i_htf_tf  = input.timeframe ("D",   "HTF Timeframe",  group=GM)
i_htf_alpha = input.int (55, "HTF Label Transparency", minval=20, maxval=90, group=GM)

i_alrt_strong = input.bool(false, "Alert: Strong Quality BOS Only", group=GA, tooltip="When ON, BOS alert fires only on STRONG quality breaks.")
i_milestone = input.int (5, "Alert: Chain Milestone", minval=2, maxval=20, group=GA, tooltip="Fire alert when chain count reaches this number.")

//  LOOKUPS

LBL_SZ = switch i_lbl_size
    "Tiny"  => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    => size.small

DASH_POS = switch i_dash_pos
    "Top Left"  => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    =>  position.top_right

//  PIVOT DETECTION

ph = ta.pivothigh(high, i_pivot_len, i_pivot_len)
pl = ta.pivotlow (low,  i_pivot_len, i_pivot_len)

var float sh  = na
var int sh_bar = na
var float prev_sh = na
var float sl  = na
var int sl_bar = na
var float prev_sl= na

if not na(ph)
    prev_sh := sh
    sh := ph
    sh_bar := bar_index - i_pivot_len

if not na(pl)
    prev_sl := sl
    sl := pl
    sl_bar := bar_index - i_pivot_len

//  PERSISTENT STATE

var int trend  = 0
var int chain_cnt = 0
var float bos_lvl = na
var int bos_bar = na
var float bos_prev = na

var bool chk_fail = false
var float fail_lvl = na
var int fail_dir = 0
var int fail_time = 0

var int tot_bos = 0
var int tot_choch = 0
var int max_chain = 0
var int n_chains = 0
var float sum_chains = 0.0
var string last_qual = "—"

// HELPERS

atr_val = math.max(nz(ta.atr(14), 0.001), 0.001)
int chain0 = chain_cnt
ref_hi = i_confirm == "Close" ? close : high
ref_lo = i_confirm == "Close" ? close : low

f_qual(dist) =>
    d_r = dist / atr_val
    b_r = math.abs(close - open) / atr_val
    s = d_r * 0.6 + b_r * 0.4
    s >= 0.75 ? "STRONG" : s >= 0.35 ? "NORMAL" : "WEAK"

//  SIGNALS

bool bos_up = false
bool bos_dn  = false
bool choch_up = false
bool choch_dn = false
bool sig_fail = false
string qual = "NORMAL"

// STRUCTURE LOGIC

if not na(sh) and ref_hi > sh
    qual := f_qual(ref_hi - sh)
    if trend == -1
        choch_up := true
        chain_cnt := 1
        tot_choch += 1
    else
        bos_up  := true
        chain_cnt := trend == 0 ? 1 : chain_cnt + 1
        tot_bos  += 1
    trend  := 1
    bos_lvl := sh
    bos_bar := sh_bar
    bos_prev := prev_sh
    chk_fail := true
    fail_lvl := sh
    fail_dir := 1
    fail_time := bar_index
    sh := na
    if chain_cnt > max_chain
        max_chain := chain_cnt

// Bearish break
if not na(sl) and ref_lo < sl and not (bos_up or choch_up)
    qual := f_qual(sl - ref_lo)
    if trend == 1
        choch_dn := true
        chain_cnt := 1
        tot_choch += 1
    else
        bos_dn := true
        chain_cnt := trend == 0 ? 1 : chain_cnt + 1
        tot_bos += 1
    trend := -1
    bos_lvl := sl
    bos_bar := sl_bar
    bos_prev := prev_sl
    chk_fail := true
    fail_lvl := sl
    fail_dir := -1
    fail_time := bar_index
    sl := na
    if chain_cnt > max_chain
        max_chain := chain_cnt

// Failed BOS check
if chk_fail and not (bos_up or bos_dn or choch_up or choch_dn)
    int elapsed = bar_index - fail_time
    if elapsed > 0 and elapsed <= i_fail_win
        if fail_dir == 1 and close < fail_lvl
            sig_fail := true
            chk_fail := false
        else if fail_dir == -1 and close > fail_lvl
            sig_fail := true
            chk_fail := false
    if elapsed > i_fail_win
        chk_fail := false

//  STATISTICS

if choch_up or choch_dn
    if chain0 > 0
        n_chains += 1
        sum_chains += float(chain0)

if bos_up or bos_dn or choch_up or choch_dn
    last_qual := qual

//  SWING LINES

if i_show_swings
    if not na(ph)
        line.new(bar_index - i_pivot_len, ph, bar_index, ph, color=color.new(i_swing_col, 35), width=1, style=line.style_dashed)
    if not na(pl)
        line.new(bar_index - i_pivot_len, pl, bar_index, pl, color=color.new(i_swing_col, 35), width=1, style=line.style_dashed)

// LABELS

lbl_off = atr_val * 0.7

if bos_up
    alp = qual == "STRONG" ? 0 : qual == "NORMAL" ? 28 : 60
    txt_col = color.new(i_bull_col, alp)
    lbl_txt = i_show_qual ? "▲ BOS  " + qual : "▲ BOS"
    label.new(bar_index, low - lbl_off, lbl_txt, color=color.new(i_bull_col, 82), textcolor=txt_col, style=label.style_label_up, size=LBL_SZ)

if bos_dn
    alp = qual == "STRONG" ? 0 : qual == "NORMAL" ? 28 : 60
    txt_col = color.new(i_bear_col, alp)
    lbl_txt = i_show_qual ? "▼ BOS  " + qual : "▼ BOS"
    label.new(bar_index, high + lbl_off, lbl_txt, color=color.new(i_bear_col, 82), textcolor=txt_col, style=label.style_label_down, size=LBL_SZ)

if choch_up
    label.new(bar_index, low - lbl_off * 1.6, "▲ CHoCH", color=color.new(i_choch_col, 78), textcolor=i_choch_col, style=label.style_label_up, size=LBL_SZ)

if choch_dn
    label.new(bar_index, high + lbl_off * 1.6, "▼ CHoCH",color=color.new(i_choch_col, 78), textcolor=i_choch_col, style=label.style_label_down, size=LBL_SZ)

if sig_fail
    label.new(bar_index, high + lbl_off * 2.4, "✗ FAILED", color=color.new(i_fail_col, 78), textcolor=i_fail_col, style=label.style_label_down, size=LBL_SZ)

//  CHAIN COUNTER

var label chain_lbl = na

if i_show_chain and barstate.islast
    label.delete(chain_lbl)
    lc  = trend == 1 ? i_bull_col : trend == -1 ? i_bear_col : color.new(#90a4ae, 0)
    sym = trend == 1 ? "▲" : trend == -1 ? "▼" : "—"
    cy  = trend == 1 ? low  - atr_val * 3.2 : high + atr_val * 3.2
    sty = trend == 1 ? label.style_label_up : label.style_label_down
    chain_lbl := label.new(bar_index, cy, sym + "  " + str.tostring(chain_cnt) + " chain", color=color.new(lc, 80), textcolor=lc, style=sty, size=size.normal)

//  PULLBACK ENTRY ZONES

var box zone_box = na

if i_show_zones
    if (bos_up or choch_up) and not na(bos_lvl)
        box.delete(zone_box)
        zt = bos_lvl
        zb = not na(bos_prev) and bos_prev < bos_lvl ? bos_prev : bos_lvl - atr_val * 1.5
        zb := math.min(zb, zt - atr_val * 0.4)
        zone_box := box.new(bos_bar, zt, bar_index + i_zone_ext, zb,
             border_color=color.new(i_bull_col, 62),
             bgcolor=color.new(i_bull_col, 90),
             border_width=1, border_style=line.style_dashed,
             text="  entry zone", text_size=size.tiny,
             text_color=color.new(i_bull_col, 45),
             text_halign=text.align_left, text_valign=text.align_bottom)

    if (bos_dn or choch_dn) and not na(bos_lvl)
        box.delete(zone_box)
        zb = bos_lvl
        zt = not na(bos_prev) and bos_prev > bos_lvl ? bos_prev : bos_lvl + atr_val * 1.5
        zt := math.max(zt, zb + atr_val * 0.4)
        zone_box := box.new(bos_bar, zt, bar_index + i_zone_ext, zb,
             border_color=color.new(i_bear_col, 62),
             bgcolor=color.new(i_bear_col, 90),
             border_width=1, border_style=line.style_dashed,
             text="  entry zone", text_size=size.tiny,
             text_color=color.new(i_bear_col, 45),
             text_halign=text.align_left, text_valign=text.align_top)

//  TREND BACKGROUND

bg_col = trend == 1 ? color.new(i_bull_col, 96) : trend == -1 ? color.new(i_bear_col, 96) : na
bgcolor(i_show_bg ? bg_col : na, title="Trend Background")

//  MULTI-TIMEFRAME

htf_trend = request.security(syminfo.tickerid, i_htf_tf, trend, lookahead=barmerge.lookahead_off)
htf_chain = request.security(syminfo.tickerid, i_htf_tf, chain_cnt, lookahead=barmerge.lookahead_off)
htf_b_bos = request.security(syminfo.tickerid, i_htf_tf, bos_up, lookahead=barmerge.lookahead_off)
htf_s_bos = request.security(syminfo.tickerid, i_htf_tf, bos_dn, lookahead=barmerge.lookahead_off)
htf_choch = request.security(syminfo.tickerid, i_htf_tf, choch_up or choch_dn, lookahead=barmerge.lookahead_off)
htf_baridx = request.security(syminfo.tickerid, i_htf_tf, bar_index, lookahead=barmerge.lookahead_off)

new_htf_bar = ta.change(htf_baridx) != 0

htf_aligned = (trend == 1 and htf_trend == 1) or (trend == -1 and htf_trend == -1)

if i_htf_on and new_htf_bar
    ha = i_htf_alpha
    if htf_b_bos
        label.new(bar_index, low  - atr_val * 5.0, "HTF ▲ BOS", color=color.new(i_bull_col, ha + 15), textcolor=color.new(i_bull_col, ha),style=label.style_label_up, size=size.small)
    if htf_s_bos
        label.new(bar_index, high + atr_val * 5.0, "HTF ▼ BOS",color=color.new(i_bear_col, ha + 15), textcolor=color.new(i_bear_col, ha),style=label.style_label_down, size=size.small)
    if htf_choch
        label.new(bar_index, high + atr_val * 6.2, "HTF CHoCH",color=color.new(i_choch_col, ha + 15), textcolor=color.new(i_choch_col, ha),style=label.style_label_down, size=size.small)

//  DASHBOARD 

var table dash_table = table.new(DASH_POS, 2, 11, bgcolor=color.new(#0d1117, 8), border_color=color.new(#2d333b, 0), border_width=1, frame_color=color.new(#388bfd, 55), frame_width=1)

if i_show_dash and barstate.islast
    BG0 = color.new(#161b27, 0)
    BG1 = color.new(#0d1117, 0)
    BG2 = color.new(#101520, 0)
    DIM = color.new(#8b949e, 0)
    WHT = color.new(#e6edf3, 0)

    table.cell(dash_table, 0, 0, "  ◈  Structure Break Chain  ", text_color=WHT, bgcolor=BG0, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash_table, 0, 0, 1, 0)

    t_str = trend == 1 ? "▲  BULLISH" : trend == -1 ? "▼  BEARISH" : "—  NEUTRAL"
    t_col = trend == 1 ? i_bull_col : trend == -1 ? i_bear_col : DIM
    table.cell(dash_table, 0, 1, "  Direction", text_color=DIM,  bgcolor=BG1, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 1, t_str + "  ", text_color=t_col, bgcolor=BG1, text_size=size.normal, text_halign=text.align_right)

    chain_col = chain_cnt >= i_milestone ? color.new(#ffab00, 0) : chain_cnt >= 3 ? WHT : DIM
    table.cell(dash_table, 0, 2, "  Chain", text_color=DIM, bgcolor=BG2, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 2, str.tostring(chain_cnt) + " BOS  ", text_color=chain_col, bgcolor=BG2, text_size=size.normal, text_halign=text.align_right)

    q_col = last_qual == "STRONG" ? color.new(#00e676, 0) : last_qual == "NORMAL" ? color.new(#ffab00, 0) : last_qual == "WEAK" ? color.new(#ff5252, 0) : DIM
    table.cell(dash_table, 0, 3, "  Last BOS", text_color=DIM, bgcolor=BG1, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 3, last_qual + "  ", text_color=q_col, bgcolor=BG1, text_size=size.normal, text_halign=text.align_right)

    htf_d_str = i_htf_on ? (htf_trend == 1 ? "▲  BULLISH" : htf_trend == -1 ? "▼  BEARISH" : "—  NEUTRAL") : "—  OFF"
    htf_d_col = i_htf_on ? (htf_trend == 1 ? i_bull_col : htf_trend == -1 ? i_bear_col : DIM) : DIM
    table.cell(dash_table, 0, 4, "  HTF (" + i_htf_tf + ")", text_color=DIM,bgcolor=BG2, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 4, htf_d_str + "  ",text_color=htf_d_col, bgcolor=BG2, text_size=size.normal, text_halign=text.align_right)

    al_str = i_htf_on ? (htf_aligned ? "✓  ALIGNED" : "✗  CONFLICT") : "—"
    al_col = i_htf_on ? (htf_aligned ? i_bull_col  : i_bear_col): DIM
    table.cell(dash_table, 0, 5, "  HTF Align",  text_color=DIM,bgcolor=BG1, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 5, al_str + "  ",  text_color=al_col, bgcolor=BG1, text_size=size.normal, text_halign=text.align_right)

    hc_str = i_htf_on ? str.tostring(htf_chain) + " BOS" : "—"
    table.cell(dash_table, 0, 6, "  HTF Chain",text_color=DIM, bgcolor=BG2, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 6, hc_str + "  ", text_color=DIM, bgcolor=BG2, text_size=size.normal, text_halign=text.align_right)

    table.cell(dash_table, 0, 7, "  Max Chain",text_color=DIM, bgcolor=BG1, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 7, str.tostring(max_chain) + "  ",  text_color=WHT, bgcolor=BG1, text_size=size.normal, text_halign=text.align_right)

    avg_chain = n_chains > 0 ? sum_chains / float(n_chains) : 0.0
    avGStr  = n_chains > 0 ? str.tostring(math.round(avg_chain, 1)) : "—"
    table.cell(dash_table, 0, 8, "  Avg Chain", text_color=DIM, bgcolor=BG2, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 8, avGStr + "  ", text_color=DIM, bgcolor=BG2, text_size=size.normal, text_halign=text.align_right)

    table.cell(dash_table, 0, 9, "  Total BOS",text_color=DIM, bgcolor=BG1, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 9, str.tostring(tot_bos) + "  ", text_color=DIM, bgcolor=BG1, text_size=size.normal, text_halign=text.align_right)

    table.cell(dash_table, 0, 10, "  CHoCH Count",text_color=DIM,bgcolor=BG2, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash_table, 1, 10, str.tostring(tot_choch) + "  ", text_color=color.new(i_choch_col, 0), bgcolor=BG2, text_size=size.normal, text_halign=text.align_right)

//  plots

plot(trend, "Trend (1=Bull | -1=Bear | 0=Neutral)", display=display.data_window)
plot(chain_cnt, "Chain Count",display=display.data_window)
plot(tot_bos,"Total BOS",display=display.data_window)
plot(tot_choch, "Total CHoCH",display=display.data_window)

//  ALERTS

bool a_bull_bos= bos_up  and (not i_alrt_strong or qual == "STRONG")
bool a_bear_bos= bos_dn  and (not i_alrt_strong or qual == "STRONG")
bool a_choch= choch_up or choch_dn
bool a_failed= sig_fail
bool a_milestone = (bos_up or bos_dn) and chain_cnt == i_milestone
bool a_str_bull  = bos_up  and qual == "STRONG"
bool a_str_bear = bos_dn  and qual == "STRONG"

alertcondition(a_bull_bos,title="▲ Bullish BOS",message="SBC ▲ Bullish Break of Structure detected.")
alertcondition(a_bear_bos,title="▼ Bearish BOS",message="SBC ▼ Bearish Break of Structure detected.")
alertcondition(a_choch,title="⚡ CHoCH — Trend Change", message="SBC ⚡ Change of Character — trend may be reversing.")
alertcondition(a_failed,title="✗ Failed BOS",message="SBC ✗ Failed Break of Structure — level was rejected.")
alertcondition(a_milestone, title="🔥 Chain Milestone",message="SBC 🔥 Chain milestone reached.")
alertcondition(a_str_bull,title="💪 Strong Bullish BOS",message="SBC 💪 STRONG quality Bullish BOS confirmed.")
alertcondition(a_str_bear,title="💪 Strong Bearish BOS",message="SBC 💪 STRONG quality Bearish BOS confirmed.")
````

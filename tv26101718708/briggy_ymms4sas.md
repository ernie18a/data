# Briggy

- url: https://www.tradingview.com/script/ymMs4saS-Briggy/
- type: indicator
- pine_id: PUB;2c2c2fffc2a8422a9646167f5782840a
- version: 1.0

## Description

Signals divergences using MCB data

Mapping data sources in settings

SE is Snake Eyes entry, recommend changing to setting to momentum cross(safer) instead of curl up

Use session filter for noise on chart

R multiplier set to 1, I turn off the display for targets/sl as they sometimes glitch

SL hit symbol on chart defaults to absolute for some reason.

Meant to be used on 30 second but can prob be adjusted for higher time frames

The whole point is to capitalize on momentum crossing 0 with confluence max hold time of a couple min unless a runner is used. 

Something to keep in mind is a perfect long setup can often be just as good as a short, so obviously look both ways. 

HUD displays stuff and can be turned off

## Source Code

````pine
//@version=6
indicator("MCB 2-Dot Momentum Cross + Divs & Sessions", shorttitle="MCB SE + HUD Options", overlay=true)

// =========================================================================
// --- 1. DIRECT DATA MAPPING ---
// =========================================================================
grp_map = "MCB Direct Mapping"
mcb_big_buy = input.source(close, "1. Map: MCB Buy", group=grp_map)
mcb_wt1     = input.source(close, "2. Map: MCB Momentum (WT1)", group=grp_map)

grp_settings = "Signal Settings"
min_dots     = input.int(2, "Minimum Dots Required", group=grp_settings)
trigger_type = input.string("Momentum Curl Up", "Momentum Cross Type", options=["Momentum Curl Up", "Zero Line Cross"], group=grp_settings)

grp_risk = "Risk & Reward Target"
rr_ratio = input.float(2.0, "Risk/Reward Ratio (Multiplier)", step=0.1, group=grp_risk, tooltip="Calculates your Target based on the distance to your Stop Loss. Example: 2.0 means your target is 2x your risk.")

// =========================================================================
// --- 2. SESSION FILTERS ---
// =========================================================================
grp_sessions = "Session Filters"
filter_signals = input.bool(true, "Require ALL Signals to be in Session?", group=grp_sessions, tooltip="If true, SnakeEyes AND Divergences will only plot/alert during your active colored blocks.")

use_sess1   = input.bool(true, "Enable Session 1", group=grp_sessions)
sess1_time  = input.session("0630-1300", "Session 1 Time", group=grp_sessions)
sess1_color = input.color(color.new(color.blue, 90), "Session 1 Background", group=grp_sessions)

use_sess2   = input.bool(false, "Enable Session 2", group=grp_sessions)
sess2_time  = input.session("0300-0800", "Session 2 Time", group=grp_sessions)
sess2_color = input.color(color.new(color.purple, 90), "Session 2 Background", group=grp_sessions)

in_sess1 = use_sess1 ? not na(time(timeframe.period, sess1_time)) : false
in_sess2 = use_sess2 ? not na(time(timeframe.period, sess2_time)) : false
is_valid_session = (use_sess1 == false and use_sess2 == false) ? true : (in_sess1 or in_sess2)

bgcolor(in_sess1 ? sess1_color : na, title="Session 1 BG")
bgcolor(in_sess2 ? sess2_color : na, title="Session 2 BG")

// =========================================================================
// --- 3. STATE TRACKING (DOTS & LOWS) ---
// =========================================================================
var int dot_count = 0
var float lowest_mom = na
var float sl_price = na
var float active_sl = na
var float active_tp = na

is_big_dot = not na(mcb_big_buy) and mcb_big_buy != mcb_big_buy[1]
is_under_zero = mcb_wt1 < 0

if ta.crossover(mcb_wt1, 0) and dot_count < min_dots
    dot_count := 0
    lowest_mom := na
    sl_price := na

if ta.crossunder(mcb_wt1, 0)
    dot_count := 0
    lowest_mom := na
    sl_price := na
    active_sl := na 
    active_tp := na

if is_under_zero
    if is_big_dot
        dot_count += 1
        
    if na(lowest_mom) or mcb_wt1 < lowest_mom
        lowest_mom := mcb_wt1
        sl_price := low 

// =========================================================================
// --- 4. TRIGGER LOGIC ---
// =========================================================================
bool wt1_curls_up   = mcb_wt1 > mcb_wt1[1] and mcb_wt1[1] < mcb_wt1[2]
bool wt1_cross_zero = ta.crossover(mcb_wt1, 0)

bool trigger_condition = trigger_type == "Zero Line Cross" ? wt1_cross_zero : wt1_curls_up

// Base Signal
bool fire_signal_base = dot_count >= min_dots and trigger_condition and (trigger_type == "Zero Line Cross" ? true : is_under_zero)

// Apply Master Session Filter to Entry Signal
bool fire_signal = filter_signals ? (fire_signal_base and is_valid_session) : fire_signal_base

// =========================================================================
// --- 5. DIVERGENCE FINDER & LINES ---
// =========================================================================
grp_div = "Divergence Finder"
show_div       = input.bool(true, "Show Regular Divergences", group=grp_div)
show_div_lines = input.bool(true, "Draw Divergence Lines", group=grp_div)
lbL            = input.int(5, "Pivot Lookback Left", group=grp_div)
lbR            = input.int(5, "Pivot Lookback Right", group=grp_div)
max_div_bars   = input.int(60, "Max Bars for Divergence", group=grp_div)

plFound = not na(ta.pivotlow(mcb_wt1, lbL, lbR))
phFound = not na(ta.pivothigh(mcb_wt1, lbL, lbR))

bars_since_pl = ta.barssince(plFound[1])
bars_since_ph = ta.barssince(phFound[1])
valid_pl_range = not na(bars_since_pl) and bars_since_pl >= 1 and bars_since_pl <= max_div_bars
valid_ph_range = not na(bars_since_ph) and bars_since_ph >= 1 and bars_since_ph <= max_div_bars

prev_pl_price = ta.valuewhen(plFound, low[lbR], 1)
prev_pl_bar   = ta.valuewhen(plFound, bar_index[lbR], 1)
prev_ph_price = ta.valuewhen(phFound, high[lbR], 1)
prev_ph_bar   = ta.valuewhen(phFound, bar_index[lbR], 1)

// Base Divergence Logic
price_LL = low[lbR] < prev_pl_price
wt1_HL   = mcb_wt1[lbR] > ta.valuewhen(plFound, mcb_wt1[lbR], 1)
bullDiv_base  = show_div and plFound and price_LL and wt1_HL and valid_pl_range

price_HH = high[lbR] > prev_ph_price
wt1_LH   = mcb_wt1[lbR] < ta.valuewhen(phFound, mcb_wt1[lbR], 1)
bearDiv_base  = show_div and phFound and price_HH and wt1_LH and valid_ph_range

// Apply Master Session Filter to Divergences (Checking if the pivot itself was in session)
bool sess_at_pivot = is_valid_session[lbR]
bullDiv = filter_signals ? (bullDiv_base and sess_at_pivot) : bullDiv_base
bearDiv = filter_signals ? (bearDiv_base and sess_at_pivot) : bearDiv_base


if bullDiv and show_div_lines
    line.new(prev_pl_bar, prev_pl_price, bar_index[lbR], low[lbR], color=color.new(color.green, 0), style=line.style_dotted, width=2)

if bearDiv and show_div_lines
    line.new(prev_ph_bar, prev_ph_price, bar_index[lbR], high[lbR], color=color.new(color.red, 0), style=line.style_dotted, width=2)


// =========================================================================
// --- 6. LIVE TRADE TRACKER & HUD CONFIG ---
// =========================================================================
grp_hud = "Live Trade HUD"
show_hud   = input.bool(true, "Show Entire Live Trade HUD", group=grp_hud)
hud_pos_in = input.string(position.bottom_right, "HUD Position", options=[position.top_right, position.bottom_right, position.bottom_left, position.top_left], group=grp_hud)

grp_hud_items = "HUD Item Filters"
show_hud_status = input.bool(true, "1. Show Status", group=grp_hud_items)
show_hud_pnl    = input.bool(true, "2. Show PnL", group=grp_hud_items)
show_hud_risk   = input.bool(true, "3. Show Risk Amount", group=grp_hud_items)
show_hud_reward = input.bool(true, "4. Show Target & Reward", group=grp_hud_items)
show_hud_runup  = input.bool(true, "5. Show Peak Runup", group=grp_hud_items)
show_hud_dd     = input.bool(true, "6. Show Max Drawdown", group=grp_hud_items)
show_hud_entry  = input.bool(true, "7. Show Entry Price", group=grp_hud_items)
show_hud_atr    = input.bool(true, "8. Show Live ATR", group=grp_hud_items)

var bool in_trade = false
var float entry_price = na
var float max_runup = 0.0
var float max_drawdown = 0.0
var float live_pnl = 0.0
var float trade_risk = 0.0
var float trade_reward = 0.0

// STRICT KILL SWITCHES (Stop Loss and Target)
bool stopped_out = false
bool target_hit  = false

if in_trade and not na(active_sl) and low <= active_sl
    in_trade := false
    stopped_out := true
    live_pnl := active_sl - entry_price // Lock PnL exactly at the Stop Loss price
else if in_trade and not na(active_tp) and high >= active_tp
    in_trade := false
    target_hit := true
    live_pnl := active_tp - entry_price // Lock PnL exactly at the Target price

// New Entry Override
if fire_signal
    active_sl := sl_price // Lock in the structural momentum low SL
    dot_count := 0 
    lowest_mom := na
    
    in_trade := true
    entry_price := close 
    max_runup := 0.0
    max_drawdown := 0.0
    live_pnl := 0.0
    
    // Calculate Risk & Target
    trade_risk := math.max(0, entry_price - active_sl)
    trade_reward := trade_risk * rr_ratio
    active_tp := entry_price + trade_reward

// Update trackers ONLY while in a live trade
if in_trade
    live_pnl := close - entry_price
    if (high - entry_price) > max_runup
        max_runup := (high - entry_price)
    if (entry_price - low) > max_drawdown
        max_drawdown := (entry_price - low)

// -------------------------------------------------------------------------
// --- DYNAMIC HUD RENDERING ENGINE ---
// -------------------------------------------------------------------------
atr_val = ta.atr(14)

var table hud = table.new(hud_pos_in, 2, 10, bgcolor=color.new(color.black, 60), border_width=1, border_color=color.new(color.gray, 80))

if barstate.islast and show_hud
    table.clear(hud, 0, 0, 1, 9) // Clear all cells to cleanly process toggles

    table.cell(hud, 0, 0, "LIVE SE STATUS", text_color=color.white, text_halign=text.align_center, text_size=size.small, bgcolor=color.new(color.blue, 70))
    table.merge_cells(hud, 0, 0, 1, 0)
    
    int r = 1 // Dynamic Row Counter
    
    if show_hud_status
        table.cell(hud, 0, r, "Status", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, in_trade ? "ACTIVE 🟢" : "FLAT ⚪", text_color=in_trade ? color.lime : color.gray, text_halign=text.align_right, text_size=size.small)
        r += 1
        
    if show_hud_pnl
        table.cell(hud, 0, r, "PnL (Pts)", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, (live_pnl > 0 ? "+" : "") + str.tostring(math.round(live_pnl, 2)), text_color=in_trade ? (live_pnl >= 0 ? color.lime : color.red) : (live_pnl >= 0 ? color.new(color.lime, 40) : color.new(color.red, 40)), text_halign=text.align_right, text_size=size.small)
        r += 1
        
    if show_hud_risk
        table.cell(hud, 0, r, "Risk (Pts)", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, str.tostring(math.round(trade_risk, 2)), text_color=color.orange, text_halign=text.align_right, text_size=size.small)
        r += 1

    if show_hud_reward
        table.cell(hud, 0, r, "Target (" + str.tostring(rr_ratio) + "R)", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, "+" + str.tostring(math.round(trade_reward, 2)) + " (" + str.tostring(math.round(active_tp, 2)) + ")", text_color=color.aqua, text_halign=text.align_right, text_size=size.small)
        r += 1

    if show_hud_runup
        table.cell(hud, 0, r, "Peak Runup", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, "+" + str.tostring(math.round(max_runup, 2)), text_color=color.lime, text_halign=text.align_right, text_size=size.small)
        r += 1
        
    if show_hud_dd
        table.cell(hud, 0, r, "Max Drawdown", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, "-" + str.tostring(math.round(max_drawdown, 2)), text_color=color.red, text_halign=text.align_right, text_size=size.small)
        r += 1
        
    if show_hud_entry
        table.cell(hud, 0, r, "Entry Price", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, str.tostring(math.round(entry_price, 2)), text_color=color.white, text_halign=text.align_right, text_size=size.small)
        r += 1
        
    if show_hud_atr
        table.cell(hud, 0, r, "Live ATR (14)", text_color=color.gray, text_halign=text.align_left, text_size=size.small)
        table.cell(hud, 1, r, str.tostring(math.round(atr_val, 2)), text_color=color.yellow, text_halign=text.align_right, text_size=size.small)
        r += 1


// =========================================================================
// --- 7. VISUALS & ALERTS ---
// =========================================================================
plotshape(fire_signal, title="SnakeEyes", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.normal, text="SE", textcolor=color.red)

// Visually debug the Kill Switches
plotshape(stopped_out, title="SL Hit", style=shape.xcross, location=location.absolute, color=color.red, size=size.small)
plotshape(target_hit, title="Target Hit", style=shape.flag, location=location.abovebar, color=color.lime, size=size.small)

// Plot the Static Stop Loss & Dynamic Target Lines
plot(active_sl, title="Stop Loss (Prev Mom Low)", color=color.red, style=plot.style_linebr, linewidth=2)
plot(active_tp, title="Take Profit (Target)", color=color.new(color.lime, 40), style=plot.style_linebr, linewidth=2)

// Divergences
plotshape(bullDiv ? low[lbR] : na, offset=-lbR, title="Bullish Divergence Label", text="DIV", style=shape.labelup, location=location.absolute, color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)
plotshape(bearDiv ? high[lbR] : na, offset=-lbR, title="Bearish Divergence Label", text="DIV", style=shape.labeldown, location=location.absolute, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)

alertcondition(fire_signal, title="SnakeEyes Long Signal", message="MCB Dots detected followed by Momentum Cross Up. Entry Signal!")
````

# MCB Zero Cross Highlighter

- url: https://www.tradingview.com/script/Q9IAPUsd-MCB-Zero-Cross-Highlighter/
- type: indicator
- pine_id: PUB;802f0853c4c646bca63a47572fbb178c
- version: 1.0

## Description

Changes color of bar based on the data points that are mapped in settings. I use MCB

## Source Code

````pine
//@version=6
indicator("MCB Zero Cross Highlighter", overlay=true)

// =========================================================================
// --- 1. DIRECT DATA MAPPING --- 
// =========================================================================
grp_map = "MCB Direct Mapping"
mcb_wt1 = input.source(close, "1. Map: MCB Momentum (WT1)", group=grp_map)
mcb_mfi = input.source(close, "2. Map: MCB Money Flow", group=grp_map)

// =========================================================================
// --- 2. SETTINGS & FILTERS --- 
// =========================================================================
grp_filters = "Cross Filters"
use_mf_filter = input.bool(true, "Require Money Flow Alignment", tooltip="If true, Up crosses require MF > 0 and Down crosses require MF < 0. Turn OFF to see divergent crosses.", group=grp_filters)

grp_vis = "Visual Settings"
col_up_grn = input.color(color.green, "Cross Up (MF Green / > 0)", group=grp_vis)
col_up_red = input.color(color.new(color.green, 50), "Cross Up (MF Red / < 0)", group=grp_vis)
col_dn_red = input.color(color.red, "Cross Down (MF Red / < 0)", group=grp_vis)
col_dn_grn = input.color(color.new(color.red, 50), "Cross Down (MF Green / > 0)", group=grp_vis)

// =========================================================================
// --- 3. SESSION FILTERS --- 
// =========================================================================
grp_sess = "Session Filters"
use_sess1 = input.bool(false, "Enable Session 1", group=grp_sess)
sess1_time = input.session("0930-1600", "Session 1 Time", group=grp_sess)
sess1_tz = input.string("America/New_York", "Session 1 Timezone", group=grp_sess)

use_sess2 = input.bool(false, "Enable Session 2", group=grp_sess)
sess2_time = input.session("0000-0800", "Session 2 Time", group=grp_sess)
sess2_tz = input.string("America/New_York", "Session 2 Timezone", group=grp_sess)

col_sess_bg = input.color(color.new(color.blue, 90), "Session Background Color", group=grp_sess)

// =========================================================================
// --- 4. LOGIC & CONDITIONS --- 
// =========================================================================
// Detect Momentum crossing the zero line
cross_up = ta.crossover(mcb_wt1, 0)
cross_dn = ta.crossunder(mcb_wt1, 0)

// Evaluate Money Flow Confluence for strict filtering (if enabled)
mf_bull_pass = not use_mf_filter or mcb_mfi > 0
mf_bear_pass = not use_mf_filter or mcb_mfi < 0

// Evaluate Session Confluence
in_sess1 = not na(time(timeframe.period, sess1_time, sess1_tz))
in_sess2 = not na(time(timeframe.period, sess2_time, sess2_tz))

// If no sessions are enabled, default to true. Otherwise, require an active session.
session_pass = (not use_sess1 and not use_sess2) or (use_sess1 and in_sess1) or (use_sess2 and in_sess2)

// Determine the 4 specific cross types based on Money Flow state
trigger_up_grn = cross_up and mcb_mfi > 0  and session_pass and mf_bull_pass
trigger_up_red = cross_up and mcb_mfi <= 0 and session_pass and mf_bull_pass
trigger_dn_red = cross_dn and mcb_mfi < 0  and session_pass and mf_bear_pass
trigger_dn_grn = cross_dn and mcb_mfi >= 0 and session_pass and mf_bear_pass

// =========================================================================
// --- 5. VISUALS & ALERTS --- 
// =========================================================================
// Paint Session Background
is_active_session = (use_sess1 and in_sess1) or (use_sess2 and in_sess2)
bgcolor(is_active_session ? col_sess_bg : na, title="Session Background")

// Paint the bars based on the 4 states (Flattened to one line to prevent continuation errors)
bar_color = trigger_up_grn ? col_up_grn : trigger_up_red ? col_up_red : trigger_dn_red ? col_dn_red : trigger_dn_grn ? col_dn_grn : na

barcolor(bar_color, title="Cross Highlight")

// Alert Hooks (Combined to catch any valid up or down cross that passes filters)
trigger_up_any = trigger_up_grn or trigger_up_red
trigger_dn_any = trigger_dn_red or trigger_dn_grn

alertcondition(trigger_up_any, title="Momentum Cross Up", message="MCB Momentum crossed above 0 with active filters applied.")
alertcondition(trigger_dn_any, title="Momentum Cross Down", message="MCB Momentum crossed below 0 with active filters applied.")
````

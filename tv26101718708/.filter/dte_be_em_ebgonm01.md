# DTE BE EM

- url: https://www.tradingview.com/script/EBGOnm01-DTE-BE-EM/
- type: indicator
- pine_id: PUB;5d8f023b93844b848626715c498738f0
- version: 2.0

## Description

The DTE BE EM (Days To Expiration Breakeven & Expected Move) indicator is a specialized institutional risk-mapping system built for TradingView in Pine Script v6. Rather than relying on static retail strike levels, it translates live option chain data into dynamic, dollar-denominated "Cost of Exposure" boundaries and expected volatility containers directly onto the underlying chart.   Core Structural PhilosophyInstitutional market makers act as liquidity providers. Within expected straddle breakeven boundaries, they harvest options time decay ($\theta$). Once spot price breaks outside these dynamic breakeven thresholds, market makers transition into forced delta-hedging engines—dynamically buying or selling underlying futures into price movement to manage their balance sheet risk.   

DTE BE EM maps these exact transition lines in real time across multiple expiration horizons.   

Key Capabilities & Mechanics
[list]
[*]Dynamic Straddle Breakeven Ratcheting (Dynamic BE)Real-Time RTH Tracking: As options decay during Regular Trading Hours (RTH, 09:30 – 16:00 EST), the indicator queries OPRA option prices bar-by-bar and tracks the minimum straddle price (min_straddle). It plots ratcheted step-lines ($Strike \pm min\_straddle$) representing the true shrinking risk boundary for options sellers.   
[*]16:00 EST Overnight Lock: At the cash close (16:00 EST), regular options trading halts. The indicator captures the final settled breakeven levels and automatically locks them as static horizontal reference rays that extend through Asia, London, and Globex overnight trading until the next RTH open.   
[/list]


Executed Expected Move (EM)True Open Implied Volatility Container: Calculates the $1.25\times$ executed straddle expected move strictly on the 09:30 AM RTH opening bar for the selected At-The-Money (ATM) strike. This anchors the session's single execution-based volatility envelope.  

Real-Time Institutional Dashboard (HUD)A compact top-right dashboard displays critical session inventory metrics across up to four tracked strikes:
[list]
[*]Open Straddle: The 1-minute high straddle price established at 09:30 AM EST.
[*]Min Straddle: The session's lowest straddle value (active ratcheted cost of exposure).   
[*]Open Vol vs. Total Vol ($\Sigma\text{ Vol}$): Initial 5-minute opening volume versus cumulative session volume to monitor institutional position building.
[/list]

Three-Layer Visual Hierarchy
[list]
[*]Macro Layer (OI / Net GEX Pillars): Establishes the key anchor strikes ($10\text{k}+$ Open Interest / major GEX nodes) used for indicator inputs.   
[*]Container Layer (DTE BE EM Step-Lines): The actionable straddle breakeven boundaries derived by the indicator, establishing where market makers shift from mean-reversion rent collectors to volatility-amplifying hedgers.   
[*]Micro Layer (Intraday Volume GEX): Real-time order flow and VWAP interaction against the step-line boundaries.   
[/list]

Core Features & Applications
[list]
[*]Dynamic BE Step-Lines: Tracks $Strike \pm min\_straddle$ during RTH to identify active institutional breakeven boundaries in real time.   
[*]Overnight Lock Mode: Anchors at the 16:00 EST close and projects static lines through Globex to define fixed overnight support and resistance for Asia and London sessions.   
[*]Executed Expected Move: Calculates $1.25 \times Open\ Straddle$ on the 09:30 AM open bar to define maximum statistical expected volatility limits for the session.   
[*]Multi-Strike Overlay: Concurrently tracks up to 4 custom strikes across different DTE chains to map cross-horizon risk confluences (e.g., 0DTE vs. 1DTE/2DTE step-lines).   
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KinetiCapital
///
//@version=6
indicator("DTE BE EM", shorttitle="DTE BE EM", overlay=true, max_lines_count=100)

// ==========================================
// USER INPUTS
// ==========================================
string i_underlying = input.string("QQQ", "Underlying", options=["QQQ", "SPY", "SPX"], group="Strike Selection")
string i_expiry     = input.string("", "DTE (YYMMDD)", tooltip="Leave empty to auto-build today's 0DTE date in NY time", group="Strike Selection")

// 4 Strike Inputs with Toggles for Overlay Lines
bool   i_use_s1     = input.bool(true,  "", inline="s1", group="Strike Selection")
float  i_strike1    = input.float(755.0, "Strike 1", step=0.5, inline="s1", group="Strike Selection")

bool   i_use_s2     = input.bool(true,  "", inline="s2", group="Strike Selection")
float  i_strike2    = input.float(750.0, "Strike 2", step=0.5, inline="s2", group="Strike Selection")

bool   i_use_s3     = input.bool(true,  "", inline="s3", group="Strike Selection")
float  i_strike3    = input.float(745.0, "Strike 3", step=0.5, inline="s3", group="Strike Selection")

bool   i_use_s4     = input.bool(false,  "", inline="s4", group="Strike Selection")
float  i_strike4    = input.float(740.0, "Strike 4", step=0.5, inline="s4", group="Strike Selection")
string dte_label    = input.string("", 'Optional DTE Label', group="Strike Selection", tooltip = "such as day or DTE value of 0 or 1.  helpful if using loading indicator more than once to observe different DTEs")

// Visual Styling & Level Toggles
bool   i_show_dyn_be = input.bool(true, "Dynamic BE", inline="dyn_be", group="settings", tooltip="Renders dynamic ratcheted step-lines during RTH, and locks to fixed horizontal close levels during non-RTH (Asia/London/Globex).")
bool   i_show_em      = input.bool(true, "Expected Move", inline = 'em', group="settings")
string i_atm_select   = input.string("Strike 2", "", options=["Strike 1", "Strike 2", "Strike 3", "Strike 4"], inline = 'em', group="settings", tooltip="EM calculation is mathematically valid only for the true ATM strike at 9:30 AM open")
color  col_upper      = input.color(color.rgb(58, 124, 61),  "",inline = 'dyn_be', group="settings")
color  col_lower      = input.color(color.rgb(189, 59, 57),  "",inline = 'dyn_be',  group="settings")
color  col_em         = input.color(color.rgb(16, 50, 97),  "",inline = 'em',    group="settings")
int    line_width     = input.int(2, "Width", group="settings")
bool   i_show_hud     = input.bool(true, "Dashboard", group="settings")

// ==========================================
// DATE & SESSION HANDLING
// ==========================================
string tz = "America/New_York"
int    currYY = year(time, tz) % 100
int    currMM = month(time, tz)
int    currDD = dayofmonth(time, tz)

// Auto-generate YYMMDD string if input is blank
string auto_expiry   = str.format("{0,number,00}{1,number,00}{2,number,00}", currYY, currMM, currDD)
string active_expiry = str.length(i_expiry) == 6 ? i_expiry : auto_expiry

// Regular Trading Hours (9:30 AM - 4:00 PM EST)
bool in_rth   = time >= timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 9, 30) and time < timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 16, 0)
bool is_open  = in_rth and not in_rth[1]

// ==========================================
// OPRA TICKER & DATA REQUESTS
// ==========================================
string base_symbol = i_underlying == "SPX" ? "SPXW" : i_underlying

var string c_tick1 = na, var string p_tick1 = na
var string c_tick2 = na, var string p_tick2 = na
var string c_tick3 = na, var string p_tick3 = na
var string c_tick4 = na, var string p_tick4 = na

if barstate.isfirst
    c_tick1 := "OPRA:" + base_symbol + active_expiry + "C" + str.format("{0,number,0.0}", i_strike1)
    p_tick1 := "OPRA:" + base_symbol + active_expiry + "P" + str.format("{0,number,0.0}", i_strike1)
    c_tick2 := "OPRA:" + base_symbol + active_expiry + "C" + str.format("{0,number,0.0}", i_strike2)
    p_tick2 := "OPRA:" + base_symbol + active_expiry + "P" + str.format("{0,number,0.0}", i_strike2)
    c_tick3 := "OPRA:" + base_symbol + active_expiry + "C" + str.format("{0,number,0.0}", i_strike3)
    p_tick3 := "OPRA:" + base_symbol + active_expiry + "P" + str.format("{0,number,0.0}", i_strike3)
    c_tick4 := "OPRA:" + base_symbol + active_expiry + "C" + str.format("{0,number,0.0}", i_strike4)
    p_tick4 := "OPRA:" + base_symbol + active_expiry + "P" + str.format("{0,number,0.0}", i_strike4)

// Request historical close prices across active timeframe for all 4 strikes
float c1 = nz(request.security(c_tick1, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p1 = nz(request.security(p_tick1, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c2 = nz(request.security(c_tick2, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p2 = nz(request.security(p_tick2, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c3 = nz(request.security(c_tick3, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p3 = nz(request.security(p_tick3, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c4 = nz(request.security(c_tick4, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p4 = nz(request.security(p_tick4, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

// Fetch 1-Minute Resolution High Data strictly for 9:30 AM Open Bar
float c1_1m_high = nz(request.security(c_tick1, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p1_1m_high = nz(request.security(p_tick1, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c2_1m_high = nz(request.security(c_tick2, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p2_1m_high = nz(request.security(p_tick2, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c3_1m_high = nz(request.security(c_tick3, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p3_1m_high = nz(request.security(p_tick3, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c4_1m_high = nz(request.security(c_tick4, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p4_1m_high = nz(request.security(p_tick4, "1", high, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

// Fetch 5-Minute Resolution Volume Data strictly for 9:30 AM First 5m Bar
float c1_5m_vol = nz(request.security(c_tick1, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p1_5m_vol = nz(request.security(p_tick1, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c2_5m_vol = nz(request.security(c_tick2, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p2_5m_vol = nz(request.security(p_tick2, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c3_5m_vol = nz(request.security(c_tick3, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p3_5m_vol = nz(request.security(p_tick3, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c4_5m_vol = nz(request.security(c_tick4, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p4_5m_vol = nz(request.security(p_tick4, "5", volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

// Request volume data across active timeframe
float c1_vol = nz(request.security(c_tick1, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p1_vol = nz(request.security(p_tick1, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c2_vol = nz(request.security(c_tick2, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p2_vol = nz(request.security(p_tick2, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c3_vol = nz(request.security(c_tick3, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p3_vol = nz(request.security(p_tick3, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float c4_vol = nz(request.security(c_tick4, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float p4_vol = nz(request.security(p_tick4, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

// Bar-by-bar live straddle sum
float bar_straddle1 = (c1 + p1) > 0 ? (c1 + p1) : na
float bar_straddle2 = (c2 + p2) > 0 ? (c2 + p2) : na
float bar_straddle3 = (c3 + p3) > 0 ? (c3 + p3) : na
float bar_straddle4 = (c4 + p4) > 0 ? (c4 + p4) : na

// Persistent Session Trackers
var float open_straddle1 = na, var float open_straddle2 = na, var float open_straddle3 = na, var float open_straddle4 = na
var float open_vol1      = na, var float open_vol2      = na, var float open_vol3      = na, var float open_vol4      = na
var float max_straddle1  = na, var float min_straddle1  = na, var float tot_vol1 = 0.0
var float max_straddle2  = na, var float min_straddle2  = na, var float tot_vol2 = 0.0
var float max_straddle3  = na, var float min_straddle3  = na, var float tot_vol3 = 0.0
var float max_straddle4  = na, var float min_straddle4  = na, var float tot_vol4 = 0.0

var float ratch_up1 = na, var float ratch_dn1 = na
var float ratch_up2 = na, var float ratch_dn2 = na
var float ratch_up3 = na, var float ratch_dn3 = na
var float ratch_up4 = na, var float ratch_dn4 = na

// Historical Bar-by-Bar Calculation starting strictly at 9:30 AM EST open
if is_open
    tot_vol1 := c1_vol + p1_vol
    tot_vol2 := c2_vol + p2_vol
    tot_vol3 := c3_vol + p3_vol
    tot_vol4 := c4_vol + p4_vol

    open_straddle1 := (c1_1m_high + p1_1m_high) > 0 ? (c1_1m_high + p1_1m_high) : bar_straddle1
    open_straddle2 := (c2_1m_high + p2_1m_high) > 0 ? (c2_1m_high + p2_1m_high) : bar_straddle2
    open_straddle3 := (c3_1m_high + p3_1m_high) > 0 ? (c3_1m_high + p3_1m_high) : bar_straddle3
    open_straddle4 := (c4_1m_high + p4_1m_high) > 0 ? (c4_1m_high + p4_1m_high) : bar_straddle4

    open_vol1 := (c1_5m_vol + p1_5m_vol) > 0 ? (c1_5m_vol + p1_5m_vol) : tot_vol1
    open_vol2 := (c2_5m_vol + p2_5m_vol) > 0 ? (c2_5m_vol + p2_5m_vol) : tot_vol2
    open_vol3 := (c3_5m_vol + p3_5m_vol) > 0 ? (c3_5m_vol + p3_5m_vol) : tot_vol3
    open_vol4 := (c4_5m_vol + p4_5m_vol) > 0 ? (c4_5m_vol + p4_5m_vol) : tot_vol4

    max_straddle1 := open_straddle1, min_straddle1 := bar_straddle1
    max_straddle2 := open_straddle2, min_straddle2 := bar_straddle2
    max_straddle3 := open_straddle3, min_straddle3 := bar_straddle3
    max_straddle4 := open_straddle4, min_straddle4 := bar_straddle4

    ratch_up1 := not na(bar_straddle1) ? i_strike1 + bar_straddle1 : na
    ratch_dn1 := not na(bar_straddle1) ? i_strike1 - bar_straddle1 : na

    ratch_up2 := not na(bar_straddle2) ? i_strike2 + bar_straddle2 : na
    ratch_dn2 := not na(bar_straddle2) ? i_strike2 - bar_straddle2 : na

    ratch_up3 := not na(bar_straddle3) ? i_strike3 + bar_straddle3 : na
    ratch_dn3 := not na(bar_straddle3) ? i_strike3 - bar_straddle3 : na

    ratch_up4 := not na(bar_straddle4) ? i_strike4 + bar_straddle4 : na
    ratch_dn4 := not na(bar_straddle4) ? i_strike4 - bar_straddle4 : na

else if in_rth
    tot_vol1 += (c1_vol + p1_vol)
    tot_vol2 += (c2_vol + p2_vol)
    tot_vol3 += (c3_vol + p3_vol)
    tot_vol4 += (c4_vol + p4_vol)

    if not na(bar_straddle1)
        if na(max_straddle1) or bar_straddle1 > max_straddle1
            max_straddle1 := bar_straddle1
        if na(min_straddle1) or bar_straddle1 < min_straddle1
            min_straddle1 := bar_straddle1
            ratch_up1 := i_strike1 + min_straddle1
            ratch_dn1 := i_strike1 - min_straddle1

    if not na(bar_straddle2)
        if na(max_straddle2) or bar_straddle2 > max_straddle2
            max_straddle2 := bar_straddle2
        if na(min_straddle2) or bar_straddle2 < min_straddle2
            min_straddle2 := bar_straddle2
            ratch_up2 := i_strike2 + min_straddle2
            ratch_dn2 := i_strike2 - min_straddle2

    if not na(bar_straddle3)
        if na(max_straddle3) or bar_straddle3 > max_straddle3
            max_straddle3 := bar_straddle3
        if na(min_straddle3) or bar_straddle3 < min_straddle3
            min_straddle3 := bar_straddle3
            ratch_up3 := i_strike3 + min_straddle3
            ratch_dn3 := i_strike3 - min_straddle3

    if not na(bar_straddle4)
        if na(max_straddle4) or bar_straddle4 > max_straddle4
            max_straddle4 := bar_straddle4
        if na(min_straddle4) or bar_straddle4 < min_straddle4
            min_straddle4 := bar_straddle4
            ratch_up4 := i_strike4 + min_straddle4
            ratch_dn4 := i_strike4 - min_straddle4

f_fmt_vol(float vol) =>
    na(vol) or vol == 0 ? "—" : vol >= 1000 ? str.format("{0,number,#.0}K", vol / 1000) : str.format("{0,number,#}", vol)

// ==========================================
// LINE & LABEL DRAWINGS (PERSIST OVERNIGHT)
// ==========================================
var int open_bar_index  = na
var int close_bar_index = na

var line  cur_up1 = na, var line  cur_dn1 = na
var line  cur_up2 = na, var line  cur_dn2 = na
var line  cur_up3 = na, var line  cur_dn3 = na
var line  cur_up4 = na, var line  cur_dn4 = na

var line  em_up = na, var line em_dn = na

var label lbl_up1 = na, var label lbl_dn1 = na
var label lbl_up2 = na, var label lbl_dn2 = na
var label lbl_up3 = na, var label lbl_dn3 = na
var label lbl_up4 = na, var label lbl_dn4 = na

var label lbl_em_up = na, var label lbl_em_dn = na

// Track RTH Open Bar Index
if is_open
    open_bar_index := bar_index

// Track RTH Close Bar Index (16:00 EST)
bool is_close = in_rth[1] and not in_rth
if is_close
    close_bar_index := bar_index

// Determine starting anchor: 16:00 Close when outside RTH, 09:30 Open during RTH
int line_start_x = in_rth ? open_bar_index : nz(close_bar_index, open_bar_index)

// Transparent LINES strictly during RTH, Normal during Globex/Overnight
color line_col_upper = in_rth ? color.new(col_upper, 100) : col_upper
color line_col_lower = in_rth ? color.new(col_lower, 100) : col_lower
color line_col_em    = in_rth ? color.new(col_em,    100) : col_em

// Continuously update horizontal lines on last bar state
if barstate.islast and i_show_dyn_be and not na(line_start_x)
    line.delete(cur_up1), line.delete(cur_dn1)
    line.delete(cur_up2), line.delete(cur_dn2)
    line.delete(cur_up3), line.delete(cur_dn3)
    line.delete(cur_up4), line.delete(cur_dn4)

    line.delete(em_up), line.delete(em_dn)

    label.delete(lbl_up1), label.delete(lbl_dn1)
    label.delete(lbl_up2), label.delete(lbl_dn2)
    label.delete(lbl_up3), label.delete(lbl_dn3)
    label.delete(lbl_up4), label.delete(lbl_dn4)

    label.delete(lbl_em_up), label.delete(lbl_em_dn)

    int line_end_x = bar_index + 15

    // Strike 1 Lines & Labels
    if i_use_s1 and not na(ratch_up1)
        cur_up1 := line.new(x1=line_start_x, y1=ratch_up1, x2=line_end_x, y2=ratch_up1, color=line_col_upper, width=line_width)
        cur_dn1 := line.new(x1=line_start_x, y1=ratch_dn1, x2=line_end_x, y2=ratch_dn1, color=line_col_lower, width=line_width)
        lbl_up1 := label.new(x=line_end_x, y=ratch_up1, text=str.format("       {0,number,#} BE."+dte_label, i_strike1), style=label.style_none, textcolor=col_upper, size=size.tiny, textalign=text.align_left)
        lbl_dn1 := label.new(x=line_end_x, y=ratch_dn1, text=str.format("       {0,number,#} BE."+dte_label, i_strike1), style=label.style_none, textcolor=col_lower, size=size.tiny, textalign=text.align_left)

    // Strike 2 Lines & Labels
    if i_use_s2 and not na(ratch_up2)
        cur_up2 := line.new(x1=line_start_x, y1=ratch_up2, x2=line_end_x, y2=ratch_up2, color=line_col_upper, width=line_width)
        cur_dn2 := line.new(x1=line_start_x, y1=ratch_dn2, x2=line_end_x, y2=ratch_dn2, color=line_col_lower, width=line_width)
        lbl_up2 := label.new(x=line_end_x, y=ratch_up2, text=str.format("        {0,number,#} BE."+dte_label, i_strike2), style=label.style_none, textcolor=col_upper, size=size.tiny, textalign=text.align_left)
        lbl_dn2 := label.new(x=line_end_x, y=ratch_dn2, text=str.format("        {0,number,#} BE."+dte_label, i_strike2), style=label.style_none, textcolor=col_lower, size=size.tiny, textalign=text.align_left)

    // Strike 3 Lines & Labels
    if i_use_s3 and not na(ratch_up3)
        cur_up3 := line.new(x1=line_start_x, y1=ratch_up3, x2=line_end_x, y2=ratch_up3, color=line_col_upper, width=line_width)
        cur_dn3 := line.new(x1=line_start_x, y1=ratch_dn3, x2=line_end_x, y2=ratch_dn3, color=line_col_lower, width=line_width)
        lbl_up3 := label.new(x=line_end_x, y=ratch_up3, text=str.format("        {0,number,#} BE."+dte_label, i_strike3), style=label.style_none, textcolor=col_upper, size=size.tiny, textalign=text.align_left)
        lbl_dn3 := label.new(x=line_end_x, y=ratch_dn3, text=str.format("        {0,number,#} BE."+dte_label, i_strike3), style=label.style_none, textcolor=col_lower, size=size.tiny, textalign=text.align_left)

    // Strike 4 Lines & Labels
    if i_use_s4 and not na(ratch_up4)
        cur_up4 := line.new(x1=line_start_x, y1=ratch_up4, x2=line_end_x, y2=ratch_up4, color=line_col_upper, width=line_width)
        cur_dn4 := line.new(x1=line_start_x, y1=ratch_dn4, x2=line_end_x, y2=ratch_dn4, color=line_col_lower, width=line_width)
        lbl_up4 := label.new(x=line_end_x, y=ratch_up4, text=str.format("        {0,number,#} BE."+dte_label, i_strike4), style=label.style_none, textcolor=col_upper, size=size.tiny, textalign=text.align_left)
        lbl_dn4 := label.new(x=line_end_x, y=ratch_dn4, text=str.format("        {0,number,#} BE."+dte_label, i_strike4), style=label.style_none, textcolor=col_lower, size=size.tiny, textalign=text.align_left)

    // SINGLE EXECUTED EXPECTED MOVE (Only for the Designated ATM Strike)
    if i_show_em
        float atm_strike  = i_atm_select == "Strike 1" ? i_strike1 : i_atm_select == "Strike 2" ? i_strike2 : i_atm_select == "Strike 3" ? i_strike3 : i_strike4
        float atm_straddle = i_atm_select == "Strike 1" ? open_straddle1 : i_atm_select == "Strike 2" ? open_straddle2 : i_atm_select == "Strike 3" ? open_straddle3 : open_straddle4

        if not na(atm_straddle)
            float em_val = atm_straddle * 1.25
            float em_u   = atm_strike + em_val
            float em_d   = atm_strike - em_val
            em_up := line.new(x1=line_start_x, y1=em_u, x2=line_end_x, y2=em_u, color=line_col_em, width=line_width, style=line.style_solid)
            em_dn := line.new(x1=line_start_x, y1=em_d, x2=line_end_x, y2=em_d, color=line_col_em, width=line_width, style=line.style_solid)
            lbl_em_up := label.new(x=line_end_x, y=em_u, text=str.format("        {0,number,#} EM", atm_strike), style=label.style_none, textcolor=col_em, size=size.tiny, textalign=text.align_left)
            lbl_em_dn := label.new(x=line_end_x, y=em_d, text=str.format("        {0,number,#} EM", atm_strike), style=label.style_none, textcolor=col_em, size=size.tiny, textalign=text.align_left)

// ==========================================
// PROGRESSIVE STEP-LINE OVERLAYS (STRICTLY DURING RTH)
// ==========================================
float step_u1 = (in_rth and i_show_dyn_be and i_use_s1) ? ratch_up1 : na
float step_d1 = (in_rth and i_show_dyn_be and i_use_s1) ? ratch_dn1 : na
float step_u2 = (in_rth and i_show_dyn_be and i_use_s2) ? ratch_up2 : na
float step_d2 = (in_rth and i_show_dyn_be and i_use_s2) ? ratch_dn2 : na
float step_u3 = (in_rth and i_show_dyn_be and i_use_s3) ? ratch_up3 : na
float step_d3 = (in_rth and i_show_dyn_be and i_use_s3) ? ratch_dn3 : na
float step_u4 = (in_rth and i_show_dyn_be and i_use_s4) ? ratch_up4 : na
float step_d4 = (in_rth and i_show_dyn_be and i_use_s4) ? ratch_dn4 : na

plot(step_u1, "S1 Upper BE Step", color=col_upper, style=plot.style_stepline, linewidth=line_width)
plot(step_d1, "S1 Lower BE Step", color=col_lower, style=plot.style_stepline, linewidth=line_width)
plot(step_u2, "S2 Upper BE Step", color=col_upper, style=plot.style_stepline, linewidth=line_width)
plot(step_d2, "S2 Lower BE Step", color=col_lower, style=plot.style_stepline, linewidth=line_width)
plot(step_u3, "S3 Upper BE Step", color=col_upper, style=plot.style_stepline, linewidth=line_width)
plot(step_d3, "S3 Lower BE Step", color=col_lower, style=plot.style_stepline, linewidth=line_width)
plot(step_u4, "S4 Upper BE Step", color=col_upper, style=plot.style_stepline, linewidth=line_width)
plot(step_d4, "S4 Lower BE Step", color=col_lower, style=plot.style_stepline, linewidth=line_width)

// ==========================================
// DASHBOARD HUD (TOP RIGHT)
// ==========================================
var table tHud = table.new(position.top_right, 5, 6, border_width=1)
if barstate.islast and i_show_hud
    table.cell(tHud, 0, 0, "", bgcolor=color.new(color.black, 100))
    table.cell(tHud, 1, 0, "", bgcolor=color.new(color.black, 100))
    table.cell(tHud, 2, 0, "", bgcolor=color.new(color.black, 100))
    table.cell(tHud, 3, 0, "", bgcolor=color.new(color.black, 100))
    table.cell(tHud, 4, 0, "", bgcolor=color.new(color.black, 100))

    table.cell(tHud, 0, 1, "Strike",        text_color=color.rgb(255, 255, 255), bgcolor=color.black, text_size=size.tiny)
    table.cell(tHud, 1, 1, "Open Straddle", text_color=color.rgb(255, 255, 255), bgcolor=color.black, text_size=size.tiny)
    table.cell(tHud, 2, 1, "Min Straddle",  text_color=color.rgb(255, 255, 255), bgcolor=color.black, text_size=size.tiny)
    table.cell(tHud, 3, 1, "Open Vol",      text_color=color.rgb(255, 255, 255), bgcolor=color.black, text_size=size.tiny)
    table.cell(tHud, 4, 1, "Σ Vol",         text_color=color.rgb(255, 255, 255), bgcolor=color.black, text_size=size.tiny)

    table.cell(tHud, 0, 2, str.format("{0,number,#}."+dte_label, i_strike1), text_color=color.white, bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 1, 2, not na(open_straddle1) ? str.format("${0,number,#.00}", open_straddle1) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 2, 2, not na(min_straddle1) ? str.format("${0,number,#.00}", min_straddle1) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 3, 2, f_fmt_vol(open_vol1), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 4, 2, f_fmt_vol(tot_vol1), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)

    table.cell(tHud, 0, 3, str.format("{0,number,#}."+dte_label, i_strike2), text_color=color.white, bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 1, 3, not na(open_straddle2) ? str.format("${0,number,#.00}", open_straddle2) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 2, 3, not na(min_straddle2) ? str.format("${0,number,#.00}", min_straddle2) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 3, 3, f_fmt_vol(open_vol2), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 4, 3, f_fmt_vol(tot_vol2), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)

    table.cell(tHud, 0, 4, str.format("{0,number,#}."+dte_label, i_strike3), text_color=color.white, bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 1, 4, not na(open_straddle3) ? str.format("${0,number,#.00}", open_straddle3) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 2, 4, not na(min_straddle3) ? str.format("${0,number,#.00}", min_straddle3) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 3, 4, f_fmt_vol(open_vol3), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 4, 4, f_fmt_vol(tot_vol3), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)

    table.cell(tHud, 0, 5, str.format("{0,number,#}."+dte_label, i_strike4), text_color=color.white, bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 1, 5, not na(open_straddle4) ? str.format("${0,number,#.00}", open_straddle4) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 2, 5, not na(min_straddle4) ? str.format("${0,number,#.00}", min_straddle4) : "—", text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 3, 5, f_fmt_vol(open_vol4), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
    table.cell(tHud, 4, 5, f_fmt_vol(tot_vol4), text_color=color.rgb(255, 255, 255), bgcolor=color.rgb(30, 30, 30), text_size=size.tiny)
````

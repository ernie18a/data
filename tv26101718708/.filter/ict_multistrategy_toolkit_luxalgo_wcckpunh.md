# ICT Multi-Strategy Toolkit [LuxAlgo]

- url: https://www.tradingview.com/script/wCCKpUNh-ICT-Multi-Strategy-Toolkit-LuxAlgo/
- type: indicator
- pine_id: PUB;26d412cdcd4d4eeabd0570280f8580a6
- version: 1.0

## Description

The ICT Multi-Strategy Toolkit [LuxAlgo] is a comprehensive suite designed to automate and visualize the most popular trading models from Inner Circle Trader (ICT) methodologies. This toolkit integrates five distinct high-probability setups into a single interface, complete with a performance dashboard and advanced trade visualization.

Included Trading Models
Silver Bullet (SB): A time-specific model that triggers during high-volatility windows (10 AM, 2 PM, and 3 AM EST). It requires a liquidity sweep of a previous pivot followed by a Market Structure Shift (MSS) and enters on the resulting Fair Value Gap (FVG).
2022 Mentorship Model: Often considered the "universal" setup, this model identifies a liquidity hunt (stop run), an aggressive displacement causing an MSS, and an entry within the confirmation Fair Value Gap.
Optimal Trade Entry (OTE): A classic Fibonacci-based retracement setup. It identifies a strong displacement leg (Impulse) and looks for entries when price pulls back into the "Sweet Spot" between the 62% and 79% Fibonacci levels.
Judas Swing (JS): A session-open manipulation model. It uses the daily open price to determine bias, waits for a "fake" move in the opposite direction at the New York open (8:30 AM – 10:00 AM) to sweep liquidity, and then catches the real trend.
Turtle Soup (TS): A contrarian "Stop Hunt" model. It detects when price aggressively breaches a major old high or low but fails to sustain the breakout, closing back inside the range for a mean-reversion trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
// © LuxAlgo

//@version=6
indicator("ICT Multi-Strategy Toolkit [LuxAlgo]", "LuxAlgo - ICT Toolkit", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// Settings & Inputs
//---------------------------------------------------------------------------------------------------------------------{
grp_toggles = "Master Toggles"
en_sb       = input.bool(true, "Enable Silver Bullet", group=grp_toggles, tooltip="The Silver Bullet: A time-based setup. It waits for a liquidity sweep, followed by a Market Structure Shift (MSS), and enters on a Fair Value Gap (FVG) exclusively during the 10AM, 2PM, or 3AM EST hours.")
en_ote      = input.bool(true, "Enable Optimal Trade Entry", group=grp_toggles, tooltip="Optimal Trade Entry (OTE): A retracement setup. It identifies a strong displacement leg that breaks structure, and waits for price to pull back into the 'discount' 62% - 79% Fibonacci zone before entering.")
en_js       = input.bool(true, "Enable Judas Swing", group=grp_toggles, tooltip="Judas Swing: A session open trap. It determines the daily bias, waits for a fake manipulative move in the opposite direction at the session open to sweep stops, and enters on the reversal.")
en_ts       = input.bool(true, "Enable Turtle Soup", group=grp_toggles, tooltip="Turtle Soup: A contrarian setup. It waits for price to aggressively break a major old high or low, trapping breakout traders, and enters the moment price fails and closes back inside the range.")
en_2022     = input.bool(true, "Enable 2022 Mentorship Model", group=grp_toggles, tooltip="2022 Mentorship Model: The universal setup. It waits for a liquidity sweep, an aggressive reversal causing a Market Structure Shift (MSS), and enters on the resulting Fair Value Gap (FVG) at any time of day.")

grp_time    = "Session Times (Exchange Time)"
sb_sess1    = input.session("1000-1100", "Silver Bullet NY AM", group=grp_time)
sb_sess2    = input.session("1400-1500", "Silver Bullet NY PM", group=grp_time)
sb_sess3    = input.session("0300-0400", "Silver Bullet London", group=grp_time)
js_sess     = input.session("0830-1000", "Judas Swing Session", group=grp_time)

grp_sett    = "Engine Settings"
pivLen      = input.int(5, "Pivot Lookback/Forward", group=grp_sett)
ote_len     = input.int(20, "OTE Swing Lookback", group=grp_sett)

grp_risk    = "Trade & Risk Settings"
entry_type  = input.string("Candle Close", "Entry Execution", options=["Candle Close", "Level (Limit)"], group=grp_risk, tooltip="Choose whether the setup executes at the exact close of the confirmed candle, or simulates a perfect limit order at the FVG/OTE level.")
rr_input    = input.float(2.0, "Risk:Reward Target", group=grp_risk, minval=0.5, step=0.5, tooltip="The RR multiplier used to place Take Profits.")
no_overlap  = input.bool(true, "Prevent Overlapping Setups", group=grp_risk, tooltip="When enabled, new setups will not trigger if there is already an active trade running on the chart.")

grp_dash    = "Dashboard Settings"
dashboardInput          = input.bool(true, 'Enable Dashboard', group = grp_dash)
dashboardPositionInput  = input.string('Top Right', 'Position', group = grp_dash, options = ['Top Right','Bottom Right','Bottom Left'])
dashboardSizeInput      = input.string('Small', 'Size', group = grp_dash, options = ['Tiny','Small','Normal','Large','Huge'])

grp_vis     = "Visual Settings"
max_setups  = input.int(1, "Historical Setups to Keep", group=grp_vis, minval=1, tooltip="How many past completed setups to keep on the chart. Set to 1 for maximum cleanliness.")
showHighlight = input.bool(true, "Highlight Setup Background", group=grp_vis, tooltip="Draws a subtle background box over the entire duration of the active setup.")
showSLTP    = input.bool(true, "Show SL/TP Target Zones", group=grp_vis, tooltip="Draws Risk/Reward boxes tracking active setups.")
showPivots  = input.bool(true, "Show Setup Sweep Lines", group=grp_vis, tooltip="Draws the specific BSL/SSL line that triggered the setup.")
showFVG     = input.bool(true, "Show Setup FVGs", group=grp_vis, tooltip="Draws the specific FVG that was tapped for the entry.")
showOTE     = input.bool(true, "Show Setup OTE Zones", group=grp_vis, tooltip="Draws the specific 62-79% zone that was tapped for the entry.")
showSteps   = input.bool(true, "Show Step-by-Step Path", group=grp_vis, tooltip="Draws retrospective dotted lines and step labels from the entry back to the setup's origin.")
showSess    = input.bool(true, "Highlight Active Sessions", group=grp_vis, tooltip="Draws a background gradient that fades as the session comes to an end.")
color_sb    = input.color(color.new(color.silver, 80), "Silver Bullet Session Color", group=grp_vis)
color_js    = input.color(color.new(color.purple, 85), "Judas Swing Session Color", group=grp_vis)

//---------------------------------------------------------------------------------------------------------------------}
// Types & Managers
//---------------------------------------------------------------------------------------------------------------------{
type Pivot
    int   bIndex
    float price
    bool  isHigh
    bool  isSwept

type FVG
    int   bIndex
    float top
    float bottom
    bool  isBullish
    bool  isMitigated

type SetupVisuals
    label[] labels
    line[]  lines
    box[]   boxes

type Trade
    string id
    int    dir
    float  ep
    float  sl
    float  tp
    bool   active
    box    sl_box
    box    tp_box

var setupHistory  = array.new<SetupVisuals>()
var active_trades = array.new<Trade>()

var int wins_sb = 0, var int loss_sb = 0
var int wins_22 = 0, var int loss_22 = 0
var int wins_ote = 0, var int loss_ote = 0
var int wins_js = 0, var int loss_js = 0
var int wins_ts = 0, var int loss_ts = 0

f_new_setup() =>
    s = SetupVisuals.new(array.new_label(), array.new_line(), array.new_box())
    setupHistory.push(s)
    if setupHistory.size() > max_setups
        old = setupHistory.shift()
        if old.labels.size() > 0
            for i = 0 to old.labels.size() - 1
                label.delete(old.labels.get(i))
        if old.lines.size() > 0
            for i = 0 to old.lines.size() - 1
                line.delete(old.lines.get(i))
        if old.boxes.size() > 0
            for i = 0 to old.boxes.size() - 1
                box.delete(old.boxes.get(i))
    s

f_execute_trade(string id, int dir, float ep, float sl, SetupVisuals sv) =>
    if ep != sl
        float tp = dir == 1 ? ep + (ep - sl) * rr_input : ep - (sl - ep) * rr_input
        box sl_box = showSLTP ? box.new(bar_index, ep, bar_index, sl, border_color=na, bgcolor=color.new(color.red, 85)) : na
        box tp_box = showSLTP ? box.new(bar_index, tp, bar_index, ep, border_color=na, bgcolor=color.new(color.green, 85)) : na
        if showSLTP
            sv.boxes.push(sl_box)
            sv.boxes.push(tp_box)
        active_trades.push(Trade.new(id, dir, ep, sl, tp, true, sl_box, tp_box))

//---------------------------------------------------------------------------------------------------------------------}
// State Variables & Arrays
//---------------------------------------------------------------------------------------------------------------------{
var pivotHighs = array.new<Pivot>()
var pivotLows  = array.new<Pivot>()
var fvgs       = array.new<FVG>()

bool alert_sb_bull = false
bool alert_sb_bear = false
bool alert_22_bull = false
bool alert_22_bear = false
bool alert_js_bull = false
bool alert_js_bear = false
bool alert_ote_bull = false
bool alert_ote_bear = false
bool alert_ts_bull = false
bool alert_ts_bear = false

bool sweepBuy  = false
bool sweepSell = false
var int   lastSweepDir      = 0
var int   lastSweepTime     = 0
var int   lastSweepIndex    = 0
var float lastSweepPrice    = 0.0
var int   lastSweepPivIndex = 0
var float lastSweepPivPrice = 0.0

bool mssBull = false
bool mssBear = false
var int   lastMssIndex   = 0
var float lastMssPrice   = 0.0

// Daily Bias for Judas Swing
d_open   = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
biasBull = close > d_open
biasBear = close < d_open

//---------------------------------------------------------------------------------------------------------------------}
// Time Flags & Sessions Fade
//---------------------------------------------------------------------------------------------------------------------{
f_get_session_duration(sess_str) =>
    float dur_ms = 60 * 60000
    if str.length(sess_str) >= 9
        sh = str.tonumber(str.substring(sess_str, 0, 2))
        sm = str.tonumber(str.substring(sess_str, 2, 4))
        eh = str.tonumber(str.substring(sess_str, 5, 7))
        em = str.tonumber(str.substring(sess_str, 7, 9))
        if not na(sh) and not na(sm) and not na(eh) and not na(em)
            dur = (eh * 60 + em) - (sh * 60 + sm)
            if dur < 0
                dur += 24 * 60
            dur_ms := dur * 60000
    dur_ms

is_sb1 = not na(time(timeframe.period, sb_sess1, "America/New_York"))
is_sb2 = not na(time(timeframe.period, sb_sess2, "America/New_York"))
is_sb3 = not na(time(timeframe.period, sb_sess3, "America/New_York"))
is_sb = is_sb1 or is_sb2 or is_sb3

is_js = not na(time(timeframe.period, js_sess, "America/New_York"))
is_js_new = is_js and not is_js[1]

var int sb_start = na
var float current_sb_dur = 60 * 60000

if is_sb1 and not is_sb1[1]
    sb_start := time
    current_sb_dur := f_get_session_duration(sb_sess1)
else if is_sb2 and not is_sb2[1]
    sb_start := time
    current_sb_dur := f_get_session_duration(sb_sess2)
else if is_sb3 and not is_sb3[1]
    sb_start := time
    current_sb_dur := f_get_session_duration(sb_sess3)

sb_progress = is_sb ? math.max(0, math.min(1, (time - sb_start) / current_sb_dur)) : 0
sb_bg = showSess and en_sb and is_sb ? color.rgb(color.r(color_sb), color.g(color_sb), color.b(color_sb), color.t(color_sb) + sb_progress * (100 - color.t(color_sb))) : na
bgcolor(sb_bg, title="Silver Bullet Session")

var int js_start = na
var float js_dur = 90 * 60000
if is_js_new
    js_start := time
    js_dur   := f_get_session_duration(js_sess)

js_progress = is_js ? math.max(0, math.min(1, (time - js_start) / js_dur)) : 0
js_bg = showSess and en_js and is_js ? color.rgb(color.r(color_js), color.g(color_js), color.b(color_js), color.t(color_js) + js_progress * (100 - color.t(color_js))) : na
bgcolor(js_bg, title="Judas Swing Session")

//---------------------------------------------------------------------------------------------------------------------}
// Engine Logic: Liquidity & Sweeps
//---------------------------------------------------------------------------------------------------------------------{
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

if not na(ph)
    idx = bar_index - pivLen
    pivotHighs.push(Pivot.new(idx, ph, true, false))

if not na(pl)
    idx = bar_index - pivLen
    pivotLows.push(Pivot.new(idx, pl, false, false))

// Check Sweeps
if pivotHighs.size() > 0
    for i = pivotHighs.size() - 1 to 0
        p = pivotHighs.get(i)
        if not p.isSwept
            if high > p.price
                p.isSwept         := true
                sweepBuy          := true
                lastSweepDir      := 1
                lastSweepTime     := time
                lastSweepIndex    := bar_index
                lastSweepPrice    := high
                lastSweepPivIndex := p.bIndex
                lastSweepPivPrice := p.price
                
                // Module: Turtle Soup
                if en_ts and close < p.price and (bar_index - p.bIndex) > (pivLen * 2) and barstate.isconfirmed
                    if not no_overlap or active_trades.size() == 0
                        sv = f_new_setup()
                        f_execute_trade("TS", -1, close, high, sv)
                        alert("ICT Toolkit: Turtle Soup Bearish Entry Triggered", alert.freq_once_per_bar_close)
                        alert_ts_bear := true
                        sv.labels.push(label.new(bar_index, high, "TS", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small, tooltip="Turtle Soup: False Breakout of Old High"))
                        if showPivots
                            sv.lines.push(line.new(p.bIndex, p.price, bar_index, p.price, color=color.red, style=line.style_solid))
                            sv.labels.push(label.new(math.round((p.bIndex + bar_index)/2), p.price, "BSL Swept", color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_center, size=size.tiny))
                        if showSteps
                            sv.lines.push(line.new(p.bIndex, p.price, bar_index, high, color=color.new(color.gray, 30), style=line.style_dotted))
                            sv.labels.push(label.new(p.bIndex, p.price, "1. Old High", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
                        if showHighlight
                            sv.boxes.push(box.new(p.bIndex, math.max(high, p.price), bar_index, math.min(low, p.price), border_color=na, bgcolor=color.new(color.red, 90)))

if pivotLows.size() > 0
    for i = pivotLows.size() - 1 to 0
        p = pivotLows.get(i)
        if not p.isSwept
            if low < p.price
                p.isSwept         := true
                sweepSell         := true
                lastSweepDir      := -1
                lastSweepTime     := time
                lastSweepIndex    := bar_index
                lastSweepPrice    := low
                lastSweepPivIndex := p.bIndex
                lastSweepPivPrice := p.price
                
                // Module: Turtle Soup
                if en_ts and close > p.price and (bar_index - p.bIndex) > (pivLen * 2) and barstate.isconfirmed
                    if not no_overlap or active_trades.size() == 0
                        sv = f_new_setup()
                        f_execute_trade("TS", 1, close, low, sv)
                        alert("ICT Toolkit: Turtle Soup Bullish Entry Triggered", alert.freq_once_per_bar_close)
                        alert_ts_bull := true
                        sv.labels.push(label.new(bar_index, low, "TS", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small, tooltip="Turtle Soup: False Breakout of Old Low"))
                        if showPivots
                            sv.lines.push(line.new(p.bIndex, p.price, bar_index, p.price, color=color.blue, style=line.style_solid))
                            sv.labels.push(label.new(math.round((p.bIndex + bar_index)/2), p.price, "SSL Swept", color=color.new(color.white, 100), textcolor=color.blue, style=label.style_label_center, size=size.tiny))
                        if showSteps
                            sv.lines.push(line.new(p.bIndex, p.price, bar_index, low, color=color.new(color.gray, 30), style=line.style_dotted))
                            sv.labels.push(label.new(p.bIndex, p.price, "1. Old Low", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
                        if showHighlight
                            sv.boxes.push(box.new(p.bIndex, math.max(high, p.price), bar_index, math.min(low, p.price), border_color=na, bgcolor=color.new(color.green, 90)))

// Garbage Collection for Pivots
if pivotHighs.size() > 50
    pivotHighs.shift()
if pivotLows.size() > 50
    pivotLows.shift()

//---------------------------------------------------------------------------------------------------------------------}
// Engine Logic: Fair Value Gaps (FVG)
//---------------------------------------------------------------------------------------------------------------------{
bullFVG = low > high[2] and close[1] > open[1]
bearFVG = high < low[2] and close[1] < open[1]

if bullFVG
    fvgs.push(FVG.new(bar_index - 2, low, high[2], true, false))

if bearFVG
    fvgs.push(FVG.new(bar_index - 2, low[2], high, false, false))

if fvgs.size() > 0
    for i = fvgs.size() - 1 to 0
        f = fvgs.get(i)
        if not f.isMitigated
            if f.isBullish and low < f.bottom
                f.isMitigated := true
            else if not f.isBullish and high > f.top
                f.isMitigated := true

// Garbage Collection for FVGs
if fvgs.size() > 50
    fvgs.shift()

//---------------------------------------------------------------------------------------------------------------------}
// Engine Logic: Market Structure Shift (MSS)
//---------------------------------------------------------------------------------------------------------------------{
var int   lastMssPivIndex = 0
var float lastMssPivPrice = 0.0

if lastSweepDir == -1
    for i = pivotHighs.size() - 1 to 0
        p = pivotHighs.get(i)
        if close > p.price and close[1] <= p.price
            mssBull         := true
            lastSweepDir    := 0 // Reset to avoid duplicate MSS
            lastMssIndex    := bar_index
            lastMssPrice    := close
            lastMssPivIndex := p.bIndex
            lastMssPivPrice := p.price
            break

if lastSweepDir == 1
    for i = pivotLows.size() - 1 to 0
        p = pivotLows.get(i)
        if close < p.price and close[1] >= p.price
            mssBear         := true
            lastSweepDir    := 0 // Reset to avoid duplicate MSS
            lastMssIndex    := bar_index
            lastMssPrice    := close
            lastMssPivIndex := p.bIndex
            lastMssPivPrice := p.price
            break

//---------------------------------------------------------------------------------------------------------------------}
// Module: 2022 Mentorship & Silver Bullet
//---------------------------------------------------------------------------------------------------------------------{
var bool  setupActive2022   = false
var int   setupDir2022      = 0
var int   s2022_swp_idx     = 0
var float s2022_swp_prc     = 0.0
var int   s2022_swp_piv_idx = 0
var float s2022_swp_piv_prc = 0.0
var int   s2022_mss_idx     = 0
var float s2022_mss_prc     = 0.0
var int   s2022_mss_piv_idx = 0
var float s2022_mss_piv_prc = 0.0

if mssBull
    setupActive2022   := true
    setupDir2022      := 1
    s2022_swp_idx     := lastSweepIndex
    s2022_swp_prc     := lastSweepPrice
    s2022_swp_piv_idx := lastSweepPivIndex
    s2022_swp_piv_prc := lastSweepPivPrice
    s2022_mss_idx     := lastMssIndex
    s2022_mss_prc     := lastMssPrice
    s2022_mss_piv_idx := lastMssPivIndex
    s2022_mss_piv_prc := lastMssPivPrice

if mssBear
    setupActive2022   := true
    setupDir2022      := -1
    s2022_swp_idx     := lastSweepIndex
    s2022_swp_prc     := lastSweepPrice
    s2022_swp_piv_idx := lastSweepPivIndex
    s2022_swp_piv_prc := lastSweepPivPrice
    s2022_mss_idx     := lastMssIndex
    s2022_mss_prc     := lastMssPrice
    s2022_mss_piv_idx := lastMssPivIndex
    s2022_mss_piv_prc := lastMssPivPrice

bool entry2022 = false
int  entryDir  = 0
var FVG tapped_fvg = na

if setupActive2022
    for i = fvgs.size() - 1 to 0
        f = fvgs.get(i)
        if f.bIndex >= s2022_swp_idx
            if setupDir2022 == 1 and f.isBullish and not f.isMitigated
                if low <= f.top and high >= f.top and barstate.isconfirmed
                    entry2022       := true
                    entryDir        := 1
                    f.isMitigated   := true
                    setupActive2022 := false
                    tapped_fvg      := f
                    break
            if setupDir2022 == -1 and not f.isBullish and not f.isMitigated
                if high >= f.bottom and low <= f.bottom and barstate.isconfirmed
                    entry2022       := true
                    entryDir        := -1
                    f.isMitigated   := true
                    setupActive2022 := false
                    tapped_fvg      := f
                    break

if entry2022
    if not no_overlap or active_trades.size() == 0
        if (en_sb and is_sb) or en_2022
            is_sb_valid = en_sb and is_sb
            lblText = is_sb_valid ? "SB" : "2022"
            lblCol  = is_sb_valid ? (entryDir == 1 ? color.green : color.red) : (entryDir == 1 ? color.aqua : color.orange)
            txtCol  = is_sb_valid ? color.white : color.black
            yPos    = entryDir == 1 ? low : high
            lblStyl = entryDir == 1 ? label.style_label_up : label.style_label_down
            
            sv = f_new_setup()
            
            ep = entry_type == "Candle Close" ? close : (entryDir == 1 ? tapped_fvg.top : tapped_fvg.bottom)
            sl = s2022_swp_prc
            if (entryDir == 1 and sl < ep) or (entryDir == -1 and sl > ep)
                f_execute_trade(is_sb_valid ? "SB" : "2022", entryDir, ep, sl, sv)
                alert("ICT Toolkit: " + (is_sb_valid ? "Silver Bullet " : "2022 Model ") + (entryDir == 1 ? "Bullish" : "Bearish") + " Entry Triggered", alert.freq_once_per_bar_close)
                
                if is_sb_valid
                    if entryDir == 1
                        alert_sb_bull := true
                    else
                        alert_sb_bear := true
                else
                    if entryDir == 1
                        alert_22_bull := true
                    else
                        alert_22_bear := true
                
            sv.labels.push(label.new(bar_index, yPos, lblText, color=lblCol, textcolor=txtCol, style=lblStyl, size=size.small, tooltip="Sweep + MSS + FVG Entry"))
            
            if showPivots
                pcol = entryDir == 1 ? color.blue : color.red
                ptxt = entryDir == 1 ? "SSL Swept" : "BSL Swept"
                sv.lines.push(line.new(s2022_swp_piv_idx, s2022_swp_piv_prc, s2022_swp_idx, s2022_swp_piv_prc, color=pcol, style=line.style_solid))
                sv.labels.push(label.new(math.round((s2022_swp_piv_idx + s2022_swp_idx)/2), s2022_swp_piv_prc, ptxt, color=color.new(color.white, 100), textcolor=pcol, style=label.style_label_center, size=size.tiny))
                
            if showFVG and not na(tapped_fvg)
                sv.boxes.push(box.new(tapped_fvg.bIndex, tapped_fvg.top, bar_index, tapped_fvg.bottom, border_color=na, bgcolor=color.new(lblCol, 85)))
                
            if showSteps
                sv.lines.push(line.new(s2022_swp_idx, s2022_swp_prc, s2022_mss_idx, s2022_mss_prc, color=color.new(color.gray, 30), style=line.style_dotted))
                
                // MSS Line & Center Label
                sv.lines.push(line.new(s2022_mss_piv_idx, s2022_mss_piv_prc, s2022_mss_idx, s2022_mss_piv_prc, color=lblCol, style=line.style_solid))
                mid_idx = math.round((s2022_mss_piv_idx + s2022_mss_idx) / 2)
                sv.labels.push(label.new(mid_idx, s2022_mss_piv_prc, "MSS", color=color.new(color.white, 100), textcolor=lblCol, style=label.style_label_center, size=size.auto))
                
                sv.lines.push(line.new(s2022_mss_idx, s2022_mss_prc, bar_index, yPos, color=color.new(color.gray, 30), style=line.style_dotted))
                sv.labels.push(label.new(s2022_swp_idx, s2022_swp_prc, "1. Sweep", style=lblStyl, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
                
            if showHighlight
                top_p = math.max(s2022_swp_prc, s2022_mss_prc, s2022_mss_piv_prc, yPos)
                bot_p = math.min(s2022_swp_prc, s2022_mss_prc, s2022_mss_piv_prc, yPos)
                sv.boxes.push(box.new(s2022_swp_idx, top_p, bar_index, bot_p, border_color=na, bgcolor=color.new(lblCol, 90)))

//---------------------------------------------------------------------------------------------------------------------}
// Module: Judas Swing
//---------------------------------------------------------------------------------------------------------------------{
var bool wait_js_bull = false
var bool wait_js_bear = false
var int  js_start_idx = 0
var bool in_js_window = false

var int   js_swp_piv_idx = 0
var float js_swp_piv_prc = 0.0

if is_js_new
    wait_js_bull := false
    wait_js_bear := false
    in_js_window := true
    js_start_idx := bar_index

if not is_js
    in_js_window := false

if en_js and in_js_window
    if biasBull and sweepSell and (bar_index - js_start_idx) < 15
        wait_js_bull := true
        js_swp_piv_idx := lastSweepPivIndex
        js_swp_piv_prc := lastSweepPivPrice
    if biasBear and sweepBuy and (bar_index - js_start_idx) < 15
        wait_js_bear := true
        js_swp_piv_idx := lastSweepPivIndex
        js_swp_piv_prc := lastSweepPivPrice

if wait_js_bull and mssBull and barstate.isconfirmed
    if not no_overlap or active_trades.size() == 0
        sv = f_new_setup()
        f_execute_trade("JS", 1, close, lastSweepPrice, sv)
        alert("ICT Toolkit: Judas Swing Bullish Entry Triggered", alert.freq_once_per_bar_close)
        alert_js_bull := true
        
        sv.labels.push(label.new(bar_index, low, "Judas", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small, tooltip="Judas Swing: Manipulative Open Drop + Bullish MSS"))
        
        if showPivots
            sv.lines.push(line.new(js_swp_piv_idx, js_swp_piv_prc, lastSweepIndex, js_swp_piv_prc, color=color.blue, style=line.style_solid))
            sv.labels.push(label.new(math.round((js_swp_piv_idx + lastSweepIndex)/2), js_swp_piv_prc, "SSL Swept", color=color.new(color.white, 100), textcolor=color.blue, style=label.style_label_center, size=size.tiny))
            
        if showSteps
            sv.lines.push(line.new(js_start_idx, d_open, lastSweepIndex, lastSweepPrice, color=color.new(color.gray, 30), style=line.style_dotted))
            
            // MSS Line & Center Label
            sv.lines.push(line.new(lastMssPivIndex, lastMssPivPrice, lastMssIndex, lastMssPivPrice, color=color.green, style=line.style_solid))
            mid_idx = math.round((lastMssPivIndex + lastMssIndex) / 2)
            sv.labels.push(label.new(mid_idx, lastMssPivPrice, "MSS", color=color.new(color.white, 100), textcolor=color.green, style=label.style_label_center, size=size.auto))
            
            sv.lines.push(line.new(lastMssIndex, lastMssPrice, bar_index, low, color=color.new(color.gray, 30), style=line.style_dotted))
            sv.labels.push(label.new(js_start_idx, d_open, "1. Open", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
            sv.labels.push(label.new(lastSweepIndex, lastSweepPrice, "2. Fake Move", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
        
        if showHighlight
            top_p = math.max(d_open, lastSweepPrice, lastMssPivPrice, lastMssPrice, low)
            bot_p = math.min(d_open, lastSweepPrice, lastMssPivPrice, lastMssPrice, low)
            sv.boxes.push(box.new(js_start_idx, top_p, bar_index, bot_p, border_color=na, bgcolor=color.new(color.green, 90)))
    wait_js_bull := false

if wait_js_bear and mssBear and barstate.isconfirmed
    if not no_overlap or active_trades.size() == 0
        sv = f_new_setup()
        f_execute_trade("JS", -1, close, lastSweepPrice, sv)
        alert("ICT Toolkit: Judas Swing Bearish Entry Triggered", alert.freq_once_per_bar_close)
        alert_js_bear := true
        
        sv.labels.push(label.new(bar_index, high, "Judas", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small, tooltip="Judas Swing: Manipulative Open Rally + Bearish MSS"))
        
        if showPivots
            sv.lines.push(line.new(js_swp_piv_idx, js_swp_piv_prc, lastSweepIndex, js_swp_piv_prc, color=color.red, style=line.style_solid))
            sv.labels.push(label.new(math.round((js_swp_piv_idx + lastSweepIndex)/2), js_swp_piv_prc, "BSL Swept", color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_center, size=size.tiny))
            
        if showSteps
            sv.lines.push(line.new(js_start_idx, d_open, lastSweepIndex, lastSweepPrice, color=color.new(color.gray, 30), style=line.style_dotted))
            
            // MSS Line & Center Label
            sv.lines.push(line.new(lastMssPivIndex, lastMssPivPrice, lastMssIndex, lastMssPivPrice, color=color.red, style=line.style_solid))
            mid_idx = math.round((lastMssPivIndex + lastMssIndex) / 2)
            sv.labels.push(label.new(mid_idx, lastMssPivPrice, "MSS", color=color.new(color.white, 100), textcolor=color.red, style=label.style_label_center, size=size.auto))
            
            sv.lines.push(line.new(lastMssIndex, lastMssPrice, bar_index, high, color=color.new(color.gray, 30), style=line.style_dotted))
            sv.labels.push(label.new(js_start_idx, d_open, "1. Open", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
            sv.labels.push(label.new(lastSweepIndex, lastSweepPrice, "2. Fake Move", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
        
        if showHighlight
            top_p = math.max(d_open, lastSweepPrice, lastMssPivPrice, lastMssPrice, high)
            bot_p = math.min(d_open, lastSweepPrice, lastMssPivPrice, lastMssPrice, high)
            sv.boxes.push(box.new(js_start_idx, top_p, bar_index, bot_p, border_color=na, bgcolor=color.new(color.red, 90)))
    wait_js_bear := false

//---------------------------------------------------------------------------------------------------------------------}
// Module: Optimal Trade Entry (OTE)
//---------------------------------------------------------------------------------------------------------------------{
var float ote_high   = na
var float ote_low    = na
var bool  ote_active = false
var int   ote_dir    = 0
var int   ote_hl_idx = 0
var int   ote_ll_idx = 0

float hl_high = ta.highest(high, ote_len)
float ll_low  = ta.lowest(low, ote_len)
int   hl_idx  = bar_index - nz(ta.highestbars(high, ote_len))
int   ll_idx  = bar_index - nz(ta.lowestbars(low, ote_len))

if en_ote and mssBull
    ote_low    := ll_low
    ote_high   := high
    ote_active := true
    ote_dir    := 1
    ote_ll_idx := ll_idx
    ote_hl_idx := bar_index

if en_ote and mssBear
    ote_high   := hl_high
    ote_low    := low
    ote_active := true
    ote_dir    := -1
    ote_hl_idx := hl_idx
    ote_ll_idx := bar_index

if ote_active
    float range_ = ote_high - ote_low
    float fib62  = ote_dir == 1 ? ote_high - range_ * 0.62 : ote_low + range_ * 0.62
    float fib79  = ote_dir == 1 ? ote_high - range_ * 0.79 : ote_low + range_ * 0.79
    float fibTop = math.max(fib62, fib79)
    float fibBot = math.min(fib62, fib79)
    
    if ote_dir == 1 and low <= fibTop and high >= fibBot and barstate.isconfirmed
        if not no_overlap or active_trades.size() == 0
            sv = f_new_setup()
            ep = entry_type == "Candle Close" ? close : fibTop
            f_execute_trade("OTE", 1, ep, ote_low, sv)
            alert("ICT Toolkit: Optimal Trade Entry (OTE) Bullish Triggered", alert.freq_once_per_bar_close)
            alert_ote_bull := true
            
            sv.labels.push(label.new(bar_index, low, "OTE", color=color.aqua, textcolor=color.black, style=label.style_label_up, size=size.small, tooltip="Optimal Trade Entry: 62%-79% Retracement"))
            
            if showOTE
                sv.boxes.push(box.new(ote_hl_idx, fibTop, bar_index, fibBot, border_color=na, bgcolor=color.new(color.aqua, 85)))
                
            if showSteps
                sv.lines.push(line.new(ote_ll_idx, ote_low, ote_hl_idx, ote_high, color=color.new(color.gray, 30), style=line.style_dotted))
                sv.lines.push(line.new(ote_hl_idx, ote_high, bar_index, low, color=color.new(color.gray, 30), style=line.style_dotted))
                sv.labels.push(label.new(ote_ll_idx, ote_low, "1. Imp L", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
                sv.labels.push(label.new(ote_hl_idx, ote_high, "2. Imp H", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
            
            if showHighlight
                sv.boxes.push(box.new(ote_ll_idx, ote_high, bar_index, ote_low, border_color=na, bgcolor=color.new(color.aqua, 90)))
            
        ote_active := false
    else if ote_dir == -1 and high >= fibBot and low <= fibTop and barstate.isconfirmed
        if not no_overlap or active_trades.size() == 0
            sv = f_new_setup()
            ep = entry_type == "Candle Close" ? close : fibBot
            f_execute_trade("OTE", -1, ep, ote_high, sv)
            alert("ICT Toolkit: Optimal Trade Entry (OTE) Bearish Triggered", alert.freq_once_per_bar_close)
            alert_ote_bear := true
            
            sv.labels.push(label.new(bar_index, high, "OTE", color=color.fuchsia, textcolor=color.black, style=label.style_label_down, size=size.small, tooltip="Optimal Trade Entry: 62%-79% Retracement"))
            
            if showOTE
                sv.boxes.push(box.new(ote_ll_idx, fibTop, bar_index, fibBot, border_color=na, bgcolor=color.new(color.fuchsia, 85)))
                
            if showSteps
                sv.lines.push(line.new(ote_hl_idx, ote_high, ote_ll_idx, ote_low, color=color.new(color.gray, 30), style=line.style_dotted))
                sv.lines.push(line.new(ote_ll_idx, ote_low, bar_index, high, color=color.new(color.gray, 30), style=line.style_dotted))
                sv.labels.push(label.new(ote_hl_idx, ote_high, "1. Imp H", style=label.style_label_down, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
                sv.labels.push(label.new(ote_ll_idx, ote_low, "2. Imp L", style=label.style_label_up, color=color.new(color.gray, 100), textcolor=color.gray, size=size.tiny))
                
            if showHighlight
                sv.boxes.push(box.new(ote_hl_idx, ote_high, bar_index, ote_low, border_color=na, bgcolor=color.new(color.fuchsia, 90)))
            
        ote_active := false

//---------------------------------------------------------------------------------------------------------------------}
// Trade Management Engine
//---------------------------------------------------------------------------------------------------------------------{
if active_trades.size() > 0
    for i = active_trades.size() - 1 to 0
        t = active_trades.get(i)
        if t.active
            if not na(t.sl_box)
                box.set_right(t.sl_box, bar_index)
                box.set_right(t.tp_box, bar_index)
            
            bool is_win = false
            bool is_loss = false
            
            if t.dir == 1
                if low <= t.sl
                    is_loss := true
                else if high >= t.tp
                    is_win := true
            else
                if high >= t.sl
                    is_loss := true
                else if low <= t.tp
                    is_win := true
                    
            if is_win or is_loss
                t.active := false
                if t.id == "SB"
                    if is_win
                        wins_sb += 1
                    else
                        loss_sb += 1
                else if t.id == "2022"
                    if is_win
                        wins_22 += 1
                    else
                        loss_22 += 1
                else if t.id == "OTE"
                    if is_win
                        wins_ote += 1
                    else
                        loss_ote += 1
                else if t.id == "JS"
                    if is_win
                        wins_js += 1
                    else
                        loss_js += 1
                else if t.id == "TS"
                    if is_win
                        wins_ts += 1
                    else
                        loss_ts += 1
                active_trades.remove(i)

//---------------------------------------------------------------------------------------------------------------------}
// Dashboard
//---------------------------------------------------------------------------------------------------------------------{
DATA                    = #DBDBDB
HEADERS                 = #808080
BACKGROUND              = #161616
BORDERS                 = #2E2E2E

var parsedDashboardPosition = switch dashboardPositionInput
    'Top Right'       => position.top_right
    'Bottom Right'    => position.bottom_right
    'Bottom Left'     => position.bottom_left

var parsedDashboardSize     = switch dashboardSizeInput
    'Tiny'            => size.tiny
    'Small'           => size.small
    'Normal'          => size.normal
    'Large'           => size.large
    'Huge'            => size.huge

cell(table t_able, int column, int row, string data, color text_col = #FFFFFF, string align = text.align_right, color background = na, float height = 0) => 
    t_able.cell(column, row, data, text_color = text_col, text_size = parsedDashboardSize, text_halign = align, bgcolor = background, height = height)

divider(table t_able, int row, int lastColumn) =>    
    string rowDivider = '━━━━━━━━━━━━━━━━━━━━━━'
    t_able.merge_cells(0, row, lastColumn, row)
    cell(t_able, 0, row, rowDivider, text_col = BORDERS, align = text.align_center, height = 0.5)

var table dash = table.new(parsedDashboardPosition, 4, 15, bgcolor=BACKGROUND, border_width=0, frame_color=BORDERS, frame_width=1)

f_win_rate(w, l) =>
    float total = w + l
    total > 0 ? str.tostring(w / total * 100, "#.##") + "%" : "0.00%"

if barstate.islast and dashboardInput
    table.clear(dash, 0, 0, 3, 14)
    dash.merge_cells(0, 0, 3, 0)
    cell(dash, 0, 0, 'ICT Toolkit Performance', text_col=DATA, align=text.align_center)
    
    divider(dash, 1, 3)
    
    cell(dash, 0, 2, 'Setup', text_col=HEADERS, align=text.align_left)
    cell(dash, 1, 2, 'W', text_col=HEADERS, align=text.align_right)
    cell(dash, 2, 2, 'L', text_col=HEADERS, align=text.align_right)
    cell(dash, 3, 2, 'WR%', text_col=HEADERS, align=text.align_right)
    
    divider(dash, 3, 3)
    
    int r = 4
    if en_sb
        cell(dash, 0, r, 'Silver Bullet', text_col=DATA, align=text.align_left)
        cell(dash, 1, r, str.tostring(wins_sb), text_col=color.green)
        cell(dash, 2, r, str.tostring(loss_sb), text_col=color.red)
        cell(dash, 3, r, f_win_rate(wins_sb, loss_sb), text_col=DATA)
        r += 1
        
    if en_2022
        cell(dash, 0, r, '2022 Model', text_col=DATA, align=text.align_left)
        cell(dash, 1, r, str.tostring(wins_22), text_col=color.green)
        cell(dash, 2, r, str.tostring(loss_22), text_col=color.red)
        cell(dash, 3, r, f_win_rate(wins_22, loss_22), text_col=DATA)
        r += 1
        
    if en_ote
        cell(dash, 0, r, 'Opt. Trade Entry', text_col=DATA, align=text.align_left)
        cell(dash, 1, r, str.tostring(wins_ote), text_col=color.green)
        cell(dash, 2, r, str.tostring(loss_ote), text_col=color.red)
        cell(dash, 3, r, f_win_rate(wins_ote, loss_ote), text_col=DATA)
        r += 1
        
    if en_js
        cell(dash, 0, r, 'Judas Swing', text_col=DATA, align=text.align_left)
        cell(dash, 1, r, str.tostring(wins_js), text_col=color.green)
        cell(dash, 2, r, str.tostring(loss_js), text_col=color.red)
        cell(dash, 3, r, f_win_rate(wins_js, loss_js), text_col=DATA)
        r += 1
        
    if en_ts
        cell(dash, 0, r, 'Turtle Soup', text_col=DATA, align=text.align_left)
        cell(dash, 1, r, str.tostring(wins_ts), text_col=color.green)
        cell(dash, 2, r, str.tostring(loss_ts), text_col=color.red)
        cell(dash, 3, r, f_win_rate(wins_ts, loss_ts), text_col=DATA)
        r += 1

//---------------------------------------------------------------------------------------------------------------------}
// Alerts (UI Conditions)
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(alert_sb_bull, title="Silver Bullet Bullish", message="ICT Toolkit: Silver Bullet Bullish Entry")
alertcondition(alert_sb_bear, title="Silver Bullet Bearish", message="ICT Toolkit: Silver Bullet Bearish Entry")
alertcondition(alert_22_bull, title="2022 Model Bullish", message="ICT Toolkit: 2022 Model Bullish Entry")
alertcondition(alert_22_bear, title="2022 Model Bearish", message="ICT Toolkit: 2022 Model Bearish Entry")
alertcondition(alert_js_bull, title="Judas Swing Bullish", message="ICT Toolkit: Judas Swing Bullish Entry")
alertcondition(alert_js_bear, title="Judas Swing Bearish", message="ICT Toolkit: Judas Swing Bearish Entry")
alertcondition(alert_ote_bull, title="OTE Bullish", message="ICT Toolkit: Optimal Trade Entry Bullish")
alertcondition(alert_ote_bear, title="OTE Bearish", message="ICT Toolkit: Optimal Trade Entry Bearish")
alertcondition(alert_ts_bull, title="Turtle Soup Bullish", message="ICT Toolkit: Turtle Soup Bullish Entry")
alertcondition(alert_ts_bear, title="Turtle Soup Bearish", message="ICT Toolkit: Turtle Soup Bearish Entry")
//---------------------------------------------------------------------------------------------------------------------}
````

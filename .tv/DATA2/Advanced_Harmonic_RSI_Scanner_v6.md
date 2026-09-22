<!-- tradingview-pine-id: PUB;0d7fe23e58244d7e808a0ff69eae26c4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Advanced Harmonic + RSI Scanner v6

Source: https://www.tradingview.com/script/nt2MO35V-Advanced-Harmonic-RSI-Reversal-Scanner-Dual-Wave/

## Description

Description:
Most harmonic indicators suffer from two fatal flaws: they clutter your chart with overlapping lines, and they blindly signal entries at Fibonacci levels without checking if the market is actually slowing down.

The Advanced Harmonic & RSI Reversal Scanner solves both problems. By combining precise Fibonacci geometry (to find the location of a reversal) with an RSI exhaustion filter (to time the exact moment of the reversal), this script prevents you from catching falling knives.

This is a clean, professional-grade scanner designed for traders who want high-probability setups without the chart spam.

🔥 Core Features
Dual ZigZag Engine: The script simultaneously scans a "Major" wave and a "Minor" wave. It prioritizes finding larger, macro setups first, but will automatically scale down to find minor setups if the broader trend is noisy.

Live Point D Tracking: Unlike standard scripts that wait for a pivot to be fully confirmed (which causes late entries), Point D dynamically tracks the live wick of the current candle. The Fibonacci ratios update in real-time as the candle moves into the Potential Reversal Zone (PRZ).

RSI Entry Confirmation: A pattern alone is not enough. The script will only fire a Bull ▲ or Bear ▼ entry signal if Point D forms and the RSI confirms momentum exhaustion (crossing over/under the oversold/overbought thresholds).

Dynamic Risk & Targets: Forget manual measuring. Upon an entry trigger, the script instantly calculates and plots your Take Profit and Stop Loss lines:

TP1: 38.2% retracement of the A-to-D leg.

TP2: 61.8% retracement of the A-to-D leg.

Risk (Stop Loss): Dynamically placed 20% beyond Point D's structural size, safely protecting you against deep extensions like Butterfly or Crab patterns.

Anti-Spam Charting: Built with a strict visual state-machine. When a live candle twitches, the script cleanly deletes and redraws its lines rather than overlapping them. Your chart remains crystal clear.

Smart History Stamping: Once a trade setup completes, the script permanently "stamps" the pattern and its target lines onto the chart so you can accurately backtest past performance.

📐 Supported Patterns
The scanner precisely calculates internal and external Fibonacci ratios to identify:

Gartley

Bat

Butterfly

Crab

AB=CD (Functions as a fallback priority if an XABCD structure is invalid)

💡 How to Trade with this Indicator
Wait for the Setup: Let the script map the X, A, B, and C yellow pivot nodes. Watch as it projects Point D.

Wait for the Trigger: Do not enter blindly. Wait for the colored "Bull ▲" or "Bear ▼" pill to appear. This means price has hit the PRZ and the RSI has hooked, signaling momentum is shifting.

Execute the Plan: Place your entry. Set your Stop Loss at the red Risk line.

Manage the Trade: Take partial profits or move your stop to breakeven when price hits the green TP1 line. Leave a runner for TP2.

---

## Source Code

````pine
//@version=6
indicator("Advanced Harmonic + RSI Scanner v6", overlay=true, max_lines_count=500, max_labels_count=500)

// ========================================================================
// 1. SETTINGS & INPUTS
// ========================================================================
grp_zz   = "ZigZag (Wave) Settings"
prd_maj  = input.int(21, "Major Wave Length", group=grp_zz, minval=5)
prd_min  = input.int(8,  "Minor Wave Length", group=grp_zz, minval=2)
err      = input.float(8.0, "Fibonacci Tolerance (%)", group=grp_zz, minval=1.0) / 100

grp_rsi  = "RSI & Entry Settings"
rsi_len  = input.int(14, "RSI Length", group=grp_rsi)
rsi_ob   = input.int(70, "RSI Overbought", group=grp_rsi)
rsi_os   = input.int(30, "RSI Oversold", group=grp_rsi)

grp_ui   = "UI & History Settings"
show_hist = input.bool(true, "Keep Historical Patterns", group=grp_ui, tooltip="Stamps completed patterns on the chart so they don't disappear.")
proj_bars = input.int(20, "Target Line Length (Bars)", group=grp_ui, minval=5)

// ========================================================================
// 2. DATA STRUCTURES & ZIGZAG ENGINE
// ========================================================================
type Point
    int x     
    float p   
    int d     

type ZigZagTracker
    Point[] conf_pts
    int last_dir
    float live_p

var zz_maj = ZigZagTracker.new(array.new<Point>(), 0, 0.0)
var zz_min = ZigZagTracker.new(array.new<Point>(), 0, 0.0)

update_zz(ZigZagTracker zz, float ph, float pl, int b_index, float live_h, float live_l, int curr_index) =>
    if not na(ph)
        if zz.last_dir == 1
            if ph > zz.live_p
                zz.live_p := ph
                if zz.conf_pts.size() > 0
                    Point pt = zz.conf_pts.get(0)
                    pt.p := ph
                    pt.x := b_index
        else
            zz.conf_pts.unshift(Point.new(b_index, ph, 1))
            zz.last_dir := 1
            zz.live_p := ph
            if zz.conf_pts.size() > 5
                zz.conf_pts.pop()
                
    if not na(pl)
        if zz.last_dir == -1
            if pl < zz.live_p
                zz.live_p := pl
                if zz.conf_pts.size() > 0
                    Point pt2 = zz.conf_pts.get(0)
                    pt2.p := pl
                    pt2.x := b_index
        else
            zz.conf_pts.unshift(Point.new(b_index, pl, -1))
            zz.last_dir := -1
            zz.live_p := pl
            if zz.conf_pts.size() > 5
                zz.conf_pts.pop()

    // Real-time tracking for Point D
    if zz.conf_pts.size() > 0
        Point pD = zz.conf_pts.get(0)
        if zz.last_dir == 1
            if live_h > pD.p
                pD.p := live_h
                pD.x := curr_index
        else if zz.last_dir == -1
            if live_l < pD.p
                pD.p := live_l
                pD.x := curr_index
    true

ph_maj = ta.pivothigh(high, prd_maj, 1), pl_maj = ta.pivotlow(low, prd_maj, 1)
ph_min = ta.pivothigh(high, prd_min, 1), pl_min = ta.pivotlow(low, prd_min, 1)

update_zz(zz_maj, ph_maj, pl_maj, bar_index[1], high, low, bar_index)
update_zz(zz_min, ph_min, pl_min, bar_index[1], high, low, bar_index)

// ========================================================================
// 3. PATTERN EVALUATION
// ========================================================================
in_range(val, target, tolerance) =>
    math.abs(val - target) <= tolerance

get_pattern(has_x, ab_xa, bc_ab, xd_xa, cd_ab, tol) =>
    pat = "Invalid"
    if has_x
        if in_range(ab_xa, 0.618, tol) and (in_range(bc_ab, 0.382, tol) or in_range(bc_ab, 0.886, tol)) and in_range(xd_xa, 0.786, tol)
            pat := "GARTLEY"
        else if (in_range(ab_xa, 0.382, tol) or in_range(ab_xa, 0.500, tol)) and in_range(xd_xa, 0.886, tol)
            pat := "BAT"
        else if in_range(ab_xa, 0.786, tol) and (in_range(xd_xa, 1.272, tol) or in_range(xd_xa, 1.618, tol))
            pat := "BUTTERFLY"
        else if (in_range(ab_xa, 0.382, tol) or in_range(ab_xa, 0.618, tol)) and in_range(xd_xa, 1.618, tol)
            pat := "CRAB"
    
    // Check AB=CD if no XABCD pattern is valid
    if pat == "Invalid" and in_range(cd_ab, 1.0, tol) and bc_ab >= (0.382 - tol) and bc_ab <= (0.886 + tol)
        pat := "AB=CD"
    pat

evaluate_tracker(ZigZagTracker zz, float tol) =>
    pat = "Invalid"
    is_bull = false
    has_x = false
    if zz.conf_pts.size() >= 4
        Point pD = zz.conf_pts.get(0), Point pC = zz.conf_pts.get(1)
        Point pB = zz.conf_pts.get(2), Point pA = zz.conf_pts.get(3)
        has_x := zz.conf_pts.size() == 5
        Point pX = has_x ? zz.conf_pts.get(4) : Point.new(0, 0.0, 0)
        
        float ab = math.abs(pB.p - pA.p), float bc = math.abs(pC.p - pB.p), float cd = math.abs(pD.p - pC.p)
        float xa = has_x ? math.abs(pA.p - pX.p) : 0, float xd = has_x ? math.abs(pD.p - pX.p) : 0
        
        float ab_xa = xa > 0 ? ab / xa : 0
        float bc_ab = ab > 0 ? bc / ab : 0
        float xd_xa = xa > 0 ? xd / xa : 0
        float cd_ab = ab > 0 ? cd / ab : 0
        
        is_bull := pD.d == -1
        pat := get_pattern(has_x, ab_xa, bc_ab, xd_xa, cd_ab, tol)
    [pat, is_bull, has_x]

[maj_pat, maj_bull, maj_has_x] = evaluate_tracker(zz_maj, err)
[min_pat, min_bull, min_has_x] = evaluate_tracker(zz_min, err)

use_maj = (maj_pat != "Invalid") or (min_pat == "Invalid")
active_zz    = use_maj ? zz_maj    : zz_min
active_pat   = use_maj ? maj_pat   : min_pat
active_bull  = use_maj ? maj_bull  : min_bull
active_has_x = use_maj ? maj_has_x : min_has_x

rsi = ta.rsi(close, rsi_len)
rsi_cross_up = ta.crossover(rsi, rsi_os)
rsi_cross_dn = ta.crossunder(rsi, rsi_ob)

// ========================================================================
// 4. DRAWING ENGINE (CLEAN & SPACED)
// ========================================================================
var line[]  curr_lines  = array.new_line()
var label[] curr_labels = array.new_label()
var int     last_C_bar  = 0 

col_bull = color.rgb(41, 98, 255)
col_bear = color.rgb(242, 54, 69)

if active_pat != "Invalid" 
    Point pD = active_zz.conf_pts.get(0)
    Point pC = active_zz.conf_pts.get(1)
    Point pB = active_zz.conf_pts.get(2)
    Point pA = active_zz.conf_pts.get(3)
    Point pX = active_has_x ? active_zz.conf_pts.get(4) : Point.new(0, 0.0, 0)
    
    bool is_abcd = (active_pat == "AB=CD")
    bool is_bull_trade = active_bull
    
    // RSI Trigger Condition
    bool entry_cond = (is_bull_trade and (rsi_cross_up or rsi <= rsi_os)) or (not is_bull_trade and (rsi_cross_dn or rsi >= rsi_ob))
    
    if entry_cond
        // Calculate Organized Risk & Targets (Fixed Sizing & Spacing)
        float ad_diff = math.abs(pA.p - pD.p)
        
        // TP targets inward (Standard 38.2% and 61.8% retracements)
        float tp1 = is_bull_trade ? pD.p + (ad_diff * 0.382) : pD.p - (ad_diff * 0.382)
        float tp2 = is_bull_trade ? pD.p + (ad_diff * 0.618) : pD.p - (ad_diff * 0.618)
        
        // SL targets strictly OUTWARD (20% of structural size beyond Point D)
        float sl = is_bull_trade ? pD.p - (ad_diff * 0.20) : pD.p + (ad_diff * 0.20)
        
        if pC.x != last_C_bar
            if not show_hist
                for l in curr_lines
                    line.delete(l)
                for lbl in curr_labels
                    label.delete(lbl)
            
            array.clear(curr_lines)
            array.clear(curr_labels)
            last_C_bar := pC.x
        else
            for l in curr_lines
                line.delete(l)
            array.clear(curr_lines)
            for lbl in curr_labels
                label.delete(lbl)
            array.clear(curr_labels)

        // ---- DRAW THE CLEAN PATTERN ----
        color draw_col = is_bull_trade ? col_bull : col_bear
        
        // Draw Main Lines
        if active_has_x and not is_abcd
            curr_lines.push(line.new(pX.x, pX.p, pA.x, pA.p, color=draw_col, width=2))
            curr_lines.push(line.new(pX.x, pX.p, pB.x, pB.p, color=draw_col, width=1, style=line.style_dashed))
            curr_labels.push(label.new(pX.x, pX.p, "X", color=color.yellow, style=label.style_circle, size=size.small, textcolor=color.black))
            
        curr_lines.push(line.new(pA.x, pA.p, pB.x, pB.p, color=draw_col, width=2))
        curr_lines.push(line.new(pB.x, pB.p, pC.x, pC.p, color=draw_col, width=2))
        curr_lines.push(line.new(pC.x, pC.p, pD.x, pD.p, color=draw_col, width=2))
        curr_lines.push(line.new(pA.x, pA.p, pC.x, pC.p, color=draw_col, width=1, style=line.style_dashed))
        curr_lines.push(line.new(pB.x, pB.p, pD.x, pD.p, color=draw_col, width=1, style=line.style_dashed))
        
        // Draw Yellow Pivot Circles
        curr_labels.push(label.new(pA.x, pA.p, "A", color=color.yellow, style=label.style_circle, size=size.small, textcolor=color.black))
        curr_labels.push(label.new(pB.x, pB.p, "B", color=color.yellow, style=label.style_circle, size=size.small, textcolor=color.black))
        curr_labels.push(label.new(pC.x, pC.p, "C", color=color.yellow, style=label.style_circle, size=size.small, textcolor=color.black))
        curr_labels.push(label.new(pD.x, pD.p, "D", color=color.yellow, style=label.style_circle, size=size.small, textcolor=color.black))

        // Explicit Entry Label
        string dir_text = is_bull_trade ? "Bull " : "Bear "
        string arrow = is_bull_trade ? " ▲" : " ▼"
        string tag_text = dir_text + active_pat + arrow
        string style_tag = is_bull_trade ? label.style_label_up : label.style_label_down
        
        curr_labels.push(label.new(pD.x, pD.p, tag_text, color=draw_col, style=style_tag, textcolor=color.white, size=size.normal))

        // Target & Risk Lines (Guaranteed to space apart)
        int future_x = bar_index + proj_bars
        
        curr_lines.push(line.new(pD.x, tp1, future_x, tp1, color=color.green, style=line.style_dashed, width=2))
        curr_labels.push(label.new(future_x, tp1, "TP1: " + str.tostring(tp1, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small))
        
        curr_lines.push(line.new(pD.x, tp2, future_x, tp2, color=color.green, style=line.style_dashed, width=2))
        curr_labels.push(label.new(future_x, tp2, "TP2: " + str.tostring(tp2, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small))
        
        curr_lines.push(line.new(pD.x, sl, future_x, sl, color=color.red, style=line.style_dotted, width=2))
        curr_labels.push(label.new(future_x, sl, "Risk: " + str.tostring(sl, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small))
````

<!-- tradingview-pine-id: PUB;66dc68412e0548f4bd73df9177febb7b -->
<!-- tradingviewscripts-format: 1 -->
# Vdubus Pattern Gen V2 [Restored & Refined]

Source: https://www.tradingview.com/script/fi2LLSGz-Vdubus-Divergence-Wave-Pattern-Generator-V1/

## Description

The Vdubus Divergence Wave Theory

10 years in the making & now finally thanks to AI I have attempted to put my Trading strategy & logic into a visual representation of how I analyse and project market using Core price action & MacD.  Enjoy  :)

A Proprietary Structural & Momentum Confluence SystemPart 1: The Strategic Concept1. The Core Philosophy: "Geometry + Physics"Traditional technical analysis often fails because traders confuse location with timing.Geometry (Price Patterns): Tells us WHERE the market is likely to reverse (e.g., at a resistance level or harmonic D-point).Physics (Momentum): Tells us WHEN the energy driving the trend has actually shifted. The Vdubus Theory posits that a trade should never be taken based on Geometry alone. A valid signal requires a specific, fractal decay in momentum—a "Handshake" between price structure and energy exhaustion.2. The 3-Wave Momentum Filter (The Engine)Most traders look for simple divergence (2 points). The Vdubus Theory demands a 3-Wave Structure to confirm the true state of the market.A. The Standard Reversal (Exhaustion)This is the "Safe" entry, catching the slow death of a trend.Wave 1 $\rightarrow$ 2 (The Warning): Price pushes higher, but momentum is lower (Standard Divergence). This signals that the trend is tapping the brakes.Wave 2 $\rightarrow$ 3 (The Confirmation): Price pushes to a final extreme (often a stop-hunt), but momentum is flat or lower than Wave 2 ("No Divergence").The Logic: This confirms that the buyers have expended all remaining energy. The engine is dead.

B. The Climax Reversal (The Trap)This is the "Aggressive" entry, catching V-shape reversals.Wave 1 $\rightarrow$ 2 (The Bait): Price pushes higher, and momentum is Stronger/Higher (No Divergence). This sucks in retail traders who believe the trend is accelerating.Wave 2 $\rightarrow$ 3 (The Snap): Price pushes again, but momentum suddenly collapses (Divergence).The Logic: A "Strong to Weak" shift. The market traps traders with a show of strength before hitting a "concrete wall" of limit orders.C. The Predator (The Trend Continuation)The Logic: Trends rarely move in straight lines. The "Predator" looks for Hidden Divergence during a pullback.The Signal: Price makes a Higher Low (Trend Structure Intact), but Momentum makes a Lower Low (Oversold Trap). This signals the end of the correction and the resumption of the main trend.3. The "Clean Path" PrincipleA trade is only valid if there is no opposing force. If you are looking to Sell (Bearish Reversal), the opposing Bullish momentum must be weak or neutral. If the "Enemy" is strong, the trade is skipped.

Part 2: The Indicator Breakdown
Tool Name: Vdubus Divergence Wave Pattern Generator V1

This script automates your analysis by combining ZigZag Pattern Recognition (Geometry) with your Custom MACD Logic (Physics).

1. The "Golden" Settings
The physics engine is tuned to your specific discovery:

Fast Length: 8

Slow Length: 21

Signal Length: 5

Lookback: 3 (Sensitive enough to catch the exact pivot points).

2. Signal Generation Logic
The indicator scans for four distinct setups. Here is the exact logic code translated into English:

Signal 1: Standard Reversal (Green/Red Pattern)
Geometry: The ZigZag algorithm identifies a 5-point structure (X-A-B-C-D), such as a Gartley, Bat, or Butterfly.

Physics Check:

Finds the last 3 momentum peaks matching the price highs.

Rule: Momentum Peak 2 must be < Peak 1 (Divergence).

Rule: Momentum Peak 3 must be <= Peak 2 (Confirmation/No Div).

Output: Draws the colored pattern and labels it (e.g., "Bearish Gartley (Exhaustion)").

Signal 2: Climax Reversal (Orange Pattern)
Geometry: Identifies the same 5-point structures.

Physics Check:

Rule: Momentum Peak 2 is >= Peak 1 (Strength/No Div).

Rule: Momentum Peak 3 is < Peak 2 (Sudden Failure/Div).

Output: Draws the pattern in Orange labeled "⚠️ CLIMAX REVERSAL". This is your "Trap" detector.

Signal 3: Rounded Top/Bottom (Navy/Maroon Label)
Geometry: Price is compressing or rounding over.

Physics Check:

Scans for 4 consecutive waves of momentum decay.

Rule: Peak 1 > Peak 2 > Peak 3 > Peak 4.

Output: Places a label indicating a "Multi-Wave Decay," identifying turns that don't have sharp pivots.

Signal 4: The Predator (Purple Pattern)
Geometry: Identifies a trend pullback (Higher Low for Buys).

Physics Check:

Rule: Momentum makes a Lower Low while Price makes a Higher Low (Hidden Divergence).

Output: Draws a Purple pattern labeled "🦖 PREDATOR" to signal trend continuation.

3. The Confluence Dashboard
Located in the corner of the screen, this provides a final "Safety Check."

Logic: It compares the absolute value (strength) of the most recent Bearish Momentum Peak vs. the most recent Bullish Momentum Low.

Output:

Green (Bulls Strong): Buying pressure is dominant. Safe to Buy, Dangerous to Sell.

Red (Bears Strong): Selling pressure is dominant. Safe to Sell, Dangerous to Buy.

Grey (Neutral): Forces are balanced.

Summary of Potential
This system solves the "Trader's Dilemma" of entering too early or too late. By waiting for the 3rd Wave, you effectively filter out the market noise and only commit capital when the opposing side has structurally and physically collapsed. It transforms trading from a guessing game into a disciplined execution of identifying Geometric Exhaustion.

Logic 1 / PREVIOUS DIVERGENCE PROJECTS future TREND BREAKS / Reversals *Not in script*
Logic 2 / Wave 1 to 2 = Divergence  /  Wave 2 to 3 = NO divergence = Signal
Reverse logic: Wave 1 to 2 = NO Divergence  /  Wave 2 to 3 = Divergence = Signal

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bespoke_Analysis_Engine

//@version=5
indicator("Vdubus Pattern Gen V2 [Restored & Refined]", shorttitle="Vdubus Gen V2", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ==========================================
// 1. SETTINGS
// ==========================================

// --- FAST STRUCTURE (Current/Entry) ---
grp_fast = "Fast Structure (Entry Geometry)"
fastDepth = input.int(9, title="Fast Pattern Scale (ZigZag)", group=grp_fast)
showFastLines = input.bool(false, title="Show Fast Lines", group=grp_fast)
showFastFills = input.bool(true, title="Show Fast Fills", group=grp_fast)
showFastLbl   = input.bool(false, title="Show Fast Labels", group=grp_fast)

// --- SLOW STRUCTURE (Macro/Context) ---
grp_slow = "Slow Structure (Macro Context)"
slowDepth = input.int(24, title="Slow Pattern Scale (ZigZag)", group=grp_slow)
showSlowLines = input.bool(true, title="Show Slow Lines", group=grp_slow)
showSlowFills = input.bool(true, title="Show Slow Fills", group=grp_slow)
showSlowLbl   = input.bool(true, title="Show Slow Labels", group=grp_slow)

// --- PROJECTION TARGETS ---
grp_tgt   = "Target Projections"
showTgtBox = input.bool(false, title="Show Target Box (Prev H/L)", tooltip="Draws target box to the previous structural High/Low (Point C).", group=grp_tgt)

// --- MOMENTUM PHYSICS ---
grp_macd  = "Momentum Physics (Smoothed Defaults)"
fastLen   = input.int(21, title="Fast Length", group=grp_macd)  
slowLen   = input.int(34, title="Slow Length", group=grp_macd) 
sigLen    = input.int(5, title="Signal Length", group=grp_macd) 
lookback  = input.int(3, title="Momentum Pivot Lookback", group=grp_macd) 

// --- STYLES ---
grp_style = "Style & Colors"
col_bear   = input.color(color.red, title="Bearish Standard", group=grp_style)
col_bull   = input.color(color.green, title="Bullish Standard", group=grp_style)
col_climax = input.color(color.orange, title="Climax (Trap)", group=grp_style)
col_round  = input.color(color.navy, title="Rounded Top/Bottom", group=grp_style)
col_pred   = input.color(color.purple, title="Predator (Hidden)", group=grp_style)

// --- PATTERN TOGGLES ---
grp_pats  = "Pattern Filters"
showStandard = input.bool(true, title="Show Standard Reversals", group=grp_pats)
showClimax   = input.bool(true, title="Show Climax Reversals", group=grp_pats)
showRounded  = input.bool(true, title="Show Rounded Patterns", group=grp_pats)
showPred     = input.bool(true, title="Show Predator (Hidden)", group=grp_pats)

grp_harm  = "Harmonic Shape Selectors"
showGartley = input.bool(false, title="Gartley", group=grp_harm)
showBat     = input.bool(false, title="Bat", group=grp_harm)
showButterfly = input.bool(false, title="Butterfly", group=grp_harm)
showCrab    = input.bool(false, title="Crab", group=grp_harm)
showDeep    = input.bool(false, title="Deep/Shark", group=grp_harm)
showHS      = input.bool(true, title="Head & Shoulders", group=grp_harm)
err_tol     = input.float(0.15, title="Harmonic Tolerance", minval=0.01, maxval=0.5, group=grp_harm)

// --- DASHBOARD ---
grp_dash  = "Confluence Dashboard"
showDash  = input.bool(false, title="Show Dashboard", group=grp_dash)
dashPos   = input.string("Bottom Right", title="Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=grp_dash)
textSize  = input.string("Small", title="Size", options=["Small", "Normal", "Large"], group=grp_dash)

// ==========================================
// 2. MOMENTUM CALCULATIONS
// ==========================================
[macdLine, signalLine, histLine] = ta.macd(close, fastLen, slowLen, sigLen)

ph_mom = ta.pivothigh(histLine, lookback, lookback)
pl_mom = ta.pivotlow(histLine, lookback, lookback)

var waveHighs_val = array.new_float()
var waveHighs_loc = array.new_int()
var waveLows_val = array.new_float()
var waveLows_loc = array.new_int()

if not na(ph_mom)
    array.unshift(waveHighs_val, ph_mom)
    array.unshift(waveHighs_loc, bar_index[lookback]) 
    if array.size(waveHighs_val) > 10 
        array.pop(waveHighs_val)
        array.pop(waveHighs_loc)

if not na(pl_mom)
    array.unshift(waveLows_val, pl_mom)
    array.unshift(waveLows_loc, bar_index[lookback]) 
    if array.size(waveLows_val) > 10 
        array.pop(waveLows_val)
        array.pop(waveLows_loc)

// --- MOMENTUM VALIDATION ---
f_checkStandardBearish() =>
    valid = false
    if array.size(waveHighs_val) >= 3
        m1 = array.get(waveHighs_val, 2), m2 = array.get(waveHighs_val, 1), m3 = array.get(waveHighs_val, 0)
        if m2 < m1 and m3 <= m2 
            valid := true
    valid

f_checkStandardBullish() =>
    valid = false
    if array.size(waveLows_val) >= 3
        m1 = array.get(waveLows_val, 2), m2 = array.get(waveLows_val, 1), m3 = array.get(waveLows_val, 0)
        if m2 > m1 and m3 >= m2 
            valid := true
    valid

f_checkClimaxBearish() =>
    valid = false
    if array.size(waveHighs_val) >= 3
        m1 = array.get(waveHighs_val, 2), m2 = array.get(waveHighs_val, 1), m3 = array.get(waveHighs_val, 0)
        if m2 >= m1 and m3 < m2
            valid := true
    valid

f_checkClimaxBullish() =>
    valid = false
    if array.size(waveLows_val) >= 3
        m1 = array.get(waveLows_val, 2), m2 = array.get(waveLows_val, 1), m3 = array.get(waveLows_val, 0)
        if m2 <= m1 and m3 > m2
            valid := true
    valid

f_checkRoundedBearish() =>
    valid = false
    if array.size(waveHighs_val) >= 4
        m1 = array.get(waveHighs_val, 3), m2 = array.get(waveHighs_val, 2)
        m3 = array.get(waveHighs_val, 1), m4 = array.get(waveHighs_val, 0)
        if m1 > m2 and m2 > m3 and m3 > m4
            valid := true
    valid

f_checkRoundedBullish() =>
    valid = false
    if array.size(waveLows_val) >= 4
        m1 = array.get(waveLows_val, 3), m2 = array.get(waveLows_val, 2)
        m3 = array.get(waveLows_val, 1), m4 = array.get(waveLows_val, 0)
        if m1 < m2 and m2 < m3 and m3 < m4
            valid := true
    valid

f_checkBearishPredator() =>
    valid = false
    if array.size(waveHighs_val) >= 2
        m2 = array.get(waveHighs_val, 1), m3 = array.get(waveHighs_val, 0)
        if m3 > m2 
            valid := true
    valid

f_checkBullishPredator() =>
    valid = false
    if array.size(waveLows_val) >= 2
        m2 = array.get(waveLows_val, 1), m3 = array.get(waveLows_val, 0)
        if m3 < m2 
            valid := true
    valid

// ==========================================
// 3. DRAWING & IDENTIFICATION
// ==========================================

f_getHarmonicName(xB_ratio, xD_ratio, isBullish) =>
    name = "Unknown" 
    if math.abs(xB_ratio - 0.618) < err_tol and math.abs(xD_ratio - 0.786) < err_tol
        name := "Gartley"
    else if xB_ratio >= 0.382 - err_tol and xB_ratio <= 0.5 + err_tol and math.abs(xD_ratio - 0.886) < err_tol
        name := "Bat"
    else if math.abs(xB_ratio - 0.786) < err_tol and xD_ratio >= 1.27 - err_tol and xD_ratio <= 1.618 + err_tol
        name := "Butterfly"
    else if xB_ratio >= 0.382 - err_tol and xB_ratio <= 0.618 + err_tol and math.abs(xD_ratio - 1.618) < err_tol
        name := "Crab"
    else if xD_ratio > 1.0
        name := "Deep Pattern"
    else
        name := "Retracement"
    name

f_drawStruct(indices, values, col, patName, isPredator, isBullish, doLines, doFills, doLbl) =>
    xD = array.get(indices, 0), yD = array.get(values, 0)
    
    // Draw Lines & Fills
    if doLines or doFills
        xX = array.get(indices, 4), yX = array.get(values, 4)
        xA = array.get(indices, 3), yA = array.get(values, 3)
        xB = array.get(indices, 2), yB = array.get(values, 2)
        xC = array.get(indices, 1), yC = array.get(values, 1)
        
        w = isPredator ? 2 : 1 
        
        if doLines
            line.new(xX, yX, xA, yA, color=col, width=w)
            line.new(xA, yA, xB, yB, color=col, width=w)
            line.new(xB, yB, xC, yC, color=col, width=w)
            line.new(xC, yC, xD, yD, color=col, width=w)
        
        if doFills
            l_xa = line.new(xX, yX, xA, yA, color=color.new(col, 100), width=0)
            l_xb = line.new(xX, yX, xB, yB, color=color.new(col, 100), width=0)
            l_bc = line.new(xB, yB, xC, yC, color=color.new(col, 100), width=0)
            l_bd = line.new(xB, yB, xD, yD, color=color.new(col, 100), width=0)
            
            linefill.new(l_xa, l_xb, color.new(col, 92)) 
            linefill.new(l_bc, l_bd, color.new(col, 92))

    // Draw Labels
    if doLbl
        sty = isBullish ? label.style_label_up : label.style_label_down
        label.new(xD, yD, patName, color=col, textcolor=color.white, style=sty, size=size.small)

    // Draw Target Box (Updated: Previous H/L)
    if showTgtBox
        // For standard M/W patterns, point C (Index 1) is the "Previous H/L" inside the structure.
        yC = array.get(values, 1)
        
        boxTop = isBullish ? yC : yD
        boxBot = isBullish ? yD : yC
        
        box.new(xD, boxTop, xD + 20, boxBot, border_color=color.new(col, 80), bgcolor=color.new(col, 95))

// ==========================================
// 4. MAIN LOGIC LOOP
// ==========================================
f_runEngine(depth, doLines, doFills, doLbl) =>
    var float[] zzP = array.new_float()
    var int[] zzL = array.new_int()
    
    ph = ta.pivothigh(high, depth, depth)
    pl = ta.pivotlow(low, depth, depth)
    
    if not na(ph)
        array.unshift(zzP, ph)
        array.unshift(zzL, bar_index[depth])
        if array.size(zzP) > 10 
            array.pop(zzP), array.pop(zzL)
        
        if array.size(zzP) >= 5
            yD = array.get(zzP, 0), yX = array.get(zzP, 4)
            yC = array.get(zzP, 1), yB = array.get(zzP, 2), yA = array.get(zzP, 3)
            
            // Calc Ratios
            xa_len = math.abs(yA - yX)
            ab_len = math.abs(yB - yA)
            xb_ratio = xa_len != 0 ? ab_len / xa_len : 0.0
            
            rawName = f_getHarmonicName(xb_ratio, 1.27, false)
            isHS = showHS and (yB > yX and yB > yD)
            
            // Check Toggles
            shouldDraw = false
            if isHS
                shouldDraw := true
            else 
                if rawName == "Gartley" and showGartley
                    shouldDraw := true
                else if rawName == "Bat" and showBat
                    shouldDraw := true
                else if rawName == "Butterfly" and showButterfly
                    shouldDraw := true
                else if rawName == "Crab" and showCrab
                    shouldDraw := true
                else if rawName == "Deep Pattern" and showDeep
                    shouldDraw := true
                else if rawName == "Retracement" // Generic fallback
                    shouldDraw := true

            // 1. Standard
            if showStandard and f_checkStandardBearish() and shouldDraw
                pat = isHS ? "Bearish H&S" : ("Bearish " + rawName)
                f_drawStruct(zzL, zzP, col_bear, pat, false, false, doLines, doFills, doLbl)
            
            // 2. Climax
            if showClimax and f_checkClimaxBearish()
                f_drawStruct(zzL, zzP, col_climax, "CLIMAX REVERSAL", false, false, doLines, doFills, doLbl)
                
            // 3. Rounded
            if showRounded and f_checkRoundedBearish() and doLbl
                label.new(bar_index[depth], yD, "ROUNDED TOP", color=col_round, style=label.style_label_down, size=size.small)
                
            // 4. Predator
            if showPred and not f_checkStandardBearish() and yD < yX
                if f_checkBearishPredator()
                    f_drawStruct(zzL, zzP, col_pred, "🦖 PREDATOR", true, false, doLines, doFills, doLbl)

    if not na(pl)
        array.unshift(zzP, pl)
        array.unshift(zzL, bar_index[depth])
        if array.size(zzP) > 10 
            array.pop(zzP), array.pop(zzL)
            
        if array.size(zzP) >= 5
            yD = array.get(zzP, 0), yX = array.get(zzP, 4)
            yC = array.get(zzP, 1), yB = array.get(zzP, 2), yA = array.get(zzP, 3)
            
            xa_len = math.abs(yA - yX)
            ab_len = math.abs(yB - yA)
            xb_ratio = xa_len != 0 ? ab_len / xa_len : 0.0
            
            rawName = f_getHarmonicName(xb_ratio, 1.27, true)
            isInvHS = showHS and (yB < yX and yB < yD)
            
            shouldDraw = false
            if isInvHS
                shouldDraw := true
            else 
                if rawName == "Gartley" and showGartley
                    shouldDraw := true
                else if rawName == "Bat" and showBat
                    shouldDraw := true
                else if rawName == "Butterfly" and showButterfly
                    shouldDraw := true
                else if rawName == "Crab" and showCrab
                    shouldDraw := true
                else if rawName == "Deep Pattern" and showDeep
                    shouldDraw := true
                else if rawName == "Retracement"
                    shouldDraw := true

            // 1. Standard
            if showStandard and f_checkStandardBullish() and shouldDraw
                pat = isInvHS ? "Bullish Inv H&S" : ("Bullish " + rawName)
                f_drawStruct(zzL, zzP, col_bull, pat, false, true, doLines, doFills, doLbl)
            
            // 2. Climax
            if showClimax and f_checkClimaxBullish()
                f_drawStruct(zzL, zzP, col_climax, "CLIMAX REVERSAL", false, true, doLines, doFills, doLbl)
            
            // 3. Rounded
            if showRounded and f_checkRoundedBullish() and doLbl
                label.new(bar_index[depth], yD, "ROUNDED BOTTOM", color=col_round, style=label.style_label_up, size=size.small)
                
            // 4. Predator
            if showPred and not f_checkStandardBullish() and yD > yX
                if f_checkBullishPredator()
                    f_drawStruct(zzL, zzP, col_pred, "🦖 PREDATOR", true, true, doLines, doFills, doLbl)

// --- EXECUTE ENGINES ---
f_runEngine(fastDepth, showFastLines, showFastFills, showFastLbl)
f_runEngine(slowDepth, showSlowLines, showSlowFills, showSlowLbl)

// ==========================================
// 5. DASHBOARD
// ==========================================
if showDash
    pos = (dashPos == "Top Right") ? position.top_right : (dashPos == "Bottom Right") ? position.bottom_right : (dashPos == "Top Left") ? position.top_left : position.bottom_left
    sz = (textSize == "Small") ? size.small : (textSize == "Large") ? size.large : size.normal
    
    var table d = table.new(pos, 2, 2, bgcolor=color.new(color.black, 50), border_color=color.white, border_width=1)
    if barstate.islast
        table.cell(d, 0, 0, "Opposing Force", text_color=color.white, text_size=sz)
        
        last_bull_mom = array.size(waveLows_val) > 0 ? array.get(waveLows_val, 0) : 0.0
        last_bear_mom = array.size(waveHighs_val) > 0 ? array.get(waveHighs_val, 0) : 0.0
        
        opp_state = "Neutral"
        opp_col = color.gray
        
        if math.abs(last_bull_mom) > math.abs(last_bear_mom)
            opp_state := "Bulls Strong"
            opp_col := color.green
        else
            opp_state := "Bears Strong"
            opp_col := color.red
            
        table.cell(d, 1, 0, opp_state, text_color=color.white, bgcolor=opp_col, text_size=sz)
````

# [Core Convexity] SMT Divergences

- url: https://www.tradingview.com/script/Qzj8k9eW-Core-Convexity-SMT-Divergences/
- type: indicator
- pine_id: PUB;31650adb498640c2a2480839735a157a
- version: 1.0

## Description

## Description

The SMT Divergences indicator is a comprehensive tool designed to detect and manage Smart Money Tool (SMT) divergences across multiple assets directly on your primary chart. SMT divergence is a classic concept used to identify institutional accumulation or distribution by revealing a lack of correlation between highly correlated assets (such as NQ, ES, and YM, or Gold and Silver) at key structural swing points.

This script automates the detection process, filters out duplicate signals, and tracks mitigation (when an SMT structure is broken or invalidated by price action) to keep your charts clean and actionable.

### Key Features

* **Automatic Asset Pairing:** Detects the root symbol of your current chart and automatically pulls data for the most relevant correlated instruments. For example, if you are viewing NQ, it will automatically check ES and YM. It also features a dedicated "No YM" mode to simplify index correlation down to NQ and ES exclusively.
* **Custom Asset Input:** Switch the selection mode to "Custom" to manually input any two symbols you wish to compare against your primary chart.
* **Dual-Layer Detection:** The script scans both immediate pivot points and structural swings (Highs/Lows) to provide both near-term and macro SMT identification.
* **Dynamic Mitigation Stack:** When price invalidates an SMT level, the indicator can immediately remove the visual lines or keep them on the chart for a specified expiration window with a configurable tag to track historical structural breaches.
* **Advanced Merging Logic:** To eliminate chart clutter, the script includes options to merge duplicate rays triggering on the same candle, as well as merging same-origin SMTs into a single combined projection point.

---

## How It Works

An SMT Divergence occurs when one asset fails to confirm a new swing high or low made by a correlated asset:

* **Bearish SMT:** The primary asset fails to make a higher high while the correlated asset successfully drives to a higher high, indicating underlying weakness.
* **Bullish SMT:** The primary asset fails to make a lower low while the correlated asset successfully drives to a lower low, indicating underlying strength.

The script runs a safe lookback sequence up to 450 bars to find matching historical pivot structures, compares the relationship between the primary chart and your secondary/tertiary assets, and plots precision lines directly between the corresponding structural points.

---

## Settings and Inputs

### System

* **Real-Time Detection:** When enabled, calculations update dynamically on the live, open bar. When disabled, signals confirm strictly on the close of the candle.
* **Merge Duplicate Rays:** If both tracked assets trigger an SMT divergence on the exact same bar, this option condenses them into a single line with a combined text label.
* **Merge Same-Origin SMTs:** Combines multiple SMT lines originating from the exact same candle, extending the line to the furthest matching historical point and appending an (M) tag.
* **Enable Structure SMT:** Expands the algorithm to look for structural pivot failures in addition to immediate, strict candle-to-candle alignment.
* **Lookback:** Determines how many historical bars the script will scan to find a matching structural pivot point (capped safely up to 500 bars).
* **Min Bars for Line/Label:** Configures the strict visual threshold required before rendering a line or a text label to screen, filtering out negligible, noise-level divergences.

### Broken SMT Mitigation

* **Remove Broken SMTs:** Activates the garbage collection system to handle lines when price violates the divergence level.
* **Bars to Keep After Invalidation:** Determines how long a broken SMT line remains visible on your chart before deletion. Set this to 0 for immediate visual removal.
* **Show (X) Tag on Invalidated:** Appends an (X) character to the text labels of broken levels during their expiration window.
* **Mitigation Logic:** Choose between "Pair Only (Strict)" which invalidates the line if the primary chart and the specific asset break structure, or "All Connected (Global)" which requires all three assets to breach the level before declaring an invalidation.

### Asset Selection and Styling

* **Asset Selection Mode:** Toggle between Automatic, Automatic (No YM), or Custom routing.
* **Check Mode:** Options include "Strict" (where bullish lines check highs and bearish lines check lows) or "Both High & Low" for unrestricted pivot mapping.
* **Styling Groups:** Fully customize visibility, font sizes, colors, line widths, and line styles (Solid, Dashed, Dotted) independently for both Asset 1 and Asset 2 configurations.

## Source Code

````pine
//@version=6
indicator("[Core Convexity] SMT Divergences", shorttitle="[Core Convexity] SMT Divergences", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// =============================================================================
// --- TYPE DEFINITIONS ---
// =============================================================================
type smtDivergence
    line  ln
    label lb
    float price      // Pivot Price of the Current Chart
    float refPrice   // Pivot Price of the Paired Asset
    float extraPrice // Pivot Price of the 3rd Asset (for Global Mitigation)
    int   startBar
    bool  isInvalidated  // Whether this SMT has been broken
    int   invalidatedBar // Bar index when invalidated
    string originalText  // Store original label text for (X) tagging

type smtDetected
    bool   active
    int    startBar
    float  startPrice
    float  endPrice
    float  refPivot  
    float  extraPivot
    bool   isBullish 
    string symbol

// =============================================================================
// --- INPUTS ---
// =============================================================================

// --- System ---
grp_sys = "System"
realtime     = input.bool(true, "Real-Time Detection", group=grp_sys, tooltip="Calculates on the open bar if enabled.")
mergeEnabled = input.bool(true, "Merge Duplicate Rays", group=grp_sys, tooltip="If checked: When both assets trigger an SMT on the same bar, only ONE line is drawn with a combined label.")
timeMerge    = input.bool(true, "Merge Same-Origin SMTs (M)", group=grp_sys, tooltip="If multiple SMTs originate from the EXACT same candle, merge them into the furthest bar and add (M) tag.")
structCheck  = input.bool(true, "Enable Structure SMT", group=grp_sys, tooltip="Checks for structural highs/lows in addition to immediate pivots.")
lookback     = input.int(500, title="Lookback", maxval=500, group=grp_sys, tooltip="How far back to search for a matching pivot point.")
threshold    = input.int(2, title="Min Bars for Line", group=grp_sys, tooltip="Minimum number of bars between pivots required to DISPLAY the SMT line.")
minBarsLabel = input.int(2, title="Min Bars for Label", minval=0, group=grp_sys, tooltip="Minimum number of bars between pivots required to DISPLAY the SMT label. Set to 0 to always show labels with lines.")

// --- Mitigation (Broken SMTs) ---
grp_brk = "Broken SMT Mitigation"
removeBroken    = input.bool(true, "Remove Broken SMTs", group=grp_brk)
expirationBars  = input.int(5, "Bars to Keep After Invalidation", minval=0, group=grp_brk, tooltip="How many bars an invalidated SMT remains visible with (X) tag before being removed. Set to 0 for immediate removal.")
showInvalidTag  = input.bool(true, "Show (X) Tag on Invalidated", group=grp_brk, tooltip="Add (X) tag to labels when SMT is invalidated.")
mitigation      = input.string("Pair Only (Strict)", "Mitigation Logic", options=["Pair Only (Strict)", "All Connected (Global)"], group=grp_brk, tooltip="Pair Only: Removes line if Chart + Paired Asset break.\nAll Connected: Removes line only if Chart + Asset 1 + Asset 2 ALL break.")

// --- Asset Selection ---
mode        = input.string("Automatic", "Asset Selection Mode", options=["Automatic", "Automatic (No YM)", "Custom"], tooltip="Automatic Pairings:\nIndices:\nNQ/MNQ <-> ES/MES & YM/MYM\n\nMetals (Strict Futures Only):\nGC <-> SI\nMGC <-> SIL\n\nNo YM Mode: Removes YM/MYM from the pool for Indices.")
checkMode   = input.string("Both High & Low", "Check Mode", options=["Strict (Bull=High, Bear=Low)", "Both High & Low"])

// --- Styling ---
grp_lbl = "General Styling"
showLabels  = input.bool(true, "Show Labels", group=grp_lbl)
lblSizeInt  = input.int(10, "Font Size", group=grp_lbl)
lblColor    = input.color(color.white, "Text Color", group=grp_lbl)

// --- Asset 1 Custom & Style ---
grp_a1 = "Asset 1 Settings"
c1_enable     = input.bool(true, "Enable Asset 1", group=grp_a1)
c1_ticker     = input.symbol("ES1!", "Symbol", group=grp_a1)
c1_invert     = input.bool(false, "Invert Scale", group=grp_a1)
// Bull
c1_bullCol    = input.color(#00E676, "Bullish Color", group=grp_a1, inline="a1bull")
c1_bullStyle  = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=grp_a1, inline="a1bull")
c1_bullWidth  = input.int(2, "Width", group=grp_a1, inline="a1bull")
// Bear
c1_bearCol    = input.color(#FF5252, "Bearish Color", group=grp_a1, inline="a1bear")
c1_bearStyle  = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=grp_a1, inline="a1bear")
c1_bearWidth  = input.int(2, "Width", group=grp_a1, inline="a1bear")

// --- Asset 2 Custom & Style ---
grp_a2 = "Asset 2 Settings"
c2_enable     = input.bool(false, "Enable Asset 2", group=grp_a2)
c2_ticker     = input.symbol("YM1!", "Symbol", group=grp_a2)
c2_invert     = input.bool(false, "Invert Scale", group=grp_a2)
// Bull
c2_bullCol    = input.color(#2962FF, "Bullish Color", group=grp_a2, inline="a2bull")
c2_bullStyle  = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=grp_a2, inline="a2bull")
c2_bullWidth  = input.int(2, "Width", group=grp_a2, inline="a2bull")
// Bear
c2_bearCol    = input.color(#FF6D00, "Bearish Color", group=grp_a2, inline="a2bear")
c2_bearStyle  = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=grp_a2, inline="a2bear")
c2_bearWidth  = input.int(2, "Width", group=grp_a2, inline="a2bear")

// =============================================================================
// --- LOGIC: STYLING & TICKERS ---
// =============================================================================

getStyle(str) =>
    str == "Dashed" ? line.style_dashed : str == "Dotted" ? line.style_dotted : line.style_solid

is_no_ym = mode == "Automatic (No YM)"

getAutoT1(root) =>
    string t = ""
    // Indices
    if root == "NQ" 
        t := "ES1!"
    else if root == "ES" 
        t := "NQ1!"
    else if root == "YM" 
        t := "NQ1!"
    else if root == "MNQ"
        t := "MES1!"
    else if root == "MES"
        t := "MNQ1!"
    else if root == "MYM"
        t := "MNQ1!"
    // Metals
    else if root == "GC" 
        t := "SI1!"
    else if root == "SI" 
        t := "GC1!"
    else if root == "MGC"
        t := "SIL1!"
    else if root == "SIL"
        t := "MGC1!"
    t

getAutoT2(root) =>
    string t = ""
    // Indices
    if root == "NQ" 
        t := is_no_ym ? "" : "YM1!" 
    else if root == "ES" 
        t := is_no_ym ? "" : "YM1!" 
    else if root == "YM" 
        t := "ES1!"
    else if root == "MNQ"
        t := is_no_ym ? "" : "MYM1!" 
    else if root == "MES"
        t := is_no_ym ? "" : "MYM1!" 
    else if root == "MYM"
        t := "MES1!"
    // Metals (Strict 1-to-1)
    t

root = syminfo.root
auto_t1 = getAutoT1(root)
auto_t2 = getAutoT2(root)

is_auto_mode = mode != "Custom"
final_t1 = is_auto_mode ? auto_t1 : c1_ticker
final_t2 = is_auto_mode ? auto_t2 : c2_ticker

use_t1 = final_t1 != ""
use_t2 = final_t2 != ""

// =============================================================================
// --- DATA FETCHING ---
// =============================================================================

[h1_raw, l1_raw] = request.security(use_t1 ? final_t1 : "", timeframe.period, [high, low], ignore_invalid_symbol=true)
[h2_raw, l2_raw] = request.security(use_t2 ? final_t2 : "", timeframe.period, [high, low], ignore_invalid_symbol=true)

h1 = c1_invert ? 1/l1_raw : h1_raw
l1 = c1_invert ? 1/h1_raw : l1_raw
h2 = c2_invert ? 1/l2_raw : h2_raw
l2 = c2_invert ? 1/h2_raw : l2_raw

// =============================================================================
// --- STATE MANAGEMENT ---
// =============================================================================

var array<smtDivergence> a1_bears = array.new<smtDivergence>()
var array<smtDivergence> a1_bulls = array.new<smtDivergence>()
var float a1_bearPrice = 0.0
var float a1_bullPrice = 0.0

var array<smtDivergence> a2_bears = array.new<smtDivergence>()
var array<smtDivergence> a2_bulls = array.new<smtDivergence>()
var float a2_bearPrice = 0.0
var float a2_bullPrice = 0.0

bool doHigh = checkMode == "Both High & Low" or close > open
bool doLow  = checkMode == "Both High & Low" or close < open
bool globalMitigation = mitigation == "All Connected (Global)"

// =============================================================================
// --- FUNCTIONS ---
// =============================================================================

getSize(s) =>
    s >= 11 ? size.large : s < 10 ? size.small : size.normal

// --- CLEAN TICKER HELPER ---
cleanTicker(t) =>
    string result = t
    int colonPos = str.pos(t, ":")
    if not na(colonPos)
        result := str.substring(t, colonPos + 1)
    result := str.replace_all(result, "1!", "")
    result

// --- CLEANUP EXPIRED INVALIDATED SMTs ---
f_cleanup_expired(_arr) =>
    if _arr.size() > 0
        for i = _arr.size() - 1 to 0
            if i >= _arr.size()
                continue
            smtDivergence item = _arr.get(i)
            if item.isInvalidated and (bar_index - item.invalidatedBar) >= expirationBars
                line.delete(item.ln)
                label.delete(item.lb)
                _arr.remove(i)

// --- BROKEN SMT MANAGEMENT ---
f_manage_stack(_arr, _mainPrice, _refPrice, _extraPrice, _isBull) =>
    float newLimit = 0.0
    if _arr.size() > 0
        for i = _arr.size() - 1 to 0
            if i >= _arr.size()
                continue
            smtDivergence item = _arr.get(i)
            
            // Skip already invalidated items (handled by f_cleanup_expired)
            if item.isInvalidated
                continue
            
            // 1. Chart Break
            bool mainBroken = _isBull ? (_mainPrice < item.price) : (_mainPrice > item.price)
            
            // 2. Paired Asset Break
            bool refBroken = false
            if not na(_refPrice) and not na(item.refPrice)
                refBroken := _isBull ? (_refPrice < item.refPrice) : (_refPrice > item.refPrice)
            else
                refBroken := true
            
            // 3. Global Check (Asset 3 Break)
            bool extraBroken = true 
            if globalMitigation 
                if not na(_extraPrice) and not na(item.extraPrice)
                    if _isBull
                        extraBroken := _extraPrice < item.extraPrice
                    else
                        extraBroken := _extraPrice > item.extraPrice
                else
                    extraBroken := true

            // DECISION
            bool isBroken = false
            if globalMitigation
                isBroken := mainBroken and refBroken and extraBroken
            else
                isBroken := mainBroken and refBroken

            if not isBroken
                newLimit := item.price
                break 
            else
                // SMT is broken - handle based on expiration setting
                if expirationBars > 0
                    // Mark as invalidated and add (X) tag
                    item.isInvalidated := true
                    item.invalidatedBar := bar_index
                    
                    // Update label with (X) tag
                    if showInvalidTag and not na(item.lb)
                        string newText = item.originalText + " (X)"
                        label.set_text(item.lb, newText)
                else
                    // Immediate removal (expirationBars = 0)
                    line.delete(item.ln)
                    label.delete(item.lb)
                    _arr.remove(i)
    newLimit

// --- DETECTION ---
f_detect(_srcMain, _srcRef, _srcExtra, _doCheck, _isBull, _safeLookback) =>
    smtDetected res = smtDetected.new(false, na, na, na, na, na, _isBull, "")
    
    if _doCheck and not na(_srcMain) and not na(_srcRef)
        float currLvl = _srcMain
        int mDist = na, int sDist = na
        
        // Main Scan
        for i = 1 to _safeLookback
            bool cond = _isBull ? (_srcMain[i] <= currLvl) : (_srcMain[i] >= currLvl)
            if cond
                mDist := i
                break
        
        // Ref Scan
        for i = 1 to _safeLookback
            bool cond = _isBull ? (_srcRef[i] <= _srcRef) : (_srcRef[i] >= _srcRef)
            if cond
                sDist := i
                break
        
        bool isSMT = false
        int dDist = na
        
        if not na(mDist) and not na(sDist)
            if math.abs(mDist - sDist) >= 2 
                isSMT := true
                dDist := math.min(mDist, sDist)
        else if (na(mDist) != na(sDist))
            isSMT := true
            dDist := na(mDist) ? sDist : mDist
        
        if structCheck and not isSMT
            if not na(mDist)
                bool structCond = _isBull ? (_srcRef < _srcRef[mDist]) : (_srcRef > _srcRef[mDist])
                if structCond
                    isSMT := true, dDist := mDist
            if not isSMT and not na(sDist)
                bool structCond2 = _isBull ? (currLvl < _srcMain[sDist]) : (currLvl > _srcMain[sDist])
                if structCond2
                    isSMT := true, dDist := sDist
        
        if isSMT and not na(dDist)
            res.active := true
            res.startBar := bar_index - dDist
            res.startPrice := _srcMain[dDist]
            res.endPrice := currLvl
            res.refPivot := _srcRef[dDist]
            if not na(_srcExtra)
                res.extraPivot := _srcExtra[dDist]
            
    res

// --- DRAWING ---
f_draw(_evt, _col, _style, _width, _tickerTxt, _arr, _isBull) =>
    float retLimit = 0.0
    int barDiff = bar_index - _evt.startBar
    
    if barDiff >= threshold
        string finalTxt = _tickerTxt
        bool hasMergeTag = false
        
        if timeMerge and _arr.size() > 0
            for i = _arr.size() - 1 to 0
                if i >= _arr.size()
                    continue
                smtDivergence existItem = _arr.get(i)
                if existItem.startBar == _evt.startBar and not existItem.isInvalidated
                    line.delete(existItem.ln)
                    label.delete(existItem.lb)
                    _arr.remove(i)
                    hasMergeTag := true
                    break 
        
        if hasMergeTag
            finalTxt := finalTxt + " (M)"
        
        ln = line.new(_evt.startBar, _evt.startPrice, bar_index, _evt.endPrice, color=_col, style=_style, width=_width)
        
        label lb = na
        // Only show label if bar difference meets minimum requirement
        if showLabels and barDiff >= minBarsLabel
            int midBar = math.round((_evt.startBar + bar_index) / 2)
            float midPrice = (_evt.startPrice + _evt.endPrice) / 2
            string lblStyle = _isBull ? label.style_label_up : label.style_label_down
            lb := label.new(midBar, midPrice, finalTxt, color=color.new(color.white, 100), style=lblStyle, textcolor=lblColor, size=getSize(lblSizeInt))
        
        float limit = _isBull ? math.min(_evt.startPrice, _evt.endPrice) : math.max(_evt.startPrice, _evt.endPrice)
        
        if removeBroken or timeMerge
            _arr.push(smtDivergence.new(ln, lb, limit, _evt.refPivot, _evt.extraPivot, _evt.startBar, false, 0, finalTxt))
            retLimit := limit
            
    retLimit

// =============================================================================
// --- MAIN EXECUTION ---
// =============================================================================

int safeLookback = math.min(lookback, bar_index - 1, 450)

if bar_index > lookback and safeLookback > 0
    
    // 0. CLEANUP EXPIRED INVALIDATED SMTs (runs every bar)
    if removeBroken and expirationBars > 0
        f_cleanup_expired(a1_bears)
        f_cleanup_expired(a1_bulls)
        f_cleanup_expired(a2_bears)
        f_cleanup_expired(a2_bulls)
    
    // 1. GARBAGE COLLECTION (check for newly broken SMTs)
    if removeBroken
        // A1 Bears: Chart(H) + T1(H1) + T2(H2)
        if high > a1_bearPrice and a1_bearPrice != 0
            a1_bearPrice := f_manage_stack(a1_bears, high, h1, h2, false)
        // A1 Bulls: Chart(L) + T1(L1) + T2(L2)
        if low < a1_bullPrice and a1_bullPrice != 0
            a1_bullPrice := f_manage_stack(a1_bulls, low, l1, l2, true)
        
        // A2 Bears: Chart(H) + T2(H2) + T1(H1)
        if high > a2_bearPrice and a2_bearPrice != 0
            a2_bearPrice := f_manage_stack(a2_bears, high, h2, h1, false)
        // A2 Bulls: Chart(L) + T2(L2) + T1(L1)
        if low < a2_bullPrice and a2_bullPrice != 0
            a2_bullPrice := f_manage_stack(a2_bulls, low, l2, l1, true)

    // 2. DETECTION
    smtDetected a1_bear = smtDetected.new(false)
    smtDetected a1_bull = smtDetected.new(false)
    if use_t1
        a1_bear := f_detect(high, h1, h2, doHigh, false, safeLookback)
        a1_bull := f_detect(low, l1, l2, doLow, true, safeLookback)

    smtDetected a2_bear = smtDetected.new(false)
    smtDetected a2_bull = smtDetected.new(false)
    if use_t2
        a2_bear := f_detect(high, h2, h1, doHigh, false, safeLookback)
        a2_bull := f_detect(low, l2, l1, doLow, true, safeLookback)

    // 3. MERGING & DRAWING
    bool canDraw = realtime ? true : barstate.isconfirmed
    
    if canDraw
        // --- Bears ---
        if mergeEnabled and a1_bear.active and a2_bear.active
            smtDetected merged = a1_bear.startBar <= a2_bear.startBar ? a1_bear : a2_bear
            string txt = "[" + cleanTicker(final_t1) + " + " + cleanTicker(final_t2) + "]"
            float lim = f_draw(merged, c1_bearCol, getStyle(c1_bearStyle), c1_bearWidth, txt, a1_bears, false)
            if removeBroken and lim != 0
                a1_bearPrice := lim
        else
            if a1_bear.active
                float lim = f_draw(a1_bear, c1_bearCol, getStyle(c1_bearStyle), c1_bearWidth, "[" + cleanTicker(final_t1) + "]", a1_bears, false)
                if removeBroken and lim != 0
                    a1_bearPrice := lim
            if a2_bear.active
                float lim = f_draw(a2_bear, c2_bearCol, getStyle(c2_bearStyle), c2_bearWidth, "[" + cleanTicker(final_t2) + "]", a2_bears, false)
                if removeBroken and lim != 0
                    a2_bearPrice := lim

        // --- Bulls ---
        if mergeEnabled and a1_bull.active and a2_bull.active
            smtDetected merged = a1_bull.startBar <= a2_bull.startBar ? a1_bull : a2_bull
            string txt = "[" + cleanTicker(final_t1) + " + " + cleanTicker(final_t2) + "]"
            float lim = f_draw(merged, c1_bullCol, getStyle(c1_bullStyle), c1_bullWidth, txt, a1_bulls, true)
            if removeBroken and lim != 0
                a1_bullPrice := lim
        else
            if a1_bull.active
                float lim = f_draw(a1_bull, c1_bullCol, getStyle(c1_bullStyle), c1_bullWidth, "[" + cleanTicker(final_t1) + "]", a1_bulls, true)
                if removeBroken and lim != 0
                    a1_bullPrice := lim
            if a2_bull.active
                float lim = f_draw(a2_bull, c2_bullCol, getStyle(c2_bullStyle), c2_bullWidth, "[" + cleanTicker(final_t2) + "]", a2_bulls, true)
                if removeBroken and lim != 0
                    a2_bullPrice := lim
````

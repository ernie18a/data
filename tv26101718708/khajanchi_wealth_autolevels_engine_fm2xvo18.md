# Khajanchi Wealth Auto-Levels Engine

- url: https://www.tradingview.com/script/Fm2XvO18-Khajanchi-Wealth-Auto-Levels-Engine/
- type: indicator
- pine_id: PUB;310ab51ba95b4c95bd4ae598092444d1
- version: 4.0

## Description

Institutional trend regime detection, dynamic pivot levels, automated Fibonacci extension clusters, and live HUD telemetry.

Overview
The Khajanchi Wealth Auto-Levels Engine is an institutional-grade chart overlay designed to systematically identify market regimes, structural support and resistance levels, and objective expansion targets without visual clutter. It combines multi-timeframe moving average mechanics with dynamic swing pivots and projected Fibonacci clusters.

Core Features
   * Trend & Regime Tracking
   * 50 & 200 Simple Moving Averages (SMA): Identifies macro bias and key institutional dynamic reaction zones.
   * Automated Golden / Death Cross Signals: Visual triangle markers and built-in alert triggers when intermediate and long-term trend alignment confirms.
   * Repaint-Safe Dynamic Pivots
   * Plots confirmed structural support (green) and resistance (red) levels based on configurable lookback pivot highs and lows.
   * Uses non-repainting historical swing confirmation to mark institutional liquidity pools.
   * Dynamic Fibonacci Projection & Golden Pocket Clusters
   * Automatically projects directional Fibonacci levels from active swing structures.
   * Automatically isolates the 0.618 Golden Pocket retracement zone and 1.618 Extension Target with forward-projecting price tags.
   * Live Regime Telemetry HUD
   * High-contrast, lightweight dashboard docked in the top-right corner displaying real-time metrics:
     * Regime Bias: Bullish/Bearish posture relative to the 200 SMA.
     * 50/200 Stack Alignment: Golden vs. Death alignment status.
     * Distance to 200 SMA (%): Real-time mean-reversion expansion/contraction percentage.
     * 200 SMA Reference Level: Exact numeric price level for institutional order placement.

How to Trade With It
 * Trend Confirmation: Look for longs when price holds above the 200 SMA and the HUD indicates a Bullish regime.
 * Pullback Entries: Monitor the 0.618 Golden Pocket line and Key Support for high-probability structural confluence.
 * Profit Targets: Use the 1.618 Target Extension level as an objective take-profit area on swing extensions.

## Source Code

````pine
//@version=6
indicator("Khajanchi Wealth Auto-Levels Engine", shorttitle="KW Levels", overlay=true, max_boxes_count=100, max_lines_count=100)

// =============================================================================
// SETTINGS TAB
// =============================================================================
GRP_PROX = "1. Auto-Volatility & Rendering Engine"
proxMultiplier = input.float(3.0, "ATR Proximity Multiplier (Tightened)", minval=1.0, group=GRP_PROX)
projBars       = input.int(15, "Forward Projection (Bars)", minval=5, maxval=50, group=GRP_PROX)
hideMitigated  = input.bool(true, "Hide Mitigated Zones (Cleans Chart)", group=GRP_PROX) // NEW: The ultimate clutter killer
colZoneText    = input.color(color.new(#000000, 0), "Zone Text Color", group=GRP_PROX) 

GRP_LIQ = "2. Macro Liquidity Lines (Floating)"
showPDHL = input.bool(true, "Show Previous Day High/Low (PDH/PDL)", group=GRP_LIQ)
showPWHL = input.bool(true, "Show Previous Week High/Low (PWH/PWL)", group=GRP_LIQ)
colPDHL  = input.color(color.new(#9E9E9E, 30), "PDH/PDL Color", group=GRP_LIQ)
colPWHL  = input.color(color.new(#FFD700, 30), "PWH/PWL Color", group=GRP_LIQ)

GRP_FVG = "3. Fair Value Gaps (Imbalances)"
showFVG = input.bool(true, "Show Active FVGs", group=GRP_FVG)
colBullFVG = input.color(color.new(#00E676, 90), "Bullish FVG (Demand)", group=GRP_FVG) 
colBearFVG = input.color(color.new(#EF5350, 90), "Bearish FVG (Supply)", group=GRP_FVG) 

GRP_OB = "4. Institutional Order Blocks"
showOB = input.bool(true, "Show Order Blocks", group=GRP_OB)
obLookback = input.int(5, "OB Pivot Lookback", minval=2, group=GRP_OB)
colBullOB = input.color(color.new(#2962FF, 90), "Bullish OB", group=GRP_OB) 
colBearOB = input.color(color.new(#FFB300, 90), "Bearish OB", group=GRP_OB) 

GRP_HUD = "5. SMC Telemetry HUD"
showHUD = input.bool(true, "Show SMC Dashboard", group=GRP_HUD)
hudPosInput = input.string("Middle Left", "HUD Position", options=["Top Left", "Middle Left", "Bottom Left"], group=GRP_HUD)

// =============================================================================
// PROXIMITY MATH (NORMALIZED ATR)
// =============================================================================
float current_atr = ta.atr(14)
float natr_pct = current_atr / close
float dynamicProx = natr_pct * proxMultiplier

float upperBound = close * (1 + dynamicProx)
float lowerBound = close * (1 - dynamicProx)

var box[] bull_fvg_boxes = array.new_box()
var box[] bear_fvg_boxes = array.new_box()
var box[] bull_ob_boxes  = array.new_box()
var box[] bear_ob_boxes  = array.new_box()

float nearest_demand = na
float nearest_supply = na
int active_fvg_count = 0

// =============================================================================
// 1. FAIR VALUE GAPS (FVG)
// =============================================================================
bool bull_fvg = low > high[2] and close[1] > high[2]
bool bear_fvg = high < low[2] and close[1] < low[2]

if showFVG
    if bull_fvg
        b = box.new(left=bar_index[2], top=low, right=bar_index+projBars, bottom=high[2], border_color=na, bgcolor=colBullFVG, text="FVG", text_size=size.tiny, text_color=colZoneText)
        array.push(bull_fvg_boxes, b)
    if bear_fvg
        b = box.new(left=bar_index[2], top=low[2], right=bar_index+projBars, bottom=high, border_color=na, bgcolor=colBearFVG, text="FVG", text_size=size.tiny, text_color=colZoneText)
        array.push(bear_fvg_boxes, b)

if array.size(bull_fvg_boxes) > 0
    for i = array.size(bull_fvg_boxes) - 1 to 0
        b = array.get(bull_fvg_boxes, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        if low < bot 
            if hideMitigated
                box.delete(b) // Delete visually if mitigated
            else
                box.set_right(b, bar_index)
            array.remove(bull_fvg_boxes, i)
        else 
            box.set_right(b, bar_index + projBars)
            if top >= lowerBound and bot <= upperBound 
                box.set_bgcolor(b, colBullFVG)
                box.set_text_color(b, colZoneText)
                active_fvg_count += 1
                if top < close
                    nearest_demand := na(nearest_demand) ? top : math.max(nearest_demand, top)
            else
                box.set_bgcolor(b, na) 
                box.set_text_color(b, na)

if array.size(bear_fvg_boxes) > 0
    for i = array.size(bear_fvg_boxes) - 1 to 0
        b = array.get(bear_fvg_boxes, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        if high > top 
            if hideMitigated
                box.delete(b)
            else
                box.set_right(b, bar_index)
            array.remove(bear_fvg_boxes, i)
        else 
            box.set_right(b, bar_index + projBars)
            if top >= lowerBound and bot <= upperBound 
                box.set_bgcolor(b, colBearFVG)
                box.set_text_color(b, colZoneText)
                active_fvg_count += 1
                if bot > close
                    nearest_supply := na(nearest_supply) ? bot : math.min(nearest_supply, bot)
            else
                box.set_bgcolor(b, na)
                box.set_text_color(b, na)

// =============================================================================
// 2. INSTITUTIONAL ORDER BLOCKS (OBs)
// =============================================================================
float ph = ta.pivothigh(high, obLookback, obLookback)
float pl = ta.pivotlow(low, obLookback, obLookback)

if showOB
    if not na(pl)
        b = box.new(left=bar_index[obLookback], top=high[obLookback], right=bar_index+projBars, bottom=low[obLookback], border_color=color.new(colBullOB, 60), border_style=line.style_dashed, bgcolor=colBullOB, text="OB", text_size=size.tiny, text_color=colZoneText)
        array.push(bull_ob_boxes, b)
    if not na(ph)
        b = box.new(left=bar_index[obLookback], top=high[obLookback], right=bar_index+projBars, bottom=low[obLookback], border_color=color.new(colBearOB, 60), border_style=line.style_dashed, bgcolor=colBearOB, text="OB", text_size=size.tiny, text_color=colZoneText)
        array.push(bear_ob_boxes, b)

if array.size(bull_ob_boxes) > 0
    for i = array.size(bull_ob_boxes) - 1 to 0
        b = array.get(bull_ob_boxes, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        if close < bot 
            if hideMitigated
                box.delete(b)
            else
                box.set_right(b, bar_index)
            array.remove(bull_ob_boxes, i)
        else
            box.set_right(b, bar_index + projBars)
            if top >= lowerBound and bot <= upperBound
                box.set_bgcolor(b, colBullOB)
                box.set_text_color(b, colZoneText)
                box.set_border_color(b, color.new(colBullOB, 60))
                if top < close
                    nearest_demand := na(nearest_demand) ? top : math.max(nearest_demand, top)
            else
                box.set_bgcolor(b, na)
                box.set_text_color(b, na)
                box.set_border_color(b, na)

if array.size(bear_ob_boxes) > 0
    for i = array.size(bear_ob_boxes) - 1 to 0
        b = array.get(bear_ob_boxes, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        if close > top 
            if hideMitigated
                box.delete(b)
            else
                box.set_right(b, bar_index)
            array.remove(bear_ob_boxes, i)
        else
            box.set_right(b, bar_index + projBars)
            if top >= lowerBound and bot <= upperBound
                box.set_bgcolor(b, colBearOB)
                box.set_text_color(b, colZoneText)
                box.set_border_color(b, color.new(colBearOB, 60))
                if bot > close
                    nearest_supply := na(nearest_supply) ? bot : math.min(nearest_supply, bot)
            else
                box.set_bgcolor(b, na)
                box.set_text_color(b, na)
                box.set_border_color(b, na)

// =============================================================================
// 3. MACRO LIQUIDITY (FLOATING LINES)
// =============================================================================
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line line_pdh = na
var line line_pdl = na
var line line_pwh = na
var line line_pwl = na

if barstate.islast
    int lineStart = bar_index - 50 
    int lineEnd   = bar_index + projBars
    
    if showPDHL
        if na(line_pdh)
            line_pdh := line.new(lineStart, pdh, lineEnd, pdh, color=colPDHL, style=line.style_dashed, width=1)
            line_pdl := line.new(lineStart, pdl, lineEnd, pdl, color=colPDHL, style=line.style_dashed, width=1)
        else
            line.set_xy1(line_pdh, lineStart, pdh)
            line.set_xy2(line_pdh, lineEnd, pdh)
            line.set_xy1(line_pdl, lineStart, pdl)
            line.set_xy2(line_pdl, lineEnd, pdl)
            
    if showPWHL
        if na(line_pwh)
            line_pwh := line.new(lineStart, pwh, lineEnd, pwh, color=colPWHL, style=line.style_solid, width=2)
            line_pwl := line.new(lineStart, pwl, lineEnd, pwl, color=colPWHL, style=line.style_solid, width=2)
        else
            line.set_xy1(line_pwh, lineStart, pwh)
            line.set_xy2(line_pwh, lineEnd, pwh)
            line.set_xy1(line_pwl, lineStart, pwl)
            line.set_xy2(line_pwl, lineEnd, pwl)

// =============================================================================
// 4. SMC TELEMETRY HUD
// =============================================================================
string hudPos = hudPosInput == "Top Left" ? position.top_left : hudPosInput == "Bottom Left" ? position.bottom_left : position.middle_left
var table hud = table.new(hudPos, 2, 6, bgcolor = color.new(#121826, 5), border_width = 1, border_color = color.new(#2A374A, 0))

if showHUD and barstate.islast
    string dem_dist = na(nearest_demand) ? "N/A" : str.tostring(((close - nearest_demand) / close) * 100, "#.1") + "%"
    string sup_dist = na(nearest_supply) ? "N/A" : str.tostring(((nearest_supply - close) / close) * 100, "#.1") + "%"
    
    string liq_status = "Inside PDH/PDL"
    color liq_col = color.new(#9E9E9E, 0)
    if close > pdh
        liq_status := "PDH Swept (Bullish)"
        liq_col := color.new(#00E676, 0)
    else if close < pdl
        liq_status := "PDL Swept (Bearish)"
        liq_col := color.new(#EF5350, 0)

    table.cell(hud, 0, 0, "SMC LIQUIDITY TELEMETRY", text_color=color.new(#FFD700,0), text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 0, "±" + str.tostring(dynamicProx * 100, "#.1") + "% (Auto)", text_color=color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(hud, 0, 1, "Nearest Supply (OB/FVG)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 1, na(nearest_supply) ? "Searching..." : str.tostring(nearest_supply, format.mintick) + " (+" + sup_dist + ")", text_color=color.new(#EF5350, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(hud, 0, 2, "Nearest Demand (OB/FVG)", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 2, na(nearest_demand) ? "Searching..." : str.tostring(nearest_demand, format.mintick) + " (-" + dem_dist + ")", text_color=color.new(#00E676, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(hud, 0, 3, "Active Local Imbalances", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 3, str.tostring(active_fvg_count) + " Unfilled Gaps", text_color=active_fvg_count > 0 ? color.new(#00B0FF, 0) : color.new(#9E9E9E,0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(hud, 0, 4, "Session Liquidity", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 4, liq_status, text_color=liq_col, text_size=size.small, text_halign=text.align_right)
````

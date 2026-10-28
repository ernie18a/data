# Dynamic Multi-DTE Call Wall Levels (RRR)

- url: https://www.tradingview.com/script/Y8bWiZMG-Dynamic-Multi-DTE-Call-Wall-Levels-RRR/
- type: indicator
- pine_id: PUB;7f2e33161ff941588f4b9cc55a06e1cb
- version: 8.0

## Description

Dynamic Multi-DTE Call Wall Levels (RRR)

This Pine Script v6 overlay indicator dynamically maps critical options market structure directly onto your price chart, identifying areas of high options concentration that act as institutional support, resistance, or volatility triggers.

Premium Data Feed: The script relies on TradingView’s native OPRA (Options Price Reporting Authority) real-time data subscription. By using dynamic string generation with the OPRA: prefix, it bypasses the need for costly third-party APIs, querying precise, strike-by-strike data directly from the exchange.

Dynamic Expiration Engine: Automatically calculates and rolls the precise YYMMDD string for three distinct time horizons: Nearest Expiry (0DTE or daily equivalent), Nearest Friday (7DTE), and +28Days (macro exposure). It mathematically adjusts for single stocks (Friday-only) versus daily ETFs (SPY/QQQ).

Exposure Visualization Logic:

Anchor & Scan: The script identifies the current At-The-Money (ATM) strike and queries the volume for a user-defined basket of strikes above and below the current price.

Peak Identification: It pushes the real-time volume data into a v6 array, instantly identifying the single strike with the maximum volume—the "Call Wall." This level represents the highest concentration of dealer gamma exposure.

Persistent Plotting: The macro and micro Call Walls are plotted as distinct horizontal lines (using trackprice=true) across the chart.

EOD Freeze Mechanism: Using session.ismarket, the script stops pinging the chain at the 4:00 PM EST close, locking the final levels in memory and projecting them across the overnight and pre-market sessions for continuous visualization.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RickyRicardo18

//@version=6
// =========================================================================
// INDICATOR:  Call/Put Wall Locator (RRR)
// DESCRIPTION: 
// This script maps structural options liquidity by identifying the highest
// volume strikes ("Walls") across three distinct time horizons (0DTE, 7DTE, 30DTE). 
// 
// KEY FEATURES & WORKAROUNDS:
// - OPRA Data Routing: Generates explicit OCC/OPRA ticker strings perfectly 
//   formatted for TradingView's options data engine.
// - Dynamic Scan Throttle: Pine Script limits `request.security` to 40 calls. 
//   This engine bypasses that limitation by dynamically reallocating data capacity. 
//   Disabling timeframes automatically widens the strike scan range (up to +/- 19 strikes).
// - Mega Wall Detector: Highlights massive structural confluence with a distinct visual 
//   cue when multiple timeframes target the exact same strike.
// =========================================================================

indicator(" Call/Put Wall Locator (RRR)", overlay=true)

string underlying = syminfo.root

// --- CORE PARAMETERS ---
string optType     = input.string("Call", title="Option Type", options=["Call", "Put"], group="Core Parameters", tooltip="Select 'Call' to map upside resistance liquidity, or 'Put' to map downside support liquidity.")
float anchorStrike = input.float(765.0, "Anchor Strike", group="Core Parameters", tooltip="Set this near the current asset price. The script will build its scan range above and below this specific anchor.")
float strikeStep   = input.float(1.0, "Strike Step", group="Core Parameters", tooltip="The standard strike interval for the chain. E.g., 1.0 for SPY, 2.5 or 5.0 for major equities like AAPL.")

// --- TIMEFRAMES ---
string expCycle    = input.string("Daily / Intra-Week", title="Expiration Cycle", options=["Daily / Intra-Week", "Standard Friday"], group="Timeframes", tooltip="Select 'Daily / Intra-Week' to anchor 0DTE to today. Select 'Standard Friday' for tickers that only list Friday expirations.")
bool show0DTE      = input.bool(true, "Enable 0DTE Bucket", group="Timeframes", tooltip="Disabling a bucket automatically frees up script memory, allowing the engine to scan a significantly wider range of strikes for the remaining active timeframes.")
bool show7DTE      = input.bool(true, "Enable 7DTE Bucket", group="Timeframes")
bool show30DTE     = input.bool(true, "Enable 30DTE Bucket", group="Timeframes")

// --- VISUAL SETTINGS ---
color col0DTE  = input.color(color.red, "0DTE Line Color", group="Visuals")
color col7DTE  = input.color(color.orange, "7DTE Line Color", group="Visuals")
color col30DTE = input.color(color.fuchsia, "30DTE Line Color", group="Visuals")
color colMega  = input.color(color.white, "Mega Wall Confluence Color", group="Visuals", tooltip="The color used when multiple timeframes converge on the exact same strike price.")

// --- MANUAL CALENDAR OVERRIDES ---
string ovr0DTE  = input.string("", "0DTE Date Override (YYMMDD)", group="Manual Calendar Overrides", tooltip="Use this to bypass the automated calendar math during holiday weeks or to explicitly target a specific quarterly OpEx date.")
string ovr7DTE  = input.string("", "7DTE Date Override (YYMMDD)", group="Manual Calendar Overrides")
string ovr30DTE = input.string("", "30DTE Date Override (YYMMDD)", group="Manual Calendar Overrides")

// --- FULLY AUTOMATED SCAN THROTTLE ---
int activeBuckets = (show0DTE ? 1 : 0) + (show7DTE ? 1 : 0) + (show30DTE ? 1 : 0)
int effScan       = activeBuckets == 0 ? 0 : math.floor(((40 / activeBuckets) - 1) / 2)

// --- ATM EQUIVALENT ---
float recAnchor = math.round(close / strikeStep) * strikeStep

get_live_expDates() =>
    int dow = dayofweek(timenow, syminfo.timezone)
    int msPerDay = 86400000
    
    int y = year(timenow, syminfo.timezone)
    int m = month(timenow, syminfo.timezone)
    int d = dayofmonth(timenow, syminfo.timezone)
    int t_midday = timestamp(syminfo.timezone, y, m, d, 12, 0, 0)
    
    int daysTo0 = 0
    if expCycle == "Standard Friday"
        daysTo0 := (13 - dow) % 7 
    else
        if dow == dayofweek.saturday
            daysTo0 := 2
        else if dow == dayofweek.sunday
            daysTo0 := 1
            
    int t_0dte = t_midday + (daysTo0 * msPerDay)
    
    // 7DTE strictly anchors to the upcoming Friday that does not collide with 0DTE
    int daysToFriday = (13 - dow) % 7
    int t_7dte = t_midday + (daysToFriday * msPerDay)
    
    if t_7dte <= t_0dte
        t_7dte += (7 * msPerDay)
        
    int t_30dte = t_7dte + (28 * msPerDay)
    
    array<int> timestamps = array.from(t_0dte, t_7dte, t_30dte)
    array<string> dates = array.new<string>()
    
    for i = 0 to 2
        int ts = array.get(timestamps, i)
        int ts_y = year(ts, syminfo.timezone) % 100
        string yy = ts_y < 10 ? "0" + str.tostring(ts_y) : str.tostring(ts_y)
        int ts_m = month(ts, syminfo.timezone)
        string mm = ts_m < 10 ? "0" + str.tostring(ts_m) : str.tostring(ts_m)
        int ts_d = dayofmonth(ts, syminfo.timezone)
        string dd = ts_d < 10 ? "0" + str.tostring(ts_d) : str.tostring(ts_d)
        
        string calcDate = yy + mm + dd
        string finalDate = calcDate
        
        if i == 0 and ovr0DTE != ""
            finalDate := ovr0DTE
        else if i == 1 and ovr7DTE != ""
            finalDate := ovr7DTE
        else if i == 2 and ovr30DTE != ""
            finalDate := ovr30DTE
            
        array.push(dates, finalDate)
    dates

format_strike(float strike) =>
    string s = str.tostring(strike)
    if not str.contains(s, ".")
        s += ".0"
    s

// --- GLOBAL EXECUTION ---
array<string> expDates = get_live_expDates()
string optLetter = (optType == "Call") ? "C" : "P"

array<float> finalWalls = array.new<float>(3, na)
array<float> finalMaxVols = array.new<float>(3, 0)
array<string> finalTicks = array.new<string>(3, "DISABLED")

if activeBuckets > 0
    array<string> activeExps = array.new<string>()
    array<int> activeIds = array.new<int>()
    
    if show0DTE
        array.push(activeExps, array.get(expDates, 0))
        array.push(activeIds, 0)
    if show7DTE
        array.push(activeExps, array.get(expDates, 1))
        array.push(activeIds, 1)
    if show30DTE
        array.push(activeExps, array.get(expDates, 2))
        array.push(activeIds, 2)
        
    for idx = 0 to array.size(activeExps) - 1
        string exp = array.get(activeExps, idx)
        int bId = array.get(activeIds, idx)
        
        array<float> strikesArray = array.new<float>()
        array<float> volumesArray = array.new<float>()
        
        for i = -effScan to effScan
            float currentStrike = anchorStrike + (i * strikeStep)
            string tickerString = "OPRA:" + underlying + exp + optLetter + format_strike(currentStrike)
            
            float optVol = request.security(tickerString, "D", volume, gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
            
            array.push(strikesArray, currentStrike)
            array.push(volumesArray, nz(optVol))
            
        float maxVol = array.max(volumesArray)
        int maxVolIndex = array.indexof(volumesArray, maxVol)
        
        float wallStrike = na
        string winningTicker = "No Data"
        
        if maxVolIndex != -1 and maxVol > 0
            wallStrike := array.get(strikesArray, maxVolIndex)
            winningTicker := "OPRA:" + underlying + exp + optLetter + format_strike(wallStrike)
            
        array.set(finalWalls, bId, wallStrike)
        array.set(finalMaxVols, bId, maxVol)
        array.set(finalTicks, bId, winningTicker)

// --- MEGA WALL CONFLUENCE DETECTOR ---
bool isMega = false
float megaStrike = na

if activeBuckets > 1
    bool allMatch = true
    float firstStrike = na
    
    for bId = 0 to 2
        bool isActive = (bId == 0 and show0DTE) or (bId == 1 and show7DTE) or (bId == 2 and show30DTE)
        if isActive
            float w = array.get(finalWalls, bId)
            if na(firstStrike)
                firstStrike := w
            else if firstStrike != w
                allMatch := false
                
    if allMatch and not na(firstStrike)
        isMega := true
        megaStrike := firstStrike

// --- STREAMLINED FEED VALIDATION ---
string valTicker = "OPRA:" + underlying + array.get(expDates, 0) + optLetter + format_strike(anchorStrike)
float totalVol = nz(array.get(finalMaxVols, 0)) + nz(array.get(finalMaxVols, 1)) + nz(array.get(finalMaxVols, 2))

string feedStatus = totalVol > 0 ? "CONNECTED (Active)" : "DISCONNECTED (No Vol/Sym)"
color feedColor = totalVol > 0 ? color.green : color.maroon

// --- VISUAL RENDERING (DRAWING OBJECTS) ---
var line line0DTE = na
var line line7DTE = na
var line line30DTE = na
var line lineMega = na

if barstate.islast
    float w0 = array.get(finalWalls, 0)
    float w7 = array.get(finalWalls, 1)
    float w30 = array.get(finalWalls, 2)
    
    if isMega
        if na(lineMega)
            lineMega := line.new(bar_index - 1, megaStrike, bar_index, megaStrike, color=colMega, width=4, style=line.style_solid, extend=extend.both)
        else
            line.set_xy1(lineMega, bar_index - 1, megaStrike)
            line.set_xy2(lineMega, bar_index, megaStrike)
            
        if not na(line0DTE)
            line.delete(line0DTE)
            line0DTE := na
        if not na(line7DTE)
            line.delete(line7DTE)
            line7DTE := na
        if not na(line30DTE)
            line.delete(line30DTE)
            line30DTE := na
    else
        if not na(lineMega)
            line.delete(lineMega)
            lineMega := na
            
        if not na(w0) and show0DTE
            if na(line0DTE)
                line0DTE := line.new(bar_index - 1, w0, bar_index, w0, color=col0DTE, width=2, style=line.style_solid, extend=extend.both)
            else
                line.set_xy1(line0DTE, bar_index - 1, w0)
                line.set_xy2(line0DTE, bar_index, w0)
        else if not na(line0DTE)
            line.delete(line0DTE)
            line0DTE := na

        if not na(w7) and show7DTE
            if na(line7DTE)
                line7DTE := line.new(bar_index - 1, w7, bar_index, w7, color=col7DTE, width=2, style=line.style_dashed, extend=extend.both)
            else
                line.set_xy1(line7DTE, bar_index - 1, w7)
                line.set_xy2(line7DTE, bar_index, w7)
        else if not na(line7DTE)
            line.delete(line7DTE)
            line7DTE := na

        if not na(w30) and show30DTE
            if na(line30DTE)
                line30DTE := line.new(bar_index - 1, w30, bar_index, w30, color=col30DTE, width=3, style=line.style_solid, extend=extend.both)
            else
                line.set_xy1(line30DTE, bar_index - 1, w30)
                line.set_xy2(line30DTE, bar_index, w30)
        else if not na(line30DTE)
            line.delete(line30DTE)
            line30DTE := na

// --- EXPANDED DIAGNOSTIC DASHBOARD ---
var table diagDash = table.new(position.top_right, 3, 9, border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    color headerBg = color.new(color.blue, 70)
    color dataBg   = color.new(color.black, 50)
    color offBg    = color.new(color.black, 80)
    
    float anchorDiff = math.abs(anchorStrike - recAnchor)
    color anchorStatusBg = (anchorDiff <= (effScan * strikeStep)) ? color.new(color.green, 70) : color.new(color.maroon, 70)
    string titleCol2 = isMega ? "[ MEGA WALL CONFLUENCE ]" : "Winning Ticker (Scan: +/- " + str.tostring(effScan) + ")"
    
    table.cell(diagDash, 0, 0, "Bucket (" + optType + ")", text_color=color.white, bgcolor=headerBg)
    table.cell(diagDash, 1, 0, titleCol2, text_color=isMega ? colMega : color.white, bgcolor=headerBg)
    table.cell(diagDash, 2, 0, "Max Vol", text_color=color.white, bgcolor=headerBg)
    
    table.cell(diagDash, 0, 1, "0DTE", text_color=show0DTE ? col0DTE : color.gray, bgcolor=show0DTE ? dataBg : offBg)
    table.cell(diagDash, 1, 1, array.get(finalTicks, 0), text_color=color.silver, bgcolor=show0DTE ? dataBg : offBg, text_font_family=font.family_monospace)
    table.cell(diagDash, 2, 1, show0DTE ? str.tostring(array.get(finalMaxVols, 0)) : "-", text_color=color.white, bgcolor=show0DTE ? dataBg : offBg)
    
    table.cell(diagDash, 0, 2, "7DTE", text_color=show7DTE ? col7DTE : color.gray, bgcolor=show7DTE ? dataBg : offBg)
    table.cell(diagDash, 1, 2, array.get(finalTicks, 1), text_color=color.silver, bgcolor=show7DTE ? dataBg : offBg, text_font_family=font.family_monospace)
    table.cell(diagDash, 2, 2, show7DTE ? str.tostring(array.get(finalMaxVols, 1)) : "-", text_color=color.white, bgcolor=show7DTE ? dataBg : offBg)
    
    table.cell(diagDash, 0, 3, "30DTE", text_color=show30DTE ? col30DTE : color.gray, bgcolor=show30DTE ? dataBg : offBg)
    table.cell(diagDash, 1, 3, array.get(finalTicks, 2), text_color=color.silver, bgcolor=show30DTE ? dataBg : offBg, text_font_family=font.family_monospace)
    table.cell(diagDash, 2, 3, show30DTE ? str.tostring(array.get(finalMaxVols, 2)) : "-", text_color=color.white, bgcolor=show30DTE ? dataBg : offBg)
    
    table.cell(diagDash, 0, 4, "USER SETTING", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(diagDash, 1, 4, "Anchor / Strike Step", text_color=color.silver, bgcolor=dataBg)
    table.cell(diagDash, 2, 4, str.tostring(anchorStrike) + " / " + str.tostring(strikeStep), text_color=color.white, bgcolor=dataBg, text_font_family=font.family_monospace)

    table.cell(diagDash, 0, 5, "SYSTEM REC", text_color=color.white, bgcolor=anchorStatusBg)
    table.cell(diagDash, 1, 5, "Live ATM Equivalent", text_color=color.silver, bgcolor=dataBg)
    table.cell(diagDash, 2, 5, str.tostring(recAnchor), text_color=color.white, bgcolor=dataBg, text_font_family=font.family_monospace)

    table.cell(diagDash, 0, 6, "FEED DIAGNOSTIC", text_color=color.white, bgcolor=color.new(color.purple, 70), text_halign=text.align_center)
    table.merge_cells(diagDash, 0, 6, 2, 6)

    table.cell(diagDash, 0, 7, "Test Ticker", text_color=color.silver, bgcolor=dataBg)
    table.cell(diagDash, 1, 7, valTicker, text_color=color.white, bgcolor=dataBg, text_font_family=font.family_monospace)
    table.merge_cells(diagDash, 1, 7, 2, 7)

    table.cell(diagDash, 0, 8, "CONNECTION STATUS", text_color=color.white, bgcolor=feedColor)
    table.cell(diagDash, 1, 8, feedStatus, text_color=color.white, bgcolor=feedColor, text_font_family=font.family_monospace)
    table.merge_cells(diagDash, 1, 8, 2, 8)
````

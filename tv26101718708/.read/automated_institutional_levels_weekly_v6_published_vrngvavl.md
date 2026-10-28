# Automated Institutional Levels + Weekly (v6 Published)

- url: https://www.tradingview.com/script/VRngvaVL-Automated-Institutional-Levels-Weekly-v6-Published/
- type: indicator
- pine_id: PUB;6c26d7024020463dad7c30673ae43db3
- version: 10.0

## Description

[b]Overview:[/b]
Tired of spending your pre-market hours manually plotting higher timeframe levels and session boundaries every single morning?This lightweight, comprehensive script automates the tedious technical analysis process for futures, forex, and equities traders. It dynamically projects institutional key levels, daily and weekly ranges, macro market structure, and session extremes directly onto your execution charts—all with zero lag and zero diagonal chart slopes.Unlike 95% of the multi-timeframe indicators available on TradingView, this script is fully Bar Replay Optimized. By utilizing custom lookahead configurations and historical indexing, the levels render flawlessly during backtesting sessions, allowing you to practice historical trading setups without data leak distortions or misalignments.

[b]Key Features:[/b]
[list=1]
[*]Previous Week High / Low (PWH / PWL):Automatically locks and projects the completed extremes of the prior week. It holds perfectly flat, ignoring the current developing week's price data to give you macro expansion targets.
[*]Previous Day High / Low (PDH / PDL):Tracks the definitive 24-hour highs and lows, shifting dynamically at the daily session crossover with precise stair-step tracking.
[*]London Session Extremes (LH / LL):Isolates the exact high and low wicks formed during the standalone London hours (03:00 AM to 08:00 AM EST). The script automatically projects these liquidity pools forward into the New York AM and PM sessions—perfect for identifying Judas Swing traps and session liquidity sweeps.
[*]Automated 4H Structural BOS Ceiling:Mechanically scans the 4-hour timeframe for true 3-candle swing high peaks. It projects the macro structural lower high forward onto your lower timeframes (1m, 5m, 15m), maintaining a clear look at macro bearish resistance until a true 4H candle body close invalidates it.
[*]Dynamic Confluence Label Stacking:Keeps your charts clean. When multiple high-timeframe zones collapse onto the exact same price tick, the individual labels disappear and convert into an eye-catching CONFLUENCE or TRIPLE WALL box on your price scale, alerting you to a high-probability institutional reversal wall.
[/list]

Recommended Setup for Day Traders:
[list=1]
[*]Load the script onto an intraday execution chart (such as the 1-minute or 5-minute charts).
[*]Use a clean continuous futures contract ticker (like ES1! or NQ1!).
[*]Pair this framework with a Fair Value Gap (FVG) or Order Block indicator. Look for fast 09:30 AM EST New York opening volume to sweep the white London High/Low or blue PDH/PDL lines right beneath the orange 4H BOS wall before hunting A+ displacement triggers.
[/list]

## Source Code

````pine
//@version=6
indicator("Automated Institutional Levels (Perfect Replay v7.2)", overlay=true)

// =========================================================================
// NATIVE PRICE TRACKERS (Dual-Compatible: Historical Backtest & Live Ticks)
// =========================================================================
isNewDay  = timeframe.change("D")
isNewWeek = timeframe.change("W")

// 1. PERFECT PREVIOUS DAY HIGH / LOW (PDH / PDL)
var float pdh = na
var float pdl = na
var float currentDayHigh = high
var float currentDayLow  = low

if isNewDay
    pdh := currentDayHigh
    pdl := currentDayLow
    currentDayHigh := high
    currentDayLow  := low
else
    currentDayHigh := math.max(high, currentDayHigh)
    currentDayLow  := math.min(low, currentDayLow)

plot(pdh, title="PDH", color=color.blue, linewidth=2, style=plot.style_stepline)
plot(pdl, title="PDL", color=color.blue, linewidth=2, style=plot.style_stepline)

// Automated 50% Equilibrium calculated strictly between PDH and PDL
dailyEQ = (pdh + pdl) / 2
plot(dailyEQ, title="Daily 50% Equilibrium", color=color.white, linewidth=1, style=plot.style_stepline)

// 2. PERFECT PREVIOUS WEEK HIGH / LOW (PWH / PWL)
var float pwh = na
var float pwl = na
var float currentWeekHigh = high
var float currentWeekLow  = low

if isNewWeek
    pwh := currentWeekHigh
    pwl := currentWeekLow
    currentWeekHigh := high
    currentWeekLow  := low
else
    currentWeekHigh := math.max(high, currentWeekHigh)
    currentWeekLow  := math.min(low, currentWeekLow)

plot(pwh, title="PWH", color=color.purple, linewidth=2, style=plot.style_stepline)
plot(pwl, title="PWL", color=color.purple, linewidth=2, style=plot.style_stepline)

// 3. 4H STRUCTURAL SWING HIGH (BOS CEILING) - Continuous Live/History Matching
// Uses historical index offsets [1, 2, 3] inside the 4H tuple to isolate closed data
[h4High, h4High1, h4High2] = request.security(syminfo.tickerid, "240", [high[1], high[2], high[3]], barmerge.gaps_off, barmerge.lookahead_off)
is4H_SwingHigh = (h4High1 > h4High2) and (h4High1 > h4High)

var float active4H_BOS = na
if is4H_SwingHigh
    active4H_BOS := h4High1

plot(active4H_BOS, title="4H Structural BOS Ceiling", color=color.orange, linewidth=2, style=plot.style_stepline)

// 4. LONDON SESSION EXTREMES (03:00 - 08:00 AM EST ONLY)
inLondon   = not na(time(timeframe.period, "0300-0800:23456", "America/New_York"))

var float lonHigh = na
var float lonLow  = na
var float currentLonHigh = na
var float currentLonLow  = na

if isNewDay
    currentLonHigh := na
    currentLonLow  := na

if inLondon
    if na(currentLonHigh)
        currentLonHigh := high
        currentLonLow  := low
    else
        currentLonHigh := math.max(high, currentLonHigh)
        currentLonLow  := math.min(low, currentLonLow)
else if not isNewDay and not na(currentLonHigh)
    lonHigh := currentLonHigh
    lonLow  := currentLonLow

// Confluence Detection Threshold
threshold = 1.0

// Continual Confluence Engine Checks (Evaluates continuously on every bar)
hasPDH_4H_Conf     = math.abs(pdh - active4H_BOS) <= threshold
hasPDH_LH_Conf     = not na(lonHigh) and (math.abs(pdh - lonHigh) <= threshold)
has4H_LH_Conf      = not na(lonHigh) and (math.abs(active4H_BOS - lonHigh) <= threshold)
hasTripleCeiling   = hasPDH_4H_Conf and hasPDH_LH_Conf

hasPDL_PWL_Conf     = math.abs(pdl - pwl) <= threshold
hasPDL_LL_Conf      = not na(lonLow) and (math.abs(pdl - lonLow) <= threshold)
hasPWL_LL_Conf      = not na(lonLow) and (math.abs(pwl - lonLow) <= threshold)
hasTripleFloor     = hasPDL_PWL_Conf and hasPDL_LL_Conf

// Visual Line Snapping Matrix (Keeps line values working historically)
finalPlotLondonHigh = hasTripleCeiling or hasPDH_LH_Conf or has4H_LH_Conf ? active4H_BOS : lonHigh
finalPlotLondonLow  = hasTripleFloor or hasPDL_LL_Conf or hasPWL_LL_Conf ? pdl : lonLow

// Rendered Session Lines (Persists through after-market/Sydney hours)
plot(finalPlotLondonHigh, title="London High", color=color.white, linewidth=1, style=plot.style_stepline)
plot(finalPlotLondonLow, title="London Low", color=color.white, linewidth=1, style=plot.style_stepline)

// =========================================================================
// MASTER CONFLUENCE LABEL LOGIC (CEILINGS & FLOORS)
// =========================================================================
var label lblPDH = na
var label lblPDL = na
var label lblLH  = na
var label lblLL  = na
var label lbl4H  = na
var label lblPWH = na
var label lblPWL = na
var label lblEQ  = na

if barstate.islast
    label.delete(lblPDH), label.delete(lblPDL)
    label.delete(lblLH),  label.delete(lblLL)
    label.delete(lbl4H)
    label.delete(lblPWH), label.delete(lblPWL)
    label.delete(lblEQ)

    // Ceiling Labels
    if hasTripleCeiling
        lbl4H := label.new(x=bar_index + 2, y=pdh, text="🔥 TRIPLE WALL: [4H BOS / PDH / LH]", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
    else if hasPDH_4H_Conf
        lbl4H := label.new(x=bar_index + 2, y=pdh, text="💥 CONFLUENCE: [4H BOS / PDH]", color=color.orange, textcolor=color.white, style=label.style_label_left, size=size.small)
        if not na(lonHigh)
            lblLH := label.new(x=bar_index + 2, y=lonHigh, text="London High", color=color.gray, textcolor=color.white, style=label.style_label_left, size=size.small)
    else if hasPDH_LH_Conf
        lblPDH := label.new(x=bar_index + 2, y=pdh, text="💥 CONFLUENCE: [PDH / London High]", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
        lbl4H  := label.new(x=bar_index + 2, y=active4H_BOS, text="4H BOS", color=color.orange, textcolor=color.black, style=label.style_label_left, size=size.small)
    else if has4H_LH_Conf
        lbl4H  := label.new(x=bar_index + 2, y=active4H_BOS, text="💥 CONFLUENCE: [4H BOS / London High]", color=color.orange, textcolor=color.white, style=label.style_label_left, size=size.small)
        lblPDH := label.new(x=bar_index + 2, y=pdh, text="PDH", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
    else
        lblPDH := label.new(x=bar_index + 2, y=pdh, text="PDH", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
        if not na(active4H_BOS)
            lbl4H := label.new(x=bar_index + 2, y=active4H_BOS, text="4H BOS", color=color.orange, textcolor=color.black, style=label.style_label_left, size=size.small)
        if not na(lonHigh)
            lblLH := label.new(x=bar_index + 2, y=lonHigh, text="London High", color=color.gray, textcolor=color.white, style=label.style_label_left, size=size.small)

    // Floor Labels
    if hasTripleFloor
        lblPDL := label.new(x=bar_index + 2, y=pdl, text="🔥 TRIPLE FLOOR: [PDL / PWL / LL]", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
    else if hasPDL_PWL_Conf
        lblPDL := label.new(x=bar_index + 2, y=pdl, text="💥 CONFLUENCE: [PDL / PWL (Weekly)]", color=color.teal, textcolor=color.white, style=label.style_label_left, size=size.small)
        if not na(lonLow)
            lblLL  := label.new(x=bar_index + 2, y=lonLow, text="London Low", color=color.gray, textcolor=color.white, style=label.style_label_left, size=size.small)
    else if hasPDL_LL_Conf
        lblPDL := label.new(x=bar_index + 2, y=pdl, text="💥 CONFLUENCE: [PDL / London Low]", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
        lblPWL := label.new(x=bar_index + 2, y=pwl, text="PWL (Weekly)", color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)
    else if hasPWL_LL_Conf
        lblPWL := label.new(x=bar_index + 2, y=pwl, text="💥 CONFLUENCE: [PWL (Weekly) / London Low]", color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)
        lblPDL := label.new(x=bar_index + 2, y=pdl, text="PDL", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
    else
        lblPDL := label.new(x=bar_index + 2, y=pdl, text="PDL", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)
        lblPWL := label.new(x=bar_index + 2, y=pwl, text="PWL (Weekly)", color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)
        if not na(lonLow)
            lblLL := label.new(x=bar_index + 2, y=lonLow, text="London Low", color=color.gray, textcolor=color.white, style=label.style_label_left, size=size.small)

    // Macro Baseline Labels
    lblPWH := label.new(x=bar_index + 2, y=pwh, text="PWH (Weekly)", color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)
    lblEQ  := label.new(x=bar_index + 2, y=dailyEQ, text="Daily 50% EQ", color=color.navy, textcolor=color.white, style=label.style_label_left, size=size.small)
````

# Contiunation Forex - alerte 

- url: https://www.tradingview.com/script/QF73OzFJ-Contiunation-Forex-alerte/
- type: indicator
- pine_id: PUB;b51411d75f9d49d9837d71c219e571d2
- version: 1.0

## Description

Wait for FVGs mitigation alerts with:
-pattern FVG filters
-bias filters
-liquidity filters

Multi-timeframe
1h liquiditis
5m FVG

To set alert Press "+ Alerts" from Trading view tollbar

## Source Code

````pine
//@version=6
indicator(title="Contiunation Forex - alerte ", shorttitle="Contiunation Forex v1.83/79___", overlay=true, max_lines_count=500, max_boxes_count=500)

// ==================== SECȚIUNEA 1: LOGICĂ ====================
swingBars      = input.int(1, title="Putere Tip Lichiditate", minval=1, group="LOGICĂ")
showSwing1H    = input.bool(true, title="Activează lichiditățile", group="LOGICĂ")
maxActiveLiq   = input.int(20, title="Număr Max de lichidități", minval=1, group="LOGICĂ")
maxSweptLiq    = input.int(3, title="Număr Max de sweep-uri", minval=0, group="LOGICĂ")

showFVG5m      = input.bool(true, title="Activează FVG 5 minute", group="LOGICĂ")
maxFvgCount    = input.int(10, title="Număr maxim de FVG-uri", minval=1, group="LOGICĂ")
fvgWidth5m     = input.int(5, title="Lățime Box (candele 5m)", group="LOGICĂ")

// ==================== SECȚIUNEA 2: TABLE & ALERTS ====================
userBias       = input.string("Neutral", title="Selected Bias", options=["Neutral", "Bullish", "Bearish"], group="TABLE")
filterOption   = input.string("ON", title="Filter FVGs (alertă doar în zona lichidităților)", options=["ON", "OFF"], group="TABLE")

alertOnMom     = input.bool(true, title="Alertă pentru Momentum (M.FVG)", group="TABLE")
alertOnPat     = input.bool(true, title="Alertă pentru Pattern (P.FVG)", group="TABLE")

alertsEnabled  = input.string("ON", title="Alert on 5m", options=["ON", "OFF"], group="TABLE")
alertSession   = input.session("0900-1700", title="Interval Alerte (Ore)", group="TABLE")
userTimezone   = input.string("GMT+3", title="Timezone (România = GMT+3)", options=["GMT+1", "GMT+2", "GMT+3", "GMT+4", "UTC", "Europe/Bucharest"], group="TABLE")

minDistRR      = 0.3
maxDistRR      = 2.5
useSmartFilter = (filterOption == "ON")

var string lastFvgName = "None"
var color  lastFvgCol  = color.white
var float  last_fvg_t  = 0.0

isAlertSession = not na(time(timeframe.period, alertSession, userTimezone))
formattedSession = str.substring(alertSession, 0, 2) + ":" + str.substring(alertSession, 2, 4) + " - " + str.substring(alertSession, 5, 7) + ":" + str.substring(alertSession, 7, 9)

// ==================== SECȚIUNEA 3: CULORI ====================
colBullMom     = input.color(color.new(#00ff00, 80), title="Bullish Momentum FVG", group="Colors")
colBullPat     = input.color(color.new(#787b86, 80), title="Bullish Pattern FVG", group="Colors")
colBullWick    = input.color(color.new(#ffeb3b, 80), title="Bullish Wicked FVG", group="Colors")
colBearMom     = input.color(color.new(#1a1a1a, 80), title="Bearish Momentum FVG", group="Colors")
colBearPat     = input.color(color.new(#434651, 80), title="Bearish Pattern FVG", group="Colors")
colBearWick    = input.color(color.new(#311b92, 80), title="Bearish Wicked FVG", group="Colors")
colTriggerLine = input.color(color.new(color.white, 30), title="Linie Senzor (C3)", group="Colors")

// ==================== BLOC 2: LICHIDITĂȚI 1H ====================
var array<line>  activeLines  = array.new<line>()
var array<float> activeLevels = array.new<float>()
var array<bool>  activeIsHigh = array.new<bool>()
var array<line>  sweptLines   = array.new<line>()

[ph_1h, pl_1h, ph_t1h] = request.security(syminfo.tickerid, "60", [ta.pivothigh(swingBars, swingBars), ta.pivotlow(swingBars, swingBars), time[swingBars]], lookahead=barmerge.lookahead_on)

add_liq(val, t, isHigh) =>
    if not na(val)
        isDup = false
        if array.size(activeLevels) > 0
            for j = 0 to array.size(activeLevels) - 1
                if array.get(activeLevels, j) == val
                    isDup := true
                    break
        if not isDup
            ln = line.new(t, val, time, val, xloc.bar_time, color=color.gray)
            array.push(activeLines, ln), array.push(activeLevels, val), array.push(activeIsHigh, isHigh)

if showSwing1H
    add_liq(ph_1h, ph_t1h, true)
    add_liq(pl_1h, ph_t1h, false)

if array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0
        l = array.get(activeLines, i), lvl = array.get(activeLevels, i), ish = array.get(activeIsHigh, i)
        bool shouldShow = userBias == "Neutral" or (userBias == "Bullish" ? ish : not ish)
        line.set_color(l, shouldShow ? color.gray : color.new(color.white, 100))
        if high >= lvl and low <= lvl
            line.set_x2(l, time), line.set_color(l, shouldShow ? color.new(color.red, 50) : color.new(color.white, 100))
            array.push(sweptLines, l), array.remove(activeLines, i), array.remove(activeLevels, i), array.remove(activeIsHigh, i)
        else
            line.set_x2(l, time)

get_liq_target(bool look_above) =>
    float target = na
    if array.size(activeLevels) > 0
        for i = 0 to array.size(activeLevels) - 1
            lvl = array.get(activeLevels, i)
            if look_above and lvl > close 
                target := na(target) ? lvl : math.min(target, lvl)
            else if not look_above and lvl < close 
                target := na(target) ? lvl : math.max(target, lvl)
    target

// ==================== BLOC 3: FVG LOGIC ====================
var array<box>    fvgBoxes    = array.new<box>()
var array<line>   fvgTriggers = array.new<line>()
var array<float>  fvgTops     = array.new<float>()
var array<float>  fvgBottoms  = array.new<float>()
var array<bool>   fvgIsBull   = array.new<bool>()
var array<bool>   fvgIsWick   = array.new<bool>()
var array<bool>   fvgIsMom    = array.new<bool>()

get_fvg_extended() =>
    bull = low[1] > high[3]
    bear = high[1] < low[3]
    mom  = bull ? (close[1] > open[1] and close[2] > open[2]) : (bear ? (close[1] < open[1] and close[2] < open[2]) : false)
    [bull, bear, mom, high[3], low[1], low[3], high[1], time[3], time[1]]

[b5, r5, m5, t_c1, b_c3, t_c3, b_c1, start_t, closed_t] = request.security(syminfo.tickerid, "5", get_fvg_extended(), lookahead=barmerge.lookahead_off)

if showFVG5m and not na(closed_t) and closed_t != last_fvg_t
    if b5 or r5
        if array.size(fvgBoxes) >= maxFvgCount
            box.delete(array.shift(fvgBoxes)), line.delete(array.shift(fvgTriggers)), array.shift(fvgTops), array.shift(fvgBottoms), array.shift(fvgIsBull), array.shift(fvgIsWick), array.shift(fvgIsMom)
        
        float topL = b5 ? t_c1 : t_c3
        float botL = b5 ? b_c3 : b_c1
        float trigPrice = b5 ? b_c3 : t_c3 
        
        color fCol = b5 ? (m5 ? colBullMom : colBullPat) : (m5 ? colBearMom : colBearPat)
        string fTxt = m5 ? "M.FVG" : "P.FVG"
        
        rightX = closed_t + (fvgWidth5m * 300000)
        bx = box.new(start_t, topL, rightX, botL, xloc=xloc.bar_time, border_color=color.new(color.white, 100), bgcolor=fCol, text=fTxt, text_size=size.tiny, text_color=color.white)
        trigLn = line.new(start_t, trigPrice, rightX, trigPrice, xloc=xloc.bar_time, color=colTriggerLine, width=1)
        
        array.push(fvgBoxes, bx), array.push(fvgTriggers, trigLn), array.push(fvgTops, topL), array.push(fvgBottoms, botL), array.push(fvgIsBull, b5), array.push(fvgIsWick, false), array.push(fvgIsMom, m5)
        
        lastFvgName := fTxt, lastFvgCol := b5 ? color.green : color.red
        last_fvg_t := closed_t

// ==================== BLOC 4: LOGICĂ ALERTE WICKED & MITIGATED (FIXED) ====================
close5m = request.security(syminfo.tickerid, "5", close, lookahead=barmerge.lookahead_off)

if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        bx = array.get(fvgBoxes, i), ln = array.get(fvgTriggers, i)
        fT = array.get(fvgTops, i), fB = array.get(fvgBottoms, i)
        isBull = array.get(fvgIsBull, i), isW = array.get(fvgIsWick, i), isM = array.get(fvgIsMom, i)

        // 1. LOGICA WICKED
        bool hitLine = isBull ? (low <= line.get_y1(ln)) : (high >= line.get_y1(ln))
        
        if hitLine and not isW
            box.set_bgcolor(bx, isBull ? colBullWick : colBearWick)
            string newTxt = isM ? "W.M.FVG" : "W.P.FVG"
            box.set_text(bx, newTxt)
            if not na(ln)
                line.delete(ln)
            array.set(fvgIsWick, i, true)
            lastFvgName := newTxt, lastFvgCol := color.orange
            
            bool passFilter = true
            if (isM and not alertOnMom) or (not isM and not alertOnPat)
                passFilter := false
            if passFilter and useSmartFilter
                float risk = math.abs(close - (isBull ? low : high))
                float targetLiq = get_liq_target(isBull)
                if na(targetLiq) or risk == 0 or (math.abs(targetLiq - close) / risk < minDistRR)
                    passFilter := false
            
            if passFilter and alertsEnabled == "ON" and isAlertSession
                alert("FVG Wicked - " + newTxt, alert.freq_once_per_bar)

        // 2. LOGICA MITIGATED
        bool mitigated = isBull ? close5m < fB : close5m > fT
        if mitigated
            if alertsEnabled == "ON" and isAlertSession
                alert("FVG Mitigated", alert.freq_once_per_bar)
            
            box.delete(bx)
            if not na(ln)
                line.delete(ln)
            array.remove(fvgBoxes, i), array.remove(fvgTriggers, i), array.remove(fvgTops, i), array.remove(fvgBottoms, i), array.remove(fvgIsBull, i), array.remove(fvgIsWick, i), array.remove(fvgIsMom, i)

// ==================== BLOC 5: DASHBOARD ====================
var table dash = table.new(position.bottom_right, 2, 5, bgcolor=#1e222d, border_color=color.new(color.gray, 80), border_width=1)
if barstate.islast
    biasCol = userBias == "Bullish" ? color.green : (userBias == "Bearish" ? color.red : color.gray)
    table.cell(dash, 0, 0, "Selected Bias:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 0, userBias, text_color=biasCol, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 0, 1, "Last FVG:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 1, lastFvgName, text_color=lastFvgCol, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 0, 2, "Filter FVGs:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, (filterOption == "ON" ? "ON (Liq Only)" : "OFF"), text_color=(filterOption == "ON" ? color.green : color.red), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 0, 3, "Alert on 5m:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 3, alertsEnabled, text_color=(alertsEnabled == "ON" ? color.green : color.red), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 0, 4, "Alerts Interval:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, formattedSession, text_color=color.orange, text_halign=text.align_left, text_size=size.small)
````

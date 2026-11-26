# FVG (Fair value Gap) MTF by DAN

- url: https://www.tradingview.com/script/JhPIh3qr-FVG-Fair-value-Gap-MTF-by-DAN/
- type: indicator
- pine_id: PUB;e9888e84a74d4bf9984cc98fd43c77ff
- version: 1.0

## Description

The Advanced Multi Timeframe FVG Dashboard is a tool built for traders who trade the FVG (Fair value gap) concept by ICT. this tool helps monitor FVG creation and mitigation across 5 pairs across 5 major timeframes (m30,h1,h4,daily,weekly) simultaneously.

Core Features:
The Ultimate MTF Dashboard: Instantly track Fair Value Gap states across M30, H1, H4, Daily, and Weekly timeframes. it highlights when a new FVG forms (OPEN) and exactly when price mitigates it (FILL). GREEN FOR BULLISH FVG, RED FOR BEARISH FVG. 

Multi-Pair Screening: Monitor your active chart plus up to 4 additional extra pairs of your choice (Forex, Crypto, Indices, etc.). Leave a slot empty and the dashboard seamlessly hides it to keep your screen clean.

Distraction-Free Visuals: The indicator natively calculates and draws the precise Top and Bottom boundaries of the FVG, alongside an optional feature to custom-paint the displacement candle itself (Candle 2). it draws a horizontal line between candle 1 and 3 of the most recent FVG confirmation only, but it colors previous fvg formation candles.

ALERTS: you can set an alert for both FVG creation and mitigation, simple toggle timeframe, pair and alerts type in settings, and you are good to go

Who is this for?

If you are an ICT or Smart Money Concepts (SMC) trader who misses high-timeframe PA shifts, this tool is designed for you.

## Source Code

````pine
//@version=6
indicator("FVG MTF KEY LEVELS BY DAN", "FVG MTF BY DAN", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS & SETTINGS
// ═══════════════════════════════════════════════════════════════════════════

grp_vis = "Visual Settings"
fvgColor      = input.color(color.new(#2196f3, 0), "FVG Line Color", group=grp_vis)
lineWidth     = input.int(2, "Line Width", minval=1, maxval=5, group=grp_vis)
lineStyleName = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_vis)
colorFvgCandle= input.bool(true, "Color FVG Candle (Candle 2)", group=grp_vis)
colBullCandle = input.color(color.new(#00c853, 0), "Bull Candle Color", group=grp_vis)
colBearCandle = input.color(color.new(#d50000, 0), "Bear Candle Color", group=grp_vis)

grp_dash = "Dashboard Settings"
showDashboard = input.bool(true, "Show Dashboard", group=grp_dash)
dashPosition  = input.string("Top Right", "Position", options=["Top Right", "Bottom Right"], group=grp_dash)
colBullOpen   = input.color(color.new(#00c853, 30), "Bull Open Color",  group=grp_dash)
colBearOpen   = input.color(color.new(#d50000, 30), "Bear Open Color",  group=grp_dash)
colBullTap    = input.color(color.new(#00c853, 0), "Bull Fill Color",   group=grp_dash)
colBearTap    = input.color(color.new(#d50000, 0), "Bear Fill Color",   group=grp_dash)
colNone       = input.color(color.new(#607d8b, 85), "None Color",       group=grp_dash)

grp_alerts = "Alert Settings"
alertCreation   = input.bool(true, "Alert on FVG Creation", group=grp_alerts)
alertMitigation = input.bool(true, "Alert on FVG Mitigation (Tap)", group=grp_alerts)
alertM30        = input.bool(true, "Enable M30 Alerts", group=grp_alerts)
alertH1         = input.bool(true, "Enable H1 Alerts", group=grp_alerts)
alertH4         = input.bool(true, "Enable H4 Alerts", group=grp_alerts)
alertD          = input.bool(true, "Enable Daily Alerts", group=grp_alerts)
alertW          = input.bool(true, "Enable Weekly Alerts", group=grp_alerts)

grp_extra = "Extra Pairs to Monitor (Total 5 including Chart)"
sym1 = input.symbol("", "Pair 1", group=grp_extra)
sym2 = input.symbol("", "Pair 2", group=grp_extra)
sym3 = input.symbol("", "Pair 3", group=grp_extra)
sym4 = input.symbol("", "Pair 4", group=grp_extra)

// Helpers
f_getLineStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ═════════════════════════════════════════════════════════
// FVG CORE LOGIC
// ═════════════════════════════════════════════════════════

// Evaluate BOTH Creation and Mitigation natively on the target timeframe
f_fvg_raw() =>
    isBull = low[1] > high[3]
    isBear = high[1] < low[3]
    hasFvg = isBull or isBear
    
    float top = ta.valuewhen(hasFvg, isBull ? low[1] : low[3], 0)
    float bot = ta.valuewhen(hasFvg, isBull ? high[3] : high[1], 0)
    bool isB  = ta.valuewhen(hasFvg, isBull, 0)
    int sT    = int(ta.valuewhen(hasFvg, time[3], 0))
    int cT    = int(ta.valuewhen(hasFvg, time[1], 0))
    
    // Natively track lowest low / highest high since the FVG was formed
    float minL = low
    float maxH = high
    minL := sT > 0 and sT == sT[1] ? math.min(low, nz(minL[1], low)) : low
    maxH := sT > 0 and sT == sT[1] ? math.max(high, nz(maxH[1], high)) : high
    
    // Evaluate pure MTF State (1=Bull, 2=Bear, 3=BullTap, 4=BearTap)
    int state = 0
    if sT > 0
        if isB
            state := minL < top ? 3 : 1
        else
            state := maxH > bot ? 4 : 2
            
    [top, bot, isB, sT, cT, state]

// Data Gathering (6 Symbols * 5 TFs = 30 calls = Extremely Optimized)
f_get_m30(s) => request.security(s, "30", f_fvg_raw())
f_get_h1(s)  => request.security(s, "60", f_fvg_raw())
f_get_h4(s)  => request.security(s, "240", f_fvg_raw())
f_get_d(s)   => request.security(s, "D", f_fvg_raw())
f_get_w(s)   => request.security(s, "W", f_fvg_raw())

// Unpacking Chart Data
[t0_3, b0_3, isB0_3, sT0_3, cT0_3, st0_3] = f_get_m30(syminfo.tickerid)
[t0_h, b0_h, isB0_h, sT0_h, cT0_h, st0_h] = f_get_h1(syminfo.tickerid)
[t0_4, b0_4, isB0_4, sT0_4, cT0_4, st0_4] = f_get_h4(syminfo.tickerid)
[t0_d, b0_d, isB0_d, sT0_d, cT0_d, st0_d] = f_get_d(syminfo.tickerid)
[t0_w, b0_w, isB0_w, sT0_w, cT0_w, st0_w] = f_get_w(syminfo.tickerid)

// Unpacking Symbol 1
safeSym1 = sym1 == "" ? syminfo.tickerid : sym1
[t1_3, b1_3, isB1_3, sT1_3, cT1_3, st1_3] = f_get_m30(safeSym1)
[t1_h, b1_h, isB1_h, sT1_h, cT1_h, st1_h] = f_get_h1(safeSym1)
[t1_4, b1_4, isB1_4, sT1_4, cT1_4, st1_4] = f_get_h4(safeSym1)
[t1_d, b1_d, isB1_d, sT1_d, cT1_d, st1_d] = f_get_d(safeSym1)
[t1_w, b1_w, isB1_w, sT1_w, cT1_w, st1_w] = f_get_w(safeSym1)

// Unpacking Symbol 2
safeSym2 = sym2 == "" ? syminfo.tickerid : sym2
[t2_3, b2_3, isB2_3, sT2_3, cT2_3, st2_3] = f_get_m30(safeSym2)
[t2_h, b2_h, isB2_h, sT2_h, cT2_h, st2_h] = f_get_h1(safeSym2)
[t2_4, b2_4, isB2_4, sT2_4, cT2_4, st2_4] = f_get_h4(safeSym2)
[t2_d, b2_d, isB2_d, sT2_d, cT2_d, st2_d] = f_get_d(safeSym2)
[t2_w, b2_w, isB2_w, sT2_w, cT2_w, st2_w] = f_get_w(safeSym2)

// Unpacking Symbol 3
safeSym3 = sym3 == "" ? syminfo.tickerid : sym3
[t3_3, b3_3, isB3_3, sT3_3, cT3_3, st3_3] = f_get_m30(safeSym3)
[t3_h, b3_h, isB3_h, sT3_h, cT3_h, st3_h] = f_get_h1(safeSym3)
[t3_4, b3_4, isB3_4, sT3_4, cT3_4, st3_4] = f_get_h4(safeSym3)
[t3_d, b3_d, isB3_d, sT3_d, cT3_d, st3_d] = f_get_d(safeSym3)
[t3_w, b3_w, isB3_w, sT3_w, cT3_w, st3_w] = f_get_w(safeSym3)

// Unpacking Symbol 4
safeSym4 = sym4 == "" ? syminfo.tickerid : sym4
[t4_3, b4_3, isB4_3, sT4_3, cT4_3, st4_3] = f_get_m30(safeSym4)
[t4_h, b4_h, isB4_h, sT4_h, cT4_h, st4_h] = f_get_h1(safeSym4)
[t4_4, b4_4, isB4_4, sT4_4, cT4_4, st4_4] = f_get_h4(safeSym4)
[t4_d, b4_d, isB4_d, sT4_d, cT4_d, st4_d] = f_get_d(safeSym4)
[t4_w, b4_w, isB4_w, sT4_w, cT4_w, st4_w] = f_get_w(safeSym4)

// Active Chart Core Pattern (Evaluated at native chart TF)
[tc, bc, blc, stc, ctc, chartState] = f_fvg_raw()

// ═════════════════════════════════════════════════════════
// DASHBOARD & STATE MACHINE
// ═════════════════════════════════════════════════════════

type FvgState
    line topL
    line botL
    float pTop
    float pBot
    int state
    int lastId
    bool seeded

f_dashPos() =>
    dashPosition == "Bottom Right" ? position.bottom_right : position.top_right

var table dash = table.new(f_dashPos(), 6, 6, bgcolor=showDashboard ? color.new(color.black, 70) : na, border_width=showDashboard ? 1 : 0, border_color=showDashboard ? color.gray : na)

f_update_cell(colIdx, rowIdx, state, isValid) =>
    if showDashboard
        txt = not isValid ? "" : state == 1 or state == 2 ? "OPEN" : state == 3 or state == 4 ? "FILL" : "NONE"
        bg  = not isValid ? na : state == 1 ? colBullOpen : state == 2 ? colBearOpen : state == 3 ? colBullTap : state == 4 ? colBearTap : colNone
        table.cell(dash, colIdx, rowIdx, txt, bgcolor=bg, text_color=color.white, text_size=size.small)

// Professional Varip Memory arrays to track instantaneous state and prevent blockages
varip array<int> alertStates = array.new<int>(31, 0)
varip array<bool> isSeeded = array.new<bool>(31, false)

f_process(stateObj, symName, tfName, colIdx, rowIdx, enabled, showVisual, top, bot, isBull, sT, cT, mtfState, col, idx) =>
    bool isNew = sT != stateObj.lastId and not na(sT)
    if isNew
        stateObj.lastId := sT
        stateObj.pTop   := top
        stateObj.pBot   := bot
        
        if showVisual
            l1_val = isBull ? bot : top 
            l2_val = isBull ? top : bot 
            if na(stateObj.botL)
                stateObj.botL := line.new(sT, l1_val, time, l1_val, xloc.bar_time, extend.none, col, f_getLineStyle(lineStyleName), lineWidth)
                stateObj.topL := line.new(cT, l2_val, time, l2_val, xloc.bar_time, extend.none, col, f_getLineStyle(lineStyleName), lineWidth)
            else
                line.set_xy1(stateObj.botL, sT, l1_val)
                line.set_xy2(stateObj.botL, time, l1_val)
                line.set_xy1(stateObj.topL, cT, l2_val)
                line.set_xy2(stateObj.topL, time, l2_val)
                line.set_color(stateObj.botL, col)
                line.set_color(stateObj.topL, col)
                line.set_width(stateObj.botL, lineWidth)
                line.set_width(stateObj.topL, lineWidth)
                line.set_style(stateObj.botL, f_getLineStyle(lineStyleName))
                line.set_style(stateObj.topL, f_getLineStyle(lineStyleName))
        else
            line.set_xy1(stateObj.botL, na, na)
            line.set_xy1(stateObj.topL, na, na)

    if (mtfState == 1 or mtfState == 2) and showVisual
        line.set_x2(stateObj.botL, time)
        line.set_x2(stateObj.topL, time)

    // Varip Synchronization Block
    bool seeded = array.get(isSeeded, idx)
    if barstate.isrealtime and not seeded
        array.set(alertStates, idx, mtfState)
        array.set(isSeeded, idx, true)
        seeded := true

    int oldAlertState = array.get(alertStates, idx)
    bool isValidPair = symName != ""
    if enabled and seeded and barstate.isrealtime and isValidPair and mtfState != oldAlertState
        array.set(alertStates, idx, mtfState) // Instantly update varip memory so next ticks on same bar don't execute
        string pStr = (symName == syminfo.tickerid ? syminfo.ticker : symName)
        if (mtfState == 1 or mtfState == 2) and alertCreation
            string msg = (mtfState == 1 ? "BULLISH" : "BEARISH") + " FVG CREATED ON " + pStr + ", " + tfName
            alert(msg, alert.freq_all)
        else if (mtfState == 3 or mtfState == 4) and alertMitigation
            string msg = (mtfState == 3 ? "BULLISH" : "BEARISH") + " FVG MITIGATED ON " + pStr + ", " + tfName
            alert(msg, alert.freq_all)

    if rowIdx > 0 and barstate.islast
        f_update_cell(colIdx, rowIdx, mtfState, isValidPair)

// Isolated States for Screen Tracking
var s0_3=FvgState.new(na,na,na,na,0,0)
var s0_1=FvgState.new(na,na,na,na,0,0)
var s0_4=FvgState.new(na,na,na,na,0,0)
var s0_d=FvgState.new(na,na,na,na,0,0)
var s0_w=FvgState.new(na,na,na,na,0,0)

var s1_3=FvgState.new(na,na,na,na,0,0)
var s1_1=FvgState.new(na,na,na,na,0,0)
var s1_4=FvgState.new(na,na,na,na,0,0)
var s1_d=FvgState.new(na,na,na,na,0,0)
var s1_w=FvgState.new(na,na,na,na,0,0)

var s2_3=FvgState.new(na,na,na,na,0,0)
var s2_1=FvgState.new(na,na,na,na,0,0)
var s2_4=FvgState.new(na,na,na,na,0,0)
var s2_d=FvgState.new(na,na,na,na,0,0)
var s2_w=FvgState.new(na,na,na,na,0,0)

var s3_3=FvgState.new(na,na,na,na,0,0)
var s3_1=FvgState.new(na,na,na,na,0,0)
var s3_4=FvgState.new(na,na,na,na,0,0)
var s3_d=FvgState.new(na,na,na,na,0,0)
var s3_w=FvgState.new(na,na,na,na,0,0)

var s4_3=FvgState.new(na,na,na,na,0,0)
var s4_1=FvgState.new(na,na,na,na,0,0)
var s4_4=FvgState.new(na,na,na,na,0,0)
var s4_d=FvgState.new(na,na,na,na,0,0)
var s4_w=FvgState.new(na,na,na,na,0,0)

var stateChartVis = FvgState.new(na,na,na,na,0,0)

// Headers
if barstate.islast and showDashboard
    table.cell(dash,0,0,"PAIR")
    table.cell(dash,1,0,"M30")
    table.cell(dash,2,0,"H1")
    table.cell(dash,3,0,"H4")
    table.cell(dash,4,0,"D")
    table.cell(dash,5,0,"W")
    table.cell(dash,0,1,syminfo.ticker)
    table.cell(dash,0,2,sym1 == "" ? "-" : sym1)
    table.cell(dash,0,3,sym2 == "" ? "-" : sym2)
    table.cell(dash,0,4,sym3 == "" ? "-" : sym3)
    table.cell(dash,0,5,sym4 == "" ? "-" : sym4)

f_run(s, r, baseIdx, t3,b3,is3,id3,ct3,st3, th,bh,ish,idh,cth,sth, t4,b4,is4,id4,ct4,st4, td,bd,isd,idd,ctd,std, tw,bw,isw,idw,ctw,stw) =>
    f_process(r==1?s0_3:r==2?s1_3:r==3?s2_3:r==4?s3_3:s4_3, s, "M30", 1, r, alertM30, false, t3,b3,is3,id3,ct3,st3, fvgColor, baseIdx)
    f_process(r==1?s0_1:r==2?s1_1:r==3?s2_1:r==4?s3_1:s4_1, s, "H1",  2, r, alertH1,  false, th,bh,ish,idh,cth,sth, fvgColor, baseIdx + 1)
    f_process(r==1?s0_4:r==2?s1_4:r==3?s2_4:r==4?s3_4:s4_4, s, "H4",  3, r, alertH4,  false, t4,b4,is4,id4,ct4,st4, fvgColor, baseIdx + 2)
    f_process(r==1?s0_d:r==2?s1_d:r==3?s2_d:r==4?s3_d:s4_d, s, "D",   4, r, alertD,   false, td,bd,isd,idd,ctd,std, fvgColor, baseIdx + 3)
    f_process(r==1?s0_w:r==2?s1_w:r==3?s2_w:r==4?s3_w:s4_w, s, "W",   5, r, alertW,   false, tw,bw,isw,idw,ctw,stw, fvgColor, baseIdx + 4)

// RUN SCREENER (Updates Dashboard & Alerts Only)
f_run(syminfo.tickerid,1, 1, t0_3,b0_3,isB0_3,sT0_3,cT0_3,st0_3, t0_h,b0_h,isB0_h,sT0_h,cT0_h,st0_h, t0_4,b0_4,isB0_4,sT0_4,cT0_4,st0_4, t0_d,b0_d,isB0_d,sT0_d,cT0_d,st0_d, t0_w,b0_w,isB0_w,sT0_w,cT0_w,st0_w)
f_run(sym1,2, 6, t1_3,b1_3,isB1_3,sT1_3,cT1_3,st1_3, t1_h,b1_h,isB1_h,sT1_h,cT1_h,st1_h, t1_4,b1_4,isB1_4,sT1_4,cT1_4,st1_4, t1_d,b1_d,isB1_d,sT1_d,cT1_d,st1_d, t1_w,b1_w,isB1_w,sT1_w,cT1_w,st1_w)
f_run(sym2,3, 11, t2_3,b2_3,isB2_3,sT2_3,cT2_3,st2_3, t2_h,b2_h,isB2_h,sT2_h,cT2_h,st2_h, t2_4,b2_4,isB2_4,sT2_4,cT2_4,st2_4, t2_d,b2_d,isB2_d,sT2_d,cT2_d,st2_d, t2_w,b2_w,isB2_w,sT2_w,cT2_w,st2_w)
f_run(sym3,4, 16, t3_3,b3_3,isB3_3,sT3_3,cT3_3,st3_3, t3_h,b3_h,isB3_h,sT3_h,cT3_h,st3_h, t3_4,b3_4,isB3_4,sT3_4,cT3_4,st3_4, t3_d,b3_d,isB3_d,sT3_d,cT3_d,st3_d, t3_w,b3_w,isB3_w,sT3_w,cT3_w,st3_w)
f_run(sym4,5, 21, t4_3,b4_3,isB4_3,sT4_3,cT4_3,st4_3, t4_h,b4_h,isB4_h,sT4_h,cT4_h,st4_h, t4_4,b4_4,isB4_4,sT4_4,cT4_4,st4_4, t4_d,b4_d,isB4_d,sT4_d,cT4_d,st4_d, t4_w,b4_w,isB4_w,sT4_w,cT4_w,st4_w)

// DRAW ACTIVE CHART VISUALS ONLY
f_process(stateChartVis, syminfo.tickerid, "Chart", 0, 0, false, true, tc, bc, blc, stc, ctc, chartState, fvgColor, 0)

// ═════════════════════════════════════════════════════════
// BAR COLORING (ACTIVE CHART TF)
// ═════════════════════════════════════════════════════════
bool rawBullChart = low[1] > high[3]
bool rawBearChart = high[1] < low[3]
color cColor = rawBullChart and colorFvgCandle ? colBullCandle : rawBearChart and colorFvgCandle ? colBearCandle : na
barcolor(cColor, offset=-2)
````

# CVD Flow Engine

- url: https://www.tradingview.com/script/cFYnMGFz-CVD-Flow-Engine/
- type: indicator
- pine_id: PUB;c7a24f14b48d48eaaacb3f3e6e5c492d
- version: 2.0

## Description

CVD Flow Engine

CVD Flow Engine is an advanced order-flow analysis framework that combines Cumulative Volume Delta (CVD), structural flow analysis, retention-style candles, trend detection, strength signals, and divergences into a single indicator.

Unlike traditional CVD indicators that focus only on cumulative delta, CVD Flow Engine attempts to classify the quality and persistence of buying and selling pressure by analyzing both trend and structure.

Key Features

• CVD Profiles
Builds a profile from cumulative delta activity, allowing traders to identify areas where buying and selling pressure have accumulated over time.

• Retention-Style CVD Candles
Transforms CVD Balance, CVD Delta, or CVD Acceleration into candle structures where each candle opens from the previous value. This provides a clearer visualization of participation and flow persistence than a traditional line plot.

• Structural Flow Analysis
Instead of relying solely on EMA position, the engine evaluates whether order flow is improving or deteriorating through market structure.

The candle coloring system identifies:

* Strong Bull Flow: CVD above trend and maintaining bullish momentum.
* Bullish Recovery: CVD remains below trend but begins producing Higher Highs and Higher Lows, indicating improving participation.
* Strong Bear Flow: CVD below trend and maintaining bearish momentum.
* Bearish Weakness: CVD remains above trend but begins producing Lower Highs and Lower Lows, suggesting deterioration in buying pressure.

This allows traders to identify improving flow conditions before traditional trend filters react.

• Dynamic Trend Engine
A CVD EMA is used to classify the prevailing order-flow regime. EMA slope analysis helps distinguish bullish, bearish, and transitional environments.

• Strong Bull / Strong Bear Signals
The indicator identifies periods where trend, momentum, and flow retention align. Compact markers highlight these states without cluttering the chart.

• Divergence Detection
Bullish and bearish divergences compare price structure against order-flow structure.

Bullish Divergence:

* Price makes a Lower Low.
* CVD makes a Higher Low.

Bearish Divergence:

* Price makes a Higher High.
* CVD makes a Lower High.

These conditions may indicate weakening participation behind the current move.

How To Use

Bullish Environment:

* Retention candles are predominantly green.
* Higher High and Higher Low structures continue to form.
* Strong Bull signals appear.
* Bullish divergences can identify pullback opportunities.

Bearish Environment:

* Retention candles transition into bearish structure.
* Lower High and Lower Low sequences develop.
* Strong Bear signals appear.
* Bearish divergences can identify weakening rallies.

Transition Environment:

* EMA slope flattens.
* Structure begins shifting before trend confirmation.
* Recovery or deterioration states emerge.
* Divergences become more frequent.

The objective of CVD Flow Engine is not to predict future price movement but to provide a structured view of whether order flow is strengthening, weakening, recovering, or deteriorating beneath the surface of price action.

By combining cumulative delta, structural analysis, trend classification, and divergence detection, the indicator helps traders evaluate whether participation is supporting the current market move or signaling a potential transition.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingIQ

//@version=6
indicator("CVD Flow Engine", calc_bars_count = 10000, overlay = false, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 1500)


enum calcType 

    REG = "Regular"
    FS  = "Fixed Start"

model                                  = input.string(defval = "CVD", title = "Model", options = ["CVD", "Imbalance Ratio", "Activity", "USD Volume"])
timeframe                              = input.timeframe(defval = "", title = "Timeframe To Calculate New Blocks On")
TF                                     = input.timeframe(defval = "2", title = "Lower Timeframe Volume")
offChart                               = input.string(defval = "CVD Delta", title = "CVD Offchart Data", options = ["CVD Delta", "CVD Acceleration"])

calcTypeInput                          = input.enum(defval = calcType.FS, title = "Calculation Type", options = [calcType.REG, calcType.FS], group = "Calculation Type")
fixedStartTime                         = input.time(timestamp("01 Jan 2000 00:00"), title = "Fixed Start Time", active = calcTypeInput == calcType.FS)
ticks                                  = input.float(defval = 0 ,title = "Ticks Per Row (0 == Auto)", group = "Calculation Type")
textSize                               = input.string(title = "Text Size", defval = "Small", options = ["Auto","Tiny", "Small", "Normal", "Large", "Huge"], group = "Current Session Configurations")
showVA                                 = input.bool(defval = true, title = "Show Single VA Lines", group = "Current Session Configurations")

vaCumu                                 = input.float(defval = 70, title = "Value Area %", minval = 0, maxval = 100) / 100
upCol                                  = input.color(defval = #55ffda, title = "Up Color", group = "Colors")
dnCol                                  = input.color(defval = color.rgb(255, 116, 116), title = "Down Color", group = "Colors")
actCol                                 = input.color(defval = #ff65fb, title = "Activity Color", group = "Colors")
usdCol                                  = input.color(defval = #5855ff, title = "USD Volume", group = "Colors")
IBcol                                  = input.color(defval = #ff65fb, title = "IB Character Color", group = "Colors")
vaCol                                  = input.color(defval = #74ffbc, title = "Value Area Color", group = "Colors")
POCcol                                 = input.color(defval = #c7ff74, title = "POC Character Color", group = "Colors")

//──────────────────────────────────────────────────────────────────────────────
// Retention-style CVD candle pane
//──────────────────────────────────────────────────────────────────────────────
cvdRetGroup                            = "Retention-Style CVD Candles"
showOriginalColumns                    = input.bool(defval = false, title = "Show Original Delta / Accel Columns", group = cvdRetGroup)
showCvdRetCandles                      = input.bool(defval = true, title = "Show CVD Retention-Style Candles", group = cvdRetGroup)
cvdRetSource                           = input.string(defval = "CVD Balance", title = "CVD Candle Source", options = ["CVD Balance", "CVD Delta", "CVD Acceleration"], group = cvdRetGroup)
cvdRetEmaLen                           = input.int(defval = 21, title = "CVD EMA Length", minval = 1, maxval = 300, group = cvdRetGroup)
cvdRetEmaSlopeThresholdPct             = input.float(defval = 0.10, title = "EMA Range Threshold % Slope", minval = 0.0, step = 0.01, group = cvdRetGroup)
cvdRetWickSmooth                       = input.int(defval = 3, title = "CVD Wick Smoothing", minval = 1, maxval = 50, group = cvdRetGroup)
cvdRetWickFactor                       = input.float(defval = 0.20, title = "CVD Wick Size From Body", minval = 0.0, maxval = 2.0, step = 0.05, group = cvdRetGroup)
cvdAboveEmaCol                         = input.color(defval = color.rgb(0, 255, 60), title = "Candle Above EMA Color", group = cvdRetGroup)
cvdBelowEmaCol                         = input.color(defval = color.rgb(180, 185, 195), title = "Candle Below EMA Color", group = cvdRetGroup)
cvdUseStructureColoring                = input.bool(defval = true, title = "Color HH/HL Recovery Under EMA", group = cvdRetGroup)
cvdStructureLookback                   = input.int(defval = 1, title = "HH/HL Structure Lookback", minval = 1, maxval = 20, group = cvdRetGroup)
cvdBullRecoveryCol                     = input.color(defval = color.rgb(0, 150, 70), title = "Bullish Recovery Under EMA Color", group = cvdRetGroup)
cvdBearDeteriorationCol                = input.color(defval = color.rgb(255, 120, 0), title = "Bearish Deterioration Above EMA Color", group = cvdRetGroup)
cvdEmaBullCol                          = input.color(defval = color.rgb(0, 255, 60), title = "EMA Bullish Slope Color", group = cvdRetGroup)
cvdEmaBearCol                          = input.color(defval = color.rgb(255, 60, 80), title = "EMA Bearish Slope Color", group = cvdRetGroup)
cvdEmaRangeCol                         = input.color(defval = color.rgb(255, 230, 0), title = "EMA Range Color", group = cvdRetGroup)

// CVD strength signals. These are LIVE/current-bar signals, not pivot-backplotted.
cvdSigGroup                            = "CVD Strength Signals"
showCvdStrengthSignals                 = input.bool(defval = true, title = "Show CVD Strength Signals", group = cvdSigGroup)
showCvdWeakSignals                     = input.bool(defval = false, title = "Show CVD Weak Bull/Bear Signals", group = cvdSigGroup)
cvdStrengthMomentumBars                = input.int(defval = 3, title = "Momentum Lookback Bars", minval = 1, maxval = 50, group = cvdSigGroup)
cvdSignalMode                          = input.string(defval = "State Change", title = "Signal Print Mode", options = ["State Change", "Every Confirmed Bar"], group = cvdSigGroup)
cvdSignalSizeInput                     = input.string(defval = "Tiny", title = "Signal Label Size", options = ["Tiny", "Small", "Normal"], group = cvdSigGroup)
cvdStrongBullLabelCol                  = input.color(defval = color.rgb(0, 220, 90), title = "Strong Bull Circle Color", group = cvdSigGroup)
cvdStrongBearLabelCol                  = input.color(defval = color.rgb(255, 60, 80), title = "Strong Bear Circle Color", group = cvdSigGroup)
cvdWeakBullLabelCol                    = input.color(defval = color.rgb(120, 220, 120), title = "Weak Bull Label Color", group = cvdSigGroup)
cvdWeakBearLabelCol                    = input.color(defval = color.rgb(255, 170, 0), title = "Weak Bear Label Color", group = cvdSigGroup)

// Clean divergence triangles. These use tiny label triangles with hover tooltips, so
// the pane stays clean while the signal explanation is still available on mouse hover.
cvdDivGroup                            = "CVD Divergence Triangles"
showCvdDivTriangles                    = input.bool(defval = true, title = "Show Bull/Bear Divergence Triangles", group = cvdDivGroup)
cvdDivPivotLeft                        = input.int(defval = 2, title = "Pivot Left", minval = 1, maxval = 20, group = cvdDivGroup)
cvdDivPivotRight                       = input.int(defval = 2, title = "Pivot Right", minval = 1, maxval = 20, group = cvdDivGroup)
showCvdBullDiv                         = input.bool(defval = true, title = "Show Bullish Divergence", group = cvdDivGroup)
showCvdBearDiv                         = input.bool(defval = true, title = "Show Bearish Divergence", group = cvdDivGroup)
cvdDivTriangleSizeInput                = input.string(defval = "Tiny", title = "Triangle Size", options = ["Tiny", "Small", "Normal"], group = cvdDivGroup)
cvdBullDivTriangleCol                  = input.color(defval = color.rgb(0, 255, 60), title = "Bullish Triangle Color", group = cvdDivGroup)
cvdBearDivTriangleCol                  = input.color(defval = color.rgb(255, 60, 80), title = "Bearish Triangle Color", group = cvdDivGroup)

// Flow Extension Engine uses PV Discovery style logic on the selected CVD source.
// It learns the average distance between CVD pivots and the CVD EMA, then projects
// adaptive upper/lower exhaustion bands around the CVD EMA.
cvdExtGroup                            = "CVD Flow Extension Engine"
showCvdFlowExtension                   = input.bool(defval = true, title = "Show Flow Extension Bands", group = cvdExtGroup)
cvdExtPivotLeft                        = input.int(defval = 3, title = "Extension Pivot Left", minval = 1, maxval = 20, group = cvdExtGroup)
cvdExtPivotRight                       = input.int(defval = 3, title = "Extension Pivot Right", minval = 1, maxval = 20, group = cvdExtGroup)
cvdExtMinSamples                       = input.int(defval = 5, title = "Minimum Pivot Samples", minval = 1, maxval = 100, group = cvdExtGroup)
cvdExtLowerAdaptiveLen                 = input.int(defval = 20, title = "Lower Band Adaptive Length", minval = 2, maxval = 300, group = cvdExtGroup)
cvdExtMode                             = input.string(defval = "Hybrid", title = "Extension Mode", options = ["Average", "Adaptive", "Hybrid"], group = cvdExtGroup)
cvdExtHybridWeight                     = input.float(defval = 0.50, title = "Hybrid Average Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = cvdExtGroup)
cvdExtBandSmooth                       = input.int(defval = 3, title = "Band Smoothing", minval = 1, maxval = 50, group = cvdExtGroup)
showCvdExtFill                         = input.bool(defval = true, title = "Show Flow Fair Value Fill", group = cvdExtGroup)
showCvdExtremeSignals                  = input.bool(defval = true, title = "Show Extension Extreme Markers", group = cvdExtGroup)
cvdExtUpperCol                         = input.color(defval = color.rgb(255, 120, 0), title = "Upper Flow Extension Color", group = cvdExtGroup)
cvdExtLowerCol                         = input.color(defval = color.rgb(0, 180, 120), title = "Lower Flow Extension Color", group = cvdExtGroup)
cvdExtFillCol                          = input.color(defval = color.rgb(255, 230, 0), title = "Flow Fair Value Fill Color", group = cvdExtGroup)

// Macro Flow Channel is a slower PV Discovery style channel built around a
// separate macro CVD EMA. Keep it off by default so the pane stays clean.
cvdMacroExtGroup                       = "CVD Macro Flow Channel"
showCvdMacroFlowExtension              = input.bool(defval = true, title = "Show Macro Flow Channel", group = cvdMacroExtGroup)
cvdMacroEmaLen                         = input.int(defval = 200, title = "Macro CVD EMA Length", minval = 1, maxval = 1000, group = cvdMacroExtGroup)
showCvdMacroEma                        = input.bool(defval = true, title = "Show Macro CVD EMA", group = cvdMacroExtGroup)
cvdMacroExtPivotLeft                   = input.int(defval = 3, title = "Macro Pivot Left", minval = 1, maxval = 20, group = cvdMacroExtGroup)
cvdMacroExtPivotRight                  = input.int(defval = 3, title = "Macro Pivot Right", minval = 1, maxval = 20, group = cvdMacroExtGroup)
cvdMacroExtMinSamples                  = input.int(defval = 5, title = "Macro Minimum Pivot Samples", minval = 1, maxval = 100, group = cvdMacroExtGroup)
cvdMacroExtAdaptiveLen                 = input.int(defval = 20, title = "Macro Adaptive Length", minval = 2, maxval = 300, group = cvdMacroExtGroup)
cvdMacroExtMode                        = input.string(defval = "Hybrid", title = "Macro Extension Mode", options = ["Average", "Adaptive", "Hybrid"], group = cvdMacroExtGroup)
cvdMacroExtHybridWeight                = input.float(defval = 0.50, title = "Macro Hybrid Average Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = cvdMacroExtGroup)
cvdMacroExtBandSmooth                  = input.int(defval = 5, title = "Macro Band Smoothing", minval = 1, maxval = 100, group = cvdMacroExtGroup)
showCvdMacroExtFill                    = input.bool(defval = true, title = "Show Macro Flow Fill", group = cvdMacroExtGroup)
showCvdMacroExtremeSignals             = input.bool(defval = false, title = "Show Macro Extreme Markers", group = cvdMacroExtGroup)
cvdMacroEmaCol                         = input.color(defval = color.rgb(255, 180, 0), title = "Macro EMA Color", group = cvdMacroExtGroup)
cvdMacroExtUpperCol                    = input.color(defval = color.rgb(255, 80, 80), title = "Macro Upper Channel Color", group = cvdMacroExtGroup)
cvdMacroExtLowerCol                    = input.color(defval = color.rgb(0, 220, 120), title = "Macro Lower Channel Color", group = cvdMacroExtGroup)
cvdMacroExtFillCol                     = input.color(defval = color.rgb(255, 180, 0), title = "Macro Flow Fill Color", group = cvdMacroExtGroup)

// CVD Z-score normalises the selected CVD source so extreme flow conditions can
// be identified independently of the raw CVD scale. It is used as an optional
// exhaustion layer and can also be combined with the Flow Extension bands.
cvdZGroup                              = "CVD Z-Score Extreme Engine"
showCvdZScoreSignals                   = input.bool(defval = true, title = "Show Z-Score Extreme Markers", group = cvdZGroup)
cvdZLen                                = input.int(defval = 100, title = "Z-Score Length", minval = 5, maxval = 1000, group = cvdZGroup)
cvdZThreshold                          = input.float(defval = 2.0, title = "Z-Score Extreme Threshold", minval = 0.1, step = 0.1, group = cvdZGroup)
cvdZSignalMode                         = input.string(defval = "State Change", title = "Z-Score Signal Print Mode", options = ["State Change", "Every Confirmed Bar"], group = cvdZGroup)
cvdZUpperCol                           = input.color(defval = color.rgb(255, 170, 0), title = "Positive Z Extreme Color", group = cvdZGroup)
cvdZLowerCol                           = input.color(defval = color.rgb(0, 220, 180), title = "Negative Z Extreme Color", group = cvdZGroup)



type cvdData

    array<float>  tickLevels 
    array<float>  cvd
    array<float>  buyVol 
    array<float>  sellVol 
    array<float>  totalVol 
    array<float>  deltaVol
    array<float>  activity

type singleProfileUDT

    array<box>   singleProfiledraw
    array<color> proColor
    int right = bar_index
    array<float> usdVol
    int         timeBlock




finTim = switch calcTypeInput
    
    calcType.REG => timeframe.change("1D")
    calcType.FS  => time[1] < fixedStartTime and time >= fixedStartTime


sz = switch textSize
    
    "Auto"             => size.auto
    "Tiny"             => size.tiny
    "Small"            => size.small
    "Normal"           => size.normal
    "Large"            => size.large
    "Huge"             => size.huge


method shifprofilespAll(array<float> tickLevels, array<float> cvd, array<float> buyVol, array<float> sellVol, array<float> totalVol, array<float> deltaVol, array<float> activity, pop = false) =>

    if tickLevels.size() > 90000

        switch pop 

            false => 

                     tickLevels.shift(), cvd.shift(), buyVol.shift(), sellVol.shift(), totalVol.shift(), deltaVol.shift(), activity.shift()

            =>    
                     tickLevels.pop() , cvd.shift(), buyVol.pop(), sellVol.pop(), totalVol.pop(), deltaVol.pop(), activity.pop()


method extendLines(array<line> id, sizeCount, startIndex) => 

    if id.size() > sizeCount 

        for i = id.size() - startIndex to 0 

            getValue = id.get(i).get_y1()

            if high >= getValue and low <= getValue 

                id.remove(i)
                continue 

            id.get(i).set_x2(time)


direction() => 
    if TF == "1T" 
        switch 
            close == bid => -1 
            close == ask =>  1
            =>               math.sign(close - close[1]) 
    else 
        math.sign(close - close[1])

f_cvd_signal_size(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : size.normal

f_flow_ext_select(_avg, _adaptive, _mode, _avgWeight) =>
    _mode == "Average" ? _avg : _mode == "Adaptive" ? _adaptive : not na(_avg) and not na(_adaptive) ? (_avgWeight * _avg + (1.0 - _avgWeight) * _adaptive) : na


profiles() => 

    var valueAreas          = array.new<float>()
    var valueAreaDrawings   = array.new<line> ()
    var pocDrawings         = array.new<line>()

    atr = ta.atr(14)

    [dayStart, dayEnd]             = request.security(syminfo.tickerid, "1D", [last_bar_time, time_close], lookahead = barmerge.lookahead_on)
    [ltfV, ltfD, ltfC, ltfH, ltfL] = request.security_lower_tf(syminfo.tickerid, TF, [volume * direction(), math.sign(close - close[1]), close, high, low])

    var cvd = 0. 

    cvd += nz(ltfV.sum())

    cvdDelta = nz(cvd - cvd[1]) 

    cvdAccel = nz(cvdDelta - (cvd[1] - cvd[2]))



    var lowOfMain = float(na), var highOfMain = float(na)

    desiredTF = timeframe.in_seconds(timeframe)

    var finalTF = switch 

        desiredTF < timeframe.in_seconds("") => timeframe.in_seconds("")
        =>          desiredTF

    lastDay = time >= dayStart and calcTypeInput == calcType.REG or time >= fixedStartTime and calcTypeInput == calcType.FS

    var tickAmount = 0.

    var TP = cvdData.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())

    var indexGet = 0 , var numberAdd  = 0, var startTime  = 0, 
    var max      = 0., var min = 20e20   , var IBend      = 0, 
    var indexIBS = 0., var indexIBE  = 0., var startTick  = 0.
    var maxIndex = 0 , var indexMax  = 0 , var startBar   = 0

    var profilesdraw       = array.new<label>(), var letterCount = array.new<int>(), 
    var singleProData = array.new<singleProfileUDT>(), isNew = false       

    if barstate.isfirst

        for i = 0 to 2
            singleProData.push(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))


    if profilesdraw.size() > 0 

        for i = 0 to profilesdraw.size() - 1

            profilesdraw.shift().delete()

    valueAreaDrawings.extendLines(2, 3)
    pocDrawings      .extendLines(1, 2)


    if finTim

        tickAmount := switch ticks == 0 

            true => atr   * syminfo.mintick
            =>      ticks * syminfo.mintick

        startTick     := math.floor(open / tickAmount) * tickAmount
        TP.tickLevels := array.from(startTick - tickAmount, startTick, startTick + tickAmount)
        TP.cvd        := array.from(0, 0, 0)
        TP.buyVol     := array.from(0, 0, 0)
        TP.sellVol    := array.from(0, 0, 0)
        TP.totalVol   := array.from(0, 0, 0)
        TP.deltaVol   := array.from(0, 0, 0)
        TP.activity   := array.from(0, 0, 0)

        isNew         := true 

        singleProData := array.new<singleProfileUDT>()

        
        if lastDay
                
            for i = 0 to 2
                singleProData.push(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))

                if i < 2 and showVA

                    valueAreaDrawings.push(line.new(time, close, time, close, xloc = xloc.bar_time, color = vaCol, style = line.style_dotted, force_overlay = true))

            pocDrawings.push(line.new(time, close, time, close, xloc = xloc.bar_time, color = POCcol, style = line.style_dotted, force_overlay = true))

        label.new(bar_index + 1, open, color = IBcol, style = label.style_circle, size = 2, force_overlay = true)
        label.new(bar_index + 1, open, color = color.new(IBcol, 80), style = label.style_circle, size = 3, force_overlay = true)

        IBend := timestamp(year, month, dayofmonth, hour + 1, 00, 00)

        indexGet := -1, numberAdd := 0,     startTime := time, startBar := bar_index
        max      := 0, min       := 20e20, indexIBS  := startTick, 
                             indexIBE := startTick
    var minUSDvol = float(na), var maxUSDvol = 0.
                


    if TP.tickLevels.size() > 0 and lastDay

        last  = TP.tickLevels.last () 
        first = TP.tickLevels.first()
        if TP.activity.size() > 0
            TP.activity.fill(0)

        max := math.max(max, high), min := math.min(min, low), 

        while high >= last

            last += tickAmount

            TP.tickLevels.push(last)
            TP.cvd       .push(0)
            TP.buyVol    .push(0)
            TP.sellVol   .push(0)
            TP.totalVol  .push(0)
            TP.deltaVol  .push(0)
            TP.activity  .push(0)

            TP.tickLevels.shifprofilespAll(TP.cvd, TP.buyVol, TP.sellVol, TP.totalVol, TP.deltaVol, TP.activity)

            if lastDay 

                singleProData.push(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))

        if time_close <= IBend

            indexIBE := math.max(high, indexIBE)

        while low <= first

            first -= tickAmount

            TP.tickLevels.unshift(first)
            TP.cvd       .unshift(0)
            TP.buyVol    .unshift(0)
            TP.sellVol   .unshift(0)
            TP.totalVol  .unshift(0)
            TP.deltaVol  .unshift(0)
            TP.activity  .unshift(0)

            TP.tickLevels.shifprofilespAll(TP.cvd, TP.buyVol, TP.sellVol, TP.totalVol, TP.deltaVol, TP.activity, true)
                
            if lastDay 

                singleProData.unshift(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))

        if time_close <= IBend 

            indexIBS := math.min(indexIBS, low)

        if ltfV.size() > 0 
            for [i, data] in ltfV

                start = TP.tickLevels.binary_search_leftmost(ltfL.get(i))
                end   = TP.tickLevels.binary_search_leftmost(ltfH.get(i))

                div   = data / (math.abs(end - start) + 1)

                for x = start to end 

                    add = TP.cvd.get(x) + nz(div)

                    TP.cvd.set(x, add)

                    absAmount = math.abs(nz(div))

                    switch math.sign(div)

                        1  => TP.buyVol .set(x, absAmount)
                        -1 => TP.sellVol.set(x, absAmount)

                    TP.totalVol.set(x, TP.totalVol.get(x) + absAmount)
                    TP.deltaVol.set(x, (nz(TP.buyVol.get(x) / TP.sellVol.get(x))))

                    mult = switch syminfo.volumetype != "quote"

                        false => 1
                        =>       ltfC.get(i)

                    switch model 

                        "USD Volume" => TP.activity.set(x, TP.activity.get(x) + (absAmount * mult))
                        =>              TP.activity.set(x, TP.activity.get(x) + absAmount)
                            
        timeN1 = startTime + timeframe.in_seconds("") * 1000, getTF = timeframe.from_seconds(desiredTF)

        getMax = TP.totalVol.max()

        valueIndexStart = 0, valueIndexEnd = 0, pocStart = TP.totalVol.indexof(getMax)

        bottom = 0, top = 0

        sumCount = TP.totalVol.sum(), arrSize = TP.totalVol.size()
        
        if na(lowOfMain)
            lowOfMain := low 
            highOfMain := high 

        lowOfMain  := math.min(low, lowOfMain)
        highOfMain := math.max(high, highOfMain)

        startIndex = TP.tickLevels.binary_search_leftmost(lowOfMain)
        endIndex   = TP.tickLevels.binary_search_leftmost(highOfMain)

        geprofilesCprice = switch 
            
            not na(pocStart) => TP.tickLevels.get(pocStart)
            =>                  float(na)

        if lastDay 

            pocDrawings.last().set_xy2(time, geprofilesCprice)
            pocDrawings.last().set_y1 (geprofilesCprice)

            for x = 0 to arrSize - 1

                slice = TP.totalVol.slice(math.max(pocStart - x, 0), math.min(pocStart + x + 1, arrSize))

                if slice.sum() / sumCount >= vaCumu

                    bottom := math.max(pocStart - x, 0)
                    top    := math.min(pocStart + x + 1, arrSize - 1)

                    getTop      = TP.tickLevels.get(top), getBot = TP.tickLevels.get(bottom)

                    if valueAreaDrawings.size() > 0

                        getDrawings = valueAreaDrawings.last()

                        getDrawings.set_y1(getTop), getDrawings.set_xy2(time, getTop)

                        getDrawings := valueAreaDrawings.get(-2)

                        getDrawings.set_y1(getBot), getDrawings.set_xy2(time, getBot)

                    break 

            midDay = math.avg(dayStart, dayEnd)


            lowOfMain := float(na)
            highOfMain := float(na)

            var timeBlock = time

            if timeframe.change(timeframe)

                timeBlock := time 

                if model == "Activity" or model == "USD Volume"

                    if singleProData.size() > 0 

                        for data in singleProData 
                            for boxes in data.singleProfiledraw

                                boxes.set_border_color(#000000)

            for i = startIndex to endIndex 

                getLevel = singleProData.get(i), 
                getPrice = TP.tickLevels.get(i), 
                getSize = getLevel.singleProfiledraw.size()
                getCVD   = TP.cvd.get(i), 
                deltaRatio = TP.deltaVol.get(i)

                left = switch getSize
            
                    0 => startBar + 2
                    =>   getLevel.right 

                transp = switch 
                    
                    i >= bottom and i <= top => 0
                    =>                          60


                absCVD = TP.cvd.abs(), absDelta = TP.deltaVol.abs()
                
                [minSeries, maxSeries, seriesNow] = switch model

                    "Imbalance Ratio" => [absDelta.min(), absDelta.max(), deltaRatio]
                    =>                   [absCVD.min(), absCVD.max(), getCVD]

                colorBox = switch math.sign(seriesNow)

                    1  => color.from_gradient(seriesNow, minSeries, maxSeries, color.new(upCol, 90), upCol)
                    -1 => color.from_gradient(math.abs(seriesNow), minSeries, maxSeries, color.new(dnCol, 90), dnCol)
                    =>    color.gray 

                if model == "Imbalance Ratio"

                    colorBox := switch 

                        seriesNow >= 1  => color.from_gradient(seriesNow, 1, absDelta.max(), color.new(upCol, 90), upCol)
                        seriesNow < 1   => color.from_gradient(math.abs(seriesNow), absDelta.min(), 1, dnCol, color.new(dnCol, 90))
                        =>    color.gray 


                if model == "Activity"

                    seriesNow := TP.activity.get(i) / volume 

                    colorBox := color.from_gradient(seriesNow, 0, 0.75, color.new(actCol, 90), actCol)

                if model == "USD Volume"

                    seriesNow := TP.activity.get(i)

                    colorBox := color.from_gradient(seriesNow, 0, 75, color.new(actCol, 90), actCol)

                if na(minUSDvol)

                    minUSDvol := seriesNow 

                minUSDvol := math.min(seriesNow, minUSDvol)
                maxUSDvol := math.max(seriesNow, maxUSDvol)

                if na(getLevel.timeBlock) or timeBlock > getLevel.timeBlock

                    getLevel.usdVol.push(seriesNow)

                    getLevel.singleProfiledraw.push(
                            box.new(
                                    left, getPrice , left + 1, getPrice + tickAmount,
                                            border_color = model == "Activity" or model == "USD Volume" ? #fff455: #000000,
                                            bgcolor      = colorBox, 
                                            text         = str.tostring(seriesNow, model == "Activity" or model == "Imbalance Ratio"  ? "0%" : model != "CVD" and model != "USD Volume" ? format.percent : format.volume), 
                                            text_color   = color.white, force_overlay = true
                                            )) 

                    getLevel.right := left + 1
                    getLevel.timeBlock := timeBlock

                else 

                    getLevel.usdVol.set(getLevel.usdVol.size() - 1, seriesNow)

                    getBox = getLevel.singleProfiledraw.last()

                    getBox.set_border_color(model == "Activity" or model == "USD Volume" ? #fff455: #000000)

                    getBox.set_bgcolor(colorBox)
                    getBox.set_text(str.tostring(seriesNow, model != "CVD" and model != "USD Volume" ? format.percent : format.volume))

    
        if lastDay 
                
            var box       VAbox                 = box  (na)
            var line      sessionLineLower      = line (na)
            var line      sessionOutlineLower   = line (na)
            var line      sessionLineUpper      = line (na)
            var line      sessionOutlineUpper   = line (na)
            var label     profilesLab                = label(na)
            var line      VAline                = line(na)
            var line      VAlineOutline         = line(na)
            var line      IBline                = line(na)
            var line      IBoutline             = line(na)

            VAbox               .delete(), sessionLineLower    .delete(), sessionOutlineLower .delete()
            sessionLineUpper    .delete(), sessionOutlineUpper .delete(), profilesLab              .delete()
            VAline              .delete(), VAlineOutline       .delete(), IBline              .delete(),
                                                 IBoutline.delete()

            getTop    = TP.tickLevels.get(top), getBot = TP.tickLevels.get(bottom), 

            IBline                := line.new(timeN1, indexIBS, timeN1, indexIBE, 
                                            xloc  = xloc.bar_time, 
                                            color = IBcol, force_overlay = true
                                            )
                
            var modelLab = label(na)
            modelLab.delete()

            if TP.tickLevels.size() > 0

                modelLab := label.new(timeN1 + timeframe.in_seconds("") * 1000 * 2, TP.tickLevels.last(), xloc = xloc.bar_time, text = model, textcolor = chart.fg_color, size = size.normal, color = #00000000, force_overlay = true)

            var ibOutLines = array.new<line>()

            if ibOutLines.size() > 0

                for i = 0 to ibOutLines.size() - 1
                    ibOutLines.shift().delete()

            transp = array.from(96, 97, 98, 99)

            for i = 0 to 3

                ibOutLines.push(line.new(timeN1, indexIBS, timeN1, indexIBE, xloc = xloc.bar_time, color = color.new(IBcol, transp.get(i)), width = (i + 1) * 4, force_overlay = true))

            var keyLevelsLabels = array.new<label>()
                
            size = keyLevelsLabels.size()

            if size > 0 
                for i = 0 to size - 1
                    keyLevelsLabels.shift().delete()

            prices = array.from(getBot, getTop, TP.tickLevels.get(math.floor(TP.tickLevels.size() / 2)), startTick, geprofilesCprice)
            texts  = array.from("VAL", "VAH", "Mid", "IB", "POC")
            colors = array.from(vaCol, vaCol, color.rgb(255, 116, 116), IBcol, POCcol)

            for [i, data] in prices 

                keyLevelsLabels.push(label.new(startTime, data, xloc = xloc.bar_time, 
                                            text      = texts.get(i) + " ▸",
                                            color     = #00000000, 
                                            textcolor = colors.get(i), 
                                            size      = size.small, 
                                            style     = label.style_label_right,
                                            force_overlay = true
                                            ))

                keyLevelsLabels.push(label.new(startTime, data, xloc = xloc.bar_time, 
                                            text      = texts.get(i) + " ▸",
                                            color     = #00000000, 
                                            textcolor = colors.get(i), 
                                            size      = size.small, 
                                            style     = label.style_label_right,
                                            force_overlay = true
                                            ))


            if session.islastbar and calcTypeInput == calcType.REG

                sizeLab = keyLevelsLabels.size()

                if sizeLab > 0 
                    for i = 0 to sizeLab - 1
                        keyLevelsLabels.shift().delete()

                profilesdraw             .clear(), sessionLineLower    := na
                sessionOutlineLower := na   , profilesLab              := na
                sessionLineUpper    := na   , sessionOutlineUpper := na
                VAbox               := na   , VAline              := na
                VAlineOutline       := na   , IBline              := na, 
                IBoutline           := na   , keyLevelsLabels.clear()
                ibOutLines.clear()
                singleProData.clear()
                minUSDvol := float(na)
                maxUSDvol := 0.
   
    if barstate.islast 

        // Guard: with a very old fixed anchor (e.g. 2000) there may be no labels yet
        // on early bars, so label.all.first() would throw RE10108.
        if label.all.size() > 0
            getLabX = label.all.first().get_x()
                
            for lines in line.all 
                if lines.get_x1() < getLabX 
                    lines.delete()

        if model == "USD Volume"

            if singleProData.size() > 0 
                for data in singleProData
                    for [x, boxes] in data.singleProfiledraw 

                        getVol   = data.usdVol.get(x)

                        boxes.set_bgcolor(color.from_gradient(getVol, minUSDvol, maxUSDvol, color.new(usdCol, 90), usdCol))



    [cvdAccel, cvdDelta, cvd]

[cvdAccel, cvdDelta, cvdBalance] = profiles()

var maxAmt = array.new<float>(0) 

plotSeries = switch offChart == "CVD Delta"

    true => cvdDelta
    =>      cvdAccel


if not na(plotSeries)

    absData = math.abs(plotSeries)

    if maxAmt.size() == 0 

        maxAmt .push(absData)

    else 

        if absData > maxAmt.min()

            search = maxAmt.binary_search_rightmost(absData)

            maxAmt.insert(search, absData)

            if maxAmt.size() > 50
                maxAmt.shift()

colCols = switch

    plotSeries >= 0 => color.from_gradient(plotSeries, 0, maxAmt.min() , color.new(upCol, 90), upCol)
    =>                 color.from_gradient(plotSeries, -maxAmt.min() , 0, dnCol, color.new(dnCol, 90))

plot(showOriginalColumns ? plotSeries : na, title = "Original CVD Delta / Accel Columns", style = plot.style_columns, color = colCols)

//──────────────────────────────────────────────────────────────────────────────
// Retention-style CVD candles
// - CVD Balance is the cumulative CVD line from the lower-timeframe delta.
// - Candle close = selected CVD source.
// - Candle open  = prior candle close, like the retention candles.
// - Candle color = above / below its own EMA.
// - Optional structure coloring highlights HH/HL bullish recovery under EMA
//   and LH/LL bearish deterioration above EMA.
// - EMA color    = green when slope is meaningfully up, red when down, yellow in range.
//──────────────────────────────────────────────────────────────────────────────
cvdRetClose = switch cvdRetSource

    "CVD Balance"      => cvdBalance
    "CVD Delta"        => cvdDelta
    =>                    cvdAccel

cvdRetOpen = nz(cvdRetClose[1], cvdRetClose)
cvdRetBody = math.abs(cvdRetClose - cvdRetOpen)
cvdRetWick = ta.ema(cvdRetBody, cvdRetWickSmooth) * cvdRetWickFactor
cvdRetHigh = math.max(cvdRetOpen, cvdRetClose) + cvdRetWick
cvdRetLow  = math.min(cvdRetOpen, cvdRetClose) - cvdRetWick

cvdRetEma = ta.ema(cvdRetClose, cvdRetEmaLen)
cvdRetEmaBase = math.max(math.abs(cvdRetEma[1]), 1.0)
cvdRetEmaSlopePct = not na(cvdRetEma[1]) ? (cvdRetEma - cvdRetEma[1]) / cvdRetEmaBase * 100.0 : 0.0
cvdRetEmaColor = cvdRetEmaSlopePct > cvdRetEmaSlopeThresholdPct ? cvdEmaBullCol : cvdRetEmaSlopePct < -cvdRetEmaSlopeThresholdPct ? cvdEmaBearCol : cvdEmaRangeCol

// Structure-aware retention coloring:
// HH/HL under EMA = bullish recovery / flow rebuilding before the EMA is reclaimed.
// LH/LL above EMA = bearish deterioration / flow weakening before the EMA is lost.
cvdStructHigherHigh = not na(cvdRetHigh[cvdStructureLookback]) and cvdRetHigh > cvdRetHigh[cvdStructureLookback]
cvdStructHigherLow = not na(cvdRetLow[cvdStructureLookback]) and cvdRetLow > cvdRetLow[cvdStructureLookback]
cvdStructLowerHigh = not na(cvdRetHigh[cvdStructureLookback]) and cvdRetHigh < cvdRetHigh[cvdStructureLookback]
cvdStructLowerLow = not na(cvdRetLow[cvdStructureLookback]) and cvdRetLow < cvdRetLow[cvdStructureLookback]
cvdStructBullRecovery = cvdUseStructureColoring and cvdRetClose < cvdRetEma and cvdStructHigherHigh and cvdStructHigherLow
cvdStructBearDeterioration = cvdUseStructureColoring and cvdRetClose > cvdRetEma and cvdStructLowerHigh and cvdStructLowerLow

cvdRetCandleColor = cvdStructBullRecovery ? cvdBullRecoveryCol : cvdStructBearDeterioration ? cvdBearDeteriorationCol : cvdRetClose >= cvdRetEma ? cvdAboveEmaCol : cvdBelowEmaCol

plotcandle(showCvdRetCandles ? cvdRetOpen : na, showCvdRetCandles ? cvdRetHigh : na, showCvdRetCandles ? cvdRetLow : na, showCvdRetCandles ? cvdRetClose : na, title = "CVD Retention-Style Candles | Bright green = above EMA, dark green = HH/HL recovery under EMA, grey = below EMA, orange = LH/LL deterioration above EMA", color = cvdRetCandleColor, wickcolor = cvdRetCandleColor, bordercolor = cvdRetCandleColor)
plot(showCvdRetCandles ? cvdRetEma : na, title = "CVD Retention EMA", color = cvdRetEmaColor, linewidth = 2)

//──────────────────────────────────────────────────────────────────────────────
// CVD Flow Extension Engine + Z-Score Extreme Engine
// Flow Extension bands use a PV Discovery style approach, but on CVD instead of
// price. The script measures confirmed CVD pivot extensions from the CVD EMA and
// projects adaptive upper/lower bands around the EMA.
// Z-score normalises the same CVD source and flags statistical extremes.
//──────────────────────────────────────────────────────────────────────────────
cvdExtPivotHigh = ta.pivothigh(cvdRetHigh, cvdExtPivotLeft, cvdExtPivotRight)
cvdExtPivotLow = ta.pivotlow(cvdRetLow, cvdExtPivotLeft, cvdExtPivotRight)
cvdExtPivotEma = cvdRetEma[cvdExtPivotRight]

cvdUpperExtRaw = not na(cvdExtPivotHigh) and not na(cvdExtPivotEma) and cvdExtPivotHigh > cvdExtPivotEma ? cvdExtPivotHigh - cvdExtPivotEma : na
cvdLowerExtRaw = not na(cvdExtPivotLow) and not na(cvdExtPivotEma) and cvdExtPivotLow < cvdExtPivotEma ? cvdExtPivotEma - cvdExtPivotLow : na

var float cvdUpperExtSum = 0.0
var int cvdUpperExtSamples = 0
var float cvdUpperExtAvg = na
var float cvdUpperExtAdaptive = na

var float cvdLowerExtSum = 0.0
var int cvdLowerExtSamples = 0
var float cvdLowerExtAvg = na
var float cvdLowerExtAdaptive = na

cvdExtAlpha = 2.0 / (cvdExtLowerAdaptiveLen + 1.0)

if not na(cvdUpperExtRaw) and cvdUpperExtRaw > 0
    cvdUpperExtSum += cvdUpperExtRaw
    cvdUpperExtSamples += 1
    cvdUpperExtAvg := cvdUpperExtSum / cvdUpperExtSamples
    cvdUpperExtAdaptive := na(cvdUpperExtAdaptive) ? cvdUpperExtRaw : cvdUpperExtAdaptive + cvdExtAlpha * (cvdUpperExtRaw - cvdUpperExtAdaptive)

if not na(cvdLowerExtRaw) and cvdLowerExtRaw > 0
    cvdLowerExtSum += cvdLowerExtRaw
    cvdLowerExtSamples += 1
    cvdLowerExtAvg := cvdLowerExtSum / cvdLowerExtSamples
    cvdLowerExtAdaptive := na(cvdLowerExtAdaptive) ? cvdLowerExtRaw : cvdLowerExtAdaptive + cvdExtAlpha * (cvdLowerExtRaw - cvdLowerExtAdaptive)

cvdUpperEnough = cvdUpperExtSamples >= cvdExtMinSamples
cvdLowerEnough = cvdLowerExtSamples >= cvdExtMinSamples
cvdUpperExtChosen = cvdUpperEnough ? f_flow_ext_select(cvdUpperExtAvg, cvdUpperExtAdaptive, cvdExtMode, cvdExtHybridWeight) : na
cvdLowerExtChosen = cvdLowerEnough ? f_flow_ext_select(cvdLowerExtAvg, cvdLowerExtAdaptive, cvdExtMode, cvdExtHybridWeight) : na

cvdUpperFlowBandRaw = not na(cvdUpperExtChosen) ? cvdRetEma + cvdUpperExtChosen : na
cvdLowerFlowBandRaw = not na(cvdLowerExtChosen) ? cvdRetEma - cvdLowerExtChosen : na
cvdUpperFlowBand = cvdExtBandSmooth > 1 ? ta.ema(cvdUpperFlowBandRaw, cvdExtBandSmooth) : cvdUpperFlowBandRaw
cvdLowerFlowBand = cvdExtBandSmooth > 1 ? ta.ema(cvdLowerFlowBandRaw, cvdExtBandSmooth) : cvdLowerFlowBandRaw

cvdUpperBandPlot = plot(showCvdRetCandles and showCvdFlowExtension ? cvdUpperFlowBand : na, title = "CVD Upper Flow Extension Band | Learned from average CVD pivot extension above EMA", color = cvdExtUpperCol, linewidth = 1)
cvdLowerBandPlot = plot(showCvdRetCandles and showCvdFlowExtension ? cvdLowerFlowBand : na, title = "CVD Lower Flow Extension Band | Learned from average CVD pivot extension below EMA", color = cvdExtLowerCol, linewidth = 1)
fill(cvdUpperBandPlot, cvdLowerBandPlot, title = "CVD Flow Fair Value Zone", color = showCvdRetCandles and showCvdFlowExtension and showCvdExtFill ? color.new(cvdExtFillCol, 92) : na)

// Macro CVD Flow Channel. This is the same PV-style extension logic as the main
// Flow Extension Engine, but projected around a slower macro CVD EMA.
cvdMacroEma = ta.ema(cvdRetClose, cvdMacroEmaLen)
cvdMacroExtPivotHigh = ta.pivothigh(cvdRetHigh, cvdMacroExtPivotLeft, cvdMacroExtPivotRight)
cvdMacroExtPivotLow = ta.pivotlow(cvdRetLow, cvdMacroExtPivotLeft, cvdMacroExtPivotRight)
cvdMacroExtPivotEma = cvdMacroEma[cvdMacroExtPivotRight]

cvdMacroUpperExtRaw = not na(cvdMacroExtPivotHigh) and not na(cvdMacroExtPivotEma) and cvdMacroExtPivotHigh > cvdMacroExtPivotEma ? cvdMacroExtPivotHigh - cvdMacroExtPivotEma : na
cvdMacroLowerExtRaw = not na(cvdMacroExtPivotLow) and not na(cvdMacroExtPivotEma) and cvdMacroExtPivotLow < cvdMacroExtPivotEma ? cvdMacroExtPivotEma - cvdMacroExtPivotLow : na

var float cvdMacroUpperExtSum = 0.0
var int cvdMacroUpperExtSamples = 0
var float cvdMacroUpperExtAvg = na
var float cvdMacroUpperExtAdaptive = na

var float cvdMacroLowerExtSum = 0.0
var int cvdMacroLowerExtSamples = 0
var float cvdMacroLowerExtAvg = na
var float cvdMacroLowerExtAdaptive = na

cvdMacroExtAlpha = 2.0 / (cvdMacroExtAdaptiveLen + 1.0)

if not na(cvdMacroUpperExtRaw) and cvdMacroUpperExtRaw > 0
    cvdMacroUpperExtSum += cvdMacroUpperExtRaw
    cvdMacroUpperExtSamples += 1
    cvdMacroUpperExtAvg := cvdMacroUpperExtSum / cvdMacroUpperExtSamples
    cvdMacroUpperExtAdaptive := na(cvdMacroUpperExtAdaptive) ? cvdMacroUpperExtRaw : cvdMacroUpperExtAdaptive + cvdMacroExtAlpha * (cvdMacroUpperExtRaw - cvdMacroUpperExtAdaptive)

if not na(cvdMacroLowerExtRaw) and cvdMacroLowerExtRaw > 0
    cvdMacroLowerExtSum += cvdMacroLowerExtRaw
    cvdMacroLowerExtSamples += 1
    cvdMacroLowerExtAvg := cvdMacroLowerExtSum / cvdMacroLowerExtSamples
    cvdMacroLowerExtAdaptive := na(cvdMacroLowerExtAdaptive) ? cvdMacroLowerExtRaw : cvdMacroLowerExtAdaptive + cvdMacroExtAlpha * (cvdMacroLowerExtRaw - cvdMacroLowerExtAdaptive)

cvdMacroUpperEnough = cvdMacroUpperExtSamples >= cvdMacroExtMinSamples
cvdMacroLowerEnough = cvdMacroLowerExtSamples >= cvdMacroExtMinSamples
cvdMacroUpperExtChosen = cvdMacroUpperEnough ? f_flow_ext_select(cvdMacroUpperExtAvg, cvdMacroUpperExtAdaptive, cvdMacroExtMode, cvdMacroExtHybridWeight) : na
cvdMacroLowerExtChosen = cvdMacroLowerEnough ? f_flow_ext_select(cvdMacroLowerExtAvg, cvdMacroLowerExtAdaptive, cvdMacroExtMode, cvdMacroExtHybridWeight) : na

cvdMacroUpperFlowBandRaw = not na(cvdMacroUpperExtChosen) ? cvdMacroEma + cvdMacroUpperExtChosen : na
cvdMacroLowerFlowBandRaw = not na(cvdMacroLowerExtChosen) ? cvdMacroEma - cvdMacroLowerExtChosen : na
cvdMacroUpperFlowBand = cvdMacroExtBandSmooth > 1 ? ta.ema(cvdMacroUpperFlowBandRaw, cvdMacroExtBandSmooth) : cvdMacroUpperFlowBandRaw
cvdMacroLowerFlowBand = cvdMacroExtBandSmooth > 1 ? ta.ema(cvdMacroLowerFlowBandRaw, cvdMacroExtBandSmooth) : cvdMacroLowerFlowBandRaw

plot(showCvdRetCandles and showCvdMacroEma ? cvdMacroEma : na, title = "Macro CVD EMA | Slow CVD regime baseline", color = cvdMacroEmaCol, linewidth = 2)
cvdMacroUpperBandPlot = plot(showCvdRetCandles and showCvdMacroFlowExtension ? cvdMacroUpperFlowBand : na, title = "Macro CVD Upper Flow Channel | Slow learned CVD extension above macro EMA", color = cvdMacroExtUpperCol, linewidth = 2)
cvdMacroLowerBandPlot = plot(showCvdRetCandles and showCvdMacroFlowExtension ? cvdMacroLowerFlowBand : na, title = "Macro CVD Lower Flow Channel | Slow learned CVD extension below macro EMA", color = cvdMacroExtLowerCol, linewidth = 2)
fill(cvdMacroUpperBandPlot, cvdMacroLowerBandPlot, title = "Macro CVD Flow Fair Value Zone", color = showCvdRetCandles and showCvdMacroFlowExtension and showCvdMacroExtFill ? color.new(cvdMacroExtFillCol, 94) : na)

cvdAtUpperExtension = showCvdRetCandles and showCvdFlowExtension and not na(cvdUpperFlowBand) and cvdRetClose >= cvdUpperFlowBand
cvdAtLowerExtension = showCvdRetCandles and showCvdFlowExtension and not na(cvdLowerFlowBand) and cvdRetClose <= cvdLowerFlowBand
cvdAtMacroUpperExtension = showCvdRetCandles and showCvdMacroFlowExtension and not na(cvdMacroUpperFlowBand) and cvdRetClose >= cvdMacroUpperFlowBand
cvdAtMacroLowerExtension = showCvdRetCandles and showCvdMacroFlowExtension and not na(cvdMacroLowerFlowBand) and cvdRetClose <= cvdMacroLowerFlowBand

cvdZBasis = ta.sma(cvdRetClose, cvdZLen)
cvdZDev = ta.stdev(cvdRetClose, cvdZLen)
cvdZScore = not na(cvdZDev) and cvdZDev != 0.0 ? (cvdRetClose - cvdZBasis) / cvdZDev : na
cvdPositiveZExtreme = showCvdRetCandles and not na(cvdZScore) and cvdZScore >= cvdZThreshold
cvdNegativeZExtreme = showCvdRetCandles and not na(cvdZScore) and cvdZScore <= -cvdZThreshold
cvdZCanPrint = showCvdZScoreSignals and barstate.isconfirmed and (cvdZSignalMode == "Every Confirmed Bar" or cvdPositiveZExtreme != cvdPositiveZExtreme[1] or cvdNegativeZExtreme != cvdNegativeZExtreme[1])

plot(cvdZScore, title = "CVD Z-Score", color = color.new(chart.fg_color, 100), display = display.data_window)

plotshape(showCvdExtremeSignals and cvdAtUpperExtension ? cvdRetHigh : na, title = "CVD Upper Flow Extension | CVD is stretched above its learned pivot-extension band", style = shape.diamond, location = location.absolute, color = cvdExtUpperCol, size = size.tiny)
plotshape(showCvdExtremeSignals and cvdAtLowerExtension ? cvdRetLow : na, title = "CVD Lower Flow Extension | CVD is stretched below its learned pivot-extension band", style = shape.diamond, location = location.absolute, color = cvdExtLowerCol, size = size.tiny)
plotshape(showCvdMacroExtremeSignals and cvdAtMacroUpperExtension ? cvdRetHigh : na, title = "Macro CVD Upper Flow Extension | CVD is stretched above its slow learned macro channel", style = shape.square, location = location.absolute, color = cvdMacroExtUpperCol, size = size.tiny)
plotshape(showCvdMacroExtremeSignals and cvdAtMacroLowerExtension ? cvdRetLow : na, title = "Macro CVD Lower Flow Extension | CVD is stretched below its slow learned macro channel", style = shape.square, location = location.absolute, color = cvdMacroExtLowerCol, size = size.tiny)
plotshape(cvdZCanPrint and cvdPositiveZExtreme ? cvdRetHigh : na, title = "CVD Positive Z-Score Extreme | Selected CVD source is statistically stretched above its mean", style = shape.xcross, location = location.absolute, color = cvdZUpperCol, size = size.tiny)
plotshape(cvdZCanPrint and cvdNegativeZExtreme ? cvdRetLow : na, title = "CVD Negative Z-Score Extreme | Selected CVD source is statistically stretched below its mean", style = shape.xcross, location = location.absolute, color = cvdZLowerCol, size = size.tiny)

alertcondition(cvdAtUpperExtension, title = "CVD Upper Flow Extension", message = "CVD reached its upper learned flow extension band on {{ticker}} {{interval}}")
alertcondition(cvdAtLowerExtension, title = "CVD Lower Flow Extension", message = "CVD reached its lower learned flow extension band on {{ticker}} {{interval}}")
alertcondition(cvdAtMacroUpperExtension, title = "Macro CVD Upper Flow Extension", message = "CVD reached its upper macro flow channel on {{ticker}} {{interval}}")
alertcondition(cvdAtMacroLowerExtension, title = "Macro CVD Lower Flow Extension", message = "CVD reached its lower macro flow channel on {{ticker}} {{interval}}")
alertcondition(cvdPositiveZExtreme, title = "CVD Positive Z-Score Extreme", message = "CVD reached a positive Z-score extreme on {{ticker}} {{interval}}")
alertcondition(cvdNegativeZExtreme, title = "CVD Negative Z-Score Extreme", message = "CVD reached a negative Z-score extreme on {{ticker}} {{interval}}")

//──────────────────────────────────────────────────────────────────────────────
// CVD Divergence Triangles
// Bullish divergence = price makes a lower pivot low while CVD makes a higher low.
// Bearish divergence = price makes a higher pivot high while CVD makes a lower high.
// Triangles are drawn on the confirmed pivot bar using tiny labels with tooltips.
// The signal confirms cvdDivPivotRight bars after the actual pivot.
//──────────────────────────────────────────────────────────────────────────────
cvdDivSize = f_cvd_signal_size(cvdDivTriangleSizeInput)

pricePivotLow = ta.pivotlow(low, cvdDivPivotLeft, cvdDivPivotRight)
pricePivotHigh = ta.pivothigh(high, cvdDivPivotLeft, cvdDivPivotRight)

var float prevBullPricePivot = na
var float prevBullCvdPivot = na
var float prevBearPricePivot = na
var float prevBearCvdPivot = na

cvdBullDiv = false
cvdBearDiv = false

if showCvdDivTriangles and showCvdBullDiv and not na(pricePivotLow) and not na(cvdRetClose[cvdDivPivotRight])
    currBullPricePivot = pricePivotLow
    currBullCvdPivot = cvdRetClose[cvdDivPivotRight]
    cvdBullDiv := not na(prevBullPricePivot) and not na(prevBullCvdPivot) and currBullPricePivot < prevBullPricePivot and currBullCvdPivot > prevBullCvdPivot

    if cvdBullDiv
        label.new(bar_index - cvdDivPivotRight, cvdRetLow[cvdDivPivotRight], "", style = label.style_triangleup, color = cvdBullDivTriangleCol, textcolor = cvdBullDivTriangleCol, size = cvdDivSize, tooltip = "Bullish CVD divergence\nPrice: lower low\nCVD: higher low\nSignal confirms after " + str.tostring(cvdDivPivotRight) + " bars\nPrice pivot: " + str.tostring(currBullPricePivot, format.mintick) + "\nCVD pivot: " + str.tostring(currBullCvdPivot, format.volume))

    prevBullPricePivot := currBullPricePivot
    prevBullCvdPivot := currBullCvdPivot

if showCvdDivTriangles and showCvdBearDiv and not na(pricePivotHigh) and not na(cvdRetClose[cvdDivPivotRight])
    currBearPricePivot = pricePivotHigh
    currBearCvdPivot = cvdRetClose[cvdDivPivotRight]
    cvdBearDiv := not na(prevBearPricePivot) and not na(prevBearCvdPivot) and currBearPricePivot > prevBearPricePivot and currBearCvdPivot < prevBearCvdPivot

    if cvdBearDiv
        label.new(bar_index - cvdDivPivotRight, cvdRetHigh[cvdDivPivotRight], "", style = label.style_triangledown, color = cvdBearDivTriangleCol, textcolor = cvdBearDivTriangleCol, size = cvdDivSize, tooltip = "Bearish CVD divergence\nPrice: higher high\nCVD: lower high\nSignal confirms after " + str.tostring(cvdDivPivotRight) + " bars\nPrice pivot: " + str.tostring(currBearPricePivot, format.mintick) + "\nCVD pivot: " + str.tostring(currBearCvdPivot, format.volume))

    prevBearPricePivot := currBearPricePivot
    prevBearCvdPivot := currBearCvdPivot

alertcondition(cvdBullDiv, title = "Bullish CVD Divergence", message = "Bullish CVD divergence on {{ticker}} {{interval}}")
alertcondition(cvdBearDiv, title = "Bearish CVD Divergence", message = "Bearish CVD divergence on {{ticker}} {{interval}}")

//──────────────────────────────────────────────────────────────────────────────
// CVD Strength Signals
// Strong Bull = CVD is above EMA, EMA is rising, and CVD is above N bars ago.
// Strong Bear = CVD is below EMA, EMA is falling, and CVD is below N bars ago.
// Weak Bull = CVD still above EMA but EMA momentum is no longer bullish.
// Weak Bear = CVD still below EMA but EMA momentum is no longer bearish.
// These labels print on the CURRENT confirmation candle only. No pivot offsets.
//──────────────────────────────────────────────────────────────────────────────
cvdEmaSlopeUp = cvdRetEmaSlopePct > cvdRetEmaSlopeThresholdPct
cvdEmaSlopeDown = cvdRetEmaSlopePct < -cvdRetEmaSlopeThresholdPct
cvdAboveEma = cvdRetClose > cvdRetEma
cvdBelowEma = cvdRetClose < cvdRetEma
cvdMomentumUp = not na(cvdRetClose[cvdStrengthMomentumBars]) and cvdRetClose > cvdRetClose[cvdStrengthMomentumBars]
cvdMomentumDown = not na(cvdRetClose[cvdStrengthMomentumBars]) and cvdRetClose < cvdRetClose[cvdStrengthMomentumBars]

cvdStrongBull = showCvdRetCandles and cvdAboveEma and cvdEmaSlopeUp and cvdMomentumUp
cvdStrongBear = showCvdRetCandles and cvdBelowEma and cvdEmaSlopeDown and cvdMomentumDown
cvdWeakBull = showCvdRetCandles and cvdAboveEma and not cvdEmaSlopeUp
cvdWeakBear = showCvdRetCandles and cvdBelowEma and not cvdEmaSlopeDown

cvdStrengthState = cvdStrongBull ? 2 : cvdStrongBear ? -2 : cvdWeakBull ? 1 : cvdWeakBear ? -1 : 0
cvdStateChanged = cvdStrengthState != cvdStrengthState[1]
cvdCanPrint = showCvdStrengthSignals and barstate.isconfirmed and (cvdSignalMode == "Every Confirmed Bar" or cvdStateChanged)
cvdWeakCanPrint = cvdCanPrint and showCvdWeakSignals
cvdSigSize = f_cvd_signal_size(cvdSignalSizeInput)

// Strong bull/bear are plotted as clean circles instead of text labels.
// Hover the circle in TradingView to see the signal description from the title.
plotshape(cvdCanPrint and cvdStrongBull ? cvdRetLow : na, title = "CVD Strong Bull | CVD is above EMA, EMA slope is bullish, and CVD momentum is rising versus the selected lookback", style = shape.circle, location = location.absolute, color = cvdStrongBullLabelCol, size = size.tiny)
plotshape(cvdCanPrint and cvdStrongBear ? cvdRetHigh : na, title = "CVD Strong Bear | CVD is below EMA, EMA slope is bearish, and CVD momentum is falling versus the selected lookback", style = shape.circle, location = location.absolute, color = cvdStrongBearLabelCol, size = size.tiny)

if cvdWeakCanPrint and cvdWeakBull
    label.new(bar_index, cvdRetLow, "CVD\nWEAK\nBULL", style = label.style_label_up, color = cvdWeakBullLabelCol, textcolor = color.black, size = cvdSigSize)

if cvdWeakCanPrint and cvdWeakBear
    label.new(bar_index, cvdRetHigh, "CVD\nWEAK\nBEAR", style = label.style_label_down, color = cvdWeakBearLabelCol, textcolor = color.black, size = cvdSigSize)

alertcondition(cvdCanPrint and (cvdStrongBull or cvdStrongBear or (showCvdWeakSignals and (cvdWeakBull or cvdWeakBear))), title = "CVD Strength Signal", message = "CVD strength state changed on {{ticker}} {{interval}}")

if barstate.islast 

    if calcTypeInput == calcType.FS

        var vline = line(na), var vlab = label(na)

        vline.delete(), vlab.delete()

        vline := line.new (fixedStartTime, 0, fixedStartTime, 0.0001, xloc = xloc.bar_time, extend = extend.both, color = chart.fg_color, width = 2)
        vlab  := label.new(fixedStartTime, 0, xloc = xloc.bar_time, color = #00000000, textcolor = chart.fg_color, text = "Drag Me")


    if box.all.size() >= 495 

        var tab    = table.new(position.top_right, 99, 99, 
                                        bgcolor       = #20222C, 
                                        border_color  = #363843, 
                                        frame_color   = #363843, 
                                        border_width  = 1, 
                                        frame_width   = 1, 
                                        force_overlay = true
                                        )
        tab.clear(0, 0, 0, 0)
        tab.cell(0, 0, text = 'Increase "Tick Size" Or "Timeframe To Calculate On"', text_color = color.white, text_size = size.small)
````

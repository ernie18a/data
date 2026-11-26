# AMT Market Phase [TradingIQ + Ethan]

- url: https://www.tradingview.com/script/kzJBbJO3-AMT-Market-Phase-TradingIQ-Ethan/
- type: indicator
- pine_id: PUB;8e05f2b1a3bc4598ad45d590f9f5d341
- version: 1.0

## Description

Hello Traders!

🔹[b]AMT Market Phase[/b]

AMT Market Phase is a market structure tool designed to identify when price is trading inside a balanced range versus when it has moved out of balance.

Instead of only marking highs and lows, this tool uses a TPO-style value area model to study where price has spent time, where value is forming, and when price breaks away from that accepted area.

Think of it as a way to visualize [b]balance, imbalance, and developing market phase shifts across multiple timeframes[/b].

[list]
[*]detects balanced and out-of-balance market phases
[*]builds TPO-style value areas from price activity
[*]marks VAH, VAL, and POC levels
[*]uses ATR buffering to filter minor value-area breaks
[*]supports multiple timeframe phase tracking
[*]optional value area, POC, and profile displays
[/list]

🔹[b]What the tool shows[/b]

🔸[b]Balance vs out of balance[/b]

The script classifies the market into two core states:

[list]
[*]Balance
[*]Out of Balance
[/list]

Balance means price is still trading within its accepted value area.

Out of Balance means price has moved beyond the buffered value area, suggesting that price may be leaving the prior area of acceptance.

This helps you quickly see whether the market is rotating inside a range or attempting to expand away from it.

[image]https://www.tradingview.com/x/cHD4d7z3/[/image] 


🔸[b]TPO-based value area[/b]

The tool builds a TPO-style profile from the active market range and calculates key levels:

[list]
[*]VAH, or Value Area High
[*]VAL, or Value Area Low
[*]POC, or Point of Control
[/list]

These levels represent where price has spent meaningful time during the current balance structure.

Instead of using a fixed lookback range, the profile expands and updates based on the active phase of the market.

[image]https://www.tradingview.com/x/W3ST7WX9/[/image] 


🔸[b]Buffered value area breaks[/b]

AMT Market Phase includes an ATR-based buffer around the value area.

This helps reduce noise by requiring price to move a meaningful distance beyond value before being classified as out of balance.

This helps separate:
[list]
[*]minor value-area probes
[*]weak fakeouts
[*]stronger attempts to leave balance
[/list]

[image]https://www.tradingview.com/x/j6K5l4NG/[/image] 

[image]https://www.tradingview.com/x/jv6NME7r/[/image] 

🔸[b]Multi-timeframe phase tracking[/b]

The indicator can track market phase across multiple timeframes.

This allows you to compare lower-timeframe and higher-timeframe structure directly on the chart.

You can use it to see:
[list]
[*]whether the current timeframe is balanced
[*]whether higher timeframes are out of balance
[*]whether multiple timeframes agree or conflict
[*]where larger value areas may be influencing price
[/list]

🔸[b]Visual value zones[/b]

The script can draw the active balance area directly on the chart.

Depending on your settings, it can display:
[list]
[*]value area zones
[*]POC lines
[*]VAH and VAL levels
[*]profile-style visuals
[*]recent balance ranges only
[/list]

This gives a clean visual map of where value has formed and where price is attempting to break away from that value.

[image]https://www.tradingview.com/x/Z6f6sbxA/[/image] 

🔸[b]Phase table[/b]

The built-in table summarizes the current phase across key timeframes.

It shows whether each tracked timeframe is in:

[list]
[*]BALANCE
[*]OUT OF BALANCE
[/list]

When price is out of balance, the table can also show directional context using arrows.

🔹[b]How to read it[/b]

Each component gives a different layer of market context:

Balance zone → where price has been accepted  
VAH → upper edge of value  
VAL → lower edge of value  
POC → most active price area  
Buffered VA → filtered balance boundary  
Out of Balance → price attempting to leave value  
Phase table → multi-timeframe market state  

🔹[b]Why this tool is useful[/b]

It gives you:
[list]
[*]a structured way to identify balance and imbalance
[*]objective value-area levels based on price activity
[*]multi-timeframe context for market phase
[*]a cleaner alternative to manually drawing ranges
[*]visual reference points for where price is accepted or rejected
[/list]

🔹[b]Best use cases[/b]

[list]
[*]identifying balanced market conditions
[*]tracking when price leaves value
[*]studying range expansion and acceptance
[*]comparing market phase across timeframes
[*]building context around VAH, VAL, and POC
[*]understanding whether price is rotating or expanding
[/list]

🔹[b]Important note[/b]

This tool is based on TPO-style value-area analysis and historical price structure.

That means:
[list]
[*]balance does not guarantee price will remain inside the range
[*]out of balance does not guarantee trend continuation
[*]value areas are context zones, not automatic trade signals
[*]market conditions can change quickly
[*]outputs should be used as context, not certainty
[/list]

🔹[b]Inputs you can customize[/b]

The script includes flexible controls such as:
[list]
[*]custom timeframe selection
[*]timeframe colors
[*]POC display toggles
[*]value area display toggles
[*]profile display toggles
[*]recent range only mode
[*]value area percentage
[*]ATR multiplier for balance filtering
[*]minimum profile bars
[*]table position
[/list]

[b]Closing Notes[/b]

AMT Market Phase is built to shift the focus from simply asking [b]where price is moving[/b] to understanding [b]whether price is accepted or rejected around value[/b].

It helps traders visualize when the market is balanced, when it is leaving balance, and how that behavior lines up across multiple timeframes.

Thank you for checking it out!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("AMT Market Phase [TradingIQ + Ethan]", overlay = true, calc_bars_count = 20000, max_bars_back = 5000, max_lines_count = 500, max_boxes_count = 500, dynamic_requests = true)

// ── Inputs ──
var groupMain = "Phase Detection"

TF1 = input.timeframe(defval = "", title = "TF1", inline = "TF1")   , colTF1 = input.color(defval = color.new(color.blue, 0), inline = "TF1", title = "")  , pocTF1   = input.bool(defval = false, title = "POC", inline = "TF1"), vaTF1   = input.bool(defval = false, title = "VA", inline = "TF1"), vpTF1   = input.bool(defval = false, title = "Profile", inline = "TF1")
TF2 = input.timeframe(defval = "240", title = "TF2", inline = "TF2"), colTF2 = input.color(defval = color.new(color.orange, 0), inline = "TF2", title = ""), pocTF2 = input.bool(defval = false, title = "POC", inline = "TF2")  , vaTF2 = input.bool(defval = false, title = "VA", inline = "TF2"), vpTF2 = input.bool(defval = false, title = "Profile", inline = "TF2")
TF3 = input.timeframe(defval = "1D", title = "TF3" , inline = "TF3"), colTF3 = input.color(defval = color.new(color.yellow, 0), inline = "TF3", title = ""), pocTF3 = input.bool(defval = false, title = "POC", inline = "TF3")  , vaTF3 = input.bool(defval = false, title = "VA", inline = "TF3"), vpTF3 = input.bool(defval = false, title = "Profile", inline = "TF3")
recentOnly = input.bool(defval = false, title = "Show Recent Range Only")

vaPercent     = input.float(defval = 70, minval = 68, maxval = 80, step = 1, title = "Value Area %", tooltip = "Percentage of TPO touches that defines the value area. Standard is 70%.", group = groupMain)
profileRows   = 200 //input.int(defval = 200, minval = 20, maxval = 200, title = "Profile Resolution", tooltip = "Number of rows in the TPO profile. Higher = more precise.", group = groupMain)
atrLen        = 14 // input.int(defval = 14, minval = 1, maxval = 100, title = "ATR Length", tooltip = "Lookback for the ATR used in the distance filter.", group = groupMain, inline = "atr")
atrMult       = input.float(defval = 1, minval = 0.0, maxval = 5.0, step = 0.1, title = "ATR Multiplier", tooltip = "Price must be at least this many ATRs beyond the VA edge to count as out of balance. 0 = no filter.", group = groupMain, inline = "atr")

var groupBalance = "Balance Confirmation"
tpoSpreadMin     = 30 //input.float(defval = 30.0, minval = 10.0, maxval = 70.0, step = 5.0, title = "Min TPO VA Spread %", tooltip = "TPO value area must span at least this % of the settle range.", group = groupBalance)
tpoSpreadMax     = 85 // input.float(defval = 85.0, minval = 50.0, maxval = 100.0, step = 5.0, title = "Max TPO VA Spread %", tooltip = "TPO value area cannot exceed this % of the range. If it does, time is too flat — no concentration.", group = groupBalance)
minProfileBars   = input.int(defval = 30, minval = 3, maxval = 100, title = "Min Profile Bars", tooltip = "Minimum bars before shape checks start running.", group = groupBalance)
maxProfileWindow = 30 //input.int(defval = 30, minval = 10, maxval = 200, title = "Profile Window (bars)", tooltip = "Rolling window size. Once OOB exceeds this many bars, the oldest bars drop off. Keeps the profile focused on recent activity.", group = groupBalance)


tablePos      = input.string(defval = "Top Right", title = "Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = "Display")

// ── Expanding TPO Profile ──
// The profile accumulates from an anchor point and only resets when price breaks out


type balanceTFstats 

    int phase 
    float vahPrice 
    float valPrice 
    float pocPrice 
    float bufferedVAH 
    float bufferedVAL 
    bool newBalanceFound
    int anchorBar
    bool isBalance
    bool showOOB
    int lastBalanceBar




// Function to compute TPO VA from current rowTPO array
calcTPOVA(rowTPO, profHigh, profLow, needsRebuild, anchorBar) =>

    _pocRow    = rowTPO.indexof(rowTPO.max())
    _pocTouch  = rowTPO.get(_pocRow)
    _totalTpo  = rowTPO.sum()

    _rowHeight = (profHigh - profLow) / profileRows
    _pocPrice  = profLow + (_pocRow + 0.5) * _rowHeight

    _vaTarget  = _totalTpo * (vaPercent / 100)
    _vaAccum   = _pocTouch
    _vaRowLow  = _pocRow
    _vaRowHigh = _pocRow

    for _step = 0 to profileRows - 1
        if _vaAccum >= _vaTarget
            break
        _canUp = _vaRowHigh < profileRows - 1
        _canDn = _vaRowLow > 0
        _upTpo = _canUp ? array.get(rowTPO, _vaRowHigh + 1) : 0.0
        _dnTpo = _canDn ? array.get(rowTPO, _vaRowLow - 1) : 0.0
        if _canUp and (not _canDn or _upTpo >= _dnTpo)
            _vaRowHigh += 1
            _vaAccum += _upTpo
        else if _canDn
            _vaRowLow -= 1
            _vaAccum += _dnTpo
        else
            break

    _vahPrice = profLow + (_vaRowHigh + 1) * _rowHeight
    _valPrice = profLow + _vaRowLow * _rowHeight

    [_vahPrice, _valPrice, _pocPrice]

// Add a single bar's TPO touches to the profile
addBarToTPOProfile(float barH, float barL, rowTPO, profHigh, profLow, needsRebuild, anchorBar) =>
    _rowHeight = (profHigh - profLow) / profileRows
    if _rowHeight > 0 and not na(barH) and not na(barL)
        _rLow  = math.max(0, math.floor((barL - profLow) / _rowHeight))
        _rHigh = math.min(profileRows - 1, math.floor((barH - profLow) / _rowHeight))
        if _rHigh < 0
            _rHigh := 0
        if _rLow > profileRows - 1
            _rLow := profileRows - 1
        if _rLow > _rHigh
            _rLow := _rHigh
        for r = _rLow to _rHigh
            array.set(rowTPO, r, array.get(rowTPO, r) + 1.0)


getPhase(tf, needsVP = false) => 
    
    var float[] rowTPO       = array.new_float(profileRows, 0.0)
    var float   profHigh     = high
    var float   profLow      = low
    var bool    needsRebuild = true
    var int     anchorBar    = time
    var tfInMS = timeframe.in_seconds(tf) * 1000
    vpArr = array.new<float>(10, 0)
    atrVal    = ta.atr(atrLen)
    atrBuffer = atrVal * atrMult

    // ── Phase State Variables ──
    var int   phase = 0
    var int   breakoutBar = 0
    var float oldBufferedVAH = 0.0
    var float oldBufferedVAL = 0.0

    rangeExpanded = (high > profHigh or low < profLow) and phase == 0

    if rangeExpanded
        profHigh := math.max(profHigh, high)
        profLow  := math.min(profLow, low)
        needsRebuild := true

    // Full rebuild: recalculate entire TPO profile from anchor

    var highArr = array.new<float>()
    var lowArr  = array.new<float>()

    highArr.unshift(high)
    lowArr .unshift(low)


    if highArr.size() > 5000
        highArr.pop()
        lowArr .pop()

    if needsRebuild

        rowTPO.fill(0)
        barsBack = (time - anchorBar) / tfInMS

        if barsBack >= 0
            maxBack = math.min(barsBack, highArr.size() - 1)
            for b = 0 to maxBack

                getHigh = highArr.get(b), getLow = lowArr.get(b)

                addBarToTPOProfile(getHigh, getLow, rowTPO, profHigh, profLow, needsRebuild, anchorBar)

        needsRebuild := false

    else if barstate.isconfirmed and phase == 0
        addBarToTPOProfile(high, low, rowTPO, profHigh, profLow, needsRebuild, anchorBar)

    // Calculate TPO VA
    [_currVAH, _currVAL, _currPOC] = calcTPOVA(rowTPO, profHigh, profLow, needsRebuild, anchorBar)

    _currBufferedVAH = _currVAH + atrBuffer
    _currBufferedVAL = _currVAL - atrBuffer

    // ── Phase Detection with Persistent Out-of-Balance ──
    // States: 0 = Balance, 1 = Out of Balance
    newBalanceFound = false
    points = array.new<chart.point>()

    liveOutside = close > _currBufferedVAH or close < _currBufferedVAL

    if phase == 0
        oldBufferedVAH := _currBufferedVAH
        oldBufferedVAL := _currBufferedVAL
        if liveOutside
            phase := 1
            breakoutBar := time

    else if phase == 1
        liveInsideOldVA = close <= oldBufferedVAH and close >= oldBufferedVAL

        if liveInsideOldVA
            barsAway = (time - breakoutBar) / tfInMS
            for b = 0 to barsAway
                if not na(high[b]) and not na(low[b])
                    profHigh := math.max(profHigh, high[b])
                    profLow  := math.min(profLow, low[b])

            needsRebuild := true
            phase := 0

        else if barstate.isconfirmed
            _barsSinceBreakout = (time - breakoutBar) / tfInMS
            _windowSize = math.min(_barsSinceBreakout, maxProfileWindow)

            if _windowSize >= minProfileBars
                _rangeHigh = high
                _rangeLow  = low
                for b = 0 to _windowSize - 1
                    if not na(high[b]) and not na(low[b])
                        _rangeHigh := math.max(_rangeHigh, high[b])
                        _rangeLow  := math.min(_rangeLow, low[b])

                _settleRows  = profileRows
                _settleRange = _rangeHigh - _rangeLow
                _sRowHeight  = _settleRange / _settleRows

                float[] _sRowTouch = array.new_float(_settleRows, 0.0)

                if _sRowHeight > 0
                    for b = 0 to _windowSize - 1
                        if not na(high[b]) and not na(low[b])
                            _srLow  = math.max(0, math.floor((low[b] - _rangeLow) / _sRowHeight))
                            _srHigh = math.min(_settleRows - 1, math.floor((high[b] - _rangeLow) / _sRowHeight))
                            if _srHigh < 0
                                _srHigh := 0
                            if _srLow > _settleRows - 1
                                _srLow := _settleRows - 1
                            if _srLow > _srHigh
                                _srLow := _srHigh
                            for r = _srLow to _srHigh
                                array.set(_sRowTouch, r, array.get(_sRowTouch, r) + 1.0)

                // ── TPO VALUE AREA ONLY ──
                _tpoPocRow     = 0
                _tpoPocTouch   = 0.0
                _tpoTotalTouch = 0.0
                for i = 0 to _settleRows - 1
                    _st = array.get(_sRowTouch, i)
                    _tpoTotalTouch += _st
                    if _st > _tpoPocTouch
                        _tpoPocTouch := _st
                        _tpoPocRow := i

                _tpoVaTarget = _tpoTotalTouch * (vaPercent / 100)
                _tpoVaAccum  = _tpoPocTouch
                _tpoVaLow    = _tpoPocRow
                _tpoVaHigh   = _tpoPocRow

                for _step = 0 to _settleRows - 1
                    if _tpoVaAccum >= _tpoVaTarget
                        break
                    _cUp = _tpoVaHigh < _settleRows - 1
                    _cDn = _tpoVaLow > 0
                    _uT  = _cUp ? array.get(_sRowTouch, _tpoVaHigh + 1) : 0.0
                    _dT  = _cDn ? array.get(_sRowTouch, _tpoVaLow - 1) : 0.0
                    if _cUp and (not _cDn or _uT >= _dT)
                        _tpoVaHigh += 1
                        _tpoVaAccum += _uT
                    else if _cDn
                        _tpoVaLow -= 1
                        _tpoVaAccum += _dT
                    else
                        break

                _tpoSpreadRows = _tpoVaHigh - _tpoVaLow + 1
                _tpoSpreadPct  = (_tpoSpreadRows / _settleRows) * 100
                _tpoSpreadOk   = _tpoSpreadPct >= tpoSpreadMin and _tpoSpreadPct <= tpoSpreadMax

                if _tpoSpreadOk 

                    newBalanceFound := true
                    phase           := 0
                    profHigh        := _rangeHigh
                    profLow         := _rangeLow
                    anchorBar       := time[math.max(_windowSize - 1, 0)]
                    needsRebuild    := true
        

    if needsRebuild
        rowTPO.fill(0)
        barsBack = (time - anchorBar) / tfInMS

        if barsBack >= 0
            maxBack = math.min(barsBack, highArr.size() - 1)
            for b = 0 to maxBack
                getHigh = highArr.get(b)
                getLow  = lowArr.get(b)
                addBarToTPOProfile(getHigh, getLow, rowTPO, profHigh, profLow, needsRebuild, anchorBar)

        needsRebuild := false

    if needsVP 
            
        for i = 0 to 9
            sum = 0.0
            startRow = i * 20
            endRow   = startRow + 20 - 1

            slice = rowTPO.slice(startRow, endRow)

            vpArr.set(i, slice.sum())


    [vahPrice, valPrice, pocPrice] = calcTPOVA(rowTPO, profHigh, profLow, needsRebuild, anchorBar)

    bufferedVAH = vahPrice + atrBuffer
    bufferedVAL = valPrice - atrBuffer
    isBalance = phase == 0
    showOOB   = phase == 1
    var int  lastBalanceBar   = time
    if isBalance
        lastBalanceBar := time

    [phase[1], vahPrice[1], valPrice[1], pocPrice[1], bufferedVAH[1], bufferedVAL[1], newBalanceFound[1], anchorBar[1], isBalance[1], showOOB[1], lastBalanceBar[1], vpArr[1], profHigh[1], profLow[1]]


[phaseTF1 ,vahPriceTF1 ,valPriceTF1, pocPriceTF1, bufferedVAHTF1, bufferedVALTF1, newBalanceFoundTF1, anchorBarTF1, isBalanceTF1, showOOBTF1, lastBalanceBarTF1, pointsTF1, profHighTF1, profLowTF1]  = request.security("", TF1, getPhase(TF1, true), lookahead = barmerge.lookahead_on)
[phaseTF2, vahPriceTF2, valPriceTF2, pocPriceTF2, bufferedVAHTF2, bufferedVALTF2, newBalanceFoundTF2, anchorBarTF2, isBalanceTF2, showOOBTF2, lastBalanceBarTF2, pointsTF2, profHighTF2, profLowTF2]  = request.security("", TF2, getPhase(TF2, true), lookahead = barmerge.lookahead_on)
[phaseTF3 ,vahPriceTF3 ,valPriceTF3, pocPriceTF3, bufferedVAHTF3, bufferedVALTF3, newBalanceFoundTF3, anchorBarTF3, isBalanceTF3, showOOBTF3, lastBalanceBarTF3, pointsTF3, profHighTF3, profLowTF3]  = request.security("", TF3, getPhase(TF3, true), lookahead = barmerge.lookahead_on)


// Static lines
// 
// drawBalance(phase ,vahPrice ,valPrice, pocPrice, bufferedVAH, bufferedVAL, anchorBar, newBalanceFound, isBalance, showOOB, lastBalanceBar)  =>

//     var line staticVAHline    = na
//     var line staticVALline    = na
//     var line staticPOCline    = na
//     var line staticBufVAHline = na
//     var line staticBufVALline = na
// // 
//     if showLines and staticLines
//         if newBalanceFound and (na(staticVAHline) or staticVAHline.get_x1() != anchorBar)

//             staticVAHline    := line.new(anchorBar, vahPrice, time, vahPrice, color = vahCol, width = 1, xloc = xloc.bar_time)
//             staticVALline    := line.new(anchorBar, valPrice, time, valPrice, color = valCol, width = 1, xloc = xloc.bar_time)
//             staticPOCline    := line.new(anchorBar, pocPrice, time, pocPrice, color = pocCol, width = 1, xloc = xloc.bar_time)
//             staticBufVAHline := line.new(anchorBar, bufferedVAH, time, bufferedVAH, color = bufferCol, width = 1, style = line.style_dotted, xloc = xloc.bar_time)
//             staticBufVALline := line.new(anchorBar, bufferedVAL, time, bufferedVAL, color = bufferCol, width = 1, style = line.style_dotted, xloc = xloc.bar_time)

//             // label.new(bar_index, vahPrice, text = str.tostring())

//         if isBalance and not na(staticVAHline) and not newBalanceFound
//             line.set_x1(staticVAHline, anchorBar)
//             line.set_x2(staticVAHline, time)
//             line.set_y1(staticVAHline, vahPrice)
//             line.set_y2(staticVAHline, vahPrice)

//             line.set_x1(staticVALline, anchorBar)
//             line.set_x2(staticVALline, time)
//             line.set_y1(staticVALline, valPrice)
//             line.set_y2(staticVALline, valPrice)

//             line.set_x1(staticPOCline, anchorBar)
//             line.set_x2(staticPOCline, time)
//             line.set_y1(staticPOCline, pocPrice)
//             line.set_y2(staticPOCline, pocPrice)

//             line.set_x1(staticBufVAHline, anchorBar)
//             line.set_x2(staticBufVAHline, time)
//             line.set_y1(staticBufVAHline, bufferedVAH)
//             line.set_y2(staticBufVAHline, bufferedVAH)

//             line.set_x1(staticBufVALline, anchorBar)
//             line.set_x2(staticBufVALline, time)
//             line.set_y1(staticBufVALline, bufferedVAL)
//             line.set_y2(staticBufVALline, bufferedVAL)
// // 

drawBalance(phase ,vahPrice ,valPrice, pocPrice, bufferedVAH, bufferedVAL, anchorBar, newBalanceFound, isBalance, showOOB, lastBalanceBar, boxCol, showPOC, showVA, showVP, points, profHigh, profLow)  =>

    var boxRange = box(na)

    var line staticVAHline    = na
    var line staticVALline    = na
    var line staticPOCline    = na
    var linefill vaFill       = na

    var polyline polySession = na
    var vpBoxes = array.new<box>(10)
    var boxPoly = array.from(chart.point.from_time(anchorBar, bufferedVAH), chart.point.from_time(time, bufferedVAH), chart.point.from_time(time, bufferedVAL), chart.point.from_time(anchorBar, bufferedVAL))


    // var line staticBufVAHline = na
    // var line staticBufVALline = na
// 
    if newBalanceFound 
        
        if not showVP and (na(boxRange) or boxRange.get_left() != anchorBar) 
         or showVP and (na(polySession) or boxPoly.first().time != anchorBar)

            if recentOnly 
                staticPOCline.delete()
                boxRange     .delete()
                staticVAHline.delete()
                staticVALline.delete()
                vaFill       .delete()

            if showVA
                staticVAHline    := line.new(anchorBar, vahPrice, time, vahPrice, width = 1, xloc = xloc.bar_time, color = color.new(boxCol, 25), style = line.style_dashed)
                staticVALline    := line.new(anchorBar, valPrice, time, valPrice, width = 1, xloc = xloc.bar_time, color = color.new(boxCol, 25), style = line.style_dashed)
                vaFill           := linefill.new(staticVAHline, staticVALline, color.new(boxCol, 95))
            if showPOC
                staticPOCline    := line.new(anchorBar, pocPrice, time, pocPrice, color = color.new(boxCol, 25), width = 2, xloc = xloc.bar_time)
            // staticBufVAHline := line.new(anchorBar, bufferedVAH, time, bufferedVAH, color = bufferCol, width = 1, style = line.style_dotted, xloc = xloc.bar_time)
            // staticBufVALline := line.new(anchorBar, bufferedVAL, time, bufferedVAL, color = bufferCol, width = 1, style = line.style_dotted, xloc = xloc.bar_time)

            if showVP
                boxPoly := array.from(chart.point.from_time(anchorBar, bufferedVAH), chart.point.from_time(time, bufferedVAH), chart.point.from_time(time, bufferedVAL), chart.point.from_time(anchorBar, bufferedVAL))
                polySession := polyline.new(boxPoly, xloc = xloc.bar_time, closed = true, line_style = line.style_dotted, fill_color = color.new(boxCol, showVA ? 100 : 99), line_color = boxCol)
                
            else

                boxRange    := box.new(anchorBar, bufferedVAH, time, bufferedVAL, bgcolor = color.new(boxCol, showVA ? 100 : 99 ), border_color = boxCol, border_style = line.style_dotted, xloc = xloc.bar_time)

            // label.new(bar_index, vahPrice, text = str.tostring())


            if showVP and points.size() > 0 and anchorBar != nz(vpBoxes.first().get_left())

                max = points.max(), min = points.min(), Range = max - min 

                rangeProf = (profHigh - profLow) / 10

                for i = 0 to 9 

                    sumAtLevel = points.get(i)

                    norm  = math.round(1 + ((sumAtLevel - min) * 10) / Range)
                    getText = "█"

                    if norm > 1 
                        for x = 0 to math.min(norm - 1, 9)
                            getText += "█"

                    if str.length(getText) < 10 

                        for x = str.length(getText) to 10 
                            getText += " "

                    else if str.length(getText) == 10 

                        getText += " "
                        

                    col = color.new(color.from_gradient(norm, 5, 10, color.gray, boxCol), 50)

                    vpBoxes.set(i, box.new(anchorBar, profLow + (rangeProf * i), time, profLow + rangeProf * (i + 1), xloc = xloc.bar_time, bgcolor = #00000000, border_color = #00000000, text = getText, text_color = col, text_halign = text.align_left))


    if isBalance and not newBalanceFound

        if not showVP and not na(boxRange) or showVP and not na(polySession)


            boxRange.set_lefttop(anchorBar, bufferedVAH)
            boxRange.set_rightbottom(time, bufferedVAL)
            line.set_xy1(staticPOCline, anchorBar, pocPrice)
            line.set_xy2(staticPOCline, time, pocPrice)

            line.set_xy1(staticVAHline, anchorBar, vahPrice)
            line.set_xy2(staticVAHline, time, vahPrice)
    
            line.set_xy1(staticVALline, anchorBar, valPrice)
            line.set_xy2(staticVALline, time, valPrice)
            
            if showVP

                polySession.delete()
                boxPoly := array.from(chart.point.from_time(anchorBar, bufferedVAH), chart.point.from_time(time, bufferedVAH), chart.point.from_time(time, bufferedVAL), chart.point.from_time(anchorBar, bufferedVAL))
                polySession := polyline.new(boxPoly, xloc = xloc.bar_time, closed = true, line_style = line.style_dotted, fill_color = color.new(boxCol, showVA ? 100 : 99), line_color = boxCol)

                if points.size() > 0 

                    max = points.max(), min = points.min(), Range = max - min 

                    rangeProf = (profHigh - profLow) / 10

                    for i = 0 to 9 

                        sumAtLevel = points.get(i)

                        norm  = math.round(1 + ((sumAtLevel - min) * 10) / Range)
                        getText = "█"

                        if norm > 1 
                            for x = 0 to math.min(norm - 1, 9)
                                getText += "█"

                        if str.length(getText) < 10 

                            for x = str.length(getText) to 10 
                                getText += " "

                        else if str.length(getText) == 10 

                            getText += " "
                            
                        col = color.new(color.from_gradient(norm, 5, 10, color.gray, boxCol), 50)

                        getBox = vpBoxes.get(i)
                        getBox.set_lefttop(anchorBar, profLow + (rangeProf * i))
                        getBox.set_rightbottom(time, profLow + rangeProf * (i + 1))
                        getBox.set_text(getText)
                        getBox.set_text_color(col)
                

    //             line.set_x1(staticBufVAHline, anchorBar)
    //             line.set_x2(staticBufVAHline, time)
    //             line.set_y1(staticBufVAHline, bufferedVAH)
    //             line.set_y2(staticBufVAHline, bufferedVAH)

    //             line.set_x1(staticBufVALline, anchorBar)
    //             line.set_x2(staticBufVALline, time)
    //             line.set_y1(staticBufVALline, bufferedVAL)
    //             line.set_y2(staticBufVALline, bufferedVAL)
    // // 

    if barstate.islast
        boxRange.set_lefttop(anchorBar, bufferedVAH)
        boxRange.set_rightbottom(time("", -1), bufferedVAL)
        line.set_xy1(staticPOCline, anchorBar, pocPrice)
        line.set_xy2(staticPOCline, time("", -1), pocPrice)

        line.set_xy1(staticVAHline, anchorBar, vahPrice)
        line.set_xy2(staticVAHline, time("", -1), vahPrice)
  
        line.set_xy1(staticVALline, anchorBar, valPrice)
        line.set_xy2(staticVALline, time("", -1), valPrice)

        if showVP
                
            polySession.delete()
            boxPoly := array.from(chart.point.from_time(anchorBar, bufferedVAH), chart.point.from_time(time, bufferedVAH), chart.point.from_time(time, bufferedVAL), chart.point.from_time(anchorBar, bufferedVAL))
            polySession := polyline.new(boxPoly, xloc = xloc.bar_time, closed = true, line_style = line.style_dotted, fill_color = color.new(boxCol, showVA ? 100 : 99), line_color = boxCol)

            if points.size() > 0 

                max = points.max(), min = points.min(), Range = max - min 

                rangeProf = (profHigh - profLow) / 10

                for i = 0 to 9 

                    sumAtLevel = points.get(i)

                    norm  = math.round(1 + ((sumAtLevel - min) * 10) / Range)
                    getText = "█"

                    if norm > 1 
                        for x = 0 to math.min(norm - 1, 9)
                            getText += "█"

                    if str.length(getText) < 10 

                        for x = str.length(getText) to 10 
                            getText += " "

                    else if str.length(getText) == 10 

                        getText += " "
                        
                    col = color.new(color.from_gradient(norm, 5, 10, color.gray, boxCol), 50)

                    getBox = vpBoxes.get(i)
                    getBox.set_lefttop(anchorBar, profLow + (rangeProf * i))
                    getBox.set_rightbottom(time, profLow + rangeProf * (i + 1))
                    getBox.set_text(getText)
                    getBox.set_text_color(col)
            
                    // vpBoxes.set(i, box.new(anchorBar, profLow + (rangeProf * i), time, profLow + rangeProf * (i + 1), xloc = xloc.bar_time, bgcolor = #00000000, border_color = #00000000, text = getText, text_color = col, text_halign = text.align_left))


drawBalance(phaseTF1 ,vahPriceTF1 ,valPriceTF1, pocPriceTF1, bufferedVAHTF1, bufferedVALTF1, anchorBarTF1, newBalanceFoundTF1, isBalanceTF1, showOOBTF1, lastBalanceBarTF1, colTF1, pocTF1, vaTF1, vpTF1, pointsTF1, profHighTF1, profLowTF1)
drawBalance(phaseTF2 ,vahPriceTF2 ,valPriceTF2, pocPriceTF2, bufferedVAHTF2, bufferedVALTF2, anchorBarTF2, newBalanceFoundTF2, isBalanceTF2, showOOBTF2, lastBalanceBarTF2, colTF2, pocTF2, vaTF2, vpTF2, pointsTF2, profHighTF2, profLowTF2)
drawBalance(phaseTF3 ,vahPriceTF3 ,valPriceTF3, pocPriceTF3, bufferedVAHTF3, bufferedVALTF3, anchorBarTF3, newBalanceFoundTF3, isBalanceTF3, showOOBTF3, lastBalanceBarTF3, colTF3, pocTF3, vaTF3, vpTF3, pointsTF3, profHighTF3, profLowTF3)

// // bgCol = newBalanceFound ? newBalCol : showOOB ? outCol : balanceCol
// // bgcolor(showBg ? bgCol : na, title = "Phase Background")

// // ── Table ──
tblPos = switch tablePos
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    =>                position.bottom_right

// [phaseTF5, vahPriceTF5, valPriceTF5, pocPriceTF5, bufferedVAHTF5, bufferedVALTF5, newBalanceFoundTF5, anchorBarTF5, isBalanceTF5, showOOBTF5, lastBalanceBarTF5] = request.security("", "5"  , getPhase("5")  )
// [phaseTF30, vahPriceTF30, valPriceTF30, pocPriceTF30, bufferedVAHTF30, bufferedVALTF30, newBalanceFoundTF30, anchorBarTF30, isBalanceTF30, showOOBTF30, lastBalanceBarTF30] = request.security("", "30" , getPhase("30") )
// [phaseTF60, vahPriceTF60, valPriceTF60, pocPriceTF60, bufferedVAHTF60, bufferedVALTF60, newBalanceFoundTF60, anchorBarTF60, isBalanceTF60, showOOBTF60, lastBalanceBarTF60] = request.security("", "60" , getPhase("60") )
[phaseTF240, vahPriceTF240, valPriceTF240, pocPriceTF240, bufferedVAHTF240, bufferedVALTF240, newBalanceFoundTF240, anchorBarTF240, isBalanceTF240, showOOBTF240, lastBalanceBarTF240] = request.security("", "240", getPhase("240"))
[phaseTF1D, vahPriceTF1D, valPriceTF1D, pocPriceTF1D, bufferedVAHTF1D, bufferedVALTF1D, newBalanceFoundTF1D, anchorBarTF1D, isBalanceTF1D, showOOBTF1D, lastBalanceBarTF1D] = request.security("", "1D" , getPhase("1D") )
[phaseTF1W, vahPriceTF1W, valPriceTF1W, pocPriceTF1W, bufferedVAHTF1W, bufferedVALTF1W, newBalanceFoundTF1W, anchorBarTF1W, isBalanceTF1W, showOOBTF1W, lastBalanceBarTF1W] = request.security("", "1W" , getPhase("1W") )

isBalanceArr = array.from(isBalanceTF240, isBalanceTF1D, isBalanceTF1W)
vahArr = array.from(bufferedVAHTF240, bufferedVAHTF1D, bufferedVAHTF1W)
valArr = array.from(bufferedVALTF240, bufferedVALTF1D, bufferedVALTF1W)
var tfArr = array.from("4H:", "1D:", "1W:")

if barstate.islast
    var tblCol = #181b27

    var tbl = table.new(tblPos, 99, 99,
         bgcolor      = #20222C,
         border_color = #363843,
         frame_color  = #363843,
         border_width = 1,
         frame_width  = 1)

    tbl.cell(0, 0, text = "AMT Phase",
        text_color = color.white,
        text_size  = size.small,
        bgcolor    = tblCol)
    tbl.cell(1, 0, text = "",
            bgcolor = tblCol)
    tbl.merge_cells(0, 0, 1, 0)

    for [i, data] in isBalanceArr 

        isBalance = data
        
        phaseText  = isBalance ? "BALANCE" : "OUT OF BALANCE"
        phaseColor = isBalance ? #5b9cf6 : #ff9800

        dirText = ""

        if not isBalance
            aboveVA = close > vahArr.get(i)
            belowVA = close < valArr.get(i)
            dirText := aboveVA ? " ▲" : belowVA ? " ▼" : ""


        tbl.cell(0, i + 1, text = tfArr.get(i),
            text_color = color.white,
            text_size  = size.small,
            bgcolor    = tblCol)
        tbl.cell(1, i + 1, text = phaseText + dirText,
            text_color = phaseColor,
            text_size  = size.small,
            bgcolor    = tblCol)
````

# ATH & 52W high with 8 MAs

- url: https://www.tradingview.com/script/XLKQ67S3-ATH-52W-high-with-8-MAs/
- type: indicator
- pine_id: PUB;c508de502ceb4708a90ad50936875648
- version: 2.0

## Description

Tracks all time highs and 52w high along with 8 highly customisable moving averages , default setting are suitable for stock markets and can be curated anyhow within limits at your own discretion

## Source Code

````pine
//@version=6
indicator("ATH + 52W + 8 MA Backbone", overlay=true, max_lines_count=4, max_labels_count=20, max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH CORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
engineTF      = input.timeframe("D", "High Engine TF", group="High Core")
lookback52    = input.int(252, "52W Window Bars", minval=50, maxval=1000, group="High Core")
firstGateBars = input.int(1, "First Gate Bars", minval=1, maxval=30, group="High Core")
closeGateBars = input.int(20, "Close Gate Bars", minval=1, maxval=250, group="High Core")
mergePct      = input.float(0.10, "Merge ATH/52W Within %", minval=0.0, maxval=5.0, step=0.05, group="High Core")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showATH    = input.bool(true, "Show ATH", group="High Display")
show52W    = input.bool(true, "Show 52W", group="High Display")
showHLabels = input.bool(true, "Show High Labels", group="High Display")
highShowOn = input.string("Daily+Weekly+Monthly", "Show Highs On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="High Display")

anchorMode = input.string("Auto", "Origin Anchor", options=["Auto", "Exact", "Snap to Chart"], group="High Display")
rightDays  = input.int(10, "Right Label Buffer Days", minval=0, maxval=365, group="High Display")

athColorBase = input.color(color.black, "ATH Color", group="ATH Style")
athTransp    = input.int(0, "ATH Transparency", minval=0, maxval=100, group="ATH Style")
athWidth     = input.int(2, "ATH Width", minval=1, maxval=5, group="ATH Style")
athLabelMode = input.string("Name Price", "ATH Label Mode", options=["Name", "Price", "Name Price", "Name Distance", "Name Price Distance"], group="ATH Style")
athTextColor = input.color(color.black, "ATH Text Color", group="ATH Style")
athAtrOffset = input.float(0.35, "ATH Label ATR Offset", minval=-5.0, maxval=5.0, step=0.05, group="ATH Style")

h52ColorBase = input.color(color.gray, "52W Color", group="52W Style")
h52Transp    = input.int(0, "52W Transparency", minval=0, maxval=100, group="52W Style")
h52Width     = input.int(2, "52W Width", minval=1, maxval=5, group="52W Style")
h52LabelMode = input.string("Name Price", "52W Label Mode", options=["Name", "Price", "Name Price", "Name Distance", "Name Price Distance"], group="52W Style")
h52TextColor = input.color(color.gray, "52W Text Color", group="52W Style")
h52AtrOffset = input.float(-0.35, "52W Label ATR Offset", minval=-5.0, maxval=5.0, step=0.05, group="52W Style")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA GLOBAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
maLabelRightDays = input.int(10, "MA Label Right Buffer Days", minval=0, maxval=365, group="MA Global")
showMALabelsGlobal = input.bool(false, "Show MA Labels Globally", group="MA Global")
maLabelModeGlobal = input.string("Name", "MA Label Mode", options=["Name", "Value", "Name Value"], group="MA Global")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 1: 5
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma1Show   = input.bool(true, "Show", group="MA 1 - 5")
ma1Len    = input.int(5, "Length", minval=1, group="MA 1 - 5")
ma1Type   = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 1 - 5")
ma1Src    = input.source(close, "Source", group="MA 1 - 5")
ma1TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 1 - 5")
ma1Custom = input.timeframe("D", "Custom TF", group="MA 1 - 5")
ma1Vis    = input.string("Daily", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 1 - 5")
ma1Color  = input.color(color.black, "Color", group="MA 1 - 5")
ma1Transp = input.int(80, "Transparency", minval=0, maxval=100, group="MA 1 - 5")
ma1Width  = input.int(1, "Width", minval=1, maxval=5, group="MA 1 - 5")
ma1Label  = input.bool(false, "Label", group="MA 1 - 5")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 2: 10
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma2Show   = input.bool(true, "Show", group="MA 2 - 10")
ma2Len    = input.int(10, "Length", minval=1, group="MA 2 - 10")
ma2Type   = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 2 - 10")
ma2Src    = input.source(close, "Source", group="MA 2 - 10")
ma2TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 2 - 10")
ma2Custom = input.timeframe("D", "Custom TF", group="MA 2 - 10")
ma2Vis    = input.string("Daily", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 2 - 10")
ma2Color  = input.color(color.black, "Color", group="MA 2 - 10")
ma2Transp = input.int(70, "Transparency", minval=0, maxval=100, group="MA 2 - 10")
ma2Width  = input.int(1, "Width", minval=1, maxval=5, group="MA 2 - 10")
ma2Label  = input.bool(false, "Label", group="MA 2 - 10")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 3: 22
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma3Show   = input.bool(true, "Show", group="MA 3 - 22")
ma3Len    = input.int(22, "Length", minval=1, group="MA 3 - 22")
ma3Type   = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 3 - 22")
ma3Src    = input.source(close, "Source", group="MA 3 - 22")
ma3TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 3 - 22")
ma3Custom = input.timeframe("D", "Custom TF", group="MA 3 - 22")
ma3Vis    = input.string("Daily", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 3 - 22")
ma3Color  = input.color(color.yellow, "Color", group="MA 3 - 22")
ma3Transp = input.int(0, "Transparency", minval=0, maxval=100, group="MA 3 - 22")
ma3Width  = input.int(1, "Width", minval=1, maxval=5, group="MA 3 - 22")
ma3Label  = input.bool(false, "Label", group="MA 3 - 22")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 4: 50
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma4Show   = input.bool(true, "Show", group="MA 4 - 50")
ma4Len    = input.int(50, "Length", minval=1, group="MA 4 - 50")
ma4Type   = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 4 - 50")
ma4Src    = input.source(close, "Source", group="MA 4 - 50")
ma4TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 4 - 50")
ma4Custom = input.timeframe("D", "Custom TF", group="MA 4 - 50")
ma4Vis    = input.string("Daily+Weekly", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 4 - 50")
ma4Color  = input.color(color.orange, "Color", group="MA 4 - 50")
ma4Transp = input.int(0, "Transparency", minval=0, maxval=100, group="MA 4 - 50")
ma4Width  = input.int(1, "Width", minval=1, maxval=5, group="MA 4 - 50")
ma4Label  = input.bool(false, "Label", group="MA 4 - 50")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 5: 65
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma5Show   = input.bool(true, "Show", group="MA 5 - 65")
ma5Len    = input.int(65, "Length", minval=1, group="MA 5 - 65")
ma5Type   = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 5 - 65")
ma5Src    = input.source(close, "Source", group="MA 5 - 65")
ma5TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 5 - 65")
ma5Custom = input.timeframe("D", "Custom TF", group="MA 5 - 65")
ma5Vis    = input.string("Daily+Weekly", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 5 - 65")
ma5Color  = input.color(color.blue, "Color", group="MA 5 - 65")
ma5Transp = input.int(0, "Transparency", minval=0, maxval=100, group="MA 5 - 65")
ma5Width  = input.int(1, "Width", minval=1, maxval=5, group="MA 5 - 65")
ma5Label  = input.bool(false, "Label", group="MA 5 - 65")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 6: 130
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma6Show   = input.bool(true, "Show", group="MA 6 - 130")
ma6Len    = input.int(130, "Length", minval=1, group="MA 6 - 130")
ma6Type   = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 6 - 130")
ma6Src    = input.source(close, "Source", group="MA 6 - 130")
ma6TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 6 - 130")
ma6Custom = input.timeframe("D", "Custom TF", group="MA 6 - 130")
ma6Vis    = input.string("Daily+Weekly+Monthly", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 6 - 130")
ma6Color  = input.color(color.purple, "Color", group="MA 6 - 130")
ma6Transp = input.int(0, "Transparency", minval=0, maxval=100, group="MA 6 - 130")
ma6Width  = input.int(1, "Width", minval=1, maxval=5, group="MA 6 - 130")
ma6Label  = input.bool(false, "Label", group="MA 6 - 130")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 7: 200
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma7Show   = input.bool(true, "Show", group="MA 7 - 200")
ma7Len    = input.int(200, "Length", minval=1, group="MA 7 - 200")
ma7Type   = input.string("SMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 7 - 200")
ma7Src    = input.source(close, "Source", group="MA 7 - 200")
ma7TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 7 - 200")
ma7Custom = input.timeframe("D", "Custom TF", group="MA 7 - 200")
ma7Vis    = input.string("Daily+Weekly+Monthly", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 7 - 200")
ma7Color  = input.color(color.black, "Color", group="MA 7 - 200")
ma7Transp = input.int(0, "Transparency", minval=0, maxval=100, group="MA 7 - 200")
ma7Width  = input.int(2, "Width", minval=1, maxval=5, group="MA 7 - 200")
ma7Label  = input.bool(true, "Label", group="MA 7 - 200")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA 8: 260
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma8Show   = input.bool(false, "Show", group="MA 8 - 260")
ma8Len    = input.int(260, "Length", minval=1, group="MA 8 - 260")
ma8Type   = input.string("SMA", "Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "VWMA"], group="MA 8 - 260")
ma8Src    = input.source(close, "Source", group="MA 8 - 260")
ma8TFMode = input.string("Chart", "Calc TF", options=["Chart", "D", "W", "M", "Custom"], group="MA 8 - 260")
ma8Custom = input.timeframe("D", "Custom TF", group="MA 8 - 260")
ma8Vis    = input.string("Weekly+Monthly", "Visible On", options=["All", "Intraday", "Daily", "Weekly", "Monthly", "Daily+Weekly", "Weekly+Monthly", "Daily+Weekly+Monthly", "None"], group="MA 8 - 260")
ma8Color  = input.color(color.black, "Color", group="MA 8 - 260")
ma8Transp = input.int(35, "Transparency", minval=0, maxval=100, group="MA 8 - 260")
ma8Width  = input.int(2, "Width", minval=1, maxval=5, group="MA 8 - 260")
ma8Label  = input.bool(false, "Label", group="MA 8 - 260")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DAY = 86400000

f_visible_on(mode) =>
    bool out = false
    if mode == "All"
        out := true
    else if mode == "Intraday"
        out := timeframe.isintraday
    else if mode == "Daily"
        out := timeframe.isdaily
    else if mode == "Weekly"
        out := timeframe.isweekly
    else if mode == "Monthly"
        out := timeframe.ismonthly
    else if mode == "Daily+Weekly"
        out := timeframe.isdaily or timeframe.isweekly
    else if mode == "Weekly+Monthly"
        out := timeframe.isweekly or timeframe.ismonthly
    else if mode == "Daily+Weekly+Monthly"
        out := timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
    else
        out := false
    out

f_tf(mode, customTf) =>
    mode == "Chart" ? timeframe.period : mode == "Custom" ? customTf : mode

f_ma(src, len, maType) =>
    float out = na
    if maType == "SMA"
        out := ta.sma(src, len)
    else if maType == "EMA"
        out := ta.ema(src, len)
    else if maType == "WMA"
        out := ta.wma(src, len)
    else if maType == "RMA"
        out := ta.rma(src, len)
    else if maType == "HMA"
        out := ta.hma(src, len)
    else
        out := ta.vwma(src, len)
    out

f_near(a, b) =>
    not na(a) and not na(b) and a != 0.0 and math.abs(a - b) / a * 100.0 <= mergePct

f_high_text(name, price, mode) =>
    float dist = price != 0.0 ? ((close - price) / price) * 100.0 : na
    string d = na(dist) ? "" : (dist >= 0 ? "+" : "") + str.tostring(dist, "#.00") + "%"
    string p = str.tostring(price, format.mintick)
    string out = ""
    if mode == "Name"
        out := name
    else if mode == "Price"
        out := p
    else if mode == "Name Price"
        out := name + " " + p
    else if mode == "Name Distance"
        out := name + " " + d
    else
        out := name + " " + p + " " + d
    out

f_ma_text(name, value) =>
    string v = str.tostring(value, format.mintick)
    string out = ""
    if maLabelModeGlobal == "Name"
        out := name
    else if maLabelModeGlobal == "Value"
        out := v
    else
        out := name + " " + v
    out

f_snap_time(t) =>
    bool useSnap = anchorMode == "Snap to Chart" or (anchorMode == "Auto" and (timeframe.isweekly or timeframe.ismonthly))
    int out = t
    bool found = false
    if useSnap and not na(t)
        for i = 0 to 5000
            if not found and i <= bar_index and not na(time[i]) and not na(time_close[i])
                if time[i] <= t and t < time_close[i]
                    out := time[i]
                    found := true
    useSnap ? out : t

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VALID HIGH CONDITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_valid_high(totalBars, firstBars) =>
    float lvl = high[totalBars]
    int srcTime = time[totalBars]
    int srcBar = bar_index - totalBars
    bool ok = not na(lvl)

    if ok
        for k = 1 to totalBars
            int off = totalBars - k
            if k <= firstBars
                if high[off] > lvl or close[off] > lvl
                    ok := false
            else
                if close[off] > lvl
                    ok := false

    [ok, lvl, srcTime, srcBar]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_high_engine() =>
    int totalBars = firstGateBars + closeGateBars

    [ok, vNow, tNow, bNow] = f_valid_high(totalBars, firstGateBars)

    float validPrice = ok ? vNow : na
    int validTime = ok ? tNow : na
    int validBar = ok ? bNow : na

    var float ath = na
    var int athTime = na
    var int athBar = na

    if ok and (na(ath) or vNow > ath)
        ath := vNow
        athTime := tNow
        athBar := bNow

    float h52 = na
    int h52Time = na
    int h52Bar = na

    for i = 0 to 1500
        if i <= bar_index and i <= lookback52 + totalBars + 5
            float pv = validPrice[i]
            int pt = validTime[i]
            int pb = validBar[i]

            bool insideWindow = not na(pb) and bar_index - pb <= lookback52

            if insideWindow and not na(pv)
                if na(h52) or pv > h52
                    h52 := pv
                    h52Time := pt
                    h52Bar := pb

    [ath, athTime, athBar, h52, h52Time, h52Bar]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUEST HIGHS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[ath, athTime, athBar, h52, h52Time, h52Bar] = request.security(syminfo.tickerid, engineTF, f_high_engine(), barmerge.gaps_off, barmerge.lookahead_off)
atrUse = request.security(syminfo.tickerid, engineTF, ta.atr(14), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REQUEST MAs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ma1TF = f_tf(ma1TFMode, ma1Custom)
ma2TF = f_tf(ma2TFMode, ma2Custom)
ma3TF = f_tf(ma3TFMode, ma3Custom)
ma4TF = f_tf(ma4TFMode, ma4Custom)
ma5TF = f_tf(ma5TFMode, ma5Custom)
ma6TF = f_tf(ma6TFMode, ma6Custom)
ma7TF = f_tf(ma7TFMode, ma7Custom)
ma8TF = f_tf(ma8TFMode, ma8Custom)

ma1 = request.security(syminfo.tickerid, ma1TF, f_ma(ma1Src, ma1Len, ma1Type), barmerge.gaps_off, barmerge.lookahead_off)
ma2 = request.security(syminfo.tickerid, ma2TF, f_ma(ma2Src, ma2Len, ma2Type), barmerge.gaps_off, barmerge.lookahead_off)
ma3 = request.security(syminfo.tickerid, ma3TF, f_ma(ma3Src, ma3Len, ma3Type), barmerge.gaps_off, barmerge.lookahead_off)
ma4 = request.security(syminfo.tickerid, ma4TF, f_ma(ma4Src, ma4Len, ma4Type), barmerge.gaps_off, barmerge.lookahead_off)
ma5 = request.security(syminfo.tickerid, ma5TF, f_ma(ma5Src, ma5Len, ma5Type), barmerge.gaps_off, barmerge.lookahead_off)
ma6 = request.security(syminfo.tickerid, ma6TF, f_ma(ma6Src, ma6Len, ma6Type), barmerge.gaps_off, barmerge.lookahead_off)
ma7 = request.security(syminfo.tickerid, ma7TF, f_ma(ma7Src, ma7Len, ma7Type), barmerge.gaps_off, barmerge.lookahead_off)
ma8 = request.security(syminfo.tickerid, ma8TF, f_ma(ma8Src, ma8Len, ma8Type), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISIBILITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
highVisible = f_visible_on(highShowOn)

ma1Visible = ma1Show and f_visible_on(ma1Vis)
ma2Visible = ma2Show and f_visible_on(ma2Vis)
ma3Visible = ma3Show and f_visible_on(ma3Vis)
ma4Visible = ma4Show and f_visible_on(ma4Vis)
ma5Visible = ma5Show and f_visible_on(ma5Vis)
ma6Visible = ma6Show and f_visible_on(ma6Vis)
ma7Visible = ma7Show and f_visible_on(ma7Vis)
ma8Visible = ma8Show and f_visible_on(ma8Vis)

sameATH52 = f_near(ath, h52)

drawATH = highVisible and showATH and not na(ath)
draw52 = highVisible and show52W and not na(h52) and (not sameATH52 or not showATH)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(ma1Visible ? ma1 : na, title="MA 1", color=color.new(ma1Color, ma1Transp), linewidth=ma1Width)
plot(ma2Visible ? ma2 : na, title="MA 2", color=color.new(ma2Color, ma2Transp), linewidth=ma2Width)
plot(ma3Visible ? ma3 : na, title="MA 3", color=color.new(ma3Color, ma3Transp), linewidth=ma3Width)
plot(ma4Visible ? ma4 : na, title="MA 4", color=color.new(ma4Color, ma4Transp), linewidth=ma4Width)
plot(ma5Visible ? ma5 : na, title="MA 5", color=color.new(ma5Color, ma5Transp), linewidth=ma5Width)
plot(ma6Visible ? ma6 : na, title="MA 6", color=color.new(ma6Color, ma6Transp), linewidth=ma6Width)
plot(ma7Visible ? ma7 : na, title="MA 7", color=color.new(ma7Color, ma7Transp), linewidth=ma7Width)
plot(ma8Visible ? ma8 : na, title="MA 8", color=color.new(ma8Color, ma8Transp), linewidth=ma8Width)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH LINES + LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line lATH = na
var line l52 = na

var label labATH = na
var label lab52 = na

var label labMA1 = na
var label labMA2 = na
var label labMA3 = na
var label labMA4 = na
var label labMA5 = na
var label labMA6 = na
var label labMA7 = na
var label labMA8 = na

if barstate.islast
    if not na(lATH)
        line.delete(lATH)
    if not na(l52)
        line.delete(l52)

    if not na(labATH)
        label.delete(labATH)
    if not na(lab52)
        label.delete(lab52)

    if not na(labMA1)
        label.delete(labMA1)
    if not na(labMA2)
        label.delete(labMA2)
    if not na(labMA3)
        label.delete(labMA3)
    if not na(labMA4)
        label.delete(labMA4)
    if not na(labMA5)
        label.delete(labMA5)
    if not na(labMA6)
        label.delete(labMA6)
    if not na(labMA7)
        label.delete(labMA7)
    if not na(labMA8)
        label.delete(labMA8)

    int highRightX = time + rightDays * DAY
    int maRightX = time + maLabelRightDays * DAY

    if drawATH
        int xATH = f_snap_time(athTime)
        float yATHLabel = ath + nz(atrUse, ta.atr(14)) * athAtrOffset
        lATH := line.new(x1=xATH, y1=ath, x2=highRightX, y2=ath, xloc=xloc.bar_time, extend=extend.right, color=color.new(athColorBase, athTransp), width=athWidth)
        if showHLabels
            labATH := label.new(x=highRightX, y=yATHLabel, text=f_high_text("ATH", ath, athLabelMode), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=athTextColor, size=size.small)

    if draw52
        int x52 = f_snap_time(h52Time)
        float y52Label = h52 + nz(atrUse, ta.atr(14)) * h52AtrOffset
        l52 := line.new(x1=x52, y1=h52, x2=highRightX, y2=h52, xloc=xloc.bar_time, extend=extend.right, color=color.new(h52ColorBase, h52Transp), width=h52Width)
        if showHLabels
            lab52 := label.new(x=highRightX, y=y52Label, text=f_high_text("52W", h52, h52LabelMode), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=h52TextColor, size=size.small)

    if showMALabelsGlobal and ma1Visible and ma1Label and not na(ma1)
        labMA1 := label.new(x=maRightX, y=ma1, text=f_ma_text("5", ma1), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma1Color, size=size.small)
    if showMALabelsGlobal and ma2Visible and ma2Label and not na(ma2)
        labMA2 := label.new(x=maRightX, y=ma2, text=f_ma_text("10", ma2), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma2Color, size=size.small)
    if showMALabelsGlobal and ma3Visible and ma3Label and not na(ma3)
        labMA3 := label.new(x=maRightX, y=ma3, text=f_ma_text("22", ma3), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma3Color, size=size.small)
    if showMALabelsGlobal and ma4Visible and ma4Label and not na(ma4)
        labMA4 := label.new(x=maRightX, y=ma4, text=f_ma_text("50", ma4), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma4Color, size=size.small)
    if showMALabelsGlobal and ma5Visible and ma5Label and not na(ma5)
        labMA5 := label.new(x=maRightX, y=ma5, text=f_ma_text("65", ma5), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma5Color, size=size.small)
    if showMALabelsGlobal and ma6Visible and ma6Label and not na(ma6)
        labMA6 := label.new(x=maRightX, y=ma6, text=f_ma_text("130", ma6), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma6Color, size=size.small)
    if showMALabelsGlobal and ma7Visible and ma7Label and not na(ma7)
        labMA7 := label.new(x=maRightX, y=ma7, text=f_ma_text("200", ma7), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma7Color, size=size.small)
    if showMALabelsGlobal and ma8Visible and ma8Label and not na(ma8)
        labMA8 := label.new(x=maRightX, y=ma8, text=f_ma_text("260", ma8), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=ma8Color, size=size.small)
````

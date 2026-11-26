# Order Block by Devran 

- url: https://www.tradingview.com/script/VrHFkq4P/
- type: indicator
- pine_id: PUB;06fd957374af4214b932a078b8c92411
- version: 1.0

## Description

It is used to find existing Order Blocks. It works in most Timeframes, but I recommend 15 minutes and 5 minutes. It doesn't work 100% correctly. You can find the Order-Block yourself beforehand and then compare it with this indicator and be a little more sure of its accuracy!

## Source Code

````pine
//@version=5
indicator("SMC OB Pro + MSS", shorttitle="OB Finder by Devran", overlay=true,
          max_boxes_count=300, max_labels_count=500, max_lines_count=200)

i_showBull  = input.bool(true,  "Show Bullish OBs",    group="Display")
i_showBear  = input.bool(true,  "Show Bearish OBs",    group="Display")
i_showMSS   = input.bool(true,  "Show MSS Lines",      group="Display")
i_showScore = input.bool(true,  "Show Grade in Label", group="Display")
i_maxOBs    = input.int(10,     "Max OBs on Chart",    group="Display", minval=1, maxval=20)
i_minGrade  = input.string("C", "Min Grade to Show",   group="Filter",  options=["A+","A","B","C","D"])
i_volFilter = input.int(15,     "Min Vol Percentile",  group="Filter",  minval=0, maxval=100)

string tf    = timeframe.period
bool   is15m = tf == "15"
bool   is5m  = tf == "5"
bool   is3m  = tf == "3"

float dispMult = is15m ? 1.20 : is5m ? 1.00 : 0.90
float bodyMin  = is15m ? 0.25 : is5m ? 0.20 : 0.15
int   maxAge   = is15m ? 50   : is5m ? 80   : 100
int   swL      = is15m ? 5    : is5m ? 4    : 3
int   swR      = is15m ? 5    : is5m ? 4    : 3
int   mssConf  = is3m  ? 5    : is5m ? 4    : 3

float ca     = ta.atr(14)
float atr200 = ta.atr(200)

normVol(float src) =>
    float lo = ta.lowest(src, 200)
    float hi = ta.highest(src, 200)
    hi - lo > 0 ? (src - lo) / (hi - lo) * 100.0 : 50.0

float nVol = normVol(high - low)

zonesOverlap(float t1, float b1, float t2, float b2) =>
    float overlap  = math.min(t1, t2) - math.max(b1, b2)
    float minRange = math.min(t1 - b1, t2 - b2)
    minRange > 0 and overlap / minRange > 0.7

[htfE20, htfE50] = request.security(syminfo.tickerid, "60",
     [ta.ema(close, 20), ta.ema(close, 50)], lookahead=barmerge.lookahead_off)

int htfBias = htfE20 > htfE50 ? 1 : htfE20 < htfE50 ? -1 : 0

float ph  = ta.pivothigh(high, swL, swR)
float pl  = ta.pivotlow (low,  swL, swR)
float iph = ta.pivothigh(high, 3, 3)
float ipl = ta.pivotlow (low,  3, 3)
float mph = ta.pivothigh(high, 5, 5)
float mpl = ta.pivotlow (low,  5, 5)

var float lastSwHigh = na
var float lastSwLow  = na
var float mssSwingH  = na
var float mssSwingL  = na

if not na(ph)
    lastSwHigh := ph
if not na(pl)
    lastSwLow  := pl
if not na(iph)
    mssSwingH  := iph
if not na(ipl)
    mssSwingL  := ipl

var int sweepLoScore = 0
var int sweepLoAge   = 999
var int sweepHiScore = 0
var int sweepHiAge   = 999

if barstate.isconfirmed
    sweepLoAge += 1
    sweepHiAge += 1

    if not na(lastSwLow)
        int pts = 0
        if low < lastSwLow and close > lastSwLow
            pts += 1
        if not na(ipl) and low < ipl and close > ipl
            pts += 1
        if not na(mpl) and low < mpl and close > mpl
            pts += 1
        if pts > 0
            sweepLoScore := pts
            sweepLoAge   := 0

    if not na(lastSwHigh)
        int pts = 0
        if high > lastSwHigh and close < lastSwHigh
            pts += 1
        if not na(iph) and high > iph and close < iph
            pts += 1
        if not na(mph) and high > mph and close < mph
            pts += 1
        if pts > 0
            sweepHiScore := pts
            sweepHiAge   := 0

var bool  bullishMSS  = false
var bool  bearishMSS  = false
var int   mssBullAge  = 999
var int   mssBearAge  = 999
var bool  pendBullSwp = false
var int   pendBullAge = 999
var float bullSwpHRef = na
var bool  pendBearSwp = false
var int   pendBearAge = 999
var float bearSwpLRef = na
var float mssBullLvl  = na
var float mssBearLvl  = na
var float fvgBullTop  = na
var float fvgBullBot  = na
var float fvgBearTop  = na
var float fvgBearBot  = na

if barstate.isconfirmed
    bullishMSS := false
    bearishMSS := false
    mssBullLvl := na
    mssBearLvl := na
    mssBullAge += 1
    mssBearAge += 1

    if pendBullSwp
        pendBullAge += 1
        if pendBullAge > mssConf
            pendBullSwp := false
            pendBullAge := 999
            bullSwpHRef := na

    if pendBearSwp
        pendBearAge += 1
        if pendBearAge > mssConf
            pendBearSwp := false
            pendBearAge := 999
            bearSwpLRef := na

    if not na(mssSwingL) and low < mssSwingL and close > mssSwingL
        pendBullSwp := true
        pendBullAge := 0
        bullSwpHRef := mssSwingH

    if not na(mssSwingH) and high > mssSwingH and close < mssSwingH
        pendBearSwp := true
        pendBearAge := 0
        bearSwpLRef := mssSwingL

    if pendBullSwp and not na(bullSwpHRef)
        if close > bullSwpHRef and (close - open) > ca * dispMult
            bullishMSS  := true
            mssBullAge  := 0
            mssBullLvl  := bullSwpHRef
            pendBullSwp := false
            pendBullAge := 999
            bullSwpHRef := na

    if pendBearSwp and not na(bearSwpLRef)
        if close < bearSwpLRef and (open - close) > ca * dispMult
            bearishMSS  := true
            mssBearAge  := 0
            mssBearLvl  := bearSwpLRef
            pendBearSwp := false
            pendBearAge := 999
            bearSwpLRef := na

    if high[2] < low
        fvgBullTop := low
        fvgBullBot := high[2]
    if low[2] > high
        fvgBearTop := low[2]
        fvgBearBot := high

    if i_showMSS
        if bullishMSS and not na(mssBullLvl)
            line.new(bar_index - 1, mssBullLvl, bar_index + 40, mssBullLvl,
                     color=color.new(color.green, 20), width=1, style=line.style_solid)
            label.new(bar_index + 2, mssBullLvl, "MSS",
                      style=label.style_none,
                      textcolor=color.new(color.green, 10),
                      size=size.tiny)
        if bearishMSS and not na(mssBearLvl)
            line.new(bar_index - 1, mssBearLvl, bar_index + 40, mssBearLvl,
                     color=color.new(color.red, 20), width=1, style=line.style_solid)
            label.new(bar_index + 2, mssBearLvl, "MSS",
                      style=label.style_none,
                      textcolor=color.new(color.red, 10),
                      size=size.tiny)

var float[] obTop   = array.new_float()
var float[] obBot   = array.new_float()
var bool[]  obBull  = array.new_bool()
var int[]   obBi    = array.new_int()
var int[]   obTch   = array.new_int()
var int[]   obSc    = array.new_int()
var bool[]  obMitig = array.new_bool()
var box[]   obBx    = array.new_box()
var label[] obLb    = array.new_label()

scoreOB(bool hasSweep, bool strongDisp, bool hasMSS, bool hasFVG, bool htfAl, bool hiVol) =>
    int s = 3
    if hasSweep
        s += 3
    if strongDisp
        s += 3
    if hasMSS
        s += 3
    if hasFVG
        s += 2
    if htfAl
        s += 2
    if hiVol
        s += 1
    s

gradeStr(int sc) =>
    string g = "D"
    if sc >= 15
        g := "A+"
    else if sc >= 12
        g := "A"
    else if sc >= 9
        g := "B"
    else if sc >= 5
        g := "C"
    g

minScoreForGrade(string gr) =>
    int s = 0
    if gr == "A+"
        s := 15
    else if gr == "A"
        s := 12
    else if gr == "B"
        s := 9
    else if gr == "C"
        s := 5
    else
        s := 0
    s

obBgColor(bool isBull, int sc) =>
    color c = color.new(color.gray, 75)
    if isBull
        if sc >= 15
            c := color.new(color.green, 30)
        else if sc >= 12
            c := color.new(color.green, 45)
        else if sc >= 9
            c := color.new(color.green, 60)
        else
            c := color.new(color.green, 75)
    else
        if sc >= 15
            c := color.new(color.red, 30)
        else if sc >= 12
            c := color.new(color.red, 45)
        else if sc >= 9
            c := color.new(color.red, 60)
        else
            c := color.new(color.red, 75)
    c

removeOrSkip(float zt, float zb, bool isBullZone, int sc) =>
    bool skip = false
    if array.size(obTop) > 0
        int  k    = 0
        bool done = false
        while k < array.size(obTop) and not done
            bool sameDir = array.get(obBull, k) == isBullZone
            if sameDir and zonesOverlap(zt, zb, array.get(obTop, k), array.get(obBot, k))
                if sc > array.get(obSc, k)
                    box.delete  (array.get(obBx,    k))
                    label.delete(array.get(obLb,    k))
                    array.remove(obTop,   k)
                    array.remove(obBot,   k)
                    array.remove(obBull,  k)
                    array.remove(obBi,    k)
                    array.remove(obTch,   k)
                    array.remove(obSc,    k)
                    array.remove(obMitig, k)
                    array.remove(obBx,    k)
                    array.remove(obLb,    k)
                else
                    skip := true
                done := true
            else
                k += 1
    skip

if barstate.isconfirmed
    int minSc = minScoreForGrade(i_minGrade)

    bool bOBc  = close[1] < open[1]
    bool bDisp = close > open
    bool bDSz  = (close - open)       > ca * dispMult
    bool bBSz  = (open[1] - close[1]) > ca * bodyMin
    bool bVol  = nVol[1] >= i_volFilter
    bool bOK   = bOBc and bDisp and bDSz and bBSz and bVol

    if bOK and i_showBull
        float zt = open[1]
        float zb = close[1]
        int   bi = bar_index[1]
        bool bSwp  = sweepLoScore > 0 and sweepLoAge <= 8
        bool bStgD = (close - open) > ca * dispMult * 1.5
        bool bMSS  = mssBullAge <= 12
        bool bFVG  = high[2] < low
        bool bHTF  = htfBias > 0
        bool bHVol = nVol[1] >= 60
        int    sc = scoreOB(bSwp, bStgD, bMSS, bFVG, bHTF, bHVol)
        string gr = gradeStr(sc)
        if sc >= minSc
            bool skip = removeOrSkip(zt, zb, true, sc)
            if not skip
                string txt = i_showScore ? "Bull OB [" + gr + "]" : "Bull OB"
                box bx = box.new(bi, zt, bar_index + 1, zb,
                                 border_color=color.new(color.green, 20),
                                 bgcolor=obBgColor(true, sc), border_width=1)
                label lb = label.new(bi, (zt + zb) * 0.5, txt,
                                     style=label.style_none,
                                     textcolor=color.new(color.green, 0),
                                     size=size.small)
                array.push(obTop,   zt)
                array.push(obBot,   zb)
                array.push(obBull,  true)
                array.push(obBi,    bi)
                array.push(obTch,   0)
                array.push(obSc,    sc)
                array.push(obMitig, false)
                array.push(obBx,    bx)
                array.push(obLb,    lb)

    bool rOBc  = close[1] > open[1]
    bool rDisp = close < open
    bool rDSz  = (open - close)       > ca * dispMult
    bool rBSz  = (close[1] - open[1]) > ca * bodyMin
    bool rVol  = nVol[1] >= i_volFilter
    bool rOK   = rOBc and rDisp and rDSz and rBSz and rVol

    if rOK and i_showBear
        float zt = close[1]
        float zb = open[1]
        int   bi = bar_index[1]
        bool rSwp  = sweepHiScore > 0 and sweepHiAge <= 8
        bool rStgD = (open - close) > ca * dispMult * 1.5
        bool rMSS  = mssBearAge <= 12
        bool rFVG  = low[2] > high
        bool rHTF  = htfBias < 0
        bool rHVol = nVol[1] >= 60
        int    sc = scoreOB(rSwp, rStgD, rMSS, rFVG, rHTF, rHVol)
        string gr = gradeStr(sc)
        if sc >= minSc
            bool skip = removeOrSkip(zt, zb, false, sc)
            if not skip
                string txt = i_showScore ? "Bear OB [" + gr + "]" : "Bear OB"
                box bx = box.new(bi, zt, bar_index + 1, zb,
                                 border_color=color.new(color.red, 20),
                                 bgcolor=obBgColor(false, sc), border_width=1)
                label lb = label.new(bi, (zt + zb) * 0.5, txt,
                                     style=label.style_none,
                                     textcolor=color.new(color.red, 0),
                                     size=size.small)
                array.push(obTop,   zt)
                array.push(obBot,   zb)
                array.push(obBull,  false)
                array.push(obBi,    bi)
                array.push(obTch,   0)
                array.push(obSc,    sc)
                array.push(obMitig, false)
                array.push(obBx,    bx)
                array.push(obLb,    lb)

    int i = 0
    while i < array.size(obTop)
        float top     = array.get(obTop,   i)
        float bot     = array.get(obBot,   i)
        bool  isBull  = array.get(obBull,  i)
        int   startBi = array.get(obBi,    i)
        int   touches = array.get(obTch,   i)
        int   sc      = array.get(obSc,    i)
        bool  mitig   = array.get(obMitig, i)
        box   bx      = array.get(obBx,    i)
        label lb      = array.get(obLb,    i)
        int   age     = bar_index - startBi

        float mid      = (top + bot) * 0.5
        bool  partial  = isBull ? (low <= mid and close > bot) : (high >= mid and close < top)
        bool  fullFill = isBull ? close < bot : close > top

        if partial and not mitig
            array.set(obMitig, i, true)
            int newSc = math.min(sc + 1, 17)
            array.set(obSc, i, newSc)
            string gr2    = gradeStr(newSc)
            string tag    = isBull ? "Bull" : "Bear"
            string newTxt = i_showScore ? tag + " OB [" + gr2 + "]★" : tag + " OB★"
            label.set_text(lb, newTxt)

        if age > 1 and high >= bot and low <= top
            touches += 1
            array.set(obTch, i, touches)

        bool isStale    = age > maxAge
        bool isOverused = touches > 3

        if isStale or fullFill or isOverused
            box.set_right(bx, bar_index)
            label.delete(lb)
            array.remove(obTop,   i)
            array.remove(obBot,   i)
            array.remove(obBull,  i)
            array.remove(obBi,    i)
            array.remove(obTch,   i)
            array.remove(obSc,    i)
            array.remove(obMitig, i)
            array.remove(obBx,    i)
            array.remove(obLb,    i)
        else
            box.set_right(bx, bar_index + 1)
            i += 1

    while array.size(obTop) > i_maxOBs
        box.delete  (array.shift(obBx))
        label.delete(array.shift(obLb))
        array.shift(obTop)
        array.shift(obBot)
        array.shift(obBull)
        array.shift(obBi)
        array.shift(obTch)
        array.shift(obSc)
        array.shift(obMitig)

alertcondition(barstate.isconfirmed and bullishMSS, title="Bullish MSS", message="SMC Pro: Bullish MSS")
alertcondition(barstate.isconfirmed and bearishMSS, title="Bearish MSS", message="SMC Pro: Bearish MSS")
````

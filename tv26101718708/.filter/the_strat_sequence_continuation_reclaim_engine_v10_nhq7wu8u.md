# The Strat Sequence Continuation / Reclaim Engine v1.0

- url: https://www.tradingview.com/script/nhq7wU8U-The-Strat-Sequence-Continuation-Reclaim-Engine-v1-0/
- type: indicator
- pine_id: PUB;b5dd880919f9437683f780d2dced7bf1
- version: 2.0

## Description

The Strat Sequence Continuation / Reclaim Engine

The Strat Sequence Continuation / Reclaim Engine is a body-close-based study designed to help traders review how specific Strat candle sequences have historically resolved on the selected chart timeframe.

This indicator combines two separate views:

1. **Markov Regime Permission Panel**
   A regime-style table that evaluates recent price behavior and displays market state, return, transition probabilities, permission, and trade behavior context. This table can be turned on/off by the user.

2. **Strat Sequence Continuation / Reclaim Table**
   A focused table that measures whether selected Strat sequences continued by body close or failed/reclaimed the relevant reference level.

The sequence table evaluates setups such as:

* Failed 2U → x
* Failed 2D → x
* F2U → 2D → x
* F2D → 2U → x
* F2U → 2D → 2D → x
* F2D → 2U → 2U → x
* 2-2U → x
* 2-2D → x
* 2-1-2U → x
* 2-1-2D → x
* 3-1-2U → x
* 3-1-2D → x
* 3H → x
* 3L → x

For bullish sequences, continuation is counted only when the next candle closes above the applicable reference candle high.
For bearish sequences, continuation is counted only when the next candle closes below the applicable reference candle low.
If price does not close beyond the reference level, the event is classified as reclaim/fail.

The table also includes:

* User-selected lookback
* Live setup candle read
* Live sequence watch
* Body-close decision rule
* Row visibility controls
* Minimum sample threshold filtering
* Optional bull/bear color coding

This tool is intended for historical sequence review, market context, and discretionary analysis. It does not predict future price movement, generate buy/sell signals, or provide financial advice. All outputs depend on the selected symbol, timeframe, lookback settings, and available chart history.

## Source Code

````pine
//@version=6
indicator("The Strat Sequence Continuation / Reclaim Engine v1.1", overlay=true, max_bars_back=5000, max_labels_count=500, max_lines_count=500)

// =====================================================
// 1) USER INPUTS
// =====================================================
grpSeq = "Sequence Continuation / Reclaim Table"
seqLookback = input.int(400, "Sequence Stat Lookback", minval=25, maxval=5000, group=grpSeq)
seqMinCount = input.int(20, "Minimum Count To Show Row", minval=0, group=grpSeq)
hideRowsBelowMin = input.bool(false, "Hide Rows Below Minimum Count", group=grpSeq)
showSeqTable = input.bool(true, "Show Sequence C/R Table", group=grpSeq)
seqPosInput = input.string("Middle Right", "Sequence Table Position", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group=grpSeq)
seqSizeInput = input.string("Small", "Sequence Table Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpSeq)
seqBg = input.color(color.new(color.black, 10), "Table Background", group=grpSeq)
seqTxt = input.color(color.white, "Text Color", group=grpSeq)
seqLabelColorMode = input.string("Bull/Bear", "Sequence Label Color Mode", options=["Bull/Bear", "All White"], group=grpSeq)
showBodyRuleCol = input.bool(true, "Show Body Rule Column", group=grpSeq)
seqHi = input.color(color.lime, "Continuation Highlight", group=grpSeq)
seqWarn = input.color(color.orange, "Low Count Warning", group=grpSeq)

showF2Ux = input.bool(true, "Show Failed 2U → x", group=grpSeq)
showF2Dx = input.bool(true, "Show Failed 2D → x", group=grpSeq)
showF2U2Dx = input.bool(true, "Show F2U → 2D → x", group=grpSeq)
showF2D2Ux = input.bool(true, "Show F2D → 2U → x", group=grpSeq)
showF2U2D2Dx = input.bool(true, "Show F2U → 2D → 2D → x", group=grpSeq)
showF2D2U2Ux = input.bool(true, "Show F2D → 2U → 2U → x", group=grpSeq)
show22Ux = input.bool(true, "Show 2-2U → x", group=grpSeq)
show22Dx = input.bool(true, "Show 2-2D → x", group=grpSeq)
show212Ux = input.bool(true, "Show 2-1-2U → x", group=grpSeq)
show212Dx = input.bool(true, "Show 2-1-2D → x", group=grpSeq)
show312Ux = input.bool(true, "Show 3-1-2U → x", group=grpSeq)
show312Dx = input.bool(true, "Show 3-1-2D → x", group=grpSeq)
show3Hx = input.bool(true, "Show 3H → x", group=grpSeq)
show3Lx = input.bool(true, "Show 3L → x", group=grpSeq)

showAudit = input.bool(false, "Show Sequence Audit Marks", group=grpSeq)
auditBars = input.int(150, "Audit Lookback Bars", minval=10, maxval=1000, group=grpSeq)
auditSizeInput = input.string("Small", "Audit Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpSeq)
auditOffsetAtr = input.float(0.06, "Audit Label Offset ATR Mult", minval=0.0, step=0.01, group=grpSeq)

// Structure is retained mainly for HTF bias used by Markov Trade Behavior.
grpStruct = "Structure / HTF Bias"
tf = input.timeframe("240", "Structural Timeframe", group=grpStruct)
structLookback = input.int(70, "Structure Lookback", minval=1, group=grpStruct)
plotStructure = input.bool(false, "Plot BF High / Low / Zone", group=grpStruct)
zS = input.float(50.0, "Zone Floor %", group=grpStruct) / 100.0
zE = input.float(70.0, "Zone Ceiling %", group=grpStruct) / 100.0
highCol = input.color(color.new(color.red, 30), "BF High Color", group=grpStruct)
lowCol = input.color(color.new(color.green, 30), "BF Low Color", group=grpStruct)
zoneCol = input.color(color.new(color.blue, 90), "Zone Fill", group=grpStruct)

// Markov module retained from the working structural probability framework.
grpMk = "Markov Regime Permission Panel"
mkEn = input.bool(true, "Enable Markov Permission Panel", group=grpMk)
mkSrc = input.source(close, "Markov Source", group=grpMk)
mkLen = input.int(20, "Regime Lookback", minval=1, maxval=500, group=grpMk)
mkLb = input.int(500, "Markov Transition Lookback", minval=25, maxval=5000, group=grpMk)
mkMode = input.string("Auto Adaptive", "Threshold Mode", options=["Auto Adaptive", "Custom Fixed"], group=grpMk)
mkVolLen = input.int(100, "Auto Volatility Lookback", minval=10, maxval=1000, group=grpMk)
mkMult = input.float(1.0, "Auto Threshold Multiplier", step=0.05, group=grpMk)
mkMinT = input.float(0.02, "Minimum Auto Threshold %", step=0.01, group=grpMk)
mkMaxT = input.float(10.0, "Maximum Auto Threshold %", step=0.25, group=grpMk)
mkBullFix = input.float(0.25, "Custom Bull Threshold %", step=0.05, group=grpMk)
mkBearFix = input.float(-0.25, "Custom Bear Threshold %", step=0.05, group=grpMk)
mkStrong = input.float(25.0, "Strong Signal Threshold %", step=1.0, group=grpMk)
mkWeak = input.float(10.0, "Weak Edge Band %", step=1.0, group=grpMk)
mkMinN = input.int(30, "Low Sample Warning Below", minval=1, group=grpMk)
mkShow = input.bool(true, "Show Markov Panel Table", group=grpMk)
mkShowFlip = input.bool(true, "Show Flip Level Row", group=grpMk)
mkShowFc = input.bool(true, "Show 3/5 Bar Signal Row", group=grpMk)
mkShowMx = input.bool(false, "Show Compact Markov Matrix % Row", group=grpMk)
mkShowAlign = input.bool(true, "Show Trade Behavior Row", group=grpMk)
mkFL = input.bool(false, "Show Markov Flip Lines", group=grpMk)
mkFLMode = input.string("Bull & Bear", "Flip Lines Shown", options=["Bull & Bear", "Bull Only", "Bear Only"], group=grpMk)
mkFLStyle = input.string("Dashed", "Flip Line Style", options=["Solid", "Dashed", "Dotted"], group=grpMk)
mkFLW = input.int(2, "Flip Line Width", minval=1, maxval=5, group=grpMk)
mkFLBack = input.int(100, "Flip Line Bars Back", minval=1, maxval=5000, group=grpMk)
mkPosInput = input.string("Top Right", "Markov Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpMk)
mkSizeInput = input.string("Small", "Markov Table Text Size", options=["Tiny", "Small", "Normal"], group=grpMk)
mkHeaderBg = input.color(color.rgb(35, 39, 52), "Header Background", group=grpMk)
mkLabelBg = input.color(color.rgb(52, 57, 72), "Label Background", group=grpMk)
mkDataBg = input.color(color.rgb(67, 72, 88), "Data Background", group=grpMk)
mkTextCol = input.color(color.white, "Text Color", group=grpMk)
mkBullCol = input.color(color.green, "Bull Color", group=grpMk)
mkSideCol = input.color(color.orange, "Sideways Color", group=grpMk)
mkBearCol = input.color(color.red, "Bear Color", group=grpMk)

// =====================================================
// 2) DISPLAY HELPERS
// =====================================================
f_pos(string x) =>
    p = position.middle_right
    if x == "Top Right"
        p := position.top_right
    else if x == "Bottom Right"
        p := position.bottom_right
    else if x == "Top Left"
        p := position.top_left
    else if x == "Middle Left"
        p := position.middle_left
    else if x == "Bottom Left"
        p := position.bottom_left
    p

f_mkPos(string x) =>
    p = position.top_right
    if x == "Top Left"
        p := position.top_left
    else if x == "Bottom Right"
        p := position.bottom_right
    else if x == "Bottom Left"
        p := position.bottom_left
    p

f_size(string x) =>
    s = size.small
    if x == "Tiny"
        s := size.tiny
    else if x == "Normal"
        s := size.normal
    else if x == "Large"
        s := size.large
    s

f_mkSize(string x) =>
    s = size.small
    if x == "Tiny"
        s := size.tiny
    else if x == "Normal"
        s := size.normal
    s

f_pct(int hits, int total) =>
    out = 0.0
    if total > 0
        out := hits * 100.0 / total
    out

f_pctText(int hits, int total) =>
    str.tostring(f_pct(hits, total), "#.##") + "%"

f_pctTextCnt(int hits, int total) =>
    str.tostring(f_pct(hits, total), "#.##") + "% (" + str.tostring(hits) + "/" + str.tostring(total) + ")"

f_edgeColor(int cont, int reclaim) =>
    c = seqTxt
    total = cont + reclaim
    if total > 0
        if cont > reclaim
            c := seqHi
        else if reclaim > cont
            c := color.red
        else
            c := color.yellow
    c

f_countBg(int total, color baseBg) =>
    c = baseBg
    if total > 0 and total < seqMinCount
        c := color.new(seqWarn, 75)
    c

f_lastText(string x) =>
    out = x
    if out == ""
        out := "NA"
    out

f_isBullSeq(int seqId) =>
    bool out = false
    if seqId == 2 or seqId == 4 or seqId == 6 or seqId == 7 or seqId == 9 or seqId == 11 or seqId == 13
        out := true
    out

f_isBearSeq(int seqId) =>
    bool out = false
    if seqId == 1 or seqId == 3 or seqId == 5 or seqId == 8 or seqId == 10 or seqId == 12 or seqId == 14
        out := true
    out

f_seqLabelColor(int seqId) =>
    color out = seqTxt
    if seqLabelColorMode == "Bull/Bear"
        if f_isBullSeq(seqId)
            out := color.lime
        else if f_isBearSeq(seqId)
            out := color.red
    out

f_liveTextColor(bool bullNow, bool bearNow) =>
    color out = seqTxt
    if seqLabelColorMode == "Bull/Bear"
        if bullNow and not bearNow
            out := color.lime
        else if bearNow and not bullNow
            out := color.red
    out

f_joinSetupText(string current, string item) =>
    string out = current
    if out == ""
        out := item
    else
        out := out + "/" + item
    out

f_setupTextFromFlags(bool isF2UFlag, bool isF2DFlag, bool is22UFlag, bool is22DFlag, bool is212UFlag, bool is212DFlag, bool is312UFlag, bool is312DFlag, bool is2UFlag, bool is2DFlag, bool is1Flag, bool is3Flag) =>
    string out = ""
    if isF2UFlag
        out := f_joinSetupText(out, "F2U")
    if isF2DFlag
        out := f_joinSetupText(out, "F2D")
    if is22UFlag
        out := f_joinSetupText(out, "22U")
    if is22DFlag
        out := f_joinSetupText(out, "22D")
    if is212UFlag
        out := f_joinSetupText(out, "212U")
    if is212DFlag
        out := f_joinSetupText(out, "212D")
    if is312UFlag
        out := f_joinSetupText(out, "312U")
    if is312DFlag
        out := f_joinSetupText(out, "312D")
    if out == ""
        if is3Flag
            out := "3"
        else if is2UFlag
            out := "2U"
        else if is2DFlag
            out := "2D"
        else if is1Flag
            out := "1"
    if out == ""
        out := "No setup"
    out

// =====================================================
// 3) THESTRAT CLASSIFICATION
// =====================================================
is2U = high > high[1] and low >= low[1]
is2D = low < low[1] and high <= high[1]
is1 = high <= high[1] and low >= low[1]
is3 = high > high[1] and low < low[1]

f2D_R = is2D and close > open
f2U_R = is2U and close < open
s22_U = is2D[1] and is2U
s22_D = is2U[1] and is2D
s212_U = is2D[2] and is1[1] and is2U
s212_D = is2U[2] and is1[1] and is2D
s312_U = is3[2] and is1[1] and is2U
s312_D = is3[2] and is1[1] and is2D

plotshape(f2D_R, title="F2D", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(f2U_R, title="F2U", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(s22_U, title="2-2U", style=shape.circle, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(s22_D, title="2-2D", style=shape.circle, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(s212_U, title="2-1-2U", style=shape.diamond, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(s212_D, title="2-1-2D", style=shape.diamond, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(s312_U, title="3-1-2U", style=shape.square, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(s312_D, title="3-1-2D", style=shape.square, location=location.abovebar, color=color.red, size=size.tiny)

// =====================================================
// 4) STRUCTURE / HTF BIAS
// =====================================================
[mtfH, mtfL, mtfO, mtfC] = request.security(syminfo.tickerid, tf, [ta.highest(high, structLookback)[1], ta.lowest(low, structLookback)[1], open[1], close[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
rangeMTF = mtfH - mtfL
isBullHTF = mtfC >= mtfO
z1 = 0.0
z2 = 0.0
if isBullHTF
    z1 := mtfH - rangeMTF * zS
    z2 := mtfH - rangeMTF * zE
else
    z1 := mtfL + rangeMTF * zS
    z2 := mtfL + rangeMTF * zE
zTop = math.max(z1, z2)
zBot = math.min(z1, z2)
float plotH = na
float plotL = na
float plotZT = na
float plotZB = na
if plotStructure
    plotH := mtfH
    plotL := mtfL
    plotZT := zTop
    plotZB := zBot
pH = plot(plotH, "BF High", color=highCol, linewidth=2, style=plot.style_linebr)
pL = plot(plotL, "BF Low", color=lowCol, linewidth=2, style=plot.style_linebr)
pZT = plot(plotZT, "Zone Top", color=color.new(color.gray, 50), style=plot.style_linebr)
pZB = plot(plotZB, "Zone Bottom", color=color.new(color.gray, 50), style=plot.style_linebr)
fill(pZT, pZB, color=zoneCol, title="Reaction Zone")

// =====================================================
// 5) STORAGE
// =====================================================
type BarData
    bool is2U
    bool is2D
    bool is1
    bool is3
    bool f2U
    bool f2D
    bool s22U
    bool s22D
    bool s212U
    bool s212D
    bool s312U
    bool s312D
    int idx
    int t
    float h
    float l
    float c

var array<BarData> bars = array.new<BarData>()
array.push(bars, BarData.new(is2U, is2D, is1, is3, f2U_R, f2D_R, s22_U, s22_D, s212_U, s212_D, s312_U, s312_D, bar_index, time, high, low, close))
keepBars = math.min(seqLookback + 50, 5000)
while array.size(bars) > keepBars
    array.shift(bars)

// =====================================================
// 6) SEQUENCE STAT ENGINE
// seqId order:
// 1 F2U-x | 2 F2D-x | 3 F2U-2D-x | 4 F2D-2U-x | 5 F2U-2D-2D-x | 6 F2D-2U-2U-x
// 7 2-2U-x | 8 2-2D-x | 9 2-1-2U-x | 10 2-1-2D-x | 11 3-1-2U-x | 12 3-1-2D-x | 13 3H-x | 14 3L-x
// =====================================================
f_seqStats(int seqId) =>
    int count = 0
    int cont = 0
    int reclaim = 0
    string last = ""
    int aSz = array.size(bars)
    int lastClosed = aSz - 1
    if not barstate.isconfirmed
        lastClosed := aSz - 2
    int st = math.max(0, lastClosed - seqLookback - 5)
    int en = lastClosed - 1
    if en >= st
        for i = st to en
            BarData cur = array.get(bars, i)
            BarData decision = array.get(bars, i + 1)
            bool match = false
            bool bull = false
            bool bear = false
            float refH = cur.h
            float refL = cur.l
            if seqId == 1
                if cur.f2U
                    match := true
                    bear := true
            else if seqId == 2
                if cur.f2D
                    match := true
                    bull := true
            else if seqId == 3
                if i > 0
                    BarData prev3 = array.get(bars, i - 1)
                    if prev3.f2U and cur.s22D
                        match := true
                        bear := true
            else if seqId == 4
                if i > 0
                    BarData prev4 = array.get(bars, i - 1)
                    if prev4.f2D and cur.s22U
                        match := true
                        bull := true
            else if seqId == 5
                if i > 1
                    BarData prev5 = array.get(bars, i - 1)
                    BarData twoBack5 = array.get(bars, i - 2)
                    if twoBack5.f2U and prev5.s22D and cur.is2D
                        match := true
                        bear := true
            else if seqId == 6
                if i > 1
                    BarData prev6 = array.get(bars, i - 1)
                    BarData twoBack6 = array.get(bars, i - 2)
                    if twoBack6.f2D and prev6.s22U and cur.is2U
                        match := true
                        bull := true
            else if seqId == 7
                if cur.s22U
                    match := true
                    bull := true
            else if seqId == 8
                if cur.s22D
                    match := true
                    bear := true
            else if seqId == 9
                if cur.s212U
                    match := true
                    bull := true
            else if seqId == 10
                if cur.s212D
                    match := true
                    bear := true
            else if seqId == 11
                if cur.s312U
                    match := true
                    bull := true
            else if seqId == 12
                if cur.s312D
                    match := true
                    bear := true
            else if seqId == 13
                if cur.is3 and decision.h > cur.h
                    match := true
                    bull := true
            else if seqId == 14
                if cur.is3 and decision.l < cur.l
                    match := true
                    bear := true
            if match
                count += 1
                if bull
                    if decision.c > refH
                        cont += 1
                        last := "C"
                    else
                        reclaim += 1
                        last := "R"
                if bear
                    if decision.c < refL
                        cont += 1
                        last := "C"
                    else
                        reclaim += 1
                        last := "R"
    [count, cont, reclaim, last]

f_ruleText(int seqId) =>
    string out = ""
    if seqId == 1
        out := "x close < F2U low"
    else if seqId == 2
        out := "x close > F2D high"
    else if seqId == 3
        out := "x close < 2D low"
    else if seqId == 4
        out := "x close > 2U high"
    else if seqId == 5
        out := "x close < prior 2D low"
    else if seqId == 6
        out := "x close > prior 2U high"
    else if seqId == 7
        out := "x close > 2U high"
    else if seqId == 8
        out := "x close < 2D low"
    else if seqId == 9
        out := "x close > 212U high"
    else if seqId == 10
        out := "x close < 212D low"
    else if seqId == 11
        out := "x close > 312U high"
    else if seqId == 12
        out := "x close < 312D low"
    else if seqId == 13
        out := "x closes through 3H"
    else if seqId == 14
        out := "x closes through 3L"
    out

f_seqName(int seqId) =>
    string out = ""
    if seqId == 1
        out := "▼ Failed 2U → x"
    else if seqId == 2
        out := "▲ Failed 2D → x"
    else if seqId == 3
        out := "▼ F2U → 2D → x"
    else if seqId == 4
        out := "▲ F2D → 2U → x"
    else if seqId == 5
        out := "▼ F2U → 2D → 2D → x"
    else if seqId == 6
        out := "▲ F2D → 2U → 2U → x"
    else if seqId == 7
        out := "● 2-2U → x"
    else if seqId == 8
        out := "● 2-2D → x"
    else if seqId == 9
        out := "◆ 2-1-2U → x"
    else if seqId == 10
        out := "◆ 2-1-2D → x"
    else if seqId == 11
        out := "■ 3-1-2U → x"
    else if seqId == 12
        out := "■ 3-1-2D → x"
    else if seqId == 13
        out := "▲ 3H → x"
    else if seqId == 14
        out := "▼ 3L → x"
    out

f_seqEnabled(int seqId) =>
    bool out = false
    if seqId == 1
        out := showF2Ux
    else if seqId == 2
        out := showF2Dx
    else if seqId == 3
        out := showF2U2Dx
    else if seqId == 4
        out := showF2D2Ux
    else if seqId == 5
        out := showF2U2D2Dx
    else if seqId == 6
        out := showF2D2U2Ux
    else if seqId == 7
        out := show22Ux
    else if seqId == 8
        out := show22Dx
    else if seqId == 9
        out := show212Ux
    else if seqId == 10
        out := show212Dx
    else if seqId == 11
        out := show312Ux
    else if seqId == 12
        out := show312Dx
    else if seqId == 13
        out := show3Hx
    else if seqId == 14
        out := show3Lx
    out

f_drawSeqRow(table tb, int r, int seqId, int count, int cont, int reclaim, string last, sz, color bg) =>
    table.cell(tb, 0, r, f_seqName(seqId), text_color=f_seqLabelColor(seqId), text_size=sz, bgcolor=bg)
    table.cell(tb, 1, r, str.tostring(count), text_color=seqTxt, text_size=sz, bgcolor=f_countBg(count, bg))
    table.cell(tb, 2, r, f_pctTextCnt(cont, count), text_color=f_edgeColor(cont, reclaim), text_size=sz, bgcolor=bg)
    table.cell(tb, 3, r, f_pctTextCnt(reclaim, count), text_color=f_edgeColor(reclaim, cont), text_size=sz, bgcolor=bg)
    if showBodyRuleCol
        table.cell(tb, 4, r, f_ruleText(seqId), text_color=seqTxt, text_size=sz, bgcolor=bg)
        table.cell(tb, 5, r, f_lastText(last), text_color=f_edgeColor(cont, reclaim), text_size=sz, bgcolor=bg)
    else
        table.cell(tb, 4, r, f_lastText(last), text_color=f_edgeColor(cont, reclaim), text_size=sz, bgcolor=bg)

// =====================================================
// 7) LIVE SETUP / LIVE SEQUENCE WATCH
// =====================================================

f_liveBullNow() =>
    bool out = false
    if f2D_R or s22_U or s212_U or s312_U or is2U
        out := true
    out

f_liveBearNow() =>
    bool out = false
    if f2U_R or s22_D or s212_D or s312_D or is2D
        out := true
    out

f_liveCandleText() =>
    string x = ""
    if is3
        x := "Live 3"
    else if is2U
        x := "Live 2U"
    else if is2D
        x := "Live 2D"
    else if is1
        x := "Live 1"
    if f2U_R
        x := x + " / F2U"
    if f2D_R
        x := x + " / F2D"
    if s22_U
        x := x + " / 22U"
    if s22_D
        x := x + " / 22D"
    if s212_U
        x := x + " / 212U"
    if s212_D
        x := x + " / 212D"
    if s312_U
        x := x + " / 312U"
    if s312_D
        x := x + " / 312D"
    x

f_liveWatchText() =>
    string x = "No active sequence watch"
    if f2U_R
        x := "Watching Failed 2U → x next"
    else if f2D_R
        x := "Watching Failed 2D → x next"
    else if f2U_R[1] and is2D
        x := "Watching F2U → 2D → x next"
    else if f2D_R[1] and is2U
        x := "Watching F2D → 2U → x next"
    else if f2U_R[2] and is2D[1] and is2D
        x := "Watching F2U → 2D → 2D → x next"
    else if f2D_R[2] and is2U[1] and is2U
        x := "Watching F2D → 2U → 2U → x next"
    else if s22_U
        x := "Watching 2-2U → x next"
    else if s22_D
        x := "Watching 2-2D → x next"
    else if s212_U
        x := "Watching 2-1-2U → x next"
    else if s212_D
        x := "Watching 2-1-2D → x next"
    else if s312_U
        x := "Watching 3-1-2U → x next"
    else if s312_D
        x := "Watching 3-1-2D → x next"
    else if is3
        x := "Watching 3H / 3L break attempt next"
    x

f_liveRuleText() =>
    string x = "Continuation requires a body close beyond the reference high/low. Otherwise = reclaim/fail."
    if f2U_R
        x := "Next close < F2U low = Continue; otherwise Reclaim"
    else if f2D_R
        x := "Next close > F2D high = Continue; otherwise Reclaim"
    else if f2U_R[1] and is2D
        x := "Next close < 2D low = Continue; otherwise Reclaim"
    else if f2D_R[1] and is2U
        x := "Next close > 2U high = Continue; otherwise Reclaim"
    else if s22_U or s212_U or s312_U
        x := "Next close > signal high = Continue; otherwise Reclaim"
    else if s22_D or s212_D or s312_D
        x := "Next close < signal low = Continue; otherwise Reclaim"
    x

// =====================================================
// 8) MARKOV HELPERS
// =====================================================
mkS(float r, float bt, float rt) =>
    int s = 0
    if r >= bt
        s := 1
    else if r <= rt
        s := -1
    s

mkTxt(int s) =>
    string x = "Sideways"
    if s == 1
        x := "Bull"
    else if s == -1
        x := "Bear"
    x

mkPct(int a, int b) =>
    float out = na
    if b > 0
        out := a * 100.0 / b
    out

mkFmt(float x) =>
    string out = "n/a"
    if not na(x)
        out := str.tostring(x, "#.##") + "%"
    out

mkPx(float x) =>
    string out = "n/a"
    if not na(x)
        out := str.tostring(x, format.mintick)
    out

mkBgState(int s) =>
    color c = color.new(mkSideCol, 25)
    if s == 1
        c := color.new(mkBullCol, 25)
    else if s == -1
        c := color.new(mkBearCol, 25)
    c

mkBgPath(string p) =>
    color c = mkDataBg
    if p == "Bull"
        c := color.new(mkBullCol, 60)
    else if p == "Bear"
        c := color.new(mkBearCol, 60)
    else if p == "Sideways"
        c := color.new(mkSideCol, 60)
    c

mkThresh(float src, simple int len) =>
    float one = na
    if not na(src[1]) and src[1] != 0.0
        one := ((src / src[1]) - 1.0) * 100.0
    float vol = ta.stdev(one, mkVolLen) * math.sqrt(len * 1.0) * mkMult
    float autoT = na
    if not na(vol)
        autoT := math.min(math.max(vol, math.max(mkMinT, 0.0)), math.max(mkMaxT, mkMinT))
    float bt = mkBullFix
    float rt = mkBearFix
    if mkMode == "Auto Adaptive"
        bt := autoT
        rt := -autoT
    [bt, rt, autoT]

mkVb(float b, float s, float r, float bb, float sb, float rb) =>
    (b * bb + s * sb + r * rb) / 100.0

mkVs(float b, float s, float r, float bs, float ss, float rs) =>
    (b * bs + s * ss + r * rs) / 100.0

mkVr(float b, float s, float r, float br, float sr, float rr) =>
    (b * br + s * sr + r * rr) / 100.0

mkPath(float b, float s, float r) =>
    string p = "n/a"
    if not na(b) and not na(s) and not na(r)
        if b >= s and b >= r
            p := "Bull"
        else if r >= b and r >= s
            p := "Bear"
        else
            p := "Sideways"
    p

mkMatrix(float src, simple int len, simple int req, float bt, float rt, bool on) =>
    int cs = 0
    float rn = na
    if on and bar_index >= len and not na(src[len]) and src[len] != 0.0
        rn := ((src / src[len]) - 1.0) * 100.0
        cs := mkS(rn, bt, rt)
    int used = 0
    int bb = 0
    int bs = 0
    int br = 0
    int sb = 0
    int ss = 0
    int sr = 0
    int rb = 0
    int rs = 0
    int rr = 0
    int maxUse = math.min(req, math.max(1, 5000 - len))
    int avail = math.max(0, bar_index - len)
    used := math.min(maxUse, avail)
    if on and used >= 1
        for i = 1 to used
            float fr = na
            float tr = na
            if not na(src[i + len]) and src[i + len] != 0.0 and not na(src[i - 1 + len]) and src[i - 1 + len] != 0.0
                fr := ((src[i] / src[i + len]) - 1.0) * 100.0
                tr := ((src[i - 1] / src[i - 1 + len]) - 1.0) * 100.0
            int f = 0
            int t = 0
            if not na(fr)
                f := mkS(fr, bt, rt)
            if not na(tr)
                t := mkS(tr, bt, rt)
            if f == 1 and t == 1
                bb += 1
            else if f == 1 and t == 0
                bs += 1
            else if f == 1 and t == -1
                br += 1
            else if f == 0 and t == 1
                sb += 1
            else if f == 0 and t == 0
                ss += 1
            else if f == 0 and t == -1
                sr += 1
            else if f == -1 and t == 1
                rb += 1
            else if f == -1 and t == 0
                rs += 1
            else if f == -1 and t == -1
                rr += 1
    int bd = bb + bs + br
    int sd = sb + ss + sr
    int rd = rb + rs + rr
    float bbp = mkPct(bb, bd)
    float bsp = mkPct(bs, bd)
    float brp = mkPct(br, bd)
    float sbp = mkPct(sb, sd)
    float ssp = mkPct(ss, sd)
    float srp = mkPct(sr, sd)
    float rbp = mkPct(rb, rd)
    float rsp = mkPct(rs, rd)
    float rrp = mkPct(rr, rd)
    float p1b = sbp
    float p1s = ssp
    float p1r = srp
    if cs == 1
        p1b := bbp
        p1s := bsp
        p1r := brp
    else if cs == -1
        p1b := rbp
        p1s := rsp
        p1r := rrp
    float p2b = mkVb(p1b, p1s, p1r, bbp, sbp, rbp)
    float p2s = mkVs(p1b, p1s, p1r, bsp, ssp, rsp)
    float p2r = mkVr(p1b, p1s, p1r, brp, srp, rrp)
    float p3b = mkVb(p2b, p2s, p2r, bbp, sbp, rbp)
    float p3s = mkVs(p2b, p2s, p2r, bsp, ssp, rsp)
    float p3r = mkVr(p2b, p2s, p2r, brp, srp, rrp)
    float p4b = mkVb(p3b, p3s, p3r, bbp, sbp, rbp)
    float p4s = mkVs(p3b, p3s, p3r, bsp, ssp, rsp)
    float p4r = mkVr(p3b, p3s, p3r, brp, srp, rrp)
    float p5b = mkVb(p4b, p4s, p4r, bbp, sbp, rbp)
    float p5r = mkVr(p4b, p4s, p4r, brp, srp, rrp)
    [cs, rn, used, bd, sd, rd, p1b, p1s, p1r, p3b, p3r, p5b, p5r, bbp, bsp, brp, sbp, ssp, srp, rbp, rsp, rrp]

mkPerm(float sig, int n) =>
    string p = "Wait / Chop"
    if n > 0 and n < mkMinN
        p := "Low sample"
    else if sig >= mkStrong
        p := "Aggressive Long"
    else if sig > mkWeak
        p := "Cautious Long"
    else if sig <= -mkStrong
        p := "Aggressive Short"
    else if sig < -mkWeak
        p := "Cautious Short"
    p

mkPermDir(string p) =>
    int d = 0
    if str.contains(p, "Long")
        d := 1
    else if str.contains(p, "Short")
        d := -1
    d

mkHtfTxt(int d) =>
    string x = "HTF Bear"
    if d == 1
        x := "HTF Bull"
    x

mkAlignTxt(int stratD, int markovD, int htfD) =>
    string x = "No live setup"
    if stratD == 0
        x := "No live setup"
    else if markovD == 0
        if stratD == htfD
            if stratD == 1
                x := "Long setup in chop / faster targets"
            else
                x := "Short setup in chop / faster targets"
        else
            if stratD == 1
                x := "Long not clean: chop + Bear HTF"
            else
                x := "Short not clean: chop + Bull HTF"
    else if stratD == markovD and stratD == htfD
        if stratD == 1
            x := "Long setup confirmed"
        else
            x := "Short setup confirmed"
    else if stratD == markovD
        if stratD == 1
            x := "Favor long continuation"
        else
            x := "Favor short continuation"
    else if markovD == htfD
        if markovD == 1
            x := "Favor longs / short counter-regime"
        else
            x := "Favor shorts / long counter-regime"
    else
        x := "Mixed: wait for confirmation"
    x

mkAlignBg(int stratD, int markovD, int htfD) =>
    color c = mkDataBg
    if stratD == 0
        c := mkDataBg
    else if markovD == 0
        c := color.new(mkSideCol, 60)
    else if stratD == markovD and stratD == htfD
        if stratD == 1
            c := color.new(mkBullCol, 45)
        else
            c := color.new(mkBearCol, 45)
    else if stratD == markovD
        if stratD == 1
            c := color.new(mkBullCol, 60)
        else
            c := color.new(mkBearCol, 60)
    else
        c := color.new(mkSideCol, 70)
    c

mkCell(table tb, int c, int r, string txt, color bg, sz) =>
    table.cell(tb, c, r, txt, text_color=mkTextCol, bgcolor=bg, text_size=sz)

// =====================================================
// 9) MARKOV CALCULATION + TRADE BEHAVIOR
// =====================================================
[mkBt, mkRt, mkAutoT] = mkThresh(mkSrc, mkLen)
[mkState, mkRet, mkUsed, mkBd, mkSd, mkRd, mkP1b, mkP1s, mkP1r, mkP3b, mkP3r, mkP5b, mkP5r, mkBBp, mkBSp, mkBRp, mkSBp, mkSSp, mkSRp, mkRBp, mkRSp, mkRRp] = mkMatrix(mkSrc, mkLen, mkLb, mkBt, mkRt, mkEn)
mkSig1 = mkP1b - mkP1r
mkSig3 = mkP3b - mkP3r
mkSig5 = mkP5b - mkP5r
mkSigH = (mkSig1 + mkSig3 + mkSig5) / 3.0
mkN = mkSd
if mkState == 1
    mkN := mkBd
else if mkState == -1
    mkN := mkRd
mkPermission = mkPerm(mkSigH, mkN)
mkBestPath = mkPath(mkP1b, mkP1s, mkP1r)
mkDir = mkPermDir(mkPermission)

mkStratDir = 0
mkStratLabel = "No live setup"
if f2D_R or s22_U or s212_U or s312_U
    mkStratDir := 1
    mkStratLabel := f_liveCandleText()
else if f2U_R or s22_D or s212_D or s312_D
    mkStratDir := -1
    mkStratLabel := f_liveCandleText()
else
    int aSzMk = array.size(bars)
    int lastClosedMk = aSzMk - 1
    if not barstate.isconfirmed
        lastClosedMk := aSzMk - 2
    int backLim = math.min(20, math.max(0, lastClosedMk))
    if backLim > 0
        for b = 1 to backLim
            int k = lastClosedMk - b + 1
            if k >= 0 and k < aSzMk
                BarData ob = array.get(bars, k)
                if ob.f2D or ob.s22U or ob.s212U or ob.s312U
                    mkStratDir := 1
                    string activeSetupBull = f_setupTextFromFlags(ob.f2U, ob.f2D, ob.s22U, ob.s22D, ob.s212U, ob.s212D, ob.s312U, ob.s312D, ob.is2U, ob.is2D, ob.is1, ob.is3)
                    mkStratLabel := "Active " + activeSetupBull + " " + str.tostring(b) + "b"
                    break
                else if ob.f2U or ob.s22D or ob.s212D or ob.s312D
                    mkStratDir := -1
                    string activeSetupBear = f_setupTextFromFlags(ob.f2U, ob.f2D, ob.s22U, ob.s22D, ob.s212U, ob.s212D, ob.s312U, ob.s312D, ob.is2U, ob.is2D, ob.is1, ob.is3)
                    mkStratLabel := "Active " + activeSetupBear + " " + str.tostring(b) + "b"
                    break
mkHtfDir = -1
if isBullHTF
    mkHtfDir := 1
mkAlign = mkAlignTxt(mkStratDir, mkDir, mkHtfDir)
mkAlignColor = mkAlignBg(mkStratDir, mkDir, mkHtfDir)
mkMomentum = "Mixed"
if not na(mkSig1) and not na(mkSig5)
    if mkSig5 - mkSig1 >= 5
        mkMomentum := "Bull building"
    else if mkSig1 - mkSig5 >= 5 and mkSig1 > 0
        mkMomentum := "Bull fading"
    else if mkSig1 - mkSig5 >= 5
        mkMomentum := "Bear building"
    else if mkSig5 - mkSig1 >= 5 and mkSig1 < 0
        mkMomentum := "Bear fading"

float mkBullFlip = na
float mkBearFlip = na
if not na(mkSrc[mkLen]) and not na(mkBt) and not na(mkRt)
    mkBullFlip := mkSrc[mkLen] * (1.0 + mkBt / 100.0)
    mkBearFlip := mkSrc[mkLen] * (1.0 + mkRt / 100.0)

var line mkBullLine = na
var line mkBearLine = na
mkLS = line.style_dashed
if mkFLStyle == "Solid"
    mkLS := line.style_solid
else if mkFLStyle == "Dotted"
    mkLS := line.style_dotted
if barstate.islast
    int mkX1 = bar_index - mkFLBack
    if mkX1 < 0
        mkX1 := 0
    bool mkDoBull = mkEn and mkFL and mkFLMode != "Bear Only" and not na(mkBullFlip)
    bool mkDoBear = mkEn and mkFL and mkFLMode != "Bull Only" and not na(mkBearFlip)
    if mkDoBull
        if na(mkBullLine)
            mkBullLine := line.new(mkX1, mkBullFlip, bar_index, mkBullFlip, extend=extend.right, color=mkBullCol, width=mkFLW, style=mkLS)
        else
            line.set_xy1(mkBullLine, mkX1, mkBullFlip)
            line.set_xy2(mkBullLine, bar_index, mkBullFlip)
            line.set_extend(mkBullLine, extend.right)
            line.set_color(mkBullLine, mkBullCol)
            line.set_width(mkBullLine, mkFLW)
            line.set_style(mkBullLine, mkLS)
    else if not na(mkBullLine)
        line.delete(mkBullLine)
        mkBullLine := na
    if mkDoBear
        if na(mkBearLine)
            mkBearLine := line.new(mkX1, mkBearFlip, bar_index, mkBearFlip, extend=extend.right, color=mkBearCol, width=mkFLW, style=mkLS)
        else
            line.set_xy1(mkBearLine, mkX1, mkBearFlip)
            line.set_xy2(mkBearLine, bar_index, mkBearFlip)
            line.set_extend(mkBearLine, extend.right)
            line.set_color(mkBearLine, mkBearCol)
            line.set_width(mkBearLine, mkFLW)
            line.set_style(mkBearLine, mkLS)
    else if not na(mkBearLine)
        line.delete(mkBearLine)
        mkBearLine := na

// =====================================================
// 10) TABLES
// =====================================================
var table seqT = table.new(f_pos(seqPosInput), 6, 22, seqBg, color.gray, 1, color.gray, 1)
seqTS = f_size(seqSizeInput)
if barstate.islast
    table.clear(seqT, 0, 0, 5, 21)
if barstate.islast and showSeqTable
    int r = 0
    baseBg = color.new(color.black, 82)
    headerBg = color.new(color.blue, 72)
    subBg = color.new(color.black, 45)
    int seqLastCol = showBodyRuleCol ? 5 : 4
    table.cell(seqT, 0, r, "Strat Sequence C/R Engine | Body-Close | Lookback: " + str.tostring(seqLookback) + " bars", text_color=seqTxt, text_size=seqTS, bgcolor=headerBg)
    table.merge_cells(seqT, 0, r, seqLastCol, r)
    r += 1
    table.cell(seqT, 0, r, "Trade Behavior", text_color=seqTxt, text_size=seqTS, bgcolor=mkLabelBg)
    seqStratBg = mkDataBg
    if mkStratDir == 1
        seqStratBg := color.new(mkBullCol, 65)
    else if mkStratDir == -1
        seqStratBg := color.new(mkBearCol, 65)
    table.cell(seqT, 1, r, mkStratLabel, text_color=seqTxt, text_size=seqTS, bgcolor=seqStratBg)
    table.cell(seqT, 2, r, mkHtfTxt(mkHtfDir), text_color=seqTxt, text_size=seqTS, bgcolor=mkDataBg)
    table.cell(seqT, 3, r, mkAlign, text_color=seqTxt, text_size=seqTS, bgcolor=mkAlignColor)
    table.merge_cells(seqT, 3, r, seqLastCol, r)
    r += 1
    table.cell(seqT, 0, r, "Live Setup Candle", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    table.cell(seqT, 1, r, f_liveCandleText(), text_color=f_liveTextColor(f_liveBullNow(), f_liveBearNow()), text_size=seqTS, bgcolor=baseBg)
    table.merge_cells(seqT, 1, r, seqLastCol, r)
    r += 1
    table.cell(seqT, 0, r, "Live Sequence Watch", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    table.cell(seqT, 1, r, f_liveWatchText(), text_color=f_liveTextColor(f_liveBullNow(), f_liveBearNow()), text_size=seqTS, bgcolor=baseBg)
    table.merge_cells(seqT, 1, r, seqLastCol, r)
    r += 1
    table.cell(seqT, 0, r, "Body-Close Rule", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    table.cell(seqT, 1, r, f_liveRuleText(), text_color=seqTxt, text_size=seqTS, bgcolor=baseBg)
    table.merge_cells(seqT, 1, r, seqLastCol, r)
    r += 1
    table.cell(seqT, 0, r, "Strat Sequence", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    table.cell(seqT, 1, r, "Count", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    table.cell(seqT, 2, r, "Continue %", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    table.cell(seqT, 3, r, "Reclaim/Fail %", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    if showBodyRuleCol
        table.cell(seqT, 4, r, "Body Rule", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
        table.cell(seqT, 5, r, "Last", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    else
        table.cell(seqT, 4, r, "Last", text_color=seqTxt, text_size=seqTS, bgcolor=subBg)
    r += 1
    for seqId = 1 to 14
        [ct, co, re, la] = f_seqStats(seqId)
        bool showThis = f_seqEnabled(seqId)
        if hideRowsBelowMin and ct < seqMinCount
            showThis := false
        if showThis
            f_drawSeqRow(seqT, r, seqId, ct, co, re, la, seqTS, baseBg)
            r += 1

var table mkT = table.new(f_mkPos(mkPosInput), 4, 10, border_width=1)
mkTS = f_mkSize(mkSizeInput)
if mkEn and mkShow and barstate.islast
    table.clear(mkT, 0, 0, 3, 9)
    int mr = 0
    mkCell(mkT, 0, mr, "MARKOV PERMISSION", mkHeaderBg, mkTS)
    mkCell(mkT, 1, mr, "Bull", color.new(mkBullCol, 30), mkTS)
    mkCell(mkT, 2, mr, "Side", color.new(mkSideCol, 30), mkTS)
    mkCell(mkT, 3, mr, "Bear", color.new(mkBearCol, 30), mkTS)
    mr += 1
    mkCell(mkT, 0, mr, "State / Return", mkLabelBg, mkTS)
    mkCell(mkT, 1, mr, mkTxt(mkState), mkBgState(mkState), mkTS)
    mkCell(mkT, 2, mr, mkFmt(mkRet), mkDataBg, mkTS)
    mkCell(mkT, 3, mr, "Sample Size " + str.tostring(mkN), mkDataBg, mkTS)
    mr += 1
    if mkShowFlip
        mkCell(mkT, 0, mr, "Flip Levels", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, mkPx(mkBullFlip), color.new(mkBullCol, 70), mkTS)
        mkCell(mkT, 2, mr, "Src " + mkPx(mkSrc), mkDataBg, mkTS)
        mkCell(mkT, 3, mr, mkPx(mkBearFlip), color.new(mkBearCol, 70), mkTS)
        mr += 1
    mkCell(mkT, 0, mr, "1-Bar Prob", mkLabelBg, mkTS)
    mkCell(mkT, 1, mr, mkFmt(mkP1b), color.new(mkBullCol, 75), mkTS)
    mkCell(mkT, 2, mr, mkFmt(mkP1s), color.new(mkSideCol, 75), mkTS)
    mkCell(mkT, 3, mr, mkFmt(mkP1r), color.new(mkBearCol, 75), mkTS)
    mr += 1
    mkCell(mkT, 0, mr, "Signal / Path", mkLabelBg, mkTS)
    sig1Bg = mkDataBg
    if mkSig1 > 0
        sig1Bg := color.new(mkBullCol, 65)
    else if mkSig1 < 0
        sig1Bg := color.new(mkBearCol, 65)
    mkCell(mkT, 1, mr, mkFmt(mkSig1), sig1Bg, mkTS)
    mkCell(mkT, 2, mr, mkBestPath, mkBgPath(mkBestPath), mkTS)
    mkCell(mkT, 3, mr, "H " + mkFmt(mkSigH), mkDataBg, mkTS)
    mr += 1
    if mkShowFc
        mkCell(mkT, 0, mr, "3B / 5B Signal", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, "3B " + mkFmt(mkSig3), mkDataBg, mkTS)
        mkCell(mkT, 2, mr, "5B " + mkFmt(mkSig5), mkDataBg, mkTS)
        mkCell(mkT, 3, mr, mkMomentum, mkDataBg, mkTS)
        mr += 1
    if mkShowMx
        mkCell(mkT, 0, mr, "Matrix %", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, "Bull→ " + mkFmt(mkBBp) + "/" + mkFmt(mkBSp) + "/" + mkFmt(mkBRp), color.new(mkBullCol, 80), mkTS)
        mkCell(mkT, 2, mr, "Side→ " + mkFmt(mkSBp) + "/" + mkFmt(mkSSp) + "/" + mkFmt(mkSRp), color.new(mkSideCol, 80), mkTS)
        mkCell(mkT, 3, mr, "Bear→ " + mkFmt(mkRBp) + "/" + mkFmt(mkRSp) + "/" + mkFmt(mkRRp), color.new(mkBearCol, 80), mkTS)
        mr += 1
    mkCell(mkT, 0, mr, "Permission", mkLabelBg, mkTS)
    permBg = color.new(mkSideCol, 60)
    if str.contains(mkPermission, "Long")
        permBg := color.new(mkBullCol, 55)
    else if str.contains(mkPermission, "Short")
        permBg := color.new(mkBearCol, 55)
    mkCell(mkT, 1, mr, mkPermission, permBg, mkTS)
    mkCell(mkT, 2, mr, "Used " + str.tostring(mkUsed), mkDataBg, mkTS)
    mkCell(mkT, 3, mr, "T " + mkFmt(mkBt), mkDataBg, mkTS)
    mr += 1
    if mkShowAlign
        stratBg = mkDataBg
        if mkStratDir == 1
            stratBg := color.new(mkBullCol, 65)
        else if mkStratDir == -1
            stratBg := color.new(mkBearCol, 65)
        mkCell(mkT, 0, mr, "Trade Behavior", mkLabelBg, mkTS)
        mkCell(mkT, 1, mr, mkStratLabel, stratBg, mkTS)
        mkCell(mkT, 2, mr, mkHtfTxt(mkHtfDir), mkDataBg, mkTS)
        mkCell(mkT, 3, mr, mkAlign, mkAlignColor, mkTS)
else if barstate.islast
    table.clear(mkT, 0, 0, 3, 9)

// =====================================================
// 11) AUDIT LABELS - LIGHTWEIGHT FIRST DRAFT
// =====================================================
auditOffsetNow = ta.atr(14) * auditOffsetAtr
var array<label> auditLabs = array.new<label>()
if barstate.islast and showAudit
    oldN = array.size(auditLabs)
    if oldN > 0
        for d = 0 to oldN - 1
            label.delete(array.get(auditLabs, d))
    array.clear(auditLabs)
    int aSzAudit = array.size(bars)
    int lastClosedAudit = aSzAudit - 1
    if not barstate.isconfirmed
        lastClosedAudit := aSzAudit - 2
    int stAudit = math.max(0, lastClosedAudit - auditBars)
    if lastClosedAudit > stAudit
        for i = stAudit to lastClosedAudit - 1
            BarData curA = array.get(bars, i)
            BarData decA = array.get(bars, i + 1)
            if curA.f2U
                string txtA = "F2U-x R"
                if decA.c < curA.l
                    txtA := "F2U-x C"
                label labA = label.new(decA.idx, decA.h + auditOffsetNow, txtA, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=f_size(auditSizeInput))
                array.push(auditLabs, labA)
            if curA.f2D
                string txtB = "F2D-x R"
                if decA.c > curA.h
                    txtB := "F2D-x C"
                label labB = label.new(decA.idx, decA.l - auditOffsetNow, txtB, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=f_size(auditSizeInput))
                array.push(auditLabs, labB)
````

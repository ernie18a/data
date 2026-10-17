# Cycles Divider

- url: https://www.tradingview.com/script/ev6atOGi-Cycles-Divider/
- type: indicator
- pine_id: PUB;8bd98ca71bcc46a98228182150292831
- version: 1.0

## Description

Cycles divider draws vertical lines that divide the chart into 4 cycles on each cycle for the QT

## Source Code

````pine
// This Pine Script® code 
// © Gauntlet man

//@version=6
indicator(title = "Cycles Divider", shorttitle = "Cycles Divider", overlay = true, explicit_plot_zorder = true, max_labels_count = 500, max_lines_count = 500)

// ============================================================================
// ===================== MASTER CYCLE TOGGLES (TOP) ===========================
// ============================================================================
var string grpM = "★ Master Cycle Toggles"
ms_4Y  = input.bool(true, "4Y Divider", group=grpM, inline="h1")
ms_1Y  = input.bool(true, "1Y Divider", group=grpM, inline="h1")
ms_3M  = input.bool(true, "3M Divider", group=grpM, inline="h2")
ms_W   = input.bool(true, "W Cycle",    group=grpM, inline="i1")
ms_D   = input.bool(true, "D Cycle",    group=grpM, inline="i1")
ms_6H  = input.bool(true, "6H Cycle",   group=grpM, inline="i2")
ms_90m = input.bool(true, "90m Cycle",  group=grpM, inline="i2")
tz = input.string("America/New_York", "Reference Timezone", group=grpM)

styOpt = "Solid"
fStyle(s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
fSize(s)  => s == "Auto" ? size.auto : s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

// ============================================================================
// ===================== HTF: 4Y (highest, single variant) ====================
// ============================================================================
var string g4 = "[4Y] Divider"
tf4   = input.string("", "Show on TF=> (blank=all D/W/M)", group=g4)
past4 = input.int(2, "Past cycles", minval=0, maxval=50, group=g4, inline="c4")
fut4  = input.int(1, "Future cycles", minval=0, maxval=50, group=g4, inline="c4")
sty4  = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=g4, inline="l4")
wid4  = input.int(1, "Thick", minval=1, maxval=5, group=g4, inline="l4")
col4  = input.color(#ff0014, "Line Col", group=g4, inline="l4")
tcol4 = input.color(#ff0014, "Text Col", group=g4, inline="l4")
txtEn4 = input.bool(true, "Text", group=g4, inline="t4")
txtSz4 = input.string("Normal", "Size", ["Auto","Tiny","Small","Normal","Large","Huge"], group=g4, inline="t4")
off4  = input.float(1.0, "Label Offset %", step=0.25, group=g4)

// ============================================================================
// ===================== HTF: 1Y (4 variants 1Y..4Y) ==========================
// ============================================================================
var string g1 = "[1Y] Divider"
tf1   = input.string("", "Show on TF=> (blank=all D/W/M)", group=g1)
past1 = input.int(4, "Past cycles", minval=0, maxval=100, group=g1, inline="c1")
fut1  = input.int(2, "Future cycles", minval=0, maxval=100, group=g1, inline="c1")
sty1  = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=g1, inline="s1")
wid1  = input.int(1, "Thick", minval=1, maxval=5, group=g1, inline="s1")
txtEn1 = input.bool(true, "Text", group=g1, inline="s1")
txtSz1 = input.string("Normal", "Size", ["Auto","Tiny","Small","Normal","Large","Huge"], group=g1, inline="s1")
off1  = input.float(1.0, "Label Offset %", step=0.25, group=g1)
c1l1 = input.color(#ff0014, "1Y line", group=g1, inline="v1a")
c1t1 = input.color(#ff0014, "1Y text", group=g1, inline="v1a")
c1l2 = input.color(#000000, "2Y line", group=g1, inline="v1b")
c1t2 = input.color(#000000, "2Y text", group=g1, inline="v1b")
c1l3 = input.color(#000000, "3Y line", group=g1, inline="v1c")
c1t3 = input.color(#000000, "3Y text", group=g1, inline="v1c")
c1l4 = input.color(#000000, "4Y line", group=g1, inline="v1d")
c1t4 = input.color(#000000, "4Y text", group=g1, inline="v1d")

// ============================================================================
// ===================== HTF: 3M (4 variants 1Q..4Q) ==========================
// ============================================================================
var string g3 = "[3M] Divider"
tf3   = input.string("", "Show on TF=> (blank=all D/W/M)", group=g3)
past3 = input.int(8, "Past cycles", minval=0, maxval=200, group=g3, inline="c3")
fut3  = input.int(4, "Future cycles", minval=0, maxval=200, group=g3, inline="c3")
sty3  = input.string("Dotted", "Line Style", options=["Solid","Dashed","Dotted"], group=g3, inline="s3")
wid3  = input.int(1, "Thick", minval=1, maxval=5, group=g3, inline="s3")
txtEn3 = input.bool(true, "Text", group=g3, inline="s3")
txtSz3 = input.string("Normal", "Size", ["Auto","Tiny","Small","Normal","Large","Huge"], group=g3, inline="s3")
idx3  = input.bool(false, "Show Index Text", group=g3)
off3  = input.float(1.0, "Label Offset %", step=0.25, group=g3)
c3l1 = input.color(#ff0014, "1Q line", group=g3, inline="v3a")
c3t1 = input.color(#ff0014, "1Q text", group=g3, inline="v3a")
c3l2 = input.color(#000000, "2Q line", group=g3, inline="v3b")
c3t2 = input.color(#000000, "2Q text", group=g3, inline="v3b")
c3l3 = input.color(#000000, "3Q line", group=g3, inline="v3c")
c3t3 = input.color(#000000, "3Q text", group=g3, inline="v3c")
c3l4 = input.color(#000000, "4Q line", group=g3, inline="v3d")
c3t4 = input.color(#000000, "4Q text", group=g3, inline="v3d")

// ============================================================================
// ===================== INTRADAY: W (4 variants, week-of-month) ==============
// ============================================================================
var string gW = "W Cycle"
tfW   = input.string("", "Show on TF=> (blank=all intraday)", group=gW)
pastW = input.int(4, "Past cycles", minval=0, maxval=52, group=gW, inline="cw")
futW  = input.int(1, "Future cycles", minval=0, maxval=52, group=gW, inline="cw")
lblW  = input.bool(true, "Show Label", group=gW, inline="sw")
widW  = input.int(1, "Thick", minval=1, maxval=5, group=gW, inline="sw")
styW  = input.string("Dotted", "Style", ["Solid","Dashed","Dotted"], group=gW, inline="sw")
tszW  = input.string("Normal", "Size", ["Tiny","Small","Normal","Large","Huge"], group=gW, inline="sw")
offW  = input.float(0.1, "Label Gap (×range)", step=0.05, minval=0, group=gW)
cWl1 = input.color(#ff0014, "W1 line", group=gW, inline="vwa")
cWt1 = input.color(#ff0014, "W1 text", group=gW, inline="vwa")
cWl2 = input.color(#000000, "W2 line", group=gW, inline="vwb")
cWt2 = input.color(#000000, "W2 text", group=gW, inline="vwb")
cWl3 = input.color(#000000, "W3 line", group=gW, inline="vwc")
cWt3 = input.color(#000000, "W3 text", group=gW, inline="vwc")
cWl4 = input.color(#000000, "W4 line", group=gW, inline="vwd")
cWt4 = input.color(#000000, "W4 text", group=gW, inline="vwd")

// ============================================================================
// ===================== INTRADAY: D (7 variants, day-of-week) ================
// ============================================================================
var string gD = "D Cycle"
tfD   = input.string("", "Show on TF=> (blank=all intraday)", group=gD)
pastD = input.int(7, "Past cycles", minval=0, maxval=100, group=gD, inline="cd")
futD  = input.int(1, "Future cycles", minval=0, maxval=100, group=gD, inline="cd")
lblD  = input.bool(true, "Show Label", group=gD, inline="sd")
widD  = input.int(1, "Thick", minval=1, maxval=5, group=gD, inline="sd")
styD  = input.string("Dotted", "Style", ["Solid","Dashed","Dotted"], group=gD, inline="sd")
tszD  = input.string("Normal", "Size", ["Tiny","Small","Normal","Large","Huge"], group=gD, inline="sd")
offD  = input.float(0.1, "Label Gap (×range)", step=0.05, minval=0, group=gD)
cDl1 = input.color(#ff0014,     "D1 Sun line", group=gD, inline="vda")
cDt1 = input.color(#ff0014,     "text", group=gD, inline="vda")
cDl2 = input.color(#000000,  "D2 Mon line", group=gD, inline="vdb")
cDt2 = input.color(#000000,  "text", group=gD, inline="vdb")
cDl3 = input.color(#000000,  "D3 Tue line", group=gD, inline="vdc")
cDt3 = input.color(#000000,  "text", group=gD, inline="vdc")
cDl4 = input.color(#000000,    "D4 Wed line", group=gD, inline="vdd")
cDt4 = input.color(#000000,    "text", group=gD, inline="vdd")
cDl5 = input.color(#000000,     "D5 Thu line", group=gD, inline="vde")
cDt5 = input.color(#000000,     "text", group=gD, inline="vde")
cDl6 = input.color(#000000,     "D6 Fri line", group=gD, inline="vdf")
cDt6 = input.color(#000000,     "text", group=gD, inline="vdf")
cDl7 = input.color(#000000,   "D7 Sat line", group=gD, inline="vdg")
cDt7 = input.color(#000000,   "text", group=gD, inline="vdg")

// ============================================================================
// ===================== INTRADAY: 6H (4 variants per day) ====================
// ============================================================================
var string gH = "6H Cycle"
tfH   = input.string("", "Show on TF=> (blank=all intraday)", group=gH)
pastH = input.int(8, "Past cycles", minval=0, maxval=200, group=gH, inline="ch")
futH  = input.int(2, "Future cycles", minval=0, maxval=200, group=gH, inline="ch")
lblH  = input.bool(true, "Show Label", group=gH, inline="shh")
widH  = input.int(1, "Thick", minval=1, maxval=5, group=gH, inline="shh")
styH  = input.string("Dotted", "Style", ["Solid","Dashed","Dotted"], group=gH, inline="shh")
tszH  = input.string("Small", "Size", ["Tiny","Small","Normal","Large","Huge"], group=gH, inline="shh")
offH  = input.float(0.1, "Label Gap (×range)", step=0.05, minval=0, group=gH)
cHl1 = input.color(#ff0014, "6H1 (18-00) line", group=gH, inline="vha")
cHt1 = input.color(#ff0014, "text", group=gH, inline="vha")
cHl2 = input.color(#000000,   "6H2 (00-06) line", group=gH, inline="vhb")
cHt2 = input.color(#000000,   "text", group=gH, inline="vhb")
cHl3 = input.color(#000000,   "6H3 (06-12) line", group=gH, inline="vhc")
cHt3 = input.color(#000000,   "text", group=gH, inline="vhc")
cHl4 = input.color(#000000,"6H4 (12-18) line", group=gH, inline="vhd")
cHt4 = input.color(#000000,"text", group=gH, inline="vhd")

// ============================================================================
// ===================== INTRADAY: 90m (4 variants per 6H block) ==============
// ============================================================================
var string gMin = "90m Cycle"
tfMin = input.string("", "Show on TF=> (blank=all intraday)", group=gMin)
pastMin = input.int(16, "Past cycles", minval=0, maxval=300, group=gMin, inline="cm")
futMin  = input.int(4, "Future cycles", minval=0, maxval=300, group=gMin, inline="cm")
lblMin  = input.bool(true, "Show Label", group=gMin, inline="sm")
widMin  = input.int(1, "Thick", minval=1, maxval=5, group=gMin, inline="sm")
styMin  = input.string("Dotted", "Style", ["Solid","Dashed","Dotted"], group=gMin, inline="sm")
tszMin  = input.string("Tiny", "Size", ["Tiny","Small","Normal","Large","Huge"], group=gMin, inline="sm")
offMin  = input.float(0.1, "Label Gap (×range)", step=0.05, minval=0, group=gMin)
cMl1 = input.color(#ff0014, "90m1 line", group=gMin, inline="vma")
cMt1 = input.color(#ff0014, "text", group=gMin, inline="vma")
cMl2 = input.color(#000000,    "90m2 line", group=gMin, inline="vmb")
cMt2 = input.color(#000000,    "text", group=gMin, inline="vmb")
cMl3 = input.color(#000000,    "90m3 line", group=gMin, inline="vmc")
cMt3 = input.color(#000000,    "text", group=gMin, inline="vmc")
cMl4 = input.color(#000000,  "90m4 line", group=gMin, inline="vmd")
cMt4 = input.color(#000000,  "text", group=gMin, inline="vmd")

// Variant color lookup helpers (line + text) by 1-based index
wLineCol(int n) => n==1?cWl1 : n==2?cWl2 : n==3?cWl3 : cWl4
wTextCol(int n) => n==1?cWt1 : n==2?cWt2 : n==3?cWt3 : cWt4
dLineCol(int n) => n==1?cDl1 : n==2?cDl2 : n==3?cDl3 : n==4?cDl4 : n==5?cDl5 : n==6?cDl6 : cDl7
dTextCol(int n) => n==1?cDt1 : n==2?cDt2 : n==3?cDt3 : n==4?cDt4 : n==5?cDt5 : n==6?cDt6 : cDt7
hLineCol(int n) => n==1?cHl1 : n==2?cHl2 : n==3?cHl3 : cHl4
hTextCol(int n) => n==1?cHt1 : n==2?cHt2 : n==3?cHt3 : cHt4
mLineCol(int n) => n==1?cMl1 : n==2?cMl2 : n==3?cMl3 : cMl4
mTextCol(int n) => n==1?cMt1 : n==2?cMt2 : n==3?cMt3 : cMt4
y1LineCol(int n) => n==1?c1l1 : n==2?c1l2 : n==3?c1l3 : c1l4
y1TextCol(int n) => n==1?c1t1 : n==2?c1t2 : n==3?c1t3 : c1t4
q3LineCol(int n) => n==1?c3l1 : n==2?c3l2 : n==3?c3l3 : c3l4
q3TextCol(int n) => n==1?c3t1 : n==2?c3t2 : n==3?c3t3 : c3t4

// ============================================================================
// ===================== HELPERS & VARIANT INDEXERS ===========================
// ============================================================================
isDWM = timeframe.isdwm
isIntra = timeframe.isminutes or timeframe.isseconds

tfOK_HTF(_list) => not isDWM ? false : str.length(_list) == 0 ? true : str.split(_list, "|").includes(timeframe.period)
tfOK_Intra(_list) => not isIntra ? false : str.length(_list) == 0 ? true : str.split(_list, "|").includes(timeframe.period)

ok4 = ms_4Y and tfOK_HTF(tf4)
ok1 = ms_1Y and tfOK_HTF(tf1)
ok3 = ms_3M and tfOK_HTF(tf3)
okW = ms_W   and tfOK_Intra(tfW)
okD = ms_D   and tfOK_Intra(tfD)
okH = ms_6H  and tfOK_Intra(tfH)
okM = ms_90m and tfOK_Intra(tfMin)

// Variant indexers (1-based) from a given time (ms) in NY:
varY(int t) => ((year(t, tz) - 2019) % 4 + 4) % 4 + 1            // 1Y: 1..4
varQ(int t) => math.floor((month(t, tz) - 1) / 3) + 1            // 3M: 1..4
varW(int t) =>                                                   // W: 1..4, week belongs to
    midWeek = t + 3 * 86400000                                   // the month of its mid-week
    raw = math.floor((dayofmonth(midWeek, tz) - 1) / 7) + 1      // 1..5 (5 = 5th week)
    (raw - 1) % 4 + 1                                            // 5th week wraps to W(1)
varD(int t) =>                                                  // D: trading day Mon=1..Fri=5
    shifted = t + 6 * 3600000                                    // 18:00 open -> +6h to next midnight
    tdow = dayofweek(shifted, tz)                                // 1=Sun..7=Sat of the trading day
    // map to Mon=1..Fri=5; Sat(7)/Sun(1) sessions don't exist -> 0 (skip)
    tdow == dayofweek.monday ? 1 : tdow == dayofweek.tuesday ? 2 : tdow == dayofweek.wednesday ? 3 : tdow == dayofweek.thursday ? 4 : tdow == dayofweek.friday ? 5 : 0
varH(int t) =>                                                   // 6H: 1..4 from 18:00
    h = hour(t, tz)
    h >= 18 ? 1 : h >= 0 and h < 6 ? 2 : h >= 6 and h < 12 ? 3 : 4
varM(int t) =>                                                   // 90m: 1..4 within 6H block
    raw = (hour(t, tz) * 60 + minute(t, tz)) - 18 * 60          // minutes since 18:00 (may be negative)
    mins = (raw % 1440 + 1440) % 1440                            // force into 0..1439 (Pine % is truncated)
    math.floor((mins % 360) / 90) + 1

MS_90m = 90 * 60 * 1000
MS_6H  = 6 * 60 * 60 * 1000
MS_D   = 24 * 60 * 60 * 1000
MS_W   = 7 * 24 * 60 * 60 * 1000

// ============================================================================
// ===================== HTF DRAWING (variant-aware) ==========================
// ============================================================================
var int curYr = year(timenow, tz)
f_4yStart(int y) => 2019 + 4 * math.floor((y - 2019) / 4.0)

// segment storage
var array<int> s4t0 = array.new<int>()
var array<int> s4t1 = array.new<int>()
var array<float> s4hi = array.new<float>()
var array<int> s1t0 = array.new<int>()
var array<int> s1t1 = array.new<int>()
var array<float> s1hi = array.new<float>()
var array<int> s3t0 = array.new<int>()
var array<int> s3t1 = array.new<int>()
var array<float> s3hi = array.new<float>()

if barstate.isfirst
    if ok4
        cs = f_4yStart(curYr)
        for k = -past4 to fut4
            s4t0.push(timestamp(tz, cs + 4*k, 1, 1, 0, 0, 0))
            s4t1.push(timestamp(tz, cs + 4*(k+1), 1, 1, 0, 0, 0))
            s4hi.push(na)
    if ok1
        for k = -past1 to fut1
            s1t0.push(timestamp(tz, curYr + k, 1, 1, 0, 0, 0))
            s1t1.push(timestamp(tz, curYr + k + 1, 1, 1, 0, 0, 0))
            s1hi.push(na)
    if ok3
        cq = math.floor((month(timenow, tz) - 1) / 3)
        bq = curYr * 4 + cq
        for k = -past3 to fut3
            qa = bq + k
            y0 = math.floor(qa / 4)
            m0 = ((qa % 4 + 4) % 4) * 3 + 1
            qa1 = qa + 1
            y1 = math.floor(qa1 / 4)
            m1 = ((qa1 % 4 + 4) % 4) * 3 + 1
            // Anchor the quarter line on the FIRST DAY's candle. A futures daily candle
            // opens at 18:00 the PREVIOUS evening, so to land the line on the Jul-1 candle
            // we anchor at Jun-30 18:00 (i.e. 18:00 the day before day 1). Using day 1 at
            // 00:00 or 18:00 falls into the next day's candle (the 2/x shift you saw).
            s3t0.push(timestamp(tz, y0, m0, 0, 18, 0, 0))
            s3t1.push(timestamp(tz, y1, m1, 0, 18, 0, 0))
            s3hi.push(na)

accumHigh(array<int> t0a, array<int> t1a, array<float> hia) =>
    if array.size(t0a) > 0
        for i = 0 to array.size(t0a) - 1
            if time >= array.get(t0a, i) and time < array.get(t1a, i)
                cur = array.get(hia, i)
                array.set(hia, i, na(cur) ? high : math.max(cur, high))
accumHigh(s4t0, s4t1, s4hi)
accumHigh(s1t0, s1t1, s1hi)
accumHigh(s3t0, s3t1, s3hi)

// FIX: HTF dividers are now anchored at low->high (two DIFFERENT prices) so
// extend.both makes them VERTICAL. The original anchored close->close (same
// price both ends), which with extend.both rendered as a stray HORIZONTAL line
// across the chart at the close price (the red/black line). low->high removes it
// while keeping the vertical divider exactly where it belongs.
drawHTF_4Y() =>
    if ok4 and barstate.islastconfirmedhistory and array.size(s4t0) > 0
        refH = high
        for i = 0 to array.size(s4t0) - 1
            if timenow >= array.get(s4t0,i) and timenow < array.get(s4t1,i)
                refH := nz(array.get(s4hi,i), high)
        refY = refH + refH * (off4/100)
        for i = 0 to array.size(s4t0) - 1
            t0 = array.get(s4t0,i)
            t1 = array.get(s4t1,i)
            line.new(t0, low, t0, high, xloc=xloc.bar_time, extend=extend.both, color=col4, style=fStyle(sty4), width=wid4)
            if txtEn4
                isFut = t0 > timenow
                segH = nz(array.get(s4hi,i), high)
                yP = isFut ? refY : segH + segH*(off4/100)
                label.new(int((t0+t1)/2), yP, "4Y", xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.blue,100), style=label.style_none, textcolor=tcol4, size=fSize(txtSz4))
        line.new(array.get(s4t1,array.size(s4t1)-1),low,array.get(s4t1,array.size(s4t1)-1),high, xloc=xloc.bar_time, extend=extend.both, color=col4, style=fStyle(sty4), width=wid4)

drawHTF_1Y() =>
    if ok1 and barstate.islastconfirmedhistory and array.size(s1t0) > 0
        refH = high
        for i = 0 to array.size(s1t0) - 1
            if timenow >= array.get(s1t0,i) and timenow < array.get(s1t1,i)
                refH := nz(array.get(s1hi,i), high)
        refY = refH + refH*(off1/100)
        for i = 0 to array.size(s1t0) - 1
            t0 = array.get(s1t0,i)
            t1 = array.get(s1t1,i)
            v = varY(t0 + 5*86400000)
            line.new(t0, low, t0, high, xloc=xloc.bar_time, extend=extend.both, color=y1LineCol(v), style=fStyle(sty1), width=wid1)
            if txtEn1
                isFut = t0 > timenow
                segH = nz(array.get(s1hi,i), high)
                yP = isFut ? refY : segH + segH*(off1/100)
                label.new(int((t0+t1)/2), yP, str.format("{0}Y", v), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.blue,100), style=label.style_none, textcolor=y1TextCol(v), size=fSize(txtSz1))
        line.new(array.get(s1t1,array.size(s1t1)-1),low,array.get(s1t1,array.size(s1t1)-1),high, xloc=xloc.bar_time, extend=extend.both, color=y1LineCol(varY(array.get(s1t0,array.size(s1t0)-1)+5*86400000)), style=fStyle(sty1), width=wid1)

drawHTF_3M() =>
    if ok3 and barstate.islastconfirmedhistory and array.size(s3t0) > 0
        refH = high
        for i = 0 to array.size(s3t0) - 1
            if timenow >= array.get(s3t0,i) and timenow < array.get(s3t1,i)
                refH := nz(array.get(s3hi,i), high)
        refY = refH + refH*(off3/100)
        gi = 0
        for i = 0 to array.size(s3t0) - 1
            t0 = array.get(s3t0,i)
            t1 = array.get(s3t1,i)
            v = varQ(t0 + 5*86400000)
            line.new(t0, low, t0, high, xloc=xloc.bar_time, extend=extend.both, color=q3LineCol(v), style=fStyle(sty3), width=wid3)
            if txtEn3
                gi += 1
                idxTxt = idx3 ? " - (" + str.tostring(gi) + ")" : ""
                isFut = t0 > timenow
                segH = nz(array.get(s3hi,i), high)
                yP = isFut ? refY : segH + segH*(off3/100)
                label.new(int((t0+t1)/2), yP, str.format("{0}Q{1}", v, idxTxt), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.blue,100), style=label.style_none, textcolor=q3TextCol(v), size=fSize(txtSz3))
        line.new(array.get(s3t1,array.size(s3t1)-1),low,array.get(s3t1,array.size(s3t1)-1),high, xloc=xloc.bar_time, extend=extend.both, color=q3LineCol(varQ(array.get(s3t0,array.size(s3t0)-1)+5*86400000)), style=fStyle(sty3), width=wid3)

drawHTF_4Y()
drawHTF_1Y()
drawHTF_3M()

// ============================================================================
// ===================== INTRADAY ENGINE (variant-aware) ======================
// ============================================================================
shifted = time + 6 * 3600000
sessDay = year(shifted, tz) * 10000 + month(shifted, tz) * 100 + dayofmonth(shifted, tz)
dKey = sessDay
wShiftedDow = dayofweek(shifted, tz)
wDaysFromMon = (wShiftedDow + 5) % 7
wMondayShifted = shifted - wDaysFromMon * 86400000
wKey = year(wMondayShifted, tz) * 10000 + month(wMondayShifted, tz) * 100 + dayofmonth(wMondayShifted, tz)

// ----- 18:00-anchored block grid for 6H and 90m (DST/gap/bar-stamp proof) -----
_t18today = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 18, 0, 0)
day18 = _t18today <= time ? _t18today : timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz) - 1, 18, 0, 0)
_minsSince = math.floor((time - day18) / 60000)
hBlk = math.floor(_minsSince / 360)
mBlk = math.floor(_minsSince / 90)
schH_curOpen = day18 + hBlk * 360 * 60000
schM_curOpen = day18 + mBlk * 90  * 60000
hKey = schH_curOpen
mKeyV = schM_curOpen
schD_curOpen = day18

type CycleState
    array<line> lines
    array<label> lbls
    array<line> futLines
    array<label> futLbls
    array<int> startBars
    array<int> startTimes
    array<float> segHighs
    int startBar = na

newState() => CycleState.new(array.new<line>(), array.new<label>(), array.new<line>(), array.new<label>(), array.new<int>(), array.new<int>(), array.new<float>())
var wS = newState()
var dS = newState()
var hS = newState()
var mS = newState()

nextOpen(int openT, string cyc, int ms) =>
    int result = openT + ms
    if cyc == "D"
        result := timestamp(tz, year(openT, tz), month(openT, tz), dayofmonth(openT, tz) + 1, 18, 0, 0)
    else if cyc == "W"
        result := timestamp(tz, year(openT, tz), month(openT, tz), dayofmonth(openT, tz) + 7, 18, 0, 0)
    result

isTradingTime(int t) =>
    int dow = dayofweek(t, tz)
    int h = hour(t, tz)
    bool trading = true
    if dow == dayofweek.saturday
        trading := false
    else if dow == dayofweek.sunday
        trading := h >= 18
    else if dow == dayofweek.friday
        trading := h < 17
    else
        trading := h != 17
    trading

tradingBarsTo(int nowT, int futT, int tfMs) =>
    int cnt = 0
    if futT > nowT
        int t = nowT
        int guard = 0
        while t < futT and guard < 5000
            if isTradingTime(t)
                cnt += 1
            t += tfMs
            guard += 1
    cnt

var line g_axisAnchor = na

drawIntra(_slotNow, _slotPrev, _show, _showLbl, _past, _fut, _ms, _firstFut, _schedOpen, _width, _styleStr, _tszStr, _gap, _cyc, CycleState st) =>
    int _localMaxFut = na
    newCycle = not na(_slotPrev) and _slotNow != _slotPrev
    if _show
        if newCycle
            int vNow = _cyc == "W" ? varW(_schedOpen) : _cyc == "D" ? varD(_schedOpen) : _cyc == "6H" ? varH(_schedOpen) : varM(_schedOpen)
            if not (_cyc == "D" and vNow == 0)
                color lc = _cyc == "W" ? wLineCol(vNow) : _cyc == "D" ? dLineCol(vNow) : _cyc == "6H" ? hLineCol(vNow) : mLineCol(vNow)
                ln = line.new(_schedOpen, low, _schedOpen, high, xloc=xloc.bar_time, extend=extend.both, color=lc, width=_width, style=fStyle(_styleStr))
                st.lines.push(ln)
                st.startBars.push(bar_index)
                st.startTimes.push(_schedOpen)
                st.segHighs.push(high)
                if _showLbl
                    color tc = _cyc == "W" ? wTextCol(vNow) : _cyc == "D" ? dTextCol(vNow) : _cyc == "6H" ? hTextCol(vNow) : mTextCol(vNow)
                    string lt = _cyc == "W" ? str.format("W ({0})", vNow) : _cyc == "D" ? str.format("D ({0})", vNow) : _cyc == "6H" ? str.format("6H ({0})", vNow) : str.format("90m ({0})", vNow)
                    lbl = label.new(bar_index, high, lt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=tc, color=color.new(color.black,100), size=fSize(_tszStr))
                    st.lbls.push(lbl)
                while st.lines.size() > _past + 1
                    line.delete(st.lines.shift())
                    st.startBars.shift()
                    st.startTimes.shift()
                    st.segHighs.shift()
                while st.lbls.size() > _past + 1
                    label.delete(st.lbls.shift())
                st.startBar := bar_index
        else
            if st.segHighs.size() > 0
                li = st.segHighs.size() - 1
                st.segHighs.set(li, math.max(st.segHighs.get(li), high))

        if barstate.islast
            float curSegH = st.segHighs.size() > 0 ? st.segHighs.get(st.segHighs.size()-1) : high
            float curRange = math.max(curSegH * 0.001, syminfo.mintick * 10)
            float curYPos = curSegH + curRange * (_gap / 0.1) * 0.1
            int _activeRightB = na   // bar position of the first future divider = active cycle's right edge
            if _fut > 0
                while st.futLines.size() > 0
                    line.delete(st.futLines.shift())
                while st.futLbls.size() > 0
                    label.delete(st.futLbls.shift())
                int _tfMs = math.max(timeframe.in_seconds() * 1000, 1)
                int _lbi  = bar_index
                int prevOpen = _firstFut
                bool _useTime = _cyc == "W" or _cyc == "D"
                array<int>    _fX0  = array.new<int>()
                array<int>    _fX1  = array.new<int>()
                array<string> _fTxt = array.new<string>()
                array<color>  _fTcol = array.new<color>()
                for k = 0 to _fut - 1
                    int ft  = prevOpen
                    int ft2 = nextOpen(ft, _cyc, _ms)
                    int _guard = 0
                    while not isTradingTime(ft) and _guard < 60
                        ft  := ft2
                        ft2 := nextOpen(ft, _cyc, _ms)
                        _guard += 1
                    int vf = _cyc == "W" ? varW(ft) : _cyc == "D" ? varD(ft) : _cyc == "6H" ? varH(ft) : varM(ft)
                    if not (_cyc == "D" and vf == 0)
                        color lcf = _cyc == "W" ? wLineCol(vf) : _cyc == "D" ? dLineCol(vf) : _cyc == "6H" ? hLineCol(vf) : mLineCol(vf)
                        int x0 = _useTime ? ft  : (_lbi + math.max(math.min(tradingBarsTo(time, ft,  _tfMs), 490), 1))
                        int x1 = _useTime ? ft2 : (_lbi + math.max(math.min(tradingBarsTo(time, ft2, _tfMs), 490), 1))
                        // remember the FIRST future divider's BAR position — it's the
                        // right edge of the current active cycle, used to center its label.
                        if na(_activeRightB)
                            _activeRightB := _useTime ? (_lbi + math.max(math.min(tradingBarsTo(time, ft, _tfMs), 490), 1)) : x0
                        fl = _useTime ? line.new(x0, low, x0, high, xloc=xloc.bar_time, extend=extend.both, color=lcf, width=_width, style=fStyle(_styleStr)) : line.new(x0, low, x0, high, xloc=xloc.bar_index, extend=extend.both, color=lcf, width=_width, style=fStyle(_styleStr))
                        st.futLines.push(fl)
                        if _showLbl
                            color tcf = _cyc == "W" ? wTextCol(vf) : _cyc == "D" ? dTextCol(vf) : _cyc == "6H" ? hTextCol(vf) : mTextCol(vf)
                            string ltf = _cyc == "W" ? str.format("W ({0})", vf) : _cyc == "D" ? str.format("D ({0})", vf) : _cyc == "6H" ? str.format("6H ({0})", vf) : str.format("90m ({0})", vf)
                            _fX0.push(x0)
                            _fX1.push(x1)
                            _fTxt.push(ltf)
                            _fTcol.push(tcf)
                    prevOpen := ft2
                int lastEdge = prevOpen
                int vLast = _cyc == "W" ? varW(lastEdge) : _cyc == "D" ? varD(lastEdge) : _cyc == "6H" ? varH(lastEdge) : varM(lastEdge)
                color lcLast = _cyc == "W" ? wLineCol(vLast) : _cyc == "D" ? dLineCol(vLast) : _cyc == "6H" ? hLineCol(vLast) : mLineCol(vLast)
                int xE = _useTime ? lastEdge : (_lbi + math.max(math.min(tradingBarsTo(time, lastEdge, _tfMs), 490), 1))
                flEnd = _useTime ? line.new(xE, low, xE, high, xloc=xloc.bar_time, extend=extend.both, color=lcLast, width=_width, style=fStyle(_styleStr)) : line.new(xE, low, xE, high, xloc=xloc.bar_index, extend=extend.both, color=lcLast, width=_width, style=fStyle(_styleStr))
                st.futLines.push(flEnd)
                if _showLbl and _fX0.size() > 0
                    for j = 0 to _fX0.size() - 1
                        int lx = _fX0.get(j)
                        int rx = j < _fX0.size() - 1 ? _fX0.get(j + 1) : _fX1.get(j)
                        if _useTime
                            int lb = _lbi + math.max(math.min(tradingBarsTo(time, lx, _tfMs), 490), 1)
                            int rb = _lbi + math.max(math.min(tradingBarsTo(time, rx, _tfMs), 490), 1)
                            int mb = int(math.round((lb + rb) / 2.0))
                            flbl = label.new(mb, curYPos, _fTxt.get(j), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=_fTcol.get(j), color=color.new(color.black,100), size=fSize(_tszStr))
                            st.futLbls.push(flbl)
                        else
                            int mx = math.min(int(math.round((lx + rx) / 2.0)), _lbi + 490)
                            flbl = label.new(mx, curYPos, _fTxt.get(j), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=_fTcol.get(j), color=color.new(color.black,100), size=fSize(_tszStr))
                            st.futLbls.push(flbl)
                _localMaxFut := lastEdge
            if _showLbl and st.lbls.size() > 0
                for i = 0 to st.lbls.size() - 1
                    float segH = st.segHighs.get(i)
                    float segRange = math.max(segH * 0.001, syminfo.mintick * 10)
                    float yPos = segH + segRange * (_gap / 0.1) * 0.1
                    int leftB  = st.startBars.get(i)
                    // For PAST labels, right edge = next cycle's start bar.
                    // For the ACTIVE (last) label, right edge = the first FUTURE divider's
                    // bar position (the cycle's true right boundary), so it sits at the real
                    // midpoint of the cycle instead of being pinned over current price.
                    int rightB = i < st.startBars.size() - 1 ? st.startBars.get(i + 1) : (na(_activeRightB) ? bar_index : _activeRightB)
                    int midB = int(math.round((leftB + rightB) / 2.0))
                    label.set_xy(st.lbls.get(i), midB, yPos)
    _localMaxFut

schD_open = schD_curOpen
fFut_D    = nextOpen(schD_open, "D", MS_D)
schH_open = schH_curOpen
fFut_6H   = schH_open + MS_6H
schM_open = schM_curOpen
fFut_90m  = schM_open + MS_90m

_wDow2 = dayofweek(time, tz)
_dToSun = (_wDow2 - 1)
_thisSun18 = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz) - _dToSun, 18, 0, 0)
schW_open = _thisSun18 <= time ? _thisSun18 : _thisSun18 - MS_W
fFut_W    = nextOpen(schW_open, "W", MS_W)

mW = drawIntra(wKey, wKey[1], okW, lblW, pastW, futW, MS_W,  fFut_W,   schW_open, widW, styW, tszW, offW, "W",   wS)
mD = drawIntra(dKey, dKey[1], okD, lblD, pastD, futD, MS_D,  fFut_D,   schD_open, widD, styD, tszD, offD, "D",   dS)
mH = drawIntra(hKey, hKey[1], okH, lblH, pastH, futH, MS_6H, fFut_6H,  schH_open, widH, styH, tszH, offH, "6H",  hS)
mM = drawIntra(mKeyV, mKeyV[1], okM, lblMin, pastMin, futMin, MS_90m, fFut_90m, schM_open, widMin, styMin, tszMin, offMin, "90m", mS)

maxFut = mW
maxFut := na(maxFut) or (not na(mD) and mD > maxFut) ? mD : maxFut
maxFut := na(maxFut) or (not na(mH) and mH > maxFut) ? mH : maxFut
maxFut := na(maxFut) or (not na(mM) and mM > maxFut) ? mM : maxFut

if barstate.islast and not na(maxFut)
    int _tfMs = math.max(timeframe.in_seconds() * 1000, 1)
    int _ahead = math.min(math.max(int(math.round((maxFut - time) / _tfMs)), 1), 490)
    int _anchorBar = bar_index + _ahead
    if na(g_axisAnchor)
        g_axisAnchor := line.new(_anchorBar, low, _anchorBar, high, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.black, 100), width=1)
    else
        line.set_xy1(g_axisAnchor, _anchorBar, low)
        line.set_xy2(g_axisAnchor, _anchorBar, high)
````

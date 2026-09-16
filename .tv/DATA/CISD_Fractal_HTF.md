<!-- tradingview-pine-id: PUB;703a1d45122041a6af15606aff8f5384 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CISD Fractal HTF

Source: https://www.tradingview.com/script/tY6f7UAQ/

## Description

This script is a highly specialized indicator designed around the **ICT (Inner Circle Trader)** concept of **CISD (Change in State of Delivery)**. Its main purpose is to identify and track structural shifts in market delivery across both your current timeframe and Higher Timeframes (HTF).

Here is a detailed breakdown of what this indicator does and its main features:

**1. Core Concept: CISD (Change in State of Delivery)**
In ICT theory, a "State of Delivery" refers to consecutive candles moving in the same direction (e.g., a series of down candles meaning the algorithm is delivering sell-side price). A **CISD** occurs when the market shifts this state:

* **Bullish CISD:** Occurs when price closes *above the opening price* of the last bearish delivery sequence. It signals that the market has shifted from selling to buying. The script plots a Blue line at this key level.
* **Bearish CISD:** Occurs when price closes *below the opening price* of the last bullish delivery sequence. It signals a shift from buying to selling. The script plots a Red line at this level.
These lines act as highly sensitive institutional support and resistance levels.

**2. Fractal Higher Timeframe (HTF) System**
Instead of just looking at the chart you have open, the indicator runs the CISD logic on multiple timeframes simultaneously:

* **Fractal Mode (Automatic):** It dynamically calculates the appropriate higher timeframes based on the chart you are viewing. For example, if you are on a 1-minute chart, it might look for 15m CISDs; if you are on a 5-minute chart, it looks for 1H and Daily CISDs.
* **Fixed Modes:** You can override the automatic system and force the indicator to *only* look for CISDs on the **1 Hour**, **4 Hour**, or **1H + 4H** timeframes, regardless of what chart you are looking at.
* **Current Timeframe:** It also tracks the CISDs of your current chart (Level 0) so you can align micro structure with macro structure.

**3. Invalidation and Chart Cleanliness (Mitigation)**
To keep your chart clean and relevant, the script uses strict invalidation rules:

* When a CISD is formed, the script remembers the absolute extreme of that move (the lowest low for a bullish CISD, or the highest high for a bearish CISD).
* **Automatic Deletion:** If price comes back and breaks that extreme (sweeps the low/high that created the CISD), the setup is considered **invalidated**. The indicator will instantly delete the line and label from your chart, leaving only the active, unviolated CISD levels.

**4. Visual Customization & Labels**

* **Labels:** The indicator automatically tags the lines with labels like `CISD ▲ 1H` or `CISD ▼ 4H` so you know exactly which timeframe caused the shift in delivery.
* **Styling:** You can fully customize the thickness of the lines, change them to Solid, Dashed, or Dotted, and adjust the Bullish/Bearish colors for up to 3 different levels (Current TF, HTF Level 1, and HTF Level 2).

**In summary:** This is an algorithmic structure tracker. It eliminates the need to constantly switch between timeframes to find where the market shifted its state of delivery. It plots macro CISD levels on your micro charts automatically, and removes them when they are no longer valid, keeping you aligned with the Higher Timeframe institutional order flow.

---

## Source Code

````pine
//@version=6
indicator("CISD Fractal HTF", overlay=true, max_lines_count=500, max_labels_count=500)
GF = "CISD | Timeframes"
FD = "CISD | Display"
FL = "CISD | Label"
fmd = input.string("Fractal", "CISD Mode", options=["Fractal","1H Only","4H Only","1H + 4H"], group=GF)
_cs = timeframe.in_seconds()
_a1 = _cs<=60 ? "15" : _cs<=180 ? "30" : _cs<=300 ? "60" : _cs<=1800 ? "240" : _cs<=3600 ? "1D" : _cs<=14400 ? "1W" : "1M"
_a2 = _cs<=180 ? "240" : _cs<=1800 ? "1D" : ""
_f1 = fmd=="1H Only" or fmd=="1H + 4H" ? "60" : fmd=="4H Only" ? "240" : _a1
_f2 = fmd=="1H + 4H" ? "240" : (fmd=="1H Only" or fmd=="4H Only") ? "" : _a2
shC = input.bool(true, "Current Timeframe ", inline="l0", group=GF)
cbC = input.color(#2196F3, "", inline="l0", group=GF)
crC = input.color(#FF1744, "", inline="l0", group=GF)
sh1 = input.bool(true, "Level 1 ", inline="l1", group=GF)
cb1 = input.color(#2196F3, "", inline="l1", group=GF)
cr1 = input.color(#FF1744, "", inline="l1", group=GF)
sh2 = input.bool(true, "Level 2 ", inline="l2", group=GF)
cb2 = input.color(#4CAF50, "", inline="l2", group=GF)
cr2 = input.color(#F44336, "", inline="l2", group=GF)
lw  = input.int(2, "Thickness", minval=1, maxval=5, group=FD)
fcS = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=FD)
shLb = input.bool(true, "Label", inline="lb", group=FL)
lc   = input.color(color.new(color.black,10), "", inline="lb", group=FL)
lb   = input.color(color.new(color.white,100), "", inline="lb", group=FL)
lz   = size.tiny
st(s) => s=="Dashed" ? line.style_dashed : s=="Dotted" ? line.style_dotted : line.style_solid
cs = st(fcS)
type HS
    bool sh
    string ht
    color cb
    color cr
type CS
    int sd = 0
    int sl = 0
    float so = na
    int sb = 0
    float slo = na
    float shi = na
    int vibes = 0
    int mdir = 0
    int cbar = 0
    int lcb = -1
    float be = na
    int tm = 0
    float pt = na
type CL
    line ln
    label lb
    int born
    float inv
    int dir
type LV
    HS h
    CS s
    array<CL> arr
var LV f0 = LV.new(HS.new(), CS.new(), array.new<CL>())
var LV f1 = LV.new(HS.new(), CS.new(), array.new<CL>())
var LV f2 = LV.new(HS.new(), CS.new(), array.new<CL>())
f0.h.sh := shC, f0.h.ht := timeframe.period, f0.h.cb := cbC, f0.h.cr := crC
f1.h.sh := sh1 and _f1 != "", f1.h.ht := _f1 != "" ? _f1 : "60", f1.h.cb := cb1, f1.h.cr := cr1
f2.h.sh := sh2 and _f2 != "", f2.h.ht := _f2 != "" ? _f2 : "240", f2.h.cb := cb2, f2.h.cr := cr2
fTx(string htf) =>
    s = timeframe.in_seconds(htf)
    s<60 ? str.tostring(s)+"s" : s/60<60 ? str.tostring(s/60)+"m" : s/3600<24 ? str.tostring(s/3600)+"H" : htf
fVt(string tf) => timeframe.in_seconds() < timeframe.in_seconds(tf)
method update(CS s, float o, float h, float l, float c, int t) =>
    cd = c>=o ? 1 : -1
    if cd == s.sd
        s.sl += 1, s.slo := math.min(s.slo, l), s.shi := math.max(s.shi, h)
    else
        s.sd := cd, s.sl := 1, s.so := o, s.sb := t, s.slo := l, s.shi := h
    if s.vibes == 0
        s.vibes := cd, s.be := s.so, s.tm := s.sb, s.pt := cd==1 ? s.shi : s.slo
    if s.vibes == 1 and h > s.pt
        s.pt := h
        if s.sd == 1
            s.be := s.so, s.tm := s.sb
    else if s.vibes == -1 and l < s.pt
        s.pt := l
        if s.sd == -1
            s.be := s.so, s.tm := s.sb
    bool sq = s.vibes==-1 and c > s.be and t > s.lcb
    bool lr = s.vibes== 1 and c < s.be and t > s.lcb
    int outDir = 0
    int outTm = 0
    float outBe = na
    float outPt = na
    if sq or lr
        outDir := sq ? 1 : -1, outTm := s.tm, outBe := s.be, outPt := s.pt
        s.mdir := outDir, s.cbar := t, s.lcb := t
        s.vibes := sq ? 1 : -1, s.be := s.so, s.tm := s.sb, s.pt := s.vibes==1 ? s.shi : s.slo
    [outDir, outTm, outBe, outPt]
method process0(LV v) =>
    if v.h.sh and barstate.isconfirmed
        [dir, tm, be, pt] = v.s.update(open, high, low, close, time)
        if dir != 0
            col = dir==1 ? v.h.cb : v.h.cr
            ln  = line.new(tm, be, time, be, xloc=xloc.bar_time, color=col, width=lw, style=cs)
            array.push(v.arr, CL.new(ln, na, bar_index, pt, dir))
method process(LV v) =>
    if v.h.sh and fVt(v.h.ht)
        if ta.change(time(v.h.ht)) != 0
            [o,h,l,c,t] = request.security(syminfo.tickerid, v.h.ht, [open[1],high[1],low[1],close[1],time[1]], lookahead=barmerge.lookahead_on)
            if not na(o)
                [dir, tm, be, pt] = v.s.update(o,h,l,c,t)
                if dir != 0
                    col = dir==1 ? v.h.cb : v.h.cr
                    ln  = line.new(tm, be, time, be, xloc=xloc.bar_time, color=col, width=lw, style=cs)
                    lbl = shLb ? label.new(time, be, text="CISD "+(dir==1?"▲":"▼")+" "+fTx(v.h.ht), xloc=xloc.bar_time, textcolor=lc, style=dir==1?label.style_label_up:label.style_label_down, color=lb, size=lz) : na
                    array.push(v.arr, CL.new(ln, lbl, bar_index, pt, dir))
method maintain0(LV v) =>
    if array.size(v.arr) > 0
        for i = array.size(v.arr)-1 to 0
            cl = array.get(v.arr, i)
            if bar_index > cl.born and (cl.dir==1 ? low <= cl.inv : high >= cl.inv)
                line.delete(cl.ln)
                if not na(cl.lb)
                    label.delete(cl.lb)
                array.remove(v.arr, i)
method maintain(LV v) =>
    if array.size(v.arr) > 0
        for i = array.size(v.arr)-1 to 0
            cl = array.get(v.arr, i)
            line.set_x2(cl.ln, time)
            if not na(cl.lb)
                label.set_x(cl.lb, time)
            if bar_index > cl.born and (cl.dir==1 ? low <= cl.inv : high >= cl.inv)
                line.delete(cl.ln)
                if not na(cl.lb)
                    label.delete(cl.lb)
                array.remove(v.arr, i)
f0.process0()
f1.process()
f2.process()
f0.maintain0()
f1.maintain()
f2.maintain()
````

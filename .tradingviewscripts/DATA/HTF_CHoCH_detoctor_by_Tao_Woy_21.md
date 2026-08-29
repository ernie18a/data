<!-- tradingview-pine-id: PUB;9e453582ad344b6ca56aae53fdd67d26 -->
<!-- tradingviewscripts-format: 1 -->
# HTF CHoCH detoctor by Tao Woy 2.1

Source: https://www.tradingview.com/script/BXLigfcw-HTF-CHOC-detector-by-Tao-Woy/

## Description

HTF CHOC detector by Tao Woy

Can display a CHOC, BOS , SWING Point of HTF on lower TimeFrame easily

eg. open m1 TF but show H1 CHOC, BOS, Swing point of H1

---

## Source Code

````pine
//@version=6
indicator("HTF CHoCH detoctor by Tao Woy 2.1", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── Inputs ──────────────────────────────────────────────
htf      = input.timeframe("60", "HTF สำหรับหาโครงสร้าง", tooltip = "เช่น 60 = H1, 240 = H4, D = Day / ตั้งเท่า TF กราฟ = ทำงานแบบปกติ")
swingLen = input.int(5, "Swing length (pivot บน HTF)", minval = 2)
useBody  = input.bool(true, "ยืนยันด้วย body close (ของแท่ง HTF)")
showBOS  = input.bool(true, "แสดง BOS ด้วย")
showPend = input.bool(true, "แสดงเส้น CHoCH realtime (เส้นประ)")
showSw   = input.bool(true, "แสดงจุด swing HTF")
colUp    = input.color(color.teal, "สี CHoCH Up")
colDn    = input.color(color.red, "สี CHoCH Down")
colBos   = input.color(color.new(color.gray, 30), "สี BOS")
colPend  = input.color(color.new(color.gray, 20), "สีเส้น realtime")

useHTF = htf != "" and htf != timeframe.period

// ── ดึงข้อมูลโครงสร้างจาก HTF (แท่งที่ปิดแล้ว = ไม่ repaint) ──
f_data() =>
    phv = ta.pivothigh(high, swingLen, swingLen)
    plv = ta.pivotlow(low, swingLen, swingLen)
    [phv[1], plv[1], time[swingLen + 1], close[1], high[1], low[1]]

[hPh, hPl, hPivT, hClose, hHigh, hLow] = request.security(syminfo.tickerid, htf, f_data(), lookahead = barmerge.lookahead_on)

// ค่าโหมด TF กราฟเอง
cPh   = ta.pivothigh(high, swingLen, swingLen)
cPl   = ta.pivotlow(low, swingLen, swingLen)
cPivT = time[swingLen]

sPh    = useHTF ? hPh : cPh
sPl    = useHTF ? hPl : cPl
sPivT  = useHTF ? hPivT : cPivT
sClose = useHTF ? hClose : close
sHigh  = useHTF ? hHigh : high
sLow   = useHTF ? hLow : low
newBar = useHTF ? timeframe.change(htf) : true

// ── State ───────────────────────────────────────────────
var float lastPH  = na
var int   lastPHT = na
var float lastPL  = na
var int   lastPLT = na
var int   trend    = 0
var float legHigh  = na
var int   legHighT = na
var float legLow   = na
var int   legLowT  = na
var float protLow  = na      // หลุด = CHoCH ▼
var int   protLowT = na
var float protHigh = na      // ทะลุ = CHoCH ▲
var int   protHighT = na
var bool  bosUpDone = false
var bool  bosDnDone = false
// ติดตามก้น/ยอดของโซนพักทั้งก้อน (จุด CHoCH จริง = จุดสุดของ pullback ก่อนทำยอด/ก้นใหม่)
var float runHi   = na
var float runLo   = na
var float pullLo  = na
var int   pullLoT = na
var float pullHi  = na
var int   pullHiT = na
var float candLo  = na
var int   candLoT = na
var float candHi  = na
var int   candHiT = na

srcUp = useBody ? sClose : sHigh
srcDn = useBody ? sClose : sLow

draw(int t1, float lvl, string txt, color c, bool isUp, bool dash) =>
    line.new(t1, lvl, time, lvl, xloc = xloc.bar_time, color = c, width = dash ? 1 : 2, style = dash ? line.style_dashed : line.style_solid)
    label.new(time, lvl, txt, xloc = xloc.bar_time, color = color.new(c, 80), textcolor = c, size = size.small, style = isUp ? label.style_label_down : label.style_label_up)

if barstate.isconfirmed and newBar
    // อัปเดต swing จาก HTF
    if not na(sPl)
        lastPL  := sPl
        lastPLT := sPivT
        if showSw
            label.new(sPivT, sPl, "", xloc = xloc.bar_time, style = label.style_triangleup, color = color.new(color.gray, 55), size = size.tiny)
        if trend == -1 and (na(legLow) or sPl < legLow)
            legLow    := sPl
            legLowT   := sPivT
            protHigh  := not na(candHi) ? candHi : lastPH
            protHighT := not na(candHi) ? candHiT : lastPHT
            bosDnDone := false
    if not na(sPh)
        lastPH  := sPh
        lastPHT := sPivT
        if showSw
            label.new(sPivT, sPh, "", xloc = xloc.bar_time, style = label.style_triangledown, color = color.new(color.gray, 55), size = size.tiny)
        if trend == 1 and (na(legHigh) or sPh > legHigh)
            legHigh   := sPh
            legHighT  := sPivT
            protLow   := not na(candLo) ? candLo : lastPL
            protLowT  := not na(candLo) ? candLoT : lastPLT
            bosUpDone := false

    // เริ่มต้น
    if trend == 0
        if not na(lastPH) and srcUp > lastPH
            trend     := 1
            legHigh   := sHigh
            legHighT  := time
            protLow   := lastPL
            protLowT  := lastPLT
            runHi     := sHigh
            pullLo    := na
            candLo    := lastPL
            candLoT   := lastPLT
        else if not na(lastPL) and srcDn < lastPL
            trend     := -1
            legLow    := sLow
            legLowT   := time
            protHigh  := lastPH
            protHighT := lastPHT
            runLo     := sLow
            pullHi    := na
            candHi    := lastPH
            candHiT   := lastPHT

    // ขาขึ้น
    else if trend == 1
        // ทำยอดใหม่ = pullback ก่อนหน้าจบ → ก้นของมันคือจุด CHoCH ที่แท้จริง
        if na(runHi) or sHigh > runHi
            if not na(pullLo)
                candLo  := pullLo
                candLoT := pullLoT
            runHi   := sHigh
            pullLo  := sLow
            pullLoT := time
        else if na(pullLo) or sLow < pullLo
            pullLo  := sLow
            pullLoT := time
        if not na(protLow) and srcDn < protLow
            draw(protLowT, protLow, "CHoCH ▼ (" + htf + ")", colDn, false, false)
            alert("HTF " + htf + " CHoCH DOWN @ " + str.tostring(protLow), alert.freq_once_per_bar_close)
            trend     := -1
            protHigh  := legHigh
            protHighT := legHighT
            legLow    := sLow
            legLowT   := time
            protLow   := na
            legHigh   := na
            runLo     := sLow
            pullHi    := na
            candHi    := protHigh
            candHiT   := protHighT
            runHi     := na
            pullLo    := na
            candLo    := na
        else if not bosUpDone and not na(legHigh) and srcUp > legHigh
            if showBOS
                draw(legHighT, legHigh, "BOS", colBos, true, true)
            bosUpDone := true
            // BOS แล้ว → ก้นโซนพักทั้งก้อนกลายเป็นจุด CHoCH ทันที
            if not na(candLo)
                protLow  := candLo
                protLowT := candLoT
            else if not na(lastPL)
                protLow  := lastPL
                protLowT := lastPLT

    // ขาลง
    else if trend == -1
        // ทำก้นใหม่ = pullback ก่อนหน้าจบ → ยอดของมันคือจุด CHoCH ที่แท้จริง
        if na(runLo) or sLow < runLo
            if not na(pullHi)
                candHi  := pullHi
                candHiT := pullHiT
            runLo   := sLow
            pullHi  := sHigh
            pullHiT := time
        else if na(pullHi) or sHigh > pullHi
            pullHi  := sHigh
            pullHiT := time
        if not na(protHigh) and srcUp > protHigh
            draw(protHighT, protHigh, "CHoCH ▲ (" + htf + ")", colUp, true, false)
            alert("HTF " + htf + " CHoCH UP @ " + str.tostring(protHigh), alert.freq_once_per_bar_close)
            trend    := 1
            protLow  := legLow
            protLowT := legLowT
            legHigh  := sHigh
            legHighT := time
            protHigh := na
            legLow   := na
            runHi    := sHigh
            pullLo   := na
            candLo   := protLow
            candLoT  := protLowT
            runLo    := na
            pullHi   := na
            candHi   := na
        else if not bosDnDone and not na(legLow) and srcDn < legLow
            if showBOS
                draw(legLowT, legLow, "BOS", colBos, false, true)
            bosDnDone := true
            if not na(candHi)
                protHigh  := candHi
                protHighT := candHiT
            else if not na(lastPH)
                protHigh  := lastPH
                protHighT := lastPHT

// ── เส้น CHoCH realtime (เส้นประ ย้ายตามโครงสร้าง HTF) ─────
var line  pendLn = na
var label pendLb = na

if barstate.islast
    float lvl = trend == 1 ? protLow : trend == -1 ? protHigh : na
    int   t1  = trend == 1 ? protLowT : protHighT
    string tfTxt = useHTF ? " (" + htf + ")" : ""
    string txt   = (trend == 1 ? "หลุดตรงนี้ = CHoCH ▼" : "ทะลุตรงนี้ = CHoCH ▲") + tfTxt
    if showPend and not na(lvl)
        if na(pendLn)
            pendLn := line.new(t1, lvl, time, lvl, xloc = xloc.bar_time, extend = extend.right, color = colPend, width = 1, style = line.style_dashed)
            pendLb := label.new(bar_index + 10, lvl, txt, color = color.new(color.gray, 100), textcolor = colPend, size = size.small, style = label.style_label_left)
        else
            line.set_xy1(pendLn, t1, lvl)
            line.set_xy2(pendLn, time, lvl)
            label.set_xy(pendLb, bar_index + 10, lvl)
            label.set_text(pendLb, txt)
    else if not na(pendLn)
        line.delete(pendLn)
        label.delete(pendLb)
        pendLn := na
        pendLb := na

// ── เตือนถ้าเปิด TF ใหญ่กว่า HTF ─────────────────────────
var table warn = table.new(position.top_right, 1, 1)
if barstate.islast and useHTF and timeframe.in_seconds(timeframe.period) > timeframe.in_seconds(htf)
    table.cell(warn, 0, 0, "TF กราฟใหญ่กว่า HTF ที่ตั้งไว้ — เปิด TF เล็กกว่า " + htf, text_color = color.red, bgcolor = color.new(color.red, 90))
````

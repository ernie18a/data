# Elliott Wave Navigator v6

- url: https://www.tradingview.com/script/ojbRNAfo-Elliott-Wave-Navigator-v6/
- type: indicator
- pine_id: PUB;ea5482344858436ba715a03416bd9f46
- version: 4.0

## Description

This is free version for who want to use elliot wave

## Source Code

````pine
//@version=6
indicator("Elliott Wave Navigator v6.5", "EW Nav v6.5", overlay=true, max_lines_count=200, max_labels_count=500, max_boxes_count=50)

//──────────────────────── Inputs ────────────────────────
grpZZ = "ZigZag engine"
autoMode = input.bool(true, "Auto reversal threshold", group=grpZZ,
     tooltip="Auto-adjusts the reversal threshold to the asset's behavior (Kaufman Efficiency Ratio)")
atrLen  = input.int(14, "ATR length", group=grpZZ)
atrMult = input.float(3.0, "Manual threshold (xATR)", step=0.25, minval=0.5, group=grpZZ,
     tooltip="Used only when Auto is off")
degMult = input.float(2.5, "Higher degree (× of main threshold)", step=0.25, minval=1.5, maxval=5.0, group=grpZZ,
     tooltip="Second zigzag for reading the larger-degree wave — warns when the small wave runs against the big one")
erLen    = input.int(50, "ER lookback (Auto)", minval=10, group=grpZZ,
     tooltip="Kaufman Efficiency Ratio lookback — used only when Auto is on")
erSmooth = input.int(10, "ER smoothing (Auto)", minval=1, group=grpZZ,
     tooltip="EMA smoothing so the auto threshold doesn't whipsaw — used only when Auto is on")
degMode = input.string("ATR ×N (default)", "Higher-degree mode", options=["ATR ×N (default)", "Higher timeframe"], group=grpZZ,
     tooltip="ATR ×N = coarse zigzag on this same timeframe (original method) | Higher timeframe = reads waves from actual higher-TF bars (e.g. Daily→Weekly), more accurate, but the latest HTF bar is still open so values can shift until it closes")
degTF = input.timeframe("", "Higher-degree timeframe (blank = auto)", group=grpZZ,
     tooltip="Used with Higher timeframe mode — blank = auto: intraday→D, Daily→W, Weekly→M")

grpD = "Display"
showZZ    = input.bool(true, "Zigzag + wave labels", group=grpD)
showInval = input.bool(true, "Invalidation line", group=grpD)
showTgt   = input.bool(true, "Target projection zone", group=grpD)
showFlip  = input.bool(true, "Next-pivot confirmation line (wave-flip level)", group=grpD,
     tooltip="Shows the price that, once reached, confirms a new pivot and flips the wave — computed as latest extreme ± (ATR × threshold)")
showChan  = input.bool(true, "Elliott channel (W4/W5 parallel lines)", group=grpD)
showPanel = input.bool(true, "Status panel", group=grpD)

grpP = "Panel"
panelPos   = input.string("top_right", "Panel position", options=["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"], group=grpP)
panelSize  = input.string("small", "Text size", options=["tiny", "small", "normal"], group=grpP)
panelStyle = input.string("Medium", "Layout", options=["Full", "Medium", "Compact"], group=grpP,
     tooltip="Full = full two-column table | Medium = same content in a single much narrower column | Compact = minimal, details in tooltips")
showEdu    = input.bool(true, "Learning mode (pattern info)", group=grpP)
showReplay = input.bool(true, "Replay labels (past count results)", group=grpP,
     tooltip="Leaves past count outcomes on the chart: green ✓ = price reached the projected zone / red ✗ = invalidated before reaching it — hover a label for details, useful for teaching yourself and friends what the system said and where")
shareMode  = input.bool(false, "Share mode (summary card)", group=grpP,
     tooltip="Shows a summary card with ticker/wave/target/invalidation/date, ready to screenshot and send to a friend")
sharePos   = input.string("middle_center", "Share card position", options=["top_center", "middle_center", "bottom_center", "middle_left", "middle_right"], group=grpP,
     tooltip="Move the card here if it covers earnings/dividend symbols or candles")

grpR = "Visible rows (Full / Medium)"
rowChk  = input.bool(true, "Signal check", group=grpR)
rowTime = input.bool(true, "Time", group=grpR)
rowFlip = input.bool(true, "Wave-flip distance (to next pivot)", group=grpR)
rowDeg  = input.bool(true, "Higher degree", group=grpR)
rowStat = input.bool(true, "Chart stats", group=grpR)
rowPlan = input.bool(true, "Game plan", group=grpR)

//──────────────────────── Auto threshold (Efficiency Ratio) ────────────────────────
chgAbs = math.abs(nz(ta.change(close)))
erDen  = math.sum(chgAbs, erLen)
erRaw  = erDen > 0 ? math.abs(close - nz(close[erLen], close)) / erDen : 0.5
erS    = ta.ema(erRaw, erSmooth)
autoMult = math.min(math.max(2.0 + 2.5 * (1 - erS), 2.0), 4.5)
multUsed = autoMode ? autoMult : atrMult

atr = ta.atr(atrLen)
dev = multUsed * atr

//──────────────────────── Confirmation data ────────────────────────
rsiV    = ta.rsi(close, 14)
volFast = ta.sma(volume, 5)
volSlow = ta.sma(volume, 20)
volRatio = volSlow > 0 ? volFast / volSlow : 1.0
bodyAbs = math.abs(close - open)
engulf  = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]
hammer  = bodyAbs > 0 and (math.min(open, close) - low) > 2 * bodyAbs and (high - math.max(open, close)) < bodyAbs
recov   = close > high[1] and close[1] < open[1]
bullRev = engulf or hammer or recov
// แท่งกลับตัวฝั่งลง (mirror ของชุดบน) — ใช้ยืนยันจังหวะขายเมื่อ W5 ถึงเป้า
engulfBear = close < open and close[1] > open[1] and close <= open[1] and open >= close[1]
shootStar  = bodyAbs > 0 and (high - math.max(open, close)) > 2 * bodyAbs and (math.min(open, close) - low) < bodyAbs
breakLow   = close < low[1] and close[1] > open[1]
bearRev    = engulfBear or shootStar or breakLow

//──────────────────────── ZigZag หลัก (ATR-based + RSI per leg) ────────────────────────
var int   dir  = 0
var float extP = na
var int   extB = na
var float legRsiHi = na
var float legRsiLo = na
var pricesA = array.new_float()
var barsA   = array.new_int()
var rsiA    = array.new_float()

f_push(p, b, r) =>
    array.push(pricesA, p)
    array.push(barsA, b)
    array.push(rsiA, r)
    if array.size(pricesA) > 14
        array.shift(pricesA)
        array.shift(barsA)
        array.shift(rsiA)

if dir == 0
    dir  := 1
    extP := high
    extB := bar_index
    legRsiHi := rsiV
    legRsiLo := rsiV
else if dir == 1
    legRsiHi := math.max(nz(legRsiHi, rsiV), rsiV)
    if high >= extP
        extP := high
        extB := bar_index
    else if close < extP - dev
        f_push(extP, extB, nz(legRsiHi, rsiV))
        dir  := -1
        extP := low
        extB := bar_index
        legRsiHi := rsiV
        legRsiLo := rsiV
else
    legRsiLo := math.min(nz(legRsiLo, rsiV), rsiV)
    if low <= extP
        extP := low
        extB := bar_index
    else if close > extP + dev
        f_push(extP, extB, nz(legRsiLo, rsiV))
        dir  := 1
        extP := high
        extB := bar_index
        legRsiHi := rsiV
        legRsiLo := rsiV

n = array.size(pricesA)
f_pv(i) => n >= i ? array.get(pricesA, n - i) : na
f_pb(i) => n >= i ? array.get(barsA,  n - i) : na
f_rv(i) => n >= i ? array.get(rsiA,   n - i) : na

p1 = f_pv(1)
p2 = f_pv(2)
p3 = f_pv(3)
p4 = f_pv(4)
p5 = f_pv(5)
p6 = f_pv(6)

//──────────────────────── ZigZag degree ใหญ่ (สำหรับ context) ────────────────────────
f_zzBig(devB) =>
    var int   d = 0
    var float e = na
    var qA = array.new_float()
    if d == 0
        d := 1
        e := high
    else if d == 1
        if high >= e
            e := high
        else if close < e - devB
            array.push(qA, e)
            if array.size(qA) > 8
                array.shift(qA)
            d := -1
            e := low
    else
        if low <= e
            e := low
        else if close > e + devB
            array.push(qA, e)
            if array.size(qA) > 8
                array.shift(qA)
            d := 1
            e := high
    m = array.size(qA)
    q1 = m >= 1 ? array.get(qA, m - 1) : na
    q2 = m >= 2 ? array.get(qA, m - 2) : na
    q3 = m >= 3 ? array.get(qA, m - 3) : na
    q4 = m >= 4 ? array.get(qA, m - 4) : na
    q5 = m >= 5 ? array.get(qA, m - 5) : na
    q6 = m >= 6 ? array.get(qA, m - 6) : na
    [d, m, q1, q2, q3, q4, q5, q6]

f_countLite(d, m, q1, q2, q3, q4, q5, q6) =>
    string cid = "No pattern yet"
    if d == 1
        if m >= 5 and q3 > q5 and q1 > q4 and q2 > q4
            cid := "Wave 5"
        else if m >= 3 and q1 > q3 and q2 > q3
            cid := "Wave 3"
        else if m >= 1
            cid := "Wave 1/B?"
    else if d == -1
        if m >= 6 and q4 > q6 and q3 > q5 and q2 > q5 and q1 > q3 and not ((q3 - q4) < (q5 - q6) and (q3 - q4) < (q1 - q2))
            cid := "Wave A"
        else if m >= 4 and q2 > q4 and q1 > q3
            cid := "Wave 4"
        else if m >= 3 and q3 > q1 and q1 > q2
            cid := "Wave C"
        else if m >= 2 and q1 > q2
            cid := "Wave 2"
    cid

[bDir, bN, q1, q2, q3, q4, q5, q6] = f_zzBig(dev * degMult)
bigId = f_countLite(bDir, bN, q1, q2, q3, q4, q5, q6)

// ── MTF: อ่าน degree ใหญ่จากแท่ง timeframe จริง (ทางเลือกแทน ATR ×N) ──
// ส่งเฉพาะตัวเลขข้าม context (ไม่ส่ง string) แล้วแปลงเป็นชื่อเวฟด้วย f_countLite ฝั่ง chart
f_autoTF() =>
    int s = timeframe.in_seconds(timeframe.period)
    s < 86400 ? "D" : s < 604800 ? "W" : "M"
f_htfZZ() =>
    f_zzBig(ta.atr(atrLen) * multUsed)
tfBig = degTF == "" ? f_autoTF() : degTF
[hDir, hN, h1, h2, h3, h4, h5, h6] = request.security(syminfo.tickerid, tfBig, f_htfZZ())
bool useMTF = degMode == "Higher timeframe"
string bigIdUsed = useMTF ? f_countLite(hDir, hN, h1, h2, h3, h4, h5, h6) : bigId
string degPre = useMTF ? tfBig + ": " : ""

//──────────────────────── Helpers ────────────────────────
f_in(x, lo, hi) => not na(x) and x >= lo and x <= hi
f_p(x) => str.tostring(x, format.mintick)
f_ck(b) => b ? "✓" : "✗"

//──────────────────────── Wave engine ────────────────────────
string countId    = "NONE"
string curWave    = "Not enough data"
float  invalLvl   = na
bool   invalBelow = true
float  tgtLo      = na
float  tgtHi      = na
int    conf       = 0
string plan       = "Waiting for more pivots"
string scoreTxt   = "—"
float  fibBase    = na

// ── จำ count ของแท่งก่อน pivot flip ล่าสุด (ใช้โดย Wave B trap) ──
var string prevCountAtFlip = "NONE"
if nz(dir[1]) != 0 and dir != nz(dir[1])
    prevCountAtFlip := countId[1]

if dir == 1
    // ── Wave B trap: เด้งหลัง Wave A มักเป็นกับดักฝั่งซื้อ — เช็คก่อน pattern อื่น ──
    if prevCountAtFlip == "WA" and n >= 2 and p2 > p1
        lenA = p2 - p1
        rB = (extP - p1) / lenA
        if f_in(rB, 0.30, 0.85)
            countId    := "WB"
            curWave    := "Wave B (temporary bounce — trap risk)"
            invalLvl   := p2
            invalBelow := false
            tgtLo      := p1 + 0.500 * lenA
            tgtHi      := p1 + 0.618 * lenA
            bool okB   = f_in(rB, 0.500, 0.786)
            conf       := 35 + (okB ? 5 : 0)
            scoreTxt   := "Bounce after A+35 B-zone" + f_ck(okB)
            plan       := "B bounce — don't chase. B usually ends in " + f_p(tgtLo) + "-" + f_p(tgtHi) + ", then C down is the risk | Above " + f_p(invalLvl) + " = correction over, real upside resumes"
    bool w5ok = false
    if countId == "NONE" and n >= 5
        l1 = p4 - p5
        l3 = p2 - p3
        w5ok := p3 > p5 and p1 > p4 and p2 > p4 and l1 > 0 and l3 > 0
        if w5ok
            countId    := "W5"
            invalLvl   := p1
            invalBelow := true
            fibBase    := l1
            r2 = (p4 - p3) / l1
            r3 = l3 / l1
            r4 = (p2 - p1) / l3
            bool extended3 = r3 >= 2.4
            if extended3
                tgtLo := p1 + 0.618 * l1
                tgtHi := p1 + 1.000 * l1
                curWave := "Wave 5 (W3 extended — short target)"
            else
                t1 = p1 + l1
                t2 = p1 + 0.618 * (p2 - p5)
                tgtLo := math.min(t1, t2)
                tgtHi := math.max(t1, t2)
                curWave := "Wave 5 (final impulse wave)"
            if l3 < l1
                tgtHi := math.min(tgtHi, p1 + 0.95 * l3)
                tgtLo := math.min(tgtLo, tgtHi)
            bool ok2  = f_in(r2, 0.382, 0.786)
            bool ok3  = f_in(r3, 1.200, 3.200)
            bool ok4  = f_in(r4, 0.236, 0.550)
            bool okAlt = not na(r2) and not na(r4) and math.abs(r2 - r4) > 0.15
            conf := 40 + (ok2 ? 10 : 0) + (f_in(r2, 0.45, 0.65) ? 5 : 0) + (ok3 ? 10 : 0) + (f_in(r3, 1.4, 1.9) ? 5 : 0) + (ok4 ? 10 : 0) + (okAlt ? 5 : 0)
            scoreTxt := "Rules+40 W2fib" + f_ck(ok2) + " W3ext" + f_ck(ok3) + " W4fib" + f_ck(ok4) + " Alt" + f_ck(okAlt)
            plan := "Final wave of the cycle — scale out in " + f_p(tgtLo) + "-" + f_p(tgtHi) + " | Below " + f_p(invalLvl) + " = cycle ended before target"
    if countId == "NONE" and n >= 3 and p1 > p3 and p2 > p3
        l1 = p2 - p3
        countId    := "W3"
        curWave    := "Wave 3 (running)"
        invalLvl   := p1
        invalBelow := true
        fibBase    := l1
        tgtLo := p1 + l1
        tgtHi := p1 + 1.618 * l1
        r2 = (p2 - p1) / l1
        bool ok2   = f_in(r2, 0.382, 0.786)
        bool okBrk = close > p2
        conf := 40 + (ok2 ? 15 : 0) + (f_in(r2, 0.45, 0.65) ? 10 : 0) + (okBrk ? 10 : 0)
        scoreTxt := "Rules+40 W2fib" + f_ck(ok2) + " breakout" + f_ck(okBrk)
        plan := "Strongest wave — hold toward " + f_p(tgtLo) + "-" + f_p(tgtHi) + " | Reassess below " + f_p(invalLvl)
    if countId == "NONE" and n >= 1
        countId    := "W1"
        curWave    := "Wave 1 / B? (unconfirmed)"
        invalLvl   := p1
        invalBelow := true
        conf := 25
        scoreTxt := "Not enough structure"
        plan := "Unclear — don't act on EW yet | Below " + f_p(invalLvl) + " = wipe the board, recount"
else if dir == -1
    bool waOk = false
    if n >= 6
        l1 = p5 - p6
        l3 = p3 - p4
        l5 = p1 - p2
        waOk := p4 > p6 and p3 > p5 and p2 > p5 and p1 > p3 and l1 > 0 and l3 > 0 and l5 > 0 and not (l3 < l1 and l3 < l5)
        if waOk
            countId    := "WA"
            curWave    := "Wave A (correction begins)"
            invalLvl   := p1
            invalBelow := false
            rng = p1 - p6
            tgtHi := p1 - 0.382 * rng
            tgtLo := p1 - 0.500 * rng
            bool okExt = l3 >= l1 and l3 >= l5
            conf := 50 + (okExt ? 10 : 0)
            scoreTxt := "5 waves done+50 W3 longest" + f_ck(okExt)
            plan := "Don't buy the dip yet — wait for " + f_p(tgtLo) + "-" + f_p(tgtHi) + " | Above " + f_p(invalLvl) + " = uptrend resumes, not a correction"
    if not waOk and n >= 4 and p2 > p4 and p1 > p3 and (p1 - p2) > 0 and (p3 - p4) > 0
        l1 = p3 - p4
        l3 = p1 - p2
        countId    := "W4"
        curWave    := "Wave 4 (consolidating)"
        invalLvl   := p3
        invalBelow := true
        tgtHi := p1 - 0.382 * l3
        tgtLo := math.max(p1 - 0.500 * l3, p3)
        r2 = (p3 - p2) / l1
        r3 = l3 / l1
        bool ok2 = f_in(r2, 0.382, 0.786)
        bool ok3 = f_in(r3, 1.200, 3.200)
        bool okAlt = not na(r2) and r2 > 0.5
        conf := 40 + (ok2 ? 10 : 0) + (ok3 ? 10 : 0) + (f_in(r3, 1.4, 1.9) ? 5 : 0) + (okAlt ? 5 : 0)
        scoreTxt := "Rules+40 W2fib" + f_ck(ok2) + " W3ext" + f_ck(ok3) + " Alt" + f_ck(okAlt)
        plan := "Wait for pullback into " + f_p(tgtLo) + "-" + f_p(tgtHi) + " to position for W5 | Drop the idea below " + f_p(invalLvl)
    if countId == "NONE" and n >= 3 and p3 > p1 and p1 > p2
        rB = (p1 - p2) / (p3 - p2)
        if f_in(rB, 0.300, 0.950)
            lenA = p3 - p2
            countId    := "WC"
            invalLvl   := p1
            invalBelow := false
            bool isFlat = rB >= 0.85
            if isFlat
                curWave := "Wave C (Flat — deep B)"
                tgtHi := p2
                tgtLo := p2 - 0.236 * lenA
            else
                curWave := "Wave C (Zigzag — shallow B)"
                tgtHi := p1 - 1.000 * lenA
                tgtLo := p1 - 1.618 * lenA
            bool okB = f_in(rB, 0.500, 0.786)
            conf := 40 + (okB ? 15 : 0) + (isFlat ? 5 : 0)
            scoreTxt := "ABC structure+40 Bfib" + f_ck(okB) + (isFlat ? " Flat type" : " Zigzag type")
            plan := "Accumulation zone for the next cycle " + f_p(tgtLo) + "-" + f_p(tgtHi) + " | Above " + f_p(invalLvl) + " = correction already over"
    if countId == "NONE" and n >= 2 and p1 > p2
        l1 = p1 - p2
        countId    := "W2"
        curWave    := "Wave 2 (first pullback)"
        invalLvl   := p2
        invalBelow := true
        tgtHi := p1 - 0.500 * l1
        tgtLo := p1 - 0.618 * l1
        bool okHigh = not na(p3) and p1 > p3
        conf := 35 + (okHigh ? 10 : 0)
        scoreTxt := "Early-trend structure+35 new high" + f_ck(okHigh)
        plan := "Accumulation zone " + f_p(tgtLo) + "-" + f_p(tgtHi) + ", wait for reversal signal | Below " + f_p(invalLvl) + " = not a W2"

//──────────────────────── BEAR state (ขาลงเป็นชั้น — กันหาโซนรับผิดจังหวะ) ────────────────────────
// เข้าเมื่อโครงสร้าง lower high ต่อเนื่อง + lower low + ทำ low ใหม่ / ออกเมื่อ close ทะลุ lower high ล่าสุด (break structure)
var bool  bearMode = false
var float bearMSB  = na
bool bearEnterBar  = false
bool bearExitBar   = false
bool bearStruct = dir == -1 and n >= 5 and p1 < p3 and p3 < p5 and p2 < p4 and extP < p2
if not bearMode and bearStruct
    bearMode := true
    bearMSB  := p1
    bearEnterBar := true
else if bearMode
    // ratchet ระดับ break structure ลงตาม lower high ใหม่ (ยืนยันเมื่อ zigzag พลิกลง)
    if nz(dir[1]) != 0 and dir != nz(dir[1]) and dir == -1 and p1 < bearMSB
        bearMSB := p1
    if close > bearMSB
        bearMode := false
        bearMSB  := na
        bearExitBar := true
if bearMode
    countId    := "BEAR"
    curWave    := "Stair-step downtrend (BEAR)"
    invalLvl   := na
    tgtLo      := na
    tgtHi      := na
    fibBase    := na
    conf       := 20
    scoreTxt   := "—"
    plan       := "Consecutive LH/LL structure — don't hunt support with bullish EW. Wait for close above " + f_p(bearMSB) + " (structure break), then start a fresh count"

//──────────────────────── BROKEN state (เสียรูปแล้ว แต่ pivot ใหม่ยังไม่เกิด) ────────────────────────
if countId != "NONE" and countId != "W1" and not na(invalLvl) and (invalBelow ? close < invalLvl : close > invalLvl)
    countId  := "BROKEN"
    curWave  := "Invalidated — awaiting recount"
    plan     := "Count invalidated at " + f_p(invalLvl) + " — don't force the old plan. A new confirmed pivot will restart the count; meanwhile navigate with other frameworks (Stage / AVWAP / Volume Profile)"
    scoreTxt := "—"
    conf     := 15
    invalLvl := na
    tgtLo    := na
    tgtHi    := na

//──────────────────────── Target extension (วิ่งเกินเป้า) ────────────────────────
string zoneState = ""
if countId == "W3" and not na(tgtHi) and close > tgtHi and not na(fibBase)
    tgtLo := p1 + 1.618 * fibBase
    tgtHi := p1 + 2.618 * fibBase
    zoneState := "past first target — extended 3rd"
    plan := "Stronger than expected (W3 extension) — extended target " + f_p(tgtLo) + "-" + f_p(tgtHi) + " | trail stop under latest swing " + f_p(p1)
if countId == "W5" and not na(tgtHi) and close > tgtHi
    zoneState := "past target — trailing mode"
    plan := "Past W5 target — don't set a new ceiling. Trail a stop under latest swing " + f_p(p1) + " and let profits run until it breaks"
bool isWait = countId == "W2" or countId == "W4" or countId == "WC"
if isWait and not na(tgtLo) and close < tgtLo
    zoneState := "deeper than projected zone"
    plan := plan + " | ⚠ Below the projected zone, close to invalidation — extra caution"
if countId == "WB" and not na(tgtHi) and close > tgtHi
    zoneState := "beyond normal B zone"
    plan := plan + " | ⚠ Bounce stronger than typical B — once close crosses " + f_p(invalLvl) + ", treat the correction as over"

//──────────────────────── Confirmation analyzer (เช็คสัญญาณ) ────────────────────────
bool inZoneNow = not na(tgtLo) and close >= tgtLo and close <= tgtHi
string chkTxt = "—"
bool entryReady = false
bool exitReady  = false
if isWait
    bool chkZone = inZoneNow
    bool chkDry  = volRatio < 0.9
    bool chkRev  = bullRev
    entryReady := chkZone and chkRev
    conf += (chkZone ? 5 : 0) + (chkZone and chkDry ? 5 : 0) + (chkZone and chkRev ? 10 : 0)
    chkTxt := "In zone" + f_ck(chkZone) + " Dry selling" + f_ck(chkDry) + " Reversal bar" + f_ck(chkRev) + (entryReady ? " > entry can be considered" : chkZone ? " > in zone, waiting for signal" : " > not in zone yet, be patient")
else if countId == "W3"
    bool chkVol = volRatio > 1.05
    conf += chkVol ? 5 : 0
    chkTxt := "Volume support" + f_ck(chkVol) + " Holding above W1 top" + f_ck(close > p2)
else if countId == "W5"
    bool chkVol = volRatio > 1.05
    bool divBear = not na(p2) and close > p2 and not na(f_rv(2)) and nz(legRsiHi, rsiV) < f_rv(2)
    bool atTgt = not na(tgtLo) and close >= tgtLo
    exitReady := atTgt and bearRev
    if divBear
        conf -= 10
        plan := plan + " | ⚠ RSI divergence — weaker momentum than W3, cycle near its end"
    if exitReady
        plan := plan + " | 🔔 Target reached + bearish reversal bar — consider scaling out"
    chkTxt := "Volume support" + f_ck(chkVol) + " Divergence" + (divBear ? " present ⚠" : f_ck(false) + " (none = good)") + " Bearish reversal bar" + f_ck(bearRev) + (exitReady ? " > sell signals complete" : "")
else if countId == "WA"
    chkTxt := "Selling pressure: " + (volRatio > 1.05 ? "still heavy — don't rush in" : "drying up — watch closely")
else if countId == "WB"
    bool chkZoneB = inZoneNow
    bool chkDryB  = volRatio < 0.9
    conf += chkZoneB and chkDryB ? 5 : 0
    chkTxt := "In B zone" + f_ck(chkZoneB) + " Dry bounce" + f_ck(chkDryB) + " Bearish reversal bar" + f_ck(bearRev) + (chkZoneB and bearRev ? " > B likely ending, beware leg C" : "")
else if countId == "BEAR"
    chkTxt := "Structure breaks if close crosses " + f_p(bearMSB) + " — until then treat every bounce as a bear rally"
conf := math.min(math.max(conf, 5), 95)

// ระยะถึงจุดเสียรูป + R:R
riskPct = na(invalLvl) or close == 0 ? na : math.abs(close - invalLvl) / close * 100
tgtMid  = na(tgtLo) ? na : (tgtLo + tgtHi) / 2

// ระดับยืนยัน pivot ถัดไป (จุดเปลี่ยนเวฟ): ราคาสุดขั้วล่าสุด ± dev
flipLvl   = dir == 1 ? extP - dev : extP + dev
flipBelow = dir == 1
flipPct   = close == 0 ? na : math.abs(close - flipLvl) / close * 100
flipDir   = dir == 1 ? "pullback to" : "bounce to"
flipNext  = dir == 1 ? "confirms top → down wave begins" : "confirms bottom → up wave begins"
rr = (countId == "W3" or countId == "W5") and not na(tgtMid) and not na(invalLvl) and close > invalLvl and tgtMid > close ? (tgtMid - close) / (close - invalLvl) : na

//──────────────────────── Degree ใหญ่ warning ────────────────────────
bool bigLate = bigIdUsed == "Wave 5" or bigIdUsed == "Wave A"
string degTxt = degPre + bigIdUsed + (bigLate and (countId == "W2" or countId == "W3" or countId == "W4") ? " ⚠ larger wave near cycle end" : "")
string degTip = useMTF ? "Read from actual " + tfBig + " bars — the latest higher-TF bar hasn't closed, so values can shift until it does" : "Estimated from ATR ×" + str.tostring(degMult, "#.#") + " zigzag on this timeframe — switch to real higher-TF bars at Settings > Higher-degree mode"

//──────────────────────── Count Scoreboard (สถิติบน chart นี้) ────────────────────────
bool invalPrevBroke = not na(invalLvl[1]) and (invalBelow[1] ? (close < invalLvl[1] and close[1] >= invalLvl[1]) : (close > invalLvl[1] and close[1] <= invalLvl[1]))
bool inZonePrev = not na(tgtLo[1]) and close >= tgtLo[1] and close <= tgtHi[1]

f_stIdx(cid) =>
    cid == "W2" ? 0 : cid == "W3" ? 1 : cid == "W4" ? 2 : cid == "W5" ? 3 : cid == "WA" ? 4 : cid == "WB" ? 5 : cid == "WC" ? 6 : -1

f_stName(idx) =>
    idx == 0 ? "W2" : idx == 1 ? "W3" : idx == 2 ? "W4" : idx == 3 ? "W5" : idx == 4 ? "A" : idx == 5 ? "B" : idx == 6 ? "C" : "?"

var int statHit  = 0
var int statFail = 0
var stHitA  = array.new_int(7, 0)
var stFailA = array.new_int(7, 0)
// replay labels เก็บใน array แล้ว cap เอง — กัน TradingView ลบ label อื่น (เช่น wave labels) แบบสุ่มเมื่อชน max_labels_count
var repL = array.new_label()
f_pushReplay(lb) =>
    array.push(repL, lb)
    if array.size(repL) > 300
        label.delete(array.shift(repL))
var string epKey = ""
var int  epIdx = -1
var bool epResolved = true

if not epResolved
    if invalPrevBroke
        statFail += 1
        if epIdx >= 0
            array.set(stFailA, epIdx, array.get(stFailA, epIdx) + 1)
            if showReplay
                f_pushReplay(label.new(bar_index, close, "✗ " + f_stName(epIdx),
                     style=label.style_label_down, color=color.new(color.red, 30), textcolor=color.white, size=size.tiny,
                     tooltip="Counted as " + f_stName(epIdx) + " but invalidated before reaching the projected zone — count cancelled here"))
        epResolved := true
    else if inZonePrev
        statHit += 1
        if epIdx >= 0
            array.set(stHitA, epIdx, array.get(stHitA, epIdx) + 1)
            if showReplay
                f_pushReplay(label.new(bar_index, close, "✓ " + f_stName(epIdx),
                     style=label.style_label_up, color=color.new(color.green, 30), textcolor=color.white, size=size.tiny,
                     tooltip="Counted as " + f_stName(epIdx) + " and price reached the projected zone here"))
        epResolved := true

// 1 episode = 1 ช่วง state ต่อเนื่อง — pivot ภายในเวฟเดิมขยับกี่รอบก็ยังเป็นเคสเดิม ไม่นับซ้ำ
string nowKey = countId
if nowKey != epKey
    int newIdx = f_stIdx(countId)
    // count วิวัฒน์เป็นเวฟถัดไปตามลำดับ (W2→W3→W4→W5→A→B→C) โดยไม่เสียรูป = thesis เดิมถูก นับเป็น hit
    if not epResolved and epIdx >= 0 and newIdx == epIdx + 1
        statHit += 1
        array.set(stHitA, epIdx, array.get(stHitA, epIdx) + 1)
        if showReplay
            f_pushReplay(label.new(bar_index, close, "✓ " + f_stName(epIdx),
                 style=label.style_label_up, color=color.new(color.green, 30), textcolor=color.white, size=size.tiny,
                 tooltip="Counted as " + f_stName(epIdx) + ", then structure evolved to " + f_stName(newIdx) + " in sequence without invalidating — original count confirmed"))
    epKey := nowKey
    epIdx := newIdx
    epResolved := epIdx < 0 or na(tgtLo)

// breakdown สถิติต่อเวฟ (แสดงใน tooltip)
f_stLine(idx) =>
    int h = array.get(stHitA, idx)
    int t = h + array.get(stFailA, idx)
    t > 0 ? f_stName(idx) + " " + str.tostring(h) + "/" + str.tostring(t) + "  " : ""
string stBreak = f_stLine(0) + f_stLine(1) + f_stLine(2) + f_stLine(3) + f_stLine(4) + f_stLine(5) + f_stLine(6)

statTot = statHit + statFail
string statTxt = statTot == 0 ? "No data yet" : "Total " + str.tostring(statHit) + "/" + str.tostring(statTot) + " (" + str.tostring(100.0 * statHit / statTot, "#") + "%)"

//──────────────────────── Adaptive confidence (calibrate ด้วยสถิติ state ตัวเอง) ────────────────────────
int myIdx = f_stIdx(countId)
int myHit = myIdx >= 0 ? array.get(stHitA, myIdx) : 0
int myTot = myIdx >= 0 ? myHit + array.get(stFailA, myIdx) : 0
float calib = myTot >= 5 ? 0.6 + 0.8 * (1.0 * myHit / myTot) : 1.0
int confRaw = conf
conf := int(math.round(math.min(math.max(conf * calib, 5), 95)))
string calibTxt = myTot >= 5 ? "Raw score " + str.tostring(confRaw) + " × calibration from this state's stats (" + str.tostring(myHit) + "/" + str.tostring(myTot) + " accurate) = " + str.tostring(conf) : "Not calibrated yet — this state has " + str.tostring(myTot) + "/5 cases"
if myTot >= 5
    statTxt := statTxt + " | this state " + str.tostring(myHit) + "/" + str.tostring(myTot)

//──────────────────────── Time guideline (มิติเวลา) ────────────────────────
string timeTxt = "—"
if countId == "W2" and n >= 2
    d1 = f_pb(1) - f_pb(2)
    el = bar_index - f_pb(1)
    timeTxt := "W2: " + str.tostring(el) + " bars in (W1 took " + str.tostring(d1) + ") — often ends around 0.5-0.62× of W1's time"
if countId == "W3" and n >= 3
    d1 = f_pb(2) - f_pb(3)
    el = bar_index - f_pb(1)
    timeTxt := "W3: " + str.tostring(el) + " bars in (W1 took " + str.tostring(d1) + ") — W3 usually takes ≥ W1's time"
if countId == "W4" and n >= 3
    d2 = f_pb(2) - f_pb(3)
    el = bar_index - f_pb(1)
    timeTxt := "W4: " + str.tostring(el) + " bars in (W2 took " + str.tostring(d2) + ") " + (el < d2 ? "— W4 usually lasts longer than W2, don't rush in" : "— duration proportionate, watch for reversal signal")
if countId == "W5" and n >= 5
    d1 = f_pb(4) - f_pb(5)
    el = bar_index - f_pb(1)
    timeTxt := "W5: " + str.tostring(el) + " bars in (W1 took " + str.tostring(d1) + ") — usually similar to W1's time"
if countId == "WC" and n >= 3
    dA = f_pb(2) - f_pb(3)
    el = bar_index - f_pb(1)
    timeTxt := "C: " + str.tostring(el) + " bars in (A took " + str.tostring(dA) + ") — often ends near A's duration"
if countId == "WB" and n >= 2
    dA = f_pb(1) - f_pb(2)
    el = bar_index - f_pb(1)
    timeTxt := "B: " + str.tostring(el) + " bars in (A took " + str.tostring(dA) + ") — B rarely takes longer than A"
if countId == "WA" and n >= 1
    timeTxt := "A: " + str.tostring(bar_index - f_pb(1)) + " bars in — wait for the B bounce before timing C"

//──────────────────────── โหมดเรียนรู้ (Pattern info) ────────────────────────
string eduTxt = switch countId
    "W1" => "Pattern: impulse start (unproven)"
    "W2" => "Pattern: early impulse (1-2)"
    "W3" => "Pattern: mid impulse (1-2-3)"
    "W4" => "Pattern: late impulse (1-2-3-4)"
    "W5" => "Pattern: impulse near completion (1-2-3-4-5)"
    "WA" => "Pattern: impulse done > A-B-C correction begins"
    "WB" => "Pattern: mid correction (Wave B — counter bounce)"
    "WC" => "Pattern: late correction (Wave C)"
    "BEAR" => "Pattern: stair-step downtrend (bear structure)"
    "BROKEN" => "Pattern: count cancelled (invalidated)"
    => "Pattern: no clear shape yet"

string eduTip = switch countId
    "W2" => "Wave 2 is often a deep, sharp pullback — deep enough that most people think the trend is over. But as long as the start of Wave 1 holds, the bullish structure is intact. This is the classic accumulation zone"
    "W3" => "Wave 3 is the longest and steepest wave with the heaviest volume, and by rule it can never be the shortest of 1, 3, 5 — this is when good news starts flowing and broad buying pours in"
    "W4" => "Wave 4 tends to be shallow and sideways-in-time, opposite in character to Wave 2 (alternation rule: W2 deep, W4 shallow), and must never overlap the top of Wave 1"
    "W5" => "Wave 5 usually has weaker momentum than Wave 3 even as price makes new highs — momentum/volume divergence is the classic sign the cycle is ending. Watch your greed here"
    "WA" => "After 5 waves the market enters an A-B-C correction — Wave A is the first leg down, which most people still read as a normal dip, so they catch the knife too early"
    "WB" => "Wave B is the classic trap bounce — volume is usually light and real buying hasn't returned. FOMO buyers chase here and get hit by Wave C. If the bounce is sluggish with dry volume, odds favor a B — be patient and buy cheaper after C ends"
    "WC" => "Wave C is the final leg of the correction — in a Zigzag (shallow B) C runs 1.0-1.618× of A, but in a Flat (deep B) C usually ends near the bottom of Wave A before a new cycle begins"
    "BEAR" => "Consecutive lower highs / lower lows form a stair-step downtrend — don't hunt support with a bullish EW framework. The first evidence sellers are done is a market structure break: a close above the latest lower high. Until then, cash is the best position"
    "BROKEN" => "Invalidation isn't failure — it's information that the old plan was wrong. New possibilities: the rally may have been an ABC rather than an impulse, or a larger-degree correction is underway. Cash + patience is the best position for now"
    => "Wait for more confirmed pivots before interpreting"

//──────────────────────── Drawing ────────────────────────
var zzL = array.new_line()
var wvL = array.new_label()
var line  invL = na
var label invT = na
var box   tgtB = na
var label tgtT = na
var line  chMain = na
var line  chPara = na
var label chLab  = na
var line  flipL  = na
var label flipT  = na

colCur = color.new(color.gray, 30)
colInv = color.new(color.red, 0)
colTgt = color.new(color.teal, 40)

f_isHigh(idx) => dir == 1 ? (idx % 2 == 0) : (idx % 2 == 1)

f_mkLab(idx, txt) =>
    label.new(f_pb(idx), f_pv(idx), txt,
         style = f_isHigh(idx) ? label.style_label_down : label.style_label_up,
         color = color.new(color.blue, 15), textcolor = color.white, size = size.small)

if barstate.islast
    while array.size(zzL) > 0
        line.delete(array.pop(zzL))
    while array.size(wvL) > 0
        label.delete(array.pop(wvL))
    line.delete(invL)
    label.delete(invT)
    box.delete(tgtB)
    label.delete(tgtT)
    line.delete(chMain)
    line.delete(chPara)
    label.delete(chLab)
    line.delete(flipL)
    label.delete(flipT)

    if showZZ and n >= 2
        for i = 1 to n - 1
            array.push(zzL, line.new(f_pb(i + 1), f_pv(i + 1), f_pb(i), f_pv(i), color=color.new(color.blue, 25), width=2))
    if showZZ and n >= 1
        array.push(zzL, line.new(f_pb(1), f_pv(1), extB, extP, color=colCur, width=2, style=line.style_dashed))

    if showZZ
        if countId == "W5"
            array.push(wvL, f_mkLab(5, "0"))
            array.push(wvL, f_mkLab(4, "1"))
            array.push(wvL, f_mkLab(3, "2"))
            array.push(wvL, f_mkLab(2, "3"))
            array.push(wvL, f_mkLab(1, "4"))
        if countId == "W3"
            array.push(wvL, f_mkLab(3, "0"))
            array.push(wvL, f_mkLab(2, "1"))
            array.push(wvL, f_mkLab(1, "2"))
        if countId == "W4"
            array.push(wvL, f_mkLab(4, "0"))
            array.push(wvL, f_mkLab(3, "1"))
            array.push(wvL, f_mkLab(2, "2"))
            array.push(wvL, f_mkLab(1, "3"))
        if countId == "W2"
            array.push(wvL, f_mkLab(2, "0"))
            array.push(wvL, f_mkLab(1, "1"))
        if countId == "WA"
            array.push(wvL, f_mkLab(6, "0"))
            array.push(wvL, f_mkLab(5, "1"))
            array.push(wvL, f_mkLab(4, "2"))
            array.push(wvL, f_mkLab(3, "3"))
            array.push(wvL, f_mkLab(2, "4"))
            array.push(wvL, f_mkLab(1, "5"))
        if countId == "WC"
            array.push(wvL, f_mkLab(3, "5"))
            array.push(wvL, f_mkLab(2, "A"))
            array.push(wvL, f_mkLab(1, "B"))
        if countId == "WB"
            array.push(wvL, f_mkLab(2, "5"))
            array.push(wvL, f_mkLab(1, "A"))
        curTxt = countId == "W5" ? "5?" : countId == "W3" ? "3?" : countId == "W1" ? "1?" : countId == "WA" ? "A?" : countId == "W4" ? "4?" : countId == "WC" ? "C?" : countId == "W2" ? "2?" : countId == "WB" ? "B?" : countId == "BEAR" ? "▼" : countId == "BROKEN" ? "✗" : ""
        if curTxt != ""
            array.push(wvL, label.new(extB, extP, curTxt,
                 style = dir == 1 ? label.style_label_down : label.style_label_up,
                 color = countId == "BROKEN" or countId == "BEAR" ? color.new(color.red, 25) : color.new(color.gray, 25), textcolor = color.white, size = size.small))

    if showInval and not na(invalLvl)
        invL := line.new(bar_index - 30, invalLvl, bar_index + 15, invalLvl, color=colInv, style=line.style_dashed, width=1)
        invT := label.new(bar_index + 15, invalLvl,
             "Invalid if " + (invalBelow ? "below " : "above ") + f_p(invalLvl),
             style=label.style_label_left, color=color.new(color.red, 85), textcolor=color.red, size=size.small)

    if showTgt and not na(tgtLo)
        tgtB := box.new(bar_index, tgtHi, bar_index + 20, tgtLo, bgcolor=color.new(color.teal, 85), border_color=colTgt)
        tgtT := label.new(bar_index + 20, (tgtLo + tgtHi) / 2,
             "Target " + f_p(tgtLo) + " - " + f_p(tgtHi),
             style=label.style_label_left, color=color.new(color.teal, 85), textcolor=color.teal, size=size.small)

    // Elliott channel: เส้นฐานผ่านจุดจบเวฟคู่ + เส้นขนานผ่านจุดจบเวฟคี่
    if showChan and (countId == "W5" or countId == "W4") and n >= 3 and f_pb(1) != f_pb(3)
        chSlope = (p1 - p3) / (f_pb(1) - f_pb(3))
        chMain := line.new(f_pb(3), p3, f_pb(1), p1, extend=extend.right, color=color.new(color.purple, 45), style=line.style_dotted, width=1)
        chPara := line.new(f_pb(2), p2, f_pb(1), p2 + chSlope * (f_pb(1) - f_pb(2)), extend=extend.right, color=color.new(color.purple, 45), style=line.style_dotted, width=1)
        chLab  := label.new(bar_index + 12, p2 + chSlope * (bar_index + 12 - f_pb(2)),
             countId == "W5" ? "Channel: W5 target" : "Channel: W4 support",
             style=label.style_label_left, color=color.new(color.purple, 88), textcolor=color.purple, size=size.small)

    if showFlip and not na(flipLvl)
        flipL := line.new(bar_index - 30, flipLvl, bar_index + 15, flipLvl, color=color.new(color.orange, 0), style=line.style_dotted, width=1)
        flipT := label.new(bar_index + 15, flipLvl,
             "Wave flip if " + flipDir + " " + f_p(flipLvl) + " (" + (na(flipPct) ? "—" : str.tostring(flipPct, "#.#") + "%") + " away)",
             style=label.style_label_left, color=color.new(color.orange, 80), textcolor=color.orange, size=size.small)

//──────────────────────── Status panel ────────────────────────
panPosC = panelPos == "top_left" ? position.top_left : panelPos == "bottom_right" ? position.bottom_right : panelPos == "bottom_left" ? position.bottom_left : panelPos == "middle_right" ? position.middle_right : position.top_right
txtSz = panelSize == "tiny" ? size.tiny : panelSize == "normal" ? size.normal : size.small

var table pan = table.new(panPosC, 2, 13, border_width=1, border_color=color.new(color.gray, 70))
if barstate.islast and showPanel
    confCol = conf >= 65 ? color.green : conf >= 45 ? color.orange : color.red
    invTxt = na(invalLvl) ? "—" : (invalBelow ? "below " : "above ") + f_p(invalLvl) + (na(riskPct) ? "" : " (" + str.tostring(riskPct, "#.#") + "% away)")
    tgtTxt = na(tgtLo) ? "—" : f_p(tgtLo) + " - " + f_p(tgtHi) + (na(rr) ? "" : " | R:R " + str.tostring(rr, "#.#") + ":1") + (zoneState == "" ? "" : " | " + zoneState)
    flipTxt = na(flipLvl) ? "—" : flipDir + " " + f_p(flipLvl) + " (" + (na(flipPct) ? "—" : str.tostring(flipPct, "#.#") + "%") + " away) → " + flipNext
    statTip = "1 case per wave (pivot updates within the same wave don't re-count): reached projected zone / evolved to next wave = hit / invalidated before the zone = miss" + (stBreak == "" ? "" : "\nBy wave: " + stBreak) + "\n" + calibTxt
    fullTip = "Score breakdown: " + scoreTxt + "\n" + calibTxt + "\n\nPlan: " + plan + "\n\nTime: " + timeTxt + "\nHigher degree: " + degTxt + "\nChart stats: " + statTxt + (stBreak == "" ? "" : "\nBy wave: " + stBreak) + (showEdu ? "\n\n" + eduTip : "")
    int r = 0
    if panelStyle == "Compact"
        table.cell(pan, 0, 0, curWave + "  ·  " + str.tostring(conf) + "/100", text_size=txtSz, text_color=confCol, tooltip=fullTip)
        table.cell(pan, 0, 1, "Invalid: " + invTxt, text_size=txtSz, text_color=color.red, tooltip="Level that cancels the current count — usable as a structural stop")
        table.cell(pan, 0, 2, "Target: " + tgtTxt, text_size=txtSz, text_color=color.teal, tooltip=plan)
        table.cell(pan, 0, 3, "Wave flip: " + flipTxt, text_size=txtSz, text_color=color.orange, tooltip="Price that confirms the next pivot = where the wave flips")
        if showEdu
            table.cell(pan, 0, 4, eduTxt, text_size=txtSz, text_color=color.gray, tooltip=eduTip)
    else if panelStyle == "Medium"
        table.cell(pan, 0, r, curWave + "  ·  " + str.tostring(conf) + "/100", text_size=txtSz, text_color=confCol, tooltip=fullTip)
        r += 1
        table.cell(pan, 0, r, "Invalid: " + invTxt, text_size=txtSz, text_color=color.red, tooltip="Level that cancels the current count — usable as a structural stop")
        r += 1
        table.cell(pan, 0, r, "Target: " + tgtTxt, text_size=txtSz, text_color=color.teal)
        r += 1
        if rowFlip
            table.cell(pan, 0, r, "Wave flip: " + flipTxt, text_size=txtSz, text_color=color.orange, tooltip="Price that confirms the next pivot")
            r += 1
        if rowChk
            table.cell(pan, 0, r, "Check: " + chkTxt, text_size=txtSz, text_color=chart.fg_color, tooltip="Auto-analyzed: dry/supportive volume, reversal bar, RSI divergence")
            r += 1
        if rowTime
            table.cell(pan, 0, r, "Time: " + timeTxt, text_size=txtSz, text_color=chart.fg_color)
            r += 1
        if rowDeg or rowStat
            degStat = (rowDeg ? "Deg: " + degTxt : "") + (rowDeg and rowStat ? "  |  " : "") + (rowStat ? "Stats: " + statTxt : "")
            table.cell(pan, 0, r, degStat, text_size=txtSz, text_color=chart.fg_color, tooltip=statTip)
            r += 1
        if rowPlan
            table.cell(pan, 0, r, "Plan: " + plan, text_size=txtSz, text_color=chart.fg_color)
            r += 1
        if showEdu
            table.cell(pan, 0, r, eduTxt, text_size=txtSz, text_color=color.gray, tooltip=eduTip)
    else
        hdr = "EW Nav v6.5 (zz " + str.tostring(multUsed, "#.#") + "x" + (autoMode ? " auto" : "") + ")"
        table.cell(pan, 0, r, hdr, text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=txtSz)
        table.cell(pan, 1, r, timeframe.period, text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=txtSz)
        r += 1
        table.cell(pan, 0, r, "Current wave", text_size=txtSz, text_color=color.gray)
        table.cell(pan, 1, r, curWave, text_size=txtSz, text_color=chart.fg_color, tooltip=showEdu ? eduTip : "")
        r += 1
        table.cell(pan, 0, r, "Confidence", text_size=txtSz, text_color=color.gray)
        table.cell(pan, 1, r, str.tostring(conf) + " / 100", text_size=txtSz, text_color=confCol, tooltip="Score breakdown: " + scoreTxt + "\n" + calibTxt)
        r += 1
        table.cell(pan, 0, r, "Invalid if", text_size=txtSz, text_color=color.gray)
        table.cell(pan, 1, r, invTxt, text_size=txtSz, text_color=color.red)
        r += 1
        table.cell(pan, 0, r, "Target", text_size=txtSz, text_color=color.gray)
        table.cell(pan, 1, r, tgtTxt, text_size=txtSz, text_color=color.teal)
        r += 1
        if rowFlip
            table.cell(pan, 0, r, "Wave flip if", text_size=txtSz, text_color=color.gray)
            table.cell(pan, 1, r, flipTxt, text_size=txtSz, text_color=color.orange, tooltip="Price that confirms the next pivot = where the wave flips")
            r += 1
        if rowChk
            table.cell(pan, 0, r, "Signal check", text_size=txtSz, text_color=color.gray)
            table.cell(pan, 1, r, chkTxt, text_size=txtSz, text_color=chart.fg_color)
            r += 1
        if rowTime
            table.cell(pan, 0, r, "Time", text_size=txtSz, text_color=color.gray)
            table.cell(pan, 1, r, timeTxt, text_size=txtSz, text_color=chart.fg_color, tooltip="Time-dimension guideline — each wave has its own duration habits; use it to curb impatience")
            r += 1
        if rowDeg
            table.cell(pan, 0, r, "Higher degree", text_size=txtSz, text_color=color.gray)
            table.cell(pan, 1, r, degTxt, text_size=txtSz, text_color=chart.fg_color, tooltip=degTip)
            r += 1
        if rowStat
            table.cell(pan, 0, r, "Chart stats", text_size=txtSz, text_color=color.gray)
            table.cell(pan, 1, r, statTxt, text_size=txtSz, text_color=chart.fg_color, tooltip=statTip)
            r += 1
        if rowPlan
            table.cell(pan, 0, r, "Game plan", text_size=txtSz, text_color=color.gray)
            table.cell(pan, 1, r, plan, text_size=txtSz, text_color=chart.fg_color)
            r += 1
        if showEdu
            table.cell(pan, 0, r, "Lesson", text_size=txtSz, text_color=color.gray)
            table.cell(pan, 1, r, eduTxt, text_size=txtSz, text_color=color.gray, tooltip=eduTip)

//──────────────────────── การ์ดแชร์เพื่อน ────────────────────────
shrPosC = sharePos == "top_center" ? position.top_center : sharePos == "bottom_center" ? position.bottom_center : sharePos == "middle_left" ? position.middle_left : sharePos == "middle_right" ? position.middle_right : position.middle_center
var table shr = table.new(shrPosC, 1, 2, border_width=1, border_color=color.new(color.blue, 40))
if barstate.islast and shareMode
    dts = str.format_time(timenow, "dd MMM yyyy", syminfo.timezone)
    shrHdr = "📈 " + syminfo.ticker + " · " + timeframe.period + " · " + dts + "  (EW Navigator)"
    shrLine2 = countId == "BEAR" ? "Status: stair-step downtrend — no dip buying, wait for structure break at " + f_p(bearMSB) : na(invalLvl) ? "Status: count invalidated — awaiting recount, don't enter yet" : "Target: " + (na(tgtLo) ? "—" : f_p(tgtLo) + " - " + f_p(tgtHi)) + "   |   Drop idea if " + (invalBelow ? "below " : "above ") + f_p(invalLvl)
    shrBody = curWave + " — confidence " + str.tostring(conf) + "/100\n" + shrLine2 + "\nAccuracy on this chart: " + statTxt
    table.cell(shr, 0, 0, shrHdr, text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=txtSz)
    table.cell(shr, 0, 1, shrBody, text_color=chart.fg_color, bgcolor=color.new(color.blue, 92), text_size=txtSz, text_halign=text.align_left)

//──────────────────────── Alerts ────────────────────────
inZone = not na(tgtLo) and close >= tgtLo and close <= tgtHi
// pivot ใหม่ = zigzag กลับทิศ (ห้ามใช้ array.size เทียบ เพราะ array ถูก cap ที่ 14 ตัว จะไม่โตอีก)
newPiv = nz(dir[1]) != 0 and dir != nz(dir[1])

// หมายเหตุ: สถานะเวฟคำนวณจาก close ของแท่ง realtime ที่ยังไม่ปิด — ตอนสร้าง alert จาก
// เงื่อนไขด้านล่าง แนะนำตั้ง trigger เป็น "Once Per Bar Close" เพื่อกันสัญญาณกะพริบ intrabar
alertcondition(invalPrevBroke, "EW: Invalidation break", "Elliott count invalidated — old structure cancelled, a fresh count will start")
alertcondition(inZone and not inZone[1], "EW: Price in target zone", "Price entered the current wave's target/entry zone")
alertcondition(entryReady and not entryReady[1], "EW: Entry checklist complete", "In zone + reversal bar — entry can be considered")
alertcondition(exitReady and not exitReady[1], "EW: W5 sell signal", "W5 target reached + bearish reversal bar — consider scaling out")
alertcondition(newPiv, "EW: New pivot confirmed", "New pivot confirmed — wave count updated")
flipNear = not na(flipPct) and flipPct <= 1.0
alertcondition(flipNear and not flipNear[1], "EW: Near wave flip", "Price near the next pivot confirmation level (< 1% away) — wave about to flip")

// Dynamic alerts (เลือก "Any alert() function call" ตอนตั้ง alert) — ใส่ราคา/เป้าจริงในข้อความ
// ยิงเฉพาะตอนแท่งปิด (freq_once_per_bar_close) จึงไม่มีปัญหากะพริบ intrabar
if invalPrevBroke
    alert("EW " + syminfo.ticker + " " + timeframe.period + ": invalidated at " + f_p(close) + " — count cancelled, awaiting recount", alert.freq_once_per_bar_close)
if inZone and not inZone[1]
    alert("EW " + syminfo.ticker + " " + timeframe.period + ": price entered target zone " + f_p(tgtLo) + "-" + f_p(tgtHi) + " (" + curWave + ")", alert.freq_once_per_bar_close)
if entryReady and not entryReady[1]
    alert("EW " + syminfo.ticker + " " + timeframe.period + ": entry checklist complete at " + f_p(close) + " | drop idea below " + f_p(invalLvl), alert.freq_once_per_bar_close)
if exitReady and not exitReady[1]
    alert("EW " + syminfo.ticker + " " + timeframe.period + ": W5 target + bearish reversal at " + f_p(close) + " — consider scaling out | trail stop under " + f_p(p1), alert.freq_once_per_bar_close)
if newPiv
    alert("EW " + syminfo.ticker + " " + timeframe.period + ": new pivot confirmed — current state: " + curWave, alert.freq_once_per_bar_close)

// ── BEAR state alerts ──
alertcondition(bearEnterBar, "EW: BEAR mode start", "Stair-step downtrend structure — stop hunting support, wait for a structure break")
alertcondition(bearExitBar, "EW: BEAR mode exit", "Structure break — start looking for a new cycle")
if bearEnterBar
    alert("EW " + syminfo.ticker + " " + timeframe.period + ": BEAR mode — stair-step downtrend, no dip buying | structure breaks if close crosses " + f_p(bearMSB), alert.freq_once_per_bar_close)
if bearExitBar
    alert("EW " + syminfo.ticker + " " + timeframe.period + ": BEAR mode exit — structure break at " + f_p(close) + ", start looking for a new cycle", alert.freq_once_per_bar_close)
````

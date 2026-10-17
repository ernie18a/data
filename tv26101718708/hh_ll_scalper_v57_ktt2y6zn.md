# HH & LL Scalper v5.7

- url: https://www.tradingview.com/script/Ktt2Y6zn-HH-LL-Scalper-v5-7/
- type: indicator
- pine_id: PUB;53e0d00862904574bf7ec7a2f670f2b6
- version: 2.0

## Description

HH & LL Scalper v5.7HH & LL Scalper v5.7HH & LL Scalper v5.7HH & LL Scalper v5.7

## Source Code

````pine
//@version=5
indicator("Astro Algo ICT — Backtest", overlay=true,
          max_lines_count=500, max_boxes_count=500,
          max_labels_count=500, max_bars_back=3000)

// ══════════════════════════════════════════════════════════
// MODULE 1 — INPUTS
// ══════════════════════════════════════════════════════════

// ── Market Structure ──────────────────────────────────────
g1           = "🏗  Market Structure"
structLen    = input.int   (10,      "Swing Lookback",     group=g1, minval=3, maxval=50)
showBOS      = input.bool  (true,    "Show BOS",           group=g1)
showCHoCH    = input.bool  (true,    "Show CHoCH",         group=g1)
bosCol       = input.color (#9E9E9E, "BOS Color",          group=g1)
chochBullCol = input.color (#FFD700, "CHoCH Bullish",      group=g1)
chochBearCol = input.color (#FF5252, "CHoCH Bearish",      group=g1)

// ── Fair Value Gap ────────────────────────────────────────
g2           = "📊  Fair Value Gap"
showFVG      = input.bool  (true, "Show FVG",              group=g2)
fvgMaxShow   = input.int   (3,    "Max FVG visible",       group=g2, minval=1, maxval=20)
bullFVGcol   = input.color (color.new(#00E676, 80), "Bullish FVG",   group=g2)
bearFVGcol   = input.color (color.new(#FF5252, 80), "Bearish FVG",   group=g2)
mitigFVGcol  = input.color (color.new(#9E9E9E, 85), "Mitigated FVG", group=g2)

// ── Order Blocks ──────────────────────────────────────────
g3           = "📦  Order Blocks"
showOB       = input.bool  (true, "Show Order Blocks",     group=g3)
obLen        = input.int   (10,   "OB Swing Lookback",     group=g3, minval=3)
maxBullOB    = input.int   (1,    "Max Bullish OB",        group=g3, minval=0)
maxBearOB    = input.int   (1,    "Max Bearish OB",        group=g3, minval=0)
bullOBcol    = input.color (color.new(#2196F3, 75), "Bullish OB",    group=g3)
bearOBcol    = input.color (color.new(#FF3131, 75), "Bearish OB",    group=g3)

// ── Signals ───────────────────────────────────────────────
g4           = "🎯  Signals"
showSignals  = input.bool  (true,          "Show Signals",        group=g4)
sigMode      = input.string("FVG + CHoCH", "Signal Mode",         group=g4,
               options=["FVG + CHoCH","OB + CHoCH","FVG + BOS","OB + BOS","Any CHoCH"])
showSigLbl   = input.bool  (true,          "Show Detail Labels",  group=g4)
buyCol       = input.color (#00E676,       "BUY Color",           group=g4)
sellCol      = input.color (#FF5252,       "SELL Color",          group=g4)

// ── Signal Filters ────────────────────────────────────────
g5           = "🔍  Signal Filters"
candleFilter = input.bool (true, "Candle Color Confirmation", group=g5,
               tooltip="BUY: nến phải xanh (close>open)\nSELL: nến phải đỏ (close<open)")

// ── Stop Loss / Take Profit ───────────────────────────────
// [ĐÃ SỬA] SL = đỉnh/đáy thực của N nến quá khứ gần nhất
//           TP = tự động theo R:R = 1:1
g6           = "📏  Stop Loss / Take Profit  (R:R = 1:1 cố định)"
showTPSL     = input.bool (true, "Hiển thị SL / TP Lines", group=g6)
slLookback   = input.int  (10,   "SL Candle Lookback",      group=g6,
               minval=1, maxval=50,
               tooltip="BUY  → SL = Lowest Low  của N nến gần nhất tính từ nến tín hiệu\nSELL → SL = Highest High của N nến gần nhất tính từ nến tín hiệu\nTP   = Entry ± cùng khoảng cách → R:R = 1:1")

// ── Backtest Table ────────────────────────────────────────
g7           = "📈  Backtest Table"
showBTTable  = input.bool  (true,           "Hiển thị bảng Backtest", group=g7)
btPos        = input.string("Bottom Right", "Vị trí bảng",            group=g7,
               options=["Top Right","Top Left","Bottom Right","Bottom Left"])

// ══════════════════════════════════════════════════════════
// MODULE 2 — BASE CALCULATIONS
// ══════════════════════════════════════════════════════════

n            = bar_index
atr          = ta.atr(14)
isBullCandle = close > open
isBearCandle = close < open

ph_s         = ta.pivothigh(high, structLen, structLen)
pl_s         = ta.pivotlow (low,  structLen, structLen)
ph_ob        = ta.pivothigh(high, obLen, obLen)
pl_ob        = ta.pivotlow (low,  obLen, obLen)

// ══════════════════════════════════════════════════════════
// MODULE 3 — MARKET STRUCTURE (CHoCH / BOS)
// ══════════════════════════════════════════════════════════

var int   structDir     = 0
var float structHigh    = na
var int   structHighIdx = 0
var float structLow     = na
var int   structLowIdx  = 0
var line[]  sLines      = array.new_line()
var label[] sLabels     = array.new_label()

if n == 0
    structHigh    := high
    structLow     := low
    structHighIdx := 0
    structLowIdx  := 0

isHighBroken = close > structHigh and close[1] <= structHigh and n > structHighIdx
isLowBroken  = close < structLow  and close[1] >= structLow  and n > structLowIdx

var bool isCHoCH_Bull = false
var bool isCHoCH_Bear = false
var bool isBOS_Bull   = false
var bool isBOS_Bear   = false
isCHoCH_Bull := false
isCHoCH_Bear := false
isBOS_Bull   := false
isBOS_Bear   := false

if isLowBroken
    isCHoCH_Bear := structDir != -1
    isBOS_Bear   := structDir == -1
    _c = structDir == -1 ? bosCol : chochBearCol
    _t = structDir == -1 ? "BOS"  : "CHoCH"
    if (showBOS and structDir == -1) or (showCHoCH and structDir != -1)
        array.push(sLines,  line.new(structLowIdx, structLow, n, structLow, color=_c))
        array.push(sLabels, label.new((structLowIdx + n) / 2, structLow, _t,
                             style=label.style_none, textcolor=_c, size=size.tiny))
        if array.size(sLines) > 40
            line.delete(array.shift(sLines))
            label.delete(array.shift(sLabels))
    structDir     := -1
    structLowIdx  := n
    structLow     := low
    structHighIdx := n
    structHigh    := high

else if isHighBroken
    isCHoCH_Bull := structDir != 1
    isBOS_Bull   := structDir == 1
    _c = structDir == 1 ? bosCol : chochBullCol
    _t = structDir == 1 ? "BOS"  : "CHoCH"
    if (showBOS and structDir == 1) or (showCHoCH and structDir != 1)
        array.push(sLines,  line.new(structHighIdx, structHigh, n, structHigh, color=_c))
        array.push(sLabels, label.new((structHighIdx + n) / 2, structHigh, _t,
                             style=label.style_none, textcolor=_c, size=size.tiny))
        if array.size(sLines) > 40
            line.delete(array.shift(sLines))
            label.delete(array.shift(sLabels))
    structDir     := 1
    structHighIdx := n
    structHigh    := high
    structLowIdx  := n
    structLow     := low

else
    if high > structHigh
        structHigh    := high
        structHighIdx := n
    if low < structLow
        structLow    := low
        structLowIdx := n

var line curHL = na
var line curLL = na
line.delete(curHL)
line.delete(curLL)
curHL := line.new(structHighIdx, structHigh, n + 5, structHigh,
          color=color.new(color.blue, 65), style=line.style_dotted, width=1)
curLL := line.new(structLowIdx,  structLow,  n + 5, structLow,
          color=color.new(color.blue, 65), style=line.style_dotted, width=1)

// ══════════════════════════════════════════════════════════
// MODULE 4 — FAIR VALUE GAPS
// ══════════════════════════════════════════════════════════

isBullFVG = high[2] < low[0]
isBearFVG = low[2]  > high[0]

type FVGData
    box  b
    bool bull
    bool mitigated

var FVGData[] fvgArr = array.new<FVGData>()

if isBullFVG and showFVG
    nb = box.new(n - 2, low[0], n + 5, high[2],
         bgcolor=bullFVGcol, border_color=color.new(#00E676, 50),
         text="FVG", text_color=color.new(#00E676, 40), text_size=size.tiny)
    array.unshift(fvgArr, FVGData.new(nb, true, false))
    if array.size(fvgArr) > fvgMaxShow * 2
        box.delete(array.pop(fvgArr).b)

if isBearFVG and showFVG
    nb = box.new(n - 2, low[2], n + 5, high[0],
         bgcolor=bearFVGcol, border_color=color.new(#FF5252, 50),
         text="FVG", text_color=color.new(#FF5252, 40), text_size=size.tiny)
    array.unshift(fvgArr, FVGData.new(nb, false, false))
    if array.size(fvgArr) > fvgMaxShow * 2
        box.delete(array.pop(fvgArr).b)

var bool insideBullFVG = false
var bool insideBearFVG = false
insideBullFVG := false
insideBearFVG := false

if array.size(fvgArr) > 0
    for i = 0 to array.size(fvgArr) - 1
        fvg = array.get(fvgArr, i)
        if not na(fvg.b)
            tp_ = fvg.b.get_top()
            bt_ = fvg.b.get_bottom()
            fvg.b.set_right(n + 5)
            if fvg.bull
                if low <= bt_
                    fvg.mitigated := true
                    fvg.b.set_bgcolor(mitigFVGcol)
                    fvg.b.set_border_color(color.new(#9E9E9E, 50))
                if close >= bt_ and close <= tp_
                    insideBullFVG := true
            else
                if high >= tp_
                    fvg.mitigated := true
                    fvg.b.set_bgcolor(mitigFVGcol)
                    fvg.b.set_border_color(color.new(#9E9E9E, 50))
                if close <= tp_ and close >= bt_
                    insideBearFVG := true

// ══════════════════════════════════════════════════════════
// MODULE 5 — ORDER BLOCKS
// ══════════════════════════════════════════════════════════

type OBData
    float top
    float bot
    int   loc
    bool  breaker

var OBData[] bullOBArr = array.new<OBData>()
var OBData[] bearOBArr = array.new<OBData>()

var float obSH  = na
var int   obSHi = 0
var bool  obSHx = false
var float obSL  = na
var int   obSLi = 0
var bool  obSLx = false

if not na(ph_ob)
    obSH  := ph_ob
    obSHi := n - obLen
    obSHx := false

if not na(pl_ob)
    obSL  := pl_ob
    obSLi := n - obLen
    obSLx := false

if showOB and not na(obSH) and close > obSH and not obSHx
    obSHx    := true
    lookback  = math.min(math.max(n - obSLi, 1), 50)
    minV      = low[1]
    maxV      = math.max(open[1], close[1])
    for k = 1 to lookback
        if not na(low[k]) and low[k] <= minV
            minV := low[k]
            maxV := math.max(open[k], close[k])
    array.unshift(bullOBArr, OBData.new(maxV, minV, n - 1, false))
    if array.size(bullOBArr) > maxBullOB + 5
        array.pop(bullOBArr)

if showOB and not na(obSL) and close < obSL and not obSLx
    obSLx    := true
    lookback  = math.min(math.max(n - obSHi, 1), 50)
    maxV      = high[1]
    minV      = math.min(open[1], close[1])
    for k = 1 to lookback
        if not na(high[k]) and high[k] >= maxV
            maxV := high[k]
            minV := math.min(open[k], close[k])
    array.unshift(bearOBArr, OBData.new(maxV, minV, n - 1, false))
    if array.size(bearOBArr) > maxBearOB + 5
        array.pop(bearOBArr)

if array.size(bullOBArr) > 0
    for i = 0 to array.size(bullOBArr) - 1
        _ob = array.get(bullOBArr, i)
        if close < _ob.bot
            _ob.breaker := true

if array.size(bearOBArr) > 0
    for i = 0 to array.size(bearOBArr) - 1
        _ob = array.get(bearOBArr, i)
        if close > _ob.top
            _ob.breaker := true

inBullOB = false
inBearOB = false
if array.size(bullOBArr) > 0
    _ob0 = array.get(bullOBArr, 0)
    if not _ob0.breaker and close >= _ob0.bot and close <= _ob0.top
        inBullOB := true
if array.size(bearOBArr) > 0
    _ob0 = array.get(bearOBArr, 0)
    if not _ob0.breaker and close <= _ob0.top and close >= _ob0.bot
        inBearOB := true

var box[] bullOBVis = array.new_box()
var box[] bearOBVis = array.new_box()

if barstate.islast and showOB
    sz_b = array.size(bullOBVis)
    if sz_b > 0
        for _i = 0 to sz_b - 1
            box.delete(array.pop(bullOBVis))

    sz_r = array.size(bearOBVis)
    if sz_r > 0
        for _i = 0 to sz_r - 1
            box.delete(array.pop(bearOBVis))

    cnt = 0
    sz_bull = array.size(bullOBArr)
    if sz_bull > 0
        for i = 0 to sz_bull - 1
            _ob = array.get(bullOBArr, i)
            if cnt < maxBullOB and not _ob.breaker
                bx = box.new(_ob.loc, _ob.top, n + 10, _ob.bot,
                     bgcolor      = bullOBcol,
                     border_color = color.new(#2196F3, 30),
                     text         = "+OB",
                     text_color   = color.new(#2196F3, 20),
                     text_size    = size.tiny)
                array.push(bullOBVis, bx)
                cnt += 1

    cnt := 0
    sz_bear = array.size(bearOBArr)
    if sz_bear > 0
        for i = 0 to sz_bear - 1
            _ob = array.get(bearOBArr, i)
            if cnt < maxBearOB and not _ob.breaker
                bx = box.new(_ob.loc, _ob.top, n + 10, _ob.bot,
                     bgcolor      = bearOBcol,
                     border_color = color.new(#FF3131, 30),
                     text         = "-OB",
                     text_color   = color.new(#FF3131, 20),
                     text_size    = size.tiny)
                array.push(bearOBVis, bx)
                cnt += 1

// ══════════════════════════════════════════════════════════
// MODULE 6 — RAW SIGNAL LOGIC (trước gate)
// ══════════════════════════════════════════════════════════

var bool bullArmed  = false
var bool bearArmed  = false
var int  bullArmBar = 0
var int  bearArmBar = 0

usesFVG = str.contains(sigMode, "FVG")
usesOB  = str.contains(sigMode, "OB")
usesBOS = str.contains(sigMode, "BOS")

if isCHoCH_Bull or (isBOS_Bull and usesBOS)
    bullArmed  := true
    bullArmBar := n
    bearArmed  := false

if isCHoCH_Bear or (isBOS_Bear and usesBOS)
    bearArmed  := true
    bearArmBar := n
    bullArmed  := false

if bullArmed and n - bullArmBar > 100
    bullArmed := false
if bearArmed and n - bearArmBar > 100
    bearArmed := false

bullZone = (usesFVG and insideBullFVG) or (usesOB and inBullOB)
bearZone = (usesFVG and insideBearFVG) or (usesOB and inBearOB)

candleOkBull = not candleFilter or isBullCandle
candleOkBear = not candleFilter or isBearCandle

bullRaw = false
bearRaw = false
if sigMode == "Any CHoCH"
    bullRaw := isCHoCH_Bull and candleOkBull
    bearRaw := isCHoCH_Bear and candleOkBear
else
    bullRaw := bullArmed and bullZone and candleOkBull
    bearRaw := bearArmed and bearZone and candleOkBear

// ══════════════════════════════════════════════════════════
// MODULE 7 — ACTIVE TRADE GATE + BACKTEST ENGINE
//
//  [ĐÃ SỬA] SL / TP logic mới:
//  ┌─────────────────────────────────────────────────────┐
//  │ BUY  → SL = Lowest Low  (slLookback nến gần nhất)  │
//  │        TP = Entry + (Entry − SL)  →  R:R = 1:1     │
//  │ SELL → SL = Highest High(slLookback nến gần nhất)  │
//  │        TP = Entry − (SL − Entry)  →  R:R = 1:1     │
//  └─────────────────────────────────────────────────────┘
// ══════════════════════════════════════════════════════════

var bool  in_trade    = false
var float ae          = na
var float asl         = na
var float atp         = na
var bool  is_long     = false

var int bt_total      = 0
var int bt_wins       = 0
var int bt_losses     = 0
var int bt_long_tot   = 0
var int bt_short_tot  = 0
var int bt_long_wins  = 0
var int bt_short_wins = 0

var bool evt_win  = false
var bool evt_loss = false
evt_win  := false
evt_loss := false

// ── B1: Giải quyết lệnh đang mở ──────────────────────────
if in_trade
    if is_long
        if low <= asl
            bt_losses    += 1
            in_trade     := false
            evt_loss     := true
        else if high >= atp
            bt_wins      += 1
            bt_long_wins += 1
            in_trade     := false
            evt_win      := true
    else
        if high >= asl
            bt_losses     += 1
            in_trade      := false
            evt_loss      := true
        else if low <= atp
            bt_wins       += 1
            bt_short_wins += 1
            in_trade      := false
            evt_win       := true

// ── B2: Gate ──────────────────────────────────────────────
bullConfirm = bullRaw and not in_trade
bearConfirm = bearRaw and not in_trade

// ── B3: Đăng ký lệnh mới — SL từ đỉnh/đáy N nến, R:R = 1:1
if bullConfirm
    // SL = đáy thấp nhất của slLookback nến QUÁ KHỨ (trước nến tín hiệu)
    // Dùng low[1] làm điểm bắt đầu → không tính nến tín hiệu hiện tại
    _sl      = ta.lowest(low[1],  slLookback)
    _dist    = close - _sl              // Khoảng cách từ entry đến SL
    ae      := close
    asl     := _sl                      // SL = đáy thực của N nến trước
    atp     := close + _dist            // TP = entry + cùng khoảng cách → R:R = 1:1
    is_long := true
    in_trade    := true
    bt_total    += 1
    bt_long_tot += 1
    bullArmed   := false

if bearConfirm
    // SL = đỉnh cao nhất của slLookback nến QUÁ KHỨ (trước nến tín hiệu)
    // Dùng high[1] làm điểm bắt đầu → không tính nến tín hiệu hiện tại
    _sl       = ta.highest(high[1], slLookback)
    _dist     = _sl - close             // Khoảng cách từ entry đến SL
    ae       := close
    asl      := _sl                     // SL = đỉnh thực của N nến trước
    atp      := close - _dist           // TP = entry - cùng khoảng cách → R:R = 1:1
    is_long  := false
    in_trade     := true
    bt_total     += 1
    bt_short_tot += 1
    bearArmed    := false

// ══════════════════════════════════════════════════════════
// MODULE 8 — TP / SL VISUAL LINES & ZONES
// ══════════════════════════════════════════════════════════

var line tpLn  = na
var line slLn  = na
var line entLn = na
var box  tpBox = na
var box  slBox = na

if (evt_win or evt_loss) and showTPSL
    if not na(tpLn)  
        line.set_x2(tpLn,  n)
    if not na(slLn)  
        line.set_x2(slLn,  n)
    if not na(entLn) 
        line.set_x2(entLn, n)
    if not na(tpBox) 
        box.set_right(tpBox, n)
    if not na(slBox) 
        box.set_right(slBox, n)

if bullConfirm and showTPSL
    line.delete(tpLn),  line.delete(slLn),  line.delete(entLn)
    box.delete(tpBox),  box.delete(slBox)
    entLn := line.new(n, ae,  n + 1, ae,  color=color.new(color.yellow, 0), width=2)
    tpLn  := line.new(n, atp, n + 1, atp, color=color.new(buyCol,  0), width=1, style=line.style_dashed)
    slLn  := line.new(n, asl, n + 1, asl, color=color.new(sellCol, 0), width=1, style=line.style_dashed)
    tpBox := box.new(n, atp, n + 1, ae,  bgcolor=color.new(buyCol,  92), border_color=na)
    slBox := box.new(n, ae,  n + 1, asl, bgcolor=color.new(sellCol, 92), border_color=na)

if bearConfirm and showTPSL
    line.delete(tpLn),  line.delete(slLn),  line.delete(entLn)
    box.delete(tpBox),  box.delete(slBox)
    entLn := line.new(n, ae,  n + 1, ae,  color=color.new(color.yellow, 0), width=2)
    tpLn  := line.new(n, atp, n + 1, atp, color=color.new(buyCol,  0), width=1, style=line.style_dashed)
    slLn  := line.new(n, asl, n + 1, asl, color=color.new(sellCol, 0), width=1, style=line.style_dashed)
    tpBox := box.new(n, ae,  n + 1, atp, bgcolor=color.new(buyCol,  92), border_color=na)
    slBox := box.new(n, asl, n + 1, ae,  bgcolor=color.new(sellCol, 92), border_color=na)

if in_trade and showTPSL and not na(tpLn)
    line.set_x2(tpLn,  n + 1)
    line.set_x2(slLn,  n + 1)
    line.set_x2(entLn, n + 1)
    box.set_right(tpBox, n + 1)
    box.set_right(slBox, n + 1)

// ══════════════════════════════════════════════════════════
// MODULE 9 — SIGNAL SHAPES & WIN/LOSS LABELS
// ══════════════════════════════════════════════════════════

plotshape(showSignals and bullConfirm ? low - atr * 1.8 : na,
  title="BUY Signal",  style=shape.labelup,   location=location.absolute,
  color=buyCol,  textcolor=color.white, text="BUY",  size=size.normal)

plotshape(showSignals and bearConfirm ? high + atr * 1.8 : na,
  title="SELL Signal", style=shape.labeldown, location=location.absolute,
  color=sellCol, textcolor=color.white, text="SELL", size=size.normal)

if evt_win
    _y   = is_long ? high + atr * 2.5 : low  - atr * 2.5
    _sty = is_long ? label.style_label_down : label.style_label_up
    label.new(n, _y, "✓ WIN",
              style=_sty, color=color.new(buyCol, 15),
              textcolor=color.white, size=size.small)

if evt_loss
    _y   = is_long ? low  - atr * 2.5 : high + atr * 2.5
    _sty = is_long ? label.style_label_up : label.style_label_down
    label.new(n, _y, "✗ LOSS",
              style=_sty, color=color.new(sellCol, 15),
              textcolor=color.white, size=size.small)

if showSigLbl and showSignals
    if bullConfirm
        _trig = isCHoCH_Bull ? "CHoCH ↑" : "BOS ↑"
        _zon  = insideBullFVG ? "FVG" : "OB"
        label.new(n, low - atr * 3.5, "ICT BUY\n" + _trig + "  |  " + _zon,
          style=label.style_label_up,
          color=color.new(buyCol, 10), textcolor=color.white, size=size.small)
    if bearConfirm
        _trig = isCHoCH_Bear ? "CHoCH ↓" : "BOS ↓"
        _zon  = insideBearFVG ? "FVG" : "OB"
        label.new(n, high + atr * 3.5, "ICT SELL\n" + _trig + "  |  " + _zon,
          style=label.style_label_down,
          color=color.new(sellCol, 10), textcolor=color.white, size=size.small)

bgcolor(bullArmed ? color.new(buyCol,  94) : na, title="Bull Armed BG")
bgcolor(bearArmed ? color.new(sellCol, 94) : na, title="Bear Armed BG")

// ══════════════════════════════════════════════════════════
// MODULE 10 — BACKTEST TABLE
// ══════════════════════════════════════════════════════════

_tbPos = btPos == "Top Right"   ? position.top_right   :
         btPos == "Top Left"    ? position.top_left    :
         btPos == "Bottom Left" ? position.bottom_left : position.bottom_right

var table btTbl = table.new(_tbPos, 2, 11,
     bgcolor      = color.new(#0D1B2A, 5),
     border_color = color.new(#434651, 60),
     border_width = 1,
     frame_color  = color.new(#434651, 40),
     frame_width  = 1)

if barstate.islast and showBTTable
    wr        = bt_total     > 0 ? bt_wins       / bt_total     * 100 : 0.0
    wr_long   = bt_long_tot  > 0 ? bt_long_wins  / bt_long_tot  * 100 : 0.0
    wr_short  = bt_short_tot > 0 ? bt_short_wins / bt_short_tot * 100 : 0.0

    wrCol    = wr >= 55 ? color.new(buyCol,  10) :
               wr >= 40 ? color.orange           : color.new(sellCol, 10)
    openTxt  = in_trade ? (is_long ? "▲  LONG" : "▼  SHORT") : "—"
    openCol  = in_trade ? (is_long ? buyCol    : sellCol)     : color.gray

    table.cell(btTbl, 0, 0, "  ICT BACKTEST  ",
               text_color=color.white,
               bgcolor=color.new(#1565C0, 20), text_size=size.small)
    table.cell(btTbl, 1, 0, "  SL Lookback: " + str.tostring(slLookback) + "  ·  R:R = 1:1  ",
               text_color=color.new(#90CAF9, 0),
               bgcolor=color.new(#1565C0, 20), text_size=size.small)

    table.cell(btTbl, 0, 1, "Tổng lệnh",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 1, str.tostring(bt_total),
               text_color=color.white,  text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 2, "Thắng  ✓",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 2, str.tostring(bt_wins),
               text_color=buyCol,       text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 3, "Thua   ✗",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 3, str.tostring(bt_losses),
               text_color=sellCol,      text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 4, "Win Rate",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 4, str.tostring(wr, "#.#") + "%",
               text_color=wrCol,        text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 5, "Long  ▲",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 5,
               str.tostring(bt_long_wins) + "/" + str.tostring(bt_long_tot) +
               "  (" + str.tostring(wr_long, "#.#") + "%)",
               text_color=buyCol, text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 6, "Short ▼",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 6,
               str.tostring(bt_short_wins) + "/" + str.tostring(bt_short_tot) +
               "  (" + str.tostring(wr_short, "#.#") + "%)",
               text_color=sellCol, text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 7, "──────────",
               text_color=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(btTbl, 1, 7, "──────────",
               text_color=color.new(color.gray, 40), text_size=size.tiny)

    table.cell(btTbl, 0, 8, "Lệnh mở",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 8, openTxt,
               text_color=openCol,      text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 9, "Entry",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 9, in_trade ? str.tostring(ae, "#.##") : "—",
               text_color=in_trade ? color.yellow : color.gray,
               text_size=size.small, text_halign=text.align_right)

    table.cell(btTbl, 0, 10, "SL  /  TP",
               text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(btTbl, 1, 10,
               in_trade ? str.tostring(asl, "#.##") + "  /  " + str.tostring(atp, "#.##") : "—",
               text_color=openCol, text_size=size.small, text_halign=text.align_right)

// ══════════════════════════════════════════════════════════
// MODULE 11 — ALERTS
// ══════════════════════════════════════════════════════════
alertcondition(bullConfirm,  "🟢 ICT BUY",        "🟢 BUY | {{ticker}} {{interval}} | {{close}}")
alertcondition(bearConfirm,  "🔴 ICT SELL",       "🔴 SELL | {{ticker}} {{interval}} | {{close}}")
alertcondition(isCHoCH_Bull, "CHoCH Bullish",      "⬆️ CHoCH Bull | {{ticker}}")
alertcondition(isCHoCH_Bear, "CHoCH Bearish",      "⬇️ CHoCH Bear | {{ticker}}")
alertcondition(isBOS_Bull,   "BOS Bullish",        "⬆️ BOS Bull | {{ticker}}")
alertcondition(isBOS_Bear,   "BOS Bearish",        "⬇️ BOS Bear | {{ticker}}")
alertcondition(evt_win,      "✅ Take Profit Hit", "✅ TP Hit | {{ticker}} {{interval}}")
alertcondition(evt_loss,     "❌ Stop Loss Hit",   "❌ SL Hit | {{ticker}} {{interval}}")
````

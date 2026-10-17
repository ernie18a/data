# RSI+BL Alert v19

- url: https://www.tradingview.com/script/Ip7o06Nz/
- type: indicator
- pine_id: PUB;b2b4272ddb2e4297afe142b0f17d1bad
- version: 1.0

## Description

RSI +EMA+WMA 
RSI+BL Alert v19
Bitcoin Futures indicator — RSI 3-line + Stage Sequence system. Best on 15m–4h.
Entry Logic
LONG (3 stages in order):

RSI closes ≥ 75 (momentum)
RSI dips below EMA9 + WMA45 (pullback)
RSI crosses back up → LONG

SHORT mirrors with RSI ≤ 25.
Exit
When RSI/EMA/WMA order fully reverses.
Philosophy
Buy the dip, not the peak. Confirms trend → waits for pullback → enters on bounce.
Features

JMA Baseline trend reference
Live debug dashboard
BUY/SELL/EXIT labels on chart
Built-in alerts

Best For
✅ Swing & intraday traders
✅ Quality over quantity
❌ Not for scalping or sideways markets

Built by RonOnCrypto.com

## Source Code

````pine
//@version=6
indicator("RSI+BL Alert v19", overlay=true, max_labels_count=500, max_bars_back=5000)

// ============================================================================
// v19 — SIMPLE START
// LONG:  RSI > EMA9 > WMA45 (mỗi cấp hơn >= 0.01)
// SHORT: RSI < EMA9 < WMA45 (mỗi cấp thấp hơn >= 0.01)
// ============================================================================

// ============================================================================
// INPUTS
// ============================================================================
grp_bl = "BASELINE"
fastLen   = input.int(70,  "Fast Length", group=grp_bl)
fastPhase = input.int(5,   "Fast Phase",  group=grp_bl)
fastPower = input.int(2,   "Fast Power",  group=grp_bl)
slowLen   = input.int(150, "Slow Length", group=grp_bl)
slowPhase = input.int(0,   "Slow Phase",  group=grp_bl)
slowPower = input.int(2,   "Slow Power",  group=grp_bl)
srcBL     = input.source(close, "Source", group=grp_bl)
showBL    = input.bool(false, "Show Baseline Lines", group=grp_bl)

grp_rsi = "RSI"
rsiLen     = input.int(14, "RSI Length",   group=grp_rsi)
rsiMA_fast = input.int(9,  "RSI EMA Fast", group=grp_rsi)
rsiMA_slow = input.int(45, "RSI WMA Slow", group=grp_rsi)

grp_logic = "LOGIC"
minSpread     = input.float(0.01, "Min spread between RSI/EMA/WMA", group=grp_logic, minval=0.001, maxval=5.0, step=0.01)
momBull       = input.int(75, "DK1: Bull Momentum (RSI close >=)", group=grp_logic)
momBear       = input.int(25, "DK1: Bear Momentum (RSI close <=)", group=grp_logic)
failBull      = input.int(40, "Reset Long if RSI <",                group=grp_logic)
failBear      = input.int(60, "Reset Short if RSI >",               group=grp_logic)

grp_sig = "SIGNALS"
showSignals  = input.bool(true, "Show Entry Labels",   group=grp_sig)
cooldownBars = input.int(5,    "Signal Cooldown (bars)", group=grp_sig)

grp_dash = "DASHBOARD"
showDash = input.bool(true, "Show Debug Dashboard", group=grp_dash)

// ============================================================================
// COLORS
// ============================================================================
bullColor = color.new(#26A69A, 0)
bearColor = color.new(#EF5350, 0)
neutColor = color.new(#787B86, 0)
hdrBg     = color.new(#16213E, 0)
rowBg     = color.new(#1A1A2E, 0)

// ============================================================================
// JMA (Jurik Moving Average)
// ============================================================================
jma(src, length, phase, power) =>
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5
    beta  = 0.45 * (length - 1) / (0.45 * (length - 1) + 2.0)
    alpha = math.pow(beta, power)
    var float e0 = na
    var float e1 = na
    var float e2 = na
    e0 := (1 - alpha) * src + alpha * nz(e0[1])
    e1 := (src - e0) * (1 - beta) + beta * nz(e1[1])
    e2 := (e0 + phaseRatio * e1 - nz(e2[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    e2

// ============================================================================
// BASELINE
// ============================================================================
blFast = jma(srcBL, fastLen, fastPhase, fastPower)
blSlow = jma(srcBL, slowLen, slowPhase, slowPower)

plot(showBL ? blFast : na, "BL Fast", color=color.new(#FFD700, 0), linewidth=2)
plot(showBL ? blSlow : na, "BL Slow", color=color.new(#FF4444, 0), linewidth=2)

// ============================================================================
// RSI + MAs
// ============================================================================
rsi  = ta.rsi(close, rsiLen)
rsiE = ta.ema(rsi, rsiMA_fast)
rsiW = ta.wma(rsi, rsiMA_slow)

// ============================================================================
// LOGIC — 3 ĐK theo chuỗi sự kiện
// LONG:
//   DK1: RSI đóng nến >= 75 (quán tính tăng xác nhận) → flag1
//   DK2: RSI đi xuống qua cả EMA + WMA (WMA > EMA > RSI) → flag2
//   DK3: RSI cắt lên lại 2 MA (RSI > EMA > WMA) → ENTRY
// SHORT: ngược lại
// Reset: sau khi entry, hoặc RSI < 40 (long) / > 60 (short)
// ============================================================================

spread_R_E = rsi  - rsiE
spread_E_W = rsiE - rsiW

// Thứ tự strict
orderLong  = spread_R_E >= minSpread and spread_E_W >= minSpread       // RSI > EMA > WMA
orderShort = spread_R_E <= -minSpread and spread_E_W <= -minSpread     // RSI < EMA < WMA

// LONG flags
var bool dk1Long = false   // RSI từng đóng nến >= 75
var bool dk2Long = false   // RSI từng dưới cả 2 MA, thứ tự WMA>EMA>RSI

// DK1 LONG: RSI đóng nến >= 75 (chỉ tính khi bar đóng)
if barstate.isconfirmed and rsi >= momBull
    dk1Long := true

// DK2 LONG: phải có dk1 trước, RSI dưới cả 2 MA và thứ tự WMA>EMA>RSI
if dk1Long and orderShort
    dk2Long := true

// SHORT flags
var bool dk1Short = false
var bool dk2Short = false

// DK1 SHORT: RSI đóng nến <= 25
if barstate.isconfirmed and rsi <= momBear
    dk1Short := true

// DK2 SHORT: phải có dk1 trước, RSI trên cả 2 MA và thứ tự RSI>EMA>WMA
if dk1Short and orderLong
    dk2Short := true

// DK3 LONG/SHORT: cắt lên/xuống lại qua 2 MA
isLong  = dk1Long  and dk2Long  and orderLong
isShort = dk1Short and dk2Short and orderShort

// Reset flags khi RSI fail
if rsi < failBull
    dk1Long := false
    dk2Long := false
if rsi > failBear
    dk1Short := false
    dk2Short := false

// ============================================================================
// ENTRY/EXIT (chỉ fire khi vừa chuyển trạng thái)
// ============================================================================
var int posState   = 0    // 0 = flat, 1 = long, -1 = short
var int lastSigBar = 0

longEntry  = isLong  and not isLong[1]  and (bar_index - lastSigBar) > cooldownBars and posState != 1
shortEntry = isShort and not isShort[1] and (bar_index - lastSigBar) > cooldownBars and posState != -1

if longEntry
    posState   := 1
    lastSigBar := bar_index
    // Reset flags sau khi entry, đợi chu kỳ mới
    dk1Long := false
    dk2Long := false
if shortEntry
    posState   := -1
    lastSigBar := bar_index
    dk1Short := false
    dk2Short := false

// Exit LONG:  RSI < EMA < WMA (thứ tự WMA > EMA > RSI) = orderShort
// Exit SHORT: RSI > EMA > WMA (thứ tự RSI > EMA > WMA) = orderLong
exitLong  = posState ==  1 and orderShort
exitShort = posState == -1 and orderLong

if exitLong
    posState := 0
if exitShort
    posState := 0

longSignal  = showSignals and longEntry
shortSignal = showSignals and shortEntry

// ============================================================================
// LABELS — Dính chặt vào bar, không dùng line/extend để tránh lệch
// ============================================================================
atrVal = ta.atr(14)

if longSignal
    label.new(bar_index, low,
         "BUY " + str.tostring(math.round(close, 1)),
         style=label.style_label_up,
         color=color.new(#00C853, 0),
         textcolor=color.white,
         size=size.small,
         yloc=yloc.belowbar)

if shortSignal
    label.new(bar_index, high,
         "SELL " + str.tostring(math.round(close, 1)),
         style=label.style_label_down,
         color=color.new(#F44336, 0),
         textcolor=color.white,
         size=size.small,
         yloc=yloc.abovebar)

if exitLong
    label.new(bar_index, high,
         "EXIT L",
         style=label.style_label_down,
         color=color.new(#FF9800, 0),
         textcolor=color.white,
         size=size.tiny,
         yloc=yloc.abovebar)

if exitShort
    label.new(bar_index, low,
         "EXIT S",
         style=label.style_label_up,
         color=color.new(#FF9800, 0),
         textcolor=color.white,
         size=size.tiny,
         yloc=yloc.belowbar)

// Mũi tên triangle ngay tại bar
plotshape(longSignal,  "Long Arrow",  shape.triangleup,   location.belowbar, color.new(#00C853, 0), size=size.small)
plotshape(shortSignal, "Short Arrow", shape.triangledown, location.abovebar, color.new(#F44336, 0), size=size.small)
plotshape(exitLong,    "Exit L",      shape.xcross,       location.abovebar, color.new(#FF9800, 0), size=size.tiny)
plotshape(exitShort,   "Exit S",      shape.xcross,       location.belowbar, color.new(#FF9800, 0), size=size.tiny)

// ============================================================================
// BAR COLOR
// ============================================================================
barClr = isLong ? bullColor : isShort ? bearColor : neutColor
barcolor(barClr, title="Bar Color")

// ============================================================================
// DEBUG DASHBOARD
// ============================================================================
var table dbg = table.new(position.bottom_right, 3, 11, bgcolor=rowBg, border_width=1, border_color=color.new(color.gray, 70), frame_width=1, frame_color=color.new(color.yellow, 50))

if showDash and barstate.islast
    okClr   = color.new(#00C853, 50)
    failClr = color.new(#F44336, 50)
    pendClr = color.new(#FF9800, 50)

    table.cell(dbg, 0, 0, "v19 DEBUG (3 DK)", text_color=color.yellow, text_size=size.tiny, bgcolor=hdrBg, text_halign=text.align_center)
    table.merge_cells(dbg, 0, 0, 2, 0)

    // Values
    table.cell(dbg, 0, 1, "RSI",   text_color=color.gray,  text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 1, str.tostring(rsi,  "#.00"), text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 1, "", bgcolor=rowBg)

    table.cell(dbg, 0, 2, "EMA9",  text_color=color.gray,  text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 2, str.tostring(rsiE, "#.00"), text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 2, "", bgcolor=rowBg)

    table.cell(dbg, 0, 3, "WMA45", text_color=color.gray,  text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 3, str.tostring(rsiW, "#.00"), text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 3, "", bgcolor=rowBg)

    // DK1 LONG
    table.cell(dbg, 0, 4, "DK1 L (>=75)", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 4, dk1Long ? "DONE" : "wait", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 4, dk1Long ? "OK" : "--", text_color=color.white, text_size=size.tiny, bgcolor=dk1Long ? okClr : pendClr, text_halign=text.align_center)

    // DK2 LONG
    table.cell(dbg, 0, 5, "DK2 L (dip)", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 5, dk2Long ? "DONE" : "wait", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 5, dk2Long ? "OK" : "--", text_color=color.white, text_size=size.tiny, bgcolor=dk2Long ? okClr : pendClr, text_halign=text.align_center)

    // DK1 SHORT
    table.cell(dbg, 0, 6, "DK1 S (<=25)", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 6, dk1Short ? "DONE" : "wait", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 6, dk1Short ? "OK" : "--", text_color=color.white, text_size=size.tiny, bgcolor=dk1Short ? okClr : pendClr, text_halign=text.align_center)

    // DK2 SHORT
    table.cell(dbg, 0, 7, "DK2 S (rise)", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 7, dk2Short ? "DONE" : "wait", text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 7, dk2Short ? "OK" : "--", text_color=color.white, text_size=size.tiny, bgcolor=dk2Short ? okClr : pendClr, text_halign=text.align_center)

    // Order check
    orderTxt = orderLong ? "R>E>W" : orderShort ? "W>E>R" : "mixed"
    orderBg  = orderLong ? okClr : orderShort ? failClr : pendClr
    table.cell(dbg, 0, 8, "Order",   text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 1, 8, orderTxt,  text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
    table.cell(dbg, 2, 8, "",        text_color=color.white, text_size=size.tiny, bgcolor=orderBg)

    // Position
    posTxt = posState == 1 ? "IN LONG" : posState == -1 ? "IN SHORT" : "FLAT"
    posBg  = posState == 1 ? color.new(bullColor, 30) : posState == -1 ? color.new(bearColor, 30) : color.new(neutColor, 60)
    table.cell(dbg, 0, 9, posTxt, text_color=color.white, text_size=size.tiny, bgcolor=posBg, text_halign=text.align_center)
    table.merge_cells(dbg, 0, 9, 2, 9)

    // Verdict
    verdictTxt = isLong ? ">> LONG READY <<" : isShort ? ">> SHORT READY <<" : dk1Long and dk2Long ? "L: wait DK3" : dk1Long ? "L: wait DK2" : dk1Short and dk2Short ? "S: wait DK3" : dk1Short ? "S: wait DK2" : "WAIT DK1"
    verdictBg  = isLong ? color.new(bullColor, 20) : isShort ? color.new(bearColor, 20) : color.new(neutColor, 60)
    table.cell(dbg, 0, 10, verdictTxt, text_color=color.white, text_size=size.tiny, bgcolor=verdictBg, text_halign=text.align_center)
    table.merge_cells(dbg, 0, 10, 2, 10)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(longEntry,  "LONG Entry",  "v19 LONG entry - RSI > EMA > WMA")
alertcondition(shortEntry, "SHORT Entry", "v19 SHORT entry - RSI < EMA < WMA")
alertcondition(exitLong,   "Exit Long",   "v19 Exit LONG - lost order")
alertcondition(exitShort,  "Exit Short",  "v19 Exit SHORT - lost order")
````

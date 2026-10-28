# CandleSignal_En

- url: https://www.tradingview.com/script/PBsDA1op/
- type: indicator
- pine_id: PUB;60e99f910be84d338a63a010d1daafeb
- version: 1.0

## Description

📊 Script Description
5_CandleSignal is an advanced TradingView indicator based on a 3-candle pattern (C1-C2-C3) combined with institutional Order Block (OB) detection, a moving average trend filter, and automatic Stop Loss / Take Profit level management.

The script identifies high-probability entry points by leveraging:

Liquidity sweeps (break of a high/low followed by a reclaim)

Order Blocks as institutional confluence zones

Displacement (impulsive move with ATR-based volatility)

Trend filter on a customizable timeframe

It is designed for intraday traders on the M5 timeframe, providing clear signals (★ BUY / ★ SELL) and warning alerts (⚠OB) when a signal is near an opposite Order Block.

🧠 How the C1-C2-C3 Pattern Works
Phase 1 — C1 (Reference Candle)
The script stores the high and low of the first valid candle. Two gray lines are drawn on the chart (C1 High / C1 Low).

Phase 2 — C2 (Setup)
It waits for a candle that:

Breaks C1's low (sweep down) but not the high, then closes back inside C1's range → BUY setup

Breaks C1's high (sweep up) but not the low, then closes back inside C1's range → SELL setup

When the setup is valid, the C1 lines turn fuchsia and the script enters breakout-waiting mode.

Phase 3 — C3 (Confirmation / Trigger)
The signal triggers when:

BUY: price breaks C1's high upward (+ ATR buffer)

SELL: price breaks C1's low downward (− ATR buffer)

Confirmation must also respect the MA filter (price above/below the moving average), unless C1 or C2 touched a matching Order Block (MA bypass).

🎯 How to Use the Signals — Entry
✅ BUY Signal (★ yellow below the candle)
Entry: at the close of candle C3 that breaks C1 High

Ideal confirmations:

Price above the MA (trend filter active)

"OB" label below the signal → confluence with a bullish Order Block (stronger signal)

No ⚠OB (warning) above the signal

❌ SELL Signal (★ red above the candle)
Entry: at the close of candle C3 that breaks C1 Low

Ideal confirmations:

Price below the MA

"OB" label above the signal → confluence with a bearish Order Block

No ⚠OB below the signal

⚠️ OB Warning (★ + colored X)
When the X appears above/below the star, it means the signal is near an opposite Order Block → possible reversal.

With "Ignore signal" mode: the signal is skipped

With "Mark with X" mode: the signal is shown but flagged → use caution or skip

🚪 How to Use the Signals — Exit
The script automatically draws a green box (TP) and a red box (SL) on the confirmed signal:

Stop Loss (SL)
BUY: below C1's low − minAtrStopMult × ATR (default 0.5 ATR)

SELL: above C1's high + minAtrStopMult × ATR

Take Profit (TP)
Calculated with a configurable R:R

Recommended exits
TP exit: when price reaches the green box

SL exit: when price reaches the red box

Early exit: if an opposite signal (opposite ★) appears before TP

Manual trailing: after 1R of profit, move SL to break-even

⚙️ Recommended Settings
🕐 Timeframe
M5 (5 minutes) — ideal for:

C1-C2-C3 patterns with well-defined liquidity sweeps

Meaningful Order Blocks

Realistic R:R ratios during the trading day

📈 Recommended R:R: 1:1.7
In Settings → Trade Levels (SL/TP) → Take Profit ratio (R:R) = 1.7

⚠️ An R:R of 1.7 with a win rate ≥ 45% is already profitable. With OB + MA filters active, the win rate typically rises.

🎛️ Recommended filters (enabled by default)
Parameter	Recommended Value
Moving Average Filter	✅ ON
MA timeframe	5
SMA period	20
Source	close
Order Block detection	✅ ON
Require displacement	✅ ON
ATR multiplier (displacement)	1.2
Bypass MA if OB touch	✅ ON
OB proximity margin	0.5 ATR
Warning OB behavior	"Mark with X"
Min SL distance beyond C1	0.5 ATR
R:R	1.7
Box extension	30 bars
🔔 Recommended alerts
Enable these alerts in TradingView:

✅ Buy Confirmed / Sell Confirmed

✅ Buy + Order Block / Sell + Order Block (strongest signals)

✅ Buy - Opposite OB Warning / Sell - Opposite OB Warning (to avoid false signals)

📋 Operational Checklist (M5 — R:R 1.7)
Before entering:

✅ The ★ signal is confirmed on a closed candle

✅ Price is on the correct side of the MA (or OB bypass applies)

✅ The "OB" confluence label is present (optional but preferable)

✅ There is NO opposite ⚠OB (otherwise skip or reduce size)

✅ The TP is far from obvious resistance/support levels

Management:

🎯 Entry at C3 close

🛑 Automatic SL (red box) — do not move it

🏁 Automatic TP (green box) at R:R 1.7

🔄 At +1R move SL to break-even

❌ If an opposite signal appears before TP → consider a manual exit

⚠️ Disclaimer
This script is not an automated trading system — it is a decision-support tool

The obRealtimeDraw parameter draws OBs even on the forming candle (repainting): disable it if you want only confirmed signals

Always test on demo and over a significant number of trades before trading with real capital

Size your position according to risk: never risk more than 1-2% of capital per trade

🎁 Quick Summary
Element	Value
Pattern	C1-C2-C3 (sweep + reclaim + breakout)
Timeframe	M5
R:R	1:1.7
Filters	MA (SMA 20) + Order Block + Displacement
BUY Signal	★ below + (OB or above MA)
SELL Signal	★ above + (OB or below MA)
Avoid	Opposite ⚠OB
SL	Beyond C1 ± 0.5 ATR
TP	Entry ± (SL distance × 1.7)
Happy trading! 📈

## Source Code

````pine
//@version=6
indicator("CandleSignal_En", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================
// INPUT
// ============================================================
grpLines          = "C1 Lines"
showLines         = input.bool(true, "Show C1 max/min lines", group=grpLines)
maxHistory        = input.int(50, "Confirmed setups (successful C1-C2-C3) to keep on chart", minval=5, maxval=200, group=grpLines)
lineColor         = input.color(color.new(color.gray, 60), "Line color (C1 waiting for C2)", group=grpLines)
setupColor        = input.color(color.new(color.fuchsia, 0), "Line color (valid C2, waiting for C3)", group=grpLines)

grpSig            = "Pattern Signals"
showBuy           = input.bool(true,  "Show BUY signals", group=grpSig)
showSell          = input.bool(true,  "Show SELL signals (mirrored)", group=grpSig)
buyColor          = input.color(color.yellow, "Buy star color", group=grpSig)
sellColor         = input.color(color.red,    "Sell star color", group=grpSig)
closeToleranceATR = input.float(0.01, "Breakout buffer beyond C1 (in ATR, 0 = triggers at exact touch)", minval=0, step=0.01, group=grpSig)

grpWarn           = "Warning OB Handling"
warnMode          = input.string("Mark with X", "Behavior when opposite OB warning is present", options=["Ignore signal", "Mark with X"], group=grpWarn)
xColor            = input.color(color.red, "X color", group=grpWarn)
xSize             = input.string("small", "X size", options=["tiny", "small", "normal", "large"], group=grpWarn)
starSize          = input.string("large", "Star size (with X warning)", options=["tiny", "small", "normal", "large"], group=grpWarn)
buyWarnColor      = input.color(color.green, "Buy star+X color (warning)", group=grpWarn)
sellWarnColor     = input.color(color.white, "Sell star+X color (warning)", group=grpWarn)

grpMA             = "Moving Average Filter"
useMaFilter       = input.bool(true, "Enable moving average trend filter", group=grpMA)
maTF              = input.timeframe("5", "MA timeframe", group=grpMA)
maLen             = input.int(20, "SMA period", minval=1, group=grpMA)
maSrc             = input.source(close, "Source", group=grpMA)
showMaPlot        = input.bool(true, "Show MA on chart", group=grpMA)
maDynamicColor    = input.bool(true, "Dynamic MA color based on trend", group=grpMA)
maColorUp         = input.color(color.lime, "MA color (price above)", group=grpMA)
maColorDown       = input.color(color.red,  "MA color (price below)", group=grpMA)
maColorFlat       = input.color(color.aqua, "MA color (fixed, if dynamic disabled)", group=grpMA)

grpOB             = "Order Block"
obEnable          = input.bool(true, "Enable Order Block detection", group=grpOB)
showObBoxes       = input.bool(true, "Show Order Block boxes on chart", group=grpOB)
obRealtimeDraw    = input.bool(true, "Draw OB also on forming candle (repainting)", group=grpOB)
useDisplacement   = input.bool(true, "Require displacement (strong breakout)", group=grpOB)
atrLen            = input.int(14, "ATR period (displacement)", minval=1, group=grpOB)
dispMult          = input.float(1.2, "ATR multiplier for displacement", minval=0.1, step=0.1, group=grpOB)
obBoxCount        = input.int(5, "Max OB per side on chart", minval=1, maxval=20, group=grpOB)
obMitigateOnClose = input.bool(true, "Mitigation on close (otherwise on wick)", group=grpOB)
obProximityATR    = input.float(0.5, "'Near' margin (in ATR)", minval=0, step=0.1, group=grpOB)
obBypassMaOnTouch = input.bool(true, "Bypass MA filter if C1 or C2 touches a matching OB", group=grpOB)
obBorderTransp    = input.int(70, "OB border transparency (0 = solid, 100 = invisible)", minval=0, maxval=100, group=grpOB)
bullObColor       = input.color(color.new(color.teal, 80), "Bullish OB box color", group=grpOB)
bearObColor       = input.color(color.new(color.orange, 80), "Bearish OB box color", group=grpOB)
warnColor         = input.color(color.new(color.fuchsia, 0), "Warning label color (opposite OB)", group=grpOB)

grpTouch          = "OB Touch Label"
showOBTouchLabel  = input.bool(true, "Show 'OB' only on first touch of an important Order Block", group=grpTouch)
obTouchMinSizeATR = input.float(1.0, "Minimum OB size to be 'important' (in ATR)", minval=0, step=0.1, group=grpTouch)
obTouchMaxLabels  = input.int(100, "Max OB Touch labels on chart", minval=5, maxval=500, group=grpTouch)

grpTrade          = "Trade Levels (SL/TP)"
showTradeBox      = input.bool(true, "Draw SL/TP box on confirmed signal", group=grpTrade)
rrRatio           = input.float(2.0, "Take Profit ratio (R:R)", minval=0.5, step=0.5, group=grpTrade)
minAtrStopMult    = input.float(0.5, "Minimum SL distance beyond C1 (in ATR)", minval=0, step=0.1, group=grpTrade)
tradeBoxBars      = input.int(30, "Box extension to the right (bars)", minval=1, group=grpTrade)
maxTradeBoxes     = input.int(10, "Max trade boxes on chart", minval=1, maxval=50, group=grpTrade)
tpBoxColor        = input.color(color.new(color.green, 85), "Take Profit box color", group=grpTrade)
slBoxColor        = input.color(color.new(color.red, 85), "Stop Loss box color", group=grpTrade)
tradeBorderTransp = input.int(40, "SL/TP box border transparency (0 = solid, 100 = invisible)", minval=0, maxval=100, group=grpTrade)
entryLineColor    = input.color(color.new(color.white, 20), "Entry line color", group=grpTrade)
showTradeLabel    = input.bool(false, "Show Entry/SL/TP labels", group=grpTrade)

grpPanel          = "Last Trade Panel"
showInfoTable     = input.bool(true, "Show last trade Entry/SL/TP panel", group=grpPanel)
infoTablePos      = input.string("Top Right", "Panel position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpPanel)

grpDbg            = "Debug"
dbgOB             = input.bool(false, "Debug: show OB touch status on C1/C2 and C3 breakout buffer", group=grpDbg)

// ============================================================
// STATE & TRADE TRACKING
// ============================================================
var int   state              = 0
var float c1High             = na
var float c1Low              = na
var line  c1HiLine           = na
var line  c1LoLine           = na
var bool  isBuySetup         = false
var bool  isSellSetup        = false

var bool c1c2TouchedBullOB  = false
var bool c1c2TouchedBearOB  = false

var bool buyTradeDrawn       = false
var bool sellTradeDrawn      = false

var int lastBullOBBar        = -1
var int lastBearOBBar        = -1

var line[] histHi            = array.new_line()
var line[] histLo            = array.new_line()

var box[]   tpBoxes          = array.new_box()
var box[]   slBoxes          = array.new_box()
var line[]  entryLines       = array.new_line()
var label[] rrLabels         = array.new_label()

var label[] obTouchLabels    = array.new_label()

var label[] warnXLabels      = array.new_label()
var label[] alertLabels      = array.new_label()
warnXMaxLabels = 100

// --- TRADE STATE TRACKING ---
var bool  inTrade            = false
var bool  activeIsLong       = false
var float activeSL           = na
var float activeTP           = na
var float activeEntry        = na

// --- LAST TRADE INFO PANEL ---
infoPos = infoTablePos == "Top Right" ? position.top_right : infoTablePos == "Top Left" ? position.top_left : infoTablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table infoTable = table.new(infoPos, 2, 5, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)

f_updateInfoTable(isLong, entryPx, slPx, tpPx, status) =>
    if showInfoTable
        table.cell(infoTable, 0, 0, "Last Signal", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=size.small)
        table.cell(infoTable, 1, 0, isLong ? "BUY" : "SELL", text_color=color.white, bgcolor=isLong ? color.new(color.green, 30) : color.new(color.red, 30), text_size=size.small)
        table.cell(infoTable, 0, 1, "Entry", text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 1, str.tostring(entryPx, "#.#####"), text_color=color.white, text_size=size.small)
        table.cell(infoTable, 0, 2, "SL", text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 2, str.tostring(slPx, "#.#####"), text_color=color.red, text_size=size.small)
        table.cell(infoTable, 0, 3, "TP", text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 3, str.tostring(tpPx, "#.#####"), text_color=color.green, text_size=size.small)
        table.cell(infoTable, 0, 4, "Status", text_color=color.white, text_size=size.small)
        table.cell(infoTable, 1, 4, status, text_color=color.white, bgcolor=status == "IN TRADE" ? color.new(color.blue, 30) : color.new(color.gray, 30), text_size=size.small)

// Handle exit from current Trade (TP or SL)
if inTrade
    if activeIsLong
        if high >= activeTP or low <= activeSL
            inTrade := false
            closedStatus = high >= activeTP ? "TP HIT" : "SL HIT"
            f_updateInfoTable(true, activeEntry, activeSL, activeTP, closedStatus)
            activeSL := na
            activeTP := na
    else
        if low <= activeTP or high >= activeSL
            inTrade := false
            closedStatus = low <= activeTP ? "TP HIT" : "SL HIT"
            f_updateInfoTable(false, activeEntry, activeSL, activeTP, closedStatus)
            activeSL := na
            activeTP := na

// Variables reset on each bar
buySignal   = false
sellSignal  = false
buyNearOB   = false
sellNearOB  = false
buyWarnOB   = false
sellWarnOB  = false

// ============================================================
// MOVING AVERAGE ON CUSTOM TIMEFRAME (trend filter)
// ============================================================
maValue = request.security(syminfo.tickerid, maTF, ta.sma(maSrc, maLen), lookahead=barmerge.lookahead_off)
maPlotColor = maDynamicColor ? (close > maValue ? maColorUp : close < maValue ? maColorDown : maColorFlat) : maColorFlat
plot(showMaPlot ? maValue : na, title="SMA Filter", color=maPlotColor, linewidth=2)

aboveMa = not useMaFilter or close > maValue
belowMa = not useMaFilter or close < maValue

// ============================================================
// ORDER BLOCK: data structures
// ============================================================
var box[]   bullBoxes   = array.new_box()
var float[] bullTop     = array.new_float()
var float[] bullBottom  = array.new_float()
var bool[]  bullTouched = array.new_bool()

var box[]   bearBoxes   = array.new_box()
var float[] bearTop     = array.new_float()
var float[] bearBottom  = array.new_float()
var bool[]  bearTouched = array.new_bool()

atrVal = ta.atr(atrLen)

// ============================================================
// ORDER BLOCK: mitigation (confirmed bars only)
// ============================================================
if barstate.isconfirmed and obEnable
    if array.size(bullBoxes) > 0
        for i = array.size(bullBoxes) - 1 to 0
            bx  = array.get(bullBoxes, i)
            bot = array.get(bullBottom, i)
            box.set_right(bx, bar_index)
            mitigated = obMitigateOnClose ? close < bot : low < bot
            if mitigated
                box.delete(bx)
                array.remove(bullBoxes, i)
                array.remove(bullTop, i)
                array.remove(bullBottom, i)
                array.remove(bullTouched, i)

    if array.size(bearBoxes) > 0
        for i = array.size(bearBoxes) - 1 to 0
            bx  = array.get(bearBoxes, i)
            top = array.get(bearTop, i)
            box.set_right(bx, bar_index)
            mitigated = obMitigateOnClose ? close > top : high > top
            if mitigated
                box.delete(bx)
                array.remove(bearBoxes, i)
                array.remove(bearTop, i)
                array.remove(bearBottom, i)
                array.remove(bearTouched, i)

// ============================================================
// ORDER BLOCK: creation
// ============================================================
if obEnable and (obRealtimeDraw or barstate.isconfirmed)
    // --- Bullish OB ---
    bullishOB = close[1] < open[1] and close > high[1] and (not useDisplacement or (close - open) > atrVal * dispMult)
    if bullishOB and bar_index != lastBullOBBar
        obTop = high[1]
        obBot = low[1]
        newBoxBull = box.new(left=bar_index[1], top=obTop, right=bar_index, bottom=obBot, border_color=color.new(bullObColor, obBorderTransp), bgcolor=showObBoxes ? bullObColor : na)
        array.push(bullBoxes, newBoxBull)
        array.push(bullTop, obTop)
        array.push(bullBottom, obBot)
        array.push(bullTouched, false)
        lastBullOBBar := bar_index
        if array.size(bullBoxes) > obBoxCount
            box.delete(array.shift(bullBoxes))
            array.shift(bullTop)
            array.shift(bullBottom)
            array.shift(bullTouched)

    // --- Bearish OB ---
    bearishOB = close[1] > open[1] and close < low[1] and (not useDisplacement or (open - close) > atrVal * dispMult)
    if bearishOB and bar_index != lastBearOBBar
        obTop = high[1]
        obBot = low[1]
        newBoxBear = box.new(left=bar_index[1], top=obTop, right=bar_index, bottom=obBot, border_color=color.new(bearObColor, obBorderTransp), bgcolor=showObBoxes ? bearObColor : na)
        array.push(bearBoxes, newBoxBear)
        array.push(bearTop, obTop)
        array.push(bearBottom, obBot)
        array.push(bearTouched, false)
        lastBearOBBar := bar_index
        if array.size(bearBoxes) > obBoxCount
            box.delete(array.shift(bearBoxes))
            array.shift(bearTop)
            array.shift(bearBottom)
            array.shift(bearTouched)

// ============================================================
// OB CHECK FUNCTIONS
// ============================================================
f_nearAnyBox(tops, bottoms, px, margin) =>
    bool found = false
    int sz = array.size(tops)
    if sz > 0
        for i = 0 to sz - 1
            t = array.get(tops, i)
            b = array.get(bottoms, i)
            if px <= t + margin and px >= b - margin
                found := true
                break
    found

f_overlapsAnyBox(tops, bottoms, lo, hi, margin) =>
    bool found = false
    int sz = array.size(tops)
    if sz > 0
        for i = 0 to sz - 1
            t = array.get(tops, i)
            b = array.get(bottoms, i)
            if hi >= b - margin and lo <= t + margin
                found := true
                break
    found

f_checkImportantTouch(tops, bottoms, touched, lo, hi, minSizeATR, atrV) =>
    bool anyNewTouch = false
    int sz = array.size(tops)
    if sz > 0
        for i = 0 to sz - 1
            already = array.get(touched, i)
            if not already
                t = array.get(tops, i)
                b = array.get(bottoms, i)
                sizeOK  = (t - b) >= atrV * minSizeATR
                overlap = hi >= b and lo <= t
                if sizeOK and overlap
                    array.set(touched, i, true)
                    anyNewTouch := true
    anyNewTouch

// ============================================================
// OB TOUCH LABELS
// ============================================================
if showOBTouchLabel and obEnable and showObBoxes
    newBullTouch = f_checkImportantTouch(bullTop, bullBottom, bullTouched, low, high, obTouchMinSizeATR, atrVal)
    newBearTouch = f_checkImportantTouch(bearTop, bearBottom, bearTouched, low, high, obTouchMinSizeATR, atrVal)
    if newBullTouch or newBearTouch
        obTouchLbl = label.new(bar_index, high, text="OB", style=label.style_label_down,
                             color=color.new(color.white, 100), textcolor=color.white, size=size.tiny)
        array.push(obTouchLabels, obTouchLbl)
        if array.size(obTouchLabels) > obTouchMaxLabels
            label.delete(array.shift(obTouchLabels))

// ============================================================
// TRADE DRAW FUNCTION
// ============================================================
f_drawTrade(isLong, entryPx, slPx) =>
    riskDist  = math.abs(entryPx - slPx)
    tpPx      = isLong ? entryPx + riskDist * rrRatio : entryPx - riskDist * rrRatio
    boxRight  = bar_index + tradeBoxBars

    if showTradeBox
        tBox = box.new(left=bar_index, top=isLong ? tpPx : entryPx, right=boxRight,
             bottom=isLong ? entryPx : tpPx, border_color=color.new(color.green, tradeBorderTransp), bgcolor=tpBoxColor)
        sBox = box.new(left=bar_index, top=isLong ? entryPx : slPx, right=boxRight,
             bottom=isLong ? slPx : entryPx, border_color=color.new(color.red, tradeBorderTransp), bgcolor=slBoxColor)
        eLine = line.new(bar_index, entryPx, boxRight, entryPx, color=entryLineColor, width=1, style=line.style_dashed)
        rrTxt = "Entry: " + str.tostring(entryPx, "#.#####") + "\nSL: " + str.tostring(slPx, "#.#####") +
             "\nTP: " + str.tostring(tpPx, "#.#####") + "\nR:R = 1:" + str.tostring(rrRatio, "#.#")
        lbl = label.new(boxRight, entryPx, text=rrTxt, style=label.style_label_left,
             color=color.new(color.black, 100),
             textcolor=showTradeLabel ? color.white : color.new(color.white, 100),
             size=size.tiny)

        array.push(tpBoxes, tBox)
        array.push(slBoxes, sBox)
        array.push(entryLines, eLine)
        array.push(rrLabels, lbl)

        if array.size(tpBoxes) > maxTradeBoxes
            box.delete(array.shift(tpBoxes))
            box.delete(array.shift(slBoxes))
            line.delete(array.shift(entryLines))
            label.delete(array.shift(rrLabels))

    tpPx

// ============================================================
// REAL-TIME CHECK (Opposite inhibition & Level update)
// ============================================================
allowBuyCheck  = state == 2 and (not inTrade or (inTrade and activeIsLong))
allowSellCheck = state == 2 and (not inTrade or (inTrade and not activeIsLong))

if allowBuyCheck or allowSellCheck
    margin = atrVal * obProximityATR
    tolBrk = atrVal * closeToleranceATR

    buyBase  = allowBuyCheck  and isBuySetup  and high >= c1High + tolBrk
    sellBase = allowSellCheck and isSellSetup and low  <= c1Low  - tolBrk

    buyNearOBcheck  = obEnable and buyBase  and f_nearAnyBox(bullTop, bullBottom, c1High, margin)
    sellNearOBcheck = obEnable and sellBase and f_nearAnyBox(bearTop, bearBottom, c1Low,  margin)

    buyWarnOBcheck  = obEnable and buyBase  and f_nearAnyBox(bearTop, bearBottom, c1High, margin)
    sellWarnOBcheck = obEnable and sellBase and f_nearAnyBox(bullTop, bullBottom, c1Low,  margin)

    buyBypassMa  = obEnable and obBypassMaOnTouch and c1c2TouchedBullOB
    sellBypassMa = obEnable and obBypassMaOnTouch and c1c2TouchedBearOB

    buyConfirm  = buyBase  and (aboveMa or buyNearOBcheck  or buyBypassMa)
    sellConfirm = sellBase and (belowMa or sellNearOBcheck or sellBypassMa)

    buyHasWarn  = buyConfirm  and buyWarnOBcheck
    sellHasWarn = sellConfirm and sellWarnOBcheck

    buySuppressed  = buyHasWarn  and warnMode == "Ignore signal"
    sellSuppressed = sellHasWarn and warnMode == "Ignore signal"

    if buyConfirm and showBuy and not buySuppressed
        buySignal := true
        buyNearOB := buyNearOBcheck
        buyWarnOB := buyHasWarn
        if not buyTradeDrawn
            slPx = c1Low - atrVal * minAtrStopMult
            tpPx = f_drawTrade(true, c1High, slPx)
            buyTradeDrawn := true

            // Activate trade if empty, or update SL/TP to new level if already active
            inTrade := true
            activeIsLong := true
            activeSL := slPx
            activeTP := tpPx
            activeEntry := c1High
            f_updateInfoTable(true, c1High, slPx, tpPx, "IN TRADE")

    if sellConfirm and showSell and not sellSuppressed
        sellSignal := true
        sellNearOB := sellNearOBcheck
        sellWarnOB := sellHasWarn
        if not sellTradeDrawn
            slPx = c1High + atrVal * minAtrStopMult
            tpPx = f_drawTrade(false, c1Low, slPx)
            sellTradeDrawn := true

            // Activate trade if empty, or update SL/TP to new level if already active
            inTrade := true
            activeIsLong := false
            activeSL := slPx
            activeTP := tpPx
            activeEntry := c1Low
            f_updateInfoTable(false, c1Low, slPx, tpPx, "IN TRADE")

// ============================================================
// STATEFUL LOGIC (confirmed bars only)
// ============================================================
if barstate.isconfirmed
    if state == 0
        c1High   := high
        c1Low    := low
        c1c2TouchedBullOB := false
        c1c2TouchedBearOB := false
        buyTradeDrawn  := false
        sellTradeDrawn := false
        if obEnable
            marginC1 = atrVal * obProximityATR
            if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC1)
                c1c2TouchedBullOB := true
            if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC1)
                c1c2TouchedBearOB := true
        if showLines
            c1HiLine := line.new(bar_index, high, bar_index + 2, high, xloc=xloc.bar_index, color=lineColor, width=1)
            c1LoLine := line.new(bar_index, low,  bar_index + 2, low,  xloc=xloc.bar_index, color=lineColor, width=1)
        state := 1

    else if state == 1
        brokeDown = low  < c1Low
        brokeUp   = high > c1High
        reclaimed = close >= c1Low and close <= c1High
        buySetup  = brokeDown and not brokeUp and reclaimed
        sellSetup = brokeUp and not brokeDown and reclaimed

        if obEnable and (buySetup or sellSetup)
            marginC2 = atrVal * obProximityATR
            if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC2)
                c1c2TouchedBullOB := true
            if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC2)
                c1c2TouchedBearOB := true

        if buySetup or sellSetup
            isBuySetup  := buySetup
            isSellSetup := sellSetup
            if showLines and not na(c1HiLine)
                line.set_color(c1HiLine, setupColor)
                line.set_color(c1LoLine, setupColor)
            state := 2
        else
            if not na(c1HiLine)
                line.delete(c1HiLine)
                line.delete(c1LoLine)
            c1High := high
            c1Low  := low
            c1c2TouchedBullOB := false
            c1c2TouchedBearOB := false
            buyTradeDrawn  := false
            sellTradeDrawn := false
            if obEnable
                marginC1 = atrVal * obProximityATR
                if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC1)
                    c1c2TouchedBullOB := true
                if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC1)
                    c1c2TouchedBearOB := true
            if showLines
                c1HiLine := line.new(x1=bar_index, y1=high, x2=bar_index + 2, y2=high, xloc=xloc.bar_index, color=lineColor, width=1)
                c1LoLine := line.new(x1=bar_index, y1=low,  x2=bar_index + 2, y2=low,  xloc=xloc.bar_index, color=lineColor, width=1)
            else
                c1HiLine := na
                c1LoLine := na
            state := 1

    else if state == 2
        margin = atrVal * obProximityATR
        tolBrkF = atrVal * closeToleranceATR

        buyBaseFinal   = isBuySetup  and high >= c1High + tolBrkF
        sellBaseFinal  = isSellSetup and low  <= c1Low  - tolBrkF

        buyNearOBFinal  = obEnable and buyBaseFinal  and f_nearAnyBox(bullTop, bullBottom, c1High, margin)
        sellNearOBFinal = obEnable and sellBaseFinal and f_nearAnyBox(bearTop, bearBottom, c1Low,  margin)

        buyBypassMaFinal  = obEnable and obBypassMaOnTouch and c1c2TouchedBullOB
        sellBypassMaFinal = obEnable and obBypassMaOnTouch and c1c2TouchedBearOB

        buyConfirmFinal  = buyBaseFinal  and (aboveMa or buyNearOBFinal  or buyBypassMaFinal)
        sellConfirmFinal = sellBaseFinal and (belowMa or sellNearOBFinal or sellBypassMaFinal)

        if dbgOB
            label.new(bar_index, high,
                 text="C1C2 BullOB=" + str.tostring(c1c2TouchedBullOB) + "\nC1C2 BearOB=" + str.tostring(c1c2TouchedBearOB) +
                      "\nC1 low=" + str.tostring(c1Low, "#.#####") + " C1 high=" + str.tostring(c1High, "#.#####") +
                      "\nbuyDrawn=" + str.tostring(buyTradeDrawn) + " sellDrawn=" + str.tostring(sellTradeDrawn) +
                      "\nbuyConfirm=" + str.tostring(buyConfirmFinal) + " sellConfirm=" + str.tostring(sellConfirmFinal),
                 style=label.style_label_down, color=color.new(color.blue, 60), textcolor=color.white, size=size.tiny)

        if buyConfirmFinal or sellConfirmFinal
            if not na(c1HiLine)
                array.push(histHi, c1HiLine)
                array.push(histLo, c1LoLine)
                while array.size(histHi) > maxHistory
                    line.delete(array.shift(histHi))
                    line.delete(array.shift(histLo))
            isBuySetup  := false
            isSellSetup := false
            c1c2TouchedBullOB := false
            c1c2TouchedBearOB := false
            buyTradeDrawn  := false
            sellTradeDrawn := false
            state       := 0
        else
            if not na(c1HiLine)
                line.delete(c1HiLine)
                line.delete(c1LoLine)
            isBuySetup  := false
            isSellSetup := false
            c1High := high
            c1Low  := low
            c1c2TouchedBullOB := false
            c1c2TouchedBearOB := false
            buyTradeDrawn  := false
            sellTradeDrawn := false
            if obEnable
                marginC1 = atrVal * obProximityATR
                if f_overlapsAnyBox(bullTop, bullBottom, low, high, marginC1)
                    c1c2TouchedBullOB := true
                if f_overlapsAnyBox(bearTop, bearBottom, low, high, marginC1)
                    c1c2TouchedBearOB := true
            if showLines
                c1HiLine := line.new(x1=bar_index, y1=high, x2=bar_index + 2, y2=high, xloc=xloc.bar_index, color=lineColor, width=1)
                c1LoLine := line.new(x1=bar_index, y1=low,  x2=bar_index + 2, y2=low,  xloc=xloc.bar_index, color=lineColor, width=1)
            else
                c1HiLine := na
                c1LoLine := na
            state := 1

// ============================================================
// SIGNAL PLOT & WARNING X SIDE BY SIDE
// ============================================================
plotBuyStar  = buySignal  and not (buyWarnOB  and warnMode == "Mark with X")
plotSellStar = sellSignal and not (sellWarnOB and warnMode == "Mark with X")

plotchar(plotBuyStar,  title="Buy Star",  char="★", location=location.belowbar, color=buyColor,  size=size.small)
plotchar(plotSellStar, title="Sell Star", char="★", location=location.abovebar, color=sellColor, size=size.small)

xSizeResolved    = xSize    == "tiny" ? size.tiny : xSize    == "small" ? size.small : xSize    == "normal" ? size.normal : size.large
starSizeResolved = starSize == "tiny" ? size.tiny : starSize == "small" ? size.small : starSize == "normal" ? size.normal : size.large

// Star and X separated into two independent labels: size (starSizeResolved / xSizeResolved)
// and color (buyWarnColor / sellWarnColor) independent from "clean" signals without warning.
if buySignal and buyWarnOB and warnMode == "Mark with X"
    starLbl = label.new(bar_index, low, text="★", style=label.style_label_up, color=color.new(color.black, 100), textcolor=buyWarnColor, size=starSizeResolved)
    xLbl    = label.new(bar_index, low, text="X", style=label.style_label_down, color=color.new(color.black, 100), textcolor=buyWarnColor, size=xSizeResolved)
    array.push(warnXLabels, starLbl)
    array.push(warnXLabels, xLbl)
    if array.size(warnXLabels) > warnXMaxLabels
        label.delete(array.shift(warnXLabels))
        label.delete(array.shift(warnXLabels))

if sellSignal and sellWarnOB and warnMode == "Mark with X"
    starLbl2 = label.new(bar_index, high, text="★", style=label.style_label_down, color=color.new(color.black, 100), textcolor=sellWarnColor, size=starSizeResolved)
    xLbl2    = label.new(bar_index, high, text="X", style=label.style_label_up, color=color.new(color.black, 100), textcolor=sellWarnColor, size=xSizeResolved)
    array.push(warnXLabels, starLbl2)
    array.push(warnXLabels, xLbl2)
    if array.size(warnXLabels) > warnXMaxLabels
        label.delete(array.shift(warnXLabels))
        label.delete(array.shift(warnXLabels))

// ============================================================
// OB CONFLUENCE & WARNING LABELS (90% Transparency)
// ============================================================
if buySignal and buyNearOB
    lbl = label.new(bar_index, low, text="OB", style=label.style_label_up, color=color.new(bullObColor, 90), textcolor=color.white, size=size.tiny)
    array.push(alertLabels, lbl)
    if array.size(alertLabels) > 200
        label.delete(array.shift(alertLabels))

if sellSignal and sellNearOB
    lbl = label.new(bar_index, high, text="OB", style=label.style_label_down, color=color.new(bearObColor, 90), textcolor=color.white, size=size.tiny)
    array.push(alertLabels, lbl)
    if array.size(alertLabels) > 200
        label.delete(array.shift(alertLabels))

if buySignal and buyWarnOB
    lbl = label.new(bar_index, high, text="⚠OB", style=label.style_label_down, color=color.new(warnColor, 90), textcolor=color.white, size=size.tiny)
    array.push(alertLabels, lbl)
    if array.size(alertLabels) > 200
        label.delete(array.shift(alertLabels))

if sellSignal and sellWarnOB
    lbl = label.new(bar_index, low, text="⚠OB", style=label.style_label_up, color=color.new(warnColor, 90), textcolor=color.white, size=size.tiny)
    array.push(alertLabels, lbl)
    if array.size(alertLabels) > 200
        label.delete(array.shift(alertLabels))

// ============================================================
// ALERTS
// ============================================================
if buySignal
    alert("BUY confirmed on " + syminfo.ticker, alert.freq_once_per_bar)
if sellSignal
    alert("SELL confirmed on " + syminfo.ticker, alert.freq_once_per_bar)
if buySignal and buyNearOB
    alert("BUY confirmed + Order Block confluence on " + syminfo.ticker, alert.freq_once_per_bar)
if sellSignal and sellNearOB
    alert("SELL confirmed + Order Block confluence on " + syminfo.ticker, alert.freq_once_per_bar)
if buySignal and buyWarnOB
    alert("WARNING: BUY near bearish Order Block (possible reversal) on " + syminfo.ticker, alert.freq_once_per_bar)
if sellSignal and sellWarnOB
    alert("WARNING: SELL near bullish Order Block (possible reversal) on " + syminfo.ticker, alert.freq_once_per_bar)

alertcondition(isBuySetup  and state == 2, title="Buy Setup Pending",  message="Low sweep + reclaim: waiting for C1 breakout on C3")
alertcondition(isSellSetup and state == 2, title="Sell Setup Pending", message="High sweep + reclaim: waiting for C1 breakout on C3")
alertcondition(buySignal,  title="Buy Confirmed",  message="C3 breaks C1High: BUY pattern completed")
alertcondition(sellSignal, title="Sell Confirmed", message="C3 breaks C1Low: SELL pattern completed")
alertcondition(buySignal  and buyNearOB,  title="Buy + Order Block", message="BUY confirmed in confluence with Order Block")
alertcondition(sellSignal and sellNearOB, title="Sell + Order Block", message="SELL confirmed in confluence with Order Block")
alertcondition(buySignal  and buyWarnOB,  title="Buy - Opposite OB Warning", message="BUY near bearish Order Block: reversal risk")
alertcondition(sellSignal and sellWarnOB, title="Sell - Opposite OB Warning", message="SELL near bullish Order Block: reversal risk")
alertcondition(showOBTouchLabel, title="Important OB Touch", message="First candle touching an important Order Block")
````

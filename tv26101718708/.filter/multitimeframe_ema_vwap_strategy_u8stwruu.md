# Multi-Timeframe EMA & VWAP Strategy

- url: https://www.tradingview.com/script/U8sTwruU-Multi-Timeframe-EMA-VWAP-Strategy/
- type: indicator
- pine_id: PUB;41c2ea70820c477e940913e94efc4e1a
- version: 4.0

## Description

This Indicator uses 4 confluences to give an alert. 
EMA on the 5min
VWAP
Price Levels
Higher time frame 1H bias

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Multi-Timeframe EMA & VWAP Strategy", overlay=true, shorttitle="MTF EMA+VWAP", max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// --- Constants ---
const color BULL_EMERALD = #10b981
const color BEAR_ROSE = #f43f5e
const color VWAP_VIOLET = #8b5cf6
const color UI_DARK = #0f172a
const color UI_GRAY = #94a3b8
const int ZONE_TIME_SPAN_MS = 100 * 365 * 24 * 60 * 60 * 1000
const string EXECUTION_GROUP = "Execution Timeframe"
const string HTF_GROUP = "Higher Timeframe Bias"
const string PSYCH_GROUP = "Psychological Zones"
const string TRADE_GROUP = "Trade Management"
const string ALERT_GROUP = "Alerts"
const string APLUS_GROUP = "A++ CFD + Futures Confirmation"
const string STYLE_GROUP = "Style"

// --- Inputs ---
ema9Length = input.int(9, "9 EMA Length", minval=1, group=EXECUTION_GROUP, tooltip="Fast EMA used for the execution-timeframe crossover.")
ema20Length = input.int(20, "20 EMA Length", minval=1, group=EXECUTION_GROUP, tooltip="Slow EMA used for the execution-timeframe crossover.")
htfTimeframe = input.timeframe("60", "HTF Bias Timeframe", group=HTF_GROUP, tooltip="Higher timeframe used to determine directional bias.")
htfEmaLength = input.int(20, "HTF EMA Length", minval=1, group=HTF_GROUP, tooltip="EMA length calculated on the higher timeframe.")
psychIntervalInput = input.float(100.0, "Psychological Level Interval (Non-Indices)", minval=1.0, group=PSYCH_GROUP, tooltip="Uses 1,000 automatically on index symbols and Nasdaq/Dow futures. This value applies to non-index symbols.")
zoneWidthInput = input.float(15.0, "Zone Width (Non-Indices)", minval=0.0, group=PSYCH_GROUP, tooltip="Uses 150 points automatically on index symbols and Nasdaq/Dow futures. This value applies to non-index symbols.")

lotSize = input.float(0.1, "Lot Size", minval=0.01, step=0.01, group=TRADE_GROUP, tooltip="Position size included in setup alert messages.")
atrLen = input.int(14, "ATR Length", minval=1, group=TRADE_GROUP, tooltip="ATR length used to calculate the alert stop and target prices.")
slMult = input.float(1.5, "Stop Loss ATR Multiplier", minval=0.1, group=TRADE_GROUP, tooltip="ATR multiple used for the suggested stop loss.")
tpMult = input.float(3.0, "Take Profit ATR Multiplier", minval=0.1, group=TRADE_GROUP, tooltip="ATR multiple used for the suggested take profit.")

alertAType = input.bool(true, "Enable 4/4 Alerts", group=ALERT_GROUP, tooltip="Allow alerts when the four conditions on the active chart are satisfied.")

// The A++ calculation uses the same execution timeframe as the chart unless a separate timeframe is selected.
enableAPlusInput = input.bool(true, "Enable A++ Alerts", group=APLUS_GROUP, tooltip="A++ requires matching confirmed BUY or SELL signals from both the CFD and futures symbols on the same alignment bar.")
aPlusTimeframeInput = input.timeframe("", "A++ Alignment Timeframe", group=APLUS_GROUP, tooltip="Leave blank to use the chart timeframe. Both symbols must produce their signal on the same bar of this timeframe.")
cfdSymbolInput = input.symbol("OANDA:XAUUSD", "CFD Symbol", group=APLUS_GROUP, tooltip="Gold CFD used for the first half of the A++ confirmation.")
futuresSymbolInput = input.symbol("COMEX:GC1!", "Futures Symbol", group=APLUS_GROUP, tooltip="Gold futures continuous contract used for the second half of the A++ confirmation.")

bullColor = input.color(BULL_EMERALD, "Bullish Color", group=STYLE_GROUP, tooltip="Color used for bullish signals and targets.")
bearColor = input.color(BEAR_ROSE, "Bearish Color", group=STYLE_GROUP, tooltip="Color used for bearish signals and stops.")
vwapColor = input.color(VWAP_VIOLET, "VWAP Color", group=STYLE_GROUP, tooltip="Color used for the daily VWAP.")
zoneColor = input.color(color.new(#64748b, 70), "Zone Color", group=STYLE_GROUP, tooltip="Color used for psychological zones.")

// --- Symbol Classification ---
bool isIndexFuture = syminfo.root == "NQ" or syminfo.root == "MNQ" or syminfo.root == "YM" or syminfo.root == "MYM"
bool isIndexSymbol = syminfo.type == "index" or isIndexFuture
float psychInterval = isIndexSymbol ? 1000.0 : psychIntervalInput
float zoneWidth = isIndexSymbol ? 150.0 : zoneWidthInput
string aPlusTimeframe = aPlusTimeframeInput == "" ? timeframe.period : aPlusTimeframeInput

// --- Active Chart Calculations ---
htfEma = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfEmaLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
buyBias = close > htfEma
sellBias = close < htfEma
ema9 = ta.ema(close, ema9Length)
ema20 = ta.ema(close, ema20Length)
dailyVwap = ta.vwap
isAboveVwap = close > dailyVwap
float remainder = close % psychInterval
bool inZone = remainder <= zoneWidth or remainder >= psychInterval - zoneWidth
atrValue = ta.atr(atrLen)

longCross = ta.crossover(ema9, ema20)
shortCross = ta.crossunder(ema9, ema20)
bool longSignal = longCross and buyBias and isAboveVwap and not inZone
bool shortSignal = shortCross and sellBias and not isAboveVwap and not inZone

float slPrice = longSignal ? close - atrValue * slMult : shortSignal ? close + atrValue * slMult : na
float tpPrice = longSignal ? close + atrValue * tpMult : shortSignal ? close - atrValue * tpMult : na

// --- A++ Source Calculations ---
// Discrete values use gaps_on so a signal from one source is not carried forward and
// incorrectly matched with a later signal from the other source.
[cfdLongCross, cfdShortCross, cfdAboveVwap, cfdInZone, cfdClose, cfdAtr] = request.security(cfdSymbolInput, aPlusTimeframe, [ta.crossover(ta.ema(close, ema9Length), ta.ema(close, ema20Length)), ta.crossunder(ta.ema(close, ema9Length), ta.ema(close, ema20Length)), close > ta.vwap, (close % psychInterval) <= zoneWidth or (close % psychInterval) >= psychInterval - zoneWidth, close, ta.atr(atrLen)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[cfdHtfEma] = request.security(cfdSymbolInput, htfTimeframe, [ta.ema(close, htfEmaLength)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[futuresLongCross, futuresShortCross, futuresAboveVwap, futuresInZone, futuresClose, futuresAtr] = request.security(futuresSymbolInput, aPlusTimeframe, [ta.crossover(ta.ema(close, ema9Length), ta.ema(close, ema20Length)), ta.crossunder(ta.ema(close, ema9Length), ta.ema(close, ema20Length)), close > ta.vwap, (close % psychInterval) <= zoneWidth or (close % psychInterval) >= psychInterval - zoneWidth, close, ta.atr(atrLen)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[futuresHtfEma] = request.security(futuresSymbolInput, htfTimeframe, [ta.ema(close, htfEmaLength)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

cfdBuyBias = cfdClose > cfdHtfEma
cfdSellBias = cfdClose < cfdHtfEma
futuresBuyBias = futuresClose > futuresHtfEma
futuresSellBias = futuresClose < futuresHtfEma

cfdLongSignal = cfdLongCross and cfdBuyBias and cfdAboveVwap and not cfdInZone
cfdShortSignal = cfdShortCross and cfdSellBias and not cfdAboveVwap and not cfdInZone
futuresLongSignal = futuresLongCross and futuresBuyBias and futuresAboveVwap and not futuresInZone
futuresShortSignal = futuresShortCross and futuresSellBias and not futuresAboveVwap and not futuresInZone

// Both markets must agree on direction and signal on the same alignment bar.
aPlusLongSignal = enableAPlusInput and cfdLongSignal and futuresLongSignal
aPlusShortSignal = enableAPlusInput and cfdShortSignal and futuresShortSignal

cfdSlPrice = aPlusLongSignal ? cfdClose - cfdAtr * slMult : aPlusShortSignal ? cfdClose + cfdAtr * slMult : na
cfdTpPrice = aPlusLongSignal ? cfdClose + cfdAtr * tpMult : aPlusShortSignal ? cfdClose - cfdAtr * tpMult : na
futuresSlPrice = aPlusLongSignal ? futuresClose - futuresAtr * slMult : aPlusShortSignal ? futuresClose + futuresAtr * slMult : na
futuresTpPrice = aPlusLongSignal ? futuresClose + futuresAtr * tpMult : aPlusShortSignal ? futuresClose - futuresAtr * tpMult : na

// --- Alerts: Confirmed 4/4 Setup ---
if barstate.isconfirmed and alertAType and (longSignal or shortSignal)
    string dirStr = longSignal ? "BUY" : "SELL"
    string msg = "SETUP A (4/4) | " + dirStr + " Signal\n" +
         "Lot Size: " + str.tostring(lotSize) + "\n" +
         "Entry: " + str.tostring(close, format.price) + "\n" +
         "Stop Loss: " + str.tostring(slPrice, format.price) + "\n" +
         "Take Profit: " + str.tostring(tpPrice, format.price)
    alert(msg, alert.freq_once_per_bar_close)

alertcondition(alertAType and barstate.isconfirmed and (longSignal or shortSignal), "Setup A (4/4)", "Custom 4/4 Setup Alert")

// --- Alerts: A++ CFD + Futures Confirmation ---
if barstate.isconfirmed and (aPlusLongSignal or aPlusShortSignal)
    string aPlusDirection = aPlusLongSignal ? "BUY" : "SELL"
    string aPlusMessage = "SETUP A++ | " + aPlusDirection + " | CFD + FUTURES ALIGNED\n" +
         "CFD: " + cfdSymbolInput + "\n" +
         "CFD Entry: " + str.tostring(cfdClose, format.price) + " | SL: " + str.tostring(cfdSlPrice, format.price) + " | TP: " + str.tostring(cfdTpPrice, format.price) + "\n" +
         "Futures: " + futuresSymbolInput + "\n" +
         "Futures Entry: " + str.tostring(futuresClose, format.price) + " | SL: " + str.tostring(futuresSlPrice, format.price) + " | TP: " + str.tostring(futuresTpPrice, format.price) + "\n" +
         "Alignment timeframe: " + aPlusTimeframe
    alert(aPlusMessage, alert.freq_once_per_bar_close)

alertcondition(aPlusLongSignal and barstate.isconfirmed, "Setup A++ BUY", "A++ BUY: CFD and futures 4/4 signals aligned")
alertcondition(aPlusShortSignal and barstate.isconfirmed, "Setup A++ SELL", "A++ SELL: CFD and futures 4/4 signals aligned")

// --- Visuals: Active Chart TP/SL Lines ---
var line slLine = na
var line tpLine = na
var label slLabel = na
var label tpLabel = na

if (longSignal or shortSignal) and barstate.isconfirmed
    line.delete(slLine)
    line.delete(tpLine)
    label.delete(slLabel)
    label.delete(tpLabel)
    slLine := line.new(bar_index, slPrice, bar_index + 12, slPrice, color=color.new(bearColor, 20), style=line.style_dashed, width=1)
    tpLine := line.new(bar_index, tpPrice, bar_index + 12, tpPrice, color=color.new(bullColor, 20), style=line.style_dashed, width=1)
    slLabel := label.new(bar_index + 12, slPrice, "SL: " + str.tostring(slPrice, format.price), color=#00000000, textcolor=bearColor, style=label.style_label_left, size=size.small)
    tpLabel := label.new(bar_index + 12, tpPrice, "TP: " + str.tostring(tpPrice, format.price), color=#00000000, textcolor=bullColor, style=label.style_label_left, size=size.small)

// --- Visuals: Bias, EMAs, and VWAP ---
pPrice = plot(close, "Price Reference", color=color.new(chart.fg_color, 100), display=display.none)
pHtf = plot(htfEma, "HTF Bias Reference", color=color.new(chart.fg_color, 100), display=display.none)
fill(pPrice, pHtf, top_value=math.max(close, htfEma), bottom_value=math.min(close, htfEma), top_color=buyBias ? color.new(bullColor, 50) : color.new(bearColor, 100), bottom_color=buyBias ? color.new(bullColor, 100) : color.new(bearColor, 50), title="HTF Bias Wave Shadow")
plot(ema9, "9 EMA", color=#38bdf8, linewidth=1)
plot(ema20, "20 EMA", color=#fbbf24, linewidth=1)
plot(dailyVwap, "Daily VWAP", color=vwapColor, linewidth=2, style=plot.style_line, linestyle=plot.linestyle_dotted)

// --- Psychological Zones ---
var box[] psychBoxes = array.new_box()
var line[] psychLines = array.new_line()
var label[] psychLabels = array.new_label()

if barstate.islast
    for b in psychBoxes
        box.delete(b)
    for l in psychLines
        line.delete(l)
    for lb in psychLabels
        label.delete(lb)
    array.clear(psychBoxes)
    array.clear(psychLines)
    array.clear(psychLabels)

    float baseLevel = math.round(close / psychInterval) * psychInterval
    for i = -8 to 8
        float level = baseLevel + i * psychInterval
        int zoneLeftTime = time - ZONE_TIME_SPAN_MS
        int zoneRightTime = time + ZONE_TIME_SPAN_MS
        array.push(psychBoxes, box.new(zoneLeftTime, level + zoneWidth, zoneRightTime, level - zoneWidth, border_color=color.new(zoneColor, 30), bgcolor=color.new(zoneColor, 85), extend=extend.none, xloc=xloc.bar_time))
        array.push(psychLines, line.new(zoneLeftTime, level, zoneRightTime, level, color=color.new(zoneColor, 20), style=line.style_dotted, width=1, extend=extend.none, xloc=xloc.bar_time))
        array.push(psychLabels, label.new(zoneRightTime, level, text=str.tostring(level, format.price), color=#00000000, textcolor=color.new(zoneColor, 10), style=label.style_label_left, size=size.tiny, xloc=xloc.bar_time))

// --- Signal Labels ---
if longSignal and barstate.isconfirmed
    label.new(bar_index, low, "BUY\n4/4 CONFIRMED", yloc=yloc.belowbar, color=bullColor, textcolor=color.white, style=label.style_label_up, size=size.small)

if shortSignal and barstate.isconfirmed
    label.new(bar_index, high, "SELL\n4/4 CONFIRMED", yloc=yloc.abovebar, color=bearColor, textcolor=color.white, style=label.style_label_down, size=size.small)

if aPlusLongSignal and barstate.isconfirmed
    label.new(bar_index, low, "A++ BUY\nCFD + FUTURES", yloc=yloc.belowbar, color=#f59e0b, textcolor=color.white, style=label.style_label_up, size=size.small)

if aPlusShortSignal and barstate.isconfirmed
    label.new(bar_index, high, "A++ SELL\nCFD + FUTURES", yloc=yloc.abovebar, color=#f59e0b, textcolor=color.white, style=label.style_label_down, size=size.small)

// --- Dashboard ---
var table mainDash = table.new(position.bottom_right, 3, 6, UI_DARK, color.new(UI_GRAY, 80), 1)
if barstate.islast
    string statusText = buyBias ? "▲ SEARCHING BUYS" : "▼ SEARCHING SELLS"
    color statusColor = buyBias ? bullColor : bearColor
    string aPlusStatus = not enableAPlusInput ? "Disabled" : aPlusLongSignal ? "BUY ALIGNED" : aPlusShortSignal ? "SELL ALIGNED" : "Waiting"
    color aPlusStatusColor = aPlusLongSignal or aPlusShortSignal ? #f59e0b : UI_GRAY
    table.cell(mainDash, 0, 0, statusText, bgcolor=color.new(statusColor, 90), text_color=statusColor, text_size=size.small)
    table.merge_cells(mainDash, 0, 0, 2, 0)
    table.cell(mainDash, 0, 1, "●", text_color=bullColor)
    table.cell(mainDash, 1, 1, "Trend Bias", text_color=UI_GRAY, text_halign=text.align_left)
    table.cell(mainDash, 2, 1, buyBias ? "Bullish" : "Bearish", text_color=statusColor, text_halign=text.align_right)
    table.cell(mainDash, 0, 2, "●", text_color=bullColor)
    table.cell(mainDash, 1, 2, "Last Setup", text_color=UI_GRAY, text_halign=text.align_left)
    table.cell(mainDash, 2, 2, buyBias ? "BUY" : "SELL", text_color=statusColor, text_halign=text.align_right)
    table.cell(mainDash, 0, 3, "●", text_color=bullColor)
    table.cell(mainDash, 1, 3, "VWAP Flow", text_color=UI_GRAY, text_halign=text.align_left)
    table.cell(mainDash, 2, 3, isAboveVwap ? "Above" : "Below", text_color=isAboveVwap ? bullColor : bearColor, text_halign=text.align_right)
    table.cell(mainDash, 0, 4, "●", text_color=bullColor)
    table.cell(mainDash, 1, 4, "Psych Zone", text_color=UI_GRAY, text_halign=text.align_left)
    table.cell(mainDash, 2, 4, not inZone ? "Safe" : "No-Trade", text_color=not inZone ? bullColor : bearColor, text_halign=text.align_right)
    table.cell(mainDash, 0, 5, "●", text_color=#f59e0b)
    table.cell(mainDash, 1, 5, "A++ Status", text_color=UI_GRAY, text_halign=text.align_left)
    table.cell(mainDash, 2, 5, aPlusStatus, text_color=aPlusStatusColor, text_halign=text.align_right)
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chokambaya
````

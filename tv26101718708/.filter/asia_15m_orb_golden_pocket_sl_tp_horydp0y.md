# Asia 15M ORB + Golden Pocket + SL TP

- url: https://www.tradingview.com/script/HORydP0y-Asia-15M-ORB-Golden-Pocket-SL-TP/
- type: indicator
- pine_id: PUB;b68f900e069348b5bc44bc99bb99a7f8
- version: 4.0

## Description

Tracks the Asia session opening range from 8:00 PM to 8:15 PM ET. After the range is complete, look for a confirmed breakout above the ORB high for possible longs or below the ORB low for possible shorts. Since the Asia session can be slower and choppier, wait for a candle close outside the range and a clear retest before entering. Best used on the 5-minute chart.

## Source Code

````pine
//@version=6
indicator("Asia ORB + HTF Trend Match + VWAP", overlay=true, max_boxes_count=300, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string trendGroup = "15M HTF Trend Background"
string orbGroup = "Asia ORB"
string vwapGroup = "VWAP"
string filterGroup = "Signal Filters"
string visualGroup = "Visuals"
string sltpGroup = "SL / TP"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF TREND BACKGROUND INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string trendTF = input.timeframe("15", "HTF Trend Timeframe", group=trendGroup)

bool useClosedHTF = input.bool(true, "Use CLOSED HTF Candle Only", group=trendGroup)
bool useTrendVwapFilter = input.bool(true, "Use VWAP For HTF Trend", group=trendGroup)
bool showTrendBackground = input.bool(true, "Show HTF Trend Background", group=trendGroup)
bool showTrendEMACloud = input.bool(true, "Show HTF EMA Cloud", group=trendGroup)
bool showTrendVWAP = input.bool(false, "Show HTF VWAP", group=trendGroup)
bool showTrendTable = input.bool(true, "Show HTF Trend Table", group=trendGroup)

int trendEmaFastLen = input.int(9, "HTF Fast EMA", minval=1, group=trendGroup)
int trendEmaSlowLen = input.int(21, "HTF Slow EMA", minval=1, group=trendGroup)

color buyBgInput = input.color(color.lime, "BUY Background Color", group=trendGroup)
color sellBgInput = input.color(color.red, "SELL Background Color", group=trendGroup)
color neutralBgInput = input.color(color.gray, "Neutral Background Color", group=trendGroup)

int bgTransparency = input.int(82, "Background Transparency", minval=50, maxval=95, group=trendGroup)

color trendEmaFastColor = input.color(color.fuchsia, "HTF EMA 9 Color", group=trendGroup)
color trendEmaSlowColor = input.color(color.orange, "HTF EMA 21 Color", group=trendGroup)
color trendVwapColor = input.color(color.yellow, "HTF VWAP Color", group=trendGroup)

int trendEmaThickness = input.int(2, "HTF EMA Thickness", minval=1, maxval=5, group=trendGroup)
int trendVwapThickness = input.int(2, "HTF VWAP Thickness", minval=1, maxval=5, group=trendGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA ORB INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string timezoneInput = input.string("America/New_York", "Timezone", group=orbGroup)

string orbSession = input.session("2000-2015", "Asia Opening 15-Minute ORB", group=orbGroup)
string entrySession = input.session("2015-0200", "Allow New Entries", group=orbGroup)
string displaySession = input.session("2000-0300", "Display Asia ORB Until", group=orbGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showVWAP = input.bool(true, "Show VWAP", group=vwapGroup)
bool useVWAPFilter = input.bool(false, "Use VWAP Filter For Entries", group=vwapGroup)
color vwapColor = input.color(color.aqua, "VWAP Color", group=vwapGroup)
int vwapThickness = input.int(2, "VWAP Thickness", minval=1, maxval=5, group=vwapGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showOrbBox = input.bool(true, "Show Asia ORB Box", group=visualGroup)
bool extendOrbBox = input.bool(true, "Extend ORB Box", group=visualGroup)
bool showGoldenPocket = input.bool(true, "Show Golden Pocket", group=visualGroup)
bool showFibLabels = input.bool(true, "Show Fib Labels", group=visualGroup)

bool showSignals = input.bool(true, "Show Asia Long/Short Signals", group=visualGroup)
bool enableAlerts = input.bool(true, "Enable Alerts", group=visualGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL FILTER INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int breakoutBufferTicks = input.int(4, "Breakout Buffer Ticks", minval=0, group=filterGroup)
float minimumBodyPercent = input.float(50.0, "Breakout Candle Minimum Body %", minval=0, maxval=100, step=5, group=filterGroup)

bool requireHTFTrendMatch = input.bool(true, "Require HTF Trend Match For Signals", group=filterGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SL / TP INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showSLTP = input.bool(true, "Show SL / TP", group=sltpGroup)
float rewardRisk = input.float(1.5, "TP Risk Reward", minval=0.25, step=0.25, group=sltpGroup)
int stopBufferTicks = input.int(2, "SL Buffer Ticks", minval=0, group=sltpGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF TREND BACKGROUND LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int shift = useClosedHTF ? 1 : 0

float trendClose = request.security(syminfo.tickerid, trendTF, close[shift], barmerge.gaps_off, barmerge.lookahead_off)
float trendEMA9 = request.security(syminfo.tickerid, trendTF, ta.ema(close, trendEmaFastLen)[shift], barmerge.gaps_off, barmerge.lookahead_off)
float trendEMA21 = request.security(syminfo.tickerid, trendTF, ta.ema(close, trendEmaSlowLen)[shift], barmerge.gaps_off, barmerge.lookahead_off)
float trendVWAP = request.security(syminfo.tickerid, trendTF, ta.vwap(hlc3)[shift], barmerge.gaps_off, barmerge.lookahead_off)

bool trendEmaBull = trendEMA9 > trendEMA21
bool trendEmaBear = trendEMA9 < trendEMA21

bool trendVwapBull = trendClose > trendVWAP
bool trendVwapBear = trendClose < trendVWAP

bool bullTrend = useTrendVwapFilter ? trendEmaBull and trendVwapBull : trendEmaBull
bool bearTrend = useTrendVwapFilter ? trendEmaBear and trendVwapBear : trendEmaBear
bool neutralTrend = not bullTrend and not bearTrend

string trendText = bullTrend ? "BUYS ONLY" : bearTrend ? "SELLS ONLY" : "NEUTRAL"

color bullBg = color.new(buyBgInput, bgTransparency)
color bearBg = color.new(sellBgInput, bgTransparency)
color neutralBg = color.new(neutralBgInput, 90)

color trendBg = bullTrend ? bullBg : bearTrend ? bearBg : neutralBg

bgcolor(showTrendBackground ? trendBg : na, title="HTF Trend Background")

trendEma9Plot = plot(showTrendEMACloud ? trendEMA9 : na, "HTF EMA 9", color=trendEmaFastColor, linewidth=trendEmaThickness)
trendEma21Plot = plot(showTrendEMACloud ? trendEMA21 : na, "HTF EMA 21", color=trendEmaSlowColor, linewidth=trendEmaThickness)

color trendCloudColor = trendEMA9 > trendEMA21 ? color.new(color.lime, 88) : color.new(color.red, 88)
fill(trendEma9Plot, trendEma21Plot, color=trendCloudColor, title="HTF EMA Cloud")

plot(showTrendVWAP ? trendVWAP : na, "HTF VWAP", color=trendVwapColor, linewidth=trendVwapThickness)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REGULAR VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float vwapValue = ta.vwap(hlc3)
plot(showVWAP ? vwapValue : na, "VWAP", color=vwapColor, linewidth=vwapThickness)

bool longVWAPOkay = not useVWAPFilter or close > vwapValue
bool shortVWAPOkay = not useVWAPFilter or close < vwapValue

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF TREND TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table trendTable = table.new(position.top_right, 1, 6, border_width=1)

if barstate.islast and showTrendTable
    color tableColor = bullTrend ? color.lime : bearTrend ? color.red : color.gray
    color textColor = bullTrend ? color.black : color.white

    table.cell(trendTable, 0, 0, "HTF TREND", bgcolor=color.black, text_color=color.white)
    table.cell(trendTable, 0, 1, trendText, bgcolor=tableColor, text_color=textColor)
    table.cell(trendTable, 0, 2, "EMA 9 / 21: " + (trendEmaBull ? "Bullish" : trendEmaBear ? "Bearish" : "Flat"), bgcolor=color.black, text_color=color.white)
    table.cell(trendTable, 0, 3, "VWAP: " + (trendVwapBull ? "Above" : trendVwapBear ? "Below" : "At VWAP"), bgcolor=color.black, text_color=color.white)
    table.cell(trendTable, 0, 4, useClosedHTF ? "Closed HTF Mode" : "Live HTF Mode", bgcolor=color.black, text_color=color.white)
    table.cell(trendTable, 0, 5, requireHTFTrendMatch ? "Signals Need HTF Match" : "HTF Filter OFF", bgcolor=color.black, text_color=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA SESSION DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool inOrbSession = not na(time(timeframe.period, orbSession, timezoneInput))
bool inEntrySession = not na(time(timeframe.period, entrySession, timezoneInput))
bool inDisplaySession = not na(time(timeframe.period, displaySession, timezoneInput))

bool orbStarts = inOrbSession and not inOrbSession[1]
bool orbEnds = not inOrbSession and inOrbSession[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA ORB VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float orbHigh = na
var float orbLow = na
var bool orbReady = false

var int savedOrbStartTime = na
var int savedOrbEndTime = na

var box orbBox = na
var box goldenBox = na

var line fib618Line = na
var line fib705Line = na
var line fib79Line = na

var label fib618Label = na
var label fib705Label = na
var label fib79Label = na

var line entryLine = na
var line slLine = na
var line tpLine = na

var label entryLabel = na
var label slLabel = na
var label tpLabel = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RESET AT ASIA OPEN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if orbStarts
    orbHigh := high
    orbLow := low
    orbReady := false

    savedOrbStartTime := time
    savedOrbEndTime := na

    box.delete(orbBox)
    box.delete(goldenBox)

    line.delete(fib618Line)
    line.delete(fib705Line)
    line.delete(fib79Line)

    label.delete(fib618Label)
    label.delete(fib705Label)
    label.delete(fib79Label)

    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tpLine)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tpLabel)

    orbBox := na
    goldenBox := na

    fib618Line := na
    fib705Line := na
    fib79Line := na

    fib618Label := na
    fib705Label := na
    fib79Label := na

    entryLine := na
    slLine := na
    tpLine := na

    entryLabel := na
    slLabel := na
    tpLabel := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUILD ASIA OPENING 15-MIN ORB
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if inOrbSession
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow := math.min(nz(orbLow, low), low)

if orbEnds
    orbReady := true
    savedOrbEndTime := time

    float orbRange = orbHigh - orbLow

    float fib618 = orbLow + orbRange * 0.618
    float fib705 = orbLow + orbRange * 0.705
    float fib79 = orbLow + orbRange * 0.79

    if showOrbBox
        orbBox := box.new(
             left=savedOrbStartTime,
             top=orbHigh,
             right=savedOrbEndTime,
             bottom=orbLow,
             xloc=xloc.bar_time,
             border_color=color.rgb(255, 193, 7),
             border_width=2,
             bgcolor=color.new(color.rgb(255, 193, 7), 86))

    if showGoldenPocket
        goldenBox := box.new(
             left=savedOrbStartTime,
             top=fib79,
             right=savedOrbEndTime,
             bottom=fib618,
             xloc=xloc.bar_time,
             bgcolor=color.new(color.yellow, 82),
             border_color=color.new(color.yellow, 25))

        fib618Line := line.new(savedOrbStartTime, fib618, savedOrbEndTime, fib618, xloc=xloc.bar_time, extend=extend.none, color=color.yellow, width=2)
        fib705Line := line.new(savedOrbStartTime, fib705, savedOrbEndTime, fib705, xloc=xloc.bar_time, extend=extend.none, color=color.orange, width=2)
        fib79Line := line.new(savedOrbStartTime, fib79, savedOrbEndTime, fib79, xloc=xloc.bar_time, extend=extend.none, color=color.yellow, width=2)

        if showFibLabels
            fib618Label := label.new(savedOrbEndTime, fib618, "61.8%", xloc=xloc.bar_time, style=label.style_label_left, color=color.yellow, textcolor=color.black, size=size.tiny)
            fib705Label := label.new(savedOrbEndTime, fib705, "70.5%", xloc=xloc.bar_time, style=label.style_label_left, color=color.orange, textcolor=color.black, size=size.tiny)
            fib79Label := label.new(savedOrbEndTime, fib79, "79%", xloc=xloc.bar_time, style=label.style_label_left, color=color.yellow, textcolor=color.black, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTEND BOXES / GOLDEN POCKET / LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if orbReady and inDisplaySession
    if showOrbBox and extendOrbBox and not na(orbBox)
        box.set_right(orbBox, time_close)

    if showGoldenPocket and extendOrbBox and not na(goldenBox)
        box.set_right(goldenBox, time_close)

        if not na(fib618Line)
            line.set_x2(fib618Line, time_close)
        if not na(fib705Line)
            line.set_x2(fib705Line, time_close)
        if not na(fib79Line)
            line.set_x2(fib79Line, time_close)

        if showFibLabels
            if not na(fib618Label)
                label.set_x(fib618Label, time_close)
            if not na(fib705Label)
                label.set_x(fib705Label, time_close)
            if not na(fib79Label)
                label.set_x(fib79Label, time_close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORB PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(inDisplaySession and orbReady ? orbHigh : na, "Asia ORB High", color=color.lime, linewidth=2, style=plot.style_linebr)
plot(inDisplaySession and orbReady ? orbLow : na, "Asia ORB Low", color=color.red, linewidth=2, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LOGIC — HTF MUST MATCH BACKGROUND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float breakoutBuffer = breakoutBufferTicks * syminfo.mintick
float stopBufferAmount = stopBufferTicks * syminfo.mintick

float candleRange = high - low
float candleBody = math.abs(close - open)
float bodyPercent = candleRange > 0 ? candleBody / candleRange * 100 : 0

bool strongBullish = close > open and bodyPercent >= minimumBodyPercent
bool strongBearish = close < open and bodyPercent >= minimumBodyPercent

bool longHTFOkay = not requireHTFTrendMatch or bullTrend
bool shortHTFOkay = not requireHTFTrendMatch or bearTrend

bool longBreakout = close > orbHigh + breakoutBuffer and close[1] <= orbHigh + breakoutBuffer
bool shortBreakout = close < orbLow - breakoutBuffer and close[1] >= orbLow - breakoutBuffer

bool longSignal = orbReady and inEntrySession and longBreakout and strongBullish and longVWAPOkay and longHTFOkay
bool shortSignal = orbReady and inEntrySession and shortBreakout and strongBearish and shortVWAPOkay and shortHTFOkay

plotshape(showSignals and longSignal, title="Asia Long", text="ASIA\nLONG", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny)
plotshape(showSignals and shortSignal, title="Asia Short", text="ASIA\nSHORT", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SL / TP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showSLTP and longSignal
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tpLine)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tpLabel)

    float entryPrice = close
    float stopPrice = orbLow - stopBufferAmount
    float riskAmount = entryPrice - stopPrice
    float targetPrice = entryPrice + riskAmount * rewardRisk

    if riskAmount > syminfo.mintick
        entryLine := line.new(bar_index, entryPrice, bar_index + 50, entryPrice, color=color.white, width=2)
        slLine := line.new(bar_index, stopPrice, bar_index + 50, stopPrice, color=color.red, width=2)
        tpLine := line.new(bar_index, targetPrice, bar_index + 50, targetPrice, color=color.lime, width=2)

        entryLabel := label.new(bar_index + 50, entryPrice, "ENTRY", style=label.style_label_left, color=color.white, textcolor=color.black, size=size.tiny)
        slLabel := label.new(bar_index + 50, stopPrice, "SL", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.tiny)
        tpLabel := label.new(bar_index + 50, targetPrice, "TP", style=label.style_label_left, color=color.lime, textcolor=color.black, size=size.tiny)

if showSLTP and shortSignal
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tpLine)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tpLabel)

    float entryPrice = close
    float stopPrice = orbHigh + stopBufferAmount
    float riskAmount = stopPrice - entryPrice
    float targetPrice = entryPrice - riskAmount * rewardRisk

    if riskAmount > syminfo.mintick
        entryLine := line.new(bar_index, entryPrice, bar_index + 50, entryPrice, color=color.white, width=2)
        slLine := line.new(bar_index, stopPrice, bar_index + 50, stopPrice, color=color.red, width=2)
        tpLine := line.new(bar_index, targetPrice, bar_index + 50, targetPrice, color=color.lime, width=2)

        entryLabel := label.new(bar_index + 50, entryPrice, "ENTRY", style=label.style_label_left, color=color.white, textcolor=color.black, size=size.tiny)
        slLabel := label.new(bar_index + 50, stopPrice, "SL", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.tiny)
        tpLabel := label.new(bar_index + 50, targetPrice, "TP", style=label.style_label_left, color=color.lime, textcolor=color.black, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(enableAlerts and longSignal, "Asia ORB Long HTF Match", "Asia ORB long confirmed. HTF background is green / buys only.")
alertcondition(enableAlerts and shortSignal, "Asia ORB Short HTF Match", "Asia ORB short confirmed. HTF background is red / sells only.")

alertcondition(enableAlerts and bullTrend and not bullTrend[1], "HTF Trend Turned Bullish", "HTF trend turned bullish: BUYS ONLY.")
alertcondition(enableAlerts and bearTrend and not bearTrend[1], "HTF Trend Turned Bearish", "HTF trend turned bearish: SELLS ONLY.")
alertcondition(enableAlerts and neutralTrend and not neutralTrend[1], "HTF Trend Turned Neutral", "HTF trend turned neutral: NO TRADE.")
````

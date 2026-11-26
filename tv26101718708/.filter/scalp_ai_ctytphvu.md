# SCALP AI

- url: https://www.tradingview.com/script/ctytphvu/
- type: indicator
- pine_id: PUB;9326168690a64d2cb7c7443ed3f62ccd
- version: 1.0

## Description

This script is a collection of various trading concepts and indicators integrated into a single Pine Script file. I would like to express my sincere gratitude to the original authors whose work, ideas, and components made this compilation possible.

Core Functionalities
Dashboard & AI Scoring System:
Features a configurable dashboard showing real-time market data.

Uses a proprietary scoring mechanism based on trend analysis (EMA 20/200), RSI, volume, VWAP, ADX, and Multi-Timeframe (MTF) alignment to output signals ("A+ SETUP" to "NO TRADE").

Trend & Filter Analysis:
Uses Exponential Moving Averages (EMA) to identify trends and simple moving averages (SMA 9, 20, 89, 200) for visual filter support.

Color-coded bar highlights based on short-term EMA 9 trends.

Session Engine:
Tracks specific market sessions (NY, London, Asia, US Pre-market) with visual markers on the chart.

Includes alerts for upcoming session starts.

Levels & Price Action:
Automatically plots Daily Open, High of Day (HOD), and Low of Day (LOD) levels with extendable lines.

Features an advanced Supply & Demand zone detection system that ranks zones based on strength, mitigates broken zones, and visualizes zone strength using bar-based meters.

Multi-Timeframe Data:
Integrates multiple daily EMAs (3, 9, 20, 50, 100, 200) to help gauge long-term momentum alongside the short-term scalping logic.

The script leverages complex array structures to manage active supply and demand zones, ensuring that invalid or "broken" zones are removed from the chart, while keeping the most relevant ones ranked by a calculated score. It also utilizes request.security for multi-timeframe data fetching to provide a broader context for the current chart timeframe.

## Source Code

````pine
//@version=6
indicator("SCALP AI", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
posInput = input.string("Middle Right", "Dashboard Position",
     options=["Top Left","Top Center","Top Right",
              "Middle Left","Middle Center","Middle Right",
              "Bottom Left","Bottom Center","Bottom Right"])

sizeInput = input.string("Tiny", "Text Size",
     options=["Tiny","Small","Normal"])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION MAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dashPos =
     posInput == "Top Left" ? position.top_left :
     posInput == "Top Center" ? position.top_center :
     posInput == "Top Right" ? position.top_right :
     posInput == "Middle Left" ? position.middle_left :
     posInput == "Middle Center" ? position.middle_center :
     posInput == "Middle Right" ? position.middle_right :
     posInput == "Bottom Left" ? position.bottom_left :
     posInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

txtSize =
     sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     size.normal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE INDICATORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema20  = ta.ema(close, 20)
ema200 = ta.ema(close, 200)

rsiVal = ta.rsi(close, 14)
volMA  = ta.sma(volume, 20)
vwapVal = ta.vwap(close)

[_, _, adxVal] = ta.dmi(14, 14)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendBull = close > ema20 and ema20 > ema200
trendBear = close < ema20 and ema20 < ema200

rsiBull = rsiVal > 60
rsiBear = rsiVal < 40

volHigh = volume > volMA
vwapBull = close > vwapVal
adxStrong = adxVal > 25

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tf(tf) =>
    request.security(syminfo.tickerid, tf,
         close > ta.ema(close,20) and close > ta.ema(close,200))

t1  = f_tf("1")
t2  = f_tf("2")
t3  = f_tf("3")
t5  = f_tf("5")
t10 = f_tf("10")
t15 = f_tf("15")

align =
     (t1?1:0)+(t2?1:0)+(t3?1:0)+(t5?1:0)+(t10?1:0)+(t15?1:0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AI SCORE SYSTEM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendScore = trendBull ? 30 : trendBear ? 10 : 15
rsiScore   = rsiBull ? 20 : rsiBear ? 5 : 10
volScore   = volHigh ? 15 : 7
vwapScore  = vwapBull ? 10 : 5
adxScore   = adxStrong ? 15 : 7
mtfScore   = align * 10 / 6

score = trendScore + rsiScore + volScore + vwapScore + adxScore + mtfScore

scoreColor =
     score >= 80 ? color.rgb(0, 217, 255) :
     score >= 60 ? color.rgb(132, 255, 0) :
     score >= 40 ? color.rgb(255, 247, 0) :
     color.red

signal =
     score >= 80 ? "A+ SETUP" :
     score >= 60 ? "STRONG SETUP" :
     score >= 40 ? "WEAK SETUP" :
     "NO TRADE"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(dashPos, 2, 20,
     bgcolor=color.new(color.black,85),
     frame_color=color.new(color.gray,60))

if barstate.islast

    table.cell(dash,0,0,"SCALP AI PRO",
         text_color=color.white,
         text_size=txtSize,
         bgcolor=color.new(color.blue,80))

    table.cell(dash,1,0,signal,
         text_color=scoreColor,
         text_size=txtSize)

    table.cell(dash,0,1,"SCORE")
    table.cell(dash,1,1,str.tostring(score, "#.0"),
         text_color=scoreColor,
         text_size=txtSize)

    table.cell(dash,0,2,"TREND")
    table.cell(dash,1,2,
         trendBull ? "BULL" : trendBear ? "BEAR" : "FLAT",
         text_color=trendBull ? color.green : trendBear ? color.red : color.gray)

    table.cell(dash,0,3,"RSI")
    table.cell(dash,1,3,
         rsiBull ? "BULL" : rsiBear ? "BEAR" : "NEUTRAL",
         text_color=rsiBull ? color.green : rsiBear ? color.red : color.gray)

    table.cell(dash,0,4,"VOLUME")
    table.cell(dash,1,4,volHigh ? "HIGH" : "LOW")

    table.cell(dash,0,5,"VWAP")
    table.cell(dash,1,5,vwapBull ? "ABOVE" : "BELOW")

    table.cell(dash,0,6,"ADX")
    table.cell(dash,1,6,adxStrong ? "STRONG" : "WEAK")

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MTF ROWS (FIXED INDENTATION)
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    table.cell(dash,0,8,"TF 1m")
    table.cell(dash,1,8,t1 ? "BULL" : "BEAR",
         text_color=t1 ? color.green : color.red)

    table.cell(dash,0,9,"TF 2m")
    table.cell(dash,1,9,t2 ? "BULL" : "BEAR",
         text_color=t2 ? color.green : color.red)

    table.cell(dash,0,10,"TF 3m")
    table.cell(dash,1,10,t3 ? "BULL" : "BEAR",
         text_color=t3 ? color.green : color.red)

    table.cell(dash,0,11,"TF 5m")
    table.cell(dash,1,11,t5 ? "BULL" : "BEAR",
         text_color=t5 ? color.green : color.red)

    table.cell(dash,0,12,"TF 10m")
    table.cell(dash,1,12,t10 ? "BULL" : "BEAR",
         text_color=t10 ? color.green : color.red)

    table.cell(dash,0,13,"TF 15m")
    table.cell(dash,1,13,t15 ? "BULL" : "BEAR",
         text_color=t15 ? color.green : color.red)

    table.cell(dash,0,14,"ALIGN")
    table.cell(dash,1,14,str.tostring(align)+"/6",
         text_color=scoreColor)

//─────────────────────────────
// TREND EMA
//─────────────────────────────
ema9 = ta.ema(close, 9)

upTrend   = close > ema9
downTrend = close < ema9

barcolor(
     upTrend   ? color.rgb(62, 138, 0) :
     downTrend ? color.rgb(255, 1, 1) :
     color.gray
)

//─────────────────────────────
// SMA FILTERS
//─────────────────────────────
sma9  = ta.sma(close, 9)
sma20  = ta.sma(close, 20)
sma89  = ta.sma(close, 89)
sma200 = ta.sma(close, 200)
plot(sma9,  "SMA 9",  style = plot.style_stepline , offset = 1, color=color.rgb(118, 118, 118, 46))
plot(sma20,  "SMA 20",  style = plot.style_circles, color=color.rgb(255, 230, 0, 54))
plot(sma89,  "SMA 89",  style = plot.style_circles ,offset = 1, color=color.rgb(118, 118, 118, 46))
plot(sma200, "SMA 200", style = plot.style_circles, color=color.rgb(33, 149, 243, 47))

//────────────────────────────
// INPUTS – godziny sesji (HHMM)
//────────────────────────────
sess1 = input.int(900,  "Session 1 (HHMM)")
sess2 = input.int(1400,  "Session 1 (HHMM)")
sess3 = input.int(1530, "Session 2 (HHMM)")
sess4 = input.int(2200, "Session 3 (HHMM)")

tz = "Europe/Warsaw"

//────────────────────────────
// Helpers
//────────────────────────────
f_time(_hhmm) =>
    hour = int(_hhmm / 100)
    min  = _hhmm % 100
    timestamp(tz, year, month, dayofmonth, hour, min)

//────────────────────────────
// Session timestamps (today)
//────────────────────────────
t1q = f_time(sess1)
t2q = f_time(sess2)
t3q = f_time(sess3)
t4q = f_time(sess4)

//────────────────────────────
// Dot on session start
//────────────────────────────
isStart = (time == t1q or time == t2q or time == t3q)

plotshape(isStart, title="Session Start",
     style=shape.circle,
     location=location.abovebar,
     size=size.tiny,
     color=color.rgb(255, 255, 255))

//────────────────────────────
// ALERT: 1 minute before
// (works best on 1m timeframe)
//────────────────────────────
preAlert = (time == t1q - 60000 or time == t2q - 60000 or time == t3q - 60000)

alertcondition(preAlert, title="Session starts in 1 min",
     message="Session starts in 1 minute (PL time)")

// optional visual mark
plotshape(preAlert, title="Pre Alert",
     style=shape.circle,
     location=location.belowbar,
     size=size.tiny,
     color=color.rgb(255, 255, 255))

//─────────────────────────────
// 🌍 SESSION ENGINE
//─────────────────────────────
inNY     = not na(time(timeframe.period, "1530-2200", "Europe/Warsaw"))
inLondon = not na(time(timeframe.period, "0900-1200", "Europe/Warsaw"))
inAsia   = not na(time(timeframe.period, "0100-1000", "Europe/Warsaw"))
inUSPre  = not na(time(timeframe.period, "1400-1530", "Europe/Warsaw"))

session_state =
     inNY     ? "NY" :
     inLondon ? "LONDON" :
     inAsia   ? "ASIA" :
     inUSPre  ? "US PRE" :
     "OFF"

//─────────────────────────────
// 🎨 DASHBOARD
//─────────────────────────────

session_col =
     session_state == "NY"
     ? color.red
     : color.white

var table dashq = table.new(position.top_right, 2, 6, border_width = 1)

if barstate.islast

    table.cell(
         dashq,
         0,
         0,
         "1%",
         bgcolor = color.black,
         text_color = color.white
    )

    table.cell(
         dashq,
         1,
         0,
         timeframe.period,
         text_color = color.white
    )

    table.cell(dashq, 0, 3, "Sesja")
    table.cell(
         dashq,
         1,
         3,
         session_state,
         text_color = session_col
    )

//──────────────────────────────────────────────
// Daily OPEN
//──────────────────────────────────────────────
grp = "Levels"

showOpen = input.bool(true, "Daily Open", group = grp)
showHod  = input.bool(true, "High Of Day", group = grp)
showLod  = input.bool(true, "Low Of Day", group = grp)

openColor = input.color(color.rgb(255, 255, 255, 41), "Open Color", group = grp)
hodColor  = input.color(color.rgb(12, 0, 230, 33), "HOD Color", group = grp)
lodColor  = input.color(color.rgb(131, 0, 0, 37), "LOD Color", group = grp)

lineWidth = input.int(15, "Line Width", minval = 1, maxval = 15, group = grp)

//──────────────────────────────────────────────
// VARIABLES
//──────────────────────────────────────────────
var line openLine = na
var line hodLine  = na
var line lodLine  = na

var float dayOpen = na
var float hod = na
var float lod = na

bool newDay = ta.change(time("D")) != 0

//──────────────────────────────────────────────
// NEW DAY
//──────────────────────────────────────────────
if newDay or barstate.isfirst

    // delete previous lines
    line.delete(openLine)
    line.delete(hodLine)
    line.delete(lodLine)

    // reset values
    dayOpen := open
    hod := high
    lod := low

    // create OPEN line
    if showOpen
        openLine := line.new(
             x1 = bar_index,
             y1 = dayOpen,
             x2 = bar_index + 1,
             y2 = dayOpen,
             extend = extend.right,
             color = openColor,
             width = lineWidth
         )

    // create HOD line
    if showHod
        hodLine := line.new(
             x1 = bar_index,
             y1 = hod,
             x2 = bar_index + 1,
             y2 = hod,
             extend = extend.right,
             color = hodColor,
             width = lineWidth
         )

    // create LOD line
    if showLod
        lodLine := line.new(
             x1 = bar_index,
             y1 = lod,
             x2 = bar_index + 1,
             y2 = lod,
             extend = extend.right,
             color = lodColor,
             width = lineWidth
         )

//──────────────────────────────────────────────
// UPDATE HOD
//──────────────────────────────────────────────
if high > hod

    hod := high

    if showHod
        line.set_y1(hodLine, hod)
        line.set_y2(hodLine, hod)

//──────────────────────────────────────────────
// UPDATE LOD
//──────────────────────────────────────────────
if low < lod

    lod := low

    if showLod
        line.set_y1(lodLine, lod)
        line.set_y2(lodLine, lod)

//──────────────────────────────────────────────
// EXTEND LINES
//──────────────────────────────────────────────
if showOpen and not na(openLine)
    line.set_x2(openLine, bar_index)

if showHod and not na(hodLine)
    line.set_x2(hodLine, bar_index)

if showLod and not na(lodLine)
    line.set_x2(lodLine, bar_index)

//─────────────────────────────────────────────
// SUPPLY & DEMAND
//─────────────────────────────────────────────
atr=14
swing_length = input.int(10, "Swing Length")
history      = input.int(20, "History")
box_width    = input.float(2.5, "Box Width")

swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low  = ta.pivotlow(low, swing_length, swing_length)

var supply_boxes = array.new_box()
var demand_boxes = array.new_box()

if not na(swing_high)

    top = swing_high
    bottom = swing_high - atr * (box_width / 10)

    bx =
         box.new(
              left = bar_index[swing_length],
              top = top,
              right = bar_index + 20,
              bottom = bottom,
              bgcolor = color.new(#787b86, 67),
              border_color = color.new(#ffffff, 100),
              extend = extend.right
         )

    array.push(supply_boxes, bx)

if not na(swing_low)

    top = swing_low + atr * (box_width / 10)
    bottom = swing_low

    bx =
         box.new(
              left = bar_index[swing_length],
              top = top,
              right = bar_index + 20,
              bottom = bottom,
              bgcolor = color.new(#00bbd4, 81),
              border_color = color.new(#ffffff, 100),
              extend = extend.right
         )

    array.push(demand_boxes, bx)

//─────────────────────────────────────────────
// REMOVE BROKEN SUPPLY ZONES
//─────────────────────────────────────────────
if array.size(supply_boxes) > 0

    for i = array.size(supply_boxes) - 1 to 0

        bx = array.get(supply_boxes, i)

        if not na(bx)

            top_level = box.get_top(bx)

            if close > top_level

                box.delete(bx)
                array.remove(supply_boxes, i)

//─────────────────────────────────────────────
// REMOVE BROKEN DEMAND ZONES
//─────────────────────────────────────────────
if array.size(demand_boxes) > 0

    for i = array.size(demand_boxes) - 1 to 0

        bx = array.get(demand_boxes, i)

        if not na(bx)

            bottom_level = box.get_bottom(bx)

            if close < bottom_level

                box.delete(bx)
                array.remove(demand_boxes, i)

//─────────────────────────────
// 📌 DAILY EMA 3
//─────────────────────────────
dailyEMA3 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 3),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//─────────────────────────────
// 🎨 PLOT
//─────────────────────────────
plot(
     dailyEMA3,
     title = "Daily EMA 3",
     color = color.rgb(255, 230, 0),
     linewidth = 1
)

//─────────────────────────────
// 📌 DAILY EMA 9
//─────────────────────────────
dailyEMA9 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 9),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//─────────────────────────────
// 🎨 PLOT
//─────────────────────────────
plot(
     dailyEMA9,
     title = "Daily EMA 9",
     color = color.rgb(255, 255, 255),
     linewidth = 1
)

//─────────────────────────────
// 📌 DAILY EMA 20
//─────────────────────────────
dailyEMA20 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 20),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//─────────────────────────────
// 🎨 PLOT
//─────────────────────────────
plot(
     dailyEMA20,
     title = "Daily EMA 20",
     color = color.rgb(255, 0, 0),
     linewidth = 1
)

//─────────────────────────────
// 📌 DAILY EMA 50
//─────────────────────────────
dailyEMA50 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 50),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//─────────────────────────────
// 🎨 PLOT
//─────────────────────────────
plot(
     dailyEMA50,
     title = "Daily EMA 50",
     color = color.rgb(255, 0, 0),
     linewidth = 5
)

//─────────────────────────────
// 📌 DAILY EMA 100
//─────────────────────────────
dailyEMA100 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 100),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//─────────────────────────────
// 🎨 PLOT
//─────────────────────────────
plot(
     dailyEMA100,
     title = "Daily EMA 100",
     color = color.rgb(0, 136, 255),
     linewidth = 5
)

//─────────────────────────────
// 📌 DAILY EMA 200
//─────────────────────────────
dailyEMA200 = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, 200),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//─────────────────────────────
// 🎨 PLOT
//─────────────────────────────
plot(
     dailyEMA200,
     title = "Daily EMA 200",
     color = color.rgb(0, 89, 255),
     linewidth = 10
)

// ranked supply & demand
gRank     = "Ranking"
gDetect   = "Swing Detection"
gScore    = "Strength Engine"
gDisplay  = "Display"
gColors   = "Colors"
gBreaks   = "Breaks"

visibleLimit = input.int(8, "Show Top Zones", minval = 1, maxval = 30, group = gRank)
storedLimit  = input.int(60, "Max Stored Zones", minval = 10, maxval = 250, group = gRank)

pivotSpan      = input.int(5, "Pivot Length", minval = 2, maxval = 50, group = gDetect)
minSwingAtr    = input.float(0.15, "Min Pivot ATR", minval = 0.0, maxval = 5.0, step = 0.05, group = gDetect)
absorbAtr      = input.float(0.55, "Absorb Similar Zones", minval = 0.0, maxval = 3.0, step = 0.05, group = gDetect)
zoneAtrWidth   = input.float(0.40, "Zone Width ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = gDetect)

volLen    = input.int(20, "Volume MA Length", minval = 1, group = gScore)
trendLen  = input.int(50, "Trend EMA Length", minval = 1, group = gScore)

breakAtr  = input.float(0.12, "Break Close Buffer ATR", minval = 0.0, maxval = 3.0, step = 0.05, group = gBreaks)
keepBrokenCount = input.int(4, "Keep Broken Zones", minval = 0, maxval = 30, group = gBreaks)

directionFilter = input.string("All", "Direction Filter", options = ["All", "Support Only", "Resistance Only"], group = gDisplay)
showStrengthBars = input.bool(true, "Show Strength Bars", group = gDisplay)
showZoneText     = input.bool(false, "Show Zone Text", group = gDisplay)
strengthTextSize = input.string("auto", "Strength Text Size", options = ["auto", "tiny", "small", "normal", "large", "huge"], group = gDisplay)

supportColor    = input.color(color.rgb(26, 216, 194, 50), "Support", inline = "c", group = gColors)
resistanceColor = input.color(color.rgb(216, 76, 26, 50), "Resistance", inline = "c", group = gColors)
brokenColor     = input.color(color.rgb(148, 163, 184, 72), "Broken", group = gColors)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Core calculations {
atrRaw  = ta.atr(14)
atrq     = na(atrRaw) or atrRaw == 0 ? syminfo.mintick * 10.0 : atrRaw
volBase = ta.sma(volume, volLen)
trendBase = ta.ema(close, trendLen)
barMs     = timeframe.in_seconds(timeframe.period) * 1000

pivotHigh = ta.pivothigh(high, pivotSpan, pivotSpan)
pivotLow = ta.pivotlow(low, pivotSpan, pivotSpan)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Zone type {
type RankedZone
    float score
    float top
    float bottom
    float mid
    int   dir
    int   bornBar
    int   leftTime
    float width
    float mitigation
    float touchCount
    float volScore
    float trendScore
    float swingScore
    int   bullStrength
    int   bearStrength
    bool  broken
    line  centerLine
    box   bodyBox
    box   bullBar
    box   bearBar
    label eventLabel

var array<RankedZone> srZones = array.new<RankedZone>()
var array<RankedZone> brokenZones = array.new<RankedZone>()
var string previousLeaderKey = ""
var string lastBreakSide = "None"
var int lastBreakIndex = na

newTopRankAlert = false

supportCreatedAlert = false
resistanceCreatedAlert = false

topSupportAlert = false
topResistanceAlert = false

supportBreakAlert = false
resistanceBreakAlert = false

supportTouchAlert = false
resistanceTouchAlert = false

supportMitigatedAlert = false
resistanceMitigatedAlert = false
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Methods {
method canDisplay(RankedZone z) =>
    directionFilter == "All" or directionFilter == "Support Only" and z.dir == -1 or directionFilter == "Resistance Only" and z.dir == 1

method overlaps(RankedZone z, float newTop, float newBottom, int newDir) =>
    float overlapTop = math.min(z.top, newTop)
    float overlapBottom = math.max(z.bottom, newBottom)
    float overlap = math.max(overlapTop - overlapBottom, 0)
    float smaller = math.min(math.max(z.top - z.bottom, syminfo.mintick), math.max(newTop - newBottom, syminfo.mintick))
    bool sameSide = z.dir == newDir
    bool closeMid = math.abs(z.mid - math.avg(newTop, newBottom)) <= absorbAtr * atrq
    bool meaningfulOverlap = overlap / smaller >= 0.35
    sameSide and (closeMid or meaningfulOverlap)

method refreshGeometry(RankedZone z) =>
    line.set_y1(z.centerLine, z.mid)
    line.set_y2(z.centerLine, z.mid)
    line.set_x2(z.centerLine, bar_index + 1)
    box.set_top(z.bodyBox, z.top)
    box.set_bottom(z.bodyBox, z.bottom)
    box.set_right(z.bodyBox, time + barMs * 25)

method deleteZone(RankedZone z) =>
    line.delete(z.centerLine)
    box.delete(z.bodyBox)
    box.delete(z.bullBar)
    box.delete(z.bearBar)
    if not na(z.eventLabel)
        label.delete(z.eventLabel)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Scoring helpers {
swing_quality(float price, int dir) =>
    float quality = 0.0
    if dir == 1
        float localMax = math.max(high[pivotSpan - 1], high[pivotSpan + 1])
        quality := math.max((price - localMax) / atr, 0)
    else
        float localMin = math.min(low[pivotSpan - 1], low[pivotSpan + 1])
        quality := math.max((localMin - price) / atr, 0)
    quality

score(float width, float volScore, float trendScore, float swingScore, float mitigation, float touches, int age) =>
    float sizeNorm = math.min(width / atr, 1.0)
    float volNorm = math.min(volScore / 2.0, 1.0)
    float swingNorm = math.min(swingScore / 1.5, 1.0)
    float touchNorm = math.min(touches / 4.0, 1.0)
    float ageNorm = math.min(age / math.max(450, 1), 1.0)

    float raw = sizeNorm * 20.0 + volNorm * 18.0 + trendScore * 12.0 + swingNorm * 28.0 + touchNorm * 16.0 + 10.0
    float penalty = mitigation * 22.0 + ageNorm * 10.0
    math.max(math.min(raw - penalty, 100.0), 0.0)

strengths(int dir, float score, float trendScore, float mitigation) =>
    float scoreNorm = math.max(math.min(score, 100.0), 0.0)
    float zoneSide = scoreNorm

    if scoreNorm >= 75
        zoneSide := 72 + (scoreNorm - 75) * 1.12
    else if scoreNorm >= 45
        zoneSide := 48 + (scoreNorm - 45) * 0.75
    else
        zoneSide := scoreNorm * 1.05

    zoneSide += trendScore * 6.0
    zoneSide -= mitigation * 28.0
    zoneSide := math.max(math.min(zoneSide, 100.0), 0.0)

    float oppositeSide = 5.0 + mitigation * 65.0 + scoreNorm * 0.08
    oppositeSide := math.max(math.min(oppositeSide, 100.0), 0.0)

    int bull = dir == -1 ? int(zoneSide) : int(oppositeSide)
    int bear = dir == 1 ? int(zoneSide) : int(oppositeSide)
    [bull, bear]

zone_text(RankedZone z) =>
    string txt = ""
    if z.dir == -1
        txt := z.mitigation >= 0.75 ? "Mit S" : z.bullStrength >= 70 ? "S" : z.bullStrength >= 45 ? "" : "W"
    else
        txt := z.mitigation >= 0.75 ? "Mit R" : z.bearStrength >= 70 ? "S" : z.bearStrength >= 45 ? "" : "W"
    txt
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Create zones {
add_zone(float pivotPrice, int dir, int pivotBar, int pivotTime) =>
    float half = zoneAtrWidth * atr * 0.5
    float top = pivotPrice + half
    float bottom = pivotPrice - half
    float mid = pivotPrice
    float width = math.max(top - bottom, syminfo.mintick)
    float volScore = volBase != 0 ? volume[pivotSpan] / volBase : 1.0
    float trendScore = dir == -1 and pivotPrice > trendBase ? 1.0 : dir == 1 and pivotPrice < trendBase ? 1.0 : 0.0
    float swingScore = swing_quality(pivotPrice, dir)
    float mitigation = 0.0
    float touches = 0.0
    int age = bar_index - pivotBar
    float score = score(width, volScore, trendScore, swingScore, mitigation, touches, age)
    [bullStrength, bearStrength] = strengths(dir, score, trendScore, mitigation)

    bool absorbed = false
    bool created = false

    if srZones.size() > 0
        for i = 0 to srZones.size() - 1
            RankedZone old = srZones.get(i)
            if old.overlaps(top, bottom, dir) and not absorbed
                old.top := math.max(old.top, top)
                old.bottom := math.min(old.bottom, bottom)
                old.mid := math.avg(old.top, old.bottom)
                old.width := math.max(old.top - old.bottom, syminfo.mintick)
                old.bornBar := math.min(old.bornBar, pivotBar)
                old.leftTime := math.min(old.leftTime, pivotTime)
                old.volScore := math.max(old.volScore, volScore)
                old.trendScore := math.max(old.trendScore, trendScore)
                old.swingScore := math.max(old.swingScore, swingScore)
                old.mitigation := 0.0
                old.touchCount += 1.0
                old.score := math.max(old.score, score) + 3.0
                old.bullStrength := math.max(old.bullStrength, bullStrength)
                old.bearStrength := math.max(old.bearStrength, bearStrength)
                old.refreshGeometry()
                srZones.set(i, old)
                absorbed := true

    if not absorbed
        color baseColor = dir == -1 ? supportColor : resistanceColor
        line ln = line.new(pivotBar, mid, bar_index + 1, mid, extend = extend.right, color = color.new(baseColor, 100), width = 1)
        box bx = box.new(left = pivotTime, right = time + barMs * 5, top = top, bottom = bottom, xloc = xloc.bar_time, bgcolor = color.new(baseColor, 78), border_color = na)
        float zoneMid = math.avg(top, bottom)
        box bearBox = box.new(left = pivotTime, right = pivotTime, top = top, bottom = zoneMid, xloc = xloc.bar_time, bgcolor = resistanceColor, border_color = na)
        box bullBox = box.new(left = pivotTime, right = pivotTime, top = zoneMid, bottom = bottom, xloc = xloc.bar_time, bgcolor = supportColor, border_color = na)
        srZones.push(RankedZone.new(score, top, bottom, mid, dir, pivotBar, pivotTime, width, mitigation, touches, volScore, trendScore, swingScore, bullStrength, bearStrength, false, ln, bx, bullBox, bearBox, na))
        created := true

    created
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Add confirmed pivots {
if not na(pivotHigh)
    float sq = swing_quality(pivotHigh, 1)
    if sq >= minSwingAtr
        bool createdResistance = add_zone(pivotHigh, 1, bar_index - pivotSpan, time[pivotSpan])
        resistanceCreatedAlert := createdResistance

if not na(pivotLow)
    float sq = swing_quality(pivotLow, -1)
    if sq >= minSwingAtr
        bool createdSupport = add_zone(pivotLow, -1, bar_index - pivotSpan, time[pivotSpan])
        supportCreatedAlert := createdSupport
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Update zones {
if srZones.size() > 0
    for i = srZones.size() - 1 to 0
        RankedZone z = srZones.get(i)
        int age = bar_index - z.bornBar
        bool expired = age > 450
        bool touched = high >= z.bottom and low <= z.top
        bool brokenSupport = z.dir == -1 and close < z.bottom - breakAtr * atrq
        bool brokenResistance = z.dir == 1 and close > z.top + breakAtr * atrq

        if touched and not brokenSupport and not brokenResistance
            bool wasUnderMitigationThreshold = z.mitigation < 0.75

            supportTouchAlert := supportTouchAlert or z.dir == -1
            resistanceTouchAlert := resistanceTouchAlert or z.dir == 1

            z.touchCount += 0.20
            float fillDistance = z.dir == -1 ? z.top - low : high - z.bottom
            z.mitigation := math.min(math.max(fillDistance / math.max(z.width, syminfo.mintick), 0.0), 1.0)

            supportMitigatedAlert := supportMitigatedAlert or z.dir == -1 and wasUnderMitigationThreshold and z.mitigation >= 0.75
            resistanceMitigatedAlert := resistanceMitigatedAlert or z.dir == 1 and wasUnderMitigationThreshold and z.mitigation >= 0.75

        z.score := score(z.width, z.volScore, z.trendScore, z.swingScore, z.mitigation, z.touchCount, age)
        [newBull, newBear] = strengths(z.dir, z.score, z.trendScore, z.mitigation)
        z.bullStrength := newBull
        z.bearStrength := newBear

        if expired
            z.deleteZone()
            srZones.remove(i)
        else if brokenSupport or brokenResistance
            z.broken := true
            lastBreakSide := brokenResistance ? "Bullish Break" : "Bearish Break"
            lastBreakIndex := bar_index
            supportBreakAlert := supportBreakAlert or brokenSupport
            resistanceBreakAlert := resistanceBreakAlert or brokenResistance

            line.set_color(z.centerLine, color.new(brokenColor, 0))
            line.set_style(z.centerLine, line.style_dotted)
            line.set_extend(z.centerLine, extend.none)
            line.set_x2(z.centerLine, bar_index)
            box.set_bgcolor(z.bodyBox, color.new(brokenColor, 88))
            box.set_border_color(z.bodyBox, na)
            box.set_right(z.bodyBox, time)
            box.set_bgcolor(z.bullBar, color.new(color.gray, 100))
            box.set_bgcolor(z.bearBar, color.new(color.gray, 100))

            if keepBrokenCount > 0
                brokenZones.push(z)
                while brokenZones.size() > keepBrokenCount
                    RankedZone oldBroken = brokenZones.shift()
                    oldBroken.deleteZone()
            else
                z.deleteZone()

            srZones.remove(i)
        else
            z.refreshGeometry()
            srZones.set(i, z)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Sort and limit zones {
srZones.sort(order.descending, sort_field = "score")

if srZones.size() > 0
    RankedZone leader = srZones.get(0)
    string leaderKey = str.tostring(leader.leftTime) + "_" + str.tostring(leader.dir)
    bool newLeader = leaderKey != previousLeaderKey

    newTopRankAlert := newLeader
    topSupportAlert := newLeader and leader.dir == -1
    topResistanceAlert := newLeader and leader.dir == 1

    previousLeaderKey := leaderKey

while srZones.size() > storedLimit
    RankedZone removed = srZones.pop()
    removed.deleteZone()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Display zones {
int visibleCount = 0
float nearestSupport = na
float nearestResistance = na

if srZones.size() > 0
    for i = 0 to srZones.size() - 1
        RankedZone z = srZones.get(i)
        bool pass = z.canDisplay()
        bool visible = pass and visibleCount < visibleLimit
        if visible
            visibleCount += 1

        color baseColor = z.dir == -1 ? supportColor : resistanceColor
        int left = z.leftTime
        int right = time + barMs * 25
        int maxBarWidth = int((right - left) * 0.82)
        int bullWidth = int(maxBarWidth * z.bullStrength / 100)
        int bearWidth = int(maxBarWidth * z.bearStrength / 100)
        float middle = math.avg(z.top, z.bottom)

        box.set_bgcolor(z.bodyBox, visible ? color.new(baseColor, 78) : color.new(color.gray, 100))
        box.set_border_color(z.bodyBox, na)
        line.set_color(z.centerLine, color.new(baseColor, 100))
        line.set_width(z.centerLine, 1)

        if visible and showStrengthBars
            box.set_left(z.bearBar, left)
            box.set_right(z.bearBar, left + bearWidth)
            box.set_top(z.bearBar, z.top)
            box.set_bottom(z.bearBar, middle)
            box.set_bgcolor(z.bearBar, color.new(resistanceColor, 10))
            box.set_border_color(z.bearBar, na)
            box.set_left(z.bullBar, left)
            box.set_right(z.bullBar, left + bullWidth)
            box.set_top(z.bullBar, middle)
            box.set_bottom(z.bullBar, z.bottom)
            box.set_bgcolor(z.bullBar, color.new(supportColor, 10))
            box.set_border_color(z.bullBar, na)       
        else
            box.set_bgcolor(z.bullBar, color.new(color.gray, 100))
            box.set_bgcolor(z.bearBar, color.new(color.gray, 100))
            box.set_border_color(z.bullBar, na)
            box.set_border_color(z.bearBar, na)

        if z.dir == -1 and z.mid < close
            nearestSupport := na(nearestSupport) or z.mid > nearestSupport ? z.mid : nearestSupport
        if z.dir == 1 and z.mid > close
            nearestResistance := na(nearestResistance) or z.mid < nearestResistance ? z.mid : nearestResistance
````

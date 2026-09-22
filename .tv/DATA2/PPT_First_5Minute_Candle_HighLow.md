<!-- tradingview-pine-id: PUB;4acaca8fd45b48a2954d59ba4bdb89be -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PPT First 5-Minute Candle High/Low

Source: https://www.tradingview.com/script/VuZVjQmx-PPT-First-5-Minute-Candle-High-Low/

## Description

Marks the high and low of the very first 5-minute candle of the trading session — the "opening range" that opening-range-breakout (ORB) traders use as their first reference level of the day.

WHAT IT DOES
At the session open (9:30-9:35 AM ET by default), the indicator watches that opening 5-minute candle form in real time. The instant that candle closes, its high and low are locked in and drawn as two horizontal lines extending forward across the rest of the chart, optionally tagged with price labels ("5M High = ..." / "5M Low = ..."). Those two lines become your reference: a break above the high or below the low is the classic opening-range-breakout signal, while price holding between them marks the range traders can fade.

The lines are drawn fresh every session. By default only today's lines are kept (each new day's lines replace yesterday's); turn off "Show Only Today's Lines" to instead build up a running history of every session's opening range on the chart.

WORKS ON ANY CHART TIMEFRAME
You do not need to be viewing the 5-minute chart. When you are, the indicator reads the high/low directly off your own chart bars; on any other timeframe (1m, 15m, 1H, daily, etc.) it pulls the 5-minute data for you in the background, so the same opening-range lines show up no matter what timeframe you actually trade from.

MULTI-EXCHANGE SESSION SUPPORT
Choose which exchange's regular session open to mark — New York, London, Tokyo, Sydney or Hong Kong — or define your own session time and IANA timezone with the "Custom" option. This makes it useful for opening-range setups on US equities/futures, FX session opens, or other global markets without changing your chart's own timezone.

INPUTS

[*]High/Low Line Color — colors for the two opening-range lines
[*]Line Style / Width — solid, dashed or dotted, and line thickness
[*]Exchange Timezone — which session's open to track (or Custom)
[*]Custom Session/Timezone — session time (HHMM-HHMM) and IANA timezone, used only when Exchange = Custom
[*]Show Only Today's Lines — keep just the current session's lines, or accumulate every past session's lines too
[*]Show High/Low Labels — toggle the price-value text labels
[*]Label Text Size — size of those labels
[*]Label Gap — how far the labels sit from their line, as a percentage of price

This is a pure charting/visualization tool — it draws the opening-range levels for you to trade around manually; it does not place trades, plot buy/sell signals, or generate alerts on its own.

---

## Source Code

````pine
//@version=6
indicator("PPT First 5-Minute Candle High/Low", shorttitle="First 5Min HL + Pulse", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================ INPUTS ============================
inpHighClr    = input.color(color.new(color.white, 0), "High Line Color")
inpLowClr     = input.color(color.new(color.white, 0), "Low Line Color")
inpLineStyle  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"])
inpLineWidth  = input.int(3, "Line Width", options=[1, 2, 3, 5])
inpExchange   = input.string("New York", "Exchange Timezone", options=["New York", "London", "Tokyo", "Sydney", "Hong Kong", "Custom"])
inpTodayOnly  = input.bool(true, "Show Only Today's Lines (delete prior days)")
inpCustSess   = input.session("0930-1600", "Custom Session (used only if Exchange = Custom)")
inpCustTz     = input.string("America/New_York", "Custom Timezone (used only if Exchange = Custom)")
inpTagSizeSel = input.string("Large", "Label Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
inpShowTags   = input.bool(true, "Show High/Low Labels")
inpTagGapPct  = input.float(0.0175, "Label Gap (% of price, smaller = closer to line)", minval=0, step=0.01)
inpShowBreak  = input.bool(true, "Enable Breakout Detection")
inpPulseCandle = input.bool(false, "Highlight Breakout Candle (Pulse)")
inpReqAligned = input.bool(true, "Require Directionally Aligned Breakout Candle")
inpReqEmaX    = input.bool(true, "Require 9/21 EMA Cross Alignment")
inpEmaXBars   = input.int(12, "9/21 Cross Bar Count", minval=1)
inpBullClr    = input.color(color.new(color.lime, 0), "Bullish Breakout Color")
inpBearClr    = input.color(color.new(color.red, 0), "Bearish Breakout Color")
inpBreakLabel = input.bool(true, "Show Breakout Indicator")
inpBullMrkClr = input.color(color.new(color.green, 0), "Bullish Breakout Indicator Color")
inpBearMrkClr = input.color(color.new(color.red, 0), "Bearish Breakout Indicator Color")

// Each exchange's regular trading session and IANA timezone.
// The session's opening 5 minutes is what gets marked (e.g. New York = 9:30-9:35 AM ET).
[sessString, sessTz] = switch inpExchange
    "New York"  => ["0930-1600", "America/New_York"]
    "London"    => ["0800-1630", "Europe/London"]
    "Tokyo"     => ["0900-1500", "Asia/Tokyo"]
    "Sydney"    => ["1000-1600", "Australia/Sydney"]
    "Hong Kong" => ["0930-1600", "Asia/Hong_Kong"]
    "Custom"    => [inpCustSess, inpCustTz]
    => ["0930-1600", "America/New_York"]

tagSizeVal = switch inpTagSizeSel
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.large

lineStyleVal = switch inpLineStyle
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_dashed

// 9/21 EMA cross recency — used to require the breakout candle's direction to agree with the
// most recent EMA cross, within a user-defined lookback window.
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
crossedUp   = ta.crossover(ema9, ema21)
crossedDown = ta.crossunder(ema9, ema21)
barsSinceUp   = ta.barssince(crossedUp)
barsSinceDown = ta.barssince(crossedDown)
emaRecentUp   = not na(barsSinceUp) and barsSinceUp <= inpEmaXBars and (na(barsSinceDown) or barsSinceUp < barsSinceDown)
emaRecentDown = not na(barsSinceDown) and barsSinceDown <= inpEmaXBars and (na(barsSinceUp) or barsSinceDown < barsSinceUp)

// ===================== STATE (persisted across bars) =====================
var line  drawnHighLine  = na
var line  drawnLowLine   = na
var label drawnHighTag   = na
var label drawnLowTag    = na
var bool  candleLocked   = false
var int   savedDateStamp = na
var float openCandleHigh = na
var float openCandleLow  = na
var int   openCandleTime = na
var bool  breakoutFound  = false

// ===================== GET FIRST 5-MIN CANDLE DATA =====================
// If the chart is already on the 5-minute timeframe (the common case for this indicator),
// read high/low directly off the chart's own bars — this can't be wrong, since it's the exact
// same data plotted on screen. Any secondary request.security call risks pulling from a
// different underlying series. Only falls back to a security request if you're viewing a
// different chart timeframe.
onFiveMinChart = timeframe.period == "5"

// Parse the session's opening hour/minute directly out of the "HHMM-HHMM" string (e.g. "0930-1600" -> 9, 30)
sessOpenHr  = str.tonumber(str.substring(sessString, 0, 2))
sessOpenMin = str.tonumber(str.substring(sessString, 2, 4))

// Check the bar's actual clock time against that open time — this is a direct check, not a
// comparison against the previous bar, which is what let the old logic get stuck after firing once.
clockHitLocal = hour(time, sessTz) == sessOpenHr and minute(time, sessTz) == sessOpenMin
[secHigh, secLow, clockHitSec] = request.security(syminfo.tickerid, "5", [high, low, hour(time, sessTz) == sessOpenHr and minute(time, sessTz) == sessOpenMin], lookahead=barmerge.lookahead_off)

barHigh  = onFiveMinChart ? high : secHigh
barLow   = onFiveMinChart ? low : secLow
clockHit = onFiveMinChart ? clockHitLocal : clockHitSec

// Calendar date (in the exchange's timezone) — used so we only ever capture once per day
todayStamp = year(time, sessTz) * 10000 + month(time, sessTz) * 100 + dayofmonth(time, sessTz)

openBarNow = onFiveMinChart and clockHit and (na(savedDateStamp) or todayStamp != savedDateStamp)

if onFiveMinChart
    if openBarNow
        // We're inside the opening 5-min candle (still forming) — keep updating live and stay unlocked
        candleLocked   := false
        openCandleHigh := barHigh
        openCandleLow  := barLow
        openCandleTime := time
        savedDateStamp := todayStamp
        breakoutFound  := false
    else if not candleLocked and not na(openCandleHigh)
        // The candle is closed and we've moved on — lock it in and draw
        candleLocked := true

        if inpTodayOnly
            line.delete(drawnHighLine)
            line.delete(drawnLowLine)
            label.delete(drawnHighTag)
            label.delete(drawnLowTag)

        drawnHighLine := line.new(bar_index, openCandleHigh, bar_index + 1, openCandleHigh, extend=extend.both, color=inpHighClr, style=lineStyleVal, width=inpLineWidth)
        drawnLowLine  := line.new(bar_index, openCandleLow, bar_index + 1, openCandleLow, extend=extend.both, color=inpLowClr, style=lineStyleVal, width=inpLineWidth)

        if inpShowTags
            tagGapAmt = openCandleHigh * (inpTagGapPct / 100)
            drawnHighTag := label.new(bar_index, openCandleHigh + tagGapAmt, "5M High = " + str.tostring(openCandleHigh, format.mintick), style=label.style_label_right, color=color.new(color.black, 100), textcolor=inpHighClr, size=tagSizeVal)
            drawnLowTag  := label.new(bar_index, openCandleLow - tagGapAmt, "5M Low = " + str.tostring(openCandleLow, format.mintick), style=label.style_label_right, color=color.new(color.black, 100), textcolor=inpLowClr, size=tagSizeVal)

// ===================== FIRST FULL BREAKOUT CANDLE =====================
// Finds the first candle, after the opening range is set, whose entire body AND wick sits fully
// outside the range — i.e. it doesn't touch either boundary. A bullish breakout candle's low sits
// above the range high; a bearish breakout candle's high sits below the range low.
color breakoutClr = na
bullBreakoutBar = false
bearBreakoutBar = false
if onFiveMinChart and inpShowBreak and candleLocked and not breakoutFound
    if low > openCandleHigh and (not inpReqAligned or close > open) and (not inpReqEmaX or emaRecentUp)
        breakoutFound   := true
        bullBreakoutBar := true
        if inpPulseCandle
            breakoutClr := inpBullClr
    else if high < openCandleLow and (not inpReqAligned or close < open) and (not inpReqEmaX or emaRecentDown)
        breakoutFound   := true
        bearBreakoutBar := true
        if inpPulseCandle
            breakoutClr := inpBearClr

barcolor(breakoutClr)

plotshape(inpPulseCandle and inpBreakLabel and bullBreakoutBar, title="Bullish Breakout", style=shape.triangleup, location=location.abovebar, color=inpBullMrkClr, size=size.small)
plotshape(inpPulseCandle and inpBreakLabel and bearBreakoutBar, title="Bearish Breakout", style=shape.triangledown, location=location.belowbar, color=inpBearMrkClr, size=size.small)
````

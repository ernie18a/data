# Lemorei Daily - All-In-One

- url: https://www.tradingview.com/script/o9bF9ESn-Lemorei-Daily-All-In-One/
- type: indicator
- pine_id: PUB;41d90da5d5a5485aabbe59210627d8df
- version: 2.0

## Description

[b]Lemorei Daily — All-in-One[/b] Daily Chart Context Tool

Lemorei Daily is a discretionary daily-chart analysis indicator designed to help traders quickly evaluate a stock’s broader trend, relative strength, volume quality, key levels, and long-side trading context.

This script is built for [b]daily charts[/b] and is intended to support watchlist building, pre-market preparation, swing context, and intraday bias planning. It is not designed as a standalone buy/sell execution system. Instead, it helps answer one important question before trading: [b]Is this stock strong enough to deserve attention?[/b][i][/i]

The indicator combines several important daily-chart components into one clean visual layout:

[list]
[*] [b]20 EMA, 50 EMA, and 200 EMA[/b][i][/i] trend structure
[*] [b]20/50 EMA cloud[/b][i][/i] to quickly visualize bullish or bearish trend alignment
[*] [b]Weekly and Monthly anchored VWAP[/b][i][/i] to identify whether price is above or below important institutional reference levels
[*] [b]Previous Day High and Previous Day Low[/b][i][/i] levels with optional extended labels
[*] [b]ATR-based daily range analysis[/b][i][/i] to classify the current day as quiet, normal, healthy, expanded, or extreme
[*] [b]Relative strength vs SPY[/b][i][/i] to show whether the ticker is leading or lagging the market
[*] [b]Volume quality analysis[/b][i][/i] using relative volume versus its average
[*] [b]Hot volume candle highlighting[/b][i][/i] for unusual daily participation
[*] [b]Fast Daily dashboard[/b][i][/i] summarizing bias, EMA position, VWAP status, relative strength, volume, range, and action context
[*] [b]Action engine[/b][i][/i] that classifies the setup as A+ LONG, WAIT VWAP, PULLBACK, SELECTIVE, AVOID LONG, or CAUTION
[*] [b]Clean action note[/b][i][/i] with plain-language guidance for the current daily context
[*] [b]Alerts[/b][i][/i] for A+ daily long context, VWAP reclaim, wait-for-VWAP conditions, and hot daily volume
[/list]

The goal of this indicator is to make daily chart analysis faster, cleaner, and more structured. It is especially useful for traders who focus on momentum stocks, large-cap leaders, continuation setups, VWAP reclaim setups, and stocks showing relative strength against the broader market.

Suggested use cases:
[list=1]
[*] Building a daily watchlist
[*] Filtering stocks before intraday trading
[*] Identifying strong continuation candidates
[*] Avoiding weak or extended names
[*] Confirming whether a stock has bullish daily structure before looking for lower-timeframe entries
[*] Monitoring important VWAP, EMA, volume, and range conditions
[/list]

[i]Important:[/i] This script is for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security. Always combine this tool with your own analysis, risk management, market conditions, news awareness, and personal trading plan.

## Source Code

````pine
// © lemorei — v2.0
//@version=6
indicator("Lemorei for 1D", overlay=true, max_labels_count=10)

// ============================================================================
// LEMOREI DAILY — LARGE CAP SCALP CONTEXT — v2.0
//
// PURPOSE
// Higher-timeframe context dashboard for large-cap LONG scalping.
//
// Typical workflow:
// • Execution: 10s / 15s
// • Management: 1m
// • Daily: context / permission
//
// TABLE
// HTF      = higher-timeframe structure
// TODAY    = current Daily behavior + same-time RVOL during RTH
// STRETCH  = ATR/range/HOD deterioration
// RS SPY   = relative strength versus SPY
//
// SCALP    = Daily-context permission for LONG scalping
// EOD      = context for holding through regular close
// AFTER    = context for holding into after-hours
// SWING    = overnight/swing context
// RISK     = nearest major Daily support below price
//
// SESSION SAFETY
// • New York time
// • Requires same-date exchange data
// • Weekends / holidays remain CLOSED
//
// IMPORTANT
// Market context only. Not a personalized stop-loss or trade instruction.
// ============================================================================


// ============================================================================
// INPUTS
// ============================================================================

grpLevels = "── Key Levels ──"
showPDHL = input.bool(true, "Show PDH / PDL", group=grpLevels)
compactLabels = input.bool(true, "Compact PDH/PDL Labels", group=grpLevels)
colPDH = input.color(#00C853, "PDH Color", group=grpLevels)
colPDL = input.color(#FF1744, "PDL Color", group=grpLevels)

grpATR = "── ATR / Range ──"
atrLen = input.int(14, "ATR Length", minval=1, group=grpATR)

grpRS = "── Relative Strength ──"
rsSymbol = input.symbol("AMEX:SPY", "Compare vs", group=grpRS)
rsLookback = input.int(20, "RS Lookback", minval=5, group=grpRS)

grpRVOL = "── Relative Volume ──"
rvolLookback = input.int(20, "Historical Sessions", minval=5, maxval=40, group=grpRVOL)

grpPM = "── Premarket ──"
pmTF = input.timeframe("5", "Premarket Calculation TF", group=grpPM)
pmSession = input.session("0400-0930", "Premarket Session", group=grpPM)

grpDash = "── Dashboard ──"
showTable = input.bool(true, "Show Dashboard", group=grpDash)
tablePos = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
tableSize = input.string("Normal", "Table Text Size", options=["Small", "Normal", "Large"], group=grpDash)


// ============================================================================
// HELPERS
// ============================================================================

txtSize = switch tableSize
    "Small" => size.small
    "Large" => size.large
    => size.normal

tpos = switch tablePos
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

fmtPrice(float x) =>
    na(x) ? "-" : "$" + str.tostring(x, "#.##")

fmtPct(float x) =>
    na(x) ? "-" : (x > 0 ? "+" : "") + str.tostring(x, "#.##") + "%"

cell(table tbl, int col, int row, string txt, color fg, color bg) =>
    table.cell(tbl, col, row, txt, text_color=fg, text_size=txtSize, bgcolor=bg, text_halign=col == 0 ? text.align_left : text.align_right)

decisionCell(table tbl, int row, string labelTxt, string valueTxt, color c) =>
    table.cell(tbl, 0, row, labelTxt, text_color=color.white, text_size=txtSize, bgcolor=color.new(c, 5), text_halign=text.align_left)
    table.cell(tbl, 1, row, valueTxt, text_color=color.white, text_size=txtSize, bgcolor=color.new(c, 5), text_halign=text.align_right)


// ============================================================================
// TICKERS
// ============================================================================

regularTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)
extendedTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)


// ============================================================================
// NEW YORK CLOCK
// ============================================================================

nyHour = hour(timenow, "America/New_York")
nyMinute = minute(timenow, "America/New_York")
nyMinutes = nyHour * 60 + nyMinute
nyDayOfWeek = dayofweek(timenow, "America/New_York")

isWeekdayNow = nyDayOfWeek >= dayofweek.monday and nyDayOfWeek <= dayofweek.friday

preClock = nyMinutes >= 240 and nyMinutes < 570
rthClock = nyMinutes >= 570 and nyMinutes < 960
postClock = nyMinutes >= 960 and nyMinutes < 1200


// ============================================================================
// SAME-DATE EXCHANGE CHECK
// ============================================================================

lastRthBarTime = request.security(regularTicker, "5", time, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
lastExtBarTime = request.security(extendedTicker, "5", time, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

rthYearMatch = not na(lastRthBarTime) and year(lastRthBarTime, "America/New_York") == year(timenow, "America/New_York")
rthMonthMatch = not na(lastRthBarTime) and month(lastRthBarTime, "America/New_York") == month(timenow, "America/New_York")
rthDayMatch = not na(lastRthBarTime) and dayofmonth(lastRthBarTime, "America/New_York") == dayofmonth(timenow, "America/New_York")

extYearMatch = not na(lastExtBarTime) and year(lastExtBarTime, "America/New_York") == year(timenow, "America/New_York")
extMonthMatch = not na(lastExtBarTime) and month(lastExtBarTime, "America/New_York") == month(timenow, "America/New_York")
extDayMatch = not na(lastExtBarTime) and dayofmonth(lastExtBarTime, "America/New_York") == dayofmonth(timenow, "America/New_York")

hasRthDataToday = rthYearMatch and rthMonthMatch and rthDayMatch
hasExtDataToday = extYearMatch and extMonthMatch and extDayMatch

isPremarketLive = isWeekdayNow and preClock and hasExtDataToday
isRthLive = isWeekdayNow and rthClock and hasRthDataToday
isPostLive = isWeekdayNow and postClock and hasExtDataToday

isClosedNow = not isPremarketLive and not isRthLive and not isPostLive

// Short labels prevent clipping in compact table.
sessionTxt = isPremarketLive ? "PRE" : isRthLive ? "MKT" : isPostLive ? "AFTER" : "CLOSED"

sessionCol = isPremarketLive ? #FFD54F : isRthLive ? #00C853 : isPostLive ? #90CAF9 : #9E9E9E


// ============================================================================
// PREMARKET FUNCTIONS
// ============================================================================

f_pm_high() =>
    bool inPM = not na(time(timeframe.period, pmSession, "America/New_York"))
    bool firstPM = inPM and not inPM[1]
    var float x = na

    if firstPM
        x := high
    else if inPM
        x := math.max(nz(x, high), high)

    x

f_pm_low() =>
    bool inPM = not na(time(timeframe.period, pmSession, "America/New_York"))
    bool firstPM = inPM and not inPM[1]
    var float x = na

    if firstPM
        x := low
    else if inPM
        x := math.min(nz(x, low), low)

    x

f_pm_close() =>
    bool inPM = not na(time(timeframe.period, pmSession, "America/New_York"))
    bool firstPM = inPM and not inPM[1]
    var float x = na

    if firstPM
        x := close
    else if inPM
        x := close

    x


// ============================================================================
// TRUE SAME-TIME-OF-DAY RVOL
//
// Current cumulative RTH volume
// divided by
// average cumulative RTH volume at the same 5-minute slot.
// ============================================================================

f_same_time_rvol() =>
    int slotsPerDay = 78
    int maxHistory = 40

    var float cumulativeVol = 0.0
    var int sessionCounter = -1

    var array<float> history = array.new_float(slotsPerDay * maxHistory, na)
    var array<float> sums = array.new_float(slotsPerDay, 0.0)
    var array<int> counts = array.new_int(slotsPerDay, 0)

    bool newSession = ta.change(time("D")) != 0

    if newSession or sessionCounter == -1
        cumulativeVol := volume
        sessionCounter += 1
    else
        cumulativeVol += volume

    int hh = hour(time, "America/New_York")
    int mm = minute(time, "America/New_York")
    int minutesFromOpen = hh * 60 + mm - 570
    int slot = int(math.floor(minutesFromOpen / 5.0))

    slot := math.max(0, math.min(slotsPerDay - 1, slot))

    int effectiveLookback = math.min(rvolLookback, maxHistory)
    int ring = sessionCounter % effectiveLookback
    int historyIndex = slot * maxHistory + ring

    float priorValue = array.get(history, historyIndex)
    float priorSum = array.get(sums, slot)
    int priorCount = array.get(counts, slot)

    float historicalAverage = priorCount > 0 ? priorSum / priorCount : na
    float result = not na(historicalAverage) and historicalAverage > 0 ? cumulativeVol / historicalAverage : na

    if na(priorValue)
        array.set(history, historyIndex, cumulativeVol)
        array.set(sums, slot, priorSum + cumulativeVol)
        array.set(counts, slot, priorCount + 1)
    else
        array.set(history, historyIndex, cumulativeVol)
        array.set(sums, slot, priorSum - priorValue + cumulativeVol)

    result


// ============================================================================
// PREMARKET / EXTENDED DATA
// ============================================================================

pmHigh = request.security(extendedTicker, pmTF, f_pm_high(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
pmLow = request.security(extendedTicker, pmTF, f_pm_low(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
pmClose = request.security(extendedTicker, pmTF, f_pm_close(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

extendedLast = request.security(extendedTicker, "5", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

rvolRaw = request.security(regularTicker, "5", f_same_time_rvol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rvolNow = isRthLive ? rvolRaw : na


// ============================================================================
// PRIOR DAILY DATA
// ============================================================================

prevOpen = request.security(regularTicker, "D", open[1], lookahead=barmerge.lookahead_on)
prevHigh = request.security(regularTicker, "D", high[1], lookahead=barmerge.lookahead_on)
prevLow = request.security(regularTicker, "D", low[1], lookahead=barmerge.lookahead_on)
prevClose = request.security(regularTicker, "D", close[1], lookahead=barmerge.lookahead_on)


// ============================================================================
// CURRENT / LAST DAILY DATA
// ============================================================================

liveOpen = request.security(regularTicker, "D", open, lookahead=barmerge.lookahead_off)
liveHigh = request.security(regularTicker, "D", high, lookahead=barmerge.lookahead_off)
liveLow = request.security(regularTicker, "D", low, lookahead=barmerge.lookahead_off)
liveClose = request.security(regularTicker, "D", close, lookahead=barmerge.lookahead_off)


// ============================================================================
// CURRENT PRICE / CHANGE
// ============================================================================

currentPrice = isPremarketLive ? pmClose : isPostLive ? extendedLast : liveClose

currentChangePct = isRthLive and prevClose != 0 ? (liveClose - prevClose) / prevClose * 100 :
     isPostLive and liveClose != 0 ? (extendedLast - liveClose) / liveClose * 100 :
     isPremarketLive and liveClose != 0 ? (pmClose - liveClose) / liveClose * 100 :
     na


// ============================================================================
// DAILY EMA
// ============================================================================

ema20 = request.security(regularTicker, "D", ta.ema(close, 20), lookahead=barmerge.lookahead_off)
ema50 = request.security(regularTicker, "D", ta.ema(close, 50), lookahead=barmerge.lookahead_off)
ema200 = request.security(regularTicker, "D", ta.ema(close, 200), lookahead=barmerge.lookahead_off)

ctxClose = liveClose


// ============================================================================
// WEEKLY / MONTHLY ANCHORED VWAP
// ============================================================================

weeklyVwap = request.security(regularTicker, "D", ta.vwap(hlc3, timeframe.change("W")), lookahead=barmerge.lookahead_off)
monthlyVwap = request.security(regularTicker, "D", ta.vwap(hlc3, timeframe.change("M")), lookahead=barmerge.lookahead_off)


// ============================================================================
// PDH / PDL
//
// During RTH = prior completed RTH session.
// Outside RTH = latest completed RTH session for next-session reference.
// ============================================================================

pdh = isRthLive ? prevHigh : liveHigh
pdl = isRthLive ? prevLow : liveLow

var label labelPDH = na
var label labelPDL = na

if barstate.islast
    if not na(labelPDH)
        label.delete(labelPDH)

    if not na(labelPDL)
        label.delete(labelPDL)

    if showPDHL and not na(pdh)
        labelPDH := label.new(bar_index + 1, pdh, compactLabels ? "PDH " + fmtPrice(pdh) : " PDH " + fmtPrice(pdh), xloc=xloc.bar_index, style=label.style_label_left, color=colPDH, textcolor=color.white, size=compactLabels ? size.normal : size.large)

    if showPDHL and not na(pdl)
        labelPDL := label.new(bar_index + 1, pdl, compactLabels ? "PDL " + fmtPrice(pdl) : " PDL " + fmtPrice(pdl), xloc=xloc.bar_index, style=label.style_label_left, color=colPDL, textcolor=color.white, size=compactLabels ? size.normal : size.large)


// ============================================================================
// ATR / RANGE
// ============================================================================

atrValue = request.security(regularTicker, "D", ta.atr(atrLen), lookahead=barmerge.lookahead_off)

dayRange = liveHigh - liveLow
rangeATR = atrValue > 0 ? dayRange / atrValue * 100 : na

closeLocation = dayRange > 0 ? (liveClose - liveLow) / dayRange * 100 : 50.0

fromHodPct = liveHigh > 0 ? (liveClose - liveHigh) / liveHigh * 100 : na
fromHodATR = atrValue > 0 ? (liveClose - liveHigh) / atrValue : na

pmRange = not na(pmHigh) and not na(pmLow) ? pmHigh - pmLow : na
pmRangeATR = atrValue > 0 and not na(pmRange) ? pmRange / atrValue * 100 : na


// ============================================================================
// RELATIVE STRENGTH VS SPY
//
// RS is NOT RSI.
//
// RS = stock return - SPY return over selected lookback.
// ============================================================================

stockRoc = request.security(regularTicker, "D", (close - close[rsLookback]) / close[rsLookback] * 100, lookahead=barmerge.lookahead_off)
benchmarkRoc = request.security(rsSymbol, "D", (close - close[rsLookback]) / close[rsLookback] * 100, lookahead=barmerge.lookahead_off)

rsVsMarket = stockRoc - benchmarkRoc

rsLabel = rsVsMarket >= 5 ? "LEADER" :
     rsVsMarket >= 2 ? "STRONG" :
     rsVsMarket >= 0 ? "POSITIVE" :
     rsVsMarket >= -2 ? "NEUTRAL" :
     rsVsMarket >= -5 ? "WEAK" :
     "LAGGING"

rsCol = rsVsMarket >= 5 ? #00E676 :
     rsVsMarket >= 2 ? #4CAF50 :
     rsVsMarket >= 0 ? #8BC34A :
     rsVsMarket >= -2 ? #FF9800 :
     rsVsMarket >= -5 ? #F44336 :
     #B71C1C

rsSign = rsVsMarket >= 0 ? "+" : ""
rsTxt = rsSign + str.tostring(rsVsMarket, "#.#") + " • " + rsLabel


// ============================================================================
// DAILY STRUCTURE
// ============================================================================

fullyBullish = ctxClose > ema20 and ema20 > ema50 and ema50 > ema200
fullyBearish = ctxClose < ema20 and ema20 < ema50 and ema50 < ema200

above20 = ctxClose > ema20
above50 = ctxClose > ema50
above200 = ctxClose > ema200

aboveW = ctxClose >= weeklyVwap
aboveM = ctxClose >= monthlyVwap

abovePDH = liveClose > prevHigh
abovePDL = liveClose > prevLow
abovePrevClose = liveClose >= prevClose

greenDay = liveClose > liveOpen
redDay = liveClose < liveOpen


// ============================================================================
// TODAY / LAST DAY STRUCTURE
// ============================================================================

dayBreakdown = liveClose < prevLow or (liveClose < prevClose and closeLocation < 20)

dayWeakening = not dayBreakdown and liveClose < liveOpen and closeLocation < 40

healthyPullback = not dayBreakdown and liveClose >= prevClose and closeLocation >= 40

strongDay = liveClose > prevClose and liveClose > liveOpen and closeLocation >= 65

dayStructureBaseTxt = dayBreakdown ? "BREAKDOWN" :
     strongDay ? "STRONG" :
     healthyPullback ? "HEALTHY" :
     dayWeakening ? "WEAKENING" :
     "MIXED"

dayStructureCol = dayBreakdown ? #F44336 :
     strongDay ? #00C853 :
     healthyPullback ? #4CAF50 :
     dayWeakening ? #FF9800 :
     #FFD54F

dayRowLabel = isRthLive or isPostLive ? "TODAY" : "LAST DAY"


// ============================================================================
// RVOL QUALITY
//
// High volume is interpreted in the direction of price structure.
//
// STRONG + high RVOL     = bullish confirmation
// BREAKDOWN + high RVOL  = bearish confirmation
//
// High RVOL never overrides broken structure.
// ============================================================================

rvolLow = isRthLive and not na(rvolNow) and rvolNow < 0.80
rvolHigh = isRthLive and not na(rvolNow) and rvolNow >= 1.50
rvolHot = isRthLive and not na(rvolNow) and rvolNow >= 2.00
rvolExtreme = isRthLive and not na(rvolNow) and rvolNow >= 3.00

rvolBullConfirm = isRthLive and not na(rvolNow) and rvolNow >= 1.50 and (strongDay or healthyPullback)
rvolBearConfirm = isRthLive and not na(rvolNow) and rvolNow >= 1.50 and (dayBreakdown or dayWeakening)


// ============================================================================
// TODAY DISPLAY — RVOL EMBEDDED ONLY DURING LIVE RTH
// ============================================================================

dayStructureTxt = dayStructureBaseTxt

if isRthLive and not na(rvolNow)
    dayStructureTxt := dayStructureBaseTxt + " • " + str.tostring(rvolNow, "#.#") + "x VOL"


// ============================================================================
// HTF COMPOSITE
// ============================================================================

htfStrongBull = fullyBullish and aboveW and aboveM

htfBull = not htfStrongBull and above200 and (above20 or above50 or aboveW or aboveM)

htfBear = fullyBearish or (not above200 and not aboveW and not aboveM)

htfTxt = htfStrongBull ? "STRONG BULL" :
     htfBull ? "BULL" :
     htfBear ? "BEAR" :
     "MIXED"

htfCol = htfStrongBull ? #00C853 :
     htfBull ? #4CAF50 :
     htfBear ? #F44336 :
     #FF9800


// ============================================================================
// STRETCH / DAMAGE
// ============================================================================

stretchDanger = (rangeATR >= 150 and closeLocation < 30) or closeLocation < 15 or fromHodATR <= -1.00

stretchExtended = not stretchDanger and (rangeATR >= 120 or closeLocation < 35 or fromHodATR <= -0.60)

stretchTxt = stretchDanger ? "RISKY • " + str.tostring(rangeATR, "#") + "% ATR" :
     stretchExtended ? "EXTENDED • " + str.tostring(rangeATR, "#") + "% ATR" :
     "NORMAL • " + str.tostring(rangeATR, "#") + "% ATR"

stretchCol = stretchDanger ? #F44336 :
     stretchExtended ? #FF9800 :
     #4CAF50


// ============================================================================
// SCALP CONTEXT
//
// LONG OK
//   Daily backdrop supports looking for a long scalp.
//
// SELECTIVE
//   Daily backdrop is mixed.
//
// NO LONG
//   Daily context is materially hostile to long scalps.
//
// RVOL:
// • Low RVOL can downgrade LONG OK to SELECTIVE.
// • High RVOL confirms direction.
// • High RVOL cannot rescue bad structure.
// ============================================================================

scalpHardBad = dayBreakdown or (redDay and closeLocation < 20) or (not above200 and rsVsMarket < 0) or stretchDanger

scalpBaseGood = not scalpHardBad and above200 and rsVsMarket >= 0 and (strongDay or healthyPullback or (greenDay and closeLocation >= 50))

scalpVolumeOK = not isRthLive or na(rvolNow) or rvolNow >= 0.80

scalpStrongConfirm = scalpBaseGood and scalpVolumeOK

scalpTxt = scalpHardBad ? "NO LONG" :
     scalpStrongConfirm ? "LONG OK" :
     "SELECTIVE"

scalpCol = scalpTxt == "LONG OK" ? #00C853 :
     scalpTxt == "SELECTIVE" ? #FFB300 :
     #F44336


// ============================================================================
// EOD SCORE — 100
//
// RVOL is directional and receives max 10 points.
// ============================================================================

int eodScore = 0

// Today — 28
eodScore += strongDay ? 28 :
     healthyPullback ? 22 :
     dayWeakening ? 7 :
     dayBreakdown ? 0 :
     14

// Trend — 18
eodScore += fullyBullish ? 18 :
     above20 and above50 and above200 ? 15 :
     above50 and above200 ? 11 :
     above200 ? 5 :
     0

// RS — 14
eodScore += rsVsMarket >= 5 ? 14 :
     rsVsMarket >= 2 ? 12 :
     rsVsMarket >= 0 ? 9 :
     rsVsMarket >= -2 ? 4 :
     0

// W/M VWAP — 10
eodScore += aboveW and aboveM ? 10 :
     aboveW or aboveM ? 5 :
     0

// Key levels — 12
eodScore += abovePDH ? 12 :
     abovePrevClose ? 10 :
     abovePDL ? 5 :
     0

// ATR — 8
eodScore += rangeATR <= 100 ? 8 :
     rangeATR <= 125 ? 5 :
     rangeATR <= 150 ? 2 :
     0

// Directional RVOL — 10
int eodRvolPts = 0

if not isRthLive or na(rvolNow)
    eodRvolPts := 5
else if strongDay or healthyPullback
    eodRvolPts := rvolNow >= 2.0 ? 10 :
         rvolNow >= 1.5 ? 8 :
         rvolNow >= 1.0 ? 6 :
         rvolNow >= 0.8 ? 4 :
         1
else if dayBreakdown or dayWeakening
    eodRvolPts := rvolNow >= 1.5 ? 0 :
         rvolNow >= 1.0 ? 2 :
         3
else
    eodRvolPts := rvolNow >= 1.5 ? 5 :
         rvolNow >= 0.8 ? 4 :
         2

eodScore += eodRvolPts

eodVeto = dayBreakdown and closeLocation < 20

eodTxt = eodVeto ? "NO" :
     eodScore >= 82 ? "STRONG" :
     eodScore >= 68 ? "ALLOW" :
     eodScore >= 52 ? "CAUTION" :
     "NO"

eodCol = eodVeto ? #F44336 :
     eodScore >= 82 ? #00C853 :
     eodScore >= 68 ? #4CAF50 :
     eodScore >= 52 ? #FF9800 :
     #F44336


// ============================================================================
// AFTER-HOURS SCORE — 100
//
// RVOL has only modest influence.
// ============================================================================

int ahScore = 0

// Today — 30
ahScore += strongDay ? 30 :
     healthyPullback ? 22 :
     dayWeakening ? 6 :
     dayBreakdown ? 0 :
     12

// Trend — 20
ahScore += fullyBullish ? 20 :
     above20 and above50 and above200 ? 16 :
     above50 and above200 ? 10 :
     above200 ? 4 :
     0

// RS — 15
ahScore += rsVsMarket >= 5 ? 15 :
     rsVsMarket >= 2 ? 13 :
     rsVsMarket >= 0 ? 9 :
     rsVsMarket >= -2 ? 4 :
     0

// W/M VWAP — 10
ahScore += aboveW and aboveM ? 10 :
     aboveW or aboveM ? 4 :
     0

// Range position — 10
ahScore += closeLocation >= 80 ? 10 :
     closeLocation >= 60 ? 8 :
     closeLocation >= 40 ? 5 :
     closeLocation >= 20 ? 2 :
     0

// Key levels — 10
ahScore += abovePDH ? 10 :
     abovePrevClose ? 8 :
     abovePDL ? 3 :
     0

// RVOL — 5
int ahRvolPts = 0

if not isRthLive or na(rvolNow)
    ahRvolPts := 3
else if strongDay or healthyPullback
    ahRvolPts := rvolNow >= 2.0 ? 5 :
         rvolNow >= 1.5 ? 4 :
         rvolNow >= 0.8 ? 3 :
         1
else if dayBreakdown or dayWeakening
    ahRvolPts := rvolNow >= 1.5 ? 0 : 1
else
    ahRvolPts := 2

ahScore += ahRvolPts

ahVeto = liveClose < prevLow or (liveClose < ema50 and dayWeakening) or dayBreakdown

ahTxt = ahVeto ? "NO" :
     ahScore >= 78 ? "ALLOW" :
     ahScore >= 65 ? "CAUTION" :
     "NO"

ahCol = ahVeto ? #F44336 :
     ahScore >= 78 ? #4CAF50 :
     ahScore >= 65 ? #FF9800 :
     #F44336


// ============================================================================
// SWING SCORE — 100
//
// RVOL intentionally NOT used.
// Morning participation should not determine overnight quality.
// ============================================================================

int swingScore = 0

// Trend — 30
swingScore += fullyBullish ? 30 :
     above20 and above50 and above200 ? 24 :
     above50 and above200 ? 15 :
     above200 ? 7 :
     0

// Today — 25
swingScore += strongDay ? 25 :
     healthyPullback ? 19 :
     dayWeakening ? 5 :
     dayBreakdown ? 0 :
     11

// RS — 15
swingScore += rsVsMarket >= 5 ? 15 :
     rsVsMarket >= 2 ? 13 :
     rsVsMarket >= 0 ? 9 :
     rsVsMarket >= -2 ? 3 :
     0

// W/M VWAP — 10
swingScore += aboveW and aboveM ? 10 :
     aboveW or aboveM ? 4 :
     0

// Key levels — 10
swingScore += abovePDH ? 10 :
     abovePrevClose ? 8 :
     abovePDL ? 3 :
     0

// Range position — 10
swingScore += closeLocation >= 80 ? 10 :
     closeLocation >= 60 ? 8 :
     closeLocation >= 40 ? 5 :
     closeLocation >= 20 ? 2 :
     0

swingVeto = liveClose < prevLow or liveClose < ema200 or fullyBearish or rsVsMarket < -5 or dayBreakdown

swingTxt = swingVeto ? "NO" :
     swingScore >= 80 ? "QUALIFIED" :
     swingScore >= 65 ? "CONDITIONAL" :
     "NO"

swingCol = swingVeto ? #F44336 :
     swingScore >= 80 ? #00C853 :
     swingScore >= 65 ? #FF9800 :
     #F44336


// ============================================================================
// STRUCTURAL RISK
//
// Nearest major Daily support below current price.
// NOT a personalized DAS stop.
// ============================================================================

float riskPrice = na
string riskName = "-"

if not na(prevLow) and prevLow < ctxClose
    riskPrice := prevLow
    riskName := "PDL"

if not na(ema20) and ema20 < ctxClose and (na(riskPrice) or ema20 > riskPrice)
    riskPrice := ema20
    riskName := "EMA20"

if not na(ema50) and ema50 < ctxClose and (na(riskPrice) or ema50 > riskPrice)
    riskPrice := ema50
    riskName := "EMA50"

if not na(weeklyVwap) and weeklyVwap < ctxClose and (na(riskPrice) or weeklyVwap > riskPrice)
    riskPrice := weeklyVwap
    riskName := "W-VWAP"

riskTxt = not na(riskPrice) ? fmtPrice(riskPrice) + " • " + riskName : "-"

riskCol = not na(riskPrice) and not na(currentPrice) and currentPrice <= riskPrice ? #F44336 : #FFD54F


// ============================================================================
// HEADER
//
// Closed session intentionally says only CLOSED.
// LAST DAY below already explains which session the context represents.
// ============================================================================

headerRightTxt = isClosedNow ? "CLOSED" :
     sessionTxt + " " + fmtPct(currentChangePct)

headerRightCol = isClosedNow ? #9E9E9E :
     currentChangePct > 0 ? #4CAF50 :
     currentChangePct < 0 ? #F44336 :
     sessionCol


// ============================================================================
// DASHBOARD
//
// No standalone RVOL row.
//
// During RTH:
// TODAY      STRONG • 2.1x VOL
//
// Outside RTH:
// LAST DAY   STRONG
// ============================================================================

var table dash = table.new(
     tpos,
     2,
     10,
     bgcolor=color.new(#0D0D1A, 5),
     border_color=#444466,
     border_width=1,
     frame_color=#6666AA,
     frame_width=1)


// ============================================================================
// DRAW DASHBOARD
// ============================================================================

if showTable and barstate.islast

    color hdrBg = #1E1E3A
    color rowBg = #0D0D1A
    color altBg = #13132A
    color lblCol = #8888AA

    // HEADER
    table.cell(dash, 0, 0, syminfo.ticker, text_color=#FFD54F, text_size=txtSize, bgcolor=hdrBg, text_halign=text.align_left)
    table.cell(dash, 1, 0, headerRightTxt, text_color=headerRightCol, text_size=txtSize, bgcolor=hdrBg, text_halign=text.align_right)

    // HTF
    cell(dash, 0, 1, "HTF", lblCol, rowBg)
    cell(dash, 1, 1, htfTxt, htfCol, rowBg)

    // TODAY / LAST DAY
    cell(dash, 0, 2, dayRowLabel, lblCol, altBg)
    cell(dash, 1, 2, dayStructureTxt, dayStructureCol, altBg)

    // STRETCH
    cell(dash, 0, 3, "STRETCH", lblCol, rowBg)
    cell(dash, 1, 3, stretchTxt, stretchCol, rowBg)

    // RS SPY
    cell(dash, 0, 4, "RS SPY", lblCol, altBg)
    cell(dash, 1, 4, rsTxt, rsCol, altBg)

    // SCALP
    decisionCell(dash, 5, "SCALP", scalpTxt, scalpCol)

    // EOD
    decisionCell(dash, 6, "EOD", str.tostring(eodScore) + " • " + eodTxt, eodCol)

    // AFTER
    decisionCell(dash, 7, "AFTER", str.tostring(ahScore) + " • " + ahTxt, ahCol)

    // SWING
    decisionCell(dash, 8, "SWING", str.tostring(swingScore) + " • " + swingTxt, swingCol)

    // RISK
    cell(dash, 0, 9, "RISK", lblCol, rowBg)
    cell(dash, 1, 9, riskTxt, riskCol, rowBg)


// ============================================================================
// HIDE TABLE
// ============================================================================

if not showTable and barstate.islast
    table.clear(dash, 0, 0, 1, 9)


// ============================================================================
// ALERTS
//
// Live intraday alerts require actual RTH.
// ============================================================================

alertcondition(
     isRthLive and scalpTxt == "NO LONG" and scalpTxt[1] != "NO LONG",
     "Daily Context — No Long",
     "{{ticker}} Daily context changed to NO LONG.")

alertcondition(
     isRthLive and scalpTxt == "LONG OK" and scalpTxt[1] != "LONG OK",
     "Daily Context — Long OK",
     "{{ticker}} Daily context changed to LONG OK.")

alertcondition(
     isRthLive and not na(rvolNow) and rvolNow >= 1.5 and rvolNow[1] < 1.5,
     "RVOL High",
     "{{ticker}} same-time RVOL crossed above 1.5x.")

alertcondition(
     isRthLive and not na(rvolNow) and rvolNow >= 2.0 and rvolNow[1] < 2.0,
     "RVOL Hot",
     "{{ticker}} same-time RVOL crossed above 2.0x.")

alertcondition(
     isRthLive and eodScore >= 68 and eodScore[1] < 68 and not eodVeto,
     "EOD Context Qualified",
     "{{ticker}} EOD context moved to ALLOW or better.")

alertcondition(
     isRthLive and eodVeto and not eodVeto[1],
     "EOD Context Invalidated",
     "{{ticker}} EOD context has been invalidated.")

alertcondition(
     isRthLive and swingScore >= 80 and swingScore[1] < 80 and not swingVeto,
     "Swing Context Qualified",
     "{{ticker}} Daily context now qualifies for swing review.")

alertcondition(
     isRthLive and swingVeto and not swingVeto[1],
     "Swing Context Invalidated",
     "{{ticker}} swing context has been structurally invalidated.")
````

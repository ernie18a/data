# Open Legacy

- url: https://www.tradingview.com/script/5luxdNAk-Open-Legacy/
- type: indicator
- pine_id: PUB;6f1ae50e4c3543968f9b41830cefdaf9
- version: 2.0

## Description

OPEN LEGACY

Open Legacy is a signal indicator for manual traders. It marks BUY and SELL entries using one of two classic methods, filtered by one shared trend check. When a signal fires, a heads-up display (HUD) locks the entry, take profit and stop loss, so you have exact numbers to put into your broker. It uses the same engine as Open Legacy Bot, so the same settings give the same signals.

HOW IT FINDS ENTRIES (Entry Method)
• FVG Pullback: a fair value gap is the space left when a candle's low is above the high from two candles earlier (or the reverse for a bearish gap). Gaps smaller than a share of ATR(14) are ignored. A BUY prints when price pulls back into a bullish gap and a candle closes bullish back above the gap's bottom, while the gap is still recent (the reverse for SELL).
• EMA Trend: a BUY prints on the first candle where the fast EMA is above the slow EMA, price closes above the fast EMA and RSI(14) is above 50. It prints once per trend leg, not on every candle (the reverse for SELL).

HOW THE FILTER WORKS (Sensitivity)
One setting controls both methods:
• Aggressive: every valid setup, with faster lengths (EMA 8/21, short gap lifetime).
• Balanced: the setup must also agree with the 50 EMA (EMA 13/34).
• Conservative: also needs price on the same side of the 50 EMA on a timeframe 4x the chart, and ADX(14) of 20 or more (EMA 21/55, longer gap lifetime, larger minimum gap).
Signals only print on a closed candle, so a label never appears and then disappears. The higher-timeframe check reads the previous completed higher-timeframe candle, so it doesn't repaint.

WHY THE PIECES WORK TOGETHER
The entries find the moment to get in. The shared filter decides whether the market is trending enough to act on it. One dial moves both from more signals to fewer, higher-quality ones. The HUD then turns each signal into fixed numbers you can trade by hand.

THE HUD
• Fixed Entry, Take Profit and Stop Loss: locked when the signal fires, using your pip distances. They don't move afterwards. Dashed lines show TP and SL on the chart.
• Setup Score: a 1-99% progress gauge for the open trade. Most of it measures how far price has moved from the stop loss toward the target, with small bonuses or deductions when the chart trend and the benchmark agree or disagree. It is a guide to how the trade is going, not a probability of winning.
• Benchmark Structure: checks a related market that usually moves with or against the chart symbol. It picks the benchmark automatically: DXY for USD pairs and gold, VIX for US and major stock indices, currency indexes for JPY, GBP, EUR, CAD and CHF pairs, and gold for DXY itself. It shows Confirmed when the benchmark supports the trade and Invalid when it has worked against it for a while.
• Overall Structure: Strong when the chart trend and the benchmark agree, Weak when they conflict, and Decent otherwise.
• Market status: shows Closed during the usual weekend and daily breaks, or when the price feed has gone quiet.

ALERTS
Create one alert with the condition "Any alert() function call". You'll get a message for each new BUY or SELL, and when the take profit or stop loss is hit.

SETTINGS
• Entry Method and Sensitivity: see above.
• Stop Loss and Take Profit (pips): your fixed distances. Keep TP larger than SL.
• Points Per Pip: 10 suits gold, indices, BTC and 5-decimal FX.
• Timezone: your own region, so the market-closed status is correct.
• Bar Replay Mode: turn this on while using TradingView's Bar Replay so the HUD keeps updating.
• Colours and HUD position are cosmetic only.

EXAMPLE SETTINGS (starting points, not recommendations)
These were tested on about three months of 1-minute broker data (Jul-Oct 2026) with real spreads. The samples are small (roughly 30-55 trades each), so treat them as starting points to test yourself, not as expected results. The trading hours shown are Irish time (Europe/Dublin), so convert them to your own timezone. For example, 07:00-12:00 Dublin is 11:30-16:30 in India while Ireland is on summer time (12:30-17:30 in winter).
• XAUUSD, 15m: FVG Pullback, Balanced. Traded Mon-Fri 07:00-12:00 (Europe/Dublin). SL 165 / TP 495 pips.
• NAS100, 15m: FVG Pullback, Aggressive. Traded Mon-Fri 18:00-20:30 (Europe/Dublin). SL 550 / TP 1100 pips.
• SP500, 15m: EMA Trend, Conservative. Traded Mon-Fri 14:00-18:00 (Europe/Dublin). SL 58 / TP 116 pips.
This indicator has no session filter, so only take signals during those hours. Pip values depend on your broker's symbol specification, so check the TP and SL lines before trading.

LIMITATIONS
• This indicator doesn't place trades. You enter and manage them yourself, and your fills will differ from the candle close.
• No method works in every market. Results change a lot by symbol, timeframe and settings.
• The benchmark checks need the benchmark symbol's data. When a benchmark market is closed (for example DXY at weekends while crypto trades), that check is skipped.
• Points Per Pip must match your symbol, or the TP and SL levels will be wrong.

This script is for education. It is not financial advice. Past results don't guarantee future results. Test on a demo account first.

## Source Code

````pine
//@version=6
indicator("Open Legacy", overlay = true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPEN LEGACY — manual signals with a live HUD.
// Two strategies, one Sensitivity dial, optional trading hours and news
// pauses, and fixed TP / SL levels for every signal.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ── 1. STRATEGY ──────────────────────────────────────────────────────────
G1 = "1. Strategy"
entryMethod = input.string("FVG Pullback", "Entry Method", options = ["FVG Pullback", "EMA Trend"], group = G1,
     tooltip = "FVG Pullback — price leaves a fair value gap (a candle so fast it leaves an untouched gap), then a signal fires when price pulls back into the gap and turns.\n\nEMA Trend — signals at the start of a new trend leg: fast EMA above slow EMA, price above the fast EMA and RSI above 50 (the reverse for sells).")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = G1,
     tooltip = "Aggressive — the most signals, any timeframe.\n\nBalanced — only signals that agree with the 50 EMA trend.\n\nConservative — also needs the trend on a timeframe 4x your chart to agree, and real trend strength (ADX 20+). The fewest signals, the highest quality.")

// ── 2. TARGETS ───────────────────────────────────────────────────────────
G2 = "2. Targets"
slPips    = input.float(100, "Stop Loss (pips)", minval = 0.1, step = 0.1, group = G2)
tpPips    = input.float(200, "Take Profit (pips)", minval = 0.1, step = 0.1, group = G2,
     tooltip = "Keep Take Profit larger than Stop Loss.")
pipPoints = input.int(10, "Points Per Pip", minval = 1, group = G2,
     tooltip = "10 for gold, indices, BTC and 5-decimal FX.")

// ── 3. FILTERS ───────────────────────────────────────────────────────────
G4 = "3. Filters"
hoursOn    = input.bool(false, "Session 1", group = G4, inline = "h1",
     tooltip = "Tick a session to only show signals inside its hours and days (your Timezone below). Each session has its own days, e.g. Session 1 Mon-Fri 07:00-12:00 and Session 2 Mon-Thu 14:00-18:00. Leave both unticked to trade any time.")
hoursWin   = input.session("0700-1200", "", group = G4, inline = "h1")
hoursDays  = input.string("Mon-Fri", "", options = ["Mon-Fri", "Tue-Fri", "Mon-Thu", "Tue-Thu", "Mon-Wed", "Wed-Fri", "Sun-Fri", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat-Sun", "Sat", "Sun", "Every Day"], group = G4, inline = "h1")
hours2On   = input.bool(false, "Session 2", group = G4, inline = "h2")
hoursWin2  = input.session("1400-1800", "", group = G4, inline = "h2")
hoursDays2 = input.string("Mon-Thu", "", options = ["Mon-Fri", "Tue-Fri", "Mon-Thu", "Tue-Thu", "Mon-Wed", "Wed-Fri", "Sun-Fri", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat-Sun", "Sat", "Sun", "Every Day"], group = G4, inline = "h2")
newsMins  = input.int(30, "News Pause ± mins", minval = 1, group = G4,
     tooltip = "Tick a News line, pick the date and time (24h, your Timezone). No signals from this many minutes before until this many minutes after.")
n1On   = input.bool(false, "News 1", group = G4, inline = "n1")
n1Date = input.time(timestamp("2026-10-13T12:00:00"), "", group = G4, inline = "n1")
n1Hour = input.int(13, "at", minval = 0, maxval = 23, group = G4, inline = "n1")
n1Min  = input.int(30, ":", minval = 0, maxval = 59, group = G4, inline = "n1")
n2On   = input.bool(false, "News 2", group = G4, inline = "n2")
n2Date = input.time(timestamp("2026-10-14T12:00:00"), "", group = G4, inline = "n2")
n2Hour = input.int(13, "at", minval = 0, maxval = 23, group = G4, inline = "n2")
n2Min  = input.int(30, ":", minval = 0, maxval = 59, group = G4, inline = "n2")

// ── 4. DISPLAY ───────────────────────────────────────────────────────────
G3 = "4. Display"
buyColor   = input.color(#4CAF50, "BUY", group = G3, inline = "c")
sellColor  = input.color(#FF5252, "SELL", group = G3, inline = "c")
hudPos     = input.string("Top Right", "HUD Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G3)
sessionTz  = input.string("Europe/Dublin", "Timezone", group = G3,
     tooltip = "Your timezone, IANA format (e.g. Europe/Dublin, America/New_York). Used for Trading Hours, news times and the market-closed status.")
replayMode = input.bool(false, "Bar Replay Mode", group = G3,
     tooltip = "Turn on while using Bar Replay so the HUD keeps updating.")

//── Internal constants ──
useExchangeTz = false
useCorrFilter = true
buyBgColor    = buyColor
buyTextColor  = color.white
sellBgColor   = sellColor
sellTextColor = color.white
corrEmaLen    = 9
corrConfBars  = 3
gracePeriodBars = 6
maxRampBars     = 12

getTablePosition(string pos) =>
    switch pos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.bottom_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🌐 UNIVERSAL HANDS-FREE BENCHMARK ROUTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Returns [benchmarkSymbol, isInverseRelationship]
// isInverseRelationship = true  -> benchmark moving UP pushes asset toward SL if asset is a BUY
//                                  (i.e. benchmark should move OPPOSITE the asset to favor TP)
// isInverseRelationship = false -> benchmark should move WITH the asset to favor TP
getUniversalInverseBenchmark() =>
    string p     = syminfo.prefix
    string t     = str.upper(syminfo.ticker)
    string base  = syminfo.basecurrency
    string quote = syminfo.currency

    string symbol  = "TVC:DXY"
    bool   inverse = true

    if t == "USDX" or t == "DXY" or t == "USDOLLAR" or t == "DX"
        symbol := "TVC:GOLD"
        inverse := true
    else if p == "NSE" or p == "BSE" or quote == "INR"
        symbol := "NSE:INDIAVIX"
        inverse := true
    else if str.contains(t, "SPX") or str.contains(t, "US500") or str.contains(t, "SP500") or str.contains(t, "NDX") or str.contains(t, "US100") or str.contains(t, "NAS100") or str.contains(t, "US30") or str.contains(t, "DJI") or str.contains(t, "GER") or str.contains(t, "DAX") or str.contains(t, "UK100") or str.contains(t, "EU50") or p == "NASDAQ" or p == "NYSE"
        symbol := "TVC:VIX"
        inverse := true
    else if base == "USD"
        if quote == "JPY"
            symbol := "TVC:JXY"
            inverse := true
        else if quote == "CAD"
            symbol := "TVC:CXY"
            inverse := true
        else if quote == "CHF"
            symbol := "TVC:SXY"
            inverse := true
        else
            // USD is the BASE here (USDSEK, USDMXN, USDZAR, USDTRY, USDHKD, etc.)
            // DXY moves WITH these pairs, not against them — DIRECT correlation
            symbol := "TVC:DXY"
            inverse := false
    else if quote == "USD"
        symbol := "TVC:DXY"
        inverse := true
    else if quote == "JPY"
        symbol := "TVC:JXY"
        inverse := true
    else if quote == "GBP"
        symbol := "TVC:BXY"
        inverse := true
    else if quote == "EUR"
        symbol := "TVC:EXY"
        inverse := true

    [symbol, inverse]

getBenchmarkDisplayName(string symbol) =>
    switch symbol
        "NSE:INDIAVIX" => "India VIX"
        "TVC:VIX"      => "VIX"
        "TVC:DXY"      => "DXY"
        "TVC:GOLD"     => "Gold"
        "TVC:JXY"      => "Yen Index"
        "TVC:BXY"      => "Pound Index"
        "TVC:EXY"      => "Euro Index"
        "TVC:CXY"      => "CAD Index"
        "TVC:SXY"      => "CHF Index"
        => symbol

[routedBenchSymbol, routedBenchInverse] = getUniversalInverseBenchmark()

string activeBenchSymbol  = routedBenchSymbol
bool   activeBenchInverse = routedBenchInverse
string activeBenchName    = getBenchmarkDisplayName(activeBenchSymbol)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🌙 MARKET-CLOSE DETECTOR — scheduled weekly close OR unscheduled outage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool isCrypto = syminfo.type == "crypto" or str.contains(syminfo.ticker, "BTC") or str.contains(syminfo.ticker, "ETH")

// Scheduled weekly close, evaluated against the REAL current clock (timenow) in
// the chosen timezone. DST is handled automatically via IANA tz names.
// • Mon-Fri: closed 22:00-22:59 local (daily break), reopens 23:00
// • Fri 22:00 onward through all of Sat through Sun 22:59: weekend closed
// • Reopens Sunday 23:00 local
f_isScheduledClose(string tz) =>
    int dow = dayofweek(timenow, tz)  // Pine: 1 = Sunday ... 7 = Saturday
    int hr  = hour(timenow, tz)
    bool weekdayBreak  = (dow >= 2 and dow <= 6) and (hr == 22)
    bool weekendClosed = (dow == 6 and hr >= 22) or (dow == 7) or (dow == 1 and hr < 23)
    weekdayBreak or weekendClosed

bool scheduledClosedNow = f_isScheduledClose(useExchangeTz ? syminfo.timezone : sessionTz)

// Live "no fresh data" detector — catches an UNSCHEDULED outage or maintenance
// break of any length (not a fixed window): as long as no new bar has printed
// for 15+ minutes on a genuinely live last bar, it stays flagged closed for
// however long that gap continues, and clears the moment fresh data resumes.
// Only ever evaluated on barstate.isrealtime, so historical/replay bars never
// trigger this regardless of how old their timestamps are.
bool dataStaleNow = barstate.isrealtime and barstate.islast and (timenow - time_close > 900000)

// DXY/forex benchmark closes on the standard schedule even when crypto itself
// keeps trading — bypass the correlation filter during that window.
bool isCryptoDxyOffline = not replayMode and isCrypto and scheduledClosedNow

// Main HUD "market closed" status:
// • non-crypto: closed if EITHER the scheduled weekly window applies OR the
//   feed has genuinely gone stale (unscheduled maintenance/outage)
// • crypto: trades 24/7, so the fixed weekly schedule doesn't apply to the
//   asset itself — only genuine exchange downtime (stale feed) marks it closed
bool isMarketClosedRT = not replayMode and (dataStaleNow or (not isCrypto and scheduledClosedNow))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📊 SIGNAL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Sensitivity presets (literal values keep lengths "simple" for ta.* calls)
fvgLife  = sensitivity == "Aggressive" ? 12  : sensitivity == "Balanced" ? 24  : 40
fvgMin   = sensitivity == "Aggressive" ? 0.10 : sensitivity == "Balanced" ? 0.25 : 0.40
emaFastL = sensitivity == "Aggressive" ? 8   : sensitivity == "Balanced" ? 13  : 21
emaSlowL = sensitivity == "Aggressive" ? 21  : sensitivity == "Balanced" ? 34  : 55

atrV  = ta.atr(14)
ema50 = ta.ema(close, 50)
[diP, diM, adxV] = ta.dmi(14, 14)

// Higher-timeframe trend (4x chart), previous completed candle — never repaints.
htfTf  = timeframe.from_seconds(timeframe.in_seconds() * 4)
htfC   = request.security(syminfo.tickerid, htfTf, close[1], lookahead = barmerge.lookahead_on)
htfE   = request.security(syminfo.tickerid, htfTf, ta.ema(close, 50)[1], lookahead = barmerge.lookahead_on)
bool htfUp = not na(htfE) and htfC > htfE
bool htfDn = not na(htfE) and htfC < htfE

// ── FVG Pullback ──
var float bullTop = na
var float bullBot = na
var int   bullBar = na
var float bearTop = na
var float bearBot = na
var int   bearBar = na
bool fvgBuy  = not na(bullBar) and bar_index - bullBar > 0 and bar_index - bullBar <= fvgLife and low <= bullTop and close > open and close > bullBot
bool fvgSell = not na(bearBar) and bar_index - bearBar > 0 and bar_index - bearBar <= fvgLife and high >= bearBot and close < open and close < bearTop
if fvgBuy
    bullBar := na
if fvgSell
    bearBar := na
if low > high[2] and (low - high[2]) >= fvgMin * atrV
    bullBot := high[2]
    bullTop := low
    bullBar := bar_index
if high < low[2] and (low[2] - high) >= fvgMin * atrV
    bearTop := low[2]
    bearBot := high
    bearBar := bar_index

// ── EMA Trend ──
emaF = ta.ema(close, emaFastL)
emaS = ta.ema(close, emaSlowL)
rsiV = ta.rsi(close, 14)
bool trUp = emaF > emaS and close > emaF and rsiV > 50
bool trDn = emaF < emaS and close < emaF and rsiV < 50
bool trendBuy  = trUp and not trUp[1]
bool trendSell = trDn and not trDn[1]

// ── Sensitivity filter ──
bool rawBuy  = entryMethod == "FVG Pullback" ? fvgBuy  : trendBuy
bool rawSell = entryMethod == "FVG Pullback" ? fvgSell : trendSell
bool qBuy  = sensitivity == "Aggressive" or (close > ema50 and (sensitivity == "Balanced" or (htfUp and adxV >= 20)))
bool qSell = sensitivity == "Aggressive" or (close < ema50 and (sensitivity == "Balanced" or (htfDn and adxV >= 20)))
bool sigBuy  = rawBuy and qBuy
bool sigSell = rawSell and qSell and not sigBuy
slowEma = ema50


rawBenchClose = request.security(activeBenchSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
rawBenchEma   = request.security(activeBenchSymbol, timeframe.period, ta.ema(close, corrEmaLen), barmerge.gaps_off, barmerge.lookahead_off)

benchClose = nz(rawBenchClose, close)
benchEma   = nz(rawBenchEma, ta.ema(close, corrEmaLen))

bool rawBenchBullish = benchClose > benchEma
bool rawBenchBearish = benchClose < benchEma
bool benchBullish = ta.lowest(rawBenchBullish ? 1 : 0, corrConfBars) == 1
bool benchBearish = ta.lowest(rawBenchBearish ? 1 : 0, corrConfBars) == 1

// benchFavorsBuy/Sell = benchmark is moving in the direction that supports price
// heading toward TP (not SL) for the current trade direction.
bool benchFavorsBuy  = activeBenchInverse ? benchBearish : benchBullish
bool benchFavorsSell = activeBenchInverse ? benchBullish : benchBearish

bool corrBuyConfirm  = not useCorrFilter or isCryptoDxyOffline or benchFavorsBuy
bool corrSellConfirm = not useCorrFilter or isCryptoDxyOffline or benchFavorsSell


// ── Filters: trading hours + news pauses ──
f_dayList(string opt) =>
    switch opt
        "Mon-Fri"   => "23456"
        "Tue-Fri"   => "3456"
        "Mon-Thu"   => "2345"
        "Tue-Thu"   => "345"
        "Mon-Wed"   => "234"
        "Wed-Fri"   => "456"
        "Sun-Fri"   => "123456"
        "Mon"       => "2"
        "Tue"       => "3"
        "Wed"       => "4"
        "Thu"       => "5"
        "Fri"       => "6"
        "Sat-Sun"   => "17"
        "Sat"       => "7"
        "Sun"       => "1"
        => "1234567"
f_hhmm(string s, int p) =>
    int(str.tonumber(str.substring(s, p, p + 2)))
int  barMins = hour(time, sessionTz) * 60 + minute(time, sessionTz)
f_inWin(string w) =>
    int hs = f_hhmm(w, 0) * 60 + f_hhmm(w, 2)
    int he = f_hhmm(w, 5) * 60 + f_hhmm(w, 7)
    he > hs ? (barMins >= hs and barMins < he) : (barMins >= hs or barMins < he)
string dowNow = str.tostring(dayofweek(time, sessionTz))
bool inS1 = hoursOn  and str.contains(f_dayList(hoursDays),  dowNow) and f_inWin(hoursWin)
bool inS2 = hours2On and str.contains(f_dayList(hoursDays2), dowNow) and f_inWin(hoursWin2)
bool inHours = (not hoursOn and not hours2On) or inS1 or inS2

// News: no signals on candles that close within the window around each event.
f_newsTs(int pick, int hh, int mm) =>
    timestamp(sessionTz, year(pick, sessionTz), month(pick, sessionTz), dayofmonth(pick, sessionTz), hh, mm)
int newsMs = newsMins * 60000
f_nearNews(bool on, int ts) =>
    on and time_close >= ts - newsMs and time_close <= ts + newsMs
bool inNews = f_nearNews(n1On, f_newsTs(n1Date, n1Hour, n1Min)) or f_nearNews(n2On, f_newsTs(n2Date, n2Hour, n2Min))

// ── Signals ──
bool confirmedBar = barstate.isconfirmed or replayMode
bool buy1  = sigBuy  and inHours and not inNews
bool sell1 = sigSell and inHours and not inNews

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔒 MULTI-TIER PERSISTENT FIXED RISK ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool   tradeActive     = false
var string activeSignalTag = "WAITING"
var float  lockedEntry     = na
var float  lockedTpPrice   = na
var float  lockedSlPrice   = na
var bool   activeIsBuy     = false
var string lastTpText      = "---"
var string lastSlText      = "---"

var int benchConfirmStreak = 0
var int benchInvalidStreak = 0
var int trendConfirmStreak = 0
var int trendInvalidStreak = 0

var line  lineSL  = na
var line  lineTP  = na
var label labelSL = na
var label labelTP = na
var int   tradeEntryBar = na

// One trade at a time: while a trade is open, a signal in the
// same direction is ignored. An opposite signal still flips it.
// (tradeActive / activeIsBuy still hold the previous candle's state here.)
bool exitsThisBar = tradeActive and bar_index > tradeEntryBar and not na(lockedTpPrice) and
     (activeIsBuy ? (high >= lockedTpPrice or low <= lockedSlPrice) : (low <= lockedTpPrice or high >= lockedSlPrice))
bool flat = not tradeActive or exitsThisBar
newBuySignal  = buy1  and (flat or not activeIsBuy)
newSellSignal = sell1 and (flat or activeIsBuy)

string masterAlertMsg = ""

if (newBuySignal or newSellSignal) and (barstate.isconfirmed or replayMode)
    activeIsBuy := newBuySignal

    finalTpDist = tpPips * pipPoints * syminfo.mintick
    finalSlDist = slPips * pipPoints * syminfo.mintick

    lockedEntry   := close
    lockedTpPrice := activeIsBuy ? close + finalTpDist : close - finalTpDist
    lockedSlPrice := activeIsBuy ? close - finalSlDist : close + finalSlDist
    tradeEntryBar := bar_index

    string tag = newBuySignal ? "BUY" : "SELL"
    activeSignalTag := tag + " ACTIVE"
    tradeActive     := true

    lastTpText      := "---"
    lastSlText      := "---"

    benchConfirmStreak := 0
    benchInvalidStreak := 0
    trendConfirmStreak := 0
    trendInvalidStreak := 0

    masterAlertMsg  := "🚀 " + syminfo.ticker + " (" + timeframe.period + ") New " + tag + " Active!" + "\n📌 Entry: " + str.tostring(lockedEntry, "#.##") + "\n🎯 TP: " + str.tostring(lockedTpPrice, "#.##") + "\n🛡️ SL: " + str.tostring(lockedSlPrice, "#.##")

    if not na(lineSL)
        line.delete(lineSL)
    if not na(lineTP)
        line.delete(lineTP)
    if not na(labelSL)
        label.delete(labelSL)
    if not na(labelTP)
        label.delete(labelTP)

    int endX = bar_index + 12
    lineSL  := line.new(bar_index, lockedSlPrice, endX, lockedSlPrice, color = color.red, width = 2, style = line.style_dashed)
    labelSL := label.new(endX, lockedSlPrice, tag + " SL: " + str.tostring(lockedSlPrice, "#.##"), style = label.style_label_left, color = color.red, textcolor = color.white, size = size.tiny)

    lineTP  := line.new(bar_index, lockedTpPrice, endX, lockedTpPrice, color = color.green, width = 2, style = line.style_dashed)
    labelTP := label.new(endX, lockedTpPrice, tag + " TP: " + str.tostring(lockedTpPrice, "#.##"), style = label.style_label_left, color = color.green, textcolor = color.white, size = size.tiny)

if tradeActive and not na(lockedTpPrice) and not na(lockedSlPrice) and bar_index > tradeEntryBar
    bool tpHit = activeIsBuy ? (high >= lockedTpPrice) : (low <= lockedTpPrice)
    bool slHit = activeIsBuy ? (low <= lockedSlPrice)  : (high >= lockedSlPrice)

    if tpHit or slHit
        if tpHit
            float tpDistance = math.abs(lockedTpPrice - lockedEntry)
            activeSignalTag := "TP HIT 🎉"
            lastTpText      := "Hit (+ " + str.tostring(tpDistance, "#.##") + ")"
            masterAlertMsg  := "🎯 " + syminfo.ticker + " (" + timeframe.period + ") Take Profit Hit!\n✨ Reached Target (+ " + str.tostring(tpDistance, "#.##") + " pts)"
        else if slHit
            float slDistance = math.abs(lockedSlPrice - lockedEntry)
            activeSignalTag := "SL HIT ❌"
            lastSlText      := "Hit (- " + str.tostring(slDistance, "#.##") + ")"
            masterAlertMsg  := "🛑 " + syminfo.ticker + " (" + timeframe.period + ") Stop Loss Hit!\n⚠️ Breached (- " + str.tostring(slDistance, "#.##") + " pts)"

        tradeActive := false
        if not na(lineSL)
            line.delete(lineSL)
            lineSL := na
        if not na(lineTP)
            line.delete(lineTP)
            lineTP := na
        if not na(labelSL)
            label.delete(labelSL)
            labelSL := na
        if not na(labelTP)
            label.delete(labelTP)
            labelTP := na

if masterAlertMsg != ""
    alert(masterAlertMsg, alert.freq_once_per_bar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🧠 SETUP SCORE + BENCHMARK STATUS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool isCorrelationConfirmedNow = (activeIsBuy and benchFavorsBuy) or (not activeIsBuy and benchFavorsSell)
bool isTrendAlignedNow         = (activeIsBuy and close > slowEma) or (not activeIsBuy and close < slowEma)

if tradeActive
    if isCorrelationConfirmedNow
        benchConfirmStreak := benchConfirmStreak + 1
        benchInvalidStreak := 0
    else
        benchInvalidStreak := benchInvalidStreak + 1
        benchConfirmStreak := 0

    if isTrendAlignedNow
        trendConfirmStreak := trendConfirmStreak + 1
        trendInvalidStreak := 0
    else
        trendInvalidStreak := trendInvalidStreak + 1
        trendConfirmStreak := 0

// Setup Score = the chance price reaches TP before SL from where it is NOW.
// It's the classic first-passage ("gambler's ruin") probability: with no
// built-in edge assumed, the odds equal the SL distance divided by the total
// TP + SL distance from the current price. Tested on 12,000+ trade snapshots
// (gold, SP500, NAS100), this beat the old blended score — adding trend,
// momentum or benchmark bonuses made the prediction LESS accurate, so they
// are shown on their own HUD lines instead of being mixed in.
float tpOdds = na
if activeSignalTag == "TP HIT 🎉"
    tpOdds := 100.0
else if activeSignalTag == "SL HIT ❌"
    tpOdds := 0.0
else if tradeActive and not na(lockedTpPrice) and not na(lockedSlPrice)
    float toTp = activeIsBuy ? lockedTpPrice - close : close - lockedTpPrice
    float toSl = activeIsBuy ? close - lockedSlPrice : lockedSlPrice - close
    tpOdds := toTp <= 0 ? 99.0 : toSl <= 0 ? 1.0 : math.min(99.0, math.max(1.0, 100.0 * toSl / (toTp + toSl)))

// HUD label uses the same streaks as the odds score — only flips to Invalid once
// the benchmark has pushed toward SL for longer than the grace period, and flips
// back to Confirmed as soon as it favors TP again.
bool isCorrelationConfirmedForLabel = benchConfirmStreak > 0 or benchInvalidStreak <= gracePeriodBars

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📱 DYNAMIC HUD TABLE RENDERER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table hud = table.new(position = getTablePosition(hudPos), columns = 2, rows = 7, bgcolor = color.rgb(18, 18, 24, 10), border_color = color.rgb(40, 40, 50), border_width = 1)

if barstate.islast or replayMode
    color headerBg = color.rgb(25, 30, 45)
    color rowBg1   = color.rgb(20, 20, 28)
    color rowBg2   = color.rgb(14, 14, 20)
    color baseBg   = color.rgb(8, 8, 12)

    bool hasHitTargetOrStop = (activeSignalTag == "TP HIT 🎉" or activeSignalTag == "SL HIT ❌")

    string idleNote = not inHours ? "Off Hours 🌙" : inNews ? "News Pause 📰" : "Waiting ⏳"
    string topHeaderStatus = isMarketClosedRT ? "CLOSED 💤" : (hasHitTargetOrStop or activeSignalTag == "WAITING" ? idleNote : activeSignalTag)
    color topHeaderColor   = isMarketClosedRT ? color.rgb(150, 150, 160) : (hasHitTargetOrStop ? color.rgb(241, 196, 15) : (str.contains(activeSignalTag, "BUY") ? color.rgb(46, 204, 113) : color.rgb(231, 76, 60)))

    string correlStatus = isCryptoDxyOffline ? "CLOSED 💤" : (isMarketClosedRT ? "CLOSED 💤" : (not tradeActive ? "Ready ⏳" : (isCorrelationConfirmedForLabel ? "Confirmed ✅" : "Invalid ❌")))

    table.cell(hud, 0, 0, "Open Legacy (" + syminfo.ticker + ")", text_color=color.rgb(220, 225, 235), bgcolor=headerBg, text_size=size.small)
    table.cell(hud, 1, 0, topHeaderStatus, text_color=topHeaderColor, bgcolor=headerBg, text_size=size.small)

    string statusOddsVal  = isMarketClosedRT ? "Market Closed 💤" : (hasHitTargetOrStop ? "Waiting ⏳" : (activeSignalTag == "WAITING" ? "Waiting..." : str.tostring(tpOdds, "#") + "% to TP"))
    string fixedEntryVal  = isMarketClosedRT ? "CLOSED 💤" : (hasHitTargetOrStop ? "Waiting ⏳" : (na(lockedEntry) ? "Waiting..." : str.tostring(lockedEntry, "#.##")))
    string takeProfitVal  = isMarketClosedRT ? "CLOSED 💤" : (hasHitTargetOrStop ? "Waiting ⏳" : (lastTpText != "---" ? lastTpText : (na(lockedTpPrice) ? "Waiting..." : str.tostring(lockedTpPrice, "#.##"))))
    string stopLossVal    = isMarketClosedRT ? "CLOSED 💤" : (hasHitTargetOrStop ? "Waiting ⏳" : (lastSlText != "---" ? lastSlText : (na(lockedSlPrice) ? "Waiting..." : str.tostring(lockedSlPrice, "#.##"))))
    string benchStructVal = correlStatus

    table.cell(hud, 0, 1, "🎯 Setup Score", text_color=color.rgb(180, 185, 195), bgcolor=rowBg1, text_size=size.small)
    table.cell(hud, 1, 1, statusOddsVal, text_color=isMarketClosedRT ? color.rgb(150, 150, 160) : (hasHitTargetOrStop ? color.rgb(241, 196, 15) : color.rgb(241, 196, 15)), bgcolor=rowBg1, text_size=size.small)

    table.cell(hud, 0, 2, "📌 Fixed Entry", text_color=color.rgb(180, 185, 195), bgcolor=rowBg2, text_size=size.small)
    table.cell(hud, 1, 2, fixedEntryVal, text_color=isMarketClosedRT ? color.rgb(150, 150, 160) : color.white, bgcolor=rowBg2, text_size=size.small)

    table.cell(hud, 0, 3, "🚀 Take Profit", text_color=color.rgb(180, 185, 195), bgcolor=rowBg1, text_size=size.small)
    table.cell(hud, 1, 3, takeProfitVal, text_color=isMarketClosedRT ? color.rgb(150, 150, 160) : color.rgb(46, 204, 113), bgcolor=rowBg1, text_size=size.small)

    table.cell(hud, 0, 4, "🛡️ Stop Loss", text_color=color.rgb(180, 185, 195), bgcolor=rowBg2, text_size=size.small)
    table.cell(hud, 1, 4, stopLossVal, text_color=isMarketClosedRT ? color.rgb(150, 150, 160) : color.rgb(231, 76, 60), bgcolor=rowBg2, text_size=size.small)

    table.cell(hud, 0, 5, "🌐 " + activeBenchName + " Structure", text_color=color.rgb(200, 210, 230), bgcolor=rowBg1, text_size=size.small)
    table.cell(hud, 1, 5, benchStructVal, text_color=isCryptoDxyOffline ? color.rgb(150, 150, 160) : (isMarketClosedRT ? color.rgb(150, 150, 160) : (correlStatus == "Ready ⏳" ? color.rgb(150, 150, 160) : (isCorrelationConfirmedForLabel ? color.rgb(46, 204, 113) : color.rgb(231, 76, 60)))), bgcolor=rowBg1, text_size=size.small)

    bool structTrendUp    = close > slowEma
    bool structTrendDown  = close < slowEma
    bool structCorrBull   = activeBenchInverse ? benchBearish : benchBullish
    bool structCorrBear   = activeBenchInverse ? benchBullish : benchBearish
    bool structAgree      = (structTrendUp and structCorrBull) or (structTrendDown and structCorrBear)
    bool structConflict   = (structTrendUp and structCorrBear) or (structTrendDown and structCorrBull)
    string structureLabel = not tradeActive ? "Waiting ⏳" : (structAgree ? "Strong" : (structConflict ? "Weak" : "Decent"))
    color  structureColor = not tradeActive ? color.rgb(150, 150, 160) : (structAgree ? color.rgb(46, 204, 113) : (structConflict ? color.rgb(231, 76, 60) : color.rgb(241, 196, 15)))
    table.cell(hud, 0, 6, "Overall Structure", text_color=color.rgb(180, 185, 195), bgcolor=baseBg, text_size=size.small)
    table.cell(hud, 1, 6, structureLabel, text_color=structureColor, bgcolor=baseBg, text_size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎨 SIGNAL LABELS — only on a closed candle, so a label never vanishes.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(newBuySignal  and confirmedBar, title = "BUY Label",  style = shape.labelup,   location = location.belowbar, color = buyBgColor,  text = "BUY",  textcolor = buyTextColor,  size = size.small)
plotshape(newSellSignal and confirmedBar, title = "SELL Label", style = shape.labeldown, location = location.abovebar, color = sellBgColor, text = "SELL", textcolor = sellTextColor, size = size.small)
````

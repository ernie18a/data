# Open Legacy Bot

- url: https://www.tradingview.com/script/Hz2fxv9K-Open-Legacy-Bot/
- type: strategy
- pine_id: PUB;00e0613d7e454a73aec68df31754aba0
- version: 2.0

## Description

OPEN LEGACY BOT

Open Legacy Bot is a trading strategy that finds entries with one of two classic methods, filters them with one shared trend check, and manages the whole trade: sessions, news blackouts, take profit and stop loss. It can also send orders to MetaTrader 5 through PineConnector, so what you see in the Strategy Tester is what the alerts send.

HOW IT FINDS ENTRIES (Entry Method)
• FVG Pullback: a fair value gap is the space left when a candle's low is above the high from two candles earlier (or the reverse for a bearish gap). Gaps smaller than a share of ATR(14) are ignored. A buy fires when price pulls back into a bullish gap and a candle closes bullish back above the gap's bottom, while the gap is still recent (the reverse for sells).
• EMA Trend: a buy fires on the first candle where the fast EMA is above the slow EMA, price closes above the fast EMA and RSI(14) is above 50. It fires once per trend leg, not on every candle (the reverse for sells).

HOW THE FILTER WORKS (Sensitivity)
One setting controls both methods:
• Aggressive: every valid setup, with faster lengths (EMA 8/21, short gap lifetime).
• Balanced: the setup must also agree with the 50 EMA (EMA 13/34).
• Conservative: also needs price on the same side of the 50 EMA on a timeframe 4x the chart, and ADX(14) of 20 or more (EMA 21/55, longer gap lifetime, larger minimum gap).
The higher-timeframe check reads the previous completed higher-timeframe candle, so it doesn't repaint.

WHY THE PIECES WORK TOGETHER
The entries find the moment to get in. The shared filter decides whether the market is trending enough to act on it. One dial moves both from more trades to fewer, higher-quality trades, so you don't need to tune many separate inputs.

TRADE MANAGEMENT
• One position at a time. An opposite signal closes the open trade and reverses it.
• Take profit and stop loss are fixed distances in pips from the entry.
• Up to two trading sessions, each with its own days (Mon-Fri, Tue-Fri, single days, weekends and more), in your timezone. New entries need at least one candle left in the session.
• Optional: close open trades at session end.
• News blackouts: enter up to three event times. No new trades within the set minutes either side, and an open trade closes when a blackout starts.

SCOREBOARD
A table shows each closed trade by day and session: TP hit, SL hit, or closed early in profit or loss. It also shows a win %. You can choose This Week, Last Week, a past week, the last 2/4/8/12 weeks, or All Time.

AUTOMATION (optional)
Fill in your PineConnector License ID, MT5 symbol and lot size. Then create two alerts on the strategy:
1. Condition "alert() function calls only", with the webhook on and pointing to your PineConnector URL. This sends buy, sell and close orders, with TP and SL in pips. It also pauses the EA outside your sessions.
2. Condition "Order fills only", with the message {{ticker}} {{strategy.order.comment}}, for readable phone notifications such as "XAUUSD BUY" or "XAUUSD TP".
Set the alerts to the same timeframe as the chart, and run one timeframe per symbol.

DEFAULT PROPERTIES AND WHY
• Script execution is on bar close: signals are only confirmed when a candle closes, and orders fill at that candle's close. The strategy doesn't recalculate on every tick or after order fills.
• Pyramiding is 1, because the strategy holds one position at a time.
• Order size is 1 unit per trade, a fixed quantity, so results don't compound. Your real broker size is set separately by the Lot Size input.
• Commission is 0 because this was built for CFD brokers that charge through the spread, not a commission. Spread isn't included in TradingView's backtest. Add your own broker's commission and slippage in Properties to make the results more conservative.

EXAMPLE SETTINGS (starting points, not recommendations)
These were tested on about three months of 1-minute broker data (Jul-Oct 2026) with real spreads. The samples are small (roughly 30-55 trades each), so treat them as starting points to test yourself, not as expected results.
All session times below are Irish time (Europe/Dublin). To use them as written, set the Timezone input to Europe/Dublin wherever you are, and the bot converts them to your chart for you. For example, 07:00-12:00 Dublin is 11:30-16:30 in India while Ireland is on summer time (12:30-17:30 in winter).
• XAUUSD, 15m: FVG Pullback, Balanced. Mon-Fri 07:00-12:00 (Europe/Dublin). SL 165 / TP 495 pips.
• NAS100, 15m: FVG Pullback, Aggressive. Mon-Fri 18:00-20:30 (Europe/Dublin). SL 550 / TP 1100 pips.
• SP500, 15m: EMA Trend, Conservative. Mon-Fri 14:00-18:00 (Europe/Dublin). SL 58 / TP 116 pips.
All examples use Points Per Pip 10, Session 2 off and Close Trades At Session End on. Pip values depend on your broker's symbol specification, so check the TP and SL lines on the chart before trading.

LIMITATIONS
• Backtest fills are at the candle's close, without spread or slippage, so live broker fills will differ.
• No method works in every market. Results change a lot by symbol, timeframe, session and settings, so test your own setup.
• Points Per Pip must match your symbol (10 suits gold, indices, BTC and 5-decimal FX), or the TP and SL distances on the chart will be wrong.
• News blackout times are entered manually.
• Automation depends on TradingView alerts, PineConnector and your MT5 terminal all running.

This script is for education and testing. It is not financial advice. Past results don't guarantee future results. Test on a demo account first.

## Source Code

````pine
//@version=6
// Properties are pre-set so you never need to open that tab: one position at
// a time, no margin limits, and a large internal balance so no entry is ever
// rejected. Internal sizing is bookkeeping only — your real size is Lot Size.
strategy("Open Legacy Bot", overlay = true,
     initial_capital = 1000000, default_qty_type = strategy.fixed, default_qty_value = 1,
     pyramiding = 1, margin_long = 0, margin_short = 0,
     calc_on_every_tick = false, process_orders_on_close = true, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🤖 OPEN LEGACY BOT
//  Two proven strategies, one sensitivity dial, your sessions and news
//  blackouts, PineConnector orders, phone alerts and a TP/SL scoreboard.
//
//  ALERTS (two, on this script):
//   Alert 1 — Condition "alert() function calls only", Webhook ON with your
//             PineConnector URL, push OFF. (Message box is not used.)
//   Alert 2 — Condition "Order fills only", message
//             {{ticker}} {{strategy.order.comment}}
//             push ON, webhook OFF.  Reads e.g. "XAUUSD BUY", "XAUUSD TP".
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ── 1. STRATEGY ───────────────────────────────────────────────────────────
G1 = "1. Strategy"
entryMethod = input.string("FVG Pullback", "Entry Method", options = ["FVG Pullback", "EMA Trend"], group = G1,
     tooltip = "FVG Pullback — price leaves a fair value gap (a candle so fast it leaves an untouched gap), then the bot enters when price pulls back into the gap and turns.\n\nEMA Trend — enters at the start of a new trend leg: fast EMA above slow EMA, price above the fast EMA and RSI above 50 (the reverse for sells).")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Aggressive", "Balanced", "Conservative"], group = G1,
     tooltip = "Aggressive — the most trades. Every valid setup, works on any timeframe.\n\nBalanced — only setups that agree with the 50 EMA trend. Roughly half the trades of Aggressive.\n\nConservative — also needs the trend on a timeframe 4x your chart to agree, and real trend strength (ADX 20+). The fewest trades, the highest quality.")
tfLock = input.string("Off", "Only Trade On Timeframe", options = ["Off", "1", "3", "5", "15", "30", "60"], group = G1,
     tooltip = "Off — trades on whatever timeframe the chart (and alert) uses. Pick a value to stop it trading on any other timeframe by mistake.")

// ── 2. SESSIONS ───────────────────────────────────────────────────────────
G2 = "2. Sessions"
s1Time = input.session("0700-1200", "Session 1", group = G2, inline = "s1")
s1Days = input.string("Mon-Fri", "", options = ["Mon-Fri", "Tue-Fri", "Mon-Thu", "Tue-Thu", "Mon-Wed", "Wed-Fri", "Sun-Fri", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat-Sun", "Sat", "Sun", "Every Day", "Off"], group = G2, inline = "s1",
     tooltip = "📆 Pick the days each session trades. Off switches the session off.")
s2Time = input.session("1400-1800", "Session 2", group = G2, inline = "s2")
s2Days = input.string("Off", "", options = ["Mon-Fri", "Tue-Fri", "Mon-Thu", "Tue-Thu", "Mon-Wed", "Wed-Fri", "Sun-Fri", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat-Sun", "Sat", "Sun", "Every Day", "Off"], group = G2, inline = "s2")
sessionTz = input.string("Europe/Dublin", "Timezone", group = G2,
     tooltip = "Your timezone, IANA format — e.g. Europe/Dublin, Europe/London, America/New_York.")
closeAtSessionEnd = input.bool(true, "Close Trades At Session End", group = G2)

// ── 3. NEWS BLACKOUTS ─────────────────────────────────────────────────────
G3 = "3. News Blackouts"
newsSide = input.int(30, "Minutes Either Side", minval = 1, group = G3,
     tooltip = "No new trades from this many minutes before each event until this many minutes after. Any open trade is closed as the window starts.")
n1On   = input.bool(false, "News 1", group = G3, inline = "n1")
n1Date = input.time(timestamp("2026-10-13T12:00:00"), "", group = G3, inline = "n1")
n1Hour = input.int(13, "at", minval = 0, maxval = 23, group = G3, inline = "n1")
n1Min  = input.int(30, ":", minval = 0, maxval = 59, group = G3, inline = "n1")
n2On   = input.bool(false, "News 2", group = G3, inline = "n2")
n2Date = input.time(timestamp("2026-10-14T12:00:00"), "", group = G3, inline = "n2")
n2Hour = input.int(13, "at", minval = 0, maxval = 23, group = G3, inline = "n2")
n2Min  = input.int(30, ":", minval = 0, maxval = 59, group = G3, inline = "n2")
n3On   = input.bool(false, "News 3", group = G3, inline = "n3")
n3Date = input.time(timestamp("2026-10-15T12:00:00"), "", group = G3, inline = "n3")
n3Hour = input.int(13, "at", minval = 0, maxval = 23, group = G3, inline = "n3")
n3Min  = input.int(30, ":", minval = 0, maxval = 59, group = G3, inline = "n3")

// ── 4. BROKER (PINECONNECTOR) ─────────────────────────────────────────────
G4 = "4. Broker (PineConnector)"
licenseId = input.string("YourLicenseID", "License ID", group = G4)
mt5Symbol = input.string("", "MT5 Symbol", group = G4,
     tooltip = "Exactly as in MT5 Market Watch, e.g. XAUUSD.s. Leave blank to use the chart's symbol.")
lotSize   = input.float(0.01, "Lot Size", minval = 0.01, step = 0.01, group = G4)
slPips    = input.float(100, "Stop Loss (pips)", minval = 0.1, step = 0.1, group = G4)
tpPips    = input.float(200, "Take Profit (pips)", minval = 0.1, step = 0.1, group = G4,
     tooltip = "Keep Take Profit larger than Stop Loss.")
pipPoints = input.int(10, "Points Per Pip", minval = 1, group = G4,
     tooltip = "10 for gold, indices, BTC and 5-decimal FX. Only affects the chart and backtest — PineConnector applies the pips above itself.")
pauseEA   = input.bool(true, "Pause EA Outside Sessions", group = G4,
     tooltip = "Sends eaon when a session starts and eaoff after it ends.")

// ── 5. DISPLAY ────────────────────────────────────────────────────────────
G5 = "5. Display"
sbShow      = input.bool(true, "📊 Show Scoreboard", group = G5)
sbPeriod    = input.string("This Week", "📅 Show Results For", options = ["This Week", "Last Week", "2 Weeks Ago", "3 Weeks Ago", "4 Weeks Ago", "Last 2 Weeks", "Last 4 Weeks", "Last 8 Weeks", "Last 12 Weeks", "All Time"], group = G5,
     tooltip = "📅 One week: This Week, Last Week, 2-4 Weeks Ago.\n📈 Several weeks added up: Last 2/4/8/12 Weeks (this week included).\n♾️ All Time: every trade on the chart, best for backtesting.")
showMarks   = input.bool(true, "Show TP/SL Lines & Session Markers", group = G5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool tfOk = tfLock == "Off" or timeframe.period == tfLock
int  tfMin = timeframe.in_seconds() / 60

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

// Scoreboard period -> weeks to add up (0 = all) and weeks back
int sbSpan = switch sbPeriod
    "Last 2 Weeks"  => 2
    "Last 4 Weeks"  => 4
    "Last 8 Weeks"  => 8
    "Last 12 Weeks" => 12
    "All Time"      => 0
    => 1
int sbWeeksBack = switch sbPeriod
    "Last Week"   => 1
    "2 Weeks Ago" => 2
    "3 Weeks Ago" => 3
    "4 Weeks Ago" => 4
    => 0

// ── Sessions ──
f_days(string opt) =>
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
        "Every Day" => "1234567"
        => ""

f_hm(string s, int p) =>
    int(str.tonumber(str.substring(s, p, p + 2)))

f_mins(int t) =>
    hour(t, sessionTz) * 60 + minute(t, sessionTz)

// true when time t falls inside the window on one of its days
f_inSess(int t, string sess, string days) =>
    int st = f_hm(sess, 0) * 60 + f_hm(sess, 2)
    int en = f_hm(sess, 5) * 60 + f_hm(sess, 7)
    int m  = f_mins(t)
    bool dayOk = str.length(days) > 0 and str.contains(days, str.tostring(dayofweek(t, sessionTz)))
    dayOk and (en > st ? (m >= st and m < en) : (m >= st or m < en))

// entries need the candle to CLOSE inside the window with a candle of room left
f_room(string sess) =>
    int en = f_hm(sess, 5) * 60 + f_hm(sess, 7)
    int st = f_hm(sess, 0) * 60 + f_hm(sess, 2)
    int m  = f_mins(time_close)
    int left = en > m ? en - m : 1440 - m + en
    bool inside = en > st ? (m > st and m < en) : (m > st or m < en)
    not closeAtSessionEnd or (inside and left > tfMin)

string d1 = f_days(s1Days)
string d2 = f_days(s2Days)
bool inWin1 = f_inSess(time, s1Time, d1)
bool inWin2 = f_inSess(time, s2Time, d2)
bool inSession = inWin1 or inWin2
bool sessionStarted = inSession and not inSession[1]
bool sessionEnded   = not inSession and inSession[1]
// true on the LAST candle of a session (its close lands on the session end),
// so trades close exactly at the end time, not one candle later.
bool sessionEndsNow = (inWin1 and not f_inSess(time_close, s1Time, d1)) or (inWin2 and not f_inSess(time_close, s2Time, d2))
bool entryWindow = (inWin1 and f_room(s1Time)) or (inWin2 and f_room(s2Time))

// ── News blackouts ──
f_newsTs(int pick, int hh, int mm) =>
    timestamp(sessionTz, year(pick, sessionTz), month(pick, sessionTz), dayofmonth(pick, sessionTz), hh, mm)
int sideMs = newsSide * 60 * 1000
f_inNews(int t, bool on, int ts) =>
    on and t >= ts - sideMs and t < ts + sideMs
bool inBlackout = f_inNews(time_close, n1On, f_newsTs(n1Date, n1Hour, n1Min)) or f_inNews(time_close, n2On, f_newsTs(n2Date, n2Hour, n2Min)) or f_inNews(time_close, n3On, f_newsTs(n3Date, n3Hour, n3Min))
bool blackoutStarted = inBlackout and not inBlackout[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORDERS — PineConnector commands go out through alert() (Alert 1).
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string sym = mt5Symbol == "" ? syminfo.ticker : mt5Symbol
f_order(string side) =>
    licenseId + "," + side + "," + sym + ",vol_lots=" + str.tostring(lotSize, "#.##") +
     ",sl_pips=" + str.tostring(slPips, "#.##") + ",tp_pips=" + str.tostring(tpPips, "#.##")
f_close(string side) =>
    licenseId + "," + side + "," + sym

float tpDist = tpPips * pipPoints * syminfo.mintick
float slDist = slPips * pipPoints * syminfo.mintick
int   tpTicks = math.round(tpPips * pipPoints)
int   slTicks = math.round(slPips * pipPoints)

// 1. Session end / blackout: flatten (MT5 and the chart)
if (sessionEndsNow and closeAtSessionEnd) or blackoutStarted
    alert(f_close("closelong"), alert.freq_all)
    alert(f_close("closeshort"), alert.freq_all)
    strategy.close_all(comment = blackoutStarted ? "Blackout" : "Session End")

// 2. Entries — one position at a time; an opposite signal reverses it.
bool canTrade = tfOk and entryWindow and not inBlackout and barstate.isconfirmed
if canTrade and sigBuy and strategy.position_size <= 0
    if strategy.position_size < 0
        alert(f_close("closeshort"), alert.freq_all)
    alert(f_order("buy"), alert.freq_all)
    strategy.entry("Long", strategy.long, comment = "BUY")
if canTrade and sigSell and strategy.position_size >= 0
    if strategy.position_size > 0
        alert(f_close("closelong"), alert.freq_all)
    alert(f_order("sell"), alert.freq_all)
    strategy.entry("Short", strategy.short, comment = "SELL")

// 3. TP / SL — the same distances MT5 holds, so the chart and the broker agree.
strategy.exit("XL", from_entry = "Long",  profit = tpTicks, loss = slTicks, comment_profit = "TP", comment_loss = "SL")
strategy.exit("XS", from_entry = "Short", profit = tpTicks, loss = slTicks, comment_profit = "TP", comment_loss = "SL")

// 4. Pause / resume the EA with your sessions (eaoff the candle after the close)
if pauseEA and sessionStarted
    alert(licenseId + ",eaon,eaon", alert.freq_all)
if pauseEA and sessionEnded
    alert(licenseId + ",eaoff,eaoff", alert.freq_all)

// ── Chart ──
float posTp = strategy.position_size > 0 ? strategy.position_avg_price + tpDist : strategy.position_size < 0 ? strategy.position_avg_price - tpDist : na
float posSl = strategy.position_size > 0 ? strategy.position_avg_price - slDist : strategy.position_size < 0 ? strategy.position_avg_price + slDist : na
plot(showMarks ? posTp : na, "TP", color.new(color.green, 0), 2, plot.style_linebr)
plot(showMarks ? posSl : na, "SL", color.new(color.red, 0), 2, plot.style_linebr)
bgcolor(showMarks and inSession ? color.new(color.blue, 94) : na, title = "Session")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📊 SCOREBOARD — reads the bot's own closed trades, so it always matches.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Per week: 14 slots (7 days x 2 sessions) x 4 outcomes
// (0 TP hit, 1 Partial Profit, 2 Partial Loss, 3 SL hit).
var array<int> sbOut = array.new_int(56, 0)
var int sbWeek = 0
var int sbSeen = 0

f_dayIdx(int t) =>
    int d = dayofweek(t, sessionTz)
    d == dayofweek.sunday ? 6 : d - 2

wkNow = weekofyear(time, sessionTz)
if wkNow != wkNow[1] and bar_index > 0
    sbWeek += 1
    for i = 0 to 55
        array.push(sbOut, 0)

while sbSeen < strategy.closedtrades
    int   et   = strategy.closedtrades.entry_time(sbSeen)
    string xc  = strategy.closedtrades.exit_comment(sbSeen)
    float pnl  = strategy.closedtrades.profit(sbSeen)
    int   kind = xc == "TP" ? 0 : xc == "SL" ? 3 : pnl > 0 ? 1 : 2
    int   sIdx = f_inSess(et, s1Time, d1) ? 0 : 1
    int   slot = (sbWeek * 14 + f_dayIdx(et) * 2 + sIdx) * 4 + kind
    array.set(sbOut, slot, array.get(sbOut, slot) + 1)
    sbSeen += 1

var table sb = table.new(position.bottom_right, 5, 16, border_width = 1, frame_width = 2,
     frame_color = color.new(#2A3350, 0), border_color = color.new(#1C2334, 0))

// Strategies only run when a candle closes, so on a live chart the newest
// candle isn't "last" until it closes. Drawing on the last historical candle
// too makes the board appear the moment the chart loads.
if (barstate.islastconfirmedhistory or barstate.isrealtime) and sbShow
    bg    = color.new(#0E1320, 0)
    alt   = color.new(#121829, 0)
    head  = color.new(#18203A, 0)
    sub   = color.new(#141B2E, 0)
    green = color.rgb(47, 212, 128)
    red   = color.rgb(255, 93, 108)
    teal  = color.rgb(46, 196, 182)
    amber = color.rgb(245, 185, 66)
    dim   = color.rgb(118, 126, 146)
    ts    = size.small
    bool s2On = d2 != ""

    int lastWk  = sbWeek - sbWeeksBack
    int firstWk = sbSpan == 0 ? 0 : math.max(0, lastWk - sbSpan + 1)
    bool single = sbSpan == 1
    string hdr  = sbSpan == 0 ? "📅 All" : single ? (sbWeeksBack == 0 ? "📅 This Wk" : sbWeeksBack == 1 ? "📅 Last Wk" : "📅 " + str.tostring(sbWeeksBack) + " Wks Ago") : "📅 " + str.tostring(sbSpan) + " Wks"

    // totals per day/session, and per outcome
    array<int> win  = array.new_int(14, 0)
    array<int> loss = array.new_int(14, 0)
    array<int> o1   = array.new_int(4, 0)
    array<int> o2   = array.new_int(4, 0)
    if lastWk >= 0
        for w = firstWk to lastWk
            for cell = 0 to 13
                for k = 0 to 3
                    int v = array.get(sbOut, (w * 14 + cell) * 4 + k)
                    if v > 0
                        if k <= 1
                            array.set(win, cell, array.get(win, cell) + v)
                        else
                            array.set(loss, cell, array.get(loss, cell) + v)
                        if cell % 2 == 0
                            array.set(o1, k, array.get(o1, k) + v)
                        else
                            array.set(o2, k, array.get(o2, k) + v)

    table.cell(sb, 0, 0, hdr, text_color = color.rgb(214, 220, 234), bgcolor = head, text_size = ts)
    table.cell(sb, 1, 0, "✅ S1", text_color = green, bgcolor = head, text_size = ts)
    table.cell(sb, 2, 0, "❌ S1", text_color = red,   bgcolor = head, text_size = ts)
    table.cell(sb, 3, 0, "✅ S2", text_color = green, bgcolor = head, text_size = ts)
    table.cell(sb, 4, 0, "❌ S2", text_color = red,   bgcolor = head, text_size = ts)

    names = array.from("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
    int today = f_dayIdx(time)
    int t1 = 0
    int l1 = 0
    int t2 = 0
    int l2 = 0
    for d = 0 to 6
        bool isToday = d == today and sbWeeksBack == 0 and single
        color rbg = isToday ? color.new(#1A2440, 0) : (d % 2 == 0 ? bg : alt)
        table.cell(sb, 0, d + 1, (isToday ? "▸ " : "") + array.get(names, d),
             text_color = isToday ? color.rgb(77, 232, 255) : color.rgb(205, 212, 228), bgcolor = rbg, text_size = ts)
        for s = 0 to 1
            int wv = array.get(win, d * 2 + s)
            int lv = array.get(loss, d * 2 + s)
            bool off = s == 1 and not s2On
            table.cell(sb, s * 2 + 1, d + 1, off ? "·" : wv == 0 ? "-" : str.tostring(wv), text_color = off or wv == 0 ? dim : green, bgcolor = rbg, text_size = ts)
            table.cell(sb, s * 2 + 2, d + 1, off ? "·" : lv == 0 ? "-" : str.tostring(lv), text_color = off or lv == 0 ? dim : red, bgcolor = rbg, text_size = ts)
            if s == 0
                t1 += wv
                l1 += lv
            else
                t2 += wv
                l2 += lv

    int totW = t1 + t2
    int totN = totW + l1 + l2
    float winPct = totN > 0 ? totW * 100.0 / totN : 0.0
    color totCol = totN == 0 ? dim : winPct > 50 ? green : winPct < 50 ? red : amber
    table.cell(sb, 0, 8, totN == 0 ? (single ? "🏁 Week" : "🏁 Total") : "🏁 " + str.tostring(winPct, "#") + "%", text_color = totCol, bgcolor = head, text_size = ts)
    table.cell(sb, 1, 8, str.tostring(t1), text_color = green, bgcolor = head, text_size = ts)
    table.cell(sb, 2, 8, str.tostring(l1), text_color = red,   bgcolor = head, text_size = ts)
    table.cell(sb, 3, 8, s2On ? str.tostring(t2) : "·", text_color = s2On ? green : dim, bgcolor = head, text_size = ts)
    table.cell(sb, 4, 8, s2On ? str.tostring(l2) : "·", text_color = s2On ? red   : dim, bgcolor = head, text_size = ts)

    // Outcome breakdown
    table.cell(sb, 0, 9, "📊 Outcome", text_color = color.rgb(214, 220, 234), bgcolor = head, text_size = ts, text_halign = text.align_left)
    table.cell(sb, 1, 9, "S1",    text_color = dim, bgcolor = head, text_size = ts)
    table.cell(sb, 2, 9, "S2",    text_color = dim, bgcolor = head, text_size = ts)
    table.cell(sb, 3, 9, "All",   text_color = dim, bgcolor = head, text_size = ts)
    table.cell(sb, 4, 9, "Share", text_color = dim, bgcolor = head, text_size = ts)
    oNames = array.from("🎯 TP Hit", "◐ Partial +", "◐ Partial −", "🛑 SL Hit")
    oCols  = array.from(green, teal, amber, red)
    for k = 0 to 3
        int v1 = array.get(o1, k)
        int v2 = array.get(o2, k)
        int vt = v1 + v2
        float pct = totN > 0 ? vt * 100.0 / totN : 0.0
        int nb = int(math.round(pct / 20.0))
        string meter = ""
        for q = 1 to 5
            meter += q <= nb ? "▰" : "▱"
        color cc  = array.get(oCols, k)
        color rbg = k % 2 == 0 ? bg : alt
        table.cell(sb, 0, 10 + k, array.get(oNames, k), text_color = cc, bgcolor = rbg, text_size = ts, text_halign = text.align_left)
        table.cell(sb, 1, 10 + k, v1 == 0 ? "-" : str.tostring(v1), text_color = v1 == 0 ? dim : cc, bgcolor = rbg, text_size = ts)
        table.cell(sb, 2, 10 + k, not s2On ? "·" : v2 == 0 ? "-" : str.tostring(v2), text_color = not s2On or v2 == 0 ? dim : cc, bgcolor = rbg, text_size = ts)
        table.cell(sb, 3, 10 + k, str.tostring(vt), text_color = vt == 0 ? dim : cc, bgcolor = sub, text_size = ts)
        table.cell(sb, 4, 10 + k, totN == 0 ? "▱▱▱▱▱" : meter + " " + str.tostring(pct, "#") + "%", text_color = totN == 0 ? dim : cc, bgcolor = sub, text_size = ts, text_halign = text.align_left)

    // spacer so the TradingView footer never covers the last row
    for col = 0 to 4
        table.cell(sb, col, 14, " ", bgcolor = color.new(color.black, 100), text_size = ts)

if showMarks and sessionStarted
    label.new(bar_index, high, "Session Start", style = label.style_label_down, color = color.new(color.gray, 35), textcolor = color.white, size = size.tiny)
if showMarks and sessionEndsNow
    label.new(bar_index, high, "Session End", style = label.style_label_down, color = color.new(color.gray, 35), textcolor = color.white, size = size.tiny)
````

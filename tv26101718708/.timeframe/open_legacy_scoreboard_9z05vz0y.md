# Open Legacy Scoreboard

- url: https://www.tradingview.com/script/9z05vz0Y-Open-Legacy-Scoreboard/
- type: indicator
- pine_id: PUB;ca864edc6a8c4db4b5148597bca945f4
- version: 3.0

## Description

OPEN LEGACY SCOREBOARD

Open Legacy Scoreboard is a results tracker for manual traders who use the Open Legacy indicator. It replays the same BUY and SELL signals with your sessions, news blackouts and pip-based take profit and stop loss. It then counts how each trade would have ended, so you can review results by day, session and week without running a strategy.

HOW IT WORKS WITH OPEN LEGACY
It uses the same engine as the Open Legacy indicator and Open Legacy Bot: the same Entry Method (FVG Pullback or EMA Trend) and the same Sensitivity filter (Aggressive, Balanced, Conservative). Use the same settings as your indicator, and the scoreboard tracks the signals you see. You don't need it if you use Open Legacy Bot, which has the scoreboard built in.

HOW TRADES ARE REPLAYED
• A trade opens at the close of a signal candle, inside one of your sessions and outside any news blackout.
• One trade at a time. An opposite signal closes the open trade and opens the new one.
• From the next candle on, it checks whether the take profit or stop loss was reached. If one candle touches both, it uses 1-minute data to decide which came first.
• Trades can close at session end, and a trade closes when a news blackout starts.

HOW RESULTS ARE COUNTED
• TP Hit: the take profit was reached.
• SL Hit: the stop loss was reached.
• Partial +: closed early in profit (session end, blackout or reversal).
• Partial -: closed early at a loss.
TP Hit and Partial + count as wins. SL Hit and Partial - count as losses.

THE TABLE
• Wins and losses for each weekday, split by Session 1 and Session 2, with today highlighted.
• Totals and an overall win %.
• An outcome breakdown showing how many trades ended each way, with each outcome's share.
• Show Results For: This Week, Last Week, 2-4 Weeks Ago, Last 2/4/8/12 Weeks, or All Time.
• Optional chart markers show each counted entry and where it settled.

SETTINGS
• Strategy: Entry Method, Sensitivity, and an optional timeframe lock.
• Sessions: up to two sessions, each with its own days (Mon-Fri, Tue-Fri, single days, weekends and more), your timezone, and close-at-session-end.
• News Blackouts: up to three event times, with minutes either side.
• Targets: Stop Loss and Take Profit in pips, plus Points Per Pip (10 suits gold, indices, BTC and 5-decimal FX).
• Display: show or hide the scoreboard, choose the period, and turn trade markers on or off.

LIMITATIONS
• This is a replay, not live trading. It assumes fills at the candle close with no spread, slippage or commission, so real results will differ.
• Weeks and days follow the Timezone setting.
• It only counts trades within the chart history TradingView has loaded. The 1-minute data used to break ties also has limited history on very long charts.
• Older trade markers can drop off the chart because of TradingView's label limit. The table totals are not affected.
• Past results don't predict future results.

This script is for education and review. It is not financial advice. Test on a demo account first.

## Source Code

````pine
//@version=6
indicator("Open Legacy Scoreboard", overlay = true, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPEN LEGACY SCOREBOARD
// Replays the Open Legacy indicator's signals — same strategy, filters and
// TP / SL — and tallies how each trade ended. Use the same settings as your
// indicator. One trade at a time: a same-direction signal is ignored while a
// trade is open, an opposite signal closes it and flips.
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
tpPips    = input.float(200, "Take Profit (pips)", minval = 0.1, step = 0.1, group = G2)
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

sessionTz  = input.string("Europe/Dublin", "Timezone", group = G4,
     tooltip = "Your timezone, IANA format (e.g. Europe/Dublin, America/New_York). Used for Trading Hours, news times and the week/day columns.")

// ── 4. DISPLAY ───────────────────────────────────────────────────────────
G5 = "4. Display"
sbShow    = input.bool(true, "📊 Show Scoreboard", group = G5)
sbPeriod  = input.string("This Week", "📅 Show Results For", options = ["This Week", "Last Week", "2 Weeks Ago", "3 Weeks Ago", "4 Weeks Ago", "Last 2 Weeks", "Last 4 Weeks", "Last 8 Weeks", "Last 12 Weeks", "All Time"], group = G5,
     tooltip = "📅 One week: This Week, Last Week, 2-4 Weeks Ago.\n📈 Several weeks added up: Last 2/4/8/12 Weeks (this week included).\n♾️ All Time: every trade on the chart, best for backtesting.")
showMarks = input.bool(true, "Show Trade Markers", group = G5,
     tooltip = "Marks each counted entry, and where it settled.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL ENGINE — identical to the Open Legacy indicator
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

bool sigB = sigBuy  and inHours and not inNews
bool sigS = sigSell and inHours and not inNews

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

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE REPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float tpDist = tpPips * pipPoints * syminfo.mintick
float slDist = slPips * pipPoints * syminfo.mintick

// 1-minute data decides which level came first when one candle hits both.
[m1H, m1L] = request.security_lower_tf(syminfo.tickerid, "1", [high, low])

// Per week: 7 days x 4 outcomes (0 TP hit, 1 Partial +, 2 Partial -, 3 SL hit).
var array<int> sbOut = array.new_int(28, 0)
var int sbWeek = 0
f_dayIdx(int t) =>
    int d = dayofweek(t, sessionTz)
    d == dayofweek.sunday ? 6 : d - 2
wkNow = weekofyear(time, sessionTz)
if wkNow != wkNow[1] and bar_index > 0
    sbWeek += 1
    for i = 0 to 27
        array.push(sbOut, 0)

f_record(int et, int kind) =>
    int slot = (sbWeek * 7 + f_dayIdx(et)) * 4 + kind
    array.set(sbOut, slot, array.get(sbOut, slot) + 1)

f_mark(bool won, string txt, bool atHigh) =>
    if showMarks
        label.new(bar_index, atHigh ? high : low, txt, style = atHigh ? label.style_label_down : label.style_label_up,
             color = won ? color.new(color.green, 20) : color.new(color.red, 20), textcolor = color.white, size = size.tiny)

var int   posDir = 0
var float posEnt = na
var int   posEt  = na
var int   posBar = na

if barstate.isconfirmed
    // 1. TP / SL on this candle (not the entry candle itself)
    if posDir != 0 and bar_index > posBar
        float tpL = posEnt + posDir * tpDist
        float slL = posEnt - posDir * slDist
        bool tpHit = posDir == 1 ? high >= tpL : low <= tpL
        bool slHit = posDir == 1 ? low <= slL : high >= slL
        if tpHit or slHit
            bool won = tpHit and not slHit
            if tpHit and slHit and array.size(m1H) > 0
                bool done = false
                for m = 0 to array.size(m1H) - 1
                    if not done
                        bool mTp = posDir == 1 ? array.get(m1H, m) >= tpL : array.get(m1L, m) <= tpL
                        bool mSl = posDir == 1 ? array.get(m1L, m) <= slL : array.get(m1H, m) >= slL
                        if mTp or mSl
                            won := mTp and not mSl
                            done := true
            f_record(posEt, won ? 0 : 3)
            f_mark(won, won ? "✓ TP" : "✗ SL", won == (posDir == 1))
            posDir := 0
    // 2. Entries — an opposite signal closes the open trade first
    int want = sigB ? 1 : sigS ? -1 : 0
    if want != 0 and want != posDir
        if posDir != 0
            bool won3 = (close - posEnt) * posDir > 0
            f_record(posEt, won3 ? 1 : 2)
            f_mark(won3, won3 ? "◐ Partial +" : "◐ Partial -", true)
        posDir := want
        posEnt := close
        posEt  := time
        posBar := bar_index
        if showMarks
            label.new(bar_index, want == 1 ? low : high, want == 1 ? "BUY" : "SELL", style = want == 1 ? label.style_label_up : label.style_label_down,
                 color = want == 1 ? color.new(color.green, 0) : color.new(color.red, 0), textcolor = color.white, size = size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📊 SCOREBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table sb = table.new(position.bottom_right, 3, 16, border_width = 1, frame_width = 2,
     frame_color = color.new(#2A3350, 0), border_color = color.new(#1C2334, 0))

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

    int lastWk  = sbWeek - sbWeeksBack
    int firstWk = sbSpan == 0 ? 0 : math.max(0, lastWk - sbSpan + 1)
    bool single = sbSpan == 1
    string hdr  = sbSpan == 0 ? "📅 All" : single ? (sbWeeksBack == 0 ? "📅 This Wk" : sbWeeksBack == 1 ? "📅 Last Wk" : "📅 " + str.tostring(sbWeeksBack) + " Wks Ago") : "📅 " + str.tostring(sbSpan) + " Wks"

    array<int> win  = array.new_int(7, 0)
    array<int> loss = array.new_int(7, 0)
    array<int> oc   = array.new_int(4, 0)
    if lastWk >= 0
        for w = firstWk to lastWk
            for d = 0 to 6
                for k = 0 to 3
                    int v = array.get(sbOut, (w * 7 + d) * 4 + k)
                    if v > 0
                        if k <= 1
                            array.set(win, d, array.get(win, d) + v)
                        else
                            array.set(loss, d, array.get(loss, d) + v)
                        array.set(oc, k, array.get(oc, k) + v)

    table.cell(sb, 0, 0, hdr, text_color = color.rgb(214, 220, 234), bgcolor = head, text_size = ts)
    table.cell(sb, 1, 0, "✅ Wins", text_color = green, bgcolor = head, text_size = ts)
    table.cell(sb, 2, 0, "❌ Losses", text_color = red, bgcolor = head, text_size = ts)

    names = array.from("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
    int today = f_dayIdx(time)
    int tw = 0
    int tl = 0
    for d = 0 to 6
        bool isNowDay = d == today and sbWeeksBack == 0 and single
        color rbg = isNowDay ? color.new(#1A2440, 0) : (d % 2 == 0 ? bg : alt)
        int wv = array.get(win, d)
        int lv = array.get(loss, d)
        table.cell(sb, 0, d + 1, (isNowDay ? "▸ " : "") + array.get(names, d),
             text_color = isNowDay ? color.rgb(77, 232, 255) : color.rgb(205, 212, 228), bgcolor = rbg, text_size = ts)
        table.cell(sb, 1, d + 1, wv == 0 ? "-" : str.tostring(wv), text_color = wv == 0 ? dim : green, bgcolor = rbg, text_size = ts)
        table.cell(sb, 2, d + 1, lv == 0 ? "-" : str.tostring(lv), text_color = lv == 0 ? dim : red, bgcolor = rbg, text_size = ts)
        tw += wv
        tl += lv

    int totN = tw + tl
    float winPct = totN > 0 ? tw * 100.0 / totN : 0.0
    color totCol = totN == 0 ? dim : winPct > 50 ? green : winPct < 50 ? red : amber
    table.cell(sb, 0, 8, totN == 0 ? (single ? "🏁 Week" : "🏁 Total") : "🏁 " + str.tostring(winPct, "#") + "%", text_color = totCol, bgcolor = head, text_size = ts)
    table.cell(sb, 1, 8, str.tostring(tw), text_color = green, bgcolor = head, text_size = ts)
    table.cell(sb, 2, 8, str.tostring(tl), text_color = red, bgcolor = head, text_size = ts)

    table.cell(sb, 0, 9, "📊 Outcome", text_color = color.rgb(214, 220, 234), bgcolor = head, text_size = ts, text_halign = text.align_left)
    table.cell(sb, 1, 9, "Trades", text_color = dim, bgcolor = head, text_size = ts)
    table.cell(sb, 2, 9, "Share", text_color = dim, bgcolor = head, text_size = ts)
    oNames = array.from("🎯 TP Hit", "◐ Partial +", "◐ Partial −", "🛑 SL Hit")
    oCols  = array.from(green, teal, amber, red)
    for k = 0 to 3
        int vt = array.get(oc, k)
        float pct = totN > 0 ? vt * 100.0 / totN : 0.0
        int nb = int(math.round(pct / 20.0))
        string meter = ""
        for q = 1 to 5
            meter += q <= nb ? "▰" : "▱"
        color cc  = array.get(oCols, k)
        color rbg = k % 2 == 0 ? bg : alt
        table.cell(sb, 0, 10 + k, array.get(oNames, k), text_color = cc, bgcolor = rbg, text_size = ts, text_halign = text.align_left)
        table.cell(sb, 1, 10 + k, vt == 0 ? "-" : str.tostring(vt), text_color = vt == 0 ? dim : cc, bgcolor = rbg, text_size = ts)
        table.cell(sb, 2, 10 + k, totN == 0 ? "▱▱▱▱▱" : meter + " " + str.tostring(pct, "#") + "%", text_color = totN == 0 ? dim : cc, bgcolor = sub, text_size = ts, text_halign = text.align_left)

    // spacer so the TradingView footer never covers the last row
    for col = 0 to 2
        table.cell(sb, col, 14, " ", bgcolor = color.new(color.black, 100), text_size = ts)
````

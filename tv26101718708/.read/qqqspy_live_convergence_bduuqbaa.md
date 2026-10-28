# QQQ/SPY Live Convergence

- url: https://www.tradingview.com/script/bduUqbaA-QQQ-SPY-Live-Convergence/
- type: indicator
- pine_id: PUB;0bac8ac636894c33936cfbb943b4dbe7
- version: 4.0

## Description

QQQ/SPY live convergence

Projects QQQ price levels onto NQ/MNQ and SPY levels onto ES/MES. Only the relevant set is shown: QQQ on Nasdaq futures, SPY on S&P futures.

• Futures/ETF ratio calibrated on synchronized 1-minute data, so levels line up the same on any chart timeframe
• Smoothed ratio with outlier filtering; re-anchors automatically after ex-dividend gaps or contract rolls
• Uses the front contract the chart is showing, so rolls are handled automatically
• Ratio held overnight and on weekends, adjusted for interest-rate carry
• Every $5 level (e.g. 750 / 755 / 760) drawn solid and bold, the rest dashed
• Optional info table with the live ratio, sync status and calibration error


F3L1X the DEV [symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] [symbol="AMEX:SPY"]AMEX:SPY[/symbol]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Inspired by "QQQ NDX NQ Price Converter [Pt]" and "SPY SPX ES Price Converter [Pt]" by PtGambler.
//@version=6
indicator("QQQ/SPY + NDX/SPX Convergence For NQ/ES +CFD", shorttitle = "QQQ/SPY + NDX/SPX", overlay = true, behind_chart = false, max_lines_count = 500, max_labels_count = 500)
// Current price grid, NOT measured options positioning or a historical level archive.
// Basis model (backtested on 60 sessions of 5m NQ/NDX/QQQ and ES/SPX/SPY data):
//   anchor       median chart/source over the last completed cash session, taken
//                at 18:00 New York, then rolled forward as fair value: ln(F/S) scales
//                with carry days between stock settlement (T+1, weekends and US
//                settlement holidays) and futures expiry.
//   optional     live median of today's samples during cash hours.
// Only completed bars are sampled and they are paired by bar time, so real-time,
// 10-minute and 15-minute delayed feeds all produce the same samples.
// Continuous charts sample the current dated contract, so a rollover never mixes contracts.
// Worst case: 2 * 121 levels + 2 * 121 connectors = 484 lines; 242 labels.
// Future coordinates: offset <= 250 + column spacing <= 250 = 500 bars.
string TZ = "America/New_York"
string AUTO = "Live + fair value"
string ANCHOR = "Prior-day fair value (static)"
int DAY_MS = 86400000
// A first-samples median this far from fair value is a structural jump
// (ETF ex-dividend, contract change), not noise: re-anchor on it.
float JUMP = 0.0005
int JUMP_N = 3
int MIN_ANCHOR = 3
int FEED_KEEP = 48
int FEED_SCAN = 12
string grpDisplay = "Display"
string grpNasdaq = "Nasdaq levels"
string grpSP = "S&P levels"
string grpLabels = "Labels"
string grpCal = "Advanced — Calibration"
string grpInf = "Diagnostics"
nLevels = input.int(10, "Levels above / below", minval = 1, maxval = 60, group = grpDisplay, tooltip = "Per source, plus one center level. Maximum 60: 242 levels + 242 possible connectors = 484 lines, 242 labels. Current grid only, not a historical archive.", display = display.none)
majorWidth = input.int(2, "Width: major", minval = 1, maxval = 5, inline = "width", group = grpDisplay, display = display.none)
minorWidth = input.int(1, "Minor", minval = 1, maxval = 5, inline = "width", group = grpDisplay, display = display.none)
showQQQ = input.bool(true, "QQQ", inline = "qqq", group = grpNasdaq, display = display.none)
colorQQQ = input.color(#D8D8D8, "", inline = "qqq", group = grpNasdaq, active = showQQQ, display = display.none)
visibilityQQQ = input.int(50, "Visibility (%)", minval = 0, maxval = 100, inline = "qqq", group = grpNasdaq, active = showQQQ, tooltip = "Line visibility: 100 = opaque, 0 = invisible. Color picker opacity is ignored; this is the only line opacity control. Text uses the same hue at full opacity.", display = display.none)
stepQQQ = input.float(1.0, "Level spacing ($)", minval = 0.01, inline = "qqqstep", group = grpNasdaq, active = showQQQ, display = display.none)
majorQQQ = input.float(5.0, "Major ($)", minval = 0.01, inline = "qqqstep", group = grpNasdaq, active = showQQQ, display = display.none)
showNDX = input.bool(true, "NDX", inline = "ndx", group = grpNasdaq, display = display.none)
colorNDX = input.color(#4DD0E1, "", inline = "ndx", group = grpNasdaq, active = showNDX, display = display.none)
visibilityNDX = input.int(40, "Visibility (%)", minval = 0, maxval = 100, inline = "ndx", group = grpNasdaq, active = showNDX, tooltip = "Line visibility only; text remains opaque. Picker opacity is ignored.", display = display.none)
stepNDX = input.float(50.0, "Level spacing (index points)", minval = 0.01, inline = "ndxstep", group = grpNasdaq, active = showNDX, display = display.none)
majorNDX = input.float(100.0, "Major", minval = 0.01, inline = "ndxstep", group = grpNasdaq, active = showNDX, tooltip = "Major interval in original NDX index points. Choose a multiple of level spacing for regular major lines.", display = display.none)
showSPY = input.bool(true, "SPY", inline = "spy", group = grpSP, display = display.none)
colorSPY = input.color(#D8D8D8, "", inline = "spy", group = grpSP, active = showSPY, display = display.none)
visibilitySPY = input.int(50, "Visibility (%)", minval = 0, maxval = 100, inline = "spy", group = grpSP, active = showSPY, tooltip = "Line visibility only; text remains opaque. Picker opacity is ignored.", display = display.none)
stepSPY = input.float(1.0, "Level spacing ($)", minval = 0.01, inline = "spystep", group = grpSP, active = showSPY, display = display.none)
majorSPY = input.float(5.0, "Major ($)", minval = 0.01, inline = "spystep", group = grpSP, active = showSPY, display = display.none)
showSPX = input.bool(true, "SPX", inline = "spx", group = grpSP, display = display.none)
colorSPX = input.color(#F7525F, "", inline = "spx", group = grpSP, active = showSPX, display = display.none)
visibilitySPX = input.int(40, "Visibility (%)", minval = 0, maxval = 100, inline = "spx", group = grpSP, active = showSPX, tooltip = "Line visibility only; text remains opaque. Picker opacity is ignored.", display = display.none)
stepSPX = input.float(10.0, "Level spacing (index points)", minval = 0.01, inline = "spxstep", group = grpSP, active = showSPX, display = display.none)
majorSPX = input.float(50.0, "Major", minval = 0.01, inline = "spxstep", group = grpSP, active = showSPX, tooltip = "Major interval in original SPX index points. Choose a multiple of level spacing for regular major lines.", display = display.none)
labelMode = input.string("All", "Pane labels", options = ["All", "Major only", "None"], inline = "labels", group = grpLabels, display = display.none)
textSizeIn = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], inline = "labels", group = grpLabels, active = labelMode != "None", display = display.none)
labelOffset = input.int(20, "Label offset (bars)", minval = 1, maxval = 250, group = grpLabels, active = labelMode != "None", display = display.none)
columnSpacing = input.int(30, "Column spacing (bars)", minval = 1, maxval = 250, group = grpLabels, active = labelMode != "None", tooltip = "ETF column first; index column to its right. Fixed bar distance: increase it when zoomed out. Offset + spacing never exceeds 500 bars. Leave enough right margin to see both columns.", display = display.none)
labelGapTicks = input.int(8, "Minimum label gap (chart ticks)", minval = 0, maxval = 100000, group = grpLabels, active = labelMode != "None", tooltip = "Deterministic vertical spacing inside each column. 0 keeps labels at levels. Increase when zoomed out; displaced labels have a subtle connector. Price lines never move. Pine cannot measure screen pixels or text widths.", display = display.none)
showMapped = input.bool(false, "Show mapped chart price", group = grpLabels, active = labelMode != "None", display = display.none)
basisMode = input.string(ANCHOR, "Basis", options = [ANCHOR, AUTO], group = grpCal, tooltip = "Prior-day fair value: median of the last completed cash session (09:45–15:55 New York), adopted at 18:00 New York when the new futures day starts, rolled forward to the new day's carry days at 20:00, then held. Levels never move intraday. Needs no live data. An ETF ex-dividend or contract change is corrected after the first three samples of the day.\n\nLive + fair value: same anchor outside cash hours; during cash hours (and ETF pre-market) the median of today's latest samples. Slightly more accurate; levels may shift by a few points intraday.", display = display.none)
smoothN = input.int(6, "Median samples", minval = 1, maxval = 48, group = grpCal, tooltip = "Live mode only: number of latest samples in the median. Until that many exist today, the rolled fair value counts as one extra sample.", display = display.none)
familyIn = input.string("Auto", "Chart family", options = ["Auto", "Nasdaq", "S&P"], group = grpCal, tooltip = "Auto recognises NQ/MNQ, ES/MES, QQQ, SPY, NDX, SPX and common CFD tickers (NAS100, US100, USTEC, US500, SPX500). Force a family for any other Nasdaq-100 or S&P 500 instrument.", display = display.none)
manualQQQ = input.bool(false, "Manual QQQ ratio", inline = "mqqq", group = grpCal, display = display.none)
ratioQQQ = input.float(1.0, "Chart / QQQ", inline = "mqqq", group = grpCal, active = manualQQQ, tooltip = "Finite and strictly positive. QQQ × ratio = chart price. Futures/CFD charts only; ignored on QQQ and NDX charts.", display = display.none)
manualNDX = input.bool(false, "Manual NDX spread", inline = "mndx", group = grpCal, display = display.none)
spreadNDX = input.float(0.0, "Chart − NDX", inline = "mndx", group = grpCal, active = manualNDX, tooltip = "Finite signed points; zero and negative are valid. NDX + spread = chart price. Futures/CFD charts only.", display = display.none)
manualSPY = input.bool(false, "Manual SPY ratio", inline = "mspy", group = grpCal, display = display.none)
ratioSPY = input.float(1.0, "Chart / SPY", inline = "mspy", group = grpCal, active = manualSPY, tooltip = "Finite and strictly positive. SPY × ratio = chart price. Futures/CFD charts only.", display = display.none)
manualSPX = input.bool(false, "Manual SPX spread", inline = "mspx", group = grpCal, display = display.none)
spreadSPX = input.float(0.0, "Chart − SPX", inline = "mspx", group = grpCal, active = manualSPX, tooltip = "Finite signed points; zero and negative are valid. SPX + spread = chart price. Futures/CFD charts only.", display = display.none)
showInfo = input.bool(false, "Show diagnostics", group = grpInf, display = display.none)
infoPosIn = input.string("Bottom right", "Position", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = grpInf, active = showInfo, display = display.none)
// Chart identity. Native sources are identity maps; everything else is measured.
bool onFuture = syminfo.type == "futures"
bool rootNQ = syminfo.type == "futures" and (syminfo.root == "NQ" or syminfo.root == "MNQ")
bool rootES = syminfo.type == "futures" and (syminfo.root == "ES" or syminfo.root == "MES")
bool usETF = syminfo.type == "fund" or syminfo.type == "stock"
bool onQQQ = usETF and syminfo.ticker == "QQQ"
bool onSPY = usETF and syminfo.ticker == "SPY"
bool onNDX = syminfo.type == "index" and syminfo.ticker == "NDX" and str.startswith(syminfo.prefix, "NASDAQ")
bool onSPX = syminfo.type == "index" and syminfo.ticker == "SPX" and (syminfo.prefix == "SP" or str.startswith(syminfo.prefix, "SP_"))
string tickerUpper = str.upper(syminfo.ticker)
bool nasOther = str.contains(tickerUpper, "NAS100") or str.contains(tickerUpper, "US100") or str.contains(tickerUpper, "USTEC") or str.contains(tickerUpper, "NDX")
bool spOther = str.contains(tickerUpper, "SPX") or str.contains(tickerUpper, "US500") or str.contains(tickerUpper, "SP500")
bool autoNasdaq = rootNQ or onQQQ or onNDX or nasOther
bool autoSP = not autoNasdaq and (rootES or onSPY or onSPX or spOther)
bool nasdaqFamily = familyIn == "Nasdaq" or familyIn == "Auto" and autoNasdaq
bool familyOK = familyIn != "Auto" or autoNasdaq or autoSP
bool onETF = nasdaqFamily ? onQQQ : onSPY
bool onIndex = nasdaqFamily ? onNDX : onSPX
bool onNative = onETF or onIndex
bool contextOK = chart.is_standard and timeframe.isintraday and timeframe.in_seconds() >= 60 and timeframe.in_seconds() <= 3600
string etfName = nasdaqFamily ? "QQQ" : "SPY"
string indexName = nasdaqFamily ? "NDX" : "SPX"
// Extended ETF session: pre-market samples keep the ETF grid right before the cash
// open and pick up an ex-dividend the moment it trades. Cash index has no pre-market.
string etfId = nasdaqFamily ? ticker.new("NASDAQ", "QQQ", session.extended, adjustment.none) : ticker.new("AMEX", "SPY", session.extended, adjustment.none)
string indexId = nasdaqFamily ? ticker.new("NASDAQ", "NDX", session.regular, adjustment.none) : ticker.new("SP", "SPX", session.regular, adjustment.none)
// Futures leg. A continuous chart is sampled through its current dated contract:
// identical price now, and one contract through the whole history.
bool chartContinuous = onFuture and str.contains(syminfo.ticker, "!")
string currentContract = syminfo.current_contract
bool contractKnown = chartContinuous and not na(currentContract) and str.length(currentContract) > 0
string contractCode = contractKnown ? currentContract : syminfo.ticker
string legId = contractKnown ? (str.contains(currentContract, ":") ? currentContract : syminfo.prefix + ":" + currentContract) : syminfo.tickerid
f_finite(float v) =>
    not na(v) and not na(v - v) and v - v == 0
// Canonical affine map y=a*source+b, inverse used for each grid's centering.
f_forward(float raw, float a, float b) =>
    raw * a + b
f_inverse(float y, float a, float b) =>
    (y - b) / a
f_ymd(int t) =>
    year(t, TZ) * 10000 + month(t, TZ) * 100 + dayofmonth(t, TZ)
f_noon(int t) =>
    timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 12, 0)
f_mins(int t) =>
    hour(t, TZ) * 60 + minute(t, TZ)
f_weekend(int t) =>
    int d = dayofweek(t, TZ)
    d == dayofweek.saturday or d == dayofweek.sunday
// US calendars 2026–2028. After 2028 only weekends are skipped: extend these lists.
// Market holidays: no cash trading. Bank holidays: trading, but no stock settlement.
var array<int> MARKET_HOLIDAYS = array.from(20260101, 20260119, 20260216, 20260403, 20260525, 20260619, 20260703, 20260907, 20261126, 20261225, 20270101, 20270118, 20270215, 20270326, 20270531, 20270618, 20270705, 20270906, 20271125, 20271224, 20280117, 20280221, 20280414, 20280529, 20280619, 20280704, 20280904, 20281123, 20281225)
var array<int> BANK_HOLIDAYS = array.from(20261012, 20261111, 20271011, 20271111, 20281009)
// Business date (as NY noon) that a moment belongs to when the day turns
// `hoursBeforeMidnight` early. 6 → futures day (turns 18:00), used for the anchor.
// 4 → cash trade date (turns 20:00, when the ETF post-market ends), used for carry:
// measured, counting the next day's carry from 18:00 doubles the evening error.
f_businessDate(int t, int hoursBeforeMidnight) =>
    int d = f_noon(t + hoursBeforeMidnight * 3600000)
    while f_weekend(d) or MARKET_HOLIDAYS.includes(f_ymd(d))
        d := f_noon(d + DAY_MS)
    d
// T+1 stock settlement date of a trade date (as NY noon).
f_settle(int d) =>
    int s = f_noon(d + DAY_MS)
    while f_weekend(s) or MARKET_HOLIDAYS.includes(f_ymd(s)) or BANK_HOLIDAYS.includes(f_ymd(s))
        s := f_noon(s + DAY_MS)
    s
// Financing days carried by the futures basis. Settlement to settlement: this is
// why a weekend's carry leaves the basis on Friday, not on Monday.
f_carryDays(int tradeNoon, int expiryNoon) =>
    int(math.round((f_settle(expiryNoon) - f_settle(tradeNoon)) / float(DAY_MS)))
f_thirdFriday(int y, int m) =>
    int first = timestamp(TZ, y, m, 1, 12, 0)
    int offset = (dayofweek.friday - dayofweek(first, TZ) + 7) % 7
    timestamp(TZ, y, m, 15 + offset, 12, 0)
f_monthCode(string c) =>
    switch c
        "F" => 1
        "G" => 2
        "H" => 3
        "J" => 4
        "K" => 5
        "M" => 6
        "N" => 7
        "Q" => 8
        "U" => 9
        "V" => 10
        "X" => 11
        "Z" => 12
        => 0
// Equity index futures expire on the third Friday of the delivery month.
// "NQZ2026" → month code Z, year 2026.
f_expiry(string contract) =>
    int result = na
    int n = str.length(contract)
    if not na(contract) and n >= 6
        int m = f_monthCode(str.substring(contract, n - 5, n - 4))
        float y = str.tonumber(str.substring(contract, n - 4, n))
        if m > 0 and not na(y) and y > 2000
            result := f_thirdFriday(int(y), m)
    result
int parsedExpiry = onFuture ? f_expiry(contractCode) : na
int expiryNoon = not na(parsedExpiry) ? parsedExpiry : onFuture and not na(syminfo.expiration_date) ? f_noon(syminfo.expiration_date + 12 * 3600000) : na
bool hasCarry = not na(expiryNoon)
int tradeNoon = f_businessDate(time, 4)
int sessionNoon = f_businessDate(time, 6)
int tauNow = hasCarry ? f_carryDays(tradeNoon, expiryNoon) : na
bool newSession = not na(sessionNoon[1]) and sessionNoon != sessionNoon[1]
// Sample bars are at least as long as chart bars (so none is skipped between two
// script updates) and 5/10/15/30 minutes (so futures and cash bars share open times).
int chartMinutes = int(timeframe.in_seconds() / 60)
int sampleMinutes = chartMinutes <= 5 ? 5 : chartMinutes <= 10 ? 10 : chartMinutes <= 15 ? 15 : 30
string SAMPLE_TF = str.tostring(sampleMinutes)
// The two latest COMPLETED bars of each feed. Completed bars are final whatever
// the feed's delay; two per update cover 45m and 60m charts.
[datedC1, datedT1, datedC2, datedT2] = request.security(legId, SAMPLE_TF, [close[1], time[1], close[2], time[2]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[ownC1, ownT1, ownC2, ownT2] = request.security(syminfo.tickerid, SAMPLE_TF, [close[1], time[1], close[2], time[2]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[etfC1, etfT1, etfC2, etfT2] = request.security(etfId, SAMPLE_TF, [close[1], time[1], close[2], time[2]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[indexC1, indexT1, indexC2, indexT2] = request.security(indexId, SAMPLE_TF, [close[1], time[1], close[2], time[2]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool datedOK = contractKnown and not na(datedT1)
// Completed bars of one feed, keyed by bar-open time.
type Feed
    array<int> times
    array<float> closes
method put(Feed f, int t, float c) =>
    if not na(t) and f_finite(c) and c > 0 and (f.times.size() == 0 or t > f.times.last())
        f.times.push(t)
        f.closes.push(c)
        if f.times.size() > FEED_KEEP
            f.times.shift()
            f.closes.shift()
method at(Feed f, int t) =>
    int i = f.times.lastindexof(t)
    i >= 0 ? f.closes.get(i) : na
type Basis
    array<float> recent
    array<float> cash
    int lastT = na
    int cashT = na
    float live = na
    float anchor = na
    int anchorTau = na
    int anchorT = na
    bool reanchored = false
// New futures day: the finished cash session's median becomes the anchor.
method newDay(Basis b, int expiry) =>
    if b.cash.size() >= MIN_ANCHOR
        b.anchor := b.cash.median()
        b.anchorT := b.cashT
        b.anchorTau := na(expiry) ? na : f_carryDays(f_businessDate(b.cashT, 4), expiry)
    b.cash.clear()
    b.recent.clear()
    b.live := na
    b.reanchored := false
method sample(Basis b, float ratio, int t, bool inCash, float fairValue, int tau) =>
    b.lastT := t
    b.recent.push(ratio)
    if inCash
        b.cash.push(ratio)
        b.cashT := t
    int n = b.recent.size()
    array<float> window = b.recent.slice(math.max(0, n - smoothN), n).copy()
    if n < smoothN and not na(fairValue)
        window.push(fairValue)
    b.live := window.median()
    if n == JUMP_N and not na(fairValue) and math.abs(b.recent.median() / fairValue - 1) > JUMP
        b.anchor := b.recent.median()
        b.anchorTau := tau
        b.anchorT := t
        b.reanchored := true
// Fair value of chart/index today: the anchor's log-basis scaled by carry days.
f_fairIndex(Basis b, int tau) =>
    float r = b.anchor
    if not na(r) and not na(tau) and not na(b.anchorTau) and b.anchorTau > 0 and tau >= 0
        r := math.exp(math.log(b.anchor) * tau / b.anchorTau)
    r
// Chart/ETF carries the same financing: move it by the index's daily carry.
f_fairETF(Basis e, Basis i, int tau) =>
    float r = e.anchor
    if not na(r) and not na(tau) and not na(e.anchorTau) and not na(i.anchor) and not na(i.anchorTau) and i.anchorTau > 0 and tau >= 0
        r := e.anchor * math.exp(math.log(i.anchor) / i.anchorTau * (tau - e.anchorTau))
    r
// Pair every not-yet-sampled bar the two feeds have in common. Cash 09:45–15:55 NY
// skips the opening bars (index still printing stale component prices) and the bar
// whose close carries the closing cross. Pre-market applies to the ETF only.
method pair(Basis b, Feed leg, Feed src, bool withPre, int session, float fairValue, int tau) =>
    int n = leg.times.size()
    if n > 0 and src.times.size() > 0
        for i = math.max(0, n - FEED_SCAN) to n - 1
            int t = leg.times.get(i)
            if na(b.lastT) or t > b.lastT
                int m = f_mins(t)
                bool inCash = m >= 585 and m + sampleMinutes <= 955
                bool inPre = withPre and m >= 240 and m + sampleMinutes <= 570
                if (inCash or inPre) and f_ymd(t) == f_ymd(session)
                    float s = src.at(t)
                    if not na(s)
                        b.sample(leg.closes.get(i) / s, t, inCash, fairValue, tau)
var Feed legFeed = Feed.new(array.new<int>(), array.new<float>())
var Feed etfFeed = Feed.new(array.new<int>(), array.new<float>())
var Feed indexFeed = Feed.new(array.new<int>(), array.new<float>())
var Basis indexBasis = Basis.new(array.new<float>(), array.new<float>())
var Basis etfBasis = Basis.new(array.new<float>(), array.new<float>())
legFeed.put(datedOK ? datedT2 : ownT2, datedOK ? datedC2 : ownC2)
legFeed.put(datedOK ? datedT1 : ownT1, datedOK ? datedC1 : ownC1)
etfFeed.put(etfT2, etfC2)
etfFeed.put(etfT1, etfC1)
indexFeed.put(indexT2, indexC2)
indexFeed.put(indexT1, indexC1)
if newSession
    indexBasis.newDay(expiryNoon)
    etfBasis.newDay(expiryNoon)
if not onIndex
    indexBasis.pair(legFeed, indexFeed, false, sessionNoon, f_fairIndex(indexBasis, tauNow), tauNow)
if not onETF
    etfBasis.pair(legFeed, etfFeed, true, sessionNoon, f_fairETF(etfBasis, indexBasis, tauNow), tauNow)
float fairIndex = f_fairIndex(indexBasis, tauNow)
float fairETF = f_fairETF(etfBasis, indexBasis, tauNow)
float autoIndex = basisMode == AUTO ? nz(indexBasis.live, fairIndex) : nz(fairIndex, indexBasis.live)
float autoETF = basisMode == AUTO ? nz(etfBasis.live, fairETF) : nz(fairETF, etfBasis.live)
bool manualETF = not onNative and (nasdaqFamily ? manualQQQ : manualSPY)
bool manualIndex = not onNative and (nasdaqFamily ? manualNDX : manualSPX)
float etfA = onETF ? 1.0 : manualETF ? (nasdaqFamily ? ratioQQQ : ratioSPY) : autoETF
float etfB = 0.0
float indexA = onIndex or manualIndex ? 1.0 : autoIndex
float indexB = manualIndex ? (nasdaqFamily ? spreadNDX : spreadSPX) : 0.0
bool etfOK = contextOK and familyOK and f_finite(etfA) and etfA > 0
bool indexOK = contextOK and familyOK and f_finite(indexA) and indexA > 0 and f_finite(indexB)
bool etfLive = basisMode == AUTO and not na(etfBasis.live)
bool indexLive = basisMode == AUTO and not na(indexBasis.live)
// Longest normal gap is Friday 15:50 → Monday 09:45; one extra day covers a holiday.
int STALE_MS = 4 * DAY_MS
int etfSeen = math.max(nz(etfBasis.lastT), nz(etfBasis.anchorT))
int indexSeen = math.max(nz(indexBasis.lastT), nz(indexBasis.anchorT))
bool etfStale = not onETF and not manualETF and etfSeen > 0 and time - etfSeen > STALE_MS
bool indexStale = not onIndex and not manualIndex and indexSeen > 0 and time - indexSeen > STALE_MS
f_status(bool native, bool manual, bool valid, bool stale, bool live, bool reanchored) =>
    not contextOK ? "UNSUPPORTED: standard 1–60m" : not familyOK ? "UNSUPPORTED: chart family" : native ? "NATIVE · identity" : manual ? (valid ? "MANUAL · fixed" : "MANUAL ERROR · invalid ratio/spread") : not valid ? "NO DATA · no synchronized cash-hours sample" : stale ? "STALE · last sample too old" : live ? "LIVE · median of today's samples" : reanchored ? "RE-ANCHORED TODAY · basis jump (ex-dividend / contract)" : hasCarry ? "PRIOR-DAY FAIR VALUE · held" : "PRIOR SESSION · no expiry, no carry roll"
textSize = switch textSizeIn
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    => size.small
// One reusable object pool per source; clearing never touches the other source.
type Grid
    array<line> levels
    array<label> labels
    array<line> links
f_clear(Grid g) =>
    while g.levels.size() > 0
        line.delete(g.levels.pop())
    while g.labels.size() > 0
        label.delete(g.labels.pop())
    while g.links.size() > 0
        line.delete(g.links.pop())
f_isMajor(float raw, float interval) =>
    float k = raw / interval
    math.abs(k - math.round(k)) < 1e-6
f_render(Grid g, bool enabled, bool valid, string name, float a, float b, float stepSize, float majorEvery, color hue, int visibility, int column) =>
    if not enabled or not valid or not f_finite(a) or a <= 0 or not f_finite(b)
        f_clear(g)
    else
        int count = 2 * nLevels + 1
        if g.levels.size() != count
            f_clear(g)
            for i = 0 to count - 1
                g.levels.push(line.new(bar_index, close, bar_index + 1, close, extend = extend.both))
                // Transparent left-anchored label: text starts at labelX and is
                // centered vertically on the level, never over the latest candles.
                g.labels.push(label.new(bar_index, close, "", style = label.style_label_left))
                g.links.push(line.new(bar_index, close, bar_index, close, color = na))
        float center = math.round(f_inverse(close, a, b) / stepSize) * stepSize
        int labelX = bar_index + math.min(500, math.max(1, labelOffset) + column * columnSpacing)
        array<int> wanted = array.new<int>()
        array<float> positions = array.new<float>()
        for i = 0 to count - 1
            float raw = center + (i - nLevels) * stepSize
            float y = f_forward(raw, a, b)
            bool major = f_isMajor(raw, majorEvery)
            line ln = g.levels.get(i)
            ln.set_xy1(bar_index, y)
            ln.set_xy2(bar_index + 1, y)
            ln.set_color(color.new(hue, 100 - visibility))
            ln.set_style(major ? line.style_solid : line.style_dashed)
            ln.set_width(major ? majorWidth : minorWidth)
            label lb = g.labels.get(i)
            lb.set_text("")
            lb.set_color(color.new(chart.bg_color, 100))
            lb.set_xy(labelX, y)
            g.links.get(i).set_color(na)
            if labelMode == "All" or labelMode == "Major only" and major
                wanted.push(i)
                positions.push(y)
        // Centered deterministic packing. No pixel/zoom API or live ATR term.
        int sizeWanted = wanted.size()
        float gap = labelGapTicks * syminfo.mintick
        if sizeWanted > 0
            int pivot = int(math.floor((sizeWanted - 1) / 2))
            if pivot < sizeWanted - 1
                for j = pivot + 1 to sizeWanted - 1
                    positions.set(j, math.max(positions.get(j), positions.get(j - 1) + gap))
            if pivot > 0
                for j = pivot - 1 to 0
                    positions.set(j, math.min(positions.get(j), positions.get(j + 1) - gap))
            for j = 0 to sizeWanted - 1
                int i = wanted.get(j)
                float raw = center + (i - nLevels) * stepSize
                float y = f_forward(raw, a, b)
                float labelY = positions.get(j)
                bool major = f_isMajor(raw, majorEvery)
                label lb = g.labels.get(i)
                lb.set_xy(labelX, labelY)
                lb.set_text(name + " " + str.tostring(raw, "#.########") + (showMapped ? "  (" + str.tostring(y, format.mintick) + ")" : ""))
                lb.set_color(color.new(chart.bg_color, 100))
                lb.set_textcolor(color.new(hue, 0))
                lb.set_size(textSize)
                lb.set_text_formatting(major ? text.format_bold : text.format_none)
                lb.set_textalign(text.align_left)
                lb.set_tooltip("Source: " + name + " " + str.tostring(raw, "#.########") + "\nExact chart level: " + str.tostring(y, "#.########") + (labelY != y ? "\nText displaced for spacing; connector ends at the exact level." : ""))
                line link = g.links.get(i)
                link.set_xy1(math.max(bar_index + 1, labelX - 3), y)
                link.set_xy2(labelX, labelY)
                link.set_color(labelY != y ? color.new(hue, 65) : na)
                link.set_style(line.style_solid)
                link.set_width(1)
var Grid etfGrid = Grid.new(array.new<line>(), array.new<label>(), array.new<line>())
var Grid indexGrid = Grid.new(array.new<line>(), array.new<label>(), array.new<line>())
bool showETF = nasdaqFamily ? showQQQ : showSPY
bool showIndex = nasdaqFamily ? showNDX : showSPX
if barstate.islast
    f_render(etfGrid, showETF, etfOK, etfName, etfA, etfB, nasdaqFamily ? stepQQQ : stepSPY, nasdaqFamily ? majorQQQ : majorSPY, nasdaqFamily ? colorQQQ : colorSPY, nasdaqFamily ? visibilityQQQ : visibilitySPY, 0)
    f_render(indexGrid, showIndex, indexOK, indexName, indexA, indexB, nasdaqFamily ? stepNDX : stepSPX, nasdaqFamily ? majorNDX : majorSPX, nasdaqFamily ? colorNDX : colorSPX, nasdaqFamily ? visibilityNDX : visibilitySPX, 1)
f_fmtTime(int t) =>
    na(t) ? "—" : str.format_time(t, "yyyy-MM-dd HH:mm", TZ)
f_px(float v) =>
    na(v) ? "—" : str.tostring(v, "#.########")
infoPos = switch infoPosIn
    "Top left" => position.top_left
    "Top right" => position.top_right
    "Bottom left" => position.bottom_left
    => position.bottom_right
f_date(int t) =>
    na(t) ? "—" : str.format_time(t, "yyyy-MM-dd", TZ)
f_days(int a, int b) =>
    na(a) or na(b) ? "—" : str.tostring(a) + " → " + str.tostring(b)
// No table object exists while diagnostics are disabled (including borders).
var table info = na
f_cell(table t, int col, int row, string value, color hue) =>
    table.cell(t, col, row, value, text_color = hue, bgcolor = chart.bg_color, text_size = size.small, text_halign = text.align_left)
if barstate.islast
    if not showInfo
        if not na(info)
            table.delete(info)
            info := na
    else
        if na(info)
            info := table.new(infoPos, 3, 11, bgcolor = chart.bg_color, border_width = 1)
        // Net carry implied by the anchor: financing minus dividends, per year.
        float carryPct = hasCarry and not na(indexBasis.anchor) and not na(indexBasis.anchorTau) and indexBasis.anchorTau > 0 ? math.log(indexBasis.anchor) / indexBasis.anchorTau * 36500 : na
        f_cell(info, 0, 0, "Source → " + syminfo.ticker, chart.fg_color)
        f_cell(info, 1, 0, etfName + (showETF ? " · shown" : " · hidden"), chart.fg_color)
        f_cell(info, 2, 0, indexName + (showIndex ? " · shown" : " · hidden"), chart.fg_color)
        f_cell(info, 0, 1, "Conversion status", chart.fg_color)
        f_cell(info, 1, 1, f_status(onETF, manualETF, etfOK, etfStale, etfLive, etfBasis.reanchored), etfOK and not etfStale ? chart.fg_color : color.orange)
        f_cell(info, 2, 1, f_status(onIndex, manualIndex, indexOK, indexStale, indexLive, indexBasis.reanchored), indexOK and not indexStale ? chart.fg_color : color.orange)
        f_cell(info, 0, 2, "Chart / source in use", chart.fg_color)
        f_cell(info, 1, 2, f_px(etfA), chart.fg_color)
        f_cell(info, 2, 2, manualIndex ? "Manual spread " + f_px(indexB) : f_px(indexA), chart.fg_color)
        f_cell(info, 0, 3, "Fair value today · live median", chart.fg_color)
        f_cell(info, 1, 3, onETF ? "—" : f_px(fairETF) + " · " + f_px(etfBasis.live), chart.fg_color)
        f_cell(info, 2, 3, onIndex ? "—" : f_px(fairIndex) + " · " + f_px(indexBasis.live), chart.fg_color)
        f_cell(info, 0, 4, "Chart − source at last price", chart.fg_color)
        f_cell(info, 1, 4, "—", chart.fg_color)
        f_cell(info, 2, 4, indexOK ? f_px(math.round(close - f_inverse(close, indexA, indexB), 2)) : "—", chart.fg_color)
        f_cell(info, 0, 5, "Anchor session · NY", chart.fg_color)
        f_cell(info, 1, 5, onETF ? "Native" : f_date(etfBasis.anchorT), chart.fg_color)
        f_cell(info, 2, 5, onIndex ? "Native" : f_date(indexBasis.anchorT), chart.fg_color)
        f_cell(info, 0, 6, "Carry days · anchor → today", chart.fg_color)
        f_cell(info, 1, 6, hasCarry ? f_days(etfBasis.anchorTau, tauNow) : "—", chart.fg_color)
        f_cell(info, 2, 6, hasCarry ? f_days(indexBasis.anchorTau, tauNow) : "—", chart.fg_color)
        f_cell(info, 0, 7, "Implied net carry · expiry", chart.fg_color)
        f_cell(info, 1, 7, na(carryPct) ? "—" : str.tostring(carryPct, "#.##") + " % p.a.", chart.fg_color)
        f_cell(info, 2, 7, hasCarry ? f_date(expiryNoon) : "No expiry · carry roll off", chart.fg_color)
        f_cell(info, 0, 8, "Last sample · NY · today's count", chart.fg_color)
        f_cell(info, 1, 8, onETF ? "Native" : f_fmtTime(etfBasis.lastT) + " · " + str.tostring(etfBasis.recent.size()), chart.fg_color)
        f_cell(info, 2, 8, onIndex ? "Native" : f_fmtTime(indexBasis.lastT) + " · " + str.tostring(indexBasis.recent.size()), chart.fg_color)
        f_cell(info, 0, 9, "Basis", chart.fg_color)
        f_cell(info, 1, 9, basisMode, chart.fg_color)
        f_cell(info, 2, 9, SAMPLE_TF + "m completed bars · cash 09:45–15:55 NY", chart.fg_color)
        f_cell(info, 0, 10, "Sampled price", chart.fg_color)
        f_cell(info, 1, 10, datedOK ? legId : syminfo.tickerid, chart.fg_color)
        f_cell(info, 2, 10, chartContinuous and not datedOK ? "Dated contract unavailable · B-ADJ must be OFF · rollover unprotected" : datedOK ? "Current dated contract · unaffected by B-ADJ" : "Chart's own price", chartContinuous and not datedOK ? color.orange : chart.fg_color)
// Audit values only: no chart or price-scale plots.
plot(etfOK ? etfA : na, "ETF map slope", display = display.data_window, precision = 10)
plot(indexOK ? indexA : na, "Index map slope", display = display.data_window, precision = 10)
plot(indexOK ? indexB : na, "Index map intercept", display = display.data_window, precision = 8)
plot(fairETF, "ETF fair value ratio", display = display.data_window, precision = 10)
plot(fairIndex, "Index fair value ratio", display = display.data_window, precision = 10)
plot(etfBasis.live, "ETF live ratio", display = display.data_window, precision = 10)
plot(indexBasis.live, "Index live ratio", display = display.data_window, precision = 10)
plot(etfBasis.anchor, "ETF anchor ratio", display = display.data_window, precision = 10)
plot(indexBasis.anchor, "Index anchor ratio", display = display.data_window, precision = 10)
plot(tauNow, "Carry days today", display = display.data_window, precision = 0)
plot(indexBasis.anchorTau, "Carry days at anchor", display = display.data_window, precision = 0)
plot(etfOK ? 1 : 0, "ETF mapping valid (1/0)", display = display.data_window, precision = 0)
plot(indexOK ? 1 : 0, "Index mapping valid (1/0)", display = display.data_window, precision = 0)
plot(nasdaqFamily ? 1 : familyOK ? 2 : 0, "Chart family Nasdaq=1 SP=2", display = display.data_window)
// A missing or stale basis is visible even with detailed diagnostics off.
var table health = na
if barstate.islast
    bool missing = showETF and not etfOK or showIndex and not indexOK
    bool stale = showETF and etfStale or showIndex and indexStale
    bool jumped = showETF and etfBasis.reanchored or showIndex and indexBasis.reanchored
    if not showInfo and (not contextOK or not familyOK or missing or stale or jumped)
        if na(health)
            health := table.new(position.bottom_left, 1, 1)
        string message = not contextOK ? "Levels: standard candles, 1–60m required" : not familyOK ? "Levels: unknown instrument · set Chart family in settings" : missing ? "Levels: no synchronized " + etfName + "/" + indexName + " cash-hours sample in loaded history" : stale ? "Levels: basis is stale · last sample " + f_fmtTime(math.max(etfSeen, indexSeen)) : "Levels: basis jumped today (ex-dividend / contract) · re-anchored on today's samples"
        table.cell(health, 0, 0, message, text_color = color.orange, bgcolor = chart.bg_color, text_size = size.small)
    else if not na(health)
        table.delete(health)
        health := na
````

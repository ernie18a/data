# 10am Bias Stats

- url: https://www.tradingview.com/script/FR9Nns3p-10am-Bias-Stats/
- type: indicator
- pine_id: PUB;ce700b7157154c01ba2131eccd2797a9
- version: 1.0

## Description

10am Bias + Stats to help determine bias going into 10am on indices.

## Source Code

````pine
// ============================================================
//  10am Bias Signal — Stats Tracker
//  PineScript v5  |  1-HOUR chart  |  UTC-4 (New York ET)
//
//  Signals determined at 10am (9am bar in UTC-4):
//    S1 - 9am-10am 1h candle wick:
//         Bull = large bottom wick only
//         Bear = large top wick only
//         Neutral = large both or neither
//    S2 - 8am-10am 2h synthetic candle wick:
//         Same logic as S1
//    S3 - ADR tag before 10am:
//         Bull = ADR low tagged, high not tagged
//         Bear = ADR high tagged, low not tagged
//         Neutral = both tagged or neither tagged
//
//  Win/Loss:
//    The 10am-11am candle (9am bar) is a Win if:
//      Bull signal → candle moves more to upside (high-open > open-low)
//      Bear signal → candle moves more to downside (open-low > high-open)
//    Neutral signals are tracked but excluded from win/loss
//
//  Table shows:
//    Overall winrate per signal
//    Winrate broken down by day of week
//    Signal frequency counts
// ============================================================
//@version=5
indicator("10am Bias Stats", overlay=true, max_bars_back=5000)

// ══════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════
grpWick   = "Wick Settings"
wickThresh = input.float(0.3, "Large wick threshold (% of candle range)", minval=0.1, maxval=0.49, step=0.05, group=grpWick, tooltip="A wick must be at least this fraction of the total candle range to be considered large. 0.3 = 30% of range.")

grpADR    = "ADR Settings"
adrDays   = input.int(10, "ADR lookback (days)", minval=3, maxval=60, group=grpADR)

grpVis    = "Display"
showLbl   = input.bool(true,  "Show signal label at 10am",     group=grpVis)
showTable = input.bool(true,  "Show stats table",              group=grpVis)
showDebug = input.bool(false, "Show debug labels",             group=grpVis)
colBull   = input.color(color.new(color.teal, 75), "Bull background", group=grpVis)
colBear   = input.color(color.new(color.red,  75), "Bear background", group=grpVis)
colNeut   = input.color(color.new(color.gray, 75), "Neutral background", group=grpVis)

// ══════════════════════════════════════════════
// BAR TIME IDENTIFICATION (UTC-4, shifted back 1hr)
// ══════════════════════════════════════════════
h = hour(time)
m = minute(time)

is7amBar  = (h == 7  and m == 0)   // 8am-9am candle (open at 8am ET)
is8amBar  = (h == 8  and m == 0)   // 9am-10am candle (open at 9am ET)
is9amBar  = (h == 9  and m == 0)   // 10am-11am candle = bias + outcome bar
is10amBar = (h == 10 and m == 0)   // 11am close — outcome finalised
is15pmBar = (h == 15 and m == 0)   // 4pm RTH close
isRTHBar  = h >= 7 and h < 15

dow = dayofweek(time)  // 1=Sun,2=Mon,3=Tue,4=Wed,5=Thu,6=Fri,7=Sat

// ══════════════════════════════════════════════
// WICK SIGNAL FUNCTION
// Returns: 1=Bull, -1=Bear, 0=Neutral
// ══════════════════════════════════════════════
f_wickSignal(o, h_, l_, c_, thresh) =>
    totalRange = h_ - l_
    sig = 0
    if totalRange > 0
        bodyHi  = math.max(o, c_)
        bodyLo  = math.min(o, c_)
        topWick = (h_ - bodyHi) / totalRange
        botWick = (bodyLo - l_) / totalRange
        largTop = topWick >= thresh
        largBot = botWick >= thresh
        if largBot and not largTop
            sig := 1      // Bull
        else if largTop and not largBot
            sig := -1     // Bear
        else
            sig := 0      // Neutral (both or neither)
    sig

// ══════════════════════════════════════════════
// TRACK 8am-9am CANDLE (7am bar in shifted time)
// ══════════════════════════════════════════════
var float open7am = na
var float high7am = na
var float low7am  = na

if is7amBar
    open7am := open
    high7am := high
    low7am  := low

// ══════════════════════════════════════════════
// TRACK 9am-10am CANDLE (8am bar in shifted time)
// ══════════════════════════════════════════════
var float open8am  = na
var float high8am  = na
var float low8am   = na
var float close8am = na

if is8amBar
    open8am  := open
    high8am  := high
    low8am   := low
    close8am := close

// Update 7am candle high/low composite as 8am bar closes
var float comp2hHigh = na
var float comp2hLow  = na

if is8amBar and not na(high7am)
    comp2hHigh := math.max(high7am, high)
    comp2hLow  := math.min(low7am,  low)

// ══════════════════════════════════════════════
// ADR TRACKING
// ══════════════════════════════════════════════
var float[] dailyHighs = array.new_float(0)
var float[] dailyLows  = array.new_float(0)

var float dayHigh  = na
var float dayLow   = na
var float pdClose  = na
var float dayClose = na

if isRTHBar
    dayHigh  := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow   := na(dayLow)  ? low  : math.min(dayLow,  low)
    dayClose := close

if is15pmBar
    if not na(dayHigh) and not na(dayLow)
        array.push(dailyHighs, dayHigh)
        array.push(dailyLows,  dayLow)
        if array.size(dailyHighs) > adrDays
            array.shift(dailyHighs)
            array.shift(dailyLows)
    pdClose := dayClose
    dayHigh := na
    dayLow  := na

f_adr() =>
    n = array.size(dailyHighs)
    total = 0.0
    if n > 0
        for i = 0 to n - 1
            total += array.get(dailyHighs, i) - array.get(dailyLows, i)
        total / n
    else
        na

// Track intraday high/low from open to 10am for ADR tag check
var float intradayHigh = na
var float intradayLow  = na

if is7amBar
    intradayHigh := high
    intradayLow  := low
else if isRTHBar and h < 9
    intradayHigh := na(intradayHigh) ? high : math.max(intradayHigh, high)
    intradayLow  := na(intradayLow)  ? low  : math.min(intradayLow,  low)

// ══════════════════════════════════════════════
// COMPUTE SIGNALS AT 9am BAR (= 10am ET)
// ══════════════════════════════════════════════
var int sig1 = 0   // S1: 9am-10am wick
var int sig2 = 0   // S2: 8am-10am 2h wick
var int sig3 = 0   // S3: ADR tag
var int combinedSig = 0  // majority vote

if is9amBar
    // S1: 8am bar (9am-10am ET candle)
    if not na(open8am)
        sig1 := f_wickSignal(open8am, high8am, low8am, close8am, wickThresh)
    else
        sig1 := 0

    // S2: synthetic 2h candle (8am open ET → 10am open ET)
    if not na(open7am) and not na(comp2hHigh) and not na(comp2hLow)
        sig2 := f_wickSignal(open7am, comp2hHigh, comp2hLow, open, wickThresh)
    else
        sig2 := 0

    // S3: ADR tag check
    adr = f_adr()
    if not na(adr) and not na(pdClose) and adr > 0
        adrHi = pdClose + adr
        adrLo = pdClose - adr
        taggedHi = not na(intradayHigh) and intradayHigh >= adrHi
        taggedLo = not na(intradayLow)  and intradayLow  <= adrLo
        if taggedLo and not taggedHi
            sig3 := 1
        else if taggedHi and not taggedLo
            sig3 := -1
        else
            sig3 := 0
    else
        sig3 := 0

    // Combined signal — majority of the 3
    voteSum = sig1 + sig2 + sig3
    combinedSig := voteSum > 0 ? 1 : voteSum < 0 ? -1 : 0

// ══════════════════════════════════════════════
// OUTCOME TRACKING
// At 10am bar close (11am ET) determine win/loss
// Win: bull signal + up move dominant (high-open > open-low)
//      bear signal + down move dominant (open-low > high-open)
// ══════════════════════════════════════════════

// Storage arrays
// Signal arrays: 1=Bull, -1=Bear, 0=Neutral
// Win arrays: 1=Win, 0=Loss, -1=Neutral (excluded)
var int[]   storedSig1  = array.new_int(0)
var int[]   storedSig2  = array.new_int(0)
var int[]   storedSig3  = array.new_int(0)
var int[]   storedComb  = array.new_int(0)
var int[]   storedWin   = array.new_int(0)   // based on combined signal
var int[]   storedWin1  = array.new_int(0)   // based on S1 alone
var int[]   storedWin2  = array.new_int(0)   // based on S2 alone
var int[]   storedWin3  = array.new_int(0)   // based on S3 alone
var int[]   storedDow   = array.new_int(0)   // day of week

// Pending — snapshot signals at 9am bar
var int  pSig1 = 0
var int  pSig2 = 0
var int  pSig3 = 0
var int  pComb = 0
var int  pDow  = 0
var bool pendingSignal = false

if is9amBar
    pSig1         := sig1
    pSig2         := sig2
    pSig3         := sig3
    pComb         := combinedSig
    pDow          := dow
    pendingSignal := true

f_winLoss(sig, candleHigh, candleLow, candleOpen) =>
    if sig == 0
        -1  // neutral — excluded
    else
        upMove   = candleHigh - candleOpen
        downMove = candleOpen - candleLow
        if sig == 1
            upMove > downMove ? 1 : 0
        else
            downMove > upMove ? 1 : 0

if is10amBar and pendingSignal
    // 9am bar (10am-11am ET) just closed — that's our outcome candle
    // Use the previous bar (9am bar = is9amBar[0] which is now bar[-1])
    outHigh  = high[1]
    outLow   = low[1]
    outOpen  = open[1]

    w    = f_winLoss(pComb, outHigh, outLow, outOpen)
    w1   = f_winLoss(pSig1, outHigh, outLow, outOpen)
    w2   = f_winLoss(pSig2, outHigh, outLow, outOpen)
    w3   = f_winLoss(pSig3, outHigh, outLow, outOpen)

    array.push(storedSig1, pSig1)
    array.push(storedSig2, pSig2)
    array.push(storedSig3, pSig3)
    array.push(storedComb, pComb)
    array.push(storedWin,  w)
    array.push(storedWin1, w1)
    array.push(storedWin2, w2)
    array.push(storedWin3, w3)
    array.push(storedDow,  pDow)

    pendingSignal := false

// ══════════════════════════════════════════════
// STATS CALCULATION
// ══════════════════════════════════════════════
f_winrate(winArr, sigArr, filterSig, filterDow) =>
    // filterSig: 0=all non-neutral, 1=bull only, -1=bear only, 99=ignore sig filter
    // filterDow: 0=all days, 2-6=specific day
    wins  = 0
    total = 0
    n     = array.size(winArr)
    if n > 0
        for i = 0 to n - 1
            w   = array.get(winArr, i)
            s   = array.get(sigArr, i)
            d   = array.get(storedDow, i)
            // Skip neutral outcomes
            if w == -1
                continue
            // Day filter
            if filterDow > 0 and d != filterDow
                continue
            // Signal filter
            if filterSig == 99
                wins  += w
                total += 1
            else if filterSig == 0 and s != 0
                wins  += w
                total += 1
            else if filterSig == s and s != 0
                wins  += w
                total += 1
    [wins, total]

f_pct(wins, total) =>
    total > 0 ? math.round(wins / total * 1000) / 10 : 0.0

f_cell(tbl, col, row, wins, total, showPct) =>
    pct    = f_pct(wins, total)
    txt    = showPct ? str.tostring(pct) + "%" : str.tostring(total)
    col_   = pct >= 55.0 ? color.teal : pct <= 45.0 and total > 0 ? color.red : color.gray
    table.cell(tbl, col, row, txt, text_color=total > 0 ? col_ : color.new(color.gray, 60), text_size=size.tiny)

// ══════════════════════════════════════════════
// BACKGROUND AT 10AM BAR
// ══════════════════════════════════════════════
var int lastComb = 0
if is9amBar
    lastComb := combinedSig

bgCol = lastComb == 1 ? colBull : lastComb == -1 ? colBear : colNeut
bgcolor(showLbl and h == 9 and lastComb != 0 ? bgCol : na, title="10am Signal Background")

// ══════════════════════════════════════════════
// SIGNAL LABEL AT 10AM
// ══════════════════════════════════════════════
f_sigStr(s) =>
    s == 1 ? "▲ Bull" : s == -1 ? "▼ Bear" : "◆ Neut"

if is9amBar and showLbl
    n = array.size(storedWin)
    lblCol = combinedSig == 1 ? color.teal : combinedSig == -1 ? color.red : color.gray
    label.new(bar_index, high, text="── 10am Bias ──\nS1 (9am wick):    " + f_sigStr(sig1) + "\nS2 (8-10am wick): " + f_sigStr(sig2) + "\nS3 (ADR tag):     " + f_sigStr(sig3) + "\nCombined:         " + f_sigStr(combinedSig) + "\nn=" + str.tostring(n) + " samples", style=label.style_label_lower_right, color=color.new(lblCol, 15), textcolor=color.white, size=size.small)

// ══════════════════════════════════════════════
// STATS TABLE
// Rows: Overall | Mon | Tue | Wed | Thu | Fri
// Cols: Signal  | S1 Win% | S1 n | S2 Win% | S2 n | S3 Win% | S3 n | Comb Win% | Comb n
// ══════════════════════════════════════════════
var table stbl = na

if is9amBar and showTable and array.size(storedWin) > 0
    if not na(stbl)
        table.delete(stbl)

    stbl := table.new(position.top_right, 9, 7, bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 30), frame_width=1)

    // Header
    table.cell(stbl, 0, 0, "Day",      text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 1, 0, "S1 W%",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 2, 0, "S1 n",    text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 3, 0, "S2 W%",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 4, 0, "S2 n",    text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 5, 0, "S3 W%",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 6, 0, "S3 n",    text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 7, 0, "Cmb W%",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))
    table.cell(stbl, 8, 0, "Cmb n",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 30))

    // Row labels
    rowLabels = array.from("All", "Mon", "Tue", "Wed", "Thu", "Fri")
    rowDows   = array.from(0, 2, 3, 4, 5, 6)  // 0=all, 2=Mon...6=Fri in TV

    for r = 0 to 5
        lbl = array.get(rowLabels, r)
        d   = array.get(rowDows,   r)
        table.cell(stbl, 0, r + 1, lbl, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 40))

        [w1, t1] = f_winrate(storedWin1, storedSig1, 0, d)
        f_cell(stbl, 1, r + 1, w1, t1, true)
        f_cell(stbl, 2, r + 1, w1, t1, false)

        [w2, t2] = f_winrate(storedWin2, storedSig2, 0, d)
        f_cell(stbl, 3, r + 1, w2, t2, true)
        f_cell(stbl, 4, r + 1, w2, t2, false)

        [w3, t3] = f_winrate(storedWin3, storedSig3, 0, d)
        f_cell(stbl, 5, r + 1, w3, t3, true)
        f_cell(stbl, 6, r + 1, w3, t3, false)

        [wc, tc] = f_winrate(storedWin, storedComb, 0, d)
        f_cell(stbl, 7, r + 1, wc, tc, true)
        f_cell(stbl, 8, r + 1, wc, tc, false)

// ══════════════════════════════════════════════
// DEBUG
// ══════════════════════════════════════════════
if showDebug
    if is7amBar or is8amBar or is9amBar or is10amBar
        label.new(bar_index, low, text=str.tostring(h) + ":00  S1=" + str.tostring(sig1) + "  S2=" + str.tostring(sig2) + "  S3=" + str.tostring(sig3) + "  n=" + str.tostring(array.size(storedWin)), style=label.style_label_upper_right, color=color.new(color.blue, 60), textcolor=color.white, size=size.tiny)

// ══════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════
alertcondition(is9amBar and combinedSig == 1,  "10am Bull Signal", "Bull bias at 10am ET on {{ticker}}")
alertcondition(is9amBar and combinedSig == -1, "10am Bear Signal", "Bear bias at 10am ET on {{ticker}}")
````

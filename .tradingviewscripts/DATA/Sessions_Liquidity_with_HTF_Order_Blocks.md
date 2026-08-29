<!-- tradingview-pine-id: PUB;96cd5ca14d214d759e04e7b10be7f214 -->
<!-- tradingviewscripts-format: 1 -->
# Sessions & Liquidity with HTF Order Blocks

Source: https://www.tradingview.com/script/XfGaHRk2-sessions-liquidity-with-htf-order-blocks/

## Description

WHAT IT DOES

This indicator combines three intraday concepts on one chart: the actual price range of each trading session, the unswept extremes those sessions leave behind, and higher-timeframe order blocks. The goal is to see where liquidity is resting and where the higher timeframe last shifted direction, without stacking three separate scripts on the chart.

1. SESSION RANGE

For each of the three sessions (Asia, London, New York) the script tracks the running high and low and draws them as two horizontal segments bounded by the session window itself — the segments do not run across the whole chart. While a session is open, the segments are projected forward to its scheduled close time, which is computed from the session string (HHMM-HHMM) in the selected time zone; overnight windows such as 1600-0100 are handled by rolling the close into the next day. When the session ends, the projection is trimmed back to the last bar of the session, so what remains on the chart is the true range of that session and nothing more.

Session windows, names, colors and the time zone are all inputs. The defaults are set for Europe/Moscow (UTC+3): Asia 03:00-12:00, London 10:00-19:00, New York 16:00-01:00.

2. LIQUIDITY LEVELS (HH session / HL session)

The moment a session closes, its high and low are converted into liquidity levels: dashed lines extended to the right and re-anchored to the current bar on every new bar. The idea is the standard one — a session extreme that has not been traded through is resting liquidity, and price tends to reach for it.

A level is considered swept as soon as any bar trades beyond it (high > level for a high, low < level for a low). A swept level is deleted from the chart instead of being greyed out, so at any moment the chart only shows liquidity that is still intact. Optionally an alert fires on the sweep, on bar close, with the level type and price in the message.

Only the N most recent levels per side are kept (4 by default) so the chart does not accumulate old lines.

3. HIGHER-TIMEFRAME ORDER BLOCKS

Order blocks are calculated on a configurable higher timeframe (1H by default) via request.security with lookahead_off, so no future data is used and the blocks do not repaint into the past.

The definition used here is deliberately simple and mechanical:
- a bullish block is the last bearish candle after which the next candle closed above its high;
- a bearish block is the last bullish candle after which the next candle closed below its low.

That candle's range (its high and low) becomes the zone. A block is drawn from the timestamp of the origin candle and its right edge follows the close of the session currently in progress — when London and New York overlap, the earlier close is used, and the edge jumps forward once that session ends. This ties the zones visually to the session structure rather than letting them extend indefinitely.

A block is removed as soon as price closes beyond it (below a bullish zone, above a bearish zone) — a wick through the zone does not mitigate it. Only the N most recent blocks per side are kept (3 by default).

HOW TO USE IT

- Intended timeframes: 5m, 15m, 30m, 1H. Sessions do not exist on daily and above, so on 1D and higher the script only prints a warning label and draws nothing.
- Set the time zone input to the one your session hours are written in — everything else follows from it.
- A typical read: price sweeps an HH session level (the level disappears and the alert fires), then reacts from a higher-timeframe order block in the opposite direction. The sweep marks where liquidity was taken; the block marks where the reaction is expected.
- The session ranges themselves are useful as context: a New York range opening entirely above the London range is a different market than one opening inside it.

ALERTS

Enable "Alert when a level is swept" and create an alert on the indicator with "Any alert() function call". The message contains the level type (HH/HL session) and its price.

ORIGINALITY AND NOTES

Session boxes, liquidity levels and order blocks all exist as separate published scripts. What is specific to this one is how the three are wired together: session extremes become liquidity levels automatically on session close, swept levels are deleted rather than kept, and the right edge of every order block is bound to the close of the session currently running instead of extending forever. All levels come from closed sessions and all order blocks are read with lookahead_off, so nothing on the chart is drawn using data that was not available at that time.

This script is not a signal generator and produces no entries or exits — it is a context tool.

---

## Source Code

````pine
//@version=6
// Sessions & Liquidity with HTF Order Blocks
//
// What it draws:
//   1) High and low of EACH trading session — segments limited to the session window, with a label
//      (Asia, London, New York).
//   2) HH session / HL session — extremes of CLOSED sessions, extended to the right as dashed
//      liquidity levels. A level lives until it is swept. Once swept it is deleted and an alert fires.
//   3) Order Block from a higher timeframe (1H by default) — the zone of the last opposite candle
//      before an impulse. It is removed when price closes beyond the zone.
//
// TIMEFRAME: this is an intraday tool by nature — sessions do not exist on 1D and above.
//            The only higher-timeframe calculation is the Order Block (request.security, configurable).
//            Use it on 5m / 15m / 30m / 1H.

indicator("Sessions & Liquidity with HTF Order Blocks", overlay = true,
          max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═══════════════ INPUTS ═══════════════
gS = "Sessions"
tz       = input.string("Europe/Moscow", "Session time zone",
           options = ["Europe/Moscow", "Etc/UTC", "America/New_York", "Europe/London", "Asia/Shanghai"], group = gS)
showName = input.bool(true,  "Show session name labels", group = gS)
nameSzIn = input.string("Large", "Label size",
           options = ["Small", "Normal", "Large", "Huge"], group = gS)
nameGapK = input.float(0.3, "Label offset from line (x ATR)", minval = 0, maxval = 2, step = 0.1, group = gS)
lineW    = input.int(2, "Session line width", minval = 1, maxval = 4, group = gS)
projRight = input.bool(true, "Extend the running session line to its close", group = gS)

nameSz = nameSzIn == "Small"  ? size.small  :
         nameSzIn == "Normal" ? size.normal :
         nameSzIn == "Large"  ? size.large  : size.huge

aOn  = input.bool(true, "", inline = "a", group = gS)
aNm  = input.string("Asia",       "", inline = "a", group = gS)
aSes = input.session("0300-1200", "", inline = "a", group = gS)
aCol = input.color(#26C6DA,       "", inline = "a", group = gS)

lOn  = input.bool(true, "", inline = "l", group = gS)
lNm  = input.string("London",     "", inline = "l", group = gS)
lSes = input.session("1000-1900", "", inline = "l", group = gS)
lCol = input.color(#FF9800,       "", inline = "l", group = gS)

nOn  = input.bool(true, "", inline = "n", group = gS)
nNm  = input.string("New York",   "", inline = "n", group = gS)
nSes = input.session("1600-0100", "", inline = "n", group = gS)
nCol = input.color(#2196F3,       "", inline = "n", group = gS)

gL = "Liquidity levels (HH / HL session)"
liqOn    = input.bool(true, "Show levels of closed sessions", group = gL)
liqMax   = input.int(4, "Levels to keep (per side)", minval = 1, maxval = 10, group = gL)
liqOffs  = input.int(6, "Label offset to the right (bars)", minval = 0, maxval = 50, group = gL)
liqHiCol = input.color(#EF5350, "HH / HL color", inline = "lc", group = gL)
liqLoCol = input.color(#26A69A, "", inline = "lc", group = gL)
sweepAl  = input.bool(true, "Alert when a level is swept", group = gL)
liqSzIn  = input.string("Normal", "Level label size",
           options = ["Small", "Normal", "Large"], group = gL)

liqSz = liqSzIn == "Small" ? size.small : liqSzIn == "Normal" ? size.normal : size.large

gO = "Order Block (higher timeframe)"
obOn   = input.bool(true, "Show Order Blocks", group = gO)
obTf   = input.timeframe("60", "Order Block timeframe", group = gO)
obMax  = input.int(3, "Blocks to keep (per side)", minval = 1, maxval = 10, group = gO)
obBull = input.color(color.new(#26A69A, 80), "Bullish / bearish", inline = "oc", group = gO)
obBear = input.color(color.new(#EF5350, 80), "", inline = "oc", group = gO)

// ═══════════════ 1. SESSIONS ═══════════════
type Sess
    string name
    color  col
    float  hi
    float  lo
    int    x1
    line   hiLn
    line   loLn
    label  hiLb
    label  loLb

var Sess sA = Sess.new(aNm, aCol, na, na, na, na, na, na, na)
var Sess sL = Sess.new(lNm, lCol, na, na, na, na, na, na, na)
var Sess sN = Sess.new(nNm, nCol, na, na, na, na, na, na, na)

// vertical label offset from the session line, in ATR units, so the text does not stick to the line
nameGap = ta.atr(14) * nameGapK

// Session close time in ms. Parsed straight from the session string "HHMM-HHMM" (chars 5..8).
sessEndMs(string spec) =>
    eh = int(str.tonumber(str.substring(spec, 5, 7)))
    em = int(str.tonumber(str.substring(spec, 7, 9)))
    e  = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), eh, em, 0)
    // an overnight session (e.g. 1600-0100) closes on the next day
    e <= time ? e + 86400000 : e

// How many bars ahead of the current one that is (500 is Pine's cap for drawing into the future)
endMsToBars(float endMs) =>
    math.min(int((endMs - time) / (timeframe.in_seconds() * 1000)), 500)

// ─── liquidity level storage ───
var array<line>  liqLn = array.new<line>()
var array<label> liqLb = array.new<label>()
var array<float> liqPr = array.new<float>()
var array<bool>  liqIsHi = array.new<bool>()

addLiq(float price, bool isHigh) =>
    if liqOn
        col = isHigh ? liqHiCol : liqLoCol
        ln  = line.new(bar_index, price, bar_index + liqOffs, price,
                       color = col, style = line.style_dashed, width = 1)
        lb  = label.new(bar_index + liqOffs, price, isHigh ? "HH session" : "HL session",
                        style = label.style_label_left,
                        color = color.new(col, 85), textcolor = col, size = liqSz)
        array.push(liqLn, ln)
        array.push(liqLb, lb)
        array.push(liqPr, price)
        array.push(liqIsHi, isHigh)
        // trim the oldest levels on the same side
        cnt = 0
        for i = array.size(liqPr) - 1 to 0
            if array.get(liqIsHi, i) == isHigh
                cnt += 1
                if cnt > liqMax
                    line.delete(array.get(liqLn, i))
                    label.delete(array.get(liqLb, i))
                    array.remove(liqLn, i)
                    array.remove(liqLb, i)
                    array.remove(liqPr, i)
                    array.remove(liqIsHi, i)

// updating one session: start / continuation / close
// NOTE: every branch must return a SINGLE type (otherwise Pine raises CE0235),
//       hence the dummy int 0 at the end of each one.
updSess(Sess s, bool en, bool inNow, bool wasIn, int rightBars) =>
    if en and inNow and not wasIn
        // session start — the line is immediately extended to its future close
        s.hi   := high
        s.lo   := low
        s.x1   := bar_index
        x2     = bar_index + rightBars
        s.hiLn := line.new(bar_index, high, x2, high, color = s.col, width = lineW)
        s.loLn := line.new(bar_index, low,  x2, low,  color = s.col, width = lineW)
        if showName
            mid0 = int(math.avg(bar_index, x2))
            s.hiLb := label.new(mid0, high + nameGap, s.name, style = label.style_none,
                                textcolor = s.col, size = nameSz, yloc = yloc.price)
            s.loLb := label.new(mid0, low - nameGap,  s.name, style = label.style_none,
                                textcolor = s.col, size = nameSz, yloc = yloc.price)
        0
    else if en and inNow and not na(s.x1)
        // session in progress — extremes are updated, the right edge stays at the close time
        s.hi := math.max(s.hi, high)
        s.lo := math.min(s.lo, low)
        x2   = bar_index + rightBars
        mid  = int(math.avg(s.x1, x2))   // label x accepts int only
        line.set_xy1(s.hiLn, s.x1, s.hi)
        line.set_xy2(s.hiLn, x2, s.hi)
        line.set_xy1(s.loLn, s.x1, s.lo)
        line.set_xy2(s.loLn, x2, s.lo)
        if showName
            label.set_xy(s.hiLb, mid, s.hi + nameGap)
            label.set_xy(s.loLb, mid, s.lo - nameGap)
        0
    else if en and wasIn and not inNow and not na(s.x1)
        // session closed — the projection is trimmed to the actual end and liquidity levels are stored
        line.set_x2(s.hiLn, bar_index - 1)
        line.set_x2(s.loLn, bar_index - 1)
        if showName
            midE = int(math.avg(s.x1, bar_index - 1))
            label.set_x(s.hiLb, midE)
            label.set_x(s.loLb, midE)
        addLiq(s.hi, true)
        addLiq(s.lo, false)
        0
    else
        0

aIn = aOn and not na(time(timeframe.period, aSes, tz))
lIn = lOn and not na(time(timeframe.period, lSes, tz))
nIn = nOn and not na(time(timeframe.period, nSes, tz))

// "were we inside the session on the previous bar" — kept in var flags rather than read via [1].
// na() does not work with series bool (CE0103), so the state is stored manually.
var bool aPrev = false
var bool lPrev = false
var bool nPrev = false

// close time of every session + how many bars ahead to extend the running session line
aEndMs = sessEndMs(aSes)
lEndMs = sessEndMs(lSes)
nEndMs = sessEndMs(nSes)

aRight = projRight ? endMsToBars(aEndMs) : 0
lRight = projRight ? endMsToBars(lEndMs) : 0
nRight = projRight ? endMsToBars(nEndMs) : 0

// The nearest close among the sessions running right now — the right edge of the Order Blocks.
// London and New York overlap, so the one closing first is used:
// once it closes, the edge jumps to the end of the next session by itself.
float aEndAct = aIn ? aEndMs : na
float lEndAct = lIn ? lEndMs : na
float nEndAct = nIn ? nEndMs : na
nearEnd = math.min(nz(aEndAct, 1e15), nz(lEndAct, 1e15), nz(nEndAct, 1e15))
obRight = nearEnd >= 1e15 ? time : int(nearEnd)   // outside sessions — up to the current bar

intraday = timeframe.isintraday
if intraday
    updSess(sA, aOn, aIn, aPrev, aRight)
    updSess(sL, lOn, lIn, lPrev, lRight)
    updSess(sN, nOn, nIn, nPrev, nRight)

aPrev := aIn
lPrev := lIn
nPrev := nIn

// ═══════════════ 2. LEVEL LIFECYCLE: extend right, delete on sweep ═══════════════
if liqOn and array.size(liqPr) > 0
    for i = array.size(liqPr) - 1 to 0
        p     = array.get(liqPr, i)
        isHi  = array.get(liqIsHi, i)
        swept = isHi ? high > p : low < p
        if swept
            line.delete(array.get(liqLn, i))
            label.delete(array.get(liqLb, i))
            array.remove(liqLn, i)
            array.remove(liqLb, i)
            array.remove(liqPr, i)
            array.remove(liqIsHi, i)
            if sweepAl and barstate.isconfirmed
                alert("Level swept: " + (isHi ? "HH session " : "HL session ") + str.tostring(p, format.mintick),
                      alert.freq_once_per_bar)
        else
            line.set_x2(array.get(liqLn, i), bar_index + liqOffs)
            label.set_x(array.get(liqLb, i), bar_index + liqOffs)

// ═══════════════ 3. HIGHER-TIMEFRAME ORDER BLOCK ═══════════════
// Human-readable timeframe name: "60" -> "1H", "240" -> "4H", "15" -> "15m", "D" -> "1D"
tfLabel(string tf) =>
    s = str.upper(tf == "" ? timeframe.period : tf)
    n = str.tonumber(s)
    na(n)     ? (s == "D" ? "1D" : s == "W" ? "1W" : s == "M" ? "1M" : s) :
     n >= 1440 ? str.tostring(int(n / 1440)) + "D" :
     n >= 60   ? str.tostring(int(n / 60))   + "H" : str.tostring(int(n)) + "m"

obTfName = tfLabel(obTf)

// Bullish OB  — the last bearish candle after which a close broke above its high.
// Bearish OB — the last bullish candle after which a close broke below its low.
obCalc() =>
    bull = close > high[1] and close[1] < open[1]
    bear = close < low[1]  and close[1] > open[1]
    [bull, bear, high[1], low[1], time[1]]

[obB, obS, obHi, obLo, obT] = request.security(syminfo.tickerid, obTf, obCalc(), lookahead = barmerge.lookahead_off)

var array<box>  obBox  = array.new<box>()
var array<bool> obDir  = array.new<bool>()   // true = bullish
var array<float> obTop = array.new<float>()
var array<float> obBot = array.new<float>()
var float lastObT = na

pushOb(bool isBull, float top, float bot, int leftT) =>
    b = box.new(left = leftT, top = top, bottom = bot, right = obRight,
                xloc = xloc.bar_time, extend = extend.none,
                bgcolor = isBull ? obBull : obBear,
                border_color = color.new(isBull ? obBull : obBear, 40),
                text = "Order block " + obTfName, text_size = size.small,
                text_color = color.new(color.gray, 20),
                text_halign = text.align_right, text_valign = text.align_bottom)
    array.push(obBox, b)
    array.push(obDir, isBull)
    array.push(obTop, top)
    array.push(obBot, bot)
    cnt = 0
    for i = array.size(obDir) - 1 to 0
        if array.get(obDir, i) == isBull
            cnt += 1
            if cnt > obMax
                box.delete(array.get(obBox, i))
                array.remove(obBox, i)
                array.remove(obDir, i)
                array.remove(obTop, i)
                array.remove(obBot, i)

if obOn and (obB or obS) and not na(obT) and (na(lastObT) or obT != lastObT)
    lastObT := obT
    pushOb(obB, obHi, obLo, int(obT))

// mitigated blocks are removed (price closed beyond the zone), living ones follow the right edge
// to the close of the current session (both branches end with int 0 — Pine requirement, CE0235)
if obOn and array.size(obDir) > 0
    for i = array.size(obDir) - 1 to 0
        dead = array.get(obDir, i) ? close < array.get(obBot, i) : close > array.get(obTop, i)
        if dead
            box.delete(array.get(obBox, i))
            array.remove(obBox, i)
            array.remove(obDir, i)
            array.remove(obTop, i)
            array.remove(obBot, i)
            0
        else
            box.set_right(array.get(obBox, i), obRight)
            0

// ═══════════════ TIMEFRAME WARNING ═══════════════
if barstate.islast and not intraday
    label.new(bar_index, high, "Sessions & Liquidity: an intraday timeframe is required (5m-1H)",
              style = label.style_label_down, color = color.red, textcolor = color.white, size = size.normal)
````

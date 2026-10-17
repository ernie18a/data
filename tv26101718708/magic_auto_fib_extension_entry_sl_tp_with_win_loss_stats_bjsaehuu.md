# MAGIC Auto Fib Extension Entry SL TP with Win Loss Stats

- url: https://www.tradingview.com/script/bJSAEhUu-MAGIC-Auto-Fib-Extension-Entry-SL-TP-with-Win-Loss-Stats/
- type: indicator
- pine_id: PUB;98f51c34e36a44bfa4464f299c52bd20
- version: 1.0

## Description

MAGIC Auto Fib Extension automatically finds market swings and draws a Trend-Based Fibonacci Extension with ready-made Entry, Stop Loss and three Take Profit levels — plus a dashboard that tracks how every past signal performed.

HOW IT WORKS

1. Swing detection
The script uses pivot highs and lows (adjustable left/right bars) to build an alternating chain of swing points.

2. A → B → C pattern
- Bullish: A = swing low, B = swing high, C = higher low between A and B.
- Bearish: A = swing high, B = swing low, C = lower high between B and A.

3. Fib extension
Levels are projected from point C using the A→B leg:
Level price = C ± (B − A) × ratio
Default "MAGIC" ratios: 0, 0.5, 0.618, 1.414, 1.618, 2, 2.272, 2.618 (all editable, each can be turned on/off).

4. Trade levels
- Entry = point C (level 0)
- Stop Loss = beyond point C or beyond point A, with an ATR(14) buffer
- TP1 / TP2 / TP3 = selectable fib levels (default 0.618 / 1.618 / 2.618)
Labels are updated with ✓ when a TP is reached and ✗ when the SL is hit.

CLEAN CHART
Only the latest setup is drawn by default ("Setups kept on chart" = 1). Older setups are removed from the chart but are still tracked in the background, so the statistics stay complete.

WIN / LOSS DASHBOARD
Shows Buy, Sell and Total columns:
- Closed trades, Wins, Losses, Win rate
- How many trades reached TP1, TP2 and TP3
- Currently open trades
Rules: a trade that reaches TP1 counts as a win (even if SL is hit afterwards). A trade that hits SL before TP1 counts as a loss. A trade closes at SL or TP3. If SL and a TP are touched in the same candle, SL is assumed first (conservative).

ALERTS
- New bullish / bearish setup (with Entry, SL, TP1–TP3 in the message)
- TP1, TP2, TP3 hit
- SL hit

SETTINGS
Pivot lengths, bull/bear filter, fib levels, TP levels, SL mode and ATR buffer, colours, background fill, level values/prices, dashboard position, and optional markers for past signals.

IMPORTANT NOTES
- A setup is confirmed only after point C is confirmed as a pivot (after "Pivot right bars" candles). By then price may have moved away from point C, so the dashboard statistics assume an entry at C and may look better than real-time trading results.
- Statistics are based on the chart history loaded in TradingView and change with symbol and timeframe.
- This indicator is a tool for analysis and education. It is not financial advice and past results do not guarantee future performance. Always use proper risk management.

TRADE MANAGEMENT
Once TP1 is reached, move the Stop Loss to Cost to Cost (breakeven at the entry price). This protects the trade, and the remaining position can run towards TP2 and TP3 risk-free.

## Source Code

````pine
//@version=6
// ============================================================================
//  MAGIC – Auto Trend-Based Fib Extension with Entry / SL / TP
//  Auto-detects swings (A → B → C) and draws a Trend-Based Fib Extension
//  using the "MAGIC" template levels: 0, 0.5, 0.618, 1.414, 1.618, 2, 2.272, 2.618
//
//  Bullish : A = swing low, B = swing high, C = higher low  (C between A and B)
//  Bearish : A = swing high, B = swing low, C = lower high  (C between B and A)
//  Level price = C ± (B − A) × ratio      Entry = level 0 (point C)
//
//  Shows only the latest signal(s) on chart; dashboard counts ALL signals.
//  Win = TP1 reached (even if SL is hit later). Loss = SL hit before TP1.
// ============================================================================
indicator("MAGIC – Trend-Based Fib TP/SL", shorttitle = "MAGIC Fib", overlay = true,
     max_lines_count = 500, max_labels_count = 500)

// ─── Swing detection ────────────────────────────────────────────────────────
grpS      = "Swing Detection"
leftLen   = input.int(5, "Pivot left bars",  minval = 1, group = grpS)
rightLen  = input.int(5, "Pivot right bars", minval = 1, group = grpS, tooltip = "Higher = fewer, stronger swings, but later confirmation")
maxSetups = input.int(1, "Setups kept on chart", minval = 1, maxval = 20, group = grpS)
showBull  = input.bool(true, "Bullish setups", inline = "dir", group = grpS)
showBear  = input.bool(true, "Bearish setups", inline = "dir", group = grpS)
showMarks = input.bool(false, "Show markers for past signals", group = grpS)

// ─── Fib levels (MAGIC template) ────────────────────────────────────────────
grpL = "Fib Levels (MAGIC template)"
on1 = input.bool(true,  "", inline = "r1", group = grpL)
lv1 = input.float(0.0,   "", inline = "r1", group = grpL)
on2 = input.bool(true,  "", inline = "r1", group = grpL)
lv2 = input.float(0.5,   "", inline = "r1", group = grpL)
on3 = input.bool(true,  "", inline = "r2", group = grpL)
lv3 = input.float(0.618, "", inline = "r2", group = grpL)
on4 = input.bool(false, "", inline = "r2", group = grpL)
lv4 = input.float(1.0,   "", inline = "r2", group = grpL)
on5 = input.bool(false, "", inline = "r3", group = grpL)
lv5 = input.float(1.272, "", inline = "r3", group = grpL)
on6 = input.bool(true,  "", inline = "r3", group = grpL)
lv6 = input.float(1.414, "", inline = "r3", group = grpL)
on7 = input.bool(true,  "", inline = "r4", group = grpL)
lv7 = input.float(1.618, "", inline = "r4", group = grpL)
on8 = input.bool(true,  "", inline = "r4", group = grpL)
lv8 = input.float(2.0,   "", inline = "r4", group = grpL)
on9 = input.bool(true,  "", inline = "r5", group = grpL)
lv9 = input.float(2.272, "", inline = "r5", group = grpL)
onA = input.bool(true,  "", inline = "r5", group = grpL)
lvA = input.float(2.618, "", inline = "r5", group = grpL)

// ─── Style ──────────────────────────────────────────────────────────────────
grpV       = "Style"
showTrend  = input.bool(true, "Trend line", inline = "tl", group = grpV)
trendCol   = input.color(color.gray, "", inline = "tl", group = grpV)
levelCol   = input.color(color.gray, "Levels line", group = grpV)
extBars    = input.int(30, "Level length (bars)", minval = 5, maxval = 300, group = grpV, tooltip = "Don't extend: levels run this many bars right of point C")
bgOn       = input.bool(true, "Background", group = grpV)
bullBg     = input.color(color.new(color.teal, 88), "Bull fill", inline = "bg", group = grpV)
bearBg     = input.color(color.new(color.red, 88),  "Bear fill", inline = "bg", group = grpV)
showVals   = input.bool(false, "Show level values", group = grpV)
showPrices = input.bool(false, "Show level prices", group = grpV)
sizeStr    = input.string("normal", "Font size", options = ["tiny", "small", "normal", "large"], group = grpV)

lblSize = switch sizeStr
    "tiny"  => size.tiny
    "small" => size.small
    "large" => size.large
    => size.normal

// ─── Trade levels ───────────────────────────────────────────────────────────
grpT      = "Entry / SL / TP"
showTrade = input.bool(true, "Show Entry / SL / TP", group = grpT)
tp1R      = input.float(0.618, "TP1 fib level", step = 0.001, group = grpT)
tp2R      = input.float(1.618, "TP2 fib level", step = 0.001, group = grpT)
tp3R      = input.float(2.618, "TP3 fib level", step = 0.001, group = grpT)
slMode    = input.string("Beyond point C", "Stop loss at", options = ["Beyond point C", "Beyond point A"], group = grpT)
slBuf     = input.float(0.5, "SL buffer (× ATR 14)", minval = 0, step = 0.1, group = grpT)
entryCol  = input.color(color.blue,  "Entry", inline = "tc", group = grpT)
slCol     = input.color(color.red,   "SL",    inline = "tc", group = grpT)
tpCol     = input.color(color.green, "TP",    inline = "tc", group = grpT)

// ─── Dashboard ──────────────────────────────────────────────────────────────
grpD       = "Dashboard"
showDash   = input.bool(true, "Show wins / losses dashboard", group = grpD)
dashPosStr = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpD)

// ─── Types & helpers ────────────────────────────────────────────────────────
type Setup
    int   dir
    int   aBar
    int   bBar
    int   cBar
    float a
    float b
    float c
    int   created
    float entry
    float sl
    float tp1
    float tp2
    float tp3
    bool  tp1Hit = false
    bool  tp2Hit = false
    bool  tp3Hit = false
    bool  done   = false
    array<line>     lines
    array<label>    labels
    array<linefill> fills
    array<label>    tradeLbls

// Deletes drawings only (setup keeps being tracked for stats)
method del(Setup this) =>
    for f in this.fills
        f.delete()
    for l in this.lines
        l.delete()
    for lb in this.labels
        lb.delete()
    for lb in this.tradeLbls
        lb.delete()
    this.fills.clear()
    this.lines.clear()
    this.labels.clear()
    this.tradeLbls.clear()

fibPrice(int dir, float a, float b, float c, float r) =>
    c + dir * math.abs(b - a) * r

markHit(Setup s, int idx, string tag) =>
    if s.tradeLbls.size() == 5
        label lb = s.tradeLbls.get(idx)
        lb.set_text(lb.get_text() + "  " + tag)

var array<float> lvls = array.new<float>()
if barstate.isfirst
    if on1
        lvls.push(lv1)
    if on2
        lvls.push(lv2)
    if on3
        lvls.push(lv3)
    if on4
        lvls.push(lv4)
    if on5
        lvls.push(lv5)
    if on6
        lvls.push(lv6)
    if on7
        lvls.push(lv7)
    if on8
        lvls.push(lv8)
    if on9
        lvls.push(lv9)
    if onA
        lvls.push(lvA)
    lvls.sort(order.ascending)

createSetup(int dir, int aB, float a, int bB, float b, int cB, float c, float atrV) =>
    Setup s = Setup.new(dir = dir, aBar = aB, bBar = bB, cBar = cB, a = a, b = b, c = c,
         created = bar_index, lines = array.new<line>(), labels = array.new<label>(),
         fills = array.new<linefill>(), tradeLbls = array.new<label>())
    int x1 = cB
    int x2 = cB + extBars

    // Trend line A → B → C (dashed)
    if showTrend
        s.lines.push(line.new(aB, a, bB, b, color = trendCol, style = line.style_dashed))
        s.lines.push(line.new(bB, b, cB, c, color = trendCol, style = line.style_dashed))

    // Fib levels
    array<line> lvlLines = array.new<line>()
    for r in lvls
        float p  = fibPrice(dir, a, b, c, r)
        line  ln = line.new(x1, p, x2, p, color = levelCol)
        s.lines.push(ln)
        lvlLines.push(ln)
        string txt = showVals ? str.tostring(r) : ""
        if showPrices
            txt := txt + (txt == "" ? "" : " ") + "(" + str.tostring(p, format.mintick) + ")"
        if txt != ""
            s.labels.push(label.new(x1, p, txt, style = label.style_label_right,
                 color = color.new(color.white, 100), textcolor = levelCol, size = lblSize))

    // Background between levels
    if bgOn and lvlLines.size() > 1
        color fc = dir == 1 ? bullBg : bearBg
        for i = 0 to lvlLines.size() - 2
            s.fills.push(linefill.new(lvlLines.get(i), lvlLines.get(i + 1), fc))

    // Entry / SL / TP
    s.entry := c
    float slBase = slMode == "Beyond point C" ? c : a
    s.sl  := slBase - dir * atrV * slBuf
    s.tp1 := fibPrice(dir, a, b, c, tp1R)
    s.tp2 := fibPrice(dir, a, b, c, tp2R)
    s.tp3 := fibPrice(dir, a, b, c, tp3R)

    if showTrade
        array<float>  px  = array.from(s.entry, s.sl, s.tp1, s.tp2, s.tp3)
        array<string> nm  = array.from("Entry", "SL", "TP1", "TP2", "TP3")
        array<color>  col = array.from(entryCol, slCol, tpCol, tpCol, tpCol)
        for i = 0 to 4
            float p = px.get(i)
            s.lines.push(line.new(x1, p, x2, p, color = col.get(i), width = 2))
            s.tradeLbls.push(label.new(x2, p, nm.get(i) + "  " + str.tostring(p, format.mintick),
                 style = label.style_label_left, color = col.get(i), textcolor = color.white, size = lblSize))
    s

// ─── Swing tracking (kept alternating high/low) ─────────────────────────────
var array<float> pPrice  = array.new<float>()
var array<int>   pBar    = array.new<int>()
var array<int>   pType   = array.new<int>()    // 1 = high, -1 = low
var array<Setup> setups  = array.new<Setup>()  // drawn on chart
var array<Setup> pending = array.new<Setup>()  // removed from chart but still open (tracked for stats)

addPivot(int t, float p, int b) =>
    bool res = false
    int  n   = pType.size()
    if n > 0 and pType.get(n - 1) == t
        float last = pPrice.get(n - 1)
        if (t == 1 and p > last) or (t == -1 and p < last)
            pPrice.set(n - 1, p)
            pBar.set(n - 1, b)
            res := true
    else
        pType.push(t)
        pPrice.push(p)
        pBar.push(b)
        if pType.size() > 20
            pType.shift()
            pPrice.shift()
            pBar.shift()
        res := true
    res

float atrV = ta.atr(14)
float ph   = ta.pivothigh(high, leftLen, rightLen)
float pl   = ta.pivotlow(low, leftLen, rightLen)

bool changed = false
if not na(ph)
    changed := addPivot(1, ph, bar_index - rightLen) or changed
if not na(pl)
    changed := addPivot(-1, pl, bar_index - rightLen) or changed

bool newBull = false
bool newBear = false
Setup latest = na

if changed and pType.size() >= 3
    int n  = pType.size()
    float p0 = pPrice.get(n - 3)
    float p1 = pPrice.get(n - 2)
    float p2 = pPrice.get(n - 1)
    int   b0 = pBar.get(n - 3)
    int   b1 = pBar.get(n - 2)
    int   b2 = pBar.get(n - 1)
    int   t2 = pType.get(n - 1)
    int dir = 0
    if t2 == -1 and showBull and p2 > p0 and p2 < p1
        dir := 1
    else if t2 == 1 and showBear and p2 < p0 and p2 > p1
        dir := -1
    if dir != 0
        // If point C was just refined (same A & B), replace the old setup
        int staleIdx = -1
        for [i, st] in setups
            if st.dir == dir and st.aBar == b0 and st.bBar == b1 and not st.done
                staleIdx := i
        if staleIdx >= 0
            setups.get(staleIdx).del()
            setups.remove(staleIdx)
        if pending.size() > 0
            for i = pending.size() - 1 to 0
                Setup st = pending.get(i)
                if st.dir == dir and st.aBar == b0 and st.bBar == b1 and not st.done
                    pending.remove(i)
        latest := createSetup(dir, b0, p0, b1, p1, b2, p2, atrV)
        setups.push(latest)
        if setups.size() > maxSetups
            Setup old = setups.shift()
            old.del()
            if not old.done
                pending.push(old)
                if pending.size() > 50
                    pending.shift()
        newBull := dir == 1
        newBear := dir == -1

// ─── TP / SL hit tracking + statistics ──────────────────────────────────────
var int bClosed = 0, var int bWins = 0, var int bLoss = 0
var int bT1 = 0,     var int bT2 = 0,  var int bT3 = 0
var int sClosed = 0, var int sWins = 0, var int sLoss = 0
var int sT1 = 0,     var int sT2 = 0,  var int sT3 = 0

bool evTP1 = false
bool evTP2 = false
bool evTP3 = false
bool evSL  = false

array<Setup> allS = setups.copy()
allS.concat(pending)

int openB = 0
int openS = 0

for s in allS
    if not s.done and bar_index > s.created
        bool slNow = s.dir == 1 ? low <= s.sl : high >= s.sl
        if slNow
            s.done := true
            evSL   := true
            markHit(s, 1, "✗ hit")
        else
            if not s.tp1Hit and (s.dir == 1 ? high >= s.tp1 : low <= s.tp1)
                s.tp1Hit := true
                evTP1    := true
                markHit(s, 2, "✓")
            if not s.tp2Hit and (s.dir == 1 ? high >= s.tp2 : low <= s.tp2)
                s.tp2Hit := true
                evTP2    := true
                markHit(s, 3, "✓")
            if not s.tp3Hit and (s.dir == 1 ? high >= s.tp3 : low <= s.tp3)
                s.tp3Hit := true
                s.done   := true
                evTP3    := true
                markHit(s, 4, "✓")
        // count the trade once it closes
        if s.done
            bool win = s.tp1Hit
            if s.dir == 1
                bClosed += 1
                bWins   += win ? 1 : 0
                bLoss   += win ? 0 : 1
                bT1     += s.tp1Hit ? 1 : 0
                bT2     += s.tp2Hit ? 1 : 0
                bT3     += s.tp3Hit ? 1 : 0
            else
                sClosed += 1
                sWins   += win ? 1 : 0
                sLoss   += win ? 0 : 1
                sT1     += s.tp1Hit ? 1 : 0
                sT2     += s.tp2Hit ? 1 : 0
                sT3     += s.tp3Hit ? 1 : 0
    if not s.done
        if s.dir == 1
            openB += 1
        else
            openS += 1

// drop closed trades from the background list
if pending.size() > 0
    for i = pending.size() - 1 to 0
        if pending.get(i).done
            pending.remove(i)

// ─── Markers & alerts ───────────────────────────────────────────────────────
plotshape(showMarks and newBull, "New bullish setup", shape.triangleup,   location.belowbar, color.teal, size = size.tiny)
plotshape(showMarks and newBear, "New bearish setup", shape.triangledown, location.abovebar, color.red,  size = size.tiny)
plotshape(showMarks and (evTP1 or evTP2 or evTP3), "TP hit", shape.flag,   location.abovebar, color.green, size = size.tiny)
plotshape(showMarks and evSL, "SL hit", shape.xcross, location.belowbar, color.red, size = size.tiny)

if not na(latest)
    string side = latest.dir == 1 ? "BUY" : "SELL"
    alert("MAGIC " + side + " " + syminfo.ticker +
         " | Entry " + str.tostring(latest.entry, format.mintick) +
         " | SL "    + str.tostring(latest.sl,    format.mintick) +
         " | TP1 "   + str.tostring(latest.tp1,   format.mintick) +
         " | TP2 "   + str.tostring(latest.tp2,   format.mintick) +
         " | TP3 "   + str.tostring(latest.tp3,   format.mintick), alert.freq_once_per_bar_close)

alertcondition(newBull, "MAGIC bullish setup", "MAGIC: new bullish fib setup on {{ticker}}")
alertcondition(newBear, "MAGIC bearish setup", "MAGIC: new bearish fib setup on {{ticker}}")
alertcondition(evTP1,   "MAGIC TP1 hit",       "MAGIC: TP1 hit on {{ticker}}")
alertcondition(evTP2,   "MAGIC TP2 hit",       "MAGIC: TP2 hit on {{ticker}}")
alertcondition(evTP3,   "MAGIC TP3 hit",       "MAGIC: TP3 hit on {{ticker}}")
alertcondition(evSL,    "MAGIC SL hit",        "MAGIC: SL hit on {{ticker}}")

// ─── Wins / Losses dashboard ────────────────────────────────────────────────
dashPos = dashPosStr == "Top Left" ? position.top_left : dashPosStr == "Bottom Right" ? position.bottom_right :
     dashPosStr == "Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(dashPos, 4, 9, bgcolor = color.new(color.black, 15), border_color = color.gray, border_width = 1)

fWr(int w, int c) => c > 0 ? str.tostring(w * 100.0 / c, "#.0") + "%" : "-"
fPct(int n, int c) => c > 0 ? str.tostring(n) + " (" + str.tostring(n * 100.0 / c, "#") + "%)" : str.tostring(n)

dCell(int col, int row, string txt, color tc = color.white) =>
    table.cell(dash, col, row, txt, text_color = tc, text_size = size.small)

if showDash and barstate.islast
    int tC = bClosed + sClosed
    dCell(0, 0, "MAGIC Stats · " + timeframe.period, color.yellow)
    dCell(1, 0, "Buy",   color.aqua)
    dCell(2, 0, "Sell",  color.orange)
    dCell(3, 0, "Total", color.yellow)
    dCell(0, 1, "Closed trades")
    dCell(1, 1, str.tostring(bClosed))
    dCell(2, 1, str.tostring(sClosed))
    dCell(3, 1, str.tostring(tC))
    dCell(0, 2, "Wins (≥TP1)")
    dCell(1, 2, str.tostring(bWins), color.lime)
    dCell(2, 2, str.tostring(sWins), color.lime)
    dCell(3, 2, str.tostring(bWins + sWins), color.lime)
    dCell(0, 3, "Losses (SL)")
    dCell(1, 3, str.tostring(bLoss), color.red)
    dCell(2, 3, str.tostring(sLoss), color.red)
    dCell(3, 3, str.tostring(bLoss + sLoss), color.red)
    dCell(0, 4, "Win rate")
    dCell(1, 4, fWr(bWins, bClosed))
    dCell(2, 4, fWr(sWins, sClosed))
    dCell(3, 4, fWr(bWins + sWins, tC))
    dCell(0, 5, "Reached TP1")
    dCell(1, 5, fPct(bT1, bClosed))
    dCell(2, 5, fPct(sT1, sClosed))
    dCell(3, 5, fPct(bT1 + sT1, tC))
    dCell(0, 6, "Reached TP2")
    dCell(1, 6, fPct(bT2, bClosed))
    dCell(2, 6, fPct(sT2, sClosed))
    dCell(3, 6, fPct(bT2 + sT2, tC))
    dCell(0, 7, "Reached TP3")
    dCell(1, 7, fPct(bT3, bClosed))
    dCell(2, 7, fPct(sT3, sClosed))
    dCell(3, 7, fPct(bT3 + sT3, tC))
    dCell(0, 8, "Open trades")
    dCell(1, 8, str.tostring(openB))
    dCell(2, 8, str.tostring(openS))
    dCell(3, 8, str.tostring(openB + openS))
````

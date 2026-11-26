# EMA Cross Trend Entries [5 TP + SL + Key Levels]

- url: https://www.tradingview.com/script/CHzvYJWo-EMA-Cross-Trend-Entries-5-TP-SL-Key-Levels/
- type: indicator
- pine_id: PUB;500dac1337824835a25aad74e5c49130
- version: 1.0

## Description

EMA Cross Trend Entries combines a filtered EMA crossover with a complete, on-chart trade plan: entry, stop loss, five take-profit levels, breakeven, and key market levels — so every signal shows exactly where you're risking and where you're targeting.

Built and tested for XAUUSD on the 5-minute chart, but fully configurable for any symbol and timeframe.

━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━
The script plots four lines:
- EMA 13 (blue) and EMA 21 (red)
- A 14-period EMA smoothing of each (yellow) — these act as a slower trend filter

BUY signal
1. EMA 13 crosses above EMA 21
2. Within the next few candles (default 3), a candle CLOSES above all four lines
3. Entry is plotted at the open of the following candle

SELL signal — the exact mirror.

Requiring a close beyond both the fast EMAs and their smoothed versions filters out many of the weak, choppy crosses a plain 2-EMA crossover produces. Each cross can only produce one trade, and only one trade is tracked at a time.

Signals are confirmed on candle close and entries are drawn on the next candle's open, so signals do not repaint.

━━━━━━━━━━━━━━━━━━━━
TRADE MANAGEMENT
━━━━━━━━━━━━━━━━━━━━
- Stop Loss — placed at the low (buy) or high (sell) of the 5th candle back, with optional buffer
- Take Profit 1–5 — fixed distances from entry (default $10 / $20 / $30 / $40 / $50), each marked with a ✓ when reached
- Breakeven — stop moves to entry once price moves a set amount in your favour (default $5)
- Optional trailing — TP1 hit → SL to breakeven, TP2 hit → SL to TP1, and so on
- Early exit — closes the trade if a candle closes back across the EMAs (choose EMA 13, EMA 13 & 21, or all 4 lines)

Every trade is drawn as a shaded risk/reward zone with right-side price tags for Entry, Stop Loss and each Take Profit, plus a label showing how the trade ended (TP, SL, BE, Trail SL or EMA Exit).

━━━━━━━━━━━━━━━━━━━━
KEY LEVELS
━━━━━━━━━━━━━━━━━━━━
- Previous Day High (PDH) and Previous Day Low (PDL)
- Automatic support and resistance from confirmed swing pivots (latest 3 each side by default)

Use these to judge whether a signal has room to reach its targets or is running straight into a level.

━━━━━━━━━━━━━━━━━━━━
STATS PANEL
━━━━━━━━━━━━━━━━━━━━
Shows how the rules performed on the loaded chart history: number of trades, hits per TP level, exits by type (SL / BE / Trail / EMA), win rate and net result in price and in account currency for a chosen lot size.

━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━
All parameters are adjustable: EMA lengths, cross window, SL candle and buffer, number and distance of TPs, breakeven trigger, trailing, exit mode, number of past trades shown, zone colours, PDH/PDL and pivot sensitivity.

ALERTS
"EMA 13/21 BUY" and "EMA 13/21 SELL" alerts fire when a signal candle closes.

━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━
- The stats are a simplified simulation on chart data: one full position per trade, no spread, commission or slippage. When a candle touches both SL and TP, the SL is assumed to hit first. Results are for evaluating the rules only.
- Pivot support/resistance is confirmed after the "right bars" setting, so new levels appear with that delay.
- This indicator is a tool for analysis and education, not financial advice. Past performance does not guarantee future results. Always test on a demo account and use proper risk management.

## Source Code

````pine
//@version=6
// EMA 13/21 Cross with 5 TPs / SL zones — based on EMA_Cross_13_21_EA (MT5)
//  BUY : EMA13 crosses above EMA21, a candle closes above all 4 lines -> entry at next candle open
//  SELL: mirror
//  SL  : low/high of the 5th candle back | TP1..TP5 | BE at +$5 | optional trailing SL by TP levels
//  Early exit on EMA close | trade closes at the last TP
//  Levels: previous day high/low + pivot support/resistance
indicator("EMA Cross Trend Entries [5 TP + SL + Key Levels]", shorttitle = "EMA Cross 5TP", overlay = true,
     max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ───────── Inputs ─────────
fastLen   = input.int(13, "Fast EMA (blue)", minval = 1, group = "EMAs")
slowLen   = input.int(21, "Slow EMA (red)", minval = 1, group = "EMAs")
smLen     = input.int(14, "EMA-based MA length (yellow)", minval = 1, group = "EMAs")

allowBuy  = input.bool(true, "Show buys", group = "Entry")
allowSell = input.bool(true, "Show sells", group = "Entry")
validBars = input.int(3, "Max candles after cross (1 = cross candle only)", minval = 1, group = "Entry")

slBack    = input.int(5, "SL at Nth candle back", minval = 1, group = "Stop loss")
slBuf     = input.float(0.0, "SL buffer ($)", minval = 0, step = 0.1, group = "Stop loss")
beTrig    = input.float(5.0, "Breakeven trigger ($, 0 = off)", minval = 0, step = 0.5, group = "Stop loss")
beOff     = input.float(0.0, "Breakeven offset ($)", minval = 0, step = 0.1, group = "Stop loss")
trailSL   = input.bool(false, "Trail SL by TPs (TP1 hit → BE, TP2 hit → SL at TP1, ...)", group = "Stop loss")

numTP     = input.int(5, "Number of TPs (trade closes at the last one)", minval = 1, maxval = 5, group = "Take profits")
tp1       = input.float(10.0, "TP1 distance ($)", minval = 0.1, step = 0.5, group = "Take profits")
tp2       = input.float(20.0, "TP2 distance ($)", minval = 0.1, step = 0.5, group = "Take profits")
tp3       = input.float(30.0, "TP3 distance ($)", minval = 0.1, step = 0.5, group = "Take profits")
tp4       = input.float(40.0, "TP4 distance ($)", minval = 0.1, step = 0.5, group = "Take profits")
tp5       = input.float(50.0, "TP5 distance ($)", minval = 0.1, step = 0.5, group = "Take profits")

exitMode  = input.string("EMA 13 & 21", "Early exit when candle closes beyond",
     options = ["Off", "EMA 13", "EMA 13 & 21", "All 4 lines"], group = "Exit")

keepPast  = input.int(2, "Past signals to show (0 = all)", minval = 0, group = "Display")
showZones = input.bool(true, "Show TP/SL zones", group = "Display")
projBars  = input.int(30, "Zone width while trade is open (bars)", minval = 5, maxval = 400, group = "Display")
strips    = input.int(6, "Zone fade steps", minval = 1, maxval = 12, group = "Display")
slCol     = input.color(#F23645, "Stop loss colour", group = "Display")
tpCol     = input.color(#2EBD4E, "Take profit colour", group = "Display")
enCol     = input.color(#787B86, "Entry colour", group = "Display")
showStats = input.bool(true, "Show stats table", group = "Display")
lotSize   = input.float(0.10, "Lot size (for $ stats)", step = 0.01, group = "Display")
contract  = input.float(100, "Contract size (gold = 100 oz)", group = "Display")

// ───────── EMAs ─────────
fast   = ta.ema(close, fastLen)
slow   = ta.ema(close, slowLen)
fastSm = ta.ema(fast, smLen)
slowSm = ta.ema(slow, smLen)

plot(fast,   "EMA 13",          color.blue, 2)
plot(slow,   "EMA 21",          color.red,  2)
plot(fastSm, "EMA 13 smoothed", color.yellow, 1)
plot(slowSm, "EMA 21 smoothed", color.yellow, 1)

// ───────── Previous day high / low ─────────
showPD   = input.bool(true, "Show previous day high / low", group = "Levels")
pdhCol   = input.color(#FF9800, "PDH colour", group = "Levels")
pdlCol   = input.color(#9C27B0, "PDL colour", group = "Levels")

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)

var line  pdhLn = na
var line  pdlLn = na
var label pdhLb = na
var label pdlLb = na

if showPD and (timeframe.change("D") or na(pdhLn))
    line.delete(pdhLn)
    line.delete(pdlLn)
    label.delete(pdhLb)
    label.delete(pdlLb)
    pdhLn := line.new(bar_index, pdh, bar_index + 1, pdh, color = pdhCol, width = 2, extend = extend.right)
    pdlLn := line.new(bar_index, pdl, bar_index + 1, pdl, color = pdlCol, width = 2, extend = extend.right)
    pdhLb := label.new(bar_index, pdh, "PDH " + str.tostring(pdh, format.mintick), style = label.style_label_left,
         color = pdhCol, textcolor = color.white, size = size.small)
    pdlLb := label.new(bar_index, pdl, "PDL " + str.tostring(pdl, format.mintick), style = label.style_label_left,
         color = pdlCol, textcolor = color.white, size = size.small)

// ───────── Support / resistance (pivot based) ─────────
showSR   = input.bool(true, "Show support / resistance", group = "Levels")
srLeft   = input.int(10, "Pivot left bars", minval = 1, group = "Levels")
srRight  = input.int(10, "Pivot right bars", minval = 1, group = "Levels")
srCount  = input.int(3, "Levels to keep (each side)", minval = 1, maxval = 10, group = "Levels")
resCol   = input.color(#FF5252, "Resistance colour", group = "Levels")
supCol   = input.color(#00BCD4, "Support colour", group = "Levels")

var array<line>  resLns = array.new<line>()
var array<label> resLbs = array.new<label>()
var array<line>  supLns = array.new<line>()
var array<label> supLbs = array.new<label>()

ph = ta.pivothigh(high, srLeft, srRight)
pl = ta.pivotlow(low, srLeft, srRight)

if showSR and not na(ph)
    x = bar_index - srRight
    array.push(resLns, line.new(x, ph, x + 1, ph, color = resCol, width = 1, style = line.style_dashed, extend = extend.right))
    array.push(resLbs, label.new(bar_index, ph, "Resistance " + str.tostring(ph, format.mintick), style = label.style_label_left,
         color = resCol, textcolor = color.white, size = size.small))
    while array.size(resLns) > srCount
        line.delete(array.shift(resLns))
        label.delete(array.shift(resLbs))

if showSR and not na(pl)
    x = bar_index - srRight
    array.push(supLns, line.new(x, pl, x + 1, pl, color = supCol, width = 1, style = line.style_dashed, extend = extend.right))
    array.push(supLbs, label.new(bar_index, pl, "Support " + str.tostring(pl, format.mintick), style = label.style_label_left,
         color = supCol, textcolor = color.white, size = size.small))
    while array.size(supLns) > srCount
        line.delete(array.shift(supLns))
        label.delete(array.shift(supLbs))

// keep level labels at the right edge of the chart
if barstate.islast
    lx = bar_index + 3
    label.set_x(pdhLb, lx)
    label.set_x(pdlLb, lx)
    for l in resLbs
        label.set_x(l, lx)
    for l in supLbs
        label.set_x(l, lx)

top    = math.max(fast, slow, fastSm, slowSm)
bottom = math.min(fast, slow, fastSm, slowSm)

crossUp    = ta.crossover(fast, slow)
crossDn    = ta.crossunder(fast, slow)
bsUp       = ta.barssince(crossUp)
bsDn       = ta.barssince(crossDn)
upCrossBar = bar_index - bsUp
dnCrossBar = bar_index - bsDn

// ───────── Drawing container per trade ─────────
type TradeDraw
    array<label> labels
    array<line>  lines
    array<box>   boxes

deleteTrade(TradeDraw t) =>
    for l in t.labels
        label.delete(l)
    for l in t.lines
        line.delete(l)
    for b in t.boxes
        box.delete(b)

// ───────── State ─────────
var int   dir       = 0        // 1 = long, -1 = short, 0 = flat
var int   pending   = 0
var int   pendCross = na
var int   lastBuyX  = na
var int   lastSellX = na
var int   entryBar  = na
var float entry     = na
var float sl        = na
var float slOrig    = na
var float finalTp   = na
var int   tpHit     = 0
var bool  beDone    = false

var line  slLn  = na
var line  enLn  = na
var label slTag = na
var label enTag = na
var array<float> tps    = array.new<float>()
var array<line>  tpLns  = array.new<line>()
var array<label> tpTags = array.new<label>()

var TradeDraw        cur     = na
var array<TradeDraw> history = array.new<TradeDraw>()

// stats
var int   nTrades = 0
var int   nFinal  = 0
var int   nSL     = 0
var int   nBE     = 0
var int   nTrail  = 0
var int   nEMA    = 0
var int   nWins   = 0
var float netPts  = 0.0
var array<int> tpCount = array.new<int>(5, 0)

fmt(x) => str.tostring(x, format.mintick)

// Faded SL / TP zones (vertical strips, strongest at entry, fading to the right)
drawZone(array<box> bx, int left, int right, float e, float s, float t, int n, color cS, color cT) =>
    for b in bx
        box.delete(b)
    array.clear(bx)
    w = math.max(1, right - left)
    for i = 0 to n - 1
        x1 = left + math.round(w * i / n)
        x2 = left + math.round(w * (i + 1) / n)
        tr = n > 1 ? 78 + math.round(19.0 * i / (n - 1)) : 85
        array.push(bx, box.new(x1, math.max(e, s), x2, math.min(e, s), border_width = 0,
             border_color = color.new(cS, 100), bgcolor = color.new(cS, tr)))
        array.push(bx, box.new(x1, math.max(e, t), x2, math.min(e, t), border_width = 0,
             border_color = color.new(cT, 100), bgcolor = color.new(cT, tr)))

// Move lines + price tags to the right edge
moveLevels(int right) =>
    line.set_x2(slLn, right)
    line.set_x2(enLn, right)
    label.set_x(slTag, right)
    label.set_x(enTag, right)
    for l in tpLns
        line.set_x2(l, right)
    for t in tpTags
        label.set_x(t, right)

// Redraw SL line/tag after BE or trailing
updateSlDraw(float v, string suffix) =>
    line.set_y1(slLn, v)
    line.set_y2(slLn, v)
    line.set_style(slLn, line.style_dashed)
    label.set_y(slTag, v)
    label.set_text(slTag, "Stop Loss: " + fmt(v) + " " + suffix)

bool buyFired  = false
bool sellFired = false

// ───────── 1) Enter at open of the candle after the signal ─────────
if pending != 0 and dir == 0
    d       = pending
    e       = open
    s       = d == 1 ? low[slBack] - slBuf : high[slBack] + slBuf
    validSL = d == 1 ? s < e : s > e
    if validSL
        dir      := d
        entry    := e
        sl       := s
        slOrig   := s
        tpHit    := 0
        beDone   := false
        entryBar := bar_index
        if d == 1
            lastBuyX := pendCross
        else
            lastSellX := pendCross

        cur := TradeDraw.new(array.new<label>(), array.new<line>(), array.new<box>())
        right = bar_index + projBars

        // Buy / Sell tag on the entry candle
        array.push(cur.labels, label.new(bar_index, d == 1 ? low : high, d == 1 ? "Buy" : "Sell",
             style = d == 1 ? label.style_label_up : label.style_label_down,
             color = d == 1 ? tpCol : slCol, textcolor = color.white, size = size.small))

        // SL + entry lines and tags
        slLn  := line.new(bar_index, sl,    right, sl,    color = slCol, width = 1)
        enLn  := line.new(bar_index, entry, right, entry, color = enCol, width = 1)
        slTag := label.new(right, sl,    "Stop Loss: " + fmt(sl), style = label.style_label_left,
             color = slCol, textcolor = color.white, size = size.small)
        enTag := label.new(right, entry, "Entry: " + fmt(entry),  style = label.style_label_left,
             color = enCol, textcolor = color.white, size = size.small)
        array.push(cur.lines, slLn)
        array.push(cur.lines, enLn)
        array.push(cur.labels, slTag)
        array.push(cur.labels, enTag)

        // TP1..TPn lines and tags
        dists = array.from(tp1, tp2, tp3, tp4, tp5)
        array.clear(tps)
        array.clear(tpLns)
        array.clear(tpTags)
        for i = 0 to numTP - 1
            lvl = e + d * array.get(dists, i)
            ln  = line.new(bar_index, lvl, right, lvl, color = tpCol, width = 1)
            tg  = label.new(right, lvl, "Take Profit " + str.tostring(i + 1) + ": " + fmt(lvl),
                 style = label.style_label_left, color = tpCol, textcolor = color.white, size = size.small)
            array.push(tps, lvl)
            array.push(tpLns, ln)
            array.push(tpTags, tg)
            array.push(cur.lines, ln)
            array.push(cur.labels, tg)
        finalTp := array.get(tps, numTP - 1)

        if showZones
            drawZone(cur.boxes, bar_index, right, entry, slOrig, finalTp, strips, slCol, tpCol)
    pending := 0

// ───────── 2) Manage open trade ─────────
if dir != 0
    float  exitPx  = na
    string exitTag = ""
    hitSL = dir == 1 ? low <= sl : high >= sl
    if hitSL                                   // SL checked first (conservative)
        exitPx  := sl
        locked  = (sl - entry) * dir
        exitTag := locked > 0 ? "TRAIL SL" : locked == 0 ? "BE" : "SL"
    else
        // TP levels reached this candle
        if tpHit < numTP
            for i = tpHit to numTP - 1
                lvl     = array.get(tps, i)
                reached = dir == 1 ? high >= lvl : low <= lvl
                if not reached
                    break
                tpHit := i + 1
                array.set(tpCount, i, array.get(tpCount, i) + 1)
                if i < numTP - 1
                    array.push(cur.labels, label.new(bar_index, lvl, "TP" + str.tostring(i + 1) + " ✓",
                         style = dir == 1 ? label.style_label_down : label.style_label_up,
                         color = tpCol, textcolor = color.white, size = size.tiny))
                if trailSL
                    newSL = i == 0 ? entry + dir * beOff : array.get(tps, i - 1)
                    if (newSL - sl) * dir > 0
                        sl     := newSL
                        beDone := true
                        updateSlDraw(sl, i == 0 ? "(BE)" : "(Trail TP" + str.tostring(i) + ")")
        if tpHit >= numTP
            exitPx  := finalTp
            exitTag := "TP" + str.tostring(numTP)
        else
            emaExit = switch exitMode
                "EMA 13"      => dir == 1 ? close < fast : close > fast
                "EMA 13 & 21" => dir == 1 ? close < fast and close < slow : close > fast and close > slow
                "All 4 lines" => dir == 1 ? close < bottom : close > top
                => false
            if emaExit
                exitPx  := close
                exitTag := "EMA EXIT"

    if na(exitPx)
        // still open: keep zone projected to the right
        right = math.max(bar_index, entryBar + projBars)
        moveLevels(right)
        if showZones
            drawZone(cur.boxes, entryBar, right, entry, slOrig, finalTp, strips, slCol, tpCol)
        // breakeven
        if beTrig > 0 and not beDone
            moved = dir == 1 ? high - entry >= beTrig : entry - low >= beTrig
            if moved
                beDone := true
                beLvl  = entry + dir * beOff
                if (beLvl - sl) * dir > 0
                    sl := beLvl
                    updateSlDraw(sl, "(BE)")
    else
        // closed: cut the zone at the exit candle
        moveLevels(bar_index)
        if showZones
            drawZone(cur.boxes, entryBar, bar_index, entry, slOrig, finalTp, strips, slCol, tpCol)

        pnl = (exitPx - entry) * dir
        nTrades += 1
        netPts  += pnl
        if pnl > 0
            nWins += 1
        if str.startswith(exitTag, "TP")
            nFinal += 1
        else if exitTag == "SL"
            nSL += 1
        else if exitTag == "BE"
            nBE += 1
        else if exitTag == "TRAIL SL"
            nTrail += 1
        else
            nEMA += 1
        col = str.startswith(exitTag, "TP") ? tpCol : exitTag == "SL" ? slCol : exitTag == "BE" ? enCol :
             exitTag == "TRAIL SL" ? color.teal : color.orange
        array.push(cur.labels, label.new(bar_index, exitPx, exitTag + " " + (pnl >= 0 ? "+" : "") + str.tostring(pnl, "#.##"),
             style = dir == 1 ? label.style_label_down : label.style_label_up,
             color = col, textcolor = color.white, size = size.tiny))

        // keep only the last N closed trades on the chart
        array.push(history, cur)
        if keepPast > 0
            while array.size(history) > keepPast
                deleteTrade(array.shift(history))
        cur     := na
        dir     := 0
        entry   := na
        sl      := na
        finalTp := na
        tpHit   := 0

// ───────── 3) Signals on candle close ─────────
newBuyX  = na(lastBuyX)  or upCrossBar != lastBuyX
newSellX = na(lastSellX) or dnCrossBar != lastSellX
buySig  = allowBuy  and fast > slow and close > top    and not na(bsUp) and bsUp <= validBars - 1 and newBuyX
sellSig = allowSell and fast < slow and close < bottom and not na(bsDn) and bsDn <= validBars - 1 and newSellX

if dir == 0 and barstate.isconfirmed
    if buySig
        pending   := 1
        pendCross := upCrossBar
        buyFired  := true
    else if sellSig
        pending   := -1
        pendCross := dnCrossBar
        sellFired := true

alertcondition(buyFired,  "EMA 13/21 BUY",  "EMA 13/21 BUY signal on {{ticker}} — entry next candle open")
alertcondition(sellFired, "EMA 13/21 SELL", "EMA 13/21 SELL signal on {{ticker}} — entry next candle open")

// ───────── Stats ─────────
var table st = table.new(position.top_right, 2, 10, bgcolor = color.new(color.black, 20), border_width = 1)
if showStats and barstate.islast
    winRate = nTrades > 0 ? nWins / nTrades * 100 : 0.0
    netUsd  = netPts * lotSize * contract
    hits = ""
    for i = 0 to numTP - 1
        hits += str.tostring(array.get(tpCount, i)) + (i < numTP - 1 ? " / " : "")
    table.cell(st, 0, 0, "Trades", text_color = color.white)
    table.cell(st, 1, 0, str.tostring(nTrades), text_color = color.white)
    table.cell(st, 0, 1, "TP1–TP" + str.tostring(numTP) + " hits", text_color = color.white)
    table.cell(st, 1, 1, hits, text_color = tpCol)
    table.cell(st, 0, 2, "Closed at TP" + str.tostring(numTP), text_color = color.white)
    table.cell(st, 1, 2, str.tostring(nFinal), text_color = tpCol)
    table.cell(st, 0, 3, "SL", text_color = color.white)
    table.cell(st, 1, 3, str.tostring(nSL), text_color = slCol)
    table.cell(st, 0, 4, "BE", text_color = color.white)
    table.cell(st, 1, 4, str.tostring(nBE), text_color = enCol)
    table.cell(st, 0, 5, "Trail SL", text_color = color.white)
    table.cell(st, 1, 5, str.tostring(nTrail), text_color = color.teal)
    table.cell(st, 0, 6, "EMA exit", text_color = color.white)
    table.cell(st, 1, 6, str.tostring(nEMA), text_color = color.orange)
    table.cell(st, 0, 7, "Win rate", text_color = color.white)
    table.cell(st, 1, 7, str.tostring(winRate, "#.#") + "%", text_color = color.white)
    table.cell(st, 0, 8, "Net ($ move)", text_color = color.white)
    table.cell(st, 1, 8, str.tostring(netPts, "#.##"), text_color = netPts >= 0 ? tpCol : slCol)
    table.cell(st, 0, 9, "Net @ " + str.tostring(lotSize) + " lot", text_color = color.white)
    table.cell(st, 1, 9, "$" + str.tostring(netUsd, "#.##"), text_color = netUsd >= 0 ? tpCol : slCol)
````

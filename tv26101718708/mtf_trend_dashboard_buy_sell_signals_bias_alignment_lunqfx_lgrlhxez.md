# MTF Trend Dashboard, Buy Sell Signals & Bias Alignment [LunqFX]

- url: https://www.tradingview.com/script/lgrlHXeZ-MTF-Trend-Dashboard-Buy-Sell-Signals-Bias-Alignment-LunqFX/
- type: indicator
- pine_id: PUB;e338b68799a243d4a2f9e675c46ad8ff
- version: 1.0

## Description

MTF Trend Dashboard shows the trend of six timeframes in one panel — from 5 minutes to the weekly — and prints buy and sell signals with the stop loss and two take-profit targets when the higher timeframes agree. Multi timeframe bias for forex, gold (XAUUSD), indices and crypto.

Most multi-timeframe dashboards colour each cell by a moving average and stop there. This one reads market structure on every timeframe: the trend is up after a candle closes above the last swing high and stays up until a candle closes below the last swing low. Because the bias comes from structure, every timeframe also has a concrete price that would flip it — the swing that defends the trend — and the dashboard prints that FLIP level for each timeframe. You see not only which way each timeframe points, but exactly where it would stop pointing that way.

Included: structure bias on six timeframes, the flip level of each, an alignment score, flip levels of two higher timeframes drawn on the chart, buy and sell signals when the chart's structure breaks in the direction the higher timeframes agree on, a stop and two targets for every signal, and alerts.

❶ THE BIAS ENGINE

The same engine runs on all six timeframes. Swing highs and lows are confirmed pivots with a fixed number of bars on each side. A close above the last swing high turns the bias up; a close below the last swing low turns it down; until either happens the bias stays as it was. A timeframe that has not yet broken any swing reads FLAT. The bias of each timeframe changes only when a candle of that timeframe has closed.

The FLIP level is the swing that would reverse the current bias: the last swing low while the bias is up, the last swing high while it is down.

❷ ALIGNMENT

The header counts how many timeframes at or above the chart's agree — "▲ BULLISH 5/6". Timeframes below the chart's are shown as "below chart" and are not counted, because a higher-timeframe chart cannot read them honestly.

❸ SIGNALS

A buy signal needs two things on the same closed bar. First, the higher timeframes — only those strictly above the chart's — agree: at least the number you set (3 by default) are bullish, and more are bullish than bearish. Second, the chart itself breaks structure upward: a candle closes above the chart's last swing high. Sell is the mirror. Each swing can trigger only once.

Stop — beyond the swing on the other side of the break, plus an ATR buffer, and never tighter than a minimum distance in ATR. If the stop would be wider than the maximum distance in ATR, the signal is skipped. Targets — TP1 and TP2 at 1R and 2R of that stop by default, both adjustable.

The signal label shows how many higher timeframes agreed, for example "▲ BUY 3/4 HTF". The plan is followed until the stop or TP2; targets reached are ticked on their tags.

HOW TO USE IT

1 — Read the header first. A bullish header with most timeframes agreeing is the environment for buys; a mixed header means the timeframes disagree and no signal will print.

2 — Use the FLIP column as your invalidation map. If price is close to the 4H flip level, the 4H trend is close to turning — a buy taken there has less room.

3 — Take signals in the direction of the header. The bottom line of the panel tells you what the tool is waiting for: "Higher TFs bullish · wait for break up".

4 — Choose the timeframes for your style. Scalpers can use 1m–4H, swing traders 1H–monthly. Only timeframes above the chart count for signals.

HOW IT WORKS

The structure engine is one function passed to request.security once per timeframe; each call keeps its own swing highs, swing lows and bias, and only updates them on a closed bar of its own timeframe. The chart's structure is tracked separately as the trigger. On every closed chart bar the script counts the agreeing higher timeframes, checks for a break of the chart's swing, sizes the stop from the opposite swing and the ATR limits, and places the targets as multiples of that stop. Requests use lookahead off.

LIMITATIONS — read before relying on it

▸ Structure bias reacts late by design: a swing is only confirmed several bars after it forms, and the bias turns only on a close beyond it. Sharp V-shaped reversals are recognised after the move has started.

▸ In ranges, structure breaks both ways. The higher timeframes then disagree and signals stop, but the chart timeframe can still flip back and forth.

▸ Higher-timeframe bias updates when that timeframe's candle closes. During a 4H or daily candle the dashboard shows the bias as of the last closed candle.

▸ Targets are fixed multiples of the stop and do not look at the next level of support or resistance.

▸ When one bar touches both the stop and a target, it is recorded as stopped.

▸ Signals appear on the close of the breaking bar. Between that close and your order, price can already have moved.

▸ The ticks on targets describe individual signals. They are not collected into a win rate, and nothing here is a statement about future results.

WHY IT IS ORIGINAL

Multi-timeframe dashboards are common, and almost all of them measure each timeframe with a moving average. This one measures structure, which gives every timeframe a defined invalidation price — the flip level — that an average cannot provide. The dashboard turns that into a map of where each timeframe's trend would end, and the signals use it as a filter for the chart's own structure breaks.

It is not a version of my other scripts. Market Structure shows swing points and breaks on the chart's timeframe only. Trade Planner trades pullbacks to a moving average and sizes the position. This script measures structure across six timeframes and trades the chart's breaks only when they agree.

SETTINGS

▸ Timeframes — six timeframes and the swing length used on all of them. ▸ Signals — on/off, how many higher timeframes must agree, chart swing length, stop buffer, minimum and maximum stop in ATR, TP1 and TP2 in R. ▸ Visuals — five candle palettes plus off, glow candles (each body drawn in four bands that brighten towards the close; colours shift one shade deeper on a light chart), flip levels of timeframes 4 and 5 on the chart, text size of signals and levels, signals kept on the chart, dashboard position and text size.

ALERTS — buy and sell (the message carries entry, stop, both targets and the number of agreeing timeframes), target reached, stop reached, all timeframes bullish, all timeframes bearish. Create them as "Any alert() function call", or use the four classic alert conditions.

NON-REPAINTING — every timeframe's bias changes only after that timeframe's candle closes; signals, stops and targets are decided on closed bars, and a printed signal never moves.

This indicator is an educational tool for reading multi-timeframe trend. It is not financial advice and it does not predict price. Always confirm with your own analysis and manage your risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  MTF Trend Dashboard, Buy Sell Signals & Bias Alignment [LunqFX]
// ----------------------------------------------------------------------------
//  Most multi-timeframe dashboards colour a cell by an EMA and stop there.
//  This one reads MARKET STRUCTURE on six timeframes — the trend holds until
//  price closes through the swing that defends it — and for every timeframe
//  prints that defending price: the FLIP level where its bias would turn.
//
//  When the higher timeframes agree and the chart's own structure breaks in
//  the same direction, a signal is printed with its stop and two targets.
//
//  NON-REPAINTING: every timeframe's bias changes only when that timeframe's
//  bar has closed; signals, stops and targets are decided on closed bars.
// ============================================================================
indicator("MTF Trend Dashboard, Buy Sell Signals & Bias Alignment [LunqFX]",
     "MTF Trend Dashboard", overlay = true,
     max_boxes_count = 40, max_lines_count = 80, max_labels_count = 120)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
UP    = #00F5D4
DN    = #FF2E88
GOLD  = #FFD250
RISK  = #FF4D6D
CARD  = #131A24
CARD2 = #1B2431
HEAD  = #0E141D
TXT   = #F1F5F9
MUTE  = #94A3B8

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gT     = "Timeframes"
tf1    = input.timeframe("5",   "Timeframe 1", group = gT)
tf2    = input.timeframe("15",  "Timeframe 2", group = gT)
tf3    = input.timeframe("60",  "Timeframe 3", group = gT)
tf4    = input.timeframe("240", "Timeframe 4", group = gT)
tf5    = input.timeframe("D",   "Timeframe 5", group = gT)
tf6    = input.timeframe("W",   "Timeframe 6", group = gT)
strLen = input.int(5, "Structure swing length", minval = 2, maxval = 30, group = gT, tooltip = "Bars on each side that make a swing high or low on every timeframe. The bias turns when a candle CLOSES beyond the last swing.")

gS     = "Signals"
sigOn  = input.bool(true, "Buy / sell signals", group = gS)
need   = input.int(3, "Higher timeframes that must agree", minval = 1, maxval = 5, group = gS, tooltip = "Counted only among the dashboard timeframes ABOVE the chart's. If fewer exist, all of them must agree.")
chLen  = input.int(5, "Chart structure swing length", minval = 2, maxval = 30, group = gS, tooltip = "The swing on your chart whose break triggers the signal.")
slBuf  = input.float(0.20, "Stop buffer beyond the swing (× ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gS)
minStp = input.float(0.50, "Minimum stop (× ATR)", minval = 0.1, maxval = 3.0, step = 0.05, group = gS)
maxStp = input.float(3.0, "Maximum stop (× ATR)", minval = 0.5, maxval = 10.0, step = 0.25, group = gS, tooltip = "A signal whose stop would be wider than this is skipped.")
r1     = input.float(1.0, "TP1 (R)", minval = 0.25, maxval = 20, step = 0.25, group = gS)
r2     = input.float(2.0, "TP2 (R)", minval = 0.25, maxval = 20, step = 0.25, group = gS)

gV      = "Visuals"
candSty = input.string("Neon Bloom", "Candle palette", options = ["Neon Bloom","Midnight Cyan","Vibrant Neon","Classic Soft","Cool Blue","Off"], group = gV)
candGlw = input.bool(true, "Glow candles", group = gV, tooltip = "Each body is drawn in four bands that brighten towards the close, so the candle reads in the direction it moved. Off = flat translucent bodies.")
flipOn  = input.bool(true, "Flip levels of timeframes 4 and 5 on the chart", group = gV)
tagSize = input.string("Large", "Signal and level text", options = ["Normal","Large","Huge"], group = gV)
keepN   = input.int(3, "Signals kept on chart", minval = 1, maxval = 10, group = gV)
hudPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)
hudSize = input.string("Large", "Dashboard text", options = ["Normal","Large","Huge"], group = gV)

szOf(string s) =>
    switch s
        "Normal" => size.normal
        "Huge"   => size.huge
        => size.large
tagSz = szOf(tagSize)
hudSz = szOf(hudSize)

// ─────────────────────────────────────────────────────────────────────────
//  STRUCTURE BIAS — one engine, run on every timeframe
//  The trend is up after a close above the last swing high and stays up
//  until a close below the last swing low. The swing that would flip it is
//  returned with it. State changes only on a closed bar of THAT timeframe.
// ─────────────────────────────────────────────────────────────────────────
f_bias(int len) =>
    ph = ta.pivothigh(len, len)
    pl = ta.pivotlow(len, len)
    var float sh = na
    var float sl = na
    var int   st = 0
    if barstate.isconfirmed
        if not na(ph)
            sh := ph
        if not na(pl)
            sl := pl
        if not na(sh) and close > sh
            st := 1
        if not na(sl) and close < sl
            st := -1
    flip = st == 1 ? sl : st == -1 ? sh : float(na)
    [st, flip]

[b1, f1] = request.security(syminfo.tickerid, tf1, f_bias(strLen), lookahead = barmerge.lookahead_off)
[b2, f2] = request.security(syminfo.tickerid, tf2, f_bias(strLen), lookahead = barmerge.lookahead_off)
[b3, f3] = request.security(syminfo.tickerid, tf3, f_bias(strLen), lookahead = barmerge.lookahead_off)
[b4, f4] = request.security(syminfo.tickerid, tf4, f_bias(strLen), lookahead = barmerge.lookahead_off)
[b5, f5] = request.security(syminfo.tickerid, tf5, f_bias(strLen), lookahead = barmerge.lookahead_off)
[b6, f6] = request.security(syminfo.tickerid, tf6, f_bias(strLen), lookahead = barmerge.lookahead_off)

chartSec = timeframe.in_seconds(timeframe.period)
tfs   = array.from(tf1, tf2, tf3, tf4, tf5, tf6)
bias  = array.from(nz(b1), nz(b2), nz(b3), nz(b4), nz(b5), nz(b6))
flips = array.from(f1, f2, f3, f4, f5, f6)

// a timeframe below the chart's cannot be read honestly from it — skipped
// "used": at or above the chart · "higher": strictly above it
nUsed = 0
uBull = 0
uBear = 0
nHigh = 0
hBull = 0
hBear = 0
for i = 0 to 5
    sec = timeframe.in_seconds(array.get(tfs, i))
    b   = array.get(bias, i)
    if sec >= chartSec
        nUsed += 1
        uBull += b == 1 ? 1 : 0
        uBear += b == -1 ? 1 : 0
    if sec > chartSec
        nHigh += 1
        hBull += b == 1 ? 1 : 0
        hBear += b == -1 ? 1 : 0
needNow = math.max(1, math.min(need, nHigh))
htfLong  = nHigh > 0 and hBull >= needNow and hBull > hBear
htfShort = nHigh > 0 and hBear >= needNow and hBear > hBull

tfName(string tf) =>
    sec = timeframe.in_seconds(tf)
    sec < 60 ? tf + "s" : sec < 3600 ? str.tostring(math.round(sec / 60)) + "m" : sec < 86400 ? str.tostring(math.round(sec / 3600)) + "H" : sec < 604800 ? "D" : sec < 2419200 ? "W" : "M"

px(float v) => str.tostring(v, format.mintick)

// ─────────────────────────────────────────────────────────────────────────
//  CANDLES — neon pair, translucent body against a solid edge
// ─────────────────────────────────────────────────────────────────────────
// On a light chart the screen-bright neon washes out, so the same palette is
// drawn one shade deeper. The theme is read from the chart's own background.
bgLum   = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
isLight = bgLum > 128
cBull = switch candSty
    "Midnight Cyan" => isLight ? #12A36B : #34E89E
    "Vibrant Neon"  => isLight ? #00977A : #00E5B0
    "Classic Soft"  => isLight ? #2E8B67 : #3FB68B
    "Cool Blue"     => isLight ? #2F6FD6 : #4C9AFF
    => isLight ? #00A896 : #00F5D4
cBear = switch candSty
    "Midnight Cyan" => isLight ? #D92F5F : #FF4D7D
    "Vibrant Neon"  => isLight ? #D61A4E : #FF2E63
    "Classic Soft"  => isLight ? #C0435A : #E0556B
    "Cool Blue"     => isLight ? #5E6878 : #8A94A6
    => isLight ? #E0115F : #FF2E88
cEdge  = close >= open ? cBull : cBear
candOn = candSty != "Off"
glowOn = candOn and candGlw
NONE   = color.new(color.black, 100)

// ── flat bodies: translucent fill against a solid edge ──
plotcandle(candOn and not glowOn ? open : na, high, low, close, "Candles", color = color.new(cEdge, 24), wickcolor = color.new(cEdge, 18), bordercolor = cEdge)

// ── glow bodies ──
// 1. a body in the chart's background colour hides the native candle, so the
//    translucent bands below show the chart, not a second candle
// 2. four bands from open to close, the band at the close the brightest
// 3. the wick and a fine outline on top
bQ = (close - open) / 4.0
plotcandle(glowOn ? open : na, glowOn ? math.max(open, close) : na, glowOn ? math.min(open, close) : na, glowOn ? close : na, "Glow mask", color = chart.bg_color, wickcolor = NONE, bordercolor = chart.bg_color, display = display.pane)
plotcandle(glowOn ? open : na, glowOn ? math.max(open, open + bQ) : na, glowOn ? math.min(open, open + bQ) : na, glowOn ? open + bQ : na, "Glow band 1", color = color.new(cEdge, 78), wickcolor = NONE, bordercolor = NONE, display = display.pane)
plotcandle(glowOn ? open + bQ : na, glowOn ? math.max(open + bQ, open + 2 * bQ) : na, glowOn ? math.min(open + bQ, open + 2 * bQ) : na, glowOn ? open + 2 * bQ : na, "Glow band 2", color = color.new(cEdge, 58), wickcolor = NONE, bordercolor = NONE, display = display.pane)
plotcandle(glowOn ? open + 2 * bQ : na, glowOn ? math.max(open + 2 * bQ, open + 3 * bQ) : na, glowOn ? math.min(open + 2 * bQ, open + 3 * bQ) : na, glowOn ? open + 3 * bQ : na, "Glow band 3", color = color.new(cEdge, 36), wickcolor = NONE, bordercolor = NONE, display = display.pane)
plotcandle(glowOn ? open + 3 * bQ : na, glowOn ? math.max(open + 3 * bQ, close) : na, glowOn ? math.min(open + 3 * bQ, close) : na, glowOn ? close : na, "Glow band 4", color = color.new(cEdge, 8), wickcolor = NONE, bordercolor = NONE, display = display.pane)
plotcandle(glowOn ? open : na, glowOn ? high : na, glowOn ? low : na, glowOn ? close : na, "Glow wick", color = NONE, wickcolor = color.new(cEdge, 10), bordercolor = color.new(cEdge, 30), display = display.pane)

// ─────────────────────────────────────────────────────────────────────────
//  CHART STRUCTURE — the trigger
// ─────────────────────────────────────────────────────────────────────────
atr = ta.atr(14)
cph = ta.pivothigh(chLen, chLen)
cpl = ta.pivotlow(chLen, chLen)
var float cSH   = na
var float cSL   = na
var bool  cSHup = false     // the current swing high has already been broken
var bool  cSLdn = false
if not na(cph)
    cSH   := cph
    cSHup := false
if not na(cpl)
    cSL   := cpl
    cSLdn := false

// stop beyond the opposite swing the break leaves behind, never tighter than
// the minimum; a stop wider than the maximum cancels the signal
lo10    = ta.lowest(low, 10)
hi10    = ta.highest(high, 10)
anchorL = na(cSL) ? lo10 : math.min(cSL, low)
anchorH = na(cSH) ? hi10 : math.max(cSH, high)
stopL   = math.min(anchorL - atr * slBuf, close - atr * minStp)
stopS   = math.max(anchorH + atr * slBuf, close + atr * minStp)
okL     = close - stopL <= atr * maxStp
okS     = stopS - close <= atr * maxStp

// ─────────────────────────────────────────────────────────────────────────
//  SIGNALS AND THE OPEN PLAN
// ─────────────────────────────────────────────────────────────────────────
var int   tDir   = 0
var float tEntry = na
var float tSL    = na
var float tTP1   = na
var float tTP2   = na
var int   tBar   = na
var int   tStage = 0           // 1 after TP1
var string lastOut = ""

var box   bRisk = na
var box   bRew  = na
var line  l1 = na
var line  l2 = na
var label kSL = na
var label k1  = na
var label k2  = na
var array<box>   allB = array.new<box>()
var array<line>  allL = array.new<line>()
var array<label> allK = array.new<label>()

longSig  = false
shortSig = false
hitTP1   = false
hitTP2   = false
hitSL    = false

closePlan(string how) =>
    box.set_right(bRisk, bar_index)
    box.set_right(bRew, bar_index)
    line.set_x2(l1, bar_index)
    line.set_x2(l2, bar_index)
    for k in array.from(kSL, k1, k2)
        label.set_x(k, bar_index)
    how

if barstate.isconfirmed
    // ── 1. the open plan, from the bar after the signal ──
    if tDir != 0 and bar_index > tBar
        slHit = tDir == 1 ? low <= tSL : high >= tSL
        h1 = tStage < 1 and (tDir == 1 ? high >= tTP1 : low <= tTP1)
        h2 = tDir == 1 ? high >= tTP2 : low <= tTP2
        // stop first: when one bar spans stop and target, the honest reading
        // is the stop
        if slHit
            hitSL := true
            label.set_text(kSL, "STOPPED  " + px(tSL))
            lastOut := closePlan("stopped")
            tDir := 0
        else
            if h1
                tStage := 1
                hitTP1 := true
                label.set_text(k1, "TP1 ✓  " + px(tTP1))
            if h2
                hitTP2 := true
                label.set_text(k2, "TP2 ✓  " + px(tTP2))
                lastOut := closePlan("TP2 reached")
                tDir := 0
        if tDir != 0
            xr = bar_index + 3
            box.set_right(bRisk, xr)
            box.set_right(bRew, xr)
            line.set_x2(l1, xr)
            line.set_x2(l2, xr)
            for k in array.from(kSL, k1, k2)
                label.set_x(k, xr)

    // ── 2. the chart breaks structure ──
    bosUp = not na(cSH) and not cSHup and close > cSH
    bosDn = not na(cSL) and not cSLdn and close < cSL
    if bosUp
        cSHup := true
    if bosDn
        cSLdn := true

    goLong  = sigOn and bosUp and htfLong and okL and tDir != 1
    goShort = sigOn and bosDn and htfShort and okS and tDir != -1

    if goLong or goShort
        if tDir != 0
            lastOut := closePlan("closed on opposite signal")
        d = goLong ? 1 : -1
        e = close
        s = goLong ? stopL : stopS
        risk = math.abs(e - s)
        tDir := d
        tEntry := e
        tSL := s
        tTP1 := e + d * risk * r1
        tTP2 := e + d * risk * r2
        tBar := bar_index
        tStage := 0
        longSig := goLong
        shortSig := goShort

        col = d == 1 ? UP : DN
        xr  = bar_index + 3
        agr = (d == 1 ? hBull : hBear)
        bRisk := box.new(bar_index, math.max(e, s), xr, math.min(e, s), border_color = color.new(RISK, 45), bgcolor = color.new(RISK, 84))
        bRew  := box.new(bar_index, math.max(e, tTP2), xr, math.min(e, tTP2), border_color = color.new(col, 55), bgcolor = color.new(col, 90))
        l1 := line.new(bar_index, tTP1, xr, tTP1, color = color.new(GOLD, 15), style = line.style_dotted, width = 2)
        l2 := line.new(bar_index, tTP2, xr, tTP2, color = color.new(GOLD, 35), style = line.style_dotted, width = 2)
        kSL := label.new(xr, s,    "SL  " + px(s), style = label.style_label_left, color = HEAD, textcolor = RISK, size = tagSz)
        k1  := label.new(xr, tTP1, "TP1  " + px(tTP1), style = label.style_label_left, color = HEAD, textcolor = GOLD, size = tagSz)
        k2  := label.new(xr, tTP2, "TP2  " + px(tTP2), style = label.style_label_left, color = HEAD, textcolor = GOLD, size = tagSz)
        kE  = label.new(bar_index, d == 1 ? low : high, (d == 1 ? "▲ BUY  " : "▼ SELL  ") + str.tostring(agr) + "/" + str.tostring(nHigh) + " HTF", yloc = d == 1 ? yloc.belowbar : yloc.abovebar, style = d == 1 ? label.style_label_up : label.style_label_down, color = col, textcolor = d == 1 ? #04211D : #2B0716, size = tagSz)

        for b in array.from(bRisk, bRew)
            array.push(allB, b)
        for l in array.from(l1, l2)
            array.push(allL, l)
        for k in array.from(kSL, k1, k2, kE)
            array.push(allK, k)
        // every signal adds 2 boxes, 2 lines and 4 labels — retire whole ones
        while array.size(allB) > keepN * 2
            box.delete(array.shift(allB))
        while array.size(allL) > keepN * 2
            line.delete(array.shift(allL))
        while array.size(allK) > keepN * 4
            label.delete(array.shift(allK))

// ─────────────────────────────────────────────────────────────────────────
//  FLIP LEVELS ON THE CHART — timeframes 4 and 5
// ─────────────────────────────────────────────────────────────────────────
var line  fl4 = na
var line  fl5 = na
var label fk4 = na
var label fk5 = na
drawFlip(line ln, label lb, float lvl, int b, string tf) =>
    line.delete(ln)
    label.delete(lb)
    line nl  = na
    label nk = na
    if not na(lvl) and b != 0 and timeframe.in_seconds(tf) >= chartSec
        // gold, not the trend colour: a flip level is a line to watch, and it
        // must not be mistaken for a signal's stop or target
        nl := line.new(bar_index - 40, lvl, bar_index + 12, lvl, color = color.new(GOLD, 10), width = 2, style = line.style_dashed)
        nk := label.new(bar_index + 12, lvl, tfName(tf) + " FLIP  " + px(lvl) + (b == 1 ? "  ▲" : "  ▼"), style = label.style_label_left, color = HEAD, textcolor = GOLD, size = tagSz)
    [nl, nk]

if flipOn and barstate.islast
    [n4, k4] = drawFlip(fl4, fk4, f4, nz(b4), tf4)
    fl4 := n4
    fk4 := k4
    [n5, k5] = drawFlip(fl5, fk5, f5, nz(b5), tf5)
    fl5 := n5
    fk5 := k5

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
hudP(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

var table hud = table.new(position.top_right, 3, 9)
if barstate.islast
    table.delete(hud)
    hud := table.new(hudP(hudPos), 3, 9, bgcolor = CARD, border_color = color.new(#28323F, 0), border_width = 1)

    heroBull = uBull > uBear
    heroBear = uBear > uBull
    heroTx = heroBull ? "▲  BULLISH  " + str.tostring(uBull) + "/" + str.tostring(nUsed) : heroBear ? "▼  BEARISH  " + str.tostring(uBear) + "/" + str.tostring(nUsed) : "—  MIXED"
    heroBg = heroBull ? #0A5F55 : heroBear ? #8E1148 : CARD2

    table.cell(hud, 0, 0, "  MTF TREND", text_color = UP, text_size = size.small, text_halign = text.align_left, bgcolor = HEAD)
    table.cell(hud, 1, 0, "BIAS", text_color = MUTE, text_size = size.small, bgcolor = HEAD)
    table.cell(hud, 2, 0, "FLIPS AT  ", text_color = MUTE, text_size = size.small, text_halign = text.align_right, bgcolor = HEAD)
    table.cell(hud, 0, 1, "  " + heroTx + "  ", text_color = color.white, text_size = hudSz, text_halign = text.align_left, bgcolor = heroBg)
    table.merge_cells(hud, 0, 1, 2, 1)

    for i = 0 to 5
        r   = i + 2
        tf  = array.get(tfs, i)
        b   = array.get(bias, i)
        fl  = array.get(flips, i)
        ok  = timeframe.in_seconds(tf) >= chartSec
        bg  = i % 2 == 0 ? CARD : CARD2
        c   = not ok ? color.new(MUTE, 50) : b == 1 ? UP : b == -1 ? DN : MUTE
        bTx = not ok ? "below chart" : b == 1 ? "▲ BULL" : b == -1 ? "▼ BEAR" : "— FLAT"
        table.cell(hud, 0, r, "  " + tfName(tf), text_color = ok ? TXT : color.new(MUTE, 50), text_size = hudSz, text_halign = text.align_left, bgcolor = bg)
        table.cell(hud, 1, r, bTx, text_color = c, text_size = hudSz, bgcolor = bg)
        table.cell(hud, 2, r, (ok and not na(fl) ? px(fl) : "—") + "  ", text_color = ok ? MUTE : color.new(MUTE, 50), text_size = hudSz, text_halign = text.align_right, bgcolor = bg)

    sTx = tDir == 1 ? "▲ LONG  ·  " + (tStage >= 1 ? "TP1 ✓" : "open") : tDir == -1 ? "▼ SHORT  ·  " + (tStage >= 1 ? "TP1 ✓" : "open") : htfLong ? "Higher TFs bullish · wait for break up" : htfShort ? "Higher TFs bearish · wait for break down" : "Higher TFs mixed · no signal"
    sCol = tDir == 1 ? UP : tDir == -1 ? DN : htfLong ? UP : htfShort ? DN : MUTE
    table.cell(hud, 0, 8, "  " + sTx + (tDir == 0 and lastOut != "" ? "  ·  last: " + lastOut : "") + "  ", text_color = sCol, text_size = size.normal, text_halign = text.align_left, bgcolor = HEAD)
    table.merge_cells(hud, 0, 8, 2, 8)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
fullBull = nUsed > 0 and uBull == nUsed
fullBear = nUsed > 0 and uBear == nUsed

planMsg(string side) =>
    syminfo.ticker + " " + side + " @ " + px(tEntry) + " | SL " + px(tSL) + " | TP1 " + px(tTP1) + " | TP2 " + px(tTP2) + " | higher TFs " + str.tostring(side == "BUY" ? hBull : hBear) + "/" + str.tostring(nHigh)

if longSig
    alert("LunqFX MTF Trend: " + planMsg("BUY"), alert.freq_once_per_bar_close)
if shortSig
    alert("LunqFX MTF Trend: " + planMsg("SELL"), alert.freq_once_per_bar_close)
if hitTP1 or hitTP2
    alert("LunqFX MTF Trend: " + syminfo.ticker + (hitTP2 ? " TP2" : " TP1") + " reached", alert.freq_once_per_bar_close)
if hitSL
    alert("LunqFX MTF Trend: " + syminfo.ticker + " stop reached", alert.freq_once_per_bar_close)
if barstate.isconfirmed and fullBull and not fullBull[1]
    alert("LunqFX MTF Trend: " + syminfo.ticker + " all timeframes BULLISH", alert.freq_once_per_bar_close)
if barstate.isconfirmed and fullBear and not fullBear[1]
    alert("LunqFX MTF Trend: " + syminfo.ticker + " all timeframes BEARISH", alert.freq_once_per_bar_close)

alertcondition(longSig,  "Buy signal",  "LunqFX MTF Trend: {{ticker}} {{interval}} BUY")
alertcondition(shortSig, "Sell signal", "LunqFX MTF Trend: {{ticker}} {{interval}} SELL")
alertcondition(fullBull and not fullBull[1], "All timeframes bullish", "LunqFX MTF Trend: {{ticker}} all timeframes bullish")
alertcondition(fullBear and not fullBear[1], "All timeframes bearish", "LunqFX MTF Trend: {{ticker}} all timeframes bearish")
````

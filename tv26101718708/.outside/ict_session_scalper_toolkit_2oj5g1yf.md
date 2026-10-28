# ICT Session Scalper Toolkit

- url: https://www.tradingview.com/script/2oj5G1YF-ICT-Session-Scalper-Toolkit/
- type: indicator
- pine_id: PUB;a1729b7749f84a5eb46caf6702f69f0a
- version: 1.0

## Description

ICT Session Scalper Toolkit
OVERVIEW
A session-scalping framework built on ICT (Inner Circle Trader) concepts. It maps the full workflow of a liquidity-based scalping model onto one chart: the session structure (Asia accumulation → London / New York manipulation → distribution), the liquidity pools that get targeted, the sweep that marks the manipulation, the displacement that confirms it, and the fair-value-gap entry that follows. Each completed sequence is graded A+ / B / C from higher-timeframe confluence.

The model follows the session-scalping process described by funded trader Candice BL in a public interview: wait for the killzone, wait for liquidity to be swept, require displacement and speed, enter on a valid inverted FVG or FVG retrace, cap the stop, target the nearest liquidity with at least 1:2.

Every visual element can be switched on/off and recolored, including all text, so the chart can be as minimal or as detailed as you want.

HOW IT WORKS
Sessions & killzones (New York time). Asia range (18:00-02:00), London killzone (02:00-05:00) and New York killzone (09:00-10:30) are tracked and optionally shaded. By default signals only fire inside a killzone, so no setup is taken before the session's real manipulation window.

Liquidity pools. Swing highs and lows (pivot length configurable) become buyside / sellside pools. Pools within a small ATR-based tolerance merge into equal highs / equal lows, which are drawn thicker. The Asia high/low and previous day high/low are added as named pools. When price trades through a pool it is marked as swept: that is the manipulation leg.

Displacement. A candle whose body exceeds a multiple of the 20-bar average body (default 1.5×) counts as displacement: the "displacement + speed" requirement of the model.

FVG / IFVG engine. Three-candle fair value gaps are tracked (optionally only those created by displacement). A gap becomes a valid inverted FVG only when a candle body closes through it: a wick or partial close is not enough. Retraces into valid IFVGs or displacement FVGs are entry events. Invalidated zones are greyed out, deleted or kept (your choice).

Signal sequence. A long requires, in order: a sellside sweep → bullish displacement within the window (default 30 bars) → a bullish IFVG validation or a retrace into a bullish zone. Shorts mirror this. The stop sits beyond the sweep extreme. If that stop exceeds the cap, the setup is skipped — "if I need a larger stop, it is not the entry". Targets: TP1 = nearest unswept pool, final target = at least the minimum R:R (default 2R).

Stop cap. Auto mode uses fixed point caps on NQ / MNQ (25 London, 40 New York, as in the source model) and an ATR multiple (default 3 × ATR14) on every other symbol, so the logic works on crypto, metals and forex without manual tuning.

Grading (A+ / B / C). Points are added for: entry or stop inside a 1H or daily FVG, proximity to the midnight open / NDOG / NWOG, a recent SMT divergence, a sweep of equal highs/lows, a low-resistance run of pools toward the target, and buying in discount / selling in premium. A point is deducted when obvious liquidity remains behind the entry (the model's C-setup rule). 4+ = A+, 2-3 = B, below = C.

Context levels. Midnight opening price, new day / new week opening gaps (18:00 ET futures reopen), the RTH gap (16:00 close → 9:30 open) with 25 / 50 / 75 % levels, 1H and daily FVGs, and the equilibrium of the recent dealing range.

SMT divergence. Compares new swing extremes on the chart symbol against a correlated symbol (default ES for NQ). Labels can be shown with sweeps only, for all SMTs, or off, and are removed when their level breaks.

Dashboard. Active session, position vs midnight open, premium/discount, RTH gap fill %, long/short setup state (armed / displacement confirmed), active SMT, and a signals / skipped counter that shows when the stop cap is filtering setups.

HOW TO USE IT
Use the 1H / daily FVGs and named pools for bias and targets; use the chart timeframe (1-5 min) for execution.
Treat signals as a checklist: the sweep, displacement and IFVG are marked; the discretionary read of speed on lower timeframes (seconds charts) remains yours.
Grades help size: the source model sizes up on A+ and takes B / C setups with reduced size.
If the dashboard shows many skipped signals, the stop cap is too tight for the instrument: switch the stop cap mode or raise the cap.
SETTINGS
All elements have their own toggle, color and text option: session shading, MOP, NDOG/NWOG, RTH gap and quartiles, liquidity lines and pool text, sweep marks, displacement markers, FVG boxes, FVG text, IFVG text, volume imbalances, HTF FVGs and text, equilibrium, SMT labels, signal labels (full / compact / off), trade lines and the dashboard. A global text size and a per-element label limit keep the chart clean.

NOTES & LIMITATIONS
Signals are evaluated on bar close by default (no repaint). Disabling "Signals on bar close only" shows them intrabar, where they can still change before the bar closes.
HTF FVGs use completed 1H / daily candles; previous day high/low uses the completed prior day only.
Session times assume futures/forex trading hours in New York time; adjust them for other markets.
SMT needs a correlated symbol your data plan can load; if it cannot be loaded SMT switches itself off.
This is a visualization and execution aid for a discretionary model. It is not a trading system, produces no performance statistics and makes no claims about profitability. Past setups shown on the chart do not imply future results.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  ICT Session Scalper Toolkit
//  Session-scalping framework built on ICT concepts: AMD session structure,
//  liquidity pools & sweeps, displacement, FVG / inverted-FVG entries,
//  1H & daily FVG context, midnight open / NDOG / NWOG, RTH gap quartiles,
//  premium/discount, SMT divergence and A+ / B / C setup grading.
//  Every visual element can be switched on/off and recolored in settings.
//  Designed for index futures (NQ/ES) on 1-5 minute charts; works on any
//  intraday timeframe and symbol (use the ATR stop-cap mode off-futures).
//  All session logic runs on America/New_York time.
//  This is a visualization and execution aid, not a trading system.
// ═══════════════════════════════════════════════════════════════════════════
indicator("ICT Session Scalper Toolkit", "ICT-Scalp", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─── Helpers ───────────────────────────────────────────────────────────────
sizeOf(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

styleOf(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

// ═══ Inputs ════════════════════════════════════════════════════════════════
grpGen = "General display"
txtSz  = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpGen)
lblCap = input.int(60, "Max text labels kept per element", minval = 10, maxval = 200, group = grpGen,
     tooltip = "Older labels of the same element are removed first. Keeps the chart clean and protects signal labels.")
TXT = sizeOf(txtSz)

grpS = "Sessions & killzones (New York time)"
tz      = input.string("America/New_York", "Timezone", group = grpS)
sesAsia = input.session("1800-0200", "Asia range",        group = grpS)
sesLKZ  = input.session("0200-0500", "London killzone",   group = grpS)
sesNKZ  = input.session("0900-1030", "New York killzone", group = grpS)
bgAsia  = input.bool(true, "Shade Asia",        inline = "sa", group = grpS)
cAsia   = input.color(color.new(#4dd0e1, 96), "", inline = "sa", group = grpS)
bgLdn   = input.bool(true, "Shade London KZ",   inline = "sl", group = grpS)
cLdn    = input.color(color.new(#f06292, 94), "", inline = "sl", group = grpS)
bgNy    = input.bool(true, "Shade New York KZ", inline = "sn", group = grpS)
cNy     = input.color(color.new(#ffb74d, 94), "", inline = "sn", group = grpS)

grpO = "Opens & gaps"
showMOP  = input.bool(true, "Midnight opening price", inline = "mo", group = grpO)
cMOP     = input.color(color.new(#ff9800, 20), "", inline = "mo", group = grpO)
mopSty   = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], inline = "mo", group = grpO)
mopTxt   = input.bool(true, "MOP text", group = grpO)
showNDOG = input.bool(true, "New day opening gap (NDOG)", inline = "nd", group = grpO)
cNDOG    = input.color(color.new(#ffee58, 92), "", inline = "nd", group = grpO)
showNWOG = input.bool(true, "New week opening gap (NWOG)", inline = "nw", group = grpO)
cNWOG    = input.color(color.new(color.gray, 90), "", inline = "nw", group = grpO)
gapTxt   = input.bool(true, "NDOG / NWOG text", group = grpO)
showRTH  = input.bool(true, "RTH gap (16:00 close → 9:30 open)", inline = "rt", group = grpO)
cRTH     = input.color(color.new(#ffee58, 35), "", inline = "rt", group = grpO)
rthQ     = input.bool(true, "RTH 25 / 50 / 75 % levels", group = grpO)
rthTxt   = input.bool(true, "RTH text", group = grpO)

grpL = "Liquidity pools"
pivLen    = input.int(3, "Swing pivot length", minval = 2, maxval = 10, group = grpL)
eqTolMult = input.float(0.15, "Equal-level tolerance (× ATR50)", minval = 0.05, maxval = 0.5, step = 0.05, group = grpL)
useAsia   = input.bool(true, "Asia high / low as pools", group = grpL)
usePDHL   = input.bool(true, "Previous day high / low as pools", group = grpL)
showLiq   = input.bool(true, "Show liquidity lines", group = grpL)
cBSL      = input.color(color.new(#ef5350, 30), "Buyside",  inline = "lc", group = grpL)
cSSL      = input.color(color.new(#26a69a, 30), "Sellside", inline = "lc", group = grpL)
liqW      = input.int(1, "Line width", minval = 1, maxval = 4, inline = "lw", group = grpL)
eqBold    = input.bool(true, "Thicker for equal highs / lows", inline = "lw", group = grpL)
liqTag    = input.bool(true, "Pool text (AS.H / AS.L / PDH / PDL)", group = grpL)
sweptMode = input.string("Dotted", "Swept lines", options = ["Delete", "Dotted", "Keep solid"], group = grpL)
showSwp   = input.bool(true, "Sweep marks (✗)", group = grpL)

grpDp = "Displacement"
dispMult = input.float(1.5, "Displacement body (× avg body 20)", minval = 1.0, maxval = 4.0, step = 0.1, group = grpDp)
showDisp = input.bool(true, "Show displacement markers", group = grpDp)
cDispUp  = input.color(color.new(#26a69a, 55), "Up",   inline = "dc", group = grpDp)
cDispDn  = input.color(color.new(#ef5350, 55), "Down", inline = "dc", group = grpDp)

grpF = "Fair value gaps (chart timeframe)"
onlyDisp  = input.bool(true, "Only displacement FVGs", group = grpF)
showFVG   = input.bool(true, "Show FVG boxes", group = grpF)
cBullF    = input.color(color.new(#26a69a, 80), "Bullish",  inline = "fc", group = grpF)
cBearF    = input.color(color.new(#ef5350, 80), "Bearish",  inline = "fc", group = grpF)
cInv      = input.color(color.new(#ccff00, 70), "Inverted", inline = "fc", group = grpF)
fvgBorder = input.bool(false, "Box border", group = grpF)
fvgTxt    = input.bool(false, "FVG text", inline = "ft", group = grpF)
ifvgTxt   = input.bool(true, "IFVG text", inline = "ft", group = grpF)
cFTxt     = input.color(#ccff00, "", inline = "ft", group = grpF)
fvgExtend = input.int(300, "Extend boxes for max (bars)", minval = 10, maxval = 2000, group = grpF)
fvgDead   = input.string("Grey out", "Invalidated FVGs", options = ["Delete", "Grey out", "Keep"], inline = "fd", group = grpF)
cDead     = input.color(color.new(color.gray, 92), "", inline = "fd", group = grpF)
showVI    = input.bool(false, "Volume imbalances", inline = "vi", group = grpF)
cVIb      = input.color(color.new(#26a69a, 88), "", inline = "vi", group = grpF)
cVIs      = input.color(color.new(#ef5350, 88), "", inline = "vi", group = grpF)

grpH = "Higher-timeframe FVGs"
show60  = input.bool(true, "1H FVGs", inline = "h1", group = grpH)
cHtf    = input.color(color.new(#66bb6a, 82), "", inline = "h1", group = grpH)
showD   = input.bool(true, "Daily FVGs", inline = "hd", group = grpH)
cDly    = input.color(color.new(#ffee58, 85), "", inline = "hd", group = grpH)
htfTxt  = input.bool(true, "HTF FVG text", inline = "ht", group = grpH)
cHtfTxt = input.color(color.new(color.white, 40), "", inline = "ht", group = grpH)
htfMax  = input.int(8, "Max HTF zones", minval = 1, maxval = 30, group = grpH)
htfFill = input.string("Delete", "Filled HTF zones", options = ["Delete", "Keep"], group = grpH)

grpP = "Premium / discount"
showEq = input.bool(true, "Equilibrium line", inline = "eq", group = grpP)
cEq    = input.color(color.new(color.gray, 45), "", inline = "eq", group = grpP)
eqLen  = input.int(120, "Dealing range lookback (bars)", minval = 30, maxval = 500, group = grpP)

grpM = "SMT divergence"
useSMT   = input.bool(true, "Check SMT vs correlated symbol", group = grpM)
smtSym   = input.symbol("CME_MINI:ES1!", "Correlated symbol", group = grpM)
smtLen   = input.int(20, "Swing window (bars)", minval = 5, maxval = 100, group = grpM)
smtLbl   = input.string("With sweep", "SMT labels", options = ["With sweep", "All", "Off"], inline = "sm", group = grpM)
cSMT     = input.color(#4dd0e1, "", inline = "sm", group = grpM)
smtClear = input.bool(true, "Remove SMT label when its level breaks", group = grpM)

grpG = "Signals & grading"
showSig    = input.bool(true, "Show entry signals", group = grpG)
onlyKZ     = input.bool(true, "Signals only inside killzones", group = grpG)
windowBars = input.int(30, "Max bars: sweep → entry", minval = 5, maxval = 120, group = grpG)
confOnly   = input.bool(true, "Signals on bar close only (no repaint)", group = grpG)
slMode     = input.string("Auto", "Stop cap mode", options = ["Auto", "Points", "ATR multiple"], group = grpG,
     tooltip = "Auto: point caps on NQ / MNQ, ATR multiple on every other symbol. Points: fixed caps per session (tuned for NQ). ATR multiple: scales to any symbol and timeframe.")
maxSL_L    = input.float(25.0, "Max stop (points) — London",   minval = 0.1, group = grpG)
maxSL_N    = input.float(40.0, "Max stop (points) — New York", minval = 0.1, group = grpG)
slAtr      = input.float(3.0,  "Max stop (× ATR14)", minval = 0.5, maxval = 10, step = 0.25, group = grpG)
strictSL   = input.bool(true, "Skip signal if stop exceeds cap", group = grpG)
showSkip   = input.bool(false, "Mark skipped signals (SL > cap)", group = grpG)
minRR      = input.float(2.0, "Minimum R:R for final target", minval = 1.0, maxval = 5.0, step = 0.5, group = grpG)
gradeMin   = input.string("C", "Show grades from", options = ["C", "B", "A+"], group = grpG)
keepSig    = input.int(50, "Signals kept on chart", minval = 1, maxval = 120, group = grpG)

grpSL = "Signal style"
sigStyle  = input.string("Full", "Signal label", options = ["Full", "Compact", "Off"], group = grpSL,
     tooltip = "Full: direction, grade and stop. Compact: grade only (hover for details). Off: no label.")
sigSz     = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = grpSL)
cAplus    = input.color(#ccff00, "A+",    inline = "sc", group = grpSL)
cLongS    = input.color(#26a69a, "Long",  inline = "sc", group = grpSL)
cShortS   = input.color(#ef5350, "Short", inline = "sc", group = grpSL)
sigTr     = input.int(75, "Label transparency", minval = 0, maxval = 100, inline = "st", group = grpSL)
cSigTxt   = input.color(color.white, "Text", inline = "st", group = grpSL)
showTrade = input.bool(true, "Entry / SL / TP lines", group = grpSL)
showTP1   = input.bool(true, "TP1 line (nearest pool)", group = grpSL)
tradeLen  = input.int(20, "Line length (bars)", minval = 3, maxval = 200, group = grpSL)
cEntry    = input.color(color.new(color.white, 40), "Entry", inline = "tl", group = grpSL)
cSLl      = input.color(color.new(#ef5350, 30), "SL",    inline = "tl", group = grpSL)
cTPl      = input.color(color.new(#26a69a, 10), "TP",    inline = "tl", group = grpSL)

grpT = "Dashboard"
showDash = input.bool(true, "Show dashboard", group = grpT)
dashSkip = input.bool(true, "Show skipped-signal counter", group = grpT)
dashPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpT)
dashSz   = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal"], group = grpT)

// ═══ Data (global, unconditional) ══════════════════════════════════════════
[pdHi, pdLo] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[h60c, l60c, t60] = request.security(syminfo.tickerid, "60", [high, low, time])
[hDc, lDc, tD] = request.security(syminfo.tickerid, "D", [high, low, time])
[esH, esL] = request.security(smtSym, timeframe.period, [high, low], ignore_invalid_symbol = true)

atr50 = ta.atr(50)
atr14 = ta.atr(14)
eqTol = atr50 * eqTolMult

pushLbl(array<label> q, label lb) =>
    array.push(q, lb)
    if array.size(q) > lblCap
        old = array.shift(q)
        if not na(old)
            label.delete(old)

// ═══ Sessions & killzones ══════════════════════════════════════════════════
inAsia = not na(time(timeframe.period, sesAsia, tz))
inLKZ  = not na(time(timeframe.period, sesLKZ, tz))
inNKZ  = not na(time(timeframe.period, sesNKZ, tz))
inKZ   = inLKZ or inNKZ
bgcolor(bgLdn and inLKZ ? cLdn : bgNy and inNKZ ? cNy : bgAsia and inAsia ? cAsia : na)

h0 = hour(time, tz)
m0 = minute(time, tz)
newGlobex = h0 == 18 and hour(time[1], tz) != 18   // futures daily reopen 18:00 ET

// ═══ Liquidity engine ══════════════════════════════════════════════════════
var liqPx    = array.new_float()
var liqStart = array.new_int()
var liqBuy   = array.new_bool()   // true = buyside (above price)
var liqSwept = array.new_bool()
var liqEq    = array.new_int()    // touch count (2+ = equal highs / lows)
var liqLine  = array.new_line()
var liqLbl   = array.new_label()
var swpQ     = array.new_label()

addLiq(bool isBuy, float px, int startBar, int eq0, string tag) =>
    merged = false
    if array.size(liqPx) > 0
        for i = 0 to array.size(liqPx) - 1
            if not merged and not array.get(liqSwept, i) and array.get(liqBuy, i) == isBuy and math.abs(array.get(liqPx, i) - px) <= eqTol
                newPx = isBuy ? math.max(array.get(liqPx, i), px) : math.min(array.get(liqPx, i), px)
                array.set(liqPx, i, newPx)
                array.set(liqEq, i, array.get(liqEq, i) + 1)
                ln = array.get(liqLine, i)
                if not na(ln)
                    line.set_y1(ln, newPx)
                    line.set_y2(ln, newPx)
                    line.set_width(ln, eqBold ? liqW + 1 : liqW)
                merged := true
    if not merged
        line  ln = na
        label lb = na
        if showLiq
            ln := line.new(startBar, px, bar_index + 1, px, color = isBuy ? cBSL : cSSL,
                 width = eq0 >= 2 and eqBold ? liqW + 1 : liqW)
        if liqTag and tag != ""
            lb := label.new(startBar, px, tag, style = isBuy ? label.style_label_down : label.style_label_up,
                 color = color.new(color.black, 100), textcolor = isBuy ? cBSL : cSSL, size = TXT)
        array.push(liqPx, px)
        array.push(liqStart, startBar)
        array.push(liqBuy, isBuy)
        array.push(liqSwept, false)
        array.push(liqEq, eq0)
        array.push(liqLine, ln)
        array.push(liqLbl, lb)
    if array.size(liqPx) > 90
        old = array.get(liqLine, 0)
        if not na(old)
            line.delete(old)
        oldL = array.get(liqLbl, 0)
        if not na(oldL)
            label.delete(oldL)
        array.remove(liqPx, 0)
        array.remove(liqStart, 0)
        array.remove(liqBuy, 0)
        array.remove(liqSwept, 0)
        array.remove(liqEq, 0)
        array.remove(liqLine, 0)
        array.remove(liqLbl, 0)

pivH = ta.pivothigh(high, pivLen, pivLen)
pivL = ta.pivotlow(low, pivLen, pivLen)
if not na(pivH)
    addLiq(true, pivH, bar_index - pivLen, 1, "")
if not na(pivL)
    addLiq(false, pivL, bar_index - pivLen, 1, "")

// Asia high/low + previous day H/L injected as named pools
var float aH = na
var float aL = na
if inAsia and not inAsia[1]
    aH := high
    aL := low
else if inAsia
    aH := math.max(nz(aH, high), high)
    aL := math.min(nz(aL, low), low)
if useAsia and inAsia[1] and not inAsia and not na(aH)
    addLiq(true, aH, bar_index - 1, 2, "AS.H")
    addLiq(false, aL, bar_index - 1, 2, "AS.L")
if usePDHL and newGlobex and not na(pdHi)
    addLiq(true, pdHi, bar_index, 2, "PDH")
    addLiq(false, pdLo, bar_index, 2, "PDL")

markSwept(int i) =>
    ln = array.get(liqLine, i)
    lb = array.get(liqLbl, i)
    if sweptMode == "Delete"
        if not na(ln)
            line.delete(ln)
            array.set(liqLine, i, line(na))
        if not na(lb)
            label.delete(lb)
            array.set(liqLbl, i, label(na))
    else if not na(ln)
        line.set_x2(ln, bar_index)
        if sweptMode == "Dotted"
            line.set_style(ln, line.style_dotted)

// sweep scan — the manipulation leg of AMD
sweptSSL = false
sweptBSL = false
int sslSweepEq = 1
int bslSweepEq = 1
if array.size(liqPx) > 0
    for i = 0 to array.size(liqPx) - 1
        if not array.get(liqSwept, i)
            px  = array.get(liqPx, i)
            isB = array.get(liqBuy, i)
            hit = isB ? high > px : low < px
            if hit
                array.set(liqSwept, i, true)
                if isB
                    sweptBSL := true
                    bslSweepEq := math.max(bslSweepEq, array.get(liqEq, i))
                else
                    sweptSSL := true
                    sslSweepEq := math.max(sslSweepEq, array.get(liqEq, i))
                markSwept(i)
                if showSwp
                    pushLbl(swpQ, label.new(bar_index, px, "✗", style = label.style_none,
                         textcolor = isB ? cBSL : cSSL, size = TXT))
            else
                ln = array.get(liqLine, i)
                if not na(ln)
                    line.set_x2(ln, bar_index + 1)

// nearest unswept pools (targets / C-grade check)
nearestAbove(float ref) =>
    float best = na
    if array.size(liqPx) > 0
        for i = 0 to array.size(liqPx) - 1
            if not array.get(liqSwept, i) and array.get(liqBuy, i)
                px = array.get(liqPx, i)
                if px > ref and (na(best) or px < best)
                    best := px
    best

nearestBelow(float ref) =>
    float best = na
    if array.size(liqPx) > 0
        for i = 0 to array.size(liqPx) - 1
            if not array.get(liqSwept, i) and not array.get(liqBuy, i)
                px = array.get(liqPx, i)
                if px < ref and (na(best) or px > best)
                    best := px
    best

countAbove(float ref, float maxDist) =>
    c = 0
    if array.size(liqPx) > 0
        for i = 0 to array.size(liqPx) - 1
            if not array.get(liqSwept, i) and array.get(liqBuy, i)
                px = array.get(liqPx, i)
                if px > ref and px - ref <= maxDist
                    c += 1
    c

countBelow(float ref, float maxDist) =>
    c = 0
    if array.size(liqPx) > 0
        for i = 0 to array.size(liqPx) - 1
            if not array.get(liqSwept, i) and not array.get(liqBuy, i)
                px = array.get(liqPx, i)
                if px < ref and ref - px <= maxDist
                    c += 1
    c

// ═══ Opens & gaps ══════════════════════════════════════════════════════════
// Midnight opening price — acts as a magnet
var float mop = na
var line  mopLn = na
var label mopLb = na
if h0 == 0 and hour(time[1], tz) != 0
    mop := open
    if showMOP
        if not na(mopLn)
            line.delete(mopLn)
        if not na(mopLb)
            label.delete(mopLb)
        mopLn := line.new(bar_index, mop, bar_index + 1, mop, extend = extend.right,
             color = cMOP, style = styleOf(mopSty), width = 1)
        if mopTxt
            mopLb := label.new(bar_index, mop, "MOP", style = label.style_none,
                 textcolor = color.new(cMOP, 0), size = TXT)

// NDOG / NWOG (18:00 ET reopen vs prior close)
var box   ndogBx = na
var box   nwogBx = na
var label ndogLb = na
var label nwogLb = na
var float ndogMid = na
var float nwogMid = na
if newGlobex
    gTop = math.max(close[1], open)
    gBot = math.min(close[1], open)
    isNW = dayofweek(time, tz) == dayofweek.sunday
    if isNW
        nwogMid := (gTop + gBot) / 2
        if showNWOG
            if not na(nwogBx)
                box.delete(nwogBx)
            if not na(nwogLb)
                label.delete(nwogLb)
            nwogBx := box.new(bar_index, gTop, bar_index + 1, gBot, extend = extend.right,
                 border_color = color.new(cNWOG, 40), border_style = line.style_dotted, bgcolor = cNWOG)
            if gapTxt
                nwogLb := label.new(bar_index, gTop, "NWOG", style = label.style_none,
                     textcolor = color.new(cNWOG, 0), size = TXT)
    else
        ndogMid := (gTop + gBot) / 2
        if showNDOG
            if not na(ndogBx)
                box.delete(ndogBx)
            if not na(ndogLb)
                label.delete(ndogLb)
            ndogBx := box.new(bar_index, gTop, bar_index + 1, gBot, extend = extend.right,
                 border_color = color.new(cNDOG, 40), border_style = line.style_dotted, bgcolor = cNDOG)
            if gapTxt
                ndogLb := label.new(bar_index, gTop, "NDOG", style = label.style_none,
                     textcolor = color.new(cNDOG, 0), size = TXT)

// RTH gap: 16:00 close → 9:30 open, quartiles 25/50/75
var float rthCls = na
var float rthOpn = na
var rthLines = array.new_line()
var rthLbls  = array.new_label()
if h0 == 16 and hour(time[1], tz) < 16
    rthCls := close[1]
rthOpenEvt = h0 == 9 and m0 == 30 and not (hour(time[1], tz) == 9 and minute(time[1], tz) == 30)
if rthOpenEvt and not na(rthCls)
    rthOpn := open
    if showRTH
        while array.size(rthLines) > 0
            line.delete(array.pop(rthLines))
        while array.size(rthLbls) > 0
            label.delete(array.pop(rthLbls))
        for q = 0 to 4
            edge = q == 0 or q == 4
            if edge or rthQ
                yq = rthOpn + (rthCls - rthOpn) * q / 4.0
                array.push(rthLines, line.new(bar_index, yq, bar_index + 1, yq, extend = extend.right,
                     color = cRTH, style = edge ? line.style_solid : line.style_dotted, width = 1))
        if rthTxt
            array.push(rthLbls, label.new(bar_index, rthOpn, "RTH 0%", style = label.style_none,
                 textcolor = color.new(cRTH, 0), size = TXT))
            array.push(rthLbls, label.new(bar_index, rthCls, "RTH 100%", style = label.style_none,
                 textcolor = color.new(cRTH, 0), size = TXT))

// ═══ Displacement & chart-TF FVG / IFVG engine ═════════════════════════════
bodySz  = math.abs(close - open)
bodyAvg = ta.sma(bodySz, 20)
dispUp = close > open and bodySz > dispMult * bodyAvg
dispDn = close < open and bodySz > dispMult * bodyAvg
plotshape(showDisp and dispUp, "Displacement up",   shape.triangleup,   location.belowbar, cDispUp, size = size.tiny)
plotshape(showDisp and dispDn, "Displacement down", shape.triangledown, location.abovebar, cDispDn, size = size.tiny)

var fTop    = array.new_float()
var fBot    = array.new_float()
var fDir    = array.new_int()     // 1 = bullish origin, -1 = bearish origin
var fState  = array.new_int()     // 0 active, 1 inverted (valid IFVG), 2 invalidated
var fBirth  = array.new_int()
var fTapped = array.new_bool()
var fBox    = array.new_box()
var fLbl    = array.new_label()   // "FVG" text
var fILbl   = array.new_label()   // "IFVG" text

clearFvgDraw(int i) =>
    bx = array.get(fBox, i)
    if not na(bx)
        box.delete(bx)
        array.set(fBox, i, box(na))
    l1 = array.get(fLbl, i)
    if not na(l1)
        label.delete(l1)
        array.set(fLbl, i, label(na))
    l2 = array.get(fILbl, i)
    if not na(l2)
        label.delete(l2)
        array.set(fILbl, i, label(na))

newFVG(int dir, float top, float bot) =>
    box   bx = na
    label lb = na
    if showFVG
        col = dir == 1 ? cBullF : cBearF
        bx := box.new(bar_index - 2, top, bar_index + 1, bot,
             border_color = fvgBorder ? color.new(col, 30) : color(na), bgcolor = col)
    if fvgTxt
        lb := label.new(bar_index - 1, (top + bot) / 2, "FVG", style = label.style_none,
             textcolor = cFTxt, size = TXT)
    array.push(fTop, top)
    array.push(fBot, bot)
    array.push(fDir, dir)
    array.push(fState, 0)
    array.push(fBirth, bar_index)
    array.push(fTapped, false)
    array.push(fBox, bx)
    array.push(fLbl, lb)
    array.push(fILbl, label(na))
    if array.size(fTop) > 50
        clearFvgDraw(0)
        array.remove(fTop, 0)
        array.remove(fBot, 0)
        array.remove(fDir, 0)
        array.remove(fState, 0)
        array.remove(fBirth, 0)
        array.remove(fTapped, 0)
        array.remove(fBox, 0)
        array.remove(fLbl, 0)
        array.remove(fILbl, 0)

invalidateFvg(int i) =>
    array.set(fState, i, 2)
    if fvgDead == "Delete"
        clearFvgDraw(i)
    else if fvgDead == "Grey out"
        bx = array.get(fBox, i)
        if not na(bx)
            box.set_bgcolor(bx, cDead)
            box.set_border_color(bx, color(na))
        l2 = array.get(fILbl, i)
        if not na(l2)
            label.delete(l2)
            array.set(fILbl, i, label(na))
        l1 = array.get(fLbl, i)
        if not na(l1)
            label.delete(l1)
            array.set(fLbl, i, label(na))

bullGap = low > high[2]
bearGap = high < low[2]
// FVGs are always tracked (the signal engine needs them); drawing is optional
if bullGap and (not onlyDisp or dispUp[1])
    newFVG(1, low, high[2])
if bearGap and (not onlyDisp or dispDn[1])
    newFVG(-1, low[2], high)

invBullEvt = false      // bearish FVG body-closed above → valid bullish IFVG
invBearEvt = false
tapBullEvt = false      // retrace into bullish zone (IFVG or displacement FVG)
tapBearEvt = false
if array.size(fTop) > 0
    for i = 0 to array.size(fTop) - 1
        st = array.get(fState, i)
        if st != 2
            top = array.get(fTop, i)
            bot = array.get(fBot, i)
            dir = array.get(fDir, i)
            bx  = array.get(fBox, i)
            if not na(bx) and bar_index - array.get(fBirth, i) < fvgExtend
                box.set_right(bx, bar_index + 1)
            if st == 0
                if dir == -1 and close > top
                    array.set(fState, i, 1)      // inverted: now support
                    invBullEvt := true
                    if not na(bx)
                        box.set_bgcolor(bx, cInv)
                    if ifvgTxt
                        array.set(fILbl, i, label.new(bar_index, bot, "IFVG", style = label.style_label_up,
                             color = color.new(color.black, 100), textcolor = cFTxt, size = TXT))
                else if dir == 1 and close < bot
                    array.set(fState, i, 1)      // inverted: now resistance
                    invBearEvt := true
                    if not na(bx)
                        box.set_bgcolor(bx, cInv)
                    if ifvgTxt
                        array.set(fILbl, i, label.new(bar_index, top, "IFVG", style = label.style_label_down,
                             color = color.new(color.black, 100), textcolor = cFTxt, size = TXT))
                else if dir == 1 and not array.get(fTapped, i) and bar_index > array.get(fBirth, i) and low <= top and close >= bot
                    array.set(fTapped, i, true)
                    tapBullEvt := true
                else if dir == -1 and not array.get(fTapped, i) and bar_index > array.get(fBirth, i) and high >= bot and close <= top
                    array.set(fTapped, i, true)
                    tapBearEvt := true
            else
                // inverted zones: retrace = entry opportunity; break back through = invalidated
                if dir == -1
                    if close < bot
                        invalidateFvg(i)
                    else if not array.get(fTapped, i) and low <= top and close >= bot
                        array.set(fTapped, i, true)
                        tapBullEvt := true
                else
                    if close > top
                        invalidateFvg(i)
                    else if not array.get(fTapped, i) and high >= bot and close <= top
                        array.set(fTapped, i, true)
                        tapBearEvt := true

// volume imbalance (body gap with wick overlap)
var viBoxes = array.new_box()
viBull = showVI and math.min(open, close) > math.max(open[1], close[1]) and low <= high[1]
viBear = showVI and math.max(open, close) < math.min(open[1], close[1]) and high >= low[1]
if viBull
    array.push(viBoxes, box.new(bar_index - 1, math.min(open, close), bar_index + 10, math.max(open[1], close[1]),
         border_color = color(na), bgcolor = cVIb))
if viBear
    array.push(viBoxes, box.new(bar_index - 1, math.min(open[1], close[1]), bar_index + 10, math.max(open, close),
         border_color = color(na), bgcolor = cVIs))
if array.size(viBoxes) > 20
    box.delete(array.shift(viBoxes))

// ═══ HTF FVGs (1H + daily) on the execution chart ══════════════════════════
var float h1a = na
var float h1b = na
var float h1c = na
var float l1a = na
var float l1b = na
var float l1c = na
var hfTop = array.new_float()
var hfBot = array.new_float()
var hfDir = array.new_int()
var hfBox = array.new_box()
var hfLbl = array.new_label()

dropHtf(int i, bool erase) =>
    bx = array.get(hfBox, i)
    lb = array.get(hfLbl, i)
    if erase
        if not na(bx)
            box.delete(bx)
        if not na(lb)
            label.delete(lb)
    else if not na(bx)
        box.set_extend(bx, extend.none)
        box.set_right(bx, bar_index)
    array.remove(hfTop, i)
    array.remove(hfBot, i)
    array.remove(hfDir, i)
    array.remove(hfBox, i)
    array.remove(hfLbl, i)

addHtf(float top, float bot, int dir, color col, string tag) =>
    bx = box.new(bar_index, top, bar_index + 1, bot, border_color = color.new(col, 50),
         bgcolor = col, extend = extend.right)
    label lb = na
    if htfTxt
        lb := label.new(bar_index, (top + bot) / 2, tag, style = label.style_none,
             textcolor = cHtfTxt, size = TXT)
    array.push(hfTop, top)
    array.push(hfBot, bot)
    array.push(hfDir, dir)
    array.push(hfBox, bx)
    array.push(hfLbl, lb)
    if array.size(hfTop) > htfMax
        dropHtf(0, true)

new60 = ta.change(t60) != 0
if new60
    h1c := h1b
    l1c := l1b
    h1b := h1a
    l1b := l1a
    h1a := h60c[1]
    l1a := l60c[1]
    if show60 and not na(h1c)
        if l1a > h1c
            addHtf(l1a, h1c, 1, cHtf, "1H FVG")
        if h1a < l1c
            addHtf(l1c, h1a, -1, cHtf, "1H FVG")

var float hDa = na
var float hDb = na
var float hDc2 = na
var float lDa = na
var float lDb = na
var float lDc2 = na
newD = ta.change(tD) != 0
if newD
    hDc2 := hDb
    lDc2 := lDb
    hDb := hDa
    lDb := lDa
    hDa := hDc[1]
    lDa := lDc[1]
    if showD and not na(hDc2)
        if lDa > hDc2
            addHtf(lDa, hDc2, 1, cDly, "D FVG")
        if hDa < lDc2
            addHtf(lDc2, hDa, -1, cDly, "D FVG")

// filled HTF zones
if array.size(hfTop) > 0
    for i = array.size(hfTop) - 1 to 0
        if (array.get(hfDir, i) == 1 and close < array.get(hfBot, i)) or (array.get(hfDir, i) == -1 and close > array.get(hfTop, i))
            dropHtf(i, htfFill == "Delete")

inHtfZone(float px) =>
    hit = false
    if array.size(hfTop) > 0
        for i = 0 to array.size(hfTop) - 1
            if px <= array.get(hfTop, i) and px >= array.get(hfBot, i)
                hit := true
    hit

// ═══ Premium / discount ════════════════════════════════════════════════════
eqTop = ta.highest(high, eqLen)
eqBot = ta.lowest(low, eqLen)
eqMid = (eqTop + eqBot) / 2
plot(showEq ? eqMid : na, "Equilibrium", color = cEq, style = plot.style_linebr)
inPremium = close > eqMid

// ═══ SMT vs correlated symbol ══════════════════════════════════════════════
nqLL = low < ta.lowest(low, smtLen)[1]
nqHH = high > ta.highest(high, smtLen)[1]
esLL = esL < ta.lowest(esL, smtLen)[1]
esHH = esH > ta.highest(esH, smtLen)[1]
smtOk   = useSMT and not na(esH)
smtBull = smtOk and nqLL and not esLL
smtBear = smtOk and nqHH and not esHH
var int lastSmtBullBar = na
var int lastSmtBearBar = na
if smtBull
    lastSmtBullBar := bar_index
if smtBear
    lastSmtBearBar := bar_index

var smtLvl = array.new_float()
var smtDir = array.new_int()
var smtLb  = array.new_label()
// remove SMT labels whose level has been broken
if smtClear and array.size(smtLvl) > 0
    for i = array.size(smtLvl) - 1 to 0
        broken = array.get(smtDir, i) == 1 ? low < array.get(smtLvl, i) : high > array.get(smtLvl, i)
        if broken
            lb = array.get(smtLb, i)
            if not na(lb)
                label.delete(lb)
            array.remove(smtLvl, i)
            array.remove(smtDir, i)
            array.remove(smtLb, i)

addSmtLbl(int dir, float lv) =>
    lb = label.new(bar_index, lv, dir == 1 ? "SMT+" : "SMT−",
         style = dir == 1 ? label.style_label_up : label.style_label_down,
         color = color.new(color.black, 100), textcolor = cSMT, size = TXT)
    array.push(smtLvl, lv)
    array.push(smtDir, dir)
    array.push(smtLb, lb)
    if array.size(smtLb) > lblCap
        old = array.shift(smtLb)
        if not na(old)
            label.delete(old)
        array.shift(smtLvl)
        array.shift(smtDir)

if smtLbl != "Off"
    if smtBull and (smtLbl == "All" or sweptSSL)
        addSmtLbl(1, low)
    if smtBear and (smtLbl == "All" or sweptBSL)
        addSmtLbl(-1, high)

// ═══ Signal engine: sweep → displacement → FVG/IFVG entry, graded A+/B/C ════
var int   armLongBar = na
var float armLongLow = na
var int   armLongEq = 1
var int   dispLongBar = na
var int   armShortBar = na
var float armShortHigh = na
var int   armShortEq = 1
var int   dispShortBar = na

if sweptSSL
    armLongBar := bar_index
    armLongLow := low
    armLongEq := sslSweepEq
    dispLongBar := na
if sweptBSL
    armShortBar := bar_index
    armShortHigh := high
    armShortEq := bslSweepEq
    dispShortBar := na

armedLong  = not na(armLongBar) and bar_index - armLongBar <= windowBars
armedShort = not na(armShortBar) and bar_index - armShortBar <= windowBars
if armedLong
    armLongLow := math.min(armLongLow, low)
    if dispUp
        dispLongBar := bar_index
if armedShort
    armShortHigh := math.max(armShortHigh, high)
    if dispDn
        dispShortBar := bar_index

kzOk     = not onlyKZ or inKZ
barOk    = not confOnly or barstate.isconfirmed
longTrig  = showSig and barOk and armedLong and not na(dispLongBar) and kzOk and (invBullEvt or tapBullEvt)
shortTrig = showSig and barOk and armedShort and not na(dispShortBar) and kzOk and (invBearEvt or tapBearEvt)

isNQ     = syminfo.root == "NQ" or syminfo.root == "MNQ"
usePts   = slMode == "Points" or (slMode == "Auto" and isNQ)
maxSLpts = usePts ? (inNKZ ? maxSL_N : maxSL_L) : slAtr * atr14
gradeRank(string g) =>
    g == "A+" ? 3 : g == "B" ? 2 : 1
minRank = gradeRank(gradeMin)

var sigLbls = array.new_label()
var sigLns  = array.new_line()     // 4 slots per signal: entry, SL, TP1, TP
var skipQ   = array.new_label()

drawSig(bool isLong, string grade, float entry, float sl, float tp1, float tpF) =>
    risk = math.abs(entry - sl)
    base = grade == "A+" ? cAplus : isLong ? cLongS : cShortS
    tr   = grade == "C" ? math.min(100, sigTr + 12) : sigTr
    tip  = (isLong ? "LONG " : "SHORT ") + grade +
         "\nEntry " + str.tostring(entry, format.mintick) +
         "\nSL " + str.tostring(sl, format.mintick) + " (" + str.tostring(risk, "#.##") + ")" +
         (na(tp1) ? "" : "\nTP1 " + str.tostring(tp1, format.mintick)) +
         "\nTP " + str.tostring(tpF, format.mintick) + " (" + str.tostring(math.abs(tpF - entry) / risk, "#.#") + "R)"
    if sigStyle != "Off"
        txt = sigStyle == "Full" ? (isLong ? "▲ LONG " : "▼ SHORT ") + grade + "\nSL " + str.tostring(sl, format.mintick) + " (" + str.tostring(risk, "#.#") + ")" : grade
        lb = label.new(bar_index, isLong ? low : high, txt,
             style = isLong ? label.style_label_up : label.style_label_down,
             color = color.new(base, tr), textcolor = cSigTxt, size = sizeOf(sigSz), tooltip = tip)
        array.push(sigLbls, lb)
        if array.size(sigLbls) > keepSig
            label.delete(array.shift(sigLbls))
    line l1 = na
    line l2 = na
    line l3 = na
    line l4 = na
    if showTrade
        x2 = bar_index + tradeLen
        l1 := line.new(bar_index, entry, x2, entry, color = cEntry, width = 1)
        l2 := line.new(bar_index, sl, x2, sl, color = cSLl, width = 1)
        if showTP1 and not na(tp1)
            l3 := line.new(bar_index, tp1, x2, tp1, color = color.new(cTPl, 40), style = line.style_dashed)
        l4 := line.new(bar_index, tpF, x2, tpF, color = cTPl, width = 1)
    array.push(sigLns, l1)
    array.push(sigLns, l2)
    array.push(sigLns, l3)
    array.push(sigLns, l4)
    if array.size(sigLns) > keepSig * 4
        for k = 1 to 4
            old = array.shift(sigLns)
            if not na(old)
                line.delete(old)

scoreSetup(bool isLong, float entry, float sl, int sweepEq) =>
    score = 0
    if inHtfZone(entry) or inHtfZone(sl)
        score += 1
    nearRef = (not na(mop) and math.abs(entry - mop) < atr14) or (not na(ndogMid) and math.abs(entry - ndogMid) < atr14) or (not na(nwogMid) and math.abs(entry - nwogMid) < atr14)
    if nearRef
        score += 1
    smtRecent = isLong ? (not na(lastSmtBullBar) and bar_index - lastSmtBullBar <= windowBars) : (not na(lastSmtBearBar) and bar_index - lastSmtBearBar <= windowBars)
    if smtRecent
        score += 1
    if sweepEq >= 2
        score += 1
    if (isLong ? countAbove(entry, atr14 * 12) : countBelow(entry, atr14 * 12)) >= 2
        score += 1
    if isLong != inPremium                       // buy in discount / sell in premium
        score += 1
    if (isLong ? countBelow(entry, atr14 * 3) : countAbove(entry, atr14 * 3)) >= 2
        score -= 1                               // obvious liquidity left behind → C
    score >= 4 ? "A+" : score >= 2 ? "B" : "C"

sigLongEvt  = false
sigShortEvt = false
var int nSkip = 0
var int nSig  = 0

if longTrig
    entry  = close
    slRaw  = armLongLow - 2 * syminfo.mintick
    slDist = entry - slRaw
    if strictSL and slDist > maxSLpts
        nSkip += 1
        if showSkip
            pushLbl(skipQ, label.new(bar_index, low, "SL > cap", style = label.style_none, textcolor = color.gray, size = TXT))
    else
        grade = scoreSetup(true, entry, slRaw, armLongEq)
        if gradeRank(grade) >= minRank
            sigLongEvt := true
            nSig += 1
            tp1 = nearestAbove(entry)
            tpF = math.max(nz(tp1, entry + minRR * slDist), entry + minRR * slDist)
            drawSig(true, grade, entry, slRaw, tp1, tpF)
            armLongBar := na

if shortTrig
    entry  = close
    slRaw  = armShortHigh + 2 * syminfo.mintick
    slDist = slRaw - entry
    if strictSL and slDist > maxSLpts
        nSkip += 1
        if showSkip
            pushLbl(skipQ, label.new(bar_index, high, "SL > cap", style = label.style_none, textcolor = color.gray, size = TXT))
    else
        grade = scoreSetup(false, entry, slRaw, armShortEq)
        if gradeRank(grade) >= minRank
            sigShortEvt := true
            nSig += 1
            tp1 = nearestBelow(entry)
            tpF = math.min(nz(tp1, entry - minRR * slDist), entry - minRR * slDist)
            drawSig(false, grade, entry, slRaw, tp1, tpF)
            armShortBar := na

// ═══ Dashboard ═════════════════════════════════════════════════════════════
posOf(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right :
     s == "Bottom left" ? position.bottom_left : position.top_right

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(posOf(dashPos), 2, 8, bgcolor = color.new(#0d0d14, 15),
             border_width = 1, border_color = color.new(#2a2a3a, 60))
    dS   = sizeOf(dashSz)
    cTxt = #d0d0d8
    sTxt = inLKZ ? "LONDON KZ" : inNKZ ? "NY KZ" : inAsia ? "ASIA" : "OFF"
    sCol = inLKZ ? color.new(cLdn, 0) : inNKZ ? color.new(cNy, 0) : inAsia ? color.new(cAsia, 0) : color.gray
    table.cell(dash, 0, 0, "SESSION", text_color = cTxt, text_size = dS, text_halign = text.align_left)
    table.cell(dash, 1, 0, sTxt, text_color = sCol, text_size = dS, text_halign = text.align_right)
    table.cell(dash, 0, 1, "vs MOP", text_color = cTxt, text_size = dS, text_halign = text.align_left)
    table.cell(dash, 1, 1, na(mop) ? "—" : close > mop ? "ABOVE ▲" : "BELOW ▼", text_color = na(mop) ? cTxt : close > mop ? #26a69a : #ef5350, text_size = dS, text_halign = text.align_right)
    table.cell(dash, 0, 2, "P/D", text_color = cTxt, text_size = dS, text_halign = text.align_left)
    table.cell(dash, 1, 2, inPremium ? "PREMIUM" : "DISCOUNT", text_color = inPremium ? #ef5350 : #26a69a, text_size = dS, text_halign = text.align_right)
    rthTx = na(rthCls) or na(rthOpn) or rthCls == rthOpn ? "—" : str.tostring(math.round(math.min(1, math.max(0, (close - rthOpn) / (rthCls - rthOpn))) * 100)) + "% filled"
    table.cell(dash, 0, 3, "RTH GAP", text_color = cTxt, text_size = dS, text_halign = text.align_left)
    table.cell(dash, 1, 3, rthTx, text_color = #ffee58, text_size = dS, text_halign = text.align_right)
    stL = armedLong ? (na(dispLongBar) ? "ARMED (wait disp)" : "ARMED + DISP ✓") : "idle"
    stS = armedShort ? (na(dispShortBar) ? "ARMED (wait disp)" : "ARMED + DISP ✓") : "idle"
    table.cell(dash, 0, 4, "LONG SETUP", text_color = cTxt, text_size = dS, text_halign = text.align_left)
    table.cell(dash, 1, 4, stL, text_color = armedLong ? #26a69a : color.gray, text_size = dS, text_halign = text.align_right)
    table.cell(dash, 0, 5, "SHORT SETUP", text_color = cTxt, text_size = dS, text_halign = text.align_left)
    table.cell(dash, 1, 5, stS, text_color = armedShort ? #ef5350 : color.gray, text_size = dS, text_halign = text.align_right)
    smtTxt = not smtOk ? "off" : not na(lastSmtBullBar) and bar_index - lastSmtBullBar <= windowBars ? "BULL +" : not na(lastSmtBearBar) and bar_index - lastSmtBearBar <= windowBars ? "BEAR −" : "—"
    table.cell(dash, 0, 6, "SMT", text_color = cTxt, text_size = dS, text_halign = text.align_left)
    table.cell(dash, 1, 6, smtTxt, text_color = cSMT, text_size = dS, text_halign = text.align_right)
    if dashSkip
        table.cell(dash, 0, 7, "SIGNALS / SKIPPED", text_color = cTxt, text_size = dS, text_halign = text.align_left)
        table.cell(dash, 1, 7, str.tostring(nSig) + " / " + str.tostring(nSkip) + (usePts ? "  (pts cap)" : "  (ATR cap)"),
             text_color = nSkip > nSig ? #ffb74d : cTxt, text_size = dS, text_halign = text.align_right)

// ═══ Alerts ════════════════════════════════════════════════════════════════
alertcondition(sweptSSL, "Sellside liquidity swept", "Sellside liquidity swept — watch for displacement up")
alertcondition(sweptBSL, "Buyside liquidity swept", "Buyside liquidity swept — watch for displacement down")
alertcondition(invBullEvt, "Bullish IFVG validated", "Bearish FVG inverted — valid bullish IFVG")
alertcondition(invBearEvt, "Bearish IFVG validated", "Bullish FVG inverted — valid bearish IFVG")
alertcondition(sigLongEvt, "LONG signal", "ICT-Scalp LONG signal (sweep + displacement + IFVG)")
alertcondition(sigShortEvt, "SHORT signal", "ICT-Scalp SHORT signal (sweep + displacement + IFVG)")
````

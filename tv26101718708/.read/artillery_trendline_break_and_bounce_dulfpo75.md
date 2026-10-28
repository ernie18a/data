# Artillery Trendline Break and Bounce

- url: https://www.tradingview.com/script/DulFPO75-Artillery-Trendline-Break-and-Bounce/
- type: indicator
- pine_id: PUB;e0d498557a88445592d0cc3c5b5b880d
- version: 1.0

## Description

Artillery Trendline Break and Bounce draws trendlines automatically from confirmed swing points and marks two classic trendline setups on the chart: the bounce off a respected line, and the break of a line close to a protective "safety line". It is built around the trendline method taught publicly by Tori Trades (not affiliated), turned into objective rules so every step is visible.

HOW IT WORKS

1. Trendlines: swing highs and lows are confirmed after a set number of bars on each side (default 5). An uptrend line connects two higher lows, a downtrend line connects two lower highs. A line is only drawn if no candle has closed through it since its first point, and the version with the most touches (then the longest span) is chosen. Each touch is numbered on the chart.

2. Bounce setup: when price tests an established line (default: at least 30 bars from its first point, about one week of 4H candles) and the candle closes back in the trend direction, a BOUNCE signal prints. The stop sits beyond the line plus a small ATR buffer and trails along the line as it moves.

3. Break setup: when a candle closes through a line, a BREAK signal prints only if price is still close to the most recent swing on the other side (within 1.5 × ATR by default). That swing is the "safety line" stop. It trails to each new confirmed swing as the move develops.

4. Exits: there is no fixed target. A trade closes when a candle closes through its safety line, and the result is tagged in R (multiples of the initial risk).

5. Trend filter (optional, on by default): signals are only taken in the direction of a higher-timeframe EMA (default Daily EMA 50), following a top-down approach.

ON THE CHART
• Green uptrend lines and red downtrend lines with numbered touches
• BUY / SELL tags for BOUNCE and BREAK setups
• Orange safety-line stop while a trade is open
• Result tags in R when a trade closes
• Dashboard: higher-timeframe trend, active lines and touches, last signal, position, wins/losses and net R
• Alerts for every signal and for safety-line exits

HOW TO USE
Designed for the 4H chart with the Daily as the trend reference, on index futures, metals, energy, forex or crypto. Swing length, touch tolerance, minimum line age, break distance, stop buffer and the trend filter can all be adjusted. Lines that never produced a signal are removed when they break to keep the chart clean.

NOTES
• Swings confirm after the swing length and higher-timeframe data uses confirmed values, so signals do not repaint.
• The method takes many small losses and relies on fewer, larger trend moves. The wins/losses and R shown in the dashboard only cover bars loaded on your chart; they are not a backtest and do not predict future results.
• For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//  ARTILLERY · TRENDLINE BREAK & BOUNCE                        © artillerytrades
//  Auto trendlines from confirmed swing points → bounce or break setups with a
//  trailing "safety line" stop. Original code.
//  Non-repainting: swings confirm after `pivL` bars, HTF data offset by [1].
// ─────────────────────────────────────────────────────────────────────────────
indicator("Artillery · Trendline Break & Bounce", shorttitle="ART TL", overlay=true,
     max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ═════════════════════════════ INPUTS ═══════════════════════════════════════
g1 = "📐 Trendlines"
pivL    = input.int(5, "Swing length (bars each side)", minval=2, group=g1)
lookMax = input.int(300, "Max line length (bars)", minval=50, maxval=450, group=g1)
minSpan = input.int(30, "Min bars from first touch to signal", minval=5, group=g1,
     tooltip="About one week of 4H candles ≈ 30 bars.")
tolMult = input.float(0.25, "Touch tolerance (× ATR)", step=0.05, minval=0.05, group=g1)
showOld = input.bool(true, "Keep broken lines on chart", group=g1)

g2 = "🎯 Setups"
useBounce = input.bool(true, "Bounce · trade the next touch", group=g2)
useBreak  = input.bool(true, "Break · trade the trendline break", group=g2)
breakDist = input.float(1.5, "Break must be within N × ATR of the safety line", step=0.1, minval=0.2, group=g2)
bounceBuf = input.float(0.5, "Bounce stop room beyond the line (× ATR)", step=0.05, minval=0.0, group=g2)

g3 = "🧭 Trend filter"
useHTF = input.bool(true, "Only signal with the higher-timeframe trend", group=g3)
htfTF  = input.timeframe("D", "Higher timeframe", group=g3)
htfLen = input.int(50, "HTF EMA length", minval=5, group=g3)

g4 = "🎨 Style"
upCol    = input.color(#22c55e, "Uptrend line", group=g4)
dnCol    = input.color(#ef4444, "Downtrend line", group=g4)
safeCol  = input.color(#f59e0b, "Safety line (stop)", group=g4)
showDash = input.bool(true, "Dashboard", group=g4)

// ═════════════════════════════ CORE ═════════════════════════════════════════
atr = ta.atr(14)
tol = atr * tolMult

htfEma   = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfLen)[1], lookahead=barmerge.lookahead_on)
htfClose = request.security(syminfo.tickerid, htfTF, close[1], lookahead=barmerge.lookahead_on)
htfBull  = htfClose > htfEma
htfBear  = htfClose < htfEma
okLong   = not useHTF or htfBull
okShort  = not useHTF or htfBear

lineY(float y1, int x1, float m, int x) =>
    y1 + m * (x - x1)

ph = ta.pivothigh(high, pivL, pivL)
pl = ta.pivotlow(low, pivL, pivL)

var array<int>   plX = array.new<int>()
var array<float> plY = array.new<float>()
var array<int>   phX = array.new<int>()
var array<float> phY = array.new<float>()

var float lastPH = na
var float lastPL = na

// active uptrend line (connects higher lows)
var bool  supOn = false
var int   supX1 = na
var float supY1 = na
var float supM  = na
var int   supT  = 0
var line  supLn = na
var bool  supUsed = false
var array<label> supDots = array.new<label>()
// active downtrend line (connects lower highs)
var bool  resOn = false
var int   resX1 = na
var float resY1 = na
var float resM  = na
var int   resT  = 0
var line  resLn = na
var bool  resUsed = false
var array<label> resDots = array.new<label>()

touchDot(int x, float y, color c, int n) =>
    label.new(x, y, str.tostring(n), style=label.style_circle, color=color.new(c, 15),
         textcolor=color.white, size=size.tiny)

retire(line ln, array<label> dots, bool used, color c) =>
    if not na(ln)
        if used and showOld
            ln.set_color(color.new(c, 35))
            for lb in dots
                lb.set_color(color.new(c, 35))
        else
            ln.delete()
            for lb in dots
                lb.delete()
    array.clear(dots)

// ── new swing low → extend or build the uptrend line ──
if not na(pl)
    int   x2 = bar_index - pivL
    float y2 = pl
    lastPL := pl
    bool absorbed = false
    if supOn and math.abs(y2 - lineY(supY1, supX1, supM, x2)) <= tol
        supT += 1
        absorbed := true
        array.push(supDots, touchDot(x2, y2, upCol, supT))
    if not absorbed and (not supOn or bar_index - supX1 > lookMax)
        int   bestT = 0
        int   bestSpan = 0
        int   bX = na
        float bY = na
        float bM = na
        int n = array.size(plX)
        if n > 0
            for i = 0 to n - 1
                int   x1 = array.get(plX, i)
                float y1 = array.get(plY, i)
                int span = x2 - x1
                if y1 < y2 and span >= pivL * 2 and bar_index - x1 <= lookMax
                    float m = (y2 - y1) / span
                    bool ok = true
                    for k = 0 to bar_index - x1
                        if close[k] < lineY(y1, x1, m, bar_index - k) - tol
                            ok := false
                            break
                    if ok
                        int t = 2
                        for j = 0 to n - 1
                            int xj = array.get(plX, j)
                            if xj > x1 and math.abs(array.get(plY, j) - lineY(y1, x1, m, xj)) <= tol
                                t += 1
                        if t > bestT or (t == bestT and span > bestSpan)
                            bestT := t
                            bestSpan := span
                            bX := x1
                            bY := y1
                            bM := m
        if bestT >= 2
            if supOn
                retire(supLn, supDots, supUsed, upCol)
            supUsed := false
            supOn := true
            supX1 := bX
            supY1 := bY
            supM  := bM
            supT  := bestT
            supLn := line.new(bX, bY, bar_index, lineY(bY, bX, bM, bar_index), color=upCol, width=2)
            array.push(supDots, touchDot(bX, bY, upCol, 1))
            array.push(supDots, touchDot(x2, y2, upCol, bestT))
    array.push(plX, x2)
    array.push(plY, y2)
    if array.size(plX) > 20
        array.shift(plX)
        array.shift(plY)

// ── new swing high → extend or build the downtrend line ──
if not na(ph)
    int   x2 = bar_index - pivL
    float y2 = ph
    lastPH := ph
    bool absorbed = false
    if resOn and math.abs(y2 - lineY(resY1, resX1, resM, x2)) <= tol
        resT += 1
        absorbed := true
        array.push(resDots, touchDot(x2, y2, dnCol, resT))
    if not absorbed and (not resOn or bar_index - resX1 > lookMax)
        int   bestT = 0
        int   bestSpan = 0
        int   bX = na
        float bY = na
        float bM = na
        int n = array.size(phX)
        if n > 0
            for i = 0 to n - 1
                int   x1 = array.get(phX, i)
                float y1 = array.get(phY, i)
                int span = x2 - x1
                if y1 > y2 and span >= pivL * 2 and bar_index - x1 <= lookMax
                    float m = (y2 - y1) / span
                    bool ok = true
                    for k = 0 to bar_index - x1
                        if close[k] > lineY(y1, x1, m, bar_index - k) + tol
                            ok := false
                            break
                    if ok
                        int t = 2
                        for j = 0 to n - 1
                            int xj = array.get(phX, j)
                            if xj > x1 and math.abs(array.get(phY, j) - lineY(y1, x1, m, xj)) <= tol
                                t += 1
                        if t > bestT or (t == bestT and span > bestSpan)
                            bestT := t
                            bestSpan := span
                            bX := x1
                            bY := y1
                            bM := m
        if bestT >= 2
            if resOn
                retire(resLn, resDots, resUsed, dnCol)
            resUsed := false
            resOn := true
            resX1 := bX
            resY1 := bY
            resM  := bM
            resT  := bestT
            resLn := line.new(bX, bY, bar_index, lineY(bY, bX, bM, bar_index), color=dnCol, width=2)
            array.push(resDots, touchDot(bX, bY, dnCol, 1))
            array.push(resDots, touchDot(x2, y2, dnCol, bestT))
    array.push(phX, x2)
    array.push(phY, y2)
    if array.size(phX) > 20
        array.shift(phX)
        array.shift(phY)

// ── extend lines / age out ──
float supV = supOn ? lineY(supY1, supX1, supM, bar_index) : na
float resV = resOn ? lineY(resY1, resX1, resM, bar_index) : na
if supOn
    supLn.set_xy2(bar_index, supV)
if resOn
    resLn.set_xy2(bar_index, resV)

bool supReady = supOn and bar_index - supX1 >= minSpan
bool resReady = resOn and bar_index - resX1 >= minSpan
bool supBreak = supOn and close < supV
bool resBreak = resOn and close > resV

// ═════════════════════════════ SIGNALS & TRADES ═════════════════════════════
var int   pos   = 0      // 1 long, -1 short
var int   ptype = 0      // 1 bounce, 2 break
var float entry = na
var float stop  = na
var float risk  = na
var int   tX1   = na
var float tY1   = na
var float tM    = na
var int   eBar  = na
var int   nW = 0
var int   nL = 0
var float sumR = 0.0
var string lastSig = "—"

bool longBounce  = false
bool shortBounce = false
bool longBreak   = false
bool shortBreak  = false

if pos == 0
    if useBounce and supReady and not supBreak and low <= supV + tol and close > supV and close > open and okLong
        longBounce := true
    else if useBounce and resReady and not resBreak and high >= resV - tol and close < resV and close < open and okShort
        shortBounce := true
    else if useBreak and resBreak and resReady and not na(lastPL) and lastPL < close and close - lastPL <= breakDist * atr and okLong
        longBreak := true
    else if useBreak and supBreak and supReady and not na(lastPH) and lastPH > close and lastPH - close <= breakDist * atr and okShort
        shortBreak := true

if longBounce
    pos := 1, ptype := 1, entry := close, eBar := bar_index
    tX1 := supX1, tY1 := supY1, tM := supM
    stop := supV - bounceBuf * atr
    risk := entry - stop
    lastSig := "BUY · Bounce"
    label.new(bar_index, low - atr * 0.4, "▲ BUY\nBOUNCE", style=label.style_label_up, color=upCol, textcolor=color.white, size=size.small)
if shortBounce
    pos := -1, ptype := 1, entry := close, eBar := bar_index
    tX1 := resX1, tY1 := resY1, tM := resM
    stop := resV + bounceBuf * atr
    risk := stop - entry
    lastSig := "SELL · Bounce"
    label.new(bar_index, high + atr * 0.4, "▼ SELL\nBOUNCE", style=label.style_label_down, color=dnCol, textcolor=color.white, size=size.small)
if longBreak
    pos := 1, ptype := 2, entry := close, eBar := bar_index
    stop := lastPL
    risk := entry - stop
    lastSig := "BUY · Break"
    label.new(bar_index, low - atr * 0.4, "▲ BUY\nBREAK", style=label.style_label_up, color=upCol, textcolor=color.white, size=size.small)
if shortBreak
    pos := -1, ptype := 2, entry := close, eBar := bar_index
    stop := lastPH
    risk := stop - entry
    lastSig := "SELL · Break"
    label.new(bar_index, high + atr * 0.4, "▼ SELL\nBREAK", style=label.style_label_down, color=dnCol, textcolor=color.white, size=size.small)

// a close through a line retires it
if longBounce or shortBreak
    supUsed := true
if shortBounce or longBreak
    resUsed := true
if supBreak
    supOn := false
    retire(supLn, supDots, supUsed, upCol)
if resBreak
    resOn := false
    retire(resLn, resDots, resUsed, dnCol)

// trail the safety line and exit on a close through it
bool exitNow = false
if pos != 0 and bar_index > eBar
    if ptype == 1
        float lv = lineY(tY1, tX1, tM, bar_index)
        stop := pos == 1 ? math.max(stop, lv - bounceBuf * atr) : math.min(stop, lv + bounceBuf * atr)
    else
        if pos == 1 and not na(pl) and pl > stop and pl < close
            stop := pl
        if pos == -1 and not na(ph) and ph < stop and ph > close
            stop := ph
    exitNow := pos == 1 ? close < stop : close > stop

float plotStop = pos != 0 ? stop : na
if exitNow
    float r = (close - entry) * pos / risk
    if r > 0
        nW += 1
    else
        nL += 1
    sumR += r
    string txt = r > 0 ? "✔ +" + str.tostring(r, "#.#") + "R" : "✖ " + str.tostring(r, "#.#") + "R"
    label.new(bar_index, pos == 1 ? high + atr * 0.4 : low - atr * 0.4, txt,
         style=pos == 1 ? label.style_label_down : label.style_label_up,
         color=r > 0 ? color.new(#16a34a, 10) : color.new(#64748b, 10), textcolor=color.white, size=size.small)
    pos := 0

plot(plotStop, "Safety line", color=safeCol, style=plot.style_linebr, linewidth=2)

// ═════════════════════════════ ALERTS ═══════════════════════════════════════
alertcondition(longBounce,  "Buy · Bounce",  "Trendline bounce long on {{ticker}} at {{close}}")
alertcondition(shortBounce, "Sell · Bounce", "Trendline bounce short on {{ticker}} at {{close}}")
alertcondition(longBreak,   "Buy · Break",   "Downtrend line broken on {{ticker}} at {{close}}")
alertcondition(shortBreak,  "Sell · Break",  "Uptrend line broken on {{ticker}} at {{close}}")
alertcondition(exitNow,     "Safety line hit", "Close through the safety line on {{ticker}} at {{close}}")

// ═════════════════════════════ DASHBOARD ════════════════════════════════════
var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(#0b1220, 10),
     border_width=1, frame_color=color.new(upCol, 40), frame_width=1)

dRow(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_color=color.new(color.white, 40), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, r, v, text_color=vc, text_size=size.small, text_halign=text.align_right)

if showDash and barstate.isfirst
    table.merge_cells(dash, 0, 0, 1, 0)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "ARTILLERY · TRENDLINES", text_color=color.white, text_size=size.small)
    dRow(1, "HTF trend", htfBull ? "Bullish ▲" : htfBear ? "Bearish ▼" : "—", htfBull ? upCol : htfBear ? dnCol : color.gray)
    dRow(2, "Uptrend line", supOn ? str.tostring(supT) + " touches" : "none", supOn ? upCol : color.gray)
    dRow(3, "Downtrend line", resOn ? str.tostring(resT) + " touches" : "none", resOn ? dnCol : color.gray)
    dRow(4, "Last signal", lastSig, color.white)
    dRow(5, "Position", pos == 1 ? "Long" : pos == -1 ? "Short" : "Flat", pos == 1 ? upCol : pos == -1 ? dnCol : color.gray)
    dRow(6, "Wins / losses", str.tostring(nW) + " / " + str.tostring(nL), color.white)
    dRow(7, "Net (chart)", (sumR >= 0 ? "+" : "") + str.tostring(sumR, "#.#") + "R", sumR >= 0 ? upCol : dnCol)
````

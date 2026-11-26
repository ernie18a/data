# SuperTrend Engine [Quantum Algo]

- url: https://www.tradingview.com/script/sUpeCIiJ-SuperTrend-Engine-Quantum-Algo/
- type: indicator
- pine_id: PUB;527522a982374c9885bc362becb25a78
- version: 1.0

## Description

SuperTrend Engine [Quantum Algo]
====================================================

🔶 OVERVIEW

SuperTrend Engine is a volatility-adaptive SuperTrend indicator built on one idea: every SuperTrend gives you signals — this one shows you the whipsaws it saved you from, tells you its real win rate on your chart, and admits when it is wrong.

The engine self-tunes its factor with a fully transparent formula, confirms flips through a Whipsaw Shield that absorbs fake-outs and marks every one it absorbed, stamps every buy and sell flip with its live, honestly-computed win rate on the current symbol, settles every marker into its real outcome ten bars later, and draws the trade geometry — entry, trailing stop, one-R and two-R references — the moment a flip confirms.

🔶 WHAT IS A SUPERTREND?

A SuperTrend is a trailing stop built from the Average True Range: a band placed a volatility-scaled distance from price that ratchets in the trend's favor and never retreats. While price holds above the band, the trend is up and the band trails below as a stop; a close through the band flips the state. It is one of the most followed trend-following tools in retail trading — and its famous weakness is the whipsaw: sideways markets flip it back and forth, and a fixed factor that survives chop is too slow in trends. This engine is built specifically against that weakness.

🔶 WHY THIS SCRIPT IS ORIGINAL

1. The Whipsaw Shield — visible absorbed fake-outs. A flip only confirms when the close clears the opposite band by a volatility margin. When the raw trail flips and reverses before clearing it, the engine holds its direction and prints a small ghost marker where the whipsaw died, with a running Whipsaws Shielded counter in the dashboard. Other tools try to reduce whipsaws quietly; to our knowledge, none renders the failures it absorbed. Here the evidence is on the chart.

2. Honest per-symbol flip statistics. Every flip is stamped with its live win rate on this exact symbol and timeframe — shrinkage-adjusted so thin history cannot show fake confidence, with a Wilson confidence bound and sample count in the hover tooltip. The indicator audits itself in public instead of asserting signals.

3. Markers that settle into their outcome. Each buy and sell marker resolves ten bars later: the trend color if the flip delivered, faded gray if it failed. Scroll any chart and read the engine's true track record directly off the markers — including the losses.

4. Transparent adaptation, not a black box. The factor self-tunes between your two bounds using Perry Kaufman's Efficiency Ratio — tight when price moves cleanly, wide in chop — and the dashboard shows the live factor and efficiency reading every bar. The adaptation can be verified with a calculator; nothing asks for trust.

5. A trade plan, not just a line. On every confirmed flip the engine draws the entry, the trailing stop, and one-R and two-R reference levels, and the dashboard tracks the open signal's running R-multiple live.

6. A breathing chart. The glow between price and trail intensifies with trend distance and fades as price returns to the stop, grade-A flips (volume, efficiency, and a decisive break together) print in the accent color, and the whole layer stays capped and clean.

🔶 HOW IT WORKS

Adaptive trail: Classic ratcheting SuperTrend bands are computed from the Average True Range, with the factor interpolated between the trend bound and the chop bound by the Efficiency Ratio — the ratio of net price movement to total path length over the lookback.

Whipsaw Shield: The raw band flip is treated as a candidate, not a signal. Only a close beyond the opposite band plus the margin confirms the flip; a raw flip that reverses first is counted, marked as a ghost, and absorbed.

Statistics: Each confirmed flip records what price did ten and thirty bars later, in the flip's direction, into capped first-in-first-out databases. Win rates are pulled toward fifty percent by pseudo-samples and carry Wilson lower bounds. Until the minimum sample is met, markers read "collecting history" instead of inventing a number.

Outcome settlement: Every marker stores its flip price and recolors by the realized ten-bar outcome, then joins the capped history.

Grading: Volume z-score, efficiency level, and break decisiveness combine into an A, B, C grade on every flip.

Non-repainting: Flips, shields, grades, statistics, and settlement are all evaluated on closed bars. Once printed, nothing moves.

🔶 HOW TO USE IT

1. Works on any market — cryptocurrency, forex, gold, indices, stocks, futures — and any timeframe. Trending instruments suit tighter trend bounds; choppy ones benefit from a wider chop bound and a larger shield margin.
2. Treat the flip as regime information and the trail as the stop: the line is the invalidation, and the one-R and two-R references scale targets to the risk the stop defines.
3. Read the ghost markers as the tool working: a cluster of × marks in a range is the chop a fixed-factor SuperTrend would have traded.
4. Judge fresh flips against the settled history and the statistics rows — a symbol whose markers keep settling gray is telling you trend-following struggles there, and that is information worth having before the next flip.
5. Use the grade for position confidence: an A-grade flip with volume, high efficiency, and a decisive break is a different event from a drift-through.
6. Watch the live factor and efficiency in the dashboard to see the adaptation reasoning in real time.

🔶 SETTINGS

- Adaptive trail: Average True Range length, factor in strong trend, factor in chop, Efficiency Ratio length.
- Whipsaw Shield: flip margin and ghost marker toggle.
- Statistics: sample cap, minimum samples to grade, shrinkage strength, Wilson z-score, markers to keep.
- Trade plan toggle and plans to keep.
- Visuals: all colors, glow fill, candle tinting.
- Themeable dashboard: position, four text sizes, title band, background, frame, grid, and three text colors.

🔶 ALERTS

- Buy Flip / Sell Flip — the adaptive trail flipped with the confirmation margin cleared.
- Whipsaw Shielded — a raw flip reversed before confirming; the engine held its direction.
- Grade A Flip — full quality confluence: volume, efficiency, and a decisive break.

🔶 FREQUENTLY ASKED QUESTIONS

Does the indicator repaint? No. Every flip, shield event, grade, statistic, and marker settlement is evaluated at bar close. Once printed, nothing moves.

How is this different from other adaptive or machine-learning SuperTrends? Adaptation itself is not the claim — several tools adapt the factor. The differences are transparency and honesty: the adaptation here is one verifiable formula shown live on the dashboard, the whipsaws it absorbs are rendered instead of hidden, every signal carries its real statistics with confidence bounds, and every marker settles into its true outcome.

What does a ghost × marker mean? The raw SuperTrend flipped there and reversed before clearing the confirmation margin. The engine held its direction and counted the whipsaw it absorbed.

Why does a marker turn gray? The flip failed: ten bars later, price had not moved in its direction. Gray markers are the audit trail working — an honest tool must be able to show its losses.

Why do the win rates hover near fifty percent on some symbols? Because that is the truth of trend-flip performance there. The shrinkage and confidence bounds are designed to display small honest numbers rather than large misleading ones.

🔶 CREDITS

The SuperTrend trailing stop was created by Olivier Seban; the Average True Range is by J. Welles Wilder Jr. (1978); the Efficiency Ratio is by Perry J. Kaufman; the Wilson score interval is by Edwin B. Wilson (1927). This script gratefully acknowledges all four. The Whipsaw Shield, the transparent adaptive-factor design, the per-symbol statistical engine, the outcome-settling markers, the trade plan layer, and all code in this script are original work — no third-party or open-source script code was reused.

🔶 LIMITATIONS

Trend-following flips underperform by nature in prolonged ranges; the shield reduces but cannot eliminate that cost, and shielded entries confirm slightly later than raw ones — the margin trades earliness for reliability. Statistics need history to mature and are honest about being thin early. Volume grading is less meaningful on symbols with unreliable volume reporting. No indicator replaces independent analysis.

🔶 DISCLAIMER

This script is provided strictly for educational and informational purposes. It is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past behavior of any flip, statistic, or grade does not guarantee future results. Trading involves substantial risk. Always do your own research and manage risk independently.

## Source Code

````pine
//@version=6
indicator("SuperTrend Engine [Quantum Algo]", overlay = true, max_lines_count = 200, max_labels_count = 300, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  Concept credits: the SuperTrend trailing stop was created by
//  Olivier Seban; the Average True Range is by J. Welles Wilder
//  Jr. (1978); the Efficiency Ratio is by Perry J. Kaufman; the
//  Wilson score interval is by Edwin B. Wilson (1927). The
//  volatility-adaptive factor, the Whipsaw Shield, per-symbol
//  flip statistics, outcome-settling markers, the trade plan
//  layer and all code in this script are original work.
// ════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════
grpT = "Adaptive Trail"
atrLen = input.int(10, "Average True Range Length", minval = 2, group = grpT)
minF   = input.float(1.5, "Factor In Strong Trend", step = 0.1, minval = 0.5, group = grpT)
maxF   = input.float(4.0, "Factor In Chop", step = 0.1, minval = 1.0, group = grpT, tooltip = "The factor self-tunes between these two values using the Efficiency Ratio: tight in clean trends to lock profit, wide in chop to survive noise.")
erLen  = input.int(20, "Efficiency Ratio Length", minval = 5, maxval = 100, group = grpT)

grpW = "Whipsaw Shield"
shieldAtr = input.float(0.15, "Flip Margin (Average True Range Ratio)", step = 0.05, minval = 0.0, group = grpW, tooltip = "A flip only confirms when the close clears the opposite band by this margin. Raw flips that reverse before clearing it are shielded — and shown as ghost markers so you can see the whipsaws the engine absorbed.")
showGhost = input.bool(true, "Show Shielded Whipsaws", group = grpW)

grpS = "Flip Statistics"
cap     = input.int(300, "Samples Per Side (FIFO Cap)", minval = 50, maxval = 1000, group = grpS)
minN    = input.int(15, "Minimum Samples To Grade", minval = 5, maxval = 100, group = grpS)
shrinkK = input.int(10, "Shrinkage Strength", minval = 0, maxval = 100, group = grpS)
zConf   = input.float(1.645, "Wilson z-Score", step = 0.005, group = grpS)
keepFlips = input.int(12, "Flip Markers To Keep", minval = 4, maxval = 40, group = grpS)

grpX = "Trade Plan"
showPlan  = input.bool(true, "Draw Trade Plan On Flip", group = grpX)
keepPlans = input.int(2, "Trade Plans To Keep", minval = 1, maxval = 6, group = grpX)

grpV = "Chart Visuals"
bullCol  = input.color(#00a89d, "Bullish Color", group = grpV)
bearCol  = input.color(#e8365f, "Bearish Color", group = grpV)
goldCol  = input.color(#d99b1e, "Accent Color", group = grpV)
silvCol  = input.color(#5c6b80, "Neutral Color", group = grpV)
showGlow = input.bool(true, "Glow Fill Between Price And Trail", group = grpV)
tintBars = input.bool(true, "Tint Candles By Trend", group = grpV)

grpB = "Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = grpB)
dashPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpB)
dashSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpB)
dashTitleBg = input.color(color.new(#231a08, 0), "Title Band", group = grpB)
dashBg      = input.color(color.new(#171207, 8), "Background", group = grpB)
dashFrame   = input.color(color.new(#d99b1e, 15), "Frame", group = grpB)
dashGrid    = input.color(color.new(#d99b1e, 80), "Grid", group = grpB)
dashHeadTxt = input.color(color.new(#f0c05a, 0), "Header Text", group = grpB)
dashBodyTxt = input.color(color.new(#eef2f7, 5), "Body Text", group = grpB)
dashMuteTxt = input.color(color.new(#cdb87e, 15), "Muted Text", group = grpB)

// ════════════════════════════════════════════════════════════════
//  ADAPTIVE FACTOR  ·  Efficiency Ratio drives the band width
// ════════════════════════════════════════════════════════════════
atrV = ta.atr(atrLen)
volMa = ta.sma(volume, 50)
volSd = ta.stdev(volume, 50)
volZ  = na(volSd) or volSd == 0 ? 0.0 : (volume - volMa) / volSd
erDen = math.sum(math.abs(ta.change(close)), erLen)
er    = erDen > 0 ? math.abs(close - close[erLen]) / erDen : 0.0
factor = minF + (1.0 - er) * (maxF - minF)

f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out
fw(float p) => str.tostring(p * 100, "#") + "%"
fr(float r) => (r >= 0 ? "+" : "") + str.tostring(r * 100, "#.#") + "%"

// ════════════════════════════════════════════════════════════════
//  SUPERTREND BANDS + WHIPSAW SHIELD STATE MACHINE
// ════════════════════════════════════════════════════════════════
up = hl2 - factor * atrV
dn = hl2 + factor * atrV
var float upB = na
var float dnB = na
upB := na(upB[1]) ? up : close[1] > upB[1] ? math.max(up, upB[1]) : up
dnB := na(dnB[1]) ? dn : close[1] < dnB[1] ? math.min(dn, dnB[1]) : dn

var int rawDir = 1
rawDir := close > dnB[1] ? 1 : close < upB[1] ? -1 : nz(rawDir[1], 1)

var int  myDir = 1
var bool diverged = false
var int  shieldCnt = 0
bool ghost  = false
bool evBuy  = false
bool evSell = false
buf = shieldAtr * atrV

if barstate.isconfirmed
    if myDir == -1 and close > nz(dnB[1], dn) + buf
        myDir := 1
        diverged := false
        evBuy := true
    else if myDir == 1 and close < nz(upB[1], up) - buf
        myDir := -1
        diverged := false
        evSell := true
    else if rawDir != myDir
        diverged := true
    else
        if diverged
            shieldCnt += 1
            ghost := true
        diverged := false

trail = myDir == 1 ? upB : dnB
var int trendStart = 0
if evBuy or evSell
    trendStart := bar_index

// ── glow visualization ─────────────────────────────────────────
dirCol = myDir == 1 ? bullCol : bearCol
pTrail = plot(trail, "Adaptive Trail", color = color.new(dirCol, 0), linewidth = 2, style = plot.style_linebr)
pGhost = plot(close, "Price Anchor", color = color.new(color.white, 100), display = display.none)
glowT  = 97 - int(math.min(math.abs(close - trail) / atrV * 5, 13))
fill(pTrail, pGhost, color = showGlow ? color.new(dirCol, glowT) : na, title = "Trend Glow")
barcolor(tintBars ? color.new(dirCol, 70) : na, title = "Trend Tint")

// ════════════════════════════════════════════════════════════════
//  PER-SYMBOL FLIP STATISTICS  ·  10 / 30 bar outcomes
// ════════════════════════════════════════════════════════════════
var array<float> b10 = array.new<float>()
var array<float> b30 = array.new<float>()
var array<float> s10 = array.new<float>()
var array<float> s30 = array.new<float>()

pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()

f_feed(array<float> a10, array<float> a30, bool cond, int dir) =>
    if barstate.isconfirmed and bar_index > 30
        if cond[10]
            pushF(a10, (close / close[10] - 1) * dir)
        if cond[30]
            pushF(a30, (close / close[30] - 1) * dir)

f_feed(b10, b30, evBuy, 1)
f_feed(s10, s30, evSell, -1)

statsOf(array<float> a) =>
    int n = a.size()
    float pS_ = 0.5
    float wLB = 0.5
    float avg = 0.0
    if n > 0
        int w = 0
        float s_ = 0.0
        for i = 0 to n - 1
            r = a.get(i)
            s_ += r
            if r > 0
                w += 1
        float pHat = w * 1.0 / n
        pS_ := (pHat * n + 0.5 * shrinkK) / (n + shrinkK)
        wLB := (pHat + zConf * zConf / (2 * n) - zConf * math.sqrt(math.max(pHat * (1 - pHat) / n + zConf * zConf / (4 * n * n), 0.0))) / (1 + zConf * zConf / n)
        avg := s_ / n
    [pS_, wLB, n, avg]

// ════════════════════════════════════════════════════════════════
//  FLIP MARKERS THAT SETTLE  +  TRADE PLAN
// ════════════════════════════════════════════════════════════════
var array<label> doneLbs = array.new<label>()
var array<label> pendLbs = array.new<label>()
var array<int>   pendBar = array.new<int>()
var array<int>   pendDir = array.new<int>()
var array<float> pendPx  = array.new<float>()
var array<label> ghostLbs = array.new<label>()
var array<line>  planLn  = array.new<line>()
var float curEntry = na
var float curRisk  = na
var int lastGradeN = 0
bool evElite = false

if barstate.isconfirmed and (evBuy or evSell)
    d = evBuy ? 1 : -1
    gap = math.abs(close - nz(trail[1], trail)) / atrV
    gradeN = 1 + (volZ > 1 ? 1 : 0) + (er > 0.5 ? 1 : 0) + (gap > 0.8 ? 1 : 0)
    grade  = gradeN >= 4 ? "A" : gradeN == 3 ? "B" : "C"
    lastGradeN := gradeN
    evElite := gradeN >= 4
    [p10, w10x, n10, a10x] = statsOf(evBuy ? b10 : s10)
    [p30, w30x, n30, a30x] = statsOf(evBuy ? b30 : s30)
    graded = n10 >= minN
    txt = (evBuy ? "Buy" : "Sell") + (graded ? "  " + fw(p10) : "")
    tip = (evBuy ? "Buy Flip ▲" : "Sell Flip ▼") + " on " + syminfo.ticker + " " + timeframe.period + " · Grade " + grade + " " + f_rep("◆", gradeN) + (graded ? "\nFavorable 10 / 30 bars: " + fw(p10) + " / " + fw(p30) + "\nSamples: " + str.tostring(n10) + " · Wilson bound: " + fw(w10x) + "\nAverage 10-bar move: " + fr(a10x * d) + "\nMarker settles into its outcome after 10 bars" : "\nCollecting history (" + str.tostring(n10) + "/" + str.tostring(minN) + ") — not yet graded")
    lb = label.new(bar_index, evBuy ? low : high, txt, style = evBuy ? label.style_label_up : label.style_label_down, color = color.new(gradeN >= 4 ? goldCol : evBuy ? bullCol : bearCol, 5), textcolor = evBuy ? #06222b : #2b0612, size = size.small, tooltip = tip)
    pendLbs.push(lb)
    pendBar.push(bar_index)
    pendDir.push(d)
    pendPx.push(close)
    curEntry := close
    curRisk  := math.abs(close - trail)
    if showPlan and curRisk > 0
        x2 = bar_index + 20
        planLn.push(line.new(bar_index, close, x2, close, color = color.new(silvCol, 25)))
        planLn.push(line.new(bar_index, trail, x2, trail, color = color.new(bearCol, 25), style = line.style_dashed))
        planLn.push(line.new(bar_index, close + d * curRisk, x2, close + d * curRisk, color = color.new(bullCol, 30), style = line.style_dotted))
        planLn.push(line.new(bar_index, close + d * curRisk * 2, x2, close + d * curRisk * 2, color = color.new(bullCol, 45), style = line.style_dotted))
        while planLn.size() > keepPlans * 4
            line.delete(planLn.shift())

if barstate.isconfirmed and ghost and showGhost
    ghostLbs.push(label.new(bar_index, close, "×", style = label.style_label_center, color = color.new(color.black, 100), textcolor = color.new(silvCol, 20), size = size.small, tooltip = "Whipsaw shielded — the raw trail flipped here and reversed before clearing the confirmation margin. The engine held its direction."))
    while ghostLbs.size() > 10
        label.delete(ghostLbs.shift())

if barstate.isconfirmed and pendLbs.size() > 0
    while pendLbs.size() > 0 and bar_index - pendBar.get(0) >= 10
        lb = pendLbs.shift()
        pendBar.shift()
        d_ = pendDir.shift()
        px = pendPx.shift()
        ret = (close / px - 1) * d_
        if ret > 0
            label.set_color(lb, color.new(d_ == 1 ? bullCol : bearCol, 0))
            label.set_textcolor(lb, d_ == 1 ? #06222b : #ffffff)
        else
            label.set_color(lb, color.new(silvCol, 45))
            label.set_textcolor(lb, color.new(#eef2f7, 15))
        doneLbs.push(lb)
        while doneLbs.size() > keepFlips
            label.delete(doneLbs.shift())

// ════════════════════════════════════════════════════════════════
//  PREMIUM DASHBOARD
// ════════════════════════════════════════════════════════════════
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small

var table tb = table.new(dPos, 2, 8, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)

if showDash and barstate.islast
    [bp, bw, bn, ba] = statsOf(b10)
    [sp, sw, sn, sa] = statsOf(s10)
    openR = not na(curEntry) and not na(curRisk) and curRisk > 0 ? (close - curEntry) / curRisk * myDir : na
    table.cell(tb, 0, 0, "◈ SUPERTREND ENGINE", bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 0, f_rep("◆", math.min(4, lastGradeN)), bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = bodySize)
    table.cell(tb, 0, 1, "State", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, (myDir == 1 ? "Bullish" : "Bearish") + " · " + str.tostring(bar_index - trendStart) + " bars", text_color = myDir == 1 ? bullCol : bearCol, text_size = bodySize)
    table.cell(tb, 0, 2, "Factor", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, str.tostring(factor, "#.##") + " · Efficiency " + fw(er), text_color = er > 0.5 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 3, "Open Signal", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, na(openR) ? "—" : (openR >= 0 ? "+" : "") + str.tostring(openR, "#.#") + " R", text_color = na(openR) ? dashBodyTxt : openR >= 0 ? bullCol : bearCol, text_size = bodySize)
    table.cell(tb, 0, 4, "Buy Flips", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, bn > 0 ? fw(bp) + " ×" + str.tostring(bn) + " · " + fr(ba) : "—", text_color = bn >= minN and bp >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 5, "Sell Flips", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, sn > 0 ? fw(sp) + " ×" + str.tostring(sn) + " · " + fr(-sa) : "—", text_color = sn >= minN and sp >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Whipsaws Shielded", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, str.tostring(shieldCnt), text_color = shieldCnt > 0 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Shrunk win rates · this chart only", text_color = dashMuteTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 7, "", text_size = size.tiny)

// ════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════
alertcondition(evBuy, "Buy Flip", "The adaptive trail flipped bullish with the confirmation margin cleared.")
alertcondition(evSell, "Sell Flip", "The adaptive trail flipped bearish with the confirmation margin cleared.")
alertcondition(ghost, "Whipsaw Shielded", "A raw flip reversed before clearing the confirmation margin — the engine held its direction.")
alertcondition(evElite, "Grade A Flip", "A flip fired with full quality confluence: volume, efficiency, and a decisive break.")
````

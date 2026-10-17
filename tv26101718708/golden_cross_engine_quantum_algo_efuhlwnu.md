# Golden Cross Engine [Quantum Algo]

- url: https://www.tradingview.com/script/eFUHlwnU-Golden-Cross-Engine-Quantum-Algo/
- type: indicator
- pine_id: PUB;63f4db97691348df942c931dfec88a71
- version: 1.0

## Description

Golden Cross Engine [Quantum Algo]
====================================================

🔶 OVERVIEW

Golden Cross Engine is a complete golden cross and death cross indicator that goes far beyond marking the moving average crossover: it counts down to the next cross before it happens, grades every cross by quality, measures what golden and death crosses have actually done on the current symbol with honest statistics, and lets every cross marker settle into its real outcome so the chart itself shows which crosses worked and which failed.

The golden cross — the fast moving average crossing above the slow, classically the 50 over the 200 — is one of the most watched events in all of trading, and the death cross is its bearish mirror. Every major cross makes financial headlines. This engine turns that famous event from a headline into a measurable, projectable, and auditable object on your chart.

🔶 WHAT ARE THE GOLDEN CROSS AND DEATH CROSS?

A golden cross occurs when a faster moving average (traditionally the 50 period) closes above a slower one (traditionally the 200 period), signaling that intermediate momentum has overtaken the long-term trend — historically read as the start of a bullish regime. A death cross is the opposite: the fast average crossing below the slow, read as the start of a bearish regime. Because both averages move slowly, the cross itself is a lagging event — which is exactly why this engine adds a convergence countdown that shows the cross forming before it prints.

🔶 WHY THIS SCRIPT IS ORIGINAL

1. The convergence countdown. The engine measures the current slope of both averages and projects their geometry forward, drawing the two converging paths and marking where and when they would meet: "Golden Cross ≈ 9 bars" with the projected price level. It is a projection at current slopes — clearly labeled as such, never a forecast — and it makes the most-watched lagging signal in trading visible in advance. An approach alert fires when the countdown first enters your chosen lead window.

2. Markers that settle into their outcome. Every cross prints in neutral gold, then resolves twenty bars later: the bullish or bearish color if the cross delivered, faded gray if it failed. The chart becomes its own audit trail — scroll back and see the honest history of every cross on the symbol.

3. Per-symbol cross statistics. Using shrinkage-adjusted win rates and Wilson confidence bounds, the engine reports how often golden and death crosses were favorable on this exact symbol and timeframe at five, twenty, and sixty bars, with sample counts and average moves — on every marker's tooltip and in the dashboard. It answers "does the golden cross actually work here" with data instead of folklore.

4. Cross quality grading. Every cross is graded A, B, or C from three observable conditions: elevated volume at the cross, slope steepness of the fast average, and momentum confirmation of price relative to it. Grade A crosses are the full-confluence events.

5. A living regime fill. The zone between the averages breathes: the bullish or bearish tint intensifies as the gap widens and pales as a cross approaches, so regime strength and regime fatigue are visible at a glance. Cross bars flash once.

6. Multi-timeframe cross state. The dashboard shows whether the fast average is above or below the slow on the fifteen-minute, one-hour, four-hour, daily, and weekly timeframes simultaneously — full-stack regime alignment in two compact rows.

🔶 HOW IT WORKS

Averages: Selectable simple or exponential averages at configurable lengths, defaulting to the classic 50 and 200.

Countdown: The engine computes each average's recent slope and solves the convergence geometry. When the averages are approaching within the horizon, it draws both projected paths, the meeting diamond with the bar count, and the projected level. When they are separating, the dashboard reads Diverging.

Statistics: Each confirmed cross records what price actually did five, twenty, and sixty bars later, in the cross's direction, into capped first-in-first-out databases. Win rates are pulled toward fifty percent by pseudo-samples so a thin history cannot display fake confidence, and each rate carries a Wilson lower bound. Crosses are rare events by nature, so sample counts are honest and often small — markers read "collecting history" until the minimum is met.

Outcome settlement: Each marker stores its cross price; twenty bars later it recolors by the realized directional outcome and joins the capped history.

Grading: Volume z-score, normalized slope steepness, and price-side confirmation combine into the A, B, C grade shown on the marker tooltip and dashboard.

Non-repainting: Crosses, grades, and statistics are evaluated on closed bars. The countdown updates on the live bar by design — it is a live projection, and it is labeled as one.

🔶 HOW TO USE IT

1. The natural home is the daily chart of major symbols — indices, large-capitalization stocks, cryptocurrency — where the 50 and 200 cross is the famous event. Intraday charts work identically with proportionally more crosses and deeper samples.
2. Watch the countdown as regime alarm: a shrinking bar count with a steepening fast average means the regime change is forming in front of you.
3. Read the settled history before trusting a fresh cross: a chart full of gray markers is telling you crossovers chop on this symbol; a chart of colored ones is telling you they trend.
4. Use the grade as confluence: an A-grade cross with volume, steep slope, and price confirmation is a different event from a flat, quiet drift-through.
5. Check the timeframe rows: a golden cross on your chart while the daily and weekly already sit bullish is alignment; against them, it is a counter-trend event.
6. The statistics rows are context, not commands — favorable rates describe this chart's history, never the next cross.

🔶 SETTINGS

- Average type and both lengths.
- Countdown: projection toggle, horizon, and approach alert lead.
- Statistics: sample cap, minimum samples to grade, shrinkage strength, Wilson z-score, markers to keep.
- Visuals: all colors, gradient fill toggle, cross-bar flash toggle.
- Themeable dashboard: position, four text sizes, title band, background, frame, grid, and three text colors.

🔶 ALERTS

- Golden Cross / Death Cross — the crossover confirmed at bar close.
- Golden Cross Approaching / Death Cross Approaching — the countdown first entered the alert lead window at current slopes.
- Grade A Cross — a cross fired with full quality confluence.

🔶 FREQUENTLY ASKED QUESTIONS

Does the indicator repaint? No. Crosses, grades, statistics, and marker settlement are evaluated on closed bars. The countdown is a live-bar projection and is explicitly presented as one.

Is the countdown a prediction? No. It is where the averages meet if both keep their current slopes. Slopes change; the countdown updates with them. Its value is showing the event forming, not promising the date.

Why are the sample counts small? Because genuine crosses are rare — a daily chart may produce only a handful in years of data. The engine shows honest small numbers with confidence bounds instead of inventing large ones, and lower timeframes build deeper samples.

Why did an old cross marker turn gray? It failed: twenty bars after that cross, price had not moved in the cross's direction. Gray markers are the audit trail working.

Which lengths should I use? The classic 50 and 200 define the famous event. Faster pairs produce more crosses and richer statistics at the cost of more noise.

🔶 CREDITS

The golden cross and death cross are classical moving-average crossover concepts in the public domain of technical analysis, watched across generations of market participants. The Wilson score interval is by Edwin B. Wilson (1927), and shrinkage estimation is standard public statistics. This script gratefully acknowledges that shared lineage. The convergence countdown and projection geometry, the outcome-settling markers, the per-symbol statistical grading, the living regime fill, and all code in this script are original work — no third-party or open-source script code was reused.

🔶 LIMITATIONS

Moving average crossovers are lagging by construction, and the countdown inherits the assumption of stable slopes. Cross samples are naturally small on higher timeframes; statistics mature with history and faster settings. Volume grading is less meaningful on symbols with unreliable volume reporting. Multi-timeframe rows describe state, not signals. No indicator replaces independent analysis.

🔶 DISCLAIMER

This script is provided strictly for educational and informational purposes. It is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past behavior of any cross, projection, or statistic does not guarantee future results. Trading involves substantial risk. Always do your own research and manage risk independently.

## Source Code

````pine
//@version=6
indicator("Golden Cross Engine [Quantum Algo]", overlay = true, max_lines_count = 100, max_labels_count = 200, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  Concept credits: the golden cross and death cross are
//  classical moving-average crossover concepts in the public
//  domain of technical analysis. The Wilson score interval is
//  by Edwin B. Wilson (1927); shrinkage estimation is standard
//  public statistics. The convergence countdown, projection
//  geometry, per-symbol outcome statistics, outcome-settled
//  markers and all code in this script are original work.
// ════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════
grpM = "Moving Averages"
maTypeS = input.string("SMA", "Average Type", options = ["SMA", "EMA"], group = grpM)
fastLen = input.int(50, "Fast Length", minval = 2, group = grpM)
slowLen = input.int(200, "Slow Length", minval = 5, group = grpM)

grpP = "Cross Countdown"
showProj = input.bool(true, "Show Convergence Projection", group = grpP, tooltip = "Projects both averages forward at their current slopes and marks where and when they would meet. A projection at current speed — not a forecast.")
horizon  = input.int(60, "Countdown Horizon (Bars)", minval = 10, maxval = 200, group = grpP)
alertLead = input.int(10, "Approach Alert Lead (Bars)", minval = 2, maxval = 60, group = grpP)

grpS = "Statistics Engine"
cap     = input.int(200, "Samples Per Cross Type (FIFO Cap)", minval = 20, maxval = 500, group = grpS)
minN    = input.int(8, "Minimum Samples To Grade", minval = 3, maxval = 50, group = grpS)
shrinkK = input.int(6, "Shrinkage Strength", minval = 0, maxval = 50, group = grpS)
zConf   = input.float(1.645, "Wilson z-Score", step = 0.005, group = grpS)
keepCross = input.int(12, "Cross Markers To Keep", minval = 4, maxval = 40, group = grpS)

grpV = "Chart Visuals"
bullCol = input.color(#00a89d, "Bullish Color", group = grpV)
bearCol = input.color(#e8365f, "Bearish Color", group = grpV)
goldCol = input.color(#d99b1e, "Gold Accent", group = grpV)
silvCol = input.color(#5c6b80, "Neutral Color", group = grpV)
showFill = input.bool(true, "Gradient Fill Between Averages", group = grpV)
flashBg  = input.bool(true, "Highlight Cross Bars", group = grpV)

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
//  AVERAGES + REGIME
// ════════════════════════════════════════════════════════════════
atr  = ta.atr(14)
fMA  = maTypeS == "EMA" ? ta.ema(close, fastLen) : ta.sma(close, fastLen)
sMA  = maTypeS == "EMA" ? ta.ema(close, slowLen) : ta.sma(close, slowLen)
volMa = ta.sma(volume, 50)
volSd = ta.stdev(volume, 50)
volZ  = na(volSd) or volSd == 0 ? 0.0 : (volume - volMa) / volSd

golden = ta.crossover(fMA, sMA)
death  = ta.crossunder(fMA, sMA)
bullRegime = fMA > sMA
var int lastCrossBar = na
if golden or death
    lastCrossBar := bar_index

f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out
fw(float p) => str.tostring(p * 100, "#") + "%"
fr(float r) => (r >= 0 ? "+" : "") + str.tostring(r * 100, "#.#") + "%"

// plots + living gradient fill (intensity breathes with the gap)
pF = plot(fMA, "Fast Average", color = color.new(goldCol, 0), linewidth = 2)
pS = plot(sMA, "Slow Average", color = color.new(silvCol, 10), linewidth = 2)
gapT = 96 - int(math.min(math.abs(fMA - sMA) / atr * 4, 14))
fill(pF, pS, color = showFill ? color.new(bullRegime ? bullCol : bearCol, gapT) : na, title = "Regime Fill")
bgcolor(flashBg and (golden or death) ? color.new(goldCol, 80) : na, title = "Cross Flash")

// ════════════════════════════════════════════════════════════════
//  PER-SYMBOL CROSS STATISTICS  ·  5 / 20 / 60 bar outcomes
// ════════════════════════════════════════════════════════════════
var array<float> g5  = array.new<float>()
var array<float> g20 = array.new<float>()
var array<float> g60 = array.new<float>()
var array<float> d5  = array.new<float>()
var array<float> d20 = array.new<float>()
var array<float> d60 = array.new<float>()

pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()

f_feed(array<float> a5, array<float> a20, array<float> a60, bool cond, int dir) =>
    if barstate.isconfirmed and bar_index > 60
        if cond[5]
            pushF(a5, (close / close[5] - 1) * dir)
        if cond[20]
            pushF(a20, (close / close[20] - 1) * dir)
        if cond[60]
            pushF(a60, (close / close[60] - 1) * dir)

f_feed(g5, g20, g60, golden, 1)
f_feed(d5, d20, d60, death, -1)

statsOf(array<float> a) =>
    int n = a.size()
    float pS_ = 0.5
    float wLB = 0.5
    float avg = 0.0
    if n > 0
        int w = 0
        float s = 0.0
        for i = 0 to n - 1
            r = a.get(i)
            s += r
            if r > 0
                w += 1
        float pHat = w * 1.0 / n
        pS_ := (pHat * n + 0.5 * shrinkK) / (n + shrinkK)
        wLB := (pHat + zConf * zConf / (2 * n) - zConf * math.sqrt(math.max(pHat * (1 - pHat) / n + zConf * zConf / (4 * n * n), 0.0))) / (1 + zConf * zConf / n)
        avg := s / n
    [pS_, wLB, n, avg]

// ════════════════════════════════════════════════════════════════
//  CROSS MARKERS THAT SETTLE INTO THEIR OUTCOME
// ════════════════════════════════════════════════════════════════
var array<label> doneLbs = array.new<label>()
var array<label> pendLbs = array.new<label>()
var array<int>   pendBar = array.new<int>()
var array<int>   pendDir = array.new<int>()
var array<float> pendPx  = array.new<float>()
var int lastGradeN = 0
var string lastGrade = "—"
bool evGoldA = false

if barstate.isconfirmed and (golden or death)
    dir = golden ? 1 : -1
    slopeF = (fMA - fMA[5]) / 5
    steep  = math.abs(slopeF) / atr > 0.04
    momOK  = golden ? close > fMA : close < fMA
    gradeN = 1 + (volZ > 1 ? 1 : 0) + (steep ? 1 : 0) + (momOK ? 1 : 0)
    grade  = gradeN >= 4 ? "A" : gradeN == 3 ? "B" : "C"
    lastGradeN := gradeN
    lastGrade := grade
    evGoldA := gradeN >= 4
    [p5, w5x, n5, a5x]    = statsOf(golden ? g5 : d5)
    [p20, w20x, n20, a20x] = statsOf(golden ? g20 : d20)
    [p60, w60x, n60, a60x] = statsOf(golden ? g60 : d60)
    graded = n20 >= minN
    txt = (golden ? "Golden Cross" : "Death Cross") + (graded ? "  " + fw(p20) : "")
    tip = (golden ? "Golden Cross ▲" : "Death Cross ▼") + " on " + syminfo.ticker + " " + timeframe.period + " · Grade " + grade + " " + f_rep("◆", gradeN) + (graded ? "\n" + "Favorable 5 / 20 / 60 bars: " + fw(p5) + " / " + fw(p20) + " / " + fw(p60) + "\nSamples: " + str.tostring(n20) + " · Wilson bound: " + fw(w20x) + "\nAverage 20-bar move: " + fr(a20x * dir) + "\nMarker settles into its outcome after 20 bars" : "\nCollecting history (" + str.tostring(n20) + "/" + str.tostring(minN) + ") — not yet graded")
    lb = label.new(bar_index, golden ? low : high, txt, style = golden ? label.style_label_up : label.style_label_down, color = color.new(goldCol, 20), textcolor = #231a08, size = size.small, tooltip = tip)
    pendLbs.push(lb)
    pendBar.push(bar_index)
    pendDir.push(dir)
    pendPx.push(close)

// settle pending markers into teal / rose (worked) or faded gray (failed)
if barstate.isconfirmed and pendLbs.size() > 0
    while pendLbs.size() > 0 and bar_index - pendBar.get(0) >= 20
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
        while doneLbs.size() > keepCross
            label.delete(doneLbs.shift())

// ════════════════════════════════════════════════════════════════
//  CONVERGENCE COUNTDOWN + PROJECTION GEOMETRY
// ════════════════════════════════════════════════════════════════
slF = (fMA - fMA[3]) / 3
slS = (sMA - sMA[3]) / 3
diff = fMA - sMA
rel  = slF - slS
float nBars = na
int   cdDir = 0
if diff < 0 and rel > 0
    nBars := -diff / rel
    cdDir := 1
else if diff > 0 and rel < 0
    nBars := diff / -rel
    cdDir := -1
cdOn = not na(nBars) and nBars >= 1 and nBars <= horizon
crossPx = cdOn ? fMA + slF * nBars : na

var array<line>  prLn = array.new<line>()
var array<label> prLb = array.new<label>()
while prLn.size() > 0
    line.delete(prLn.shift())
while prLb.size() > 0
    label.delete(prLb.shift())
if showProj and barstate.islast and cdOn
    nB = int(math.round(nBars))
    prLn.push(line.new(bar_index, fMA, bar_index + nB, crossPx, color = color.new(goldCol, 20), style = line.style_dashed, width = 2))
    prLn.push(line.new(bar_index, sMA, bar_index + nB, crossPx, color = color.new(silvCol, 35), style = line.style_dashed))
    prLb.push(label.new(bar_index + nB, crossPx, "◆ " + (cdDir == 1 ? "Golden Cross" : "Death Cross") + " ≈ " + str.tostring(nB) + " bars", style = cdDir == 1 ? label.style_label_lower_left : label.style_label_upper_left, color = color.new(color.black, 100), textcolor = color.new(goldCol, 0), size = size.small, tooltip = "Where the averages meet if both keep their current slopes — a projection at current speed, not a forecast. Level ≈ " + str.tostring(crossPx, format.mintick)))

// approach alerts fire once when the countdown first enters the lead window
var bool inLeadG = false
var bool inLeadD = false
leadGNow = cdOn and cdDir == 1 and nBars <= alertLead
leadDNow = cdOn and cdDir == -1 and nBars <= alertLead
evLeadG = leadGNow and not inLeadG
evLeadD = leadDNow and not inLeadD
inLeadG := leadGNow
inLeadD := leadDNow

// ════════════════════════════════════════════════════════════════
//  MULTI-TIMEFRAME CROSS STATE
// ════════════════════════════════════════════════════════════════
f_state(string tf) =>
    request.security(syminfo.tickerid, tf, (maTypeS == "EMA" ? ta.ema(close, fastLen) : ta.sma(close, fastLen)) > (maTypeS == "EMA" ? ta.ema(close, slowLen) : ta.sma(close, slowLen)), lookahead = barmerge.lookahead_off)
s15 = f_state("15")
s60 = f_state("60")
s240 = f_state("240")
sD  = f_state("D")
sW  = f_state("W")

// ════════════════════════════════════════════════════════════════
//  PREMIUM DASHBOARD
// ════════════════════════════════════════════════════════════════
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small

var table tb = table.new(dPos, 2, 9, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)

if showDash and barstate.islast
    [gp, gw, gn, ga] = statsOf(g20)
    [dp, dw, dn, da] = statsOf(d20)
    stateTxt = (bullRegime ? "Golden Regime" : "Death Regime") + (na(lastCrossBar) ? "" : " · " + str.tostring(bar_index - lastCrossBar) + " bars")
    cdTxt = cdOn ? (cdDir == 1 ? "Golden ≈ " : "Death ≈ ") + str.tostring(int(math.round(nBars))) + " bars" : "Diverging"
    mtf = (s15 ? "15m▲" : "15m▼") + "  " + (s60 ? "1h▲" : "1h▼") + "  " + (s240 ? "4h▲" : "4h▼")
    mtf2 = (sD ? "1D▲" : "1D▼") + "  " + (sW ? "1W▲" : "1W▼")
    table.cell(tb, 0, 0, "◈ GOLDEN CROSS ENGINE", bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 0, f_rep("◆", math.min(4, lastGradeN)), bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = bodySize)
    table.cell(tb, 0, 1, "State", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, stateTxt, text_color = bullRegime ? bullCol : bearCol, text_size = bodySize)
    table.cell(tb, 0, 2, "Countdown", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, cdTxt, text_color = cdOn ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 3, "Projected Level", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, cdOn ? str.tostring(crossPx, format.mintick) : "—", text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 4, "Last Grade", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, lastGrade, text_color = lastGradeN >= 4 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 5, "Golden 20-Bar", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, gn > 0 ? fw(gp) + " ×" + str.tostring(gn) + " · " + fr(ga) : "—", text_color = gn >= minN and gp >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Death 20-Bar", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, dn > 0 ? fw(dp) + " ×" + str.tostring(dn) + " · " + fr(-da) : "—", text_color = dn >= minN and dp >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Timeframes", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 7, mtf, text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 8, "Higher", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 8, mtf2, text_color = dashBodyTxt, text_size = bodySize)

// ════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════
alertcondition(golden, "Golden Cross", "The fast average crossed above the slow average.")
alertcondition(death, "Death Cross", "The fast average crossed below the slow average.")
alertcondition(evLeadG, "Golden Cross Approaching", "The convergence countdown projects a golden cross within the alert lead window at current slopes.")
alertcondition(evLeadD, "Death Cross Approaching", "The convergence countdown projects a death cross within the alert lead window at current slopes.")
alertcondition(evGoldA, "Grade A Cross", "A cross fired with full quality confluence: volume, steep slope, and momentum confirmation.")
````

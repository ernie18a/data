# Range Breakout Verdict Engine [PhenLabs]

- url: https://www.tradingview.com/script/pGUm5VkY-Range-Breakout-Verdict-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;1631aaed43f7425b8e71f9407c9313a2
- version: 1.0

## Description

📊 Range Breakout Verdict Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
Most range tools draw a box and mark the first close outside it as a breakout. When price slips back inside a few bars later, the label is either left behind as a false signal or quietly rewritten as a “deviation”. Either way you learn the answer only after the move is over.

The Range Breakout Verdict Engine treats every breakout as a question that needs evidence. When a confirmed close leaves an auto-detected range, the breakout goes [b]under test[/b]. Each closed bar after it adds evidence for or against acceptance. The engine stops and gives one verdict, [b]ACCEPTED[/b] (continuation) or [b]DEVIATION[/b] (failed break), as soon as the evidence is strong enough for the error rates you chose. If the evidence never gets there, the test ends as SKIP.

The evidence comes from your own chart. The engine follows every past breakout to a clear outcome and learns how accepted breakouts and failed breakouts tend to behave in the bars right after the break. A verdict is a new event on a closed bar. It is never repainted or relabelled.

🚀 Points of Innovation
[list]
[*]Wald sequential probability ratio test (SPRT) applied to range breakouts: the verdict arrives on a data-dependent bar instead of after a fixed number of confirmation candles
[*]You set the tolerated false-accept and false-reject rates (α and β) directly, instead of tuning an abstract sensitivity number
[*]Likelihoods are learned from this chart’s own resolved breakouts and counted only after each outcome is known, so there is no lookahead
[*]A TESTING state replaces the usual relabel-on-failure behaviour: the provisional phase is shown in the dashboard and the verdict is a single permanent event
[*]An early verdict record on the chart scores only verdicts issued before the outcome bar, so you can see how the tool actually performs on the symbol and timeframe you are trading
[*]Automatic range detection by compression ratio: no manual anchors and no clicking points on the chart
[/list]

🔧 Core Components
[list]
[*]Compression range detector: arms a range when the high-low height of the last N closed bars is at most a set fraction of the 4N-bar context height
[*]Breakout test: the first confirmed close outside the armed range opens a test in that direction
[*]Evidence accumulator: each closed bar’s distance beyond the broken boundary, measured in range heights, is binned and converted into a log-likelihood ratio
[*]Outcome labeller: follows every breakout until a close reaches the acceptance yardstick (1.0× range height beyond) or returns past the failure depth (0.25× range height inside), then adds the breakout’s observations to the matching class
[*]Verdict gate: ACCEPTED at the upper Wald bound, DEVIATION at the lower bound, SKIP if neither is reached within the maximum test bars
[/list]

🔥 Key Features
[list]
[*]Decision-ready signals: an accepted up-break or a rejected down-break is bullish; an accepted down-break or a rejected up-break is bearish
[*]Three error-rate presets (5%, 10%, 20%) via one dropdown
[*]LEARNING gate: no verdicts until the chart has enough resolved accepted and failed breakouts (5 each by default)
[*]Chart accept rate: the share of breakouts on this chart that went on to be accepted, shown as context for every verdict
[*]14 inputs with progressive disclosure: the learning rules stay greyed out until you enable Custom Learning Rules
[*]Theme-adaptive dashboard that reads on dark and light charts, with a Table Size setting
[*]Bullish, bearish and breakout-under-test alerts, plus Pine Screener columns
[/list]

🎨 Visualization
[list]
[*]Range box: a faint dashed box while the range is armed. It turns solid in the verdict colour when a verdict is issued and stays neutral after a SKIP or LEARNING test. Only the last 4 boxes are kept
[*]Acceptance yardstick: a short dotted line, 1.0× range height beyond the broken boundary, shown only while a breakout is being tracked. It marks the distance used to label acceptance
[*]Verdict label: a small ACCEPTED ▲ / DEVIATION ▼ label placed clear of the candle, never on top of it
[*]Dashboard: state, evidence meter between the two bounds, error rates, learned trials, chart accept rate, early verdict record, last verdict and data mode
[/list]

📖 Usage Guidelines
Range Detection
[list]
[*][b]Range Length[/b] — Default: 20 — Range: 8-100 — Bars in the candidate range window. Shorter values find more, smaller ranges
[*][b]Max Compression[/b] — Default: 0.50 — Range: 0.20-0.90 — Maximum ratio of range height to the 4× longer context height. Lower values accept only tight consolidations
[/list]
Sequential Test
[list]
[*][b]Error Rates[/b] — Default: Balanced (α = β = 10%) — Options: Conservative 5%, Balanced 10%, Aggressive 20% — Lower rates need more evidence, so verdicts arrive later and more tests end as SKIP
[*][b]Max Test Bars[/b] — Default: 8 — Range: 2-30 — Closed bars after the breakout bar that the test may use before it ends as SKIP
[/list]
Learning Rules (enable Custom Learning Rules to edit)
[list]
[*][b]Acceptance Yardstick[/b] — Default: 1.0 — Range: 0.3-3.0 — Distance beyond the boundary, in range heights, that labels a past breakout ACCEPTED
[*][b]Failure Depth[/b] — Default: 0.25 — Range: 0.05-1.0 — Distance back inside the range that labels a past breakout FAILED
[*][b]Outcome Horizon[/b] — Default: 30 — Range: 5-200 — Breakouts that resolve neither way within this many bars are left out of learning
[*][b]Min Trials per Class[/b] — Default: 5 — Range: 2-50 — Resolved accepted and failed breakouts needed before verdicts start
[/list]
Visuals
[list]
[*][b]Show Range Boxes[/b] — Default: on — Toggles range boxes and the yardstick line
[*][b]Bullish / Bearish colours[/b] — Default: teal / coral — Verdict colours
[*][b]Show Dashboard[/b] and [b]Table Size[/b] — Default: on / Small — Dashboard visibility and scale
[/list]

✅ Best Use Cases
[list]
[*]Range and consolidation traders deciding whether to join a breakout or fade it back into the range
[*]Wyckoff spring / upthrust and AMD-style manipulation reads, where the question is whether the break is real
[*]Opening-range and overnight-range breakouts on index futures, gold and crypto
[*]Pine Screener scans for symbols with a fresh verdict or a breakout currently under test
[/list]

⚠️ Limitations
[list]
[*]Wald’s error bounds assume independent observations. Consecutive closes are correlated, so realised error rates can be higher than the α and β you select. The early verdict record shows what actually happened on your chart; trust it over the nominal rates
[*]Verdicts need learning history. A chart with few resolved breakouts stays in LEARNING, so use enough history or a lower timeframe
[*]Evidence is pooled across test bars and is based on closing prices only; wicks and volume are not used
[*]Only one breakout is tracked at a time. While a breakout is being followed to its outcome, no new range is armed
[*]Statistics are specific to the symbol, timeframe and settings. Changing any of them restarts learning
[/list]

💡 What Makes This Unique
[list]
[*]Evidence-timed verdicts: the tool waits exactly as long as the evidence needs, no fixed confirmation candle count
[*]No relabelling: the provisional phase is explicit, so historical signals on the chart are the signals you would have seen live
[*]Measured, not named: the only percentages shown are counts of real outcomes on your chart
[/list]

⚙️ Under the Hood
[list]
[*][b]Sequential probability ratio test[/b]: each closed test bar adds ln P(bin | accepted) − ln P(bin | failed) to a running total. The test stops at Wald’s bounds A = ln((1 − β) / α) and B = ln(β / (1 − α)), so the stopping rule follows directly from the error rates you pick
[*][b]Chart-learned likelihood histograms[/b]: two 6-bin integer arrays store how often accepted and failed breakouts produced each close distance (in range heights). They use Laplace smoothing and are updated only when a breakout’s outcome resolves, which keeps the current test free of future information
[*][b]Closed-bar state machine[/b]: scanning → range armed → testing → outcome tracking. Every transition sits behind barstate.isconfirmed, the range uses the previous N bars only, and no request.* call or lookahead is involved
[*][b]Object budget[/b]: explicit max_boxes_count, max_lines_count and max_labels_count, with the script deleting its own oldest boxes and labels rather than relying on garbage collection
[*][b]Data mode / plan note[/b]: OHLC only. Every TradingView plan gets the full feature set, and the dashboard’s Data mode row shows “OHLC · all plans”
[*][b]Screener & alerts[/b]: the first four plots, Verdict Signal (+1 / −1 / 0), Evidence LLR, State (0 / 1 / 2) and Chart Accept Rate %, are exposed to the Pine Screener and the Data Window. Filter on Verdict Signal = 1 or −1 for fresh verdicts, or State = 2 for breakouts under test. Alert conditions: RBVE Bullish Verdict, RBVE Bearish Verdict, RBVE Breakout Under Test
[/list]

🔬 How It Works
[list=1]
[*]Range arming: on each closed bar the engine compares the previous N-bar height with the previous 4N-bar height. When the ratio is at or below Max Compression and the close is inside, the range is frozen and drawn
[*]Breakout: the first close above the range high or below the range low opens a test, and the breakout bar is the first observation
[*]Evidence: each test bar’s close distance beyond the boundary (negative when back inside) is binned and its log-likelihood ratio is added. The dashboard meter shows where the total sits between the two bounds
[*]Verdict: crossing the upper bound gives ACCEPTED, crossing the lower bound gives DEVIATION, and reaching Max Test Bars first gives SKIP. One verdict per breakout
[*]Learning: the breakout is followed until it reaches the yardstick (accepted), returns past the failure depth (failed), or times out (discarded). Resolved observations update the histograms used by every later test
[/list]

[quote]💡 Note:
Start on a liquid symbol with plenty of history, such as BTCUSDT, ETHUSDT, ES or NQ futures, or XAUUSD on 15m to 4h, and let the dashboard leave LEARNING before acting on verdicts. Check the early verdict record against the chart accept rate: the verdict is only worth following if its record is clearly better than the base rate on your market. You can move the dashboard to the chart’s bottom panel from the script’s More menu for a clutter-free chart. This tool is an analytical aid for studying breakout behaviour, not financial advice.[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PhenLabs

//@version=6
indicator("Range Breakout Verdict Engine [PhenLabs]", shorttitle = "RBVE [PhenLabs]", overlay = true, max_boxes_count = 12, max_lines_count = 6, max_labels_count = 40)

// ═══════════════════════════════════════════════════════════════════════════
// Range Breakout Verdict Engine
// A confirmed close outside an auto-detected range opens a TEST. Every closed
// bar adds evidence to a Wald sequential probability ratio test (SPRT) whose
// likelihoods are learned from this chart's own resolved breakouts. The test
// stops with ACCEPTED (continuation) or DEVIATION (failed break) the moment the
// evidence crosses the bounds set by your chosen error rates, or SKIP if it
// never does. The verdict is a new event on a closed bar and is never rewritten.
// ═══════════════════════════════════════════════════════════════════════════

enum ErrRate
    conservative = "Conservative (α = β = 5%)"
    balanced     = "Balanced (α = β = 10%)"
    aggressive   = "Aggressive (α = β = 20%)"

enum TSize
    tiny   = "Tiny"
    small  = "Small"
    normal = "Normal"

// ── Inputs ────────────────────────────────────────────────────────────────
const string G_R = "Range Detection"
const string G_T = "Sequential Test"
const string G_L = "Learning Rules"
const string G_V = "Visuals"

int   rngLen  = input.int(20, "Range Length", minval = 8, maxval = 100, group = G_R, tooltip = "Bars in the candidate range window. The range is the high/low of the previous N closed bars.")
float cmpMax  = input.float(0.50, "Max Compression", minval = 0.20, maxval = 0.90, step = 0.05, group = G_R, tooltip = "Range height ÷ height of the 4× longer context window. Lower values accept only tighter consolidations.")
ErrRate errIn = input.enum(ErrRate.balanced, "Error Rates", group = G_T, tooltip = "α = tolerated rate of ACCEPTED verdicts on breakouts that fail. β = tolerated rate of DEVIATION verdicts on breakouts that hold. Lower rates need more evidence, so verdicts arrive later and more tests end in SKIP.")
int   maxK    = input.int(8, "Max Test Bars", minval = 2, maxval = 30, group = G_T, tooltip = "Closed bars after the breakout bar that the test may use. If the evidence never crosses a bound, the test ends as SKIP.")
bool  advOn   = input.bool(false, "Custom Learning Rules", group = G_L, tooltip = "Off = defaults (1.0× yardstick, 0.25× failure depth, 30-bar horizon, 5 trials per class).")
float yardIn  = input.float(1.0, "Acceptance Yardstick (× range height)", minval = 0.3, maxval = 3.0, step = 0.1, group = G_L, active = advOn, tooltip = "A breakout is labelled ACCEPTED for learning when a close reaches this distance beyond the broken boundary.")
float failIn  = input.float(0.25, "Failure Depth (× range height)", minval = 0.05, maxval = 1.0, step = 0.05, group = G_L, active = advOn, tooltip = "A breakout is labelled FAILED for learning when a close returns this far back inside the range.")
int   horIn   = input.int(30, "Outcome Horizon (bars)", minval = 5, maxval = 200, group = G_L, active = advOn, tooltip = "Breakouts that resolve neither way within this many bars are discarded from learning.")
int   nMinIn  = input.int(5, "Min Trials per Class", minval = 2, maxval = 50, group = G_L, active = advOn, tooltip = "Resolved ACCEPTED and FAILED breakouts required before verdicts are issued. Until then the dashboard shows LEARNING.")
bool  showBox = input.bool(true, "Show Range Boxes", group = G_V)
color bullCol = input.color(#22C3A6, "Bullish", group = G_V, inline = "pal")
color bearCol = input.color(#F0506E, "Bearish", group = G_V, inline = "pal")
bool  showDash = input.bool(true, "Show Dashboard", group = G_V)
TSize tsIn    = input.enum(TSize.small, "Table Size", group = G_V, active = showDash)

// ── Effective parameters ──────────────────────────────────────────────────
float yardE   = advOn ? yardIn : 1.0
float failE   = advOn ? failIn : 0.25
int   nMinE   = advOn ? nMinIn : 5
int   horE    = math.max(advOn ? horIn : 30, maxK + 1)
float alphaE  = errIn == ErrRate.conservative ? 0.05 : errIn == ErrRate.balanced ? 0.10 : 0.20
float betaE   = alphaE
float upperA  = math.log((1.0 - betaE) / alphaE)
float lowerB  = math.log(betaE / (1.0 - alphaE))
string tblSz  = tsIn == TSize.tiny ? size.tiny : tsIn == TSize.small ? size.small : size.normal
color neutral = color.new(chart.fg_color, 55)
const int NB  = 6

// ── Helpers (pure) ────────────────────────────────────────────────────────
// Bin a signed, range-normalised close distance beyond the broken boundary.
f_bin(float x) =>
    x < -0.25 ? 0 : x < 0.0 ? 1 : x < 0.15 ? 2 : x < 0.35 ? 3 : x < 0.70 ? 4 : 5

// Laplace-smoothed log-likelihood ratio of one observation: ln P(bin|ACCEPTED) / P(bin|FAILED).
f_lr(int b, array<int> ca, array<int> cf, int nA, int nF) =>
    float pa = (ca.get(b) + 1.0) / (nA + NB)
    float pf = (cf.get(b) + 1.0) / (nF + NB)
    math.log(pa / pf)

f_pct(int num, int den) =>
    den > 0 ? str.tostring(math.round(100.0 * num / den)) + "%" : "—"

// ── Series used inside the confirmed-bar block (computed every bar) ──────
float hiW = ta.highest(high, rngLen)
float loW = ta.lowest(low, rngLen)
float hiC = ta.highest(high, rngLen * 4)
float loC = ta.lowest(low, rngLen * 4)

// ── Persistent state ──────────────────────────────────────────────────────
// state: 0 = scanning, 1 = range armed, 2 = breakout under test / outcome tracking
var int   state   = 0
var float rTop    = na
var float rBot    = na
var int   rFormed = na
var box   curBox  = na
var array<box> boxHist = array.new<box>()

var int   tDir    = 0
var float tBound  = na
var float tH      = na
var int   tBar    = na
var int   tK      = -1
var float llr     = 0.0
var int   vK      = -1     // test bar on which the verdict was issued
var int   verdict = 0      // 0 pending, 1 ACCEPTED, -1 DEVIATION, 2 SKIP, 3 LEARNING (no verdict)
var array<int> obs = array.new<int>()

var array<int> cntA = array.new<int>(NB, 0)
var array<int> cntF = array.new<int>(NB, 0)
var int nObsA = 0
var int nObsF = 0
var int nTrA  = 0
var int nTrF  = 0
var int nUnres = 0

var int accV   = 0
var int accHit = 0
var int devV   = 0
var int devHit = 0

var int   lastV     = 0
var int   lastVDir  = 0
var int   lastVBar  = na
var line  yLine     = na
var array<label> labs = array.new<label>()

bool bullSig   = false
bool bearSig   = false
bool testStart = false

// ── Engine (closed bars only) ─────────────────────────────────────────────
if barstate.isconfirmed
    // 1) Range detection
    if state == 0
        float wH = hiW[1] - loW[1]
        float cH = hiC[1] - loC[1]
        if not na(wH) and not na(cH) and cH > 0 and wH > syminfo.mintick * 2 and wH <= cmpMax * cH and close <= hiW[1] and close >= loW[1]
            rTop    := hiW[1]
            rBot    := loW[1]
            rFormed := bar_index
            state   := 1
            if showBox
                curBox := box.new(bar_index - rngLen, rTop, bar_index, rBot, border_color = neutral, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(chart.fg_color, 94))
                boxHist.push(curBox)
                if boxHist.size() > 4
                    box.delete(boxHist.shift())
    // 2) Armed range: breakout, expiry, or extend
    else if state == 1
        if close > rTop or close < rBot
            tDir    := close > rTop ? 1 : -1
            tBound  := tDir == 1 ? rTop : rBot
            tH      := rTop - rBot
            tBar    := bar_index
            tK      := -1
            llr     := 0.0
            vK      := -1
            obs.clear()
            verdict := nTrA >= nMinE and nTrF >= nMinE ? 0 : 3
            state   := 2
            testStart := true
            if showBox and not na(curBox)
                box.set_right(curBox, bar_index)
                if not na(yLine)
                    line.delete(yLine)
                float yLvl = tBound + tDir * yardE * tH
                yLine := line.new(bar_index, yLvl, bar_index + maxK, yLvl, color = neutral, style = line.style_dotted, width = 1)
        else if bar_index - rFormed > 2 * rngLen
            state := 0
            if not na(curBox)
                box.delete(curBox)
                if boxHist.size() > 0
                    boxHist.pop()
                curBox := na
        else if showBox and not na(curBox)
            box.set_right(curBox, bar_index)

    // 3) Test step (runs on the breakout bar itself as k = 0)
    if state == 2
        tK += 1
        float x = tDir * (close - tBound) / tH
        int   b = f_bin(x)
        if tK <= maxK
            obs.push(b)
            if verdict == 0
                llr += f_lr(b, cntA, cntF, nObsA, nObsF)
                if llr >= upperA
                    verdict := 1
                else if llr <= lowerB
                    verdict := -1
                else if tK == maxK
                    verdict := 2
                if verdict == 1 or verdict == -1
                    vK := tK
                    int sDir = verdict == 1 ? tDir : -tDir
                    bullSig  := sDir == 1
                    bearSig  := sDir == -1
                    lastV    := verdict
                    lastVDir := sDir
                    lastVBar := bar_index
                    color sc = sDir == 1 ? bullCol : bearCol
                    string tx = (verdict == 1 ? "ACCEPTED" : "DEVIATION") + (sDir == 1 ? " ▲" : " ▼")
                    float ly = sDir == 1 ? low - 0.12 * tH : high + 0.12 * tH
                    labs.push(label.new(bar_index, ly, tx, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(sc, 15), style = sDir == 1 ? label.style_label_up : label.style_label_down, textcolor = color.white, size = size.small))
                    if labs.size() > 20
                        label.delete(labs.shift())
                    if not na(curBox)
                        box.set_border_color(curBox, sc)
                        box.set_border_style(curBox, line.style_solid)
                        box.set_bgcolor(curBox, color.new(sc, 92))

        // Outcome labelling for learning (independent of the verdict)
        int outc = x >= yardE ? 1 : x <= -failE ? -1 : tK >= horE ? 2 : 0
        if outc != 0
            if verdict == 0
                verdict := 2
            if outc == 1 or outc == -1
                for ob in obs
                    if outc == 1
                        cntA.set(ob, cntA.get(ob) + 1)
                        nObsA += 1
                    else
                        cntF.set(ob, cntF.get(ob) + 1)
                        nObsF += 1
                if outc == 1
                    nTrA += 1
                else
                    nTrF += 1
                // Verdict record counts only verdicts issued BEFORE the outcome bar,
                // so a deviation called on the bar that already closed deep inside is not scored.
                if verdict == 1 and vK < tK
                    accV   += 1
                    accHit += outc == 1 ? 1 : 0
                else if verdict == -1 and vK < tK
                    devV   += 1
                    devHit += outc == -1 ? 1 : 0
            else
                nUnres += 1
            if not na(yLine)
                line.delete(yLine)
            yLine  := na
            curBox := na
            state  := 0

// ── Pine Screener / Data Window columns (first plots) ─────────────────────
int sigCode = bullSig ? 1 : bearSig ? -1 : 0
plot(sigCode, "Verdict Signal (+1 bull / -1 bear)", color = chart.fg_color, display = display.data_window + display.pine_screener)
plot(state == 2 and verdict == 0 ? llr : 0.0, "Evidence LLR", color = chart.fg_color, display = display.data_window + display.pine_screener)
plot(state, "State (0 scan / 1 range / 2 test)", color = chart.fg_color, display = display.data_window + display.pine_screener)
plot(nTrA + nTrF > 0 ? 100.0 * nTrA / (nTrA + nTrF) : na, "Chart Accept Rate %", color = chart.fg_color, display = display.data_window + display.pine_screener)

// Price-scale anchors (invisible) so drawings stay calibrated to the symbol scale
plot(high, "Anchor High", color = color.new(color.gray, 100), display = display.pane, editable = false)
plot(low, "Anchor Low", color = color.new(color.gray, 100), display = display.pane, editable = false)

// ── Alerts ────────────────────────────────────────────────────────────────
alertcondition(bullSig, "RBVE Bullish Verdict", "RBVE bullish verdict (accepted up-break or rejected down-break) on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearSig, "RBVE Bearish Verdict", "RBVE bearish verdict (accepted down-break or rejected up-break) on {{ticker}} {{interval}} at {{close}}")
alertcondition(testStart, "RBVE Breakout Under Test", "RBVE: range breakout under sequential test on {{ticker}} {{interval}} at {{close}}")

// ── Dashboard ─────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(chart.bg_color, 8), border_color = color.new(chart.fg_color, 80), border_width = 1, frame_color = color.new(chart.fg_color, 70), frame_width = 1)

if showDash and barstate.islast
    color fg  = chart.fg_color
    color dim = color.new(chart.fg_color, 35)
    bool ready = nTrA >= nMinE and nTrF >= nMinE

    string stTxt = state == 0 ? "SCANNING" : state == 1 ? "RANGE ARMED · " + str.tostring(bar_index - rFormed) + " bars" : verdict == 0 ? "TESTING " + (tDir == 1 ? "▲ " : "▼ ") + str.tostring(math.max(tK, 0)) + "/" + str.tostring(maxK) : verdict == 3 ? "TRACKING (learning)" : "TRACKING OUTCOME"
    color stCol = state == 2 and verdict == 0 ? (tDir == 1 ? bullCol : bearCol) : fg

    int seg = 10
    float pos = (llr - lowerB) / (upperA - lowerB)
    int fillN = state == 2 and verdict == 0 ? int(math.round(math.max(0.0, math.min(1.0, pos)) * seg)) : 0
    string meter = ""
    for i = 1 to seg
        meter += i <= fillN ? "■" : "□"
    string evTxt = state == 2 and verdict == 0 ? meter + "  " + str.tostring(llr, "#.##") : "±" + str.tostring(upperA, "#.##") + " bounds"
    color evCol = state == 2 and verdict == 0 ? (llr >= 0 ? bullCol : bearCol) : dim

    string lrnTxt = "Acc " + str.tostring(nTrA) + " · Fail " + str.tostring(nTrF) + (ready ? "" : "  (LEARNING " + str.tostring(nMinE) + "+ each)")
    string recTxt = "ACC " + str.tostring(accHit) + "/" + str.tostring(accV) + " · DEV " + str.tostring(devHit) + "/" + str.tostring(devV)
    string lvTxt = lastV == 0 ? "—" : (lastV == 1 ? "ACCEPTED" : "DEVIATION") + (lastVDir == 1 ? " ▲ · " : " ▼ · ") + str.tostring(bar_index - lastVBar) + " bars ago"
    color lvCol = lastV == 0 ? dim : lastVDir == 1 ? bullCol : bearCol

    table.cell(dash, 0, 0, "RBVE", text_color = fg, text_size = tblSz, text_halign = text.align_left, text_formatting = text.format_bold)
    table.cell(dash, 1, 0, "Range Breakout Verdict", text_color = dim, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 1, "State", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 1, stTxt, text_color = stCol, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 2, "Evidence", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 2, evTxt, text_color = evCol, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 3, "Error rates", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 3, "α " + str.tostring(math.round(alphaE * 100)) + "% · β " + str.tostring(math.round(betaE * 100)) + "%", text_color = fg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 4, "Learned", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 4, lrnTxt, text_color = ready ? fg : dim, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 5, "Chart accept rate", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 5, f_pct(nTrA, nTrA + nTrF), text_color = fg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 6, "Early verdict record", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 6, recTxt, text_color = fg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 7, "Last verdict", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 7, lvTxt, text_color = lvCol, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 8, "Data mode", text_color = dim, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 8, "OHLC · all plans", text_color = fg, text_size = tblSz, text_halign = text.align_right)
````

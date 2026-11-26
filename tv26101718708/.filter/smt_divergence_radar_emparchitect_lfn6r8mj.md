# SMT Divergence Radar [EmpArchitect]

- url: https://www.tradingview.com/script/lfN6r8MJ-SMT-Divergence-Radar-EmpArchitect/
- type: indicator
- pine_id: PUB;012d6381fc6b4a429d8c0146fc981940
- version: 1.0

## Description

█ OVERVIEW

SMT Divergence Radar [EmpArchitect] detects SMT divergence between the chart symbol and a correlated comparison symbol.

When two correlated markets disagree at confirmed swing points, that disagreement can provide useful structure context. One market may make a higher high while the other fails, or one may make a lower low while the other holds.

The radar anchors on the chart symbol’s confirmed pivots and samples the comparison symbol at those same bars. This keeps the comparison consistent without manually switching overlays or trying to match two separate pivot streams.

No signals. No entries. No targets. No financial advice.

█ WHAT IT DETECTS

Bearish SMT:
At a confirmed swing high, the chart symbol and comparison symbol disagree. One market makes a higher high while the other does not.

Bullish SMT:
At a confirmed swing low, the chart symbol and comparison symbol disagree. One market makes a lower low while the other does not.

Divergence is drawn as a dashed line between the relevant chart pivots, with a graded SMT label.

█ HOW IT WORKS

1. Detects confirmed pivot highs and lows on the chart symbol.
2. Samples the comparison symbol’s high or low at those exact pivot bars.
3. Checks whether both markets confirmed the same higher-high or lower-low behavior.
4. Marks divergence when the two symbols disagree.
5. Grades the SMT by chart swing magnitude relative to ATR.

Using identical pivot bars keeps the model simple and consistent.

█ GRADING

Each SMT is graded by the size of the chart swing involved:

A — large divergence swing
B — moderate divergence swing
C — minimum qualifying swing

The grade is not a trade signal. It only describes the size of the detected swing disagreement.

█ COMPARISON SYMBOL

Default comparison is ETHUSDT, suited for BTC charts. You can change the comparison symbol based on the market being reviewed.

Examples:

Crypto:
• BTC vs ETH
• ETH vs BTC
• SOL vs BTC

Indices:
• NQ vs ES
• ES vs YM

Metals / FX:
• XAUUSD vs DXY
• EURUSD vs GBPUSD

Choose a genuinely correlated comparison symbol. SMT only has useful meaning when the two markets normally move with some relationship.

█ DISPLAY

SMT divergence lines and labels appear when the chart symbol and comparison symbol disagree at a confirmed swing.

Optional swing-point dots can be enabled in settings. They are hidden by default to keep the chart clean.

█ DASHBOARD

The dashboard shows:

• Compare — the comparison symbol in use
• Bull SMT — bullish SMT marks currently shown
• Bear SMT — bearish SMT marks currently shown
• Last — most recent SMT event
• Status — Watching pivots / SMT found

█ DETECTION SETTINGS

• Comparison Symbol — correlated market used for comparison
• Pivot Length — controls swing sensitivity
• Min Swing Distance ATR — filters insignificant swings
• Max SMT Marks — caps visible divergence marks
• Show Swing Points — toggles confirmed pivot dots
• Show SMT Labels — toggles text labels
• Show Divergence Lines — toggles SMT lines

█ ALERTS

Included alerts:

• Bullish SMT detected
• Bearish SMT detected
• Any SMT detected

Structure context only. Not trade signals. Use alerts with Once Per Bar Close.

█ PAIRS WITH

Smart Liquidity Map [EmpArchitect] — liquidity context
HTF Context Overlay [EmpArchitect] — higher-timeframe reference levels
ICT Dealing Range [EmpArchitect] — premium / discount context
Breaker Block Detector [EmpArchitect] — failed OB zones
ICT FVG Repricing Zones [EmpArchitect] — displacement imbalance
Liquidity Trap Zones [EmpArchitect] — failed reversal context

█ NOTES

• Works on correlated instruments across all timeframes
• Best viewed on 15M–4H charts
• Requires a genuinely correlated comparison symbol
• Bar-close confirmed / non-repainting by design
• Pine Script v6
• Open-source
• Built by EmpArchitect
• Educational context tool only
• Not financial advice
• Not a signal service

## Source Code

````pine
//@version=6
indicator("SMT Divergence Radar [EmpArchitect]", shorttitle="SMT Radar [EA]", overlay=true, max_labels_count=300, max_lines_count=200)

// ═══════════════════════════════════════════════════════════════════
// SMT DIVERGENCE RADAR [EmpArchitect] v1.0
//
// When correlated markets disagree at swing points, structure changes.
// Anchors on the chart symbol's confirmed pivots and compares the
// comparison symbol's price at those same bars.
//
// No signals. No entries. No targets.
// ═══════════════════════════════════════════════════════════════════

// ─────────────── INPUTS ───────────────

grp1 = "Detection"
compSymbol  = input.symbol("BINANCE:ETHUSDT", "Comparison Symbol", group=grp1, tooltip="The correlated symbol to compare against.")
pivotLen    = input.int(3, "Pivot Length", minval=2, maxval=20, group=grp1)
minSwingATR = input.float(0.15, "Min Swing Distance ATR", minval=0.0, maxval=2.0, step=0.05, group=grp1, tooltip="Minimum swing size vs ATR to qualify.")

grp2 = "Display"
showBull    = input.bool(true, "Show Bullish SMT", group=grp2)
showBear    = input.bool(true, "Show Bearish SMT", group=grp2)
showLines   = input.bool(true, "Show Divergence Lines", group=grp2)
showLabels  = input.bool(true, "Show SMT Labels", group=grp2)
showSwings  = input.bool(false, "Show Swing Points", group=grp2, tooltip="Marks confirmed chart pivots so you can see the detector is active.")
showDash    = input.bool(true, "Show Dashboard", group=grp2)
maxMarks    = input.int(8, "Max SMT Marks", minval=5, maxval=50, group=grp2)

grp3 = "Style"
bullCol     = input.color(color.new(#00D9A3, 0), "Bullish SMT", group=grp3)
bearCol     = input.color(color.new(#F59E0B, 0), "Bearish SMT", group=grp3)

// ─────────────── ATR + GUARD ───────────────

atr = ta.atr(14)
atrRef = atr[pivotLen]
bool confirmed = barstate.isconfirmed

// ─────────────── COMPARISON DATA ───────────────

[compHigh, compLow] = request.security(compSymbol, timeframe.period, [high, low], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─────────────── CHART PIVOTS ───────────────

curPH = ta.pivothigh(high, pivotLen, pivotLen)
curPL = ta.pivotlow(low, pivotLen, pivotLen)

bool newPH = confirmed and not na(curPH)
bool newPL = confirmed and not na(curPL)

// ─────────────── TRACK CHART PIVOTS + COMPARISON SAMPLED AT SAME BARS ───────────────

// Highs: chart pivot value + bar, and comparison HIGH sampled at that pivot bar
var float lastPH = na
var int   lastPHbar = na
var float lastPHcomp = na
var float prevPH = na
var int   prevPHbar = na
var float prevPHcomp = na

// Lows
var float lastPL = na
var int   lastPLbar = na
var float lastPLcomp = na
var float prevPL = na
var int   prevPLbar = na
var float prevPLcomp = na

if newPH
    prevPH := lastPH
    prevPHbar := lastPHbar
    prevPHcomp := lastPHcomp
    lastPH := curPH
    lastPHbar := bar_index - pivotLen
    lastPHcomp := compHigh[pivotLen]   // comparison high at the chart's pivot bar

if newPL
    prevPL := lastPL
    prevPLbar := lastPLbar
    prevPLcomp := lastPLcomp
    lastPL := curPL
    lastPLbar := bar_index - pivotLen
    lastPLcomp := compLow[pivotLen]    // comparison low at the chart's pivot bar

// ─────────────── STATE ───────────────

var bool evtBullSMT = false
var bool evtBearSMT = false
var string lastEvent = "—"
var string status = "Watching pivots"

evtBullSMT := false
evtBearSMT := false

var label[] smtLabels = array.new_label()
var line[]  smtLines  = array.new_line()
var bool[]  smtIsBull = array.new_bool()
var label[] swingLabels = array.new_label()

f_smtGrade(float a, float b) =>
    float diverge = math.abs(a - b)
    float ratio = not na(atrRef) and atrRef > 0 ? diverge / atrRef : 0.0
    ratio >= 1.0 ? "A" : ratio >= 0.35 ? "B" : "C"

// ─────────────── SWING MARKERS (always show detector is alive) ───────────────

if showSwings and newPH
    lb = label.new(bar_index - pivotLen, curPH, "•", style=label.style_none, textcolor=color.new(#9CA3AF, 75), size=size.tiny, yloc=yloc.abovebar)
    array.push(swingLabels, lb)

if showSwings and newPL
    lb = label.new(bar_index - pivotLen, curPL, "•", style=label.style_none, textcolor=color.new(#9CA3AF, 75), size=size.tiny, yloc=yloc.belowbar)
    array.push(swingLabels, lb)

while array.size(swingLabels) > 60
    label.delete(array.shift(swingLabels))

// ─────────────── SMT DETECTION (chart-anchored) ───────────────
// Compares chart and comparison at the SAME two pivot bars.
// Bearish: chart and comparison disagree on higher-high.
// Bullish: chart and comparison disagree on lower-low.

bool bearSMT = false
if newPH and not na(lastPH) and not na(prevPH) and not na(lastPHcomp) and not na(prevPHcomp)
    bool chartHH = lastPH > prevPH
    bool compHH  = lastPHcomp > prevPHcomp
    bool disagreement = chartHH != compHH
    bool minSwing = not na(atrRef) and atrRef > 0 and math.abs(lastPH - prevPH) >= minSwingATR * atrRef
    bearSMT := disagreement and minSwing

bool bullSMT = false
if newPL and not na(lastPL) and not na(prevPL) and not na(lastPLcomp) and not na(prevPLcomp)
    bool chartLL = lastPL < prevPL
    bool compLL  = lastPLcomp < prevPLcomp
    bool disagreement = chartLL != compLL
    bool minSwing = not na(atrRef) and atrRef > 0 and math.abs(lastPL - prevPL) >= minSwingATR * atrRef
    bullSMT := disagreement and minSwing

// ─────────────── DRAW SMT ───────────────

if bearSMT and showBear
    string grade = f_smtGrade(lastPH, prevPH)
    line ln = na
    if showLines and not na(prevPHbar) and not na(lastPHbar)
        ln := line.new(prevPHbar, prevPH, lastPHbar, lastPH, color=color.new(bearCol, 20), style=line.style_dashed, width=2)
    label lb = na
    if showLabels
        lb := label.new(lastPHbar, lastPH, "Bear SMT " + grade, style=label.style_label_down, color=color.new(bearCol, 65), textcolor=color.white, size=size.tiny)
    array.push(smtLines, ln)
    array.push(smtLabels, lb)
    array.push(smtIsBull, false)
    evtBearSMT := true
    lastEvent := "Bear SMT " + grade
    status := "SMT found"

if bullSMT and showBull
    string grade = f_smtGrade(lastPL, prevPL)
    line ln = na
    if showLines and not na(prevPLbar) and not na(lastPLbar)
        ln := line.new(prevPLbar, prevPL, lastPLbar, lastPL, color=color.new(bullCol, 20), style=line.style_dashed, width=2)
    label lb = na
    if showLabels
        lb := label.new(lastPLbar, lastPL, "Bull SMT " + grade, style=label.style_label_up, color=color.new(bullCol, 65), textcolor=color.white, size=size.tiny)
    array.push(smtLines, ln)
    array.push(smtLabels, lb)
    array.push(smtIsBull, true)
    evtBullSMT := true
    lastEvent := "Bull SMT " + grade
    status := "SMT found"

// ─────────────── OBJECT CAP (all arrays aligned) ───────────────

while array.size(smtIsBull) > maxMarks
    array.shift(smtIsBull)
    oldLb = array.shift(smtLabels)
    if not na(oldLb)
        label.delete(oldLb)
    oldLn = array.shift(smtLines)
    if not na(oldLn)
        line.delete(oldLn)

// Visible counts for dashboard
int bullVisible = 0
int bearVisible = 0
if array.size(smtIsBull) > 0
    for i = 0 to array.size(smtIsBull) - 1
        if array.get(smtIsBull, i)
            bullVisible += 1
        else
            bearVisible += 1

// ─────────────── DASHBOARD ───────────────

string compName = str.replace_all(str.replace_all(compSymbol, "BINANCE:", ""), "BYBIT:", "")
compName := str.replace_all(compName, ".P", "")

var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 82), border_width=0)

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 5)
    table.cell(dash, 0, 0, "SMT Radar", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0", text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 1, "Compare", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 1, compName, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Bull SMT", text_color=#00D9A3, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(bullVisible), text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Bear SMT", text_color=#F59E0B, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(bearVisible), text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Last", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 4, lastEvent, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Status", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 5, status, text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)
else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 5)

// ─────────────── ALERTS ───────────────

alertcondition(evtBullSMT, title="Bullish SMT Detected", message="Bullish SMT divergence detected. Structure context only.")
alertcondition(evtBearSMT, title="Bearish SMT Detected", message="Bearish SMT divergence detected. Structure context only.")
alertcondition(evtBullSMT or evtBearSMT, title="SMT Detected", message="SMT divergence detected between chart and comparison symbol. Structure context only.")
````

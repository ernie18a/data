# MONeY Phlow

- url: https://www.tradingview.com/script/LFbBakUE-MONeY-Phlow/
- type: indicator
- pine_id: PUB;e597d74034a047a9bf8424f641d172a7
- version: 1.0

## Description

Every money flow index or oscillator keeps a memory, though almost none says how long it lasts. A reading that has favored buyers for twenty bars might describe a crowd that keeps renewing its bids. Then again, it might also describe a crowd that left fifteen bars ago while the arithmetic of a thirteen-bar window kept its old verdict on the screen. The two cases may draw an identical line, and call for opposite faces of patience.

MONeY Phlow (short title "MONeYφ") adds the missing clock. 

The tool draws a Money Flow Index with a regime heatmap, a pulse, event markers and a compact readout. Then counts how often ownership of the flow changes hands and converts that count into a half-life a trader can hold in mind. A table prints what the pane can only imply. The sections below explain the pane, the memory engine, and an hourly reading of Moderna chart at the time of writing.

[b]Six Layers in One Pane
[/b]
The flow line is a 13-bar Money Flow Index on each bar's typical price, colored by tier: orchid above 80 or below 20, lime from 60 to 80, peach from 20 to 40, and lemon through the neutral middle. Ownership passes to buyers when the line rises above 55 and to sellers when it falls below 45, and between those levels the previous owner keeps it. The band works like the dead travel in a ship's wheel, which keeps the rudder from twitching every time the helmsman's hand trembles.

The pulse beneath the line is the smoothed one-bar change of the flow line, green while flow is rising and red while it is falling. The table's Impulse row restates it as a z-score against 34 bars of the line's own volatility. In the physics of this instrument the line is speed and the pulse is acceleration; one says where the flow sits, and the other says where it is heading.

The background shades each bar with one of eight regimes: Bull Expansion, Bear Expansion, Accumulation, Distribution, Exhaustion, Capitulation, Dead Zone and Drift. Each has a stated rule, a new regime must persist for a few bars before the heatmap commits to it, and its opacity rises with Strength. A lemon readout beside the last bar prints Strength and Flow Age, such as 73 | 5. Strength runs from 0 to 100 and weighs depth, pulse and persistence, less divergence and compression, while Flow Age counts only the bars on which control was strong.

Triangles on the zero line mark boundary events: continuations through 60 and 40, a fade back through 80, and reversal pressure up through 20. A triangle whose line crosses back through 50 inside its cooldown has failed, and the instrument draws nothing for it; the failure instead raises a disagreement score that quietly drains Strength. Diamonds at the floor and ceiling of the pane mark sharp turns in the pulse, scaled to the line's own volatility and thinned by a threshold set at the golden ratio.

[b]Turn-Wise Memory
[/b]
A turn is a change of ownership, the line crossing the band from one side to the other. The instrument counts turns inside an 89-bar window and computes φ as one minus the share of bars on which a turn occurred, so six turns in 89 bars gives a φ of 0.933. The count works like a census of abdications. It never asks why each owner fell, only how often owners fall here.

A survival rate per bar is hard to feel, so the table converts it into a half-life, the age by which half of all ownerships would have turned at the window's rate. The Memory row prints that half-life in bars and in trading time, the bars multiplied by the chart's interval, with the word "traded" as a reminder that session gaps are not counted. The Retained row raises φ to the current ownership's age, which gives the share of ownerships that survive that long, and it turns yellow at two half-lives.

Retained measures how unusual an ownership's age is, not how close its end has come, because the rate behind it does not change from bar to bar. The Control row decides what an unusual age means. Ownership age counts every bar since the last turn, while Flow Age counts only the bars on which control was exercised; the gap between them is a tenure measured against a timesheet.

[b]Reading the Chart
[/b]
The chart above shows Moderna (MRNA) on the hourly clock from September through the close of 9 October. The stock has climbed from a 130.42 low on 10 September to a 224.99 high, and it closed the week at that high. Every number in the pane comes from the stock's own money flow.

The table reads Bull Expansion five bars old, Strength 73 and Flow Age 5, which matches the readout. Memory reads φ 0.933 from six turns, a half-life of 9.9 bars, or close to ten hours traded. Retained reads 53 percent at 0.9 half-lives with nine bars owned, so the current buyers have lived roughly one ordinary lifetime for this market and no longer. The flow line sits at 88.2 in its upper extreme with the pulse positive and rising, persistence runs 13 bars, compression ranks 4, and disagreement reads 0.4, which says no divergence is weighing on the reading.

Two rows complicate the picture. The flow line sits above 80, yet the regime is not Exhaustion, because Exhaustion requires the pulse to stall or fall at that height; the first hour in which the pulse turns down will hand the engine an Exhaustion candidate. The Daily row, which reruns the same engine on the last closed day and never repaints, reads Distribution with Strength 46 and Flow Age 0. The hourly buyers are pressing a fresh expansion into the extreme while the daily crowd is selling into strength.

[b]Where MONeYφ Fits During a Trade
[/b]
MONeY Phlow is a supplementary instrument cut for the five-minute through hourly charts, where ownership turns often enough to be counted and a half-life can be measured in hours a trader actually watches. Outside that range the table's title turns yellow, since slower clocks turn too rarely to count and faster ones count noise. (Consider setting the visibility defaults to Off except for minutes and hours.) Volume read bar by bar, a supertrend-style trailing stop and a single moving average make natural companions, and the pane never says when to act.

The table reports the last closed bar while a bar is still forming, and it flags tick-volume feeds, which count activity rather than money. Every value behind the pane, from Strength and Flow Age to φ, half-life, ownership age and Retained, appears in the Data Window as a number or a code. The instrument raises no alerts by design, as it was built for a discretionary trader at the desk. 

[b]A Thesis Has a Half-Life
[/b]
The Moderna table holds two true statements in the same week. Hourly buyers own the flow at an upper extreme with their expansion five bars old, and the daily engine reads distribution beneath them. Neither cancels the other, and the pane does not pretend to know which will yield.

What the half-life adds is a clock on the reason for holding. 

A position held for one half-life is held, on average, by the crowd that justified it, while a position held for three is held by a crowd that has turned over several times. Most stops are drawn in price, as if the only way a trade can fail is by losing ground. A trade can also keep its ground while the money that defended it changes hands. A leading indicator of that change is older ownership beside a younger Flow Age.

## Source Code

````pine
//@version=6
// MONeY Phlow (MONeYφ) · version 1.1 · The Leading Indicator · 2026
// Designed by Adrian Dyer for "The Leading Indicator". Built on the core of Money Flow Pulse - Pro.
// The regime engine, heatmap, pulse, triangles, diamonds and readout, plus a memory φ counted from the
// money-flow line's own ownership turns, its half-life, the survival of the current ownership, refusal
// guards, an information table, a daily row and a machine-legible Data Window.
// Optimized for the 5-minute to 1-hour clocks. Discretionary instrument for live trading; it raises no alerts by design.
indicator("MONeY Phlow", shorttitle = "MONeYφ", overlay = false, precision = 2)

// ─── Option strings ────────────────────────────────────────────────────────
string TB_COMPACT = "Compact"
string TB_FULL    = "Full"

// ─── Core ──────────────────────────────────────────────────────────────────
string G_CORE = "Core"
length = input.int(13, "MFI Length", minval = 2, group = G_CORE)
src    = input.source(hlc3, "Source", group = G_CORE)
modeIn = input.string("Auto", "Timeframe Mode", options = ["Auto", "Low TF", "Intraday", "Structure", "Daily"], group = G_CORE)

// ─── Memory φ ──────────────────────────────────────────────────────────────
string G_PHI = "Memory φ"
phiWin     = input.int(89, "Memory Window (bars)", minval = 34, maxval = 1000, group = G_PHI,
     tooltip = "φ is the chance that the side owning the money flow still owns it one bar later, counted from this window: φ = 1 − ownership turns ÷ window. A turn is a change of side across the 55/45 band. The half-life is the age by which half of all ownerships have turned.")
discDecay  = input.float(0.95, "Disagreement Retention φ (per bar)", minval = 0.5, maxval = 0.99, step = 0.01, group = G_PHI,
     tooltip = "The disagreement score keeps this fraction of itself each bar. The default of 0.95 gives a half-life near 13.5 bars.")
showRetain = input.bool(false, "Show Retained Memory in Readout", group = G_PHI,
     tooltip = "Adds a third value to the readout: the share of ownerships that survive to the current ownership's age. Off by default, so the readout keeps its Strength | Flow Age form.")
showTurns  = input.bool(false, "Show Ownership Turns", group = G_PHI,
     tooltip = "Marks each ownership turn with a small dot on the 50 line, so the turns that set φ can be counted by eye.")

// ─── Visual layers ─────────────────────────────────────────────────────────
string G_VIS = "Visual Layers"
mfiWidth   = input.int(1, "MFI Line Width", minval = 1, maxval = 4, group = G_VIS)
showPulse  = input.bool(true, "Show Pulse Layer", group = G_VIS)
pulseIsRaw = input.bool(false, "Pulse Displays Raw ROC (unsmoothed)", group = G_VIS)
pulseOpac  = input.int(65, "Pulse Opacity %", minval = 0, maxval = 100, group = G_VIS)
showHeat   = input.bool(true, "Show Regime Heatmap", group = G_VIS)
heatMinOp  = input.int(8, "Heatmap Min Opacity % (low strength)", minval = 0, maxval = 100, group = G_VIS)
heatMaxOp  = input.int(55, "Heatmap Max Opacity % (full strength)", minval = 0, maxval = 100, group = G_VIS)
showLevels = input.bool(true, "Show 20/40/60/80 Guides", group = G_VIS)

// ─── Palette ───────────────────────────────────────────────────────────────
string G_PAL = "Palette"
lemon   = input.color(#FAF3B2, "Neutral and Readout", group = G_PAL, inline = "p1")
slate   = input.color(#787B86, "Dead Zone and Guides", group = G_PAL, inline = "p1")
lime    = input.color(#B2FF80, "Bull Expansion", group = G_PAL, inline = "p2")
ember   = input.color(#E57373, "Bear Expansion", group = G_PAL, inline = "p2")
tealc   = input.color(#69D4CD, "Accumulation", group = G_PAL, inline = "p3")
peach   = input.color(#FFB380, "Distribution", group = G_PAL, inline = "p3")
orchid  = input.color(#BA68C8, "Exhaustion and Extremes", group = G_PAL, inline = "p4")
crimson = input.color(#C62828, "Capitulation", group = G_PAL, inline = "p4")
pulseUp = input.color(#4CAF50, "Impulse Rising", group = G_PAL, inline = "p5")
pulseDn = input.color(#E53935, "Impulse Falling", group = G_PAL, inline = "p5")
phiCol  = input.color(#9575CD, "Memory φ (table)", group = G_PAL, inline = "p6")

// ─── Event markers ─────────────────────────────────────────────────────────
string G_EVT = "Event Markers"
showTri  = input.bool(true, "Show Boundary Triangles", group = G_EVT)
showDia  = input.bool(true, "Show Zero-Line Diamonds", group = G_EVT)
diaScale = input.float(1.618, "Diamond Threshold Scale", minval = 0.5, maxval = 5.0, step = 0.1, group = G_EVT,
     tooltip = "A diamond prints when the impulse crosses zero with a two-bar swing larger than the mode's threshold times this scale. Higher values print fewer, sharper diamonds; 1.0 uses each mode's base threshold.")

// ─── Status readout ────────────────────────────────────────────────────────
string G_READ = "Status Readout"
showReadout = input.bool(true, "Show Status Readout", group = G_READ)
readAlways  = input.bool(false, "Always Show (include neutral regimes)", group = G_READ)
readSize    = input.string("Small", "Readout Font Size", options = ["Tiny", "Small", "Normal"], group = G_READ)
offX        = input.int(3, "Horizontal Offset (bars)", minval = 0, maxval = 20, group = G_READ)
offY        = input.float(0.0, "Vertical Offset (oscillator units)", minval = -50, maxval = 50, group = G_READ)

// ─── Daily row ─────────────────────────────────────────────────────────────
string G_HTF = "Daily Row"
showHTF = input.bool(true, "Show Daily Row", group = G_HTF,
     tooltip = "The last closed day's regime, Strength and Flow Age, computed in Daily mode. It never repaints, appears on intraday charts only, and shows in the Full table.")

// ─── Information table ─────────────────────────────────────────────────────
string G_TB = "Information Table"
showTable         = input.bool(true, "Show Table", group = G_TB)
tableMode         = input.string(TB_FULL, "Rows", options = [TB_COMPACT, TB_FULL], group = G_TB)
tablePosInput     = input.string("Bottom Left", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_TB)
tableSizeInput    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_TB)
tableBgInput      = input.color(color.new(#2A2E39, 20), "Background", group = G_TB)
tableLabelInput   = input.color(#FAF3B2, "Label Color", group = G_TB)
tableBorderCInput = input.color(color.new(#FAF3B2, 70), "Border Color", group = G_TB)
tableBorderWInput = input.int(1, "Border Width", minval = 0, maxval = 5, group = G_TB)
showFootnote      = input.bool(true, "Show Settings Footnote", group = G_TB)
tableRead         = input.string("Closed bar", "Table Reads", options = ["Closed bar", "Live bar"], group = G_TB,
     tooltip = "Closed bar: while a bar is still forming, the table reports the last closed bar. Live bar: the table reports the forming bar. The readout and the Data Window always report each bar as plotted.")

// ─── Timeframe mode resolution ─────────────────────────────────────────────
int    tfSec    = timeframe.in_seconds()
string autoMode = tfSec <= 300 ? "Low TF" : tfSec <= 1800 ? "Intraday" : tfSec <= 14400 ? "Structure" : "Daily"
string mode     = modeIn == "Auto" ? autoMode : modeIn

// persistence req | heatmap inertia | triangle cooldown | diamond multiplier | strength smoothing | impulse smoothing
// Resolved in global scope so the smoothing lengths stay simple ints for ta.ema.
[persistReq, inertiaBars, baseCool, diaMult, strSmooth, impSmooth] = switch mode
    "Low TF"    => [2, 2, 5, 0.8, 2, 2]
    "Intraday"  => [3, 3, 8, 1.0, 3, 2]
    "Structure" => [5, 5, 13, 1.3, 5, 3]
    => [8, 8, 21, 1.6, 8, 5]

// ─── Regime engine (wrapped so the daily row can rerun it in Daily mode) ────
// The two smoothing lengths are declared simple, so ta.ema accepts them; the daily call passes Daily-mode literals.
f_engine(int pReq, int pInert, int pCool, float pDia, simple int pStr, simple int pImp) =>
    float m     = ta.mfi(src, length)
    int   score = m > 80 ? 2 : m > 60 ? 1 : m < 20 ? -2 : m < 40 ? -1 : 0
    float roc   = m - nz(m[1], m)
    float imp   = ta.ema(roc, pImp)
    float fvol  = ta.stdev(roc, 34)
    float impZ  = fvol > 0 ? imp / fvol : 0.0

    var int d = 0
    d := m > 55 ? 1 : m < 45 ? -1 : d
    var int bullRun = 0
    var int bearRun = 0
    bullRun := m > 50 ? bullRun + 1 : 0
    bearRun := m < 50 ? bearRun + 1 : 0
    int pers = d > 0 ? bullRun : d < 0 ? -bearRun : 0

    float mVar = ta.stdev(m, 21)
    float comp = 100.0 - ta.percentrank(mVar, 144)

    var float lastPHp  = na
    var float lastPHm  = na
    var float lastPLp  = na
    var float lastPLm  = na
    var float disagree = 0.0
    disagree := disagree * discDecay
    float ph = ta.pivothigh(high, 5, 5)
    float pl = ta.pivotlow(low, 5, 5)
    if not na(ph)
        float mAtH = m[5]
        if not na(lastPHp) and ph > lastPHp and mAtH < lastPHm
            disagree += imp < 0 ? 3.0 : 1.0
        lastPHp := ph
        lastPHm := mAtH
    if not na(pl)
        float mAtL = m[5]
        if not na(lastPLp) and pl < lastPLp and mAtL > lastPLm
            disagree += imp > 0 ? 3.0 : 1.0
        lastPLp := pl
        lastPLm := mAtL

    float levelComp   = math.min(math.abs(m - 50.0) / 35.0, 1.0)
    float impComp     = math.max(0.0, math.min(1.0, 0.5 + 0.25 * (d * impZ)))
    float persComp    = math.min(math.abs(pers) / (pReq * 3), 1.0)
    float disPen      = math.min(disagree * 0.06, 0.30)
    float compPen     = comp > 70 ? (comp - 70.0) / 100.0 : 0.0
    float strengthRaw = 100.0 * math.max(0.0, math.min(1.0, 0.40 * levelComp + 0.30 * impComp + 0.30 * persComp - disPen - compPen))
    int   strength    = math.round(ta.ema(strengthRaw, pStr))

    var int flowAge = 0
    if d != d[1]
        flowAge := d == 0 ? 0 : 1
    else if d != 0
        if strength >= 55
            flowAge += 1
        else if strength < 40
            flowAge := math.max(flowAge - 1, 0)

    int candidate = 6
    if comp > 75 and math.abs(m - 50) < 10
        candidate := 0
    else if m >= 80 and imp <= 0
        candidate := 5
    else if m <= 20 and imp <= 0
        candidate := 4
    else if m < 45 and imp > 0
        candidate := 3
    else if m > 55 and (imp < 0 or disagree >= 3)
        candidate := 2
    else if d > 0 and imp > 0
        candidate := 1
    else if d < 0 and imp < 0
        candidate := 7

    var int regime    = 6
    var int candCount = 0
    if candidate == regime
        candCount := 0
    else
        candCount := candidate == candidate[1] ? candCount + 1 : 1
        if candCount >= pInert
            regime    := candidate
            candCount := 0

    int effCool = regime == 4 or regime == 5 ? pCool * 2 : pCool

    bool triBullCont = ta.crossover(m, 60) and bullRun >= pReq and imp > 0
    bool triBearCont = ta.crossunder(m, 40) and bearRun >= pReq and imp < 0
    bool triFade     = ta.crossunder(m, 80) and imp < 0
    bool triRev      = ta.crossover(m, 20) and imp > 0

    var int cbBullCont = -100000
    var int cbBearCont = -100000
    var int cbFade     = -100000
    var int cbRev      = -100000
    bool sigBullCont = false
    bool sigBearCont = false
    bool sigFade     = false
    bool sigRev      = false
    if triBullCont and bar_index - cbBullCont > effCool
        sigBullCont := true
        cbBullCont  := bar_index
    if triBearCont and bar_index - cbBearCont > effCool
        sigBearCont := true
        cbBearCont  := bar_index
    if triFade and bar_index - cbFade > effCool
        sigFade := true
        cbFade  := bar_index
    if triRev and bar_index - cbRev > effCool
        sigRev := true
        cbRev  := bar_index

    // Crosses and changes evaluated on every bar, outside any short-circuit, so their history is true bar history.
    bool  xDn50  = ta.crossunder(m, 50)
    bool  xUp50  = ta.crossover(m, 50)
    bool  xUpImp = ta.crossover(imp, 0)
    bool  xDnImp = ta.crossunder(imp, 0)
    float chImp2 = math.abs(ta.change(imp, 2))

    var bool armBull    = false
    var int  armBullBar = 0
    var bool armBear    = false
    var int  armBearBar = 0
    if sigBullCont or sigRev
        armBull    := true
        armBullBar := bar_index
    if sigBearCont or sigFade
        armBear    := true
        armBearBar := bar_index
    bool bullFail = armBull and xDn50 and bar_index - armBullBar <= effCool
    bool bearFail = armBear and xUp50 and bar_index - armBearBar <= effCool
    if bullFail
        armBull  := false
        disagree += 2.0
    if bearFail
        armBear  := false
        disagree += 2.0
    if armBull and bar_index - armBullBar > effCool
        armBull := false
    if armBear and bar_index - armBearBar > effCool
        armBear := false
    int failEvent = bullFail ? -1 : bearFail ? 1 : 0

    float diaThresh = pDia * fvol * 0.5 * diaScale
    bool  diaBull   = xUpImp and chImp2 > diaThresh
    bool  diaBear   = xDnImp and chImp2 > diaThresh

    [m, score, roc, imp, fvol, impZ, d, pers, comp, disagree, strength, flowAge, candidate, regime,
     sigBullCont, sigBearCont, sigFade, sigRev, failEvent, diaBull, diaBear]

[mfi, mfiScore, rocRaw, impulse, flowVol, impulseZ, dir, persistence, compression, disagree, strength, flowAge, candidate, regime,
     sigBullCont, sigBearCont, sigFade, sigRev, failEvent, diaBull, diaBear] = f_engine(persistReq, inertiaBars, baseCool, diaMult, strSmooth, impSmooth)

f_daily() =>
    [m, sc, ro, im, fv, iz, d, pe, co, di, st, fa, ca, rg, b1, b2, b3, b4, fe, d1, d2] = f_engine(8, 8, 21, 1.6, 8, 5)
    int ok = na(m) or na(st) ? 0 : 1
    [rg[1], st[1], fa[1], ok[1]]

[dRegime, dStrength, dFlowAge, dOk] = request.security(syminfo.tickerid, timeframe.isintraday ? "1D" : timeframe.period, f_daily(),
     lookahead = barmerge.lookahead_on)

// ─── Guards: refuse rather than lie ────────────────────────────────────────
float  cumVolAll = ta.cum(nz(volume))
bool   noVolume  = cumVolAll == 0
bool   refused   = noVolume or na(volume) or na(mfi) or na(strength)
string whyRefuse = noVolume ? "No volume from this feed" : na(volume) ? "No volume on this bar" :
     na(mfi) or na(strength) ? "Warming " + str.tostring(bar_index + 1) + "/" + str.tostring(length + strSmooth + 1) : "Ready"

// ─── Memory φ (counted from the line's own ownership turns) ────────────────
// A turn is a change of owning side across the 55/45 band. φ = 1 − turns ÷ window is the per-bar survival
// of an ownership (the geometric estimate), and its half-life is the age by which half of all ownerships turn.
bool  turn     = dir != dir[1] and dir != 0 and nz(dir[1]) != 0
float turnsW   = math.sum(turn ? 1.0 : 0.0, phiWin)
int   phiNeed  = length + phiWin
bool  phiReady = not na(turnsW) and bar_index + 1 >= phiNeed
float phiRaw   = phiReady ? 1.0 - turnsW / phiWin : na
float phiBar   = phiReady and phiRaw > 0 ? phiRaw : na
float halfLife = not na(phiBar) and phiBar < 1 ? math.log(0.5) / math.log(phiBar) : na
int   dirSince = ta.barssince(dir != dir[1])
int   ownAge   = dir == 0 or na(dirSince) ? na : dirSince + 1
float retained = not na(phiBar) and not na(ownAge) ? math.pow(phiBar, ownAge) * 100.0 : na
float ageHL    = not na(halfLife) and not na(ownAge) ? ownAge / halfLife : na
float discHL   = math.log(0.5) / math.log(discDecay)
int   regSince = ta.barssince(regime != regime[1])
int   regAge   = na(regSince) ? bar_index + 1 : regSince + 1

// ─── Last event ────────────────────────────────────────────────────────────
var string lastEvt    = "None yet"
var int    lastEvtBar = na
if not refused
    string evt = sigBullCont ? "Bull continuation ▲" : sigBearCont ? "Bear continuation ▼" : sigFade ? "Upper fade ▼" :
         sigRev ? "Lower reversal ▲" : failEvent == -1 ? "Failed bull signal" : failEvent == 1 ? "Failed bear signal" :
         diaBull ? "Impulse shift up ◆" : diaBear ? "Impulse shift down ◆" : ""
    if evt != ""
        lastEvt    := evt
        lastEvtBar := bar_index

// ─── Feed and clock ────────────────────────────────────────────────────────
string vType     = syminfo.volumetype
int    feedCode  = vType == "base" ? 1 : vType == "quote" ? 2 : vType == "tick" ? 3 : 0
bool   intraday  = timeframe.isintraday
bool   offDesign = tfSec < 300 or tfSec > 3600

// ─── Heatmap ───────────────────────────────────────────────────────────────
f_regimeCol(int r) =>
    switch r
        0 => slate
        1 => lime
        2 => peach
        3 => tealc
        4 => crimson
        5 => orchid
        7 => ember
        => color(na)

color regimeCol  = f_regimeCol(regime)
float opFloor    = math.min(heatMinOp, heatMaxOp)
float opCeil     = math.max(heatMinOp, heatMaxOp)
float strOpacity = opFloor + (opCeil - opFloor) * (strength / 100.0)
int   confTransp = math.round(100.0 - strOpacity)
int   heatTransp = regime == 0 ? math.round(100.0 - opFloor) : confTransp
bgcolor(showHeat and not refused and regime != 6 and not na(regimeCol) ? color.new(regimeCol, heatTransp) : na, title = "Regime Heatmap")

// ─── Plots (the status line carries only the Pulse and the MFI) ────────────
color mfiColor = mfiScore == 2 or mfiScore == -2 ? orchid : mfiScore == 1 ? lime : mfiScore == -1 ? peach : lemon

plot(showLevels ? 80 : na, "Guide 80", color = color.new(slate, 82), linewidth = 1, display = display.pane)
plot(showLevels ? 60 : na, "Guide 60", color = color.new(slate, 90), linewidth = 1, display = display.pane)
plot(showLevels ? 40 : na, "Guide 40", color = color.new(slate, 90), linewidth = 1, display = display.pane)
plot(showLevels ? 20 : na, "Guide 20", color = color.new(slate, 82), linewidth = 1, display = display.pane)
hline(0, "Zero Line", color = color.new(lemon, 55))

float pulseDisp = pulseIsRaw ? rocRaw : impulse
plot(showPulse and not refused ? pulseDisp : na, "Pulse", style = plot.style_area,
     color = pulseDisp >= 0 ? color.new(pulseUp, 100 - pulseOpac) : color.new(pulseDn, 100 - pulseOpac))
plot(refused ? na : mfi, "MFI", color = color.new(mfiColor, 0), linewidth = mfiWidth)

plotshape(showTri and not refused and sigBullCont ? 0.0 : na, "Bull Continuation", style = shape.triangleup, location = location.absolute, color = color.new(lime, 0), size = size.tiny, display = display.pane)
plotshape(showTri and not refused and sigBearCont ? 0.0 : na, "Bear Continuation", style = shape.triangledown, location = location.absolute, color = color.new(peach, 0), size = size.tiny, display = display.pane)
plotshape(showTri and not refused and sigFade ? 0.0 : na, "Upper Fade", style = shape.triangledown, location = location.absolute, color = color.new(orchid, 0), size = size.tiny, display = display.pane)
plotshape(showTri and not refused and sigRev ? 0.0 : na, "Lower Reversal Pressure", style = shape.triangleup, location = location.absolute, color = color.new(orchid, 0), size = size.tiny, display = display.pane)
plotshape(showDia and not refused and diaBull, "Impulse Shift Up", style = shape.diamond, location = location.bottom, color = color.new(pulseUp, 0), size = size.tiny, display = display.pane)
plotshape(showDia and not refused and diaBear, "Impulse Shift Down", style = shape.diamond, location = location.top, color = color.new(pulseDn, 0), size = size.tiny, display = display.pane)
plotshape(showTurns and not refused and turn ? 50.0 : na, "Ownership Turn", style = shape.circle, location = location.absolute, color = dir > 0 ? color.new(lime, 0) : color.new(peach, 0), size = size.tiny, display = display.pane)

// ─── Status readout (live bar) ─────────────────────────────────────────────
string readFont     = readSize == "Tiny" ? size.tiny : readSize == "Normal" ? size.normal : size.small
bool   regimeActive = regime != 0 and regime != 6
var label lbl = na
if barstate.islast
    bool showNow = showReadout and not refused and (readAlways or regimeActive)
    if showNow
        if na(lbl)
            lbl := label.new(bar_index + offX, mfi + offY, "", xloc = xloc.bar_index, style = label.style_none, textcolor = lemon, size = readFont)
        label.set_xy(lbl, bar_index + offX, mfi + offY)
        string rtxt = str.tostring(strength) + " | " + str.tostring(flowAge) + (showRetain and not na(retained) ? " | " + str.tostring(retained, "0") + "%" : "")
        label.set_text(lbl, rtxt)
        label.set_textcolor(lbl, lemon)
        label.set_size(lbl, readFont)
    else
        if not na(lbl)
            label.delete(lbl)
            lbl := na

// ─── Data Window (codes for the machine; legends live in the titles) ───────
int modeCode = mode == "Low TF" ? 1 : mode == "Intraday" ? 2 : mode == "Structure" ? 3 : 4
int triCode  = sigBullCont ? 1 : sigBearCont ? 2 : sigFade ? 3 : sigRev ? 4 : 0
int diaCode  = diaBull ? 1 : diaBear ? -1 : 0
plot(strength, "Regime Strength", format = format.price, precision = 0, display = display.data_window)
plot(flowAge, "Flow Age (qualified bars)", format = format.price, precision = 0, display = display.data_window)
plot(persistence, "Persistence (signed)", format = format.price, precision = 0, display = display.data_window)
plot(compression, "Compression Rank", format = format.price, precision = 1, display = display.data_window)
plot(disagree, "Disagreement", format = format.price, precision = 2, display = display.data_window)
plot(flowVol, "Flow Volatility", format = format.price, precision = 2, display = display.data_window)
plot(impulseZ, "Impulse Z", format = format.price, precision = 2, display = display.data_window)
plot(regime, "Regime Code (0 Dead Zone, 1 Bull Expansion, 2 Distribution, 3 Accumulation, 4 Capitulation, 5 Exhaustion, 6 Drift, 7 Bear Expansion)", format = format.price, precision = 0, display = display.data_window)
plot(candidate, "Candidate Regime", format = format.price, precision = 0, display = display.data_window)
plot(mfiScore, "MFI Tier", format = format.price, precision = 0, display = display.data_window)
plot(rocRaw, "MFI ROC (raw)", format = format.price, precision = 2, display = display.data_window)
plot(failEvent, "Failure Event (-1 failed bull, 1 failed bear)", format = format.price, precision = 0, display = display.data_window)
plot(triCode, "Triangle Code (1 bull cont, 2 bear cont, 3 upper fade, 4 lower reversal)", format = format.price, precision = 0, display = display.data_window)
plot(diaCode, "Diamond Code (1 shift up, -1 shift down)", format = format.price, precision = 0, display = display.data_window)
plot(modeCode, "Mode Code (1 Low TF, 2 Intraday, 3 Structure, 4 Daily)", format = format.price, precision = 0, display = display.data_window)
plot(regAge, "Regime Age (bars)", format = format.price, precision = 0, display = display.data_window)
plot(turnsW, "Ownership Turns in Window", format = format.price, precision = 0, display = display.data_window)
plot(phiBar, "Memory φ (survival per bar)", format = format.price, precision = 3, display = display.data_window)
plot(halfLife, "Memory Half-Life (bars)", format = format.price, precision = 1, display = display.data_window)
plot(ownAge, "Ownership Age (bars)", format = format.price, precision = 0, display = display.data_window)
plot(retained, "Retained (% of ownerships surviving to this age)", format = format.price, precision = 1, display = display.data_window)

// ─── Information table ─────────────────────────────────────────────────────
var string tblPos = switch tablePosInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.bottom_left

var string tblSize = switch tableSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

var table tbl = table.new(tblPos, 2, 16, bgcolor = tableBgInput, frame_color = tableBorderCInput, frame_width = tableBorderWInput,
     border_color = tableBorderCInput, border_width = tableBorderWInput)

f_cell(int c, int r, string txt, color col) =>
    table.cell(tbl, c, r, txt, text_color = col, text_size = tblSize, text_halign = text.align_left)

f_row(int r, string lab, string v, color vc) =>
    f_cell(0, r, lab, tableLabelInput)
    f_cell(1, r, v, vc)

f_fmt(float x, string f) =>
    na(x) ? "—" : str.tostring(x, f)

f_sgn(float x, string f) =>
    na(x) ? "—" : (x >= 0 ? "+" : "") + str.tostring(x, f)

f_bars(int n) =>
    na(n) ? "—" : n == 1 ? "1 bar" : str.tostring(n) + " bars"

// Trading time: bars times this chart's interval, so session gaps are not counted. Hours run past 24 rather than into days.
f_dur(float bars) =>
    string s = "—"
    if not na(bars)
        float mins = math.round(bars * tfSec / 60.0)
        float h    = math.floor(mins / 60)
        float m    = mins - h * 60
        s := h >= 1 ? "≈ " + str.tostring(h, "#") + " h " + str.tostring(m, "#") + " min traded" : "≈ " + str.tostring(math.max(m, 1), "#") + " min traded"
    s

f_regTxt(int r) =>
    na(r) ? "—" : r == 0 ? "Dead Zone" : r == 1 ? "Bull Expansion" : r == 2 ? "Distribution" : r == 3 ? "Accumulation" :
         r == 4 ? "Capitulation" : r == 5 ? "Exhaustion" : r == 7 ? "Bear Expansion" : "Drift"

f_regCol(int r) =>
    na(r) or r == 6 ? color.gray : color.new(f_regimeCol(r), 0)

f_tierTxt(int t) =>
    t == 2 ? "upper extreme" : t == 1 ? "bull tier" : t == -1 ? "bear tier" : t == -2 ? "lower extreme" : "neutral tier"

f_feedTxt(int c) =>
    c == 1 ? "Base units" : c == 2 ? "Quote currency" : c == 3 ? "Tick count" : "Unspecified"

// Table offset: the last closed bar unless the Live option is chosen.
int    k        = tableRead == "Live bar" or barstate.isconfirmed ? 0 : 1
bool   refusedT = refused[k]
string whyT     = whyRefuse[k]
int    regT     = regime[k]
int    regAgeT  = regAge[k]
int    strT     = strength[k]
int    faT      = flowAge[k]
bool   readyT   = phiReady[k]
float  phiT     = phiBar[k]
float  hlT      = halfLife[k]
float  turnsT   = turnsW[k]
float  retT     = retained[k]
float  ageHLT   = ageHL[k]
int    ownT     = ownAge[k]
int    dirT     = dir[k]
float  mfiT     = mfi[k]
int    scoreT   = mfiScore[k]
float  impZT    = impulseZ[k]
float  impT     = impulse[k]
float  impPT    = impulse[k + 1]
int    persT    = persistence[k]
float  compT    = compression[k]
float  disT     = disagree[k]
string evtT     = lastEvt[k]
int    evtBarT  = lastEvtBar[k]

if barstate.islast
    table.clear(tbl, 0, 0, 1, 15)
    if showTable
        bool full = tableMode == TB_FULL
        f_cell(0, 0, "MONeYφ", color.white)
        f_cell(1, 0, syminfo.ticker + " · " + timeframe.period + (offDesign ? " · outside 5m–1h" : ""), offDesign ? color.yellow : color.white)
        int r = 1
        if refusedT
            f_row(r, "Status", whyT, color.gray)
            r += 1
        else
            f_row(r, "Regime", f_regTxt(regT) + " · " + f_bars(regAgeT), f_regCol(regT))
            r += 1
            f_row(r, "Control", "Strength " + str.tostring(strT) + " · Flow Age " + str.tostring(faT), lemon)
            r += 1
            int    nTurns = na(turnsT) ? 0 : int(turnsT)
            string turnTx = nTurns == 1 ? "1 turn" : str.tostring(nTurns) + " turns"
            string phiTxt = not readyT ? "Warming " + str.tostring(bar_index - k + 1) + "/" + str.tostring(phiNeed) :
                 na(phiT) ? "Turning every bar · no measure" :
                 na(hlT) ? "φ 1.000 · 0 turns in " + str.tostring(phiWin) + " bars" :
                 "φ " + f_fmt(phiT, "0.000") + " · " + turnTx + " · half-life " + f_fmt(hlT, "0.0") + " bars " + f_dur(hlT)
            f_row(r, "Memory", phiTxt, readyT and not na(phiT) ? phiCol : color.gray)
            r += 1
            string retTxt = dirT == 0 ? "No side owns the flow" :
                 not readyT ? f_bars(ownT) + " owned · memory warming" :
                 na(phiT) ? f_bars(ownT) + " owned · no measure" :
                 na(hlT) ? f_bars(ownT) + " owned · no turn in window" :
                 f_fmt(retT, "0") + "% retained · " + f_fmt(ageHLT, "0.0") + " half-lives · " + f_bars(ownT) + " owned"
            f_row(r, "Retained", retTxt, dirT == 0 or not readyT or na(phiT) ? color.gray : not na(ageHLT) and ageHLT >= 2 ? color.yellow : lemon)
            r += 1
            if full
                f_row(r, "MFI", f_fmt(mfiT, "0.0") + " · " + f_tierTxt(scoreT) + " · " + (dirT > 0 ? "bull side" : dirT < 0 ? "bear side" : "no side"),
                     dirT > 0 ? lime : dirT < 0 ? peach : lemon)
                r += 1
                f_row(r, "Impulse", "z " + f_sgn(impZT, "0.00") + " · " + (impT >= 0 ? "positive" : "negative") + ", " + (impT >= impPT ? "rising" : "falling"),
                     impT >= 0 ? pulseUp : pulseDn)
                r += 1
                f_row(r, "Persistence", f_sgn(persT, "0") + (math.abs(persT) == 1 ? " bar" : " bars"), lemon)
                r += 1
                f_row(r, "Compression", "rank " + f_fmt(compT, "0") + (compT > 75 ? " · dead-zone risk" : compT > 70 ? " · coiled" : ""), compT > 70 ? color.yellow : lemon)
                r += 1
                f_row(r, "Disagreement", f_fmt(disT, "0.0") + " · half-life " + f_fmt(discHL, "0.0") + " bars", disT >= 3 ? color.yellow : lemon)
                r += 1
                int evtAgo = na(evtBarT) ? na : bar_index - k - evtBarT
                f_row(r, "Last event", na(evtAgo) ? evtT : evtT + " · " + (evtAgo == 0 ? "this bar" : f_bars(evtAgo) + " ago"), lemon)
                r += 1
        if full and showHTF
            if intraday
                f_row(r, "Daily", nz(dOk) != 1 ? "Daily warming" : f_regTxt(dRegime) + " · " + str.tostring(dStrength) + " | " + str.tostring(dFlowAge) + " · last close",
                     nz(dOk) != 1 ? color.gray : f_regCol(dRegime))
            else
                f_row(r, "Daily", "Intraday charts only", color.gray)
            r += 1
        if full
            f_row(r, "Feed", f_feedTxt(feedCode) + (feedCode == 3 ? " · MFI weighs tick counts" : ""),
                 feedCode == 3 ? color.yellow : feedCode == 0 ? color.gray : color.white)
            r += 1
        if showFootnote
            f_row(r, "Settings", "MFI " + str.tostring(length) + " · " + mode + (modeIn == "Auto" ? " (auto)" : "") +
                 (phiWin != 89 ? " · φ window " + str.tostring(phiWin) : "") + (discDecay != 0.95 ? " · decay " + str.tostring(discDecay) : "") +
                 (diaScale != 1.618 ? " · diamonds ×" + str.tostring(diaScale) : ""), color.gray)
````

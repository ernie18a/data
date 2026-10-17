# MACD-V (Volatility-Normalised Momentum)

- url: https://www.tradingview.com/script/A2Q48PQF/
- type: indicator
- pine_id: PUB;e838e61476e841598487c99a9c37d7d9
- version: 3.0

## Description

A faithful implementation of MACD-V, the volatility-normalised momentum indicator introduced by Alex Spiroglou in his Charles Dow Award–winning paper (CMT Association, 2022; SSRN 4099617).

Classic MACD has a structural flaw: because it is the raw difference of two price EMAs, its values are tied to the price scale, so the same reading means different things on different symbols and in different volatility regimes — and a level that signals "overbought" on one chart is meaningless on another. MACD-V fixes this by dividing the MACD line by ATR:
[pine]MACD-V = [ ( EMA12 − EMA26 ) / ATR26 ] × 100[/pine]
Normalising by volatility makes the output comparable across instruments and across time. The same threshold levels then carry the same meaning everywhere, which is what makes a fixed "momentum lifecycle" map possible.

[b]Momentum lifecycle[/b]
The MACD-V line is read against fixed levels rather than just its sign. Spiroglou's roadmap uses +150 / +50 / −50 / −100 / −150 to divide momentum into stages — overbought, rallying, rebounding, retracing, pullback, declining, oversold. Strong trends live above +150 (the line is unbounded, so it can reach 200+); pullbacks in an uptrend often hold near −100. The histogram (MACD-V minus its signal line) has its own ±40 extremes on a separate, smaller scale.

[b]What this implementation adds (all optional)[/b]
[list]
[*]A label is printed whenever the line moves into a new lifecycle stage, so the transitions are visible without reading levels off the axis.
[*]Optional background shading collapses the seven stages into three momentum bands using the study's neutral zone — up above +50, ranging within ±50, down below −50 — so a label can read "Rebounding" while the background stays neutral.
[*]A four-colour histogram coloured by both sign and slope, so a fading move is visible before it flips sign.
[*]Dots at MACD-V / signal-line crosses.
[*]The two threshold ranges (the line's ±150/±50 and the histogram's ±40) are split into separate, independently toggled groups, and every level is an input so you can adjust them.
[/list]

[b]Notes[/b]
The default thresholds are Spiroglou's published levels, which are meaningful precisely because the series is ATR-normalised. The Source input defaults to close but accepts any series. This is a momentum/context tool, not a trade signal and not financial advice.
Credit: the MACD-V concept and its lifecycle levels are the work of Alex Spiroglou, DipTA(STA), CFTe. This script is an independent implementation of the published formula and roadmap.

## Source Code

````pine
// =====================================================================
//  MACD-V — Volatility-Normalised Momentum, with Spiroglou's
//  Momentum Lifecycle RoadMap (7 stages, signal-line aware)
// =====================================================================
//  MACD-V = ((EMA_fast(close) - EMA_slow(close)) / ATR) * 100
//
//  Dividing MACD by ATR normalises momentum by volatility, so the same
//  threshold levels mean the same thing across instruments and over time
//  (Alex Spiroglou, 2022 — CMT Charles Dow Award; NAAIM Founders Award;
//  SSRN 4099617).
//
//  A lifecycle stage is defined by TWO things together: the height band of
//  the MACD-V line AND whether it sits above or below its signal line. The
//  same band therefore reads differently on the way up vs the way down, so
//  one stage no longer mixes a rise and a fall:
//      > +150 ............... Overbought (Risk)
//      +50..+150 above sig .. Rallying      (up-leg)
//      +50..+150 below sig .. Retracing     (down-leg)
//      -50..+50 ............. Ranging        (only after N bars inside)
//      -150..-50 above sig .. Rebounding    (up-leg)
//      -150..-50 below sig .. Reversing     (down-leg)
//      < -150 ............... Oversold (Risk)
//
//  Ranging is strict: the inner +/-50 zone is labelled Ranging only once
//  the line has stayed inside it for N consecutive bars (default 20). During
//  the lead-in the prior leg's label is held, so brief touches of +/-50 are
//  not called Ranging.
//
//  Up-leg states (Rebounding, Rallying, Overbought) are the rising half of
//  the cycle; down-leg states (Retracing, Reversing, Oversold) the falling
//  half; Ranging is the neutral transition. Each stage's label is centred on
//  its bar run — up-leg at the bottom edge, down-leg at the top, Ranging on
//  the zero line. The background is shaded by leg and by depth. The histogram
//  (MACD-V minus signal) keeps its own +/-40 extremes.
//
//  Descriptive context only — not a signal, not financial advice.
// =====================================================================

//@version=6
indicator("MACD-V", shorttitle = "MACD-V", overlay = false, max_labels_count = 500)

// --------------------------- Stage ids -------------------------------
// Distinct ids for the seven lifecycle stages, used throughout instead of
// magic numbers. Ordered by momentum, but only their distinctness matters.
const int STAGE_OVERSOLD   = 1
const int STAGE_REVERSING  = 2
const int STAGE_REBOUNDING = 3
const int STAGE_RANGING    = 4
const int STAGE_RETRACING  = 5
const int STAGE_RALLYING   = 6
const int STAGE_OVERBOUGHT = 7

// ----------------------------- Inputs --------------------------------
string GRP_MV   = "MACD-V"
string GRP_LINE = "MACD-V line range (lifecycle)"
string GRP_HIST = "Histogram range"
string GRP_STG  = "Lifecycle stage labels"
string GRP_COL  = "Colours"

float src        = input.source(close, "Source", group = GRP_MV)
int   fastLen    = input.int(12, "Fast EMA", minval = 1, group = GRP_MV)
int   slowLen    = input.int(26, "Slow EMA", minval = 1, group = GRP_MV)
int   atrLen     = input.int(26, "ATR length", minval = 1, group = GRP_MV, tooltip = "Volatility divisor that normalises the momentum.")
int   sigLen     = input.int(9,  "Signal EMA", minval = 1, group = GRP_MV)
bool  showHist   = input.bool(true, "Show histogram (MACD-V minus Signal)", group = GRP_MV)
bool  histFourCol = input.bool(true, "4-colour histogram", group = GRP_MV, tooltip = "Colour the histogram by sign AND slope, so a fading move is visible before it flips sign.")
bool  showCross  = input.bool(true, "Dots on MACD-V / Signal cross", group = GRP_MV, tooltip = "Up-colour dot when MACD-V crosses up through the signal line, down-colour when it crosses down. Drawn on the signal line.")

// Roadmap levels. Only +/-150 (Risk) and +/-50 (fast/slow boundary) are
// used for staging; there is no +/-100 level in Spiroglou's roadmap.
bool  showLineRange = input.bool(true, "Show MACD-V line range", group = GRP_LINE, tooltip = "The +/-150 (Risk) and +/-50 (fast/slow boundary) levels of the MACD-V line.")
float lvlOverbought = input.float(150,  "Overbought / Risk (+150)", group = GRP_LINE)
float lvlUpBound    = input.float(50,   "Fast/slow up boundary (+50)", group = GRP_LINE)
float lvlDnBound    = input.float(-50,  "Fast/slow down boundary (-50)", group = GRP_LINE)
float lvlOversold   = input.float(-150, "Oversold / Risk (-150)", group = GRP_LINE)
int   rangeBars     = input.int(20, "Ranging confirmation bars (N)", minval = 1, group = GRP_LINE, tooltip = "Spiroglou's strict definition: the inner +/-50 zone is only called Ranging after the line stays inside it for N consecutive bars. Set N = 1 to label Ranging the moment the line enters +/-50.")

// Histogram thresholds (a separate, smaller scale than the line).
bool  showHistRange = input.bool(true, "Show histogram range", group = GRP_HIST, tooltip = "The +/-40 extremes of the histogram (MACD-VH): a separate scale that flags short-term momentum stretch.")
float histExtreme   = input.float(40, "Histogram extreme (+/-40)", group = GRP_HIST)

// Lifecycle stage labels and background.
bool  showStageLabels = input.bool(true, "Label stage changes", group = GRP_STG, tooltip = "Prints a label where the line enters a new stage — a band change OR a signal-line cross within a band.")
float labelEdge       = input.float(180, "Label edge level", minval = 0, group = GRP_STG, tooltip = "Fixed level the labels sit at: up-leg at -this (bottom), down-leg at +this (top), Ranging on the zero line. Set above the line's usual range so labels stay clear of it.")
bool  showStageBg     = input.bool(true, "Shade background by stage", group = GRP_STG, tooltip = "Tints the pane by leg and depth: up-leg colour, down-leg colour, neutral Ranging; fainter near zero, more opaque toward +/-150.")
int   stageBgTransp   = input.int(90, "Background transparency", minval = 70, maxval = 99, group = GRP_STG, tooltip = "Higher = fainter background, so the line and histogram stay readable.")

color colUp        = input.color(#60C0D8, "Up-leg (Rebounding/Rallying/Overbought)", group = GRP_COL)
color colDn        = input.color(#D84878, "Down-leg (Retracing/Reversing/Oversold)", group = GRP_COL)
color colSignal    = input.color(#C9CDD4, "Signal line", group = GRP_COL)
color colHistUpStr = input.color(#60C0D8, "Histogram: rising above zero", group = GRP_COL)
color colHistUpFad = input.color(#90D8E4, "Histogram: falling above zero", group = GRP_COL)
color colHistDnStr = input.color(#D84878, "Histogram: falling below zero", group = GRP_COL)
color colHistDnFad = input.color(#E490A8, "Histogram: rising below zero", group = GRP_COL)
color colBgUp      = input.color(#60C0D8, "Background: up-leg", group = GRP_COL)
color colBgRange   = input.color(#8A8A8A, "Background: Ranging", group = GRP_COL)
color colBgDn      = input.color(#D84878, "Background: down-leg", group = GRP_COL)

// ------------------------------ MACD-V -------------------------------
float emaFast = ta.ema(src, fastLen)
float emaSlow = ta.ema(src, slowLen)
float atr     = ta.atr(atrLen)
float macdv   = atr > 0 ? (emaFast - emaSlow) / atr * 100.0 : 0.0
float signal  = ta.ema(macdv, sigLen)
float hist    = macdv - signal

// ------------------------------ Plots --------------------------------
// MACD-V line: up-colour above its signal, down-colour below.
color macdvColor = macdv >= signal ? colUp : colDn

// Histogram: four states by sign (above/below zero) and slope (rising/falling).
bool  histRising = hist > nz(hist[1])
color histCol4   = hist > 0 ? (histRising ? colHistUpStr : colHistUpFad) : (histRising ? colHistDnFad : colHistDnStr)
color histColor  = histFourCol ? histCol4 : color.new(hist >= 0 ? colUp : colDn, 55)

plot(showHist ? hist : na, "Histogram", color = histColor, style = plot.style_columns)
plot(macdv,  "MACD-V", color = macdvColor, linewidth = 2)
plot(signal, "Signal", color = colSignal,  linewidth = 1)

// Dots at MACD-V / signal crosses, drawn on the signal line.
bool crossUp = ta.crossover(macdv, signal)
bool crossDn = ta.crossunder(macdv, signal)
plot(showCross and crossUp ? signal : na, "Cross up",   color = colUp, style = plot.style_circles, linewidth = 4)
plot(showCross and crossDn ? signal : na, "Cross down", color = colDn, style = plot.style_circles, linewidth = 4)

// Zero line plus the +/-50 and +/-150 roadmap levels.
hline(0, "Zero line", color = color.new(color.gray, 40), linestyle = hline.style_solid)
hline(showLineRange ? lvlOverbought : na, "Overbought (+150)",  color = color.new(color.gray, 50), linestyle = hline.style_solid)
hline(showLineRange ? lvlUpBound    : na, "Up boundary (+50)",  color = color.new(color.gray, 50), linestyle = hline.style_solid)
hline(showLineRange ? lvlDnBound    : na, "Down boundary (-50)", color = color.new(color.gray, 50), linestyle = hline.style_solid)
hline(showLineRange ? lvlOversold   : na, "Oversold (-150)",    color = color.new(color.gray, 50), linestyle = hline.style_solid)

// Histogram thresholds (separate scale).
hline(showHistRange and showHist ?  histExtreme : na, "Histogram +extreme", color = color.new(color.gray, 75), linestyle = hline.style_dotted)
hline(showHistRange and showHist ? -histExtreme : na, "Histogram -extreme", color = color.new(color.gray, 75), linestyle = hline.style_dotted)

// ------------------------- Lifecycle stage ---------------------------
// Raw band + direction, before the Ranging persistence rule is applied.
// Inside +/-50 it returns STAGE_RANGING as a candidate that may be held off.
classifyStage() =>
    int s = STAGE_RANGING
    if macdv >= lvlOverbought
        s := STAGE_OVERBOUGHT
    else if macdv >= lvlUpBound
        s := macdv >= signal ? STAGE_RALLYING : STAGE_RETRACING
    else if macdv > lvlDnBound
        s := STAGE_RANGING
    else if macdv > lvlOversold
        s := macdv >= signal ? STAGE_REBOUNDING : STAGE_REVERSING
    else
        s := STAGE_OVERSOLD
    s

isUpLeg(int s)   => s == STAGE_REBOUNDING or s == STAGE_RALLYING  or s == STAGE_OVERBOUGHT
isDownLeg(int s) => s == STAGE_OVERSOLD   or s == STAGE_REVERSING or s == STAGE_RETRACING

stageText(int s) =>
    switch s
        STAGE_OVERBOUGHT => "Overbought"
        STAGE_RALLYING   => "Rallying"
        STAGE_RETRACING  => "Retracing"
        STAGE_RANGING    => "Ranging"
        STAGE_REBOUNDING => "Rebounding"
        STAGE_REVERSING  => "Reversing"
        => "Oversold"

// Count consecutive bars inside +/-50; Ranging confirms only at N. Until
// then the prior committed leg is held, so brief touches are not Ranging.
bool inRange = macdv > lvlDnBound and macdv < lvlUpBound
var int rangeCount = 0
rangeCount := inRange ? nz(rangeCount[1]) + 1 : 0
bool rangingConfirmed = inRange and rangeCount >= rangeBars

int rawStage  = classifyStage()
var int stage = na
int heldStage = nz(stage[1], STAGE_RANGING)
stage := not inRange ? rawStage : (rangingConfirmed ? STAGE_RANGING : heldStage)

bool legUp   = isUpLeg(stage)
bool legDown = isDownLeg(stage)

// Leg drives label edge / colour; background adds depth toward +/-150.
color stageColor = legUp ? colUp : legDown ? colDn : color.new(colBgRange, 0)
float stageEdge  = legUp ? -labelEdge : legDown ? labelEdge : 0.0

int   depth    = math.abs(macdv) >= lvlOverbought ? 2 : math.abs(macdv) >= lvlUpBound ? 1 : 0
int   bgTransp = math.max(60, stageBgTransp - depth * 12)
color bgBase   = legUp ? colBgUp : legDown ? colBgDn : colBgRange
bgcolor(showStageBg ? color.new(bgBase, bgTransp) : na, title = "Stage background")

// One label per stage, centred on the bar run of that stage. The run that
// just ended spans stageStartBar..bar_index-1; label it at its midpoint.
var int   stageStartBar = bar_index
var int   prevStage     = na
var float prevStageEdge = na
var color prevStageCol  = na

bool stageChanged = not na(stage[1]) and stage != stage[1]

if showStageLabels and barstate.isconfirmed and stageChanged and not na(prevStage)
    int midBar = math.round((stageStartBar + bar_index - 1) / 2.0)
    label.new(midBar, prevStageEdge,
         text      = stageText(prevStage),
         yloc      = yloc.price,
         style     = label.style_label_center,
         color     = color.new(prevStageCol, 20),
         textcolor = color.white,
         size      = size.small)

if stageChanged
    stageStartBar := bar_index
prevStage     := stage
prevStageEdge := stageEdge
prevStageCol  := stageColor
````

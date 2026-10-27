# AVWAP Sextant

- url: https://www.tradingview.com/script/4IBbjA5Y-AVWAP-Sextant/
- type: indicator
- pine_id: PUB;4799cfa2fe034a7b95a7490e782c4aeb
- version: 1.0

## Description

Anchored VWAP bands get touched far less often than most traders expect, and most AVWAP tools never explain why. The AVWAP Sextant is built around that explanation. It works like a navigator's sextant, which returns an angle without caring what the navigator hoped to see: you sight a bar by hand, and the instrument measures forward from it without signals, alerts or opinions.

The Sextant is a supplementary tool rather than a trading system. It is designed to be laid over your own setups and techniques, so you can test whether a level you already trust coincides with the anchored crowd's actual cost and dispersion, and to manage trades already in progress. It confirms, questions and frames decisions you make by other means, and it never makes one for you.

Read to the end and you will be able to look at any band and ask the question a sigma reading actually answers, namely what share of the anchored crowd has traded as far from its cost as price sits at the moment.

[b]What the Sextant Draws[/b]

The anchor is one time input. You click the bar where you judge the measurement should begin (a gap, a policy print, a swing extreme, a session open or your own entry), and you drag it to re-sight. Nothing renders to the left of the anchor. Everything the instrument draws is arithmetic on three running sums of volume, price times volume and squared price times volume, all starting at that bar.

Four families of line hang from the anchor, and all four are on by default. The AVWAP is the anchored crowd's break-even, color-coded as either rising, flat or falling by its own slope, measured in the chart's average range per bar so one threshold serves young anchors and old ones alike. A golden envelope sits 1.618 sigma above and below it, always both rails. An exhaustion ribbon fills the space between 2.718 sigma (Euler's number, ) and 3.0 sigma, drawn only on the side of the AVWAP that price occupies.

The fourth family is a pair of 21-bar averages, one simple and one exponential, seeded at the anchor so neither knows any history before it. They share a length and differ only in weighting, so their fill changes color when recent prices stop agreeing with the window as a whole. An optional information table stays off by default, and the Data Window carries every value for traders who prefer numbers to pixels.

The instrument has boundaries worth knowing. It forecasts on the hourly chart and faster; above the hourly clock it still draws, under a notice marking the reading as retrospective. Sigma is tiny in the first bars after an anchor, so the rails mean little until history accumulates, and the same anchor reads slightly differently on each timeframe because slower bars compress the movement inside them. On feeds without volume the weighting collapses and the AVWAP becomes an ordinary average. An anchor outside the loaded history draws nothing and posts a notice rather than borrowing a nearby origin.

The anchor is a nail driven into a wall before any picture is hung, and no amount of careful hanging corrects a nail placed in the wrong stud.

[b]Why Price So Rarely Touches the Ribbon[/b]

The golden coefficient is not decoration. In a steady trend with even volume since the anchor, prices spread uniformly and the current price sits the square root of three sigma from the AVWAP, roughly 1.73. A trend moving at an even pace therefore lives just beyond the golden rail, and a price holding near that rail describes a move proceeding at its natural speed.

Sigma also translates into participation. Suppose a market built a base, jumped, and a fraction p of anchored volume has since traded at the new level; that level then sits at the square root of (1 − p) / p sigma from the AVWAP. The golden rail corresponds to roughly 28 percent of anchored volume, the inner ribbon line to roughly 12 percent, and the outer line to roughly 10 percent. A sigma reading is a census rather than a ruler.

The ribbon behaves like a rainbow that retreats as you walk toward it. A move large enough to reach 2.718 sigma usually arrives on heavy volume, and that volume trades far from the mean, so it inflates sigma in the same bar that carries price outward. Only a displacement on thin volume can close the distance, which is why contact is rare and meaningful when it happens. Young anchors seldom see it, since a single spike is a large share of a few hours of history, while multi-day anchors can.

[b]Two Primary Uses: Analysis and Trade Management[/b]

The first use is structural analysis. Sight the Sextant on an event you consider an origin, then read four things in order: the AVWAP's color, which shows where new volume is being accepted against the crowd's cost; price's position against the golden rail, which shows whether the move runs at an even pace; the ribbon's slope, which shows whether the trend's reach is still advancing; and the moving-average fill, which shows whether recent prices agree with the window. Compare each reading against your own levels and setups, and give weight to the places where the two independent methods agree.

The second use is managing a trade in progress. Drop the anchor on your entry bar, and the AVWAP becomes the cost basis of everyone who entered alongside you. The golden rail then reads as the pace limit of the move you hold, the ribbon as the zone where participation thins and partial exits deserve consideration, and a confirmed close back through the AVWAP as the moment the crowd you joined went under water.

A second Sextant anchored at the opposite extreme of the same move turns the pair into a vise, since a falling AVWAP above a rising one means two cost bases are closing on price. In either use the Sextant behaves like a second witness in a courtroom, and its testimony carries weight precisely because it was gathered independently of yours.

[b]Reading the Gold Chart Above[/b]

The chart shows gold on the 15-minute clock. The anchor sits on the October 7 low, labeled 4,066.535. The AVWAP climbs from that bar in its rising color, and the lower golden rail flattens far beneath price, which says the anchored crowd spent nearly the entire move in profit.

Next, watch the ribbon. Through October 8 it runs almost flat while price chops, a stalled reach, and its gaps mark bars where the side changed. The lone purple fragment beneath the AVWAP late that morning is a one-bar failed crossing, a close below the break-even that the next bar reversed.

Once the advance resumes, the ribbon lifts in price's direction, and price finally reaches it on the way into the session high labeled 4,207.485. In the final hours the ribbon keeps climbing while price flattens, and a ribbon rising away from a stalling price reports widening dispersion rather than advancing reach. The moving-average fill trades colors at the same time, as recent prices stop agreeing with the window.

The ribbon is a tide line on a beach, and its height matters less than whether each wave still leaves its mark higher up the sand.

[b]The Instrument Grades the Hand[/b]

A Sextant cannot be wrong. Every number it prints is exact arithmetic on the trades since the bar you chose, so when a fix fails, the failure belongs to the anchor.

That fact turns the usual test of an indicator inside out. Most scripts are judged by whether their signals worked, and this one has no signals to judge. What it measures instead is the person who sighted it, and the rails become a report card stapled to every click.

Keep a journal of anchors beside outcomes, alongside the setups they were meant to confirm. Over enough entries it will show which events you correctly recognized as origins, which of your own techniques the anchored crowd tends to agree with, and whether the hand that clicks the chart has learned anything at all.

The script is open source, contains no alert conditions or strategy logic, and is published for discretionary analysis and education rather than as financial advice.

## Source Code

````pine
// Open Source | Designed by Adrian Dyer for "The Leading Indicator", Engineered by PineForge Laboratory (2026)
// AVWAP Sextant (AVWAP-Sex) · first published October 2026
//   An anchored VWAP with a golden envelope, a one-sided exhaustion ribbon and a seeded MA ribbon.
//   The AVWAP is colored by its own slope, measured in the chart's average range per bar: rising,
//   flat or falling. It is a drawing tool: placed by hand, read by eye, and erased when done.
//   Forecasts on 1h and faster; above 1h it still draws, under a notice marking the reading as
//   retrospective. The status line stays empty by design; every number lives in the Data Window
//   and the optional information table, which reads the last closed bar.
//   No alertcondition(). No strategy constructs. Live discretionary use only.

//@version=6
indicator(title="AVWAP Sextant", shorttitle="AVWAP-Sex", overlay = true)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
string G_ANCH = "Anchor"
string G_BASE = "Anchored VWAP (coefficient 1)"
string G_GOLD = "Golden Envelope (symmetric)"
string G_RIB  = "Exhaustion Ribbon (biased)"
string G_MA   = "Moving-Average Ribbon"
string G_TAB  = "Information Table"

string S_LINE = "Line"
string S_STEP = "Stepline"
string S_CIRC = "Circles"

string F_LIVE = "Live (intrabar)"
string F_CONF = "Confirmed on Close"

string M_GATE = "Render-Gated (rolling, hidden before anchor)"
string M_SEED = "Seeded (knows nothing before anchor)"

anchorInput = input.time(timestamp("01 Jan 2025 00:00 +0000"), "Anchor (click the chart)", confirm = true, group = G_ANCH,
     tooltip = "The single origin every measurement accumulates from. Place it on the bar you judged worth measuring from; drag it to re-sight. Nothing renders to its left.")

showBaseInput  = input.bool(true, "Show AVWAP", group = G_BASE)
baseColInput   = input.color(#FFF9C4, "Flat", group = G_BASE, inline = "b")
baseUpInput    = input.color(#81C784, "Rising", group = G_BASE, inline = "b")
baseDnInput    = input.color(#F7525F, "Falling", group = G_BASE, inline = "b")
baseWInput     = input.int(1, "Width", minval = 1, maxval = 5, group = G_BASE)
baseSlopeOn    = input.bool(true, "Color by Slope", group = G_BASE,
     tooltip = "Colors the AVWAP by its own slope: Rising, Flat or Falling. With this off, the line keeps the Flat color throughout.")
baseSlopeLen   = input.int(8, "AVWAP Slope Window (bars)", minval = 2, maxval = 55, group = G_BASE,
     tooltip = "The AVWAP's change over this many bars, divided by the window and by the chart's 13-bar average range. A steady trend on even volume reads the same at any anchor age in this unit.")
baseFlatInput  = input.float(0.034, "Flat Threshold (ranges per bar)", minval = 0.0, step = 0.001, group = G_BASE,
     tooltip = "Slopes inside plus or minus this value color the line Flat. The line stays Flat for the first two windows after the anchor, while the AVWAP is still finding its weight, and until the 13-bar average range has history.")
baseStyleInput = input.string(S_LINE, "Style", options = [S_LINE, S_STEP, S_CIRC], group = G_BASE)

showGoldInput  = input.bool(true, "Show Golden Envelope", group = G_GOLD)
goldCoefInput  = input.float(1.618, "Coefficient (x VW Sigma)", minval = 0.1, step = 0.001, group = G_GOLD,
     tooltip = "Both rails, always drawn, above and below the AVWAP. The envelope traps the bilateral event: a vault across the AVWAP, an overshoot into the far rail, a snap back. A one-sided rail would be blind exactly when you need it.")
goldColInput   = input.color(#FBC02D, "Color", group = G_GOLD, inline = "g")
goldWInput     = input.int(1, "Width", minval = 1, maxval = 5, group = G_GOLD, inline = "g")
goldStyleInput = input.string(S_LINE, "Style", options = [S_LINE, S_STEP, S_CIRC], group = G_GOLD)

showRibInput   = input.bool(true, "Show Exhaustion Ribbon", group = G_RIB)
ribInCoefInput = input.float(2.718, "Inner Coefficient", minval = 0.1, step = 0.001, group = G_RIB)
ribOutCoefInput= input.float(3.0, "Outer Coefficient", minval = 0.1, step = 0.001, group = G_RIB)
ribInColInput  = input.color(#F8BBD0, "Inner Line", group = G_RIB, inline = "r1")
ribInWInput    = input.int(1, "Width", minval = 1, maxval = 5, group = G_RIB, inline = "r1")
ribOutColInput = input.color(#9575CD, "Outer Line", group = G_RIB, inline = "r2")
ribOutWInput   = input.int(1, "Width", minval = 1, maxval = 5, group = G_RIB, inline = "r2")
ribStyleInput  = input.string(S_LINE, "Style", options = [S_LINE, S_STEP, S_CIRC], group = G_RIB)
ribFillColInput= input.color(#BA68C8, "Fill Color", group = G_RIB, inline = "r3")
ribFillOpInput = input.int(34, "Fill Transparency", minval = 0, maxval = 100, group = G_RIB, inline = "r3")
flipModeInput  = input.string(F_CONF, "Flip Behavior", options = [F_CONF, F_LIVE], group = G_RIB,
     tooltip = "The ribbon renders only on the side of the AVWAP that price occupies and flips when price crosses. Live flips the instant price ticks across, honest and slightly jarring. Confirmed waits for a close beyond the AVWAP, so a wick never strobes it. Scalpers tend to want Live; structural readers want Confirmed.")
slopeLenInput  = input.int(8, "Reach Slope Window (bars)", minval = 2, maxval = 55, group = G_RIB,
     tooltip = "The ribbon's slope is measured over this many bars and expressed in sigma per bar, signed so that a positive value means the ribbon is advancing in the direction of the side price occupies. A window that crosses a flip of side reports nothing.")
stallInput     = input.float(0.01, "Stall Buffer (sigma per bar)", minval = 0.0, step = 0.001, group = G_RIB,
     tooltip = "Slopes inside plus or minus this value read as Stalling in the table. A starting value, to be tuned against captures.")

showMAInput   = input.bool(true, "Show MA Ribbon", group = G_MA)
maModeInput   = input.string(M_SEED, "Anchoring", options = [M_SEED, M_GATE], group = G_MA,
     tooltip = "Seeded: the averages initialize at the anchor and know nothing before it, expanding until their window fills; expect them squashed near the AVWAP in their first bars. Render-Gated: the averages roll conventionally over their full lookback and are simply not drawn left of the anchor, so pre-anchor history lives inside them.")
ma1TypeInput  = input.string("SMA", "MA 1 Type", options = ["SMA", "EMA", "HMA", "VWMA"], group = G_MA, inline = "m1")
ma1LenInput   = input.int(21, "Length", minval = 2, maxval = 500, group = G_MA, inline = "m1")
ma1ColInput   = input.color(#A5D6A7, "Color", group = G_MA, inline = "m1")
ma2TypeInput  = input.string("EMA", "MA 2 Type", options = ["SMA", "EMA", "HMA", "VWMA"], group = G_MA, inline = "m2")
ma2LenInput   = input.int(21, "Length", minval = 2, maxval = 500, group = G_MA, inline = "m2")
ma2ColInput   = input.color(#F77C80, "Color", group = G_MA, inline = "m2")
maWInput      = input.int(1, "MA Width", minval = 1, maxval = 5, group = G_MA, inline = "m3")
maStyleInput  = input.string(S_LINE, "Style", options = [S_LINE, S_STEP, S_CIRC], group = G_MA, inline = "m3")
shadeUpInput  = input.color(#66BB6A, "Shade: MA1 Above", group = G_MA, inline = "m4")
shadeDnInput  = input.color(#F7525F, "MA1 Below", group = G_MA, inline = "m4")
shadeOpInput  = input.int(34, "Shade Transparency", minval = 0, maxval = 100, group = G_MA)

string TB_COMPACT = "Compact"
string TB_FULL    = "Full"
showTabInput  = input.bool(false, "Show Table", group = G_TAB)
tabModeInput  = input.string(TB_FULL, "Rows", options = [TB_COMPACT, TB_FULL], group = G_TAB,
     tooltip = "Full shows every row. Compact keeps AVWAP, Position, Reach and Anchor age: which way the crowd's cost is moving, where price sits, whether the ribbon is reaching, and how old the sighting is.")
tabPosInput   = input.string("Middle Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_TAB,
     tooltip = "Middle Right keeps clear of the corners other price-pane instruments use. With two or more Sextants on one chart, show the table on one of them at most, or the tables print over each other.")
tabSizeInput  = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_TAB)
tabBgInput    = input.color(color.new(#2A2E39, 20), "Background", group = G_TAB)
tabLabelInput = input.color(#FAF3B2, "Label Color", group = G_TAB,
     tooltip = "Colors the left column. The title and the right column keep their own colors, which carry each value's meaning.")
tabBorderCInput = input.color(color.new(#FAF3B2, 70), "Border Color", group = G_TAB)
tabBorderWInput = input.int(1, "Border Width", minval = 0, maxval = 5, group = G_TAB,
     tooltip = "Sets both the outline around the table and the lines between its cells.")
showFootInput = input.bool(true, "Show Settings Footnote", group = G_TAB,
     tooltip = "Prints only the settings that depart from the defaults, so a capture records how the instrument was tuned.")
tabReadInput  = input.string("Closed bar", "Table Reads", options = ["Closed bar", "Live bar"], group = G_TAB,
     tooltip = "Closed bar: while a bar is still forming, the table reports the last closed bar. Live bar: the table reports the forming bar. The drawings and the Data Window are unaffected.")

//──────────────────────────────────────────────────────────────────────────────
// Timeframe posture: the instrument forecasts on 1h and faster; above 1h it
// still draws, and a notice marks the reading as retrospective.
//──────────────────────────────────────────────────────────────────────────────
bool aboveDesign = timeframe.isticks ? false : timeframe.in_seconds(timeframe.period) > 3600

//──────────────────────────────────────────────────────────────────────────────
// Anchor state
//──────────────────────────────────────────────────────────────────────────────
var int firstTime = na
if na(firstTime)
    firstTime := time

bool validAnchor = anchorInput >= firstTime
bool anchored    = validAnchor and time >= anchorInput
bool anchorBar   = anchored and not anchored[1]

var bool everAnchored = false
if anchored
    everAnchored := true

var int nSince = 0
if anchorBar
    nSince := 1
else if anchored
    nSince += 1

//──────────────────────────────────────────────────────────────────────────────
// Anchored VWAP and volume-weighted sigma (running sums, reset at anchor)
//──────────────────────────────────────────────────────────────────────────────
var float cV   = 0.0
var float cPV  = 0.0
var float cPV2 = 0.0
if anchorBar
    cV := 0.0
    cPV := 0.0
    cPV2 := 0.0
if anchored
    float tp = hlc3
    float v = math.max(nz(volume), 1e-6)
    cV   += v
    cPV  += tp * v
    cPV2 += tp * tp * v

float vwapV  = anchored and cV > 0 ? cPV / cV : na
float sigmaV = anchored and cV > 0 ? math.sqrt(math.max(cPV2 / cV - vwapV * vwapV, 0.0)) : na

//──────────────────────────────────────────────────────────────────────────────
// Ribbon side: live or held-until-confirmed
//──────────────────────────────────────────────────────────────────────────────
int liveSide = na(vwapV) ? 1 : close >= vwapV ? 1 : -1
var int heldSide = 1
int side = flipModeInput == F_LIVE ? liveSide : heldSide
if barstate.isconfirmed and not na(vwapV)
    heldSide := liveSide

//──────────────────────────────────────────────────────────────────────────────
// Series
//──────────────────────────────────────────────────────────────────────────────
float baseP = showBaseInput ? vwapV : na
float goldU = showGoldInput and not na(vwapV) ? vwapV + goldCoefInput * sigmaV : na
float goldD = showGoldInput and not na(vwapV) ? vwapV - goldCoefInput * sigmaV : na

bool flipped = side != side[1]
float ribIn  = showRibInput and not na(vwapV) and not flipped ? vwapV + ribInCoefInput  * sigmaV * side : na
float ribOut = showRibInput and not na(vwapV) and not flipped ? vwapV + ribOutCoefInput * sigmaV * side : na

// Rolling moving averages (all four computed unconditionally; lengths are simple)
float ma1Sma = ta.sma(close, ma1LenInput)
float ma1Ema = ta.ema(close, ma1LenInput)
float ma1Hma = ta.hma(close, ma1LenInput)
float ma1Vwm = ta.vwma(close, ma1LenInput)
float ma2Sma = ta.sma(close, ma2LenInput)
float ma2Ema = ta.ema(close, ma2LenInput)
float ma2Hma = ta.hma(close, ma2LenInput)
float ma2Vwm = ta.vwma(close, ma2LenInput)

// A volume-weighted average needs volume; on feeds without it (indices, some
// CFDs and FX) the VWMA falls back to the simple average of the same length.
rollOf(string typ, float sV, float eV, float hV, float vV) =>
    typ == "SMA" ? sV : typ == "EMA" ? eV : typ == "HMA" ? hV : (na(vV) ? sV : vV)

// Seeded averages: exact for SMA/EMA/VWMA; HMA seeds as a cumulative mean
// during warmup, then switches to the true Hull once its window fills.
seededMA(float src, int len, string typ, float rollV, bool aBar, bool aOn, int n) =>
    var float sSum = 0.0
    var float sVS  = 0.0
    var float sVol = 0.0
    var float e    = na
    if aBar
        sSum := 0.0
        sVS := 0.0
        sVol := 0.0
        e := src
    if aOn
        sSum += src
        sVS  += src * math.max(nz(volume), 1e-6)
        sVol += math.max(nz(volume), 1e-6)
        float alpha = 2.0 / (len + 1)
        e := na(e) ? src : alpha * src + (1 - alpha) * e
    float cumMean = n > 0 ? sSum / n : src
    float cumVwma = sVol > 0 ? sVS / sVol : cumMean
    typ == "EMA" ? e :
     typ == "SMA" ? (n < len ? cumMean : rollV) :
     typ == "VWMA" ? (n < len ? cumVwma : rollV) :
     (n < len ? cumMean : rollV)

float ma1Roll = rollOf(ma1TypeInput, ma1Sma, ma1Ema, ma1Hma, ma1Vwm)
float ma2Roll = rollOf(ma2TypeInput, ma2Sma, ma2Ema, ma2Hma, ma2Vwm)
float ma1Seed = seededMA(close, ma1LenInput, ma1TypeInput, ma1Roll, anchorBar, anchored, nSince)
float ma2Seed = seededMA(close, ma2LenInput, ma2TypeInput, ma2Roll, anchorBar, anchored, nSince)

bool maOn = showMAInput and anchored
float ma1V = maOn ? (maModeInput == M_SEED ? ma1Seed : ma1Roll) : na
float ma2V = maOn ? (maModeInput == M_SEED ? ma2Seed : ma2Roll) : na

//──────────────────────────────────────────────────────────────────────────────
// Derived readings: position in sigma and the ribbon's reach slope
//──────────────────────────────────────────────────────────────────────────────
// Position is price's signed distance from the AVWAP in volume-weighted sigma.
float posSigma = anchored and sigmaV > 0 ? (close - vwapV) / sigmaV : na

// The reach slope follows the inner ribbon level whether or not the ribbon is
// drawn, over a window that contains no change of side, in sigma per bar,
// signed so that a positive value means the ribbon advances on price's side.
// The run of bars on the current side starts at the anchor or at a flip, and
// the slope waits two windows after the anchor so that the birth of sigma is
// not mistaken for reach.
float ribLevel  = anchored and not na(vwapV) ? vwapV + ribInCoefInput * sigmaV * side : na
var int sideRun = 0
sideRun := anchorBar or side != nz(side[1], side) ? 1 : anchored ? sideRun + 1 : 0
bool  slopeOk   = anchored and nSince > 2 * slopeLenInput and sideRun > slopeLenInput and sigmaV > 0
float reachSlope = slopeOk ? side * (ribLevel - ribLevel[slopeLenInput]) / (slopeLenInput * sigmaV) : na
int   reachCode  = na(reachSlope) ? na : reachSlope > stallInput ? 1 : reachSlope < -stallInput ? -1 : 0

// The AVWAP's own slope, in the chart's 13-bar average range per bar. In a
// steady trend on even volume the AVWAP advances at half the pace of price whatever the
// anchor's age, so this unit holds one threshold for young and old anchors.
float atrV      = ta.atr(13)
bool  avSlopeOk = anchored and nSince > 2 * baseSlopeLen and not na(atrV) and atrV > 0
float avSlope   = avSlopeOk ? (vwapV - vwapV[baseSlopeLen]) / (baseSlopeLen * atrV) : na
int   avCode    = na(avSlope) ? na : avSlope > baseFlatInput ? 1 : avSlope < -baseFlatInput ? -1 : 0
color baseCol   = baseSlopeOn and not na(avCode) ? (avCode == 1 ? baseUpInput : avCode == -1 ? baseDnInput : baseColInput) : baseColInput

//──────────────────────────────────────────────────────────────────────────────
// Plots: one plot per line, its style taken from the input. TradingView caps
// a script at 64 plots, and a series color or a fill counts against the cap,
// so the lines are never drawn once per style.
//──────────────────────────────────────────────────────────────────────────────
baseStyle = baseStyleInput == S_STEP ? plot.style_stepline : baseStyleInput == S_CIRC ? plot.style_circles : plot.style_linebr
goldStyle = goldStyleInput == S_STEP ? plot.style_stepline : goldStyleInput == S_CIRC ? plot.style_circles : plot.style_linebr
ribStyle  = ribStyleInput  == S_STEP ? plot.style_stepline : ribStyleInput  == S_CIRC ? plot.style_circles : plot.style_linebr
maStyle   = maStyleInput   == S_STEP ? plot.style_stepline : maStyleInput   == S_CIRC ? plot.style_circles : plot.style_linebr

// Base line, colored by its own slope
plot(baseP, "AVWAP", color = baseCol, linewidth = baseWInput, style = baseStyle, display = display.pane)

// Golden envelope (both rails, always)
plot(goldU, "Gold +", color = goldColInput, linewidth = goldWInput, style = goldStyle, display = display.pane)
plot(goldD, "Gold -", color = goldColInput, linewidth = goldWInput, style = goldStyle, display = display.pane)

// Exhaustion ribbon (biased) with its fill
pRi = plot(ribIn,  "e-Rib In",  color = ribInColInput,  linewidth = ribInWInput,  style = ribStyle, display = display.pane)
pRo = plot(ribOut, "e-Rib Out", color = ribOutColInput, linewidth = ribOutWInput, style = ribStyle, display = display.pane)
fill(pRi, pRo, color = color.new(ribFillColInput, ribFillOpInput))

// MA ribbon with variable cross shading
color shade = ma1V >= ma2V ? color.new(shadeUpInput, shadeOpInput) : color.new(shadeDnInput, shadeOpInput)
pM1 = plot(ma1V, "MA 1", color = ma1ColInput, linewidth = maWInput, style = maStyle, display = display.pane)
pM2 = plot(ma2V, "MA 2", color = ma2ColInput, linewidth = maWInput, style = maStyle, display = display.pane)
fill(pM1, pM2, color = shade)

//──────────────────────────────────────────────────────────────────────────────
// Notices: an invalid anchor draws nothing rather than substitute an origin,
// and a chart above 1h is marked as retrospective.
//──────────────────────────────────────────────────────────────────────────────
var label ntc = na
var table tfNote = na
if barstate.islast
    if not validAnchor or not everAnchored
        string msg = not validAnchor ?
             "Sextant · The anchor precedes loaded history. Drag it onto a visible bar." :
             "Sextant · The anchor sits ahead of the last bar. Nothing to sight yet."
        if na(ntc)
            ntc := label.new(bar_index, close, msg, style = label.style_label_left,
                 color = color.new(#161616, 20), textcolor = #DBDBDB, size = size.small)
        else
            label.set_xy(ntc, bar_index, close)
            label.set_text(ntc, msg)
    else if not na(ntc)
        label.delete(ntc)
        ntc := na
    if aboveDesign
        if na(tfNote)
            tfNote := table.new(tabPosInput == "Bottom Center" ? position.top_center : position.bottom_center, 1, 1, bgcolor = color.new(#161616, 30), border_width = 0)
        table.cell(tfNote, 0, 0, "Sextant · above 1h the rails confirm swings after the fact; they do not forecast", text_color = color.yellow, text_size = size.small)
    else if not na(tfNote)
        table.delete(tfNote)
        tfNote := na

//──────────────────────────────────────────────────────────────────────────────
// Information table (optional, closed bar by default)
//──────────────────────────────────────────────────────────────────────────────
int k = tabReadInput == "Live bar" or barstate.isconfirmed ? 0 : 1

f_fmt(float x) =>
    na(x) ? "—" : str.tostring(x, format.mintick)

f_sig3(float x) =>
    na(x) ? "—" : (x < 0 and math.round(x, 3) != 0 ? "−" : "+") + str.tostring(math.abs(x), "0.000")

f_sig(float x) =>
    na(x) ? "—" : (x < 0 and math.round(x, 2) != 0 ? "−" : "+") + str.tostring(math.abs(x), "0.00")

// Calendar span from the anchor to the bar read, so weekends and overnight
// gaps sit inside it; long spans drop their minutes, short ones their days.
f_dur(int ms) =>
    string s = "—"
    if not na(ms) and ms >= 0
        float secs = ms / 1000.0
        float d    = math.floor(secs / 86400)
        float h    = math.floor((secs - d * 86400) / 3600)
        float m    = math.floor((secs - d * 86400 - h * 3600) / 60)
        s := d >= 10 ? str.tostring(d, "#") + " d" : d >= 1 ? str.tostring(d, "#") + " d " + str.tostring(h, "#") + " h" :
             h >= 1 ? str.tostring(h, "#") + " h " + str.tostring(m, "#") + " min" : str.tostring(m, "#") + " min"
    s

f_tf() =>
    timeframe.isminutes ? (timeframe.multiplier % 60 == 0 ? str.tostring(timeframe.multiplier / 60, "#") + "h" : timeframe.period + "m") : timeframe.period

var string tabPos = switch tabPosInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.bottom_left

var string tabSize = switch tabSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

color QUIET = color.gray

var table tab = na
if showTabInput and na(tab)
    tab := table.new(tabPos, 2, 12, bgcolor = tabBgInput, frame_color = tabBorderCInput, frame_width = tabBorderWInput,
         border_color = tabBorderCInput, border_width = tabBorderWInput)

f_cell(int c, int r, string txt, color col) =>
    table.cell(tab, c, r, txt, text_color = col, text_size = tabSize, text_halign = text.align_left)

f_row(int r, string key, string val, color vc) =>
    f_cell(0, r, key, tabLabelInput)
    f_cell(1, r, val, vc)

bool defCoef = goldCoefInput == 1.618 and ribInCoefInput == 2.718 and ribOutCoefInput == 3.0
bool defSlope = slopeLenInput == 8 and stallInput == 0.01
bool defMA = ma1TypeInput == "SMA" and ma1LenInput == 21 and ma2TypeInput == "EMA" and ma2LenInput == 21 and maModeInput == M_SEED

if showTabInput and barstate.islast
    table.clear(tab, 0, 0, 1, 11)
    bool full    = tabModeInput == TB_FULL
    bool sighted = validAnchor and everAnchored
    bool readOk  = sighted and anchored[k]
    f_cell(0, 0, "AVWAP-Sex", color.white)
    f_cell(1, 0, syminfo.ticker + " · " + f_tf() + (aboveDesign ? " · above 1h" : ""), aboveDesign ? color.yellow : color.white)
    int r = 1
    if not readOk
        f_row(r, "Status", not validAnchor ? "Anchor precedes loaded history" : not sighted ? "Anchor ahead of the last bar" : "Sighted · awaiting first close", QUIET)
        r += 1
    else
        int   sideT = side[k]
        int   rcT   = reachCode[k]
        float m1T   = ma1V[k]
        float m2T   = ma2V[k]
        string ageT = str.tostring(nSince[k]) + " bars · ≈ " + f_dur(time[k] - anchorInput)
        string reachT = na(rcT) ? "Settling" : (rcT == 1 ? "Advancing" : rcT == -1 ? "Contracting" : "Stalling") + " · " + f_sig(reachSlope[k]) + " σ/bar"
        color  reachC = na(rcT) ? QUIET : rcT == 0 ? color.yellow : rcT == 1 ? ribInColInput : ribOutColInput
        int    avT    = avCode[k]
        string avTxt  = f_fmt(vwapV[k]) + " · " + (na(avT) ? "Settling" : (avT == 1 ? "Rising" : avT == -1 ? "Falling" : "Flat") + " " + f_sig3(avSlope[k]) + " r/bar")
        color  avC    = na(avT) ? QUIET : baseCol[k]
        if full
            f_row(r, "Anchor age", ageT, color.white)
            r += 1
            f_row(r, "AVWAP", avTxt, avC)
            r += 1
            f_row(r, "Sigma", f_fmt(sigmaV[k]), color.white)
            r += 1
        if not full
            f_row(r, "AVWAP", avTxt, avC)
            r += 1
        f_row(r, "Position", (na(posSigma[k]) ? "—" : f_sig(posSigma[k]) + " σ · " + (posSigma[k] >= 0 ? "above" : "below")), color.white)
        r += 1
        if full
            f_row(r, "Golden rails", showGoldInput ? f_fmt(vwapV[k] + goldCoefInput * sigmaV[k]) + " / " + f_fmt(vwapV[k] - goldCoefInput * sigmaV[k]) : "Off", showGoldInput ? goldColInput : QUIET)
            r += 1
            bool ribShown = showRibInput and not flipped[k]
            f_row(r, "Ribbon", not ribShown ? (showRibInput ? "Flipping" : "Off") : (sideT > 0 ? "Above " : "Below ") + f_fmt(vwapV[k] + ribInCoefInput * sigmaV[k] * sideT) + " to " + f_fmt(vwapV[k] + ribOutCoefInput * sigmaV[k] * sideT),
                 ribShown ? ribInColInput : QUIET)
            r += 1
        f_row(r, "Reach", reachT, reachC)
        r += 1
        if full
            bool maNa = na(m1T) or na(m2T)
            f_row(r, "MA ribbon", maNa ? "Off" : m1T >= m2T ? "MA 1 leads" : "MA 1 trails", maNa ? QUIET : m1T >= m2T ? color.new(shadeUpInput, 0) : color.new(shadeDnInput, 0))
            r += 1
        else
            f_row(r, "Anchor age", ageT, color.white)
            r += 1
    if showFootInput
        array<string> parts = array.new<string>()
        if flipModeInput == F_LIVE
            parts.push("Live flip")
        if tabReadInput == "Live bar"
            parts.push("Live read")
        if not defCoef
            parts.push(str.tostring(goldCoefInput) + " · " + str.tostring(ribInCoefInput) + "/" + str.tostring(ribOutCoefInput))
        if not baseSlopeOn
            parts.push("Slope color off")
        if baseSlopeLen != 8 or baseFlatInput != 0.034
            parts.push("A" + str.tostring(baseSlopeLen) + "/" + str.tostring(baseFlatInput))
        if not defSlope
            parts.push("S" + str.tostring(slopeLenInput) + "/" + str.tostring(stallInput))
        if not showMAInput
            parts.push("MA off")
        else if not defMA
            parts.push(ma1TypeInput + str.tostring(ma1LenInput) + "/" + ma2TypeInput + str.tostring(ma2LenInput) + (maModeInput == M_SEED ? " Seeded" : " Gated"))
        f_row(r, "Settings", parts.size() == 0 ? "Defaults" : array.join(parts, " · "), QUIET)
else if not showTabInput and not na(tab)
    table.delete(tab)
    tab := na

//──────────────────────────────────────────────────────────────────────────────
// Data Window numeric interface (nothing added to the chart pane)
//──────────────────────────────────────────────────────────────────────────────
float dwState = validAnchor and everAnchored ? 1 : -1
plot(dwState,                        "State (1 Sighted / -1 No Anchor)", display = display.data_window, editable = false)
plot(vwapV,                          "AVWAP",            display = display.data_window, editable = false)
plot(sigmaV,                         "VW Sigma",         display = display.data_window, editable = false)
plot(anchored ? vwapV + goldCoefInput * sigmaV : na, "Gold Upper", display = display.data_window, editable = false)
plot(anchored ? vwapV - goldCoefInput * sigmaV : na, "Gold Lower", display = display.data_window, editable = false)
plot(anchored and showRibInput and not flipped ? vwapV + ribInCoefInput  * sigmaV * side : na, "Ribbon Inner", display = display.data_window, editable = false)
plot(anchored and showRibInput and not flipped ? vwapV + ribOutCoefInput * sigmaV * side : na, "Ribbon Outer", display = display.data_window, editable = false)
plot(anchored ? side : na,           "Ribbon Side (1 Above / -1 Below)", display = display.data_window, editable = false)
plot(ma1V,                           "MA 1",             display = display.data_window, editable = false)
plot(ma2V,                           "MA 2",             display = display.data_window, editable = false)
plot(maOn and not na(ma1V) and not na(ma2V) ? (ma1V >= ma2V ? 1 : -1) : na, "MA Spread Sign", display = display.data_window, editable = false)
plot(posSigma,                       "Position (σ from AVWAP, signed)", format = format.price, precision = 3, display = display.data_window, editable = false)
plot(anchored ? nSince : na,         "Anchor Age (bars)", format = format.price, precision = 0, display = display.data_window, editable = false)
plot(reachSlope,                     "Reach Slope (σ per bar, + advancing on price's side)", format = format.price, precision = 4, display = display.data_window, editable = false)
plot(reachCode,                      "Reach (1 Advancing / 0 Stalling / -1 Contracting)", format = format.price, precision = 0, display = display.data_window, editable = false)
plot(avSlope,                        "AVWAP Slope (ranges per bar)", format = format.price, precision = 4, display = display.data_window, editable = false)
plot(avCode,                         "AVWAP Trend (1 Rising / 0 Flat / -1 Falling)", format = format.price, precision = 0, display = display.data_window, editable = false)
plot(aboveDesign ? 1 : 0,            "Above 1h (1 retrospective / 0 forecasting range)", format = format.price, precision = 0, display = display.data_window, editable = false)
````

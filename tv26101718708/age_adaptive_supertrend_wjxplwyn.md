# Age Adaptive Supertrend

- url: https://www.tradingview.com/script/wJXPlWYN-Age-Adaptive-Supertrend/
- type: indicator
- pine_id: PUB;843341c0d3c74a1791675519b24aedab
- version: 1.0

## Description

█ OVERVIEW
Age Adaptive Supertrend is an adaptive version of the classic Supertrend. The width of the active band is not fixed for the whole trend. It changes with the age of the current move and with how efficiently price is moving in its direction.

Instead of keeping the same ATR multiplier from the start of a trend to its end, the indicator compares the current trend age with the historical distribution of trend durations in the same direction. The further the current trend moves into the later part of a typical duration, the more the band can tighten and the more sensitive it becomes to the end of the move.

Adaptation is not based on age alone. The Efficiency Ratio (ER) can limit tightening while the move is strongly directional.
• with high efficiency, the band can keep its standard width
• when the move loses quality and starts to look like consolidation, tightening can reach the full value implied by the trend's age

The trend-duration history comes from an internal classic reference Supertrend. More recent completed trends carry more weight through an exponential half-life. Statistics are kept separately for uptrends and downtrends.

The indicator can also display the classic Supertrend for reference, Entry / SL / TP levels for the most recent signal, and a diagnostic table showing the trend's direction, age, efficiency, current band multiplier and stop level.

█ CONCEPTS
The indicator combines the classic Supertrend construction with trend-age analysis, the historical distribution of trend durations and the efficiency of the current move. The band does not have to be the same width at the beginning and at the end of a trend.

Age Adaptive Supertrend does not forecast a price target. Adaptation only determines how tightly the active band protects the current trend.

Trend Age
• age is counted from the last direction change of the adaptive version
• a new trend starts at age 1, and age increases by 1 with each subsequent bar
• this age is compared with the duration history of reference trends in the same direction
• uptrends use a separate uptrend history
• downtrends use a separate downtrend history

Historical Trend Duration
• the history is not built from the adaptive band
• it comes from the classic reference Supertrend, which uses the same ATR Length and Base Multiplier
• each time a reference trend ends, its duration is recorded
• up to 300 of the most recent observations are kept per direction
• older entries are removed
• observation weights decay exponentially according to the Half-Life parameter
• with a Half-Life of 40, a trend that ended 40 reference trends ago (counting both directions) has half the weight of the most recent one
• this keeps the statistics stable while still allowing them to adapt to changes in market character

Trend Survival (S)
• from the weighted history, the indicator calculates a value S: a smoothed survival measure showing what weighted share of historical trends lasted longer than the current age
• a high S means that many historical trends in this direction lasted longer than the current one
• a low S means that the current trend is already in the later part of the historical duration distribution
• S is not a raw percentage of observations
• it is a smoothed, exponentially weighted survival function
• thanks to the smoothing, S changes gradually as the trend ages instead of jumping at each historical duration
• the ongoing reference trend can be added to S as a censored observation
• this happens when it has the same direction as the adaptive trend and is already older than it
• this behavior is always active in the indicator's logic and is not a separate setting
• adaptation starts only after at least 15 historical trends have been collected in a given direction
• until then, S equals 1 and the band stays at its base width

Efficiency Ratio
• ER measures the quality of the move since the start of the current adaptive trend
• it is the price displacement in the trend direction divided by the sum of all moves between consecutive closes
• the value ranges from 0 to 1
• ER close to 1 indicates a strongly directional move with few pullbacks
• ER close to 0 indicates an inefficient move: consolidation, or a move often running against the trend
• displacement against the trend is clipped to zero, so ER never falls below 0
• measurement starts from the close of the bar on which the direction changed

Efficient Trend Protection
When Protect Efficient Trends is enabled, ER limits the tightening that results from age.
• above the Efficiency Threshold, age does not tighten the band
• between the threshold and a value 0.25 lower, the influence of age on tightening increases linearly
• at the lower level and below, tightening reaches the full value implied by S

This allows a strong, directional trend to keep its standard room, while a long but inefficient trend can be tightened sooner.

When Protect Efficient Trends is disabled, adaptation depends only on trend age and the historical duration distribution.

Adaptive Multiplier
S and ER combine into an effective adaptation level, Seff. The ATR multiplier is then reduced relative to the Base Multiplier, but never below the Minimum Multiplier. Tightening Strength controls how strongly that reduction is applied.
• Base Multiplier sets the initial band width
• Tightening Strength controls how strongly the band tightens
• a value of 0 disables adaptation and reproduces the classic Supertrend
• a value of 1 is standard
• values above 1 tighten the band more aggressively
• Minimum Multiplier stops the band from moving any closer to price

In practice:
• a young or efficient trend keeps a width close to the base
• an older or less efficient trend may get a tighter band
• once the Minimum Multiplier is reached, further tightening stops
• only the band of the current direction is tightened
• the opposite band always uses the Base Multiplier

Adaptive Supertrend Logic
The band construction remains classic and is based on ATR and the midpoint of the bar.
• in an uptrend the band sits below price
• in a downtrend the band sits above price
• the band never moves backward against the prevailing trend
• the direction changes when the closing price crosses the active band
• after a direction change, age and efficiency are measured anew
• because the line never moves backward, its actual distance from price may be smaller than the current multiplier alone would suggest

Reference Supertrend
• the optional Reference ST displays the classic Supertrend with the same ATR Length and Base Multiplier
• it is not an additional signal
• it serves as a visual reference and as the source of the trend-duration history
• when enabled, it shows how far the adaptive version deviates from the classic one

Trend Signals
• a Buy signal appears when the direction changes from Downtrend to Uptrend
• a Sell signal appears when the direction changes from Uptrend to Downtrend
• the signal is generated on the bar where the direction changes
• on a real-time bar it may appear and disappear before the bar closes
• once the bar has closed, the signal is final

Trend Visualization
The line color reflects the current direction:
• the up color for an Uptrend
• the down color for a Downtrend

Diagnostic Table
The table summarizes the state of the current adaptive trend. It shows the direction, age relative to the historical median, the weighted measure of historical continuation, efficiency since the start of the trend, the current band multiplier, and the stop level with its distance from price.

It goes beyond direction alone. It shows how the current trend compares with the data the adaptation mechanism relies on.

Age
• age is the number of bars since the start of the current adaptive trend
• next to it, the median duration of historical reference trends in the same direction is shown
• the median is calculated from the stored durations and is not weighted by half-life

Longer Trends in History
• this value shows S as a percentage: the weighted and smoothed share of historical trends that lasted longer than the current age
• a high value means the current trend is still relatively young compared with history
• a low value means it is already in the later part of the distribution
• until 15 observations have been collected, the table shows data-collection progress instead of a percentage

Efficiency since Start
Shows ER and its classification:
• directional when ER is at or above the threshold
• moderate in the intermediate zone
• consolidation when ER is at or below the lower level
• on a direction-change bar the table shows "new trend", since the new trend has no movement history yet

Band Multiplier
Shows the ATR multiplier used to calculate the new value of the active band, together with its state:
• standard when the multiplier stays close to the base
• tightened when adaptation has already narrowed the band
• minimum when the Minimum Multiplier has been reached

This is the calculation multiplier. The line's actual distance from price may be smaller because the band never moves backward.

Stop
Shows the level of the active band and its distance from the closing price, both as a percentage of price and as a multiple of ATR.

TP/SL
After a new signal, the optional module draws Entry, Stop Loss and up to three Take Profit levels.
• Entry is the closing price of the signal bar
• Stop Loss can be calculated in two ways:
  • ATR-based: the SL distance is ATR times the SL ATR Multiplier
  • percentage-based: the SL distance is a set percent of Entry
• the ATR used for TP/SL has its own period and does not have to match the band ATR
• Take Profit levels are derived from the distance between Entry and SL, using the chosen risk-to-reward ratios for TP1, TP2 and TP3
• the direction depends on whether the signal is a Buy or a Sell
• a new signal removes the previous set of levels and creates a new one
• levels are extended onto subsequent bars until the Stop Loss or the farthest displayed Take Profit is hit, or until the next signal appears
• SL and TP hits are evaluated using the bar's high and low, not the close alone

█ FEATURES
• Adaptive Supertrend based on the age of the current adaptive trend
• Duration history built from a classic reference Supertrend
• Separate statistics for Uptrends and Downtrends
• Exponential weighting of more recent completed trends
• Configurable Half-Life
• Smoothed measure of historical trend continuation
• Fixed threshold of 15 observations before adaptation starts
• Ongoing reference trend included as a censored observation when it has the same direction and is older than the adaptive trend
• Efficiency Ratio measured from the start of the current trend
• Optional protection of strong, efficient trends
• Configurable Efficiency Threshold with full tightening 0.25 below the threshold
• Base Multiplier as the base band width
• Tightening Strength as the strength of adaptation
• Minimum Multiplier as the lower limit of tightening
• Classic Supertrend construction based on ATR and the bar midpoint
• Optional classic Reference Supertrend
• Buy and Sell signals on direction changes
• Optional bar coloring
• Configurable Uptrend and Downtrend colors
• Configurable line transparency
• Optional gradient between the band and the bar midpoint
• Optional Buy/Sell labels
• Diagnostic table for the current trend
• Trend age compared with the unweighted historical median
• Historical continuation readout
• ER and move-state readout
• Current band multiplier readout
• Stop level and its distance from price
• Configurable table position and size
• Configurable table background and text colors
• Optional Entry, SL, TP1, TP2 and TP3 levels
• Stop Loss based on ATR or on a percentage of Entry
• Independent ATR period for the TP/SL module
• Independent Risk:Reward for TP1–TP3
• Individual toggles for SL, TP1, TP2 and TP3
• Risk and Reward zone visualization
• Automatic extension of TP/SL levels
• Levels end at SL, the farthest TP or a new signal
• Hidden Buy/Sell outputs for external backtesting
• Alerts for Buy and Sell signals

█ APPLICATIONS
Trend following
The indicator can be used as a dynamic trend line and protective level. Entries are best considered in line with the current band direction, not against it.

Assessing trend maturity
Age, S and the historical median help distinguish a young trend from one that has already lasted a long time relative to history. A long age alone does not automatically mean weakness, but it shows that the typical duration of similar moves is running out.

Assessing move quality
ER separates the length of a trend from the quality of its path. A long trend with high ER can still keep a wide band. A long trend full of pullbacks and with low ER can be tightened more strongly.

Comparison with the classic Supertrend
The Reference ST shows how far the adaptive version deviates from a fixed multiplier. This makes it easier to judge whether a tighter band comes from age, from a drop in efficiency, or from both.

How to use it
Age Adaptive Supertrend is best treated as a tool for analyzing trend structure and dynamics rather than as a standalone entry instruction. Before acting on a signal, consider the broader market structure, support and resistance levels, momentum and higher-timeframe context.

█ NOTES
• Buy/Sell signals are generated when the adaptive trend changes direction
• on a real-time bar a signal may appear and disappear before the bar closes
• once the bar has closed, the signal is final
• for alerts, the "Once Per Bar Close" frequency is recommended
• band adaptation starts only after 15 historical reference trends have been collected in a given direction
• duration statistics are kept separately for uptrends and downtrends and come from the reference Supertrend, not from the adaptive band
• the line's current distance from price may be smaller than the current ATR multiplier alone would suggest, because the band never moves backward
• the TP/SL module is intended for visual planning of the Risk:Reward structure
• it does not assess signal quality
• levels end when the high or low hits the SL or the farthest displayed TP, or when a new signal appears
• the Stop Loss ends the levels even when its line is hidden
• this indicator does not replace independent market analysis or risk management

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Age Adaptive Supertrend", overlay = true, max_labels_count = 500, max_lines_count = 500)

// Inputs

const string G_BAND  = "Band"
const string G_ADPT  = "Adaptation"
const string G_LOOK  = "Style"
const string G_TPSL  = "TP/SL"
const string G_TPSLD = "TP/SL – Display"
const string G_TBL   = "Table"

atrLen    = input.int(10, "ATR Length", minval = 1, group = G_BAND,
     tooltip = "Averaging period of the Average True Range. Higher values smooth the band at the cost of slower reaction to changes in volatility.")
baseMult  = input.float(3.0, "Base Multiplier", minval = 0.1, step = 0.1, group = G_BAND,
     tooltip = "Distance of the band from hl2 in ATR multiples at the start of a trend (equivalent to the multiplier of a classic Supertrend). The same multiplier defines the reference Supertrend used to measure trend durations.")
kExp      = input.float(1.0, "Tightening Strength", minval = 0.0, step = 0.1, group = G_BAND,
     tooltip = "How strongly the band tightens as the trend ages relative to the historical distribution of trend durations. 0 – no tightening (classic Supertrend), 1 – standard, above 1 – aggressive tightening.")
floorMult = input.float(1.2, "Minimum Multiplier", minval = 0.1, step = 0.1, group = G_BAND,
     tooltip = "Lower limit of the ATR multiplier. Prevents the stop level from moving too close to price and closing positions prematurely due to market noise.")

halfLife  = input.float(40.0, "Half-Life (in trends)", minval = 1.0, step = 1.0, group = G_ADPT,
     tooltip = "Half-life of the weights in the trend-duration statistics, expressed in number of trends: a trend this many trends ago has a weight of 0.5. Lower values adapt faster to regime changes at the cost of less stable estimates.")
useEr     = input.bool(true, "Protect Efficient Trends", group = G_ADPT,
     tooltip = "Band tightening depends on the efficiency ratio (ER) of the current trend. With a high ER the band keeps its standard width, allowing positions to be held through strong directional moves; as ER falls, tightening increases to its full value. When disabled, tightening depends on trend age only.")
erHi      = input.float(0.40, "Efficiency Threshold", minval = 0.25, maxval = 1.0, step = 0.05, group = G_ADPT,
     tooltip = "Efficiency ratio measured from the start of the current trend on closing prices: price displacement in the trend direction divided by the sum of all bar-to-bar moves (0–1). Above the threshold there is no tightening; at a value 0.25 lower tightening is full; in between it is linear. ER = 1 means a one-way move without pullbacks; ER near 0 means consolidation or a move against the trend. ER is naturally high in young trends and naturally lower in long ones.")

upColor    = input.color(color.rgb(6, 162, 47),  "Up Color", group = G_LOOK, inline = "col")
downColor  = input.color(color.rgb(207, 23, 23), "Down",     group = G_LOOK, inline = "col",
     tooltip = "Colors of the line, gradient, bars and labels for uptrends and downtrends.")
lineTransp = input.int(40, "Line Transparency", minval = 0, maxval = 100, group = G_LOOK,
     tooltip = "0 – fully opaque, 100 – line hidden.")
fillTransp = input.int(80, "Gradient Transparency", minval = 0, maxval = 100, group = G_LOOK,
     tooltip = "Transparency of the fill next to the trend line. Toward price the fill fades by an additional 20 points. A value of 100 disables the gradient.")
colorBars  = input.bool(true, "Color Bars", group = G_LOOK,
     tooltip = "Colors bars according to the direction of the current trend.")
showSig    = input.bool(true, "Buy/Sell Labels", group = G_LOOK,
     tooltip = "Shows labels on bars where the trend direction changes. On the live bar a signal may appear and disappear before the bar closes; signals are final once the bar has closed.")
showRef    = input.bool(false, "Reference ST", group = G_LOOK, inline = "ref")
refColor   = input.color(color.new(color.gray, 60), "", group = G_LOOK, inline = "ref",
     tooltip = "Classic Supertrend with the same ATR length and base multiplier, used to build the trend-duration statistics. Shows how far the adaptive band deviates from the classic one.")

showTargets = input.bool(true, "Show TP/SL Levels", group = G_TPSL,
     tooltip = "Draws Entry, Stop Loss and Take Profit levels for the most recent Buy/Sell signal. Levels are extended until the Stop Loss or the farthest displayed Take Profit is reached, or until the next signal.")
useAtrSL    = input.bool(true, "SL = ATR", group = G_TPSL,
     tooltip = "Enabled: Stop Loss distance from entry is based on ATR (SL ATR Multiplier).\nDisabled: fixed percentage distance (SL % from Entry).")
tpAtrPeriod = input.int(14, "ATR Period (TP/SL)", minval = 1, group = G_TPSL,
     tooltip = "ATR period used to calculate the Stop Loss distance and Take Profit levels. Independent of the band ATR length.")
slAtrMult   = input.float(1.5, "SL ATR Multiplier", minval = 0.1, step = 0.1, group = G_TPSL,
     tooltip = "ATR multiplier defining the Stop Loss distance from entry; active when SL = ATR is enabled.")
slPercent   = input.float(1.0, "SL % from Entry", minval = 0.01, step = 0.1, group = G_TPSL,
     tooltip = "Percentage distance of the Stop Loss from entry; used when SL = ATR is disabled.")
rrTP1       = input.float(1.0, "TP1 Risk:Reward", minval = 0.1, step = 0.1, group = G_TPSL,
     tooltip = "Reward-to-risk ratio for TP1. A value of 1.0 places TP1 at a distance equal to the risk (SL) from entry.")
rrTP2       = input.float(2.0, "TP2 Risk:Reward", minval = 0.1, step = 0.1, group = G_TPSL,
     tooltip = "Reward-to-risk ratio for TP2.")
rrTP3       = input.float(3.0, "TP3 Risk:Reward", minval = 0.1, step = 0.1, group = G_TPSL,
     tooltip = "Reward-to-risk ratio for TP3.")

showSlLevel  = input.bool(true, "Show SL",  group = G_TPSLD, tooltip = "Draws the Stop Loss line and label for the active signal.")
showTp1Level = input.bool(true, "Show TP1", group = G_TPSLD, tooltip = "Draws the Take Profit 1 line and label for the active signal.")
showTp2Level = input.bool(true, "Show TP2", group = G_TPSLD, tooltip = "Draws the Take Profit 2 line and label for the active signal.")
showTp3Level = input.bool(true, "Show TP3", group = G_TPSLD, tooltip = "Draws the Take Profit 3 line and label for the active signal.")

showTable  = input.bool(true, "Show Table", group = G_TBL,
     tooltip = "Summary of the current trend: direction, age relative to history, move efficiency since the start of the trend (ER), current band multiplier and stop level. The multiplier sets how far from hl2 a new band level is calculated; the trend line never moves backward, so its actual distance from price (Stop row) may be smaller.")
tablePosIn = input.string("Bottom Right", "Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = G_TBL, tooltip = "Position of the table on the chart.")
tableSizeIn = input.string("Normal", "Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = G_TBL, tooltip = "Text size in the table.")
tblBg      = input.color(#000000, "Background", group = G_TBL, inline = "tbl")
tblText    = input.color(color.white, "Text",   group = G_TBL, inline = "tbl",
     tooltip = "Background and text color of the table. For a light chart theme, a light background with dark text is recommended.")
tblTransp  = input.int(0, "Background Transparency", minval = 0, maxval = 100, group = G_TBL,
     tooltip = "0 – fully opaque background, 100 – background hidden.")

// Internal constants

const int   MAX_HIST    = 300    // maximum number of stored trends per direction
const int   MIN_SAMPLES = 15     // minimum number of historical trends before tightening is applied
const float SMOOTH_H    = 2.0    // smoothing width of the survival function (in bars)
const bool  USE_CENSOR  = true   // include the ongoing trend as a censored observation (Kaplan–Meier)
const bool  SPLIT_DIR   = true   // separate statistics for uptrends and downtrends

refMult = baseMult
erLo    = erHi - 0.25

// Helper functions

// Logistic function.
sig(float x) =>
    1.0 / (1.0 + math.exp(-x))

// Exponentially weighted, smoothed survival function at age t.
// Returns numerator and denominator [Σ w·a, Σ w] so that a censored observation can be added.
survAccum(array<int> durs, array<int> ids, int t, int nowId, float hl, float h) =>
    float num = 0.0
    float den = 0.0
    for [i, dv] in durs
        float w = math.pow(0.5, float(nowId - ids.get(i)) / hl)
        float a = h > 0 ? sig((dv - t - 0.5) / h) / sig((dv - 0.5) / h) : (dv > t ? 1.0 : 0.0)
        num += w * a
        den += w
    [num, den]

// Appends a trend duration to the history while keeping it within the size limit.
pushCapped(array<int> durs, array<int> ids, int v, int id, int cap) =>
    durs.push(v)
    ids.push(id)
    if durs.size() > cap
        durs.shift()
        ids.shift()

tablePosition(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

tableTextSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

// Reference Supertrend: trend-duration history

[refST, refDir] = ta.supertrend(refMult, atrLen)   // refDir < 0 means uptrend

var array<int> durUp = array.new<int>()
var array<int> idsUp = array.new<int>()
var array<int> durDn = array.new<int>()
var array<int> idsDn = array.new<int>()
var int refAge = 0
var int seqId  = 0

bool refFlip = not na(refDir[1]) and refDir != refDir[1]
if refFlip
    seqId += 1
    if refDir[1] < 0
        pushCapped(durUp, idsUp, refAge, seqId, MAX_HIST)
    else
        pushCapped(durDn, idsDn, refAge, seqId, MAX_HIST)
    refAge := 1
else
    refAge += 1

// Adaptive trend state

var int   dir    = 1
var int   age    = 0
var float upBand = na
var float dnBand = na
var float tStart = na
var float tPath  = 0.0

// Directional efficiency ratio since the start of the trend: movement against the trend yields 0.
if na(tStart)
    tStart := close
tPath += math.abs(close - nz(close[1], close))
float er = tPath > 0 ? math.max(0.0, dir * (close - tStart)) / tPath : 1.0

// Trend continuation probability S(t)

[numU, denU] = survAccum(durUp, idsUp, age, seqId + 1, halfLife, SMOOTH_H)
[numD, denD] = survAccum(durDn, idsDn, age, seqId + 1, halfLife, SMOOTH_H)

float num  = SPLIT_DIR ? (dir == 1 ? numU : numD) : numU + numD
float den  = SPLIT_DIR ? (dir == 1 ? denU : denD) : denU + denD
int   nObs = SPLIT_DIR ? (dir == 1 ? durUp.size() : durDn.size()) : durUp.size() + durDn.size()

// The ongoing reference trend is already longer than the current age: add it as a censored observation.
bool refIsUp    = refDir < 0
bool censorFits = not SPLIT_DIR or ((dir == 1) == refIsUp)
if USE_CENSOR and censorFits and refAge > age
    num += 1.0
    den += 1.0

float S = nObs >= MIN_SAMPLES and den > 0 ? num / den : 1.0

// Effective tightening factor and band multiplier.
float g    = useEr ? math.max(0.0, math.min(1.0, (erHi - er) / math.max(erHi - erLo, 1e-6))) : 1.0
float Seff = 1.0 - (1.0 - S) * g
float mult = math.max(floorMult, baseMult * math.pow(Seff, kExp))

// Bands and direction change

// Only the band of the active trend is tightened; the opposite band uses the base multiplier.
float multUp = dir == 1  ? mult : baseMult
float multDn = dir == -1 ? mult : baseMult

float atr   = ta.atr(atrLen)
float atrTP = ta.atr(tpAtrPeriod)
float newUp = hl2 - multUp * atr
float newDn = hl2 + multDn * atr

float prevUp = upBand
float prevDn = dnBand
upBand := na(prevUp) or close[1] < prevUp ? newUp : math.max(newUp, prevUp)
dnBand := na(prevDn) or close[1] > prevDn ? newDn : math.min(newDn, prevDn)

int prevDir = dir
if dir == 1 and close < upBand
    dir := -1
else if dir == -1 and close > dnBand
    dir := 1

bool flipped = dir != prevDir
if flipped
    age    := 1
    tStart := close
    tPath  := 0.0
else
    age += 1

bool buySignal  = flipped and dir == 1
bool sellSignal = flipped and dir == -1

// Visuals

float st       = dir == 1 ? upBand : dnBand
float plotLine = flipped ? na : st

color trendCol = dir == 1 ? upColor : downColor

pLine   = plot(plotLine, "Trend Line", color = color.new(trendCol, lineTransp), linewidth = 2, style = plot.style_linebr)
pCenter = plot(hl2, "hl2", display = display.none)

fill(pLine, pCenter, plotLine, hl2,
     color.new(trendCol, fillTransp),
     color.new(trendCol, math.min(100, fillTransp + 20)),
     title = "Trend Gradient")

plot(showRef ? refST : na, "Reference ST", color = refColor, style = plot.style_linebr)

if showSig and flipped
    label.new(bar_index,
         dir == 1 ? low - atr * 0.5 : high + atr * 0.5,
         dir == 1 ? "Buy" : "Sell",
         color     = color.new(trendCol, 40),
         style     = dir == 1 ? label.style_label_up : label.style_label_down,
         textcolor = color.white,
         size      = size.small)

barcolor(colorBars ? trendCol : na)

// TP/SL: state

var int      tpslDir        = 0
var float    tpslSL         = na
var float    tpslExtreme    = na
var line     tpslEntryLn    = na
var label    tpslEntryLb    = na
var line     tpslSlLn       = na
var label    tpslSlLb       = na
var line     tpslTp1Ln      = na
var label    tpslTp1Lb      = na
var line     tpslTp2Ln      = na
var label    tpslTp2Lb      = na
var line     tpslTp3Ln      = na
var label    tpslTp3Lb      = na
var line     tpslExtLn      = na
var linefill tpslRiskFill   = na
var linefill tpslRewardFill = na
var int      tpslEntryBar   = na

// TP/SL: levels for a new signal

if showTargets and (buySignal or sellSignal)
    bool isBuyTrade = buySignal

    // Remove the levels of the previous signal.
    line.delete(tpslEntryLn)
    label.delete(tpslEntryLb)
    line.delete(tpslSlLn)
    label.delete(tpslSlLb)
    line.delete(tpslTp1Ln)
    label.delete(tpslTp1Lb)
    line.delete(tpslTp2Ln)
    label.delete(tpslTp2Lb)
    line.delete(tpslTp3Ln)
    label.delete(tpslTp3Lb)
    line.delete(tpslExtLn)
    linefill.delete(tpslRiskFill)
    linefill.delete(tpslRewardFill)
    tpslEntryLn    := na
    tpslEntryLb    := na
    tpslSlLn       := na
    tpslSlLb       := na
    tpslTp1Ln      := na
    tpslTp1Lb      := na
    tpslTp2Ln      := na
    tpslTp2Lb      := na
    tpslTp3Ln      := na
    tpslTp3Lb      := na
    tpslExtLn      := na
    tpslRiskFill   := na
    tpslRewardFill := na

    tpslDir      := isBuyTrade ? 1 : -1
    tpslEntryBar := bar_index

    float entryP   = close
    float riskDist = useAtrSL ? atrTP * slAtrMult : entryP * (slPercent / 100.0)

    // Lines and labels: transparency 40; risk and reward zone fills: 80.
    color entryCol    = color.new(isBuyTrade ? upColor : downColor, 40)
    color slCol       = color.new(isBuyTrade ? downColor : upColor, 40)
    color tpCol       = color.new(isBuyTrade ? upColor : downColor, 40)
    color riskFillC   = color.new(isBuyTrade ? downColor : upColor, 80)
    color rewardFillC = color.new(isBuyTrade ? upColor : downColor, 80)

    float slP  = isBuyTrade ? entryP - riskDist : entryP + riskDist
    float tp1P = isBuyTrade ? entryP + riskDist * rrTP1 : entryP - riskDist * rrTP1
    float tp2P = isBuyTrade ? entryP + riskDist * rrTP2 : entryP - riskDist * rrTP2
    float tp3P = isBuyTrade ? entryP + riskDist * rrTP3 : entryP - riskDist * rrTP3

    // The farthest displayed TP ends the drawing of the levels.
    tpslSL      := slP
    tpslExtreme := showTp3Level ? tp3P : showTp2Level ? tp2P : showTp1Level ? tp1P : na

    tpslEntryLn := line.new(bar_index, entryP, bar_index + 1, entryP,
         color = entryCol, width = 2, extend = extend.none)
    tpslEntryLb := label.new(bar_index, entryP,
         (isBuyTrade ? "BUY " : "SELL ") + str.tostring(entryP, format.mintick),
         style = label.style_label_left, color = entryCol,
         textcolor = color.white, size = size.small)

    if showSlLevel
        tpslSlLn := line.new(bar_index, slP, bar_index + 1, slP,
             color = slCol, width = 1, style = line.style_dashed, extend = extend.none)
        tpslSlLb := label.new(bar_index, slP,
             "SL " + str.tostring(slP, format.mintick),
             style = label.style_label_left, color = slCol,
             textcolor = color.white, size = size.small)

    if showTp1Level
        tpslTp1Ln := line.new(bar_index, tp1P, bar_index + 1, tp1P,
             color = tpCol, width = 1, extend = extend.none)
        tpslTp1Lb := label.new(bar_index, tp1P,
             "TP1 " + str.tostring(tp1P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showTp2Level
        tpslTp2Ln := line.new(bar_index, tp2P, bar_index + 1, tp2P,
             color = tpCol, width = 1, extend = extend.none)
        tpslTp2Lb := label.new(bar_index, tp2P,
             "TP2 " + str.tostring(tp2P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showTp3Level
        tpslTp3Ln := line.new(bar_index, tp3P, bar_index + 1, tp3P,
             color = tpCol, width = 1, style = line.style_dotted, extend = extend.none)
        tpslTp3Lb := label.new(bar_index, tp3P,
             "TP3 " + str.tostring(tp3P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showSlLevel
        tpslRiskFill := linefill.new(tpslEntryLn, tpslSlLn, riskFillC)

    // The reward zone extends to the farthest displayed TP.
    float fillExtreme = entryP
    if isBuyTrade
        if showTp1Level
            fillExtreme := math.max(fillExtreme, tp1P)
        if showTp2Level
            fillExtreme := math.max(fillExtreme, tp2P)
        if showTp3Level
            fillExtreme := math.max(fillExtreme, tp3P)
        if fillExtreme > entryP
            tpslExtLn      := line.new(bar_index, fillExtreme, bar_index + 1, fillExtreme, color = na, extend = extend.none)
            tpslRewardFill := linefill.new(tpslEntryLn, tpslExtLn, rewardFillC)
    else
        if showTp1Level
            fillExtreme := math.min(fillExtreme, tp1P)
        if showTp2Level
            fillExtreme := math.min(fillExtreme, tp2P)
        if showTp3Level
            fillExtreme := math.min(fillExtreme, tp3P)
        if fillExtreme < entryP
            tpslExtLn      := line.new(bar_index, fillExtreme, bar_index + 1, fillExtreme, color = na, extend = extend.none)
            tpslRewardFill := linefill.new(tpslEntryLn, tpslExtLn, rewardFillC)

// TP/SL: extending and closing the levels

if tpslDir != 0
    if not na(tpslEntryLb)
        label.set_x(tpslEntryLb, bar_index)
    if not na(tpslSlLb)
        label.set_x(tpslSlLb, bar_index)
    if not na(tpslTp1Lb)
        label.set_x(tpslTp1Lb, bar_index)
    if not na(tpslTp2Lb)
        label.set_x(tpslTp2Lb, bar_index)
    if not na(tpslTp3Lb)
        label.set_x(tpslTp3Lb, bar_index)

    if not na(tpslEntryLn)
        line.set_x2(tpslEntryLn, bar_index + 1)
    if not na(tpslSlLn)
        line.set_x2(tpslSlLn, bar_index + 1)
    if not na(tpslTp1Ln)
        line.set_x2(tpslTp1Ln, bar_index + 1)
    if not na(tpslTp2Ln)
        line.set_x2(tpslTp2Ln, bar_index + 1)
    if not na(tpslTp3Ln)
        line.set_x2(tpslTp3Ln, bar_index + 1)
    if not na(tpslExtLn)
        line.set_x2(tpslExtLn, bar_index + 1)

    bool slHit = tpslDir == 1 ? low <= tpslSL : high >= tpslSL
    bool tpHit = not na(tpslExtreme) and
         (tpslDir == 1 ? high >= tpslExtreme : low <= tpslExtreme)

    // Once SL or the farthest TP is reached, the levels end on the current bar.
    if bar_index > tpslEntryBar and (slHit or tpHit)
        if not na(tpslEntryLn)
            line.set_x2(tpslEntryLn, bar_index)
        if not na(tpslSlLn)
            line.set_x2(tpslSlLn, bar_index)
        if not na(tpslTp1Ln)
            line.set_x2(tpslTp1Ln, bar_index)
        if not na(tpslTp2Ln)
            line.set_x2(tpslTp2Ln, bar_index)
        if not na(tpslTp3Ln)
            line.set_x2(tpslTp3Ln, bar_index)
        if not na(tpslExtLn)
            line.set_x2(tpslExtLn, bar_index)
        tpslDir := 0

// Table

var table tb = table.new(tablePosition(tablePosIn), 2, 6, border_width = 1)
if showTable and barstate.islast
    color  tc = tblText
    string ts = tableTextSize(tableSizeIn)
    tb.set_bgcolor(color.new(tblBg, tblTransp))

    // Trend direction.
    string dirTxt = dir == 1 ? "▲ Uptrend" : "▼ Downtrend"

    // Trend age compared with the median duration of trends in the same direction.
    float  med    = dir == 1 ? durUp.median() : durDn.median()
    string ageTxt = str.tostring(age) + (age == 1 ? " bar" : " bars") + (na(med) ? "" : "  (median " + str.tostring(med, "0") + ")")

    // Weighted share of historical trends that lasted longer than the current one.
    string survTxt = nObs >= MIN_SAMPLES ? str.tostring(S * 100, "0") + "%" : "collecting data (" + str.tostring(nObs) + "/" + str.tostring(MIN_SAMPLES) + ")"

    // Move efficiency since the start of the trend. On a direction-change bar the new trend has no data yet.
    string erState = er >= erHi ? "directional" : er <= erLo ? "consolidation" : "moderate"
    string erTxt   = flipped ? "new trend" : str.tostring(er, "0.00") + "  " + erState

    // Current band multiplier.
    string bandState = mult >= baseMult * 0.97 ? "standard" : mult <= floorMult * 1.001 ? "minimum" : "tightened"
    string bandTxt   = str.tostring(mult, "0.00") + "× ATR  " + bandState

    // Stop level and its actual distance from the closing price.
    float  distPct = close != 0 ? math.abs(close - st) / close * 100 : na
    float  distAtr = atr > 0 ? math.abs(close - st) / atr : na
    string stopTxt = str.tostring(st, format.mintick) + "  (" + str.tostring(distPct, "0.00") + "% · " + str.tostring(distAtr, "0.0") + " ATR)"

    tb.cell(0, 0, "Trend",                 text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(1, 0, dirTxt,                  text_color = trendCol, text_size = ts, text_halign = text.align_left)
    tb.cell(0, 1, "Age",                   text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(1, 1, ageTxt,                  text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(0, 2, "Longer trends in history", text_color = tc,    text_size = ts, text_halign = text.align_left)
    tb.cell(1, 2, survTxt,                 text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(0, 3, "Efficiency since start", text_color = tc,      text_size = ts, text_halign = text.align_left)
    tb.cell(1, 3, erTxt,                   text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(0, 4, "Band multiplier",       text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(1, 4, bandTxt,                 text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(0, 5, "Stop",                  text_color = tc,       text_size = ts, text_halign = text.align_left)
    tb.cell(1, 5, stopTxt,                 text_color = trendCol, text_size = ts, text_halign = text.align_left)

// BACKTESTER OUTPUT PLOTS 
plot(buySignal ? 1 : na, "backtest_buy",  display = display.none)
plot(sellSignal ? 1 : na, "backtest_sell", display = display.none)

// Alerts
alertcondition(buySignal,  "Buy Signal",  "Age Adaptive Supertrend: Buy signal on {{ticker}} ({{interval}}) at {{close}}")
alertcondition(sellSignal, "Sell Signal", "Age Adaptive Supertrend: Sell signal on {{ticker}} ({{interval}}) at {{close}}")
````

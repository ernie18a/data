# Precision Bedrock [MohaveTrader]

- url: https://www.tradingview.com/script/2yXIzaDX-Precision-Bedrock-MohaveTrader/
- type: indicator
- pine_id: PUB;872dfc2339424fdb89d01f9754788ede
- version: 3.0

## Description

Precision Bedrock is an open-source market structure indicator that combines adaptive trend rails, structural equilibrium, rail-sourced support and resistance zones, and contextual reversal warnings into a single framework. Rather than accumulating historical levels, Bedrock continuously maintains the structure that remains relevant to current price action.

━━━━━━━━━━━━━━━━━━━━━━━━━━
WHY BEDROCK IS DIFFERENT
━━━━━━━━━━━━━━━━━━━━━━━━━━

Most support/resistance tools draw a level and leave it there. The market moves; the level does not, and the chart slowly fills with lines that no longer matter.

Bedrock treats market structure as something living. Zones are born from rail extremes and confirmed by price rejection. They move through a defined lifecycle that includes testing, confirmation, merging, role reversal, and eventual retirement as the market evolves. The result is a chart focused on the structural levels that remain relevant as price evolves.

━━━━━━━━━━━━━━━━━━━━━━━━━━
THE RAIL & EQUILIBRIUM ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━

Upper and lower rails track the recent extremes over a lookback that adapts to your chart's timeframe. They define the channel the zones are sourced from and the directional context the reversal logic reads against, running under the hood rather than as a plotted line.

Between the rails sits the equilibrium: a smoothed, adaptive midline that reads where price is balancing within the channel. It is the reference the reversal logic measures turns against — a curl or slope shift in the equilibrium is often where building pressure first shows up.

━━━━━━━━━━━━━━━━━━━━━━━━━━
STRUCTURAL ZONES
━━━━━━━━━━━━━━━━━━━━━━━━━━

Zones are sourced from the rails, not from raw pivots. A rail printing a new extreme arms a candidate; a close-based pullback of a configurable ATR distance away from that extreme commits it into a zone, keeping zones anchored to structure the market actually stepped away from. Each zone is an ATR-width band — the rail extreme is the outer edge, extending inward toward price — so the level has the thickness real reactions occur across.

Every zone moves through a lifecycle:

• Active — a confirmed level, drawn as Support or Resistance.
• Testing — price has entered the band; the label reads Testing until the test resolves.
• Confirmed hold — after a set number of consecutive closes back outside the inner edge, the test counts and the level's respected-touch strength increases.
• Broken — a confirmed close beyond the outer edge, or price walking far past and staying away, retires the level.
• Role reversal — a broken level can flip its role in place (support becomes resistance, or the reverse) a limited number of times, rather than spawning a duplicate.

Overlapping same-side zones collapse into a single structural area, reducing duplicate levels and chart clutter. Distant zones are hidden but retained, reappearing if price returns; a per-side cap and a broken-level fade keep the chart clean. Labels show the role and mid price (for example, "Support 6.04"), and an optional Full Zone History mode lengthens each box back to where the level first formed. All zone logic runs on confirmed bars and draws at the live edge — historical levels do not repaint.

━━━━━━━━━━━━━━━━━━━━━━━━━━
REVERSAL WARNING DOTS
━━━━━━━━━━━━━━━━━━━━━━━━━━

A reversal warning dot marks a bar where pressure is building against the current trend near a rail extreme. It appears only when several conditions align on the same bar: the trend is intact and not already changing, price is on the appropriate side of the equilibrium, price is near the relevant rail, either the equilibrium is turning or the bar itself is a rejection, and a weighted reversal score clears its threshold. A cooldown prevents clusters on the same swing. The score blends multiple structural and momentum components, so no single feature alone fires a dot.

A dot is an early, contextual warning, not a trade signal. It flags that a turn is being pressured; it does not confirm one. Each dot's tooltip prints its reversal score and the rail-break level a close beyond which would confirm the turn.

━━━━━━━━━━━━━━━━━━━━━━━━━━
CANDLE COLORING
━━━━━━━━━━━━━━━━━━━━━━━━━━

Optional candle coloring displays bullish bars in green and bearish bars in red, to keep the chart readable against the zone bands and dots. It is a simple directional recolor and encodes no state. For the cleanest display, hide the chart’s native candle body, border, and wick colors when this option is enabled.

━━━━━━━━━━━━━━━━━━━━━━━━━━
CHOP SUPPRESSION
━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional filter, off by default, suppresses reversal dots when momentum is unusually weak or the momentum state is changing repeatedly. It remains optional because quiet or thin markets can still produce legitimate reversal pressure.

━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━

Bedrock is context and structure for your own methodology, not a signal service:

• Read the zones as a map of where price may react, and plan your own entries, stops, and scale-outs around them.
• Use the rails and equilibrium for directional context as price approaches a zone.
• Treat a reversal warning dot as an early heads-up to tighten attention on an open position — remembering that a dot is a warning, not a confirmed turn.
• Watch how a level's touch history and lifecycle develop to gauge which zones have earned respect on your instrument.

Alert conditions are included for bullish and bearish reversal warnings, carrying the ticker and timeframe.

Bedrock pairs naturally with tools that add a different lens on the same price — volume profile, VWAP, and momentum or market-structure tools. It does not predict prices or guarantee outcomes: its zones and warnings are analytical structures, not recommendations to buy or sell. You remain solely responsible for every trading decision.

━━━━━━━━━━━━━━━━━━━━━━━━━━
CREDITS & LICENSE
━━━━━━━━━━━━━━━━━━━━━━━━━━

Precision Bedrock is released under the Mozilla Public License 2.0.

The adaptive trend rail, equilibrium, and reversal framework is derived from Adaptive Trend Rails by NICK789, used under the MPL 2.0. Original framework © NICK789.

Structural zones, lifecycle management, reversal scoring, candle coloring, and other Bedrock-specific functionality are original work by MohaveTrader. The momentum-state component of the reversal score is adapted from the author's open-source Precision Price Gamma (PGamma).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789
// © MohaveTrader
// Rail, trend, equilibrium and reversal-warning framework by NICK789.
// MohaveTrader modifications: the reversal-pressure score uses a MohaveTrader momentum-state component while retaining NICK789's structural equilibrium turn gate; adaptive rails retained (fixed-length and alternate engine modes removed); optional up/down candle coloring; rail-sourced structural zones with ATR confirmation, merging, testing, role reversal, bypass, relevance filtering and lifecycle management.
//
// v1.1 — July 2026
//
// Zone bypass is now directional: a level is removed only on a confirmed close through its break side, so valid far and uncrossed levels are kept. Max Zones Per Side is now the main density control.
// Relevance Distance default tightened for a cleaner default chart.
// Stack Merge Gap adds an Auto mode that scales the gap to the symbol's ATR percent.
// Added a Zone Pressure layer: interacting-level border intensity tracks directional attack pressure, with a role-colored slope arrow and a faded momentum trail.

//@version=6
indicator("Precision Bedrock [MohaveTrader]", "Bedrock", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 1000)

const string grpMain   = "01. Trend & Reversal"
const string grpVisual = "02. Visuals"

const color WARNING_COLOR = #ffc857

const color C_UP   = color.new(#39FF14, 0)
const color C_DOWN = color.new(#FF1744, 0)

const string widthInput = "Narrow"  // "Narrow" | "Medium" | "Wide"

bool showReversalDots = input.bool(
     true,
     "Show Reversal Warning Dots",
     group = grpMain,
     tooltip = "Shows an early warning when pressure builds against the current trend. A close through the Trend Change level is still required for confirmation."
)

string reversalDotSizeInput = input.string(
     "Tiny",
     "Reversal Dot Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = grpMain
)

bool showPaintbars = input.bool(true, "Color Up/Down Candles", group = grpVisual, tooltip = "Recolors candles by direction using the up/down palette. Disable native candles in chart settings when this is on.")

const int   pgSmooth = 9
const int   pgMomLen = 5
const int   pgGamLen = 3
const float i_bufPct = 5.0

const int   equilibriumLength        = 34
const float equilibriumShift         = 0.65
const float equilibriumBufferPct     = 20.0
const float reversalDotScore         = 58.0
const int   reversalCooldown         = 6
const bool  requireRailZone          = true

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(value, maximum))

f_labelSize(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

int adaptiveBaseLength =
     timeframe.isintraday ?
          timeframe.multiplier < 15 ? 14 :
          timeframe.multiplier < 60 ? 24 :
          34 :
     48

float widthMultiplier = switch widthInput
    "Narrow" => 0.65
    "Medium" => 1.00
    => 1.75

int adaptiveRailLength = math.max(2, int(math.round(adaptiveBaseLength * widthMultiplier)))
int railLength = adaptiveRailLength

float upperRail = ta.highest(high, railLength)
float lowerRail = ta.lowest(low, railLength)

float upperBreakLevel = upperRail[1]
float lowerBreakLevel = lowerRail[1]

int upperOffsetRaw = ta.highestbars(high[1], railLength)
int lowerOffsetRaw = ta.lowestbars(low[1], railLength)

int upperSourceBar = not na(upperOffsetRaw) ? bar_index - (math.abs(upperOffsetRaw) + 1) : na
int lowerSourceBar = not na(lowerOffsetRaw) ? bar_index - (math.abs(lowerOffsetRaw) + 1) : na

bool upperBreak = not na(upperBreakLevel) and ta.crossover(close, upperBreakLevel)
bool lowerBreak = not na(lowerBreakLevel) and ta.crossunder(close, lowerBreakLevel)

var int trend = 0
int previousTrend = nz(trend[1], 0)

if upperBreak
    trend := 1
else if lowerBreak
    trend := -1
else
    trend := previousTrend

bool bullishTrendChange = upperBreak and previousTrend == -1
bool bearishTrendChange = lowerBreak and previousTrend == 1
bool trendChange = bullishTrendChange or bearishTrendChange

float railRange = upperRail - lowerRail
float rawPosition =
     railRange > syminfo.mintick
     ? f_clamp((hlc3 - lowerRail) / railRange, 0.0, 1.0)
     : 0.5

float positionEma = ta.ema(rawPosition, equilibriumLength)
float positionWma = ta.wma(rawPosition, equilibriumLength)
float positionVwmaRaw = ta.vwma(rawPosition, equilibriumLength)
float positionVwma = na(positionVwmaRaw) ? positionWma : positionVwmaRaw
float acceptedPosition = math.avg(positionEma, positionVwma)

float centredPosition = 0.5 + (acceptedPosition - 0.5) * equilibriumShift
float edgeBuffer = equilibriumBufferPct / 100.0
float boundedPosition = f_clamp(centredPosition, edgeBuffer, 1.0 - edgeBuffer)

float equilibrium =
     railRange > syminfo.mintick
     ? lowerRail + railRange * boundedPosition
     : math.avg(upperRail, lowerRail)

bool equilibriumCurlDown = equilibrium < equilibrium[1] and equilibrium[1] <= equilibrium[2]
bool equilibriumCurlUp = equilibrium > equilibrium[1] and equilibrium[1] >= equilibrium[2]

int baselineLength = 50
float candleRange = high - low
float candleBody = math.abs(close - open)
float averageVolume = ta.sma(volume, baselineLength)
float averageRange = ta.sma(candleRange, baselineLength)

float volumeRatio = averageVolume > 0 ? volume / averageVolume : na
float rangeRatio = averageRange > 0 ? candleRange / averageRange : na
float bodyPct = candleRange > 0 ? candleBody / candleRange * 100.0 : 0.0
float closePositionPct = candleRange > 0 ? (close - low) / candleRange * 100.0 : 50.0
float upperWickPct = candleRange > 0 ? (high - math.max(open, close)) / candleRange * 100.0 : 0.0
float lowerWickPct = candleRange > 0 ? (math.min(open, close) - low) / candleRange * 100.0 : 0.0

float channelPositionPct =
     railRange > syminfo.mintick
     ? f_clamp((close - lowerRail) / railRange * 100.0, 0.0, 100.0)
     : 50.0

bool nearUpperRail = channelPositionPct >= 60.0
bool nearLowerRail = channelPositionPct <= 40.0
bool volumeStress = nz(volumeRatio) >= 1.35 and bodyPct < 55.0
bool expandedRange = nz(rangeRatio) >= 1.20

float pgBase = ta.ema(close, pgSmooth)
float pgMomentum = pgBase - pgBase[pgMomLen]
float pgMomSmooth = ta.ema(pgMomentum, pgSmooth)
float pgGamma = pgMomSmooth - pgMomSmooth[pgGamLen]
float pgMomBuf = ta.ema(math.abs(pgMomSmooth), 20) * i_bufPct / 100
float pgGamBuf = ta.ema(math.abs(pgGamma), 20) * i_bufPct / 100
var bool momUpState = false
var bool gamUpState = false
momUpState := momUpState ? pgMomSmooth > -pgMomBuf : pgMomSmooth > pgMomBuf
gamUpState := gamUpState ? pgGamma > -pgGamBuf : pgGamma > pgGamBuf

int pgStateInt = momUpState and gamUpState ? 0 : momUpState and not gamUpState ? 1 : not momUpState and not gamUpState ? 2 : 3

const string grpChop = "Chop Avoidance"
bool  i_useChopFilter    = input.bool(false, "Suppress Dots In Chop", group = grpChop, tooltip = "Off by default. On: suppresses reversal dots when the tape is dead or whipsawing — low momentum-state energy, or the state flipping back and forth rapidly. Small-bodied rejection bars are deliberately still allowed through, so genuine low-energy reversals are not over-filtered.")
const float i_chopMomPct = 35.0
const float i_chopGamPct = 35.0
const int i_chopFlipMax      = 4
const int i_chopFlipLookback = 8

float chopMomAvg    = ta.ema(math.abs(pgMomSmooth), 20)
float chopGamAvg    = ta.ema(math.abs(pgGamma), 20)
bool  chopMomDead   = math.abs(pgMomSmooth) < chopMomAvg * i_chopMomPct / 100
bool  chopGamDead   = math.abs(pgGamma) < chopGamAvg * i_chopGamPct / 100
bool  chopStateFlip = pgStateInt != pgStateInt[1]
float chopFlipCount = math.sum(chopStateFlip ? 1 : 0, i_chopFlipLookback)
bool  chopSuppress  = i_useChopFilter and ((chopMomDead and chopGamDead) or chopFlipCount >= i_chopFlipMax)

float bearishClosePressure = 100.0 - closePositionPct
float bullishClosePressure = closePositionPct
float bearishBodyPressure = close < open ? bodyPct : bodyPct * 0.20
float bullishBodyPressure = close > open ? bodyPct : bodyPct * 0.20

float participationScore =
     na(volumeRatio)
     ? 50.0
     : volumeStress or expandedRange
       ? f_clamp(volumeRatio / 1.8 * 100.0, 0.0, 100.0)
       : f_clamp(volumeRatio / 2.2 * 100.0, 20.0, 80.0)

float equilibriumSlopePct =
     railRange > syminfo.mintick
     ? (equilibrium - equilibrium[1]) / railRange * 100.0
     : 0.0

float bearishGammaScore =
     momUpState and not gamUpState ? 100.0 :
     not momUpState and not gamUpState ? 70.0 :
     momUpState and gamUpState ? 25.0 :
     45.0

float bullishGammaScore =
     not momUpState and gamUpState ? 100.0 :
     momUpState and gamUpState ? 70.0 :
     not momUpState and not gamUpState ? 25.0 :
     45.0

float bearishRailScore = f_clamp((channelPositionPct - 45.0) / 55.0 * 100.0, 0.0, 100.0)
float bullishRailScore = f_clamp((55.0 - channelPositionPct) / 55.0 * 100.0, 0.0, 100.0)

float bearishReversalScore =
     bearishClosePressure * 0.20 +
     upperWickPct * 0.22 +
     bearishBodyPressure * 0.15 +
     participationScore * 0.13 +
     bearishGammaScore * 0.18 +
     bearishRailScore * 0.12

float bullishReversalScore =
     bullishClosePressure * 0.20 +
     lowerWickPct * 0.22 +
     bullishBodyPressure * 0.15 +
     participationScore * 0.13 +
     bullishGammaScore * 0.18 +
     bullishRailScore * 0.12

bool bearishZoneOK = not requireRailZone or nearUpperRail
bool bullishZoneOK = not requireRailZone or nearLowerRail

bool bearishRejection =
     upperWickPct >= 25.0 or
     (close < open and bodyPct >= 35.0) or
     closePositionPct <= 42.0

bool bullishRejection =
     lowerWickPct >= 25.0 or
     (close > open and bodyPct >= 35.0) or
     closePositionPct >= 58.0

bool bearishMomentumTurn = equilibriumCurlDown or equilibriumSlopePct <= 0.05
bool bullishMomentumTurn = equilibriumCurlUp or equilibriumSlopePct >= -0.05

bool bearishWarningRaw =
     trend == 1 and
     not trendChange and
     close >= equilibrium and
     bearishZoneOK and
     (bearishMomentumTurn or bearishRejection) and
     bearishReversalScore >= reversalDotScore

bool bullishWarningRaw =
     trend == -1 and
     not trendChange and
     close <= equilibrium and
     bullishZoneOK and
     (bullishMomentumTurn or bullishRejection) and
     bullishReversalScore >= reversalDotScore

var int lastWarningBar = na
bool warningCooldownReady = na(lastWarningBar) or bar_index - lastWarningBar >= reversalCooldown
bool bearishWarning = showReversalDots and warningCooldownReady and bearishWarningRaw and not chopSuppress
bool bullishWarning = showReversalDots and warningCooldownReady and bullishWarningRaw and not chopSuppress

reversalDotSize = f_labelSize(reversalDotSizeInput)

if bearishWarning
    label.new(
         bar_index,
         high,
         "●",
         style = label.style_label_down,
         color = color.new(color.black, 100),
         textcolor = WARNING_COLOR,
         size = reversalDotSize,
         tooltip = "Bearish reversal pressure\nScore: " + str.tostring(bearishReversalScore, "#") + "/100\nTrend Change level: " + str.tostring(lowerBreakLevel, format.mintick)
    )
    lastWarningBar := bar_index

if bullishWarning
    label.new(
         bar_index,
         low,
         "●",
         style = label.style_label_up,
         color = color.new(color.black, 100),
         textcolor = WARNING_COLOR,
         size = reversalDotSize,
         tooltip = "Bullish reversal pressure\nScore: " + str.tostring(bullishReversalScore, "#") + "/100\nTrend Change level: " + str.tostring(upperBreakLevel, format.mintick)
    )
    lastWarningBar := bar_index

color paintColor = showPaintbars ? (close >= open ? C_UP : C_DOWN) : na
plotcandle(open, high, low, close, "Candles", color = paintColor, wickcolor = paintColor, bordercolor = paintColor)


alertcondition(bearishWarning, "Bearish Reversal Warning", "Bearish reversal pressure building on {{ticker}} {{interval}}.")
alertcondition(bullishWarning, "Bullish Reversal Warning", "Bullish reversal pressure building on {{ticker}} {{interval}}.")
const string grpZone     = "03. Structural Zones"
const string grpZoneLife = "04. Zone Lifecycle"
const string grpZoneVis  = "05. Zone Style"

bool  i_showZones       = input.bool(true, "Show Structural Zones", group = grpZone)
float i_seedPullbackATR = input.float(0.50, "Zone Confirmation Pullback (x ATR)", minval = 0.10, maxval = 3.0, step = 0.05, group = grpZone, tooltip = "Price must pull back this far from a rail extreme, close-based, before a zone commits. Lower = more zones, higher = stronger rejection required.")
float i_zoneWidthATR    = input.float(0.35, "Zone Width (x ATR, inward)", minval = 0.05, maxval = 3.0, step = 0.05, group = grpZone, tooltip = "Full inward thickness of the band. The rail extreme is the outer edge; the band extends inward toward price by this amount.")
const int i_zoneAtrLen = 14
const float i_mergeATR = 0.50
int   i_maxZonesPerSide = input.int(5, "Max Zones Per Side", minval = 1, maxval = 40, group = grpZone)
string i_stackMode      = input.string("Auto", "Stack Merge Mode", options = ["Auto", "Manual"], group = grpZone, tooltip = "Auto scales the merge gap to the symbol's ATR percent of price, so noisier symbols merge more. Manual uses the fixed gap below.")
float i_stackGapATR     = input.float(0.10, "Stack Merge Gap (x ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = grpZone, tooltip = "Manual mode gap. Two same-side zones whose bands overlap or sit within this gap collapse into one. The more-tested level survives and keeps its outer edge. 0 = only true overlap merges.")

float i_relevanceMult = input.float(5.0, "Relevance Distance (x ATR)", minval = 1.0, maxval = 40.0, step = 0.5, group = grpZoneLife, tooltip = "Zones further than this from price are hidden but kept in storage. Chart ATR.")
float i_breakawayMult = input.float(1.0, "Breakaway Distance (x ATR)", minval = 0.25, maxval = 5.0, step = 0.25, group = grpZoneLife, tooltip = "A confirmed close beyond a zone outer edge by this much marks it broken.")
int   i_holdConfirm   = input.int(2, "Confirmed-Hold Bars", minval = 1, maxval = 5, group = grpZoneLife, tooltip = "Consecutive closes back outside a zone's inward edge required before a test counts as a confirmed hold and raises the touch count. TESTING still shows immediately on entry. 1 is faster but easier to fake; 3 tends to feel late on a 5m chart.")
const bool i_flipZones = true
const int  i_maxFlips  = 2
float i_bypassMult    = input.float(4.0, "Bypass Distance (x ATR)", minval = 2.0, maxval = 12.0, step = 0.5, group = grpZoneLife, tooltip = "If price closes this far PAST a zone — above a resistance or below a support — for the bypass bar count, the zone is marked broken as walked-through. Distance from the far side only, so a zone price never reached is never bypassed.")
int   i_bypassBars    = input.int(5, "Bypass Bars", minval = 2, maxval = 40, group = grpZoneLife)
const int i_maxZoneAge = 0
const int i_brokenFade = 3

int   i_zoneExt       = input.int(10, "Zone Extension (bars)", minval = 0, maxval = 200, group = grpZoneVis)
int   i_labelOffset   = input.int(8, "Label Right Offset (bars)", minval = 0, maxval = 80, group = grpZoneVis, tooltip = "How far right of the zone box the text sits. Increase to slide the labels clear of other indicators' tags (e.g. GammaRun's target / entry / trail labels).")
int   i_arrowGap      = input.int(4, "Arrow Gap (bars)", minval = 0, maxval = 60, group = grpZoneVis, tooltip = "Bars right of the zone box where the arrow sits, between the box and its label. Raise to move it toward the label, lower toward the box.")
int i_zoneMaxBack = timeframe.isintraday ? (timeframe.multiplier <= 15 ? 1000 : 750) : timeframe.isdaily ? 750 : timeframe.isweekly ? 520 : 240
bool  i_zoneLabels    = input.bool(true, "Show Zone Labels", group = grpZoneVis)
bool  i_showFullHistory = input.bool(true, "Full Zone History", group = grpZoneVis, tooltip = "Off: each zone box starts at its most recent confirmation (compact). On: the box extends back to where the level first formed, so its length reflects how long the level has been in play. Lifecycle, age and relevance behave the same either way.")
color i_resColor      = input.color(#f6465d, "Resistance", group = grpZoneVis, inline = "z1")
color i_supColor      = input.color(#26e2a8, "Support", group = grpZoneVis, inline = "z1")
color i_testColor     = input.color(#ffd93d, "Testing", group = grpZoneVis, inline = "z2")
color i_brokenColor   = input.color(#7f8c8d, "Broken", group = grpZoneVis, inline = "z2")

float chartAtr = ta.atr(i_zoneAtrLen)

const string grpPress = "06. Zone Pressure"
bool  i_showPressure  = input.bool(true, "Show Zone Pressure", group = grpPress, tooltip = "Border brightness and an up/down arrow track directional pressure on a zone while price is interacting with it: buyers on resistance, sellers on support.")
int   i_pressLen      = input.int(10, "Pressure Window (bars)", minval = 3, maxval = 100, group = grpPress, tooltip = "Rolling window for the volume-weighted directional pressure.")
float i_pressProxATR  = input.float(0.35, "Pressure Proximity (x ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = grpPress, tooltip = "Pressure is read only while price is within the zone band plus this buffer. Chart ATR.")
int   i_pressSlopeLB  = input.int(3, "Pressure Slope Lookback (bars)", minval = 1, maxval = 20, group = grpPress, tooltip = "Bars back used to gauge whether pressure is building or fading.")
float i_pressDeadband = input.float(0.04, "Pressure Slope Deadband", minval = 0.0, maxval = 0.5, step = 0.01, group = grpPress, tooltip = "Pressure slope must exceed this before an arrow shows, so a flat read does not flicker.")
float i_pressGain     = input.float(1.8, "Pressure Visual Gain", minval = 0.5, maxval = 4.0, step = 0.1, group = grpPress, tooltip = "Display only. Scales how strongly the border responds to pressure. Does not affect the signal.")
bool  i_showTrail     = input.bool(true, "Keep Momentum Trail", group = grpPress, tooltip = "Keeps a faded arrow on a zone after price leaves, marking the prior interaction. The border returns to normal; only the arrow stays.")
float i_trailThresh   = input.float(0.25, "Trail Attack Threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = grpPress, tooltip = "Minimum pressure a zone must reach before it keeps a trail arrow. Higher keeps fewer.")
string i_arrowMode    = input.string("Both", "Arrow Bias", options = ["Both", "Bull", "Bear", "None"], group = grpPress, tooltip = "Which arrows to show. Both = buyers on resistance (green) and sellers on support (red). Bull = buyers only. Bear = sellers only. None = no arrows.")
const int i_trailFade = 55

float prRange = high - low
float prRangePressure = prRange > 0 ? ((close - low) - (high - close)) / prRange : 0.0
float prTr = ta.tr(true)
float prProgress = prTr > 0 and not na(close[1]) ? f_clamp((close - close[1]) / prTr, -1.0, 1.0) : 0.0
bool  prAgree = (prRangePressure > 0 and prProgress > 0) or (prRangePressure < 0 and prProgress < 0)
float prDirBar = prAgree ? (prRangePressure + prProgress) / 2.0 : 0.0
float prVolSum = math.sum(volume, i_pressLen)
float prNet = prVolSum > 0 ? math.sum(prDirBar * volume, i_pressLen) / prVolSum : 0.0
float prSmooth = ta.ema(prNet, 3)

type SRZone
    float  anchor
    float  top
    float  bottom
    bool   isRes
    int    firstSeen
    int    lastConfirmed
    int    touches
    int    flips
    string state
    int    brokenBar
    int    farBars
    int    holdBars
    box    bx
    line   ln
    label  lb
    label  tri
    float  peakAttack
    int    trailDir
    int    trailSide
    bool   wasInteracting

var array<SRZone> zones = array.new<SRZone>()

var float pendHi    = na
var int   pendHiBar = na
var bool  pendHiArm = false
var float pendLo    = na
var int   pendLoBar = na
var bool  pendLoArm = false

method scrubZone(SRZone z) =>
    box.delete(z.bx)
    line.delete(z.ln)
    label.delete(z.lb)
    label.delete(z.tri)

if i_showZones and barstate.isconfirmed and not na(chartAtr) and chartAtr > 0
    float zw    = chartAtr * i_zoneWidthATR
    float brkD  = chartAtr * i_breakawayMult
    float bypD  = chartAtr * i_bypassMult
    float seedD = chartAtr * i_seedPullbackATR

    bool railHiUp = not na(upperRail) and (na(pendHi) or na(upperRail[1]) or upperRail > upperRail[1])
    bool railLoDn = not na(lowerRail) and (na(pendLo) or na(lowerRail[1]) or lowerRail < lowerRail[1])
    if railHiUp
        pendHi := upperRail
        pendHiBar := na(upperSourceBar) ? bar_index : upperSourceBar
        pendHiArm := true
    if railLoDn
        pendLo := lowerRail
        pendLoBar := na(lowerSourceBar) ? bar_index : lowerSourceBar
        pendLoArm := true

    for pass = 0 to 1
        bool isRes = pass == 0
        bool doSeed = isRes ? (pendHiArm and not na(pendHi) and (pendHi - close) >= seedD) : (pendLoArm and not na(pendLo) and (close - pendLo) >= seedD)
        if doSeed
            float px = isRes ? pendHi : pendLo
            int   bb = isRes ? pendHiBar : pendLoBar
            float mergeD = chartAtr * i_mergeATR
            int hit = -1
            if zones.size() > 0
                for k = 0 to zones.size() - 1
                    SRZone z = zones.get(k)
                    if z.isRes == isRes and z.state != "BROKEN" and math.abs(z.anchor - px) <= mergeD
                        hit := k
            if hit >= 0
                SRZone z = zones.get(hit)
                z.touches += 1
                z.firstSeen := math.min(z.firstSeen, bb)
                z.lastConfirmed := math.max(z.lastConfirmed, bb)
                if isRes and px > z.anchor
                    z.anchor := px
                    z.top := px
                    z.bottom := px - zw
                if not isRes and px < z.anchor
                    z.anchor := px
                    z.bottom := px
                    z.top := px + zw
            else
                SRZone z = SRZone.new()
                z.anchor := px
                z.isRes := isRes
                z.top := isRes ? px : px + zw
                z.bottom := isRes ? px - zw : px
                z.firstSeen := bb
                z.lastConfirmed := bb
                z.touches := 1
                z.flips := 0
                z.state := "ACTIVE"
                z.brokenBar := na
                z.farBars := 0
                z.holdBars := 0
                z.peakAttack := 0.0
                z.trailDir := 0
                z.trailSide := 0
                z.wasInteracting := false
                zones.push(z)
            if isRes
                pendHiArm := false
            else
                pendLoArm := false

    if zones.size() > 1
        float atrPctB   = close > 0 ? chartAtr / close * 100.0 : 0.0
        float autoMult  = atrPctB >= 6.0 ? 0.35 : atrPctB >= 3.0 ? 0.25 : atrPctB >= 1.5 ? 0.15 : 0.10
        float mergeMult = i_stackMode == "Auto" ? math.min(autoMult, 0.35) : i_stackGapATR
        float stackGap  = chartAtr * mergeMult
        for a = zones.size() - 1 to 1
            SRZone za = zones.get(a)
            if za.state != "BROKEN"
                for b = a - 1 to 0
                    SRZone zb = zones.get(b)
                    if zb.state != "BROKEN" and zb.isRes == za.isRes and (za.bottom - stackGap) <= zb.top and (zb.bottom - stackGap) <= za.top
                        bool keepA = za.touches > zb.touches or (za.touches == zb.touches and (za.isRes ? za.anchor >= zb.anchor : za.anchor <= zb.anchor))
                        SRZone keep = keepA ? za : zb
                        SRZone drop = keepA ? zb : za
                        keep.touches += drop.touches
                        keep.flips := math.max(keep.flips, drop.flips)
                        keep.firstSeen := math.min(keep.firstSeen, drop.firstSeen)
                        keep.lastConfirmed := math.max(keep.lastConfirmed, drop.lastConfirmed)
                        if nz(drop.peakAttack) > nz(keep.peakAttack)
                            keep.peakAttack := drop.peakAttack
                            keep.trailDir := drop.trailDir
                            keep.trailSide := drop.trailSide
                        drop.scrubZone()
                        zones.remove(keepA ? b : a)
                        break

    if zones.size() > 0
        for k = zones.size() - 1 to 0
            SRZone z = zones.get(k)
            if z.state != "BROKEN"
                bool brokeOut = z.isRes ? close > z.top + brkD : close < z.bottom - brkD
                if brokeOut
                    if i_flipZones and z.flips < i_maxFlips
                        z.isRes := not z.isRes
                        z.flips += 1
                        z.state := "ACTIVE"
                        z.touches := math.max(1, z.touches)
                        z.farBars := 0
                        z.holdBars := 0
                    else
                        z.state := "BROKEN"
                        z.brokenBar := bar_index
                else
                    bool entering = z.isRes ? high >= z.bottom : low <= z.top
                    if z.state == "ACTIVE" and entering
                        z.state := "TESTING"
                        z.holdBars := 0
                    if z.state == "TESTING"
                        bool respected = z.isRes ? close < z.bottom : close > z.top
                        z.holdBars := respected ? z.holdBars + 1 : 0
                        if z.holdBars >= i_holdConfirm
                            z.state := "ACTIVE"
                            z.touches += 1
                            z.holdBars := 0
                            z.lastConfirmed := bar_index
                    bool bypassed = z.isRes ? close > z.top + bypD : close < z.bottom - bypD
                    z.farBars := bypassed ? z.farBars + 1 : 0
                    if z.farBars >= i_bypassBars
                        z.state := "BROKEN"
                        z.brokenBar := bar_index

    if zones.size() > 0
        for k = zones.size() - 1 to 0
            SRZone z = zones.get(k)
            bool aged  = i_maxZoneAge > 0 and z.state != "TESTING" and bar_index - z.lastConfirmed > i_maxZoneAge
            bool faded = z.state == "BROKEN" and not na(z.brokenBar) and bar_index - z.brokenBar > i_brokenFade
            if aged or faded
                z.scrubZone()
                zones.remove(k)

    int nR = 0
    int nS = 0
    if zones.size() > 0
        for k = zones.size() - 1 to 0
            SRZone z = zones.get(k)
            if z.state != "BROKEN"
                if z.isRes
                    nR += 1
                    if nR > i_maxZonesPerSide
                        z.scrubZone()
                        zones.remove(k)
                else
                    nS += 1
                    if nS > i_maxZonesPerSide
                        z.scrubZone()
                        zones.remove(k)

    if i_showPressure and i_showTrail and zones.size() > 0
        float trProx = chartAtr * i_pressProxATR
        for k = 0 to zones.size() - 1
            SRZone z = zones.get(k)
            if z.state != "BROKEN"
                float an = z.isRes ? math.max(prSmooth, 0.0) : math.max(-prSmooth, 0.0)
                float ap = z.isRes ? math.max(prSmooth[i_pressSlopeLB], 0.0) : math.max(-prSmooth[i_pressSlopeLB], 0.0)
                bool interactingNow = high >= z.bottom - trProx and low <= z.top + trProx
                if interactingNow and not z.wasInteracting
                    z.peakAttack := 0.0
                    z.trailDir := 0
                    z.trailSide := 0
                if interactingNow
                    z.peakAttack := math.max(nz(z.peakAttack), an)
                    float sl = an - ap
                    if sl > i_pressDeadband
                        z.trailDir := 1
                        z.trailSide := z.isRes ? 1 : -1
                    else if sl < -i_pressDeadband
                        z.trailDir := -1
                        z.trailSide := z.isRes ? 1 : -1
                z.wasInteracting := interactingNow

if i_showZones and barstate.islast and not na(chartAtr)
    float relD = chartAtr * i_relevanceMult
    if zones.size() > 0
        for k = 0 to zones.size() - 1
            SRZone z = zones.get(k)
            z.scrubZone()
            bool pertinent = math.abs(close - z.anchor) <= relD
            if pertinent
                int origin = i_showFullHistory ? z.firstSeen : z.lastConfirmed
                int drawStart = int(math.max(origin, bar_index - i_zoneMaxBack))
                color c = z.state == "BROKEN" ? i_brokenColor : z.state == "TESTING" ? i_testColor : z.isRes ? i_resColor : i_supColor
                if z.state == "BROKEN"
                    z.ln := line.new(drawStart, z.anchor, bar_index + i_zoneExt, z.anchor, xloc = xloc.bar_index, color = color.new(c, 45), width = 1)
                else
                    float prProx = chartAtr * i_pressProxATR
                    bool zInteract = i_showPressure and high >= z.bottom - prProx and low <= z.top + prProx
                    float attackNow = z.isRes ? math.max(prSmooth, 0.0) : math.max(-prSmooth, 0.0)
                    float attackPrev = z.isRes ? math.max(prSmooth[i_pressSlopeLB], 0.0) : math.max(-prSmooth[i_pressSlopeLB], 0.0)
                    float attackLvl = zInteract ? attackNow : 0.0
                    float attackViz = f_clamp(attackLvl * i_pressGain, 0.0, 1.0)
                    int bTransp = int(f_clamp(45.0 - attackViz * 40.0, 5.0, 45.0))
                    int bWidth = 1 + int(math.round(attackViz * 2.0))
                    int bgTransp = int(f_clamp(85.0 - attackViz * 18.0, 67.0, 85.0))
                    z.bx := box.new(drawStart, z.top, bar_index + i_zoneExt, z.bottom, xloc = xloc.bar_index, border_color = color.new(c, bTransp), border_width = bWidth, bgcolor = color.new(c, bgTransp))
                    if i_zoneLabels
                        float mid = math.avg(z.top, z.bottom)
                        string roleTxt = z.state == "TESTING" ? "Testing" : z.isRes ? "Resistance" : "Support"
                        z.lb := label.new(bar_index + i_zoneExt + i_labelOffset, mid, roleTxt + " " + str.tostring(mid, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = c, size = size.normal)
                        float aSlope = attackNow - attackPrev
                        bool liveUp = zInteract and aSlope > i_pressDeadband
                        bool liveDn = zInteract and aSlope < -i_pressDeadband
                        bool liveOK = i_arrowMode == "Both" or (i_arrowMode == "Bull" and z.isRes) or (i_arrowMode == "Bear" and not z.isRes)
                        bool trailOK = i_arrowMode == "Both" or (i_arrowMode == "Bull" and z.trailSide > 0) or (i_arrowMode == "Bear" and z.trailSide < 0)
                        bool showLive = (liveUp or liveDn) and liveOK
                        bool showTrail = not showLive and i_showTrail and trailOK and nz(z.peakAttack) >= i_trailThresh and nz(z.trailDir) != 0
                        if showLive
                            color triCol = z.isRes ? C_UP : C_DOWN
                            z.tri := label.new(bar_index + i_zoneExt + i_arrowGap, mid, (liveUp ? "▲" : "▼"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = triCol, size = size.normal)
                        else if showTrail
                            color trailCol = color.new(z.trailSide > 0 ? C_UP : C_DOWN, i_trailFade)
                            z.tri := label.new(bar_index + i_zoneExt + i_arrowGap, mid, (z.trailDir > 0 ? "▲" : "▼"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = trailCol, size = size.normal)

// HOW TO USE BEDROCK
//
// Why some zones sit far from price.
// A zone is only removed when price closes through it the wrong way: up through a resistance, or down through a support. A level that price simply moves away from is kept, because it was never actually broken. That is why an old support well below, or an old resistance well above, can stay on the chart. To carry fewer zones overall, lower Max Zones Per Side. To hide the ones far from current price without deleting them, lower Relevance Distance; widen it to bring them back.
//
// The arrows.
// An arrow appears on the zone price is working, and only while price is near it. Green means buyers are pressing a resistance; red means sellers are pressing a support. An up arrow means that pressure is building, a down arrow means it is fading, and the zone border brightens as the pressure grows. A faded arrow left behind marks where pressure last showed, so you can see where a move started even after price has moved on. The arrows describe pressure. They are not buy or sell signals.
````

<!-- tradingview-pine-id: PUB;a33c28ad4f944b65b886c561c6a86c9c -->
<!-- tradingviewscripts-format: 1 -->
# Oliver Velez Campaign Engine v1.4

Source: https://www.tradingview.com/script/kDZGROce-Oliver-Velez-Campaign-Engine-v1-4/

## Description

This Indicator's goal is to visually Identify a trending market and also to signal Shifts.

---

## Source Code

````pine
//@version=6
indicator("Oliver Velez Campaign Engine v1.4", shorttitle="OV-C14", overlay=true, format=format.price, max_labels_count=300)

//=============================================================================
// OVERVIEW
//=============================================================================
// Dedicated campaign-management engine.
//
// Single responsibility:
//   • Identify the dominant campaign.
//   • Preserve campaign coloring through healthy pullbacks.
//   • Detect weakening and campaign termination.
//   • Avoid entry/add logic.
//
// State model:
//   0  = Neutral
//   1  = Bull Transition
//   2  = Bull Campaign
//   3  = Bull Mature
//   4  = Bull Weakening
//  -1  = Bear Transition
//  -2  = Bear Campaign
//  -3  = Bear Mature
//  -4  = Bear Weakening

//=============================================================================
// INPUTS — MOVING AVERAGES
//=============================================================================
groupMA = "Moving Averages"

show8 = input.bool(true, "Show 9 SMA", group=groupMA)
len8 = input.int(9, "9 SMA length", minval=1, group=groupMA)
color8 = input.color(color.orange, "9 SMA color", group=groupMA)
width8 = input.int(1, "9 SMA thickness", minval=1, maxval=5, group=groupMA)

show20 = input.bool(true, "Show 20 SMA", group=groupMA)
len20 = input.int(20, "20 SMA length", minval=2, group=groupMA)
color20 = input.color(color.aqua, "20 SMA color", group=groupMA)
width20 = input.int(2, "20 SMA thickness", minval=1, maxval=5, group=groupMA)

show200 = input.bool(true, "Show 200 SMA", group=groupMA)
len200 = input.int(200, "200 SMA length", minval=20, group=groupMA)
color200 = input.color(color.fuchsia, "200 SMA color", group=groupMA)
width200 = input.int(2, "200 SMA thickness", minval=1, maxval=5, group=groupMA)

//=============================================================================
// INPUTS — CAMPAIGN LOGIC
//=============================================================================
groupCampaign = "Campaign Logic"

useParentCampaign = input.bool(true, "Use 5-minute parent campaign", group=groupCampaign)
parentTF = input.timeframe("5", "Parent campaign timeframe", group=groupCampaign)
useHigherContext = input.bool(true, "Use 15-minute strategic context", group=groupCampaign)
higherTF = input.timeframe("15", "Strategic context timeframe", group=groupCampaign)

transitionBars = input.int(3, "Transition confirmation bars", minval=1, maxval=8, group=groupCampaign)
minimum20SlopeAtr = input.float(0.08, "Minimum 20 slope in ATR", minval=0.01, maxval=0.60, step=0.01, group=groupCampaign)
strong20SlopeAtr = input.float(0.18, "Strong 20 slope in ATR", minval=0.02, maxval=1.00, step=0.01, group=groupCampaign)
flat20SlopeAtr = input.float(0.05, "Flat 20 threshold in ATR", minval=0.01, maxval=0.30, step=0.01, group=groupCampaign)

minimumEfficiency = input.float(0.25, "Minimum directional efficiency", minval=0.05, maxval=0.90, step=0.01, group=groupCampaign)
efficiencyLookback = input.int(12, "Efficiency lookback", minval=5, maxval=40, group=groupCampaign)
max20Crosses = input.int(4, "Maximum 20 crosses in lookback", minval=2, maxval=10, group=groupCampaign)

matureTravelAtr = input.float(3.25, "Mature campaign after ATR travel", minval=1.00, maxval=10.00, step=0.25, group=groupCampaign)
matureDistance20Atr = input.float(2.00, "Mature if distance from 20 exceeds ATR", minval=0.75, maxval=6.00, step=0.10, group=groupCampaign)
wide20To200Atr = input.float(4.50, "Wide state: 20-to-200 distance in ATR", minval=1.00, maxval=12.00, step=0.25, group=groupCampaign)

oppositeClosesThrough20 = input.int(2, "Closes through 20 to end campaign", minval=1, maxval=4, group=groupCampaign)
weakeningHealthThreshold = input.int(48, "Weakening health threshold", minval=20, maxval=75, group=groupCampaign)
exitHealthThreshold = input.int(25, "Exit health threshold", minval=5, maxval=50, group=groupCampaign)
weakeningHoldBars = input.int(5, "Maximum weakening bars", minval=1, maxval=12, group=groupCampaign)
requirePricePosition = input.bool(true, "Require price on correct side of 9 and 20", group=groupCampaign)
allThreeGuarantee = input.bool(true, "Automatic campaign whenever price is above/below all three SMAs", group=groupCampaign)
allowStrongLocalOverride = input.bool(true, "Allow strong local 9/20 structure to override delayed higher-timeframe context", group=groupCampaign)
strongSlopeGuarantee = input.bool(true, "Automatic campaign when price/9/20 align with a strongly sloping 20", group=groupCampaign)

groupStructure = "Campaign Structural Memory"
useStructuralMemory = input.bool(true, "Use campaign-defining Elephant Bar memory", group=groupStructure)
elephantBodyLookback = input.int(7, "Average body lookback", minval=3, maxval=20, group=groupStructure)
elephantBodyMultiplier = input.float(1.30, "Elephant body multiplier", minval=0.80, maxval=3.00, step=0.05, group=groupStructure)
elephantStructureLookback = input.int(5, "New-extreme lookback", minval=2, maxval=15, group=groupStructure)
elephantCloseAllowance = input.float(0.30, "Close-near-extreme allowance", minval=0.10, maxval=0.50, step=0.05, group=groupStructure)
anchorsToNeutral = input.int(2, "Closed anchor levels required for Neutral", minval=1, maxval=2, group=groupStructure)
showAnchorLevels = input.bool(false, "Show remembered structural levels", group=groupStructure)
bullAnchorColor = input.color(color.new(color.blue, 35), "Bull anchor level color", group=groupStructure)
bearAnchorColor = input.color(color.new(color.red, 35), "Bear anchor level color", group=groupStructure)
anchorWidth = input.int(1, "Anchor level thickness", minval=1, maxval=4, group=groupStructure)

//=============================================================================
// INPUTS — VISUALS
//=============================================================================
groupVisual = "Visuals"

showCampaignColors = input.bool(true, "Color campaign candles", group=groupVisual)
showTransitionColors = input.bool(false, "Color transition candles", group=groupVisual)
showWeakeningColor = input.bool(true, "Color weakening candles", group=groupVisual)
showResetColor = input.bool(true, "Color reset candle", group=groupVisual)
showStateLabels = input.bool(false, "Show state-change labels", group=groupVisual)

bullCampaignColor = input.color(color.rgb(145, 185, 220), "Bull campaign — Dull Light Blue", group=groupVisual)
bullMatureColor = input.color(color.rgb(125, 165, 205), "Bull mature campaign", group=groupVisual)
bullTransitionColor = input.color(color.rgb(80, 210, 235), "Bull transition", group=groupVisual)

bearCampaignColor = input.color(color.rgb(185, 125, 225), "Bear campaign — Light Purple", group=groupVisual)
bearMatureColor = input.color(color.rgb(155, 100, 195), "Bear mature campaign", group=groupVisual)
bearTransitionColor = input.color(color.rgb(235, 95, 185), "Bear transition", group=groupVisual)

weakeningColor = input.color(color.rgb(255, 190, 35), "Weakening — Amber", group=groupVisual)
resetColor = input.color(color.yellow, "Reset — Yellow", group=groupVisual)

//=============================================================================
// INPUTS — DIAGNOSTICS
//=============================================================================
groupDiag = "Diagnostics"
showDiagnostics = input.bool(false, "Show values in Data Window", group=groupDiag)

//=============================================================================
// CORE SERIES
//=============================================================================
sma8 = ta.sma(close, len8)
sma20 = ta.sma(close, len20)
sma200 = ta.sma(close, len200)
atr = ta.atr(14)

plot(show8 ? sma8 : na, "9 SMA", color=color8, linewidth=width8, force_overlay=true)
plot(show20 ? sma20 : na, "20 SMA", color=color20, linewidth=width20, force_overlay=true)
plot(show200 ? sma200 : na, "200 SMA", color=color200, linewidth=width200, force_overlay=true)

barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
avgBody = ta.sma(body, elephantBodyLookback)
bullBar = close > open
bearBar = close < open
bullStrongClose = bullBar and close >= high - barRange * elephantCloseAllowance
bearStrongClose = bearBar and close <= low + barRange * elephantCloseAllowance

slope8Atr = atr > 0 ? (sma8 - sma8[3]) / atr : 0.0
slope20Atr = atr > 0 ? (sma20 - sma20[5]) / atr : 0.0
slope200Atr = atr > 0 ? (sma200 - sma200[5]) / atr : 0.0

distance20Atr = atr > 0 ? math.abs(close - sma20) / atr : 0.0
distance20To200Atr = atr > 0 ? math.abs(sma20 - sma200) / atr : 0.0

bull20Strong = slope20Atr >= strong20SlopeAtr
bear20Strong = slope20Atr <= -strong20SlopeAtr
bull20Valid = slope20Atr >= minimum20SlopeAtr
bear20Valid = slope20Atr <= -minimum20SlopeAtr
flat20 = math.abs(slope20Atr) <= flat20SlopeAtr

//=============================================================================
// DIRECTIONAL EFFICIENCY / AUCTION
//=============================================================================
path = 0.0
for i = 0 to efficiencyLookback - 2
    path += math.abs(close[i] - close[i + 1])

net = math.abs(close - close[efficiencyLookback - 1])
efficiency = path > 0 ? net / path : 0.0

cross20 = ta.cross(close, sma20)
crossCount = ta.cum(cross20 ? 1.0 : 0.0) - nz(ta.cum(cross20 ? 1.0 : 0.0)[efficiencyLookback], 0.0)

neutralAuction =
     crossCount >= max20Crosses and
     flat20 and
     efficiency < minimumEfficiency

//=============================================================================
// MULTI-TIMEFRAME CONTEXT
//=============================================================================
pClose = request.security(syminfo.tickerid, parentTF, close, lookahead=barmerge.lookahead_off)
p8 = request.security(syminfo.tickerid, parentTF, ta.sma(close, len8), lookahead=barmerge.lookahead_off)
p20 = request.security(syminfo.tickerid, parentTF, ta.sma(close, len20), lookahead=barmerge.lookahead_off)
p20Slope = request.security(syminfo.tickerid, parentTF, ta.sma(close, len20) - ta.sma(close, len20)[5], lookahead=barmerge.lookahead_off)

hClose = request.security(syminfo.tickerid, higherTF, close, lookahead=barmerge.lookahead_off)
h20 = request.security(syminfo.tickerid, higherTF, ta.sma(close, len20), lookahead=barmerge.lookahead_off)

parentBull = pClose >= p20 and p8 >= p20 and p20Slope > 0
parentBear = pClose <= p20 and p8 <= p20 and p20Slope < 0
higherBull = hClose >= h20
higherBear = hClose <= h20

bullContext =
     (not useParentCampaign or parentBull) and
     (not useHigherContext or higherBull or parentBull)

bearContext =
     (not useParentCampaign or parentBear) and
     (not useHigherContext or higherBear or parentBear)

//=============================================================================
// PRICE POSITION / ALIGNMENT
//=============================================================================
// The campaign engine must first respect where price is relative to the 9 and
// 20. When price and the averages are fully aligned above or below all three
// moving averages, the campaign is guaranteed and higher-timeframe lag cannot
// suppress the local trend state.

bullPricePosition = close > sma8 and close > sma20
bearPricePosition = close < sma8 and close < sma20

bullAllThree =
     close > sma8 and
     close > sma20 and
     close > sma200

bearAllThree =
     close < sma8 and
     close < sma20 and
     close < sma200

bullLocalAuthority =
     bullPricePosition and
     sma8 >= sma20 and
     bull20Valid

bearLocalAuthority =
     bearPricePosition and
     sma8 <= sma20 and
     bear20Valid

bullStrongSlopeAuthority =
     strongSlopeGuarantee and
     close > sma8 and
     close > sma20 and
     sma8 >= sma20 and
     bull20Strong

bearStrongSlopeAuthority =
     strongSlopeGuarantee and
     close < sma8 and
     close < sma20 and
     sma8 <= sma20 and
     bear20Strong

//=============================================================================
// LOCAL CAMPAIGN CANDIDATES
//=============================================================================
bullStructure =
     (not requirePricePosition or bullPricePosition) and
     sma8 >= sma20 and
     bull20Valid and
     efficiency >= minimumEfficiency

bearStructure =
     (not requirePricePosition or bearPricePosition) and
     sma8 <= sma20 and
     bear20Valid and
     efficiency >= minimumEfficiency

bullTransitionCandidate =
     not neutralAuction and
     (bullStrongSlopeAuthority or
      (bullStructure and
       (bullContext or (allowStrongLocalOverride and bullLocalAuthority) or (allThreeGuarantee and bullAllThree))))

bearTransitionCandidate =
     not neutralAuction and
     (bearStrongSlopeAuthority or
      (bearStructure and
       (bearContext or (allowStrongLocalOverride and bearLocalAuthority) or (allThreeGuarantee and bearAllThree))))

bullTransitionCount = math.sum(bullTransitionCandidate ? 1.0 : 0.0, transitionBars)
bearTransitionCount = math.sum(bearTransitionCandidate ? 1.0 : 0.0, transitionBars)

bullTransitionConfirmed = bullTransitionCount >= transitionBars
bearTransitionConfirmed = bearTransitionCount >= transitionBars

//=============================================================================
// CAMPAIGN HEALTH
//=============================================================================
bullHealth =
     (close >= sma20 ? 22 : 0) +
     (sma8 >= sma20 ? 18 : 0) +
     (bull20Valid ? 16 : 0) +
     (bull20Strong ? 12 : 0) +
     (bullContext ? 12 : 0) +
     (close >= sma8 ? 10 : 0) +
     (efficiency >= minimumEfficiency ? 10 : 0)

bearHealth =
     (close <= sma20 ? 22 : 0) +
     (sma8 <= sma20 ? 18 : 0) +
     (bear20Valid ? 16 : 0) +
     (bear20Strong ? 12 : 0) +
     (bearContext ? 12 : 0) +
     (close <= sma8 ? 10 : 0) +
     (efficiency >= minimumEfficiency ? 10 : 0)

//=============================================================================
// STATE MACHINE
//=============================================================================
var int state = 0
var float campaignStartPrice = na
var int campaignStartBar = na
var int weakeningBars = 0

// Most recent two campaign-defining Elephant Bar invalidation levels.
// Bull campaign anchors store Elephant Bar lows.
// Bear campaign anchors store Elephant Bar highs.
var float bullAnchor1 = na
var float bullAnchor2 = na
var float bearAnchor1 = na
var float bearAnchor2 = na

bullCampaignActive = state > 0
bearCampaignActive = state < 0

campaignTravelAtr =
     bullCampaignActive and not na(campaignStartPrice) ? (high - campaignStartPrice) / atr :
     bearCampaignActive and not na(campaignStartPrice) ? (campaignStartPrice - low) / atr :
     0.0

campaignMature =
     campaignTravelAtr >= matureTravelAtr or
     distance20Atr >= matureDistance20Atr or
     distance20To200Atr >= wide20To200Atr

bullCampaignElephant =
     useStructuralMemory and
     state > 0 and
     bullStrongClose and
     body >= avgBody * elephantBodyMultiplier and
     close > ta.highest(high, elephantStructureLookback)[1]

bearCampaignElephant =
     useStructuralMemory and
     state < 0 and
     bearStrongClose and
     body >= avgBody * elephantBodyMultiplier and
     close < ta.lowest(low, elephantStructureLookback)[1]

if bullCampaignElephant
    bullAnchor2 := bullAnchor1
    bullAnchor1 := low

if bearCampaignElephant
    bearAnchor2 := bearAnchor1
    bearAnchor1 := high

// Wicks do not count. Only a candle CLOSE through an anchor changes integrity.
bullAnchorBreach1 = state > 0 and not na(bullAnchor1) and close < bullAnchor1
bullAnchorBreach2 = state > 0 and not na(bullAnchor2) and close < bullAnchor2
bearAnchorBreach1 = state < 0 and not na(bearAnchor1) and close > bearAnchor1
bearAnchorBreach2 = state < 0 and not na(bearAnchor2) and close > bearAnchor2

bullStructuralBreachCount = (bullAnchorBreach1 ? 1 : 0) + (bullAnchorBreach2 ? 1 : 0)
bearStructuralBreachCount = (bearAnchorBreach1 ? 1 : 0) + (bearAnchorBreach2 ? 1 : 0)

bullStructuralWeakening =
     useStructuralMemory and
     state > 0 and
     bullStructuralBreachCount >= 1

bearStructuralWeakening =
     useStructuralMemory and
     state < 0 and
     bearStructuralBreachCount >= 1

bullStructuralNeutral =
     useStructuralMemory and
     state > 0 and
     bullStructuralBreachCount >= anchorsToNeutral

bearStructuralNeutral =
     useStructuralMemory and
     state < 0 and
     bearStructuralBreachCount >= anchorsToNeutral

bullOppositeCount =
     (close < sma20 ? 1 : 0) +
     (close[1] < sma20[1] ? 1 : 0) +
     (oppositeClosesThrough20 >= 3 and close[2] < sma20[2] ? 1 : 0) +
     (oppositeClosesThrough20 >= 4 and close[3] < sma20[3] ? 1 : 0)

bearOppositeCount =
     (close > sma20 ? 1 : 0) +
     (close[1] > sma20[1] ? 1 : 0) +
     (oppositeClosesThrough20 >= 3 and close[2] > sma20[2] ? 1 : 0) +
     (oppositeClosesThrough20 >= 4 and close[3] > sma20[3] ? 1 : 0)

bullWeakening =
     bullCampaignActive and
     (bullStructuralWeakening or bullHealth <= weakeningHealthThreshold or slope20Atr <= 0)

bearWeakening =
     bearCampaignActive and
     (bearStructuralWeakening or bearHealth <= weakeningHealthThreshold or slope20Atr >= 0)

bullExit =
     bullCampaignActive and
     (bullOppositeCount >= oppositeClosesThrough20 or
      neutralAuction)

bearExit =
     bearCampaignActive and
     (bearOppositeCount >= oppositeClosesThrough20 or
      neutralAuction)

previousState = state

// Structural invalidation has priority over automatic MA alignment.
// One closed anchor warns; the configured number of closed anchors resets Neutral.
if bullStructuralNeutral or bearStructuralNeutral
    state := 0
    campaignStartPrice := na
    campaignStartBar := na
    weakeningBars := 0
    bullAnchor1 := na
    bullAnchor2 := na
    bearAnchor1 := na
    bearAnchor2 := na

else if bullStructuralWeakening
    state := 4
    weakeningBars := math.max(weakeningBars, 1)

else if bearStructuralWeakening
    state := -4
    weakeningBars := math.max(weakeningBars, 1)

// Full price alignment has absolute campaign authority when structural memory
// has not recorded a confirmed close-through invalidation.
// Above all three = bullish campaign.
// Below all three = bearish campaign.
// No slope, MA ordering, efficiency, health, or higher-timeframe requirement
// can suppress this state.
else if allThreeGuarantee and bullAllThree
    if state <= 0
        campaignStartPrice := close
        campaignStartBar := bar_index
        bearAnchor1 := na
        bearAnchor2 := na
    state := campaignMature ? 3 : 2
    weakeningBars := 0

else if allThreeGuarantee and bearAllThree
    if state >= 0
        campaignStartPrice := close
        campaignStartBar := bar_index
        bullAnchor1 := na
        bullAnchor2 := na
    state := campaignMature ? -3 : -2
    weakeningBars := 0

else if bullStrongSlopeAuthority
    if state <= 0
        campaignStartPrice := close
        campaignStartBar := bar_index
        bearAnchor1 := na
        bearAnchor2 := na
    state := campaignMature ? 3 : 2
    weakeningBars := 0

else if bearStrongSlopeAuthority
    if state >= 0
        campaignStartPrice := close
        campaignStartBar := bar_index
        bullAnchor1 := na
        bullAnchor2 := na
    state := campaignMature ? -3 : -2
    weakeningBars := 0

else if state == 0
    weakeningBars := 0
    if bullTransitionCandidate
        state := 1
    else if bearTransitionCandidate
        state := -1

else if state == 1
    if bearTransitionCandidate
        state := -1
    else if bullTransitionConfirmed
        state := 2
        campaignStartPrice := close
        campaignStartBar := bar_index
    else if not bullTransitionCandidate
        state := 0

else if state == -1
    if bullTransitionCandidate
        state := 1
    else if bearTransitionConfirmed
        state := -2
        campaignStartPrice := close
        campaignStartBar := bar_index
    else if not bearTransitionCandidate
        state := 0

else if state == 2 or state == 3
    if bullExit
        state := 0
        campaignStartPrice := na
        campaignStartBar := na
        weakeningBars := 0
    else if bullWeakening
        state := 4
        weakeningBars := 1
    else if campaignMature
        state := 3
    else
        state := 2

else if state == -2 or state == -3
    if bearExit
        state := 0
        campaignStartPrice := na
        campaignStartBar := na
        weakeningBars := 0
    else if bearWeakening
        state := -4
        weakeningBars := 1
    else if campaignMature
        state := -3
    else
        state := -2

else if state == 4
    weakeningBars += 1
    if bullExit
        state := 0
        campaignStartPrice := na
        campaignStartBar := na
        weakeningBars := 0
    else if close >= sma20 and sma8 >= sma20 and slope20Atr > 0
        state := campaignMature ? 3 : 2
        weakeningBars := 0

else if state == -4
    weakeningBars += 1
    if bearExit
        state := 0
        campaignStartPrice := na
        campaignStartBar := na
        weakeningBars := 0
    else if close <= sma20 and sma8 <= sma20 and slope20Atr < 0
        state := campaignMature ? -3 : -2
        weakeningBars := 0

//=============================================================================
// VISUAL OUTPUT
//=============================================================================
stateChanged = state != previousState
resetBar = state == 0 and previousState != 0

color candleColor = na

if showCampaignColors
    if state == 2
        candleColor := bullCampaignColor
    else if state == 3
        candleColor := bullMatureColor
    else if state == -2
        candleColor := bearCampaignColor
    else if state == -3
        candleColor := bearMatureColor

if showTransitionColors
    if state == 1
        candleColor := bullTransitionColor
    else if state == -1
        candleColor := bearTransitionColor

if showWeakeningColor
    if state == 4 or state == -4
        candleColor := weakeningColor

if showResetColor and resetBar
    candleColor := resetColor

barcolor(candleColor)

plot(showAnchorLevels and state > 0 ? bullAnchor1 : na, "Bull Structural Anchor 1", color=bullAnchorColor, linewidth=anchorWidth, style=plot.style_linebr, force_overlay=true)
plot(showAnchorLevels and state > 0 ? bullAnchor2 : na, "Bull Structural Anchor 2", color=bullAnchorColor, linewidth=anchorWidth, style=plot.style_linebr, force_overlay=true)
plot(showAnchorLevels and state < 0 ? bearAnchor1 : na, "Bear Structural Anchor 1", color=bearAnchorColor, linewidth=anchorWidth, style=plot.style_linebr, force_overlay=true)
plot(showAnchorLevels and state < 0 ? bearAnchor2 : na, "Bear Structural Anchor 2", color=bearAnchorColor, linewidth=anchorWidth, style=plot.style_linebr, force_overlay=true)

if showStateLabels and stateChanged
    labelText =
         state == 1 ? "BULL TRANSITION" :
         state == 2 ? "BULL CAMPAIGN" :
         state == 3 ? "BULL MATURE" :
         state == 4 ? "BULL WEAKENING" :
         state == -1 ? "BEAR TRANSITION" :
         state == -2 ? "BEAR CAMPAIGN" :
         state == -3 ? "BEAR MATURE" :
         state == -4 ? "BEAR WEAKENING" :
         "RESET"

    bullishLabel = state > 0

    label.new(
         bar_index,
         bullishLabel ? low : high,
         labelText,
         style=bullishLabel ? label.style_label_up : label.style_label_down,
         color=candleColor,
         textcolor=color.white,
         size=size.tiny,
         force_overlay=true)

//=============================================================================
// ALERTS
//=============================================================================
alertcondition(state == 2 and previousState != 2, "Bull Campaign Started", "Bull campaign confirmed.")
alertcondition(state == -2 and previousState != -2, "Bear Campaign Started", "Bear campaign confirmed.")
alertcondition(state == 4 and previousState != 4, "Bull Campaign Weakening", "Bull campaign is weakening.")
alertcondition(state == -4 and previousState != -4, "Bear Campaign Weakening", "Bear campaign is weakening.")
alertcondition(bullStructuralWeakening, "Bull Structure Breached", "A candle closed below a remembered bullish Elephant Bar anchor.")
alertcondition(bearStructuralWeakening, "Bear Structure Breached", "A candle closed above a remembered bearish Elephant Bar anchor.")
alertcondition(resetBar, "Campaign Reset", "Campaign ended and reset to neutral.")

//=============================================================================
// DIAGNOSTICS
//=============================================================================
plot(showDiagnostics ? state : na, "Campaign State", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? bullHealth : na, "Bull Health", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? bearHealth : na, "Bear Health", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? efficiency : na, "Directional Efficiency", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? campaignTravelAtr : na, "Campaign Travel ATR", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? bullStructuralBreachCount : na, "Bull Structural Breaches", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? bearStructuralBreachCount : na, "Bear Structural Breaches", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? (bullPricePosition ? 1 : bearPricePosition ? -1 : 0) : na, "Price vs 9/20", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? (bullAllThree ? 1 : bearAllThree ? -1 : 0) : na, "All-Three Alignment", color=color.new(color.gray, 100), display=display.data_window)
plot(showDiagnostics ? (bullStrongSlopeAuthority ? 1 : bearStrongSlopeAuthority ? -1 : 0) : na, "Strong 20 Slope Authority", color=color.new(color.gray, 100), display=display.data_window)
````

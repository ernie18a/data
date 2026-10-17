# Mean Reversion Zones

- url: https://www.tradingview.com/script/PYyTdl1O-mean-reversion-zones/
- type: indicator
- pine_id: PUB;172723fcf17a4c11bc7abe283424f31b
- version: 1.0

## Description

Mean Reversion Zones is an indicator that helps evaluate how far price has deviated from the balance line.

The indicator builds a dynamic mean-reversion channel around the calculated balance line. The upper red zones show areas where price has deviated above balance. The lower green zones show areas where price has deviated below balance. The central grey area represents the balance zone, where price is closer to its current average value.

This tool is designed to help traders read market context, identify stretched price conditions, and understand where the market is currently located: near balance, above balance, below balance, or inside an extreme deviation zone.

How it works

The script uses endpoint kernel smoothing to calculate a non-repainting balance line. Around this line, it builds several adaptive zones based on the mean absolute deviation of price from balance and current volatility conditions.

The channel can work in two width modes:

Fixed : the channel width is calculated based on the selected multiplier.
Adaptive : the channel expands and contracts depending on the current ATR compared with its average value.

The zones are divided into several areas:

Balance Zone : price is close to its average value.
Upper Risk Zone : price has deviated above balance.
Upper Extreme / Outer Risk Zone : price is strongly stretched to the upside.
Lower Opportunity Zone : price has deviated below balance.
Lower Extreme / Outer Opportunity Zone : price is strongly stretched to the downside.

 Extreme dots

Red dots appear only when price reaches the upper extreme area or moves above the outer upper zone.

Green dots appear only when price reaches the lower extreme area or moves below the outer lower zone.

These dots are not trading signals. They are visual markers showing that price has reached a statistically stretched area relative to the current balance line.

  Dashboard

The Dashboard briefly shows the current market context:

Zone : the current position of price inside the channel.
Reading : a simple text description of the current deviation.
Trend : EMA-based trend context: Uptrend, Downtrend, or Sideways.
Volatility : current ATR compared with its average value.
Hint : an educational context hint, not a trading recommendation.

  How to use

The indicator may be useful for traders who want to answer several questions:

1. Is price close to balance or already far away from it?
2. Has the market deviated upward or downward?
3. Is the current deviation moving with the trend or against it?
4. Is volatility normal, high, or extreme?
5. Is it better to wait for price to return closer to balance before making a decision?

  Important limitations

The indicator does not predict future price movement.

Upper zones are not automatic short signals. Lower zones are not automatic long signals. Extreme dots are not entry signals. They only show that price is currently stretched relative to the calculated balance line.

Mean-reversion tools can remain in a stretched condition for a long time during strong trends. Therefore, this indicator should always be used together with market structure analysis, trend analysis, volume, risk management, and your own trading plan.

 Alerts

The script includes alerts for the following events:

 Price enters the upper risk zone.
 Price enters the extreme upper risk zone.
 Price moves above the outer upper risk zone.
 Price enters the lower opportunity zone.
 Price enters the extreme lower opportunity zone.
 Price moves below the outer lower opportunity zone.
 Price returns to the balance zone.

These alerts are intended only for tracking market context and should not be treated as standalone trading signals.
[url=https://www.tradingview.com/x/njcZp5Hg/]https://www.tradingview.com/x/njcZp5Hg/[/url][image]https://www.tradingview.com/x/njcZp5Hg/[/image]

## Source Code

````pine
// This source code is subject to the terms of the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarketStructureLab
// MSL Mean Reversion Zones, developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.
//@version=6
indicator("MarketStructureLab - Mean Reversion Zones", "MSL MR Zones", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)
//==== INPUTS ============================================================
groupCalc   = "Core Settings"
groupZones  = "Channel & Zones"
groupVisual = "Visuals"
groupTable  = "Dashboard"
// Core
src      = input.source(close, "Source", group=groupCalc, display=display.none, tooltip="Price series used for smoothing. Close is standard.")
gaussLen = input.float(8.0, "Smoothing Length", minval=1.0, step=0.5, group=groupCalc, display=display.none, tooltip="Gaussian bandwidth. Higher = smoother balance line. Lower = more reactive and noisier.")
// Channel
widthMode  = input.string("Adaptive", "Channel Width Mode", options=["Fixed", "Adaptive"], group=groupZones, display=display.none, tooltip="Fixed: channel uses Channel Width only. Adaptive: channel expands and contracts with current volatility.")
widthBase  = input.float(3.0, "Channel Width", minval=0.1, step=0.1, group=groupZones, display=display.none, tooltip="Base multiplier on mean absolute error. Higher = wider channel, fewer zone touches.")
adaptPower = input.float(0.5, "Adaptation Strength", minval=0.0, maxval=2.0, step=0.1, group=groupZones, display=display.none, tooltip="How strongly the channel reacts to volatility. 0 = off, 1 = linear, 2 = stronger adaptation. Used only in Adaptive mode.")
atrLen     = input.int(14, "ATR Length", minval=1, group=groupZones, display=display.none, tooltip="ATR period for volatility stats.")
volAvgLen  = input.int(50, "Volatility Lookback", minval=5, group=groupZones, display=display.none, tooltip="Window used to average current volatility. Higher = smoother adaptation.")
// Zone multipliers
midMult     = input.float(0.25, "Balance Zone Width", minval=0.05, maxval=0.9, step=0.05, group=groupZones, display=display.none, tooltip="Half-width of the central balance zone as a fraction of channel width.")
softMult    = input.float(0.65, "Risk / Opportunity Zone", minval=0.3, maxval=0.95, step=0.05, group=groupZones, display=display.none, tooltip="Distance from balance where price enters the regular upper risk or lower opportunity zone.")
extremeMult = input.float(1.00, "Extreme Zone", minval=0.6, maxval=1.5, step=0.05, group=groupZones, display=display.none, tooltip="Distance where the extreme upper/lower zone begins.")
outerMult   = input.float(1.15, "Outer Zone", minval=0.7, maxval=1.6, step=0.05, group=groupZones, display=display.none, tooltip="Outer reference for the strongest deviation zone fill.")
trendLen    = input.int(50, "Trend Context Length", minval=5, group=groupZones, display=display.none, tooltip="EMA period used only for dashboard trend context.")
// Visuals
showMidZone   = input.bool(true,  "Show Balance Zone",              group=groupVisual, display=display.none, tooltip="Toggle the central balance zone fill.")
showSoftZones = input.bool(true,  "Show Risk / Opportunity Zones",  group=groupVisual, display=display.none, tooltip="Toggle the regular upper risk and lower opportunity zone fills.")
showExtreme   = input.bool(true,  "Show Extreme Zones",             group=groupVisual, display=display.none, tooltip="Toggle the extreme and outer zone lines and fills.")
showDots      = input.bool(true,  "Show Extreme Dots",              group=groupVisual, display=display.none, tooltip="Small dots appear only when price is inside the extreme upper/lower zones or outside the outer channel. These are not trading signals.")
showLabels    = input.bool(false, "Show First-Touch Labels",        group=groupVisual, display=display.none, tooltip="Optional educational labels when price first enters an extreme risk or extreme opportunity zone.")
midFillT      = input.int(88, "Balance Zone Transparency",          minval=0, maxval=100, group=groupVisual, display=display.none, tooltip="Higher = more transparent balance zone.")
softFillT     = input.int(82, "Risk / Opportunity Transparency",    minval=0, maxval=100, group=groupVisual, display=display.none, tooltip="Higher = more transparent upper/lower zones.")
extremeFillT  = input.int(72, "Extreme Zone Transparency",          minval=0, maxval=100, group=groupVisual, display=display.none, tooltip="Higher = more transparent extreme zones.")
bullColor     = input.color(color.teal, "Lower Zone", inline="clr", group=groupVisual, display=display.none, tooltip="Colour for lower opportunity / oversold areas.")
bearColor     = input.color(color.red,  "Upper Zone", inline="clr", group=groupVisual, display=display.none, tooltip="Colour for upper risk / overbought areas.")
// Dashboard
showTable = input.bool(true, "Show Dashboard", group=groupTable, display=display.none, tooltip="Toggle the educational dashboard.")
tablePos  = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=groupTable, display=display.none, tooltip="Dashboard position on the chart.")
//==== COLORS ============================================================
textColor      = color.white
headerBg       = #1e222d
leftColBg      = #252833
rightNeutralBg = #2a2e39
borderColor    = #373a46
//==== HELPERS ===========================================================
safeDiv(float num, float den, float fallback) =>
    (na(num) or na(den) or den == 0.0) ? fallback : (num / den)
clampFloat(float x, float lo, float hi) =>
    na(x) ? lo : x < lo ? lo : x > hi ? hi : x
gauss(float x, float b) =>
    math.exp(-(math.pow(x, 2) / (b * b * 2.0)))
getPos(string p) =>
    p == "Top Left" ? position.top_left : p == "Top Right" ? position.top_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Right" ? position.bottom_right : position.middle_right
//==== CALCULATIONS ======================================================
// Endpoint kernel smoothing. Non-repainting by construction.
var gaussWeights = array.new<float>()
var float weightSum = 0.0
if barstate.isfirst
    for i = 0 to 499
        array.push(gaussWeights, gauss(i, gaussLen))
    weightSum := array.sum(gaussWeights)
float balanceRaw = 0.0
for i = 0 to 499
    balanceRaw += nz(src[i]) * array.get(gaussWeights, i)
balance = safeDiv(balanceRaw, weightSum, src)
channelMae = ta.sma(math.abs(src - balance), 499) * widthBase
// Volatility
atrNow   = ta.atr(atrLen)
atrAvg   = ta.sma(atrNow, volAvgLen)
volRatio = safeDiv(atrNow, atrAvg, 1.0)
volState = volRatio < 0.8 ? "Low" : volRatio < 1.2 ? "Normal" : volRatio < 1.6 ? "High" : "Extreme"
// Channel width
widthMult    = widthMode == "Adaptive" ? math.pow(clampFloat(volRatio, 0.3, 3.0), adaptPower) : 1.0
channelWidth = channelMae * widthMult
// Zone levels
midUpper   = balance + channelWidth * midMult
midLower   = balance - channelWidth * midMult
softUpper  = balance + channelWidth * softMult
softLower  = balance - channelWidth * softMult
extUpper   = balance + channelWidth * extremeMult
extLower   = balance - channelWidth * extremeMult
outerUpper = balance + channelWidth * outerMult
outerLower = balance - channelWidth * outerMult
// Trend context
trendLine   = ta.ema(close, trendLen)
trendSlope  = trendLine - trendLine[1]
isUptrend   = close > trendLine and trendSlope > 0
isDowntrend = close < trendLine and trendSlope < 0
trendText   = isUptrend ? "Uptrend" : isDowntrend ? "Downtrend" : "Sideways"
//==== SIGNAL ENGINE =====================================================
// Zone states (visual context only, no trade signals)
inBalance     = close <= midUpper  and close >= midLower
aboveBalance  = close >  midUpper  and close <= softUpper
belowBalance  = close <  midLower  and close >= softLower
inUpperRisk   = close >  softUpper and close <  extUpper
inExtremeRisk = close >= extUpper
inLowerOpp    = close <  softLower and close >  extLower
inExtremeOpp  = close <= extLower
outsideUpper  = close >= outerUpper
outsideLower  = close <= outerLower
dotUpper = close >= extUpper
dotLower = close <= extLower
priceZone   = outsideUpper ? "Above Outer Risk" : inExtremeRisk ? "Extreme Risk" : inUpperRisk ? "Upper Risk" : outsideLower ? "Below Outer Opportunity" : inExtremeOpp ? "Extreme Opportunity" : inLowerOpp ? "Lower Opportunity" : aboveBalance ? "Above Balance" : belowBalance ? "Below Balance" : "Balance"
readingText = outsideUpper ? "Very stretched up" : inExtremeRisk ? "Strong upper deviation" : inUpperRisk ? "Price stretched up" : outsideLower ? "Very stretched down" : inExtremeOpp ? "Strong lower deviation" : inLowerOpp ? "Price stretched down" : aboveBalance ? "Above balance" : belowBalance ? "Below balance" : "Neutral zone"
hintText    = outsideUpper ? "Pullback risk" : inExtremeRisk ? "Watch pullback" : inUpperRisk ? "Avoid late longs" : outsideLower ? "Rebound possible" : inExtremeOpp ? "Watch rebound" : inLowerOpp ? "Avoid late shorts" : aboveBalance ? "No extreme" : belowBalance ? "No extreme" : "No edge yet"
// New-entry events
newUpperRisk      = inUpperRisk    and not inUpperRisk[1]
newExtremeRisk    = inExtremeRisk  and not inExtremeRisk[1]
newLowerOpp       = inLowerOpp     and not inLowerOpp[1]
newExtremeOpp     = inExtremeOpp   and not inExtremeOpp[1]
newOutsideUpper   = outsideUpper   and not outsideUpper[1]
newOutsideLower   = outsideLower   and not outsideLower[1]
returnedToBalance = inBalance      and not inBalance[1]
//==== VISUAL STATE ======================================================
zoneColor    = outsideUpper ? color.new(bearColor, 0) : inExtremeRisk ? color.new(bearColor, 15) : inUpperRisk ? color.new(bearColor, 40) : outsideLower ? color.new(bullColor, 0) : inExtremeOpp ? color.new(bullColor, 15) : inLowerOpp ? color.new(bullColor, 40) : aboveBalance ? color.new(bearColor, 70) : belowBalance ? color.new(bullColor, 70) : color.new(color.gray, 50)
trendColor   = isUptrend ? color.new(bullColor, 30) : isDowntrend ? color.new(bearColor, 30) : color.new(color.gray, 50)
volColor     = volState == "Normal" ? color.new(bullColor, 40) : volState == "High" ? color.new(color.orange, 30) : volState == "Extreme" ? color.new(color.red, 20) : color.new(color.gray, 40)
readingColor = outsideUpper or inExtremeRisk or inUpperRisk ? color.new(bearColor, 35) : outsideLower or inExtremeOpp or inLowerOpp ? color.new(bullColor, 35) : color.new(color.gray, 50)
hintColor    = outsideUpper or inExtremeRisk or inUpperRisk ? color.new(bearColor, 35) : outsideLower or inExtremeOpp or inLowerOpp ? color.new(bullColor, 35) : color.new(color.gray, 50)
//==== PLOTS =============================================================
plot(balance, "Balance Line", color.new(color.gray, 40), 2)
pMidU    = plot(showMidZone   ? midUpper   : na, "Balance Upper",          color.new(color.gray, 70))
pMidL    = plot(showMidZone   ? midLower   : na, "Balance Lower",          color.new(color.gray, 70))
pUpSoft  = plot(showSoftZones ? softUpper  : na, "Upper Risk Zone",        color.new(bearColor, 50))
pLoSoft  = plot(showSoftZones ? softLower  : na, "Lower Opportunity Zone", color.new(bullColor, 50))
pUpExt   = plot(showExtreme   ? extUpper   : na, "Upper Extreme",          color.new(bearColor, 40))
pLoExt   = plot(showExtreme   ? extLower   : na, "Lower Extreme",          color.new(bullColor, 40))
pUpOuter = plot(showExtreme   ? outerUpper : na, "Upper Outer Zone",       color.new(bearColor, 30))
pLoOuter = plot(showExtreme   ? outerLower : na, "Lower Outer Zone",       color.new(bullColor, 30))
fill(pMidU,   pMidL,    color=showMidZone   ? color.new(color.gray, midFillT)    : na, title="Balance Zone Fill")
fill(pUpSoft, pUpExt,   color=showSoftZones ? color.new(bearColor, softFillT)    : na, title="Upper Risk Fill")
fill(pUpExt,  pUpOuter, color=showExtreme   ? color.new(bearColor, extremeFillT) : na, title="Upper Extreme Fill")
fill(pLoSoft, pLoExt,   color=showSoftZones ? color.new(bullColor, softFillT)    : na, title="Lower Opportunity Fill")
fill(pLoExt,  pLoOuter, color=showExtreme   ? color.new(bullColor, extremeFillT) : na, title="Lower Extreme Fill")
plotshape(showDots and dotUpper, "Extreme Upper Dot", style=shape.circle, location=location.abovebar, color=color.new(bearColor, outsideUpper ? 0 : 25), size=size.tiny)
plotshape(showDots and dotLower, "Extreme Lower Dot", style=shape.circle, location=location.belowbar, color=color.new(bullColor, outsideLower ? 0 : 25), size=size.tiny)
if showLabels and newExtremeRisk
    label.new(bar_index, high, outsideUpper ? "Outer Risk" : "Extreme Risk", style=label.style_label_down, color=color.new(bearColor, outsideUpper ? 0 : 10), textcolor=textColor, size=size.tiny, yloc=yloc.abovebar)
if showLabels and newExtremeOpp
    label.new(bar_index, low, outsideLower ? "Outer Opportunity" : "Extreme Opportunity", style=label.style_label_up, color=color.new(bullColor, outsideLower ? 0 : 10), textcolor=textColor, size=size.tiny, yloc=yloc.belowbar)
//==== ALERTS ============================================================
alertcondition(newUpperRisk,      "MSL MR Zones - Upper Risk Zone",           "MarketStructureLab MR Zones: price entered the upper risk zone.")
alertcondition(newExtremeRisk,    "MSL MR Zones - Extreme Upper Risk",        "MarketStructureLab MR Zones: price entered the extreme upper risk zone.")
alertcondition(newOutsideUpper,   "MSL MR Zones - Above Outer Risk",          "MarketStructureLab MR Zones: price moved above the upper outer risk zone.")
alertcondition(newLowerOpp,       "MSL MR Zones - Lower Opportunity Zone",    "MarketStructureLab MR Zones: price entered the lower opportunity zone.")
alertcondition(newExtremeOpp,     "MSL MR Zones - Extreme Lower Opportunity", "MarketStructureLab MR Zones: price entered the extreme lower opportunity zone.")
alertcondition(newOutsideLower,   "MSL MR Zones - Below Outer Opportunity",   "MarketStructureLab MR Zones: price moved below the lower outer opportunity zone.")
alertcondition(returnedToBalance, "MSL MR Zones - Back to Balance",           "MarketStructureLab MR Zones: price returned to the balance zone.")
//==== TABLE =============================================================
var table proTable = table.new(getPos(tablePos), 2, 6, bgcolor=headerBg, border_color=borderColor, border_width=1, frame_color=borderColor, frame_width=1)
if showTable and barstate.islast
    table.cell(proTable, 0, 0, "MSL MR",     text_color=textColor, text_size=size.normal, bgcolor=headerBg)
    table.cell(proTable, 1, 0, "Zones",      text_color=textColor, text_size=size.normal, bgcolor=headerBg)
    table.cell(proTable, 0, 1, "Zone",       text_color=textColor, text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 1, priceZone,    text_color=textColor, text_size=size.small,  bgcolor=zoneColor)
    table.cell(proTable, 0, 2, "Reading",    text_color=textColor, text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 2, readingText,  text_color=textColor, text_size=size.small,  bgcolor=readingColor)
    table.cell(proTable, 0, 3, "Trend",      text_color=textColor, text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 3, trendText,    text_color=textColor, text_size=size.small,  bgcolor=trendColor)
    table.cell(proTable, 0, 4, "Volatility", text_color=textColor, text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 4, volState,     text_color=textColor, text_size=size.small,  bgcolor=volColor)
    table.cell(proTable, 0, 5, "Hint",       text_color=textColor, text_size=size.small,  bgcolor=leftColBg)
    table.cell(proTable, 1, 5, hintText,     text_color=textColor, text_size=size.small,  bgcolor=hintColor)
if not showTable and barstate.islast
    table.clear(proTable, 0, 0, 1, 5)
//==== USAGE GUIDE =======================================================
// WHAT THIS INDICATOR DOES
// MSL Mean Reversion Zones shows how far price has moved away from a
// smoothed balance line. Upper red zones highlight areas where price may
// be extended above balance. Lower green zones highlight areas where
// price may be extended below balance. The middle grey area is the
// balance zone.
//
// IMPORTANT
// This indicator does not generate buy or sell signals. It is an
// educational market context tool. Upper zones are not automatic short
// entries. Lower zones are not automatic long entries. Always read zones
// together with trend context, volatility, market structure and risk
// management.
//
// HOW TO READ THE ZONES
//   Balance                  : price is close to the mean, no extreme deviation.
//   Upper Risk               : price extended above balance, pullback risk increases.
//   Extreme Risk             : price strongly extended above, be careful with late longs.
//   Above Outer Risk         : price outside the upper channel, very stretched condition.
//   Lower Opportunity        : price extended below balance, rebound probability increases.
//   Extreme Opportunity      : price strongly extended below, be careful with late shorts.
//   Below Outer Opportunity  : price outside the lower channel, very stretched condition.
//
// EXTREME DOTS
// Red dots appear only at or above the Upper Extreme level. Green dots
// appear only at or below the Lower Extreme level. Dots do not appear in
// regular soft zones or near the balance area.
//
// DASHBOARD
//   Zone       : current location of price inside the channel.
//   Reading    : plain description of the current deviation.
//   Trend      : EMA-based context, Uptrend / Downtrend / Sideways.
//   Volatility : current ATR vs its average, Low / Normal / High / Extreme.
//   Hint       : educational interpretation. Not a trading signal.
//
// SUGGESTED USE
// 1. Is price near balance or far from it?
// 2. Is price in an upper risk zone or lower opportunity zone?
// 3. Is the move supported by trend or stretched against it?
// 4. Is volatility normal or extreme?
//
// Suggested timeframes: H1 and above. Use for context building, not
// blind entries.
//==========================================================================
````

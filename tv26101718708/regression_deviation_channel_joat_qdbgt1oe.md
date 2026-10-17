# Regression Deviation Channel [JOAT]

- url: https://www.tradingview.com/script/qdbgt1Oe-Regression-Deviation-Channel-JOAT/
- type: indicator
- pine_id: PUB;86675a9cad5245c4abd2126e6a788637
- version: 1.0

## Description

[b]Regression Deviation Channel [JOAT][/b]

[b]Introduction[/b]

The Regression Deviation Channel [JOAT] is an institutional-style statistical trend and execution framework built around segmented regression, deviation envelopes, premium/discount zoning, breakout qualification, and risk mapping. Instead of acting like a plain moving-average channel, it models price through a best-fit regression path, measures dispersion with RMSE, then classifies where price is trading inside that structure: discount, equilibrium, or premium.

This version is designed to feel more like a desk-grade directional map than a simple overlay. It combines a frozen regression segment, internal band hierarchy, confidence scoring, Supertrend stack alignment, breakout detection, and ATR-based trade mapping into one visual structure. The goal is not just to show where price is, but whether the current move is balanced, compressed, expanding, or resolving.

[image]https://www.tradingview.com/x/3PvmlBKK/[/image]

[b]Why This Indicator Exists[/b]

Most channels are too simple. They show boundaries but do not explain what price is doing inside those boundaries. This indicator was built to solve that by combining:

[list]
[*][b]Segmented Regression:[/b] Tracks the current directional price path with a proper best-fit slope
[*][b]Deviation Architecture:[/b] Uses RMSE to define statistically meaningful channel width
[*][b]Premium / Discount Zoning:[/b] Splits the channel into expensive, fair value, and cheap territory
[*][b]Breakout Qualification:[/b] Scores breakout quality using slope, participation, structure, and location
[*][b]Trend Stack Context:[/b] Adds Supertrend alignment to distinguish strong directional pressure from noise
[*][b]Trade Mapping:[/b] Builds clean ATR-based stop and multi-target projections after confirmed breaks
[/list]

The result is a regression channel that does more than draw lines. It gives context, bias, execution framing, and visual hierarchy.

[b]Core Components Explained[/b]

[b]1. Segmented Regression Engine[/b]

[pine]
[slope, intercept, rmse] = f_ols(winLen)
basisVal = intercept + slope * float(barsInSeg - 1)
upperVal = basisVal + rmse * multiplier
lowerVal = basisVal - rmse * multiplier
[/pine]

The core engine uses manual ordinary least squares regression to calculate the channel basis. Once the segment matures, the regression values are frozen and projected forward until price resolves beyond the envelope.

This “freeze and resolve” behavior keeps the channel visually stable instead of constantly shifting every bar.

[b]2. RMSE Deviation Structure[/b]

Root mean squared error defines channel width, making the envelope responsive to how tightly price is hugging the trend.

[list]
[*]Tight RMSE = cleaner trend structure
[*]Wide RMSE = unstable or volatile structure
[*]Internal bands split the envelope into inner, quarter, and outer zones
[/list]

These nested bands create a true structure ladder instead of a single upper/lower shell.

[b]3. Premium / Discount Channel Arrays[/b]

The channel is separated into three value areas:

[list]
[*][b]Premium:[/b] Upper edge territory where price is extended and expensive relative to the current regression path
[*][b]Equilibrium:[/b] The center band around fair value and neutral orderflow balance
[*][b]Discount:[/b] Lower edge territory where price is cheap relative to the active path
[/list]

This makes the indicator more useful for directional context:

[list]
[*]Bull channels pressing premium signal strong continuation pressure
[*]Bear channels pressing discount signal strong downside control
[*]Repeated failure to hold premium/discount can signal exhaustion or rebalancing
[/list]

[b]4. Breakout Confidence Model[/b]

Breakouts are not treated equally. The indicator scores breakout quality using four ingredients:

[list]
[*][b]Participation:[/b] Distance from the regression basis normalized by ATR
[*][b]Slope Force:[/b] Strength of the normalized regression slope
[*][b]Location:[/b] Whether price is already pressing the outer structure
[*][b]Alignment:[/b] Whether price direction and Supertrend stack agree with the channel
[/list]

[pine]
breakoutConfidence = participation + slopeForce + location + alignment
[/pine]

This helps separate lazy drifts from high-quality channel resolution.

[b]5. Supertrend Ribbon Stack[/b]

The Supertrend layer is not there as a generic add-on. It acts as a second-order directional filter.

[list]
[*]Bull channel + bull Supertrend = higher-quality directional stack
[*]Bear channel + bear Supertrend = stronger downside stack
[*]When regression and Supertrend disagree, price is more likely in transition
[/list]

The fill between regression basis and Supertrend visually shows whether pressure is aligned or conflicted.

[b]6. ATR Risk Map[/b]

After a confirmed breakout, the indicator projects:

[list]
[*]1 ATR-based stop level
[*]3 reward targets using configurable risk-reward multiples
[*]Auto-expiring lines so stale trade maps are removed
[/list]

This gives the channel direct execution value instead of leaving the user to manually measure every move.

[b]Visual Elements[/b]

[list]
[*][b]Metallic Basis Line:[/b] Gold-toned centerline for the active regression basis
[*][b]Outer Deviation Shell:[/b] Main channel boundaries with glow
[*][b]Inner Structure Bands:[/b] Internal ladder for pressure staging
[*][b]Premium / Discount Fills:[/b] Separate upper and lower value zones inside the channel
[*][b]Equilibrium Fill:[/b] Neutral fair-value region
[*][b]Supertrend Ribbon:[/b] Context layer showing secondary directional alignment
[*][b]Iridescent Candles:[/b] Candle coloring that intensifies as control and confidence improve
[*][b]Breakout Markers:[/b] Compact signals for confirmed resolves
[*][b]Readiness Diamonds:[/b] Pre-break alignment markers when channel conditions are strong
[/list]

The visual hierarchy is designed so you can read the channel at a glance without relying on heavy objects or clutter.

[b]Dashboard[/b]

The dashboard is intentionally compact and fixed to the right side. It shows only the highest-signal metrics:

[list]
[*]Bias
[*]Regime
[*]Flow
[*]Channel Position
[*]Confidence
[*]Compression
[*]Trend Stack
[*]Trade Map
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Channel Bias[/b]
Check whether the regression slope is bullish or bearish. That defines the primary directional path.

[b]Step 2: Read Value Location[/b]
See whether price is trading in premium, equilibrium, or discount. This tells you whether price is extended or balanced inside the channel.

[b]Step 3: Watch Trend Stack Alignment[/b]
When Supertrend and regression agree, directional pressure is cleaner. When they disagree, reduce conviction.

[b]Step 4: Monitor Confidence[/b]
Use the breakout confidence score to judge whether price is merely drifting or building a meaningful resolution.

[b]Step 5: Trade the Resolve, Not the Noise[/b]
Use breakout markers and ATR map levels when price exits the frozen envelope with qualified pressure.

[b]Best Practices[/b]

[list]
[*]Use higher timeframes for cleaner channel geometry
[*]Treat equilibrium as fair value, not a signal by itself
[*]Bull channels work best when premium holds and pullbacks respect the inner bands
[*]Bear channels work best when discount holds and rallies fail at internal structure
[*]High compression followed by rising confidence often precedes expansion
[*]Use the risk map for framing, not blind automation
[/list]

[b]Indicator Limitations[/b]

[list]
[*]Regression is still a model of recent price, not a guarantee of future direction
[*]Sudden event-driven moves can invalidate the frozen segment quickly
[*]Premium and discount are relative to the current channel, not absolute market value
[*]High breakout confidence can still fail in thin or news-driven markets
[*]Short segments increase responsiveness but also increase noise
[/list]

[b]Technical Implementation[/b]

Built in Pine Script v6 using:

[list]
[*]Manual OLS regression
[*]RMSE deviation envelopes
[*]Segment freeze-and-resolve logic
[*]Internal quarter and inner bands
[*]Premium/discount channel zoning
[*]Supertrend stack integration
[*]Breakout confidence scoring
[*]ATR-based stop and target map
[*]Compact institutional dashboard
[/list]

[b]Originality Statement[/b]

This indicator is original in how it treats a regression channel as a full market-state framework instead of a static overlay. The value is not just in plotting upper and lower lines, but in combining:

[list]
[*]Segment freezing
[*]Internal value zoning
[*]Directional stack confirmation
[*]Breakout qualification
[*]Execution mapping
[/list]

Each layer contributes different information: regression defines path, RMSE defines structure, premium/discount defines value, Supertrend defines stack, and confidence defines quality.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Regression channels, premium/discount zones, and breakout scores are analytical tools, not guarantees of market outcome. All trading decisions remain the responsibility of the user.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Regression Deviation Channel [JOAT]", shorttitle="RDC [JOAT]", overlay=true, max_labels_count=100, max_lines_count=200)

grp_reg = "Regression Settings"
grp_risk = "Risk Framework"
grp_state = "Institutional State"
grp_vis = "Visual Settings"
grp_table = "Dashboard"

i_min_length = input.int(15, "Min Segment Length", minval=5, maxval=50, group=grp_reg)
i_max_length = input.int(200, "Max Segment Length", minval=50, maxval=500, group=grp_reg)
i_mult = input.float(1.5, "Channel Multiplier", minval=0.1, maxval=10.0, step=0.1, group=grp_reg)
i_break_buffer = input.float(0.2, "Breakout Buffer ATR", minval=0.0, maxval=5.0, step=0.1, group=grp_reg)

i_atr_period = input.int(14, "ATR Period", minval=1, maxval=100, group=grp_risk)
i_sl_atr_mult = input.float(1.5, "Stop ATR Multiplier", minval=0.1, maxval=10.0, step=0.1, group=grp_risk)
i_rr_tp1 = input.float(1.0, "TP1 R:R", minval=0.1, maxval=20.0, step=0.1, group=grp_risk)
i_rr_tp2 = input.float(2.0, "TP2 R:R", minval=0.1, maxval=20.0, step=0.1, group=grp_risk)
i_rr_tp3 = input.float(3.0, "TP3 R:R", minval=0.1, maxval=20.0, step=0.1, group=grp_risk)
i_show_tpsl = input.bool(true, "Show Active TP/SL", group=grp_risk)
i_tp_line_bars = input.int(40, "TP/SL Max Bars", minval=5, maxval=300, group=grp_risk)

i_st_period = input.int(10, "Supertrend Period", minval=1, maxval=100, group=grp_state)
i_st_mult = input.float(3.0, "Supertrend Multiplier", minval=0.1, maxval=20.0, step=0.1, group=grp_state)
i_conf_threshold = input.float(65.0, "Breakout Confidence %", minval=0.0, maxval=100.0, step=1.0, group=grp_state)

i_bull_col = input.color(#20c7b5, "Bull Color", group=grp_vis)
i_bear_col = input.color(#ff7058, "Bear Color", group=grp_vis)
i_mid_col = input.color(#d3b15f, "Midline Metallic", group=grp_vis)
i_show_marks = input.bool(true, "Show Breakout Markers", group=grp_vis)
i_show_barcolor = input.bool(true, "Show Candle Coloring", group=grp_vis)
i_show_glow = input.bool(true, "Show Channel Glow", group=grp_vis)
i_show_bg = input.bool(true, "Show Channel Background", group=grp_vis)
i_show_supertrend = input.bool(true, "Show Supertrend Ribbon", group=grp_vis)
i_show_table = input.bool(true, "Show Dashboard", group=grp_table)

f_ols(n) =>
    sampleSize = math.max(math.min(n, bar_index + 1), 2)
    float sumX = 0.0
    float sumY = 0.0
    float sumXY = 0.0
    float sumX2 = 0.0
    for i = 0 to sampleSize - 1
        x = float(sampleSize - 1 - i)
        y = close[i]
        sumX += x
        sumY += y
        sumXY += x * y
        sumX2 += x * x
    denom = float(sampleSize) * sumX2 - sumX * sumX
    slope = denom == 0.0 ? 0.0 : (float(sampleSize) * sumXY - sumX * sumY) / denom
    intercept = (sumY - slope * sumX) / float(sampleSize)
    float ssq = 0.0
    for i = 0 to sampleSize - 1
        x = float(sampleSize - 1 - i)
        pred = intercept + slope * x
        ssq += math.pow(close[i] - pred, 2.0)
    rmse = math.sqrt(ssq / float(sampleSize))
    [slope, intercept, rmse]

atrVal = ta.atr(i_atr_period)
[stLine, stDir] = ta.supertrend(i_st_mult, i_st_period)
stBull = stDir < 0

var int segStart = 0
var float frozenSlope = na
var float frozenIntercept = na
var float frozenRmse = na
var bool isFrozen = false

var int tradeDir = 0
var float stopLvl = na
var float tp1Lvl = na
var float tp2Lvl = na
var float tp3Lvl = na
var int tradeBars = 0
var line lnSl = na
var line lnTp1 = na
var line lnTp2 = na
var line lnTp3 = na

barsInSeg = bar_index - segStart + 1
winLen = math.max(i_min_length, math.min(barsInSeg, i_max_length))
[liveSlope, liveIntercept, liveRmse] = f_ols(winLen)

if not isFrozen and barstate.isconfirmed and barsInSeg >= i_min_length
    frozenSlope := liveSlope
    frozenIntercept := liveIntercept
    frozenRmse := liveRmse
    isFrozen := true

useSlope = isFrozen ? frozenSlope : liveSlope
useIntercept = isFrozen ? frozenIntercept : liveIntercept
useRmse = isFrozen ? frozenRmse : liveRmse

basisVal = useIntercept + useSlope * float(barsInSeg - 1)
upperVal = basisVal + useRmse * i_mult
lowerVal = basisVal - useRmse * i_mult
channelWidth = math.max(upperVal - lowerVal, 1e-10)
segBull = useSlope >= 0.0
breakBuffer = atrVal * i_break_buffer
normSlope = useSlope / math.max(atrVal, 1e-10)
channelPos = math.max(math.min((close - lowerVal) / channelWidth, 1.0), 0.0)
quarterUpper = basisVal + channelWidth * 0.25
quarterLower = basisVal - channelWidth * 0.25
innerUpper = basisVal + channelWidth * 0.12
innerLower = basisVal - channelWidth * 0.12
premiumFloor = upperVal - channelWidth * 0.22
discountCeiling = lowerVal + channelWidth * 0.22

breakUp = barstate.isconfirmed and isFrozen and close > upperVal + breakBuffer and close[1] <= upperVal + breakBuffer
breakDown = barstate.isconfirmed and isFrozen and close < lowerVal - breakBuffer and close[1] >= lowerVal - breakBuffer

distanceFromBasis = math.abs(close - basisVal)
trendAlignment = (segBull and close >= basisVal) or (not segBull and close <= basisVal)
structureAlignment = (segBull and stBull) or (not segBull and not stBull)
participationScore = math.min((distanceFromBasis / math.max(atrVal, 1e-10)) * 22.0, 35.0)
slopeScore = math.min(math.abs(normSlope) * 240.0, 30.0)
locationScore = channelPos >= 0.78 or channelPos <= 0.22 ? 20.0 : channelPos >= 0.65 or channelPos <= 0.35 ? 12.0 : 4.0
alignmentScore = (trendAlignment ? 8.0 : 0.0) + (structureAlignment ? 7.0 : 0.0)
breakoutConfidence = math.min(participationScore + slopeScore + locationScore + alignmentScore, 100.0)
compressionScore = math.max(0.0, 100.0 - math.min(channelWidth / math.max(atrVal, 1e-10) * 10.0, 100.0))
energyScore = math.min(distanceFromBasis / channelWidth * 100.0, 100.0)
channelControl = math.min(compressionScore * 0.35 + breakoutConfidence * 0.65, 100.0)

premiumState = close >= premiumFloor
discountState = close <= discountCeiling
equilibriumState = not premiumState and not discountState
flowState = breakoutConfidence >= 75 ? "EXPANSION" : compressionScore >= 65 ? "COIL" : "BALANCE"
regimeState = breakUp ? "BULL RESOLVE" : breakDown ? "BEAR RESOLVE" : premiumState ? "PREMIUM" : discountState ? "DISCOUNT" : "EQUILIBRIUM"
biasState = segBull ? "BULL CHANNEL" : "BEAR CHANNEL"
mapState = tradeDir == 1 ? "LONG MAP" : tradeDir == -1 ? "SHORT MAP" : "NO MAP"
qualityState = breakoutConfidence >= i_conf_threshold ? "QUALIFIED" : "BUILDING"
signalReadyLong = barstate.isconfirmed and segBull and stBull and premiumState and breakoutConfidence >= i_conf_threshold
signalReadyShort = barstate.isconfirmed and not segBull and not stBull and discountState and breakoutConfidence >= i_conf_threshold

if barstate.isconfirmed and (breakUp or breakDown)
    if not na(lnSl)
        line.delete(lnSl)
        lnSl := na
    if not na(lnTp1)
        line.delete(lnTp1)
        lnTp1 := na
    if not na(lnTp2)
        line.delete(lnTp2)
        lnTp2 := na
    if not na(lnTp3)
        line.delete(lnTp3)
        lnTp3 := na
    riskDist = atrVal * i_sl_atr_mult
    dir = breakUp ? 1 : -1
    tradeDir := dir
    stopLvl := close - dir * riskDist
    tp1Lvl := close + dir * riskDist * i_rr_tp1
    tp2Lvl := close + dir * riskDist * i_rr_tp2
    tp3Lvl := close + dir * riskDist * i_rr_tp3
    tradeBars := 0
    if i_show_tpsl
        tpCol = dir == 1 ? i_bull_col : i_bear_col
        lnSl := line.new(bar_index, stopLvl, bar_index + 1, stopLvl, color=color.new(i_bear_col, 20), width=1, style=line.style_dashed)
        lnTp1 := line.new(bar_index, tp1Lvl, bar_index + 1, tp1Lvl, color=color.new(tpCol, 25), width=1, style=line.style_dashed)
        lnTp2 := line.new(bar_index, tp2Lvl, bar_index + 1, tp2Lvl, color=color.new(tpCol, 10), width=1, style=line.style_dashed)
        lnTp3 := line.new(bar_index, tp3Lvl, bar_index + 1, tp3Lvl, color=color.new(tpCol, 0), width=1, style=line.style_dotted)
    segStart := bar_index
    isFrozen := false
    frozenSlope := na
    frozenIntercept := na
    frozenRmse := na
else if barstate.isconfirmed and tradeDir != 0
    tradeBars += 1
    stopHit = tradeDir == 1 ? low <= stopLvl : high >= stopLvl
    tpHit = tradeDir == 1 ? high >= tp3Lvl : low <= tp3Lvl
    expired = tradeBars > i_tp_line_bars
    if stopHit or tpHit or expired
        if not na(lnSl)
            line.delete(lnSl)
            lnSl := na
        if not na(lnTp1)
            line.delete(lnTp1)
            lnTp1 := na
        if not na(lnTp2)
            line.delete(lnTp2)
            lnTp2 := na
        if not na(lnTp3)
            line.delete(lnTp3)
            lnTp3 := na
        tradeDir := 0
        stopLvl := na
        tp1Lvl := na
        tp2Lvl := na
        tp3Lvl := na
        tradeBars := 0
    else
        if not na(lnSl)
            line.set_x2(lnSl, bar_index + 1)
        if not na(lnTp1)
            line.set_x2(lnTp1, bar_index + 1)
        if not na(lnTp2)
            line.set_x2(lnTp2, bar_index + 1)
        if not na(lnTp3)
            line.set_x2(lnTp3, bar_index + 1)

chanCol = segBull ? i_bull_col : i_bear_col
metalBull = color.rgb(32, 199, 181)
metalBear = color.rgb(255, 112, 88)
iridescentBull = color.rgb(113, 255, 233)
iridescentBear = color.rgb(255, 166, 138)
metalStrength = math.min(channelControl / 100.0, 1.0)
barBaseCol = segBull ? color.from_gradient(channelPos, 0.0, 1.0, color.new(metalBull, 10), iridescentBull) : color.from_gradient(channelPos, 0.0, 1.0, iridescentBear, color.new(metalBear, 10))
barCol = i_show_barcolor ? color.from_gradient(metalStrength, 0.0, 1.0, color.new(barBaseCol, 55), barBaseCol) : na
barcolor(barCol, title="RDC Candle Color")

plot(i_show_glow ? basisVal : na, "Basis Glow Outer", color=color.new(chanCol, 91), linewidth=7)
plot(i_show_glow ? basisVal : na, "Basis Glow Mid", color=color.new(i_mid_col, 82), linewidth=4)
pBasis = plot(basisVal, "Regression Basis", color=color.new(i_mid_col, 0), linewidth=2)
plot(i_show_glow ? upperVal : na, "Upper Glow", color=color.new(chanCol, 84), linewidth=5)
plot(i_show_glow ? lowerVal : na, "Lower Glow", color=color.new(chanCol, 84), linewidth=5)
pUpper = plot(upperVal, "Upper Deviation", color=color.new(chanCol, 5), linewidth=2)
pLower = plot(lowerVal, "Lower Deviation", color=color.new(chanCol, 5), linewidth=2)
pQuarterUpper = plot(quarterUpper, "Upper Quarter", color=color.new(i_bull_col, 80), linewidth=1)
pQuarterLower = plot(quarterLower, "Lower Quarter", color=color.new(i_bear_col, 80), linewidth=1)
pInnerUpper = plot(innerUpper, "Inner Upper", color=color.new(i_mid_col, 85), linewidth=1)
pInnerLower = plot(innerLower, "Inner Lower", color=color.new(i_mid_col, 85), linewidth=1)
pPremiumFloor = plot(premiumFloor, "Premium Floor", color=color.new(i_bull_col, 70), linewidth=1)
pDiscountCeiling = plot(discountCeiling, "Discount Ceiling", color=color.new(i_bear_col, 70), linewidth=1)
pSupertrend = plot(i_show_supertrend ? stLine : na, "Supertrend Ribbon", color=color.new(stBull ? i_bull_col : i_bear_col, 45), linewidth=2)

fill(pBasis, pInnerUpper, color=color.new(segBull ? i_bull_col : i_bear_col, 93), title="Inner Upper Fill")
fill(pBasis, pInnerLower, color=color.new(segBull ? i_bull_col : i_bear_col, 93), title="Inner Lower Fill")
fill(pInnerUpper, pQuarterUpper, color=color.new(i_bull_col, 90), title="Upper Gradient Fill")
fill(pInnerLower, pQuarterLower, color=color.new(i_bear_col, 90), title="Lower Gradient Fill")
fill(pQuarterUpper, pUpper, color=color.new(i_bull_col, 95), title="Upper Exhaustion Fill")
fill(pQuarterLower, pLower, color=color.new(i_bear_col, 95), title="Lower Exhaustion Fill")
fill(pUpper, pPremiumFloor, color=color.new(i_bull_col, 91), title="Premium Zone Fill")
fill(pDiscountCeiling, pLower, color=color.new(i_bear_col, 91), title="Discount Zone Fill")
fill(pPremiumFloor, pDiscountCeiling, color=color.new(i_mid_col, 96), title="Equilibrium Fill")
fill(pBasis, pSupertrend, color=color.new(stBull ? i_bull_col : i_bear_col, 94), title="Trend Ribbon Fill")

bgcolor(i_show_bg and premiumState ? color.new(i_bull_col, 95) : na, title="Premium Background")
bgcolor(i_show_bg and discountState ? color.new(i_bear_col, 95) : na, title="Discount Background")
bgcolor(i_show_bg and breakoutConfidence >= 80 ? color.new(segBull ? i_bull_col : i_bear_col, 96) : na, title="Breakout Confidence Background")

plotshape(i_show_marks and breakUp, "Break Up", style=shape.triangleup, location=location.belowbar, color=i_bull_col, size=size.small, text="RDC")
plotshape(i_show_marks and breakDown, "Break Down", style=shape.triangledown, location=location.abovebar, color=i_bear_col, size=size.small, text="RDC")
plotshape(i_show_marks and signalReadyLong and not breakUp, "Long Ready", style=shape.diamond, location=location.belowbar, color=color.new(iridescentBull, 10), size=size.tiny)
plotshape(i_show_marks and signalReadyShort and not breakDown, "Short Ready", style=shape.diamond, location=location.abovebar, color=color.new(iridescentBear, 10), size=size.tiny)

var table dash = na
if i_show_table
    if na(dash)
        dash := table.new(position.top_right, 2, 9, bgcolor=#171a28, border_color=#343850, border_width=1, frame_color=#424963, frame_width=1)
    if barstate.islast
        sz = size.normal
        table.cell(dash, 0, 0, "RDC [JOAT]", text_color=#ffd770, text_size=sz, bgcolor=#0d0f18, text_halign=text.align_center)
        table.cell(dash, 1, 0, "VALUE", text_color=#c7cbe2, text_size=sz, bgcolor=#0d0f18, text_halign=text.align_center)
        table.cell(dash, 0, 1, "Bias", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 1, biasState, text_color=chanCol, text_size=sz, bgcolor=#131726)
        table.cell(dash, 0, 2, "Regime", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 2, regimeState, text_color=premiumState ? i_bull_col : discountState ? i_bear_col : i_mid_col, text_size=sz, bgcolor=#131726)
        table.cell(dash, 0, 3, "Flow", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 3, flowState, text_color=breakoutConfidence >= 75 ? #ffd770 : #d7d9e6, text_size=sz, bgcolor=#131726)
        table.cell(dash, 0, 4, "Channel Pos", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 4, str.tostring(channelPos * 100.0, "#.0") + "%", text_color=channelPos >= 0.5 ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#131726)
        table.cell(dash, 0, 5, "Confidence", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 5, str.tostring(breakoutConfidence, "#.0") + "%", text_color=breakoutConfidence >= i_conf_threshold ? #ffd770 : #d7d9e6, text_size=sz, bgcolor=#131726)
        table.cell(dash, 0, 6, "Compression", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 6, str.tostring(compressionScore, "#.0") + "%", text_color=#ffd770, text_size=sz, bgcolor=#131726)
        table.cell(dash, 0, 7, "Trend Stack", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 7, stBull ? "BULL STACK" : "BEAR STACK", text_color=stBull ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#131726)
        table.cell(dash, 0, 8, "Trade Map", text_color=#a9b0c8, text_size=sz, bgcolor=#131726)
        table.cell(dash, 1, 8, mapState, text_color=tradeDir == 1 ? i_bull_col : tradeDir == -1 ? i_bear_col : #d7d9e6, text_size=sz, bgcolor=#131726)

alertcondition(breakUp, "RDC: Channel Break Up", "RDC [JOAT]: price broke above the upper channel.")
alertcondition(breakDown, "RDC: Channel Break Down", "RDC [JOAT]: price broke below the lower channel.")
alertcondition(signalReadyLong, "RDC: Long Pressure Ready", "RDC [JOAT]: bullish pressure alignment reached confidence threshold.")
alertcondition(signalReadyShort, "RDC: Short Pressure Ready", "RDC [JOAT]: bearish pressure alignment reached confidence threshold.")
````

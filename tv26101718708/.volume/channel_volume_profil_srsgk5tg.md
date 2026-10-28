# Channel Volume Profil

- url: https://www.tradingview.com/script/sRSgk5tG-Channel-Volume-Profil/
- type: indicator
- pine_id: PUB;7190ef9e0f6c470297a783bcd72214a4
- version: 1.0

## Description

wizard channel vp idm is a visual analysis tool built around a dynamic price channel, an anchored volume profile, value area levels, volume nodes, inducement zones, liquidity sweeps, and confluence labels.

the purpose of this indicator is to help traders read where price is positioned inside an active market structure. it combines channel direction, volume acceptance, value area behavior, and liquidity reactions into one clean visual layout.

this indicator does not predict the market. it is designed to organize technical analysis and highlight areas where price may react, slow down, reject, or continue.

main concept

the script builds a dynamic channel around price using a regression-based structure. inside this channel, it calculates an anchored volume profile that follows the slope of the market.

unlike a classic horizontal volume profile, this profile is projected inside the active channel. when the market is rising, the profile follows the upward slope. when the market is falling, the profile follows the downward slope.

this makes the profile easier to read in trending conditions, because the volume zones stay aligned with the current market path.

what the indicator displays

poc

poc stands for point of control. it marks the area with the highest volume inside the profile. this is often an area of acceptance where price may return, pause, or consolidate.

vah

vah stands for value area high. it is the upper boundary of the value area. if price rejects this level, a move back toward the poc may be watched. if price accepts above it, the market may be trying to expand higher.

val

val stands for value area low. it is the lower boundary of the value area. if price rejects this level, a move back toward the poc may be watched. if price accepts below it, the market may be trying to expand lower.

hvn

hvn stands for high volume node. it marks an area where volume concentration is high. these levels may act as areas of acceptance, reaction, or slowdown.

lvn

lvn stands for low volume node. it marks an area where volume concentration is low. these levels may act as fast movement zones, rejection zones, or imbalance areas.

idm

idm represents an internal inducement area. it helps identify internal liquidity zones that may be swept before a reaction or continuation.

drop marker

the drop marker highlights a possible liquidity sweep. it appears when price takes a level or zone and then moves back inside.

a label

the a label is a confluence marker. it combines several conditions such as sweep, rejection, value area interaction, volume behavior, poc reclaim, and structure context. it should not be used alone. it is a visual signal for deeper analysis.

how to use the indicator

start by looking at the channel direction.

if the channel is rising, the trader can focus more on reactions near the lower part of the channel, val, or bullish sweep zones.

if the channel is falling, the trader can focus more on reactions near the upper part of the channel, vah, or bearish sweep zones.

if price is near the middle of the channel, the market may be balanced. in that case, it is usually better to wait for a clear rejection, breakout, sweep, or acceptance shift.

how to use the poc

the poc is the main acceptance level of the current profile.

when price is above the poc, the market may be accepting higher prices.

when price is below the poc, the market may be accepting lower prices.

when price keeps returning to the poc, the market may be consolidating or building balance.

a clean break and hold above the poc can show stronger bullish acceptance.

a clean break and hold below the poc can show weaker structure or bearish acceptance.

how to use vah and val

vah and val define the value area.

a rejection from vah can show that price is failing to accept higher levels.

a rejection from val can show that price is failing to accept lower levels.

an acceptance above vah can suggest expansion to the upside.

an acceptance below val can suggest expansion to the downside.

beginners can use vah, poc, and val as a simple map:

vah = upper value zone

poc = balance zone

val = lower value zone

how to use hvn and lvn

hvn and lvn are displayed as small dotted levels with tiny labels.

hvn can act as a reaction or slowdown zone because price has previously accepted volume there.

lvn can act as a faster movement zone because there was less volume acceptance there.

these levels are not automatic buy or sell signals. they are reference points that should be combined with price action, structure, and risk management.

how to use idm

idm labels show internal inducement areas.

an idm can represent a zone where liquidity was built and later taken by the market. when price sweeps an idm and then reintegrates, it may help explain a reaction or shift in behavior.

an idm near val may support a bullish reaction if price sweeps and returns inside the channel.

an idm near vah may support a bearish reaction if price sweeps and returns inside the channel.

how to use the drop marker

the drop marker shows a potential liquidity sweep.

a drop below val or below the lower channel can suggest that price swept lower liquidity and then returned inside.

a drop above vah or above the upper channel can suggest that price swept upper liquidity and then returned inside.

it is usually better to wait for candle close before interpreting the marker.

how to use the a label

the a label represents a stronger confluence condition.

a bullish a near val or the lower channel can suggest possible absorption if price sweeps liquidity and closes back inside.

a bearish a near vah or the upper channel can suggest possible distribution if price sweeps liquidity and closes back inside.

the a label becomes more meaningful when it appears near poc, vah, val, hvn, lvn, or idm.

it should always be confirmed with market context, candle close, and risk management.

important settings

channel / vp lookback

controls how many bars are used for the channel and the volume profile. a higher value gives a broader view. a lower value gives a more reactive view.

regression length

controls the base of the channel. a higher value makes the channel smoother. a lower value makes it react faster to recent price movement.

vp rows

controls the number of rows in the volume profile. more rows create more detail, but too many rows can make the chart heavier.

value area %

controls the value area calculation. the common default is 70.

poc source

chooses how the poc is calculated. raw is stricter. smoothed is more stable visually.

vah / val source

chooses whether value area boundaries use raw volume or smoothed volume.

keep vp / levels inside rails

keeps the volume profile and main levels inside the channel so they do not overlap the outer rail visuals.

auto guard from neon rails

adds extra spacing from the visual rail bands to keep the profile and levels clean.

show inner lines

shows or hides decorative inner channel lines. when disabled, inner decorative lines are removed, while important levels such as poc, vah, val, hvn, and lvn remain visible.

show hvn / lvn small lines

shows small dotted high volume node and low volume node markers.

idm validation mode

controls how idm labels are displayed.

balanced sweep is more flexible.

strict bos is more selective.

early candidate displays potential idm areas earlier.

a minimum score

controls how selective the a label is. a higher value gives fewer signals. a lower value gives more signals.

beginner workflow

step 1

identify the channel direction.

if the channel is rising, focus on bullish reactions near the lower channel, val, or sweep zones.

if the channel is falling, focus on bearish reactions near the upper channel, vah, or sweep zones.

step 2

check where price is compared to the poc.

above poc can show stronger acceptance.

below poc can show weaker acceptance.

around poc can show balance or consolidation.

step 3

watch vah and val.

vah is the upper value boundary.

val is the lower value boundary.

look for rejection, acceptance, or sweep around these levels.

step 4

use hvn and lvn as reaction levels.

hvn may slow price down.

lvn may lead to faster movement or sharp rejection.

step 5

wait for confirmation.

a drop marker shows a sweep.

an a label shows confluence.

an idm label shows internal liquidity.

when several elements appear in the same area, that zone becomes more important for analysis.

example use case

price is rising inside the channel.

price pulls back toward val.

a drop marker appears below val.

price closes back inside the channel.

an a label appears near the lower channel.

in this case, the trader can study the area as a possible bullish reaction zone. this does not mean automatic entry. the trader should still check market structure, candle close, risk, and invalidation level.

another example

price reaches the upper channel and trades near vah.

a drop marker appears above vah.

price closes back below vah.

an a label appears near the top of the channel.

this can be studied as a possible rejection zone. the trader should still confirm with structure, risk management, and broader market direction.

usage tips

do not use the indicator alone.

always check the broader trend.

wait for candle close before making a decision.

avoid trading every label.

focus on zones where several elements align.

adjust settings depending on the asset and timeframe.

use proper risk management.

test the indicator before using it in live conditions.

risk notice

this indicator is an educational and technical analysis tool. it is not financial advice and does not guarantee any result. all signals and levels should be used as visual references inside a complete trading plan. every trader is responsible for their own decisions, risk management, and execution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("CHANNEL VP", "CHVP", overlay=true, max_bars_back=1500, max_lines_count=500, max_labels_count=500, max_polylines_count=100)

gCore = "01. Core Channel"
lookback = input.int(220, "Channel / VP Lookback", minval=60, maxval=500, group=gCore)
projection = input.int(55, "Right Projection Bars", minval=10, maxval=150, group=gCore)
regLen = input.int(160, "Regression Length", minval=30, maxval=500, group=gCore)
resMult = input.float(1.15, "Residual Width Multiplier", minval=0.50, maxval=3.00, step=0.05, group=gCore)
smoothSlope = input.int(5, "Slope Smooth", minval=1, maxval=30, group=gCore)

gVP = "02. Anchored VP PRO"
showVP = input.bool(true, "Show Anchored VP", group=gVP)
bins = input.int(42, "VP Rows", minval=12, maxval=70, group=gVP)
valueAreaPct = input.float(70.0, "Value Area %", minval=50.0, maxval=95.0, step=0.5, group=gVP)
profileMaxBars = input.int(95, "VP Max Width Bars", minval=10, maxval=180, group=gVP)
profileMinRatio = input.float(0.015, "Min Visible Width Ratio", minval=0.0, maxval=0.20, step=0.005, group=gVP)
vpKeepInside = input.bool(true, "Keep VP / Levels Inside Rails", group=gVP)
vpInnerPadding = input.float(0.025, "Inner Rail Padding", minval=0.000, maxval=0.120, step=0.005, group=gVP)
vpAutoRailGuard = input.bool(true, "Auto Guard From Neon Rails", group=gVP)
vpRailExtraPadding = input.float(0.020, "Extra Rail Gap", minval=0.000, maxval=0.080, step=0.005, group=gVP)
profileBorder = input.bool(true, "VP Polygon Border", group=gVP)
profileMidLine = input.bool(false, "VP Row Inner Line", group=gVP)
pocSource = input.string("Smoothed", "POC Source", options=["Raw", "Smoothed"], group=gVP)
vaSource = input.string("Raw", "VAH / VAL Source", options=["Raw", "Smoothed"], group=gVP)
pocTiePct = input.float(1.50, "POC Tie Tolerance %", minval=0.0, maxval=10.0, step=0.25, group=gVP)
vpSmoothSideWeight = input.float(0.25, "VP Smoothing Side Weight", minval=0.00, maxval=0.45, step=0.05, group=gVP)

gVPF = "03. VP Precision Filters"
vpConfirmedOnly = input.bool(true, "Use Confirmed Bars Only", group=gVPF)
vpFilterMode = input.string("All volume", "Volume Filter Mode", options=["All volume", "Above volume MA", "Below volume MA"], group=gVPF)
vpVolMaLen = input.int(30, "Volume MA Length", minval=5, maxval=300, group=gVPF)
vpMinVolMult = input.float(0.70, "Volume MA Filter Multiplier", minval=0.05, maxval=5.00, step=0.05, group=gVPF)
vpClampOutliers = input.bool(true, "Clamp Extreme Volume Outliers", group=gVPF)
vpMaxVolMult = input.float(3.50, "Max Volume Cap vs MA", minval=1.00, maxval=20.00, step=0.25, group=gVPF)
vpBodyWeight = input.float(0.35, "Body Precision Weight", minval=0.00, maxval=1.00, step=0.05, group=gVPF)

gHVN = "04. HVN / LVN"
showHVNLVN = input.bool(true, "Show HVN / LVN Small Lines", group=gHVN)
hvnThreshold = input.float(0.62, "HVN Min Ratio", minval=0.10, maxval=1.00, step=0.01, group=gHVN)
lvnThreshold = input.float(0.28, "LVN Max Ratio", minval=0.01, maxval=0.80, step=0.01, group=gHVN)
hvnLvnLineLen = input.int(8, "HVN / LVN Small Line Length", minval=2, maxval=30, group=gHVN)
hvnLvnMinSpacing = input.int(3, "HVN / LVN Min Row Spacing", minval=1, maxval=20, group=gHVN)
showHVNLVNText = input.bool(true, "Show HVN / LVN Tiny Labels", group=gHVN)
hvnLvnLabelOffset = input.int(1, "HVN / LVN Label Offset", minval=0, maxval=10, group=gHVN)
maxHVNLVNLabels = input.int(10, "Max HVN / LVN Marks", minval=0, maxval=30, group=gHVN)

gVisual = "05. Visual"
showGlow = input.bool(true, "Show Neon Rails", group=gVisual)
glowLayers = input.int(13, "Neon Layers", minval=3, maxval=25, group=gVisual)
railBandPct = input.float(0.065, "Rail Band Thickness", minval=0.01, maxval=0.20, step=0.005, group=gVisual)
showInterior = input.bool(true, "Show Inner Lines", group=gVisual)
interiorLines = input.int(18, "Inner Density", minval=6, maxval=40, group=gVisual)
showRightLabels = input.bool(true, "Show VAH / POC / VAL Labels", group=gVisual)
showChannelMid = input.bool(true, "Show Channel Midline", group=gVisual)
rightLabelOffset = input.int(0, "Right Label Offset", minval=0, maxval=20, group=gVisual)
rightLabelStep = input.int(6, "Right Label Step Bars", minval=2, maxval=12, group=gVisual)
extendLevelsToLabels = input.bool(true, "Extend VAH / POC / VAL To Labels", group=gVisual)
colTop = input.color(color.rgb(255, 0, 190), "Upper Rail Magenta", group=gVisual)
colBottom = input.color(color.rgb(0, 220, 210), "Lower Rail Cyan", group=gVisual)
colPoc = input.color(color.rgb(0, 165, 255), "POC Blue", group=gVisual)
colPanel = input.color(color.rgb(0, 42, 78), "Interior Blue", group=gVisual)
colVahVal = input.color(color.rgb(0, 190, 255), "VAH / VAL", group=gVisual)

gStruct = "06. Structure / IDM PRO"
showIDM = input.bool(true, "Show Validated IDM", group=gStruct)
idmMode = input.string("Balanced Sweep", "IDM Validation Mode", options=["Strict BOS", "Balanced Sweep", "Early Candidate"], group=gStruct)
pivotLeft = input.int(3, "Pivot Left", minval=1, maxval=12, group=gStruct)
pivotRight = input.int(3, "Pivot Right", minval=1, maxval=12, group=gStruct)
idmAtrFilter = input.float(0.15, "Min Pivot Distance ATR", minval=0.0, maxval=3.0, step=0.05, group=gStruct)
idmSweepTolAtr = input.float(0.02, "IDM Sweep Tolerance ATR", minval=0.0, maxval=1.0, step=0.01, group=gStruct)
idmConfluenceBars = input.int(28, "IDM Confluence Window", minval=3, maxval=100, group=gStruct)
idmMinSpacing = input.int(8, "IDM Min Spacing Bars", minval=1, maxval=50, group=gStruct)
maxIDMLabels = input.int(32, "Max IDM Labels", minval=5, maxval=120, group=gStruct)

gSignals = "07. Sweep / A PRO"
showDrops = input.bool(true, "Show Sweep Drops", group=gSignals)
showA = input.bool(true, "Show A Confluence Labels", group=gSignals)
showAScore = input.bool(false, "Show A Score Text", group=gSignals)
aMinScore = input.int(60, "A Minimum Score", minval=30, maxval=100, group=gSignals)
aRequireDirection = input.bool(false, "A Requires Candle Direction", group=gSignals)
touchPct = input.float(0.055, "Rail Touch Tolerance", minval=0.005, maxval=0.25, step=0.005, group=gSignals)
wickMult = input.float(1.15, "Wick Rejection Multiplier", minval=0.20, maxval=5.0, step=0.05, group=gSignals)
signalMinSpacing = input.int(8, "Signal Min Spacing Bars", minval=1, maxval=50, group=gSignals)
useVolFilter = input.bool(false, "Use Volume Filter For A", group=gSignals)
volLen = input.int(30, "Signal Volume MA Length", minval=5, maxval=200, group=gSignals)
volMult = input.float(1.05, "Signal Volume Multiplier", minval=0.1, maxval=5.0, step=0.05, group=gSignals)
maxSignalLabels = input.int(35, "Max A / Drop Labels", minval=5, maxval=150, group=gSignals)

gAlerts = "08. Alerts"
enableAlerts = input.bool(true, "Enable Alert Conditions", group=gAlerts)

var array<line> lines = array.new<line>()
var array<label> labels = array.new<label>()
var array<polyline> polys = array.new<polyline>()
var array<float> volBins = array.new<float>()
var array<float> smoothBins = array.new<float>()

f_clear_lines(array<line> a) =>
    while array.size(a) > 0
        line.delete(array.pop(a))

f_clear_labels(array<label> a) =>
    while array.size(a) > 0
        label.delete(array.pop(a))

f_clear_polys(array<polyline> a) =>
    while array.size(a) > 0
        polyline.delete(array.pop(a))

f_clampf(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_clampi(float v, int lo, int hi) =>
    int(math.round(math.max(lo, math.min(hi, v))))

f_y(float basisNow, float slopeNow, float botOffNow, float rngNow, float frac, int rel) =>
    basisNow + slopeNow * rel + botOffNow + rngNow * frac

f_guard_x(int x) =>
    int(math.min(x, bar_index + 490))

f_safe_frac(float frac, float pad, bool enabled, float railPad, bool autoGuard) =>
    float p = autoGuard ? math.max(pad, railPad) : pad
    enabled ? f_clampf(frac, p, 1.0 - p) : frac

f_arr_get(array<float> raw, array<float> sm, int idx, bool useSmooth) =>
    useSmooth ? array.get(sm, idx) : array.get(raw, idx)

f_push_line(int x1, float y1, int x2, float y2, color c, int w, st) =>
    array.push(lines, line.new(x1, y1, x2, y2, xloc=xloc.bar_index, extend=extend.none, color=c, width=w, style=st))

f_push_label(int x, float y, string txt, st, color bg, color tc, sz) =>
    array.push(labels, label.new(x=x, y=y, text=txt, xloc=xloc.bar_index, yloc=yloc.price, style=st, color=bg, textcolor=tc, size=sz))

f_push_poly(int x1, float yTop1, int x2, float yTop2, int x3, float yBot3, int x4, float yBot4, color fillC, color lineC) =>
    array<chart.point> pts = array.new<chart.point>()
    array.push(pts, chart.point.from_index(x1, yTop1))
    array.push(pts, chart.point.from_index(x2, yTop2))
    array.push(pts, chart.point.from_index(x3, yBot3))
    array.push(pts, chart.point.from_index(x4, yBot4))
    polyline p = polyline.new(pts, curved=false, closed=true, xloc=xloc.bar_index, line_color=lineC, fill_color=fillC, line_style=line.style_solid, line_width=1)
    array.push(polys, p)

f_add_volume(array<float> a, float loNIn, float hiNIn, float volIn, int nBins) =>
    float aN = f_clampf(math.min(loNIn, hiNIn), 0.0, 0.999999)
    float zN = f_clampf(math.max(loNIn, hiNIn), 0.0, 0.999999)
    if volIn > 0.0
        if math.abs(zN - aN) <= 0.0000001
            int idx = f_clampi(math.floor(aN * nBins), 0, nBins - 1)
            array.set(a, idx, array.get(a, idx) + volIn)
        else
            int loBin = f_clampi(math.floor(aN * nBins), 0, nBins - 1)
            int hiBin = f_clampi(math.floor(zN * nBins), 0, nBins - 1)
            float usedWeight = 0.0
            for vb = loBin to hiBin
                float binLo = vb / nBins
                float binHi = (vb + 1.0) / nBins
                float overlap = math.max(0.0, math.min(zN, binHi) - math.max(aN, binLo))
                usedWeight += overlap
            float normWeight = usedWeight > 0.0 ? usedWeight : math.max(zN - aN, 1.0 / nBins)
            for vb = loBin to hiBin
                float binLo = vb / nBins
                float binHi = (vb + 1.0) / nBins
                float overlap = math.max(0.0, math.min(zN, binHi) - math.max(aN, binLo))
                float addV = volIn * overlap / normWeight
                array.set(a, vb, array.get(a, vb) + addV)
    0

basis = ta.linreg(close, regLen, 0)
basisPrev = ta.linreg(close, regLen, 1)
rawSlope = basis - basisPrev
slope = ta.sma(rawSlope, smoothSlope)
resHi = high - basis
resLo = low - basis
topOffRaw = ta.highest(resHi, lookback) * resMult
botOffRaw = ta.lowest(resLo, lookback) * resMult
topOff = math.max(topOffRaw, syminfo.mintick * 10)
botOff = math.min(botOffRaw, -syminfo.mintick * 10)
rng = math.max(topOff - botOff, syminfo.mintick * 20)
atr = ta.atr(14)
volMa = ta.sma(volume, volLen)
vpVolMa = ta.sma(volume, vpVolMaLen)
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)
ready = not na(basis) and not na(slope) and not na(topOff) and not na(botOff) and rng > 0.0

topNow = basis + topOff
botNow = basis + botOff
bodyNow = math.max(math.abs(close - open), syminfo.mintick)
upperWickNow = high - math.max(open, close)
lowerWickNow = math.min(open, close) - low
volOkNow = not useVolFilter or volume > volMa * volMult
bullSweepNow = ready and barstate.isconfirmed and low <= botNow + rng * touchPct and close > botNow and lowerWickNow >= bodyNow * wickMult
bearSweepNow = ready and barstate.isconfirmed and high >= topNow - rng * touchPct and close < topNow and upperWickNow >= bodyNow * wickMult
bullANow = bullSweepNow and close > open and volOkNow
bearANow = bearSweepNow and close < open and volOkNow

alertcondition(enableAlerts and bullANow, "WIZARD V3 RG — Bull A Live", "Bull A live confluence: lower rail rejection confirmed.")
alertcondition(enableAlerts and bearANow, "WIZARD V3 RG — Bear A Live", "Bear A live confluence: upper rail rejection confirmed.")
alertcondition(enableAlerts and bullSweepNow, "WIZARD V3 RG — Bull Sweep Live", "Bullish liquidity sweep / lower rail rejection confirmed.")
alertcondition(enableAlerts and bearSweepNow, "WIZARD V3 RG — Bear Sweep Live", "Bearish liquidity sweep / upper rail rejection confirmed.")

if barstate.islast
    f_clear_lines(lines)
    f_clear_labels(labels)
    f_clear_polys(polys)
    array.clear(volBins)
    array.clear(smoothBins)
    int barsUsed = math.min(lookback, bar_index + 1)
    float railSafePad = railBandPct + vpRailExtraPadding
    if ready and barsUsed > 20
        for b = 0 to bins - 1
            array.push(volBins, 0.0)
            array.push(smoothBins, 0.0)

        for j = 0 to barsUsed - 1
            bool confirmedOk = not (vpConfirmedOnly and j == 0 and not barstate.isconfirmed)
            float vRaw = nz(volume[j], 0.0)
            float vMaJ = nz(vpVolMa[j], vRaw)
            bool modeOk = vpFilterMode == "All volume" or (vpFilterMode == "Above volume MA" and vRaw >= vMaJ * vpMinVolMult) or (vpFilterMode == "Below volume MA" and vRaw <= vMaJ * vpMinVolMult)
            float vCap = vpClampOutliers ? math.min(vRaw, vMaJ * vpMaxVolMult) : vRaw
            float vUse = confirmedOk and modeOk ? vCap : 0.0
            if vUse > 0.0
                float midJ = basis - slope * j
                float botJ = midJ + botOff
                float rangeLoN = f_clampf((low[j] - botJ) / rng, 0.0, 0.999999)
                float rangeHiN = f_clampf((high[j] - botJ) / rng, 0.0, 0.999999)
                float bodyLow = math.min(open[j], close[j])
                float bodyHigh = math.max(open[j], close[j])
                float bodyLoN = f_clampf((bodyLow - botJ) / rng, 0.0, 0.999999)
                float bodyHiN = f_clampf((bodyHigh - botJ) / rng, 0.0, 0.999999)
                float rangeVol = vUse * (1.0 - vpBodyWeight)
                float bodyVol = vUse * vpBodyWeight
                f_add_volume(volBins, rangeLoN, rangeHiN, rangeVol, bins)
                f_add_volume(volBins, bodyLoN, bodyHiN, bodyVol, bins)

        float sideW = vpSmoothSideWeight
        float midW = math.max(0.0, 1.0 - sideW * 2.0)
        for b = 0 to bins - 1
            float left = b > 0 ? array.get(volBins, b - 1) : array.get(volBins, b)
            float mid = array.get(volBins, b)
            float right = b < bins - 1 ? array.get(volBins, b + 1) : array.get(volBins, b)
            array.set(smoothBins, b, left * sideW + mid * midW + right * sideW)

        bool pocUseSmooth = pocSource == "Smoothed"
        bool vaUseSmooth = vaSource == "Smoothed"
        float totalVol = 0.0
        float totalVaVol = 0.0
        float maxVol = 0.0
        float maxPocVol = -1.0
        int pocIdx = 0
        float curNorm = f_clampf((close - (basis + botOff)) / rng, 0.0, 0.999999)
        float bestDist = 10.0
        for b = 0 to bins - 1
            float rawB = array.get(volBins, b)
            float pocB = f_arr_get(volBins, smoothBins, b, pocUseSmooth)
            float vaB = f_arr_get(volBins, smoothBins, b, vaUseSmooth)
            totalVol += rawB
            totalVaVol += vaB
            maxVol := math.max(maxVol, rawB)
            float distB = math.abs((b + 0.5) / bins - curNorm)
            bool stronger = pocB > maxPocVol
            bool tie = maxPocVol > 0.0 and math.abs(pocB - maxPocVol) / maxPocVol <= pocTiePct * 0.01 and distB < bestDist
            if stronger or tie
                maxPocVol := pocB
                pocIdx := b
                bestDist := distB

        int valIdx = pocIdx
        int vahIdx = pocIdx
        float vaTarget = totalVaVol * valueAreaPct * 0.01
        float vaVol = totalVaVol > 0.0 ? f_arr_get(volBins, smoothBins, pocIdx, vaUseSmooth) : 0.0
        while vaVol < vaTarget and (valIdx > 0 or vahIdx < bins - 1)
            bool canLeft = valIdx > 0
            bool canRight = vahIdx < bins - 1
            float leftV = canLeft ? f_arr_get(volBins, smoothBins, valIdx - 1, vaUseSmooth) : -1.0
            float rightV = canRight ? f_arr_get(volBins, smoothBins, vahIdx + 1, vaUseSmooth) : -1.0
            int leftDist = canLeft ? math.abs((valIdx - 1) - pocIdx) : 100000
            int rightDist = canRight ? math.abs((vahIdx + 1) - pocIdx) : 100000
            bool chooseRight = canRight and (not canLeft or rightV > leftV or (rightV == leftV and rightDist <= leftDist))
            if chooseRight
                vahIdx += 1
                vaVol += f_arr_get(volBins, smoothBins, vahIdx, vaUseSmooth)
            else if canLeft
                valIdx -= 1
                vaVol += f_arr_get(volBins, smoothBins, valIdx, vaUseSmooth)

        float pocFracRaw = totalVol > 0.0 ? (pocIdx + 0.5) / bins : 0.5
        float vahFracRaw = totalVol > 0.0 ? (vahIdx + 0.5) / bins : 0.70
        float valFracRaw = totalVol > 0.0 ? (valIdx + 0.5) / bins : 0.30
        float pocFrac = f_safe_frac(pocFracRaw, vpInnerPadding, vpKeepInside, railSafePad, vpAutoRailGuard)
        float vahFrac = f_safe_frac(vahFracRaw, vpInnerPadding, vpKeepInside, railSafePad, vpAutoRailGuard)
        float valFrac = f_safe_frac(valFracRaw, vpInnerPadding, vpKeepInside, railSafePad, vpAutoRailGuard)

        int xL = bar_index - barsUsed + 1
        int xR = bar_index + projection
        int relL = xL - bar_index
        int relR = projection
        float topL = f_y(basis, slope, botOff, rng, 1.0, relL)
        float topR = f_y(basis, slope, botOff, rng, 1.0, relR)
        float botL = f_y(basis, slope, botOff, rng, 0.0, relL)
        float botR = f_y(basis, slope, botOff, rng, 0.0, relR)
        float midL = f_y(basis, slope, botOff, rng, 0.5, relL)
        float midR = f_y(basis, slope, botOff, rng, 0.5, relR)

        if showInterior
            for k = 0 to interiorLines
                float fracK = k / math.max(interiorLines, 1)
                float y1 = f_y(basis, slope, botOff, rng, fracK, relL)
                float y2 = f_y(basis, slope, botOff, rng, fracK, relR)
                int trK = f_clampi(88 - math.abs(fracK - 0.5) * 22, 55, 94)
                f_push_line(xL, y1, xR, y2, color.new(colPanel, trK), 2, line.style_solid)

        if showGlow
            for g = 0 to glowLayers - 1
                float offG = rng * railBandPct * g / math.max(glowLayers - 1, 1)
                int trTop = f_clampi(30 + g * 4, 12, 86)
                int trBot = f_clampi(30 + g * 4, 12, 86)
                f_push_line(xL, topL - offG, xR, topR - offG, color.new(colTop, trTop), 2, line.style_solid)
                f_push_line(xL, botL + offG, xR, botR + offG, color.new(colBottom, trBot), 2, line.style_solid)

        f_push_line(xL, topL, xR, topR, color.new(color.white, 50), 1, line.style_solid)
        f_push_line(xL, botL, xR, botR, color.new(color.white, 50), 1, line.style_solid)

        if showInterior and showChannelMid
            f_push_line(xL, midL, xR, midR, color.new(colPoc, 45), 1, line.style_dotted)

        float vahL = f_y(basis, slope, botOff, rng, vahFrac, relL)
        float pocL = f_y(basis, slope, botOff, rng, pocFrac, relL)
        float valL = f_y(basis, slope, botOff, rng, valFrac, relL)

        int labBaseX = f_guard_x(xR + rightLabelOffset)
        int vahLabX = f_guard_x(labBaseX)
        int pocLabX = f_guard_x(labBaseX + rightLabelStep)
        int valLabX = f_guard_x(labBaseX + rightLabelStep * 2)

        int vahX2 = extendLevelsToLabels ? vahLabX : xR
        int pocX2 = extendLevelsToLabels ? pocLabX : xR
        int valX2 = extendLevelsToLabels ? valLabX : xR

        float vahR = f_y(basis, slope, botOff, rng, vahFrac, vahX2 - bar_index)
        float pocR = f_y(basis, slope, botOff, rng, pocFrac, pocX2 - bar_index)
        float valR = f_y(basis, slope, botOff, rng, valFrac, valX2 - bar_index)

        f_push_line(xL, vahL, vahX2, vahR, color.new(colVahVal, 12), 1, line.style_dashed)
        f_push_line(xL, pocL, pocX2, pocR, color.new(colPoc, 0), 3, line.style_solid)
        f_push_line(xL, valL, valX2, valR, color.new(colVahVal, 12), 1, line.style_dashed)

        if showRightLabels
            f_push_label(vahLabX, vahR, "VAH", label.style_label_left, color.new(colVahVal, 0), color.black, size.tiny)
            f_push_label(pocLabX, pocR, "POC", label.style_label_left, color.new(colPoc, 0), color.white, size.tiny)
            f_push_label(valLabX, valR, "VAL", label.style_label_left, color.new(colVahVal, 0), color.black, size.tiny)

        if showVP and totalVol > 0.0 and maxVol > 0.0
            for b = 0 to bins - 1
                float v = array.get(volBins, b)
                float ratioRaw = maxVol > 0.0 ? v / maxVol : 0.0
                float ratio = math.max(ratioRaw, profileMinRatio)
                int wBars = math.max(1, int(math.round(profileMaxBars * ratio)))
                int x1 = xL
                int x2 = xL + wBars
                int rel1 = x1 - bar_index
                int rel2 = x2 - bar_index
                float fracLo = f_safe_frac(b / bins, vpInnerPadding, vpKeepInside, railSafePad, vpAutoRailGuard)
                float fracHi = f_safe_frac((b + 1.0) / bins, vpInnerPadding, vpKeepInside, railSafePad, vpAutoRailGuard)
                float fracMid = f_safe_frac((b + 0.5) / bins, vpInnerPadding, vpKeepInside, railSafePad, vpAutoRailGuard)
                float yTop1 = f_y(basis, slope, botOff, rng, fracHi, rel1)
                float yTop2 = f_y(basis, slope, botOff, rng, fracHi, rel2)
                float yBot1 = f_y(basis, slope, botOff, rng, fracLo, rel1)
                float yBot2 = f_y(basis, slope, botOff, rng, fracLo, rel2)
                float yMid1 = f_y(basis, slope, botOff, rng, fracMid, rel1)
                float yMid2 = f_y(basis, slope, botOff, rng, fracMid, rel2)
                int trFill = f_clampi(82 - ratioRaw * 60, 8, 90)
                bool inVA = b >= valIdx and b <= vahIdx
                color fillC = b == pocIdx ? color.new(colPoc, 20) : inVA ? color.new(color.rgb(0, 180, 230), trFill) : color.new(color.rgb(0, 105, 190), f_clampi(trFill + 8, 18, 94))
                color lineC = not profileBorder ? color.new(color.black, 100) : b == pocIdx ? color.new(colPoc, 0) : color.new(color.rgb(0, 220, 255), f_clampi(trFill - 24, 0, 85))
                f_push_poly(x1, yTop1, x2, yTop2, x2, yBot2, x1, yBot1, fillC, lineC)
                if showInterior and profileMidLine
                    f_push_line(x1, yMid1, x2, yMid2, color.new(color.rgb(0, 235, 255), 72), 1, line.style_dotted)

        int hvnLvnCount = 0
        int lastHvnLvnBin = na
        if showHVNLVN and maxPocVol > 0.0 and maxHVNLVNLabels > 0 and maxVol > 0.0
            for b = 1 to bins - 2
                float prevV = array.get(smoothBins, b - 1)
                float curV = array.get(smoothBins, b)
                float nextV = array.get(smoothBins, b + 1)
                float ratioS = maxPocVol > 0.0 ? curV / maxPocVol : 0.0
                bool isHVN = curV > prevV and curV > nextV and ratioS >= hvnThreshold
                bool isLVN = curV < prevV and curV < nextV and ratioS <= lvnThreshold
                bool spacingOkHL = na(lastHvnLvnBin) or math.abs(b - lastHvnLvnBin) >= hvnLvnMinSpacing
                if hvnLvnCount < maxHVNLVNLabels and spacingOkHL and (isHVN or isLVN)
                    float ratioRawHL = maxVol > 0.0 ? array.get(volBins, b) / maxVol : 0.0
                    int wBarsHL = math.max(1, int(math.round(profileMaxBars * math.max(ratioRawHL, profileMinRatio))))
                    int hx1 = xL + wBarsHL
                    int hLabX = f_guard_x(xR + rightLabelOffset + rightLabelStep * (3 + hvnLvnCount) + hvnLvnLabelOffset)
                    int hx2 = math.max(hx1 + hvnLvnLineLen, hLabX)
                    hx2 := f_guard_x(hx2)
                    float fracHL = f_safe_frac((b + 0.5) / bins, vpInnerPadding, vpKeepInside, railSafePad, vpAutoRailGuard)
                    float hy1 = f_y(basis, slope, botOff, rng, fracHL, hx1 - bar_index)
                    float hy2 = f_y(basis, slope, botOff, rng, fracHL, hx2 - bar_index)
                    color hCol = isHVN ? color.rgb(0, 235, 255) : color.rgb(120, 190, 255)
                    string hTxt = isHVN ? "HVN" : "LVN"
                    f_push_line(hx1, hy1, hx2, hy2, color.new(hCol, 0), 1, line.style_dotted)
                    if showHVNLVNText
                        f_push_label(hx2, hy2, hTxt, label.style_label_left, color.new(hCol, 0), color.black, size.tiny)
                    hvnLvnCount += 1
                    lastHvnLvnBin := b

        int idmCount = 0
        int sigCount = 0
        int simDir = slope >= 0.0 ? 1 : -1
        int lastDropX = na
        int lastAX = na
        int lastIdmLabelX = na
        int lastValidIdmX = na
        float lastValidIdmPrice = na
        float swingHi = na
        float swingLo = na
        float liqHi = na
        float liqLo = na
        float idmCandPrice = na
        int idmCandX = na
        int idmSide = 0
        bool idmSwept = false

        for q = 0 to barsUsed - 1
            int j = barsUsed - 1 - q
            int bx = bar_index - j
            float midJ2 = basis - slope * j
            float botJ2 = midJ2 + botOff
            float topJ2 = midJ2 + topOff
            float pocJ = f_y(basis, slope, botOff, rng, pocFrac, -j)
            float vahJ = f_y(basis, slope, botOff, rng, vahFrac, -j)
            float valJ = f_y(basis, slope, botOff, rng, valFrac, -j)
            float bodyJ = math.max(math.abs(close[j] - open[j]), syminfo.mintick)
            float upperWickJ = high[j] - math.max(open[j], close[j])
            float lowerWickJ = math.min(open[j], close[j]) - low[j]
            float wickBullRatio = lowerWickJ / bodyJ
            float wickBearRatio = upperWickJ / bodyJ
            bool volStrongJ = volume[j] > volMa[j] * volMult
            bool volOkJ = not useVolFilter or volStrongJ
            bool bosUp = not na(swingHi) and close[j] > swingHi and high[j] > swingHi
            bool bosDn = not na(swingLo) and close[j] < swingLo and low[j] < swingLo
            bool bullPivotSweep = not na(liqLo) and low[j] < liqLo - atr[j] * idmSweepTolAtr and close[j] > liqLo
            bool bearPivotSweep = not na(liqHi) and high[j] > liqHi + atr[j] * idmSweepTolAtr and close[j] < liqHi
            bool bullVaSweep = low[j] <= valJ and close[j] > valJ
            bool bearVaSweep = high[j] >= vahJ and close[j] < vahJ
            bool bullRailSweep = low[j] <= botJ2 + rng * touchPct and close[j] > botJ2
            bool bearRailSweep = high[j] >= topJ2 - rng * touchPct and close[j] < topJ2
            bool bullTrueSweep = (bullPivotSweep or bullVaSweep or bullRailSweep) and wickBullRatio >= wickMult * 0.80
            bool bearTrueSweep = (bearPivotSweep or bearVaSweep or bearRailSweep) and wickBearRatio >= wickMult * 0.80

            if simDir == 1 and idmSide == -1 and not idmSwept and not na(idmCandPrice) and low[j] < idmCandPrice - atr[j] * idmSweepTolAtr and close[j] > idmCandPrice
                idmSwept := true

            if simDir == -1 and idmSide == 1 and not idmSwept and not na(idmCandPrice) and high[j] > idmCandPrice + atr[j] * idmSweepTolAtr and close[j] < idmCandPrice
                idmSwept := true

            bool idmSpacingOk = not na(idmCandX) and (na(lastIdmLabelX) or math.abs(idmCandX - lastIdmLabelX) >= idmMinSpacing)
            bool idmBalancedValid = idmMode == "Balanced Sweep" and idmSwept
            bool idmStrictValid = idmMode == "Strict BOS" and idmSwept and ((simDir == 1 and bosUp) or (simDir == -1 and bosDn))
            bool idmShouldPrint = showIDM and idmCount < maxIDMLabels and not na(idmCandPrice) and not na(idmCandX) and idmCandX >= xL and idmSpacingOk and (idmBalancedValid or idmStrictValid)

            if idmShouldPrint
                bool isBullIdm = idmSide == -1
                f_push_label(idmCandX, isBullIdm ? idmCandPrice - atr[j] * 0.18 : idmCandPrice + atr[j] * 0.15, "IDM", label.style_none, color.new(color.black, 100), color.yellow, size.tiny)
                lastValidIdmX := idmCandX
                lastValidIdmPrice := idmCandPrice
                lastIdmLabelX := idmCandX
                idmCount += 1
                idmCandPrice := na
                idmCandX := na
                idmSide := 0
                idmSwept := false

            if simDir == 1 and bosDn
                simDir := -1
                idmCandPrice := na
                idmCandX := na
                idmSide := 0
                idmSwept := false

            if simDir == -1 and bosUp
                simDir := 1
                idmCandPrice := na
                idmCandX := na
                idmSide := 0
                idmSwept := false

            bool idmConf = not na(lastValidIdmX) and math.abs(bx - lastValidIdmX) <= idmConfluenceBars
            bool bullPocReclaim = low[j] < pocJ and close[j] > pocJ
            bool bearPocReclaim = high[j] > pocJ and close[j] < pocJ
            bool bullDirOk = not aRequireDirection or close[j] >= open[j]
            bool bearDirOk = not aRequireDirection or close[j] <= open[j]
            int bullScore = (bullRailSweep ? 20 : 0) + (bullVaSweep ? 20 : 0) + (wickBullRatio >= wickMult ? 20 : wickBullRatio >= wickMult * 0.70 ? 10 : 0) + (volStrongJ ? 10 : 0) + (bullPocReclaim ? 15 : 0) + (idmConf ? 15 : 0)
            int bearScore = (bearRailSweep ? 20 : 0) + (bearVaSweep ? 20 : 0) + (wickBearRatio >= wickMult ? 20 : wickBearRatio >= wickMult * 0.70 ? 10 : 0) + (volStrongJ ? 10 : 0) + (bearPocReclaim ? 15 : 0) + (idmConf ? 15 : 0)
            bool dropSpacingOk = na(lastDropX) or math.abs(bx - lastDropX) >= signalMinSpacing
            bool aSpacingOk = na(lastAX) or math.abs(bx - lastAX) >= signalMinSpacing

            if dropSpacingOk and showDrops and bullTrueSweep and sigCount < maxSignalLabels
                f_push_label(bx, low[j] - atr[j] * 0.10, "💧", label.style_none, color.new(color.black, 100), color.rgb(170, 230, 255), size.normal)
                sigCount += 1
                lastDropX := bx

            if dropSpacingOk and showDrops and bearTrueSweep and sigCount < maxSignalLabels
                f_push_label(bx, high[j] + atr[j] * 0.10, "💧", label.style_none, color.new(color.black, 100), color.rgb(170, 230, 255), size.normal)
                sigCount += 1
                lastDropX := bx

            if aSpacingOk and showA and bullTrueSweep and bullScore >= aMinScore and bullDirOk and volOkJ and sigCount < maxSignalLabels
                f_push_label(bx, low[j] - atr[j] * 0.45, showAScore ? "A\n" + str.tostring(bullScore) : "A", label.style_label_up, color.rgb(215, 180, 0), color.black, size.small)
                sigCount += 1
                lastAX := bx

            if aSpacingOk and showA and bearTrueSweep and bearScore >= aMinScore and bearDirOk and volOkJ and sigCount < maxSignalLabels
                f_push_label(bx, high[j] + atr[j] * 0.45, showAScore ? "A\n" + str.tostring(bearScore) : "A", label.style_label_down, color.rgb(215, 180, 0), color.black, size.small)
                sigCount += 1
                lastAX := bx

            float phJ = ph[j]
            float plJ = pl[j]
            int pivotHist = j + pivotRight
            bool hasPivotHist = pivotHist <= bar_index
            float refClose = hasPivotHist ? close[pivotHist] : na
            float refAtr = hasPivotHist ? atr[pivotHist] : na
            int pivotX = bar_index - j - pivotRight
            bool okHighPivot = hasPivotHist and not na(phJ) and not na(refClose) and not na(refAtr) and math.abs(phJ - refClose) >= refAtr * idmAtrFilter
            bool okLowPivot = hasPivotHist and not na(plJ) and not na(refClose) and not na(refAtr) and math.abs(plJ - refClose) >= refAtr * idmAtrFilter

            if okHighPivot
                swingHi := phJ
                liqHi := phJ
                if simDir == -1
                    idmCandPrice := phJ
                    idmCandX := pivotX
                    idmSide := 1
                    idmSwept := false
                    bool earlySpacingHigh = not na(idmCandX) and (na(lastIdmLabelX) or math.abs(idmCandX - lastIdmLabelX) >= idmMinSpacing)
                    if showIDM and idmMode == "Early Candidate" and idmCount < maxIDMLabels and earlySpacingHigh and idmCandX >= xL
                        f_push_label(idmCandX, idmCandPrice + refAtr * 0.15, "IDM", label.style_none, color.new(color.black, 100), color.yellow, size.tiny)
                        lastValidIdmX := idmCandX
                        lastValidIdmPrice := idmCandPrice
                        lastIdmLabelX := idmCandX
                        idmCount += 1

            if okLowPivot
                swingLo := plJ
                liqLo := plJ
                if simDir == 1
                    idmCandPrice := plJ
                    idmCandX := pivotX
                    idmSide := -1
                    idmSwept := false
                    bool earlySpacingLow = not na(idmCandX) and (na(lastIdmLabelX) or math.abs(idmCandX - lastIdmLabelX) >= idmMinSpacing)
                    if showIDM and idmMode == "Early Candidate" and idmCount < maxIDMLabels and earlySpacingLow and idmCandX >= xL
                        f_push_label(idmCandX, idmCandPrice - refAtr * 0.18, "IDM", label.style_none, color.new(color.black, 100), color.yellow, size.tiny)
                        lastValidIdmX := idmCandX
                        lastValidIdmPrice := idmCandPrice
                        lastIdmLabelX := idmCandX
                        idmCount += 1
````

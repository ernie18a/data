# Range Zones ATR 

- url: https://www.tradingview.com/script/J7beAlvd/
- type: indicator
- pine_id: PUB;45a0447740c742e0ac9f82775518eefd
- version: 2.0

## Description

Range Zones ATR 
Range Zones ATR  is an open-source indicator designed to detect, validate, score, and maintain sideways price zones using ATR-normalized structure analysis. 
The script is built for one specific purpose: identifying areas where price is behaving like a genuine horizontal range rather than a brief pause inside an ongoing trend. Instead of marking every local consolidation, it evaluates whether price is compressed relative to current volatility, whether directional pressure remains limited, whether the market is interacting with both sides of the structure, and whether internal movement stays balanced enough to justify treating the area as a meaningful zone of acceptance.
In practical terms, this indicator highlights parts of the chart where price is rotating within a contained area instead of moving cleanly in one direction. That makes it useful for studying balance, consolidation, containment, and possible expansion after compression.
What this indicator is
This indicator is a volatility-adjusted range structure detector.
Its main task is to answer a structural question:
Is price actually trading inside a valid sideways regime, or is the apparent consolidation too directional, too unstable, or too impulsive to be treated as a real range?
To answer that, the script does not rely on a single condition. It combines multiple filters and measurements into one process. A visible zone is only created after the candidate structure survives tests related to compression, trend pressure, slope behavior, duration, touch activity, oscillation, drift, and local expansion.
What this indicator shows
The script draws zones directly on the chart as horizontal boxes representing areas where price is being accepted inside a relatively contained environment.
The indicator can classify zones in three different ways:
Base Range
A confirmed sideways zone that passed the core validation logic.
Prime Range
A higher-quality confirmed zone with a stronger final score. These zones generally show cleaner balance, stronger containment, and better internal structure than a standard range.
HTF Confluence
A confirmed local zone that also overlaps with a valid higher-timeframe range context when the optional multi-timeframe feature is enabled.
These labels are structural descriptions, not trade commands. They are intended to help the user understand the character and quality of the detected range.
What the script measures
The indicator is built around the idea that a valid range should appear compressed, balanced, and relatively non-directional. To evaluate that, it measures several parts of market behavior.


Range width relative to ATR


The script compares the width of recent price envelopes to ATR. This allows the indicator to interpret range width relative to current volatility instead of using a fixed distance. A narrow range on one symbol may be wide on another, and a usable range on one timeframe may be insignificant on another. ATR normalization helps the script stay adaptive across different chart conditions.


Multiple internal envelopes


The script builds short-, medium-, and long-lookback envelopes from recent highs and lows. It then compares those candidates and selects the one that provides the best structural fit. This makes the detection process more flexible than relying on only one fixed lookback.


ADX trend pressure


A stable range normally should not exist in a strongly directional environment. The script uses ADX as part of its filter and scoring process to reduce the chance of classifying strong directional movement as sideways structure.


EMA slope and linear regression slope


A market can appear flat while still drifting directionally. To reduce that problem, the script checks both EMA slope and linear regression slope. This helps filter out sloped price action that does not behave like a clean horizontal range.


Minimum persistence


A valid range should remain stable for a meaningful number of bars before it is trusted. The script therefore includes minimum-bar confirmation logic so that very brief pauses do not become fully confirmed zones too early.


Touch behavior


A healthy range usually shows repeated interaction with its boundaries. The script tracks touches near the upper and lower edges of the candidate zone to confirm that price is actually rotating through the structure rather than clustering on one side.


Internal oscillation


A sideways regime should contain some back-and-forth movement. The script evaluates oscillatory behavior within the candidate zone to avoid treating a slow directional drift as balanced consolidation.


Drift and efficiency


The script checks how directly price is moving from one point to another. If movement becomes too efficient or too directional, that is less consistent with a true range. If movement is choppier and more rotational, the structure is more likely to qualify.


Impulsive movement


Strong impulsive candles can weaken or invalidate the idea of a stable range. The script uses expansion and impulse-related checks to reject candidates that are behaving too aggressively.


Higher-timeframe overlap


When the optional MTF context feature is enabled, the script checks whether the local zone overlaps a confirmed higher-timeframe range area. If the overlap is meaningful, the zone can receive a score boost and be classified with higher structural context.
How the detection process works
At a high level, the script follows this workflow:
First, it builds recent envelopes from highs and lows using several internal lookbacks.
Second, it measures whether those envelopes are sufficiently compressed relative to ATR.
Third, it combines that compression with trend and slope conditions such as ADX, EMA slope, and linear regression slope.
Fourth, if the environment looks suitable, it starts tracking a candidate zone instead of drawing a confirmed zone immediately.
Fifth, while the candidate is active, it evaluates persistence, touch count, oscillation, drift, path efficiency, and impulsive behavior.
Sixth, if the candidate survives enough structural tests, it becomes a visible zone on the chart.
Seventh, once a zone is active, it can continue, refine, merge with a nearby compatible zone, or terminate if price no longer behaves like the same sideways regime.
Finally, if breakout alerts are enabled, the script only considers a breakout confirmed after price closes beyond the zone edge plus an ATR-based buffer.
This process is important because the indicator is not designed to draw every small pause. It is designed to identify consolidations that behave like actual balance.
How to read the zones
A visible zone should be interpreted as an area where the script sees containment, acceptance, and relatively balanced price behavior.
That can help the user evaluate:
whether the market is still consolidating rather than trending,
whether price is continuing to rotate inside the same area,
whether one side of the structure is weakening,
whether the range remains healthy,
or whether the market may be transitioning from compression into expansion.
A Base Range means the structure passed the standard confirmation requirements.
A Prime Range means the same structure passed with a stronger overall score.
An HTF Confluence zone means the local structure also aligns with a broader higher-timeframe range area.
These classifications describe current market structure. They do not guarantee that price will remain inside the zone or that the next movement will occur in a particular direction.
How to use this indicator
This indicator is best used as a market-structure and chart-context tool.
One practical use is to study where price is being accepted inside a contained area. When price remains inside a confirmed zone and continues to interact with both edges, the market may still be operating in a balanced regime.
Another use is to monitor edge behavior. The upper and lower zone boundaries can serve as structural reference areas. Repeated rejection near one side, repeated return toward the middle, or clean acceptance outside the zone may help the user judge whether the range is still functioning or beginning to fail.
The breakout logic can also be used for structure monitoring. Because the script requires price to move beyond the zone edge with an ATR-based buffer, it is more selective than a simple boundary touch. This helps reduce reactions to small wick-only violations and shallow overshoots.
The optional higher-timeframe context can be used to compare local balance with broader structure. A local range that overlaps a confirmed higher-timeframe range may be more relevant than an isolated local pause.
The script can also be used to filter low-quality consolidation. Many apparent ranges are only temporary slowdowns inside a directional move. This indicator tries to reject many of those cases by requiring better balance, persistence, touch behavior, and non-directional structure before a zone is confirmed.
What makes this indicator different
This script differs from simpler range tools in several ways.
ATR-normalized detection
The indicator evaluates range width relative to ATR instead of using fixed-width boxes. This helps the same logic adapt to different volatility conditions, symbols, and timeframes.
Multi-factor validation
The script does not rely on a single trigger. It combines compression, trend pressure, slope analysis, persistence, touch activity, oscillation, drift, and efficiency into one structural decision process.
Candidate-to-confirmation workflow
Many range tools mark a zone as soon as price becomes temporarily narrow. This script first tracks a candidate, then confirms it only if the structure continues to behave like a true sideways regime.
Quality classification
The script separates normal confirmed ranges from stronger confirmed ranges. This helps distinguish ordinary structure from zones that achieve better internal scores.
Zone merge logic
Nearby zones that belong to the same horizontal regime can be merged. This is useful because real consolidations are often fragmented by minor interruptions or short empty gaps that still belong to the same broader balance area.
Higher-timeframe confluence
The optional MTF feature is used as structural context rather than as a separate signal engine. This allows local zones to be strengthened when they align with a broader confirmed range.
Active zone maintenance
Once confirmed, a zone is not simply frozen in place. The script can continue refining and extending the zone while price remains compatible with the same range logic.
Input overview
Mode
Conservative, Balanced, and Aggressive modes control how selective the detection process is. Conservative mode generally favors fewer and stricter zones. Aggressive mode allows broader coverage.
Preset
Scalping, Intraday, and Swing presets adjust internal lookbacks and structural behavior for different trading horizons.
Price Series
The script can use close, hl2, hlc3, or ohlc4 as its selected price source in parts of the scoring and filtering process, while envelopes remain based on highs and lows.
Sensitivity
Sensitivity changes how tightly or loosely candidate structures are interpreted.
Min Bars and Min Score
These settings define how much persistence and quality a candidate needs before it can qualify as a visible zone.
Trend Filter
This filter reduces the chance of labeling strong directional movement as sideways structure.
Merge controls
Merge Zones, Merge Threshold, Merge Gap Bars, and Bridge Merge control whether nearby compatible zones should be combined into one broader regime.
MTF controls
MTF Context, Higher TF, and MTF Boost allow local structure to be compared against confirmed higher-timeframe range structure.
Visual controls
The script includes settings for fill, borders, labels, theme handling, and score visibility.
Alerts
Optional alerts are available for newly confirmed zones and for breakout events beyond an active zone.
Best use cases
This indicator is designed for users who want to study consolidation structure rather than only directional trend behavior.
It can be useful for identifying balanced price areas, monitoring acceptance inside a horizontal regime, watching for continuation or breakdown of an existing range, studying compression before expansion, and comparing local structure with higher-timeframe context.
Important limitations
This script is an indicator, not a strategy. It does not execute trades and it does not provide backtest results.
Like any range-based method, it can become less effective in environments dominated by persistent directional expansion, abrupt trend transitions, or sudden volatility shocks. A detected zone is the script’s structural interpretation of current price behavior, not a guarantee that price will remain contained.
Open-source note
This script is published as open-source so users can inspect the logic, understand how the methodology works, and build on the idea in accordance with TradingView’s publication and reuse rules.

## Source Code

````pine
//@version=5
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright (c) 2026 Malibuu
indicator(title = "ATR Range Zones Pro", shorttitle = "ATR Zones", overlay = true, max_boxes_count = 500, max_lines_count = 400, max_labels_count = 200)
var gGen = "General"
detMode = input.string("Balanced", "Mode", options = ["Conservative", "Balanced", "Aggressive"], group = gGen, tooltip = "Conservative: fewer zones. Aggressive: more coverage.", display = display.none)
preset = input.string("Intraday", "Preset", options = ["Scalping", "Intraday", "Swing"], group = gGen, tooltip = "Time horizon for internal lookbacks.", display = display.none)
srcStr = input.string("close", "Price Series", options = ["close", "hl2", "hlc3", "ohlc4"], group = gGen, tooltip = "Filter/score series; envelope uses high/low.", display = display.none)
var gDet = "Detection"
sensitivity = input.string("Normal", "Sensitivity", options = ["Calm", "Normal", "Reactive"], group = gDet, tooltip = "Calm: tighter span. Reactive: wider span.", display = display.none)
basicMinZoneBars = input.int(4, "Min Bars", minval = 2, group = gDet, tooltip = "Closed bars before a zone can confirm.", display = display.none)
basicMinScore = input.int(38, "Min Score", minval = 1, maxval = 100, group = gDet, tooltip = "Standard floor 0-100. HQ uses +7 vs this.", display = display.none)
useTrendFil = input.bool(true, "Trend Filter", group = gDet, tooltip = "When on, ADX must stay within mode-based cap.", display = display.none)
var gZn = "Zones"
useMerge = input.bool(true, "Merge Zones", group = gZn, tooltip = "Stitch nearby horizontal zones into one box.", display = display.none)
mergeThreshold = input.float(0.55, "Merge Threshold", minval = 0.15, maxval = 2.0, step = 0.05, group = gZn, tooltip = "Top/bottom slack vs ATR to treat bands as the same regime.", display = display.none)
mergeGapBars = input.int(72, "Merge Gap Bars", minval = 1, maxval = 300, group = gZn, tooltip = "Max bars after prior zone ends to still merge / bridge. Scales up on higher timeframes.", display = display.none)
allowBridgeMerge = input.bool(true, "Bridge Merge", group = gZn, tooltip = "Allow short empty gaps between similar bands (same horizontal area).", display = display.none)
onlyOneActive = input.bool(true, "Single Zone", group = gZn, tooltip = "One live box at a time.", display = display.none)
bufK = input.float(0.12, "Breakout Buffer", minval = 0.0, step = 0.02, group = gZn, tooltip = "Extra x ATR beyond edge.", display = display.none)
useMtfContext = input.bool(false, "MTF Context", group = gZn, tooltip = "Boost zones that overlap a confirmed higher-timeframe range.", display = display.none)
mtfTfSel = input.string("4H", "Higher TF", options = ["1H", "4H", "1D"], group = gZn, tooltip = "Higher timeframe used only for zone context.", display = display.none)
mtfBoostSel = input.string("Normal", "MTF Boost", options = ["Low", "Normal", "High"], group = gZn, tooltip = "Score lift when current zone overlaps confirmed HTF context.", display = display.none)
var gVs = "Visuals"
themeSel = input.string("Dark", "Theme", options = ["Auto", "Light", "Dark"], group = gVs, tooltip = "Auto fits chart background.", display = display.none)
showFill = input.bool(true, "Zone Fill", group = gVs, tooltip = "Zone shading.", display = display.none)
showBorder = input.bool(true, "Border", group = gVs, tooltip = "Zone outline.", display = display.none)
showLbl = input.bool(true, "Zone Labels", group = gVs, tooltip = "Show zone names such as Base Range, Prime Range, and HTF Confluence.", display = display.none)
showScoreTag = input.bool(false, "Score", group = gVs, tooltip = "Append 0-100 to zone caption.", display = display.none)
labelTextColorIn = input.color(color.white, "Label Text Color", group = gVs, tooltip = "Text color for zone labels.", display = display.none)
labelSizeSel = input.string("Small Text", "Label Size", options = ["Tiny Text", "Small Text", "Normal Text", "Large Text", "Huge Text"], group = gVs, tooltip = "Text size for zone labels.", display = display.none)
transpIn = input.int(82, "Transparency", minval = 60, maxval = 96, group = gVs, tooltip = "Higher = softer fill.", display = display.none)
var gClr = "Colors"
colBullBrkIn    = input.color(color.new(#22c55e, 0), "Bullish Breakout", group = gClr, tooltip = "Color for bullish breakout border.", display = display.none)
colBearBrkIn    = input.color(color.new(#ef4444, 0), "Bearish Breakout", group = gClr, tooltip = "Color for bearish breakout border.", display = display.none)
colNeutralZoneIn = input.color(color.new(#64748b, 0), "Base Range Zone", group = gClr, tooltip = "Color for standard base range zones.", display = display.none)
colHighQIn      = input.color(color.new(#14b8a6, 0), "Prime Range Zone", group = gClr, tooltip = "Color for high-quality prime range zones.", display = display.none)
colMtfZoneIn    = input.color(color.new(#f59e0b, 0), "HTF Confluence Zone", group = gClr, tooltip = "Color for multi-timeframe confluence zones.", display = display.none)
colExpiredBrdIn = input.color(color.new(#94a3b8, 0), "Expired Zone Border", group = gClr, tooltip = "Color for expired zone borders.", display = display.none)
var gAl = "Alerts"
alNew = input.bool(false, "New Zone", group = gAl, tooltip = "New confirmed zone.", display = display.none)
alBrk = input.bool(false, "Breakout", group = gAl, tooltip = "Close confirms beyond buffer.", display = display.none)
px = srcStr == "close" ? close : srcStr == "hl2" ? hl2 : srcStr == "hlc3" ? hlc3 : ohlc4
atrLen          = 14
emaLenFil       = 34
emaSlopeLb      = 8
linRegLenFil    = 20
dxLen           = 14
scoreEmaLen     = 50
scoreEmaLb      = 10
scoreLrLen      = 20
scoreEmaRefAtr  = 0.42
scoreLrRefAtr   = 0.30
useEmaSlopeFil  = true
useLinRegFil    = true
useAdxScore     = true
useSlopeScore   = true
useLinRegScore  = true
useMinBarsScore = true
minBarsStreak   = 3
maxDriftRatio   = 0.56
maxEfficiency   = 0.60
minOscillation  = 2
minTouchCount   = 3
requireBothBandTouch = true
maxImpulseBars  = 3
impBodyAtr      = 0.70
impBodyPct      = 0.50
hardMaxER       = 0.90
hardMaxDriftV   = 0.82
hardEmaSlopeAtr = 0.88
hardLrSlopeAtr  = 0.58
pathFloorAtr    = 0.12
touchTolAtr     = 0.16
mergeMinOv      = 0.22
brkN            = 2
useFbProt       = true
trendAdxPen     = 34.0
trendEmaPenMult = 0.58
trendPenAmt     = 0.055
labelSizeUse = labelSizeSel == "Tiny Text" ? size.tiny : labelSizeSel == "Normal Text" ? size.normal : labelSizeSel == "Large Text" ? size.large : labelSizeSel == "Huge Text" ? size.huge : size.small
maxAdx = detMode == "Conservative" ? 25.0 : detMode == "Aggressive" ? 31.0 : 28.0
maxEmaSlopeAtr = detMode == "Conservative" ? 0.32 : detMode == "Aggressive" ? 0.44 : 0.38
maxLinRegSlopeAtr = detMode == "Conservative" ? 0.27 : detMode == "Aggressive" ? 0.37 : 0.32
detM = detMode == "Conservative" ? 0.92 : detMode == "Aggressive" ? 1.08 : 1.0
sensM = sensitivity == "Calm" ? 0.94 : sensitivity == "Reactive" ? 1.06 : 1.0
effShort = preset == "Scalping" ? 8 : preset == "Intraday" ? 10 : 14
effMed = preset == "Scalping" ? 15 : preset == "Intraday" ? 18 : 26
effLong = preset == "Scalping" ? 24 : preset == "Intraday" ? 30 : 42
baseAtrMult = preset == "Scalping" ? 2.78 : preset == "Intraday" ? 3.05 : 3.38
atrMultEff = baseAtrMult * detM * sensM
effMinBars = math.max(2, int(math.round(basicMinZoneBars * (detMode == "Conservative" ? 1.15 : detMode == "Aggressive" ? 0.92 : 1.0))))
effMinStd = math.min(100, math.max(1, int(math.round(basicMinScore * (detMode == "Conservative" ? 1.06 : detMode == "Aggressive" ? 0.93 : 1.0)))))
effMinHQ = math.min(100, math.max(effMinStd + 1, math.max(1, int(math.round(math.min(93, basicMinScore + 7) * (detMode == "Conservative" ? 1.08 : detMode == "Aggressive" ? 0.94 : 1.0))))))
mergeGapBarsEff = int(math.min(300, math.round(mergeGapBars * math.max(1.0, math.min(4.0, timeframe.in_seconds(timeframe.period) / 1200.0)))))
dupGapBarsEff = int(math.max(basicMinZoneBars * 2, math.min(mergeGapBarsEff, math.round(mergeGapBars * 0.50))))
effGrace = preset == "Scalping" ? 3 : preset == "Intraday" ? 4 : 5
effStartRelax = preset == "Scalping" ? 1.26 : preset == "Intraday" ? 1.32 : 1.36
mxCandRangeMult = preset == "Scalping" ? 4.0 : preset == "Intraday" ? 4.5 : 5.0
mxHtAtr = preset == "Scalping" ? 4.0 : preset == "Intraday" ? 4.5 : 5.0
covBackMax = preset == "Scalping" ? 48 : preset == "Intraday" ? 96 : 144
covGraceMax = preset == "Scalping" ? 2 : preset == "Intraday" ? 3 : 4
covTolAtr = 0.62
mtfTf = mtfTfSel == "1H" ? "60" : mtfTfSel == "4H" ? "240" : "D"
mtfBoostPts = mtfBoostSel == "Low" ? 4 : mtfBoostSel == "High" ? 10 : 7
confirm = barstate.isconfirmed
atr = ta.atr(atrLen)
[mtfHiRaw, mtfLoRaw, mtfAtrRaw] = request.security(syminfo.tickerid, mtfTf, [ta.highest(high, effMed)[1], ta.lowest(low, effMed)[1], ta.atr(atrLen)[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
mtfReady = useMtfContext and not na(mtfHiRaw) and not na(mtfLoRaw) and not na(mtfAtrRaw) and mtfAtrRaw > 0.0 and (mtfHiRaw - mtfLoRaw) > syminfo.mintick
mtfRangeOk = mtfReady and (mtfHiRaw - mtfLoRaw) <= mtfAtrRaw * atrMultEff * effStartRelax * 1.08
emS = ta.ema(px, scoreEmaLen)
dEmS = emS - emS[scoreEmaLb]
lrS = ta.linreg(px, scoreLrLen, 0)
dLrS = lrS - lrS[1]
[_, _, adx] = ta.dmi(dxLen, dxLen)
emF = ta.ema(px, emaLenFil)
dEmF = emF - emF[emaSlopeLb]
lrF = ta.linreg(px, linRegLenFil, 0)
dLrF = lrF - lrF[1]
sc_adx = useAdxScore and not na(adx) ? 100.0 * (1.0 - math.min(1.0, adx / 48.0)) : 0.0
sc_sl = useSlopeScore and not na(dEmS) and not na(atr) and scoreEmaRefAtr > 0 ? 100.0 * (1.0 - math.min(1.0, math.abs(dEmS) / (atr * scoreEmaRefAtr * 1.8))) : 0.0
sc_lr = useLinRegScore and not na(dLrS) and not na(atr) and scoreLrRefAtr > 0 ? 100.0 * (1.0 - math.min(1.0, math.abs(dLrS) / (atr * scoreLrRefAtr * 1.8))) : 0.0
filtW = (useAdxScore ? 1.0 : 0.0) + (useSlopeScore ? 1.0 : 0.0) + (useLinRegScore ? 1.0 : 0.0)
sumWFilt = (useAdxScore ? sc_adx : 0.0) + (useSlopeScore ? sc_sl : 0.0) + (useLinRegScore ? sc_lr : 0.0)
zoneScoreFromRng(float sc_rng_i) => (3.0 * sc_rng_i + sumWFilt) / math.max(1e-10, 3.0 + filtW)
envCore(int len) =>
    rhi = ta.highest(high, len)
    rlo = ta.lowest(low, len)
    rsi = rhi - rlo
    lfti = int(math.max(bar_index - len + 1, 0))
    sc_rngi = rsi > 0 and not na(atr) ? 100.0 * (1.0 - math.min(1.0, rsi / (atr * atrMultEff * 1.1))) : 0.0
    [rhi, rlo, rsi, lfti, sc_rngi]
[rhS, rlS, rsS, lfS, scRS] = envCore(effShort)
[rhM, rlM, rsM, lfM, scRM] = envCore(effMed)
[rhL, rlL, rsL, lfL, scRL] = envCore(effLong)
zShort = zoneScoreFromRng(scRS)
zMed = zoneScoreFromRng(scRM)
zLong = zoneScoreFromRng(scRL)
bandMult = atr * atrMultEff * effStartRelax
okS = rsS <= bandMult
okM = rsM <= bandMult
okL = rsL <= bandMult
anyBandOk = okS or okM or okL
pickBestEnv() =>
    float rH = na
    float rL = na
    int lf = 0
    float bz = -1.0
    if okS and zShort > bz
        bz := zShort
        rH := rhS
        rL := rlS
        lf := lfS
    if okM and zMed > bz
        bz := zMed
        rH := rhM
        rL := rlM
        lf := lfM
    if okL and zLong > bz
        bz := zLong
        rH := rhL
        rL := rlL
        lf := lfL
    if na(rH)
        if zShort >= zMed and zShort >= zLong
            rH := rhS
            rL := rlS
            lf := lfS
        else if zMed >= zLong
            rH := rhM
            rL := rlM
            lf := lfM
        else
            rH := rhL
            rL := rlL
            lf := lfL
    [rH, rL, lf]
[rhBest, rlBest, leftAlignBest] = pickBestEnv()
rngBest = rhBest - rlBest
rs = nz(rngBest, ta.highest(high, effMed) - ta.lowest(low, effMed))
basicNow = not na(rhBest) and not na(rlBest) and rngBest <= bandMult
rngStartRelaxed = not na(rhBest) and not na(rlBest) and rngBest <= bandMult * 1.22
var int st = 0
st := basicNow ? st + 1 : 0
sc_mnb = useMinBarsScore ? 100.0 * math.min(1.0, float(st) / float(math.max(minBarsStreak, 1))) : 0.0
sc_rng_cur = rs > 0 and not na(atr) ? 100.0 * (1.0 - math.min(1.0, rs / (atr * atrMultEff * 1.1))) : 0.0
zoneScoreCore = (3.0 * sc_rng_cur + sumWFilt + (useMinBarsScore ? sc_mnb : 0.0)) / math.max(1e-10, 3.0 + filtW + (useMinBarsScore ? 1.0 : 0.0))
mildTrendPen = (not na(adx) and adx > trendAdxPen) or (not na(dEmS) and not na(atr) and math.abs(dEmS) > atr * trendEmaPenMult)
lenIdle = effMed
idlePathSum = math.sum(math.abs(px - nz(px[1], px)), lenIdle)
idleNet = math.abs(px - nz(px[lenIdle], px))
idleER = idlePathSum > atr * pathFloorAtr ? idleNet / idlePathSum : 1.0
idleRngW = ta.highest(high, lenIdle) - ta.lowest(low, lenIdle)
idleDriftRat = idleRngW > syminfo.mintick ? idleNet / idleRngW : 0.0
hardTrendVeto(float erV, float driftV, int impCt) => erV > hardMaxER or driftV > hardMaxDriftV or (not na(dEmF) and not na(atr) and math.abs(dEmF) > atr * hardEmaSlopeAtr) or (not na(dLrF) and not na(atr) and math.abs(dLrF) > atr * hardLrSlopeAtr) or impCt > maxImpulseBars
startVetoRaw = hardTrendVeto(idleER, idleDriftRat, 0)
flatChopMk = not na(adx) and adx <= 26.0 and idleDriftRat <= 0.84 and idleER <= 0.88
startVeto = startVetoRaw and not flatChopMk
balanceAvgFromAcc(float sDn, int sNn, float ct, float cb) => sNn > 0 and (ct - cb) / 2.0 > syminfo.mintick ? 100.0 * (1.0 - math.min(1.0, sDn / float(sNn))) : 50.0
promoScore(float zCore, int cbars, int tT, int tB, float balA, bool trndPen, float oscScr, float drScr, float erScr) =>
    dU = 100.0 * math.min(1.0, float(cbars) / float(math.max(effMinBars * 2, 1)))
    tch = 100.0 * math.min(1.0, (float(tT) + float(tB)) / 8.0)
    fw = filtW + (useMinBarsScore ? 1.0 : 0.0)
    sumS = sumWFilt + (useMinBarsScore ? sc_mnb : 0.0)
    rawB = 0.28 * zCore + 0.12 * dU + 0.12 * tch + 0.12 * balA + 0.10 * oscScr + 0.10 * drScr + 0.10 * erScr
    rwB = 0.28 + 0.12 + 0.12 + 0.12 + 0.10 + 0.10 + 0.10
    rawC = rawB + (fw > 0 ? (sumS / fw) * 0.12 : 0.0)
    rwC = rwB + (fw > 0 ? 0.12 : 0.0)
    sc0 = rwC > 0 ? rawC / rwC : zCore
    trndPen ? sc0 * (1.0 - trendPenAmt) : sc0
touchTol = atr * touchTolAtr
var float pT = na
var float pB = na
var int pLf = -1
var int pRg = -1
sidewaysGate(float driftF, float erF, float midF, int oscN, int tT, int tB, int impCt, bool netSlopeOk) =>
    totTouch = tT + tB
    adxOk = not useTrendFil or (not na(adx) and adx <= maxAdx)
    emaOk = not useEmaSlopeFil or (not na(dEmF) and math.abs(dEmF) <= atr * maxEmaSlopeAtr)
    lrOk = not useLinRegFil or (not na(dLrF) and math.abs(dLrF) <= atr * maxLinRegSlopeAtr)
    touchOk = totTouch >= minTouchCount
    bandTouchOk = not requireBothBandTouch or (tT >= 1 and tB >= 1)
    adxOk and emaOk and lrOk and driftF <= maxDriftRatio and erF <= maxEfficiency and midF <= maxDriftRatio and (minOscillation <= 0 or oscN >= minOscillation) and touchOk and bandTouchOk and impCt <= maxImpulseBars and netSlopeOk
overlapIoU(float tA, float bA, float tB_, float bB_) =>
    h1 = tA - bA
    h2 = tB_ - bB_
    interH = math.max(0.0, math.min(tA, tB_) - math.max(bA, bB_))
    uni = math.max(1e-10, h1 + h2 - interH)
    interH / uni
mtfConfluenceFor(float zTop, float zBot) =>
    zH = math.max(zTop - zBot, syminfo.mintick)
    interH = mtfReady ? math.max(0.0, math.min(zTop, mtfHiRaw) - math.max(zBot, mtfLoRaw)) : 0.0
    coverLtf = interH / zH
    iou = mtfReady ? overlapIoU(zTop, zBot, mtfHiRaw, mtfLoRaw) : 0.0
    midL = (zTop + zBot) * 0.5
    midH = mtfReady ? (mtfHiRaw + mtfLoRaw) * 0.5 : midL
    midDist = math.abs(midL - midH)
    tolNow = math.max(atr, mtfReady ? mtfAtrRaw : atr) * mergeThreshold
    midNear = midDist <= tolNow and coverLtf >= 0.18
    overlapOk = coverLtf >= 0.34 or iou >= 0.08 or midNear
    mtfRangeOk and overlapOk
bandsNear(float tA, float bA, float tB_, float bB_, float tol) => math.abs(tA - tB_) <= tol and math.abs(bA - bB_) <= tol
sameRegime(float tA, float bA, float tB_, float bB_, float tol) =>
    iou = overlapIoU(tA, bA, tB_, bB_)
    midA = (tA + bA) * 0.5
    midB = (tB_ + bB_) * 0.5
    hA = tA - bA
    hB_ = tB_ - bB_
    sep = math.abs(midA - midB)
    maxH = math.max(hA, hB_)
    minH = math.max(math.min(hA, hB_), syminfo.mintick)
    hRatio = maxH / minH
    edgeNear = bandsNear(tA, bA, tB_, bB_, tol)
    overlapOk = iou >= mergeMinOv
    midOk = sep <= tol * 0.92 and hRatio <= 1.95 and maxH <= atr * atrMultEff * 1.14
    containOk = iou >= mergeMinOv * 0.62 and sep <= tol * 1.35 and hRatio <= 2.25
    overlapOk or edgeNear or midOk or containOk
coverageRefine(float zT, float zB, int seedLeft, float maxH) =>
    int lR = seedLeft
    float tR = zT
    float bR = zB
    int missN = 0
    tol = atr * covTolAtr
    wideTol = tol * 1.48
    wickTol = tol * 1.18
    missLimit = math.min(3, covGraceMax)
    for i = 0 to 180
        inLookback = i <= covBackMax
        hasBar = bar_index >= i
        if inLookback and hasBar
            hiI = high[i]
            loI = low[i]
            opI = open[i]
            clI = close[i]
            brI = math.max(hiI - loI, syminfo.mintick)
            bodyHiI = math.max(opI, clI)
            bodyLoI = math.min(opI, clI)
            bodyMidI = (opI + clI) * 0.5
            upperI = tR + wideTol
            lowerI = bR - wideTol
            coreUpperI = tR + tol
            coreLowerI = bR - tol
            interI = math.max(0.0, math.min(hiI, upperI) - math.max(loI, lowerI))
            overlapI = interI / brI
            bodyRangeI = math.max(bodyHiI - bodyLoI, syminfo.mintick)
            bodyInterI = math.max(0.0, math.min(bodyHiI, upperI) - math.max(bodyLoI, lowerI))
            bodyOverlapI = bodyInterI / bodyRangeI
            closeOkI = clI <= upperI and clI >= lowerI
            bodyOkI = bodyMidI <= upperI and bodyMidI >= lowerI
            coreCloseOkI = clI <= coreUpperI and clI >= coreLowerI
            coreBodyOkI = bodyMidI <= coreUpperI and bodyMidI >= coreLowerI
            overlapOkI = overlapI >= 0.29
            bodyOverlapOkI = bodyOverlapI >= 0.50
            rangeOkI = brI <= maxH * 0.88 or overlapI >= 0.48 or bodyOverlapI >= 0.66
            bodySizeI = bodyHiI - bodyLoI
            bodyOkSizeI = bodySizeI <= atr * impBodyAtr * 1.58 or bodyOverlapI >= 0.62
            bodyRatI = brI > 0.0 ? bodySizeI / brI : 0.0
            bodyMidCoreOkI = bodyMidI <= coreUpperI and bodyMidI >= coreLowerI
            impulseI = bodySizeI > atr * impBodyAtr * 1.72 and bodyRatI >= impBodyPct and not bodyMidCoreOkI and bodyOverlapI < 0.58
            wickOverlapOkI = overlapOkI and bodyOverlapI >= 0.38
            priceOkI = closeOkI or bodyOkI or coreCloseOkI or coreBodyOkI or bodyOverlapOkI or wickOverlapOkI
            goodI = priceOkI and rangeOkI and bodyOkSizeI and not impulseI
            pastSeedI = bar_index - i < seedLeft
            if goodI
                missN := 0
                hiAbsorbI = hiI <= tR + wickTol
                loAbsorbI = loI >= bR - wickTol
                hiUseI = hiI
                if not hiAbsorbI
                    hiUseI := math.min(bodyHiI, upperI)
                loUseI = loI
                if not loAbsorbI
                    loUseI := math.max(bodyLoI, lowerI)
                nextT = math.max(tR, hiUseI)
                nextB = math.min(bR, loUseI)
                nextH = nextT - nextB
                heightOkI = nextH <= maxH and nextH > syminfo.mintick
                if heightOkI
                    tR := nextT
                    bR := nextB
                    lR := int(math.min(lR, bar_index - i))
            else
                if pastSeedI
                    missN := missN + 1
                    if missN > missLimit
                        break
        else
            break
    [tR, bR, lR]
overlapOrNear(float tA, float bA, float tN, float bN) =>
    bt = atr * mergeThreshold
    sameBand = sameRegime(tA, bA, tN, bN, bt)
    iouNow = overlapIoU(tA, bA, tN, bN)
    sameBand or iouNow > 0.12
gapTrendVeto(int gapB) =>
    gb = math.max(0, gapB)
    gapInScope = gb >= 3 and gb <= mergeGapBarsEff
    strongAdx = useTrendFil and not na(adx) and adx > maxAdx * 1.25
    strongEma = not na(dEmF) and not na(atr) and math.abs(dEmF) > atr * hardEmaSlopeAtr
    strongLr = not na(dLrF) and not na(atr) and math.abs(dLrF) > atr * hardLrSlopeAtr
    shortGap = gb <= math.max(2, effMinBars)
    strongSlopeGap = strongEma and strongLr
    strongGap = idleER > hardMaxER or idleDriftRat > hardMaxDriftV or strongSlopeGap or (strongAdx and not shortGap)
    gapInScope and strongGap
tryMerge(float t0, float b0, int l0, float pTop, float pBot, int pL, int pR, bool gapTrendBlkMerge) =>
    float tR = t0
    float bR = b0
    int lR = l0
    bool mR = false
    hasPrior = not na(pTop) and not na(pBot) and pL >= 0 and pR >= 0
    if useMerge and hasPrior
        gapB = math.max(0, l0 - pR - 1)
        gapTrendMergeOk = not gapTrendBlkMerge
        if gapB <= mergeGapBarsEff and gapTrendMergeOk
            bt = atr * mergeThreshold
            iou0 = overlapIoU(pTop, pBot, t0, b0)
            topsAlign = math.abs(t0 - pTop) <= bt
            botsAlign = math.abs(b0 - pBot) <= bt
            edgesAlign = topsAlign and botsAlign
            midP = (pTop + pBot) * 0.5
            midN = (t0 + b0) * 0.5
            midClose = math.abs(midN - midP) <= bt * 1.12
            regimeOk = sameRegime(pTop, pBot, t0, b0, bt)
            hP = pTop - pBot
            hN = t0 - b0
            hMax = math.max(hP, hN)
            hMin = math.max(math.min(hP, hN), syminfo.mintick)
            hRatioM = hMax / hMin
            looseOverlapOk = midClose and iou0 > 0.028 and hRatioM <= 2.25
            edgeLooseOk = math.abs(t0 - pTop) <= bt * 1.35 and math.abs(b0 - pBot) <= bt * 1.35 and hRatioM <= 2.15
            nearBand = regimeOk or edgesAlign or edgeLooseOk or looseOverlapOk
            strictBridgeOk = iou0 >= mergeMinOv and edgesAlign
            bridgeOk = allowBridgeMerge ? nearBand : strictBridgeOk
            mergedH = math.max(t0, pTop) - math.min(b0, pBot)
            heightOk = mergedH <= atr * mxHtAtr * 1.12 and mergedH > syminfo.mintick and mergedH <= hMax * 1.85
            if bridgeOk and heightOk
                tR := math.max(t0, pTop)
                bR := math.min(b0, pBot)
                lR := int(math.min(l0, pL))
                mR := true
    [tR, bR, lR, mR]
chartBgLuma() => (color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)) / 3.0
isDarkPalette = themeSel == "Light" ? false : themeSel == "Dark" ? true : chartBgLuma() < 140.0
fillStdTr = int(math.min(96, math.max(60, transpIn + (isDarkPalette ? 8 : 10))))
fillHqTr = int(math.min(94, math.max(60, transpIn + (isDarkPalette ? 2 : 5))))
fillMtfTr = int(math.min(95, math.max(60, transpIn + (isDarkPalette ? 4 : 8))))
oldFillStdTr = int(math.min(98, fillStdTr + 2))
oldFillHqTr = int(math.min(97, fillHqTr + 5))
oldFillMtfTr = int(math.min(97, fillMtfTr + 5))
brStdTr = isDarkPalette ? 42 : 56
brHqTr = isDarkPalette ? 20 : 38
brMtfTr = isDarkPalette ? 16 : 34
brExpiredTr = isDarkPalette ? 62 : 66
brBreakTr = isDarkPalette ? 12 : 26
labelBgTr = isDarkPalette ? 76 : 82
labelGap = math.max(nz(atr, syminfo.mintick) * 0.18, syminfo.mintick * 8.0)
zoneFillColor(bool mtfZone, bool qualityZone, bool oldZone) => mtfZone ? color.new(colMtfZoneIn, oldZone ? oldFillMtfTr : fillMtfTr) : qualityZone ? color.new(colHighQIn, oldZone ? oldFillHqTr : fillHqTr) : color.new(colNeutralZoneIn, oldZone ? oldFillStdTr : fillStdTr)
zoneBorderColor(bool mtfZone, bool qualityZone) => mtfZone ? color.new(colMtfZoneIn, brMtfTr) : qualityZone ? color.new(colHighQIn, brHqTr) : color.new(colNeutralZoneIn, brStdTr)
zoneBorderWidth(bool mtfZone, bool qualityZone) => mtfZone or qualityZone ? 2 : 1
zoneLabelBgColor(bool mtfZone, bool qualityZone) => mtfZone ? color.new(colMtfZoneIn, labelBgTr) : qualityZone ? color.new(colHighQIn, labelBgTr) : color.new(colNeutralZoneIn, labelBgTr)
zoneLabelText(bool mtfZone, bool qualityZone, int scoreVal) =>
    baseTxt = mtfZone ? "HTF Confluence" : qualityZone ? "Prime Range" : "Base Range"
    baseTxt + (showScoreTag ? " | " + str.tostring(scoreVal) : "")
breakoutBorderColor(bool isBreakout, int dir) => isBreakout ? (dir == 1 ? color.new(colBullBrkIn, brBreakTr) : dir == -1 ? color.new(colBearBrkIn, brBreakTr) : color.new(colExpiredBrdIn, brExpiredTr)) : color.new(colExpiredBrdIn, brExpiredTr)
var bool active = false
var bool cand = false
var bool isQuality = false
var bool isMtfQuality = false
var float cTop = na
var float cBot = na
var int cStart = -1
var int cBars = 0
var int ctT = 0
var int ctB = 0
var float sumDev = 0.0
var int sumDevN = 0
var float oAtCand = na
var float pathSumD = 0.0
var int oscCross = 0
var int sidePrev = 0
var int bigBodyCt = 0
var float refMid0 = na
var int badBasicCand = 0
var int badBasicAct = 0
var box bx = na
var box pBx = na
var float tPx = na
var float bPx = na
var int zAct = 0
var label lbb = na
var label pLb = na
buf = atr * bufK
inBoxCore = active and not na(tPx) and not na(bPx) and close <= tPx and close >= bPx
outUpCls = active and not na(tPx) and close > tPx + buf
outDnCls = active and not na(bPx) and close < bPx - buf
covTolNow = atr * covTolAtr
activeReady = active and not na(tPx) and not na(bPx) and not na(atr) and atr > 0.0
actSameRegime = false
if activeReady and not na(rhBest) and not na(rlBest)
    actSameRegime := sameRegime(tPx, bPx, rhBest, rlBest, covTolNow)
float actUpper = na
float actLower = na
float actBarRange = syminfo.mintick
float actInter = 0.0
if activeReady
    actUpper := tPx + covTolNow
    actLower := bPx - covTolNow
    actBarRange := math.max(high - low, syminfo.mintick)
actBodyMid = (open + close) * 0.5
if activeReady
    actInter := math.max(0.0, math.min(high, actUpper) - math.max(low, actLower))
actOverlap = actInter / actBarRange
actBodyHi = math.max(open, close)
actBodyLo = math.min(open, close)
actBodyRange = math.max(actBodyHi - actBodyLo, syminfo.mintick)
float actBodyInter = 0.0
if activeReady
    actBodyInter := math.max(0.0, math.min(actBodyHi, actUpper) - math.max(actBodyLo, actLower))
actBodyOverlap = actBodyInter / actBodyRange
actCloseOk = activeReady and close <= actUpper and close >= actLower
actBodyOk = activeReady and actBodyMid <= actUpper and actBodyMid >= actLower
actOverlapOk = activeReady and actOverlap >= 0.30
actBodyOverlapOk = activeReady and actBodyOverlap >= 0.50
actBarOk = actCloseOk or actBodyOk or actOverlapOk or actBodyOverlapOk
actTrendRaw = hardTrendVeto(idleER, idleDriftRat, 0)
actAdxMissing = na(adx)
actLagTrendOk = not useTrendFil or actAdxMissing or adx <= maxAdx * 1.95
actLocalDriftOk = idleDriftRat <= 0.92
actLocalErOk = idleER <= 0.92
actLocalFlatOk = actLocalDriftOk and actLocalErOk and actLagTrendOk
actCorePriceOk = actCloseOk or actBodyOk or actBodyOverlapOk
actTrendOk = not actTrendRaw or ((actSameRegime or actCorePriceOk) and actLocalFlatOk)
actRangeState = basicNow or rngStartRelaxed or actSameRegime or (actLocalFlatOk and actCorePriceOk)
zoneContinueOk = confirm and activeReady and (actBarOk or actSameRegime) and actRangeState and actTrendOk
var int upC = 0
var int dnC = 0
if confirm
    if active
        if outUpCls
            if zoneContinueOk
                upC := 0
                dnC := 0
            else
                upC := upC + 1
                dnC := 0
        else if outDnCls
            if zoneContinueOk
                dnC := 0
                upC := 0
            else
                dnC := dnC + 1
                upC := 0
        else
            if useFbProt and inBoxCore
                upC := 0
                dnC := 0
            else
                upC := 0
                dnC := 0
    else
        upC := 0
        dnC := 0
brk = confirm and active and (upC >= brkN or dnC >= brkN)
boxAllowedAct = not na(atr) and not na(tPx) and not na(bPx) and atr > 0.0 and (tPx - bPx) <= atr * atrMultEff * 1.08
if confirm
    if active
        if boxAllowedAct or zoneContinueOk
            badBasicAct := 0
        else
            badBasicAct := badBasicAct + 1
    else
        badBasicAct := 0
tooTall = confirm and active and not na(tPx) and not na(bPx) and (tPx - bPx) > atr * mxHtAtr and not zoneContinueOk
strEnd = confirm and active and badBasicAct > effGrace and not zoneContinueOk
needX = confirm and (brk or strEnd or tooTall)
var int brK = 0
if needX
    brK := brk ? (close > tPx + buf ? 1 : close < bPx - buf ? -1 : 0) : 0
    int lfSv = pLf
    if not na(bx)
        lfSv := int(box.get_left(bx))
        box.set_right(bx, bar_index)
        box.set_top(bx, tPx)
        box.set_bottom(bx, bPx)
        doneFill = zoneFillColor(isMtfQuality, isQuality, true)
        brkBordCol = breakoutBorderColor(brk, brK)
        box.set_bgcolor(bx, showFill ? doneFill : color.new(doneFill, 100))
        box.set_border_color(bx, showBorder ? brkBordCol : color.new(brkBordCol, 100))
        box.set_border_width(bx, showBorder ? (brk ? 2 : 1) : 1)
        if lfSv >= 0
            pLf := lfSv
        pBx := bx
    pT := tPx
    pB := bPx
    pRg := bar_index
    if showLbl and not na(lbb)
        finalLabelBg = zoneLabelBgColor(isMtfQuality, isQuality)
        finalLabelX = int(math.round((math.max(lfSv, 0) + bar_index) * 0.5))
        finalLabelY = bPx - labelGap
        label.set_xy(lbb, finalLabelX, finalLabelY)
        label.set_color(lbb, finalLabelBg)
        label.set_textcolor(lbb, labelTextColorIn)
        label.set_size(lbb, labelSizeUse)
        pLb := lbb
    bx := na
    active := false
    isQuality := false
    isMtfQuality := false
    tPx := na
    bPx := na
    zAct := 0
    lbb := na
else
    brK := 0
gapB_rawForMerge = pRg >= 0 ? leftAlignBest - pRg - 1 : 0
gapB_forMerge = math.max(0, gapB_rawForMerge)
gapTrendBlocked_forMerge = gapTrendVeto(gapB_forMerge)
ovNear_rh = overlapOrNear(pT, pB, rhBest, rlBest)
resetCandNow = false
if confirm
    if cand
        cTop := math.max(cTop, high)
        cBot := math.min(cBot, low)
        hCand = cTop - cBot
        rngWide = hCand > atr * mxCandRangeMult
        relaxBasic = hCand <= bandMult or anyBandOk
        if relaxBasic
            badBasicCand := 0
        else
            badBasicCand := badBasicCand + 1
        driftEnd = hCand > syminfo.mintick ? math.abs(px - oAtCand) / hCand : 1.0
        pathEff = pathSumD + atr * pathFloorAtr
        erCand = pathEff > syminfo.mintick ? math.abs(px - oAtCand) / pathEff : 1.0
        candLocalWidthOk = hCand <= bandMult * 1.42
        candLocalDriftOk = driftEnd <= maxDriftRatio * 1.46
        candLocalErOk = erCand <= maxEfficiency * 1.52
        candLocalImpulseOk = bigBodyCt <= maxImpulseBars
        candLocalFlatOk = candLocalWidthOk and candLocalDriftOk and candLocalErOk and candLocalImpulseOk
        if candLocalFlatOk
            badBasicCand := 0
        cancelHardTrend = hardTrendVeto(erCand, driftEnd, bigBodyCt)
        cancelHard = cBars >= 4 and cancelHardTrend and not candLocalFlatOk
        cancelCand = rngWide or cancelHard or badBasicCand > effGrace
        if cancelCand
            resetCandNow := true
        else
            pathSumD := pathSumD + math.abs(px - nz(px[1], px))
            cBars := cBars + 1
            midC = (cTop + cBot) / 2.0
            halfC = (cTop - cBot) / 2.0
            if halfC > syminfo.mintick
                sumDev := sumDev + math.abs(px - midC) / halfC
                sumDevN := sumDevN + 1
            sd = px > midC ? 1 : px < midC ? -1 : 0
            if sd != 0
                if sidePrev != 0 and sd != sidePrev
                    oscCross := oscCross + 1
                sidePrev := sd
            brOne = math.max(high - low, syminfo.mintick)
            bdRat = brOne > 0.0 ? math.abs(px - open) / brOne : 0.0
            if math.abs(px - open) > atr * impBodyAtr and bdRat >= impBodyPct
                bigBodyCt := bigBodyCt + 1
            if high >= cTop - touchTol
                ctT := ctT + 1
            if low <= cBot + touchTol
                ctB := ctB + 1
            balA = balanceAvgFromAcc(sumDev, sumDevN, cTop, cBot)
            netPerBar = cBars > 1 ? (px - oAtCand) / float(cBars - 1) : 0.0
            slopeSoft = math.abs(netPerBar) <= atr * 0.36 * 1.28
            oscN = oscCross
            erScr = 100.0 * (1.0 - math.min(1.0, erCand / math.max(maxEfficiency, 1e-6)))
            drScr = 100.0 * (1.0 - math.min(1.0, driftEnd / math.max(maxDriftRatio, 1e-6)))
            oscScr = 100.0 * math.min(1.0, float(oscCross) / float(math.max(minOscillation + 2, 1)))
            fsRaw = promoScore(zoneScoreCore, cBars, ctT, ctB, balA, mildTrendPen, oscScr, drScr, erScr)
            zFin = int(math.round(math.min(100.0, math.max(0.0, fsRaw))))
            hLimPromo = rngStartRelaxed ? atr * atrMultEff * 1.52 : atr * atrMultEff * 1.38
            promoReady = cand and cBars >= effMinBars and hCand <= hLimPromo
            if promoReady
                cTop0 = cTop
                cBot0 = cBot
                cSt0 = cStart
                gapB_rawCandMerge = pRg >= 0 ? cSt0 - pRg - 1 : 0
                gapB_candMerge = math.max(0, gapB_rawCandMerge)
                gapTrendBlocked_candMerge = gapTrendVeto(gapB_candMerge)
                [tFv, bFv, lFv, didMerge] = tryMerge(cTop0, cBot0, cSt0, pT, pB, pLf, pRg, gapTrendBlocked_candMerge)
                tFin = tFv <= bFv ? bFv + syminfo.mintick : tFv
                bFin = bFv
                lFin = lFv
                hFin = tFin - bFin
                hasPriorMerge = useMerge and not na(pT) and not na(pB) and pLf >= 0 and pRg >= 0
                gapWithinMerge = gapB_candMerge <= mergeGapBarsEff
                stitched = hasPriorMerge and gapWithinMerge and didMerge
                driftF = hFin > syminfo.mintick ? math.abs(px - oAtCand) / hFin : 1.0
                midF = hFin > syminfo.mintick ? math.abs((tFin + bFin) * 0.5 - refMid0) / hFin : 0.0
                pathF = pathSumD + atr * pathFloorAtr
                erF = pathF > syminfo.mintick ? math.abs(px - oAtCand) / pathF : 1.0
                hLimDraw = rngStartRelaxed ? atr * atrMultEff * 1.52 : atr * atrMultEff * 1.38
                strongV = hardTrendVeto(erF, driftF, bigBodyCt)
                openGeom = not na(lFin) and lFin <= bar_index and tFin > bFin and hFin <= hLimDraw
                ovNear_fin = overlapOrNear(pT, pB, tFin, bFin)
                dupRecent = not na(pT) and not na(pB) and pRg >= 0 and gapB_candMerge <= dupGapBarsEff and ovNear_fin and not stitched and not gapTrendBlocked_candMerge
                gateSq = sidewaysGate(driftF, erF, midF, oscN, ctT, ctB, bigBodyCt, slopeSoft)
                localTouchCnt = ctT + ctB
                localTouchOk = localTouchCnt >= minTouchCount
                localBandOk = not requireBothBandTouch or (ctT >= 1 and ctB >= 1) or oscN >= minOscillation + 1
                localOscNeed = math.max(1, minOscillation - 1)
                localOscOk = minOscillation <= 0 or oscN >= localOscNeed
                localDriftOk = driftF <= maxDriftRatio * 1.48
                localErOk = erF <= maxEfficiency * 1.58
                localMidOk = midF <= maxDriftRatio * 1.36
                netAbsPromo = math.abs(netPerBar)
                localSlopeAltOk = netAbsPromo <= atr * 0.60
                localSlopeOk = slopeSoft or localSlopeAltOk
                localImpulseOk = bigBodyCt <= maxImpulseBars
                adxMissingPromo = na(adx)
                localAdxOk = not useTrendFil or adxMissingPromo or adx <= maxAdx * 2.15
                localRangeGate = openGeom and localTouchOk and localBandOk and localOscOk and localDriftOk and localErOk and localMidOk and localSlopeOk and localImpulseOk and localAdxOk
                gateOk = gateSq or localRangeGate
                strongOk = not strongV or localRangeGate
                geomOk = openGeom
                dupRecentOk = not dupRecent
                oneActiveDrawOk = not onlyOneActive or not active
                mtfConfluence = mtfConfluenceFor(tFin, bFin)
                preScoreOk = zFin >= effMinStd or (mtfConfluence and zFin + mtfBoostPts >= effMinStd)
                canRefineZone = oneActiveDrawOk and gateOk and strongOk and geomOk and dupRecentOk and preScoreOk
                if canRefineZone
                    covMaxH = atr * mxHtAtr
                    [tCov, bCov, lCov] = coverageRefine(tFin, bFin, lFin, covMaxH)
                    tFin := tCov <= bCov ? bCov + syminfo.mintick : tCov
                    bFin := bCov
                    lFin := lCov
                    mtfConfluenceFinal = mtfConfluenceFor(tFin, bFin)
                    zFinFinal = mtfConfluenceFinal ? int(math.min(100.0, float(zFin + mtfBoostPts))) : zFin
                    wantQuality = gateOk and strongOk and geomOk and dupRecentOk and zFinFinal >= effMinHQ
                    wantStandard = gateOk and strongOk and geomOk and dupRecentOk and not wantQuality and zFinFinal >= effMinStd
                    canDrawZone = wantQuality or wantStandard
                    if canDrawZone
                        resetCandNow := true
                        isQuality := wantQuality
                        isMtfQuality := mtfConfluenceFinal
                        zAct := zFinFinal
                        bgUse = zoneFillColor(mtfConfluenceFinal, wantQuality, false)
                        brdUse = zoneBorderColor(mtfConfluenceFinal, wantQuality)
                        brdWidthUse = zoneBorderWidth(mtfConfluenceFinal, wantQuality)
                        if stitched and not na(pBx)
                            box.delete(pBx)
                            pBx := na
                        if stitched and not na(pLb)
                            label.delete(pLb)
                            pLb := na
                        bx := box.new(lFin, tFin, bar_index, bFin, border_color = showBorder ? brdUse : color.new(brdUse, 100), bgcolor = showFill ? bgUse : color.new(bgUse, 100), border_width = showBorder ? brdWidthUse : 1, xloc = xloc.bar_index)
                        tPx := tFin
                        bPx := bFin
                        active := true
                        if showLbl
                            if not na(lbb)
                                label.delete(lbb)
                            labTxt = zoneLabelText(mtfConfluenceFinal, wantQuality, zAct)
                            labBg = zoneLabelBgColor(mtfConfluenceFinal, wantQuality)
                            labX = int(math.round((lFin + bar_index) * 0.5))
                            labY = bFin - labelGap
                            lbb := label.new(labX, labY, labTxt, style = label.style_label_up, size = labelSizeUse, color = labBg, textcolor = labelTextColorIn)
                        else if not na(lbb)
                            label.delete(lbb)
                            lbb := na
    else if not active
        priorRawG = pRg >= 0 ? leftAlignBest - pRg - 1 : 999999
        priorG = math.max(0, priorRawG)
        btC = atr * mergeThreshold
        hasPriorStart = not na(pT) and not na(pB) and pRg >= 0
        gapWithinStart = priorG >= 0 and priorG <= mergeGapBarsEff
        topDeltaCand = math.abs(rhBest - pT)
        botDeltaCand = math.abs(rlBest - pB)
        edgesNearCand = topDeltaCand <= btC and botDeltaCand <= btC
        sameBandCand = false
        if hasPriorStart
            sameBandCand := sameRegime(pT, pB, rhBest, rlBest, btC)
        bridgePriceOk = sameBandCand or edgesNearCand
        bridgeVetoGapClear = not gapTrendBlocked_forMerge
        bridgeVetoOk = priorG < 3 or priorG > mergeGapBarsEff or bridgeVetoGapClear
        bridgeCand = useMerge and hasPriorStart and gapWithinStart and bridgePriceOk and bridgeVetoOk
        dupCandZone = hasPriorStart and priorG <= dupGapBarsEff and ovNear_rh and not bridgeCand and not gapTrendBlocked_forMerge
        startRangeOk = anyBandOk or rngBest <= bandMult or rngStartRelaxed
        startLocalDriftOk = idleDriftRat <= 0.96
        startLocalErOk = idleER <= 0.96
        startAdxMissing = na(adx)
        startLocalAdxOk = not useTrendFil or startAdxMissing or adx <= maxAdx * 2.15
        startLocalOk = startRangeOk and startLocalDriftOk and startLocalErOk and startLocalAdxOk
        startVetoOk = not startVeto or startLocalOk
        canStart = not dupCandZone and startVetoOk and startRangeOk
        if canStart
            cand := true
            cStart := leftAlignBest
            cBars := 1
            cTop := rhBest
            cBot := rlBest
            ctT := 0
            ctB := 0
            sumDev := 0.0
            sumDevN := 0
            oAtCand := open
            refMid0 := (rhBest + rlBest) / 2.0
            pathSumD := 0.0
            oscCross := 0
            sidePrev := 0
            bigBodyCt := 0
            badBasicCand := 0
            if high >= cTop - touchTol
                ctT := ctT + 1
            if low <= cBot + touchTol
                ctB := ctB + 1
if resetCandNow
    cand := false
    cBars := 0
    ctT := 0
    ctB := 0
    sumDev := 0.0
    sumDevN := 0
    cStart := -1
    pathSumD := 0.0
    oscCross := 0
    sidePrev := 0
    bigBodyCt := 0
    oAtCand := na
    refMid0 := na
    badBasicCand := 0
    cTop := na
    cBot := na
if active and not na(bx)
    box.set_right(bx, bar_index)
    if confirm and zoneContinueOk
        extTop = tPx
        extBot = bPx
        absorbTol = covTolNow * 1.18
        topWickOk = high <= tPx + absorbTol
        botWickOk = low >= bPx - absorbTol
        topBodyOk = actBodyHi <= tPx + absorbTol
        botBodyOk = actBodyLo >= bPx - absorbTol
        if topWickOk
            extTop := math.max(tPx, high)
        else if topBodyOk
            extTop := math.max(tPx, actBodyHi)
        if botWickOk
            extBot := math.min(bPx, low)
        else if botBodyOk
            extBot := math.min(bPx, actBodyLo)
        extH = extTop - extBot
        extOk = extH <= atr * mxHtAtr and extH > syminfo.mintick
        if extOk
            tPx := extTop
            bPx := extBot
            box.set_top(bx, tPx)
            box.set_bottom(bx, bPx)
    updFill = zoneFillColor(isMtfQuality, isQuality, false)
    updBrd = zoneBorderColor(isMtfQuality, isQuality)
    updBrdWidth = zoneBorderWidth(isMtfQuality, isQuality)
    box.set_bgcolor(bx, showFill ? updFill : color.new(updFill, 100))
    box.set_border_color(bx, showBorder ? updBrd : color.new(updBrd, 100))
    box.set_border_width(bx, showBorder ? updBrdWidth : 1)
    lfCur = int(box.get_left(bx))
    if showLbl and not na(lbb)
        liveLabelX = int(math.round((lfCur + bar_index) * 0.5))
        liveLabelY = bPx - labelGap
        label.set_xy(lbb, liveLabelX, liveLabelY)
        liveLabelBg = zoneLabelBgColor(isMtfQuality, isQuality)
        label.set_color(lbb, liveLabelBg)
        label.set_textcolor(lbb, labelTextColorIn)
        label.set_size(lbb, labelSizeUse)
alertcondition(alNew and confirm and active and not nz(active[1], false), title = "New Zone", message = "New Zone on {{ticker}}")
alertcondition(alBrk and confirm and needX and (brK == 1 or brK == -1), title = "Breakout", message = "Breakout on {{ticker}}")
````

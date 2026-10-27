# Aurelian Consensus Bands [JOAT]

- url: https://www.tradingview.com/script/dyX8rfNt-Aurelian-Consensus-Bands-JOAT/
- type: indicator
- pine_id: PUB;44b457be387846f7bcfa6fd53af555a4
- version: 1.0

## Description

[b]Aurelian Consensus Bands [JOAT][/b]

[b]Introduction[/b]

Aurelian Consensus Bands is an open-source price consensus map built around a log-volume profile, dynamic consensus bands, VWAP context, and confirmed-bar signal logic. It is designed to answer a specific question: where is price trading relative to the market's recent volume-weighted agreement zone, and is that move supported by session pressure?

The script plots VPOC, consensus area, boundary bands, session VWAP deviation shells, a dynamic volume node, right-side price rails, managed signal boxes, candle coloring, and a compact top-right dashboard. Its goal is not to predict the future. It provides a structured chart layer for reading acceptance, rejection, and directional pressure around consensus levels.

[image]https://www.tradingview.com/x/VQ2peWDy/[/image]

[b]Core Concepts[/b]

[b]1. Log-Volume Consensus Profile[/b]

The script builds a rolling profile on a logarithmic price canvas. Recent bars contribute volume across high-low rows, with recency weighting applied before the profile is converted into levels. This reduces sensitivity to one-off spikes while preserving important volume clusters.

[pine]
// Conceptual summary
// volume is distributed across log-price rows
// rows are then analyzed for VPOC, mean, and stdev bands
[/pine]

[b]2. VPOC, CA, and Boundary Band[/b]

The engine extracts a volume point of control, consensus area high/low, and wider boundary bands. The midpoint of the consensus area and the VPOC can be blended into the active anchor. Price displacement from that anchor is normalized so the indicator can classify whether price is inside, above, or below the agreement zone.

[b]3. Dual-Anchor Coherence[/b]

Aurelian compares the VPOC view and consensus-area midpoint view. Signals are only stronger when both views agree. If the two anchors conflict, the coherence score falls and the dashboard shows weaker context.

[b]4. VWAP and Session Pressure[/b]

The script adds session VWAP, VWAP deviation shells, synthetic delta pressure, and a dynamic volume node. Qualified signals require more than a simple cross; they also consider whether VWAP and pressure agree with the band event.

[b]5. Right-Side Price Rails and Signal Box[/b]

The current VPOC, anchor, consensus levels, VWAP, and dynamic node are projected to the right edge with price labels. Qualified signals can also create a managed visual box with entry, stop, T1, and T2 levels based on ATR and planned R multiples.

[b]Features[/b]

[list]
[*][b]Rolling log-volume profile:[/b] Builds VPOC, consensus area, and boundary bands from recent price-volume structure
[*][b]Dual-anchor coherence filter:[/b] Compares VPOC and consensus midpoint before qualifying signals
[*][b]VWAP deviation shells:[/b] Adds session VWAP context and upper/lower deviation bands
[*][b]Dynamic volume node:[/b] Tracks a lighter-weight volume anchor for current conditions
[*][b]Candle color blending:[/b] Colors bars using consensus direction and institutional context strength
[*][b]Qualified signal markers:[/b] Uses clean dots/squares rather than arrows or retail-style markers
[*][b]Managed signal box:[/b] Projects entry, stop, T1, and T2 for visual planning only
[*][b]Right-side rails:[/b] Labels VPOC, anchor, CA high/low, VWAP, and node prices at the chart edge
[*][b]Top-right dashboard:[/b] Shows mode, bias, coherence, score, VWAP state, delta, node, quality, and state
[*][b]Confirmed-bar logic:[/b] Main signal events are gated on confirmed bars
[/list]

[b]Input Parameters[/b]

[b]Profile Core:[/b]
[list]
[*]Profile Rows controls profile resolution
[*]Profile Lookback controls how much recent history is used
[*]Recency Weight Span controls how quickly old bars lose influence
[*]Profile Smooth controls smoothing on extracted levels
[/list]

[b]Context and Rails:[/b]
[list]
[*]Show Session VWAP and VWAP Deviation Shells
[*]Show Dynamic Volume Node
[*]Show Right-Side Price Rails
[*]Show Managed Signal Box
[*]Signal Stop ATR Mult and Target R settings
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the anchor[/b]
Use the VPOC and consensus anchor to understand where the market's recent agreement zone sits.

[b]Step 2: Check coherence[/b]
Higher coherence means the VPOC and consensus midpoint agree. Lower coherence suggests mixed structure.

[b]Step 3: Watch VWAP and node context[/b]
Signals carry more context when price, VWAP, delta, and the dynamic node point in the same direction.

[b]Step 4: Use right-side rails[/b]
The rails provide forward reference levels for continuation, rejection, or mean reversion planning.

[b]Indicator Limitations[/b]

[list]
[*]The profile depends on the selected lookback and row resolution
[*]Signals are contextual, not standalone trade recommendations
[*]Very low volume symbols may produce less reliable profile and delta readings
[*]Confirmed-bar logic means signals appear after the bar closes, not before
[/list]

[b]Originality Statement[/b]

Aurelian combines a rolling log-volume consensus profile, dual-anchor coherence, session VWAP deviation context, synthetic pressure, dynamic node tracking, right-edge rails, and managed visual signal boxes in one open-source Pine v6 tool. The purpose is not to merge unrelated indicators, but to create a single acceptance/rejection framework around volume agreement and session context.

[b]Disclaimer[/b]

This script is for educational and informational use only. It is not financial advice and does not ensure any trading outcome. Market behavior is uncertain, and all signals should be evaluated with risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aurelian Consensus Bands [JOAT]", shorttitle="ACB [JOAT]", overlay=true, max_bars_back=5000, max_lines_count=350, max_labels_count=350, max_boxes_count=80)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
string G_PROFILE = "Profile Core"
int profileRows = input.int(360, "Profile Rows", minval=120, maxval=720, group=G_PROFILE, tooltip="Number of log rows used to build the consensus profile.")
int profileLookback = input.int(280, "Profile Lookback", minval=100, maxval=600, group=G_PROFILE, tooltip="Number of confirmed bars used in the profile cache.")
int profileWeightSpan = input.int(84, "Recency Weight Span", minval=20, maxval=240, group=G_PROFILE, tooltip="Older bars receive less influence as the cache ages.")
int profileSmooth = input.int(21, "Profile Smooth", minval=5, maxval=80, group=G_PROFILE, tooltip="Smoothing applied to the extracted profile levels.")
bool updateOnClose = input.bool(true, "Confirmed Bar Only", group=G_PROFILE, tooltip="Keeps the profile and signals anchored to confirmed bars.")

string G_BANDS = "Band Display"
bool showVPOC = input.bool(true, "Show VPOC", group=G_BANDS)
bool showConsensusArea = input.bool(true, "Show Consensus Area", group=G_BANDS)
bool showBoundaryBand = input.bool(true, "Show Boundary Band", group=G_BANDS)
bool showConsensusAnchor = input.bool(true, "Show Consensus Anchor", group=G_BANDS)
bool showClouds = input.bool(true, "Show Gradient Clouds", group=G_BANDS)
bool showCandleTint = input.bool(true, "Color Candles", group=G_BANDS)
bool showSignalDots = input.bool(true, "Show Signal Dots", group=G_BANDS)

string G_CONTEXT = "Institutional Context"
bool showVWAP = input.bool(true, "Show Session VWAP", group=G_CONTEXT)
bool showVWAPBands = input.bool(true, "Show VWAP Deviation Shells", group=G_CONTEXT)
bool showDynamicNode = input.bool(true, "Show Dynamic Volume Node", group=G_CONTEXT)
int vwapDevLength = input.int(80, "VWAP Deviation Length", minval=20, maxval=240, group=G_CONTEXT)
int dynamicNodeLength = input.int(48, "Dynamic Node Length", minval=12, maxval=160, group=G_CONTEXT)
int deltaSmoothLength = input.int(8, "Delta Smooth", minval=2, maxval=34, group=G_CONTEXT)

string G_RAILS = "Right-Side Rails"
bool showRightRails = input.bool(true, "Show Right-Side Price Rails", group=G_RAILS)
bool showSignalBox = input.bool(true, "Show Managed Signal Box", group=G_RAILS)
int railProjection = input.int(22, "Rail Projection Bars", minval=5, maxval=80, group=G_RAILS)
int signalBoxBars = input.int(18, "Signal Box Bars", minval=5, maxval=80, group=G_RAILS)
float riskAtrMult = input.float(1.15, "Signal Stop ATR Mult", minval=0.25, maxval=4.0, step=0.05, group=G_RAILS)
float targetOneR = input.float(1.0, "Target One R", minval=0.25, maxval=5.0, step=0.25, group=G_RAILS)
float targetTwoR = input.float(2.0, "Target Two R", minval=0.50, maxval=8.0, step=0.25, group=G_RAILS)

string G_SIGNAL = "Signals"
string anchorMode = input.string("Consensus", "Anchor Mode", options=["VPOC", "CA-M", "Consensus"], group=G_SIGNAL, tooltip="VPOC = volume node anchor, CA-M = consensus midpoint, Consensus = blended anchor.")
float signalThreshold = input.float(0.35, "Signal Threshold", minval=0.05, maxval=1.00, step=0.05, group=G_SIGNAL, tooltip="Minimum normalized displacement needed to confirm a direction change.")
float coherenceFloor = input.float(0.08, "Coherence Floor", minval=0.00, maxval=0.60, step=0.02, group=G_SIGNAL, tooltip="Suppresses signals when the two anchor views disagree too much.")

string G_STYLE = "Visual Style"
color bullColor = input.color(#0b7788, "Bull Color", group=G_STYLE)
color bearColor = input.color(#9f0808, "Bear Color", group=G_STYLE)
color neutralColor = input.color(#8b949e, "Neutral Color", group=G_STYLE)
color accentColor = input.color(#388bfd, "Accent Color", group=G_STYLE)
color sentinelBullColor = input.color(#00ff00, "Sentinel Bull Accent", group=G_STYLE)
color sentinelBearColor = input.color(#ff1744, "Sentinel Bear Accent", group=G_STYLE)
color vwapColor = input.color(#00e5ff, "VWAP Cyan", group=G_STYLE)
color warningColor = input.color(#ffd93d, "Liquidity Gold", group=G_STYLE)
int bandOpacity = input.int(78, "Band Opacity", minval=0, maxval=100, group=G_STYLE)
int glowOpacity = input.int(88, "Glow Opacity", minval=0, maxval=100, group=G_STYLE)
int lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group=G_STYLE)

string G_DASH = "Dashboard"
bool showDashboard = input.bool(true, "Show Dashboard", group=G_DASH)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.min(math.max(x, lo), hi)

f_safe_div(float num, float den) =>
    den != 0.0 and not na(den) ? num / den : 0.0

f_fmt(float x) =>
    na(x) ? "NA" : str.tostring(x, format.mintick)

f_pct(float x) =>
    na(x) ? "NA" : str.tostring(math.round(x * 100.0)) + "%"

f_row_bg(int row) =>
    row % 2 == 0 ? color.new(#161b22, 0) : color.new(#0d1117, 0)

f_weight(int age, int maxAge, int span) =>
    float a = float(age)
    float m = float(maxAge)
    float s = float(span)
    float raw = 1.0 - a / math.max(1.0, m)
    float ramp = 1.0 - a / math.max(1.0, s)
    f_clamp(math.max(raw, ramp), 0.10, 1.0)

f_line_color(float norm, color bull, color bear) =>
    float n = f_clamp((norm + 1.0) * 50.0, 0.0, 100.0)
    color.from_gradient(n, 0.0, 100.0, bear, bull)

f_sig_color(float norm, color bull, color bear, color neutral) =>
    float centered = f_clamp(math.abs(norm), 0.0, 1.5)
    color strong = norm >= 0 ? bull : bear
    color.from_gradient(centered, 0.0, 1.5, color.new(neutral, 20), strong)

f_pressure_color(float norm, color bull, color bear, color neutral) =>
    float clipped = f_clamp(norm, -1.0, 1.0)
    clipped >= 0 ? color.from_gradient(clipped, 0.0, 1.0, color.new(neutral, 25), bull) : color.from_gradient(math.abs(clipped), 0.0, 1.0, color.new(neutral, 25), bear)

f_strength_bucket(float x) =>
    x >= 0.70 ? "HIGH" : x >= 0.35 ? "MED" : "LOW"

f_set_line(line ln, int x1, float y1, int x2, float y2, color col, styleId, int width) =>
    if not na(ln)
        line.set_xy1(ln, x1, y1)
        line.set_xy2(ln, x2, y2)
        line.set_color(ln, col)
        line.set_style(ln, styleId)
        line.set_width(ln, width)

f_set_label(label lb, int x, float y, string txt, color bg, color fg) =>
    if not na(lb)
        label.set_xy(lb, x, y)
        label.set_text(lb, txt)
        label.set_color(lb, bg)
        label.set_textcolor(lb, fg)

f_profile_levels(float[] profile, float lMin, float step) =>
    int sz = array.size(profile)
    if sz <= 0 or step <= 0
        float mid = na
        [mid, mid, mid, mid, mid]
    else
        float sumV = 0.0
        float sumPos = 0.0
        float peak = 0.0
        int peakIdx = 0
        for i = 0 to sz - 1
            float v = array.get(profile, i)
            sumV += v
            sumPos += v * float(i)
            if v > peak
                peak := v
                peakIdx := i

        if sumV <= 0.0
            float mid = math.exp(lMin + step * float(sz) * 0.5)
            [mid, mid, mid, mid, mid]
        else
            float interpIdx = float(peakIdx)
            if peakIdx > 0 and peakIdx < sz - 1
                float up = array.get(profile, peakIdx + 1)
                float dn = array.get(profile, peakIdx - 1)
                float localSum = up + peak + dn
                if localSum > 0
                    interpIdx := ((peakIdx - 1) * dn + peakIdx * peak + (peakIdx + 1) * up) / localSum

            float vpoc = math.exp(lMin + (interpIdx * step) + (step * 0.5))

            float wMean = sumPos / sumV
            float varSum = 0.0
            for i = 0 to sz - 1
                float v = array.get(profile, i)
                float dev = float(i) - wMean
                varSum += v * dev * dev
            float wStdev = math.sqrt(varSum / sumV)

            int caLoIdx = math.max(0, int(math.round(wMean - wStdev)))
            int caHiIdx = math.min(sz - 1, int(math.round(wMean + wStdev)))
            int bbLoIdx = math.max(0, int(math.round(wMean - 2.0 * wStdev)))
            int bbHiIdx = math.min(sz - 1, int(math.round(wMean + 2.0 * wStdev)))

            float caH = math.exp(lMin + step * float(caHiIdx + 1))
            float caL = math.exp(lMin + step * float(caLoIdx))
            float bbH = math.exp(lMin + step * float(bbHiIdx + 1))
            float bbL = math.exp(lMin + step * float(bbLoIdx))
            [vpoc, caH, caL, bbH, bbL]

// -----------------------------------------------------------------------------
// Cache and profile state
// -----------------------------------------------------------------------------
int lookbackCap = math.max(profileLookback, profileRows)
var float[] logHighCache = array.new_float(0)
var float[] logLowCache = array.new_float(0)
var float[] volCache = array.new_float(0)
var float[] ageWeights = array.new_float(0)
var float[] profile = array.new_float(profileRows, 0.0)
var float[] diff = array.new_float(profileRows + 1, 0.0)

if barstate.isfirst
    for i = 0 to lookbackCap - 1
        array.push(ageWeights, f_weight(i, lookbackCap - 1, profileWeightSpan))

bool isConfirmedBar = barstate.isconfirmed
bool allowUpdate = updateOnClose ? isConfirmedBar : true

if allowUpdate
    array.push(logHighCache, high > 0 ? math.log(high) : na)
    array.push(logLowCache, low > 0 ? math.log(low) : na)
    array.push(volCache, nz(volume) > 0 ? volume : 1.0)
    if array.size(logHighCache) > lookbackCap
        array.shift(logHighCache)
        array.shift(logLowCache)
        array.shift(volCache)

int cacheSize = array.size(logHighCache)
float rawHigh = ta.highest(high, profileLookback)
float rawLow = ta.lowest(low, profileLookback)
float smoothSpan = float(math.max(5, int(math.round(math.sqrt(float(profileLookback))))))
float smoothHigh = ta.ema(rawHigh, int(smoothSpan))
float smoothLow = ta.ema(rawLow, int(smoothSpan))
float canvasHigh = math.max(rawHigh, smoothHigh)
float canvasLow = math.min(smoothLow, math.max(rawLow, syminfo.mintick))
float logMin = na(canvasLow) ? na : math.log(canvasLow)
float logMax = na(canvasHigh) ? na : math.log(canvasHigh)
float logRange = not na(logMin) and not na(logMax) ? logMax - logMin : 0.0
float logStep = logRange > 0.0 ? logRange / float(profileRows) : 0.0

if allowUpdate
    array.fill(diff, 0.0)
    if logStep > 0 and cacheSize > 0
        int maxIdx = cacheSize - 1
        for i = 0 to cacheSize - 1
            int ci = maxIdx - i
            float lH = array.get(logHighCache, ci)
            float lL = array.get(logLowCache, ci)
            float v = array.get(volCache, ci)
            float w = array.get(ageWeights, i < array.size(ageWeights) ? i : array.size(ageWeights) - 1)
            if not na(lH) and not na(lL)
                int rStart = math.max(0, math.min(profileRows - 1, int((lL - logMin) / logStep)))
                int rEnd = math.max(0, math.min(profileRows - 1, int((lH - logMin) / logStep)))
                if rStart <= rEnd
                    float addv = v * w
                    array.set(diff, rStart, array.get(diff, rStart) + addv)
                    array.set(diff, rEnd + 1, array.get(diff, rEnd + 1) - addv)

        float running = 0.0
        for r = 0 to profileRows - 1
            running += array.get(diff, r)
            array.set(profile, r, running)
    else
        array.fill(profile, 0.0)

// -----------------------------------------------------------------------------
// Consensus analysis
// -----------------------------------------------------------------------------
[vpocRaw, caHRaw, caLRaw, bbHRaw, bbLRaw] = f_profile_levels(profile, logMin, logStep)

float vpoc = ta.ema(vpocRaw, profileSmooth)
float caH = ta.ema(caHRaw, profileSmooth)
float caL = ta.ema(caLRaw, profileSmooth)
float bbH = ta.ema(bbHRaw, profileSmooth)
float bbL = ta.ema(bbLRaw, profileSmooth)
float caM = math.sqrt(caH * caL)

float anchorPrice = anchorMode == "VPOC" ? vpoc : anchorMode == "CA-M" ? caM : math.sqrt(vpoc * caM)

float rangeUp = bbH - anchorPrice
float rangeDn = anchorPrice - bbL
float anchorPos = na
if rangeUp > 0 and rangeDn > 0
    anchorPos := close >= anchorPrice ? (close - anchorPrice) / rangeUp : (close - anchorPrice) / rangeDn
anchorPos := f_clamp(anchorPos, -1.5, 1.5)

float vpocPos = na
float vpocUp = bbH - vpoc
float vpocDn = vpoc - bbL
if vpocUp > 0 and vpocDn > 0
    vpocPos := close >= vpoc ? (close - vpoc) / vpocUp : (close - vpoc) / vpocDn
vpocPos := f_clamp(vpocPos, -1.5, 1.5)

float caPos = na
float caUp = bbH - caM
float caDn = caM - bbL
if caUp > 0 and caDn > 0
    caPos := close >= caM ? (close - caM) / caUp : (close - caM) / caDn
caPos := f_clamp(caPos, -1.5, 1.5)

float direction = (vpocPos + caPos) * 0.5
float denom = vpocPos * vpocPos + caPos * caPos
float coherence = denom > 0 ? (2.0 * vpocPos * caPos) / denom : 0.0
float coherenceAbs = math.abs(coherence)
float consensusScore = f_clamp(math.abs(direction) * coherenceAbs, 0.0, 1.5)

color barTone = f_sig_color(direction, bullColor, bearColor, neutralColor)
color anchorTone = f_line_color(anchorPos, bullColor, bearColor)
color consensusTone = direction >= 0 ? color.from_gradient(consensusScore, 0.0, 1.5, color.new(bullColor, 82), bullColor) : color.from_gradient(consensusScore, 0.0, 1.5, color.new(bearColor, 82), bearColor)

// -----------------------------------------------------------------------------
// Context layer: VWAP, volume pressure, dynamic node, and signal qualification
// -----------------------------------------------------------------------------
float atrValue = ta.atr(14)
float sessionVWAP = ta.vwap(hlc3)
float vwapDev = ta.stdev(hlc3 - sessionVWAP, vwapDevLength)
float vwapUpperOne = sessionVWAP + vwapDev
float vwapLowerOne = sessionVWAP - vwapDev
float vwapUpperTwo = sessionVWAP + vwapDev * 2.0
float vwapLowerTwo = sessionVWAP - vwapDev * 2.0
float vwapZ = f_clamp(f_safe_div(close - sessionVWAP, math.max(vwapDev, syminfo.mintick)), -3.0, 3.0)

float candleRange = math.max(high - low, syminfo.mintick)
float syntheticDelta = nz(volume) * (close - open) / candleRange
bool newDailySession = ta.change(time("D")) != 0
var float sessionDelta = 0.0
sessionDelta := newDailySession ? syntheticDelta : nz(sessionDelta[1]) + syntheticDelta
int deltaBasisLength = math.max(5, int(math.round(vwapDevLength / 4.0)))
float deltaBasis = ta.ema(math.abs(syntheticDelta), deltaBasisLength)
float deltaImpulse = f_clamp(f_safe_div(ta.ema(syntheticDelta, deltaSmoothLength), math.max(deltaBasis, 1.0)), -2.0, 2.0)
float deltaBias = f_clamp(f_safe_div(ta.ema(sessionDelta, deltaSmoothLength), math.max(ta.ema(math.abs(sessionDelta), vwapDevLength), 1.0)), -1.0, 1.0)
color deltaTone = f_pressure_color(deltaImpulse * 0.5, sentinelBullColor, sentinelBearColor, neutralColor)

float highestVolume = ta.highest(volume, dynamicNodeLength)
float dynamicNode = ta.valuewhen(volume == highestVolume, hlc3, 0)
float nodeDistanceAtr = f_safe_div(close - dynamicNode, math.max(atrValue, syminfo.mintick))
float bandCompression = f_safe_div(caH - caL, math.max(bbH - bbL, syminfo.mintick))
float expansionPressure = f_clamp((1.0 - bandCompression) + math.abs(vwapZ) * 0.15 + math.abs(deltaImpulse) * 0.10, 0.0, 1.5)
float institutionalScore = f_clamp(consensusScore / 1.5 * 0.45 + coherenceAbs * 0.25 + math.min(math.abs(vwapZ) / 2.0, 1.0) * 0.15 + math.abs(deltaBias) * 0.15, 0.0, 1.0)
bool contextLong = direction > 0 and close > sessionVWAP and deltaBias >= -0.25 and close >= dynamicNode
bool contextShort = direction < 0 and close < sessionVWAP and deltaBias <= 0.25 and close <= dynamicNode
color regimeTone = institutionalScore >= 0.70 ? (direction >= 0 ? sentinelBullColor : sentinelBearColor) : institutionalScore >= 0.35 ? warningColor : neutralColor

// -----------------------------------------------------------------------------
// Visuals
// -----------------------------------------------------------------------------
plotVpoc = plot(showVPOC ? vpoc : na, "VPOC", color=color.new(anchorTone, 0), linewidth=lineWidth + 1, style=plot.style_linebr)
plotCaH = plot(showConsensusArea ? caH : na, "CA High", color=color.new(neutralColor, 10), linewidth=1, style=plot.style_linebr)
plotCaL = plot(showConsensusArea ? caL : na, "CA Low", color=color.new(neutralColor, 10), linewidth=1, style=plot.style_linebr)
plotBbH = plot(showBoundaryBand ? bbH : na, "BB High", color=color.new(bearColor, 0), linewidth=1, style=plot.style_linebr)
plotBbL = plot(showBoundaryBand ? bbL : na, "BB Low", color=color.new(bullColor, 0), linewidth=1, style=plot.style_linebr)
plotAnchor = plot(showConsensusAnchor ? anchorPrice : na, "Consensus Anchor", color=color.new(consensusTone, 0), linewidth=lineWidth, style=plot.style_linebr)
plotCloseRef = plot(showClouds ? close : na, "Close Ref", color=color.new(color.white, 100), display=display.none)

fill(plotBbH, plotCaH, showClouds ? color.new(bearColor, bandOpacity) : na, title="Upper Band Cloud")
fill(plotCaH, plotVpoc, showClouds ? color.new(neutralColor, math.min(95, bandOpacity + 8)) : na, title="Upper Consensus Cloud")
fill(plotVpoc, plotCaL, showClouds ? color.new(neutralColor, math.min(95, bandOpacity + 8)) : na, title="Lower Consensus Cloud")
fill(plotCaL, plotBbL, showClouds ? color.new(bullColor, bandOpacity) : na, title="Lower Band Cloud")
fill(plotAnchor, plotCloseRef, showClouds ? color.new(consensusTone, glowOpacity) : na, title="Consensus Glow")

plotVwap = plot(showVWAP ? sessionVWAP : na, "Session VWAP", color=color.new(vwapColor, 0), linewidth=2, style=plot.style_linebr)
plotVwapUpperOne = plot(showVWAPBands ? vwapUpperOne : na, "VWAP Upper One", color=color.new(vwapColor, 62), linewidth=1, style=plot.style_linebr)
plotVwapLowerOne = plot(showVWAPBands ? vwapLowerOne : na, "VWAP Lower One", color=color.new(vwapColor, 62), linewidth=1, style=plot.style_linebr)
plotVwapUpperTwo = plot(showVWAPBands ? vwapUpperTwo : na, "VWAP Upper Two", color=color.new(vwapColor, 84), linewidth=1, style=plot.style_linebr)
plotVwapLowerTwo = plot(showVWAPBands ? vwapLowerTwo : na, "VWAP Lower Two", color=color.new(vwapColor, 84), linewidth=1, style=plot.style_linebr)
plotDynamicNode = plot(showDynamicNode ? dynamicNode : na, "Dynamic Volume Node", color=color.new(warningColor, 18), linewidth=1, style=plot.style_cross)

fill(plotVwapUpperOne, plotVwap, showVWAPBands ? color.new(vwapColor, 92) : na, title="VWAP Upper Inner Glow")
fill(plotVwap, plotVwapLowerOne, showVWAPBands ? color.new(vwapColor, 92) : na, title="VWAP Lower Inner Glow")
fill(plotVwapUpperTwo, plotVwapUpperOne, showVWAPBands ? color.new(sentinelBearColor, 94) : na, title="VWAP Upper Exhaustion Shell")
fill(plotVwapLowerOne, plotVwapLowerTwo, showVWAPBands ? color.new(sentinelBullColor, 94) : na, title="VWAP Lower Exhaustion Shell")

color candleComposite = institutionalScore >= 0.55 ? color.from_gradient(institutionalScore, 0.55, 1.0, barTone, regimeTone) : barTone
barcolor(showCandleTint ? candleComposite : na, title="Consensus Candle Tint")

// Small state markers without arrows
bool crossAboveAnchor = ta.crossover(close, anchorPrice)
bool crossBelowAnchor = ta.crossunder(close, anchorPrice)
bool bullishShift = isConfirmedBar and not na(anchorPrice) and crossAboveAnchor and coherenceAbs >= coherenceFloor and consensusScore >= signalThreshold and close > caL
bool bearishShift = isConfirmedBar and not na(anchorPrice) and crossBelowAnchor and coherenceAbs >= coherenceFloor and consensusScore >= signalThreshold and close < caH
bool consensusLong = bullishShift and direction > 0
bool consensusShort = bearishShift and direction < 0
bool institutionalLong = consensusLong and contextLong and institutionalScore >= 0.45
bool institutionalShort = consensusShort and contextShort and institutionalScore >= 0.45

plotshape(showSignalDots and consensusLong, title="Consensus Long Dot", style=shape.circle, location=location.belowbar, color=color.new(bullColor, 0), size=size.tiny, text="L", textcolor=color.white)
plotshape(showSignalDots and consensusShort, title="Consensus Short Dot", style=shape.circle, location=location.abovebar, color=color.new(bearColor, 0), size=size.tiny, text="S", textcolor=color.white)
plotshape(showSignalDots and bullishShift and not consensusLong, title="Neutral Bull Shift", style=shape.diamond, location=location.belowbar, color=color.new(accentColor, 0), size=size.tiny, text="B", textcolor=color.white)
plotshape(showSignalDots and bearishShift and not consensusShort, title="Neutral Bear Shift", style=shape.diamond, location=location.abovebar, color=color.new(accentColor, 0), size=size.tiny, text="B", textcolor=color.white)
plotshape(showSignalDots and institutionalLong, title="Institutional Long Core", style=shape.square, location=location.belowbar, color=color.new(sentinelBullColor, 0), size=size.tiny, text="Q", textcolor=color.white)
plotshape(showSignalDots and institutionalLong, title="Institutional Long Glow", style=shape.square, location=location.belowbar, color=color.new(sentinelBullColor, 82), size=size.small, text="", textcolor=color.white)
plotshape(showSignalDots and institutionalShort, title="Institutional Short Core", style=shape.square, location=location.abovebar, color=color.new(sentinelBearColor, 0), size=size.tiny, text="Q", textcolor=color.white)
plotshape(showSignalDots and institutionalShort, title="Institutional Short Glow", style=shape.square, location=location.abovebar, color=color.new(sentinelBearColor, 82), size=size.small, text="", textcolor=color.white)

alertcondition(consensusLong, title="Aurelian Consensus Long", message="Aurelian Consensus Bands [JOAT]: bullish consensus shift on confirmed bar.")
alertcondition(consensusShort, title="Aurelian Consensus Short", message="Aurelian Consensus Bands [JOAT]: bearish consensus shift on confirmed bar.")
alertcondition(institutionalLong, title="Aurelian Qualified Long", message="Aurelian Consensus Bands [JOAT]: qualified long with VWAP and delta context.")
alertcondition(institutionalShort, title="Aurelian Qualified Short", message="Aurelian Consensus Bands [JOAT]: qualified short with VWAP and delta context.")

// -----------------------------------------------------------------------------
// Right-side price rails and managed signal box
// -----------------------------------------------------------------------------
var line railVpoc = na
var line railAnchor = na
var line railCaH = na
var line railCaL = na
var line railVwap = na
var line railNode = na
var label railVpocLabel = na
var label railAnchorLabel = na
var label railCaHLabel = na
var label railCaLLabel = na
var label railVwapLabel = na
var label railNodeLabel = na

if barstate.isfirst
    railVpoc := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(bullColor, 0), style=line.style_solid, width=2)
    railAnchor := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(accentColor, 0), style=line.style_solid, width=2)
    railCaH := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(sentinelBearColor, 10), style=line.style_dashed, width=1)
    railCaL := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(sentinelBullColor, 10), style=line.style_dashed, width=1)
    railVwap := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(vwapColor, 0), style=line.style_dotted, width=2)
    railNode := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(warningColor, 0), style=line.style_dotted, width=1)
    railVpocLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 25), textcolor=color.white, size=size.small)
    railAnchorLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 25), textcolor=color.white, size=size.small)
    railCaHLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 45), textcolor=color.white, size=size.tiny)
    railCaLLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 45), textcolor=color.white, size=size.tiny)
    railVwapLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 25), textcolor=color.white, size=size.small)
    railNodeLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 35), textcolor=color.white, size=size.tiny)

int railX1 = bar_index
int railX2 = bar_index + railProjection
color railHide = color.new(color.white, 100)
if barstate.islast
    f_set_line(railVpoc, railX1, vpoc, railX2, vpoc, showRightRails and showVPOC ? color.new(anchorTone, 0) : railHide, line.style_solid, lineWidth + 1)
    f_set_line(railAnchor, railX1, anchorPrice, railX2, anchorPrice, showRightRails and showConsensusAnchor ? color.new(consensusTone, 0) : railHide, line.style_solid, lineWidth)
    f_set_line(railCaH, railX1, caH, railX2, caH, showRightRails and showConsensusArea ? color.new(sentinelBearColor, 15) : railHide, line.style_dashed, 1)
    f_set_line(railCaL, railX1, caL, railX2, caL, showRightRails and showConsensusArea ? color.new(sentinelBullColor, 15) : railHide, line.style_dashed, 1)
    f_set_line(railVwap, railX1, sessionVWAP, railX2, sessionVWAP, showRightRails and showVWAP ? color.new(vwapColor, 0) : railHide, line.style_dotted, 2)
    f_set_line(railNode, railX1, dynamicNode, railX2, dynamicNode, showRightRails and showDynamicNode ? color.new(warningColor, 0) : railHide, line.style_dotted, 1)
    f_set_label(railVpocLabel, railX2, vpoc, showRightRails and showVPOC ? "VPOC " + f_fmt(vpoc) : "", color.new(#161b22, showRightRails ? 25 : 100), color.new(anchorTone, showRightRails ? 0 : 100))
    f_set_label(railAnchorLabel, railX2, anchorPrice, showRightRails and showConsensusAnchor ? "ANCH " + f_fmt(anchorPrice) : "", color.new(#161b22, showRightRails ? 25 : 100), color.new(consensusTone, showRightRails ? 0 : 100))
    f_set_label(railCaHLabel, railX2, caH, showRightRails and showConsensusArea ? "CA-H " + f_fmt(caH) : "", color.new(#161b22, showRightRails ? 45 : 100), color.new(sentinelBearColor, showRightRails ? 0 : 100))
    f_set_label(railCaLLabel, railX2, caL, showRightRails and showConsensusArea ? "CA-L " + f_fmt(caL) : "", color.new(#161b22, showRightRails ? 45 : 100), color.new(sentinelBullColor, showRightRails ? 0 : 100))
    f_set_label(railVwapLabel, railX2, sessionVWAP, showRightRails and showVWAP ? "VWAP " + f_fmt(sessionVWAP) : "", color.new(#161b22, showRightRails ? 25 : 100), color.new(vwapColor, showRightRails ? 0 : 100))
    f_set_label(railNodeLabel, railX2, dynamicNode, showRightRails and showDynamicNode ? "NODE " + f_fmt(dynamicNode) : "", color.new(#161b22, showRightRails ? 35 : 100), color.new(warningColor, showRightRails ? 0 : 100))

var box signalBox = na
var line signalEntryLine = na
var line signalStopLine = na
var line signalTargetOneLine = na
var line signalTargetTwoLine = na
var label signalEntryLabel = na
var label signalStopLabel = na
var label signalTargetOneLabel = na
var label signalTargetTwoLabel = na

bool createLongBox = showSignalBox and institutionalLong
bool createShortBox = showSignalBox and institutionalShort
if createLongBox or createShortBox
    if not na(signalBox)
        box.delete(signalBox)
    if not na(signalEntryLine)
        line.delete(signalEntryLine)
    if not na(signalStopLine)
        line.delete(signalStopLine)
    if not na(signalTargetOneLine)
        line.delete(signalTargetOneLine)
    if not na(signalTargetTwoLine)
        line.delete(signalTargetTwoLine)
    if not na(signalEntryLabel)
        label.delete(signalEntryLabel)
    if not na(signalStopLabel)
        label.delete(signalStopLabel)
    if not na(signalTargetOneLabel)
        label.delete(signalTargetOneLabel)
    if not na(signalTargetTwoLabel)
        label.delete(signalTargetTwoLabel)

    bool longBox = createLongBox
    color boxTone = longBox ? sentinelBullColor : sentinelBearColor
    float entryPrice = close
    float stopCandidate = longBox ? math.min(bbL, close - atrValue * riskAtrMult) : math.max(bbH, close + atrValue * riskAtrMult)
    float stopPrice = na(stopCandidate) ? (longBox ? close - atrValue * riskAtrMult : close + atrValue * riskAtrMult) : stopCandidate
    float riskUnit = math.max(math.abs(entryPrice - stopPrice), syminfo.mintick)
    float targetOne = longBox ? entryPrice + riskUnit * targetOneR : entryPrice - riskUnit * targetOneR
    float targetTwo = longBox ? entryPrice + riskUnit * targetTwoR : entryPrice - riskUnit * targetTwoR
    float boxTop = math.max(entryPrice, targetTwo)
    float boxBottom = math.min(entryPrice, targetTwo)
    int boxRight = bar_index + signalBoxBars
    signalBox := box.new(bar_index, boxTop, boxRight, boxBottom, xloc=xloc.bar_index, bgcolor=color.new(boxTone, 92), border_color=color.new(boxTone, 15), border_width=1, border_style=line.style_dashed)
    signalEntryLine := line.new(bar_index, entryPrice, boxRight, entryPrice, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.white, 10), width=2, style=line.style_solid)
    signalStopLine := line.new(bar_index, stopPrice, boxRight, stopPrice, xloc=xloc.bar_index, extend=extend.none, color=color.new(sentinelBearColor, longBox ? 0 : 70), width=1, style=line.style_dashed)
    signalTargetOneLine := line.new(bar_index, targetOne, boxRight, targetOne, xloc=xloc.bar_index, extend=extend.none, color=color.new(boxTone, 25), width=1, style=line.style_dotted)
    signalTargetTwoLine := line.new(bar_index, targetTwo, boxRight, targetTwo, xloc=xloc.bar_index, extend=extend.none, color=color.new(boxTone, 0), width=2, style=line.style_dotted)
    signalEntryLabel := label.new(boxRight, entryPrice, "Entry " + f_fmt(entryPrice), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#30363d, 12), textcolor=color.white, size=size.tiny)
    signalStopLabel := label.new(boxRight, stopPrice, "Stop " + f_fmt(stopPrice), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(sentinelBearColor, 18), textcolor=color.white, size=size.tiny)
    signalTargetOneLabel := label.new(boxRight, targetOne, "T1 " + f_fmt(targetOne), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(boxTone, 35), textcolor=color.white, size=size.tiny)
    signalTargetTwoLabel := label.new(boxRight, targetTwo, "T2 " + f_fmt(targetTwo), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(boxTone, 18), textcolor=color.white, size=size.tiny)

// -----------------------------------------------------------------------------
// Dashboard
// -----------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 12, bgcolor=color.new(#0d1117, 8), border_color=color.new(#30363d, 20), border_width=1, frame_color=color.new(#388bfd, 35), frame_width=1)
string modeLabel = anchorMode == "VPOC" ? "VPOC" : anchorMode == "CA-M" ? "CA-M" : "CONSENSUS"
string biasLabel = direction > 0 ? "BULL" : direction < 0 ? "BEAR" : "NEUTRAL"
string coherenceLabel = str.tostring(math.round(coherenceAbs * 100.0)) + "%"
string scoreLabel = str.tostring(math.round(consensusScore * 100.0)) + "%"
string positionLabel = str.tostring(math.round((anchorPos + 1.5) * 33.333)) + "%"
string bandLabel = na(bbH) or na(bbL) ? "NA" : str.tostring(math.round(((bbH - bbL) / close) * 10000.0) / 100.0) + "%"
string deltaLabel = deltaImpulse > 0.25 ? "BID +" : deltaImpulse < -0.25 ? "ASK +" : "MIXED"
string vwapLabel = vwapZ > 1.5 ? "HIGH EXT" : vwapZ < -1.5 ? "LOW EXT" : close >= sessionVWAP ? "ABOVE" : "BELOW"
string nodeLabel = nodeDistanceAtr > 0.25 ? "ABOVE" : nodeDistanceAtr < -0.25 ? "BELOW" : "AT NODE"
string qualityLabel = f_strength_bucket(institutionalScore)
string statusLabel = institutionalLong ? "LONG +" : institutionalShort ? "SHORT +" : consensusLong ? "LONG" : consensusShort ? "SHORT" : "WAIT"
color statusColor = institutionalLong ? sentinelBullColor : institutionalShort ? sentinelBearColor : consensusLong ? bullColor : consensusShort ? bearColor : neutralColor

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "AURELIAN", text_color=color.white, bgcolor=color.new(#161b22, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "ACB [JOAT]", text_color=color.new(accentColor, 0), bgcolor=color.new(#161b22, 0), text_halign=text.align_right)
    table.cell(dash, 0, 1, "Mode", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(1), text_halign=text.align_left)
    table.cell(dash, 1, 1, modeLabel, text_color=color.white, bgcolor=f_row_bg(1), text_halign=text.align_right)
    table.cell(dash, 0, 2, "Bias", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(2), text_halign=text.align_left)
    table.cell(dash, 1, 2, biasLabel, text_color=color.new(statusColor, 0), bgcolor=f_row_bg(2), text_halign=text.align_right)
    table.cell(dash, 0, 3, "Coherence", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(3), text_halign=text.align_left)
    table.cell(dash, 1, 3, coherenceLabel, text_color=color.new(anchorTone, 0), bgcolor=f_row_bg(3), text_halign=text.align_right)
    table.cell(dash, 0, 4, "Score", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(4), text_halign=text.align_left)
    table.cell(dash, 1, 4, scoreLabel, text_color=color.new(consensusTone, 0), bgcolor=f_row_bg(4), text_halign=text.align_right)
    table.cell(dash, 0, 5, "Anchor", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(5), text_halign=text.align_left)
    table.cell(dash, 1, 5, positionLabel, text_color=color.new(anchorTone, 0), bgcolor=f_row_bg(5), text_halign=text.align_right)
    table.cell(dash, 0, 6, "Bands", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(6), text_halign=text.align_left)
    table.cell(dash, 1, 6, bandLabel, text_color=color.new(neutralColor, 0), bgcolor=f_row_bg(6), text_halign=text.align_right)
    table.cell(dash, 0, 7, "VWAP", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(7), text_halign=text.align_left)
    table.cell(dash, 1, 7, vwapLabel, text_color=color.new(vwapColor, 0), bgcolor=f_row_bg(7), text_halign=text.align_right)
    table.cell(dash, 0, 8, "Delta", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(8), text_halign=text.align_left)
    table.cell(dash, 1, 8, deltaLabel, text_color=color.new(deltaTone, 0), bgcolor=f_row_bg(8), text_halign=text.align_right)
    table.cell(dash, 0, 9, "Node", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(9), text_halign=text.align_left)
    table.cell(dash, 1, 9, nodeLabel, text_color=color.new(warningColor, 0), bgcolor=f_row_bg(9), text_halign=text.align_right)
    table.cell(dash, 0, 10, "Quality", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(10), text_halign=text.align_left)
    table.cell(dash, 1, 10, qualityLabel, text_color=color.new(regimeTone, 0), bgcolor=f_row_bg(10), text_halign=text.align_right)
    table.cell(dash, 0, 11, "State", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(11), text_halign=text.align_left)
    table.cell(dash, 1, 11, statusLabel, text_color=color.new(statusColor, 0), bgcolor=f_row_bg(11), text_halign=text.align_right)
````

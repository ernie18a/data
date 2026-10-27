# Auric Reference Crucible [JOAT]

- url: https://www.tradingview.com/script/M5JcKR8r-Auric-Reference-Crucible-JOAT/
- type: indicator
- pine_id: PUB;e1ad856d54a04b14bc5bf632700709e2
- version: 1.0

## Description

[b]Auric Reference Crucible [JOAT][/b]

[b]Introduction[/b]

Auric Reference Crucible is an open-source reference-price state engine. It tracks daily open, weekly open, monthly open, and previous close, then classifies how price behaves around each anchor.

The indicator is built for traders who use opening prices and prior closes as decision levels but want a structured way to separate untouched levels, tests, reclaims, rejections, and active control.

[image]https://www.tradingview.com/x/7SjdDnKw/[/image]

[b]Core Concepts[/b]

[b]1. Multi-Timeframe Reference Anchors[/b]
Daily, weekly, and monthly opens are tracked as higher-timeframe anchors. Previous close is tracked separately. Each reference can be enabled or disabled.

[b]2. Anchor State Classification[/b]
Each reference is classified by interaction state: untouched, touched, tested, reclaimed, rejected, or active control. This creates a state machine instead of a static horizontal-line tool.

[b]3. ATR Touch and Reaction Bands[/b]
ATR defines touch distance and reaction band thickness so levels adapt to each symbol's current volatility.

[b]4. Control Score[/b]
The script scores anchors using state, distance, pressure, and reaction behavior. The strongest anchor becomes the active control reference.

[b]5. Reclaim and Reject Execution Zones[/b]
When the active reference and confirmation logic agree, the script can draw compact long or short execution rails with entry, stop, TP1, and TP2.

[b]Features[/b]

[list]
[*][b]Daily, weekly, monthly, and previous close references:[/b] Core anchors used for session and swing context.
[*][b]Reference state machine:[/b] Tracks touch, test, reclaim, and reject behavior.
[*][b]Dominant control anchor:[/b] Scores references so the most relevant level is emphasized.
[*][b]ATR reaction bands:[/b] Volatility-adjusted zones around active references.
[*][b]Confirmed state changes:[/b] Optional confirmed-bar logic reduces intrabar repaint risk.
[*][b]Execution rails:[/b] Optional long/short plans with stop and target references.
[*][b]Fade untouched anchors:[/b] Keeps inactive references less visually dominant.
[*][b]Dashboard:[/b] Shows anchor state, bias, and control information.
[*][b]Alerts:[/b] Anchor touch, reclaim, reject, long crucible, and short crucible.
[/list]

[b]Input Parameters[/b]

[b]References:[/b] Show Daily Open, Show Weekly Open, Show Monthly Open, Show Previous Close.

[b]Signals:[/b] Touch Zone ATR, Reaction Band ATR, Reclaim Confirmation Bars, Wick Rejection Multiple, Confirmed-Bar State Changes.

[b]Execution and Visuals:[/b] Trend Filter EMA, Pressure Window, Minimum Control Score, Stop ATR, TP1 R, TP2 R, Execution Cooldown Bars, Stored Setup Zones, Reaction Bands, Dashboard, Execution Rails, Signal Zones, Reference Price Tags.

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the active reference[/b]
Start with the dashboard. It shows which anchor is currently most relevant and whether price is treating that anchor as bullish, bearish, or neutral.

[b]Step 2: Watch reclaim and reject states[/b]
A reclaim means price moved back through a reference with confirmation. A reject means price tested the area and failed to hold through it.

[b]Step 3: Use execution rails after confirmation[/b]
When a long or short crucible appears, use the plotted entry, stop, and target references as a structured review plan.

[b]Indicator Limitations[/b]

[list]
[*]Higher-timeframe opens update according to exchange/session boundaries.
[*]Reference levels are context zones, not automatic entries.
[*]ATR bands widen during volatility expansion and narrow during quiet periods.
[*]Confirmed-bar mode means some state changes appear after the bar closes.
[/list]

[b]Originality Statement[/b]

Auric Reference Crucible is original in its reference-state approach. It does not simply plot opens and closes; it classifies anchor behavior, scores active control, adapts reaction zones with ATR, and optionally converts confirmed reclaim/reject behavior into structured execution rails.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice and should not be treated as a recommendation to buy or sell. Reference prices can fail, especially during news, gaps, and thin liquidity. Use proper risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Auric Reference Crucible [JOAT]", shorttitle="ARC [JOAT]", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=150, max_bars_back=2000)

// Original JOAT reference-state engine. Tracks D/W/M opens and previous close,
// classifies each anchor, scores the active control level, and draws clean
// volatility-adaptive reaction bands.

string gRefs = "Reference Anchors"
bool showD = input.bool(true, "Show Daily Open", group=gRefs)
bool showW = input.bool(true, "Show Weekly Open", group=gRefs)
bool showM = input.bool(true, "Show Monthly Open", group=gRefs)
bool showP = input.bool(true, "Show Previous Close", group=gRefs)

string gSignals = "Signals"
float touchAtr = input.float(0.22, "Touch Zone ATR", minval=0.02, maxval=2.0, step=0.01, group=gSignals)
float bandAtr = input.float(0.34, "Reaction Band ATR", minval=0.02, maxval=2.0, step=0.01, group=gSignals)
int reclaimBars = input.int(2, "Reclaim Confirmation Bars", minval=1, maxval=6, group=gSignals)
float wickRejectMult = input.float(1.35, "Wick Rejection Multiple", minval=0.2, step=0.05, group=gSignals)
bool closeOnly = input.bool(true, "Confirmed-Bar State Changes", group=gSignals)

string gVisual = "Visuals"
bool showBands = input.bool(true, "Show Reaction Bands", group=gVisual)
bool showOnlyActive = input.bool(true, "Fade Untouched Anchors", group=gVisual)
bool showDashboard = input.bool(true, "Show Dashboard", group=gVisual)
bool showControlHalo = input.bool(false, "Show Historical Control Halo", group=gVisual)
bool showExecutionRails = input.bool(true, "Show Execution Rails", group=gVisual)
bool showSignalZones = input.bool(true, "Show Reclaim/Reject Zones", group=gVisual)
bool showAnchorLabels = input.bool(false, "Show Reference Price Tags", group=gVisual)
int leftBars = input.int(24, "Left Extension Bars", minval=8, maxval=1000, group=gVisual)
int rightBars = input.int(12, "Right Extension Bars", minval=5, maxval=300, group=gVisual)
int farFadeAtr = input.int(5, "Fade Distance ATR", minval=1, maxval=30, group=gVisual)

string gExecution = "Execution Model"
int trendLen = input.int(34, "Trend Filter EMA", minval=2, maxval=300, group=gExecution)
int pressureLen = input.int(48, "Pressure Window", minval=5, maxval=300, group=gExecution)
float minScoreForSignal = input.float(2.25, "Minimum Control Score", minval=0.0, maxval=10.0, step=0.05, group=gExecution)
float stopAtr = input.float(1.15, "Stop ATR", minval=0.15, maxval=5.0, step=0.05, group=gExecution)
float tp1R = input.float(1.15, "TP1 R", minval=0.25, maxval=8.0, step=0.05, group=gExecution)
float tp2R = input.float(2.25, "TP2 R", minval=0.25, maxval=12.0, step=0.05, group=gExecution)
int arcCooldownBars = input.int(12, "Execution Cooldown Bars", minval=0, maxval=100, group=gExecution)
int maxSetups = input.int(1, "Stored Setup Zones", minval=1, maxval=30, group=gExecution)

color C_BULL = color.rgb(0, 212, 255)
color C_BEAR = color.rgb(255, 51, 102)
color C_STRONG_BULL = color.rgb(0, 255, 170)
color C_STRONG_BEAR = color.rgb(255, 0, 136)
color C_GOLD = color.rgb(82, 185, 255)
color C_VIOLET = color.rgb(123, 47, 255)
color C_NEUTRAL = color.rgb(138, 148, 166)
color C_PANEL = color.rgb(12, 15, 24, 8)
color C_PANEL_2 = color.rgb(22, 27, 42, 12)
color C_TEXT = color.rgb(230, 236, 245)
color C_DIM = color.rgb(120, 130, 150)
color C_CLEAR = color.rgb(0, 0, 0, 100)

int ST_UNTOUCHED = 0
int ST_TOUCHED = 1
int ST_TESTED = 2
int ST_HELD = 3
int ST_RECLAIMED = 4
int ST_REJECTED = 5

f_shortState(int st) =>
    st == ST_UNTOUCHED ? "-" : st == ST_TOUCHED ? "Touch" : st == ST_TESTED ? "Test" : st == ST_HELD ? "Held" : st == ST_RECLAIMED ? "Reclaim" : st == ST_REJECTED ? "Reject" : "-"

f_stateWeight(int st) =>
    st == ST_RECLAIMED ? 6.0 : st == ST_REJECTED ? 5.0 : st == ST_TOUCHED ? 4.0 : st == ST_TESTED ? 3.0 : st == ST_HELD ? 2.0 : st == ST_UNTOUCHED ? 0.5 : 0.0

f_stateColor(int st, int bias, bool far, bool control) =>
    color base = st == ST_UNTOUCHED ? C_NEUTRAL : st == ST_TOUCHED ? C_GOLD : st == ST_TESTED ? color.rgb(105, 162, 255) : st == ST_HELD ? (bias >= 0 ? C_BULL : C_BEAR) : st == ST_RECLAIMED ? (bias >= 0 ? C_STRONG_BULL : C_STRONG_BEAR) : st == ST_REJECTED ? (bias >= 0 ? C_BEAR : C_BULL) : C_NEUTRAL
    color.new(base, far ? 78 : control ? 0 : st == ST_UNTOUCHED ? 58 : 18)

f_lineStyle(int st, bool far) =>
    line.style_solid

f_updateState(float refPrice, int prevState, int prevBias, int prevCount, float zone, float wickMult, int neededBars, bool allowChange) =>
    int ns = prevState
    int nb = prevBias
    int nc = prevCount
    bool evTouch = false
    bool evReclaim = false
    bool evReject = false
    if allowChange and not na(refPrice)
        bool inZone = low <= refPrice + zone and high >= refPrice - zone
        bool above = close > refPrice + zone
        bool below = close < refPrice - zone
        float rng = math.max(high - low, syminfo.mintick)
        float body = math.max(math.abs(close - open), syminfo.mintick)
        float lowerWick = math.min(open, close) - low
        float upperWick = high - math.max(open, close)
        bool bullReject = inZone and close > refPrice and lowerWick > body * wickMult and close > low + rng * 0.65
        bool bearReject = inZone and close < refPrice and upperWick > body * wickMult and close < low + rng * 0.35
        bool crossedUp = close > refPrice + zone and close[1] <= refPrice
        bool crossedDown = close < refPrice - zone and close[1] >= refPrice
        nc := (above and prevBias <= 0) or (below and prevBias >= 0) ? nc + 1 : 0
        if prevState == ST_UNTOUCHED and inZone
            ns := ST_TOUCHED
            nb := close >= refPrice ? 1 : -1
            evTouch := true
        else if inZone and prevState != ST_UNTOUCHED
            ns := ST_TESTED
        if bullReject or bearReject
            ns := ST_REJECTED
            nb := bullReject ? 1 : -1
            evReject := true
        if crossedUp or crossedDown
            nb := crossedUp ? 1 : -1
            if nc >= neededBars or neededBars <= 1
                ns := ST_RECLAIMED
                evReclaim := true
        if prevState == ST_RECLAIMED and inZone and not evReject
            ns := ST_HELD
    [ns, nb, nc, evTouch, evReclaim, evReject]

f_clamp(float value, float floor, float ceiling) =>
    math.max(floor, math.min(ceiling, value))

f_buyShare(float o, float h, float l, float c) =>
    float rng = math.max(h - l, syminfo.mintick)
    float closePosition = (c - l) / rng
    float bodyDirection = c > o ? 1.0 : c < o ? 0.0 : 0.5
    float bodyPower = math.abs(c - o) / rng
    f_clamp(closePosition * 0.56 + bodyDirection * 0.28 + bodyPower * (bodyDirection - 0.5) * 0.32 + 0.14, 0.0, 1.0)

f_setupColor(bool longSide, float quality) =>
    color.from_gradient(quality, 0.0, 100.0, color.new(C_NEUTRAL, 35), longSide ? C_STRONG_BULL : C_STRONG_BEAR)

f_anchorShort(string anchorName) =>
    anchorName == "Daily Open" ? "D Open" : anchorName == "Weekly Open" ? "W Open" : anchorName == "Monthly Open" ? "M Open" : anchorName == "Previous Close" ? "Prev Close" : anchorName

float atr = ta.atr(14)
float zone = atr * touchAtr
float band = atr * bandAtr
bool allowState = closeOnly ? barstate.isconfirmed : true
float dOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)
float wOpen = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_off)
float mOpen = request.security(syminfo.tickerid, "M", open, lookahead=barmerge.lookahead_off)
float pClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)
bool newDay = ta.change(time("D")) != 0
bool newWeek = ta.change(time("W")) != 0
bool newMonth = ta.change(time("M")) != 0

var int dState = ST_UNTOUCHED
var int wState = ST_UNTOUCHED
var int mState = ST_UNTOUCHED
var int pState = ST_UNTOUCHED
var int dBias = 1
var int wBias = 1
var int mBias = 1
var int pBias = 1
var int dCount = 0
var int wCount = 0
var int mCount = 0
var int pCount = 0
if newDay
    dState := ST_UNTOUCHED
    pState := ST_UNTOUCHED
    dCount := 0
    pCount := 0
if newWeek
    wState := ST_UNTOUCHED
    wCount := 0
if newMonth
    mState := ST_UNTOUCHED
    mCount := 0

[dN, dB, dC, dTouch, dReclaim, dReject] = f_updateState(dOpen, dState, dBias, dCount, zone, wickRejectMult, reclaimBars, allowState)
[wN, wB, wC, wTouch, wReclaim, wReject] = f_updateState(wOpen, wState, wBias, wCount, zone, wickRejectMult, reclaimBars, allowState)
[mN, mB, mC, mTouch, mReclaim, mReject] = f_updateState(mOpen, mState, mBias, mCount, zone, wickRejectMult, reclaimBars, allowState)
[pN, pB, pC, pTouch, pReclaim, pReject] = f_updateState(pClose, pState, pBias, pCount, zone, wickRejectMult, reclaimBars, allowState)
dState := dN
wState := wN
mState := mN
pState := pN
dBias := dB
wBias := wB
mBias := mB
pBias := pB
dCount := dC
wCount := wC
mCount := mC
pCount := pC

f_score(float refPrice, int st) =>
    float distAtr = atr > 0.0 ? math.abs(close - refPrice) / atr : 99.0
    math.max(0.0, 1.0 - distAtr / farFadeAtr) * f_stateWeight(st)

float dScore = showD ? f_score(dOpen, dState) : 0.0
float wScore = showW ? f_score(wOpen, wState) : 0.0
float mScore = showM ? f_score(mOpen, mState) : 0.0
float pScore = showP ? f_score(pClose, pState) : 0.0
float bestScore = math.max(math.max(dScore, wScore), math.max(mScore, pScore))
string controlName = bestScore == 0.0 ? "None" : bestScore == dScore ? "Daily Open" : bestScore == wScore ? "Weekly Open" : bestScore == mScore ? "Monthly Open" : "Previous Close"
int controlBias = bestScore == dScore ? dBias : bestScore == wScore ? wBias : bestScore == mScore ? mBias : pBias
float controlPrice = bestScore == dScore ? dOpen : bestScore == wScore ? wOpen : bestScore == mScore ? mOpen : pClose

float trendMean = ta.ema(close, trendLen)
float trendSlope = trendMean - trendMean[3]
bool trendBull = close > trendMean and trendSlope >= 0.0
bool trendBear = close < trendMean and trendSlope <= 0.0
float share = f_buyShare(open, high, low, close)
float buyVol = volume * share
float sellVol = volume * (1.0 - share)
float pressureDenom = math.sum(buyVol + sellVol, pressureLen)
float pressureScore = pressureDenom > 0.0 ? math.sum(buyVol - sellVol, pressureLen) / pressureDenom * 100.0 : 0.0
bool pressureBull = pressureScore > 3.0
bool pressureBear = pressureScore < -3.0
bool controlInRange = not na(controlPrice) and high >= controlPrice - zone and low <= controlPrice + zone
bool anyTouch = dTouch or wTouch or mTouch or pTouch
bool anyReclaim = dReclaim or wReclaim or mReclaim or pReclaim
bool anyReject = dReject or wReject or mReject or pReject
bool longAnchorEvent = (dReclaim and dBias >= 0) or (wReclaim and wBias >= 0) or (mReclaim and mBias >= 0) or (pReclaim and pBias >= 0) or (dReject and dBias >= 0) or (wReject and wBias >= 0) or (mReject and mBias >= 0) or (pReject and pBias >= 0)
bool shortAnchorEvent = (dReclaim and dBias < 0) or (wReclaim and wBias < 0) or (mReclaim and mBias < 0) or (pReclaim and pBias < 0) or (dReject and dBias < 0) or (wReject and wBias < 0) or (mReject and mBias < 0) or (pReject and pBias < 0)
float controlDistanceAtr = atr > 0.0 and not na(controlPrice) ? math.abs(close - controlPrice) / atr : 99.0
float longQuality = 0.0
longQuality += bestScore >= minScoreForSignal ? 22.0 : bestScore * 6.0
longQuality += trendBull ? 20.0 : close > trendMean ? 10.0 : 0.0
longQuality += pressureBull ? 18.0 : pressureScore > 0.0 ? 9.0 : 0.0
longQuality += controlBias >= 0 ? 16.0 : 0.0
longQuality += controlInRange or controlDistanceAtr <= 0.75 ? 12.0 : 0.0
longQuality += close > open ? 8.0 : 0.0
longQuality += anyReclaim ? 4.0 : 0.0
longQuality := f_clamp(longQuality, 0.0, 100.0)
float shortQuality = 0.0
shortQuality += bestScore >= minScoreForSignal ? 22.0 : bestScore * 6.0
shortQuality += trendBear ? 20.0 : close < trendMean ? 10.0 : 0.0
shortQuality += pressureBear ? 18.0 : pressureScore < 0.0 ? 9.0 : 0.0
shortQuality += controlBias < 0 ? 16.0 : 0.0
shortQuality += controlInRange or controlDistanceAtr <= 0.75 ? 12.0 : 0.0
shortQuality += close < open ? 8.0 : 0.0
shortQuality += anyReclaim ? 4.0 : 0.0
shortQuality := f_clamp(shortQuality, 0.0, 100.0)
bool longSetup = allowState and barstate.isconfirmed and longAnchorEvent and bestScore >= minScoreForSignal and longQuality >= 58.0 and longQuality > shortQuality
bool shortSetup = allowState and barstate.isconfirmed and shortAnchorEvent and bestScore >= minScoreForSignal and shortQuality >= 58.0 and shortQuality > longQuality
var int lastArcSetupBar = na
bool arcSetupReady = na(lastArcSetupBar) or bar_index - lastArcSetupBar > arcCooldownBars
longSetup := longSetup and arcSetupReady
shortSetup := shortSetup and arcSetupReady
if longSetup or shortSetup
    lastArcSetupBar := bar_index
float longStop = math.min(controlPrice - zone, low - atr * stopAtr)
float shortStop = math.max(controlPrice + zone, high + atr * stopAtr)
float longRisk = math.max(close - longStop, syminfo.mintick)
float shortRisk = math.max(shortStop - close, syminfo.mintick)
float longTp1 = close + longRisk * tp1R
float longTp2 = close + longRisk * tp2R
float shortTp1 = close - shortRisk * tp1R
float shortTp2 = close - shortRisk * tp2R

var line[] refLines = array.new<line>()
var box[] refBoxes = array.new<box>()
var label[] refLabels = array.new<label>()
var line[] execLines = array.new<line>()
var box[] execBoxes = array.new<box>()
var label[] execLabels = array.new<label>()

f_clear() =>
    while array.size(refLines) > 0
        line.delete(array.pop(refLines))
    while array.size(refBoxes) > 0
        box.delete(array.pop(refBoxes))
    while array.size(refLabels) > 0
        label.delete(array.pop(refLabels))

f_clearExecution() =>
    while array.size(execLines) > 0
        line.delete(array.pop(execLines))
    while array.size(execBoxes) > 0
        box.delete(array.pop(execBoxes))
    while array.size(execLabels) > 0
        label.delete(array.pop(execLabels))

f_pruneExecution() =>
    int maxLines = maxSetups * 4
    while array.size(execLines) > maxLines
        line.delete(array.shift(execLines))
    while array.size(execBoxes) > maxSetups * 2
        box.delete(array.shift(execBoxes))
    while array.size(execLabels) > maxSetups
        label.delete(array.shift(execLabels))

f_execLine(int x1, int x2, float y, color col, style, int width) =>
    array.push(execLines, line.new(x1, y, x2, y, xloc=xloc.bar_index, extend=extend.none, color=col, style=style, width=width))

f_drawSetup(bool longSide, float entry, float stopLevel, float tpOne, float tpTwo, float quality, string anchorName) =>
    if showExecutionRails
        if maxSetups == 1
            f_clearExecution()
        int x1 = bar_index
        int x2 = bar_index + rightBars
        color sideColor = f_setupColor(longSide, quality)
        color riskColor = C_STRONG_BEAR
        color rewardColor = C_STRONG_BULL
        float riskTop = math.max(entry, stopLevel)
        float riskBottom = math.min(entry, stopLevel)
        float rewardTop = math.max(entry, tpTwo)
        float rewardBottom = math.min(entry, tpTwo)
        if showSignalZones
            array.push(execBoxes, box.new(x1, rewardTop, x2, rewardBottom, xloc=xloc.bar_index, border_color=color.new(rewardColor, 18), bgcolor=color.new(rewardColor, 88)))
            array.push(execBoxes, box.new(x1, riskTop, x2, riskBottom, xloc=xloc.bar_index, border_color=color.new(riskColor, 18), bgcolor=color.new(riskColor, 88)))
        f_execLine(x1, x2, entry, color.new(C_TEXT, 4), line.style_solid, 2)
        f_execLine(x1, x2, stopLevel, color.new(riskColor, 0), line.style_solid, 2)
        f_execLine(x1, x2, tpOne, color.new(C_BULL, 0), line.style_solid, 1)
        f_execLine(x1, x2, tpTwo, color.new(rewardColor, 0), line.style_solid, 2)
        string sideText = longSide ? "ARC BUY" : "ARC SELL"
        string qualityText = str.tostring(quality, "#")
        string labelText = sideText + "\nRef " + f_anchorShort(anchorName) + "\nQ " + qualityText + "\nEntry " + str.tostring(entry, format.mintick) + "\nStop " + str.tostring(stopLevel, format.mintick) + "\nTP1 " + str.tostring(tpOne, format.mintick) + "\nTP2 " + str.tostring(tpTwo, format.mintick)
        array.push(execLabels, label.new(x2, entry, labelText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(sideColor, 8), textcolor=longSide ? color.rgb(5, 9, 12) : color.white, size=size.small))
        f_pruneExecution()

f_draw(bool enabled, string name, float price, int st, int bias, bool isControl) =>
    if enabled and not na(price)
        bool far = atr > 0.0 and math.abs(close - price) > atr * farFadeAtr
        bool visible = not showOnlyActive or st != ST_UNTOUCHED or isControl
        if visible
            int x1 = bar_index - leftBars
            int x2 = bar_index + rightBars
            color lc = f_stateColor(st, bias, far, isControl)
            array.push(refLines, line.new(x1, price, x2, price, color=lc, width=isControl ? 3 : st == ST_UNTOUCHED ? 1 : 2, style=f_lineStyle(st, far)))
            if showBands and st != ST_UNTOUCHED and (isControl or not far)
                array.push(refBoxes, box.new(x1, price + band, x2, price - band, border_color=C_CLEAR, bgcolor=color.new(bias >= 0 ? C_BULL : C_BEAR, isControl ? 84 : 90)))
            if showAnchorLabels and (isControl or (not far and st != ST_UNTOUCHED))
                array.push(refLabels, label.new(x2, price, (isControl ? "CONTROL " : "") + f_anchorShort(name) + "\n" + f_shortState(st), style=label.style_label_left, color=color.new(lc, far ? 45 : 10), textcolor=C_TEXT, size=size.small))

if barstate.islast
    f_clear()
    f_draw(showD, "Daily Open", dOpen, dState, dBias, controlName == "Daily Open")
    f_draw(showW, "Weekly Open", wOpen, wState, wBias, controlName == "Weekly Open")
    f_draw(showM, "Monthly Open", mOpen, mState, mBias, controlName == "Monthly Open")
    f_draw(showP, "Previous Close", pClose, pState, pBias, controlName == "Previous Close")

color controlColor = controlBias >= 0 ? f_setupColor(true, longQuality) : f_setupColor(false, shortQuality)
plot(showControlHalo and not na(controlPrice) ? controlPrice : na, "ARC Control Core", color=color.new(controlColor, 0), linewidth=2, style=plot.style_linebr)
plot(showControlHalo and not na(controlPrice) ? controlPrice : na, "ARC Control Glow", color=color.new(controlColor, 76), linewidth=8, style=plot.style_linebr)
upperHalo = plot(showControlHalo and not na(controlPrice) ? controlPrice + band : na, "ARC Upper Crucible", color=color.new(controlColor, 72), linewidth=1, style=plot.style_linebr)
lowerHalo = plot(showControlHalo and not na(controlPrice) ? controlPrice - band : na, "ARC Lower Crucible", color=color.new(controlColor, 72), linewidth=1, style=plot.style_linebr)
fill(upperHalo, lowerHalo, color=showControlHalo ? color.new(controlColor, 90) : na, title="ARC Control Reaction Field")
plot(showControlHalo ? trendMean : na, "ARC Trend Mean", color=color.new(C_VIOLET, 40), linewidth=1)

if longSetup
    f_drawSetup(true, close, longStop, longTp1, longTp2, longQuality, controlName)
if shortSetup
    f_drawSetup(false, close, shortStop, shortTp1, shortTp2, shortQuality, controlName)

barcolor(not na(controlPrice) and bestScore > 0 ? color.new(close >= controlPrice ? C_BULL : C_BEAR, longSetup or shortSetup ? 12 : 65) : na)

var table dash = table.new(position.top_right, 3, 10, border_width=1, border_color=color.new(C_VIOLET, 55), frame_color=color.new(C_VIOLET, 30), bgcolor=C_PANEL)
var bool dashMerged = false
f_cell(int col, int row, string cellText, color txtColor, color bgColor) =>
    table.cell(dash, col, row, cellText, text_color=txtColor, bgcolor=bgColor, text_size=size.small)
f_row(int row, string name, int st, int bias, bool enabled) =>
    color bg = row % 2 == 0 ? C_PANEL_2 : C_PANEL
    f_cell(0, row, enabled ? name : "", enabled ? C_TEXT : C_DIM, bg)
    f_cell(1, row, enabled ? f_shortState(st) : "", enabled ? f_stateColor(st, bias, false, false) : C_DIM, bg)
    f_cell(2, row, enabled ? (bias >= 0 ? "Bull" : "Bear") : "", enabled ? (bias >= 0 ? C_BULL : C_BEAR) : C_DIM, bg)

if barstate.islast and showDashboard
    if not dashMerged
        table.merge_cells(dash, 0, 0, 2, 0)
        table.merge_cells(dash, 0, 6, 2, 6)
        table.merge_cells(dash, 0, 9, 2, 9)
        dashMerged := true
    table.cell(dash, 0, 0, "Auric Reference", text_color=C_TEXT, bgcolor=color.new(C_VIOLET, 20), text_size=size.small)
    f_cell(0, 1, "Anchor", C_DIM, C_PANEL)
    f_cell(1, 1, "State", C_DIM, C_PANEL)
    f_cell(2, 1, "Bias", C_DIM, C_PANEL)
    f_row(2, "D Open", dState, dBias, showD)
    f_row(3, "W Open", wState, wBias, showW)
    f_row(4, "M Open", mState, mBias, showM)
    f_row(5, "P Close", pState, pBias, showP)
    table.cell(dash, 0, 6, controlName == "None" ? "No active control" : controlName + " controls", text_color=controlBias >= 0 ? C_BULL : C_BEAR, bgcolor=C_PANEL_2, text_size=size.small)
    f_cell(0, 7, "Long Q", C_DIM, C_PANEL)
    f_cell(1, 7, str.tostring(longQuality, "#"), f_setupColor(true, longQuality), C_PANEL)
    f_cell(2, 7, longSetup ? "ARMED" : pressureBull ? "Bid" : "-", longSetup ? C_STRONG_BULL : pressureBull ? C_BULL : C_DIM, C_PANEL)
    f_cell(0, 8, "Short Q", C_DIM, C_PANEL_2)
    f_cell(1, 8, str.tostring(shortQuality, "#"), f_setupColor(false, shortQuality), C_PANEL_2)
    f_cell(2, 8, shortSetup ? "ARMED" : pressureBear ? "Offer" : "-", shortSetup ? C_STRONG_BEAR : pressureBear ? C_BEAR : C_DIM, C_PANEL_2)
    table.cell(dash, 0, 9, anyTouch ? "Anchor touch active" : anyReclaim ? "Anchor reclaimed" : anyReject ? "Anchor rejected" : "Waiting for reference contact", text_color=anyReclaim ? C_STRONG_BULL : anyReject ? C_STRONG_BEAR : anyTouch ? C_GOLD : C_DIM, bgcolor=C_PANEL, text_size=size.small)

alertcondition(dTouch or wTouch or mTouch or pTouch, "ARC Anchor Touch [JOAT]", "Auric Reference Crucible [JOAT]: a reference anchor was touched.")
alertcondition(dReclaim or wReclaim or mReclaim or pReclaim, "ARC Anchor Reclaim [JOAT]", "Auric Reference Crucible [JOAT]: a reference anchor was reclaimed.")
alertcondition(dReject or wReject or mReject or pReject, "ARC Anchor Reject [JOAT]", "Auric Reference Crucible [JOAT]: a reference anchor rejected price.")
alertcondition(longSetup, "ARC Long Crucible [JOAT]", "Auric Reference Crucible [JOAT]: confirmed long reference execution setup.")
alertcondition(shortSetup, "ARC Short Crucible [JOAT]", "Auric Reference Crucible [JOAT]: confirmed short reference execution setup.")
````

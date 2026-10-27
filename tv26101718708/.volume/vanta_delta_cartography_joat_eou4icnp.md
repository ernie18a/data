# Vanta Delta Cartography [JOAT]

- url: https://www.tradingview.com/script/EOu4ICNp-Vanta-Delta-Cartography-JOAT/
- type: indicator
- pine_id: PUB;ca857e93fea644dd84d6b89473a8d883
- version: 1.0

## Description

[b]Vanta Delta Cartography [JOAT][/b]

[b]Introduction[/b]

Vanta Delta Cartography is an open-source liquidity and auction-mapping indicator. It combines session VWAP bands, a developing volume profile, POC/value-area/VWMP references, estimated CVD impulse, pivot-confirmed divergence, absorption scoring, naked POC memory, and compact execution plans.

The goal is to show where the active session is accepting value, where pressure is imbalanced, and where a confirmed bid-side or ask-side plan appears.

[image]https://www.tradingview.com/x/BeRtqBtR/[/image]

[b]Core Concepts[/b]

[b]1. Manual Session VWAP[/b]
The script calculates session VWAP from cumulative price-volume and volume during the configured active session. Weighted deviation bands create inner and outer auction zones around VWAP.

[b]2. Developing Volume Profile[/b]
The active range is divided into rows. The script estimates total volume, buy pressure, and sell pressure inside each row, then derives POC, value area high, value area low, VWMP, and imbalance shelves.

[b]3. Estimated CVD Impulse[/b]
CVD is estimated from candle-derived delta. Fast and slow CVD lines create impulse context, while pivot-confirmed divergence identifies disagreement between price and participation.

[b]4. Naked POC Memory[/b]
Prior session POC levels can be stored until price revisits them. This gives the chart a memory of unfinished auction references.

[b]5. Auction Quality Gate[/b]
Long and short plans require location, delta, quality score, and a supporting event such as POC reclaim, value-area reaction, divergence, or shelf pressure.

[b]Features[/b]

[list]
[*][b]Session VWAP with deviation bands:[/b] Shows the active auction mean and volatility envelope.
[*][b]Developing profile:[/b] Tracks POC, VAH, VAL, VWMP, and row pressure.
[*][b]Right-side heatmap:[/b] Displays volume and pressure intensity by price row.
[*][b]Imbalance shelves:[/b] Highlights areas where buy or sell pressure dominates.
[*][b]Estimated CVD impulse:[/b] Measures participation direction from candle and volume data.
[*][b]Pivot-confirmed divergence:[/b] Marks bullish or bearish CVD disagreement.
[*][b]Naked POC memory:[/b] Stores prior POC references until revisited.
[*][b]Execution plans:[/b] Draws compact entry, stop, TP1, and TP2 zones for confirmed absorption states.
[*][b]Candle coloring:[/b] Bars can reflect liquidity pressure.
[*][b]Dashboard and alerts:[/b] Includes auction state, POC, value area, VWAP, CVD impulse, divergence, naked POC, and session state.
[/list]

[b]Input Parameters[/b]

[b]Core and Bands:[/b] Active Session, Session Bars Used, Profile Rows, Value Area, Show VWAP Bands, Inner Sigma, Outer Sigma.

[b]Signals and Risk:[/b] Signal Zones, Pivot Left, Pivot Right, Delta Impulse Threshold, Auction Quality Gate, Signal Projection Bars, Signal Cooldown Bars, ATR Stop, ATR Target.

[b]Visuals:[/b] Right Profile Heatmap, POC / VA / VWMP Lines, Naked POC Line, Session Auction Frame, Right Imbalance Shelves, Liquidity Candle Color, Dashboard.

[b]How to Use This Indicator[/b]

[b]Step 1: Read the session auction[/b]
Use VWAP, value area, and POC to determine whether price is accepting above control, below control, or rotating around value.

[b]Step 2: Check pressure shelves[/b]
Imbalance shelves show where estimated participation is concentrated. These areas can act as reaction context.

[b]Step 3: Watch CVD impulse and divergence[/b]
Strong CVD impulse supports continuation. Divergence warns that price and participation are not confirming each other.

[b]Indicator Limitations[/b]

[list]
[*]CVD and pressure are estimated from candles and volume, not true exchange delta.
[*]Volume profile rows are approximations based on chart data and selected lookback.
[*]Session behavior depends on the selected session template.
[*]Divergence uses pivot confirmation and can appear after the pivot candle.
[/list]

[b]Originality Statement[/b]

Vanta Delta Cartography is original in its combined session VWAP, developing profile, pressure heatmap, estimated CVD impulse, pivot divergence, naked POC memory, imbalance shelves, and confirmed execution-plan logic. Each layer supports the same auction question: where is value, where is pressure, and where has participation failed or accepted?

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell. Auction and delta estimates can be inaccurate, especially on symbols with limited volume data. Use independent analysis and risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Vanta Delta Cartography [JOAT]", shorttitle="VDC [JOAT]", overlay=true, max_lines_count=260, max_boxes_count=260, max_labels_count=140)

// ============================================================================
// Vanta Delta Cartography [JOAT]
// Original institutional liquidity study built from four non-repainting layers:
// 1. Session VWAP with weighted deviation bands and auction-side gradient.
// 2. Developing volume profile with POC, value area, VWMP, and imbalance shelves.
// 3. Estimated CVD impulse, pivot-confirmed divergence, and absorption scoring.
// 4. Compact right-side execution plans with separated reward and risk zones.
// All actionable states are gated by barstate.isconfirmed.
// ============================================================================

// ============================================================================
// Palette: dark institutional neon
// ============================================================================
color colBull        = color.rgb(33, 225, 190)
color colBullStrong  = color.rgb(126, 255, 192)
color colBear        = color.rgb(255, 83, 121)
color colBearStrong  = color.rgb(255, 42, 102)
color colControl     = color.rgb(68, 176, 255)
color colViolet      = color.rgb(86, 118, 255)
color colNeutral     = color.rgb(137, 150, 170)
color colHud         = color.rgb(11, 18, 27)
color colHudSoft     = color.new(colHud, 76)
color colReward      = color.rgb(72, 255, 178)
color colRisk        = color.rgb(255, 52, 100)
color colFrame       = color.rgb(35, 86, 120)

// ============================================================================
// Inputs
// ============================================================================
string groupCore = "Core"
string sessionSpec = input.session("0930-1600", "Active Session", group=groupCore)
int profileBarsLimit = input.int(180, "Session Bars Used", minval=50, maxval=500, group=groupCore)
int profileRows = input.int(28, "Profile Rows", minval=14, maxval=56, group=groupCore)
float valueAreaPct = input.float(0.70, "Value Area", minval=0.50, maxval=0.90, step=0.01, group=groupCore)

string groupBands = "VWAP"
bool showVwap = input.bool(true, "Show VWAP Bands", group=groupBands)
float sigmaOne = input.float(1.0, "Inner Sigma", minval=0.5, maxval=3.0, step=0.1, group=groupBands)
float sigmaTwo = input.float(2.0, "Outer Sigma", minval=1.0, maxval=5.0, step=0.1, group=groupBands)

string groupSignals = "Signals"
bool showSignalZones = input.bool(true, "Signal Zones", group=groupSignals)
int pivotLeft = input.int(3, "Pivot Left", minval=1, maxval=10, group=groupSignals)
int pivotRight = input.int(3, "Pivot Right", minval=1, maxval=10, group=groupSignals)
float impulseThreshold = input.float(0.12, "Delta Impulse Threshold", minval=0.02, maxval=0.50, step=0.01, group=groupSignals)
float qualityGate = input.float(72.0, "Auction Quality Gate", minval=40.0, maxval=98.0, step=1.0, group=groupSignals)
int signalExtend = input.int(16, "Signal Projection Bars", minval=6, maxval=80, group=groupSignals)
int signalCooldownBars = input.int(12, "Signal Cooldown Bars", minval=0, maxval=100, group=groupSignals)
int maxSignalPlans = input.int(6, "Stored Auction Plans", minval=3, maxval=25, group=groupSignals)

string groupRisk = "Risk"
float stopAtr = input.float(1.15, "ATR Stop", minval=0.25, maxval=5.0, step=0.05, group=groupRisk)
float targetAtr = input.float(1.90, "ATR Target", minval=0.50, maxval=8.0, step=0.05, group=groupRisk)

string groupVisuals = "Visuals"
bool showHeatmap = input.bool(true, "Right Profile Heatmap", group=groupVisuals)
bool showProfileLines = input.bool(false, "POC / VA / VWMP Lines", group=groupVisuals)
bool showNakedPocLine = input.bool(false, "Show Naked POC Line", group=groupVisuals)
bool showAuctionFrame = input.bool(true, "Session Auction Frame", group=groupVisuals)
bool showImbalanceShelves = input.bool(true, "Right Imbalance Shelves", group=groupVisuals)
float shelfGate = input.float(0.18, "Shelf Imbalance Gate", minval=0.05, maxval=0.45, step=0.01, group=groupVisuals)
bool colorCandles = input.bool(true, "Liquidity Candle Color", group=groupVisuals)
bool showDashboard = input.bool(true, "Dashboard", group=groupVisuals)
int profileRightOffset = input.int(42, "Profile Right Offset", minval=12, maxval=140, group=groupVisuals)

// ============================================================================
// Utility functions
// ============================================================================
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

f_range(float h, float l) =>
    math.max(h - l, syminfo.mintick)

// Estimated buy share from candle anatomy. This is not exchange bid/ask data;
// it is a consistent approximation using close location, body size, and side.
f_buy_share(float o, float h, float l, float c) =>
    float rng = f_range(h, l)
    float closePos = (c - l) / rng
    float bodyShare = math.abs(c - o) / rng
    float sideBias = c >= o ? 1.0 : 0.0
    f_clamp(0.17 + closePos * 0.43 + bodyShare * 0.20 + sideBias * 0.20, 0.05, 0.95)

f_sum_float(float[] arr) =>
    float total = 0.0
    for i = 0 to array.size(arr) - 1
        total += array.get(arr, i)
    total

f_argmax_float(float[] arr) =>
    int best = 0
    float bestVal = array.get(arr, 0)
    for i = 1 to array.size(arr) - 1
        float v = array.get(arr, i)
        if v > bestVal
            bestVal := v
            best := i
    best

f_clear_boxes(box[] boxes) =>
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))

f_trim_boxes(box[] boxes, int maxItems) =>
    while array.size(boxes) > maxItems
        box.delete(array.shift(boxes))

f_trim_lines(line[] lines, int maxItems) =>
    while array.size(lines) > maxItems
        line.delete(array.shift(lines))

f_trim_labels(label[] labels, int maxItems) =>
    while array.size(labels) > maxItems
        label.delete(array.shift(labels))

f_quality_color(float quality, bool bidSide) =>
    color.from_gradient(quality, 40.0, 100.0, colNeutral, bidSide ? colBullStrong : colBearStrong)

f_plan_text(bool bidSide, float quality, string reason, float entry, float stop, float tpOne, float tpTwo) =>
    string planTitle = bidSide ? "VDC BID ABSORB" : "VDC ASK ABSORB"
    planTitle + "\n" + reason + "\nQ " + str.tostring(quality, "#") + "\nEntry " + str.tostring(entry, format.mintick) + "\nStop " + str.tostring(stop, format.mintick) + "\nTP1 " + str.tostring(tpOne, format.mintick) + "\nTP2 " + str.tostring(tpTwo, format.mintick)

// ============================================================================
// Session state
// ============================================================================
bool inSession = not na(time(timeframe.period, sessionSpec))
bool newSession = inSession and not inSession[1]
bool endedSession = not inSession and inSession[1]
float atr = ta.atr(14)

var int sessionBars = 0
var float sessionOpen = na
var float sessionHigh = na
var float sessionLow = na

if newSession
    sessionBars := 0
    sessionOpen := open
    sessionHigh := high
    sessionLow := low

if inSession
    sessionBars += 1
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow := na(sessionLow) ? low : math.min(sessionLow, low)

int barsUsed = math.max(1, math.min(sessionBars, profileBarsLimit))
float profileHigh = na
float profileLow = na
for i = 0 to profileBarsLimit - 1
    if i < barsUsed
        profileHigh := na(profileHigh) ? high[i] : math.max(profileHigh, high[i])
        profileLow := na(profileLow) ? low[i] : math.min(profileLow, low[i])
float profileRange = math.max(profileHigh - profileLow, syminfo.mintick)
float rowSize = profileRange / profileRows

// ============================================================================
// Manual session VWAP and weighted standard deviation
// ============================================================================
var float sumPV = 0.0
var float sumPV2 = 0.0
var float sumVol = 0.0

if newSession
    sumPV := 0.0
    sumPV2 := 0.0
    sumVol := 0.0

if inSession
    float typical = hlc3
    sumPV += typical * volume
    sumPV2 += typical * typical * volume
    sumVol += volume

float sessionVwap = sumVol > 0.0 ? sumPV / sumVol : na
float variance = sumVol > 0.0 and not na(sessionVwap) ? math.max(sumPV2 / sumVol - sessionVwap * sessionVwap, 0.0) : na
float sigma = not na(variance) ? math.sqrt(variance) : na
float vwapUpOne = not na(sessionVwap) and not na(sigma) ? sessionVwap + sigma * sigmaOne : na
float vwapDnOne = not na(sessionVwap) and not na(sigma) ? sessionVwap - sigma * sigmaOne : na
float vwapUpTwo = not na(sessionVwap) and not na(sigma) ? sessionVwap + sigma * sigmaTwo : na
float vwapDnTwo = not na(sessionVwap) and not na(sigma) ? sessionVwap - sigma * sigmaTwo : na
float vwapDistance = not na(sessionVwap) and atr > 0.0 ? f_clamp((close - sessionVwap) / atr, -2.0, 2.0) : 0.0
color vwapGradient = color.from_gradient(vwapDistance, -2.0, 2.0, colBearStrong, colBullStrong)

// ============================================================================
// Developing profile: volume, buy pressure, sell pressure
// ============================================================================
float[] rowVol = array.new_float(profileRows, 0.0)
float[] rowBuy = array.new_float(profileRows, 0.0)
float[] rowSell = array.new_float(profileRows, 0.0)

if inSession
    for i = 0 to profileBarsLimit - 1
        if i < barsUsed
            float mid = hlc3[i]
            if not na(mid)
                int idxRaw = int(math.floor((mid - profileLow) / rowSize))
                int idx = int(f_clamp(idxRaw, 0, profileRows - 1))
                float share = f_buy_share(open[i], high[i], low[i], close[i])
                float vol = nz(volume[i])
                array.set(rowVol, idx, array.get(rowVol, idx) + vol)
                array.set(rowBuy, idx, array.get(rowBuy, idx) + vol * share)
                array.set(rowSell, idx, array.get(rowSell, idx) + vol * (1.0 - share))

float totalVol = f_sum_float(rowVol)
int pocIndex = f_argmax_float(rowVol)
float pocLevel = profileLow + (pocIndex + 0.5) * rowSize

int valIndex = pocIndex
int vahIndex = pocIndex
float vaAccum = array.get(rowVol, pocIndex)
if totalVol > 0.0
    int left = pocIndex - 1
    int right = pocIndex + 1
    while vaAccum < totalVol * valueAreaPct and (left >= 0 or right <= profileRows - 1)
        float leftVol = left >= 0 ? array.get(rowVol, left) : -1.0
        float rightVol = right <= profileRows - 1 ? array.get(rowVol, right) : -1.0
        if leftVol >= rightVol and left >= 0
            vaAccum += leftVol
            valIndex := left
            left -= 1
        else if right <= profileRows - 1
            vaAccum += rightVol
            vahIndex := right
            right += 1
        else
            break

float vahLevel = profileLow + (vahIndex + 1) * rowSize
float valLevel = profileLow + valIndex * rowSize

float weightedMid = 0.0
if totalVol > 0.0
    for i = 0 to profileRows - 1
        weightedMid += (profileLow + (i + 0.5) * rowSize) * array.get(rowVol, i)
float vwmp = totalVol > 0.0 ? weightedMid / totalVol : na

// ============================================================================
// Auction imbalance shelves and regime scoring
// ============================================================================
float maxRowVol = 0.0
float bidShelfPrice = na
float askShelfPrice = na
float bidShelfPower = 0.0
float askShelfPower = 0.0
for i = 0 to profileRows - 1
    float rowVolume = array.get(rowVol, i)
    maxRowVol := math.max(maxRowVol, rowVolume)

if totalVol > 0.0 and maxRowVol > 0.0
    for i = 0 to profileRows - 1
        float rowVolume = array.get(rowVol, i)
        float rowBuy = array.get(rowBuy, i)
        float buyFraction = rowVolume > 0.0 ? rowBuy / rowVolume : 0.5
        float rowIntensity = rowVolume / maxRowVol
        float signedShelf = (buyFraction - 0.5) * rowIntensity * 2.0
        float shelfPrice = profileLow + (i + 0.5) * rowSize
        if signedShelf > bidShelfPower
            bidShelfPower := signedShelf
            bidShelfPrice := shelfPrice
        if -signedShelf > askShelfPower
            askShelfPower := -signedShelf
            askShelfPrice := shelfPrice

float profileSkew = totalVol > 0.0 ? (f_sum_float(rowBuy) - f_sum_float(rowSell)) / totalVol : 0.0
float valueWidthAtr = atr > 0.0 ? (vahLevel - valLevel) / atr : 0.0
float vwapCompression = not na(sigma) and atr > 0.0 ? sigma / atr : 0.0
float bidLocationScore = not na(sessionVwap) and close > sessionVwap ? 18.0 : close > pocLevel ? 10.0 : 0.0
float askLocationScore = not na(sessionVwap) and close < sessionVwap ? 18.0 : close < pocLevel ? 10.0 : 0.0
float bidShelfScore = f_clamp(bidShelfPower * 34.0, 0.0, 18.0)
float askShelfScore = f_clamp(askShelfPower * 34.0, 0.0, 18.0)
float compressionScore = valueWidthAtr <= 2.6 ? 8.0 : valueWidthAtr <= 4.0 ? 4.0 : 0.0
float bidAuctionBias = f_clamp(50.0 + profileSkew * 55.0 + vwapDistance * 8.0, 0.0, 100.0)
float askAuctionBias = f_clamp(50.0 - profileSkew * 55.0 - vwapDistance * 8.0, 0.0, 100.0)

// ============================================================================
// CVD impulse and pivot-confirmed divergence
// ============================================================================
float deltaEstimate = volume * (f_buy_share(open, high, low, close) * 2.0 - 1.0)
var float cvd = 0.0
cvd := newSession ? deltaEstimate : nz(cvd[1]) + deltaEstimate
float cvdFast = ta.ema(cvd, 8)
float cvdSlow = ta.ema(cvd, 21)
float cvdImpulse = math.abs(cvdSlow) > 0.0 ? (cvdFast - cvdSlow) / math.max(math.abs(cvdSlow), volume) : 0.0

float priceHighPivot = ta.pivothigh(high, pivotLeft, pivotRight)
float priceLowPivot = ta.pivotlow(low, pivotLeft, pivotRight)
float cvdHighPivot = ta.pivothigh(cvd, pivotLeft, pivotRight)
float cvdLowPivot = ta.pivotlow(cvd, pivotLeft, pivotRight)

var float priorPriceHigh = na
var float priorCvdHigh = na
var float priorPriceLow = na
var float priorCvdLow = na

bool bearDiv = false
bool bullDiv = false
if barstate.isconfirmed
    if not na(priceHighPivot) and not na(cvdHighPivot)
        bearDiv := not na(priorPriceHigh) and priceHighPivot > priorPriceHigh and cvdHighPivot < priorCvdHigh
        priorPriceHigh := priceHighPivot
        priorCvdHigh := cvdHighPivot
    if not na(priceLowPivot) and not na(cvdLowPivot)
        bullDiv := not na(priorPriceLow) and priceLowPivot < priorPriceLow and cvdLowPivot > priorCvdLow
        priorPriceLow := priceLowPivot
        priorCvdLow := cvdLowPivot

float bidDeltaScore = f_clamp((cvdImpulse - impulseThreshold) * 85.0, 0.0, 20.0)
float askDeltaScore = f_clamp((-cvdImpulse - impulseThreshold) * 85.0, 0.0, 20.0)
float bidDivergenceScore = bullDiv ? 14.0 : 0.0
float askDivergenceScore = bearDiv ? 14.0 : 0.0
float bidQuality = f_clamp(32.0 + bidLocationScore + bidShelfScore + bidDeltaScore + bidDivergenceScore + compressionScore + math.max(profileSkew, 0.0) * 18.0, 0.0, 100.0)
float askQuality = f_clamp(32.0 + askLocationScore + askShelfScore + askDeltaScore + askDivergenceScore + compressionScore + math.max(-profileSkew, 0.0) * 18.0, 0.0, 100.0)

// ============================================================================
// Naked POC memory
// ============================================================================
var float[] nakedPocs = array.new_float()
var bool[] nakedTouched = array.new_bool()
int maxNaked = 8

if endedSession and not na(pocLevel[1])
    if array.size(nakedPocs) >= maxNaked
        array.shift(nakedPocs)
        array.shift(nakedTouched)
    array.push(nakedPocs, pocLevel[1])
    array.push(nakedTouched, false)

if array.size(nakedPocs) > 0
    for i = 0 to array.size(nakedPocs) - 1
        float lvl = array.get(nakedPocs, i)
        if not array.get(nakedTouched, i) and low <= lvl and high >= lvl
            array.set(nakedTouched, i, true)

float nearestNaked = na
float nearestDistance = 100000000.0
if array.size(nakedPocs) > 0
    for i = 0 to array.size(nakedPocs) - 1
        float lvl = array.get(nakedPocs, i)
        if not array.get(nakedTouched, i)
            float dist = math.abs(close - lvl)
            if dist < nearestDistance
                nearestDistance := dist
                nearestNaked := lvl

// ============================================================================
// Close-confirmed signal engine
// ============================================================================
float valueTolerance = math.max(atr * 0.20, syminfo.mintick * 5.0)
bool reclaimedPoc = barstate.isconfirmed and close > pocLevel and close[1] <= pocLevel
bool rejectedPoc = barstate.isconfirmed and close < pocLevel and close[1] >= pocLevel
bool longLocation = not na(sessionVwap) and close > sessionVwap and close >= valLevel and close <= vwapUpTwo
bool shortLocation = not na(sessionVwap) and close < sessionVwap and close <= vahLevel and close >= vwapDnTwo
bool longDelta = cvdFast > cvdSlow and cvdImpulse > impulseThreshold
bool shortDelta = cvdFast < cvdSlow and cvdImpulse < -impulseThreshold
bool valReclaim = low <= valLevel + valueTolerance and close > valLevel and close > open
bool vahReject = high >= vahLevel - valueTolerance and close < vahLevel and close < open
string bidReason = bullDiv ? "CVD Divergence" : valReclaim ? "Value Reclaim" : reclaimedPoc ? "POC Reclaim" : "Bid Shelf"
string askReason = bearDiv ? "CVD Divergence" : vahReject ? "Value Reject" : rejectedPoc ? "POC Reject" : "Ask Shelf"

bool rawLongSignal = barstate.isconfirmed and inSession and showSignalZones and longLocation and longDelta and bidQuality >= qualityGate and bidQuality > askQuality and (reclaimedPoc or valReclaim or bullDiv or bidShelfPower > shelfGate)
bool rawShortSignal = barstate.isconfirmed and inSession and showSignalZones and shortLocation and shortDelta and askQuality >= qualityGate and askQuality > bidQuality and (rejectedPoc or vahReject or bearDiv or askShelfPower > shelfGate)
var int lastAuctionSignalBar = na
bool auctionSignalReady = na(lastAuctionSignalBar) or bar_index - lastAuctionSignalBar > signalCooldownBars
bool longSignal = rawLongSignal and auctionSignalReady
bool shortSignal = rawShortSignal and auctionSignalReady
if longSignal or shortSignal
    lastAuctionSignalBar := bar_index
bool exitLongState = barstate.isconfirmed and (bearDiv or close < sessionVwap or close < pocLevel)
bool exitShortState = barstate.isconfirmed and (bullDiv or close > sessionVwap or close > pocLevel)

float longStop = close - atr * stopAtr
float longTargetOne = close + atr * targetAtr * 0.65
float longTargetTwo = close + atr * targetAtr
float shortStop = close + atr * stopAtr
float shortTargetOne = close - atr * targetAtr * 0.65
float shortTargetTwo = close - atr * targetAtr

// ============================================================================
// Visual plots and glow layers
// ============================================================================
plot(showProfileLines ? pocLevel : na, "POC", color=colControl, linewidth=2, style=plot.style_linebr)
plot(showProfileLines ? vahLevel : na, "VAH", color=color.new(colBull, 0), linewidth=1, style=plot.style_linebr)
plot(showProfileLines ? valLevel : na, "VAL", color=color.new(colBear, 0), linewidth=1, style=plot.style_linebr)
plot(showProfileLines ? vwmp : na, "VWMP", color=colViolet, linewidth=1, style=plot.style_linebr)
plot(showProfileLines and showNakedPocLine ? nearestNaked : na, "Nearest Naked POC", color=color.new(colBearStrong, 0), linewidth=2, style=plot.style_linebr)

plot(showVwap ? sessionVwap : na, "Session VWAP", color=vwapGradient, linewidth=2)
plot(showVwap ? sessionVwap : na, "VWAP Glow", color=color.new(vwapGradient, 78), linewidth=7)
plotUpOne = plot(showVwap ? vwapUpOne : na, "VWAP +1", color=color.new(vwapGradient, 28), linewidth=1)
plotDnOne = plot(showVwap ? vwapDnOne : na, "VWAP -1", color=color.new(vwapGradient, 28), linewidth=1)
plotUpTwo = plot(showVwap ? vwapUpTwo : na, "VWAP +2", color=color.new(vwapGradient, 68), linewidth=1)
plotDnTwo = plot(showVwap ? vwapDnTwo : na, "VWAP -2", color=color.new(vwapGradient, 68), linewidth=1)
fill(plotUpOne, plotDnOne, color=color.new(colViolet, 91))
fill(plotUpTwo, plotDnTwo, color=color.new(colViolet, 95))
valueAreaTopPlot = plot(showProfileLines ? vahLevel : na, "Value Area Top Fill", display=display.none)
valueAreaBotPlot = plot(showProfileLines ? valLevel : na, "Value Area Bottom Fill", display=display.none)
fill(valueAreaTopPlot, valueAreaBotPlot, color=color.new(colControl, 91))

color candleState = na
color bidCandle = f_quality_color(bidQuality, true)
color askCandle = f_quality_color(askQuality, false)
candleState := colorCandles and longSignal ? color.new(bidCandle, 0) : colorCandles and shortSignal ? color.new(askCandle, 0) : colorCandles and bidAuctionBias >= 58.0 ? color.new(bidCandle, 32) : colorCandles and askAuctionBias >= 58.0 ? color.new(askCandle, 32) : na
barcolor(barstate.isconfirmed ? candleState : na)

// ============================================================================
// Object-managed profile heatmap and signal projections
// ============================================================================
var box[] heatBoxes = array.new_box()
var box[] shelfBoxes = array.new_box()
var box[] signalBoxes = array.new_box()
var line[] signalLines = array.new_line()
var label[] signalLabels = array.new_label()
var box auctionFrame = na

if showAuctionFrame and newSession
    if not na(auctionFrame)
        box.delete(auctionFrame)
    auctionFrame := box.new(bar_index, sessionHigh, bar_index, sessionLow, xloc=xloc.bar_index, bgcolor=color.new(colFrame, 94), border_color=color.new(vwapGradient, 48))

if showAuctionFrame and inSession and not na(auctionFrame)
    box.set_right(auctionFrame, bar_index)
    box.set_top(auctionFrame, sessionHigh)
    box.set_bottom(auctionFrame, sessionLow)
    box.set_bgcolor(auctionFrame, color.new(vwapGradient, bidQuality > qualityGate or askQuality > qualityGate ? 92 : 95))
    box.set_border_color(auctionFrame, color.new(vwapGradient, 44))

if not showAuctionFrame and not na(auctionFrame)
    box.delete(auctionFrame)
    auctionFrame := na

if barstate.islast
    f_clear_boxes(heatBoxes)
    f_clear_boxes(shelfBoxes)
    if showHeatmap and inSession and totalVol > 0.0
        int leftAnchor = bar_index + profileRightOffset
        int rightAnchor = bar_index + profileRightOffset + 10
        for i = 0 to profileRows - 1
            float binVol = array.get(rowVol, i)
            float binBuy = array.get(rowBuy, i)
            float buyFraction = binVol > 0.0 ? binBuy / binVol : 0.5
            float intensity = maxRowVol > 0.0 ? binVol / maxRowVol : 0.0
            int alpha = int(f_clamp(94.0 - intensity * 76.0, 14.0, 94.0))
            color base = color.from_gradient(buyFraction, 0.0, 1.0, colBearStrong, colBullStrong)
            color border = i == pocIndex ? color.new(colControl, 0) : i >= valIndex and i <= vahIndex ? color.new(colControl, 42) : color.new(colNeutral, 88)
            float top = profileLow + (i + 1) * rowSize
            float bot = profileLow + i * rowSize
            array.push(heatBoxes, box.new(leftAnchor, top, rightAnchor, bot, xloc=xloc.bar_index, bgcolor=color.new(base, alpha), border_color=border))
    if showImbalanceShelves and inSession and totalVol > 0.0 and maxRowVol > 0.0
        int shelfLeft = bar_index + profileRightOffset + 13
        int shelfRight = bar_index + profileRightOffset + 23
        for i = 0 to profileRows - 1
            float binVol = array.get(rowVol, i)
            float binBuy = array.get(rowBuy, i)
            float buyFraction = binVol > 0.0 ? binBuy / binVol : 0.5
            float imbalance = math.abs(buyFraction - 0.5) * 2.0
            float intensity = binVol / maxRowVol
            if imbalance >= shelfGate and intensity >= 0.16
                bool bidShelf = buyFraction >= 0.5
                color shelfColor = bidShelf ? colReward : colRisk
                int shelfAlpha = int(f_clamp(94.0 - imbalance * intensity * 72.0, 22.0, 92.0))
                float shelfTop = profileLow + (i + 1) * rowSize
                float shelfBot = profileLow + i * rowSize
                array.push(shelfBoxes, box.new(shelfLeft, shelfTop, shelfRight, shelfBot, xloc=xloc.bar_index, bgcolor=color.new(shelfColor, shelfAlpha), border_color=color.new(shelfColor, 30)))

if longSignal
    float rewardTop = math.max(close, longTargetTwo)
    float rewardBot = math.min(close, longTargetTwo)
    float riskTop = math.max(close, longStop)
    float riskBot = math.min(close, longStop)
    array.push(signalBoxes, box.new(bar_index, rewardTop, bar_index + signalExtend, rewardBot, xloc=xloc.bar_index, bgcolor=color.new(colReward, 88), border_color=color.new(colReward, 18)))
    array.push(signalBoxes, box.new(bar_index, riskTop, bar_index + signalExtend, riskBot, xloc=xloc.bar_index, bgcolor=color.new(colRisk, 88), border_color=color.new(colRisk, 18)))
    array.push(signalLines, line.new(bar_index, close, bar_index + signalExtend, close, xloc=xloc.bar_index, color=color.white, width=2))
    array.push(signalLines, line.new(bar_index, longStop, bar_index + signalExtend, longStop, xloc=xloc.bar_index, color=color.new(colBearStrong, 0), width=2))
    array.push(signalLines, line.new(bar_index, longTargetOne, bar_index + signalExtend, longTargetOne, xloc=xloc.bar_index, color=color.new(colBullStrong, 5), width=1))
    array.push(signalLines, line.new(bar_index, longTargetTwo, bar_index + signalExtend, longTargetTwo, xloc=xloc.bar_index, color=colBullStrong, width=2))
    array.push(signalLabels, label.new(bar_index + signalExtend, close, f_plan_text(true, bidQuality, bidReason, close, longStop, longTargetOne, longTargetTwo), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.rgb(8, 12, 18), color=color.new(f_quality_color(bidQuality, true), 6), size=size.small))

if shortSignal
    float rewardTop = math.max(close, shortTargetTwo)
    float rewardBot = math.min(close, shortTargetTwo)
    float riskTop = math.max(close, shortStop)
    float riskBot = math.min(close, shortStop)
    array.push(signalBoxes, box.new(bar_index, rewardTop, bar_index + signalExtend, rewardBot, xloc=xloc.bar_index, bgcolor=color.new(colReward, 88), border_color=color.new(colReward, 18)))
    array.push(signalBoxes, box.new(bar_index, riskTop, bar_index + signalExtend, riskBot, xloc=xloc.bar_index, bgcolor=color.new(colRisk, 88), border_color=color.new(colRisk, 18)))
    array.push(signalLines, line.new(bar_index, close, bar_index + signalExtend, close, xloc=xloc.bar_index, color=color.white, width=2))
    array.push(signalLines, line.new(bar_index, shortStop, bar_index + signalExtend, shortStop, xloc=xloc.bar_index, color=color.new(colBearStrong, 0), width=2))
    array.push(signalLines, line.new(bar_index, shortTargetOne, bar_index + signalExtend, shortTargetOne, xloc=xloc.bar_index, color=color.new(colBullStrong, 5), width=1))
    array.push(signalLines, line.new(bar_index, shortTargetTwo, bar_index + signalExtend, shortTargetTwo, xloc=xloc.bar_index, color=colBullStrong, width=2))
    array.push(signalLabels, label.new(bar_index + signalExtend, close, f_plan_text(false, askQuality, askReason, close, shortStop, shortTargetOne, shortTargetTwo), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(f_quality_color(askQuality, false), 6), size=size.small))

f_trim_boxes(signalBoxes, maxSignalPlans * 2)
f_trim_lines(signalLines, maxSignalPlans * 4)
f_trim_labels(signalLabels, maxSignalPlans)

// ============================================================================
// Dashboard and alerts
// ============================================================================
if showDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, border_width=1, frame_color=color.new(colNeutral, 65), frame_width=1)
    string pulseState = longSignal ? "Bid Absorb" : shortSignal ? "Ask Absorb" : bidAuctionBias > askAuctionBias ? "Bid Lean" : askAuctionBias > bidAuctionBias ? "Ask Lean" : "Balanced"
    color pulseColor = longSignal ? colBullStrong : shortSignal ? colBearStrong : bidAuctionBias > askAuctionBias ? colBull : askAuctionBias > bidAuctionBias ? colBear : colNeutral
    table.cell(dash, 0, 0, "Vanta Delta", text_color=color.white, bgcolor=color.new(colControl, 35))
    table.cell(dash, 1, 0, pulseState, text_color=pulseColor, bgcolor=colHudSoft)
    table.cell(dash, 0, 1, "Quality", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 1, str.tostring(bidQuality, "#") + " / " + str.tostring(askQuality, "#"), text_color=bidQuality > askQuality ? colBullStrong : colBearStrong, bgcolor=colHudSoft)
    table.cell(dash, 0, 2, "Auction Bias", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 2, str.tostring(bidAuctionBias, "#") + " / " + str.tostring(askAuctionBias, "#"), text_color=bidAuctionBias > askAuctionBias ? colBullStrong : colBearStrong, bgcolor=colHudSoft)
    table.cell(dash, 0, 3, "POC", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 3, str.tostring(pocLevel, format.mintick), text_color=colControl, bgcolor=colHudSoft)
    table.cell(dash, 0, 4, "Value Area", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 4, str.tostring(valLevel, format.mintick) + " / " + str.tostring(vahLevel, format.mintick), text_color=colControl, bgcolor=colHudSoft)
    table.cell(dash, 0, 5, "VWAP", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 5, str.tostring(sessionVwap, format.mintick), text_color=vwapGradient, bgcolor=colHudSoft)
    table.cell(dash, 0, 6, "CVD Impulse", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 6, str.tostring(cvdImpulse, "#.000"), text_color=cvdImpulse > 0.0 ? colBullStrong : colBearStrong, bgcolor=colHudSoft)
    table.cell(dash, 0, 7, "Shelf", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 7, str.tostring(bidShelfPower, "#.00") + " / " + str.tostring(askShelfPower, "#.00"), text_color=bidShelfPower > askShelfPower ? colBullStrong : colBearStrong, bgcolor=colHudSoft)
    table.cell(dash, 0, 8, "Divergence", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 8, bullDiv ? "Bull" : bearDiv ? "Bear" : "None", text_color=bullDiv ? colBullStrong : bearDiv ? colBearStrong : colNeutral, bgcolor=colHudSoft)
    table.cell(dash, 0, 9, "Session", text_color=color.white, bgcolor=colHudSoft)
    table.cell(dash, 1, 9, inSession ? "Active" : "Closed", text_color=inSession ? colBullStrong : colNeutral, bgcolor=colHudSoft)

alertcondition(longSignal, "VDC Bid Absorption [JOAT]", "Vanta Delta Cartography [JOAT]: close-confirmed bid-side absorption plan.")
alertcondition(shortSignal, "VDC Ask Absorption [JOAT]", "Vanta Delta Cartography [JOAT]: close-confirmed ask-side absorption plan.")
alertcondition(exitLongState, "VDC Bid Risk-Off [JOAT]", "Vanta Delta Cartography [JOAT]: bid-side risk-off state.")
alertcondition(exitShortState, "VDC Ask Risk-Off [JOAT]", "Vanta Delta Cartography [JOAT]: ask-side risk-off state.")
alertcondition(bullDiv, "VDC Bullish CVD Divergence [JOAT]", "Vanta Delta Cartography [JOAT]: pivot-confirmed bullish CVD divergence.")
alertcondition(bearDiv, "VDC Bearish CVD Divergence [JOAT]", "Vanta Delta Cartography [JOAT]: pivot-confirmed bearish CVD divergence.")
````

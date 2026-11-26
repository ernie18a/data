# Momentum Saturation Zones [JOAT]

- url: https://www.tradingview.com/script/qvVc6HKv-Momentum-Saturation-Zones-JOAT/
- type: indicator
- pine_id: PUB;3218024a36ce4b56b7a9874ef3621dc7
- version: 1.0

## Description

[b]Momentum Saturation Zones [JOAT][/b]

[b]Introduction[/b]

Momentum Saturation Zones is an open-source indicator that detects when momentum has reached an extreme and then begins pulling back, marks the price level where that extreme occurred as a zone, and tracks the zone's structural validity until price either respects or invalidates it. The premise is that momentum peaks and troughs at significant price levels leave structural imprints — areas where the market demonstrated conviction — that subsequently act as reference points for support or resistance.

The key differentiator from a simple overbought/oversold indicator is the composite strength scoring: a zone is only created when a configurable minimum score is reached, incorporating the momentum extreme level, the magnitude of the pullback, volume at the peak bar, and whether a divergence is present.

[b]Core Concepts[/b]

[b]1. Multi-Source Momentum[/b]

The momentum signal is selectable from five sources: RSI, Rate of Change (normalized), MFI, Stochastic RSI, or a composite average of all four. The composite mode averages RSI, normalized ROC, MFI, and StochRSI into a single signal, reducing single-indicator noise while retaining each component's contribution:

[pine]
float momSeries = (rsiRaw + rocNorm + mfiRaw + stochD) / 4.0
[/pine]

[b]2. Adaptive Pullback Detection[/b]

The saturation trigger fires when momentum has pulled back from a rolling peak by more than a configurable percentage threshold. The threshold is adaptive — scaled by the current ATR relative to its 50-bar average. In high-volatility regimes the required pullback is larger; in low-volatility regimes it is smaller. This prevents premature triggers in noisy markets and late triggers in calm ones.

[image]https://www.tradingview.com/x/bUVAjnPy/[/image]

[b]3. Composite Strength Scoring (0-100)[/b]

Each potential zone is scored before creation. The score combines four components: how extreme the momentum peak was (0-40 points), how far beyond the threshold the pullback reached (0-20 points), the volume ratio at the peak bar relative to average (0-20 points), and whether momentum divergence is present (0-20 points). Only zones meeting the minimum score gate are created:

[pine]
float extrem   = math.max(0.0, math.min(40.0, (peakAbsMom - 50.0) * 40.0 / 50.0))
float pbScore  = math.max(0.0, math.min(20.0, (actualPb - adaptPct) * 2.0 + 10.0))
float volScore = math.max(0.0, math.min(20.0, (volRatio - 1.0) * 20.0))
float divScore = bearDiv and i_useDiv ? 20.0 : 0.0
[/pine]

[b]4. Zone Anchor Logic[/b]

Bear resistance zones are anchored at the candle high of the peak bar with the zone extending upward by one ATR multiple — the bottom edge sits exactly at the candle high so price must reach up to touch the zone. Bull support zones are anchored at the candle low of the trough bar with the zone extending downward — the top edge sits at the candle low so price must come back down to touch it.

[b]5. Zone Lifecycle and Touch Counting[/b]

Each zone tracks how many times price has returned to it (touch counter displayed in the label). When price closes beyond the invalidation offset, the zone is deleted entirely — no ghost boxes remain. A proximity check before creation prevents duplicate zones from stacking at the same price level.

[b]Features[/b]

[list]
[*][b]Five momentum sources:[/b] RSI, ROC, MFI, StochRSI, or Composite average
[*][b]Adaptive pullback threshold:[/b] ATR-normalized trigger scaled to current volatility regime
[*][b]Composite strength scoring (0-100):[/b] Extremity, pullback depth, volume, and divergence components
[*][b]ATR-anchored zones:[/b] Three-layer gradient zones (outer, mid, core) with center line
[*][b]Proper candle anchoring:[/b] Resistance bottoms at candle high; support tops at candle low
[*][b]Touch counting:[/b] Zone labels update each time price retests the zone
[*][b]Proximity deduplication:[/b] No duplicate zones within 1.5 ATR of same-side existing zones
[*][b]Clean invalidation:[/b] Zones deleted entirely on invalidation — no ghost boxes
[*][b]Divergence detection:[/b] Momentum divergence contributes bonus points to strength score
[*][b]Candle coloring:[/b] Candles tinted when price is inside or within 0.5 ATR of a valid zone
[*][b]Dashboard:[/b] Momentum value, pullback threshold, volatility regime, active zone count, and directional strength scores
[/list]

[b]Input Parameters[/b]

[b]Momentum Configuration:[/b]
[list]
[*]Momentum Source: RSI, ROC, MFI, StochRSI, or Composite (default: Composite)
[*]Momentum Length: Period for all momentum calculations (default: 14)
[*]Peak Lookback Bars: Rolling window for peak/trough detection (default: 50)
[/list]

[b]Saturation Trigger:[/b]
[list]
[*]Adaptive ATR Threshold toggle (default: on)
[*]Pullback % from Peak: Required pullback to trigger (default: 10%)
[*]RSI Overbought/Oversold: Absolute extreme levels for gate (default: 70/30)
[*]Cooldown Bars: Minimum bars between zone creation events (default: 10)
[/list]

[b]Zone Settings:[/b]
[list]
[*]Max Active Zones: Simultaneous zone cap (default: 4)
[*]ATR Length: ATR period for zone sizing (default: 14)
[*]Zone Width (x ATR): Zone height as ATR multiple (default: 1.0)
[*]Invalidation Offset %: Margin beyond zone for invalidation trigger (default: 0.3%)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Zone Strength[/b]
Zones display their strength score (0-100) in the label. Higher-scoring zones represent confluences of multiple factors and are historically more likely to produce price reactions.

[b]Step 2: Use Touch Count for Context[/b]
A zone touched twice and holding is more significant than a freshly-created zone. A zone touched three or more times that eventually breaks is exhausted — expect the break to accelerate.

[b]Step 3: Watch for Candle Color Changes Near Zones[/b]
The candle coloring activates when price enters the zone or comes within 0.5 ATR of it. This provides a passive alert that price is approaching a structural reference.

[b]Indicator Limitations[/b]

[list]
[*]Momentum peaks do not always coincide with price extremes — the zone is placed at the price of the peak momentum bar, which may differ from the highest/lowest price in the lookback
[*]In strongly trending markets, zones on the trend side may be repeatedly invalidated as trend continues
[*]The strength score is a composite heuristic, not a backtested predictor of zone success rate
[/list]

[b]Originality Statement[/b]

The composite strength scoring system — combining momentum extremity, pullback depth, volume, and divergence into a single 0-100 gate — applied to zone creation is the original analytical contribution. The proper candle-edge anchoring (resistance bottom at candle high, support top at candle low), proximity deduplication, and clean deletion on invalidation are implementation details not present in most published support/resistance zone indicators.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Momentum saturation zones are historical reference levels and do not predict future price reactions. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Momentum Saturation Zones [JOAT]", shorttitle="MSZ [JOAT]", overlay=true,
     max_boxes_count=300, max_lines_count=300, max_labels_count=200, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color BULL_BASE  = color.rgb(0,   191, 165)
color BEAR_BASE  = color.rgb(255,  82,  82)
color WARM_BULL  = color.rgb(255, 185,  20)
color HOT_BEAR   = color.rgb(255,  75,  95)
color VOID_BG    = color.rgb(10,   14,  26)
color SLATE_BRD  = color.rgb(40,   55,  90)
color LAVEN_HDR  = color.rgb(140, 160, 210)
color GOLD_VAL   = color.rgb(255, 215,  60)
color GREY_GHOST = color.rgb(100, 110, 130)
color NEON_CYAN  = color.rgb(0,   243, 255)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_MOM  = "━━ Momentum Configuration ━━"
string G_TRIG = "━━ Saturation Trigger ━━"
string G_FILT = "━━ Quality Filters ━━"
string G_ZONE = "━━ Zone Settings ━━"
string G_VIZ  = "━━ Visual & Dashboard ━━"

string i_momSrc   = input.string("Composite", "Momentum Source",
     options=["RSI","ROC","MFI","StochRSI","Composite"], group=G_MOM,
     tooltip="RSI=classic, ROC=pure price, MFI=money flow, StochRSI=fast oscillator, Composite=all five averaged.")
int    i_momLen   = input.int(14,  "Momentum Length",     minval=2, maxval=100, group=G_MOM)
int    i_pkLook   = input.int(50,  "Peak Lookback Bars",  minval=5, maxval=300, group=G_MOM)
bool   i_useAdapt = input.bool(true, "Adaptive ATR Threshold",    group=G_TRIG)
float  i_pctDrop  = input.float(10.0,"Pullback % from Peak",      minval=1.0, maxval=50.0, step=0.5, group=G_TRIG)
bool   i_absGate  = input.bool(true, "Require Absolute Extreme",  group=G_TRIG)
float  i_rsiOB    = input.float(70.0,"RSI Overbought Level",      minval=50.0, maxval=99.0, group=G_TRIG)
float  i_rsiOS    = input.float(30.0,"RSI Oversold Level",        minval=1.0,  maxval=50.0, group=G_TRIG)
int    i_pvtConf  = input.int(2,   "Pivot Confirmation Bars",     minval=0, maxval=10, group=G_TRIG)
int    i_cooldown = input.int(10,  "Zone Cooldown (bars)",        minval=0, group=G_TRIG)
bool   i_useVolF  = input.bool(true, "Volume Filter at Peak",     group=G_FILT)
float  i_volMult  = input.float(1.2,"Volume Multiplier",          minval=0.5, step=0.1, group=G_FILT)
bool   i_useDiv   = input.bool(true, "Divergence Bonus Score",    group=G_FILT)
int    i_minStr   = input.int(40,  "Min Strength Score (0-100)",  minval=0, maxval=100, group=G_FILT)
int    i_maxZones = input.int(4,   "Max Active Zones",            minval=1, maxval=10, group=G_ZONE)
int    i_atrLen   = input.int(14,  "ATR Length",                  minval=1, group=G_ZONE)
float  i_zoneW    = input.float(1.0,"Zone Width (x ATR)",         minval=0.2, maxval=3.0, step=0.1, group=G_ZONE)
float  i_invOff   = input.float(0.3,"Invalidation Offset %",      minval=0.0, step=0.1, group=G_ZONE) / 100
int    i_extBars  = input.int(20,  "Zone Extension (bars)",       minval=5, group=G_ZONE)
bool   i_showGrad = input.bool(true, "Gradient Zone Fill",        group=G_VIZ)
bool   i_showDash = input.bool(true, "Show Dashboard",            group=G_VIZ)
bool   i_showTouch= input.bool(true, "Touch Markers",             group=G_VIZ)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — MOMENTUM SOURCES
// ═══════════════════════════════════════════════════════════════════════════════
float rsiRaw  = ta.rsi(close, i_momLen)
float rocRaw  = ta.roc(close, i_momLen)
float mfiRaw  = ta.mfi(hlc3, i_momLen)

float rocStd  = ta.stdev(rocRaw, 100)
float rocNorm = 50.0 + 50.0 * (rocRaw / (rocStd * 2.0 + 0.0001))
rocNorm := math.max(0.0, math.min(100.0, rocNorm))

float stochK  = ta.stoch(close, high, low, i_momLen)
float stochD  = ta.sma(stochK, 3)
float srsiRaw = 50.0 + stochD - 50.0

float momSeries = switch i_momSrc
    "RSI"      => rsiRaw
    "ROC"      => rocRaw
    "MFI"      => mfiRaw
    "StochRSI" => stochD
    =>             (rsiRaw + rocNorm + mfiRaw + stochD) / 4.0

float momRsiSpace = switch i_momSrc
    "ROC"      => rocNorm
    "RSI"      => rsiRaw
    "MFI"      => mfiRaw
    "StochRSI" => stochD
    =>             (rsiRaw + rocNorm + mfiRaw + stochD) / 4.0

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — ROLLING PEAKS & ADAPTIVE THRESHOLD
// ═══════════════════════════════════════════════════════════════════════════════
float rollHi   = ta.highest(momSeries, i_pkLook)
float rollLo   = ta.lowest (momSeries, i_pkLook)
int   hiOffset = ta.highestbars(momSeries, i_pkLook)
int   loOffset = ta.lowestbars (momSeries, i_pkLook)

float hiBarPrice = high[math.abs(hiOffset)]
float loBarPrice = low [math.abs(loOffset)]
float hiBarVol   = volume[math.abs(hiOffset)]
float loBarVol   = volume[math.abs(loOffset)]

float atrVal   = ta.atr(i_atrLen)
float atrPct   = (atrVal / nz(close, 1.0)) * 100.0
float atrPctMA = ta.sma(atrPct, 50)
float volReg   = atrPct / (atrPctMA + 0.0001)
float adaptPct = i_useAdapt ? i_pctDrop * math.max(0.6, math.min(1.8, volReg)) : i_pctDrop

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — SATURATION TRIGGERS
// ═══════════════════════════════════════════════════════════════════════════════
bool bearPullback = momSeries <= rollHi * (1.0 - adaptPct / 100.0)
bool bullPullback = momSeries >= rollLo + math.abs(rollLo) * (adaptPct / 100.0)

float peakMomAbs   = momRsiSpace[math.abs(hiOffset)]
float troughMomAbs = momRsiSpace[math.abs(loOffset)]
bool  absGateBear  = not i_absGate or peakMomAbs   >= i_rsiOB
bool  absGateBull  = not i_absGate or troughMomAbs <= i_rsiOS

bool peakAgeOK   = i_pvtConf == 0 or math.abs(hiOffset) >= i_pvtConf
bool troughAgeOK = i_pvtConf == 0 or math.abs(loOffset) >= i_pvtConf

float volAvg      = ta.sma(volume, 20)
bool  volAtPeak   = hiBarVol > volAvg * i_volMult
bool  volAtTrough = loBarVol > volAvg * i_volMult
bool  volGateBear = not i_useVolF or volAtPeak
bool  volGateBull = not i_useVolF or volAtTrough

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
var float prevPriceHi = na
var float prevMomHi   = na
var float prevPriceLo = na
var float prevMomLo   = na

float curPriceHi = hiBarPrice
float curMomHi   = rollHi
float curPriceLo = loBarPrice
float curMomLo   = rollLo

bool bearDiv = not na(prevPriceHi) and not na(prevMomHi) and
               curPriceHi > prevPriceHi and curMomHi < prevMomHi
bool bullDiv = not na(prevPriceLo) and not na(prevMomLo) and
               curPriceLo < prevPriceLo and curMomLo > prevMomLo

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — COMPOSITE STRENGTH SCORE (0-100)
// ═══════════════════════════════════════════════════════════════════════════════
calcStrBear(float peakAbsMom, float curMom, float pkVol) =>
    float extrem   = math.max(0.0, math.min(40.0, (peakAbsMom - 50.0) * 40.0 / 50.0))
    float actualPb = (rollHi - curMom) / (rollHi + 0.0001) * 100.0
    float pbScore  = math.max(0.0, math.min(20.0, (actualPb - adaptPct) * 2.0 + 10.0))
    float volRatio = pkVol / (volAvg + 0.0001)
    float volScore = math.max(0.0, math.min(20.0, (volRatio - 1.0) * 20.0))
    float divScore = bearDiv and i_useDiv ? 20.0 : 0.0
    math.round(extrem + pbScore + volScore + divScore)

calcStrBull(float trAbsMom, float curMom, float trVol) =>
    float extrem   = math.max(0.0, math.min(40.0, (50.0 - trAbsMom) * 40.0 / 50.0))
    float actualPb = (curMom - rollLo) / (math.abs(rollLo) + 0.0001) * 100.0
    float pbScore  = math.max(0.0, math.min(20.0, (actualPb - adaptPct) * 2.0 + 10.0))
    float volRatio = trVol / (volAvg + 0.0001)
    float volScore = math.max(0.0, math.min(20.0, (volRatio - 1.0) * 20.0))
    float divScore = bullDiv and i_useDiv ? 20.0 : 0.0
    math.round(extrem + pbScore + volScore + divScore)

int bearStr = calcStrBear(peakMomAbs,   momSeries, hiBarVol)
int bullStr = calcStrBull(troughMomAbs, momSeries, loBarVol)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — COOLDOWN & LATCH
// ═══════════════════════════════════════════════════════════════════════════════
var int lastBearBar = -999
var int lastBullBar = -999
var int lastZoneBar = -999

int curHiBar = bar_index + hiOffset
int curLoBar = bar_index + loOffset

bool newBearPeak   = curHiBar != lastBearBar
bool newBullTrough = curLoBar != lastBullBar
bool coolOK        = (bar_index - lastZoneBar) >= i_cooldown

bool bearSat = barstate.isconfirmed and bearPullback and newBearPeak and
               coolOK and absGateBear and volGateBear and peakAgeOK and
               bearStr >= i_minStr

bool bullSat = barstate.isconfirmed and bullPullback and newBullTrough and
               coolOK and absGateBull and volGateBull and troughAgeOK and
               bullStr >= i_minStr

if bearSat
    lastBearBar := curHiBar
    lastZoneBar := bar_index
    prevPriceHi := curPriceHi
    prevMomHi   := curMomHi

if bullSat
    lastBullBar := curLoBar
    lastZoneBar := bar_index
    prevPriceLo := curPriceLo
    prevMomLo   := curMomLo

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — ZONE MANAGEMENT
// ═══════════════════════════════════════════════════════════════════════════════
strengthStars(int s) =>
    s >= 80 ? "AAAAA" : s >= 65 ? "AAAA " : s >= 50 ? "AAA  " : s >= 35 ? "AA   " : "A    "

var box[]   zOuter   = array.new_box()
var box[]   zMid     = array.new_box()
var box[]   zCore    = array.new_box()
var line[]  zCenter  = array.new_line()
var label[] zLabels  = array.new_label()
var float[] zTop     = array.new_float()
var float[] zBot     = array.new_float()
var float[] zAnchor  = array.new_float()
var bool[]  zIsBull  = array.new_bool()
var int[]   zStr     = array.new_int()
var int[]   zTouches = array.new_int()
var bool[]  zValid   = array.new_bool()

countValid() =>
    int cnt = 0
    int n   = zValid.size()
    if n > 0
        for k = 0 to n - 1
            if array.get(zValid, k)
                cnt += 1
    cnt

zoneDel(int i) =>
    box.delete   (array.get(zOuter,   i))
    box.delete   (array.get(zMid,     i))
    box.delete   (array.get(zCore,    i))
    line.delete  (array.get(zCenter,  i))
    label.delete (array.get(zLabels,  i))
    array.remove(zOuter,   i)
    array.remove(zMid,     i)
    array.remove(zCore,    i)
    array.remove(zCenter,  i)
    array.remove(zLabels,  i)
    array.remove(zTop,     i)
    array.remove(zBot,     i)
    array.remove(zAnchor,  i)
    array.remove(zIsBull,  i)
    array.remove(zStr,     i)
    array.remove(zTouches, i)
    array.remove(zValid,   i)

evictOldest() =>
    int n = zValid.size()
    if n > 0
        for k = 0 to n - 1
            if array.get(zValid, k)
                zoneDel(k)
                break

createZone(float anchor, bool isBull, int strength) =>
    // Bull support: zone starts AT the low and extends downward
    // Bear resist:  zone starts AT the high and extends upward
    float zoneH  = atrVal * i_zoneW
    float topP   = isBull ? anchor          : anchor + zoneH
    float botP   = isBull ? anchor - zoneH  : anchor
    color baseC  = isBull ? BULL_BASE : BEAR_BASE
    int   opOuter = i_showGrad ? math.max(70, 95 - strength / 4) : 80
    int   opMid   = i_showGrad ? math.max(55, 85 - strength / 3) : 70
    int   opCore  = i_showGrad ? math.max(40, 75 - strength / 2) : 60
    int   rx      = bar_index + i_extBars

    box bOut = box.new(bar_index, topP, rx, botP,
         bgcolor=color.new(baseC, opOuter), border_color=color.new(baseC, 100), border_width=0)
    // Mid/core gradient layers centered on anchor price
    box bMid = box.new(bar_index, anchor + zoneH * 0.25, rx, anchor - zoneH * 0.25,
         bgcolor=color.new(baseC, opMid),  border_color=color.new(baseC, 100), border_width=0)
    box bCore = box.new(bar_index, anchor + zoneH * 0.10, rx, anchor - zoneH * 0.10,
         bgcolor=color.new(baseC, opCore), border_color=color.new(baseC, 30),  border_width=1)
    line ctrLn = line.new(bar_index, anchor, rx, anchor,
         color=color.new(baseC, 20), style=line.style_solid, width=2)

    string lbl_text = (isBull ? "▲ SUPPORT" : "▼ RESIST") + "  " +
                      strengthStars(strength) + "  " + str.tostring(strength) + "/100\n" +
                      str.tostring(anchor, format.mintick)
    label lbl = label.new(rx, anchor, lbl_text, color=color.new(baseC, 75),
         textcolor=color.rgb(220, 230, 255), style=label.style_label_left, size=size.small)

    array.push(zOuter,   bOut)
    array.push(zMid,     bMid)
    array.push(zCore,    bCore)
    array.push(zCenter,  ctrLn)
    array.push(zLabels,  lbl)
    array.push(zTop,     topP)
    array.push(zBot,     botP)
    array.push(zAnchor,  anchor)
    array.push(zIsBull,  isBull)
    array.push(zStr,     strength)
    array.push(zTouches, 0)
    array.push(zValid,   true)

// Skip new zone if an identical-side zone already exists within 1.5 ATR (prevents stacked duplicates)
noNearbyZone(float anchor, bool isBull) =>
    bool ok = true
    int nCheck = zAnchor.size()
    if nCheck > 0
        for k = 0 to nCheck - 1
            if array.get(zValid, k) and array.get(zIsBull, k) == isBull
                if math.abs(array.get(zAnchor, k) - anchor) < atrVal * 1.5
                    ok := false
                    break
    ok

if bearSat and noNearbyZone(hiBarPrice, false)
    if countValid() >= i_maxZones
        evictOldest()
    createZone(hiBarPrice, false, bearStr)

if bullSat and noNearbyZone(loBarPrice, true)
    if countValid() >= i_maxZones
        evictOldest()
    createZone(loBarPrice, true, bullStr)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — ZONE MAINTENANCE (extend + touch + delete on invalidation)
// ═══════════════════════════════════════════════════════════════════════════════
var int lastTouchBar = -999
bool touchFiredBull = false
bool touchFiredBear = false

if barstate.isconfirmed and zOuter.size() > 0
    int i = 0
    while i < zOuter.size()
        float topZ   = array.get(zTop,    i)
        float botZ   = array.get(zBot,    i)
        float ancZ   = array.get(zAnchor, i)
        bool  bullZ  = array.get(zIsBull, i)
        bool  validZ = array.get(zValid,  i)
        int   strZ   = array.get(zStr,    i)
        bool  deleted = false

        if validZ
            int rx2 = bar_index + i_extBars
            box.set_right  (array.get(zOuter,   i), rx2)
            box.set_right  (array.get(zMid,     i), rx2)
            box.set_right  (array.get(zCore,    i), rx2)
            line.set_x2    (array.get(zCenter,  i), rx2)
            label.set_x    (array.get(zLabels,  i), rx2)

            bool touched = low <= topZ and high >= botZ
            if touched and (bar_index - lastTouchBar) > 2
                int newT = array.get(zTouches, i) + 1
                array.set(zTouches, i, newT)
                lastTouchBar := bar_index
                if bullZ
                    touchFiredBull := true
                else
                    touchFiredBear := true
                string newTxt = (bullZ ? "▲ SUPPORT" : "▼ RESIST") + "  " +
                     strengthStars(strZ) + "  " + str.tostring(strZ) + "/100  [" + str.tostring(newT) + "x]\n" +
                     str.tostring(ancZ, format.mintick)
                label.set_text(array.get(zLabels, i), newTxt)

            // Invalidation: delete the zone entirely so no ghost boxes remain
            float invP2 = bullZ ? botZ * (1.0 - i_invOff) : topZ * (1.0 + i_invOff)
            if (bullZ and close < invP2) or (not bullZ and close > invP2)
                zoneDel(i)
                deleted := true

        if not deleted
            i += 1

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — SIGNALS & TOUCH MARKERS
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(bearSat, title="Bear Saturation", style=shape.triangledown,
     location=location.abovebar, color=BEAR_BASE, size=size.small, text="PEAK", textcolor=BEAR_BASE)
plotshape(bullSat, title="Bull Saturation", style=shape.triangleup,
     location=location.belowbar, color=BULL_BASE, size=size.small, text="TROUGH", textcolor=BULL_BASE)


// ── MSZ Candle Coloring based on active zone proximity ──────────────────────
// Find nearest valid zone and color candles based on proximity + direction
color mszCandleColor = na
if zValid.size() > 0
    float nearestDist = 1.0e15
    bool  nearestBull = true
    for ki = 0 to zValid.size() - 1
        if array.get(zValid, ki)
            float anch = array.get(zAnchor, ki)
            float dist = math.abs(close - anch)
            float topZ = array.get(zTop, ki)
            float botZ = array.get(zBot, ki)
            if dist < nearestDist
                nearestDist := dist
                nearestBull := array.get(zIsBull, ki)
            // If price inside a zone: paint strongly
            if low <= topZ and high >= botZ
                color zoneC = array.get(zIsBull, ki) ? color.rgb(0, 191, 165) : color.rgb(255, 82, 82)
                mszCandleColor := color.new(zoneC, 20)
    // If near a zone (within 0.5 ATR)
    if na(mszCandleColor) and nearestDist < ta.atr(14) * 0.5
        color nearC = nearestBull ? color.rgb(0, 191, 165) : color.rgb(255, 82, 82)
        mszCandleColor := color.new(nearC, 50)

barcolor(mszCandleColor, title="MSZ Zone Candle Color")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 12 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 8,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash and barstate.islast
    string momState = momRsiSpace > i_rsiOB ? "OVERBOUGHT" : momRsiSpace < i_rsiOS ? "OVERSOLD" : "NEUTRAL"
    color  momCol   = momRsiSpace > i_rsiOB ? BEAR_BASE : momRsiSpace < i_rsiOS ? BULL_BASE : LAVEN_HDR
    string volState = volReg > 1.3 ? "HIGH VOL" : volReg < 0.7 ? "LOW VOL" : "NORMAL"

    table.cell(dash, 0, 0, "Momentum Saturation Zones", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Source",      text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, i_momSrc,     text_color=NEON_CYAN,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 2, "Momentum",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 2, str.tostring(momRsiSpace, "#.#") + "  " + momState,
         text_color=momCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 3, "Pullback Thr",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, str.tostring(adaptPct, "#.#") + "%" + (i_useAdapt ? " (adaptive)" : " (fixed)"),
         text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 4, "Vol Regime",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, volState,      text_color=GOLD_VAL,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 5, "Active Zones",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 5, str.tostring(countValid()) + " / " + str.tostring(i_maxZones),
         text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 6, "Bear Strength",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 6, strengthStars(bearStr) + " " + str.tostring(bearStr),
         text_color=BEAR_BASE, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 7, "Bull Strength",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 7, strengthStars(bullStr) + " " + str.tostring(bullStr),
         text_color=BULL_BASE, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 13 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bearSat, "MSZ Bear Zone", "Momentum Saturation Zones [JOAT]: Bear resistance zone on {{ticker}} {{interval}}")
alertcondition(bullSat, "MSZ Bull Zone", "Momentum Saturation Zones [JOAT]: Bull support zone on {{ticker}} {{interval}}")
alertcondition(touchFiredBull, "MSZ Support Test", "Momentum Saturation Zones [JOAT]: Support zone tested on {{ticker}}")
alertcondition(touchFiredBear, "MSZ Resist Test",  "Momentum Saturation Zones [JOAT]: Resistance zone tested on {{ticker}}")
````

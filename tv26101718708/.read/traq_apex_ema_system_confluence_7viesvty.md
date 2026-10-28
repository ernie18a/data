# Traq APEX EMA System + Confluence

- url: https://www.tradingview.com/script/7viesVtY-Traq-APEX-EMA-System-Confluence/
- type: indicator
- pine_id: PUB;82f56d9008484ec19e17261338117ff5
- version: 1.0

## Description

Full Description:

Traq APEX EMA System + Confluence is a discretionary trading indicator designed to evaluate trend pullbacks using a combination of EMA structure, market structure, liquidity context, and risk-reference levels.

The script is built around the idea that an EMA pullback signal is more useful when it occurs in the presence of supporting structure. Instead of treating an EMA rejection alone as a trade signal, the script checks whether additional conditions are present, such as recent break of structure, internal liquidity sweeps, active fair value gap retests, higher-timeframe EMA alignment, session context, VWAP direction, and previous day/week liquidity levels.

Main Components

EMA Ribbon and Bias

The script plots an EMA ribbon using multiple moving averages. The ribbon is used to evaluate trend structure, compression, expansion, and pullback location. A separate bias EMA is used to judge broader directional context. The script can optionally require the price to agree with the bias EMA and can also require the bias EMA slope to support the trade direction.

Higher-Timeframe EMA Context

The indicator includes two configurable higher-timeframe EMA states. By default, these use the last closed higher-timeframe candle to avoid live higher-timeframe flicker. Users can choose between “No Opposition” and “Strict Alignment” modes.

“No Opposition” allows neutral higher-timeframe conditions but blocks signals when the selected higher timeframes oppose the trade direction. “Strict Alignment” requires both selected higher timeframes to align.

Pullback Signal Engine

The Traq APEX signal engine looks for pullbacks into the EMA ribbon followed by a rejection candle. Users can choose shallow, mid, or deep pullback depth. A minimum body-size filter based on ATR is included to reduce weak rejection candles.

The plotted signal is not intended to be a market-entry instruction. The displayed entry reference uses a stop-entry concept: above the signal candle high for long setups and below the signal candle low for short setups.

Break of Structure Context

The script tracks confirmed swing highs and swing lows using pivot logic. A bullish BOS occurs when the price closes above a prior swing high by a minimum point threshold. A bearish BOS occurs when the price closes below a prior swing low by a minimum point threshold. BOS is used as a structure filter and dashboard condition, not as a separate visual clutter layer.

Internal Liquidity Sweeps

The script tracks internal swing liquidity using pivot highs and lows. A buy-side sweep occurs when price trades through a recent swing high. A sell-side sweep occurs when the price trades through a recent swing low. These sweeps can be required as part of the confluence layer.

Internal liquidity drawings are capped through managed line and label arrays so that old liquidity markings do not consume the script’s drawing budget.

Active FVG Retest Tracking

The script detects bullish and bearish fair value gaps and stores multiple active FVGs in arrays. FVGs are only added and removed on confirmed bars to avoid intrabar rollback artifacts. Users can choose the mitigation mode: Touch, Midline, or Full Fill.

FVG retests can be used as a score component or required as a stricter filter.

External Liquidity Map

The script includes previous day high/low, previous week high/low, and previous week equilibrium. These levels are used as external liquidity context and optional score components.

External liquidity sweeps can be used to increase confluence but are not required by default.

Confluence Score

The script scores long and short conditions separately using available components such as BOS, internal sweep, FVG retest, session, VWAP direction, and external liquidity sweep. Users can set a minimum score threshold. This allows the script to be tested as either a broad pullback tool or a stricter confluence filter.

Risk Reference Levels

When a final signal appears, the script can display a stop reference and fixed R:R target. Stops are based on recent liquidity sweep levels when available, otherwise a fallback swing/ATR reference is used. These levels are visual references only and should be evaluated against each trader’s own risk plan.

How to Use

Start by using the script as a visual decision-support tool, not as an automated signal system.

Suggested starting settings for testing:

Use Closed HTF Bars: ON
MTF Mode: No Opposition
Require Recent BOS: ON
Require Internal Sweep: ON
Require Active FVG Retest: OFF
Require External Sweep: OFF
Minimum Confluence Score: 3
FVG Mitigation Mode: Midline
Max Internal LIQ Drawings: 20 to 30
Show Base Debug: ON during testing

The base debug markers can help show where the EMA pullback engine wanted to fire but the confluence layer blocked the signal.

Limitations

This script does not predict future price movement. It does not guarantee profitable trades, accuracy, win rate, or any specific trading result.

The indicator is designed for discretionary analysis and requires user judgment. Signals can fail, especially during choppy, low-volume, news-driven, or range-bound conditions.

Swing structure and liquidity levels are based on pivot confirmation, which means they are confirmed with delay. This avoids repainting after confirmation but does not identify swings instantly.

Higher-timeframe context defaults to closed HTF bars for stability. If users disable closed HTF mode, higher-timeframe arrows and context may update intrabar.

Risk labels and target labels are references only. They should not be treated as financial advice or as a substitute for proper position sizing, market context, and independent testing.

Chart Setup

For publication, use a clean candlestick chart with only this script applied. Avoid adding unrelated indicators, extra drawings, logos, promotional text, or contact references. The script output should be clearly visible, including the EMA ribbon, dashboard, liquidity labels, and a small number of example signals.

Disclaimer

This script is for educational and analytical use only. It does not provide financial advice, does not predict future market movement, and does not guarantee trading results. Users should test settings on their own markets and timeframes before relying on any output.

## Source Code

````pine
//@version=6
// ============================================================================
// APEX EMA SYSTEM + CONFLUENCE LAYER
// EMA Pullback Engine + BOS / Liquidity Sweep / Active FVG Retest / External LIQ Map
// Final L/S signals are close-confirmed.
// MTF context defaults to closed HTF candles for stable, non-flickering bias.
// FVG array state mutates only on confirmed bars (no intrabar rollback artifacts).
// ============================================================================

indicator("Traq APEX EMA System + Confluence", shorttitle="Traq APEX EMA+", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================================
// INPUTS — EMA RIBBON
// ============================================================================
gR = "── EMA Ribbon ──"
showRibbon = input.bool(true, "Show EMA Ribbon", group=gR)
src        = input.source(close, "Source", group=gR)

len1 = input.int(8,   "EMA 1", minval=1, group=gR, inline="r1")
len2 = input.int(13,  "EMA 2", minval=1, group=gR, inline="r1")
len3 = input.int(21,  "EMA 3", minval=1, group=gR, inline="r2")
len4 = input.int(34,  "EMA 4", minval=1, group=gR, inline="r2")
len5 = input.int(55,  "EMA 5", minval=1, group=gR, inline="r3")
len6 = input.int(89,  "EMA 6", minval=1, group=gR, inline="r3")
len7 = input.int(144, "EMA 7", minval=1, group=gR, inline="r4")
len8 = input.int(233, "EMA 8", minval=1, group=gR, inline="r4")

// ============================================================================
// INPUTS — BIAS / TREND
// ============================================================================
gB = "── Trend Bias ──"
biasLen      = input.int(200, "Bias EMA Length", minval=1, group=gB)
showBias     = input.bool(true, "Show Bias EMA", group=gB)
slopeLook    = input.int(5, "Slope Lookback", minval=1, group=gB)
slopeFlatPct = input.float(0.02, "Flat Threshold (% of price)", minval=0.0, step=0.01, group=gB)

requireBiasSlope = input.bool(true, "Require Bias EMA Slope", group=gB,
     tooltip="Longs require rising/not falling bias EMA. Shorts require falling/not rising bias EMA.")

// ============================================================================
// INPUTS — APEX SIGNAL ENGINE
// ============================================================================
gS = "── APEX Signals ──"
fastLen       = input.int(21, "Signal Fast EMA", minval=1, group=gS)
slowLen       = input.int(55, "Signal Slow EMA", minval=1, group=gS)
requireBias   = input.bool(true, "Require Bias Agreement", group=gS)
requireAlign  = input.bool(true, "Require Partial Stack E1–E5", group=gS)
requireRegime = input.bool(true, "Suppress Ranging Regime", group=gS)

pbLookback = input.int(3, "Pullback Lookback", minval=1, maxval=8, group=gS)
pbDepth    = input.string("Mid (E3)", "Pullback Depth", group=gS,
     options=["Shallow (E1)", "Mid (E3)", "Deep (E4)"])

minBodyAtr = input.float(0.3, "Min Rejection Body × ATR", minval=0.0, step=0.05, group=gS)
useConfirmedOnly = input.bool(true, "Confirmed Close Only", group=gS)

showSignals   = input.bool(true, "Show Final Signals", group=gS)
showBaseDebug = input.bool(false, "Show Base APEX Signals That Failed Confluence", group=gS)

// ============================================================================
// INPUTS — MULTI-TIMEFRAME
// ============================================================================
gM = "── Multi-Timeframe ──"
useMTF       = input.bool(true, "Enable MTF Panel", group=gM)
htf1         = input.timeframe("60", "Higher TF 1", group=gM)
htf2         = input.timeframe("240", "Higher TF 2", group=gM)
mtfFast      = input.int(21, "MTF Fast EMA", minval=1, group=gM)
mtfSlow      = input.int(55, "MTF Slow EMA", minval=1, group=gM)
mtfMinSpread = input.float(0.5, "Min HTF Spread × ATR", minval=0.0, step=0.1, group=gM)

mtfUseClosedBars = input.bool(true, "Use Closed HTF Bars", group=gM,
     tooltip="ON = MTF state uses the last fully closed HTF candle. More stable and avoids live HTF flicker. OFF = live HTF state updates intrabar.")

requireMTF = input.bool(true, "Require MTF Agreement", group=gM)
mtfMode = input.string("No Opposition", "MTF Filter Mode", group=gM,
     options=["No Opposition", "Strict Alignment"],
     tooltip="No Opposition allows neutral HTF. Strict requires both HTFs aligned.")

// ============================================================================
// INPUTS — REGIME FILTER
// ============================================================================
gRg = "── Regime Filter ──"
atrLen    = input.int(14, "ATR Length", minval=1, group=gRg)
trendMult = input.float(0.5, "Min Ribbon Spread × ATR", minval=0.0, step=0.1, group=gRg)

// ============================================================================
// INPUTS — CONFLUENCE LAYER
// ============================================================================
gC = "── Confluence Layer ──"
enableConfluence = input.bool(true, "Enable Confluence Layer", group=gC)

swingLookback  = input.int(10, "Swing Lookback", minval=3, maxval=50, group=gC)
signalExpiry   = input.int(30, "Confluence Expiry Bars", minval=5, maxval=100, group=gC)
bosMinPoints   = input.float(3.0, "Min BOS Strength Points", minval=0.1, group=gC)
bosBodyAtrMult = input.float(0.7, "Strong BOS Body × ATR", minval=0.1, step=0.1, group=gC)

requireBOS   = input.bool(true, "Require Recent BOS", group=gC)
requireSweep = input.bool(true, "Require Directional Internal Liquidity Sweep", group=gC)
requireFVG   = input.bool(false, "Require Active FVG Retest", group=gC,
     tooltip="Uses active tracked FVGs, not only the most recent FVG.")

minScore = input.int(3, "Minimum Confluence Score", minval=0, maxval=6, group=gC)

fvgMinSize     = input.float(3.0, "Min FVG Size Points", minval=0.1, group=gC)
maxTrackedFVGs = input.int(12, "Max Active FVGs Tracked", minval=1, maxval=50, group=gC)
fvgMitMode     = input.string("Midline", "FVG Mitigation Mode", group=gC,
     options=["Touch", "Midline", "Full Fill"],
     tooltip="Touch = first contact. Midline = 50% fill. Full Fill = complete gap fill.")

useSession = input.bool(true, "Use Session Filter In Score", group=gC)
nyTime     = input.string("0930-1100", "NY Session Time ET", group=gC)
londonTime = input.string("0300-0500", "London Session Time ET", group=gC)
allowLondon = input.bool(false, "Allow London", group=gC)
allowNY     = input.bool(true, "Allow NY", group=gC)

useVWAPScore = input.bool(true, "Use VWAP Direction In Score", group=gC)
vwapSlopeBars = input.int(5, "VWAP Slope Lookback", minval=1, group=gC)

// ============================================================================
// INPUTS — LIQUIDITY VISUALS
// ============================================================================
gLiq = "── Liquidity Visuals ──"

showInternalLiqLevels = input.bool(true, "Show Internal LIQ", group=gLiq)
maxInternalLiqLevels  = input.int(30, "Max Internal LIQ Drawings", minval=5, maxval=150, group=gLiq,
     tooltip="Caps internal pivot LIQ lines/labels so they do not consume the full TradingView drawing budget.")

showExternalLevels    = input.bool(true, "Show PDH/PDL/PWH/PWL LIQ", group=gLiq)
useExternalScore      = input.bool(true, "Use External Liquidity In Score", group=gLiq)
requireExternalSweep  = input.bool(false, "Require External Sweep", group=gLiq,
     tooltip="Strict mode. Longs require PDL/PWL sweep. Shorts require PDH/PWH sweep.")

liqLineCol      = input.color(color.orange, "All LIQ Line Color", group=gLiq)
liqLabelTxtCol  = input.color(color.orange, "All LIQ Label Text", group=gLiq)
liqLineWidth    = input.int(1, "All LIQ Line Width", minval=1, maxval=5, group=gLiq)

showPrevWeekEQ  = input.bool(true, "Show Previous Week Equilibrium", group=gLiq)
pwEqCol         = input.color(color.new(color.yellow, 0), "Prev Week EQ Color", group=gLiq)

// ============================================================================
// INPUTS — RISK / TARGETS
// ============================================================================
gRisk = "── Risk / Targets ──"
showStops  = input.bool(true, "Show Stop Level", group=gRisk)
showTarget = input.bool(true, "Show RR Target", group=gRisk)
stopAtrBuf = input.float(0.25, "Stop Buffer × ATR", minval=0.0, step=0.05, group=gRisk)
rrTarget   = input.float(2.0, "R:R Target", minval=0.5, step=0.5, group=gRisk)

// ============================================================================
// INPUTS — VISUALS
// ============================================================================
gV = "── Visuals ──"
ribbonFill = input.bool(true, "Fill Ribbon", group=gV)
colUp      = input.color(color.new(#26a69a, 0), "Bull", group=gV, inline="c1")
colDn      = input.color(color.new(#ef5350, 0), "Bear", group=gV, inline="c1")
colNeutral = input.color(color.new(#787b86, 0), "Neutral", group=gV, inline="c1")
showSRzone = input.bool(true, "Bias S/R Reaction Zone", group=gV)
showVwap   = input.bool(false, "Show VWAP", group=gV)
showGradeLabels = input.bool(true, "Show Grade Labels", group=gV)

// ============================================================================
// INPUTS — DASHBOARD
// ============================================================================
gD = "── Dashboard ──"
showDash = input.bool(true, "Show Dashboard", group=gD)
dashPos  = input.string("Top Right", "Position", group=gD,
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
dashSize = input.string("Normal", "Text Size", group=gD,
     options=["Tiny", "Small", "Normal", "Large"])

// ============================================================================
// INPUTS — ALERTS
// ============================================================================
gA = "── Alerts ──"
enableJsonAlerts = input.bool(false, "Enable JSON alert() Calls", group=gA)

// ============================================================================
// CORE EMA CALCULATIONS
// ============================================================================
e1 = ta.ema(src, len1)
e2 = ta.ema(src, len2)
e3 = ta.ema(src, len3)
e4 = ta.ema(src, len4)
e5 = ta.ema(src, len5)
e6 = ta.ema(src, len6)
e7 = ta.ema(src, len7)
e8 = ta.ema(src, len8)

biasEma = ta.ema(src, biasLen)
fastEma = ta.ema(src, fastLen)
slowEma = ta.ema(src, slowLen)
atr     = ta.atr(atrLen)

bullStack = e1 > e2 and e2 > e3 and e3 > e4 and e4 > e5 and e5 > e6 and e6 > e7 and e7 > e8
bearStack = e1 < e2 and e2 < e3 and e3 < e4 and e4 < e5 and e5 < e6 and e6 < e7 and e7 < e8

partialBullStack = e1 > e2 and e2 > e3 and e3 > e4 and e4 > e5
partialBearStack = e1 < e2 and e2 < e3 and e3 < e4 and e4 < e5

ribbonSpread = math.abs(e1 - e8)
isTrending = ribbonSpread >= trendMult * atr
isRanging = not isTrending

slopeAbs = biasEma - biasEma[slopeLook]
flatBand = close * slopeFlatPct / 100.0
biasRising = slopeAbs > flatBand
biasFalling = slopeAbs < -flatBand
biasFlat = not biasRising and not biasFalling

priceAboveBias = close > biasEma
priceBelowBias = close < biasEma

biasSlopeOkLong = not requireBiasSlope or not biasFalling
biasSlopeOkShort = not requireBiasSlope or not biasRising

pbEma = pbDepth == "Shallow (E1)" ? e1 : pbDepth == "Deep (E4)" ? e4 : e3

// ============================================================================
// MTF HELPER — CLOSED HTF BAR OPTION + TUPLE REQUEST
// ============================================================================
f_mtfPack(_offset) =>
    _fast = ta.ema(src, mtfFast)
    _slow = ta.ema(src, mtfSlow)
    _atr  = ta.atr(atrLen)
    [_fast[_offset], _slow[_offset], _fast[slopeLook + _offset], _atr[_offset]]

f_mtfState(_tf) =>
    _offset = mtfUseClosedBars ? 1 : 0
    [hf, hs, hp, ha] = request.security(
         syminfo.tickerid,
         _tf,
         f_mtfPack(_offset),
         lookahead=barmerge.lookahead_off)

    spread = math.abs(hf - hs)
    slopeUp = hf > hp
    slopeDn = hf < hp
    qualifies = spread >= ha * mtfMinSpread
    int st = hf > hs and slopeUp and qualifies ? 1 : hf < hs and slopeDn and qualifies ? -1 : 0
    st

mtfCurr = fastEma > slowEma ? 1 : fastEma < slowEma ? -1 : 0
mtf1 = useMTF ? f_mtfState(htf1) : 0
mtf2 = useMTF ? f_mtfState(htf2) : 0

mtfNoOppLong  = mtf1 != -1 and mtf2 != -1
mtfNoOppShort = mtf1 != 1 and mtf2 != 1

mtfStrictLong  = mtf1 == 1 and mtf2 == 1
mtfStrictShort = mtf1 == -1 and mtf2 == -1

mtfOkLong = not requireMTF or not useMTF or (mtfMode == "Strict Alignment" ? mtfStrictLong : mtfNoOppLong)
mtfOkShort = not requireMTF or not useMTF or (mtfMode == "Strict Alignment" ? mtfStrictShort : mtfNoOppShort)

mtfAllBull = mtfCurr == 1 and (not useMTF or mtfStrictLong)
mtfAllBear = mtfCurr == -1 and (not useMTF or mtfStrictShort)

// ============================================================================
// APEX PULLBACK ENGINE
// ============================================================================
var int barsFromPBBull = 999
var int barsFromPBBear = 999

if close < e5 or not partialBullStack
    barsFromPBBull := 999
else if open > e1 and low <= pbEma
    barsFromPBBull := 0
else
    barsFromPBBull := math.min(barsFromPBBull + 1, 999)

if close > e5 or not partialBearStack
    barsFromPBBear := 999
else if open < e1 and high >= pbEma
    barsFromPBBear := 0
else
    barsFromPBBear := math.min(barsFromPBBear + 1, 999)

bodySize = math.abs(close - open)
strongBody = bodySize >= atr * minBodyAtr

rejectionBull = close > e1 and close > open and strongBody
rejectionBear = close < e1 and close < open and strongBody

biasOkLong = not requireBias or priceAboveBias
biasOkShort = not requireBias or priceBelowBias

alignOkLong = not requireAlign or partialBullStack
alignOkShort = not requireAlign or partialBearStack

regimeOk = not requireRegime or isTrending
confirmedOk = not useConfirmedOnly or barstate.isconfirmed

apexLongBase = barsFromPBBull <= pbLookback and rejectionBull and alignOkLong and biasOkLong and biasSlopeOkLong and regimeOk and mtfOkLong and confirmedOk
apexShortBase = barsFromPBBear <= pbLookback and rejectionBear and alignOkShort and biasOkShort and biasSlopeOkShort and regimeOk and mtfOkShort and confirmedOk

// ============================================================================
// CONFLUENCE LAYER — SESSION / VWAP
// ============================================================================
londonSession = time(timeframe.period, londonTime, "America/New_York")
nySession = time(timeframe.period, nyTime, "America/New_York")

inLondon = not na(londonSession)
inNY = not na(nySession)
inAllowedSession = not useSession or (allowLondon and inLondon) or (allowNY and inNY)

vwapVal = ta.vwap(hlc3)
vwapSlope = vwapVal - vwapVal[vwapSlopeBars]

vwapOkLong = not useVWAPScore or (close > vwapVal and vwapSlope >= 0)
vwapOkShort = not useVWAPScore or (close < vwapVal and vwapSlope <= 0)

// ============================================================================
// CONFLUENCE LAYER — SWINGS / BOS
// ============================================================================
ph = ta.pivothigh(high, swingLookback, swingLookback)
pl = ta.pivotlow(low, swingLookback, swingLookback)

var float swingHigh = na
var int swingHighBar = na
var float swingLow = na
var int swingLowBar = na

if not na(ph)
    swingHigh := ph
    swingHighBar := bar_index - swingLookback

if not na(pl)
    swingLow := pl
    swingLowBar := bar_index - swingLookback

bullBOS = not na(swingHigh) and close > swingHigh and close[1] <= swingHigh and (close - swingHigh) >= bosMinPoints
bearBOS = not na(swingLow) and close < swingLow and close[1] >= swingLow and (swingLow - close) >= bosMinPoints

barBody = math.abs(close - open)
bullBOSStrong = bullBOS and barBody >= bosBodyAtrMult * atr
bearBOSStrong = bearBOS and barBody >= bosBodyAtrMult * atr

var bool recentBullBOS = false
var bool recentBearBOS = false
var int bullBOSAge = 9999
var int bearBOSAge = 9999

if bullBOS
    recentBullBOS := true
    recentBearBOS := false
    bullBOSAge := 0
    bearBOSAge := 9999
else
    bullBOSAge += 1
    if bullBOSAge > signalExpiry
        recentBullBOS := false

if bearBOS
    recentBearBOS := true
    recentBullBOS := false
    bearBOSAge := 0
    bullBOSAge := 9999
else
    bearBOSAge += 1
    if bearBOSAge > signalExpiry
        recentBearBOS := false

// ============================================================================
// CONFLUENCE LAYER — INTERNAL DIRECTIONAL LIQUIDITY SWEEPS
// Managed drawing arrays prevent LIQ drawings from exhausting global label/line budget.
// ============================================================================
var float liqHiVal = na
var float liqLoVal = na

var bool buySideSwept = false
var bool sellSideSwept = false

var int buySideSweepAge = 9999
var int sellSideSweepAge = 9999

var float lastBuySweepHigh = na
var float lastSellSweepLow = na

var array<line>  internalLiqLines  = array.new_line()
var array<label> internalLiqLabels = array.new_label()

f_addInternalLiq(_x1, _y, _isHigh) =>
    if showInternalLiqLevels
        newLiqLine = line.new(_x1, _y, bar_index, _y,
             color=liqLineCol, width=liqLineWidth, style=line.style_solid)

        newLiqLabel = label.new(_x1, _y, "LIQ",
             color=color.new(liqLineCol, 100), textcolor=liqLabelTxtCol,
             style=_isHigh ? label.style_label_down : label.style_label_up, size=size.tiny)

        array.push(internalLiqLines, newLiqLine)
        array.push(internalLiqLabels, newLiqLabel)

        while array.size(internalLiqLines) > maxInternalLiqLevels
            oldLine = array.shift(internalLiqLines)
            line.delete(oldLine)

        while array.size(internalLiqLabels) > maxInternalLiqLevels
            oldLabel = array.shift(internalLiqLabels)
            label.delete(oldLabel)

if not na(ph)
    liqHiVal := ph
    buySideSwept := false
    buySideSweepAge := 9999
    f_addInternalLiq(bar_index - swingLookback, ph, true)

if not na(pl)
    liqLoVal := pl
    sellSideSwept := false
    sellSideSweepAge := 9999
    f_addInternalLiq(bar_index - swingLookback, pl, false)

sweepHigh = not na(liqHiVal) and high >= liqHiVal
sweepLow = not na(liqLoVal) and low <= liqLoVal

if sweepHigh
    buySideSwept := true
    buySideSweepAge := 0
    lastBuySweepHigh := high
else if buySideSwept
    buySideSweepAge += 1
    if buySideSweepAge > signalExpiry
        buySideSwept := false

if sweepLow
    sellSideSwept := true
    sellSideSweepAge := 0
    lastSellSweepLow := low
else if sellSideSwept
    sellSideSweepAge += 1
    if sellSideSweepAge > signalExpiry
        sellSideSwept := false

// ============================================================================
// CONFLUENCE LAYER — EXTERNAL LIQUIDITY MAP
// PDH / PDL / PWH / PWL / Previous Week EQ
// ============================================================================
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)

pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_off)

prevWeekEQ = not na(pwh) and not na(pwl) ? (pwh + pwl) / 2.0 : na

isNewDayExt  = nz(ta.change(time("D")), 0) != 0
isNewWeekExt = nz(ta.change(time("W")), 0) != 0

pdhSweepNow = not na(pdh) and high >= pdh and high[1] < pdh
pdlSweepNow = not na(pdl) and low <= pdl and low[1] > pdl

pwhSweepNow = not na(pwh) and high >= pwh and high[1] < pwh
pwlSweepNow = not na(pwl) and low <= pwl and low[1] > pwl

var bool pdhSwept = false
var bool pdlSwept = false
var bool pwhSwept = false
var bool pwlSwept = false

var int pdhSweepAge = 9999
var int pdlSweepAge = 9999
var int pwhSweepAge = 9999
var int pwlSweepAge = 9999

var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na

var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na

if isNewDayExt
    pdhSwept := false
    pdlSwept := false
    pdhSweepAge := 9999
    pdlSweepAge := 9999

    line.delete(pdhLine)
    line.delete(pdlLine)
    label.delete(pdhLabel)
    label.delete(pdlLabel)

    if showExternalLevels and not na(pdh)
        pdhLine := line.new(bar_index, pdh, bar_index + 1, pdh,
             color=liqLineCol, width=liqLineWidth, style=line.style_solid)
        pdhLabel := label.new(bar_index, pdh, "PDH LIQ",
             color=color.new(liqLineCol, 100), textcolor=liqLabelTxtCol,
             style=label.style_label_left, size=size.tiny)

    if showExternalLevels and not na(pdl)
        pdlLine := line.new(bar_index, pdl, bar_index + 1, pdl,
             color=liqLineCol, width=liqLineWidth, style=line.style_solid)
        pdlLabel := label.new(bar_index, pdl, "PDL LIQ",
             color=color.new(liqLineCol, 100), textcolor=liqLabelTxtCol,
             style=label.style_label_left, size=size.tiny)

if isNewWeekExt
    pwhSwept := false
    pwlSwept := false
    pwhSweepAge := 9999
    pwlSweepAge := 9999

    line.delete(pwhLine)
    line.delete(pwlLine)
    label.delete(pwhLabel)
    label.delete(pwlLabel)

    if showExternalLevels and not na(pwh)
        pwhLine := line.new(bar_index, pwh, bar_index + 1, pwh,
             color=liqLineCol, width=liqLineWidth, style=line.style_solid)
        pwhLabel := label.new(bar_index, pwh, "PWH LIQ",
             color=color.new(liqLineCol, 100), textcolor=liqLabelTxtCol,
             style=label.style_label_left, size=size.tiny)

    if showExternalLevels and not na(pwl)
        pwlLine := line.new(bar_index, pwl, bar_index + 1, pwl,
             color=liqLineCol, width=liqLineWidth, style=line.style_solid)
        pwlLabel := label.new(bar_index, pwl, "PWL LIQ",
             color=color.new(liqLineCol, 100), textcolor=liqLabelTxtCol,
             style=label.style_label_left, size=size.tiny)

if pdhSweepNow
    pdhSwept := true
    pdhSweepAge := 0
else if pdhSwept
    pdhSweepAge += 1

if pdlSweepNow
    pdlSwept := true
    pdlSweepAge := 0
else if pdlSwept
    pdlSweepAge += 1

if pwhSweepNow
    pwhSwept := true
    pwhSweepAge := 0
else if pwhSwept
    pwhSweepAge += 1

if pwlSweepNow
    pwlSwept := true
    pwlSweepAge := 0
else if pwlSwept
    pwlSweepAge += 1

externalSweepLongFresh  = (pdlSwept and pdlSweepAge <= signalExpiry) or (pwlSwept and pwlSweepAge <= signalExpiry)
externalSweepShortFresh = (pdhSwept and pdhSweepAge <= signalExpiry) or (pwhSwept and pwhSweepAge <= signalExpiry)

externalLongTxt =
     pwlSwept and pwlSweepAge <= signalExpiry ? "PWL swept" :
     pdlSwept and pdlSweepAge <= signalExpiry ? "PDL swept" : "No sell-side ext sweep"

externalShortTxt =
     pwhSwept and pwhSweepAge <= signalExpiry ? "PWH swept" :
     pdhSwept and pdhSweepAge <= signalExpiry ? "PDH swept" : "No buy-side ext sweep"

weeklyDiscount = not na(prevWeekEQ) and close < prevWeekEQ
weeklyPremium  = not na(prevWeekEQ) and close > prevWeekEQ

weeklyLocationTxt =
     na(prevWeekEQ) ? "No PW EQ" :
     close > prevWeekEQ ? "Premium > PW EQ" :
     close < prevWeekEQ ? "Discount < PW EQ" : "At PW EQ"

// ============================================================================
// CONFLUENCE LAYER — ACTIVE FVG ENGINE
// Tracks multiple unmitigated FVGs instead of only the most recent FVG.
// Array state mutates ONLY on confirmed bars (no intrabar rollback artifacts).
// ============================================================================
bullFVG = low > high[2] and (low - high[2]) >= fvgMinSize
bearFVG = high < low[2] and (low[2] - high) >= fvgMinSize

var array<float> bullFvgTopArr = array.new_float()
var array<float> bullFvgBotArr = array.new_float()
var array<float> bullFvgMidArr = array.new_float()
var array<int>   bullFvgBarArr = array.new_int()

var array<float> bearFvgTopArr = array.new_float()
var array<float> bearFvgBotArr = array.new_float()
var array<float> bearFvgMidArr = array.new_float()
var array<int>   bearFvgBarArr = array.new_int()

f_trimFVGArrays(_topArr, _botArr, _midArr, _barArr) =>
    while array.size(_topArr) > maxTrackedFVGs
        array.shift(_topArr)
        array.shift(_botArr)
        array.shift(_midArr)
        array.shift(_barArr)

if barstate.isconfirmed and bullFVG
    fTop = low
    fBot = high[2]
    fMid = (fTop + fBot) / 2.0
    array.push(bullFvgTopArr, fTop)
    array.push(bullFvgBotArr, fBot)
    array.push(bullFvgMidArr, fMid)
    array.push(bullFvgBarArr, bar_index)
    f_trimFVGArrays(bullFvgTopArr, bullFvgBotArr, bullFvgMidArr, bullFvgBarArr)

if barstate.isconfirmed and bearFVG
    fTop = low[2]
    fBot = high
    fMid = (fTop + fBot) / 2.0
    array.push(bearFvgTopArr, fTop)
    array.push(bearFvgBotArr, fBot)
    array.push(bearFvgMidArr, fMid)
    array.push(bearFvgBarArr, bar_index)
    f_trimFVGArrays(bearFvgTopArr, bearFvgBotArr, bearFvgMidArr, bearFvgBarArr)

bullFvgRetest = false
bearFvgRetest = false

var float activeBullFvgTop = na
var float activeBullFvgBot = na
var float activeBullFvgMid = na

var float activeBearFvgTop = na
var float activeBearFvgBot = na
var float activeBearFvgMid = na

// Bull FVG scan — confirmed bars only. Iterate backward so removals are safe.
if barstate.isconfirmed and array.size(bullFvgTopArr) > 0
    for i = array.size(bullFvgTopArr) - 1 to 0
        fTop = array.get(bullFvgTopArr, i)
        fBot = array.get(bullFvgBotArr, i)
        fMid = array.get(bullFvgMidArr, i)
        fBar = array.get(bullFvgBarArr, i)

        touched = bar_index > fBar and low <= fTop and high >= fBot
        retested = touched and close > fMid

        mitigated =
             fvgMitMode == "Touch"   ? touched :
             fvgMitMode == "Midline" ? low <= fMid :
             low <= fBot

        if retested
            bullFvgRetest := true
            activeBullFvgTop := fTop
            activeBullFvgBot := fBot
            activeBullFvgMid := fMid

        if mitigated
            array.remove(bullFvgTopArr, i)
            array.remove(bullFvgBotArr, i)
            array.remove(bullFvgMidArr, i)
            array.remove(bullFvgBarArr, i)

// Bear FVG scan — confirmed bars only.
if barstate.isconfirmed and array.size(bearFvgTopArr) > 0
    for i = array.size(bearFvgTopArr) - 1 to 0
        fTop = array.get(bearFvgTopArr, i)
        fBot = array.get(bearFvgBotArr, i)
        fMid = array.get(bearFvgMidArr, i)
        fBar = array.get(bearFvgBarArr, i)

        touched = bar_index > fBar and high >= fBot and low <= fTop
        retested = touched and close < fMid

        mitigated =
             fvgMitMode == "Touch"   ? touched :
             fvgMitMode == "Midline" ? high >= fMid :
             high >= fTop

        if retested
            bearFvgRetest := true
            activeBearFvgTop := fTop
            activeBearFvgBot := fBot
            activeBearFvgMid := fMid

        if mitigated
            array.remove(bearFvgTopArr, i)
            array.remove(bearFvgBotArr, i)
            array.remove(bearFvgMidArr, i)
            array.remove(bearFvgBarArr, i)

// ============================================================================
// CONFLUENCE SCORING
// ============================================================================
bosOkLong = recentBullBOS
bosOkShort = recentBearBOS

sweepOkLong = sellSideSwept
sweepOkShort = buySideSwept

fvgOkLong = bullFvgRetest
fvgOkShort = bearFvgRetest

sessionOk = inAllowedSession

scoreLong = 0
scoreShort = 0
maxScore = 0

maxScore += 1
if bosOkLong
    scoreLong += 1
if bosOkShort
    scoreShort += 1

maxScore += 1
if sweepOkLong
    scoreLong += 1
if sweepOkShort
    scoreShort += 1

maxScore += 1
if fvgOkLong
    scoreLong += 1
if fvgOkShort
    scoreShort += 1

if useSession
    maxScore += 1
    if sessionOk
        scoreLong += 1
        scoreShort += 1

if useVWAPScore
    maxScore += 1
    if vwapOkLong
        scoreLong += 1
    if vwapOkShort
        scoreShort += 1

if useExternalScore
    maxScore += 1
    if externalSweepLongFresh
        scoreLong += 1
    if externalSweepShortFresh
        scoreShort += 1

effectiveMinScore = math.min(minScore, maxScore)

requiredLongOk =
     (not requireBOS or bosOkLong) and
     (not requireSweep or sweepOkLong) and
     (not requireFVG or fvgOkLong) and
     (not requireExternalSweep or externalSweepLongFresh)

requiredShortOk =
     (not requireBOS or bosOkShort) and
     (not requireSweep or sweepOkShort) and
     (not requireFVG or fvgOkShort) and
     (not requireExternalSweep or externalSweepShortFresh)

confluenceOkLong = not enableConfluence or (requiredLongOk and scoreLong >= effectiveMinScore)
confluenceOkShort = not enableConfluence or (requiredShortOk and scoreShort >= effectiveMinScore)

finalLongSignal = apexLongBase and confluenceOkLong
finalShortSignal = apexShortBase and confluenceOkShort

failedLongBase = apexLongBase and not confluenceOkLong
failedShortBase = apexShortBase and not confluenceOkShort

// ============================================================================
// GRADING
// ============================================================================
f_grade(_score, _max, _baseOk, _finalOk) =>
    not _baseOk ? "NONE" :
     not _finalOk ? "SKIP" :
     _score >= _max and _max >= 4 ? "A+" :
     _score >= _max - 1 ? "A" :
     _score >= effectiveMinScore ? "B" : "SKIP"

longGrade = f_grade(scoreLong, maxScore, apexLongBase, finalLongSignal)
shortGrade = f_grade(scoreShort, maxScore, apexShortBase, finalShortSignal)

// ============================================================================
// RISK LEVELS
// ============================================================================
entryLong = high + syminfo.mintick
entryShort = low - syminfo.mintick

fallbackStopLong = ta.lowest(low, pbLookback + swingLookback) - atr * stopAtrBuf
fallbackStopShort = ta.highest(high, pbLookback + swingLookback) + atr * stopAtrBuf

stopLevelLong = not na(lastSellSweepLow) and sellSideSwept ? lastSellSweepLow - atr * stopAtrBuf : fallbackStopLong
stopLevelShort = not na(lastBuySweepHigh) and buySideSwept ? lastBuySweepHigh + atr * stopAtrBuf : fallbackStopShort

riskLong = entryLong - stopLevelLong
riskShort = stopLevelShort - entryShort

tpLevelLong = entryLong + riskLong * rrTarget
tpLevelShort = entryShort - riskShort * rrTarget

validRiskLong = riskLong > syminfo.mintick
validRiskShort = riskShort > syminfo.mintick

// ============================================================================
// PLOTS — EMA RIBBON
// ============================================================================
ribbonCol = bullStack ? colUp : bearStack ? colDn : colNeutral

p1 = plot(showRibbon ? e1 : na, "EMA 1", color.new(ribbonCol, 0), 1)
p2 = plot(showRibbon ? e2 : na, "EMA 2", color.new(ribbonCol, 10), 1)
p3 = plot(showRibbon ? e3 : na, "EMA 3", color.new(ribbonCol, 20), 1)
p4 = plot(showRibbon ? e4 : na, "EMA 4", color.new(ribbonCol, 30), 1)
p5 = plot(showRibbon ? e5 : na, "EMA 5", color.new(ribbonCol, 40), 1)
p6 = plot(showRibbon ? e6 : na, "EMA 6", color.new(ribbonCol, 50), 1)
p7 = plot(showRibbon ? e7 : na, "EMA 7", color.new(ribbonCol, 60), 1)
p8 = plot(showRibbon ? e8 : na, "EMA 8", color.new(ribbonCol, 70), 2)

fill(p1, p8, ribbonFill and showRibbon ? color.new(ribbonCol, 88) : na, title="Ribbon Fill")

// ============================================================================
// PLOTS — BIAS EMA / ZONE / VWAP
// ============================================================================
biasPlotCol = biasRising ? colUp : biasFalling ? colDn : colNeutral

plot(showBias ? biasEma : na, "Bias EMA", color.new(biasPlotCol, 0), 2)

zoneUp = plot(showBias and showSRzone ? biasEma + atr * 0.25 : na, "SR Upper", color.new(biasPlotCol, 80), 1)
zoneDn = plot(showBias and showSRzone ? biasEma - atr * 0.25 : na, "SR Lower", color.new(biasPlotCol, 80), 1)

fill(zoneUp, zoneDn, showBias and showSRzone ? color.new(biasPlotCol, 90) : na, title="SR Zone")

plot(showVwap ? vwapVal : na, "Session VWAP", color.new(color.blue, 0), 2)

plot(showPrevWeekEQ ? prevWeekEQ : na, "Previous Week EQ", color=pwEqCol, linewidth=1, style=plot.style_linebr)

barcolor(isRanging ? color.new(colNeutral, 60) : na, title="Ranging Bars")

// ============================================================================
// SIGNAL MARKERS
// ============================================================================
plotshape(showSignals and finalLongSignal, "Final Long", shape.triangleup, location.belowbar, colUp, size=size.small, text="L")
plotshape(showSignals and finalShortSignal, "Final Short", shape.triangledown, location.abovebar, colDn, size=size.small, text="S")

plotshape(showBaseDebug and failedLongBase, "Base Long Failed", shape.circle, location.belowbar, color.new(colNeutral, 30), size=size.tiny, text="xL")
plotshape(showBaseDebug and failedShortBase, "Base Short Failed", shape.circle, location.abovebar, color.new(colNeutral, 30), size=size.tiny, text="xS")

if finalLongSignal and showGradeLabels
    label.new(bar_index, low,
         longGrade + " LONG\nScore " + str.tostring(scoreLong) + "/" + str.tostring(maxScore) +
         "\nEntry Stop " + str.tostring(entryLong, format.mintick),
         color=color.new(colUp, 10), textcolor=color.white, style=label.style_label_up, size=size.small)

if finalShortSignal and showGradeLabels
    label.new(bar_index, high,
         shortGrade + " SHORT\nScore " + str.tostring(scoreShort) + "/" + str.tostring(maxScore) +
         "\nEntry Stop " + str.tostring(entryShort, format.mintick),
         color=color.new(colDn, 10), textcolor=color.white, style=label.style_label_down, size=size.small)

if finalLongSignal and showStops and validRiskLong
    label.new(bar_index, stopLevelLong, "SL " + str.tostring(stopLevelLong, format.mintick),
         color=color.new(colDn, 20), textcolor=color.white, style=label.style_label_up, size=size.tiny)

if finalLongSignal and showTarget and validRiskLong
    label.new(bar_index, tpLevelLong, "TP " + str.tostring(tpLevelLong, format.mintick),
         color=color.new(colUp, 20), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if finalShortSignal and showStops and validRiskShort
    label.new(bar_index, stopLevelShort, "SL " + str.tostring(stopLevelShort, format.mintick),
         color=color.new(colUp, 20), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if finalShortSignal and showTarget and validRiskShort
    label.new(bar_index, tpLevelShort, "TP " + str.tostring(tpLevelShort, format.mintick),
         color=color.new(colDn, 20), textcolor=color.white, style=label.style_label_up, size=size.tiny)

// ============================================================================
// DASHBOARD
// ============================================================================
f_pos(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right : position.bottom_left

f_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Large" ? size.large : size.normal

f_arrow(_st) =>
    _st == 1 ? "▲ Bull" : _st == -1 ? "▼ Bear" : "► Flat"

f_acol(_st) =>
    _st == 1 ? colUp : _st == -1 ? colDn : colNeutral

var table dash = na

if showDash and na(dash)
    dash := table.new(f_pos(dashPos), 2, 13, border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

if showDash and barstate.islast
    table.clear(dash, 0, 0, 1, 12)
    ts = f_size(dashSize)

    table.cell(dash, 0, 0, "APEX EMA+", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=ts)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period + (mtfUseClosedBars ? " · HTF Closed" : " · HTF Live"),
         text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=ts)

    biasTxt = biasRising ? "Rising" : biasFalling ? "Falling" : "Flat"
    table.cell(dash, 0, 1, "Bias EMA", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 1, biasTxt + (priceAboveBias ? " · Px>EMA" : " · Px<EMA"),
         text_color=color.white, bgcolor=color.new(biasPlotCol, 30), text_size=ts)

    ribTxt = bullStack ? "Full Bull" :
         partialBullStack ? "Partial Bull" :
         bearStack ? "Full Bear" :
         partialBearStack ? "Partial Bear" : "Mixed"

    ribCol = bullStack ? colUp :
         partialBullStack ? color.new(colUp, 40) :
         bearStack ? colDn :
         partialBearStack ? color.new(colDn, 40) : colNeutral

    table.cell(dash, 0, 2, "Ribbon", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 2, ribTxt, text_color=color.white, bgcolor=color.new(ribCol, 30), text_size=ts)

    table.cell(dash, 0, 3, "Regime", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 3, isTrending ? "Trending" : "Ranging",
         text_color=color.white, bgcolor=isTrending ? color.new(colUp, 30) : color.new(colNeutral, 20), text_size=ts)

    table.cell(dash, 0, 4, "TF " + timeframe.period, text_color=color.white, text_size=ts)
    table.cell(dash, 1, 4, f_arrow(mtfCurr), text_color=color.white, bgcolor=color.new(f_acol(mtfCurr), 30), text_size=ts)

    table.cell(dash, 0, 5, "TF " + (useMTF ? htf1 : "—"), text_color=color.white, text_size=ts)
    table.cell(dash, 1, 5, useMTF ? f_arrow(mtf1) : "off", text_color=color.white, bgcolor=color.new(f_acol(mtf1), 30), text_size=ts)

    table.cell(dash, 0, 6, "TF " + (useMTF ? htf2 : "—"), text_color=color.white, text_size=ts)
    table.cell(dash, 1, 6, useMTF ? f_arrow(mtf2) : "off", text_color=color.white, bgcolor=color.new(f_acol(mtf2), 30), text_size=ts)

    structTxt = recentBullBOS ? "Bull BOS " + str.tostring(bullBOSAge) + "b" :
         recentBearBOS ? "Bear BOS " + str.tostring(bearBOSAge) + "b" : "Neutral"

    structCol = recentBullBOS ? colUp : recentBearBOS ? colDn : colNeutral

    table.cell(dash, 0, 7, "Structure", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 7, structTxt, text_color=color.white, bgcolor=color.new(structCol, 30), text_size=ts)

    sweepTxt = sellSideSwept ? "Sell-side swept" :
         buySideSwept ? "Buy-side swept" : "No sweep"

    sweepCol = sellSideSwept ? colUp : buySideSwept ? colDn : colNeutral

    table.cell(dash, 0, 8, "Internal LIQ", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 8, sweepTxt, text_color=color.white, bgcolor=color.new(sweepCol, 30), text_size=ts)

    fvgTxt = bullFvgRetest ? "Bull FVG Retest" :
         bearFvgRetest ? "Bear FVG Retest" : "No Retest"

    fvgCol = bullFvgRetest ? colUp : bearFvgRetest ? colDn : colNeutral

    table.cell(dash, 0, 9, "FVG", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 9, fvgTxt, text_color=color.white, bgcolor=color.new(fvgCol, 30), text_size=ts)

    extTxt =
         externalSweepLongFresh ? externalLongTxt :
         externalSweepShortFresh ? externalShortTxt : "No external sweep"

    extCol =
         externalSweepLongFresh ? colUp :
         externalSweepShortFresh ? colDn : colNeutral

    table.cell(dash, 0, 10, "External LIQ", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 10, extTxt, text_color=color.white, bgcolor=color.new(extCol, 30), text_size=ts)

    eqCol =
         weeklyDiscount ? colUp :
         weeklyPremium ? colDn : colNeutral

    table.cell(dash, 0, 11, "PW EQ", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 11, weeklyLocationTxt, text_color=color.white, bgcolor=color.new(eqCol, 30), text_size=ts)

    scoreTxt = "L " + str.tostring(scoreLong) + "/" + str.tostring(maxScore) + " · S " + str.tostring(scoreShort) + "/" + str.tostring(maxScore)

    table.cell(dash, 0, 12, "Score", text_color=color.white, text_size=ts)
    table.cell(dash, 1, 12, scoreTxt, text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=ts)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(finalLongSignal, "APEX+ Long", "APEX EMA+: Final LONG signal on {{ticker}} {{interval}}")
alertcondition(finalShortSignal, "APEX+ Short", "APEX EMA+: Final SHORT signal on {{ticker}} {{interval}}")

alertcondition(apexLongBase and not finalLongSignal, "APEX Base Long Failed Confluence", "APEX EMA+: Base LONG failed confluence on {{ticker}} {{interval}}")
alertcondition(apexShortBase and not finalShortSignal, "APEX Base Short Failed Confluence", "APEX EMA+: Base SHORT failed confluence on {{ticker}} {{interval}}")

alertcondition(bullBOS, "Bull BOS", "APEX EMA+: Bullish BOS on {{ticker}} {{interval}}")
alertcondition(bearBOS, "Bear BOS", "APEX EMA+: Bearish BOS on {{ticker}} {{interval}}")

alertcondition(sweepLow, "Internal Sell-side Sweep", "APEX EMA+: Internal sell-side liquidity swept on {{ticker}} {{interval}}")
alertcondition(sweepHigh, "Internal Buy-side Sweep", "APEX EMA+: Internal buy-side liquidity swept on {{ticker}} {{interval}}")

alertcondition(bullFvgRetest, "Bull FVG Retest", "APEX EMA+: Bullish active FVG retest on {{ticker}} {{interval}}")
alertcondition(bearFvgRetest, "Bear FVG Retest", "APEX EMA+: Bearish active FVG retest on {{ticker}} {{interval}}")

alertcondition(pdhSweepNow, "PDH Sweep", "APEX EMA+: Previous Day High swept on {{ticker}} {{interval}}")
alertcondition(pdlSweepNow, "PDL Sweep", "APEX EMA+: Previous Day Low swept on {{ticker}} {{interval}}")
alertcondition(pwhSweepNow, "PWH Sweep", "APEX EMA+: Previous Week High swept on {{ticker}} {{interval}}")
alertcondition(pwlSweepNow, "PWL Sweep", "APEX EMA+: Previous Week Low swept on {{ticker}} {{interval}}")

if enableJsonAlerts and finalLongSignal and validRiskLong
    alert('{"system":"APEX_EMA_PLUS","side":"LONG","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","grade":"' + longGrade + '","score":"' + str.tostring(scoreLong) + '/' + str.tostring(maxScore) + '","entry_stop":"' + str.tostring(entryLong, format.mintick) + '","sl":"' + str.tostring(stopLevelLong, format.mintick) + '","tp":"' + str.tostring(tpLevelLong, format.mintick) + '"}', alert.freq_once_per_bar_close)

if enableJsonAlerts and finalShortSignal and validRiskShort
    alert('{"system":"APEX_EMA_PLUS","side":"SHORT","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","grade":"' + shortGrade + '","score":"' + str.tostring(scoreShort) + '/' + str.tostring(maxScore) + '","entry_stop":"' + str.tostring(entryShort, format.mintick) + '","sl":"' + str.tostring(stopLevelShort, format.mintick) + '","tp":"' + str.tostring(tpLevelShort, format.mintick) + '"}', alert.freq_once_per_bar_close)
````

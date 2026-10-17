# AF_StochZ_Overlay

- url: https://www.tradingview.com/script/6zRUGnaI/
- type: indicator
- pine_id: PUB;15495e11fbad4c929d832b2a76c171c8
- version: 2.0

## Description

AF_StochZ Overlay — Adaptive Fisher-Transformed Stochastic with Z-Score Normalized Lead Signals & Divergence Detection

Overview

AF_StochZ Overlay is a price-chart (overlay) signal tool built on a statistically normalized, adaptive stochastic oscillator. Instead of plotting the oscillator in a separate pane, it converts the oscillator's extreme readings and divergences directly into labeled buy/sell markers on price, so traders can react to momentum-based signals without switching focus between panes.

How it works

Adaptive lookback (Efficiency Ratio): The stochastic lookback length is not fixed. It is calculated每 bar using Kaufman's Efficiency Ratio (ER), which compares net directional price change to total path traveled over erLen bars. When price moves efficiently (strong trend), the lookback contracts toward minLen for faster response; when price is choppy, the lookback expands toward maxLen to filter noise.
Stochastic → Fisher Transform: A standard %K stochastic is calculated over this adaptive length, smoothed, then rescaled to a ±1 range and passed through a Fisher Transform. The Fisher Transform sharpens turning points by converting a bounded oscillator into a signal with a more Gaussian (normal) distribution, making extremes statistically more distinct than a raw stochastic.
Z-Score normalization: The Fisher-transformed value is then normalized against its own rolling mean and standard deviation (zLen) to produce a Z-Score. This means overbought/oversold thresholds are expressed in standard deviations from the indicator's own recent behavior, rather than fixed 0–100 levels — the thresholds self-adjust to each instrument's and timeframe's own statistical character.
Lead-signal confirmation logic: A raw Z-Score pivot alone is not enough to fire a signal. The script requires the oscillator to pivot beyond the user-defined threshold, AND price itself to form a confirmed swing pivot (pricePivotL/pricePivotR) within a maximum bar lag (maxPriceLag) after that oscillator pivot. Only when both conditions line up in sequence does a BUY/SELL label print. This two-stage confirmation is designed to reduce the false positives that pure oscillator-crossing signals typically generate.
Regular & hidden divergence detection: Independently of the lead signals, the script scans a configurable lookback window (divLookbackMin–divLookbackMax) for regular divergence (price extreme vs. oscillator extreme disagreement, signaling potential reversal) and hidden divergence (signaling potential trend continuation), comparing confirmed price pivots against the Z-Score oscillator at the same pivots.

What problem it solves

Classic stochastic oscillators use a fixed lookback and fixed 0–100 overbought/oversold bands, which makes them lag in trending markets and whipsaw in choppy ones, and their thresholds are not adapted to the volatility regime of the specific instrument being traded. AF_StochZ Overlay addresses this by (a) adapting its own lookback to current market efficiency, (b) expressing overbought/oversold as a statistically self-calibrating Z-Score rather than an arbitrary fixed band, and (c) requiring price-action confirmation before a signal is drawn, rather than firing on the oscillator alone.

Originality

While each individual building block (Efficiency Ratio-based adaptive length, Fisher Transform, Z-Score normalization, pivot-based divergence) is a known technical-analysis concept, the specific combination here — an ER-adaptive stochastic whose Fisher-transformed output is Z-Score normalized, gated through a two-stage oscillator-then-price pivot confirmation sequence, and cross-checked against independent regular/hidden divergence logic, all rendered as overlay labels rather than a separate pane — is an original synthesis, not a copy of any single public script.

How to use

Green/Red "BUY"/"SELL" labels: statistically-confirmed lead signals (oscillator pivot + confirmed price pivot within the lag window).
"R-Bull"/"R-Bear" labels: regular divergence (potential reversal).
"H-Bull"/"H-Bear" labels: hidden divergence (potential trend continuation).
All lengths, thresholds, and lag windows are adjustable in the input groups.

Disclaimer

This script is a technical analysis tool, not financial advice. No indicator can guarantee profit or eliminate risk. Backtest and forward-test on your own instruments/timeframes before live use, and always apply independent risk management.

## Source Code

````pine
//@version=6
indicator("AF_StochZ_Overlay", shorttitle="AF_StochZ_Overlay", overlay=true, max_labels_count=500)

// ==========================================
// 1. INPUTS
// ==========================================
int minLen          = input.int(8, "Min Length", minval=1, group="Adaptive Parameters")
int maxLen          = input.int(34, "Max Length", minval=1, group="Adaptive Parameters", tooltip="Max Length, Min Length'ten kucuk girilirse otomatik olarak Min Length'e clamp edilir.")
int erLen           = input.int(10, "ER Length", minval=1, group="Adaptive Parameters")

int smoothK         = input.int(3, "%K Smoothing", minval=1, group="Signal Settings")
int smoothD         = input.int(3, "%D Signal", minval=1, group="Signal Settings")
bool useKDFilter    = input.bool(false, "Require %K/%D Confirmation", group="Signal Settings", tooltip="Aktifse: BUY sinyali icin %K > %D, SELL sinyali icin %K < %D sarti da aranir.")
int zLen            = input.int(20, "Z-Score Length", minval=2, group="Statistical Settings")
int oscPivotBars    = input.int(1, "Oscillator Pivot Bars (L=R)", minval=1, maxval=5, group="Statistical Settings", tooltip="Osilator pivot tespiti icin sol/sag bar sayisi. Deger buyudukce daha az ama daha guvenilir sinyal uretir.")

// Indicator Extreme Thresholds
float osLevel       = input.float(-1.0, "Oversold Level (Z-Score)", group="Level Thresholds")
float obLevel       = input.float(1.0, "Overbought Level (Z-Score)", group="Level Thresholds")

// Price Pivot Confirmation Bars & Lag Limits
int pricePivotL     = input.int(3, "Price Pivot Left Bars", minval=1, group="Price Pivot Filter")
int pricePivotR     = input.int(2, "Price Pivot Right Bars", minval=1, group="Price Pivot Filter")
int maxPriceLag     = input.int(5, "Max Lag After Osc Pivot (Bars)", minval=1, maxval=10, group="Price Pivot Filter")

color colLeadBull   = input.color(color.green, "Buy Signal Color", group="Color Settings")
color colLeadBear   = input.color(color.red, "Sell Signal Color", group="Color Settings")

// Trend Filter (YENI - 35 yillik TA onerisi)
bool useTrendFilter = input.bool(false, "Use Trend Filter (EMA)", group="Trend Filter", tooltip="Aktifse: BUY sinyalleri sadece fiyat EMA'nin ustundeyken, SELL sinyalleri sadece fiyat EMA'nin altindayken uretilir. Varsayilan kapali (geriye donuk uyumluluk).")
int trendEmaLen     = input.int(200, "Trend EMA Length", minval=1, group="Trend Filter")

// Divergence Settings
bool showRegularDiv = input.bool(true, "Show Regular Divergence", group="Divergence Settings")
bool showHiddenDiv  = input.bool(true, "Show Hidden Divergence", group="Divergence Settings")
bool showDivLines   = input.bool(false, "Show Divergence Lines", group="Divergence Settings")
int divLookbackMin  = input.int(5, "Divergence Min Lookback (Bars)", minval=1, group="Divergence Settings")
int divLookbackMax  = input.int(60, "Divergence Max Lookback (Bars)", minval=1, group="Divergence Settings")

color colRegBullDiv = input.color(color.green, "Reg. Bullish Div Color", group="Divergence Colors")
color colRegBearDiv = input.color(color.red, "Reg. Bearish Div Color", group="Divergence Colors")
color colHidBullDiv = input.color(color.teal, "Hid. Bullish Div Color", group="Divergence Colors")
color colHidBearDiv = input.color(color.orange, "Hid. Bearish Div Color", group="Divergence Colors")

// ==========================================
// 2. STOCHASTIC & Z-SCORE CALCULATIONS
// ==========================================
int safeMaxLen      = math.max(maxLen, minLen)   // FIX: Min Length > Max Length durumunda cakismayi onler

float change        = math.abs(close - close[erLen])
float volatility    = ta.sma(math.abs(close - close[1]), erLen) * erLen
float er            = volatility != 0 ? change / volatility : 0.0
int adaptiveLen     = math.max(minLen, math.min(safeMaxLen, int(math.round(safeMaxLen - er * (safeMaxLen - minLen)))))

float highestHigh   = ta.highest(high, adaptiveLen)
float lowestLow     = ta.lowest(low, adaptiveLen)
float stochRng      = highestHigh - lowestLow
float rawStoch      = stochRng != 0 ? ((close - lowestLow) / stochRng) * 100 : 50.0
float stochK        = ta.sma(rawStoch, smoothK)
float stochD        = ta.sma(stochK, smoothD)   // FIX: onceden hesaplanip hic kullanilmayan input artik gercekten kullaniliyor

float stochScaled   = math.max(math.min((stochK - 50) / 50, 0.998), -0.998)
float fisherStoch   = 0.5 * math.log((1 + stochScaled) / (1 - stochScaled))

float meanZ         = ta.sma(fisherStoch, zLen)
float stdDevZ       = ta.stdev(fisherStoch, zLen)
float zStochK       = stdDevZ != 0 ? (fisherStoch - meanZ) / stdDevZ : 0.0

// Trend filtresi icin EMA (YENI)
float trendEma      = ta.ema(close, trendEmaLen)
bool bullTrendOK    = not useTrendFilter or close > trendEma
bool bearTrendOK    = not useTrendFilter or close < trendEma

// %K/%D teyit filtresi (YENI)
bool kdBullOK        = stochK > stochD
bool kdBearOK        = stochK < stochD

// ==========================================
// 3. SIGNAL LOGIC (LEAD SIGNALS)
// ==========================================
float oscPl = ta.pivotlow(zStochK, oscPivotBars, oscPivotBars)
float oscPh = ta.pivothigh(zStochK, oscPivotBars, oscPivotBars)

var int lastValidOscLowBar  = na
var int lastValidOscHighBar = na

// FIX: barstate.isconfirmed eklendi. Kapanmamis (canli) barin verisiyle onaylanan bir pivotun
// bir sonraki tick'te degisip "kaybolmasi" (repaint benzeri davranis) engellenir.
if not na(oscPl) and oscPl < osLevel and barstate.isconfirmed
    lastValidOscLowBar := bar_index - oscPivotBars

if not na(oscPh) and oscPh > obLevel and barstate.isconfirmed
    lastValidOscHighBar := bar_index - oscPivotBars

float pricePl = ta.pivotlow(low, pricePivotL, pricePivotR)
float pricePh = ta.pivothigh(high, pricePivotL, pricePivotR)

var int lastFiredBullBar = na
var int lastFiredBearBar = na

bool leadBullSignal = false
bool leadBearSignal = false

int priceLowBar  = bar_index - pricePivotR
int priceHighBar = bar_index - pricePivotR

// BULLISH SIGNAL CHECK
if not na(pricePl) and not na(lastValidOscLowBar) and barstate.isconfirmed and bullTrendOK and (not useKDFilter or kdBullOK)
    int diffLow = priceLowBar - lastValidOscLowBar
    if diffLow >= 0 and diffLow <= maxPriceLag and (na(lastFiredBullBar) or lastFiredBullBar != lastValidOscLowBar)
        leadBullSignal := true
        lastFiredBullBar := lastValidOscLowBar

// BEARISH SIGNAL CHECK
if not na(pricePh) and not na(lastValidOscHighBar) and barstate.isconfirmed and bearTrendOK and (not useKDFilter or kdBearOK)
    int diffHigh = priceHighBar - lastValidOscHighBar
    if diffHigh >= 0 and diffHigh <= maxPriceLag and (na(lastFiredBearBar) or lastFiredBearBar != lastValidOscHighBar)
        leadBearSignal := true
        lastFiredBearBar := lastValidOscHighBar

// ==========================================
// 4. DIVERGENCE DETECTION
// ==========================================
// FIX: eski kodda divPricePl/divPricePh, section 3'teki pricePl/pricePh ile birebir ayniydi.
// Ayni ta.pivotlow/ta.pivothigh cagrisi iki kez yapiliyordu -> kaldirildi, mevcut degiskenler kullaniliyor.
bool regBullDiv = false
bool regBearDiv = false
bool hidBullDiv = false
bool hidBearDiv = false

int prevBullBar = na
int prevBearBar = na

int safeDivMax = math.max(divLookbackMax, divLookbackMin)  // FIX: Min > Max girilirse guvenli sinir

// Bullish Divergence Search
if not na(pricePl) and barstate.isconfirmed
    int pBar = bar_index - pricePivotR
    float pLow = low[pricePivotR]
    float pOsc = zStochK[pricePivotR]

    for i = divLookbackMin to safeDivMax
        if not na(pricePl[i])
            int prevBar = pBar - i
            float prevLow = low[pricePivotR + i]
            float prevOsc = zStochK[pricePivotR + i]

            if showRegularDiv and pLow < prevLow and pOsc > prevOsc
                regBullDiv := true
                prevBullBar := prevBar
                break

            if showHiddenDiv and pLow > prevLow and pOsc < prevOsc
                hidBullDiv := true
                prevBullBar := prevBar
                break

// Bearish Divergence Search
if not na(pricePh) and barstate.isconfirmed
    int pBar = bar_index - pricePivotR
    float pHigh = high[pricePivotR]
    float pOsc = zStochK[pricePivotR]

    for i = divLookbackMin to safeDivMax
        if not na(pricePh[i])
            int prevBar = pBar - i
            float prevHigh = high[pricePivotR + i]
            float prevOsc = zStochK[pricePivotR + i]

            if showRegularDiv and pHigh > prevHigh and pOsc < prevOsc
                regBearDiv := true
                prevBearBar := prevBar
                break

            if showHiddenDiv and pHigh < prevHigh and pOsc > prevOsc
                hidBearDiv := true
                prevBearBar := prevBar
                break

// ==========================================
// 5. UNIFIED OVERLAY LABELS & PLOTTING
// ==========================================
float atrVal = ta.atr(14)

// BULLISH LABELS (Below Bar)
if leadBullSignal or regBullDiv or hidBullDiv
    string txt = ""
    color bgCol = colLeadBull

    if leadBullSignal
        txt := "BUY"
        if regBullDiv
            txt := txt + "\nR-Bull"
            bgCol := colRegBullDiv
        else if hidBullDiv
            txt := txt + "\nH-Bull"
            bgCol := colHidBullDiv
    else if regBullDiv
        txt := "R-Bull"
        bgCol := colRegBullDiv
    else if hidBullDiv
        txt := "H-Bull"
        bgCol := colHidBullDiv

    label.new(x=priceLowBar, y=low[pricePivotR] - (atrVal * 0.2), text=txt, color=bgCol, textcolor=color.white, style=label.style_label_up, size=size.normal)

    if showDivLines and (regBullDiv or hidBullDiv) and not na(prevBullBar)
        line.new(x1=prevBullBar, y1=low[bar_index - prevBullBar], x2=priceLowBar, y2=low[pricePivotR], color=bgCol, width=2, style=hidBullDiv ? line.style_dashed : line.style_solid)

// BEARISH LABELS (Above Bar)
if leadBearSignal or regBearDiv or hidBearDiv
    string txt = ""
    color bgCol = colLeadBear

    if leadBearSignal
        txt := "SELL"
        if regBearDiv
            txt := txt + "\nR-Bear"
            bgCol := colRegBearDiv
        else if hidBearDiv
            txt := txt + "\nH-Bear"
            bgCol := colHidBearDiv
    else if regBearDiv
        txt := "R-Bear"
        bgCol := colRegBearDiv
    else if hidBearDiv
        txt := "H-Bear"
        bgCol := colHidBearDiv

    label.new(x=priceHighBar, y=high[pricePivotR] + (atrVal * 0.2), text=txt, color=bgCol, textcolor=color.white, style=label.style_label_down, size=size.normal)

    if showDivLines and (regBearDiv or hidBearDiv) and not na(prevBearBar)
        line.new(x1=prevBearBar, y1=high[bar_index - prevBearBar], x2=priceHighBar, y2=high[pricePivotR], color=bgCol, width=2, style=hidBearDiv ? line.style_dashed : line.style_solid)

// ==========================================
// 6. ALERTS
// ==========================================
alertcondition(leadBullSignal, title="StochZ Lead BUY", message="BUY Signal: Price Pivot Low confirmed after Indicator Reversal!")
alertcondition(leadBearSignal, title="StochZ Lead SELL", message="SELL Signal: Price Pivot High confirmed after Indicator Reversal!")

alertcondition(regBullDiv, title="Regular Bullish Divergence", message="Regular Bullish Divergence Detected!")
alertcondition(regBearDiv, title="Regular Bearish Divergence", message="Regular Bearish Divergence Detected!")
alertcondition(hidBullDiv, title="Hidden Bullish Divergence", message="Hidden Bullish Divergence Detected!")
alertcondition(hidBearDiv, title="Hidden Bearish Divergence", message="Hidden Bearish Divergence Detected!")
````

<!-- tradingview-pine-id: PUB;1cc3037149604657b9c77f811ce38e9d -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Kamote Regime Filter v1.8

Source: https://www.tradingview.com/script/r3oO0KYi-Kamote-v1-0/

## Description

Kamote v1.0 gives traders a clear, color-coded decision system that tells them the current market regime and the single highest-probability strategy to use—or when to stay out—across Intraday, Day, and Swing horizons.

It does this by combining five independent, hysteresis-protected filters into one coherent recommendation engine, displayed in a clean status matrix with fully configurable alerts. The result is fewer forced trades in dead or chaotic conditions and higher-confidence entries when the conditions actually align.

### Core Value: One Dashboard That Replaces Guesswork ###
Most indicators show isolated signals. Kamote synthesizes volatility regime, higher-timeframe trend direction, trend efficiency, volume behavior, and horizon-specific strategy scoring into a single, actionable output. Traders see at a glance:

[*] Whether volatility is Dead, Healthy, or Extreme  
[*] Whether the higher-timeframe linear-regression slope is Bullish, Bearish, or Flat  
[*] Whether multi-timeframe Kaufman Efficiency Ratio confirms real trend strength  
[*] Whether volume is Expanding, Contracting, or Flat  
[*] The optimal strategy (Trend Long/Short, Pullback Long/Short, Momentum Long/Short, Breakout, Mean Reversion) or “Stay Out / None”

Color coding makes the matrix instantly readable. Green supports action, red signals caution or exit, yellow flags transitional states.

### How the Engine Works ###
Kamote runs a single higher-timeframe data request (automatically set by the chosen trading mode) and blends it with chart-timeframe calculations. All regime classifications use percentile ranks plus hysteresis bands so the status does not flicker on every minor bar.

Volatility Regime (ATR Percentile + Hysteresis)  
ATR is ranked over a lookback window. Dead (< low percentile), Extreme (> high percentile), or Healthy. Hysteresis prevents rapid oscillation between states. Extreme + contracting volume + weak efficiency is treated as structural noise and forces a “Stay Out” recommendation.

Higher-Timeframe Trend Filter (ATR-Scaled Linear Regression Slope)
Slope is calculated on the higher timeframe, normalized by ATR, and classified Bullish / Bearish / Flat. The threshold itself scales with volatility so the filter stays relevant in both quiet and explosive markets.

Multi-Timeframe Efficiency Ratio
Kaufman’s Efficiency Ratio is computed on both chart and higher timeframes, then blended with user-adjustable weights. A minimum threshold gates whether the move is efficient enough to support trend or momentum strategies.

Volume Regime (Percentile + Hysteresis)
Volume is ranked and classified Expanding / Contracting / Flat. Expanding volume supports breakouts and trend continuation; contracting volume favors mean-reversion or short-side setups depending on direction.

Horizon-Aware Strategy Scoring  
The script first checks for hard invalid states (extreme volatility + contracting volume + weak efficiency, flat slope + weak efficiency + flat volume, or swing-mode + flat slope + extreme ATR). If any invalid condition is true, the recommendation is “Stay Out.”

Otherwise it scores eight strategy candidates using eligibility gates and horizon-specific weights:

[*] Trend and Pullback strategies are favored on Day and especially Swing horizons.  
[*] Momentum strategies are favored on Intraday.  
[*] Breakout receives a boost on Intraday and a discount on Swing.  
[*] Mean Reversion is favored on Swing and discounted on Intraday.

The highest-scoring eligible strategy is displayed. Confidence modifiers (healthy ATR, volume alignment, weak prior efficiency, etc.) further refine the score so the recommendation is not binary.

### Designed for Real Trading Workflows ###
Three preset modes (Intra / Day / Swing) automatically adjust higher-timeframe, efficiency length, volume lookback, slope threshold, ATR window, and hysteresis. Users can still fine-tune every parameter. Layout can be horizontal or vertical and placed in any corner. Alerts fire only on confirmed state changes for ATR regime, slope direction, efficiency cross, volume regime, and strategy recommendation—keeping notification noise low.

### Why Traders Adopt It ###
Kamote does not claim to predict the future. It enforces discipline by making regime and edge explicit. When the matrix is green and a strategy is named, the conditions that historically support that style of trade are present. When it says “Stay Out,” the market is offering no edge. That single piece of information—knowing when not to trade—is often more valuable than any entry signal.

The script is pure Pine Script v6, overlay=false, and designed to sit alongside price action or other tools without cluttering the chart. It is built for discretionary traders who want a systematic regime filter and for systematic traders who need a clean, multi-factor permission layer.

Install Kamote v1.0, select your trading horizon, and let the status matrix tell you what the market is actually offering right now.

---

## Source Code

````pine
//@version=6
// Script Name: Kamote Regime Filter
// Script Version: v1.8
// Author: isid0re
// Description:
//      Percentile based ATR regime detection with hysteresis,
//      Higher-Timeframe Linear Regression slope filter (ATR-scaled),
//      Multi-timeframe Kaufman Efficiency Ratio (trend strength),
//      Volume regime classification (Expanding / Contracting / Flat),
//      Horizon-aware score based strategy recommendation engine (Intra / Day / Swing),
//      Status matrix with color-coded conditions, and alert conditions.
// Last Updated: 2026-09-03

// ==========================================
// SCRIPT DECLARATION
// ==========================================
indicator(title = "Kamote Regime Filter v1.8", shorttitle = "Kamote", overlay = false)

// ==========================================
// COLORS
// ==========================================
white  = color.white
black  = color.black
gray   = color.new(#D0CECE, 0)
red    = color.new(#E07A7A, 0)
orange = color.new(#F9C89E, 0)
yellow = color.new(#FDF0A6, 0)
green  = color.new(#A2D2B5, 0)
blue   = color.new(#A2C2E8,0)
purple = color.new(#D2BCE0, 0)

// ==========================================
// USER INPUTS
// ==========================================

// Display Settings
layout   = input.string("H", "Horizontal or Vertical Layout", options=["H", "V"], group = "Display Settings")
location = input.string("BR", "Position", options=["TR", "TL", "BR", "BL"], group = "Display Settings")
showRawSeries = input.bool(false, "Plot raw underlying series", group = "Display Settings")

// Trade Horizon Selector
horizon      = input.string("Day", "Trading Mode", options = ["Intra", "Day", "Swing"], group = "Trade Horizon Settings")
htfPreset    = horizon == "Intra" ? "60" : horizon == "Day" ? "240" : "1D"
erPreset     = horizon == "Intra" ? 5 : horizon == "Day" ? 10 : 20
volPreset    = horizon == "Intra" ? 10 : horizon == "Day" ? 20 : 50
slopePreset  = horizon == "Intra" ? 0.10 : horizon == "Day" ? 0.12 : 0.15
windowPreset = horizon == "Intra" ? 150 : horizon == "Day" ? 200 : 220
hystPreset   = horizon == "Intra" ? 4.0 : horizon == "Day" ? 5.0 : 6.0
useConfirmedHtf = input.bool(true, "Use confirmed HTF bar (adds up to 1 HTF-bar lag)", group = "Trade Horizon Settings")

// ATR Percentile Settings
atrLen       = input.int(14, "ATR Length", minval = 1, group = "ATR Percentile Settings")
atrWindow    = windowPreset

// Regime Percentile Thresholds + Hysteresis
lowPct       = input.float(30.0, "Dead Regime Percentile", step = 1.0, group = "Regime Thresholds")
highPct      = input.float(70.0, "Extreme Regime Percentile", step = 1.0, group = "Regime Thresholds")
hystBand     = hystPreset

// Higher Timeframe 
htf = htfPreset

// LR Slope Filter (HTF)
slopeBars = input.int(20, "LR Slope Lookback (HTF bars)", minval = 5, group = "LR Slope — HTF Trend Filter")
slopeThreshold = slopePreset

// Efficiency Ratio Filter
erLen = erPreset
erWeightHtf = input.float(0.70, "ER HTF Weight (higher = more importance)", step = 0.05, minval = 0.05, maxval = 0.95, group = "Efficiency Ratio Filter")
erWeightLtf = 1- erWeightHtf
erThreshold = input.float(0.35, "ER Minimum (higher = more efficient)", step = 0.05, minval = 0.05, maxval = 0.95, group = "Efficiency Ratio Filter")

// Volume Regime Settings (Percentile + Hysteresis)
volLookback  = volPreset
volLowPct    = input.float(30.0, "Volume Contracting Percentile", step = 1.0, group = "Volume Regime")
volHighPct   = input.float(70.0, "Volume Expanding Percentile",   step = 1.0, group = "Volume Regime")
volHystBand  = input.float(5.0,  "Volume Hysteresis Band (±)",    step = 0.5, minval = 0.0, group = "Volume Regime")

// Alert Settings
enableAtrAlerts     = input.bool(true, "Enable ATR Alerts", group = "Alert Settings")
enableSlopeAlerts   = input.bool(true, "Enable LR Slope Alerts", group = "Alert Settings")
enableErAlerts      = input.bool(true, "Enable Efficiency Ratio Alerts", group = "Alert Settings")
enableVolumeAlerts  = input.bool(true, "Enable Volume Alerts", group = "Alert Settings")
enableStrategyAlerts= input.bool(true, "Enable Strategy Alerts", group = "Alert Settings")

// ==========================================
// FUNCTIONS
// ==========================================

// --- ATR Regime Classification ---
// Clamp hysteresis so bands cannot overlap thresholds
f_clamp_hysteresis(_lowPct, _highPct, _hystBand) =>
    maxHyst = (_highPct - _lowPct) / 2
    math.min(_hystBand, maxHyst)

// --- ATR Regime Classification (Percentile-based) with Hysteresis ---
f_atr_regime(_pct, _lowPct, _highPct, _hyst, _prevAtrDead, _prevAtrExtreme) =>
    enterDead    = _pct < (_lowPct - _hyst)
    exitDead     = _pct > (_lowPct + _hyst)

    enterExtreme = _pct > (_highPct + _hyst)
    exitExtreme  = _pct < (_highPct - _hyst)

    dead    = _prevAtrDead ? not exitDead : enterDead
    extreme = _prevAtrExtreme ? not exitExtreme : enterExtreme
    healthy = not dead and not extreme

    [dead, extreme, healthy]

// --- LR Slope Classification ---
f_lr_slope_state(_slope, _thr) =>
    _flat = math.abs(_slope) < _thr
    _bull = _slope > _thr
    _bear = _slope < -_thr
    [_flat, _bull, _bear]

// --- Kaufman Efficiency Ratio ---
f_efficiency_ratio(_len) =>
    change = math.abs(close - close[_len])
    volatility = math.sum(math.abs(close - close[1]), _len)
    er = volatility != 0 ? change / volatility : 0.0
    er

// --- Multi‑TF ER ---
f_er_blend(_erLtf, _erHtf, _wLtf, _wHtf, _threshold) =>
    erAvg = (_wLtf * _erLtf) + (_wHtf * _erHtf)
    isEfficiencyValid  = erAvg >= _threshold
    [erAvg, isEfficiencyValid]

// --- Volume Regime Classification --- 
f_volume_regime(_lookback, _lowPct, _highPct, _hyst, _prevExp, _prevCon) =>
    volPct = ta.percentrank(volume, _lookback)
    
    // Hysteresis bands
    enterExp = volPct > (_highPct + _hyst)
    exitExp  = volPct < (_highPct - _hyst)
    
    enterCon = volPct < (_lowPct - _hyst)
    exitCon  = volPct > (_lowPct + _hyst)
    
    expanding   = _prevExp ? not exitExp : enterExp
    contracting = _prevCon ? not exitCon : enterCon
    flat        = not expanding and not contracting
    
    [expanding, contracting, flat, volPct]

// --- Single HTF Data Packet ---
f_htf_packet(_useConfirmedHtf, _atrLen, _atrWindow, _slopeBars, _erLenHtf, _tf) =>
    i = _useConfirmedHtf ? 1 : 0
    
    request.security(
        syminfo.tickerid,
        _tf,
        [
            ta.percentrank(ta.atr(_atrLen), _atrWindow)[i],                             // 0: atrPct
            ta.atr(_atrLen)[i],                                                         // 1: atrRaw (for scaling)
            (ta.linreg(close, _slopeBars, 0) - ta.linreg(close, _slopeBars, 1))[i],     // 2: lrSlopeRaw
            f_efficiency_ratio(_erLenHtf)[i],                                           // 3: erHtf
            close[i]                                                                    // 4: htfClose
        ],
        lookahead = barmerge.lookahead_off,
        gaps      = barmerge.gaps_off
    )

// --- Composite Strategy Permission ---
f_strategy_permission(_isAtrDead, _isAtrExtreme, _isAtrHealthy, _isSlopeFlat, _isSlopeBullish, _isSlopeBearish, _isEfficiencyValid, _isVolExpanding, _isVolContracting, _isVolFlat, _horizon) =>
    isIntra = _horizon == "Intra"
    isSwing = _horizon == "Swing"

    // --- Structural invalid states ---
    extremeStress = _isAtrExtreme and not _isEfficiencyValid                                  // Extreme ATR + weak ER = stressed / inefficient price movement
    breakoutCandidate = _isSlopeFlat and _isVolExpanding and not _isAtrDead                   // Breakout environment: flat slope + expanding participation + live ATR
    breakoutStressException = breakoutCandidate and _isAtrExtreme and not _isEfficiencyValid  // The market is transitioning from a flat state with expanding participation

    invalidUnstable  =  extremeStress and not breakoutStressException                         // Extreme ATR + weak ER = Stay Out unless the Breakout exception qualifies
    invalidNoEdge    = _isSlopeFlat and not _isEfficiencyValid and _isVolFlat                 // Flat slope + weak ER + flat volume = no edge to exploit
    invalidSwingChop = isSwing and _isSlopeFlat and _isAtrExtreme                             // Swing horizon + flat slope + extreme ATR = whipsaw chop

    invalid = invalidUnstable or invalidNoEdge or invalidSwingChop

    if invalid
        "Stay Out"
    else
        // --- Strategy Eligibility ---
        eligTrendLong     = (not isIntra) and _isSlopeBullish and _isEfficiencyValid ? 1.0 : 0.0 // Trend Long: non-Intra + bullish slope + valid ER
        eligTrendShort    = (not isIntra) and _isSlopeBearish and _isEfficiencyValid ? 1.0 : 0.0 // Trend Short: non-Intra + bearish slope + valid ER
        eligPullbackLong = (not isIntra) and _isSlopeBullish and not _isEfficiencyValid ? 1.0 : 0.0  // Pullback Long: non‑Intra + bullish slope + weak ER
        eligPullbackShort = (not isIntra) and _isSlopeBearish and not _isEfficiencyValid ? 1.0 : 0.0  // Pullback Short: non‑Intra + bearish slope + weak ER        
        eligMomentumLong  = (not isSwing) and _isAtrExtreme and _isSlopeBullish and _isEfficiencyValid and _isVolExpanding ? 1.0 : 0.0 // Momentum Long: non-Swing + Extreme ATR + Bullish slope + Valid efficiency ratio + Expanding participation (Extreme ATR alone cannot qualify Momentum)
        eligMomentumShort = (not isSwing) and _isAtrExtreme and _isSlopeBearish and _isEfficiencyValid and _isVolExpanding ? 1.0 : 0.0 // Momentum Short: non-Swing + Extreme ATR + Bearish slope + Valid efficiency ratio + Expanding participation (Extreme ATR alone cannot qualify Momentum)
        eligBreakout      = _isSlopeFlat and _isVolExpanding and (not _isAtrDead) and (_isAtrExtreme or not _isEfficiencyValid) ? 1.0 : 0.0 // Breakout: flat slope + expanding participation + live ATR + (extreme ATR or weak efficiency)
        eligMeanReversion = _isAtrDead and _isSlopeFlat and (not _isVolExpanding) ? 1.0 : 0.0 // Mean Reversion: dead ATR + flat slope + non-expanding volume (contracting or flat)

        // --- Secondary Eligibility: Used only to grade confidence within an already-eligible strategy ---
        confAtrHealthy = _isAtrHealthy ? 1.0 : 0.0      // Healthy (non-dead, non-extreme) ATR supports directional trend/pullback confidence
        confVolExp     = _isVolExpanding ? 1.0 : 0.0    // Supports trend-long / momentum-long confidence when volume is not actively contracting
        confVolCon     = _isVolContracting ? 1.0 : 0.0  // Supports trend-short confidence when volume is not actively expanding
        confVolFlat    = _isVolFlat ? 1.0 : 0.0         // Supports mean-reversion confidence (flat volume is the archetypal mean-reversion volume profile)
        confWeakEr     = _isEfficiencyValid ? 0.0 : 1.0 // Supports breakout confidence specifically via the weak-ER qualifying path
        confAtrExt     = _isAtrExtreme ? 1.0 : 0.0      // Supports breakout confidence specifically via the volatility-spike qualifying path

        // Horizon-specific weights for each strategy, applied only when the strategy is eligible (per the gates above).
        wTrend    = isSwing ? 1.2 : 1.0                       // Trend: Day baseline, Swing favored
        wPull     = isSwing ? 1.1 : 1.0                       // Pullback: Day baseline, Swing favored
        wMomentum = isIntra ? 1.3 : 1.0                       // Momentum: Day baseline, Intra favored
        wBreak    = isSwing ? 0.8 : isIntra ? 1.2 : 1.0       // Breakout: eligible at all horizons; Intra favored, Swing discounted
        wMeanRev  = isIntra ? 0.6 : isSwing ? 1.4 : 1.0       // Mean Reversion: eligible at all horizons; Swing favored, Intra discounted

        // Signal Scores per strategy
        trendLongScore     = eligTrendLong     * wTrend    * (1.0 + 0.5 * confAtrHealthy + 0.3 * confVolExp)
        trendShortScore    = eligTrendShort    * wTrend    * (1.0 + 0.5 * confAtrHealthy + 0.3 * confVolExp)
        pullbackLongScore  = eligPullbackLong  * wPull     * (1.0 + 0.5 * confAtrHealthy + 0.3 * (1.0 - confVolExp)) // Pullback Long: non-Intra + bullish slope + weak ER Rewards the absence of expanding volume (opposing state)
        pullbackShortScore = eligPullbackShort * wPull     * (1.0 + 0.5 * confAtrHealthy + 0.3 * (1.0 - confVolExp)) // Pullback Short: non-Intra + bearish slope + weak ER Rewards the absence of expanding volume (opposing state)
        momentumLongScore  = eligMomentumLong  * wMomentum
        momentumShortScore = eligMomentumShort * wMomentum
        breakoutScore      = eligBreakout      * wBreak    * (1.0 + 0.5 * (confAtrExt * confWeakEr))
        meanReversionScore = eligMeanReversion * wMeanRev  * (1.0 + 0.5 * confVolFlat)

        // Select the highest scoring strategy
        strats = array.new_string(0)
        scores = array.new_float(0)

        array.push(strats, "Trend Long")
        array.push(scores, trendLongScore)

        array.push(strats, "Trend Short")
        array.push(scores, trendShortScore)

        array.push(strats, "Pullback Long")
        array.push(scores, pullbackLongScore)

        array.push(strats, "Pullback Short")
        array.push(scores, pullbackShortScore)

        array.push(strats, "Momentum Long")
        array.push(scores, momentumLongScore)

        array.push(strats, "Momentum Short")
        array.push(scores, momentumShortScore)

        array.push(strats, "Breakout")
        array.push(scores, breakoutScore)

        array.push(strats, "Mean Reversion")
        array.push(scores, meanReversionScore)

        bestStratIdx = 0
        bestScore = array.get(scores, 0)

        for i = 1 to array.size(scores) - 1
            s = array.get(scores, i)
            if s > bestScore
                bestScore := s
                bestStratIdx := i

        bestStrat = array.get(strats, bestStratIdx)

        bestScore > 0.0 ? bestStrat : "None"

// --- Color helper function ---
f_get_color(_exp1, _exp2, _exp3, _green, _red, _yellow, _white) =>
    _exp1 ? _green : _exp2 ? _red : _exp3 ? _yellow : _white

// --- Status Matrix Rendering ---

// Map dashboard position strings
f_get_table_position(_pos) =>
    switch _pos
        "TR"    => position.top_right
        "TL"    => position.top_left
        "BR"    => position.bottom_right
        "BL"    => position.bottom_left
        => position.top_right

// Determine orientation and number of rows/columns based on layout
f_get_table_layout(_layout) =>
    isVertical = (_layout == "V")  
    
    totalCols = isVertical ? 2 : 6 // vertical = 2 columns x 6 rows
    totalRows = isVertical ? 6 : 2 // horizontal = 6 columns x 2 rows

    [totalCols, totalRows]

f_render_cell(_table, _layout, _index, _label, _label_color, _label_bgColor, _value, _val_color, _val_bgColor) =>
    isVertical = (_layout == "V")  
  
    if isVertical
        c = 0
        r = _index
        table.cell(_table, c, r, _label, text_color=_label_color, text_size=size.normal, bgcolor=_label_bgColor)
        table.cell(_table, c + 1, r, _value, text_color=_val_color, text_size=size.normal, bgcolor=_val_bgColor)
    else
        c = _index
        r = 0
        table.cell(_table, c, r, _label, text_color=_label_color, text_size=size.normal, bgcolor=_label_bgColor)
        table.cell(_table, c, r + 1, _value, text_color=_val_color, text_size=size.normal, bgcolor=_val_bgColor)

// --- Dynamic Alerts ---
f_dynamic_alert(_enabled, _trigger, _message) =>
    if _enabled and barstate.isconfirmed and _trigger
        alert(_message, alert.freq_once_per_bar_close)

// ==========================================
// DATA & CALCULATIONS
// ==========================================

// Resolution guard
chartSeconds = timeframe.in_seconds(timeframe.period)
htfSeconds   = timeframe.in_seconds(htf)

if chartSeconds >= htfSeconds
    runtime.error("The Higher Timeframe resolution must be greater than the chart timeframe (" + timeframe.period + ").")

// Regime Percentile Thresholds + Hysteresis guard
if lowPct >= highPct
    runtime.error("Dead Regime Percentile must be less than Extreme Regime Percentile.")
if volLowPct >= volHighPct
    runtime.error("Volume Contracting Percentile must be less than Volume Expanding Percentile.")

// ER HTF length
erLenHtf = erLen

// ---------- SINGLE HTF REQUEST ----------
[atrPct, atrHtf, lrSlopeRaw, erHtf, htfClose] = f_htf_packet(useConfirmedHtf, atrLen, atrWindow, slopeBars, erLenHtf, htf)

// Derived local values
lrSlope  = lrSlopeRaw / htfClose
atrNorm  = atrHtf / htfClose
slopeThr = slopeThreshold * atrNorm

[isSlopeFlat, isSlopeBullish, isSlopeBearish] = f_lr_slope_state(lrSlope, slopeThr)

// ---------- LTF ER + blend ----------
erLtf = f_efficiency_ratio(erLen)
[erAvg, isEfficiencyValid] = f_er_blend(erLtf, erHtf, erWeightLtf, erWeightHtf, erThreshold)

// ---------- Volume Regime + Hysteresis ----------
var bool prevVolExp = false
var bool prevVolCon = false
volHyst = f_clamp_hysteresis(volLowPct, volHighPct, volHystBand)
[isVolExpanding, isVolContracting, isVolFlat, volPct] = f_volume_regime(volLookback, volLowPct, volHighPct, volHyst, prevVolExp, prevVolCon)

// ---------- Dataset Validity Guard ----------
htfBarsNeeded      = math.max(atrWindow, slopeBars)
chartBarsNeededHtf = math.ceil(htfBarsNeeded * htfSeconds / chartSeconds)
chartBarsNeeded    = math.max(erLen, volLookback)
minHistory         = math.max(chartBarsNeededHtf, chartBarsNeeded) + 10

badDataSetTxt = "Bad Dataset"
badDataSet = na(atrPct) or na(atrHtf) or na(lrSlopeRaw) or na(erLtf) or na(erHtf) or na(volume) or na(volPct) or na(htfClose) or htfClose == 0 or bar_index < minHistory

// ---------- ATR Regime + Hysteresis ----------
var bool prevAtrDead    = false
var bool prevAtrExtreme = false

hyst = f_clamp_hysteresis(lowPct, highPct, hystBand)
[isAtrDead, isAtrExtreme, isAtrHealthy] = f_atr_regime(atrPct, lowPct, highPct, hyst, prevAtrDead, prevAtrExtreme)

if not badDataSet and barstate.isconfirmed // Only update state on valid data and confirmed bars
    prevAtrDead    := isAtrDead
    prevAtrExtreme := isAtrExtreme
    prevVolExp  := isVolExpanding
    prevVolCon  := isVolContracting

// ---------- Strategy ---------- 
var string optimalStrategy = "Loading"

if barstate.isconfirmed
    optimalStrategy := badDataSet ? badDataSetTxt : f_strategy_permission(isAtrDead, isAtrExtreme, isAtrHealthy, isSlopeFlat, isSlopeBullish, isSlopeBearish, isEfficiencyValid, isVolExpanding, isVolContracting, isVolFlat, horizon)

// ---------- Visuals ---------- 

var arr_labels = array.from("Volatility Regime (%)", "HTF Trend Direction", "Trend Strength", syminfo.volumetype == "tick" ? "Tick Volume (%)" : "Volume Regime (%)", "Volume Alignment", "Recommendation")

volatilityTxt = (isAtrDead ? "Dead" : isAtrExtreme ? "Extreme" : "Healthy") + " (" + str.tostring(atrPct, "0.00") + "%)"
volatilityColor = f_get_color(isAtrHealthy, isAtrDead, isAtrExtreme, green, red, yellow, white)

directionTxt = isSlopeFlat ? "Sideways" : isSlopeBullish ? "Bullish" : "Bearish"
directionColor = f_get_color(isSlopeBullish, isSlopeBearish, isSlopeFlat, green, red, yellow, white)

strengthTxt = str.tostring(erAvg, "0.00")
strengthColor = isEfficiencyValid ? green : red

volumeTxt =  (isVolExpanding ? "Expanding" : isVolContracting ? "Contracting" : "Flat") + " (" + str.tostring(volPct, "0.00") + "%)"
volumeColor = f_get_color(isVolExpanding, isVolContracting, isVolFlat, green, red, yellow, white)

alignmentTxt = switch
    isSlopeBullish and isVolExpanding    => "Bull Confirmed"
    isSlopeBearish and isVolExpanding    => "Bear Confirmed"
    isSlopeBullish and isVolContracting  => "Bull Exhaustion"
    isSlopeBearish and isVolContracting  => "Bear Exhaustion"
    isSlopeFlat and isVolExpanding and not isAtrDead => "Breakout / Expansion"
    => "Low Energy / Neutral"

alignmentColor = f_get_color(
    (isSlopeBullish and isVolExpanding) or (isSlopeBearish and isVolExpanding),     // green – confirmed
    (isSlopeBullish and isVolContracting) or (isSlopeBearish and isVolContracting), // red – exhaustion
    (isSlopeFlat and isVolExpanding and not isAtrDead),                             // yellow – breakout
    green, red, yellow, white
)

strategyTxt = optimalStrategy
strategyColor = f_get_color( 
    not badDataSet and not (strategyTxt == "Stay Out") and not (strategyTxt == "None"),
    strategyTxt == "Stay Out",
    strategyTxt == "None",
    green, red, yellow, white
)

// ==========================================
// EXECUTION
// ==========================================


// ==========================================
// PLOTTING & VISUALIZATION
// ==========================================

// ---------- Series Plots (for debugging) ----------
// --- HTF LR Slope (dimensionless) ---
plot(showRawSeries and not badDataSet ? lrSlope : na, title="HTF LR Slope", color=color.purple, display = display.data_window)
plot(showRawSeries and not badDataSet ? slopeThr : na,  "Slope Bullish Threshold", color=color.green, linestyle=plot.linestyle_dotted, display = display.data_window)
plot(showRawSeries and not badDataSet ? -slopeThr : na, "Slope Bearish Threshold", color=color.red, linestyle=plot.linestyle_dotted, display = display.data_window)

// --- ATR Percentile (0–100) ---
plot(showRawSeries and not badDataSet ? atrPct : na, title="ATR Percentile", color=color.blue)
plot(showRawSeries and not badDataSet ? lowPct : na,  "ATR Dead Threshold",  color=color.red, linestyle=plot.linestyle_dotted)
plot(showRawSeries and not badDataSet ? highPct : na, "ATR Extreme Threshold", color=color.yellow, linestyle=plot.linestyle_dotted)

// --- Efficiency Ratio Average (converted to %) ---
plot(showRawSeries and not badDataSet ? erAvg * 100 : na, title="Efficiency Ratio (%)", color=color.teal)
plot(showRawSeries and not badDataSet ? erThreshold * 100 : na, "ER Threshold (%)", color=color.orange, linestyle=plot.linestyle_dotted)

// --- Volume Percentile (0–100) ---
plot(showRawSeries and not badDataSet ? volPct : na, title="Volume Percentile", color=color.fuchsia)
plot(showRawSeries and not badDataSet ? volLowPct : na,  "Volume Contracting Threshold", color=color.red, linestyle=plot.linestyle_dotted)
plot(showRawSeries and not badDataSet ? volHighPct : na, "Volume Expanding Threshold",  color=color.green, linestyle=plot.linestyle_dotted)

// ---------- Status Matrix ---------- 
[col, row] = f_get_table_layout(layout)
var table matrix = table.new(f_get_table_position(location), col, row, border_width = 1)

if badDataSet
    for i = 0 to array.size(arr_labels) - 1
        f_render_cell(matrix, layout, i, array.get(arr_labels, i), black, gray, badDataSetTxt, black, white)
else if barstate.isconfirmed and barstate.islast
    f_render_cell(matrix, layout, 0, array.get(arr_labels, 0), black, gray, volatilityTxt, black, volatilityColor)
    f_render_cell(matrix, layout, 1, array.get(arr_labels, 1), black, gray, directionTxt, black, directionColor)
    f_render_cell(matrix, layout, 2, array.get(arr_labels, 2), black, gray, strengthTxt, black, strengthColor)
    f_render_cell(matrix, layout, 3, array.get(arr_labels, 3), black, gray, volumeTxt, black, volumeColor)
    f_render_cell(matrix, layout, 4, array.get(arr_labels, 4), black, gray, alignmentTxt, black, alignmentColor)
    f_render_cell(matrix, layout, 5, array.get(arr_labels, 5), black, gray, optimalStrategy, black, strategyColor)

// ==========================================
// ALERTS
// ==========================================

// --- State Alerts (triggered only on state change) ---
isAtrDeadAlert            = not badDataSet and isAtrDead and not isAtrDead[1]
isAtrExtremeAlert         = not badDataSet and isAtrExtreme and not isAtrExtreme[1]
isAtrHealthyAlert         = not badDataSet and isAtrHealthy and not isAtrHealthy[1]
lrSlopeFlatAlert        = not badDataSet and isSlopeFlat and not isSlopeFlat[1]
lrSlopeBullAlert        = not badDataSet and isSlopeBullish and not isSlopeBullish[1]
lrSlopeBearAlert        = not badDataSet and isSlopeBearish and not isSlopeBearish[1]
erCrossAboveAlert       = not badDataSet and isEfficiencyValid and not isEfficiencyValid[1]
erCrossBelowAlert       = not badDataSet and not isEfficiencyValid and isEfficiencyValid[1]
isVolExpandingAlert       = not badDataSet and isVolExpanding and not isVolExpanding[1]
isVolContractingAlert     = not badDataSet and isVolContracting and not isVolContracting[1]
isVolFlatAlert            = not badDataSet and isVolFlat and not isVolFlat[1]

// --- Strategy Change Alert (triggered only on strategy change) ---
strategyChangedAlert    = not badDataSet and optimalStrategy != optimalStrategy[1]

// --- ATR Regime Alerts ---
f_dynamic_alert(enableAtrAlerts, isAtrDeadAlert, "HTF ATR regime entered DEAD state (low volatility).")
f_dynamic_alert(enableAtrAlerts, isAtrExtremeAlert, "HTF ATR regime entered EXTREME state (high volatility).")
f_dynamic_alert(enableAtrAlerts, isAtrHealthyAlert, "HTF ATR regime entered HEALTHY state (balanced volatility).")

// --- LR Slope Alerts ---
f_dynamic_alert(enableSlopeAlerts, lrSlopeFlatAlert, "HTF LR slope turned flat.")
f_dynamic_alert(enableSlopeAlerts, lrSlopeBullAlert, "HTF LR slope turned bullish.")
f_dynamic_alert(enableSlopeAlerts, lrSlopeBearAlert, "HTF LR slope turned bearish.")

// --- Efficiency Ratio Alerts ---
f_dynamic_alert(enableErAlerts, erCrossAboveAlert, "Multi-TF ER now meets minimum strength.")
f_dynamic_alert(enableErAlerts, erCrossBelowAlert, "Multi-TF ER fell below minimum strength.")

// --- Volume Regime Alerts ---
f_dynamic_alert(enableVolumeAlerts, isVolExpandingAlert, "Volume regime entered EXPANDING state.")
f_dynamic_alert(enableVolumeAlerts, isVolContractingAlert, "Volume regime entered CONTRACTING state.")
f_dynamic_alert(enableVolumeAlerts, isVolFlatAlert, "Volume regime entered FLAT state.")

// --- Strategy Alerts ---
strategyChanged = strategyChangedAlert
f_dynamic_alert(enableStrategyAlerts, strategyChanged, "Recommended strategy changed to " + str.tostring(optimalStrategy) + ".")
````

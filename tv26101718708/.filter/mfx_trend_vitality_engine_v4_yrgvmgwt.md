# MFx Trend Vitality Engine V4

- url: https://www.tradingview.com/script/yrgVmGwt-MFx-Trend-Vitality-Engine-V4/
- type: indicator
- pine_id: PUB;a6bec79fa279420dbc80f39544ca89b3
- version: 1.0

## Description

Trend Vitality Engine V4

Trend Vitality Engine is a market-analysis indicator designed to describe the evolving condition of buyer and seller campaigns rather than generate entry, exit, top, bottom, or price-prediction signals.

The underlying concept is to treat an active directional move as a developing campaign. Instead of asking only whether price is moving up or down, TVE evaluates several characteristics of the buyer and seller sides and organizes them into an instrument-panel view of trend condition.

Core framework

TVE evaluates several related but distinct aspects of campaign health:

[b]Vitality[/b] represents the overall aliveness and condition of the active buyer or seller campaign.

[b]Structural Vitality[/b] represents the slower structural condition underlying that campaign.

[b]Live Vitality[/b] represents its more immediate condition.

[b]Power[/b] represents current applied directional pressure.

[b]Efficiency / Transmission[/b] represents how effectively campaign energy is being converted into directional progress.

[b]Durability [/b]represents recent structural resilience or accumulated wear.

[b]Reserve / Fuel[/b] is a composite measure of usable campaign capacity derived from Power, Efficiency and Durability.

[b]Dominance[/b] identifies which side currently holds greater control according to the TVE framework.

[b]State and Phase[/b] describe the current internal condition of the buyer-versus-seller contest.

[b]Lifecycle[/b] is a heuristic evidence-voting model that describes campaign evolution through stages such as expansion, maturity, distribution, fatigue, capitulation, repair, accumulation and emergence.

[b]Market Health[/b] is a composite summary of underlying TVE measurements. It should not be interpreted as an additional independent confirmation signal.

Timeframe cascade

TVE evaluates market condition in the context of a [b]higher-timeframe cascade[/b][i][/i]. The dashboard displays the chart timeframe and the corresponding higher-timeframe context so that the current campaign can be interpreted within a broader market structure.

This allows the indicator to be used as an instrument panel rather than reducing market condition to a single directional reading.

What changed in V4

V4 preserves the established TVE architecture while correcting the live Durability mechanism.

In the previous version, lifetime accumulated damage could continue building across campaign history until the usable Durability range became saturated. This could cause Durability to remain at or near its lower boundary and reduce its ability to represent current structural wear.

V4 retains lifetime accumulated damage as historical diagnostic information but uses rolling live damage for the active Durability calculation. This allows current structural wear to increase during deterioration and recover as damaging evidence leaves the active measurement window.

Repaired Durability is then passed through the existing Reserve calculation and existing downstream TVE systems. The Reserve equation itself was not redesigned for this release.

Because Durability is once again an active input, users should expect some Reserve, Market Health, Lifecycle and related downstream readings to differ from the previous version.

Lifecycle interpretation

Lifecycle stages describe campaign evolution and should not be interpreted as direct forecasts of immediate price direction.

In particular, stages such as Bear Repair, Bear Accumulation and Bear Emergence describe developments occurring within, or emerging from, a bearish campaign context. The word "Bear" identifies the campaign context and does not necessarily mean that the indicator is forecasting an immediate price decline.

Lifecycle Evidence Score represents the strength of evidence supporting the selected lifecycle classification. It is not a calibrated probability or statistical confidence level.

How to use TVE

TVE is intended to be read as a collection of related gauges rather than as a single signal.

A user can begin with Dominance and the higher-timeframe context to understand which side currently controls the campaign. Vitality and Power describe campaign condition and applied pressure. Efficiency describes conversion quality. Durability and Reserve provide information about structural wear and usable capacity. Lifecycle provides context about campaign evolution, while Market Health summarizes the broader condition represented by the underlying gauges.

Divergence, decay, structural events and warning conditions provide additional context when the internal condition of a campaign begins to differ from its surface behavior.

The Command Center summarizes these measurements in plain-language descriptions while the detailed dashboard exposes the underlying buyer and seller measurements.

Alerts

V4 includes alert conditions for Trend Vitality Critical, Trend Vitality Rapid Decay, Critical Vitality plus Structural Event, Late Cycle Divergence, and Silent Damage Accumulating.

These alerts identify TVE conditions. They are not automated trade recommendations.

Research and limitations

TVE was developed as an experimental framework for observing trend health and buyer-versus-seller campaign behavior across multiple timeframes.

V4 follows a validation process that included comparison of internal measurements across multiple instruments and timeframes and investigation of the Durability mechanism. The V4 Durability change addresses an identified mechanical behavior in the previous implementation.

This validation should not be interpreted as evidence that TVE predicts future returns. Individual TVE measurements can overlap because several gauges intentionally summarize related aspects of the same underlying campaign.

TVE does not claim to predict market tops or bottoms, forecast future prices, identify guaranteed reversals, or provide statistically guaranteed entries or exits.

It is intended as an analytical instrument panel that helps users observe the evolving health, pressure, efficiency, wear, reserve, lifecycle and control of buyer and seller campaigns.

Version continuity

V4 is the current version of the Trend Vitality Engine. V3 remains the legacy version so existing charts and previous observations can be preserved and compared without silently changing the historical implementation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © renderingnature1
//@version=6
indicator("MFx Trend Vitality Engine V4", shorttitle = "MFx TVE V4", overlay = false, max_bars_back = 1500)
 
// Trend Vitality Engine V4
//
// V4 preserves the established TVE architecture while correcting
// the Durability/Wear subsystem to represent recent structural damage.
//
// Core interpretation:
// • Vitality   = campaign aliveness / condition
// • Power      = current applied directional pressure
// • Efficiency = conversion quality
// • Durability = recent structural wear / resilience
// • Reserve    = composite usable campaign capacity
// • Lifecycle  = heuristic campaign-evolution evidence classification
// • Market Health = composite summary
//
// Lifecycle Evidence Scores are heuristic evidence scores,
// not calibrated probabilities.
//
// TVE is an observational trend-health framework.
// It does not predict market tops, bottoms, or future returns.
//══════════════════════════════════════════════════════════════════════════════
// 1. INPUTS
//══════════════════════════════════════════════════════════════════════════════
//──────────────────────────────────────
// 1.1 Presentation Inputs
// Dashboard remains in the TVE pane.
// Command Center appears over candles.
//──────────────────────────────────────
showTable = input.bool(true, "Show Vitality Dashboard", group = "Dashboard")
showDebug = input.bool(false, "Show Debug Rows", group = "Dashboard", tooltip = "Shows internal TVE research diagnostics. Not required for normal interpretation.")
showLegend = input.bool(false, "Show Vitality Legend", group = "Dashboard")
textSizeOpt = input.string("Small", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = "Dashboard")
tablePosOpt = input.string("Bottom Right", "Dashboard Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = "Dashboard")
showCommandBrief = input.bool(true, "Show Command Center", group = "Command Center", tooltip = "Displays a plain-English assessment of the active TVE campaign over the candle chart.")
commandTextSizeOpt = input.string("Small", "Center Text Size", options = ["Tiny", "Small", "Normal"], group = "Command Center")
commandSideOpt = input.string("Right", "Center Side", options = ["Left", "Right"], group = "Command Center")
commandBarsRight = input.int(2, "Horizontal Offset", minval = 0, maxval = 50, group = "Command Center", tooltip = "Moves the command center farther into the chart's future-candle space.")
commandLookback = input.int(100, "Vertical Lookback", minval = 20, maxval = 500, group = "Command Center", tooltip = "Sets the price range used to position the command center above recent candles.")
commandVerticalAtr = input.float(1.0, "Vertical ATR Offset", minval = 0.0, maxval = 10.0, step = 0.25, group = "Command Center")
commandBgColor = input.color(color.new(color.rgb(15, 23, 42), 8), "Center Background", group = "Command Center")
commandTextColor = input.color(color.white, "Center Text", group = "Command Center")
//──────────────────────────────────────
// 1.2 Higher Timeframe Inputs
//──────────────────────────────────────
htfMode = input.string("Auto Crypto", "HTF Pairing Mode", options = ["Manual", "Auto TradFi", "Auto Crypto"])
manualHTF = input.timeframe("3D", "Manual Wellness HTF")
//──────────────────────────────────────
// 1.3 WaveTrend Inputs
//──────────────────────────────────────
wtChannelLength = input.int(9,  "WT Channel Length", minval = 1)
wtAverageLength = input.int(12, "WT Average Length", minval = 1)
wtMALength      = input.int(3,  "WT MA Length",      minval = 1)
//──────────────────────────────────────
// 1.4 Hybrid Money Flow Inputs
//──────────────────────────────────────
cmfLength = input.int(20, "CMF Length", minval = 1)
mfiLength = input.int(14, "MFI Length", minval = 1)
//──────────────────────────────────────
// 1.5 Vitality Engine Inputs
//──────────────────────────────────────
waveMemory = input.int(4, "Completed Waves To Read", minval = 3, maxval = 4)
recoveryPerBar = input.float(0.75, "Trend Rejuvenation Per HTF Bar", minval = 0.0, maxval = 5.0, step = 0.25)
efficiencyDecayThreshold = input.float(0.92, "Efficiency Decay Threshold", minval=0.50, maxval=1.20, step=0.01)
trajectoryWindow = input.int(3, "Trajectory Wave Window", minval=2, maxval=6, tooltip="How many completed wave closes to use when computing Power, Efficiency, Durability, and Trend Fuel trajectory. 3 = default, 2 = faster, 5 = smoother.")
lifecycleConfirmBars = input.int(2, "Lifecycle Confirmation HTF Bars", minval=1, maxval=6, tooltip="How many HTF bars a new lifecycle stage must persist before the dashboard confirms it.")
//──────────────────────────────────────
// 1.6 Debug / Research Inputs (New)
//──────────────────────────────────────
showDebugPlots = input.bool(false, "Show Research Plots (Debug)", group="🔬 Research Tools")
showPriceProgress = input.bool(false, "Debug: Price Progress %", group="🔬 Research Tools")
showEnergySpent   = input.bool(false, "Debug: Energy Spent", group="🔬 Research Tools")
showAbsEfficiency = input.bool(true,  "Debug: Absolute Efficiency", group="🔬 Research Tools")
showEffRatio      = input.bool(false, "Debug: Efficiency Ratio", group="🔬 Research Tools")
showEffMA         = input.bool(false, "Debug: Efficiency MA (5 waves)", group="🔬 Research Tools")
effMALength       = input.int(5, "Efficiency MA Length", minval=3, maxval=12, group="🔬 Research Tools")
//──────────────────────────────────────
// KU#9 Rolling Efficiency Normalization
// Research only — does not alter production scoring
//──────────────────────────────────────
effNormWindow = input.int(8, "Efficiency Normalization Window", minval=3, maxval=20, group="KU#9 Research")
showEffV2Raw = input.bool(false, "Show Raw Efficiency V2", group="KU#9 Research")
showEffV2MA = input.bool(false, "Show Efficiency V2 Average", group="KU#9 Research")
showEffV2Norm = input.bool(false, "Show Rolling Normalized Efficiency V2", group="KU#9 Research")
showEffV2OldRatio = input.bool(false, "Show Old Adjacent-Wave Ratio", group="KU#9 Research")
showEffV2BaselineContext = input.bool(false, "Show V2 Baseline Context", group="KU#9 Research")
showEffV2PeakRetention = input.bool(false, "Show V2 Peak Retention", group="KU#9 Research")
//══════════════════════════════════════════════════════════════════════════════
// 2. CONSTANTS
//══════════════════════════════════════════════════════════════════════════════
// Structural score weights
WT_SCORE_WEIGHT       = 35.0
AREA_SCORE_WEIGHT     = 17.5
MF_SCORE_WEIGHT       = 15.0
// Vitality blend weights
STRUCTURAL_WEIGHT     = 0.40
LIVE_WEIGHT           = 0.60
// Wave score blend weights
WAVE_SCORE_WEIGHT     = 0.70
PENALTY_SCORE_WEIGHT  = 0.30
// Aging / damage parameters
AGING_LEAK            = 0.02
WAVE_DAMAGE_MULT      = 0.35
// Live vitality pre-bias values
PRE_WT                = 30.0
PRE_MF                = 20.0
//══════════════════════════════════════════════════════════════════════════════
// 3. UI SETTINGS
//══════════════════════════════════════════════════════════════════════════════
//──────────────────────────────────────
// 3.1 Text Size Resolvers
//──────────────────────────────────────
txtSize = textSizeOpt == "Tiny" ? size.tiny : textSizeOpt == "Small" ? size.small : size.normal
commandTxtSize = commandTextSizeOpt == "Tiny" ? size.tiny : commandTextSizeOpt == "Small" ? size.small : size.normal
//──────────────────────────────────────
// 3.2 Table Position Resolver
//──────────────────────────────────────
tablePos =
     tablePosOpt == "Top Left"      ? position.top_left      :
     tablePosOpt == "Top Center"    ? position.top_center    :
     tablePosOpt == "Top Right"     ? position.top_right     :
     tablePosOpt == "Middle Left"   ? position.middle_left   :
     tablePosOpt == "Middle Center" ? position.middle_center :
     tablePosOpt == "Middle Right"  ? position.middle_right  :
     tablePosOpt == "Bottom Left"   ? position.bottom_left   :
     tablePosOpt == "Bottom Center" ? position.bottom_center :
     position.bottom_right
//══════════════════════════════════════════════════════════════════════════════
// 4. TIMEFRAME HELPERS
//══════════════════════════════════════════════════════════════════════════════
f_cleanTF(tf) =>
    string result = tf
    if tf == "1"
        result := "1m"
    else if tf == "3"
        result := "3m"
    else if tf == "5"
        result := "5m"
    else if tf == "15"
        result := "15m"
    else if tf == "30"
        result := "30m"
    else if tf == "60"
        result := "1H"
    else if tf == "120"
        result := "2H"
    else if tf == "240"
        result := "4H"
    else if tf == "360"
        result := "6H"
    else if tf == "720"
        result := "12H"
    else if tf == "D" or tf == "1D"
        result := "1D"
    else if tf == "2D"
        result := "2D"
    else if tf == "3D"
        result := "3D"
    else if tf == "W" or tf == "1W"
        result := "1W"
    else if tf == "2W"
        result := "2W"
    else if tf == "M" or tf == "1M"
        result := "1M"
    else if tf == "3M"
        result := "3M"
    result
f_autoHTF(_mode) =>
    tf = timeframe.period
    string tradfiHTF = "D"
    string cryptoHTF = "D"
    if tf == "1"
        tradfiHTF := "5"
        cryptoHTF := "5"
    else if tf == "3"
        tradfiHTF := "15"
        cryptoHTF := "15"
    else if tf == "5"
        tradfiHTF := "15"
        cryptoHTF := "30"
    else if tf == "15"
        tradfiHTF := "60"
        cryptoHTF := "60"
    else if tf == "30"
        tradfiHTF := "120"
        cryptoHTF := "120"
    else if tf == "60"
        tradfiHTF := "240"
        cryptoHTF := "240"
    else if tf == "120"
        tradfiHTF := "D"
        cryptoHTF := "360"
    else if tf == "240"
        tradfiHTF := "D"
        cryptoHTF := "720"
    else if tf == "360"
        tradfiHTF := "2D"
        cryptoHTF := "2D"
    else if tf == "720"
        tradfiHTF := "D"
        cryptoHTF := "D"
    else if tf == "D" or tf == "1D"
        tradfiHTF := "3D"
        cryptoHTF := "3D"
    else if tf == "2D"
        tradfiHTF := "D"
        cryptoHTF := "W"
    else if tf == "3D"
        tradfiHTF := "W"
        cryptoHTF := "W"
    else if tf == "W" or tf == "1W"
        tradfiHTF := "2W"
        cryptoHTF := "2W"
    else if tf == "2W"
        tradfiHTF := "M"
        cryptoHTF := "M"
    else if tf == "M" or tf == "1M"
        tradfiHTF := "3M"
        cryptoHTF := "3M"
    string result = manualHTF
    if _mode == "Auto TradFi"
        result := tradfiHTF
    else if _mode == "Auto Crypto"
        result := cryptoHTF
    result
wellnessHTF = f_autoHTF(htfMode)
//══════════════════════════════════════════════════════════════════════════════
// 5. CORE HELPER FUNCTIONS
//══════════════════════════════════════════════════════════════════════════════
f_clamp100(x) =>
    math.max(0.0, math.min(100.0, x))
f_safeDiv(num, den, fallback) =>
    den != 0 and not na(den) ? num / den : fallback
f_normCentered(src, len) =>
    lo  = ta.lowest(src, len)
    hi  = ta.highest(src, len)
    rng = hi - lo
    rng != 0 ? ((src - lo) / rng) * 100 - 50 : 0.0
f_gauge(x) =>
    v = int(math.round(f_clamp100(x) / 10.0))
    str.repeat("█", v) + str.repeat("░", 10 - v)
f_vote(cond, weight) =>
    cond ? weight : 0.0
//══════════════════════════════════════════════════════════════════════════════
// 6. COLOR HELPERS
//══════════════════════════════════════════════════════════════════════════════
f_scoreColor(x) =>
    color result = color.new(color.red, 70)
    if x >= 75
        result := color.new(color.green, 65)
    else if x >= 55
        result := color.new(color.teal, 70)
    else if x >= 35
        result := color.new(color.orange, 70)
    result
f_trajectoryColor(t) =>
    color result = color.new(color.gray, 80)
    if t == "▲ Accel"
        result := color.new(color.green, 60)
    else if t == "▲ Rising"
        result := color.new(color.teal, 65)
    else if t == "— Stable"
        result := color.new(color.gray, 72)
    else if t == "▼ Falling"
        result := color.new(color.orange, 65)
    else if t == "▼ Rapid"
        result := color.new(color.red, 60)
    result
f_efficiencyBaseline(hist, window) =>
    int n = math.min(array.size(hist), window)
    float total = 0.0
    float result = na
    if n > 0
        for i = 0 to n - 1
            total += array.get(hist, i)
        result := total / n
    result
//══════════════════════════════════════════════════════════════════════════════
// 7. CORE CALCULATION ENGINES
//══════════════════════════════════════════════════════════════════════════════
f_wt() =>
    ap  = ta.sma(hlc3, wtChannelLength)
    esa = ta.ema(ap, wtAverageLength)
    d   = ta.ema(math.abs(ap - esa), wtAverageLength)
    ci  = f_safeDiv(ap - esa, 0.015 * d, 0.0)
    ta.ema(ci, wtMALength)
f_mf() =>
    mfv    = high != low ? (((close - low) - (high - close)) / (high - low)) : 0.0
    cmfNum = math.sum(mfv * volume, cmfLength)
    cmfDen = math.sum(volume, cmfLength)
    cmf    = f_safeDiv(cmfNum, cmfDen, 0.0)
    mfi    = ta.mfi(hlc3, mfiLength)
    (f_normCentered(cmf, 100) + f_normCentered(mfi, 100)) / 2.0
f_trajectory(hist, window) =>
    n = math.min(array.size(hist), window)
    string result = "No Data"
    if n >= 2
        half   = math.max(1, int(n / 2))
        sumNew = 0.0
        sumOld = 0.0
        for k = 0 to half - 1
            sumNew += array.get(hist, k)
        for k = half to n - 1
            sumOld += array.get(hist, k)
        avgNew = sumNew / half
        avgOld = sumOld / (n - half)
        delta  = avgNew - avgOld
        if delta >= 12
            result := "▲ Accel"
        else if delta >= 4
            result := "▲ Rising"
        else if delta >= -4
            result := "— Stable"
        else if delta >= -12
            result := "▼ Falling"
        else
            result := "▼ Rapid"
    result
f_isRising(t) =>
    t == "▲ Rising" or t == "▲ Accel"
f_isFalling(t) =>
    t == "▼ Falling" or t == "▼ Rapid"
//══════════════════════════════════════════════════════════════════════════════
// 8. VITALITY ENGINE
//══════════════════════════════════════════════════════════════════════════════
f_vitalityEngine() =>
    //──────────────────────────────────────
    // 8.1 Core Calculations
    //──────────────────────────────────────
    wt    = f_wt()
    mf    = f_mf()
    wtSig = ta.sma(wt, wtMALength)
    //──────────────────────────────────────
    // 8.2 Buyer Wave Memory
    // Completed positive wave history
    //──────────────────────────────────────
    var float pWT1 = na
    var float pWT2 = na
    var float pWT3 = na
    var float pWT4 = na
    var float pArea1 = na
    var float pArea2 = na
    var float pArea3 = na
    var float pArea4 = na
    var float pMF1 = na
    var float pMF2 = na
    var float pMF3 = na
    var float pMF4 = na
    // Legacy price captured at peak WT.
    var float pPrice1 = na
    var float pPrice2 = na
    var float pPrice3 = na
    var float pPrice4 = na
    // Efficiency V2 buyer-wave price boundaries.
    var float pStartPrice1 = na
    var float pStartPrice2 = na
    var float pStartPrice3 = na
    var float pStartPrice4 = na
    var float pPeakPrice1 = na
    var float pPeakPrice2 = na
    var float pPeakPrice3 = na
    var float pPeakPrice4 = na
    // Completed buyer-wave duration history.
    var int pBars1 = na
    var int pBars2 = na
    var int pBars3 = na
    var int pBars4 = na
    // Research event counter.
    var int buyerWaveSerial = 0
    //──────────────────────────────────────
    // 8.3 Seller Wave Memory
    // Completed negative wave history
    //──────────────────────────────────────
    var float nWT1 = na
    var float nWT2 = na
    var float nWT3 = na
    var float nWT4 = na
    var float nArea1 = na
    var float nArea2 = na
    var float nArea3 = na
    var float nArea4 = na
    var float nMF1 = na
    var float nMF2 = na
    var float nMF3 = na
    var float nMF4 = na
    var float nPrice1 = na
    var float nPrice2 = na
    var float nPrice3 = na
    var float nPrice4 = na
    // Completed seller-wave duration history.
    var int nBars1 = na
    var int nBars2 = na
    var int nBars3 = na
    var int nBars4 = na
    // Research event counter.
    var int sellerWaveSerial = 0
    //──────────────────────────────────────
    // 8.4 Active Wave Trackers
    // Tracks the current unfinished wave
    //──────────────────────────────────────
    var float posPeakWT = na
    var float posPeakMF = na
    var float posPrice = na
    var float posArea = 0.0
    var int posWaveBars = 0
    // Efficiency V2 active buyer-wave boundaries.
    var float posStartPrice = na
    var float posPeakPrice = na
    var float negPeakWT = na
    var float negPeakMF = na
    var float negPrice = na
    var float negArea = 0.0
    var int negWaveBars = 0
    //──────────────────────────────────────
    // 8.5 Persistent Aging / Diagnostic State
    //──────────────────────────────────────
    var float buyerPenaltyState = 0.0
    var float sellerPenaltyState = 0.0
    var float cumulativeBuyerDamage = 0.0
    var float cumulativeSellerDamage = 0.0

    // Phase 0I / frozen Phase 0C live-damage repair.
    // Lifetime cumulative damage above remains untouched for history/debug.
    var float[] liveBuyerDamageWindow = array.new_float()
    var float[] liveSellerDamageWindow = array.new_float()
    var float liveBuyerDamage = 0.0
    var float liveSellerDamage = 0.0
    var float liveBuyerDamageAdd = 0.0
    var float liveSellerDamageAdd = 0.0
    var float liveBuyerDamageRecovery = 0.0
    var float liveSellerDamageRecovery = 0.0
    var float prevBuyerEfficiency  = na
    var float prevSellerEfficiency = na
    // Efficiency V2 research memory.
    var float prevBuyerEfficiencyV2 = na
    var bool buyerEfficiencyDecayState = false
    var bool sellerEfficiencyDecayState = false
    var float buyerEfficiencyRatio  = na
    var float sellerEfficiencyRatio = na
    // Efficiency V2 research ratio.
    var float buyerEfficiencyRatioV2 = na
    //──────────────────────────────────────
    // 8.6 Active Vitality History
    //──────────────────────────────────────
    var float activeVitalityWave1 = na
    var float activeVitalityWave2 = na
    var float activeVitalityWave3 = na
    var float agingVelocity = na
    //──────────────────────────────────────
    // 8.7 Diagnostic History Arrays
    // Used by the trajectory engine
    //──────────────────────────────────────
    var float[] buyerEngineHist = array.new_float()
    var float[] buyerTransmissionHist = array.new_float()
    var float[] buyerWearHist = array.new_float()
    var float[] buyerReserveHist = array.new_float()
    var float[] sellerEngineHist = array.new_float()
    var float[] sellerTransmissionHist = array.new_float()
    var float[] sellerWearHist = array.new_float()
    var float[] sellerReserveHist = array.new_float()
    var float[] buyerEfficiencyHist = array.new_float()
    var float[] sellerEfficiencyHist = array.new_float()
//──────────────────────────────────────
// 8.7A KU#9 Efficiency V2 Context
// Research only — production remains unchanged
//──────────────────────────────────────
    var float[] buyerEfficiencyV2History = array.new_float()
    var float buyerEfficiencyV2RollingMin = na
    var float buyerEfficiencyV2RollingMax = na
    var float buyerEfficiencyV2RollingMean = na
    var float buyerEfficiencyV2PriorMean = na
    var float buyerEfficiencyV2PriorPeak = na
    var float buyerEfficiencyV2NormScore = na
    var float buyerEfficiencyV2OldScore = na
    var float buyerEfficiencyV2BaselineScore = na
    var float buyerEfficiencyV2PeakRetention = na
    float efficiencyV2Range = na
    //══════════════════════════════════════════════════════════════════════════
    // WAVE CAPTURE ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.8 Buyer Wave Capture
    // Captures completed positive WaveTrend cycles
    //──────────────────────────────────────
    if ta.crossover(wt, 0)
        posPeakWT := wt
        posPeakMF := mf
        posPrice := close
        posArea := 0.0
        posWaveBars := 0
        // Efficiency V2 wave boundaries.
        posStartPrice := close
        posPeakPrice := high
    if wt > 0
        posArea += wt
        posWaveBars += 1
        // Highest price achieved during the positive WT wave.
        if na(posPeakPrice) or high > posPeakPrice
            posPeakPrice := high
        // Preserve legacy peak-WT price capture.
        if na(posPeakWT) or wt > posPeakWT
            posPeakWT := wt
            posPeakMF := mf
            posPrice := close
    if ta.crossunder(wt, 0) and not na(posPeakWT)
        pWT4 := pWT3
        pWT3 := pWT2
        pWT2 := pWT1
        pWT1 := posPeakWT
        pArea4 := pArea3
        pArea3 := pArea2
        pArea2 := pArea1
        pArea1 := posArea
        pMF4 := pMF3
        pMF3 := pMF2
        pMF2 := pMF1
        pMF1 := posPeakMF
        pPrice4 := pPrice3
        pPrice3 := pPrice2
        pPrice2 := pPrice1
        pPrice1 := posPrice
        // Efficiency V2 completed-wave boundaries.
        pStartPrice4 := pStartPrice3
        pStartPrice3 := pStartPrice2
        pStartPrice2 := pStartPrice1
        pStartPrice1 := posStartPrice
        pPeakPrice4 := pPeakPrice3
        pPeakPrice3 := pPeakPrice2
        pPeakPrice2 := pPeakPrice1
        pPeakPrice1 := posPeakPrice
        pBars4 := pBars3
        pBars3 := pBars2
        pBars2 := pBars1
        pBars1 := posWaveBars
        buyerWaveSerial += 1
        posPeakWT := na
        posPeakMF := na
        posPrice := na
        posArea := 0.0
        posWaveBars := 0
        posStartPrice := na
        posPeakPrice := na
    //──────────────────────────────────────
    // 8.9 Seller Wave Capture
    // Captures completed negative WaveTrend cycles
    //──────────────────────────────────────
    if ta.crossunder(wt, 0)
        negPeakWT   := math.abs(wt)
        negPeakMF   := math.abs(mf)
        negPrice    := close
        negArea     := 0.0
        negWaveBars := 0
    if wt < 0
        negArea     += math.abs(wt)
        negWaveBars += 1
        if na(negPeakWT) or math.abs(wt) > negPeakWT
            negPeakWT := math.abs(wt)
            negPeakMF := math.abs(mf)
            negPrice  := close
    if ta.crossover(wt, 0) and not na(negPeakWT)
        nWT4 := nWT3
        nWT3 := nWT2
        nWT2 := nWT1
        nWT1 := negPeakWT
        nArea4 := nArea3
        nArea3 := nArea2
        nArea2 := nArea1
        nArea1 := negArea
        nMF4 := nMF3
        nMF3 := nMF2
        nMF2 := nMF1
        nMF1 := negPeakMF
        nPrice4 := nPrice3
        nPrice3 := nPrice2
        nPrice2 := nPrice1
        nPrice1 := negPrice
        nBars4 := nBars3
        nBars3 := nBars2
        nBars2 := nBars1
        nBars1 := negWaveBars
        sellerWaveSerial += 1
        negPeakWT   := na
        negPeakMF   := na
        negPrice    := na
        negArea     := 0.0
        negWaveBars := 0
    //══════════════════════════════════════════════════════════════════════════
    // STRUCTURAL AGING ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.10 Buyer Structural Aging Conditions
    //──────────────────────────────────────
    buyerHasData =
         not na(pWT3) and
         not na(pArea3) and
         not na(pMF3) and
         not na(pPrice3)
    buyerPriceHH   = buyerHasData and pPrice1 > pPrice3
    buyerWTDecay   = buyerHasData and pWT1 < pWT3
    buyerAreaDecay = buyerHasData and pArea1 < pArea3
    buyerMFDecay   = buyerHasData and pMF1 < pMF3
    buyerPriceProgressPct =
         buyerHasData ?
         ((pPrice1 - pPrice3) / math.max(pPrice3, 0.0001)) * 100.0 :
         na
    buyerEnergySpent =
         buyerHasData ?
         math.max(1.0, pArea1 + pArea2 + pArea3) :
         na
    buyerEfficiency =
         buyerHasData ?
         buyerPriceProgressPct / buyerEnergySpent :
         na
    //──────────────────────────────────────
    // 8.10A Buyer Efficiency V2 Research
    // Single-wave return divided by average
    // WT energy consumed per bar.
    //──────────────────────────────────────
    buyerWaveV2HasData =
         not na(pStartPrice1) and
         not na(pPeakPrice1) and
         not na(pArea1) and
         not na(pBars1) and
         pStartPrice1 > 0 and
         pPeakPrice1 > 0 and
         pBars1 > 0
    buyerWaveReturnV2 =
         buyerWaveV2HasData ?
         math.log(pPeakPrice1 / pStartPrice1) * 100.0 :
         na
    buyerAverageEnergyV2 =
         buyerWaveV2HasData ?
         pArea1 / math.max(float(pBars1), 1.0) :
         na
    buyerEfficiencyV2 =
         buyerWaveV2HasData and
         not na(buyerAverageEnergyV2) and
         buyerAverageEnergyV2 > 0 ?
         buyerWaveReturnV2 / buyerAverageEnergyV2 :
         na
    //──────────────────────────────────────
    // 8.11 Seller Structural Aging Conditions
    //──────────────────────────────────────
    sellerHasData =
         not na(nWT3) and
         not na(nArea3) and
         not na(nMF3) and
         not na(nPrice3)
    sellerPriceLL   = sellerHasData and nPrice1 < nPrice3
    sellerWTDecay   = sellerHasData and nWT1 < nWT3
    sellerAreaDecay = sellerHasData and nArea1 < nArea3
    sellerMFDecay   = sellerHasData and nMF1 < nMF3
    sellerPriceProgressPct =
         sellerHasData ?
         ((nPrice3 - nPrice1) / math.max(nPrice3, 0.0001)) * 100.0 :
         na
    sellerEnergySpent =
         sellerHasData ?
         math.max(1.0, nArea1 + nArea2 + nArea3) :
         na
    sellerEfficiency =
         sellerHasData ?
         sellerPriceProgressPct / sellerEnergySpent :
         na
    //──────────────────────────────────────
    // 8.12 Completed Wave Events
    //──────────────────────────────────────
    buyerWaveClosed  = ta.crossunder(wt, 0) and not na(pWT1)
    sellerWaveClosed = ta.crossover(wt, 0) and not na(nWT1)
    //══════════════════════════════════════════════════════════════════════════
    // EFFICIENCY ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.13 Efficiency Decay Detection
    //──────────────────────────────────────
    buyerEfficiencyDecay  = false
    sellerEfficiencyDecay = false
    buyerEfficiencyImpulse  = 0.0
    sellerEfficiencyImpulse = 0.0
    if buyerWaveClosed and buyerHasData and not na(buyerEfficiency) and not na(prevBuyerEfficiency)
        buyerEfficiencyRatio :=
             math.abs(buyerEfficiency) /
             math.max(math.abs(prevBuyerEfficiency), 0.0001)
        buyerEfficiencyDecay :=
             buyerEfficiencyRatio < efficiencyDecayThreshold
        buyerEfficiencyDecayState := buyerEfficiencyDecay
        if buyerEfficiencyDecay
            buyerEfficiencyImpulse :=
                 math.min(
                     12.0,
                     (efficiencyDecayThreshold - buyerEfficiencyRatio) /
                     efficiencyDecayThreshold *
                     12.0
                 )
    // Buyer Efficiency V2 research ratio.
    if buyerWaveClosed
        buyerEfficiencyRatioV2 := not na(buyerEfficiencyV2) and not na(prevBuyerEfficiencyV2) ? math.abs(buyerEfficiencyV2) / math.max(math.abs(prevBuyerEfficiencyV2), 0.0001) : na
    if sellerWaveClosed and sellerHasData and not na(sellerEfficiency) and not na(prevSellerEfficiency)
        sellerEfficiencyRatio := math.abs(sellerEfficiency) / math.max(math.abs(prevSellerEfficiency), 0.0001)
        sellerEfficiencyDecay := sellerEfficiencyRatio < efficiencyDecayThreshold
        sellerEfficiencyDecayState := sellerEfficiencyDecay
        if sellerEfficiencyDecay
            sellerEfficiencyImpulse := math.min(12.0,
                    (efficiencyDecayThreshold - sellerEfficiencyRatio) /
                    efficiencyDecayThreshold *
                    12.0
                )
//──────────────────────────────────────
// 8.14 Efficiency Memory Update
//──────────────────────────────────────
    if buyerWaveClosed and buyerHasData and not na(buyerEfficiency)
        prevBuyerEfficiency := buyerEfficiency
    if buyerWaveClosed and not na(buyerEfficiencyV2)
        prevBuyerEfficiencyV2 := buyerEfficiencyV2
    if sellerWaveClosed and sellerHasData and not na(sellerEfficiency)
        prevSellerEfficiency := sellerEfficiency
//──────────────────────────────────────
// 8.14A KU#9 Research Snapshot
// Captures raw values at completed wave close
//──────────────────────────────────────
    var float buyerResearchProgress = na
    var float buyerResearchEnergy = na
    var float buyerResearchEfficiency = na
    var float buyerResearchRatio = na
// Efficiency V2 research snapshot.
    var float buyerResearchReturnV2 = na
    var float buyerResearchAvgEnergyV2 = na
    var float buyerResearchEfficiencyV2 = na
    var float buyerResearchRatioV2 = na
    var float buyerResearchNormV2 = na
    var float buyerResearchMeanV2 = na
    var float buyerResearchMinV2 = na
    var float buyerResearchMaxV2 = na
    var float buyerResearchOldScoreV2 = na
    var float buyerResearchBaselineScoreV2 = na
    var float buyerResearchPeakRetentionV2 = na
    var float buyerResearchPriorMeanV2 = na
    var float buyerResearchPriorPeakV2 = na
    if buyerWaveClosed and buyerHasData
        buyerResearchProgress := buyerPriceProgressPct
        buyerResearchEnergy := buyerEnergySpent
        buyerResearchEfficiency := buyerEfficiency
        buyerResearchRatio := buyerEfficiencyRatio
        buyerResearchReturnV2 := buyerWaveReturnV2
        buyerResearchAvgEnergyV2 := buyerAverageEnergyV2
        buyerResearchEfficiencyV2 := buyerEfficiencyV2
        buyerResearchRatioV2 := buyerEfficiencyRatioV2
    // Preserve old adjacent-wave ratio score for comparison.
    buyerEfficiencyV2OldScore := not na(buyerEfficiencyRatioV2) ? math.max(0.0, math.min(100.0, buyerEfficiencyRatioV2 * 100.0)) : na
    // Contextualize the current wave against PRIOR completed waves.
    // Current wave is intentionally not added until after scoring.
    if not na(buyerEfficiencyV2)
        buyerEfficiencyV2PriorMean := array.size(buyerEfficiencyV2History) >= 3 ? array.avg(buyerEfficiencyV2History) : na
        buyerEfficiencyV2PriorPeak := array.size(buyerEfficiencyV2History) >= 3 ? array.max(buyerEfficiencyV2History) : na
        // Baseline Context:
        // 50 = equal to prior-wave mean
        // Above 50 = stronger than prior mean
        // Below 50 = weaker than prior mean
        buyerEfficiencyV2BaselineScore := not na(buyerEfficiencyV2PriorMean) and buyerEfficiencyV2PriorMean > 0 and buyerEfficiencyV2 > 0 ? f_clamp100 (50.0 + math.log (buyerEfficiencyV2 / buyerEfficiencyV2PriorMean) *25.0) : na
        // Peak Retention:
        // 100 = equal to or above prior campaign-window peak
        // 50 = retaining half of prior peak efficiency
        buyerEfficiencyV2PeakRetention := not na(buyerEfficiencyV2PriorPeak) and buyerEfficiencyV2PriorPeak > 0 ? f_clamp100(buyerEfficiencyV2 / buyerEfficiencyV2PriorPeak * 100.0) : na
        // Add current wave only after prior-context scoring.
        array.push(buyerEfficiencyV2History, buyerEfficiencyV2)
        if array.size(buyerEfficiencyV2History) > effNormWindow
            array.shift(buyerEfficiencyV2History)
        // Updated rolling statistics including current wave.
        buyerEfficiencyV2RollingMin := array.min(buyerEfficiencyV2History)
        buyerEfficiencyV2RollingMax := array.max(buyerEfficiencyV2History)
        buyerEfficiencyV2RollingMean := array.avg(buyerEfficiencyV2History)
        efficiencyV2Range := buyerEfficiencyV2RollingMax - buyerEfficiencyV2RollingMin
        buyerEfficiencyV2NormScore := array.size(buyerEfficiencyV2History) >= 3 and efficiencyV2Range > 0.0000001 ? math.max(0.0, math.min(100.0, (buyerEfficiencyV2 - buyerEfficiencyV2RollingMin) / efficiencyV2Range * 100.0)) : na
    buyerResearchNormV2 := buyerEfficiencyV2NormScore
    buyerResearchMeanV2 := buyerEfficiencyV2RollingMean
    buyerResearchMinV2 := buyerEfficiencyV2RollingMin
    buyerResearchMaxV2 := buyerEfficiencyV2RollingMax
    buyerResearchOldScoreV2 := buyerEfficiencyV2OldScore
    buyerResearchBaselineScoreV2 := buyerEfficiencyV2BaselineScore
    buyerResearchPeakRetentionV2 := buyerEfficiencyV2PeakRetention
    buyerResearchPriorMeanV2 := buyerEfficiencyV2PriorMean
    buyerResearchPriorPeakV2 := buyerEfficiencyV2PriorPeak
    //──────────────────────────────────────
    // 8.15 Aging Impulse Construction
    //──────────────────────────────────────
    buyerAgeImpulse = 0.0
    if buyerPriceHH and buyerWTDecay
        buyerAgeImpulse += 18
    if buyerAreaDecay
        buyerAgeImpulse += 14
    if buyerMFDecay
        buyerAgeImpulse += 12
    if buyerEfficiencyDecay
        buyerAgeImpulse += 6
    if buyerPriceHH and buyerWTDecay and buyerAreaDecay and buyerMFDecay
        buyerAgeImpulse += 16
    sellerAgeImpulse = 0.0
    if sellerPriceLL and sellerWTDecay
        sellerAgeImpulse += 18
    if sellerAreaDecay
        sellerAgeImpulse += 14
    if sellerMFDecay
        sellerAgeImpulse += 12
    if sellerEfficiencyDecay
        sellerAgeImpulse += 6
    if sellerPriceLL and sellerWTDecay and sellerAreaDecay and sellerMFDecay
        sellerAgeImpulse += 16
    //──────────────────────────────────────
    // 8.16 Penalty / Damage State Update
    //──────────────────────────────────────
    if buyerWaveClosed
        buyerPenaltyState     += buyerAgeImpulse * WAVE_DAMAGE_MULT
        cumulativeBuyerDamage += buyerAgeImpulse * WAVE_DAMAGE_MULT
    else
        buyerPenaltyState += buyerAgeImpulse * AGING_LEAK - recoveryPerBar
    buyerPenaltyState := f_clamp100(buyerPenaltyState)
    if sellerWaveClosed
        sellerPenaltyState     += sellerAgeImpulse * WAVE_DAMAGE_MULT
        cumulativeSellerDamage += sellerAgeImpulse * WAVE_DAMAGE_MULT
    else
        sellerPenaltyState += sellerAgeImpulse * AGING_LEAK - recoveryPerBar
    sellerPenaltyState := f_clamp100(sellerPenaltyState)

// Rolling Live-Damage Update
// Lifetime cumulative damage is retained for historical diagnostics.
// Live Durability uses recent rolling structural damage.
    liveBuyerDamageAdd := 0.0
    liveSellerDamageAdd := 0.0
    liveBuyerDamageRecovery := 0.0
    liveSellerDamageRecovery := 0.0

    if buyerWaveClosed or sellerWaveClosed
        float priorLiveBuyerDamage = liveBuyerDamage
        float priorLiveSellerDamage = liveSellerDamage

        liveBuyerDamageAdd := buyerWaveClosed ? buyerAgeImpulse * WAVE_DAMAGE_MULT : 0.0
        liveSellerDamageAdd := sellerWaveClosed ? sellerAgeImpulse * WAVE_DAMAGE_MULT : 0.0

        array.unshift(liveBuyerDamageWindow, liveBuyerDamageAdd)
        array.unshift(liveSellerDamageWindow, liveSellerDamageAdd)

        if array.size(liveBuyerDamageWindow) > waveMemory
            array.pop(liveBuyerDamageWindow)
        if array.size(liveSellerDamageWindow) > waveMemory
            array.pop(liveSellerDamageWindow)

        liveBuyerDamage := array.size(liveBuyerDamageWindow) > 0 ? array.sum(liveBuyerDamageWindow) : 0.0
        liveSellerDamage := array.size(liveSellerDamageWindow) > 0 ? array.sum(liveSellerDamageWindow) : 0.0

        liveBuyerDamageRecovery := math.max(priorLiveBuyerDamage + liveBuyerDamageAdd - liveBuyerDamage, 0.0)
        liveSellerDamageRecovery := math.max(priorLiveSellerDamage + liveSellerDamageAdd - liveSellerDamage, 0.0)

    //══════════════════════════════════════════════════════════════════════════
    // DIAGNOSTIC SCORING ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.17 Structural Vitality
    //──────────────────────────────────────
    buyerPenaltyVitality  = 100.0 - buyerPenaltyState
    sellerPenaltyVitality = 100.0 - sellerPenaltyState
    buyerWTScore =
         buyerHasData ?
         math.max(0.0, math.min(1.0, pWT1 / 80.0)) * WT_SCORE_WEIGHT :
         WT_SCORE_WEIGHT
    buyerAreaScore =
         buyerHasData ?
         math.max(0.0, math.min(2.0, pArea1 / math.max(pArea2, 1.0))) * AREA_SCORE_WEIGHT :
         AREA_SCORE_WEIGHT * 2.0
    buyerMFScore =
         buyerHasData ?
         math.max(0.0, math.min(2.0, pMF1 / math.max(pMF2, 1.0))) * MF_SCORE_WEIGHT :
         MF_SCORE_WEIGHT * 2.0
    buyerWaveScore =
         buyerHasData ?
         math.min(100.0, buyerWTScore + buyerAreaScore + buyerMFScore) :
         100.0
    sellerWTScore =
         sellerHasData ?
         math.max(0.0, math.min(1.0, nWT1 / 80.0)) * WT_SCORE_WEIGHT :
         WT_SCORE_WEIGHT
    sellerAreaScore =
         sellerHasData ?
         math.max(0.0, math.min(2.0, nArea1 / math.max(nArea2, 1.0))) * AREA_SCORE_WEIGHT :
         AREA_SCORE_WEIGHT * 2.0
    sellerMFScore =
         sellerHasData ?
         math.max(0.0, math.min(2.0, nMF1 / math.max(nMF2, 1.0))) * MF_SCORE_WEIGHT :
         MF_SCORE_WEIGHT * 2.0
    sellerWaveScore =
         sellerHasData ?
         math.min(100.0, sellerWTScore + sellerAreaScore + sellerMFScore) :
         100.0
    buyerStructuralVitality =
         f_clamp100(buyerWaveScore * WAVE_SCORE_WEIGHT + buyerPenaltyVitality * PENALTY_SCORE_WEIGHT)
    sellerStructuralVitality =
         f_clamp100(sellerWaveScore * WAVE_SCORE_WEIGHT + sellerPenaltyVitality * PENALTY_SCORE_WEIGHT)
    //──────────────────────────────────────
    // 8.18 Live Vitality
    //──────────────────────────────────────
    buyerWT     = math.max(0.0, wt + PRE_WT)
    buyerMF_val = math.max(0.0, mf + PRE_MF)
    sellerWT     = math.max(0.0, -wt + PRE_WT)
    sellerMF_val = math.max(0.0, -mf + PRE_MF)
    buyerWTNorm = math.min(1.0, buyerWT / (50.0 + PRE_WT))
    buyerMFNorm = math.min(1.0, buyerMF_val / (50.0 + PRE_MF))
    sellerWTNorm = math.min(1.0, sellerWT / (50.0 + PRE_WT))
    sellerMFNorm = math.min(1.0, sellerMF_val / (50.0 + PRE_MF))
    buyerLiveVitality  = 5 + buyerWTNorm * 45 + buyerMFNorm * 45
    sellerLiveVitality = 5 + sellerWTNorm * 45 + sellerMFNorm * 45
    buyerVitality =
         math.round(f_clamp100(buyerStructuralVitality * STRUCTURAL_WEIGHT + buyerLiveVitality * LIVE_WEIGHT))
    sellerVitality =
         math.round(f_clamp100(sellerStructuralVitality * STRUCTURAL_WEIGHT + sellerLiveVitality * LIVE_WEIGHT))
    //──────────────────────────────────────
    // 8.19 Diagnostic Model
    // Power / Efficiency / Durability / Trend Fuel
    //──────────────────────────────────────
    // ── POWER — current applied directional pressure ────────────────────
    // Power answers: how hard is that side pushing RIGHT NOW?
    // It is intentionally independent of Vitality (campaign health).
    // This produces the semantically useful split MadCat identified:
    //   Vitality 78 | Power 42 → healthy campaign, not pressing hard now
    //   Vitality 36 | Power 74 → weak campaign, but heavy pressure now
    //
    // Sources:
    //   55% — directional WT (wt > 0 → buyer pressure, wt < 0 → seller)
    //   30% — directional MF (money flow confirming the direction)
    //   15% — short-term WT acceleration (EMA3 vs EMA8 of raw directional WT)
    //
    // Acceleration component: clamp to 0–1 so it only adds, never subtracts.
    // We don't want a decelerating seller push to reduce buyer Power score.
    float rawWTBuyer  = math.max(0.0,  wt)
    float rawWTSeller = math.max(0.0, -wt)
    float wtAccelBuyerFast  = ta.ema(rawWTBuyer,  3)
    float wtAccelBuyerSlow  = ta.ema(rawWTBuyer,  8)
    float wtAccelSellerFast = ta.ema(rawWTSeller, 3)
    float wtAccelSellerSlow = ta.ema(rawWTSeller, 8)
    // Normalize acceleration: fast > slow means accelerating pressure
    // Divide by 20 to get a 0–1 range across typical WT magnitudes
    float accelBuyer  = f_clamp100((wtAccelBuyerFast  - wtAccelBuyerSlow)  / 20.0 * 100.0)
    float accelSeller = f_clamp100((wtAccelSellerFast - wtAccelSellerSlow) / 20.0 * 100.0)
    // Combine: WT pressure + MF pressure + acceleration
    // All inputs already 0–100 at this point
    float buyerEngineScore =
         f_clamp100(buyerWTNorm  * 100.0 * 0.55 +
                    buyerMFNorm  * 100.0 * 0.30 +
                    accelBuyer          * 0.15)
    float sellerEngineScore =
         f_clamp100(sellerWTNorm * 100.0 * 0.55 +
                    sellerMFNorm * 100.0 * 0.30 +
                    accelSeller         * 0.15)
//──────────────────────────────────────
// Context-Normalized Transmission Score
//──────────────────────────────────────
    buyerEfficiencyBaseline =
         f_efficiencyBaseline(buyerEfficiencyHist, waveMemory)
    sellerEfficiencyBaseline =
         f_efficiencyBaseline(sellerEfficiencyHist, waveMemory)
    var float buyerTransmissionScore = 50.0
    var float sellerTransmissionScore = 50.0
    float buyerBaselineRatio = na
    float buyerLevelScore = 50.0
    float buyerMomentumScore = 50.0
    float sellerBaselineRatio = na
    float sellerLevelScore = 50.0
    float sellerMomentumScore = 50.0
    if buyerWaveClosed and not na(buyerEfficiency)
        if not na(buyerEfficiencyBaseline) and buyerEfficiencyBaseline > 0
            buyerBaselineRatio := math.abs(buyerEfficiency) / buyerEfficiencyBaseline
        if not na(buyerBaselineRatio)
            buyerLevelScore := f_clamp100(
                 50.0 +
                 (buyerBaselineRatio - 1.0) * 75.0
            )
        if not na(buyerEfficiencyRatio)
            buyerMomentumScore := f_clamp100(
                 50.0 +
                 (buyerEfficiencyRatio - 1.0) * 100.0
            )
        buyerTransmissionScore := f_clamp100(
             buyerLevelScore * 0.70 +
             buyerMomentumScore * 0.30
        )
    if sellerWaveClosed and not na(sellerEfficiency)
        if not na(sellerEfficiencyBaseline) and sellerEfficiencyBaseline > 0
            sellerBaselineRatio := math.abs(sellerEfficiency) / sellerEfficiencyBaseline
        if not na(sellerBaselineRatio)
            sellerLevelScore := f_clamp100(
                 50.0 +
                 (sellerBaselineRatio - 1.0) * 75.0
            )
        if not na(sellerEfficiencyRatio)
            sellerMomentumScore := f_clamp100(
                 50.0 +
                 (sellerEfficiencyRatio - 1.0) * 100.0
            )
        sellerTransmissionScore := f_clamp100(
             sellerLevelScore * 0.70 +
             sellerMomentumScore * 0.30
        )
    buyerWearScore =
         f_clamp100(
             100.0 -
             buyerPenaltyState -
             liveBuyerDamage
         )
    sellerWearScore =
         f_clamp100(
             100.0 -
             sellerPenaltyState -
             liveSellerDamage
         )
    buyerReserve =
         math.round(
             buyerEngineScore *
             buyerTransmissionScore *
             (50.0 + buyerWearScore / 2.0) /
             10000.0
         )
    sellerReserve =
         math.round(
             sellerEngineScore *
             sellerTransmissionScore *
             (50.0 + sellerWearScore / 2.0) /
             10000.0
         )
    //══════════════════════════════════════════════════════════════════════════
    // WAVE HISTORY ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.20 Buyer Diagnostic History
    //──────────────────────────────────────
    if buyerWaveClosed
        array.unshift(buyerEngineHist, buyerEngineScore)
        if array.size(buyerEngineHist) > 8
            array.pop(buyerEngineHist)
        array.unshift(buyerTransmissionHist, buyerTransmissionScore)
        if array.size(buyerTransmissionHist) > 8
            array.pop(buyerTransmissionHist)
        array.unshift(buyerWearHist, buyerWearScore)
        if array.size(buyerWearHist) > 8
            array.pop(buyerWearHist)
        array.unshift(buyerReserveHist, float(buyerReserve))
        if array.size(buyerReserveHist) > 8
            array.pop(buyerReserveHist)
    //──────────────────────────────────────
    // 8.21 Seller Diagnostic History
    //──────────────────────────────────────
    if sellerWaveClosed
        array.unshift(sellerEngineHist, sellerEngineScore)
        if array.size(sellerEngineHist) > 8
            array.pop(sellerEngineHist)
        array.unshift(sellerTransmissionHist, sellerTransmissionScore)
        if array.size(sellerTransmissionHist) > 8
            array.pop(sellerTransmissionHist)
        array.unshift(sellerWearHist, sellerWearScore)
        if array.size(sellerWearHist) > 8
            array.pop(sellerWearHist)
        array.unshift(sellerReserveHist, float(sellerReserve))
        if array.size(sellerReserveHist) > 8
            array.pop(sellerReserveHist)
    //══════════════════════════════════════════════════════════════════════════
    // TRAJECTORY ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.22 Buyer Trajectories
    //──────────────────────────────────────
    buyerEngineTrajectory =
         f_trajectory(buyerEngineHist, trajectoryWindow)
    buyerTransmissionTrajectory =
         f_trajectory(buyerTransmissionHist, trajectoryWindow)
    buyerWearTrajectory =
         f_trajectory(buyerWearHist, trajectoryWindow)
    buyerReserveTrajectory =
         f_trajectory(buyerReserveHist, trajectoryWindow)
    //──────────────────────────────────────
    // 8.23 Seller Trajectories
    //──────────────────────────────────────
    sellerEngineTrajectory =
         f_trajectory(sellerEngineHist, trajectoryWindow)
    sellerTransmissionTrajectory =
         f_trajectory(sellerTransmissionHist, trajectoryWindow)
    sellerWearTrajectory =
         f_trajectory(sellerWearHist, trajectoryWindow)
    sellerReserveTrajectory =
         f_trajectory(sellerReserveHist, trajectoryWindow)
    //══════════════════════════════════════════════════════════════════════════
    // DIVERGENCE ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.24 Buyer Divergence States
    //──────────────────────────────────────
    buyerLateCycleDivergence =
         f_isRising(buyerEngineTrajectory) and
         f_isFalling(buyerTransmissionTrajectory)
    buyerMatureGrind =
         f_isFalling(buyerEngineTrajectory) and
         f_isRising(buyerTransmissionTrajectory)
    buyerSilentDamage =
         f_isFalling(buyerWearTrajectory) and
         not f_isFalling(buyerReserveTrajectory)
    //──────────────────────────────────────
    // 8.25 Seller Divergence States
    //──────────────────────────────────────
    sellerLateCycleDivergence =
         f_isRising(sellerEngineTrajectory) and
         f_isFalling(sellerTransmissionTrajectory)
    sellerMatureGrind =
         f_isFalling(sellerEngineTrajectory) and
         f_isRising(sellerTransmissionTrajectory)
    sellerSilentDamage =
         f_isFalling(sellerWearTrajectory) and
         not f_isFalling(sellerReserveTrajectory)
    //══════════════════════════════════════════════════════════════════════════
    // MARKET CLASSIFICATION ENGINE
    //══════════════════════════════════════════════════════════════════════════
    //──────────────────────────────────────
    // 8.26 Trend Bias
    //──────────────────────────────────────
    trendUp   = close > ta.sma(close, 50)
    trendDown = close < ta.sma(close, 50)
    buyerDecayCount =
         (buyerWTDecay ? 1 : 0) +
         (buyerAreaDecay ? 1 : 0) +
         (buyerMFDecay ? 1 : 0)
    sellerDecayCount =
         (sellerWTDecay ? 1 : 0) +
         (sellerAreaDecay ? 1 : 0) +
         (sellerMFDecay ? 1 : 0)
    //──────────────────────────────────────
    // 8.27 Dominance
    //──────────────────────────────────────
    dominant =
         trendUp and buyerVitality >= sellerVitality ? "Buyers" :
         trendDown and sellerVitality >= buyerVitality ? "Sellers" :
         buyerVitality > sellerVitality ? "Buyers" :
         sellerVitality > buyerVitality ? "Sellers" :
         "Mixed"
    //──────────────────────────────────────
    // 8.28 Active Divergence
    //──────────────────────────────────────
    activeDivergence =
         dominant == "Buyers" and buyerLateCycleDivergence ? "Late Cycle" :
         dominant == "Buyers" and buyerMatureGrind        ? "Mature Grind" :
         dominant == "Buyers" and buyerSilentDamage       ? "Silent Damage" :
         dominant == "Sellers" and sellerLateCycleDivergence ? "Late Cycle" :
         dominant == "Sellers" and sellerMatureGrind         ? "Mature Grind" :
         dominant == "Sellers" and sellerSilentDamage        ? "Silent Damage" :
         "Aligned"
    divergenceCode =
         activeDivergence == "Late Cycle"    ? 3 :
         activeDivergence == "Silent Damage" ? 2 :
         activeDivergence == "Mature Grind"  ? 1 :
         0
    //──────────────────────────────────────
    // 8.29 Active Vitality
    //──────────────────────────────────────
    activeVitality = dominant == "Buyers" ? buyerVitality : dominant == "Sellers" ? sellerVitality : math.round((buyerVitality + sellerVitality) / 2)
    dominantWaveClosed = dominant == "Buyers" ? buyerWaveClosed : dominant == "Sellers" ? sellerWaveClosed : buyerWaveClosed or sellerWaveClosed
    if dominantWaveClosed
        agingVelocity := not na(activeVitalityWave1) ? activeVitality - activeVitalityWave1 : na
        activeVitalityWave3 := activeVitalityWave2
        activeVitalityWave2 := activeVitalityWave1
        activeVitalityWave1 := activeVitality
    //──────────────────────────────────────
    // 8.30 Compression / Exhaustion Conditions
    //──────────────────────────────────────
    vitalitySpread = math.abs(buyerVitality - sellerVitality)
    compressionRegime =
         buyerVitality < 45 and
         sellerVitality < 45 and
         vitalitySpread < 15
    buyerExhaustion =
         dominant == "Buyers" and
         buyerVitality < 45 and
         sellerVitality < 55 and
         buyerDecayCount >= 2
    sellerExhaustion =
         dominant == "Sellers" and
         sellerVitality < 45 and
         buyerVitality < 55 and
         sellerDecayCount >= 2
    //──────────────────────────────────────
    // 8.31 State / Phase Classification
    //──────────────────────────────────────
    state =
         activeVitality >= 80 ? "Peak" :
         activeVitality >= 60 ? "Strong" :
         activeVitality >= 40 ? "Stable" :
         activeVitality >= 20 ? "Weakening" :
         "Failing"
    phase =
         compressionRegime ? "Compression" :
         buyerExhaustion   ? "Buyer Exhaustion" :
         sellerExhaustion  ? "Seller Exhaustion" :
         activeVitality >= 80 ? "Emergence" :
         activeVitality >= 60 ? "Expansion" :
         activeVitality >= 40 ? "Dominance" :
         activeVitality >= 20 ? "Deterioration" :
         "Transition"
    //──────────────────────────────────────
    // 8.32 Structural Event Detection
    //──────────────────────────────────────
    bloodDiamond =
         ta.crossunder(wt, wtSig) and
         wt > 0 and
         buyerVitality <= 40
    greenRecovery =
         ta.crossover(wt, wtSig) and
         wt < 0 and
         sellerVitality <= 40
    structure =
         bloodDiamond  ? "Blood Diamond" :
         greenRecovery ? "Green Recovery" :
         "None"
    rapidDecay =
         activeVitality <= 40 and
         activeVitality < activeVitality[1] - 20
    criticalEvent =
         activeVitality <= 19 and
         structure != "None"
    //══════════════════════════════════════════════════════════════════════════
    // 8.33 Engine Return Tuple
    //══════════════════════════════════════════════════════════════════════════
    [wt, mf, buyerVitality, sellerVitality, activeVitality, buyerDecayCount, sellerDecayCount, dominant, state, phase, structure, rapidDecay, criticalEvent, pWT1, pWT2, pWT3, nWT1, nWT2, nWT3, buyerPenaltyState, sellerPenaltyState, buyerAgeImpulse, sellerAgeImpulse, buyerStructuralVitality, sellerStructuralVitality, buyerLiveVitality, sellerLiveVitality, buyerEfficiencyDecayState, sellerEfficiencyDecayState, buyerEfficiencyRatio, sellerEfficiencyRatio, agingVelocity, cumulativeBuyerDamage, cumulativeSellerDamage, buyerEngineScore, buyerTransmissionScore, buyerWearScore, buyerReserve, sellerEngineScore, sellerTransmissionScore, sellerWearScore, sellerReserve, buyerEngineTrajectory, buyerTransmissionTrajectory, buyerWearTrajectory, buyerReserveTrajectory, sellerEngineTrajectory, sellerTransmissionTrajectory, sellerWearTrajectory, sellerReserveTrajectory, activeDivergence, divergenceCode, buyerLateCycleDivergence, sellerLateCycleDivergence, buyerMatureGrind, sellerMatureGrind, buyerSilentDamage, sellerSilentDamage, buyerPriceProgressPct, buyerEnergySpent, buyerEfficiency, buyerEfficiencyRatio, buyerResearchProgress, buyerResearchEnergy, buyerResearchEfficiency, buyerResearchRatio, buyerResearchReturnV2, buyerResearchAvgEnergyV2, buyerResearchEfficiencyV2, buyerResearchRatioV2, buyerResearchNormV2, buyerResearchMeanV2, buyerResearchMinV2, buyerResearchMaxV2, buyerResearchOldScoreV2, buyerResearchBaselineScoreV2, buyerResearchPeakRetentionV2, buyerResearchPriorMeanV2, buyerResearchPriorPeakV2, pBars1, buyerWaveSerial]
//══════════════════════════════════════════════════════════════════════════════
// 9. HIGHER TIMEFRAME ENGINE
//══════════════════════════════════════════════════════════════════════════════
[htfWT, htfMF, buyerVitality, sellerVitality, activeVitality, buyerDecayCount, sellerDecayCount, dominant, state, phase, structure, rapidDecay, criticalEvent, pWT1, pWT2, pWT3, nWT1, nWT2, nWT3, buyerPenaltyStateDbg, sellerPenaltyStateDbg, buyerAgeImpulseDbg, sellerAgeImpulseDbg, buyerStructuralDbg, sellerStructuralDbg, buyerLiveDbg, sellerLiveDbg, buyerEfficiencyDecayDbg, sellerEfficiencyDecayDbg, buyerEfficiencyRatioDbg, sellerEfficiencyRatioDbg, agingVelocityDbg, buyerCumDamageDbg, sellerCumDamageDbg, buyerEngineScore, buyerTransmissionScore, buyerWearScore, buyerReserve, sellerEngineScore, sellerTransmissionScore, sellerWearScore, sellerReserve, buyerEngTraj, buyerTrnTraj, buyerWearTraj, buyerResTraj, sellerEngTraj, sellerTrnTraj, sellerWearTraj, sellerResTraj, activeDivergence, divergenceCode, buyerLateCycleDivergence, sellerLateCycleDivergence, buyerMatureGrind, sellerMatureGrind, buyerSilentDamage, sellerSilentDamage, buyerPriceProgressPctDbg, buyerEnergySpentDbg, buyerEfficiencyDbg, buyerEfficiencyRatioResearchDbg, buyerResearchProgressDbg, buyerResearchEnergyDbg, buyerResearchEfficiencyDbg, buyerResearchRatioDbg, buyerResearchReturnV2Dbg, buyerResearchAvgEnergyV2Dbg, buyerResearchEfficiencyV2Dbg, buyerResearchRatioV2Dbg, buyerResearchNormV2Dbg, buyerResearchMeanV2Dbg, buyerResearchMinV2Dbg, buyerResearchMaxV2Dbg, buyerResearchOldScoreV2Dbg, buyerResearchBaselineScoreV2Dbg, buyerResearchPeakRetentionV2Dbg, buyerResearchPriorMeanV2Dbg, buyerResearchPriorPeakV2Dbg, buyerWaveBarsDbg, buyerWaveSerialDbg] = request.security(
    syminfo.tickerid,
    wellnessHTF,
    f_vitalityEngine(),
    gaps = barmerge.gaps_off,
    lookahead = barmerge.lookahead_off
)
 //──────────────────────────────────────
// 10.7 Live vs Structural Pressure
//──────────────────────────────────────
buyerLiveStructGap  = buyerLiveDbg - buyerStructuralDbg
sellerLiveStructGap = sellerLiveDbg - sellerStructuralDbg
activeLiveStructGap =
     dominant == "Buyers"  ? buyerLiveStructGap :
     dominant == "Sellers" ? sellerLiveStructGap :
     0.0
structurePressure =
     activeLiveStructGap >= 25  ? "Overextended" :
     activeLiveStructGap >= 15  ? "Stretched" :
     activeLiveStructGap <= -15 ? "Dormant" :
     "Aligned"
structurePressureBg =
     activeLiveStructGap >= 25  ? color.new(color.red, 65) :
     activeLiveStructGap >= 15  ? color.new(color.orange, 70) :
     activeLiveStructGap <= -15 ? color.new(color.gray, 75) :
     color.new(color.green, 80)
//──────────────────────────────────────
// 10.8 Exhaustion Warning Logic
//──────────────────────────────────────
buyerWarning =
     dominant == "Buyers" and
     buyerVitality < 60 and
     buyerDecayCount >= 2 and
     buyerPenaltyStateDbg >= 50 and
     (
         buyerLiveDbg < 40 or
         buyerEfficiencyDecayDbg or
         buyerLiveStructGap >= 20
     )
sellerWarning =
     dominant == "Sellers" and
     sellerVitality < 60 and
     sellerDecayCount >= 2 and
     sellerPenaltyStateDbg >= 50 and
     (
         sellerLiveDbg < 40 or
         sellerEfficiencyDecayDbg or
         sellerLiveStructGap >= 20
     )
warningBias =
     buyerWarning  ? "Buyer Exhaustion" :
     sellerWarning ? "Seller Exhaustion" :
     "Neutral"
warningBg =
     warningBias != "Neutral" ? color.new(color.red, 65) :
     color.new(color.gray, 80)
//──────────────────────────────────────
// 10.9 Aging Velocity Status
//──────────────────────────────────────
agingVelocityText =
     na(agingVelocityDbg) ? "No Data" :
     agingVelocityDbg <= -15 ? "Rapid Decay" :
     agingVelocityDbg <= -8  ? "Decaying" :
     agingVelocityDbg >= -3 and agingVelocityDbg <= 3 ? "Stable" :
     agingVelocityDbg >= 8 ? "Recovering Fast" :
     agingVelocityDbg > 3  ? "Recovering" :
     "Neutral"
agingVelocityBg =
     na(agingVelocityDbg) ? color.new(color.gray, 80) :
     agingVelocityDbg <= -15 ? color.new(color.red, 55) :
     agingVelocityDbg <= -8  ? color.new(color.red, 70) :
     agingVelocityDbg >= -3 and agingVelocityDbg <= 3 ? color.new(color.gray, 75) :
     agingVelocityDbg >= 8 ? color.new(color.green, 65) :
     agingVelocityDbg > 3  ? color.new(color.teal, 75) :
     color.new(color.gray, 80)
//──────────────────────────────────────
// 10.10 Structural Depth
//──────────────────────────────────────
buyerStructuralDepth  = math.min(100.0, buyerPenaltyStateDbg)
sellerStructuralDepth = math.min(100.0, sellerPenaltyStateDbg)
buyerStructuralDepthText =
     buyerStructuralDepth >= 90 ? "Extreme Damage" :
     buyerStructuralDepth >= 75 ? "Deep Damage" :
     buyerStructuralDepth >= 60 ? "Moderate Damage" :
     buyerStructuralDepth >= 40 ? "Light Damage" :
     "Stable"
sellerStructuralDepthText =
     sellerStructuralDepth >= 90 ? "Extreme Damage" :
     sellerStructuralDepth >= 75 ? "Deep Damage" :
     sellerStructuralDepth >= 60 ? "Moderate Damage" :
     sellerStructuralDepth >= 40 ? "Light Damage" :
     "Stable"
//──────────────────────────────────────
// 10.10a Composite Market Health
//──────────────────────────────────────
activeTransmissionScore =
     dominant == "Buyers" ? buyerTransmissionScore :
     dominant == "Sellers" ? sellerTransmissionScore :
     math.round((buyerTransmissionScore + sellerTransmissionScore) / 2)
activeReserveScore =
     dominant == "Buyers" ? buyerReserve :
     dominant == "Sellers" ? sellerReserve :
     math.round((buyerReserve + sellerReserve) / 2)
activeDurabilityScore =
     dominant == "Buyers" ? buyerWearScore :
     dominant == "Sellers" ? sellerWearScore :
     math.round((buyerWearScore + sellerWearScore) / 2)
divergenceHealth =
     math.abs(divergenceCode) >= 3 ? 25.0 :
     math.abs(divergenceCode) == 2 ? 45.0 :
     math.abs(divergenceCode) == 1 ? 65.0 :
     100.0
baseHealth =
     activeVitality * 0.35 +
     activeTransmissionScore * 0.20 +
     activeReserveScore * 0.25 +
     activeDurabilityScore * 0.15 +
     divergenceHealth * 0.05
criticalSubsystem =
     math.min(
         activeReserveScore,
         activeTransmissionScore,
         activeDurabilityScore
     )
//══════════════════════════════════════════════════════════════════════════════
// 10. DASHBOARD HELPERS
//══════════════════════════════════════════════════════════════════════════════
//──────────────────────────────────────
// 10.1 Dashboard Color Helpers
//──────────────────────────────────────
f_stateBg(score) =>
    color result = color.new(color.maroon, 55)
    if score >= 80
        result := color.new(color.green, 65)
    else if score >= 60
        result := color.new(color.teal, 70)
    else if score >= 40
        result := color.new(color.orange, 72)
    else if score >= 20
        result := color.new(color.red, 72)
    result
f_divergenceBg(code) =>
    color result = color.new(color.gray, 80)
    if code == 3
        result := color.new(color.red, 60)
    else if code == 2
        result := color.new(color.orange, 65)
    else if code == 1
        result := color.new(color.teal, 70)
    result
f_lifecycleBg(stage) =>
    color result = color.new(color.gray, 80)
    if stage == "Bull Expansion"
        result := color.new(color.green, 65)
    else if stage == "Bull Maturity"
        result := color.new(color.teal, 70)
    else if stage == "Bull Distribution"
        result := color.new(color.orange, 68)
    else if stage == "Bull Fatigue"
        result := color.new(color.red, 65)
    else if stage == "Bear Capitulation"
        result := color.new(color.red, 60)
    else if stage == "Bear Repair"
        result := color.new(color.orange, 70)
    else if stage == "Bear Accumulation"
        result := color.new(color.yellow, 75)
    else if stage == "Bear Emergence"
        result := color.new(color.green, 70)
    result
//──────────────────────────────────────
// 10.2 Dashboard Table Instance
//──────────────────────────────────────
var table t = table.new(tablePos, 6, 30, border_width = 1)
var bool dashboardCellsMerged = false
//──────────────────────────────────────
// 10.3 Dashboard Row Helpers
//──────────────────────────────────────
f_row(col, row, left, right, bg) =>
    table.cell(t, col, row, left, text_color = color.white, bgcolor = color.new(color.black, 0), text_size = txtSize)
    table.cell(t, col + 1, row, right, text_color = color.white, bgcolor = bg, text_size = txtSize)
f_section(row, title, bg) =>
    table.cell(t, 0, row, title, text_color = color.white, bgcolor = bg, text_size = txtSize, text_halign = text.align_left)
// Section header for rows that compare buyers against sellers.
// The merged side bands orient the eye before the user reads any values.
f_sectionSides(row, title, bg) =>
    table.cell(t, 0, row, title, text_color = color.white, bgcolor = bg, text_size = txtSize, text_halign = text.align_left)
    table.cell(t, 2, row, "▲ BUYERS", text_color = color.white, bgcolor = color.new(color.green, 58), text_size = txtSize, text_halign = text.align_center)
    table.cell(t, 4, row, "▼ SELLERS", text_color = color.white, bgcolor = color.new(color.red, 58), text_size = txtSize, text_halign = text.align_center)
//──────────────────────────────────────
// 10.4 Main Dashboard Backgrounds
//──────────────────────────────────────
mainBg = f_stateBg(activeVitality)
divergenceBg = f_divergenceBg(divergenceCode)
//──────────────────────────────────────
// 10.5 Regime Classification
//──────────────────────────────────────
regime =
     phase == "Compression"        ? "Compression" :
     phase == "Buyer Exhaustion"   ? "Exhaustion" :
     phase == "Seller Exhaustion"  ? "Exhaustion" :
     buyerVitality > 80 and sellerVitality < 20 ? "Bull Expansion" :
     sellerVitality > 80 and buyerVitality < 20 ? "Bear Expansion" :
     activeVitality >= 60 ? "Trend" :
     activeVitality >= 40 ? "Transition" :
     "Exhaustion"
regimeBg =
     regime == "Bull Expansion" ? color.new(color.green, 70) :
     regime == "Bear Expansion" ? color.new(color.red, 70) :
     regime == "Trend"          ? color.new(color.teal, 75) :
     regime == "Transition"     ? color.new(color.orange, 75) :
     regime == "Compression"    ? color.new(color.yellow, 75) :
     color.new(color.maroon, 70)
//──────────────────────────────────────
// 10.6 Signal Quality / Efficiency
//──────────────────────────────────────
signalQuality = math.round(math.min(100.0, math.max(buyerStructuralDbg, sellerStructuralDbg) * 0.6 + math.max(buyerLiveDbg, sellerLiveDbg) * 0.4))
activeEfficiencyDecay = dominant == "Buyers" ? buyerEfficiencyDecayDbg : dominant == "Sellers" ? sellerEfficiencyDecayDbg : false
activeEfficiencyRatio = dominant == "Buyers" ? buyerEfficiencyRatioDbg : dominant == "Sellers" ? sellerEfficiencyRatioDbg : na
efficiencyText = na(activeEfficiencyRatio) ? "No Data" : activeEfficiencyDecay ? "Weakening" : "Stable"
efficiencyBg = na(activeEfficiencyRatio) ? color.new(color.gray, 80) : activeEfficiencyDecay ? color.new(color.red, 65) : color.new(color.green, 80)
//──────────────────────────────────────
// 10.7 Market Health
//──────────────────────────────────────
bottleneckPenalty = criticalSubsystem < 40 ? (40 - criticalSubsystem) * 0.40 : 0.0
marketHealth = math.round(math.max(0, math.min(100, baseHealth - bottleneckPenalty)))
//──────────────────────────────────────
// 10.10b Diagnostic Reason Engine
//──────────────────────────────────────
fuelPenalty =
     activeReserveScore < 40 ?
     40 - activeReserveScore :
     0.0
efficiencyPenalty =
     activeTransmissionScore < 40 ?
     40 - activeTransmissionScore :
     0.0
durabilityPenalty =
     activeDurabilityScore < 40 ?
     40 - activeDurabilityScore :
     0.0
vitalityPenalty =
     activeVitality < 45 ?
     45 - activeVitality :
     0.0
divergencePenalty =
     divergenceCode != 0 ?
     math.abs(divergenceCode) * 10.0 :
     0.0
primaryLimiter =
     fuelPenalty >= efficiencyPenalty and fuelPenalty >= durabilityPenalty and fuelPenalty >= vitalityPenalty and fuelPenalty >= divergencePenalty and fuelPenalty > 0 ? "Fuel Starvation" :
     efficiencyPenalty >= fuelPenalty and efficiencyPenalty >= durabilityPenalty and efficiencyPenalty >= vitalityPenalty and efficiencyPenalty >= divergencePenalty and efficiencyPenalty > 0 ? "Poor Efficiency" :
     durabilityPenalty >= fuelPenalty and durabilityPenalty >= efficiencyPenalty and durabilityPenalty >= vitalityPenalty and durabilityPenalty >= divergencePenalty and durabilityPenalty > 0 ? "Structural Fatigue" :
     vitalityPenalty >= fuelPenalty and vitalityPenalty >= efficiencyPenalty and vitalityPenalty >= durabilityPenalty and vitalityPenalty >= divergencePenalty and vitalityPenalty > 0 ? "Weak Vitality" :
     divergencePenalty > 0 ? activeDivergence :
     "Balanced"
primaryLimiterBg =
     primaryLimiter == "Balanced" ? color.new(color.green, 80) :
     primaryLimiter == "Mature Grind" ? color.new(color.teal, 70) :
     primaryLimiter == "Silent Damage" ? color.new(color.orange, 65) :
     primaryLimiter == "Late Cycle" ? color.new(color.red, 60) :
     color.new(color.orange, 70)
marketHealthText =
     marketHealth >= 85 ? "Healthy Expansion" :
     marketHealth >= 65 ? "Healthy Trend" :
     marketHealth >= 45 ? "Transition" :
     marketHealth >= 25 ? "Fatiguing" :
     "Exhaustion"
//──────────────────────────────────────
// 10.10c Market Lifecycle Engine
// Dual-family evidence voting model
//──────────────────────────────────────
buyerPowerRising = f_isRising(buyerEngTraj)
buyerPowerFalling = f_isFalling(buyerEngTraj)
buyerEffRising = f_isRising(buyerTrnTraj)
buyerEffFalling = f_isFalling(buyerTrnTraj)
buyerFuelRising = f_isRising(buyerResTraj)
buyerFuelFalling = f_isFalling(buyerResTraj)
buyerWearFalling = f_isFalling(buyerWearTraj)
sellerPowerRising = f_isRising(sellerEngTraj)
sellerPowerFalling = f_isFalling(sellerEngTraj)
sellerEffRising = f_isRising(sellerTrnTraj)
sellerEffFalling = f_isFalling(sellerTrnTraj)
sellerFuelRising = f_isRising(sellerResTraj)
sellerFuelFalling = f_isFalling(sellerResTraj)
sellerWearFalling = f_isFalling(sellerWearTraj)
bullExpansionScore =
     f_vote(dominant == "Buyers", 15) +
     f_vote(buyerVitality >= 70, 20) +
     f_vote(buyerReserve >= 45, 15) +
     f_vote(buyerPowerRising, 15) +
     f_vote(buyerEffRising or buyerTransmissionScore >= 70, 15) +
     f_vote(buyerWearScore >= 70, 10) +
     f_vote(buyerDecayCount == 0, 10)
bullMaturityScore =
     f_vote(dominant == "Buyers", 15) +
     f_vote(buyerVitality >= 55 and buyerVitality < 85, 15) +
     f_vote(buyerReserve < 45, 15) +
     f_vote(buyerEffFalling or buyerEfficiencyDecayDbg, 15) +
     f_vote(buyerFuelFalling, 15) +
     f_vote(buyerDecayCount >= 1, 10) +
     f_vote(sellerVitality >= 25, 15)
bullDistributionScore =
     f_vote(dominant == "Buyers", 10) +
     f_vote(buyerLateCycleDivergence, 25) +
     f_vote(buyerSilentDamage, 20) +
     f_vote(buyerReserve < 30, 15) +
     f_vote(buyerEffFalling, 15) +
     f_vote(buyerWearFalling or buyerWearScore < 45, 15)
bullFatigueScore =
     f_vote(buyerVitality < 45, 20) +
     f_vote(buyerReserve < 20, 20) +
     f_vote(buyerWearScore < 35, 15) +
     f_vote(buyerDecayCount >= 2, 15) +
     f_vote(sellerVitality > buyerVitality, 15) +
     f_vote(marketHealth < 35, 15)
bearCapitulationScore =
     f_vote(dominant == "Sellers", 15) +
     f_vote(sellerVitality >= 75, 20) +
     f_vote(buyerVitality <= 30, 20) +
     f_vote(buyerReserve <= 15, 15) +
     f_vote(marketHealth <= 25, 15) +
     f_vote(rapidDecay or activeVitality <= 25, 15)
bearRepairScore =
     f_vote(dominant == "Sellers", 10) +
     f_vote(sellerVitality < 80 and sellerVitality >= 45, 15) +
     f_vote(sellerPowerFalling or sellerMatureGrind, 20) +
     f_vote(sellerFuelFalling or sellerReserve < 35, 15) +
     f_vote(buyerPowerRising or buyerVitality > buyerVitality[1], 20) +
     f_vote(marketHealth > 20 and marketHealth < 50, 20)
bearAccumulationScore =
     f_vote(math.abs(buyerVitality - sellerVitality) < 25, 20) +
     f_vote(buyerVitality >= 25 and buyerVitality <= 55, 15) +
     f_vote(sellerVitality <= 65, 15) +
     f_vote(buyerFuelRising, 15) +
     f_vote(buyerEffRising or buyerTransmissionScore >= 60, 15) +
     f_vote(marketHealth >= 25 and marketHealth <= 60, 20)
bearEmergenceScore =
     f_vote(dominant == "Buyers", 20) +
     f_vote(buyerVitality > sellerVitality, 20) +
     f_vote(buyerPowerRising, 15) +
     f_vote(buyerFuelRising or buyerReserve >= 30, 15) +
     f_vote(buyerTransmissionScore >= 60, 15) +
     f_vote(sellerVitality < 55, 15)
maxLifecycleScore =
     math.max(
         math.max(
             math.max(bullExpansionScore, bullMaturityScore),
             math.max(bullDistributionScore, bullFatigueScore)
         ),
         math.max(
             math.max(bearCapitulationScore, bearRepairScore),
             math.max(bearAccumulationScore, bearEmergenceScore)
         )
     )
rawCycleStage =
     maxLifecycleScore == bullExpansionScore    ? "Bull Expansion" :
     maxLifecycleScore == bullMaturityScore     ? "Bull Maturity" :
     maxLifecycleScore == bullDistributionScore ? "Bull Distribution" :
     maxLifecycleScore == bullFatigueScore      ? "Bull Fatigue" :
     maxLifecycleScore == bearCapitulationScore ? "Bear Capitulation" :
     maxLifecycleScore == bearRepairScore       ? "Bear Repair" :
     maxLifecycleScore == bearAccumulationScore ? "Bear Accumulation" :
     "Bear Emergence"
float developingScore = 0.0
string developingStage = "None"
if rawCycleStage != "Bull Expansion" and bullExpansionScore > developingScore
    developingScore := bullExpansionScore
    developingStage := "Bull Expansion"
if rawCycleStage != "Bull Maturity" and bullMaturityScore > developingScore
    developingScore := bullMaturityScore
    developingStage := "Bull Maturity"
if rawCycleStage != "Bull Distribution" and bullDistributionScore > developingScore
    developingScore := bullDistributionScore
    developingStage := "Bull Distribution"
if rawCycleStage != "Bull Fatigue" and bullFatigueScore > developingScore
    developingScore := bullFatigueScore
    developingStage := "Bull Fatigue"
if rawCycleStage != "Bear Capitulation" and bearCapitulationScore > developingScore
    developingScore := bearCapitulationScore
    developingStage := "Bear Capitulation"
if rawCycleStage != "Bear Repair" and bearRepairScore > developingScore
    developingScore := bearRepairScore
    developingStage := "Bear Repair"
if rawCycleStage != "Bear Accumulation" and bearAccumulationScore > developingScore
    developingScore := bearAccumulationScore
    developingStage := "Bear Accumulation"
if rawCycleStage != "Bear Emergence" and bearEmergenceScore > developingScore
    developingScore := bearEmergenceScore
    developingStage := "Bear Emergence"
// Hysteresis / persistence
var string confirmedCycleStage = "No Data"
var string candidateCycleStage = "No Data"
var int candidateLifecycleBars = 0
htfLifecycleClock = ta.change(time(wellnessHTF)) != 0 or barstate.isfirst
if htfLifecycleClock
    if confirmedCycleStage == "No Data"
        confirmedCycleStage := rawCycleStage
        candidateCycleStage := rawCycleStage
        candidateLifecycleBars := 0
    else if rawCycleStage == confirmedCycleStage
        candidateCycleStage := rawCycleStage
        candidateLifecycleBars := 0
    else
        if rawCycleStage != candidateCycleStage
            candidateCycleStage := rawCycleStage
            candidateLifecycleBars := 1
        else
            candidateLifecycleBars += 1
        if candidateLifecycleBars >= lifecycleConfirmBars
            confirmedCycleStage := candidateCycleStage
            candidateLifecycleBars := 0
cycleConfidence =
     confirmedCycleStage == "Bull Expansion"    ? bullExpansionScore :
     confirmedCycleStage == "Bull Maturity"     ? bullMaturityScore :
     confirmedCycleStage == "Bull Distribution" ? bullDistributionScore :
     confirmedCycleStage == "Bull Fatigue"      ? bullFatigueScore :
     confirmedCycleStage == "Bear Capitulation" ? bearCapitulationScore :
     confirmedCycleStage == "Bear Repair"       ? bearRepairScore :
     confirmedCycleStage == "Bear Accumulation" ? bearAccumulationScore :
     confirmedCycleStage == "Bear Emergence"    ? bearEmergenceScore :
     maxLifecycleScore
cycleFamily =
     str.contains(confirmedCycleStage, "Bull") ? "Bull Family" :
     str.contains(confirmedCycleStage, "Bear") ? "Bear Family" :
     "Transition"
cycleStageText =
     confirmedCycleStage + " | Evidence " + str.tostring(math.round(cycleConfidence))
developingStageText =
     developingStage + " | Evidence " + str.tostring(math.round(developingScore))
//══════════════════════════════════════════════════════════════════════════════
// 10.11 COMMAND CENTER NARRATIVE
// Presentation only. Every sentence is built from the same variables displayed
// in TREND OVERVIEW, ENGINE OVERVIEW, TRAJECTORY, MARKET STATE, and WARNINGS.
//
// COMMAND CENTER DESIGN RULES
// 1. Never fabricate information.
// 2. Every statement must map to one or more visible dashboard rows.
// 3. The dashboard is the evidence; the Command Center is the narrative.
// 4. No new score, threshold, vote, forecast, or trade instruction is created.
// 5. If the dashboard cannot verify a statement, it does not appear here.
//══════════════════════════════════════════════════════════════════════════════
//──────────────────────────────────────
// 10.11A Plain-English Narrative Engine
// Presentation only. Every sentence is derived from dashboard-visible states.
//──────────────────────────────────────
f_buildCampaignLabel(string _dominant) =>
    _dominant == "Buyers" ? "▲ BUYER CAMPAIGN" :
     _dominant == "Sellers" ? "▼ SELLER CAMPAIGN" :
     "◆ CONTESTED MARKET"
f_marketStatePhrase(string _state) =>
    _state == "Strong" ? "market conditions remain strong" :
     _state == "Peak" ? "the market remains near peak conditions" :
     _state == "Weak" ? "market conditions remain weak" :
     _state == "Recovery" ? "the market remains in recovery" :
     _state == "Transition" ? "the market is moving through a transition" :
     _state == "Neutral" ? "market conditions remain balanced" :
     _state == "No Data" ? "the broader market state is still developing" :
     "the current market state is " + _state
f_buildControlNarrative(string _dominant, string _state) =>
    string _stateText = f_marketStatePhrase(_state)
    _dominant == "Buyers" ?
         (_state == "Weak" ? "Buyers still hold control despite weak market conditions." :
          _state == "Transition" ? "Buyers retain a slight edge as the market moves through a transition." :
          "Buyers remain in control as " + _stateText + ".") :
     _dominant == "Sellers" ?
         (_state == "Strong" ? "Sellers hold control despite otherwise strong market conditions." :
          _state == "Recovery" ? "Sellers still hold control even as the market begins to recover." :
          "Sellers remain in control as " + _stateText + ".") :
     "Neither side has clear control as " + _stateText + "."
//──────────────────────────────────────
// THE TAKEAWAY
// One-sentence synthesis of control, campaign health, applied Power, and trajectory.
// Vitality describes campaign health; Power describes force being applied now.
// Narrative thresholds classify existing scores only; no new score, forecast, or trade signal is created.
// "Efficiency" is translated into its price consequence:
// rising = pressure is translating into directional price movement more easily
// falling = more pressure/effort is required for the same directional progress
//──────────────────────────────────────
f_buildTakeaway(string _dominant, float _buyerVitality, float _sellerVitality, float _buyerPowerLevel, float _sellerPowerLevel, float _buyerReserve, float _sellerReserve, string _buyerPower, string _sellerPower, string _buyerEfficiency, string _sellerEfficiency) =>
    bool _buyerPowerUp = f_isRising(_buyerPower)
    bool _buyerPowerDown = f_isFalling(_buyerPower)
    bool _sellerPowerUp = f_isRising(_sellerPower)
    bool _sellerPowerDown = f_isFalling(_sellerPower)
    bool _buyerEffUp = f_isRising(_buyerEfficiency)
    bool _buyerEffDown = f_isFalling(_buyerEfficiency)
    bool _sellerEffUp = f_isRising(_sellerEfficiency)
    bool _sellerEffDown = f_isFalling(_sellerEfficiency)
    bool _buyerPowerNoData = _buyerPower == "No Data"
    bool _sellerPowerNoData = _sellerPower == "No Data"
    bool _buyerEffNoData = _buyerEfficiency == "No Data"
    bool _sellerEffNoData = _sellerEfficiency == "No Data"
    float _powerGap = _buyerPowerLevel - _sellerPowerLevel
    bool _buyerHealthyLowPower = _buyerVitality >= 65 and _buyerPowerLevel <= 35
    bool _sellerHealthyLowPower = _sellerVitality >= 65 and _sellerPowerLevel <= 35
    bool _buyerWeakHighPower = _buyerVitality <= 45 and _buyerPowerLevel >= 65
    bool _sellerWeakHighPower = _sellerVitality <= 45 and _sellerPowerLevel >= 65
    string _takeaway = "Neither side has a clear advantage yet."
    if _dominant == "Buyers"
        if _buyerPowerNoData or _buyerEffNoData
            _takeaway := "Buyers hold the advantage while the supporting pressure and price-response history is still developing."
        else if _sellerWeakHighPower
            _takeaway := "Buyers retain the broader advantage, but sellers are mounting a strong counterattack despite weak campaign health."
        else if _buyerReserve <= 15 and (_buyerPowerLevel <= 40 or _buyerEffDown)
            _takeaway := "Buyers retain control, but continuation risk is rising as reserves thin."
        else if _powerGap >= 35 and not _buyerPowerDown
            _takeaway := "Buyers hold a substantial pressure advantage and remain firmly in control."
        else if _powerGap <= 10 and _buyerPowerDown
            _takeaway := "Buyer control remains intact, but the pressure advantage is narrowing and becoming more vulnerable."
        else if _buyerHealthyLowPower
            _takeaway := "The buyer campaign remains structurally healthy, but immediate buying pressure is limited."
        else if _buyerWeakHighPower
            _takeaway := "Buyer campaign health is weak despite strong immediate buying pressure."
        else if _buyerPowerDown and _buyerEffUp
            _takeaway := "Buyers retain the advantage despite lighter pressure; what remains is still translating efficiently into higher prices."
        else if _buyerPowerDown and _buyerEffDown
            _takeaway := "Buyers retain control, but fading pressure is producing less upward progress."
        else if _buyerPowerUp and _buyerEffDown
            _takeaway := "Buyers remain in control, but they are spending more pressure for less upward progress."
        else if _buyerPowerUp and _buyerEffUp
            _takeaway := "Buyer pressure is expanding and translating into higher prices more efficiently."
        else
            _takeaway := "Buyers remain in control, with the pressure balance broadly stable."
    else if _dominant == "Sellers"
        if _sellerPowerNoData or _sellerEffNoData
            _takeaway := "Sellers hold the advantage while the supporting pressure and price-response history is still developing."
        else if _buyerWeakHighPower
            _takeaway := "Sellers retain the broader advantage, but buyers are mounting a strong counterattack despite weak campaign health."
        else if _sellerReserve <= 15 and (_sellerPowerLevel <= 40 or _sellerEffDown)
            _takeaway := "Sellers retain control, but continuation risk is rising as reserves thin."
        else if _powerGap <= -35 and not _sellerPowerDown
            _takeaway := "Sellers hold a substantial pressure advantage and remain firmly in control."
        else if _powerGap >= -10 and _sellerPowerDown
            _takeaway := "Seller control remains intact, but the pressure advantage is narrowing and becoming more vulnerable."
        else if _sellerHealthyLowPower
            _takeaway := "The seller campaign remains structurally healthy, but immediate selling pressure is limited."
        else if _sellerWeakHighPower
            _takeaway := "Seller campaign health is weak despite strong immediate selling pressure."
        else if _sellerPowerDown and _sellerEffUp
            _takeaway := "Sellers retain the advantage despite lighter pressure; what remains is still translating efficiently into lower prices."
        else if _sellerPowerDown and _sellerEffDown
            _takeaway := "Sellers retain control, but fading pressure is producing less downward progress."
        else if _sellerPowerUp and _sellerEffDown
            _takeaway := "Sellers remain in control, but they are spending more pressure for less downward progress."
        else if _sellerPowerUp and _sellerEffUp
            _takeaway := "Seller pressure is expanding and translating into lower prices more efficiently."
        else
            _takeaway := "Sellers remain in control, with the pressure balance broadly stable."
    _takeaway

f_buildTrendNarrative(string _cycleStage, string _marketHealth, string _dominant, float _buyerPowerLevel, float _sellerPowerLevel, float _buyerReserve, float _sellerReserve, string _buyerEfficiency, string _sellerEfficiency) =>
    bool _buyerEffDown = f_isFalling(_buyerEfficiency)
    bool _sellerEffDown = f_isFalling(_sellerEfficiency)
    bool _buyerExtensionWeak = _buyerReserve <= 15 and (_buyerPowerLevel <= 40 or _buyerEffDown)
    bool _sellerExtensionWeak = _sellerReserve <= 15 and (_sellerPowerLevel <= 40 or _sellerEffDown)
    string _cycleText =
         _cycleStage == "Bull Expansion" ? (_dominant == "Buyers" ? "The buyer campaign is in expansion." : "Sellers are contesting a still-strong bullish expansion.") :
         _cycleStage == "Bull Maturity" ? (_dominant == "Buyers" ? "The buyer campaign is in maturity, with its strongest phase likely behind it." : "Sellers control the transition as the prior bullish campaign matures.") :
         _cycleStage == "Bull Distribution" ? (_dominant == "Buyers" ? "The buyer campaign is in distribution as seller influence grows." : "The market is in bullish distribution as sellers take control.") :
         _cycleStage == "Bull Fatigue" ? (_dominant == "Buyers" ? "The buyer campaign is in fatigue." : "Sellers control the transition as the prior bullish campaign fatigues.") :
         _cycleStage == "Bear Capitulation" ? (_dominant == "Sellers" ? "The seller campaign is in capitulation." : "Buyers are taking control as the prior bearish campaign reaches capitulation.") :
         _cycleStage == "Bear Repair" ? (_dominant == "Sellers" ? "The seller campaign is in repair, with the bearish impulse losing continuity." : "The buyer campaign is in repair after the prior bearish move.") :
         _cycleStage == "Bear Accumulation" ? (_dominant == "Buyers" ? "The buyer campaign is in accumulation, rebuilding after the prior bearish move." : "Sellers retain control while the market enters bearish accumulation.") :
         _cycleStage == "Bear Emergence" ? (_dominant == "Sellers" ? "The seller campaign is in emergence and beginning to take shape." : "The market is in bear emergence against the active buyer campaign.") :
         "The current campaign phase is still taking shape."
    string _extensionText =
         _dominant == "Buyers" and _buyerExtensionWeak ? " Extension capacity is weakening as buyer reserves thin." :
         _dominant == "Sellers" and _sellerExtensionWeak ? " Extension capacity is weakening as seller reserves thin." :
         ""
    string _healthText =
         _marketHealth == "Healthy Expansion" ? " Underlying market structure remains resilient." :
         _marketHealth == "Healthy Trend" ? " Underlying market structure remains constructive." :
         _marketHealth == "Transition" ? " Underlying conditions are shifting." :
         _marketHealth == "Fatiguing" ? " Underlying market health is weakening." :
         _marketHealth == "Exhaustion" ? " The current move is showing signs of exhaustion." :
         " There is not enough information yet to assess market health."
    _cycleText + _extensionText + _healthText

f_buildEngineNarrative(string _engineStatus, string _primaryLimiter, string _efficiency, string _dominant, float _buyerPower, float _sellerPower, float _buyerFuel, float _sellerFuel) =>
    float _power = _dominant == "Buyers" ? _buyerPower : _dominant == "Sellers" ? _sellerPower : math.max(_buyerPower, _sellerPower)
    float _fuel = _dominant == "Buyers" ? _buyerFuel : _dominant == "Sellers" ? _sellerFuel : math.max(_buyerFuel, _sellerFuel)
    string _side = _dominant == "Buyers" ? "Buyer" : _dominant == "Sellers" ? "Seller" : "Active"
    string _capacityText =
         _fuel <= 10 and _power <= 35 ? _side + " force is light and reserves are nearly depleted, leaving little capacity for renewed pressure." :
         _fuel <= 15 and _power >= 60 ? _side + " force remains high, but depleted reserves are reducing durability." :
         _fuel <= 20 ? _side + " reserves are thin, limiting the staying power behind current pressure." :
         _power <= 25 ? _side + " pressure is light even though reserve capacity remains available." :
         ""
    string _limiterText =
         _primaryLimiter == "Fuel Starvation" ? "Limited fuel is restricting the current campaign." :
         _primaryLimiter == "Poor Efficiency" ? "The campaign is spending more effort for less price progress." :
         _primaryLimiter == "Structural Fatigue" ? "Structural fatigue is reducing the campaign's staying power." :
         _primaryLimiter == "Weak Vitality" ? "Weak participation is limiting the current campaign." :
         _primaryLimiter == "Late Cycle" ? "Late-cycle conditions are making further progress harder to sustain." :
         _primaryLimiter == "Silent Damage" ? "Hidden internal weakness is limiting the current campaign." :
         _primaryLimiter == "Mature Grind" ? "The campaign remains active, but progress has become slower and harder to sustain." :
         "No single weakness is dominating the engine."
    string _efficiencyText =
         _efficiency == "Weakening" ? "Efficiency is deteriorating." :
         _efficiency == "Stable" ? "Efficiency is holding steady." :
         "Efficiency history is still developing."
    string _statusText =
         _engineStatus == "Buyer Exhaustion" ? "Buyers are showing signs of exhaustion." :
         _engineStatus == "Seller Exhaustion" ? "Sellers are showing signs of exhaustion." :
         ""
    (_capacityText != "" ? _capacityText : _limiterText) + " " + _efficiencyText + (_statusText != "" ? " " + _statusText : "")

f_buildTrajectoryNarrative(string _buyerPower, string _sellerPower, string _buyerEfficiency, string _sellerEfficiency, float _buyerPowerLevel, float _sellerPowerLevel) =>
    bool _buyerPowerUp = f_isRising(_buyerPower)
    bool _buyerPowerDown = f_isFalling(_buyerPower)
    bool _sellerPowerUp = f_isRising(_sellerPower)
    bool _sellerPowerDown = f_isFalling(_sellerPower)
    bool _buyerEffUp = f_isRising(_buyerEfficiency)
    bool _buyerEffDown = f_isFalling(_buyerEfficiency)
    bool _sellerEffUp = f_isRising(_sellerEfficiency)
    bool _sellerEffDown = f_isFalling(_sellerEfficiency)
    bool _powerNoData = _buyerPower == "No Data" and _sellerPower == "No Data"
    bool _effNoData = _buyerEfficiency == "No Data" and _sellerEfficiency == "No Data"
    float _gap = _buyerPowerLevel - _sellerPowerLevel
    string _powerText =
         _powerNoData ? "Power history is still developing." :
         _sellerPowerUp and _buyerPowerDown ? "Seller pressure is building while buyer pressure eases." :
         _buyerPowerUp and _sellerPowerDown ? "Buyer pressure is rebuilding while seller pressure fades." :
         _buyerPowerUp and _sellerPowerUp ? (_gap >= 20 ? "Both sides are adding pressure, with buyers still holding the stronger hand." : _gap <= -20 ? "Both sides are adding pressure, with sellers still holding the stronger hand." : "Both sides are adding pressure and the contest is tightening.") :
         _buyerPowerDown and _sellerPowerDown ? (_gap >= 20 ? "Pressure is easing on both sides, but buyers retain substantially more active force." : _gap <= -20 ? "Pressure is easing on both sides, but sellers retain substantially more active force." : "Applied pressure is easing on both sides as the imbalance narrows.") :
         _sellerPowerUp ? "Seller pressure is building." :
         _buyerPowerUp ? "Buyer pressure is building." :
         _sellerPowerDown ? "Seller pressure is easing." :
         _buyerPowerDown ? "Buyer pressure is easing." :
         "Neither side is gaining meaningful momentum."
    string _effText =
         _effNoData ? "Efficiency history is still developing." :
         _buyerEffDown and _sellerEffUp ? "Sellers are becoming more effective as buyer efficiency slips." :
         _sellerEffDown and _buyerEffUp ? "Buyers are becoming more effective as seller efficiency slips." :
         _buyerEffDown and _sellerEffDown ? "Both sides are becoming less efficient." :
         _buyerEffUp and _sellerEffUp ? "Both sides are becoming more efficient." :
         _buyerEffDown ? "Buyer efficiency is weakening." :
         _sellerEffDown ? "Seller efficiency is weakening." :
         _buyerEffUp ? "Buyer efficiency is improving." :
         _sellerEffUp ? "Seller efficiency is improving." :
         "Efficiency is broadly stable."
    _powerText + " " + _effText

f_buildMarketNarrative(string _state, string _dominant, string _velocity, string _structure) =>
    string _opening =
         _state == "Strong" and _dominant == "Buyers" ? "Underlying market structure remains resilient, with buyers holding the advantage." :
         _state == "Strong" and _dominant == "Sellers" ? "Underlying market structure remains resilient despite current seller control." :
         _state == "Peak" and _dominant == "Buyers" ? "Underlying conditions remain near peak health, with buyers holding the advantage." :
         _state == "Peak" and _dominant == "Sellers" ? "Underlying conditions remain near peak health despite current seller control." :
         _state == "Weak" and _dominant == "Buyers" ? "Underlying market structure remains weak despite buyer control." :
         _state == "Weak" and _dominant == "Sellers" ? "Underlying market structure remains weak, with sellers holding the advantage." :
         _state == "Recovery" and _dominant == "Buyers" ? "Underlying conditions are recovering with buyers holding the advantage." :
         _state == "Recovery" and _dominant == "Sellers" ? "Underlying conditions are recovering despite continued seller control." :
         _state == "Transition" and _dominant == "Buyers" ? "The market is in transition, with buyers holding a slight edge." :
         _state == "Transition" and _dominant == "Sellers" ? "The market is in transition, with sellers holding a slight edge." :
         _state == "Transition" ? "The market is in transition with no clear side in control." :
         _dominant == "Buyers" ? "Buyers hold the advantage as " + f_marketStatePhrase(_state) + "." :
         _dominant == "Sellers" ? "Sellers hold the advantage as " + f_marketStatePhrase(_state) + "." :
         "Control remains contested as " + f_marketStatePhrase(_state) + "."
    string _velocityText = ""
    if _velocity == "Recovering Fast"
        _velocityText := _dominant == "Buyers" ? "Underlying conditions are improving quickly in favor of buyers." : _dominant == "Sellers" ? "The recovery is making sustained seller control less secure." : "Underlying conditions are improving quickly."
    else if _velocity == "Recovering"
        _velocityText := _dominant == "Buyers" ? "Underlying conditions are improving in favor of buyers." : _dominant == "Sellers" ? "The recovery is making sustained seller control less secure." : "Underlying conditions are improving."
    else if _velocity == "Stable"
        _velocityText := "Underlying conditions are holding steady."
    else if _velocity == "Decaying"
        _velocityText := _dominant == "Buyers" ? "Underlying conditions are becoming less favorable to sustained buyer control." : _dominant == "Sellers" ? "Underlying conditions are shifting in favor of sellers." : "Underlying conditions are deteriorating."
    else if _velocity == "Rapid Decay"
        _velocityText := _dominant == "Buyers" ? "Underlying conditions are deteriorating quickly against buyer control." : _dominant == "Sellers" ? "Underlying conditions are shifting quickly in favor of sellers." : "Underlying conditions are deteriorating quickly."
    else if _velocity == "No Data"
        _velocityText := "The rate of change is still developing."
    else
        _velocityText := "The rate of change is neutral."
    string _structureText =
         _structure == "Blood Diamond" ? "A bearish structural shift is active." :
         _structure == "Green Recovery" ? "A recovery structure is active." :
         ""
    _opening + " " + _velocityText + (_structureText != "" ? " " + _structureText : "")

f_buildConditionsNarrative(string _dominant, string _structure, bool _buyerSilentDamage, bool _sellerSilentDamage, string _activeDivergence, bool _buyerLateCycle, bool _sellerLateCycle, string _buyerPower, string _sellerPower, float _buyerPowerLevel, float _sellerPowerLevel, float _buyerFuel, float _sellerFuel) =>
    bool _buyerPowerUp = f_isRising(_buyerPower)
    bool _buyerPowerDown = f_isFalling(_buyerPower)
    bool _sellerPowerUp = f_isRising(_sellerPower)
    bool _sellerPowerDown = f_isFalling(_sellerPower)
    string _watch = ""
    if _dominant == "Sellers"
        _watch := _buyerPowerUp and _sellerPowerDown ? "Watch whether buyer pressure continues rebuilding while seller pressure fades; sustained follow-through would threaten seller control." :
             _sellerFuel <= 10 ? "Seller reserves are nearly depleted; watch for renewed seller pressure before treating control as durable." :
             _sellerPowerDown and _buyerPowerLevel >= _sellerPowerLevel * 0.75 ? "Seller pressure is fading and the imbalance is narrowing; watch for a buyer pressure crossover." :
             _sellerPowerUp ? "Watch whether rising seller pressure produces continued downside progress; failure to do so would signal weakening efficiency." :
             "Watch whether sellers can preserve their pressure advantage or buyers begin to close the gap."
    else if _dominant == "Buyers"
        _watch := _sellerPowerUp and _buyerPowerDown ? "Watch whether seller pressure continues rebuilding while buyer pressure fades; sustained follow-through would threaten buyer control." :
             _buyerFuel <= 10 ? "Buyer reserves are nearly depleted; watch for renewed buyer pressure before treating control as durable." :
             _buyerPowerDown and _sellerPowerLevel >= _buyerPowerLevel * 0.75 ? "Buyer pressure is fading and the imbalance is narrowing; watch for a seller pressure crossover." :
             _buyerPowerUp ? "Watch whether rising buyer pressure produces continued upside progress; failure to do so would signal weakening efficiency." :
             "Watch whether buyers can preserve their pressure advantage or sellers begin to close the gap."
    else
        _watch := "Control is contested; watch for one side to establish a sustained pressure advantage."
    if _structure == "Blood Diamond"
        _watch += " Bearish structure remains active."
    else if _structure == "Green Recovery"
        _watch += " Recovery structure remains active."
    if _buyerSilentDamage or _sellerSilentDamage
        _watch += " Hidden structural damage also deserves attention."
    if _buyerLateCycle or _sellerLateCycle or _activeDivergence == "Late Cycle"
        _watch += " Late-cycle stress raises reversal sensitivity."
    else if _activeDivergence == "Mature Grind"
        _watch += " Mature-grind conditions favor confirmation over anticipation."
    _watch

//──────────────────────────────────────
// 10.11B Evidence-Backed Briefing
// Each argument below is also rendered in the dashboard.
//──────────────────────────────────────
string commanderCampaign = f_buildCampaignLabel(dominant)
string commanderControl = f_buildControlNarrative(
     dominant,
     state)
string commanderTakeaway = f_buildTakeaway(
     dominant,
     buyerVitality,
     sellerVitality,
     buyerEngineScore,
     sellerEngineScore,
     buyerReserve,
     sellerReserve,
     buyerEngTraj,
     sellerEngTraj,
     buyerTrnTraj,
     sellerTrnTraj)
string commanderTrend = f_buildTrendNarrative(
     confirmedCycleStage,
     marketHealthText,
     dominant,
     buyerEngineScore,
     sellerEngineScore,
     buyerReserve,
     sellerReserve,
     buyerTrnTraj,
     sellerTrnTraj)
string commanderEngine = f_buildEngineNarrative(
     warningBias,
     primaryLimiter,
     efficiencyText,
     dominant,
     buyerEngineScore,
     sellerEngineScore,
     buyerReserve,
     sellerReserve)
string commanderTrajectory = f_buildTrajectoryNarrative(
     buyerEngTraj,
     sellerEngTraj,
     buyerTrnTraj,
     sellerTrnTraj,
     buyerEngineScore,
     sellerEngineScore)
string commanderMarket = f_buildMarketNarrative(
     state,
     dominant,
     agingVelocityText,
     structure)
string commanderRisk = f_buildConditionsNarrative(
     dominant,
     structure,
     buyerSilentDamage,
     sellerSilentDamage,
     activeDivergence,
     buyerLateCycleDivergence,
     sellerLateCycleDivergence,
     buyerEngTraj,
     sellerEngTraj,
     buyerEngineScore,
     sellerEngineScore,
     buyerReserve,
     sellerReserve)
string commanderBriefText =
     "COMMAND CENTER" +
     "\n" + commanderCampaign +
     "\n" + f_cleanTF(timeframe.period) + " → " + f_cleanTF(wellnessHTF) +
     "\n" +
     "\nTREND OVERVIEW" +
     "\n" + commanderTrend +
     "\n" +
     "\nENGINE OVERVIEW" +
     "\n" + commanderEngine +
     "\n" +
     "\nTRAJECTORY" +
     "\n" + commanderTrajectory +
     "\n" +
     "\nMARKET STATE" +
     "\n" + commanderMarket +
     "\n" +
     "\nACTIVE CONDITIONS" +
     "\n" + commanderRisk
//══════════════════════════════════════════════════════════════════════════════
// 10.12 COMMAND CENTER OVERLAY
// THE TAKEAWAY sits directly below CONTROL as the one-line plain-English summary.
// All rows remain driven by the same evidence-backed variables used below.
//══════════════════════════════════════════════════════════════════════════════
var table commanderBriefTable = table.new(position.top_right, 2, 11, border_width = 1, border_color = color.new(color.white, 80), force_overlay = true)
var bool commanderBriefMerged = false
if barstate.islast
    commandPosition = commandSideOpt == "Right" ? position.top_right : position.top_left
    table.set_position(commanderBriefTable, commandPosition)
    table.clear(commanderBriefTable, 0, 0, 1, 10)
    if not commanderBriefMerged
        table.merge_cells(commanderBriefTable, 0, 0, 1, 0)
        commanderBriefMerged := true
    if showCommandBrief
        table.cell(commanderBriefTable, 0, 0, "COMMAND CENTER  •  " + commanderCampaign + "  •  " + f_cleanTF(timeframe.period) + " → " + f_cleanTF(wellnessHTF), text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 1, "CONTROL", text_color = color.white, bgcolor = color.new(color.gray, 72), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 1, commanderControl, text_color = color.white, bgcolor = mainBg, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 2, "THE TAKEAWAY", text_color = color.white, bgcolor = color.new(color.orange, 62), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 2, commanderTakeaway, text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 3, "CYCLE STAGE", text_color = color.white, bgcolor = f_lifecycleBg(confirmedCycleStage), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 3, confirmedCycleStage + "  •  " + str.tostring(math.round(cycleConfidence)) + "%", text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 4, "▲ BUYERS", text_color = color.white, bgcolor = color.new(color.green, 58), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 4, "Vitality " + str.tostring(buyerVitality) + "  |  Power " + str.tostring(buyerEngineScore, "#") + "  |  Fuel " + str.tostring(buyerReserve, "#"), text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 5, "▼ SELLERS", text_color = color.white, bgcolor = color.new(color.red, 58), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 5, "Vitality " + str.tostring(sellerVitality) + "  |  Power " + str.tostring(sellerEngineScore, "#") + "  |  Fuel " + str.tostring(sellerReserve, "#"), text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 6, "CAMPAIGN", text_color = color.white, bgcolor = color.new(color.blue, 68), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 6, commanderTrend, text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 7, "ENGINE", text_color = color.white, bgcolor = color.new(color.navy, 62), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 7, commanderEngine, text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 8, "TACTICAL SHIFT", text_color = color.white, bgcolor = color.new(color.gray, 68), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 8, commanderTrajectory, text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 9, "MARKET", text_color = color.white, bgcolor = color.new(color.blue, 72), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 9, commanderMarket, text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
        table.cell(commanderBriefTable, 0, 10, "WATCH LIST", text_color = color.white, bgcolor = color.new(color.red, 68), text_size = commandTxtSize)
        table.cell(commanderBriefTable, 1, 10, commanderRisk, text_color = commandTextColor, bgcolor = commandBgColor, text_size = commandTxtSize, text_halign = text.align_left)
//──────────────────────────────────────
// RESEARCH PLOTS
//──────────────────────────────────────
//plot(showDebugPlots and showPriceProgress ? buyerPriceProgressPctDbg : na,title = "Buyer Price Progress %",color = color.green,linewidth = 2)
//plot(showDebugPlots and showEnergySpent ? buyerEnergySpentDbg : na,title = "Buyer Energy Spent",color = color.orange,linewidth = 2)
//plot(showDebugPlots and showAbsEfficiency ? buyerEfficiencyDbg : na,title = "Buyer Absolute Efficiency",color = color.aqua,linewidth = 2)
//plot(showDebugPlots and showEffRatio ? buyerEfficiencyRatioResearchDbg : na, title = "Buyer Efficiency Ratio", color = color.yellow, linewidth = 2)
//──────────────────────────────────────
// KU#9 COMPLETED BUYER WAVE RESEARCH LABEL
//──────────────────────────────────────
newResearchWave =
     not na(buyerWaveSerialDbg) and
     buyerWaveSerialDbg != buyerWaveSerialDbg[1]
if showDebugPlots and newResearchWave
    label.new(
        bar_index,
        buyerResearchEfficiencyDbg,
        "Wave " + str.tostring(buyerWaveSerialDbg) +
        "\n\n── RAW METRICS ──" +
        "\nProgress: " +
        str.tostring(buyerResearchProgressDbg, "#.##") + "%" +
        "\nWT Area: " +
        str.tostring(buyerResearchEnergyDbg, "#.##") +
        "\nV1 Efficiency: " +
        str.tostring(buyerResearchEfficiencyDbg, "#.######") +
        "\nV1 Ratio: " +
        str.tostring(buyerResearchRatioDbg, "#.###") +
        "\nV2 Return: " +
        str.tostring(buyerResearchReturnV2Dbg, "#.###") + "%" +
        "\nV2 Avg Energy: " +
        str.tostring(buyerResearchAvgEnergyV2Dbg, "#.###") +
        "\nV2 Efficiency: " +
        str.tostring(buyerResearchEfficiencyV2Dbg, "#.######") +
        "\nV2 Ratio: " +
        str.tostring(buyerResearchRatioV2Dbg, "#.###") +
        "\n\n── CONTEXT ──" +
        "\nOld Score: " +
        str.tostring(buyerResearchOldScoreV2Dbg, "#.##") +
        "\nNorm Score: " +
        str.tostring(buyerResearchNormV2Dbg, "#.##") +
        "\nBaseline Context: " +
        str.tostring(buyerResearchBaselineScoreV2Dbg, "#.##") +
        "\nPeak Retention: " +
        str.tostring(buyerResearchPeakRetentionV2Dbg, "#.##") +
        "\n\n── REFERENCE ──" +
        "\nPrior Mean: " +
        str.tostring(buyerResearchPriorMeanV2Dbg, "#.######") +
        "\nPrior Peak: " +
        str.tostring(buyerResearchPriorPeakV2Dbg, "#.######") +
        "\nRolling Mean: " +
        str.tostring(buyerResearchMeanV2Dbg, "#.######") +
        "\nRange: " +
        str.tostring(buyerResearchMinV2Dbg, "#.######") +
        " → " +
        str.tostring(buyerResearchMaxV2Dbg, "#.######") +
        "\n\n── WAVE INFO ──" +
        "\nBars: " +
        str.tostring(buyerWaveBarsDbg),
        style = label.style_label_down,
        color = color.new(color.blue, 10),
        textcolor = color.white,
        size = size.small
    )
if barstate.islast
    table.clear(t, 0, 0, 5, 29)
    if not dashboardCellsMerged
        // Permanent hierarchy: one system pair, one buyer pair, one seller pair.
        table.merge_cells(t, 2, 0, 3, 0)
        table.merge_cells(t, 4, 0, 5, 0)
        table.merge_cells(t, 0, 1, 5, 1)
        table.merge_cells(t, 0, 8, 1, 8)
        table.merge_cells(t, 2, 8, 3, 8)
        table.merge_cells(t, 4, 8, 5, 8)
        table.merge_cells(t, 0, 13, 1, 13)
        table.merge_cells(t, 2, 13, 3, 13)
        table.merge_cells(t, 4, 13, 5, 13)
        table.merge_cells(t, 0, 18, 1, 18)
        table.merge_cells(t, 2, 18, 3, 18)
        table.merge_cells(t, 4, 18, 5, 18)
        table.merge_cells(t, 0, 23, 1, 23)
        table.merge_cells(t, 2, 23, 3, 23)
        table.merge_cells(t, 4, 23, 5, 23)
        table.merge_cells(t, 0, 26, 1, 26)
        table.merge_cells(t, 2, 26, 3, 26)
        table.merge_cells(t, 4, 26, 5, 26)
        dashboardCellsMerged := true
    if showTable
        //──────────────────────────────────────
        // 11.1 Global Header
        // Neutral because Trend Overview mixes
        // system-level and side-specific data.
        //──────────────────────────────────────
        table.cell(t, 0, 0, "SYSTEM", text_color = color.white, bgcolor = color.new(color.blue, 55), text_size = txtSize)
        table.cell(t, 1, 0, "STATUS", text_color = color.white, bgcolor = color.new(color.blue, 55), text_size = txtSize)
        table.cell(t, 2, 0, "▲ BUYER ENGINE", text_color = color.white, bgcolor = color.new(color.green, 55), text_size = txtSize, text_halign = text.align_center)
        table.cell(t, 4, 0, "▼ SELLER ENGINE", text_color = color.white, bgcolor = color.new(color.red, 55), text_size = txtSize, text_halign = text.align_center)
        //──────────────────────────────────────
        // 11.2 Trend Overview
        // System-level interpretation plus
        // explicitly labeled side diagnostics.
        //──────────────────────────────────────
        f_section(1, "══ TREND OVERVIEW ══", color.new(color.blue, 82))
        f_row(0, 2, "HTF", f_cleanTF(timeframe.period) + " → " + f_cleanTF(wellnessHTF), color.new(color.gray, 75))
        f_row(2, 2, "Buyer Vitality", str.tostring(buyerVitality) + " / 100", f_stateBg(buyerVitality))
        f_row(4, 2, "Seller Vitality", str.tostring(sellerVitality) + " / 100", f_stateBg(sellerVitality))
        f_row(0, 3, "Market Health Σ", f_gauge(marketHealth) + " " + str.tostring(marketHealth), f_stateBg(marketHealth))
        f_row(2, 3, "Condition", marketHealthText, f_stateBg(marketHealth))
        f_row(4, 3, "Divergence", activeDivergence, divergenceBg)
        f_row(0, 4, "Primary Limiter", primaryLimiter, primaryLimiterBg)
        f_row(2, 4, "Fuel", str.tostring(activeReserveScore, "#"), f_scoreColor(activeReserveScore))
        f_row(4, 4, "Durability", str.tostring(activeDurabilityScore, "#"), f_scoreColor(activeDurabilityScore))
        f_row(0, 5, "Trend Vitality", f_gauge(activeVitality) + " " + str.tostring(activeVitality), mainBg)
        f_row(2, 5, "Buyer Struct.", str.tostring(math.round(buyerStructuralDbg)) + " / 100", f_stateBg(buyerStructuralDbg))
        f_row(4, 5, "Seller Struct.", str.tostring(math.round(sellerStructuralDbg)) + " / 100", f_stateBg(sellerStructuralDbg))
        f_row(0, 6, "Cycle Stage", cycleStageText, f_lifecycleBg(confirmedCycleStage))
        f_row(2, 6, "Buyer Live", str.tostring(math.round(buyerLiveDbg)) + " / 100", f_stateBg(buyerLiveDbg))
        f_row(4, 6, "Seller Live", str.tostring(math.round(sellerLiveDbg)) + " / 100", f_stateBg(sellerLiveDbg))
        f_row(0, 7, "Developing", developingStageText, f_lifecycleBg(developingStage))
        f_row(2, 7, "Buyer Decay", str.tostring(buyerDecayCount) + " / 3", buyerDecayCount >= 2 ? color.new(color.red, 70) : color.new(color.green, 80))
        f_row(4, 7, "Seller Decay", str.tostring(sellerDecayCount) + " / 3", sellerDecayCount >= 2 ? color.new(color.red, 70) : color.new(color.green, 80))
        //──────────────────────────────────────
        // 11.3 Engine Overview
        // Left pair = Buyers
        // Right pair = Sellers
        //──────────────────────────────────────
        f_sectionSides(8, "══ ENGINE OVERVIEW | BUY ← → SELL ══", color.new(color.navy, 82))
        f_row(0, 9, "Engine Status", warningBias, warningBg)
        f_row(2, 9, "Power (Pressure)", f_gauge(buyerEngineScore) + " " + str.tostring(buyerEngineScore, "#"), f_scoreColor(buyerEngineScore))
        f_row(4, 9, "Power (Pressure)", f_gauge(sellerEngineScore) + " " + str.tostring(sellerEngineScore, "#"), f_scoreColor(sellerEngineScore))
        f_row(0, 10, "Trend Fuel", "Usable Capacity", color.new(color.blue, 75))
        f_row(2, 10, "Fuel", f_gauge(buyerReserve) + " " + str.tostring(buyerReserve, "#"), f_scoreColor(buyerReserve))
        f_row(4, 10, "Fuel", f_gauge(sellerReserve) + " " + str.tostring(sellerReserve, "#"), f_scoreColor(sellerReserve))
        f_row(0, 11, "Efficiency", "Conversion: " + efficiencyText, efficiencyBg)
        f_row(2, 11, "Effic.", f_gauge(buyerTransmissionScore) + " " + str.tostring(buyerTransmissionScore, "#"), f_scoreColor(buyerTransmissionScore))
        f_row(4, 11, "Effic.", f_gauge(sellerTransmissionScore) + " " + str.tostring(sellerTransmissionScore, "#"), f_scoreColor(sellerTransmissionScore))
        f_row(0, 12, "Durability", "Recent Resilience", color.new(color.blue, 75))
        f_row(2, 12, "Wear", f_gauge(buyerWearScore) + " " + str.tostring(buyerWearScore, "#"), f_scoreColor(buyerWearScore))
        f_row(4, 12, "Wear", f_gauge(sellerWearScore) + " " + str.tostring(sellerWearScore, "#"), f_scoreColor(sellerWearScore))
        //──────────────────────────────────────
        // 11.4 Trajectory
        // Wave-over-wave directional change.
        //──────────────────────────────────────
        f_sectionSides(13, "══ TRAJECTORY | BUY ← → SELL ══", color.new(color.gray, 82))
        f_row(0, 14, "Trajectory", "Wave-over-Wave", color.new(color.blue, 75))
        f_row(2, 14, "Power →", buyerEngTraj, f_trajectoryColor(buyerEngTraj))
        f_row(4, 14, "Power →", sellerEngTraj, f_trajectoryColor(sellerEngTraj))
        f_row(0, 15, "Efficiency →", "Direction", color.new(color.gray, 85))
        f_row(2, 15, "Effic. →", buyerTrnTraj, f_trajectoryColor(buyerTrnTraj))
        f_row(4, 15, "Effic. →", sellerTrnTraj, f_trajectoryColor(sellerTrnTraj))
        f_row(0, 16, "Durability →", "Direction", color.new(color.gray, 85))
        f_row(2, 16, "Wear →", buyerWearTraj, f_trajectoryColor(buyerWearTraj))
        f_row(4, 16, "Wear →", sellerWearTraj, f_trajectoryColor(sellerWearTraj))
        f_row(0, 17, "Fuel →", "Direction", color.new(color.gray, 85))
        f_row(2, 17, "Fuel →", buyerResTraj, f_trajectoryColor(buyerResTraj))
        f_row(4, 17, "Fuel →", sellerResTraj, f_trajectoryColor(sellerResTraj))
        //──────────────────────────────────────
        // 11.5 Market State
        // Control, damage, and aging velocity.
        //──────────────────────────────────────
        f_sectionSides(18, "══ MARKET STATE | BUY ← → SELL ══", color.new(color.blue, 82))
        f_row(0, 19, "State", state, mainBg)
        f_row(2, 19, "Depth", str.tostring(buyerStructuralDepth, "#.##"), color.new(color.red, 75))
        f_row(4, 19, "Depth", str.tostring(sellerStructuralDepth, "#.##"), color.new(color.red, 75))
        f_row(0, 20, "Dominant", dominant, color.new(color.gray, 75))
        f_row(2, 20, "Penalty", str.tostring(buyerPenaltyStateDbg, "#.##"), color.new(color.gray, 85))
        f_row(4, 20, "Penalty", str.tostring(sellerPenaltyStateDbg, "#.##"), color.new(color.gray, 85))
        f_row(0, 21, "Velocity", agingVelocityText, agingVelocityBg)
        f_row(2, 21, "Impulse", str.tostring(buyerAgeImpulseDbg, "#.##"), color.new(color.gray, 85))
        f_row(4, 21, "Impulse", str.tostring(sellerAgeImpulseDbg, "#.##"), color.new(color.gray, 85))
        f_row(0, 22, "Structure", structure, structure == "None" ? color.new(color.gray, 80) : color.new(color.red, 60))
        f_row(2, 22, "Damage", buyerStructuralDepthText, color.new(color.red, 75))
        f_row(4, 22, "Damage", sellerStructuralDepthText, color.new(color.red, 75))
        //──────────────────────────────────────
        // 11.6 Warnings
        // Side-specific risk diagnostics.
        //──────────────────────────────────────
        f_sectionSides(23, "══ WARNINGS | BUY ← → SELL ══", color.new(color.red, 84))
        f_row(0, 24, "Divergence", activeDivergence, divergenceBg)
        f_row(2, 24, "Late Cycle", buyerLateCycleDivergence ? "Yes" : "—", buyerLateCycleDivergence ? color.new(color.red, 60) : color.new(color.gray, 85))
        f_row(4, 24, "Late Cycle", sellerLateCycleDivergence ? "Yes" : "—", sellerLateCycleDivergence ? color.new(color.red, 60) : color.new(color.gray, 85))
        f_row(0, 25, "Silent Damage", buyerSilentDamage or sellerSilentDamage ? "Damage Building" : "Clean", buyerSilentDamage or sellerSilentDamage ? color.new(color.orange, 65) : color.new(color.gray, 80))
        f_row(2, 25, "Silent Dmg", buyerSilentDamage ? "Yes" : "—", buyerSilentDamage ? color.new(color.orange, 65) : color.new(color.gray, 85))
        f_row(4, 25, "Silent Dmg", sellerSilentDamage ? "Yes" : "—", sellerSilentDamage ? color.new(color.orange, 65) : color.new(color.gray, 85))
        //──────────────────────────────────────
        // 11.7 Debug Rows
        // Research diagnostics are retained
        // until the TVE study is finalized.
        //──────────────────────────────────────
        if showDebug
            f_sectionSides(26, "══ DEBUG | BUY ← → SELL ══", color.new(color.gray, 86))
            f_row(0, 27, "Engine Clarity", str.tostring(signalQuality) + " / 100", f_stateBg(signalQuality))
            f_row(2, 27, "Wave Memory", str.tostring(pWT1, "#.0") + " | " + str.tostring(pWT2, "#.0") + " | " + str.tostring(pWT3, "#.0"), color.new(color.gray, 85))
            f_row(4, 27, "Wave Memory", str.tostring(nWT1, "#.0") + " | " + str.tostring(nWT2, "#.0") + " | " + str.tostring(nWT3, "#.0"), color.new(color.gray, 85))
            f_row(0, 28, "Live / Structure", structurePressure, structurePressureBg)
            f_row(2, 28, "Eff. Ratio", str.tostring(buyerEfficiencyRatioDbg, "#.##"), efficiencyBg)
            f_row(4, 28, "Eff. Ratio", str.tostring(sellerEfficiencyRatioDbg, "#.##"), efficiencyBg)
            f_row(0, 29, "Cumulative Damage", "Buyer / Seller", color.new(color.gray, 85))
            f_row(2, 29, "Buyer Wear", str.tostring(buyerCumDamageDbg, "#.##"), color.new(color.orange, 75))
            f_row(4, 29, "Seller Wear", str.tostring(sellerCumDamageDbg, "#.##"), color.new(color.orange, 75))
//══════════════════════════════════════════════════════════════════════════════
// 12. TVE PLOTS
// White = Trend momentum and lifecycle
// Green / Red = Buyer-seller pressure around equilibrium
// Zero = Balance between buyer and seller pressure
//══════════════════════════════════════════════════════════════════════════════
plot(htfWT, title = "HTF Trend Line", color = color.white, linewidth = 2)
plot(htfMF, title = "HTF Buyer / Seller Pressure", color = htfMF >= 0 ? color.lime : color.red, linewidth = 2)
hline(0, title = "Pressure Equilibrium", color = color.gray, linestyle = hline.style_dashed)
//══════════════════════════════════════════════════════════════════════════════
// 13. KU#9 RESEARCH PLOTS
// Research diagnostics remain available until the study is finalized.
// These plots do not alter production scoring.
//══════════════════════════════════════════════════════════════════════════════
plot(showDebugPlots and showEffV2Raw ? buyerResearchEfficiencyV2Dbg : na, title = "KU#9 Raw Efficiency V2", linewidth = 2)
plot(showDebugPlots and showEffV2MA ? buyerResearchMeanV2Dbg : na, title = "KU#9 Efficiency V2 Rolling Mean", linewidth = 2)
plot(showDebugPlots and showEffV2Norm ? buyerResearchNormV2Dbg : na, title = "KU#9 Efficiency V2 Rolling Normalized", linewidth = 2)
plot(showDebugPlots and showEffV2OldRatio ? buyerResearchOldScoreV2Dbg : na, title = "KU#9 Efficiency V2 Old Ratio Score", linewidth = 2)
plot(showDebugPlots and showEffV2BaselineContext ? buyerResearchBaselineScoreV2Dbg : na, title = "KU#9 V2 Baseline Context", linewidth = 2)
plot(showDebugPlots and showEffV2PeakRetention ? buyerResearchPeakRetentionV2Dbg : na, title = "KU#9 V2 Peak Retention", linewidth = 2)
//══════════════════════════════════════════════════════════════════════════════
// 14. ALERTS
//══════════════════════════════════════════════════════════════════════════════
alertcondition(activeVitality <= 19, title = "Trend Vitality Critical", message = "Trend Vitality is critical on the selected HTF source.")
alertcondition(rapidDecay, title = "Trend Vitality Rapid Decay", message = "Trend Vitality is rapidly deteriorating on the selected HTF source.")
alertcondition(criticalEvent, title = "Critical Vitality + Structural Event", message = "Critical vitality with a structural event detected on the selected HTF source.")
alertcondition(activeDivergence == "Late Cycle", title = "Late Cycle Divergence", message = "Late Cycle Divergence: Power is rising while Efficiency is falling. Force exists, but price is not responding efficiently.")
alertcondition(activeDivergence == "Silent Damage", title = "Silent Damage Accumulating", message = "Silent Damage: Durability is deteriorating while Trend Fuel is holding. Structural damage may be building beneath the surface.")
````

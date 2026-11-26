# Market Momentum Energy [ZurvanEG]

- url: https://www.tradingview.com/script/3iFkhPYU-Market-Momentum-Energy-ZurvanEG/
- type: indicator
- pine_id: PUB;ded2f5cddf204a97b596208e738de0e8
- version: 1.0

## Description

⯁ Market Momentum Energy
◇ Overview
Market Momentum Energy is a directional energy oscillator designed to evaluate whether current market movement has enough strength, participation, and directional conviction to matter. Instead of measuring price change alone, it converts movement into a normalized energy reading that reflects direction, intensity, volatility context, participation, and movement quality.
It helps separate clean directional pressure from noise, low-volume drift, volatility expansion, compression, or late-stage exhaustion. Its purpose is to show whether movement has meaningful energy behind it, whether that energy is expanding or fading, and whether conditions are closer to ignition, weak movement, saturation, or possible reversal pressure.

◈ Core Framework
At its core, the indicator uses a motion-energy model that measures directional movement through price displacement or regression-based slope, then normalizes it against recent volatility for better comparison across regimes, instruments, and timeframes.
The motion reading is shaped through a power curve, while an optional effort layer can modulate it using volume or true range. After that, self-normalization keeps energy, thresholds, dead zones, saturation levels, and signal logic more stable across changing volatility conditions.
The framework also includes quality filtering, final energy smoothing, signal logic, energy bands, divergence detection, optional energy MA, adaptive visuals, candle coloring, signal-volume markers, alerts, and a compact info table.
[image]https://www.tradingview.com/x/vr9n61CX/[/image]
◇ Signals
The signal system highlights energy ignition events. Signals are generated when energy crosses a defined threshold, with controls for quality, saturation, HMA-based short-term direction confirmation, re-arm behavior, and optional alternation.

◇ Signal Volume Markers
The indicator can draw transparent volume-based circles directly on signal candles. Circle size is based on cumulative volume over a user-defined lookback period, making it easier to identify signals that appear after unusually high participation. This feature is most meaningful on markets with reliable volume data.
 [image]https://www.tradingview.com/x/mIVG1bGJ/[/image]
◇ Energy Bands
The energy bands provide statistical context for the current energy reading. They help identify stretched momentum, possible exhaustion zones, or unusually strong directional expansion. To keep the chart clean, bands can appear only when energy gets close to them and remain visible for a few bars after activation.
 [image]https://www.tradingview.com/x/cZY54RBu/[/image]
◇ Dead Zone & Saturation
The dead zone marks areas where energy is too weak to be treated as meaningful. The saturation level marks areas where energy is already strong or potentially overextended. Together, they organize the oscillator into practical states: weak, active, strong, and overextended.

◇ Divergence
The divergence module detects confirmed regular divergence between price and energy. It can help identify cases where price makes new highs or lows while energy fails to confirm. Pivot confirmation and filtering conditions are included to reduce weak or irrelevant divergence marks.
[image]https://www.tradingview.com/x/Djkbzgn8/[/image]
◇ Visual System
The visual layer makes energy state easy to read at a glance. Energy is shown as a directional histogram with optional line view, optional energy MA, adaptive intensity, contraction fading, dead-zone shading, energy bands, candle coloring, and signal-volume circles on the price chart.
The coloring system helps distinguish expanding energy, contracting energy, positive and negative movement, weak zones, saturated conditions, and high-participation signal areas.

◇ Alerts
Configurable alerts are included for bullish signals, bearish signals, bullish divergence, and bearish divergence. They support monitoring and workflow automation, but should still be evaluated with broader market context and risk management.

◇ Info Table
The compact info table summarizes current energy, quality, and market state. It acts as a quick reference panel for identifying dead zone, active direction, or strong energy conditions without inspecting every plot manually.
[image]https://www.tradingview.com/x/j06tEu9w/[/image]
◇ Use Case
Market Momentum Energy is intended for traders who want a clearer way to evaluate directional movement strength. It can help identify momentum ignition, monitor whether energy is expanding or fading, avoid low-energy noise, detect overextended conditions, and add context to possible reversal or continuation setups.
It may be useful for trend-following traders, momentum traders, discretionary price-action traders, and system builders who want a structured energy layer for filtering market conditions.
It helps answer questions such as:
⬦ Is the market moving with enough energy?
⬦ Is the move clean or choppy?
⬦ Is momentum expanding or fading?
⬦ Is energy holding above or below its moving average?
⬦ Did the signal appear after unusually high cumulative volume?
⬦ Is the signal early enough, or already near saturation?
⬦ Is price making a new extreme while energy fails to confirm?
⬦ Is the market in a low-energy dead zone?

◈ Conclusion
Market Momentum Energy is built for traders who want more than a basic momentum oscillator. By combining normalized motion, participation effort, quality filtering, energy bands, divergence detection, final smoothing, signal-volume visualization, adaptive visuals, alerts, and structured signal logic, it provides a broader view of directional market energy.
Rather than simply showing whether price is rising or falling, the indicator focuses on whether movement has enough strength, participation, and directional conviction to matter.
In short, Market Momentum Energy is a practical tool for evaluating the strength, quality, and state of market movement before acting on a trade idea.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZurvanEG
// @version=6 

// In the Name of God of Infinite Time and Space
// ───────────────────────────────────────────────────────────────────────────── ─── ─
//    Title : 𝗠𝗠𝗘 - 𝗠arket 𝗠omentum 𝗘nergy [𝗭urvān𝗘𝗚]
//            Directional energy oscillator that combines volatility-normalized motion,
//            participation effort, and hybrid confidence filtering into a readable
//            measure of market movement energy and directional conviction.
// Language : TradingView's Pine Script® v6
// ───────────────────────────────────────────────────────────────────────────── ─── ─

// #START_REGION
// ▾▾▾▾▾▾▾▾▾▾▾▾▾
const string ltitle = '𝗠𝗠𝗘 - 𝗠arket 𝗠omentum 𝗘nergy [𝗭urvān𝗘𝗚]'
const string stitle = '⧕𝗠𝗠𝗘'
indicator(title=ltitle, shorttitle=stitle, overlay=false, max_labels_count=500)


// ══════════
// >>INPUTS<< ⑴
// ═════ ══ ═

// >0.source
// ──── ── ─
//  main input series used by the motion and quality engines
string      grp_source = ''
float            i_src = input.source(close,   'Source',                      group = grp_source, display = display.none, tooltip = 'Series feeding both motion and quality.')
 
// >1.motion model
// ────────── ── ─
//  directional displacement / slope model that defines raw market motion
string      grp_motion = '1) Motion Model'
int              i_len = input.int   (20,      'Length',                      group = grp_motion, display = display.all,  minval = 2,
               tooltip = 'Primary motion length. Drives displacement, regression slope and quality.')
string  i_velocityMode = input.string("Displacement", 'Velocity Mode',        group = grp_motion, display = display.none, options = ["Displacement", "LinReg Slope"],
               tooltip = 'Displacement = price now vs N bars ago (faster, more reactive). \nLinReg Slope = regression slope (smoother, less jitter). \nBoth share the same volatility baseline.')
int            i_lrLen = input.int   (14,      'LinReg Length',               group = grp_motion, display = display.none, minval = 2,
               tooltip = 'Regression length used only in LinReg Slope mode. Independent from Length.')

// >2.effort
// ──── ── ─
//  optional participation multiplier using volume or range
string      grp_effort = '2) Effort'
bool       i_useEffort = input.bool  (true,    'Use Effort',                  group = grp_effort, display = display.none,
               tooltip = 'Multiplies motion by participation (volume or range). \nDisable for a pure price-motion reading.')
string  i_effortSource = input.string("Auto",  'Effort Source',               group = grp_effort, display = display.none, options = ["Auto", "Volume", "True Range"],
               tooltip = 'Auto uses volume when available, otherwise True Range. \nRange is the safe choice on assets with unreliable volume.')
float      i_effWeight = input.float (0.50,    'Effort Weight',               group = grp_effort, display = display.none, minval = 0.0,  maxval = 1.0, step = 0.05,
               tooltip = 'How strongly effort modulates motion. \n0 disables effort, \n1 = full impact.')

// >3.quality filter
// ──────────── ── ─
//  post-core confidence layer from R² linearity and ER efficiency
string        grp_qual = '3) Quality Filter'
bool      i_useQuality = input.bool  (true,    'Use Hybrid Quality Filter',   group = grp_qual,   display = display.none,
               tooltip = 'Applies a post-core confidence layer from R² (linearity) and ER (efficiency). \nSuppresses choppy, low-conviction motion.')
float           i_qMix = input.float (0.35,    'R² / ER Mix',                 group = grp_qual,   display = display.none, minval = 0.0,  maxval = 1.0,  step = 0.05,
               tooltip = '1 = pure R², \n0 = pure ER. \nControls the blend between linearity and efficiency before quality scaling.')
string    i_qScaleMode = input.string("Normalized", 'Quality Scale',          group = grp_qual,   display = display.none, options = ["Raw", "Normalized"],
               tooltip = 'Raw keeps the original absolute R²/ER blend behavior. \nNormalized scales the blend relative to its recent average, making Quality Gate more stable when changing R² / ER Mix.')
float        i_qWeight = input.float (0.70,    'Quality Weight',              group = grp_qual,   display = display.none, minval = 0.0,  maxval = 1.0,  step = 0.05,
               tooltip = 'How strongly quality scales final energy. \n0 = ignored, \n1 = full effect.')

// >4.signals
// ───── ── ─
//  ignition state machine with re-arm, direction-filter retry, and optional alternation
string      grp_signal = '4) Signals'
bool           i_sigOn = input.bool  (true,    'Enable Signal',               group = grp_signal, display = display.none,
               tooltip = 'Master switch for ignition signals and signal alerts.')
float   i_sigThreshold = input.float (0.45,    'Signal Threshold',            group = grp_signal, display = display.none, minval = 0.05, step = 0.01,
               tooltip = 'The single ignition level energy must cross. \nAbove noise, below saturation.')

// >5.divergence
// ──────── ── ─
//  confirmed regular price/energy divergence at pivots with distance guard
string         grp_div = '5) Divergence'
bool           i_divOn = input.bool  (true,    'Divergence Detection',        group = grp_div,    display = display.none,
               tooltip = 'Detects confirmed regular price/energy divergence at pivots.')
int          i_divLook = input.int   (12,      'Divergence Pivot Lookback',   group = grp_div,    display = display.none, minval = 3,
               tooltip = 'Left/right bars to confirm a pivot. \nHigher = slower but cleaner.')
bool   i_divReqQuality = input.bool  (true,    'Require Pivot Quality',       group = grp_div,    display = display.none,
               tooltip = 'Requires selected quality at the pivot to exceed the Quality Gate.')

// >6.display
// ───── ── ─
//  dead zone, saturation, energy envelopes, optional plots, chart candle coloring and compact status table
string        grp_view = '6) Display'
bool    i_showDeadBand = input.bool  (true,    'Show Dead Zone',              group = grp_view,  display = display.none,
               tooltip = 'Shades the dead zone band for quick visual reference.')
float       i_deadZone = input.float (0.2,     'Dead Zone',                   group = grp_view, display = display.none, minval = 0.0,  step = 0.01,
               tooltip = 'Energy magnitude treated as flat/noise.')
bool       i_showBands = input.bool  (true,    'Show Energy Bands',           group = grp_view,  display = display.none,
               tooltip = 'Shows statistical envelope of recent energy using percentile ranks.')
float i_bandActivation = input.float (0.80,    'Visibility Level',            group = grp_view,  display = display.none, minval = 0.10, maxval = 1.00, step = 0.05,
               tooltip = 'Shows the percentile band when energy reaches this fraction of the band.')
bool    i_showEnergyMA = input.bool  (true,    'Show Energy MA',              group = grp_view,   display = display.none,
               tooltip = 'Shows a moving average of the reported final energy.')
int      i_energyMALen = input.int   (5,       'Energy MA Length',            group = grp_view,   display = display.none, minval = 1,
               tooltip = 'Moving average length applied to the reported final energy. 1 = no additional MA smoothing.')
string  i_energyMAType = input.string("RMA",   'Energy MA Type',              group = grp_view,   display = display.none, options = ["SMA", "EMA", "RMA", "WMA"],
               tooltip = 'Moving average type used for the final energy MA.')
bool     i_showCandles = input.bool  (true,    'Color Candles On Chart',      group = grp_view,   display = display.none,
               tooltip = 'Colors main chart candles by energy color.')
bool  i_showSigVolMark = input.bool  (true,    'Show Signal Volume Circles',  group = grp_view,   display = display.none,
               tooltip = 'Draws a transparent circle on the signal candle.')
int        i_sigVolLen = input.int   (20,      'Volume Accumulation Length',  group = grp_view,   display = display.none, minval = 1,
               tooltip = 'Number of previous bars used to accumulate volume before a signal.')
int      i_sigVolAlpha = input.int   (70,      'Circle Transparency',         group = grp_view,   display = display.none, minval = 0,    maxval = 95,
               tooltip = 'Transparency of the signal volume circle.')
bool       i_showTable = input.bool  (true,    'Show Info Table',             group = grp_view,   display = display.none,
               tooltip = 'Shows a compact status table on the main chart.')
string      i_tablePos = input.string("Bottom Right", 'Table Position',       group = grp_view,   display = display.none, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"])
string     i_tableSize = input.string("Small", 'Table Size',                  group = grp_view,   display = display.none, options = ["Tiny", "Small", "Normal", "Large"])

// >7.alerts
// ──── ── ─
//  optional alert switches for signals and divergence events
string      grp_alerts = '7) Alerts'
bool       i_alertLong = input.bool(true,      'Long   ',                     group = grp_alerts, display = display.none, inline = 'alert0')
bool      i_alertShort = input.bool(true,      'Short Signal',                group = grp_alerts, display = display.none, inline = 'alert0',
               tooltip = 'Enables alert condition for long and short signals events.')
bool    i_alertBullDiv = input.bool(true,      'Bullish       ',              group = grp_alerts, display = display.none, inline = 'alert1')
bool    i_alertBearDiv = input.bool(true,      'Bearish Divergence',          group = grp_alerts, display = display.none, inline = 'alert1',
               tooltip = 'Enables alert condition for bullish and bearish divergences events.')


// ═════════════════════
// >>UTILITY FUNCTIONS<< ⑵
// ════════════════ ══ ═ 

// @function  clamp a float between lo and hi.
// @param     x   value to clamp
// @param     lo  lower bound
// @param     hi  upper bound
// @returns   clamped float
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

// @function  clamp a float to the [0, 1] range.
// @param     x  value to clamp
// @returns   clamped float in [0, 1]
f_clamp01(float x) =>
    f_clamp(x, 0.0, 1.0)

// @function  current bar true range.
// @returns   true range value
f_trueRange() =>
    math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))

// @function  Kaufman efficiency ratio of a series.
// @param     x       source series
// @param     length  lookback length
// @returns   efficiency ratio in [0, 1]
f_er(series float x, int length) =>
    float _net  = math.abs(x - x[length])
    float _path = math.sum(math.abs(ta.change(x)), length)
    _path > 0.0 ? f_clamp01(_net / _path) : 0.0

// @function  blended quality from R² (linearity) and ER (efficiency).
// @param     x       source series
// @param     length  lookback length
// @param     mix     1 = pure R², 0 = pure ER
// @returns   blended quality in [0, 1]
f_qualityBlend(series float x, int length, float mix) =>
    float _r  = ta.correlation(x, bar_index, length)
    float _r2 = na(_r) ? 0.0 : f_clamp01(_r * _r)
    float _er = f_er(x, length)
    f_clamp01(math.pow(_r2, mix) * math.pow(_er, 1.0 - mix))

// @function  volatility-normalized directional velocity.
// @param     x                  source series
// @param     displacementLength  bars for displacement mode
// @param     regressionLength    bars for linreg slope mode
// @param     baselineLength      volatility baseline window
// @param     mode               "Displacement" or "LinReg Slope"
// @param     floorMult          baseline floor multiplier
// @returns   normalized velocity (signed)
f_velocity(series float x, int displacementLength, int regressionLength, int baselineLength, string mode, float floorMult) =>
    float _chVolBase  = ta.stdev(ta.change(x), baselineLength)
    float _avgAbsBase = ta.sma(math.abs(ta.change(x)), baselineLength)
    float _floorBase  = _avgAbsBase * floorMult

    float _displacement = x - x[displacementLength]
    float _lrSlope      = ta.linreg(x, regressionLength, 0) - ta.linreg(x, regressionLength, 1)

    float _normBase  = math.max(_chVolBase, _floorBase)
    float _dispNorm  = _normBase * math.sqrt(displacementLength)
    float _slopeNorm = _normBase / math.sqrt(regressionLength)

    mode == "LinReg Slope" ?
         _slopeNorm > 0.0 ? _lrSlope / _slopeNorm : 0.0 :
         _dispNorm > 0.0 ? _displacement / _dispNorm : 0.0

// @function  participation multiplier from volume or range.
// @param     referenceLength  averaging window
// @param     sourceMode       "Auto", "Volume" or "True Range"
// @param     cap              max normalized effort
// @param     weight           modulation strength (0 disables)
// @param     enabled          master toggle
// @returns   effort multiplier (>= 0.10)
f_effort(int referenceLength, string sourceMode, float cap, float weight, bool enabled) =>
    float _result = 1.0
    if enabled
        bool  _hasVol     = not na(volume) and volume > 0.0
        bool  _useVolume  = sourceMode == "Volume" or (sourceMode == "Auto" and _hasVol)
        float _rawEffort  = _useVolume ? volume : f_trueRange()
        float _avgEffort  = ta.sma(_rawEffort, referenceLength)
        float _effortNorm = _avgEffort > 0.0 ? math.min(_rawEffort / _avgEffort, cap) : 1.0
        _result := 1.0 + weight * (_effortNorm - 1.0)
    math.max(0.10, _result)

// @function  map table position string to a position constant.
// @param     p  position label
// @returns   position.* constant
f_tablePos(string p) =>
     p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left"  ? position.bottom_left  :
     p == "Middle Right" ? position.middle_right :
     position.middle_left

// @function  map table size string to a size constant.
// @param     s  size label
// @returns   size.* constant
f_tableSize(string s) =>
     s == "Tiny"  ? size.tiny  :
     s == "Small" ? size.small :
     s == "Large" ? size.large :
     size.normal

// @function  single source of truth for energy.
// @returns   [energy, selectedQuality, qualityFactor]
f_compute(
     series float x,
     int displacementLength, int regressionLength, int baselineLength, int referenceLength,
     string mode, float floorMult, int velSmoothLen, float power,
     bool enableEffort, string effortMode, float effortMax, float effortImpact,
     int energyNormLength, float scaleFloor,
     bool enableQuality, float qualityMix, string qualityScaleMode,
     float qualityNormCenter, float qualityGate, float qualityPower, float qualityWeight, int qualitySmooth) =>

    // motion
    float _velRaw = f_velocity(x, displacementLength, regressionLength, baselineLength, mode, floorMult)
    float _vel    = velSmoothLen > 1 ? ta.ema(_velRaw, velSmoothLen) : _velRaw
    float _dir    = _vel > 0.0 ? 1.0 : _vel < 0.0 ? -1.0 : 0.0
    float _motion = _dir * math.pow(math.abs(_vel), power)

    // raw energy + self-normalization
    float _effortMod = f_effort(referenceLength, effortMode, effortMax, effortImpact, enableEffort)
    float _rawEnergy = _motion * _effortMod

    float _scaleFast  = ta.sma(math.abs(_rawEnergy), energyNormLength)
    float _scaleSlow  = ta.sma(math.abs(_rawEnergy), referenceLength) * scaleFloor
    float _scale      = math.max(_scaleFast, _scaleSlow)
    float _coreEnergy = _scale > 0.0 ? _rawEnergy / _scale : _rawEnergy

    // quality layer (length follows the active velocity mode)
    int   _qLen   = mode == "LinReg Slope" ? regressionLength : displacementLength
    float _qBlend = f_qualityBlend(x, _qLen, qualityMix)
    float _qAvg   = ta.sma(_qBlend, energyNormLength)

    float _qScaled =
         qualityScaleMode == "Normalized" ?
         f_clamp01((_qBlend / math.max(_qAvg, 0.01)) * qualityNormCenter) :
         _qBlend

    float _qGated  = _qScaled < qualityGate ? 0.0 : _qScaled
    float _qBase   = enableQuality ? 1.0 - qualityWeight * (1.0 - f_clamp01(math.pow(_qGated, qualityPower))) : 1.0
    float _qFactor = qualitySmooth > 1 ? ta.ema(_qBase, qualitySmooth) : _qBase

    float _energy = _coreEnergy * _qFactor
    [_energy, _qScaled, _qFactor]

// @function  apply a selected moving average to a source series.
// @param     x     source series
// @param     len   moving average length
// @param     mode  moving average type
// @returns   smoothed series
f_ma(series float x, int len, string mode) =>
     mode == "SMA" ? ta.sma(x, len) :
     mode == "RMA" ? ta.rma(x, len) :
     mode == "WMA" ? ta.wma(x, len) :
     ta.ema(x, len)

// @function  map a normalized volume ratio to a label size.
// @param     ratio       cumulative volume ratio
// @param     tinyLevel   upper bound for tiny size
// @param     smallLevel  upper bound for small size
// @param     largeLevel  lower bound for large size
// @param     hugeLevel   lower bound for huge size
// @returns   size.* constant
f_volMarkerSize(float ratio, float tinyLevel, float smallLevel, float largeLevel, float hugeLevel) =>
    ratio >= hugeLevel   ? size.huge   :
     ratio >= largeLevel ? size.large  :
     ratio >= smallLevel ? size.normal :
     ratio >= tinyLevel  ? size.small  :
     size.tiny


// ════════════════════
// >>CORE CALCULATION<< ⑶
// ═══════════════ ══ ═ 

[energyRaw, qRaw, qFactor] =
     f_compute(
         i_src, i_len, i_lrLen, 70, 144, i_velocityMode, 0.05, 4, 1.0, i_useEffort, i_effortSource, 1.0, i_effWeight,
         70, 0.4, i_useQuality, i_qMix, i_qScaleMode, 0.5, 0.7, 2.0, i_qWeight, 3)

// Final reported energy.
// All downstream logic uses this smoothed value: signals, divergence, bands, colors, table and alerts.
float energy      = f_ma(energyRaw, 4, "RMA")
float energySlope = energy - energy[1]
float energyMA    = i_showEnergyMA and i_energyMALen > 1 ? f_ma(energy, i_energyMALen, i_energyMAType) : na

float upperBand = i_showBands ? ta.rma(ta.percentile_nearest_rank(energy, 233, 99.5),         3) : na
float lowerBand = i_showBands ? ta.rma(ta.percentile_nearest_rank(energy, 233, 100.0 - 99.5), 3) : na


// ══════════
// >>SIGNAL<< ⑷
// ═════ ══ ═ 

bool qualityOk   = qRaw >= 0.2
bool notSatLong  = energy < 3
bool notSatShort = energy > -3

float sigDirMA      = ta.hma(i_src, 7)
float sigDir        = sigDirMA - sigDirMA[1]
bool  sigDirLongOk  = sigDir > 0.0
bool  sigDirShortOk = sigDir < 0.0

var bool longArmed  = true
var bool shortArmed = true

if energy <= -0.3
    longArmed := true
if energy >= 0.3
    shortArmed := true

bool crossUp   = ta.crossover(energy, i_sigThreshold)
bool crossDown = ta.crossunder(energy, -i_sigThreshold)

var int lastSignalDir = 0
bool altLongOk  = lastSignalDir != 1
bool altShortOk = lastSignalDir != -1

bool longCandidate  = i_sigOn and longArmed  and crossUp   and qualityOk and notSatLong  and altLongOk
bool shortCandidate = i_sigOn and shortArmed and crossDown and qualityOk and notSatShort and altShortOk

var int longDirWait  = 0
var int shortDirWait = 0

bool longSignal  = false
bool shortSignal = false

if longCandidate
    if sigDirLongOk
        longSignal := true
    else
        longDirWait := 3

if shortCandidate
    if sigDirShortOk
        shortSignal := true
    else
        shortDirWait := 3

bool longRetryOk  = i_sigOn and longArmed  and longDirWait  > 0 and energy > i_sigThreshold  and qualityOk and notSatLong  and sigDirLongOk  and altLongOk
bool shortRetryOk = i_sigOn and shortArmed and shortDirWait > 0 and energy < -i_sigThreshold and qualityOk and notSatShort and sigDirShortOk and altShortOk

if not longSignal and longRetryOk
    longSignal := true

if not shortSignal and shortRetryOk
    shortSignal := true

if longDirWait > 0
    longDirWait -= 1

if shortDirWait > 0
    shortDirWait -= 1

if longSignal
    longArmed     := false
    longDirWait   := 0
    lastSignalDir := 1

if shortSignal
    shortArmed     := false
    shortDirWait   := 0
    lastSignalDir := -1


// ══════════════
// >>DIVERGENCE<< ⑸
// ═════════ ══ ═ 

bool bullDiv = false
bool bearDiv = false

var float lastPriceHigh  = na
var float lastEnergyHigh = na
var int   lastHighBar    = na
var float lastPriceLow   = na
var float lastEnergyLow  = na
var int   lastLowBar     = na

int maxDivGap = i_divLook * 8

if i_divOn
    float _priceHighPivot = ta.pivothigh(close, i_divLook, i_divLook)
    float _priceLowPivot  = ta.pivotlow(close, i_divLook, i_divLook)

    float _energyAtPivot  = energy[i_divLook]
    float _qualityAtPivot = qRaw[i_divLook]
    int   _pivotBar       = bar_index - i_divLook

    bool _qualityPivotOk = not i_divReqQuality or _qualityAtPivot >= 0.7

    if not na(_priceHighPivot) and _energyAtPivot > 0.1 and _qualityPivotOk
        bool _gapOk = not na(lastHighBar) and (_pivotBar - lastHighBar) <= maxDivGap
        bearDiv :=
             _gapOk and
             not na(lastPriceHigh) and not na(lastEnergyHigh) and
             _priceHighPivot > lastPriceHigh and
             _energyAtPivot < lastEnergyHigh

        lastPriceHigh  := _priceHighPivot
        lastEnergyHigh := _energyAtPivot
        lastHighBar    := _pivotBar

    if not na(_priceLowPivot) and _energyAtPivot < -0.1 and _qualityPivotOk
        bool _gapOk = not na(lastLowBar) and (_pivotBar - lastLowBar) <= maxDivGap
        bullDiv :=
             _gapOk and
             not na(lastPriceLow) and not na(lastEnergyLow) and
             _priceLowPivot < lastPriceLow and
             _energyAtPivot > lastEnergyLow

        lastPriceLow  := _priceLowPivot
        lastEnergyLow := _energyAtPivot
        lastLowBar    := _pivotBar


// ═════════
// >>PLOTS<< ⑹
// ════ ══ ═

// >a) colors
// ───── ── ─
bool  inDead         = math.abs(energy) <= i_deadZone
float energyStrength = f_clamp01(math.abs(energy) / 3)

int adaptAlpha = int(math.max(0.0, 70.0 - energyStrength * 70.0))

color baseCol =
     inDead       ? #787b8680 :
     energy >= 3  ? #00f47d :
     energy <= -3 ? #ff1a46 :
     energy > 0.0 ? #26dc83 :
     #ff2952

color levelColor = inDead ? #787b8680 : color.new(baseCol, adaptAlpha)

bool posExpanding = energy > 0.0 and energySlope >= 0.0
bool negExpanding = energy < 0.0 and energySlope <= 0.0
bool expanding    = posExpanding or negExpanding

bool posContracting = energy > 0.0 and energySlope < 0.0
bool negContracting = energy < 0.0 and energySlope > 0.0
bool contracting    = posContracting or negContracting

float contractStrength = math.min(energyStrength, 0.65)

color contractionColor =
     energy > 0.0 ? color.from_gradient(contractStrength, 0.0, 1.0, #787b8680, #26dc83) :
     energy < 0.0 ? color.from_gradient(contractStrength, 0.0, 1.0, #787b8680, #ff2952) :
     #787b8680

color directionalColor =
     inDead      ? #787b8680 :
     expanding   ? levelColor :
     contracting ? color.new(contractionColor, 50) :
     levelColor

// >b) core series
// ────────── ── ─
plot(energy,   "Energy",           color = directionalColor, style = plot.style_columns)
plot(energyMA, "Energy MA",        color = #ca5fe580, linewidth = 1)

// >c) bands
// ──── ── ─
bool upperBandValid = i_showBands and not na(upperBand) and upperBand > 0.0
bool lowerBandValid = i_showBands and not na(lowerBand) and lowerBand < 0.0

bool upperNearBand = upperBandValid and energy >= upperBand * i_bandActivation
bool lowerNearBand = lowerBandValid and energy <= lowerBand * i_bandActivation

var int upperBandHold = 0
var int lowerBandHold = 0

if upperNearBand
    upperBandHold := 5
else if upperBandHold > 0
    upperBandHold -= 1

if lowerNearBand
    lowerBandHold := 5
else if lowerBandHold > 0
    lowerBandHold -= 1

bool showUpperBand = i_showBands and (upperNearBand or upperBandHold > 0)
bool showLowerBand = i_showBands and (lowerNearBand or lowerBandHold > 0)

upperBandPlot = plot(showUpperBand ? upperBand : na, "Upper Band", color = color.new(color.orange, 50), linewidth = 2, style = plot.style_linebr, display = display.pane)
lowerBandPlot = plot(showLowerBand ? lowerBand : na, "Lower Band", color = color.new(color.orange, 50), linewidth = 2, style = plot.style_linebr, display = display.pane)

upperZeroPlot = plot(showUpperBand ? 0.0 : na, "Upper Band Zero", color = na, display = display.none)
lowerZeroPlot = plot(showLowerBand ? 0.0 : na, "Lower Band Zero", color = na, display = display.none)

fill(upperBandPlot, upperZeroPlot, color = showUpperBand ? color.new(color.orange, 97) : na, title = "Upper Band To Zero Fill")
fill(lowerBandPlot, lowerZeroPlot, color = showLowerBand ? color.new(color.orange, 97) : na, title = "Lower Band To Zero Fill")

// >d) dead zone band
// ───────────── ── ─
dzTop = plot(i_showDeadBand ?  i_deadZone : na, "Dead Zone Top", color = na, display = display.none)
dzBot = plot(i_showDeadBand ? -i_deadZone : na, "Dead Zone Bot", color = na, display = display.none)
fill(dzTop, dzBot, color = i_showDeadBand ? color.new(color.gray, 90) : na, title = "Dead Zone Band")

hline(0.0,    "Zero",         color = color.new(color.gray, 35))

// >e) signals + divergence + candles
// ───────────────────────────── ── ─
plotshape(longSignal,  title = "Long Signal",        style = shape.triangleup,   location = location.bottom,   color = color.new(#00f47d, 30), size = size.tiny, display = display.pane)
plotshape(shortSignal, title = "Short Signal",       style = shape.triangledown, location = location.top,      color = color.new(#ff1a46, 30), size = size.tiny, display = display.pane)

plotshape(bullDiv,     title = "Bullish Divergence", style = shape.diamond,      location = location.belowbar, color = #00f47d, size = size.tiny, offset = -i_divLook, text = "DIV", textcolor = #00f47d, display = display.pane, force_overlay = true)
plotshape(bearDiv,     title = "Bearish Divergence", style = shape.diamond,      location = location.abovebar, color = #ff1a46, size = size.tiny, offset = -i_divLook, text = "DIV", textcolor = #ff1a46, display = display.pane, force_overlay = true)

plotcandle(
     i_showCandles ? open  : na,
     i_showCandles ? high  : na,
     i_showCandles ? low   : na,
     i_showCandles ? close : na,
     title       = "Chart Energy Candles",
     color       = directionalColor,
     wickcolor   = directionalColor,
     bordercolor = directionalColor,
     display = display.pane, force_overlay = true)

// >f) signal volume markers
// ───────────────── ── ─
float sigVolRaw   = na(volume) ? 0.0 : volume
float sigVolSum   = math.sum(sigVolRaw, i_sigVolLen)
float sigVolAvg   = ta.sma(sigVolSum, 233)
float sigVolRatio = sigVolAvg > 0.0 ? sigVolSum / sigVolAvg : 1.0

string sigVolSize    = f_volMarkerSize(sigVolRatio, 0.75, 1.5, 2, 3)
float  sigCirclePrice = (open + close) * 0.5

if i_showSigVolMark and longSignal
    label.new(
         bar_index,
         sigCirclePrice,
         xloc          = xloc.bar_index,
         style         = label.style_circle,
         color         = color.new(#00f47d, i_sigVolAlpha),
         textcolor     = color.new(color.white, 0),
         size          = sigVolSize,
         textalign     = text.align_center,
         tooltip       = "Buy signal\nVolume ratio: " + str.tostring(sigVolRatio, "#.##") + "x",
         force_overlay = true)

if i_showSigVolMark and shortSignal
    label.new(
         bar_index,
         sigCirclePrice,
         xloc          = xloc.bar_index,
         style         = label.style_circle,
         color         = color.new(#ff1a46, i_sigVolAlpha),
         textcolor     = color.new(color.white, 0),
         size          = sigVolSize,
         textalign     = text.align_center,
         tooltip       = "Sell signal\nVolume ratio: " + str.tostring(sigVolRatio, "#.##") + "x",
         force_overlay = true)


// ══════════════
// >>INFO TABLE<< ⑺
// ═════════ ══ ═ 

var table infoTable = table.new(f_tablePos(i_tablePos), 2, 3, border_width = 1, border_color = color.new(color.gray, 75), force_overlay = true)

if i_showTable and barstate.islast
    table.clear(infoTable, 0, 0, 1, 2)

    _txtSize = f_tableSize(i_tableSize)
    _tableBg = color.new(color.blue, 93)

    string _stateText =
         inDead       ? "DEAD" :
         energy >= 3  ? "STRONG UP" :
         energy <= -3 ? "STRONG DOWN" :
         energy > 0.0 ? "UP" :
         "DOWN"

    color _stateColor = inDead ? color.gray : energy > 0.0 ? #00f47d : #ff1a46
    color _qColor     = qRaw >= 0.7 ? color.white : color.gray

    table.cell(infoTable, 0, 0, "Energy", text_color = color.white, bgcolor = _tableBg, text_size = _txtSize,
                 tooltip = "Final normalized energy after quality. Sign = direction, magnitude = strength.")
    table.cell(infoTable, 1, 0, str.tostring(energy, "#.###"), text_color = _stateColor, bgcolor = _tableBg, text_size = _txtSize,
                 tooltip = "Current final energy value.")

    table.cell(infoTable, 0, 1, "Quality", text_color = color.white, bgcolor = _tableBg, text_size = _txtSize,
                 tooltip = "Selected quality / final quality factor. Selected quality is Raw or Normalized depending on Quality Scale; factor is the smoothed weight applied to energy.")
    table.cell(infoTable, 1, 1, str.tostring(qRaw, "#.##") + " / " + str.tostring(qFactor, "#.##"), text_color = _qColor, bgcolor = _tableBg, text_size = _txtSize,
                 tooltip = "Left = selected quality value. Right = final quality factor used to scale energy.")

    table.cell(infoTable, 0, 2, "State", text_color = color.white, bgcolor = _tableBg, text_size = _txtSize,
                 tooltip = "Discrete regime: DEAD inside the dead zone, UP/DOWN directional, STRONG when beyond saturation.")
    table.cell(infoTable, 1, 2, _stateText, text_color = _stateColor, bgcolor = _tableBg, text_size = _txtSize,
                 tooltip = "Current energy state based on dead zone and saturation levels.")


// ══════════
// >>ALERTS<< ⑻
// ═════ ══ ═

alertcondition(i_alertLong    and longSignal,  "Long Signal",        "Market Momentum Energy: Long Signal")
alertcondition(i_alertShort   and shortSignal, "Short Signal",       "Market Momentum Energy: Short Signal")
alertcondition(i_alertBullDiv and bullDiv,     "Bullish Divergence", "Market Momentum Energy: Bullish Divergence")
alertcondition(i_alertBearDiv and bearDiv,     "Bearish Divergence", "Market Momentum Energy: Bearish Divergence")
// ▴▴▴▴▴▴▴▴▴▴▴
// #END REGION
````

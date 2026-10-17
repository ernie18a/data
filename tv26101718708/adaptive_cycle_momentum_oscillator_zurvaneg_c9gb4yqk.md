# Adaptive Cycle Momentum Oscillator [ZurvanEG]

- url: https://www.tradingview.com/script/c9GB4Yqk-Adaptive-Cycle-Momentum-Oscillator-ZurvanEG/
- type: indicator
- pine_id: PUB;617cf7a137c84a6288fe3d298520a54e
- version: 1.0

## Description

⯁ Adaptive Cycle Momentum Oscillator
◇ Overview
MOM is a cycle-adaptive momentum oscillator built to present market direction, strength, fatigue, volatility compression and saturation within one coherent framework.
Unlike conventional momentum oscillators that apply the same lookback to every market condition, MOM can adjust its momentum window to the market’s active rhythm. This allows its response to become faster or slower as market behaviour changes, while a fixed-length mode remains available for users who require consistent settings.
Beyond measuring momentum, MOM adds context to the reading. It distinguishes strengthening movement from fading pressure, reduces the influence of momentum formed during volatility compression, identifies statistically unusual momentum zones, and detects confirmed divergence structures.
The objective is not to produce more signals or predict every reversal. It is to provide a cleaner and more informative view of momentum—showing not only its direction, but also the conditions under which it is developing.

◈ Key Features
◇ Adaptive Momentum
Automatically adjusts the momentum lookback as market rhythm changes. Fixed mode can be selected whenever a constant length is preferred.
◇ Momentum Regime
Classifies momentum as bullish, bearish or neutral. Separate entry and exit levels reduce unstable regime switching around the dead zone.
[image]https://www.tradingview.com/x/3qZAvdwG/[/image]
◇ Strength & Fatigue
The line gradient shows direction and magnitude, while color strength distinguishes expanding momentum from momentum fading toward zero.
◇ Volatility Squeeze
Detects compressed volatility and reduces momentum produced inside quiet conditions. Squeeze intensity can also be displayed as a variable background.
[image]https://www.tradingview.com/x/DbminkSv/[/image]
 ◇ Saturation Bands
Adaptive upper and lower bands identify momentum readings that are extreme relative to the oscillator’s own recent behavior. They should be treated as saturation zones, not automatic reversal signals.
 [image]https://www.tradingview.com/x/GvpwXTIl/[/image]
◇ Divergence
Detects confirmed regular and hidden bullish or bearish divergence. Signals can optionally be restricted to pivots occurring beyond the saturation bands to filter weaker mid-range structures.
 [image]https://www.tradingview.com/x/sIOohw4r/[/image]
◇ Visuals & Information
Optional candle coloring transfers the oscillator’s momentum gradient to the main chart. A compact table displays the current regime, momentum value and slope state, with optional cycle, length, squeeze and divergence diagnostics.
◇ Alerts
Independent alerts are available for:
⬦ Bullish and bearish regime shifts
⬦ Upper and lower saturation contacts
⬦ Squeeze entry and release
⬦ Confirmed bullish and bearish divergence

◈ Interpretation
Adaptive Cycle Momentum Oscillator helps answer:
⬦ Is momentum bullish, bearish or neutral?
⬦ Is the current move strengthening or fading?
⬦ Was momentum produced during expansion or compression?
⬦ Is the reading unusually saturated for this market?
⬦ Has a meaningful divergence been confirmed?

◈ Notes
⬦ Adaptive mode requires sufficient historical data for cycle estimation.
⬦ Divergences appear after pivot confirmation and are therefore delayed by design.
⬦ Saturation does not guarantee reversal, especially during strong trends.
⬦ Squeeze attenuation provides context; it does not predict breakout direction.

◈ Conclusion
Adaptive Cycle Momentum Oscillator is designed as a complete momentum-analysis framework rather than a simple oscillator or signal generator. It combines adaptive measurement, stable directional regimes, strength and fatigue colouring, volatility context, dynamic saturation bands and confirmed divergence in a single visual system.
By adapting to market rhythm and evaluating momentum within its surrounding conditions, MOM helps separate meaningful directional pressure from weak movement produced inside noise or compression. Its visual structure is intended to make changes in direction, intensity and exhaustion recognizable without requiring several overlapping indicators.
MOM does not attempt to replace price structure, risk management or trading confirmation. Its role is to provide a clearer and more consistent momentum perspective that can support trend analysis, pullback evaluation, saturation monitoring and divergence assessment across different instruments and timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZurvanEG
// @version=6 
  
// In the Name of God of Infinite Time and Space
// ──────────────────────────────────────────────────────────────────────────────── ── ─
//    Title : 𝗠𝗢𝗠 - 𝗔daptive 𝗖ycle 𝗠omentum 𝗢scillator [𝗭urvān𝗘𝗚]
//            A cycle-adaptive momentum oscillator that dynamically adjusts its lookback
//            to market conditions, reduces the influence of low-volatility movement,
//            identifies directional regimes, and evaluates momentum extremes through
//            adaptive percentile bands.
// Language : TradingView's Pine Script® v6
// ──────────────────────────────────────────────────────────────────────────────── ── ─

// #START_REGION
// ▾▾▾▾▾▾▾▾▾▾▾▾▾
const string ltitle = '𝗠𝗢𝗠 - 𝗔daptive 𝗖ycle 𝗠omentum 𝗢scillator [𝗭urvān𝗘𝗚]'
const string stitle = '⧕𝗠𝗢𝗠'
indicator(title = ltitle, shorttitle = stitle, overlay = false, format = format.price, precision = 2, max_lines_count = 500)


// ────────
// >INPUTS< ⑴
// ─────▾──
string g_cor            = 'Momentum Engine'
float  i_source         = input.source(close,      'Source',                     group = g_cor, display = display.none,                                          tooltip = '')
string i_lengthMode     = input.string('Adaptive', 'Length Mode',                group = g_cor, display = display.all,  options = ['Adaptive', 'Fixed'],         tooltip = '⬩ ADAPTIVE derives the momentum lookback from the dominant market cycle.\n⬩ FIXED uses a constant lookback.')
int    i_fixedLength    = input.int   (14,         'Fixed Length',               group = g_cor, display = display.none, minval = 2,   maxval = 500,              tooltip = 'Constant lookback used when Length Mode is FIXED.',                           active = i_lengthMode == 'Fixed')
int    i_cycleMin       = input.int   (8,          'Minimum Cycle Period',       group = g_cor, display = display.none, minval = 6,   maxval = 47,               tooltip = 'Shortest cycle length used when Length Mode is ADAPTIVE.',                    active = i_lengthMode == 'Adaptive')
int    i_cycleMax       = input.int   (34,         'Maximum Cycle Period',       group = g_cor, display = display.none, minval = 7,   maxval = 48,               tooltip = 'Longest cycle length used when Length Mode is ADAPTIVE.',                     active = i_lengthMode == 'Adaptive')
float  i_cycleMult      = input.float (1.1,        'Period Multiplier',          group = g_cor, display = display.none, minval = 0.1, maxval = 5.0, step = 0.05, tooltip = 'Scales the validated cycle period before it becomes the momentum lookback.',  active = i_lengthMode == 'Adaptive')
bool   adaptiveMode     = i_lengthMode == 'Adaptive'
string g_sqz            = 'Volatility Squeeze'
bool   i_squeezeOn      = input.bool  (true,       'Squeeze Attenuation',        group = g_sqz, display = display.none,                                          tooltip = 'Measures historically low relative volatility from Fast ATR / Slow ATR and reduces momentum magnitude during compressed conditions.')
int    i_squeezeFast    = input.int   (8,          'Fast ATR Length',            group = g_sqz, display = display.none, minval = 2,   maxval = 100,              tooltip = 'ATR length representing current volatility.\nIt must be smaller than Slow ATR Length.', active = i_squeezeOn)
int    i_squeezeSlow    = input.int   (34,         'Slow ATR Length',            group = g_sqz, display = display.none, minval = 10,  maxval = 500,              tooltip = 'ATR length representing baseline volatility.',                                          active = i_squeezeOn)
string g_div            = 'Divergence'
bool   i_divShow        = input.bool  (true,       'Show Divergence',            group = g_div, display = display.none, inline = 'div1',                         tooltip = '')
bool   i_divLines       = input.bool  (false,      'Connect Pivots',             group = g_div, display = display.none, inline = 'div1',                         tooltip = 'Draws the line joining the two momentum pivots.', active = i_divShow)
bool   i_divRegular     = input.bool  (true,       'Regular',                    group = g_div, display = display.none, inline = 'div2',                         tooltip = '', active = i_divShow)
bool   i_divHidden      = input.bool  (false,      'Hidden',                     group = g_div, display = display.none, inline = 'div2',                         tooltip = '', active = i_divShow)
string i_divBandMode    = input.string('Any Pivot','Saturation Band Filter',     group = g_div, display = display.none,                                          tooltip = 'Restricts divergence to pivots located beyond the adaptive envelope.\n⬩ OFF accepts every pivot.\n⬩ LATEST PIVOT requires only the confirming pivot to sit outside its band.\n⬩ ANY PIVOT accepts the pair when at least one of the two pivots is outside.\n⬩ BOTH PIVOTS is the strictest mode and keeps only fully saturated structures.', active = i_divShow,
                options = ['Off', 'Latest Pivot', 'Any Pivot', 'Both Pivots'])
string g_vis            = 'Visuals'
bool   i_fixedMomColor  = input.bool  (false,      'Use Fixed Momentum Color',   group = g_vis, display = display.none,                                          tooltip = 'Displays the momentum line with a fixed color instead of its directional gradient.')
bool   i_bandsShow      = input.bool  (true,       'Show Saturation Bands',      group = g_vis, display = display.none,                                          tooltip = 'Adaptive saturation envelope built from the momentum distribution itself.')
bool   i_squeezeBgShow  = input.bool  (true,       'Show Squeeze Background',    group = g_vis, display = display.none,                                          tooltip = 'Displays squeeze intensity as a variable-opacity background.', active = i_squeezeOn)
bool   i_showDeadZone   = input.bool  (true,       'Show Dead Zone',             group = g_vis, display = display.none,                                          tooltip = 'Displays the fixed region between the positive and negative regime-entry levels.')
bool   i_paintCandles   = input.bool  (true,       'Color Candles by Momentum',  group = g_vis, display = display.none,                                          tooltip = 'Applies the momentum gradient color to the main-chart candles.')
int    i_candleTransp   = input.int   (45,         'Candle Transparency',        group = g_vis, display = display.none, minval = 0,   maxval = 100, step = 5,    tooltip = 'Controls the transparency of momentum-based candle colors.\n⬩ 0 displays fully opaque colors.\n⬩ 100 makes the colors fully transparent.', active = i_paintCandles)
string g_tbl            = 'Info Table'
bool   i_showTable      = input.bool  (true,       'Show Info Table',            group = g_tbl, display = display.none,                                          tooltip = '')
string i_tablePos       = input.string('Bottom Right', 'Table Position',         group = g_tbl, display = display.none,                                          tooltip = 'Anchor point of the table on the main chart.', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Middle Right', 'Middle Left'], active = i_showTable)
string i_tableSize      = input.string('Small',    'Table Size',                 group = g_tbl, display = display.none,                                          tooltip = 'Text size used by every table cell.',          options = ['Tiny', 'Small', 'Normal', 'Large'],                                                    active = i_showTable)
bool   i_tableDiag      = input.bool  (false,      'Diagnostics Rows',           group = g_tbl, display = display.none,                                          tooltip = 'Adds the resolved lookback, the raw dominant cycle, the squeeze intensity and the last divergence.',                                              active = i_showTable)
string g_alt            = 'Alerts'
bool   i_alertRegime    = input.bool  (true,       'Regime Shift',               group = g_alt, display = display.none,                                          tooltip = 'Alerts when the momentum regime changes to bullish or bearish.')
bool   i_alertBand      = input.bool  (true,       'Saturation Band',            group = g_alt, display = display.none,                                          tooltip = 'Alerts when momentum reaches the upper or lower saturation band.')
bool   i_alertSqueeze   = input.bool  (false,      'Squeeze Transition',         group = g_alt, display = display.none,                                          tooltip = 'Alerts when momentum compression begins or ends.')
bool   i_alertDiv       = input.bool  (false,      'Confirmed Divergence',       group = g_alt, display = display.none,                                          tooltip = 'Alerts when a bullish or bearish divergence is confirmed.')


// ─────────
// >PALETTE< ⑵
// ──────▾──
// >colors
color  C_BULL_STRONG = #2ce433
color  C_BULL_WEAK   = #135f16
color  C_BEAR_STRONG = #ff2323
color  C_BEAR_WEAK   = #811313
color  C_ZERO_BULL   = #708278
color  C_ZERO_BEAR   = #867278
color  C_NEUTRAL     = #787b86
color  C_MUTED       = #b2b5be
color  C_WARN        = #ffb74d
color  C_STRUCTURE   = #787b86
color  C_MOM_FIXED   = #2962FF
color  C_SQUEEZE     = #9a80cc
color  C_WHITE       = #ffffff
color  C_ORANGE      = #ff9800
color  C_RED         = #ff5252

// >internal constants
float  ENTRY_LEVEL      = 7.0         // outer threshold whose crossing immediately establishes a bullish or bearish regime
float  EXIT_LEVEL       = 5.0         // inner threshold used to release an existing directional regime
float  CYCLE_LEN_SMOOTH = 0.9,        // recursive smoothing applied to the fractional length before integer conversion
int    SLOPE_LENGTH     = 3           // EMA length applied to the momentum slope for fatigue detection
float  GRADIENT_SAT     = 20.0        // momentum at which the color gradient reaches its endpoint

bool   CYCLE_VALIDATE   = true,       // enables spectral quality validation for the detected dominant cycle
float  CYCLE_MIN_DOM    = 0.20,       // minimum spectral peak dominance required to accept the detected cycle
float  CYCLE_MAX_DIST   = 3.0,        // maximum allowed distance between the spectral peak and centre-of-gravity period
bool   CYCLE_EDGE_REJ   = true,       // rejects dominant peaks located at the minimum or maximum search boundary
string CYCLE_INVALID    = 'Hold',     // invalid-period handling: 'Hold' retains the last valid period; 'NA' drops it immediately
int    CYCLE_HOLD_BARS  = 20,         // maximum consecutive invalid bars allowed while retaining the last valid period
string CYCLE_MISSING    = 'Fallback', // missing-length handling: 'Fallback' uses a static length; 'NA' interrupts the output
int    CYCLE_FALLBACK   = 14          // static lookback used when no validated adaptive period is available

int    SQUEEZE_RANK_LEN = 144,        // lookback used to percentile-rank relative volatility
float  SQUEEZE_FULL_PCT = 25.0,       // percentile at or below which squeeze intensity is maximal
float  SQUEEZE_NONE_PCT = 55.0,       // percentile at or above which squeeze intensity is zero
float  SQUEEZE_FLOOR    = 0.30        // minimum momentum multiplier applied at maximum squeeze
float  SQUEEZE_BG_LEVEL = 0.20        // minimum squeeze intensity required to display the background and trigger squeeze-transition detection

int    DIV_LEFT_BARS    = 5,          // bars required to the left of a confirmed momentum pivot
int    DIV_RIGHT_BARS   = 5,          // bars required to the right; also defines confirmation delay
int    DIV_MIN_BARS     = 5,          // minimum allowed distance between consecutive pivots
int    DIV_MAX_BARS     = 60,         // maximum allowed distance between consecutive pivots
float  DIV_MIN_OFFSET   = 5.0         // minimum absolute momentum difference between paired pivots

int    BANDS_LENGTH     = 377         // momentum-history lookback used to derive the saturation bands
float  BANDS_PERCENT    = 99.0        // distribution threshold defining the upper and lower saturation bands
int    BANDS_SMOOTH     = 3           // RMA smoothing length applied to the raw saturation-band values
float  BANDS_ACTIVATE   = 0.70        // fraction of the band level momentum must reach before the band becomes visible
int    BAND_HOLD_BARS   = 5           // bars a percentile band stays visible after its last activation


// ──────────────
// >INPUT GUARDS< ⑶
// ───────────▾──
// Fail loudly on the first bar instead of silently producing a degenerate series.
if barstate.isfirst
    if adaptiveMode and i_cycleMin >= i_cycleMax
        runtime.error('Momentum Regime: Minimum Cycle Period must be smaller than Maximum Cycle Period.')
    if adaptiveMode and CYCLE_MISSING == 'Fallback' and CYCLE_FALLBACK > 252
        runtime.error('Momentum Regime: Fallback Length must not exceed Maximum Length.')
    if i_squeezeOn and i_squeezeFast >= i_squeezeSlow
        runtime.error('Momentum Regime: Fast ATR Length must be smaller than Slow ATR Length.')
    if i_squeezeOn and SQUEEZE_FULL_PCT >= SQUEEZE_NONE_PCT
        runtime.error('Momentum Regime: Full-Squeeze Percentile must be smaller than No-Squeeze Percentile.')
    if i_divShow and DIV_MIN_BARS >= DIV_MAX_BARS
        runtime.error('Momentum Regime: Minimum Pivot Distance must be smaller than Maximum Pivot Distance.')


// ───────────
// >FUNCTIONS< ⑷
// ────────▾──
// >a) na-safe exponential smoother
f_naSafeSmooth(float source, simple int length, simple bool useRma) =>
    var float State = na
    float Alpha = useRma ? 1.0 / math.max(length, 1) : 2.0 / (math.max(length, 1) + 1.0)
    if not na(source)
        State := na(State) ? source : State + Alpha * (source - State)
    State

// >b) relative-volatility squeeze
f_relativeSqueeze(simple int fastLength, simple int slowLength, simple int rankLength, simple float fullPercentile, simple float nonePercentile) =>
    float FastAtr         = ta.atr(fastLength)
    float SlowAtr         = ta.atr(slowLength)
    float AtrRatio        = not na(FastAtr) and not na(SlowAtr) and SlowAtr > 0.0 ? FastAtr / SlowAtr : na
    float PercentileRank  = ta.percentrank(AtrRatio, rankLength)
    float PercentileRange = math.max(nonePercentile - fullPercentile, 1e-10)
    float NormalizedRank  = not na(PercentileRank) ? math.max(0.0, math.min(1.0, (PercentileRank - fullPercentile) / PercentileRange)) : na
    float SmoothRank      = not na(NormalizedRank) ? NormalizedRank * NormalizedRank * (3.0 - 2.0 * NormalizedRank) : na
    not na(SmoothRank) ? 1.0 - SmoothRank : na

// >c) pure ehlers autocorrelation periodogram
f_pureACP(float source, simple int minPeriod, simple int maxPeriod, simple bool enabled) =>
    float PowerAlpha     = 0.20
    float AgcDecay       = 0.995
    float PowerThreshold = 0.50

    // roofing filter · stage 1 — 48-bar high-pass removes the trend component
    float HpAngle = 0.707 * 2.0 * math.pi / 48.0
    float HpAlpha = (math.cos(HpAngle) + math.sin(HpAngle) - 1.0) / math.cos(HpAngle)

    var float HighPass = 0.0
    HighPass := math.pow(1.0 - HpAlpha * 0.5, 2.0) * (source - 2.0 * nz(source[1]) + nz(source[2])) + 2.0 * (1.0 - HpAlpha) * nz(HighPass[1]) - math.pow(1.0 - HpAlpha, 2.0) * nz(HighPass[2])

    // roofing filter · stage 2 — 10-bar super smoother removes the aliasing noise
    float A1 = math.exp(-1.414 * math.pi / 10.0)
    float C2 = 2.0 * A1 * math.cos(1.414 * math.pi / 10.0)
    float C3 = -(A1 * A1)
    float C1 = 1.0 - C2 - C3

    var float Filt = 0.0
    Filt := C1 * (HighPass + nz(HighPass[1])) * 0.5 + C2 * nz(Filt[1]) + C3 * nz(Filt[2])

    bool HistoryReady = bar_index >= 2 * maxPeriod + 2
    int  Stride       = maxPeriod + 1

    var array<float> Correlation = array.new_float(maxPeriod + 1, 0.0)
    var array<float> SmoothPower = array.new_float(maxPeriod + 1, 0.0)
    var array<float> NormalPower = array.new_float(maxPeriod + 1, 0.0)
    var array<float> CosineTable = array.new_float((maxPeriod + 1) * (maxPeriod + 1), 0.0)
    var array<float> SineTable   = array.new_float((maxPeriod + 1) * (maxPeriod + 1), 0.0)

    // the DFT basis is constant, so it is tabulated once on the first bar.
    if barstate.isfirst and enabled
        for period = minPeriod to maxPeriod
            for lag = 3 to maxPeriod
                float Angle = 2.0 * math.pi * float(lag) / float(period)
                array.set(CosineTable, period * Stride + lag, math.cos(Angle))
                array.set(SineTable,   period * Stride + lag, math.sin(Angle))

    var float AgcPeak = 0.0

    float CgPeriod       = na
    float PeakPeriod     = na
    float PeakPower      = 0.0
    float PeakDominance  = 0.0
    float CgPeakDistance = na
    bool  EdgeHit        = false

    if HistoryReady and enabled
        // >pearson autocorrelation over an averaging window equal to the lag itself
        for lag = 3 to maxPeriod
            float SumX  = 0.0
            float SumY  = 0.0
            float SumXX = 0.0
            float SumYY = 0.0
            float SumXY = 0.0
            for count = 0 to lag - 1
                float X = Filt[count]
                float Y = Filt[count + lag]
                SumX  += X
                SumY  += Y
                SumXX += X * X
                SumYY += Y * Y
                SumXY += X * Y
            float N           = float(lag)
            float Numerator   = N * SumXY - SumX * SumY
            float DenomSquare = (N * SumXX - SumX * SumX) * (N * SumYY - SumY * SumY)
            array.set(Correlation, lag, DenomSquare > 1e-10 ? Numerator / math.sqrt(DenomSquare) : 0.0)

        // >DFT of the correlation set; the squared magnitude is squared again to sharpen peaks
        for period = minPeriod to maxPeriod
            float CosinePart = 0.0
            float SinePart   = 0.0
            for lag = 3 to maxPeriod
                float Corr = array.get(Correlation, lag)
                CosinePart += Corr * array.get(CosineTable, period * Stride + lag)
                SinePart   += Corr * array.get(SineTable,   period * Stride + lag)
            float MagnitudeSquared = CosinePart * CosinePart + SinePart * SinePart
            float RawPower         = MagnitudeSquared * MagnitudeSquared
            array.set(SmoothPower, period, PowerAlpha * RawPower + (1.0 - PowerAlpha) * array.get(SmoothPower, period))

        // >automatic gain control: a slowly decaying peak keeps the spectrum in [0,1]
        AgcPeak := nz(AgcPeak[1]) * AgcDecay
        for period = minPeriod to maxPeriod
            AgcPeak := math.max(AgcPeak, array.get(SmoothPower, period))

        int PrimaryIndex = minPeriod
        for period = minPeriod to maxPeriod
            float Normalized = AgcPeak > 1e-10 ? array.get(SmoothPower, period) / AgcPeak : 0.0
            array.set(NormalPower, period, Normalized)
            if Normalized > PeakPower
                PeakPower    := Normalized
                PrimaryIndex := period

        PeakPeriod := float(PrimaryIndex)
        EdgeHit    := PrimaryIndex == minPeriod or PrimaryIndex == maxPeriod

        // >centre of gravity over the significant part of the spectrum
        float WeightedPeriod = 0.0
        float WeightSum      = 0.0
        for period = minPeriod to maxPeriod
            float Power = array.get(NormalPower, period)
            if Power >= PowerThreshold
                WeightedPeriod += float(period) * Power
                WeightSum      += Power
        CgPeriod := WeightSum > 1e-10 ? WeightedPeriod / WeightSum : na

        // >strongest competing local maximum, used as the ambiguity reference
        float SecondaryPeak = 0.0
        for period = minPeriod to maxPeriod
            if period != PrimaryIndex
                float Current      = array.get(NormalPower, period)
                bool  GreaterLeft  = period == minPeriod or Current > array.get(NormalPower, period - 1)
                bool  GreaterRight = period == maxPeriod or Current > array.get(NormalPower, period + 1)
                if GreaterLeft and GreaterRight
                    SecondaryPeak := math.max(SecondaryPeak, Current)

        PeakDominance  := PeakPower > 1e-10 ? math.max(0.0, math.min(1.0, (PeakPower - SecondaryPeak) / PeakPower)) : 0.0
        CgPeakDistance := not na(CgPeriod) ? math.abs(CgPeriod - PeakPeriod) : na

    [CgPeriod, PeakPeriod, PeakPower, PeakDominance, CgPeakDistance, EdgeHit]

// >d) oscillator divergence
f_oscDivergence(float osc, float priceHigh, float priceLow, float upperBand, float lowerBand, simple int left, simple int right, simple int minBars, simple int maxBars, float minAmp, simple string bandMode, simple bool useRegular, simple bool useHidden, simple bool enabled) =>
    var float LastHighOsc     = na
    var float LastHighPrice   = na
    var int   LastHighBar     = na
    var bool  LastHighOutside = false
    var float LastLowOsc      = na
    var float LastLowPrice    = na
    var int   LastLowBar      = na
    var bool  LastLowOutside  = false

    bool  RegularBull = false
    bool  HiddenBull  = false
    bool  RegularBear = false
    bool  HiddenBear  = false
    int   HighFromBar = na
    float HighFromOsc = na
    int   LowFromBar  = na
    float LowFromOsc  = na

    float PivotHigh = enabled ? ta.pivothigh(osc, left, right) : na
    float PivotLow  = enabled ? ta.pivotlow (osc, left, right) : na

    // >bearish family · oscillator highs
    if not na(PivotHigh)
        int   PivotBar     = bar_index - right
        float PivotPrice   = priceHigh[right]
        float PivotBand    = upperBand[right]
        bool  PivotOutside = not na(PivotBand) and PivotHigh >= PivotBand
        bool  BandOk       = switch bandMode
            'Latest Pivot' => PivotOutside
            'Any Pivot'    => PivotOutside or LastHighOutside
            'Both Pivots'  => PivotOutside and LastHighOutside
            => true
        if not na(LastHighBar) and BandOk
            int Distance = PivotBar - LastHighBar
            if Distance >= minBars and Distance <= maxBars and math.abs(PivotHigh - LastHighOsc) >= minAmp
                RegularBear := useRegular and PivotPrice > LastHighPrice and PivotHigh < LastHighOsc
                HiddenBear  := useHidden  and PivotPrice < LastHighPrice and PivotHigh > LastHighOsc
                if RegularBear or HiddenBear
                    HighFromBar := LastHighBar
                    HighFromOsc := LastHighOsc
        LastHighOsc     := PivotHigh
        LastHighPrice   := PivotPrice
        LastHighBar     := PivotBar
        LastHighOutside := PivotOutside

    // >bullish family · oscillator lows
    if not na(PivotLow)
        int   PivotBar     = bar_index - right
        float PivotPrice   = priceLow[right]
        float PivotBand    = lowerBand[right]
        bool  PivotOutside = not na(PivotBand) and PivotLow <= PivotBand
        bool  BandOk       = switch bandMode
            'Latest Pivot' => PivotOutside
            'Any Pivot'    => PivotOutside or LastLowOutside
            'Both Pivots'  => PivotOutside and LastLowOutside
            => true
        if not na(LastLowBar) and BandOk
            int Distance = PivotBar - LastLowBar
            if Distance >= minBars and Distance <= maxBars and math.abs(PivotLow - LastLowOsc) >= minAmp
                RegularBull := useRegular and PivotPrice < LastLowPrice and PivotLow > LastLowOsc
                HiddenBull  := useHidden  and PivotPrice > LastLowPrice and PivotLow < LastLowOsc
                if RegularBull or HiddenBull
                    LowFromBar := LastLowBar
                    LowFromOsc := LastLowOsc
        LastLowOsc     := PivotLow
        LastLowPrice   := PivotPrice
        LastLowBar     := PivotBar
        LastLowOutside := PivotOutside

    [RegularBull, HiddenBull, RegularBear, HiddenBear, HighFromBar, HighFromOsc, LowFromBar, LowFromOsc]


// ──────────────
// >CYCLE ENGINE< ⑸
// ───────────▾──
// >a) dominant cycle estimation
[acpCg, acpPeak, acpPower, acpDominance, acpDistance, acpEdge] = f_pureACP(i_source, i_cycleMin, i_cycleMax, adaptiveMode)

// >b) quality validation
bool acpReady  = adaptiveMode and not na(acpCg) and not na(acpPeak)
bool acpDomOk  = not CYCLE_VALIDATE or acpDominance >= CYCLE_MIN_DOM
bool acpDistOk = not CYCLE_VALIDATE or (not na(acpDistance) and acpDistance <= CYCLE_MAX_DIST)
bool acpEdgeOk = not CYCLE_VALIDATE or not CYCLE_EDGE_REJ or not acpEdge
bool acpValid  = acpReady and acpDomOk and acpDistOk and acpEdgeOk

// >c) validated period selector
var float cyclePeriod  = na
var int   invalidCount = 0

if acpReady
    if acpValid
        cyclePeriod  := acpCg
        invalidCount := 0
    else
        invalidCount += 1
        if CYCLE_INVALID == 'NA' or invalidCount > CYCLE_HOLD_BARS
            cyclePeriod := na

// >d) adaptive length pipeline
float scaledPeriod = not na(cyclePeriod) ? cyclePeriod * i_cycleMult : na

var float smoothedLength = na
smoothedLength := not na(scaledPeriod) ? (na(smoothedLength[1]) or CYCLE_LEN_SMOOTH <= 0.0 ? scaledPeriod : CYCLE_LEN_SMOOTH * smoothedLength[1] + (1.0 - CYCLE_LEN_SMOOTH) * scaledPeriod) : na

float resolvedLength = not na(smoothedLength) ? math.max(2.0, math.min(252, smoothedLength)) : CYCLE_MISSING == 'Fallback' ? float(CYCLE_FALLBACK) : na

// final lookback: adaptive when a cycle length is available, otherwise the static fixed length.
bool lengthReady = adaptiveMode ? not na(resolvedLength) : true
int  lookback    = adaptiveMode ? (lengthReady ? math.max(2, math.min(252, int(math.round(resolvedLength)))) : 2) : i_fixedLength


// ─────────────────
// >MOMENTUM ENGINE< ⑹
// ──────────────▾──
// >a) raw chande momentum
float sourceChange = ta.change(i_source)
float positiveMove = sourceChange >= 0.0 ? sourceChange : 0.0
float negativeMove = sourceChange >= 0.0 ? 0.0 : -sourceChange
float positiveSum  = math.sum(positiveMove, lookback)
float negativeSum  = math.sum(negativeMove, lookback)
float totalMove    = positiveSum + negativeSum

bool  momDefined  = lengthReady and not na(totalMove) and totalMove > 1e-10
float rawMomentum = momDefined ? 100.0 * (positiveSum - negativeSum) / totalMove : na

// >b) squeeze measurement and attenuation
// intensity 0 → factor 1  ·  intensity 1 → factor = attenuation floor
float measuredSqueeze = f_relativeSqueeze(i_squeezeFast, i_squeezeSlow, SQUEEZE_RANK_LEN, SQUEEZE_FULL_PCT, SQUEEZE_NONE_PCT)
float squeezeStrength = i_squeezeOn ? nz(measuredSqueeze, 0.0) : 0.0
float squeezeFactor   = 1.0 - squeezeStrength * (1.0 - SQUEEZE_FLOOR)
float adjustedMom     = momDefined ? rawMomentum * squeezeFactor : na

// >c) final momentum
float smoothedMom   = f_naSafeSmooth(adjustedMom, 2, true)
float finalMomentum = momDefined and not na(smoothedMom) ? smoothedMom : na

// >d) slope and fatigue
float rawSlope      = not na(finalMomentum) and not na(finalMomentum[1]) ? finalMomentum - finalMomentum[1] : na
float smoothedSlope = f_naSafeSmooth(rawSlope, SLOPE_LENGTH, false)
float slope         = na(finalMomentum) ? na : SLOPE_LENGTH > 1 ? smoothedSlope : rawSlope


// ────────
// >REGIME< ⑺
// ─────▾──
// 1 = bullish · 0 = neutral · -1 = bearish
float exitLevel = math.min(EXIT_LEVEL, ENTRY_LEVEL)
bool  bullEntry = not na(finalMomentum) and finalMomentum >  ENTRY_LEVEL
bool  bearEntry = not na(finalMomentum) and finalMomentum < -ENTRY_LEVEL

var int regime = 0
int prevRegime = nz(regime[1], 0)
if na(finalMomentum)
    regime := 0
else if prevRegime == 1
    regime := bearEntry ? -1 : finalMomentum <  exitLevel ? 0 :  1
else if prevRegime == -1
    regime := bullEntry ?  1 : finalMomentum > -exitLevel ? 0 : -1
else
    regime := bullEntry ?  1 : bearEntry ? -1 : 0


// ──────────────────
// >SATURATION BANDS< ⑻
// ───────────────▾──
bool divBandGate = i_divShow and i_divBandMode != 'Off'
bool bandsNeeded = i_bandsShow or divBandGate

var float bandFeed = na
bandFeed := not na(finalMomentum) ? finalMomentum : nz(bandFeed[1], na)

float upperBand = bandsNeeded ? ta.rma(ta.percentile_nearest_rank(bandFeed, BANDS_LENGTH, BANDS_PERCENT),         BANDS_SMOOTH) : na
float lowerBand = bandsNeeded ? ta.rma(ta.percentile_nearest_rank(bandFeed, BANDS_LENGTH, 100.0 - BANDS_PERCENT), BANDS_SMOOTH) : na

bool upperBandValid = i_bandsShow and not na(upperBand) and upperBand > 0.0
bool lowerBandValid = i_bandsShow and not na(lowerBand) and lowerBand < 0.0

bool upperNearBand = upperBandValid and not na(finalMomentum) and finalMomentum >= upperBand * BANDS_ACTIVATE
bool lowerNearBand = lowerBandValid and not na(finalMomentum) and finalMomentum <= lowerBand * BANDS_ACTIVATE

// short persistence so the band does not blink out between two consecutive touches.
var int upperBandHold = 0
var int lowerBandHold = 0

if upperNearBand
    upperBandHold := BAND_HOLD_BARS
else if upperBandHold > 0
    upperBandHold -= 1

if lowerNearBand
    lowerBandHold := BAND_HOLD_BARS
else if lowerBandHold > 0
    lowerBandHold -= 1

bool showUpperBand = i_bandsShow and (upperNearBand or upperBandHold > 0)
bool showLowerBand = i_bandsShow and (lowerNearBand or lowerBandHold > 0)

bool upperBandHit = upperBandValid and not na(finalMomentum) and finalMomentum >= upperBand
bool lowerBandHit = lowerBandValid and not na(finalMomentum) and finalMomentum <= lowerBand


// ────────────
// >DIVERGENCE< ⑼
// ─────────▾──
[divRegBull, divHidBull, divRegBear, divHidBear, divHighFromBar, divHighFromOsc, divLowFromBar, divLowFromOsc] = f_oscDivergence(finalMomentum, high, low, upperBand, lowerBand, DIV_LEFT_BARS, DIV_RIGHT_BARS, DIV_MIN_BARS, DIV_MAX_BARS, DIV_MIN_OFFSET, i_divBandMode, i_divRegular, i_divHidden, i_divShow)

bool  divBull    = divRegBull or divHidBull
bool  divBear    = divRegBear or divHidBear
int   divPivotX  = bar_index - DIV_RIGHT_BARS
float divPivotY  = finalMomentum[DIV_RIGHT_BARS]

if i_divShow and not na(divPivotY)
    if divBull and not na(divLowFromBar)
        if i_divLines
            line.new(divLowFromBar, divLowFromOsc, divPivotX, divPivotY, xloc = xloc.bar_index, color = divRegBull ? C_BULL_STRONG : C_BULL_WEAK, width = 1, style = divRegBull ? line.style_solid : line.style_dotted)
        label.new(divPivotX, divPivotY, divRegBull ? 'RD' : 'HD', xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(divRegBull ? C_BULL_STRONG : C_BULL_WEAK, 20), textcolor = C_WHITE, size = size.tiny, tooltip = divRegBull ? 'Regular Bullish Divergence (RD)' : 'Hidden Bullish Divergence (HD)')

    if divBear and not na(divHighFromBar)
        if i_divLines
            line.new(divHighFromBar, divHighFromOsc, divPivotX, divPivotY, xloc = xloc.bar_index, color = divRegBear ? C_BEAR_STRONG : C_BEAR_WEAK, width = 1, style = divRegBear ? line.style_solid : line.style_dotted)
        label.new(divPivotX, divPivotY, divRegBear ? 'RD' : 'HD', xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(divRegBear ? C_BEAR_STRONG : C_BEAR_WEAK, 20), textcolor = C_WHITE, size = size.tiny, tooltip = divRegBear ? 'Regular Bearish Divergence (RD)' : 'Hidden Bearish Divergence (HD)')
            
// last divergence memory, consumed by the info table only.
var string lastDivText  = na
var color  lastDivColor = C_NEUTRAL
if divBull
    lastDivText  := (divRegBull ? 'Regular Bull' : 'Hidden Bull')
    lastDivColor := divRegBull ? C_BULL_STRONG : C_BULL_WEAK
if divBear
    lastDivText  := (divRegBear ? 'Regular Bear' : 'Hidden Bear')
    lastDivColor := divRegBear ? C_BEAR_STRONG : C_BEAR_WEAK


// ───────
// >PLOTS< ⑽
// ────▾──
// >color
bool  bullStrength = not na(finalMomentum) and finalMomentum > 0.0 and not na(slope) and slope >= 0.0
bool  bearStrength = not na(finalMomentum) and finalMomentum < 0.0 and not na(slope) and slope <= 0.0
color bullColor    = bullStrength ? C_BULL_STRONG : C_BULL_WEAK
color bearColor    = bearStrength ? C_BEAR_STRONG : C_BEAR_WEAK

color momColor = na(finalMomentum) ? C_NEUTRAL : finalMomentum >= 0.0 ?
     color.from_gradient(math.min(finalMomentum,  GRADIENT_SAT),  0.0,           GRADIENT_SAT, C_ZERO_BULL, bullColor) :
     color.from_gradient(math.max(finalMomentum, -GRADIENT_SAT), -GRADIENT_SAT,  0.0,          bearColor,   C_ZERO_BEAR)

// >a) momentum
momPlot  = plot(finalMomentum,                       'Momentum',        color = i_fixedMomColor ? C_MOM_FIXED : momColor, linewidth = 2, style = plot.style_linebr)
aLenPlot = plot(adaptiveMode ? float(lookback) : na, 'Adaptive Length', color = na, display = display.status_line, editable = false)

// >b) structure
deadUpperPlot = plot(i_showDeadZone ?  ENTRY_LEVEL : na, 'Dead-Zone Upper', color = color.new(C_STRUCTURE, 65), style = plot.style_linebr, linestyle = plot.linestyle_dotted, display = display.pane)
deadLowerPlot = plot(i_showDeadZone ? -ENTRY_LEVEL : na, 'Dead-Zone Lower', color = color.new(C_STRUCTURE, 65), style = plot.style_linebr, linestyle = plot.linestyle_dotted, display = display.pane)
fill(deadUpperPlot, deadLowerPlot, color = i_showDeadZone ? color.new(C_STRUCTURE, 85) : na, title = 'Dead Zone')

hline(0.0, 'Zero Line', color = color.new(C_STRUCTURE, 30), linestyle = hline.style_dashed)

// >c) percentile bands
upperBandPlot = plot(showUpperBand ? upperBand : na, 'Upper Band',      color = color.new(C_ORANGE, 53), linewidth = 1, style = plot.style_linebr, display = display.pane)
lowerBandPlot = plot(showLowerBand ? lowerBand : na, 'Lower Band',      color = color.new(C_ORANGE, 53), linewidth = 1, style = plot.style_linebr, display = display.pane)

fill(upperBandPlot, momPlot, color = showUpperBand ? color.new(C_ORANGE, 93) : na, title = 'Upper Band To Zero Fill')
fill(lowerBandPlot, momPlot, color = showLowerBand ? color.new(C_ORANGE, 93) : na, title = 'Lower Band To Zero Fill')

// >d) backgrounds
float squeezeVisual = squeezeStrength > SQUEEZE_BG_LEVEL ? math.min(1.0, (squeezeStrength - SQUEEZE_BG_LEVEL) / math.max(1.0 - SQUEEZE_BG_LEVEL, 1e-10)) : 0.0
color squeezeBg     = i_squeezeOn and i_squeezeBgShow and squeezeVisual > 0.0 ? color.new(C_SQUEEZE, int(math.round(100.0 - squeezeVisual * 10.0))) : na

bgcolor(squeezeBg, title = 'Squeeze Background')

// >e) chart candles
color candleColor = i_paintCandles ? color.new(momColor, i_candleTransp) : na
plotcandle(i_paintCandles ? open : na, high, low, close, 'Momentum Candles', color = candleColor, wickcolor = candleColor, bordercolor = candleColor, display = display.pane, force_overlay = true, editable = false)


// ────────────
// >INFO TABLE< ⑾
// ─────────▾──
var string tablePosition = switch i_tablePos
    'Top Right'     => position.top_right
    'Top Left'      => position.top_left
    'Bottom Left'   => position.bottom_left
    'Middle Right'  => position.middle_right
    'Middle Left'   => position.middle_left
    => position.bottom_right

var string tableTextSize = switch i_tableSize
    'Tiny'   => size.tiny
    'Normal' => size.normal
    'Large'  => size.large
    => size.small

var table infoTable = i_showTable ? table.new(tablePosition, columns = 2, rows = 7, border_color = color.new(#787b86, 75), border_width = 1, frame_color = color.new(#787b86, 55), frame_width = 1, force_overlay = true) : na

f_tableRow(table _t, int _row, string _label, string _value, color _valueColor) =>
    table.cell(_t, 0, _row, _label, text_color = color.new(C_WHITE, 15), text_size = tableTextSize, text_halign = text.align_left,  bgcolor = color.new(#131722, 25))
    table.cell(_t, 1, _row, _value, text_color = _valueColor,            text_size = tableTextSize, text_halign = text.align_right, bgcolor = color.new(#131722, 25))

if i_showTable and barstate.islast and not na(infoTable)
    // >row 0 · regime
    string txtRegime = regime == 1 ? 'BULLISH' : regime == -1 ? 'BEARISH' : 'NEUTRAL'
    color  clrRegime = regime == 1 ? bullColor : regime == -1 ? bearColor : C_NEUTRAL

    // >row 1 · momentum value
    string txtValue = na(finalMomentum) ? 'n/a' : str.tostring(finalMomentum, '#.##')
    color  clrValue = momColor

    // >row 2 · slope / fatigue — mirrors the logic that drives the line color
    string txtSlope = na(slope) ? '—' :
                      regime ==  1 ? (bullStrength ? '▲ Strong' : '▼ Fading') :
                      regime == -1 ? (bearStrength ? '▼ Strong' : '▲ Fading') :
                      slope > 0.0 ? '▲ Rising' : slope < 0.0 ? '▼ Falling' : '▬ Flat'
    color  clrSlope = regime == 1 ? bullColor : regime == -1 ? bearColor : C_NEUTRAL

    f_tableRow(infoTable, 0, 'Regime',   txtRegime, clrRegime)
    f_tableRow(infoTable, 1, 'Momentum', txtValue,  clrValue)
    f_tableRow(infoTable, 2, 'Slope',    txtSlope,  clrSlope)

    if i_tableDiag
        // >row 3 · resolved lookback
        string txtLength = adaptiveMode ? (lengthReady ? str.tostring(lookback) + '  adaptive' : 'warm-up') : str.tostring(lookback) + '  fixed'
        color  clrLength = adaptiveMode and not lengthReady ? C_WARN : C_MUTED

        // >row 4 · dominant cycle
        string txtCycle = not adaptiveMode ? 'off' : na(cyclePeriod) ? 'n/a' : str.tostring(cyclePeriod, '#.#') + '  bars' + (CYCLE_VALIDATE and not acpValid ? '  (held)' : '')
        color  clrCycle = not adaptiveMode ? C_NEUTRAL : na(cyclePeriod) ? C_WARN : not CYCLE_VALIDATE ? C_MUTED : acpValid ? C_BULL_STRONG : C_WARN

        // >row 5 · squeeze
        string txtSqueeze = not i_squeezeOn ? 'off' : str.tostring(squeezeStrength * 100.0, '#') + '%   ×' + str.tostring(squeezeFactor, '#.##')
        color  clrSqueeze = not i_squeezeOn ? C_NEUTRAL : i_squeezeBgShow and squeezeStrength >= SQUEEZE_BG_LEVEL ? C_SQUEEZE : C_MUTED

        // >row 6 · last divergence
        string txtDiv = not i_divShow ? 'off' : na(lastDivText) ? 'none' : lastDivText
        color  clrDiv = not i_divShow ? C_NEUTRAL : na(lastDivText) ? C_MUTED : lastDivColor

        f_tableRow(infoTable, 3, 'Length',     txtLength,  clrLength)
        f_tableRow(infoTable, 4, 'Cycle',      txtCycle,   clrCycle)
        f_tableRow(infoTable, 5, 'Squeeze',    txtSqueeze, clrSqueeze)
        f_tableRow(infoTable, 6, 'Divergence', txtDiv,     clrDiv)
    else
        table.clear(infoTable, 0, 3, 1, 6)


// ────────
// >ALERTS< ⑿
// ─────▾──
bool alertBullRegime = i_alertRegime and regime ==  1 and prevRegime !=  1
bool alertBearRegime = i_alertRegime and regime == -1 and prevRegime != -1
bool alertUpperBand  = i_alertBand and i_bandsShow and upperBandHit and not upperBandHit[1]
bool alertLowerBand  = i_alertBand and i_bandsShow and lowerBandHit and not lowerBandHit[1]
bool alertSqueezeIn  = i_alertSqueeze and i_squeezeOn and ta.crossover(squeezeStrength, SQUEEZE_BG_LEVEL)
bool alertSqueezeOut = i_alertSqueeze and i_squeezeOn and ta.crossunder(squeezeStrength, SQUEEZE_BG_LEVEL)
bool alertBullDiv    = i_alertDiv and i_divShow and divBull
bool alertBearDiv    = i_alertDiv and i_divShow and divBear

alertcondition(alertBullRegime, 'Bullish Regime',     'Momentum regime turned bullish on {{ticker}} · {{interval}}.')
alertcondition(alertBearRegime, 'Bearish Regime',     'Momentum regime turned bearish on {{ticker}} · {{interval}}.')
alertcondition(alertUpperBand,  'Upper Saturation',   'Momentum reached the upper saturation band on {{ticker}} · {{interval}}.')
alertcondition(alertLowerBand,  'Lower Saturation',   'Momentum reached the lower saturation band on {{ticker}} · {{interval}}.')
alertcondition(alertSqueezeIn,  'Squeeze Entered',    'Momentum compression started on {{ticker}} · {{interval}}.')
alertcondition(alertSqueezeOut, 'Squeeze Released',   'Momentum compression ended on {{ticker}} · {{interval}}.')
alertcondition(alertBullDiv,    'Bullish Divergence', 'Confirmed bullish momentum divergence on {{ticker}} · {{interval}}.')
alertcondition(alertBearDiv,    'Bearish Divergence', 'Confirmed bearish momentum divergence on {{ticker}} · {{interval}}.')
// ▴▴▴▴▴▴▴▴▴▴
// #endRegion
````

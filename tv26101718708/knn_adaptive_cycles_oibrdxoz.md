# KNN Adaptive Cycles

- url: https://www.tradingview.com/script/oiBrdXOz-KNN-Adaptive-Cycles/
- type: indicator
- pine_id: PUB;d70ff7b56aa64868b0a10cbfe856a0fb
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

An adaptive Stochastic RSI whose lookback lengths are driven by the market's measured dominant cycle period, further refined in real time by a K-Nearest Neighbors machine learning layer. Rather than accepting a fixed RSI or Stochastic length, the indicator continuously measures the dominant cycle in price using two independent spectral methods, then uses KNN to anticipate where the cycle is heading and to condition the oscillator output against historical outcomes — so the indicator adapts to what the market is actually doing, not what a static setting assumes it should be.


█ [b]CYCLE DETECTION[/b]

The indicator measures the dominant cycle period using two independent methods from the digital signal processing work of John Ehlers, who treated price as a waveform and applied engineering filters to extract its underlying structure.

[b]Autocorrelation Periodogram[/b]
Computes Pearson correlation across lags from the minimum to maximum period range, identifying the lag at which price most strongly repeats. Returns a correlation coefficient used directly as a confidence score.

[b]Goertzel / DFT Power Spectrum[/b]
A frequency-domain scan that computes spectral power at each candidate period and selects the one carrying the most energy. Independent of the autocorrelation method, giving two mathematically distinct perspectives on the same cycle.

Before measurement, price is conditioned with Ehlers' filter set: a Highpass filter to remove the trend component, a Super Smoother for anti-aliasing, and an optional Bandpass pre-filter to isolate the cycle band. In [i]AC + DFT (Confirmed)[/i] mode the two estimates are cross-checked, with each method weighted by its agreement strength and the AC correlation coefficient before blending into a single confirmed period. Single-method modes run the selected method at full per-bar resolution.


█ [b]KNN MACHINE LEARNING[/b]

Two independent KNN nearest-neighbor routines operate on top of the cycle and signal layers. Both use weighted Euclidean distance across feature vectors, a 1/distance-weighted outcome average across K neighbors, and ALMA smoothing on the output bias.

[b]Period KNN[/b]
Searches history for bars whose cycle state most closely resembles the current bar — matching on current period, rate of change, stability streak, confidence score, and volatility regime. Observes what the period actually became [i]Forward Bars[/i] later at each neighbor, then blends that prediction into the current period estimate before final smoothing. Helps the indicator anticipate cycle transitions rather than just react to them.

[b]Signal KNN[/b]
Searches history for bars whose StochRSI context most closely resembles now — matching on K level, K−D histogram, K slope, volatility regime, OB/OS proximity, and D line. Observes the forward price outcome at each neighbor and blends the resulting bias into the K line before D smoothing, so D inherits the correction naturally.


█ [b]FEATURES[/b]

[b]Cycle detection[/b]
• Dual spectral cycle detection — AC and DFT run in parallel with a 0–100% confidence score reflecting method agreement
• Confidence-weighted period blending — each method weighted by agreement and correlation strength, smoothed into one adaptive period
• Single-method modes — Optional select Autocorrelation Only or DFT Only run for faster loading
• Optional Performance Throttle — cadence-limited spectral scans for the AC + DFT mode

[b]KNN layer[/b]
• Period KNN — anticipates cycle transitions by learning from historical cycle states and their forward outcomes
• Signal KNN — conditions the K line against historically similar StochRSI contexts and their forward price outcomes
• Per-feature importance weights for both KNN routines — tunable to emphasize what matters most on a given instrument
• ALMA-smoothed bias output — configurable length, offset, and sigma

## Source Code

````pine
//@version=6
indicator("KNN Adaptive Cycles", shorttitle="KNN-AC", overlay=false)
// StochRSI that features spectral dilation, cycle detection, and KNN adaptive values                                        
// ######:   . ####:     :##:    ######:  
// #######   #######:     ##     #######  
// ##   :##  #:.   ##    ####    ##   :## 
// ##    ##        ##    ####    ##    ## 
// ##   :##        ##   :#  #:   ##   :## 
// #######.    #####     #::#    #######: 
// #######.    #####.   ##  ##   ######   
// ##   :##        ##   ######   ##   ##. 
// ##    ##        ##  .######.  ##   ##  
// ##   :##  #:    ##  :##  ##:  ##   :## 
// ########  #######:  ###  ###  ##    ##:
// ######    :#####:   ##:  :##  ##    ##:
                                        

// ==================== INPUTS ====================
string cycleGroup = "Cycle Detection"
src = input.source(close, "Source", group=cycleGroup)
minPeriod = input.int(8, "Min Period", minval=4, maxval=20, group=cycleGroup)
maxPeriod = input.int(50, "Max Period", minval=20, maxval=100, group=cycleGroup)
useSpectralDilation = input.bool(true, "Use Spectral Dilation (Bandpass Pre-filter)", group=cycleGroup)
bandpassBandwidth = input.float(0.3, "Bandpass Bandwidth", minval=0.1, maxval=0.5, step=0.05, group=cycleGroup, tooltip="Lower = narrower band, more selective")
confirmationThreshold = input.float(0.2, "Confirmation Tolerance (%)", minval=0.05, maxval=0.5, step=0.05, group=cycleGroup, tooltip="Methods must agree within this % to confirm. Only used in AC + DFT (Confirmed) mode.")

string perfGroup = "Cycle Mode"
cycleMode = input.string("AC + DFT (Confirmed)", "Cycle Detection Mode", options=["AC + DFT (Confirmed)", "Autocorrelation Only", "DFT Only"], group=perfGroup, tooltip="AC + DFT runs both methods and confidence-weights their output — most accurate. Autocorrelation Only and DFT Only run a single method every bar for full resolution with lower CPU cost.")
useThrottle = input.bool(false, "Performance Throttle", group=perfGroup, tooltip="When enabled, throttles the AC and DFT scans to run every N bars instead of every bar. Substantially reduces CPU cost with minimal impact on output quality since the period is heavily smoothed. Only applies in AC + DFT (Confirmed) mode — single-method modes always run every bar.")
updateInterval = input.int(3, "Throttle Cadence (bars)", minval=2, maxval=20, group=perfGroup, tooltip="How many bars between full cycle scans when Performance Throttle is enabled. 3–5 is a good balance of speed and accuracy.")
dftBufferMult = input.float(2.0, "DFT Sample Window (x Max Period)", minval=1.0, maxval=2.0, step=0.5, group=perfGroup, tooltip="How many bars the DFT analyzes, as a multiple of Max Period. Lower = faster. 2.0 = best resolution, 1.0 = fastest.")

string knnGroup = "KNN"
usePeriodKnn  = input.bool(true,  "Enable Period KNN",  group=knnGroup, tooltip="Searches history for bars whose cycle state resembles the current one, then blends the observed future period into the current period estimate. Helps the indicator anticipate period transitions rather than just reacting to them.")
useSignalKnn  = input.bool(true,  "Enable Signal KNN",  group=knnGroup, tooltip="Searches history for bars whose StochRSI context resembles now, then blends the observed forward price outcome into the K line.")
knnK          = input.int(6,   "K Neighbors",            minval=2, maxval=20,  group=knnGroup, tooltip="How many nearest historical bars to use for each KNN engine. More = smoother but less sensitive.")
knnLookback   = input.int(150, "Search Lookback (bars)", minval=30, maxval=500, group=knnGroup, tooltip="How many historical bars to search for similar conditions. Larger = broader memory, more compute.")
knnForward    = input.int(5,   "Forward Bars (outcome)", minval=1,  maxval=20,  group=knnGroup, tooltip="How far ahead the outcome is measured at each historical neighbor. Match to your typical hold time on this timeframe.")
knnBiasSmooth = input.int(4,   "Bias Smoothing",         minval=1,  maxval=20,  group=knnGroup, tooltip="EMA length applied to the raw KNN bias before blending. Higher = smoother, less bar-to-bar noise. 1 = no smoothing.")
periodBlend   = input.float(0.25, "Period Blend Weight",  minval=0.05, maxval=1.0, step=0.05, group=knnGroup, tooltip="How strongly the KNN period prediction shifts the confirmed period. 0.25 = 25% KNN, 75% native cycle engine.")
signalBlend   = input.float(0.25, "Signal Blend Weight",  minval=0.05, maxval=1.0, step=0.05, group=knnGroup, tooltip="How strongly the KNN forward bias shifts the K line. 0.25 = 25% KNN, 75% native K.")
// Period KNN feature weights
fw_period     = input.float(1.2, "Period FW: Current Period",        minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the current cycle period value in the period similarity search.")
fw_pdelta     = input.float(1.0, "Period FW: Period Rate of Change", minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of how fast the period is changing (1-bar delta).")
fw_pstab      = input.float(0.8, "Period FW: Period Stability",      minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of how many consecutive bars the period has stayed within a 10% band (stability streak).")
fw_pconf      = input.float(1.0, "Period FW: Cycle Confidence",      minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the cycle confidence score (inter-method agreement) in the period similarity search.")
fw_pvol       = input.float(0.9, "Period FW: Volatility Regime",     minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the current ATR/avg-ATR volatility ratio.")
// Signal KNN feature weights
fw_k          = input.float(1.0, "Signal FW: K Level",               minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the K value in the signal similarity search.")
fw_hist       = input.float(1.0, "Signal FW: Histogram (K-D)",       minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the K minus D histogram in the signal similarity search.")
fw_kslope     = input.float(0.8, "Signal FW: K Slope",               minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the 1-bar change in K.")
fw_svol       = input.float(1.2, "Signal FW: Volatility Regime",     minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the volatility regime in the signal similarity search. Higher weight helps distinguish trending from choppy sessions.")
fw_extreme    = input.float(0.9, "Signal FW: OB/OS Extremity",       minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of proximity to the 20/80 OB/OS levels.")
fw_d          = input.float(0.7, "Signal FW: D Line Context",         minval=0.0, maxval=3.0, step=0.1, group=knnGroup, tooltip="Importance of the D signal line value in the signal similarity search.")

string rsiGroup = "RSI Settings"
rsiMult = input.float(1.0, "RSI Period Multiplier", minval=0.25, maxval=2.0, step=0.25, group=rsiGroup, tooltip="Scales RSI period relative to detected cycle. Use 0.5 for half-cycle (more responsive), 1.0 for full cycle (smoother)")

string stochGroup = "Stochastic Settings"
stochMult = input.float(1.0, "Stoch Period Multiplier", minval=0.25, maxval=2.0, step=0.25, group=stochGroup, tooltip="Scales stochastic lookback relative to detected cycle. Use 0.5 for half-cycle (faster signals), 1.0 for full cycle (fewer false signals)")
kSmooth = input.int(10, "K Smoothing Length", minval=1, group=stochGroup)
kMaType = input.string("EMA", "K Smoothing Type", options=["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=stochGroup)
dSmooth = input.int(4, "D Smoothing Length", minval=1, group=stochGroup)
dMaType = input.string("EMA", "D Smoothing Type", options=["EMA", "SMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "ALMA"], group=stochGroup)
almaOffset = input.float(0.85, "ALMA Offset", minval=0.0, maxval=1.0, step=0.05, group=stochGroup, tooltip="Only used when an MA type is set to ALMA. Higher = more responsive / less lag.")
almaSigma = input.float(6.0, "ALMA Sigma", minval=1.0, step=1.0, group=stochGroup, tooltip="Only used when an MA type is set to ALMA. Higher = smoother.")

string vizGroup = "Visual Style"
colorTheme = input.string("Modern (Red/Cyan)", "Color Theme", options=["Modern (Red/Cyan)", "Classic (Blue/Orange)", "Neon (Green/Magenta)", "Ocean (Teal/Indigo)", "Sunset (Gold/Pink)", "Mono (White/Gray)", "Custom"], group=vizGroup)
upColorInput = input.color(#00E5FF, "Custom Up Color", group=vizGroup, tooltip="Used only when Color Theme = Custom")
downColorInput = input.color(#FF1744, "Custom Down Color", group=vizGroup, tooltip="Used only when Color Theme = Custom")
lineWidthModern = input.int(4, "Line Width", minval=1, maxval=8, group=vizGroup)
showSignalLine = input.bool(true, "Show Signal (D) Line", group=vizGroup)
showHist = input.bool(true, "Show Histogram (K - D)", group=vizGroup)
histNormLength = input.int(50, "Histogram Normalization Length", minval=5, group=vizGroup, tooltip="The histogram (K - D) is normalized over this many bars and scaled to fill the 20-80 band, centered on the 50 midline.")
histTransp = input.int(30, "Histogram Transparency", minval=0, maxval=100, group=vizGroup, tooltip="0 = solid, 100 = invisible. Bars that are losing momentum fade an extra step beyond this.")
showZones = input.bool(true, "Highlight OB/OS Zones", group=vizGroup)

string displayGroup = "Display"
showCycleInfo    = input.bool(false, "Show Cycle Detection Info",    group=displayGroup)
showKnnTable     = input.bool(false, "Show KNN Table",               group=displayGroup)
showConfidenceBg = input.bool(false, "Cycle Correlation Confidence", group=displayGroup, tooltip="Background color shows agreement between AC and DFT cycle detection methods: Green = high confidence (both agree), Yellow = moderate, Red = low. In single-method modes reflects autocorrelation strength or DFT stability.")

// ==================== FUNCTIONS ====================

ma(string maType, float source, simple int length, simple float almaOff, simple float almaSig) =>
    switch maType
        "SMA"  => ta.sma(source, length)
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "RMA"  => ta.rma(source, length)
        "HMA"  => ta.hma(source, length)
        "DEMA" =>
            float e1 = ta.ema(source, length)
            float e2 = ta.ema(e1, length)
            2 * e1 - e2
        "TEMA" =>
            float e1 = ta.ema(source, length)
            float e2 = ta.ema(e1, length)
            float e3 = ta.ema(e2, length)
            3 * (e1 - e2) + e3
        "ALMA" => ta.alma(source, length, almaOff, almaSig)
        => ta.ema(source, length)

// Ehlers Super Smoother
superSmoother(float source, int length) =>
    float coef = math.pi * math.sqrt(2) / length
    float a1 = math.exp(-coef)
    float b1 = 2 * a1 * math.cos(coef * math.sqrt(2))
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1 - c2 - c3
    var float filt = 0.0
    filt := c1 * (source + nz(source[1])) / 2 + c2 * nz(filt[1]) + c3 * nz(filt[2])
    filt

// Bandpass Filter (for Spectral Dilation)
bandpassFilter(float source, int centerPeriod, float bandwidth) =>
    float delta = bandwidth
    float beta = math.cos(2 * math.pi / centerPeriod)
    float gamma = 1 / math.cos(4 * math.pi * delta / centerPeriod)
    float alpha = gamma - math.sqrt(gamma * gamma - 1)
    var float bp = 0.0
    bp := 0.5 * (1 - alpha) * (source - nz(source[2])) + beta * (1 + alpha) * nz(bp[1]) - alpha * nz(bp[2])
    bp

// Highpass Filter
highpassFilter(float source, int length) =>
    float alphaHP = (0.707 * 2 * math.pi) / length
    float a = math.exp(-alphaHP)
    float b = 2 * a * math.cos(alphaHP)
    float c2 = b
    float c3 = -a * a
    float c1 = (1 + c2 - c3) / 4
    var float hp = 0.0
    hp := c1 * (source - 2 * nz(source[1]) + nz(source[2])) + c2 * nz(hp[1]) + c3 * nz(hp[2])
    hp

// tanh
f_tanh(float x) =>
    float e2 = math.exp(math.max(-50.0, math.min(50.0, 2.0 * x)))
    (e2 - 1.0) / (e2 + 1.0)

f_sdiv(float x, float y) =>
    y == 0.0 or na(y) ? 0.0 : x / y

// normalise
f_norm01(float src, int len) =>
    float hi  = ta.highest(src, len)
    float lo  = ta.lowest (src, len)
    float rng = hi - lo
    rng > 1e-10 ? math.max(0.0, math.min(1.0, (src - lo) / rng)) : 0.5

// ================= AUTOCORRELATION PERIODOGRAM ==================
autocorrelationCycle(float filt, bool doUpdate) =>
    var float[] filtBuffer = array.new_float(maxPeriod + 1, 0.0)
    array.unshift(filtBuffer, filt)
    if array.size(filtBuffer) > maxPeriod + 1
        array.pop(filtBuffer)
    var float maxCorr = 0.0
    var int dominantPeriod = minPeriod
    if doUpdate
        maxCorr := 0.0
        dominantPeriod := minPeriod
        for lag = minPeriod to maxPeriod
            float sx = 0.0
            float sy = 0.0
            float sxx = 0.0
            float syy = 0.0
            float sxy = 0.0
            int n = maxPeriod - lag
            for i = 0 to n - 1
                float x = array.get(filtBuffer, i)
                float y = array.get(filtBuffer, i + lag)
                sx  := sx  + x
                sy  := sy  + y
                sxx := sxx + x * x
                syy := syy + y * y
                sxy := sxy + x * y
            float denom = math.sqrt((n * sxx - sx * sx) * (n * syy - sy * sy))
            float r = denom != 0 ? (n * sxy - sx * sy) / denom : 0
            if r > maxCorr and r > 0.2
                maxCorr := r
                dominantPeriod := lag
    var float smoothACPeriod = 0.0
    smoothACPeriod := 0.2 * dominantPeriod + 0.8 * nz(smoothACPeriod[1])
    [smoothACPeriod, maxCorr]

// ==================== DFT ====================
goertzelCycle(float filt, bool doUpdate) =>
    int bufSize = math.max(maxPeriod, math.round(maxPeriod * dftBufferMult))
    var float[] dataBuffer = array.new_float(bufSize, 0.0)
    array.unshift(dataBuffer, filt)
    if array.size(dataBuffer) > bufSize
        array.pop(dataBuffer)
    var int dominantPeriod = minPeriod
    if doUpdate
        int N = array.size(dataBuffer)
        float maxPower = 0.0
        int domP = minPeriod
        for period = minPeriod to maxPeriod
            float omega = 2 * math.pi / period
            float coeff = 2 * math.cos(omega)
            float s1 = 0.0
            float s2 = 0.0
            for i = 0 to N - 1
                float s0 = array.get(dataBuffer, i) + coeff * s1 - s2
                s2 := s1
                s1 := s0
            float pwr = s1 * s1 + s2 * s2 - coeff * s1 * s2
            if pwr > maxPower
                maxPower := pwr
                domP := period
        dominantPeriod := domP
    var float smoothDFTPeriod = 0.0
    smoothDFTPeriod := 0.2 * dominantPeriod + 0.8 * nz(smoothDFTPeriod[1])
    smoothDFTPeriod

// ==================== MAIN CYCLE DETECTION ====================

float centerPeriod  = (minPeriod + maxPeriod) / 2
float processedSrc  = useSpectralDilation ? bandpassFilter(src, math.round(centerPeriod), bandpassBandwidth) : src
float ppHP          = highpassFilter(processedSrc, maxPeriod)
float ppFilt        = superSmoother(ppHP, 10)


bool useAC  = cycleMode == "AC + DFT (Confirmed)" or cycleMode == "Autocorrelation Only"
bool useDFT = cycleMode == "AC + DFT (Confirmed)" or cycleMode == "DFT Only"

// Throttle
bool intervalTick = not useThrottle or (bar_index % updateInterval == 0)
bool doUpdateAC   = useAC  and (cycleMode == "Autocorrelation Only" or intervalTick)
bool doUpdateDFT  = useDFT and (cycleMode == "DFT Only"             or intervalTick)

[acPeriod, acConfidence] = autocorrelationCycle(ppFilt, doUpdateAC)
float dftPeriod = goertzelCycle(ppFilt, doUpdateDFT)

// ==================== PERIOD SELECTION BY MODE ====================
float confirmedPeriod = 0.0
float cycleConfidence = 0.0

if cycleMode == "Autocorrelation Only"
    confirmedPeriod := acPeriod
    cycleConfidence := acConfidence * 100

else if cycleMode == "DFT Only"
    confirmedPeriod := dftPeriod
    float dftDrift   = math.abs(dftPeriod - nz(dftPeriod[1])) / math.max(dftPeriod, 1)
    cycleConfidence := math.max(0, 100 - dftDrift * 500)

else
    // AC + DFT (Confirmed)
    float avgPeriod = (acPeriod + dftPeriod) / 2
    float acDev     = math.abs(acPeriod  - avgPeriod) / math.max(avgPeriod, 1)
    float dftDev    = math.abs(dftPeriod - avgPeriod) / math.max(avgPeriod, 1)
    int agreementCount = 0
    if acDev  <= confirmationThreshold
        agreementCount := agreementCount + 1
    if dftDev <= confirmationThreshold
        agreementCount := agreementCount + 1
    float totalWeight    = 0.0
    float weightedPeriod = 0.0
    float acWeight  = acConfidence * (acDev <= confirmationThreshold ? 1.5 : 0.75)
    weightedPeriod := weightedPeriod + acPeriod  * acWeight
    totalWeight    := totalWeight    + acWeight
    float dftWeight = dftDev <= confirmationThreshold ? 1.0 : 0.5
    weightedPeriod := weightedPeriod + dftPeriod * dftWeight
    totalWeight    := totalWeight    + dftWeight
    confirmedPeriod := totalWeight > 0 ? weightedPeriod / totalWeight : avgPeriod
    cycleConfidence := (agreementCount / 2.0) * 100

float acDev_disp  = cycleMode == "AC + DFT (Confirmed)" ? math.abs(acPeriod  - (acPeriod + dftPeriod) / 2) / math.max((acPeriod + dftPeriod) / 2, 1) : 0.0
float dftDev_disp = cycleMode == "AC + DFT (Confirmed)" ? math.abs(dftPeriod - (acPeriod + dftPeriod) / 2) / math.max((acPeriod + dftPeriod) / 2, 1) : 0.0

// ==================== KNN PERIOD ====================

float knn_atr     = ta.atr(14)
float knn_avg_atr = ta.sma(knn_atr, 50)
float vol_ratio   = knn_avg_atr > 0 ? knn_atr / knn_avg_atr : 1.0

var int pStabStreak = 0
float pStabThresh   = confirmedPeriod * 0.10
pStabStreak := math.abs(confirmedPeriod - nz(confirmedPeriod[1])) <= pStabThresh ? pStabStreak + 1 : 0

float pfeat_period = f_norm01(confirmedPeriod,                          knnLookback)
float pfeat_delta  = f_norm01(confirmedPeriod - nz(confirmedPeriod[1]), knnLookback)
float pfeat_stab   = f_norm01(float(pStabStreak),                       knnLookback)
float pfeat_conf   = f_norm01(cycleConfidence,                          knnLookback)
float pfeat_vol    = f_norm01(vol_ratio,                                knnLookback)

float period_knn_bias   = 0.0
int   period_knn_n      = 0
float period_knn_dist   = na

if usePeriodKnn and bar_index >= knnLookback + knnForward
    var array<float> pk_heap_dist = array.new_float(0)
    var array<float> pk_heap_out  = array.new_float(0)
    array.clear(pk_heap_dist)
    array.clear(pk_heap_out)
    for _i = 0 to knnK - 1
        array.push(pk_heap_dist, 1e18)
        array.push(pk_heap_out,  0.0)
    float pk_worst = 1e18
    int pk_start   = knnForward + 1
    int pk_end     = math.min(knnLookback, bar_index - 1)
    for i = pk_start to pk_end
        float h0 = pfeat_period[i]
        float h1 = pfeat_delta [i]
        float h2 = pfeat_stab  [i]
        float h3 = pfeat_conf  [i]
        float h4 = pfeat_vol   [i]
        if na(h0) or na(h1) or na(h2) or na(h3) or na(h4)
            continue
        float d0 = fw_period * (pfeat_period - h0)
        float d1 = fw_pdelta * (pfeat_delta  - h1)
        float d2 = fw_pstab  * (pfeat_stab   - h2)
        float d3 = fw_pconf  * (pfeat_conf   - h3)
        float d4 = fw_pvol   * (pfeat_vol    - h4)
        float dist = math.sqrt(d0*d0 + d1*d1 + d2*d2 + d3*d3 + d4*d4)
        if dist < pk_worst
            int worst_idx   = 0
            float cur_worst = -1.0
            for k = 0 to knnK - 1
                float kd = array.get(pk_heap_dist, k)
                if kd > cur_worst
                    cur_worst := kd
                    worst_idx := k
            float p_then  = confirmedPeriod[i]
            float p_after = confirmedPeriod[i - knnForward]
            float p_range = float(maxPeriod - minPeriod)
            float raw_out = p_range > 0 ? (p_after - p_then) / p_range : 0.0
            float outcome = f_tanh(raw_out * 3.0)
            array.set(pk_heap_dist, worst_idx, dist)
            array.set(pk_heap_out,  worst_idx, outcome)
            pk_worst := -1.0
            for k = 0 to knnK - 1
                float kd = array.get(pk_heap_dist, k)
                if kd > pk_worst
                    pk_worst := kd
    float pk_w_sum  = 0.0
    float pk_o_sum  = 0.0
    float pk_d_sum  = 0.0
    int   pk_n      = 0
    for k = 0 to knnK - 1
        float d = array.get(pk_heap_dist, k)
        float o = array.get(pk_heap_out,  k)
        if d < 1e17
            float w  = d < 1e-10 ? 1e10 : 1.0 / d
            pk_w_sum += w
            pk_o_sum += o * w
            pk_d_sum += d
            pk_n     += 1
    if pk_w_sum > 0.0
        period_knn_bias := pk_o_sum / pk_w_sum
        period_knn_n    := pk_n
        period_knn_dist := pk_n > 0 ? pk_d_sum / pk_n : na

float period_bias_smooth = ta.alma(period_knn_bias, knnBiasSmooth, almaOffset, almaSigma)
float period_knn_shift   = period_bias_smooth * float(maxPeriod - minPeriod) * 0.5
float blendedPeriod      = usePeriodKnn
     ? math.max(float(minPeriod), math.min(float(maxPeriod), confirmedPeriod + periodBlend * period_knn_shift))
     : confirmedPeriod

var float finalPeriod = 0.0
finalPeriod := 0.15 * blendedPeriod + 0.85 * nz(finalPeriod[1])
finalPeriod := math.max(minPeriod, math.min(maxPeriod, finalPeriod))

// ==================== CYCLE RSI ====================
int rsiPeriod = math.max(2, math.round(finalPeriod * rsiMult))

float change = src - src[1]
float gain   = math.max(change, 0)
float loss   = math.max(-change, 0)

float alphaRSI = 2.0 / (rsiPeriod + 1)
var float avgGain = 0.0
var float avgLoss = 0.0
avgGain := alphaRSI * gain + (1 - alphaRSI) * nz(avgGain[1])
avgLoss := alphaRSI * loss + (1 - alphaRSI) * nz(avgLoss[1])

float cycleRSI = avgLoss == 0 ? 100 : avgGain == 0 ? 0 : 100 - (100 / (1 + avgGain / avgLoss))

// ==================== STOCHASTIC OF RSI ====================
int stochPeriod = math.max(5, math.round(finalPeriod * stochMult))

var float highestRSI = na
var float lowestRSI  = na
highestRSI := cycleRSI
lowestRSI  := cycleRSI
for i = 1 to maxPeriod
    if i < stochPeriod
        highestRSI := math.max(highestRSI, nz(cycleRSI[i]))
        lowestRSI  := math.min(lowestRSI,  nz(cycleRSI[i]))

float rawK = highestRSI - lowestRSI != 0 ? 100 * (cycleRSI - lowestRSI) / (highestRSI - lowestRSI) : 50

float kLine_native = ma(kMaType, rawK, kSmooth, almaOffset, almaSigma)
float dLine_native = ma(dMaType, kLine_native, dSmooth, almaOffset, almaSigma)

// ==================== KNN SIGNAL ====================

// Signal KNN features
float sfeat_k       = f_norm01(kLine_native,                          knnLookback)
float sfeat_hist    = f_norm01(kLine_native - dLine_native,           knnLookback)
float sfeat_kslope  = f_norm01(kLine_native - nz(kLine_native[1]),   knnLookback)
float sfeat_vol     = f_norm01(vol_ratio,                             knnLookback)
float _ob_dist      = math.abs(kLine_native - 80)
float _os_dist      = math.abs(kLine_native - 20)
float sfeat_extreme = 1.0 - math.min(_ob_dist, _os_dist) / 60.0
sfeat_extreme      := math.max(0.0, math.min(1.0, sfeat_extreme))
float sfeat_d       = f_norm01(dLine_native,                          knnLookback)

float signal_knn_bias  = 0.0
int   signal_knn_n     = 0
float signal_knn_dist  = na

if useSignalKnn and bar_index >= knnLookback + knnForward
    var array<float> sk_heap_dist = array.new_float(0)
    var array<float> sk_heap_out  = array.new_float(0)
    array.clear(sk_heap_dist)
    array.clear(sk_heap_out)
    for _i = 0 to knnK - 1
        array.push(sk_heap_dist, 1e18)
        array.push(sk_heap_out,  0.0)
    float sk_worst = 1e18
    int sk_start   = knnForward + 1
    int sk_end     = math.min(knnLookback, bar_index - 1)
    for i = sk_start to sk_end
        float h0 = sfeat_k      [i]
        float h1 = sfeat_hist   [i]
        float h2 = sfeat_kslope [i]
        float h3 = sfeat_vol    [i]
        float h4 = sfeat_extreme[i]
        float h5 = sfeat_d      [i]
        if na(h0) or na(h1) or na(h2) or na(h3) or na(h4) or na(h5)
            continue
        float d0 = fw_k      * (sfeat_k       - h0)
        float d1 = fw_hist   * (sfeat_hist    - h1)
        float d2 = fw_kslope * (sfeat_kslope  - h2)
        float d3 = fw_svol   * (sfeat_vol     - h3)
        float d4 = fw_extreme * (sfeat_extreme - h4)
        float d5 = fw_d      * (sfeat_d       - h5)
        float dist = math.sqrt(d0*d0 + d1*d1 + d2*d2 + d3*d3 + d4*d4 + d5*d5)
        if dist < sk_worst
            int worst_idx   = 0
            float cur_worst = -1.0
            for k = 0 to knnK - 1
                float kd = array.get(sk_heap_dist, k)
                if kd > cur_worst
                    cur_worst := kd
                    worst_idx := k
            float price_then  = close[i]
            float price_after = close[i - knnForward]
            float atr_then    = nz(knn_atr[i], knn_atr)
            float raw_ret     = atr_then > 0 ? (price_after - price_then) / atr_then : 0.0
            float k_sign      = kLine_native[i] >= 50 ? 1.0 : -1.0
            float outcome     = f_tanh(raw_ret * k_sign)
            array.set(sk_heap_dist, worst_idx, dist)
            array.set(sk_heap_out,  worst_idx, outcome)
            sk_worst := -1.0
            for k = 0 to knnK - 1
                float kd = array.get(sk_heap_dist, k)
                if kd > sk_worst
                    sk_worst := kd
    float sk_w_sum = 0.0
    float sk_o_sum = 0.0
    float sk_d_sum = 0.0
    int   sk_n     = 0
    for k = 0 to knnK - 1
        float d = array.get(sk_heap_dist, k)
        float o = array.get(sk_heap_out,  k)
        if d < 1e17
            float w  = d < 1e-10 ? 1e10 : 1.0 / d
            sk_w_sum += w
            sk_o_sum += o * w
            sk_d_sum += d
            sk_n     += 1
    if sk_w_sum > 0.0
        signal_knn_bias := sk_o_sum / sk_w_sum
        signal_knn_n    := sk_n
        signal_knn_dist := sk_n > 0 ? sk_d_sum / sk_n : na

float signal_bias_smooth = ta.alma(signal_knn_bias, knnBiasSmooth, almaOffset, almaSigma)
float kLine_blended = useSignalKnn
     ? math.max(0.0, math.min(100.0, kLine_native + signalBlend * signal_bias_smooth * 50.0))
     : kLine_native

// Final K and D — D smoothed from the (possibly KNN-adjusted) K
float kLine = kLine_blended
float dLine = ma(dMaType, kLine, dSmooth, almaOffset, almaSigma)

// ==================== THEME ====================
color upCol = switch colorTheme
    "Modern (Red/Cyan)"     => #00E5FF
    "Classic (Blue/Orange)" => #2962FF
    "Neon (Green/Magenta)"  => #39FF14
    "Ocean (Teal/Indigo)"   => #2DD4BF
    "Sunset (Gold/Pink)"    => #FFD60A
    "Mono (White/Gray)"     => #ECEFF1
    => upColorInput

color downCol = switch colorTheme
    "Modern (Red/Cyan)"     => #FF1744
    "Classic (Blue/Orange)" => #FF9800
    "Neon (Green/Magenta)"  => #FF00FF
    "Ocean (Teal/Indigo)"   => #6366F1
    "Sunset (Gold/Pink)"    => #FF1F6B
    "Mono (White/Gray)"     => #607D8B
    => downColorInput

// ==================== VISUALIZATION ====================
bool isModern = true

color lineCol = kLine >= nz(kLine[1], kLine) ? upCol : downCol

bool showConfBg = showConfidenceBg
color bgColor = showConfBg ? (cycleConfidence >= 66 ? color.new(color.green, 90) : cycleConfidence >= 33 ? color.new(color.yellow, 92) : color.new(color.red, 92)) : na
bgcolor(bgColor)

// --- Histogram ---
float hist       = kLine - dLine
float histMaxAbs = ta.highest(math.abs(hist), histNormLength)
float histNorm   = histMaxAbs > 0 ? hist / histMaxAbs : 0.0
float histDisp   = 50 + histNorm * 30
bool  histUp     = hist >= 0
bool  histGrow   = hist >= nz(hist[1], hist)
int   histFade   = math.min(histTransp + 30, 100)
color histCol    = histUp ? (histGrow ? color.new(upCol, histTransp) : color.new(upCol, histFade)) : (histGrow ? color.new(downCol, histFade) : color.new(downCol, histTransp))
plot(showHist ? histDisp : na, "Histogram (K - D)", color=histCol, style=plot.style_columns, histbase=50)

// --- OB/OS zones ---
hTop = hline(100, "Top",        color=na,                        display=display.none)
hOB  = hline(80,  "Overbought", color=color.new(downCol, 40),   linestyle=hline.style_dashed)
hMid = hline(50,  "Midline",    color=color.new(color.gray, 55), linestyle=hline.style_dotted)
hOS  = hline(20,  "Oversold",   color=color.new(upCol, 40),     linestyle=hline.style_dashed)
hBot = hline(0,   "Bottom",     color=na,                        display=display.none)
fill(hTop, hOB, color=showZones ? color.new(downCol, 92) : na, title="OB Zone")
fill(hOS,  hBot, color=showZones ? color.new(upCol,   92) : na, title="OS Zone")

// --- Lines ---
plot(isModern ? kLine : na,                      "StochRSI",  color=lineCol,                    linewidth=lineWidthModern)
plot((isModern and showSignalLine) ? dLine : na, "D (signal)", color=color.new(color.gray, 15), linewidth=2)
plot(not isModern ? kLine : na,                  "K",          color=upCol,                     linewidth=2)
plot((not isModern and showSignalLine) ? dLine : na, "D",      color=downCol,                   linewidth=2)

// ==================== DATA WINDOW ====================
plot(finalPeriod,                         "Final Cycle Period",       display=display.data_window)
plot(useAC  ? acPeriod  : na,            "Autocorrelation Period",   display=display.data_window)
plot(useDFT ? dftPeriod : na,            "DFT Period",               display=display.data_window)
plot(cycleConfidence,                     "Cycle Confidence %",       display=display.data_window)
plot(usePeriodKnn ? period_knn_bias : na, "Period KNN Bias",         display=display.data_window)
plot(rsiPeriod,                           "RSI Period",               display=display.data_window)
plot(stochPeriod,                         "Stoch Period",             display=display.data_window)
plot(cycleRSI,                            "Raw RSI",                  display=display.data_window)
plot(kLine_native,                        "K Native",                 display=display.data_window)
plot(useSignalKnn ? kLine : na,          "K Blended",                display=display.data_window)
plot(dLine,                               "D Value",                  display=display.data_window)
plot(hist,                                "Histogram Value",          display=display.data_window)
plot(useSignalKnn ? signal_knn_bias : na, "Signal KNN Bias",         display=display.data_window)
plot(useAC ? acConfidence * 100 : na,    "AC Correlation %",         display=display.data_window)

// ==================== KNN TABLE ====================
var table knnTable = na

if barstate.islast and (usePeriodKnn or useSignalKnn) and showKnnTable
    int tRows = 2 + (usePeriodKnn ? 3 : 0) + (useSignalKnn ? 3 : 0)
    if na(knnTable)
        knnTable := table.new(position.bottom_right, 2, tRows,
             bgcolor=color.new(color.black, 75), border_width=1,
             border_color=color.new(color.white, 75), force_overlay=true)
    int row = 0
    // Header
    table.cell(knnTable, 0, row, "KNN Engine",   text_color=color.white,  text_size=size.small)
    table.cell(knnTable, 1, row, "Status",        text_color=color.white,  text_size=size.small)
    row := row + 1
    table.cell(knnTable, 0, row, "K / Lookback", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(knnTable, 1, row, str.tostring(knnK) + " / " + str.tostring(knnLookback), text_color=color.new(color.gray, 20), text_size=size.small)
    row := row + 1
    // Period KNN block
    if usePeriodKnn
        color pbias_col = period_knn_bias > 0.1 ? color.new(color.lime, 0) : period_knn_bias < -0.1 ? color.new(color.red, 0) : color.new(color.gray, 20)
        table.cell(knnTable, 0, row, "Period Bias",  text_color=color.new(color.aqua, 0),  text_size=size.small)
        table.cell(knnTable, 1, row, str.tostring(period_knn_bias, "#.###"), text_color=pbias_col, text_size=size.small)
        row := row + 1
        table.cell(knnTable, 0, row, "Period Shift", text_color=color.new(color.gray, 20), text_size=size.small)
        table.cell(knnTable, 1, row, str.tostring(periodBlend * period_bias_smooth * float(maxPeriod - minPeriod) * 0.5, "#.##") + " bars", text_color=color.new(color.gray, 20), text_size=size.small)
        row := row + 1
        table.cell(knnTable, 0, row, "Period N / Dist", text_color=color.new(color.gray, 20), text_size=size.small)
        table.cell(knnTable, 1, row, str.tostring(period_knn_n) + " / " + (na(period_knn_dist) ? "—" : str.tostring(period_knn_dist, "#.####")), text_color=color.new(color.gray, 20), text_size=size.small)
        row := row + 1
    // Signal KNN block
    if useSignalKnn
        color sbias_col = signal_knn_bias > 0.1 ? color.new(color.lime, 0) : signal_knn_bias < -0.1 ? color.new(color.red, 0) : color.new(color.gray, 20)
        table.cell(knnTable, 0, row, "Signal Bias",  text_color=color.new(color.yellow, 0), text_size=size.small)
        table.cell(knnTable, 1, row, str.tostring(signal_knn_bias, "#.###"), text_color=sbias_col, text_size=size.small)
        row := row + 1
        table.cell(knnTable, 0, row, "K Shift",      text_color=color.new(color.gray, 20), text_size=size.small)
        table.cell(knnTable, 1, row, str.tostring(signalBlend * signal_bias_smooth * 50.0, "#.##") + " pts", text_color=color.new(color.gray, 20), text_size=size.small)
        row := row + 1
        table.cell(knnTable, 0, row, "Signal N / Dist", text_color=color.new(color.gray, 20), text_size=size.small)
        table.cell(knnTable, 1, row, str.tostring(signal_knn_n) + " / " + (na(signal_knn_dist) ? "—" : str.tostring(signal_knn_dist, "#.####")), text_color=color.new(color.gray, 20), text_size=size.small)
else if barstate.islast and not na(knnTable)
    table.delete(knnTable)
    knnTable := na

// ==================== CYCLE INFO TABLE ====================
var table infoTable = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 80), border_width=1)

if showCycleInfo and barstate.islast
    table.cell(infoTable, 0, 0, "Cycle Method", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, "Period",        text_color=color.white, text_size=size.small)
    bool acActive  = cycleMode == "AC + DFT (Confirmed)" or cycleMode == "Autocorrelation Only"
    bool dftActive = cycleMode == "AC + DFT (Confirmed)" or cycleMode == "DFT Only"
    color acRowCol  = acActive  ? color.aqua : color.new(color.gray, 50)
    color dftRowCol = dftActive ? color.aqua : color.new(color.gray, 50)
    color acValCol  = cycleMode == "AC + DFT (Confirmed)" ? (acDev_disp  <= confirmationThreshold ? color.lime : color.gray) : (cycleMode == "Autocorrelation Only" ? color.yellow : color.new(color.gray, 50))
    color dftValCol = cycleMode == "AC + DFT (Confirmed)" ? (dftDev_disp <= confirmationThreshold ? color.lime : color.gray) : (cycleMode == "DFT Only"             ? color.yellow : color.new(color.gray, 50))
    table.cell(infoTable, 0, 1, "Autocorr",  text_color=acRowCol,  text_size=size.small)
    table.cell(infoTable, 1, 1, acActive  ? str.tostring(math.round(acPeriod,  1)) : "—", text_color=acValCol,  text_size=size.small)
    table.cell(infoTable, 0, 2, "DFT",       text_color=dftRowCol, text_size=size.small)
    table.cell(infoTable, 1, 2, dftActive ? str.tostring(math.round(dftPeriod, 1)) : "—", text_color=dftValCol, text_size=size.small)
    table.cell(infoTable, 0, 3, "CONFIRMED", text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(math.round(finalPeriod, 1)), text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 4, "Confidence", text_color=color.white, text_size=size.small)
    color confColor = cycleConfidence >= 66 ? color.lime : cycleConfidence >= 33 ? color.yellow : color.red
    table.cell(infoTable, 1, 4, str.tostring(math.round(cycleConfidence)) + "%", text_color=confColor, text_size=size.small)

// ==================== ALERTS ====================
alertcondition(ta.crossover(kLine, dLine)  and kLine < 30, "Bullish Cross in Oversold",   "K crossed above D in oversold zone")
alertcondition(ta.crossunder(kLine, dLine) and kLine > 70, "Bearish Cross in Overbought", "K crossed below D in overbought zone")
alertcondition(cycleConfidence >= 66,                       "High Cycle Confidence",        "AC and DFT cycle detection methods agree")
alertcondition(usePeriodKnn and period_knn_bias > 0.3,     "Period KNN Bullish Bias",      "KNN predicts cycle period is likely to expand (bullish cycle stretch)")
alertcondition(usePeriodKnn and period_knn_bias < -0.3,    "Period KNN Bearish Bias",      "KNN predicts cycle period is likely to contract")
alertcondition(useSignalKnn and signal_knn_bias > 0.3 and kLine < 30, "KNN Signal Bull at OS", "Strong bullish KNN bias at oversold K")
alertcondition(useSignalKnn and signal_knn_bias < -0.3 and kLine > 70, "KNN Signal Bear at OB", "Strong bearish KNN bias at overbought K")
````

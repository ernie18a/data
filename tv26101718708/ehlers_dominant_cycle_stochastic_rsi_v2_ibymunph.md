# Ehlers Dominant Cycle Stochastic RSI v2

- url: https://www.tradingview.com/script/iBymUNph-Ehlers-Dominant-Cycle-Stochastic-RSI-v2/
- type: indicator
- pine_id: PUB;d538acb9b06a4d86a9112478756a0746
- version: 2.0

## Description

[b]Ehlers Dominant Cycle Stochastic RSI[/b]

[b]Summary[/b]
An adaptive Stochastic RSI whose lengths are set by the market's measured dominant cycle rather than by a fixed input. The indicator continuously estimates the dominant cycle period in price and feeds that period directly into the RSI and Stochastic calculations, so the oscillator's lookback adjusts as the underlying cycle shortens or lengthens across symbols and timeframes.

[b]The Inspiration — John Ehlers[/b]
The indicator is built on the digital signal processing work of John Ehlers, who treated price as a waveform and applied engineering filters to extract its underlying cycle. Rather than rely on a single cycle estimate, it runs three independent measurement methods in parallel:

[list]
[*]Hilbert Transform homodyne discriminator — Ehlers' classic dominant-cycle estimator
[*]Autocorrelation Periodogram — Pearson correlation across lags to identify the repeating period
[*]Goertzel / DFT power spectrum — a frequency-domain scan for the strongest cycle
[/list]
Before measurement, price is conditioned with Ehlers' filter set: a Super Smoother filter, a Highpass filter to remove the trend (DC) component, and an optional Bandpass "spectral dilation" pre-filter to isolate the cycle band. The three estimates are then cross-checked. When they agree, their values are blended into a single confirmed period; when they diverge, outliers are down-weighted before the result is smoothed.

[b]Features[/b]
[list]
[*]Triple cycle detection with confirmation — Hilbert, Autocorrelation, and DFT run together, with a 0–100% confidence score reflecting how closely they agree
[*]Confidence-weighted period blending — each method is weighted by agreement and correlation strength, then smoothed into one cycle period
[*]Adaptive RSI & Stochastic lengths — both derive from the detected cycle, with independent multipliers (e.g. 0.5× for half-cycle, 1.0× for full-cycle)
[*]Spectral dilation pre-filter — optional bandpass with adjustable bandwidth for tighter cycle isolation
[*]Momentum histogram — normalized K−D centered on the midline, with bars that fade as momentum stalls
[*]OB/OS zone shading
[*]Performance controls — recalc interval and DFT window settings to manage the spectral scans
[/list]

## Source Code

````pine
//@version=6
indicator("Ehlers Dominant Cycle Stochastic RSI", shorttitle="Ehlers Cycle StochRSI", overlay=false)
                                        
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
confirmationThreshold = input.float(0.2, "Confirmation Tolerance (%)", minval=0.05, maxval=0.5, step=0.05, group=cycleGroup, tooltip="Methods must agree within this % to confirm. Only used in All Three mode.")

string perfGroup = "Performance Mode"
cycleMode = input.string("All Three (Confirmed)", "Cycle Detection Mode", options=["All Three (Confirmed)", "Hilbert Only", "Autocorrelation Only", "DFT Only"], group=perfGroup, tooltip="All Three runs the full multi-method scan with confidence weighting — most accurate, most CPU. Hilbert Only is per-bar recursive with near-zero overhead. AC and DFT are throttled by the Recalc Interval below.")
updateInterval = input.int(3, "Cycle Recalc Interval (bars)", minval=1, maxval=20, group=perfGroup, tooltip="Only applies in All Three (Confirmed) mode. Recompute the heavy AC & DFT scans every N bars instead of every bar. 1 = every bar (most accurate, slowest). 3-5 = much faster with virtually identical output. In AC Only or DFT Only mode, the selected method always runs every bar for full resolution.")
dftBufferMult = input.float(2.0, "DFT Sample Window (x Max Period)", minval=1.0, maxval=2.0, step=0.5, group=perfGroup, tooltip="How many bars the DFT analyzes, as a multiple of Max Period. Lower = faster. 2.0 = best resolution, 1.0 = fastest. Only used when DFT is active.")

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
visualStyle = input.string("Modern", "Appearance", options=["Modern", "Classic"], group=vizGroup, tooltip="Modern = single thick line colored by direction. Classic = separate K and D lines.")
colorTheme = input.string("Modern (Red/Cyan)", "Color Theme", options=["Modern (Red/Cyan)", "Classic (Blue/Orange)", "Neon (Green/Magenta)", "Ocean (Teal/Indigo)", "Sunset (Gold/Pink)", "Mono (White/Gray)", "Custom"], group=vizGroup)
upColorInput = input.color(#00E5FF, "Custom Up Color", group=vizGroup, tooltip="Used only when Color Theme = Custom")
downColorInput = input.color(#FF1744, "Custom Down Color", group=vizGroup, tooltip="Used only when Color Theme = Custom")
lineWidthModern = input.int(4, "Modern Line Width", minval=1, maxval=8, group=vizGroup)
showSignalLine = input.bool(true, "Show Signal (D) Line", group=vizGroup, tooltip="In Modern mode this draws a reference line for the D signal.")
showHist = input.bool(true, "Show Histogram (K - D)", group=vizGroup)
histNormLength = input.int(50, "Histogram Normalization Length", minval=5, group=vizGroup, tooltip="The histogram (K - D) is normalized over this many bars and scaled to fill the 20-80 band, centered on the 50 midline.")
histTransp = input.int(30, "Histogram Transparency", minval=0, maxval=100, group=vizGroup, tooltip="0 = solid, 100 = invisible. Bars that are losing momentum fade an extra step beyond this.")
showZones = input.bool(true, "Highlight OB/OS Zones", group=vizGroup)

string displayGroup = "Display"
showCycleInfo = input.bool(false, "Show Cycle Detection Info", group=displayGroup)
showConfidenceBg = input.bool(false, "Cycle Correlation Confidence", group=displayGroup, tooltip="Background color shows agreement between cycle detection methods: Green = high confidence, Yellow = moderate, Red = low. In single-method modes this reflects autocorrelation strength (AC/DFT) or is disabled (Hilbert).")

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

// ================ HILBERT TRANSFORM ==================
hilbertCycle(float source) =>
    // Smoothed price
    float smooth = (4 * source + 3 * nz(source[1]) + 2 * nz(source[2]) + nz(source[3])) / 10
    
    var float detrender = 0.0
    var float I1 = 0.0
    var float Q1 = 0.0
    var float jI = 0.0
    var float jQ = 0.0
    var float I2 = 0.0
    var float Q2 = 0.0
    var float Re = 0.0
    var float Im = 0.0
    var float htPeriod = 0.0
    var float smoothPeriod = 0.0
    
    if bar_index > 5
        float adaptiveFactor = 0.075 * nz(htPeriod[1]) + 0.54
        
        detrender := (0.0962 * smooth + 0.5769 * nz(smooth[2]) - 0.5769 * nz(smooth[4]) - 0.0962 * nz(smooth[6])) * adaptiveFactor
        
        Q1 := (0.0962 * detrender + 0.5769 * nz(detrender[2]) - 0.5769 * nz(detrender[4]) - 0.0962 * nz(detrender[6])) * adaptiveFactor
        I1 := nz(detrender[3])
        
        jI := (0.0962 * I1 + 0.5769 * nz(I1[2]) - 0.5769 * nz(I1[4]) - 0.0962 * nz(I1[6])) * adaptiveFactor
        jQ := (0.0962 * Q1 + 0.5769 * nz(Q1[2]) - 0.5769 * nz(Q1[4]) - 0.0962 * nz(Q1[6])) * adaptiveFactor
        
        I2 := I1 - jQ
        Q2 := Q1 + jI
        
        I2 := 0.2 * I2 + 0.8 * nz(I2[1])
        Q2 := 0.2 * Q2 + 0.8 * nz(Q2[1])
        
        Re := I2 * nz(I2[1]) + Q2 * nz(Q2[1])
        Im := I2 * nz(Q2[1]) - Q2 * nz(I2[1])
        Re := 0.2 * Re + 0.8 * nz(Re[1])
        Im := 0.2 * Im + 0.8 * nz(Im[1])
        
        if Im != 0 and Re != 0
            htPeriod := 2 * math.pi / math.atan(Im / Re)
        
        // Rate of change limiter
        if htPeriod > 1.5 * nz(htPeriod[1])
            htPeriod := 1.5 * nz(htPeriod[1])
        if htPeriod < 0.67 * nz(htPeriod[1])
            htPeriod := 0.67 * nz(htPeriod[1])
        
        htPeriod := math.max(minPeriod, math.min(maxPeriod, htPeriod))
        smoothPeriod := 0.33 * htPeriod + 0.67 * nz(smoothPeriod[1])
    
    smoothPeriod

// ================= AUTOCORRELATION PERIODOGRAM ==================
autocorrelationCycle(float filt, bool doUpdate) =>
    // Store filtered values for correlation
    var float[] filtBuffer = array.new_float(maxPeriod + 1, 0.0)
    array.unshift(filtBuffer, filt)
    if array.size(filtBuffer) > maxPeriod + 1
        array.pop(filtBuffer)

    // Held between recalcs
    var float maxCorr = 0.0
    var int dominantPeriod = minPeriod

    if doUpdate
        maxCorr := 0.0
        dominantPeriod := minPeriod
        // Pearson correlation
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
                sx := sx + x
                sy := sy + y
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
    // Store values
    var float[] dataBuffer = array.new_float(bufSize, 0.0)
    array.unshift(dataBuffer, filt)
    if array.size(dataBuffer) > bufSize
        array.pop(dataBuffer)

    var int dominantPeriod = minPeriod

    if doUpdate
        int N = array.size(dataBuffer)
        float maxPower = 0.0
        int domP = minPeriod
        // Goertzel power per period
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

// Spectral dilation (bandpass pre-filter)
float centerPeriod = (minPeriod + maxPeriod) / 2
float processedSrc = useSpectralDilation ? bandpassFilter(src, math.round(centerPeriod), bandpassBandwidth) : src

// Shared pre-filter (highpass + super smoother)
float ppHP = highpassFilter(processedSrc, maxPeriod)
float ppFilt = superSmoother(ppHP, 10)

// Hilbert runs every bar
float hilbertPeriod = hilbertCycle(processedSrc)

// AC and DFT
bool useAC  = cycleMode == "All Three (Confirmed)" or cycleMode == "Autocorrelation Only"
bool useDFT = cycleMode == "All Three (Confirmed)" or cycleMode == "DFT Only"

bool intervalTick = updateInterval <= 1 or (bar_index % updateInterval == 0)
// Throttle only applies in All Three mode
bool doUpdateAC  = useAC  and (cycleMode == "Autocorrelation Only" or intervalTick)
bool doUpdateDFT = useDFT and (cycleMode == "DFT Only"             or intervalTick)

[acPeriod, acConfidence] = autocorrelationCycle(ppFilt, doUpdateAC)
float dftPeriod = goertzelCycle(ppFilt, doUpdateDFT)

// ==================== PERIOD SELECTION BY MODE ====================
float confirmedPeriod = 0.0
float cycleConfidence = 0.0

if cycleMode == "Hilbert Only"
    confirmedPeriod := hilbertPeriod
    cycleConfidence := 100.0

else if cycleMode == "Autocorrelation Only"
    confirmedPeriod := acPeriod
    cycleConfidence := acConfidence * 100

else if cycleMode == "DFT Only"
    confirmedPeriod := dftPeriod
    float dftDrift = math.abs(dftPeriod - nz(dftPeriod[1])) / math.max(dftPeriod, 1)
    cycleConfidence := math.max(0, 100 - dftDrift * 500)

else
    // ---- Else, All Three ----
    float avgPeriod = (hilbertPeriod + acPeriod + dftPeriod) / 3

    float hilbertDev = math.abs(hilbertPeriod - avgPeriod) / avgPeriod
    float acDev      = math.abs(acPeriod      - avgPeriod) / avgPeriod
    float dftDev     = math.abs(dftPeriod     - avgPeriod) / avgPeriod

    int agreementCount = 0
    if hilbertDev <= confirmationThreshold
        agreementCount := agreementCount + 1
    if acDev <= confirmationThreshold
        agreementCount := agreementCount + 1
    if dftDev <= confirmationThreshold
        agreementCount := agreementCount + 1

    float totalWeight   = 0.0
    float weightedPeriod = 0.0

    float hilbertWeight = hilbertDev <= confirmationThreshold ? 1.0 : 0.5
    weightedPeriod := weightedPeriod + hilbertPeriod * hilbertWeight
    totalWeight    := totalWeight    + hilbertWeight

    float acWeight = acConfidence * (acDev <= confirmationThreshold ? 1.5 : 0.75)
    weightedPeriod := weightedPeriod + acPeriod * acWeight
    totalWeight    := totalWeight    + acWeight

    float dftWeight = dftDev <= confirmationThreshold ? 1.0 : 0.5
    weightedPeriod := weightedPeriod + dftPeriod * dftWeight
    totalWeight    := totalWeight    + dftWeight

    confirmedPeriod := totalWeight > 0 ? weightedPeriod / totalWeight : avgPeriod
    cycleConfidence := (agreementCount / 3.0) * 100

// ---- Deviation references ----
float hilbertDev_disp = cycleMode == "All Three (Confirmed)" ? math.abs(hilbertPeriod - (hilbertPeriod + acPeriod + dftPeriod) / 3) / ((hilbertPeriod + acPeriod + dftPeriod) / 3) : 0.0
float acDev_disp      = cycleMode == "All Three (Confirmed)" ? math.abs(acPeriod      - (hilbertPeriod + acPeriod + dftPeriod) / 3) / ((hilbertPeriod + acPeriod + dftPeriod) / 3) : 0.0
float dftDev_disp     = cycleMode == "All Three (Confirmed)" ? math.abs(dftPeriod     - (hilbertPeriod + acPeriod + dftPeriod) / 3) / ((hilbertPeriod + acPeriod + dftPeriod) / 3) : 0.0

// Final smoothing
var float finalPeriod = 0.0
finalPeriod := 0.15 * confirmedPeriod + 0.85 * nz(finalPeriod[1])
finalPeriod := math.max(minPeriod, math.min(maxPeriod, finalPeriod))

// ==================== CYCLE RSI ====================
int rsiPeriod = math.max(2, math.round(finalPeriod * rsiMult))

float change = src - src[1]
float gain = math.max(change, 0)
float loss = math.max(-change, 0)

float alphaRSI = 2.0 / (rsiPeriod + 1)
var float avgGain = 0.0
var float avgLoss = 0.0

avgGain := alphaRSI * gain + (1 - alphaRSI) * nz(avgGain[1])
avgLoss := alphaRSI * loss + (1 - alphaRSI) * nz(avgLoss[1])

float cycleRSI = avgLoss == 0 ? 100 : avgGain == 0 ? 0 : 100 - (100 / (1 + avgGain / avgLoss))

// ==================== STOCHASTIC OF RSI ====================
int stochPeriod = math.max(5, math.round(finalPeriod * stochMult))

var float highestRSI = na
var float lowestRSI = na

highestRSI := cycleRSI
lowestRSI := cycleRSI
for i = 1 to maxPeriod
    if i < stochPeriod
        highestRSI := math.max(highestRSI, nz(cycleRSI[i]))
        lowestRSI := math.min(lowestRSI, nz(cycleRSI[i]))

float rawK = highestRSI - lowestRSI != 0 ? 100 * (cycleRSI - lowestRSI) / (highestRSI - lowestRSI) : 50

// K and D smoothing
float kLine = ma(kMaType, rawK, kSmooth, almaOffset, almaSigma)
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
bool isModern = visualStyle == "Modern"

// Direction-based color
color lineCol = kLine >= nz(kLine[1], kLine) ? upCol : downCol

// Background
bool showConfBg = showConfidenceBg and cycleMode != "Hilbert Only"
color bgColor = showConfBg ? (cycleConfidence >= 66 ? color.new(color.green, 90) : cycleConfidence >= 33 ? color.new(color.yellow, 92) : color.new(color.red, 92)) : na
bgcolor(bgColor)

// --- Histogram ---
float hist = kLine - dLine
float histMaxAbs = ta.highest(math.abs(hist), histNormLength)
float histNorm = histMaxAbs > 0 ? hist / histMaxAbs : 0.0
float histDisp = 50 + histNorm * 30
bool histUp = hist >= 0
bool histGrow = hist >= nz(hist[1], hist)
int histFade = math.min(histTransp + 30, 100)
color histCol = histUp ? (histGrow ? color.new(upCol, histTransp) : color.new(upCol, histFade)) : (histGrow ? color.new(downCol, histFade) : color.new(downCol, histTransp))
plot(showHist ? histDisp : na, "Histogram (K - D)", color=histCol, style=plot.style_columns, histbase=50)

// --- OB/OS shading ---
hTop = hline(100, "Top", color=na, display=display.none)
hOB  = hline(80, "Overbought", color=color.new(downCol, 40), linestyle=hline.style_dashed)
hMid = hline(50, "Midline", color=color.new(color.gray, 55), linestyle=hline.style_dotted)
hOS  = hline(20, "Oversold", color=color.new(upCol, 40), linestyle=hline.style_dashed)
hBot = hline(0, "Bottom", color=na, display=display.none)
fill(hTop, hOB, color=showZones ? color.new(downCol, 92) : na, title="OB Zone")
fill(hOS, hBot, color=showZones ? color.new(upCol, 92) : na, title="OS Zone")

// --- Lines ---
plot(isModern ? kLine : na, "StochRSI", color=lineCol, linewidth=lineWidthModern)
plot((isModern and showSignalLine) ? dLine : na, "D (signal)", color=color.new(color.gray, 15), linewidth=2)
plot(not isModern ? kLine : na, "K", color=upCol, linewidth=2)
plot((not isModern and showSignalLine) ? dLine : na, "D", color=downCol, linewidth=2)

// ==================== DATA WINDOW AND TABLE ====================
plot(finalPeriod,    "Final Cycle Period",    display=display.data_window)
plot(hilbertPeriod,  "Hilbert Period",        display=display.data_window)
plot(useAC  ? acPeriod  : na, "Autocorrelation Period", display=display.data_window)
plot(useDFT ? dftPeriod : na, "DFT Period",             display=display.data_window)
plot(cycleConfidence, "Cycle Confidence %",  display=display.data_window)
plot(rsiPeriod,      "RSI Period",           display=display.data_window)
plot(stochPeriod,    "Stoch Period",         display=display.data_window)
plot(cycleRSI,       "Raw RSI",              display=display.data_window)
plot(kLine,          "K Value",              display=display.data_window)
plot(dLine,          "D Value",              display=display.data_window)
plot(hist,           "Histogram Value",      display=display.data_window)
plot(useAC ? acConfidence * 100 : na, "AC Correlation %", display=display.data_window)

// info table
var table infoTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_width=1)

if showCycleInfo and barstate.islast
    table.cell(infoTable, 0, 0, "Cycle Method", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, "Period", text_color=color.white, text_size=size.small)

    // Hilbert row
    bool hilbertActive = cycleMode == "All Three (Confirmed)" or cycleMode == "Hilbert Only"
    color hilbertRowCol = hilbertActive ? color.aqua : color.new(color.gray, 50)
    color hilbertValCol = cycleMode == "All Three (Confirmed)" ? (hilbertDev_disp <= confirmationThreshold ? color.lime : color.gray) : (cycleMode == "Hilbert Only" ? color.yellow : color.new(color.gray, 50))
    table.cell(infoTable, 0, 1, "Hilbert", text_color=hilbertRowCol, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(math.round(hilbertPeriod, 1)), text_color=hilbertValCol, text_size=size.small)

    // Autocorrelation
    bool acActive = cycleMode == "All Three (Confirmed)" or cycleMode == "Autocorrelation Only"
    color acRowCol = acActive ? color.aqua : color.new(color.gray, 50)
    color acValCol = cycleMode == "All Three (Confirmed)" ? (acDev_disp <= confirmationThreshold ? color.lime : color.gray) : (cycleMode == "Autocorrelation Only" ? color.yellow : color.new(color.gray, 50))
    table.cell(infoTable, 0, 2, "Autocorr", text_color=acRowCol, text_size=size.small)
    table.cell(infoTable, 1, 2, acActive ? str.tostring(math.round(acPeriod, 1)) : "—", text_color=acValCol, text_size=size.small)

    // DFT
    bool dftActive = cycleMode == "All Three (Confirmed)" or cycleMode == "DFT Only"
    color dftRowCol = dftActive ? color.aqua : color.new(color.gray, 50)
    color dftValCol = cycleMode == "All Three (Confirmed)" ? (dftDev_disp <= confirmationThreshold ? color.lime : color.gray) : (cycleMode == "DFT Only" ? color.yellow : color.new(color.gray, 50))
    table.cell(infoTable, 0, 3, "DFT", text_color=dftRowCol, text_size=size.small)
    table.cell(infoTable, 1, 3, dftActive ? str.tostring(math.round(dftPeriod, 1)) : "—", text_color=dftValCol, text_size=size.small)

    table.cell(infoTable, 0, 4, "CONFIRMED", text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(math.round(finalPeriod, 1)), text_color=color.yellow, text_size=size.small)

    table.cell(infoTable, 0, 5, "Confidence", text_color=color.white, text_size=size.small)
    color confColor = cycleConfidence >= 66 ? color.lime : cycleConfidence >= 33 ? color.yellow : color.red
    string confLabel = cycleMode == "Hilbert Only" ? "N/A" : str.tostring(math.round(cycleConfidence)) + "%"
    table.cell(infoTable, 1, 5, confLabel, text_color=cycleMode == "Hilbert Only" ? color.gray : confColor, text_size=size.small)

// Alerts
alertcondition(ta.crossover(kLine, dLine) and kLine < 30, "Bullish Cross in Oversold", "K crossed above D in oversold zone")
alertcondition(ta.crossunder(kLine, dLine) and kLine > 70, "Bearish Cross in Overbought", "K crossed below D in overbought zone")
alertcondition(cycleConfidence >= 66, "High Cycle Confidence", "All three cycle detection methods agree")
````

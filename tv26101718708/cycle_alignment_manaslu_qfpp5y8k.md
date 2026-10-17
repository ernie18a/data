# Cycle Alignment [Manaslu]

- url: https://www.tradingview.com/script/QfPP5Y8K-Cycle-Alignment-Manaslu/
- type: indicator
- pine_id: PUB;b65c8f7767af49c19fb92f846cb074c4
- version: 1.0

## Description

Cycle Alignment [Manaslu] is the foundational Congruence component of the ET Massif Framework research suite.

[b]1. Description[/b]
Manaslu is a dual adaptive band-pass filter (BPF) derived from concepts popularized by John Ehlers. A band-pass filter is a signal-processing technique designed to emphasize oscillations occurring within a selected range of cycle lengths while suppressing both slower trend components and higher-frequency noise. In market data, this allows cyclical behavior to be isolated and observed more clearly, revealing structure that may otherwise be obscured by broader trends or short-term fluctuations.[image]https://www.tradingview.com/x/k0xFVmju/[/image]
What distinguishes Manaslu is that it does not focus on a single filtered signal. Instead, it constructs two independent adaptive band-pass filters, each with its own dynamically estimated cycle period. The objective is to evaluate phase congruence, divergence, and synchronization between two inputs (indicators).

Manaslu is not intended to identify dominant market cycles, perform spectral decomposition, or estimate cycle periodicity for forecasting purposes. Its primary role is to study the phase relationship between two adaptive cyclical structures rather than the characteristics of either structure in isolation.[image]https://www.tradingview.com/x/H0eVl5Rm/[/image]
[b]2. Construct[/b]
[b]A. Adaptive Period Estimation[/b]
For each input (series), an adaptive cycle period is estimated :
[list]
[*]Crossovers between the input and its moving average are identified
[*]The time distance between successive crossover events is measured as a half-cycle and doubled to estimate the full cycle length
[*]A user-defined minimum cycle floor is applied to ensure stability
[/list][b]B. Detrending[/b]
A two-bar difference operation detrends each source before filtering. This removes the slower trend component and allows the filter to focus on cyclical behavior.
[pine]x = 0.5 × (Price − Price[2])[/pine]
[b]C. Band-Pass Filter [/b]
The adaptive period is applied to a second-order Ehlers-style band-pass filter.
[pine]beta = cos(2π / Period)
gamma = 1 / cos(4π × Delta / Period)
alpha = gamma − √(gamma² − 1)
out = 0.5 × (1 − alpha) × (x − x[2]) + beta × (1 + alpha) × out[1] − alpha × out[2]
[/pine][list]
[*]Beta — the frequency tuning coefficient that positions the filter around the target cycle period
[*]Gamma — the bandwidth controller that determines the allowed deviation around the core cycle period using Delta
[*]Delta — the user-defined bandwidth spread parameter controlling the tolerance window around the primary period
[*]Alpha — the smoothing and feedback weight derived from Gamma that controls filter decay and stability
[/list][b]D. Normalization[/b]
Each band-pass output is normalized independently against its recent peak amplitude. This allows two inputs with different scales, volatility profiles, or magnitudes to be compared directly.[image]https://www.tradingview.com/x/7efsV9kV/[/image]The examples shown in this script description uses an oscillator as the primary input and a moving average as the comparator input for the band-pass filter. These inputs are for illustrative purposes only and are not part of the script itself.

[b]3, Rationale[/b]
Band-pass filters are applied primarily to extract cyclic behavior and reduce the impact of random noise and fluctuations. By attenuating both very slow and very fast movements, a band-pass filter can produce a cleaner representation of the market's oscillatory structure. In the context of Manaslu, the objective is not to forecast future cycles but to create a consistent framework for comparing indicator on indicator phase congruence. 

Potential inputs include moving averages, RSI variants, oscillators, denoised trend indicators, adaptive filters, and other cyclical or transformed data series.[image]https://www.tradingview.com/x/rcMtbjj8/[/image]
Picture Danny (John Travolta) and Sandy (Olivia Newton-John) on the dance floor in Grease. Each dance to their own beat and rhythm. When both move in rhythm, the performance appears coordinated and confident. When one speeds up, slows down, or turns against the other, the performance becomes less coherent — even though both are still moving. Manaslu attempts to visualize that relationship between two indicators. The focus is on how congruently they move together, not on the individual cycles themselves.[image]https://www.tradingview.com/x/HUGBaqds/[/image]
[b]4. Interpretation

A. In-Phase [/b]
Both cycles rise and fall together. This suggests broad agreement between the selected inputs. Indicators exhibiting strong phase congruence may warrant greater confidence.[image] https://www.tradingview.com/x/WQUtlXsk/[/image]
[b]B. Approximately 180° Out of Phase[/b] 
The cycles move in opposite directions. Both structures remain active but opposing forces are present. This condition may indicate reduced directional efficiency, internal conflict, or a tendency for moves to taper as opposing influences interact.[image]https://www.tradingview.com/x/eH5jPIqe/[/image]
[b]C. One Stable, One Erratic [/b]
One cycle exhibits coherent structure while the other appears unstable or erratic. Users should determine which input carries greater analytical importance — which is closer to price, which is driving decision-making, and whether the erratic structure is background noise or beginning to influence price behavior. Context matters more than visual appearance alone.
[image]https://www.tradingview.com/x/72riuudm/[/image]
[b]D. Both Erratic [/b]
Neither cycle displays clear structure. Phase relationships become unreliable. Confidence in the underlying indicators should generally be reduced until more coherent structure emerges.[image]https://www.tradingview.com/x/u9EJjcYp/[/image][b]General Caveats[/b] 
Band-pass filters are sensitive to changing market conditions. Phase relationships can shift rapidly during transitions between trend and range environments. Temporary synchronization does not imply causation, prediction, or future persistence. Manaslu should be viewed as a relationship analysis tool rather than a standalone signal generator.

Like all filters, a band-pass filter represents a mathematical model rather than a direct observation of market behaviour. Its output depends on the selected parameters and may change as market conditions evolve. Consequently, the filtered waveform should be interpreted as a representation of cyclical structure rather than proof of an underlying market cycle.

[b]Default Settings[/b]
Bandwidth: 0.025 
Minimum cycle length: 40 
Primary Input: HL2 
Comparator Input: Close
To use another indicator's output as an input, add that indicator to your chart, then in the Settings → Inputs tab select the relevant plot from the input dropdown.

[b]日本語概要 (Japanese Summary)[/b]
Manaslu は、ET Massif Framework における Congruence（整合性） 研究コンポーネントです。 独立した2つの適応型サイクル構造を比較し、その位相の同調や乖離、同期状態の観測を目的としています。 なお、本指標は将来のサイクル予測やドミナントサイクルの検出を目的とするものではありません。 移動平均線、RSI、オシレーター、各種フィルターといった異なる指標間の関係性を評価し、2つの構造がどの程度協調して動いているかを観察するための分析ツールです。

[b]中文概要（Chinese Summary）[/b]
Manaslu 是 ET Massif Framework 中的 Congruence（整合性） 研究元件。 本指標旨在比較兩個獨立的自適應週期結構，並觀察其相位的一致、不一致以及同步狀態。
須注意的是，本指標並非用於未來週期預測，亦非用於偵測主導週期（Dominant Cycle）。其主要用途在於評估不同指標之間的關聯性，例如：均線、RSI、震盪指標以及各類濾波器等。
它並非針對週期本身進行常規分析，而是一款用以觀察兩個結構之間協調運作程度的分析工具。

[b]Disclaimer:[/b]
This script is a research tool for market structure analysis and educational purposes only. It does not constitute financial advice. Trading involves risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © et20tradeview

//@version=6
indicator('Cycle Alignment [Manaslu]', overlay=false)

//---Inputs---
src       = input.source(hl2, 'Primary')
src2      = input.source(close, 'Comparator')
bandwidth = input.float(0.025, 'Bandwidth (Tuning)', minval=0.001, maxval=1.0, step=0.005)
lookback  = input.int(10, 'crossover lookback')
minCycle  = input.int(40, 'minimum cycle length')  // Your minimum period floor


//---Variables---
var float lastCrossBar = 0
var float lastCrossBar2 =0

var float smoothedFullSpan = 40.0  
var float smoothedFullSpan2 = 40.0


//----Functions---

f_adaptive_period(src, lookback, minCycle) =>
    var float lastCross = 0.0
    var float smoothed  = float(minCycle)

    // Check for any crossover between price and its moving average
    if ta.cross(src, ta.sma(src, lookback))

        // Calculate the 'New' raw measurement (Half-Cycle * 2 = Full Cycle)
        float measured = (bar_index - lastCross) * 2

        // Update the 'Old' value using the 25% Smoothing Rule
        smoothed      := 0.25 * measured + 0.75 * smoothed
        lastCross     := bar_index
    math.max(smoothed, minCycle)


detrend(Series) =>
    // 1. Calculate the raw 2-bar difference
    float change = Series - Series[2]
    
    // 2. Fallback safety net for the first 2 bars on the chart
    if na(Series[2])
        change := na(Series[1]) ? 0.0 : Series - Series[1]
        
    // 3. Return the scaled result
    0.5 * change


bpf(Series, Period, Delta) =>
     // Ensure Period isn't zero to avoid division by zero errors
    float p = Period < 2 ? 2 : Period
    var float output = 0.0

    //beta : frequency co-efficient
    //gamma: bandwidth
    //alpha: filter decay

    float beta  = math.cos(3.14 * (360 / Period) / 180)
    float gamma = 1.0 / math.cos(3.14 * (720 * Delta / Period) / 180)
    float alpha = gamma - math.sqrt(math.pow(gamma, 2) - 1.0)

    detrended = detrend(Series)

    //Filter recursive output
    output := 0.5 * (1.0 - alpha) * (detrended - nz(detrended[2])) +  beta * (1.0 + alpha) * nz(output[1]) -  alpha * nz(output[2])
    output


// Define a robust normalization function
// This ensures both indicators scale to their own recent intensity independently.
f_normalize_vibe(src, len) =>
    float _abs_src = math.abs(src)
    float _peak = ta.highest(_abs_src, len)
    float _res  = src / (_peak > 0 ? _peak : 1e-10)
    _res


//----Calculation---

//--- 1. Find the adaptive cycle length
finalAdaptiveSpan  = f_adaptive_period(src,  lookback, minCycle)
finalAdaptiveSpan2 = f_adaptive_period(src2, lookback, minCycle)

//--- 2. Apply the Bandpass Filter
cycle = bpf(src, finalAdaptiveSpan , bandwidth)
cycleP = bpf(src2, finalAdaptiveSpan2 , bandwidth)

//--- 3. Normalize the Bandpass Filter (BPF) outputs
normcycle   = f_normalize_vibe(cycle, 50)  // base cyycle
normcycleP  = f_normalize_vibe(cycleP, 50) // comparator cycle

//--- 4. Normalization (keeps it visually consistent)
peak = ta.highest(math.abs(cycle), 50)
normalizedCycle = cycle / (peak > 0 ? peak : 1e-10)

peakP = ta.highest(math.abs(cycleP), 50)
normalizedCycleP = cycleP / (peakP > 0 ? peakP : 1e-10)


//--Plots---
plot(normcycle, "Adaptive Cycle", color=#ffea00, linewidth=2)
plot(normcycleP, "Adaptive Cycle", color=color.rgb(46, 239, 226), linewidth=2)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
````

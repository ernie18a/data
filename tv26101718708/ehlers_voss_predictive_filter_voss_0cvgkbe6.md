# Ehlers Voss Predictive Filter (VOSS)

- url: https://www.tradingview.com/script/0cvGKBE6-Ehlers-Voss-Predictive-Filter-VOSS/
- type: indicator
- pine_id: PUB;d51bce8258984b0bbd66fcc6659951e2
- version: 1.0

## Description

The Voss Predictive Filter is a two-stage signal processing pipeline that extracts a dominant cycle from noisy price data and predicts its future trajectory. By utilizing negative group delay, it creates a leading oscillator that anticipates bandpass zero crossings. Crossings between the base filter (Filt) and the predictor (Voss) generate early, high-fidelity trade signals with significantly reduced lag.

HISTORICAL CONTEXT

Introduced by John Ehlers in his August 2019 article "A Peek Into the Future," the algorithm builds on theoretical physics work by Henning U. Voss. Voss demonstrated that universal negative delay filters could be constructed using weighted feedback over a finite history of output samples. Ehlers adapted this to financial time series by pairing it with his two-pole bandpass filter.

Unlike standard "zero-lag" moving averages that merely reduce delay by mathematical overshooting, the Voss predictor achieves genuine anticipation by exploiting the mathematical structure of narrowband signals. When the input contains a dominant cycle near the tuned period, the predictor reconstructs future values with high fidelity.

HOW IT WORKS

Stage 1: Two-Pole Bandpass Filter (BPF)
The script first isolates cycles near a specified Period using a recursive filter structure. A differencing calculation removes the DC component (the underlying trend), centering the oscillator at zero. The Bandwidth parameter controls how tightly the filter rejects frequencies outside the target cycle.

Stage 2: The Voss Predictor
The predictor computes a weighted sum of its own past values over a specific lookback history (Order = 3 × Predict). Each past value is assigned a linearly increasing weight. This feedback loop shifts the filter response forward in time, creating a net negative group delay exactly equal to your "Predict" parameter.

INPUTS & PARAMETERS

Period: Sets the center frequency of the bandpass filter. Should approximately align with the market's current dominant cycle. Default: 20.
Predict: The number of bars to look into the future (the amount of negative delay). Default: 3.
Bandwidth: Controls the selectivity (Q factor) of the bandpass filter. Lower values narrow the passband. Default: 0.25.

HOW TO USE

[b]Crossings and Early Signals[/b]
The indicator plots two lines: Filt (the baseline cycle) and Voss (the predicted cycle).
Bullish Signal: The Voss line crosses above the Filt line.
Bearish Signal: The Voss line crosses below the Filt line.
Because Voss leads Filt by the "Predict" parameter, these crossings anticipate the actual cycle's zero-crossings, getting you into the move earlier.

[b]Cycle Phase Interpretation[/b]
Both lines oscillate around zero. They represent the phase and momentum of the dominant cycle, not absolute price targets. Use the crossings for timing, not the levels for price prediction.

[b]Broadband Graceful Degradation[/b]
If the market stops cycling and enters a broadband noise or pure trend state, prediction accuracy degrades gracefully, and the Voss output simply reverts toward the standard bandpass filter line.

LIMITATIONS

Mistuning Penalty: The predictor relies on the "Period" matching the actual dominant cycle in the data. Mistuning by more than 30% degrades prediction accuracy significantly.
Noise Amplification: Setting "Predict" too high (e.g., > 5) requires a deep lookback history (Order > 15), which heavily amplifies noise in the feedback loop. Practical values are between 2 and 5.
Ringing: Setting the "Bandwidth" below 0.1 makes the filter highly selective. While smooth, it will "ring" excessively and respond very slowly to actual cycle changes.
Warmup Time: The bandpass filter needs approximately "Period" bars to stabilize. Signals immediately after the start of the chart are unreliable.

REFERENCES

Ehlers, J. F. "A Peek Into the Future." Technical Analysis of Stocks and Commodities, August 2019.
Voss, H. U. "Anticipating chaotic synchronization." Physical Review E, 61(5), 2000.
Ehlers, J. F. Cycle Analytics for Traders. Wiley, 2013.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj
//@version=6
indicator("Ehlers Voss Predictive Filter (VOSS)", "VOSS", overlay=false)

//@function Ehlers Voss Predictive Filter — negative group delay bandpass predictor
//@param source Series to filter
//@param period Primary cycle period (bars)
//@param predict Prediction bars (negative delay amount)
//@param bandwidth Bandpass tolerance (fraction of period)
//@returns [filt, voss] — bandpass output and predictive filter output
//@optimized Two-pole BPF + weighted feedback predictor, O(Order) per bar
voss(series float src, simple int period, simple int predict, simple float bandwidth) =>
    // --- Filter constants (computed once, recomputed if params change) ---
    var int _order = 0
    var float _f1 = 0.0
    var float _s1 = 0.0
    var int _prev_period = 0
    var int _prev_predict = 0
    var float _prev_bw = 0.0

    if _prev_period != period or _prev_predict != predict or _prev_bw != bandwidth
        _order := 3 * predict
        _f1 := math.cos(2.0 * math.pi / float(period))
        float g1 = math.cos(bandwidth * 2.0 * math.pi / float(period))
        _s1 := 1.0 / g1 - math.sqrt(1.0 / (g1 * g1) - 1.0)
        _prev_period := period
        _prev_predict := predict
        _prev_bw := bandwidth

    // --- Stage 1: Two-pole Bandpass Filter ---
    // Filt = 0.5*(1-S1)*(src - src[2]) + F1*(1+S1)*Filt[1] - S1*Filt[2]
    var float filt = na
    float ssrc = nz(src, src[1])
    float src2 = nz(src[2], ssrc)
    float filt1 = nz(filt[1], 0.0)
    float filt2 = nz(filt[2], 0.0)
    filt := 0.5 * (1.0 - _s1) * (ssrc - src2) + _f1 * (1.0 + _s1) * filt1 - _s1 * filt2
    if bar_index <= 5
        filt := 0.0

    // --- Stage 2: Voss Predictor ---
    // SumC = sum of ((count+1)/Order) * Voss[Order - count] for count = 0 to Order-1
    // Voss = ((3 + Order) / 2) * Filt - SumC
    var float voss_val = na
    float sumC = 0.0
    for count = 0 to _order - 1
        int idx = _order - count
        sumC += (float(count + 1) / float(_order)) * nz(voss_val[idx], 0.0)
    voss_val := (float(3 + _order) / 2.0) * filt - sumC
    [filt, voss_val]

// ---------- Main loop ----------

// Inputs
i_period    = input.int(20, "Period", minval=2, tooltip="Primary cycle period in bars")
i_predict   = input.int(3, "Predict", minval=1, tooltip="Prediction bars (negative delay)")
i_bandwidth = input.float(0.25, "Bandwidth", minval=0.01, maxval=0.99, step=0.05,
              tooltip="Bandpass tolerance as fraction of period")
i_source    = input.source(close, "Source")

// Calculation
[filt, voss_out] = voss(i_source, i_period, i_predict, i_bandwidth)

// Plot
plot(filt, "Bandpass", color=color.red, linewidth=1)
plot(voss_out, "Voss", color=color.new(color.blue, 0), linewidth=2)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)
````

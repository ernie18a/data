# Ehlers Cybernetic Oscillator (v6)

- url: https://www.tradingview.com/script/DvsGrDHQ-Ehlers-Cybernetic-Oscillator-v6/
- type: indicator
- pine_id: PUB;6bb89d401ce442079f7ea74d64003fa1
- version: 1.0

## Description

The script below implements the Ehlers Cybernetic Oscillator, adapted directly for Pine Script v6. It applies a specialized highpass filter to eliminate market noise, smooths it using a 2-pole SuperSmoother filter to eliminate lag, and scales it according to its Root Mean Square (RMS).  

How to use this indicator:

Zero-Line Crossings: When the Blue main line crosses above 0, it indicates a shifting bullish trend acceleration with minimized lag.

Signal Crossings: When the Blue line crosses above the Orange line below the zero line, it signals an early cyclic entry setup.

## Source Code

````pine
//@version=6
indicator("Ehlers Cybernetic Oscillator (v6)", shorttitle="Ehlers CybOsc", overlay=false)

// Input Parameters
src = input.source(close, title="Source")
hpLength = input.int(30, title="HighPass Length", minval=1)
lpLength = input.int(20, title="SuperSmoother Length", minval=1)

// --- 1. Ehlers HighPass Filter ---
method highPass(float price, int period) =>
    float a1 = math.exp(-1.414 * math.pi / period)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / period)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = (1.0 + c2 - c3) / 4.0
    
    // Allocate state variables to persist values across bars
    var float hp = 0.0
    var float pr1 = 0.0
    var float pr2 = 0.0
    var float hp1 = 0.0
    var float hp2 = 0.0
    
    if bar_index >= 4
        hp := c1 * (price - 2.0 * pr1 + pr2) + c2 * hp1 + c3 * hp2
    else
        hp := 0.0
        
    // Shift states manually inside the method context
    pr2 := pr1
    pr1 := price
    hp2 := hp1
    hp1 := hp
    hp

// --- 2. Ehlers SuperSmoother Filter ---
method superSmoother(float price, int period) =>
    float a1 = math.exp(-1.414 * math.pi / period)
    float b1 = 2.0 * a1 * math.cos(1.414 * math.pi / period)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1.0 - c2 - c3
    
    var float lp = 0.0
    var float pr1 = 0.0
    var float lp1 = 0.0
    var float lp2 = 0.0
    
    if bar_index >= 4
        lp := c1 * (price + pr1) / 2.0 + c2 * lp1 + c3 * lp2
    else
        lp := price
        
    pr1 := price
    lp2 := lp1
    lp1 := lp
    lp

// --- Calculation Pipeline ---
// Compute HighPass, then feed its output directly into the SuperSmoother
float hpSignal = src.highPass(hpLength)
float smoothLP = hpSignal.superSmoother(lpLength)

// --- 3. Root Mean Square (RMS) Normalization ---
// Calculate sum of squares over a 100-period rolling window
float sumSq = 0.0
for i = 0 to 99
    sumSq += smoothLP[i] * smoothLP[i]

float rms = math.sqrt(sumSq / 100.0)

// Final Oscillator Value
float cyberneticOsc = (rms != 0.0) ? (smoothLP / rms) : 0.0
float triggerLine = cyberneticOsc[1]

// --- Visualizing the Data ---
hline(0.0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
hline(1.0, "Overbought", color=color.red, linestyle=hline.style_dotted)
hline(-1.0, "Oversold", color=color.green, linestyle=hline.style_dotted)

plot(cyberneticOsc, title="Cybernetic Oscillator", color=color.blue, linewidth=2)
plot(triggerLine, title="Trigger Line", color=color.orange, linewidth=1)
````

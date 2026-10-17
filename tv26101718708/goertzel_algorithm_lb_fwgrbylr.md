# Goertzel Algorithm [LB]

- url: https://www.tradingview.com/script/FwgRBYlr/
- type: indicator
- pine_id: PUB;e0b12e6dc61541c29a6a170f12d3ae90
- version: 1.0

## Description

[b]🔬 Concept[/b]
The Goertzel Algorithm, developed by Gerald Goertzel in 1958, is a digital signal processing technique that efficiently computes individual terms of the Discrete Fourier Transform (DFT). Unlike a full FFT which calculates all frequency bins, the Goertzel Algorithm targets a single predetermined frequency — making it the optimal tool for detecting the presence and power of a specific cycle period within a price series.

[b]📐 Mathematical Foundation[/b]
The algorithm implements a second‑order recursive filter with a resonance at the target frequency. For a target period [i]T[/i], the normalized angular frequency is :

[i]ω = 2π / T[/i]

The recurrence relation is applied to each sample [i]x[n][/i] in the window :

[i]Q[n] = x[n] + 2·cos(ω)·Q[n-1] - Q[n-2][/i]

After processing [i]N[/i] samples, the complex DFT coefficient is extracted without storing intermediate values :

[i]Re = Q[N-1] - Q[N-2]·cos(ω)[/i]
[i]Im = Q[N-2]·sin(ω)[/i]

The output is the squared magnitude (power) of that frequency component :

[i]Power = Re² + Im²[/i]

This approach requires only one multiply and two additions per sample, making it substantially lighter than a full FFT when monitoring a single cycle.

[b]🎯 What Problem Does It Solve ?[/b]
Classic oscillators and moving averages operate blindly across all frequencies, mixing signal and noise. FFT‑based indicators attempt spectral analysis but compute hundreds of unnecessary frequency bins, wasting computational resources and introducing lag. The Goertzel Algorithm isolates the exact cycle period the trader wants to monitor, delivering pure frequency‑domain intelligence with minimal overhead.

[b]📊 How To Interpret[/b]
[i]Power rising and sustained at high levels[/i] → the target cycle period is strongly present in the price action ; the market is respecting the chosen rhythm.
[i]Power declining toward zero[/i] → the target cycle has faded ; the market is no longer oscillating at that frequency.
[i]Sharp power spike[/i] → the cycle has suddenly emerged ; potential entry signal when a known period (e.g., 20‑bar) becomes active.
[i]Compare multiple instances with different periods[/i] → add the indicator twice with different target periods (e.g., 10 and 20 bars) to see which cycle dominates.

[b]⚙️ Parameters[/b]
[b]Target Period (bars)[/b] – the exact cycle length to detect ; typical values are 10, 20, 50, or any dominant cycle observed on the chart.
[b]Analysis Window Length[/b] – number of bars over which the algorithm computes the power ; longer windows give more frequency resolution but slower response.
[b]Source[/b] – price data used as input (close, HLC3, etc.).

[b]📚 Reference[/b]
Goertzel G., "An Algorithm for the Evaluation of Finite Trigonometric Series", The American Mathematical Monthly, Vol. 65, No. 1, pp. 34‑35, January 1958.
Proakis J.G. & Manolakis D.G., "Digital Signal Processing : Principles, Algorithms, and Applications", Chapter 6 – Efficient Computation of the DFT, Prentice Hall, 1996.

## Source Code

````pine
//@version=6
indicator("Goertzel Algorithm [LB]", overlay=false)

// === PARAMÈTRES ===
periodTarget  = input.int(20,   "Target Period (bars)", minval=2, tooltip="The cycle period to detect")
windowLength  = input.int(100,  "Analysis Window Length", minval=3, tooltip="Number of bars in the sliding window")
src           = input.source(close, "Source")

// === PRÉCALCUL DES CONSTANTES THÉORIQUES ===
var float k         = na
var float omega     = na
var float coeff     = na
var float sin_omega = na
var float cos_omega = na

if barstate.isfirst
    // Fréquence cible normalisée
    targetFreq = 1.0 / periodTarget
    // Pulsation numérique
    omega     := 2.0 * math.pi * targetFreq
    // Cosinus et sinus (précalculés pour stabilité)
    cos_omega := math.cos(omega)
    sin_omega := math.sin(omega)
    // Coefficient de récurrence
    coeff     := 2.0 * cos_omega

// === FONCTION DE CALCUL THÉORIQUE POUR UNE FENÊTRE ===
get_goertzel_power(source_array, N, coeff_val, cos_val, sin_val) =>
    float Q1 = 0.0  // Q(n-1)
    float Q2 = 0.0  // Q(n-2)
    
    // Récurrence de Goertzel (ordre 2)
    for n = 0 to N - 1
        float x = array.get(source_array, n)
        float Q0 = x + coeff_val * Q1 - Q2
        Q2 := Q1
        Q1 := Q0
    
    // Version numériquement stable pour la puissance
    float real_part = Q1 - Q2 * cos_val
    float imag_part = Q2 * sin_val
    float power_val = real_part * real_part + imag_part * imag_part
    
    power_val

// === CALCUL GLISSANT À CHAQUE BARRE ===
var float power = na

if bar_index >= windowLength - 1
    // Construction du tableau des échantillons (ordre chronologique)
    var array<float> samples = array.new<float>()
    array.clear(samples)
    
    // Remplir du plus ancien (index haut) au plus récent (index bas)
    for i = 0 to windowLength - 1
        array.push(samples, src[windowLength - 1 - i])
    
    // Calcul de la puissance théorique
    power := get_goertzel_power(samples, windowLength, coeff, cos_omega, sin_omega)

// === TRACÉ ===
plot(power, "Theoretical Goertzel Power", color=color.new(#FF6B6B, 0), linewidth=2)

// Ligne zéro pour référence
hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

// Ligne de la période cible théorique (pour info)
var line targetLine = na
if barstate.islast
    float maxPower = ta.highest(power, 500)
    if not na(maxPower) and maxPower > 0
        targetLine := line.new(bar_index - 1, maxPower * 0.5, bar_index, maxPower * 0.5, 
         color=color.new(color.yellow, 70), width=1, style=line.style_dotted)
````

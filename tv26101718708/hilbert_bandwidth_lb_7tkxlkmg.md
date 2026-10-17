# Hilbert Bandwidth [LB]

- url: https://www.tradingview.com/script/7tKxlkmg/
- type: indicator
- pine_id: PUB;d0ff09e099634795982fb7a15060f64a
- version: 1.0

## Description

[b]🔬 Concept[/b]
The Hilbert Bandwidth Index, derived from John Ehlers' analytic signal approach, measures the instantaneous stability of the dominant market cycle by computing the bandwidth — the absolute deviation between the raw instantaneous period and its smoothed counterpart. A narrow bandwidth indicates a clean, well-defined cycle suitable for trading.

[b]📐 Mathematical Foundation[/b]
The price median is transformed via a 7‑coefficient FIR Hilbert Transform to extract the analytic signal's real and imaginary components :

[i]real = 0.0962·P[t] + 0.5769·P[t-2] - 0.5769·P[t-4] - 0.0962·P[t-6][/i]
[i]imag = 0.0962·P[t-1] + 0.5769·P[t-3] - 0.5769·P[t-5] - 0.0962·P[t-7][/i]

The instantaneous phase [i]φ[/i] is obtained via the two‑argument arctangent of [i]imag[/i] and [i]real[/i]. After exponential smoothing, the phase difference [i]Δφ[/i] between consecutive bars yields the instantaneous period :

[i]T = 2π / |Δφ|[/i]

Finally, the bandwidth is defined as :

[i]B = |T - EMA(T, L)[/i]|

where [i]L[/i] is the period smoothing length. The result is expressed in bars.

[b]🎯 What Problem Does It Solve ?[/b]
Traditional cycle indicators assume a persistent dominant cycle, producing unreliable signals during chaotic or transitional markets — the Hilbert Bandwidth quantifies cycle cleanliness in real time, allowing traders to filter out low‑quality cyclic signals and act only when the market exhibits a stable, tradeable rhythm.

[b]📊 How To Interpret[/b]
[i]Bandwidth below threshold (background colored)[/i] → the dominant cycle is narrow, well‑defined, and stable ; trend‑following and cycle‑based strategies have higher probability of success.
[i]Bandwidth above threshold[/i] → the cycle is broad and unstable ; the market is either noisy or in transition ; avoid cycle‑dependent entries.
[i]Bandwidth rapidly contracting[/i] → the market is shifting from chaos to order ; anticipate a breakout or the emergence of a clean trend.

[image]https://www.tradingview.com/x/bpiWRmpq/[/image]

[b]⚙️ Parameters[/b]
[b]Phase Smoothing[/b] – exponential smoothing length applied to the instantaneous phase (default 50) ; higher values stabilize the phase estimate but introduce lag.
[b]Period Smoothing[/b] – EMA length applied to the instantaneous period (default 10) ; controls the responsiveness of the bandwidth calculation.
[b]Narrow Band Threshold[/b] – the bandwidth value in bars below which the cycle is considered "clean" (default 3.0) ; the background is highlighted when bandwidth falls below this level.

[b]📚 Reference[/b]
Ehlers J.F., "Rocket Science for Traders : Digital Signal Processing Applications", Chapter 7 – The Hilbert Transform, John Wiley & Sons, 2001.
Ehlers J.F., "Cycle Analytics for Traders", Chapter 9 – Bandwidth Measurement, John Wiley & Sons, 2014.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// INDICATEUR : Hilbert Bandwidth Index
// Concept    : Bande passante instantanée d'un cycle (Ehlers)
//              Phase extraite par transformée de Hilbert,
//              largeur du cycle en barres.
// Auteur     : Luis Barlier
// Style      : Minimaliste – 1 ligne, fond noir, coloration
//              quand le cycle est « net » (bande étroite).
// ═══════════════════════════════════════════════════════════════
indicator("Hilbert Bandwidth [LB]", overlay=false)
bgcolor(color.new(#000000, 100))

// ── PARAMÈTRES ────────────────────────────────────────────
smoothLength  = input.int(50, "Lissage phase", minval=10)
periodSmooth  = input.int(10, "Lissage période", minval=2)
seuilBande    = input.float(3.0, "Seuil bande étroite", minval=0.5, step=0.5)

// ── PRIX MÉDIAN ───────────────────────────────────────────
prix = (high + low) / 2

// ── TRANSFORMÉE DE HILBERT FIXE (FIR 7 barres) ──────────
// Coefficients d'Ehlers pour le signal analytique
real = 0.0962*prix + 0.5769*prix[2] - 0.5769*prix[4] - 0.0962*prix[6]
imag = 0.0962*prix[1] + 0.5769*prix[3] - 0.5769*prix[5] - 0.0962*prix[7]

// ── PHASE INSTANTANÉE (atan2 manuel) ─────────────────────
phase = 0.0
if imag != 0 or real != 0
    phase := math.atan(imag / real)
    // Ajustement du quadrant
    if real < 0
        if imag >= 0
            phase += math.pi
        else
            phase -= math.pi

// Lissage exponentiel de la phase
alpha = 2.0 / (smoothLength + 1)
phaseLisse = 0.0
phaseLisse := alpha * phase + (1 - alpha) * nz(phaseLisse[1], phase)

// Différence de phase (déroulement manuel)
delta = phaseLisse - nz(phaseLisse[1], phaseLisse)
if delta < -math.pi
    delta += 2 * math.pi
else if delta > math.pi
    delta -= 2 * math.pi

// ── PÉRIODE INSTANTANÉE (en barres) ─────────────────────
// Protection division par zéro
instPeriode = 2 * math.pi / math.max(math.abs(delta), 0.0001)

// Lissage de la période
periodeLisse = ta.ema(instPeriode, periodSmooth)

// ── BANDE PASSANTE INSTANTANÉE = largeur du cycle ───────
bande = math.abs(instPeriode - periodeLisse)

// ── SORTIE ───────────────────────────────────────────────
plot(bande, "Bande passante", color=color.new(#00bcd4, 0), linewidth=2)

// Coloration du fond quand le cycle est net (bande étroite)
couleurFond = bande < seuilBande ? color.new(#00bcd4, 90) : na
bgcolor(couleurFond, title="Cycle net")

// Ligne de seuil
hline(seuilBande, "Seuil", color.new(#ffffff, 70), linestyle=hline.style_dashed)
````

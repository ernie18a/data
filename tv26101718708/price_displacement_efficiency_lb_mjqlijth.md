# Price Displacement Efficiency [LB]

- url: https://www.tradingview.com/script/MJQLiJTH/
- type: indicator
- pine_id: PUB;c92ad90c12c94cb89ebb9890be57cb83
- version: 1.0

## Description

HI trader, [image]https://www.tradingview.com/x/DKHOwwLS/[/image]The [b]Price Displacement Efficiency (PDE)[/b] is a momentum-oscillator designed to measure the "straightness" of price action. Based on the principles of market geometry and efficiency, it evaluates whether the market is moving with conviction in a specific direction or if it is merely "churning" with high volatility but little net progress.

[b]The Problem It Solves:[/b]
Standard indicators often fail to distinguish between [i]high-volatility noise[/i] and [i]genuine trend displacement[/i]. A market can move 100 pips up and down (high movement) but end up exactly where it started (zero displacement). The PDE solves this by calculating the ratio between the net displacement and the total energy expended by price.

[b]How It Works:[/b]
The indicator compares the absolute distance between the current price and the price [i]n[/i] periods ago against the sum of every individual bar-to-bar move during that same window.[b]High Efficiency (>75):[/b] Price is moving in a "straight line." This indicates a strong, healthy trend where every bit of volume is resulting in price progress.
[b]Low Efficiency (<20):[/b] Price is oscillating heavily with no clear direction. This is typical of "Choppy" markets or accumulation/distribution phases.

[b]Key Features:[/b]
[b]Directional Histogram:[/b] Shows the efficiency value relative to the trend direction (Green for Bullish, Red for Bearish).
[b]Smoothing Signal:[/b] An EMA line is applied to the raw efficiency data to help identify momentum shifts and trend transitions.
[b]Compression Detection:[/b] The background highlights yellow when the market is in an "Inefficient" state (below 20%). This warns traders to stay out of the market or prepare for an imminent breakout.
[b]Breakout Signals:[/b] Visual triangles appear when price exits a compression zone, signaling a potential surge in directional volatility.

[b]How to Use It:[/b]
[i]Trend Following:[/i] Look for values sustaining above 50/75 to stay in a trend.
[i]Reversal Warning:[/i] If price is making new highs but the PDE is dropping sharply, it suggests the trend is becoming "inefficient" and may soon exhaust.
[i]Volatility Contraction:[/i] Use the yellow highlighted zones to identify periods where the market is coiled, waiting for the next "Breakout" signal.

[b]Disclaimer:[/b]
[i]This indicator is a tool for analyzing market structure and efficiency. It does not constitute financial advice. Past performance is not indicative of future results.[/i]

## Source Code

````pine
// @version=6
indicator("Price Displacement Efficiency V2 (PDE)", shorttitle="PDE_V6", overlay=false, precision=2)

// --- Entrées ---
int len    = input.int(14, "Période d'Analyse", minval=2)
int sigLen = input.int(7, "Lissage Signal", minval=1)
color colUp = input.color(#00ff88, "Couleur Hausse") // Equivalent Emerald
color colDn = input.color(#ff0055, "Couleur Baisse") // Equivalent Rose
color colNeu = input.color(color.gray, "Couleur Neutre")

// --- Calcul du Cœur (Logique PDE) ---
// Distance nette entre le début et la fin de la fenêtre
float displacement = math.abs(close - close[len])

// Somme des mouvements réels (Energie totale dépensée)
// En v6, l'utilisation de boucles reste efficace pour ce calcul spécifique
float totalMovement = 0.0
for i = 0 to len - 1
    totalMovement += math.abs(close[i] - close[i+1])

// Calcul de l'indice d'efficacité (0 à 100)
float pdeBase = totalMovement > 0 ? (displacement / totalMovement) * 100 : 0

// Directionnalité (Positif si prix monte, Négatif si prix baisse)
float pdeDir = close > close[len] ? pdeBase : -pdeBase

// Lissage du signal (Calculé sur le PDE directionnel)
float pdeSignal = ta.ema(pdeDir, sigLen)

// --- Visuel ---
// Seuils de référence
hline(75, "Flux Pur", color=color.new(colUp, 50), linestyle=hline.style_dotted)
hline(-75, "Flux Pur", color=color.new(colDn, 50), linestyle=hline.style_dotted)
hline(0, "Pivot", color=color.new(colNeu, 50))

// Détection de la compression (Marché inefficace)
bool isLowEff = math.abs(pdeDir) < 20

// Plot principal en colonnes (Histogramme)
plot(pdeDir, "PDE Index", color = pdeDir > 0 ? colUp : colDn, style=plot.style_columns)

// Ligne de signal pour les transitions
plot(pdeSignal, "Signal Line", color=color.white, linewidth=2)

// Coloration de l'arrière-plan pour les zones de compression (v6 style)
bgcolor(isLowEff ? color.new(color.yellow, 90) : na, title="Zone de Compression")

// --- Alertes Visuelles ---
// Signal de sortie de compression (Explosion d'efficacité)
bool breakout = math.abs(pdeDir) > 20 and math.abs(pdeDir[1]) <= 20
plotshape(breakout, "Signal Breakout", shape.triangleup, location.bottom, color.yellow, size=size.small)
````

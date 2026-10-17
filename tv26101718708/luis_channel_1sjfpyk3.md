# Luis channel

- url: https://www.tradingview.com/script/1SJfPyk3/
- type: indicator
- pine_id: PUB;0818f7b73df54f1e9503e927a7f12206
- version: 1.0

## Description

​[image]https://www.tradingview.com/x/ZZBjuSUZ/[/image]
Luis Barlier Channel (LB Channel) – Technical Overview

1. Core Concept & Calculations
The LB Channel is a price envelope indicator that generates three lines based on a lookback period (default: 20 bars).

Key Innovation: Ignores wicks entirely, focusing only on candle bodies:

Body High (BH): 
max(open, close)
max(open, close)

Body Low (BL): 
min(open, close)
min(open, close)

Channel Lines:

Upper Bound: 
Highest(BH,length)
Highest(BH,length)
Lower Bound: 
Lowest(BL,length)
Lowest(BL,length)

Basis (Middle): 
(Upper+Lower)/2

2. Visual & Functional Features
Dynamic S/R Zone: Blue boundaries act as support/resistance, updating only when new body highs/lows break prior extremes.

Value Area Fill: Light blue shading (90% transparency) highlights if price is "inside" or "outside" the recent range.

Offset Control: Shift entire channel forward/backward for cycle analysis.

3. The Problem It Solves: Wick Noise
Traditional channels (Donchian, Bollinger) react to volatility spikes:

Long wicks from news/liquidity hunts artificially widen ranges

Generate false breakouts

Distort "fair value"

LB Channel Solution: Filters noise by using only committed price action (body highs/lows), ignoring temporary spikes that lack follow-through.

## Source Code

````pine
//@version=6
indicator(title="Luis channel", shorttitle="LB channel", overlay=true)

// --- Entrées ---
length = input.int(20, minval=1, title="Longueur")
offset = input.int(0, "Décalage (Offset)")

// --- Calculs ---
// On définit le "haut" et le "bas" du corps de la bougie
body_high = math.max(open, close)
body_low  = math.min(open, close)

// Calcul du canal basé uniquement sur ces corps
upper = ta.highest(body_high, length)
lower = ta.lowest(body_low, length)
basis = math.avg(upper, lower)

// --- Affichage ---
plot(basis, "Milieu (Basis)", color=color.gray, style=plot.style_linebr, offset=offset)

u = plot(upper, "Borne Haute (Corps)", color=#2962FF, linewidth=2, offset=offset)
l = plot(lower, "Borne Basse (Corps)", color=#2962FF, linewidth=2, offset=offset)

// Remplissage du canal
fill(u, l, color=color.new(#2962FF, 90), title="Fond du Canal")
````

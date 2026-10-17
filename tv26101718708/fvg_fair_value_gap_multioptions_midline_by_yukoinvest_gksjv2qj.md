# FVG (Fair Value Gap) Multi-Options & Midline | By YukoInvest

- url: https://www.tradingview.com/script/GKSJv2qj/
- type: indicator
- pine_id: PUB;d801ed18800140c5a1c71353f8d99fa9
- version: 1.0

## Description

Gardez un graphique épuré tout en repérant les zones de liquidité clés.

Cet indicateur FVG By YukoInvest a été codé pour les traders exigeants utilisant les concepts ICT (Inner Circle Trader) et SMC (Smart Money Concepts). Contrairement aux indicateurs surchargés qui polluent votre Price Action, cet outil se concentre sur la clarté visuelle et la personnalisation absolue.

Identifiez instantanément les déséquilibres du marché (Imbalances) avec précision grâce à des boîtes propres, légères et entièrement paramétrables.

🌟 Fonctionnalités Clés :
Détection Automatique Bullish / Bearish : Repère instantanément les espaces laissés entre la mèche de la 1ère et de la 3ème bougie.

Contrôle Total de l'Affichage (Toggle On/Off) : Vous ne cherchez que des achats ? Désactivez les FVG baissiers en un clic pour ne garder que ce qui compte pour votre biais du jour.

Filtre de Taille (Min FVG Size) : Ne vous laissez plus polluer par les micro-gaps insignifiants. Définissez une taille minimale pour n'afficher que les Imbalances institutionnels majeurs.

Ligne Médiane (Consequent Encroachment) : Affiche une ligne précise à 50% de la zone du FVG, un niveau de réaction crucial en SMC. Option activable/désactivable.

Esthétique Personnalisable : Couleurs de fond, opacité, bordures et lignes médianes totalement configurables pour s'adapter à votre thème visuel (Dark ou Light mode).

⚙️ Comment l'utiliser au mieux :
Profil de Trader : Indispensable pour le Day Trading et le Scalping (M1, M5, M15).

Stratégie : Utilisez ces zones comme cibles de liquidité (Draw on Liquidity) ou comme zones d'entrée optimales lors d'un retracement après un Break of Structure (BOS) ou un Change of Character (CHOCH).

Code optimisé en Pine Script v5 pour garantir une fluidité maximale et conserver un historique de 500 FVG sans faire ralentir votre plateforme.

Tradez intelligemment, tradez proprement.
© YukoInvest

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YukoInvest

//@version=5
indicator("FVG By YukoInvest", overlay=true, max_boxes_count=500, max_lines_count=500)

// --- Configuration & Options ---
minSize  = input.float(0.0, title="Min FVG Size", step=0.1, group="Settings")
showBull = input.bool(true, title="Show Bullish FVG", group="Settings")
showBear = input.bool(true, title="Show Bearish FVG", group="Settings")
showMid  = input.bool(true, title="Show Midline", group="Settings")

// --- Couleurs (Transparence 90 = 0.1 sur FXReplay) ---
bullColor = input.color(color.new(#00FF00, 90), title="Bullish Fill", group="Colors")
bearColor = input.color(color.new(#FF0000, 90), title="Bearish Fill", group="Colors")
lineColor = input.color(color.new(#B2B5BE, 0), title="Border & Midline", group="Colors")

// --- LOGIQUE FVG HAUSSIER (BULLISH) ---
// Condition : Le plus bas actuel est au-dessus du plus haut de la bougie d'il y a 2 périodes
bullGap = low - high[2]
isBullFVG = showBull and low > high[2] and bullGap >= minSize

if isBullFVG
    // Dessin de la boîte
    box.new(left=bar_index[2], top=low, right=bar_index, bottom=high[2], border_color=lineColor, border_width=1, bgcolor=bullColor)
    
    // Dessin de la ligne médiane
    if showMid
        midPriceBull = math.avg(low, high[2])
        line.new(x1=bar_index[2], y1=midPriceBull, x2=bar_index, y2=midPriceBull, color=lineColor, width=1)

// --- LOGIQUE FVG BAISSIER (BEARISH) ---
// Condition : Le plus haut actuel est en-dessous du plus bas de la bougie d'il y a 2 périodes
bearGap = low[2] - high
isBearFVG = showBear and high < low[2] and bearGap >= minSize

if isBearFVG
    // Dessin de la boîte
    box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high, border_color=lineColor, border_width=1, bgcolor=bearColor)
    
    // Dessin de la ligne médiane
    if showMid
        midPriceBear = math.avg(low[2], high)
        line.new(x1=bar_index[2], y1=midPriceBear, x2=bar_index, y2=midPriceBear, color=lineColor, width=1)
````

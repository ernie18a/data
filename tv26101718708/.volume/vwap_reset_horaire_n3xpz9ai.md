# VWAP Reset Horaire 

- url: https://www.tradingview.com/script/n3Xpz9Ai/
- type: indicator
- pine_id: PUB;df1606954dcc485e94dd0f4fbd5828ef
- version: 1.0

## Description

VWAP Reset Horaire 

VWAP qui repart de zéro à chaque nouvelle heure pleine. Chaque heure devient une mini-session avec son propre prix moyen pondéré par le volume, ce qui transforme le cadre H1 en référence intra-heure pour le scalp M1.
Ce que ça fait

La VWAP cumule (prix typique × volume) / volume puis remet ses compteurs à zéro au début de chaque heure. La ligne ne se relie pas d'une heure à l'autre : chaque segment est indépendant, donc le reset est visuellement net.
Bandes d'écart-type

Écart-type pondéré par le volume (et non simple stdev des clôtures), à ±1σ et ±2σ. Cohérent avec la VWAP elle-même : la zone ±1σ marque l'équilibre intra-heure, les ±2σ les extensions.

Lecture
Prix au-dessus de la VWAP horaire = agression acheteuse sur l'heure en cours, en dessous = agression vendeuse. Un prix collé à la VWAP signale une heure en équilibre ; un prix qui s'éloigne en touchant régulièrement la même bande signale une heure qui tend.

Réglages
Source (hlc3 par défaut), affichage des bandes, multiplicateurs σ, marqueur de reset.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Hakujii

//@version=6
indicator("VWAP Reset Horaire [ROGUEFEED]", overlay = true)

// ─── Source ───
src        = input.source(hlc3, "Source (prix typique)", group = "Calcul")
showBands  = input.bool(true,  "Bandes d'écart-type", group = "Bandes")
mult1      = input.float(1.0,  "Multiplicateur bande 1", step = 0.5, group = "Bandes")
mult2      = input.float(2.0,  "Multiplicateur bande 2", step = 0.5, group = "Bandes")

// ─── Reset à chaque nouvelle heure ───
nouvelleHeure = timeframe.change("60")

var float sumPV  = na   // Σ (prix × volume)
var float sumV   = na   // Σ volume
var float sumPV2 = na   // Σ (prix² × volume)  → pour l'écart-type

if nouvelleHeure or na(sumV)
    sumPV  := src * volume
    sumV   := volume
    sumPV2 := src * src * volume
else
    sumPV  += src * volume
    sumV   += volume
    sumPV2 += src * src * volume

vwap = sumPV / sumV

// ─── Écart-type pondéré par le volume ───
variance = math.max(sumPV2 / sumV - vwap * vwap, 0)
dev      = math.sqrt(variance)

// ─── Tracés ───
// joindre = false coupe la ligne au reset → pas de trait diagonal entre les heures
p = plot(vwap, "VWAP horaire", color.new(color.orange, 0), 2, join = false)

upper1 = vwap + dev * mult1
lower1 = vwap - dev * mult1
upper2 = vwap + dev * mult2
lower2 = vwap - dev * mult2

u1 = plot(showBands ? upper1 : na, "+1σ", color.new(color.teal, 40), join = false)
l1 = plot(showBands ? lower1 : na, "-1σ", color.new(color.teal, 40), join = false)
u2 = plot(showBands ? upper2 : na, "+2σ", color.new(color.teal, 70), join = false)
l2 = plot(showBands ? lower2 : na, "-2σ", color.new(color.teal, 70), join = false)

fill(u1, l1, showBands ? color.new(color.teal, 94) : na)

// ─── Marqueur de reset ───
bgcolor(nouvelleHeure ? color.new(color.gray, 90) : na)
````

# ATW OPCVM FCP GOLD VL

- url: https://www.tradingview.com/script/VEFKv2U4/
- type: indicator
- pine_id: PUB;e98316972c2447a89fac6913fbf2dd09
- version: 1.0

## Description

**Attijari Gold Tracker**

Indicateur permettant d'estimer la valeur liquidative (VL) du fonds Attijari Gold à partir du cours de l'or (XAUUSD).

**Formule utilisée :**

VL théorique = XAUUSD × 0,571

Le coefficient 0,571 a été calibré à partir des données du 31/05/2026 :

* VL Attijari Gold : 2 583,04 DH
* XAUUSD : 4 525,32 USD

**Particularité du fonds :**

La valeur liquidative officielle d'Attijari Gold est calculée chaque jeudi. L'indicateur permet donc d'obtenir une estimation en temps réel entre deux publications de VL afin de suivre l'évolution théorique du fonds en fonction du prix de l'or.

**Limites :**

* N'intègre pas les frais de gestion.
* N'intègre pas les éventuels écarts de réplication.
* Le coefficient devra être recalibré périodiquement en fonction des nouvelles VL publiées.

Usage : suivi rapide de la corrélation entre Attijari Gold et le marché de l'or.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abdou_echchrif

//@version=6
//@version=6
indicator("ATW OPCVM FCP GOLD VL", shorttitle="ATW GOLD VL", overlay=false)

gold = request.security("OANDA:XAUUSD", timeframe.period, close)

// Calibration du 31/05/2026
// VL = 2583.04 DH
// XAUUSD = 4525.32 USD
// Coefficient = 0.5708

attijari_gold = gold * 0.5708

plot(attijari_gold,
     title="VL théorique Attijari Gold",
     linewidth=2)

var table info = table.new(position.top_right, 1, 4)

if barstate.islast
    table.cell(info, 0, 0, "ATW GOLD Tracker")
    table.cell(info, 0, 1, "VL = XAUUSD × 0.5708")
    table.cell(info, 0, 2, "VL officielle : jeudi")
    table.cell(info, 0, 3, "Base : 31/05/2026")
````

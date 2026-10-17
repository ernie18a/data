# Setup Grade by Epy

- url: https://www.tradingview.com/script/VwV4huay/
- type: indicator
- pine_id: PUB;3ff49a24daa148d5bef10aa4878aebf7
- version: 1.0

## Description

Cet indicateur est un outil de validation de setup basé sur la méthodologie ICT / DodgysDD, conçu pour t'aider à ne trader que les configurations qui cochent un maximum de cases avant d'entrer en position.
Fonctionnement hybride : 3 critères sont détectés automatiquement par le script, 2 restent manuels pour conserver ton jugement sur les éléments contextuels.
Critères auto-détectés :

Liquidity Sweep — détection d'un balayage de liquidité sur les niveaux Asia High/Low et London High/Low (wick ou clôture + retour)
iFVG — identification automatique d'un Inverse Fair Value Gap sur les timeframes 5m, 15m, 1h et 4h
Volume — confirmation d'un volume supérieur à la moyenne (MA configurable)

Critères manuels (toggle on/off) :

HTF PDA Delivery — livraison depuis une zone Premium/Discount sur HTF
SMT w/ ES — divergence de structure avec l'instrument corrélé

Setup Grade : le score global est affiché sous forme de note (A+ → D) en fonction du nombre de critères validés.
Compatible avec les TF 1m, 2m, 3m et 5m. Pensé pour les sessions Asia, London et New York.

Not financial advice. Outil personnel basé sur le framework ICT/DodgysDD.

## Source Code

````pine
//@version=6
indicator("ICT Checklist | Setup Grade", overlay=true)

// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════
grp = "Checklist"
i_liq   = input.bool(false, "Liquidity Sweep",   group=grp)
i_htf   = input.bool(false, "HTF PDA Delivery",  group=grp)
i_vol   = input.bool(false, "Volume",             group=grp)
i_ifvg  = input.bool(false, "iFVG",               group=grp)
i_smt   = input.bool(false, "SMT w/ ES",          group=grp)
i_eq    = input.bool(false, "Equilibrium",        group=grp)

grp2 = "Display"
i_show  = input.bool(true, "Show Checklist", group=grp2)

// ══════════════════════════════════════════════════════
// SCORE & GRADE
// ══════════════════════════════════════════════════════
score = (i_liq ? 1 : 0) + (i_htf ? 1 : 0) + (i_vol ? 1 : 0) + (i_ifvg ? 1 : 0) + (i_smt ? 1 : 0) + (i_eq ? 1 : 0)

grade = score == 6 ? "A+" : score == 5 ? "A" : score == 4 ? "B" : score == 3 ? "C" : score >= 1 ? "D" : "-"

grade_col = score >= 5 ? color.new(#00c853, 0) : score == 4 ? color.new(#ffab00, 0) : score >= 1 ? color.new(#ff3d00, 0) : color.new(color.gray, 60)

sym(b) => b ? "YES" : "NO"
col(b) => b ? color.new(#00c853, 0) : color.new(#ff3d00, 0)

// ══════════════════════════════════════════════════════
// TABLE
// ══════════════════════════════════════════════════════
var table t = table.new(
     position.bottom_right, 2, 9,
     bgcolor       = color.new(#0d0d0d, 10),
     border_color  = color.new(color.gray, 60),
     border_width  = 1,
     frame_color   = color.new(color.gray, 40),
     frame_width   = 1)

row_set(r, label, val, vc) =>
    table.cell(t, 0, r, label,
         text_color  = color.new(color.white, 10),
         text_size   = size.small,
         bgcolor     = color.new(#1a1a1a, 10),
         text_halign = text.align_left)
    table.cell(t, 1, r, val,
         text_color  = vc,
         text_size   = size.small,
         bgcolor     = color.new(#1a1a1a, 10),
         text_halign = text.align_center)

if barstate.islast and i_show
    table.cell(t, 0, 0, "Checklist",
         text_color  = color.new(color.white, 0),
         text_size   = size.normal,
         bgcolor     = color.new(#111111, 0),
         text_halign = text.align_center)
    table.cell(t, 1, 0, "Status",
         text_color  = color.new(color.white, 0),
         text_size   = size.normal,
         bgcolor     = color.new(#111111, 0),
         text_halign = text.align_center)

    table.cell(t, 0, 1, "Setup Grade",
         text_color  = color.new(color.white, 10),
         text_size   = size.small,
         bgcolor     = color.new(#222222, 0),
         text_halign = text.align_left)
    table.cell(t, 1, 1, grade + " (" + str.tostring(score) + "/6)",
         text_color  = grade_col,
         text_size   = size.small,
         bgcolor     = color.new(#222222, 0),
         text_halign = text.align_center)

    row_set(2, "Liquidity Sweep",  sym(i_liq),  col(i_liq))
    row_set(3, "HTF PDA Delivery", sym(i_htf),  col(i_htf))
    row_set(4, "Volume",           sym(i_vol),  col(i_vol))
    row_set(5, "iFVG",             sym(i_ifvg), col(i_ifvg))
    row_set(6, "SMT w/ ES",        sym(i_smt),  col(i_smt))
    row_set(7, "Equilibrium",      sym(i_eq),   col(i_eq))

    table.cell(t, 0, 8, "A+ = 6/6  |  A = 5  |  B = 4  |  C <= 3",
         text_color  = color.new(color.gray, 30),
         text_size   = size.tiny,
         bgcolor     = color.new(#0d0d0d, 10),
         text_halign = text.align_center)
    table.merge_cells(t, 0, 8, 1, 8)
````

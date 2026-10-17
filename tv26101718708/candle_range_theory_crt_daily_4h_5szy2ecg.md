# Candle Range Theory (CRT) - Daily & 4H

- url: https://www.tradingview.com/script/5sZy2ecg/
- type: indicator
- pine_id: PUB;87000be19af148d9987799be65a4c2d7
- version: 1.0

## Description

L'indicateur détecte automatiquement les patterns CRT haussiers et baissiers sur les TF Daily et 4H, visible sur tous les TF inférieurs

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © goodlist11

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © CRT_Analyzer

//@version=6
indicator("Candle Range Theory (CRT) - Daily & 4H", overlay=true, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grp_tf     = "Timeframes"
show_daily = input.bool(true, "Afficher CRT Daily",    group=grp_tf)
show_4h    = input.bool(true, "Afficher CRT 4 Heures", group=grp_tf)

grp_bull   = "CRT Haussier"
bull_color = input.color(color.new(#9C27B0, 0), "Couleur trait haussier", group=grp_bull)
bull_width = input.int(2, "Épaisseur", minval=1, maxval=5, group=grp_bull)

grp_bear   = "CRT Baissier"
bear_color = input.color(color.new(#9C27B0, 0), "Couleur trait baissier", group=grp_bear)
bear_width = input.int(2, "Épaisseur", minval=1, maxval=5, group=grp_bear)

// ══════════════════════════════════════════════════════════════════════════════
// DESSIN — 100% xloc.bar_time, aucun bar_index
// t1 = timestamp ouverture B1, t2 = timestamp fermeture B3
// ══════════════════════════════════════════════════════════════════════════════
draw_line(t1, t2, price, col, wid) =>
    line.new(
         x1    = t1,
         y1    = price,
         x2    = t2,
         y2    = price,
         xloc  = xloc.bar_time,
         color = col,
         style = line.style_solid,
         width = wid
     )

// ══════════════════════════════════════════════════════════════════════════════
// DAILY  (ms_d = durée d'une session Daily en millisecondes)
// ══════════════════════════════════════════════════════════════════════════════
var int ms_d = 24 * 60 * 60 * 1000

// On récupère time (timestamp ouverture), OHLC pour les 3 dernières bougies
[d_t, d_o, d_h, d_l, d_c] = request.security(syminfo.tickerid, "D",
     [time, open, high, low, close],
     lookahead=barmerge.lookahead_off)

// Alias lisibles : suffixe 1=B1(ancienne), 2=B2(milieu), 3=B3(récente)
d_t1 = d_t[2] , d_o1 = d_o[2] , d_h1 = d_h[2] , d_l1 = d_l[2] , d_c1 = d_c[2]
d_t2 = d_t[1]                  , d_h2 = d_h[1] , d_l2 = d_l[1] , d_c2 = d_c[1]
d_t3 = d_t                                                        , d_c3 = d_c   , d_h3 = d_h , d_l3 = d_l

// Détection
d_bull = (d_c1 > d_o1) and (d_l2 < d_l1) and (d_c2 > d_o1) and (d_c3 > d_h1)
d_bear = (d_c1 < d_o1) and (d_h2 > d_h1) and (d_c2 < d_o1) and (d_c3 < d_l1)

// Feu une seule fois à la confirmation de B3
d_bull_trigger = d_bull and not d_bull[1]
d_bear_trigger = d_bear and not d_bear[1]

if show_daily and d_bull_trigger
    // Trait au HIGH de B1, du début de B1 à la fin de B3
    draw_line(d_t1, d_t3 + ms_d, d_h1, bull_color, bull_width)

if show_daily and d_bear_trigger
    // Trait au LOW de B1
    draw_line(d_t1, d_t3 + ms_d, d_l1, bear_color, bear_width)

// ══════════════════════════════════════════════════════════════════════════════
// 4 HEURES
// ══════════════════════════════════════════════════════════════════════════════
var int ms_4h = 4 * 60 * 60 * 1000

[h4_t, h4_o, h4_h, h4_l, h4_c] = request.security(syminfo.tickerid, "240",
     [time, open, high, low, close],
     lookahead=barmerge.lookahead_off)

h4_t1 = h4_t[2] , h4_o1 = h4_o[2] , h4_h1 = h4_h[2] , h4_l1 = h4_l[2] , h4_c1 = h4_c[2]
h4_t2 = h4_t[1]                    , h4_h2 = h4_h[1]  , h4_l2 = h4_l[1] , h4_c2 = h4_c[1]
h4_t3 = h4_t                                                               , h4_c3 = h4_c   , h4_h3 = h4_h , h4_l3 = h4_l

h4_bull = (h4_c1 > h4_o1) and (h4_l2 < h4_l1) and (h4_c2 > h4_o1) and (h4_c3 > h4_h1)
h4_bear = (h4_c1 < h4_o1) and (h4_h2 > h4_h1) and (h4_c2 < h4_o1) and (h4_c3 < h4_l1)

h4_bull_trigger = h4_bull and not h4_bull[1]
h4_bear_trigger = h4_bear and not h4_bear[1]

if show_4h and h4_bull_trigger
    draw_line(h4_t1, h4_t3 + ms_4h, h4_h1, bull_color, bull_width)

if show_4h and h4_bear_trigger
    draw_line(h4_t1, h4_t3 + ms_4h, h4_l1, bear_color, bear_width)
````

<!-- tradingview-pine-id: PUB;51cd9215e0c946ed8e25b0fbff57efda -->
<!-- tradingviewscripts-format: 1 -->
# XauLabs — Swing Points

Source: https://www.tradingview.com/script/3v4tUyce/

## Description

ENGLISH

What it does

It marks confirmed swing highs and swing lows, labels each one relative to the previous one of the same type — HH, HL, LH, LL — and connects them with a zigzag. That labelled sequence is the raw material of every structure-based method: HH + HL is the skeleton of an uptrend, LH + LL the skeleton of a downtrend, anything mixed is no man's land.

How it works (full method)

Confirmation. A swing high is confirmed only when the highs of the N bars before AND the N bars after are all lower (mirrored for swing lows). N is user-defined, default 7, range 5–21.
Labelling. On confirmation, the new swing high is compared to the previous confirmed swing high: higher gives HH, lower gives LH. The first one, with no predecessor, is labelled H. Swing lows are compared to previous swing lows: HL or LL, first one labelled L. Highs are never compared to lows.
Zigzag. Each confirmed pivot is joined to the previous confirmed pivot by a straight line, regardless of type. The result is the chart's skeleton with the intermediate noise removed.
Two levels of structure. Major structure uses the main sensitivity and is the default view. An optional minor structure, with its own smaller sensitivity (default 3), plots the internal waves inside each major leg. It is off by default: the skeleton first, the ripples afterwards. Reading a minor swing as if it were a major one is the most common way to end up flipping bias several times a day.

No repainting

Labels appear N bars after the extreme they mark, are drawn at the true historical position of that extreme, and never move or disappear afterwards. What history shows is what would have been visible live. The confirmation delay is the cost, and it is stated rather than hidden.

On-chart output

HH / HL / LH / LL labels on every confirmed major pivot.
Zigzag connecting major pivots.
Optional minor pivot dots.
A badge in the top-right corner showing the two most recent readings, with selectable text size.
Two alert conditions: major swing high confirmed, major swing low confirmed.

Suggested use

Start on H4. Read the badge: HH · HL means the bullish skeleton is intact. Structure has to be read on one sensitivity, applied consistently — not on whichever swing supports the trade you already want to take.

This is an educational structure-reading tool. It gives no buy or sell signals and makes no performance claim. Trading involves substantial risk of loss.

FRANÇAIS

Ce que fait l'indicateur

Il marque les sommets et creux de swing confirmés, étiquette chacun par rapport au précédent du même type — HH, HL, LH, LL — et les relie par un zigzag. Cette séquence étiquetée est la matière première de toute méthode structurelle : HH + HL forme le squelette d'une tendance haussière, LH + LL celui d'une tendance baissière, tout ce qui est mixte est une zone grise.

Comment il fonctionne (méthode complète)

Confirmation. Un sommet n'est confirmé que si les N bougies avant ET les N bougies après ont toutes un plus haut inférieur (symétrique pour les creux). N est réglable, 7 par défaut, plage 5–21.
Étiquetage. À la confirmation, le nouveau sommet est comparé au sommet confirmé précédent : plus haut donne HH, plus bas donne LH. Le premier, sans prédécesseur, est étiqueté H. Les creux sont comparés aux creux : HL ou LL, le premier étiqueté L. Un sommet n'est jamais comparé à un creux.
Zigzag. Chaque pivot confirmé est relié au pivot confirmé précédent par une droite, quel que soit son type. On obtient le squelette du graphique, débarrassé du bruit intermédiaire.
Deux niveaux de structure. La structure majeure utilise la sensibilité principale : c'est la vue par défaut. Une structure mineure optionnelle, avec sa propre sensibilité plus courte (3 par défaut), trace les vagues internes de chaque jambe majeure. Elle est désactivée par défaut : le squelette d'abord, les vagues ensuite. Lire un swing mineur comme s'il était majeur est la façon la plus courante de changer de biais cinq fois par jour.

Aucun repaint

Les étiquettes apparaissent N bougies après l'extrême qu'elles marquent, sont tracées à la vraie place historique de cet extrême, et ne bougent ni ne disparaissent ensuite. Ce que montre l'historique est ce qui aurait été visible en direct. Le délai de confirmation est le prix à payer, et il est affiché plutôt que masqué.

Affichage

Étiquettes HH / HL / LH / LL sur chaque pivot majeur confirmé.
Zigzag reliant les pivots majeurs.
Points de pivots mineurs, optionnels.
Un badge dans le coin supérieur droit affichant les deux dernières lectures, avec taille de texte réglable.
Deux conditions d'alerte : sommet majeur confirmé, creux majeur confirmé.

Utilisation suggérée

Commencer en H4. Lire le badge : HH · HL signifie que le squelette haussier est intact. La structure se lit sur une seule sensibilité, appliquée avec constance — pas sur le swing qui arrange le trade qu'on a déjà envie de prendre.

Outil éducatif de lecture de structure. Il ne donne aucun signal d'achat ou de vente et ne formule aucune promesse de performance. Le trading comporte un risque de perte important.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © XauLabs
// NIVEAU 2 / 8 — Swing Points — v1.2
// Changements v1.1 -> v1.2 :
//   - Titre indicator() en anglais (House Rules : titres de scripts en anglais)
//   - Badge : ligne de marque remplacée par le nom de l'outil
//   - Taille du texte (badge + étiquettes) réglable — lisibilité de la vignette de publication
//   - Pivots mineurs calculés inconditionnellement (ta.pivothigh dans un ternaire = état interne
//     évalué de façon conditionnelle, source d'avertissement et de résultats faux)
//   - Messages d'alerte neutralisés (plus de mention de marque)

//@version=6
indicator("XauLabs — Swing Points", shorttitle="XauLabs · Swing Points", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================
// RÉGLAGES
// ============================================================
grpMajeure = "Structure majeure (le squelette)"
lenMaj     = input.int(7, "Sensibilité majeure (bougies)", minval=5, maxval=21, group=grpMajeure, display=display.none, tooltip="Un pivot est confirmé après ce nombre de bougies de chaque côté. Aucun repaint.")
montrerEtiquettes = input.bool(true, "Étiquettes HH / HL / LH / LL", group=grpMajeure, display=display.none)
montrerZigzag     = input.bool(true, "Relier les pivots majeurs (zigzag)", group=grpMajeure, display=display.none)

grpMineure = "Structure mineure (les vagues internes)"
montrerMineure = input.bool(false, "Afficher les pivots mineurs", group=grpMineure, display=display.none, tooltip="Les respirations à l'intérieur de la structure majeure. Désactivé par défaut : apprends d'abord à lire le squelette, ajoute les vagues ensuite.")
lenMin     = input.int(3, "Sensibilité mineure (bougies)", minval=2, maxval=9, group=grpMineure, display=display.none)

grpAffichage = "Affichage"
montrerBadge = input.bool(true, "Badge de lecture (coin supérieur droit)", group=grpAffichage, display=display.none)
tailleTexte  = input.string(size.small, "Taille du texte (badge et étiquettes)", options=[size.tiny, size.small, size.normal, size.large, size.huge], group=grpAffichage, display=display.none, tooltip="Passer en large ou huge pour une capture d'écran lisible.")

// Palette XauLabs
colOr      = color.new(#D9A441, 0)
colIvoire  = color.new(#F4EFE6, 0)
colHausse  = color.new(#4E9B6E, 0)
colBaisse  = color.new(#B0413E, 0)
colGris    = color.new(#8A8494, 0)
colMineur  = color.new(#8A8494, 45)
colLigne   = color.new(#D9A441, 55)

// ============================================================
// STRUCTURE MAJEURE — pivots confirmés (non-repainting)
// ============================================================
phMaj = ta.pivothigh(high, lenMaj, lenMaj)
plMaj = ta.pivotlow(low,  lenMaj, lenMaj)

var float dernierHaut = na
var float dernierBas  = na
var int   dernierPivotBar  = na
var float dernierPivotPrix = na

var string lectureHaut = "—"
var string lectureBas  = "—"

// --- Sommet majeur confirmé ---
if not na(phMaj)
    estHH = na(dernierHaut) ? false : phMaj > dernierHaut
    txt = na(dernierHaut) ? "H" : estHH ? "HH" : "LH"
    colTxt = na(dernierHaut) ? colGris : estHH ? colHausse : colBaisse
    if montrerEtiquettes
        label.new(bar_index - lenMaj, phMaj, txt, style=label.style_label_down, color=color.new(#17141A, 20), textcolor=colTxt, size=tailleTexte)
    if montrerZigzag and not na(dernierPivotBar)
        line.new(dernierPivotBar, dernierPivotPrix, bar_index - lenMaj, phMaj, color=colLigne, width=1)
    lectureHaut := txt
    dernierHaut := phMaj
    dernierPivotBar := bar_index - lenMaj
    dernierPivotPrix := phMaj

// --- Creux majeur confirmé ---
if not na(plMaj)
    estHL = na(dernierBas) ? false : plMaj > dernierBas
    txt = na(dernierBas) ? "L" : estHL ? "HL" : "LL"
    colTxt = na(dernierBas) ? colGris : estHL ? colHausse : colBaisse
    if montrerEtiquettes
        label.new(bar_index - lenMaj, plMaj, txt, style=label.style_label_up, color=color.new(#17141A, 20), textcolor=colTxt, size=tailleTexte)
    if montrerZigzag and not na(dernierPivotBar)
        line.new(dernierPivotBar, dernierPivotPrix, bar_index - lenMaj, plMaj, color=colLigne, width=1)
    lectureBas := txt
    dernierBas := plMaj
    dernierPivotBar := bar_index - lenMaj
    dernierPivotPrix := plMaj

// ============================================================
// STRUCTURE MINEURE — les vagues internes (optionnel)
// ============================================================
phMin = ta.pivothigh(high, lenMin, lenMin)
plMin = ta.pivotlow(low,  lenMin, lenMin)

plotshape(montrerMineure and not na(phMin), style=shape.circle, location=location.abovebar, color=colMineur, size=size.tiny, offset=-lenMin, title="Sommet mineur", display=display.pane)
plotshape(montrerMineure and not na(plMin), style=shape.circle, location=location.belowbar, color=colMineur, size=size.tiny, offset=-lenMin, title="Creux mineur", display=display.pane)

// ============================================================
// BADGE
// ============================================================
var table badge = table.new(position.top_right, 1, 2, bgcolor=color.new(#17141A, 10), border_width=1, border_color=color.new(#D9A441, 70))
if barstate.islast and montrerBadge
    lecture = lectureHaut + " · " + lectureBas
    colLecture = (lectureHaut == "HH" and lectureBas == "HL") ? colHausse : (lectureHaut == "LH" and lectureBas == "LL") ? colBaisse : colGris
    table.cell(badge, 0, 0, "SWING POINTS", text_color=colOr, text_size=tailleTexte)
    table.cell(badge, 0, 1, lecture, text_color=colLecture, text_size=tailleTexte)

// ============================================================
// ALERTES
// ============================================================
alertcondition(not na(phMaj), "Sommet majeur confirmé", "Swing Points : nouveau sommet majeur confirmé.")
alertcondition(not na(plMaj), "Creux majeur confirmé",  "Swing Points : nouveau creux majeur confirmé.")
````

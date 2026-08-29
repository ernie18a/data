<!-- tradingview-pine-id: PUB;d2606272f9ee4f88a2b5cc73b29cc70b -->
<!-- tradingviewscripts-format: 1 -->
# XauLabs — Trend & Range

Source: https://www.tradingview.com/script/K2rPdqXm/

## Description

**ENGLISH**

**What it does**

This indicator answers one question, and only one: is the market currently trending up, trending down, or ranging? It reads pure price structure — confirmed swing highs and swing lows — and states a verdict on the chart.

**How it works (full method)**

1. **Swing detection.** A swing high is confirmed only when the highs of the N bars before AND the N bars after are all lower (mirrored for swing lows). N is user-defined, default 7, range 5–21. Confirmation therefore arrives N bars after the actual extreme; the marker is then plotted at its true historical position and never moves again.

2. **Memory.** The script keeps the last two confirmed highs and the last two confirmed lows.

3. **Classification.**
   - Uptrend: last high > previous high AND last low > previous low.
   - Downtrend: last high < previous high AND last low < previous low.
   - Range: anything else, including any state with fewer than two confirmed highs and two confirmed lows.

4. **Close-based invalidation** (optional, on by default). Any bar closing below the last confirmed swing low arms an invalidation flag. While that flag is armed, no uptrend is displayed: the state is forced to Range, even if the swing sequence otherwise qualifies as higher highs and higher lows. The flag is cleared only when a new swing low is confirmed. The logic is mirrored for downtrends, using a close above the last confirmed swing high. Wicks piercing the level do not count — only the close does. This mechanism can only suppress a trend reading, never create one: a trend must always earn its own structure.

**Why the delay is deliberate**

Signals never appear and later vanish. What the history shows is what would have been visible live. The cost is the N-bar confirmation delay, and it is stated openly rather than hidden behind a repainting display.

**On-chart output**

- Background tint: green uptrend, red downtrend, grey range.
- Triangles marking each confirmed swing high and low.
- A two-line state badge in the top-right corner, with selectable size and language (EN/FR).
- One alert condition: state change.

**Suggested use**

Start on H4. When the state reads Range, trend-following setups are structurally out of place — the indicator is meant to be used as a context filter before any entry logic, not as an entry trigger itself. The lower the sensitivity value, the faster and noisier the reading; the higher, the slower and more stable.

**Originality**

Most trend tools average price (moving averages, oscillators) and therefore lag by construction. This one reads structure only, applies a strict non-repainting confirmation rule, and adds a close-based invalidation layer so that a broken structure is downgraded to Range immediately rather than after the next swing forms. Open source: every rule above is verifiable line by line in the code.

This is an educational structure-reading tool. It gives no buy or sell signals and makes no performance claim. Trading involves substantial risk of loss.

---

**FRANÇAIS**

**Ce que fait l'indicateur**

Il répond à une seule question : le marché est-il en tendance haussière, baissière, ou en range ? Il lit la structure pure du prix — sommets et creux confirmés — et affiche son verdict.

**Comment il fonctionne (méthode complète)**

1. **Détection des pivots.** Un sommet n'est confirmé que si les N bougies avant ET les N bougies après ont toutes un plus haut inférieur (symétrique pour les creux). N est réglable, 7 par défaut, plage 5–21. La confirmation arrive donc N bougies après l'extrême réel ; le marqueur est ensuite tracé à sa vraie place historique et ne bouge plus jamais.

2. **Mémoire.** Le script conserve les deux derniers sommets et les deux derniers creux confirmés.

3. **Classification.**
   - Hausse : dernier sommet > précédent ET dernier creux > précédent.
   - Baisse : dernier sommet < précédent ET dernier creux < précédent.
   - Range : tout le reste, y compris tant que moins de deux sommets et deux creux sont confirmés.

4. **Invalidation en clôture** (optionnelle, active par défaut). Toute bougie qui clôture sous le dernier creux confirmé arme une invalidation. Tant qu'elle est armée, aucune tendance haussière n'est affichée : l'état reste Range, même si la séquence de pivots remplit par ailleurs la condition sommets et creux ascendants. L'invalidation ne se désarme qu'à la confirmation d'un nouveau creux. Le mécanisme est symétrique en tendance baissière, avec une clôture au-dessus du dernier sommet confirmé. Une mèche qui perce le niveau ne suffit pas — seule la clôture compte. Ce mécanisme peut uniquement supprimer une lecture de tendance, jamais en créer une : une tendance doit toujours prouver sa propre structure.

**Pourquoi le délai est assumé**

Aucun signal n'apparaît puis ne disparaît. Ce que montre l'historique est ce qui aurait été visible en direct. La contrepartie est le délai de confirmation de N bougies, affiché ouvertement plutôt que masqué derrière un affichage qui se repeint.

**Affichage**

- Fond teinté : vert en hausse, rouge en baisse, gris en range.
- Triangles marquant chaque sommet et creux confirmé.
- Un badge d'état à deux lignes dans le coin supérieur droit, avec taille et langue (EN/FR) réglables.
- Une condition d'alerte : changement d'état.

**Utilisation suggérée**

Commencer en H4. Quand l'état affiche Range, les setups de suivi de tendance sont structurellement hors sujet — l'indicateur est conçu comme un filtre de contexte en amont d'une logique d'entrée, pas comme un déclencheur d'entrée. Plus la sensibilité est basse, plus la lecture est rapide et bruitée ; plus elle est haute, plus elle est lente et stable.

**Originalité**

La plupart des outils de tendance moyennent le prix (moyennes mobiles, oscillateurs) et retardent par construction. Celui-ci lit uniquement la structure, applique une règle de confirmation stricte sans repeinture, et ajoute une couche d'invalidation en clôture pour qu'une structure cassée redevienne Range immédiatement plutôt qu'au pivot suivant. Code ouvert : chaque règle ci-dessus est vérifiable ligne par ligne.

Outil éducatif de lecture de structure. Il ne donne aucun signal d'achat ou de vente et ne formule aucune promesse de performance. Le trading comporte un risque de perte important.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © XauLabs
// NIVEAU 1 / 8 — Trend & Range — v1.3
// Changements v1.2 -> v1.3 :
//   - Titre indicator() en anglais (House Rules : titres de scripts en anglais)
//   - Badge : ligne de marque remplacée par le nom de l'outil (pas de marque dessinée sur le graphique)
//   - Badge : langue FR/EN au choix + taille réglable (lisibilité de la vignette de publication)
//   - Triangles de pivots passés en size.small (invisibles en tiny une fois la vignette réduite)
//   - Message d'alerte neutralisé (plus de mention de marque)
//   - Suppression des déclarations max_lines_count / max_labels_count (aucune ligne ni label utilisés)

//@version=6
indicator("XauLabs — Trend & Range", shorttitle="XauLabs · Trend & Range", overlay=true)

// ============================================================
// RÉGLAGES
// ============================================================
grpLecture   = "Lecture de structure"
pivotLen     = input.int(7, "Sensibilité des pivots (bougies)", minval=5, maxval=21, group=grpLecture, display=display.none, tooltip="Nombre de bougies de chaque côté pour confirmer un sommet/creux. Plus grand = structure plus lente et plus fiable. Un pivot n'est confirmé qu'après ce nombre de bougies : c'est le prix de l'honnêteté (aucun repaint).")
cassureClose = input.bool(true, "Invalidation immédiate sur clôture", group=grpLecture, display=display.none, tooltip="Une clôture sous le dernier creux confirmé arme une invalidation : tant qu'elle est armée, aucune tendance haussière ne peut être affichée. Elle se désarme à la confirmation d'un nouveau creux. Symétrique en baisse.")

grpAffichage = "Affichage"
montrerFond  = input.bool(true,  "Colorer le fond selon l'état", group=grpAffichage, display=display.none)
montrerPivots= input.bool(true,  "Marquer les sommets/creux confirmés", group=grpAffichage, display=display.none)
montrerBadge = input.bool(true,  "Badge d'état (coin supérieur droit)", group=grpAffichage, display=display.none)
langueBadge  = input.string("EN", "Langue du badge", options=["EN", "FR"], group=grpAffichage, display=display.none)
tailleBadge  = input.string(size.normal, "Taille du badge", options=[size.tiny, size.small, size.normal, size.large, size.huge], group=grpAffichage, display=display.none, tooltip="Passer en large ou huge pour une capture d'écran lisible.")

// Palette XauLabs
colOr      = color.new(#D9A441, 0)
colIvoire  = color.new(#F4EFE6, 0)
colHausse  = color.new(#4E9B6E, 0)
colBaisse  = color.new(#B0413E, 0)
colRange   = color.new(#8A8494, 0)
colFondH   = color.new(#4E9B6E, 85)
colFondB   = color.new(#B0413E, 85)
colFondR   = color.new(#8A8494, 88)

// ============================================================
// DÉTECTION DES PIVOTS (confirmés — non-repainting)
// ============================================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

var float dernierHaut  = na
var float avantHaut    = na
var float dernierBas   = na
var float avantBas     = na

if not na(ph)
    avantHaut   := dernierHaut
    dernierHaut := ph
if not na(pl)
    avantBas   := dernierBas
    dernierBas := pl

// ============================================================
// CLASSIFICATION : TENDANCE OU RANGE
// ============================================================
structureComplete = not na(avantHaut) and not na(avantBas)

hh = structureComplete and dernierHaut > avantHaut
hl = structureComplete and dernierBas  > avantBas
lh = structureComplete and dernierHaut < avantHaut
ll = structureComplete and dernierBas  < avantBas

int etatPivots = hh and hl ? 1 : lh and ll ? -1 : 0

// Invalidation par clôture : drapeau armé/désarmé
var bool hausseInvalidee = false
var bool baisseInvalidee = false

if not na(pl)
    hausseInvalidee := false
if not na(ph)
    baisseInvalidee := false

if cassureClose and structureComplete
    if close < dernierBas
        hausseInvalidee := true
    if close > dernierHaut
        baisseInvalidee := true

int etat = etatPivots
if cassureClose
    if etatPivots == 1 and hausseInvalidee
        etat := 0
    if etatPivots == -1 and baisseInvalidee
        etat := 0

// ============================================================
// AFFICHAGE
// ============================================================
couleurFond = etat == 1 ? colFondH : etat == -1 ? colFondB : colFondR
bgcolor(montrerFond ? couleurFond : na)

plotshape(montrerPivots and not na(ph), style=shape.triangledown, location=location.abovebar, color=colOr,     size=size.small, offset=-pivotLen, title="Sommet confirmé", display=display.pane)
plotshape(montrerPivots and not na(pl), style=shape.triangleup,   location=location.belowbar, color=colIvoire, size=size.small, offset=-pivotLen, title="Creux confirmé", display=display.pane)

var table badge = table.new(position.top_right, 1, 2, bgcolor=color.new(#17141A, 10), border_width=1, border_color=color.new(#D9A441, 70))
if barstate.islast and montrerBadge
    txtHaut = langueBadge == "FR" ? "TENDANCE HAUSSIÈRE" : "UPTREND"
    txtBas  = langueBadge == "FR" ? "TENDANCE BAISSIÈRE" : "DOWNTREND"
    txtEtat = etat == 1 ? txtHaut : etat == -1 ? txtBas : "RANGE"
    colEtat = etat == 1 ? colHausse : etat == -1 ? colBaisse : colRange
    table.cell(badge, 0, 0, "TREND & RANGE", text_color=colOr, text_size=tailleBadge)
    table.cell(badge, 0, 1, txtEtat, text_color=colEtat, text_size=tailleBadge)

alertcondition(etat != etat[1], "Changement d'état", "Trend & Range : l'état du marché a changé (tendance / range).")
````

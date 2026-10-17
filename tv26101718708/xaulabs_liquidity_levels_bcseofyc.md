# XauLabs  Liquidity Levels

- url: https://www.tradingview.com/script/BCSEOfyc/
- type: indicator
- pine_id: PUB;156206df72a147e1a1054eddfa5f492f
- version: 1.0

## Description

ENGLISH

What it does

Most tools draw every swing high and low the same way. This one counts. A level touched four times without being broken is not the same object as a level touched once, and the script says so on the chart: line thickness and shading grow with the number of touches, and the count is written next to each zone. It also draws the diagonal along which lows keep rising — the sloping counterpart of a horizontal level — and marks the places where the two meet.

How it works (full method)

Confirmed pivots only. A swing is registered when it dominates a set number of bars on both sides (8 by default). The right-hand bars are what make the tool non-repainting: a level appears with that delay and never moves afterwards. The dashboard states the delay in plain sight.
Grouping into zones. Each new pivot is compared to existing levels. If it falls within a tolerance expressed in ATR (0.12 by default), it counts as the same zone and the counter increases. The zone is drawn as a band spanning the actual spread between its touches — equal highs and equal lows are rarely exactly equal, and the band shows the real width.
Weight by touches. Border, shading and the printed count all scale with the number of touches. Two touches is a pair of equal highs; four is a wall the market keeps returning to. By default only zones with at least two touches are displayed — single pivots are noise.
Sweeps are marked, not erased. When price wicks beyond a zone and closes back inside, the zone turns dotted grey and is labelled swept. It stays on the chart: what happened is part of the reading. Single-touch levels are never labelled swept — that is an ordinary break of structure, not a liquidity event.
Liquidity trendline. The script searches all pairs of confirmed pivots for the ascending line that the most lows have respected, with a tolerance of its own (0.5 ATR by default) because a diagonal spanning hours cannot hug prices to the cent. A low sitting above the line is not a violation — only a low clearly beneath it invalidates the line. Where several candidates tie, the oldest anchor wins, so the line starts at the origin of the move. The touch count is printed at its right end.
Confluence. When the projected diagonal reaches a horizontal zone, both are recoloured and marked. That intersection is where a horizontal cluster and a sloping one arrive together.
Recovery. If price closes below the diagonal, the script frames the area between the break and the current low, and names it: the diagonal and the equal lows have to be reworked.
Housekeeping. Zones further than a set distance from price, or older than a set number of bars, are removed. Beyond the display cap, the least-touched zones go first — an accumulation zone far from price outranks an isolated pivot nearby.

On what "liquidity" means here

The script measures touches, which is observable. The idea that stop orders accumulate behind repeatedly defended levels is an interpretation of that measurement, and a common one, but it is not something a chart can prove. The distinction matters: what you see counted is real, what it implies about resting orders is a reading.

No repainting

Pivots are confirmed by the right-hand bars and never revised. Zones extend forward as bars close; sweeps are evaluated on closed bars only. The diagonal is recomputed on the last bar because new pivots can extend it, which is stated here rather than hidden.

Settings

Pivot width, equality tolerance, minimum touches, maximum zones, distance and age filters, sweep marking and quota, diagonal tolerance, anchor depth, projection length, confluence and recovery marking, colours, dashboard and text size.

Educational structural tool. It gives no buy or sell signals and makes no performance claim. Trading involves substantial risk of loss.

FRANÇAIS

Ce que fait l'indicateur

La plupart des outils dessinent tous les sommets et creux de la même façon. Celui-ci compte. Un niveau touché quatre fois sans être franchi n'est pas le même objet qu'un niveau touché une fois, et le script le dit sur le graphique : l'épaisseur et l'intensité augmentent avec le nombre de touches, et le compte est écrit à côté de chaque zone. Il trace aussi la diagonale le long de laquelle les creux montent — l'équivalent en pente d'un niveau horizontal — et marque les endroits où les deux se rejoignent.

Comment il fonctionne (méthode complète)

Uniquement des pivots confirmés. Un pivot est enregistré quand il domine un nombre fixé de bougies de chaque côté (8 par défaut). Ce sont les bougies de droite qui rendent l'outil non-repainting : un niveau apparaît avec ce délai et ne bouge plus ensuite. Le tableau de bord affiche ce délai en clair.
Regroupement en zones. Chaque nouveau pivot est comparé aux niveaux existants. S'il tombe dans une tolérance exprimée en ATR (0,12 par défaut), c'est la même zone et le compteur augmente. La zone est tracée comme une bande couvrant l'écart réel entre ses touches — des equal highs ne sont presque jamais exactement égaux, et la bande montre la largeur véritable.
Le poids vient des touches. Bordure, intensité et compte affiché suivent le nombre de touches. Deux touches, c'est une paire d'equal highs ; quatre, c'est un mur où le marché revient sans cesse. Par défaut, seules les zones à deux touches minimum s'affichent — un pivot isolé est du bruit.
Les balayages sont marqués, pas effacés. Quand le prix dépasse une zone en mèche et clôture en deçà, elle passe en gris pointillé avec la mention « balayé ». Elle reste au graphique : ce qui s'est passé fait partie de la lecture. Un niveau à une seule touche n'est jamais marqué balayé — c'est une cassure de structure ordinaire, pas un événement de liquidité.
Diagonale de liquidité. Le script examine toutes les paires de pivots confirmés pour retenir la droite ascendante que le plus de creux ont respectée, avec une tolérance qui lui est propre (0,5 ATR par défaut) : une diagonale qui traverse plusieurs heures ne peut pas coller au centime. Un creux situé au-dessus de la droite n'est pas une violation — seul un creux nettement dessous l'invalide. À égalité, l'ancrage le plus ancien gagne : la droite part de l'origine du mouvement. Le nombre de touches est écrit à son extrémité.
Confluence. Quand la diagonale projetée rejoint une zone horizontale, les deux sont recolorées et signalées. C'est l'endroit où un amas horizontal et un amas en pente arrivent ensemble.
Récupération. Si le prix clôture sous la diagonale, le script encadre la zone entre la cassure et le plus bas atteint depuis, et la nomme : la diagonale et les equal lows sont à retravailler.
Entretien. Les zones trop éloignées du prix ou trop anciennes disparaissent. Au-delà du plafond d'affichage, ce sont les moins touchées qui partent en premier — une zone d'accumulation lointaine vaut mieux qu'un pivot isolé tout proche.

Sur le mot « liquidité »

Le script mesure des touches, ce qui est observable. L'idée que des ordres stop s'accumulent derrière les niveaux défendus plusieurs fois est une interprétation de cette mesure, très répandue, mais qu'un graphique ne peut pas démontrer. La distinction compte : ce que vous voyez compté est réel, ce que cela suppose des ordres en attente est une lecture.

Aucun repaint

Les pivots sont confirmés par les bougies de droite et ne sont jamais révisés. Les zones s'étendent vers l'avant à mesure que les bougies clôturent ; les balayages sont évalués sur bougies closes uniquement. La diagonale est recalculée sur la dernière bougie parce que de nouveaux pivots peuvent la prolonger — c'est écrit ici plutôt que caché.

Réglages

Largeur de pivot, tolérance d'égalité, touches minimum, zones maximum, filtres de distance et d'âge, marquage et quota de balayages, tolérance de la diagonale, profondeur d'ancrage, longueur de projection, marquage des confluences et des récupérations, couleurs, tableau de bord et taille du texte.

Outil structurel à but éducatif. Il ne donne aucun signal d'achat ou de vente et ne formule aucune promesse de performance. Le trading comporte un risque de perte important.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © XauLabs
// NIVEAU 4 / 8 — Liquidity Levels — v1.5
// Corrections v1.6 -> v1.7 :
//   - Tolérance de la diagonale RÉGLABLE et bien plus large (0.5 ATR par défaut) :
//     une droite qui traverse plusieurs heures ne peut pas coller au centime
//   - À nombre de touches égal, c'est l'ancrage le PLUS ANCIEN qui gagne : la
//     droite part de l'origine du mouvement et non de la moitié du trajet
//   - RÉCUPÉRATION : quand le prix casse sous la diagonale puis revient la
//     retravailler, la zone est encadrée et nommée sur le graphique
// (base v1.4 -> v1.6) : la diagonale est choisie par le NOMBRE DE TOUCHES,
// pas par l'ancrage le plus lointain. Deux points clés :
//   - un creux qui reste AU-DESSUS de la droite n'est pas une violation : quand
//     deux creux sont égaux, la droite passe par le premier et le troisième, le
//     deuxième restant légèrement au-dessus. Seul un creux nettement SOUS la
//     droite invalide la ligne.
//   - le seuil est donc de 2 touches (les deux ancres), le classement se faisant
//     ensuite sur le nombre de touches puis sur la récence de l'ancrage.
// Un écart minimum entre les deux ancres évite les droites triviales.
// (base v1.4)
// Ajouts v1.2 -> v1.3 :
//   - Fenêtre de pertinence : les zones trop lointaines ou trop vieilles sont
//     retirées (le graphique reste lisible)
//   - TREND DE LIQUIDITÉ : la diagonale qui relie des creux montants (ou des
//     sommets descendants) et qui concentre les stops le long de sa pente
//   - CONFLUENCE : quand la diagonale rejoint une zone horizontale d'equal lows/highs,
//     les deux sont marquées — c'est là que le potentiel de balayage est le plus fort
// (base v1.2)
// Corrections v1.1 -> v1.2 :
//   - ZONES au lieu de traits : la bande couvre l'écart réel entre les touches
//   - L'élagage garde les niveaux les PLUS TOUCHÉS (avant : les plus proches du prix,
//     ce qui effaçait les zones d'accumulation lointaines, les plus importantes)
//   - Un niveau à une seule touche n'est plus marqué "balayé" : ce n'est pas de la
//     liquidité, c'est une simple cassure de structure
//   - Affichage épuré : fond léger, bordure fine, compte à droite
// (base v1.1)
// Correction v1.0 -> v1.1 : en Pine, "for i = 0 to size - 1" sur un tableau VIDE
// devient "0 to -1" et s'exécute à l'envers au lieu d'être ignoré — d'où une
// lecture d'index sur un tableau vide (RE10045). Toutes les boucles de parcours
// sont désormais protégées par un test de taille.
// Principe : un sommet (ou un creux) qui se répète au même prix sans être franchi
// est touché plusieurs fois. Le script COMPTE ces touches et affiche le compte.
// Quand le prix dépasse le niveau en mèche mais clôture en deçà, le niveau est
// marqué BALAYÉ — il n'est pas effacé, la trace reste.
// ⚠️ NON TESTÉ. À vérifier avant publication : compte des touches, marquage du
//    balayage, lisibilité avec beaucoup de niveaux, tenue en M5 sur plusieurs jours.

//@version=6
indicator("XauLabs — Liquidity Levels", shorttitle="XauLabs · Liquidity", overlay=true, max_boxes_count=500, max_labels_count=500)

// ============================================================
// RÉGLAGES
// ============================================================
grpDetect  = "Détection"
gauche     = input.int(8, "Bougies à gauche du pivot", minval=2, maxval=50, group=grpDetect, display=display.none, tooltip="Un pivot est confirmé quand il domine ce nombre de bougies de chaque côté.")
droite     = input.int(8, "Bougies à droite (confirmation)", minval=2, maxval=50, group=grpDetect, display=display.none, tooltip="Le niveau n'apparaît qu'après ce nombre de bougies : c'est le prix à payer pour ne pas repeindre.")
tolATR     = input.float(0.12, "Tolérance d'égalité (× ATR)", minval=0.01, maxval=1.0, step=0.01, group=grpDetect, display=display.none, tooltip="Deux pivots dans cette marge comptent comme le même niveau.")
minTouches = input.int(2, "Touches minimum pour afficher", minval=1, maxval=10, group=grpDetect, display=display.none, tooltip="2 = uniquement les equal highs / equal lows. 1 = tous les pivots confirmés.")
maxNiveaux = input.int(8, "Zones affichées au maximum", minval=2, maxval=60, group=grpDetect, display=display.none)
distMaxATR = input.float(12.0, "Distance maximum au prix (× ATR)", minval=1.0, maxval=60.0, step=0.5, group=grpDetect, display=display.none, tooltip="Au-delà, la zone n'est plus pertinente pour la séance en cours et disparaît.")
ageMax     = input.int(400, "Âge maximum (bougies)", minval=50, maxval=3000, step=50, group=grpDetect, display=display.none, tooltip="Une zone dont la dernière touche est plus ancienne que cela disparaît.")

grpTrend      = "Trend de liquidité"
montrerTrend  = input.bool(true, "Tracer les diagonales de liquidité", group=grpTrend, display=display.none, tooltip="Relie des creux montants (ou des sommets descendants) : les stops s'alignent le long de cette pente.")
profondeur    = input.int(10, "Pivots examinés pour l'ancrage", minval=3, maxval=20, group=grpTrend, display=display.none, tooltip="La diagonale s'ancre sur le creux le plus bas (ou le sommet le plus haut) parmi ces pivots : elle part de l'origine du mouvement.")
extension     = input.int(40, "Prolongation à droite (bougies)", minval=5, maxval=200, group=grpTrend, display=display.none)
ecartMini     = input.int(20, "Écart minimum entre les deux ancres (bougies)", minval=5, maxval=300, step=5, group=grpTrend, display=display.none, tooltip="Évite les droites tracées entre deux pivots collés.")
margeTrend    = input.float(0.5, "Tolérance de la diagonale (× ATR)", minval=0.05, maxval=3.0, step=0.05, group=grpTrend, display=display.none, tooltip="Une droite qui traverse plusieurs heures ne colle pas au centime : cette marge décide de ce qui compte comme touche ou comme cassure.")
montrerRecup  = input.bool(true, "Encadrer les récupérations", group=grpTrend, display=display.none, tooltip="Le prix casse sous la diagonale puis revient la retravailler : la zone est encadrée.")
colTrend      = input.color(#D9A441, "Couleur des diagonales", group=grpTrend, display=display.none)
marquerConflu = input.bool(true, "Marquer les confluences diagonale + zone", group=grpTrend, display=display.none, tooltip="Une diagonale qui rejoint une zone d'egal highs/lows : potentiel de balayage renforcé.")

grpBalayage     = "Balayage"
marquerBalayage = input.bool(true, "Marquer les niveaux balayés", group=grpBalayage, display=display.none, tooltip="Mèche au-delà du niveau, clôture en deçà : le niveau est marqué, pas effacé.")
garderBalayes   = input.int(4, "Niveaux balayés conservés", minval=0, maxval=20, group=grpBalayage, display=display.none)

grpAffichage  = "Affichage"
theme         = input.string("Sombre", "Thème du graphique", options=["Sombre", "Clair"], group=grpAffichage, display=display.none)
colHaut       = input.color(#D93B3B, "Niveaux au-dessus du prix", group=grpAffichage, display=display.none)
colBas        = input.color(#3FA88C, "Niveaux en dessous du prix", group=grpAffichage, display=display.none)
montrerCompte = input.bool(true, "Afficher le nombre de touches", group=grpAffichage, display=display.none)
montrerBadge  = input.bool(true, "Tableau de bord", group=grpAffichage, display=display.none)
tailleTexte   = input.string(size.small, "Taille du texte", options=[size.tiny, size.small, size.normal], group=grpAffichage, display=display.none)

// ============================================================
// PALETTE
// ============================================================
clair     = theme == "Clair"
colTexte  = clair ? color.new(#2A2430, 0) : color.new(#F4EFE6, 0)
colFaible = clair ? color.new(#6B6474, 0) : color.new(#8A8494, 0)
colFondUI = clair ? color.new(#FFFFFF, 4) : color.new(#17141A, 6)
colBordUI = color.new(#D9A441, 55)
colAccent = color.new(#D9A441, 0)
colMort   = clair ? color.new(#9A93A6, 25) : color.new(#5C5563, 15)
transp    = color.new(#000000, 100)

// ============================================================
// ÉTAT DES NIVEAUX
// ============================================================
var array<float> nvPrix    = array.new_float()
var array<float> nvBande   = array.new_float()
var array<int>   nvDernier = array.new_int()
var array<int>   nvTouches = array.new_int()
var array<int>   nvDebut   = array.new_int()
var array<bool>  nvHaut    = array.new_bool()
var array<bool>  nvBalaye  = array.new_bool()
var array<box>   nvBoite   = array.new_box()
var array<label> nvEtiq    = array.new_label()

atr = ta.atr(14)
tol = atr * tolATR

// ============================================================
// DÉTECTION DES PIVOTS ET COMPTAGE DES TOUCHES
// ============================================================
ph         = ta.pivothigh(high, gauche, droite)
pl         = ta.pivotlow(low, gauche, droite)
tempsPivot = time[droite]

if not na(ph)
    int trouve = -1
    if array.size(nvPrix) > 0
        for i = 0 to array.size(nvPrix) - 1
            if array.get(nvHaut, i) and not array.get(nvBalaye, i) and math.abs(array.get(nvPrix, i) - ph) <= tol
                trouve := i
    if trouve >= 0
        array.set(nvTouches, trouve, array.get(nvTouches, trouve) + 1)
        array.set(nvPrix,  trouve, math.max(array.get(nvPrix, trouve), ph))
        array.set(nvBande, trouve, math.min(array.get(nvBande, trouve), ph))
        array.set(nvDernier, trouve, bar_index)
    else
        array.push(nvPrix, ph)
        array.push(nvBande, ph)
        array.push(nvDernier, bar_index)
        array.push(nvTouches, 1)
        array.push(nvDebut, tempsPivot)
        array.push(nvHaut, true)
        array.push(nvBalaye, false)
        array.push(nvBoite, box.new(tempsPivot, ph, time, ph, xloc=xloc.bar_time, bgcolor=transp, border_color=transp))
        array.push(nvEtiq, label.new(time, ph, "", xloc=xloc.bar_time, style=label.style_label_left, color=transp, textcolor=transp, size=size.tiny))

if not na(pl)
    int trouveB = -1
    if array.size(nvPrix) > 0
        for i = 0 to array.size(nvPrix) - 1
            if not array.get(nvHaut, i) and not array.get(nvBalaye, i) and math.abs(array.get(nvPrix, i) - pl) <= tol
                trouveB := i
    if trouveB >= 0
        array.set(nvTouches, trouveB, array.get(nvTouches, trouveB) + 1)
        array.set(nvPrix,  trouveB, math.min(array.get(nvPrix, trouveB), pl))
        array.set(nvBande, trouveB, math.max(array.get(nvBande, trouveB), pl))
        array.set(nvDernier, trouveB, bar_index)
    else
        array.push(nvPrix, pl)
        array.push(nvBande, pl)
        array.push(nvDernier, bar_index)
        array.push(nvTouches, 1)
        array.push(nvDebut, tempsPivot)
        array.push(nvHaut, false)
        array.push(nvBalaye, false)
        array.push(nvBoite, box.new(tempsPivot, pl, time, pl, xloc=xloc.bar_time, bgcolor=transp, border_color=transp))
        array.push(nvEtiq, label.new(time, pl, "", xloc=xloc.bar_time, style=label.style_label_left, color=transp, textcolor=transp, size=size.tiny))

// ============================================================
// TREND DE LIQUIDITÉ — la diagonale le long de laquelle les stops s'alignent
// ============================================================
var array<float> basPrix = array.new_float()
var array<int>   basBar  = array.new_int()
var array<float> hauPrix = array.new_float()
var array<int>   hauBar  = array.new_int()

if not na(pl)
    array.push(basPrix, pl)
    array.push(basBar, bar_index - droite)
    if array.size(basPrix) > profondeur
        array.shift(basPrix)
        array.shift(basBar)
if not na(ph)
    array.push(hauPrix, ph)
    array.push(hauBar, bar_index - droite)
    if array.size(hauPrix) > profondeur
        array.shift(hauPrix)
        array.shift(hauBar)

var line trendBas  = na
var line trendHaut = na
var label etiqBas  = na
var label etiqHaut = na
float projBas  = na
float projHaut = na

// Évalue une droite passant par deux pivots : compte les touches, rejette si un
// pivot passe nettement dessous (au-delà de la tolérance d'égalité).
// Un creux au même niveau qu'un autre reste DANS la tolérance : c'est une touche.
f_evalue(array<float> prix, array<int> barres, int iA, int iB, bool hausse, float marge) =>
    float pA = array.get(prix, iA)
    float pB = array.get(prix, iB)
    int   bA = array.get(barres, iA)
    int   bB = array.get(barres, iB)
    int   touches = 0
    bool  valide  = bB > bA and (hausse ? pB > pA : pB < pA)
    if valide
        float pente = (pB - pA) / (bB - bA)
        for i = iA to array.size(prix) - 1
            if i < array.size(prix)
                float attendu = pA + pente * (array.get(barres, i) - bA)
                float ecart   = array.get(prix, i) - attendu
                if hausse
                    if ecart < -marge
                        valide := false
                    else if ecart <= marge
                        touches += 1
                else
                    if ecart > marge
                        valide := false
                    else if ecart >= -marge
                        touches += 1
    [valide, touches]

if barstate.islast and montrerTrend
    line.delete(trendBas)
    line.delete(trendHaut)
    label.delete(etiqBas)
    label.delete(etiqHaut)
    float marge = atr * margeTrend

    // ---- diagonale ascendante : on retient la droite la plus touchée ----
    if array.size(basPrix) >= 3
        int n = array.size(basPrix)
        int meilleurA = -1
        int meilleurB = -1
        int meilleurT = 0
        for a = 0 to n - 2
            for b = a + 1 to n - 1
                if b < n
                    [ok, t] = f_evalue(basPrix, basBar, a, b, true, marge)
                    assezLong = array.get(basBar, b) - array.get(basBar, a) >= ecartMini
                    // plus de touches gagne ; à égalité, l'ancrage le plus récent gagne
                    if ok and assezLong and t >= 2 and (t > meilleurT or (t == meilleurT and (meilleurA < 0 or a < meilleurA)))
                        meilleurT := t
                        meilleurA := a
                        meilleurB := b
        if meilleurA >= 0
            p1 = array.get(basPrix, meilleurA)
            b1 = array.get(basBar, meilleurA)
            p2 = array.get(basPrix, meilleurB)
            b2 = array.get(basBar, meilleurB)
            pente = (p2 - p1) / (b2 - b1)
            fin   = bar_index + extension
            projBas := p1 + pente * (fin - b1)
            trendBas := line.new(b1, p1, fin, projBas, xloc=xloc.bar_index, color=color.new(colTrend, 25), width=2)
            etiqBas := label.new(fin, projBas, "trend de liquidité ×" + str.tostring(meilleurT), xloc=xloc.bar_index, style=label.style_label_left, color=transp, textcolor=color.new(colTrend, 10), size=size.tiny)

    // ---- diagonale descendante ----
    if array.size(hauPrix) >= 3
        int n = array.size(hauPrix)
        int meilleurA = -1
        int meilleurB = -1
        int meilleurT = 0
        for a = 0 to n - 2
            for b = a + 1 to n - 1
                if b < n
                    [ok, t] = f_evalue(hauPrix, hauBar, a, b, false, marge)
                    assezLong = array.get(hauBar, b) - array.get(hauBar, a) >= ecartMini
                    if ok and assezLong and t >= 2 and (t > meilleurT or (t == meilleurT and (meilleurA < 0 or a < meilleurA)))
                        meilleurT := t
                        meilleurA := a
                        meilleurB := b
        if meilleurA >= 0
            p1 = array.get(hauPrix, meilleurA)
            b1 = array.get(hauBar, meilleurA)
            p2 = array.get(hauPrix, meilleurB)
            b2 = array.get(hauBar, meilleurB)
            pente = (p2 - p1) / (b2 - b1)
            fin   = bar_index + extension
            projHaut := p1 + pente * (fin - b1)
            trendHaut := line.new(b1, p1, fin, projHaut, xloc=xloc.bar_index, color=color.new(colTrend, 25), width=2)
            etiqHaut := label.new(fin, projHaut, "trend de liquidité ×" + str.tostring(meilleurT), xloc=xloc.bar_index, style=label.style_label_left, color=transp, textcolor=color.new(colTrend, 10), size=size.tiny)

// ============================================================
// RÉCUPÉRATION — le prix casse sous la diagonale puis revient la retravailler
// ============================================================
var box   boiteRecup = na
var label etiqRecup  = na
var int   barreCasse = na
var float niveauCasse = na

// valeur de la diagonale ascendante à la bougie courante
float valTrend = na
if not na(trendBas)
    x1 = line.get_x1(trendBas)
    y1 = line.get_y1(trendBas)
    x2 = line.get_x2(trendBas)
    y2 = line.get_y2(trendBas)
    if x2 != x1
        valTrend := y1 + (y2 - y1) * (bar_index - x1) / (x2 - x1)

if barstate.islast and montrerRecup and montrerTrend
    box.delete(boiteRecup)
    label.delete(etiqRecup)
    if not na(valTrend) and close < valTrend
        // on remonte chercher la bougie qui a cassé la diagonale
        int recul = 0
        int trouveCasse = na
        for r = 0 to 200
            if r < bar_index
                y1b = line.get_y1(trendBas)
                x1b = line.get_x1(trendBas)
                x2b = line.get_x2(trendBas)
                y2b = line.get_y2(trendBas)
                vr = x2b != x1b ? y1b + (y2b - y1b) * (bar_index - r - x1b) / (x2b - x1b) : na
                if na(trouveCasse) and not na(vr) and close[r] >= vr
                    trouveCasse := bar_index - r
        if not na(trouveCasse)
            float basDepuis = ta.lowest(low, math.max(1, bar_index - trouveCasse))
            float hautZone  = valTrend
            boiteRecup := box.new(trouveCasse, hautZone, bar_index + math.round(extension / 3), basDepuis, xloc=xloc.bar_index, bgcolor=color.new(colTrend, 82), border_color=color.new(colTrend, 30), border_width=1, border_style=line.style_dashed)
            etiqRecup := label.new(math.round((trouveCasse + bar_index) / 2), hautZone, "récupération : la diagonale et les equal lows sont à retravailler", xloc=xloc.bar_index, style=label.style_label_down, color=transp, textcolor=color.new(colTrend, 5), size=size.tiny)

// ============================================================
// BALAYAGE — mèche au-delà, clôture en deçà
// ============================================================
if barstate.isconfirmed and marquerBalayage and array.size(nvPrix) > 0
    for i = 0 to array.size(nvPrix) - 1
        if not array.get(nvBalaye, i) and array.get(nvTouches, i) >= minTouches
            prix = array.get(nvPrix, i)
            if array.get(nvHaut, i)
                if high > prix and close < prix
                    array.set(nvBalaye, i, true)
            else
                if low < prix and close > prix
                    array.set(nvBalaye, i, true)

// ============================================================
// NETTOYAGE ET AFFICHAGE
// ============================================================
if barstate.islast
    // 0. fenêtre de pertinence : trop loin du prix ou trop ancien = on retire
    if array.size(nvPrix) > 0
        for z = array.size(nvPrix) - 1 to 0
            if z < array.size(nvPrix)
                tropLoin = math.abs(array.get(nvPrix, z) - close) > atr * distMaxATR
                tropVieux = bar_index - array.get(nvDernier, z) > ageMax
                if tropLoin or tropVieux
                    box.delete(array.get(nvBoite, z))
                    label.delete(array.get(nvEtiq, z))
                    array.remove(nvPrix, z)
                    array.remove(nvBande, z)
                    array.remove(nvDernier, z)
                    array.remove(nvTouches, z)
                    array.remove(nvDebut, z)
                    array.remove(nvHaut, z)
                    array.remove(nvBalaye, z)
                    array.remove(nvBoite, z)
                    array.remove(nvEtiq, z)

    // 1. les niveaux balayés au-delà du quota disparaissent (les plus anciens d'abord)
    int comptBalayes = 0
    if array.size(nvPrix) > 0
        for j = array.size(nvPrix) - 1 to 0
            if j < array.size(nvPrix)
                if array.get(nvBalaye, j)
                    comptBalayes += 1
                    if comptBalayes > garderBalayes
                        box.delete(array.get(nvBoite, j))
                        label.delete(array.get(nvEtiq, j))
                        array.remove(nvPrix, j)
                        array.remove(nvBande, j)
                        array.remove(nvDernier, j)
                        array.remove(nvTouches, j)
                        array.remove(nvDebut, j)
                        array.remove(nvHaut, j)
                        array.remove(nvBalaye, j)
                        array.remove(nvBoite, j)
                        array.remove(nvEtiq, j)

    // 2. élagage par FORCE, pas par distance : on retire d'abord les niveaux
    //    les moins touchés. Une zone d'accumulation lointaine vaut mieux qu'un
    //    pivot isolé tout proche du prix.
    while array.size(nvPrix) > maxNiveaux
        int faible = 0
        int tPire = 999999
        float dPire = -1.0
        for k = 0 to math.max(0, array.size(nvPrix) - 1)
            t = array.get(nvTouches, k)
            d = math.abs(array.get(nvPrix, k) - close)
            if t < tPire or (t == tPire and d > dPire)
                tPire  := t
                dPire  := d
                faible := k
        box.delete(array.get(nvBoite, faible))
        label.delete(array.get(nvEtiq, faible))
        array.remove(nvPrix, faible)
        array.remove(nvBande, faible)
        array.remove(nvDernier, faible)
        array.remove(nvTouches, faible)
        array.remove(nvDebut, faible)
        array.remove(nvHaut, faible)
        array.remove(nvBalaye, faible)
        array.remove(nvBoite, faible)
        array.remove(nvEtiq, faible)

    // 3. dessin : une zone par niveau retenu
    if array.size(nvPrix) > 0
        for k = 0 to array.size(nvPrix) - 1
            prix    = array.get(nvPrix, k)
            bande   = array.get(nvBande, k)
            touches = array.get(nvTouches, k)
            haut    = array.get(nvHaut, k)
            balaye  = array.get(nvBalaye, k)
            visible = touches >= minTouches

            // épaisseur minimale pour rester lisible quand les touches sont serrées
            float mini = tol * 0.35
            float b1 = math.min(prix, bande)
            float b2 = math.max(prix, bande)
            if b2 - b1 < mini
                float centre = (b1 + b2) / 2
                b1 := centre - mini / 2
                b2 := centre + mini / 2

            base    = balaye ? colMort : (haut ? colHaut : colBas)
            // plus il y a de touches, plus la zone est marquée
            int opac = balaye ? 92 : math.max(72, 90 - touches * 5)
            couleur = not visible ? transp : color.new(base, opac)
            bord    = not visible ? transp : color.new(base, balaye ? 60 : 25)

            bo = array.get(nvBoite, k)
            box.set_lefttop(bo, array.get(nvDebut, k), b2)
            box.set_rightbottom(bo, time, b1)
            box.set_bgcolor(bo, couleur)
            box.set_border_color(bo, bord)
            box.set_border_width(bo, balaye ? 1 : 1)
            box.set_border_style(bo, balaye ? line.style_dotted : line.style_solid)

            // confluence : une diagonale de liquidité vient rejoindre cette zone
            bool conflu = false
            if marquerConflu and montrerTrend and visible and not balaye
                if not na(projBas) and projBas >= b1 - tol and projBas <= b2 + tol
                    conflu := true
                if not na(projHaut) and projHaut >= b1 - tol and projHaut <= b2 + tol
                    conflu := true
            if conflu
                box.set_bgcolor(bo, color.new(colTrend, 78))
                box.set_border_color(bo, color.new(colTrend, 0))
                box.set_border_width(bo, 2)

            la = array.get(nvEtiq, k)
            label.set_xy(la, time, (b1 + b2) / 2)
            label.set_text(la, not visible ? "" : (montrerCompte ? "×" + str.tostring(touches) : "") + (balaye ? " balayé" : "") + (conflu ? "  ⚠ confluence" : ""))
            label.set_textcolor(la, not visible ? transp : conflu ? color.new(colTrend, 0) : color.new(base, balaye ? 45 : 0))
            label.set_color(la, transp)
            label.set_size(la, tailleTexte)

// ============================================================
// TABLEAU DE BORD
// ============================================================
var table bord = table.new(position.top_right, 2, 4, border_width=1, border_color=colBordUI, frame_width=1, frame_color=colBordUI)

if barstate.islast and montrerBadge
    int nHaut = 0
    int nBas  = 0
    float procheHaut = na
    float procheBas  = na
    if array.size(nvPrix) > 0
        for k = 0 to array.size(nvPrix) - 1
            if not array.get(nvBalaye, k) and array.get(nvTouches, k) >= minTouches
                p = array.get(nvPrix, k)
                if p > close
                    nHaut += 1
                    procheHaut := na(procheHaut) ? p : math.min(procheHaut, p)
                else
                    nBas += 1
                    procheBas := na(procheBas) ? p : math.max(procheBas, p)

    table.cell(bord, 0, 0, " LIQUIDITY LEVELS ", text_color=colAccent, text_size=tailleTexte, bgcolor=colFondUI)
    table.merge_cells(bord, 0, 0, 1, 0)
    table.cell(bord, 0, 1, " au-dessus ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
    table.cell(bord, 1, 1, na(procheHaut) ? " — " : " " + str.tostring(procheHaut, format.mintick) + "  (" + str.tostring(nHaut) + ") ", text_color=colHaut, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_right)
    table.cell(bord, 0, 2, " en dessous ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
    table.cell(bord, 1, 2, na(procheBas) ? " — " : " " + str.tostring(procheBas, format.mintick) + "  (" + str.tostring(nBas) + ") ", text_color=colBas, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_right)
    table.cell(bord, 0, 3, " confirmation ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
    table.cell(bord, 1, 3, " " + str.tostring(droite) + " bougies ", text_color=colTexte, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_right)

// ============================================================
// ALERTES
// ============================================================
alertcondition(not na(ph), "Sommet confirmé", "Un sommet vient d'être confirmé.")
alertcondition(not na(pl), "Creux confirmé", "Un creux vient d'être confirmé.")
````

<!-- tradingview-pine-id: PUB;d5dc2be358eb4ac3a8c9e04063ef4a29 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# XauLabs — BOS / CHoCH

Source: https://www.tradingview.com/script/IvGbECvJ/

## Description

ENGLISH

What it does

A market either keeps doing what it was doing, or it stops. This indicator marks the exact bar where that question gets answered: a BOS when structure continues in the same direction, a CHoCH when it breaks against it. Two scales are read in parallel — a swing structure for the major turns, an internal structure for the detail inside them — so the chart shows both the shape of the move and its texture.

Where this one differs

Most tools flip the bias to the opposite direction the moment a CHoCH prints. This one does not. A bullish CHoCH inside a downtrend cancels the downtrend and returns the state to RANGE — nothing more. The upside then has to prove its own sequence with a first BOS in its direction before an uptrend is declared. That is a deliberate choice: a change of character is evidence that the previous story ended, not evidence that the opposite story has begun. It is less flattering to read and closer to what actually happens.

How it works (full method)

Confirmed pivots, two widths. Swing pivots use 20 bars on each side by default, internal pivots use 5. A pivot is only registered once the right-hand bars have closed, which is what makes the tool non-repainting — and what makes a level appear with a delay rather than being revised later.
Breaks are judged on the close. A wick beyond a pivot changes nothing. The candle has to close beyond the level for the structure to be considered broken. This is the same rule used across the whole XauLabs set, and it is what separates a break from a sweep.
One level, one break. Each pivot carries a flag. Once it has produced a break it is retired, so a single level cannot trigger a cascade of marks as price oscillates around it.
State machine. Three states per scale: bullish, bearish, range. A break with the trend increments the BOS counter. A break against it sets the state to range and resets the counter to zero. From range, the first break in either direction establishes that direction with one BOS.
Optional shape filter. On the internal scale, breaks can be filtered by candle shape — a bullish break is kept only when the upper wick is shorter than the lower one, and conversely. Off by default.
Dashboard. Two columns, swing and internal, each showing the current state and the number of BOS in the running sequence, plus the exact level whose close would trigger the next CHoCH. When both columns agree, the move is aligned; when the internal scale drops to range while the swing scale still reads bullish, that divergence is the first sign of tiring.

No repainting

Pivots are confirmed by the right-hand bars and never revised. Breaks are evaluated on confirmed bars only. A mark printed in history is exactly what would have been printed live, with the same delay.

Settings

Swing and internal pivot width, either structure on or off, shape filter, which marks to display (all, BOS only, CHoCH only), number of marks kept on screen, level lines, colours, theme, dashboard and text size. Eight alert conditions, four per scale.

Educational structural tool. It gives no buy or sell signals and makes no performance claim. Trading involves substantial risk of loss.

FRANÇAIS

Ce que fait l'indicateur

Un marché continue ce qu'il faisait, ou il s'arrête. Cet indicateur marque la bougie exacte où la question est tranchée : un BOS quand la structure continue dans le même sens, un CHoCH quand elle casse à contresens. Deux échelles sont lues en parallèle — une structure swing pour les tournants majeurs, une structure interne pour le détail à l'intérieur — de sorte que le graphique montre à la fois la forme du mouvement et sa texture.

Ce qui distingue celui-ci

La plupart des outils basculent le biais dans la direction opposée dès qu'un CHoCH apparaît. Pas celui-ci. Un CHoCH haussier dans une tendance baissière annule la tendance baissière et ramène l'état à RANGE — rien de plus. La hausse devra ensuite prouver sa propre séquence par un premier BOS dans son sens avant qu'une tendance haussière soit déclarée. C'est un choix délibéré : un changement de caractère prouve que l'histoire précédente est terminée, pas que l'histoire inverse a commencé. C'est moins flatteur à lire, et plus proche de ce qui se passe réellement.

Comment il fonctionne (méthode complète)

Pivots confirmés, deux largeurs. Les pivots swing utilisent 20 bougies de chaque côté par défaut, les pivots internes 5. Un pivot n'est enregistré qu'une fois les bougies de droite clôturées : c'est ce qui rend l'outil non-repainting, et ce qui fait qu'un niveau apparaît avec un délai plutôt que d'être révisé après coup.
Les cassures se jugent en clôture. Une mèche au-delà d'un pivot ne change rien. La bougie doit clôturer au-delà du niveau pour que la structure soit considérée comme cassée. C'est la règle appliquée dans toute la série XauLabs, et c'est elle qui sépare une cassure d'un balayage.
Un niveau, une cassure. Chaque pivot porte un drapeau. Une fois qu'il a produit une cassure, il est retiré : un même niveau ne peut donc pas déclencher une cascade de marquages pendant que le prix oscille autour.
Machine à états. Trois états par échelle : haussière, baissière, range. Une cassure dans le sens de la tendance incrémente le compteur de BOS. Une cassure à contresens ramène l'état à range et remet le compteur à zéro. Depuis le range, la première cassure dans un sens établit ce sens avec un BOS.
Filtre de forme, optionnel. Sur l'échelle interne, les cassures peuvent être filtrées selon la forme de la bougie : une cassure haussière n'est retenue que si la mèche haute est plus courte que la basse, et inversement. Désactivé par défaut.
Tableau de bord. Deux colonnes, swing et interne, chacune affichant l'état courant et le nombre de BOS de la séquence en cours, plus le niveau exact dont la clôture au-delà déclencherait le prochain CHoCH. Quand les deux colonnes concordent, le mouvement est aligné ; quand l'échelle interne repasse en range alors que le swing reste haussier, cette divergence est le premier signe d'essoufflement.

Aucun repaint

Les pivots sont confirmés par les bougies de droite et ne sont jamais révisés. Les cassures ne sont évaluées que sur bougies confirmées. Un marquage visible dans l'historique est exactement celui qui serait apparu en direct, avec le même délai.

Réglages

Largeur des pivots swing et internes, activation de chaque structure, filtre de forme, marquages affichés (tout, BOS seulement, CHoCH seulement), nombre de marquages conservés, lignes de niveau, couleurs, thème, tableau de bord et taille du texte. Huit conditions d'alerte, quatre par échelle.

Outil structurel à but éducatif. Il ne donne aucun signal d'achat ou de vente et ne formule aucune promesse de performance. Le trading comporte un risque de perte important.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © XauLabs
// NIVEAU 5 / 8 — BOS / CHoCH — v2.0
//
// Changements v1.0 -> v2.0 :
//   - DOUBLE LECTURE : structure INTERNE (pivots courts) et structure SWING
//     (pivots longs) lues en parallèle. La v1.0 n'en avait qu'une, ce qui ne
//     détectait que quelques cassures par jour.
//   - Chaque pivot porte un drapeau "déjà cassé" : un même niveau ne peut plus
//     déclencher deux fois.
//   - Filtre optionnel des cassures peu significatives.
//
// Position de la maison, tenue dans le code :
//   un CHoCH ne crée PAS la tendance inverse. Il annule la tendance en cours et
//   ramène l'état à RANGE. La direction opposée devra prouver sa propre séquence
//   (un premier BOS dans son sens) pour être déclarée.
// Toutes les cassures sont évaluées EN CLÔTURE, jamais sur mèche.
//
// ⚠️ NON TESTÉ. À vérifier : densité des marquages en M5 et M15, cohérence des
//    deux structures entre elles, passage en RANGE après chaque CHoCH.

//@version=6
indicator("XauLabs — BOS / CHoCH", shorttitle="XauLabs · BOS/CHoCH", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// RÉGLAGES
// ============================================================
grpSwing   = "Structure swing (les cassures majeures)"
montrerSwing = input.bool(true, "Afficher la structure swing", group=grpSwing, display=display.none)
pivotSwing = input.int(20, "Largeur des pivots swing", minval=3, maxval=100, group=grpSwing, display=display.none, tooltip="Nombre de bougies de chaque côté. Plus c'est grand, moins il y a de cassures et plus elles sont significatives.")

grpInterne = "Structure interne (le détail du mouvement)"
montrerInterne = input.bool(true, "Afficher la structure interne", group=grpInterne, display=display.none)
pivotInterne = input.int(5, "Largeur des pivots internes", minval=2, maxval=50, group=grpInterne, display=display.none, tooltip="Beaucoup plus court que le swing : c'est ce qui fait apparaître les cassures intermédiaires.")
filtreInterne = input.bool(false, "Filtrer les cassures internes peu franches", group=grpInterne, display=display.none, tooltip="Écarte les cassures dont la bougie n'a pas une forme convaincante.")

grpAffichage = "Affichage"
theme        = input.string("Sombre", "Thème du graphique", options=["Sombre", "Clair"], group=grpAffichage, display=display.none)
quoiAfficher = input.string("Tout", "Marquages affichés", options=["Tout", "BOS seulement", "CHoCH seulement"], group=grpAffichage, display=display.none)
montrerLignes = input.bool(true, "Tracer le niveau cassé", group=grpAffichage, display=display.none)
maxTraces    = input.int(20, "Marquages conservés à l'écran", minval=4, maxval=120, group=grpAffichage, display=display.none)
colHausse    = input.color(#4E9B6E, "Haussier", group=grpAffichage, inline="c", display=display.none)
colBaisse    = input.color(#B0413E, "Baissier", group=grpAffichage, inline="c", display=display.none)
colRange     = input.color(#D9A441, "CHoCH / range", group=grpAffichage, inline="c", display=display.none)
montrerBadge = input.bool(true, "Tableau de bord", group=grpAffichage, display=display.none)
tailleTexte  = input.string(size.small, "Taille du texte", options=[size.tiny, size.small, size.normal, size.large], group=grpAffichage, display=display.none)

// ============================================================
// PALETTE
// ============================================================
clair     = theme == "Clair"
colTexte  = clair ? color.new(#2A2430, 0) : color.new(#F4EFE6, 0)
colFaible = clair ? color.new(#6B6474, 0) : color.new(#8A8494, 0)
colFondUI = clair ? color.new(#FFFFFF, 4) : color.new(#17141A, 6)
colBordUI = color.new(#D9A441, 55)
colAccent = color.new(#D9A441, 0)
transp    = color.new(#000000, 100)

// ============================================================
// MÉMOIRE DES TRACÉS
// ============================================================
var array<line>  traces = array.new_line()
var array<label> etiqs  = array.new_label()

f_trace(int barreNiv, float niveau, string txt, color coul, bool versLeBas, bool interne) =>
    bool afficher = quoiAfficher == "Tout" or (quoiAfficher == "BOS seulement" and txt == "BOS") or (quoiAfficher == "CHoCH seulement" and txt == "CHoCH")
    if afficher
        if montrerLignes
            array.push(traces, line.new(barreNiv, niveau, bar_index, niveau, xloc=xloc.bar_index, color=color.new(coul, interne ? 55 : 25), width=1, style=interne ? line.style_dotted : line.style_dashed))
        array.push(etiqs, label.new(math.round((barreNiv + bar_index) / 2), niveau, txt, xloc=xloc.bar_index, style=versLeBas ? label.style_label_down : label.style_label_up, color=transp, textcolor=color.new(coul, interne ? 30 : 0), size=interne ? size.tiny : tailleTexte))
        while array.size(traces) > maxTraces
            line.delete(array.shift(traces))
        while array.size(etiqs) > maxTraces
            label.delete(array.shift(etiqs))

// ============================================================
// STRUCTURE SWING
// ============================================================
phS = ta.pivothigh(high, pivotSwing, pivotSwing)
plS = ta.pivotlow(low, pivotSwing, pivotSwing)

var float sommetS    = na
var int   sommetSbar = na
var bool  sommetScasse = true
var float creuxS     = na
var int   creuxSbar  = na
var bool  creuxScasse = true
var int   etatS      = 0
var int   bosS       = 0

if not na(phS)
    sommetS      := phS
    sommetSbar   := bar_index - pivotSwing
    sommetScasse := false
if not na(plS)
    creuxS      := plS
    creuxSbar   := bar_index - pivotSwing
    creuxScasse := false

bool bosHausseS = false
bool bosBaisseS = false
bool chochHausseS = false
bool chochBaisseS = false

if barstate.isconfirmed and montrerSwing
    if not na(sommetS) and not sommetScasse and close > sommetS
        sommetScasse := true
        if etatS == -1
            etatS := 0
            bosS  := 0
            chochHausseS := true
            f_trace(sommetSbar, sommetS, "CHoCH", colRange, true, false)
        else
            etatS := 1
            bosS  += 1
            bosHausseS := true
            f_trace(sommetSbar, sommetS, "BOS", colHausse, true, false)

    if not na(creuxS) and not creuxScasse and close < creuxS
        creuxScasse := true
        if etatS == 1
            etatS := 0
            bosS  := 0
            chochBaisseS := true
            f_trace(creuxSbar, creuxS, "CHoCH", colRange, false, false)
        else
            etatS := -1
            bosS  += 1
            bosBaisseS := true
            f_trace(creuxSbar, creuxS, "BOS", colBaisse, false, false)

// ============================================================
// STRUCTURE INTERNE
// ============================================================
phI = ta.pivothigh(high, pivotInterne, pivotInterne)
plI = ta.pivotlow(low, pivotInterne, pivotInterne)

var float sommetI    = na
var int   sommetIbar = na
var bool  sommetIcasse = true
var float creuxI     = na
var int   creuxIbar  = na
var bool  creuxIcasse = true
var int   etatI      = 0
var int   bosI       = 0

if not na(phI)
    sommetI      := phI
    sommetIbar   := bar_index - pivotInterne
    sommetIcasse := false
if not na(plI)
    creuxI      := plI
    creuxIbar   := bar_index - pivotInterne
    creuxIcasse := false

// forme de la bougie : mèche haute courte = poussée acheteuse convaincante
bougieHaussiere = filtreInterne ? (high - math.max(close, open)) < (math.min(close, open) - low) : true
bougieBaissiere = filtreInterne ? (high - math.max(close, open)) > (math.min(close, open) - low) : true

bool bosHausseI = false
bool bosBaisseI = false
bool chochHausseI = false
bool chochBaisseI = false

if barstate.isconfirmed and montrerInterne
    if not na(sommetI) and not sommetIcasse and close > sommetI and bougieHaussiere
        sommetIcasse := true
        if etatI == -1
            etatI := 0
            bosI  := 0
            chochHausseI := true
            f_trace(sommetIbar, sommetI, "CHoCH", colRange, true, true)
        else
            etatI := 1
            bosI  += 1
            bosHausseI := true
            f_trace(sommetIbar, sommetI, "BOS", colHausse, true, true)

    if not na(creuxI) and not creuxIcasse and close < creuxI and bougieBaissiere
        creuxIcasse := true
        if etatI == 1
            etatI := 0
            bosI  := 0
            chochBaisseI := true
            f_trace(creuxIbar, creuxI, "CHoCH", colRange, false, true)
        else
            etatI := -1
            bosI  += 1
            bosBaisseI := true
            f_trace(creuxIbar, creuxI, "BOS", colBaisse, false, true)

// ============================================================
// TABLEAU DE BORD
// ============================================================
var table bord = table.new(position.top_right, 3, 4, border_width=1, border_color=colBordUI, frame_width=1, frame_color=colBordUI)

f_nom(int e) => e == 1 ? "HAUSSIÈRE" : e == -1 ? "BAISSIÈRE" : "RANGE"
f_coul(int e) => e == 1 ? colHausse : e == -1 ? colBaisse : colRange

if barstate.islast and montrerBadge
    string aSurveillerS = etatS == 1 ? "CHoCH sous " + str.tostring(creuxS, format.mintick) : etatS == -1 ? "CHoCH au-dessus de " + str.tostring(sommetS, format.mintick) : "BOS pour établir une tendance"

    table.cell(bord, 0, 0, " STRUCTURE ", text_color=colAccent, text_size=tailleTexte, bgcolor=colFondUI, text_halign=text.align_left)
    table.cell(bord, 1, 0, " swing ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_center)
    table.cell(bord, 2, 0, " interne ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_center)

    table.cell(bord, 0, 1, " état ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
    table.cell(bord, 1, 1, " " + f_nom(etatS) + " ", text_color=f_coul(etatS), text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_center)
    table.cell(bord, 2, 1, " " + f_nom(etatI) + " ", text_color=f_coul(etatI), text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_center)

    table.cell(bord, 0, 2, " BOS dans la séquence ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
    table.cell(bord, 1, 2, " " + str.tostring(bosS) + " ", text_color=colTexte, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_center)
    table.cell(bord, 2, 2, " " + str.tostring(bosI) + " ", text_color=colTexte, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_center)

    table.cell(bord, 0, 3, " à surveiller (swing) ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
    table.cell(bord, 1, 3, " " + aSurveillerS + " ", text_color=colTexte, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_right)
    table.merge_cells(bord, 1, 3, 2, 3)

// ============================================================
// ALERTES
// ============================================================
alertcondition(bosHausseS,   "BOS haussier (swing)",     "Cassure de structure haussière confirmée en clôture.")
alertcondition(bosBaisseS,   "BOS baissier (swing)",     "Cassure de structure baissière confirmée en clôture.")
alertcondition(chochHausseS, "CHoCH haussier (swing)",   "Changement de caractère haussier : la structure repasse en range.")
alertcondition(chochBaisseS, "CHoCH baissier (swing)",   "Changement de caractère baissier : la structure repasse en range.")
alertcondition(bosHausseI,   "BOS haussier (interne)",   "Cassure interne haussière confirmée en clôture.")
alertcondition(bosBaisseI,   "BOS baissier (interne)",   "Cassure interne baissière confirmée en clôture.")
alertcondition(chochHausseI, "CHoCH haussier (interne)", "Changement de caractère interne haussier.")
alertcondition(chochBaisseI, "CHoCH baissier (interne)", "Changement de caractère interne baissier.")
````

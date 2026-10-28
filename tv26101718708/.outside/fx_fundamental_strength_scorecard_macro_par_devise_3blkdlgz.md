# FX Fundamental Strength - Scorecard macro par devise

- url: https://www.tradingview.com/script/3BlKdLGZ/
- type: indicator
- pine_id: PUB;0a7481f8243b43199d97aeb2de3c3437
- version: 1.0

## Description

Description
FX Fundamental Strength calcule un score de force fondamentale pour 8 devises majeures (USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD) et les classe en temps reel. L'objectif est de fournir un contexte macro clair, pas un signal d'entree.
Pour chaque devise, l'indicateur combine 4 metriques:

Taux directeur (request.economic INTR): plus il est haut, plus la devise est forte.
Inflation annuelle (IRYY): par defaut une inflation elevee est lue comme hawkish (option desactivable).
Momentum du rendement 2 ans: variation du taux 2 ans sur N jours, un rendement qui monte renforce la devise.
Taux de chomage (UR): plus il est bas, plus la devise est forte.

Notation relative
Chaque metrique est notee en relatif: une devise gagne des points selon le nombre d'autres devises qu'elle bat sur cette metrique. Cette approche est robuste aux echelles differentes et aux donnees manquantes (une valeur indisponible vaut 0 point sans casser le calcul). Les 4 scores sont ensuite combines selon des ponderations reglables (par defaut: Taux 40, Momentum 25, Inflation 20, Chomage 15).
Le resultat est un score de 0 a 100 par devise, ou 100 represente la plus forte du panier, avec un classement et un code couleur.
Biais LONG / SHORT
L'indicateur met en avant la devise la plus forte et la plus faible du moment, et propose un biais directionnel: LONG sur la plus forte, SHORT sur la plus faible. Des alertes se declenchent quand la devise la plus forte ou la plus faible change.
Parametres principaux

Ponderations des 4 metriques
Fenetre du momentum 2 ans (jours)
Symboles des rendements 2 ans modifiables (par exemple basculer sur le 10 ans si le 2 ans n'est pas disponible)
Position, taille et affichage du tableau

A noter
C'est un outil de contexte fondamental, a croiser avec ton propre timing (structure de marche, niveaux, methodologie d'execution). L'EUR utilise le Bund allemand comme proxy de rendement. 32 appels de donnees au total (4 metriques x 8 devises), sous la limite Pine.

## Source Code

````pine
//@version=6
// =====================================================================
//  FX FUNDAMENTAL DASHBOARD — Différentiel de taux + Spreads obligataires
// ---------------------------------------------------------------------
//  Donne un BIAIS DIRECTIONNEL macro sur une paire de devises.
//  100% compatible CFD : tu choisis les 2 devises à la main (menus),
//  le script ne dépend donc PAS du ticker affiché par ton broker.
//
//  Sources de données (externes au graphique) :
//    - Taux directeurs des banques centrales  -> request.economic()
//    - Rendements obligataires 2 ans / 10 ans  -> TVC (request.security)
//
//  ⚠️ Outil de CONTEXTE / biais, pas un signal d'entrée.
//     L'entrée reste sur ton modèle technique (ICT, etc.).
// =====================================================================
indicator("FX Fundamental Dashboard", overlay = true, max_labels_count = 1)

// ---------------------------------------------------------------------
//  INPUTS
// ---------------------------------------------------------------------
var string GP = "Paire de devises"
baseCur  = input.string("EUR", "Devise de base (gauche)",
     options = ["USD","EUR","GBP","JPY","AUD","NZD","CAD","CHF"], group = GP,
     tooltip = "1ère devise de la paire. Ex : EUR/USD -> EUR")
quoteCur = input.string("USD", "Devise de cotation (droite)",
     options = ["USD","EUR","GBP","JPY","AUD","NZD","CAD","CHF"], group = GP,
     tooltip = "2ème devise. Ex : EUR/USD -> USD")

var string GC = "Calcul"
lookback = input.int(20, "Lookback variation (barres)", minval = 1, group = GC,
     tooltip = "Nombre de barres pour mesurer si un différentiel s'écarte (↑) ou se resserre (↓).")
useRate  = input.bool(true, "Taux directeurs",        group = GC)
use2Y    = input.bool(true, "Spread obligataire 2 ans",  group = GC)
use10Y   = input.bool(true, "Spread obligataire 10 ans", group = GC)

var string GD = "Affichage"
tblPos  = input.string("top_right", "Position du tableau",
     options = ["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group = GD)
txtSize = input.string("normal", "Taille du texte",
     options = ["tiny","small","normal","large"], group = GD)

// ---------------------------------------------------------------------
//  MAPPINGS devise -> code pays (économie) et symbole obligataire (TVC)
// ---------------------------------------------------------------------
ccode(cur) =>
    switch cur
        "USD" => "US"
        "EUR" => "EU"
        "GBP" => "GB"
        "JPY" => "JP"
        "AUD" => "AU"
        "NZD" => "NZ"
        "CAD" => "CA"
        "CHF" => "CH"
        => "US"

// Pour l'EUR on prend le Bund allemand (DE) comme benchmark de référence.
ysym(cur, tenor) =>
    c = switch cur
        "USD" => "US"
        "EUR" => "DE"
        "GBP" => "GB"
        "JPY" => "JP"
        "AUD" => "AU"
        "NZD" => "NZ"
        "CAD" => "CA"
        "CHF" => "CH"
        => "US"
    "TVC:" + c + tenor

// ---------------------------------------------------------------------
//  RÉCUPÉRATION DES DONNÉES
// ---------------------------------------------------------------------
// Taux directeurs (en %)
baseRate  = request.economic(ccode(baseCur),  "INTR", ignore_invalid_symbol = true)
quoteRate = request.economic(ccode(quoteCur), "INTR", ignore_invalid_symbol = true)

// Rendements obligataires (en %), tirés en daily pour rester stables en intraday
base10  = request.security(ysym(baseCur,  "10Y"), "D", close, ignore_invalid_symbol = true)
quote10 = request.security(ysym(quoteCur, "10Y"), "D", close, ignore_invalid_symbol = true)
base02  = request.security(ysym(baseCur,  "02Y"), "D", close, ignore_invalid_symbol = true)
quote02 = request.security(ysym(quoteCur, "02Y"), "D", close, ignore_invalid_symbol = true)

// ---------------------------------------------------------------------
//  DIFFÉRENTIELS & TENDANCES
//  diff > 0  => avantage à la devise de BASE  => biais HAUSSIER pour la paire
//  trend > 0 => l'écart se creuse en faveur de la base => momentum qui s'accélère
// ---------------------------------------------------------------------
rateDiff = baseRate - quoteRate
diff02   = base02   - quote02
diff10   = base10   - quote10

rateTrend = rateDiff - rateDiff[lookback]
trend02   = diff02   - diff02[lookback]
trend10   = diff10   - diff10[lookback]

// ---------------------------------------------------------------------
//  SCORE / BIAIS GLOBAL  (basé sur le NIVEAU des différentiels)
// ---------------------------------------------------------------------
score = 0.0
n     = 0
if useRate and not na(rateDiff)
    score += math.sign(rateDiff)
    n     += 1
if use2Y and not na(diff02)
    score += math.sign(diff02)
    n     += 1
if use10Y and not na(diff10)
    score += math.sign(diff10)
    n     += 1

biasScore = n > 0 ? score / n : na   // normalisé entre -1 et +1

biasTxt = na(biasScore) ? "INDISPONIBLE" :
     biasScore >=  0.66 ? "FORT ▲ " + baseCur :
     biasScore >=  0.34 ? "MODÉRÉ ▲ " + baseCur :
     biasScore >  -0.34 ? "NEUTRE" :
     biasScore >  -0.66 ? "MODÉRÉ ▼ " + baseCur + " (▲ " + quoteCur + ")" :
     "FORT ▼ " + baseCur + " (▲ " + quoteCur + ")"

biasCol = na(biasScore) ? color.new(color.gray, 0) :
     biasScore >=  0.34 ? color.new(#089981, 0) :
     biasScore <= -0.34 ? color.new(#f23645, 0) :
     color.new(color.gray, 0)

// ---------------------------------------------------------------------
//  HELPERS D'AFFICHAGE
// ---------------------------------------------------------------------
fpct(x) => na(x) ? "n/a" : str.tostring(x, "#.##") + "%"
fdif(x) => na(x) ? "n/a" : (x > 0 ? "+" : "") + str.tostring(x, "#.##")
arrow(x) => na(x) ? "·" : x > 0 ? "▲" : x < 0 ? "▼" : "▬"

// Couleur d'une cellule de différentiel : vert si base favorisée, rouge sinon
dcol(x) => na(x) ? color.new(color.gray, 30) :
     x > 0 ? color.new(#089981, 0) : x < 0 ? color.new(#f23645, 0) : color.new(color.gray, 0)

favTxt(x) => na(x) ? "—" : x > 0 ? baseCur : x < 0 ? quoteCur : "neutre"

posSel = switch tblPos
    "top_right"     => position.top_right
    "top_left"      => position.top_left
    "bottom_right"  => position.bottom_right
    "bottom_left"   => position.bottom_left
    "middle_right"  => position.middle_right
    "middle_left"   => position.middle_left
    => position.top_right

szSel = switch txtSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.normal

// ---------------------------------------------------------------------
//  TABLEAU
// ---------------------------------------------------------------------
var table t = table.new(posSel, 6, 7, border_width = 1, frame_width = 1,
     frame_color = color.new(color.gray, 40), border_color = color.new(color.gray, 60))

if barstate.islast
    bgHdr = color.new(#2a2e39, 0)
    txHdr = color.white

    // Titre
    table.cell(t, 0, 0, "FX FONDAMENTAL  —  " + baseCur + "/" + quoteCur,
         text_color = txHdr, text_size = szSel, bgcolor = bgHdr, text_halign = text.align_left)
    table.merge_cells(t, 0, 0, 5, 0)

    // En-têtes de colonnes
    table.cell(t, 0, 1, "Métrique",  text_color = txHdr, text_size = szSel, bgcolor = bgHdr, text_halign = text.align_left)
    table.cell(t, 1, 1, baseCur,     text_color = txHdr, text_size = szSel, bgcolor = bgHdr)
    table.cell(t, 2, 1, quoteCur,    text_color = txHdr, text_size = szSel, bgcolor = bgHdr)
    table.cell(t, 3, 1, "Diff",      text_color = txHdr, text_size = szSel, bgcolor = bgHdr)
    table.cell(t, 4, 1, "Tend.",     text_color = txHdr, text_size = szSel, bgcolor = bgHdr)
    table.cell(t, 5, 1, "Favorise",  text_color = txHdr, text_size = szSel, bgcolor = bgHdr)

    bgRow = color.new(#1c2030, 0)

    // Ligne : Taux directeurs
    rRate = useRate ? 2 : -1
    if useRate
        table.cell(t, 0, 2, "Taux dir.", text_color = color.white, text_size = szSel, bgcolor = bgRow, text_halign = text.align_left)
        table.cell(t, 1, 2, fpct(baseRate),  text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 2, 2, fpct(quoteRate), text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 3, 2, fdif(rateDiff),  text_color = color.white, text_size = szSel, bgcolor = dcol(rateDiff))
        table.cell(t, 4, 2, arrow(rateTrend), text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 5, 2, favTxt(rateDiff), text_color = color.white, text_size = szSel, bgcolor = bgRow)

    // Ligne : Oblig 2 ans
    if use2Y
        table.cell(t, 0, 3, "Oblig. 2A", text_color = color.white, text_size = szSel, bgcolor = bgRow, text_halign = text.align_left)
        table.cell(t, 1, 3, fpct(base02),  text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 2, 3, fpct(quote02), text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 3, 3, fdif(diff02),  text_color = color.white, text_size = szSel, bgcolor = dcol(diff02))
        table.cell(t, 4, 3, arrow(trend02), text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 5, 3, favTxt(diff02), text_color = color.white, text_size = szSel, bgcolor = bgRow)

    // Ligne : Oblig 10 ans
    if use10Y
        table.cell(t, 0, 4, "Oblig. 10A", text_color = color.white, text_size = szSel, bgcolor = bgRow, text_halign = text.align_left)
        table.cell(t, 1, 4, fpct(base10),  text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 2, 4, fpct(quote10), text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 3, 4, fdif(diff10),  text_color = color.white, text_size = szSel, bgcolor = dcol(diff10))
        table.cell(t, 4, 4, arrow(trend10), text_color = color.white, text_size = szSel, bgcolor = bgRow)
        table.cell(t, 5, 4, favTxt(diff10), text_color = color.white, text_size = szSel, bgcolor = bgRow)

    // Biais global
    table.cell(t, 0, 5, "BIAIS GLOBAL", text_color = color.white, text_size = szSel, bgcolor = bgHdr, text_halign = text.align_left)
    table.cell(t, 1, 5, biasTxt, text_color = color.white, text_size = szSel, bgcolor = biasCol)
    table.merge_cells(t, 1, 5, 5, 5)

    // Note
    table.cell(t, 0, 6, "Contexte directionnel — pas un signal d'entrée",
         text_color = color.new(color.gray, 0), text_size = size.tiny, bgcolor = bgRow, text_halign = text.align_left)
    table.merge_cells(t, 0, 6, 5, 6)
````

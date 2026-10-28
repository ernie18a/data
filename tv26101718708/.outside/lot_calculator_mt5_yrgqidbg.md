# Lot Calculator MT5

- url: https://www.tradingview.com/script/yrGQiDBG/
- type: indicator
- pine_id: PUB;fa3d9edd0ca645f28f2719ec946d1ad6
- version: 2.0

## Description

MT5 Lot Size Calculator – Forex & Gold

Simple and accurate lot size calculator for TradingView, designed for Forex traders and XAUUSD (Gold).

Set your risk percentage and stop loss, and the tool automatically calculates the ideal position size for MT5.

✔ Forex compatible
✔ Gold (XAUUSD) compatible
✔ Automatic risk management
✔ Fast and easy to use
✔ Perfect for prop firms and disciplined trading

Trade with clear and professional risk management directly from TradingView.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  CALCULATEUR DE LOT (VOLUME MT5) — FOREX & GOLD
//  · PE / SL / TP glissables directement sur le graphique (input.price)
//  · Capital, % de risque, specs du contrat et conversion de devise manuels
//  · Volume arrondi aux contraintes MT5 : volume_step / volume_min / volume_max
// ════════════════════════════════════════════════════════════════════════════
indicator("Calculateur de Lot MT5 — Forex & Gold", "Lot MT5", overlay = true,
     max_lines_count = 50, max_labels_count = 50, max_boxes_count = 50)

// ───────────────────────────── 1 · COMPTE & RISQUE ─────────────────────────
g1       = "1 · Compte & risque"
capital  = input.float(100000, "Capital du compte", minval = 0, step = 100, group = g1,
     tooltip = "Solde / equity MT5 servant de base au calcul du risque.")
riskMode = input.string("Pourcentage", "Mode de risque", options = ["Pourcentage", "Montant fixe"], group = g1)
riskPct  = input.float(1.0, "Risque (%)", minval = 0, maxval = 100, step = 0.1, group = g1)
riskCash = input.float(1000, "Risque (montant fixe)", minval = 0, step = 10, group = g1)
commMode = input.string("Par lot / par sens", "Commission",
     options = ["Aucune", "Par lot / par sens", "Par lot aller-retour"], group = g1,
     tooltip = "MT5 facture le plus souvent par lot et par sens (entrée + sortie).")
commVal  = input.float(3.5, "Montant commission", minval = 0, step = 0.5, group = g1)
leverage = input.int(500, "Levier du compte (1:x)", minval = 1, step = 50, group = g1,
     tooltip = "Sert uniquement au calcul indicatif de la marge requise.")

// ──────────────── 2 · NIVEAUX (glissables sur le graphique) ────────────────
// confirm = true → TradingView demande 3 clics à l'ajout de l'indicateur,
// puis chaque ligne reste déplaçable à la souris directement sur le graphique.
g2   = "2 · Niveaux — glissables sur le graphique"
peIn = input.price(0.0, "① Prix d'entrée (PE)", group = g2, confirm = true)
slIn = input.price(0.0, "② Stop Loss (SL)", group = g2, confirm = true)
tpIn = input.price(0.0, "③ Take Profit (TP)", group = g2, confirm = true)

// ─────────────── 3 · SPÉCIFICATIONS SYMBOLE (comme dans MT5) ───────────────
g3        = "3 · Spécifications du symbole (MT5)"
autoSpec  = input.bool(true, "Détection auto (Forex / XAU / XAG / autre)", group = g3,
     tooltip = "Décoche pour saisir Contract Size et Point exactement comme dans la fenêtre « Spécification » de MT5.")
cSizeIn   = input.float(100000, "Contract Size (1 lot)", minval = 0.000001, group = g3,
     tooltip = "MT5 → Symboles → Spécification.\nForex : 100 000 · XAUUSD : 100 · XAGUSD : 5 000 · Indices : 1")
pointIn   = input.float(0.00001, "Point MT5 (plus petit incrément)", minval = 0.0000001, group = g3,
     tooltip = "EURUSD 5 chiffres : 0.00001 · USDJPY 3 chiffres : 0.001 · XAUUSD 2 chiffres : 0.01")
pipFactor = input.int(10, "Points par pip", minval = 1, group = g3,
     tooltip = "10 pour les symboles à 5 (ou 3) chiffres, 1 pour ceux à 4 (ou 2) chiffres.")

// ─────────────────── 4 · CONTRAINTES DE VOLUME DU BROKER ───────────────────
g4       = "4 · Volume MT5 (contraintes broker)"
stepMode = input.string("0.01 (standard)", "Volume step",
     options = ["0.01 (standard)", "0.1", "1.0", "Personnalisé"], group = g4,
     tooltip = "MT5 rejette tout volume qui n'est pas un multiple exact du Volume step.")
stepCust = input.float(0.01, "Volume step personnalisé", minval = 0.000001, step = 0.01, group = g4)
volMinIn = input.float(0.01, "Volume min", minval = 0, step = 0.01, group = g4)
volMaxIn = input.float(100.0, "Volume max", minval = 0, step = 1, group = g4)
roundDir = input.string("Vers le bas (prudent)", "Arrondi",
     options = ["Vers le bas (prudent)", "Au plus proche"], group = g4)

// ───────────────────────── 5 · CONVERSION DE DEVISE ────────────────────────
g5       = "5 · Conversion de devise"
fxMode   = input.string("Aucune (cotation = compte)", "Mode",
     options = ["Aucune (cotation = compte)", "Taux manuel", "Depuis un symbole"], group = g5,
     tooltip = "Nécessaire si la devise de cotation ≠ devise du compte (ex. EURGBP sur un compte USD).")
fxManual = input.float(1.0, "Taux manuel (cotation → compte)", minval = 0.000001, step = 0.01, group = g5)
fxSymbol = input.symbol("FX_IDC:GBPUSD", "Symbole du taux", group = g5)
fxInvert = input.bool(false, "Inverser le taux du symbole (1 / x)", group = g5)

// ────────────────────────────── 6 · AFFICHAGE ──────────────────────────────
g6        = "6 · Affichage"
showTable = input.bool(true, "Tableau récapitulatif", group = g6)
showLines = input.bool(true, "Lignes PE / SL / TP", group = g6)
showZones = input.bool(true, "Zones risque / gain", group = g6)
showLbls  = input.bool(true, "Étiquettes sur les lignes", group = g6)
showOrder = input.bool(true, "Ligne d'ordre MT5 (à recopier)", group = g6)
barsLeft  = input.int(40, "Barres à gauche", minval = 0, maxval = 500, group = g6)
barsRight = input.int(15, "Barres à droite", minval = 0, maxval = 500, group = g6)
tblPosIn  = input.string("Haut droite", "Position du tableau",
     options = ["Haut droite", "Haut gauche", "Milieu droite", "Milieu gauche", "Bas droite", "Bas gauche"], group = g6)
txtSizeIn = input.string("Normale", "Taille du texte", options = ["Petite", "Normale", "Grande"], group = g6)
colLong   = input.color(#26a69a, "Couleur LONG", group = g6, inline = "c")
colShort  = input.color(#ef5350, "Couleur SHORT", group = g6, inline = "c")

// ══════════════════════════════════════════════════════════════════════════
//  NIVEAUX EFFECTIFS (repli tant qu'aucun clic n'a été fait)
// ══════════════════════════════════════════════════════════════════════════
atr14  = ta.atr(14)
pe     = peIn > 0 ? peIn : close
sl     = slIn > 0 ? slIn : pe - atr14
tp     = tpIn > 0 ? tpIn : pe + 2 * atr14
isLong = sl < pe

// ══════════════════════════════════════════════════════════════════════════
//  SPÉCIFICATIONS — détection automatique
// ══════════════════════════════════════════════════════════════════════════
tk    = str.upper(syminfo.ticker)
isXAU = str.contains(tk, "XAU") or str.contains(tk, "GOLD")
isXAG = str.contains(tk, "XAG") or str.contains(tk, "SILVER")
isXPT = str.contains(tk, "XPT")
isXPD = str.contains(tk, "XPD")
isFx  = syminfo.type == "forex"

autoContract = isXAU ? 100.0 : isXAG ? 5000.0 : isXPT ? 50.0 : isXPD ? 100.0 : isFx ? 100000.0 : 1.0
autoPoint    = syminfo.mintick
autoPipFact  = isXAU or isXAG or isFx ? 10 : 1

contractSize = autoSpec ? autoContract : cSizeIn
mt5Point     = autoSpec ? autoPoint : pointIn
ptsPerPip    = autoSpec ? autoPipFact : pipFactor
pipSize      = mt5Point * ptsPerPip

specLabel = isXAU ? "XAU · 100 oz/lot" : isXAG ? "XAG · 5 000 oz/lot" : isFx ? "Forex · 100 000/lot" : "Contract size " + str.tostring(contractSize, "#.##")

// ══════════════════════════════════════════════════════════════════════════
//  TAUX DE CONVERSION cotation → devise du compte
// ══════════════════════════════════════════════════════════════════════════
fxRaw = request.security(fxSymbol, timeframe.period, close, ignore_invalid_symbol = true)
fxSym = na(fxRaw) or fxRaw <= 0 ? 1.0 : (fxInvert ? 1.0 / fxRaw : fxRaw)
fxRate = switch fxMode
    "Taux manuel"       => fxManual
    "Depuis un symbole" => fxSym
    => 1.0

// ══════════════════════════════════════════════════════════════════════════
//  CALCUL DU VOLUME MT5
// ══════════════════════════════════════════════════════════════════════════
volStep = switch stepMode
    "0.01 (standard)" => 0.01
    "0.1"             => 0.1
    "1.0"             => 1.0
    => stepCust

// Valeur, en devise du compte, d'un mouvement de 1.0 de prix pour 1 lot
valPerUnit = contractSize * fxRate
tickValue  = mt5Point * valPerUnit          // « Tick value » MT5 : 1 point, 1 lot

// Commission totale aller-retour, par lot
commRT = switch commMode
    "Par lot / par sens"   => commVal * 2
    "Par lot aller-retour" => commVal
    => 0.0

riskAllowed = riskMode == "Pourcentage" ? capital * riskPct / 100.0 : riskCash

slDist = math.abs(pe - sl)
tpDist = math.abs(tp - pe)
slPts  = mt5Point > 0 ? slDist / mt5Point : 0.0
tpPts  = mt5Point > 0 ? tpDist / mt5Point : 0.0
slPips = pipSize > 0 ? slDist / pipSize : 0.0
tpPips = pipSize > 0 ? tpDist / pipSize : 0.0

// Risque pour 1 lot = perte au SL + commission aller-retour
riskPerLot = slDist * valPerUnit + commRT
volExact   = riskPerLot > 0 ? riskAllowed / riskPerLot : 0.0

// Arrondi strict au multiple de volume_step (sinon MT5 rejette l'ordre)
eps     = 0.000000001
volDown = math.floor(volExact / volStep + eps) * volStep
volNear = math.round(volExact / volStep) * volStep
volSnap = roundDir == "Au plus proche" ? volNear : volDown
lotVol  = math.max(0.0, math.min(volSnap, volMaxIn))
// Nettoyage flottant pour un affichage propre (0.42999… → 0.43)
lotVol := math.round(lotVol / volStep) * volStep

volDec = volStep >= 1 ? 0 : volStep >= 0.1 ? 1 : 2
volFmt = volDec == 0 ? "#" : volDec == 1 ? "#.0" : "#.00"

nUnits      = lotVol * contractSize
pipValue    = lotVol * pipSize * valPerUnit
ptValue     = lotVol * mt5Point * valPerUnit
commTotal   = lotVol * commRT
riskReal    = lotVol * slDist * valPerUnit + commTotal
gainReal    = lotVol * tpDist * valPerUnit - commTotal
riskRealPct = capital > 0 ? riskReal / capital * 100.0 : 0.0
gainRealPct = capital > 0 ? gainReal / capital * 100.0 : 0.0
rr          = slDist > 0 ? tpDist / slDist : 0.0

// Marge indicative (MT5 : Contract Size × Volume × Prix / Levier)
marginReq = nUnits * pe * fxRate / leverage

// Break-even : prix qui couvre la commission
beShift   = valPerUnit > 0 ? commRT / valPerUnit : 0.0
breakEven = isLong ? pe + beShift : pe - beShift

// ── Contrôles de cohérence
warn = ""
if capital <= 0
    warn := "⚠ Capital nul ou négatif"
else if slDist == 0
    warn := "⚠ SL = PE : distance nulle"
else if isLong and tp <= pe
    warn := "⚠ LONG : le TP doit être au-dessus du PE"
else if not isLong and tp >= pe
    warn := "⚠ SHORT : le TP doit être en dessous du PE"
else if lotVol <= 0
    warn := "⚠ Volume 0 : SL trop large pour ce risque"
else if lotVol < volMinIn
    warn := "⚠ " + str.tostring(lotVol, volFmt) + " < volume min MT5 (" + str.tostring(volMinIn, volFmt) + ") → ordre rejeté"
else if volSnap > volMaxIn
    warn := "⚠ Volume plafonné au max broker (" + str.tostring(volMaxIn, volFmt) + ")"

dirCol = isLong ? colLong : colShort
dirTxt = isLong ? "LONG ▲" : "SHORT ▼"

orderTxt = (isLong ? "BUY " : "SELL ") + str.tostring(lotVol, volFmt) + " " + syminfo.ticker +
     "   @ " + str.tostring(pe, format.mintick) +
     "   SL " + str.tostring(sl, format.mintick) +
     "   TP " + str.tostring(tp, format.mintick)

// ══════════════════════════════════════════════════════════════════════════
//  DESSIN SUR LE GRAPHIQUE
// ══════════════════════════════════════════════════════════════════════════
var line  lnPE = na
var line  lnSL = na
var line  lnTP = na
var line  lnBE = na
var box   bxRisk = na
var box   bxGain = na
var label lbPE = na
var label lbSL = na
var label lbTP = na
var label lbOrd = na

if barstate.islast
    x1 = bar_index - barsLeft
    x2 = bar_index + barsRight

    line.delete(lnPE)
    line.delete(lnSL)
    line.delete(lnTP)
    line.delete(lnBE)
    box.delete(bxRisk)
    box.delete(bxGain)
    label.delete(lbPE)
    label.delete(lbSL)
    label.delete(lbTP)
    label.delete(lbOrd)

    if showZones
        bxRisk := box.new(x1, pe, x2, sl, border_color = color.new(colShort, 60),
             border_width = 1, bgcolor = color.new(colShort, 88))
        bxGain := box.new(x1, pe, x2, tp, border_color = color.new(colLong, 60),
             border_width = 1, bgcolor = color.new(colLong, 88))

    if showLines
        lnPE := line.new(x1, pe, x2, pe, color = color.new(#787b86, 0), width = 2)
        lnSL := line.new(x1, sl, x2, sl, color = colShort, width = 2)
        lnTP := line.new(x1, tp, x2, tp, color = colLong, width = 2)
        if commRT > 0
            lnBE := line.new(x1, breakEven, x2, breakEven, color = color.new(#ff9800, 20),
                 width = 1, style = line.style_dotted)

    if showLbls
        txtPE = "PE  " + str.tostring(pe, format.mintick) + "   ▸ " + str.tostring(lotVol, volFmt) + " lot"
        txtSL = "SL  " + str.tostring(sl, format.mintick) + "   −" + str.tostring(slPips, "#.#") +
             " pips / " + str.tostring(slPts, "#") + " pts   −" + str.tostring(riskReal, "#.##")
        txtTP = "TP  " + str.tostring(tp, format.mintick) + "   +" + str.tostring(tpPips, "#.#") +
             " pips / " + str.tostring(tpPts, "#") + " pts   +" + str.tostring(gainReal, "#.##") +
             "   (" + str.tostring(rr, "#.##") + "R)"
        lbPE := label.new(x2, pe, txtPE, xloc = xloc.bar_index, style = label.style_label_left,
             color = color.new(#787b86, 10), textcolor = color.white, size = size.normal)
        lbSL := label.new(x2, sl, txtSL, xloc = xloc.bar_index, style = label.style_label_left,
             color = color.new(colShort, 10), textcolor = color.white, size = size.normal)
        lbTP := label.new(x2, tp, txtTP, xloc = xloc.bar_index, style = label.style_label_left,
             color = color.new(colLong, 10), textcolor = color.white, size = size.normal)

    if showOrder
        lbOrd := label.new(bar_index, isLong ? sl : tp, orderTxt, xloc = xloc.bar_index,
             yloc = yloc.price, style = label.style_label_up, color = color.new(#1e222d, 5),
             textcolor = color.new(#d1d4dc, 0), size = size.small)

// ══════════════════════════════════════════════════════════════════════════
//  TABLEAU RÉCAPITULATIF
// ══════════════════════════════════════════════════════════════════════════
tblPos = switch tblPosIn
    "Haut droite"   => position.top_right
    "Haut gauche"   => position.top_left
    "Milieu droite" => position.middle_right
    "Milieu gauche" => position.middle_left
    "Bas droite"    => position.bottom_right
    => position.bottom_left

txtSize = switch txtSizeIn
    "Petite" => size.small
    "Grande" => size.large
    => size.normal

cBg   = color.new(#131722, 8)
cSep  = color.new(#2a2e39, 0)
cKey  = color.new(#b2b5be, 0)
cNone = color(na)

var table t = table.new(tblPos, 2, 21, bgcolor = cBg, border_color = cSep, border_width = 1,
     frame_color = cSep, frame_width = 1)

// Pine interdit les valeurs par défaut calculées : tous les arguments sont explicites.
row(int r, string k, string v, color vc, color bg, bool bold) =>
    table.cell(t, 0, r, k, text_color = bold ? color.white : cKey, text_size = txtSize,
         text_halign = text.align_left, bgcolor = bg)
    table.cell(t, 1, r, v, text_color = vc, text_size = txtSize,
         text_halign = text.align_right, bgcolor = bg)

sep(int r) =>
    table.cell(t, 0, r, "", bgcolor = cSep, height = 0.3)
    table.cell(t, 1, r, "", bgcolor = cSep, height = 0.3)

if barstate.islast and showTable
    rrCol   = rr >= 2 ? colLong : rr >= 1 ? color.new(#ff9800, 0) : colShort
    riskTxt = str.tostring(riskAllowed, "#.##") + "  (" + str.tostring(capital > 0 ? riskAllowed / capital * 100 : 0, "#.##") + " %)"
    lastKey = commRT > 0 ? "Commission / BE" : "Taux conversion"
    lastVal = commRT > 0 ? str.tostring(commTotal, "#.##") + " · " + str.tostring(breakEven, format.mintick) : str.tostring(fxRate, "#.#####")

    row(0, "CALCUL LOT MT5", dirTxt, color.white, color.new(dirCol, 25), true)
    row(1, "Symbole", syminfo.ticker, color.white, cNone, false)
    row(2, "Spécification", specLabel, color.white, cNone, false)
    row(3, "Point / pip", str.tostring(mt5Point, "#.#####") + " · " + str.tostring(pipSize, "#.#####"), color.white, cNone, false)
    row(4, "Tick value (1 lot)", str.tostring(tickValue, "#.#####"), color.white, cNone, false)
    sep(5)
    row(6, "Entrée (PE)", str.tostring(pe, format.mintick), color.white, cNone, false)
    row(7, "Stop Loss", str.tostring(sl, format.mintick) + "  (" + str.tostring(slPts, "#") + " pts / " + str.tostring(slPips, "#.#") + " pips)", colShort, cNone, false)
    row(8, "Take Profit", str.tostring(tp, format.mintick) + "  (" + str.tostring(tpPts, "#") + " pts / " + str.tostring(tpPips, "#.#") + " pips)", colLong, cNone, false)
    row(9, "Ratio R:R", "1 : " + str.tostring(rr, "#.##"), rrCol, cNone, false)
    sep(10)
    row(11, "Risque autorisé", riskTxt, color.white, cNone, false)
    row(12, "▶ VOLUME MT5", str.tostring(lotVol, volFmt) + " lot", color.white, color.new(dirCol, 30), true)
    row(13, "Volume exact", str.tostring(volExact, "#.####") + "  (step " + str.tostring(volStep, volFmt) + ")", color.white, cNone, false)
    row(14, "Unités", str.tostring(nUnits, "#"), color.white, cNone, false)
    row(15, "Valeur pip / point", str.tostring(pipValue, "#.##") + " · " + str.tostring(ptValue, "#.####"), color.white, cNone, false)
    row(16, "Risque réel", str.tostring(riskReal, "#.##") + "  (" + str.tostring(riskRealPct, "#.##") + " %)", colShort, cNone, false)
    row(17, "Gain potentiel", str.tostring(gainReal, "#.##") + "  (" + str.tostring(gainRealPct, "#.##") + " %)", colLong, cNone, false)
    row(18, lastKey, lastVal, color.white, cNone, false)
    row(19, "Marge (1:" + str.tostring(leverage) + ")", str.tostring(marginReq, "#.##"), color.white, cNone, false)
    table.cell(t, 0, 20, warn, text_color = color.new(#ffb74d, 0), text_size = txtSize,
         text_halign = text.align_left, bgcolor = warn == "" ? cBg : color.new(#5d4037, 40))
    table.cell(t, 1, 20, "", bgcolor = warn == "" ? cBg : color.new(#5d4037, 40))
````

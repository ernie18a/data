# ICT Suite - HTF Liquidity, MTF, Breakers, FVG, Intermarket, FX

- url: https://www.tradingview.com/script/SqIpdYPX/
- type: indicator
- pine_id: PUB;4bef8f3df56d48c28f5ff415a6ecb115
- version: 1.0

## Description

APERCU
ICT All in One regroupe en un seul indicateur six outils d'analyse couramment utilises en approche Smart Money Concepts et ICT. L'objectif est de liberer des emplacements d'indicateurs sur le graphique et de centraliser le contexte. Liquidites multi echelles, alignement multi timeframe, niveaux de prix cles, zones de reaction comme les breakers et les FVG, et deux tableaux de sentiment, un pour l'intermarche et un pour le forex.
Chaque bloc dispose d'un interrupteur pour l'activer ou le desactiver dans le groupe Modules. On n'active que ce dont on a besoin.

LES 6 MODULES
1 LIQUIDITES HTF ET SESSIONS
Trace les hauts et bas de la periode precedente. Le jour avec PDH et PDL, la semaine avec PWH et PWL, le mois avec PMH et PML. Trace aussi les hauts et bas des sessions Asie, Londres et New York. Les niveaux HTF sont calcules en non repaint, valeur de la periode close sans redessin. Horaires de session en heure de Paris par defaut, entierement parametrables.
2 ALIGNEMENT MULTI TIMEFRAME
Tableau synthetique de 8 unites de temps configurables, de M1 a Mensuel par defaut. Pour chaque unite de temps, la tendance de la bougie, cloture contre ouverture, et l'etat du croisement EMA 9 et 21. Utile pour verifier d'un coup d'oeil si les echelles sont alignees avant de prendre position.
3 NIVEAUX DE PRIX
Affiche EMA 9, EMA 21, VWAP, le POC du jour calcule sur un profil de volume intrabar, et les naked POC, c'est a dire les POC de seances precedentes qui n'ont pas encore ete retestes. Couleur differenciee selon que le naked POC est au dessus ou en dessous du prix.
4 BREAKERS FVG IFVG ET MODELE 2022
Breaker Blocks haussiers et baissiers detectes via une prise de liquidite sur un swing puis une cassure de structure dite BOS. Suivi du retest et de l'invalidation, la mitigation.
Fair Value Gaps, desequilibre sur 3 bougies.
IFVG, un FVG casse en cloture qui inverse sa polarite, le support devient resistance et inversement.
Marqueurs du modele d'entree 2022 ICT, prise de liquidite puis changement de structure MSS.
5 DASHBOARD INTERMARKET
Tableau de biais multi actifs. DXY, VIX, ES, NQ, YM, GC pour l'or et le rendement US 10Y. Pour chaque actif, le biais du jour avec reference Daily Open ou EMA au choix, et la correlation glissante avec le symbole du graphique. Verdict global Risk On Risk Off base sur l'alignement des indices et du VIX, plus un detecteur de divergence SMT, ES contre NQ par defaut et configurable.
6 DASHBOARD FX RISK ON RISK OFF
Sentiment du marche des changes a partir de 9 paires, soit 7 majeures plus AUD JPY et NZD JPY comme barometres de risque. Chaque paire recoit un score selon le caractere risque ou refuge de ses devises, agrege en un verdict global Risk On Risk Off pondere, avec un seuil reglable.

CONCEPTS ICT ET SMC COUVERTS
Liquidites de reference PDH PDL PWH PWL PMH PML, hauts et bas de sessions, prise de liquidite ou sweep, cassure de structure BOS, changement de structure MSS, breaker blocks, Fair Value Gaps et FVG inverses, modele d'entree 2022, POC et naked POC, VWAP, divergence SMT, sentiment Risk On Risk Off intermarche et forex.

COMMENT L'UTILISER
A placer sur ton instrument principal, par exemple ES ou MES, GC ou MGC, un indice ou une paire forex. Le module Liquidites et les Niveaux donnent les cibles et zones de reaction. L'Alignement multi timeframe et les deux dashboards servent de filtre de contexte directionnel. Les modules dashboards sont surtout pertinents sur les indices et le forex.
Les trois tableaux sont positionnes par defaut dans trois coins differents. Alignement multi timeframe en haut a gauche, Intermarket en haut a droite, FX en bas a droite, pour ne pas se chevaucher. Tout est repositionnable dans les reglages.

REGLAGES PRINCIPAUX
Modules, pour activer ou desactiver chacun des 6 blocs.
Couleurs, styles, epaisseurs et etiquettes pour chaque type de niveau.
Horaires et fuseau des sessions.
Liste des 8 timeframes du tableau multi timeframe.
Symboles Intermarket et parametres SMT, lookback et symboles A et B.
Prefixe broker FX, par exemple OANDA, FX, FX IDC, et seuil de validation Risk On Risk Off.
Position et taille de chaque tableau.

NOTES TECHNIQUES
Pine Script version 6.
Donnees HTF en non repaint, cloture confirmee plus lookahead.
L'indicateur utilise environ 36 appels a la fonction request security, volontairement optimises par regroupement en tuples pour rester sous la limite de la plateforme. Couper un module masque son affichage mais ne reduit pas ce nombre.
Pour limiter le nombre d'appels, le module FX se concentre sur 9 paires et le tableau multi timeframe n'affiche pas de compte a rebours de bougie.

AVERTISSEMENT
Outil d'analyse technique a usage discretionnaire. Les concepts SMC et ICT sont des grilles de lecture, pas des regles deterministes. Le choix exact des swings, des zones et des entrees peut varier selon les ecoles. Cet indicateur ne constitue ni un conseil financier, ni une recommandation, ni un systeme de signaux d'achat ou de vente. Les performances passees ne prejugent pas des resultats futurs. Teste toujours sur compte de demonstration et applique ta propre gestion du risque.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  ICT ALL-IN-ONE  —  fusion des 5 indicateurs
//    1) Liquidités HTF (PDH/PDL, PWH/PWL, PMH/PML) + Sessions Asie/Londres/NY
//    2) Alignement Multi-Timeframe (tendance + EMA 9/21)
//    3) Niveaux : EMA 9/21, VWAP, POC du jour, naked POC de séances
//    4) Breakers / FVG / IFVG / Modèle 2022 ICT
//    5) Dashboard Intermarket (biais, corrélation, Risk-On/Off, SMT)
//    6) Dashboard FX Risk-On / Risk-Off
//
//  ⚠ LIMITE request.security() : Pine plafonne à ~40 appels.
//    Budget de ce script ≈ 36 :
//       Liquidités 3 | MTF 8 | Intermarket 16 | FX 9
//    Compromis pour rester sous la barre :
//       • FX réduit à 9 paires (7 majeures + AUD/JPY + NZD/JPY, baromètres).
//       • Colonne "compte à rebours" du tableau MTF supprimée (économise 8 appels).
//    Chaque module a un interrupteur ON/OFF (groupe ① Modules) pour l'affichage.
//    NB : couper un module masque son rendu mais ne réduit PAS le nb d'appels
//    security (Pine les compte à la compilation). Pour vraiment en retirer,
//    supprime les lignes de calcul concernées.
// ════════════════════════════════════════════════════════════════════════════
indicator("ICT All-in-One", shorttitle="ICT-AIO", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════════════
//  ① MODULES — interrupteurs maîtres
// ════════════════════════════════════════════════════════════════════════════
gMod    = "① Modules"
modLiq   = input.bool(true, "1 · Liquidités HTF + Sessions", group=gMod)
modMTF   = input.bool(true, "2 · Tableau Alignement MTF",    group=gMod)
modLvls  = input.bool(true, "3 · Niveaux EMA/VWAP/POC",      group=gMod)
modBB    = input.bool(true, "4 · Breakers / FVG / IFVG / 2022", group=gMod)
modInter = input.bool(true, "5 · Dashboard Intermarket",     group=gMod)
modFX    = input.bool(true, "6 · Dashboard FX Risk",         group=gMod)

// ─────────── HELPER STYLE COMMUN ───────────
f_style(string s) =>
    s == "Pointillé" ? line.style_dotted : s == "Tirets" ? line.style_dashed : line.style_solid

// ════════════════════════════════════════════════════════════════════════════
//  1 · LIQUIDITÉS HTF + SESSIONS
// ════════════════════════════════════════════════════════════════════════════
gD = "1 · Jour précédent (PDH / PDL)"
showD = input.bool(true, "Afficher", group=gD, inline="d1")
colD  = input.color(color.new(#2962FF, 0), "", group=gD, inline="d1")
styD  = input.string("Solide", "Style", options=["Solide","Pointillé","Tirets"], group=gD, inline="d2")
wD    = input.int(1, "Épaisseur", minval=1, maxval=4, group=gD, inline="d2")

gW = "1 · Semaine précédente (PWH / PWL)"
showW = input.bool(true, "Afficher", group=gW, inline="w1")
colW  = input.color(color.new(#FF6D00, 0), "", group=gW, inline="w1")
styW  = input.string("Tirets", "Style", options=["Solide","Pointillé","Tirets"], group=gW, inline="w2")
wW    = input.int(1, "Épaisseur", minval=1, maxval=4, group=gW, inline="w2")

gMo = "1 · Mois précédent (PMH / PML)"
showM = input.bool(true, "Afficher", group=gMo, inline="m1")
colM  = input.color(color.new(#AA00FF, 0), "", group=gMo, inline="m1")
styM  = input.string("Solide", "Style", options=["Solide","Pointillé","Tirets"], group=gMo, inline="m2")
wM    = input.int(2, "Épaisseur", minval=1, maxval=4, group=gMo, inline="m2")

gS   = "1 · Sessions"
tz   = input.string("Europe/Paris", "Fuseau horaire", group=gS, tooltip="Heure de Paris appliquée aux horaires de session.")
extS = input.bool(false, "Prolonger les niveaux de session à droite", group=gS)

gSa = "1 · Session Asie"
showA = input.bool(true, "Afficher", group=gSa, inline="a")
sessA = input.session("0200-0600", "Horaire", group=gSa, inline="a")
colA  = input.color(color.new(#26A69A, 0), "", group=gSa, inline="a")

gSl = "1 · Session Londres"
showL = input.bool(true, "Afficher", group=gSl, inline="l")
sessL = input.session("0800-1100", "Horaire", group=gSl, inline="l")
colL  = input.color(color.new(#42A5F5, 0), "", group=gSl, inline="l")

gSn = "1 · Session New York"
showN = input.bool(true, "Afficher", group=gSn, inline="n")
sessN = input.session("1530-2200", "Horaire", group=gSn, inline="n")
colN  = input.color(color.new(#EF5350, 0), "", group=gSn, inline="n")

// ─────────── TYPES Liquidités ───────────
type HTF
    line  ln = na
    label lb = na

type Sess
    line  hiLn = na
    line  loLn = na
    label hiLb = na
    label loLb = na
    float hi   = na
    float lo   = na

// ─────────── DONNÉES HTF (non-repaint) — 3 appels security ───────────
[pdh, pdl, pdt] = request.security(syminfo.tickerid, "D", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl, pwt] = request.security(syminfo.tickerid, "W", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)
[pmh, pml, pmt] = request.security(syminfo.tickerid, "M", [high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

dtD = na(pdt) ? "" : str.format_time(pdt, "dd/MM/yy", syminfo.timezone)
dtW = na(pwt) ? "" : str.format_time(pwt, "dd/MM/yy", syminfo.timezone)
dtM = na(pmt) ? "" : str.format_time(pmt, "MM/yyyy",  syminfo.timezone)

newD = timeframe.change("D")
newW = timeframe.change("W")
newM = timeframe.change("M")

method draw(HTF this, bool isNew, bool show, float v, color c, string sty, int w, string txt) =>
    if show and not na(v)
        if isNew or na(this.ln)
            this.ln := line.new(bar_index, v, bar_index + 1, v, color=c, style=f_style(sty), width=w)
            this.lb := label.new(bar_index, v, txt, style=label.style_none, textcolor=c, size=size.small)
        line.set_y1(this.ln, v)
        line.set_xy2(this.ln, bar_index, v)
        label.set_xy(this.lb, bar_index, v)
        label.set_text(this.lb, txt)

method run(Sess this, bool show, string sess, color c, string name) =>
    if show
        inS   = not na(time(timeframe.period, sess, tz))
        start = inS and not inS[1]
        if start
            this.hi   := high
            this.lo   := low
            ext       = extS ? extend.right : extend.none
            dt        = str.format_time(time, "dd/MM", tz)
            this.hiLn := line.new(bar_index, high, bar_index, high, color=c, style=line.style_dotted, width=1, extend=ext)
            this.loLn := line.new(bar_index, low,  bar_index, low,  color=c, style=line.style_dotted, width=1, extend=ext)
            this.hiLb := label.new(bar_index, high, name + " H  " + dt, style=label.style_none, textcolor=c, size=size.tiny)
            this.loLb := label.new(bar_index, low,  name + " L  " + dt, style=label.style_none, textcolor=c, size=size.tiny)
        else if inS and not na(this.hi)
            this.hi := math.max(this.hi, high)
            this.lo := math.min(this.lo, low)
        if inS and not na(this.hiLn)
            line.set_y1(this.hiLn, this.hi)
            line.set_xy2(this.hiLn, bar_index, this.hi)
            line.set_y1(this.loLn, this.lo)
            line.set_xy2(this.loLn, bar_index, this.lo)
            label.set_xy(this.hiLb, bar_index, this.hi)
            label.set_xy(this.loLb, bar_index, this.lo)

var HTF hHi = HTF.new()
var HTF hLo = HTF.new()
var HTF wHi = HTF.new()
var HTF wLo = HTF.new()
var HTF mHi = HTF.new()
var HTF mLo = HTF.new()
var Sess sA = Sess.new()
var Sess sL = Sess.new()
var Sess sN = Sess.new()

if modLiq
    hHi.draw(newD, showD, pdh, colD, styD, wD, "PDH  " + dtD)
    hLo.draw(newD, showD, pdl, colD, styD, wD, "PDL  " + dtD)
    wHi.draw(newW, showW, pwh, colW, styW, wW, "PWH  " + dtW)
    wLo.draw(newW, showW, pwl, colW, styW, wW, "PWL  " + dtW)
    mHi.draw(newM, showM, pmh, colM, styM, wM, "PMH  " + dtM)
    mLo.draw(newM, showM, pml, colM, styM, wM, "PML  " + dtM)
    sA.run(showA, sessA, colA, "Asie")
    sL.run(showL, sessL, colL, "Londres")
    sN.run(showN, sessN, colN, "NY")

// ════════════════════════════════════════════════════════════════════════════
//  2 · ALIGNEMENT MULTI-TIMEFRAME  +  3 · NIVEAUX (EMA/VWAP/POC)
// ════════════════════════════════════════════════════════════════════════════
gTF = "2 · Timeframes"
tf1 = input.timeframe("1",   "TF 1", group=gTF)
tf2 = input.timeframe("5",   "TF 2", group=gTF)
tf3 = input.timeframe("15",  "TF 3", group=gTF)
tf4 = input.timeframe("60",  "TF 4", group=gTF)
tf5 = input.timeframe("240", "TF 5", group=gTF)
tf6 = input.timeframe("D",   "TF 6", group=gTF)
tf7 = input.timeframe("W",   "TF 7", group=gTF)
tf8 = input.timeframe("M",   "TF 8", group=gTF)

gEMA = "2-3 · EMA"
emaFast = input.int(9,  "EMA rapide", minval=1, group=gEMA)
emaSlow = input.int(21, "EMA lente",  minval=1, group=gEMA)

gLv = "3 · Niveaux de prix"
showEma   = input.bool(true, "EMA 9 / 21", group=gLv)
showVwap  = input.bool(true, "VWAP",       group=gLv)
showPoc   = input.bool(true, "POC du jour", group=gLv)
showNaked = input.bool(true, "naked POC (séances non pris)", group=gLv)
binTicks  = input.int(4, "Taille de bin (ticks)", minval=1, group=gLv, tooltip="Résolution du profil de volume. Plus petit = plus précis mais plus lourd.")
maxStore  = input.int(40, "Nb max de POC mémorisés", minval=1, group=gLv)
lvlExtend = input.int(8, "Longueur de la barre", minval=1, group=gLv)

gMTFd = "2 · Affichage tableau MTF"
posMTF = input.string("Haut gauche", "Position", options=["Haut droite","Haut gauche","Bas droite","Bas gauche","Milieu droite","Milieu gauche"], group=gMTFd)
szMTF  = input.string("Normal", "Taille texte", options=["Petit","Normal","Grand"], group=gMTFd)

gMTFc = "2-3 · Couleurs"
colTrUp  = input.color(color.new(#26a69a, 0), "Haussier", group=gMTFc)
colTrDn  = input.color(color.new(#ef5350, 0), "Baissier", group=gMTFc)
colPoc   = input.color(color.new(#ff9800, 0), "POC du jour", group=gMTFc)
colVwap  = input.color(color.new(#2196f3, 0), "VWAP",        group=gMTFc)
colEma9  = input.color(color.new(#ffeb3b, 0), "EMA 9",       group=gMTFc)
colEma21 = input.color(color.new(#9c27b0, 0), "EMA 21",      group=gMTFc)
colNkUp  = input.color(color.new(#4caf50, 0), "naked POC au-dessus", group=gMTFc)
colNkDn  = input.color(color.new(#f44336, 0), "naked POC en-dessous", group=gMTFc)

// ─────────── États persistants Niveaux ───────────
var vp        = map.new<float, float>()
var pocPrices = array.new<float>()
var pocTested = array.new<bool>()
var gfxLines  = array.new<line>()
var gfxLabels = array.new<label>()

// ─────────── Helpers tableau/Niveaux ───────────
posConst(p) =>
    switch p
        "Haut droite"   => position.top_right
        "Haut gauche"   => position.top_left
        "Bas droite"    => position.bottom_right
        "Bas gauche"    => position.bottom_left
        "Milieu droite" => position.middle_right
        "Milieu gauche" => position.middle_left
        => position.top_right

szConst(s) =>
    switch s
        "Petit"  => size.small
        "Normal" => size.normal
        "Grand"  => size.large
        => size.normal

pocFromMap(map<float, float> m) =>
    float bestP = na
    float bestV = -1.0
    ks = m.keys()
    if array.size(ks) > 0
        for k in ks
            v = m.get(k)
            if v > bestV
                bestV := v
                bestP := k
    bestP

clearGfx() =>
    if array.size(gfxLines) > 0
        for i = 0 to array.size(gfxLines) - 1
            line.delete(array.get(gfxLines, i))
        array.clear(gfxLines)
    if array.size(gfxLabels) > 0
        for i = 0 to array.size(gfxLabels) - 1
            label.delete(array.get(gfxLabels, i))
        array.clear(gfxLabels)

drawLevel(price, txt, col) =>
    if not na(price)
        x2 = bar_index + lvlExtend
        ln = line.new(bar_index - 2, price, x2, price, color=col, width=2)
        lb = label.new(x2, price, txt + " " + str.tostring(price, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=col, textcolor=color.white, size=size.small)
        array.push(gfxLines, ln)
        array.push(gfxLabels, lb)

// ─────────── MTF : tendance + EMA combinés (1 appel/TF = 8 appels) ───────────
trendValue() => close >= open ? 1 : -1
emaValue()   => ta.ema(close, emaFast) >= ta.ema(close, emaSlow) ? 1 : -1
getTE(tf)    => request.security(syminfo.tickerid, tf, [trendValue(), emaValue()], lookahead=barmerge.lookahead_off)

[s1, e1] = getTE(tf1)
[s2, e2] = getTE(tf2)
[s3, e3] = getTE(tf3)
[s4, e4] = getTE(tf4)
[s5, e5] = getTE(tf5)
[s6, e6] = getTE(tf6)
[s7, e7] = getTE(tf7)
[s8, e8] = getTE(tf8)

// ─────────── Niveaux en cours ───────────
ema9v  = ta.ema(close, emaFast)
ema21v = ta.ema(close, emaSlow)
vwapv  = ta.vwap(hlc3)

// ─────────── Profil de volume / POC session ───────────
binSize   = syminfo.mintick * binTicks
dayChange = timeframe.change("D")
if modLvls
    if dayChange and bar_index > 0
        poc = pocFromMap(vp)
        if not na(poc)
            array.push(pocPrices, poc)
            array.push(pocTested, false)
            if array.size(pocPrices) > maxStore
                array.shift(pocPrices)
                array.shift(pocTested)
        vp.clear()
    key = math.round(hlc3 / binSize) * binSize
    vp.put(key, (vp.contains(key) ? vp.get(key) : 0.0) + volume)
    if array.size(pocPrices) > 0
        for i = 0 to array.size(pocPrices) - 1
            if not array.get(pocTested, i)
                p = array.get(pocPrices, i)
                if low <= p and high >= p
                    array.set(pocTested, i, true)

// ─────────── Tableau MTF ───────────
var table dash = table.new(posConst(posMTF), 3, 9, border_width=1, frame_width=1, frame_color=color.new(color.gray, 40))

drawRow(row, lbl, sig, ema) =>
    bull    = sig == 1
    emaBull = ema == 1
    table.cell(dash, 0, row, lbl, text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=szConst(szMTF), text_halign=text.align_left)
    table.cell(dash, 1, row, bull ? "▲" : "▼", text_color=color.white, bgcolor=bull ? colTrUp : colTrDn, text_size=szConst(szMTF), text_halign=text.align_center)
    table.cell(dash, 2, row, emaBull ? "9>21" : "9<21", text_color=color.white, bgcolor=emaBull ? colTrUp : colTrDn, text_size=szConst(szMTF), text_halign=text.align_center)

if modMTF and barstate.islast
    table.cell(dash, 0, 0, "TF",    text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=szConst(szMTF))
    table.cell(dash, 1, 0, "Tend.", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=szConst(szMTF))
    table.cell(dash, 2, 0, "EMA",   text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=szConst(szMTF))
    drawRow(1, "M1",  s1, e1)
    drawRow(2, "M5",  s2, e2)
    drawRow(3, "M15", s3, e3)
    drawRow(4, "H1",  s4, e4)
    drawRow(5, "H4",  s5, e5)
    drawRow(6, "D",   s6, e6)
    drawRow(7, "W",   s7, e7)
    drawRow(8, "MN",  s8, e8)

// ─────────── Dessin des niveaux ───────────
if modLvls and barstate.islast
    clearGfx()
    if showEma
        drawLevel(ema9v,  "EMA9",  colEma9)
        drawLevel(ema21v, "EMA21", colEma21)
    if showVwap
        drawLevel(vwapv, "VWAP", colVwap)
    if showPoc
        drawLevel(pocFromMap(vp), "POC J", colPoc)
    if showNaked and array.size(pocPrices) > 0
        for i = 0 to array.size(pocPrices) - 1
            if not array.get(pocTested, i)
                p = array.get(pocPrices, i)
                drawLevel(p, "nPOC", p >= close ? colNkUp : colNkDn)

// ════════════════════════════════════════════════════════════════════════════
//  4 · BREAKERS / FVG / IFVG / MODÈLE 2022 ICT
// ════════════════════════════════════════════════════════════════════════════
gP    = "4 · Détection breakers"
lenL  = input.int(5, "Force pivots (gauche)", minval=1, group=gP)
lenR  = input.int(5, "Force pivots (droite)", minval=1, group=gP, tooltip="Valeur haute = swings plus majeurs, confirmés R bougies plus tard.")
zBody = input.bool(false, "Zone = corps de bougie (sinon mèches)", group=gP)

gV       = "4 · Affichage breakers"
showBull = input.bool(true, "Breakers haussiers", group=gV, inline="b")
colBull  = input.color(color.new(#26A69A, 80), "", group=gV, inline="b")
showBear = input.bool(true, "Breakers baissiers", group=gV, inline="s")
colBear  = input.color(color.new(#EF5350, 80), "", group=gV, inline="s")
colMit   = input.color(color.new(color.gray, 88), "Couleur si mitigé", group=gV)
bWidth   = input.int(1, "Épaisseur bordure", minval=0, maxval=3, group=gV)
showLbl  = input.bool(true, "Étiquettes", group=gV)
maxBB    = input.int(8, "Nb max par sens", minval=1, maxval=50, group=gV)

gAl    = "4 · Alertes"
alNew  = input.bool(true, "Alerte à la formation", group=gAl)
alTest = input.bool(true, "Alerte au retest", group=gAl)

gF       = "4 · Fair Value Gaps (FVG)"
showFVG  = input.bool(true, "Afficher les FVG", group=gF)
colFvgB  = input.color(color.new(#26A69A, 82), "FVG haussier", group=gF)
colFvgS  = input.color(color.new(#EF5350, 82), "FVG baissier", group=gF)
showFvgLbl = input.bool(true, "Étiquette FVG / IFVG au 50 %", group=gF)
maxFVG   = input.int(15, "Nb max de FVG / IFVG", minval=1, maxval=80, group=gF)

gIf      = "4 · FVG inversés (IFVG)"
showIFVG = input.bool(true, "Afficher les IFVG", group=gIf)
colIfvgB = input.color(color.new(#2962FF, 72), "IFVG haussier (support)", group=gIf)
colIfvgS = input.color(color.new(#FF6D00, 72), "IFVG baissier (résistance)", group=gIf)

gZ            = "4 · Style des zones"
showBorderBB  = input.bool(true, "Contour des breakers", group=gZ)
showBorderFVG = input.bool(true, "Contour des FVG / IFVG", group=gZ)
fillTransp    = input.int(85, "Transparence du fond", minval=0, maxval=100, group=gZ, tooltip="0 = opaque, 100 = invisible.")

gM22     = "4 · Modèle 2022 ICT"
show2022 = input.bool(true, "Activer (prise de liquidité + MSS)", group=gM22)
col22    = input.color(color.new(#FFD700, 0), "Couleur des marqueurs", group=gM22)
maxM22   = input.int(10, "Nb max de signaux", minval=1, maxval=50, group=gM22)

effBWbb  = showBorderBB ? bWidth : 0
effBWfvg = showBorderFVG ? bWidth : 0

// ─────────── Types breakers ───────────
type BB
    box   bx
    label lb
    bool  bull
    float top
    float bot
    bool  hit  = false
    bool  dead = false

var array<BB> bbs = array.new<BB>()

type FVG
    box   bx
    label lb
    int   x1
    bool  bull
    float top
    float bot
    bool  inv  = false
    bool  dead = false

var array<FVG> fvgs = array.new<FVG>()

type M22
    label dot
    line  mss
    label mlb

var array<M22> m22s = array.new<M22>()

// ─────────── Fonctions breakers ───────────
trim(bool bull) =>
    cnt = 0
    if array.size(bbs) > 0
        for i = 0 to array.size(bbs) - 1
            if array.get(bbs, i).bull == bull
                cnt += 1
    while cnt > maxBB
        idx = -1
        if array.size(bbs) > 0
            for i = 0 to array.size(bbs) - 1
                if array.get(bbs, i).bull == bull
                    idx := i
                    break
        if idx >= 0
            old = array.remove(bbs, idx)
            box.delete(old.bx)
            label.delete(old.lb)
            cnt := cnt - 1
        else
            cnt := 0

addBreaker(bool bull, int x1, float top, float bot) =>
    col   = bull ? colBull : colBear
    bcol  = color.new(col, 0)
    bx    = box.new(x1, top, bar_index + 1, bot, border_color=bcol, border_width=effBWbb, border_style=line.style_dashed, bgcolor=color.new(col, fillTransp))
    label lb = na
    if showLbl
        lb := label.new(x1, bull ? top : bot, bull ? "Breaker ▲" : "Breaker ▼", style=label.style_none, textcolor=bcol, size=size.tiny)
    array.push(bbs, BB.new(bx=bx, lb=lb, bull=bull, top=top, bot=bot))
    trim(bull)
    if alNew
        alert(bull ? "Breaker haussier formé" : "Breaker baissier formé", alert.freq_once_per_bar)

trimFvg() =>
    while array.size(fvgs) > maxFVG
        old = array.shift(fvgs)
        if not na(old.bx)
            box.delete(old.bx)
        if not na(old.lb)
            label.delete(old.lb)

add2022(bool bull, int sweepBar, float sweepP, float mssLvl, int mssBar) =>
    dot = label.new(sweepBar, sweepP, "", style=label.style_circle, color=col22, size=size.tiny, yloc=bull ? yloc.belowbar : yloc.abovebar)
    mss = line.new(mssBar, mssLvl, bar_index, mssLvl, color=col22, style=line.style_dotted, width=1)
    mlb = label.new(bar_index, mssLvl, "MSS", style=label.style_none, textcolor=col22, size=size.tiny)
    array.push(m22s, M22.new(dot=dot, mss=mss, mlb=mlb))
    while array.size(m22s) > maxM22
        old = array.shift(m22s)
        label.delete(old.dot)
        line.delete(old.mss)
        label.delete(old.mlb)

// ─────────── Pivots ───────────
ph = ta.pivothigh(lenL, lenR)
pl = ta.pivotlow(lenL, lenR)

var float hi1p  = na
var int   hi1b  = na
var float hi1t  = na
var float hi1bt = na
var float hi2p  = na
var int   hi2b  = na
var float lo1p  = na
var int   lo1b  = na
var float lo1t  = na
var float lo1bt = na
var float lo2p  = na
var int   lo2b  = na

var bool  bullArm = false
var float bullLvl = na
var float bullTop = na
var float bullBot = na
var int   bullBar = na
var int   bullArmBar = na
var bool  bearArm = false
var float bearLvl = na
var float bearTop = na
var float bearBot = na
var int   bearBar = na
var int   bearArmBar = na

var float bullSweepP = na
var int   bullSweepB = na
var float bearSweepP = na
var int   bearSweepB = na

if modBB
    if not na(ph)
        hi2p := hi1p
        hi2b := hi1b
        hi1p := ph
        hi1b := bar_index - lenR
        h_ = high[lenR]
        l_ = low[lenR]
        o_ = open[lenR]
        c_ = close[lenR]
        hi1t  := zBody ? math.max(o_, c_) : h_
        hi1bt := zBody ? math.min(o_, c_) : l_
        if (showBear or show2022) and not na(hi2p) and hi1p > hi2p and not na(lo1p) and lo1b > hi2b and lo1b < hi1b
            bearArm    := true
            bearLvl    := lo1p
            bearTop    := lo1t
            bearBot    := lo1bt
            bearBar    := lo1b
            bearArmBar := bar_index
            bearSweepP := hi1p
            bearSweepB := hi1b

    if not na(pl)
        lo2p := lo1p
        lo2b := lo1b
        lo1p := pl
        lo1b := bar_index - lenR
        h_ = high[lenR]
        l_ = low[lenR]
        o_ = open[lenR]
        c_ = close[lenR]
        lo1t  := zBody ? math.max(o_, c_) : h_
        lo1bt := zBody ? math.min(o_, c_) : l_
        if (showBull or show2022) and not na(lo2p) and lo1p < lo2p and not na(hi1p) and hi1b > lo2b and hi1b < lo1b
            bullArm    := true
            bullLvl    := hi1p
            bullTop    := hi1t
            bullBot    := hi1bt
            bullBar    := hi1b
            bullArmBar := bar_index
            bullSweepP := lo1p
            bullSweepB := lo1b

    // Confirmations BOS
    if bullArm and close > bullLvl
        if showBull
            addBreaker(true, bullBar, bullTop, bullBot)
        if show2022
            add2022(true, bullSweepB, bullSweepP, bullLvl, bullBar)
        bullArm := false
    else if bullArm and bar_index - bullArmBar > 250
        bullArm := false

    if bearArm and close < bearLvl
        if showBear
            addBreaker(false, bearBar, bearTop, bearBot)
        if show2022
            add2022(false, bearSweepB, bearSweepP, bearLvl, bearBar)
        bearArm := false
    else if bearArm and bar_index - bearArmBar > 250
        bearArm := false

    // Maintenance des zones breakers
    if array.size(bbs) > 0
        for i = 0 to array.size(bbs) - 1
            b = array.get(bbs, i)
            if not b.dead
                box.set_right(b.bx, bar_index + 1)
                if not na(b.lb)
                    label.set_x(b.lb, bar_index + 1)
                inZone = high >= b.bot and low <= b.top
                if inZone and not b.hit
                    b.hit := true
                    if alTest
                        alert(b.bull ? "Retest breaker haussier" : "Retest breaker baissier", alert.freq_once_per_bar)
                invalid = b.bull ? close < b.bot : close > b.top
                if invalid
                    b.dead := true
                    box.set_bgcolor(b.bx, color.new(colMit, fillTransp))
                    box.set_border_color(b.bx, color.new(colMit, 40))
                    box.set_right(b.bx, bar_index)

    // FVG / IFVG
    bullFvg  = low > high[2]
    bearFvg  = high < low[2]
    trackFvg = showFVG or showIFVG

    if trackFvg and bullFvg
        box bx = na
        label lb = na
        if showFVG
            bx := box.new(bar_index - 2, low, bar_index + 1, high[2], border_color=color.new(colFvgB, 0), border_width=effBWfvg, bgcolor=color.new(colFvgB, fillTransp))
            if showFvgLbl
                lb := label.new(bar_index - 2, math.avg(low, high[2]), "FVG", style=label.style_none, textcolor=color.new(colFvgB, 0), size=size.tiny, textalign=text.align_left)
        array.push(fvgs, FVG.new(bx=bx, lb=lb, x1=bar_index - 2, bull=true, top=low, bot=high[2]))
        trimFvg()

    if trackFvg and bearFvg
        box bx = na
        label lb = na
        if showFVG
            bx := box.new(bar_index - 2, low[2], bar_index + 1, high, border_color=color.new(colFvgS, 0), border_width=effBWfvg, bgcolor=color.new(colFvgS, fillTransp))
            if showFvgLbl
                lb := label.new(bar_index - 2, math.avg(low[2], high), "FVG", style=label.style_none, textcolor=color.new(colFvgS, 0), size=size.tiny, textalign=text.align_left)
        array.push(fvgs, FVG.new(bx=bx, lb=lb, x1=bar_index - 2, bull=false, top=low[2], bot=high))
        trimFvg()

    if array.size(fvgs) > 0
        for i = 0 to array.size(fvgs) - 1
            f = array.get(fvgs, i)
            if not f.dead
                if not na(f.bx)
                    box.set_right(f.bx, bar_index + 1)
                if not na(f.lb)
                    label.set_x(f.lb, bar_index + 1)
                if not f.inv
                    flip = f.bull ? close < f.bot : close > f.top
                    if flip
                        if showIFVG
                            f.inv  := true
                            f.bull := not f.bull
                            nc  = f.bull ? colIfvgB : colIfvgS
                            mid = math.avg(f.top, f.bot)
                            if na(f.bx)
                                f.bx := box.new(f.x1, f.top, bar_index + 1, f.bot, border_color=color.new(nc, 0), border_width=effBWfvg, bgcolor=color.new(nc, fillTransp))
                            else
                                box.set_bgcolor(f.bx, color.new(nc, fillTransp))
                                box.set_border_color(f.bx, color.new(nc, 0))
                            if showFvgLbl
                                if na(f.lb)
                                    f.lb := label.new(f.x1, mid, "IFVG", style=label.style_none, textcolor=color.new(nc, 0), size=size.tiny, textalign=text.align_left)
                                else
                                    label.set_text(f.lb, "IFVG")
                                    label.set_textcolor(f.lb, color.new(nc, 0))
                            if alNew
                                alert(f.bull ? "IFVG haussier formé" : "IFVG baissier formé", alert.freq_once_per_bar)
                        else
                            f.dead := true
                            if not na(f.bx)
                                box.delete(f.bx)
                            if not na(f.lb)
                                label.delete(f.lb)
                else
                    gone = f.bull ? close < f.bot : close > f.top
                    if gone
                        f.dead := true
                        if not na(f.bx)
                            box.delete(f.bx)
                        if not na(f.lb)
                            label.delete(f.lb)

// ════════════════════════════════════════════════════════════════════════════
//  5 · DASHBOARD INTERMARKET  (biais, corrélation, Risk-On/Off, SMT)
// ════════════════════════════════════════════════════════════════════════════
gISym = "5 · Symboles Intermarket"
symDXY = input.symbol("TVC:DXY",        "Dollar Index (DXY)", group=gISym)
symVIX = input.symbol("TVC:VIX",        "VIX",                group=gISym)
symES  = input.symbol("CME_MINI:ES1!",  "S&P 500 (ES)",       group=gISym)
symNQ  = input.symbol("CME_MINI:NQ1!",  "Nasdaq (NQ)",        group=gISym)
symYM  = input.symbol("CBOT_MINI:YM1!", "Dow (YM)",           group=gISym)
symGC  = input.symbol("COMEX:GC1!",     "Or (GC)",            group=gISym)
sym10Y = input.symbol("TVC:US10Y",      "Rendement US 10Y",   group=gISym)

gICalc   = "5 · Calcul Intermarket"
biasInter = input.string("Daily Open", "Référence du biais", options=["Daily Open","EMA"], group=gICalc)
emaLenI   = input.int(50, "Longueur EMA",         minval=1, group=gICalc)
corrLen   = input.int(50, "Lookback corrélation", minval=5, group=gICalc)

gISMT   = "5 · SMT Divergence"
showSMT = input.bool(true, "Détecter SMT divergence",  group=gISMT)
smtA    = input.symbol("CME_MINI:ES1!", "SMT symbole A", group=gISMT)
smtB    = input.symbol("CME_MINI:NQ1!", "SMT symbole B", group=gISMT)
smtLen  = input.int(20, "Lookback swing SMT", minval=3, group=gISMT)

gITbl   = "5 · Tableau Intermarket"
posInter = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gITbl)
szInter  = input.string("Normal", "Taille", options=["Tiny","Small","Normal","Large"], group=gITbl)
tintBg   = input.bool(true, "Teinter le fond si alignement Risk-On/Off total", group=gITbl)

// Biais + corrélation : [close, ema] (TF chart, 1 appel) + daily open (1 appel) = 2/symbole
f_metrics(sym) =>
    [c, ema] = request.security(sym, timeframe.period, [close, ta.ema(close, emaLenI)], lookahead=barmerge.lookahead_off)
    dop  = request.security(sym, "D", open, lookahead=barmerge.lookahead_off)
    ref  = biasInter == "Daily Open" ? dop : ema
    bias = c > ref ? 1 : c < ref ? -1 : 0
    corr = ta.correlation(close, c, corrLen)
    [bias, corr]

f_biasTxt(b) => b == 1 ? "▲ Haussier" : b == -1 ? "▼ Baissier" : "– Plat"
f_biasCol(b) => b == 1 ? color.new(color.green, 65) : b == -1 ? color.new(color.red, 65) : color.new(color.gray, 65)

[bDXY, cDXY] = f_metrics(symDXY)
[bVIX, cVIX] = f_metrics(symVIX)
[bES,  cES ] = f_metrics(symES)
[bNQ,  cNQ ] = f_metrics(symNQ)
[bYM,  cYM ] = f_metrics(symYM)
[bGC,  cGC ] = f_metrics(symGC)
[b10Y, c10Y] = f_metrics(sym10Y)

fullRiskOn  = bES == 1  and bNQ == 1  and bYM == 1  and bVIX == -1
fullRiskOff = bES == -1 and bNQ == -1 and bYM == -1 and bVIX == 1
regimeTxtI = fullRiskOn ? "RISK-ON" : fullRiskOff ? "RISK-OFF" : "Mixte / pas d'alignement"
regimeColI = fullRiskOn ? color.new(color.green, 40) : fullRiskOff ? color.new(color.red, 40) : color.new(color.orange, 50)

bgcolor(modInter and tintBg and fullRiskOn ? color.new(color.green, 92) : modInter and tintBg and fullRiskOff ? color.new(color.red, 92) : na)

// SMT : [high, low] par symbole = 2 appels
[aH, aL] = request.security(smtA, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)
[bH, bL] = request.security(smtB, timeframe.period, [high, low], lookahead=barmerge.lookahead_off)

aNewHigh = aH >= ta.highest(aH, smtLen)[1]
bNewHigh = bH >= ta.highest(bH, smtLen)[1]
aNewLow  = aL <= ta.lowest(aL,  smtLen)[1]
bNewLow  = bL <= ta.lowest(bL,  smtLen)[1]

bearSMT = showSMT and (aNewHigh != bNewHigh)
bullSMT = showSMT and (aNewLow  != bNewLow)
smtTxt  = not showSMT ? "désactivé" : bearSMT ? "▼ SMT baissier" : bullSMT ? "▲ SMT haussier" : "aligné"
smtCol  = not showSMT ? color.new(color.gray, 65) : bearSMT ? color.new(color.red, 50) : bullSMT ? color.new(color.green, 50) : color.new(color.gray, 65)

posI = posInter == "Top Right" ? position.top_right : posInter == "Top Left" ? position.top_left : posInter == "Bottom Right" ? position.bottom_right : position.bottom_left
szI  = szInter == "Tiny" ? size.tiny : szInter == "Small" ? size.small : szInter == "Large" ? size.large : size.normal

var table tInter = table.new(posI, 3, 11, border_width=1, border_color=color.new(color.gray, 50))

f_rowI(_t, _r, _name, _b, _c) =>
    table.cell(_t, 0, _r, _name,         text_color=color.white, text_size=szI, bgcolor=color.new(color.black, 30), text_halign=text.align_left)
    table.cell(_t, 1, _r, f_biasTxt(_b), text_color=color.white, text_size=szI, bgcolor=f_biasCol(_b))
    table.cell(_t, 2, _r, na(_c) ? "n/a" : str.tostring(_c, "#.00"), text_color=color.white, text_size=szI, bgcolor=color.new(color.black, 30))

if modInter and barstate.islast
    table.cell(tInter, 0, 0, "Actif",      text_color=color.white, text_size=szI, bgcolor=color.new(color.blue, 20))
    table.cell(tInter, 1, 0, "Biais jour", text_color=color.white, text_size=szI, bgcolor=color.new(color.blue, 20))
    table.cell(tInter, 2, 0, "Corr.",      text_color=color.white, text_size=szI, bgcolor=color.new(color.blue, 20))
    f_rowI(tInter, 1, "DXY", bDXY, cDXY)
    f_rowI(tInter, 2, "VIX", bVIX, cVIX)
    f_rowI(tInter, 3, "ES",  bES,  cES)
    f_rowI(tInter, 4, "NQ",  bNQ,  cNQ)
    f_rowI(tInter, 5, "YM",  bYM,  cYM)
    f_rowI(tInter, 6, "GC",  bGC,  cGC)
    f_rowI(tInter, 7, "10Y", b10Y, c10Y)
    table.cell(tInter, 0, 8, "SMT",   text_color=color.white, text_size=szI, bgcolor=color.new(color.black, 30), text_halign=text.align_left)
    table.cell(tInter, 1, 8, smtTxt,  text_color=color.white, text_size=szI, bgcolor=smtCol)
    table.cell(tInter, 2, 8, str.tostring(smtLen), text_color=color.white, text_size=szI, bgcolor=color.new(color.black, 30))
    table.cell(tInter, 0, 9, "Régime", text_color=color.white, text_size=szI, bgcolor=color.new(color.black, 30), text_halign=text.align_left)
    table.cell(tInter, 1, 9, regimeTxtI, text_color=color.white, text_size=szI, bgcolor=regimeColI)
    table.cell(tInter, 2, 9, "", bgcolor=color.new(color.black, 30))
    table.cell(tInter, 0, 10, "Corr. = corrélation glissante avec le symbole du graphique", text_color=color.new(color.white, 30), text_size=size.tiny, bgcolor=color.new(color.black, 30))
    table.merge_cells(tInter, 0, 10, 2, 10)

alertcondition(bearSMT,     "SMT baissier",   "Divergence SMT baissière détectée")
alertcondition(bullSMT,     "SMT haussier",   "Divergence SMT haussière détectée")
alertcondition(fullRiskOn,  "Risk-On total",  "Indices haussiers + VIX baissier")
alertcondition(fullRiskOff, "Risk-Off total", "Indices baissiers + VIX haussier")

// ════════════════════════════════════════════════════════════════════════════
//  6 · DASHBOARD FX RISK-ON / RISK-OFF  (9 paires, biais Daily Open — 9 appels)
// ════════════════════════════════════════════════════════════════════════════
gFXd      = "6 · Données FX"
brokerPfx = input.string("OANDA:", "Préfixe broker (OANDA:, FX:, FX_IDC:)", group=gFXd)

gFXv      = "6 · Verdict FX"
fxThresh  = input.int(3, "Seuil de score Risk-On/Off", minval=1, group=gFXv)

gFXdisp = "6 · Affichage FX"
posFX = input.string("Bottom Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gFXdisp)
szFX  = input.string("Small", "Taille", options=["Tiny","Small","Normal","Large"], group=gFXdisp)

// Direction Daily Open d'une paire : +1 / -1 / 0  (1 appel security)
f_dir(pair) =>
    sym = brokerPfx + pair
    dv  = request.security(sym, "D", close - open, lookahead=barmerge.lookahead_off)
    dv > 0 ? 1 : dv < 0 ? -1 : 0

// [direction, signal risque, contribution score]
f_pair(pair, riskChar) =>
    d       = f_dir(pair)
    sig     = riskChar == 0 ? 0 : d * (riskChar > 0 ? 1 : -1)
    contrib = d * riskChar
    [d, sig, contrib]

[dEU, sEU, kEU] = f_pair("EURUSD",  1)
[dGU, sGU, kGU] = f_pair("GBPUSD",  1)
[dAU, sAU, kAU] = f_pair("AUDUSD",  2)
[dNU, sNU, kNU] = f_pair("NZDUSD",  2)
[dUJ, sUJ, kUJ] = f_pair("USDJPY",  0)
[dUF, sUF, kUF] = f_pair("USDCHF",  0)
[dUC, sUC, kUC] = f_pair("USDCAD", -2)
[dAJ, sAJ, kAJ] = f_pair("AUDJPY",  2)
[dNJ, sNJ, kNJ] = f_pair("NZDJPY",  2)

fxScore   = kEU + kGU + kAU + kNU + kUJ + kUF + kUC + kAJ + kNJ
regimeTxtF = fxScore >=  fxThresh ? "RISK-ON" : fxScore <= -fxThresh ? "RISK-OFF" : "MIXTE / neutre"
regimeColF = fxScore >=  fxThresh ? color.new(color.green, 25) : fxScore <= -fxThresh ? color.new(color.red, 25) : color.new(color.orange, 35)

posF = posFX == "Top Right" ? position.top_right : posFX == "Top Left" ? position.top_left : posFX == "Bottom Right" ? position.bottom_right : position.bottom_left
szF  = szFX == "Tiny" ? size.tiny : szFX == "Small" ? size.small : szFX == "Large" ? size.large : size.normal

f_dirTxt(d) => d == 1 ? "▲" : d == -1 ? "▼" : "–"
f_dirCol(d) => d == 1 ? color.new(color.green, 60) : d == -1 ? color.new(color.red, 60) : color.new(color.gray, 60)
f_sigTxt(s) => s == 1 ? "Risk-On" : s == -1 ? "Risk-Off" : "Neutre"
f_sigCol(s) => s == 1 ? color.new(color.green, 35) : s == -1 ? color.new(color.red, 35) : color.new(color.gray, 55)

var table tFX = table.new(posF, 3, 14, border_width=1, border_color=color.new(color.gray, 60))

f_prow(_t, _r, _name, _d, _s) =>
    table.cell(_t, 0, _r, _name,        text_color=color.white, text_size=szF, bgcolor=color.new(color.black, 25), text_halign=text.align_left)
    table.cell(_t, 1, _r, f_dirTxt(_d), text_color=color.white, text_size=szF, bgcolor=f_dirCol(_d))
    table.cell(_t, 2, _r, f_sigTxt(_s), text_color=color.white, text_size=szF, bgcolor=f_sigCol(_s))

f_section(_t, _r, _label) =>
    table.cell(_t, 0, _r, _label, text_color=color.white, text_size=szF, bgcolor=color.new(color.blue, 30), text_halign=text.align_left)
    table.merge_cells(_t, 0, _r, 2, _r)

if modFX and barstate.islast
    table.cell(tFX, 0, 0, "Paire",  text_color=color.white, text_size=szF, bgcolor=color.new(color.blue, 10))
    table.cell(tFX, 1, 0, "Sens",   text_color=color.white, text_size=szF, bgcolor=color.new(color.blue, 10))
    table.cell(tFX, 2, 0, "Signal", text_color=color.white, text_size=szF, bgcolor=color.new(color.blue, 10))
    f_section(tFX, 1, "— MAJEURES —")
    f_prow(tFX, 2, "EUR/USD", dEU, sEU)
    f_prow(tFX, 3, "GBP/USD", dGU, sGU)
    f_prow(tFX, 4, "AUD/USD", dAU, sAU)
    f_prow(tFX, 5, "NZD/USD", dNU, sNU)
    f_prow(tFX, 6, "USD/JPY", dUJ, sUJ)
    f_prow(tFX, 7, "USD/CHF", dUF, sUF)
    f_prow(tFX, 8, "USD/CAD", dUC, sUC)
    f_section(tFX, 9, "— BAROMÈTRES —")
    f_prow(tFX, 10, "AUD/JPY", dAJ, sAJ)
    f_prow(tFX, 11, "NZD/JPY", dNJ, sNJ)
    table.cell(tFX, 0, 12, "Sentiment", text_color=color.white, text_size=szF, bgcolor=color.new(color.black, 10), text_halign=text.align_left)
    table.cell(tFX, 1, 12, str.tostring(fxScore), text_color=color.white, text_size=szF, bgcolor=color.new(color.black, 10))
    table.cell(tFX, 2, 12, regimeTxtF, text_color=color.white, text_size=szF, bgcolor=regimeColF)
    table.cell(tFX, 0, 13, "AUD/JPY & NZD/JPY = baromètres de risque", text_color=color.new(color.white, 25), text_size=size.tiny, bgcolor=color.new(color.black, 25))
    table.merge_cells(tFX, 0, 13, 2, 13)

alertcondition(fxScore >=  fxThresh, "FX Risk-On",  "Sentiment FX global : RISK-ON")
alertcondition(fxScore <= -fxThresh, "FX Risk-Off", "Sentiment FX global : RISK-OFF")
````

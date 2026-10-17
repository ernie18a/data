# FVG MTF + Structure Lines

- url: https://www.tradingview.com/script/uOo2xb4v/
- type: indicator
- pine_id: PUB;56fdd4c30eba49368937a44ee671559e
- version: 2.0

## Description

FVG MTF + Structure Lines
Cet indicateur combine deux concepts du Smart Money Concepts (SMC) : la détection de structure de marché et les Fair Value Gaps (FVGs) sur trois unités de temps supérieures.

Structure de Marché
L'indicateur surveille en permanence deux niveaux de structure :
Structure interne (5 barres) — détecte les retournements à court terme. Chaque fois que le prix casse au-dessus d'un pivot haut ou en dessous d'un pivot bas récent, une ligne pointillée est tracée au niveau du pivot cassé. C'est le premier signe d'un changement de direction.
Structure swing (50 barres par défaut, paramétrable) — détecte les retournements majeurs sur un horizon plus large. Fonctionne exactement de la même façon mais exige une confirmation sur plus de barres. Les lignes sont en trait plein.

Fair Value Gaps (FVGs)
Un FVG est un déséquilibre laissé par une bougie impulsive : la bougie centrale ne chevauche ni la précédente ni la suivante, créant un "vide" de prix que le marché a tendance à revenir combler.
L'indicateur détecte ces zones sur trois timeframes supérieurs simultanément, chacun avec ses propres couleurs :

Daily — vert/rouge (déséquilibres journaliers)
Weekly — bleu/orange (déséquilibres hebdomadaires)
Monthly — violet/jaune (déséquilibres mensuels)

Chaque FVG est affiché sous forme de rectangle coloré qui s'étend vers la droite au fil des barres. Dès que le prix revient dans la zone (le bas pour un FVG haussier, le haut pour un baissier), la zone est considérée comme mitigée : le rectangle disparaît automatiquement.
L'indicateur ne s'affiche que si l'unité de temps du graphique est inférieure au timeframe demandé — inutile d'afficher des FVGs Daily sur un graphique Weekly.

## Source Code

````pine
// Based on Smart Money Concepts [LuxAlgo] — CC BY-NC-SA 4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Adapted : FVG Daily/Weekly/Monthly + Structure Lines (no labels)
//@version=5
indicator('FVG MTF + Structure Lines', 'FVG MTF + Str', overlay=true, max_boxes_count=500, max_lines_count=500)

//─── CONSTANTS ─────────────────────────────────────────────────────────────────
BULLISH     = 1
BEARISH     = -1
BULLISH_LEG = 1
BEARISH_LEG = 0
HISTORICAL  = 'Historical'
PRESENT     = 'Present'

//─── INPUTS ────────────────────────────────────────────────────────────────────
modeInput  = input.string(HISTORICAL, 'Mode',
             options  = [HISTORICAL, PRESENT],
             tooltip  = 'Historical : conserve toutes les structures passées\nPresent : affiche uniquement la structure en cours')

// ── Structure de Marché ──
grpSTR     = 'Structure de Marché'
showIntStr = input.bool  (true,             'Interne (tirets)',  group=grpSTR, inline='i',
             tooltip='Lignes de structure interne détectées sur 5 barres (trait pointillé)')
intBullCol = input.color (#089981,          '',                  group=grpSTR, inline='i')
intBearCol = input.color (#F23645,          '',                  group=grpSTR, inline='i')
showSwgStr = input.bool  (true,             'Swing  (plein)',    group=grpSTR, inline='s',
             tooltip='Lignes de structure swing (trait plein)')
swgBullCol = input.color (#089981,          '',                  group=grpSTR, inline='s')
swgBearCol = input.color (#F23645,          '',                  group=grpSTR, inline='s')
swgsLength = input.int   (50,               'Longueur Pivot',    group=grpSTR, minval=10,
             tooltip='Nombre de barres utilisées pour confirmer un pivot swing')

// ── FVG Daily ──
grpD         = 'FVG Daily'
showDFVG     = input.bool  (true,                          'Afficher',      group=grpD)
dBullBG      = input.color (color.new(#00ff68, 70),       '↑ Fond',        group=grpD, inline='dbg',   tooltip='Couleur et opacité du fond haussier / baissier')
dBearBG      = input.color (color.new(#ff0008, 70),       '↓ Fond',        group=grpD, inline='dbg')
dBullBord    = input.color (color.new(#00ff68, 0),        '↑ Bordure',     group=grpD, inline='dbord', tooltip='Couleur et opacité de la bordure haussière / baissière')
dBearBord    = input.color (color.new(#ff0008, 0),        '↓ Bordure',     group=grpD, inline='dbord')
dBordWidth   = input.int   (1,                             'Épaisseur',     group=grpD, minval=1, maxval=4, inline='dbordw')
dBordStyle   = input.string('Plein',                      'Style',         group=grpD, options=['Plein','Tirets','Pointillés'], inline='dbordw')

// ── FVG Weekly ──
grpW         = 'FVG Weekly'
showWFVG     = input.bool  (true,                          'Afficher',      group=grpW)
wBullBG      = input.color (color.new(#2157f3, 70),       '↑ Fond',        group=grpW, inline='wbg',   tooltip='Couleur et opacité du fond haussier / baissier')
wBearBG      = input.color (color.new(#ff8c00, 70),       '↓ Fond',        group=grpW, inline='wbg')
wBullBord    = input.color (color.new(#2157f3, 0),        '↑ Bordure',     group=grpW, inline='wbord', tooltip='Couleur et opacité de la bordure haussière / baissière')
wBearBord    = input.color (color.new(#ff8c00, 0),        '↓ Bordure',     group=grpW, inline='wbord')
wBordWidth   = input.int   (1,                             'Épaisseur',     group=grpW, minval=1, maxval=4, inline='wbordw')
wBordStyle   = input.string('Plein',                      'Style',         group=grpW, options=['Plein','Tirets','Pointillés'], inline='wbordw')

// ── FVG Monthly ──
grpM         = 'FVG Monthly'
showMFVG     = input.bool  (true,                          'Afficher',      group=grpM)
mBullBG      = input.color (color.new(#9c27b0, 70),       '↑ Fond',        group=grpM, inline='mbg',   tooltip='Couleur et opacité du fond haussier / baissier')
mBearBG      = input.color (color.new(#ffeb3b, 70),       '↓ Fond',        group=grpM, inline='mbg')
mBullBord    = input.color (color.new(#9c27b0, 0),        '↑ Bordure',     group=grpM, inline='mbord', tooltip='Couleur et opacité de la bordure haussière / baissière')
mBearBord    = input.color (color.new(#ffeb3b, 0),        '↓ Bordure',     group=grpM, inline='mbord')
mBordWidth   = input.int   (1,                             'Épaisseur',     group=grpM, minval=1, maxval=4, inline='mbordw')
mBordStyle   = input.string('Plein',                      'Style',         group=grpM, options=['Plein','Tirets','Pointillés'], inline='mbordw')

//─── TYPES ─────────────────────────────────────────────────────────────────────
type pivot
    float currentLevel = na
    float lastLevel    = na
    bool  crossed      = false
    int   barTime      = na
    int   barIndex     = na

type sTrend
    int bias = 0

type fvgZone
    float top
    float bottom
    int   bias
    box   b_ox

//─── VARIABLES ─────────────────────────────────────────────────────────────────
var pivot  swingH   = pivot.new()
var pivot  swingL   = pivot.new()
var pivot  intH     = pivot.new()
var pivot  intL     = pivot.new()
var sTrend swgTrend = sTrend.new()
var sTrend intTrend = sTrend.new()

var array<fvgZone> dFVGs = array.new<fvgZone>()
var array<fvgZone> wFVGs = array.new<fvgZone>()
var array<fvgZone> mFVGs = array.new<fvgZone>()

//─── HELPERS ───────────────────────────────────────────────────────────────────
styleToLine(string s) =>
    s == 'Tirets'      ? line.style_dashed  :
     s == 'Pointillés' ? line.style_dotted  :
     line.style_solid

//─── STRUCTURE ─────────────────────────────────────────────────────────────────

leg(int size) =>
    var int l = 0
    if high[size] > ta.highest(size)
        l := BEARISH_LEG
    else if low[size] < ta.lowest(size)
        l := BULLISH_LEG
    l

updatePivots(int size, bool internal) =>
    cl = leg(size)
    if ta.change(cl) != 0
        if ta.change(cl) == 1
            p               = internal ? intL : swingL
            p.lastLevel    := p.currentLevel
            p.currentLevel := low[size]
            p.crossed      := false
            p.barTime      := time[size]
            p.barIndex     := bar_index[size]
        else
            p               = internal ? intH : swingH
            p.lastLevel    := p.currentLevel
            p.currentLevel := high[size]
            p.crossed      := false
            p.barTime      := time[size]
            p.barIndex     := bar_index[size]

detectAndDrawStr(bool internal) =>
    ph     = internal ? intH     : swingH
    pl     = internal ? intL     : swingL
    tr     = internal ? intTrend : swgTrend
    bCol   = internal ? intBullCol : swgBullCol
    rCol   = internal ? intBearCol : swgBearCol
    lStyle = internal ? line.style_dashed : line.style_solid
    show   = internal ? showIntStr : showSwgStr
    condH  = internal ? intH.currentLevel != swingH.currentLevel : true
    condL  = internal ? intL.currentLevel != swingL.currentLevel : true

    var line lH = line.new(na, na, na, na, xloc=xloc.bar_time)
    var line lL = line.new(na, na, na, na, xloc=xloc.bar_time)

    if ta.crossover(close, ph.currentLevel) and not ph.crossed and condH
        ph.crossed := true
        tr.bias    := BULLISH
        if show
            if modeInput == PRESENT
                lH.delete()
            lH := line.new(
                 chart.point.new(ph.barTime, na, ph.currentLevel),
                 chart.point.new(time, na, ph.currentLevel),
                 xloc.bar_time, color=bCol, style=lStyle)

    if ta.crossunder(close, pl.currentLevel) and not pl.crossed and condL
        pl.crossed := true
        tr.bias    := BEARISH
        if show
            if modeInput == PRESENT
                lL.delete()
            lL := line.new(
                 chart.point.new(pl.barTime, na, pl.currentLevel),
                 chart.point.new(time, na, pl.currentLevel),
                 xloc.bar_time, color=rCol, style=lStyle)

//─── FVG ───────────────────────────────────────────────────────────────────────

purgeFVGs(array<fvgZone> zones) =>
    i = zones.size() - 1
    while i >= 0
        z = zones.get(i)
        mitigated = ((z.bias == BULLISH and low  <= z.bottom) or
                     (z.bias == BEARISH and high >= z.top))
        if mitigated
            z.b_ox.delete()
            zones.remove(i)
        i -= 1

detectFVGs(string tf, bool show,
     color bBG,    color rBG,
     color bBord,  color rBord,
     int   bordWidth, string bordStyle,
     array<fvgZone> zones) =>

    [c1, t1, h0, l0, t0, h2, l2] = request.security(
         syminfo.tickerid, tf,
         [close[1], time[1], high, low, time, high[2], low[2]],
         lookahead=barmerge.lookahead_on)

    if show and timeframe.in_seconds() < timeframe.in_seconds(tf)
        if timeframe.change(tf)
            // FVG haussier : gap entre le haut de la bougie -2 et le bas de la bougie 0
            if l0 > h2 and c1 > h2
                b = box.new(
                     chart.point.new(t1, na, l0),
                     chart.point.new(t0, na, h2),
                     xloc         = xloc.bar_time,
                     bgcolor      = bBG,
                     border_color = bBord,
                     border_width = bordWidth,
                     border_style = styleToLine(bordStyle))
                zones.push(fvgZone.new(l0, h2, BULLISH, b))

            // FVG baissier : gap entre le bas de la bougie -2 et le haut de la bougie 0
            if h0 < l2 and c1 < l2
                b = box.new(
                     chart.point.new(t1, na, l2),
                     chart.point.new(t0, na, h0),
                     xloc         = xloc.bar_time,
                     bgcolor      = rBG,
                     border_color = rBord,
                     border_width = bordWidth,
                     border_style = styleToLine(bordStyle))
                zones.push(fvgZone.new(l2, h0, BEARISH, b))

        // Purger les zones mitigées et étendre les zones actives
        purgeFVGs(zones)
        for z in zones
            z.b_ox.set_right(time)

//─── MAIN ──────────────────────────────────────────────────────────────────────

// Structure interne (5 barres) et swing
updatePivots(5, true)
updatePivots(swgsLength, false)
detectAndDrawStr(true)
detectAndDrawStr(false)

// FVGs multi-timeframe
detectFVGs('D', showDFVG, dBullBG, dBearBG, dBullBord, dBearBord, dBordWidth, dBordStyle, dFVGs)
detectFVGs('W', showWFVG, wBullBG, wBearBG, wBullBord, wBearBord, wBordWidth, wBordStyle, wFVGs)
detectFVGs('M', showMFVG, mBullBG, mBearBG, mBullBord, mBearBord, mBordWidth, mBordStyle, mFVGs)
````

# Orderflow + Supply/Demand [Olinvest Style]

- url: https://www.tradingview.com/script/2r5Jxqfi/
- type: indicator
- pine_id: PUB;3f8a5c557d024a0d8b8382da8a641450
- version: 1.0

## Description

Indicateur Orderflow sur ma stratégie personnelle qui m'a rendu rentable en moins d'un an

## Source Code

````pine
//@version=5
// =============================================================================
//  Orderflow + Supply & Demand Indicator
//  Inspiré de la stratégie Orderflow (style Olinvest School)
//  Auteur : créé pour Fares
//
//  Composants :
//   - Order Blocks (OB) bullish / bearish
//   - Fair Value Gaps (FVG) / Imbalances
//   - Liquidity Zones (Buy Side / Sell Side Liquidity)
//   - Break of Structure (BOS) et Change of Character (CHoCH)
//   - Zones de Supply & Demand (combinaison RBD/DBR + bougies momentum + pivots)
//   - Alertes : nouvel OB/FVG, BOS/CHoCH, entrée dans une zone
// =============================================================================

indicator("Orderflow + Supply/Demand [Olinvest Style]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// =============================================================================
//  INPUTS
// =============================================================================
grpStruct   = "🧱 Structure de marché"
grpOB       = "📦 Order Blocks"
grpFVG      = "🟦 Fair Value Gaps"
grpLiq      = "💧 Liquidity Zones"
grpSD       = "🟥🟩 Supply & Demand"
grpStyle    = "🎨 Style"
grpAlerts   = "🔔 Alertes"

// --- Structure
pivotLen        = input.int(5,   "Pivot Length (Structure)",    minval = 1, group = grpStruct, tooltip = "Nombre de bougies à gauche/droite pour valider un swing high/low.")
showBOS         = input.bool(true, "Afficher BOS",              group = grpStruct)
showCHoCH       = input.bool(true, "Afficher CHoCH",            group = grpStruct)

// --- Order Blocks
showOB          = input.bool(true,  "Afficher Order Blocks",                group = grpOB)
obLookback      = input.int(20,     "Lookback OB (bougies)",                minval = 3, group = grpOB, tooltip = "Rechercher la dernière bougie opposée avant l'impulsion.")
obMaxBoxes      = input.int(6,      "Nombre max d'OB affichés",             minval = 1, maxval = 20, group = grpOB)
obMitigation    = input.string("Wick", "Mode de mitigation", options = ["Wick", "Close"], group = grpOB, tooltip = "Wick = invalidé par la mèche ; Close = invalidé par la clôture.")

// --- FVG
showFVG         = input.bool(true,  "Afficher Fair Value Gaps", group = grpFVG)
fvgMinSize      = input.float(0.0,  "Taille min FVG (en ATR)",  minval = 0.0, step = 0.1, group = grpFVG, tooltip = "Filtre les FVG trop petits. 0 = pas de filtre.")
fvgMaxBoxes     = input.int(8,      "Nombre max de FVG affichés", minval = 1, maxval = 30, group = grpFVG)
fvgMitigated    = input.bool(false, "Masquer FVG mitigés",      group = grpFVG)

// --- Liquidity
showLiq         = input.bool(true,  "Afficher zones de liquidité",  group = grpLiq)
liqPivot        = input.int(10,     "Pivot Length (Liquidity)",     minval = 2, group = grpLiq)
liqTolerance    = input.float(0.1,  "Tolérance equal H/L (% ATR)",  minval = 0.0, step = 0.05, group = grpLiq, tooltip = "Tolérance pour considérer deux H/L comme égaux.")

// --- Supply & Demand
showSD          = input.bool(true,    "Afficher zones Supply/Demand",        group = grpSD)
sdMomentumMult  = input.float(1.5,    "Multiplicateur ATR pour bougie momentum", minval = 0.5, step = 0.1, group = grpSD, tooltip = "Une bougie est 'impulsive' si sa taille > ATR * ce facteur.")
sdMaxZones      = input.int(5,        "Nombre max de zones S/D",             minval = 1, maxval = 15, group = grpSD)
sdExtend        = input.bool(true,    "Étendre les zones vers la droite",    group = grpSD)
sdBaseMaxBars   = input.int(5,        "Bougies max dans la base",            minval = 1, maxval = 10, group = grpSD, tooltip = "Nombre max de bougies de consolidation pour valider RBD/DBR/DBD/RBR.")

// --- Style
colBullOB       = input.color(color.new(#26a69a, 75), "Bullish OB",  group = grpStyle)
colBearOB       = input.color(color.new(#ef5350, 75), "Bearish OB",  group = grpStyle)
colBullFVG      = input.color(color.new(#2962ff, 80), "Bullish FVG", group = grpStyle)
colBearFVG      = input.color(color.new(#ff6d00, 80), "Bearish FVG", group = grpStyle)
colDemand       = input.color(color.new(#00c853, 78), "Demand",      group = grpStyle)
colSupply       = input.color(color.new(#d50000, 78), "Supply",      group = grpStyle)
colLiqBuy       = input.color(color.new(#ffd600, 0),  "BSL",         group = grpStyle)
colLiqSell      = input.color(color.new(#ff9100, 0),  "SSL",         group = grpStyle)
colBOS          = input.color(color.new(#00b0ff, 0),  "BOS",         group = grpStyle)
colCHoCH        = input.color(color.new(#e040fb, 0),  "CHoCH",       group = grpStyle)

// --- Alertes
alertEntryZone  = input.bool(true,  "Alerte entrée dans zone S/D", group = grpAlerts)
alertNewOB      = input.bool(true,  "Alerte nouvel Order Block",   group = grpAlerts)
alertNewFVG     = input.bool(true,  "Alerte nouveau FVG",          group = grpAlerts)
alertBOS        = input.bool(true,  "Alerte BOS",                  group = grpAlerts)
alertCHoCH      = input.bool(true,  "Alerte CHoCH",                group = grpAlerts)

// =============================================================================
//  HELPERS
// =============================================================================
atr14 = ta.atr(14)

// Bougie haussière / baissière
isBull = close > open
isBear = close < open

// Bougie impulsive (momentum)
candleSize = math.abs(close - open)
isImpulse  = candleSize > atr14 * sdMomentumMult

// =============================================================================
//  STRUCTURE DE MARCHE (Swings, BOS, CHoCH)
// =============================================================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

var float lastPH       = na
var float lastPL       = na
var int   lastPHbar    = na
var int   lastPLbar    = na

// Tendance interne : 1 = haussière, -1 = baissière, 0 = inconnue
var int trend = 0

if not na(ph)
    lastPH    := ph
    lastPHbar := bar_index - pivotLen

if not na(pl)
    lastPL    := pl
    lastPLbar := bar_index - pivotLen

// Détection BOS / CHoCH
var float prevSwingHigh = na
var float prevSwingLow  = na

bosUp   = false
bosDown = false
chochUp = false
chochDown = false

if not na(lastPH) and close > lastPH and close[1] <= lastPH
    if trend == -1
        chochUp := true
    else
        bosUp := true
    prevSwingHigh := lastPH
    trend := 1

if not na(lastPL) and close < lastPL and close[1] >= lastPL
    if trend == 1
        chochDown := true
    else
        bosDown := true
    prevSwingLow := lastPL
    trend := -1

// Tracé BOS / CHoCH
plotshape(showBOS   and bosUp,     title = "BOS Up",     style = shape.triangleup,   location = location.belowbar, color = colBOS,   size = size.tiny, text = "BOS")
plotshape(showBOS   and bosDown,   title = "BOS Down",   style = shape.triangledown, location = location.abovebar, color = colBOS,   size = size.tiny, text = "BOS")
plotshape(showCHoCH and chochUp,   title = "CHoCH Up",   style = shape.diamond,      location = location.belowbar, color = colCHoCH, size = size.tiny, text = "CHoCH")
plotshape(showCHoCH and chochDown, title = "CHoCH Down", style = shape.diamond,      location = location.abovebar, color = colCHoCH, size = size.tiny, text = "CHoCH")

// =============================================================================
//  ORDER BLOCKS
// =============================================================================
// Définition : dernière bougie de signe opposé avant une impulsion qui casse la structure.
//   - Bullish OB : dernière bougie baissière avant une impulsion haussière (BOS up).
//   - Bearish OB : dernière bougie haussière avant une impulsion baissière (BOS down).

var box[] bullOBs = array.new<box>()
var box[] bearOBs = array.new<box>()

// Cherche la dernière bougie opposée dans les 'obLookback' bougies
f_findLastOpposite(bool wantBear) =>
    int idx = na
    for i = 1 to obLookback
        c_bear = close[i] < open[i]
        c_bull = close[i] > open[i]
        if (wantBear and c_bear) or (not wantBear and c_bull)
            idx := i
            break
    idx

newBullOB = false
newBearOB = false

if bosUp or chochUp
    i = f_findLastOpposite(true)
    if not na(i)
        top    = math.max(open[i], close[i])
        bottom = math.min(low[i], math.min(open[i], close[i]))
        if showOB
            b = box.new(left = bar_index - i, top = top, right = bar_index + 10, bottom = bottom, bgcolor = colBullOB, border_color = color.new(color.green, 50), extend = extend.right)
            array.push(bullOBs, b)
            if array.size(bullOBs) > obMaxBoxes
                old = array.shift(bullOBs)
                box.delete(old)
        newBullOB := true

if bosDown or chochDown
    i = f_findLastOpposite(false)
    if not na(i)
        top    = math.max(high[i], math.max(open[i], close[i]))
        bottom = math.min(open[i], close[i])
        if showOB
            b = box.new(left = bar_index - i, top = top, right = bar_index + 10, bottom = bottom, bgcolor = colBearOB, border_color = color.new(color.red, 50), extend = extend.right)
            array.push(bearOBs, b)
            if array.size(bearOBs) > obMaxBoxes
                old = array.shift(bearOBs)
                box.delete(old)
        newBearOB := true

// Mitigation OB : on supprime ceux qui sont traversés selon le mode choisi
if array.size(bullOBs) > 0
    for i = array.size(bullOBs) - 1 to 0
        b = array.get(bullOBs, i)
        bottom = box.get_bottom(b)
        breached = obMitigation == "Wick" ? low <= bottom : close < bottom
        if breached
            box.delete(b)
            array.remove(bullOBs, i)

if array.size(bearOBs) > 0
    for i = array.size(bearOBs) - 1 to 0
        b = array.get(bearOBs, i)
        top = box.get_top(b)
        breached = obMitigation == "Wick" ? high >= top : close > top
        if breached
            box.delete(b)
            array.remove(bearOBs, i)

// =============================================================================
//  FAIR VALUE GAPS
// =============================================================================
// FVG bullish : low[0] > high[2]  (gap entre bougie -2 et bougie 0)
// FVG bearish : high[0] < low[2]

var box[] bullFVGs = array.new<box>()
var box[] bearFVGs = array.new<box>()

bullFVGcond = low > high[2]
bearFVGcond = high < low[2]

fvgFilter(top_, bot_) =>
    sz = math.abs(top_ - bot_)
    fvgMinSize == 0.0 or sz >= atr14 * fvgMinSize

newBullFVG = false
newBearFVG = false

if bullFVGcond and showFVG
    topf = low
    botf = high[2]
    if fvgFilter(topf, botf)
        b = box.new(left = bar_index - 2, top = topf, right = bar_index + 10, bottom = botf, bgcolor = colBullFVG, border_color = color.new(color.blue, 60), extend = extend.right)
        array.push(bullFVGs, b)
        if array.size(bullFVGs) > fvgMaxBoxes
            old = array.shift(bullFVGs)
            box.delete(old)
        newBullFVG := true

if bearFVGcond and showFVG
    topf = low[2]
    botf = high
    if fvgFilter(topf, botf)
        b = box.new(left = bar_index - 2, top = topf, right = bar_index + 10, bottom = botf, bgcolor = colBearFVG, border_color = color.new(color.orange, 60), extend = extend.right)
        array.push(bearFVGs, b)
        if array.size(bearFVGs) > fvgMaxBoxes
            old = array.shift(bearFVGs)
            box.delete(old)
        newBearFVG := true

// Mitigation des FVG : on les supprime ou on les masque s'ils sont traversés
if array.size(bullFVGs) > 0
    for i = array.size(bullFVGs) - 1 to 0
        b = array.get(bullFVGs, i)
        bottom = box.get_bottom(b)
        if low <= bottom
            if fvgMitigated
                box.delete(b)
                array.remove(bullFVGs, i)
            else
                box.set_bgcolor(b, color.new(color.gray, 85))

if array.size(bearFVGs) > 0
    for i = array.size(bearFVGs) - 1 to 0
        b = array.get(bearFVGs, i)
        top = box.get_top(b)
        if high >= top
            if fvgMitigated
                box.delete(b)
                array.remove(bearFVGs, i)
            else
                box.set_bgcolor(b, color.new(color.gray, 85))

// =============================================================================
//  LIQUIDITY ZONES (BSL / SSL via equal highs/lows)
// =============================================================================
var line[] bslLines = array.new<line>()
var line[] sslLines = array.new<line>()

phL = ta.pivothigh(high, liqPivot, liqPivot)
plL = ta.pivotlow(low,  liqPivot, liqPivot)

var float lastPH_L = na
var int   lastPH_L_bar = na
var float lastPL_L = na
var int   lastPL_L_bar = na

tol = atr14 * liqTolerance

if not na(phL) and showLiq
    if not na(lastPH_L) and math.abs(phL - lastPH_L) <= tol
        l = line.new(x1 = lastPH_L_bar, y1 = lastPH_L, x2 = bar_index - liqPivot, y2 = phL, color = colLiqBuy, width = 2, extend = extend.right)
        array.push(bslLines, l)
        if array.size(bslLines) > 10
            old = array.shift(bslLines)
            line.delete(old)
    lastPH_L     := phL
    lastPH_L_bar := bar_index - liqPivot

if not na(plL) and showLiq
    if not na(lastPL_L) and math.abs(plL - lastPL_L) <= tol
        l = line.new(x1 = lastPL_L_bar, y1 = lastPL_L, x2 = bar_index - liqPivot, y2 = plL, color = colLiqSell, width = 2, extend = extend.right)
        array.push(sslLines, l)
        if array.size(sslLines) > 10
            old = array.shift(sslLines)
            line.delete(old)
    lastPL_L     := plL
    lastPL_L_bar := bar_index - liqPivot

// Nettoyage liquidité : si le prix balaie le niveau, on supprime la ligne
if array.size(bslLines) > 0
    for i = array.size(bslLines) - 1 to 0
        l = array.get(bslLines, i)
        y = line.get_y2(l)
        if high > y
            line.delete(l)
            array.remove(bslLines, i)

if array.size(sslLines) > 0
    for i = array.size(sslLines) - 1 to 0
        l = array.get(sslLines, i)
        y = line.get_y2(l)
        if low < y
            line.delete(l)
            array.remove(sslLines, i)

// =============================================================================
//  SUPPLY & DEMAND ZONES
// =============================================================================
// Combinaison de méthodes :
//   1) Patterns RBD / DBR / DBD / RBR (rallye/base/drop etc.)
//   2) Confirmation par bougie impulsive (taille > ATR * sdMomentumMult)
//   3) Ancrage sur pivots haut/bas récents

var box[] demandZones = array.new<box>()
var box[] supplyZones = array.new<box>()

// Détection d'une base : 1 à sdBaseMaxBars bougies à petit corps (corps < ATR)
f_isBase(int idx) =>
    sz = math.abs(close[idx] - open[idx])
    sz < atr14 * 0.8

// On regarde si la bougie courante est impulsive et si avant on a une mini-base
newDemand = false
newSupply = false

if isImpulse and isBull and showSD
    // Cherche une base sur les sdBaseMaxBars bougies précédentes
    baseHigh  = high[1]
    baseLow   = low[1]
    baseLen   = 0
    for i = 1 to sdBaseMaxBars
        if f_isBase(i)
            baseHigh := math.max(baseHigh, high[i])
            baseLow  := math.min(baseLow,  low[i])
            baseLen  := i
        else
            break
    // Vérifie qu'avant la base on a un drop (DBR) ou un rallye (RBR)
    if baseLen >= 1
        b = box.new(left = bar_index - baseLen, top = baseHigh, right = bar_index + 10, bottom = baseLow, bgcolor = colDemand, border_color = color.new(color.green, 40), extend = sdExtend ? extend.right : extend.none)
        array.push(demandZones, b)
        if array.size(demandZones) > sdMaxZones
            old = array.shift(demandZones)
            box.delete(old)
        newDemand := true

if isImpulse and isBear and showSD
    baseHigh  = high[1]
    baseLow   = low[1]
    baseLen   = 0
    for i = 1 to sdBaseMaxBars
        if f_isBase(i)
            baseHigh := math.max(baseHigh, high[i])
            baseLow  := math.min(baseLow,  low[i])
            baseLen  := i
        else
            break
    if baseLen >= 1
        b = box.new(left = bar_index - baseLen, top = baseHigh, right = bar_index + 10, bottom = baseLow, bgcolor = colSupply, border_color = color.new(color.red, 40), extend = sdExtend ? extend.right : extend.none)
        array.push(supplyZones, b)
        if array.size(supplyZones) > sdMaxZones
            old = array.shift(supplyZones)
            box.delete(old)
        newSupply := true

// Détection d'entrée dans une zone S/D
priceInDemand = false
priceInSupply = false

if array.size(demandZones) > 0
    for i = 0 to array.size(demandZones) - 1
        b = array.get(demandZones, i)
        top = box.get_top(b)
        bot = box.get_bottom(b)
        if low <= top and high >= bot
            priceInDemand := true

if array.size(supplyZones) > 0
    for i = 0 to array.size(supplyZones) - 1
        b = array.get(supplyZones, i)
        top = box.get_top(b)
        bot = box.get_bottom(b)
        if low <= top and high >= bot
            priceInSupply := true

// Mitigation : on retire la zone si elle est complètement traversée (close au-delà)
if array.size(demandZones) > 0
    for i = array.size(demandZones) - 1 to 0
        b = array.get(demandZones, i)
        bot = box.get_bottom(b)
        if close < bot
            box.delete(b)
            array.remove(demandZones, i)

if array.size(supplyZones) > 0
    for i = array.size(supplyZones) - 1 to 0
        b = array.get(supplyZones, i)
        top = box.get_top(b)
        if close > top
            box.delete(b)
            array.remove(supplyZones, i)

// =============================================================================
//  ALERTES
// =============================================================================
if alertNewOB and newBullOB
    alert("🟢 Nouveau Bullish Order Block détecté sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertNewOB and newBearOB
    alert("🔴 Nouveau Bearish Order Block détecté sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertNewFVG and newBullFVG
    alert("🟦 Nouveau Bullish FVG détecté sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertNewFVG and newBearFVG
    alert("🟧 Nouveau Bearish FVG détecté sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertBOS and bosUp
    alert("📈 BOS haussier sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertBOS and bosDown
    alert("📉 BOS baissier sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertCHoCH and chochUp
    alert("🔄 CHoCH haussier sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertCHoCH and chochDown
    alert("🔄 CHoCH baissier sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertEntryZone and priceInDemand and not priceInDemand[1]
    alert("🟩 Le prix entre dans une zone DEMAND sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

if alertEntryZone and priceInSupply and not priceInSupply[1]
    alert("🟥 Le prix entre dans une zone SUPPLY sur " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar_close)

// =============================================================================
//  ALERT CONDITIONS (pour création manuelle via le menu Alertes de TradingView)
// =============================================================================
alertcondition(newBullOB,   title = "Nouveau Bullish OB",  message = "Nouveau Bullish Order Block")
alertcondition(newBearOB,   title = "Nouveau Bearish OB",  message = "Nouveau Bearish Order Block")
alertcondition(newBullFVG,  title = "Nouveau Bullish FVG", message = "Nouveau Bullish FVG")
alertcondition(newBearFVG,  title = "Nouveau Bearish FVG", message = "Nouveau Bearish FVG")
alertcondition(bosUp,       title = "BOS Up",              message = "Break of Structure haussier")
alertcondition(bosDown,     title = "BOS Down",            message = "Break of Structure baissier")
alertcondition(chochUp,     title = "CHoCH Up",            message = "Change of Character haussier")
alertcondition(chochDown,   title = "CHoCH Down",          message = "Change of Character baissier")
alertcondition(priceInDemand and not priceInDemand[1], title = "Entrée zone DEMAND", message = "Prix dans une zone de Demande")
alertcondition(priceInSupply and not priceInSupply[1], title = "Entrée zone SUPPLY", message = "Prix dans une zone de Supply")
````

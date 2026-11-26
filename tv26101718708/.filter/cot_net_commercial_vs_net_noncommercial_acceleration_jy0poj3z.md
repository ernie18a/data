# COT Net Commercial vs Net Non-Commercial + Acceleration

- url: https://www.tradingview.com/script/jy0Poj3z/
- type: indicator
- pine_id: PUB;bed436cd95dd4972a3bb0dc968e2e17d
- version: 1.0

## Description

In diesem Chart wird die netto Positionierung den Commercials und der Non-Commercials dargestellt. Dazu zeigen die roten und grünen Pfeile an, ob die Commercials relativ zur Vergangenheit, eine starke Änderung vorgenommen haben.

## Source Code

````pine
//@version=6

// -------------------- Inputs
bool hideCurrentWeek = true

bool showCommercials = true
bool showLarge = true

// Marking settings (COT-Updates ~ wöchentlich)
int   lookbackUpdates = input.int(26, "Lookback ~ 6 Monate (COT-Updates)", minval=5, maxval=260)
float perc            = input.float(90.0, "Schwelle Perzentil (|Δ|)", minval=1, maxval=99, step=1)
bool  markMoves       = input.bool(true, "Extrem-Änderungen markieren")

indicator(
    "COT Net Commercial vs Net Non-Commercial Positions",
    shorttitle="COT COMM vs NON COMM",
    format=format.percent,
    precision=0
)

import TradingView/LibraryCOT/2 as cot

var string Root_Symbol = syminfo.root
var string CFTC_Code_fixed = cot.convertRootToCOTCode("Auto")
if Root_Symbol == "HG"
    CFTC_Code_fixed := "085692"
else if Root_Symbol == "LBR"
    CFTC_Code_fixed := "058644"

// -------------------- Data request helper
dataRequest(metricName, direction) =>
    tickerId = cot.COTTickerid("Legacy", CFTC_Code_fixed, false, metricName, direction, "All")
    value = request.security(tickerId, "1D", close, ignore_invalid_symbol=true)
    if barstate.islastconfirmedhistory and na(value)
        runtime.error("Could not find relevant COT data based on the current symbol.")
    value

// -------------------- Net long positions
netLongCommercialPositions() =>
    commercialLong  = dataRequest("Commercial Positions", "Long")
    commercialShort = dataRequest("Commercial Positions", "Short")
    commercialLong - commercialShort

netLongLargePositions() =>
    largeSpecsLong  = dataRequest("Noncommercial Positions", "Long")
    largeSpecsShort = dataRequest("Noncommercial Positions", "Short")
    largeSpecsLong - largeSpecsShort

// -------------------- Series
netCommercials = netLongCommercialPositions()
netLarge       = netLongLargePositions()

// -------------------- Hide current (unconfirmed) week logic (unverändert)
plotValueCommercials = hideCurrentWeek ? (timenow >= time_close ? netCommercials : na) : na
plotValueLarge       = hideCurrentWeek ? (timenow >= time_close ? netLarge       : na) : na

// -------------------- Plots
hline(0.0, color=color.black)
plot(showCommercials ? plotValueCommercials : na, "Commercials",   color=color.green, style=plot.style_steplinebr, linewidth=2)
plot(showLarge       ? plotValueLarge       : na, "Large Traders", color=color.red,   style=plot.style_steplinebr, linewidth=2)

// =====================================================================
// Extrem-Änderungen (90%-Perzentil) – Markierungsstil angepasst
// - kein Text
// - ▲ grün bei Anstieg
// - ▼ rot bei Abfall
// =====================================================================

netForSignal = plotValueCommercials

deltaNet = netForSignal - netForSignal[1]
absDelta = math.abs(deltaNet)

// Echtes COT-Update
isUpdate = not na(netForSignal) and not na(netForSignal[1]) and (netForSignal != netForSignal[1])

// Sammle nur |Δ| echter Updates
var float[] deltas = array.new_float()

if isUpdate and absDelta > 0
    array.push(deltas, absDelta)
    if array.size(deltas) > lookbackUpdates
        array.shift(deltas)

// Perzentil aus Array
percentile_from_array(float[] a, float p) =>
    sz = array.size(a)
    if sz == 0
        na
    else
        float[] b = array.copy(a)
        array.sort(b, order.ascending)
        idx = int(math.round((p / 100.0) * (sz - 1)))
        array.get(b, idx)

thrAbs = percentile_from_array(deltas, perc)

// Signal: Top-10%-Bewegung (aufwärts ODER abwärts)
sig = markMoves and isUpdate and not na(thrAbs) and (absDelta >= thrAbs)

// -------------------- Markierungen (nur Stil geändert)
plotshape(
    sig and deltaNet > 0,
    title="Extrem-Anstieg Commercials",
    style=shape.triangleup,
    location=location.bottom,
    size=size.tiny,
    color=color.green
)

plotshape(
    sig and deltaNet < 0,
    title="Extrem-Abfall Commercials",
    style=shape.triangledown,
    location=location.bottom,
    size=size.tiny,
    color=color.red
)
````

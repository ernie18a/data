# Currency Strength RoC Panels (RoC Only) + Triggers

- url: https://www.tradingview.com/script/9XQMXpof-Currency-Strength-RoC-Panels-RoC-Only-Triggers/
- type: indicator
- pine_id: PUB;b9a5af4b767c414cbaf073fa1f18ef03
- version: 1.0

## Description

Currency Strength Slope (ROC)

Currency Strength Slope is a relative currency momentum indicator designed to measure and rank the rate of change across the major currency basket.

Instead of looking at one Forex pair in isolation, this indicator evaluates the underlying momentum of each major currency individually: EUR, USD, JPY, CHF, GBP, AUD, CAD, and NZD. By comparing currency strength movement across a full FX basket, it helps identify which currencies are accelerating, weakening, or showing meaningful shifts in relative momentum.

The goal is to provide a clearer view of currency flow, momentum rotation, and potential strength/weakness relationships across the market.

Features:

• Tracks RoC/momentum for 8 major currencies
• Includes EUR, USD, JPY, CHF, GBP, AUD, CAD, and NZD
• Uses a full FX basket comparison approach
• Customizable broker/feed selection
• Adjustable anchor timeframe and lookback
• Optional last-closed-bar mode for cleaner confirmed values
• Optional z-score normalization
• Ranking panel for strongest to weakest momentum
• Optional flag display
• Positive and negative trigger lines
• Fixed or auto StDev-based trigger thresholds
• Signal dots on trigger crosses
• Basket shift marker when leading currencies flip
• Zero line and top absolute RoC line options

Alerts Included:

• Any RoC Trigger Cross
• Basket Shift: Top 2 Absolute RoC Flip

Potential use cases:

• Identify the strongest and weakest currencies
• Find momentum rotation across the FX basket
• Spot currency acceleration and deceleration
• Confirm directional bias on Forex pairs
• Build strong-vs-weak pair ideas
• Detect major shifts in currency leadership
• Add confluence to existing Forex strategies

Interpretation:

Positive RoC

The currency is gaining momentum relative to the broader basket.

Negative RoC

The currency is losing momentum relative to the broader basket.

Ranking Panel

Shows which currencies are currently leading or lagging by momentum.

Trigger Crosses

Highlight when a currency’s momentum moves beyond a meaningful positive or negative threshold.

Basket Shift Marker

Appears when the top 2 currencies by absolute RoC flip direction, which may signal a broader shift in currency flow.

This indicator is intended to help traders move beyond single-pair analysis and understand the broader currency strength environment.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Currency Strength RoC Panels (RoC Only) + Triggers", overlay=false, max_labels_count=200, max_lines_count=200)

//===========================
// Groups
//===========================
gp1 = "Data"
gp2 = "RoC (Momentum)"
gp4 = "Panels"
gp5 = "Plot"
gp6 = "Colors"
gp7 = "Trigger Lines"
gp8 = "Signals & Alerts"

//===========================
// Inputs
//===========================
broker      = input.string("FX_IDC", "Broker", options=["OANDA","FOREXCOM","SAXO","FX_IDC","FX"], group=gp1)
anchorTF    = input.timeframe("D", "Anchor TF (comparison)", group=gp1)
anchorBars  = input.int(1, "Anchor bars back", minval=1, group=gp1)

// >>> NEW: freeze display on last closed bar
useLastClosed = input.bool(false, "Use last closed bar values (no intrabar updates)", group=gp1)

// RoC settings
rocLen      = input.int(14, "RoC length (slope)", minval=1, group=gp2)
normalize   = input.bool(true, "Normalize (z-score)", group=gp2)
normLen     = input.int(50, "Normalization length", minval=5, group=gp2)

// Panels
showPanels  = input.bool(true, "Show panel", group=gp4)
panelY      = input.string("top", "Panel Y", options=["top","middle","bottom"], group=gp4, inline="pos")
panelX      = input.string("right", "Panel X", options=["left","center","right"], group=gp4, inline="pos")
textSize    = input.string(size.normal, "Text size", options=[size.tiny,size.small,size.normal,size.large,size.huge], group=gp4)
showFlags   = input.bool(true, "Show flags", group=gp4)

// Plot
showLines   = input.bool(true, "Plot RoC lines", group=gp5)
showTopLine = input.bool(false, "Plot Top |RoC|", group=gp5)
topLineW    = input.int(3, "Top line width", minval=1, maxval=6, group=gp5)
showZero    = input.bool(true, "Show zero line", group=gp5)

// Trigger lines (positive/negative thresholds)
showTriggers     = input.bool(true, "Show trigger lines", group=gp7)
triggerMode      = input.string("Fixed", "Trigger mode", options=["Fixed","Auto (StDev)"], group=gp7)
posTrigFixed     = input.float(1.50, "Positive trigger (fixed)", step=0.05, group=gp7, inline="fix")
negTrigFixed     = input.float(-1.50, "Negative trigger (fixed)", step=0.05, group=gp7, inline="fix")
autoLen          = input.int(100, "Auto length", minval=20, group=gp7)
autoMult         = input.float(1.5, "Auto multiplier", step=0.1, group=gp7)
triggerLineColor = input.color(color.new(color.gray, 0), "Trigger line color", group=gp7)
triggerLineW     = input.int(1, "Trigger line width", minval=1, maxval=4, group=gp7)

// Signals / Alerts
showSignalDots    = input.bool(true, "Show signal dots at trigger crosses", group=gp8)
showBasketShift   = input.bool(true, "Show basket shift marker (top 2 abs RoC flip)", group=gp8)
basketMarkerY     = input.float(0.0, "Basket shift marker Y", step=0.1, group=gp8)
enableAlerts      = input.bool(true, "Enable alertconditions", group=gp8)

//===========================
// Colors
//===========================
eurColor = input.color(color.red,     "EUR", group=gp6)
usdColor = input.color(color.orange,  "USD", group=gp6)
jpyColor = input.color(color.aqua,    "JPY", group=gp6)
chfColor = input.color(color.maroon,  "CHF", group=gp6)
gbpColor = input.color(color.green,   "GBP", group=gp6)
audColor = input.color(color.blue,    "AUD", group=gp6)
cadColor = input.color(color.purple,  "CAD", group=gp6)
nzdColor = input.color(color.fuchsia, "NZD", group=gp6)

zeroColor      = input.color(color.gray,  "Zero line", group=gp6)
topColor       = input.color(color.white, "Top line", group=gp6)
panelTextColor = input.color(color.black, "Panel text", group=gp6)

//===========================
// Helpers
//===========================
logRet(v1, v2) =>
    v2 == 0.0 ? 0.0 : math.log(v1 / v2) * 10000.0

logRet_div(a1, a2, b1, b2) =>
    (b1 == 0.0 or b2 == 0.0) ? 0.0 : logRet(a1 / b1, a2 / b2)

logRet_mul(a1, a2, b1, b2) =>
    logRet(a1 * b1, a2 * b2)

// NOTE: lookahead_off avoids repainting from HTF lookahead
getPair(sym) =>
    v_now = request.security(sym, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
    v_ref = request.security(sym, anchorTF, close[anchorBars], barmerge.gaps_off, barmerge.lookahead_off)
    [v_now, v_ref]

// slope per bar (linreg delta)
regSlope(x, len) =>
    ta.linreg(x, len, 0) - ta.linreg(x, len, 1)

zscore(x) =>
    mu = ta.sma(x, normLen)
    sd = ta.stdev(x, normLen)
    sd == 0.0 ? na : (x - mu) / sd

flag(cur) =>
    switch cur
        "EUR" => "🇪🇺"
        "USD" => "🇺🇸"
        "JPY" => "🇯🇵"
        "CHF" => "🇨🇭"
        "GBP" => "🇬🇧"
        "AUD" => "🇦🇺"
        "CAD" => "🇨🇦"
        "NZD" => "🇳🇿"
        => ""

ccur(cur) =>
    switch cur
        "EUR" => eurColor
        "USD" => usdColor
        "JPY" => jpyColor
        "CHF" => chfColor
        "GBP" => gbpColor
        "AUD" => audColor
        "CAD" => cadColor
        "NZD" => nzdColor
        => color.gray

posFrom(y, x) =>
    key = y + "_" + x
    switch key
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.top_right

// Return sorted index array (DESC by vals)
sortIdxDesc(vals) =>
    idx = array.new_int()
    for i = 0 to array.size(vals) - 1
        array.push(idx, i)

    for i = 0 to array.size(idx) - 2
        best = i
        for j = i + 1 to array.size(idx) - 1
            vi = array.get(vals, array.get(idx, best))
            vj = array.get(vals, array.get(idx, j))
            if vj > vi
                best := j
        if best != i
            tmp = array.get(idx, i)
            array.set(idx, i, array.get(idx, best))
            array.set(idx, best, tmp)
    idx

renderPanel(_pos, _title, _vals, _names) =>
    var table t = table.new(_pos, 4, 9, border_width=0)
    table.clear(t, 0, 0, 3, 8)

    table.cell(t, 0, 0, "R", text_color=panelTextColor, text_size=textSize)
    table.cell(t, 1, 0, "",  text_color=panelTextColor, text_size=textSize)
    table.cell(t, 2, 0, _title, text_color=panelTextColor, text_size=textSize, text_halign=text.align_left)
    table.cell(t, 3, 0, "Val", text_color=panelTextColor, text_size=textSize, text_halign=text.align_right)

    idx = sortIdxDesc(_vals)
    for r = 0 to 7
        i0  = array.get(idx, r)
        cur = array.get(_names, i0)
        val = array.get(_vals, i0)

        bg  = color.new(ccur(cur), 0)
        rk  = str.tostring(r + 1)
        fl  = showFlags ? flag(cur) : ""
        vs  = str.format("{0,number,#.###}", val)

        table.cell(t, 0, r + 1, rk, bgcolor=bg, text_color=panelTextColor, text_size=textSize)
        table.cell(t, 1, r + 1, fl, bgcolor=bg, text_color=panelTextColor, text_size=textSize)
        table.cell(t, 2, r + 1, cur, bgcolor=bg, text_color=panelTextColor, text_size=textSize, text_halign=text.align_left)
        table.cell(t, 3, r + 1, vs, bgcolor=bg, text_color=panelTextColor, text_size=textSize, text_halign=text.align_right)

// helper: choose current vs last-closed
pick(v) => useLastClosed ? v[1] : v

//===========================
// Pull base pairs
//===========================
[eurusd_now, eurusd_ref] = getPair(broker + ":EURUSD")
[usdjpy_now, usdjpy_ref] = getPair(broker + ":USDJPY")
[usdchf_now, usdchf_ref] = getPair(broker + ":USDCHF")
[gbpusd_now, gbpusd_ref] = getPair(broker + ":GBPUSD")
[audusd_now, audusd_ref] = getPair(broker + ":AUDUSD")
[usdcad_now, usdcad_ref] = getPair(broker + ":USDCAD")
[nzdusd_now, nzdusd_ref] = getPair(broker + ":NZDUSD")

//===========================
// Returns
//===========================
EURUSD = logRet(eurusd_now, eurusd_ref)
USDJPY = logRet(usdjpy_now, usdjpy_ref)
USDCHF = logRet(usdchf_now, usdchf_ref)
GBPUSD = logRet(gbpusd_now, gbpusd_ref)
AUDUSD = logRet(audusd_now, audusd_ref)
USDCAD = logRet(usdcad_now, usdcad_ref)
NZDUSD = logRet(nzdusd_now, nzdusd_ref)

// Crosses
EURJPY = logRet_mul(eurusd_now, eurusd_ref, usdjpy_now, usdjpy_ref)
EURCHF = logRet_mul(eurusd_now, eurusd_ref, usdchf_now, usdchf_ref)
EURGBP = logRet_div(eurusd_now, eurusd_ref, gbpusd_now, gbpusd_ref)
EURAUD = logRet_div(eurusd_now, eurusd_ref, audusd_now, audusd_ref)
EURNZD = logRet_div(eurusd_now, eurusd_ref, nzdusd_now, nzdusd_ref)
EURCAD = logRet_mul(eurusd_now, eurusd_ref, usdcad_now, usdcad_ref)

CHFJPY = logRet_div(usdjpy_now, usdjpy_ref, usdchf_now, usdchf_ref)
GBPJPY = logRet_mul(gbpusd_now, gbpusd_ref, usdjpy_now, usdjpy_ref)
GBPCHF = logRet_mul(gbpusd_now, gbpusd_ref, usdchf_now, usdchf_ref)
GBPAUD = logRet_div(gbpusd_now, gbpusd_ref, audusd_now, audusd_ref)
GBPCAD = logRet_mul(gbpusd_now, gbpusd_ref, usdcad_now, usdcad_ref)
GBPNZD = logRet_div(gbpusd_now, gbpusd_ref, nzdusd_now, nzdusd_ref)

AUDJPY = logRet_mul(audusd_now, audusd_ref, usdjpy_now, usdjpy_ref)
AUDCHF = logRet_mul(audusd_now, audusd_ref, usdchf_now, usdchf_ref)
AUDCAD = logRet_mul(audusd_now, audusd_ref, usdcad_now, usdcad_ref)
AUDNZD = logRet_div(audusd_now, audusd_ref, nzdusd_now, nzdusd_ref)

NZDJPY = logRet_mul(nzdusd_now, nzdusd_ref, usdjpy_now, usdjpy_ref)
NZDCHF = logRet_mul(nzdusd_now, nzdusd_ref, usdchf_now, usdchf_ref)
NZDCAD = logRet_mul(nzdusd_now, nzdusd_ref, usdcad_now, usdcad_ref)

CADJPY = logRet_div(usdjpy_now, usdjpy_ref, usdcad_now, usdcad_ref)
CADCHF = logRet_div(usdchf_now, usdchf_ref, usdcad_now, usdcad_ref)

//===========================
// Currency Strength (internal only)
//===========================
EUR = ( EURUSD + EURJPY + EURCHF + EURGBP + EURAUD + EURCAD + EURNZD ) / 7
USD = (-EURUSD + USDJPY + USDCHF - GBPUSD - AUDUSD + USDCAD - NZDUSD ) / 7
JPY = (-EURJPY - USDJPY - CHFJPY - GBPJPY - AUDJPY - CADJPY - NZDJPY ) / 7
CHF = (-EURCHF - USDCHF + CHFJPY - GBPCHF - AUDCHF - CADCHF - NZDCHF ) / 7
GBP = (-EURGBP + GBPUSD + GBPCHF + GBPJPY + GBPAUD + GBPCAD + GBPNZD ) / 7
AUD = (-EURAUD + AUDUSD + AUDJPY + AUDCHF - GBPAUD + AUDCAD + AUDNZD ) / 7
CAD = (-EURCAD - USDCAD + CADJPY + CADCHF - GBPCAD - AUDCAD - NZDCAD ) / 7
NZD = (-EURNZD + NZDUSD + NZDJPY + NZDCHF - GBPNZD + NZDCAD - AUDNZD ) / 7

//===========================
// RoC (Momentum) only
//===========================
EUR_roc_raw = regSlope(EUR, rocLen)
USD_roc_raw = regSlope(USD, rocLen)
JPY_roc_raw = regSlope(JPY, rocLen)
CHF_roc_raw = regSlope(CHF, rocLen)
GBP_roc_raw = regSlope(GBP, rocLen)
AUD_roc_raw = regSlope(AUD, rocLen)
CAD_roc_raw = regSlope(CAD, rocLen)
NZD_roc_raw = regSlope(NZD, rocLen)

EUR_roc = normalize ? zscore(EUR_roc_raw) : EUR_roc_raw
USD_roc = normalize ? zscore(USD_roc_raw) : USD_roc_raw
JPY_roc = normalize ? zscore(JPY_roc_raw) : JPY_roc_raw
CHF_roc = normalize ? zscore(CHF_roc_raw) : CHF_roc_raw
GBP_roc = normalize ? zscore(GBP_roc_raw) : GBP_roc_raw
AUD_roc = normalize ? zscore(AUD_roc_raw) : AUD_roc_raw
CAD_roc = normalize ? zscore(CAD_roc_raw) : CAD_roc_raw
NZD_roc = normalize ? zscore(NZD_roc_raw) : NZD_roc_raw

// >>> APPLY "last closed" selection consistently
EURv = pick(EUR_roc)
USDv = pick(USD_roc)
JPYv = pick(JPY_roc)
CHFv = pick(CHF_roc)
GBPv = pick(GBP_roc)
AUDv = pick(AUD_roc)
CADv = pick(CAD_roc)
NZDv = pick(NZD_roc)

//===========================
// Trigger thresholds (pos/neg)
//===========================
absTopRoc = math.max(math.abs(EURv), math.abs(USDv))
absTopRoc := math.max(absTopRoc, math.abs(JPYv))
absTopRoc := math.max(absTopRoc, math.abs(CHFv))
absTopRoc := math.max(absTopRoc, math.abs(GBPv))
absTopRoc := math.max(absTopRoc, math.abs(AUDv))
absTopRoc := math.max(absTopRoc, math.abs(CADv))
absTopRoc := math.max(absTopRoc, math.abs(NZDv))

autoBase = ta.stdev(absTopRoc, autoLen) * autoMult
posTrig  = triggerMode == "Fixed" ? posTrigFixed : autoBase
negTrig  = triggerMode == "Fixed" ? negTrigFixed : -autoBase

//===========================
// Plots (RoC only)
//===========================
plot(showLines ? EURv : na, title="EUR RoC", color=ccur("EUR"))
plot(showLines ? USDv : na, title="USD RoC", color=ccur("USD"))
plot(showLines ? JPYv : na, title="JPY RoC", color=ccur("JPY"))
plot(showLines ? CHFv : na, title="CHF RoC", color=ccur("CHF"))
plot(showLines ? GBPv : na, title="GBP RoC", color=ccur("GBP"))
plot(showLines ? AUDv : na, title="AUD RoC", color=ccur("AUD"))
plot(showLines ? CADv : na, title="CAD RoC", color=ccur("CAD"))
plot(showLines ? NZDv : na, title="NZD RoC", color=ccur("NZD"))

plot(showTopLine ? absTopRoc : na, title="Top |RoC|", color=topColor, linewidth=topLineW)
plot(showZero ? 0.0 : na, title="Zero", color=zeroColor)

// Trigger lines
plot(showTriggers ? posTrig : na, title="Positive Trigger", color=triggerLineColor, linewidth=triggerLineW)
plot(showTriggers ? negTrig : na, title="Negative Trigger", color=triggerLineColor, linewidth=triggerLineW)

//===========================
// Trigger cross signals (RoC crosses trigger lines)
//===========================
eurUp = ta.crossover(EURv, posTrig)
eurDn = ta.crossunder(EURv, negTrig)
usdUp = ta.crossover(USDv, posTrig)
usdDn = ta.crossunder(USDv, negTrig)
jpyUp = ta.crossover(JPYv, posTrig)
jpyDn = ta.crossunder(JPYv, negTrig)
chfUp = ta.crossover(CHFv, posTrig)
chfDn = ta.crossunder(CHFv, negTrig)
gbpUp = ta.crossover(GBPv, posTrig)
gbpDn = ta.crossunder(GBPv, negTrig)
audUp = ta.crossover(AUDv, posTrig)
audDn = ta.crossunder(AUDv, negTrig)
cadUp = ta.crossover(CADv, posTrig)
cadDn = ta.crossunder(CADv, negTrig)
nzdUp = ta.crossover(NZDv, posTrig)
nzdDn = ta.crossunder(NZDv, negTrig)

anyTriggerCross = eurUp or eurDn or usdUp or usdDn or jpyUp or jpyDn or chfUp or chfDn or gbpUp or gbpDn or audUp or audDn or cadUp or cadDn or nzdUp or nzdDn

plot(showSignalDots and (eurUp or eurDn) ? EURv : na, title="EUR Trigger Dot", style=plot.style_circles, color=ccur("EUR"), linewidth=2)
plot(showSignalDots and (usdUp or usdDn) ? USDv : na, title="USD Trigger Dot", style=plot.style_circles, color=ccur("USD"), linewidth=2)
plot(showSignalDots and (jpyUp or jpyDn) ? JPYv : na, title="JPY Trigger Dot", style=plot.style_circles, color=ccur("JPY"), linewidth=2)
plot(showSignalDots and (chfUp or chfDn) ? CHFv : na, title="CHF Trigger Dot", style=plot.style_circles, color=ccur("CHF"), linewidth=2)
plot(showSignalDots and (gbpUp or gbpDn) ? GBPv : na, title="GBP Trigger Dot", style=plot.style_circles, color=ccur("GBP"), linewidth=2)
plot(showSignalDots and (audUp or audDn) ? AUDv : na, title="AUD Trigger Dot", style=plot.style_circles, color=ccur("AUD"), linewidth=2)
plot(showSignalDots and (cadUp or cadDn) ? CADv : na, title="CAD Trigger Dot", style=plot.style_circles, color=ccur("CAD"), linewidth=2)
plot(showSignalDots and (nzdUp or nzdDn) ? NZDv : na, title="NZD Trigger Dot", style=plot.style_circles, color=ccur("NZD"), linewidth=2)

//===========================
// Basket shift (top 2 ABS RoC flip sign across zero)
//===========================
rocByIndex(i) =>
    switch i
        0 => EURv
        1 => USDv
        2 => JPYv
        3 => CHFv
        4 => GBPv
        5 => AUDv
        6 => CADv
        7 => NZDv
        => na

absVals = array.from(math.abs(EURv), math.abs(USDv), math.abs(JPYv), math.abs(CHFv), math.abs(GBPv), math.abs(AUDv), math.abs(CADv), math.abs(NZDv))
idxAbs  = sortIdxDesc(absVals)

i1 = array.get(idxAbs, 0)
i2 = array.get(idxAbs, 1)

lead1 = rocByIndex(i1)
lead2 = rocByIndex(i2)

// if using "last closed", compare the chosen bar to its prior bar consistently:
lead1_prev = useLastClosed ? rocByIndex(i1)[2] : rocByIndex(i1)[1]
lead2_prev = useLastClosed ? rocByIndex(i2)[2] : rocByIndex(i2)[1]

lead1Flip = (lead1 * lead1_prev) < 0
lead2Flip = (lead2 * lead2_prev) < 0
basketShift = lead1Flip and lead2Flip

plot(showBasketShift and basketShift ? basketMarkerY : na, title="Basket Shift Marker", style=plot.style_circles, linewidth=3, color=color.new(color.yellow, 0))

//===========================
// Alertconditions (must be global scope)
//===========================
alertcondition(enableAlerts and anyTriggerCross, title="Any RoC Trigger Cross", message="Currency RoC crossed a trigger threshold (+Trig or -Trig).")
alertcondition(enableAlerts and basketShift, title="Basket Shift (Top 2 ABS RoC Flip)", message="Basket shift: top 2 (by absolute RoC) flipped sign (crossed zero).")

//===========================
// Panel (RoC only)
//===========================
names = array.from("EUR","USD","JPY","CHF","GBP","AUD","CAD","NZD")

if showPanels and barstate.islast
    rocVals = array.from(EURv, USDv, JPYv, CHFv, GBPv, AUDv, CADv, NZDv)
    p = posFrom(panelY, panelX)
    renderPanel(p, "RoC", rocVals, names)
````

# Order Flow + Std Dev + IFVG + Quant + Delta + VWAP + VP + OTE

- url: https://www.tradingview.com/script/MMEfAPDg-Order-Flow-Std-Dev-IFVG-Quant-Delta-VWAP-VP-OTE/
- type: indicator
- pine_id: PUB;417a8a4867bd4a009141b27643279c47
- version: 1.0

## Description

What this indicator does

Orderflow Confluence Suite answers two questions on one chart: who is in control right now (orderflow) and is price at a location worth acting on (structure). It combines an intrabar orderflow engine — delta, cumulative delta, imbalance, absorption, VWAP with deviation bands, a rolling volume profile and a tape-speed readout — with a Smart Money Concepts location engine — fair value gaps with full inverse-FVG lifecycle, an Optimal Trade Entry retracement window built from swing structure, and the current day's H4 and H1 OTE zones projected onto your chart, resetting each new day.

A signal only prints when both sides agree: the orderflow score reaches its threshold (all six conditions by default) and price is sitting at a qualifying location — inside the OTE window, retesting a flipped gap, or inside today's H4/H1 zone — in the same direction. Each signal label states which location qualified.

The dashboard has a Plain English mode (on by default): every reading is written as a sentence — "Buyers in control today, lead growing", "Heavy selling absorbed — bullish clue", "Inside the pullback BUY window" — so you don't need to already speak orderflow to use it. Toggle it off for standard trader shorthand.

Why these components are combined

Orderflow tools tell you when participation is real but say nothing about where price is in the structure; SMC tools mark where the high-interest zones are but say nothing about whether anyone is actually trading there. Each half gates the other: the orderflow score filters out structure retests that nobody is participating in, and the location gate filters out strong flow that fires in the middle of nowhere. Neither module is decorative — every component feeds either the participation gate, the location gate, or the dashboard context that explains them.

How it works

Orderflow engine (participation gate). TradingView provides no Level 2 data, so aggressive buying and selling are reconstructed from lower-timeframe intrabar candles via request.security_lower_tf — an intrabar close at or above its open counts as aggressive buying, below as selling. From this: per-bar delta labels; session-anchored cumulative delta with rising/falling state; imbalance flags when one side takes ≥65% of a bar's volume (triangles on two consecutive bars); absorption diamonds when volume runs ≥1.5× average yet the bar's range stays ≤0.6× ATR with delta opposing the close — heavy aggression that failed to move price. A statistical layer normalises everything: volume z-score, delta z-score and delta percentile over a rolling window, plus a tape readout counting large prints (≥2× average print size) per side. Session VWAP carries ±1σ/±2σ bands from volume-weighted variance, and a rolling volume profile classifies the POC, high-volume nodes (≥70% of POC volume) and low-volume nodes (≤30%). The score counts six conditions per side: delta direction, CVD slope, price vs VWAP, price vs value, volume z-score above 0.5, and imbalance-or-absorption.

SMC engine (location gate). Fair value gaps are detected on the bar that completes them, with an ATR minimum-size filter. When price closes through a gap's midpoint (or full fill, selectable) it flips to an inverse FVG — former support becomes resistance and vice versa — and the script then watches for the retest: price tagging the flipped zone and closing back on the right side of it. Zones that get reclaimed are invalidated rather than left on the chart. The OTE window applies the 62–79% retracement (adjustable) to the most recent swing leg, with direction set by swing structure (higher highs and higher lows vs lower highs and lower lows) and an optional swing-order check. The same OTE calculation runs on the H4 and H1 series via request.security, and those zones are drawn as shaded boxes spanning the current day only — labelled buy or sell by that timeframe's structure — and reset automatically at the daily change. Optional SMA-based standard deviation bands are included for mean-reversion context (off by default; the dashboard reports SD position either way).

Signals. On a confirmed close, with a cooldown between signals: orderflow score ≥ threshold, dominant over the opposing side, and (unless the location gate is disabled) price at a same-direction location. Labels read like "BUY 6/6 @ H4 zone". Signals are evaluated on closed bars only and reference no future data, so they do not repaint; note the H4/H1 zones themselves update as those higher-timeframe bars develop, which is live structure behaving normally, and historical intrabar data can differ marginally from live-streamed ticks.

How to use it

Best on 5m–1h charts of liquid instruments with real exchange volume (index futures, gold, crypto). Set the intrabar timeframe to "1"; with seconds data on a 1–5m chart, 10S–15S gives finer delta. On forex/CFDs volume is tick count, so treat delta modules as rough approximations there.

Suggested flow: read the dashboard top-down — who's winning the bar and the session, whether flow is one-sided or being absorbed, how stretched price is, where it sits in the profile, then the structure/OTE/zone rows, ending with the Signal check row which states exactly what is and isn't satisfied. Treat the H4/H1 zones as the day's areas of interest, the OTE window as the tactical entry area, and wait for the two-gate signal rather than acting on either gate alone. Alerts are included for signals, absorption, stacked imbalance, IFVG retests and OTE entry.

Settings overview

Everything is grouped and toggleable: intrabar timeframe, imbalance/absorption thresholds, VWAP anchor and band widths, profile lookback/rows and node thresholds, FVG size/expiry/mitigation mode, OTE swing length and retracement bounds, HTF zone display, SD bands, minimum orderflow score, the location-gate toggle, and signal cooldown. Plain English mode is under General.

Limitations

Delta is reconstructed from intrabar candle direction — a well-established proxy, not true DOM/footprint data, which requires a dedicated platform with exchange depth. The confluence logic identifies conditions and locations, not outcomes; it is a context and filtering tool, not a trade system. Nothing here guarantees results — position sizing and stop discipline remain yours. This script is provided for educational purposes and is not financial advice.

## Source Code

````pine
//@version=6
indicator("Orderflow Confluence Suite — OF + SMC", "OF+SMC", overlay = true, max_boxes_count = 500, max_lines_count = 100, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────
// ORDERFLOW CONFLUENCE SUITE
// Merges: Orderflow Suite (delta/CVD, imbalance, absorption,
// VWAP+sigma, volume profile, tape, quant) + IFVG/OTE/StdDev v3
// + daily H4/H1 OTE buy/sell zones (reset each day).
// Signals use TWO GATES:
//   Gate 1 (participation): orderflow score, default 6/6
//   Gate 2 (location): price in OTE zone, IFVG retest, or
//                      inside today's H4/H1 zone, same direction
// Dashboard has a Plain English mode (default ON).
// ─────────────────────────────────────────────────────────────

// ── INPUTS ───────────────────────────────────────────────────
grpG = "General"
plainMode = input.bool(true, "Plain English dashboard", group = grpG, tooltip = "ON: readable sentences. OFF: trader shorthand.")
ltfTf     = input.timeframe("1", "Intrabar timeframe (delta source)", group = grpG)
showDash  = input.bool(true, "Show dashboard", group = grpG)
dashSizeS = input.string("small", "Dashboard text size", options = ["tiny", "small", "normal"], group = grpG)

grpD = "Footprint / Delta"
showDeltaLbl = input.bool(true, "Delta labels under bars", group = grpD)
deltaBars    = input.int(12, "Bars to label", minval = 1, maxval = 40, group = grpD)
imbRatio     = input.float(0.65, "Imbalance: one-sided share of volume", minval = 0.5, maxval = 0.95, step = 0.05, group = grpD)
absVolMult   = input.float(1.5, "Absorption: volume >= x average", minval = 1.0, step = 0.1, group = grpD)
absRangeMax  = input.float(0.6, "Absorption: range <= x ATR", minval = 0.1, step = 0.1, group = grpD)

grpV = "VWAP"
showVwap    = input.bool(true, "Session VWAP + deviation bands", group = grpV)
vwapAnchorS = input.string("Session", "Anchor", options = ["Session", "Week"], group = grpV)
band1Mult   = input.float(1.0, "Band 1 — fair value edge (sigma)", step = 0.25, group = grpV)
band2Mult   = input.float(2.0, "Band 2 — mean reversion (sigma)", step = 0.25, group = grpV)

grpP = "Volume Profile"
showProf  = input.bool(true, "Show profile", group = grpP)
profLen   = input.int(150, "Lookback (bars)", minval = 20, maxval = 500, group = grpP)
profRows  = input.int(24, "Rows", minval = 6, maxval = 50, group = grpP)
profWidth = input.int(30, "Max row width (bars)", minval = 5, maxval = 60, group = grpP)
hvnPct    = input.float(0.70, "HVN >= x POC volume", step = 0.05, group = grpP)
lvnPct    = input.float(0.30, "LVN <= x POC volume", step = 0.05, group = grpP)

grpT = "Tape & Quant"
largePrintMult = input.float(2.0, "Large print >= x avg intrabar volume", step = 0.25, group = grpT)
zLen           = input.int(100, "Z-score / percentile lookback", minval = 20, maxval = 500, group = grpT)

grpF = "Fair Value Gaps / IFVG"
fvgAtrMult = input.float(0.3, "Minimum gap size (x ATR)", group = grpF, minval = 0.0, step = 0.1)
fvgMinZone = input.float(0.5, "Minimum zone height (x ATR)", group = grpF, minval = 0.0, step = 0.1)
fvgExpiry  = input.int(50, "Bars a zone stays valid", group = grpF, minval = 5)
fvgWidth   = input.int(30, "Box width (bars)", group = grpF, minval = 5)
fvgMitMode = input.string("Midpoint", "Mitigation trigger", group = grpF, options = ["Midpoint", "Full fill"])
showLive    = input.bool(true, "Show live gaps", group = grpF)
showInv     = input.bool(true, "Show inverse gaps", group = grpF)
showInvalid = input.bool(false, "Keep invalidated zones on chart", group = grpF)
showInvLbl  = input.bool(true, "Show inversion labels", group = grpF)

grpO = "OTE (chart timeframe)"
oteSwing  = input.int(20, "Swing length", group = grpO, minval = 3)
oteShow   = input.bool(true, "Show OTE zone", group = grpO)
oteExtend = input.int(20, "Extend zone right (bars)", group = grpO, minval = 1)
oteSeq    = input.bool(true, "Require correct swing order", group = grpO)
oteLoIn   = input.float(0.62, "Retracement start", group = grpO, minval = 0.1, maxval = 0.95, step = 0.01)
oteHiIn   = input.float(0.79, "Retracement end", group = grpO, minval = 0.1, maxval = 0.99, step = 0.01)

grpH = "Daily H4 / H1 zones"
showHtf   = input.bool(true, "Show today's H4 + H1 OTE zones", group = grpH)
htfSwing  = input.int(10, "HTF swing length", group = grpH, minval = 3, tooltip = "Swing length used on the H4 and H1 series. Smaller than chart swing length because HTF bars cover more time.")
htfExtend = input.int(8, "Extend zones right (bars)", group = grpH, minval = 1)

grpSD = "Standard deviation bands"
sdShow = input.bool(false, "Show SMA + SD bands", group = grpSD, tooltip = "Off by default - the VWAP sigma bands cover similar ground. Dashboard reports SD position either way.")
sdLen  = input.int(20, "Length", group = grpSD, minval = 5)
sdM1   = input.float(1.0, "1st band multiplier", group = grpSD, step = 0.1)
sdM2   = input.float(2.0, "2nd band multiplier", group = grpSD, step = 0.1)

grpS = "Signals"
showSignals = input.bool(true, "Show BUY / SELL signals", group = grpS)
minScore    = input.int(6, "Gate 1: min orderflow score (of 6)", minval = 3, maxval = 6, group = grpS)
useLocGate  = input.bool(true, "Gate 2: require OTE / IFVG / HTF zone location", group = grpS)
coolDown    = input.int(10, "Signal cooldown (bars)", minval = 0, group = grpS)

// ── COLORS ───────────────────────────────────────────────────
colBuy  = color.new(#26a69a, 0)
colSell = color.new(#ef5350, 0)
colPoc  = color.new(#ff9800, 0)
colHvn  = color.new(#2962ff, 60)
colLvn  = color.new(#787b86, 75)
colMid  = color.new(#b2b5be, 82)
colVwap = color.new(#ff9800, 0)
colB1   = color.new(#2962ff, 0)
colB2   = color.new(#9c27b0, 0)
colBg   = color.new(#131722, 15)
colHead = color.new(#000000, 0)
colGray = color.new(#b2b5be, 0)
cBullFill = color.new(color.teal, 80)
cBearFill = color.new(color.red, 80)
cBullEdge = color.new(color.teal, 25)
cBearEdge = color.new(color.red, 25)
cInvBull  = color.new(color.lime, 72)
cInvBear  = color.new(color.orange, 72)
cInvEdge  = color.new(color.orange, 15)
cDeadFill = color.new(color.gray, 88)
cDeadEdge = color.new(color.gray, 60)
cH4Buy  = color.new(#26a69a, 78)
cH4Sell = color.new(#ef5350, 78)
cH1Buy  = color.new(#26a69a, 86)
cH1Sell = color.new(#ef5350, 86)

// ── HELPERS (value-only, no drawing calls) ──────────────────
f_fmt(float v) =>
    a = math.abs(v)
    a >= 1000000 ? str.tostring(v / 1000000, "#.##") + "M" : a >= 1000 ? str.tostring(v / 1000, "#.#") + "K" : str.tostring(v, "#.##")

f_px(float v) =>
    str.tostring(v, format.mintick)

// ── INTRABAR DATA → DELTA ───────────────────────────────────
[ivVol, ivDir] = request.security_lower_tf(syminfo.tickerid, ltfTf, [volume, close >= open ? 1.0 : -1.0])

int nPrints = na(ivVol) ? 0 : ivVol.size()
float avgPrintSize = volume / math.max(nPrints, 1)
float smoothPrint  = ta.sma(avgPrintSize, 20)

float buyVol  = 0.0
float sellVol = 0.0
int bigBuyPrints  = 0
int bigSellPrints = 0
if nPrints > 0
    for i = 0 to nPrints - 1
        v = ivVol.get(i)
        d = ivDir.get(i)
        if d > 0
            buyVol += v
        else
            sellVol += v
        if v >= smoothPrint * largePrintMult
            if d > 0
                bigBuyPrints += 1
            else
                bigSellPrints += 1
else
    buyVol  := close >= open ? volume : 0.0
    sellVol := close >= open ? 0.0 : volume

float delta   = buyVol - sellVol
float buyPct  = volume > 0 ? buyVol / volume : 0.5
float sellPct = 1.0 - buyPct

bool newSess = vwapAnchorS == "Week" ? timeframe.change("W") : timeframe.change("D")
var float cvd = 0.0
if newSess
    cvd := 0.0
cvd += delta
bool cvdRising  = cvd > cvd[3]
bool cvdFalling = cvd < cvd[3]

bool buyImb  = volume > 0 and buyPct >= imbRatio
bool sellImb = volume > 0 and sellPct >= imbRatio
bool stackedBuyImb  = buyImb and buyImb[1]
bool stackedSellImb = sellImb and sellImb[1]

float atrVal   = ta.atr(14)
float volAvg   = ta.sma(volume, 20)
float barRange = high - low
bool bigVol     = volume >= volAvg * absVolMult
bool smallRange = barRange <= atrVal * absRangeMax
bool bullAbs = bigVol and smallRange and delta < 0 and close >= (high + low) / 2
bool bearAbs = bigVol and smallRange and delta > 0 and close <= (high + low) / 2

// ── QUANT STATS ─────────────────────────────────────────────
float volZ     = (volume - ta.sma(volume, zLen)) / math.max(ta.stdev(volume, zLen), 1e-10)
float deltaZ   = (delta - ta.sma(delta, zLen)) / math.max(ta.stdev(delta, zLen), 1e-10)
float deltaPct = ta.percentrank(delta, zLen)
bool tapeFast  = volZ > 1.0
bool tapeSlow  = volZ < -0.5

float pressBuy    = ta.sma(buyVol, 20)
float pressSell   = ta.sma(sellVol, 20)
float pressBuyPct = (pressBuy + pressSell) > 0 ? pressBuy / (pressBuy + pressSell) * 100 : 50.0

// ── SESSION VWAP + SIGMA BANDS ──────────────────────────────
float src = hlc3
var float cumV   = 0.0
var float cumPV  = 0.0
var float cumPV2 = 0.0
if newSess
    cumV   := 0.0
    cumPV  := 0.0
    cumPV2 := 0.0
cumV   += volume
cumPV  += src * volume
cumPV2 += src * src * volume
float vwapVal = cumV > 0 ? cumPV / cumV : src
float vwapVar = cumV > 0 ? math.max(cumPV2 / cumV - vwapVal * vwapVal, 0.0) : 0.0
float vwapSd  = math.sqrt(vwapVar)
float vwapDistSd = vwapSd > 0 ? (close - vwapVal) / vwapSd : 0.0

pV  = plot(showVwap ? vwapVal : na, "VWAP", colVwap, 2)
pU1 = plot(showVwap ? vwapVal + band1Mult * vwapSd : na, "+1 sigma", color.new(colB1, 45))
pL1 = plot(showVwap ? vwapVal - band1Mult * vwapSd : na, "-1 sigma", color.new(colB1, 45))
pU2 = plot(showVwap ? vwapVal + band2Mult * vwapSd : na, "+2 sigma", color.new(colB2, 45))
pL2 = plot(showVwap ? vwapVal - band2Mult * vwapSd : na, "-2 sigma", color.new(colB2, 45))
fill(pU1, pL1, color = color.new(colB1, 92), title = "Fair value zone")
fill(pU2, pU1, color = color.new(colB2, 94), title = "Upper mean-reversion zone")
fill(pL1, pL2, color = color.new(colB2, 94), title = "Lower mean-reversion zone")

float valueMean = math.sum(src * volume, profLen) / math.max(math.sum(volume, profLen), 1e-10)
bool aboveValue = close > valueMean

// ── STANDARD DEVIATION BANDS (from IFVG/OTE v3) ─────────────
sdBasis = ta.sma(close, sdLen)
sdVal   = ta.stdev(close, sdLen)
sdU1 = sdBasis + sdM1 * sdVal
sdL1 = sdBasis - sdM1 * sdVal
sdU2 = sdBasis + sdM2 * sdVal
sdL2 = sdBasis - sdM2 * sdVal
plot(sdShow ? sdBasis : na, "SD basis", color.new(color.gray, 40))
plot(sdShow ? sdU1 : na, "+1 SD", color.new(color.yellow, 55))
plot(sdShow ? sdL1 : na, "-1 SD", color.new(color.yellow, 55))
plot(sdShow ? sdU2 : na, "+2 SD", color.new(color.orange, 55))
plot(sdShow ? sdL2 : na, "-2 SD", color.new(color.orange, 55))

// ── STRUCTURE + OTE (chart timeframe, from v3 with fix) ─────
oteNear = math.min(oteLoIn, oteHiIn)
oteFar  = math.max(oteLoIn, oteHiIn)

ph = ta.pivothigh(high, oteSwing, oteSwing)
pl = ta.pivotlow(low, oteSwing, oteSwing)

var float sh1 = na
var float sh2 = na
var float sl1 = na
var float sl2 = na
var int   sh1Bar = na
var int   sl1Bar = na

if not na(ph)
    sh2    := sh1
    sh1    := ph
    sh1Bar := bar_index - oteSwing
if not na(pl)
    sl2    := sl1
    sl1    := pl
    sl1Bar := bar_index - oteSwing

var bool bullBias   = false
var bool haveStruct = false
if not na(sh1) and not na(sh2) and not na(sl1) and not na(sl2)
    haveStruct := true
    hh = sh1 > sh2
    lh = sh1 < sh2
    hl = sl1 > sl2
    ll = sl1 < sl2
    if hh and hl
        bullBias := true
    else if lh and ll
        bullBias := false
    else if lh
        bullBias := false
    else if hl
        bullBias := true

var float oteTop = na
var float oteBot = na
seqOk = not oteSeq or na(sh1Bar) or na(sl1Bar) ? true : bullBias ? sl1Bar < sh1Bar : sh1Bar < sl1Bar
if not na(sh1) and not na(sl1) and sh1 > sl1 and seqOk
    leg = sh1 - sl1
    if bullBias
        oteTop := sh1 - leg * oteNear
        oteBot := sh1 - leg * oteFar
    else
        oteTop := sl1 + leg * oteFar
        oteBot := sl1 + leg * oteNear

inOte     = not na(oteTop) and close <= oteTop and close >= oteBot
inBullOte = inOte and bullBias
inBearOte = inOte and not bullBias

var line  lnOteTop = na
var line  lnOteBot = na
var label lbOte    = na
if barstate.islast and oteShow and not na(oteTop)
    line.delete(lnOteTop)
    line.delete(lnOteBot)
    label.delete(lbOte)
    oteCol = bullBias ? color.new(color.lime, 30) : color.new(color.red, 30)
    oteTxt = bullBias ? "OTE buy zone" : "OTE sell zone"
    lnOteTop := line.new(bar_index - oteSwing * 2, oteTop, bar_index + oteExtend, oteTop, color = oteCol, width = 1, style = line.style_dashed)
    lnOteBot := line.new(bar_index - oteSwing * 2, oteBot, bar_index + oteExtend, oteBot, color = oteCol, width = 1, style = line.style_dashed)
    lbOte := label.new(bar_index + oteExtend, math.avg(oteTop, oteBot), oteTxt, style = label.style_label_left, color = color.new(color.black, 70), textcolor = oteCol, size = size.small)

oteBg = inBullOte ? color.new(color.lime, 92) : inBearOte ? color.new(color.red, 92) : na
bgcolor(oteBg, title = "OTE zone highlight")

// ── DAILY H4 / H1 OTE ZONES (reset each day) ────────────────
f_oteHtf() =>
    hph = ta.pivothigh(high, htfSwing, htfSwing)
    hpl = ta.pivotlow(low, htfSwing, htfSwing)
    var float hSh1 = na
    var float hSh2 = na
    var float hSl1 = na
    var float hSl2 = na
    if not na(hph)
        hSh2 := hSh1
        hSh1 := hph
    if not na(hpl)
        hSl2 := hSl1
        hSl1 := hpl
    var bool hBull = false
    if not na(hSh1) and not na(hSh2) and not na(hSl1) and not na(hSl2)
        hHh = hSh1 > hSh2
        hLh = hSh1 < hSh2
        hHl = hSl1 > hSl2
        hLl = hSl1 < hSl2
        if hHh and hHl
            hBull := true
        else if hLh and hLl
            hBull := false
        else if hLh
            hBull := false
        else if hHl
            hBull := true
    float hTop = na
    float hBot = na
    if not na(hSh1) and not na(hSl1) and hSh1 > hSl1
        hLeg = hSh1 - hSl1
        if hBull
            hTop := hSh1 - hLeg * oteNear
            hBot := hSh1 - hLeg * oteFar
        else
            hTop := hSl1 + hLeg * oteFar
            hBot := hSl1 + hLeg * oteNear
    [hTop, hBot, hBull ? 1 : -1]

[h4Top, h4Bot, h4Dir] = request.security(syminfo.tickerid, "240", f_oteHtf(), lookahead = barmerge.lookahead_off)
[h1Top, h1Bot, h1Dir] = request.security(syminfo.tickerid, "60", f_oteHtf(), lookahead = barmerge.lookahead_off)

var int dayStartBar = 0
if timeframe.change("D")
    dayStartBar := bar_index

var box h4Box = na
var box h1Box = na
var label h4Lbl = na
var label h1Lbl = na
if barstate.islast
    box.delete(h4Box)
    box.delete(h1Box)
    label.delete(h4Lbl)
    label.delete(h1Lbl)
    if showHtf and not na(h4Top)
        h4Col = h4Dir > 0 ? cH4Buy : cH4Sell
        h4Edge = h4Dir > 0 ? cBullEdge : cBearEdge
        h4Txt = h4Dir > 0 ? "H4 buy zone (today)" : "H4 sell zone (today)"
        h4Box := box.new(dayStartBar, h4Top, bar_index + htfExtend, h4Bot, border_color = h4Edge, bgcolor = h4Col, border_width = 2)
        h4Lbl := label.new(bar_index + htfExtend, math.avg(h4Top, h4Bot), h4Txt, style = label.style_label_left, color = color.new(color.black, 70), textcolor = h4Dir > 0 ? colBuy : colSell, size = size.small)
    if showHtf and not na(h1Top)
        h1Col = h1Dir > 0 ? cH1Buy : cH1Sell
        h1Edge = h1Dir > 0 ? color.new(color.teal, 55) : color.new(color.red, 55)
        h1Txt = h1Dir > 0 ? "H1 buy zone (today)" : "H1 sell zone (today)"
        h1Box := box.new(dayStartBar, h1Top, bar_index + htfExtend, h1Bot, border_color = h1Edge, bgcolor = h1Col, border_width = 1)
        h1Lbl := label.new(bar_index + htfExtend, math.avg(h1Top, h1Bot), h1Txt, style = label.style_label_left, color = color.new(color.black, 70), textcolor = h1Dir > 0 ? colBuy : colSell, size = size.small)

bool inH4Buy  = not na(h4Top) and h4Dir > 0 and close <= h4Top and close >= h4Bot
bool inH4Sell = not na(h4Top) and h4Dir < 0 and close <= h4Top and close >= h4Bot
bool inH1Buy  = not na(h1Top) and h1Dir > 0 and close <= h1Top and close >= h1Bot
bool inH1Sell = not na(h1Top) and h1Dir < 0 and close <= h1Top and close >= h1Bot

// ── FVG / IFVG ENGINE (from v3) ─────────────────────────────
MAX_ZONES = 60
var array<float> zTop   = array.new<float>()
var array<float> zBot   = array.new<float>()
var array<int>   zBar   = array.new<int>()
var array<int>   zRef   = array.new<int>()
var array<bool>  zBull  = array.new<bool>()
var array<int>   zState = array.new<int>()
var array<bool>  zBig   = array.new<bool>()
var array<box>   zBox   = array.new<box>()

gapMin = fvgAtrMult * atrVal
bullT  = low
bullB  = high[2]
bearT  = low[2]
bearB  = high

newBullGap = barstate.isconfirmed and bar_index > 2 and bullT > bullB and (bullT - bullB) >= gapMin
newBearGap = barstate.isconfirmed and bar_index > 2 and bearB < bearT and (bearT - bearB) >= gapMin

if newBullGap
    big = (bullT - bullB) >= fvgMinZone * atrVal
    array.push(zTop, bullT)
    array.push(zBot, bullB)
    array.push(zBar, bar_index - 1)
    array.push(zRef, bar_index)
    array.push(zBull, true)
    array.push(zState, 0)
    array.push(zBig, big)
    bx = box.new(bar_index - 2, bullT, bar_index - 2 + fvgWidth, bullB, border_color = showLive ? cBullEdge : na, bgcolor = showLive ? cBullFill : na, border_width = big ? 2 : 1)
    array.push(zBox, bx)

if newBearGap
    big2 = (bearT - bearB) >= fvgMinZone * atrVal
    array.push(zTop, bearT)
    array.push(zBot, bearB)
    array.push(zBar, bar_index - 1)
    array.push(zRef, bar_index)
    array.push(zBull, false)
    array.push(zState, 0)
    array.push(zBig, big2)
    bx2 = box.new(bar_index - 2, bearT, bar_index - 2 + fvgWidth, bearB, border_color = showLive ? cBearEdge : na, bgcolor = showLive ? cBearFill : na, border_width = big2 ? 2 : 1)
    array.push(zBox, bx2)

bool firedInvBull  = false
bool firedInvBear  = false
bool firedRetestUp = false
bool firedRetestDn = false

if barstate.isconfirmed and array.size(zTop) > 0
    for i = array.size(zTop) - 1 to 0
        st = array.get(zState, i)
        if st != 2
            t    = array.get(zTop, i)
            b    = array.get(zBot, i)
            bull = array.get(zBull, i)
            big3 = array.get(zBig, i)
            bx3  = array.get(zBox, i)
            mid  = math.avg(t, b)
            trig = fvgMitMode == "Midpoint" ? mid : bull ? b : t
            if st == 0
                mitigated = bull ? close < trig : close > trig
                if mitigated
                    array.set(zState, i, 1)
                    array.set(zRef, i, bar_index)
                    vis = showInv
                    box.set_bgcolor(bx3, vis ? (bull ? cInvBear : cInvBull) : na)
                    box.set_border_color(bx3, vis ? cInvEdge : na)
                    box.set_border_style(bx3, line.style_dashed)
                    box.set_right(bx3, bar_index + fvgWidth)
                    if bull
                        firedInvBear := true
                    else
                        firedInvBull := true
                    if showInvLbl and vis and big3
                        label.new(bar_index, bull ? t : b, bull ? "IFVG down" : "IFVG up", style = bull ? label.style_label_down : label.style_label_up, color = color.new(bull ? color.orange : color.lime, 25), textcolor = color.white, size = size.tiny)
            else if st == 1
                if bull
                    if high >= b and close < b and big3
                        firedRetestDn := true
                else
                    if low <= t and close > t and big3
                        firedRetestUp := true
                reclaimed = bull ? close > t : close < b
                if reclaimed
                    array.set(zState, i, 2)
                    array.set(zRef, i, bar_index)
                    box.set_bgcolor(bx3, showInvalid ? cDeadFill : na)
                    box.set_border_color(bx3, showInvalid ? cDeadEdge : na)
            if bar_index - array.get(zRef, i) > fvgExpiry and array.get(zState, i) != 2
                array.set(zState, i, 2)
                box.set_bgcolor(bx3, showInvalid ? cDeadFill : na)
                box.set_border_color(bx3, showInvalid ? cDeadEdge : na)

if array.size(zTop) > MAX_ZONES
    for k = 0 to array.size(zTop) - MAX_ZONES - 1
        box.delete(array.shift(zBox))
        array.shift(zTop)
        array.shift(zBot)
        array.shift(zBar)
        array.shift(zRef)
        array.shift(zBull)
        array.shift(zState)
        array.shift(zBig)

// ── VOLUME PROFILE ──────────────────────────────────────────
var array<box> profBoxes = array.new<box>()
var line pocLine = na
var float pocPrice = na
var string valueZoneKey = "na"
var string hvnAboveTxt = "-"
var string hvnBelowTxt = "-"
if showProf and barstate.islast
    if profBoxes.size() > 0
        for b in profBoxes
            box.delete(b)
        profBoxes.clear()
    if not na(pocLine)
        line.delete(pocLine)
    int lb = math.min(profLen, bar_index + 1)
    float hi = high
    float lo = low
    for i = 0 to lb - 1
        hi := math.max(hi, high[i])
        lo := math.min(lo, low[i])
    float rowH = (hi - lo) / profRows
    if rowH > 0
        rowVolA = array.new<float>(profRows, 0.0)
        for i = 0 to lb - 1
            bHi = high[i]
            bLo = low[i]
            bRange = math.max(bHi - bLo, syminfo.mintick)
            for r = 0 to profRows - 1
                rTop = lo + rowH * (r + 1)
                rBot = lo + rowH * r
                ov = math.min(bHi, rTop) - math.max(bLo, rBot)
                if ov > 0
                    rowVolA.set(r, rowVolA.get(r) + volume[i] * ov / bRange)
        float maxVRaw = rowVolA.max()
        int pocRow = math.max(rowVolA.indexof(maxVRaw), 0)
        float maxV = math.max(maxVRaw, 1e-10)
        pocPrice := lo + rowH * (pocRow + 0.5)
        for r = 0 to profRows - 1
            rv = rowVolA.get(r)
            w = math.max(1, math.round(rv / maxV * profWidth))
            rTop = lo + rowH * (r + 1)
            rBot = lo + rowH * r
            rowCol = r == pocRow ? color.new(colPoc, 55) : rv >= maxV * hvnPct ? colHvn : rv <= maxV * lvnPct ? colLvn : colMid
            profBoxes.push(box.new(bar_index + 3, rTop, bar_index + 3 + w, rBot, border_color = color.new(color.gray, 85), bgcolor = rowCol))
        pocLine := line.new(bar_index - lb + 1, pocPrice, bar_index + 3, pocPrice, color = colPoc, width = 2, style = line.style_dashed)
        int closeRow = int(math.min(profRows - 1, math.max(0, math.floor((close - lo) / rowH))))
        float rvClose = rowVolA.get(closeRow)
        valueZoneKey := rvClose >= maxV * hvnPct ? "hvn" : rvClose <= maxV * lvnPct ? "lvn" : "mid"
        float hvnAbove = na
        float hvnBelow = na
        for r = 0 to profRows - 1
            if rowVolA.get(r) >= maxV * hvnPct
                rowMid = lo + rowH * (r + 0.5)
                if rowMid > close and na(hvnAbove)
                    hvnAbove := rowMid
                if rowMid < close
                    hvnBelow := rowMid
        hvnAboveTxt := na(hvnAbove) ? "-" : f_px(hvnAbove)
        hvnBelowTxt := na(hvnBelow) ? "-" : f_px(hvnBelow)

// ── FOOTPRINT MARKS ─────────────────────────────────────────
var array<label> dLabels = array.new<label>()
if showDeltaLbl and barstate.isconfirmed
    deltaTxtCol = delta >= 0 ? colBuy : colSell
    deltaTxt = (delta >= 0 ? "+" : "-") + f_fmt(math.abs(delta))
    dLabels.push(label.new(bar_index, low, deltaTxt, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.black, 100), textcolor = deltaTxtCol, size = size.small))
    if dLabels.size() > deltaBars
        label.delete(dLabels.shift())

plotshape(showDeltaLbl and stackedBuyImb, "Stacked buy imbalance", shape.triangleup, location.belowbar, colBuy, size = size.tiny)
plotshape(showDeltaLbl and stackedSellImb, "Stacked sell imbalance", shape.triangledown, location.abovebar, colSell, size = size.tiny)
plotchar(showDeltaLbl and bullAbs, "Bullish absorption", "◆", location.belowbar, colBuy, size = size.tiny)
plotchar(showDeltaLbl and bearAbs, "Bearish absorption", "◆", location.abovebar, colSell, size = size.tiny)

// ── TWO-GATE SIGNALS ────────────────────────────────────────
int bullScore = (delta > 0 ? 1 : 0) + (cvdRising ? 1 : 0) + (close > vwapVal ? 1 : 0) + (aboveValue ? 1 : 0) + (volZ > 0.5 ? 1 : 0) + (buyImb or bullAbs ? 1 : 0)
int bearScore = (delta < 0 ? 1 : 0) + (cvdFalling ? 1 : 0) + (close < vwapVal ? 1 : 0) + (not aboveValue ? 1 : 0) + (volZ > 0.5 ? 1 : 0) + (sellImb or bearAbs ? 1 : 0)

bool bullLocation = inBullOte or firedRetestUp or inH4Buy or inH1Buy
bool bearLocation = inBearOte or firedRetestDn or inH4Sell or inH1Sell

var int lastSigBar = -99999
bool canSig  = bar_index - lastSigBar > coolDown
bool buySig  = showSignals and barstate.isconfirmed and canSig and bullScore >= minScore and bullScore > bearScore and (not useLocGate or bullLocation)
bool sellSig = showSignals and barstate.isconfirmed and canSig and bearScore >= minScore and bearScore > bullScore and (not useLocGate or bearLocation)
if buySig
    lastSigBar := bar_index
    buyWhere = inBullOte ? "OTE" : firedRetestUp ? "IFVG" : inH4Buy ? "H4 zone" : inH1Buy ? "H1 zone" : "flow"
    label.new(bar_index, low, "BUY " + str.tostring(bullScore) + "/6 @ " + buyWhere, yloc = yloc.belowbar, style = label.style_label_up, color = colBuy, textcolor = color.white, size = size.normal)
if sellSig
    lastSigBar := bar_index
    sellWhere = inBearOte ? "OTE" : firedRetestDn ? "IFVG" : inH4Sell ? "H4 zone" : inH1Sell ? "H1 zone" : "flow"
    label.new(bar_index, high, "SELL " + str.tostring(bearScore) + "/6 @ " + sellWhere, yloc = yloc.abovebar, style = label.style_label_down, color = colSell, textcolor = color.white, size = size.normal)

alertcondition(buySig, "OF+SMC: BUY", "Orderflow 6/6 with price at a buy location")
alertcondition(sellSig, "OF+SMC: SELL", "Orderflow 6/6 with price at a sell location")
alertcondition(bullAbs, "Bullish absorption", "Heavy selling absorbed - price held")
alertcondition(bearAbs, "Bearish absorption", "Heavy buying absorbed - price capped")
alertcondition(stackedBuyImb, "Stacked buy imbalance", "Two consecutive buy-imbalance bars")
alertcondition(stackedSellImb, "Stacked sell imbalance", "Two consecutive sell-imbalance bars")
alertcondition(firedRetestUp, "IFVG support retest", "Price tested a flipped support zone and closed back above it")
alertcondition(firedRetestDn, "IFVG resistance retest", "Price tested a flipped resistance zone and closed back below it")
alertcondition(inBullOte and not inBullOte[1], "Entered OTE buy zone", "Price entered the OTE buy window")
alertcondition(inBearOte and not inBearOte[1], "Entered OTE sell zone", "Price entered the OTE sell window")

// ── DASHBOARD — PLAIN ENGLISH / PRO ─────────────────────────
dashTxtSize = dashSizeS == "tiny" ? size.tiny : dashSizeS == "small" ? size.small : size.normal
var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(position.top_right, 2, 17, bgcolor = colBg, border_width = 1, border_color = color.new(color.gray, 60))
    // counts for IFVG row
    int nLive = 0
    int nInv  = 0
    if array.size(zTop) > 0
        for i = 0 to array.size(zTop) - 1
            s = array.get(zState, i)
            if s == 0
                nLive += 1
            if s == 1
                nInv += 1
    // header
    dash.cell(0, 0, "CONFLUENCE SUITE", text_color = colPoc, text_size = dashTxtSize, bgcolor = colHead)
    dash.cell(1, 0, syminfo.ticker + " · " + timeframe.period, text_color = colGray, text_size = dashTxtSize, bgcolor = colHead)
    // 1 this bar
    barWinner = delta >= 0 ? "Buyers" : "Sellers"
    barPc = str.tostring((delta >= 0 ? buyPct : sellPct) * 100, "#")
    t1 = plainMode ? barWinner + " won this bar (" + barPc + "% of volume)" : "Δ " + (delta >= 0 ? "+" : "-") + f_fmt(math.abs(delta)) + " (B " + str.tostring(buyPct * 100, "#") + "%/S " + str.tostring(sellPct * 100, "#") + "%)"
    dash.cell(0, 1, plainMode ? "This bar" : "Bar Δ", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 1, t1, text_color = delta >= 0 ? colBuy : colSell, text_size = dashTxtSize)
    // 2 session
    sessLead = cvd >= 0 ? "Buyers" : "Sellers"
    sessTrend = cvdRising ? (cvd >= 0 ? ", lead growing" : ", sellers fading") : cvdFalling ? (cvd >= 0 ? ", lead fading" : ", lead growing") : ""
    t2 = plainMode ? sessLead + " in control today" + sessTrend : "CVD " + (cvd >= 0 ? "+" : "-") + f_fmt(math.abs(cvd)) + (cvdRising ? " ▲" : cvdFalling ? " ▼" : " ·")
    dash.cell(0, 2, plainMode ? "Today so far" : "Session CVD", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 2, t2, text_color = cvdRising ? colBuy : cvdFalling ? colSell : colGray, text_size = dashTxtSize)
    // 3 pressure
    t3 = plainMode ? "Buyers " + str.tostring(pressBuyPct, "#") + "% of recent aggression" : "B " + str.tostring(pressBuyPct, "#") + "% / S " + str.tostring(100 - pressBuyPct, "#") + "% (20b)"
    dash.cell(0, 3, plainMode ? "Recent pressure" : "Aggression 20b", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 3, t3, text_color = pressBuyPct >= 55 ? colBuy : pressBuyPct <= 45 ? colSell : colGray, text_size = dashTxtSize)
    // 4 imbalance
    t4 = stackedBuyImb ? (plainMode ? "Heavy one-way BUYING, 2 bars running" : "BUY stacked") : stackedSellImb ? (plainMode ? "Heavy one-way SELLING, 2 bars running" : "SELL stacked") : buyImb ? (plainMode ? "One-way buying this bar" : "BUY") : sellImb ? (plainMode ? "One-way selling this bar" : "SELL") : (plainMode ? "Two-way trade, no side dominant" : "-")
    dash.cell(0, 4, plainMode ? "One-sided flow" : "Imbalance", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 4, t4, text_color = buyImb ? colBuy : sellImb ? colSell : colGray, text_size = dashTxtSize)
    // 5 absorption
    t5 = bullAbs ? (plainMode ? "Heavy selling ABSORBED - bullish clue" : "BULL - sellers absorbed") : bearAbs ? (plainMode ? "Heavy buying ABSORBED - bearish clue" : "BEAR - buyers absorbed") : (plainMode ? "None right now" : "-")
    dash.cell(0, 5, "Absorption", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 5, t5, text_color = bullAbs ? colBuy : bearAbs ? colSell : colGray, text_size = dashTxtSize)
    // 6 stretch (VWAP sigma + SD band)
    absD = math.abs(vwapDistSd)
    sdPos = close > sdU2 ? ">2SD" : close > sdU1 ? ">1SD" : close < sdL2 ? "<-2SD" : close < sdL1 ? "<-1SD" : "in 1SD"
    stretchPlain = absD >= band2Mult ? "STRETCHED " + (vwapDistSd > 0 ? "high" : "low") + " - snap-back risk" : absD <= band1Mult ? "Near today's fair price" : (vwapDistSd > 0 ? "Above" : "Below") + " fair price, not extreme"
    t6 = plainMode ? stretchPlain : "VWAP " + (vwapDistSd >= 0 ? "+" : "") + str.tostring(vwapDistSd, "#.##") + "σ · SD " + sdPos
    dash.cell(0, 6, plainMode ? "Price stretch" : "VWAP / SD", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 6, t6, text_color = absD >= band2Mult ? colPoc : close > vwapVal ? colBuy : colSell, text_size = dashTxtSize)
    // 7 profile
    zonePlain = valueZoneKey == "hvn" ? "busy area - expect chop" : valueZoneKey == "lvn" ? "thin area - can move fast" : "average traffic"
    zonePro = valueZoneKey == "hvn" ? "HVN - acceptance" : valueZoneKey == "lvn" ? "LVN - rejection risk" : "Mid volume"
    t7 = na(pocPrice) ? "n/a" : plainMode ? (close > pocPrice ? "Above" : "Below") + " the day's busiest price, in a " + zonePlain : (close > pocPrice ? "Above POC · " : "Below POC · ") + zonePro
    dash.cell(0, 7, plainMode ? "Where price sits" : "Profile", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 7, t7, text_color = na(pocPrice) ? colGray : close > pocPrice ? colBuy : colSell, text_size = dashTxtSize)
    // 8 resting liquidity
    t8 = plainMode ? "Big resting orders: " + hvnAboveTxt + " above / " + hvnBelowTxt + " below" : hvnAboveTxt + " / " + hvnBelowTxt
    dash.cell(0, 8, plainMode ? "Order walls" : "HVN liq ▲/▼", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 8, t8, text_color = colGray, text_size = dashTxtSize)
    // 9 tape
    paceTxt = tapeFast ? "FAST" : tapeSlow ? "SLOW" : "normal"
    t9 = plainMode ? "Pace " + paceTxt + " · big buys " + str.tostring(bigBuyPrints) + " / big sells " + str.tostring(bigSellPrints) : paceTxt + " · prints B" + str.tostring(bigBuyPrints) + "/S" + str.tostring(bigSellPrints)
    dash.cell(0, 9, plainMode ? "Trading pace" : "Tape", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 9, t9, text_color = tapeFast ? colPoc : colGray, text_size = dashTxtSize)
    // 10 quant
    volDesc = volZ > 2 ? "very unusual" : volZ > 1 ? "unusual" : volZ < -0.5 ? "quiet" : "normal"
    t10 = plainMode ? "Volume " + volDesc + " · flow stronger than " + str.tostring(deltaPct, "#") + "% of recent bars" : "Vol z " + str.tostring(volZ, "#.#") + " · Δ z " + str.tostring(deltaZ, "#.#") + " · Δ pct " + str.tostring(deltaPct, "#")
    dash.cell(0, 10, plainMode ? "How unusual" : "Quant", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 10, t10, text_color = colGray, text_size = dashTxtSize)
    // 11 structure
    t11 = not haveStruct ? (plainMode ? "Still forming" : "building") : bullBias ? (plainMode ? "Uptrend (higher highs + higher lows)" : "HH + HL up") : (plainMode ? "Downtrend (lower highs + lower lows)" : "LH + LL down")
    dash.cell(0, 11, plainMode ? "Trend structure" : "Structure", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 11, t11, text_color = not haveStruct ? colGray : bullBias ? colBuy : colSell, text_size = dashTxtSize)
    // 12 OTE
    t12 = na(oteTop) ? (plainMode ? "No valid pullback leg yet" : "no valid leg") : inBullOte ? (plainMode ? "Inside the pullback BUY window" : "in buy zone") : inBearOte ? (plainMode ? "Inside the pullback SELL window" : "in sell zone") : (plainMode ? "Outside the entry window (" + f_px(oteBot) + "-" + f_px(oteTop) + ")" : "outside " + f_px(oteBot) + "-" + f_px(oteTop))
    dash.cell(0, 12, plainMode ? "Entry window" : "OTE", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 12, t12, text_color = na(oteTop) ? colGray : inBullOte ? colBuy : inBearOte ? colSell : colGray, text_size = dashTxtSize)
    // 13 IFVG
    retestNow = firedRetestUp ? (plainMode ? " · support retest NOW" : " · retest up") : firedRetestDn ? (plainMode ? " · resistance retest NOW" : " · retest dn") : ""
    t13 = plainMode ? str.tostring(nLive) + " open gaps · " + str.tostring(nInv) + " flipped zones" + retestNow : "live " + str.tostring(nLive) + " · inv " + str.tostring(nInv) + retestNow
    dash.cell(0, 13, plainMode ? "Gaps & flips" : "FVG / IFVG", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 13, t13, text_color = firedRetestUp ? colBuy : firedRetestDn ? colSell : colGray, text_size = dashTxtSize)
    // 14 H4 zone
    t14 = na(h4Top) ? (plainMode ? "No valid zone yet today" : "n/a") : (h4Dir > 0 ? (plainMode ? "Buy zone " : "buy ") : (plainMode ? "Sell zone " : "sell ")) + f_px(h4Bot) + "-" + f_px(h4Top) + (inH4Buy or inH4Sell ? (plainMode ? " · price is IN it" : " · inside") : "")
    dash.cell(0, 14, plainMode ? "H4 zone today" : "H4 OTE", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 14, t14, text_color = na(h4Top) ? colGray : h4Dir > 0 ? colBuy : colSell, text_size = dashTxtSize)
    // 15 H1 zone
    t15 = na(h1Top) ? (plainMode ? "No valid zone yet today" : "n/a") : (h1Dir > 0 ? (plainMode ? "Buy zone " : "buy ") : (plainMode ? "Sell zone " : "sell ")) + f_px(h1Bot) + "-" + f_px(h1Top) + (inH1Buy or inH1Sell ? (plainMode ? " · price is IN it" : " · inside") : "")
    dash.cell(0, 15, plainMode ? "H1 zone today" : "H1 OTE", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 15, t15, text_color = na(h1Top) ? colGray : h1Dir > 0 ? colBuy : colSell, text_size = dashTxtSize)
    // 16 gates
    bool domBull = bullScore >= bearScore
    int domScore = domBull ? bullScore : bearScore
    bool gateOF  = domScore >= minScore
    bool gateLoc = not useLocGate or (domBull ? bullLocation : bearLocation)
    sideTxt = domBull ? "BUY" : "SELL"
    t16 = gateOF and gateLoc ? (plainMode ? sideTxt + " READY - flow passed and price at a proper zone" : sideTxt + " · OF " + str.tostring(domScore) + "/6 ✔ · loc ✔") : plainMode ? "Waiting - flow " + str.tostring(domScore) + "/6" + (gateLoc ? ", at a zone" : ", not at an entry zone") : "wait · OF " + str.tostring(domScore) + "/6" + (gateOF ? " ✔" : " ✘") + " · loc" + (gateLoc ? " ✔" : " ✘")
    dash.cell(0, 16, plainMode ? "Signal check" : "Gates", text_color = colGray, text_size = dashTxtSize)
    dash.cell(1, 16, t16, text_color = gateOF and gateLoc ? (domBull ? colBuy : colSell) : colGray, text_size = dashTxtSize)
````

# Futures Session TWAP + Bands - CFD Charts

- url: https://www.tradingview.com/script/11LAHezr/
- type: indicator
- pine_id: PUB;bb08905778044d3db0000dd7258ce3a0
- version: 1.0

## Description

An anchored TWAP (time-weighted average price) with 1/2/3-sigma bands that
knows when the real market is actually open — built for CFD and cash-index
charts whose 24h quotes distort classic session averages.

What makes it original: a TWAP weighs every bar equally, so on a 24h CFD chart
the thin overnight bars count as much as the liquid session and drag the line
away from the number execution desks reference. This indicator pulls the
volume of the auto-detected futures contract and uses it as a SESSION GATE:
only bars where the future actually traded are counted. It also plots an
optional futures-volume VWAP on the same anchor, so the TWAP-vs-VWAP spread
becomes readable at a glance — that spread is the point of the pair.

How it works:
- TWAP = equal-weight average of the chart's price (hlc3 by default) over the
  anchor period (session/week/month); bands from the time-weighted variance.
- Session gate (optional, on by default): bars without futures volume are
  skipped, so the TWAP covers the real trading session. Only session/volume
  information is borrowed from the future — the price stays this chart's
  price, so the futures-vs-cash basis cannot distort the level.
- The futures contract is auto-detected from the chart symbol (DAX/GER40 ->
  FDAX, NAS100 -> NQ, US30 -> YM, UK100 -> Z, US500 -> ES), or set manually.
- Optional "Daily anchor = futures trading day" resets at the futures day
  change instead of CFD broker midnight, matching the sibling VWAP tool.
- A status label shows the active source, the gate state and the current
  VWAP-minus-TWAP spread.

How to use it: the TWAP is the fair time-average of the session — the line an
evenly-sliced execution would achieve. Compare it with the futures-volume
VWAP: VWAP above TWAP means volume was concentrated above the time average
(participants paid up), VWAP below TWAP means volume traded below it. The two
lines glued together signals balanced rotation; a widening spread marks
one-sided participation. The 2/3-sigma bands frame statistically stretched
zones relative to the session mean. Check the status label once after loading
to confirm the futures feed is active.

*This script is part of a consistent set of open-source session, range and
volume tools — the companions are on my profile.*

## Source Code

````pine
//@version=6
// TWAP + STANDARD-DEVIATION BANDS — futures-session aware, for CFD charts
// TWAP = time-weighted average price: every counted bar weighs the same,
// volume does NOT enter the average (that is the definition of TWAP).
// Real futures volume is used for two things it is actually good for here:
//   1) SESSION GATE: on 24h CFD charts, only bars where the matching futures
//      contract actually traded are counted — otherwise the thin overnight
//      CFD bars flood a session TWAP and drag it away from the number the
//      futures/institutional world references.
//   2) Optional FUTURES-VOLUME VWAP comparison line: the TWAP-vs-VWAP spread
//      shows whether volume was done above or below the time average
//      (VWAP > TWAP -> volume concentrated at higher prices, and vice versa).
// Price is always THIS chart's price (CFD) — only volume/session info is
// borrowed from the future, so the futures-vs-cash basis never distorts levels.
// Sibling tool: vwap_stdev_futurevol.pine (same symbol map, same anchors).
indicator("Futures Session TWAP + Bands — CFD Charts", shorttitle = "Fut TWAP", overlay = true)

anchorIn = input.string("Session (day)", "Anchor",
     options = ["Session (day)", "Week", "Month"], group = "TWAP")
srcIn    = input.source(hlc3, "Price source", group = "TWAP")
gateIn   = input.bool(true, "Count only bars with futures volume", group = "TWAP",
     tooltip = "Session gate: bars where the futures contract did not trade (overnight CFD hours) are skipped. Off = every chart bar counts (classic TWAP).")
volMode  = input.string("Futures symbol", "Futures data source",
     options = ["Chart (CFD)", "Futures symbol"], group = "Volume",
     tooltip = "Futures = real exchange volume via request.security (for the session gate and the VWAP comparison line). Chart = this chart's own volume (use on a native futures chart).")
autoFut  = input.bool(true, "Auto-detect futures symbol", group = "Volume")
futMan   = input.symbol("EUREX:FDAX1!", "…manual otherwise", group = "Volume")

f_detectFut() =>
    s = str.lower(syminfo.ticker) + " " + str.lower(syminfo.prefix) + " " + str.lower(syminfo.description)
    isNQ  = str.contains(s, "nas") or str.contains(s, "ndx") or str.contains(s, "us100") or str.contains(s, "ustec") or str.contains(s, "tech100") or str.contains(s, "nq1") or str.contains(s, "nq!")
    isYM  = str.contains(s, "dow") or str.contains(s, "us30") or str.contains(s, "dji") or str.contains(s, "ym1") or str.contains(s, "ym!") or str.contains(s, "wall street")
    isDAX = str.contains(s, "dax") or str.contains(s, "ger40") or str.contains(s, "de40") or str.contains(s, "german")
    isFTSE = str.contains(s, "ftse") or str.contains(s, "uk100") or str.contains(s, "ukx")
    isES  = str.contains(s, "us500") or str.contains(s, "sp500") or str.contains(s, "spx") or str.contains(s, "s&p") or str.contains(s, "es1") or str.contains(s, "es!")
    isDAX ? "EUREX:FDAX1!" : isFTSE ? "ICEEUR:Z1!" : isNQ ? "CME_MINI:NQ1!" :
     isYM ? "CBOT_MINI:YM1!" : isES ? "CME_MINI:ES1!" : syminfo.tickerid

futSym   = autoFut ? f_detectFut() : futMan

showBands = input.bool(true,  "Show std-dev bands", group = "Bands")
m1 = input.float(1.0, "Band 1 (sigma)", step = 0.5, group = "Bands")
m2 = input.float(2.0, "Band 2 (sigma)", step = 0.5, group = "Bands")
m3 = input.float(3.0, "Band 3 (sigma)", step = 0.5, group = "Bands")

showVwap = input.bool(true, "Show futures-volume VWAP (comparison)", group = "VWAP compare",
     tooltip = "Same anchor, volume-weighted. The TWAP-vs-VWAP spread shows whether volume traded above or below the time average.")

// --- fetch futures volume ---
// NO silent fallback to chart volume: CFD tick volume and futures contracts
// are different units. Bars without futures data are treated as "no futures
// trading" (gate skips them; VWAP sums add zero weight).
futVol = request.security(futSym, timeframe.period, volume, ignore_invalid_symbol = true)
useFut = volMode == "Futures symbol"
vol    = useFut ? futVol : volume

// --- anchor reset (identical mechanic to the sibling VWAP tool) ---
futDayAnk = input.bool(true, "Daily anchor = futures trading day", group = "TWAP",
     tooltip = "Resets at the FUTURES day change instead of the chart symbol's midnight, so the TWAP is anchored identically on CFD and futures charts.")
res  = anchorIn == "Week" ? "W" : anchorIn == "Month" ? "M" : "D"
futDayT = request.security(futSym, "D", time, ignore_invalid_symbol = true)
futDayChg = nz(ta.change(futDayT)) != 0
newP = res == "D" and futDayAnk and useFut ? futDayChg : timeframe.change(res)

var float sumP   = 0.0   // TWAP: sum of prices (weight 1 per counted bar)
var float sumN   = 0.0   // TWAP: counted bars
var float sumP2  = 0.0   // TWAP: sum of squared prices (bands)
var float sumPV  = 0.0   // VWAP compare: price x volume
var float sumV   = 0.0   // VWAP compare: volume
if newP or bar_index == 0
    sumP   := 0.0
    sumN   := 0.0
    sumP2  := 0.0
    sumPV  := 0.0
    sumV   := 0.0

v = nz(vol)
counted = not gateIn or not useFut or v > 0
if counted
    sumP  += srcIn
    sumN  += 1.0
    sumP2 += srcIn * srcIn
sumPV += srcIn * v
sumV  += v

twap = sumN > 0 ? sumP / sumN : na
varc = sumN > 0 ? math.max(sumP2 / sumN - twap * twap, 0.0) : 0.0
dev  = math.sqrt(varc)
vwapC = sumV > 0 ? sumPV / sumV : na

// --- Plots ---
pT = plot(twap, "TWAP", color = color.new(color.teal, 0), linewidth = 2)
plot(showVwap ? vwapC : na, "Fut-Vol VWAP (compare)",
     color = color.new(color.orange, 30), linewidth = 1)

u1 = twap + m1 * dev
l1 = twap - m1 * dev
u2 = twap + m2 * dev
l2 = twap - m2 * dev
u3 = twap + m3 * dev
l3 = twap - m3 * dev

pu1 = plot(showBands ? u1 : na, "+1σ", color = color.new(color.gray, 40))
pl1 = plot(showBands ? l1 : na, "-1σ", color = color.new(color.gray, 40))
pu2 = plot(showBands ? u2 : na, "+2σ", color = color.new(color.gray, 55))
pl2 = plot(showBands ? l2 : na, "-2σ", color = color.new(color.gray, 55))
plot(showBands ? u3 : na, "+3σ", color = color.new(color.gray, 70), style = plot.style_circles)
plot(showBands ? l3 : na, "-3σ", color = color.new(color.gray, 70), style = plot.style_circles)

fill(pu1, pl1, color = color.new(color.teal, 92))
fill(pu2, pu1, color = color.new(color.blue, 94))
fill(pl1, pl2, color = color.new(color.blue, 94))

// --- status label: source, gate state, TWAP-vs-VWAP spread ---
if barstate.islast
    sprd = not na(vwapC) and not na(twap) ? vwapC - twap : na
    txt = (useFut ? "Futures: " + futSym + (na(futVol) ? " (NO DATA - gate inactive on such bars)" : " ✓")
                  : "Chart volume (CFD)")
         + (gateIn and useFut ? "\nGate: only bars with futures trading" : "\nGate: off (all bars count)")
         + (not na(sprd) ? "\nVWAP-TWAP spread: " + str.tostring(sprd, format.mintick)
              + (sprd > 0 ? "  (volume above time avg)" : sprd < 0 ? "  (volume below time avg)" : "") : "")
    label.new(bar_index, twap, txt, style = label.style_label_left,
         color = color.new(color.black, 20), textcolor = color.white, size = size.small)
````

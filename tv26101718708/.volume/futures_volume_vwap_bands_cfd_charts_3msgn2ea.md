# Futures Volume VWAP + Bands - CFD Charts

- url: https://www.tradingview.com/script/3mSgn2ea/
- type: indicator
- pine_id: PUB;ca295c8b310a4014a51e5023bc438a70
- version: 1.0

## Description

A session/week/month-anchored VWAP with 1/2/3-sigma bands — with a twist for
CFD traders: the VWAP weighting can use REAL futures exchange volume instead
of broker tick volume.

What makes it original: this is not another VWAP variant — the weighting
source is the auto-detected futures contract while the price stays the CFD's,
bars without futures data are excluded instead of silently falling back to
tick volume, and the daily anchor can follow the futures trading day so the
VWAP matches across CFD and native futures charts.

How it works:
- Price source is this chart's CFD price (hlc3 by default); the weight is the
  volume of the auto-detected futures contract (request.security). Because
  only the WEIGHT comes from the future, the basis offset between CFD and
  futures prices is handled naturally.
- Bands are computed from the volume-weighted variance around the VWAP.
- Optional "Daily anchor = futures trading day" resets the calculation at the
  futures day change instead of CFD broker midnight, so the VWAP matches
  across CFD and native futures charts.
- Bars without futures data do not enter the sums; a status label always
  shows which volume source is active.

How to use it: the standard VWAP playbook applies — price above a rising VWAP
supports longs, reversion trades target the VWAP, and the 2/3-sigma bands mark
statistically stretched zones where momentum entries have poor expectancy. The
difference is that these levels are weighted by real market participation, so
they match what futures traders see instead of broker tick noise. Check the
status label once after loading to confirm the futures feed is active.

## Source Code

````pine
//@version=6
// VWAP + STANDARD-DEVIATION BANDS — with an optional FUTURES volume source
// Runs on a CFD chart but can pull REAL exchange volume from the matching
// futures contract (request.security). Price = CFD (hlc3), weight = futures
// volume -> the basis offset solves itself (the VWAP uses the CFD price).
// Anchor: session / week / month. Bands at 1/2/3 sigma.
indicator("Futures Volume VWAP + Bands — CFD Charts", shorttitle = "Fut Vol VWAP", overlay = true)

anchorIn = input.string("Session (day)", "Anchor",
     options = ["Session (day)", "Week", "Month"], group = "VWAP")
srcIn    = input.source(hlc3, "Price source", group = "VWAP")
volMode  = input.string("Futures symbol", "Volume source",
     options = ["Chart (CFD)", "Futures symbol"], group = "Volume",
     tooltip = "Futures = real exchange volume via request.security. The price stays this chart's CFD price. Chart = this chart's own volume (use on a native futures chart).")
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

// --- fetch futures volume ---
// NO silent fallback to chart volume: CFD tick volume and futures contracts
// are different units — mixing them floods the overnight bars of a 24h CFD
// with meaningless weights (divergence vs. the native futures chart).
// Bars without futures data simply do not count (nz(vol) = 0 in the sums).
futVol = request.security(futSym, timeframe.period, volume, ignore_invalid_symbol = true)
useFut = volMode == "Futures symbol"
vol    = useFut ? futVol : volume

// --- anchor reset ---
// Optional futures-trading-day anchor: timeframe.change("D") fires at the
// CFD broker's midnight but at the session start on the futures chart ->
// different accumulation windows on the two chart types.
futDayAnk = input.bool(true, "Daily anchor = futures trading day", group = "VWAP",
     tooltip = "Resets at the FUTURES day change instead of the chart symbol's midnight, so the VWAP is anchored identically on CFD and futures charts.")
res  = anchorIn == "Week" ? "W" : anchorIn == "Month" ? "M" : "D"
futDayT = request.security(futSym, "D", time, ignore_invalid_symbol = true)
futDayChg = nz(ta.change(futDayT)) != 0
newP = res == "D" and futDayAnk and useFut ? futDayChg : timeframe.change(res)

var float sumPV  = 0.0
var float sumV   = 0.0
var float sumP2V = 0.0
if newP or bar_index == 0
    sumPV  := 0.0
    sumV   := 0.0
    sumP2V := 0.0

v = nz(vol)
sumPV  += srcIn * v
sumV   += v
sumP2V += srcIn * srcIn * v

vwap = sumV > 0 ? sumPV / sumV : na
varc = sumV > 0 ? math.max(sumP2V / sumV - vwap * vwap, 0.0) : 0.0
dev  = math.sqrt(varc)

// --- Plots ---
pV = plot(vwap, "VWAP", color = color.new(color.orange, 0), linewidth = 2)

u1 = vwap + m1 * dev
l1 = vwap - m1 * dev
u2 = vwap + m2 * dev
l2 = vwap - m2 * dev
u3 = vwap + m3 * dev
l3 = vwap - m3 * dev

pu1 = plot(showBands ? u1 : na, "‑1σ", color = color.new(color.gray, 40))
pl1 = plot(showBands ? l1 : na, "‑1σ", color = color.new(color.gray, 40))
pu2 = plot(showBands ? u2 : na, "‑2σ", color = color.new(color.gray, 55))
pl2 = plot(showBands ? l2 : na, "‑2σ", color = color.new(color.gray, 55))
plot(showBands ? u3 : na, "‑3σ", color = color.new(color.gray, 70), style = plot.style_circles)
plot(showBands ? l3 : na, "‑3σ", color = color.new(color.gray, 70), style = plot.style_circles)

fill(pu1, pl1, color = color.new(color.orange, 92))
fill(pu2, pu1, color = color.new(color.blue, 94))
fill(pl1, pl2, color = color.new(color.blue, 94))

// --- status label: confirms which volume source is active ---
if barstate.islast
    txt = (useFut ? "Futures volume: " + futSym + (na(futVol) ? " (NO DATA - bars without futures volume do NOT count)" : " ✓")
                  : "Chart volume (CFD)")
    label.new(bar_index, vwap, txt, style = label.style_label_left,
         color = color.new(color.black, 20), textcolor = color.white, size = size.small)
````

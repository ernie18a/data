# Pressure Fatigue Index [PFI] v3

- url: https://www.tradingview.com/script/yQD7j9gz-Pressure-Fatigue-Index-PFI-v3/
- type: indicator
- pine_id: PUB;8f0a84c1126c43c384d980e3a8f5abf4
- version: 1.0

## Description

Pressure Fatigue Index (PFI)

OVERVIEW

The Pressure Fatigue Index is a bounded oscillator that reads from 0 to 100. Low readings mean oversold and high readings mean overbought, the same orientation you already know from RSI. That is where the resemblance ends. PFI does not use the average gain versus average loss ratio that RSI is built on. It reads a completely separate stream of information, namely where price settles inside each bar and how forceful that bar was, and it adds a fatigue mechanism that keeps the oscillator from pinning at an extreme for long stretches. That pinning behavior is the single most common frustration with RSI in trending markets, and removing it is the whole point of this tool.

HOW THE READING IS BUILT

For every bar, PFI measures where the close finished inside that bar's own range. A close near the high produces a positive value, a close near the low produces a negative value, and the exact middle of the bar is zero. In plain terms the raw bar value is twice the close, minus the high, minus the low, all divided by the range of the bar.

That location is then weighted by the size of the bar relative to recent volatility, using its true range compared with ATR. A wide conviction bar counts far more than a narrow indecisive one, so a big committed push moves the reading while chop barely registers.

Those weighted values are smoothed with a Wilder average into a running charge, and the charge is passed through a smooth squashing curve, a hyperbolic tangent, that maps it cleanly onto the 0 to 100 scale. The outcome is an oscillator that responds to genuine intrabar buying and selling pressure rather than to close to close drift.

THE FATIGUE MECHANIC

This is what separates PFI from every standard oscillator. While the reading sits beyond your overbought or oversold level, a hidden fatigue term builds up, and it builds faster the deeper the reading has pushed into the extreme. That fatigue then compresses the plotted line back toward the midline. To hold a value pinned at 85 the market would have to supply constantly accelerating fresh pressure, which real markets cannot sustain, so an extended run simply sags the line out of the zone on its own. The moment the reading leaves the extreme, fatigue releases and full sensitivity returns. Fatigue is driven by the underlying raw reading rather than the visible plotted line, so there is no threshold flutter and no repainting.

THE RAW GHOST LINE

PFI plots two lines. The bold purple line is the fatigue compressed reading you trade from. The faint gray ghost line behind it is the raw pressure before fatigue is applied. The distance between the two is itself information. When the ghost is still pinned deep in a zone while the purple line sags away from it, the move is still strong and it is not yet time to fade. When both lines roll out of the zone together, the exhaustion is real. The gap between them also drives the signal engine described below.

THE SIGNAL ENGINE

The buy and sell markers are built to catch turns at the actual low and high, not to fire every time a line touches a level. A signal is the end of a short sequence rather than a single condition, and each side can fire only once per cycle.

A buy requires the following to line up in order. First, a flush bar must occur while the raw reading is oversold, meaning a bar that is unusually wide relative to ATR and that closes down at the bottom of its own range. That is the panic capitulation that tends to mark bottoms, and it is marked on the pane with a small dot. Second, the episode must be mature, meaning the gap between the ghost and the purple line has grown wide enough to prove the move was both deep and sustained. Third, the trigger bar itself must be a conviction reversal, a bar with real size that closes up near the top of its range while the reading turns back up near the zone. In short, sellers pressed hard, exhausted themselves on a flush, and buyers just took the first decisive bar back.

Sells are the exact mirror. A euphoric blowoff bar in the overbought zone, a mature episode, and then a heavy rejection bar near the high.

After a signal fires, that side locks and cannot fire again until the reading passes back through the midline, so a single messy bottoming or topping process produces one marker rather than a cluster. A cooldown allows a second attempt only if a fresh, deeper flush develops.

There is also an optional divergence filter. When enabled, a buy also requires price to print a new low for the episode while the pressure reading makes a higher low, the classic bottoming tell. It is off by default because it screens out clean sharp reversals that have no divergence, but you can enable it when you only want the highest conviction fades.

INPUTS

Core sets the price source, the pressure length, the volatility length, and the sensitivity that controls how easily the reading reaches its extremes.

Zones set your overbought and oversold levels.

Fatigue exposes the build rate, the release rate, and the impact, so you can tune how quickly the oscillator tires and recovers and how hard it is pulled back toward the middle.

Signals expose the arm gap, the flush bar strictness, the trigger bar strictness, the near zone buffer, the optional divergence filter, and the re signal cooldown.

Smoothing gives you a moving average over the oscillator with the same menu as the built in RSI, including SMA, EMA, SMMA, WMA, VWMA, and an SMA option with Bollinger Bands.

HOW TO USE IT

Treat the purple line the way you would treat any oscillator, with low as oversold and high as overbought, but trust it to leave the zone on its own rather than staying stuck. Use the ghost line and its distance from the purple line to judge whether a move is still strong or genuinely tiring. Take the triangle markers as your prepared fade entries, and remember that each side fires once per cycle by design. If you want more markers on a fast timeframe, loosen the flush range first, then the arm gap, then the trigger close location. If you want fewer and stronger markers, do the reverse and consider enabling the divergence filter.

Set your alerts to fire once per bar close, since the live bar can move before it settles.

NOTE

This tool is offered for research and education. It is not financial advice. Test it on your own markets and timeframes and manage your own risk before trading it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
indicator("Pressure Fatigue Index [PFI] v3", shorttitle="PFI", overlay=false, precision=2)

// ═══ Core ═══
src     = input.source(close, "Source", group="Core")
lenP    = input.int(14, "Pressure Length", minval=2, group="Core")
lenV    = input.int(14, "Volatility Length", minval=2, group="Core")
sens    = input.float(0.25, "Sensitivity", minval=0.01, step=0.05, group="Core")

// ═══ Zones ═══
obLvl   = input.float(70, "Overbought", minval=50, maxval=99, group="Zones")
osLvl   = input.float(30, "Oversold", minval=1, maxval=50, group="Zones")

// ═══ Fatigue ═══
fatGain = input.float(0.08, "Fatigue Build Rate", minval=0.0, step=0.01, group="Fatigue")
fatRel  = input.float(0.85, "Fatigue Release", minval=0.0, maxval=0.99, step=0.01, group="Fatigue")
fatImp  = input.float(1.0, "Fatigue Impact", minval=0.1, step=0.1, group="Fatigue")
showRaw = input.bool(true, "Show Raw Ghost Line", group="Fatigue")

// ═══ Signals ═══
gapMin  = input.float(4.0, "Arm Gap (Gray vs Purple, pts)", minval=0.0, step=0.5, group="Signals")
capW    = input.float(1.5, "Flush Bar Range (xATR)", minval=0.5, step=0.1, group="Signals")
capQ    = input.float(0.5, "Flush Bar Close Loc (0-1)", minval=0.1, maxval=1.0, step=0.05, group="Signals")
qTrig   = input.float(0.5, "Trigger Bar Close Loc (0-1)", minval=0.1, maxval=1.0, step=0.05, group="Signals")
wTrig   = input.float(1.0, "Trigger Bar Range (xATR)", minval=0.3, step=0.1, group="Signals")
nearBuf = input.float(8.0, "Near-Zone Buffer (pts)", minval=0.0, step=1.0, group="Signals")
useDiv  = input.bool(false, "Require Price Divergence", group="Signals")
divMin  = input.float(1.0, "Divergence Min (pts)", minval=0.0, step=0.5, group="Signals")
coolBars = input.int(25, "Re-Signal Cooldown (bars)", minval=1, group="Signals")

// ═══ Smoothing (parity with built-in RSI) ═══
maType  = input.string("None", "MA Type", options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"], group="Smoothing")
maLen   = input.int(14, "MA Length", minval=1, group="Smoothing")
bbMult  = input.float(2.0, "BB StdDev", minval=0.1, step=0.1, group="Smoothing")

// ═══ Engine ═══
rng    = high - low
atrV   = ta.atr(lenV)
qBar   = rng > 0 ? (2.0 * src - high - low) / rng : 0.0
wBar   = atrV > 0 ? math.min(rng / atrV, 3.0) : 1.0
charge = ta.rma(qBar * wBar, lenP)
x2     = math.min(math.max(2.0 * charge / sens, -40.0), 40.0)
e2     = math.exp(x2)
pre    = 50.0 + 50.0 * (e2 - 1.0) / (e2 + 1.0)
inOB   = pre > obLvl
inOS   = pre < osLvl
press  = inOB ? (pre - obLvl) / math.max(100.0 - obLvl, 1.0) : inOS ? (osLvl - pre) / math.max(osLvl, 1.0) : 0.0
var float fat = 0.0
fat   := inOB or inOS ? math.min(fat + press * fatGain, 4.0) : fat * fatRel
pfi    = 50.0 + (pre - 50.0) * math.exp(-fat * fatImp)

// ═══ Episode Tracking (all latches reset when raw crosses 50) ═══
gapL = pfi - pre
gapS = pre - pfi
var float epLoPre = na
var float epLoPx  = na
var float epHiPre = na
var float epHiPx  = na
divBarL = pre < osLvl and not na(epLoPx) and low <= epLoPx and pre > epLoPre + divMin
divBarS = pre > obLvl and not na(epHiPx) and high >= epHiPx and pre < epHiPre - divMin
epLoPre := pre >= 50 ? na : pre < osLvl ? (na(epLoPre) ? pre : math.min(epLoPre, pre)) : epLoPre
epLoPx  := pre >= 50 ? na : pre < osLvl ? (na(epLoPx) ? low : math.min(epLoPx, low)) : epLoPx
epHiPre := pre <= 50 ? na : pre > obLvl ? (na(epHiPre) ? pre : math.max(epHiPre, pre)) : epHiPre
epHiPx  := pre <= 50 ? na : pre > obLvl ? (na(epHiPx) ? high : math.max(epHiPx, high)) : epHiPx
capBarL = pre < osLvl and wBar >= capW and qBar <= -capQ
capBarS = pre > obLvl and wBar >= capW and qBar >= capQ
var bool capL = false
var bool capS = false
var bool divL = false
var bool divS = false
var bool armL = false
var bool armS = false
capL := pre >= 50 ? false : capL or capBarL
capS := pre <= 50 ? false : capS or capBarS
divL := pre >= 50 ? false : divL or divBarL
divS := pre <= 50 ? false : divS or divBarS
armL := pre >= 50 ? false : armL or (pre < osLvl and gapL >= gapMin)
armS := pre <= 50 ? false : armS or (pre > obLvl and gapS >= gapMin)

// ═══ Trigger: flush -> conviction reclaim, one shot per cycle ═══
var bool lockL = false
var bool lockS = false
var int  coolL = 0
var int  coolS = 0
convL   = qBar >= qTrig and wBar >= wTrig and pre > pre[1]
convS   = qBar <= -qTrig and wBar >= wTrig and pre < pre[1]
nearL   = pre <= osLvl + nearBuf
nearS   = pre >= obLvl - nearBuf
buySig  = armL and capL and convL and nearL and not lockL and (not useDiv or divL)
sellSig = armS and capS and convS and nearS and not lockS and (not useDiv or divS)
coolL  := buySig ? coolBars : math.max(coolL - 1, 0)
coolS  := sellSig ? coolBars : math.max(coolS - 1, 0)
lockL  := buySig ? true : pre >= 50 or coolL == 0 ? false : lockL
lockS  := sellSig ? true : pre <= 50 or coolS == 0 ? false : lockS

// ═══ MA Selection ═══
maSma  = ta.sma(pfi, maLen)
maEma  = ta.ema(pfi, maLen)
maRma  = ta.rma(pfi, maLen)
maWma  = ta.wma(pfi, maLen)
maVwma = ta.vwma(pfi, maLen)
isBB   = maType == "SMA + Bollinger Bands"
bbSd   = ta.stdev(pfi, maLen) * bbMult
maVal  = maType == "SMA" or isBB ? maSma : maType == "EMA" ? maEma : maType == "SMMA (RMA)" ? maRma : maType == "WMA" ? maWma : maType == "VWMA" ? maVwma : na

// ═══ Plots ═══
ghostCol = armL ? color.new(color.teal, 25) : armS ? color.new(color.orange, 25) : color.new(color.gray, 55)
plot(showRaw ? pre : na, "Raw Pressure (Ghost)", color=ghostCol, linewidth=1)
plot(pfi, "PFI", color=#7E57C2, linewidth=2)
plot(maVal, "PFI MA", color=color.new(color.yellow, 0), linewidth=1)
pU = plot(isBB ? maSma + bbSd : na, "BB Upper", color=color.new(color.green, 55))
pL = plot(isBB ? maSma - bbSd : na, "BB Lower", color=color.new(color.green, 55))
fill(pU, pL, color=color.new(color.green, 92), title="BB Fill")
hOB  = hline(obLvl, "Overbought", color=color.new(color.gray, 50))
hMid = hline(50, "Middle", color=color.new(color.gray, 75), linestyle=hline.style_dotted)
hOS  = hline(osLvl, "Oversold", color=color.new(color.gray, 50))
fill(hOB, hOS, color=color.new(#7E57C2, 94), title="Band Fill")
plotshape(capBarL, "Flush Bar", style=shape.circle, location=location.bottom, color=color.new(color.gray, 40), size=size.tiny)
plotshape(capBarS, "Blowoff Bar", style=shape.circle, location=location.top, color=color.new(color.gray, 40), size=size.tiny)
plotshape(buySig, "Buy", style=shape.triangleup, location=location.bottom, color=color.new(color.green, 0), size=size.small)
plotshape(sellSig, "Sell", style=shape.triangledown, location=location.top, color=color.new(color.red, 0), size=size.small)
bgcolor(buySig ? color.new(color.green, 88) : sellSig ? color.new(color.red, 88) : na, title="Signal Flash")

// ═══ Alerts ═══
alertcondition(buySig, "PFI Buy", "PFI Buy — flush and conviction reclaim at the low")
alertcondition(sellSig, "PFI Sell", "PFI Sell — blowoff and conviction rejection at the high")
alertcondition(ta.crossover(pfi, 50), "PFI Bull Cross 50", "PFI crossed above 50")
alertcondition(ta.crossunder(pfi, 50), "PFI Bear Cross 50", "PFI crossed below 50")
````

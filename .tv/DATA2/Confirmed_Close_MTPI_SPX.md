<!-- tradingview-pine-id: PUB;11aa4bc677634352ba8a32d020b33d6c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Confirmed Close MTPI SPX

Source: https://www.tradingview.com/script/KGyUf2R4-Confirmed-Close-MTPI-SPX/

## Description

CONFIRMED CLOSE MTPI SPX

WHAT THIS IS

This is a trend indicator for the S&P 500. It answers one question: is the
index in an uptrend or a downtrend right now?

It does that by running twelve separate trend indicators at once and taking a
vote. Each of the twelve looks at the chart in its own way and says either
"up" or "down". The score you see is simply the average of those twelve votes.
All twelve agreeing up gives +1.00. All twelve agreeing down gives -1.00. Six
against six gives 0.00.

Because twelve votes average out, the score can only land on thirteen values,
one sixth apart: -1.00, -0.83, -0.67 and so on up to +1.00.

This approach is usually called a Trend Probability Indicator, or TPI. The
point is that no single indicator is reliable on its own. Any one of them will
whipsaw you. A group of twelve disagreeing with each other is information, and
the score tells you how much of that group agrees.

WHY "CONFIRMED CLOSE"

A lot of indicators change their mind while the current candle is still
forming, then change back before it closes. That is called repainting and it
makes an indicator untradeable, because the signal you acted on may not be
there an hour later.

This one does not do that. While today's candle is still open, the indicator
shows you yesterday's confirmed reading. The state only changes when a daily
candle actually closes. What you see is what you could have traded.

On an index this matters more than it does on a 24 hour market. A US equity
session runs for six and a half hours and the index can travel a long way
inside one of them. A reading taken at 11am is a reading of an unfinished
candle. This script will not give you one.

HOW TO READ IT

On the price chart:

- Candles are painted cyan while the score is above zero and magenta while it
  is below. This is the state, at a glance.
- A cyan triangle with the word BULLISH below it marks the candle where the
  score turned positive. A magenta triangle with BEARISH above it marks the
  turn down. These are the moments that matter.
- Two moving averages, a 12 period and a 21 period EMA, are drawn as a
  reference. They are a crude version of the same question and they are there
  so you can see how much smoother the twelve indicator version is.
- Bars are tinted amber where the twelve indicator score and the simple 12/21
  cross disagree. Those are the bars where the crude version would have put
  you on the wrong side.

In the separate pane below:

- The stepped line is the score, from -1.00 to +1.00, filled to the zero line
  and coloured by state.
- Dotted lines at +0.5 and -0.5 give you a sense of how strong the agreement
  is. A score of +1.00 is twelve out of twelve. A score of +0.17 is seven
  against five, which is a trend barely holding together.

The dashboard, bottom right by default:

- The big number is the current score, with the state next to it.
- The bar beside it is a gauge. It fills outward from the middle, right and
  cyan for bullish, left and magenta for bearish.
- The twelve indicators are listed in two columns, the six trend-following
  ones on the left and the six oscillators on the right, each showing its own
  vote. This is where you see WHY the score is what it is.
- "12/21 agree" is the share of days where the twelve indicator score and the
  simple EMA cross pointed the same way, measured across all the history your
  chart has loaded. Read it as a rough measure of how often the crude version
  would have agreed with the careful one. It is measured against the raw cross
  with no filtering, so treat it as an indication rather than a precise
  statistic.
- "Regime" is how many days the current state has lasted. It turns amber below
  eight days, because a trend that has not lasted eight days has a habit of
  being noise.

A cyan and magenta pair was chosen on purpose rather than the usual green and
red. It separates on the blue and the red channel, so it stays readable with
red green colour blindness, and it tells this script apart from the others in
the set at a glance. If you would rather have green and red, there is a toggle
in the settings.

HOW TO USE IT

The simplest use is the one it was built for. When the score is above zero,
equities are in an uptrend and you hold them. When it is below zero, they are
not, and you do not. You act on the close, and you execute on the open of the
next session. Anything earlier is acting on a candle that has not finished
forming.

Set an alert if you do not want to watch it. The script exposes two alert
conditions, one for the turn up and one for the turn down, and both fire only
on a confirmed daily close.

Read the twelve rows when the score is near zero. A score of -0.67 that is
being held off the floor by two oscillators is a very different situation from
a -0.67 where the trend-following group is turning. The individual votes tell
you which one you are in.

THE WIDER SYSTEM THIS BELONGS TO

This indicator is one rung of a ladder. The idea is that you are always
holding the strongest available thing, and that the decision is made in steps
rather than all at once.

Step one. A TPI on the total crypto market cap. If it is positive, you stay in
crypto and you go to step two. If it is negative, you leave crypto and go to
step three.

Step two, only when crypto is bullish. An ETH/BTC ratio TPI decides which of
the two majors leads. From there a further layer of ratio TPIs compares mid
caps against whichever major won, and the ones that are outperforming get a
share of the book.

Step three, when crypto is bearish. A gold TPI. If gold is in an uptrend, that
is where the money sits.

Step four, when gold is not working either. This indicator. If equities are
trending up, that is the holding.

Step five, when nothing is trending. Cash, and a EUR/USD TPI decides whether
that cash is better held in euros or in dollars.

Each rung is its own TPI, built the same way: twelve indicators, one vote
each, tuned separately for that market. The ladder simply asks them in order.

This rung is the quiet one. In a long crypto bull market it never gets asked,
because the ladder stops at step one or two. It earns its place in the years
when crypto and gold are both dead and something still has to be held.

A SET, NOT A SINGLE SCRIPT

This is the fourth published piece of that set, after the total market cap, the
ETH/BTC ratio and gold. The remaining rung is built and running and will follow
as its own publication, reading the same way so you only have to learn the
layout once.

ABOUT THE SETTINGS

The twelve indicators and their periods are visible in the settings and in the
source. They were tuned for this specific market against a cleaned 12/21 EMA
reference on daily data from January 2023 onward, with regimes shorter than
eight days treated as noise and removed before the tuning was scored. The
symbol itself has daily history back to 2005 if you want to look further back.

Those numbers are right for the S&P 500. They are not automatically right for
anything else, and they are deliberately not the numbers the other scripts in
this set use. If you put this on another symbol, expect to retune. That is the
honest answer, and it is why each market in the set gets its own publication
rather than one script with a symbol dropdown.

Two of the twelve are read on a smoothed line rather than the raw one, which
is deliberate: the CCI is scored on its EMA 5 smoothing and the RSI on its
EMA 10. The Awesome Oscillator is scored on its raw line. Those choices are in
the code and commented.

HOW FAITHFUL THE REBUILD IS

Because seven of the twelve are rewritten from other people's published
formulas rather than called directly, the obvious question is whether they
behave the same. They do. Every one of the twelve votes was compared bar by bar
against the original indicator running on the same chart, across 5,365 daily
bars going back to May 2005. Zero disagreements on any of the twelve, and the
combined score matched on every single bar.

That check is worth repeating if you change a setting, and it is why each vote
is exposed as a hidden plot in the script rather than kept internal.

CREDIT WHERE IT IS DUE

Seven of the twelve components are reimplementations of open-source community
scripts, written from their published formulas so they could all live in one
indicator and be scored consistently. Full credit to the original authors:

- Gaussian Channel by DonovanWall
- Optimized Trend Tracker by KivancOzbilgic
- Awesome Oscillator v2 by KivancOzbilgic
- Hull Suite by InSilico
- SSL Channel by ErwinBeckers
- Coral Trend Indicator by LazyBear
- WaveTrend by LazyBear

The remaining five are standard: ALMA, CCI, RSI, Coppock Curve and the
Detrended Price Oscillator.

What is added here is the aggregation into a single score, the confirmed close
behaviour, the per indicator breakdown, the agreement measurement against the
reference, and the ladder logic this is built to serve.

LIMITATIONS AND A PLAIN WARNING

This is a trend indicator. It is late by design. It will not catch the exact
top or the exact bottom, and it is not supposed to. It will be wrong in a
sideways market, which is what the eight day regime warning is there to tell
you.

A negative reading does not mean the index is about to fall, and a positive one
does not mean it is about to rise. It reports what has already been happening.

Equities also carry something the other rungs do not: gaps. An index can close
on a confirmed uptrend and open several percent lower on news, and no daily
trend indicator will protect you from that. Size accordingly.

Nothing here is financial advice. It is a tool for reading a chart. Past
behaviour of any indicator tells you nothing reliable about the future. Do
your own work and size your positions so that being wrong is survivable.

---

## Source Code

````pine
//@version=6
// Confirmed Close MTPI SPX
// Twelve indicators, settings read from the "SPX TPI" study template on
// 2026-09-20. Same method as Confirmed Close MTPI TOTALES, tuned for the
// S&P 500: Coral Trend takes the perpetual slot and the Detrended Price
// Oscillator takes the oscillator one.
// Cyan is the bullish state, magenta is the bearish one.
// A green and red palette is available in the settings.
indicator("Confirmed Close MTPI SPX", shorttitle="CC SPX", overlay=false, precision=2, max_labels_count=500)

grpP = "Perpetual"
grpO = "Oscillator"
grpR = "Reference"
grpD = "Display"

gPeriod  = input.int(79,    "Gaussian period",        group=grpP)
ottLen   = input.int(33,    "OTT period (EMA)",       group=grpP)
ottPct   = input.float(0.4, "OTT percent",            group=grpP)
hullLen  = input.int(77,    "Hull Ehma length",       group=grpP)
sslLen   = input.int(45,    "SSL period",             group=grpP)
almaLen  = input.int(72,    "ALMA length",            group=grpP)
almaOff  = input.float(0.85,"ALMA offset",            group=grpP)
almaSig  = input.float(6,   "ALMA sigma",             group=grpP)
crSm     = input.int(22,    "Coral smoothing period", group=grpP)
crCd     = input.float(0.1, "Coral constant D",       group=grpP)

cciLen   = input.int(38,    "CCI length",             group=grpO)
cciSm    = input.int(5,     "CCI EMA smoothing",      group=grpO)
wtCh     = input.int(25,    "WaveTrend channel",      group=grpO)
wtAv     = input.int(11,    "WaveTrend average",      group=grpO)
aoFast   = input.int(4,     "AO fast",                group=grpO)
aoSlow   = input.int(41,    "AO slow",                group=grpO)
aoSig    = input.int(7,     "AO signal",              group=grpO)
rsiLen   = input.int(13,    "RSI length",             group=grpO)
rsiSm    = input.int(10,    "RSI EMA smoothing",      group=grpO)
copWma   = input.int(5,     "Coppock WMA",            group=grpO)
copLong  = input.int(30,    "Coppock long RoC",       group=grpO)
copShort = input.int(18,    "Coppock short RoC",      group=grpO)
dpoLen   = input.int(26,    "DPO length",             group=grpO)

refFast  = input.int(12,    "Reference fast EMA",     group=grpR)
refSlow  = input.int(21,    "Reference slow EMA",     group=grpR)
showEma  = input.bool(true, "Show the EMA cross on the chart", group=grpR)

useConf  = input.bool(true, "Confirmed close only",   group=grpD, tooltip="The forming candle shows the last confirmed state. Nothing repaints.")
paint    = input.string("Solid", "Candle painting", options=["Solid","Outline","Off"], group=grpD)
showFlip = input.bool(true, "Flip markers",           group=grpD)
markAtr  = input.float(2.5, "Marker distance (ATR)", minval=0, maxval=10, step=0.25, group=grpD)
showTbl  = input.bool(true, "Dashboard",              group=grpD)
posIn    = input.string("Bottom right", "Dashboard position", options=["Top left","Top centre","Top right","Middle left","Middle centre","Middle right","Bottom left","Bottom centre","Bottom right"], group=grpD)
szIn     = input.string("Small", "Dashboard text size", options=["Tiny","Small","Normal","Large"], group=grpD)
altPal   = input.bool(false, "Green and red palette", group=grpD, tooltip="Off is cyan for the uptrend and magenta for the downtrend. On is the usual green and red.")
showWarn = input.bool(true, "Tint bars where the MTPI and the 12/21 disagree", group=grpD)

tblPos = posIn == "Top left" ? position.top_left : posIn == "Top centre" ? position.top_center : posIn == "Top right" ? position.top_right : posIn == "Middle left" ? position.middle_left : posIn == "Middle centre" ? position.middle_center : posIn == "Middle right" ? position.middle_right : posIn == "Bottom left" ? position.bottom_left : posIn == "Bottom centre" ? position.bottom_center : position.bottom_right
szBig  = szIn == "Tiny" ? size.small : szIn == "Small" ? size.large : szIn == "Normal" ? size.large : size.huge
szMid  = szIn == "Tiny" ? size.tiny : szIn == "Small" ? size.small : szIn == "Normal" ? size.normal : size.large
szLow  = szIn == "Tiny" ? size.tiny : szIn == "Small" ? size.tiny : szIn == "Normal" ? size.small : size.normal

cBull = altPal ? #089981 : #26c6da
cBear = altPal ? #f23645 : #e91e63
cNeut = #787b86
// Amber reads clearly against both palettes here, so the tint does not switch.
cWarn = #ffa726
cPanel = #131722
cHead  = #1b2233
cGrid  = #2a2e39
cDim   = #6a6e79
cText  = #d1d4dc

gSrc  = hlc3
beta  = (1 - math.cos(4 * math.asin(1) / gPeriod)) / (math.pow(1.414, 2.0 / 2.0) - 1)
alpha = -beta + math.sqrt(beta * beta + 2 * beta)
float gFilt = na
gFilt := math.pow(alpha, 2) * gSrc + 2 * (1 - alpha) * nz(gFilt[1]) - math.pow(1 - alpha, 2) * nz(gFilt[2])
vGauss = gFilt > gFilt[1] ? 1 : -1

ottMa = ta.ema(close, ottLen)
fark  = ottMa * ottPct * 0.01
float longStop = na
longStop := ottMa > nz(longStop[1]) ? math.max(ottMa - fark, nz(longStop[1])) : ottMa - fark
float shortStop = na
shortStop := ottMa < nz(shortStop[1], ottMa + fark) ? math.min(ottMa + fark, nz(shortStop[1], ottMa + fark)) : ottMa + fark
var int ottDir = 1
ottDir := ottDir == -1 and ottMa > nz(shortStop[1]) ? 1 : ottDir == 1 and ottMa < nz(longStop[1]) ? -1 : ottDir
ottMT  = ottDir == 1 ? longStop : shortStop
ottVal = ottMa > ottMT ? ottMT * (200 + ottPct) / 200 : ottMT * (200 - ottPct) / 200
vOtt = ottMa > ottVal[2] ? 1 : -1

ehma = ta.ema(2 * ta.ema(close, int(hullLen / 2)) - ta.ema(close, hullLen), int(math.round(math.sqrt(hullLen))))
vHull = ehma > ehma[2] ? 1 : -1

smaH = ta.sma(high, sslLen)
smaL = ta.sma(low, sslLen)
var int hlv = 0
hlv := close > smaH ? 1 : close < smaL ? -1 : hlv
sslDown = hlv < 0 ? smaH : smaL
sslUp   = hlv < 0 ? smaL : smaH
vSsl = sslUp > sslDown ? 1 : -1

almaV = ta.alma(close, almaLen, almaOff, almaSig)
vAlma = almaV > almaV[1] ? 1 : -1

// Coral Trend Indicator, LazyBear's smoothing cascade, scored on the direction
// of its filter line against the previous bar.
crDi = (crSm - 1.0) / 2.0 + 1.0
crC1 = 2 / (crDi + 1.0)
crC2 = 1 - crC1
crC3 = 3.0 * (crCd * crCd + crCd * crCd * crCd)
crC4 = -3.0 * (2.0 * crCd * crCd + crCd + crCd * crCd * crCd)
crC5 = 3.0 * crCd + 1.0 + crCd * crCd * crCd + 3.0 * crCd * crCd
float ci1 = na
float ci2 = na
float ci3 = na
float ci4 = na
float ci5 = na
float ci6 = na
ci1 := crC1 * close + crC2 * nz(ci1[1])
ci2 := crC1 * ci1   + crC2 * nz(ci2[1])
ci3 := crC1 * ci2   + crC2 * nz(ci3[1])
ci4 := crC1 * ci3   + crC2 * nz(ci4[1])
ci5 := crC1 * ci4   + crC2 * nz(ci5[1])
ci6 := crC1 * ci5   + crC2 * nz(ci6[1])
coralV = -crCd * crCd * crCd * ci6 + crC3 * ci5 + crC4 * ci4 + crC5 * ci3
vCoral = coralV > coralV[1] ? 1 : -1

cciV = ta.ema(ta.cci(hlc3, cciLen), cciSm)
vCci = cciV > 0 ? 1 : -1

wtAp  = hlc3
wtEsa = ta.ema(wtAp, wtCh)
wtD   = ta.ema(math.abs(wtAp - wtEsa), wtCh)
wt1   = ta.ema((wtAp - wtEsa) / (0.015 * wtD), wtAv)
vWt = wt1 > 0 ? 1 : -1

// The AO study plots its SIGNAL as plot 0 and the RAW oscillator as plot 1,
// and the rule reads plot 1, so the raw line is what gets scored.
aoRaw  = ta.sma(hl2, aoFast) - ta.sma(hl2, aoSlow)
aoLine = ta.sma(aoRaw, aoSig)
vAo = aoRaw > 0 ? 1 : -1

rsiV = ta.ema(ta.rsi(close, rsiLen), rsiSm)
vRsi = rsiV > 50 ? 1 : -1

copV = ta.wma(ta.roc(close, copLong) + ta.roc(close, copShort), copWma)
vCop = copV > 0 ? 1 : -1

// Detrended Price Oscillator, not centred, which is the study's own default.
dpoBars = int(dpoLen / 2) + 1
dpoMa   = ta.sma(close, dpoLen)
dpoV    = close - dpoMa[dpoBars]
vDpo = dpoV > 0 ? 1 : -1

warm  = math.max(gPeriod, ottLen, hullLen, sslLen, almaLen, crSm, cciLen + cciSm, wtCh + wtAv, aoSlow + aoSig, rsiLen + rsiSm, copLong + copWma, dpoLen + dpoBars)
ready = bar_index >= warm and not na(coralV[1]) and not na(dpoV)
sumV  = vGauss + vOtt + vHull + vSsl + vAlma + vCoral + vCci + vWt + vAo + vRsi + vCop + vDpo
scoreRaw = ready ? sumV / 12.0 : na
score = useConf and not barstate.isconfirmed ? scoreRaw[1] : scoreRaw

st = score > 0 ? 1 : score < 0 ? -1 : 0
stateCol = st > 0 ? cBull : st < 0 ? cBear : cNeut
stateTxt = st > 0 ? "BULLISH" : st < 0 ? "BEARISH" : "NEUTRAL"
var int ageBars = 0
ageBars := st != nz(st[1], st) ? 1 : ageBars + 1
young = ageBars < 8

flipUp = showFlip and st == 1 and nz(st[1], 0) != 1
flipDn = showFlip and st == -1 and nz(st[1], 0) != -1

emaF = ta.ema(close, refFast)
emaS = ta.ema(close, refSlow)
refState = emaF > emaS ? 1 : -1
emaCol = refState > 0 ? cBull : cBear
pEmaF = plot(showEma ? emaF : na, "EMA fast", color=color.new(emaCol, 20), linewidth=2, display=display.pane, force_overlay=true)
pEmaS = plot(showEma ? emaS : na, "EMA slow", color=color.new(cDim, 20), linewidth=1, display=display.pane, force_overlay=true)
fill(pEmaF, pEmaS, color=color.new(emaCol, 90), title="EMA cross")

var int nTot = 0
var int nAgr = 0
counted = not na(score) and barstate.isconfirmed
nTot := counted ? nTot + 1 : nTot
nAgr := counted and ((score > 0 and refState == 1) or (score < 0 and refState == -1)) ? nAgr + 1 : nAgr
agree = nTot > 0 ? 100.0 * nAgr / nTot : na

pScore = plot(score, "Score", color=stateCol, linewidth=2, style=plot.style_stepline, display=display.pane + display.status_line + display.price_scale)
pZero  = plot(0, "Zero base", color=color.new(cGrid, 100), display=display.none, editable=false)
fill(pScore, pZero, color=color.new(stateCol, 85))
hline(0, "Zero", color=color.new(cDim, 30))
hline(0.5, "+0.5", color=color.new(cGrid, 0), linestyle=hline.style_dotted)
hline(-0.5, "-0.5", color=color.new(cGrid, 0), linestyle=hline.style_dotted)
plot(refState * 0.08, "Reference 12/21", color=color.new(cDim, 45), style=plot.style_stepline, display=display.pane)

solid = paint == "Solid"
barcolor(paint != "Off" ? stateCol : na, title="MTPI bar colour")
plotcandle(solid ? open : na, solid ? high : na, solid ? low : na, solid ? close : na, title="MTPI candles", color=stateCol, wickcolor=stateCol, bordercolor=stateCol, display=display.pane, force_overlay=true)

atrMk = ta.atr(14)
mkUp = flipUp ? low - atrMk * markAtr : na
mkDn = flipDn ? high + atrMk * markAtr : na
plotshape(mkUp, title="Bullish flip", style=shape.triangleup, location=location.absolute, color=cBull, size=size.tiny, display=display.pane, force_overlay=true)
plotshape(mkDn, title="Bearish flip", style=shape.triangledown, location=location.absolute, color=cBear, size=size.tiny, display=display.pane, force_overlay=true)

if flipUp
    label.new(bar_index, mkUp - atrMk * 1.0, "BULLISH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=cBull, size=size.small, force_overlay=true)
if flipDn
    label.new(bar_index, mkDn + atrMk * 1.0, "BEARISH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=cBear, size=size.small, force_overlay=true)

disagree = not na(score) and st != 0 and ((st > 0 and refState < 0) or (st < 0 and refState > 0))
bgcolor(showWarn and disagree ? color.new(cWarn, 88) : na, title="MTPI and reference disagree", force_overlay=true)

alertcondition(flipUp, title="MTPI SPX turned bullish", message="MTPI SPX turned BULLISH on the confirmed close")
alertcondition(flipDn, title="MTPI SPX turned bearish", message="MTPI SPX turned BEARISH on the confirmed close")
if flipUp and barstate.isconfirmed
    alert("MTPI SPX turned BULLISH, score " + str.tostring(score, "0.00"), alert.freq_once_per_bar_close)
if flipDn and barstate.isconfirmed
    alert("MTPI SPX turned BEARISH, score " + str.tostring(score, "0.00"), alert.freq_once_per_bar_close)

vTxt(int v) => v > 0 ? "+1" : v < 0 ? "-1" : "0"
vCol(int v) => v > 0 ? cBull : v < 0 ? cBear : cNeut

gaugeStr(float s) =>
    n = int(math.round(math.abs(nz(s)) * 6))
    l = s < 0 ? n : 0
    r = s > 0 ? n : 0
    str.repeat("░", 6 - l) + str.repeat("█", l) + str.repeat("█", r) + str.repeat("░", 6 - r)

if showTbl and barstate.islast
    var table t = table.new(tblPos, 4, 11, bgcolor=color.new(cPanel, 0), frame_color=color.new(cGrid, 0), frame_width=1, border_color=color.new(cGrid, 0), border_width=1, force_overlay=true)
    table.cell(t, 0, 0, "CONFIRMED CLOSE MTPI", text_color=cText, text_size=szMid, text_halign=text.align_left, bgcolor=cHead)
    table.cell(t, 1, 0, "", bgcolor=cHead)
    table.cell(t, 2, 0, "", bgcolor=cHead)
    table.cell(t, 3, 0, "SPX", text_color=cDim, text_size=szMid, text_halign=text.align_right, bgcolor=cHead)
    table.cell(t, 0, 1, str.tostring(score, "+0.00;-0.00"), text_color=stateCol, text_size=szBig, text_halign=text.align_left)
    table.cell(t, 1, 1, stateTxt, text_color=stateCol, text_size=szMid, text_halign=text.align_left)
    table.cell(t, 2, 1, gaugeStr(score), text_color=stateCol, text_size=szMid, text_halign=text.align_center)
    table.cell(t, 3, 1, str.tostring((12 + sumV) / 2, "#") + "/12 up", text_color=cDim, text_size=szMid, text_halign=text.align_right)
    names1 = array.from("Gaussian", "OTT", "Hull", "SSL", "ALMA", "Coral")
    vals1  = array.from(vGauss, vOtt, vHull, vSsl, vAlma, vCoral)
    names2 = array.from("CCI", "WaveTrend", "AO", "RSI", "Coppock", "DPO")
    vals2  = array.from(vCci, vWt, vAo, vRsi, vCop, vDpo)
    table.cell(t, 0, 2, "PERPETUAL", text_color=cDim, text_size=szLow, text_halign=text.align_left)
    table.cell(t, 1, 2, "", text_size=szLow)
    table.cell(t, 2, 2, "OSCILLATOR", text_color=cDim, text_size=szLow, text_halign=text.align_left)
    table.cell(t, 3, 2, "", text_size=szLow)
    for i = 0 to 5
        table.cell(t, 0, i + 3, array.get(names1, i), text_color=cText, text_size=szMid, text_halign=text.align_left)
        table.cell(t, 1, i + 3, vTxt(array.get(vals1, i)), text_color=vCol(array.get(vals1, i)), text_size=szMid, text_halign=text.align_right)
        table.cell(t, 2, i + 3, array.get(names2, i), text_color=cText, text_size=szMid, text_halign=text.align_left)
        table.cell(t, 3, i + 3, vTxt(array.get(vals2, i)), text_color=vCol(array.get(vals2, i)), text_size=szMid, text_halign=text.align_right)
    table.cell(t, 0, 9, "12/21 agree", text_color=cDim, text_size=szLow, text_halign=text.align_left)
    table.cell(t, 1, 9, str.tostring(agree, "#.#") + "%", text_color=cText, text_size=szLow, text_halign=text.align_right)
    table.cell(t, 2, 9, "Reference", text_color=cDim, text_size=szLow, text_halign=text.align_left)
    table.cell(t, 3, 9, refState > 0 ? "bull" : "bear", text_color=vCol(refState), text_size=szLow, text_halign=text.align_right)
    table.cell(t, 0, 10, "Confirmed", text_color=cDim, text_size=szLow, text_halign=text.align_left)
    table.cell(t, 1, 10, str.format_time(useConf and not barstate.isconfirmed ? time[1] : time, "dd MMM", "UTC"), text_color=cDim, text_size=szLow, text_halign=text.align_right)
    table.cell(t, 2, 10, "Regime", text_color=cDim, text_size=szLow, text_halign=text.align_left)
    table.cell(t, 3, 10, str.tostring(ageBars) + "d", text_color=young ? cWarn : cDim, text_size=szLow, text_halign=text.align_right)

plot(vGauss, "v Gaussian", display=display.none)
plot(vOtt,   "v OTT",      display=display.none)
plot(vHull,  "v Hull",     display=display.none)
plot(vSsl,   "v SSL",      display=display.none)
plot(vAlma,  "v ALMA",     display=display.none)
plot(vCoral, "v Coral",    display=display.none)
plot(vCci,   "v CCI",      display=display.none)
plot(vWt,    "v WaveTrend",display=display.none)
plot(vAo,    "v AO",       display=display.none)
plot(vRsi,   "v RSI",      display=display.none)
plot(vCop,   "v Coppock",  display=display.none)
plot(vDpo,   "v DPO",      display=display.none)
plot(scoreRaw, "Score raw",display=display.none)
plot(agree,  "Agreement %",display=display.none)
````

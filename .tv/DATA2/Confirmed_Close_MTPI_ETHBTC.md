<!-- tradingview-pine-id: PUB;7f818b7067b74c55806bded7efd3dcd1 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Confirmed Close MTPI ETH/BTC

Source: https://www.tradingview.com/script/pfMJnWXe-Confirmed-Close-MTPI-ETH-BTC/

## Description

WHAT THIS IS

This is a trend indicator for the ETH/BTC ratio. It answers one question: which of the two majors is leading right now, ether or bitcoin?

The chart it runs on is a ratio, not a price. When the line rises, ether is gaining on bitcoin. When it falls, bitcoin is gaining on ether. Both can be going up or down in dollars at the time. The ratio only cares which one is winning.

It answers that by running twelve separate trend indicators at once and taking a vote. Each of the twelve looks at the chart in its own way and says either up or down. The score is the average of those votes. All twelve for ether gives +1.00, all twelve for bitcoin gives -1.00, and a six against six split gives 0.00.

Because twelve votes average out, the score can only land on thirteen values, one sixth apart: -1.00, -0.83, -0.67 and so on up to +1.00.

This approach is usually called a Trend Probability Indicator, or TPI. The point is that no single indicator is reliable on its own. Any one of them will whipsaw you. What holds up is the question of how much of the group agrees, and that is what the score measures.

WHY "CONFIRMED CLOSE"

A lot of indicators change their mind while the current candle is still forming, then change back before it closes. That is called repainting and it makes an indicator untradeable, because the signal you acted on may not be there an hour later.

This one does not do that. While today's candle is still open, the indicator shows you yesterday's confirmed reading. The state only changes when a daily candle actually closes. What you see is what you could have traded.

HOW TO READ IT

Blue is ether, orange is bitcoin. That pair was chosen on purpose: it stays readable for the most common forms of colour blindness, where green and red do not. There is a green and red palette in the settings if you prefer it.

On the price chart:

- Candles are painted blue while ether leads and orange while bitcoin leads. This is the state, at a glance.
- A blue triangle marked ETH below the candles is the bar where the score turned in ether's favour. An orange triangle marked BTC above them is the turn to bitcoin. These are the moments that matter.
- Two moving averages, a 12 period and a 21 period EMA, are drawn as a reference. They are a crude version of the same question and they are there so you can see how much smoother the twelve indicator version is.
- Bars are tinted purple where the twelve indicator score and the simple 12/21 cross disagree. Those are the bars where the crude version would have put you in the wrong coin.

In the separate pane below:

- The stepped line is the score, from -1.00 to +1.00, filled to the zero line and coloured by state.
- Dotted lines at +0.5 and -0.5 give you a sense of how strong the agreement is. A score of +1.00 is twelve out of twelve. A score of +0.17 is seven against five, which is a lead barely holding together.

The dashboard, bottom right by default:

- The big number is the current score, with ETH LEADS or BTC LEADS next to it.
- The bar beside it is a gauge. It fills outward from the middle, right and blue for ether, left and orange for bitcoin.
- The twelve indicators are listed in two columns, the six trend-following ones on the left and the six oscillators on the right, each showing its own vote. This is where you see WHY the score is what it is.
- "12/21 agree" is the share of days where the twelve indicator score and the simple EMA cross pointed the same way, measured across all the history your chart has loaded. Read it as a rough measure of how often the crude version would have agreed with the careful one. It is measured against the raw cross with no filtering, so treat it as an indication rather than a precise statistic.
- "Regime" is how many days the current state has lasted. It turns amber below eight days, because a lead that has not lasted eight days has a habit of being noise.

HOW TO USE IT

The simplest use is the one it was built for. It does not tell you whether to be in crypto at all. It tells you which major to hold once you have decided to be. Positive and the base holding is ether. Negative and it is bitcoin.

You act on the close, and you execute on the open of the next candle. Anything earlier is acting on a candle that has not finished forming.

Set an alert if you do not want to watch it. The script exposes two alert conditions, one for the turn to ether and one for the turn to bitcoin, and both fire only on a confirmed daily close.

Read the twelve rows when the score is near zero. A score of +0.17 that is being held up by two oscillators is a very different situation from a +0.17 where the trend-following group is turning. The individual votes tell you which one you are in.

THE WIDER SYSTEM THIS BELONGS TO

This indicator is one rung of a ladder. The idea is that you are always holding the strongest available thing, and that the decision is made in steps rather than all at once.

Step one. A TPI on the total crypto market cap excluding stablecoins. If it is positive, you stay in crypto and you go to step two. If it is negative, you leave crypto and go to step three.

Step two, and this is where this indicator sits. ETH/BTC decides which major leads. Positive means ether is outperforming and ether is the base holding. Negative means bitcoin. A further layer of ratio TPIs then compares mid caps against whichever major won, and the ones that are outperforming take a share of the book.

Step three, when crypto is bearish. A gold TPI. If gold is trending up, that is where the money sits.

Step four, when gold is not working either. An index TPI on the S&P 500. If equities are trending, that is the holding.

Step five, when nothing is trending. Cash, and a EUR/USD TPI decides whether that cash is better held in euros or in dollars.

Each rung is its own TPI, built the same way: twelve indicators, one vote each, tuned separately for that market. The ladder simply asks them in order.

A SET, NOT A SINGLE SCRIPT

This is the second published piece of that set, after the one on the total crypto market cap. The other rungs are built and running and will follow as separate publications, each one an indicator for its own market, all reading the same way so you only have to learn the layout once.

ABOUT THE SETTINGS

The twelve indicators and their periods are visible in the settings and in the source. They were tuned for this specific ratio against a cleaned 12/21 EMA reference on daily data from January 2023 onward, with regimes shorter than eight days treated as noise and removed before the tuning was scored. The symbol has daily history back to 2017 if you want to look further back.

A ratio is choppier than a single market, so the agreement ceiling is lower here than it is on the total market cap version. That is the honest answer and it is why the twelve are not the same twelve. Two components differ from the market cap script: Coral Trend replaces the Follow Line, and TRIX replaces the Fisher Transform.

Those numbers are right for ETH/BTC. They are not automatically right for anything else. If you put this on another symbol, expect to retune. That is why each market in the set gets its own publication rather than one script with a symbol dropdown.

Three of the twelve are read on a smoothed line rather than the raw one, which is deliberate: the CCI is scored on its EMA 5 smoothing and the RSI on its EMA 12. The Awesome Oscillator is scored on its raw line, not its signal line. Those choices are in the code and commented.

HOW FAITHFUL THE REBUILD IS

Because seven of the twelve are rewritten from other people's published formulas rather than called directly, the obvious question is whether they behave the same. They do, and you can check it yourself: put the twelve original indicators on this chart with the settings listed in the source and compare.

That is what was done here. Three thousand three hundred daily bars were loaded, back to 2017, and every one of the twelve votes was compared bar by bar against the original indicator running on the same chart. Zero disagreements on any of the twelve, and the combined score matched on every single bar.

The score also reproduces the daily record of the live system this belongs to, exactly, for 626 consecutive days. That part you cannot verify from here, so take it for what it is worth. The bar by bar check above is the one that stands on its own.

That check is worth repeating if you change a setting, and it is why each vote is exposed as a hidden plot in the script rather than kept internal.

CREDIT WHERE IT IS DUE

Seven of the twelve components are reimplementations of open-source community scripts, written from their published formulas so they could all live in one indicator and be scored consistently. Full credit to the original authors:

- Gaussian Channel by DonovanWall
- Optimized Trend Tracker by KivancOzbilgic
- Awesome Oscillator v2 by KivancOzbilgic
- Hull Suite by InSilico
- SSL Channel by ErwinBeckers
- Coral Trend Indicator by LazyBear
- WaveTrend by LazyBear

The remaining five are standard: ALMA, CCI, RSI, Coppock Curve and TRIX.

What is added here is the aggregation into a single score, the confirmed close behaviour, the per indicator breakdown, the agreement measurement against the reference, and the ladder logic this is built to serve.

LIMITATIONS AND A PLAIN WARNING

This is a trend indicator. It is late by design. It will not catch the exact turn in the ratio, and it is not supposed to. It will be wrong when the two majors trade in line with each other for weeks, which is what the eight day regime warning is there to tell you.

It also says nothing about the direction of crypto itself. A +1.00 reading here means ether is beating bitcoin. Both of them can still be falling. That is what the first rung of the ladder is for.

Nothing here is financial advice. It is a tool for reading a chart. Past behaviour of any indicator tells you nothing reliable about the future. Do your own work and size your positions so that being wrong is survivable.

---

## Source Code

````pine
//@version=6
// Confirmed Close MTPI ETH/BTC
// Twelve indicators, settings read from the "ETH/BTC RATIO MTPI" study template
// on 2026-09-20. Same method as Confirmed Close MTPI TOTALES, tuned for this
// ratio: Coral Trend replaces the Follow Line and TRIX replaces the Fisher.
// Blue is ether, orange is bitcoin, which is also the colour-blind safe pair.
// A green and red palette is available in the settings.
indicator("Confirmed Close MTPI ETH/BTC", shorttitle="CC ETHBTC", overlay=false, precision=2, max_labels_count=500)

grpP = "Perpetual"
grpO = "Oscillator"
grpR = "Reference"
grpD = "Display"

gPeriod  = input.int(78,    "Gaussian period",        group=grpP)
ottLen   = input.int(30,    "OTT period (EMA)",       group=grpP)
ottPct   = input.float(0.7, "OTT percent",            group=grpP)
hullLen  = input.int(72,    "Hull Ehma length",       group=grpP)
sslLen   = input.int(47,    "SSL period",             group=grpP)
almaLen  = input.int(98,    "ALMA length",            group=grpP)
almaOff  = input.float(0.95,"ALMA offset",            group=grpP)
almaSig  = input.float(6,   "ALMA sigma",             group=grpP)
crSm     = input.int(24,    "Coral smoothing period", group=grpP)
crCd     = input.float(0.2, "Coral constant D",       group=grpP)

cciLen   = input.int(43,    "CCI length",             group=grpO)
cciSm    = input.int(5,     "CCI EMA smoothing",      group=grpO)
wtCh     = input.int(27,    "WaveTrend channel",      group=grpO)
wtAv     = input.int(11,    "WaveTrend average",      group=grpO)
aoFast   = input.int(3,     "AO fast",                group=grpO)
aoSlow   = input.int(47,    "AO slow",                group=grpO)
aoSig    = input.int(7,     "AO signal",              group=grpO)
rsiLen   = input.int(13,    "RSI length",             group=grpO)
rsiSm    = input.int(12,    "RSI EMA smoothing",      group=grpO)
copWma   = input.int(6,     "Coppock WMA",            group=grpO)
copLong  = input.int(36,    "Coppock long RoC",       group=grpO)
copShort = input.int(16,    "Coppock short RoC",      group=grpO)
trixLen  = input.int(10,    "TRIX length",            group=grpO)

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
altPal   = input.bool(false, "Green and red palette", group=grpD, tooltip="Off is blue for ether and orange for bitcoin. On is the usual green and red.")
showWarn = input.bool(true, "Tint bars where the MTPI and the 12/21 disagree", group=grpD)

tblPos = posIn == "Top left" ? position.top_left : posIn == "Top centre" ? position.top_center : posIn == "Top right" ? position.top_right : posIn == "Middle left" ? position.middle_left : posIn == "Middle centre" ? position.middle_center : posIn == "Middle right" ? position.middle_right : posIn == "Bottom left" ? position.bottom_left : posIn == "Bottom centre" ? position.bottom_center : position.bottom_right
szBig  = szIn == "Tiny" ? size.small : szIn == "Small" ? size.large : szIn == "Normal" ? size.large : size.huge
szMid  = szIn == "Tiny" ? size.tiny : szIn == "Small" ? size.small : szIn == "Normal" ? size.normal : size.large
szLow  = szIn == "Tiny" ? size.tiny : szIn == "Small" ? size.tiny : szIn == "Normal" ? size.small : size.normal

cBull = altPal ? #089981 : #2196f3
cBear = altPal ? #f23645 : #f7931a
cNeut = #787b86
cWarn = altPal ? #ffa726 : #ab47bc
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

trixV = 10000 * ta.change(ta.ema(ta.ema(ta.ema(math.log(close), trixLen), trixLen), trixLen))
vTrix = trixV > 0 ? 1 : -1

warm  = math.max(gPeriod, ottLen, hullLen, sslLen, almaLen, crSm, cciLen + cciSm, wtCh + wtAv, aoSlow + aoSig, rsiLen + rsiSm, copLong + copWma, trixLen * 3 + 1)
ready = bar_index >= warm and not na(coralV[1]) and not na(trixV)
sumV  = vGauss + vOtt + vHull + vSsl + vAlma + vCoral + vCci + vWt + vAo + vRsi + vCop + vTrix
scoreRaw = ready ? sumV / 12.0 : na
score = useConf and not barstate.isconfirmed ? scoreRaw[1] : scoreRaw

st = score > 0 ? 1 : score < 0 ? -1 : 0
stateCol = st > 0 ? cBull : st < 0 ? cBear : cNeut
stateTxt = st > 0 ? "ETH LEADS" : st < 0 ? "BTC LEADS" : "LEVEL"
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
plotshape(mkUp, title="ETH flip", style=shape.triangleup, location=location.absolute, color=cBull, size=size.tiny, display=display.pane, force_overlay=true)
plotshape(mkDn, title="BTC flip", style=shape.triangledown, location=location.absolute, color=cBear, size=size.tiny, display=display.pane, force_overlay=true)

if flipUp
    label.new(bar_index, mkUp - atrMk * 1.0, "ETH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=cBull, size=size.small, force_overlay=true)
if flipDn
    label.new(bar_index, mkDn + atrMk * 1.0, "BTC", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=cBear, size=size.small, force_overlay=true)

disagree = not na(score) and st != 0 and ((st > 0 and refState < 0) or (st < 0 and refState > 0))
bgcolor(showWarn and disagree ? color.new(cWarn, 88) : na, title="MTPI and reference disagree", force_overlay=true)

alertcondition(flipUp, title="MTPI ETH/BTC turned to ETH", message="MTPI ETH/BTC turned to ETH on the confirmed close")
alertcondition(flipDn, title="MTPI ETH/BTC turned to BTC", message="MTPI ETH/BTC turned to BTC on the confirmed close")
if flipUp and barstate.isconfirmed
    alert("MTPI ETH/BTC turned to ETH, score " + str.tostring(score, "0.00"), alert.freq_once_per_bar_close)
if flipDn and barstate.isconfirmed
    alert("MTPI ETH/BTC turned to BTC, score " + str.tostring(score, "0.00"), alert.freq_once_per_bar_close)

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
    table.cell(t, 3, 0, "ETH/BTC", text_color=cDim, text_size=szMid, text_halign=text.align_right, bgcolor=cHead)
    table.cell(t, 0, 1, str.tostring(score, "+0.00;-0.00"), text_color=stateCol, text_size=szBig, text_halign=text.align_left)
    table.cell(t, 1, 1, stateTxt, text_color=stateCol, text_size=szMid, text_halign=text.align_left)
    table.cell(t, 2, 1, gaugeStr(score), text_color=stateCol, text_size=szMid, text_halign=text.align_center)
    table.cell(t, 3, 1, str.tostring((12 + sumV) / 2, "#") + "/12 ETH", text_color=cDim, text_size=szMid, text_halign=text.align_right)
    names1 = array.from("Gaussian", "OTT", "Hull", "SSL", "ALMA", "Coral")
    vals1  = array.from(vGauss, vOtt, vHull, vSsl, vAlma, vCoral)
    names2 = array.from("CCI", "WaveTrend", "AO", "RSI", "Coppock", "TRIX")
    vals2  = array.from(vCci, vWt, vAo, vRsi, vCop, vTrix)
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
    table.cell(t, 3, 9, refState > 0 ? "ETH" : "BTC", text_color=vCol(refState), text_size=szLow, text_halign=text.align_right)
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
plot(vTrix,  "v TRIX",     display=display.none)
plot(scoreRaw, "Score raw",display=display.none)
plot(agree,  "Agreement %",display=display.none)
````

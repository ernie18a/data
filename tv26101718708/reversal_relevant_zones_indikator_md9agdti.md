# Reversal & Relevant Zones Indikator

- url: https://www.tradingview.com/script/Md9Agdti/
- type: indicator
- pine_id: PUB;b06b3bb826ea4fbb905ec152831531c5
- version: 1.0

## Description

This Indikator plots relevant Support and Resistance Zones and Buy and Sell Signals

## Source Code

````pine
//@version=6
indicator(
  title            = "Reversal + MTF S/R + PDH/PDL  |  EUR/USD 1min",
  overlay          = true,
  max_bars_back    = 5000,
  max_lines_count  = 500,
  max_labels_count = 300,
  max_boxes_count  = 200
)

// Preis-Anker: zwingt den Indikator auf die Chart-Preisskala
// Skalen-Anker: hält Indikator auf Chart-Preisskala
plot(close, "close", color=#00000000)

// ══════════════════════════════════════════════════════
// EINSTELLUNGEN
// ══════════════════════════════════════════════════════
grp1 = "── RSI ──"
rsiLen   = input.int(14, "Länge",        group=grp1, minval=2)
rsiUpper = input.int(68, "Überkauft",    group=grp1, minval=51, maxval=99)
rsiLower = input.int(32, "Überverkauft", group=grp1, minval=1,  maxval=49)

grp2 = "── Stochastic ──"
stochLen   = input.int(14, "Länge",        group=grp2, minval=2)
stochSmK   = input.int(3,  "%K Glättung",  group=grp2, minval=1)
stochSmD   = input.int(3,  "%D Glättung",  group=grp2, minval=1)
stochUpper = input.int(80, "Überkauft",    group=grp2, minval=51, maxval=99)
stochLower = input.int(20, "Überverkauft", group=grp2, minval=1,  maxval=49)

grp4 = "── MTF Support / Resistance ──"
show15m      = input.bool(true,     "15M Zonen",        group=grp4)
show30m      = input.bool(true,     "30M Zonen",        group=grp4)
show1h       = input.bool(true,     "1H Zonen",         group=grp4)
srZone15     = input.float(0.00020, "15M Toleranz",     group=grp4, step=0.00005)
srZone30     = input.float(0.00025, "30M Toleranz",     group=grp4, step=0.00005)
srZone1h     = input.float(0.00030, "1H Toleranz",      group=grp4, step=0.00005)
srMinTouches = input.int(2,         "Min. Berührungen", group=grp4, minval=1)

grp5 = "── Previous Day High / Low ──"
showPDHL = input.bool(true, "PDH / PDL anzeigen", group=grp5)

grp6 = "── Darstellung ──"
showTrend = input.bool(true,  "Trend EMA anzeigen", group=grp6)
showBG    = input.bool(false, "Trend-Hintergrund",  group=grp6)
showSlTp  = input.bool(true,  "SL/TP Punkte",       group=grp6)

grpTL = "── Trend EMA ──"
emaT1Len    = input.int(50,  "Trend EMA Schnell",                        group=grpTL, minval=5)
slopeSmooth = input.int(8,   "Trend Glättung (höher = weniger Wechsel)", group=grpTL, minval=2, maxval=30)

grpSQ = "── Signal Qualität ──"
srProximity  = input.float(0.00020, "S/R Nähe Toleranz", group=grpSQ, step=0.00005)
cooldownBars = input.int(10,        "Cooldown (Kerzen)",  group=grpSQ, minval=3, maxval=50)

grpBT = "── Backtest ──"
btInterval = input.int(50,  "Intervall (Kerzen)", group=grpBT, minval=20, maxval=200)
btLookback = input.int(200, "Lookback (Kerzen)",  group=grpBT, minval=50, maxval=500)

// Kerzen werden vom Chart selbst gezeichnet (overlay=true)
// plotcandle() entfernt – verhindert Skalierungsprobleme

// ══════════════════════════════════════════════════════
// INDIKATOREN
// ══════════════════════════════════════════════════════
rsi    = ta.rsi(close, rsiLen)
stochLo  = ta.lowest(low, stochLen)
stochHi  = ta.highest(high, stochLen)
stochRng = stochHi - stochLo
stochRaw = stochRng > 0 ? 100.0 * (close - stochLo) / stochRng : 50.0
stochK   = ta.sma(stochRaw, stochSmK)
stochD   = ta.sma(stochK,   stochSmD)
atr      = ta.atr(14)
atrAvg   = ta.sma(atr, 20)

// ══════════════════════════════════════════════════════
// TREND EMA – Pullback-gefilterter Trend
// Farbe wechselt NUR bei echtem Trendwechsel,
// nicht bei kleinen Korrekturen und Pullbacks
// ══════════════════════════════════════════════════════
emaT1 = ta.ema(close, emaT1Len)
emaT2 = ta.ema(close, 200)

// Geglättete Steigung über mehrere Kerzen
emaT1Slope = ta.sma(emaT1 - emaT1[3], slopeSmooth)
emaT2Slope = ta.sma(emaT2 - emaT2[5], slopeSmooth)

// Mindest-Steigung für Trendwechsel (filtert Seitwärts)
slopeThresh = atrAvg * 0.002

// Persistente Trendrichtung: wechselt nur bei klarer Richtungsänderung
var bool t1Bull = true
var bool t2Bull = true

if emaT1Slope >  slopeThresh
    t1Bull := true
else if emaT1Slope < -slopeThresh
    t1Bull := false

if emaT2Slope >  slopeThresh * 0.5
    t2Bull := true
else if emaT2Slope < -slopeThresh * 0.5
    t2Bull := false

// Echter Trendwechsel (nicht bei jedem Pullback)
emaTurnBull = t1Bull  and not t1Bull[1]
emaTurnBear = not t1Bull and t1Bull[1]
emaBullCtx  = t1Bull
emaBearCtx  = not t1Bull

// Farbdefinitionen
t1ColA = t1Bull ? color.new(#00C853, 75) : color.new(#FF1744, 75)
t1ColB = t1Bull ? color.new(#00C853, 50) : color.new(#FF1744, 50)
t1ColC = t1Bull ? color.new(#00C853,  0) : color.new(#FF1744,  0)

// Glow-Plots
plot(emaT1, "EMA50 Glow", color=showTrend ? t1ColA : #00000000, linewidth=6)
plot(emaT1, "EMA50 Mid",  color=showTrend ? t1ColB : #00000000, linewidth=4)
plot(emaT1, "EMA50 Kern", color=showTrend ? t1ColC : #00000000, linewidth=2)

// Trendwechsel-Marker – als plot() auf EMA-Wert (kein location.absolute)
plot(showTrend and emaTurnBull ? emaT1 : na, "Trend →Grün",
  color=color.new(#00C853, 0), linewidth=4, style=plot.style_circles)
plot(showTrend and emaTurnBear ? emaT1 : na, "Trend →Rot",
  color=color.new(#FF1744, 0), linewidth=4, style=plot.style_circles)

// ══════════════════════════════════════════════════════
// MTF DATEN
// ══════════════════════════════════════════════════════
h15    = request.security(syminfo.tickerid, "15", high,  lookahead=barmerge.lookahead_off)
l15    = request.security(syminfo.tickerid, "15", low,   lookahead=barmerge.lookahead_off)
isPH15 = request.security(syminfo.tickerid, "15", high == ta.highest(high, 10), lookahead=barmerge.lookahead_off)
isPL15 = request.security(syminfo.tickerid, "15", low  == ta.lowest(low,  10),  lookahead=barmerge.lookahead_off)

h30    = request.security(syminfo.tickerid, "30", high,  lookahead=barmerge.lookahead_off)
l30    = request.security(syminfo.tickerid, "30", low,   lookahead=barmerge.lookahead_off)
isPH30 = request.security(syminfo.tickerid, "30", high == ta.highest(high, 10), lookahead=barmerge.lookahead_off)
isPL30 = request.security(syminfo.tickerid, "30", low  == ta.lowest(low,  10),  lookahead=barmerge.lookahead_off)

h1h    = request.security(syminfo.tickerid, "60", high,  lookahead=barmerge.lookahead_off)
l1h    = request.security(syminfo.tickerid, "60", low,   lookahead=barmerge.lookahead_off)
isPH1h = request.security(syminfo.tickerid, "60", high == ta.highest(high, 10), lookahead=barmerge.lookahead_off)
isPL1h = request.security(syminfo.tickerid, "60", low  == ta.lowest(low,  10),  lookahead=barmerge.lookahead_off)

pdHigh   = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdLow    = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
isNewDay = ta.change(request.security(syminfo.tickerid, "D", time, lookahead=barmerge.lookahead_on)) != 0

ema15mF = request.security(syminfo.tickerid, "15", ta.ema(close, 9),  lookahead=barmerge.lookahead_off)
ema15mS = request.security(syminfo.tickerid, "15", ta.ema(close, 21), lookahead=barmerge.lookahead_off)
ema30mF = request.security(syminfo.tickerid, "30", ta.ema(close, 9),  lookahead=barmerge.lookahead_off)
ema30mS = request.security(syminfo.tickerid, "30", ta.ema(close, 21), lookahead=barmerge.lookahead_off)
ema1hF  = request.security(syminfo.tickerid, "60", ta.ema(close, 9),  lookahead=barmerge.lookahead_off)
ema1hS  = request.security(syminfo.tickerid, "60", ta.ema(close, 21), lookahead=barmerge.lookahead_off)

trend15mBull = ema15mF > ema15mS
trend15mBear = ema15mF < ema15mS
htfBull      = ema30mF > ema30mS and ema1hF > ema1hS
htfBear      = ema30mF < ema30mS and ema1hF < ema1hS

// ══════════════════════════════════════════════════════
// CANDLESTICK PATTERNS
// ══════════════════════════════════════════════════════
body     = math.abs(close - open)
body1    = math.abs(close[1] - open[1])
body2    = math.abs(close[2] - open[2])
rng      = high - low
upWick   = high - math.max(close, open)
downWick = math.min(close, open) - low
safeBody = math.max(body, syminfo.mintick)
midpt1   = (open[1] + close[1]) / 2.0

bullEngulf  = close > open  and close[1] < open[1] and close >= open[1]  and open <= close[1] and body > body1
hammer      = downWick >= safeBody * 2.0 and upWick   <= safeBody * 0.5 and rng > atrAvg * 0.3
invHammer   = close > open  and upWick   >= safeBody * 2.0 and downWick <= safeBody * 0.5 and rng > atrAvg * 0.3
dojiBody    = body <= atrAvg * 0.05
bullDoji    = dojiBody and rng > atrAvg * 0.3 and low  <= math.min(math.min(l15, l30), l1h) + srProximity
mornStar    = close[2] < open[2] and body1 <= body2 * 0.3 and close > open and close >= midpt1 + body2 * 0.5 and body >= atrAvg * 0.4
bullHarami  = close > open  and close[1] < open[1] and open > close[1]  and close < open[1] and body < body1 * 0.6
tweezerBot  = math.abs(low - low[1]) <= syminfo.mintick * 3 and close[1] < open[1] and close > open and rng > atrAvg * 0.3
bullPattern = bullEngulf or hammer or invHammer or bullDoji or mornStar or bullHarami or tweezerBot

bearEngulf  = close < open  and close[1] > open[1] and close <= open[1]  and open >= close[1] and body > body1
shootStar   = upWick   >= safeBody * 2.0 and downWick <= safeBody * 0.5 and rng > atrAvg * 0.3
hangMan     = close < open  and downWick >= safeBody * 2.0 and upWick   <= safeBody * 0.5 and rng > atrAvg * 0.3
bearDoji    = dojiBody and rng > atrAvg * 0.3 and high >= math.max(math.max(h15, h30), h1h) - srProximity
evenStar    = close[2] > open[2] and body1 <= body2 * 0.3 and close < open and close <= midpt1 - body2 * 0.5 and body >= atrAvg * 0.4
bearHarami  = close < open  and close[1] > open[1] and open < close[1]  and close > open[1] and body < body1 * 0.6
tweezerTop  = math.abs(high - high[1]) <= syminfo.mintick * 3 and close[1] > open[1] and close < open and rng > atrAvg * 0.3
bearPattern = bearEngulf or shootStar or hangMan or bearDoji or evenStar or bearHarami or tweezerTop

bullPatName() =>
    string n = "Pattern"
    if bullEngulf
        n := "Engulfing"
    if mornStar
        n := "Morning Star"
    if hammer
        n := "Hammer"
    if tweezerBot
        n := "Tweezer Bot"
    if invHammer
        n := "Inv.Hammer"
    if bullHarami
        n := "Harami"
    if bullDoji
        n := "Doji"
    n

bearPatName() =>
    string n = "Pattern"
    if bearEngulf
        n := "Engulfing"
    if evenStar
        n := "Evening Star"
    if shootStar
        n := "Shoot.Star"
    if tweezerTop
        n := "Tweezer Top"
    if hangMan
        n := "Hang.Man"
    if bearHarami
        n := "Harami"
    if bearDoji
        n := "Doji"
    n

// ══════════════════════════════════════════════════════
// SIGNALE – 3 Wege, immer an S/R Zone
// ══════════════════════════════════════════════════════
rsiOversold    = rsi < rsiLower
rsiOverbought  = rsi > rsiUpper
stochCrossUp   = ta.crossover(stochK,  stochD)
stochCrossDown = ta.crossunder(stochK, stochD)
stochLow       = stochK < stochLower
stochHigh      = stochK > stochUpper

nearSupport =
  math.abs(low   - l15)   <= srProximity or math.abs(low   - l30)   <= srProximity or
  math.abs(low   - l1h)   <= srProximity or math.abs(low   - pdLow) <= srProximity or
  math.abs(close - l15)   <= srProximity or math.abs(close - l30)   <= srProximity or
  math.abs(close - l1h)   <= srProximity or math.abs(close - pdLow) <= srProximity

nearResistance =
  math.abs(high  - h15)    <= srProximity or math.abs(high  - h30)    <= srProximity or
  math.abs(high  - h1h)    <= srProximity or math.abs(high  - pdHigh) <= srProximity or
  math.abs(close - h15)    <= srProximity or math.abs(close - h30)    <= srProximity or
  math.abs(close - h1h)    <= srProximity or math.abs(close - pdHigh) <= srProximity

var int lastBuyBar  = 0
var int lastSellBar = 0
buyCooldownOk  = (bar_index - lastBuyBar)  >= cooldownBars
sellCooldownOk = (bar_index - lastSellBar) >= cooldownBars

// Trendwechsel-Fenster: wie viele Kerzen nach Flip sind Signale prioritär
var int lastBullFlip = 0
var int lastBearFlip = 0
if emaTurnBull
    lastBullFlip := bar_index
if emaTurnBear
    lastBearFlip := bar_index

flipWindow     = 15
recentBullFlip = (bar_index - lastBullFlip) <= flipWindow
recentBearFlip = (bar_index - lastBearFlip) <= flipWindow

// ★★★ STARK – frischer Trendwechsel + Zone + RSI/Stoch extrem + Pattern
strongBuy  = nearSupport    and recentBullFlip
  and rsiOversold  and stochCrossUp  and bullPattern
  and buyCooldownOk

strongSell = nearResistance and recentBearFlip
  and rsiOverbought and stochCrossDown and bearPattern
  and sellCooldownOk

// ★★ MITTEL – Trend aktiv (kein frischer Flip nötig) + Zone + RSI + Pattern
medBuy  = nearSupport    and emaBullCtx
  and rsiOversold  and stochCrossUp
  and bullPattern  and buyCooldownOk
  and not strongBuy

medSell = nearResistance and emaBearCtx
  and rsiOverbought and stochCrossDown
  and bearPattern   and sellCooldownOk
  and not strongSell

strongBuyPlus  = strongBuy  and htfBull
strongSellPlus = strongSell and htfBear
medBuyPlus     = medBuy     and htfBull
medSellPlus    = medSell    and htfBear

if strongBuy or medBuy
    lastBuyBar := bar_index
if strongSell or medSell
    lastSellBar := bar_index

slBuy  = low   - atr * 1.5
tpBuy  = close + atr * 2.5
slSell = high  + atr * 1.5
tpSell = close - atr * 2.5

// ══════════════════════════════════════════════════════
// BACKTEST – alle N Kerzen aktualisiert
// ══════════════════════════════════════════════════════
var float btWinRate    = 50.0
var int   btWins       = 0
var int   btLosses     = 0
var int   btLastUpdate = 0
var label btLabel      = na

if barstate.isconfirmed and (bar_index - btLastUpdate) >= btInterval
    btLastUpdate := bar_index
    int wins = 0
    int losses = 0
    for i = btLookback to 5
        float sigAtr = atr[i]
        bool wasBuy  = math.abs(low[i]  - l15[i]) <= srZone15 * 2 and close[i] > open[i]
        bool wasSell = math.abs(high[i] - h15[i]) <= srZone15 * 2 and close[i] < open[i]
        if wasBuy
            float tp = close[i] + sigAtr * 2.5
            float sl = close[i] - sigAtr * 1.5
            for j = i - 1 to math.max(i - 20, 0)
                if high[j] >= tp
                    wins += 1
                    break
                else if low[j] <= sl
                    losses += 1
                    break
        if wasSell
            float tp = close[i] - sigAtr * 2.5
            float sl = close[i] + sigAtr * 1.5
            for j = i - 1 to math.max(i - 20, 0)
                if low[j] <= tp
                    wins += 1
                    break
                else if high[j] >= sl
                    losses += 1
                    break
    btWins   := wins
    btLosses := losses
    int total = wins + losses
    btWinRate := total > 0 ? math.round(100.0 * wins / total) : 50.0
    if not na(btLabel)
        label.delete(btLabel)
    color btCol = btWinRate >= 60 ? color.new(#00C853, 0) : btWinRate >= 45 ? color.new(#FF9100, 0) : color.new(#FF1744, 0)
    btLabel := label.new(bar_index, close, yloc=yloc.abovebar,
      text="BT Win:" + str.tostring(btWinRate) + "%  (" + str.tostring(total) + " Trades)",
      color=btCol, textcolor=color.white, style=label.style_label_down, size=size.small)

// ══════════════════════════════════════════════════════
// S/R HELPER FUNKTIONEN
// ══════════════════════════════════════════════════════
countTouches1m(float level, float tolerance) =>
    int cnt = 0
    for i = 0 to 99
        if math.abs(high[i] - level) <= tolerance or math.abs(low[i] - level) <= tolerance
            cnt += 1
    cnt

tfScore(float level, float tol) =>
    int score = 0
    if math.abs(h15 - level) <= tol * 1.5 or math.abs(l15 - level) <= tol * 1.5
        score += 1
    if math.abs(h30 - level) <= tol * 2.0 or math.abs(l30 - level) <= tol * 2.0
        score += 1
    if math.abs(h1h - level) <= tol * 2.5 or math.abs(l1h - level) <= tol * 2.5
        score += 1
    score

calcZoneStats(float level, float tolerance, bool isSupport, int tfs, bool nearPD) =>
    int bullBars = 0
    int bearBars = 0
    for i = 0 to 149
        bool touched = math.abs(high[i] - level) <= tolerance or math.abs(low[i] - level) <= tolerance
        if touched
            if close[i] >= open[i]
                bullBars += 1
            else
                bearBars += 1
    int total  = math.max(bullBars + bearBars, 1)
    int buyPct = math.round(100.0 * bullBars / total)
    int selPct = 100 - buyPct
    int revPct = isSupport ? buyPct : selPct
    int conPct = 100 - revPct
    int bonus  = math.min(tfs * 5, 15) + (nearPD ? 5 : 0)
    if revPct > 50
        revPct := math.min(revPct + bonus, 95)
        conPct := 100 - revPct
    else
        conPct := math.min(conPct + bonus, 95)
        revPct := 100 - conPct
    [buyPct, selPct, revPct, conPct]

lineCol(int score) =>
    color result = color.new(#607D8B, 20)
    if score >= 3
        result := color.new(#FF1744, 0)
    else if score == 2
        result := color.new(#FF9100, 0)
    else if score == 1
        result := color.new(#FFD600, 0)
    result

// ══════════════════════════════════════════════════════
// S/R ZONEN
// – Box läuft immer bis zum aktuellen Bar
// – Zone wird entfernt wenn sie 2x klar gebrochen wurde
// ══════════════════════════════════════════════════════
var box[]   srBoxes   = array.new_box()
var label[] srLabels  = array.new_label()
var float[] drawnLvls = array.new_float()
var bool[]  drawnIsRes = array.new_bool()   // true = Resistance, false = Support
var int[]   breakCount = array.new_int()    // Anzahl Durchbrüche

// Zählt wie oft close klar auf der "falschen" Seite der Zone schloss
countBreaches(float level, float zoneH, bool isRes) =>
    int cnt = 0
    for i = 1 to 50
        // Resistance gebrochen wenn close klar über Zone schloss
        // Support gebrochen wenn close klar unter Zone schloss
        if isRes and close[i] > level + zoneH * 1.5
            cnt += 1
        else if not isRes and close[i] < level - zoneH * 1.5
            cnt += 1
    cnt

alreadyDrawn(float level, float tol) =>
    bool found = false
    int sz = array.size(drawnLvls)
    if sz > 0
        for i = 0 to sz - 1
            if math.abs(array.get(drawnLvls, i) - level) <= tol
                found := true
                break
    found

// Jede Bar: Boxen bis aktuellen Bar verlängern + invalidierte Zonen entfernen
if barstate.isconfirmed
    int i = 0
    while i < array.size(srBoxes)
        float lvl  = array.get(drawnLvls, i)
        bool  isR  = array.get(drawnIsRes, i)
        float zH   = atrAvg * 0.25
        int   bc   = countBreaches(lvl, zH, isR)
        if bc >= 2
            // Zone 2x gebrochen → entfernen
            box.delete(array.get(srBoxes, i))
            label.delete(array.get(srLabels, i))
            array.remove(srBoxes,   i)
            array.remove(srLabels,  i)
            array.remove(drawnLvls, i)
            array.remove(drawnIsRes,i)
            array.remove(breakCount,i)
        else
            // Box bis aktuellen Bar verlängern
            box.set_right(array.get(srBoxes, i), bar_index + 30)
            i += 1

drawZone(float level, float tol, bool isRes, string tf) =>
    if not alreadyDrawn(level, tol)
        int touches = countTouches1m(level, tol)
        if touches >= srMinTouches
            int  tfs    = tfScore(level, tol)
            bool nearPD = math.abs(level - pdHigh) <= tol * 3 or math.abs(level - pdLow) <= tol * 3
            bool isSupp = not isRes
            [buyP, selP, revP, conP] = calcZoneStats(level, tol, isSupp, tfs, nearPD)

            int transFill = tfs >= 3 ? 78 : tfs == 2 ? 84 : 90
            int transBord = tfs >= 3 ? 20 : tfs == 2 ? 35 : 55

            color fillCol = na
            color bordCol = na
            if isRes
                fillCol := selP >= 55 ? color.new(#FF1744, transFill) : color.new(#FF6D00, transFill)
                bordCol := selP >= 55 ? color.new(#FF1744, transBord) : color.new(#FF6D00, transBord)
            else
                fillCol := buyP >= 55 ? color.new(#00C853, transFill) : color.new(#FF6D00, transFill)
                bordCol := buyP >= 55 ? color.new(#00C853, transBord) : color.new(#FF6D00, transBord)

            float zoneH   = atrAvg * 0.25
            float zoneTop = level + zoneH
            float zoneBot = level - zoneH
            int   x1      = bar_index - 30

            bx = box.new(
              left         = x1,
              top          = zoneTop,
              right        = bar_index + 30,
              bottom       = zoneBot,
              bgcolor      = fillCol,
              border_color = bordCol,
              border_width = tfs >= 2 ? 2 : 1,
              border_style = tfs >= 3 ? line.style_solid : line.style_dashed)

            string tag  = isRes ? "R" : "S"
            string trnd = revP >= conP ? "↩ hält" : "→ bricht"
            string txt  = tag + " " + tf + "  " + trnd
              + "  |  REV:" + str.tostring(revP) + "%  CON:" + str.tostring(conP) + "%"
              + "  |  B:" + str.tostring(buyP) + "%  S:" + str.tostring(selP) + "%"

            color lblCol = na
            if isRes
                lblCol := selP >= 55 ? color.new(#B71C1C, 0) : color.new(#E65100, 0)
            else
                lblCol := buyP >= 55 ? color.new(#1B5E20, 0) : color.new(#E65100, 0)

            lbl = label.new(x=bar_index + 35, y=level, text=txt,
              color=lblCol, textcolor=color.white,
              style=label.style_label_left, size=size.normal)

            array.push(srBoxes,    bx)
            array.push(srLabels,   lbl)
            array.push(drawnLvls,  level)
            array.push(drawnIsRes, isRes)
            array.push(breakCount, 0)

if show15m and barstate.isconfirmed
    if isPH15
        drawZone(h15, srZone15, true,  "15M")
    if isPL15
        drawZone(l15, srZone15, false, "15M")

if show30m and barstate.isconfirmed
    if isPH30
        drawZone(h30, srZone30, true,  "30M")
    if isPL30
        drawZone(l30, srZone30, false, "30M")

if show1h and barstate.isconfirmed
    if isPH1h
        drawZone(h1h, srZone1h, true,  "1H")
    if isPL1h
        drawZone(l1h, srZone1h, false, "1H")

// ══════════════════════════════════════════════════════
// PREVIOUS DAY HIGH / LOW
// ══════════════════════════════════════════════════════
var line  pdHL   = na
var line  pdLL   = na
var label pdHLbl = na
var label pdLLbl = na

if showPDHL and isNewDay and barstate.isconfirmed
    if not na(pdHL)
        line.delete(pdHL)
    if not na(pdLL)
        line.delete(pdLL)
    if not na(pdHLbl)
        label.delete(pdHLbl)
    if not na(pdLLbl)
        label.delete(pdLLbl)

    [pdHBuy, pdHSel, pdHRev, pdHCon] = calcZoneStats(pdHigh, srZone1h, false, 2, true)
    [pdLBuy, pdLSel, pdLRev, pdLCon] = calcZoneStats(pdLow,  srZone1h, true,  2, true)

    pdHL := line.new(x1=bar_index, y1=pdHigh, x2=bar_index + 1, y2=pdHigh,
      color=color.new(#E040FB, 0), width=2, style=line.style_dotted, extend=extend.right)
    pdHLbl := label.new(x=bar_index, y=pdHigh,
      text="PDH  REV:" + str.tostring(pdHRev) + "%  CON:" + str.tostring(pdHCon) + "%  |  B:" + str.tostring(pdHBuy) + "%  S:" + str.tostring(pdHSel) + "%",
      color=color.new(#6A1B9A, 0), textcolor=color.white, style=label.style_label_left, size=size.normal)

    pdLL := line.new(x1=bar_index, y1=pdLow, x2=bar_index + 1, y2=pdLow,
      color=color.new(#00BCD4, 0), width=2, style=line.style_dotted, extend=extend.right)
    pdLLbl := label.new(x=bar_index, y=pdLow,
      text="PDL  REV:" + str.tostring(pdLRev) + "%  CON:" + str.tostring(pdLCon) + "%  |  B:" + str.tostring(pdLBuy) + "%  S:" + str.tostring(pdLSel) + "%",
      color=color.new(#006064, 0), textcolor=color.white, style=label.style_label_left, size=size.normal)

// ══════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════
bgcolor(showBG and t1Bull ? color.new(color.green, 96) : na)
bgcolor(showBG and not t1Bull ? color.new(color.red,   96) : na)

// ══════════════════════════════════════════════════════
// SIGNAL LABELS
// ══════════════════════════════════════════════════════
if strongBuy
    color col = strongBuyPlus ? color.new(#00695C, 0) : color.new(#00C853, 0)
    label.new(bar_index, low - atr * 0.6,
      text="BUY ★★★" + (strongBuyPlus ? " +" : "") + "\n" + bullPatName(),
      color=col, textcolor=color.white, style=label.style_label_up, size=size.normal)

if strongSell
    color col = strongSellPlus ? color.new(#B71C1C, 0) : color.new(#D50000, 0)
    label.new(bar_index, high + atr * 0.6,
      text="SELL ★★★" + (strongSellPlus ? " +" : "") + "\n" + bearPatName(),
      color=col, textcolor=color.white, style=label.style_label_down, size=size.normal)

if medBuy
    color col = medBuyPlus ? color.new(#00695C, 20) : color.new(#43A047, 0)
    label.new(bar_index, low - atr * 0.6,
      text="BUY ★★" + (medBuyPlus ? " +" : "") + "\n" + bullPatName(),
      color=col, textcolor=color.white, style=label.style_label_up, size=size.normal)

if medSell
    color col = medSellPlus ? color.new(#B71C1C, 20) : color.new(#E53935, 0)
    label.new(bar_index, high + atr * 0.6,
      text="SELL ★★" + (medSellPlus ? " +" : "") + "\n" + bearPatName(),
      color=col, textcolor=color.white, style=label.style_label_down, size=size.normal)

plot(showSlTp and (strongBuy  or medBuy)  ? slBuy  : na, "SL Buy",  color=color.new(color.red,   10), linewidth=2, style=plot.style_circles)
plot(showSlTp and (strongBuy  or medBuy)  ? tpBuy  : na, "TP Buy",  color=color.new(color.green, 10), linewidth=2, style=plot.style_circles)
plot(showSlTp and (strongSell or medSell) ? slSell : na, "SL Sell", color=color.new(color.red,   10), linewidth=2, style=plot.style_circles)
plot(showSlTp and (strongSell or medSell) ? tpSell : na, "TP Sell", color=color.new(color.green, 10), linewidth=2, style=plot.style_circles)

// ══════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════
alertcondition(strongBuy,  title="BUY ★★★",  message='{"ticker":"EURUSD","action":"buy","strength":"3","price":"{{close}}","time":"{{time}}"}')
alertcondition(medBuy,     title="BUY ★★",   message='{"ticker":"EURUSD","action":"buy","strength":"2","price":"{{close}}","time":"{{time}}"}')
alertcondition(strongSell, title="SELL ★★★", message='{"ticker":"EURUSD","action":"sell","strength":"3","price":"{{close}}","time":"{{time}}"}')
alertcondition(medSell,    title="SELL ★★",  message='{"ticker":"EURUSD","action":"sell","strength":"2","price":"{{close}}","time":"{{time}}"}')
````

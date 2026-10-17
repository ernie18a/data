# brs2tester

- url: https://www.tradingview.com/script/NiWCXbml-brs2tester/
- type: indicator
- pine_id: PUB;8a5a398ff2be48db8dedb68cf8141bbe
- version: 1.0

## Description

Testing ema cycles combined with conors rsi and other rsi. brs2tester

## Source Code

````pine
//@version=5
indicator("Blackcrest Renko (Scanner)", overlay=true, max_labels_count=500)

// ============================================================
// SCANNER MODE — Only show signals on the last closed bar
// ============================================================
isLastClosed = barstate.islast and barstate.isconfirmed

// ============================================================
// TOGGLE INPUTS
// ============================================================
show_P7  = input.bool(true, "P7 — Double Top (Bearish)", group="Patterns")
show_P8  = input.bool(true, "P8 — Double Bottom (Bullish)", group="Patterns")
show_P11 = input.bool(true, "P11 — 7 Up (Bearish)", group="Patterns")
show_P12 = input.bool(true, "P12 — 7 Down (Bullish)", group="Patterns")
show_P13 = input.bool(true, "P13 — Renko Spikes (Bearish)", group="Patterns")
show_P14 = input.bool(true, "P14 — Renko Spikes (Bullish)", group="Patterns")

// ============================================================
// DOUBLE TOP / BOTTOM SETTINGS
// ============================================================
dtLookback    = input.int(10, "DT/DB Lookback (bars)", minval=5, maxval=100, group="Double Top/Bottom")
dtTolerance   = input.float(0.0, "DT/DB Price Tolerance", minval=0.0, step=0.01, group="Double Top/Bottom")
dtMinBetween  = input.int(1, "DT/DB Min Bars Between", minval=1, group="Double Top/Bottom")
dtMinBricks   = input.int(7, "DT/DB Min Consecutive Bricks (1st Leg)", minval=1, maxval=50, group="Double Top/Bottom")

// ============================================================
// 7 UP / 7 DOWN SETTINGS
// ============================================================
minUpBricks   = input.int(7, "7Up Min Consecutive Green Bricks", minval=1, maxval=50, group="7 Up / 7 Down")
minDownBricks = input.int(7, "7Dn Min Consecutive Red Bricks", minval=1, maxval=50, group="7 Up / 7 Down")
macdMaxPct    = input.float(5.0, "Max MACD Change %", minval=0.0, step=0.5, group="7 Up / 7 Down")

// ============================================================
// MACD (12, 26, 9)
// ============================================================
[macdLine, macdSignalLine, _] = ta.macd(close, 12, 26, 9)
macdValid = not na(macdLine) and not na(macdLine[1])

// ============================================================
// WTO (ohlc4, channel 9, average 11, SMA 3)
// ============================================================
wtoSrc = ohlc4
wtoEsa = ta.ema(wtoSrc, 9)
wtoD   = ta.ema(math.abs(wtoSrc - wtoEsa), 9)
wtoCi  = (wtoSrc - wtoEsa) / (0.015 * wtoD)
wtoChannel = ta.ema(wtoCi, 11)
wtoAverage = ta.sma(wtoChannel, 3)

wtoBearish = not na(wtoChannel) and not na(wtoAverage) and wtoChannel < wtoAverage
wtoBullish = not na(wtoChannel) and not na(wtoAverage) and wtoChannel > wtoAverage

// ============================================================
// CONNORS RSI
// ============================================================
updown(s) =>
    isEqual = s == s[1]
    isGrowing = s > s[1]
    ud = 0.0
    ud := isEqual ? 0 : isGrowing ? (nz(ud[1]) <= 0 ? 1 : nz(ud[1])+1) : (nz(ud[1]) >= 0 ? -1 : nz(ud[1])-1)
    ud

crsiRsi = ta.rsi(close, 3)
crsiUpdown = ta.rsi(updown(close), 2)
crsiPctrank = ta.percentrank(ta.roc(close, 1), 100)
crsi = math.avg(crsiRsi, crsiUpdown, crsiPctrank)
crsiValid = not na(crsi) and not na(crsi[1]) and not na(crsi[2])

// ============================================================
// RENKO DIRECTION
// ============================================================
bullishBar = close > open
bearishBar = close < open
firstBearish = bearishBar and bullishBar[1]
firstBullish = bullishBar and bearishBar[1]

// ============================================================
// HELPERS
// ============================================================
isPeak(idx) =>
    close[idx] > open[idx] and close[idx - 1] < open[idx - 1]

isTrough(idx) =>
    close[idx] < open[idx] and close[idx - 1] > open[idx - 1]

greenRunBefore(idx) =>
    count = 0
    i = idx
    while i < idx + 50 and close[i] > open[i]
        count += 1
        i += 1
    count

redRunBefore(idx) =>
    count = 0
    i = idx
    while i < idx + 50 and close[i] < open[i]
        count += 1
        i += 1
    count

// ============================================================
// PATTERN 7 — Renko Double Top (Bearish)
// ============================================================
recentPeakIdx = -1
for i = 1 to 5
    if isPeak(i)
        recentPeakIdx := i
        break

foundDoubleTop = false
if show_P7 and recentPeakIdx > 0 and bearishBar
    lvl = high[recentPeakIdx]
    for i = (recentPeakIdx + dtMinBetween) to dtLookback
        if isPeak(i)
            if math.abs(high[i] - lvl) <= dtTolerance
                if greenRunBefore(i) >= dtMinBricks
                    foundDoubleTop := true
                    break

p7 = isLastClosed and foundDoubleTop and firstBearish and not na(macdLine)

// ============================================================
// PATTERN 8 — Renko Double Bottom (Bullish)
// ============================================================
recentTroughIdx = -1
for i = 1 to 5
    if isTrough(i)
        recentTroughIdx := i
        break

foundDoubleBottom = false
if show_P8 and recentTroughIdx > 0 and bullishBar
    lvl = low[recentTroughIdx]
    for i = (recentTroughIdx + dtMinBetween) to dtLookback
        if isTrough(i)
            if math.abs(low[i] - lvl) <= dtTolerance
                if redRunBefore(i) >= dtMinBricks
                    foundDoubleBottom := true
                    break

p8 = isLastClosed and foundDoubleBottom and firstBullish and not na(macdLine)

// ============================================================
// PATTERN 11 — 7 Up (Bearish)
// ============================================================
greenRun = 0
gIdx = 1
while gIdx < 100 and close[gIdx] > open[gIdx]
    greenRun += 1
    gIdx += 1

macdRiseChange = macdLine - macdLine[1]
macdRisePct = macdLine != 0 ? (macdRiseChange / math.abs(macdLine)) * 100 : 0.0

p11 = show_P11 and isLastClosed and firstBearish and greenRun >= minUpBricks and macdValid and macdRisePct <= macdMaxPct

// ============================================================
// PATTERN 12 — 7 Down (Bullish)
// ============================================================
redRun = 0
rIdx = 1
while rIdx < 100 and close[rIdx] < open[rIdx]
    redRun += 1
    rIdx += 1

macdDropChange = macdLine[1] - macdLine
macdDropPct = macdLine != 0 ? (macdDropChange / math.abs(macdLine)) * 100 : 0.0

p12 = show_P12 and isLastClosed and firstBullish and redRun >= minDownBricks and macdValid and macdDropPct <= macdMaxPct

// ============================================================
// PATTERN 13 — Renko Spikes (Bearish)
// ============================================================
crsiRise = crsi - crsi[1]
p13 = show_P13 and isLastClosed and wtoBearish and crsiValid and crsiRise > 2.5 and crsiRise < 10 and crsi[2] > 60

// ============================================================
// PATTERN 14 — Renko Spikes (Bullish)
// ============================================================
crsiDrop = crsi[1] - crsi
p14 = show_P14 and isLastClosed and wtoBullish and crsiValid and crsiDrop > 2.5 and crsiDrop < 10 and crsi[2] < 40

// ============================================================
// SMILEY FACE — drawn to the right of the last closed bar
// when ANY signal fires
// ============================================================
anySignal = p7 or p8 or p11 or p12 or p13 or p14

var label smileyLabel = na
if anySignal
    label.delete(smileyLabel)
    smileyLabel := label.new(x=bar_index + 5, y=close, text="😀😀\n😀😀", xloc=xloc.bar_index, yloc=yloc.price, color=color.yellow, textcolor=color.yellow, style=label.style_none, size=size.huge)

// ============================================================
// STATUS LINE — Nick reads this from the DOM
// ============================================================
signalCode = p7 ? 7 : p8 ? 8 : p11 ? 11 : p12 ? 12 : p13 ? 13 : p14 ? 14 : 0
plot(signalCode, "SIGNAL", display=display.status_line)

// ============================================================
// ALERTS
// ============================================================
alertcondition(p7,  "P7 Renko Double Top",      "Renko Double Top bearish signal")
alertcondition(p8,  "P8 Renko Double Bottom",    "Renko Double Bottom bullish signal")
alertcondition(p11, "P11 7 Up (Bearish)",        "7 Up bearish signal")
alertcondition(p12, "P12 7 Down (Bullish)",      "7 Down bullish signal")
alertcondition(p13, "P13 Renko Spikes (Bearish)","Renko Spikes bearish signal")
alertcondition(p14, "P14 Renko Spikes (Bullish)","Renko Spikes bullish signal")
````

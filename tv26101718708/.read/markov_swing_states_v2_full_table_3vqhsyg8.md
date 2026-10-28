# Markov Swing States v2 - Full Table

- url: https://www.tradingview.com/script/3VQhsyG8-Markov-Swing-States-v2-Full-Table/
- type: indicator
- pine_id: PUB;000ade36943648c69a2c7c2b3c12e043
- version: 1.0

## Description

The indicator should be read as a probability dashboard by states, not as a classic "buy/sell" signal. 
It does 3 things:
-classifies each day into a technical state;
-counts the history of how it has moved from one state to another;
-shows you if the current state has a favorable probability for bullish continuation.

S3 Breakout occurs when:
-price closes above the maximum of the last 20 days;
-volume is above the average volume;
-price is above EMA 9;
-EMA 9 is above EMA 21.
This is the most important state for aggressive entry.

S4 Bull Trend occurs when:
-price is above EMA 9;
-EMA 9 > EMA 21;
-price is above SMA 50;
-RSI is above 55.
This is the state of an already confirmed bullish trend. It is not necessarily the best entry, but it is a good state for maintaining the position.

S5 Healthy Pullback occurs when:
-price retests EMA 9 or EMA 21;
-closes above EMA;
-EMA 9 > EMA 21;
-price stays above SMA 50;
-RSI stays above 50.
This is the healthy pullback condition. It is not bearish. It means the price is cooling down after a rally.

S6 Distribution occurs when:
-price loses EMA 21;
-MACD histogram deteriorates.
This is the risk condition.

The table is the most important part.
Samples = This is the sample size.
P -> Bull = Shows the probability that the next day will be S4 Bull Trend.
P -> Pullback = Shows the probability that the stock will stay or enter a healthy pullback.
P -> Dist = Shows the probability of distribution. For long entries, you want this value to be small.

## Source Code

````pine
//@version=6
indicator("Markov Swing States v2 - Full Table", overlay=true, max_labels_count=500)

// === INPUTS ===
breakoutLen     = input.int(20, "Breakout lookback", minval=5)
volMult         = input.float(1.5, "Volume multiplier for breakout", minval=1.0, step=0.1)
retestTolPct    = input.float(0.5, "EMA retest tolerance (%)", minval=0.0, step=0.1)
minSamples      = input.int(20, "Minimum historical samples", minval=5)
minProbBull     = input.float(55.0, "Minimum probability to Bull Trend (%)", minval=1, maxval=100)

showTable = input.bool(true, "Show Markov table")
showEMAs  = input.bool(true, "Show EMA/SMA lines")

// === VISUAL CLEANUP ===
groupVisual = "Visual Cleanup"

showS3Labels    = input.bool(true,  "Show S3 Breakout labels", group=groupVisual)
showS5Labels    = input.bool(false, "Show S5 Pullback labels", group=groupVisual)
showS6Labels    = input.bool(false, "Show S6 Distribution labels", group=groupVisual)
showMLongLabels = input.bool(true,  "Show M-LONG labels", group=groupVisual)

signalLookbackBars = input.int(
     80,
     "Show labels only on last N bars",
     minval=5,
     maxval=500,
     group=groupVisual
)

// === INDICATORS ===
ema9   = ta.ema(close, 9)
ema21  = ta.ema(close, 21)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

rsi = ta.rsi(close, 14)

[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)
macdHistDelta = macdHist - macdHist[1]

vol20 = ta.sma(volume, 20)
high20Prev = ta.highest(high, breakoutLen)[1]

retestTol = retestTolPct / 100.0

// === STATE CONSTANTS ===
const int ST_NEUTRAL = 0
const int ST_BEAR    = 1
const int ST_ACC     = 2
const int ST_BREAK   = 3
const int ST_BULL    = 4
const int ST_PULL    = 5
const int ST_DIST    = 6
const int N_STATES   = 7

// === STATE NAME ===
f_stateName(int s) =>
    switch s
        ST_NEUTRAL => "Neutral"
        ST_BEAR    => "S1 Bear / Weak"
        ST_ACC     => "S2 Accumulation"
        ST_BREAK   => "S3 Breakout"
        ST_BULL    => "S4 Bull Trend"
        ST_PULL    => "S5 Healthy Pullback"
        ST_DIST    => "S6 Distribution"
        => "Unknown"

// === STATE CLASSIFICATION ===
enoughData = not na(sma50) and not na(ema21) and not na(rsi) and not na(vol20) and not na(high20Prev)

f_getState() =>
    int s = ST_NEUTRAL

    if enoughData
        breakout =
             close > high20Prev and
             volume > volMult * vol20 and
             close > ema9 and
             ema9 > ema21

        retest9 =
             low <= ema9 * (1 + retestTol) and
             close > ema9

        retest21 =
             low <= ema21 * (1 + retestTol) and
             close > ema21

        healthyPullback =
             (retest9 or retest21) and
             ema9 > ema21 and
             close > sma50 and
             rsi > 50

        bullTrend =
             close > ema9 and
             ema9 > ema21 and
             close > sma50 and
             rsi > 55

        distribution =
             close < ema21 and
             macdHistDelta < 0

        bearWeak =
             close < sma50 and
             ema9 < ema21 and
             rsi < 45

        accumulation =
             math.abs(close / sma50 - 1.0) < 0.05 and
             rsi >= 45 and
             rsi <= 55

        if breakout
            s := ST_BREAK
        else if healthyPullback
            s := ST_PULL
        else if bullTrend
            s := ST_BULL
        else if distribution
            s := ST_DIST
        else if bearWeak
            s := ST_BEAR
        else if accumulation
            s := ST_ACC
        else
            s := ST_NEUTRAL

    s

state = f_getState()

// === MARKOV ARRAYS ===
// counts[from_state, to_state]
var counts = array.new_int(N_STATES * N_STATES, 0)
var totals = array.new_int(N_STATES, 0)

// Count transition from previous confirmed bar to current confirmed bar.
// Bar states are the correct Pine mechanism for limiting logic to specific bar executions. 
// TradingView documents barstate variables for exactly this type of control.
if barstate.isconfirmed and enoughData and enoughData[1] == true
    fromState = state[1]
    toState   = state

    idx = fromState * N_STATES + toState

    array.set(counts, idx, array.get(counts, idx) + 1)
    array.set(totals, fromState, array.get(totals, fromState) + 1)

// === FUNCTIONS FOR PROBABILITY ===
f_prob(int fromS, int toS) =>
    total = array.get(totals, fromS)
    cnt   = array.get(counts, fromS * N_STATES + toS)
    total > 0 ? cnt * 100.0 / total : na

f_fmtProb(float p) =>
    na(p) ? "n/a" : str.tostring(p, "#.0") + "%"

f_fmtInt(int x) =>
    str.tostring(x)

// === CURRENT STATE METRICS ===
rowTotalCurrent = array.get(totals, state)
probToBull      = f_prob(state, ST_BULL)

validMarkovLong =
     (state == ST_BREAK or state == ST_PULL) and
     rowTotalCurrent >= minSamples and
     not na(probToBull) and
     probToBull >= minProbBull

// === PLOTS ===
plot(showEMAs ? ema9 : na, "EMA 9", color=color.yellow)
plot(showEMAs ? ema21 : na, "EMA 21", color=color.orange)
plot(showEMAs ? sma50 : na, "SMA 50", color=color.aqua)
plot(showEMAs ? sma200 : na, "SMA 200", color=color.blue)

// === LABELS ===
// === CLEAN LABELS ===
// Recomandare: păstrăm graficul curat.
// S3 și M-LONG sunt cele mai importante pentru intrare.
// S5 poate fi activat doar dacă vrei să vezi pullback-urile.
// S6 rămâne OFF default, ca să nu încarce graficul.

plotshape(
     showS3Labels and state == ST_BREAK,
     title="S3 Breakout",
     style=shape.labelup,
     text="S3",
     location=location.belowbar,
     color=color.new(color.green, 0),
     textcolor=color.white,
     size=size.tiny,
     show_last=signalLookbackBars
)

plotshape(
     showS5Labels and state == ST_PULL,
     title="S5 Healthy Pullback",
     style=shape.circle,
     text="",
     location=location.belowbar,
     color=color.new(color.teal, 0),
     textcolor=color.white,
     size=size.tiny,
     show_last=signalLookbackBars
)

plotshape(
     showS6Labels and state == ST_DIST,
     title="S6 Distribution",
     style=shape.xcross,
     text="",
     location=location.abovebar,
     color=color.new(color.red, 0),
     textcolor=color.white,
     size=size.tiny,
     show_last=signalLookbackBars
)

plotshape(
     showMLongLabels and validMarkovLong,
     title="Markov Long Setup",
     style=shape.triangleup,
     text="LONG",
     location=location.belowbar,
     color=color.new(color.lime, 0),
     textcolor=color.black,
     size=size.small,
     show_last=signalLookbackBars
)

// === TABLE ===
// Pine tables are designed for fixed-position dashboards and should generally be updated on the last bar.
var table dash = table.new(position.bottom_right, 5, N_STATES + 3, border_width=1)

if barstate.islast and showTable
    table.clear(dash, 0, 0, 4, N_STATES + 2)

    // Header
    table.cell(dash, 0, 0, "Current State", bgcolor=color.new(color.gray, 75))
    table.cell(dash, 1, 0, f_stateName(state), bgcolor=color.new(color.gray, 75))
    table.cell(dash, 2, 0, "Samples", bgcolor=color.new(color.gray, 75))
    table.cell(dash, 3, 0, f_fmtInt(rowTotalCurrent), bgcolor=color.new(color.gray, 75))
    table.cell(dash, 4, 0, "P->Bull " + f_fmtProb(probToBull), bgcolor=color.new(color.gray, 75))

    // Column names
    table.cell(dash, 0, 1, "Source State", bgcolor=color.new(color.gray, 85))
    table.cell(dash, 1, 1, "Samples", bgcolor=color.new(color.gray, 85))
    table.cell(dash, 2, 1, "P -> Bull", bgcolor=color.new(color.gray, 85))
    table.cell(dash, 3, 1, "P -> Pullback", bgcolor=color.new(color.gray, 85))
    table.cell(dash, 4, 1, "P -> Dist", bgcolor=color.new(color.gray, 85))

    for s = 0 to N_STATES - 1
        totalS = array.get(totals, s)
        pBull  = f_prob(s, ST_BULL)
        pPull  = f_prob(s, ST_PULL)
        pDist  = f_prob(s, ST_DIST)

        row = s + 2
        rowBg = s == state ? color.new(color.yellow, 70) : color.new(color.black, 90)

        table.cell(dash, 0, row, f_stateName(s), bgcolor=rowBg)
        table.cell(dash, 1, row, f_fmtInt(totalS), bgcolor=rowBg)
        table.cell(dash, 2, row, f_fmtProb(pBull), bgcolor=rowBg)
        table.cell(dash, 3, row, f_fmtProb(pPull), bgcolor=rowBg)
        table.cell(dash, 4, row, f_fmtProb(pDist), bgcolor=rowBg)

// === ALERTS ===
alertcondition(validMarkovLong, "Markov Long Setup", "Markov Long Setup detected")
alertcondition(state == ST_BREAK, "S3 Breakout", "S3 Breakout detected")
alertcondition(state == ST_PULL, "S5 Healthy Pullback", "S5 Healthy Pullback detected")
alertcondition(state == ST_DIST, "S6 Distribution", "S6 Distribution detected")
````

<!-- tradingview-pine-id: PUB;44738f6fbf614816a335c858067b0581 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Smart AVWAPs

Source: https://www.tradingview.com/script/b9a2Obu5-Smart-AVWAPs/

## Description

## Smart AVWAPs

Smart AVWAPs is a multi-anchored VWAP indicator designed for swing traders who want to identify areas where several important volume-weighted price levels converge.

Instead of anchoring VWAPs to every minor swing, the indicator automatically creates AVWAPs from selected high-importance events:

* High relative volume swing highs and lows
* Earnings gaps
* 52-week highs and lows
* Major reversal candles with elevated volume

The indicator keeps the most recent active AVWAPs on the chart, making it easier to visually identify price zones where multiple anchored VWAPs overlap or compress.

### How to Use

AVWAP convergence can highlight areas where participants anchored to different market events have similar volume-weighted cost bases.

For swing trading, these areas can be monitored as potential support, resistance, consolidation, or breakout zones.

A typical workflow is:

1. Look for several AVWAPs converging within a narrow price range.
2. Observe how price behaves around the convergence area.
3. Wait for confirmation such as a strong breakout, reclaim, increased relative volume, or successful retest.
4. Use broader trend, market structure, and risk management before taking a position.

AVWAP convergence itself is not intended to be an automatic buy or sell signal.

### Inputs

**Active AVWAPs**
Controls the maximum number of recent AVWAP anchors displayed.

**Pivot Left / Right**
Controls the sensitivity of swing-high and swing-low detection.

**Minimum RVOL**
Requires a swing or reversal candle to have elevated volume relative to its recent average.

**Earnings Gap %**
Defines the minimum price gap required for an earnings event to create an anchor.

**Reversal ATR**
Controls how large a reversal candle must be relative to ATR before it qualifies as a significant anchor.

### Intended Use

The indicator is primarily designed for daily-chart swing trading, but the settings can be adjusted for other timeframes and trading styles.

It is best used as a visual confluence tool rather than as a standalone trading system.

For research and educational purposes only. This indicator does not provide financial advice or guarantee future mar

---

## Source Code

````pine
//@version=6
indicator("Smart AVWAPs", overlay=true)

// SETTINGS
src = input.source(hlc3, "Source")
maxA = input.int(8, "Active AVWAPs", 1, 8)
L = input.int(5, "Pivot Left")
R = input.int(5, "Pivot Right")
rvolMin = input.float(1.5, "Min RVOL", step=0.1)
gapMin = input.float(3.0, "Earnings Gap %", step=0.5)
atrMult = input.float(1.0, "Reversal ATR", step=0.1)

// BASE DATA
avgVol = ta.sma(volume, 20)[1]
rvol = avgVol > 0 ? volume / avgVol : na
atr = ta.atr(14)
cumPV = ta.cum(src * volume)
cumV = ta.cum(volume)

// ARRAYS
var pvs = array.new<float>()
var vols = array.new<float>()
var bars = array.new<int>()

add(float pv, float vol, int b) =>
    if not na(pv) and not array.includes(bars, b)
        array.unshift(pvs, pv)
        array.unshift(vols, vol)
        array.unshift(bars, b)
        if array.size(pvs) > maxA
            array.pop(pvs), array.pop(vols), array.pop(bars)

avwap(int i) =>
    float v = na
    if array.size(pvs) > i
        dv = cumV - array.get(vols, i)
        if dv > 0
            v := (cumPV - array.get(pvs, i)) / dv
    v

// 1. HIGH-RVOL PIVOTS
ph = ta.pivothigh(high, L, R)
pl = ta.pivotlow(low, L, R)

if not na(ph) and rvol[R] >= rvolMin
    add(cumPV[R + 1], cumV[R + 1], bar_index - R)

if not na(pl) and rvol[R] >= rvolMin
    add(cumPV[R + 1], cumV[R + 1], bar_index - R)

// 2. EARNINGS GAP
earn = request.earnings(syminfo.tickerid, earnings.actual,
     gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true)

gap = math.abs(open - close[1]) / close[1] * 100
earnGap = (not na(earn) or not na(earn[1])) and gap >= gapMin

// 3. 52-WEEK EXTREMES
h52 = request.security(syminfo.tickerid, "D",
     ta.highest(high[1], 252), lookahead=barmerge.lookahead_off)

l52 = request.security(syminfo.tickerid, "D",
     ta.lowest(low[1], 252), lookahead=barmerge.lookahead_off)

new52H = high > h52
new52L = low < l52

// 4. MAJOR REVERSALS
rng = high - low
body = math.max(math.abs(close - open), syminfo.mintick)
uw = high - math.max(open, close)
lw = math.min(open, close) - low

bullEngulf = close > open and close[1] < open[1] and close >= open[1]
bearEngulf = close < open and close[1] > open[1] and close <= open[1]

hammer = lw >= body * 2 and uw <= body
star = uw >= body * 2 and lw <= body

reversal = rng >= atr * atrMult and rvol >= rvolMin and
     (bullEngulf or bearEngulf or hammer or star)

// ADD CURRENT BAR ANCHOR
if earnGap or new52H or new52L or reversal
    add(cumPV[1], cumV[1], bar_index)

// PLOTS
plot(avwap(0), "AVWAP 1", color.blue, 2)
plot(avwap(1), "AVWAP 2", color.orange, 2)
plot(avwap(2), "AVWAP 3", color.green)
plot(avwap(3), "AVWAP 4", color.red)
plot(avwap(4), "AVWAP 5", color.purple)
plot(avwap(5), "AVWAP 6", color.teal)
plot(avwap(6), "AVWAP 7", color.fuchsia)
plot(avwap(7), "AVWAP 8", color.gray)
````

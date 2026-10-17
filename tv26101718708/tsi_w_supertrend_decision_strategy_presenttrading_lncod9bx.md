# TSI w SuperTrend decision - Strategy [presentTrading]

- url: https://www.tradingview.com/script/lncoD9BX-TSI-w-SuperTrend-decision-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;1371d391abc84ff6885984cf94818e68
- version: 1.0

## Description

This strategy aims to improve upon the performance of Traidngview's newly published "Trend Strength Index" indicator by incorporating the SuperTrend for better trade execution and risk management. Enjoy :)

█ Introduction and How it is Different

The "TSI with SuperTrend Decision - Strategy"  combines the Trend Strength Index (TSI) with SuperTrend indicators to determine entry and exit points. Unlike traditional strategies that rely solely on one indicator, this method leverages the strengths of both TSI and SuperTrend to provide a more nuanced and adaptive trading strategy. 

This dual approach allows for capturing trends more effectively, especially in volatile markets.

BTCUSD 8h LS Performance
[image]https://www.tradingview.com/x/TpzULldT/[/image]

█ Strategy, How it Works: Detailed Explanation

🔶 Trend Strength Index (TSI)

The TSI is a momentum oscillator that shows both the direction and strength of a trend. It is calculated by comparing the price movement with the bar index over a specified period. The formula for TSI is as follows:

```
TSI = (PC / |PC|)
where:
PC = Change in price over the period
```

In this strategy, TSI is calculated using the closing prices and a default period of 64 bars. The TSI values help identify overbought and oversold conditions, providing signals for potential market reversals.

🔶 SuperTrend Indicator

The SuperTrend is a trend-following indicator based on the average true range (ATR). It helps in identifying the direction of the market trend. The SuperTrend calculation involves:

```
SuperTrend = HLC3 ± (Factor * ATR)
where:
HLC3 = (High + Low + Close) / 3
Factor = User-defined multiplier
ATR = Average True Range over a period
```

The SuperTrend settings in this strategy include a length of 10 bars and a factor of 3.0.

Last Bull Cycle of BTC
[image]https://www.tradingview.com/x/f2wKEET2/[/image]

🔶 Entry and Exit Conditions

The strategy uses the TSI and SuperTrend together to determine entry and exit points:

- Long Entry: When the SuperTrend indicates a downward trend (st.d < 0) and the TSI is above the oversold level (-0.241).
- Long Exit: When the SuperTrend indicates an upward trend (st.d > 0) and the TSI is below the overbought level (0.241).
- Short Entry: When the SuperTrend indicates an upward trend (st.d > 0) and the TSI is below the overbought level (0.241).
- Short Exit: When the SuperTrend indicates a downward trend (st.d < 0) and the TSI is above the oversold level (-0.241).

█ Trade Direction
The strategy allows users to select the trade direction through the `tradeDirection` input. The options are:
- Both: Enables both long and short trades.
- Long: Enables only long trades.
- Short: Enables only short trades.

█ Default Settings
- TSI Length: 64
- SuperTrend Length: 10
- SuperTrend Factor: 3.0
- Trade Direction: Both
- Take Profit (%): 30.0
- Stop Loss (%): 20.0

Impact of Default Settings
- TSI Length: A longer TSI period smooths out noise but may lag in identifying trends. A shorter period is more responsive but can generate false signals.
- SuperTrend Length: A shorter length provides quicker signals but can be prone to whipsaws. A longer length is more reliable but may delay entries and exits.
- SuperTrend Factor: A higher factor increases the distance of the SuperTrend from the price, reducing sensitivity to minor price fluctuations.
- Trade Direction: Allows flexibility in trading strategies by enabling both long and short trades based on market conditions.
- Take Profit and Stop Loss: These settings manage risk by automatically closing trades at predefined profit or loss levels. Higher percentages provide larger potential gains but also higher risk.

## Source Code

````pine
//@version=5
strategy("TSI w SuperTrend decision - Strategy [presentTrading]", overlay=false, precision=3, commission_value=0.1, commission_type=strategy.commission.percent, slippage=1, currency=currency.USD, default_qty_type=strategy.percent_of_equity, default_qty_value=10, initial_capital=10000)

tradeDirection = input.string("Both", "Trading Direction", options=["Both", "Long", "Short"])
period = input.int(64, "TSI Length", minval=2)
TPSLCondition = input.string("None", "TPSL Condition", options=["TP", "SL", "Both", "None"])
takeProfitPerc = input.float(30.0, title="Take Profit (%)")
stopLossPerc = input.float(20.0, title="Stop Loss (%)")

bullishColorInput = input.color(color.new(#089981, 90), "Bullish Color")
bearishColorInput = input.color(color.new(#F23645, 90), "Bearish Color")

tsi = ta.correlation(close, bar_index, period)

tsiPlot = plot(tsi, "Trend Strength Index", color=#7E57C2)
hline(0, "TSI Middle Band", color=color.new(#787B86, 50))
hline(1, "TSI Bullish Band", color=color.new(bullishColorInput, 0))
hline(-1, "TSI Bearish Band", color=color.new(bearishColorInput, 0))

midLinePlot = plot(0, color=na, editable=false, display=display.none)
fill(tsiPlot, midLinePlot, 1, 0, top_color=bullishColorInput, bottom_color=color.new(bullishColorInput, 100), title="Bullish Gradient Fill")
fill(tsiPlot, midLinePlot, 0, -1, top_color=color.new(bearishColorInput, 100), bottom_color=bearishColorInput, title="Bearish Gradient Fill")

type bar
    float o = na
    float h = na
    float l = na
    float c = na

type supertrend_
    float s = na
    int d = na

method src(bar b, simple string src) =>
    float x = switch src
        'oc2' => math.avg(b.o, b.c)
        'hl2' => math.avg(b.h, b.l)
        'hlc3' => math.avg(b.h, b.l, b.c)
        'ohlc4' => math.avg(b.o, b.h, b.l, b.c)
        'hlcc4' => math.avg(b.h, b.l, b.c, b.c)
    x

method atr(bar b, simple int len) =>
    float tr = na(b.h[1]) ? b.h - b.l : math.max(math.max(b.h - b.l, math.abs(b.h - b.c[1])), math.abs(b.l - b.c[1]))
    len == 1 ? tr : ta.rma(tr, len)

method st(bar b, simple float factor, simple int len) =>
    float atr = b.atr(len)
    float up = b.src('hl2') + factor * atr
    up := up < nz(up[1]) or b.c[1] > nz(up[1]) ? up : nz(up[1])
    float dn = b.src('hl2') - factor * atr
    dn := dn > nz(dn[1]) or b.c[1] < nz(dn[1]) ? dn : nz(dn[1])
    float st = na
    int dir = na
    dir := switch
        na(atr[1]) => 1
        st[1] == nz(up[1]) => dir := b.c > up ? -1 : +1
        => dir := b.c < dn ? +1 : -1
    st := dir == -1 ? dn : up
    supertrend_.new(st, dir)

var string tp = 'Choose an indicator source of which to base the SuperTrend on.'
var string g1 = "Entry/Exit: SuperTrend Settings", var string gu = "UI Options"
src = tsi
len = input.int(10, "SuperTrend Length", inline='1', group=g1)
mlt = input.float(3.0, "SuperTrend Factor", 1, 20, 0.5, inline='1', group=g1)
clbl = input.bool(true, "Contrarian Signals", group=gu)
colu = input.color(#008cff, "Bull Color", group=gu)
cold = input.color(#ff4800, "Bear Color", group=gu)

bar b = bar.new(nz(src[1]), math.max(nz(src[1]), src), math.min(nz(src[1]), src), src)
float tr = b.atr(len)
supertrend_ st = b.st(mlt, len)

color cst = switch st.d
    +1 => cold
    -1 => colu

t = plot(st.d > 0 ? st.s : na, 'Bear ST', cst, 1, plot.style_linebr)
d = plot(st.d < 0 ? st.s : na, 'Bull ST', cst, 1, plot.style_linebr)
i = plot(st.d, 'Direction', display=display.none)
c = plot(b.src('oc2'), 'Filler', display=display.none)

fill(t, c, color.new(cold, 90))
fill(d, c, color.new(colu, 90))

bool scon = clbl and math.sign(ta.change(st.d)) == 1 ? true : false
bool bcon = clbl and math.sign(ta.change(st.d)) == -1 ? true : false

plotshape(scon ? st.s + tr / 3 : na, 'Sell Signal', shape.labeldown, location.absolute, color.new(cold, 60), 0, '𝓢', chart.fg_color)
plotshape(bcon ? st.s - tr / 3 : na, 'Buy Signal', shape.labelup, location.absolute, color.new(colu, 60), 0, '𝓑', chart.fg_color)

// Draw horizontal lines at TSI levels 0.3 and -0.3
hline(0.241, "TSI Level 0.3", color=#7ef3c6)
hline(-0.241, "TSI Level -0.3", color=#f07f7f)

// Entry/Exit conditions
LongEntry = st.d < 0 and tsi > -0.241
LongExit = st.d > 0 and tsi < 0.241
ShortEntry = st.d > 0 and tsi < 0.241
ShortExit = st.d < 0 and tsi > -0.241

// Strategy logic
if (tradeDirection == "Long" or tradeDirection == "Both")
    if (LongEntry)
        strategy.entry("Long Entry", strategy.long)

if (tradeDirection == "Short" or tradeDirection == "Both")
    if (ShortEntry)
        strategy.entry("Short Entry", strategy.short)

if (tradeDirection == "Long" or tradeDirection == "Both")
    if (LongExit)
        strategy.close("Long Entry")

if (tradeDirection == "Short" or tradeDirection == "Both")
    if (ShortExit)
        strategy.close("Short Entry")

// Apply Take Profit and Stop Loss conditions
if (TPSLCondition == "TP" or TPSLCondition == "Both")
    strategy.exit("TakeProfit_Long", "Long Entry", limit=close * (1 + takeProfitPerc / 100))
    strategy.exit("TakeProfit_Short", "Short Entry", limit=close * (1 - takeProfitPerc / 100))

if (TPSLCondition == "SL" or TPSLCondition == "Both")
    strategy.exit("StopLoss_Long", "Long Entry", stop=close * (1 - stopLossPerc / 100))
    strategy.exit("StopLoss_Short", "Short Entry", stop=close * (1 + stopLossPerc / 100))
````

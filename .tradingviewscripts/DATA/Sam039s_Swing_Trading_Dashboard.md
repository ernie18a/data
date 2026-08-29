<!-- tradingview-pine-id: PUB;0ec99bd6ab364f1f9f361c2c0395674a -->
<!-- tradingviewscripts-format: 1 -->
# Sam&#039;s Swing Trading Dashboard

Source: https://www.tradingview.com/script/V3EBkocH-Swing-Trader-s-Buy-Signal/

## Description

A Buy or Strong Buy signal triggers when multiple independent technical factors align simultaneously. Instead of relying on a single indicator (which often produces false signals), this dashboard evaluates confluent technical layers: Macro Trend, Short-Term Momentum, Institutional Volume, and Relative Strength.

Breakdown of Dashboard Elements
Trend (Overall Structure)

What it checks: Confirms whether Price > SMA20 > SMA50 > SMA200.

Why it triggers a Buy: Institutional traders trade in the direction of the macro trend. A bullish trend hierarchy ensures you are not buying into a falling knife or fighting a broader downtrend.

RSI (Relative Strength Index)

What it checks: Measures price momentum speed (RSI > 50 gives +1 pt, RSI > 60 gives +1 pt).

Why it triggers a Buy: An RSI above 50 indicates buyers are in control of momentum. Crossing above 60 signifies accelerating momentum without entering extreme overbought exhaustion.

Stoch RSI (Stochastic RSI Crossover)

What it checks: Evaluates if the Fast line %K is above %D (k > d) and recovering from oversold territory (k > 20).

Why it triggers a Buy: RSI provides the macro momentum, but Stoch RSI provides precise swing timing. A bullish %K > %D crossover pinpoints the exact moment a brief pullback ends and the upward swing resumes.

RS vs SPY (Relative Strength vs. Benchmark)

What it checks: Compares the asset's performance directly against the market index (AMEX:SPY).

Why it triggers a Buy: Outperforming stocks lead market rallies. Positive RS momentum (+1 to +2 pts) confirms that institutions are actively accumulating this specific asset faster than the broader market.

Price > SMA20 (Short-Term Trend Filter)

What it checks: Verifies if current price is trading above its 20-period Simple Moving Average.

Why it triggers a Buy: The 20 SMA represents the short-term swing baseline. Trading above it confirms immediate buyer control and validates short-term breakout momentum.

Price > SMA50 (Medium-Term Trend Filter)

What it checks: Verifies if current price is trading above its 50-period Simple Moving Average.

Why it triggers a Buy: The 50 SMA is the primary benchmark for institutional support. Staying above this level proves medium-term pullbacks are being bought rather than sold.

Volume (Institutional Participation)

What it checks: Compares current bar volume against its 20-period average (HIGH = >120%, VERY HIGH = >150%).

Why it triggers a Buy: Price moves without high volume lack conviction. Above-average volume confirms "smart money" accumulation, providing the fuel required for a sustained breakout.

Score (Confluence Aggregator)What it checks: Sums up the binary conditions across all indicators (Maximum score = 11).

Why it triggers a Buy: A BUY requires a score $\ge 7$ alongside an early bull trend, while a STRONG BUY requires a score $\ge 9$ with fully aligned trends, relative strength, and RSI momentum. This eliminates guesswork by requiring a strict mathematical majority of positive technical factors before triggering an entry.

---

## Source Code

````pine
//@version=6
indicator("Sam's Swing Trading Dashboard", overlay=true)

//─────────────────────────────────────
// INPUTS
//─────────────────────────────────────
benchmark   = input.symbol("AMEX:SPY", "Benchmark")
rsiLength   = input.int(14, "RSI Length")
stochLength = input.int(14, "Stoch RSI Length")
smoothK     = input.int(3, "Stoch RSI K")
smoothD     = input.int(3, "Stoch RSI D")
rsLength    = input.int(20, "RS Lookback")
volLength   = input.int(20, "Volume Average Length")

showMAs     = input.bool(true, "Show 10/20/50/200 SMA")
showBg      = input.bool(false, "Show Signal Background")

//─────────────────────────────────────
// MOVING AVERAGES
//─────────────────────────────────────
sma10  = ta.sma(close, 10)
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

plot(showMAs ? sma10 : na, "SMA 10", color=color.yellow, linewidth=2)
plot(showMAs ? sma20 : na, "SMA 20", color=color.orange, linewidth=2)
plot(showMAs ? sma50 : na, "SMA 50", color=color.blue, linewidth=2)
plot(showMAs ? sma200 : na, "SMA 200", color=color.red, linewidth=2)

//─────────────────────────────────────
// RSI
//─────────────────────────────────────
rsi = ta.rsi(close, rsiLength)

// RSI Trend Conditions
rsiBull = rsi > 50
rsiStrong = rsi > 60
rsiWeak = rsi < 40

//─────────────────────────────────────
// STOCHASTIC RSI
//─────────────────────────────────────
rsiLow  = ta.lowest(rsi, stochLength)
rsiHigh = ta.highest(rsi, stochLength)

stochRsiRaw =
     rsiHigh != rsiLow ?
     100 * (rsi - rsiLow) / (rsiHigh - rsiLow) :
     0

k = ta.sma(stochRsiRaw, smoothK)
d = ta.sma(k, smoothD)

stochBullCross = ta.crossover(k, d)
stochBearCross = ta.crossunder(k, d)

stochOversold = k < 20
stochOverbought = k > 80

stochRecovering =
     k > d and
     k > 20

//─────────────────────────────────────
// RELATIVE STRENGTH VS SPY
//─────────────────────────────────────
benchmarkClose = request.security(
     benchmark,
     timeframe.period,
     close,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

rsRatio = close / benchmarkClose

rsMomentum =
     not na(rsRatio[rsLength]) ?
     ((rsRatio / rsRatio[rsLength]) - 1) * 100 :
     na

rsBull = rsMomentum > 0
rsStrong = rsMomentum > 2
rsWeak = rsMomentum < 0

//─────────────────────────────────────
// TREND CONDITIONS
//─────────────────────────────────────
above20 = close > sma20
above50 = close > sma50
above200 = close > sma200

bullTrend =
     close > sma20 and
     sma20 > sma50 and
     sma50 > sma200

earlyBullTrend =
     close > sma20 and
     close > sma50

bearTrend =
     close < sma20 and
     close < sma50

//─────────────────────────────────────
// VOLUME
//─────────────────────────────────────
avgVolume = ta.sma(volume, volLength)

highVolume = volume > avgVolume * 1.2
veryHighVolume = volume > avgVolume * 1.5

//─────────────────────────────────────
// SCORING SYSTEM
//─────────────────────────────────────
score = 0

score += close > sma20 ? 1 : 0
score += close > sma50 ? 1 : 0
score += close > sma200 ? 1 : 0

score += sma20 > sma50 ? 1 : 0
score += sma50 > sma200 ? 1 : 0

score += rsi > 50 ? 1 : 0
score += rsi > 60 ? 1 : 0

score += rsMomentum > 0 ? 1 : 0
score += rsMomentum > 2 ? 1 : 0

score += k > d ? 1 : 0
score += highVolume ? 1 : 0

// Maximum possible score = 11

//─────────────────────────────────────
// SIGNAL CLASSIFICATION
//─────────────────────────────────────
strongBuy =
     score >= 9 and
     bullTrend and
     rsBull and
     rsiBull

buy =
     score >= 7 and
     earlyBullTrend and
     rsBull

watch =
     score >= 5 and
     not strongBuy and
     not buy

avoid =
     score < 5 or
     bearTrend

//─────────────────────────────────────
// SIGNAL COLORS
//─────────────────────────────────────
signalColor =
     strongBuy ? color.green :
     buy ? color.lime :
     watch ? color.orange :
     color.red

signalText =
     strongBuy ? "STRONG BUY" :
     buy ? "BUY" :
     watch ? "WATCH" :
     "AVOID"

//─────────────────────────────────────
// OPTIONAL BACKGROUND
//─────────────────────────────────────
bgcolor(
     showBg ?
     color.new(signalColor, 90) :
     na
)

//─────────────────────────────────────
// BUY / SELL LABELS
//─────────────────────────────────────
newStrongBuy =
     strongBuy and
     not strongBuy[1]

newBuy =
     buy and
     not buy[1]

plotshape(
     newStrongBuy,
     title="Strong Buy Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="STRONG\nBUY",
     textcolor=color.white,
     size=size.small
)

plotshape(
     newBuy,
     title="Buy Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.tiny
)

//─────────────────────────────────────
// DASHBOARD
//─────────────────────────────────────
var table dashboard =
     table.new(
         position.top_right,
         2,
         9,
         border_width=1
     )

if barstate.islast

    table.cell(
         dashboard,
         0,
         0,
         "SWING DASHBOARD",
         bgcolor=color.black,
         text_color=color.white
    )

    table.cell(
         dashboard,
         1,
         0,
         signalText,
         bgcolor=signalColor,
         text_color=color.white
    )

    // Trend
    table.cell(
         dashboard,
         0,
         1,
         "Trend"
    )

    table.cell(
         dashboard,
         1,
         1,
         bullTrend ? "Bullish" :
         bearTrend ? "Bearish" :
         "Mixed",
         bgcolor=
             bullTrend ? color.green :
             bearTrend ? color.red :
             color.orange,
         text_color=color.white
    )

    // RSI
    table.cell(
         dashboard,
         0,
         2,
         "RSI"
    )

    table.cell(
         dashboard,
         1,
         2,
         str.tostring(rsi, "#.0"),
         bgcolor=
             rsiStrong ? color.green :
             rsiBull ? color.lime :
             rsiWeak ? color.red :
             color.orange,
         text_color=color.white
    )

    // Stoch RSI
    table.cell(
         dashboard,
         0,
         3,
         "Stoch RSI"
    )

    table.cell(
         dashboard,
         1,
         3,
         str.tostring(k, "#.0"),
         bgcolor=
             stochRecovering ? color.green :
             stochOversold ? color.orange :
             stochOverbought ? color.red :
             color.gray,
         text_color=color.white
    )

    // Relative Strength
    table.cell(
         dashboard,
         0,
         4,
         "RS vs SPY"
    )

    table.cell(
         dashboard,
         1,
         4,
         str.tostring(rsMomentum, "#.00") + "%",
         bgcolor=
             rsStrong ? color.green :
             rsBull ? color.lime :
             color.red,
         text_color=color.white
    )

    // SMA 20
    table.cell(
         dashboard,
         0,
         5,
         "Price > SMA20"
    )

    table.cell(
         dashboard,
         1,
         5,
         above20 ? "YES" : "NO",
         bgcolor=
             above20 ? color.green :
             color.red,
         text_color=color.white
    )

    // SMA 50
    table.cell(
         dashboard,
         0,
         6,
         "Price > SMA50"
    )

    table.cell(
         dashboard,
         1,
         6,
         above50 ? "YES" : "NO",
         bgcolor=
             above50 ? color.green :
             color.red,
         text_color=color.white
    )

    // Volume
    table.cell(
         dashboard,
         0,
         7,
         "Volume"
    )

    table.cell(
         dashboard,
         1,
         7,
         veryHighVolume ? "VERY HIGH" :
         highVolume ? "HIGH" :
         "NORMAL",
         bgcolor=
             veryHighVolume ? color.green :
             highVolume ? color.lime :
             color.gray,
         text_color=color.white
    )

    // Score
    table.cell(
         dashboard,
         0,
         8,
         "Score"
    )

    table.cell(
         dashboard,
         1,
         8,
         str.tostring(score) + " / 11",
         bgcolor=signalColor,
         text_color=color.white
    )

//─────────────────────────────────────
// ALERTS
//─────────────────────────────────────
alertcondition(
     newStrongBuy,
     title="Strong Buy Signal",
     message="New STRONG BUY signal detected."
)

alertcondition(
     newBuy,
     title="Buy Signal",
     message="New BUY signal detected."
)

alertcondition(
     stochBullCross,
     title="Stoch RSI Bullish Cross",
     message="Stoch RSI bullish crossover detected."
)
//─────────────────────────────────────
// ALERTS & NOTIFICATIONS
//─────────────────────────────────────
// Dynamic Alert (Fires popup / app notification on real-time bar close)
if newStrongBuy
    alert("STRONG BUY Signal Detected on " + syminfo.ticker, alert.freq_once_per_bar_close)

// Legacy Alert Conditions (Selectable from the TradingView Create Alert menu)
alertcondition(
     newStrongBuy,
     title="Strong Buy Signal",
     message="New STRONG BUY signal detected."
)
````

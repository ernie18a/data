# EMA Channel + MTF Bias Table

- url: https://www.tradingview.com/script/crJHSWAv-EMA-Channel-MTF-Bias-Table/
- type: indicator
- pine_id: PUB;7db8f84afd294c70aaefd008f2b70430
- version: 1.0

## Description

What This System Is Trying To Do
This system separates trading into 2 jobs:
1. The Table
Answers:

“Should I even be looking for longs or shorts?”

2. The EMA Signals
Answers:

“Okay, WHEN exactly should I enter?”

That’s the whole idea.
Most beginners mix those together and take random signals.
This system tries to stop that.

Step 1 — Understand The Table
You’ll see rows like:
TFTrendVWAPQuality4HBULLSTRONG BULLA1HBULLBULLA15MBULLBULLA+5MBULLBULLB

What Each Column Means
TF = Timeframe


4H = big trend


1H = main intraday direction


15M = current market condition


5M = entry timeframe


Think of it like:


4H = weather forecast


1H = today's trend


15M = current momentum


5M = your trigger



TREND Column
This tells you market direction.
BULL
Market trending upward.
Prefer:


buy setups


long continuations



BEAR
Market trending downward.
Prefer:


shorts


bearish continuation



RANGE
Market moving sideways.
Usually:


weaker entries


slower moves


more fakeouts


Be cautious.

CHOP
Bad conditions.
This means:


random movement


fake breakouts


whipsaws


Usually avoid trading completely.
This is one of the most important things the table gives you.

VWAP Column
This shows whether price is favorably positioned relative to VWAP.
The orange line on chart = VWAP.

STRONG BULL
Price strongly above VWAP.
This is ideal for longs.

BULL
Above VWAP.
Still favorable for longs.

BEAR
Below VWAP.
Favorable for shorts.

STRONG BEAR
Strong downside pressure below VWAP.
Best short conditions.

QUALITY Column
This grades how clean the market currently is.

A+ / A
Best conditions.
Usually:


strong trend


clean movement


continuation likely


These are your best trades.

B
Okay conditions.
Tradable.
But less clean.

C
Messy conditions.
Usually:


chop starting


weaker momentum


overlapping candles


Need caution.

D
Avoid trading.
Market quality is poor.

OVERALL Bias
At bottom you'll see:
FAVOR LONGS
Means:


higher timeframes aligned bullish


Focus mainly on BUY setups.

FAVOR SHORTS
Focus mainly on SELL setups.

MIXED / CHOP
Timeframes disagree.
This is where beginners lose money forcing trades.
Usually:


wait


reduce trading


be patient



Step 2 — Wait For EMA Entry Signal
After the table gives direction:
NOW wait for actual entry.

BUY Signal
You’ll see:


white BUY label


This means:
crossover(close, emaHigh)
Basically:

price regained momentum upward


SELL Signal
You’ll see:


white SELL label


Means:

momentum turning downward


The BIG Mistake Beginners Make
They take:
every BUY
every SELL
Don’t do that.
The table decides IF signals are worth taking.

How To Actually Trade It
LONG Example
GOOD Setup
Table says:
4H = BULL
1H = BULL
15M = BULL
VWAP = BULL
Quality = A

Then:
wait for 5M BUY signal
THAT is a high-quality setup.

BAD Setup
Table says:
4H = BEAR
1H = BEAR
But 5M prints BUY.
Ignore it.
That’s usually just a temporary bounce against the trend.

Easiest Beginner Rule
ONLY TRADE:
when 4H + 1H agree.
That alone removes tons of bad trades.

What You're Looking For
You want:
aligned timeframes
clean quality
VWAP agreement
THEN EMA trigger
That creates:
cleaner continuation entries
less emotional trading
less random guessing

Best Times To Trade
This system works best during:
NY open
post-ORB expansion
trend days
sessions

It works worst during:
lunch
sideways compression
low volatility

Simplest Possible Workflow
Step 1
Check overall bias.
FAVOR LONGS?
Only hunt buys.
FAVOR SHORTS?
Only hunt sells.
MIXED?
Trade less or wait.

Step 2
Check quality.
A or A+?
Good conditions.
C or D?
Be careful.

Step 3
Wait for EMA signal.
Then enter.

Beginner Mistake To Avoid
Do [b]NOT[/b] chase giant candles.
Best entries usually happen:
- after pullbacks
- after small pauses
- After reclaim candles

NOT after huge expansion candles.

The Goal Of This System
This system is trying to help you:
- stop trading against trend
- stop forcing chop trades
- stop taking random signals

only trade when market conditions support it
That’s the real edge.

## Source Code

````pine
//@version=6
indicator("EMA Channel + MTF Bias Table", overlay=true)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
smaLength = input.int(20, "SMA Length")
emaLength = input.int(9, "EMA Length")

showTable = input.bool(true, "Show Bias Table")

//━━━━━━━━━━━━━━━━━━━
// BASE CHART LOGIC
//━━━━━━━━━━━━━━━━━━━
sma20 = ta.sma(close, smaLength)

emaHigh = ta.ema(high, emaLength)
emaLow  = ta.ema(low, emaLength)

plot(sma20,
     title="SMA 20",
     color=close >= sma20 ? color.green : color.red,
     linewidth=2)

p1 = plot(emaHigh, color=color.blue, linewidth=1)
p2 = plot(emaLow, color=color.blue, linewidth=1)

fill(p1, p2, color=color.new(color.blue, 90))

//━━━━━━━━━━━━━━━━━━━
// VWAP
//━━━━━━━━━━━━━━━━━━━
vwapVal = ta.vwap(hlc3)
plot(vwapVal, color=color.orange, linewidth=2, title="VWAP")

//━━━━━━━━━━━━━━━━━━━
// ENTRY SIGNALS
//━━━━━━━━━━━━━━━━━━━
aboveTrend = close > sma20
belowTrend = close < sma20

rawBuy  = ta.crossover(close, emaHigh) and aboveTrend
rawSell = ta.crossunder(close, emaLow) and belowTrend

plotshape(rawBuy,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.white,
     text="BUY",
     textcolor=color.black,
     size=size.tiny)

plotshape(rawSell,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.white,
     text="SELL",
     textcolor=color.black,
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━━
// BACKGROUND TREND
//━━━━━━━━━━━━━━━━━━━
bgcolor(
 aboveTrend ? color.new(color.green, 92) :
 belowTrend ? color.new(color.red, 92) : na)

//━━━━━━━━━━━━━━━━━━━
// MTF FUNCTIONS
//━━━━━━━━━━━━━━━━━━━
f_getTrend(tf) =>
    fast = request.security(syminfo.tickerid, tf, ta.ema(close, 9))
    slow = request.security(syminfo.tickerid, tf, ta.ema(close, 21))
    px   = request.security(syminfo.tickerid, tf, close)
    vw   = request.security(syminfo.tickerid, tf, ta.vwap(hlc3))
    atr  = request.security(syminfo.tickerid, tf, ta.atr(14))

    distance = math.abs(fast - slow)
    compressed = distance < atr * 0.05

    bull = fast > slow and px > vw
    bear = fast < slow and px < vw

    state = bull ? "BULL" :
      bear ? "BEAR" :
      compressed ? "RANGE" : "CHOP"

    state

f_getVWAPState(tf) =>
    px = request.security(syminfo.tickerid, tf, close)
    vw = request.security(syminfo.tickerid, tf, ta.vwap(hlc3))

    dist = math.abs(px - vw)
    atrv = request.security(syminfo.tickerid, tf, ta.atr(14))

    strongBull = px > vw and dist > atrv * 0.30
    strongBear = px < vw and dist > atrv * 0.30

    result = strongBull ? "STRONG BULL" :
      strongBear ? "STRONG BEAR" :
      px > vw ? "BULL" :
      px < vw ? "BEAR" : "NEUTRAL"

    result

f_getQuality(tf) =>
    fast = request.security(syminfo.tickerid, tf, ta.ema(close, 9))
    slow = request.security(syminfo.tickerid, tf, ta.ema(close, 21))
    atrv = request.security(syminfo.tickerid, tf, ta.atr(14))

    spread = math.abs(fast - slow)

    score = spread / atrv

    quality = score > 0.35 ? "A+" :
      score > 0.25 ? "A" :
      score > 0.15 ? "B" :
      score > 0.08 ? "C" : "D"

    quality

//━━━━━━━━━━━━━━━━━━━
// TIMEFRAME STATES
//━━━━━━━━━━━━━━━━━━━
trend4H  = f_getTrend("240")
trend1H  = f_getTrend("60")
trend15M = f_getTrend("15")
trend5M  = f_getTrend("5")

vwap4H  = f_getVWAPState("240")
vwap1H  = f_getVWAPState("60")
vwap15M = f_getVWAPState("15")
vwap5M  = f_getVWAPState("5")

quality4H  = f_getQuality("240")
quality1H  = f_getQuality("60")
quality15M = f_getQuality("15")
quality5M  = f_getQuality("5")

//━━━━━━━━━━━━━━━━━━━
// OVERALL BIAS
//━━━━━━━━━━━━━━━━━━━
allBull = trend4H == "BULL" and trend1H == "BULL" and trend15M == "BULL"
allBear = trend4H == "BEAR" and trend1H == "BEAR" and trend15M == "BEAR"

overallBias = allBull ? "FAVOR LONGS" :
 allBear ? "FAVOR SHORTS" : "MIXED / CHOP"

biasColor = allBull ? color.green :
 allBear ? color.red : color.orange

//━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━
var table biasTable = table.new(position.top_right, 4, 6,
 border_width=1)

if barstate.islast and showTable

    table.cell(biasTable, 0, 0, "TF", bgcolor=color.black, text_color=color.white)
    table.cell(biasTable, 1, 0, "TREND", bgcolor=color.black, text_color=color.white)
    table.cell(biasTable, 2, 0, "VWAP", bgcolor=color.black, text_color=color.white)
    table.cell(biasTable, 3, 0, "QUALITY", bgcolor=color.black, text_color=color.white)

    // 4H
    table.cell(biasTable, 0, 1, "4H")
    table.cell(biasTable, 1, 1, trend4H,
         text_color=trend4H == "BULL" ? color.lime : trend4H == "BEAR" ? color.red : color.orange)
    table.cell(biasTable, 2, 1, vwap4H)
    table.cell(biasTable, 3, 1, quality4H)

    // 1H
    table.cell(biasTable, 0, 2, "1H")
    table.cell(biasTable, 1, 2, trend1H,
         text_color=trend1H == "BULL" ? color.lime : trend1H == "BEAR" ? color.red : color.orange)
    table.cell(biasTable, 2, 2, vwap1H)
    table.cell(biasTable, 3, 2, quality1H)

    // 15M
    table.cell(biasTable, 0, 3, "15M")
    table.cell(biasTable, 1, 3, trend15M,
         text_color=trend15M == "BULL" ? color.lime : trend15M == "BEAR" ? color.red : color.orange)
    table.cell(biasTable, 2, 3, vwap15M)
    table.cell(biasTable, 3, 3, quality15M)

    // 5M
    table.cell(biasTable, 0, 4, "5M")
    table.cell(biasTable, 1, 4, trend5M,
         text_color=trend5M == "BULL" ? color.lime : trend5M == "BEAR" ? color.red : color.orange)
    table.cell(biasTable, 2, 4, vwap5M)
    table.cell(biasTable, 3, 4, quality5M)

    // OVERALL
    table.cell(biasTable, 0, 5, "OVERALL",
         bgcolor=color.black,
         text_color=color.white)

    table.cell(biasTable, 1, 5, overallBias,
         bgcolor=biasColor,
         text_color=color.white)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(rawBuy, title="BUY ALERT", message="EMA Channel BUY")
alertcondition(rawSell, title="SELL ALERT", message="EMA Channel SELL")
````

# MHIDa ATR-Distance Dip

- url: https://www.tradingview.com/script/l0M9OW6D/
- type: indicator
- pine_id: PUB;44dbf6d9d7d14a688ab49cfe70e8ab9d
- version: 1.0

## Description

WHAT IT DOES

ATR-Distance Dip is a visual context tool that measures how far price has stretched BELOW a reference moving average - not in fixed percentage points, but in ATR units (units of volatility). The same setting adapts by itself: in a calm market a small move already counts as far, in a choppy market price must travel further before it counts.

It draws:
- The reference average (EMA, default 20).
- A dynamic threshold line at (average - N x ATR), default N = 3.5.
- A shaded stretch zone between the average and the threshold.
- A small triangle when the previous bar closed below the threshold and the current bar closes back up (the first comeback candle after the drop).
- An optional alert on that comeback event, so you can be notified to LOOK at the chart.

HOW IT IS CALCULATED

- average = EMA(close, 20)
- ATR = simple moving average of the True Range over 14 bars (a plain SMA of the true range, not Wilder's smoothing)
- threshold = average - N x ATR (N adjustable, default 3.5; a sensible exploratory range is 2.5 / 3.5 / 4.5)
- highlight condition (evaluated on closed bars): previous close below the previous threshold AND current close above the previous close.

WHY ATR INSTEAD OF A FIXED PERCENTAGE

A fixed distance like 5% below the average means different things in quiet and in volatile regimes. Measuring the stretch in ATR units keeps the meaning consistent: 3.5 ATR below the average is unusually stretched both in slow and in fast markets, because the yardstick itself follows current volatility.

HOW TO USE IT

Add it to a standard candlestick chart. Watch the shaded zone: when price falls below the threshold line, the market is unusually stretched below its average for the current volatility regime. The triangle marks only the first attempt to come back (a close above the previous close), which is where a chart reader may want to start paying attention. Adjust the average length, the ATR length and the multiple to your instrument and timeframe: the defaults are a starting point, not the one true configuration.

HONESTY NOTE

This is a context and chart-reading aid, not a trading system: it issues no entries, no exits and simulates no trades. Directional markers are drawn only on standard chart types. It is not financial advice. You always decide.

## Source Code

````pine
//@version=6
// ATR-Distance Dip — a context aid to help you read what you see
// on the chart. It is NOT a signal, NOT financial advice, and NOT a standalone winner.
// You always decide.
//
// WHAT IT DOES (in plain words):
//   It measures how far price has moved BELOW one of its moving averages, but the
//   distance is NOT a fixed percentage: it is measured in ATR, i.e. in "units of
//   volatility". This way the threshold adapts on its own: when the market is calm
//   a few points are enough to be "far", when it is choppy price must travel further.
//   It highlights when price is N times ATR below the average AND then tries to come
//   back (the first candle that turns up again after the drop).
//
// HONESTY: this is a VISUAL context aid for reading the chart. It is not a winning
//   system on its own. Measuring distance in ATR (rather than in fixed %) only helps
//   frame a sharp move relative to the current volatility — it does not tell you what
//   to do. Treat the defaults as a starting point, not "the" configuration. You decide.
//
// LOGIC (the core rule):
//     ok = close[1] < ema20[1] - K*atr[1]  AND  close > close[1]
//   average = EMA(20), atr = simple moving average of the true range over 14,
//   K = the ATR multiple (a sensible exploratory range is 2.5 / 3.5 / 4.5).
//   This script does NOT simulate trades: it only draws the context. The defaults are
//   a starting point, not "the" configuration.

indicator("MHIDa ATR-Distance Dip", shorttitle="ATR-Dip", overlay=true)

// ---------------- INPUTS (defaults = a starting point, not truth) ----------------
lenMedia = input.int(20, "Average length (EMA)", minval=2,
     tooltip="The reference average from which the distance is measured. Default 20 as a starting point.")
lenAtr   = input.int(14, "ATR length", minval=1,
     tooltip="Volatility (ATR) period. Default 14 as a starting point.")
multAtr  = input.float(3.5, "ATR multiple (N times below the average)", minval=0.1, step=0.1,
     tooltip="How many ATRs below the average to consider price 'far down'. Exploratory range: 2.5 / 3.5 / 4.5. Default 3.5 as a starting point.")
mostraBanda  = input.bool(true,  "Show threshold band (average - N*ATR)")
mostraMedia  = input.bool(true,  "Show the average")

// ---------------- CALCULATIONS ----------------
// ATR as a SIMPLE moving average of the true range (not Wilder's ATR).
media  = ta.ema(close, lenMedia)
atrSma = ta.sma(ta.tr(true), lenAtr)

// dynamic threshold: the "distance line" below the average, in units of ATR
soglia = media - multAtr * atrSma

// current distance expressed in ATR (to read the context, it is not a signal)
distanzaInAtr = atrSma > 0 ? (media - close) / atrSma : na

// Condition (causal, on a closed bar):
//   previous bar below the threshold  +  current candle coming back (closes above the previous)
sottoSoglia   = close[1] < (media[1] - multAtr * atrSma[1])
rientroVerde  = close > close[1]
dipRientro    = not na(media[1]) and not na(atrSma[1]) and sottoSoglia and rientroVerde

// ---------------- DRAWING ----------------
pMedia  = plot(mostraMedia  ? media  : na, "Average (EMA)",            color=color.new(color.orange, 0), linewidth=2)
pSoglia = plot(mostraBanda  ? soglia : na, "Threshold average - N*ATR", color=color.new(color.teal, 0),   linewidth=1)

// light fill between average and threshold: the "drop zone" below the average
fill(pMedia, pSoglia, color=color.new(color.teal, 90), title="Zone below the average (in ATR)")

// visual marker when price is below the threshold and comes back
plotshape(dipRientro and chart.is_standard, title="Come-back from below the ATR threshold", style=shape.triangleup,
     location=location.belowbar, color=color.new(color.teal, 0), size=size.tiny,
     text="ATR-dip")

// non-invasive notification (if you want an alert, use it to LOOK, not to act automatically)
alertcondition(dipRientro, title="MHIDa ATR-Dip - come-back",
     message="MHIDa ATR-Distance Dip: price came back from below average - N*ATR. A context aid, not a signal. Look at the chart and decide for yourself.")
````

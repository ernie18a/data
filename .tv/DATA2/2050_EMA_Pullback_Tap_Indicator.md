<!-- tradingview-pine-id: PUB;7d17227ffb3a4645822b64cb337efa05 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 20/50 EMA Pullback Tap Indicator

Source: https://www.tradingview.com/script/e6Z3CyAj-20-50-EMA-Pullback-Tap-Indicator/

## Description

The 20/50 EMA Pullback Tap Indicator is a simple price-action based tool designed to identify potential entries after a momentum shift, rather than entering immediately when the 20 EMA crosses the 50 EMA.

The core idea is simple:

The EMA cross identifies a change in momentum. The pullback provides the entry.

How It Works
🟢 Long Setup
The 20 EMA crosses above the 50 EMA.
The indicator arms a bullish setup.
No trade is signalled on the crossover.
Price must first establish itself above the 20 EMA.
The indicator then waits for price to pull back and touch the 20 EMA.
When the 20 EMA is tapped, a BUY signal is generated.
Only one long signal is generated from that crossover.
If price does not touch the 20 EMA within 30 candles, the setup expires.
🔴 Short Setup

The short setup works in the opposite direction:

The 20 EMA crosses below the 50 EMA.
The indicator arms a bearish setup.
No trade is signalled on the crossover.
Price must first establish itself below the 20 EMA.
The indicator waits for price to pull back and touch the 20 EMA.
When the 20 EMA is tapped, a SELL signal is generated.
Only one short signal is generated from that crossover.
If price does not touch the 20 EMA within 30 candles, the setup expires.
Why Use the Pullback?

A common problem with EMA crossover systems is entering immediately on the crossover. By the time the cross occurs, price may already have moved significantly.

This indicator takes a different approach.

The 20/50 crossover is treated as confirmation that momentum has shifted, while the 20 EMA pullback is used as the potential entry location.

This can provide a more structured entry instead of chasing the initial move.

No Additional Indicators

The indicator intentionally keeps the methodology simple.

It does not use:

RSI
MACD
VWAP
Volume filters
Additional trend indicators
Multiple confirmation indicators

The system is built around just:

20 EMA + 50 EMA + Pullback to the 20 EMA

Signal Behaviour

The indicator is designed to detect the EMA tap during the active candle rather than requiring the candle to close first.

This means signals can appear while the current candle is developing when price reaches the 20 EMA.

Because of this behaviour, traders should understand that a live-bar signal can change or disappear before the candle closes depending on market movement and TradingView's realtime calculations.

Setup Expiration

Each crossover creates a new setup.

If the required pullback does not occur within the configured number of candles, the setup is automatically cancelled.

The default expiration is:

30 candles

This prevents an old EMA crossover from generating an entry long after the original momentum shift.

Recommended Use

The indicator can be used on its own as a simple EMA pullback system or combined with a trader's own:

Support and resistance
Market structure
Liquidity levels
Risk management
Higher-timeframe analysis

However, these additional concepts are not required by the indicator itself.

Important Disclaimer

This indicator identifies potential setups based on the rules described above. A signal does not guarantee a profitable trade.

Always use appropriate risk management and test the indicator on your chosen market and timeframe before using it with real capital.

---

## Source Code

````pine
//@version=6
indicator("20/50 EMA Pullback Tap Indicator", overlay=true, max_labels_count=500)

//====================================================
// SETTINGS
//====================================================

grpEMA = "EMA Settings"

fastLength = input.int(20, "Fast EMA", minval=1, group=grpEMA)
slowLength = input.int(50, "Slow EMA", minval=1, group=grpEMA)

grpSetup = "Setup Rules"

setupExpiry = input.int(
     30,
     "Setup Expiry (Candles)",
     minval=1,
     group=grpSetup,
     tooltip="Number of candles allowed for price to touch the 20 EMA after the crossover.")

showSetupLabels = input.bool(
     true,
     "Show Setup Labels",
     group=grpSetup)

showExpiry = input.bool(
     true,
     "Show Expiry Labels",
     group=grpSetup)

showEMAs = input.bool(
     true,
     "Show 20/50 EMAs",
     group=grpSetup)

//====================================================
// EMAs
//====================================================

ema20 = ta.ema(close, fastLength)
ema50 = ta.ema(close, slowLength)

//====================================================
// CROSSOVER
//====================================================

bullCross = ta.crossover(ema20, ema50)
bearCross = ta.crossunder(ema20, ema50)

//====================================================
// SETUP STATE
//
//  0  = No setup
//  1  = Bullish setup armed
// -1  = Bearish setup armed
//
// Once a signal fires, that setup is finished.
// The next signal requires a NEW crossover.
//====================================================

var int setupState = 0
var int setupBar = na
var bool priceEstablishedAbove = false
var bool priceEstablishedBelow = false

//====================================================
// ARM NEW BULLISH SETUP
//====================================================

if bullCross
    setupState := 1
    setupBar := bar_index
    priceEstablishedAbove := false
    priceEstablishedBelow := false

//====================================================
// ARM NEW BEARISH SETUP
//====================================================

if bearCross
    setupState := -1
    setupBar := bar_index
    priceEstablishedAbove := false
    priceEstablishedBelow := false

//====================================================
// PRICE MUST ESTABLISH ON CORRECT SIDE OF 20 EMA
//====================================================

if setupState == 1 and bar_index > setupBar and close > ema20
    priceEstablishedAbove := true

if setupState == -1 and bar_index > setupBar and close < ema20
    priceEstablishedBelow := true

//====================================================
// SETUP AGE
//====================================================

setupAge =
     setupState != 0 and not na(setupBar)
     ? bar_index - setupBar
     : na

//====================================================
// SETUP EXPIRY
//====================================================
//
// If the 20 EMA is not touched within the allowed number
// of candles, the setup is cancelled.
//====================================================

bullExpired =
     setupState == 1 and
     setupAge >= setupExpiry

bearExpired =
     setupState == -1 and
     setupAge >= setupExpiry

if bullExpired
    setupState := 0
    setupBar := na
    priceEstablishedAbove := false

if bearExpired
    setupState := 0
    setupBar := na
    priceEstablishedBelow := false

//====================================================
// 20 EMA PULLBACK TOUCH
//====================================================
//
// LONG:
// Price first establishes above the 20 EMA.
// Then the candle's LOW touches/crosses the 20 EMA.
//
// SHORT:
// Price first establishes below the 20 EMA.
// Then the candle's HIGH touches/crosses the 20 EMA.
//
// The crossover candle itself cannot generate an entry.
//====================================================

longTap =
     setupState == 1 and
     priceEstablishedAbove and
     bar_index > setupBar and
     low <= ema20

shortTap =
     setupState == -1 and
     priceEstablishedBelow and
     bar_index > setupBar and
     high >= ema20

//====================================================
// SIGNALS
//====================================================

longSignal = longTap
shortSignal = shortTap

//====================================================
// COMPLETE SETUP AFTER SIGNAL
//====================================================
//
// This guarantees ONE signal per crossover.
// The next signal requires a new 20/50 crossover.
//====================================================

if longSignal
    setupState := 0
    setupBar := na
    priceEstablishedAbove := false

if shortSignal
    setupState := 0
    setupBar := na
    priceEstablishedBelow := false

//====================================================
// PLOTS
//====================================================

plot(
     showEMAs ? ema20 : na,
     title="20 EMA",
     color=color.orange,
     linewidth=2)

plot(
     showEMAs ? ema50 : na,
     title="50 EMA",
     color=color.blue,
     linewidth=2)

//====================================================
// CROSSOVER LABELS
//====================================================

plotshape(
     showSetupLabels and bullCross,
     title="Bullish Cross",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     text="20/50\nARMED",
     size=size.small)

plotshape(
     showSetupLabels and bearCross,
     title="Bearish Cross",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     text="20/50\nARMED",
     size=size.small)

//====================================================
// BUY / SELL SIGNALS
//====================================================

plotshape(
     longSignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.white,
     text="BUY",
     size=size.normal)

plotshape(
     shortSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     text="SELL",
     size=size.normal)

//====================================================
// EXPIRY LABELS
//====================================================

plotshape(
     showExpiry and bullExpired,
     title="Bullish Setup Expired",
     style=shape.xcross,
     location=location.abovebar,
     color=color.gray,
     text="EXPIRED",
     size=size.tiny)

plotshape(
     showExpiry and bearExpired,
     title="Bearish Setup Expired",
     style=shape.xcross,
     location=location.belowbar,
     color=color.gray,
     text="EXPIRED",
     size=size.tiny)

//====================================================
// ALERTS
//====================================================

alertcondition(
     bullCross,
     title="20/50 Bullish Cross",
     message="20 EMA crossed ABOVE 50 EMA — bullish setup armed. Wait for the 20 EMA pullback.")

alertcondition(
     bearCross,
     title="20/50 Bearish Cross",
     message="20 EMA crossed BELOW 50 EMA — bearish setup armed. Wait for the 20 EMA pullback.")

alertcondition(
     longSignal,
     title="20/50 BUY",
     message="20/50 EMA BUY — price pulled back and touched the 20 EMA.")

alertcondition(
     shortSignal,
     title="20/50 SELL",
     message="20/50 EMA SELL — price pulled back and touched the 20 EMA.")
````

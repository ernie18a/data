<!-- tradingview-pine-id: PUB;f45021026cea44f49d9e94a414b5ab55 -->
<!-- tradingviewscripts-format: 1 -->
# Mask Man 9 & Price Movement V2

Source: https://www.tradingview.com/script/CxrEDT92-Fibo-and-Price-movement-by-Maxtrader6876/

## Description

Fibo and Price movement by Maxtrader6876

This full-fledged TradingView Pine Script v6 Strategy turns the indicator logic into an automated backtesting system, complete with execution rules, order sizes, and customizable stop-loss parameters

How to Enter a BUY (Long) TradeTo enter a buy position, two conditions must align on the same candle:The Crossover: The market price must cross and close above the blue Mask Man line (9 EMA).The Momentum Check: The general price movement over the last 5 bars must be positive (higher highs/upward momentum).Action: Enter the trade immediately at the close of the candle when the green "BUY" triangle appears.

🔴 How to Enter a SELL (Short) TradeTo enter a short position, look for the exact opposite setup:The Crossunder: The market price must cross and close below the blue Mask Man line (9 EMA).The Momentum Check: The general price movement over the last 5 bars must be negative (lower lows/downward momentum).Action: Enter the trade immediately at the close of the candle when the red "SELL" triangle appears.

🛡️ Managing Risk (Exits)Once you are in a trade, the strategy manages your risk automatically using a 1:2 Risk-to-Reward ratio:Stop Loss (SL): Placed at 1.5% away from your entry price to protect your capital from sudden market reversals.Take Profit (TP): Placed at 3.0% away from your entry price to lock in profits automatically when the target is reached.Opposite Signal Exit: If a sell signal appears while you are in a buy position (or vice versa), the strategy will automatically flip the trade to match the new market direction.

Thank you

MaxTrader6876

---

## Source Code

````pine
//@version=6
indicator("Mask Man 9 & Price Movement V2", overlay=true)

// --- Inputs ---
int length      = input.int(9, title="Mask Man Length")
hlc3Src         = input.source(hlc3, title="Source")
int pmLength    = input.int(5, title="Price Movement Lookback")
bool showSignals = input.bool(true, title="Show Buy/Sell Signals")

// --- Mask Man Component (Length 9) ---
float maskMa    = ta.ema(hlc3Src, length)
plot(maskMa, color=color.blue, title="Mask Man EMA (9)")

// --- Price Movement V2 Logic ---
float priceChange = ta.change(hlc3Src, pmLength)
bool pmBull       = priceChange > 0
bool pmBear       = priceChange < 0

// --- Trigger Conditions ---
bool buyCond  = ta.crossover(hlc3Src, maskMa) and pmBull
bool sellCond = ta.crossunder(hlc3Src, maskMa) and pmBear

// --- Visual Alerts ---
plotshape(showSignals and buyCond, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="BUY")
plotshape(showSignals and sellCond, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

// --- Version 6 Dynamic Alert Triggers ---
if buyCond
    alert("Mask Man V2: BUY Signal Triggered!", alert.freq_once_per_bar_close)
if sellCond
    alert("Mask Man V2: SELL Signal Triggered!", alert.freq_once_per_bar_close)
````

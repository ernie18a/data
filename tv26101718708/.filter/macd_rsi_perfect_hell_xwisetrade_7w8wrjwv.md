# MACD RSI Perfect Hell [XWiseTrade]

- url: https://www.tradingview.com/script/7w8wrJwv-MACD-RSI-Perfect-Hell-XWiseTrade/
- type: indicator
- pine_id: PUB;c0c4d812630d432d9c6f067d60fd8dce
- version: 1.0

## Description

[b]MACD RSI Perfect Hell[/b]

Every trading course teaches the same "perfect" long setup: MACD crosses up, volume rises, RSI lifts off oversold, and price starts climbing — all at once. The textbook calls this confirmation heaven and tells you to buy. This indicator marks exactly those moments — and warns you instead of cheering them.

[b]Why it exists[/b]
The cleaner the textbook setup looks, the more dangerous it often is. When MACD, RSI, volume, and price all agree at the same instant, everyone watching those same standard indicators sees the same thing at the same time. The crowd piles in together. But a rally needs someone still left to buy — and at the textbook-perfect moment, most of them already have. That exhaustion is why "perfect" entries so often mark the spot where a move runs out of fuel. Perfect Heaven tends to be Perfect Hell. This tool is built to make those crowded moments visible, so you pause instead of chasing.

[b]How it works[/b]
A warning label is plotted only when all four classic conditions line up on the same bar — not one or two, all four:
[list=1]
[*]MACD line crosses its signal line (up for a bullish setup, down for bearish).
[*]Volume is rising — above its average and higher than the previous bar — so the move has participation behind it.
[*]RSI is just leaving an extreme — climbing out of oversold for a bull setup, dropping out of overbought for a bear setup.
[*]Price has already started moving in that direction over a short lookback.
[/list]
Requiring all four at once is deliberate. Any one or two of these fire constantly and mean little. Demanding the full "perfect" stack means the indicator stays silent almost all the time, and only speaks up at the rare moments when the setup is textbook-complete — which is exactly when the crowd is most committed and a reversal is most worth watching for.

[b]How to use it[/b]
Add it to any chart and timeframe. When a "⚠️ Perfect Hell" label appears above a bar, a textbook-perfect bullish setup has just formed; below a bar, a bearish one. Treat it as a caution flag, not a trigger: it's telling you the easy, obvious trade is now crowded. Use it to tighten risk, wait for a better location, or simply stay aware that the move may be closer to its end than its beginning. Alerts are available for both directions. A cooldown keeps labels from clustering.

[b]What makes it different[/b]
Almost every MACD/RSI tool is built to find confirmation and push you into the trade. This one is built on the opposite idea: that flawless confirmation is itself a warning. It uses the same well-known indicators most traders rely on, but reads their perfect alignment as a contrarian signal of crowding and exhaustion rather than a green light. That inversion — same inputs, opposite conclusion — is the whole point.

Inputs: MACD fast/slow/signal, RSI length and overbought/oversold levels, volume average length, price-move lookback, signal cooldown.

These are descriptive, contrarian caution signals for discretionary use. They are not buy/sell recommendations.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

//@version=6
indicator("MACD RSI Perfect Hell [XWiseTrade]", overlay=true, max_labels_count=500)

// ===== Inputs =====
fastLen  = input.int(12, "MACD fast", group="MACD")
slowLen  = input.int(26, "MACD slow", group="MACD")
sigLen   = input.int(9,  "MACD signal", group="MACD")
rsiLen   = input.int(14, "RSI length", group="RSI")
rsiOS    = input.int(30, "RSI oversold (bull setup leaves from here)", group="RSI")
rsiOB    = input.int(70, "RSI overbought (bear setup leaves from here)", group="RSI")
volLen   = input.int(20, "Volume average length", group="Volume")
priceLen = input.int(3,  "Price move lookback", minval=1, group="Price",
     tooltip="Bars used to confirm price has started moving in the signal direction")
cooldown = input.int(8,  "Signal cooldown (bars)", minval=0, group="Display")

// ===== MACD =====
[macdLine, signalLine, _] = ta.macd(close, fastLen, slowLen, sigLen)
crossUp   = ta.crossover(macdLine, signalLine)   // bullish cross
crossDown = ta.crossunder(macdLine, signalLine)  // bearish cross

// ===== RSI leaving an extreme =====
rsi = ta.rsi(close, rsiLen)
rsiLeavingOS = rsi > rsiOS and rsi[1] <= rsiOS   // RSI climbing out of oversold
rsiLeavingOB = rsi < rsiOB and rsi[1] >= rsiOB   // RSI dropping out of overbought

// ===== Volume rising (participation confirming the move) =====
avgVol     = ta.sma(volume, volLen)
volRising  = volume > avgVol and volume > volume[1]

// ===== Price already moving in the signal direction =====
priceUp   = close > close[priceLen]
priceDown = close < close[priceLen]

// ===== "Perfect Heaven" = every textbook condition aligns =====
// Bull: fresh cross up + rising volume + RSI leaving oversold + price rising
// This is the entry every textbook calls perfect. Precisely because everyone
// sees it, the crowd is already in -> it is often a Perfect Hell (a top trap).
heavenBull = crossUp   and volRising and rsiLeavingOS and priceUp
heavenBear = crossDown and volRising and rsiLeavingOB and priceDown

// ===== Cooldown =====
var int lastBull = -1000
var int lastBear = -1000
fireBull = heavenBull and (bar_index - lastBull > cooldown)
fireBear = heavenBear and (bar_index - lastBear > cooldown)
if fireBull
    lastBull := bar_index
if fireBear
    lastBear := bar_index

// ===== Labels: warning, not an entry =====
if fireBull
    label.new(bar_index, high, "⚠️ Perfect Hell", yloc=yloc.abovebar,
         color=color.new(color.orange,0), textcolor=color.white,
         style=label.style_label_down, size=size.small)
if fireBear
    label.new(bar_index, low, "⚠️ Perfect Hell", yloc=yloc.belowbar,
         color=color.new(color.orange,0), textcolor=color.white,
         style=label.style_label_up, size=size.small)

// ===== Alerts =====
alertcondition(fireBull, "Perfect Hell (bullish setup)", "Textbook-perfect bullish alignment formed - crowded setup, stay alert to a reversal")
alertcondition(fireBear, "Perfect Hell (bearish setup)", "Textbook-perfect bearish alignment formed - crowded setup, stay alert to a reversal")
````

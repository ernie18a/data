# Stockholm (LONG) Momentum Engine

- url: https://www.tradingview.com/script/x6zK0e9S-Stockholm-LONG-Momentum-Engine/
- type: indicator
- pine_id: PUB;733417b2d38a4b41b7b0c598378938d0
- version: 1.0

## Description

Stockholm (LONG) Momentum Engine

Stockholm (LONG) Momentum Engine is a long-only momentum continuation indicator designed specifically for small-cap stocks on NASDAQ, NYSE and OMX using 5-minute and 15-minute charts. The indicator was created to address a common weakness in many traditional momentum systems: exiting strong trend continuation moves too early during normal pullbacks.
Instead of relying on a simple moving average crossover or standalone momentum oscillator, this script combines multiple market structure components into a continuation-based framework intended to identify sustained bullish momentum while filtering weaker conditions.

The script combines:
• EMA 9 / EMA 21 trend structure
• VWAP positioning
• SMA 50 directional bias
• Relative volume expansion
• RSI momentum persistence
• Breakout continuation confirmation
• Confirmation-based exit filtering

The interaction between these components is designed to detect situations where momentum remains structurally strong, rather than reacting to every short-term retracement.

The indicator does not attempt to predict reversals or bottoms. Its primary focus is identifying:
* bullish continuation environments
* momentum persistence
* trend alignment
* breakout continuation
* relative strength during intraday trading

HOW THE LOGIC WORKS

BUY conditions require multiple bullish confirmations occurring simultaneously:
• Price above VWAP and SMA 50
• EMA 9 above EMA 21
• Relative volume expansion above average
• RSI momentum confirmation
• Breakout above recent highs
• Bullish candle continuation structure

This multi-condition approach is intended to reduce weak signals that can occur when using only a single indicator or crossover. The SELL logic is intentionally stricter and slower than the entry logic.

Instead of exiting immediately on minor pullbacks, the script waits for confirmation of:
* trend deterioration
* momentum weakness
* structure breakdown
* VWAP failure
* weakening EMA structure

The objective is to reduce premature exits during strong continuation trends commonly seen in momentum-driven small-cap stocks.

INTENDED USE

This indicator was designed for:
• Small-cap momentum stocks
• Intraday continuation trading
• Breakout trading
• Momentum-based swing trading
• Biotech runners
• Relative volume movers

Recommended timeframes:
• 5-minute
• 15-minute

The script is LONG ONLY and was not designed for:
* short selling
* forex
* cryptocurrency
* options trading
* mean reversion systems

CORE CONCEPT
The core concept behind Stockholm (LONG) Momentum Engine is that strong momentum stocks often continue trending longer than traditional indicators anticipate. The script therefore focuses more on continuation probability and trend persistence than short-term overbought or oversold conditions.

DISCLAIMER
This indicator is intended as a decision-support tool only and should not be considered financial advice. Market conditions can change rapidly, especially in volatile small-cap stocks. Always use proper risk management and independent judgment when trading.

## Source Code

````pine
//@version=5
indicator("Stockholm (LONG) Momentum Engine", overlay=true, max_labels_count=500)

// === INPUTS ===
sma_len       = input.int(50, "SMA Trend Length")
ema_fast_len  = input.int(9, "EMA Fast")
ema_slow_len  = input.int(21, "EMA Slow")
rsi_len       = input.int(14, "RSI Length")
vol_mult      = input.float(1.5, "Volume Multiplier", step=0.1)
breakout_len  = input.int(12, "Breakout Lookback")
min_bars_in_trade = input.int(5, "Min Bars Before SELL")

// === CORE ===
sma50    = ta.sma(close, sma_len)
ema9     = ta.ema(close, ema_fast_len)
ema21    = ta.ema(close, ema_slow_len)
rsi      = ta.rsi(close, rsi_len)
vwap_val = ta.vwap(close)

// === FILTERS ===
vol_avg  = ta.sma(volume, 20)
high_vol = volume > vol_avg * vol_mult
breakout = close > ta.highest(high[1], breakout_len)

trend_ok = close > sma50 and close > vwap_val and ema9 > ema21
momentum_ok = rsi > 50
structure_ok = close > open and close > high[1]

buy_signal_raw = trend_ok and momentum_ok and high_vol and breakout and structure_ok

// === POSITION STATE ===
var bool in_trade = false
var int entry_bar = na

buy_signal = buy_signal_raw and not in_trade

if buy_signal
    in_trade := true
    entry_bar := bar_index

bars_in_trade = in_trade and not na(entry_bar) ? bar_index - entry_bar : 0

// === VERY STRICT SELL LOGIC ===
trend_still_alive = close > vwap_val and close > sma50 and ema9 > ema21
real_trend_break = close < vwap_val and close < sma50 and ema9 < ema21
confirmed_break = close < low[1] and close[1] < low[2]
momentum_dead = rsi < 45

sell_signal = in_trade and bars_in_trade >= min_bars_in_trade and not trend_still_alive and real_trend_break and confirmed_break and momentum_dead

if sell_signal
    in_trade := false
    entry_bar := na

// === VISUALS ===
plot(sma50, color=color.new(color.orange, 35), linewidth=2, title="SMA 50")
plot(ema9, color=color.new(color.green, 20), linewidth=1, title="EMA 9")
plot(ema21, color=color.new(color.red, 20), linewidth=1, title="EMA 21")
plot(vwap_val, color=color.new(color.blue, 0), linewidth=2, title="VWAP")

plotshape(buy_signal, title="BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(sell_signal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)

// === ALERTS ===
alertcondition(buy_signal, title="BUY Alert", message="Stockholm LONG BUY")
alertcondition(sell_signal, title="SELL Alert", message="Stockholm LONG SELL")

// === INFO PANEL ===
var table t = table.new(position.top_left, 2, 9, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))
    table.cell(t, 1, 0, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))
    table.cell(t, 0, 1, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))
    table.cell(t, 1, 1, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))
    table.cell(t, 0, 2, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))
    table.cell(t, 1, 2, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))

    table.cell(t, 0, 3, "STATUS", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 3, in_trade ? "LONG" : "WAIT", bgcolor=in_trade ? color.green : color.gray, text_color=color.white)

    table.cell(t, 0, 4, "TREND", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 4, trend_ok ? "BULLISH" : "WEAK", bgcolor=trend_ok ? color.green : color.red, text_color=color.white)

    table.cell(t, 0, 5, "VOLUME", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 5, high_vol ? "HIGH" : "LOW", bgcolor=high_vol ? color.green : color.red, text_color=color.white)

    table.cell(t, 0, 6, "RSI", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 6, str.tostring(math.round(rsi)), bgcolor=rsi > 50 ? color.green : color.orange, text_color=color.white)

    table.cell(t, 0, 7, "MODE", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 7, "LONG ONLY", bgcolor=color.new(color.blue, 10), text_color=color.white)

    table.cell(t, 0, 8, "REGIME", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 8, trend_ok ? "TRADE" : "NO TRADE", bgcolor=trend_ok ? color.green : color.red, text_color=color.white)
````

# Stockholm (LONG) Momentum Engine

- url: https://www.tradingview.com/script/QpgAEMm1-Stockholm-LONG-Momentum-Engine/
- type: indicator
- pine_id: PUB;995e92db5f3344b78bfe8c9294158a05
- version: 1.0

## Description

# Stockholm (LONG) Momentum Engine

Stockholm (LONG) Momentum Engine is a custom-built momentum continuation indicator specifically designed for trading small-cap stocks on NASDAQ, NYSE and OMX using 5-minute and 15-minute timeframes. The purpose of the indicator is not simply to combine moving averages or standard momentum tools, but to solve a common problem in momentum trading:
Most traditional trend indicators exit strong runners too early during normal pullbacks.

This script was developed specifically for continuation trading in volatile small-cap momentum stocks, where maintaining exposure during trend persistence is often more important than reacting to every temporary retracement. The indicator combines multiple market structure components into a single long-only framework:

• EMA trend alignment (EMA 9 / EMA 21)
• VWAP institutional trend confirmation
• SMA 50 higher timeframe directional bias
• RSI momentum persistence
• Relative volume expansion detection
• Breakout continuation logic
• Confirmation-based sell filtering

Instead of generating signals from simple EMA crossovers, the script evaluates whether price action shows continuation characteristics commonly seen in strong momentum runners:

* Price holding above VWAP
* Bullish EMA structure
* Relative volume expansion
* Breakout continuation above recent highs
* Momentum persistence through RSI
* Bullish candle structure confirmation

The SELL logic is intentionally designed to be slower and stricter than traditional momentum systems.

The goal is to reduce premature exits during healthy continuation trends by requiring:
* confirmed structure weakness
* trend deterioration
* momentum loss
* multi-condition confirmation

before producing a SELL signal.

This creates a more trend-persistent system better suited for:
* small-cap momentum stocks
* biotech runners
* opening range continuation
* intraday breakouts
* trend continuation swings

The indicator is LONG ONLY and was not designed for:
* short selling
* forex
* crypto
* options
* mean reversion strategies

HOW TO USE THE INDICATOR
BUY signals appear when:
* price is above VWAP and SMA 50
* EMA 9 is above EMA 21
* volume expands above average
* RSI confirms momentum
* price breaks recent highs
* bullish candle continuation is detected

SELL signals appear only after:
* trend weakness is confirmed
* VWAP structure fails
* EMA structure weakens
* momentum deteriorates
* bearish continuation confirms

This makes the indicator better suited for traders who prefer:
* holding winners longer
* trend continuation
* momentum persistence
* reduced signal noise

BEST MARKETS
• NASDAQ small caps
• NYSE momentum stocks
• OMX momentum stocks
• Biotech runners
• Relative volume movers

   RECOMMENDED TIMEFRAMES
• 5-minute
• 15-minute

CORE PHILOSOPHY
The core philosophy behind Stockholm (LONG) Momentum Engine is:
Strong momentum stocks often remain stronger longer than traditional indicators expect.
The script attempts to identify continuation probability rather than reacting to every short-term pullback.
It focuses on trend persistence, momentum quality and continuation structure instead of short-term overbought/oversold conditions.

This indicator is a decision-support tool and should not be considered financial advice. 
/7Lasse

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

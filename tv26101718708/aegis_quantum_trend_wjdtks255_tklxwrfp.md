# Aegis Quantum Trend [wjdtks255]

- url: https://www.tradingview.com/script/TKLXWrFP/
- type: indicator
- pine_id: PUB;d658e9f1bc7745438614f4455ac583a4
- version: 1.0

## Description

Aegis Quantum Trend [wjdtks255]

A powerful, all-in-one trend following system that integrates ZLSMA (Zero Lag Moving Average), Advanced Dynamic Heikin-Ashi candles, and EMA trend filters to provide precise entry and exit signals.

[Key Features]

Zero Lag Trend: Utilizes ZLSMA to filter out market noise and capture trend shifts faster than standard moving averages.

Dynamic HA System: Advanced Heikin-Ashi candles with HMA smoothing, helping you visualize real market momentum.

Smart Signals: Automatically detects high-probability buy/sell points and provides clear exit signals based on volatility and trend reversal logic.

[How to Use]

Signals: Follow the 'BUY' and 'SELL' labels for entry. Use 'EXIT' labels to protect your capital and lock in profits.

Filters: Combine this tool with your primary market analysis. Ensure the volatility condition is met for higher signal reliability.

Customization: Adjust EMA lengths and Lookback settings in the indicator settings to align with your specific timeframe and trading style.

[Important Note for Best Experience]

Hide Default Candles: To prevent visual overlap and ensure the best clarity, please hide or disable the default price candles (or set chart style to 'Line') while using this indicator. The Aegis Dynamic HA system is designed to provide a cleaner and more precise view of market momentum on its own.

[Disclaimer]
This indicator is for educational purposes only and does not constitute financial advice. Trading involves significant risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wjdtks255

//@version=6
indicator("Aegis Quantum Trend [wjdtks255]", shorttitle="Aegis Quantum Trend [wjdtks255]", overlay=true, max_labels_count=500)

// [!] Disclaimer: This indicator is for educational and reference purposes only. 
// It does not constitute financial advice. Past performance does not guarantee future results.

// --- 1. ZLSMA 설정 ---
len_zlsma = input.int(32, title="ZLSMA Length")
offset_zlsma = input.int(0, title="ZLSMA Offset")
src_zlsma = input(close, title="ZLSMA Source")

lsma = ta.linreg(src_zlsma, len_zlsma, offset_zlsma)
lsma2 = ta.linreg(lsma, len_zlsma, offset_zlsma)
eq = lsma - lsma2
zlsma = lsma + eq

plot(zlsma, color=color.yellow, linewidth=3, title="ZLSMA")

// --- 2. EMA 설정 ---
fast_length = input.int(10, title="Fast EMA Length")
slow_length = input.int(30, title="Slow EMA Length")

// --- 3. Aegis Dynamic HA 설정 ---
smooth_len = input.int(7, title="HA Smoothing (HMA)")
mom_len = input.int(10, title="Momentum Length")
atr_len = input.int(14, title="ATR Length")

var float haOpen = na
haClose = (open + high + low + close) / 4
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + nz(haClose[1])) / 2
haHigh = math.max(high, math.max(haOpen, haClose))
haLow = math.min(low, math.min(haOpen, haClose))

fast_ema = ta.ema(haClose, fast_length)
slow_ema = ta.ema(haClose, slow_length)

plot(fast_ema, color=color.blue, title="Fast EMA")
plot(slow_ema, color=color.red, title="Slow EMA")

smoothed_Close = ta.hma(haClose, smooth_len)
smoothed_Open = ta.hma(haOpen, smooth_len)

momentum_wave = ta.rsi(smoothed_Close, mom_len)
atr = ta.atr(atr_len)
volatility_condition = atr > ta.sma(atr, atr_len) 

is_bullish = smoothed_Close > smoothed_Open
is_bearish = smoothed_Close < smoothed_Open

color ha_color = is_bullish ? color.new(#00BCD4, 20) : color.new(#FF5252, 20)
plotcandle(smoothed_Open, haHigh, haLow, smoothed_Close, title="Dynamic HA", color=ha_color, wickcolor=ha_color, bordercolor=ha_color)

// --- 4. 시그널 로직 ---
var int position = 0 

buy_cond = is_bullish and momentum_wave > 50 and volatility_condition
sell_cond = is_bearish and momentum_wave < 50 and volatility_condition
exit_long_cond = is_bearish
exit_short_cond = is_bullish

bool buy_signal = false
bool sell_signal = false
bool exit_signal = false

if position <= 0 and buy_cond
    buy_signal := true
    position := 1
else if position >= 0 and sell_cond
    sell_signal := true
    position := -1
else if position == 1 and exit_long_cond
    exit_signal := true
    position := 0
else if position == -1 and exit_short_cond
    exit_signal := true
    position := 0

plotshape(buy_signal, title="Buy Signal", style=shape.labelup, location=location.belowbar, color=color.new(#00BCD4, 0), text="BUY", textcolor=color.white, size=size.small)
plotshape(sell_signal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.new(#FF5252, 0), text="SELL", textcolor=color.white, size=size.small)
plotshape(exit_signal and position[1] == 1, title="Exit Long", style=shape.labeldown, location=location.abovebar, color=color.new(#FFC107, 0), text="EXIT", textcolor=color.black, size=size.small)
plotshape(exit_signal and position[1] == -1, title="Exit Short", style=shape.labelup, location=location.belowbar, color=color.new(#FFC107, 0), text="EXIT", textcolor=color.black, size=size.small)
````

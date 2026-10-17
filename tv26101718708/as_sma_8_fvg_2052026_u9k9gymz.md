# AS SMA 8 + FVG 2.05.2026

- url: https://www.tradingview.com/script/U9k9GymZ/
- type: indicator
- pine_id: PUB;9d950a0b6f5e4cd584f99d766cb1d803
- version: 1.0

## Description

This Pine Script (version 6) defines a TradingView indicator titled “AS SMA 8 + FVG 2.05.2026”, designed to combine moving average trend analysis with Fair Value Gap (FVG) detection and simple price action signals.

1. Inputs

The script allows the user to configure three exponential moving averages (EMAs) and FVG visualization:

Fast MA (len_sma8) – default length 8 (used as the main short-term trend line)
Mid MA (len_ma20) – default length 20
Long MA (len_ma200) – default length 200
FVG Extend – defines how far FVG boxes extend into the future (default: 5 bars)
2. Moving Averages (Trend Structure)

The indicator calculates three EMAs:

Fast EMA (8) – used for short-term trend direction and signals
EMA 20 – medium trend filter
EMA 200 – long-term trend context

All three EMAs are plotted on the chart with different colors and transparency levels to visually distinguish trend layers.

3. Fair Value Gap (FVG) Detection

The script identifies a classic 3-candle FVG structure:

Bullish FVG (bull_fvg):
Occurs when the current low is higher than the high from two candles ago (low > high[2])
Bearish FVG (bear_fvg):
Occurs when the current high is lower than the low from two candles ago (high < low[2])
4. FVG Visualization

When an FVG is detected:

A box is drawn on the chart
Bullish FVGs are highlighted in semi-transparent green
Bearish FVGs are highlighted in semi-transparent red
Each box starts 2 bars back and extends forward by the user-defined fvg_extend value

This visually marks liquidity gaps in price action.

5. Candle Coloring (Trend Context)

Candles are colored based on the direction of the fast EMA:

Green candles → fast EMA is rising
Red candles → fast EMA is falling
Gray candles → neutral state

This provides a quick visual representation of short-term momentum.

6. Trading Signals

The script generates simple crossover-based signals:

BUY signal: when price closes above the fast EMA (crossover)
SELL signal: when price closes below the fast EMA (crossunder)

Signals are only triggered on confirmed bar close.

7. Alert System (Unified Logic)

A single alert system handles all conditions:

BUY alerts → price crosses above fast EMA
SELL alerts → price crosses below fast EMA
Bullish FVG detection
Bearish FVG detection

Only one message is triggered per bar close, prioritizing signal conditions.

## Source Code

````pine
//@version=6
indicator("AS SMA 8 + FVG 2.05.2026", overlay=true)

//────────────────────
// INPUTS
//────────────────────
len_sma8   = input.int(8, minval=1, title="Fast MA (SMA 8 label)")
len_ma20   = input.int(20, minval=1, title="Mid MA (EMA 20)")
len_ma200  = input.int(200, minval=1, title="EMA 200")
fvg_extend = input.int(5, minval=1, title="FVG Extend")

//────────────────────
// MAs (LOGIC CLEAN)
//────────────────────
ma_fast  = ta.ema(close, len_sma8)
ma_mid   = ta.ema(close, len_ma20)
ma_long  = ta.ema(close, len_ma200)

plot(ma_fast, title="FAST EMA 8", style = plot.style_stepline, color=color.new(#787b86, 52))
plot(ma_mid,  title="EMA 20", color=color.new(#2195f3, 54))
plot(ma_long, title="EMA 200", color=color.new(color.blue, 70))

//────────────────────
// FVG LOGIC (3-candle)
//────────────────────
bull_fvg = low > high[2]
bear_fvg = high < low[2]

//────────────────────
// FVG BOXES (SAFE)
//────────────────────
if bull_fvg and not na(high[2])
    box.new(
        left=bar_index - 2,
        right=bar_index + fvg_extend,
        top=low,
        bottom=high[2],
        bgcolor=color.new(color.green, 75),
        border_color=na
    )

if bear_fvg and not na(low[2])
    box.new(
        left=bar_index - 2,
        right=bar_index + fvg_extend,
        top=low[2],
        bottom=high,
        bgcolor=color.new(color.red, 80),
        border_color=na
    )

//────────────────────
// CANDLE COLOR (TREND FAST MA)
//────────────────────
fast_up = ma_fast > ma_fast[1]
fast_dn = ma_fast < ma_fast[1]

barcolor(
     fast_up ? color.new(color.green, 35) :
     fast_dn ? color.new(color.red, 45) :
     color.new(color.gray, 80)
)

//────────────────────
// SIGNALS (CLEAN CROSS LOGIC)
//────────────────────
buy_signal  = barstate.isconfirmed and ta.crossover(close, ma_fast)
sell_signal = barstate.isconfirmed and ta.crossunder(close, ma_fast)

//────────────────────
// ALERTS (ONE STREAM)
//────────────────────
alert_msg =
     buy_signal  ? "BUY: Close crossed above FAST MA" :
     sell_signal ? "SELL: Close crossed below FAST MA" :
     bull_fvg    ? "BULL FVG detected" :
     bear_fvg    ? "BEAR FVG detected" :
     ""

any_alert = buy_signal or sell_signal or bull_fvg or bear_fvg

if any_alert
    alert(alert_msg, alert.freq_once_per_bar_close)
````

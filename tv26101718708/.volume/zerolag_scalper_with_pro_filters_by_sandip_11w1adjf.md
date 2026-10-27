# Zero-Lag Scalper with Pro Filters by sandip

- url: https://www.tradingview.com/script/11w1adjf-Zero-Lag-Scalper-with-Pro-Filters-by-sandip/
- type: indicator
- pine_id: PUB;42771161529d4f618f2ba9b5573b6b75
- version: 1.0

## Description

The script uses a Zero-Lag EMA (ZLEMA) as its primary engine. Traditional moving averages often react too slowly to price action; the ZLEMA "corrects" this by subtracting a lagged data point from the current price before applying a standard EMA calculation. This allows the indicator line to "hug" the price more closely, providing earlier trend shift alerts.

## Source Code

````pine
//@version=5
indicator("Zero-Lag Scalper with Pro Filters", overlay=true)

// --- Inputs ---
z_length = input.int(100, "Z-Lag Length (Pro: 100+)", minval=1)
atr_mult = input.float(2.0, "Band Multiplier (ATR Factor)", step=0.1)
adx_min  = input.int(25, "Minimum ADX for Signal")
use_vwap = input.bool(true, "Use VWAP Filter?")

// --- Zero-Lag EMA Calculation ---
// Formula: EMA(Price + (Price - Price[Lag]), Length)
lag = math.floor((z_length - 1) / 2)
z_data = close + (close - close[lag])
zlema = ta.ema(z_data, z_length)

// --- Filters: ADX and VWAP ---
[plus_di, minus_di, adx_val] = ta.dmi(14, 14)
vwap_val = ta.vwap(hlc3)

// --- Signal Conditions ---
// Power Buy: ZLEMA turns up + Price > VWAP + ADX > 25
buy_signal = ta.crossover(close, zlema) and adx_val > adx_min and (not use_vwap or close > vwap_val)
// Power Sell: ZLEMA turns down + Price < VWAP + ADX > 25
sell_signal = ta.crossunder(close, zlema) and adx_val > adx_min and (not use_vwap or close < vwap_val)

// --- Visuals ---
plot(zlema, color=close > zlema ? color.green : color.red, linewidth=2, title="Zero-Lag Basis")
plot(use_vwap ? vwap_val : na, color=color.gray, style=plot.style_linebr, title="VWAP Filter")

plotshape(buy_signal, title="POWER BUY", text="POWER BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(sell_signal, title="POWER SELL", text="POWER SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

// Alert conditions
alertcondition(buy_signal, title="Buy Alert", message="Power Buy Signal Confirmed")
alertcondition(sell_signal, title="Sell Alert", message="Power Sell Signal Confirmed")
````

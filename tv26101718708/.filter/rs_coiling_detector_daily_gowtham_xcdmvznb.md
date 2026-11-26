# RS Coiling Detector Daily [Gowtham]

- url: https://www.tradingview.com/script/xCDmVZnb-RS-Coiling-Detector-Daily-Gowtham/
- type: indicator
- pine_id: PUB;709276164ff742eb93acadbe614d60e1
- version: 1.0

## Description

Rsi 70 plus stocks coiling ,rsi first needs to form 70 plus on daily, wait for a low volume pullback. If it tightens as it pullback ull see a green patch showing low risk entry

## Source Code

````pine
//@version=5
indicator("RS Coiling Detector Daily [Gowtham]", shorttitle="RS Coil Daily", overlay=false)

index        = input.symbol("NSE:NIFTY", "Benchmark Index")
rs_length    = input.int(52, "RS MA Length")
vol_length   = input.int(10, "Volatility Lookback")
rsi_length   = input.int(14, "RSI Length")
rsi_min      = input.float(70, "Minimum RSI Threshold")
rsi_lookback = input.int(100, "RSI Lookback in Daily Bars (100 = 20 weeks)")
coil_thresh  = input.float(0.7, "Coiling Threshold (0.6 strict, 0.7 loose)")
value_low    = input.float(-5, "Value Zone Lower Bound")
value_high   = input.float(3, "Value Zone Upper Bound")
base_bars    = input.int(15, "Base Lookback Bars")
base_range   = input.float(10, "Max Base Range % (tighter = stricter)")
ema_length   = input.int(50, "EMA Length for Base Filter")

index_close = request.security(index, timeframe.period, close)
drs         = close / index_close
drs_ma      = ta.sma(drs, rs_length)
mrs         = 100 * ((drs / drs_ma) - 1)

rs_vol_now  = ta.stdev(mrs, vol_length)
rs_vol_prev = ta.highest(ta.stdev(mrs, vol_length), 30)

rsi_daily = request.security(syminfo.tickerid, "D", ta.rsi(close, rsi_length))
rsi_fired = ta.highest(rsi_daily, rsi_lookback) >= rsi_min

price_range      = (ta.highest(high, base_bars) - ta.lowest(low, base_bars)) / ta.lowest(low, base_bars) * 100
is_consolidating = price_range < base_range

ema50      = ta.ema(close, ema_length)
above_ema  = close > ema50

is_coiling  = (rs_vol_now < rs_vol_prev * coil_thresh) and rsi_fired and (mrs >= mrs[10]) and is_consolidating and above_ema
is_value    = is_coiling and (mrs >= value_low and mrs <= value_high)
is_momentum = is_coiling and mrs > value_high

hline(0, "Zero Line", color=color.blue, linewidth=2)
plot(mrs, "Mansfield RS", color=is_value ? color.green : is_momentum ? color.orange : color.black, linewidth=2)
bgcolor(is_value ? color.new(color.green, 92) : is_momentum ? color.new(color.orange, 92) : na)
alertcondition(is_value, "RS Value Zone Coiling Daily", "Daily RS coiling in value zone — high reward setup")
alertcondition(is_momentum, "RS Momentum Coiling Daily", "Daily RS coiling above zero — momentum setup")
````

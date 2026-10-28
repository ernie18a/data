# AMV Bands (Adaptive Multi-Volatility) v0.2

- url: https://www.tradingview.com/script/L6FNG5Ie/
- type: indicator
- pine_id: PUB;3ee04b2bed3b444db826d41c1e2db794
- version: 1.0

## Description

Beyaz Bant Sistemi sadece trendi değil, piyasanın nabzını da okur.
Fiyat beyaz bandın üzerinde kaldığı sürece güç alımı devam ederken, banda yapılan temaslar çoğu zaman yeni yön hareketinin başlangıcını verir.

Bu yapı sayesinde:
• Sahte sinyaller filtrelenir
• Trend yönü daha net okunur
• Pump/Dump bölgeleri ekstra doğrulama kazanır
• Momentum değişimleri erken yakalanır

Beyaz bant kırılmadıkça trend ölmez.
Sistem sadece hareketi değil, hareketin arkasındaki gücü gösterir.


The White Band System doesn’t only track the trend — it reads the market’s pulse.
As long as price holds above the white band, bullish strength remains active, while every touch to the band often becomes the start of a new directional move.

With this structure:
• Fake signals are filtered
• Trend direction becomes clearer
• Pump/Dump zones gain extra confirmation
• Momentum shifts are detected earlier

As long as the white band holds, the trend survives.
The system doesn’t just show movement — it shows the power behind it.

## Source Code

````pine
// @version=5
indicator("Teo AMV Bands (Adaptive Multi-Volatility) v0.2", overlay=true, max_lines_count=200)

// === INPUTS ===
src = input.source(close, "Source")
len_mid = input.int(34, "Mid MA Length")
mid_type = input.string("HMA", "Mid Type", options=["HMA","EMA","SMA"])
len_std = input.int(20, "StdDev Length")
len_atr = input.int(14, "ATR Length")
vwma_len = input.int(50, "VWMA Length")
w_std = input.float(0.5, "Weight StdDev", step=0.1)
w_atr = input.float(0.3, "Weight ATR", step=0.1)
w_vw = input.float(0.2, "Weight VWMA Deviation", step=0.1)
squeezeLen = input.int(50, "Squeeze Lookback")
squeezePercentile = input.float(10, "Squeeze Percentile (lower %)", step=1)
vol_multiplier = input.float(1.25, "Volume Multiplier for Confirmation", step=0.05)
htf = input.timeframe("60", "Higher TF for Confirmation")
use_momentum = input.bool(true, "Use Momentum (RSI) Confirmation")
rsi_len = input.int(14, "RSI Length")
plot_bands = input.bool(true, "Plot Bands")

// === HELPERS ===
f_ma(_src, _len, _type) =>
    _type == "HMA" ? ta.hma(_src, _len) :
     _type == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

// Center line
mid = f_ma(src, len_mid, mid_type)

// Volatility components
sd = ta.stdev(src, len_std)
atr = ta.atr(len_atr)
vwma_val = ta.vwma(src, vwma_len)
vw_dev = math.abs(vwma_val - ta.sma(src, vwma_len))

bandwidth = w_std * sd + w_atr * atr + w_vw * vw_dev
upper = mid + bandwidth
lower = mid - bandwidth

// Squeeze detection
bw = bandwidth
bw_hist_min = ta.lowest(bw, squeezeLen)
squeeze = bw <= bw_hist_min * (1 + squeezePercentile/100)

// Volume confirmation
vol_ma = ta.sma(volume, vwma_len)
vol_ok = volume > vol_ma * vol_multiplier

// Momentum confirmation
rsi = ta.rsi(src, rsi_len)
mom_ok_buy = rsi > 50
mom_ok_sell = rsi < 50

// Higher timeframe trend confirmation
htf_mid = request.security(syminfo.tickerid, htf, mid)
htf_close = request.security(syminfo.tickerid, htf, close)
htf_trend_up = htf_close > htf_mid
htf_trend_down = htf_close < htf_mid

// Signal rules
breakout_buy = close > upper and vol_ok and (not squeeze or (squeeze and vol_ok)) and (not use_momentum or mom_ok_buy) and htf_trend_up
breakout_sell = close < lower and vol_ok and (not squeeze or (squeeze and vol_ok)) and (not use_momentum or mom_ok_sell) and htf_trend_down

// === PLOTS ===
p1 = plot(upper, title="Upper", linewidth=2, display = plot_bands ? display.all : display.none)
p2 = plot(mid,   title="Mid",   linewidth=1, display = plot_bands ? display.all : display.none)
p3 = plot(lower, title="Lower", linewidth=2, display = plot_bands ? display.all : display.none)

fill(p1, p3, color = close >= mid ? color.new(color.green,85) : color.new(color.red,85), 
     display = plot_bands ? display.all : display.none)

// Signals on chart
plotshape(breakout_buy, title="Buy Signal", style=shape.labelup, location=location.belowbar, text="TEO BUY", textcolor=color.white, size=size.small, color=color.green)
plotshape(breakout_sell, title="Sell Signal", style=shape.labeldown, location=location.abovebar, text="TEO SELL", textcolor=color.white, size=size.small, color=color.red)

// Alerts
alertcondition(breakout_buy, "TEO BUY", "Teo AMV Bands BUY signal")
alertcondition(breakout_sell, "TEO SELL", "Teo AMV Bands SELL signal")

// Quick info label
var label info = na
if barstate.islast
    label.delete(info)
    info_text = "BW: " + str.tostring(bandwidth, "#.######") + "\nSqueeze: " + (squeeze ? "YES" : "no") + "\nVol OK: " + (vol_ok ? "YES" : "no")
    info := label.new(bar_index, na, info_text, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.gray,90), textcolor=color.white, size=size.small)
````

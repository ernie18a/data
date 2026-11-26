# Bitcoin vs Inverted DXY Regime | Astral Vision 

- url: https://www.tradingview.com/script/6j1LAL1U/
- type: indicator
- pine_id: PUB;5e7ad5fd8930422fb201bae337f9b986
- version: 1.0

## Description

[b]Bitcoin vs Inverted DXY Regime | Astral Vision 🌠💠[/b]

Inspired by: @JackGreenCrypto

This indicator plots the Z-Score of Bitcoin's log price and the inverted Z-Score of the DXY Dollar Index on the same scale, shifted forward in time by a configurable lag, to visualize the historical inverse relationship between dollar strength and Bitcoin price and to identify divergences between the two series before they resolve in price.

[b]Calculation ⚙️[/b]

Both Bitcoin and DXY are first transformed by taking their natural logarithm. Working in log space is essential for two reasons: Bitcoin has moved across several orders of magnitude, so raw price differences between 2015 and 2024 are not comparable; and the inverse relationship between DXY and Bitcoin is proportional rather than linear, meaning a 10% move in DXY has a proportionally similar impact regardless of absolute price level.

The Z-Score is then computed independently for each series using the same formula: subtract the simple moving average of the log series over the lookback window from the current log value, then divide by the standard deviation of the same window. The result for each series is: Z = (log(price) - SMA(log(price), N)) / StDev(log(price), N), where N is the configurable Z-Score lookback. This expresses each series in units of standard deviations above or below its own rolling mean, making the two series directly comparable on the same scale regardless of their absolute price differences.

The DXY Z-Score is then multiplied by -1 to invert it. Since DXY and Bitcoin historically move in opposite directions, the uninverted DXY Z-Score would mirror Bitcoin rather than track it. After inversion, the two series should theoretically overlap or move together during periods of normal inverse correlation. Divergences, where Bitcoin's Z-Score moves in one direction while the inverted DXY Z-Score moves in the other, signal a breakdown in the typical relationship that has historically tended to resolve by one series catching up to the other.

The inverted DXY line is plotted with a configurable forward offset in bars. This operationalizes the observed lag between dollar index movements and their full transmission into Bitcoin price, allowing the DXY signal to be read as a leading indicator rather than a coincident one.

[b]Plots 📊[/b]
[list]
[*]Bitcoin log Z-Score over the configurable lookback window
[*]Inverted DXY log Z-Score shifted forward by the configurable lag
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Z-Score Lookback: rolling window for mean and standard deviation applied to both series
[*]DXY Lag: bars to shift the inverted DXY signal forward in time
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
Standard correlation tools between Bitcoin and DXY operate on raw prices or percentage returns, which are distorted by the enormous scale difference between the two assets and by Bitcoin's exponential growth trend. Computing both in log space and normalizing via Z-Score removes these distortions entirely, placing both series on equal statistical footing. The forward shift on the DXY line turns a coincident correlation chart into a directional leading signal: when the inverted DXY is rising ahead of Bitcoin's Z-Score, it suggests dollar weakness is building that has not yet fully priced into Bitcoin, and vice versa.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin vs Inverted DXY Regime | Astral Vision 🌠💠", overlay = false)

theme      = input.string("Paradiso", "Theme", options = ["Inferno","Paradiso","Futura","Infinito","Hermes"])
usecustom  = input.bool(false, "Custom Colors")
custom_pos = input.color(color.rgb(0, 210, 255), "Custom Pos", inline = "cc")
custom_neg = input.color(color.rgb(0,  80, 160), "Custom Neg", inline = "cc")
z_len      = input.int(365, "Z-Score Lookback", minval = 50)
dxy_lag    = input.int(90,  "DXY Lag (bars)",   minval = 0, maxval = 500)

pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255, 0,   0)   :
     theme == "Paradiso" ? color.rgb(0,   210, 255) :
     theme == "Futura"   ? color.rgb(0,   255, 180) :
     theme == "Infinito" ? color.rgb(180, 120, 255) :
     color.rgb(255, 160, 0)

neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120, 0,   0)   :
     theme == "Paradiso" ? color.rgb(0,   80,  160) :
     theme == "Futura"   ? color.rgb(180, 0,   255) :
     theme == "Infinito" ? color.rgb(255, 220, 80)  :
     color.rgb(0, 180, 120)

float btc = request.security("INDEX:BTCUSD", "D", close)
float dxy = request.security("TVC:DXY",      "D", close)

float log_btc = na(btc) or btc <= 0 ? float(na) : math.log(btc)
float log_dxy = na(dxy) or dxy <= 0 ? float(na) : math.log(dxy)

float btc_mean  = ta.sma(log_btc, z_len)
float btc_stdev = ta.stdev(log_btc, z_len)
float btc_z     = na(btc_stdev) or btc_stdev == 0 ? float(na) : (log_btc - btc_mean) / btc_stdev

float dxy_mean  = ta.sma(log_dxy, z_len)
float dxy_stdev = ta.stdev(log_dxy, z_len)
float dxy_z_raw = na(dxy_stdev) or dxy_stdev == 0 ? float(na) : (log_dxy - dxy_mean) / dxy_stdev
float dxy_z_inv = na(dxy_z_raw) ? float(na) : dxy_z_raw * -1


plot(btc_z,     "BTC/USD Log Dev",        neg_col, 2)
plot(dxy_z_inv, "Inverted DXY (90d lag)", pos_col,               2, offset = dxy_lag)
````

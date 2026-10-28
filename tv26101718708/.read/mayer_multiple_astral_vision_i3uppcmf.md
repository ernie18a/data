# Mayer Multiple | Astral Vision 

- url: https://www.tradingview.com/script/I3UPpCMf/
- type: indicator
- pine_id: PUB;4966d62ca2b34e7d9e54748d7d127018
- version: 1.0

## Description

[b]Mayer Multiple | Astral Vision 🌠💠
[/b]
The Mayer Multiple divides Bitcoin's price by its moving average, expressing how extended or compressed price is relative to its long-term trend. 
Readings above 2.4 have historically marked distribution zones; readings below 0.6 have marked generational accumulation opportunities.

Unlike most implementations that treat the Mayer Multiple as a static valuation tool, this version adds a configurable moving average of the multiple itself, enabling trend analysis directly on the oscillator. 
Valuation mode colors by threshold breach. 
Trend mode colors continuously by whether the multiple is above or below its own MA. 
Both the SMA length and the multiple MA length are fully adjustable, and overbought/oversold thresholds are user-defined rather than fixed.

Price-space bands are projected directly onto the chart showing the exact levels where each threshold would be reached.

[b]Calculation ⚙️
[/b]
`Mayer Multiple = BTC Price / SMA(Price, length)`
`Multiple MA = SMA(Multiple, length)`
`Price OB = OB threshold × SMA`
`Price OS = OS threshold × SMA`

[b]Disclaimer 🎯
[/b]
This indicator is a personal research tool for educational and informational purposes only. It does not constitute financial advice or investment recommendation of any kind. I am not affiliated with any financial institution, research firm, or organization. Always conduct your own research before making any financial decision.

[b]Inputs 🎛️
[/b]- `Color Mode` Valuation (threshold-based) or Trend (above/below multiple MA)
- `Price SMA Length` moving average length for the multiple calculation (default 200)
- `Multiple SMA Length` moving average applied to the multiple itself (default 200)
- `Overbought / Oversold Threshold` user-defined valuation extremes (default 2.4 / 0.6)

[b]Colors 🎨
[/b]5 Astral Vision presets + custom override. Default: Paradiso.

[b]Plots 📊
[/b]- Mayer Multiple oscillator colored by active mode
- Multiple moving average signal baseline
- Overbought / oversold threshold lines with fill between
- Price-space OB / OS bands projected onto the chart
- Background highlight when price breaches either band
- Candle coloring by active regime

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision 

//@version=6
indicator("Mayer Multiple | Astral Vision 🌠💠", overlay=false)

theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group="Colors")
usecustom  = input.bool(false, "Custom Colors", group="Colors")
custom_pos = input.color(color.rgb(0,255,180), "Custom Positive", group="Colors")
custom_neg = input.color(color.rgb(180,0,255), "Custom Negative", group="Colors")
colormode  = input.string("Valuation", "Color Mode", options=["Trend","Valuation"], group="Colors")

int     psma_length = input.int(200,  "Price SMA Length",      group="Settings")
int     msma_length = input.int(200,  "Multiple SMA Length",   group="Settings")
float   ob_level    = input.float(2.4, "Overbought Threshold", step=0.05, group="Thresholds")
float   os_level    = input.float(0.6, "Oversold Level",       step=0.05, group="Thresholds")

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255):
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

color neu_col = color.black

float btc_close                            = request.security("INDEX:BTCUSD", "D", close)
[btc_open, btc_high, btc_low, btc_close2] = request.security("INDEX:BTCUSD", "D", [open, high, low, close])

float sma_price = ta.sma(btc_close, psma_length)
float multiple  = btc_close / sma_price
float mma       = ta.sma(multiple, msma_length)
float price_ob  = ob_level * sma_price
float price_os  = os_level * sma_price

color val_col   = multiple > ob_level ? pos_col : multiple < os_level ? neg_col : neu_col
color trend_col = multiple > mma ? pos_col : multiple < mma ? neg_col : color.rgb(0,0,0)
color osc_col   = colormode == "Trend" ? trend_col : val_col

plot_ob = plot(ob_level, "Overbought", color=color.new(pos_col, 0), linewidth=2)
plot_os = plot(os_level, "Oversold",   color=color.new(neg_col, 0), linewidth=2)
fill(plot_ob, plot_os, color=color.new(neu_col, 92))

plot(multiple, "Mayer Multiple",    color=osc_col,                    linewidth=2)
plot(mma,      "Mayer Multiple MA", color=color.new(color.white, 50), linewidth=1)
plot(price_ob, "Overbought Band", color=color.new(pos_col, 50), linewidth=2, force_overlay=true)
plot(price_os, "Oversold Band",   color=color.new(neg_col, 50), linewidth=2, force_overlay=true)

bgcolor(btc_close > price_ob ? color.new(pos_col, 50) : btc_close < price_os ? color.new(neg_col, 50) : na, force_overlay=true)

color candle_col = colormode == "Valuation" ?
     (multiple > ob_level ? pos_col : multiple < os_level ? neg_col : color.black) :
     (multiple > mma ? pos_col : multiple < mma ? neg_col : color.black)

plotcandle(btc_open, btc_high, btc_low, btc_close2, "Price", candle_col, candle_col, bordercolor=candle_col, force_overlay=true)
````

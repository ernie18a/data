# Bitcoin 2Y-SMA Bands| Astral Vision 

- url: https://www.tradingview.com/script/zkCzrgE0/
- type: indicator
- pine_id: PUB;2c08bd9618c04264bb5fe6b96566354e
- version: 1.0

## Description

[b]Bitcoin 2Y-SMA Bands | Astral Vision 🌠💠
[/b]

The 2-year simple moving average spans a full halving epoch, filtering short and medium-term noise to expose Bitcoin's underlying long-term trend. This indicator builds a two-band valuation framework anchored to this baseline.

The bottom band scales the 2Y-SMA by a configurable multiplier (default 0.6), the level at which every major bear market has historically found its floor. 
The top band scales from the bottom by a second multiplier (default 6.5), marking the ceiling of speculative excess beyond which price has rarely sustained.

The oscillator panel plots the log ratio of price to the bottom band, keeping both reference levels flat and proportionally scaled across all cycles regardless of Bitcoin's absolute price.

Calculation ⚙️

`Investor Bottom = SMA(close, 730) × bottom_multiplier`
`Investor Top = Investor Bottom × top_multiplier`
`Ratio = close / Investor Bottom`
`Oscillator = log(Ratio)` plotted against `log(1.0)` and `log(top_multiplier)`

[b]Purpose 🎯
[/b]
This indicator is a personal research tool designed to contextualize Bitcoin's price within a long-term valuation framework based on the 2-year simple moving average.

[b]Disclaimer ⭕️
[/b]It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.


[b]Inputs 🎛️
[/b]- `Bottom Multiplier` scales the 2Y-SMA to define the accumulation floor (default 0.6)
- `Top Multiplier` scales the bottom band to define the distribution ceiling (default 6.5)
- `Plot Candle` toggles candle coloring on the price chart
- `Use Gradient Color` colors candles continuously by position within the valuation range rather than by binary threshold crossing

[b]Colors 🎨
[/b]5 Astral Vision presets + custom override. Default: Hermes.

[b]Plots 📊
[/b]- Investor bottom and top bands projected directly on the price chart
- Log ratio oscillator in the lower panel with fills at both extremes
- Background highlight when price breaches either band
- Candle coloring by active regime or continuous gradient

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision  

//@version=6
indicator("Bitcoin 2Y-SMA Bands| Astral Vision 🌠💠",
     overlay=false, max_bars_back=5000, format=format.price, precision=2)

string group1 = "Settings"
string group2 = "Astral Colors"
string group3 = "Plots"

float mult_bottom = input.float(0.6, "Bottom Multiplier (2y-SMA ×)", step=0.05, group=group1)
float mult_top    = input.float(6.5, "Top Multiplier (Bottom ×)",    step=0.1,  group=group1)

bool  show_candle = input.bool(true,  "Plot Candle",        group=group3)
bool  usegrad     = input.bool(false, "Use Gradient Color", group=group3)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.white, "Custom Positive", group=group2)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)   :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

float sma_2y     = ta.sma(close, 730)
float inv_bottom = sma_2y * mult_bottom
float inv_top    = inv_bottom * mult_top
float ratio      = inv_bottom != 0 ? close / inv_bottom : na

color grad_col  = color.from_gradient(ratio, 1.0, mult_top, pos_col, neg_col)
color flat_col  = ratio > mult_top ? neg_col : ratio < 1.0 ? pos_col : color.rgb(120,120,120)
color final_col = usegrad ? grad_col : flat_col

plot(inv_bottom, "Investor Bottom (2y-SMA × mult)", color=pos_col, linewidth=2, force_overlay=true)
plot(inv_top,    "Investor Top (Bottom × mult)",    color=neg_col, linewidth=2, force_overlay=true)

bgcolor(ratio < 1.0      ? color.new(pos_col, 50) : na, force_overlay=true)
bgcolor(ratio > mult_top ? color.new(neg_col, 50) : na, force_overlay=true)

plotcandle(open, high, low, close, "Candle", final_col, final_col,
          bordercolor   = final_col,
          force_overlay = true,
          display       = show_candle ? display.all : display.none)

h_top   = plot(math.log(mult_top), "Top Level",    color=neg_col, linewidth=1)
h_one   = plot(math.log(1.0),      "Bottom Level", color=pos_col, linewidth=1)
p_ratio = plot(math.log(ratio),    "Price / Investor Bottom", color=final_col, linewidth=2)

fill(p_ratio, h_one, ratio < 1.0      ? color.new(pos_col, 70) : na)
fill(p_ratio, h_top, ratio > mult_top ? color.new(neg_col, 70) : na)
````

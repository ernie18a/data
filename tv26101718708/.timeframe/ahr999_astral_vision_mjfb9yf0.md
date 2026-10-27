# AHR999 | Astral Vision 

- url: https://www.tradingview.com/script/mjfB9YF0/
- type: indicator
- pine_id: PUB;be2a1d193edf43e1830342895b02c049
- version: 1.0

## Description

[b]AHR999 | Astral Vision 🌠💠[/b]

This indicator computes the AHR999 index, a composite valuation metric that combines two independent measures of Bitcoin's price position: its distance from a geometric moving average of recent price, and its distance from a long-term power law growth model based on Bitcoin's age in days. When both measures agree that price is depressed, the index produces low readings historically associated with strong accumulation opportunities.

[b]Calculation ⚙️[/b]

The first component is the ratio between current Bitcoin price and its geometric mean over a configurable lookback window. Unlike an arithmetic mean, the geometric mean multiplies all values together and takes the N-th root, making it more representative of compounded growth and less sensitive to extreme price spikes. To keep the numbers computationally manageable, the daily close is scaled by dividing by 10,000 before computing the geometric mean, then rescaled afterward. The ratio of current price to this geometric mean measures whether price is above or below its recent compounded average.

The second component is the ratio between current price and a power law estimate of Bitcoin's fair value derived from its age. The power law estimate is: estimated price = 10 ^ (5.84 × log10(bitcoin age in days) + (-17.01)), where bitcoin age counts from the genesis block. This formula captures the empirically observed relationship between Bitcoin's price and the time elapsed since its creation, producing a continuously rising fair value line that reflects Bitcoin's historical growth trajectory. The ratio of current price to this estimate measures how far price sits above or below its age-implied fair value.

The AHR999 index is then the product of these two ratios: geometric mean ratio multiplied by power law ratio. Historically, readings below approximately 0.45 have corresponded to strong accumulation zones, while readings above 1.2 have corresponded to elevated valuation. A configurable oversold level controls when the index triggers the accumulation signal, and the corresponding price level at which the index would reach that threshold is plotted directly on the price chart as a dynamic support reference.

The price overlay band is derived by inverting the AHR999 formula: given a target index value of `os_level`, the implied price is the square root of (`os_level` × geometric mean price × estimated power law price).

[b]Plots 📊[/b]
[list]
[*]AHR999 index line colored by position relative to the oversold threshold
[*]Oversold threshold line in the sub-panel
[*]Dynamic price level on the chart corresponding to the oversold threshold
[*]Background color highlight in the sub-panel and on the price chart when index is below threshold
[*]Candle coloring with continuous gradient reflecting the index value
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Length: lookback window for the geometric mean calculation
[*]Oversold Level: index threshold below which accumulation conditions are signaled
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
Standard moving average crossovers or RSI-based oversold signals measure Bitcoin's price relative only to its own recent history, without any reference to the long-term growth trajectory implied by its age and adoption curve. The AHR999 index introduces a second reference frame — the power law model — making it possible to distinguish between price being temporarily below its short-term average in a bull market versus being genuinely depressed relative to its structural long-term fair value. The dynamic price band on the chart further operationalizes this by showing in price terms exactly where the accumulation threshold currently sits, rather than requiring the user to mentally translate an oscillator reading back into a price level.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Astral Vision 

//@version=6
indicator("AHR999 | Astral Vision 🌠💠", overlay = false)

inv_ahr999_to_price(float target_ahr999, float gma_price, float estimate_price) =>
    math.sqrt(target_ahr999 * gma_price * estimate_price)

group1 = "Settings"
group2 = "Astral Colors"

int     len         = input.int(300, title = "Length", group = group1)
float   os_level    = input.float(0.35, "Oversold Level", minval=-1, maxval=1.0, step=0.05, group = group1)

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group2)

color raw_pos = theme == "Paradiso" ? color.rgb(0,210,255) :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255)  :
     theme == "Hermes"   ? color.rgb(255,160,0)    :
     color.rgb(255,0,0)
color raw_neg = theme == "Paradiso" ? color.rgb(0,80,160)  :
     theme == "Futura"   ? color.rgb(180,0,255)    :
     theme == "Infinito" ? color.rgb(255,220,80)   :
     theme == "Hermes"   ? color.rgb(0,180,120)    :
     color.rgb(120,0,0)

color col_pos = usecustom ? custom_pos : raw_pos
color col_neg = usecustom ? custom_neg : raw_neg

[btc_open, btc_high, btc_low, btc_close] = request.security("INDEX:BTCUSD", "D", [open, high, low, close])

scale_daily_close = btc_close / 10000

calculateGeometricMean(lookback) =>
    product = 1.0
    for i = 0 to lookback - 1
        product := product * scale_daily_close[i]
    mean = math.pow(product, 1 / lookback) > 0 ? math.pow(product, 1 / lookback) : na
    mean

gma           = calculateGeometricMean(len)
avg_index     = scale_daily_close / gma
bitcoin_age   = request.security("BNC:BLX", "D", bar_index) + 561
estimate_price = math.pow(10, 5.84 * math.log10(bitcoin_age) + (-17.01))
estimate_index = btc_close / estimate_price
ahr999        = avg_index * estimate_index

float gma_price  = gma * 10000
float price_os   = inv_ahr999_to_price(os_level, gma_price, estimate_price)

color col_line   = ahr999 > os_level ? col_neg : col_pos
color candlecol  = color.from_gradient(ahr999, 0.3, 0.6, col_pos, col_neg)
color bg         = ahr999 < os_level ? color.new(col_pos, 70) : na

plot(ahr999,   "AHR999 Index",  color=col_line, linewidth=2)
plot(price_os, "Oversold Band", color=color.new(col_pos, 20), linewidth=2, force_overlay=true)

plotcandle(btc_open, btc_high, btc_low, btc_close, "PlotCandle", candlecol, candlecol, bordercolor=candlecol, force_overlay=true)
bgcolor(bg, force_overlay=true)
bgcolor(bg, force_overlay=false)

hline(os_level, "OS Threshold", color.new(col_pos, 20), linestyle=hline.style_solid)
````

# Bitcoin Realized Price Bands | Astral Vision 

- url: https://www.tradingview.com/script/dFOYEuSY/
- type: indicator
- pine_id: PUB;8ddf68b7ab5f4a589cded95d0713c205
- version: 1.0

## Description

[b]Bitcoin Realized Price Bands | Astral Vision 🌠💠[/b]

The Realized Price is the on-chain cost basis of the entire Bitcoin supply: the average price at which every coin last moved, weighted by supply. 
It represents the aggregate break-even level of all Bitcoin holders. 
When price trades below it, the market as a whole is underwater; when price trades above it, the network is collectively in profit.

This indicator builds a five-level band structure anchored to the Realized Price, scaling each band by a configurable multiplier. 
The bands divide Bitcoin's valuation space into distinct regimes: deep accumulation below cost basis, fair value around it, overvaluation beginning at the mid line, and two successive distribution extremes above. 
A mirrored oscillator panel plots price as a ratio of Realized Price, keeping the same band levels flat and directly comparable across all cycles regardless of Bitcoin's absolute price.

[b]Calculation ⚙️[/b]

`Realized Price = Realized Cap / Circulating Supply`

Each band is a simple scalar multiple of the Realized Price:

`Band = Realized Price × multiplier`

The oscillator plots `close / Realized Price`, expressing price in units of on-chain cost basis. A value of 1.0 means price equals the aggregate holder break-even; values above or below reflect proportional deviation from it.

[b]Plots 📊[/b]
[list]
[*]Five band lines projected on the price chart: Lower Band, Realized Price, Mid Line, Overvalued, Extreme Bubble
[*]Fill between Lower Band and Realized Price (positive color, accumulation zone)
[*]Fill between Overvalued and Extreme Bubble (negative color, distribution zone)
[*]Candle coloring on the price chart by active valuation regime
[*]Triangle signal on the price chart when price crosses above Realized Price from below (long signal)
[*]Triangle signal on the price chart when price crosses back below Overvalued from above (short signal)
[*]Mirrored oscillator panel with the same five flat reference levels
[*]Oscillator line colored by active regime
[*]Fill between oscillator and Overvalued band when price is above it (distribution fill)
[*]Fill between oscillator and Realized Price band when price is below it (accumulation fill)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Lower Band`: multiplier defining the sub-cost-basis accumulation floor (default 0.75)
[*]`Realized Price`: multiplier for the on-chain cost basis line, typically 1.0 (default 1.0)
[*]`Mid Line`: intermediate level between cost basis and overvaluation (default 1.5)
[*]`Overvalued`: multiplier marking the onset of distribution territory (default 2.5)
[*]`Extreme Bubble`: multiplier marking peak speculative excess (default 3.5)
[*]`Neutral Color`: independent color for the mid line, separate from the Astral theme
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override, plus an independent neutral color input for the mid line. Default: Futura. Positive color applies to the lower bands and accumulation fills; negative color applies to the upper bands and distribution fills.

[b]Purpose 🎯[/b]

Most Realized Price indicators plot a single line with no envelope, offering no context for the magnitude of deviation above or below the on-chain cost basis. Traders must manually judge whether a given premium or discount is historically significant.

This indicator structures the entire valuation space around Realized Price as a dynamic anchor. Because the bands scale with it, they automatically adjust upward each cycle as the aggregate cost basis rises, remaining meaningful without any manual recalibration. 
The oscillator panel removes the need to mentally track the exponential price growth of each band, expressing the same information on a flat, cycle-comparable scale. 
The cross signals identify the two most actionable structural events: reclaiming cost basis from below and retreating from the overvalued zone, both of which have historically preceded sustained directional moves.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("Bitcoin Realized Price Bands | Astral Vision 🌠💠", overlay=false)

group1 = "Settings"
group2 = "Astral Colors"

float lowbandinp = input.float(0.75, "Lower Band",     step=0.05, group=group1)
float upper0inp  = input.float(1.0,  "Realized Price", step=0.05, group=group1)
float upper1inp  = input.float(1.5,  "Mid Line",       step=0.05, group=group1)
float upper2inp  = input.float(2.5,  "Overvalued",     step=0.05, group=group1)
float upper3inp  = input.float(3.5,  "Extreme Bubble", step=0.05, group=group1)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,0,0),  "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(120,0,0),  "Custom Negative", group=group2)
color  neu_col    = input.color(color.white, "Neutral Color", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80)  :
     color.rgb(0,180,120)

float btc_real = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)
float btc_supp = request.security("GLASSNODE:BTC_SUPPLY",          "D", close)

float realizedPrice = btc_real / btc_supp

float lowband = realizedPrice * lowbandinp
float upper0  = realizedPrice * upper0inp
float upper1  = realizedPrice * upper1inp
float upper2  = realizedPrice * upper2inp
float upper3  = realizedPrice * upper3inp

float osc = close / realizedPrice

color candle_col = osc >= upper2inp ? neg_col :
                   osc >= upper1inp ? color.black :
                   osc >= 1.0       ? color.black :
                   pos_col

pov1 = plot(lowband,       "Lower Band",     color=pos_col, linewidth=2, force_overlay=true)
pov0 = plot(upper0,        "Realized Price", color=pos_col, linewidth=2, force_overlay=true)
pov3 = plot(upper1,        "Mid Line",       color=neu_col, linewidth=1, force_overlay=true)
pov4 = plot(upper2,        "Overvalued",     color=neg_col, linewidth=2, force_overlay=true)
pov5 = plot(upper3,        "Extreme Bubble", color=neg_col, linewidth=2, force_overlay=true)

fill(pov1, pov0, color=color.new(pos_col, 80))
fill(pov4, pov5, color=color.new(neg_col, 80))

plotcandle(open, high, low, close, "Candles", candle_col, candle_col,
     bordercolor=candle_col, force_overlay=true)

po1 = plot(lowbandinp, "Osc Lower Band",     color=pos_col, linewidth=2)
po0 = plot(upper0inp,  "Osc Realized Price", color=pos_col, linewidth=2)
po3 = plot(upper1inp,  "Osc Mid Line",       color=neu_col, linewidth=1)
po4 = plot(upper2inp,  "Osc Overvalued",     color=neg_col, linewidth=2)
po5 = plot(upper3inp,  "Osc Extreme Bubble", color=neg_col, linewidth=2)

posc = plot(osc, "MVRV Ratio", color=candle_col, linewidth=2)

bool cross_long  = osc[1] < upper0inp   and osc >= upper0inp
bool cross_short = osc[1] > upper2inp   and osc <= upper2inp

plotshape(cross_long, "Long Signal",
     style        = shape.triangleup,
     location     = location.belowbar,
     color        = pos_col,
     size         = size.small,
     force_overlay = true)

plotshape(cross_short, "Short Signal",
     style        = shape.triangledown,
     location     = location.abovebar,
     color        = neg_col,
     size         = size.small,
     force_overlay = true)

fill(po1, po0, color=color.new(pos_col, 80))
fill(po4, po5, color=color.new(neg_col, 80))
fill(posc, po4, osc >= upper2inp ? color.new(neg_col, 75) : na)
fill(posc, po0, osc <= upper0inp ? color.new(pos_col, 75) : na)
````

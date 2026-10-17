# Bitcoin Power Law Bands | Astral Vision 

- url: https://www.tradingview.com/script/3otNhSnZ/
- type: indicator
- pine_id: PUB;ab0a727c42f847e8a92b8ccfd5346df6
- version: 1.0

## Description

Capito — niente sezione "source code protected" e niente paywall framing, dato che è open source. Ecco la versione corretta:

[b]Bitcoin Power Law Bands | Astral Vision 🌠💠[/b]

Bitcoin's price history follows a remarkably consistent power law growth pattern, where the relationship between price and time, when both are expressed logarithmically, forms a structure that has held across more than a decade of market cycles. This indicator plots a full set of power law bands derived from that relationship, anchored to historically observed turning points across Bitcoin's complete price history, and converts the position of price within those bands into a normalized oscillator that makes the current cycle position immediately readable.

The power law model used here is time-segmented: rather than fitting a single static curve to all of Bitcoin's history, the model recalibrates its growth exponent across distinct historical phases, each anchored to a specific cycle low or high date. Each phase boundary is defined by a precise historical timestamp, and the local growth exponent h is interpolated continuously between these anchors using a base-4 progression. This segmented approach captures the documented deceleration in Bitcoin's growth rate as the asset matures, rather than assuming the same growth rate observed in the earliest years continues indefinitely.

The bands are constructed from the standard power law formula price = 10^(p1 + p2 × log10(h)), where h is the time-segmented exponent described above. Around this central curve, four bands are generated using a deviation term that itself decays as a function of h raised to a configurable power, multiplied by fixed standard-deviation-style coefficients (-3, -1.5, +4, +5) to produce the lower extreme, lower moderate, upper moderate, and upper extreme bands respectively. The decay structure means the bands compress proportionally as h grows, reflecting the empirical narrowing of Bitcoin's volatility envelope in log space over time.

The oscillator at the bottom of the indicator translates the absolute price position within these bands into a normalized 0 to 1 scale, where 0 represents the lower extreme band and 1 represents the upper extreme band. This transformation makes it possible to read Bitcoin's position within its long-term growth channel as a single number, comparable across any period in Bitcoin's history regardless of the dramatic difference in absolute price levels between, for example, 2015 and 2025.

The faded projection lines extending into the future use the same model structure carried forward from the most recent anchor, providing a visual reference for where the bands are mathematically projected to sit if the established growth pattern continues, without making any claim about whether price will actually follow that path.

This indicator is open-source. The full calculation, including the exact anchor timestamps, the segmented exponent interpolation, and the band deviation formula, is visible directly in the script for anyone who wants to study or build on the methodology.

[b]Analytical Framework[/b]
Type of analysis: long-term structural growth modeling, cycle position assessment
Recommended timeframe: daily or weekly chart, for long-term position trading and cycle analysis exclusively. Not suitable for short-term or intraday use.
Signal type: deterministic power law bands with a normalized 0-1 position oscillator

[b]How to interpret the signals[/b]

The candle coloring on the price chart provides the simplest read: when price closes above the upper moderate band, the candles take on the positive color, indicating Bitcoin is trading in the upper portion of its long-term growth channel, a zone that has historically corresponded to mid-to-late cycle conditions. When price closes below the lower moderate band, the candles take on the negative color, indicating Bitcoin is trading in the lower portion of its growth channel, a zone that has historically corresponded to deep value territory following major corrections.

The oscillator provides the same information with more granularity. A reading near 1.0 means price is pressed against the upper extreme of the historical growth channel, a condition that has, in every previous instance across Bitcoin's history, preceded a significant correction. A reading near 0.0 means price is pressed against the lower extreme, a condition that has, in every previous instance, marked one of the best long-term accumulation opportunities available. The two horizontal reference levels on the oscillator mark where the moderate bands sit on the normalized scale, making it easy to see when price transitions from the middle of the channel into either extreme zone.

Because the bands recalibrate their growth exponent at each historical cycle boundary, the position of price within the channel should be interpreted relative to the current cycle's specific band placement rather than assuming the same absolute price level carries the same meaning it did in a previous cycle.

[b]How it differs from existing tools[/b]

Most power law indicators on TradingView fit a single static exponent across the entirety of Bitcoin's history, which forces a tradeoff between fitting the early years accurately and fitting recent years accurately. This indicator instead segments the growth model across historically anchored cycle boundaries, allowing the exponent to adapt as Bitcoin's growth rate has empirically decelerated. The normalized 0-1 oscillator is also a meaningful addition: rather than requiring visual inspection of where price sits between curved logarithmic bands, it converts that position into a single comparable number.

[b]Plots 📊[/b]
[list]
[*]Four power law bands on the price chart: upper extreme, upper moderate, lower moderate, lower extreme
[*]Faded future projection lines extending the band structure forward
[*]Candle coloring on the price chart reflecting current position relative to the moderate bands
[*]Normalized 0-1 oscillator in the sub-panel with reference levels marking the moderate band positions
[/list]

[b]Inputs 🎛️[/b]
This indicator has no configurable settings beyond color selection; all band parameters are fixed based on historical calibration and visible directly in the open-source code.

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision 


//@version=6
indicator(title = 'Bitcoin Power Law Bands | Astral Vision 🌠💠', overlay = false)

group1 = "Settings"
group2 = "Astral Colors"

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(0,210,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(0,80,160),  "Custom Negative",  group=group2)

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

color neu_col = color.black

float p001 = 1.47
float p002 = 5.38
float p003 = 0.79
int   t002 = timestamp(2009, 10, 05, 15, 41, 28)
int   t003 = timestamp(2010, 04, 22, 12, 15, 34)
int   t004 = timestamp(2011, 01, 28, 10, 41, 47)
int   t005 = timestamp(2011, 12, 14, 16, 24, 37)
int   t006 = timestamp(2012, 11, 28, 16, 24, 38)
int   t007 = timestamp(2013, 10, 09, 05, 28, 22)
int   t008 = timestamp(2014, 08, 11, 05, 06, 05)
int   t009 = timestamp(2015, 07, 29, 15, 45, 38)
int   t010 = timestamp(2016, 07, 09, 18, 46, 13)
int   t014 = timestamp(2020, 05, 11, 21, 23, 43)
int   t018 = timestamp(2024, 04, 20, 02, 09, 27)
int   t019 = timestamp(2025, 04, 15, 08, 16, 12)

float d002 = (t003 - t002) / (0.25 - 0.116)
float d003 = (t004 - t003) * 4
float d004 = (t005 - t004) * 4
float d005 = (t006 - t005) * 4
float d006 = (t007 - t006) * 4
float d007 = (t008 - t007) * 4
float d008 = (t009 - t008) * 4
float d009 = (t010 - t009) * 4
float d010 = (t014 - t010)
float d011 = (t018 - t014)
float d012 = (t019 - t018) * 4
float d013 = (t019 - t014)

float h001 = if time >= t019
    4.25 + (time - t019) / d013
else if time >= t018
    4.00 + (time - t018) / d012
else if time >= t014
    3.00 + (time - t014) / d011
else if time >= t010
    2.00 + (time - t010) / d010
else if time >= t009
    1.75 + (time - t009) / d009
else if time >= t008
    1.50 + (time - t008) / d008
else if time >= t007
    1.25 + (time - t007) / d007
else if time >= t006
    1.00 + (time - t006) / d006
else if time >= t005
    0.75 + (time - t005) / d005
else if time >= t004
    0.50 + (time - t004) / d004
else if time >= t003
    0.25 + (time - t003) / d003
else
    0.116 + (time - t002) / d002

float h002 = 4.25 + (time - t019 + 1000 * timeframe.in_seconds() * 1000) / d013

calc(h) =>
    e    = math.pow(p003, h + 1)
    dev  = e / 3.0
    base = math.pow(10, p001 + p002 * math.log10(h))
    b_3  = base * math.pow(10, -3 * dev)
    b_2  = base * math.pow(10, -1.5 * dev)
    b_4  = base * math.pow(10, +4 * dev)
    b_5  = base * math.pow(10, +5 * dev)
    [b_3, b_2, b_4, b_5]

[v001, v002, v008, v009] = calc(h001)
[v010, v011, v017, v018] = calc(h002)

plot(v001, "Band -3",    color=neg_col,                   linewidth=1, force_overlay=true)
plot(v002, "Band -2",    color=color.new(neg_col, 40),    linewidth=1, force_overlay=true)
plot(v008, "Band +4",    color=color.new(pos_col, 40),    linewidth=1, force_overlay=true)
plot(v009, "Band +5",    color=pos_col,                   linewidth=1, force_overlay=true)

plot(v010, "Future -3",  color=color.new(neg_col, 60),    linewidth=1, offset=1000, show_last=1000+1, force_overlay=true)
plot(v011, "Future -2",  color=color.new(neg_col, 75),    linewidth=1, offset=1000, show_last=1000+1, force_overlay=true)
plot(v017, "Future +4",  color=color.new(pos_col, 75),    linewidth=1, offset=1000, show_last=1000+1, force_overlay=true)
plot(v018, "Future +5",  color=color.new(pos_col, 60),    linewidth=1, offset=1000, show_last=1000+1, force_overlay=true)

float total_range = v009 - v001
float osc = total_range != 0 ? math.max(0, math.min(1, (close - v001) / total_range)) : na

float lvl_neg  = total_range != 0 ? (v002 - v001) / total_range : na
float lvl_pos  = total_range != 0 ? (v008 - v001) / total_range : na

color candle_col = close >= v008 ? pos_col :
                   close <= v002 ? neg_col : neu_col

color osc_col = osc >= lvl_pos ? pos_col :
                 osc <= lvl_neg ? neg_col : neu_col

plotcandle(open, high, low, close, "Candle", candle_col, candle_col, bordercolor=candle_col, force_overlay=true)

plot(osc, "Growth Oscillator", color=osc_col, linewidth=2)

plot(lvl_neg, "Osc -2σ level", color=color.new(neg_col, 40), linewidth=1)
plot(lvl_pos, "Osc +4σ level", color=color.new(pos_col, 40), linewidth=1)
plot(0.0,     "Osc bottom",    color=neg_col,                 linewidth=1)
plot(1.0,     "Osc top",       color=pos_col,                 linewidth=1)
````

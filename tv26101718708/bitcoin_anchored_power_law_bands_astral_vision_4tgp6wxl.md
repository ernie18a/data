# Bitcoin Anchored Power Law Bands| Astral Vision 

- url: https://www.tradingview.com/script/4tGp6WXL/
- type: indicator
- pine_id: PUB;f63f33dbc8e84b57b59fc1bfe85fc82d
- version: 1.0

## Description

[b]Bitcoin Anchored Power Law Bands | Astral Vision 🌠💠[/b]

This indicator plots a set of price bands derived from the Bitcoin Power Law framework, which models Bitcoin's long-term price trajectory as a power function of the number of days elapsed since the genesis block. Rather than fitting a regression line to the full price history, this implementation anchors the model to a fixed historical reference point (February 10, 2013) and derives the scaling coefficient analytically from the price level at that date, producing a deterministic model that does not shift as new price data is added.

[b]Calculation ⚙️[/b]

The number of days elapsed since the genesis block (January 3, 2009) is computed for both the current bar and the anchor date. The fair value line follows the general power law form: price = k × t^5.8, where t is the number of days since genesis and the exponent 5.8 is the empirically observed slope of Bitcoin's long-term log-log price growth. 
The scaling coefficient k is derived by solving the equation at the anchor point: k = 16.99 / t0^5.8, where t0 is the day count at the anchor date and 16.99 is the calibrated price level at that anchor. This ensures the fair value line passes exactly through the anchor point and projects forward with a fixed slope.

The lower support band is set at 70% of the fair value line, marking the zone below which Bitcoin has historically spent very little time and which has corresponded to the deepest capitulation periods. The bubble lower band is set at 2.0 times the fair value line, representing the lower boundary of historically elevated territory. The bubble upper band applies a dynamic multiplier that decays over time: bubble upper multiplier = 30.5 × (t / t0)^(-1.4), meaning the upper band compresses toward the fair value line as Bitcoin matures, consistent with the empirically observed reduction in peak-to-fair-value distance across successive market cycles.

A background color highlights periods when price falls below the fair value line, marking structurally undervalued territory relative to the power law model.

[b]Plots 📊[/b]
[list]
[*]Fair value line: the anchored power law baseline
[*]Lower support band at 0.7x the fair value line, with fill between the two
[*]Bubble lower band at 2.0x the fair value line
[*]Bubble upper band with time-decaying dynamic multiplier
[*]Background color when price is below the fair value line
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]No period or length inputs: the model is fully derived from the anchor date and fixed power law exponent
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Paradiso.

[b]Purpose 🎯[/b]
Standard moving averages and trend channels reset with each new cycle and have no memory of Bitcoin's full price history. The power law model is anchored to time itself, meaning its output is determined solely by how old Bitcoin is rather than by recent price action. The anchoring approach used here further removes the statistical instability of regression-based power law models, where the fitted line shifts as new data points are added. By fixing the calibration to a single historical reference point, the model produces a stable, non-updating fair value line that can be compared against current price with a consistent long-term reference frame. The time-decaying upper band addresses the limitation of fixed-multiplier models by reflecting Bitcoin's historically compressing cycle amplitude.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision

//@version=6
indicator("Bitcoin Anchored Power Law Bands| Astral Vision 🌠💠", overlay=true)

group1 = "Settings"
group2 = "Astral Colors"

string theme      = input.string("Paradiso", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,0,0),  "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(120,0,0),  "Custom Negative", group=group2)

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

color neu_col = color.rgb(120,120,120)
color blk_col = color.black

int genesis     = timestamp(2009, 1, 3, 0, 0)
int anchor_time = timestamp(2013, 2, 10, 0, 0)

float t  = math.max((time - genesis) / 86400000, 1)
float t0 = math.max((anchor_time - genesis) / 86400000, 1)

float k              = 16.99 / math.pow(t0, 5.8)
float fair           = k * math.pow(t, 5.8)
float bubble_upper_dyn = 30.5 * math.pow(t / t0, -1.4)
float nb_lower       = fair * 0.7
float bubble_lower   = fair * 2.0
float bubble_upper   = fair * bubble_upper_dyn



p1 = plot(fair,         "Support Line",  color=pos_col,                linewidth=3)
p2 = plot(nb_lower,     "Mid Line",      color=pos_col, linewidth=2)
p3 = plot(bubble_lower, "Bubble Lower",  color=neg_col, linewidth=2)
p4 = plot(bubble_upper, "Bubble Upper",  color=neg_col,                linewidth=3)

fill(p1, p2, color=color.new(pos_col, 50))


bgcolor(close < fair ? color.new(pos_col, 50) : na)
````

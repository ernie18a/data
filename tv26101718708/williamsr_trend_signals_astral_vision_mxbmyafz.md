# Williams%R Trend Signals | Astral Vision 

- url: https://www.tradingview.com/script/mxBMYAfZ/
- type: indicator
- pine_id: PUB;310a2a5b49ec45438c279b95280fe633
- version: 1.0

## Description

[b]Williams %R Trend Signals | Astral Vision 🌠💠[/b]

Williams %R measures where the current close sits within the high-low range of the past N bars, expressed on a scale from 0 to −100. 
Values near 0 indicate price is closing at the top of its recent range; values near 100 indicate price is closing at the bottom. Unlike RSI, %R is not smoothed internally, it reacts immediately to price extremes, making it sensitive to momentum shifts at cycle turning points.

This indicator computes Williams %R on the weekly timeframe regardless of chart resolution, then applies a short SMA to reduce week-to-week noise. 
Trend signals fire when the smoothed %R crosses a configurable bull or bear threshold, marking the weekly bars where momentum has definitively shifted regime. 
Each signal is projected as a full-height glowing vertical line on the price chart, making the historical record of macro trend changes immediately visible across the entire chart history.

[b]Calculation ⚙️[/b]

`%R = 100 × (close − Highest(close, length)) / (Highest(close, length) − Lowest(close, length))`

`SMA %R = SMA(%R, sma_length)`

Both are computed on the weekly timeframe. A bull signal fires when the smoothed %R crosses above the bull threshold; a bear signal fires when it crosses below the bear threshold. 
Both thresholds are evaluated on the SMA, not the raw %R, preventing single-bar spikes from triggering signals.

[b]Plots 📊[/b]
[list]
[*]Raw Williams %R line (thin), colored by position relative to the bull threshold
[*]Smoothed SMA %R line (thick), colored by the same logic
[*]Bull and bear threshold lines
[*]Full-height vertical lines on the price chart at each signal bar, rendered with a 4-layer glow (widths 3/6/12/20, transparencies 0/40/65/82) in positive or negative color
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Williams %R Length`: lookback period for highest/lowest range calculation (default 40 weeks)
[*]`SMA Length`: smoothing applied to raw %R before threshold evaluation (default 4 weeks)
[*]`Bull Threshold`: SMA %R level whose upward crossing fires a bull signal (default −90)
[*]`Bear Threshold`: SMA %R level whose downward crossing fires a bear signal (default −30)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Futura. Positive color applies to bull signals and %R readings below the bull threshold; negative color applies to bear signals and readings above it.

[b]Purpose 🎯[/b]

Standard Williams %R indicators operate on the chart's native timeframe and plot a raw oscillator with no signal logic, leaving the trader to visually interpret crosses manually across hundreds of bars. Daily %R generates excessive noise, while the macro-relevant signal is embedded in the weekly structure.

This indicator locks the calculation to the weekly timeframe and adds a smoothing layer specifically to filter noise before threshold evaluation, ensuring signals represent genuine momentum regime changes rather than transient fluctuations. The glowing vertical line output translates each weekly signal event directly onto any chart timeframe, daily, 4H, or lower, making the macro turning point visible at any resolution without requiring the trader to switch between timeframes.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("Williams%R Trend Signals | Astral Vision 🌠💠", max_lines_count = 500)

group1 = "Settings"
group2 = "Astral Colors"

int   wr_len     = input.int(40,   "Williams %R Length",  minval=1,    group=group1)
int   sma_len    = input.int(4,    "SMA Length",          minval=1,    group=group1)
float bull_thresh = input.float(-90.0, "Bull Threshold",  step=1.0,    group=group1)
float bear_thresh = input.float(-30.0, "Bear Threshold",  step=1.0,    group=group1)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group2)

color raw_pos = theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     theme == "Hermes"   ? color.rgb(255,160,0)   :
     color.rgb(255,0,0)
color raw_neg = theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)   :
     theme == "Infinito" ? color.rgb(255,220,80)  :
     theme == "Hermes"   ? color.rgb(0,180,120)   :
     color.rgb(120,0,0)

color col_pos = usecustom ? custom_pos : raw_pos
color col_neg = usecustom ? custom_neg : raw_neg

_pr() =>
    max      = ta.highest(close, wr_len)
    min      = ta.lowest(close,  wr_len)
    percentR = 100 * (close - max) / (max - min)
    smaR     = ta.sma(percentR, sma_len)
    [percentR, smaR]

[percentR, smaR] = request.security(syminfo.tickerid, "W", _pr())

turned_bull = smaR > bull_thresh and smaR[1] <= bull_thresh
turned_bear = smaR < bear_thresh and smaR[1] >= bear_thresh

hline(bull_thresh, title="Bull Threshold", color=#787B86)
hline(bear_thresh, title="Bear Threshold", color=#787B86)

wr_col_raw = percentR < bull_thresh ? col_pos : col_neg
wr_col_sma = smaR     < bull_thresh ? col_pos : col_neg

plot(percentR, title="%R",  color=wr_col_raw, linewidth=1)
plot(smaR,     title="SMA", color=wr_col_sma, linewidth=3)

if turned_bull
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_pos, 0),  width=3,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_pos, 40), width=6,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_pos, 65), width=12, force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_pos, 82), width=20, force_overlay=true)

if turned_bear
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_neg, 0),  width=3,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_neg, 40), width=6,  force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_neg, 65), width=12, force_overlay=true)
    line.new(bar_index, high * 1.5, bar_index, low * 0.5, xloc=xloc.bar_index, extend=extend.both, color=color.new(col_neg, 82), width=20, force_overlay=true)
````

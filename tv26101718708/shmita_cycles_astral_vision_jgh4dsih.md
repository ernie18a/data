# Shmita Cycles | Astral Vision 

- url: https://www.tradingview.com/script/jgH4DSIH/
- type: indicator
- pine_id: PUB;bba3e92cf6184d12b0291da172350124
- version: 1.0

## Description

[b]Shmita Cycles | Astral Vision 🌠💠[/b]

This indicator marks the Shmita years on the Bitcoin chart, highlighting the start and end dates of each seven-year biblical cycle and shading the entire period between them. 
The Shmita (Hebrew for "release" or "sabbatical year") is a one-year period that occurs every seven years in the Jewish calendar, during which debts are cancelled and land lies fallow. 
A number of analysts and researchers have observed that Shmita years have historically coincided with significant financial market stress and Bitcoin cycle lows, making it an unconventional but recurring point of reference in crypto market cycle analysis.

[b]Calculation ⚙️[/b]

The indicator contains three hardcoded Shmita periods with their precise start and end dates derived from the Jewish calendar:

First period: September 25, 2014 to September 13, 2015. This window encompasses Bitcoin's bear market trough and the beginning of the 2015 to 2017 recovery cycle.

Second period: September 7, 2021 to September 25, 2022. This window encompasses the peak of the 2021 bull market and the subsequent bear market, including the FTX collapse and the cycle bottom.

Third period: September 23, 2028 to September 11, 2029. This is the projected future Shmita year based on the fixed seven-year cadence of the Jewish calendar.

On each bar, the indicator checks whether the current bar's timestamp falls within any of the three defined periods. If it does, a background color is applied to the chart for that bar, producing a continuous shaded zone across the entire Shmita window.

At the last bar, three glow lines are drawn at each Shmita start and end date. Each glow is composed of three overlapping vertical lines at the same timestamp: a wide line at 80% transparency, a medium line at 55% transparency, and a thin line at 0% transparency, producing a layered luminous effect. The start date uses the positive theme color and the end date uses the negative theme color, visually distinguishing entry into and exit from each Shmita window.

The vertical lines extend from a fixed high value of 10,000,000 to a fixed low of 10.0, covering Bitcoin's entire historical and plausible future price range on a logarithmic scale without distorting the chart the way coordinate-based approaches would.

[b]Plots 📊[/b]
[list]
[*]Background color shading across each Shmita period
[*]Glow vertical line at each Shmita start date in the positive theme color
[*]Glow vertical line at each Shmita end date in the negative theme color
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]No date or period inputs: the three Shmita windows are hardcoded to the Jewish calendar dates
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Inferno.

[b]Purpose 🎯[/b]
The Shmita cycle is not a technical indicator in the conventional sense: it does not use price, volume, or any mathematical transformation of market data. Its value lies in providing a fixed external temporal reference that has shown empirical overlap with Bitcoin market cycle turning points across the two completed Shmita years since Bitcoin's inception, offering a non-price-derived framework for contextualizing where the current market might sit within a longer macro rhythm. Displaying the future 2028-2029 Shmita window allows traders to mark a calendrical reference point for the projected next cycle without any assumptions about price level.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Shmita Cycles | Astral Vision 🌠💠", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 50)

string theme      = input.string("Inferno", "Color Theme", ["Inferno", "Paradiso", "Futura", "Infinito", "Hermes"], group = "Colors")
bool   usecustom  = input.bool(false, "Use Custom Colors", group = "Colors")
color  custom_pos = input.color(color.rgb(255, 255, 255), "Custom Positive", group = "Colors")
color  custom_neg = input.color(color.rgb(100, 100, 100), "Custom Negative", group = "Colors")

color theme_pos = theme == "Paradiso" ? color.rgb(0, 210, 255) : theme == "Futura" ? color.rgb(0, 255, 180) : theme == "Infinito" ? color.rgb(180, 120, 255) : theme == "Hermes" ? color.rgb(255, 160, 0) : color.rgb(255, 0, 0)
color theme_neg = theme == "Paradiso" ? color.rgb(0, 80, 160) : theme == "Futura" ? color.rgb(180, 0, 255) : theme == "Infinito" ? color.rgb(255, 220, 80) : theme == "Hermes" ? color.rgb(0, 180, 120) : color.rgb(120, 0, 0)
color col_start = usecustom ? custom_pos : theme_pos
color col_end   = usecustom ? custom_neg : theme_neg
color col_zone  = color.new(col_start, 60)
type ShmitaPeriod
    int t_start
    int t_end

var periods = array.from(
    ShmitaPeriod.new(timestamp("2014-09-25"), timestamp("2015-09-13")),
    ShmitaPeriod.new(timestamp("2021-09-07"), timestamp("2022-09-25")),
    ShmitaPeriod.new(timestamp("2028-09-23"), timestamp("2029-09-11"))
)

f_glow(int t, color col, float top, float bot) =>
    line.new(t, top, t, bot, xloc = xloc.bar_time, color = color.new(col, 80), width = 8)
    line.new(t, top, t, bot, xloc = xloc.bar_time, color = color.new(col, 55), width = 4)
    line.new(t, top, t, bot, xloc = xloc.bar_time, color = color.new(col,  0), width = 1)

in_shmita = false
for i = 0 to array.size(periods) - 1
    sp = array.get(periods, i)
    if time >= sp.t_start and time <= sp.t_end
        in_shmita := true

bgcolor(in_shmita ? col_zone : na)

if barstate.islast
    float top = 10000000
    float bot = 10.0
    for i = 0 to array.size(periods) - 1
        sp = array.get(periods, i)
        f_glow(sp.t_start, col_start, top, bot)
        f_glow(sp.t_end,   col_end,   top, bot)
````

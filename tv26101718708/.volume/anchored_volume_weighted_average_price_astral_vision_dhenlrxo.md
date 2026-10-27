# Anchored Volume Weighted Average Price | Astral Vision 

- url: https://www.tradingview.com/script/dHeNlrxO/
- type: indicator
- pine_id: PUB;d9ac3632a27a4596a546f683f6123508
- version: 1.0

## Description

[b]Anchored Volume Weighted Average Price | Astral Vision 🌠💠[/b]

The Volume Weighted Average Price anchored to a fixed date represents the average price at which every Bitcoin has changed hands since that moment, weighted by volume. 
Unlike a moving average which weights bars equally by time an anchored VWAP weights each bar by its trading activity, making it a true reflection of the average cost basis for all market participants who entered after the anchor point.

When price trades above an anchored VWAP, the aggregate of participants since that anchor is in profit. When price trades below it, they are in loss. 
This makes anchored VWAPs among the most reliable dynamic support and resistance levels available, as they represent the price at which the largest volume of participants is either defending a gain or protecting against a loss.

This indicator plots up to 16 simultaneous anchored VWAPs: one per calendar year from 2013 through 2025, plus three fully custom anchors at any user-defined date, all on the price chart with individual color control and labeled at the current bar.

[b]Calculation ⚙️[/b]

`VWAP = Cumulative(HLC3 × Volume) / Cumulative(Volume)`

Accumulation begins on the first bar of the anchor year (or the exact timestamp for custom anchors) and runs continuously to the present bar. Each VWAP is computed independently, carrying its own cumulative price-volume and volume sums from its respective start date.

[b]Plots 📊[/b]
[list]
[*]Up to 13 year-anchored VWAP lines (2013–2025), each with a dual-layer glow (linewidths 6/2, transparency 80/0)
[*]3 custom timestamp-anchored VWAP lines with the same glow rendering
[*]Labeled endpoints at the current bar for every active VWAP, showing year or custom identifier
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`2013` through `2025` :individual toggles to enable each year-anchored VWAP, each with its own color picker
[*]`Custom 1 / 2 / 3`: toggles for three free-anchor VWAPs, each with a date/time input and color picker
[/list]

[b]Colors 🎨[/b]

Each VWAP line has its own independent color, pre-assigned along a spectral progression from violet (2013) through the visible spectrum to yellow (2025), giving each cycle year a visually distinct identity at a glance. Custom anchors default to blue, yellow, and green with full override available.

[b]Purpose 🎯[/b]

Standard VWAP tools on TradingView anchor to the current session or a single user-defined point, offering no way to compare multiple historical anchors simultaneously. Traders who want to assess confluence across different cycle entry points must place and manage anchors manually, one at a time.

This indicator solves that entirely: all major Bitcoin calendar years are available as one-click toggles, letting you layer any combination of historical cost bases onto the chart instantly. The custom anchors extend this to any structurally significant date (cycle lows, halving events, ETF approvals) without any manual drawing tool interaction. Confluence zones where multiple VWAPs converge are immediately visible and have historically acted as the strongest support and resistance levels in Bitcoin's price structure.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Astral Vision 

//@version=6
indicator("Anchored Volume Weighted Average Price | Astral Vision 🌠💠", overlay=true)

show2013 = input.bool(false, "2013", inline="2013")
col2013  = input.color(color.rgb(255, 0,   180), "", inline="2013")
show2014 = input.bool(false, "2014", inline="2014")
col2014  = input.color(color.rgb(180, 0,   255), "", inline="2014")
show2015 = input.bool(false, "2015", inline="2015")
col2015  = input.color(color.rgb(0,   80,  255), "", inline="2015")
show2016 = input.bool(false, "2016", inline="2016")
col2016  = input.color(color.rgb(0,   210, 255), "", inline="2016")
show2017 = input.bool(false, "2017", inline="2017")
col2017  = input.color(color.rgb(0,   255, 180), "", inline="2017")
show2018 = input.bool(false, "2018", inline="2018")
col2018  = input.color(color.rgb(0,   255, 80),  "", inline="2018")
show2019 = input.bool(false, "2019", inline="2019")
col2019  = input.color(color.rgb(255, 255, 0),   "", inline="2019")
show2020 = input.bool(false, "2020", inline="2020")
col2020  = input.color(color.rgb(255, 160, 0),   "", inline="2020")
show2021 = input.bool(false, "2021", inline="2021")
col2021  = input.color(color.rgb(255, 80,  0),   "", inline="2021")
show2022 = input.bool(false, "2022", inline="2022")
col2022  = input.color(color.rgb(255, 0,   0),   "", inline="2022")
show2023 = input.bool(false, "2023", inline="2023")
col2023  = input.color(color.rgb(180, 120, 255),  "", inline="2023")
show2024 = input.bool(false, "2024", inline="2024")
col2024  = input.color(color.rgb(0,   255, 255),  "", inline="2024")
show2025 = input.bool(false, "2025", inline="2025")
col2025  = input.color(color.rgb(255, 220, 80),   "", inline="2025")

show_c1 = input.bool(true, "Custom 1", inline="c1")
time_c1 = input.time(timestamp("2015-01-17"), "", inline="c1")
col_c1  = input.color(color.blue, "", inline="c1")
show_c2 = input.bool(true, "Custom 2", inline="c2")
time_c2 = input.time(timestamp("2018-12-15"), "", inline="c2")
col_c2  = input.color(color.yellow, "", inline="c2")
show_c3 = input.bool(true, "Custom 3", inline="c3")
time_c3 = input.time(timestamp("2023-01-01"), "", inline="c3")
col_c3  = input.color(color.green, "", inline="c3")

f_anchored_vwap(_startYear, _active) =>
    var float cumPV = 0.0
    var float cumVol = 0.0
    var float vwap = na
    if _active
        isActive = year(time) >= _startYear
        if isActive
            cumPV += hlc3 * volume
            cumVol += volume
            vwap := cumPV / cumVol
        else
            vwap := na
    vwap

f_anchored_vwap_ts(_startTs, _active) =>
    var float cumPV = 0.0
    var float cumVol = 0.0
    var float vwap = na
    if _active
        isActive = time >= _startTs
        if isActive
            cumPV += hlc3 * volume
            cumVol += volume
            vwap := cumPV / cumVol
        else
            vwap := na
    vwap

vwap2013 = f_anchored_vwap(2013, show2013)
vwap2014 = f_anchored_vwap(2014, show2014)
vwap2015 = f_anchored_vwap(2015, show2015)
vwap2016 = f_anchored_vwap(2016, show2016)
vwap2017 = f_anchored_vwap(2017, show2017)
vwap2018 = f_anchored_vwap(2018, show2018)
vwap2019 = f_anchored_vwap(2019, show2019)
vwap2020 = f_anchored_vwap(2020, show2020)
vwap2021 = f_anchored_vwap(2021, show2021)
vwap2022 = f_anchored_vwap(2022, show2022)
vwap2023 = f_anchored_vwap(2023, show2023)
vwap2024 = f_anchored_vwap(2024, show2024)
vwap2025 = f_anchored_vwap(2025, show2025)

vwap_c1 = f_anchored_vwap_ts(time_c1, show_c1)
vwap_c2 = f_anchored_vwap_ts(time_c2, show_c2)
vwap_c3 = f_anchored_vwap_ts(time_c3, show_c3)

plot(vwap2013, "VWAP 2013 Glow", color=color.new(col2013, 80), linewidth=6)
plot(vwap2013, "VWAP 2013",      color=col2013,                linewidth=2)
plot(vwap2014, "VWAP 2014 Glow", color=color.new(col2014, 80), linewidth=6)
plot(vwap2014, "VWAP 2014",      color=col2014,                linewidth=2)
plot(vwap2015, "VWAP 2015 Glow", color=color.new(col2015, 80), linewidth=6)
plot(vwap2015, "VWAP 2015",      color=col2015,                linewidth=2)
plot(vwap2016, "VWAP 2016 Glow", color=color.new(col2016, 80), linewidth=6)
plot(vwap2016, "VWAP 2016",      color=col2016,                linewidth=2)
plot(vwap2017, "VWAP 2017 Glow", color=color.new(col2017, 80), linewidth=6)
plot(vwap2017, "VWAP 2017",      color=col2017,                linewidth=2)
plot(vwap2018, "VWAP 2018 Glow", color=color.new(col2018, 80), linewidth=6)
plot(vwap2018, "VWAP 2018",      color=col2018,                linewidth=2)
plot(vwap2019, "VWAP 2019 Glow", color=color.new(col2019, 80), linewidth=6)
plot(vwap2019, "VWAP 2019",      color=col2019,                linewidth=2)
plot(vwap2020, "VWAP 2020 Glow", color=color.new(col2020, 80), linewidth=6)
plot(vwap2020, "VWAP 2020",      color=col2020,                linewidth=2)
plot(vwap2021, "VWAP 2021 Glow", color=color.new(col2021, 80), linewidth=6)
plot(vwap2021, "VWAP 2021",      color=col2021,                linewidth=2)
plot(vwap2022, "VWAP 2022 Glow", color=color.new(col2022, 80), linewidth=6)
plot(vwap2022, "VWAP 2022",      color=col2022,                linewidth=2)
plot(vwap2023, "VWAP 2023 Glow", color=color.new(col2023, 80), linewidth=6)
plot(vwap2023, "VWAP 2023",      color=col2023,                linewidth=2)
plot(vwap2024, "VWAP 2024 Glow", color=color.new(col2024, 80), linewidth=6)
plot(vwap2024, "VWAP 2024",      color=col2024,                linewidth=2)
plot(vwap2025, "VWAP 2025 Glow", color=color.new(col2025, 80), linewidth=6)
plot(vwap2025, "VWAP 2025",      color=col2025,                linewidth=2)

plot(vwap_c1, "Custom 1 Glow", color=color.new(col_c1, 80), linewidth=6)
plot(vwap_c1, "Custom 1",      color=col_c1,                linewidth=2)
plot(vwap_c2, "Custom 2 Glow", color=color.new(col_c2, 80), linewidth=6)
plot(vwap_c2, "Custom 2",      color=col_c2,                linewidth=2)
plot(vwap_c3, "Custom 3 Glow", color=color.new(col_c3, 80), linewidth=6)
plot(vwap_c3, "Custom 3",      color=col_c3,                linewidth=2)

if barstate.islast
    if not na(vwap2013)
        label.new(bar_index, vwap2013, "🌠💠 VWAP 2013", color=color.new(col2013, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2014)
        label.new(bar_index, vwap2014, "🌠💠 VWAP 2014", color=color.new(col2014, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2015)
        label.new(bar_index, vwap2015, "🌠💠 VWAP 2015", color=color.new(col2015, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2016)
        label.new(bar_index, vwap2016, "🌠💠 VWAP 2016", color=color.new(col2016, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2017)
        label.new(bar_index, vwap2017, "🌠💠 VWAP 2017", color=color.new(col2017, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2018)
        label.new(bar_index, vwap2018, "🌠💠 VWAP 2018", color=color.new(col2018, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2019)
        label.new(bar_index, vwap2019, "🌠💠 VWAP 2019", color=color.new(col2019, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2020)
        label.new(bar_index, vwap2020, "🌠💠 VWAP 2020", color=color.new(col2020, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2021)
        label.new(bar_index, vwap2021, "🌠💠 VWAP 2021", color=color.new(col2021, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2022)
        label.new(bar_index, vwap2022, "🌠💠 VWAP 2022", color=color.new(col2022, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2023)
        label.new(bar_index, vwap2023, "🌠💠 VWAP 2023", color=color.new(col2023, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2024)
        label.new(bar_index, vwap2024, "🌠💠 VWAP 2024", color=color.new(col2024, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap2025)
        label.new(bar_index, vwap2025, "🌠💠 VWAP 2025", color=color.new(col2025, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap_c1)
        label.new(bar_index, vwap_c1, "🌠💠 Custom 1", color=color.new(col_c1, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap_c2)
        label.new(bar_index, vwap_c2, "🌠💠 Custom 2", color=color.new(col_c2, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
    if not na(vwap_c3)
        label.new(bar_index, vwap_c3, "🌠💠 Custom 3", color=color.new(col_c3, 40), textcolor=color.white, style=label.style_label_left, size=size.small, text_formatting=text.format_bold)
````

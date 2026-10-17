# EMA Multi-Cloud

- url: https://www.tradingview.com/script/hXl4bnA5-EMA-Multi-Cloud/
- type: indicator
- pine_id: PUB;6225b8933107422ca8a20b2203d5035f
- version: 1.0

## Description

This indicator prints 3 EMAs that has 'clouds'

Fully adjustable inputs and styles

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LittleSympathy

//@version=6
indicator("EMA Multi-Cloud", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
matype          = input.string("EMA", title="MA Type", options=["EMA", "SMA"])
ma_len1         = input.int(9,  title="Short EMA Length")
ma_len2         = input.int(20, title="Long EMA Length")
ma_len3         = input.int(50, title="Longest EMA Length")
src             = input.source(hl2, title="Source")
ma_offset       = input.int(0,  title="Offset")
showlong        = input.bool(false, title="Show Long Alerts")
showshort       = input.bool(false, title="Show Short Alerts")
showLine        = input.bool(false, title="Display EMA Line")
ema1            = input.bool(true,  title="Show EMA Cloud-1")
ema2            = input.bool(true,  title="Show EMA Cloud-2")
emacloudleading = input.int(0, minval=0, title="Leading Period For EMA Cloud")

// ─── COLOUR INPUTS ────────────────────────────────────────────────────────────
col_short_ema       = input.color(color.white,  title="Short EMA Colour",             group="Colours")
col_long_ema_up     = input.color(color.green,  title="Long EMA Colour (Rising)",      group="Colours")
col_long_ema_down   = input.color(color.red,    title="Long EMA Colour (Falling)",     group="Colours")
col_longest_ema     = input.color(color.white,  title="Longest EMA Colour",           group="Colours")
col_cloud1_bull     = input.color(color.yellow, title="Cloud 1 Colour (Bullish)",      group="Colours")
col_cloud1_bear     = input.color(color.white,  title="Cloud 1 Colour (Bearish)",      group="Colours")
col_cloud2_bull     = input.color(color.yellow, title="Cloud 2 Colour (Bullish)",      group="Colours")
col_cloud2_bear     = input.color(color.white,  title="Cloud 2 Colour (Bearish)",      group="Colours")
cloud1_transp       = input.int(40, title="Cloud 1 Transparency", minval=0, maxval=100, group="Colours")
cloud2_transp       = input.int(60, title="Cloud 2 Transparency", minval=0, maxval=100, group="Colours")

// ─── MA FUNCTION ──────────────────────────────────────────────────────────────
f_ma(malen) =>
    float result = na
    if matype == "EMA"
        result := ta.ema(src, malen)
    if matype == "SMA"
        result := ta.sma(src, malen)
    result

// ─── CALCULATIONS ─────────────────────────────────────────────────────────────
mashort   = f_ma(ma_len1)
malong    = f_ma(ma_len2)
malongest = f_ma(ma_len3)

// ─── COLOURS ──────────────────────────────────────────────────────────────────
cloudcolour1 = mashort  >= malong    ? col_cloud1_bull : col_cloud1_bear
cloudcolour2 = malong   >= malongest ? col_cloud2_bull : col_cloud2_bear
malongcolor  = malong   >= malong[1] ? col_long_ema_up : col_long_ema_down

// ─── PLOTS ────────────────────────────────────────────────────────────────────
mashortline1 = plot(ema1 ? mashort : na, color=showLine ? col_short_ema   : na, linewidth=1, offset=emacloudleading, title="Short Leading EMA")
malongline1  = plot(malong,              color=showLine ? malongcolor      : na, linewidth=4, offset=emacloudleading, title="Long Leading EMA")
malongline2  = plot(malongest,           color=showLine ? col_longest_ema  : na, linewidth=4, offset=emacloudleading, title="Longest Leading EMA")

// ─── CLOUDS ───────────────────────────────────────────────────────────────────
fill(mashortline1, malongline1, color=color.new(cloudcolour1, cloud1_transp), title="MA Cloud1")
fill(malongline2,  malongline1, color=color.new(cloudcolour2, cloud2_transp), title="MA Cloud2")
````

# Jellyfish VWAP

- url: https://www.tradingview.com/script/DnVkoNyh-Jellyfish-VWAP/
- type: indicator
- pine_id: PUB;62713b68a9304c2dbb9e6b560bea5cb0
- version: 5.0

## Description

Find and label "hammer" candle for possible long positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sotrosh

//@version=6
indicator("Jellyfish VWAP", overlay=true, max_labels_count=500)
buyTextColor = input.color(color.blue, "BUY Label Color")

vwap_value = ta.vwap(close)
vwap_rounded = math.round(vwap_value / syminfo.mintick) * syminfo.mintick
low_rounded  = math.round(low / syminfo.mintick) * syminfo.mintick
open_rounded = math.round(open / syminfo.mintick) * syminfo.mintick
close_rounded = math.round(close / syminfo.mintick) * syminfo.mintick

is_low_below_vwap = low_rounded < vwap_rounded
is_open_above_vwap = open_rounded > vwap_value
is_close_above_vwap = close_rounded > vwap_value

// BUY LABEL
if is_low_below_vwap and is_open_above_vwap and is_close_above_vwap
    label.new(
        bar_index,
        low,
        "BUY",
        style=label.style_none,
        color=color.green,
        textcolor=buyTextColor,
        size=size.normal
    )
````

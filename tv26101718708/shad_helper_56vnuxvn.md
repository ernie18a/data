# SHAD helper

- url: https://www.tradingview.com/script/56vNUxvN-SHAD-helper/
- type: indicator
- pine_id: PUB;7195683ec1a641d8aad9f64924e1e4b8
- version: 2.0

## Description

Displays lines and labels for prices following the [b]SHAD[/b] strategy.
[b]SHAD[/b] strategy consists in selling half the position every time price doubles, thus this indicator displays values for x2, x4, x8 and x16 of current closing price.
You can also see "/2" (-50%) and "/4 " (-75%) values.

You can edit display colors and labels text size in the indicator's settings

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © seborax

//@version=5
indicator("SHAD helper", overlay=true)

color color_up = input.color(color.teal, "Color for multiples 🚀")
color color_down = input.color(color.red, "Color for losses 📉")

label_size_input = input.string(defval="Normal", title="Label Size", options=["Auto", "Huge", "Large", "Normal", "Small", "Tiny"])
label_size = (label_size_input == "Huge") ? size.huge :
     (label_size_input == "Large") ? size.large :
     (label_size_input == "Small") ? size.small :
     (label_size_input == "Tiny") ? size.tiny :
     (label_size_input == "Auto") ? size.auto :
     size.normal

plot(close / 4, color=color_down, trackprice=true, offset=-9999, title="/4")
plot(close / 2, color=color_down, trackprice=true, offset=-9999, title="/2")
plot(close * 2, color=color_up, trackprice=true, offset=-9999, title="x2")
plot(close * 4, color=color_up, trackprice=true, offset=-9999, title="x4")
plot(close * 8, color=color_up, trackprice=true, offset=-9999, title="x8")
plot(close * 16, color=color_up, trackprice=true, offset=-9999, title="x16")

if barstate.islast
    x = bar_index + 5
    
    label.new(x, close / 4, "/4", textcolor=color_down, size=label_size, style=label.style_none)
    label.new(x, close / 2, "/2", textcolor=color_down, size=label_size, style=label.style_none)
    label.new(x, close * 2, "x2", textcolor=color_up, size=label_size, style=label.style_none)
    label.new(x, close * 4, "x4", textcolor=color_up, size=label_size, style=label.style_none)
    label.new(x, close * 8, "x8", textcolor=color_up, size=label_size, style=label.style_none)
    label.new(x, close * 16, "x16", textcolor=color_up, size=label_size, style=label.style_none)
````

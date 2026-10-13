<!-- tradingview-pine-id: PUB;wOtYtilLJovR295jPxtgyX1BMAiXDSKX -->
<!-- tradingviewscripts-format: 1 -->
# Watermark

Source: https://www.tradingview.com/script/G0I0osGM-Watermark/

## Description

Look in the lower-left corner of this chart. If you load the script on your chart, you will see how the watermark animates. You can personalize it in the script's "Settings/Inputs" tab to use it in your chart snapshots.

Do keep in mind that if you use it when publishing ideas, videos or scripts, [House Rules](https://www.tradingview.com/?solution=43000591638) prohibit advertising on your chart.

For Pine coders
This script uses our new (https://www.tradingview.com/pine-script-docs/en/v4/essential/Tables.html#) feature in Pine to position a watermark on the chart, and the new [varip](https://www.tradingview.com/script/ppQxBISk-Using-varip-variables-PineCoders/) type of variable to animate it.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=5
indicator("Watermark", "", true)

// Watermark
// v2 2022.07.24

// This code was written using the recommendations from the Pine Script™ User Manual's Style Guide:
//   https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html



// ———————————————————— Constants and Inputs {



// ————— Constants
color  WHITE = color.new(color.white, 30)
color  BLUE  = color.new(color.blue, 50)
string ST_1  = "I💙TradingView"
string ST_2  = "I💚Pine"

// ————— Inputs
string GRP1             = "═════════  Text Input  ══════════"
string textInput1       = input.string(ST_1,     "Text 1",    group = GRP1) 
string textInput2       = input.string(ST_2,     "Text 2",    group = GRP1, tooltip = "Clear 'Text 2' to prevent animation.")

string GRP2             = "════════ Information Box ═════════"
string infoBoxSizeInput = input.string("small",  "Size",      inline = "21", group = GRP2, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string infoBoxYPosInput = input.string("bottom", "↕",         inline = "21", group = GRP2, options = ["top", "middle", "bottom"])
string infoBoxXPosInput = input.string("left",   "↔",         inline = "21", group = GRP2, options = ["left", "center", "right"])
int    heightInput      = input.int(3,           "Height",    inline = "22", minval = 1, maxval = 100, tooltip = "1-100")
int    widthInput       = input.int(10,          "Width",     inline = "22", minval = 1, maxval = 100, tooltip = "1-100")
color  textColorInput   = input.color(WHITE,     "Text")
color  bgColorInput     = input.color(BLUE,      "Background")
// }



// ———————————————————— Visuals {


// We use `var` to only initialize the table on the first bar.
var table watermark = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 1, 1)

// We only populate the table on the last bar; it's more efficient.
if barstate.islast
    // This `varip` variable will preserve its value across realtime updates.
    varip bool changeText = true
    // Toggle this value on each update.
    changeText := not changeText
    // If there's a "Text 2" string in inputs and it's time to flip, change the text.
    string txt = str.length(textInput2) != 0 and changeText ? textInput2 : textInput1
    // Populate our table cell.
    table.cell(watermark, 0, 0, txt, widthInput, heightInput, textColorInput, text_size = infoBoxSizeInput, bgcolor = bgColorInput)
// }
````

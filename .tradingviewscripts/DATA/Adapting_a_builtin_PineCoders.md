<!-- tradingview-pine-id: PUB;bn2YRD56TqUmieQrAfhvwN199REAmfPD -->
<!-- tradingviewscripts-format: 1 -->
# Adapting a built-in [PineCoders]

Source: https://www.tradingview.com/script/J8kODTBn-Adapting-a-built-in-PineCoders/

## Description

█ OVERVIEW

This Pine script shows how it can be quite simple to personalize a built-in indicator for your needs.

█ OUR SCRIPT

Our objective was to add the current values for volume​ and its moving average in prominent view, and use brighter colors than the built-in.

We started with the source code from the "Volume" built-in indicator. You can access the source code of many built-ins from the Pine Editor by clicking the "Open" button and choosing "New default built-in script..."

We changed the variable names so they conform to our [Coding Conventions](https://www.pinecoders.com/coding_conventions/). Everybody is of course free to code their scripts the way they want; the conventions provide guidelines for those interested in Pine-specific recommendations. We use our conventions to make our code more readable, which helps readers of open-source publications. As Uncle Bob, a.k.a. Robert Cecil Martin, argues in his "Clean Code" book, code that is easier to read is also useful for its first user: you.

We assigned the colors we use to constants because they are used in multiple places in the script. If we decide to change them, we only need to change the constant definitions for the change to trickle down to the rest of the code.

We used the `inline` and `tooltip` parameters of [input()](https://www.tradingview.com/pine-script-reference/v4/#fun_input) to better organize our inputs and provide extra information under an "i" icon when needed.

We wanted to pack more information in the display of the moving average and volume​ than just the values, so we color-coded their background:
 • When the MA is rising, the background of its table cell is in the bull color, otherwise it's in the bear color. The period used for the MA is also displayed in that cell's legend.
 • When the current volume's value is higher/lower than its MA, the background of its cell is of bull/bear color.
We use a Pine table to display our values. We use extra cells to provide a configurable margin to the left, and a small space between the two values.

Because we only use constant colors in this script (i.e., values that are known at compile time), users can change the colors in the "Setting/Style" tab's color widgets. Users of the script can also use the tab to change other attributes of the plots.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PineCoders

//@version=5
indicator("Adapting a built-in [PineCoders]", "Vol", format = format.volume)

// Adapting a built-in [PineCoders]
// v3, 2022.10.01

// This code was written using the recommendations from the Pine Script™ User Manual's Style Guide:
//   https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html



// ———————————————————— Constants and Inputs {


// ————— Constants
color BULL  = #00FF00
color BEAR  = #FF0000
color MA    = color.new(color.gray, 40)
color GRAY  = #808080ff
color WHITE = #FFFFFFff

// ————— Inputs
bool    showMaInput             = input.bool(true,          "Show MA, ",                inline = "ma")
int     maLengthInput           = input.int(20,             "Length",                   inline = "ma", minval = 1)
bool    usePrevClInput          = input.bool(false,         "Color columns based on previous close")
bool    showInfoBoxInput        = input.bool(true,          "Show values")
string  infoBoxSizeInput        = input.string("normal",    "Size ",                    inline = "display", options = ["tiny", "small", "normal", "large", "huge", "auto"])
string  infoBoxYPosInput        = input.string("top",       "↕",                        inline = "display", options = ["top", "middle", "bottom"])
string  infoBoxXPosInput        = input.string("left",      "↔",                        inline = "display", options = ["left", "center", "right"])
color   infoBoxTxtColorInput    = input.color(WHITE,        "T",                        inline = "display")
float   leftMarginInput         = input.float(2.0,          "Left margin",              minval =  1,  maxval = 100, step = 0.5, tooltip = "1-100")
// } 



// ———————————————————— Calculations {


// Color of the volume columns.
color columns = usePrevClInput ? close[1] > close ? BEAR : BULL : open > close ? BEAR : BULL
// MA of volume calculation. We use `nz()` so that value is zero when the symbol has no volume information.
float ma = ta.sma(nz(volume), maLengthInput)
// Detect when the MA is rising. Will be used to determine the color of the background of the MA value's table cell.
bool maRises = ta.rising(ma, 1)
// }



// ———————————————————— Visuals {


// ————— Display table
if showInfoBoxInput
    // Create a 4-column, 1-row table.
    var table infoBox = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 4, 1)
    // MA cell's bg is bull color when MA is rising.
    color bgMa = maRises ? BULL : BEAR
    // Volume cell's bg is bull color when volume is above its MA.
    color bgVol = volume > ma ? BULL : BEAR
    if barstate.isfirst
        // Left margin.
        table.cell(infoBox, 0, 0, " ", width = leftMarginInput)
        table.cell(infoBox, 1, 0, "",  text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput, bgcolor = bgMa)
        // Small space between values (note that you can use a float width).
        table.cell(infoBox, 2, 0, " ", width = 0.5)
        table.cell(infoBox, 3, 0, "",  text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput, bgcolor = bgVol)
    else if barstate.islast
        table.cell_set_text(   infoBox, 1, 0, str.format("SMA({0}): {1,number,###,####,###}", maLengthInput, ma))
        table.cell_set_bgcolor(infoBox, 1, 0, bgMa) 
        table.cell_set_text(   infoBox, 3, 0, str.format("Vol: {0,number,###,####,###}", nz(volume)))
        table.cell_set_bgcolor(infoBox, 3, 0, bgVol)  
        
// ————— Plots
plot(volume, "Volume", columns, 1, plot.style_columns)
plot(showMaInput ? ma : na, "Volume MA", MA, 1, plot.style_area)
// }
````

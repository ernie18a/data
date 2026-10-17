# Current Month Display

- url: https://www.tradingview.com/script/QWneBAhh-Current-Month-Display/
- type: indicator
- pine_id: PUB;f420a9e287d74c1c8a231caaddb60755
- version: 1.0

## Description

The Current Month Display indicator shows the month from the latest bar’s timestamp in the symbol’s exchange timezone.

You can customise its horizontal alignment, top/bottom placement, margin spacing, letter case, text colour, font family, font style, and size.

By default, it's uppercase and centred at the bottom.

This indicator is especially useful when collecting ‘playbook’ examples on a higher timeframe.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Current Month Display", overlay = true)

// --- Inputs ---
string GROUP_LAYOUT = "Layout"
string GROUP_STYLE = "Style"

horizontalInput = input.string("Center", "Horizontal alignment", options = ["Left", "Center", "Right"], group = GROUP_LAYOUT, tooltip = "Choose where the month appears horizontally on the chart.")
verticalInput = input.string("Bottom", "Vertical placement", options = ["Top", "Bottom"], group = GROUP_LAYOUT, tooltip = "Choose whether the month appears near the top or bottom of the chart.")
marginInput = input.float(3.0, "Margin spacing (%)", minval = 0.0, maxval = 30.0, step = 0.5, group = GROUP_LAYOUT, tooltip = "Sets the empty space between the month and the selected top or bottom edge, as a percentage of the chart pane height.")
caseInput = input.string("Uppercase", "Letter case", options = ["Uppercase", "Lowercase", "Title case"], group = GROUP_STYLE, tooltip = "Choose uppercase, lowercase, or title-case month text.")
monthColorInput = input.color(color.new(#DBDBDB, 0), "Text color", group = GROUP_STYLE, tooltip = "Choose the month text color.")
fontFamilyInput = input.string("Default", "Font family", options = ["Default", "Monospace"], group = GROUP_STYLE, tooltip = "Choose the standard or monospace font family.")
fontStyleInput = input.string("Normal", "Font style", options = ["Normal", "Bold", "Italic", "Bold italic"], group = GROUP_STYLE, tooltip = "Choose normal, bold, italic, or bold italic text formatting.")
textSizeInput = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GROUP_STYLE, tooltip = "Choose the month label size.")

// --- Layout ---
tablePosition = switch
    verticalInput == "Top" and horizontalInput == "Left" => position.top_left
    verticalInput == "Top" and horizontalInput == "Center" => position.top_center
    verticalInput == "Top" and horizontalInput == "Right" => position.top_right
    verticalInput == "Bottom" and horizontalInput == "Left" => position.bottom_left
    verticalInput == "Bottom" and horizontalInput == "Center" => position.bottom_center
    => position.bottom_right

textAlignment = switch horizontalInput
    "Left" => text.align_left
    "Right" => text.align_right
    => text.align_center

fontFamily = fontFamilyInput == "Monospace" ? font.family_monospace : font.family_default
textFormatting = switch fontStyleInput
    "Bold" => text.format_bold
    "Italic" => text.format_italic
    "Bold italic" => text.format_bold + text.format_italic
    => text.format_none
textSize = switch textSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge" => size.huge
    => size.normal

var table monthTable = table.new(position = tablePosition, columns = 1, rows = 2, bgcolor = color.new(color.black, 100), frame_width = 0, border_width = 0)

// --- Month label ---
var array<string> monthNames = array.from("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
monthNumber = month(time, syminfo.timezone)
monthName = array.get(monthNames, monthNumber - 1)
monthText = switch caseInput
    "Uppercase" => str.upper(monthName)
    "Lowercase" => str.lower(monthName)
    => monthName

if barstate.islast
    if verticalInput == "Top"
        table.cell(monthTable, 0, 0, text = "", height = marginInput, bgcolor = color.new(color.black, 100))
        table.cell(monthTable, 0, 1, text = monthText, text_color = monthColorInput, text_halign = textAlignment, text_valign = text.align_center, text_size = textSize, bgcolor = color.new(color.black, 100), text_font_family = fontFamily, text_formatting = textFormatting)
    else
        table.cell(monthTable, 0, 0, text = monthText, text_color = monthColorInput, text_halign = textAlignment, text_valign = text.align_center, text_size = textSize, bgcolor = color.new(color.black, 100), text_font_family = fontFamily, text_formatting = textFormatting)
        table.cell(monthTable, 0, 1, text = "", height = marginInput, bgcolor = color.new(color.black, 100))
````

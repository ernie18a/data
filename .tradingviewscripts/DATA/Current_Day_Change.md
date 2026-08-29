<!-- tradingview-pine-id: PUB;c650110dc6d44292be3454a0b5b0b544 -->
<!-- tradingviewscripts-format: 1 -->
# Current Day % Change

Source: https://www.tradingview.com/script/54ZaKlkn-Current-Day-Change/

## Description

Display Current Day % Change
On every TF
Options :
Color Option 
Font Option
Location Option

---

## Source Code

````pine
//@version=6
indicator("Current Day % Change", overlay=true)

//=========================
// Inputs
//=========================
locationInput = input.string("Top Right", "Location", options=[
     "Top Left", "Top Center", "Top Right",
     "Middle Left", "Middle Center", "Middle Right",
     "Bottom Left", "Bottom Center", "Bottom Right"])

fontSize = input.string("Large", "Font Size", options=["Tiny","Small","Normal","Large","Huge"])

positiveColor = input.color(color.lime, "Positive Color")
negativeColor = input.color(color.red, "Negative Color")
textColor = input.color(color.white, "Text Color")
backgroundColor = input.color(color.new(color.black, 20), "Background Color")

//=========================
// Convert Location
//=========================
tablePosition =
     locationInput == "Top Left" ? position.top_left :
     locationInput == "Top Center" ? position.top_center :
     locationInput == "Top Right" ? position.top_right :
     locationInput == "Middle Left" ? position.middle_left :
     locationInput == "Middle Center" ? position.middle_center :
     locationInput == "Middle Right" ? position.middle_right :
     locationInput == "Bottom Left" ? position.bottom_left :
     locationInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

//=========================
// Convert Font Size
//=========================
txtSize =
     fontSize == "Tiny" ? size.tiny :
     fontSize == "Small" ? size.small :
     fontSize == "Normal" ? size.normal :
     fontSize == "Large" ? size.large :
     size.huge

//=========================
// Current Day Change
//=========================
dayOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

changePercent = ((close - dayOpen) / dayOpen) * 100

displayColor = changePercent >= 0 ? positiveColor : negativeColor

//=========================
// Table
//=========================
var table t = table.new(tablePosition, 1, 1)

if barstate.islast
    table.cell(
         t,
         0,
         0,
         str.format("{0,number,+0.00;-0.00}%", changePercent),
         text_color=textColor,
         bgcolor=backgroundColor,
         text_size=txtSize)

    table.cell_set_text_color(t, 0, 0, displayColor)
````

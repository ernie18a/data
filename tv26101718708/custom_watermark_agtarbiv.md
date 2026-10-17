# Custom Watermark

- url: https://www.tradingview.com/script/AGTArbIv-Custom-Watermark/
- type: indicator
- pine_id: PUB;29a5e97471ed4e169d68524142039f7b
- version: 1.0

## Description

You can customize:

* Text: Anything you want (e.g., DISCIPLINE, FOLLOW THE PLAN, NO FOMO).
* Size: Tiny, Small, Normal, Large, or Huge.
* Color: Any TradingView-supported color.
* Transparency: 0 (fully opaque) to 100 (fully transparent).
* Position: Any of the nine standard positions (corners, edges, or center).

For an unobtrusive watermark, a good combination is:

* Color: Light Gray
* Transparency: 90–95%
* Size: Huge
* Position: Center

This gives a subtle reminder without obscuring your chart.

## Source Code

````pine
//@version=6
indicator("Custom Watermark", overlay=true)

// ===== INPUTS =====
watermarkText = input.string("DISCIPLINE", "Watermark Text")

textSize = input.string(
     "Huge",
     "Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"]
)

textColor = input.color(color.gray, "Text Color")

transparency = input.int(
     85,
     "Transparency",
     minval = 0,
     maxval = 100
)

position = input.string(
     "Center",
     "Position",
     options = [
         "Top Left",
         "Top Center",
         "Top Right",
         "Center Left",
         "Center",
         "Center Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ]
)

// ===== SIZE =====
sizeValue =
     textSize == "Tiny"   ? size.tiny :
     textSize == "Small"  ? size.small :
     textSize == "Normal" ? size.normal :
     textSize == "Large"  ? size.large :
     size.huge

// ===== POSITION =====
pos =
     position == "Top Left" ? position.top_left :
     position == "Top Center" ? position.top_center :
     position == "Top Right" ? position.top_right :
     position == "Center Left" ? position.middle_left :
     position == "Center" ? position.middle_center :
     position == "Center Right" ? position.middle_right :
     position == "Bottom Left" ? position.bottom_left :
     position == "Bottom Center" ? position.bottom_center :
     position.bottom_right

// ===== TABLE =====
var table wm = table.new(pos, 1, 1)

if barstate.islast
    table.cell(
         wm,
         0,
         0,
         watermarkText,
         text_color = color.new(textColor, transparency),
         text_size = sizeValue,
         bgcolor = color.new(color.black, 100)
    )
````

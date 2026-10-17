# Custom Banner ( Motivation Words )

- url: https://www.tradingview.com/script/cNZyQphm-Custom-Banner-Motivation-Words/
- type: indicator
- pine_id: PUB;909a0e6058604f0cb13cb57bd2580d10
- version: 1.0

## Description

A custom banner with motivational words to inspire daily success and positivity.”


“Boost your mindset with a custom motivational banner filled with powerful words that inspire action, focus, and success.”

## Source Code

````pine
//@version=6
indicator("Custom Banner", overlay=true)

// Inputs
bannerText = input.string("@Sindhi ", "Banner Text")
mottoText  = input.string("PATIENCE | DISCIPLINE | RISK MANAGEMENT | TIME | EXECUTION", "Motto")

textColor = input.color(color.white, "Text Color")
bgColor   = input.color(color.black, "Background Color")

showBanner = input.bool(true, "Show Banner")

bannerSizeInput = input.string("Large", "Banner Size",
     options=["Tiny","Small","Normal","Large","Huge"])

mottoSizeInput = input.string("Small", "Motto Size",
     options=["Tiny","Small","Normal","Large","Huge"])

// Convert text size
bannerSize =
     bannerSizeInput == "Tiny"   ? size.tiny :
     bannerSizeInput == "Small"  ? size.small :
     bannerSizeInput == "Normal" ? size.normal :
     bannerSizeInput == "Large"  ? size.large :
     size.huge

mottoSize =
     mottoSizeInput == "Tiny"   ? size.tiny :
     mottoSizeInput == "Small"  ? size.small :
     mottoSizeInput == "Normal" ? size.normal :
     mottoSizeInput == "Large"  ? size.large :
     size.huge

// Create table
var table banner = table.new(position.top_center, 1, 2)

if barstate.islast and showBanner
    table.cell(banner, 0, 0, bannerText,
         text_color=textColor,
         bgcolor=bgColor,
         text_size=bannerSize)

    table.cell(banner, 0, 1, mottoText,
         text_color=textColor,
         bgcolor=bgColor,
         text_size=mottoSize)
````

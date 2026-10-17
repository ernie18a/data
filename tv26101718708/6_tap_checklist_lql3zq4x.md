# 6 TAP Checklist 

- url: https://www.tradingview.com/script/Lql3Zq4X-6-TAP-Checklist/
- type: indicator
- pine_id: PUB;7eaf31864bfa4e0881a6299bb8b1ccb3
- version: 1.0

## Description

6TAP rules checklist.
6 Rules applied before entering, not all checked align, box stays red, trade is a no-go zone, all 6 align, box turns green trade is good to go

## Source Code

````pine
//@version=5
indicator("6 TAP Checklist Clean", overlay=true)

// Inputs
structure = input.bool(false, "Market Structure aligned")
liquidity = input.bool(false, "Liquidity swept")
poi       = input.bool(false, "POI identified")
taps      = input.bool(false, "5 taps complete")
entry     = input.bool(false, "Entry confirmed")
risk      = input.bool(false, "Risk defined")

// Score
score = (structure ? 1 : 0) + (liquidity ? 1 : 0) + (poi ? 1 : 0) + (taps ? 1 : 0) + (entry ? 1 : 0) + (risk ? 1 : 0)

// Status
isValid = score == 6

// ✅ DOT + STATUS
statusDot  = isValid ? "🟢" : "🔴"
statusText = isValid ? "TRADE" : "NO TRADE"

// Build text
txt = statusDot + " 6 TAP CHECKLIST"
txt += "\n"
txt += "\n1  M Structure aligned: " + (structure ? "✔" : "✘")
txt += "\n2  Liquidity swept: " + (liquidity ? "✔" : "✘")
txt += "\n3  POI identified: " + (poi ? "✔" : "✘")
txt += "\n4  5 Taps complete: " + (taps ? "✔" : "✘")
txt += "\n5  Entry confirmed: " + (entry ? "✔" : "✘")
txt += "\n6  Risk defined: " + (risk ? "✔" : "✘")
txt += "\n"
txt += "\nSTEP: " + str.tostring(score) + "/6"
txt += "\nSTATUS: " + statusText

// Table (bottom-left)
var table t = table.new(position.bottom_left, 1, 1)

// Background color
bg = isValid ? color.new(#99ef9c, 10) : color.new(#e7b3b3, 10)

// Update table
table.cell(t, 0, 0, txt, text_color=color.black, bgcolor=bg)
````

# Black Diamond - Institutional, Banking and Retail Zones

- url: https://www.tradingview.com/script/jpjiXgIo-Black-Diamond-Institutional-Banking-and-Retail-Zones/
- type: indicator
- pine_id: PUB;29a7c06c89ad4a0a99b778105dfde7c3
- version: 1.0

## Description

# Black Diamond – Institutional, Banking & Retail Zones

## Overview

Black Diamond – Institutional, Banking & Retail Zones is a dynamic support and resistance indicator designed to automatically identify and display key psychological price levels where market participants are most likely to react.

The indicator classifies these levels into three categories:

• Banking Levels – Major liquidity and psychological levels
• Institutional Levels – Smart money accumulation and distribution levels
• Retail Levels – Minor round-number reaction levels

Unlike traditional round-number indicators that require manual adjustment, Black Diamond automatically adapts to Forex, Gold, Indices, Crypto and Stocks, ensuring the levels remain relevant regardless of the asset being traded.

The indicator provides clear visual zones rather than single lines, helping traders focus on areas of interest instead of exact prices.

---

## What Are Banking Levels?

Banking Levels are major psychological price levels where large institutions, banks and professional traders frequently place orders.

Examples:

Gold:

* 3300
* 3400
* 3500

Forex:

* 1.1000
* 1.2000
* 1.3000

These areas often act as:

* Major support and resistance
* Liquidity targets
* Stop hunt locations
* Profit-taking zones
* Trend reversal areas

Banking Levels are generally considered the strongest levels displayed by the indicator.

---

## What Are Institutional Levels?

Institutional Levels sit between the major banking levels and represent areas where professional money often accumulates or distributes positions.

Examples:

Gold:

* 3350
* 3450

Forex:

* 1.1050
* 1.2050

Institutional Levels commonly provide:

* Pullback opportunities
* Continuation entries
* Intermediate support and resistance
* Smart money reaction zones

These levels are typically stronger than retail levels but weaker than major banking levels.

---

## What Are Retail Levels?

Retail Levels are smaller round numbers that many traders naturally focus on.

Examples:

Gold:

* 3310
* 3320
* 3330

Forex:

* 1.1010
* 1.1020

These levels often create:

* Temporary pauses in price
* Scalping opportunities
* Minor support and resistance
* Intraday reaction points

Retail Levels are generally the weakest of the three categories but can still provide valuable intraday information.

---

## Key Features

✔ Automatic asset detection

✔ Automatically adapts to:

* Forex
* Gold
* Silver
* Indices
* Stocks
* Cryptocurrency

✔ Adjustable level visibility

✔ Banking, Institutional and Retail level filtering

✔ Adjustable number of visible levels

✔ Zone-based visualization

✔ Custom colours

✔ Centre-line display option

✔ Label display option

✔ Built-in alert conditions

✔ Clean chart design

---

## Recommended Settings

### Scalping

Timeframes:

* 1 Minute
* 3 Minute
* 5 Minute

Settings:

* Levels Above/Below: 3–5
* Banking Levels: ON
* Institutional Levels: ON
* Retail Levels: OFF or ON depending on preference

---

### Intraday Trading

Timeframes:

* 15 Minute
* 30 Minute
* 1 Hour

Settings:

* Levels Above/Below: 5–7
* Banking Levels: ON
* Institutional Levels: ON
* Retail Levels: ON

---

### Swing Trading

Timeframes:

* 4 Hour
* Daily

Settings:

* Levels Above/Below: 8–10
* Banking Levels: ON
* Institutional Levels: ON
* Retail Levels: OFF

---

## Best Used With

This indicator performs best when combined with:

* Market Structure
* BOS (Break of Structure)
* CHoCH (Change of Character)
* Liquidity Sweeps
* Fair Value Gaps (FVGs)
* Order Blocks
* Volume Analysis
* Session Highs and Lows
* Trend Confirmation

The zones should be treated as areas of interest rather than standalone entry signals.

---

## Alerts

The indicator includes alert conditions for:

• Price entering a Banking Zone

• Price entering an Institutional Zone

• Price entering a Retail Zone

These alerts can be used to notify traders when price approaches important areas that may provide trading opportunities.

---

## Disclaimer

This indicator is provided for educational and informational purposes only. It does not provide financial advice and should not be considered a recommendation to buy or sell any financial instrument. Always conduct your own analysis and apply proper risk management before entering any trade.

## Source Code

````pine
//@version=6
indicator("Black Diamond - Institutional, Banking and Retail Zones", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
levelMode = input.string("Auto", "Level Mode", options=["Auto", "Manual"])
cleanMode = input.bool(true, "Clean Mode - Less Clutter")

levelsAboveBelow = input.int(5, "Levels Above & Below Current Price", minval=1, maxval=10)

extendLeft  = input.int(80, "Extend Zones Left", minval=10, maxval=500)
extendRight = input.int(30, "Extend Zones Right", minval=5, maxval=300)

showBanking     = input.bool(true, "Show Banking Levels")
showInstitution = input.bool(true, "Show Institutional Levels")
showRetail      = input.bool(true, "Show Retail Levels")

manualBankingStep     = input.float(100.0, "Manual Banking Level Step", step=0.0001)
manualInstitutionStep = input.float(50.0, "Manual Institutional Level Step", step=0.0001)
manualRetailStep      = input.float(10.0, "Manual Retail Level Step", step=0.0001)

showMidLines = input.bool(true, "Show Centre Lines")
showLabels   = input.bool(true, "Show Labels")

//━━━━━━━━━━━━━━━━━━━
// COLOURS
//━━━━━━━━━━━━━━━━━━━
bankingColour     = input.color(color.new(color.purple, 82), "Banking Zone Colour")
institutionColour = input.color(color.new(color.blue, 86), "Institutional Zone Colour")
retailColour      = input.color(color.new(color.gray, 90), "Retail Zone Colour")

bankingLineColour     = input.color(color.purple, "Banking Line Colour")
institutionLineColour = input.color(color.blue, "Institutional Line Colour")
retailLineColour      = input.color(color.gray, "Retail Line Colour")

//━━━━━━━━━━━━━━━━━━━
// AUTO SPACING
//━━━━━━━━━━━━━━━━━━━
f_autoRetailStep() =>
    float step = 10.0

    if syminfo.type == "forex"
        step := close > 20 ? 0.10 : 0.0010
    else if close < 10
        step := 0.10
    else if close < 100
        step := 1.0
    else if close < 1000
        step := 5.0
    else if close < 10000
        step := 10.0
    else if close < 50000
        step := 50.0
    else
        step := 100.0

    step

float retailStep      = levelMode == "Auto" ? f_autoRetailStep() : manualRetailStep
float institutionStep = levelMode == "Auto" ? retailStep * 5.0 : manualInstitutionStep
float bankingStep     = levelMode == "Auto" ? retailStep * 10.0 : manualBankingStep

float retailZoneSize      = retailStep * 0.08
float institutionZoneSize = institutionStep * 0.035
float bankingZoneSize     = bankingStep * 0.025

//━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━
var array<box> zones = array.new<box>()
var array<line> midLines = array.new<line>()
var array<label> zoneLabels = array.new<label>()

//━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━
f_clear() =>
    while array.size(zones) > 0
        box.delete(array.pop(zones))

    while array.size(midLines) > 0
        line.delete(array.pop(midLines))

    while array.size(zoneLabels) > 0
        label.delete(array.pop(zoneLabels))

f_isMultiple(float _level, float _step) =>
    math.abs(_level - math.round(_level / _step) * _step) <= syminfo.mintick * 20

f_drawZone(float _level, float _size, color _bg, color _lineColour, string _txt) =>
    int leftBar  = bar_index - extendLeft
    int rightBar = bar_index + extendRight

    float top    = _level + _size
    float bottom = _level - _size

    box b = box.new(leftBar, top, rightBar, bottom, bgcolor=_bg, border_color=color.new(_lineColour, 45))
    array.push(zones, b)

    if showMidLines
        line l = line.new(leftBar, _level, rightBar, _level, color=_lineColour, width=1, style=line.style_dashed)
        array.push(midLines, l)

    if showLabels
        label lab = label.new(
             rightBar,
             _level,
             _txt + " " + str.tostring(_level, format.mintick),
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(_lineColour, 20),
             size=size.tiny)

        array.push(zoneLabels, lab)

//━━━━━━━━━━━━━━━━━━━
// MAIN DRAWING
//━━━━━━━━━━━━━━━━━━━
if barstate.islast
    f_clear()

    float base = math.floor(close / retailStep) * retailStep

    for i = -levelsAboveBelow to levelsAboveBelow
        float level = base + i * retailStep

        bool isBanking = f_isMultiple(level, bankingStep)
        bool isInstitution = f_isMultiple(level, institutionStep) and not isBanking
        bool isRetail = not isBanking and not isInstitution

        if showBanking and isBanking
            f_drawZone(level, bankingZoneSize, bankingColour, bankingLineColour, "BANKING")

        if showInstitution and isInstitution
            f_drawZone(level, institutionZoneSize, institutionColour, institutionLineColour, "INSTITUTION")

        if showRetail and isRetail
            f_drawZone(level, retailZoneSize, retailColour, retailLineColour, "RETAIL LEVEL")

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
bool nearBanking = false
bool nearInstitution = false
bool nearRetail = false

float baseAlert = math.floor(close / retailStep) * retailStep

for i = -levelsAboveBelow to levelsAboveBelow
    float level = baseAlert + i * retailStep

    bool isBanking = f_isMultiple(level, bankingStep)
    bool isInstitution = f_isMultiple(level, institutionStep) and not isBanking
    bool isRetail = not isBanking and not isInstitution

    if isBanking and high >= level - bankingZoneSize and low <= level + bankingZoneSize
        nearBanking := true

    if isInstitution and high >= level - institutionZoneSize and low <= level + institutionZoneSize
        nearInstitution := true

    if isRetail and high >= level - retailZoneSize and low <= level + retailZoneSize
        nearRetail := true

alertcondition(nearBanking, "Price Entered Banking Zone", "Price has entered a Banking level zone")
alertcondition(nearInstitution, "Price Entered Institutional Zone", "Price has entered an Institutional level zone")
alertcondition(nearRetail, "Price Entered Retail Zone", "Price has entered a Retail level zone")
````

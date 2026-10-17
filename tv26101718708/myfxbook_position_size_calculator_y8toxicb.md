# Myfxbook Position Size Calculator

- url: https://www.tradingview.com/script/Y8toXICB-Myfxbook-Position-Size-Calculator/
- type: indicator
- pine_id: PUB;ec50ab73650f45a7a053e08095f2a4aa
- version: 1.0

## Description

Position size calculator for forex.

Based on myfxbook position size calculator. Designed to have a similar layout without the user having to switch between the chart and myfxbook calculator.

You enter your account size, account currency, risk ratio % and stop loss into settings.

It will automatically calculate the lot sizing required, so you can enter it into Metatrader for example.

It's customisable so you can change the colours and font etc

Hope it's useful to you...

https://www.tradingview.com/x/DbQC43lK/

https://www.tradingview.com/x/LQAw0ypR/

https://www.tradingview.com/x/V61aAqCQ/

## Source Code

````pine
//@version=6
indicator("Myfxbook Position Size Calculator", overlay=true, behind_chart=false)

//==================================================
// 1. CALCULATOR INPUTS — AT THE TOP OF SETTINGS
//==================================================

accountCurrency = input.string(
     "USD",
     "Account Currency",
     options=["GBP", "USD", "EUR"],
     group="Calculator Inputs")

accountSize = input.float(
     1000,
     "Account Size",
     minval=0.01,
     group="Calculator Inputs")

riskPercent = input.float(
     1.0,
     "Risk Ratio, %",
     minval=0.01,
     group="Calculator Inputs")

stopPips = input.float(
     20.0,
     "Stop-Loss, pips",
     minval=0.1,
     group="Calculator Inputs")

//==================================================
// 2. DISPLAY SETTINGS
//==================================================

// Calculator position
positionInput = input.string(
     position.top_right,
     "Calculator Position",
     options=[
         position.top_left,
         position.top_center,
         position.top_right,
         position.middle_left,
         position.middle_center,
         position.middle_right,
         position.bottom_left,
         position.bottom_center,
         position.bottom_right
     ],
     group="Display Settings")

// Font family
fontInput = input.string(
     "Default",
     "Font",
     options=["Default", "Monospace"],
     group="Display Settings")

fontFamily = fontInput == "Monospace" ?
     font.family_monospace : font.family_default

// Font size
fontSizeInput = input.string(
     "Small",
     "Font Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group="Display Settings")

fontSize = switch fontSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

//==================================================
// 3. DISPLAY COLOURS
//==================================================

backgroundColour = input.color(
     color.white,
     "Background Colour",
     group="Display Colours")

textColour = input.color(
     color.rgb(45, 45, 55),
     "Body Text Colour",
     group="Display Colours")

gridColour = input.color(
     color.black,
     "Grid and Border Colour",
     group="Display Colours")

//==================================================
// 4. UPPER HEADING COLOURS
//==================================================

upperHeadingBackground = input.color(
     color.rgb(46, 35, 155),
     "Upper Heading Background",
     group="Upper Heading Colours")

upperHeadingText = input.color(
     color.white,
     "Upper Heading Text",
     group="Upper Heading Colours")

//==================================================
// 5. LOWER HEADING COLOURS
//==================================================

lowerHeadingBackground = input.color(
     color.rgb(46, 35, 155),
     "Lower Heading Background",
     group="Lower Heading Colours")

lowerHeadingText = input.color(
     color.white,
     "Lower Heading Text",
     group="Lower Heading Colours")

//==================================================
// AUTOMATIC CURRENCY PAIR
//==================================================

baseCurrency = syminfo.basecurrency
quoteCurrency = syminfo.currency

pair = baseCurrency + quoteCurrency

isForex = syminfo.type == "forex" and
     str.length(baseCurrency) == 3 and
     str.length(quoteCurrency) == 3

pipSize = quoteCurrency == "JPY" ? 0.01 : 0.0001

//==================================================
// POSITION SIZE CALCULATION
//==================================================

riskMoney = accountSize * riskPercent / 100.0

conversionRate = request.currency_rate(
     quoteCurrency,
     accountCurrency,
     true)

pipValuePerUnit = pipSize * conversionRate

valid = isForex and
     not na(conversionRate) and
     conversionRate > 0 and
     stopPips > 0

units = valid ?
     riskMoney / (stopPips * pipValuePerUnit) : na

lots = units / 100000.0

//==================================================
// CURRENCY SYMBOL
//==================================================

currencySymbol = switch accountCurrency
    "GBP" => "£"
    "USD" => "$"
    "EUR" => "€"

//==================================================
// TABLE CREATION
//==================================================

var table panel = table.new(
     positionInput,
     2,
     10,
     bgcolor=backgroundColour,
     frame_color=gridColour,
     frame_width=2,
     border_color=gridColour,
     border_width=1)

// Merge cells for the upper heading
if barstate.isfirst
    table.merge_cells(panel, 0, 0, 1, 0)

//==================================================
// DISPLAY
//==================================================

if barstate.islast

    // UPPER HEADING
    table.cell(
         panel, 0, 0,
         "POSITION SIZE CALCULATOR",
         bgcolor=upperHeadingBackground,
         text_color=upperHeadingText,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // CURRENCY PAIR
    table.cell(
         panel, 0, 1,
         "Currency Pair",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 1,
         isForex ? pair : "Unsupported",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // ACCOUNT CURRENCY
    table.cell(
         panel, 0, 2,
         "Account Currency",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 2,
         accountCurrency,
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // ACCOUNT SIZE
    table.cell(
         panel, 0, 3,
         "Account Size",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 3,
         str.tostring(accountSize, "#,##0.##"),
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // RISK RATIO
    table.cell(
         panel, 0, 4,
         "Risk Ratio, %",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 4,
         str.tostring(riskPercent, "#.##"),
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // STOP-LOSS
    table.cell(
         panel, 0, 5,
         "Stop-Loss, pips",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 5,
         str.tostring(stopPips, "#.##"),
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // LOWER HEADING — RESULTS
    table.cell(
         panel, 0, 6,
         "RESULTS",
         bgcolor=lowerHeadingBackground,
         text_color=lowerHeadingText,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    table.cell(
         panel, 1, 6,
         isForex ? pair : "N/A",
         bgcolor=lowerHeadingBackground,
         text_color=lowerHeadingText,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // MONEY — CURRENCY SYMBOL, NO DECIMAL PLACES
    table.cell(
         panel, 0, 7,
         "Money",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 7,
         currencySymbol + str.tostring(math.round(riskMoney), "#,##0"),
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // UNITS — WHOLE NUMBERS
    table.cell(
         panel, 0, 8,
         "Units",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 8,
         valid ? str.tostring(math.round(units), "#,##0") : "N/A",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)

    // SIZING — TWO DECIMAL PLACES, INCLUDING LEADING ZERO
    table.cell(
         panel, 0, 9,
         "Sizing (Lots)",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_left)

    table.cell(
         panel, 1, 9,
         valid ? str.tostring(lots, "0.00") : "N/A",
         bgcolor=backgroundColour,
         text_color=textColour,
         text_size=fontSize,
         text_font_family=fontFamily,
         text_halign=text.align_center)
````

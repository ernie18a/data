# Profit-protected pyramiding calculator 

- url: https://www.tradingview.com/script/cvmitWuc-Profit-protected-pyramiding-calculator/
- type: indicator
- pine_id: PUB;b4e058f91bd04b1f8dafc3e81bd51034
- version: 1.0

## Description

A practical position management tool designed for traders who scale into strength using structured risk management.

This script helps calculate the required additional position size needed to adjust your blended average cost after adding to an existing position.

Unlike emotional averaging or martingale-style position sizing, this tool is intended for traders who:

• Add to positions systematically
• Scale into strength, not weakness
• Manage exposure using trailing stops
• Build positions while maintaining trade structure
• Focus on risk-adjusted execution

## How It Works

The calculator uses:

* Existing position size
* Existing average cost
* Planned add price
* Desired blended average cost

to calculate:

* Required additional quantity
* Estimated additional capital required

## Typical Use Case

Example:

A trader already holds a profitable position and has raised the trailing stop significantly above the original average cost.

Instead of adding randomly, the trader can calculate how much additional exposure can be added while keeping the new blended average at a controlled distance from the protective stop.

This creates a more structured and risk-aware scaling process.

## Important Notes

This tool is a mathematical position-planning utility only.

It does NOT:

* Generate buy or sell signals
* Predict market direction
* Recommend averaging down
* Replace proper risk management

Always use independent analysis and predefined risk controls before making trading decisions.

Designed for educational and execution-planning purposes.

## Source Code

````pine
//@version=6
indicator("Profit-protected pyramiding calculator ", overlay=true)

// Inputs
OldQnt     = input.int(1500, "Existing Position Size # Shares")
OldPrice   = input.float(10, " Existing Average Price")
NewPrice   = input.float(18, "  Planned Add Price ")
TargetAvg  = input.float(12, " Protected Average Target")

// Calculation
var float NewQnt = na

denominator = (TargetAvg - NewPrice)

// حماية من القسمة على صفر
NewQnt := denominator != 0 ? ((OldPrice * OldQnt) - (TargetAvg * OldQnt)) / denominator : na

// تقريب العدد (ماينفعش تشترى 2.7 سهم 😄)
NewQntRounded = math.round(NewQnt)


// إجمالى تكلفة التعزيز
NewCost = NewPrice * NewQntRounded

// Table
var table t = table.new(position.top_right, 2, 7, border_width=2)

if barstate.islast
    table.cell(t, 0, 0, "Pyramiding Calculation", bgcolor=color.gray)
    table.cell(t, 1, 0, "Value", bgcolor=color.gray)

    table.cell(t, 0, 1, " Existing Position Size # Shares")
    table.cell(t, 1, 1, str.tostring(OldQnt))

    table.cell(t, 0, 2, " Existing Average Price")
    table.cell(t, 1, 2, str.tostring(OldPrice))

    table.cell(t, 0, 3, " Planned Add Price")
    table.cell(t, 1, 3, str.tostring(NewPrice))

    table.cell(t, 0, 4, " Protected Average Target ")
    table.cell(t, 1, 4, str.tostring(TargetAvg))

    table.cell(t, 0, 5, "Buy Qnt")
    table.cell(t, 1, 5, str.tostring(NewQntRounded), 
         text_color = NewQntRounded > 0 ? color.green : color.red)
    table.cell(t, 0, 6, " New Cost")
    table.cell(t, 1, 6, str.tostring(NewCost))
````

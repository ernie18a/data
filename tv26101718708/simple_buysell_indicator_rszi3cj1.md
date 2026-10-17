# Simple Buy/Sell Indicator

- url: https://www.tradingview.com/script/RsZi3CJ1-Simple-Buy-Sell-Indicator/
- type: indicator
- pine_id: PUB;b87f491408f4450490cd851017a35cd9
- version: 2.0

## Description

Create you own custom strategies using this 'Simple Buy/Sell Indicator'. It allows other indicators to be combined together into a BUY/SELL strategy, using up to four separate rules.

The output is:
    1 = BUY
    0 = None
   -1 = SELL

This can then be used as an input to my 'Simple Pyramid Strategy' or my (coming soon - watch this space) 'Complex Single Trade Strategy'.

Each rule compares two values with [< > =]:
Value 1) A source value, or change in that value.
Value 2) An actual value, a percentage of the price of the chart asset, or another source input.

'Bars Back' can be specified if you don't want the latest value. So 1 bar back will give the latest confirmed value.
When the first value is a change, this specifies how far back to test the change for. If the change input is from a higher timeframe, make sure to use the correct value for bars back.
e.g. If the chart is 15 min, but the input change is from an indicator on the 4 hour, bars back needs to be 240 / 15 = 16 bars back.

Inverse rules can optionally be created as well. This means that a BUY strategy will automatically create a SELL strategy, or vice versa, with all the same rules inverted.

When a rule is inverted, the second value is often negated. So x > 4 becomes x < -4. This negation is ALWAYS applied when the first value is a change, but optionally for values.

For comparing two levels, like the price with a moving average, you don't want negation. So price > average, becomes price < average.

However, if the first value is an oscillator, like a MACD signal, you most likely will need negation. So x > 60 becomes x < -60.

For oscillators not zero centred, they will also need an offset to work with negation. 
e.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50]
So instead of testing for overbought and oversold with > 70 and < 30, you would offset by -50. Then you would test for > 20 (overbought), which becomes < -20 (oversold) when inverted.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JustinTimeTunes

//@version=6
indicator(title = "Simple Buy/Sell Indicator", shorttitle = "S Buy/Sell")

// Create you own custom strategies using this 'Simple Buy/Sell Indicator'. It allows other indicators to be combined together into a BUY/SELL strategy, using up to four separate rules.
// The output is:
//     1 = BUY
//     0 = None
//    -1 = SELL
// This can then be used as an input to my 'Simple Pyramid Strategy' or my (coming soon - watch this space) 'Complex Single Trade Strategy'.
//
// Each rule compares two values with [< > =]:
// Value 1) A source value, or change in that value.
// Value 2) An actual value, a percentage of the price of the chart asset, or another source input.
//
// 'Bars Back' can be specified if you don't want the latest value. So 1 bar back will give the latest confirmed value.
// When the first value is a change, this specifies how far back to test the change for. If the change input is from a higher timeframe, make sure to use the correct value for bars back.
// e.g. If the chart is 15 min, but the input change is from an indicator on the 4 hour, bars back needs to be 240 / 15 = 16 bars back.
//
// Inverse rules can optionally be created as well. This means that a BUY strategy will automatically create a SELL strategy, or vice versa, with all the same rules inverted.
// When a rule is inverted, the second value is often negated. So x > 4 becomes x < -4. This negation is ALWAYS applied when the first value is a change, but optionally for values.
// For comparing two levels, like the price with a moving average, you don't want negation. So price > average, becomes price < average.
// However, if the first value is an oscillator, like a MACD signal, you most likely will need negation. So x > 60 becomes x < -60.
// For oscillators not zero centred, they will also need an offset to work with negation. e.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50]
// So instead of testing for overbought and oversold with > 70 and < 30, you would offset by -50. Then you would test for > 20 (overbought), which becomes < -20 (oversold) when inverted.

// Update: 10 May 2026 - I've added 'crossover', 'crossunder' and 'cross' to the list of operators or comparisons.
// So now you can get a signal from a source input crossing over a static level, or over another source input.
// You can even test for a change in a source input crossing over. e.g. Crossing over 0, so from negative to positive, a negative change meaning falling, crossing over to a positive change meaning rising, which is a bullish reversal.
// Likewise, crossing under works in the same way, as does cross, which is both directions.
// These crosses also work seamlessly with the rule inversions as well.


// Inputs

// Rule One

bool useRule1Input = input.bool(defval = false, title = "Add Rule One", group = "... Rule One ...", inline = "in1A")

float source1Input  = input.source(defval = close, title = "Source", group = "... Rule One ...", inline = "in1B")

string source1TypeInput = input.string(defval = "Value", title = "", options = ["Value", "Change"], group = "... Rule One ...", inline = "in1B", display = display.none,
    tooltip = "Compare the value of the source input, or else the change in that value.")

int source1BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule One ...", inline = "in1C", display = display.none)

float rule1OffsetInput = input.float(defval = 0, title = "Offset", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule One ...", inline = "in1C", display = display.none,
    tooltip = "Number of bars back to get the value for, or to compare change with. 0 is treated as a minimum of 1 for change.\n\nAn offset can be added if required. This may be useful to zero centre oscilators," +
    " used in conjunction with the second value negation.\n\ne.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50].\n\nIf the first value is a change, the offset is not applied as that is already zero centred.")

string rule1OperatorInput = input.string(defval = "=", title = " ~ - ~ - ~ Compare", options = ["=", ">", "<", "crossover", "crossunder", "cross"], group = "... Rule One ...", inline = "in1D", display = display.none)

float rule1ValueInput = input.float(defval = 0, title = "With", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule One ...", inline = "in1E", display = display.none)

string rule1ValueTypeInput = input.string(defval = "Value", title = "", options = ["Value", "Percent", "Other Source"], group = "... Rule One ...", inline = "in1E", display = display.none,
    tooltip = "Compare with this actual value, or a percentage of the price of the chart asset, or against another source input.")

float rule1OtherSourceInput  = input.source(defval = close, title = "Other Source", group = "... Rule One ...", inline = "in1F", display = display.none)

int otherSource1BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule One ...", inline = "in1F", display = display.none)

bool negate1Input = input.bool(defval = false, title = "Negate second value for inverse rule", group = "... Rule One ...", inline = "in1G", display = display.none,
    tooltip = "For inverse rules, the second value is ALWAYS negated when the first value is a change, but otherwise is only negated if specified here.\n\nThis might be necessary if the first value is an oscillator." +
    " However, if the oscillator isn't zero centred, it will also need an offset above, to work with the negation.")


// Rule Two

bool useRule2Input = input.bool(defval = false, title = "Add Rule Two", group = "... Rule Two ...", inline = "in2A")

float source2Input  = input.source(defval = close, title = "Source", group = "... Rule Two ...", inline = "in2B")

string source2TypeInput = input.string(defval = "Value", title = "", options = ["Value", "Change"], group = "... Rule Two ...", inline = "in2B", display = display.none,
    tooltip = "Compare the value of the source input, or else the change in that value.")

int source2BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Two ...", inline = "in2C", display = display.none)

float rule2OffsetInput = input.float(defval = 0, title = "Offset", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Two ...", inline = "in2C", display = display.none,
    tooltip = "Number of bars back to get the value for, or to compare change with. 0 is treated as a minimum of 1 for change.\n\nAn offset can be added if required. This may be useful to zero centre oscilators," +
    " used in conjunction with the second value negation.\n\ne.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50].\n\nIf the first value is a change, the offset is not applied as that is already zero centred.")

string rule2OperatorInput = input.string(defval = "=", title = " ~ - ~ - ~ Compare", options = ["=", ">", "<", "crossover", "crossunder", "cross"], group = "... Rule Two ...", inline = "in2D", display = display.none)

float rule2ValueInput = input.float(defval = 0, title = "With", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Two ...", inline = "in2E", display = display.none)

string rule2ValueTypeInput = input.string(defval = "Value", title = "", options = ["Value", "Percent", "Other Source"], group = "... Rule Two ...", inline = "in2E", display = display.none,
    tooltip = "Compare with this actual value, or a percentage of the price of the chart asset, or against another source input.")

float rule2OtherSourceInput  = input.source(defval = close, title = "Other Source", group = "... Rule Two ...", inline = "in2F", display = display.none)

int otherSource2BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Two ...", inline = "in2F", display = display.none)

bool negate2Input = input.bool(defval = false, title = "Negate second value for inverse rule", group = "... Rule Two ...", inline = "in2G", display = display.none,
    tooltip = "For inverse rules, the second value is ALWAYS negated when the first value is a change, but otherwise is only negated if specified here.\n\nThis might be necessary if the first value is an oscillator." +
    " However, if the oscillator isn't zero centred, it will also need an offset above, to work with the negation.")


// Rule Three

bool useRule3Input = input.bool(defval = false, title = "Add Rule Three", group = "... Rule Three ...", inline = "in3A")

float source3Input  = input.source(defval = close, title = "Source", group = "... Rule Three ...", inline = "in3B")

string source3TypeInput = input.string(defval = "Value", title = "", options = ["Value", "Change"], group = "... Rule Three ...", inline = "in3B", display = display.none,
    tooltip = "Compare the value of the source input, or else the change in that value.")

int source3BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Three ...", inline = "in3C", display = display.none)

float rule3OffsetInput = input.float(defval = 0, title = "Offset", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Three ...", inline = "in3C", display = display.none,
    tooltip = "Number of bars back to get the value for, or to compare change with. 0 is treated as a minimum of 1 for change.\n\nAn offset can be added if required. This may be useful to zero centre oscilators," +
    " used in conjunction with the second value negation.\n\ne.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50].\n\nIf the first value is a change, the offset is not applied as that is already zero centred.")

string rule3OperatorInput = input.string(defval = "=", title = " ~ - ~ - ~ Compare", options = ["=", ">", "<", "crossover", "crossunder", "cross"], group = "... Rule Three ...", inline = "in3D", display = display.none)

float rule3ValueInput = input.float(defval = 0, title = "With", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Three ...", inline = "in3E", display = display.none)

string rule3ValueTypeInput = input.string(defval = "Value", title = "", options = ["Value", "Percent", "Other Source"], group = "... Rule Three ...", inline = "in3E", display = display.none,
    tooltip = "Compare with this actual value, or a percentage of the price of the chart asset, or against another source input.")

float rule3OtherSourceInput  = input.source(defval = close, title = "Other Source", group = "... Rule Three ...", inline = "in3F", display = display.none)

int otherSource3BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Three ...", inline = "in3F", display = display.none)

bool negate3Input = input.bool(defval = false, title = "Negate second value for inverse rule", group = "... Rule Three ...", inline = "in3G", display = display.none,
    tooltip = "For inverse rules, the second value is ALWAYS negated when the first value is a change, but otherwise is only negated if specified here.\n\nThis might be necessary if the first value is an oscillator." +
    " However, if the oscillator isn't zero centred, it will also need an offset above, to work with the negation.")


// Rule Four

bool useRule4Input = input.bool(defval = false, title = "Add Rule Four", group = "... Rule Four ...", inline = "in4A")

float source4Input  = input.source(defval = close, title = "Source", group = "... Rule Four ...", inline = "in4B")

string source4TypeInput = input.string(defval = "Value", title = "", options = ["Value", "Change"], group = "... Rule Four ...", inline = "in4B", display = display.none,
    tooltip = "Compare the value of the source input, or else the change in that value.")

int source4BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Four ...", inline = "in4C", display = display.none)

float rule4OffsetInput = input.float(defval = 0, title = "Offset", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Four ...", inline = "in4C", display = display.none,
    tooltip = "Number of bars back to get the value for, or to compare change with. 0 is treated as a minimum of 1 for change.\n\nAn offset can be added if required. This may be useful to zero centre oscilators," +
    " used in conjunction with the second value negation.\n\ne.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50].\n\nIf the first value is a change, the offset is not applied as that is already zero centred.")

string rule4OperatorInput = input.string(defval = "=", title = " ~ - ~ - ~ Compare", options = ["=", ">", "<", "crossover", "crossunder", "cross"], group = "... Rule Four ...", inline = "in4D", display = display.none)

float rule4ValueInput = input.float(defval = 0, title = "With", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Four ...", inline = "in4E", display = display.none)

string rule4ValueTypeInput = input.string(defval = "Value", title = "", options = ["Value", "Percent", "Other Source"], group = "... Rule Four ...", inline = "in4E", display = display.none,
    tooltip = "Compare with this actual value, or a percentage of the price of the chart asset, or against another source input.")

float rule4OtherSourceInput  = input.source(defval = close, title = "Other Source", group = "... Rule Four ...", inline = "in4F", display = display.none)

int otherSource4BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Four ...", inline = "in4F", display = display.none)

bool negate4Input = input.bool(defval = false, title = "Negate second value for inverse rule", group = "... Rule Four ...", inline = "in4G", display = display.none,
    tooltip = "For inverse rules, the second value is ALWAYS negated when the first value is a change, but otherwise is only negated if specified here.\n\nThis might be necessary if the first value is an oscillator." +
    " However, if the oscillator isn't zero centred, it will also need an offset above, to work with the negation.")


// Indicator Output

string outputValueInput = input.string(defval = "BUY (1)", title = "Output value if ALL selected rules are met.", options = ["BUY (1)", "SELL (-1)"],
    tooltip = "Output value if ALL the selected rules are true, otherwise the output is None (0).", group = "Indicator Output", display = display.none)

bool invertInput = input.bool(defval = true, title = "Apply inverse rules as well.", group = "Indicator Output", display = display.none,
    tooltip = "This means that a BUY stratgey will automatically create a SELL strategy as well, or vice versa, with all the same rules inverted.")


// Functions

getPercentAsValue(percent) =>
    (percent / 100) * high


getFirstValue(source, sourceType, barsBack, offset) =>
    result = source[barsBack]
    result += offset

    if sourceType == "Change"
        if barsBack > 1
            result := ta.change(source, barsBack)
        else
            result := ta.change(source)

    result


getSecondValue(value, valueType, otherSource, otherBarsBack) =>
    result = value

    if valueType == "Percent"
        result := getPercentAsValue(value)

    else if valueType == "Other Source"
        result := otherSource[otherBarsBack]

    result


resolveRule(firstValue, secondValue, operator) =>
    result = false

    if operator == "="
        result := firstValue == secondValue

    else if operator == ">"
        result := firstValue > secondValue

    else if operator == "<"
        result := firstValue < secondValue

    else if operator == "crossover"
        result := ta.crossover(firstValue, secondValue)

    else if operator == "crossunder"
        result := ta.crossunder(firstValue, secondValue)

    else if operator == "cross"
        result := ta.cross(firstValue, secondValue)

    result


resolveInvertedRule(firstValue, secondValue, operator, negateSecondVal) =>
    thisOp = operator
    thisSecondVal = secondValue

    if operator == ">"
        thisOp := "<"

    else if operator == "<"
        thisOp := ">"

    else if operator == "crossover"
        thisOp := "crossunder"

    else if operator == "crossunder"
        thisOp := "crossover"


    if negateSecondVal
        thisSecondVal *= -1

    resolveRule(firstValue, thisSecondVal, thisOp)


resolveLogic(r1, r2, r3, r4) =>
    r1 and r2 and r3 and r4


// Calculate Output

bool rule1 = true
bool rule2 = true
bool rule3 = true
bool rule4 = true

bool invertedRule1 = true
bool invertedRule2 = true
bool invertedRule3 = true
bool invertedRule4 = true

float firstVal1 = 0
float firstVal2 = 0
float firstVal3 = 0
float firstVal4 = 0

float secondVal1 = 0
float secondVal2 = 0
float secondVal3 = 0
float secondVal4 = 0


if useRule1Input

    firstVal1 := getFirstValue(source1Input, source1TypeInput, source1BarsBackInput, rule1OffsetInput)

    secondVal1 := getSecondValue(rule1ValueInput, rule1ValueTypeInput, rule1OtherSourceInput, otherSource1BarsBackInput)

    rule1 := resolveRule(firstVal1, secondVal1, rule1OperatorInput)


if useRule2Input

    firstVal2 := getFirstValue(source2Input, source2TypeInput, source2BarsBackInput, rule2OffsetInput)

    secondVal2 := getSecondValue(rule2ValueInput, rule2ValueTypeInput, rule2OtherSourceInput, otherSource2BarsBackInput)

    rule2 := resolveRule(firstVal2, secondVal2, rule2OperatorInput)


if useRule3Input

    firstVal3 := getFirstValue(source3Input, source3TypeInput, source3BarsBackInput, rule3OffsetInput)

    secondVal3 := getSecondValue(rule3ValueInput, rule3ValueTypeInput, rule3OtherSourceInput, otherSource3BarsBackInput)

    rule3 := resolveRule(firstVal3, secondVal3, rule3OperatorInput)


if useRule4Input

    firstVal4 := getFirstValue(source4Input, source4TypeInput, source4BarsBackInput, rule4OffsetInput)

    secondVal4 := getSecondValue(rule4ValueInput, rule4ValueTypeInput, rule4OtherSourceInput, otherSource4BarsBackInput)

    rule4 := resolveRule(firstVal4, secondVal4, rule4OperatorInput)



int trueValue = 1

if outputValueInput == "SELL (-1)"
    trueValue := -1


int outputValue = 0

if resolveLogic(rule1, rule2, rule3, rule4)
    outputValue := trueValue


if useRule1Input
    invertedRule1 := resolveInvertedRule(firstVal1, secondVal1, rule1OperatorInput, (source1TypeInput == "Change" or negate1Input))

if useRule2Input
    invertedRule2 := resolveInvertedRule(firstVal2, secondVal2, rule2OperatorInput, (source2TypeInput == "Change" or negate2Input))

if useRule3Input
    invertedRule3 := resolveInvertedRule(firstVal3, secondVal3, rule3OperatorInput, (source3TypeInput == "Change" or negate3Input))

if useRule4Input
    invertedRule4 := resolveInvertedRule(firstVal4, secondVal4, rule4OperatorInput, (source4TypeInput == "Change" or negate4Input))


if invertInput and outputValue == 0

    if resolveLogic(invertedRule1, invertedRule2, invertedRule3, invertedRule4)
        outputValue := trueValue * -1


// Output -> Chart -> Strategy...

outputPlot = plot(series = outputValue, title = "Buy/Sell", linewidth = 2, color = color.white)

hline(price = 0, title = "zero", color = #787B86, linestyle = hline.style_solid)

midLinePlot = plot(series = 0, title = "midline", color = na, editable = false, display = display.none)

fill(outputPlot, midLinePlot, 1,  0,  top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100), title = "BUY")
fill(outputPlot, midLinePlot, 0, -1,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0), title = "SELL")

topLevel = hline(price = 1.1, title = "Background Top", color = #787B86, linestyle = hline.style_solid)
bottomLevel = hline(price = -1.1, title = "Background Bottom", color = #787B86, linestyle = hline.style_solid)
fill(topLevel, bottomLevel, color=color.rgb(26, 7, 94, 90), title="Buy/Sell Background")
````

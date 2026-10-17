# Custom Buy/Sell Indicator

- url: https://www.tradingview.com/script/PZbgI2XG-Custom-Buy-Sell-Indicator/
- type: indicator
- pine_id: PUB;af71c18f78244be590a5849b9fbc3994
- version: 2.0

## Description

Create you own custom strategies using this 'Custom Buy/Sell Indicator'. It allows other indicators to be combined together into a BUY/SELL strategy, using up to seven separate rules.

It is essentially the same as my 'Simple Buy/Sell Indicator', but combines up to seven rules rather than just four, plus the rules can be combined using various different logical expressions.
There are ten different logical expressions which should cover many common usages, however the list is by no means exhaustive. Should you require a different expression, drop me a comment and I'll try to provide an update.

The output is:
    1 = BUY
    0 = None
   -1 = SELL
This can then be used as an input to my 'Simple Pyramid Strategy' or my 'Complex Single Trade Strategy'.

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

For oscillators not zero centred, they will also need an offset to work with negation. e.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50]
So instead of testing for overbought and oversold with > 70 and < 30, you would offset by -50. Then you would test for > 20 (overbought), which becomes < -20 (oversold) when inverted.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JustinTimeTunes

//@version=6
indicator(title = "Custom Buy/Sell Indicator", shorttitle = "C Buy/Sell")


// Create you own custom strategies using this 'Custom Buy/Sell Indicator'. It allows other indicators to be combined together into a BUY/SELL strategy, using up to seven separate rules.
// It is essentially the same as my 'Simple Buy/Sell Indicator', but combines up to seven rules rather than just four, plus the rules can be combined using various different logical expressions.
// There are ten different logical expressions which should cover many common usages, however the list is by no means exhaustive. Should you require a different expression, drop me a comment and I'll try to provide an update.
//
// The output is:
//     1 = BUY
//     0 = None
//    -1 = SELL
// This can then be used as an input to my 'Simple Pyramid Strategy' or my 'Complex Single Trade Strategy'.
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


// Constants

const string LOGIC_1 = "rule1 AND rule2 AND rule3 AND rule4 AND rule5 AND rule6 AND rule7"
const string LOGIC_2 = "( ( rule1 AND rule2 ) OR ( rule3 AND rule4 ) ) AND rule5 AND rule6 AND rule7"
const string LOGIC_3 = "( rule1 AND rule2 AND rule3 ) OR ( rule4 AND rule5 AND rule6 ) AND rule7"
const string LOGIC_4 = "( rule1 OR rule2 ) AND rule3 AND rule4 AND rule5 AND rule6 AND rule7"
const string LOGIC_5 = "( rule1 OR rule2 OR rule3 ) AND rule4 AND rule5 AND rule6 AND rule7"
const string LOGIC_6 = "( rule1 OR rule2 ) AND ( rule3 OR rule4 ) AND rule5 AND rule6 AND rule7"
const string LOGIC_7 = "rule1 OR ( rule2 AND rule3 ) OR ( rule4 AND rule5 ) OR ( rule6 AND rule7 )"
const string LOGIC_8 = "rule1 OR rule2 OR rule3 OR ( rule4 AND rule5 ) OR ( rule6 AND rule7 )"
const string LOGIC_9 = "rule1 OR rule2 OR rule3 OR rule4 OR rule5 OR ( rule6 AND rule7 )"
const string LOGIC_10 = "rule1 OR rule2 OR rule3 OR rule4 OR rule5 OR rule6 OR rule7"


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


// Rule Five

bool useRule5Input = input.bool(defval = false, title = "Add Rule Five", group = "... Rule Five ...", inline = "in5A")

float source5Input  = input.source(defval = close, title = "Source", group = "... Rule Five ...", inline = "in5B")

string source5TypeInput = input.string(defval = "Value", title = "", options = ["Value", "Change"], group = "... Rule Five ...", inline = "in5B", display = display.none,
    tooltip = "Compare the value of the source input, or else the change in that value.")

int source5BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Five ...", inline = "in5C", display = display.none)

float rule5OffsetInput = input.float(defval = 0, title = "Offset", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Five ...", inline = "in5C", display = display.none,
    tooltip = "Number of bars back to get the value for, or to compare change with. 0 is treated as a minimum of 1 for change.\n\nAn offset can be added if required. This may be useful to zero centre oscilators," +
    " used in conjunction with the second value negation.\n\ne.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50].\n\nIf the first value is a change, the offset is not applied as that is already zero centred.")

string rule5OperatorInput = input.string(defval = "=", title = " ~ - ~ - ~ Compare", options = ["=", ">", "<", "crossover", "crossunder", "cross"], group = "... Rule Five ...", inline = "in5D", display = display.none)

float rule5ValueInput = input.float(defval = 0, title = "With", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Five ...", inline = "in5E", display = display.none)

string rule5ValueTypeInput = input.string(defval = "Value", title = "", options = ["Value", "Percent", "Other Source"], group = "... Rule Five ...", inline = "in5E", display = display.none,
    tooltip = "Compare with this actual value, or a percentage of the price of the chart asset, or against another source input.")

float rule5OtherSourceInput  = input.source(defval = close, title = "Other Source", group = "... Rule Five ...", inline = "in5F", display = display.none)

int otherSource5BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Five ...", inline = "in5F", display = display.none)

bool negate5Input = input.bool(defval = false, title = "Negate second value for inverse rule", group = "... Rule Five ...", inline = "in5G", display = display.none,
    tooltip = "For inverse rules, the second value is ALWAYS negated when the first value is a change, but otherwise is only negated if specified here.\n\nThis might be necessary if the first value is an oscillator." +
    " However, if the oscillator isn't zero centred, it will also need an offset above, to work with the negation.")


// Rule Six

bool useRule6Input = input.bool(defval = false, title = "Add Rule Six", group = "... Rule Six ...", inline = "in6A")

float source6Input  = input.source(defval = close, title = "Source", group = "... Rule Six ...", inline = "in6B")

string source6TypeInput = input.string(defval = "Value", title = "", options = ["Value", "Change"], group = "... Rule Six ...", inline = "in6B", display = display.none,
    tooltip = "Compare the value of the source input, or else the change in that value.")

int source6BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Six ...", inline = "in6C", display = display.none)

float rule6OffsetInput = input.float(defval = 0, title = "Offset", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Six ...", inline = "in6C", display = display.none,
    tooltip = "Number of bars back to get the value for, or to compare change with. 0 is treated as a minimum of 1 for change.\n\nAn offset can be added if required. This may be useful to zero centre oscilators," +
    " used in conjunction with the second value negation.\n\ne.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50].\n\nIf the first value is a change, the offset is not applied as that is already zero centred.")

string rule6OperatorInput = input.string(defval = "=", title = " ~ - ~ - ~ Compare", options = ["=", ">", "<", "crossover", "crossunder", "cross"], group = "... Rule Six ...", inline = "in6D", display = display.none)

float rule6ValueInput = input.float(defval = 0, title = "With", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Six ...", inline = "in6E", display = display.none)

string rule6ValueTypeInput = input.string(defval = "Value", title = "", options = ["Value", "Percent", "Other Source"], group = "... Rule Six ...", inline = "in6E", display = display.none,
    tooltip = "Compare with this actual value, or a percentage of the price of the chart asset, or against another source input.")

float rule6OtherSourceInput  = input.source(defval = close, title = "Other Source", group = "... Rule Six ...", inline = "in6F", display = display.none)

int otherSource6BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Six ...", inline = "in6F", display = display.none)

bool negate6Input = input.bool(defval = false, title = "Negate second value for inverse rule", group = "... Rule Six ...", inline = "in6G", display = display.none,
    tooltip = "For inverse rules, the second value is ALWAYS negated when the first value is a change, but otherwise is only negated if specified here.\n\nThis might be necessary if the first value is an oscillator." +
    " However, if the oscillator isn't zero centred, it will also need an offset above, to work with the negation.")


// Rule Seven

bool useRule7Input = input.bool(defval = false, title = "Add Rule Seven", group = "... Rule Seven ...", inline = "in7A")

float source7Input  = input.source(defval = close, title = "Source", group = "... Rule Seven ...", inline = "in7B")

string source7TypeInput = input.string(defval = "Value", title = "", options = ["Value", "Change"], group = "... Rule Seven ...", inline = "in7B", display = display.none,
    tooltip = "Compare the value of the source input, or else the change in that value.")

int source7BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Seven ...", inline = "in7C", display = display.none)

float rule7OffsetInput = input.float(defval = 0, title = "Offset", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Seven ...", inline = "in7C", display = display.none,
    tooltip = "Number of bars back to get the value for, or to compare change with. 0 is treated as a minimum of 1 for change.\n\nAn offset can be added if required. This may be useful to zero centre oscilators," +
    " used in conjunction with the second value negation.\n\ne.g. RSI [0 to 100] can be zero centred with an offset of -50 to make it [-50 to +50].\n\nIf the first value is a change, the offset is not applied as that is already zero centred.")

string rule7OperatorInput = input.string(defval = "=", title = " ~ - ~ - ~ Compare", options = ["=", ">", "<", "crossover", "crossunder", "cross"], group = "... Rule Seven ...", inline = "in7D", display = display.none)

float rule7ValueInput = input.float(defval = 0, title = "With", minval = -1000000, maxval = 1000000, step = 0.00001, group = "... Rule Seven ...", inline = "in7E", display = display.none)

string rule7ValueTypeInput = input.string(defval = "Value", title = "", options = ["Value", "Percent", "Other Source"], group = "... Rule Seven ...", inline = "in7E", display = display.none,
    tooltip = "Compare with this actual value, or a percentage of the price of the chart asset, or against another source input.")

float rule7OtherSourceInput  = input.source(defval = close, title = "Other Source", group = "... Rule Seven ...", inline = "in7F", display = display.none)

int otherSource7BarsBackInput = input.int(defval = 0, title = "Bars Back", minval = 0, maxval = 10000, group = "... Rule Seven ...", inline = "in7F", display = display.none)

bool negate7Input = input.bool(defval = false, title = "Negate second value for inverse rule", group = "... Rule Seven ...", inline = "in7G", display = display.none,
    tooltip = "For inverse rules, the second value is ALWAYS negated when the first value is a change, but otherwise is only negated if specified here.\n\nThis might be necessary if the first value is an oscillator." +
    " However, if the oscillator isn't zero centred, it will also need an offset above, to work with the negation.")


// Indicator Output

string logicInput = input.string(defval = LOGIC_1, title = "Rule Logic", options = [LOGIC_1, LOGIC_2, LOGIC_3, LOGIC_4, LOGIC_5, LOGIC_6, LOGIC_7, LOGIC_8, LOGIC_9, LOGIC_10],
    tooltip = "This is the logic that will be applied to the rules. If logic's not your thing, then most likely you will just need the default setting of all ANDs (first expression), which just means that ALL the rules need to be true to generate a signal." +
    "\n\nAny rules not selected will have a default value of true, unless they are with an OR, then they default to false.", group = "Strategy", display = display.none)

string outputValueInput = input.string(defval = "BUY (1)", title = "Output value if ALL selected rules are met.", options = ["BUY (1)", "SELL (-1)"],
    tooltip = "Output value if ALL the selected rules satisfy the logical expression above, otherwise the output is None (0).", group = "Indicator Output", display = display.none)

bool invertInput = input.bool(defval = true, title = "Apply inverse rules as well.",
    tooltip = "This means that a BUY stratgey will automatically create a SELL strategy as well, or vice versa, with all the same rules inverted.", group = "Indicator Output", display = display.none)


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


resolveLogic(r1, r2, r3, r4, r5, r6, r7, logicExp) =>

    bool result = switch logicExp
        LOGIC_1 => r1 and r2 and r3 and r4 and r5 and r6 and r7
        LOGIC_2 => ((r1 and r2) or (r3 and r4)) and r5 and r6 and r7
        LOGIC_3 => (r1 and r2 and r3) or (r4 and r5 and r6) and r7
        LOGIC_4 => (r1 or r2) and r3 and r4 and r5 and r6 and r7
        LOGIC_5 => (r1 or r2 or r3) and r4 and r5 and r6 and r7
        LOGIC_6 => (r1 or r2) and (r3 or r4) and r5 and r6 and r7
        LOGIC_7 => r1 or (r2 and r3) or (r4 and r5) or (r6 and r7)
        LOGIC_8 => r1 or r2 or r3 or (r4 and r5) or (r6 and r7)
        LOGIC_9 => r1 or r2 or r3 or r4 or r5 or (r6 and r7)
        LOGIC_10 => r1 or r2 or r3 or r4 or r5 or r6 or r7
        => false

    result


// Calculate Output

bool rule1 = true
bool rule2 = true
bool rule3 = true
bool rule4 = true
bool rule5 = true
bool rule6 = true
bool rule7 = true

bool invertedRule1 = true
bool invertedRule2 = true
bool invertedRule3 = true
bool invertedRule4 = true
bool invertedRule5 = true
bool invertedRule6 = true
bool invertedRule7 = true

float firstVal1 = 0
float firstVal2 = 0
float firstVal3 = 0
float firstVal4 = 0
float firstVal5 = 0
float firstVal6 = 0
float firstVal7 = 0

float secondVal1 = 0
float secondVal2 = 0
float secondVal3 = 0
float secondVal4 = 0
float secondVal5 = 0
float secondVal6 = 0
float secondVal7 = 0


if logicInput == LOGIC_4

    rule1 := false
    rule2 := false
    invertedRule1 := false
    invertedRule2 := false

else if logicInput == LOGIC_5

    rule1 := false
    rule2 := false
    rule3 := false

    invertedRule1 := false
    invertedRule2 := false
    invertedRule3 := false

else if logicInput == LOGIC_6 or logicInput == LOGIC_2

    rule1 := false
    rule2 := false
    rule3 := false
    rule4 := false

    invertedRule1 := false
    invertedRule2 := false
    invertedRule3 := false
    invertedRule4 := false

else if logicInput == LOGIC_3

    rule1 := false
    rule2 := false
    rule3 := false
    rule4 := false
    rule5 := false
    rule6 := false

    invertedRule1 := false
    invertedRule2 := false
    invertedRule3 := false
    invertedRule4 := false
    invertedRule5 := false
    invertedRule6 := false

else if logicInput == LOGIC_7 or logicInput == LOGIC_8 or logicInput == LOGIC_9 or logicInput == LOGIC_10

    rule1 := false
    rule2 := false
    rule3 := false
    rule4 := false
    rule5 := false
    rule6 := false
    rule7 := false

    invertedRule1 := false
    invertedRule2 := false
    invertedRule3 := false
    invertedRule4 := false
    invertedRule5 := false
    invertedRule6 := false
    invertedRule7 := false


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


if useRule5Input

    firstVal5 := getFirstValue(source5Input, source5TypeInput, source5BarsBackInput, rule5OffsetInput)

    secondVal5 := getSecondValue(rule5ValueInput, rule5ValueTypeInput, rule5OtherSourceInput, otherSource5BarsBackInput)

    rule5 := resolveRule(firstVal5, secondVal5, rule5OperatorInput)


if useRule6Input

    firstVal6 := getFirstValue(source6Input, source6TypeInput, source6BarsBackInput, rule6OffsetInput)

    secondVal6 := getSecondValue(rule6ValueInput, rule6ValueTypeInput, rule6OtherSourceInput, otherSource6BarsBackInput)

    rule6 := resolveRule(firstVal6, secondVal6, rule6OperatorInput)


if useRule7Input

    firstVal7 := getFirstValue(source7Input, source7TypeInput, source7BarsBackInput, rule7OffsetInput)

    secondVal7 := getSecondValue(rule7ValueInput, rule7ValueTypeInput, rule7OtherSourceInput, otherSource7BarsBackInput)

    rule7 := resolveRule(firstVal7, secondVal7, rule7OperatorInput)


int trueValue = 1

if outputValueInput == "SELL (-1)"
    trueValue := -1


int outputValue = 0

if resolveLogic(rule1, rule2, rule3, rule4, rule5, rule6, rule7, logicInput)
    outputValue := trueValue


if useRule1Input
    invertedRule1 := resolveInvertedRule(firstVal1, secondVal1, rule1OperatorInput, (source1TypeInput == "Change" or negate1Input))

if useRule2Input
    invertedRule2 := resolveInvertedRule(firstVal2, secondVal2, rule2OperatorInput, (source2TypeInput == "Change" or negate2Input))

if useRule3Input
    invertedRule3 := resolveInvertedRule(firstVal3, secondVal3, rule3OperatorInput, (source3TypeInput == "Change" or negate3Input))

if useRule4Input
    invertedRule4 := resolveInvertedRule(firstVal4, secondVal4, rule4OperatorInput, (source4TypeInput == "Change" or negate4Input))

if useRule5Input
    invertedRule5 := resolveInvertedRule(firstVal5, secondVal5, rule5OperatorInput, (source5TypeInput == "Change" or negate5Input))

if useRule6Input
    invertedRule6 := resolveInvertedRule(firstVal6, secondVal6, rule6OperatorInput, (source6TypeInput == "Change" or negate6Input))

if useRule7Input
    invertedRule7 := resolveInvertedRule(firstVal7, secondVal7, rule7OperatorInput, (source7TypeInput == "Change" or negate7Input))


if invertInput and outputValue == 0

    if resolveLogic(invertedRule1, invertedRule2, invertedRule3, invertedRule4, invertedRule5, invertedRule6, invertedRule7, logicInput)
        outputValue := trueValue * -1


// Output -> Chart -> Strategy...

outputPlot = plot(series = outputValue, title = "Buy/Sell", linewidth = 2, color = color.white)

hline(price = 0, title = "zero", color = #787B86, linestyle = hline.style_solid)

midLinePlot = plot(series = 0, title = "midline", color = na, editable = false, display = display.none)

fill(outputPlot, midLinePlot, 1,  0,  top_color = color.new(color.green, 0), bottom_color = color.new(color.green, 100), title = "BUY")
fill(outputPlot, midLinePlot, 0, -1,  top_color = color.new(color.red, 100), bottom_color = color.new(color.red, 0), title = "SELL")

topLevel = hline(price = 1.1, title = "Background Top", color = #787B86, linestyle = hline.style_solid)
bottomLevel = hline(price = -1.1, title = "Background Bottom", color = #787B86, linestyle = hline.style_solid)
fill(topLevel, bottomLevel, color = color.rgb(26, 7, 94, 90), title = "Buy/Sell Background")
````

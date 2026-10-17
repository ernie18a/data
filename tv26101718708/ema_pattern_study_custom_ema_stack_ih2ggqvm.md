# EMA Pattern Study - Custom EMA Stack

- url: https://www.tradingview.com/script/iH2GgQVm-EMA-Pattern-Study-Custom-EMA-Stack/
- type: indicator
- pine_id: PUB;ee6530b74acb4e00880d9369787977d4
- version: 1.0

## Description

This indicator was built to study EMA structure, trend alignment, and pullback behavior with a cleaner visual read.

Instead of showing every moving average at full strength all the time, the script uses a hierarchy-based visibility model. When a faster EMA drops below the EMA beneath it, that line can either fade or disappear entirely. This makes it easier to see which EMA is actually controlling price during pullbacks, continuation phases, and potential trend transitions.

Core Features:

5 fully customizable EMAs
Default stack: 12 / 26 / 50 / 100 / 200
Custom EMA source selection:
Open, High, Low, Close, HL2, HLC3, OHLC4, OC2, OHC3, OLC3
Adjustable colors and line widths
Visibility modes:
Always Show
Hide When Under Next EMA
Fade When Under Next EMA
Golden Cross / Death Cross markers using EMA 3 vs EMA 5
Optional background highlight on major cross events
Alerts for Golden Cross and Death Cross conditions

How I Use It:

This tool is not meant to predict price.

It is meant to make EMA behavior easier to study.

When the faster EMAs are stacked cleanly above the slower EMAs, trend structure is organized and participants are still accepting higher prices. When the faster EMAs begin rolling underneath the next EMA in the stack, the fade logic helps visually show that momentum is weakening or transitioning into a deeper pullback.

The real value is in studying how price behaves around the visible support averages.

Clean continuation often shows price pulling into a key EMA while the higher structure remains intact. The faster EMAs may curl over, but price continues to hug the supporting average cleanly instead of breaking down through the entire stack.

That behavior is very different from a messy trend failure where EMAs tangle, price loses acceptance, and structure becomes noisy.

This indicator helps separate:

Organized trend continuation
Controlled pullbacks
EMA compression
Trend transition
Full structure failure

Best Use Cases:

Studying continuation setups
Identifying clean pullback behavior
Spotting EMA compression before expansion
Watching trend alignment across different EMA stacks
Cleaning up charts when too many averages overlap
Reviewing historical examples of trend strength vs trend failure

Important Note:

This is not a signal tool.
The cross markers are included for reference, but the main purpose is structural study.

The focus is not “EMA crossed, take a trade.”

The focus is:

What is price doing relative to the EMA stack?
Which average is controlling the pullback?
Are participants accepting higher prices or rejecting the move?
Is the structure organized, compressing, or failing?

Process > Prediction.
Structure > Signals.
Execution > Indicators.

## Source Code

````pine
//@version=6
indicator("EMA Pattern Study - Custom EMA Stack", overlay=true, max_labels_count=500)

// =====================================================================
// INPUTS
// =====================================================================
groupEMA = "EMA Settings"

emaSourceChoice = input.string(
     "Close",
     "EMA Source",
     options=[
         "Open",
         "High",
         "Low",
         "Close",
         "HL2",
         "HLC3",
         "OHLC4",
         "OC2",
         "OHC3",
         "OLC3"
     ],
     group=groupEMA
)

// =====================================================================
// EMA 1
// =====================================================================
groupEMA1 = "EMA 1"
showEMA1   = input.bool(true, "Show EMA 1", group=groupEMA1)
lengthEMA1 = input.int(12, "EMA 1 Length", minval=1, group=groupEMA1)
colorEMA1  = input.color(color.red, "EMA 1 Color", group=groupEMA1)
widthEMA1  = input.int(2, "EMA 1 Width", minval=1, maxval=5, group=groupEMA1)

// =====================================================================
// EMA 2
// =====================================================================
groupEMA2 = "EMA 2"
showEMA2   = input.bool(true, "Show EMA 2", group=groupEMA2)
lengthEMA2 = input.int(26, "EMA 2 Length", minval=1, group=groupEMA2)
colorEMA2  = input.color(color.yellow, "EMA 2 Color", group=groupEMA2)
widthEMA2  = input.int(2, "EMA 2 Width", minval=1, maxval=5, group=groupEMA2)

// =====================================================================
// EMA 3
// =====================================================================
groupEMA3 = "EMA 3"
showEMA3   = input.bool(true, "Show EMA 3", group=groupEMA3)
lengthEMA3 = input.int(50, "EMA 3 Length", minval=1, group=groupEMA3)
colorEMA3  = input.color(color.purple, "EMA 3 Color", group=groupEMA3)
widthEMA3  = input.int(2, "EMA 3 Width", minval=1, maxval=5, group=groupEMA3)

// =====================================================================
// EMA 4
// =====================================================================
groupEMA4 = "EMA 4"
showEMA4   = input.bool(true, "Show EMA 4", group=groupEMA4)
lengthEMA4 = input.int(100, "EMA 4 Length", minval=1, group=groupEMA4)
colorEMA4  = input.color(color.green, "EMA 4 Color", group=groupEMA4)
widthEMA4  = input.int(2, "EMA 4 Width", minval=1, maxval=5, group=groupEMA4)

// =====================================================================
// EMA 5
// =====================================================================
groupEMA5 = "EMA 5"
showEMA5   = input.bool(true, "Show EMA 5", group=groupEMA5)
lengthEMA5 = input.int(200, "EMA 5 Length", minval=1, group=groupEMA5)
colorEMA5  = input.color(color.blue, "EMA 5 Color", group=groupEMA5)
widthEMA5  = input.int(2, "EMA 5 Width", minval=1, maxval=5, group=groupEMA5)

// =====================================================================
// VISIBILITY LOGIC SETTINGS
// =====================================================================
groupVisibility = "EMA Visibility Logic"

visibilityMode = input.string(
     "Fade When Under Next EMA",
     "Visibility Mode",
     options=[
         "Always Show",
         "Hide When Under Next EMA",
         "Fade When Under Next EMA"
     ],
     group=groupVisibility
)

fadeTransparency = input.int(
     85,
     "Fade Transparency",
     minval=0,
     maxval=100,
     group=groupVisibility
)

// =====================================================================
// SIGNAL SETTINGS
// =====================================================================
groupSignals = "Pattern Signals"

showGoldenCross = input.bool(true, "Show Golden Cross EMA 3/EMA 5", group=groupSignals)
showDeathCross  = input.bool(true, "Show Death Cross EMA 3/EMA 5", group=groupSignals)
showBgHighlight = input.bool(true, "Highlight Cross Background", group=groupSignals)

// =====================================================================
// SOURCE SELECTION
// =====================================================================
emaSource =
     emaSourceChoice == "Open"  ? open :
     emaSourceChoice == "High"  ? high :
     emaSourceChoice == "Low"   ? low :
     emaSourceChoice == "Close" ? close :
     emaSourceChoice == "HL2"   ? hl2 :
     emaSourceChoice == "HLC3"  ? hlc3 :
     emaSourceChoice == "OHLC4" ? ohlc4 :
     emaSourceChoice == "OC2"   ? (open + close) / 2 :
     emaSourceChoice == "OHC3"  ? (open + high + close) / 3 :
     emaSourceChoice == "OLC3"  ? (open + low + close) / 3 :
     close

// =====================================================================
// EMA CALCULATIONS
// =====================================================================
ema1 = ta.ema(emaSource, lengthEMA1)
ema2 = ta.ema(emaSource, lengthEMA2)
ema3 = ta.ema(emaSource, lengthEMA3)
ema4 = ta.ema(emaSource, lengthEMA4)
ema5 = ta.ema(emaSource, lengthEMA5)

// =====================================================================
// EMA HIERARCHY CONDITIONS
// =====================================================================
// EMA 1 fades/hides when below EMA 2.
// EMA 2 fades/hides when below EMA 3.
// EMA 3 fades/hides when below EMA 4.
// EMA 4 fades/hides when below EMA 5.
// EMA 5 always remains visible.

ema1AboveEMA2 = ema1 > ema2
ema2AboveEMA3 = ema2 > ema3
ema3AboveEMA4 = ema3 > ema4
ema4AboveEMA5 = ema4 > ema5

fadeMode       = visibilityMode == "Fade When Under Next EMA"
hideMode       = visibilityMode == "Hide When Under Next EMA"
alwaysShowMode = visibilityMode == "Always Show"

// =====================================================================
// PLOT VALUE LOGIC
// =====================================================================
plotEMA1 =
     alwaysShowMode or fadeMode ? ema1 :
     ema1AboveEMA2 ? ema1 :
     na

plotEMA2 =
     alwaysShowMode or fadeMode ? ema2 :
     ema2AboveEMA3 ? ema2 :
     na

plotEMA3 =
     alwaysShowMode or fadeMode ? ema3 :
     ema3AboveEMA4 ? ema3 :
     na

plotEMA4 =
     alwaysShowMode or fadeMode ? ema4 :
     ema4AboveEMA5 ? ema4 :
     na

plotEMA5 = ema5

// =====================================================================
// COLOR LOGIC
// =====================================================================
finalColorEMA1 =
     fadeMode and not ema1AboveEMA2 ? color.new(colorEMA1, fadeTransparency) :
     color.new(colorEMA1, 0)

finalColorEMA2 =
     fadeMode and not ema2AboveEMA3 ? color.new(colorEMA2, fadeTransparency) :
     color.new(colorEMA2, 0)

finalColorEMA3 =
     fadeMode and not ema3AboveEMA4 ? color.new(colorEMA3, fadeTransparency) :
     color.new(colorEMA3, 0)

finalColorEMA4 =
     fadeMode and not ema4AboveEMA5 ? color.new(colorEMA4, fadeTransparency) :
     color.new(colorEMA4, 0)

finalColorEMA5 = color.new(colorEMA5, 0)

// =====================================================================
// EMA PLOTS
// =====================================================================
plot(showEMA1 ? plotEMA1 : na, title="EMA 1", color=finalColorEMA1, linewidth=widthEMA1)
plot(showEMA2 ? plotEMA2 : na, title="EMA 2", color=finalColorEMA2, linewidth=widthEMA2)
plot(showEMA3 ? plotEMA3 : na, title="EMA 3", color=finalColorEMA3, linewidth=widthEMA3)
plot(showEMA4 ? plotEMA4 : na, title="EMA 4", color=finalColorEMA4, linewidth=widthEMA4)
plot(showEMA5 ? plotEMA5 : na, title="EMA 5", color=finalColorEMA5, linewidth=widthEMA5)

// =====================================================================
// GOLDEN CROSS / DEATH CROSS LOGIC
// =====================================================================
// Uses EMA 3 vs EMA 5 by default.
// With your default settings, this is 50 EMA vs 200 EMA.

goldenCross = ta.crossover(ema3, ema5)
deathCross  = ta.crossunder(ema3, ema5)

// =====================================================================
// SIGNAL MARKERS
// =====================================================================
plotshape(
     showGoldenCross and goldenCross,
     title="Golden Cross",
     style=shape.labelup,
     text="Golden\nCross",
     location=location.belowbar,
     color=color.new(color.green, 0),
     textcolor=color.white,
     size=size.small
)

plotshape(
     showDeathCross and deathCross,
     title="Death Cross",
     style=shape.labeldown,
     text="Death\nCross",
     location=location.abovebar,
     color=color.new(color.red, 0),
     textcolor=color.white,
     size=size.small
)

// =====================================================================
// BACKGROUND HIGHLIGHT
// =====================================================================
bgcolor(showBgHighlight and goldenCross ? color.new(color.green, 85) : na)
bgcolor(showBgHighlight and deathCross  ? color.new(color.red, 85)   : na)

// =====================================================================
// ALERTS
// =====================================================================
alertcondition(goldenCross, title="Golden Cross", message="Golden Cross: EMA 3 crossed above EMA 5")
alertcondition(deathCross, title="Death Cross", message="Death Cross: EMA 3 crossed below EMA 5")
````

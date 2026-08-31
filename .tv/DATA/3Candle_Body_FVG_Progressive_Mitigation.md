<!-- tradingview-pine-id: PUB;f16ffc1b641843d9bc5130aa4d302b15 -->
<!-- tradingviewscripts-format: 1 -->
# 3-Candle Body FVG — Progressive Mitigation

Source: https://www.tradingview.com/script/6Siq2hnJ-THE-BREAKER/

## Description

3 candle pattern that works great from liquidity. ict concepts.

---

## Source Code

````pine
//@version=6
indicator(
     "3-Candle Body FVG — Progressive Mitigation",
     overlay=true,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500
)

//--------------------------------------------------
// Display settings
//--------------------------------------------------
showBullish = input.bool(
     true,
     "Show Bullish Boxes",
     group="Display"
)

showBearish = input.bool(
     true,
     "Show Bearish Boxes",
     group="Display"
)

showMidline = input.bool(
     true,
     "Show 50% EQ Line",
     group="Display"
)

showPriceLabel = input.bool(
     false,
     "Show 50% Price Label",
     group="Display"
)

//--------------------------------------------------
// Box appearance
//--------------------------------------------------
bullColor = input.color(
     color.lime,
     "Bullish Box Color",
     group="Box Appearance"
)

bearColor = input.color(
     color.red,
     "Bearish Box Color",
     group="Box Appearance"
)

boxTransparency = input.int(
     82,
     "Box Transparency",
     minval=0,
     maxval=100,
     group="Box Appearance"
)

//--------------------------------------------------
// 50% EQ appearance
//--------------------------------------------------
eqLineColor = input.color(
     color.white,
     "50% EQ Line Color",
     group="50% EQ Appearance"
)

eqLineWidth = input.int(
     1,
     "50% EQ Line Width",
     minval=1,
     maxval=4,
     group="50% EQ Appearance"
)

eqLineStyleInput = input.string(
     "Dotted",
     "50% EQ Line Style",
     options=["Dotted", "Dashed", "Solid"],
     group="50% EQ Appearance"
)

eqLineStyle =
     eqLineStyleInput == "Dotted" ? line.style_dotted :
     eqLineStyleInput == "Dashed" ? line.style_dashed :
     line.style_solid

//--------------------------------------------------
// Mitigation settings
//--------------------------------------------------
mitigationType = input.string(
     "Progressive Body Fill",
     "Mitigation Method",
     options=[
          "First Wick Touch",
          "Full Wick Fill",
          "Progressive Body Fill"
     ],
     group="Mitigation"
)

keepMitigatedBoxes = input.bool(
     true,
     "Keep Boxes After Full Mitigation",
     group="Mitigation"
)

dynamicEq = input.bool(
     true,
     "Move 50% Line as Box Shrinks",
     group="Mitigation"
)

//--------------------------------------------------
// Alert settings
//--------------------------------------------------
enableBoxFormedAlerts = input.bool(
     true,
     "Enable Box-Formation Alerts",
     group="Alerts"
)

enableEqTouchAlerts = input.bool(
     true,
     "Enable First 50% EQ-Touch Alerts",
     group="Alerts"
)

//--------------------------------------------------
// Bullish object storage
//--------------------------------------------------
var bullBoxes       = array.new_box()
var bullLines       = array.new_line()
var bullLabels      = array.new_label()
var bullCreatedBars = array.new_int()
var bullEqTouched   = array.new_bool()
var bullOriginalEq  = array.new_float()

//--------------------------------------------------
// Bearish object storage
//--------------------------------------------------
var bearBoxes       = array.new_box()
var bearLines       = array.new_line()
var bearLabels      = array.new_label()
var bearCreatedBars = array.new_int()
var bearEqTouched   = array.new_bool()
var bearOriginalEq  = array.new_float()

//--------------------------------------------------
// Candle definitions
//
// Candle 1 = [2]
// Candle 2 = [1]
// Candle 3 = current candle
//--------------------------------------------------
candle1BodyTop =
     math.max(open[2], close[2])

candle1BodyBottom =
     math.min(open[2], close[2])

candle3BodyTop =
     math.max(open, close)

candle3BodyBottom =
     math.min(open, close)

// Current candle body boundaries
currentBodyTop =
     math.max(open, close)

currentBodyBottom =
     math.min(open, close)

//--------------------------------------------------
// Pattern detection
//--------------------------------------------------

// Bullish body-only gap
bullishBodyGap =
     candle3BodyBottom > candle1BodyTop

// Reject a normal wick-to-wick bullish FVG
noBullishWickFVG =
     low <= high[2]

bullishPattern =
     bar_index >= 2 and
     bullishBodyGap and
     noBullishWickFVG and
     barstate.isconfirmed

// Bearish body-only gap
bearishBodyGap =
     candle3BodyTop < candle1BodyBottom

// Reject a normal wick-to-wick bearish FVG
noBearishWickFVG =
     high >= low[2]

bearishPattern =
     bar_index >= 2 and
     bearishBodyGap and
     noBearishWickFVG and
     barstate.isconfirmed

//--------------------------------------------------
// Alert-event variables
//--------------------------------------------------
bool bullishEqTouchEvent = false
bool bearishEqTouchEvent = false

//--------------------------------------------------
// Create bullish box
//--------------------------------------------------
if showBullish and bullishPattern
    float bullTop =
         candle3BodyBottom

    float bullBottom =
         candle1BodyTop

    float bullEq =
         (bullTop + bullBottom) / 2.0

    box newBullBox = box.new(
         left=bar_index - 1,
         top=bullTop,
         right=bar_index,
         bottom=bullBottom,
         border_color=bullColor,
         border_width=1,
         bgcolor=color.new(
              bullColor,
              boxTransparency
         ),
         extend=extend.right
    )

    line newBullLine = na

    if showMidline
        newBullLine := line.new(
             x1=bar_index - 1,
             y1=bullEq,
             x2=bar_index,
             y2=bullEq,
             extend=extend.right,
             color=eqLineColor,
             style=eqLineStyle,
             width=eqLineWidth
        )

    label newBullLabel = na

    if showPriceLabel
        newBullLabel := label.new(
             x=bar_index,
             y=bullEq,
             text="50%: " +
                  str.tostring(
                       bullEq,
                       format.mintick
                  ),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=color.new(bullColor, 15),
             textcolor=color.white,
             size=size.small
        )

    array.push(bullBoxes, newBullBox)
    array.push(bullLines, newBullLine)
    array.push(bullLabels, newBullLabel)
    array.push(bullCreatedBars, bar_index)
    array.push(bullEqTouched, false)
    array.push(bullOriginalEq, bullEq)

//--------------------------------------------------
// Create bearish box
//--------------------------------------------------
if showBearish and bearishPattern
    float bearTop =
         candle1BodyBottom

    float bearBottom =
         candle3BodyTop

    float bearEq =
         (bearTop + bearBottom) / 2.0

    box newBearBox = box.new(
         left=bar_index - 1,
         top=bearTop,
         right=bar_index,
         bottom=bearBottom,
         border_color=bearColor,
         border_width=1,
         bgcolor=color.new(
              bearColor,
              boxTransparency
         ),
         extend=extend.right
    )

    line newBearLine = na

    if showMidline
        newBearLine := line.new(
             x1=bar_index - 1,
             y1=bearEq,
             x2=bar_index,
             y2=bearEq,
             extend=extend.right,
             color=eqLineColor,
             style=eqLineStyle,
             width=eqLineWidth
        )

    label newBearLabel = na

    if showPriceLabel
        newBearLabel := label.new(
             x=bar_index,
             y=bearEq,
             text="50%: " +
                  str.tostring(
                       bearEq,
                       format.mintick
                  ),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=color.new(bearColor, 15),
             textcolor=color.white,
             size=size.small
        )

    array.push(bearBoxes, newBearBox)
    array.push(bearLines, newBearLine)
    array.push(bearLabels, newBearLabel)
    array.push(bearCreatedBars, bar_index)
    array.push(bearEqTouched, false)
    array.push(bearOriginalEq, bearEq)

//--------------------------------------------------
// Manage bullish boxes
//--------------------------------------------------
int bullIndex =
     array.size(bullBoxes) - 1

while bullIndex >= 0
    box currentBox =
         array.get(bullBoxes, bullIndex)

    line currentLine =
         array.get(bullLines, bullIndex)

    label currentLabel =
         array.get(bullLabels, bullIndex)

    int createdBar =
         array.get(bullCreatedBars, bullIndex)

    bool eqAlreadyTouched =
         array.get(bullEqTouched, bullIndex)

    float originalEq =
         array.get(bullOriginalEq, bullIndex)

    float boxTop =
         box.get_top(currentBox)

    float boxBottom =
         box.get_bottom(currentBox)

    bool bullFullyMitigated = false

    //--------------------------------------------------
    // Progressive bullish body mitigation
    //
    // Wicks are ignored.
    // The body trims the box downward from its top.
    //--------------------------------------------------
    if (
         bar_index > createdBar and
         mitigationType == "Progressive Body Fill"
    )
        bool bodyEnteredBox =
             currentBodyBottom < boxTop and
             currentBodyTop > boxBottom

        if bodyEnteredBox
            float newTop =
                 math.max(
                      boxBottom,
                      currentBodyBottom
                 )

            if newTop <= boxBottom
                bullFullyMitigated := true
            else
                box.set_top(
                     currentBox,
                     newTop
                )

                boxTop := newTop

    //--------------------------------------------------
    // Other bullish mitigation methods
    //--------------------------------------------------
    if (
         bar_index > createdBar and
         mitigationType == "First Wick Touch" and
         low <= boxTop
    )
        bullFullyMitigated := true

    if (
         bar_index > createdBar and
         mitigationType == "Full Wick Fill" and
         low <= boxBottom
    )
        bullFullyMitigated := true

    //--------------------------------------------------
    // Bullish EQ level
    //--------------------------------------------------
    float bullCurrentEq =
         dynamicEq ?
         (boxTop + boxBottom) / 2.0 :
         originalEq

    if not na(currentLine)
        line.set_y1(
             currentLine,
             bullCurrentEq
        )

        line.set_y2(
             currentLine,
             bullCurrentEq
        )

    if not na(currentLabel)
        label.set_x(
             currentLabel,
             bar_index
        )

        label.set_y(
             currentLabel,
             bullCurrentEq
        )

        label.set_text(
             currentLabel,
             "50%: " +
             str.tostring(
                  bullCurrentEq,
                  format.mintick
             )
        )

    //--------------------------------------------------
    // Bullish 50% touch alert
    //--------------------------------------------------
    bool eqTouchedNow =
         bar_index > createdBar and
         low <= bullCurrentEq and
         high >= bullCurrentEq

    if eqTouchedNow and not eqAlreadyTouched
        array.set(
             bullEqTouched,
             bullIndex,
             true
        )

        bullishEqTouchEvent := true

    //--------------------------------------------------
    // Finish bullish mitigation
    //--------------------------------------------------
    if bullFullyMitigated
        box.set_extend(
             currentBox,
             extend.none
        )

        box.set_right(
             currentBox,
             bar_index
        )

        if not na(currentLine)
            line.set_extend(
                 currentLine,
                 extend.none
            )

            line.set_x2(
                 currentLine,
                 bar_index
            )

        if not na(currentLabel)
            label.set_x(
                 currentLabel,
                 bar_index
            )

        if not keepMitigatedBoxes
            box.delete(currentBox)

            if not na(currentLine)
                line.delete(currentLine)

            if not na(currentLabel)
                label.delete(currentLabel)

        array.remove(
             bullBoxes,
             bullIndex
        )

        array.remove(
             bullLines,
             bullIndex
        )

        array.remove(
             bullLabels,
             bullIndex
        )

        array.remove(
             bullCreatedBars,
             bullIndex
        )

        array.remove(
             bullEqTouched,
             bullIndex
        )

        array.remove(
             bullOriginalEq,
             bullIndex
        )

    bullIndex -= 1

//--------------------------------------------------
// Manage bearish boxes
//--------------------------------------------------
int bearIndex =
     array.size(bearBoxes) - 1

while bearIndex >= 0
    box currentBox =
         array.get(bearBoxes, bearIndex)

    line currentLine =
         array.get(bearLines, bearIndex)

    label currentLabel =
         array.get(bearLabels, bearIndex)

    int createdBar =
         array.get(bearCreatedBars, bearIndex)

    bool eqAlreadyTouched =
         array.get(bearEqTouched, bearIndex)

    float originalEq =
         array.get(bearOriginalEq, bearIndex)

    float boxTop =
         box.get_top(currentBox)

    float boxBottom =
         box.get_bottom(currentBox)

    bool bearFullyMitigated = false

    //--------------------------------------------------
    // Progressive bearish body mitigation
    //
    // Wicks are ignored.
    // The body trims the box upward from its bottom.
    //--------------------------------------------------
    if (
         bar_index > createdBar and
         mitigationType == "Progressive Body Fill"
    )
        bool bodyEnteredBox =
             currentBodyTop > boxBottom and
             currentBodyBottom < boxTop

        if bodyEnteredBox
            float newBottom =
                 math.min(
                      boxTop,
                      currentBodyTop
                 )

            if newBottom >= boxTop
                bearFullyMitigated := true
            else
                box.set_bottom(
                     currentBox,
                     newBottom
                )

                boxBottom := newBottom

    //--------------------------------------------------
    // Other bearish mitigation methods
    //--------------------------------------------------
    if (
         bar_index > createdBar and
         mitigationType == "First Wick Touch" and
         high >= boxBottom
    )
        bearFullyMitigated := true

    if (
         bar_index > createdBar and
         mitigationType == "Full Wick Fill" and
         high >= boxTop
    )
        bearFullyMitigated := true

    //--------------------------------------------------
    // Bearish EQ level
    //--------------------------------------------------
    float bearCurrentEq =
         dynamicEq ?
         (boxTop + boxBottom) / 2.0 :
         originalEq

    if not na(currentLine)
        line.set_y1(
             currentLine,
             bearCurrentEq
        )

        line.set_y2(
             currentLine,
             bearCurrentEq
        )

    if not na(currentLabel)
        label.set_x(
             currentLabel,
             bar_index
        )

        label.set_y(
             currentLabel,
             bearCurrentEq
        )

        label.set_text(
             currentLabel,
             "50%: " +
             str.tostring(
                  bearCurrentEq,
                  format.mintick
             )
        )

    //--------------------------------------------------
    // Bearish 50% touch alert
    //--------------------------------------------------
    bool eqTouchedNow =
         bar_index > createdBar and
         low <= bearCurrentEq and
         high >= bearCurrentEq

    if eqTouchedNow and not eqAlreadyTouched
        array.set(
             bearEqTouched,
             bearIndex,
             true
        )

        bearishEqTouchEvent := true

    //--------------------------------------------------
    // Finish bearish mitigation
    //--------------------------------------------------
    if bearFullyMitigated
        box.set_extend(
             currentBox,
             extend.none
        )

        box.set_right(
             currentBox,
             bar_index
        )

        if not na(currentLine)
            line.set_extend(
                 currentLine,
                 extend.none
            )

            line.set_x2(
                 currentLine,
                 bar_index
            )

        if not na(currentLabel)
            label.set_x(
                 currentLabel,
                 bar_index
            )

        if not keepMitigatedBoxes
            box.delete(currentBox)

            if not na(currentLine)
                line.delete(currentLine)

            if not na(currentLabel)
                label.delete(currentLabel)

        array.remove(
             bearBoxes,
             bearIndex
        )

        array.remove(
             bearLines,
             bearIndex
        )

        array.remove(
             bearLabels,
             bearIndex
        )

        array.remove(
             bearCreatedBars,
             bearIndex
        )

        array.remove(
             bearEqTouched,
             bearIndex
        )

        array.remove(
             bearOriginalEq,
             bearIndex
        )

    bearIndex -= 1

//--------------------------------------------------
// Box-formation alerts
//--------------------------------------------------
alertcondition(
     enableBoxFormedAlerts and
     showBullish and
     bullishPattern,
     title="Bullish Body-FVG Box Formed",
     message="A bullish three-candle body-FVG box has formed."
)

alertcondition(
     enableBoxFormedAlerts and
     showBearish and
     bearishPattern,
     title="Bearish Body-FVG Box Formed",
     message="A bearish three-candle body-FVG box has formed."
)

alertcondition(
     enableBoxFormedAlerts and
     (
          (
               showBullish and
               bullishPattern
          ) or
          (
               showBearish and
               bearishPattern
          )
     ),
     title="Any Body-FVG Box Formed",
     message="A new three-candle body-FVG box has formed."
)

//--------------------------------------------------
// 50% EQ-touch alerts
//--------------------------------------------------
alertcondition(
     enableEqTouchAlerts and
     bullishEqTouchEvent,
     title="Bullish Box 50% Touched",
     message="Price has touched the 50% level of a bullish body-FVG box."
)

alertcondition(
     enableEqTouchAlerts and
     bearishEqTouchEvent,
     title="Bearish Box 50% Touched",
     message="Price has touched the 50% level of a bearish body-FVG box."
)

alertcondition(
     enableEqTouchAlerts and
     (
          bullishEqTouchEvent or
          bearishEqTouchEvent
     ),
     title="Any Box 50% Touched",
     message="Price has touched the 50% level of a body-FVG box."
)
````

# Fair Value Gaps - Significant Displacement

- url: https://www.tradingview.com/script/PsBN8tD2-Fair-Value-Gaps-Significant-Displacement/
- type: indicator
- pine_id: PUB;35eccb43efea4b898b5168efb2d7513d
- version: 1.0

## Description

[b]Fair Value Gaps[/b] - Significant Displacement is designed to filter out many of the small, low-quality imbalances that can clutter a chart and instead focus on FVGs created during stronger displacement.

Rather than marking every textbook three-candle imbalance, the script evaluates gap size, relative volume, candle displacement, and candle structure before displaying an FVG.

The goal is a cleaner chart that highlights stronger imbalances for intraday price-action analysis.

🔎 [b]HOW FAIR VALUE GAPS ARE DETECTED[/b]

The indicator uses the traditional three-candle Fair Value Gap structure.

A [b]Bullish FVG[/b] forms when:

The current candle's low remains above the high from two candles earlier.
This creates an untraded price range between those candles.

A [b]Bearish FVG[/b] forms when:

The current candle's high remains below the low from two candles earlier.
This leaves an imbalance between the surrounding candles.

The middle candle is treated as the [b]displacement candle[/b] responsible for creating the imbalance.

⚡ [b]SIGNIFICANT DISPLACEMENT FILTERING[/b]

The script does not automatically display every FVG.

For an imbalance to qualify, the displacement must meet several quality requirements.

[b]RELATIVE VOLUME[/b]

The displacement candle must trade with meaningful volume relative to recent activity.

Default: Minimum Relative Volume: 1.25×

The candle's volume is compared with its recent average volume rather than using a fixed volume number, allowing the filter to adapt across different markets.

[b]MINIMUM FVG SIZE[/b]

Very small imbalances are filtered out using ATR.

Default: Minimum FVG Size: 0.10 ATR

This prevents insignificant gaps from being displayed simply because a technical three-candle imbalance exists.

[b]DISPLACEMENT BODY SIZE[/b]

The middle candle must show meaningful price expansion.

Default: Minimum Displacement Body: 0.70 ATR

This helps distinguish genuine displacement from ordinary candles that happen to create a small gap.

[b]CANDLE BODY QUALITY[/b]

The displacement candle's body must represent a meaningful portion of its total range.

Default: Minimum Body Percentage: 60%

This reduces FVGs produced by candles dominated by large wicks or limited directional body expansion.

[b]DIRECTIONAL DISPLACEMENT[/b]

By default:

[list]
[*]Bullish FVGs require a bullish displacement candle
[*]Bearish FVGs require a bearish displacement candle
[/list]

This keeps the imbalance aligned with the direction of the move that created it.

🟢 [b]BULLISH FVGs[/b]

Bullish Fair Value Gaps are displayed in green by default.

They represent an upside displacement that left an imbalance below current price.

Bullish and bearish FVG colors can both be customized from the indicator settings.

🔴 [b]BEARISH FVGs[/b]

Bearish Fair Value Gaps are displayed in red by default.

They represent downside displacement that left an imbalance above current price.

➗ [b]50% FVG MIDPOINT[/b]

Each FVG includes an optional 50% midpoint.

The midpoint is enabled by default and appears as a dashed line through the center of the imbalance.

This can be useful for traders who monitor partial mitigation or reactions around the equilibrium of an FVG.

The midpoint can be disabled from the settings for a cleaner chart.

✅ [b]FULL FVG FILL[/b]

FVGs remain active until the entire imbalance has been filled.

For a bullish FVG, price must trade through the lower boundary of the gap.

For a bearish FVG, price must trade through the upper boundary.

Once the FVG is fully filled, the box is automatically removed from the chart.

This prevents already-resolved imbalances from continuing to clutter the display.

🕒 [b]TRADING-DAY EXTENSION[/b]

Active FVGs extend across the trading day in which they formed.

At the beginning of the next trading day, remaining historical FVGs are capped at the end of their original session instead of extending indefinitely across future price action.

This keeps the visual history of previous sessions while maintaining a clean current chart.

📅 [b]HISTORICAL FVG LOOKBACK[/b]

Historical Fair Value Gaps can remain visible for a selected number of trading days.

Available settings:

[list]
[*]1 Day
[*]3 Days
[*]5 Days
[*]10 Days
[/list]

Default: [b]3 Trading Days[/b]

This allows traders to review previous-session imbalances without permanently accumulating old zones.

👁️ [b]DISPLAY CONTROLS[/b]

The indicator includes several visual controls:

[list]
[*]Show / Hide Bullish FVGs
[*]Show / Hide Bearish FVGs
[*]Custom Bullish FVG Color
[*]Custom Bearish FVG Color
[*]Box Transparency
[*]Border Transparency
[*]Show / Hide FVG Text
[*]Show / Hide 50% Midpoint
[*]Midpoint Transparency
[*]Historical Lookback
[/list]

The default appearance is designed to remain clean while still making important imbalances easy to identify.

🔔 [b]ALERTS[/b]

Alert conditions are included for:

[list]
[*]New Bullish FVG
[*]New Bearish FVG
[*]Bullish FVG Fully Filled
[*]Bearish FVG Fully Filled
[/list]

These can be used through TradingView's alert system to monitor new displacement imbalances and subsequent fills.

🧠 [b]HOW TO INTERPRET THE INDICATOR[/b]

An FVG should not automatically be treated as an entry signal.

The indicator identifies areas where significant displacement created an imbalance.

The script is intentionally focused on identifying the imbalance itself rather than combining unrelated trading systems into one indicator.

⏱️ [b]SIGNAL CONFIRMATION[/b]

FVGs are confirmed using closed candles.

A Fair Value Gap is only created once the three-candle structure is confirmed.

After confirmation, the FVG may remain active until fully filled or until it falls outside the selected historical lookback.

📌 SUMMARY

[b]Fair Value Gaps - Significant Displacement[/b] is built for traders who want FVG analysis without filling their chart with every minor imbalance.

The indicator combines:

[b]Three-candle FVG structure + relative volume + ATR gap size + displacement strength + candle quality + full-fill tracking[/b] to focus attention on stronger Fair Value Gaps while keeping the chart clean and readable.

## Source Code

````pine
//@version=6
indicator(
     "Fair Value Gaps - Significant Displacement",
     overlay = true,
     max_boxes_count = 500
)

// =====================================================
// FAIR VALUE GAP SETTINGS
// =====================================================

showFVG = input.bool(
     true,
     "Show FVG",
     group = "Fair Value Gaps"
)

showBullishFVG = input.bool(
     true,
     "Show Bullish FVG",
     group = "Fair Value Gaps"
)

showBearishFVG = input.bool(
     true,
     "Show Bearish FVG",
     group = "Fair Value Gaps"
)

maxFvgHistory = input.int(
     50,
     "Maximum FVG History",
     minval = 10,
     maxval = 200,
     group = "Fair Value Gaps"
)

historicalLookbackDays = input.int(
     3,
     "Historical Lookback (Trading Days)",
     options = [1, 3, 5, 10],
     group = "Fair Value Gaps",
     tooltip = "Keeps FVGs visible for this many completed trading days in addition to the current trading day."
)

// =====================================================
// VISUALS
// =====================================================

bullishFvgColor = input.color(
     color.green,
     "Bullish FVG Color",
     group = "Visuals"
)

bearishFvgColor = input.color(
     color.red,
     "Bearish FVG Color",
     group = "Visuals"
)

boxTransparency = input.int(
     90,
     "Box Transparency",
     minval = 0,
     maxval = 100,
     group = "Visuals"
)

borderTransparency = input.int(
     20,
     "Border Transparency",
     minval = 0,
     maxval = 100,
     group = "Visuals"
)

showFvgText = input.bool(
     true,
     "Show FVG Text",
     group = "Visuals"
)

showMidpoint = input.bool(
     true,
     "Show 50% Midpoint",
     group = "Visuals",
     tooltip = "Draws the 50% level of each FVG. Off by default to keep the chart clean."
)

midpointTransparency = input.int(
     35,
     "Midpoint Transparency",
     minval = 0,
     maxval = 100,
     group = "Visuals"
)

// =====================================================
// QUALITY FILTERS
// =====================================================

volumeLength = input.int(
     20,
     "Volume Average Length",
     minval = 5,
     maxval = 100,
     group = "Quality Filters"
)

minRelativeVolume = input.float(
     1.25,
     "Minimum Relative Volume",
     minval = 1.0,
     maxval = 5.0,
     step = 0.05,
     group = "Quality Filters",
     tooltip = "The middle displacement candle must have at least this multiple of its recent average volume."
)

atrLength = input.int(
     14,
     "ATR Length",
     minval = 5,
     maxval = 100,
     group = "Quality Filters"
)

minGapAtr = input.float(
     0.10,
     "Minimum FVG Size (ATR)",
     minval = 0.0,
     maxval = 2.0,
     step = 0.05,
     group = "Quality Filters",
     tooltip = "Minimum size of the actual fair value gap as a fraction of ATR."
)

minDisplacementBodyAtr = input.float(
     0.70,
     "Minimum Displacement Body (ATR)",
     minval = 0.10,
     maxval = 3.0,
     step = 0.05,
     group = "Quality Filters",
     tooltip = "The middle candle body must be at least this large relative to ATR."
)

minBodyPercentOfRange = input.float(
     0.60,
     "Minimum Body % Of Candle Range",
     minval = 0.30,
     maxval = 1.0,
     step = 0.05,
     group = "Quality Filters",
     tooltip = "Requires the displacement candle body to occupy a meaningful percentage of the full candle range."
)

requireDirectionalDisplacement = input.bool(
     true,
     "Require Directional Displacement Candle",
     group = "Quality Filters",
     tooltip = "Bullish FVGs require a bullish displacement candle and bearish FVGs require a bearish displacement candle."
)

// =====================================================
// CALCULATIONS
// =====================================================

float volumeAverage =
     ta.sma(
          volume,
          volumeLength
     )

float atrValue =
     ta.atr(
          atrLength
     )

bool enoughBars =
     bar_index >= 2

bool validVolumeData =
     enoughBars and
     not na(volume[1]) and
     not na(volumeAverage[1]) and
     volumeAverage[1] > 0

float middleRelativeVolume =
     validVolumeData ?
     volume[1] /
     volumeAverage[1] :
     na

bool volumeQualified =
     validVolumeData and
     middleRelativeVolume >=
     minRelativeVolume

float middleBody =
     enoughBars ?
     math.abs(
          close[1] -
          open[1]
     ) :
     na

float middleRange =
     enoughBars ?
     high[1] -
     low[1] :
     na

float middleBodyPercent =
     enoughBars and
     middleRange > 0 ?
     middleBody /
     middleRange :
     0.0

bool displacementBodyQualified =
     enoughBars and
     not na(atrValue[1]) and
     middleBody >=
     atrValue[1] *
     minDisplacementBodyAtr and
     middleBodyPercent >=
     minBodyPercentOfRange

bool bullishDisplacementDirection =
     not requireDirectionalDisplacement or
     close[1] >
     open[1]

bool bearishDisplacementDirection =
     not requireDirectionalDisplacement or
     close[1] <
     open[1]

float bullishGapSize =
     enoughBars ?
     low -
     high[2] :
     na

float bearishGapSize =
     enoughBars ?
     low[2] -
     high :
     na

bool bullishGapSizeQualified =
     enoughBars and
     not na(atrValue) and
     bullishGapSize >=
     atrValue *
     minGapAtr

bool bearishGapSizeQualified =
     enoughBars and
     not na(atrValue) and
     bearishGapSize >=
     atrValue *
     minGapAtr

// =====================================================
// FVG STORAGE
// =====================================================

var array<box> fvgBoxes =
     array.new_box()

var array<int> fvgDirs =
     array.new_int()

var array<float> fvgTops =
     array.new_float()

var array<float> fvgBottoms =
     array.new_float()

var array<int> fvgCreatedBars =
     array.new_int()

var array<int> fvgAgeDays =
     array.new_int()

var array<bool> fvgTouched =
     array.new_bool()

var array<bool> fvgFinalized =
     array.new_bool()

var array<line> fvgMidpointLines =
     array.new_line()

var array<label> fvgTextLabels =
     array.new_label()

bool newTradingDay =
     ta.change(
          time("D")
     ) != 0

// =====================================================
// DAY BOUNDARY DISPLAY MANAGEMENT
//
// Signal logic is untouched.
//
// At the start of each new trading day:
// - current-day boxes from yesterday are capped at
//   yesterday's final bar;
// - historical age advances by one trading day;
// - boxes older than the selected lookback are removed.
// =====================================================

if newTradingDay

    int dayIndex =
         array.size(
              fvgBoxes
         ) -
         1

    while dayIndex >= 0

        int ageDays =
             array.get(
                  fvgAgeDays,
                  dayIndex
             ) +
             1

        array.set(
             fvgAgeDays,
             dayIndex,
             ageDays
        )

        bool removeForAge =
             ageDays >
             historicalLookbackDays

        if removeForAge

            box expiredHistoryBox =
                 array.get(
                      fvgBoxes,
                      dayIndex
                 )

            if not na(
                 expiredHistoryBox
            )

                box.delete(
                     expiredHistoryBox
                )

            line expiredMidpointLine =
                 array.get(
                      fvgMidpointLines,
                      dayIndex
                 )

            if not na(
                 expiredMidpointLine
            )

                line.delete(
                     expiredMidpointLine
                )

            label expiredTextLabel =
                 array.get(
                      fvgTextLabels,
                      dayIndex
                 )

            if not na(
                 expiredTextLabel
            )

                label.delete(
                     expiredTextLabel
                )

            array.remove(
                 fvgBoxes,
                 dayIndex
            )

            array.remove(
                 fvgDirs,
                 dayIndex
            )

            array.remove(
                 fvgTops,
                 dayIndex
            )

            array.remove(
                 fvgBottoms,
                 dayIndex
            )

            array.remove(
                 fvgCreatedBars,
                 dayIndex
            )

            array.remove(
                 fvgAgeDays,
                 dayIndex
            )

            array.remove(
                 fvgTouched,
                 dayIndex
            )

            array.remove(
                 fvgFinalized,
                 dayIndex
            )

            array.remove(
                 fvgMidpointLines,
                 dayIndex
            )

            array.remove(
                 fvgTextLabels,
                 dayIndex
            )

        else

            bool finalized =
                 array.get(
                      fvgFinalized,
                      dayIndex
                 )

            if not finalized

                box dayBox =
                     array.get(
                          fvgBoxes,
                          dayIndex
                     )

                if not na(
                     dayBox
                )

                    box.set_extend(
                         dayBox,
                         extend.none
                    )

                    box.set_right(
                         dayBox,
                         bar_index -
                         1
                    )

                line dayMidpointLine =
                     array.get(
                          fvgMidpointLines,
                          dayIndex
                     )

                if not na(
                     dayMidpointLine
                )

                    line.set_extend(
                         dayMidpointLine,
                         extend.none
                    )

                    line.set_x2(
                         dayMidpointLine,
                         bar_index -
                         1
                    )

                array.set(
                     fvgFinalized,
                     dayIndex,
                     true
                )

        dayIndex -=
             1

// =====================================================
// ALERT FLAGS
// =====================================================

bool newBullishFVG =
     false

bool newBearishFVG =
     false

bool bullishFvgFilled =
     false

bool bearishFvgFilled =
     false

// =====================================================
// SIGNIFICANT FVG DETECTION
// =====================================================

bool bullishFVG =
     enoughBars and
     barstate.isconfirmed and
     low >
     high[2] and
     volumeQualified and
     bullishGapSizeQualified and
     displacementBodyQualified and
     bullishDisplacementDirection

bool bearishFVG =
     enoughBars and
     barstate.isconfirmed and
     high <
     low[2] and
     volumeQualified and
     bearishGapSizeQualified and
     displacementBodyQualified and
     bearishDisplacementDirection

// =====================================================
// CREATE BULLISH FVG
// =====================================================

if bullishFVG

    float fvgTop =
         low

    float fvgBottom =
         high[2]

    box newFvgBox =
         na

    if showFVG and
       showBullishFVG

        newFvgBox :=
             box.new(
                  left =
                       bar_index -
                       1,
                  top =
                       fvgTop,
                  right =
                       bar_index,
                  bottom =
                       fvgBottom,
                  xloc =
                       xloc.bar_index,
                  extend =
                       extend.right,
                  border_color =
                       color.new(
                            bullishFvgColor,
                            borderTransparency
                       ),
                  border_width =
                       1,
                  bgcolor =
                       color.new(
                            bullishFvgColor,
                            boxTransparency
                       )
             )

    array.push(
         fvgBoxes,
         newFvgBox
    )

    array.push(
         fvgDirs,
         1
    )

    array.push(
         fvgTops,
         fvgTop
    )

    array.push(
         fvgBottoms,
         fvgBottom
    )

    array.push(
         fvgCreatedBars,
         bar_index
    )

    array.push(
         fvgAgeDays,
         0
    )

    array.push(
         fvgTouched,
         false
    )

    array.push(
         fvgFinalized,
         false
    )

    line newBullishMidpoint =
         na

    if showFVG and
       showBullishFVG and
       showMidpoint

        float midpoint =
             (
                  fvgTop +
                  fvgBottom
             ) /
             2.0

        newBullishMidpoint :=
             line.new(
                  x1 =
                       bar_index -
                       1,
                  y1 =
                       midpoint,
                  x2 =
                       bar_index,
                  y2 =
                       midpoint,
                  xloc =
                       xloc.bar_index,
                  extend =
                       extend.right,
                  color =
                       color.new(
                            bullishFvgColor,
                            midpointTransparency
                       ),
                  width =
                       1,
                  style =
                       line.style_dashed
             )

    array.push(
         fvgMidpointLines,
         newBullishMidpoint
    )

    label newBullishTextLabel =
         na

    if showFVG and
       showBullishFVG and
       showFvgText

        float bullishTextY =
             (
                  fvgTop +
                  fvgBottom
             ) /
             2.0

        newBullishTextLabel :=
             label.new(
                  x =
                       bar_index +
                       1,
                  y =
                       bullishTextY,
                  text =
                       "FVG",
                  xloc =
                       xloc.bar_index,
                  yloc =
                       yloc.price,
                  style =
                       label.style_none,
                  textcolor =
                       color.new(
                            color.white,
                            25
                       ),
                  size =
                       size.tiny
             )

    array.push(
         fvgTextLabels,
         newBullishTextLabel
    )

    newBullishFVG :=
         true

// =====================================================
// CREATE BEARISH FVG
// =====================================================

if bearishFVG

    float fvgTop =
         low[2]

    float fvgBottom =
         high

    box newFvgBox =
         na

    if showFVG and
       showBearishFVG

        newFvgBox :=
             box.new(
                  left =
                       bar_index -
                       1,
                  top =
                       fvgTop,
                  right =
                       bar_index,
                  bottom =
                       fvgBottom,
                  xloc =
                       xloc.bar_index,
                  extend =
                       extend.right,
                  border_color =
                       color.new(
                            bearishFvgColor,
                            borderTransparency
                       ),
                  border_width =
                       1,
                  bgcolor =
                       color.new(
                            bearishFvgColor,
                            boxTransparency
                       )
             )

    array.push(
         fvgBoxes,
         newFvgBox
    )

    array.push(
         fvgDirs,
         -1
    )

    array.push(
         fvgTops,
         fvgTop
    )

    array.push(
         fvgBottoms,
         fvgBottom
    )

    array.push(
         fvgCreatedBars,
         bar_index
    )

    array.push(
         fvgAgeDays,
         0
    )

    array.push(
         fvgTouched,
         false
    )

    array.push(
         fvgFinalized,
         false
    )

    line newBearishMidpoint =
         na

    if showFVG and
       showBearishFVG and
       showMidpoint

        float midpoint =
             (
                  fvgTop +
                  fvgBottom
             ) /
             2.0

        newBearishMidpoint :=
             line.new(
                  x1 =
                       bar_index -
                       1,
                  y1 =
                       midpoint,
                  x2 =
                       bar_index,
                  y2 =
                       midpoint,
                  xloc =
                       xloc.bar_index,
                  extend =
                       extend.right,
                  color =
                       color.new(
                            bearishFvgColor,
                            midpointTransparency
                       ),
                  width =
                       1,
                  style =
                       line.style_dashed
             )

    array.push(
         fvgMidpointLines,
         newBearishMidpoint
    )

    label newBearishTextLabel =
         na

    if showFVG and
       showBearishFVG and
       showFvgText

        float bearishTextY =
             (
                  fvgTop +
                  fvgBottom
             ) /
             2.0

        newBearishTextLabel :=
             label.new(
                  x =
                       bar_index +
                       1,
                  y =
                       bearishTextY,
                  text =
                       "FVG",
                  xloc =
                       xloc.bar_index,
                  yloc =
                       yloc.price,
                  style =
                       label.style_none,
                  textcolor =
                       color.new(
                            color.white,
                            25
                       ),
                  size =
                       size.tiny
             )

    array.push(
         fvgTextLabels,
         newBearishTextLabel
    )

    newBearishFVG :=
         true

// =====================================================
// MANAGE FVG BOXES
//
// - Every independently significant FVG may print.
// - The box remains extended through the trading day.
// - Once the gap is FULLY FILLED, the box is deleted.
// - At the next trading day, any still-open box is capped
//   at the prior day's final bar.
// =====================================================

if barstate.isconfirmed

    int f =
         array.size(
              fvgBoxes
         ) -
         1

    while f >= 0

        box currentBox =
             array.get(
                  fvgBoxes,
                  f
             )

        int fvgDir =
             array.get(
                  fvgDirs,
                  f
             )

        float fvgTop =
             array.get(
                  fvgTops,
                  f
             )

        float fvgBottom =
             array.get(
                  fvgBottoms,
                  f
             )

        int createdBar =
             array.get(
                  fvgCreatedBars,
                  f
             )

        bool alreadyTouched =
             array.get(
                  fvgTouched,
                  f
             )

        bool laterBar =
             bar_index >
             createdBar

        if laterBar

            bool touchesFvg =
                 high >=
                 fvgBottom and
                 low <=
                 fvgTop

            if not alreadyTouched and
               touchesFvg

                array.set(
                     fvgTouched,
                     f,
                     true
                )

            bool fullyFilled =
                 fvgDir == 1 ?
                 low <=
                 fvgBottom :
                 high >=
                 fvgTop

            if fullyFilled

                if fvgDir == 1

                    bullishFvgFilled :=
                         true

                else

                    bearishFvgFilled :=
                         true

                if not na(
                     currentBox
                )

                    box.delete(
                         currentBox
                    )

                line currentMidpointLine =
                     array.get(
                          fvgMidpointLines,
                          f
                     )

                if not na(
                     currentMidpointLine
                )

                    line.delete(
                         currentMidpointLine
                    )

                label currentTextLabel =
                     array.get(
                          fvgTextLabels,
                          f
                     )

                if not na(
                     currentTextLabel
                )

                    label.delete(
                         currentTextLabel
                    )

                array.remove(
                     fvgBoxes,
                     f
                )

                array.remove(
                     fvgDirs,
                     f
                )

                array.remove(
                     fvgTops,
                     f
                )

                array.remove(
                     fvgBottoms,
                     f
                )

                array.remove(
                     fvgCreatedBars,
                     f
                )

                array.remove(
                     fvgAgeDays,
                     f
                )

                array.remove(
                     fvgTouched,
                     f
                )

                array.remove(
                     fvgFinalized,
                     f
                )

                array.remove(
                     fvgMidpointLines,
                     f
                )

                array.remove(
                     fvgTextLabels,
                     f
                )

        f -=
             1

// =====================================================
// LIMIT FVG HISTORY
// =====================================================

while array.size(
     fvgBoxes
) > maxFvgHistory

    box oldBox =
         array.shift(
              fvgBoxes
         )

    array.shift(
         fvgDirs
    )

    array.shift(
         fvgCreatedBars
    )

    if not na(
         oldBox
    )

        box.delete(
             oldBox
        )

    line oldMidpointLine =
         array.shift(
              fvgMidpointLines
         )

    if not na(
         oldMidpointLine
    )

        line.delete(
             oldMidpointLine
        )

    label oldTextLabel =
         array.shift(
              fvgTextLabels
         )

    if not na(
         oldTextLabel
    )

        label.delete(
             oldTextLabel
        )

    array.shift(
         fvgTops
    )

    array.shift(
         fvgBottoms
    )

    array.shift(
         fvgAgeDays
    )

    array.shift(
         fvgTouched
    )

    array.shift(
         fvgFinalized
    )

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     newBullishFVG,
     "Bullish FVG",
     "Significant bullish FVG confirmed on {{ticker}}."
)

alertcondition(
     newBearishFVG,
     "Bearish FVG",
     "Significant bearish FVG confirmed on {{ticker}}."
)

alertcondition(
     bullishFvgFilled,
     "Bullish FVG Filled",
     "Bullish FVG fully filled on {{ticker}}."
)

alertcondition(
     bearishFvgFilled,
     "Bearish FVG Filled",
     "Bearish FVG fully filled on {{ticker}}."
)
````

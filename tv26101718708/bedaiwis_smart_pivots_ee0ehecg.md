# Bedaiwi's Smart Pivots

- url: https://www.tradingview.com/script/EE0ehEcg-Bedaiwi-s-Smart-Pivots/
- type: indicator
- pine_id: PUB;642d78967b0e45008ef0b4e1d537c997
- version: 1.0

## Description

[b]Bedaiwi's Smart Pivots[/b] is a three-level market-structure indicator that classifies price turning points as Minor, Intermediate, and Major highs and lows.

[b]HOW IT WORKS[/b]

[i]Minor Pivots
[/i]
A Minor High is confirmed when the middle bar of a three-bar formation has a high that is strictly higher than the highs immediately before and after it.

A Minor Low is confirmed when the middle bar has a low that is strictly lower than the lows immediately before and after it.

Equal highs and equal lows are not treated as Minor pivots.

[i] Intermediate Pivots [/i]

Intermediate pivots are derived from confirmed sequences of Minor pivots.

An Intermediate High is identified when a higher Minor High is followed by a lower Minor High.

An Intermediate Low is identified when a lower Minor Low is followed by a higher Minor Low.

[i]Major Pivots [/i]

Major pivots apply the same hierarchical logic to confirmed Intermediate pivots.

A Major High is identified when a higher Intermediate High is followed by a lower Intermediate High.

A Major Low is identified when a lower Intermediate Low is followed by a higher Intermediate Low.

[b]SYMBOLS AND COLORS[/b]

- Red diamond: Intermediate High
- Green diamond: Intermediate Low
- Red exclamation mark: Major High
- Green exclamation mark: Major Low

Optional Minor pivots use the same High and Low color settings.

When the replacement option is enabled, an Intermediate symbol is removed and replaced with an exclamation mark if the same point is later promoted to Major status.

[b]HISTORICAL PLOTTING AND CONFIRMATION DELAY[/b]

Pivot identification requires subsequent price information.

A Minor pivot is confirmed only after the following bar closes. Intermediate and Major pivots require additional confirmed pivot sequences, so their confirmation occurs later.

After confirmation, the indicator places the symbol on the historical bar where the relevant high or low occurred. Therefore, a symbol displayed on an earlier bar was not necessarily available in real time on that bar.

Historical placement is used only to show the actual location of the confirmed turning point. It should not be interpreted as a signal that was known on the historical pivot bar.

[b]SETTINGS[/b]

Users can:

- Show or hide Minor pivots
- Show or hide Intermediate pivots
- Show or hide Major pivots
- Replace an Intermediate symbol when it becomes a Major pivot
- Customize High and Low pivot colors

[b]PRACTICAL USE[/b]

Smart Pivots can help users:

- Study market structure
- Identify significant historical swing highs and lows
- Separate short-term fluctuations from higher-level price structure
- Review possible support and resistance areas
- Add context to discretionary price-action analysis

[b]LIMITATIONS[/b]

Smart Pivots is an analytical indicator. It does not place trading orders and does not define entries, exits, stop-loss levels, profit targets, position sizing, or expected returns.

Pivot confirmation is delayed by design because later price action is required. Results may vary between symbols, timeframes, sessions, and data feeds.

The indicator does not identify final market tops or bottoms with certainty. Historical observations do not guarantee future market behavior.

This script is provided for research and educational purposes only. It is not financial or investment advice.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0:
// https://mozilla.org/MPL/2.0/
//
// Smart Pivots is a three-level hierarchical pivot-structure indicator.
// It identifies Minor, Intermediate, and Major highs and lows.
// This script does not submit trading orders.

//@version=6
indicator(
     title            = "Bedaiwi's Smart Pivots",
     shorttitle       = "Bedaiwi's Smart Pivots",
     overlay          = true,
     max_labels_count = 500
)

//=============================================================================
// Settings
//=============================================================================

const string DISPLAY_GROUP = "Pivot Display"

bool showMinor = input.bool(
     false,
     "Show Minor Pivots",
     group = DISPLAY_GROUP
)

bool showIntermediate = input.bool(
     true,
     "Show Intermediate Pivots",
     group = DISPLAY_GROUP
)

bool showMajor = input.bool(
     true,
     "Show Major Pivots",
     group = DISPLAY_GROUP
)

bool replaceIntermediateWithMajor = input.bool(
     true,
     "Replace Intermediate Symbol With Major Symbol",
     tooltip = "When an Intermediate pivot becomes a Major pivot, the diamond is removed and replaced with an exclamation mark.",
     group = DISPLAY_GROUP
)

color upColor = input.color(
     color.rgb(255, 0, 0),
     "High Pivot Color",
     group = DISPLAY_GROUP
)

color downColor = input.color(
     color.rgb(0, 170, 80),
     "Low Pivot Color",
     group = DISPLAY_GROUP
)

//=============================================================================
// Minor Pivots
//
// A Minor High pivot is a strict three-bar local high.
// A Minor Low pivot is a strict three-bar local low.
//
// The same strict comparisons are used, so equal highs or equal lows are not accepted.
//=============================================================================

bool minorUpConfirmed =
     barstate.isconfirmed and
     bar_index >= 2 and
     high[1] > high[2] and
     high[1] > high

bool minorDownConfirmed =
     barstate.isconfirmed and
     bar_index >= 2 and
     low[1] < low[2] and
     low[1] < low

// Plot the Minor pivot on its original high or low bar.
plotshape(
     series   = showMinor and minorUpConfirmed,
     title    = "Minor High",
     style    = shape.diamond,
     location = location.abovebar,
     offset   = -1,
     color    = upColor,
     size     = size.tiny
)

plotshape(
     series   = showMinor and minorDownConfirmed,
     title    = "Minor Low",
     style    = shape.diamond,
     location = location.belowbar,
     offset   = -1,
     color    = downColor,
     size     = size.tiny
)

//=============================================================================
// Previous Minor High pivots
//=============================================================================

var float previousMinorHighPrice = na
var int   previousMinorHighBar   = na
var bool  previousMinorHighWasP2 = false

//=============================================================================
// Previous Minor Low pivots
//=============================================================================

var float previousMinorLowPrice = na
var int   previousMinorLowBar   = na
var bool  previousMinorLowWasP2 = false

//=============================================================================
// Previous Intermediate High pivots
//=============================================================================

var float previousIntermediateUpPrice = na
var int   previousIntermediateUpBar   = na
var bool  previousIntermediateUpWasP2 = false
var label previousIntermediateUpLabel = na

//=============================================================================
// Previous Intermediate Low pivots
//=============================================================================

var float previousIntermediateDownPrice = na
var int   previousIntermediateDownBar   = na
var bool  previousIntermediateDownWasP2 = false
var label previousIntermediateDownLabel = na

//=============================================================================
// Minor High -> Intermediate High -> Major High
//=============================================================================

if minorUpConfirmed

    float currentMinorHighPrice = high[1]
    int currentMinorHighBar = bar_index - 1

    // p2:
    // The current Minor high is higher than the previous Minor high.
    bool currentMinorHighP2 =
         not na(previousMinorHighPrice) and
         currentMinorHighPrice > previousMinorHighPrice

    // p3:
    // The current Minor high is lower than the previous one,
    // and the previous Minor high was a p2 higher high.
    bool currentMinorHighP3 =
         not na(previousMinorHighPrice) and
         currentMinorHighPrice < previousMinorHighPrice and
         previousMinorHighWasP2

    // When p3 occurs, the previous Minor high becomes an Intermediate High pivot.
    if currentMinorHighP3

        float currentIntermediateUpPrice = previousMinorHighPrice
        int currentIntermediateUpBar = previousMinorHighBar

        // pj2:
        // The current Intermediate High pivot is higher than the previous one.
        bool currentIntermediateUpP2 =
             not na(previousIntermediateUpPrice) and
             currentIntermediateUpPrice > previousIntermediateUpPrice

        // pj3:
        // The current Intermediate High pivot is lower than the previous one,
        // and the previous Intermediate High pivot was a pj2 higher high.
        bool currentIntermediateUpP3 =
             not na(previousIntermediateUpPrice) and
             currentIntermediateUpPrice < previousIntermediateUpPrice and
             previousIntermediateUpWasP2

        // When pj3 occurs, the previous Intermediate High pivot becomes a Major High pivot.
        if currentIntermediateUpP3

            if showMajor

                if replaceIntermediateWithMajor and
                   not na(previousIntermediateUpLabel)

                    label.delete(previousIntermediateUpLabel)

                label.new(
                     x         = previousIntermediateUpBar,
                     y         = na,
                     text      = "!",
                     xloc      = xloc.bar_index,
                     yloc      = yloc.abovebar,
                     style     = label.style_none,
                     textcolor = upColor,
                     size      = size.large,
                     tooltip   = "Major High"
                )

        // Create the symbol for the current Intermediate High pivot.
        label currentIntermediateUpLabel = na

        if showIntermediate

            currentIntermediateUpLabel := label.new(
                 x         = currentIntermediateUpBar,
                 y         = na,
                 text      = "◆",
                 xloc      = xloc.bar_index,
                 yloc      = yloc.abovebar,
                 style     = label.style_none,
                 textcolor = upColor,
                 size      = size.small,
                 tooltip   = "Intermediate High"
            )

        previousIntermediateUpWasP2 := currentIntermediateUpP2
        previousIntermediateUpPrice := currentIntermediateUpPrice
        previousIntermediateUpBar   := currentIntermediateUpBar
        previousIntermediateUpLabel := currentIntermediateUpLabel

    previousMinorHighWasP2 := currentMinorHighP2
    previousMinorHighPrice := currentMinorHighPrice
    previousMinorHighBar   := currentMinorHighBar

//=============================================================================
// Minor Low -> Intermediate Low -> Major Low
//=============================================================================

if minorDownConfirmed

    float currentMinorLowPrice = low[1]
    int currentMinorLowBar = bar_index - 1

    // p2:
    // The current Minor low is lower than the previous Minor low.
    bool currentMinorLowP2 =
         not na(previousMinorLowPrice) and
         currentMinorLowPrice < previousMinorLowPrice

    // p3:
    // The current Minor low is higher than the previous one,
    // and the previous Minor low was a p2 lower low.
    bool currentMinorLowP3 =
         not na(previousMinorLowPrice) and
         currentMinorLowPrice > previousMinorLowPrice and
         previousMinorLowWasP2

    // When p3 occurs, the previous Minor low becomes an Intermediate Low pivot.
    if currentMinorLowP3

        float currentIntermediateDownPrice = previousMinorLowPrice
        int currentIntermediateDownBar = previousMinorLowBar

        // pj2:
        // The current Intermediate Low pivot is lower than the previous one.
        bool currentIntermediateDownP2 =
             not na(previousIntermediateDownPrice) and
             currentIntermediateDownPrice < previousIntermediateDownPrice

        // pj3:
        // The current Intermediate Low pivot is higher than the previous one,
        // and the previous Intermediate Low pivot was a pj2 lower low.
        bool currentIntermediateDownP3 =
             not na(previousIntermediateDownPrice) and
             currentIntermediateDownPrice > previousIntermediateDownPrice and
             previousIntermediateDownWasP2

        // When pj3 occurs, the previous Intermediate Low pivot becomes a Major Low pivot.
        if currentIntermediateDownP3

            if showMajor

                if replaceIntermediateWithMajor and
                   not na(previousIntermediateDownLabel)

                    label.delete(previousIntermediateDownLabel)

                label.new(
                     x         = previousIntermediateDownBar,
                     y         = na,
                     text      = "!",
                     xloc      = xloc.bar_index,
                     yloc      = yloc.belowbar,
                     style     = label.style_none,
                     textcolor = downColor,
                     size      = size.large,
                     tooltip   = "Major Low"
                )

        // Create the symbol for the current Intermediate Low pivot.
        label currentIntermediateDownLabel = na

        if showIntermediate

            currentIntermediateDownLabel := label.new(
                 x         = currentIntermediateDownBar,
                 y         = na,
                 text      = "◆",
                 xloc      = xloc.bar_index,
                 yloc      = yloc.belowbar,
                 style     = label.style_none,
                 textcolor = downColor,
                 size      = size.small,
                 tooltip   = "Intermediate Low"
            )

        previousIntermediateDownWasP2 := currentIntermediateDownP2
        previousIntermediateDownPrice := currentIntermediateDownPrice
        previousIntermediateDownBar   := currentIntermediateDownBar
        previousIntermediateDownLabel := currentIntermediateDownLabel

    previousMinorLowWasP2 := currentMinorLowP2
    previousMinorLowPrice := currentMinorLowPrice
    previousMinorLowBar   := currentMinorLowBar
````

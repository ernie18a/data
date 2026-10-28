# DMI Spread Dashboard ,5m  30m 1h

- url: https://www.tradingview.com/script/A2XlaUGt-DMI-Spread-Dashboard-5m-30m-1h/
- type: indicator
- pine_id: PUB;b3bd9f45d8624511af2f61cc13a34e4b
- version: 1.0

## Description

DMI Spread Dashboard is a multi-timeframe directional-momentum monitor built around the Directional Movement Index (DMI) and Average Directional Index (ADX). It calculates the complete DMI structure independently on the 5-minute, 30-minute, and 1-hour timeframes, then organizes the results into one compact chart dashboard.

The indicator is designed to answer four separate questions:

1. Which side currently has directional control?
2. How large is the difference between positive and negative directional movement?
3. Is that directional difference expanding or contracting?
4. Is the underlying directional movement strong enough to be meaningful according to ADX?

Instead of displaying only a DMI crossover or a single ADX value, the dashboard separates direction, directional separation, trend strength, and momentum development. This helps users distinguish an established directional move from a weak crossover or a move that is losing participation.

HOW THE CALCULATIONS WORK

The script uses the traditional Directional Movement framework associated with J. Welles Wilder Jr.

For every selected timeframe, the script first compares the current high and low with those of the previous bar:

• Positive directional movement measures qualifying upward movement in the high.

• Negative directional movement measures qualifying downward movement in the low.

• When both sides move, only the qualifying dominant directional movement is retained according to the standard DMI comparison.

Positive and negative directional movement are smoothed using Wilder’s moving average method. Each smoothed value is then normalized by a Wilder-smoothed True Range and multiplied by 100 to produce +DI and -DI.

The script calculates ADX from the smoothed absolute difference between +DI and -DI relative to their combined value. ADX measures the strength of directional movement, not its direction. A high ADX can therefore occur during either bullish or bearish conditions.

The indicator then calculates its central measurement:

DMI Spread = +DI - -DI

A positive spread means +DI is greater than -DI and upward directional movement is dominant. A negative spread means -DI is greater than +DI and downward directional movement is dominant. A spread near zero indicates that neither side has established meaningful separation.

WHAT MAKES THE DASHBOARD DIFFERENT

The script does more than place standard DMI values from several timeframes into a table. It converts the relationship between +DI and -DI into a signed spread and then measures the bar-to-bar change in that spread.

This creates two separate forms of information:

• Direction identifies which side is currently dominant.

• Spread development identifies whether that dominance is expanding or contracting.

For a positive spread, an increase in the spread is classified as EXPANDING because bullish directional separation is increasing. A decrease is classified as CONTRACTING because bullish separation is weakening.

For a negative spread, a further decrease below zero is classified as EXPANDING because bearish directional separation is increasing. Movement back toward zero is classified as CONTRACTING because bearish separation is weakening.

This distinction is important because a market can remain technically bullish while its bullish DMI spread contracts. It can also remain technically bearish while bearish separation begins to weaken. The dashboard makes those changes visible without requiring users to compare multiple DMI plots manually.

The 5-minute, 30-minute, and 1-hour calculations are performed independently using each timeframe’s own price data. The 5-minute row can be used for short-term execution context, the 30-minute row for intermediate intraday structure, and the 1-hour row for broader directional context.

DASHBOARD COLUMNS

TIME

Identifies the independently calculated 5-minute, 30-minute, or 1-hour dataset.

+DI

Shows the magnitude of positive directional movement after Wilder smoothing and True Range normalization.

-DI

Shows the magnitude of negative directional movement after Wilder smoothing and True Range normalization.

SPREAD

Shows +DI minus -DI. Positive values indicate bullish directional dominance, while negative values indicate bearish directional dominance. The magnitude describes the separation between the two DMI components.

DIRECTION

Displays BULLISH when the spread is above zero, BEARISH when it is below zero, and NEUTRAL when the two values are equal.

ADX

Displays the Average Directional Index for the corresponding timeframe. ADX measures directional strength and does not determine whether the direction is bullish or bearish.

STRENGTH

Classifies ADX as STRONG or WEAK using the user-defined ADX Strength Threshold. The default threshold is 25. This threshold is a filter and should be adjusted when appropriate for the instrument and trading method.

STATUS

Displays one of four conditions:

• BULL CROSS: +DI has crossed above -DI.

• BEAR CROSS: +DI has crossed below -DI.

• EXPANDING: the prevailing directional spread is moving farther away from zero.

• CONTRACTING: the prevailing directional spread is moving toward zero or is no longer expanding.

When a new DMI cross is detected, the cross message temporarily takes priority over the expanding or contracting classification.

INTERPRETING MULTI-TIMEFRAME ALIGNMENT

Broad bullish alignment is present when all three spreads are positive. The alignment has stronger directional confirmation when the spreads are also expanding and ADX is above the selected threshold.

Broad bearish alignment is present when all three spreads are negative. The alignment has stronger directional confirmation when the negative spreads are expanding and ADX is above the selected threshold.

Mixed readings indicate timeframe disagreement. For example, a bullish 5-minute reading against bearish 30-minute and 1-hour readings may represent a short-term rebound within a broader bearish structure. It does not automatically confirm a larger bullish reversal.

A contracting spread should not automatically be interpreted as a reversal. It only indicates that the existing separation between +DI and -DI is narrowing. A crossover or additional price confirmation is required before directional control has formally changed under this model.

SUGGESTED WORKFLOW

1. Begin with the 1-hour row to identify the broader directional condition.

2. Use the 30-minute row to determine whether intermediate momentum agrees with or opposes the 1-hour condition.

3. Use the 5-minute row to monitor shorter-term changes, contractions, expansions, and DMI crosses.

4. Give greater weight to a setup when direction, spread development, and ADX strength agree across multiple timeframes.

5. Confirm dashboard readings with price structure, support and resistance, liquidity, volume, or another independent execution method.

The dashboard can be moved to the top-right, top-left, bottom-right, or bottom-left corner through the Dashboard Position input.

INPUTS

DI Length controls the smoothing period used to calculate +DI and -DI. The default is 14.

ADX Smoothing controls the smoothing period used for ADX. The default is 14.

ADX Strength Threshold determines when the dashboard labels ADX as STRONG. The default is 25.

Dashboard Position controls where the table appears on the chart.

ALERTS

The script provides separate bullish and bearish DMI cross alert conditions for the 5-minute, 30-minute, and 1-hour timeframes.

For confirmation-based use, alerts should normally be configured as “Once Per Bar Close.” Alerts notify users that a DMI relationship has changed; they are not automatic trade signals.

LIMITATIONS

This indicator does not predict future price direction and does not generate entries, exits, profit targets, or stop-loss levels.

DMI and ADX are derived from historical price movement and are lagging measurements. Crosses can occur after a move has already begun, and repeated crosses may occur during sideways or low-volatility markets.

ADX measures directional strength, not direction. A STRONG reading can accompany either bullish or bearish movement.

EXPANDING and CONTRACTING describe changes in the DMI spread. They do not guarantee price continuation or reversal.

Values from an open timeframe can change while that timeframe’s bar is still developing. A 30-minute or 1-hour reading is not final until its corresponding bar closes. Using “Once Per Bar Close” helps avoid acting on an unfinished alert condition, but users should still understand which timeframe is being evaluated.

When the indicator is used on a chart timeframe above five minutes, TradingView’s standard lower-timeframe request behavior may not reproduce every intermediate 5-minute event. For the most dependable observation of 5-minute changes and alerts, use the indicator on a 5-minute or lower chart.

The script should be used as a directional-context and confirmation tool rather than as a standalone trading system.

ORIGINALITY AND PURPOSE

DMI and ADX are established technical-analysis calculations. This script does not claim ownership of those underlying formulas.

The script’s contribution is its purpose-built interpretation and presentation layer: independently calculated 5-minute, 30-minute, and 1-hour DMI structures; a signed DMI spread; spread-expansion and contraction classification; timeframe-specific ADX strength; cross-state prioritization; configurable dashboard placement; and separate alert conditions.

These components are organized to help users evaluate directional control, separation, strength, and multi-timeframe agreement from one chart interface instead of manually comparing three separate DMI indicators.

Open-source users can inspect the calculations, adjust the parameters, and study how the multi-timeframe dashboard converts standard DMI components into a structured directional framework.

## Source Code

````pine
//@version=6
indicator(title="DMI Spread Dashboard — 5m / 30m / 1h", shorttitle="DMI Spread", overlay=true, precision=2)

//──────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────

diLength = input.int(14, "DI Length", minval=1)
adxSmoothing = input.int(14, "ADX Smoothing", minval=1, maxval=50)
adxThreshold = input.float(25.0, "ADX Strength Threshold", minval=1)

dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

//──────────────────────────────────────────────────────────────────────
// Dashboard position
//──────────────────────────────────────────────────────────────────────

tablePosition = switch dashboardPosition
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

//──────────────────────────────────────────────────────────────────────
// DMI calculation
// Spread = +DI minus -DI
//──────────────────────────────────────────────────────────────────────

calculateDMI() =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : up > down and up > 0 ? up : 0
    minusDM = na(down) ? na : down > up and down > 0 ? down : 0
    trueRangeAverage = ta.rma(ta.tr, diLength)
    plusDI = fixnan(100 * ta.rma(plusDM, diLength) / trueRangeAverage)
    minusDI = fixnan(100 * ta.rma(minusDM, diLength) / trueRangeAverage)
    diSum = plusDI + minusDI
    adx = 100 * ta.rma(math.abs(plusDI - minusDI) / (diSum == 0 ? 1 : diSum), adxSmoothing)
    spread = plusDI - minusDI
    spreadChange = ta.change(spread)
    bullishCross = ta.crossover(plusDI, minusDI)
    bearishCross = ta.crossunder(plusDI, minusDI)
    [plusDI, minusDI, adx, spread, spreadChange, bullishCross, bearishCross]

//──────────────────────────────────────────────────────────────────────
// Independent timeframe calculations
//──────────────────────────────────────────────────────────────────────

[plus5, minus5, adx5, spread5, spreadChange5, bullCross5, bearCross5] = request.security(syminfo.tickerid, "5", calculateDMI(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[plus30, minus30, adx30, spread30, spreadChange30, bullCross30, bearCross30] = request.security(syminfo.tickerid, "30", calculateDMI(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[plus60, minus60, adx60, spread60, spreadChange60, bullCross60, bearCross60] = request.security(syminfo.tickerid, "60", calculateDMI(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────────────
// Formatting helpers
//──────────────────────────────────────────────────────────────────────

formatValue(float value) =>
    str.tostring(value, "#.##")

directionText(float spread) =>
    spread > 0 ? "BULLISH" : spread < 0 ? "BEARISH" : "NEUTRAL"

directionColor(float spread) =>
    spread > 0 ? color.rgb(0, 150, 90) : spread < 0 ? color.rgb(190, 50, 50) : color.gray

strengthText(float adx) =>
    adx >= adxThreshold ? "STRONG" : "WEAK"

strengthColor(float adx) =>
    adx >= adxThreshold ? color.rgb(120, 80, 190) : color.rgb(85, 85, 85)

spreadState(float spread, float spreadChange) =>
    expanding = (spread > 0 and spreadChange > 0) or (spread < 0 and spreadChange < 0)
    expanding ? "EXPANDING" : "CONTRACTING"

spreadStateColor(float spread, float spreadChange) =>
    expanding = (spread > 0 and spreadChange > 0) or (spread < 0 and spreadChange < 0)
    expanding ? color.rgb(0, 125, 115) : color.rgb(180, 120, 25)

crossText(bool bullishCross, bool bearishCross) =>
    bullishCross ? "BULL CROSS" : bearishCross ? "BEAR CROSS" : "—"

crossColor(bool bullishCross, bool bearishCross) =>
    bullishCross ? color.rgb(0, 150, 90) : bearishCross ? color.rgb(190, 50, 50) : color.rgb(55, 55, 55)

//──────────────────────────────────────────────────────────────────────
// Dashboard
// Four rows: header, 5m, 30m and 1h
//──────────────────────────────────────────────────────────────────────

var table dashboard = table.new(tablePosition, 8, 4, border_width=1, frame_color=color.rgb(90, 90, 90), border_color=color.rgb(70, 70, 70))

headerColor = color.rgb(35, 35, 40)
textColor = color.white

if barstate.islast
    // Header
    table.cell(dashboard, 0, 0, "TIME", bgcolor=headerColor, text_color=textColor)
    table.cell(dashboard, 1, 0, "+DI", bgcolor=headerColor, text_color=color.rgb(80, 140, 255))
    table.cell(dashboard, 2, 0, "-DI", bgcolor=headerColor, text_color=color.rgb(255, 130, 40))
    table.cell(dashboard, 3, 0, "SPREAD", bgcolor=headerColor, text_color=textColor)
    table.cell(dashboard, 4, 0, "DIRECTION", bgcolor=headerColor, text_color=textColor)
    table.cell(dashboard, 5, 0, "ADX", bgcolor=headerColor, text_color=color.rgb(245, 0, 87))
    table.cell(dashboard, 6, 0, "STRENGTH", bgcolor=headerColor, text_color=textColor)
    table.cell(dashboard, 7, 0, "STATUS", bgcolor=headerColor, text_color=textColor)

    // 5-minute
    table.cell(dashboard, 0, 1, "5m", bgcolor=headerColor, text_color=textColor)
    table.cell(dashboard, 1, 1, formatValue(plus5), text_color=textColor)
    table.cell(dashboard, 2, 1, formatValue(minus5), text_color=textColor)
    table.cell(dashboard, 3, 1, formatValue(spread5), bgcolor=directionColor(spread5), text_color=textColor)
    table.cell(dashboard, 4, 1, directionText(spread5), bgcolor=directionColor(spread5), text_color=textColor)
    table.cell(dashboard, 5, 1, formatValue(adx5), text_color=textColor)
    table.cell(dashboard, 6, 1, strengthText(adx5), bgcolor=strengthColor(adx5), text_color=textColor)
    table.cell(dashboard, 7, 1, bullCross5 or bearCross5 ? crossText(bullCross5, bearCross5) : spreadState(spread5, spreadChange5), bgcolor=bullCross5 or bearCross5 ? crossColor(bullCross5, bearCross5) : spreadStateColor(spread5, spreadChange5), text_color=textColor)

    // 30-minute
    table.cell(dashboard, 0, 2, "30m", bgcolor=headerColor, text_color=textColor)
    table.cell(dashboard, 1, 2, formatValue(plus30), text_color=textColor)
    table.cell(dashboard, 2, 2, formatValue(minus30), text_color=textColor)
    table.cell(dashboard, 3, 2, formatValue(spread30), bgcolor=directionColor(spread30), text_color=textColor)
    table.cell(dashboard, 4, 2, directionText(spread30), bgcolor=directionColor(spread30), text_color=textColor)
    table.cell(dashboard, 5, 2, formatValue(adx30), text_color=textColor)
    table.cell(dashboard, 6, 2, strengthText(adx30), bgcolor=strengthColor(adx30), text_color=textColor)
    table.cell(dashboard, 7, 2, bullCross30 or bearCross30 ? crossText(bullCross30, bearCross30) : spreadState(spread30, spreadChange30), bgcolor=bullCross30 or bearCross30 ? crossColor(bullCross30, bearCross30) : spreadStateColor(spread30, spreadChange30), text_color=textColor)

    // 1-hour
    table.cell(dashboard, 0, 3, "1h", bgcolor=headerColor, text_color=textColor)
    table.cell(dashboard, 1, 3, formatValue(plus60), text_color=textColor)
    table.cell(dashboard, 2, 3, formatValue(minus60), text_color=textColor)
    table.cell(dashboard, 3, 3, formatValue(spread60), bgcolor=directionColor(spread60), text_color=textColor)
    table.cell(dashboard, 4, 3, directionText(spread60), bgcolor=directionColor(spread60), text_color=textColor)
    table.cell(dashboard, 5, 3, formatValue(adx60), text_color=textColor)
    table.cell(dashboard, 6, 3, strengthText(adx60), bgcolor=strengthColor(adx60), text_color=textColor)
    table.cell(dashboard, 7, 3, bullCross60 or bearCross60 ? crossText(bullCross60, bearCross60) : spreadState(spread60, spreadChange60), bgcolor=bullCross60 or bearCross60 ? crossColor(bullCross60, bearCross60) : spreadStateColor(spread60, spreadChange60), text_color=textColor)

//──────────────────────────────────────────────────────────────────────
// Alerts
// Use Once Per Bar Close
//──────────────────────────────────────────────────────────────────────

alertcondition(bullCross5, title="5m Bullish DMI Cross", message="5-minute DMI bullish cross: +DI crossed above -DI.")
alertcondition(bearCross5, title="5m Bearish DMI Cross", message="5-minute DMI bearish cross: +DI crossed below -DI.")

alertcondition(bullCross30, title="30m Bullish DMI Cross", message="30-minute DMI bullish cross: +DI crossed above -DI.")
alertcondition(bearCross30, title="30m Bearish DMI Cross", message="30-minute DMI bearish cross: +DI crossed below -DI.")

alertcondition(bullCross60, title="1h Bullish DMI Cross", message="1-hour DMI bullish cross: +DI crossed above -DI.")
alertcondition(bearCross60, title="1h Bearish DMI Cross", message="1-hour DMI bearish cross: +DI crossed below -DI.")
````

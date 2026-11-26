# Round Numbers

- url: https://www.tradingview.com/script/zlY3RolI-Round-Numbers/
- type: indicator
- pine_id: PUB;374c5074e69a4bcf8050a3c1522d1ec4
- version: 3.0

## Description

Round Numbers highlights the key psychological price levels around the current market by drawing round, half, and quarter number levels around price.

The goal is simple: make round numbers easier to see, improve chart readability, and help you stay visually oriented without cluttering the chart with unrelated logic.

[b]How it works[/b]
[list]
[*]Automatically adapts level spacing across different markets using daily range and decimal-place anchoring.
[*]Works with Forex, cryptocurrencies, indices, commodities, and stocks.
[*]Optional symbol-specific override multipliers are available for instruments that require custom spacing.
[/list]
[b]Displays[/b]
[list]
[*]Round levels
[*]Half levels
[*]Quarter levels
[/list]
[b]Use cases[/b]
[list]
[*]Visualize where price is trading relative to nearby psychological levels.
[*]Improve chart structure and orientation.
[*]Keep important price levels visible across different markets.
[/list]
[b]Settings[/b]
[list]
[*]Visible Levels - Number of levels displayed around the current price.
[*]Round / Half / Quarter - Individual visibility and style settings.
[*]Overrides - Optional symbol-specific spacing multipliers.
[/list]
This indicator is designed as a visual reference layer. It does not generate trade signals and does not attempt to identify support or resistance using order flow, liquidity, or reversal logic.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) PriceFirst
// Round Numbers v1.1.0

//@version=6
indicator("Round Numbers", "", true, max_lines_count = 500)

roundNumbersGroup = "Round Numbers"
roundNumbersVisibleLevels = input.int(8, "Visible Levels", inline=roundNumbersGroup, group=roundNumbersGroup, minval=0, maxval=60, tooltip="Alert modes: Touched fires immediately when price touches a selected level. Crossed also fires on touch, then fires again if the candle closes on the other side of the level.\n\nCreate a TradingView alert on this indicator and choose 'Any alert() function call'.\n\nTo disable it, delete the alert in TradingView. Settings are captured when the alert is created — recreate the alert to apply any changed settings.", display=display.none)

roundNumbersRoundDisplay = input.bool(true, "Round", inline="round", group=roundNumbersGroup)
roundNumbersRoundColor = input.color(color.rgb(103, 58, 183, 25), "", inline="round", group=roundNumbersGroup)
roundNumbersRoundStyle = input.string("Solid", title="", options=["Solid", "Dashed", "Dotted"], inline="round", group=roundNumbersGroup, display=display.none)
roundNumbersRoundAlert = input.string("Off", "Alert", options=["Off", "Touched", "Crossed"], inline="round", group=roundNumbersGroup)

roundNumbersHalfDisplay = input.bool(true, "Half", inline="half", group=roundNumbersGroup)
roundNumbersHalfColor = input.color(color.rgb(103, 58, 183, 25), "", inline="half", group=roundNumbersGroup)
roundNumbersHalfStyle = input.string("Solid", title="", options=["Solid", "Dashed", "Dotted"], inline="half", group=roundNumbersGroup, display=display.none)
roundNumbersHalfAlert = input.string("Off", "Alert", options=["Off", "Touched", "Crossed"], inline="half", group=roundNumbersGroup)

roundNumbersQuarterDisplay = input.bool(true, "Quarter", inline="quarter", group=roundNumbersGroup)
roundNumbersQuarterColor = input.color(color.rgb(103, 58, 183, 25), "", inline="quarter", group=roundNumbersGroup)
roundNumbersQuarterStyle = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="quarter", group=roundNumbersGroup, display=display.none)
roundNumbersQuarterAlert = input.string("Off", "Alert", options=["Off", "Touched", "Crossed"], inline="quarter", group=roundNumbersGroup)

overrideGroup = "Overrides"
overridePatterns1 = input.string("", "Symbols", inline="override1-symbols", group=overrideGroup, tooltip="Comma-separated symbol patterns. Multiplier scales automatic spacing; Step fixes round-to-round spacing and overrides Multiplier when greater than 0.", display=display.none)
overrideMultiplier1 = input.float(1.0, "Multiplier", inline="override1-values", minval=0.0001, step=0.1, group=overrideGroup, display=display.none)
overrideStep1 = input.float(0.0, "Step", inline="override1-values", minval=0.0, step=0.0001, group=overrideGroup, display=display.none)
overridePatterns2 = input.string("", "Symbols", inline="override2-symbols", group=overrideGroup, display=display.none)
overrideMultiplier2 = input.float(1.0, "Multiplier", inline="override2-values", minval=0.0001, step=0.1, group=overrideGroup, display=display.none)
overrideStep2 = input.float(0.0, "Step", inline="override2-values", minval=0.0, step=0.0001, group=overrideGroup, display=display.none)
overridePatterns3 = input.string("", "Symbols", inline="override3-symbols", group=overrideGroup, display=display.none)
overrideMultiplier3 = input.float(1.0, "Multiplier", inline="override3-values", minval=0.0001, step=0.1, group=overrideGroup, display=display.none)
overrideStep3 = input.float(0.0, "Step", inline="override3-values", minval=0.0, step=0.0001, group=overrideGroup, display=display.none)
overridePatterns4 = input.string("", "Symbols", inline="override4-symbols", group=overrideGroup, display=display.none)
overrideMultiplier4 = input.float(1.0, "Multiplier", inline="override4-values", minval=0.0001, step=0.1, group=overrideGroup, display=display.none)
overrideStep4 = input.float(0.0, "Step", inline="override4-values", minval=0.0, step=0.0001, group=overrideGroup, display=display.none)
overridePatterns5 = input.string("", "Symbols", inline="override5-symbols", group=overrideGroup, display=display.none)
overrideMultiplier5 = input.float(1.0, "Multiplier", inline="override5-values", minval=0.0001, step=0.1, group=overrideGroup, display=display.none)
overrideStep5 = input.float(0.0, "Step", inline="override5-values", minval=0.0, step=0.0001, group=overrideGroup, display=display.none)

getLineStyle(styleOption) =>
    styleOption == "Dotted" ? line.style_dotted : styleOption == "Dashed" ? line.style_dashed : line.style_solid

matchesOverrideList(listText) =>
    symbol = str.upper(syminfo.ticker)
    bool matched = false
    normalizedList = str.replace_all(str.upper(listText), " ", "")
    entries = str.split(normalizedList, ",")

    for entry in entries
        pattern = entry

        if str.length(pattern) > 0 and str.contains(symbol, pattern)
            matched := true
            break

    matched

getOverrideMajorStep(baseMajorStep) =>
    float majorStep = na

    if matchesOverrideList(overridePatterns1)
        majorStep := overrideStep1 > 0 ? overrideStep1 : baseMajorStep * overrideMultiplier1
    else if matchesOverrideList(overridePatterns2)
        majorStep := overrideStep2 > 0 ? overrideStep2 : baseMajorStep * overrideMultiplier2
    else if matchesOverrideList(overridePatterns3)
        majorStep := overrideStep3 > 0 ? overrideStep3 : baseMajorStep * overrideMultiplier3
    else if matchesOverrideList(overridePatterns4)
        majorStep := overrideStep4 > 0 ? overrideStep4 : baseMajorStep * overrideMultiplier4
    else if matchesOverrideList(overridePatterns5)
        majorStep := overrideStep5 > 0 ? overrideStep5 : baseMajorStep * overrideMultiplier5

    majorStep

dailyRangeAnchor = request.security(syminfo.tickerid, "D", math.max(ta.sma(high - low, 14), ta.highest(high - low, 20) * 0.5))

getAutoTargetStep(baseMajorStep) =>
    targetStep = nz(dailyRangeAnchor)
    math.max(baseMajorStep, targetStep)

getAnchoredMajorStep(targetStep, baseMajorStep) =>
    exponent = math.floor(math.log10(targetStep))
    float[] candidates = array.from(math.pow(10.0, exponent - 1), math.pow(10.0, exponent), math.pow(10.0, exponent + 1))
    bestStep = math.max(baseMajorStep, array.get(candidates, 0))
    bestDistance = math.abs(bestStep - targetStep)

    for i = 1 to array.size(candidates) - 1
        candidate = math.max(baseMajorStep, array.get(candidates, i))
        distance = math.abs(candidate - targetStep)

        if distance < bestDistance
            bestStep := candidate
            bestDistance := distance

    bestStep

getAutoMajorStep(baseMajorStep) =>
    overrideMajorStep = getOverrideMajorStep(baseMajorStep)

    if not na(overrideMajorStep)
        overrideMajorStep
    else
        targetStep = getAutoTargetStep(baseMajorStep)
        getAnchoredMajorStep(targetStep, baseMajorStep)

var float baseStep = syminfo.mintick
var line[] roundNumberLines = array.new<line>()

baseMajorStep = baseStep * 100
majorStep = getAutoMajorStep(baseMajorStep)
quarterStep = majorStep * 0.25

getTouchedLevel(targetLevelType) =>
    startIndex = int(math.ceil(low / quarterStep))
    endIndex = int(math.floor(high / quarterStep))
    index = startIndex
    checked = 0
    float touchedLevel = na

    while index <= endIndex and checked < 200
        quarterLevel = math.abs(index % 4)

        if targetLevelType == 0 and quarterLevel == 0
            touchedLevel := index * quarterStep
            break
        else if targetLevelType == 2 and quarterLevel == 2
            touchedLevel := index * quarterStep
            break
        else if targetLevelType == 1 and (quarterLevel == 1 or quarterLevel == 3)
            touchedLevel := index * quarterStep
            break

        index := index + 1
        checked := checked + 1

    touchedLevel

isTouchedAlert(alertMode, touchedLevel) =>
    (alertMode == "Touched" or alertMode == "Crossed") and not na(touchedLevel)

isTouchedAndClosedBeyondAlert(alertMode, touchedLevel) =>
    alertMode == "Crossed" and not na(touchedLevel) and not na(close[1]) and ((close[1] < touchedLevel and close > touchedLevel) or (close[1] > touchedLevel and close < touchedLevel))

handleLevelAlert(levelName, alertMode, touchedLevel) =>
    if (alertMode == "Touched" or alertMode == "Crossed") and not na(touchedLevel)
        alert(levelName + " touched at " + str.tostring(touchedLevel), alert.freq_once_per_bar)

    if isTouchedAndClosedBeyondAlert(alertMode, touchedLevel)
        closeSide = close > touchedLevel ? "above" : "below"
        alert(levelName + " crossed " + str.tostring(touchedLevel) + " and closed " + closeSide, alert.freq_once_per_bar_close)

roundTouchedLevel = getTouchedLevel(0)
halfTouchedLevel = getTouchedLevel(2)
quarterTouchedLevel = getTouchedLevel(1)

roundTouchedAlert = isTouchedAlert(roundNumbersRoundAlert, roundTouchedLevel)
halfTouchedAlert = isTouchedAlert(roundNumbersHalfAlert, halfTouchedLevel)
quarterTouchedAlert = isTouchedAlert(roundNumbersQuarterAlert, quarterTouchedLevel)

roundCloseBeyondAlert = isTouchedAndClosedBeyondAlert(roundNumbersRoundAlert, roundTouchedLevel)
halfCloseBeyondAlert = isTouchedAndClosedBeyondAlert(roundNumbersHalfAlert, halfTouchedLevel)
quarterCloseBeyondAlert = isTouchedAndClosedBeyondAlert(roundNumbersQuarterAlert, quarterTouchedLevel)

alertcondition(roundTouchedAlert, "Round number touched", "Price touched a round number level.")
alertcondition(halfTouchedAlert, "Half level touched", "Price touched a half level.")
alertcondition(quarterTouchedAlert, "Quarter level touched", "Price touched a quarter level.")
alertcondition(roundCloseBeyondAlert, "Round number touched and closed beyond", "Price touched a round number level and closed beyond it.")
alertcondition(halfCloseBeyondAlert, "Half level touched and closed beyond", "Price touched a half level and closed beyond it.")
alertcondition(quarterCloseBeyondAlert, "Quarter level touched and closed beyond", "Price touched a quarter level and closed beyond it.")

handleLevelAlert("Round number", roundNumbersRoundAlert, roundTouchedLevel)
handleLevelAlert("Half level", roundNumbersHalfAlert, halfTouchedLevel)
handleLevelAlert("Quarter level", roundNumbersQuarterAlert, quarterTouchedLevel)

if barstate.islast
    startIndex = int(math.round(close / quarterStep)) - roundNumbersVisibleLevels
    endIndex = startIndex + roundNumbersVisibleLevels * 2

    while roundNumberLines.size() > 0
        roundNumberLines.pop().delete()

    index = startIndex
    x1 = na(bar_index[1]) ? bar_index : bar_index[1]

    while index <= endIndex
        quarterLevel = math.abs(index % 4)
        levelPrice = index * quarterStep

        show = roundNumbersRoundDisplay
        width = 2
        lineColor = roundNumbersRoundColor
        lineStyle = getLineStyle(roundNumbersRoundStyle)

        if quarterLevel != 0
            show := roundNumbersHalfDisplay
            width := 1
            lineColor := roundNumbersHalfColor
            lineStyle := getLineStyle(roundNumbersHalfStyle)

        if quarterLevel == 1 or quarterLevel == 3
            show := roundNumbersQuarterDisplay
            lineColor := roundNumbersQuarterColor
            lineStyle := getLineStyle(roundNumbersQuarterStyle)

        if show
            roundNumberLines.push(line.new(x1, levelPrice, bar_index, levelPrice, color=lineColor, width=width, extend=extend.both, style=lineStyle))

        index := index + 1
````

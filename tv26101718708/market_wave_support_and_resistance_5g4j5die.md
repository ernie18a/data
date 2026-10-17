# Market Wave Support and Resistance

- url: https://www.tradingview.com/script/5G4j5dIE-Market-Wave-Support-and-Resistance/
- type: indicator
- pine_id: PUB;014c0b4f72b04db4805dea631613544f
- version: 1.0

## Description

You can add all the level which is shared every morning by mentors on Market Wave discord channel

## Source Code

````pine
//@version=5
indicator("Wave Support and Resistance Pro", overlay=true, max_lines_count=300, max_labels_count=300)

// AUTO SYMBOL DETECTION
symbolName = syminfo.ticker

// SETTINGS
levelsText = input.string("332,338,341,345,348,353,360,364,370,374,378,385,390,400,405,415,428,431,434,440,445,450,454,465,476,488", "Support / Resistance Levels")
keyLevel = input.float(423, "Key Level (0 = none)")

regularColor = input.color(color.gray, "Regular Level Color")
keyColor = input.color(color.yellow, "Key Level Color")
labelTextColor = input.color(color.white, "Label Text Color")
labelBgColor = input.color(color.black, "Label Background Color")

regularWidth = input.int(1, "Regular Width", minval=1, maxval=5)
keyWidth = input.int(3, "Key Width", minval=1, maxval=5)
showLabels = input.bool(true, "Show Labels")

// ALERT SETTINGS
enableAlerts = input.bool(true, "Enable Custom Alerts")
alertLevelsText = input.string("400,423,450", "Custom Alert Levels")
alertType = input.string("Touch Either Side", "Alert Type", options=["Cross Above", "Cross Below", "Touch Either Side"])

// STORAGE
var line[] linesArr = array.new_line()
var label[] labelsArr = array.new_label()
var string prevLevels = ""
var float prevKey = 0.0
var bool initialized = false

needsRefresh = not initialized or levelsText != prevLevels or keyLevel != prevKey

if needsRefresh
    if array.size(linesArr) > 0
        for i = 0 to array.size(linesArr) - 1
            line.delete(array.get(linesArr, i))
        array.clear(linesArr)

    if array.size(labelsArr) > 0
        for i = 0 to array.size(labelsArr) - 1
            label.delete(array.get(labelsArr, i))
        array.clear(labelsArr)

    levelArray = str.split(levelsText, ",")
    foundKey = false

    for i = 0 to array.size(levelArray) - 1
        txt = str.trim(array.get(levelArray, i))
        lvl = str.tonumber(txt)

        if not na(lvl)
            isKey = keyLevel > 0 and math.abs(lvl - keyLevel) <= syminfo.mintick

            if isKey
                foundKey := true

            clr = isKey ? keyColor : regularColor
            wid = isKey ? keyWidth : regularWidth
            labelTxt = isKey ? symbolName + " KEY " + str.tostring(lvl) : symbolName + " " + str.tostring(lvl)

            ln = line.new(bar_index, lvl, bar_index + 1, lvl, extend=extend.both, color=clr, width=wid)
            array.push(linesArr, ln)

            if showLabels
                lb = label.new(bar_index, lvl, text=labelTxt, style=label.style_label_left, color=labelBgColor, textcolor=labelTextColor, size=size.small)
                array.push(labelsArr, lb)

    if not foundKey and keyLevel > 0
        keyLn = line.new(bar_index, keyLevel, bar_index + 1, keyLevel, extend=extend.both, color=keyColor, width=keyWidth)
        array.push(linesArr, keyLn)

        if showLabels
            keyLb = label.new(bar_index, keyLevel, text=symbolName + " KEY " + str.tostring(keyLevel), style=label.style_label_left, color=labelBgColor, textcolor=labelTextColor, size=size.normal)
            array.push(labelsArr, keyLb)

    prevLevels := levelsText
    prevKey := keyLevel
    initialized := true

// MULTIPLE CUSTOM ALERTS
alertArray = str.split(alertLevelsText, ",")

if enableAlerts
    for i = 0 to array.size(alertArray) - 1
        alertTxt = str.trim(array.get(alertArray, i))
        alertLvl = str.tonumber(alertTxt)

        if not na(alertLvl)
            crossAbove = ta.crossover(close, alertLvl)
            crossBelow = ta.crossunder(close, alertLvl)
            touchLevel = high >= alertLvl and low <= alertLvl

            trigger = alertType == "Cross Above" ? crossAbove : alertType == "Cross Below" ? crossBelow : touchLevel

            if trigger
                msg = alertType == "Cross Above" ? symbolName + " crossed ABOVE " + str.tostring(alertLvl) : alertType == "Cross Below" ? symbolName + " crossed BELOW " + str.tostring(alertLvl) : symbolName + " touched " + str.tostring(alertLvl)
                alert(msg, alert.freq_once_per_bar)
````

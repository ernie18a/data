# Tokyo \ London  Sessions High \ Low

- url: https://www.tradingview.com/script/xFvFBpdw-Tokyo-London-Sessions-High-Low/
- type: indicator
- pine_id: PUB;dacd9c915ad34ef9936f1958e5d47752
- version: 1.0

## Description

the high and low of Tokyo sessions and London sessions prior to the opening of New York

## Source Code

````pine
//@version=6
indicator("Tokyo London Live Session High Low", overlay=true, max_lines_count=100, max_labels_count=100)

// Tokyo
showTokyo = input.bool(true, "Show Tokyo")
tokyoSession = input.session("0900-1500", "Tokyo Session")
tokyoTZ = input.string("Asia/Tokyo", "Tokyo Timezone")
tokyoHighColor = input.color(color.rgb(41,121,255), "Tokyo High")   // أزرق
tokyoLowColor  = input.color(color.rgb(97,255,255), "Tokyo Low")    // سماوي

// London
showLondon = input.bool(true, "Show London")
londonSession = input.session("0830-1430", "London Session")
londonTZ = input.string("Europe/London", "London Timezone")
londonHighColor = input.color(color.rgb(255,179,0), "London High")  // برتقالي
londonLowColor  = input.color(color.rgb(255,235,59), "London Low")  // أصفر

// Style
lineWidth  = input.int(1, "Line Width", minval=1, maxval=5)
extendBars = input.int(45, "Extend Right Bars", minval=1)
styleInput = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"])

showLabels = input.bool(true, "Show Labels")

lineStyle = styleInput == "Solid" ? line.style_solid :
     styleInput == "Dashed" ? line.style_dashed :
     line.style_dotted

f_session(_show, _session, _tz, _highColor, _lowColor, _highText, _lowText) =>
    inSession = _show and not na(time(timeframe.period, _session, _tz))
    startSession = inSession and not inSession[1]

    var float sessHigh = na
    var float sessLow = na
    var int highIndex = na
    var int lowIndex = na

    var line highLine = na
    var line lowLine = na

    var label highLabel = na
    var label lowLabel = na

    if startSession
        if not na(highLine)
            line.delete(highLine)
        if not na(lowLine)
            line.delete(lowLine)
        if not na(highLabel)
            label.delete(highLabel)
        if not na(lowLabel)
            label.delete(lowLabel)

        sessHigh := high
        sessLow := low
        highIndex := bar_index
        lowIndex := bar_index

        highLine := line.new(
             highIndex, sessHigh,
             bar_index + extendBars, sessHigh,
             color=_highColor,
             width=lineWidth,
             style=lineStyle
        )

        lowLine := line.new(
             lowIndex, sessLow,
             bar_index + extendBars, sessLow,
             color=_lowColor,
             width=lineWidth,
             style=lineStyle
        )

        if showLabels
            highLabel := label.new(
                 bar_index + extendBars, sessHigh,
                 _highText,
                 style=label.style_none,
                 textcolor=_highColor,
                 size=size.small
            )

            lowLabel := label.new(
                 bar_index + extendBars, sessLow,
                 _lowText,
                 style=label.style_none,
                 textcolor=_lowColor,
                 size=size.small
            )

    if inSession
        if high > sessHigh
            sessHigh := high
            highIndex := bar_index

        if low < sessLow
            sessLow := low
            lowIndex := bar_index

        if not na(highLine)
            line.set_x1(highLine, highIndex)
            line.set_y1(highLine, sessHigh)
            line.set_y2(highLine, sessHigh)
            line.set_x2(highLine, bar_index + extendBars)

        if not na(lowLine)
            line.set_x1(lowLine, lowIndex)
            line.set_y1(lowLine, sessLow)
            line.set_y2(lowLine, sessLow)
            line.set_x2(lowLine, bar_index + extendBars)

        if showLabels
            if not na(highLabel)
                label.set_xy(highLabel, bar_index + extendBars, sessHigh)
            if not na(lowLabel)
                label.set_xy(lowLabel, bar_index + extendBars, sessLow)

    if not inSession
        if not na(highLine)
            line.set_x2(highLine, bar_index + extendBars)
        if not na(lowLine)
            line.set_x2(lowLine, bar_index + extendBars)

        if showLabels
            if not na(highLabel)
                label.set_xy(highLabel, bar_index + extendBars, sessHigh)
            if not na(lowLabel)
                label.set_xy(lowLabel, bar_index + extendBars, sessLow)

f_session(showTokyo, tokyoSession, tokyoTZ, tokyoHighColor, tokyoLowColor, "TH", "TL")
f_session(showLondon, londonSession, londonTZ, londonHighColor, londonLowColor, "LH", "LL")
````

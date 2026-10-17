# FX Round Levels

- url: https://www.tradingview.com/script/VFn3sZan-FX-Round-Levels/
- type: indicator
- pine_id: PUB;84c289435dbb453497e678018b794f35
- version: 1.0

## Description

FX Round Levels — 整数位水平线

自动在图表上绘制心理价位（整数位）和中间位水平线，适用于外汇、指数、加密货币等所有品种。

功能特点

整数位（xx.00）：自动计算并显示当前价格附近的整数关口
中间位（xx.50）：可选显示整数位中间的半数关口
重要整数位高亮：自动识别 xxx000 / xxx500 等关键整百/整五百位，以不同颜色突出显示
价格标签：每条线旁显示精确价格，偏移量可调
全品种自适应：自动检测小数位数，兼容所有货币对及品种
完整自定义：颜色、线宽、线型（实线/虚线/点线）均可独立设置
显示数量可控：默认显示当前价格上下各 15 条，最多支持 200 条
适用场景：支撑/阻力分析、关键价位识别、价格区间参考

--------------------------------------------------------------
English Version
FX Round Levels — Psychological Price Levels

Automatically plots round number levels and mid-point levels on your chart. Works on any instrument — Forex, indices, crypto, commodities.

Features

Round levels (xx.00): Auto-calculated whole-number price levels around current price
Mid levels (xx.50): Optional half-figure levels between round numbers
Significant level highlight: Distinguishes major levels (xxx000 / xxx500) with a separate color
Price labels: Precise price tag beside each line, with adjustable offset
Universal compatibility: Auto-detects decimal places, works on any symbol and timeframe
Full customization: Independent color, width, and style (Solid / Dashed / Dotted) for round and mid levels
Adjustable count: Default ±15 levels around price, up to 200 total
Use case: Support/resistance analysis, key price identification, range reference

## Source Code

````pine
//@version=6
indicator("FX Round Levels", overlay=true, max_lines_count=500, max_labels_count=500)

//=========================
// Input arguments
//=========================
roundLevelColor       = input.color(color.rgb(105, 105, 105), "整数位线颜色 (00)")
significantLevelColor = input.color(color.silver, "重要整数位颜色")
midLevelColor         = input.color(color.rgb(105, 105, 105), "中间位线颜色 (50)")

roundLevelWidth       = input.int(1, "整数位线宽", minval=1, maxval=5)
midLevelWidth         = input.int(1, "中间位线宽", minval=1, maxval=5)

roundLevelStyleInput  = input.string("Dashed", "整数位线样式", options=["Solid", "Dashed", "Dotted"])
midLevelStyleInput    = input.string("Dashed", "中间位线样式", options=["Solid", "Dashed", "Dotted"])

showLabels            = input.bool(true, "显示价格标签")
showRoundLevels       = input.bool(true, "显示整数位")
showMidLevels         = input.bool(false, "显示中间位")
levelsToShow          = input.int(30, "显示的水平线数量", minval=1, maxval=200)
labelOffsetBars       = input.int(5, "标签偏移(K线数)", minval=1, maxval=100)
highlightSignificant  = input.bool(false, "高亮重要整数位(xxx000 / xxx500)")

//=========================
// Styling
//=========================
f_line_style(styleStr) =>
    result = line.style_dashed
    if styleStr == "Solid"
        result := line.style_solid
    else if styleStr == "Dotted"
        result := line.style_dotted
    else
        result := line.style_dashed
    result

roundLevelStyle = f_line_style(roundLevelStyleInput)
midLevelStyle   = f_line_style(midLevelStyleInput)

//=========================
// Calcuate digits
//=========================
f_digits_from_mintick() =>
    mt = syminfo.mintick
    d = 0
    v = mt
    for i = 0 to 10
        if math.abs(v - math.round(v)) < 0.0000001
            d := i
            break
        v := v * 10
    d

digits = f_digits_from_mintick()
multiplier = math.pow(10, digits)
roundLevelDivisor = 100.0

//=========================
// Tools
//=========================
f_price_to_string(price) =>
    str.tostring(price, format.mintick)

f_scaled_int_string(price) =>
    str.tostring(int(math.round(price * multiplier)))

f_is_significant_level(price) =>
    scaledStr = f_scaled_int_string(price)
    len = str.length(scaledStr)
    lastThree = len >= 3 ? str.substring(scaledStr, len - 3, len) : scaledStr
    lastThree == "000" or lastThree == "500"

f_level_color(price, isRound) =>
    c = roundLevelColor
    if not isRound
        c := midLevelColor
    else
        if highlightSignificant and f_is_significant_level(price)
            c := significantLevelColor
        else
            c := roundLevelColor
    c

f_level_width(isRound) =>
    isRound ? roundLevelWidth : midLevelWidth

f_level_style(isRound) =>
    isRound ? roundLevelStyle : midLevelStyle

//=========================
// Store objects
//=========================
var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()

f_clear_objects() =>
    linesCount = array.size(levelLines)
    if linesCount > 0
        for i = 0 to linesCount - 1
            ln = array.get(levelLines, i)
            line.delete(ln)
    array.clear(levelLines)

    labelsCount = array.size(levelLabels)
    if labelsCount > 0
        for i = 0 to labelsCount - 1
            lb = array.get(levelLabels, i)
            label.delete(lb)
    array.clear(levelLabels)

//=========================
// Draw lines
//=========================
f_draw_level(price, isRound) =>
    c = f_level_color(price, isRound)
    w = f_level_width(isRound)
    s = f_level_style(isRound)

    l = line.new(
         bar_index - 500,
         price,
         bar_index + 500,
         price,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = c,
         style = s,
         width = w
     )
    array.push(levelLines, l)

    if showLabels
        lb = label.new(
             bar_index + labelOffsetBars,
             price,
             text = f_price_to_string(price),
             xloc = xloc.bar_index,
             style = label.style_none,
             textcolor = c,
             size = size.small
         )
        array.push(levelLabels, lb)

//=========================
// Main
//=========================
if barstate.islast
    f_clear_objects()

    currentPrice = close
    scaledPrice = currentPrice * multiplier
    roundedDown = math.floor(scaledPrice / roundLevelDivisor) * roundLevelDivisor
    halfLevels = int(math.floor(levelsToShow / 2))

    for i = -halfLevels to halfLevels
        roundLevel = (roundedDown + i * roundLevelDivisor) / multiplier
        midLevel = roundLevel + (roundLevelDivisor / 2.0) / multiplier

        if showRoundLevels
            f_draw_level(roundLevel, true)

        if showMidLevels
            f_draw_level(midLevel, false)
````

# TSF Highest Volume

- url: https://www.tradingview.com/script/w4mDIxFM-TSF-Highest-Volume/
- type: indicator
- pine_id: PUB;887446bc62674a4e806d0db3d76e57d8
- version: 1.0

## Description

TSF Highest Volume

TSF Highest Volume labels the up days on which a stock trades its heaviest volume: the highest ever, the highest since its IPO, or the highest in one year. Each label shows the dollar volume of that day, and a price line marks the close of the most recent one. It works on daily, weekly and monthly charts.

WHAT IT SHOWS
- HVE: an up day with more volume than every earlier bar on the chart, IPO day included.
- HVIPO: an up day with more volume than every earlier bar except the IPO day. This works for stocks that listed less than a year ago.
- HV1: an up day with more volume than every bar of the prior year (250 daily, 52 weekly or 12 monthly bars).
- Dollar volume: the bar's volume multiplied by its close, shown under the tag.
- Price line: a horizontal line at the closing price of the most recent labelled bar. Only the latest one is drawn.

Only one label is shown per bar, in this order: HVE, then HVIPO, then HV1. An up day is a bar that closes above the prior bar's close. Record volume on a down day gets no label, but it still counts as the level a later up day has to beat.

HOW TO USE IT
Use the labels to spot the days when demand for a stock was at its heaviest, and the line to see where price stands against the close of the latest one. The labels and the line describe what happened. They are not buy or sell signals. A label on the current bar is final once the bar closes.

The IPO day is taken to be the first bar on the chart, and no HVE or HVIPO label is drawn during a stock's first 20 bars. This is the implementation used in The Setup Factory's own tools, published as one fixed standard. All rules it applies are stated above.

## Source Code

````pine
//@version=6
indicator("TSF Highest Volume", shorttitle = "TSF HV", overlay = true, max_labels_count = 500)

// ── Inputs ──────────────────────────────────────────────────────────────────
showHVE    = input.bool(true, "Label: highest volume ever (HVE)")
showHVIPO  = input.bool(true, "Label: highest volume since IPO (HVIPO)")
showHV1    = input.bool(true, "Label: highest volume in one year (HV1)")
showDollar = input.bool(true, "Show the dollar volume of that bar")
showLine   = input.bool(true, "Price line at the close of the latest labelled bar")
labelCol   = input.color(#F56E0F, "Label and line colour")

// ── Fixed values ────────────────────────────────────────────────────────────
LABEL_GAP = 1.0      // distance of the label above the candle's high, in ATRs
MIN_BARS  = 20       // no HVE or HVIPO label during the first 20 bars of a stock's history
IPO_BARS  = 1        // the first bar of the history is treated as the IPO day

// One year on the chart's timeframe: 250 daily bars, 52 weekly bars, 12 monthly bars
yearLen = timeframe.isweekly ? 52 : timeframe.ismonthly ? 12 : 250

// Labels are only drawn on daily, weekly and monthly charts
isDWM = timeframe.isdwm

// ── Highest volume of all bars BEFORE this one, IPO day included ────────────
var float maxEver = na
maxEverBefore = maxEver
maxEver := na(maxEver) ? volume : math.max(maxEver, volume)

// ── Highest volume of all bars before this one, leaving out the IPO day ─────
var float maxSinceIpo = na
maxSinceIpoBefore = maxSinceIpo
if bar_index >= IPO_BARS
    maxSinceIpo := na(maxSinceIpo) ? volume : math.max(maxSinceIpo, volume)

// ── Highest volume of the prior one year of bars ────────────────────────────
maxYearBefore = ta.highest(volume, yearLen)[1]

// An up day: the bar closed above the prior bar's close
isUpDay = close > close[1]

// 1) HVE: an up day whose volume is above every earlier bar, IPO day included
isHVE = isDWM and isUpDay and bar_index >= MIN_BARS and volume > maxEverBefore

// 3) HVIPO: an up day whose volume is above every earlier bar except the IPO day.
//    It does not need a year of history. It is not shown when the bar is already an HVE.
isHVIPO = isDWM and isUpDay and bar_index >= MIN_BARS and not isHVE
     and not na(maxSinceIpoBefore) and volume > maxSinceIpoBefore

// 2) HV1: an up day whose volume is above every bar of the prior year.
//    It is not shown when the bar is already an HVE or an HVIPO.
isHV1 = isDWM and isUpDay and bar_index >= yearLen and volume > maxYearBefore and not isHVE and not isHVIPO

// ── Dollar volume of the bar: volume x close ────────────────────────────────
dollarVol = volume * close

money(float x) =>
    x >= 1e9 ? "$" + str.tostring(x / 1e9, "#.00") + "B" :
     x >= 1e6 ? "$" + str.tostring(x / 1e6, "#.0") + "M" :
     "$" + str.tostring(x / 1e3, "#") + "K"

// ── Label above the candle, and one price line at the latest labelled bar's close ──
atr14 = ta.atr(14)
var line hvLine = na

if (isHVE and showHVE) or (isHVIPO and showHVIPO) or (isHV1 and showHV1)
    string tag = isHVE ? "HVE" : isHVIPO ? "HVIPO" : "HV1"
    string txt = showDollar ? tag + "\n" + money(dollarVol) : tag
    label.new(bar_index, high + LABEL_GAP * atr14, txt, yloc = yloc.price, style = label.style_label_down,
         color = labelCol, textcolor = color.white, size = size.normal)

    if showLine
        // Remove the line of the previous labelled bar, then draw one from this bar's close to the right edge
        line.delete(hvLine)
        hvLine := line.new(bar_index, close, bar_index + 1, close, extend = extend.right, color = labelCol, width = 1)

// ── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(isHVE,   "Highest volume ever on an up day",        "An up day with the highest volume in the chart's history")
alertcondition(isHVIPO, "Highest volume since IPO on an up day",   "An up day with the highest volume since the IPO day")
alertcondition(isHV1,   "Highest volume in one year on an up day", "An up day with the highest volume of the past year")
````

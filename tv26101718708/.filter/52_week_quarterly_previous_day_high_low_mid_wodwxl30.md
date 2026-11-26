# 52 Week Quarterly Previous Day High Low Mid

- url: https://www.tradingview.com/script/wodWxl30-52-Week-Quarterly-Previous-Day-High-Low-Mid/
- type: indicator
- pine_id: PUB;82a78aff34604c69b55964eebf9e8945
- version: 1.0

## Description

[b]52-Week High/Low, Quarterly High/Low (13-Week) & Previous Day High / Low / Mid[/b]

**A clean, all-in-one context indicator combining intraday reference levels and long-term high/low structure — built for traders who want key levels without cluttering the chart.**

---

🔹 [b]What It Plots[/b]

1. [b]Previous Day High / Low / Mid[/b]
Draws live, auto-updating horizontal lines at the prior trading day's high, low, and midpoint. These lines extend in real time as the current session develops, giving you an instant read on where price stands relative to yesterday's range — a level watched closely by intraday and swing traders alike for breakout, reversal, and mean-reversion setups.


2. [b]52-Week High / Low[/b]
Calculated from weekly data, this plots the true 52-week high and low (1-year lookback) — a level closely followed for breakout confirmation, momentum screens, and macro trend context. Choose whether the calculation uses candle highs/lows or closing prices to match your preferred definition of "range."

3. [b]Quarterly High / Low (13-Week)[/b]
The same logic applied to a 13-week (one quarter) lookback, useful for spotting intermediate-term range breaks and consolidation zones that longer 52-week levels can miss.

4. [b]Smart Merged Labels[/b]
Instead of stacking overlapping "YH," "QH," "YL," "QL" tags on top of each other when the yearly and quarterly levels converge, the indicator automatically merges them into a single clean "YH/QH" or "YL/QL" label — keeping your chart readable even when the two timeframes align.

---

🔹 [b]Why Use It[/b]

Most traders juggle several separate indicators to track daily levels and long-term range context. This script consolidates all three into one lightweight overlay:

- ✅ Spot intraday breakouts against yesterday's range
- ✅ Identify major support/resistance from Yearly High/Low (52-week) and Quarterly High/Low (13-week) extremes
- ✅ Keep the chart clean with automatic label merging and full visibility toggles

---

🔹[b] Customization[/b]

Every component can be shown, hidden, or recolored independently:
- Toggle previous day High/Low/Mid colors
- Toggle Yearly and Quarterly High/Low visibility
- Choose High/Low vs. Close basis for the range calculations

---

🔹 [b]How to Use It[/b]

- Intraday traders: Watch for reactions and breakouts at the previous day's high/low/mid, especially during the first hour of the session.

- Swing traders/Position/breakout traders: Treat the 52-week and 13-week highs/lows as major structural levels; a decisive close beyond them often signals a shift in the dominant range.

---

*As with any tool, this indicator is designed to provide context, not standalone signals. Combine it with your own risk management and trade plan.*

## Source Code

````pine
//@version=6
indicator("Yearly Quarterly Previous Day High Low Mid", overlay=true, max_lines_count=500, max_labels_count=500)

// === Previous Day High/Low ===
prevDayGroup = "Previous Day HL Colors"
prevDayHighColor = input.color(color.blue, title="Previous Day High Color", group=prevDayGroup)
prevDayLowColor  = input.color(color.orange, title="Previous Day Low Color", group=prevDayGroup)
prevDayMidColor  = input.color(color.rgb(42, 44, 53), title="Previous Day Mid Color", group=prevDayGroup)

prevDayHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_on)
prevDayMid  = (prevDayHigh + prevDayLow) / 2

var line highLine = na
var line lowLine  = na
var line midLine  = na

// v6: int/float no longer implicitly casts to bool, so compare explicitly instead of `if isNewDay`
isNewDay = ta.change(time("D")) != 0

if isNewDay
    highLine := line.new(bar_index, prevDayHigh, bar_index, prevDayHigh, color=prevDayHighColor, width=1)
    lowLine  := line.new(bar_index, prevDayLow,  bar_index, prevDayLow,  color=prevDayLowColor,  width=1)
    midLine  := line.new(bar_index, prevDayMid,  bar_index, prevDayMid,  color=prevDayMidColor,  width=1)

if not na(highLine)
    line.set_x2(highLine, bar_index)
    line.set_x2(lowLine, bar_index)
    line.set_x2(midLine, bar_index)

/// === 52 Week High/Low ===
high_low_close = input.string(defval="Highs/Lows", title="Base 52 week values on candle:", options=["Highs/Lows", "Close"])

showYH = input.bool(true, title="Show Yearly High", group="High/Low Visibility")
showYL = input.bool(true, title="Show Yearly Low", group="High/Low Visibility")
showQH = input.bool(true, title="Show Quarterly High", group="High/Low Visibility")
showQL = input.bool(true, title="Show Quarterly Low", group="High/Low Visibility")

weekly_hh = request.security(syminfo.tickerid, "W", ta.highest(high, 52), lookahead=barmerge.lookahead_on)
weekly_ll = request.security(syminfo.tickerid, "W", ta.lowest(low, 52), lookahead=barmerge.lookahead_on)
weekly_hc = request.security(syminfo.tickerid, "W", ta.highest(close, 52), lookahead=barmerge.lookahead_on)
weekly_lc = request.security(syminfo.tickerid, "W", ta.lowest(close, 52), lookahead=barmerge.lookahead_on)

high_plot = high_low_close == "Highs/Lows" ? weekly_hh : weekly_hc
low_plot  = high_low_close == "Highs/Lows" ? weekly_ll : weekly_lc

plot(showYH ? high_plot : na, title="Yearly High", trackprice=true, color=color.orange, offset=-9999)
plot(showYL ? low_plot  : na, title="Yearly Low",  trackprice=true, color=color.orange, offset=-9999)

// === 13 Week High/Low (Quarterly) ===
quarterly_hh = request.security(syminfo.tickerid, "W", ta.highest(high, 13), lookahead=barmerge.lookahead_on)
quarterly_ll = request.security(syminfo.tickerid, "W", ta.lowest(low, 13), lookahead=barmerge.lookahead_on)
quarterly_hc = request.security(syminfo.tickerid, "W", ta.highest(close, 13), lookahead=barmerge.lookahead_on)
quarterly_lc = request.security(syminfo.tickerid, "W", ta.lowest(close, 13), lookahead=barmerge.lookahead_on)

quarterly_high_plot = high_low_close == "Highs/Lows" ? quarterly_hh : quarterly_hc
quarterly_low_plot  = high_low_close == "Highs/Lows" ? quarterly_ll : quarterly_lc

plot(showQH ? quarterly_high_plot : na, title="Quarterly High", trackprice=true, color=color.purple, offset=-9999)
plot(showQL ? quarterly_low_plot  : na, title="Quarterly Low", trackprice=true, color=color.purple, offset=-9999)

// === Combined High/Low Labels ===
var label yhLabel = na
var label ylLabel = na
var label qhLabel = na
var label qlLabel = na

if barstate.islast
    // Delete previous labels
    if not na(yhLabel)
        label.delete(yhLabel)
    if not na(ylLabel)
        label.delete(ylLabel)
    if not na(qhLabel)
        label.delete(qhLabel)
    if not na(qlLabel)
        label.delete(qlLabel)

    priceRange = high - low
    tolerance = priceRange * 0.01

    // High Labels
    if showYH or showQH
        if showYH and showQH and math.abs(high_plot - quarterly_high_plot) <= tolerance
            yhLabel := label.new(bar_index, high_plot, "YH/QH", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)
        else
            if showYH
                yhLabel := label.new(bar_index, high_plot, "YH", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)
            if showQH
                qhLabel := label.new(bar_index, quarterly_high_plot, "QH", style=label.style_label_down, color=color.purple, textcolor=color.white, size=size.small)

    // Low Labels
    if showYL or showQL
        if showYL and showQL and math.abs(low_plot - quarterly_low_plot) <= tolerance
            ylLabel := label.new(bar_index, low_plot, "YL/QL", style=label.style_label_up, color=color.orange, textcolor=color.white, size=size.small)
        else
            if showYL
                ylLabel := label.new(bar_index, low_plot, "YL", style=label.style_label_up, color=color.orange, textcolor=color.white, size=size.small)
            if showQL
                qlLabel := label.new(bar_index, quarterly_low_plot, "QL", style=label.style_label_up, color=color.purple, textcolor=color.white, size=size.small)
````

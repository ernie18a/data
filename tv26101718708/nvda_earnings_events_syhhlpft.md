# NVDA Earnings Events 

- url: https://www.tradingview.com/script/SyhHLPfT-nvda-earnings-events/
- type: indicator
- pine_id: PUB;cdc8bf9059c74635bfe0401d5f4b2df0
- version: 1.0

## Description

M.D.S.
Самое важное для чарта:

Ты сейчас видишь:
— дату earnings
— какой был прошлый EPS
— какой вышел новый EPS.

И можешь визуально смотреть:
— как индекс реагировал на acceleration/deceleration earnings NVDA.

## Source Code

````pine
//@version=6
indicator("NVDA Earnings Events — Previous / Actual", overlay=true, max_labels_count=500, max_lines_count=500)

showLines  = input.bool(true, "Show black vertical lines")
showLabels = input.bool(true, "Show notes with data")

f_event(_time, _quarter, _prev, _actual, _above) =>
    inBar = time <= _time and time_close > _time

    if inBar
        if showLines
            line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.black, width=1, style=line.style_dashed)

        if showLabels
            txt = str.format("{0}\nNVDA Earnings\nPrevious: {1}\nActual: {2}", _quarter, _prev, _actual)

            label.new(
                 x=bar_index,
                 y=_above ? high : low,
                 text=txt,
                 xloc=xloc.bar_index,
                 yloc=_above ? yloc.abovebar : yloc.belowbar,
                 style=_above ? label.style_label_down : label.style_label_up,
                 color=color.black,
                 textcolor=color.white,
                 size=size.normal
            )

// ===== NVDA EARNINGS EVENTS =====
// Previous = прошлый EPS
// Actual = EPS, который вышел

f_event(timestamp("America/New_York", 2026, 02, 25, 16, 00), "Q4 FY2026", "1.24", "1.57", true)

f_event(timestamp("America/New_York", 2025, 11, 19, 16, 00), "Q3 FY2026", "0.99", "1.24", true)
f_event(timestamp("America/New_York", 2025, 08, 27, 16, 00), "Q2 FY2026", "0.77", "0.99", false)
f_event(timestamp("America/New_York", 2025, 05, 28, 16, 00), "Q1 FY2026", "0.85", "0.77", true)
f_event(timestamp("America/New_York", 2025, 02, 26, 16, 00), "Q4 FY2025", "0.78", "0.85", false)

f_event(timestamp("America/New_York", 2024, 11, 20, 16, 00), "Q3 FY2025", "0.65", "0.78", true)
f_event(timestamp("America/New_York", 2024, 08, 28, 16, 00), "Q2 FY2025", "0.58", "0.65", false)
f_event(timestamp("America/New_York", 2024, 05, 22, 16, 00), "Q1 FY2025", "0.49", "0.58", true)
f_event(timestamp("America/New_York", 2024, 02, 21, 16, 00), "Q4 FY2024", "0.38", "0.49", false)

f_event(timestamp("America/New_York", 2023, 11, 21, 16, 00), "Q3 FY2024", "0.25", "0.38", true)
f_event(timestamp("America/New_York", 2023, 08, 23, 16, 00), "Q2 FY2024", "0.09", "0.25", true)
f_event(timestamp("America/New_York", 2023, 05, 24, 16, 00), "Q1 FY2024", "0.06", "0.09", false)
f_event(timestamp("America/New_York", 2023, 02, 22, 16, 00), "Q4 FY2023", "0.03", "0.06", false)

f_event(timestamp("America/New_York", 2022, 11, 16, 16, 00), "Q3 FY2023", "0.03", "0.03", true)
f_event(timestamp("America/New_York", 2022, 08, 24, 16, 00), "Q2 FY2023", "0.12", "0.03", false)
f_event(timestamp("America/New_York", 2022, 05, 25, 16, 00), "Q1 FY2023", "0.11", "0.12", true)
f_event(timestamp("America/New_York", 2022, 02, 16, 16, 00), "Q4 FY2022", "0.10", "0.11", true)

f_event(timestamp("America/New_York", 2021, 11, 17, 16, 00), "Q3 FY2022", "0.09", "0.10", true)
f_event(timestamp("America/New_York", 2021, 08, 18, 16, 00), "Q2 FY2022", "0.08", "0.09", false)
f_event(timestamp("America/New_York", 2021, 05, 26, 16, 00), "Q1 FY2022", "0.06", "0.08", true)
f_event(timestamp("America/New_York", 2021, 02, 24, 16, 00), "Q4 FY2021", "0.05", "0.06", false)
````

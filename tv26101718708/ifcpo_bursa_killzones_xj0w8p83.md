# iFCPO Bursa Killzones

- url: https://www.tradingview.com/script/Xj0W8P83-iFCPO-Bursa-Killzones/
- type: indicator
- pine_id: PUB;7527c5e523494dcdaf3879c922ac0c78
- version: 1.0

## Description

iFCPO Bursa Killzones — AM/PM/Night session shading for FCPO traders.

FCPO sessions (Malaysia time):
- AM: 10:30-12:30
- Lunch: 12:30-14:30 (closed)
- PM: 14:30-18:00 ★ Edge Zone (research-confirmed)
- Night: 21:00-23:30

Background tints + session-open labels. Boolean outputs (in_AM/in_PM/in_Night/in_Lunch) chainable from other indicators.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Bursa Killzones — AM / PM / Night session shading (MYT)
// Tier: FREE | Category: Sessions
indicator("iFCPO Bursa Killzones", "iFCPO Sess", overlay = true)

show_am    = input.bool(true,  "Show AM session",    group = "Sessions")
show_pm    = input.bool(true,  "Show PM session",    group = "Sessions")
show_night = input.bool(true,  "Show Night session", group = "Sessions")
show_lunch = input.bool(true,  "Show Lunch (closed)", group = "Sessions")
show_label = input.bool(true,  "Show session labels", group = "Display")

am_color    = input.color(color.new(#3B82F6, 88), "AM color",    group = "Colors")
pm_color    = input.color(color.new(#1FC77E, 75), "PM Edge Zone color", group = "Colors")
night_color = input.color(color.new(#E0B544, 88), "Night color", group = "Colors")
lunch_color = input.color(color.new(#FF3B5C, 92), "Lunch (dimmed)", group = "Colors")

TZ = "Asia/Kuala_Lumpur"

in_am    = not na(time(timeframe.period, "1030-1230:23456", TZ))
in_pm    = not na(time(timeframe.period, "1430-1800:23456", TZ))
in_night = not na(time(timeframe.period, "2100-2330:23456", TZ))
in_lunch = not na(time(timeframe.period, "1230-1430:23456", TZ))

bgcolor(show_am    and in_am    ? am_color    : na, title = "AM bg")
bgcolor(show_pm    and in_pm    ? pm_color    : na, title = "PM bg")
bgcolor(show_night and in_night ? night_color : na, title = "Night bg")
bgcolor(show_lunch and in_lunch ? lunch_color : na, title = "Lunch bg")

am_open    = show_am    and in_am    and not in_am[1]
pm_open    = show_pm    and in_pm    and not in_pm[1]
night_open = show_night and in_night and not in_night[1]

if show_label
    if am_open
        label.new(bar_index, high, "AM 10:30",
           color = color.new(#3B82F6, 60), textcolor = color.white,
           style = label.style_label_down, size = size.tiny)
    if pm_open
        label.new(bar_index, high, "PM 14:30 ★ Edge Zone",
           color = color.new(#1FC77E, 30), textcolor = color.white,
           style = label.style_label_down, size = size.small)
    if night_open
        label.new(bar_index, high, "Night 21:00",
           color = color.new(#E0B544, 50), textcolor = color.black,
           style = label.style_label_down, size = size.tiny)

plot(in_am    ? 1 : 0, "in_AM",    display = display.data_window)
plot(in_pm    ? 1 : 0, "in_PM",    display = display.data_window)
plot(in_night ? 1 : 0, "in_Night", display = display.data_window)
plot(in_lunch ? 1 : 0, "in_Lunch", display = display.data_window)
````

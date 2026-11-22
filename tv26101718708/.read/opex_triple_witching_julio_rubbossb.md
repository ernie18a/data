# Opex + Triple Witching (Julio)

- url: https://www.tradingview.com/script/RUBbOSsb-Opex-Triple-Witching-Julio/
- type: indicator
- pine_id: PUB;2f172f5adb63415f83b4e721fc12c865
- version: 1.0

## Description

Triple Witching occurs on the third Friday of March, June, September, and December.Triple Witching occurs on the third Friday of March, June, September, and December. It's when three types of derivatives expire simultaneously: stock index futures, stock index options, and stock options. This causes elevated volume and volatility as traders roll or close positions.
OPEX (Options Expiration) is every other third Friday of the month — the ones that are NOT Triple Witching. These are standard monthly options expirations and also tend to see increased volatility and pinning behavior around key strikes as market makers hedge expiring contracts.

## Source Code

````pine
//@version=6
indicator("Opex + Triple Witching (Julio)", overlay=true)

// INPUTS
show_third_friday = input.bool(true, title="Show Third Friday?")
show_triple_witching = input.bool(true, title="Show Triple Witching?")
show_labels = input.bool(true, title="Show Labels?")

// Function to find the third Friday of a month
find_third_friday(y, m) =>
    first_day = timestamp(y, m, 1, 0, 0)
    first_day_weekday = dayofweek(first_day)
    days_to_first_friday = (6 - first_day_weekday + 7) % 7
    first_friday = first_day + days_to_first_friday * 86400000
    third_friday = first_friday + 14 * 86400000
    third_friday

// Define quarterly months
quarter_months = array.new_int(4)
array.set(quarter_months, 0, 3)
array.set(quarter_months, 1, 6)
array.set(quarter_months, 2, 9)
array.set(quarter_months, 3, 12)

// Check third Friday of current month
t_this_month = find_third_friday(year(time), month(time))
is_third_friday = dayofmonth(time) == dayofmonth(t_this_month) and month(time) == month(t_this_month) and year(time) == year(t_this_month)

// Check Triple Witching (third Friday of Mar/Jun/Sep/Dec)
is_triple_witching = false
for i = 0 to array.size(quarter_months) - 1
    m = array.get(quarter_months, i)
    t = find_third_friday(year(time), m)
    if dayofmonth(time) == dayofmonth(t) and month(time) == m and year(time) == year(t)
        is_triple_witching := true

// Background colors
bgcolor(show_triple_witching and is_triple_witching ? color.new(#2962ff, 70) : show_third_friday and is_third_friday ? color.new(color.green, 70) : na, title="Third Friday / Triple Witching")

// Labels at top of bar
if show_labels and barstate.isconfirmed
    if is_triple_witching and show_triple_witching
        label.new(x = bar_index, y = high, text = "TW", color = color.new(#2962ff, 100), textcolor = #2962ff, style = label.style_label_down, size = size.small)
    else if is_third_friday and show_third_friday
        label.new(x = bar_index, y = high, text = "OPEX", color = color.new(color.green, 100), textcolor = color.green, style = label.style_label_down, size = size.small)
````

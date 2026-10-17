# Price Momentum Oscillator

- url: https://www.tradingview.com/script/Us0lJDWN-Price-Momentum-Oscillator/
- type: indicator
- pine_id: PUB;b0158a7926ae45e5a103ef57e8a87ebb
- version: 1.0

## Description

This script implements a custom momentum oscillator.
It calculates the z-score of the price relative to its 1-year moving average and then measures the deviation of this z-score from its own 200-day moving average.

Enjoy

## Source Code

````pine
// This script implements a custom momentum oscillator.
// It calculates the z-score of the price relative to its 1-year moving average
// and then measures the deviation of this z-score from its own 200-day moving average.

//@version=6
indicator("Price Momentum Oscillator", shorttitle="PMO", overlay=false)

// --- DYNAMIC INPUTS ---
// Adjust MA and StDev lengths based on the chart's timeframe to maintain consistency (1 year and 200 days).
int len_long = switch
    timeframe.isdaily   => 365
    timeframe.isweekly  => 52  // Approx. 52 weeks in a year
    timeframe.ismonthly => 12  // 12 months in a year
    => 365                     // Intraday / Default fallback

int len_short = switch
    timeframe.isdaily   => 200
    timeframe.isweekly  => 29  // Approx. 200 days / 7 days/week
    timeframe.ismonthly => 7   // Approx. 200 days / 30.44 days/month
    => 200                     // Intraday / Default fallback


// --- CALCULATIONS ---
// 1. Calculate the 1-Year Simple Moving Average of the closing price.
price = close
ma_365 = ta.sma(price, len_long)

// 2. Calculate the 1-Year Standard Deviation of the closing price.
std_365 = ta.stdev(price, len_long)

// 3. Calculate the Z-Score using the formula.
// Z-Score = (Price - 1-Year MA) / 1-Year StDev
// We handle the case where stdev is zero to avoid division by zero errors.
z_score = std_365 > 0 ? (price - ma_365) / std_365 : 0

// 4. Invert the Z-Score.
inverted_z_score = -z_score

// 5. Calculate the SMA of the inverted Z-Score.
z_score_ma = ta.sma(inverted_z_score, len_short)

// 6. Calculate the final indicator value and invert its direction.
pmo_value = (inverted_z_score - z_score_ma) * -1


// --- PLOTTING ---
// Determine the color of the oscillator plot based on its value relative to zero.
// Green for positive values (buy/invested), Red for negative values (sell/exit).
color plot_color = pmo_value >= 0 ? color.green : color.red

// Plot the final value as an oscillator in its own pane.
plot(pmo_value, "PMO", color=plot_color, linewidth=2)

// Add a horizontal line at the zero level for easy reference.
hline(0, "Zero Line", color=color.new(color.white, 50), linestyle=hline.style_dashed)
````

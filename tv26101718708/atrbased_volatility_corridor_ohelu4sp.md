# ATR-based Volatility Corridor

- url: https://www.tradingview.com/script/ohElU4SP-ATR-based-Volatility-Corridor/
- type: indicator
- pine_id: PUB;2291ca3ff41946949da9b1450460a445
- version: 1.0

## Description

Shows a volatility corridor based on historical atr instead of IV, to draw upper and lower standard deviations for a given DTE

## Source Code

````pine
//@version=6
indicator("ATR-based Volatility Corridor", overlay=true)

atr_len = input.int(14, "ATR Periode")
dte = input.int(30, "Days to Expiration")
use_252 = input.bool(true, "√256 statt √365")

// ATR in annualisierte Volatilität umrechnen
atr_value = ta.atr(atr_len)
daily_vol_pct = (atr_value / close) * 100
annual_vol = daily_vol_pct * math.sqrt(use_252 ? 256 : 365.25)

// Expected Move Faktor
em_factor = (annual_vol / 100) * math.sqrt(dte / 365.25)

upper_1sd = close * (1 + em_factor)
lower_1sd = close * (1 - em_factor)
upper_2sd = close * (1 + 2 * em_factor)
lower_2sd = close * (1 - 2 * em_factor)

// Plots
plot(upper_1sd, "1SD Upper (ATR)", color=color.green, linewidth=2)
plot(lower_1sd, "1SD Lower (ATR)", color=color.green, linewidth=2)
plot(upper_2sd, "2SD Upper", color=color.red, linewidth=1, style=plot.style_linebr)
plot(lower_2sd, "2SD Lower", color=color.red, linewidth=1, style=plot.style_linebr)

// Info Label
var label info = label.new(bar_index, na, "", color=color.new(color.black, 80), style=label.style_label_left)
if barstate.islast
    label.set_xy(info, bar_index, upper_1sd)
    label.set_text(info, "ATR Vol (ann): " + str.tostring(annual_vol, "#.##") + "%\n1SD Move: " + str.tostring(em_factor*100, "#.##") + "%")
````

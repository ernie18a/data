# Trippel Stochastic Konfluens - June 20th 2026

- url: https://www.tradingview.com/script/f34TsfOz-Trippel-Stochastic-Konfluens-June-20th-2026/
- type: indicator
- pine_id: PUB;cbadb5bd90be47e5aebc987e8e13b0fd
- version: 1.0

## Description

This indicator plots three stochastics: 

1) Fast Stochastic - 8.5.5
2) Medium Stochastic - 21.5.5
3) Slow Stochastic - 55.8.8

This makes it easier to see when all three aligns in the "overbought" or "oversold" band on the Stochastic oscillator. 

Overbought: 80 and above.
Oversold: 20 and below. 

This should be used with other information, such as: support/resistance levels, moving averages, trend lines or swing highs and swing lows. 

Note: A stochastic rising on thin volumes into the 20 band indicates fewer sellers willing to sell at current price. 

Volumes drying up and tight price action in oversold or overbought areas should be regarded as areas of interest.

## Source Code

````pine
//@version=6
indicator(title="Trippel Stochastic Konfluens v6", shorttitle="3x Stoch", overlay=false)

// 1. Inställningar för den Snabba (8, 3, 3)
smoothK_1 = 3
smoothD_1 = 3
length_1 = 8
stoch_1 = ta.stoch(close, high, low, length_1)
k_1 = ta.sma(stoch_1, smoothK_1)
d_1 = ta.sma(k_1, smoothD_1)

// 2. Inställningar för Mellan (21, 5, 5)
smoothK_2 = 5
smoothD_2 = 5
length_2 = 21
stoch_2 = ta.stoch(close, high, low, length_2)
k_2 = ta.sma(stoch_2, smoothK_2)
d_2 = ta.sma(k_2, smoothD_2)

// 3. Inställningar för den Tröga (55, 8, 8)
smoothK_3 = 8
smoothD_3 = 8
length_3 = 55
stoch_3 = ta.stoch(close, high, low, length_3)
k_3 = ta.sma(stoch_3, smoothK_3)
d_3 = ta.sma(k_3, smoothD_3)

// Rita ut referenslinjer (Extrembanden 20 och 80)
hline(80, "Överköpt", color=color.gray, linestyle=hline.style_dashed)
hline(50, "Mittlinje", color=color.gray, linestyle=hline.style_dotted)
hline(20, "Översåld", color=color.gray, linestyle=hline.style_dashed)

// Rita ut linjerna i grafen
plot(k_1, title="Stoch Snabba (8)", color=color.green, linewidth=1)
plot(k_2, title="Stoch Mellan (21)", color=color.blue, linewidth=1)
plot(k_3, title="Stoch Tröga (55)", color=color.purple, linewidth=2)
````

# Daily High/Low Progressive

- url: https://www.tradingview.com/script/1ZrkEMEi-Daily-High-Low-Progressive/
- type: indicator
- pine_id: PUB;04d586d8b141403c907b6e1780f66441
- version: 1.0

## Description

Defines today's HIGH an LOW for daytraders
Can be used just like support and resistance levels
Trade opertunities are appearing when high or low levels are initially broken
and reversal trades are possible.

## Source Code

````pine
// © Gemini
//@version=6
indicator("Daily High/Low Progressive", overlay=true)

// Controleren of we op een nieuwe dag zijn gestart
is_new_day = ta.change(time("D")) != 0

// Variabelen initialiseren
var float daily_high = na
var float daily_low = na

// Logica voor het bijhouden van de high en low
if is_new_day
    daily_high := high
    daily_low := low
else
    daily_high := math.max(high, daily_high)
    daily_low := math.min(low, daily_low)

// Plotten van de lijnen
// 'style=plot.style_stepline' zorgt ervoor dat je de verschuivingen (het progressieve) goed ziet
plot(daily_high, color=color.new(color.red, 0), linewidth=2, title="Today's High", style=plot.style_stepline)
plot(daily_low, color=color.new(color.green, 0), linewidth=2, title="Today's Low", style=plot.style_stepline)

// Optioneel: Achtergrondkleur bij nieuwe dag
bgcolor(is_new_day ? color.new(color.gray, 90) : na)
````

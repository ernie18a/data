# Sen Line Break Bar Trigger

- url: https://www.tradingview.com/script/FVnkXBOi-Sen-Line-Break-Bar-Trigger/
- type: indicator
- pine_id: PUB;37fef0c7e6e648dbb1d35a07de060e47
- version: 1.0

## Description

Triggers an alert whenever a new bar is formed in LineBreak chart

## Source Code

````pine
//@version=6
indicator("Sen Line Break Bar Trigger", overlay=true)

if ta.change(time) > 0
    alert("New Line Break bar formed!", alert.freq_once_per_bar)
````

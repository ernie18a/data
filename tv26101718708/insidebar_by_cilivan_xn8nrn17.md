# inside_bar (by cilivan)

- url: https://www.tradingview.com/script/xN8nrN17-inside-bar-by-cilivan/
- type: indicator
- pine_id: PUB;M9GP352i3zL5VsEI46hcDwya4XolB00y
- version: 1.0

## Description

Simple script for coloring inside bars to spot them easier (color can be adjusted)

## Source Code

````pine
//@version=3
study("inside_bar", overlay=true)

range = high - low

insideBar() => high <= high[1] and low >= low[1] ? 1 : 0

barColor = #ffffff

barcolor(insideBar() ? barColor : na )
````

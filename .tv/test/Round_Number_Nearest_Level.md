<!-- tradingview-pine-id: PUB;ffc37b37bc7a469c9dd80766c804e053 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Round Number Nearest Level

Source: https://www.tradingview.com/script/eXVH2IfA-Round-Number-Nearest-Level/

## Description

Round Number Nearest Level is a simple visual reminder of the round-number price level nearest to the current market price.

During fast-moving trading sessions, it is easy to focus on entries, exits, volume, and momentum while overlooking an approaching round number. This can be especially challenging for newer traders. Round-number prices often attract attention and may act as potential support, resistance, targets, or areas of increased activity.

The indicator keeps the chart uncluttered by displaying only the nearest level. As the price moves, the plotted line automatically steps to the next closest round number.

HOW IT WORKS

Automatic mode selects the interval based on the current price:

• Below $5: nearest $0.50 level  
• $5 and above: nearest $1.00 level

Custom mode allows you to define your own multiplier. For example, a multiplier of 5 plots the nearest $5 level, while a multiplier of 0.25 plots the nearest quarter-dollar level.

The level is displayed as an orange stepped line directly on the price chart.

This indicator is intended as a situational-awareness aid. Round-number levels are reference points, not guaranteed support or resistance, and should be considered alongside price action, volume, risk management, and your broader trading plan.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GapLogic

//@version=6
indicator("Round Number Nearest Level", shorttitle = "RNRL", overlay = true)

var const string VERSION = "1.0.0"
var string versionInput = input.string(VERSION, title = "Version", options = [VERSION], group = "General")

enum LevelMode
    Automatic
    Custom

LevelMode modeInput = input.enum(
     LevelMode.Automatic,
     title = "Mode",
     tooltip = "Automatic uses $0.50 levels below $5 and $1.00 levels at $5 and above.")

float multiplierInput = input.float(
     1.0,
     title = "Multiplier",
     minval = 0.000001,
     step = 0.5,
     tooltip = "In Custom mode, the line is drawn at the nearest multiple of this value.",
     active = modeInput == LevelMode.Custom)

float automaticMultiplier = close < 5.0 ? 0.5 : 1.0
float levelMultiplier = modeInput == LevelMode.Automatic ? automaticMultiplier : multiplierInput
float nearestLevel = math.round_to_mintick(math.round(close / levelMultiplier) * levelMultiplier)

plot(
     nearestLevel,
     title = "Nearest Round Number Level",
     color = color.new(color.orange, 50),
     style = plot.style_stepline)
````

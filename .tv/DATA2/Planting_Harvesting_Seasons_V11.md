<!-- tradingview-pine-id: PUB;8270d89cbc014595ab231cf95fbddf1e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Planting & Harvesting Seasons V1.1

Source: https://www.tradingview.com/script/f4JQtwee-Planting-Harvesting-Seasons-V1-1/

## Description

Overview

As a commodity trader, seasonal patterns play a big role in my analysis. This script visually overlays the typical planting and harvesting periods for key agricultural futures directly on the chart. It automatically detects the underlying commodity based on the symbol (e.g. ZC, ZW, ZS, CT) and displays color-coded zones for each seasonal window.

These zones are based on historical crop calendars and help identify when planting or harvesting typically takes place, so technical setups can be better aligned with fundamental seasonal factors.

How It Works

The script reads the chart's symbol root and matches it against a built-in table of crop development and harvest windows (month ranges) for supported futures. Two background zones are drawn:

Development (green) — the typical crop development/growing period
Harvest (red) — the typical harvest period
Labels mark the start and end of each zone as the chart crosses into or out of it. Month ranges that cross the calendar year boundary (e.g. harvest starting in one year and ending in the next) are handled correctly.

Supported Markets

Chicago Wheat (ZW), Corn (ZC), Soybeans (ZS), Rough Rice (ZR), Cotton (CT), Oats (ZO), Cocoa (CC), Coffee (KC), Sugar (SB), Orange Juice (OJ).

What This Script Does Not Do

This is a visual aid only — it does not generate buy or sell signals, does not predict price direction, and is not a standalone trading system. Crop calendars are based on typical/historical timing and can vary by growing region and year.

Limitations

Actual planting and harvest timing can shift from year to year due to weather, regional differences, and other agronomic factors. The zones shown are typical historical windows, not a forecast for the current season.

Changelog (V1.1)

Improved terminology inside the script (crop development and harvest phases)
Improved month-range handling for seasons that cross the calendar year boundary
Updated futures-relevant windows for ZC, CC, KC, SB and OJ

Feedback is always appreciated!

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DerAndi72
//
// Script: Planting & Harvesting Seasons
// Version: V1.1
// Release: Maintenance Update
//
// Changelog:
// V1.1 - Maintenance Update
// - Kept the established script name: Planting & Harvesting Seasons.
// - Improved terminology inside the script by using crop development and harvest phases.
// - Improved month range handling for year-crossing seasons.
// - Updated futures-relevant windows for ZC, CC, KC, SB and OJ.
//
// V1.0 - Initial Release
// - Initial public release as Planting & Harvesting Seasons.
// - Added basic crop planting and harvest background zones.


//@version=6
indicator("Planting & Harvesting Seasons V1.1", overlay = true)
// Dynamic future recognition
asset = syminfo.root

// Initialize season values
var int developmentStart = na
var int developmentEnd   = na
var int harvestStart     = na
var int harvestEnd       = na

// Helper function: supports normal and year-crossing month ranges
isMonthInRange(startMonth, endMonth) =>
    if na(startMonth) or na(endMonth)
        false
    else if startMonth > endMonth
        month >= startMonth or month <= endMonth
    else
        month >= startMonth and month <= endMonth

// Set futures-relevant crop development and harvest windows
// 1 = January, 12 = December
switch asset
    "ZW" => developmentStart := 9,  developmentEnd := 10, harvestStart := 6,  harvestEnd := 7
    "ZC" => developmentStart := 4,  developmentEnd := 5,  harvestStart := 9,  harvestEnd := 11
    "ZS" => developmentStart := 4,  developmentEnd := 6,  harvestStart := 9,  harvestEnd := 11
    "ZR" => developmentStart := 4,  developmentEnd := 6,  harvestStart := 8,  harvestEnd := 10
    "CT" => developmentStart := 4,  developmentEnd := 6,  harvestStart := 9,  harvestEnd := 11
    "ZO" => developmentStart := 4,  developmentEnd := 5,  harvestStart := 7,  harvestEnd := 8
    "CC" => developmentStart := 4,  developmentEnd := 9,  harvestStart := 10, harvestEnd := 3
    "KC" => developmentStart := 10, developmentEnd := 12, harvestStart := 5,  harvestEnd := 9
    "SB" => developmentStart := 1,  developmentEnd := 3,  harvestStart := 4,  harvestEnd := 11
    "OJ" => developmentStart := 3,  developmentEnd := 5,  harvestStart := 11, harvestEnd := 6

// Check whether current month is inside one of the defined seasons
developmentSeason = isMonthInRange(developmentStart, developmentEnd)
harvestSeason     = isMonthInRange(harvestStart, harvestEnd)

// Set background color
seasonColor = developmentSeason ? color.new(color.green, 60) : harvestSeason ? color.new(color.red, 60) : na
bgcolor(seasonColor)

// Dynamic label positioning
pos = ta.lowest(low, 10) - ta.atr(14) * 0.5

// Show labels for development season start and end
if developmentSeason and not developmentSeason[1]
    label.new(bar_index, pos, "Start Development", color = color.green, textcolor = color.white, style = label.style_label_down)

if not developmentSeason and developmentSeason[1]
    label.new(bar_index, pos, "End Development", color = color.green, textcolor = color.white, style = label.style_label_up)

// Show labels for harvest season start and end
if harvestSeason and not harvestSeason[1]
    label.new(bar_index, pos, "Start Harvest", color = color.red, textcolor = color.white, style = label.style_label_down)

if not harvestSeason and harvestSeason[1]
    label.new(bar_index, pos, "End Harvest", color = color.red, textcolor = color.white, style = label.style_label_up)
````

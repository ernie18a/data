<!-- tradingview-pine-id: PUB;449a067698804b128e1de6dff6e40390 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Book Value & Tangible Book Value

Source: https://www.tradingview.com/script/niG33CeK-Book-Value-Tangible-Book-Value/

## Description

Book Value & Tangible Book Value plots two reported quarterly figures side by side: total book value per share, and tangible book value per share, which is book value with goodwill and other intangibles removed.

Both series are drawn as stepped lines with a marker at each reported quarter, so you can see exactly when a value changed rather than an interpolated curve.

How to read it. The gap between the two lines is the share of equity that comes from intangibles. A wide and widening gap usually points to acquisitions, and it is the part of book value that a writedown can erase overnight. Compare the lines with price to see what multiple of book you are paying; price below tangible book value has historically drawn value investors, though it is often a sign of distress rather than a bargain. A falling tangible line while the total line holds up is a warning worth investigating.

Notes and limits. Values change only on new quarterly reports, so the lines are flat between filings. Book value is an accounting measure of historical cost, not market value, and it understates asset-light businesses while overstating companies carrying old assets or acquisition goodwill. It needs reported quarterly financials, so nothing plots on indices, forex, crypto, and most funds. It is most meaningful for banks, insurers and asset-heavy industrials, and least meaningful for software and services.

---

## Source Code

````pine
// Copyright (c) 2026 Cengiz Ilerler
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/. 
//
// Book Value & Tangible Book Value
// Plots reported book value per share and tangible book value per share as stepped series.

//@version=6
indicator("Book Value & Tangible Book Value", overlay=false)

// Pull actual reported quarterly balance sheet figures
bvps  = request.financial(syminfo.tickerid, "BOOK_VALUE_PER_SHARE", "FQ", ignore_invalid_symbol=true)
tbvps = request.financial(syminfo.tickerid, "BOOK_TANGIBLE_PER_SHARE", "FQ", ignore_invalid_symbol=true)

// Plot both lines on the same pane
plot(bvps, "Total Book Value / Share", color=color.aqua, linewidth=2, style=plot.style_stepline_diamond)
plot(tbvps, "Tangible Book Value / Share", color=color.orange, linewidth=2, style=plot.style_stepline_diamond)
````

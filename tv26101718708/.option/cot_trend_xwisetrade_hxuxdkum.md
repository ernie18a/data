# COT Trend [XWiseTrade]

- url: https://www.tradingview.com/script/HXuxDkUm-COT-Trend-XWiseTrade/
- type: indicator
- pine_id: PUB;be2f60bd4a8848be8f471261b5e2d8d3
- version: 1.0

## Description

Visualize institutional bias using Commitment of Traders (COT) data.

This indicator compares non-commercial net positions of the current symbol against the USD Index to automatically determine market bias:
• Green background = Speculators more long than USD → Bullish
• Red background = Speculators more short than USD → Bearish

Supported symbols: Major FX pairs, Gold, Silver, Oil, SPX, NDX.

Features:
• Weekly COT data via official LibraryCOT
• Clear background coloring
• Persistent bias label
• Works on any timeframe

Perfect for trend filtering and understanding "smart money" positioning.

More premium indicators and strategies coming soon at:
xwisetrade.com

Be Wise. Trade X.
Dec 22, 2025
Release Notes
Visualize institutional bias using Commitment of Traders (COT) data.

This indicator compares non-commercial net positions of the current symbol against the USD Index to automatically determine market bias:
• Green background = Speculators more long than USD → Bullish
• Red background = Speculators more short than USD → Bearish

Supported symbols: Major FX pairs, Gold, Silver, Oil, SPX, NDX.

Features:
• Weekly COT data via official LibraryCOT
• Clear background coloring
• Persistent bias label
• Works on any timeframe

Perfect for trend filtering and understanding "smart money" positioning.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zong_xu (adapted for XWiseTrade)

 //@version=6
import TradingView/LibraryCOT/2 as LibraryCOT
indicator("COT Trend [XWiseTrade]", overlay=true)

// === Map symbol to COT code ===
getCOTCode() =>
    switch syminfo.ticker
        "AUDUSD" => "232741"
        "EURUSD" => "099741"
        "GBPUSD" => "096741"
        "USDJPY" => "097741"
        "USDCAD" => "090741"
        "USDCHF" => "092741"
        "NZDUSD" => "112741"
        "XAUUSD" => "088691"
        "XAGUSD" => "084691"
        "USOIL" => "067651"
        "SPX"    => "138741"
        "NDX"    => "209742"
        => ""

// Fixed COT codes
string codeA = getCOTCode()          // Current symbol
string codeB = "098662"              // USD Index fixed code

// === Fetch Noncommercial Net Positions using LibraryCOT ===
dataSource      = "Legacy"
includeOptions  = false

longID_A  = LibraryCOT.COTTickerid(dataSource, codeA, includeOptions, "Noncommercial Positions", "Long",  "All")
shortID_A = LibraryCOT.COTTickerid(dataSource, codeA, includeOptions, "Noncommercial Positions", "Short", "All")
longID_B  = LibraryCOT.COTTickerid(dataSource, codeB, includeOptions, "Noncommercial Positions", "Long",  "All")
shortID_B = LibraryCOT.COTTickerid(dataSource, codeB, includeOptions, "Noncommercial Positions", "Short", "All")

var float longA  = na
var float shortA = na
var float longB  = na
var float shortB = na

if not na(codeA)
    longA  := request.security(longID_A,  "W", close, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    shortA := request.security(shortID_A, "W", close, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)

longB  := request.security(longID_B,  "W", close, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
shortB := request.security(shortID_B, "W", close, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)

// Calculate net positions
netA = na(longA) or na(shortA) ? na : longA - shortA
netB = na(longB) or na(shortB) ? na : longB - shortB

// Determine trend bias by comparing to USD Index
cotBias = na(codeA) or na(codeB) ? "Unknown" :
          na(netA) or na(netB)   ? "No Data" :
          netA > netB            ? "Long" :
          netA < netB            ? "Short" :
                                   "Neutral"

// === Background trend zones ===
showTrendBg = input.bool(true, "Show COT Trend Background", group="COT Trend Filter")
bgcolor(showTrendBg and cotBias == "Long"   ? color.new(color.green, 85) : na, title="COT Bullish Zone")
bgcolor(showTrendBg and cotBias == "Short"  ? color.new(color.red,   85) : na, title="COT Bearish Zone")

// === Trend label ===
var label trendLabel = na
if barstate.islast
    label.delete(trendLabel)
    trendLabel := label.new(
         bar_index, high, 
         text = "COT Bias: " + cotBias, 
         style = label.style_label_left, 
         color = color.rgb(255, 0, 0), 
         textcolor = color.white, 
         size = size.normal, 
         yloc = yloc.abovebar)
````

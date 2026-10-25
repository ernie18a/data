# TriQuote Anchor

- url: https://www.tradingview.com/script/3q6d62XZ-TriQuote-Anchor/
- type: indicator
- pine_id: PUB;8dab0b6cd87245b5a98eec3736afba8f
- version: 1.0

## Description

**TriQuote Anchor**

Display live quotes for any 3 tickers directly on your chart. Choose between a floating label anchored next to current price, or a fixed corner panel (top/middle/bottom right).

**Features:**
- 3 fully customizable ticker inputs (stocks, indices, futures, crypto, FX)
- Individual show/hide toggles per ticker
- Anchored-to-price mode follows the chart as it moves
- 4 display positions
- Adjustable font size, text color, background color
- Monospace formatting for clean alignment
- Bar-offset control for label distance from price

Perfect for traders who want to keep an eye on correlated symbols (e.g. SPY/QQQ/VIX, BTC/ETH/DXY, or any custom watchlist) without leaving the current chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jackTD25

//@version=5
indicator("TriQuote Anchor", overlay=true)

// --- Ticker Inputs ---
ticker1 = input.symbol("AMEX:SPY", "Ticker 1", group="Tickers")
ticker2 = input.symbol("SP:SPX",   "Ticker 2", group="Tickers")
ticker3 = input.symbol("CBOE:VIX", "Ticker 3", group="Tickers")

show1 = input.bool(true, "Show Ticker 1", group="Tickers")
show2 = input.bool(true, "Show Ticker 2", group="Tickers")
show3 = input.bool(true, "Show Ticker 3", group="Tickers")

// --- Display Inputs ---
displayPos = input.string("Anchored to Price", "Display Position", 
     options=["Anchored to Price", "Top Right", "Middle Right", "Bottom Right"],
     group="Layout Settings")

anchorOffset = input.int(2, "Price Anchor Offset (Bars)", minval=0, 
     group="Layout Settings")

textSizeInput = input.string("Small", "Font Size", 
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group="Styling")

textColor = input.color(color.white, "Text Color", group="Styling")
bgColor   = input.color(color.new(color.black, 40), "Background Color", group="Styling")

// --- Size Logic ---
fontSize = textSizeInput == "Tiny"   ? size.tiny   :
           textSizeInput == "Small"  ? size.small  :
           textSizeInput == "Normal" ? size.normal :
           textSizeInput == "Large"  ? size.large  :
                                       size.huge

// --- Helper: clean ticker name for display ---
cleanName(s) =>
    arr = str.split(s, ":")
    array.size(arr) > 1 ? array.get(arr, 1) : s

// --- Data Fetching ---
p1 = request.security(ticker1, timeframe.period, close, gaps=barmerge.gaps_off)
p2 = request.security(ticker2, timeframe.period, close, gaps=barmerge.gaps_off)
p3 = request.security(ticker3, timeframe.period, close, gaps=barmerge.gaps_off)

// --- Build Quote Text ---
quoteText = ""
if show1
    quoteText := cleanName(ticker1) + ": " + str.tostring(p1, "#.00")
if show2
    quoteText := (quoteText == "" ? "" : quoteText + "\n") + cleanName(ticker2) + ": " + str.tostring(p2, "#.00")
if show3
    quoteText := (quoteText == "" ? "" : quoteText + "\n") + cleanName(ticker3) + ": " + str.tostring(p3, "#.00")

if quoteText == ""
    quoteText := "—"

// Always anchor to the chart's current price so the label stays visible
anchorPrice = close

// --- Table Logic (Corner Positions) ---
tPos = displayPos == "Top Right"    ? position.top_right    : 
       displayPos == "Middle Right" ? position.middle_right : 
                                      position.bottom_right

if barstate.islast and displayPos != "Anchored to Price"
    subTable = table.new(tPos, 1, 1)
    table.cell(subTable, 0, 0, quoteText, 
         bgcolor=bgColor, 
         text_color=textColor, 
         text_size=fontSize, 
         text_font_family=font.family_monospace,
         text_halign=text.align_left)

// --- Label Logic (Anchored Position) ---
var label priceLabel = label.new(na, na, "", 
     style=label.style_label_left, 
     color=bgColor, 
     textcolor=textColor, 
     size=fontSize, 
     text_font_family=font.family_monospace,
     textalign=text.align_left)

if barstate.islast
    if displayPos == "Anchored to Price"
        label.set_xy(priceLabel, bar_index + anchorOffset, anchorPrice)
        label.set_text(priceLabel, quoteText)
        label.set_color(priceLabel, bgColor)
        label.set_textcolor(priceLabel, textColor)
        label.set_size(priceLabel, fontSize)
    else
        label.set_text(priceLabel, "")
        label.set_color(priceLabel, color.new(color.white, 100))
````

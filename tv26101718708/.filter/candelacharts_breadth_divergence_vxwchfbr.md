# CandelaCharts - Breadth Divergence

- url: https://www.tradingview.com/script/vxWChFbR-CandelaCharts-Breadth-Divergence/
- type: indicator
- pine_id: PUB;7469d3a1494d4f7fa68ea7fad8555eab
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - Breadth Divergence[/b] indicator identifies structural divergences between the primary chart's price action and a secondary breadth or macroeconomic symbol (such as [symbol]VALUG[/symbol] (Value Line Geometric Index), [symbol]USI:ADD[/symbol] (Advance-Decline Issues), or [symbol]US10Y[/symbol] (Treasury Yields)). 

Because you can plug any custom ticker into the indicator, it functions perfectly as an inter-market or macro divergence tool. By analyzing pivot highs and lows, it detects when the underlying market breadth or macro environment fails to confirm the price movement, signaling potential market reversals.

[list]
[*] [b]Bearish Divergence:[/b] Occurs when the main chart makes a Higher High while the breadth/macro symbol makes a Lower High.
[*] [b]Bullish Divergence:[/b] Occurs when the main chart makes a Lower Low while the breadth/macro symbol makes a Higher Low.
[/list]

📦 [b]Features[/b]

[list]
[*] [b]Automated Divergence Detection:[/b] Accurately maps regular bullish and bearish divergences using customizable pivot points.
[*] [b]Customizable Breadth Symbol:[/b] Set any symbol to act as the breadth index to measure internal market strength.
[*] [b]Visual Clarity:[/b] Highlights divergence zones with clean lines connecting the pivots and shaded background boxes for easy identification.
[*] [b]Flexible Lookbacks:[/b] Complete control over pivot lookback lengths to adapt the sensitivity to any timeframe or volatility condition.
[/list]

📈 [b]Supported Assets & Timeframes[/b]

This indicator is universally compatible with [b]any asset class[/b] (Equities, Crypto, Forex, Commodities, Indices) and [b]any timeframe[/b]. To adapt the indicator to a different market, you only need to change a single input: the [b]Breadth Symbol[/b]. For example:
[list]
[*] [b]S&P 500[/b] ([symbol]SPY[/symbol], [symbol]ES1![/symbol]): Set the Breadth Symbol to [symbol]USI:ADD[/symbol] (Advance-Decline), [symbol]USI:VOLD[/symbol] (Up/Down Volume), [symbol]RSP[/symbol] (Equal Weight), or [symbol]VALUG[/symbol] (Value Line).
[*] [b]Nasdaq 100[/b] ([symbol]QQQ[/symbol], [symbol]NQ1![/symbol]): Set the Breadth Symbol to [symbol]USI:ADDQ[/symbol] (Nasdaq Advance-Decline), [symbol]USI:VOLDQ[/symbol], [symbol]QQQE[/symbol] (Equal Weight), or [symbol]VXN[/symbol] (Nasdaq Volatility).
[*] [b]Forex / Currencies[/b] (e.g. [symbol]EURUSD[/symbol], [symbol]GBPUSD[/symbol]): Set the Breadth Symbol to [symbol]DXY[/symbol] (US Dollar Index) or [symbol]US10Y[/symbol] (US 10-Year Treasury Yield).
[*] [b]Crypto[/b] ([symbol]BTCUSD[/symbol]): Set the Breadth Symbol to [symbol]TOTAL3[/symbol] (Altcoin Market Cap) or [symbol]BTC.D[/symbol] (Bitcoin Dominance).
[/list]

⚙️ [b]Settings[/b]

[list]
[*] [b]Breadth Symbol:[/b] The ticker used to compare against the main chart (Default: [symbol]VALUG[/symbol] - Value Line Geometric Index).
[*] [b]Pivot Left / Right:[/b] The number of bars required to the left and right to confirm a pivot high or low.
[*] [b]Bullish / Bearish Colors:[/b] Customize the color of the divergence lines and background boxes. The backgrounds automatically apply a 90% opacity to the chosen colors.
[/list]

⚡️ [b]Showcase[/b]

[list]
[*] [b]S&P 500 ([symbol]ES1![/symbol]) vs. [symbol]VALUG[/symbol]:[/b] Show a bullish divergence where ES makes a lower low but the Value Line Geometric Index makes a higher low.
https://www.tradingview.com/x/5MFe0WrO/
[*] [b]Nasdaq 100 ([symbol]NQ1![/symbol]) vs. [symbol]ADDQ[/symbol]:[/b] Highlight a scenario where the cap-weighted NQ pushes higher but the Nasdaq Advance-Decline diverges, signaling weakness in the broader tech sector.
https://www.tradingview.com/x/V0eOhfFd/
[*] [b]Ethereum ([symbol]ETHUSD[/symbol]) vs. [symbol]TOTAL3[/symbol]:[/b] Show a bearish divergence where Ethereum makes a higher high, but the broader Altcoin market cap fails to follow suit.
https://www.tradingview.com/x/JUKVUskl/
[*] [b]Euro ([symbol]EURUSD[/symbol]) vs. [symbol]DXY[/symbol]:[/b] Display an inverse divergence setup using the US Dollar Index.
https://www.tradingview.com/x/9NeWLHr0/
[/list]

🚨 [b]Alerts[/b]

This indicator features built-in alerts using the `alert()` function. You can create an alert on the indicator to be notified whenever a Bullish or Bearish Breadth Divergence is detected.

⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator(title = "CandelaCharts - Breadth Divergence", shorttitle = "CandelaCharts - Breadth Divergence", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)












// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

colors_gray                         = color.gray
colors_transparent                  = color.new(color.white, 100)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

general_font                        = input.string("Monospace", "Text                   ", options = ["Default", "Monospace"], inline = "3.0", group = "General")
general_text                        = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "3.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                  = input.bool(false, "Hide Brand               ", group = "General")

sym_breadth                         = input.symbol("VALUG", "Breadth Symbol   ", inline="1.0", group = "Settings")
color_bull                          = input.color(color.teal, "", inline="1.0", group = "Settings")
color_bear                          = input.color(color.red, "", inline="1.0", group = "Settings")
lookback_left                       = input.int(5, "Pivot Left        ", minval = 1, group = "Settings")
lookback_right                      = input.int(5, "Pivot Right        ", minval = 1, group = "Settings")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   UDT   |
// # ========================================================================= #

//#region

type UDT_Divergence
    int start_time
    int end_time
    float start_price
    float end_price
    bool is_bearish

type UDT_Store
    array<line> lines
    array<box> boxes
    array<UDT_Divergence> divergences

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Functions / Utils  |
// # ========================================================================= #

//#region

method text_size(string size) =>
    out = switch size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
    out

method line_style(string line) =>
    out = switch line
        '⎯⎯⎯'  => line.style_solid
        '----'   => line.style_dashed
        '····'   => line.style_dotted

method font_style(string font) =>
    out = switch font
        'Default'   => font.family_default
        'Monospace' => font.family_monospace

method set_opacity(color css, int opacity) =>
    blue  = color.b(css)
    red   = color.r(css)
    green = color.g(css)
    color.rgb(red, green, blue, opacity)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Store   |
// # ========================================================================= #

//#region

var UDT_Store store = UDT_Store.new(array.new<line>(), array.new<box>(), array.new<UDT_Divergence>())

method clean_lines(UDT_Store s) =>
    if array.size(s.lines) > 50
        line old = array.shift(s.lines)
        line.delete(old)

method clean_boxes(UDT_Store s) =>
    if array.size(s.boxes) > 50
        box old = array.shift(s.boxes)
        box.delete(old)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Variables / Constants   |
// # ========================================================================= #

//#region

breadth_high = request.security(sym_breadth, timeframe.period, high)
breadth_low  = request.security(sym_breadth, timeframe.period, low)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Core Logic   |
// # ========================================================================= #

//#region

ph = ta.pivothigh(high, lookback_left, lookback_right)
pl = ta.pivotlow(low, lookback_left, lookback_right)

var float last_ph_price = na
var int   last_ph_time  = na
var float last_ph_brdth = na

var float last_pl_price = na
var int   last_pl_time  = na
var float last_pl_brdth = na

bool bear_div = false
bool bull_div = false

if not na(ph)
    float current_ph_price = ph
    int   current_ph_time  = time[lookback_right]
    float current_ph_brdth = breadth_high[lookback_right]

    if not na(last_ph_price)
        // Bearish Divergence: Main makes Higher High, Breadth makes Lower High
        if current_ph_price > last_ph_price and current_ph_brdth < last_ph_brdth
            bear_div := true
            UDT_Divergence div = UDT_Divergence.new(last_ph_time, current_ph_time, last_ph_price, current_ph_price, true)
            array.push(store.divergences, div)

    last_ph_price := current_ph_price
    last_ph_time  := current_ph_time
    last_ph_brdth := current_ph_brdth

if not na(pl)
    float current_pl_price = pl
    int   current_pl_time  = time[lookback_right]
    float current_pl_brdth = breadth_low[lookback_right]

    if not na(last_pl_price)
        // Bullish Divergence: Main makes Lower Low, Breadth makes Higher Low
        if current_pl_price < last_pl_price and current_pl_brdth > last_pl_brdth
            bull_div := true
            UDT_Divergence div = UDT_Divergence.new(last_pl_time, current_pl_time, last_pl_price, current_pl_price, false)
            array.push(store.divergences, div)

    last_pl_price := current_pl_price
    last_pl_time  := current_pl_time
    last_pl_brdth := current_pl_brdth

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Visuals / UI   |
// # ========================================================================= #

//#region

float trailing_lowest  = ta.lowest(low, 20)
float trailing_highest = ta.highest(high, 20)

if bear_div
    UDT_Divergence last_div = store.divergences.last()
    
    line l = line.new(x1 = last_div.start_time, y1 = last_div.start_price, x2 = last_div.end_time, y2 = last_div.end_price, xloc = xloc.bar_time, color = color_bear, width = 2, style = line.style_solid)
    array.push(store.lines, l)
    store.clean_lines()
    
    float box_top = math.max(last_div.start_price, last_div.end_price)
    float box_bot = trailing_lowest
    box b = box.new(left = last_div.start_time, top = box_top, right = last_div.end_time, bottom = box_bot, xloc = xloc.bar_time, border_color = colors_transparent, border_width = 0, bgcolor = color_bear.set_opacity(90))
    array.push(store.boxes, b)
    store.clean_boxes()

if bull_div
    UDT_Divergence last_div = store.divergences.last()
    
    line l = line.new(x1 = last_div.start_time, y1 = last_div.start_price, x2 = last_div.end_time, y2 = last_div.end_price, xloc = xloc.bar_time, color = color_bull, width = 2, style = line.style_solid)
    array.push(store.lines, l)
    store.clean_lines()

    float box_top = trailing_highest
    float box_bot = math.min(last_div.start_price, last_div.end_price)
    box b = box.new(left = last_div.start_time, top = box_top, right = last_div.end_time, bottom = box_bot, xloc = xloc.bar_time, border_color = colors_transparent, border_width = 0, bgcolor = color_bull.set_opacity(90))
    array.push(store.boxes, b)
    store.clean_boxes()

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #











// # ========================================================================= #
// # |   Brand   |
// # ========================================================================= #

//#region

if barstate.isfirst and general_brand_show == false
    var table brand = table.new(position.bottom_right, 1, 1, bgcolor = chart.bg_color)
    table.cell(brand, 0, 0,  "© CandelaCharts", text_color = colors_gray, text_halign = text.align_center, text_size = text_size(general_text), text_font_family = font_style(general_font))

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````

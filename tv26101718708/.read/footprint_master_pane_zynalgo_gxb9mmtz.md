# Footprint Master Pane [ZynAlgo]

- url: https://www.tradingview.com/script/GXB9MMTZ-Footprint-Master-Pane-ZynAlgo/
- type: indicator
- pine_id: PUB;c84207226587430eb1c0f6302ada6487
- version: 2.0

## Description

[b]Overview[/b]

ZynAlgo Footprint Master Pane is an order-flow and footprint-style volume analysis indicator designed to help traders study micro-liquidity behavior inside each candlestick.

The tool displays intrabar volume-side activity as a matrix-style Footprint Profile in a separate pane. Instead of only observing open, high, low, and close movement, traders can study where buying and selling pressure appears across different price levels inside recent candles.

This can help users evaluate:
[list]
[*]Intrabar volume concentration
[*]Buy-side and sell-side pressure
[*]Delta behavior inside each candle
[*]Point of Control placement
[*]Liquidity concentration at candle highs and lows
[*]Potential absorption or exhaustion behavior
[/list]

Chart example:
[image]https://www.tradingview.com/x/XOOZ2NJQ/[/image]

[b]How to Read the Footprint Matrix[/b]

Each data block on the chart is displayed in this format:

[b][Price Level] Bid | Ask[/b]

[b]Price Level[/b]

The price level represented by that row of the footprint matrix.

[b]Bid - Left Number[/b]

Represents sell-side volume activity classified by the script for that price level.

[b]Ask - Right Number[/b]

Represents buy-side volume activity classified by the script for that price level.

[b]Background Color - Heatmap[/b]

The higher the volume at a price level, the stronger the heatmap intensity.

Default color logic:
[list]
[*]Cyan: buy-side activity is dominant at that price level.
[*]Pink: sell-side activity is dominant at that price level.
[*]Gray: low or inactive liquidity area.
[/list]

[b]Key Highlights[/b]

[b]POC - Point of Control[/b]

The Point of Control is the price level with the highest total trading volume within the selected candlestick.

It is displayed as the gold zone and represents the main volume concentration area for that candle.

[b]Footer Metrics[/b]

The bottom of each footprint column displays summary data for the candle.

[b]Delta[/b]

Delta represents the net difference between buy-side and sell-side volume activity.

A positive delta indicates that buy-side pressure is dominant. A negative delta indicates that sell-side pressure is dominant.

[b]Total Volume[/b]

Total volume represents the combined volume activity for the entire candlestick.

[b]Configuration Settings[/b]

[b]1. Order Flow Engine[/b]

[b]Intrabar Timeframe[/b]

Defines the lower timeframe used by the tool to extract intrabar volume information.

Lower intrabar timeframes can provide more detailed footprint construction, while higher intrabar timeframes may produce a smoother and lighter display.

[b]Stack Levels - Height[/b]

Controls how many price levels each candlestick is divided into.

Higher values:
[list]
[*]Show more footprint detail
[*]Create a finer price-level breakdown
[*]May increase chart processing load
[/list]

Lower values:
[list]
[*]Create a simpler footprint view
[*]Reduce visual density
[*]May run more smoothly on slower charts
[/list]

[b]Auto Detect Asset - Smart Grid[/b]

When enabled, the system attempts to measure the current asset's volatility and calculate an appropriate grid size automatically.

This is useful when switching between markets such as gold, crypto, forex, indices, or stocks.

[b]Manual Tick Size[/b]

When Auto Detect Asset is disabled, users can manually define the tick or grid size.

This can be useful when a symbol requires a custom footprint scale.

[b]2. Pane Visuals[/b]

[b]Recent Bars to Render[/b]

Controls how many recent candles are displayed in detailed footprint form.

Limiting the number of rendered candles can help keep the chart responsive on TradingView.

[b]Color Customization[/b]

Users can customize the colors for:
[list]
[*]Buy-side activity
[*]Sell-side activity
[*]Point of Control zone
[*]Heatmap display
[/list]

This allows the footprint pane to match different chart themes and visual preferences.

[b]Basic Analytical Applications[/b]

[b]1. Absorption Observation[/b]

When price approaches a key support or resistance area, footprint data can help traders study whether one side of the market is being absorbed.

For example, if a bearish candle shows positive delta and large volume near the lower part of the candle, it may suggest that sell pressure is being absorbed by buy-side participation.

[b]2. POC Migration[/b]

Point of Control migration can help traders evaluate where value is shifting across consecutive candles.

In an uptrend, POC zones that continue to migrate higher may suggest that market participation is accepting higher prices.

[b]3. Liquidity at Highs and Lows[/b]

Traders can inspect volume activity near candle highs and lows to study exhaustion behavior.

For example, if price reaches a new high but the top levels show very low participation, that may indicate weaker continuation pressure.

[b]How to Use[/b]

[list=1]
[*]Add the indicator to the chart.
[*]Choose an intrabar timeframe suitable for the chart timeframe and market.
[*]Adjust stack levels to control footprint detail.
[*]Use the heatmap to identify price levels with stronger participation.
[*]Monitor the POC to study where volume concentration forms inside each candle.
[*]Compare delta and total volume to evaluate buy-side or sell-side pressure.
[*]Combine footprint observations with market structure, support and resistance, liquidity zones, and risk planning.
[/list]

[b]Best Use Cases[/b]

This indicator may be useful for:
[list]
[*]Order-flow style analysis
[*]Footprint chart reading
[*]Intrabar volume analysis
[*]Delta observation
[*]Point of Control tracking
[*]Absorption study
[*]Exhaustion analysis
[*]Liquidity-zone confirmation
[/list]

[b]Limitations[/b]

[list]
[*]Footprint values depend on the intrabar data available from TradingView for the selected symbol and timeframe.
[*]The Bid and Ask display is based on the script's volume-side classification logic and should be interpreted as analytical volume-side data.
[*]Lower intrabar timeframes may provide more detail but can increase processing load.
[*]A footprint imbalance does not guarantee price continuation or reversal.
[*]The indicator does not provide automatic trade entries, exits, or position management.
[*]Past order-flow or footprint behavior does not guarantee future results.
[/list]

[b]Important Note[/b]

This indicator is an analysis tool only. It does not provide financial advice, investment advice, or guaranteed trading results. Users are responsible for their own trading decisions and risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright ZynAlgo

//@version=6
indicator("Footprint Master Pane [ZynAlgo]", shorttitle="FP Master [ZynAlgo]", overlay=false, max_labels_count=500)

// SETTINGS
GRP_DATA = "1. ORDER FLOW ENGINE"
GRP_UI   = "2. PANE VISUALS"

ltf          = input.timeframe("1", title="Intrabar Timeframe", group=GRP_DATA)
levels_count = input.int(15, title="Stack Levels (Height)", minval=5, maxval=30, group=GRP_DATA, tooltip="Number of price levels shown in each footprint column.")

auto_tick    = input.bool(true, title="Auto Detect Asset (Smart Grid)", group=GRP_DATA, tooltip="Let the script calculate a practical grid step when the symbol changes.")
manual_tick  = input.float(1.0, title="Manual Tick Size (If Auto is OFF)", step=0.1, group=GRP_DATA)

bars_to_show = input.int(10, title="Recent Bars to Render", minval=1, maxval=20, group=GRP_UI, tooltip="Limits the number of recent footprint columns rendered for chart performance.")

c_buy  = input.color(color.rgb(0, 255, 255), title="Ask Dominance (Buy)", group=GRP_UI)
c_sell = input.color(color.rgb(255, 20, 147), title="Bid Dominance (Sell)", group=GRP_UI)
c_poc  = input.color(color.rgb(255, 215, 0), title="POC Highlight (Gold)", group=GRP_UI)
c_text = color.white

txt_size_opt = input.string("Normal", title="Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=GRP_UI, tooltip="Font size of the numbers inside each footprint cell and the Delta/Total footer. Increase if the values are hard to read; if columns overlap, reduce 'Recent Bars to Render' or 'Stack Levels'.")
string lbl_size = switch txt_size_opt
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

// AUTO TICK SIZE ALGORITHM
float atr_val = ta.atr(100)[1]
float calc_tick = atr_val / levels_count
float min_t = syminfo.mintick
calc_tick := math.max(min_t, math.round(calc_tick / min_t) * min_t)
float tick_size = auto_tick ? calc_tick : manual_tick

// INTRABAR DATA FETCHING
float[] ltf_c = request.security_lower_tf(syminfo.tickerid, ltf, close, ignore_invalid_timeframe=true)
float[] ltf_o = request.security_lower_tf(syminfo.tickerid, ltf, open, ignore_invalid_timeframe=true)
float[] ltf_v = request.security_lower_tf(syminfo.tickerid, ltf, volume, ignore_invalid_timeframe=true)

// ANTI-REPAINT BINNING (FIXED GRID)
int start_level = math.floor(low / tick_size)

array<float> bid_vol = array.new_float(levels_count, 0.0)
array<float> ask_vol = array.new_float(levels_count, 0.0)

if not na(ltf_v) and array.size(ltf_v) > 0
    for i = 0 to array.size(ltf_v) - 1
        float c = array.get(ltf_c, i)
        float o = array.get(ltf_o, i)
        float v = array.get(ltf_v, i)

        int grid_idx = math.floor(c / tick_size) - start_level
        grid_idx := math.max(0, math.min(levels_count - 1, grid_idx))

        if c > o
            array.set(ask_vol, grid_idx, array.get(ask_vol, grid_idx) + v)
        else if c < o
            array.set(bid_vol, grid_idx, array.get(bid_vol, grid_idx) + v)
        else
            array.set(ask_vol, grid_idx, array.get(ask_vol, grid_idx) + (v / 2))
            array.set(bid_vol, grid_idx, array.get(bid_vol, grid_idx) + (v / 2))

// SOLID MATRIX RENDERING (SUB-PANE WITH POC)
if bar_index > last_bar_index - bars_to_show
    float max_vol = 0.0
    int poc_idx = -1

    for i = 0 to levels_count - 1
        float tot = array.get(bid_vol, i) + array.get(ask_vol, i)
        if tot > max_vol
            max_vol := tot
            poc_idx := i

    for i = 0 to levels_count - 1
        float b_v = array.get(bid_vol, i)
        float a_v = array.get(ask_vol, i)
        float tot = b_v + a_v
        float y_pos = i
        float price_lvl = (start_level + i) * tick_size
        string txt = "[" + str.tostring(price_lvl) + "]  " + str.tostring(math.round(b_v)) + " | " + str.tostring(math.round(a_v))
        color bg_color = na

        if i == poc_idx and tot > 0
            bg_color := color.new(c_poc, 30)
        else if tot > 0
            float intensity = max_vol > 0 ? (tot / max_vol) : 0
            int trans = 100 - math.round(intensity * 75)
            bg_color := a_v > b_v ? color.new(c_buy, trans) : (b_v > a_v ? color.new(c_sell, trans) : color.new(color.gray, trans))
        else
            bg_color := color.new(color.gray, 90)

        label.new(x=bar_index, y=y_pos, text=txt, style=label.style_label_center, color=bg_color, textcolor=c_text, size=lbl_size)

// FOOTER AND DELTA
float total_bid = array.sum(bid_vol)
float total_ask = array.sum(ask_vol)
float bar_delta = total_ask - total_bid
float bar_vol = total_ask + total_bid

if bar_index > last_bar_index - bars_to_show
    string bottom_txt = "Delta: " + str.tostring(math.round(bar_delta)) + "\nTotal: " + str.tostring(math.round(bar_vol))
    color bottom_col = bar_delta > 0 ? color.new(c_buy, 40) : color.new(c_sell, 40)
    label.new(x=bar_index, y=-1.5, text=bottom_txt, style=label.style_label_up, color=bottom_col, textcolor=c_text, size=lbl_size)

// SCALING ANCHORS
plot(levels_count, color=color.new(color.black, 100), display=display.none)
plot(-3, color=color.new(color.black, 100), display=display.none)
````

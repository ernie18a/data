# Stockbee Sugar Babies Pine Screener by QuadrantLower

- url: https://www.tradingview.com/script/GUmWmvZn-Stockbee-Sugar-Babies-Pine-Screener-by-QuadrantLower/
- type: indicator
- pine_id: PUB;b18f696eb0924ed2ba15c3b9b9dadbbb
- version: 4.0

## Description

[b]PLEASE NOTE: this is intended to be used with TradingView's Pine Screener and not as a chart indicator![/b]

At the time of writing, TradingView's Pine Screener is in Beta and, as a result, [b]using this script is somewhat painful and should be considered experimental[/b] - it is a proof of concept and does not offer a great user experience. Sorry about that!

This script is for helping you generate a weekly Watchlist of [i]Sugar Babies[/i] - this is Stockbee/Pradeep Bonde's concept of stocks which have a history of making 4%+ breakouts with institutional volume (9M+ on the day) - that you can then keep a close eye on and look for breakout, reversal and anticipation trades (as per Pradeep's methodology).

To use this screener:
[list]
[*]Favourite the script so that it shows up in TradingView’s Pine Screener
[*]Create watchlists to filter - unfortunately, this is how TradingView’s Pine Screener currently works - you can't simply scan the entire market. At the time of writing, TradingView has a limit of 500 symbols per Watchlist (for all subscriptions other than Basic, which has 30, and Ultimate, which has 1000), so you will need to split up the market into separate watchlists. This is painful, but possible, using a combination of TradingView’s Stock Screener, exporting to CSV, editing outside of TradingView and importing to create watchlists. You can significantly minimize the amount of work by reducing the size of the universe to your needs (e.g. minimum Market Cap, minimum Price, limit to certain sectors only etc.). On the plus side, once this is done, these watchlists are good for many months, but they will atrophy over time as they wont get updated with IPOs or symbol changes.
[*]Launch the Pine Screener, select one of your Watchlists, select the indicator (it will only function on the 1D timeframe, but this is Pine Screener’s default so no worries), click on the columns options button (the three vertical lines button on the top right), enable all of the unchecked columns, then hit scan.
[*]Once the scan is complete you should see the columns populated with data. The green columns represent Bullish EP9s, the red columns represent Bearish EP9s and the orange columns represent the sum of Bullish and Bearish EP9s. There are seven lookback periods – 2Y, 1Y, 6M, 3M, 1M, 10D and 5D. Longer lookbacks are not possible as Pine Screener has a 500 bar (i.e. 500 day) limit. 
[*]You can then sort the columns and save the top, say, five results given by each Total column into a separate watchlist – repeat for each of your watchlists until you have distilled your Universe of Sugar Babies for the week :)
[/list]
[url=https://www.tradingview.com/watchlists/333288162/]Here[/url] is an example Sugar Babies Universe Watchlist. Don't ask me to update it - please make your own.

Here are all US stocks available on TradingView in May 2026 filtered by Mkt Cap >= 10M USD and Price >= 0.3 USD, then split in to 20 watchlists:
[list]
[*][url=https://www.tradingview.com/watchlists/333281748/]▚ US Market - Pt 01[/url]
[*][url=https://www.tradingview.com/watchlists/333281761/]▚ US Market - Pt 02[/url]
[*][url=https://www.tradingview.com/watchlists/333282495/]▚ US Market - Pt 03[/url]
[*][url=https://www.tradingview.com/watchlists/333282534/]▚ US Market - Pt 04[/url]
[*][url=https://www.tradingview.com/watchlists/333282659/]▚ US Market - Pt 05[/url]
[*][url=https://www.tradingview.com/watchlists/333282677/]▚ US Market - Pt 06[/url]
[*][url=https://www.tradingview.com/watchlists/333283731/]▚ US Market - Pt 07[/url]
[*][url=https://www.tradingview.com/watchlists/333283748/]▚ US Market - Pt 08[/url]
[*][url=https://www.tradingview.com/watchlists/333283852/]▚ US Market - Pt 09[/url]
[*][url=https://www.tradingview.com/watchlists/333284020/]▚ US Market - Pt 10[/url]
[*][url=https://www.tradingview.com/watchlists/333284069/]▚ US Market - Pt 11[/url]
[*][url=https://www.tradingview.com/watchlists/333284082/]▚ US Market - Pt 12[/url]
[*][url=https://www.tradingview.com/watchlists/333284190/]▚ US Market - Pt 13[/url]
[*][url=https://www.tradingview.com/watchlists/333284206/]▚ US Market - Pt 14[/url]
[*][url=https://www.tradingview.com/watchlists/333284272/]▚ US Market - Pt 15[/url]
[*][url=https://www.tradingview.com/watchlists/333284291/]▚ US Market - Pt 16[/url]
[*][url=https://www.tradingview.com/watchlists/333284299/]▚ US Market - Pt 17[/url]
[*][url=https://www.tradingview.com/watchlists/333284312/]▚ US Market - Pt 18[/url]
[*][url=https://www.tradingview.com/watchlists/333284321/]▚ US Market - Pt 19[/url]
[*][url=https://www.tradingview.com/watchlists/333284335/]▚ US Market - Pt 20[/url]
[/list]
[b]RISK DISCLAIMER[/b]

All content, including tools and scripts, released by QuadrantLower are purely for informational and educational purposes only. Nothing herein should be construed as financial advice or a recommendation to buy, sell, or hold any security or financial instrument. All trading involves risk and may not be suitable for all investors. You are solely responsible for your own trading decisions. Past performance is not indicative of future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 2026 QuadrantLower
// All credit to Pradeep Bonde for the idea - https://stockbee.biz/

//@version=6
indicator("▚ Stockbee Sugar Babies Pine Screener by QuadrantLower", shorttitle="▚ Sugar Babies Screener", overlay=true, max_bars_back=5000)

// ─── Timeframe Guard ──────────────────────────────────────────────────────────
if timeframe.period != "1D"
    runtime.error("This script only works on the Daily (1D) timeframe.")

// ─── Inputs ───────────────────────────────────────────────────────────────────
float pIncreaseThreshold  = input.float(4.0, "Price Change % Threshold", minval=0.0) / 100
float vIncreaseThreshold  = input.float(8.9, "Volume Threshold (M)",     minval=0.0) * 1000000

// ─── Label Inputs ─────────────────────────────────────────────────────────────
color  bullLabelColor     = input.color(color.new(color.green, 0),  "Bullish Colour ‎ ", inline="bull")
color  bullLabelTxtColor  = input.color(color.new(color.black, 0),  "‎Bullish Text Colour ‎ ", inline="bull")
color  bearLabelColor     = input.color(color.new(color.red, 0),    "Bearish Colour",      inline="bear")
color  bearLabelTxtColor  = input.color(color.new(color.white, 0),  "Bearish Text Colour", inline="bear")
color  totalLabelColor    = input.color(color.new(color.orange, 0), "Total Colour ‎ ‎ ‎", inline="total")
color  totalLabelTxtColor = input.color(color.new(color.black, 0),  "‎ Total Text Colour ‎ ‎ ‎ ", inline="total")

string labelSize          = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"])

string tablePosition      = input.string("Middle Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])

// ─── Core Conditions ──────────────────────────────────────────────────────────
bool priceCondition = close >= close[1] * (1 + pIncreaseThreshold) // today's candle is greater than or equal to yesterday's candle by X (default is a 4% breakout, as set in the user input)
bool volCondition   = volume > volume[1] and volume >= vIncreaseThreshold // today's candle has more volume than yesterday's candle AND the volume today is greater than or equal to X (default is 8.9M, as set in the user input)
bool bullSignal         = priceCondition and volCondition

bool bearPriceCondition = close <= close[1] * (1 - pIncreaseThreshold) // today's candle is less than or equal to yesterday's candle by X %
bool bearSignal         = bearPriceCondition and volCondition

// ─── Functions ──────────────────────────────────────────────────────────
f_getLabelSize() =>
    switch labelSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_getTablePosition() =>
    switch tablePosition
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.middle_right

// ─── Signal Labels ────────────────────────────────────────────────────────────
if bullSignal
    float pctChange = (close / close[1] - 1) * 100
    string labelTxt = "▲ +" + str.tostring(pctChange, "#.##") + "%\nVol " + str.tostring(volume / 1000000, "#.##") + "M"
    label.new(
      bar_index, low,
      "▲ EP9M",
      tooltip=labelTxt,
      yloc=yloc.belowbar,
      color=bullLabelColor,
      textcolor=bullLabelTxtColor,
      style=label.style_label_up,
      size=f_getLabelSize())

if bearSignal
    float pctChange = (close / close[1] - 1) * 100
    string labelTxt = "▼ " + str.tostring(pctChange, "#.##") + "%\nVol " + str.tostring(volume / 1000000, "#.##") + "M"
    label.new(
      bar_index, high,
      "▼ EP9M",
      tooltip=labelTxt,
      yloc=yloc.abovebar,
      color=bearLabelColor,
      textcolor=bearLabelTxtColor,
      style=label.style_label_down,
      size=f_getLabelSize())

// ─── Count function: sum occurrences over N bars ──────────────────────────────
bullCount(int len) =>
    math.sum(bullSignal ? 1 : 0, len)

bearCount(int len) =>
    math.sum(bearSignal ? 1 : 0, len)

// ─── Period counts & calcs ────────────────────────────────────────────────────
float bull_c2Y  = bullCount(500)
float bull_c1Y  = bullCount(252)
float bull_c6M  = bullCount(126)
float bull_c3M  = bullCount(63)
float bull_c1M  = bullCount(21)
float bull_c10D = bullCount(10)
float bull_c5D  = bullCount(5)
float bull_cSum = nz(bull_c2Y) + nz(bull_c1Y) + nz(bull_c6M) + nz(bull_c3M) + nz(bull_c1M) + nz(bull_c10D) + nz(bull_c5D) // sum the results of all the bull counts, checking for undefined values
float bull_SBscore = (not na(bull_c2Y) ? bull_cSum * bull_c2Y : // generate a "Sugar Baby" score by multiplying the sum of all periods by the 2Y EP9 count - also checks for undefined values and, if found, takes the next period's count as the multiplier
  not na(bull_c1Y)  ? bull_cSum * bull_c1Y :
  not na(bull_c6M)  ? bull_cSum * bull_c6M :
  not na(bull_c3M)  ? bull_cSum * bull_c3M :
  not na(bull_c1M)  ? bull_cSum * bull_c1M :
  not na(bull_c10D) ? bull_cSum * bull_c10D :
  not na(bull_c5D)  ? bull_cSum * bull_c5D : 0) /100 // divide the Sugar baby score by 100 to make the numbers more manageable

float bear_c2Y  = bearCount(500)
float bear_c1Y  = bearCount(252)
float bear_c6M  = bearCount(126)
float bear_c3M  = bearCount(63)
float bear_c1M  = bearCount(21)
float bear_c10D = bearCount(10)
float bear_c5D  = bearCount(5)
float bear_cSum = nz(bear_c2Y) + nz(bear_c1Y) + nz(bear_c6M) + nz(bear_c3M) + nz(bear_c1M) + nz(bear_c10D) + nz(bear_c5D)
float bear_SBscore = (not na(bear_c2Y) ? bear_cSum * bear_c2Y :
  not na(bear_c1Y)  ? bear_cSum * bear_c1Y :
  not na(bear_c6M)  ? bear_cSum * bear_c6M :
  not na(bear_c3M)  ? bear_cSum * bear_c3M :
  not na(bear_c1M)  ? bear_cSum * bear_c1M :
  not na(bear_c10D) ? bear_cSum * bear_c10D :
  not na(bear_c5D)  ? bear_cSum * bear_c5D : 0) / 100

float total_c2Y  = bull_c2Y + bear_c2Y
float total_c1Y  = bull_c1Y + bear_c1Y
float total_c6M  = bull_c6M + bear_c6M
float total_c3M  = bull_c3M + bear_c3M
float total_c1M  = bull_c1M + bear_c1M
float total_c10D = bull_c10D + bear_c10D
float total_c5D  = bull_c5D + bear_c5D
float total_cSum = nz(total_c2Y) + nz(total_c1Y) + nz(total_c6M) + nz(total_c3M) + nz(total_c1M) + nz(total_c10D) + nz(total_c5D)
float total_SBscore = (not na(total_c2Y) ? total_cSum * total_c2Y :
  not na(total_c1Y)  ? total_cSum * total_c1Y :
  not na(total_c6M)  ? total_cSum * total_c6M :
  not na(total_c3M)  ? total_cSum * total_c3M :
  not na(total_c1M)  ? total_cSum * total_c1M :
  not na(total_c10D) ? total_cSum * total_c10D :
  not na(total_c5D)  ? total_cSum * total_c5D : 0) / 100

// ─── Hidden plots (for Pine Screener) ─────────────────────────────────────────
plot(bull_SBscore,  "Bull Sugar Baby Score",   display=display.all, color=bullLabelColor)
plot(bear_SBscore,  "Bear Sugar Baby Score",   display=display.all, color=bearLabelColor)
plot(total_SBscore, "Total Sugar Baby Score",  display=display.all, color=totalLabelColor)

plot(bull_c2Y,  "Bull EP9 2Y Count",   display=display.all, color=bullLabelColor)
plot(bull_c1Y,  "Bull EP9 1Y Count",   display=display.all, color=bullLabelColor)
plot(bull_c6M,  "Bull EP9 6M Count",   display=display.all, color=bullLabelColor)
plot(bull_c3M,  "Bull EP9 3M Count",   display=display.all, color=bullLabelColor)
plot(bull_c1M,  "Bull EP9 1M Count",   display=display.all, color=bullLabelColor)
plot(bull_c10D, "Bull EP9 10D Count",  display=display.all, color=bullLabelColor)
plot(bull_c5D,  "Bull EP9 5D Count",   display=display.all, color=bullLabelColor)

plot(bear_c2Y,  "Bear EP9 2Y Count",   display=display.none, color=bearLabelColor) // The Pine Scanner wont show more than 10 plots by default irrispective of how many are set to "display.all", so we prioritize displaying the Baby and Bull Score plots...
plot(bear_c1Y,  "Bear EP9 1Y Count",   display=display.none, color=bearLabelColor)
plot(bear_c6M,  "Bear EP9 6M Count",   display=display.none, color=bearLabelColor)
plot(bear_c3M,  "Bear EP9 3M Count",   display=display.none, color=bearLabelColor)
plot(bear_c1M,  "Bear EP9 1M Count",   display=display.none, color=bearLabelColor)
plot(bear_c10D, "Bear EP9 10D Count",  display=display.none, color=bearLabelColor)
plot(bear_c5D,  "Bear EP9 5D Count",   display=display.none, color=bearLabelColor)

plot(total_c2Y,  "Total EP9 2Y Count",  display=display.none, color=totalLabelColor)
plot(total_c1Y,  "Total EP9 1Y Count",  display=display.none, color=totalLabelColor)
plot(total_c6M,  "Total EP9 6M Count",  display=display.none, color=totalLabelColor)
plot(total_c3M,  "Total EP9 3M Count",  display=display.none, color=totalLabelColor)
plot(total_c1M,  "Total EP9 1M Count",  display=display.none, color=totalLabelColor)
plot(total_c10D, "Total EP9 10D Count", display=display.none, color=totalLabelColor)
plot(total_c5D,  "Total EP9 5D Count",  display=display.none, color=totalLabelColor)

// ─── Display Table ────────────────────────────────────────────────────────────
int tableCols = 4
var table t = table.new(
  f_getTablePosition(), tableCols, 12,
  border_width=1,
  border_color=color.new(color.gray, 50),
  frame_color=color.new(color.gray, 50),
  frame_width=1)

if barstate.islast
    // Title row
    table.cell(t, 0, 0, "▚ Sugar Baby EP9s", text_color=color.white, bgcolor=color.rgb(15, 15, 35),
      text_size=size.small)
    table.merge_cells(t, 0, 0, 3, 0)
    // Header row
    table.cell(t, 0, 1, "Period",   text_color=color.white,    bgcolor=color.rgb(30, 30, 50), text_size=size.small)
    table.cell(t, 1, 1, "▲ Bull",   text_color=bullLabelColor,   bgcolor=color.rgb(30, 30, 50), text_size=size.small)
    table.cell(t, 2, 1, "▼ Bear",   text_color=bearLabelColor,   bgcolor=color.rgb(30, 30, 50), text_size=size.small)
    table.cell(t, 3, 1, "Total",  text_color=totalLabelColor,  bgcolor=color.rgb(30, 30, 50), text_size=size.small)

    // Data rows
    string[] labels  = array.from("2 Y", "1 Y", "6 M", "3 M", "1 M", "10 D", "5 D", "SCORE")
    float[]  bull_counts  = array.from(bull_c2Y, bull_c1Y, bull_c6M, bull_c3M, bull_c1M, bull_c10D, bull_c5D, bull_SBscore)
    float[]  bear_counts = array.from(bear_c2Y, bear_c1Y, bear_c6M, bear_c3M, bear_c1M, bear_c10D, bear_c5D, bear_SBscore)
    float[]  total_counts = array.from(total_c2Y, total_c1Y, total_c6M, total_c3M, total_c1M, total_c10D, total_c5D, total_SBscore)

    for i = 0 to 7
        int row = i + 2
        color bg = i % 2 == 0
          ? color.rgb(20, 20, 40)
          : color.rgb(25, 25, 48)
        float bull_cnt  = array.get(bull_counts,  i)
        float bear_cnt = array.get(bear_counts, i)
        float total_cnt = array.get(total_counts, i)
        table.cell(t, 0, row, array.get(labels, i),
          text_color=color.white, bgcolor=bg, text_size=size.small)
        table.cell(t, 1, row, str.tostring(bull_cnt),
          text_color=bull_cnt > 0 ? bullLabelColor : color.new(color.gray, 30),
          bgcolor=bg, text_size=size.small)
        table.cell(t, 2, row, str.tostring(bear_cnt),
          text_color=bear_cnt > 0 ? bearLabelColor : color.new(color.gray, 30),
          bgcolor=bg, text_size=size.small)
        table.cell(t, 3, row, str.tostring(total_cnt),
          text_color=bear_cnt > 0 ? totalLabelColor : color.new(color.gray, 30),
          bgcolor=bg, text_size=size.small)
````

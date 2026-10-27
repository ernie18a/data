# Bishop Biryani Ribbons V2

- url: https://www.tradingview.com/script/72XPRxdH-Bishop-Biryani-Ribbons-V2/
- type: indicator
- pine_id: PUB;7ff41d471ddd4782ac0016a485b40ebc
- version: 3.0

## Description

[b]What this indicator is[/b]

Bishop Biryani Ribbons V2 is a moving-average ribbon that reads the trend for you and puts the numbers that matter for a trade in one place. On the chart you get up to 7 moving averages with a shaded cloud between them, candles colored by trend, and optional signals. In the corner you get a dashboard that spells everything out in plain English: trend, trend strength, relative strength vs the market, volume, how stretched price is, earnings and more.

Out of the box it stays simple: four simple moving averages (10, 20, 50 and 200), one cloud, colored candles and a small dashboard. Everything else is off until you turn it on, so you only add what you actually use.

[b]Why everything is in one indicator[/b]

The simple answer is that it lets any swing trader or day trader see the most important stuff up front. I built it to help traders, especially newer ones, look at numbers that matter that they were not looking at before, especially in a market like this one.

Most of you guys check the same few things before every trade: is it trending, how strong is that trend, is the stock beating the market, is volume behind the move, is price too stretched to chase, and is earnings coming up. Normally that means stacking five or six separate indicators that do not talk to each other. Here, those pieces are wired together so each one feeds the next:

1) The trend reading comes from the moving-average stack, filtered by trend strength (ADX), so sideways chop is not called a trend.

2) The cloud, candle colors and background all show that one reading, and they dim when the market is choppy.

3) Pullback dots only fire in the direction of that trend reading, so a dot is a dip inside a trend and not a random touch of a line.

4) The A / B / C grade on each dot uses the other pieces: the bigger-timeframe trend, trend strength, volume on the dip and the RS Rating.

5) The scoreboard then checks how past dots on that same chart actually played out, overall and by grade, so you can see whether the setup has worked on that stock.

6) The dashboard shows all of it in words, with the scale in parentheses, so nothing needs to be decoded.

So the pieces are wired to work together on one chart, and they answer one question in order: is there a trend, is this a good place to join it, and has that worked here before.

[b]Why the RS Rating matters for every style[/b]

The RS Rating is the number most traders never look at, and it matters no matter how you trade. For swing traders, it keeps you in the stocks leading the market instead of the ones lagging it. For day traders, it tells you which names are worth trading today. Leaders tend to follow through when the market is strong and hold up better when it is weak, and because the rating works on any timeframe, you can see it right on a 1 or 5 minute chart. For LEAPS traders (long-dated options held for months), it shows whether a stock has been beating the market for most of the past year, not just the past few days. That is the kind of strength you want behind a position you plan to hold.

[b]How it works[/b]

[i]Moving averages.[/i] Up to 7 lines, each one can be SMA, EMA, WMA, HMA, ALMA, T3 or VWMA. Any line can be colored by direction: green while it is rising, pink while it is falling, gray when it is flat.

[i]Trend reading.[/i] Every candle gets one of four readings, worked out in this order:

[list]
[*]Choppy: trend strength (ADX, 14 candles) is below 20. If strength is still under 20 but has risen at least 1 point over the last 3 candles, the new trend is allowed to show early.
[*]Bullish: Average 1 is above Average 2, Average 2 is above Average 3, and price closes above Average 3. On the default setup that is the 10 above the 20 above the 50, with price above the 50.
[*]Bearish: the exact mirror of Bullish.
[*]Mixed: there is enough strength, but the lines are not lined up either way.
[/list]

[i]Cloud and candles.[/i] The cloud between two averages is green when the faster line is on top and pink when it is below. It fades as the lines come together. Candles are colored by how far price is from Average 2, so the color gets stronger as price runs away from the line.

[i]Pullback dots (optional).[/i] A green dot prints when, in a Bullish reading, the candle's low dips to Average 1 but the candle closes above Average 2. That means buyers defended the dip. A pink dot is the mirror of that in a Bearish reading. Both lines can be changed.

[i]Grade (optional).[/i] Each dot earns 1 point for each of these: the trend on a bigger timeframe agrees (Daily by default, or the next one up when the chart is already Daily or bigger), trend strength is 25 or more, the dip came on lighter volume than its 20-candle average, and the stock is beating the S&P 500 over the past year. A = 3 or 4 points, B = 2, C = 0 or 1.

[i]Scoreboard (optional).[/i] For the last 100 dots on the chart, a dot "won" if price moved 1 ATR in its favor (measured from the dot candle's close) before it moved 1 ATR against it. Dots that hit neither within 60 candles are not counted. ATR means average true range, the size of a normal candle including gaps.

[i]RS Rating (1 to 99).[/i] This is an IBD-style Relative Strength Rating. The stock's performance vs the S&P 500 is measured over 3, 6, 9 and 12 months, with the last 3 months counting double. That score is then ranked against about 6,100 US stocks, so 99 means stronger than 99% of them. It is worked out on daily data, so it reads the same on any chart timeframe. Ranking thousands of stocks every day is something an indicator cannot do on its own, so the daily ranking cutoffs come from @Fred6724's free daily data feed (see Credits).

[i]RS line new highs (optional).[/i] The RS line is the stock's price divided by the S&P 500. An orange dot prints when it makes a new high over the last 250 candles (52 on weekly). A rising RS line means the stock is beating the market, and a new RS high often shows up before price breaks out.

[b]Settings guide[/b]

The settings are split into 18 numbered sections in plain English, in the same order as below. Every setting also has an (i) you can hover for the full explanation.

[b]1) Quick Setup.[/b] Presets set things up in one click.

[list]
[*]Custom (default): uses your own settings.
[*]Bishop Bullish Swing + RS: SMA 10/20/50/200 plus my own swing setup, which turns on pullback dots (uptrend only), trend tags with RS, the RS chart extras, the range channel and the swing stats in the dashboard.
[*]Simple: just the 10, 20, 50 and 200 lines with their name tags and prices. No cloud, candle colors, signals or dashboard.
[*]Swing: SMA 10/20/50/200.
[*]Day trade: EMA 9/21/50/200.
[*]Scalp: EMA 8/21.
[*]Minimal: SMA 50/200.
[/list]

While a preset is picked, the settings it controls are locked, and the boxes in the menu will not change to show it (an indicator cannot tick its own boxes). To change a locked setting, pick Custom. Scalp and Minimal read the trend from just their two lines.

[b]2) Moving Averages.[/b] Up to 7 lines, each with an on/off tick, length, color and a "by direction" tick. Defaults: 10, 20, 50 and 200 on, with the 200 colored by direction. One average type and price source apply to every line. Line colors are changed here, not in the Style tab, and a changed color is used in every theme.

[b]3) Look.[/b] Color theme: Auto (default) uses Bishop Neon on dark charts and Bishop Light on white charts. Bishop Neon, Bishop Light, Classic and Custom can also be picked. Also in this section: line look (thin line or soft band), the glow, how steep a line must be for full direction color, and line prices on the right edge.

[b]4) Trend Cloud.[/b] Cloud 1 (on, between Average 1 and 2) and Cloud 2 (off, between Average 3 and 4). Each one can use any pair of lines, look faded or solid, and has its own on/off tick, so it stays on even if you hide its lines. Also in this section: tint the whole background by the trend reading.

[b]5) Candle Colors.[/b] Colors candles green above Average 2 and pink below it, stronger the farther price runs. Bold, Balanced (default) or Subtle sets how fast candles reach full color.

[b]6) Trend Reading.[/b] Spot choppy (sideways) markets (on), the trend strength look-back (14), the "trending when strength is above" number (20), show new trends early (on), and what happens to the cloud and candles when it is choppy: turn gray, dim their color (default) or stay normal. In the dashboard, strength reads as Weak (under 20), Waking up, Building (20 to 25), Strong (25 to 40) or Very strong (40 and up), shown like "Strong (27/100)".

[b]7) Pullback Dots.[/b] Off by default. Pick the side (both, uptrend only, downtrend only), which line the dip must reach and which line it must close beyond, and when dots count (Bullish/Bearish reading, Cloud 1 color, or any time). Optional filters: a touch tolerance in ATRs, minimum candles between dots, only the first pullback of each trend, and only dips on lighter volume. Also in this section: dot position, the A / B / C grade, and the bigger "vs" timeframe for the grade.

[b]8) Other Chart Signals.[/b]

[list]
[*]Only show signals after the candle closes (on), and signals only during regular market hours (off).
[*]Optional markers: triangles when Cloud 1 changes color, trend change tags, and purple shading when the lines bunch up (a squeeze, which often comes before a big move).
[*]RS on the chart: orange dots on RS line new highs (every new high, or only when RS leads price), an "RS 92" badge on the last candle, leader stars on pullback dots (RS 80 and up for up dots, 20 and under for down dots), a green / gray / red RS strip along the bottom, and the RS Rating added to trend change tags.
[/list]

[b]9) Range Channel.[/b] Off by default. Draws support and resistance around a sideways range while the market is choppy, and freezes it when price breaks out or the trend returns. You can pick candle bodies or wicks, the minimum choppy length and how many old channels to keep.

[b]10) Previous Day Levels.[/b] Off by default, intraday charts only. Yesterday's high and low (dashed amber) and close (dotted gray).

[b]11) Auto Fib Extensions (Beta).[/b] Off by default. Draws trend-based fib extensions the way you would draw them by hand: from the trend's starting low, to the high, back to the pullback low. Each new pullback adds the next fib. You pick the levels, how many fibs, the direction, the smallest pullback that counts and when a deep pullback starts a new trend.

[b]12) Dashboard.[/b] Full or Compact, position and text size. Choose which rows show: trend on other timeframes (30 min and Daily on by default, and only timeframes bigger than the chart appear), trend age and stretch from Average 2, RS Rating and past year vs the market, the pullback scoreboard and its split by grade, and the earnings countdown. Hover any row for an explanation.

[b]13) Dashboard: Swing Stats.[/b] Each row is off until you tick it, except relative volume:

[list]
[*]Market (S&P 500) trend
[*]ATR in $ and %, and average daily range %
[*]Today's low to high next to a normal day
[*]Stretch from the 50-day line
[*]Distance from the 52-week high
[*]Relative volume, like "61% (lighter than normal)"
[*]Buying vs selling volume
[*]Volume and dollar volume, today vs average
[*]Sector and industry
[/list]

The volume look-back is 20 days by default. All of these come from daily candles, so they read the same on any chart timeframe.

[b]14) Dashboard: Compact Style.[/b] One tick for each dashboard row, with shorter wording made for phones. A row shows in Compact only when it is ticked here and also turned on in section 12 or 13.

[b]15) Name Tags.[/b] A label like "10 SMA" right at the end of each line. You can set the distance from the last candle and push overlapping tags apart.

[b]16) Bigger-Timeframe Lines.[/b] Off by default. Up to 4 averages from a bigger timeframe on the current chart, for example the daily 100 on a 15 minute chart. They only update when the bigger candle closes, so they look like steps and never repaint.

[b]17) Alerts.[/b] Tick the events you want: trend reading changes (on), changes into or out of Mixed, cloud color changes, pullback dots and squeezes. Then create one alert with Biryani as the condition and "Any alert() function call", and that one alert covers all of them.

[b]18) Pine Screener.[/b] Four values for TradingView's Pine Screener: Trend (1 Bullish, -1 Bearish, 0 Choppy, 2 Mixed), Pullback dot (1 up, -1 down, 0 none), Trend strength (0 to 100) and RS Rating (1 to 99). The script has to be in your favorites to show up there.

[b]How to use it[/b]

Think of it as a checklist that is always on your chart, not a buy or sell button. Here is how a typical swing trade on a daily chart would go:

1) Check the dashboard. Look for a Bullish reading with trend strength at least Building or Strong.

2) Check the RS Rating. 80 and up means the stock is a market leader. An orange RS new-high dot is a bonus.

3) Wait for a pullback dot near the 10 or 20 instead of chasing. A or B grades have more in their favor.

4) Check stretch. If it says "very stretched", price is far from its line and a pullback is more likely than a clean entry.

5) Check relative volume, buying vs selling, and the earnings countdown before you size the trade.

6) Look at the scoreboard to see how dots have played out on that stock before.

For day trading, pick the Day trade preset on a 5 or 15 minute chart, turn on the 1 hour and Daily trend rows, previous day levels, and signals during regular market hours only. The Simple preset is there if you just want clean lines.

Always set your own stop and position size. None of this is financial advice.

[b]No repainting[/b]

[list]
[*]By default, dots, triangles, tags and stars only appear after the candle closes, and alerts fire on the close.
[*]Bigger-timeframe lines and the grade's bigger-timeframe point only use finished candles.
[*]On intraday charts, the RS strip, stars, RS on tags and the grade's RS point use the previous day's finished rating.
[*]The candle that is still forming updates its colors, cloud and dashboard live, like any indicator.
[/list]

[b]Limitations[/b]

[list]
[*]Moving averages lag. The trend reading confirms a trend after it starts, not at the exact turn.
[*]The scoreboard uses a simple 1 ATR win / 1 ATR loss test on past dots of that one chart. It ignores fees and slippage and does not promise future results.
[*]The RS Rating depends on Fred6724's daily feed. If the feed is more than 7 days late, the last numbers it sent are used and the rating shows a * (like "RS 92*"). If the feed cannot be read at all, backup numbers saved in the script are used. Older parts of the RS strip are estimates for the same reason.
[*]Orange RS dots are turned off on the S&P 500 itself and on funds that track it.
[*]Swing Stats come from daily candles. During market hours "today" means so far today, so relative volume starts low in the morning and builds through the day.
[*]The range channel and the auto fibs are drawn from past candles and can move while they are still live: the channel until it freezes, the fibs as new swings confirm. Auto fibs are Beta, so I personally would check them against your own drawing.
[*]If you turn off "only show signals after the candle closes", dots and tags can appear mid-candle and disappear before the close.
[*]On very long charts, the oldest labels (stars, tags, grade letters) drop off because of TradingView's label limit. This is cosmetic only.
[*]No plots are offset into the past.
[/list]

[b]Credits[/b]

The RS Rating uses @Fred6724's free daily rating data, and the rating curve is adapted from his RS Rating script (Mozilla Public License 2.0). Thank you Fred, really appreciate it. A real 1 to 99 rating means ranking every US stock against each other every single day, which an indicator cannot do on its own. That ranking has to come from an outside daily data feed (TradingView calls these Pine Seeds), and TradingView no longer lets anyone start a new one. Fred's feed already does this and it is free, so it made sense to use it.

This script is open source under the Mozilla Public License 2.0, © TheMarketBishop.

The original Bishop Chicken Biryani Ribbon (V14) stays up on my profile for anyone who prefers the old version. If you run into anything or have questions, let me know in the comments. Hopefully it helps

Fun fact: the best biryani is cooked dum style. The pot gets sealed shut with dough so everything cooks in its own steam. Patience pays off, in biryani and in trading

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheMarketBishop
// RS Rating: daily rating data from Fred6724's free feed, and the rating curve adapted from Fred6724's RS Rating script
// (both under the Mozilla Public License 2.0). Thank you, Fred.

//@version=6
indicator("Bishop Biryani Ribbons V2", shorttitle="Biryani", overlay=true, max_labels_count=200, max_lines_count=300, max_boxes_count=50, behind_chart=true)

//==========================================================
// SETTINGS SECTIONS
//==========================================================
const string G1  = "1 · Quick Setup"
const string G2  = "2 · Moving Averages"
const string G3  = "3 · Look"
const string G4  = "4 · Trend Cloud  (shaded band between two averages)"
const string G5  = "5 · Candle Colors"
const string G6  = "6 · Trend Reading  (Bullish / Bearish / Choppy / Mixed)"
const string G7  = "7 · Pullback Dots"
const string G8  = "8 · Other Chart Signals"
const string G9  = "9 · Range Channel  (support / resistance when choppy)"
const string GPD = "10 · Previous Day Levels"
const string GFB = "11 · Auto Fib Extensions  (Beta)"
const string G10 = "12 · Dashboard"
const string GSW = "13 · Dashboard: Swing Stats  (daily numbers, all off until you tick them)"
const string GCP = "14 · Dashboard: Compact Style  (only used when Style = Compact)"
const string G11 = "15 · Name Tags  (labels at the end of each line)"
const string G12 = "16 · Multi-Timeframe Moving Averages"
const string GSC = "18 · Pine Screener"
const string G13 = "17 · Alerts  (tick what you want, then Add Alert > Biryani > Any alert() function call)"

const string A1 = "Average 1"
const string A2 = "Average 2"
const string A3 = "Average 3"
const string A4 = "Average 4"
const string A5 = "Average 5"
const string A6 = "Average 6"
const string A7 = "Average 7"

//==========================================================
// 1 · QUICK SETUP
//==========================================================
preset = input.string("Custom (use my settings below)", "Preset", options=["Custom (use my settings below)", "Bishop Bullish Swing + RS  (SMA 10 / 20 / 50 / 200)", "Simple  (SMA 10 / 20 / 50 / 200, lines only)", "Swing  (SMA 10 / 20 / 50 / 200)", "Day trade  (EMA 9 / 21 / 50 / 200)", "Scalp  (EMA 8 / 21)", "Minimal  (SMA 50 / 200)"], group=G1, display=display.none, tooltip="One-click setup.\nCustom = your own choices in the sections below.\nBishop Bullish Swing + RS = The Market Bishop's own swing setup: SMA 10 / 20 / 50 / 200, uptrend pullback dots with leader stars and scoreboard, trend change tags with the RS Rating, orange RS dots, RS badge and color strip, range channel, choppy markets dimmed, regular market hours only, and the full swing dashboard.\nSimple = just the SMA 10 / 20 / 50 / 200 lines with their glow, name tags and prices. No cloud, candle colors, direction colors, signals, extra lines or dashboard.\nSwing, Day trade, Scalp and Minimal pick the averages and Cloud 1 only. Scalp and Minimal also read the trend, pullback dots, candle colors, stretch and squeeze from just their two lines.\nWhile a preset is chosen, the settings it controls are locked. Pick Custom to change them.")

//==========================================================
// 2 · MOVING AVERAGES
//==========================================================
maTypeIn = input.string("SMA", "Average type", options=["SMA", "EMA", "WMA", "HMA", "ALMA", "T3", "VWMA"], group=G2, display=display.none, tooltip="Only used when Preset = Custom.\nSMA = simple average (the classic).\nEMA = reacts faster to new prices.\nWMA = between SMA and EMA.\nHMA = very fast and smooth.\nALMA = smooth with little delay.\nT3 = the smoothest, rounded curves.\nVWMA = gives more weight to high-volume candles.")
src      = input.source(close, "Based on price", group=G2, display=display.none, tooltip="The price the averages are built from. Close is the standard.")
showMa1In = input.bool(true,  A1, inline="m1", group=G2, display=display.none)
lenMa1In  = input.int(10,  "", minval=1, inline="m1", group=G2, display=display.none)
colIn1    = input.color(#00DCFF, "", inline="m1", group=G2, display=display.none)
dirMa1In  = input.bool(false, "by direction", inline="m1", group=G2, display=display.none, tooltip="On/off, length, color, and by direction.\nBy direction = the line turns green while rising, pink while falling and gray when flat. Tick it on any average you like.\nLengths and on/off are only used when Preset = Custom.\nColors: change one here (in this Inputs tab) and that line uses it in every theme. Lines you leave alone follow the Color theme. If by direction is ticked on a line, the direction colors win.")
showMa2In = input.bool(true,  A2, inline="m2", group=G2, display=display.none)
lenMa2In  = input.int(20,  "", minval=1, inline="m2", group=G2, display=display.none)
colIn2    = input.color(#4C7DFF, "", inline="m2", group=G2, display=display.none)
dirMa2In  = input.bool(false, "by direction", inline="m2", group=G2, display=display.none)
showMa3In = input.bool(true,  A3, inline="m3", group=G2, display=display.none)
lenMa3In  = input.int(50,  "", minval=1, inline="m3", group=G2, display=display.none)
colIn3    = input.color(#FFAA00, "", inline="m3", group=G2, display=display.none)
dirMa3In  = input.bool(false, "by direction", inline="m3", group=G2, display=display.none)
showMa4In = input.bool(true,  A4, inline="m4", group=G2, display=display.none)
lenMa4In  = input.int(200, "", minval=1, inline="m4", group=G2, display=display.none)
colIn4    = input.color(#8C93A8, "", inline="m4", group=G2, display=display.none)
dirMa4In  = input.bool(true, "by direction", inline="m4", group=G2, display=display.none)
showMa5In = input.bool(false, A5, inline="m5", group=G2, display=display.none)
lenMa5    = input.int(100, "", minval=1, inline="m5", group=G2, display=display.none)
colIn5    = input.color(#2DD4BF, "", inline="m5", group=G2, display=display.none)
dirMa5In  = input.bool(false, "by direction", inline="m5", group=G2, display=display.none)
showMa6In = input.bool(false, A6, inline="m6", group=G2, display=display.none)
lenMa6    = input.int(150, "", minval=1, inline="m6", group=G2, display=display.none)
colIn6    = input.color(#B57BFF, "", inline="m6", group=G2, display=display.none)
dirMa6In  = input.bool(false, "by direction", inline="m6", group=G2, display=display.none)
showMa7In = input.bool(false, A7, inline="m7", group=G2, display=display.none)
lenMa7    = input.int(300, "", minval=1, inline="m7", group=G2, display=display.none)
colIn7    = input.color(#FF6B9A, "", inline="m7", group=G2, display=display.none)
dirMa7In  = input.bool(false, "by direction", inline="m7", group=G2, display=display.none)

// Preset overrides (Custom = your own settings)
isCustom = preset == "Custom (use my settings below)"
pSwing   = preset == "Swing  (SMA 10 / 20 / 50 / 200)"
pDay     = preset == "Day trade  (EMA 9 / 21 / 50 / 200)"
pScalp   = preset == "Scalp  (EMA 8 / 21)"
pMin     = preset == "Minimal  (SMA 50 / 200)"
pBBS     = preset == "Bishop Bullish Swing + RS  (SMA 10 / 20 / 50 / 200)"   // The Market Bishop's own setup: turns on the settings listed in the Preset tooltip
pSimple  = preset == "Simple  (SMA 10 / 20 / 50 / 200, lines only)"   // lines only: everything else is switched off
dirMa1 = pSimple ? false : dirMa1In
dirMa2 = pSimple ? false : dirMa2In
dirMa3 = pSimple ? false : dirMa3In
dirMa4 = pSimple ? false : dirMa4In
dirMa5 = pSimple ? false : dirMa5In
dirMa6 = pSimple ? false : dirMa6In
dirMa7 = pSimple ? false : dirMa7In
maType  = isCustom ? maTypeIn : (pDay or pScalp) ? "EMA" : "SMA"
lenMa1  = isCustom ? lenMa1In : pDay ? 9 : pScalp ? 8 : 10
lenMa2  = isCustom ? lenMa2In : (pDay or pScalp) ? 21 : 20
lenMa3  = isCustom ? lenMa3In : 50
lenMa4  = isCustom ? lenMa4In : 200
showMa1 = isCustom ? showMa1In : not pMin
showMa2 = isCustom ? showMa2In : not pMin
showMa3 = isCustom ? showMa3In : not pScalp
showMa4 = isCustom ? showMa4In : not pScalp
showMa5 = isCustom ? showMa5In : false
showMa6 = isCustom ? showMa6In : false
showMa7 = isCustom ? showMa7In : false

// Which lines the trend reading, dots, candles and stretch use.
// Scalp (8/21) and Minimal (50/200) only use their two visible lines.
twoLine = pScalp or pMin
keyLenF = pMin ? lenMa3 : lenMa1
keyLenM = pMin ? lenMa4 : lenMa2
keyLenS = pMin ? lenMa4 : pScalp ? lenMa2 : lenMa3
refLen  = pMin ? lenMa3 : lenMa2

//==========================================================
// 3 · LOOK
//==========================================================
theme     = input.string("Auto (matches your chart)", "Color theme", options=["Auto (matches your chart)", "Bishop Neon", "Bishop Light", "Classic", "Custom"], group=G3, display=display.none, tooltip="Auto = Bishop Neon on dark charts and Bishop Light on white charts. It switches by itself when you change your chart background.\nBishop Neon / Bishop Light = always use that one.\nClassic = the original V14 colors.\nCustom = the colors you pick in sections 2 and 4.\nAny color you change in sections 2 or 4 is used in every theme.")
lineLook  = input.string("Line", "Line look", options=["Line", "Soft band"], group=G3, display=display.none, tooltip="Line = thin line with a soft glow.\nSoft band = Averages 1 to 4 drawn as thicker see-through bands (5 to 7 stay as lines).")
bandW     = input.int(10, "Band thickness", minval=4, maxval=20, group=G3, display=display.none, tooltip="Only used when Line look = Soft band.")
glowMode  = input.string("All lines", "Line glow", options=["All lines", "Average 1 and 2 only", "Off"], group=G3, display=display.none, tooltip="The glow is drawn on Averages 1 to 4.")
glowW     = input.int(7, "Glow thickness", minval=2, maxval=14, group=G3, display=display.none)
glowT     = input.int(80, "Glow softness", minval=50, maxval=98, group=G3, display=display.none, tooltip="Higher number = softer, fainter glow.")
slopeSens = input.float(0.2, "Direction colors: how steep = full color", minval=0.01, maxval=3.0, step=0.01, group=G3, display=display.none, tooltip="For averages colored by direction (section 2). Lower = full color on gentle moves. Higher = only steep moves get full color.")
showTags  = input.bool(true, "Show line prices on the right edge", group=G3, display=display.none)

//==========================================================
// 4 · TREND CLOUD
//==========================================================
r1OnIn     = input.bool(true, "Cloud 1 between", inline="r1", group=G4, display=display.none)
r1FastIn   = input.string(A1, "", options=[A1, A2, A3, A4, A5, A6, A7], inline="r1", group=G4, display=display.none)
r1SlowIn   = input.string(A2, "and", options=[A1, A2, A3, A4, A5, A6, A7], inline="r1", group=G4, display=display.none, tooltip="Each cloud has its own on/off tick, so it stays on even if you hide its lines in section 2.\nWhich two lines Cloud 1 uses is only taken from here when Preset = Custom.")
r1On = pSimple ? false : r1OnIn
r2OnIn     = input.bool(false, "Cloud 2 between", inline="r2", group=G4, display=display.none)
r2FastSel  = input.string(A3, "", options=[A1, A2, A3, A4, A5, A6, A7], inline="r2", group=G4, display=display.none)
r2SlowSel  = input.string(A4, "and", options=[A1, A2, A3, A4, A5, A6, A7], inline="r2", group=G4, display=display.none)
r2On = pSimple ? false : r2OnIn
cloudStyle = input.string("Fade", "Cloud look", options=["Fade", "Solid"], group=G4, display=display.none, tooltip="Fade = brightest at the faster line, fading toward the slower line.")
cloudOpac  = input.int(45, "Cloud brightness %", minval=5, maxval=100, group=G4, display=display.none, tooltip="How bright the cloud gets in a strong trend. It dims by itself when the two lines get close.")
cloudRef   = input.float(1.0, "Full brightness when lines are this far apart", minval=0.1, step=0.1, group=G4, display=display.none, tooltip="In average candle sizes. 1 = the two lines are one normal candle apart.")
bullIn     = input.color(#00E5A0, "Up color", inline="rc", group=G4, display=display.none)
bearIn     = input.color(#FF3B69, "Down color", inline="rc", group=G4, display=display.none, tooltip="Change these and the clouds, candles, direction colors and dashboard use them in every theme. Leave them alone and they follow the Color theme.")
bgOnIn     = input.bool(false, "Tint the whole background by trend", group=G4, display=display.none, tooltip="Light green while the trend reading is Bullish, light pink while it is Bearish, no tint when Choppy or Mixed. Squeeze shading (section 8) takes over while it is on.")
bgOn = pSimple ? false : bgOnIn
r1FastSel  = isCustom ? r1FastIn : pMin ? A3 : A1
r1SlowSel  = isCustom ? r1SlowIn : pMin ? A4 : A2

//==========================================================
// 5 · CANDLE COLORS
//==========================================================
candleOnIn = input.bool(true, "Color candles by trend", group=G5, display=display.none, tooltip="Candles turn green above Average 2 and pink below it (Average 3 with the Minimal preset). Gray right on the line, with stronger color the farther price runs from it.")
candleOn = pSimple ? false : candleOnIn
candleMode = input.string("Balanced", "How quickly candles get full color", options=["Bold", "Balanced", "Subtle"], group=G5, display=display.none, tooltip="Bold = full color after a small move.\nBalanced = in between.\nSubtle = full color only on big moves.")
candleFull = candleMode == "Bold" ? 0.8 : candleMode == "Subtle" ? 2.5 : 1.5

//==========================================================
// 6 · TREND READING
//==========================================================
chopOnIn  = input.bool(true, "Spot choppy (sideways) markets", group=G6, display=display.none, tooltip="BULLISH = Average 1 above 2 above 3, and price above 3.\nBEARISH = the opposite.\nScalp and Minimal read the trend from just their two lines (fast line above slow line, price above the slow line).\nCHOPPY = trend strength is below the number set just below.\nMIXED = enough strength, but the lines are not lined up.")
chopOn = pBBS ? true : chopOnIn
adxLen    = input.int(14, "Trend strength: candles to look back", minval=1, group=G6, display=display.none, tooltip="Trend strength uses the ADX formula. 14 is the standard.")
adxMin    = input.float(20, "Trending when strength is above", minval=1, step=1, group=G6, display=display.none, tooltip="Below this = choppy. 20 is standard. 25 is stricter.")
earlyOn   = input.bool(true, "Show new trends early (while strength is climbing)", group=G6, display=display.none, tooltip="If strength is still low but clearly climbing, the trend shows right away instead of waiting.")
earlyBars = input.int(3, "Climbing = compared to how many candles ago", minval=1, maxval=20, group=G6, display=display.none, tooltip="Lower = spots new trends faster but more false starts. Higher = slower but more reliable.")
earlyMin  = input.float(1.0, "Climbing = risen by at least", minval=0.1, step=0.5, group=G6, display=display.none, tooltip="Points of trend strength (0 to 100). 1 = any real pickup. 3+ = only a sharp pickup.")
chopLookIn = input.string("Dim their color", "When choppy, cloud and candles", options=["Turn gray", "Dim their color", "Stay normal"], group=G6, display=display.none, tooltip="Turn gray = color disappears while choppy.\nDim their color = keeps green/pink, just faded.\nStay normal = choppy only shows in the dashboard.")
chopLook = pBBS ? "Dim their color" : chopLookIn
muteChop  = chopLook == "Turn gray"
dimChop   = chopLook == "Dim their color"

//==========================================================
// 7 · PULLBACK DOTS
//==========================================================
pbOnIn     = input.bool(false, "Show pullback dots", inline="pb0", group=G7, display=display.none)
pbSideIn   = input.string("Both", "", options=["Both", "Uptrend only", "Downtrend only"], inline="pb0", group=G7, display=display.none, tooltip="Green dot = in an uptrend, price dipped to a line but the dip held. Pink dot = the mirror image in a downtrend.")
pbSide = pBBS ? "Uptrend only" : pbSideIn
pbOn = pBBS ? true : pSimple ? false : pbOnIn
pbTouchSel = input.string(A1, "Dip must reach", options=[A1, A2, A3, A4], inline="pb1", group=G7, display=display.none)
pbHoldSel  = input.string(A2, "and close beyond", options=[A1, A2, A3, A4], inline="pb1", group=G7, display=display.none, tooltip="Default: dip to Average 1, but close above Average 2 (uptrend) or below it (downtrend). The Minimal preset always uses its 50 line for both.")
pbTrend    = input.string("Bullish / Bearish reading", "Only when", options=["Bullish / Bearish reading", "Cloud 1 color", "Any time"], group=G7, display=display.none, tooltip="Bullish / Bearish reading = strictest.\nCloud 1 color = only needs Cloud 1 green (or pink).\nAny time = no trend check.")
pbTol      = input.float(0.0, "Counts as a touch if within", minval=0.0, step=0.05, group=G7, display=display.none, tooltip="0 = must actually touch the line. 0.2 = within 0.2 average candle sizes also counts.")
pbGap      = input.int(1, "Minimum candles between dots", minval=1, maxval=100, group=G7, display=display.none, tooltip="Raise this (for example 5) to stop dots bunching up.")
pbFirst    = input.bool(false, "Only the first pullback of each trend", group=G7, display=display.none, tooltip="Shows just one dot per trend: the first dip after the trend turns Bullish (or Bearish). The first pullback is usually the most reliable. Resets every time a new trend starts. With Only when = Any time, a new trend means a new Bullish or Bearish reading.")
pbVol      = input.bool(false, "Only if the dip came on lighter volume", group=G7, display=display.none, tooltip="The dip candle's volume must be below the 20-candle average. Needs volume data.")
pbPos      = input.string("Floating below", "Dot position", options=["Floating below", "Tight to the candle", "On the line it touched"], group=G7, display=display.none)
pbGrade    = input.bool(false, "Show a quality grade (A / B / C) by each dot", inline="gr", group=G7, display=display.none)
htfTrendTf = input.timeframe("D", "vs", inline="gr", group=G7, display=display.none, tooltip="1 point each:\n• the trend on this bigger timeframe agrees (if your chart is already this timeframe or bigger, the next one up is used: Daily chart = Weekly)\n• trend strength is 25 or more\n• the dip came on lighter volume\n• the stock is beating the S&P 500 over the past year\nA = 3 or 4 points, B = 2, C = 0 or 1. Only finished bigger-timeframe candles are used, so a grade never changes after the fact.")

//==========================================================
// 8 · OTHER CHART SIGNALS
//==========================================================
sigConfirm = input.bool(true, "Only show dots and triangles after the candle closes", group=G8, display=display.none, tooltip="On = dots, triangles, tags and stars never appear and then vanish. Off = they can show up while the candle is still forming.")
rthOnlyIn  = input.bool(false, "Signals only during regular market hours", group=G8, display=display.none, tooltip="Ignores premarket and after-hours candles for dots, triangles, tags, alerts and the scoreboard.")
rthOnly = pBBS ? true : rthOnlyIn
showFlipsIn = input.bool(false, "Triangles when Cloud 1 changes color", group=G8, display=display.none)
showFlips = pSimple ? false : showFlipsIn
tagOnIn    = input.bool(false, "Trend change tags (Bullish / Bearish / Choppy)", group=G8, display=display.none, tooltip="A small tag on the chart every time the trend reading changes, so you can scroll back and see the trend history at a glance.")
tagOn = pBBS ? true : pSimple ? false : tagOnIn
rsDotsIn   = input.bool(false, "Orange dots when RS hits a new high", inline="rsd", group=G8, display=display.none, tooltip="An orange dot above the candle when the stock's strength compared with the S&P 500 (its RS line) hits a new high over the look-back. This is the same signal as the blue dots on Fred6724's RS Rating.\nNot shown on the S&P 500 itself or funds that track it, since they can't beat themselves.")
rsDotLen   = input.int(250, "look-back", minval=20, maxval=1000, inline="rsd", group=G8, display=display.none, tooltip="How many candles back the new high is measured over. 250 on a daily chart = about one year (it switches to 52 on weekly charts).")
rsDots = pBBS ? true : pSimple ? false : rsDotsIn
rsDotMode  = input.string("Every RS new high", "Which RS new highs", options=["Every RS new high", "Only when RS leads price"], group=G8, display=display.none, tooltip="Every RS new high = the same dots as Fred6724's RS Rating indicator.\nOnly when RS leads price = only when price itself has NOT made a new high yet. Fewer dots; strength showing up before price often comes before a breakout.")
rsBadgeIn  = input.bool(false, "RS badge above the last candle (e.g. RS 92)", group=G8, display=display.none)
rsBadge = pBBS ? true : pSimple ? false : rsBadgeIn
rsStarIn   = input.bool(false, "Star on pullback dots of market leaders (turn on pullback dots first)", group=G8, display=display.none, tooltip="Adds a small star to an up dot when the stock's RS Rating is 80 or higher, and to a down dot when it is 20 or lower (the weakest stocks, for shorts).\nOnly shows while Show pullback dots (section 7) is on.")
rsStar = pBBS ? true : pSimple ? false : rsStarIn
rsStripIn  = input.bool(false, "RS Rating color strip along the bottom", group=G8, display=display.none, tooltip="Green = RS 80 and up (a leader). Gray = 40 to 79. Red = under 40.\nOlder parts of the strip are estimates, because only recent rating cutoffs are available. On intraday charts each candle uses the previous day's finished rating, so the strip never changes after the fact.")
rsStrip = pBBS ? true : pSimple ? false : rsStripIn
rsTagOnIn  = input.bool(false, "Add the RS Rating to trend change tags (turn on Trend change tags first)", group=G8, display=display.none, tooltip="Adds the RS Rating at that moment to each trend change tag, e.g. Bullish · RS 92.\nOnly shows while Trend change tags (above) is on.")
rsTagOn = pBBS ? true : pSimple ? false : rsTagOnIn
sqzOnIn    = input.bool(false, "Purple shading when lines bunch up (squeeze)", inline="sq", group=G8, display=display.none)
sqzThr     = input.float(0.8, "how tight", minval=0.1, step=0.1, inline="sq", group=G8, display=display.none, tooltip="How close Averages 1, 2 and 3 must be (the two lines for Scalp and Minimal), in average candle sizes. Tight lines often come before a big move.")
sqzOn = pSimple ? false : sqzOnIn

//==========================================================
// 9 · RANGE CHANNEL
//==========================================================
rngOnIn = input.bool(false, "Draw a range channel when choppy", group=G9, display=display.none, tooltip="Draws the top (resistance) and bottom (support) of a sideways range. It freezes when price closes outside it or the market trends again.\nChoppy here means trend strength is below your 'Trending when strength is above' number in section 6, so it works even when 'Spot choppy markets' is off.")
rngOn = pBBS ? true : pSimple ? false : rngOnIn
rngEdge = input.string("Candle bodies", "Channel edges use", options=["Candle bodies", "Wicks"], group=G9, display=display.none, tooltip="Candle bodies = tighter and cleaner. Wicks = the very highest and lowest prices.")
rngMin  = input.int(8, "Only draw if choppy for at least (candles)", minval=2, maxval=200, group=G9, display=display.none)
rngPre  = input.int(10, "Also include candles from before it turned choppy", minval=0, maxval=100, group=G9, display=display.none)
rngKeep = input.int(4, "Old channels to keep on the chart", minval=1, maxval=12, group=G9, display=display.none, tooltip="Finished channels kept on the chart, not counting the one being drawn now.")
rngLbl  = input.bool(true, "Show support / resistance prices", group=G9, display=display.none)

//==========================================================
// 10 · PREVIOUS DAY LEVELS
//==========================================================
pdOnIn = input.bool(false, "Show previous day high, low and close", group=GPD, display=display.none, tooltip="Dashed amber lines = yesterday's high and low. Dotted gray line = yesterday's close. Day traders watch these as support and resistance. Only shows on intraday charts.")
pdOn = pSimple ? false : pdOnIn
pdDays = input.int(1, "Days to show", minval=1, maxval=5, group=GPD, display=display.none)
pdLbl  = input.bool(true, "Show labels", group=GPD, display=display.none)

//==========================================================
// 11 · AUTO FIB EXTENSIONS  (BETA)
//==========================================================
fibOnIn  = input.bool(false, "Draw auto fib extensions", group=GFB, display=display.none, tooltip="Beta: still being fine-tuned, so check the fibs against your own drawing.\nDraws trend-based fib extensions the way you would by hand: from the low where the trend started, up to the high, then back down to the pullback low. Each new pullback adds the next fib, starting where the last one ended (the ladder).\nIn a downtrend it is the mirror image.")
fibOn = pSimple ? false : fibOnIn
fibFrom  = input.string("Most recent", "Start from", options=["Start of the trend", "Most recent"], group=GFB, display=display.none, tooltip="Start of the trend = the first fib begins at the low where the trend started, and the ladder builds up from there.\nMost recent = only the newest fib(s).")
fibCount = input.int(2, "How many fibs (ladder steps)", minval=1, maxval=4, group=GFB, display=display.none, tooltip="1 = a single fib. 2 to 4 = ladders up: each new fib starts where the last one ended.")
fibDir   = input.string("Uptrends only", "Direction", options=["Follow the trend reading", "Uptrends only", "Downtrends only"], group=GFB, display=display.none, tooltip="Follow the trend reading = upside fibs while the trend is Bullish, downside fibs while it is Bearish. During Choppy or Mixed it keeps the last one.")
fibLvls  = input.string("0.618, 1, 1.618, 2.618, 3.618, 4.236", "Levels", group=GFB, display=display.none, tooltip="Type the levels you want, separated by commas.")
fibSwing = input.float(2.0, "Smallest pullback that counts (in average candle sizes)", minval=0.5, maxval=10, step=0.25, group=GFB, display=display.none, tooltip="How far a candle has to CLOSE away from a high (or low) before it counts as a pullback. A single wick does not count.\nLower = more, smaller fibs. Higher = fewer, bigger fibs. 2 suits most charts; try 1.5 for more fibs, or 2.5 on very fast movers.")
fibReset = input.float(78.6, "Start a new trend if a pullback gives back more than (%)", minval=50, maxval=100, step=0.1, group=GFB, display=display.none, tooltip="If a pullback erases more than this much of the move, the old ladder is thrown away and a new trend starts from that low.")
fibDaily = input.string("Auto (yes below 1 hour)", "Start fresh each day", options=["Auto (yes below 1 hour)", "Yes", "No"], group=GFB, display=display.none, tooltip="Yes = day trading: each day builds its own ladder starting from that day's low (or high).\nAuto = yes on charts below 1 hour, no on 1 hour and up.")
fibPath  = input.bool(true, "Show the swing lines (start, high, pullback)", group=GFB, display=display.none)
fibLbl   = input.bool(true, "Show level labels", group=GFB, display=display.none)
fibUpC   = input.color(#4CAF50, "Colors: up", inline="fbc", group=GFB, display=display.none)
fibDnC   = input.color(#F23645, "down", inline="fbc", group=GFB, display=display.none)

//==========================================================
// 12 · DASHBOARD
//==========================================================
showTableIn = input.bool(true, "Show dashboard", group=G10, display=display.none)
showTable = pSimple ? false : showTableIn
boxStyle    = input.string("Full", "Style", options=["Full", "Compact"], group=G10, display=display.none, tooltip="Full = every row you turn on in sections 12 and 13.\nCompact = only the rows you tick in section 14, with shorter wording. Made for phones.")
tablePosIn  = input.string("Top right", "Position", options=["Top right", "Bottom right", "Top left", "Bottom left", "Middle right"], group=G10, display=display.none)
tableSizeIn = input.string("Small", "Text size", options=["Extra tiny", "Tiny", "Small", "Normal", "Large"], group=G10, display=display.none)
mtfOn       = input.bool(true, "Trend on other timeframes", group=G10, display=display.none, tooltip="One row per timeframe: green = Bullish, red = Bearish, plain = Choppy, amber = Mixed. Timeframes that are not bigger than your chart are skipped.")
mtfOn1      = input.bool(true,  "", inline="t1", group=G10, display=display.none)
mtfTf1      = input.timeframe("30", "", inline="t1", group=G10, display=display.none)
mtfOn2      = input.bool(false,  "", inline="t1", group=G10, display=display.none)
mtfTf2      = input.timeframe("60", "", inline="t1", group=G10, display=display.none)
mtfOn3      = input.bool(true,  "", inline="t2", group=G10, display=display.none)
mtfTf3      = input.timeframe("D", "", inline="t2", group=G10, display=display.none)
mtfOn4      = input.bool(false, "", inline="t2", group=G10, display=display.none)
mtfTf4      = input.timeframe("W", "", inline="t2", group=G10, display=display.none)
statsOnIn   = input.bool(false, "Trend age and stretch", group=G10, display=display.none, tooltip="Trend age = how many candles the current reading has lasted.\nStretch = how far price has run from Average 2 (Average 3 with the Minimal preset), counted in ATRs (average candle sizes).")
statsOn = pBBS ? true : statsOnIn
extWarn     = input.float(2.0, "Call it 'very stretched' at", minval=0.5, step=0.1, group=G10, display=display.none, tooltip="In ATRs (average candle sizes) away from Average 2.")
rsOnIn      = input.bool(false, "RS Rating (1 to 99)", group=G10, display=display.none, tooltip="IBD-style Relative Strength Rating. It compares this stock's past year with about 6,100 US stocks: 99 = stronger than 99% of them. The last 3 months count double.\nAlso shows how much the stock is beating or lagging the market (S&P 500).\nThis tick only controls these two dashboard rows. The RS features in section 8 work either way.\nRating data: Fred6724's free daily feed (github.com/Fred6725/relative-strength), Mozilla Public License 2.0.")
rsOn = pBBS ? true : rsOnIn
scoreOnIn   = input.bool(false, "Pullback dot scoreboard", group=G10, display=display.none, tooltip="For every past dot: did price move the win distance in your favor before the loss distance against you? A dot that reaches neither within 60 candles is not counted.")
scoreOn = pBBS ? true : scoreOnIn
scoreWin    = input.float(1.0, "Win distance", minval=0.1, step=0.1, inline="sc", group=G10, display=display.none)
scoreLos    = input.float(1.0, "Loss distance", minval=0.1, step=0.1, inline="sc", group=G10, display=display.none, tooltip="In average candle sizes from the dot candle's close.")
scoreN      = input.int(100, "Count the last how many dots", minval=10, maxval=500, group=G10, display=display.none)
scoreGrdIn  = input.bool(false, "Scoreboard split by grade (A / B / C)", group=G10, display=display.none, tooltip="Win rate of past dots split by quality grade. Shows whether A dots really beat C dots on this stock. Works even when grade labels are hidden on the chart.")
scoreGrd = pBBS ? true : scoreGrdIn
earnOn      = input.bool(true, "Earnings warning", group=G10, display=display.none, tooltip="Days until the next earnings report. Amber with a ! at 7 days or less.")
listOn      = input.bool(true, "List of averages (price above / below each)", group=G10, display=display.none)

//==========================================================
// 13 · DASHBOARD: SWING STATS  (all from daily candles, so they read the same on any chart timeframe)
//==========================================================
swMktIn  = input.bool(false, "Market trend (S&P 500)", group=GSW, display=display.none, tooltip="The same Bullish / Bearish / Choppy / Mixed reading, worked out on the S&P 500 daily chart. Most swing trades struggle when the market is weak.")
swMkt = pBBS ? true : swMktIn
// How the stock moves
swAtrIn  = input.bool(false, "ATR: average daily move in $ and %", inline="sw1", group=GSW, display=display.none)
swAtrLen = input.int(14, "look-back (days)", minval=1, maxval=100, inline="sw1", group=GSW, display=display.none, tooltip="ATR (Average True Range) = how much the stock normally moves in a day, gaps included. Shown in dollars and as a % of price. Handy for sizing stops.")
swAtr = pBBS ? true : swAtrIn
swAdrIn  = input.bool(false, "Average daily range %", inline="sw2", group=GSW, display=display.none)
swAdrLen = input.int(20, "look-back (days)", minval=1, maxval=100, inline="sw2", group=GSW, display=display.none, tooltip="The average distance from each day's low to its high, as a % of price, over the days before today. Tells you whether a stock moves enough to be worth swing trading. Momentum swing traders often want about 4% or more.")
swAdr = pBBS ? true : swAdrIn
swUsedIn = input.bool(false, "Today's low-to-high range vs a normal day", group=GSW, display=display.none, tooltip="How far the stock has traveled today from its low to its high, next to a normal day (the average daily range). This is not the change from yesterday's close.\nAmber = today's range is already as big as a normal day or bigger, so chasing it is riskier.\nWhen the market is closed it shows the last trading day.")
swUsed = pBBS ? true : swUsedIn
swExt50In = input.bool(false, "Stretch from the 50-day line (how many ATRs away)", group=GSW, display=display.none, tooltip="How far price is from the 50-day average (same average type as your lines), counted in ATRs, a normal day's move. 4x the ATR above = price sits about 4 normal days' moves above the line. The bigger the number, the more stretched the stock is. Stretched stocks often pull back toward the line.")
swExt50 = pBBS ? true : swExt50In
// Where price sits
sw52In   = input.bool(false, "Distance from the 52-week high", group=GSW, display=display.none, tooltip="How far the last price is below the highest price of the past year. Leading stocks usually trade near their highs.")
sw52 = pBBS ? true : sw52In
// Volume
swRvol   = input.bool(true, "Relative volume (today vs a normal day)", group=GSW, display=display.none, tooltip="Today's volume as a % of a normal day. 100% = normal, 200% = twice as much. Amber = 150% or more.\nDuring the trading day it counts the volume so far, so it starts low in the morning and builds up.")
swUdIn   = input.bool(false, "Buying vs selling volume (up days vs down days)", group=GSW, display=display.none, tooltip="Of all the shares traded over the volume look-back, the % that traded on up days (buying) vs down days (selling). More on up days = buyers in control.")
swUd = pBBS ? true : swUdIn
swAvgVIn = input.bool(false, "Volume: today and the average (shares)", group=GSW, display=display.none, tooltip="Shares traded today next to the average day. During market hours, today counts the volume so far.")
swAvgV = pBBS ? true : swAvgVIn
swDolVIn = input.bool(false, "Dollar volume: today and the average ($ traded)", group=GSW, display=display.none, tooltip="Dollars traded today (shares times price) next to the average day. Shows how easy the stock is to get in and out of. During market hours, today counts the volume so far.")
swDolV = pBBS ? true : swDolVIn
swVolLen = input.int(20, "Volume look-back (days)", minval=5, maxval=200, group=GSW, display=display.none, tooltip="Used by relative volume, buying vs selling volume, average volume and average dollar volume. 20 days keeps up with how fast the market changes. 50 is the slower, classic setting.")
// The company
swSec    = input.bool(false, "Sector and industry", group=GSW, display=display.none)

//==========================================================
// 14 · DASHBOARD: COMPACT STYLE  (which rows the small dashboard shows)
//==========================================================
cmpTrend = input.bool(true,  "This chart's trend", inline="c1", group=GCP, display=display.none, tooltip="Only used when Style = Compact (section 12). Compact uses shorter wording, made for phones.\nA row shows only if it is also turned on in section 12 or 13.")
cmpBig   = input.bool(true,  "Biggest other timeframe", inline="c1", group=GCP, display=display.none)
cmpAgree = input.bool(false, "Timeframes agree", inline="c2", group=GCP, display=display.none)
cmpMkt   = input.bool(false, "Market (S&P 500)", inline="c2", group=GCP, display=display.none)
cmpStr   = input.bool(true,  "Trend strength", inline="c3", group=GCP, display=display.none)
cmpAge   = input.bool(false, "Trend age", inline="c3", group=GCP, display=display.none)
cmpExt   = input.bool(false, "Stretch from Average 2", inline="c4", group=GCP, display=display.none)
cmpAtr   = input.bool(false, "ATR", inline="c4", group=GCP, display=display.none)
cmpAdr   = input.bool(false, "Average daily range", inline="c5", group=GCP, display=display.none)
cmpDay   = input.bool(false, "Today's range", inline="c5", group=GCP, display=display.none)
cmpExt50 = input.bool(false, "Stretch from 50-day", inline="c6", group=GCP, display=display.none)
cmpRs    = input.bool(true,  "RS Rating", inline="c6", group=GCP, display=display.none)
cmpPast  = input.bool(false, "Past year vs market", inline="c7", group=GCP, display=display.none)
cmp52    = input.bool(false, "52-week high", inline="c7", group=GCP, display=display.none)
cmpRvol  = input.bool(true,  "Relative volume", inline="c8", group=GCP, display=display.none)
cmpUd    = input.bool(false, "Buying vs selling", inline="c8", group=GCP, display=display.none)
cmpVol   = input.bool(false, "Volume", inline="c9", group=GCP, display=display.none)
cmpDolV  = input.bool(false, "Dollar volume", inline="c9", group=GCP, display=display.none)
cmpDots  = input.bool(false, "Pullback dot results", inline="c10", group=GCP, display=display.none)
cmpGrd   = input.bool(false, "Dots by grade", inline="c10", group=GCP, display=display.none)
cmpSqz   = input.bool(false, "Lines bunched", inline="c11", group=GCP, display=display.none)
cmpEarn  = input.bool(true,  "Earnings (7 days or less)", inline="c11", group=GCP, display=display.none)
cmpSec   = input.bool(false, "Sector and industry", inline="c12", group=GCP, display=display.none)
cmpList  = input.bool(false, "List of averages", inline="c12", group=GCP, display=display.none)

//==========================================================
// 15 · NAME TAGS
//==========================================================
showLabels  = input.bool(true, "Show name tags", group=G11, display=display.none)
labelGap    = input.float(0.0, "Push overlapping tags apart (0 = off)", minval=0.0, step=0.1, group=G11, display=display.none, tooltip="0 = every name tag sits right on its own line (recommended).\nRaise it (for example 0.3) only if two tags overlap because their lines are very close. The tags then get pushed apart, so they can sit a little off their lines, more so when you zoom in. In average candle sizes.")
labelOffset = input.int(1, "Distance from the last candle (candles)", minval=0, maxval=50, group=G11, display=display.none, tooltip="1 = the tag sits right after the end of its line.")

//==========================================================
// 16 · MULTI-TIMEFRAME MAs
//==========================================================
showMtf1In = input.bool(false, "MTF MA 1", inline="h1", group=G12, display=display.none)
tfMtf1   = input.timeframe("60", "", inline="h1", group=G12, display=display.none)
lenMtf1  = input.int(20, "", minval=1, inline="h1", group=G12, display=display.none)
typMtf1  = input.string("Same as main", "", options=["Same as main", "SMA", "EMA", "WMA", "HMA", "ALMA", "T3", "VWMA"], inline="h1", group=G12, display=display.none)
colMtf1  = input.color(#7CFFB2, "", inline="h1", group=G12, display=display.none, tooltip="Moving averages from another timeframe, drawn on your chart. Example: the daily 100 average on your 15 minute chart.\nEach line has: on/off, timeframe, length, average type and color.\nAverage type: Same as main = the type picked in section 2. Or pick SMA, EMA, WMA, HMA, ALMA, T3 or VWMA for just that line.\nThe line only updates when the bigger candle closes, so it never repaints. A timeframe smaller than your chart is skipped.")
showMtf1 = pSimple ? false : showMtf1In
showMtf2In = input.bool(false, "MTF MA 2", inline="h2", group=G12, display=display.none)
tfMtf2   = input.timeframe("D", "", inline="h2", group=G12, display=display.none)
lenMtf2  = input.int(100, "", minval=1, inline="h2", group=G12, display=display.none)
typMtf2  = input.string("Same as main", "", options=["Same as main", "SMA", "EMA", "WMA", "HMA", "ALMA", "T3", "VWMA"], inline="h2", group=G12, display=display.none)
colMtf2  = input.color(#FF5CF0, "", inline="h2", group=G12, display=display.none)
showMtf2 = pSimple ? false : showMtf2In
showMtf3In = input.bool(false, "MTF MA 3", inline="h3", group=G12, display=display.none)
tfMtf3   = input.timeframe("W", "", inline="h3", group=G12, display=display.none)
lenMtf3  = input.int(50, "", minval=1, inline="h3", group=G12, display=display.none)
typMtf3  = input.string("Same as main", "", options=["Same as main", "SMA", "EMA", "WMA", "HMA", "ALMA", "T3", "VWMA"], inline="h3", group=G12, display=display.none)
colMtf3  = input.color(#FFE45C, "", inline="h3", group=G12, display=display.none)
showMtf3 = pSimple ? false : showMtf3In
showMtf4In = input.bool(false, "MTF MA 4", inline="h4", group=G12, display=display.none)
tfMtf4   = input.timeframe("W", "", inline="h4", group=G12, display=display.none)
lenMtf4  = input.int(200, "", minval=1, inline="h4", group=G12, display=display.none)
typMtf4  = input.string("Same as main", "", options=["Same as main", "SMA", "EMA", "WMA", "HMA", "ALMA", "T3", "VWMA"], inline="h4", group=G12, display=display.none)
colMtf4  = input.color(#FFFFFF, "", inline="h4", group=G12, display=display.none)
showMtf4 = pSimple ? false : showMtf4In

//==========================================================
// 17 · ALERTS
//==========================================================
alState = input.bool(true,  "Trend reading changes (Bullish / Bearish / Choppy)", group=G13, display=display.none)
alMixed = input.bool(false, "Also alert on changes into or out of MIXED", group=G13, display=display.none, tooltip="Off (quieter) = only alerts when the trend becomes BULLISH, BEARISH or CHOPPY.")
alCloud = input.bool(false, "A cloud changes color", group=G13, display=display.none)
alPb    = input.bool(false, "A pullback dot appears", group=G13, display=display.none)
alSqz   = input.bool(false, "A squeeze starts or ends", group=G13, display=display.none)

//==========================================================
// 18 · PINE SCREENER
//==========================================================
scrOn = input.bool(true, "Send values to the Pine Screener", group=GSC, display=display.none, tooltip="Lets TradingView's Pine Screener filter whole watchlists by Biryani. In the Pine Screener pick this script, then filter by:\nScreener Trend: 1 = Bullish, -1 = Bearish, 0 = Choppy, 2 = Mixed\nScreener Pullback dot: 1 = new up dot, -1 = new down dot, 0 = none\nScreener Trend strength: 0 to 100\nScreener RS Rating: 1 to 99 (99 = strongest)")

//==========================================================
// MOVING AVERAGE ENGINE
//==========================================================
const float ALMA_OFFSET = 0.85
const float ALMA_SIGMA  = 6.0
const float T3_FACTOR   = 0.7

f_t3(float source, int length, float v) =>
    e1 = ta.ema(source, length)
    e2 = ta.ema(e1, length)
    e3 = ta.ema(e2, length)
    e4 = ta.ema(e3, length)
    e5 = ta.ema(e4, length)
    e6 = ta.ema(e5, length)
    c1 = -v * v * v
    c2 = 3 * v * v + 3 * v * v * v
    c3 = -6 * v * v - 3 * v - 3 * v * v * v
    c4 = 1 + 3 * v + v * v * v + 3 * v * v
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

getMA(float source, int length, string type) =>
    switch type
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "HMA"  => ta.hma(source, length)
        "ALMA" => ta.alma(source, length, ALMA_OFFSET, ALMA_SIGMA)
        "T3"   => f_t3(source, length, T3_FACTOR)
        "VWMA" => ta.vwma(source, length)
        => ta.sma(source, length)

// Multi-timeframe MA that never repaints. Same timeframe as chart = computed locally. Smaller = skipped.
f_htf(string tf, int length, string typ) =>
    int tfSec    = timeframe.in_seconds(tf)
    int chartSec = timeframe.in_seconds()
    float result = na
    if tfSec == chartSec
        result := getMA(src, length, typ)
    else if tfSec > chartSec
        result := request.security(syminfo.tickerid, tf, getMA(src, length, typ)[1], lookahead=barmerge.lookahead_on)
    result

// Short timeframe text for name tags (e.g. 1H, 1D)
f_tfLabel(string tf) =>
    int s = timeframe.in_seconds(tf)
    s >= 2419200 ? str.tostring(math.round(s / 2628003.0)) + "M" : s >= 604800 ? str.tostring(math.round(s / 604800.0)) + "W" : s >= 86400 ? str.tostring(math.round(s / 86400.0)) + "D" : s >= 3600 and s % 3600 == 0 ? str.tostring(s / 3600) + "H" : s >= 60 ? str.tostring(math.round(s / 60.0)) + "m" : str.tostring(s) + "s"

// Plain-English timeframe name for the dashboard (e.g. "15 min", "Daily")
f_tfName(string tf) =>
    int s = timeframe.in_seconds(tf)
    s >= 2419200 ? (s < 2700000 ? "Monthly" : str.tostring(math.round(s / 2628003.0)) + " month") : s >= 604800 ? (s == 604800 ? "Weekly" : str.tostring(math.round(s / 604800.0)) + " week") : s >= 86400 ? (s == 86400 ? "Daily" : str.tostring(math.round(s / 86400.0)) + " day") : s >= 3600 and s % 3600 == 0 ? str.tostring(s / 3600) + " hour" : s >= 60 ? str.tostring(math.round(s / 60.0)) + " min" : str.tostring(s) + " sec"

// Trend code: 1 = BULLISH, -1 = BEARISH, 0 = CHOPPY, 2 = MIXED
f_stateCode() =>
    m1 = getMA(src, keyLenF, maType)
    m2 = getMA(src, keyLenM, maType)
    m3 = getMA(src, keyLenS, maType)
    [dp, dm, ax] = ta.dmi(adxLen, adxLen)
    bool chop = chopOn and ax < adxMin and not (earlyOn and ax - ax[earlyBars] >= earlyMin)
    bool up = twoLine ? (m1 > m3 and close > m3) : (m1 > m2 and m2 > m3 and close > m3)
    bool dn = twoLine ? (m1 < m3 and close < m3) : (m1 < m2 and m2 < m3 and close < m3)
    chop ? 0 : up ? 1 : dn ? -1 : 2

// Live trend reading of a bigger timeframe (only shown in the dashboard)
f_htfState(string tf) =>
    int tfSec    = timeframe.in_seconds(tf)
    int chartSec = timeframe.in_seconds()
    int result = na
    if tfSec > chartSec
        result := request.security(syminfo.tickerid, tf, f_stateCode())
    else if tfSec == chartSec
        result := f_stateCode()
    result

//==========================================================
// CALCULATIONS
//==========================================================
ma1 = getMA(src, lenMa1, maType)
ma2 = getMA(src, lenMa2, maType)
ma3 = getMA(src, lenMa3, maType)
ma4 = getMA(src, lenMa4, maType)
ma5 = getMA(src, lenMa5, maType)
ma6 = getMA(src, lenMa6, maType)
ma7 = getMA(src, lenMa7, maType)

mtTyp1 = typMtf1 == "Same as main" ? maType : typMtf1
htf1 = showMtf1 ? f_htf(tfMtf1, lenMtf1, mtTyp1) : na
mtTyp2 = typMtf2 == "Same as main" ? maType : typMtf2
htf2 = showMtf2 ? f_htf(tfMtf2, lenMtf2, mtTyp2) : na
mtTyp3 = typMtf3 == "Same as main" ? maType : typMtf3
htf3 = showMtf3 ? f_htf(tfMtf3, lenMtf3, mtTyp3) : na
mtTyp4 = typMtf4 == "Same as main" ? maType : typMtf4
htf4 = showMtf4 ? f_htf(tfMtf4, lenMtf4, mtTyp4) : na

atr14 = ta.atr(14)

// Direction of each line, in average candle sizes per bar (3-bar average so it doesn't flicker)
f_slope(float m) =>
    atr14 > 0 ? (m - m[3]) / (3 * atr14) : 0.0

s1 = f_slope(ma1)
s2 = f_slope(ma2)
s3 = f_slope(ma3)
s4 = f_slope(ma4)
s5 = f_slope(ma5)
s6 = f_slope(ma6)
s7 = f_slope(ma7)

// Trend reading: line stack + strength filter
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxRising = adxVal - adxVal[earlyBars] >= earlyMin
isChop    = chopOn and adxVal < adxMin and not (earlyOn and adxRising)
kF = pMin ? ma3 : ma1
kM = pMin ? ma4 : ma2
kS = pMin ? ma4 : pScalp ? ma2 : ma3
refLine = pMin ? ma3 : ma2
stackBull = twoLine ? (kF > kS and close > kS) : (kF > kM and kM > kS and close > kS)
stackBear = twoLine ? (kF < kS and close < kS) : (kF < kM and kM < kS and close < kS)
stateBull = not isChop and stackBull
stateBear = not isChop and stackBear
int stateCode = isChop ? 0 : stackBull ? 1 : stackBear ? -1 : 2

var int stateBars = 0
stateBars := stateCode == stateCode[1] ? stateBars + 1 : 1

// Grade point 1 compares with a bigger timeframe, using only its finished candles (no repainting).
// If the chart is already that timeframe or bigger, the next one up is used (Daily chart = Weekly).
gradeTf = timeframe.in_seconds(htfTrendTf) > timeframe.in_seconds() ? htfTrendTf : timeframe.isintraday ? "D" : timeframe.isdaily ? "W" : timeframe.isweekly ? "M" : "12M"
htfCode = pbGrade or scoreGrd ? request.security(syminfo.tickerid, gradeTf, f_stateCode()[1], lookahead=barmerge.lookahead_on) : na

// Stretch: distance from Average 2, in average candle sizes
extAtr = atr14 > 0 ? (close - refLine) / atr14 : 0.0

// Squeeze: Averages 1 / 2 / 3 packed together
maHi  = math.max(kF, math.max(kM, kS))
maLo  = math.min(kF, math.min(kM, kS))
isSqz = atr14 > 0 and (maHi - maLo) / atr14 < sqzThr


//==========================================================
// COLORS
//==========================================================
bgLum     = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
isAuto    = theme == "Auto (matches your chart)"
isNeon    = theme == "Bishop Neon" or (isAuto and bgLum < 128)
isLight   = theme == "Bishop Light" or (isAuto and bgLum >= 128)
isClassic = theme == "Classic"
chartLight = bgLum >= 128   // the actual chart background, whatever the theme

bullC = theme == "Custom" or bullIn != #00E5A0 ? bullIn : isNeon ? #00E5A0 : isLight ? #00A37A : isClassic ? #089981 : bullIn
bearC = theme == "Custom" or bearIn != #FF3B69 ? bearIn : isNeon ? #FF3B69 : isLight ? #E0245E : isClassic ? #F23645 : bearIn
flatC = isLight ? #9AA1AD : #7A8291
mixC  = isLight ? #D97706 : #FFAA00
sqzC  = isLight ? #8B5CF6 : #B57BFF
panelBg   = isLight ? #FFFFFF : #0B0E14
panelText = isLight ? #111827 : #E6E9EF
panelMute = isLight ? #6B7280 : #8A93A6
panelEdge = isLight ? #D1D5DB : #1E2433

// A color you change in section 2 or 4 wins in every theme. Unchanged colors follow the theme.
isCustomTheme = theme == "Custom"
base1 = isCustomTheme or colIn1 != #00DCFF ? colIn1 : isNeon ? #00DCFF : isLight ? #0891B2 : isClassic ? color.aqua   : colIn1
base2 = isCustomTheme or colIn2 != #4C7DFF ? colIn2 : isNeon ? #4C7DFF : isLight ? #2563EB : isClassic ? color.blue   : colIn2
base3 = isCustomTheme or colIn3 != #FFAA00 ? colIn3 : isNeon ? #FFAA00 : isLight ? #D97706 : isClassic ? color.orange : colIn3
base4 = isCustomTheme or colIn4 != #8C93A8 ? colIn4 : isNeon ? #8C93A8 : isLight ? #4B5563 : isClassic ? #434651      : colIn4
base5 = isCustomTheme or colIn5 != #2DD4BF ? colIn5 : isNeon ? #2DD4BF : isLight ? #0D9488 : isClassic ? color.teal   : colIn5
base6 = isCustomTheme or colIn6 != #B57BFF ? colIn6 : isNeon ? #B57BFF : isLight ? #7C3AED : isClassic ? color.maroon : colIn6
base7 = isCustomTheme or colIn7 != #FF6B9A ? colIn7 : isNeon ? #FF6B9A : isLight ? #DB2777 : isClassic ? color.navy   : colIn7

f_slopeCol(float s) =>
    s >= 0 ? color.from_gradient(s, 0.0, slopeSens, flatC, bullC) : color.from_gradient(s, -slopeSens, 0.0, bearC, flatC)

f_stateTxt(int c) =>
    na(c) ? "n/a" : c == 1 ? "BULLISH" : c == -1 ? "BEARISH" : c == 0 ? "CHOPPY" : "MIXED"

f_stateCol(int c) =>
    na(c) ? flatC : c == 1 ? bullC : c == -1 ? bearC : c == 0 ? panelText : mixC

f_stateArrow(int c) =>
    c == 1 ? "▲" : c == -1 ? "▼" : "•"

// Each average can be colored by its direction (the "by direction" ticks in section 2)
c1 = dirMa1 ? f_slopeCol(s1) : base1
c2 = dirMa2 ? f_slopeCol(s2) : base2
c3 = dirMa3 ? f_slopeCol(s3) : base3
c4 = dirMa4 ? f_slopeCol(s4) : base4
c5 = dirMa5 ? f_slopeCol(s5) : base5
c6 = dirMa6 ? f_slopeCol(s6) : base6
c7 = dirMa7 ? f_slopeCol(s7) : base7

// Readable text on any name tag color
f_textOn(color c) =>
    float lum = 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
    lum > 140 ? #0B0E14 : #FFFFFF

//==========================================================
// TREND CLOUDS  (work even if their lines are hidden)
//==========================================================
f_pick(string sel) =>
    switch sel
        A1 => ma1
        A2 => ma2
        A3 => ma3
        A4 => ma4
        A5 => ma5
        A6 => ma6
        => ma7

r1Fast = f_pick(r1FastSel)
r1Slow = f_pick(r1SlowSel)
r2Fast = f_pick(r2FastSel)
r2Slow = f_pick(r2SlowSel)

r1Bull = r1Fast > r1Slow
r2Bull = r2Fast > r2Slow

// Each cloud has its own on/off tick: it stays on even when its lines are hidden in section 2
f_shown(string sel) =>
    switch sel
        A1 => showMa1
        A2 => showMa2
        A3 => showMa3
        A4 => showMa4
        A5 => showMa5
        A6 => showMa6
        => showMa7

r1Vis = r1On
r2Vis = r2On

// Pullbacks: candle dips to one line during a trend but closes back beyond another (all user settings)
// Minimal: dips are measured against the 50 (wick touches it, candle closes back beyond it)
pbTouch = f_pick(pMin ? A3 : pbTouchSel)
pbHold  = f_pick(pMin ? A3 : pbHoldSel)
pbTolPx = pbTol * atr14
bool pbUpOk = pbTrend == "Bullish / Bearish reading" ? stateBull : pbTrend == "Cloud 1 color" ? r1Bull : true
bool pbDnOk = pbTrend == "Bullish / Bearish reading" ? stateBear : pbTrend == "Cloud 1 color" ? not r1Bull : true
volAvg  = ta.sma(volume, 20)
pbVolOk = not pbVol or (not na(volAvg) and volume < volAvg)
rthOk   = not rthOnly or session.ismarket
pbBullRaw = pbSide != "Downtrend only" and pbUpOk and low <= pbTouch + pbTolPx and close > pbHold and pbVolOk and rthOk
pbBearRaw = pbSide != "Uptrend only" and pbDnOk and high >= pbTouch - pbTolPx and close < pbHold and pbVolOk and rthOk
var int lastPbUp = -100000
var int lastPbDn = -100000
var bool pbUsedUp = false
var bool pbUsedDn = false
// A new trend resets "first pullback only". With "Any time" there is no trend check, so a new Bullish / Bearish reading counts.
upStart = pbTrend == "Any time" ? stateBull and not stateBull[1] : pbUpOk and not pbUpOk[1]
dnStart = pbTrend == "Any time" ? stateBear and not stateBear[1] : pbDnOk and not pbDnOk[1]
if upStart
    pbUsedUp := false
if dnStart
    pbUsedDn := false
pbBull = pbBullRaw and not pbBullRaw[1] and bar_index - lastPbUp >= pbGap and not (pbFirst and pbUsedUp)
pbBear = pbBearRaw and not pbBearRaw[1] and bar_index - lastPbDn >= pbGap and not (pbFirst and pbUsedDn)
if pbBull
    lastPbUp := bar_index
    pbUsedUp := true
if pbBear
    lastPbDn := bar_index
    pbUsedDn := true

// Signals on the chart wait for the candle to close (if that setting is on)
sigOk = not sigConfirm or barstate.isconfirmed

const float WEAK_T = 90.0
f_cloudT(float a, float b, float strongT) =>
    float t = atr14 > 0 ? math.min(math.abs(a - b) / (cloudRef * atr14), 1.0) : 0.0
    WEAK_T + (strongT - WEAK_T) * t

strongT1 = 100.0 - cloudOpac
strongT2 = math.min(100.0 - cloudOpac + 15.0, 95.0)
isGrad   = cloudStyle == "Fade"

t1 = f_cloudT(r1Fast, r1Slow, strongT1)
t2 = f_cloudT(r2Fast, r2Slow, strongT2)

f_cc(bool bull) =>
    muteChop and isChop ? flatC : bull ? bullC : bearC

col1Strong = color.new(f_cc(r1Bull), dimChop and isChop ? math.max(t1, 84.0) : t1)
col1Faint  = isGrad ? color.new(f_cc(r1Bull), 97) : col1Strong
col2Strong = color.new(f_cc(r2Bull), dimChop and isChop ? math.max(t2, 86.0) : t2)
col2Faint  = isGrad ? color.new(f_cc(r2Bull), 97) : col2Strong

// Invisible anchors for the clouds (so hiding a line never removes its cloud)
pR1F = plot(r1Vis ? r1Fast : na, "Cloud 1 Fast", display=display.none, editable=false)
pR1S = plot(r1Vis ? r1Slow : na, "Cloud 1 Slow", display=display.none, editable=false)
pR2F = plot(r2Vis ? r2Fast : na, "Cloud 2 Fast", display=display.none, editable=false)
pR2S = plot(r2Vis ? r2Slow : na, "Cloud 2 Slow", display=display.none, editable=false)

// Brightest at the faster line, fading toward the slower line
fill(pR2F, pR2S, math.max(r2Fast, r2Slow), math.min(r2Fast, r2Slow), r2Vis ? (r2Bull ? col2Strong : col2Faint) : na, r2Vis ? (r2Bull ? col2Faint : col2Strong) : na, "Cloud 2", editable=false)
fill(pR1F, pR1S, math.max(r1Fast, r1Slow), math.min(r1Fast, r1Slow), r1Vis ? (r1Bull ? col1Strong : col1Faint) : na, r1Vis ? (r1Bull ? col1Faint : col1Strong) : na, "Cloud 1", editable=false)

// One background layer: squeeze shading (only if turned on) wins over the optional trend tint
bgcolor(sqzOn and isSqz ? color.new(sqzC, 88) : bgOn and stateBull ? color.new(bullC, 95) : bgOn and stateBear ? color.new(bearC, 95) : na, title="Background", editable=false)

//==========================================================
// CANDLE COLORS  (fade, like the cloud)
//==========================================================
candleRaw = extAtr >= 0 ? color.from_gradient(extAtr, 0.0, candleFull, flatC, bullC) : color.from_gradient(extAtr, -candleFull, 0.0, bearC, flatC)
candleCol = muteChop and isChop ? flatC : dimChop and isChop ? color.from_gradient(0.45, 0.0, 1.0, flatC, candleRaw) : candleRaw
barcolor(candleOn ? candleCol : na, title="Candle Color", editable=false)

//==========================================================
// GLOW  (drawn on the chart only: no prices on the right edge, nothing in the legend)
//==========================================================
isBand  = lineLook == "Soft band"
glowKey = isBand or glowMode != "Off"
glowAll = isBand or glowMode == "All lines"
uT = isBand ? 62 : glowT
uW = isBand ? bandW : glowW

plot(showMa1 and glowKey ? ma1 : na, "Average 1 Glow", color.new(c1, uT), uW, display=display.pane, editable=false)
plot(showMa2 and glowKey ? ma2 : na, "Average 2 Glow", color.new(c2, uT), uW, display=display.pane, editable=false)
plot(showMa3 and glowAll ? ma3 : na, "Average 3 Glow", color.new(c3, uT), uW, display=display.pane, editable=false)
plot(showMa4 and glowAll ? ma4 : na, "Average 4 Glow", color.new(c4, uT), uW + 1, display=display.pane, editable=false)

//==========================================================
// LINES  (one price each on the right edge)
//==========================================================
dispLine = showTags ? display.all : display.all - display.price_scale

plot(showMa1 ? ma1 : na, A1, isBand ? color.new(c1, 30) : c1, isBand ? 1 : 2, display=showMa1 ? dispLine : display.none, editable=false)
plot(showMa2 ? ma2 : na, A2, isBand ? color.new(c2, 30) : c2, isBand ? 1 : 2, display=showMa2 ? dispLine : display.none, editable=false)
plot(showMa3 ? ma3 : na, A3, isBand ? color.new(c3, 30) : c3, isBand ? 1 : 2, display=showMa3 ? dispLine : display.none, editable=false)
plot(showMa4 ? ma4 : na, A4, isBand ? color.new(c4, 30) : c4, isBand ? 1 : 3, display=showMa4 ? dispLine : display.none, editable=false)
plot(showMa5 ? ma5 : na, A5, c5, 2, display=showMa5 ? dispLine : display.none, editable=false)
plot(showMa6 ? ma6 : na, A6, c6, 2, display=showMa6 ? dispLine : display.none, editable=false)
plot(showMa7 ? ma7 : na, A7, c7, 2, display=showMa7 ? dispLine : display.none, editable=false)

plot(htf1, "Multi-Timeframe MA 1", colMtf1, 2, plot.style_stepline, display=showMtf1 ? dispLine : display.none)
plot(htf2, "Multi-Timeframe MA 2", colMtf2, 2, plot.style_stepline, display=showMtf2 ? dispLine : display.none)
plot(htf3, "Multi-Timeframe MA 3", colMtf3, 2, plot.style_stepline, display=showMtf3 ? dispLine : display.none)
plot(htf4, "Multi-Timeframe MA 4", colMtf4, 2, plot.style_stepline, display=showMtf4 ? dispLine : display.none)

//==========================================================
// MARKERS
//==========================================================
r1Up = ta.crossover(r1Fast, r1Slow)
r1Dn = ta.crossunder(r1Fast, r1Slow)
r2Up = ta.crossover(r2Fast, r2Slow)
r2Dn = ta.crossunder(r2Fast, r2Slow)

dispFlip = showFlips ? display.pane : display.none
plotshape(r1Vis and r1Up and sigOk and rthOk, "Cloud 1 Turned Up", shape.triangleup,   location.belowbar, bullC, size=size.tiny, display=dispFlip, editable=false)
plotshape(r1Vis and r1Dn and sigOk and rthOk, "Cloud 1 Turned Down", shape.triangledown, location.abovebar, bearC, size=size.tiny, display=dispFlip, editable=false)

// Glowing pullback dots: a soft halo behind a bright core, centered on the same spot
dispPb = pbOn ? display.pane : display.none
pbOnLine = pbPos == "On the line it touched"
pbOffs   = pbPos == "Tight to the candle" ? 0.15 : 0.45
pbBullY = pbBull and sigOk ? (pbOnLine ? pbTouch : low  - pbOffs * atr14) : na
pbBearY = pbBear and sigOk ? (pbOnLine ? pbTouch : high + pbOffs * atr14) : na
plotshape(pbBullY, "Pullback Up Glow",   shape.circle, location.absolute, color.new(bullC, 72), size=size.small, display=dispPb, editable=false)
plotshape(pbBullY, "Pullback Up",        shape.circle, location.absolute, bullC,                 size=size.tiny,  display=dispPb, editable=false)
plotshape(pbBearY, "Pullback Down Glow", shape.circle, location.absolute, color.new(bearC, 72), size=size.small, display=dispPb, editable=false)
plotshape(pbBearY, "Pullback Down",      shape.circle, location.absolute, bearC,                 size=size.tiny,  display=dispPb, editable=false)

//==========================================================
// RS RATING, MULTI-TIMEFRAME, EARNINGS
//==========================================================
// RS score: weighted 1-year performance (last 3 months count double), stock vs S&P 500. 100 = same as the market.
f_rsPerf() =>
    float c0 = ta.valuewhen(barstate.isfirst, close, 0)
    0.4 * close / nz(close[63], c0) + 0.2 * close / nz(close[126], c0) + 0.2 * close / nz(close[189], c0) + 0.2 * close / nz(close[252], c0)
rsStockPerf = request.security(syminfo.tickerid, "D", f_rsPerf(), ignore_invalid_symbol=true)
rsSpxPerf   = request.security("SP:SPX", "D", f_rsPerf(), ignore_invalid_symbol=true)
rsScore     = rsSpxPerf > 0 ? rsStockPerf / rsSpxPerf * 100 : na
// Chart signals (strip, stars, RS on tags, grade point): on intraday charts they use the previous day's
// finished score, so nothing drawn in the past changes after a reload. Daily and up: the candle's own day.
rsStockPerfC = timeframe.isintraday ? request.security(syminfo.tickerid, "D", f_rsPerf()[1], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true) : rsStockPerf
rsSpxPerfC   = timeframe.isintraday ? request.security("SP:SPX", "D", f_rsPerf()[1], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true) : rsSpxPerf
rsScoreC     = rsSpxPerfC > 0 ? rsStockPerfC / rsSpxPerfC * 100 : na

// The 7 cutoff scores it takes to rate 99, 90, 70, 50, 30, 10 and 1 across ~6,100 US stocks.
// Live: Fred6724's free daily feed (github.com/Fred6725/relative-strength), read the way his RS Rating script does.
// If the feed is late, the last cutoffs it sent are still used (they are fresher than any backup).
// Backup: real cutoffs saved in the code (Oct 8, 2026), used only if the feed can't be read at all.
const float RSB_99 = 212.35
const float RSB_90 = 121.49
const float RSB_70 = 96.99
const float RSB_50 = 88.88
const float RSB_30 = 76.26
const float RSB_10 = 48.92
const float RSB_01 = 17.15
f_rsCuts() =>
    float sv = request.seed("seed_fred6725_rs_rating", "RSRATING", close, true)
    float st = request.seed("seed_fred6725_rs_rating", "RSRATING", time, true)
    array<float> vals = array.new<float>()
    float lastT = na
    for i = 0 to 44
        float v = sv[i]
        if na(lastT) and not na(st[i])
            lastT := st[i]
        if not na(v) and v != 0 and vals.size() < 7 and not vals.includes(v)
            vals.push(v)
    bool ok = vals.size() == 7
    if ok
        vals.sort(order.descending)
    while vals.size() < 7
        vals.push(na)
    [ok ? 1.0 : 0.0, lastT, vals.get(0), vals.get(1), vals.get(2), vals.get(3), vals.get(4), vals.get(5), vals.get(6)]
[rsOk, rsFeedT, rsL99, rsL90, rsL70, rsL50, rsL30, rsL10, rsL01] = request.security("SP:SPX", "D", f_rsCuts())
rsDaysOld = na(rsFeedT) ? na : (timenow - rsFeedT) / 86400000.0
rsStale   = rsOk != 1.0 or na(rsDaysOld) or rsDaysOld > 7
rsHaveFeed = rsOk == 1.0
rsC99 = rsHaveFeed ? rsL99 : RSB_99
rsC90 = rsHaveFeed ? rsL90 : RSB_90
rsC70 = rsHaveFeed ? rsL70 : RSB_70
rsC50 = rsHaveFeed ? rsL50 : RSB_50
rsC30 = rsHaveFeed ? rsL30 : RSB_30
rsC10 = rsHaveFeed ? rsL10 : RSB_10
rsC01 = rsHaveFeed ? rsL01 : RSB_01
// Place the score between the two cutoffs it falls between. Rating curve from Fred6724's RS Rating script
// (Mozilla Public License 2.0), calibrated to the real spread of ~6,100 stocks, so the numbers match his.
f_rsBand(float x, float taller, float smaller, float rUp, float rDn, float w) =>
    float sm = x + (x - smaller) * w
    if sm > taller - 1
        sm := taller - 1
    float k1 = smaller / rDn
    float k2 = (taller - 1) / rUp
    float k3 = (k1 - k2) / (taller - 1 - smaller)
    math.max(rDn, math.min(rUp, sm / (k1 - k3 * (x - smaller))))
f_rsRate(float x) =>
    float rr = na(x) ? na : x >= rsC99 ? 99.0 : x >= rsC90 ? f_rsBand(x, rsC99, rsC90, 98, 90, 0.33) : x >= rsC70 ? f_rsBand(x, rsC90, rsC70, 89, 70, 2.1) : x >= rsC50 ? f_rsBand(x, rsC70, rsC50, 69, 50, 0) : x >= rsC30 ? f_rsBand(x, rsC50, rsC30, 49, 30, 0) : x >= rsC10 ? f_rsBand(x, rsC30, rsC10, 29, 10, 0) : x > rsC01 ? f_rsBand(x, rsC10, rsC01, 9, 2, 0) : 1.0
    na(rr) ? na : float(math.max(1, math.min(99, math.round(rr))))
rsRating  = f_rsRate(rsScore)    // dashboard, badge, screener: the latest rating
rsRatingC = f_rsRate(rsScoreC)   // things drawn on candles (see above)

//==========================================================
// RS ON THE CHART  (leading dots, badge, leader stars, color strip)
//==========================================================
const color rsOrange = #FF8A00
rsSpxNow = request.security("SP:SPX", timeframe.period, close, ignore_invalid_symbol=true)
rsLine   = rsSpxNow > 0 ? close / rsSpxNow : na
rsLook   = timeframe.isweekly and rsDotLen == 250 ? 52 : rsDotLen
// Skip the S&P 500 itself and funds that track it (their RS line barely moves, so every bar would be a "new high")
rsHi     = ta.highest(rsLine, rsLook)
rsLo     = ta.lowest(rsLine, rsLook)
rsCorr   = ta.correlation(ta.roc(close, 1), ta.roc(rsSpxNow, 1), 50)   // day-to-day moves, not price levels
pxHi     = ta.highest(high, rsLook)
rsNewHi  = not na(rsLine) and rsLine >= rsHi
rsMoves  = not na(rsLo) and rsLo > 0 and (rsHi - rsLo) / rsLo > 0.005 and nz(rsCorr) < 0.98
rsLead   = rsDots and rsNewHi and rsMoves and (rsDotMode == "Every RS new high" or high < pxHi) and sigOk and rthOk
plotshape(rsLead, "RS Leads Glow", shape.circle, location.abovebar, color.new(rsOrange, 70), size=size.small, display=display.pane, editable=false)
plotshape(rsLead, "RS Leads Price", shape.circle, location.abovebar, rsOrange, size=size.tiny, display=display.pane, editable=false)
rsStripC = na(rsRatingC) ? na : rsRatingC >= 80 ? bullC : rsRatingC < 40 ? bearC : panelMute
plotshape(rsStrip and not na(rsRatingC), "RS Strip", shape.square, location.bottom, color.new(rsStripC, 15), size=size.tiny, display=display.pane, editable=false)
var array<label> starLbls = array.new<label>()
starOffs = pbGrade ? 1.05 : 0.55   // sits past the grade letter when grades are on
if rsStar and pbOn and not na(rsRatingC)
    if not na(pbBullY) and rsRatingC >= 80
        starLbls.push(label.new(bar_index, pbBullY - starOffs * atr14, "★", style=label.style_none, textcolor=rsOrange, size=size.small))
    if not na(pbBearY) and rsRatingC <= 20
        starLbls.push(label.new(bar_index, pbBearY + starOffs * atr14, "★", style=label.style_none, textcolor=rsOrange, size=size.small))
    while starLbls.size() > 60
        label.delete(starLbls.shift())
var label rsBadgeLbl = na
if barstate.islast
    label.delete(rsBadgeLbl)
    if rsBadge and not na(rsRating)
        color bc = rsRating >= 80 ? bullC : rsRating < 40 ? bearC : panelMute
        rsBadgeLbl := label.new(bar_index, high + 0.8 * atr14, "RS " + str.tostring(rsRating, "#") + (rsStale ? "*" : ""), style=label.style_label_down, color=color.new(bc, 10), textcolor=f_textOn(bc), size=size.small, tooltip="RS Rating (1 to 99). Hover the RS row in the dashboard for details.")
mtfC1 = mtfOn and mtfOn1 ? f_htfState(mtfTf1) : na
mtfC2 = mtfOn and mtfOn2 ? f_htfState(mtfTf2) : na
mtfC3 = mtfOn and mtfOn3 ? f_htfState(mtfTf3) : na
mtfC4 = mtfOn and mtfOn4 ? f_htfState(mtfTf4) : na
// Calendar days to the report date (the report date is read as a UTC date, today as the exchange's date)
f_dayNum(int t, string tz) => int(timestamp("UTC", year(t, tz), month(t, tz), dayofmonth(t, tz)) / 86400000)
earnT    = earnings.future_time
earnDays = na(earnT) ? na : f_dayNum(int(earnT), "UTC") - f_dayNum(timenow, syminfo.timezone)

//==========================================================
// SWING STATS  (daily numbers for the dashboard, section 13)
//==========================================================
f_swingD() =>
    float atrD  = ta.atr(swAtrLen)
    float adrD  = (ta.sma(high / low, swAdrLen) - 1) * 100
    float m50   = getMA(close, 50, maType)
    float hi52  = ta.highest(high, math.min(252, bar_index + 1))
    float avgV  = ta.sma(volume, swVolLen)
    float avgDV = ta.sma(close * volume, swVolLen)
    float upV   = math.sum(close > close[1] ? volume : 0.0, swVolLen)
    float dnV   = math.sum(close < close[1] ? volume : 0.0, swVolLen)
    // ATR is the standard one (today included, same as TradingView's ATR). The daily-range and volume
    // averages use the days before today, so a half-finished day does not drag them down.
    [atrD, adrD[1], m50, hi52, avgV[1], avgDV[1], upV, dnV, (high / low - 1) * 100, close, volume]
[dAtr, dAdr, d50, dHi52, dAvgV, dAvgDV, dUpV, dDnV, dRange, dClose, dVol] = request.security(syminfo.tickerid, "D", f_swingD(), ignore_invalid_symbol=true)
mktCode = swMkt ? request.security("SP:SPX", "D", f_stateCode(), ignore_invalid_symbol=true) : na

// Short big numbers: 8.3M, 2.1B, 512K, 1.4T
f_big(float x) =>
    float a = math.abs(x)
    a >= 1e12 ? str.tostring(x / 1e12, "#.#") + "T" : a >= 1e9 ? str.tostring(x / 1e9, "#.#") + "B" : a >= 1e8 ? str.tostring(x / 1e6, "#") + "M" : a >= 1e6 ? str.tostring(x / 1e6, "#.#") + "M" : a >= 1e3 ? str.tostring(x / 1e3, "#") + "K" : str.tostring(x, "#")

//==========================================================
// DOT QUALITY GRADES  (A / B / C)
//==========================================================
gUp  = pbBull
gHtf = not na(htfCode) and ((gUp and htfCode == 1) or (not gUp and htfCode == -1))
gStr = adxVal >= 25
gVol = not na(volAvg) and volume < volAvg
gRs  = not na(rsScoreC) and ((gUp and rsScoreC > 100) or (not gUp and rsScoreC < 100))
gPts = (gHtf ? 1 : 0) + (gStr ? 1 : 0) + (gVol ? 1 : 0) + (gRs ? 1 : 0)
gTxt = gPts >= 3 ? "A" : gPts == 2 ? "B" : "C"
var array<label> gradeLbls = array.new<label>()
if pbGrade and pbOn and (not na(pbBullY) or not na(pbBearY))
    float gy = gUp ? pbBullY - 0.5 * atr14 : pbBearY + 0.5 * atr14
    color gc = gPts >= 3 ? (gUp ? bullC : bearC) : gPts == 2 ? mixC : flatC
    gradeLbls.push(label.new(bar_index, gy, gTxt, style=label.style_label_center, color=color.new(#000000, 100), textcolor=gc, size=size.small))
    while gradeLbls.size() > 120
        label.delete(gradeLbls.shift())

//==========================================================
// PULLBACK DOT SCOREBOARD  (overall + by grade)
//==========================================================
const int SB_MAX_AGE = 60
var array<float> sbWinLvl = array.new<float>()
var array<float> sbLosLvl = array.new<float>()
var array<int>   sbDir    = array.new<int>()
var array<int>   sbStart  = array.new<int>()
var array<int>   sbGrd    = array.new<int>()
var array<int>   sbRes    = array.new<int>()
var array<int>   sbResA   = array.new<int>()
var array<int>   sbResB   = array.new<int>()
var array<int>   sbResC   = array.new<int>()
if barstate.isconfirmed
    int i = sbDir.size() - 1
    while i >= 0
        int   d  = sbDir.get(i)
        float wl = sbWinLvl.get(i)
        float ll = sbLosLvl.get(i)
        bool hitW = d == 1 ? high >= wl : low <= wl
        bool hitL = d == 1 ? low <= ll : high >= ll
        bool expired = bar_index - sbStart.get(i) > SB_MAX_AGE
        if hitW or hitL or expired
            if hitW or hitL
                int res = hitL ? 0 : 1
                int gr  = sbGrd.get(i)
                sbRes.push(res)
                if gr == 3
                    sbResA.push(res)
                else if gr == 2
                    sbResB.push(res)
                else
                    sbResC.push(res)
            sbDir.remove(i)
            sbWinLvl.remove(i)
            sbLosLvl.remove(i)
            sbStart.remove(i)
            sbGrd.remove(i)
        i -= 1
    if pbBull or pbBear
        int d = pbBull ? 1 : -1
        sbDir.push(d)
        sbWinLvl.push(close + d * scoreWin * atr14)
        sbLosLvl.push(close - d * scoreLos * atr14)
        sbStart.push(bar_index)
        sbGrd.push(gPts >= 3 ? 3 : gPts == 2 ? 2 : 1)
    while sbRes.size() > scoreN
        sbRes.shift()
    while sbResA.size() > scoreN
        sbResA.shift()
    while sbResB.size() > scoreN
        sbResB.shift()
    while sbResC.size() > scoreN
        sbResC.shift()
sbCount = sbRes.size()
sbRate  = sbCount > 0 ? sbRes.sum() * 100.0 / sbCount : na

f_rateTxt(array<int> a, string g) =>
    a.size() == 0 ? g + " –" : g + " " + str.tostring(math.round(a.sum() * 100.0 / a.size())) + "%"

//==========================================================
// ALERTS  (one alert covers everything you tick in settings)
//==========================================================
string tkr = syminfo.ticker + " (" + f_tfName(timeframe.period) + ")"
var int lastMain = na
bool mainChanged = stateCode != 2 and stateCode != lastMain
if stateCode != 2
    lastMain := stateCode
if alState and rthOk and (alMixed ? stateCode != stateCode[1] : mainChanged)
    alert("Biryani: " + tkr + " trend is now " + f_stateTxt(stateCode), alert.freq_once_per_bar_close)
if alCloud and rthOk and r1On and (r1Up or r1Dn)
    alert("Biryani: " + tkr + " Cloud 1 turned " + (r1Up ? "up (green)" : "down (pink)"), alert.freq_once_per_bar_close)
if alCloud and rthOk and r2On and (r2Up or r2Dn)
    alert("Biryani: " + tkr + " Cloud 2 turned " + (r2Up ? "up (green)" : "down (pink)"), alert.freq_once_per_bar_close)
if alPb and (pbBull or pbBear)
    alert("Biryani: " + tkr + (pbBull ? " pullback in an uptrend (dip held)" : " pullback in a downtrend (pop failed)"), alert.freq_once_per_bar_close)
if alSqz and rthOk and isSqz and not isSqz[1]
    alert("Biryani: " + tkr + " squeeze started (lines bunched up)", alert.freq_once_per_bar_close)
if alSqz and rthOk and not isSqz and isSqz[1]
    alert("Biryani: " + tkr + " squeeze ended", alert.freq_once_per_bar_close)

//==========================================================
// TREND CHANGE TAGS
//==========================================================
var array<label> tagLbls = array.new<label>()
if tagOn and mainChanged and sigOk and rthOk and not na(stateCode[1])
    bool tUp = stateCode == 1
    bool tDn = stateCode == -1
    color tc = tUp ? bullC : tDn ? bearC : chartLight ? #111827 : #E6E9EF
    string tt = (tUp ? "Bullish" : tDn ? "Bearish" : "Choppy") + (rsTagOn and not na(rsRatingC) ? " · RS " + str.tostring(rsRatingC, "#") : "")
    float ty = tUp ? low - 0.9 * atr14 : high + 0.9 * atr14
    tagLbls.push(label.new(bar_index, ty, tt, style=tUp ? label.style_label_up : label.style_label_down, color=color.new(tc, 82), textcolor=tc, size=size.tiny))
    while tagLbls.size() > 50
        label.delete(tagLbls.shift())

//==========================================================
// PREVIOUS DAY HIGH / LOW / CLOSE
//==========================================================
[pdH, pdL, pdC] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
pdOk = pdOn and timeframe.isintraday
var array<line>  pdLines = array.new<line>()
var array<label> pdTags  = array.new<label>()
var line pdHl = na
var line pdLl = na
var line pdCl = na
if pdOk and timeframe.change("D") and not na(pdH)
    if not na(pdHl)
        line.set_x2(pdHl, bar_index - 1)
        line.set_x2(pdLl, bar_index - 1)
        line.set_x2(pdCl, bar_index - 1)
    pdHl := line.new(bar_index, pdH, bar_index + 5, pdH, color=color.new(mixC, 15), width=1, style=line.style_dashed)
    pdLl := line.new(bar_index, pdL, bar_index + 5, pdL, color=color.new(mixC, 15), width=1, style=line.style_dashed)
    pdCl := line.new(bar_index, pdC, bar_index + 5, pdC, color=color.new(panelMute, 15), width=1, style=line.style_dotted)
    pdLines.push(pdHl)
    pdLines.push(pdLl)
    pdLines.push(pdCl)
    if pdLbl
        pdTags.push(label.new(bar_index, pdH, "Prev high " + str.tostring(pdH, format.mintick), style=label.style_label_lower_left, color=color.new(#000000, 100), textcolor=mixC, size=size.tiny))
        pdTags.push(label.new(bar_index, pdL, "Prev low " + str.tostring(pdL, format.mintick), style=label.style_label_upper_left, color=color.new(#000000, 100), textcolor=mixC, size=size.tiny))
        pdTags.push(label.new(bar_index, pdC, "Prev close " + str.tostring(pdC, format.mintick), style=label.style_label_lower_left, color=color.new(#000000, 100), textcolor=panelMute, size=size.tiny))
    while pdLines.size() > pdDays * 3
        line.delete(pdLines.shift())
    while pdTags.size() > pdDays * 3
        label.delete(pdTags.shift())
if pdOk and not na(pdHl)
    line.set_x2(pdHl, bar_index + 5)
    line.set_x2(pdLl, bar_index + 5)
    line.set_x2(pdCl, bar_index + 5)

//==========================================================
// AUTO FIB EXTENSIONS  (BETA; lines and labels: costs no plots)
//==========================================================
fibFresh = fibDaily == "Yes" or (fibDaily == "Auto (yes below 1 hour)" and timeframe.isintraday and timeframe.in_seconds() < 3600)

// 1) Swing finder. A high counts once a candle CLOSES "fibSwing" average candles below it
//    (so a single wick does not count). Lows the same way.
var int   zzDir  = 0
var float zzHi   = na
var int   zzHiB  = na
var float zzLo   = na
var int   zzLoB  = na
var float lsh    = na   // up-leg: lowest low since the high
var int   lshB   = na
var float hal    = na   // up-leg: highest high after that low
var int   halB   = na
var float hsl    = na   // down-leg: highest high since the low
var int   hslB   = na
var float lah    = na   // down-leg: lowest low after that high
var int   lahB   = na
var float legLo  = na
var int   legLoB = na
var float loBH   = na
var int   loBHB  = na
var float legHi  = na
var int   legHiB = na
var float hiBL   = na
var int   hiBLB  = na
var float swHi   = na   // last swing high / low
var int   swHiB  = na
var float swLo   = na
var int   swLoB  = na
float newLo  = na
int   newLoB = na
float newHi  = na
int   newHiB = na
if fibOn and not na(atr14)
    float thr = atr14 * fibSwing
    if zzDir == 0
        zzDir  := 1
        zzHi   := high
        zzHiB  := bar_index
        legLo  := low
        legLoB := bar_index
    else if zzDir == 1
        if low < legLo
            legLo  := low
            legLoB := bar_index
        if high > zzHi
            zzHi  := high
            zzHiB := bar_index
            loBH  := legLo
            loBHB := legLoB
            lsh   := na
            hal   := na
        else
            if na(lsh) or low < lsh
                lsh  := low
                lshB := bar_index
                hal  := na
            else if na(hal) or high > hal
                hal  := high
                halB := bar_index
            if zzHi - close >= thr
                newHi  := zzHi
                newHiB := zzHiB
                if not na(loBH) and not na(swLo) and loBH < swLo
                    swLo  := loBH
                    swLoB := loBHB
                zzDir  := -1
                zzLo   := lsh
                zzLoB  := lshB
                hsl    := hal
                hslB   := halB
                lah    := na
                legHi  := high
                legHiB := bar_index
                hiBL   := na
    else
        if high > legHi
            legHi  := high
            legHiB := bar_index
        if low < zzLo
            zzLo  := low
            zzLoB := bar_index
            hiBL  := legHi
            hiBLB := legHiB
            hsl   := na
            lah   := na
        else
            if na(hsl) or high > hsl
                hsl  := high
                hslB := bar_index
                lah  := na
            else if na(lah) or low < lah
                lah  := low
                lahB := bar_index
            if close - zzLo >= thr
                newLo  := zzLo
                newLoB := zzLoB
                if not na(hiBL) and not na(swHi) and hiBL > swHi
                    swHi  := hiBL
                    swHiB := hiBLB
                zzDir  := 1
                zzHi   := hsl
                zzHiB  := hslB
                lsh    := lah
                lshB   := lahB
                hal    := na
                legLo  := low
                legLoB := bar_index
                loBH   := na

// Day high / low (for "Start fresh each day")
var int   sesStart = na
var float sesLo  = na
var int   sesLoB = na
var float sesHi  = na
var int   sesHiB = na
bool fibNewDay = fibOn and fibFresh and timeframe.change("D")
if fibNewDay or na(sesLo)
    sesStart := bar_index
    sesLo  := low
    sesLoB := bar_index
    sesHi  := high
    sesHiB := bar_index
else
    if low < sesLo
        sesLo  := low
        sesLoB := bar_index
    if high > sesHi
        sesHi  := high
        sesHiB := bar_index

// 2) Ladders. Up ladder = higher lows, with the highest high between each pair.
//    Down ladder = lower highs, stored as negative prices so one routine serves both.
//    meta = [last locked step, highest high carried over, its bar]
var array<float> buP  = array.new<float>()
var array<int>   buB  = array.new<int>()
var array<float> buXP = array.new<float>()
var array<int>   buXB = array.new<int>()
var array<float> buM  = array.from(0.0, na, na)
var array<float> beP  = array.new<float>()
var array<int>   beB  = array.new<int>()
var array<float> beXP = array.new<float>()
var array<int>   beXB = array.new<int>()
var array<float> beM  = array.from(0.0, na, na)

f_ladderReset(array<float> nP, array<int> nB, array<float> xP, array<int> xB, array<float> meta, float p, int pb) =>
    nP.clear()
    nB.clear()
    xP.clear()
    xB.clear()
    meta.set(0, 0.0)
    meta.set(1, na)
    meta.set(2, na)
    if not na(p)
        nP.push(p)
        nB.push(pb)
        xP.push(na)
        xB.push(na)
    true

// Adds a new swing low p (bar pb). hp / hb = the swing high since the last swing low.
// - A fib is locked once price makes a new high after it: a later dip below its low does not erase it.
// - The trend starts over only when a pullback erases more than "resetPct" of a big leg up
//   (a leg that is at least half of the whole trend), or breaks below where the trend started.
f_ladderAdd(array<float> nP, array<int> nB, array<float> xP, array<int> xB, array<float> meta, float p, int pb, float hp, int hb, float resetPct) =>
    float cH  = hp
    int   cHB = hb
    if nP.size() == 0
        f_ladderReset(nP, nB, xP, xB, meta, p, pb)
    else
        float cy = meta.get(1)
        if not na(cy) and (na(cH) or cy > cH)
            cH  := cy
            cHB := int(meta.get(2))
        int n = nP.size()
        int k = n - 1
        while k >= 0 and nP.get(k) >= p
            k -= 1
        if k < 0
            f_ladderReset(nP, nB, xP, xB, meta, p, pb)
        else
            int ci = math.min(int(meta.get(0)), n - 1)
            int bi = math.min(ci, k)
            float mx  = cH
            int   mxB = cHB
            float top = cH
            if n > 1
                for j = 1 to n - 1
                    float xv = xP.get(j)
                    if j > bi and (na(mx) or xv > mx)
                        mx  := xv
                        mxB := xB.get(j)
                    if na(top) or xv > top
                        top := xv
            if not na(mx) and mx > p
                float base = nP.get(bi)
                bool restart = (mx - p) / (mx - base) * 100 >= resetPct and (mx - base) >= 0.5 * (top - nP.get(0))
                if restart
                    f_ladderReset(nP, nB, xP, xB, meta, p, pb)
                else if ci > k
                    // dipped below a locked low: keep the ladder as drawn
                    meta.set(1, mx)
                    meta.set(2, mxB)
                else
                    // unlocked lows that just got undercut no longer count; their highs carry over
                    float h2  = cH
                    int   h2B = cHB
                    while nP.size() - 1 > k
                        nP.pop()
                        nB.pop()
                        float ph  = xP.pop()
                        int   phb = xB.pop()
                        if na(h2) or ph > h2
                            h2  := ph
                            h2B := phb
                    if not na(h2) and h2 > p
                        int m = nP.size()
                        float pm = na
                        if m - 1 > ci
                            for j = ci + 1 to m - 1
                                float xv = xP.get(j)
                                if na(pm) or xv > pm
                                    pm := xv
                        int newCi = not na(pm) and h2 > pm ? m - 1 : math.min(ci, m - 1)
                        nP.push(p)
                        nB.push(pb)
                        xP.push(h2)
                        xB.push(h2B)
                        // keep memory small: merge an old middle step (the first 5 and the newest stay exact)
                        if nP.size() > 100 and newCi > 6
                            nP.remove(5)
                            nB.remove(5)
                            float mP = xP.remove(5)
                            int   mB = xB.remove(5)
                            if mP > xP.get(5)
                                xP.set(5, mP)
                                xB.set(5, mB)
                            newCi -= 1
                        meta.set(0, newCi)
                        meta.set(1, na)
                        meta.set(2, na)
    true

if fibNewDay
    f_ladderReset(buP, buB, buXP, buXB, buM, na, na)
    f_ladderReset(beP, beB, beXP, beXB, beM, na, na)
// fresh day: swings from yesterday do not start today's ladder
if fibFresh and not na(newLo) and newLoB < sesStart
    swLo  := newLo
    swLoB := newLoB
    newLo := na
if fibFresh and not na(newHi) and newHiB < sesStart
    swHi  := newHi
    swHiB := newHiB
    newHi := na
if fibOn and not na(newLo)
    // fresh day: if the day's low came before the last swing high, the trend starts there
    if fibFresh and buP.size() == 0 and sesLo < newLo and sesLoB >= sesStart and not na(swHiB) and swHiB > sesLoB
        f_ladderReset(buP, buB, buXP, buXB, buM, sesLo, sesLoB)
    f_ladderAdd(buP, buB, buXP, buXB, buM, newLo, newLoB, swHi, swHiB, fibReset)
    swLo  := newLo
    swLoB := newLoB
if fibOn and not na(newHi)
    if fibFresh and beP.size() == 0 and sesHi > newHi and sesHiB >= sesStart and not na(swLoB) and swLoB > sesHiB
        f_ladderReset(beP, beB, beXP, beXB, beM, -sesHi, sesHiB)
    f_ladderAdd(beP, beB, beXP, beXB, beM, -newHi, newHiB, -swLo, swLoB, fibReset)
    swHi  := newHi
    swHiB := newHiB

// Levels typed in settings
var array<float>  fibR = array.new<float>()
var array<string> fibN = array.new<string>()
if barstate.isfirst
    for part in str.split(str.replace_all(fibLvls, " ", ""), ",")
        float v = str.tonumber(part)
        if not na(v)
            fibR.push(v)
            fibN.push(part)

var int fibTrend = 0
if stateCode == 1
    fibTrend := 1
else if stateCode == -1
    fibTrend := -1

// Draw (only on the last candle, so it always shows the current ladder)
var array<line>  fibLines = array.new<line>()
var array<label> fibTags  = array.new<label>()
if barstate.islast
    for l in fibLines
        line.delete(l)
    fibLines.clear()
    for t in fibTags
        label.delete(t)
    fibTags.clear()
    if fibOn
        bool useUp = fibDir == "Uptrends only" or (fibDir == "Follow the trend reading" and fibTrend >= 0)
        float sg = useUp ? 1.0 : -1.0
        array<float> nP = useUp ? buP : beP
        array<int>   nB = useUp ? buB : beB
        array<float> xP = useUp ? buXP : beXP
        array<int>   xB = useUp ? buXB : beXB
        color fc    = useUp ? fibUpC : fibDnC
        color pathC = chartLight ? color.new(#374151, 25) : color.new(#FFFFFF, 30)
        int n = nP.size() - 1
        if n >= 1
            bool fromStart = fibFrom == "Start of the trend"
            int k0 = fromStart ? 1 : math.max(1, n - fibCount + 1)
            int k1 = fromStart ? math.min(n, fibCount) : n
            int xEnd = bar_index + 15
            for k = k0 to k1
                float a  = nP.get(k - 1) * sg
                float b  = xP.get(k) * sg
                float c  = nP.get(k) * sg
                int   ab = nB.get(k - 1)
                int   bb = xB.get(k)
                int   cb = nB.get(k)
                if fibPath
                    fibLines.push(line.new(ab, a, bb, b, color=pathC, width=2))
                    fibLines.push(line.new(bb, b, cb, c, color=pathC, width=2))
                for [i, r] in fibR
                    float lv = c + r * (b - a)
                    fibLines.push(line.new(bb, lv, xEnd, lv, color=color.new(fc, 10), width=1))
                    if fibLbl
                        fibTags.push(label.new(xEnd, lv, fibN.get(i) + " (" + str.tostring(lv, format.mintick) + ")", style=label.style_label_left, color=color.new(#000000, 100), textcolor=fc, size=size.small))

//==========================================================
// PINE SCREENER VALUES  (hidden from the chart, readable by the Pine Screener)
//==========================================================
dispScr = scrOn ? display.data_window : display.none
plot(stateCode, "Screener Trend", color=#8A93A6, display=dispScr, editable=false)
plot(pbBull ? 1 : pbBear ? -1 : 0, "Screener Pullback dot", color=#8A93A6, display=dispScr, editable=false)
plot(adxVal, "Screener Trend strength", color=#8A93A6, display=dispScr, editable=false)
plot(rsRating, "Screener RS Rating", color=#8A93A6, display=dispScr, editable=false)

//==========================================================
// RANGE CHANNEL  (lines and boxes: costs no plots)
//==========================================================
// Its own choppy check (trend strength below the section 6 number), so it works even when
// "Spot choppy markets" is off. Same early-trend rule as the trend reading.
rngChop = adxVal < adxMin and not (earlyOn and adxRising)
var int chopAge = 0
var int rngEnd  = na   // bar where the last channel froze: a new one only uses candles after it
chopAge := rngChop ? chopAge + 1 : 0
rngSrcHi = rngEdge == "Wicks" ? high : math.max(open, close)
rngSrcLo = rngEdge == "Wicks" ? low  : math.min(open, close)
rngRoom  = na(rngEnd) ? 400 : bar_index - rngEnd
rngLen   = math.max(1, math.min(chopAge + rngPre, rngRoom, 400))
rngHiN   = ta.highest(rngSrcHi, rngLen)
rngLoN   = ta.lowest(rngSrcLo, rngLen)

const int RNG_END  = 3
const int RNG_EXT  = 5
var bool  rngLive  = false
var float rngHi    = na
var float rngLo    = na
var int   rngLeft  = na
var int   rngOff   = 0
var box   rngBox   = na
var line  rngTopG  = na
var line  rngTop   = na
var line  rngBotG  = na
var line  rngBot   = na
var label rngTopL  = na
var label rngBotL  = na
var array<box>  rngBoxes = array.new<box>()
var array<line> rngLines = array.new<line>()
chanC = #8A93A6

if rngOn
    if not rngLive
        if rngChop and chopAge >= rngMin and not na(rngHiN) and not na(rngLoN)
            rngLive := true
            rngHi   := rngHiN
            rngLo   := rngLoN
            rngLeft := bar_index - rngLen + 1
            rngOff  := 0
            int rx = bar_index + RNG_EXT
            rngBox  := box.new(rngLeft, rngHi, rx, rngLo, border_color=color.new(chanC, 100), bgcolor=color.new(chanC, 91))
            rngTopG := line.new(rngLeft, rngHi, rx, rngHi, color=color.new(bearC, 80), width=6)
            rngTop  := line.new(rngLeft, rngHi, rx, rngHi, color=color.new(bearC, 5), width=2)
            rngBotG := line.new(rngLeft, rngLo, rx, rngLo, color=color.new(bullC, 80), width=6)
            rngBot  := line.new(rngLeft, rngLo, rx, rngLo, color=color.new(bullC, 5), width=2)
            rngBoxes.push(rngBox)
            rngLines.push(rngTopG)
            rngLines.push(rngTop)
            rngLines.push(rngBotG)
            rngLines.push(rngBot)
            while rngBoxes.size() > rngKeep + 1
                box.delete(rngBoxes.shift())
            while rngLines.size() > (rngKeep + 1) * 4
                line.delete(rngLines.shift())
    else
        bool brk = close > rngHi or close < rngLo
        rngOff := rngChop ? 0 : rngOff + 1
        if brk or rngOff >= RNG_END
            rngLive := false
            rngEnd  := bar_index
            chopAge := 0
            // keep exactly the number of finished channels asked for
            while rngBoxes.size() > rngKeep
                box.delete(rngBoxes.shift())
            while rngLines.size() > rngKeep * 4
                line.delete(rngLines.shift())
            box.set_right(rngBox, bar_index)
            line.set_x2(rngTopG, bar_index)
            line.set_x2(rngTop, bar_index)
            line.set_x2(rngBotG, bar_index)
            line.set_x2(rngBot, bar_index)
        else
            rngHi := math.max(rngHi, rngSrcHi)
            rngLo := math.min(rngLo, rngSrcLo)
            int rx = bar_index + RNG_EXT
            box.set_top(rngBox, rngHi)
            box.set_bottom(rngBox, rngLo)
            box.set_right(rngBox, rx)
            line.set_xy1(rngTopG, rngLeft, rngHi)
            line.set_xy2(rngTopG, rx, rngHi)
            line.set_xy1(rngTop, rngLeft, rngHi)
            line.set_xy2(rngTop, rx, rngHi)
            line.set_xy1(rngBotG, rngLeft, rngLo)
            line.set_xy2(rngBotG, rx, rngLo)
            line.set_xy1(rngBot, rngLeft, rngLo)
            line.set_xy2(rngBot, rx, rngLo)

if barstate.islast
    label.delete(rngTopL)
    label.delete(rngBotL)
    if rngOn and rngLive and rngLbl
        rngTopL := label.new(rngLeft, rngHi, "Resistance " + str.tostring(rngHi, format.mintick), style=label.style_label_lower_left, color=color.new(#000000, 100), textcolor=bearC, size=size.small)
        rngBotL := label.new(rngLeft, rngLo, "Support " + str.tostring(rngLo, format.mintick), style=label.style_label_upper_left, color=color.new(#000000, 100), textcolor=bullC, size=size.small)

//==========================================================
// NAME TAGS  (each tag sits on its own line, right after the last candle)
//==========================================================
var array<label> labs = array.new<label>()

f_add(array<float> ys, array<string> ts, array<color> cs, bool cond, float y, string txt, color c) =>
    if cond and not na(y)
        ys.push(y)
        ts.push(txt)
        cs.push(c)

if barstate.islast
    for l in labs
        label.delete(l)
    labs.clear()
    if showLabels
        ys = array.new<float>()
        ts = array.new<string>()
        cs = array.new<color>()
        f_add(ys, ts, cs, showMa1, ma1, str.tostring(lenMa1) + " " + maType, c1)
        f_add(ys, ts, cs, showMa2, ma2, str.tostring(lenMa2) + " " + maType, c2)
        f_add(ys, ts, cs, showMa3, ma3, str.tostring(lenMa3) + " " + maType, c3)
        f_add(ys, ts, cs, showMa4, ma4, str.tostring(lenMa4) + " " + maType, c4)
        f_add(ys, ts, cs, showMa5, ma5, str.tostring(lenMa5) + " " + maType, c5)
        f_add(ys, ts, cs, showMa6, ma6, str.tostring(lenMa6) + " " + maType, c6)
        f_add(ys, ts, cs, showMa7, ma7, str.tostring(lenMa7) + " " + maType, c7)
        f_add(ys, ts, cs, showMtf1, htf1, f_tfLabel(tfMtf1) + " " + str.tostring(lenMtf1) + " " + mtTyp1, colMtf1)
        f_add(ys, ts, cs, showMtf2, htf2, f_tfLabel(tfMtf2) + " " + str.tostring(lenMtf2) + " " + mtTyp2, colMtf2)
        f_add(ys, ts, cs, showMtf3, htf3, f_tfLabel(tfMtf3) + " " + str.tostring(lenMtf3) + " " + mtTyp3, colMtf3)
        f_add(ys, ts, cs, showMtf4, htf4, f_tfLabel(tfMtf4) + " " + str.tostring(lenMtf4) + " " + mtTyp4, colMtf4)
        if ys.size() > 0
            idx = ys.sort_indices(order.ascending)
            float gap  = labelGap * atr14
            float prev = na
            for i in idx
                float y = ys.get(i)
                if not na(prev) and y < prev + gap
                    y := prev + gap
                color lc = cs.get(i)
                labs.push(label.new(bar_index + labelOffset, y, ts.get(i), style=label.style_label_left, color=lc, textcolor=f_textOn(lc), size=size.small))
                prev := y

//==========================================================
// DASHBOARD
//==========================================================
f_tablePos(string p) =>
    switch p
        "Top right"    => position.top_right
        "Bottom right" => position.bottom_right
        "Top left"     => position.top_left
        "Bottom left"  => position.bottom_left
        => position.middle_right

tSize = tableSizeIn == "Tiny" ? size.tiny : tableSizeIn == "Normal" ? size.normal : tableSizeIn == "Large" ? size.large : size.small
tXtiny = tableSizeIn == "Extra tiny"

const int T_ROWS = 50
var table dash = table.new(f_tablePos(tablePosIn), 3, T_ROWS, bgcolor=color.new(panelBg, 12), frame_color=panelEdge, frame_width=1, border_color=color.new(panelBg, 100), border_width=0)

f_cell(int col, int row, string txt, color tc, string align, string tip) =>
    if tXtiny
        dash.cell(col, row, txt, text_color=tc, text_size=7, text_halign=align, text_font_family=font.family_monospace, tooltip=tip)
    else
        dash.cell(col, row, txt, text_color=tc, text_size=tSize, text_halign=align, text_font_family=font.family_monospace, tooltip=tip)

const string TIP_LIST = "How far price is above or below this average right now, in %. The arrow shows whether the average itself is rising, falling or flat."

f_row(int row, string name, color nameCol, float val, float s) =>
    float d = (close - val) / val * 100
    string arrow = na(s) ? "" : s > 0.03 ? "▲" : s < -0.03 ? "▼" : "•"
    color aCol = na(s) ? flatC : s > 0.03 ? bullC : s < -0.03 ? bearC : flatC
    f_cell(0, row, name, nameCol, text.align_left, TIP_LIST)
    f_cell(1, row, str.tostring(math.abs(d), "0.00") + "%" + (d >= 0 ? " above" : " below"), d >= 0 ? bullC : bearC, text.align_right, TIP_LIST)
    f_cell(2, row, arrow, aCol, text.align_center, TIP_LIST)

f_trendRow(int row, string name, int code, string tip) =>
    f_cell(0, row, name, panelText, text.align_left, tip)
    f_cell(1, row, f_stateTxt(code), f_stateCol(code), text.align_right, tip)
    f_cell(2, row, na(code) ? "" : f_stateArrow(code), f_stateCol(code), text.align_center, tip)

f_info(int row, string name, string val, color vc, string mark, color mc, string tip) =>
    f_cell(0, row, name, panelMute, text.align_left, tip)
    f_cell(1, row, val, vc, text.align_right, tip)
    f_cell(2, row, mark, mc, text.align_center, tip)

f_strengthTxt(float a) =>
    a < adxMin ? (earlyOn and adxRising ? "Waking up" : "Weak") : a < 25 ? "Building" : a < 40 ? "Strong" : "Very strong"

f_stretchTxt(float e) =>
    float a = math.abs(e)
    na(e) ? "n/a" : str.tostring(a, "0.#") + "x the ATR" + (e >= 0 ? " above" : " below") + (a >= extWarn ? " (very stretched)" : a < 1.0 ? " (close)" : " (normal)")

// Compact wording
f_stretchShort(float e) =>
    na(e) ? "n/a" : str.tostring(math.abs(e), "0.#") + "x ATR" + (e >= 0 ? " above" : " below")

f_tfBigger(string tf) =>
    timeframe.in_seconds(tf) > timeframe.in_seconds()

const string TIP_TREND = "The trend reading for this chart.\nBULLISH = the averages are stacked upward and price is above them.\nBEARISH = the opposite.\nCHOPPY = no real trend right now (trend strength is weak).\nMIXED = some strength, but the averages are not lined up."
const string TIP_AGREE = "How many timeframes in the list above (including this chart) point the same way. The more that agree, the stronger the setup."
string TIP_STR = "How strong the current move is, from 0 to 100 (the ADX formula).\nWeak = under " + str.tostring(adxMin) + ", no real trend.\nWaking up = under " + str.tostring(adxMin) + " but climbing, a new trend may be starting.\nBuilding = " + str.tostring(adxMin) + " to 25.\nStrong = 25 to 40.\nVery strong = 40 and up."
const string TIP_AGE   = "How many candles the current trend reading has lasted. Young trends have more room to run; very old trends are more likely to tire."
const string TIP_RSPCT = "How this stock did over the past year compared with the S&P 500, with the last 3 months counting double (the same score the RS Rating is built from). Beating = it did better than the market. Lagging = it did worse."
const string TIP_SCORE = "Of the past pullback dots: how often price moved your win distance in the dot's direction before it moved your loss distance against it. A dot that reaches neither within 60 candles is not counted."
const string TIP_GRADE = "The same win rate, split by each dot's quality grade (A = best, C = weakest). If A beats C, the grades are worth following on this stock and timeframe."
const string TIP_SQZ   = "Yes = the averages are bunched tightly together. That often comes right before a big move, but it does not tell you which direction."
const string TIP_MKT   = "The same trend reading, worked out on the S&P 500 daily chart. Most swing trades struggle when the market is weak."
const string TIP_ATR   = "ATR (Average True Range) = how much this stock normally moves in a day, gaps included, from daily candles. In dollars and as a % of price. Handy for sizing stops."
const string TIP_ADR   = "Average distance from each day's low to its high, as a % of price, over the days before today. Tells you whether the stock moves enough to be worth swing trading."
const string TIP_USED  = "How far the stock has traveled today from its low to its high, next to a normal day (the average daily range). This is not the change from yesterday's close. Amber = today's range is already as big as a normal day or bigger, so chasing it is riskier."
const string TIP_EXT50 = "How far price is from the 50-day average, counted in ATRs (a normal day's move). 4x the ATR above = price sits about 4 normal days' moves above the line. The bigger the number, the more stretched the stock is."
const string TIP_52    = "How far the last price is below the highest price of the past year. Leading stocks usually trade near their highs."
const string TIP_RVOL  = "Today's volume as a % of a normal day (the average of the days before today). 100% = normal, 200% = twice as much. During the trading day it counts the volume so far, so it starts low in the morning and builds up."
const string TIP_UD    = "Of all the shares traded over the volume look-back, the % that traded on up days (buying) vs down days (selling). More on up days = buyers in control."
const string TIP_AVGV  = "Shares traded today next to the average day over the volume look-back. During market hours, today counts the volume so far."
const string TIP_DOLV  = "Dollars traded today (shares times price) next to the average day. Shows how easy the stock is to get in and out of. During market hours, today counts the volume so far."
const string TIP_SEC   = "The sector and industry this company belongs to."
const string TIP_EARN  = "Days until this company's next earnings report, with the date in brackets. Moves around earnings can be big and jumpy, so many traders size down or wait."

const string TIP_HIST  = "This stock does not have enough price history yet for every average to show (common with new IPOs). The lines, the cloud, the candle colors and the trend reading all need those averages.\nA T3 stacks six averages, so it needs about 6 times its length in candles. SMA, EMA, WMA, ALMA and VWMA only need their length.\nFix: pick SMA or EMA in section 2, or wait for more candles."

// How many candles an average needs before it can show (T3 stacks 6 EMAs, HMA adds a short smoothing step)
f_needBars(int length, string typ) =>
    typ == "T3" ? 6 * (length - 1) + 1 : typ == "HMA" ? length + int(math.floor(math.sqrt(length))) - 1 : length

if barstate.islast
    dash.clear(0, 0, 2, T_ROWS - 1)
    if showTable
        bool isFull = boxStyle == "Full"
        bool cp = not isFull   // Compact: only the rows ticked in section 14, with shorter wording for phones
        bool vA = mtfOn and mtfOn1 and f_tfBigger(mtfTf1)
        bool vB = mtfOn and mtfOn2 and f_tfBigger(mtfTf2)
        bool vC = mtfOn and mtfOn3 and f_tfBigger(mtfTf3)
        bool vD = mtfOn and mtfOn4 and f_tfBigger(mtfTf4)
        int r = 0
        // ---- Trend on this chart ----
        if isFull or cmpTrend
            f_trendRow(r, "Trend (" + f_tfName(timeframe.period) + ")", stateCode, TIP_TREND)
            r += 1
        // ---- Not enough history yet (new stocks): name the first average that cannot show ----
        int nBars = bar_index + 1
        int needB = 0
        string needN = ""
        if showMa1 and na(ma1) and (needB == 0 or f_needBars(lenMa1, maType) < needB)
            needB := f_needBars(lenMa1, maType)
            needN := str.tostring(lenMa1) + " " + maType
        if showMa2 and na(ma2) and (needB == 0 or f_needBars(lenMa2, maType) < needB)
            needB := f_needBars(lenMa2, maType)
            needN := str.tostring(lenMa2) + " " + maType
        if showMa3 and na(ma3) and (needB == 0 or f_needBars(lenMa3, maType) < needB)
            needB := f_needBars(lenMa3, maType)
            needN := str.tostring(lenMa3) + " " + maType
        if showMa4 and na(ma4) and (needB == 0 or f_needBars(lenMa4, maType) < needB)
            needB := f_needBars(lenMa4, maType)
            needN := str.tostring(lenMa4) + " " + maType
        if showMa5 and na(ma5) and (needB == 0 or f_needBars(lenMa5, maType) < needB)
            needB := f_needBars(lenMa5, maType)
            needN := str.tostring(lenMa5) + " " + maType
        if showMa6 and na(ma6) and (needB == 0 or f_needBars(lenMa6, maType) < needB)
            needB := f_needBars(lenMa6, maType)
            needN := str.tostring(lenMa6) + " " + maType
        if showMa7 and na(ma7) and (needB == 0 or f_needBars(lenMa7, maType) < needB)
            needB := f_needBars(lenMa7, maType)
            needN := str.tostring(lenMa7) + " " + maType
        if needB > 0
            f_info(r, "History", str.tostring(nBars) + " candles (" + needN + " needs " + (maType == "T3" or maType == "HMA" ? "about " : "") + str.tostring(needB) + ")", mixC, "!", mixC, TIP_HIST)
            r += 1
        // ---- Trend on other timeframes (Compact: only the biggest one) ----
        if isFull
            if vA
                f_trendRow(r, "Trend (" + f_tfName(mtfTf1) + ")", mtfC1, "The same trend reading, worked out on the " + f_tfName(mtfTf1) + " chart.")
                r += 1
            if vB
                f_trendRow(r, "Trend (" + f_tfName(mtfTf2) + ")", mtfC2, "The same trend reading, worked out on the " + f_tfName(mtfTf2) + " chart.")
                r += 1
            if vC
                f_trendRow(r, "Trend (" + f_tfName(mtfTf3) + ")", mtfC3, "The same trend reading, worked out on the " + f_tfName(mtfTf3) + " chart.")
                r += 1
            if vD
                f_trendRow(r, "Trend (" + f_tfName(mtfTf4) + ")", mtfC4, "The same trend reading, worked out on the " + f_tfName(mtfTf4) + " chart.")
                r += 1
        else if cmpBig
            string bigTf = ""
            int bigC = na
            int bigS = 0
            if vA and timeframe.in_seconds(mtfTf1) > bigS
                bigTf := mtfTf1
                bigC := mtfC1
                bigS := timeframe.in_seconds(mtfTf1)
            if vB and timeframe.in_seconds(mtfTf2) > bigS
                bigTf := mtfTf2
                bigC := mtfC2
                bigS := timeframe.in_seconds(mtfTf2)
            if vC and timeframe.in_seconds(mtfTf3) > bigS
                bigTf := mtfTf3
                bigC := mtfC3
                bigS := timeframe.in_seconds(mtfTf3)
            if vD and timeframe.in_seconds(mtfTf4) > bigS
                bigTf := mtfTf4
                bigC := mtfC4
                bigS := timeframe.in_seconds(mtfTf4)
            if bigTf != ""
                f_trendRow(r, "Trend (" + f_tfName(bigTf) + ")", bigC, "The same trend reading, worked out on the " + f_tfName(bigTf) + " chart.")
                r += 1
        if isFull or cmpAgree
            int nShown = (vA ? 1 : 0) + (vB ? 1 : 0) + (vC ? 1 : 0) + (vD ? 1 : 0)
            if nShown >= 1
                int tot = 1 + nShown
                int nUp = (stateCode == 1 ? 1 : 0) + (vA and mtfC1 == 1 ? 1 : 0) + (vB and mtfC2 == 1 ? 1 : 0) + (vC and mtfC3 == 1 ? 1 : 0) + (vD and mtfC4 == 1 ? 1 : 0)
                int nDn = (stateCode == -1 ? 1 : 0) + (vA and mtfC1 == -1 ? 1 : 0) + (vB and mtfC2 == -1 ? 1 : 0) + (vC and mtfC3 == -1 ? 1 : 0) + (vD and mtfC4 == -1 ? 1 : 0)
                string agTxt = nUp + nDn == 0 ? "No clear trend" : nUp > nDn ? str.tostring(nUp) + " of " + str.tostring(tot) + " Bullish" : nDn > nUp ? str.tostring(nDn) + " of " + str.tostring(tot) + " Bearish" : "Split"
                color agC = nUp > nDn ? bullC : nDn > nUp ? bearC : panelText
                f_info(r, "Timeframes agree", agTxt, agC, "", panelText, TIP_AGREE)
                r += 1
        // ---- The market ----
        if swMkt and (isFull or cmpMkt) and not na(mktCode)
            f_trendRow(r, cp ? "S&P 500" : "Market (S&P 500)", mktCode, TIP_MKT)
            r += 1
        // ---- Trend strength, age and stretch ----
        if (isFull or cmpStr) and not na(adxVal)
            f_info(r, "Trend strength", f_strengthTxt(adxVal) + " (" + str.tostring(math.round(adxVal)) + "/100)", adxVal >= adxMin ? panelText : flatC, "", panelText, TIP_STR)
            r += 1
        if statsOn and (isFull or cmpAge)
            f_info(r, "Trend age", str.tostring(stateBars) + (stateBars == 1 ? " candle" : " candles"), panelText, "", panelText, TIP_AGE)
            r += 1
        if statsOn and (isFull or cmpExt)
            bool stretched = not na(extAtr) and math.abs(extAtr) >= extWarn
            f_info(r, "Stretch from " + str.tostring(refLen), cp ? f_stretchShort(extAtr) : f_stretchTxt(extAtr), stretched ? mixC : panelText, stretched ? "!" : "", mixC, "How far price has run from the " + str.tostring(refLen) + " average, counted in ATRs (average candle sizes on this chart). Very stretched moves often pull back toward the line.")
            r += 1
        // ---- How the stock moves ----
        if swAtr and (isFull or cmpAtr) and not na(dAtr) and dClose > 0
            f_info(r, cp ? "ATR" : "ATR (" + str.tostring(swAtrLen) + " days)", "$" + str.tostring(dAtr, format.mintick) + (cp ? " (" : "  (") + str.tostring(dAtr / dClose * 100, "0.0") + "%)", panelText, "", panelText, TIP_ATR)
            r += 1
        if swAdr and (isFull or cmpAdr) and not na(dAdr)
            f_info(r, cp ? "Avg range" : "Avg daily range", str.tostring(dAdr, "0.0") + "%", panelText, "", panelText, TIP_ADR)
            r += 1
        if swUsed and (isFull or cmpDay) and not na(dRange) and dAdr > 0
            bool bigDay = dRange >= dAdr
            f_info(r, cp ? "Today's range" : "Today's low to high", str.tostring(dRange, "0.0") + "% (normal " + str.tostring(dAdr, "0.0") + "%)", bigDay ? mixC : panelText, bigDay ? "!" : "", mixC, TIP_USED)
            r += 1
        if swExt50 and (isFull or cmpExt50) and not na(d50) and dAtr > 0
            float e50 = (dClose - d50) / dAtr
            f_info(r, cp ? "From 50-day" : "Stretch from 50-day", str.tostring(math.abs(e50), "0.#") + (cp ? "x ATR" : "x the ATR") + (e50 >= 0 ? " above" : " below"), panelText, "", panelText, TIP_EXT50)
            r += 1
        // ---- Strength vs the market ----
        if rsOn and not na(rsRating) and (isFull or cmpRs)
            string rsTip = rsStale ? "Estimated. " + (rsHaveFeed and not na(rsDaysOld) ? "Fred6724's daily rating data has not updated in " + str.tostring(math.floor(rsDaysOld)) + " days, so this uses the last numbers it sent." : "Fred6724's daily rating data can't be read right now, so this uses backup numbers saved in the indicator.") + " It should be within a few points." : "IBD-style rating from 1 to 99: how this stock's past year compares with about 6,100 US stocks. 99 = stronger than 99% of them. The last 3 months count double.\nRating data: Fred6724 (github.com/Fred6725/relative-strength), updated " + str.format_time(int(rsFeedT), "MMM d", "America/New_York") + "."
            f_info(r, "RS Rating", str.tostring(rsRating, "#") + (rsStale ? "*" : ""), rsRating >= 80 ? bullC : rsRating < 40 ? bearC : panelText, "", panelText, rsTip)
            r += 1
        if rsOn and not na(rsScore) and (isFull or cmpPast)
            float rsPct = rsScore - 100
            bool rsEven = math.abs(rsPct) < 0.5
            color rsPc = rsEven ? panelText : rsPct >= 0 ? bullC : bearC
            string pyTxt = rsEven ? "Matching the market" : cp ? (rsPct >= 0 ? "+" : "-") + str.tostring(math.abs(rsPct), "#") + "% vs market" : (rsPct >= 0 ? "Beating the market by " : "Lagging the market by ") + str.tostring(math.abs(rsPct), "#") + "%"
            f_info(r, "Past year", pyTxt, rsPc, rsEven ? "•" : rsPct >= 0 ? "▲" : "▼", rsPc, TIP_RSPCT)
            r += 1
        // ---- Where price sits ----
        if sw52 and (isFull or cmp52) and dHi52 > 0
            float off52 = (dClose / dHi52 - 1) * 100
            bool atHi = off52 >= -0.5
            f_info(r, cp ? "52-week high" : "From 52-week high", atHi ? "At the high" : str.tostring(math.abs(off52), "0.0") + "% below", atHi ? bullC : panelText, atHi ? "▲" : "", bullC, TIP_52)
            r += 1
        // ---- Volume ----
        if dAvgV > 0
            if swRvol and (isFull or cmpRvol)
                float rv = dVol / dAvgV
                string rvTxt = rv < 0.85 ? "lighter than normal" : rv <= 1.15 ? "about normal" : rv < 1.5 ? "heavier than normal" : "much heavier than normal"
                f_info(r, cp ? "Rel. volume" : "Relative volume", str.tostring(rv * 100, "#") + (cp ? "% of normal" : "% (" + rvTxt + ")"), rv >= 1.5 ? mixC : panelText, rv >= 1.5 ? "!" : "", mixC, TIP_RVOL)
                r += 1
            if swUd and (isFull or cmpUd) and dUpV + dDnV > 0
                int upPct = int(math.round(dUpV / (dUpV + dDnV) * 100))
                color udC = upPct > 50 ? bullC : upPct < 50 ? bearC : panelText
                f_info(r, cp ? "Buy vs sell" : "Buying vs selling", str.tostring(upPct) + "% vs " + str.tostring(100 - upPct) + "%", udC, upPct > 50 ? "▲" : upPct < 50 ? "▼" : "•", udC, TIP_UD)
                r += 1
            if swAvgV and (isFull or cmpVol)
                f_info(r, "Volume", "Today " + f_big(nz(dVol)) + " · Avg " + f_big(dAvgV), panelText, "", panelText, TIP_AVGV)
                r += 1
            if swDolV and (isFull or cmpDolV) and dAvgDV > 0
                f_info(r, "Dollar volume", "Today $" + f_big(nz(dVol) * dClose) + " · Avg $" + f_big(dAvgDV), panelText, "", panelText, TIP_DOLV)
                r += 1
        // ---- Pullback dot results ----
        if scoreOn and pbOn and (isFull or cmpDots)
            f_info(r, "Pullback dots", sbCount == 0 ? "No results yet" : str.tostring(math.round(sbRate)) + "% won (" + str.tostring(sbCount) + " dots)", sbCount == 0 ? flatC : sbRate >= 55 ? bullC : sbRate >= 45 ? panelText : bearC, "", panelText, TIP_SCORE)
            r += 1
        if scoreGrd and pbOn and (isFull or cmpGrd)
            f_info(r, "Dots by grade", f_rateTxt(sbResA, "A") + "  " + f_rateTxt(sbResB, "B") + "  " + f_rateTxt(sbResC, "C"), panelText, "", panelText, TIP_GRADE)
            r += 1
        // ---- Squeeze, earnings, the company ----
        if sqzOn and (isFull or cmpSqz)
            f_info(r, "Lines bunched", isSqz ? "Yes" : "No", isSqz ? sqzC : flatC, isSqz ? "◆" : "", sqzC, TIP_SQZ)
            r += 1
        if earnOn and not na(earnDays) and earnDays >= 0 and (isFull or (cmpEarn and earnDays <= 7))
            bool soon = earnDays <= 7
            f_info(r, "Earnings", (earnDays == 0 ? "Today" : earnDays == 1 ? "Tomorrow" : "in " + str.tostring(earnDays) + " days") + " (" + str.format_time(int(earnT), "MMM d", "UTC") + ")", soon ? mixC : panelText, soon ? "!" : "", mixC, TIP_EARN)
            r += 1
        if swSec and (isFull or cmpSec)
            string secTxt = syminfo.sector
            string indTxt = syminfo.industry
            if not na(secTxt) and secTxt != ""
                f_info(r, "Sector", secTxt, panelText, "", panelText, TIP_SEC)
                r += 1
            if not na(indTxt) and indTxt != ""
                f_info(r, "Industry", indTxt, panelText, "", panelText, TIP_SEC)
                r += 1
        // ---- List of averages ----
        if listOn and (isFull or cmpList)
            f_info(r, "Average", "Price is", panelMute, "", panelMute, TIP_LIST)
            r += 1
            f_info(r, "───────", "────────", panelMute, "", panelMute, TIP_LIST)
            r += 1
            if showMa1 and not na(ma1)
                f_row(r, str.tostring(lenMa1) + " " + maType, base1, ma1, s1)
                r += 1
            if showMa2 and not na(ma2)
                f_row(r, str.tostring(lenMa2) + " " + maType, base2, ma2, s2)
                r += 1
            if showMa3 and not na(ma3)
                f_row(r, str.tostring(lenMa3) + " " + maType, base3, ma3, s3)
                r += 1
            if showMa4 and not na(ma4)
                f_row(r, str.tostring(lenMa4) + " " + maType, base4, ma4, s4)
                r += 1
            if showMa5 and not na(ma5)
                f_row(r, str.tostring(lenMa5) + " " + maType, base5, ma5, s5)
                r += 1
            if showMa6 and not na(ma6)
                f_row(r, str.tostring(lenMa6) + " " + maType, base6, ma6, s6)
                r += 1
            if showMa7 and not na(ma7)
                f_row(r, str.tostring(lenMa7) + " " + maType, base7, ma7, s7)
                r += 1
            if showMtf1 and not na(htf1) and r < T_ROWS
                f_row(r, f_tfLabel(tfMtf1) + " " + str.tostring(lenMtf1) + " " + mtTyp1, colMtf1, htf1, na)
                r += 1
            if showMtf2 and not na(htf2) and r < T_ROWS
                f_row(r, f_tfLabel(tfMtf2) + " " + str.tostring(lenMtf2) + " " + mtTyp2, colMtf2, htf2, na)
                r += 1
            if showMtf3 and not na(htf3) and r < T_ROWS
                f_row(r, f_tfLabel(tfMtf3) + " " + str.tostring(lenMtf3) + " " + mtTyp3, colMtf3, htf3, na)
                r += 1
            if showMtf4 and not na(htf4) and r < T_ROWS
                f_row(r, f_tfLabel(tfMtf4) + " " + str.tostring(lenMtf4) + " " + mtTyp4, colMtf4, htf4, na)
                r += 1
````

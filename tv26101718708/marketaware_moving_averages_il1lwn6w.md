# Market-Aware Moving Averages

- url: https://www.tradingview.com/script/iL1LWN6w/
- type: indicator
- pine_id: PUB;8b53f1e9822c448a86e77227672bb0d8
- version: 5.0

## Description

Market-Aware Moving Averages automatically switches its moving-average lengths based on the market the chart symbol belongs to, so you don't have to reconfigure it each time you move between Taiwan, the US, Japan, Korea, Europe, India, crypto, forex, and more.
Why this exists. Different markets follow different moving-average conventions. The US, Europe and India favor the round 50/200 set; Taiwan and Korea use the trading-day set (60 for a quarter, 240 for a year); Japan has its own 25/75 tradition. Changing lengths by hand on every switch is tedious and easy to forget. This script reads the symbol's country and type and applies the right set on its own.
What it plots. Five main lines covering week / month / quarter / half-year / year, plus optional secondary lines that are common but less central. Main and secondary use two distinct colors, and line width grows with period, so the longest (yearly) line is the thickest and least noisy.
Length sets by market:

[list]
[*]US / Europe / India, and all non-stock instruments (default): 5 / 20 / 50 / 100 / 200; secondary 10 / 13 / 15 / 30
[*]Taiwan / Korea: 5 / 20 / 60 / 120 / 240; secondary 10 (Korea also 90 / 180)
[*]Japan: 5 / 25 / 75 / 100 / 200; secondary 10 / 15
[/list]

How detection works. It uses Pine's syminfo.country and syminfo.type. Any stock without a mapped country, and every non-stock instrument (index, forex, crypto, futures, commodity), falls back to the default 5/20/50/200 set.
Settings. Override the auto-detection to force a specific system or fully custom lengths; switch between SMA and EMA; toggle each line; and change both colors. Secondary lines are hidden by default.
Note. Moving averages are lagging indicators and can give false signals in ranging markets. The length conventions used here are common market practices, not guarantees. This is a visualization tool, not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © z411392
//
//
//@version=6
// =============================================================
// Full name : Market-Aware Adaptive Moving Averages
//             (main/secondary split by color, auto-switched by market)
// Version   : v2
// -------------------------------------------------------------
// Design principles:
//   1) Main vs secondary lines use two distinct colors (color is fixed by role).
//   2) Line width grows with period: fast = thin, slow = thick; the longest
//      (yearly) line is the thickest and least noisy.
//   3) Secondary lines are hidden by default; when shown they also go thin->thick
//      by period, but use a separate color to stay distinct from the main lines.
//
// Main five slots (week / month / quarter / half-year / year), per market:
//   US/EU/IN + all non-stock (default) : 5 / 20 / 50 / 100 / 200
//   Taiwan / Korea                     : 5 / 20 / 60 / 120 / 240
//   Japan                              : 5 / 25 / 75 / 100 / 200
// Secondary lines (vary by market):
//   US/EU/IN : 10 / 13 / 15 / 30
//   Taiwan   : 10
//   Korea    : 10 / 90 / 180
//   Japan    : 10 / 15
// =============================================================
indicator("Market-Aware Moving Averages", shorttitle = "Market-Aware MA", overlay = true)

// ————— Inputs
maTypeInput = input.string("SMA", "MA type", options = ["SMA", "EMA"])

modeInput = input.string("Auto (by market)", "MA system",
     options = ["Auto (by market)",
                "Anglo US/EU/IN 5-20-50-100-200",
                "Asia TW/KR 5-20-60-120-240",
                "Japan 5-25-75-100-200",
                "Custom"])

GRP_MAIN = "Main lines (half-year hidden by default -> 5/20/50/200)"
showMain1Input = input.bool(true,  "Week   (thin)",      group = GRP_MAIN)
showMain2Input = input.bool(true,  "Month  (thin)",      group = GRP_MAIN)
showMain3Input = input.bool(true,  "Quarter (medium)",   group = GRP_MAIN)
showMain4Input = input.bool(false, "Half-year (thick)",  group = GRP_MAIN)
showMain5Input = input.bool(true,  "Year   (thickest)",  group = GRP_MAIN)

GRP_SEC = "Secondary lines"
showSecInput = input.bool(false, "Show secondary lines (hidden by default)", group = GRP_SEC)

GRP_FAST = "Fast extra lines (hidden by default)"
show10Input = input.bool(false, "10-day", group = GRP_FAST)
show15Input = input.bool(false, "15-day", group = GRP_FAST)

GRP_COLOR = "Colors"
mainColorInput = input.color(#ec407a, "Main color (default pink)",      group = GRP_COLOR)
secColorInput  = input.color(#26c6da, "Secondary color (default cyan)", group = GRP_COLOR)

GRP_CUST = "Custom main lengths (used when system = Custom)"
custom1Input = input.int(5,   "Week",      minval = 1, group = GRP_CUST)
custom2Input = input.int(20,  "Month",     minval = 1, group = GRP_CUST)
custom3Input = input.int(50,  "Quarter",   minval = 1, group = GRP_CUST)
custom4Input = input.int(100, "Half-year", minval = 1, group = GRP_CUST)
custom5Input = input.int(200, "Year",      minval = 1, group = GRP_CUST)

// ————— Function declarations

// @function     Returns a moving average of the given type and length.
// @param src    (series float) Source series, usually close.
// @param len    (simple int)   Lookback length.
// @returns      (series float) SMA or EMA depending on `maTypeInput`.
// Dependencies  maTypeInput (global input)
f_ma(src, len) =>
    maTypeInput == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

// ————— Market detection
//@variable ISO 3166-1 alpha-2 country code; empty string for most non-stocks.
country = syminfo.country
//@variable Asset class: "stock", "fund", "dr", "index", "forex", "crypto", etc.
symType = syminfo.type
//@variable True for stock-like instruments that carry a meaningful country.
isEquity = symType == "stock" or symType == "dr" or symType == "fund"

isAsia  = isEquity and (country == "TW" or country == "KR")
isJapan = isEquity and country == "JP"

// ————— System resolution
useAsia   = modeInput == "Asia TW/KR 5-20-60-120-240"  or (modeInput == "Auto (by market)" and isAsia)
useJapan  = modeInput == "Japan 5-25-75-100-200"        or (modeInput == "Auto (by market)" and isJapan)
useCustom = modeInput == "Custom"
// Everything else falls back to Anglo (Auto-hit US/EU/IN, Auto-miss, and all non-stock).

//@variable True when the active market uses the Korea secondary set (10/90/180).
isKoreaSec = useAsia and not useCustom and country == "KR"
//@variable True when the active market uses the Anglo secondary set (10/13/15/30).
isAngloSec = not useCustom and not useAsia and not useJapan
//@variable True when the active market uses the Japan secondary set (10/15).
isJapanSec = useJapan and not useCustom

// ————— Pre-compute every candidate MA with constant lengths
// (Constant lengths keep ta.ema's length argument valid regardless of market.)
ma5   = f_ma(close, 5)
ma10  = f_ma(close, 10)
ma13  = f_ma(close, 13)
ma15  = f_ma(close, 15)
ma20  = f_ma(close, 20)
ma25  = f_ma(close, 25)
ma30  = f_ma(close, 30)
ma50  = f_ma(close, 50)
ma60  = f_ma(close, 60)
ma75  = f_ma(close, 75)
ma90  = f_ma(close, 90)
ma100 = f_ma(close, 100)
ma120 = f_ma(close, 120)
ma180 = f_ma(close, 180)
ma200 = f_ma(close, 200)
ma240 = f_ma(close, 240)

maCustom1 = f_ma(close, custom1Input)
maCustom2 = f_ma(close, custom2Input)
maCustom3 = f_ma(close, custom3Input)
maCustom4 = f_ma(close, custom4Input)
maCustom5 = f_ma(close, custom5Input)

// ————— Main: pick the five lines for the active market
main1 = useCustom ? maCustom1 : ma5
main2 = useCustom ? maCustom2 : useJapan ? ma25 : ma20
main3 = useCustom ? maCustom3 : useAsia ? ma60 : useJapan ? ma75 : ma50
main4 = useCustom ? maCustom4 : useAsia ? ma120 : ma100
main5 = useCustom ? maCustom5 : useAsia ? ma240 : ma200

// ————— Secondary: pick by market (na = unused slot)
sec1 = useCustom ? na : ma10
sec2 = isAngloSec ? ma13 : isJapanSec ? ma15 : isKoreaSec ? ma90 : na
sec3 = isAngloSec ? ma15 : isKoreaSec ? ma180 : na
sec4 = isAngloSec ? ma30 : na

// ————— Visuals: main lines, one color, width grows with period
plot(showMain1Input ? main1 : na, "Main week",      color = mainColorInput, linewidth = 1)
plot(showMain2Input ? main2 : na, "Main month",     color = mainColorInput, linewidth = 1)
plot(showMain3Input ? main3 : na, "Main quarter",   color = mainColorInput, linewidth = 2)
plot(showMain4Input ? main4 : na, "Main half-year", color = mainColorInput, linewidth = 3)
plot(showMain5Input ? main5 : na, "Main year",      color = mainColorInput, linewidth = 4)

// ————— Visuals: secondary lines, separate color, width grows with period
plot(showSecInput ? sec1 : na, "Secondary 1", color = secColorInput, linewidth = 1)
plot(showSecInput ? sec2 : na, "Secondary 2", color = secColorInput, linewidth = 1)
plot(showSecInput ? sec3 : na, "Secondary 3", color = secColorInput, linewidth = 2)
plot(showSecInput ? sec4 : na, "Secondary 4", color = secColorInput, linewidth = 3)

// ————— Visuals: fast extra lines (10 / 15), independent toggles, hidden by default
plot(show10Input ? ma10 : na, "10-day", color = secColorInput, linewidth = 1)
plot(show15Input ? ma15 : na, "15-day", color = secColorInput, linewidth = 1)
````

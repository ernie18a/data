# COT Category Screener [invincible3]

- url: https://www.tradingview.com/script/7Kb64tJb-COT-Category-Screener-invincible3/
- type: indicator
- pine_id: PUB;658a6631e59443f2b47c73cceb4d8798
- version: 1.0

## Description

[b]COT Category Screener — Participant Select[/b]

The [b]COT Category Screener[/b] is a professional Commitment of Traders dashboard designed to compare positioning across multiple futures markets from one compact table.

It uses [b]Legacy COT data[/b] and allows traders to analyze either [b]Non-Commercial[/b] or [b]Commercial[/b] participants. Every displayed metric—including net positioning, historical indices, score, bias, ranking, and weekly history—automatically adapts to the selected participant.

[b]MARKET CATEGORIES[/b]

The screener supports the following groups:

• Metals
• Energy
• Grains & Oilseeds
• Soft Commodities
• Livestock
• Equity Indices
• Cryptocurrencies
• Major Currencies
• Emerging-Market Currencies

Depending on the selected category, the dashboard compares up to eight markets simultaneously.

[b]PARTICIPANT SELECTION[/b]

Choose between:

[b]Non-Commercial[/b]

Primarily reflects speculative positioning from large traders such as funds and institutional market participants.

[b]Commercial[/b]

Reflects the positioning stance of commercial participants and hedgers.

Commercial mode represents the [b]Commercial participant-side perspective[/b]. It should not automatically be interpreted as a contrarian market signal.

When Commercial and Non-Commercial positioning spreads are symmetrical, their displayed scores and bias states will naturally appear opposite.

[b]DASHBOARD METRICS[/b]

[b]OI — Open Interest[/b]

Displays the total number of outstanding contracts reported for the selected market.

[b]NET — Net Position[/b]

Calculated as:

[b]Long Positions − Short Positions[/b]

A positive value indicates net-long positioning, while a negative value indicates net-short positioning.

[b]ΔNET — Weekly Net Change[/b]

Measures the change in the selected participant’s net position compared with the previous COT report.

It helps identify whether participants are:

• Adding long exposure
• Reducing long exposure
• Adding short exposure
• Covering short exposure

[b]L% and S%[/b]

Displays the selected participant’s long and short positions as a percentage of total open interest.

[b]FLIP%[/b]

Calculated as:

[b]Long% − Short%[/b]

A positive Flip% indicates stronger long exposure, while a negative Flip% indicates stronger short exposure.

[b]HISTORICAL DIFFERENCE MODEL[/b]

The screener calculates the historical position of the spread between the selected participant and the opposite participant over three report windows:

• [b]D13[/b] — 13-report difference index
• [b]D26[/b] — 26-report difference index
• [b]D52[/b] — 52-report difference index

These values range from 0 to 100.

In the screener’s model:

• Lower Difference values contribute to a more bullish score.
• Higher Difference values contribute to a more bearish score.

The three windows are weighted as follows:

• D13: 20%
• D26: 30%
• D52: 50%

The longer-term D52 component therefore carries the greatest influence.

[b]COT POSITION INDICES[/b]

[b]I52[/b]

Shows the selected participant’s current net position relative to its historical range over the previous 52 reports.

[b]I3Y[/b]

Shows the same relative position over 156 reports, approximately three years of weekly COT history.

Values near 0 indicate positioning near the lower end of the historical range.

Values near 100 indicate positioning near the upper end of the historical range.

These indices describe historical positioning extremes and should be interpreted together with the participant type, Difference readings, weekly net change, and overall bias.

[b]COMPOSITE SCORE[/b]

The screener converts the weighted D13, D26, and D52 readings into a normalized score ranging from:

• [b]+100[/b] — Strong bullish positioning setup
• [b]0[/b] — Neutral or mixed positioning
• [b]−100[/b] — Strong bearish positioning setup

The score is designed for relative comparison and ranking across markets within the selected category.

[b]BIAS STATES[/b]

[b]▲ BUY[/b]

Positioning has reached a potential bottom-zone setup.

This identifies an extreme condition, but it does not confirm that positioning has already reversed.

[b]↗ BULL TURN[/b]

Short- and medium-term positioning has begun turning upward from a bullish extreme.

[b]▲ LONG BUILD[/b]

A bullish turn is supported by a positive weekly change in net positioning, indicating that the selected participant is actively building long exposure.

[b]▲ LONG BIAS[/b]

Positioning remains within the bullish side of the model, although a fresh turning condition is not present.

[b]↘ LONG UNWIND[/b]

The broader positioning structure remains bullish, but net exposure declined during the latest report.

[b]↗ SHORT COVER[/b]

The broader structure remains bearish, but net positioning increased, suggesting that short exposure may be reducing.

[b]▼ SHORT BIAS[/b]

Positioning remains within the bearish side of the model without a newly confirmed bearish turn.

[b]◇ TOP RISK[/b]

Positioning has reached a potential upper-zone or overcrowded extreme.

This is a risk condition rather than an immediate sell confirmation.

[b]↘ BEAR TURN[/b]

Short- and medium-term positioning has begun turning downward from a bearish extreme.

[b]▼ SHORT BUILD[/b]

A bearish turn is supported by a negative weekly change in net positioning, indicating active short-position accumulation or long-position reduction.

[b]• NEUTRAL[/b]

Positioning is mixed and does not meet the defined bullish or bearish thresholds.

[b]— NO DATA[/b]

Sufficient historical COT observations are not yet available for the selected calculation.

[b]WEEKLY POSITIONING HISTORY[/b]

The final column displays a compact [b]10–15 week Flip% sparkline[/b].

Each vertical character represents one COT reporting week:

• The oldest report appears on the left.
• The most recent report appears on the right.
• Taller bars represent stronger relative Flip% readings.

The history can be normalized independently for each market or displayed using a fixed percentage range.

Hover over the history cell to view the underlying weekly values.

[b]SORTING OPTIONS[/b]

Markets can be arranged by:

• Category Order
• Bullish → Bearish
• Bearish → Bullish
• Strongest Extreme

This makes it easier to identify the strongest relative opportunities or risks within a market group.

[b]VISUAL DESIGN[/b]

The dashboard uses neutral table surfaces with value-colored typography rather than full-cell heatmap coloring.

It automatically adapts to light and dark chart themes and includes detailed hover tooltips for:

• CFTC market codes
• Raw positioning values
• Difference readings
• Historical indices
• Composite scores
• Bias calculations
• Weekly Flip% history

[b]DATA OPTIONS[/b]

The user can select between:

• Futures Only
• Futures and Options Combined

All calculations are based on weekly COT reports and are not intended to represent real-time positioning.

[b]SUGGESTED USE[/b]

This screener is designed for:

• Identifying historically crowded positioning
• Comparing related futures markets
• Detecting positioning accumulation or distribution
• Monitoring speculative and commercial behavior separately
• Locating potential medium-term bottom or top setups
• Confirming broader macro or price-action analysis

COT positioning is generally more suitable for contextual and medium-term analysis than precise entry timing.

Signals should be combined with price structure, trend, momentum, volatility, and appropriate risk-management rules.

[b]DISCLAIMER[/b]

This indicator is an analytical tool and does not constitute financial advice.

Historical positioning extremes do not guarantee a market reversal or continuation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
import TradingView/LibraryCOT/2

indicator(
     "COT Category Screener [invincible3]",
     overlay = true,
     dynamic_requests = true,
     max_bars_back = 5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const int MAX_MARKETS = 8
const int MAX_HISTORY = 156
const int COLS = 16

// One participant is displayed at a time. The Participant input selects whether
// these columns use Non-Commercial or Commercial data.
const int C_RANK    = 0
const int C_MARKET  = 1
const int C_OI      = 2
const int C_NET     = 3
const int C_DNET    = 4
const int C_LONG    = 5
const int C_SHORT   = 6
const int C_FLIP    = 7
const int C_D13     = 8
const int C_D26     = 9
const int C_D52     = 10
const int C_I52     = 11
const int C_I156    = 12
const int C_SCORE   = 13
const int C_BIAS    = 14
const int C_HISTORY = 15

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpData = "COT Data"
category = input.string(
     "Metals",
     "Category",
     options = [
         "Metals",
         "Energy",
         "Grains & Oilseeds",
         "Soft Commodities",
         "Livestock",
         "Equity Indices",
         "Cryptocurrencies",
         "Currencies — Majors",
         "Currencies — Emerging"
     ],
     group = grpData)

dataSource = input.string(
     "Futures Only",
     "Data",
     options = ["Futures Only", "Futures and Options"],
     group = grpData)

includeOptions = dataSource == "Futures and Options"

grpHistory = "Weekly History"
historyBars = input.int(
     15,
     "Bars / Weeks",
     minval = 10,
     maxval = 15,
     group = grpHistory,
     tooltip = "One vertical bar represents one COT reporting week. Bars run from oldest on the left to latest on the right.")

historyScaleMode = input.string(
     "Relative to Each Market",
     "Bar Scale",
     options = ["Relative to Each Market", "Fixed Percentage Range"],
     group = grpHistory)

historyFixedScale = input.float(
     50.0,
     "Fixed Range ±%",
     minval = 5.0,
     step = 5.0,
     group = grpHistory)

grpTable = "Table"
showTable = input.bool(true, "Show Screener", group = grpTable)

tablePos = input.string(
     "Middle Center",
     "Location",
     options = [
         "Top Right", "Middle Right", "Bottom Right",
         "Top Center", "Middle Center", "Bottom Center",
         "Top Left", "Middle Left", "Bottom Left"
     ],
     group = grpTable)

tableSize = input.string(
     "Small",
     "Metric Text Size",
     options = ["Auto", "Large", "Normal", "Small", "Tiny"],
     group = grpTable)

sortMode = input.string(
     "Category Order",
     "Sort Markets",
     options = ["Category Order", "Bullish → Bearish", "Bearish → Bullish", "Strongest Extreme"],
     group = grpTable)

participantMode = input.string(
     "Non-Commercial",
     "Participant",
     options = ["Non-Commercial", "Commercial"],
     group = grpData,
     tooltip = "Select the participant used for every displayed metric, score, bias, weekly history and market ranking.")

useCommercial = participantMode == "Commercial"

upCol = input.color(#3B82F6, "Positive", group = grpTable)
mdCol = input.color(#D48CFF, "Neutral", group = grpTable)
dnCol = input.color(#FF5A6E, "Negative", group = grpTable)
flipScale = input.float(35.0, "Flip% Color Scale", minval = 1.0, step = 1.0, group = grpTable)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CATEGORY DEFINITIONS
// Maximum category size is deliberately eight markets: 8 × 5 COT requests = 40.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_marketCount(string cat) =>
    switch cat
        "Metals" => 5
        "Energy" => 4
        "Grains & Oilseeds" => 5
        "Soft Commodities" => 3
        "Livestock" => 2
        "Equity Indices" => 8
        "Cryptocurrencies" => 2
        "Currencies — Majors" => 8
        "Currencies — Emerging" => 4
        => 0

f_marketName(string cat, int i) =>
    switch cat
        "Metals" =>
            switch i
                0 => "GOLD"
                1 => "SILVER"
                2 => "PLATINUM"
                3 => "PALLADIUM"
                4 => "COPPER"
                => ""
        "Energy" =>
            switch i
                0 => "CRUDE OIL"
                1 => "NATURAL GAS"
                2 => "GASOLINE"
                3 => "HEATING OIL"
                => ""
        "Grains & Oilseeds" =>
            switch i
                0 => "WHEAT"
                1 => "CORN"
                2 => "SOYBEANS"
                3 => "SOYBEAN MEAL"
                4 => "SOYBEAN OIL"
                => ""
        "Soft Commodities" =>
            switch i
                0 => "COTTON"
                1 => "COCOA"
                2 => "ORANGE JUICE"
                => ""
        "Livestock" =>
            switch i
                0 => "LEAN HOGS"
                1 => "FEEDER CATTLE"
                => ""
        "Equity Indices" =>
            switch i
                0 => "S&P 500"
                1 => "S&P 500 Mini"
                2 => "Dow Jones"
                3 => "NASDAQ"
                4 => "NASDAQ Mini"
                5 => "RUSSELL 2000"
                6 => "NIKKEI"
                7 => "Volatility S&P 500"
                => ""
        "Cryptocurrencies" =>
            switch i
                0 => "BTC"
                1 => "ETH"
                => ""
        "Currencies — Majors" =>
            switch i
                0 => "USD"
                1 => "EUR"
                2 => "JPY"
                3 => "GBP"
                4 => "CHF"
                5 => "CAD"
                6 => "AUD"
                7 => "NZD"
                => ""
        "Currencies — Emerging" =>
            switch i
                0 => "MXN"
                1 => "BRL"
                2 => "ZAR"
                3 => "RUB"
                => ""
        => ""

f_marketLabel(string name) =>
    switch name
        "S&P 500 Mini" => "S&P MINI"
        "Dow Jones" => "DOW JONES"
        "NASDAQ Mini" => "NASDAQ MINI"
        "Volatility S&P 500" => "VIX"
        "CRUDE OIL" => "CRUDE OIL WTI"
        => name

f_getTickerCode(string name) =>
    switch name
        "GOLD" => "088691"
        "SILVER" => "084691"
        "PLATINUM" => "076651"
        "PALLADIUM" => "075651"
        "COPPER" => "085692"
        "CRUDE OIL" => "067651"
        "NATURAL GAS" => "023651"
        "GASOLINE" => "111659"
        "HEATING OIL" => "022651"
        "WHEAT" => "001602"
        "CORN" => "002602"
        "SOYBEANS" => "005602"
        "SOYBEAN MEAL" => "026603"
        "SOYBEAN OIL" => "007601"
        "COTTON" => "033661"
        "COCOA" => "073732"
        "ORANGE JUICE" => "042601"
        "LEAN HOGS" => "054642"
        "FEEDER CATTLE" => "061641"
        "S&P 500" => "13874+"
        "S&P 500 Mini" => "13874A"
        "Dow Jones" => "12460+"
        "NASDAQ" => "20974+"
        "NASDAQ Mini" => "209742"
        "RUSSELL 2000" => "239742"
        "NIKKEI" => "240741"
        "Volatility S&P 500" => "1170E1"
        "BTC" => "133741"
        "ETH" => "146021"
        "USD" => "098662"
        "EUR" => "099741"
        "JPY" => "097741"
        "MXN" => "095741"
        "CHF" => "092741"
        "RUB" => "089741"
        "CAD" => "090741"
        "NZD" => "112741"
        "GBP" => "096742"
        "BRL" => "102741"
        "ZAR" => "122741"
        "AUD" => "232741"
        => ""

marketCount = f_marketCount(category)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COT REQUESTS
// Five unique contexts per market. Each tuple also returns the prior week.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_cotTicker(simple string code, simple string metricName, simple string direction) =>
    LibraryCOT.COTTickerid(
         COTType = "Legacy",
         CFTCCode = code,
         includeOptions = includeOptions,
         metricName = metricName,
         metricDirection = direction,
         metricType = "All")

f_requestMarket(simple string code) =>
    oiTicker = f_cotTicker(code, "Open Interest", "No direction")
    comLongTicker = f_cotTicker(code, "Commercial Positions", "Long")
    comShortTicker = f_cotTicker(code, "Commercial Positions", "Short")
    ncLongTicker = f_cotTicker(code, "Noncommercial Positions", "Long")
    ncShortTicker = f_cotTicker(code, "Noncommercial Positions", "Short")

    [oi, oiPrev, reportTime] = request.security(
         oiTicker,
         "W",
         [close, close[1], time],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true)

    [comLong, comLongPrev] = request.security(
         comLongTicker,
         "W",
         [close, close[1]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true)

    [comShort, comShortPrev] = request.security(
         comShortTicker,
         "W",
         [close, close[1]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true)

    [ncLong, ncLongPrev] = request.security(
         ncLongTicker,
         "W",
         [close, close[1]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true)

    [ncShort, ncShortPrev] = request.security(
         ncShortTicker,
         "W",
         [close, close[1]],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true)

    [oi, oiPrev, reportTime, comLong, comLongPrev, comShort, comShortPrev, ncLong, ncLongPrev, ncShort, ncShortPrev]

// LibraryCOT.COTTickerid() requires simple/constant CFTC codes.
// Requests are split into eight small slot functions. This prevents one
// large dispatcher from exceeding Pine's 254 external-element limit.

f_emptyRequest() =>
    [float(na), float(na), int(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na)]

f_requestSlot0(simple string cat) =>
    switch cat
        "Metals" => f_requestMarket("088691")  // GOLD
        "Energy" => f_requestMarket("067651")  // CRUDE OIL
        "Grains & Oilseeds" => f_requestMarket("001602")  // WHEAT
        "Soft Commodities" => f_requestMarket("033661")  // COTTON
        "Livestock" => f_requestMarket("054642")  // LEAN HOGS
        "Equity Indices" => f_requestMarket("13874+")  // S&P 500
        "Cryptocurrencies" => f_requestMarket("133741")  // BTC
        "Currencies — Majors" => f_requestMarket("098662")  // USD
        "Currencies — Emerging" => f_requestMarket("095741")  // MXN
        => f_emptyRequest()

f_requestSlot1(simple string cat) =>
    switch cat
        "Metals" => f_requestMarket("084691")  // SILVER
        "Energy" => f_requestMarket("023651")  // NATURAL GAS
        "Grains & Oilseeds" => f_requestMarket("002602")  // CORN
        "Soft Commodities" => f_requestMarket("073732")  // COCOA
        "Livestock" => f_requestMarket("061641")  // FEEDER CATTLE
        "Equity Indices" => f_requestMarket("13874A")  // S&P 500 MINI
        "Cryptocurrencies" => f_requestMarket("146021")  // ETH
        "Currencies — Majors" => f_requestMarket("099741")  // EUR
        "Currencies — Emerging" => f_requestMarket("102741")  // BRL
        => f_emptyRequest()

f_requestSlot2(simple string cat) =>
    switch cat
        "Metals" => f_requestMarket("076651")  // PLATINUM
        "Energy" => f_requestMarket("111659")  // GASOLINE
        "Grains & Oilseeds" => f_requestMarket("005602")  // SOYBEANS
        "Soft Commodities" => f_requestMarket("042601")  // ORANGE JUICE
        "Equity Indices" => f_requestMarket("12460+")  // DOW JONES
        "Currencies — Majors" => f_requestMarket("097741")  // JPY
        "Currencies — Emerging" => f_requestMarket("122741")  // ZAR
        => f_emptyRequest()

f_requestSlot3(simple string cat) =>
    switch cat
        "Metals" => f_requestMarket("075651")  // PALLADIUM
        "Energy" => f_requestMarket("022651")  // HEATING OIL
        "Grains & Oilseeds" => f_requestMarket("026603")  // SOYBEAN MEAL
        "Equity Indices" => f_requestMarket("20974+")  // NASDAQ
        "Currencies — Majors" => f_requestMarket("096742")  // GBP
        "Currencies — Emerging" => f_requestMarket("089741")  // RUB
        => f_emptyRequest()

f_requestSlot4(simple string cat) =>
    switch cat
        "Metals" => f_requestMarket("085692")  // COPPER
        "Grains & Oilseeds" => f_requestMarket("007601")  // SOYBEAN OIL
        "Equity Indices" => f_requestMarket("209742")  // NASDAQ MINI
        "Currencies — Majors" => f_requestMarket("092741")  // CHF
        => f_emptyRequest()

f_requestSlot5(simple string cat) =>
    switch cat
        "Equity Indices" => f_requestMarket("239742")  // RUSSELL 2000
        "Currencies — Majors" => f_requestMarket("090741")  // CAD
        => f_emptyRequest()

f_requestSlot6(simple string cat) =>
    switch cat
        "Equity Indices" => f_requestMarket("240741")  // NIKKEI
        "Currencies — Majors" => f_requestMarket("232741")  // AUD
        => f_emptyRequest()

f_requestSlot7(simple string cat) =>
    switch cat
        "Equity Indices" => f_requestMarket("1170E1")  // VIX
        "Currencies — Majors" => f_requestMarket("112741")  // NZD
        => f_emptyRequest()

[oi0, oiPrev0, reportTime0, comLong0, comLongPrev0, comShort0, comShortPrev0, ncLong0, ncLongPrev0, ncShort0, ncShortPrev0] = f_requestSlot0(category)
[oi1, oiPrev1, reportTime1, comLong1, comLongPrev1, comShort1, comShortPrev1, ncLong1, ncLongPrev1, ncShort1, ncShortPrev1] = f_requestSlot1(category)
[oi2, oiPrev2, reportTime2, comLong2, comLongPrev2, comShort2, comShortPrev2, ncLong2, ncLongPrev2, ncShort2, ncShortPrev2] = f_requestSlot2(category)
[oi3, oiPrev3, reportTime3, comLong3, comLongPrev3, comShort3, comShortPrev3, ncLong3, ncLongPrev3, ncShort3, ncShortPrev3] = f_requestSlot3(category)
[oi4, oiPrev4, reportTime4, comLong4, comLongPrev4, comShort4, comShortPrev4, ncLong4, ncLongPrev4, ncShort4, ncShortPrev4] = f_requestSlot4(category)
[oi5, oiPrev5, reportTime5, comLong5, comLongPrev5, comShort5, comShortPrev5, ncLong5, ncLongPrev5, ncShort5, ncShortPrev5] = f_requestSlot5(category)
[oi6, oiPrev6, reportTime6, comLong6, comLongPrev6, comShort6, comShortPrev6, ncLong6, ncLongPrev6, ncShort6, ncShortPrev6] = f_requestSlot6(category)
[oi7, oiPrev7, reportTime7, comLong7, comLongPrev7, comShort7, comShortPrev7, ncLong7, ncLongPrev7, ncShort7, ncShortPrev7] = f_requestSlot7(category)

reqOI = array.from(oi0, oi1, oi2, oi3, oi4, oi5, oi6, oi7)
reqOIPrev = array.from(oiPrev0, oiPrev1, oiPrev2, oiPrev3, oiPrev4, oiPrev5, oiPrev6, oiPrev7)
reqReportTime = array.from(reportTime0, reportTime1, reportTime2, reportTime3, reportTime4, reportTime5, reportTime6, reportTime7)
reqComLong = array.from(comLong0, comLong1, comLong2, comLong3, comLong4, comLong5, comLong6, comLong7)
reqComLongPrev = array.from(comLongPrev0, comLongPrev1, comLongPrev2, comLongPrev3, comLongPrev4, comLongPrev5, comLongPrev6, comLongPrev7)
reqComShort = array.from(comShort0, comShort1, comShort2, comShort3, comShort4, comShort5, comShort6, comShort7)
reqComShortPrev = array.from(comShortPrev0, comShortPrev1, comShortPrev2, comShortPrev3, comShortPrev4, comShortPrev5, comShortPrev6, comShortPrev7)
reqNCLong = array.from(ncLong0, ncLong1, ncLong2, ncLong3, ncLong4, ncLong5, ncLong6, ncLong7)
reqNCLongPrev = array.from(ncLongPrev0, ncLongPrev1, ncLongPrev2, ncLongPrev3, ncLongPrev4, ncLongPrev5, ncLongPrev6, ncLongPrev7)
reqNCShort = array.from(ncShort0, ncShort1, ncShort2, ncShort3, ncShort4, ncShort5, ncShort6, ncShort7)
reqNCShortPrev = array.from(ncShortPrev0, ncShortPrev1, ncShortPrev2, ncShortPrev3, ncShortPrev4, ncShortPrev5, ncShortPrev6, ncShortPrev7)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT VALUES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float[] curOI = array.new_float(MAX_MARKETS, na)
var float[] curOIPrev = array.new_float(MAX_MARKETS, na)
var int[] curReportTime = array.new_int(MAX_MARKETS, na)
var int[] lastStoredReportTime = array.new_int(MAX_MARKETS, na)

var float[] curNCNet = array.new_float(MAX_MARKETS, na)
var float[] curNCDelta = array.new_float(MAX_MARKETS, na)
var float[] curNCLongPct = array.new_float(MAX_MARKETS, na)
var float[] curNCShortPct = array.new_float(MAX_MARKETS, na)
var float[] curNCFlip = array.new_float(MAX_MARKETS, na)

var float[] curComNet = array.new_float(MAX_MARKETS, na)
var float[] curComDelta = array.new_float(MAX_MARKETS, na)
var float[] curComLongPct = array.new_float(MAX_MARKETS, na)
var float[] curComShortPct = array.new_float(MAX_MARKETS, na)
var float[] curComFlip = array.new_float(MAX_MARKETS, na)

var float[] curNCD13 = array.new_float(MAX_MARKETS, na)
var float[] curNCD26 = array.new_float(MAX_MARKETS, na)
var float[] curNCD52 = array.new_float(MAX_MARKETS, na)
var float[] curNCI52 = array.new_float(MAX_MARKETS, na)
var float[] curNCI156 = array.new_float(MAX_MARKETS, na)

var float[] curComD13 = array.new_float(MAX_MARKETS, na)
var float[] curComD26 = array.new_float(MAX_MARKETS, na)
var float[] curComD52 = array.new_float(MAX_MARKETS, na)
var float[] curComI52 = array.new_float(MAX_MARKETS, na)
var float[] curComI156 = array.new_float(MAX_MARKETS, na)

var float[] curNCScore = array.new_float(MAX_MARKETS, na)
var string[] curNCBias = array.new_string(MAX_MARKETS, "NO DATA")
var float[] curComScore = array.new_float(MAX_MARKETS, na)
var string[] curComBias = array.new_string(MAX_MARKETS, "NO DATA")

// Weekly matrices: column 0 is latest, columns increase into the past.
var matrix<float> ncNetHistory = matrix.new<float>(MAX_MARKETS, MAX_HISTORY, na)
var matrix<float> comNetHistory = matrix.new<float>(MAX_MARKETS, MAX_HISTORY, na)
var matrix<float> ncFlipHistory = matrix.new<float>(MAX_MARKETS, MAX_HISTORY, na)
var matrix<float> comFlipHistory = matrix.new<float>(MAX_MARKETS, MAX_HISTORY, na)
var int[] historyCount = array.new_int(MAX_MARKETS, 0)

f_shiftPush(matrix<float> history, int row, float value) =>
    col = MAX_HISTORY - 1
    while col > 0
        matrix.set(history, row, col, matrix.get(history, row, col - 1))
        col -= 1
    matrix.set(history, row, 0, value)

f_storeReport(int row, float ncNet, float comNet, float ncFlip, float comFlip) =>
    f_shiftPush(ncNetHistory, row, ncNet)
    f_shiftPush(comNetHistory, row, comNet)
    f_shiftPush(ncFlipHistory, row, ncFlip)
    f_shiftPush(comFlipHistory, row, comFlip)
    array.set(historyCount, row, math.min(array.get(historyCount, row) + 1, MAX_HISTORY))

// Stochastic position of one history series. offset 0=current, 1=previous report.
f_histStoch(matrix<float> history, int row, int length, int count, int offset) =>
    available = math.max(count - offset, 0)
    n = math.min(length, available)
    float result = na
    if n > 0
        current = matrix.get(history, row, offset)
        float lo = na
        float hi = na
        j = offset
        last = offset + n - 1
        while j <= last
            v = matrix.get(history, row, j)
            if not na(v)
                lo := na(lo) ? v : math.min(lo, v)
                hi := na(hi) ? v : math.max(hi, v)
            j += 1
        if not na(current) and not na(lo) and not na(hi)
            result := hi == lo ? 50.0 : (current - lo) / (hi - lo) * 100.0
    result

// Stochastic position of NC Net - Commercial Net.
f_histDiffStoch(int row, int length, int count, int offset, bool commercialPerspective) =>
    available = math.max(count - offset, 0)
    n = math.min(length, available)
    float result = na
    if n > 0
        ncCurrent = matrix.get(ncNetHistory, row, offset)
        comCurrent = matrix.get(comNetHistory, row, offset)
        current = commercialPerspective ? comCurrent - ncCurrent : ncCurrent - comCurrent
        float lo = na
        float hi = na
        j = offset
        last = offset + n - 1
        while j <= last
            ncV = matrix.get(ncNetHistory, row, j)
            comV = matrix.get(comNetHistory, row, j)
            v = commercialPerspective ? comV - ncV : ncV - comV
            if not na(v)
                lo := na(lo) ? v : math.min(lo, v)
                hi := na(hi) ? v : math.max(hi, v)
            j += 1
        if not na(current) and not na(lo) and not na(hi)
            result := hi == lo ? 50.0 : (current - lo) / (hi - lo) * 100.0
    result

// Original positioning-bias model from the supplied COT Heatmap.
// Diff 0 = +100 bullish setup, Diff 50 = neutral, Diff 100 = -100 bearish.
// The 13 / 26 / 52 report windows use 20% / 30% / 50% weights.
f_ncBiasScore(float d13, float d26, float d52) =>
    na(d13) or na(d26) or na(d52) ? na :
     100.0 - 2.0 * (d13 * 0.20 + d26 * 0.30 + d52 * 0.50)

f_ncBiasLabel(
     float d13,
     float d26,
     float d52,
     float prevD13,
     float prevD26,
     float ncNetChange,
     float nc52,
     float nc156,
     float com52,
     float com156) =>

    if na(d13) or na(d26) or na(d52)
        "NO DATA"
    else
        weightedDiff = d13 * 0.20 + d26 * 0.30 + d52 * 0.50

        maxBullSetup = d13 <= 10 and d26 <= 10 and d52 <= 15
        bullSetup = weightedDiff <= 25 and d52 <= 30
        bullAligned = not na(nc52) and not na(nc156) and not na(com52) and not na(com156) and nc52 <= 20 and nc156 <= 30 and com52 >= 80 and com156 >= 70
        bullTurn = bullSetup and not na(prevD13) and d13 > prevD13 and (na(prevD26) or d26 >= prevD26)
        buyConfirmed = bullTurn and not na(ncNetChange) and ncNetChange > 0

        maxBearSetup = d13 >= 90 and d26 >= 90 and d52 >= 85
        bearSetup = weightedDiff >= 75 and d52 >= 70
        bearAligned = not na(nc52) and not na(nc156) and not na(com52) and not na(com156) and nc52 >= 80 and nc156 >= 70 and com52 <= 20 and com156 <= 30
        bearTurn = bearSetup and not na(prevD13) and d13 < prevD13 and (na(prevD26) or d26 <= prevD26)
        sellConfirmed = bearTurn and not na(ncNetChange) and ncNetChange < 0

        buyConfirmed ? "LONG BUILD" :
         bullTurn ? "BULL TURN" :
         maxBullSetup or bullSetup ? "BOTTOM SETUP" :
         sellConfirmed ? "SHORT BUILD" :
         bearTurn ? "BEAR TURN" :
         maxBearSetup or bearSetup ? "TOP RISK" :
         weightedDiff < 40 and not na(ncNetChange) and ncNetChange < 0 ? "LONG UNWIND" :
         weightedDiff < 40 ? "LONG BIAS" :
         weightedDiff > 60 and not na(ncNetChange) and ncNetChange > 0 ? "SHORT COVER" :
         weightedDiff > 60 ? "SHORT BIAS" :
         "NEUTRAL"

// Commercial participant-side bias.
// Commercial-vs-NC Diff is the inverse of NC-vs-Commercial Diff, so applying
// the same score orientation makes the visible Commercial bias opposite to NC.
// This column describes the Commercial participant stance, not a contrarian
// market-confirmation signal.
f_comBiasScore(float d13, float d26, float d52) =>
    na(d13) or na(d26) or na(d52) ? na :
     100.0 - 2.0 * (d13 * 0.20 + d26 * 0.30 + d52 * 0.50)

f_comBiasLabel(
     float d13,
     float d26,
     float d52,
     float prevD13,
     float prevD26,
     float comNetChange,
     float com52,
     float com156,
     float nc52,
     float nc156) =>

    if na(d13) or na(d26) or na(d52)
        "NO DATA"
    else
        weightedDiff = d13 * 0.20 + d26 * 0.30 + d52 * 0.50

        maxBullSetup = d13 <= 10 and d26 <= 10 and d52 <= 15
        bullSetup = weightedDiff <= 25 and d52 <= 30
        bullAligned = not na(com52) and not na(com156) and not na(nc52) and not na(nc156) and com52 <= 20 and com156 <= 30 and nc52 >= 80 and nc156 >= 70
        bullTurn = bullSetup and not na(prevD13) and d13 > prevD13 and (na(prevD26) or d26 >= prevD26)
        buyConfirmed = bullTurn and not na(comNetChange) and comNetChange > 0

        maxBearSetup = d13 >= 90 and d26 >= 90 and d52 >= 85
        bearSetup = weightedDiff >= 75 and d52 >= 70
        bearAligned = not na(com52) and not na(com156) and not na(nc52) and not na(nc156) and com52 >= 80 and com156 >= 70 and nc52 <= 20 and nc156 <= 30
        bearTurn = bearSetup and not na(prevD13) and d13 < prevD13 and (na(prevD26) or d26 <= prevD26)
        sellConfirmed = bearTurn and not na(comNetChange) and comNetChange < 0

        buyConfirmed ? "LONG BUILD" :
         bullTurn ? "BULL TURN" :
         maxBullSetup or bullSetup ? "BOTTOM SETUP" :
         sellConfirmed ? "SHORT BUILD" :
         bearTurn ? "BEAR TURN" :
         maxBearSetup or bearSetup ? "TOP RISK" :
         weightedDiff < 40 and not na(comNetChange) and comNetChange < 0 ? "LONG UNWIND" :
         weightedDiff < 40 ? "LONG BIAS" :
         weightedDiff > 60 and not na(comNetChange) and comNetChange > 0 ? "SHORT COVER" :
         weightedDiff > 60 ? "SHORT BIAS" :
         "NEUTRAL"

// Request and update every market on every chart bar.
for i = 0 to marketCount - 1
    marketName = f_marketName(category, i)

    oi = array.get(reqOI, i)
    oiPrev = array.get(reqOIPrev, i)
    reportTime = array.get(reqReportTime, i)
    comLong = array.get(reqComLong, i)
    comLongPrev = array.get(reqComLongPrev, i)
    comShort = array.get(reqComShort, i)
    comShortPrev = array.get(reqComShortPrev, i)
    ncLong = array.get(reqNCLong, i)
    ncLongPrev = array.get(reqNCLongPrev, i)
    ncShort = array.get(reqNCShort, i)
    ncShortPrev = array.get(reqNCShortPrev, i)

    comNet = comLong - comShort
    comNetPrev = comLongPrev - comShortPrev
    comDelta = comNet - comNetPrev

    ncNet = ncLong - ncShort
    ncNetPrev = ncLongPrev - ncShortPrev
    ncDelta = ncNet - ncNetPrev

    ncLongPct = oi == 0 ? na : ncLong / oi * 100.0
    ncShortPct = oi == 0 ? na : ncShort / oi * 100.0
    ncFlip = ncLongPct - ncShortPct

    comLongPct = oi == 0 ? na : comLong / oi * 100.0
    comShortPct = oi == 0 ? na : comShort / oi * 100.0
    comFlip = comLongPct - comShortPct

    array.set(curOI, i, oi)
    array.set(curOIPrev, i, oiPrev)
    array.set(curReportTime, i, reportTime)

    array.set(curNCNet, i, ncNet)
    array.set(curNCDelta, i, ncDelta)
    array.set(curNCLongPct, i, ncLongPct)
    array.set(curNCShortPct, i, ncShortPct)
    array.set(curNCFlip, i, ncFlip)

    array.set(curComNet, i, comNet)
    array.set(curComDelta, i, comDelta)
    array.set(curComLongPct, i, comLongPct)
    array.set(curComShortPct, i, comShortPct)
    array.set(curComFlip, i, comFlip)

    lastStoredTime = array.get(lastStoredReportTime, i)
    isNewReport = not na(reportTime) and (na(lastStoredTime) or reportTime != lastStoredTime)

    if isNewReport
        f_storeReport(i, ncNet, comNet, ncFlip, comFlip)
        array.set(lastStoredReportTime, i, reportTime)

    count = array.get(historyCount, i)

    ncD13 = f_histDiffStoch(i, 13, count, 0, false)
    ncD26 = f_histDiffStoch(i, 26, count, 0, false)
    ncD52 = f_histDiffStoch(i, 52, count, 0, false)
    ncI52 = f_histStoch(ncNetHistory, i, 52, count, 0)
    ncI156 = f_histStoch(ncNetHistory, i, 156, count, 0)

    comD13 = f_histDiffStoch(i, 13, count, 0, true)
    comD26 = f_histDiffStoch(i, 26, count, 0, true)
    comD52 = f_histDiffStoch(i, 52, count, 0, true)
    comI52 = f_histStoch(comNetHistory, i, 52, count, 0)
    comI156 = f_histStoch(comNetHistory, i, 156, count, 0)

    prevNCD13 = f_histDiffStoch(i, 13, count, 1, false)
    prevNCD26 = f_histDiffStoch(i, 26, count, 1, false)
    prevComD13 = f_histDiffStoch(i, 13, count, 1, true)
    prevComD26 = f_histDiffStoch(i, 26, count, 1, true)

    ncScore = f_ncBiasScore(ncD13, ncD26, ncD52)
    ncBias = f_ncBiasLabel(ncD13, ncD26, ncD52, prevNCD13, prevNCD26, ncDelta, ncI52, ncI156, comI52, comI156)
    comScore = f_comBiasScore(comD13, comD26, comD52)
    comBias = f_comBiasLabel(comD13, comD26, comD52, prevComD13, prevComD26, comDelta, comI52, comI156, ncI52, ncI156)

    array.set(curNCD13, i, ncD13)
    array.set(curNCD26, i, ncD26)
    array.set(curNCD52, i, ncD52)
    array.set(curNCI52, i, ncI52)
    array.set(curNCI156, i, ncI156)

    array.set(curComD13, i, comD13)
    array.set(curComD26, i, comD26)
    array.set(curComD52, i, comD52)
    array.set(curComI52, i, comI52)
    array.set(curComI156, i, comI156)

    array.set(curNCScore, i, ncScore)
    array.set(curNCBias, i, ncBias)
    array.set(curComScore, i, comScore)
    array.set(curComBias, i, comBias)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WEEKLY BAR-SPARKLINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_barChar(int level) =>
    switch level
        0 => "▁"
        1 => "▂"
        2 => "▃"
        3 => "▄"
        4 => "▅"
        5 => "▆"
        6 => "▇"
        => "█"

f_historyValue(int row, int col, bool commercial) =>
    commercial ? matrix.get(comFlipHistory, row, col) : matrix.get(ncFlipHistory, row, col)

f_sparkline(int row, bool commercial) =>
    count = array.get(historyCount, row)
    n = math.min(historyBars, count)
    string bars = ""

    if n > 0
        float lo = na
        float hi = na

        if historyScaleMode == "Fixed Percentage Range"
            lo := -historyFixedScale
            hi := historyFixedScale
        else
            scan = 0
            while scan < n
                v = f_historyValue(row, scan, commercial)
                if not na(v)
                    lo := na(lo) ? v : math.min(lo, v)
                    hi := na(hi) ? v : math.max(hi, v)
                scan += 1

        if na(lo) or na(hi)
            bars := ""
        else
            oldest = n - 1
            while oldest >= 0
                v = f_historyValue(row, oldest, commercial)
                norm = na(v) ? 0.0 : hi == lo ? 0.5 : math.max(math.min((v - lo) / (hi - lo), 1.0), 0.0)
                level = int(math.round(norm * 7.0))
                bars := bars + f_barChar(level)
                oldest -= 1

    bars

f_historyTooltip(int row, string marketName, bool commercial) =>
    count = array.get(historyCount, row)
    n = math.min(historyBars, count)
    participantLabel = commercial ? "Commercial Flip%" : "Non-Commercial Flip%"
    string tip = marketName + " — " + participantLabel + " weekly bars\nOldest → Latest"

    if n == 0
        tip := tip + "\nNo stored reports"
    else
        oldest = n - 1
        displayIndex = 1
        while oldest >= 0
            v = f_historyValue(row, oldest, commercial)
            tip := tip + "\n" + str.tostring(displayIndex) + ": " + (na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "#.1") + "%")
            displayIndex += 1
            oldest -= 1

    tip

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SORT ORDER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_sortValue(int marketIndex) =>
    score = useCommercial ? array.get(curComScore, marketIndex) : array.get(curNCScore, marketIndex)
    sortMode == "Strongest Extreme" ? math.abs(score) : score

f_shouldShift(float leftValue, float keyValue) =>
    sortMode == "Bullish → Bearish" ? leftValue < keyValue :
     sortMode == "Bearish → Bullish" ? leftValue > keyValue :
     sortMode == "Strongest Extreme" ? leftValue < keyValue :
     false

f_order() =>
    int[] order = array.new_int()
    for i = 0 to marketCount - 1
        array.push(order, i)

    if sortMode != "Category Order"
        i = 1
        while i < array.size(order)
            key = array.get(order, i)
            keyValue = nz(f_sortValue(key), sortMode == "Bearish → Bullish" ? 100000.0 : -100000.0)
            j = i - 1
            while j >= 0
                left = array.get(order, j)
                leftValue = nz(f_sortValue(left), sortMode == "Bearish → Bullish" ? 100000.0 : -100000.0)
                if f_shouldShift(leftValue, keyValue)
                    array.set(order, j + 1, left)
                    j -= 1
                else
                    break
            array.set(order, j + 1, key)
            i += 1

    order

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE HELPERS — NEUTRAL SURFACES, VALUE-COLORED TYPOGRAPHY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_pos(string x) =>
    switch x
        "Top Right" => position.top_right
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Center" => position.top_center
        "Middle Center" => position.middle_center
        "Bottom Center" => position.bottom_center
        "Top Left" => position.top_left
        "Middle Left" => position.middle_left
        "Bottom Left" => position.bottom_left
        => position.middle_center

f_size(string x) =>
    switch x
        "Auto" => size.auto
        "Large" => size.large
        "Normal" => size.normal
        "Small" => size.small
        "Tiny" => size.tiny
        => size.tiny

tBg = chart.bg_color
tFg = chart.fg_color
txtSize = f_size(tableSize)

f_norm01(float v, float minV, float maxV) =>
    hi = maxV <= minV ? minV + 1.0 : maxV
    math.max(math.min((v - minV) / (hi - minV), 1.0), 0.0)

f_levelColor(float v, float minV, float maxV, bool upGood) =>
    if na(v)
        color.new(tFg, 35)
    else
        x = f_norm01(v, minV, maxV)
        upGood ?
             (x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, dnCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, upCol)) :
             (x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, upCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, dnCol))

f_scoreColor(float score) =>
    f_levelColor(score, 0, 100, true)

f_signedColor(float v, float scale) =>
    if na(v)
        color.new(tFg, 35)
    else
        s = math.max(scale, 0.0001)
        x = math.max(math.min((v + s) / (2.0 * s), 1.0), 0.0)
        x <= 0.5 ? color.from_gradient(x, 0.0, 0.5, dnCol, mdCol) : color.from_gradient(x, 0.5, 1.0, mdCol, upCol)

headerBg = color.from_gradient(0.055, 0.0, 1.0, tBg, tFg)
titleBg = color.from_gradient(0.095, 0.0, 1.0, tBg, tFg)
sectionBg = color.from_gradient(0.075, 0.0, 1.0, tBg, tFg)
rowBgA = color.from_gradient(0.010, 0.0, 1.0, tBg, tFg)
rowBgB = color.from_gradient(0.035, 0.0, 1.0, tBg, tFg)
// Neutral signal-strip surfaces: visually separate interpretation from raw data
// without returning to data-dependent heatmap backgrounds.
signalBgA = color.from_gradient(0.045, 0.0, 1.0, tBg, tFg)
signalBgB = color.from_gradient(0.070, 0.0, 1.0, tBg, tFg)
footerBg = color.from_gradient(0.050, 0.0, 1.0, tBg, tFg)
separatorBg = color.from_gradient(0.100, 0.0, 1.0, tBg, tFg)

f_rowBg(int row) =>
    ((row - 2) % 2 == 0) ? rowBgA : rowBgB

f_signalBg(int row) =>
    ((row - 2) % 2 == 0) ? signalBgA : signalBgB

f_biasStateColor(string label, float score) =>
    softBull = color.from_gradient(0.62, 0.0, 1.0, tFg, upCol)
    softBear = color.from_gradient(0.62, 0.0, 1.0, tFg, dnCol)
    neutralBias = color.from_gradient(0.50, 0.0, 1.0, tFg, mdCol)

    label == "BOTTOM SETUP" or label == "BULL TURN" or label == "LONG BUILD" ? upCol :
     label == "LONG BIAS" or label == "LONG UNWIND" ? softBull :
     label == "NEUTRAL" ? neutralBias :
     label == "SHORT BIAS" or label == "SHORT COVER" ? softBear :
     label == "SHORT BUILD" or label == "BEAR TURN" or label == "TOP RISK" ? dnCol :
     f_signedColor(score, 100.0)

f_biasDisplay(string label) =>
    label == "LONG BUILD" ? "▲ LONG BUILD" :
     label == "BULL TURN" ? "↗ BULL TURN" :
     label == "BOTTOM SETUP" ? "▲ BUY" :
     label == "LONG BIAS" ? "▲ LONG BIAS" :
     label == "LONG UNWIND" ? "↘ LONG UNWIND" :
     label == "SHORT COVER" ? "↗ SHORT COVER" :
     label == "SHORT BIAS" ? "▼ SHORT BIAS" :
     label == "TOP RISK" ? "◇ TOP RISK" :
     label == "BEAR TURN" ? "↘ BEAR TURN" :
     label == "SHORT BUILD" ? "▼ SHORT BUILD" :
     label == "NEUTRAL" ? "• NEUTRAL" :
     label == "NO DATA" ? "— NO DATA" : label

f_fmtPosition(float v) =>
    if na(v)
        "n/a"
    else
        av = math.abs(v)
        prefix = v > 0 ? "+" : ""
        prefix + (av >= 1000000 ? str.tostring(v / 1000000.0, "#.1") + "M" :
         av >= 1000 ? str.tostring(v / 1000.0, "#.1") + "K" :
         str.tostring(v, "#.0"))

f_fmtPct(float v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "#.1") + "%"

f_fmtLevel(float v) =>
    na(v) ? "n/a" : str.tostring(v, "#.0")

f_fmtScore(float v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "#.0")

f_cell(table tbl, int col, int row, string cellText, color bg, color textColor, string tip = "", string halign = text.align_center, string cellSize = size.small, string fontFamily = font.family_default) =>
    table.cell(
         tbl,
         col,
         row,
         text = cellText,
         bgcolor = bg,
         text_color = textColor,
         text_size = cellSize,
         text_font_family = fontFamily,
         text_halign = halign,
         text_valign = text.align_center,
         tooltip = tip)

f_valueCell(table tbl, int col, int row, string cellText, color valueColor, string tip) =>
    f_cell(tbl, col, row, cellText, f_rowBg(row), valueColor, tip, text.align_center, txtSize)

f_signalCell(table tbl, int col, int row, string cellText, color valueColor, string tip, string cellSize = size.small, string fontFamily = font.family_default) =>
    f_cell(tbl, col, row, cellText, f_signalBg(row), valueColor, tip, text.align_center, cellSize, fontFamily)

f_headerCell(table tbl, int col, string label, string tip) =>
    f_cell(tbl, col, 1, label, headerBg, color.new(tFg, 8), tip, text.align_center, size.small)

f_groupHeader(table tbl, int firstCol, int lastCol, string label, string tip) =>
    if lastCol > firstCol
        table.merge_cells(tbl, firstCol, 1, lastCol, 1)
    f_cell(tbl, firstCol, 1, label, sectionBg, color.new(tFg, 5), tip, text.align_center, size.small)


f_ncAlignment(float nc52, float nc156) =>
    na(nc52) or na(nc156) ? "Unavailable" :
     nc52 <= 20 and nc156 <= 30 ? "Bullish extreme" :
     nc52 >= 80 and nc156 >= 70 ? "Bearish extreme" :
     nc52 < 40 and nc156 < 40 ? "Bullish leaning" :
     nc52 > 60 and nc156 > 60 ? "Bearish leaning" :
     "Mixed / neutral"

f_comAlignment(float com52, float com156) =>
    na(com52) or na(com156) ? "Unavailable" :
     com52 >= 80 and com156 >= 70 ? "Bullish confirmation" :
     com52 <= 20 and com156 <= 30 ? "Bearish confirmation" :
     com52 > 60 and com156 > 60 ? "Bullish leaning" :
     com52 < 40 and com156 < 40 ? "Bearish leaning" :
     "Mixed / neutral"

f_ncBiasTooltip(int i, string marketName) =>
    d13 = array.get(curNCD13, i)
    d26 = array.get(curNCD26, i)
    d52 = array.get(curNCD52, i)
    nc52 = array.get(curNCI52, i)
    nc156 = array.get(curNCI156, i)
    com52 = array.get(curComI52, i)
    com156 = array.get(curComI156, i)
    score = array.get(curNCScore, i)
    bias = array.get(curNCBias, i)
    ncDelta = array.get(curNCDelta, i)

    marketName + " — Non-Commercial bias" +
     "\nBias: " + f_biasDisplay(bias) +
     "\nNC score: " + f_fmtScore(score) + " (-100 bearish to +100 bullish)" +
     "\nNC Diff 13 / 26 / 52: " + f_fmtLevel(d13) + " / " + f_fmtLevel(d26) + " / " + f_fmtLevel(d52) +
     "\nNC alignment: " + f_ncAlignment(nc52, nc156) +
     "\nCommercial confirmation: " + f_comAlignment(com52, com156) +
     "\nNC Net Change: " + f_fmtPosition(ncDelta)

f_comBiasTooltip(int i, string marketName) =>
    d13 = array.get(curComD13, i)
    d26 = array.get(curComD26, i)
    d52 = array.get(curComD52, i)
    com52 = array.get(curComI52, i)
    com156 = array.get(curComI156, i)
    nc52 = array.get(curNCI52, i)
    nc156 = array.get(curNCI156, i)
    score = array.get(curComScore, i)
    bias = array.get(curComBias, i)
    comDelta = array.get(curComDelta, i)

    marketName + " — Commercial bias" +
     "\nBias: " + f_biasDisplay(bias) +
     "\nCOM score: " + f_fmtScore(score) + " (-100 bearish to +100 bullish)" +
     "\nCOM Diff 13 / 26 / 52: " + f_fmtLevel(d13) + " / " + f_fmtLevel(d26) + " / " + f_fmtLevel(d52) +
     "\nCommercial alignment: " + f_comAlignment(com52, com156) +
     "\nNC confirmation: " + f_ncAlignment(nc52, nc156) +
     "\nCOM Net Change: " + f_fmtPosition(comDelta) +
     "\nModel: Commercial participant-side bias; intentionally opposite to NC when the two Diff series are symmetric."

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE — SELECTED PARTICIPANT ONLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table cotTable = table.new(
     f_pos(tablePos),
     COLS,
     marketCount + 3,
     bgcolor = tBg,
     frame_color = color.new(tFg, 55),
     frame_width = 1,
     border_color = color.new(tFg, 90),
     border_width = 0)

if barstate.islast
    table.clear(cotTable, 0, 0, COLS - 1, marketCount + 2)

    if showTable
        participantShort = useCommercial ? "COMMERCIAL" : "NON-COMMERCIAL"
        participantPrefix = useCommercial ? "COM" : "NC"

        // Title
        table.merge_cells(cotTable, 0, 0, COLS - 1, 0)
        reportText = includeOptions ? "FUTURES + OPTIONS" : "FUTURES ONLY"
        titleText = "COT CATEGORY SCREENER  •  " + str.upper(category) + "  •  " + participantShort + "  •  " + reportText
        f_cell(cotTable, 0, 0, titleText, titleBg, tFg, titleText, text.align_center, size.normal)

        // Column headers
        f_headerCell(cotTable, C_RANK, "#", "Current displayed rank")
        f_headerCell(cotTable, C_MARKET, "MARKET", "COT market")
        f_headerCell(cotTable, C_OI, "OI", "Open Interest")
        f_headerCell(cotTable, C_NET, "NET", participantMode + " net position")
        f_headerCell(cotTable, C_DNET, "ΔNET", "Weekly change in " + participantMode + " net position")
        f_headerCell(cotTable, C_LONG, "L%", participantMode + " long positions as % of open interest")
        f_headerCell(cotTable, C_SHORT, "S%", participantMode + " short positions as % of open interest")
        f_headerCell(cotTable, C_FLIP, "FLIP%", participantShort + " Long% minus Short%")
        f_headerCell(cotTable, C_D13, "D13", "13-report stochastic of " + participantShort + " net minus the opposite participant")
        f_headerCell(cotTable, C_D26, "D26", "26-report stochastic of " + participantShort + " net minus the opposite participant")
        f_headerCell(cotTable, C_D52, "D52", "52-report stochastic of " + participantShort + " net minus the opposite participant")
        f_headerCell(cotTable, C_I52, "I52", "52-report COT index of " + participantMode + " net position")
        f_headerCell(cotTable, C_I156, "I3Y", "156-report COT index of " + participantMode + " net position")
        f_headerCell(cotTable, C_SCORE, "SCORE", participantMode + " score: -100 bearish to +100 bullish")
        f_headerCell(cotTable, C_BIAS, "BIAS", participantMode + " positioning stage")
        f_headerCell(cotTable, C_HISTORY, str.tostring(historyBars) + "W", participantMode + " Flip% history, oldest to latest")

        order = f_order()

        for displayRow = 0 to marketCount - 1
            i = array.get(order, displayRow)
            row = displayRow + 2
            marketName = f_marketName(category, i)
            marketLabel = f_marketLabel(marketName)
            code = f_getTickerCode(marketName)

            oi = array.get(curOI, i)

            net = useCommercial ? array.get(curComNet, i) : array.get(curNCNet, i)
            delta = useCommercial ? array.get(curComDelta, i) : array.get(curNCDelta, i)
            longPct = useCommercial ? array.get(curComLongPct, i) : array.get(curNCLongPct, i)
            shortPct = useCommercial ? array.get(curComShortPct, i) : array.get(curNCShortPct, i)
            flip = useCommercial ? array.get(curComFlip, i) : array.get(curNCFlip, i)
            d13 = useCommercial ? array.get(curComD13, i) : array.get(curNCD13, i)
            d26 = useCommercial ? array.get(curComD26, i) : array.get(curNCD26, i)
            d52 = useCommercial ? array.get(curComD52, i) : array.get(curNCD52, i)
            i52 = useCommercial ? array.get(curComI52, i) : array.get(curNCI52, i)
            i156 = useCommercial ? array.get(curComI156, i) : array.get(curNCI156, i)
            score = useCommercial ? array.get(curComScore, i) : array.get(curNCScore, i)
            bias = useCommercial ? array.get(curComBias, i) : array.get(curNCBias, i)

            f_cell(cotTable, C_RANK, row, str.tostring(displayRow + 1), f_rowBg(row), color.new(tFg, 20), "Displayed rank", text.align_center, txtSize)
            f_cell(cotTable, C_MARKET, row, marketLabel, f_rowBg(row), tFg, marketName + "\nCFTC code: " + code, text.align_left, txtSize)
            f_cell(cotTable, C_OI, row, f_fmtPosition(oi), f_rowBg(row), color.new(tFg, 12), "Open Interest: " + f_fmtPosition(oi), text.align_center, txtSize)

            netColor = f_signedColor(flip, flipScale)
            f_valueCell(cotTable, C_NET, row, f_fmtPosition(net), netColor, participantPrefix + " Net: " + f_fmtPosition(net))
            f_valueCell(cotTable, C_DNET, row, f_fmtPosition(delta), netColor, participantPrefix + " weekly net change: " + f_fmtPosition(delta))
            f_valueCell(cotTable, C_LONG, row, f_fmtPct(longPct), f_levelColor(longPct, 0, 100, true), participantPrefix + " Long%: " + f_fmtPct(longPct))
            f_valueCell(cotTable, C_SHORT, row, f_fmtPct(shortPct), f_levelColor(shortPct, 0, 100, false), participantPrefix + " Short%: " + f_fmtPct(shortPct))
            f_valueCell(cotTable, C_FLIP, row, f_fmtPct(flip), f_signedColor(flip, flipScale), participantPrefix + " Flip%: " + f_fmtPct(flip))

            // Low Diff = bullish score; high Diff = bearish score.
            f_valueCell(cotTable, C_D13, row, f_fmtLevel(d13), f_levelColor(d13, 0, 100, false), participantPrefix + " Difference 13: " + f_fmtLevel(d13))
            f_valueCell(cotTable, C_D26, row, f_fmtLevel(d26), f_levelColor(d26, 0, 100, false), participantPrefix + " Difference 26: " + f_fmtLevel(d26))
            f_valueCell(cotTable, C_D52, row, f_fmtLevel(d52), f_levelColor(d52, 0, 100, false), participantPrefix + " Difference 52: " + f_fmtLevel(d52))
            f_valueCell(cotTable, C_I52, row, f_fmtLevel(i52), f_scoreColor(i52), participantPrefix + " Index 52: " + f_fmtLevel(i52))
            f_valueCell(cotTable, C_I156, row, f_fmtLevel(i156), f_scoreColor(i156), participantPrefix + " Index 156: " + f_fmtLevel(i156))

            scoreColor = f_signedColor(score, 100.0)
            f_signalCell(cotTable, C_SCORE, row, f_fmtScore(score), scoreColor, participantPrefix + " score: " + f_fmtScore(score))

            biasColor = f_biasStateColor(bias, score)
            biasTooltip = useCommercial ? f_comBiasTooltip(i, marketName) : f_ncBiasTooltip(i, marketName)
            f_signalCell(cotTable, C_BIAS, row, f_biasDisplay(bias), biasColor, biasTooltip)

            bars = f_sparkline(i, useCommercial)
            historyTextColor = na(flip) ? color.new(tFg, 18) : flip >= 0 ? upCol : dnCol
            f_signalCell(
                 cotTable,
                 C_HISTORY,
                 row,
                 bars,
                 historyTextColor,
                 f_historyTooltip(i, marketName, useCommercial),
                 size.small,
                 font.family_monospace)

        // Footer
        footerRow = marketCount + 2
        table.merge_cells(cotTable, 0, footerRow, COLS - 1, footerRow)
        firstTime = array.get(curReportTime, 0)
        dateText = na(firstTime) ? "n/a" : str.format_time(firstTime, "yyyy-MM-dd", syminfo.timezone)
        footerText = "REPORT " + dateText + "  •  " + str.tostring(marketCount) + " MARKETS  •  PARTICIPANT: " + str.upper(participantMode) + "  •  SORT: " + sortMode + "  •  " + str.tostring(historyBars) + "W FLIP%  •  HOVER FOR DETAIL"
        f_cell(cotTable, 0, footerRow, footerText, footerBg, color.new(tFg, 12), footerText, text.align_left, size.tiny)
````

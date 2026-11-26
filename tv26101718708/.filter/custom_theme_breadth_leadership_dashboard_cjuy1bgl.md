# Custom Theme Breadth & Leadership Dashboard

- url: https://www.tradingview.com/script/CJuY1Bgl-Custom-Theme-Breadth-Leadership-Dashboard/
- type: indicator
- pine_id: PUB;ea870906be004f6bbf8e29ddef8ddd5a
- version: 2.0

## Description

[b]Custom Theme Breadth & Leadership Dashboard[/b]

This script is a customizable theme-breadth dashboard designed to help traders monitor whether a selected group of stocks or ETFs is showing broad participation, narrow leadership, mixed behaviour, or short-term weakness.

The main purpose of the script is to help traders avoid looking at one symbol in isolation. Many strong market moves happen through themes, sectors, or related groups of stocks. For example, AI infrastructure may include semiconductors, memory, networking, data-centre hardware, power infrastructure and cooling. This dashboard allows users to place related symbols into one basket and quickly see whether strength is broad-based or limited to only a few names.

The script is not a buy or sell signal. It is a decision-support tool for theme monitoring, sector rotation, watchlist review and relative leadership analysis.

[b]What the dashboard shows[/b]

At the top of the table, the dashboard shows the overall condition of the selected basket:

Overall Theme Read
Constructive Symbols
Breadth %
Leaders
Average Score

Below the summary section, the table displays each selected symbol with the following columns:

1D: one-day rate of change
1W: five-trading-day rate of change
1M: twenty-one-trading-day rate of change
3M: sixty-three-trading-day rate of change
YTD: year-to-date rate of change
Score: a 0 to 10 participation score based on positive returns across multiple timeframes
Status: a short-term participation label based on recent performance behaviour

The score is designed to reward symbols that are positive across multiple timeframes. A symbol receives points for positive 1D, 1W, 1M, 3M and YTD performance, with additional bonus points for stronger 1W and 1M momentum.

[b]Status definitions[/b]

Leading: 1W, 1M and 3M performance are all positive.
Improving: 1D and 1W are positive, but 1M is still negative.
Weakening: 1D and 1W are negative, but 3M is still positive.
Lagging: 1W and 1M are both negative.
Mixed: the symbol does not clearly fit into the other categories.

Important note on [b][i]“Weakening”[/i][/b]

A symbol can still be a strong longer-term leader and appear as “Weakening” if it has recently pulled back.

For example, a stock may have very strong 3M or YTD performance but still be classified as Weakening if its 1D and 1W performance are negative. This is intentional. The dashboard is designed to show current participation and short-term behaviour, not only long-term leadership quality.

[b]Constructive Symbols[/b]

Constructive Symbols means the number of enabled symbols currently classified as either Leading or Improving.

This is a short-term participation measure. It does not mean that all other symbols are bad companies or poor long-term investments. It simply means they are not currently showing the short-term participation pattern required to be counted as constructive by this dashboard.

[b]Breadth %[/b]

Breadth % shows the percentage of enabled symbols that are currently constructive.

For example, if the dashboard shows 2 / 10 and 20%, it means that 2 out of the 10 enabled symbols are currently classified as either Leading or Improving.

[b]Leaders[/b]

Leaders shows how many enabled symbols are classified as Leading.

[b]Average Score[/b]

Average Score shows the average score across all enabled symbols in the selected basket.

[b]Overall Theme Read[/b]

The script converts the breadth and average score into an overall theme interpretation:

Broad Strength: many symbols in the basket are constructive and the average score is strong.
Narrow Leadership: the average score is strong, but breadth is not broad enough. This can mean only a few leaders are carrying the theme.
Mixed Theme: some symbols are working, but participation is uneven.
Weak Theme: few symbols are constructive and the group is not showing broad strength.

[b]How to use[/b]

1. Choose Core Themes, Full Themes or Custom List mode.
2. In Custom List mode, enter the stocks or ETFs that represent the market theme you want to monitor.
3. Enable or disable symbols depending on your watchlist.
4. Use the Overall Theme Read to understand the condition of the basket.
5. Use Constructive Symbols and Breadth % to understand whether participation is broad or narrow.
6. Use the individual symbol rows to identify which names are leading, improving, weakening, lagging or mixed.
7. Use the dashboard together with your own chart analysis, support/resistance levels, volume, earnings dates and risk management.

[b]Example use cases[/b]

A trader studying AI infrastructure could create a custom basket containing semiconductor, memory, networking, server, data-centre power and cooling names. If only one or two names are strong while the rest are weakening, the dashboard may show narrow leadership or a weak theme. If many names are leading or improving together, the dashboard may show broad strength.

A trader studying sector rotation could use the Core Themes or Full Themes modes to compare ETFs and identify where participation is improving or deteriorating.

[b]Limitations[/b]

This script does not predict price movement.
It does not provide automatic buy or sell signals.
It does not replace individual chart analysis.
It does not account for earnings dates, company fundamentals, valuation or news.
A strong dashboard reading should still be confirmed with price structure, volume, market condition and risk management.

[b]The script is designed to help traders quickly evaluate theme participation and leadership across a custom basket of symbols.[/b]

[b]Sample snapshots[/b]

[image]https://www.tradingview.com/x/y84e3dAQ/[/image]
[image]https://www.tradingview.com/x/tg5dNgiY/[/image]
[image]https://www.tradingview.com/x/2ntiVF2c/[/image]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0

// Custom Theme Breadth & Leadership Dashboard

// This script is designed to help traders monitor whether a user-defined

// market theme is showing broad participation, narrow leadership, mixed action,

// or weakness. It evaluates a selected basket of ETFs or stocks using short-

// and medium-term rate-of-change measures, then converts the individual symbol

// readings into a theme-level breadth summary.

//

// The script is not a buy/sell signal. It is a decision-support dashboard for

// theme monitoring, sector rotation, leadership checks and watchlist review.

//@version=6

indicator("Custom Theme Breadth & Leadership Dashboard v2", overlay = true, dynamic_requests = true)

//----------------------------------------------------

// Safety

//----------------------------------------------------

if timeframe.in_seconds() > timeframe.in_seconds("1D")

    runtime.error("Please switch to Daily timeframe or lower")

//----------------------------------------------------

// Theme Type

//----------------------------------------------------

type theme

    string name

    string sym

    string ticker

    bool autoMeta

//----------------------------------------------------

// Helpers

//----------------------------------------------------

f_len(int x) =>

    na(x) ? 1 : math.max(1, x)

f_pos(string y, string x) =>

    y == "Top" and x == "Right" ? position.top_right :

     y == "Top" and x == "Center" ? position.top_center :

     y == "Top" and x == "Left" ? position.top_left :

     y == "Middle" and x == "Right" ? position.middle_right :

     y == "Middle" and x == "Center" ? position.middle_center :

     y == "Middle" and x == "Left" ? position.middle_left :

     y == "Bottom" and x == "Right" ? position.bottom_right :

     y == "Bottom" and x == "Center" ? position.bottom_center :

     position.bottom_left

f_color(float val, float strongPos, float medPos, float lightPos, float strongNeg, float medNeg) =>

    val > strongPos ? color.rgb(0, 146, 5) :

     val > medPos ? color.rgb(50, 180, 54) :

     val > lightPos ? color.rgb(137, 230, 140) :

     val < strongNeg ? color.rgb(250, 27, 27) :

     val < medNeg ? color.rgb(250, 100, 100) :

     val < 0 ? color.rgb(250, 181, 181) :

     color.rgb(252, 221, 221)

f_status_color(string st) =>

    st == "Leading" ? color.rgb(0, 146, 5) :

     st == "Improving" ? color.rgb(50, 180, 54) :

     st == "Weakening" ? color.rgb(250, 181, 181) :

     st == "Lagging" ? color.rgb(250, 27, 27) :

     color.gray

f_theme_read(float breadthPct, float avgScore) =>

    breadthPct >= 70 and avgScore >= 6.5 ? "Broad Strength" :

     breadthPct < 70 and avgScore >= 6.5 ? "Narrow Leadership" :

     breadthPct >= 40 and avgScore >= 4.0 ? "Mixed Theme" :

     "Weak Theme"

f_theme_read_color(string read) =>

    read == "Broad Strength" ? color.rgb(0, 146, 5) :

     read == "Narrow Leadership" ? color.rgb(255, 170, 0) :

     read == "Mixed Theme" ? color.gray :

     color.rgb(250, 27, 27)

//----------------------------------------------------

// Inputs

//----------------------------------------------------

displayGroup = "Display"

yPos = input.string("Middle", "Table Position", options = ["Top", "Middle", "Bottom"], inline = "pos", group = displayGroup)

xPos = input.string("Left", "", options = ["Right", "Center", "Left"], inline = "pos", group = displayGroup)

colBy = input.string("Text", "Show Colours By", options = ["Text", "Background"], group = displayGroup)

tableBgColor = input.color(color.rgb(0, 0, 0), "Table Background", group = displayGroup)

tableTextColor = input.color(color.rgb(196, 200, 212), "Text Colour", group = displayGroup)

txtSize = input.int(11, "Text Size", minval = 8, maxval = 20, group = displayGroup)

sortBy = input.string("Score", "Sort By", options = ["Score", "Status", "1 Day", "1 Week", "1 Month", "3 Months", "YTD"], group = displayGroup)

listMode = input.string("Saved Preset 1", "List Mode", options = ["Core Themes", "Full Themes", "Saved Preset 1", "Saved Preset 2", "Saved Preset 3", "Saved Preset 4", "Saved Preset 5"], group = displayGroup)

//----------------------------------------------------

// Theme On / Off Controls

//----------------------------------------------------

themeGroup = "Theme On / Off"

showSPY  = input.bool(true, "S&P 500", group = themeGroup, inline = "t1")

showQQQ  = input.bool(true, "Nasdaq 100", group = themeGroup, inline = "t1")

showSMH  = input.bool(true, "Semiconductors", group = themeGroup, inline = "t2")

showIGV  = input.bool(true, "Software", group = themeGroup, inline = "t2")

showHACK = input.bool(true, "Cybersecurity", group = themeGroup, inline = "t3")

showSKYY = input.bool(true, "Cloud Computing", group = themeGroup, inline = "t3")

showBOTZ = input.bool(true, "AI / Robotics", group = themeGroup, inline = "t4")

showXBI  = input.bool(true, "Biotech", group = themeGroup, inline = "t4")

showXLV  = input.bool(true, "Healthcare", group = themeGroup, inline = "t5")

showTLT  = input.bool(true, "Long Term Treasuries", group = themeGroup, inline = "t5")

showQTUM = input.bool(true, "Quantum", group = themeGroup, inline = "t6")

showARKG = input.bool(true, "Genomics", group = themeGroup, inline = "t6")

showXLI  = input.bool(true, "Industrials", group = themeGroup, inline = "t7")

showKRE  = input.bool(true, "Regional Banks", group = themeGroup, inline = "t7")

showXRT  = input.bool(true, "Retail", group = themeGroup, inline = "t8")

showXLE  = input.bool(true, "Energy", group = themeGroup, inline = "t8")

showXLU  = input.bool(true, "Utilities", group = themeGroup, inline = "t9")

showGDX  = input.bool(true, "Gold Miners", group = themeGroup, inline = "t9")

showSIL  = input.bool(true, "Silver Miners", group = themeGroup, inline = "t10")

showWGMI = input.bool(true, "Bitcoin Miners", group = themeGroup, inline = "t10")

//----------------------------------------------------
// Saved Theme Presets
//----------------------------------------------------

// TradingView persists indicator inputs with the chart/layout.
// Configure each preset once, then switch baskets from List Mode.

preset1Group = "Saved Preset 1"
p1ThemeName = input.string("AI Infrastructure", "Theme Name", group = preset1Group)

p1c1On = input.bool(true, "1 On", group = preset1Group, inline = "p1c1")
p1c1Sym = input.symbol("NASDAQ:NVDA", "Symbol", group = preset1Group, inline = "p1c1")

p1c2On = input.bool(true, "2 On", group = preset1Group, inline = "p1c2")
p1c2Sym = input.symbol("NASDAQ:MU", "Symbol", group = preset1Group, inline = "p1c2")

p1c3On = input.bool(true, "3 On", group = preset1Group, inline = "p1c3")
p1c3Sym = input.symbol("NASDAQ:MRVL", "Symbol", group = preset1Group, inline = "p1c3")

p1c4On = input.bool(true, "4 On", group = preset1Group, inline = "p1c4")
p1c4Sym = input.symbol("NASDAQ:RMBS", "Symbol", group = preset1Group, inline = "p1c4")

p1c5On = input.bool(true, "5 On", group = preset1Group, inline = "p1c5")
p1c5Sym = input.symbol("NASDAQ:AMD", "Symbol", group = preset1Group, inline = "p1c5")

p1c6On = input.bool(true, "6 On", group = preset1Group, inline = "p1c6")
p1c6Sym = input.symbol("NASDAQ:AVGO", "Symbol", group = preset1Group, inline = "p1c6")

p1c7On = input.bool(true, "7 On", group = preset1Group, inline = "p1c7")
p1c7Sym = input.symbol("NYSE:ANET", "Symbol", group = preset1Group, inline = "p1c7")

p1c8On = input.bool(true, "8 On", group = preset1Group, inline = "p1c8")
p1c8Sym = input.symbol("NYSE:VRT", "Symbol", group = preset1Group, inline = "p1c8")

p1c9On = input.bool(true, "9 On", group = preset1Group, inline = "p1c9")
p1c9Sym = input.symbol("NYSE:DELL", "Symbol", group = preset1Group, inline = "p1c9")

p1c10On = input.bool(true, "10 On", group = preset1Group, inline = "p1c10")
p1c10Sym = input.symbol("NASDAQ:PLTR", "Symbol", group = preset1Group, inline = "p1c10")

p1c11On = input.bool(false, "11 On", group = preset1Group, inline = "p1c11")
p1c11Sym = input.symbol("NASDAQ:TSLA", "Symbol", group = preset1Group, inline = "p1c11")

p1c12On = input.bool(false, "12 On", group = preset1Group, inline = "p1c12")
p1c12Sym = input.symbol("NASDAQ:META", "Symbol", group = preset1Group, inline = "p1c12")

p1c13On = input.bool(false, "13 On", group = preset1Group, inline = "p1c13")
p1c13Sym = input.symbol("NASDAQ:MSFT", "Symbol", group = preset1Group, inline = "p1c13")

p1c14On = input.bool(false, "14 On", group = preset1Group, inline = "p1c14")
p1c14Sym = input.symbol("NASDAQ:GOOGL", "Symbol", group = preset1Group, inline = "p1c14")

p1c15On = input.bool(false, "15 On", group = preset1Group, inline = "p1c15")
p1c15Sym = input.symbol("NASDAQ:CRWD", "Symbol", group = preset1Group, inline = "p1c15")

preset2Group = "Saved Preset 2"
p2ThemeName = input.string("Hyperscalers", "Theme Name", group = preset2Group)

p2c1On = input.bool(true, "1 On", group = preset2Group, inline = "p2c1")
p2c1Sym = input.symbol("NASDAQ:MSFT", "Symbol", group = preset2Group, inline = "p2c1")

p2c2On = input.bool(true, "2 On", group = preset2Group, inline = "p2c2")
p2c2Sym = input.symbol("NASDAQ:AMZN", "Symbol", group = preset2Group, inline = "p2c2")

p2c3On = input.bool(true, "3 On", group = preset2Group, inline = "p2c3")
p2c3Sym = input.symbol("NASDAQ:GOOGL", "Symbol", group = preset2Group, inline = "p2c3")

p2c4On = input.bool(true, "4 On", group = preset2Group, inline = "p2c4")
p2c4Sym = input.symbol("NASDAQ:META", "Symbol", group = preset2Group, inline = "p2c4")

p2c5On = input.bool(true, "5 On", group = preset2Group, inline = "p2c5")
p2c5Sym = input.symbol("NYSE:ORCL", "Symbol", group = preset2Group, inline = "p2c5")

p2c6On = input.bool(false, "6 On", group = preset2Group, inline = "p2c6")
p2c6Sym = input.symbol("NASDAQ:NVDA", "Symbol", group = preset2Group, inline = "p2c6")

p2c7On = input.bool(false, "7 On", group = preset2Group, inline = "p2c7")
p2c7Sym = input.symbol("NASDAQ:AVGO", "Symbol", group = preset2Group, inline = "p2c7")

p2c8On = input.bool(false, "8 On", group = preset2Group, inline = "p2c8")
p2c8Sym = input.symbol("NASDAQ:AMD", "Symbol", group = preset2Group, inline = "p2c8")

p2c9On = input.bool(false, "9 On", group = preset2Group, inline = "p2c9")
p2c9Sym = input.symbol("NYSE:ANET", "Symbol", group = preset2Group, inline = "p2c9")

p2c10On = input.bool(false, "10 On", group = preset2Group, inline = "p2c10")
p2c10Sym = input.symbol("NYSE:VRT", "Symbol", group = preset2Group, inline = "p2c10")

p2c11On = input.bool(false, "11 On", group = preset2Group, inline = "p2c11")
p2c11Sym = input.symbol("NYSE:DELL", "Symbol", group = preset2Group, inline = "p2c11")

p2c12On = input.bool(false, "12 On", group = preset2Group, inline = "p2c12")
p2c12Sym = input.symbol("NASDAQ:PLTR", "Symbol", group = preset2Group, inline = "p2c12")

p2c13On = input.bool(false, "13 On", group = preset2Group, inline = "p2c13")
p2c13Sym = input.symbol("NASDAQ:CRWD", "Symbol", group = preset2Group, inline = "p2c13")

p2c14On = input.bool(false, "14 On", group = preset2Group, inline = "p2c14")
p2c14Sym = input.symbol("NASDAQ:TSLA", "Symbol", group = preset2Group, inline = "p2c14")

p2c15On = input.bool(false, "15 On", group = preset2Group, inline = "p2c15")
p2c15Sym = input.symbol("NASDAQ:MU", "Symbol", group = preset2Group, inline = "p2c15")

preset3Group = "Saved Preset 3"
p3ThemeName = input.string("Saved Theme 3", "Theme Name", group = preset3Group)

p3c1On = input.bool(false, "1 On", group = preset3Group, inline = "p3c1")
p3c1Sym = input.symbol("NASDAQ:NVDA", "Symbol", group = preset3Group, inline = "p3c1")

p3c2On = input.bool(false, "2 On", group = preset3Group, inline = "p3c2")
p3c2Sym = input.symbol("NASDAQ:MSFT", "Symbol", group = preset3Group, inline = "p3c2")

p3c3On = input.bool(false, "3 On", group = preset3Group, inline = "p3c3")
p3c3Sym = input.symbol("NASDAQ:AMZN", "Symbol", group = preset3Group, inline = "p3c3")

p3c4On = input.bool(false, "4 On", group = preset3Group, inline = "p3c4")
p3c4Sym = input.symbol("NASDAQ:GOOGL", "Symbol", group = preset3Group, inline = "p3c4")

p3c5On = input.bool(false, "5 On", group = preset3Group, inline = "p3c5")
p3c5Sym = input.symbol("NASDAQ:META", "Symbol", group = preset3Group, inline = "p3c5")

p3c6On = input.bool(false, "6 On", group = preset3Group, inline = "p3c6")
p3c6Sym = input.symbol("NASDAQ:AVGO", "Symbol", group = preset3Group, inline = "p3c6")

p3c7On = input.bool(false, "7 On", group = preset3Group, inline = "p3c7")
p3c7Sym = input.symbol("NASDAQ:AMD", "Symbol", group = preset3Group, inline = "p3c7")

p3c8On = input.bool(false, "8 On", group = preset3Group, inline = "p3c8")
p3c8Sym = input.symbol("NYSE:ANET", "Symbol", group = preset3Group, inline = "p3c8")

p3c9On = input.bool(false, "9 On", group = preset3Group, inline = "p3c9")
p3c9Sym = input.symbol("NYSE:VRT", "Symbol", group = preset3Group, inline = "p3c9")

p3c10On = input.bool(false, "10 On", group = preset3Group, inline = "p3c10")
p3c10Sym = input.symbol("NYSE:ORCL", "Symbol", group = preset3Group, inline = "p3c10")

p3c11On = input.bool(false, "11 On", group = preset3Group, inline = "p3c11")
p3c11Sym = input.symbol("NASDAQ:CRWD", "Symbol", group = preset3Group, inline = "p3c11")

p3c12On = input.bool(false, "12 On", group = preset3Group, inline = "p3c12")
p3c12Sym = input.symbol("NASDAQ:TSLA", "Symbol", group = preset3Group, inline = "p3c12")

p3c13On = input.bool(false, "13 On", group = preset3Group, inline = "p3c13")
p3c13Sym = input.symbol("NYSE:DELL", "Symbol", group = preset3Group, inline = "p3c13")

p3c14On = input.bool(false, "14 On", group = preset3Group, inline = "p3c14")
p3c14Sym = input.symbol("NASDAQ:MU", "Symbol", group = preset3Group, inline = "p3c14")

p3c15On = input.bool(false, "15 On", group = preset3Group, inline = "p3c15")
p3c15Sym = input.symbol("NASDAQ:PLTR", "Symbol", group = preset3Group, inline = "p3c15")

preset4Group = "Saved Preset 4"
p4ThemeName = input.string("Saved Theme 4", "Theme Name", group = preset4Group)

p4c1On = input.bool(false, "1 On", group = preset4Group, inline = "p4c1")
p4c1Sym = input.symbol("NASDAQ:NVDA", "Symbol", group = preset4Group, inline = "p4c1")

p4c2On = input.bool(false, "2 On", group = preset4Group, inline = "p4c2")
p4c2Sym = input.symbol("NASDAQ:MSFT", "Symbol", group = preset4Group, inline = "p4c2")

p4c3On = input.bool(false, "3 On", group = preset4Group, inline = "p4c3")
p4c3Sym = input.symbol("NASDAQ:AMZN", "Symbol", group = preset4Group, inline = "p4c3")

p4c4On = input.bool(false, "4 On", group = preset4Group, inline = "p4c4")
p4c4Sym = input.symbol("NASDAQ:GOOGL", "Symbol", group = preset4Group, inline = "p4c4")

p4c5On = input.bool(false, "5 On", group = preset4Group, inline = "p4c5")
p4c5Sym = input.symbol("NASDAQ:META", "Symbol", group = preset4Group, inline = "p4c5")

p4c6On = input.bool(false, "6 On", group = preset4Group, inline = "p4c6")
p4c6Sym = input.symbol("NASDAQ:AVGO", "Symbol", group = preset4Group, inline = "p4c6")

p4c7On = input.bool(false, "7 On", group = preset4Group, inline = "p4c7")
p4c7Sym = input.symbol("NASDAQ:AMD", "Symbol", group = preset4Group, inline = "p4c7")

p4c8On = input.bool(false, "8 On", group = preset4Group, inline = "p4c8")
p4c8Sym = input.symbol("NYSE:ANET", "Symbol", group = preset4Group, inline = "p4c8")

p4c9On = input.bool(false, "9 On", group = preset4Group, inline = "p4c9")
p4c9Sym = input.symbol("NYSE:VRT", "Symbol", group = preset4Group, inline = "p4c9")

p4c10On = input.bool(false, "10 On", group = preset4Group, inline = "p4c10")
p4c10Sym = input.symbol("NYSE:ORCL", "Symbol", group = preset4Group, inline = "p4c10")

p4c11On = input.bool(false, "11 On", group = preset4Group, inline = "p4c11")
p4c11Sym = input.symbol("NASDAQ:CRWD", "Symbol", group = preset4Group, inline = "p4c11")

p4c12On = input.bool(false, "12 On", group = preset4Group, inline = "p4c12")
p4c12Sym = input.symbol("NASDAQ:TSLA", "Symbol", group = preset4Group, inline = "p4c12")

p4c13On = input.bool(false, "13 On", group = preset4Group, inline = "p4c13")
p4c13Sym = input.symbol("NYSE:DELL", "Symbol", group = preset4Group, inline = "p4c13")

p4c14On = input.bool(false, "14 On", group = preset4Group, inline = "p4c14")
p4c14Sym = input.symbol("NASDAQ:MU", "Symbol", group = preset4Group, inline = "p4c14")

p4c15On = input.bool(false, "15 On", group = preset4Group, inline = "p4c15")
p4c15Sym = input.symbol("NASDAQ:PLTR", "Symbol", group = preset4Group, inline = "p4c15")

preset5Group = "Saved Preset 5"
p5ThemeName = input.string("Saved Theme 5", "Theme Name", group = preset5Group)

p5c1On = input.bool(false, "1 On", group = preset5Group, inline = "p5c1")
p5c1Sym = input.symbol("NASDAQ:NVDA", "Symbol", group = preset5Group, inline = "p5c1")

p5c2On = input.bool(false, "2 On", group = preset5Group, inline = "p5c2")
p5c2Sym = input.symbol("NASDAQ:MSFT", "Symbol", group = preset5Group, inline = "p5c2")

p5c3On = input.bool(false, "3 On", group = preset5Group, inline = "p5c3")
p5c3Sym = input.symbol("NASDAQ:AMZN", "Symbol", group = preset5Group, inline = "p5c3")

p5c4On = input.bool(false, "4 On", group = preset5Group, inline = "p5c4")
p5c4Sym = input.symbol("NASDAQ:GOOGL", "Symbol", group = preset5Group, inline = "p5c4")

p5c5On = input.bool(false, "5 On", group = preset5Group, inline = "p5c5")
p5c5Sym = input.symbol("NASDAQ:META", "Symbol", group = preset5Group, inline = "p5c5")

p5c6On = input.bool(false, "6 On", group = preset5Group, inline = "p5c6")
p5c6Sym = input.symbol("NASDAQ:AVGO", "Symbol", group = preset5Group, inline = "p5c6")

p5c7On = input.bool(false, "7 On", group = preset5Group, inline = "p5c7")
p5c7Sym = input.symbol("NASDAQ:AMD", "Symbol", group = preset5Group, inline = "p5c7")

p5c8On = input.bool(false, "8 On", group = preset5Group, inline = "p5c8")
p5c8Sym = input.symbol("NYSE:ANET", "Symbol", group = preset5Group, inline = "p5c8")

p5c9On = input.bool(false, "9 On", group = preset5Group, inline = "p5c9")
p5c9Sym = input.symbol("NYSE:VRT", "Symbol", group = preset5Group, inline = "p5c9")

p5c10On = input.bool(false, "10 On", group = preset5Group, inline = "p5c10")
p5c10Sym = input.symbol("NYSE:ORCL", "Symbol", group = preset5Group, inline = "p5c10")

p5c11On = input.bool(false, "11 On", group = preset5Group, inline = "p5c11")
p5c11Sym = input.symbol("NASDAQ:CRWD", "Symbol", group = preset5Group, inline = "p5c11")

p5c12On = input.bool(false, "12 On", group = preset5Group, inline = "p5c12")
p5c12Sym = input.symbol("NASDAQ:TSLA", "Symbol", group = preset5Group, inline = "p5c12")

p5c13On = input.bool(false, "13 On", group = preset5Group, inline = "p5c13")
p5c13Sym = input.symbol("NYSE:DELL", "Symbol", group = preset5Group, inline = "p5c13")

p5c14On = input.bool(false, "14 On", group = preset5Group, inline = "p5c14")
p5c14Sym = input.symbol("NASDAQ:MU", "Symbol", group = preset5Group, inline = "p5c14")

p5c15On = input.bool(false, "15 On", group = preset5Group, inline = "p5c15")
p5c15Sym = input.symbol("NASDAQ:PLTR", "Symbol", group = preset5Group, inline = "p5c15")


//----------------------------------------------------

// Time calculations

//----------------------------------------------------

newYear = timeframe.change("12M")

barsYear = ta.barssince(newYear)

lenY = f_len(barsYear)

//----------------------------------------------------

// Build Selected List

//----------------------------------------------------

dataArr = array.new<theme>()

if listMode == "Core Themes"

    if showSPY

        dataArr.push(theme.new("S&P 500", "AMEX:SPY", "SPY", false))

    if showQQQ

        dataArr.push(theme.new("Nasdaq 100", "NASDAQ:QQQ", "QQQ", false))

    if showSMH

        dataArr.push(theme.new("Semiconductors", "NASDAQ:SMH", "SMH", false))

    if showIGV

        dataArr.push(theme.new("Software", "BATS:IGV", "IGV", false))

    if showHACK

        dataArr.push(theme.new("Cybersecurity", "BATS:HACK", "HACK", false))

    if showSKYY

        dataArr.push(theme.new("Cloud Computing", "BATS:SKYY", "SKYY", false))

    if showBOTZ

        dataArr.push(theme.new("AI / Robotics", "BATS:BOTZ", "BOTZ", false))

    if showXBI

        dataArr.push(theme.new("Biotech", "BATS:XBI", "XBI", false))

    if showXLV

        dataArr.push(theme.new("Healthcare", "AMEX:XLV", "XLV", false))

    if showTLT

        dataArr.push(theme.new("Long Term Treasuries", "NASDAQ:TLT", "TLT", false))

if listMode == "Full Themes"

    if showSPY

        dataArr.push(theme.new("S&P 500", "AMEX:SPY", "SPY", false))

    if showQQQ

        dataArr.push(theme.new("Nasdaq 100", "NASDAQ:QQQ", "QQQ", false))

    if showSMH

        dataArr.push(theme.new("Semiconductors", "NASDAQ:SMH", "SMH", false))

    if showIGV

        dataArr.push(theme.new("Software", "BATS:IGV", "IGV", false))

    if showHACK

        dataArr.push(theme.new("Cybersecurity", "BATS:HACK", "HACK", false))

    if showSKYY

        dataArr.push(theme.new("Cloud Computing", "BATS:SKYY", "SKYY", false))

    if showBOTZ

        dataArr.push(theme.new("AI / Robotics", "BATS:BOTZ", "BOTZ", false))

    if showQTUM

        dataArr.push(theme.new("Quantum", "BATS:QTUM", "QTUM", false))

    if showXBI

        dataArr.push(theme.new("Biotech", "BATS:XBI", "XBI", false))

    if showARKG

        dataArr.push(theme.new("Genomics", "BATS:ARKG", "ARKG", false))

    if showXLV

        dataArr.push(theme.new("Healthcare", "AMEX:XLV", "XLV", false))

    if showXLI

        dataArr.push(theme.new("Industrials", "AMEX:XLI", "XLI", false))

    if showKRE

        dataArr.push(theme.new("Regional Banks", "AMEX:KRE", "KRE", false))

    if showXRT

        dataArr.push(theme.new("Retail", "AMEX:XRT", "XRT", false))

    if showXLE

        dataArr.push(theme.new("Energy", "AMEX:XLE", "XLE", false))

    if showXLU

        dataArr.push(theme.new("Utilities", "AMEX:XLU", "XLU", false))

    if showGDX

        dataArr.push(theme.new("Gold Miners", "AMEX:GDX", "GDX", false))

    if showSIL

        dataArr.push(theme.new("Silver Miners", "AMEX:SIL", "SIL", false))

    if showWGMI

        dataArr.push(theme.new("Bitcoin Miners", "BATS:WGMI", "WGMI", false))

    if showTLT

        dataArr.push(theme.new("Long Term Treasuries", "NASDAQ:TLT", "TLT", false))

if listMode == "Saved Preset 1"
    if p1c1On
        dataArr.push(theme.new("", p1c1Sym, "", true))
    if p1c2On
        dataArr.push(theme.new("", p1c2Sym, "", true))
    if p1c3On
        dataArr.push(theme.new("", p1c3Sym, "", true))
    if p1c4On
        dataArr.push(theme.new("", p1c4Sym, "", true))
    if p1c5On
        dataArr.push(theme.new("", p1c5Sym, "", true))
    if p1c6On
        dataArr.push(theme.new("", p1c6Sym, "", true))
    if p1c7On
        dataArr.push(theme.new("", p1c7Sym, "", true))
    if p1c8On
        dataArr.push(theme.new("", p1c8Sym, "", true))
    if p1c9On
        dataArr.push(theme.new("", p1c9Sym, "", true))
    if p1c10On
        dataArr.push(theme.new("", p1c10Sym, "", true))
    if p1c11On
        dataArr.push(theme.new("", p1c11Sym, "", true))
    if p1c12On
        dataArr.push(theme.new("", p1c12Sym, "", true))
    if p1c13On
        dataArr.push(theme.new("", p1c13Sym, "", true))
    if p1c14On
        dataArr.push(theme.new("", p1c14Sym, "", true))
    if p1c15On
        dataArr.push(theme.new("", p1c15Sym, "", true))

if listMode == "Saved Preset 2"
    if p2c1On
        dataArr.push(theme.new("", p2c1Sym, "", true))
    if p2c2On
        dataArr.push(theme.new("", p2c2Sym, "", true))
    if p2c3On
        dataArr.push(theme.new("", p2c3Sym, "", true))
    if p2c4On
        dataArr.push(theme.new("", p2c4Sym, "", true))
    if p2c5On
        dataArr.push(theme.new("", p2c5Sym, "", true))
    if p2c6On
        dataArr.push(theme.new("", p2c6Sym, "", true))
    if p2c7On
        dataArr.push(theme.new("", p2c7Sym, "", true))
    if p2c8On
        dataArr.push(theme.new("", p2c8Sym, "", true))
    if p2c9On
        dataArr.push(theme.new("", p2c9Sym, "", true))
    if p2c10On
        dataArr.push(theme.new("", p2c10Sym, "", true))
    if p2c11On
        dataArr.push(theme.new("", p2c11Sym, "", true))
    if p2c12On
        dataArr.push(theme.new("", p2c12Sym, "", true))
    if p2c13On
        dataArr.push(theme.new("", p2c13Sym, "", true))
    if p2c14On
        dataArr.push(theme.new("", p2c14Sym, "", true))
    if p2c15On
        dataArr.push(theme.new("", p2c15Sym, "", true))

if listMode == "Saved Preset 3"
    if p3c1On
        dataArr.push(theme.new("", p3c1Sym, "", true))
    if p3c2On
        dataArr.push(theme.new("", p3c2Sym, "", true))
    if p3c3On
        dataArr.push(theme.new("", p3c3Sym, "", true))
    if p3c4On
        dataArr.push(theme.new("", p3c4Sym, "", true))
    if p3c5On
        dataArr.push(theme.new("", p3c5Sym, "", true))
    if p3c6On
        dataArr.push(theme.new("", p3c6Sym, "", true))
    if p3c7On
        dataArr.push(theme.new("", p3c7Sym, "", true))
    if p3c8On
        dataArr.push(theme.new("", p3c8Sym, "", true))
    if p3c9On
        dataArr.push(theme.new("", p3c9Sym, "", true))
    if p3c10On
        dataArr.push(theme.new("", p3c10Sym, "", true))
    if p3c11On
        dataArr.push(theme.new("", p3c11Sym, "", true))
    if p3c12On
        dataArr.push(theme.new("", p3c12Sym, "", true))
    if p3c13On
        dataArr.push(theme.new("", p3c13Sym, "", true))
    if p3c14On
        dataArr.push(theme.new("", p3c14Sym, "", true))
    if p3c15On
        dataArr.push(theme.new("", p3c15Sym, "", true))

if listMode == "Saved Preset 4"
    if p4c1On
        dataArr.push(theme.new("", p4c1Sym, "", true))
    if p4c2On
        dataArr.push(theme.new("", p4c2Sym, "", true))
    if p4c3On
        dataArr.push(theme.new("", p4c3Sym, "", true))
    if p4c4On
        dataArr.push(theme.new("", p4c4Sym, "", true))
    if p4c5On
        dataArr.push(theme.new("", p4c5Sym, "", true))
    if p4c6On
        dataArr.push(theme.new("", p4c6Sym, "", true))
    if p4c7On
        dataArr.push(theme.new("", p4c7Sym, "", true))
    if p4c8On
        dataArr.push(theme.new("", p4c8Sym, "", true))
    if p4c9On
        dataArr.push(theme.new("", p4c9Sym, "", true))
    if p4c10On
        dataArr.push(theme.new("", p4c10Sym, "", true))
    if p4c11On
        dataArr.push(theme.new("", p4c11Sym, "", true))
    if p4c12On
        dataArr.push(theme.new("", p4c12Sym, "", true))
    if p4c13On
        dataArr.push(theme.new("", p4c13Sym, "", true))
    if p4c14On
        dataArr.push(theme.new("", p4c14Sym, "", true))
    if p4c15On
        dataArr.push(theme.new("", p4c15Sym, "", true))

if listMode == "Saved Preset 5"
    if p5c1On
        dataArr.push(theme.new("", p5c1Sym, "", true))
    if p5c2On
        dataArr.push(theme.new("", p5c2Sym, "", true))
    if p5c3On
        dataArr.push(theme.new("", p5c3Sym, "", true))
    if p5c4On
        dataArr.push(theme.new("", p5c4Sym, "", true))
    if p5c5On
        dataArr.push(theme.new("", p5c5Sym, "", true))
    if p5c6On
        dataArr.push(theme.new("", p5c6Sym, "", true))
    if p5c7On
        dataArr.push(theme.new("", p5c7Sym, "", true))
    if p5c8On
        dataArr.push(theme.new("", p5c8Sym, "", true))
    if p5c9On
        dataArr.push(theme.new("", p5c9Sym, "", true))
    if p5c10On
        dataArr.push(theme.new("", p5c10Sym, "", true))
    if p5c11On
        dataArr.push(theme.new("", p5c11Sym, "", true))
    if p5c12On
        dataArr.push(theme.new("", p5c12Sym, "", true))
    if p5c13On
        dataArr.push(theme.new("", p5c13Sym, "", true))
    if p5c14On
        dataArr.push(theme.new("", p5c14Sym, "", true))
    if p5c15On
        dataArr.push(theme.new("", p5c15Sym, "", true))

///----------------------------------------------------

// Active list display name
activeListName = listMode == "Saved Preset 1" ? p1ThemeName :
     listMode == "Saved Preset 2" ? p2ThemeName :
     listMode == "Saved Preset 3" ? p3ThemeName :
     listMode == "Saved Preset 4" ? p4ThemeName :
     listMode == "Saved Preset 5" ? p5ThemeName :
     listMode

// Table

//----------------------------------------------------

var table data = table.new(f_pos(yPos, xPos), 8, 32, tableBgColor, color.rgb(219, 221, 228), 1, color.rgb(219, 221, 228), 1)

//----------------------------------------------------

// Main

//----------------------------------------------------

if barstate.islast

    table.clear(data, 0, 0, 7, 31)

    dayArr = array.new<float>()

    weekArr = array.new<float>()

    monthArr = array.new<float>()

    m3Arr = array.new<float>()

    ytdArr = array.new<float>()

    scoreArr = array.new<float>()

    statusArr = array.new<string>()

    statusRankArr = array.new<float>()

    nameArr = array.new<string>()

    tickerArr = array.new<string>()

    constructiveCount = 0

    leadingCount = 0

    totalScore = 0.0

    if dataArr.size() > 0

        for t in dataArr

            [d1, w1, m1, m3, y1, reqName, reqTicker] = request.security(

                 t.sym,

                 "D",

                 [

                     ta.roc(close, 1),

                     ta.roc(close, 5),

                     ta.roc(close, 21),

                     ta.roc(close, 63),

                     ta.roc(close, lenY),

                     syminfo.description,

                     syminfo.ticker

                 ],

                 lookahead = barmerge.lookahead_off

            )

            // Score logic

            // Max score = 10

            score = 0.0

            score += d1 > 0 ? 1.0 : 0.0

            score += w1 > 0 ? 2.0 : 0.0

            score += m1 > 0 ? 2.0 : 0.0

            score += m3 > 0 ? 2.0 : 0.0

            score += y1 > 0 ? 1.0 : 0.0

            // Additional momentum participation bonus

            score += w1 > 5 ? 1.0 : 0.0

            score += m1 > 10 ? 1.0 : 0.0

            // Status logic

            status = w1 > 0 and m1 > 0 and m3 > 0 ? "Leading" :

                 d1 > 0 and w1 > 0 and m1 < 0 ? "Improving" :

                 d1 < 0 and w1 < 0 and m3 > 0 ? "Weakening" :

                 w1 < 0 and m1 < 0 ? "Lagging" :

                 "Mixed"

            statusRank = status == "Leading" ? 5.0 :

                 status == "Improving" ? 4.0 :

                 status == "Mixed" ? 3.0 :

                 status == "Weakening" ? 2.0 :

                 1.0

            isConstructive = status == "Leading" or status == "Improving"

            constructiveCount += isConstructive ? 1 : 0

            leadingCount += status == "Leading" ? 1 : 0

            totalScore += score

            dayArr.push(d1)

            weekArr.push(w1)

            monthArr.push(m1)

            m3Arr.push(m3)

            ytdArr.push(y1)

            scoreArr.push(score)

            statusArr.push(status)

            statusRankArr.push(statusRank)

            nameArr.push(t.autoMeta ? reqName : t.name)

            tickerArr.push(t.autoMeta ? reqTicker : t.ticker)

        enabledCount = dataArr.size()

        breadthPct = enabledCount > 0 ? constructiveCount / enabledCount * 100.0 : na

        avgScore = enabledCount > 0 ? totalScore / enabledCount : na

        themeRead = f_theme_read(breadthPct, avgScore)

        themeReadColor = f_theme_read_color(themeRead)

        //----------------------------------------------------

        // Dashboard summary header

        //----------------------------------------------------

        data.cell(0, 0, activeListName + " — Breadth & Leadership", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor, text_halign = text.align_left)

        data.cell(1, 0, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(2, 0, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(3, 0, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(4, 0, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(5, 0, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(6, 0, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(7, 0, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(0, 1, "Overall Theme Read", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor, text_halign = text.align_left)

        data.cell(1, 1, themeRead, text_color = themeReadColor, text_size = txtSize, bgcolor = tableBgColor, text_halign = text.align_left)

        data.cell(2, 1, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(3, 1, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(4, 1, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(5, 1, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(6, 1, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(7, 1, "", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(0, 2, "Constructive Symbols", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor, text_halign = text.align_left)

        data.cell(1, 2, str.tostring(constructiveCount) + " / " + str.tostring(enabledCount), text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(2, 2, "Breadth", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(3, 2, str.tostring(breadthPct, "#.0") + "%", text_color = breadthPct >= 70 ? color.rgb(0, 146, 5) : breadthPct >= 40 ? color.rgb(255, 170, 0) : color.rgb(250, 27, 27), text_size = txtSize, bgcolor = tableBgColor)

        data.cell(4, 2, "Leaders", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(5, 2, str.tostring(leadingCount), text_color = color.rgb(0, 146, 5), text_size = txtSize, bgcolor = tableBgColor)

        data.cell(6, 2, "Avg Score", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(7, 2, str.tostring(avgScore, "#.0"), text_color = avgScore >= 6.5 ? color.rgb(0, 146, 5) : avgScore >= 4.0 ? color.rgb(255, 170, 0) : color.rgb(250, 27, 27), text_size = txtSize, bgcolor = tableBgColor)

        //----------------------------------------------------

        // Column headers

        //----------------------------------------------------

        headerRow = 4

        data.cell(0, headerRow, "Theme / Symbol", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(1, headerRow, "1D", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(2, headerRow, "1W", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(3, headerRow, "1M", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(4, headerRow, "3M", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(5, headerRow, "YTD", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(6, headerRow, "Score", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(7, headerRow, "Status", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        sortArr = sortBy == "1 Day" ? dayArr :

             sortBy == "1 Week" ? weekArr :

             sortBy == "1 Month" ? monthArr :

             sortBy == "3 Months" ? m3Arr :

             sortBy == "YTD" ? ytdArr :

             sortBy == "Status" ? statusRankArr :

             scoreArr

        sorted = array.sort_indices(sortArr, order.descending)

        useTextColour = colBy == "Text"

        //----------------------------------------------------

        // Symbol rows

        //----------------------------------------------------

        for i = 0 to dataArr.size() - 1

            si = sorted.get(i)

            row = i + 5

            d = dayArr.get(si)

            w = weekArr.get(si)

            m = monthArr.get(si)

            q = m3Arr.get(si)

            y = ytdArr.get(si)

            sc = scoreArr.get(si)

            st = statusArr.get(si)

            statusColour = f_status_color(st)

            data.cell(

                 0,

                 row,

                 nameArr.get(si) + " (" + tickerArr.get(si) + ")",

                 bgcolor = tableBgColor,

                 text_color = tableTextColor,

                 text_size = txtSize,

                 text_halign = text.align_left

            )

            dColor = f_color(d, 7, 3, 0, -20, -10)

            wColor = f_color(w, 15, 10, 0, -15, -10)

            mColor = f_color(m, 15, 10, 0, -15, -10)

            qColor = f_color(q, 15, 10, 0, -15, -10)

            yColor = f_color(y, 15, 10, 0, -15, -10)

            data.cell(1, row, str.tostring(d, format.percent), text_color = useTextColour ? dColor : tableTextColor, bgcolor = useTextColour ? tableBgColor : dColor, text_size = txtSize)

            data.cell(2, row, str.tostring(w, format.percent), text_color = useTextColour ? wColor : tableTextColor, bgcolor = useTextColour ? tableBgColor : wColor, text_size = txtSize)

            data.cell(3, row, str.tostring(m, format.percent), text_color = useTextColour ? mColor : tableTextColor, bgcolor = useTextColour ? tableBgColor : mColor, text_size = txtSize)

            data.cell(4, row, str.tostring(q, format.percent), text_color = useTextColour ? qColor : tableTextColor, bgcolor = useTextColour ? tableBgColor : qColor, text_size = txtSize)

            data.cell(5, row, str.tostring(y, format.percent), text_color = useTextColour ? yColor : tableTextColor, bgcolor = useTextColour ? tableBgColor : yColor, text_size = txtSize)

            data.cell(

                 6,

                 row,

                 str.tostring(sc, "#.0"),

                 bgcolor = tableBgColor,

                 text_color = sc >= 8 ? color.rgb(0, 146, 5) : sc >= 5 ? color.rgb(50, 180, 54) : sc >= 3 ? color.gray : color.rgb(250, 27, 27),

                 text_size = txtSize

            )

            data.cell(

                 7,

                 row,

                 st,

                 bgcolor = tableBgColor,

                 text_color = statusColour,

                 text_size = txtSize

            )

    else

        data.cell(0, 0, activeListName + " — Breadth & Leadership", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)

        data.cell(0, 1, "No symbols enabled", text_color = tableTextColor, text_size = txtSize, bgcolor = tableBgColor)
````

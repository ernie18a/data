# Crypto ETF Flow Tracker [QuantAlgo]

- url: https://www.tradingview.com/script/8w3JMyCz-Crypto-ETF-Flow-Tracker-QuantAlgo/
- type: indicator
- pine_id: PUB;b81f1cc4802e42c3b265e095c87e0639
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Crypto ETF Flow Tracker[/b] is a data tool for traders who watch where institutional money is moving in crypto. It reads the daily fund flow reported for the US spot crypto ETFs across five assets, gathers the funds of each asset into one table, and draws the same figures below as a histogram with a cumulative line. Bitcoin, Ethereum, Solana, XRP, and Hyperliquid funds are covered, with up to five assets on screen at once and every fund individually includable, so a view can run from the full asset group down to a single issuer's product. Whether you follow the daily print, the trend of cumulative flow, or how one fund is faring against its peers, the indicator turns a scattered set of issuer reports into one dated view on any chart.
[image]https://www.tradingview.com/x/BfdRVRIF/[/image]
[b]🟢 How It Works[/b]

Each trading day, every included fund reports its net creation and redemption value through TradingView's ETF fund flow data, and the indicator builds that day's row from those reports: the funds of the asset across the columns, a Total column with the group's net flow for the day, and a Cumulative column with the net flow of every day up to and including it. Below the daily rows, summary rows give the total on record, the average per reporting day, the largest single-day net inflow, and the largest single-day net outflow, for each fund and for the group as a whole.

Flow figures are published by TradingView's data provider during the US session that follows the one they cover, one fund at a time, and the indicator picks each one up as it lands. The newest row fills in through the day, a fund still to report shows a dash, the date wears an asterisk until the row is complete, and hovering the date shows how many funds are in. The chart draws from the same rows, placing each day's total on its own date as a bar, a line, or an area, with the cumulative line running across the loaded history, so the pane and the table tell the same story.
[image]https://www.tradingview.com/x/Jjp53Ot7/[/image]
[b]🟢 Key Features[/b]

[b]▶ BTC ETFs[/b]

The indicator tracks the US spot Bitcoin funds, including [symbol="NASDAQ:IBIT"]NASDAQ:IBIT[/symbol], [symbol="CBOE:FBTC"]CBOE:FBTC[/symbol], [symbol="AMEX:BITB"]AMEX:BITB[/symbol], [symbol="CBOE:ARKB"]CBOE:ARKB[/symbol], [symbol="CBOE:BTCO"]CBOE:BTCO[/symbol], [symbol="CBOE:EZBC"]CBOE:EZBC[/symbol], [symbol="NASDAQ:BRRR"]NASDAQ:BRRR[/symbol], [symbol="CBOE:HODL"]CBOE:HODL[/symbol], [symbol="CBOE:BTCW"]CBOE:BTCW[/symbol], [symbol="AMEX:MSBT"]AMEX:MSBT[/symbol], [symbol="AMEX:GBTC"]AMEX:GBTC[/symbol], [symbol="AMEX:BTC"]AMEX:BTC[/symbol] . Every fund is included by default, and new listings will be added in future updates when they are available. This is the deepest group, with the Grayscale trust's outflows and the newer issuers' inflows visible side by side, and the group's cumulative figure reads as the net dollar demand the spot ETF market has brought to Bitcoin since launch.
[image]https://www.tradingview.com/x/9RKN7mhx/[/image]
[b]▶ ETH ETFs[/b]

Coverage extends to the US spot Ethereum funds, including [symbol="NASDAQ:ETHA"]NASDAQ:ETHA[/symbol], [symbol="NASDAQ:ETHB"]NASDAQ:ETHB[/symbol], [symbol="CBOE:FETH"]CBOE:FETH[/symbol], [symbol="AMEX:ETHW"]AMEX:ETHW[/symbol], [symbol="CBOE:TETH"]CBOE:TETH[/symbol], [symbol="CBOE:ETHV"]CBOE:ETHV[/symbol], [symbol="CBOE:QETH"]CBOE:QETH[/symbol], [symbol="CBOE:EZET"]CBOE:EZET[/symbol], [symbol="AMEX:MSSE"]AMEX:MSSE[/symbol], [symbol="AMEX:ETHE"]AMEX:ETHE[/symbol], [symbol="AMEX:ETH"]AMEX:ETH[/symbol] . All of them are switched on from the start, and future launches join the list as they arrive. The columns keep the converted trusts and the funds launched since visible next to each other, while the Total column gives the net Ethereum ETF flow for each session.
[image]https://www.tradingview.com/x/JZCsjAZN/[/image]
[b]▶ SOL ETFs[/b]

The tracker follows the US spot Solana funds, including [symbol="AMEX:BSOL"]AMEX:BSOL[/symbol], [symbol="NASDAQ:VSOL"]NASDAQ:VSOL[/symbol], [symbol="AMEX:FSOL"]AMEX:FSOL[/symbol], [symbol="CBOE:TSOL"]CBOE:TSOL[/symbol], [symbol="AMEX:SOEZ"]AMEX:SOEZ[/symbol], [symbol="AMEX:MSOL"]AMEX:MSOL[/symbol], [symbol="AMEX:GSOL"]AMEX:GSOL[/symbol] . Each is enabled out of the box, and any new Solana fund will be added in a later update once it is listed. Because these funds are recent, the feed records the launch seed of some of them as a flow on the day before trading began; a Seed Capital setting keeps the feed exactly as published or removes those opening records so the history reflects investor demand alone.
[image]https://www.tradingview.com/x/CJcwQjZ1/[/image]
[b]▶ XRP ETFs[/b]

On the XRP side the indicator covers [symbol="NASDAQ:XRPC"]NASDAQ:XRPC[/symbol], [symbol="AMEX:XRPZ"]AMEX:XRPZ[/symbol], [symbol="AMEX:XRP"]AMEX:XRP[/symbol], [symbol="AMEX:GXRP"]AMEX:GXRP[/symbol], [symbol="CBOE:TOXR"]CBOE:TOXR[/symbol] . The full set is active by default, with future listings added when they become available. The group is small enough that one fund's day can move the total, which the per-fund columns make easy to spot.
[image]https://www.tradingview.com/x/NLovdRIL/[/image]
[b]▶ HYPE ETFs
[/b]
The Hyperliquid group covers [symbol="AMEX:BHYP"]AMEX:BHYP[/symbol], [symbol="NASDAQ:THYP"]NASDAQ:THYP[/symbol], [symbol="NASDAQ:HYPG"]NASDAQ:HYPG[/symbol] . All three are included from the outset, and newcomers will be added in a future update once they trade. As the youngest group, its table begins on the first session with a reported flow, and its cumulative line starts from that day.
[image]https://www.tradingview.com/x/jRV4ba7k/[/image]
[b]▶ Flow Tables[/b]

Five slots decide which assets are on screen and where their tables sit, drawn over the price chart or inside the indicator pane. Each table lists the most recent sessions, up to thirty, oldest at the top and latest at the bottom, with the latest row highlighted. Figures are abbreviated with K, M, and B, signed, and shown to a chosen number of decimal places, in the inflow color for positive values and the outflow color for negative ones, with zero and missing values in neutral. The title and the Cumulative header carry the asset's color, tying a table to its line on the chart at a glance. Average divides each fund's total by the days it has reported since its first non-zero flow, so a fund launched last month is not diluted by the days before it existed.
[image]https://www.tradingview.com/x/5dANungp/[/image]
[b]▶ Flow Chart[/b]

Every active slot draws its daily net flow in the pane: as a histogram nested by width so several assets share the space, as a thin line in the asset's color, or as an area filled with the inflow color above zero and the outflow color below. The cumulative line runs in the same asset color and ends in a label that pairs the latest net flow with the cumulative figure, for example "BTC Net +456.8M | Cum +56.8B", with an asterisk (*) on the net figure while funds are still reporting. Because cumulative flow runs into the tens of billions while daily flows sit in the hundreds of millions, the line is fitted into the histogram's range by default with its true value in the label, and can be drawn at its actual value instead. Chart Mode selects the histogram with the cumulative line, either on its own, or Fund Comparison.
[image]https://www.tradingview.com/x/V64QJh3u/[/image]
[b]▶ Fund Comparison[/b]

Fund Comparison replaces the asset view with one line per included fund, each tracing that fund's cumulative flow at its actual value and ending in a label with the fund's name and figure, so the issuers of an asset can be measured against each other over time. The asset's own cumulative line can be added or left off, keeping the scale on the funds themselves.
[image]https://www.tradingview.com/x/1hl5Wphk/[/image]
[b]▶ Built-in Alerts[/b]

Ready-made alert conditions fire when the feed delivers a net inflow day or a net outflow day for a tracked asset, when a day clears the large flow threshold in either direction, when an asset flips between net inflow and net outflow versus the prior session, and whenever new flow data is published. The Any alert() function call option carries the asset name, the session date, the figure, and how many funds had reported in its message.
[image]https://www.tradingview.com/x/hHIuQ5kL/[/image]
[b]▶ Color Presets[/b]

Six presets (Classic, Aqua, Cosmic, Cyber, Neon, Custom) drive the inflow, outflow, and neutral colors used by every table cell and histogram bar, with one palette applied across all assets at once. The assets themselves keep their own colors, BTC orange, ETH blue, SOL purple, XRP gray, and HYPE mint, carried by each table title, cumulative line, and label, so an asset stays recognizable in whichever slot it is placed.
[image]https://www.tradingview.com/x/tR6vnAbV/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator("Crypto ETF Flow Tracker [QuantAlgo]", overlay = false, format = format.volume, precision = 1, max_polylines_count = 80, max_labels_count = 60, dynamic_requests = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string general_settings = "════════ General Settings ════════"
var string btc_settings     = "════════ BTC ETFs ════════"
var string eth_settings     = "════════ ETH ETFs ════════"
var string sol_settings     = "════════ SOL ETFs ════════"
var string xrp_settings     = "════════ XRP ETFs ════════"
var string hype_settings    = "════════ HYPE ETFs ════════"
var string table_settings   = "════════ Table Settings ════════"
var string chart_settings   = "════════ Chart Settings ════════"
var string alert_settings   = "════════ Alert Settings ════════"
var string visual_settings  = "════════ Visualization Settings ════════"

tooltip_slot1        = "Asset shown in the first slot. Every active slot draws its own flow table and its own histogram and cumulative line, so all five assets can be read side by side. Off hides the slot. Flows come from TradingView's daily ETF fund flow field, the same figure shown as Fund Flows on each ETF's symbol page, and are recorded against the trading day the flow belongs to. The feed publishes a session's figures during the following US session, fund by fund, so the latest row fills in over that day, shows a dash for any fund not yet reported, and carries an asterisk on its date until every fund is in. Trackers that read issuer websites directly post a session's figures the same evening, so their newest row normally sits one trading day ahead of this feed. Figures published after the chart was opened appear on the next reload, since TradingView does not stream fundamental data. Designed for the daily timeframe. Intraday charts work but place each day's bar at the first bar of that trading day, and weekly or monthly charts are not supported because the feed is daily."
tooltip_slot_other   = "Asset shown in this slot. Selecting an asset already used by an earlier slot is treated as Off."
tooltip_show_tables  = "Enable/disable the daily flow tables, drawn over the price chart or inside this pane depending on Table Location. Each table lists the selected ETFs of its asset as columns and the most recent trading days as rows, followed by a Total column for the asset's net flow that day and a Cumulative column for the net flow of every day up to and including that day. The cumulative runs from the first day loaded on the chart, which matches the since-inception figure once the chart history reaches back past the asset's first ETF launch."
tooltip_show_chart   = "Enable/disable the flow chart. Each active slot draws its daily net flow as a histogram, dated to the trading day the flow belongs to, and a cumulative line in that asset's color running across the loaded history. Slots are nested by bar width, Slot 1 widest and Slot 5 narrowest, so several assets can share the pane."
tooltip_seed         = "Seed capital is the money a sponsor places in a fund before its first day of trading, which flow trackers list separately from daily flows because it is not investor demand. The feed reports some launch seeds as a flow dated to the day before trading began. Include keeps the feed exactly as published, and Exclude removes those records where a fund's opening entry matches its published seed."
tooltip_decimals     = "Number of decimal places shown after every figure in the tables, labels, and alert messages, from 0 to 3. Figures are abbreviated with K, M, and B for thousands, millions, and billions, so a flow of 1,234,567 dollars shows as +1.2M at one decimal place and +1.235M at three."
tooltip_etf          = "Check the ETFs to include. An unchecked ETF is removed from the table, the Total and Cumulative columns, the chart, and the alerts for that asset, so the view can be narrowed down to a single fund. Every fund is included by default, and new listings are added as they become available."
tooltip_location     = "Price Chart draws the tables over the main price pane, leaving this pane to the histogram and cumulative lines so the two never cover each other. Indicator Pane keeps the tables inside this pane above the chart. The position settings below apply to whichever pane is chosen."
tooltip_days         = "Most recent trading days listed in each table, oldest at the top and latest at the bottom. The summary rows are not affected by this setting and always cover every day loaded on the chart."
tooltip_stats        = "Enable/disable the Total, Average, Max Inflow, and Max Outflow rows beneath the daily rows. Total is the sum of every day loaded on the chart. Average divides each fund's total by the number of days it has reported since its first non-zero flow, so a fund launched last month is not diluted by the days before it existed. Max Inflow is the largest single-day net inflow on record and Max Outflow the largest single-day net outflow, each shown as a dash when that fund or asset has never had one. The Total label shows the first date included on hover."
tooltip_position     = "Corner or edge of the pane where this slot's table is anchored. Tables placed at the same position overlap."
tooltip_size         = "Text size for every table. Tiny and Small fit more columns across the pane, while Normal and Large suit presentation and screen recording."
tooltip_chart_mode   = "Histogram + Cumulative draws each active slot's daily net flow as bars with its cumulative line. Histogram Only and Cumulative Only give each its own price scale, for example by adding the indicator twice with a different mode in each pane. Fund Comparison draws one line per included fund showing that fund's cumulative flow at its actual value, each ending in a label with the fund's name and figure, so the funds of an asset can be compared against each other."
tooltip_compare_cum  = "Enable/disable the asset's own cumulative line inside Fund Comparison. Off leaves only the fund lines, which keeps the scale on the funds themselves. On adds the asset total, drawn at its actual value in the asset's color."
tooltip_cum_scale    = "Cumulative flow runs into the tens of billions while daily flows sit in the hundreds of millions, so on one shared scale the histogram would flatten to nothing. Fit To Histogram rescales the cumulative line into the histogram range and prints its true value in a label at its end. Actual Values draws the line at its true level and expands the scale to fit it."
tooltip_labels       = "Enable/disable the value labels at the right edge of the chart. Each asset carries one label: at the end of its cumulative line it shows the latest daily net flow and the cumulative net flow together, and in Histogram Only it sits on the last bar with the daily flow alone. An asterisk after the daily flow means not every fund has reported that session yet. Fund Comparison adds one label per fund line. Each label is filled with the color of the line or asset it belongs to."
tooltip_flow_style   = "How each active slot's daily net flow is drawn. Histogram uses bars in the inflow and outflow colors, nested by width when several slots share the pane. Line joins the daily totals with a thin line in the asset's color. Area fills the space between the daily totals and the zero line, inflow color above the line and outflow color below it."
tooltip_hist_trans   = "Transparency of the histogram bars and area fills. Lower values (0-20) produce solid shapes, with bars separated by a thin outline in the chart background color. Higher values (50-80) let the flows of several slots show through each other when they overlap."
tooltip_large_flow   = "Net flow size, in millions of US dollars, that a single trading day must reach for the Large Inflow Day and Large Outflow Day alerts to fire. 500 suits the BTC funds, whose big days run past a billion, while 50 to 100 suits the smaller asset groups. Every alert fires on the bar where the feed delivers a new trading day for an active slot, using the figures published at that moment, so the total can still be partial while the remaining funds report. With the Once Per Bar frequency an alert fires the moment the data lands, while Once Per Bar Close waits for the daily close. Flow Data Published fires on every new row. The Any alert() function call option carries the asset name, date, figure, and how many funds had reported in its message."
tooltip_color_preset = "Pre-configured color schemes for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean-inspired blue and orange. Cosmic offers futuristic cyan and purple. Cyber features cool cyan and warm orange contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Custom uses the Inflow, Outflow, and Neutral colors set below, while all other presets use gray for the neutral state. The same palette applies to every slot."
tooltip_inflow       = "Color applied to positive figures in the tables and to inflow bars in the histogram, for every slot at once. Only used when Color Preset is set to Custom."
tooltip_outflow      = "Color applied to negative figures in the tables and to outflow bars in the histogram, for every slot at once. Only used when Color Preset is set to Custom."
tooltip_neutral      = "Color applied to zero figures, to missing values shown as a dash, and to the date column and column headers. Gray is recommended as a neutral cue. Only used when Color Preset is set to Custom."
tooltip_asset_color  = "Color that follows this asset wherever it is placed: the title of its table, its cumulative line, and the label at the end of that line. Slot order does not matter, so BTC stays orange whether it sits in Slot 1 or Slot 4. Inflow and outflow figures keep the palette colors above."

slot1Asset  = input.string("BTC", "Slot 1 Asset", group = general_settings, options = ["BTC", "ETH", "SOL", "XRP", "HYPE", "Off"], tooltip = tooltip_slot1, display = display.none)
slot2Asset  = input.string("ETH", "Slot 2 Asset", group = general_settings, options = ["BTC", "ETH", "SOL", "XRP", "HYPE", "Off"], tooltip = tooltip_slot_other, display = display.none)
slot3Asset  = input.string("Off", "Slot 3 Asset", group = general_settings, options = ["BTC", "ETH", "SOL", "XRP", "HYPE", "Off"], tooltip = tooltip_slot_other, display = display.none)
slot4Asset  = input.string("Off", "Slot 4 Asset", group = general_settings, options = ["BTC", "ETH", "SOL", "XRP", "HYPE", "Off"], tooltip = tooltip_slot_other, display = display.none)
slot5Asset  = input.string("Off", "Slot 5 Asset", group = general_settings, options = ["BTC", "ETH", "SOL", "XRP", "HYPE", "Off"], tooltip = tooltip_slot_other, display = display.none)
showTables  = input.bool(true, "Show Flow Tables", group = general_settings, tooltip = tooltip_show_tables, display = display.none)
showChart   = input.bool(true, "Show Flow Chart", group = general_settings, tooltip = tooltip_show_chart, display = display.none)
decimalsIn  = input.int(1, "Decimal Places", group = general_settings, minval = 0, maxval = 3, tooltip = tooltip_decimals, display = display.none)
seedMode    = input.string("Include", "Seed Capital", group = general_settings, options = ["Include", "Exclude"], tooltip = tooltip_seed, display = display.none)

useIBIT = input.bool(true, "IBIT", group = btc_settings, inline = "btc1", display = display.none)
useFBTC = input.bool(true, "FBTC", group = btc_settings, inline = "btc1", display = display.none)
useBITB = input.bool(true, "BITB", group = btc_settings, inline = "btc1", display = display.none)
useARKB = input.bool(true, "ARKB", group = btc_settings, inline = "btc1", tooltip = tooltip_etf, display = display.none)
useBTCO = input.bool(true, "BTCO", group = btc_settings, inline = "btc2", display = display.none)
useEZBC = input.bool(true, "EZBC", group = btc_settings, inline = "btc2", display = display.none)
useBRRR = input.bool(true, "BRRR", group = btc_settings, inline = "btc2", display = display.none)
useHODL = input.bool(true, "HODL", group = btc_settings, inline = "btc2", display = display.none)
useBTCW = input.bool(true, "BTCW", group = btc_settings, inline = "btc3", display = display.none)
useMSBT = input.bool(true, "MSBT", group = btc_settings, inline = "btc3", display = display.none)
useGBTC = input.bool(true, "GBTC", group = btc_settings, inline = "btc3", display = display.none)
useBTC  = input.bool(true, "BTC",  group = btc_settings, inline = "btc3", display = display.none)

useETHA = input.bool(true, "ETHA", group = eth_settings, inline = "eth1", display = display.none)
useETHB = input.bool(true, "ETHB", group = eth_settings, inline = "eth1", display = display.none)
useFETH = input.bool(true, "FETH", group = eth_settings, inline = "eth1", display = display.none)
useETHW = input.bool(true, "ETHW", group = eth_settings, inline = "eth1", tooltip = tooltip_etf, display = display.none)
useTETH = input.bool(true, "TETH", group = eth_settings, inline = "eth2", display = display.none)
useETHV = input.bool(true, "ETHV", group = eth_settings, inline = "eth2", display = display.none)
useQETH = input.bool(true, "QETH", group = eth_settings, inline = "eth2", display = display.none)
useEZET = input.bool(true, "EZET", group = eth_settings, inline = "eth2", display = display.none)
useMSSE = input.bool(true, "MSSE", group = eth_settings, inline = "eth3", display = display.none)
useETHE = input.bool(true, "ETHE", group = eth_settings, inline = "eth3", display = display.none)
useETH  = input.bool(true, "ETH",  group = eth_settings, inline = "eth3", display = display.none)

useBSOL = input.bool(true, "BSOL", group = sol_settings, inline = "sol1", display = display.none)
useVSOL = input.bool(true, "VSOL", group = sol_settings, inline = "sol1", display = display.none)
useFSOL = input.bool(true, "FSOL", group = sol_settings, inline = "sol1", display = display.none)
useTSOL = input.bool(true, "TSOL", group = sol_settings, inline = "sol1", tooltip = tooltip_etf, display = display.none)
useSOEZ = input.bool(true, "SOEZ", group = sol_settings, inline = "sol2", display = display.none)
useMSOL = input.bool(true, "MSOL", group = sol_settings, inline = "sol2", display = display.none)
useGSOL = input.bool(true, "GSOL", group = sol_settings, inline = "sol2", display = display.none)

useXRPC = input.bool(true, "XRPC", group = xrp_settings, inline = "xrp1", display = display.none)
useXRPZ = input.bool(true, "XRPZ", group = xrp_settings, inline = "xrp1", display = display.none)
useXRP  = input.bool(true, "XRP",  group = xrp_settings, inline = "xrp1", display = display.none)
useGXRP = input.bool(true, "GXRP", group = xrp_settings, inline = "xrp1", tooltip = tooltip_etf, display = display.none)
useTOXR = input.bool(true, "TOXR", group = xrp_settings, inline = "xrp2", display = display.none)

useBHYP = input.bool(true, "BHYP", group = hype_settings, inline = "hype1", display = display.none)
useTHYP = input.bool(true, "THYP", group = hype_settings, inline = "hype1", display = display.none)
useHYPG = input.bool(true, "HYPG", group = hype_settings, inline = "hype1", tooltip = tooltip_etf, display = display.none)

tableWhere  = input.string("Price Chart", "Table Location", group = table_settings, options = ["Price Chart", "Indicator Pane"], tooltip = tooltip_location, display = display.none)
tableDays   = input.int(15, "Days Shown", group = table_settings, minval = 1, maxval = 30, tooltip = tooltip_days, display = display.none)
showStats   = input.bool(true, "Show Summary Rows", group = table_settings, tooltip = tooltip_stats, display = display.none)
slot1Pos    = input.string("Top Left", "Slot 1 Table Position", group = table_settings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = tooltip_position, display = display.none)
slot2Pos    = input.string("Top Right", "Slot 2 Table Position", group = table_settings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = tooltip_position, display = display.none)
slot3Pos    = input.string("Bottom Left", "Slot 3 Table Position", group = table_settings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = tooltip_position, display = display.none)
slot4Pos    = input.string("Bottom Center", "Slot 4 Table Position", group = table_settings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = tooltip_position, display = display.none)
slot5Pos    = input.string("Bottom Right", "Slot 5 Table Position", group = table_settings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = tooltip_position, display = display.none)
tableSizeIn = input.string("Small", "Table Text Size", group = table_settings, options = ["Tiny", "Small", "Normal", "Large"], tooltip = tooltip_size, display = display.none)

flowStyle    = input.string("Histogram", "Flow Style", group = chart_settings, options = ["Histogram", "Line", "Area"], tooltip = tooltip_flow_style, display = display.none)
chartMode    = input.string("Histogram + Cumulative", "Chart Mode", group = chart_settings, options = ["Histogram + Cumulative", "Histogram Only", "Cumulative Only", "Fund Comparison"], tooltip = tooltip_chart_mode, display = display.none)
compareCum   = input.bool(true, "Cumulative Line In Comparison", group = chart_settings, tooltip = tooltip_compare_cum, display = display.none)
cumScaleIn   = input.string("Fit To Histogram", "Cumulative Line Scale", group = chart_settings, options = ["Fit To Histogram", "Actual Values"], tooltip = tooltip_cum_scale, display = display.none)
showLabels   = input.bool(true, "Show Value Labels", group = chart_settings, tooltip = tooltip_labels, display = display.none)
histTrans    = input.int(0, "Flow Transparency", group = chart_settings, minval = 0, maxval = 100, tooltip = tooltip_hist_trans, display = display.none)

largeFlowIn  = input.float(500.0, "Large Flow Threshold (US$m)", group = alert_settings, minval = 0.0, step = 50.0, tooltip = tooltip_large_flow, display = display.none)

colorPreset   = input.string("Custom", "Color Preset", group = visual_settings, options = ["Custom", "Classic", "Aqua", "Cosmic", "Cyber", "Neon"], tooltip = tooltip_color_preset, display = display.none)
inflowCustom  = input.color(#00ffaa, "Inflow Color", group = visual_settings, tooltip = tooltip_inflow, display = display.none)
outflowCustom = input.color(#ff0000, "Outflow Color", group = visual_settings, tooltip = tooltip_outflow, display = display.none)
neutralCustom = input.color(#808080, "Neutral Color", group = visual_settings, tooltip = tooltip_neutral, display = display.none)
btcColor      = input.color(#f7931a, "BTC Color", group = visual_settings, tooltip = tooltip_asset_color, display = display.none)
ethColor      = input.color(#627eea, "ETH Color", group = visual_settings, tooltip = tooltip_asset_color, display = display.none)
solColor      = input.color(#9945ff, "SOL Color", group = visual_settings, tooltip = tooltip_asset_color, display = display.none)
xrpColor      = input.color(#808080, "XRP Color", group = visual_settings, tooltip = tooltip_asset_color, display = display.none)
hypeColor     = input.color(#49ffce, "HYPE Color", group = visual_settings, tooltip = tooltip_asset_color, display = display.none)

//              ╔════════════════════════════════╗              //
//              ║      PRESET CONFIGURATION      ║              //
//              ╚════════════════════════════════╝              //

[inflowCol, outflowCol, neutralCol] = switch colorPreset
    "Classic" => [#00ff00, #ff0000, #808080]
    "Aqua" => [#00d4ff, #ff8c00, #808080]
    "Cosmic" => [#49ffce, #9932cc, #808080]
    "Cyber" => [#00cccc, #ff6600, #808080]
    "Neon" => [#ffff00, #ff00ff, #808080]
    => [inflowCustom, outflowCustom, neutralCustom]

string tableTextSize = switch tableSizeIn
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    => size.small

string decFmt = switch decimalsIn
    0 => "#,##0"
    2 => "#,##0.00"
    3 => "#,##0.000"
    => "#,##0.0"

positionOf(string p) =>
    switch p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

assetColor(string asset) =>
    switch asset
        "BTC" => btcColor
        "ETH" => ethColor
        "SOL" => solColor
        "XRP" => xrpColor
        "HYPE" => hypeColor
        => neutralCol

bool   histOn      = showChart and (chartMode == "Histogram + Cumulative" or chartMode == "Histogram Only")
bool   compareOn   = showChart and chartMode == "Fund Comparison"
bool   lineOn      = showChart and (chartMode == "Histogram + Cumulative" or chartMode == "Cumulative Only" or (compareOn and compareCum))
bool   fitOn       = showChart and chartMode == "Histogram + Cumulative" and cumScaleIn == "Fit To Histogram"
int   tableRows   = tableDays + (showStats ? 6 : 2)
bool  tablesOnChart = tableWhere == "Price Chart"
bool  excludeSeed   = seedMode == "Exclude"
float largeFlow   = largeFlowIn * 1000000.0
color tableBg     = color.rgb(0, 0, 0)
color tableBorder = color.new(#888888, 70)
color tableText   = color.new(#ffffff, 0)
color tableLatest = color.new(#ffffff, 88)
color edgeCol     = color.new(chart.bg_color, 0)

//              ╔════════════════════════════════╗              //
//              ║          ETF UNIVERSE          ║              //
//              ╚════════════════════════════════╝              //

buildList(array<string> syms, array<float> seeds, array<bool> flags) =>
    array<string> outSyms  = array.new<string>()
    array<float>  outSeeds = array.new<float>()
    for i = 0 to syms.size() - 1
        if flags.get(i)
            outSyms.push(syms.get(i))
            outSeeds.push(seeds.get(i) * 1000000.0)
    [outSyms, outSeeds]

listFor(string asset) =>
    switch asset
        "BTC" => buildList(array.from("NASDAQ:IBIT", "CBOE:FBTC", "AMEX:BITB", "CBOE:ARKB", "CBOE:BTCO", "CBOE:EZBC", "NASDAQ:BRRR", "CBOE:HODL", "CBOE:BTCW", "AMEX:MSBT", "AMEX:GBTC", "AMEX:BTC"), array.from(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), array.from(useIBIT, useFBTC, useBITB, useARKB, useBTCO, useEZBC, useBRRR, useHODL, useBTCW, useMSBT, useGBTC, useBTC))
        "ETH" => buildList(array.from("NASDAQ:ETHA", "NASDAQ:ETHB", "CBOE:FETH", "AMEX:ETHW", "CBOE:TETH", "CBOE:ETHV", "CBOE:QETH", "CBOE:EZET", "AMEX:MSSE", "AMEX:ETHE", "AMEX:ETH"), array.from(10.6, 104.7, 4.4, 2.5, 2.3, 10.2, 1.1, 2.7, 0.0, 0.0, 0.0), array.from(useETHA, useETHB, useFETH, useETHW, useTETH, useETHV, useQETH, useEZET, useMSSE, useETHE, useETH))
        "SOL" => buildList(array.from("AMEX:BSOL", "NASDAQ:VSOL", "AMEX:FSOL", "CBOE:TSOL", "AMEX:SOEZ", "AMEX:MSOL", "AMEX:GSOL"), array.from(222.9, 7.3, 3.0, 111.0, 2.4, 0.0, 0.0), array.from(useBSOL, useVSOL, useFSOL, useTSOL, useSOEZ, useMSOL, useGSOL))
        "XRP" => buildList(array.from("NASDAQ:XRPC", "AMEX:XRPZ", "AMEX:XRP", "AMEX:GXRP", "CBOE:TOXR"), array.from(0.0, 0.0, 0.0, 0.0, 0.0), array.from(useXRPC, useXRPZ, useXRP, useGXRP, useTOXR))
        "HYPE" => buildList(array.from("AMEX:BHYP", "NASDAQ:THYP", "NASDAQ:HYPG"), array.from(0.0, 0.0, 0.0), array.from(useBHYP, useTHYP, useHYPG))
        => [array.new<string>(), array.new<float>()]

tickerLabel(string sym) =>
    array<string> parts = str.split(sym, ":")
    parts.last()

//              ╔════════════════════════════════╗              //
//              ║           DATA ENGINE          ║              //
//              ╚════════════════════════════════╝              //

int dateKey = year * 10000 + month * 100 + dayofmonth

var array<int> usKeys  = array.new<int>()
var array<int> usTimes = array.new<int>()
var int        usLast  = na

int usBarTime = request.security("NASDAQ:IBIT", "D", time, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

if not na(usBarTime) and (na(usLast) or usBarTime != usLast)
    usKeys.push(dateKey)
    usTimes.push(time)
    usLast := usBarTime

type FlowState
    string        asset
    array<string> tickers
    array<float>  seeds
    array<bool>   seen
    array<int>    dayTimes
    array<float>  vals
    int           pendingKey
    array<float>  pendingRow
    array<float>  fundClosed
    float         cumClosed
    bool          hasData

newState(string asset) =>
    [syms, seeds] = listFor(asset)
    FlowState.new(asset = asset, tickers = syms, seeds = seeds, seen = array.new<bool>(syms.size(), false), dayTimes = array.new<int>(), vals = array.new<float>(), pendingKey = na, pendingRow = array.new<float>(), fundClosed = array.new<float>(syms.size(), 0.0), cumClosed = 0.0, hasData = false)

rowTotal(FlowState s, int r) =>
    int   n   = s.tickers.size()
    float tot = na
    if n > 0 and r >= 0 and r < s.dayTimes.size()
        for i = 0 to n - 1
            float v = s.vals.get(r * n + i)
            if not na(v)
                tot := nz(tot) + v
    tot

rowHasFlow(array<float> row) =>
    bool live = false
    for v in row
        if not na(v) and v != 0.0
            live := true
    live

seedFilter(FlowState s, int i, float v) =>
    float out = v
    if not na(v) and not s.seen.get(i)
        s.seen.set(i, true)
        float seed = s.seeds.get(i)
        if excludeSeed and seed > 0.0 and math.abs(v - seed) <= seed * 0.03
            out := 0.0
    out

attribute(FlowState s, int dayTime, array<float> raw) =>
    int  n        = s.tickers.size()
    int  rows     = s.dayTimes.size()
    bool appended = false
    array<float> row = array.new<float>(n, na)
    for i = 0 to n - 1
        row.set(i, seedFilter(s, i, raw.get(i)))
    if rows > 0 and s.dayTimes.get(rows - 1) == dayTime
        int base = (rows - 1) * n
        for i = 0 to n - 1
            float v = row.get(i)
            if not na(v)
                s.vals.set(base + i, v)
    else if rows > 0 or rowHasFlow(row)
        if rows > 0
            s.cumClosed := s.cumClosed + nz(rowTotal(s, rows - 1))
            int prevBase = (rows - 1) * n
            for i = 0 to n - 1
                s.fundClosed.set(i, s.fundClosed.get(i) + nz(s.vals.get(prevBase + i)))
        for i = 0 to n - 1
            s.vals.push(row.get(i))
        s.dayTimes.push(dayTime)
        s.hasData := true
        appended := true
    appended

updateState(FlowState s) =>
    int   n         = s.tickers.size()
    int   lastIdx   = usKeys.size() - 1
    bool  newDay    = false
    float prevTotal = na
    if not na(s.pendingKey) and lastIdx >= 0
        int lastKey = usKeys.get(lastIdx)
        if lastKey == s.pendingKey
            if lastIdx >= 1
                float pt = s.hasData ? rowTotal(s, s.dayTimes.size() - 1) : na
                bool appendedA = attribute(s, usTimes.get(lastIdx - 1), s.pendingRow)
                if appendedA
                    prevTotal := pt
                    newDay := true
            s.pendingKey := na
        else if lastKey > s.pendingKey
            s.pendingKey := na
    array<float> row = array.new<float>(n, na)
    bool anyNew = false
    for i = 0 to n - 1
        float f = request.financial(s.tickers.get(i), "FUND_FLOWS", "D", gaps = barmerge.gaps_on, ignore_invalid_symbol = true)
        if not na(f)
            row.set(i, f)
            anyNew := true
    if anyNew
        if lastIdx >= 1 and usKeys.get(lastIdx) == dateKey
            float pt = s.hasData ? rowTotal(s, s.dayTimes.size() - 1) : na
            bool appendedB = attribute(s, usTimes.get(lastIdx - 1), row)
            if appendedB
                prevTotal := pt
                newDay := true
        else if lastIdx < 0 or usKeys.get(lastIdx) < dateKey
            if s.pendingKey == dateKey
                for i = 0 to n - 1
                    float g = row.get(i)
                    if not na(g)
                        s.pendingRow.set(i, g)
            else
                s.pendingKey := dateKey
                s.pendingRow := row
    float curTotal = s.hasData ? rowTotal(s, s.dayTimes.size() - 1) : na
    float cumNow   = s.hasData ? s.cumClosed + nz(curTotal) : na
    int   gotCount = 0
    float fundHi   = na
    float fundLo   = na
    if s.hasData
        int lastBase = (s.dayTimes.size() - 1) * n
        for i = 0 to n - 1
            float cur = s.vals.get(lastBase + i)
            if not na(cur)
                gotCount += 1
            float val = s.fundClosed.get(i) + nz(cur)
            fundHi := na(fundHi) ? val : math.max(fundHi, val)
            fundLo := na(fundLo) ? val : math.min(fundLo, val)
    [newDay, curTotal, prevTotal, cumNow, gotCount, fundHi, fundLo]

string slot2Eff = slot2Asset == slot1Asset ? "Off" : slot2Asset
string slot3Eff = slot3Asset == slot1Asset or slot3Asset == slot2Eff ? "Off" : slot3Asset
string slot4Eff = slot4Asset == slot1Asset or slot4Asset == slot2Eff or slot4Asset == slot3Eff ? "Off" : slot4Asset
string slot5Eff = slot5Asset == slot1Asset or slot5Asset == slot2Eff or slot5Asset == slot3Eff or slot5Asset == slot4Eff ? "Off" : slot5Asset

var FlowState slotOne   = newState(slot1Asset)
var FlowState slotTwo   = newState(slot2Eff)
var FlowState slotThree = newState(slot3Eff)
var FlowState slotFour  = newState(slot4Eff)
var FlowState slotFive  = newState(slot5Eff)

bool slot1On = slot1Asset != "Off" and slotOne.tickers.size() > 0
bool slot2On = slot2Eff != "Off" and slotTwo.tickers.size() > 0
bool slot3On = slot3Eff != "Off" and slotThree.tickers.size() > 0
bool slot4On = slot4Eff != "Off" and slotFour.tickers.size() > 0
bool slot5On = slot5Eff != "Off" and slotFive.tickers.size() > 0

bool  s1New   = false
float s1Total = na
float s1Prev  = na
float s1Cum   = na
int   s1Got   = 0
float s1Hi    = na
float s1Lo    = na
if slot1On
    [d1, t1, p1, c1, g1, h1, o1] = updateState(slotOne)
    s1New   := d1
    s1Total := t1
    s1Prev  := p1
    s1Cum   := c1
    s1Got   := g1
    s1Hi    := h1
    s1Lo    := o1

bool  s2New   = false
float s2Total = na
float s2Prev  = na
float s2Cum   = na
int   s2Got   = 0
float s2Hi    = na
float s2Lo    = na
if slot2On
    [d2, t2, p2, c2, g2, h2, o2] = updateState(slotTwo)
    s2New   := d2
    s2Total := t2
    s2Prev  := p2
    s2Cum   := c2
    s2Got   := g2
    s2Hi    := h2
    s2Lo    := o2

bool  s3New   = false
float s3Total = na
float s3Prev  = na
float s3Cum   = na
int   s3Got   = 0
float s3Hi    = na
float s3Lo    = na
if slot3On
    [d3, t3, p3, c3, g3, h3, o3] = updateState(slotThree)
    s3New   := d3
    s3Total := t3
    s3Prev  := p3
    s3Cum   := c3
    s3Got   := g3
    s3Hi    := h3
    s3Lo    := o3

bool  s4New   = false
float s4Total = na
float s4Prev  = na
float s4Cum   = na
int   s4Got   = 0
float s4Hi    = na
float s4Lo    = na
if slot4On
    [d4, t4, p4, c4, g4, h4, o4] = updateState(slotFour)
    s4New   := d4
    s4Total := t4
    s4Prev  := p4
    s4Cum   := c4
    s4Got   := g4
    s4Hi    := h4
    s4Lo    := o4

bool  s5New   = false
float s5Total = na
float s5Prev  = na
float s5Cum   = na
int   s5Got   = 0
float s5Hi    = na
float s5Lo    = na
if slot5On
    [d5, t5, p5, c5, g5, h5, o5] = updateState(slotFive)
    s5New   := d5
    s5Total := t5
    s5Prev  := p5
    s5Cum   := c5
    s5Got   := g5
    s5Hi    := h5
    s5Lo    := o5

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

fmtFlow(float v) =>
    string out = "-"
    if not na(v)
        if v == 0.0
            out := "0"
        else
            float  a   = math.abs(v)
            float  r   = math.round(a / 1000000000.0, decimalsIn)
            string sfx = "B"
            if r < 1.0
                r := math.round(a / 1000000.0, decimalsIn)
                sfx := "M"
                if r < 1.0
                    r := math.round(a / 1000.0, decimalsIn)
                    sfx := "K"
                    if r < 1.0
                        r := math.round(a, decimalsIn)
                        sfx := ""
            out := (v > 0.0 ? "+" : "-") + str.tostring(r, decFmt) + sfx
    out

flowColor(float v) =>
    na(v) ? neutralCol : v > 0.0 ? inflowCol : v < 0.0 ? outflowCol : neutralCol

fundColor(int i) =>
    switch i % 12
        0 => #4c8dff
        1 => #ff8c42
        2 => #3ddc97
        3 => #e05fbd
        4 => #f2d94e
        5 => #9b6bff
        6 => #4fd1c5
        7 => #ff6b6b
        8 => #a3e048
        9 => #c084fc
        10 => #38bdf8
        => #fb923c

readoutTextColor(color fillColor) =>
    float brightness = (color.r(fillColor) * 299.0 + color.g(fillColor) * 587.0 + color.b(fillColor) * 114.0) / 1000.0
    brightness >= 128.0 ? color.black : color.white

slotSeries(FlowState s) =>
    int days = s.dayTimes.size()
    array<float> totals = array.new<float>(days, 0.0)
    array<float> cums   = array.new<float>(days, 0.0)
    float run = 0.0
    if days > 0
        for r = 0 to days - 1
            float dt = nz(rowTotal(s, r))
            run += dt
            totals.set(r, dt)
            cums.set(r, run)
    [totals, cums]


fillTable(table t, FlowState s) =>
    int n    = s.tickers.size()
    int days = s.dayTimes.size()
    int cols = n + 3
    [totals, cums] = slotSeries(s)
    table.clear(t, 0, 1, cols - 1, tableRows - 1)
    table.cell(t, 0, 0, s.asset + " ETF Flows (US$)", text_color = assetColor(s.asset), text_halign = text.align_center, text_size = tableTextSize, bgcolor = tableBg)
    table.cell(t, 0, 1, "Date", text_color = neutralCol, text_size = tableTextSize, bgcolor = tableBg)
    for i = 0 to n - 1
        table.cell(t, i + 1, 1, tickerLabel(s.tickers.get(i)), text_color = tableText, text_size = tableTextSize, bgcolor = tableBg)
    table.cell(t, n + 1, 1, "Total", text_color = tableText, text_size = tableTextSize, bgcolor = tableBg)
    table.cell(t, n + 2, 1, "Cumulative", text_color = assetColor(s.asset), text_size = tableTextSize, bgcolor = tableBg)
    int shown = math.min(tableDays, days)
    for k = 0 to shown - 1
        int   r   = days - shown + k
        int   row = 2 + k
        color bg  = r == days - 1 ? tableLatest : tableBg
        int   got = 0
        for i = 0 to n - 1
            float v = s.vals.get(r * n + i)
            if not na(v)
                got += 1
            table.cell(t, i + 1, row, fmtFlow(v), text_color = flowColor(v), text_size = tableTextSize, bgcolor = bg)
        bool   isPartial = r == days - 1 and got < n
        string dateText = str.format_time(s.dayTimes.get(r), "dd MMM yyyy", syminfo.timezone) + (isPartial ? " *" : "")
        string dateTip  = isPartial ? str.tostring(got) + " of " + str.tostring(n) + " funds reported so far. The feed publishes each fund's figure for a session during the following US session, so the remaining cells fill in as they arrive. Figures published after the chart was opened appear on the next reload." : ""
        table.cell(t, 0, row, dateText, text_color = neutralCol, text_size = tableTextSize, bgcolor = bg, tooltip = dateTip)
        float dayTot = rowTotal(s, r)
        float dayCum = cums.get(r)
        table.cell(t, n + 1, row, fmtFlow(dayTot), text_color = flowColor(dayTot), text_size = tableTextSize, bgcolor = bg)
        table.cell(t, n + 2, row, fmtFlow(dayCum), text_color = flowColor(dayCum), text_size = tableTextSize, bgcolor = bg)
    if showStats
        array<float> tSum    = array.new<float>(n, 0.0)
        array<int>   tCnt    = array.new<int>(n, 0)
        array<float> tMaxIn  = array.new<float>(n, na)
        array<float> tMaxOut = array.new<float>(n, na)
        array<bool>  tLive   = array.new<bool>(n, false)
        float gSum    = 0.0
        int   gCnt    = 0
        float gMaxIn  = na
        float gMaxOut = na
        for r = 0 to days - 1
            for i = 0 to n - 1
                float w = s.vals.get(r * n + i)
                if not na(w)
                    if w != 0.0
                        tLive.set(i, true)
                    if tLive.get(i)
                        tSum.set(i, tSum.get(i) + w)
                        tCnt.set(i, tCnt.get(i) + 1)
                        if w > 0.0
                            tMaxIn.set(i, na(tMaxIn.get(i)) ? w : math.max(tMaxIn.get(i), w))
                        if w < 0.0
                            tMaxOut.set(i, na(tMaxOut.get(i)) ? w : math.min(tMaxOut.get(i), w))
            float sTot = rowTotal(s, r)
            if not na(sTot)
                gSum += sTot
                gCnt += 1
                if sTot > 0.0
                    gMaxIn := na(gMaxIn) ? sTot : math.max(gMaxIn, sTot)
                if sTot < 0.0
                    gMaxOut := na(gMaxOut) ? sTot : math.min(gMaxOut, sTot)
        int    base  = 2 + shown
        string since = str.format_time(s.dayTimes.get(0), "dd MMM yyyy", syminfo.timezone)
        table.cell(t, 0, base,     "Total",       text_color = tableText, text_size = tableTextSize, bgcolor = tableBg, tooltip = "Since " + since + ", every day loaded on the chart")
        table.cell(t, 0, base + 1, "Average",     text_color = tableText, text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, 0, base + 2, "Max Inflow",  text_color = tableText, text_size = tableTextSize, bgcolor = tableBg, tooltip = "Largest single-day net inflow on record")
        table.cell(t, 0, base + 3, "Max Outflow", text_color = tableText, text_size = tableTextSize, bgcolor = tableBg, tooltip = "Largest single-day net outflow on record")
        for i = 0 to n - 1
            float cSum = tCnt.get(i) > 0 ? tSum.get(i) : na
            float cAvg = tCnt.get(i) > 0 ? tSum.get(i) / tCnt.get(i) : na
            table.cell(t, i + 1, base,     fmtFlow(cSum),           text_color = flowColor(cSum),           text_size = tableTextSize, bgcolor = tableBg)
            table.cell(t, i + 1, base + 1, fmtFlow(cAvg),           text_color = flowColor(cAvg),           text_size = tableTextSize, bgcolor = tableBg)
            table.cell(t, i + 1, base + 2, fmtFlow(tMaxIn.get(i)),  text_color = flowColor(tMaxIn.get(i)),  text_size = tableTextSize, bgcolor = tableBg)
            table.cell(t, i + 1, base + 3, fmtFlow(tMaxOut.get(i)), text_color = flowColor(tMaxOut.get(i)), text_size = tableTextSize, bgcolor = tableBg)
        float gTot = gCnt > 0 ? gSum : na
        float gAvg = gCnt > 0 ? gSum / gCnt : na
        float cEnd = days > 0 ? cums.get(days - 1) : na
        table.cell(t, n + 1, base,     fmtFlow(gTot),    text_color = flowColor(gTot),    text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, n + 1, base + 1, fmtFlow(gAvg),    text_color = flowColor(gAvg),    text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, n + 1, base + 2, fmtFlow(gMaxIn),  text_color = flowColor(gMaxIn),  text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, n + 1, base + 3, fmtFlow(gMaxOut), text_color = flowColor(gMaxOut), text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, n + 2, base,     fmtFlow(cEnd),    text_color = flowColor(cEnd),    text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, n + 2, base + 1, "-",              text_color = neutralCol,         text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, n + 2, base + 2, "-",              text_color = neutralCol,         text_size = tableTextSize, bgcolor = tableBg)
        table.cell(t, n + 2, base + 3, "-",              text_color = neutralCol,         text_size = tableTextSize, bgcolor = tableBg)

makeTable(FlowState s, string pos) =>
    int   cols = s.tickers.size() + 3
    table t    = na
    if tablesOnChart
        t := table.new(positionOf(pos), cols, tableRows, bgcolor = tableBg, frame_color = tableBorder, frame_width = 1, border_color = tableBorder, border_width = 1, force_overlay = true)
    else
        t := table.new(positionOf(pos), cols, tableRows, bgcolor = tableBg, frame_color = tableBorder, frame_width = 1, border_color = tableBorder, border_width = 1, force_overlay = false)
    table.merge_cells(t, 0, 0, cols - 1, 0)
    t

renderTable(table t, FlowState s) =>
    if s.hasData
        fillTable(t, s)
    else
        table.cell(t, 0, 0, s.asset + " ETF Flows: no fund flow data on this chart", text_color = neutralCol, text_size = tableTextSize, bgcolor = tableBg)

var table slot1Table = na
var table slot2Table = na
var table slot3Table = na
var table slot4Table = na
var table slot5Table = na

if barstate.isfirst and showTables
    if slot1On
        slot1Table := makeTable(slotOne, slot1Pos)
    if slot2On
        slot2Table := makeTable(slotTwo, slot2Pos)
    if slot3On
        slot3Table := makeTable(slotThree, slot3Pos)
    if slot4On
        slot4Table := makeTable(slotFour, slot4Pos)
    if slot5On
        slot5Table := makeTable(slotFive, slot5Pos)

if barstate.islast
    if not na(slot1Table)
        renderTable(slot1Table, slotOne)
    if not na(slot2Table)
        renderTable(slot2Table, slotTwo)
    if not na(slot3Table)
        renderTable(slot3Table, slotThree)
    if not na(slot4Table)
        renderTable(slot4Table, slotFour)
    if not na(slot5Table)
        renderTable(slot5Table, slotFive)

pushBar(array<chart.point> pts, int t, float v, int halfW) =>
    pts.push(chart.point.from_time(t - halfW, 0.0))
    pts.push(chart.point.from_time(t - halfW, v))
    pts.push(chart.point.from_time(t + halfW, v))
    pts.push(chart.point.from_time(t + halfW, 0.0))

drawFlow(FlowState s, float widthFrac) =>
    [totals, cums] = slotSeries(s)
    int days  = totals.size()
    int halfW = math.round(timeframe.in_seconds() * 1000.0 * widthFrac / 2.0)
    int start = math.max(0, days - 2000)
    array<chart.point> posPts = array.new<chart.point>()
    array<chart.point> negPts = array.new<chart.point>()
    polyline posPl = na
    polyline negPl = na
    if days > 0
        if flowStyle == "Histogram"
            for k = start to days - 1
                float v = totals.get(k)
                if v > 0.0
                    pushBar(posPts, s.dayTimes.get(k), v, halfW)
                else if v < 0.0
                    pushBar(negPts, s.dayTimes.get(k), v, halfW)
            if posPts.size() >= 4
                posPl := polyline.new(posPts, curved = false, closed = true, xloc = xloc.bar_time, line_color = edgeCol, fill_color = color.new(inflowCol, histTrans), line_style = line.style_solid, line_width = 1)
            if negPts.size() >= 4
                negPl := polyline.new(negPts, curved = false, closed = true, xloc = xloc.bar_time, line_color = edgeCol, fill_color = color.new(outflowCol, histTrans), line_style = line.style_solid, line_width = 1)
        else if flowStyle == "Line"
            for k = start to days - 1
                posPts.push(chart.point.from_time(s.dayTimes.get(k), totals.get(k)))
            if posPts.size() >= 2
                posPl := polyline.new(posPts, curved = false, closed = false, xloc = xloc.bar_time, line_color = assetColor(s.asset), line_style = line.style_solid, line_width = 1)
        else
            int   t0 = s.dayTimes.get(start)
            posPts.push(chart.point.from_time(t0, 0.0))
            negPts.push(chart.point.from_time(t0, 0.0))
            for k = start to days - 1
                int   t = s.dayTimes.get(k)
                float v = totals.get(k)
                if k > start
                    float pv = totals.get(k - 1)
                    if pv * v < 0.0
                        int pt = s.dayTimes.get(k - 1)
                        int tc = pt + math.round((t - pt) * (0.0 - pv) / (v - pv))
                        posPts.push(chart.point.from_time(tc, 0.0))
                        negPts.push(chart.point.from_time(tc, 0.0))
                posPts.push(chart.point.from_time(t, math.max(v, 0.0)))
                negPts.push(chart.point.from_time(t, math.min(v, 0.0)))
            int tEnd = s.dayTimes.get(days - 1)
            posPts.push(chart.point.from_time(tEnd, 0.0))
            negPts.push(chart.point.from_time(tEnd, 0.0))
            if posPts.size() >= 3
                posPl := polyline.new(posPts, curved = false, closed = true, xloc = xloc.bar_time, line_color = color.new(inflowCol, 0), fill_color = color.new(inflowCol, math.max(histTrans, 20)), line_style = line.style_solid, line_width = 1)
            if negPts.size() >= 3
                negPl := polyline.new(negPts, curved = false, closed = true, xloc = xloc.bar_time, line_color = color.new(outflowCol, 0), fill_color = color.new(outflowCol, math.max(histTrans, 20)), line_style = line.style_solid, line_width = 1)
    [posPl, negPl]

latestPartial(FlowState s) =>
    int  n       = s.tickers.size()
    int  days    = s.dayTimes.size()
    bool partial = false
    if days > 0 and n > 0
        int base = (days - 1) * n
        for i = 0 to n - 1
            if na(s.vals.get(base + i))
                partial := true
    partial

flowText(FlowState s) =>
    [totals, cums] = slotSeries(s)
    int days = totals.size()
    days > 0 ? "Net " + fmtFlow(totals.get(days - 1)) + (latestPartial(s) ? "*" : "") : ""

drawFlowLabel(FlowState s) =>
    [totals, cums] = slotSeries(s)
    int   days = totals.size()
    label lb   = na
    if days > 0
        color c    = assetColor(s.asset)
        color fill = color.new(c, 0)
        lb := label.new(s.dayTimes.get(days - 1), totals.get(days - 1), "  " + s.asset + "  " + flowText(s) + "  ", xloc = xloc.bar_time, style = label.style_label_left, color = fill, textcolor = readoutTextColor(fill), size = size.small)
    lb

drawCum(FlowState s) =>
    [totals, cums] = slotSeries(s)
    int   days  = totals.size()
    color lineC = assetColor(s.asset)
    polyline cumPl = na
    label    cumLb = na
    if days >= 2
        int   start = math.max(0, days - 9000)
        float hMin  = 0.0
        float hMax  = 0.0
        float cMin  = na
        float cMax  = na
        for r = 0 to days - 1
            hMin := math.min(hMin, totals.get(r))
            hMax := math.max(hMax, totals.get(r))
            cMin := na(cMin) ? cums.get(r) : math.min(cMin, cums.get(r))
            cMax := na(cMax) ? cums.get(r) : math.max(cMax, cums.get(r))
        bool fit = fitOn and cMax > cMin and hMax > hMin
        array<chart.point> pts = array.new<chart.point>()
        float yLast = na
        for r = start to days - 1
            float y = fit ? hMin + (cums.get(r) - cMin) / (cMax - cMin) * (hMax - hMin) : cums.get(r)
            pts.push(chart.point.from_time(s.dayTimes.get(r), y))
            yLast := y
        cumPl := polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_time, line_color = lineC, line_style = line.style_solid, line_width = 2)
        if showLabels
            color  fill = color.new(lineC, 0)
            string txt  = "  " + s.asset + "  " + flowText(s) + "  |  Cum " + fmtFlow(cums.get(days - 1)) + "  "
            cumLb := label.new(s.dayTimes.get(days - 1), yLast, txt, xloc = xloc.bar_time, style = label.style_label_left, color = fill, textcolor = readoutTextColor(fill), size = size.small)
    [cumPl, cumLb]

drawFundLines(FlowState s, array<polyline> pls, array<label> lbs) =>
    int n    = s.tickers.size()
    int days = s.dayTimes.size()
    if days >= 2
        for i = 0 to n - 1
            array<chart.point> pts = array.new<chart.point>()
            float run     = 0.0
            float lastY   = na
            bool  started = false
            for r = 0 to days - 1
                float v = s.vals.get(r * n + i)
                if not na(v)
                    started := true
                if started
                    run += nz(v)
                    pts.push(chart.point.from_time(s.dayTimes.get(r), run))
                    lastY := run
            if pts.size() >= 2
                color c = fundColor(i)
                pls.push(polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_time, line_color = c, line_style = line.style_solid, line_width = 1))
                string txt = "  " + tickerLabel(s.tickers.get(i)) + " " + fmtFlow(lastY) + "  "
                if showLabels
                    lbs.push(label.new(s.dayTimes.get(days - 1), lastY, txt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(c, 15), textcolor = readoutTextColor(c), size = size.tiny))

dropPolyline(polyline p) =>
    if not na(p)
        polyline.delete(p)

dropLabel(label l) =>
    if not na(l)
        label.delete(l)

var polyline s1Pos = na
var polyline s1Neg = na
var polyline s2Pos = na
var polyline s2Neg = na
var polyline s3Pos = na
var polyline s3Neg = na
var polyline s4Pos = na
var polyline s4Neg = na
var polyline s5Pos = na
var polyline s5Neg = na
var polyline s1CumPl = na
var polyline s2CumPl = na
var polyline s3CumPl = na
var polyline s4CumPl = na
var polyline s5CumPl = na
var label    s1Lbl = na
var label    s2Lbl = na
var label    s3Lbl = na
var label    s4Lbl = na
var label    s5Lbl = na
var array<polyline> fundPls = array.new<polyline>()
var array<label>    fundLbs = array.new<label>()

bool slot1Draw = slot1On and slotOne.hasData
bool slot2Draw = slot2On and slotTwo.hasData
bool slot3Draw = slot3On and slotThree.hasData
bool slot4Draw = slot4On and slotFour.hasData
bool slot5Draw = slot5On and slotFive.hasData

if barstate.islast and showChart
    dropPolyline(s1Pos)
    dropPolyline(s1Neg)
    dropPolyline(s2Pos)
    dropPolyline(s2Neg)
    dropPolyline(s3Pos)
    dropPolyline(s3Neg)
    dropPolyline(s4Pos)
    dropPolyline(s4Neg)
    dropPolyline(s5Pos)
    dropPolyline(s5Neg)
    dropPolyline(s1CumPl)
    dropPolyline(s2CumPl)
    dropPolyline(s3CumPl)
    dropPolyline(s4CumPl)
    dropPolyline(s5CumPl)
    dropLabel(s1Lbl)
    dropLabel(s2Lbl)
    dropLabel(s3Lbl)
    dropLabel(s4Lbl)
    dropLabel(s5Lbl)
    for fp in fundPls
        dropPolyline(fp)
    for fl in fundLbs
        dropLabel(fl)
    fundPls.clear()
    fundLbs.clear()
    s1Pos := na
    s1Neg := na
    s2Pos := na
    s2Neg := na
    s3Pos := na
    s3Neg := na
    s4Pos := na
    s4Neg := na
    s5Pos := na
    s5Neg := na
    s1CumPl := na
    s2CumPl := na
    s3CumPl := na
    s4CumPl := na
    s5CumPl := na
    s1Lbl := na
    s2Lbl := na
    s3Lbl := na
    s4Lbl := na
    s5Lbl := na
    if histOn
        if slot1Draw
            [a1, b1] = drawFlow(slotOne, 0.80)
            s1Pos := a1
            s1Neg := b1
        if slot2Draw
            [a2, b2] = drawFlow(slotTwo, 0.65)
            s2Pos := a2
            s2Neg := b2
        if slot3Draw
            [a3, b3] = drawFlow(slotThree, 0.50)
            s3Pos := a3
            s3Neg := b3
        if slot4Draw
            [a4, b4] = drawFlow(slotFour, 0.35)
            s4Pos := a4
            s4Neg := b4
        if slot5Draw
            [a5, b5] = drawFlow(slotFive, 0.20)
            s5Pos := a5
            s5Neg := b5
    if lineOn
        if slot1Draw
            [q1, m1] = drawCum(slotOne)
            s1CumPl := q1
            s1Lbl := m1
        if slot2Draw
            [q2, m2] = drawCum(slotTwo)
            s2CumPl := q2
            s2Lbl := m2
        if slot3Draw
            [q3, m3] = drawCum(slotThree)
            s3CumPl := q3
            s3Lbl := m3
        if slot4Draw
            [q4, m4] = drawCum(slotFour)
            s4CumPl := q4
            s4Lbl := m4
        if slot5Draw
            [q5, m5] = drawCum(slotFive)
            s5CumPl := q5
            s5Lbl := m5
    if histOn and not lineOn and showLabels
        if slot1Draw
            s1Lbl := drawFlowLabel(slotOne)
        if slot2Draw
            s2Lbl := drawFlowLabel(slotTwo)
        if slot3Draw
            s3Lbl := drawFlowLabel(slotThree)
        if slot4Draw
            s4Lbl := drawFlowLabel(slotFour)
        if slot5Draw
            s5Lbl := drawFlowLabel(slotFive)
    if compareOn
        if slot1Draw
            drawFundLines(slotOne, fundPls, fundLbs)
        if slot2Draw
            drawFundLines(slotTwo, fundPls, fundLbs)
        if slot3Draw
            drawFundLines(slotThree, fundPls, fundLbs)
        if slot4Draw
            drawFundLines(slotFour, fundPls, fundLbs)
        if slot5Draw
            drawFundLines(slotFive, fundPls, fundLbs)

color scaleCol = color.new(#000000, 100)

plot(histOn and slot1On and s1New ? s1Total : na, "Slot 1 Flow Scale", color = scaleCol, style = plot.style_columns, display = display.pane)
plot(histOn and slot2On and s2New ? s2Total : na, "Slot 2 Flow Scale", color = scaleCol, style = plot.style_columns, display = display.pane)
plot(histOn and slot3On and s3New ? s3Total : na, "Slot 3 Flow Scale", color = scaleCol, style = plot.style_columns, display = display.pane)
plot(histOn and slot4On and s4New ? s4Total : na, "Slot 4 Flow Scale", color = scaleCol, style = plot.style_columns, display = display.pane)
plot(histOn and slot5On and s5New ? s5Total : na, "Slot 5 Flow Scale", color = scaleCol, style = plot.style_columns, display = display.pane)
plot(lineOn and not fitOn and slot1On ? s1Cum : na, "Slot 1 Line Scale", color = scaleCol, display = display.pane)
plot(lineOn and not fitOn and slot2On ? s2Cum : na, "Slot 2 Line Scale", color = scaleCol, display = display.pane)
plot(lineOn and not fitOn and slot3On ? s3Cum : na, "Slot 3 Line Scale", color = scaleCol, display = display.pane)
plot(lineOn and not fitOn and slot4On ? s4Cum : na, "Slot 4 Line Scale", color = scaleCol, display = display.pane)
plot(lineOn and not fitOn and slot5On ? s5Cum : na, "Slot 5 Line Scale", color = scaleCol, display = display.pane)
plot(compareOn and slot1On ? s1Hi : na, "Slot 1 Fund High", color = scaleCol, display = display.pane)
plot(compareOn and slot1On ? s1Lo : na, "Slot 1 Fund Low", color = scaleCol, display = display.pane)
plot(compareOn and slot2On ? s2Hi : na, "Slot 2 Fund High", color = scaleCol, display = display.pane)
plot(compareOn and slot2On ? s2Lo : na, "Slot 2 Fund Low", color = scaleCol, display = display.pane)
plot(compareOn and slot3On ? s3Hi : na, "Slot 3 Fund High", color = scaleCol, display = display.pane)
plot(compareOn and slot3On ? s3Lo : na, "Slot 3 Fund Low", color = scaleCol, display = display.pane)
plot(compareOn and slot4On ? s4Hi : na, "Slot 4 Fund High", color = scaleCol, display = display.pane)
plot(compareOn and slot4On ? s4Lo : na, "Slot 4 Fund Low", color = scaleCol, display = display.pane)
plot(compareOn and slot5On ? s5Hi : na, "Slot 5 Fund High", color = scaleCol, display = display.pane)
plot(compareOn and slot5On ? s5Lo : na, "Slot 5 Fund Low", color = scaleCol, display = display.pane)
hline(0, "Zero Line", color = color.new(#888888, 50), linestyle = hline.style_dotted)

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

bool inflowDay    = (slot1On and s1New and s1Total > 0.0) or (slot2On and s2New and s2Total > 0.0) or (slot3On and s3New and s3Total > 0.0) or (slot4On and s4New and s4Total > 0.0) or (slot5On and s5New and s5Total > 0.0)
bool outflowDay   = (slot1On and s1New and s1Total < 0.0) or (slot2On and s2New and s2Total < 0.0) or (slot3On and s3New and s3Total < 0.0) or (slot4On and s4New and s4Total < 0.0) or (slot5On and s5New and s5Total < 0.0)
bool largeInflow  = (slot1On and s1New and s1Total >= largeFlow) or (slot2On and s2New and s2Total >= largeFlow) or (slot3On and s3New and s3Total >= largeFlow) or (slot4On and s4New and s4Total >= largeFlow) or (slot5On and s5New and s5Total >= largeFlow)
bool largeOutflow = (slot1On and s1New and s1Total <= -largeFlow) or (slot2On and s2New and s2Total <= -largeFlow) or (slot3On and s3New and s3Total <= -largeFlow) or (slot4On and s4New and s4Total <= -largeFlow) or (slot5On and s5New and s5Total <= -largeFlow)
bool flowFlip     = (slot1On and s1New and s1Total * s1Prev < 0.0) or (slot2On and s2New and s2Total * s2Prev < 0.0) or (slot3On and s3New and s3Total * s3Prev < 0.0) or (slot4On and s4New and s4Total * s4Prev < 0.0) or (slot5On and s5New and s5Total * s5Prev < 0.0)
bool newData      = (slot1On and s1New) or (slot2On and s2New) or (slot3On and s3New) or (slot4On and s4New) or (slot5On and s5New)

alertcondition(inflowDay, title = "Net Inflow Day", message = "Crypto ETF Flow Tracker: a tracked asset recorded a net inflow day, check the tables on {{exchange}}:{{ticker}}")
alertcondition(outflowDay, title = "Net Outflow Day", message = "Crypto ETF Flow Tracker: a tracked asset recorded a net outflow day, check the tables on {{exchange}}:{{ticker}}")
alertcondition(largeInflow, title = "Large Inflow Day", message = "Crypto ETF Flow Tracker: a tracked asset recorded a net inflow above the large flow threshold, check the tables on {{exchange}}:{{ticker}}")
alertcondition(largeOutflow, title = "Large Outflow Day", message = "Crypto ETF Flow Tracker: a tracked asset recorded a net outflow beyond the large flow threshold, check the tables on {{exchange}}:{{ticker}}")
alertcondition(flowFlip, title = "Flow Direction Flip", message = "Crypto ETF Flow Tracker: a tracked asset flipped between net inflow and net outflow versus the prior trading day, check the tables on {{exchange}}:{{ticker}}")
alertcondition(newData, title = "Flow Data Published", message = "Crypto ETF Flow Tracker: the feed delivered a new trading day of flows for a tracked asset, check the tables on {{exchange}}:{{ticker}}")

flowMessage(FlowState s, float total, int got) =>
    string dateText = str.format_time(s.dayTimes.get(s.dayTimes.size() - 1), "dd MMM yyyy", syminfo.timezone)
    string sizeText = math.abs(total) >= largeFlow ? ", large flow" : ""
    s.asset + " ETF flows: " + fmtFlow(total) + " net flow for " + dateText + " with " + str.tostring(got) + " of " + str.tostring(s.tickers.size()) + " funds reported" + sizeText

if slot1On and s1New
    alert(flowMessage(slotOne, s1Total, s1Got), alert.freq_once_per_bar)
if slot2On and s2New
    alert(flowMessage(slotTwo, s2Total, s2Got), alert.freq_once_per_bar)
if slot3On and s3New
    alert(flowMessage(slotThree, s3Total, s3Got), alert.freq_once_per_bar)
if slot4On and s4New
    alert(flowMessage(slotFour, s4Total, s4Got), alert.freq_once_per_bar)
if slot5On and s5New
    alert(flowMessage(slotFive, s5Total, s5Got), alert.freq_once_per_bar)

//              ╔════════════════════════════════╗              //
//              ║           CREATED BY           ║              //
//              ╚════════════════════════════════╝              //

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗ 
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````

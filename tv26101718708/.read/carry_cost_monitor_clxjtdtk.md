# Carry Cost Monitor

- url: https://www.tradingview.com/script/CLXjtdTK-Carry-Cost-Monitor/
- type: indicator
- pine_id: PUB;803943eb25ff4994ba5197cef909138a
- version: 1.0

## Description

[b]The bill you did not expect[/b]

You run a Swiss franc account. You trade Micro E-mini S&P 500 futures because the US equity market is where the liquidity is. One quarter later your broker sends a statement and there it is: [b]CHF 1,600 in debit interest[/b]. Nobody warned you. The contract you traded settles in US dollars. Your account holds Swiss francs. Interactive Brokers lent you the dollars, charged you the USD overnight rate plus 1.5% markup on every dollar for every day you held the position. Meanwhile your Swiss franc cash earned close to nothing because the SNB policy rate sits well below the Fed Funds rate. The gap between those two rates, accumulated silently over months, is the [i]carry cost[/i] that drained your account.

This is not a rare edge case. Any trader whose account currency differs from the instrument currency faces the same mechanic. A European trading US equities, a Japanese investor buying Australian bonds, a Canadian holding FTSE futures. The cost is real, it compounds daily, and most platforms do not surface it until the quarterly statement arrives.

The Carry Cost Monitor exists to make this cost [b]visible before it accumulates[/b]. It shows the yield differential between your account currency and the instrument currency in real time, estimates the financing cost or income over any horizon you choose, and lets you compare all major currencies side by side so you can make informed decisions about where and what you trade.

The indicator applied to a US dollar denominated chart with a CHF base account. The dashboard in the top right shows the carry spread, percentile rank, estimated annual cost, and break-even return. Below, the comparison table lists all available currencies sorted by carry cost.

[b]What carry costs actually are[/b]

When you hold an instrument denominated in a foreign currency, your broker creates a [i]loan[/i] in that currency to settle the trade. You owe interest on the borrowed amount and may earn interest on your deposited base currency. The net cost is the difference between those two rates plus whatever the broker charges on top.

The indicator formalizes this as:

  [i]Carry Spread (%) = Y_instrument - Y_account[/i]

where Y is the sovereign yield for the selected maturity. A positive spread means you borrow a currency that yields more than yours. [b]You pay.[/b] A negative spread means the borrowed currency yields less than your base. [b]You earn.[/b]

The gross carry rate adds the broker fee:

  [i]Gross Carry (%) = Carry Spread + Broker Markup[/i]

Interactive Brokers structures this markup in tiers (Interactive Brokers, 2024):

  Balance 0 to 100,000:    benchmark + [b]1.50%[/b]
  Balance 100,000 to 1M:   benchmark + 0.50%
  Balance above 1M:        benchmark + 0.30%

The estimated cost over a chosen horizon follows standard money market convention, adjusted for each currency's day count basis (Stigum and Crescenzi, 2007):

  [i]Cost = Nominal * (Gross Carry / 100) * (Days / Day Count Basis)[/i]

Day Count Basis is 360 for USD, EUR, CHF, JPY, and SEK (ACT/360), and 365 for GBP, CAD, AUD, and NZD (ACT/365). These match the interbank settlement rules in the ISDA day count fraction definitions (ISDA, 2006).

Finally, the break-even tells you how much your instrument must move to cover the carry drag:

  [i]Break-Even (%) = |Gross Carry| * (Days / 365)[/i]

This is the [b]minimum performance[/b] needed to not lose money purely from financing.

[b]Where the data comes from[/b]

The indicator pulls sovereign bond yields for [b]9 currencies[/b] across two maturities (2-year and 10-year), totaling 18 external data requests. The symbols follow TradingView's TVC convention:

  USD: US02Y / US10Y          EUR: DE02Y / DE10Y (Germany as eurozone proxy)
  CHF: CH02Y / CH10Y          GBP: GB02Y / GB10Y
  JPY: JP02Y / JP10Y             CAD: CA02Y / CA10Y
  AUD: AU02Y / AU10Y          NZD: NZ02Y / NZ10Y
  SEK: SE02Y / SE10Y

The 2-year yield is the default because it sits closest to actual overnight funding rates. The correlation between 2-year sovereign yields and their respective benchmarks (SOFR for USD, SARON for CHF, ESTR for EUR) typically exceeds [b]0.85[/b] over rolling 1-year windows, with average deviations of 20 to 50 basis points (Ilmanen, 2011). That deviation is smaller than the broker markup itself, making sovereign yields a practical proxy.

Why not use the overnight rates directly? Most are only available at monthly frequency through FRED on TradingView, with shorter history. Sovereign yields update daily with 10+ years of data. The trade-off is slight imprecision for much better coverage and responsiveness.

The instrument currency is detected automatically through the built-in [i]syminfo.currency[/i] variable. When it matches your account currency, the indicator reports zero cost because no foreign exchange borrowing occurs. Currencies whose yield data returns nothing on TradingView are hidden from the chart and dashboard automatically.

https://www.tradingview.com/x/UjVSZSnC/
[i]The settings panel showing the Carry Model inputs. Account Currency is set to CHF, Yield Maturity to 2Y, Position Size to 100,000, and the broker tier to 0-100k. These four settings control the entire cost calculation.[/i]

[b]Reading the carry lines[/b]

The main panel draws up to 8 spread lines, one per foreign currency relative to your account currency. 

The [b]zero line[/b] is the boundary. Everything above it costs you money. Everything below it earns you money. The further a line sits from zero, the larger the financing effect.

For the active instrument pair, a [b]1-sigma band[/b] (252-day rolling mean plus/minus one standard deviation) wraps around the spread. When the current value breaks outside this band, the carry environment is statistically unusual compared to its own recent history. That might mean a central bank shifted rates, or term spreads moved.

Each currency has its own color, chosen to stay distinguishable even under the most common forms of colorblindness:

  USD: [i]blue[/i]              EUR: [i]amber[/i]           CHF: [i]red[/i]             GBP: [i]purple[/i]
  JPY: [i]emerald[/i]         CAD: [i]orange[/i]         AUD: [i]cyan[/i]           NZD: [i]lime[/i]
  SEK: [i]fuchsia[/i]

https://www.tradingview.com/x/mkur7Jrr/
[i]The historical view with all currency lines visible. Each colored line represents one currency's carry spread against the selected base. Crossing the zero line marks a shift from paying carry to earning it.[/i]

[b]The dashboard[/b]

The dashboard sits in the corner of the chart (position adjustable) and answers two questions without requiring you to read the lines themselves.

The [b]top section[/b] shows the active pair in detail: the raw carry spread in percent, its percentile rank over 2 years (504 trading days), the estimated absolute cost or income for your chosen time horizon and position size, and the break-even return. This is the quick answer to [i]"what is this position costing me right now?"[/i]

The [b]bottom section[/b] is a comparison table listing every currency with valid data. Each row shows the currency name, its carry spread, its current yield, and the projected cost over your horizon. The instrument currency is marked with a triangle. Rows are color-coded: green for pairs that produce income, red for pairs that cost you money. This answers the follow-up question: [i]"would my carry situation improve if I traded a similar instrument denominated in a different currency?"[/i]

https://www.tradingview.com/x/yNlJwC6l/
[i]The dashboard detail showing the active pair section. CHF to USD carry spread is positive, placing it in the 72nd percentile of its 2-year range. The estimated annual cost for a 100,000 position at the 0-100k broker tier is displayed alongside the break-even return.

The comparison table below the active pair section. All currencies are listed with their individual spreads and estimated costs. JPY shows the largest negative spread (income), while USD shows the highest positive spread (cost) from a CHF base perspective.[/i]

[b]Setting it up[/b]

The Carry Model group contains the five settings that determine everything:

[b]Account Currency[/b]: your brokerage base currency. This is the single most important input. Get this wrong and every number on the screen is meaningless.

[b]Yield Maturity[/b]: 2Y sits closer to actual funding costs. 10Y captures term premium effects and is useful for longer-horizon strategic planning.

[b]Position Size[/b]: the notional value of your position in the instrument currency. Drives the absolute cost estimate.

[b]Cost Horizon[/b]: 1 month, 3 months, 6 months, or 1 year. Controls how far out the projection reaches.

[b]Broker Balance Tier[/b]: matches the IB tiered structure. Set to "None" to strip out the broker markup entirely and see the pure yield differential.

The Display group controls background shading (green when earning, red when paying) and whether all currency lines appear or only the detected one.

Eight color themes are available (EdgeTools, Gold, Behavioral, Quant, Ocean, Fire, Matrix, Arctic) with dark and light mode support. Line width and glow effects are adjustable.

Three alert conditions can fire:

  Carry spread enters the [b]90th percentile[/b] (historically expensive environment)
  Carry spread enters the [b]10th percentile[/b] (historically cheap environment)
  Carry spread [b]crosses zero[/b] (direction flipped)

[b]Practical examples[/b]

[b]Example 1[/b]: CHF account trading MES (Micro E-mini S&P 500)
Account currency: CHF. Instrument currency: USD. Assume CH02Y = 0.60%, US02Y = 3.85%.

Carry spread = 3.85 - 0.60 = [b]+3.25%[/b].
Broker markup (0-100k tier) = 1.50%.
Gross carry = 3.25 + 1.50 = [b]4.75%[/b].
Annual cost on 100,000 USD nominal = 100,000 * 0.0475 * (365/360) = [b]4,819 USD[/b].
Break-even = 4.75% per year. The S&P 500 must return more than 4.75% annually just to cover carry.

[b]Example 2[/b]: USD account buying CSPX (iShares S&P 500 UCITS, EUR-listed)
Account currency: USD. Instrument currency: EUR. Assume US02Y = 3.85%, DE02Y = 2.05%.

Carry spread = 2.05 - 3.85 = [b]-1.80%[/b].
Broker markup = 1.50%.
Gross carry = -1.80 + 1.50 = [b]-0.30%[/b].
Annual income on 100,000 EUR nominal = 100,000 * 0.003 * (365/360) = [b]304 EUR[/b].
You earn a small amount because USD yields exceed EUR yields by more than the broker markup.

[b]Example 3[/b]: EUR account trading Nikkei 225 futures (JPY-denominated)
Account currency: EUR. Instrument currency: JPY. Assume DE02Y = 2.05%, JP02Y = 0.15%.

Carry spread = 0.15 - 2.05 = [b]-1.90%[/b].
Broker markup = 1.50%.
Gross carry = -1.90 + 1.50 = [b]-0.40%[/b].
You earn a small net income because borrowing JPY is cheaper than what your EUR balance yields.

These examples show that the carry direction depends entirely on which currency has the higher rate and how large the broker fee is. Pairs close to zero can flip between cost and income whenever a central bank moves.

[b]Limitations[/b]

Sovereign yields are [i]not[/i] overnight rates. The 2-year bond yield is a proxy, not the exact benchmark brokers use. Interactive Brokers references SOFR for USD, SARON for CHF, ESTR for EUR, SONIA for GBP. The gap between sovereign 2Y yields and these overnight rates typically sits at 20 to 50 basis points (Ilmanen, 2011, p. 364), occasionally more during yield curve inversions.

The broker cost model is simplified. Real IB interest calculations depend on multi-currency balances across the account, unrealized PnL, margin usage, and the interaction between positive and negative currency positions. The indicator applies a single-tier markup, which captures the dominant cost component but may overstate the net cost for larger accounts earning credit interest on their base currency.

Currency detection relies on [i]syminfo.currency[/i]. For most futures, ETFs, and equities on major exchanges, this returns the correct settlement currency. Some synthetic instruments, CFDs, or crypto pairs may return unexpected values. Always verify the detected currency in the dashboard header.

Currencies that consistently lacked yield data on TradingView (such as NOK) have been excluded. Missing data for remaining currencies is handled gracefully and does not produce errors.

The indicator works best on the [b]daily timeframe[/b]. Intraday charts display yield data that updates once per day, creating flat segments within the session. This does not affect the accuracy of cost estimates.

[b]References[/b]

Ilmanen, A. (2011) [i]Expected returns: an investor's guide to harvesting market rewards[/i]. Chichester: John Wiley and Sons.

Interactive Brokers (2024) Interest rates on credit and debit balances. (Web Accessed: May 2026).

ISDA (2006) [i]2006 ISDA definitions[/i]. New York: International Swaps and Derivatives Association.

Koijen, R.S.J., Moskowitz, T.J., Pedersen, L.H. and Vrugt, E.B. (2018) 'Carry', [i]Journal of Financial Economics[/i], 127(2), pp. 197-225.

Stigum, M. and Crescenzi, A. (2007) [i]Stigum's money market[/i]. 4th edn. New York: McGraw-Hill.

## Source Code

````pine
//@version=6
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
// (c) EdgeTools

// Carry Cost Monitor (CCM)
//
// Estimates the implicit financing cost or income when trading instruments
// denominated in a foreign currency from a different account base currency.
// Sovereign yield differentials serve as proxies for short-term funding rates.
//
// The instrument currency is detected automatically via syminfo.currency.
// The user selects their brokerage account base currency manually.
//
// Data universe (18 security calls):
//   2Y yields:  US02Y, DE02Y, CH02Y, GB02Y, JP02Y, CA02Y, AU02Y, NZ02Y, SE02Y
//   10Y yields: US10Y, DE10Y, CH10Y, GB10Y, JP10Y, CA10Y, AU10Y, NZ10Y, SE10Y
//
// Day count conventions:
//   ACT/360 -- USD, EUR, CHF, JPY, SEK
//   ACT/365 -- GBP, CAD, AUD, NZD
//
// Carry spread = Yield(instrument currency) - Yield(account currency)
//   Positive spread: you pay carry (instrument currency yields more)
//   Negative spread: you earn carry (account currency yields more)
//
// Broker cost model (Interactive Brokers tiered):
//   Debit  0-100k:  benchmark + 1.50%
//   Debit  100k-1M: benchmark + 0.50%
//   Debit  >1M:     benchmark + 0.30%
//   Credit 0-10k:   0.00%
//   Credit >10k:    benchmark - 0.50%
//
// How to use:
//   1. Set your brokerage account currency in the Carry Model settings
//   2. Open any chart -- the instrument currency is detected automatically
//   3. Read the dashboard for estimated carry costs over your chosen horizon
//   4. Compare all currency spreads in the table to find cheaper alternatives
//   5. Use the historical lines to see how carry environments shifted over time
//
// Limitations:
//   Sovereign yields are proxies, not actual overnight benchmarks (SOFR, SARON, etc.).
//   Typical deviation from true funding rate: 20-50 bps.
//   Broker spreads are simplified; actual tiering depends on total account balance.
//   Currencies without yield data on TradingView are automatically hidden.
//   Best used on daily timeframe; intraday yield data may lag.
//
// References:
//   Ilmanen (2011) Expected Returns, Chapter 14: Carry
//   Koijen, Moskowitz, Pedersen, Vrugt (2018) Carry, Journal of Financial Economics
//
// Educational and analysis purposes only. Not investment advice.

indicator("Carry Cost Monitor", shorttitle="CCM", overlay=false,
     max_bars_back=500, max_lines_count=500)

// inputs

i_base_ccy    = input.string("USD", "Account Currency",
     options=["USD", "EUR", "CHF", "GBP", "JPY", "CAD", "AUD", "NZD", "SEK"],
     group="Carry Model",
     tooltip="Your brokerage account base currency.")
i_maturity    = input.string("2Y", "Yield Maturity",
     options=["2Y", "10Y"], group="Carry Model",
     tooltip="2Y is closer to short-term funding costs. 10Y captures term premium.")
i_position    = input.float(100000, "Position Size (Nominal)", minval=1000, step=10000,
     group="Carry Model",
     tooltip="Notional value of position in instrument currency.")
i_horizon     = input.string("1Y", "Cost Horizon",
     options=["1M", "3M", "6M", "1Y"], group="Carry Model",
     tooltip="Time horizon for cost/income estimation.")
i_broker_tier = input.string("0-100k", "Broker Balance Tier",
     options=["0-100k", "100k-1M", ">1M", "None"], group="Carry Model",
     tooltip="Approximate IB debit interest tier. Determines broker markup over benchmark.")

i_bg_mode     = input.string("Carry", "Background Mode",
     options=["Off", "Carry"], group="Display",
     tooltip="Carry: green when earning, red when paying.")
i_bg_int      = input.int(88, "Background Intensity", minval=70, maxval=95, step=1, group="Display")
i_show_all    = input.bool(true, "Show All Currency Lines", group="Display",
     tooltip="Plot carry spreads for all currencies, not just the detected instrument currency.")

i_candles     = input.bool(false, "Color Candles", group="Candles")
i_candle_tr   = input.int(25, "Candle Transparency", minval=0, maxval=60, step=5, group="Candles")

i_dash        = input.bool(true, "Show Dashboard", group="Dashboard")
i_dash_pos    = input.string("Top Right", "Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"],
     group="Dashboard")
i_dash_sz     = input.string("Normal", "Size",
     options=["Tiny", "Small", "Normal", "Large"], group="Dashboard")

i_wm          = input.bool(true, "Show Watermark", group="Watermark")
i_wm_pos      = input.string("Bottom Right", "Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"],
     group="Watermark")
i_wm_sz       = input.string("Large", "Size",
     options=["Small", "Normal", "Large", "Huge"], group="Watermark")

i_theme       = input.string("EdgeTools", "Color Theme",
     options=["EdgeTools", "Gold", "Behavioral", "Quant", "Ocean", "Fire", "Matrix", "Arctic"],
     group="Appearance")
i_dark        = input.bool(true, "Dark Mode", group="Appearance")
i_width       = input.int(2, "Line Width", minval=1, maxval=5, group="Appearance")
i_glow        = input.bool(true, "Glow Effect", group="Appearance")

i_alerts      = input.bool(false, "Enable Alerts", group="Alerts")

// color scheme

var color primary_color = na
var color bullish_color = na
var color bearish_color = na
var color neutral_color = na
var color text_color    = na
var color bg_color      = na
var color table_bg      = na
var color header_bg     = na

switch i_theme
    "EdgeTools" =>
        primary_color := i_dark ? #3b82f6 : #2563eb
        bullish_color := i_dark ? #22c55e : #16a34a
        bearish_color := i_dark ? #ef4444 : #dc2626
        neutral_color := i_dark ? #737373 : #525252
        text_color    := i_dark ? #fafafa : #0a0a0a
        bg_color      := i_dark ? #0a0a0a : #fafafa
        table_bg      := i_dark ? #171717 : #f9f9f9
        header_bg     := i_dark ? #262626 : #e5e5e5
    "Gold" =>
        primary_color := i_dark ? #FFD700 : #DAA520
        bullish_color := i_dark ? #FFA500 : #FF8C00
        bearish_color := i_dark ? #FF5252 : #D32F2F
        neutral_color := i_dark ? #C0C0C0 : #808080
        text_color    := i_dark ? color.white : color.black
        bg_color      := i_dark ? #000000 : #FFFFFF
        table_bg      := i_dark ? #1A1A00 : #FFFEF0
        header_bg     := i_dark ? #2D2600 : #F5F5DC
    "Behavioral" =>
        primary_color := #808080
        bullish_color := #00FF00
        bearish_color := #8B0000
        neutral_color := #FFBF00
        text_color    := i_dark ? color.white : color.black
        bg_color      := i_dark ? #000000 : #FFFFFF
        table_bg      := i_dark ? #1A1A1A : #F8F8F8
        header_bg     := i_dark ? #2D2D2D : #E8E8E8
    "Quant" =>
        primary_color := #808080
        bullish_color := #FFA500
        bearish_color := #8B0000
        neutral_color := #4682B4
        text_color    := i_dark ? color.white : color.black
        bg_color      := i_dark ? #000000 : #FFFFFF
        table_bg      := i_dark ? #0D0D0D : #FAFAFA
        header_bg     := i_dark ? #1A1A1A : #F0F0F0
    "Ocean" =>
        primary_color := i_dark ? #20B2AA : #008B8B
        bullish_color := i_dark ? #00CED1 : #4682B4
        bearish_color := i_dark ? #FF4500 : #B22222
        neutral_color := i_dark ? #87CEEB : #2F4F4F
        text_color    := i_dark ? #F0F8FF : #191970
        bg_color      := i_dark ? #001F3F : #F0F8FF
        table_bg      := i_dark ? #001A2E : #E6F7FF
        header_bg     := i_dark ? #002A47 : #CCF2FF
    "Fire" =>
        primary_color := i_dark ? #FF6347 : #DC143C
        bullish_color := i_dark ? #FFD700 : #FF8C00
        bearish_color := i_dark ? #8B0000 : #800000
        neutral_color := i_dark ? #FFA500 : #CD853F
        text_color    := i_dark ? #FFFAF0 : #2F1B14
        bg_color      := i_dark ? #2F1B14 : #FFFAF0
        table_bg      := i_dark ? #261611 : #FFF8F0
        header_bg     := i_dark ? #3D241A : #FFE4CC
    "Matrix" =>
        primary_color := i_dark ? #00FF41 : #006400
        bullish_color := i_dark ? #39FF14 : #228B22
        bearish_color := i_dark ? #FF073A : #8B0000
        neutral_color := i_dark ? #00FFFF : #008B8B
        text_color    := i_dark ? #C0FF8C : #003300
        bg_color      := i_dark ? #0D1B0D : #F0FFF0
        table_bg      := i_dark ? #0A1A0A : #E8FFF0
        header_bg     := i_dark ? #112B11 : #CCFFCC
    "Arctic" =>
        primary_color := i_dark ? #87CEFA : #4169E1
        bullish_color := i_dark ? #00BFFF : #0000CD
        bearish_color := i_dark ? #FF1493 : #8B008B
        neutral_color := i_dark ? #B0E0E6 : #483D8B
        text_color    := i_dark ? #F8F8FF : #191970
        bg_color      := i_dark ? #191970 : #F8F8FF
        table_bg      := i_dark ? #141B47 : #F0F8FF
        header_bg     := i_dark ? #1E2A5C : #E0F0FF

table_tr = i_dark ? 80 : 15

// currency-specific line colors

color COL_USD = #3b82f6
color COL_EUR = #f59e0b
color COL_CHF = #ef4444
color COL_GBP = #8b5cf6
color COL_JPY = #10b981
color COL_CAD = #f97316
color COL_AUD = #06b6d4
color COL_NZD = #84cc16
color COL_SEK = #e879f9

// helpers

f_pos(string pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        => position.bottom_center

f_sz(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_ccy_color(string ccy) =>
    switch ccy
        "USD" => COL_USD
        "EUR" => COL_EUR
        "CHF" => COL_CHF
        "GBP" => COL_GBP
        "JPY" => COL_JPY
        "CAD" => COL_CAD
        "AUD" => COL_AUD
        "NZD" => COL_NZD
        "SEK" => COL_SEK
        => neutral_color

f_horizon_days() =>
    switch i_horizon
        "1M"  => 30.0
        "3M"  => 91.0
        "6M"  => 182.0
        => 365.0

f_day_count(string ccy) =>
    switch ccy
        "GBP" => 365.0
        "CAD" => 365.0
        "AUD" => 365.0
        "NZD" => 365.0
        => 360.0

f_broker_markup() =>
    switch i_broker_tier
        "0-100k"  => 1.50
        "100k-1M" => 0.50
        ">1M"     => 0.30
        => 0.0

// data retrieval (18 security calls)

float y_us_2  = nz(request.security("TVC:US02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_de_2  = nz(request.security("TVC:DE02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_ch_2  = nz(request.security("TVC:CH02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_gb_2  = nz(request.security("TVC:GB02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_jp_2  = nz(request.security("TVC:JP02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_ca_2  = nz(request.security("TVC:CA02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_au_2  = nz(request.security("TVC:AU02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_nz_2  = nz(request.security("TVC:NZ02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_se_2  = nz(request.security("TVC:SE02Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

float y_us_10 = nz(request.security("TVC:US10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_de_10 = nz(request.security("TVC:DE10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_ch_10 = nz(request.security("TVC:CH10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_gb_10 = nz(request.security("TVC:GB10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_jp_10 = nz(request.security("TVC:JP10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_ca_10 = nz(request.security("TVC:CA10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_au_10 = nz(request.security("TVC:AU10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_nz_10 = nz(request.security("TVC:NZ10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)
float y_se_10 = nz(request.security("TVC:SE10Y", "D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true), 0.0)

// yield selection by maturity

f_yield(string ccy) =>
    bool use_2y = i_maturity == "2Y"
    switch ccy
        "USD" => use_2y ? y_us_2 : y_us_10
        "EUR" => use_2y ? y_de_2 : y_de_10
        "CHF" => use_2y ? y_ch_2 : y_ch_10
        "GBP" => use_2y ? y_gb_2 : y_gb_10
        "JPY" => use_2y ? y_jp_2 : y_jp_10
        "CAD" => use_2y ? y_ca_2 : y_ca_10
        "AUD" => use_2y ? y_au_2 : y_au_10
        "NZD" => use_2y ? y_nz_2 : y_nz_10
        "SEK" => use_2y ? y_se_2 : y_se_10
        => 0.0

// instrument currency detection

string inst_ccy = syminfo.currency
bool ccy_match  = inst_ccy == i_base_ccy

string[] all_ccy = array.from("USD", "EUR", "CHF", "GBP", "JPY", "CAD", "AUD", "NZD", "SEK")

// data validity: hide currencies whose selected maturity returns the 0.0 fallback
f_has_data(string ccy) =>
    f_yield(ccy) != 0.0

// carry spread calculations

float base_yield = f_yield(i_base_ccy)

float spread_usd = f_yield("USD") - base_yield
float spread_eur = f_yield("EUR") - base_yield
float spread_chf = f_yield("CHF") - base_yield
float spread_gbp = f_yield("GBP") - base_yield
float spread_jpy = f_yield("JPY") - base_yield
float spread_cad = f_yield("CAD") - base_yield
float spread_aud = f_yield("AUD") - base_yield
float spread_nzd = f_yield("NZD") - base_yield
float spread_sek = f_yield("SEK") - base_yield

f_spread(string ccy) =>
    switch ccy
        "USD" => spread_usd
        "EUR" => spread_eur
        "CHF" => spread_chf
        "GBP" => spread_gbp
        "JPY" => spread_jpy
        "CAD" => spread_cad
        "AUD" => spread_aud
        "NZD" => spread_nzd
        "SEK" => spread_sek
        => 0.0

float inst_spread = ccy_match ? 0.0 : f_spread(inst_ccy)

// gross carry rate: broker markup always works against you
float broker_pct    = f_broker_markup()
float gross_carry   = inst_spread + broker_pct
float horizon_days  = f_horizon_days()
float inst_daycount = f_day_count(inst_ccy)

float carry_cost     = i_position * (gross_carry / 100.0) * (horizon_days / inst_daycount)
float break_even_pct = math.abs(gross_carry) * (horizon_days / 365.0)

// statistical context

float inst_spread_pctl = ta.percentrank(inst_spread, 504)

float inst_mu    = ta.sma(inst_spread, 252)
float inst_sd    = ta.stdev(inst_spread, 252)
float inst_upper = inst_mu + inst_sd
float inst_lower = inst_mu - inst_sd

// cumulative carry cost (running total, constant position assumption)

float daily_cost_rate = gross_carry / 100.0 / inst_daycount
var float cumulative_carry = 0.0
if barstate.isconfirmed and not ccy_match
    cumulative_carry += i_position * daily_cost_rate

// visualization

color carry_bg = na
if i_bg_mode == "Carry" and not ccy_match
    carry_bg := inst_spread < 0 ? color.new(bullish_color, i_bg_int) : color.new(bearish_color, i_bg_int)
bgcolor(carry_bg, title="Carry Background")

hline(0.0, "Zero", color=#737373, linestyle=hline.style_solid)

// sigma bands for the active instrument spread
p_upper = plot(not ccy_match ? inst_upper : na, "Upper band", color=color.new(neutral_color, 50), linewidth=1, style=plot.style_line)
p_lower = plot(not ccy_match ? inst_lower : na, "Lower band", color=color.new(neutral_color, 50), linewidth=1, style=plot.style_line)
fill(p_upper, p_lower, color=color.new(neutral_color, 80), title="Sigma band")

// show flags per currency
bool show_usd = i_show_all and i_base_ccy != "USD" and f_has_data("USD")
bool show_eur = i_show_all and i_base_ccy != "EUR" and f_has_data("EUR")
bool show_chf = i_show_all and i_base_ccy != "CHF" and f_has_data("CHF")
bool show_gbp = i_show_all and i_base_ccy != "GBP" and f_has_data("GBP")
bool show_jpy = i_show_all and i_base_ccy != "JPY" and f_has_data("JPY")
bool show_cad = i_show_all and i_base_ccy != "CAD" and f_has_data("CAD")
bool show_aud = i_show_all and i_base_ccy != "AUD" and f_has_data("AUD")
bool show_nzd = i_show_all and i_base_ccy != "NZD" and f_has_data("NZD")
bool show_sek = i_show_all and i_base_ccy != "SEK" and f_has_data("SEK")

// glow layer
plot(i_glow and show_usd ? spread_usd : na, "USD glow", color=color.new(COL_USD, 70), linewidth=i_width + 4)
plot(i_glow and show_eur ? spread_eur : na, "EUR glow", color=color.new(COL_EUR, 70), linewidth=i_width + 4)
plot(i_glow and show_chf ? spread_chf : na, "CHF glow", color=color.new(COL_CHF, 70), linewidth=i_width + 4)
plot(i_glow and show_gbp ? spread_gbp : na, "GBP glow", color=color.new(COL_GBP, 70), linewidth=i_width + 4)
plot(i_glow and show_jpy ? spread_jpy : na, "JPY glow", color=color.new(COL_JPY, 70), linewidth=i_width + 4)
plot(i_glow and show_cad ? spread_cad : na, "CAD glow", color=color.new(COL_CAD, 70), linewidth=i_width + 4)
plot(i_glow and show_aud ? spread_aud : na, "AUD glow", color=color.new(COL_AUD, 70), linewidth=i_width + 4)
plot(i_glow and show_nzd ? spread_nzd : na, "NZD glow", color=color.new(COL_NZD, 70), linewidth=i_width + 4)
plot(i_glow and show_sek ? spread_sek : na, "SEK glow", color=color.new(COL_SEK, 70), linewidth=i_width + 4)

// main carry spread lines: active instrument currency opaque, others faded
color c_usd = inst_ccy == "USD" ? COL_USD : color.new(COL_USD, 0)
color c_eur = inst_ccy == "EUR" ? COL_EUR : color.new(COL_EUR, 0)
color c_chf = inst_ccy == "CHF" ? COL_CHF : color.new(COL_CHF, 0)
color c_gbp = inst_ccy == "GBP" ? COL_GBP : color.new(COL_GBP, 0)
color c_jpy = inst_ccy == "JPY" ? COL_JPY : color.new(COL_JPY, 0)
color c_cad = inst_ccy == "CAD" ? COL_CAD : color.new(COL_CAD, 0)
color c_aud = inst_ccy == "AUD" ? COL_AUD : color.new(COL_AUD, 0)
color c_nzd = inst_ccy == "NZD" ? COL_NZD : color.new(COL_NZD, 0)
color c_sek = inst_ccy == "SEK" ? COL_SEK : color.new(COL_SEK, 0)

plot(show_usd ? spread_usd : na, "USD", color=c_usd, linewidth=i_width)
plot(show_eur ? spread_eur : na, "EUR", color=c_eur, linewidth=i_width)
plot(show_chf ? spread_chf : na, "CHF", color=c_chf, linewidth=i_width)
plot(show_gbp ? spread_gbp : na, "GBP", color=c_gbp, linewidth=i_width)
plot(show_jpy ? spread_jpy : na, "JPY", color=c_jpy, linewidth=i_width)
plot(show_cad ? spread_cad : na, "CAD", color=c_cad, linewidth=i_width)
plot(show_aud ? spread_aud : na, "AUD", color=c_aud, linewidth=i_width)
plot(show_nzd ? spread_nzd : na, "NZD", color=c_nzd, linewidth=i_width)
plot(show_sek ? spread_sek : na, "SEK", color=c_sek, linewidth=i_width)

// candle coloring
color candle_col = na
if i_candles and not ccy_match
    candle_col := inst_spread < 0 ? color.new(bullish_color, i_candle_tr) : color.new(bearish_color, i_candle_tr)
barcolor(candle_col)

// dashboard

if i_dash and barstate.islast
    int n_ccy = 0
    for idx = 0 to array.size(all_ccy) - 1
        if array.get(all_ccy, idx) != i_base_ccy and f_has_data(array.get(all_ccy, idx))
            n_ccy += 1

    int total_rows = 4 + n_ccy + 1
    var table dash = table.new(f_pos(i_dash_pos), 5, total_rows,
         border_width=1, bgcolor=color.new(table_bg, table_tr))
    table.clear(dash, 0, 0, 4, total_rows - 1)

    string sz   = f_sz(i_dash_sz)
    string sz_s = i_dash_sz == "Large" ? size.normal : i_dash_sz == "Normal" ? size.small : size.tiny
    color  hdr  = color.new(header_bg, 20)
    color  tc   = text_color

    int row = 0

    table.cell(dash, 0, row, "CCM", text_color=tc, bgcolor=hdr, text_size=sz)
    string det_str = ccy_match ? "No FX mismatch" : i_base_ccy + " → " + inst_ccy
    table.cell(dash, 1, row, det_str, text_color=ccy_match ? bullish_color : neutral_color, bgcolor=hdr, text_size=sz_s)
    table.cell(dash, 2, row, "", bgcolor=hdr, text_size=sz_s)
    table.cell(dash, 3, row, "", bgcolor=hdr, text_size=sz_s)
    table.cell(dash, 4, row, "", bgcolor=hdr, text_size=sz_s)
    row += 1

    if not ccy_match
        color cost_c = inst_spread < 0 ? bullish_color : inst_spread > 0 ? bearish_color : neutral_color
        color cost_bg_c = color.new(cost_c, 85)

        table.cell(dash, 0, row, "Carry spread", text_color=tc, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 1, row, str.tostring(inst_spread, "#.##") + "%", text_color=cost_c, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 2, row, "Pctl", text_color=tc, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 3, row, str.tostring(inst_spread_pctl, "#") + "%", text_color=cost_c, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 4, row, "", bgcolor=cost_bg_c, text_size=sz_s)
        row += 1

        string cost_label = carry_cost > 0 ? "Est. cost" : "Est. income"
        table.cell(dash, 0, row, cost_label + " (" + i_horizon + ")", text_color=tc, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 1, row, str.tostring(math.abs(carry_cost), "#,###") + " " + inst_ccy, text_color=cost_c, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 2, row, "Break-even", text_color=tc, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 3, row, str.tostring(break_even_pct, "#.##") + "%", text_color=cost_c, bgcolor=cost_bg_c, text_size=sz_s)
        table.cell(dash, 4, row, "", bgcolor=cost_bg_c, text_size=sz_s)
        row += 1
    else
        table.cell(dash, 0, row, "No carry cost", text_color=bullish_color, bgcolor=color.new(bullish_color, 90), text_size=sz_s)
        table.cell(dash, 1, row, "Account and instrument currency match", text_color=bullish_color, bgcolor=color.new(bullish_color, 90), text_size=sz_s)
        table.cell(dash, 2, row, "", bgcolor=color.new(bullish_color, 90), text_size=sz_s)
        table.cell(dash, 3, row, "", bgcolor=color.new(bullish_color, 90), text_size=sz_s)
        table.cell(dash, 4, row, "", bgcolor=color.new(bullish_color, 90), text_size=sz_s)
        row += 1
        row += 1

    table.cell(dash, 0, row, "Currency", text_color=tc, bgcolor=hdr, text_size=sz_s)
    table.cell(dash, 1, row, "Spread", text_color=tc, bgcolor=hdr, text_size=sz_s)
    table.cell(dash, 2, row, "Yield", text_color=tc, bgcolor=hdr, text_size=sz_s)
    table.cell(dash, 3, row, i_horizon + " cost", text_color=tc, bgcolor=hdr, text_size=sz_s)
    table.cell(dash, 4, row, "", bgcolor=hdr, text_size=sz_s)
    row += 1

    for idx = 0 to array.size(all_ccy) - 1
        string ccy = array.get(all_ccy, idx)
        if ccy != i_base_ccy and f_has_data(ccy)
            float sp = f_spread(ccy)
            float yd = f_yield(ccy)
            float bm = f_broker_markup()
            float gr = sp + bm
            float dc = f_day_count(ccy)
            float cost_est = i_position * (gr / 100.0) * (horizon_days / dc)

            color sp_c  = sp < 0 ? bullish_color : sp > 0 ? bearish_color : neutral_color
            color row_bg = color.new(sp_c, 92)
            bool active = ccy == inst_ccy

            string marker = active ? " ◄" : ""
            table.cell(dash, 0, row, ccy + marker, text_color=f_ccy_color(ccy), bgcolor=row_bg, text_size=sz_s)
            table.cell(dash, 1, row, str.tostring(sp, "#.##") + "%", text_color=sp_c, bgcolor=row_bg, text_size=sz_s)
            table.cell(dash, 2, row, str.tostring(yd, "#.##") + "%", text_color=tc, bgcolor=row_bg, text_size=sz_s)
            string cost_str = cost_est > 0 ? "-" + str.tostring(math.abs(cost_est), "#,###") : "+" + str.tostring(math.abs(cost_est), "#,###")
            table.cell(dash, 3, row, cost_str, text_color=sp_c, bgcolor=row_bg, text_size=sz_s)
            table.cell(dash, 4, row, "", bgcolor=row_bg, text_size=sz_s)
            row += 1

// watermark

if i_wm and barstate.islast
    var table wm = table.new(f_pos(i_wm_pos), 1, 3, border_width=0,
         bgcolor=color.new(color.black, 100))

    color wm_tc    = i_dark ? color.new(color.white, 30) : color.new(color.black, 40)
    string wm_sz   = f_sz(i_wm_sz)
    string wm_sz_s = i_wm_sz == "Huge" ? size.large : i_wm_sz == "Large" ? size.normal : size.small

    table.cell(wm, 0, 0, syminfo.ticker + ", " + timeframe.period,
         text_color=wm_tc, text_size=wm_sz, bgcolor=color.new(color.black, 100),
         text_halign=text.align_right)

    string wm_line2 = ccy_match ? "CCM: No FX mismatch" :
         "CCM: " + i_base_ccy + " → " + inst_ccy + " | Spread " + str.tostring(inst_spread, "#.##") + "%"
    table.cell(wm, 0, 1, wm_line2,
         text_color=wm_tc, text_size=wm_sz_s, bgcolor=color.new(color.black, 100),
         text_halign=text.align_right)

    string wm_line3 = ccy_match ? "Account = Instrument" :
         str.tostring(math.abs(carry_cost), "#,###") + " " + inst_ccy + " / " + i_horizon +
         (carry_cost > 0 ? " cost" : " income")
    color wm_c3 = ccy_match ? bullish_color : (carry_cost > 0 ? bearish_color : bullish_color)
    table.cell(wm, 0, 2, wm_line3,
         text_color=color.new(wm_c3, 20), text_size=wm_sz_s, bgcolor=color.new(color.black, 100),
         text_halign=text.align_right)

// alerts

bool spread_extreme_high = inst_spread_pctl > 90 and inst_spread_pctl[1] <= 90
bool spread_extreme_low  = inst_spread_pctl < 10 and inst_spread_pctl[1] >= 10
bool spread_crossed_zero = (inst_spread > 0 and inst_spread[1] <= 0) or (inst_spread < 0 and inst_spread[1] >= 0)

alertcondition(spread_extreme_high and i_alerts, "Carry spread 90th percentile",
     "CCM: Carry spread entered 90th percentile -- historically expensive")
alertcondition(spread_extreme_low and i_alerts, "Carry spread 10th percentile",
     "CCM: Carry spread entered 10th percentile -- historically cheap")
alertcondition(spread_crossed_zero and i_alerts, "Carry spread zero cross",
     "CCM: Carry spread crossed zero line -- direction changed")
````

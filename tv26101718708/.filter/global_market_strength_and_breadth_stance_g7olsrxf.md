# Global Market Strength and Breadth Stance

- url: https://www.tradingview.com/script/G7OlSrxf-Global-Market-Strength-and-Breadth-Stance/
- type: indicator
- pine_id: PUB;3958fe7a6a3d4fada683f1cc41728c86
- version: 22.0

## Description

[b]Introduction[/b]

The Market Strength and Breadth Dashboard is a comprehensive, institutional-grade market monitoring tool designed for swing traders and active investors. Instead of trading in a vacuum, this dashboard scans the internal health of a chosen market across cap sizes, sector leaders, equal-weighted indices, and growth/value proxies. By analyzing multiple dimensions of trend strength and rolling them up into a live dashboard, the indicator calculates an overall Market Stance and provides actionable guidance on Total Open Risk (TOR).

Whether you trade in the US, India, Japan, China, Taiwan, or South Korea, this dashboard provides a top-down view of market breadth so you can trade with the wind at your back.

[url=https://www.tradingview.com/x/qw2AWRpv/]https://www.tradingview.com/x/qw2AWRpv/[/url]

[b]Key Features[/b]

[b]1. Multi-Market & Sector Breadth Coverage[/b]

The dashboard automatically maps a curated list of index benchmarks, equal-weight indices, growth/tech proxies, and sector ETFs based on your selected country:

United States (US): SPY (S&P 500), QQQ (Nasdaq 100), RSP (S&P 500 Equal Weight), IWM (Russell 2000), MDY (S&P MidCap 400), SMH (Semiconductors), IGV (Tech-Software).

India (IN): Nifty 50, Nifty 50 Equal Weight, Nifty 500, Nifty Midcap 100, Nifty Smallcap 100, Nifty IT, Nifty Finance, Nifty Auto, Nifty Banking, Manufacturing, Nifty India Digital.

Japan (JP): Nikkei 225, TOPIX, TOPIX 100, TOPIX Mid 400, Nikkei Mid Small ETF, TOPIX Small Index, Nikkei Semiconductor, Semiconductor ETF, Electric Appliances, TOPIX Machinery.

China (CN): Total Stock Market, Top 300 Index (Weighted & Equal Weight), 50 Large Cap, 500 Mid Cap, 1000 Small Cap, ChiNext 100, Tech/Semis/AI/Biotech.

Taiwan (TW): TAIEX, Top 50 ETF, Mid-Cap 100 ETF, TPEX Weighted Index, Semiconductors Sub-Index, Electronics Sub-Index, Electronic Parts/Components, Market Leader Equal Weight ETF, IT Growth Equal Weight ETF.

South Korea (KR): KOSPI, KOSPI 200, KOSPI Large, KOSPI Mid, KOSPI Small, KOSDAQ, KOSDAQ 150, KOSPI 200 Equal Weight, KQ150 Equal Weight.

[url=https://www.tradingview.com/x/fwCwZqBS/]https://www.tradingview.com/x/fwCwZqBS/[/url]

[b]2. Timeframe-Adaptive Moving Averages[/b]

Moving average lengths are automatically adjusted based on your selected Analysis Timeframe to ensure the technical signals match the trend structure of that horizon:

[b]Daily Timeframe:[/b] 20 SMA (Short-term), 50 SMA (Medium-term), 200 SMA (Long-term / Macro).
[b]Weekly Timeframe:[/b] 10 SMA, 30 SMA, 40 SMA.
[b]Monthly Timeframe:[/b] 3 SMA, 6 SMA, 10 SMA.

[b]3. Advanced Hybrid Trend Engine[/b]

Rather than relying on a single moving average, the dashboard calculates a Hybrid Trend for each index by combining two distinct methodologies:

[b]SMA Ribbon Trend:[/b] Evaluates alignment. A full bullish alignment requires:
Price > SMA 1 > SMA 2 > SMA 3, while a bearish alignment requires:
Price < SMA 1 < SMA 2 < SMA3

[b]Donchian Channel Trend:[/b] Checks price relative to the 20-period Donchian mid-line. If the price is within 15% of the Donchian mid-line, the trend is treated as Sideways (congestion). If it breaks out above or below this corridor, it triggers a trend state.

[b][i]The Hybrid Nuance:[/i][/b] A ticker is only marked in an Uptrend if the Donchian trend is bullish and the SMA Ribbon is not bearish. It is marked in a Downtrend if the Donchian trend is bearish and the SMA Ribbon is not bullish. Otherwise, it is classified as Sideways.

[url=https://www.tradingview.com/x/eBLbhjez/]https://www.tradingview.com/x/eBLbhjez/[/url]

[b]4. Granular Status Classification[/b]

Every monitored index is evaluated and categorized into one of five states:

🟢 Very Bullish: Macro bullish (SMA 2 > SMA 3), short-term bullish (SMA1 > SMA2), price trading above the short-term SMA 1, and the Hybrid Trend is actively upward.

🟢 Bullish: Macro and short-term bullish alignments are in place, price is above 
SMA 1, but the Hybrid Trend has turned sideways.

🔵 Pullback: Macro and short-term bullish alignments are intact, but price has pulled back below the short-term SMA 1 (while holding above the medium-term SMA 2). Ideal for dip-buying setups.

🟡 Caution: Signals are mixed. This occurs during transitional phases, such as when price is below SMA 2 in a macro uptrend, or when price trades above SMA 1 but the macro alignment is bearish (SMA 2 ≤ SMA 3).

🔴 Bearish: Macro bearish alignment (SMA 2 ≤ SMA 3) and the price is below its short-term 
SMA 1.

[b]The Breadth & Stance Engine (Dashboard Footer)[/b]

The bottom row of the dashboard acts as the command center, compiling all individual metrics into market breadth stats and a singular directional bias:

[url=https://www.tradingview.com/x/QRX99PD1/]https://www.tradingview.com/x/QRX99PD1/[/url]

[b]1. Market Stance & Total Open Risk (TOR)[/b]

The dashboard calculates a global market posture based on the state of the primary index (e.g., SPY for US, Nifty 50 for India) and the percentage of overall constructive indices:
[list]
[*][b]Risk-On (Aggressive) | TOR Open (6-8R):[/b] The primary index is Bullish/Very Bullish, ≥ 70% of the market is constructive, and ≤ 10% is Bearish. This is the green light for aggressive long positioning.
[*][b]Risk-On (Selective) | TOR Normal (4-5R):[/b] The primary index is constructive, and ≥ 50% of the market is constructive. Longs are favored, but selectivity and tight setups are required.
[*][b]Risk-Off (Defensive) | TOR Tight (1-2R):[/b] The primary index is bearish or ≥ 50% of the indices are in a Bearish status. Capital should be defensively positioned; focus shifts to short exposure or hedging.
[*][b]Capital Preservation | TOR Cash (0R):[/b] The primary index is Bearish, and ≥ 75% of all indices are in a Bearish status. The system advises sitting in cash.
[*][b]Caution / Neutral | TOR Max 3R: [/b]Outlines range-bound or highly rotational conditions. Open risk should be strictly capped.[/list]
[b]2. Breadth Ratio Columns[/b]

The dashboard displays raw breadth ratios for three structural checkpoints:
[list]
[*]Price > MA1 (Short-term momentum breadth)
[*]MA1 > MA2 (Medium-term structural health)
[*]MA2 > MA3 (Long-term structural alignment)[/list]
[b]Format:[/b] L / S (Long / Short). E.g., 5L / 2S means 5 indices are bullish on that metric, and 2 are bearish.

[b]Color Coding: [/b]Automatically highlights in Green if ≥ 70% of the indices are positive, Red if ≥ 60% are negative, and Yellow for rotational/neutral conditions.

[b]Under the Hood: Pine Script v6 Optimization[/b]

This script has been engineered to prevent chart lag. All calculations are requested dynamically using a single, optimized request.security tuple call per ticker.
[list]
[*][b]No Repainting[/b]: The dashboard is calculated strictly on closed historical bars and the live real-time bar using barstate.islast, ensuring that historical data is not distorted and the dashboard is lightweight.
[*][b]Declarative Layouts[/b]: The UI adapts row heights dynamically based on the number of active indices for the selected country, preventing empty table cells from wasting screen real estate.
[*][b]User Input Settings[/b]
[*][b]Active Market / Country[/b]: Switch between US, Korea, China, Taiwan, Japan, and India.
[*][b]Analysis Timeframe[/b]: Select Daily, Weekly, or Monthly.
[*][b]Table Position[/b]: Choose from 9 positions on your chart canvas.
[*][b]Text Size[/b]: Small, Normal, or Large text configurations.
[*][b]Styling & Colors[/b]: Fully customize table frames, title background, warning cells, risk stances, and text colors to match your dark or light chart theme.[/list]
[url=https://www.tradingview.com/x/18OvRFzr/]https://www.tradingview.com/x/18OvRFzr/[/url]

⚠️ [b]Important Caution & Risk Disclaimer[/b]
Please read and understand the following before incorporating this dashboard into your trading:

[b]Index Decoupling:[/b] Sector weightings in modern index products are often heavily skewed toward mega-cap stocks. An index may print "Very Bullish" while the vast majority of individual mid-and-small-cap stocks are struggling. Always cross-reference index breadth with individual stock scans.

[b]Breadth is a Filter, Not a Trigger: [/b]The dashboard's output (such as "Risk-On" or "Risk-Off") represents a statistical regime filter of market conditions. It is not a direct buy or sell signal. Trade execution must still rely on your own verified setups, trigger criteria, and risk-reward calculations.

[b]Data & Calculation Lag:[/b] Because the dashboard aggregates multiple indices and ETFs, there may be temporary divergences in fast-moving markets or discrepancies between local index data feeds.

[b]No Guarantee of Accuracy:[/b] Historical performance of these filters is not indicative of future results. Market regimes can shift rapidly without warning. You must use your own judgment, manage your trade sizing, and implement hard stops on every position. Never risk more capital than you can afford to lose.

## Source Code

````pine
//@version=6
indicator("Market Strength and Breadth Dashboard", overlay=true)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================

// 1. General & Dashboard Layout Settings
gp_general      = "General & Dashboard Layout"
active_country  = input.string("US", "Market / Country", options=["US", "Korea", "China", "Taiwan", "Japan", "India", "Hong Kong", "Custom"], group=gp_general)
view_mode       = input.string("Market Breadth & Stance", "Dashboard View", options=["Market Breadth & Stance", "Performance Metrics", "Combined View", "Sector Rotation"], group=gp_general)
analysis_tf     = input.string("Auto (Chart)", "Analysis Timeframe", options=["Auto (Chart)", "Daily", "Weekly", "Monthly"], group=gp_general)
table_pos       = input.string("Bottom Left", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=gp_general)
text_size_input = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=gp_general)
compact_view    = input.bool(false, "Compact Mode (Small Screens)", group=gp_general, tooltip="Hides secondary return columns to fit comfortably on small screens, laptops, and split-chart layouts")

show_breadth    = view_mode == "Market Breadth & Stance" or view_mode == "Combined View"
show_perf       = view_mode == "Performance Metrics" or view_mode == "Combined View" or view_mode == "Sector Rotation"
is_combined     = view_mode == "Combined View"
show_rotation   = view_mode == "Sector Rotation"

// 2. Sector Rotation Settings
gp_rotation        = "Sector Rotation Settings"
rank_view_type     = input.string("Composite Strength", "Ranking Method", options=["Composite Strength", "Returns", "Both (Compare)"], group=gp_rotation)
sort_rotation_by   = input.string("Composite Strength Rank", "Sort Sectors By", options=["Composite Strength Rank", "Rotation Stage", "Return Rank", "Daily Rank", "Weekly Rank", "Monthly Rank", "Quarterly Rank", "% YTD", "% Off 52WH"], group=gp_rotation)
rotation_calc_type = input.string("Trailing Rolling", "Calculation Mode", options=["Trailing Rolling", "Calendar (Match Timeframes)"], group=gp_rotation)
show_rank_debug    = input.bool(false, "Show Raw Values in Rank (Debug)", group=gp_rotation)
use_vol_weighting  = input.bool(true, "Factor Volume into Composite Scores", group=gp_rotation, tooltip="When enabled, adds directional volume confirmation: high volume up-days boost scores (+5 pts), high volume down-days penalize (-5 pts), and 5-day volume flow confirms weekly accumulation.")

// Stage Stability Settings (RRG-style smoothing to dampen single-day noise)
sma_gate_band   = input.float(0.5, "20 SMA Gate Tolerance (%)", minval=0.0, maxval=2.0, step=0.25, group=gp_rotation,
     tooltip="Allows price to be up to this % below the 20 SMA before losing bullish badge eligibility. " +
             "0.0 = original hard binary gate. Default 0.5% filters hairline SMA breaks on large-cap ETFs. " +
             "Increase to 1.0–1.5% for more volatile instruments.")
rank_smooth_len = input.int(3, "Rank Smoothing Length", minval=1, maxval=10, group=gp_rotation,
     tooltip="Smooths the daily composite score over N bars before computing daily ranks. " +
             "Higher values = more stable rotation stage labels. Default 3 mirrors RRG-style momentum inertia. " +
             "Set to 1 to disable (original behavior).")
p5d_smooth_len  = input.int(2, "Weekly Return Smoothing", minval=1, maxval=5, group=gp_rotation,
     tooltip="Smooths the 5-day rolling return over N bars before it enters the weekly composite score. " +
             "Set to 1 to disable (original behavior). Default 2 adds gentle inertia to weekly ranks.")

is_cal_mode        = rotation_calc_type == "Calendar (Match Timeframes)"
calc_comp          = rank_view_type == "Composite Strength" or rank_view_type == "Both (Compare)"
calc_ret           = rank_view_type == "Returns" or rank_view_type == "Both (Compare)"

// 3. Performance & Combined View Settings
gp_perf              = "Performance & Combined View Settings"
sort_perf_metric     = input.string("Multi-Period Performance", "Sort Sectors By", options=["None (Default Order)", "Multi-Period Performance", "Short-Term Performance", "% YTD", "% Off 52WH"], group=gp_perf)
sort_perf_order      = input.string("Descending", "Sort Order", options=["Descending", "Ascending"], group=gp_perf)
sort_sectors_by_perf = sort_perf_metric != "None (Default Order)"

// 4. Moving Average Settings
gp_ma              = "Moving Average Settings"
ma_type            = input.string("SMA", "MA Type", options=["SMA", "EMA"], group=gp_ma, tooltip="Moving average formula type applied to breadth and stance calculations")
input_ma1_len      = input.int(20, "Fast MA Length", minval=1, group=gp_ma, tooltip="Fast moving average period on Daily timeframe (default 20)")
input_ma2_len      = input.int(50, "Medium MA Length", minval=1, group=gp_ma, tooltip="Medium moving average period on Daily timeframe (default 50)")
input_ma3_len      = input.int(200, "Slow MA Length", minval=1, group=gp_ma, tooltip="Slow moving average period on Daily timeframe (default 200)")

// Resolves the effective timeframe to run the calculations on:
// - If 'Auto (Chart)', matches chart interval if it is Daily, Weekly, or Monthly.
// - Defaults to 'Daily' for lower (intraday) intervals to prevent excessive security calls.
// - Maps this resolved interval to the standard Pine Script resolution string ("D", "W", "M").
effective_tf = analysis_tf == "Auto (Chart)" ? 
               (timeframe.isdaily ? "Daily" : timeframe.isweekly ? "Weekly" : timeframe.ismonthly ? "Monthly" : "Daily") : 
               analysis_tf

base_tf_string = switch effective_tf
    "Daily"     => "D"
    "Weekly"    => "W"
    "Monthly"   => "M"
    => "D"

tf_string = show_rotation ? "D" : base_tf_string

// 4. Styling & Color Configurations
gp_style          = "Table Styling & Colors"
color_title_bg    = input.color(color.new(color.yellow, 75), "Header Row Color", group=gp_style)
color_body_bg     = input.color(color.new(color.aqua, 85), "Body Row Color", group=gp_style)
color_text        = input.color(color.black, "Text Color", group=gp_style)
color_bg          = input.color(color.white, "Background Color", group=gp_style)

color_frame       = input.color(color.new(color.blue, 0), "Frame Color", group=gp_style)
frame_width       = input.int(2, "Frame Width", group=gp_style)
color_border      = input.color(#363a45, "Border Color", group=gp_style)
border_width      = input.int(1, "Border Width", group=gp_style)

color_pos_bg      = input.color(color.new(color.green, 40), "Positive Color", group=gp_style)
color_warn_bg     = input.color(color.new(#ffeb3b, 40), "Warning Color", group=gp_style)
color_bad_bg      = input.color(color.new(color.red, 40), "Bad Color", group=gp_style)

color_v_bull      = input.color(color.new(#00c853, 40), "Very Bullish / Leader Color", group=gp_style)
color_bull        = input.color(color.new(#a5d6a7, 40), "Bullish / Improving Color", group=gp_style)
color_pb          = input.color(color.new(#00b0ff, 40), "Pullback Color", group=gp_style)
color_bear        = input.color(color.new(#e57373, 40), "Bearish / Laggard Color", group=gp_style)

// 5. Custom Market Tickers (Used when Market / Country is set to Custom)
gp_custom    = "Custom Market Tickers"
dir_tooltip  = "US:\nSPY, RSP, DIA, MDY, IWM, QQQ, XLK, RSPT, SMH, IGV, XLC, XLY, XLF, XLI, XLB, XLE, XLV, XBI, XLP, XLRE, XLU\n\n" +
               "Korea:\nKRX:KOSPI, KRX:KOSPI200, KRX:KOSPI200EW, KRX:KOSPI2, KRX:KOSPI3, KRX:KOSPI4, KRX:KOSDAQ, KRX:KOSDAQ150, KRX:KOSDAQ150EWI, KRX:364980, KRX:KRXSECTOR2, KRX:KRXSECTOR21, KRX:KRXSECTOR1, KRX:KRXSECTOR4, KRX:KRXSECTOR9, KRX:KRXSECTOR10, KRX:KRXSECTOR7, KRX:KRXSECTOR3, KRX:KRXSECTOR19, KRX:KRXSECTOR6\n\n" +
               "China:\nSSE:000300, SZSE:399001, SSE:000888, SSE:000016, SSE:000905, SSE:000852, SSE:000984, SZSE:399006, SSE:000688, SSE:000915, SSE:000914, SSE:000911, SSE:000910, SSE:000909, SSE:000941, SSE:000916, SSE:000913, SSE:000912, SZSE:399997, SSE:000917\n\n" +
               "Taiwan:\nINDEX:TAIEX, TWSE:0050, TWSE:0051, TPEX:IX0043, TWSE:00921, TWSE:00943, TWSE:IX0027, TWSE:IX0028, TWSE:IX0029, TWSE:IX0032, TWSE:IX0030, TWSE:IX0039, TWSE:IX0026, TWSE:IX0024, TWSE:IX0033, TWSE:IX0036, TWSE:IX0021, TWSE:IX0012, TWSE:IX0011, TWSE:IX0016\n\n" +
               "Japan:\nTVC:NI225, TSE:TOPIX, TSE:TOPIX100, TSE:MID400, TSE:SMALL, TSE:T17EAPI, TSE:2644, TSE:T17ISO, TSE:T17M, TSE:T17CWT, TSE:T17ATE, TSE:T17B, TSE:T17FIN, TSE:T17RE, TSE:T17RMC, TSE:T17PHR, TSE:T17FD, TSE:T17RT, TSE:T17EPG, TSE:T17ER\n\n" +
               "India:\nNSE:NIFTY, NSE:NIFTY50EQUALWEIGHT, NSE:CNX500, NSE:CNXMIDCAP, NSE:CNXSMALLCAP, NSE:CNXIT, NSE:NIFTY_IND_DIGITAL, NSE:BANKNIFTY, NSE:CNXPSUBANK, NSE:CNXFINANCE, NSE:CNXAUTO, NSE:NIFTY_REALTY, NSE:NIFTY_INDIA_MFG, NSE:CNXINFRA, NSE:CNXMETAL, NSE:CNXMEDIA, NSE:CNXFMCG, NSE:CNXCONSUMPTION, NSE:CNXPHARMA, NSE:CNXENERGY\n\n" +
               "Hong Kong:\nHSI:HSI, HSI:HSCEI, HSI:HSCI, HSI:HSLI, HSI:HSMI, HSI:HSSI, HKEX:2800, HSI:HSTECH, HSI:HSCI.IT, HSI:HSCI.F, HSI:HSCI.P, HSI:HSCI.I, HSI:HSCI.M, HSI:HSCI.E, HSI:HSCI.C, HSI:HSCI.H, HSI:HSCI.CD, HSI:HSCI.CS, HSI:HSCI.T, HSI:HSCI.U"

custom_key_count = input.int(3, "Custom Benchmark Count", minval=0, maxval=20, group=gp_custom, tooltip="Number of benchmark index slots (starting from Slot 1) before the sector divider and independent ranking")
custom_sym1  = input.symbol("", "Slot 1 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym2  = input.symbol("", "Slot 2 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym3 = input.symbol("", "Slot 3 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym4  = input.symbol("", "Slot 4 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym5  = input.symbol("", "Slot 5 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym6  = input.symbol("", "Slot 6 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym7  = input.symbol("", "Slot 7 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym8  = input.symbol("", "Slot 8 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym9  = input.symbol("", "Slot 9 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym10 = input.symbol("", "Slot 10 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym11 = input.symbol("", "Slot 11 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym12 = input.symbol("", "Slot 12 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym13 = input.symbol("", "Slot 13 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym14 = input.symbol("", "Slot 14 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym15 = input.symbol("", "Slot 15 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym16 = input.symbol("", "Slot 16 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym17 = input.symbol("", "Slot 17 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym18 = input.symbol("", "Slot 18 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym19 = input.symbol("", "Slot 19 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym20 = input.symbol("", "Slot 20 Ticker", group=gp_custom, tooltip=dir_tooltip)
custom_sym21 = input.symbol("", "Slot 21 Ticker", group=gp_custom, tooltip=dir_tooltip)

// ==========================================
// 2. PREDEFINED MARKET UNIVERSES & SYMBOL MAPPINGS
// ==========================================

// Mapping helper for display names of predefined tickers
f_get_predefined_name(sym) =>
    clean_sym = str.replace_all(sym, "$", "")
    switch clean_sym
        "SPY"                     => "S&P 500"
        "QQQ"                     => "Nasdaq 100"
        "RSP"                     => "S&P 500 EW"
        "IWM"                     => "Russell 2000"
        "MDY"                     => "S&P MidCap 400"
        "SMH"                     => "Semiconductors"
        "IGV"                     => "Tech-Software"
        "DIA"                     => "Dow Jones"
        "XLK"                     => "Technology"
        "RSPT"                    => "Equal Weight Tech"
        "XLC"                     => "Communication Services"
        "XLY"                     => "Consumer Discretionary"
        "XLF"                     => "Financials"
        "XLI"                     => "Industrials"
        "XLB"                     => "Materials"
        "XLE"                     => "Energy"
        "XLV"                     => "Health Care"
        "XBI"                     => "Biotechnology"
        "XLP"                     => "Consumer Staples"
        "XLRE"                    => "Real Estate"
        "XLU"                     => "Utilities"
        "KRX:KOSPI"               => "KOSPI"
        "KRX:KOSPI200"            => "KOSPI 200"
        "KRX:KOSPI2"              => "KOSPI Large"
        "KRX:KOSPI3"              => "KOSPI Mid"
        "KRX:KOSPI4"              => "KOSPI Small"
        "KRX:KOSDAQ"              => "KOSDAQ"
        "KRX:KOSDAQ150"           => "KOSDAQ 150"
        "KRX:KOSPI200EW"          => "KOSPI 200 EW"
        "KRX:KOSDAQ150EWI"        => "KQ150EWI"
        "KRX:KRXSECTOR21"         => "KRX IT"
        "KRX:KRXSECTOR2"          => "KRX Semiconductors"
        "KRX:364980"              => "Secondary Battery ETF"
        "KRX:KRXSECTOR1"          => "KRX Automobiles"
        "KRX:KRXSECTOR4"          => "KRX Financials"
        "KRX:KRXSECTOR3"          => "KRX Health Care"
        "KRX:KRXSECTOR6"          => "KRX Energy & Chemicals"
        "KRX:KRXSECTOR7"          => "KRX Steels"
        "KRX:KRXSECTOR9"          => "KRX Media & Telecom"
        "KRX:KRXSECTOR10"         => "KRX Construction"
        "KRX:KRXSECTOR19"         => "KRX Consumer Staples"
        "SZSE:399001"             => "Total Stock Market"
        "SSE:000300"              => "Top 300 Index (Weighted)"
        "SSE:000984"              => "Top 300 Index (Equal Weight)"
        "SSE:000888"              => "CSI 800 Index"
        "SSE:000016"              => "50 Large Cap"
        "SSE:000905"              => "500 Mid Cap"
        "SSE:000852"              => "1000 Small Cap"
        "SZSE:399006"             => "ChiNext 100 Growth, Energy, Health"
        "SSE:000688"              => "Technology, Semis, AI, Biotech, Manufacturing"
        "SSE:000941"              => "CSI New Energy Index"
        "SZSE:399997"             => "CSI Liquor Index"
        "SSE:000915"              => "CSI IT Index"
        "SSE:000914"              => "CSI Financials Index"
        "SSE:000911"              => "CSI Consumer Discretionary Index"
        "SSE:000910"              => "CSI Industrials Index"
        "SSE:000909"              => "CSI Materials Index"
        "SSE:000916"              => "CSI Telecommunication Services Index"
        "SSE:000913"              => "CSI Health Care Index"
        "SSE:000912"              => "CSI Consumer Staples Index"
        "SSE:000917"              => "CSI Utilities Index"
        "INDEX:TAIEX"             => "Taiwan Stock Exchange"
        "TWSE:0050"               => "Yuanta/P-shares Taiwan Top 50 ETF"
        "TWSE:0051"               => "Yuanta Taiwan Mid-Cap 100 ETF"
        "TPEX:IX0043"             => "TPEX CAPITALIZATION WEIGHTED STOCK INDEX"
        "TWSE:IX0028"             => "TAIEX Semiconductors Sub-Index"
        "TWSE:IX0027"             => "TAIEX Electronics Sub-Index"
        "TWSE:IX0032"             => "TAIEX Electronic Parts/Components Sub-Index"
        "TWSE:IX0029"             => "TAIEX Computer & Peripheral Equipment Sub-Index"
        "TWSE:IX0030"             => "TAIEX Optoelectronic Sub-Index"
        "TWSE:IX0039"             => "TAIEX Finance and Insurance Sub-Index"
        "TWSE:IX0026"             => "TAIEX Automobile Sub-Index"
        "TWSE:IX0024"             => "TAIEX Iron and Steel Sub-Index"
        "TWSE:IX0033"             => "TAIEX Electronic Products Distribution Sub-Index"
        "TWSE:IX0036"             => "TAIEX Building Materials and Construction Sub-Index"
        "TWSE:IX0021"             => "TAIEX Biotechnology and Medical Care Sub-Index"
        "TWSE:IX0012"             => "TAIEX Plastics Sub-Index"
        "TWSE:IX0011"             => "TAIEX Food Sub-Index"
        "TWSE:IX0016"             => "TAIEX Textiles Sub-Index"
        "TWSE:00921"              => "Mega Taiwan Market Leader Dividend Equal Weight ETF"
        "TWSE:00943"              => "Mega Taiwan IT Growth and High Dividend Equal Weight ETF"
        "TVC:NI225"               => "Nikkei 225 Index"
        "TSE:TOPIX"               => "Tokyo Stock Price Index"
        "TSE:TOPIX100"            => "TOPIX 100 Index"
        "TSE:MID400"              => "TOPIX Mid 400 Index"
        "TSE:1493"                => "Nikkei Mid Small ETF"
        "TSE:SMALL"               => "TOPIX Small Index"
        "TSE:213A"                => "Nikkei Semiconductor Stock ETF"
        "TSE:2644"                => "Semiconductor ETF"
        "TSE:T17EAPI"             => "Electric Appliances & Precision Instruments"
        "TSE:T17M"                => "TOPIX Machinery"
        "TSE:1629"                => "Wholesale Trade"
        "TSE:1622"                => "Transportation Equipment"
        "TSE:T17B"                => "TOPIX Banks"
        "NSE:NIFTY"               => "Nifty 50"
        "NSE:NIFTY50EQUALWEIGHT"  => "Nifty 50 Equal Weight"
        "NSE:CNX500"              => "Nifty 500"
        "NSE:CNXMIDCAP"           => "Nifty Midcap 100"
        "NSE:CNXSMALLCAP"         => "Nifty Smallcap 100"
        "NSE:CNXIT"               => "Nifty IT"
        "NSE:CNXFINANCE"          => "Nifty Finance"
        "NSE:CNXAUTO"             => "Nifty Auto"
        "NSE:BANKNIFTY"           => "Nifty Banking"
        "NSE:NIFTY_REALTY"        => "Nifty Realty"
        "NSE:NIFTY_INDIA_MFG"     => "Manufacturing"
        "NSE:NIFTY_IND_DIGITAL"   => "Nifty India Digital"
        "NSE:CNXFMCG"             => "Nifty FMCG"
        "NSE:CNXMETAL"            => "Nifty Metal"
        "NSE:CNXENERGY"           => "Nifty Energy"
        "NSE:CNXINFRA"            => "Nifty Infrastructure"
        "NSE:CNXMEDIA"            => "Nifty Media"
        "NSE:CNXPSUBANK"          => "Nifty PSU Bank"
        "NSE:CNXCONSUMPTION"      => "Nifty Consumption"
        "NSE:CNXPHARMA"           => "Nifty Pharma"
        "HSI:HSI"                 => "Hang Seng Index"
        "HSI:HSCEI"               => "Hang Seng China Enterprises"
        "HSI:HSCI"                => "Hang Seng Composite Index"
        "HSI:HSLI"                => "Hang Seng Composite LargeCap"
        "HSI:HSMI"                => "Hang Seng Composite MidCap"
        "HSI:HSSI"                => "Hang Seng Composite SmallCap"
        "HKEX:2800"               => "Tracker Fund of Hong Kong"
        "HSI:HSTECH"              => "Hang Seng TECH Index"
        "HSI:HSCI.IT"             => "Hang Seng IT Sector Index"
        "HSI:HSCI.F"              => "Hang Seng Financials Sector"
        "HSI:HSCI.P"              => "Hang Seng Properties & Construction"
        "HSI:HSCI.I"              => "Hang Seng Industrials Sector"
        "HSI:HSCI.M"              => "Hang Seng Materials Sector"
        "HSI:HSCI.E"              => "Hang Seng Energy Sector"
        "HSI:HSCI.C"              => "Hang Seng Conglomerates Sector"
        "HSI:HSCI.H"              => "Hang Seng Healthcare Sector"
        "HSI:HSCI.CD"             => "Hang Seng Consumer Discretionary"
        "HSI:HSCI.CS"             => "Hang Seng Consumer Staples"
        "HSI:HSCI.T"              => "Hang Seng Telecommunications"
        "HSI:HSCI.U"              => "Hang Seng Utilities Sector"
        => ""

f_get_sym(country, idx) =>
    switch country
        "US" =>
            switch idx
                0 => "SPY"
                1 => "RSP"
                2 => "DIA"
                3 => "MDY"
                4 => "IWM"
                5 => "QQQ"
                6 => "XLK"
                7 => "RSPT"
                8 => "SMH"
                9 => "IGV"
                10 => "XLC"
                11 => "XLY"
                12 => "XLF"
                13 => "XLI"
                14 => "XLB"
                15 => "XLE"
                16 => "XLV"
                17 => "XBI"
                18 => "XLP"
                19 => "XLRE"
                20 => "XLU"
                => ""
        "Korea" =>
            switch idx
                0 => "KRX:KOSPI"
                1 => "KRX:KOSPI200"
                2 => "KRX:KOSPI200EW"
                3 => "KRX:KOSPI2"
                4 => "KRX:KOSPI3"
                5 => "KRX:KOSPI4"
                6 => "KRX:KOSDAQ"
                7 => "KRX:KOSDAQ150"
                8 => "KRX:KOSDAQ150EWI"
                9 => "KRX:364980"
                10 => "KRX:KRXSECTOR2"
                11 => "KRX:KRXSECTOR21"
                12 => "KRX:KRXSECTOR1"
                13 => "KRX:KRXSECTOR4"
                14 => "KRX:KRXSECTOR9"
                15 => "KRX:KRXSECTOR10"
                16 => "KRX:KRXSECTOR7"
                17 => "KRX:KRXSECTOR3"
                18 => "KRX:KRXSECTOR19"
                19 => "KRX:KRXSECTOR6"
                => ""
        "China" =>
            switch idx
                0 => "SSE:000300"
                1 => "SZSE:399001"
                2 => "SSE:000888"
                3 => "SSE:000016"
                4 => "SSE:000905"
                5 => "SSE:000852"
                6 => "SSE:000984"
                7 => "SZSE:399006"
                8 => "SSE:000688"
                9 => "SSE:000915"
                10 => "SSE:000914"
                11 => "SSE:000911"
                12 => "SSE:000910"
                13 => "SSE:000909"
                14 => "SSE:000941"
                15 => "SSE:000916"
                16 => "SSE:000913"
                17 => "SSE:000912"
                18 => "SZSE:399997"
                19 => "SSE:000917"
                => ""
        "Taiwan" =>
            switch idx
                0 => "INDEX:TAIEX"
                1 => "TWSE:0050"
                2 => "TWSE:0051"
                3 => "TPEX:IX0043"
                4 => "TWSE:00921"
                5 => "TWSE:00943"
                6 => "TWSE:IX0027"
                7 => "TWSE:IX0028"
                8 => "TWSE:IX0029"
                9 => "TWSE:IX0032"
                10 => "TWSE:IX0030"
                11 => "TWSE:IX0039"
                12 => "TWSE:IX0026"
                13 => "TWSE:IX0024"
                14 => "TWSE:IX0033"
                15 => "TWSE:IX0036"
                16 => "TWSE:IX0021"
                17 => "TWSE:IX0012"
                18 => "TWSE:IX0011"
                19 => "TWSE:IX0016"
                => ""
        "Japan" =>
            switch idx
                0 => "TVC:NI225"
                1 => "TSE:TOPIX"
                2 => "TSE:TOPIX100"
                3 => "TSE:MID400"
                4 => "TSE:SMALL"
                5 => "TSE:T17EAPI"
                6 => "TSE:2644"
                7 => "TSE:T17ISO"
                8 => "TSE:T17M"
                9 => "TSE:T17CWT"
                10 => "TSE:T17ATE"
                11 => "TSE:T17B"
                12 => "TSE:T17FIN"
                13 => "TSE:T17RE"
                14 => "TSE:T17RMC"
                15 => "TSE:T17PHR"
                16 => "TSE:T17FD"
                17 => "TSE:T17RT"
                18 => "TSE:T17EPG"
                19 => "TSE:T17ER"
                => ""
        "India" =>
            switch idx
                0 => "NSE:NIFTY"
                1 => "NSE:NIFTY50EQUALWEIGHT"
                2 => "NSE:CNX500"
                3 => "NSE:CNXMIDCAP"
                4 => "NSE:CNXSMALLCAP"
                5 => "NSE:CNXIT"
                6 => "NSE:NIFTY_IND_DIGITAL"
                7 => "NSE:BANKNIFTY"
                8 => "NSE:CNXPSUBANK"
                9 => "NSE:CNXFINANCE"
                10 => "NSE:CNXAUTO"
                11 => "NSE:NIFTY_REALTY"
                12 => "NSE:NIFTY_INDIA_MFG"
                13 => "NSE:CNXINFRA"
                14 => "NSE:CNXMETAL"
                15 => "NSE:CNXMEDIA"
                16 => "NSE:CNXFMCG"
                17 => "NSE:CNXCONSUMPTION"
                18 => "NSE:CNXPHARMA"
                19 => "NSE:CNXENERGY"
                => ""
        "Hong Kong" =>
            switch idx
                0 => "HSI:HSI"
                1 => "HSI:HSCEI"
                2 => "HSI:HSCI"
                3 => "HSI:HSLI"
                4 => "HSI:HSMI"
                5 => "HSI:HSSI"
                6 => "HKEX:2800"
                7 => "HSI:HSTECH"
                8 => "HSI:HSCI.IT"
                9 => "HSI:HSCI.F"
                10 => "HSI:HSCI.P"
                11 => "HSI:HSCI.I"
                12 => "HSI:HSCI.M"
                13 => "HSI:HSCI.E"
                14 => "HSI:HSCI.C"
                15 => "HSI:HSCI.H"
                16 => "HSI:HSCI.CD"
                17 => "HSI:HSCI.CS"
                18 => "HSI:HSCI.T"
                19 => "HSI:HSCI.U"
                => ""
        "Custom" =>
            switch idx
                0 => custom_sym1
                1 => custom_sym2
                2 => custom_sym3
                3 => custom_sym4
                4 => custom_sym5
                5 => custom_sym6
                6 => custom_sym7
                7 => custom_sym8
                8 => custom_sym9
                9 => custom_sym10
                10 => custom_sym11
                11 => custom_sym12
                12 => custom_sym13
                13 => custom_sym14
                14 => custom_sym15
                15 => custom_sym16
                16 => custom_sym17
                17 => custom_sym18
                18 => custom_sym19
                19 => custom_sym20
                20 => custom_sym21
                => ""
        => ""

f_get_name(country, idx, sym) =>
    switch country
        "US" =>
            switch idx
                0 => "S&P 500"
                1 => "S&P 500 EW"
                2 => "Dow Jones"
                3 => "S&P MidCap 400"
                4 => "Russell 2000"
                5 => "Nasdaq 100"
                6 => "Technology"
                7 => "Equal Weight Tech"
                8 => "Semiconductors"
                9 => "Tech-Software"
                10 => "Communication Services"
                11 => "Consumer Discretionary"
                12 => "Financials"
                13 => "Industrials"
                14 => "Materials"
                15 => "Energy"
                16 => "Health Care"
                17 => "Biotechnology"
                18 => "Consumer Staples"
                19 => "Real Estate"
                20 => "Utilities"
                => ""
        "Korea" =>
            switch idx
                0 => "KOSPI"
                1 => "KOSPI 200"
                2 => "KOSPI 200 EW"
                3 => "KOSPI Large"
                4 => "KOSPI Mid"
                5 => "KOSPI Small"
                6 => "KOSDAQ"
                7 => "KOSDAQ 150"
                8 => "KQ150EWI"
                9 => "Secondary Battery ETF"
                10 => "KRX Semiconductors"
                11 => "KRX IT"
                12 => "KRX Automobiles"
                13 => "KRX Financials"
                14 => "KRX Media & Telecom"
                15 => "KRX Construction"
                16 => "KRX Steels"
                17 => "KRX Health Care"
                18 => "KRX Consumer Staples"
                19 => "KRX Energy & Chemicals"
                => ""
        "China" =>
            switch idx
                0 => "Top 300 Index (Weighted)"
                1 => "Total Stock Market"
                2 => "CSI 800 Index"
                3 => "50 Large Cap"
                4 => "500 Mid Cap"
                5 => "1000 Small Cap"
                6 => "Top 300 Index (Equal Weight)"
                7 => "ChiNext 100 Growth, Energy, Health"
                8 => "Technology, Semis, AI, Biotech, Manufacturing"
                9 => "CSI IT Index"
                10 => "CSI Financials Index"
                11 => "CSI Consumer Discretionary Index"
                12 => "CSI Industrials Index"
                13 => "CSI Materials Index"
                14 => "CSI New Energy Index"
                15 => "CSI Telecommunication Services Index"
                16 => "CSI Health Care Index"
                17 => "CSI Consumer Staples Index"
                18 => "CSI Liquor Index"
                19 => "CSI Utilities Index"
                => ""
        "Taiwan" =>
            switch idx
                0 => "Taiwan Stock Exchange"
                1 => "Yuanta/P-shares Taiwan Top 50 ETF"
                2 => "Yuanta Taiwan Mid-Cap 100 ETF"
                3 => "TPEX Cap-Weighted Index"
                4 => "Mega Taiwan Leader Dividend EW ETF"
                5 => "Mega Taiwan IT Growth Dividend EW ETF"
                6 => "TAIEX Electronics Sub-Index"
                7 => "TAIEX Semiconductors Sub-Index"
                8 => "TAIEX Computer & Peripheral Sub-Index"
                9 => "TAIEX Electronic Parts/Components Sub-Index"
                10 => "TAIEX Optoelectronic Sub-Index"
                11 => "TAIEX Finance and Insurance Sub-Index"
                12 => "TAIEX Automobile Sub-Index"
                13 => "TAIEX Iron and Steel Sub-Index"
                14 => "TAIEX Electronic Products Distribution"
                15 => "TAIEX Building Materials & Construction"
                16 => "TAIEX Biotech & Medical Care"
                17 => "TAIEX Plastics Sub-Index"
                18 => "TAIEX Food Sub-Index"
                19 => "TAIEX Textiles Sub-Index"
                => ""
        "Japan" =>
            switch idx
                0 => "Nikkei 225 Index"
                1 => "Tokyo Stock Price Index"
                2 => "TOPIX 100 Index"
                3 => "TOPIX Mid 400 Index"
                4 => "TOPIX Small Index"
                5 => "Electric Appliances & Precision Instruments"
                6 => "Semiconductor ETF"
                7 => "IT & Services, Others"
                8 => "TOPIX Machinery"
                9 => "Commercial & Wholesale Trade"
                10 => "Automobiles & Trans. Equip."
                11 => "TOPIX Banks"
                12 => "Financials (ex-Banks)"
                13 => "Real Estate"
                14 => "Raw Materials & Chemicals"
                15 => "Pharmaceutical"
                16 => "Foods"
                17 => "Retail Trade"
                18 => "Electric Power & Gas"
                19 => "Energy Resources"
                => ""
        "India" =>
            switch idx
                0 => "Nifty 50"
                1 => "Nifty 50 Equal Weight"
                2 => "Nifty 500"
                3 => "Nifty Midcap 100"
                4 => "Nifty Smallcap 100"
                5 => "Nifty IT"
                6 => "Nifty India Digital"
                7 => "Nifty Banking"
                8 => "Nifty PSU Bank"
                9 => "Nifty Finance"
                10 => "Nifty Auto"
                11 => "Nifty Realty"
                12 => "Manufacturing"
                13 => "Nifty Infrastructure"
                14 => "Nifty Metal"
                15 => "Nifty Media"
                16 => "Nifty FMCG"
                17 => "Nifty Consumption"
                18 => "Nifty Pharma"
                19 => "Nifty Energy"
                => ""
        "Hong Kong" =>
            switch idx
                0 => "Hang Seng Index"
                1 => "Hang Seng China Enterprises"
                2 => "Hang Seng Composite Index"
                3 => "Hang Seng Composite LargeCap"
                4 => "Hang Seng Composite MidCap"
                5 => "Hang Seng Composite SmallCap"
                6 => "Tracker Fund of Hong Kong"
                7 => "Hang Seng TECH Index"
                8 => "Hang Seng IT Sector Index"
                9 => "Hang Seng Financials Sector"
                10 => "Hang Seng Properties & Construction"
                11 => "Hang Seng Industrials Sector"
                12 => "Hang Seng Materials Sector"
                13 => "Hang Seng Energy Sector"
                14 => "Hang Seng Conglomerates Sector"
                15 => "Hang Seng Healthcare Sector"
                16 => "Hang Seng Consumer Discretionary"
                17 => "Hang Seng Consumer Staples"
                18 => "Hang Seng Telecommunications"
                19 => "Hang Seng Utilities Sector"
                => ""
        "Custom" => f_get_predefined_name(sym)
        => ""

f_get_key_count(country) =>
    switch country
        "US"        => 6
        "Korea"     => 9
        "China"     => 7
        "Taiwan"    => 5
        "Japan"     => 5
        "India"     => 5
        "Hong Kong" => 7
        "Custom"    => custom_key_count
        => 0

// User-Defined Types (UDT) for Structured Market Data (Pine Script v6)
type SymbolRaw
    float close_val
    float sma_1
    float sma_2
    float sma_3
    float hybrid_val
    float er_val
    int   bar_time
    float pct_1d        // raw 1D return — used for display column only
    float pct_1d_ema3   // 3-bar EMA of 1D return — used in daily composite scoring only
    float pct_5d        // raw 5D return — used for display column only
    float pct_5d_smooth // EMA-smoothed 5D return — used in weekly composite scoring only
    float pct_21d
    float pct_63d
    float pct_off_52w
    float pct_ytd
    float rvol
    float atr_pct       // 14-period ATR % for volatility normalization
    float vol_flow_5d   // 5-day up/down volume flow ratio [-1.0 to 1.0]
    bool  has_vol       // true if valid volume data is present

type SymbolItem
    string    sym
    string    name
    SymbolRaw raw
    bool      is_active

// ==========================================
// 3. CORE ANALYTICAL HELPERS & SCORING MODELS
// ==========================================

f_get_position(pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

f_get_text_size(sz) =>
    switch sz
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_set_cell(tbl, col, row, txt, text_col, bg_col, sz_str, align_str) =>
    sz = f_get_text_size(sz_str)
    align = align_str == "left" ? text.align_left : align_str == "right" ? text.align_right : text.align_center
    table.cell(tbl, col, row, txt, text_color=text_col, bgcolor=bg_col, text_size=sz, text_halign=align, text_valign=text.align_center)

f_set_cell_bold(tbl, col, row, txt, text_col, bg_col, sz_str, align_str) =>
    sz = f_get_text_size(sz_str)
    align = align_str == "left" ? text.align_left : align_str == "right" ? text.align_right : text.align_center
    table.cell(tbl, col, row, txt, text_color=text_col, bgcolor=bg_col, text_size=sz, text_halign=align, text_valign=text.align_center, text_formatting=text.format_bold)

f_render_cell(tbl, col, row, txt, text_col, bg_col, sz_str, align_str, is_bold) =>
    if is_bold
        f_set_cell_bold(tbl, col, row, txt, text_col, bg_col, sz_str, align_str)
    else
        f_set_cell(tbl, col, row, txt, text_col, bg_col, sz_str, align_str)

// Ticker Equality & Alias Match Helper:
// - Direct matches return true immediately.
// - Explicitly handles known Chinese/Taiwanese index alias pairs (e.g. 000688 <-> STAR50).
f_tickers_are_equal(t1, t2) =>
    bool eq = false
    if t1 == t2
        eq := true
    else if (t1 == "000688" and t2 == "STAR50") or (t1 == "STAR50" and t2 == "000688")
        eq := true
    else if (t1 == "000300" and t2 == "CSI300") or (t1 == "CSI300" and t2 == "000300")
        eq := true
    else if (t1 == "399006" and t2 == "CHINEXT") or (t1 == "CHINEXT" and t2 == "399006")
        eq := true
    else if (t1 == "000016" and t2 == "SSE50") or (t1 == "SSE50" and t2 == "000016")
        eq := true
    else if (t1 == "000905" and t2 == "CSI500") or (t1 == "CSI500" and t2 == "000905")
        eq := true
    else if (t1 == "TAIEX" and t2 == "IX0001") or (t1 == "IX0001" and t2 == "TAIEX")
        eq := true
    eq

// Chart Symbol Matching Logic:
// - Standardizes strings by converting to uppercase and removing spaces.
// - Compares table tickers with the chart's tickerid (e.g. NASDAQ:QQQ) or ticker (e.g. QQQ).
// - If the table ticker doesn't match directly, it handles prefix mismatch cases (e.g., matching QQQ with NASDAQ:QQQ)
//   to identify if the row corresponds to the active chart symbol.
f_is_ticker_match(sym_in_table) =>
    s = str.upper(str.replace_all(str.replace_all(sym_in_table, " ", ""), "$", ""))
    curr_id = not na(syminfo.tickerid) ? str.upper(str.replace_all(str.replace_all(syminfo.tickerid, " ", ""), "$", "")) : ""
    curr_tick = not na(syminfo.ticker) ? str.upper(str.replace_all(str.replace_all(syminfo.ticker, " ", ""), "$", "")) : ""
    curr_prefix = not na(syminfo.prefix) ? str.upper(str.replace_all(str.replace_all(syminfo.prefix, " ", ""), "$", "")) : ""
    
    is_match = (s == curr_id or s == curr_tick)
    if not is_match
        if str.contains(s, ":")
            parts = str.split(s, ":")
            if array.size(parts) >= 2
                tbl_prefix = array.get(parts, 0)
                tbl_ticker = array.get(parts, 1)
                
                // Helper expression to strip delay suffixes (e.g. SSE_DLY -> SSE, SZSE_DLY -> SZSE)
                p_tbl = str.replace_all(tbl_prefix, "_DLY", "")
                p_curr = str.replace_all(curr_prefix, "_DLY", "")
                
                // Single-line prefix normalizations to avoid any multiline parser continuation limitations
                tbl_norm = (p_tbl == "SSE" or p_tbl == "SHSE" or p_tbl == "SHA" or p_tbl == "SH") ? "SHSE" : (p_tbl == "SZSE" or p_tbl == "SZ" or p_tbl == "SZN") ? "SZSE" : (p_tbl == "TSE" or p_tbl == "JPX") ? "TSE" : (p_tbl == "HSI" or p_tbl == "HKEX") ? "HKEX" : p_tbl
                curr_norm = (p_curr == "SSE" or p_curr == "SHSE" or p_curr == "SHA" or p_curr == "SH") ? "SHSE" : (p_curr == "SZSE" or p_curr == "SZ" or p_curr == "SZN") ? "SZSE" : (p_curr == "TSE" or p_curr == "JPX") ? "TSE" : (p_curr == "HSI" or p_curr == "HKEX") ? "HKEX" : p_curr
                               
                is_match := f_tickers_are_equal(tbl_ticker, curr_tick) and (tbl_norm == curr_norm or tbl_prefix == "" or curr_prefix == "")
        else
            string curr_id_tick = ""
            if str.contains(curr_id, ":")
                c_parts = str.split(curr_id, ":")
                if array.size(c_parts) >= 2
                    curr_id_tick := array.get(c_parts, array.size(c_parts) - 1)
            is_match := f_tickers_are_equal(s, curr_tick) or (curr_id_tick != "" and f_tickers_are_equal(s, curr_id_tick))
    is_match

f_get_tf_label(tf_name) =>
    switch tf_name
        "Daily"     => "DTF"
        "Weekly"    => "WTF"
        "Monthly"   => "MTF"
        => "DTF"

f_get_ratio_bg(lng, shrt, pos_color, warn_color, bad_color) =>
    int total = lng + shrt
    color bg = warn_color
    if total > 0
        float pct_lng = lng * 100.0 / total
        float pct_shrt = shrt * 100.0 / total
        if pct_lng >= 70.0
            bg := pos_color
        else if pct_shrt >= 60.0
            bg := bad_color
        else
            bg := warn_color
    bg


// --- Dynamic Runtime State Arrays (Populated on barstate.islast) ---
var string[] act_syms  = array.new_string()
var string[] act_names = array.new_string()
var float[] act_c     = array.new_float()
var float[] act_s20   = array.new_float()
var float[] act_s50   = array.new_float()
var float[] act_s200  = array.new_float()
var float[] act_hy    = array.new_float()
var float[] act_er    = array.new_float()
var float[] act_p1d   = array.new_float()
var float[] act_p1d_ema3   = array.new_float()  // 3-bar EMA of 1D return (Change 1)
var float[] act_p5d   = array.new_float()
var float[] act_p5d_smooth = array.new_float()  // EMA-smoothed 5D return (Change 4)
var float[] act_p21d  = array.new_float()
var float[] act_p63d  = array.new_float()
var float[] act_p52h  = array.new_float()
var float[] act_pytd  = array.new_float()
var float[] act_rvol  = array.new_float()
var float[] act_atr_pct     = array.new_float()
var float[] act_vol_flow_5d = array.new_float()
var bool[]  act_has_vol     = array.new_bool()

// --- Sector Rotation & Multi-Timeframe Ranking State Arrays ---
// rank_ret_*: Pure percentage return ranks (1 to N) across Daily, Weekly, Monthly, and Quarterly horizons.
// act_comp_*: Multi-factor composite strength scores (0 to 100+ points) across horizons.
// rank_comp_*: Composite strength score ranks (1 to N) across horizons.
// flow_badges: Qualitative rotation lifecycle stage badges (e.g. Core Leader, Emerging, Improving).
// flow_colors: Cell background colors corresponding to the rotation stage.
// flow_scores: Numerical hierarchy scores (100 to 700) used for sorting sectors by Rotation Stage.
// sort_keys: Dynamic sorting keys populated based on active 'Sort Sectors By' selection.
var int[] rank_ret_d     = array.new_int(21, 0)
var int[] rank_ret_w     = array.new_int(21, 0)
var int[] rank_ret_m     = array.new_int(21, 0)
var int[] rank_ret_q     = array.new_int(21, 0)

var float[] act_comp_d   = array.new_float(21, 0.0)
var float[] act_comp_d_smooth = array.new_float(21, 0.0)  // EMA-smoothed daily scores for rank computation (Change 3)
var float[] act_comp_w   = array.new_float(21, 0.0)
var float[] act_comp_m   = array.new_float(21, 0.0)
var float[] act_comp_q   = array.new_float(21, 0.0)
var float[] act_comp_master = array.new_float(21, 0.0)

var int[] rank_comp_d    = array.new_int(21, 0)
var int[] rank_comp_w    = array.new_int(21, 0)
var int[] rank_comp_m    = array.new_int(21, 0)
var int[] rank_comp_q    = array.new_int(21, 0)
var int[] rank_comp_master = array.new_int(21, 0)

var int[] rank_shift     = array.new_int(21, 0)
var string[] flow_badges = array.new_string(21, "")
var color[] flow_colors  = array.new_color(21, na)
var float[] flow_scores  = array.new_float(21, 0.0)
var float[] sort_keys    = array.new_float(21, 0.0)

// Persistent state tracking for real-time alerts
var string prev_country       = ""
var string prev_stance        = ""
var string[] prev_flow_badges = array.new_string(21, "")
var bool alerts_initialized   = false

// Series trigger flags for native TradingView alertcondition dialog
bool cond_stance_shift = false
bool cond_sector_rot   = false

var string[] sma_statuses = array.new_string(21, "")
var string[] sma50_statuses = array.new_string(21, "")
var string[] sma200_statuses = array.new_string(21, "")
var string[] slope_statuses = array.new_string(21, "")
var string[] statuses = array.new_string(21, "")

var color[] colors = array.new_color(21, na)
var color[] smacols = array.new_color(21, na)
var color[] sma50cols = array.new_color(21, na)
var color[] sma200cols = array.new_color(21, na)
var color[] slopecols = array.new_color(21, na)

var bool[] is_active_row_array = array.new_bool()
var int[] display_indices       = array.new_int()

// --- Percentage & Rank Formatting Helpers ---
// f_fmt_pct: Formats standard percentage returns with sign (+/-) and color coding.
// f_fmt_pct_compact: Formats compact returns for debug rank displays without decimals if >= 10%.
// f_fmt_rank: Formats ranks with fixed-width leading zero padding (#01 to #09) for vertical alignment.
// f_fmt_off_52w: Formats distance from 52-week highs with tiered color coding:
//   >= -0.5%: Very Bullish (within striking distance of 52WH)
//   >= -5.0%: Positive (healthy consolidation near highs)
//   >= -20.0%: Warning (moderate pullback)
//   < -20.0%: Bad (severe drawdown / bear market territory)
f_fmt_pct(val, pos_color, warn_color, bad_color) =>
    if na(val)
        ["--", warn_color]
    else
        string txt = (val > 0 ? "+" : "") + str.tostring(val, "#.##") + "%"
        color col = val > 0 ? pos_color : (val < 0 ? bad_color : warn_color)
        [txt, col]

f_fmt_pct_compact(val) =>
    if na(val)
        "--"
    else
        float a_val = math.abs(val)
        string sign = val > 0 ? "+" : (val < 0 ? "-" : "")
        sign + (a_val >= 10.0 ? str.tostring(a_val, "#") : str.tostring(a_val, "#.#")) + "%"

f_fmt_rank(r) =>
    na(r) ? "--" : ((r < 10 ? "#0" : "#") + str.tostring(r))

f_fmt_off_52w(val, v_bull_color, pos_color, warn_color, bad_color) =>
    if na(val)
        ["--", warn_color]
    else
        string txt = str.tostring(val, "#.##") + "%"
        color col = val >= -0.5 ? v_bull_color : (val >= -5.0 ? pos_color : (val >= -20.0 ? warn_color : bad_color))
        [txt, col]

// =========================================================================
// Native Group Ranking Helper (O(N log N) via array.sort_indices)
// Evaluates descending ranks (1 to N) within a group based on metric values.
// Ties are broken deterministically by earlier array index.
// Handles NaN values deterministically by pushing them to the bottom rank.
// =========================================================================
f_calc_group_ranks_desc(vals, start_idx, end_idx, out_ranks) =>
    if end_idx >= start_idx
        int count = end_idx - start_idx + 1
        float[] group_vals = array.new_float(count)
        for k = 0 to count - 1
            float v = array.get(vals, start_idx + k)
            array.set(group_vals, k, na(v) ? -1e12 : v)
        int[] sorted_idx = array.sort_indices(group_vals, order.descending)
        for rank_zero = 0 to count - 1
            int orig_offset = array.get(sorted_idx, rank_zero)
            array.set(out_ranks, start_idx + orig_offset, rank_zero + 1)

// =========================================================================
// Native Group Selection Sort Helper (O(N log N) via array.sort_indices)
// Sorts a group range [start_pos to start_pos + count - 1] of display_indices
// based on values in vals array. Supports descending and ascending orders.
// Handles NaN values deterministically by pushing them to the bottom.
// =========================================================================
f_sort_group(disp_idx, vals, start_pos, count, is_desc) =>
    if count > 1
        float[] group_keys = array.new_float(count)
        float na_replacement = is_desc ? -1e12 : 1e12
        for k = 0 to count - 1
            float v = array.get(vals, start_pos + k)
            array.set(group_keys, k, na(v) ? na_replacement : v)
        int[] sorted_order = array.sort_indices(group_keys, is_desc ? order.descending : order.ascending)
        for k = 0 to count - 1
            int orig_offset = array.get(sorted_order, k)
            array.set(disp_idx, start_pos + k, start_pos + orig_offset)

// =========================================================================
// Multi-Timeframe Composite Strength Scoring Model
// Evaluates a structural multi-factor score (0 to 100+ points) across 4 horizons.
// Blends trend alignment, moving average structure, breakout quality, efficiency ratio,
// directional volume confirmation, volatility normalization (ATR%), and market alpha (vs Slot 0):
//
// 1. Daily Score (f_calc_comp_d): Short-Term Momentum, Alpha & Directional Volume
//    - Price > 20 SMA: 25 pts (immediate trend filter)
//    - 20 SMA > 50 SMA: 15 pts (moving average alignment)
//    - Hybrid Trend: 20 pts for Uptrend (1.0), 10 pts for Sideways (0.0), 0 pts for Downtrend (-1.0)
//    - Kaufman's Efficiency Ratio (ER): ER * 10 pts (rewards clean directional momentum over noise)
//    - Volatility-Normalized Daily Return: (1D EMA3 / ATR%) * 4.0 pts (clamped [-10, 15])
//    - Daily Alpha vs Benchmark (Slot 0): 1D alpha * 1.5 pts (clamped [-5, 5])
//    - Directional Volume: Up + RVOL>=1.3 (+5 pts), Down + RVOL>=1.3 (-5 pts),
//                          Down + RVOL<0.7 (+2 pts orderly pullback), Up + RVOL<0.7 (-2.5 pts weak advance)
//
// 2. Weekly Score (f_calc_comp_w): Intermediate Trend Confirmation & Multi-Day Accumulation
//    - Price > 50 SMA: 25 pts (intermediate trend filter)
//    - 20 SMA > 50 SMA: 25 pts (intermediate MA alignment)
//    - Hybrid Trend: 10 pts for constructive trend (>= 0.0)
//    - Kaufman's Efficiency Ratio (ER): ER * 10 pts (rewards sustained directional weekly movement)
//    - Volatility-Normalized Weekly Return: (5D smooth / ATR%) * 3.0 pts (clamped [-12, 18])
//    - Weekly Alpha vs Benchmark (Slot 0): 5D alpha * 1.0 pt (clamped [-6, 6])
//    - 5-Day Volume Flow Ratio: vol_flow_5d * 5.0 pts (rewards sustained weekly accumulation)
//
// 3. Monthly Score (f_calc_comp_m): Macro Horizon, Alpha & Smooth 52WH Proximity
//    - Price > 200 SMA: 30 pts (macro bull market baseline)
//    - 50 SMA > 200 SMA: 30 pts (classic Golden Cross alignment)
//    - Continuous 52WH Proximity: 12.0 * (1.0 - |p52h| / 20.0) (clamped [0, 12])
//    - Volatility-Normalized Monthly Return: (21D return / ATR%) * 2.0 pts (clamped [-15, 20])
//    - Monthly Alpha vs Benchmark (Slot 0): 21D alpha * 0.75 pts (clamped [-8, 8])
//
// 4. Quarterly Score (f_calc_comp_q): Institutional Anchor, Macro Alpha & ATH Leadership
//    - Price > 200 SMA: 35 pts (institutional regime filter)
//    - 50 SMA > 200 SMA: 35 pts (macro trend persistence)
//    - Continuous 52WH Proximity: 18.0 * (1.0 - |p52h| / 20.0) (clamped [0, 18])
//    - Volatility-Normalized Quarterly Return: (63D return / ATR%) * 1.5 pts (clamped [-15, 20])
//    - Quarterly Alpha vs Benchmark (Slot 0): 63D alpha * 0.5 pts (clamped [-10, 10])
// =========================================================================
f_calc_comp_d(c, s20, s50, hy, er, p1d, p1d_ema3, rvol, has_vol, atr_pct, alpha_1d, use_vol) =>
    float score = 0.0
    score += (c > s20 ? 25.0 : 0.0)
    score += (s20 > s50 ? 15.0 : 0.0)
    score += (hy == 1.0 ? 20.0 : (hy == 0.0 ? 10.0 : 0.0))
    score += (er * 10.0)
    
    // Volatility-normalized daily return + market alpha
    float norm_p1d = atr_pct > 0 ? (p1d_ema3 / atr_pct) : p1d_ema3
    score += math.max(-10.0, math.min(15.0, norm_p1d * 4.0))
    score += math.max(-5.0, math.min(5.0, alpha_1d * 1.5))
    
    // Directional volume confirmation (Accumulation vs Distribution)
    if use_vol and has_vol and not na(rvol)
        if p1d_ema3 > 0 and rvol >= 1.3
            score += 5.0   // Institutional Accumulation
        else if p1d_ema3 < 0 and rvol >= 1.3
            score -= 5.0   // Institutional Distribution
        else if p1d_ema3 < 0 and rvol < 0.7
            score += 2.0   // Orderly low-volume consolidation
        else if p1d_ema3 > 0 and rvol < 0.7
            score -= 2.5   // Low-volume advance (weak conviction)
    score

f_calc_comp_w(c, s20, s50, hy, er, p5d, p5d_smooth, vol_flow_5d, has_vol, atr_pct, alpha_5d, use_vol) =>
    float score = 0.0
    score += (c > s50 ? 25.0 : 0.0)
    score += (s20 > s50 ? 25.0 : 0.0)
    score += (hy >= 0.0 ? 10.0 : 0.0)
    score += (er * 10.0)
    
    // Volatility-normalized weekly return + market alpha
    float norm_p5d = atr_pct > 0 ? (p5d_smooth / atr_pct) : p5d_smooth
    score += math.max(-12.0, math.min(18.0, norm_p5d * 3.0))
    score += math.max(-6.0, math.min(6.0, alpha_5d * 1.0))
    
    // 5-day volume accumulation/distribution flow
    if use_vol and has_vol and not na(vol_flow_5d)
        score += (vol_flow_5d * 5.0)  // ranges -5.0 (pure distribution) to +5.0 (pure accumulation)
    score

f_calc_comp_m(c, s50, s200, p52h, p21d, atr_pct, alpha_21d) =>
    float score = 0.0
    score += (c > s200 ? 30.0 : 0.0)
    score += (s50 > s200 ? 30.0 : 0.0)
    
    // Continuous 52WH proximity curve (0% to -20%)
    float p52h_pts = not na(p52h) ? math.max(0.0, 12.0 * (1.0 - math.abs(math.min(0.0, p52h)) / 20.0)) : 0.0
    score += p52h_pts
    
    // Volatility-normalized monthly return + market alpha
    float norm_p21d = atr_pct > 0 ? (p21d / atr_pct) : p21d
    score += math.max(-15.0, math.min(20.0, norm_p21d * 2.0))
    score += math.max(-8.0, math.min(8.0, alpha_21d * 0.75))
    score

f_calc_comp_q(c, s50, s200, p52h, p63d, atr_pct, alpha_63d) =>
    float score = 0.0
    score += (c > s200 ? 35.0 : 0.0)
    score += (s50 > s200 ? 35.0 : 0.0)
    
    // Continuous 52WH proximity curve (0% to -20%)
    float p52h_pts = not na(p52h) ? math.max(0.0, 18.0 * (1.0 - math.abs(math.min(0.0, p52h)) / 20.0)) : 0.0
    score += p52h_pts
    
    // Volatility-normalized quarterly return + market alpha
    float norm_p63d = atr_pct > 0 ? (p63d / atr_pct) : p63d
    score += math.max(-15.0, math.min(20.0, norm_p63d * 1.5))
    score += math.max(-10.0, math.min(10.0, alpha_63d * 0.5))
    score

// =========================================================================
// Rotation Stage & Trajectory State Machine
// Classifies each asset into one of 8 lifecycle stages based on multi-timeframe rank progression.
//
// Lifecycle Badges (listed in actual runtime evaluation order):
// 1. 💎 Core Leader:  Unanimous top-tier rank across Quarterly, Monthly, and Weekly horizons while holding above 20 SMA.
// 2. 🚀 Emerging (+X): Surging into top-tier Weekly ranks from outside Monthly (rw <= top_n and rm > top_n), or
//    experiencing a major multi-rank leap (shift_w >= emerg_shift), with confirmed daily rank (rd <= top_n + 1) and Price > 20 SMA.
// 3. ↗ Improving (+X): Confirmed Weekly rank advance (shift_w >= improv_shift) over Monthly baseline, backed by Price > 20 SMA.
// 4. ❄️ Laggard:      Chronic structural underperformance stuck in bottom-tier ranks across both Monthly and Weekly horizons
//    (rm >= bot_n and rw >= bot_n) below the 20 SMA. Evaluated before Fading to prevent chronic bottom-tier assets from being mislabeled.
// 5. 📊 Coiling:      Former leader (rm or rq <= top_n) holding above 20 SMA with moderate rank softness (shift_w >= -emerg_shift).
//    Captures healthy base-building / wedge consolidations where Weekly rank drifted but price structure remains constructive.
//    Evaluated before Fading to prevent mislabeling sectors that are basing, not breaking down.
// 6. ⚠️ Fading (-X):  Former leaders (rm <= top_n or rq <= top_n) experiencing confirmed structural breakdown:
//    - Above 20 SMA: requires a severe rank collapse (shift_w <= -(emerg_shift + 1)) — one rank worse than old threshold.
//    - Below 20 SMA: requires shift_w <= -emerg_shift OR weekly rank deep in bottom half (rw >= top_n + 2).
//    Daily rank (shift_d) removed from trigger — weekly progression is sufficient to confirm fading.
// 7. ↘ Softening (-X): Mild rank decay across Weekly horizons (shift_w <= -improv_shift).
//    Daily-only shift_d trigger removed — weekly progression only, consistent with Q→M→W signal philosophy.
// 8. ⚓ Stable:        Neutral rank drift across horizons, or unconfirmed counter-trend bounces failing the 20 SMA trend gate.
//
// Dynamic Threshold Scaling by Group Size:
// - Benchmark Indices (group_size <= 3): top_n = 1, bot_n = 3, emerg_shift = 2, improv_shift = 1.
// - Small Watchlists (group_size <= 4):  bot_n = 4 (only last place is bottom tier).
// - Mid-Size Groups (group_size <= 6):   top_n = 2, bot_n = group_size - 1, emerg_shift = 3, improv_shift = 1.
// - Full Sectors (group_size > 6):       top_n = 3, bot_n = group_size - 2 (rank 9+ in 11 sectors), emerg_shift = 4, improv_shift = 2.
//
// Key Guardrails & Principles:
// - Trend Gate (Price > 20 SMA): Bullish badges (Core Leader, Emerging, Improving, Coiling) strictly require price to trade
//   above the 20 SMA. Counter-trend 1-day bounces in broken/downtrending charts are filtered out and remain Stable/Laggard.
// - Q→M→W Signal Philosophy: Stage classification is driven by Quarterly, Monthly, and Weekly rank progression only.
//   Daily rank (rd) is retained only as a tie-breaker in Core Leader score and as a confirmation gate in Emerging.
//   It is NOT used to trigger Fading or Softening, preventing single-session noise from mislabeling healthy consolidations.
// - Weekly Progression Confirmation: Shift is measured as Monthly to Weekly (shift_w = rm - rw), requiring multi-day
//   persistence rather than single-day noise.
// - Stage Score Sorting: Returns a hierarchical score (700 for Leader, 600 for Emerging, 500 for Improving, 450 for Coiling,
//   400 for Stable, 300 for Softening, 200 for Fading, 100 for Laggard) with shift/rank tiebreakers for logical table ordering.
// =========================================================================
f_eval_rotation_flow(rq, rm, rw, rd, is_above_20, sc_master, p52h_val, group_size, color_v_bull, color_bull, color_warn_bg, color_bad_bg, color_bear, color_body_bg) =>
    int shift_w = rm - rw
    int shift_d = rm - rd
    string badge = ""
    color col = color_body_bg
    float stage_score = 0.0
    
    int top_n        = group_size <= 3 ? 1 : (group_size <= 6 ? 2 : 3)
    int bot_n        = group_size <= 4 ? group_size : (group_size <= 6 ? (group_size - 1) : (group_size - 2))
    int emerg_shift  = group_size <= 3 ? 2 : (group_size <= 6 ? 3 : 4)
    int improv_shift = group_size <= 6 ? 1 : 2
    
    string sh_w_str = shift_w > 0 ? "+" + str.tostring(shift_w) : str.tostring(shift_w)
    
    // Normalized tiebreaker bonus from Master Composite score [0.0 to 49.0 pts]
    float m_bonus = math.max(0.0, math.min(49.0, sc_master * 0.4))
    // 52WH proximity bonus [0.0 to 10.0 pts]
    float ath_bonus = not na(p52h_val) ? math.max(0.0, 10.0 * (1.0 - math.abs(math.min(0.0, p52h_val)) / 20.0)) : 0.0

    if is_above_20 and rq <= top_n and rm <= top_n and rw <= top_n
        badge := "💎 Core Leader"
        col   := color_v_bull
        // Core Leader tiebreaker: Master Composite + ATH proximity + multi-timeframe rank bonus
        // Guarantees an asset at ATH with top Q/M/W outranks a high-daily-beta peer
        stage_score := 700.0 + m_bonus + ath_bonus - (rd * 0.5)
    else if is_above_20 and ((rw <= top_n and rm > top_n) or shift_w >= emerg_shift) and rd <= (top_n + 1)
        badge := "🚀 Emerging (" + sh_w_str + ")"
        col   := color_v_bull
        stage_score := 600.0 + (shift_w * 5.0) + m_bonus
    else if is_above_20 and shift_w >= improv_shift
        badge := "↗ Improving (" + sh_w_str + ")"
        col   := color_bull
        stage_score := 500.0 + (shift_w * 5.0) + m_bonus
    else if rm >= bot_n and rw >= bot_n and not is_above_20
        badge := "❄️ Laggard"
        col   := color_bear
        stage_score := 100.0 + m_bonus - rd
    // Fix 2: Coiling — former leader holding above 20 SMA with moderate rank softness.
    // Captures healthy base-building / wedge consolidations (e.g. SMH coiling inside a descending
    // wedge) where the Weekly rank drifted off its Monthly peak but price structure remains intact.
    // Evaluated before Fading so these sectors are never mislabeled as breaking down.
    else if is_above_20 and (rm <= top_n or rq <= top_n) and shift_w >= -emerg_shift
        badge := "📊 Coiling"
        col   := color_bull
        stage_score := 450.0 + m_bonus - rd
    // Fix 1 + Fix 3: Fading — SMA-aware threshold; shift_d removed from trigger.
    // Above 20 SMA: requires a severe rank collapse (shift_w <= -(emerg_shift + 1)), one step
    // stricter than the old threshold, preventing consolidation phases from being mislabeled.
    // Below 20 SMA: requires shift_w <= -emerg_shift OR deep weekly rank drop (rw >= top_n + 2).
    // shift_d is no longer used as a trigger — Q→M→W only; daily rank retained as tiebreaker only.
    else if ((rm <= top_n or rq <= top_n) and
             (rw >= (top_n + 2) or
              (is_above_20 and shift_w <= -(emerg_shift + 1)) or
              (not is_above_20 and shift_w <= -emerg_shift)))
        int sh_fade = shift_w < 0 ? shift_w : (rq <= top_n and (rq - rw) < 0 ? (rq - rw) : -1)
        string sh_fade_str = str.tostring(sh_fade)
        badge := "⚠️ Fading (" + sh_fade_str + ")"
        col   := color_bad_bg
        stage_score := 200.0 + (sh_fade * 5.0)
    // Fix 3: Softening — daily-only shift_d trigger removed; weekly rank progression is sufficient.
    // A sector must show a confirmed multi-day weekly rank decay (shift_w <= -improv_shift) to
    // be classified as Softening — a single down day in daily rank no longer qualifies.
    else if shift_w <= -improv_shift
        int sh_soft = shift_w
        string sh_soft_str = str.tostring(sh_soft)
        badge := "↘ Softening (" + sh_soft_str + ")"
        col   := color_warn_bg
        stage_score := 300.0 + (sh_soft * 5.0)
    else
        badge := "⚓ Stable"
        col   := color_body_bg
        stage_score := 400.0 + m_bonus - rd
        
    [badge, col, shift_w, stage_score]

// Evaluates rank heat-map cell background color dynamically scaled to group size:
// - Top-tier ranks (<= 2 or 3): Vibrant green
// - Mid-tier ranks (<= 4 or 7): Light green
// - Lower-tier ranks (<= 5 or 10): Yellow warning
// - Bottom ranks: Red
f_get_rank_color(r, group_size, color_v_bull, color_bull, color_warn_bg, color_bad_bg) =>
    int top_thresh = group_size <= 6 ? 2 : 3
    int mid_thresh = group_size <= 6 ? 4 : 7
    int low_thresh = group_size <= 6 ? 5 : 10
    r <= top_thresh ? color_v_bull : (r <= mid_thresh ? color_bull : (r <= low_thresh ? color_warn_bg : color_bad_bg))

// Define static variables (required for request.security compiler constraints)
sym1 = f_get_sym(active_country, 0), name1 = f_get_name(active_country, 0, sym1)
sym2 = f_get_sym(active_country, 1), name2 = f_get_name(active_country, 1, sym2)
sym3 = f_get_sym(active_country, 2), name3 = f_get_name(active_country, 2, sym3)
sym4 = f_get_sym(active_country, 3), name4 = f_get_name(active_country, 3, sym4)
sym5 = f_get_sym(active_country, 4), name5 = f_get_name(active_country, 4, sym5)
sym6 = f_get_sym(active_country, 5), name6 = f_get_name(active_country, 5, sym6)
sym7 = f_get_sym(active_country, 6), name7 = f_get_name(active_country, 6, sym7)
sym8 = f_get_sym(active_country, 7), name8 = f_get_name(active_country, 7, sym8)
sym9 = f_get_sym(active_country, 8), name9 = f_get_name(active_country, 8, sym9)
sym10 = f_get_sym(active_country, 9), name10 = f_get_name(active_country, 9, sym10)
sym11 = f_get_sym(active_country, 10), name11 = f_get_name(active_country, 10, sym11)
sym12 = f_get_sym(active_country, 11), name12 = f_get_name(active_country, 11, sym12)
sym13 = f_get_sym(active_country, 12), name13 = f_get_name(active_country, 12, sym13)
sym14 = f_get_sym(active_country, 13), name14 = f_get_name(active_country, 13, sym14)
sym15 = f_get_sym(active_country, 14), name15 = f_get_name(active_country, 14, sym15)
sym16 = f_get_sym(active_country, 15), name16 = f_get_name(active_country, 15, sym16)
sym17 = f_get_sym(active_country, 16), name17 = f_get_name(active_country, 16, sym17)
sym18 = f_get_sym(active_country, 17), name18 = f_get_name(active_country, 17, sym18)
sym19 = f_get_sym(active_country, 18), name19 = f_get_name(active_country, 18, sym19)
sym20 = f_get_sym(active_country, 19), name20 = f_get_name(active_country, 19, sym20)
sym21 = f_get_sym(active_country, 20), name21 = f_get_name(active_country, 20, sym21)

// Define default fallback symbol based on active country (prevents cross-pollination of open chart properties)
default_symbol = active_country == "US" ? "SPY" :
                 active_country == "Korea" ? "KRX:KOSPI" :
                 active_country == "China" ? "SSE:000300" :
                 active_country == "Taiwan" ? "INDEX:TAIEX" :
                 active_country == "Japan" ? "TVC:NI225" :
                 active_country == "India" ? "NSE:NIFTY" :
                 active_country == "Custom" and custom_sym1 != "" ? custom_sym1 : "SPY"

// Dynamic MA lengths based on effective analysis timeframe
ma1_len = switch effective_tf
    "Weekly"    => 10
    "Monthly"   => 3
    => input_ma1_len

ma2_len = switch effective_tf
    "Weekly"    => 30
    "Monthly"   => 6
    => input_ma2_len

ma3_len = switch effective_tf
    "Weekly"    => 40
    "Monthly"   => 10
    => input_ma3_len

// Cache Static Headers
header_country = (active_country == "Custom" ? "Custom" : active_country) + " Index"
ma_type_suffix = " " + ma_type
ma1_label = str.tostring(ma1_len) + ma_type_suffix
ma2_label = str.tostring(ma2_len) + ma_type_suffix
ma3_label = str.tostring(ma3_len) + ma_type_suffix
header_col2 = "Price > " + ma1_label
header_col3 = str.tostring(ma1_len) + " > " + str.tostring(ma2_len) + ma_type_suffix
header_col4 = str.tostring(ma2_len) + " > " + str.tostring(ma3_len) + ma_type_suffix

header_p1 = switch effective_tf
    "Daily"   => "% 1D"
    "Weekly"  => "% 1W"
    "Monthly" => "% 1M"
    => "% 1D"

header_p2 = switch effective_tf
    "Daily"   => "% 5D"
    "Weekly"  => "% 4W"
    "Monthly" => "% 3M"
    => "% 5D"

sort_column_name = switch sort_perf_metric
    "Short-Term Performance"   => header_p1
    "Multi-Period Performance" => header_p2
    "% Off 52WH"               => "% Off 52WH"
    "% YTD"                    => "% YTD"
    => header_p1

f_ma(src, len, ma_mode) =>
    ma_mode == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

f_data() =>
    float close_val = close
    float sma_1     = na
    float sma_2     = na
    float sma_3     = na
    float hybrid_val = na
    float er_val    = na
    
    float pct_1d      = na
    float pct_1d_ema3 = na   // 3-bar EMA of 1D return — composite scoring only (Change 1)
    float pct_5d      = na
    float pct_5d_smooth = na // configurable EMA of 5D return — composite scoring only (Change 4)
    float pct_21d   = na
    float pct_63d   = na
    float pct_off_52w = na
    float pct_ytd   = na

    if show_breadth or show_rotation
        sma_1 := f_ma(close, ma1_len, ma_type)
        sma_2 := f_ma(close, ma2_len, ma_type)
        sma_3 := f_ma(close, ma3_len, ma_type)
        
        // Ribbon Trend (Moving Average Alignment):
        ribbon_val = 0.0
        if not na(sma_1) and not na(sma_2) and not na(sma_3)
            ribbon_up = close > sma_1 and sma_1 > sma_2 and sma_2 > sma_3
            ribbon_down = close < sma_1 and sma_1 < sma_2 and sma_2 < sma_3
            ribbon_val := ribbon_up ? 1.0 : (ribbon_down ? -1.0 : 0.0)
            
        // Donchian Channel Trend (20-period Breakout):
        upper_dc = ta.highest(high, 20)
        lower_dc = ta.lowest(low, 20)
        mid_dc = (upper_dc + lower_dc) / 2.0
        dc_range = upper_dc - lower_dc
        dc_val = 0.0
        if dc_range > 0
            distance_from_mid = math.abs(close - mid_dc)
            is_dc_sideways = (distance_from_mid / dc_range) < 0.15
            dc_val := is_dc_sideways ? 0.0 : (close > mid_dc ? 1.0 : -1.0)
            
        // Hybrid Trend (Macro-Filtered Breakout):
        if dc_val == 1.0
            if ribbon_val >= 0.0 
                hybrid_val := 1.0
        else if dc_val == -1.0
            if ribbon_val <= 0.0 
                hybrid_val := -1.0
                
        // Kaufman's Efficiency Ratio (ER):
        er_len = 10
        er_dir = math.abs(close - close[er_len])
        er_vol = math.sum(math.abs(close - close[1]), er_len)
        er_val := er_vol > 0 ? er_dir / er_vol : 0.0
            
    if show_perf or show_rotation
        if show_rotation
            pct_1d      := not na(close[1]) and close[1] != 0 ? ((close - close[1]) / close[1]) * 100.0 : 0.0
            pct_1d_ema3 := ta.ema(pct_1d, 3)  // 3-bar EMA of daily return for composite scoring (Change 1)
            
            // Rotation Timeframe Return Modes:
            // - Calendar Mode (is_cal_mode): Measures return from fixed calendar boundary closes
            //   (WTD from prior Friday, MTD from prior month-end, QTD from prior quarter-end)
            //   evaluated dynamically using ta.valuewhen() on period transitions.
            // - Trailing Mode (not is_cal_mode): Measures rolling window returns over fixed bar lags
            //   (5-day, 21-day, 63-day) using close[5], close[21], and close[63].
            if is_cal_mode
                prev_w_close = ta.valuewhen(timeframe.change("W"), close[1], 0)
                pct_5d      := not na(prev_w_close) and prev_w_close != 0 ? ((close - prev_w_close) / prev_w_close) * 100.0 : 0.0
                pct_5d_smooth := ta.ema(pct_5d, p5d_smooth_len)  // EMA-smoothed 5D return (Change 4)

                prev_m_close = ta.valuewhen(month(time) != month(time[1]), close[1], 0)
                pct_21d := not na(prev_m_close) and prev_m_close != 0 ? ((close - prev_m_close) / prev_m_close) * 100.0 : 0.0

                is_q_start = (month(time) == 1 or month(time) == 4 or month(time) == 7 or month(time) == 10) and month(time) != month(time[1])
                prev_q_close = ta.valuewhen(is_q_start, close[1], 0)
                pct_63d := not na(prev_q_close) and prev_q_close != 0 ? ((close - prev_q_close) / prev_q_close) * 100.0 : 0.0
            else
                pct_5d        := not na(close[5])  and close[5] != 0  ? ((close - close[5]) / close[5]) * 100.0 : 0.0
                pct_5d_smooth := ta.ema(pct_5d, p5d_smooth_len)  // EMA-smoothed 5D return (Change 4)
                pct_21d       := not na(close[21]) and close[21] != 0 ? ((close - close[21]) / close[21]) * 100.0 : 0.0
                pct_63d       := not na(close[63]) and close[63] != 0 ? ((close - close[63]) / close[63]) * 100.0 : 0.0

            high_52w = ta.highest(high, 252)
            pct_off_52w := not na(high_52w) and high_52w != 0 ? ((close - high_52w) / high_52w) * 100.0 : 0.0

        else
            pct_1d := not na(close[1]) and close[1] != 0 ? ((close - close[1]) / close[1]) * 100.0 : 0.0
            
            pct_5d := switch effective_tf
                "Daily"   => not na(close[5]) and close[5] != 0 ? ((close - close[5]) / close[5]) * 100.0 : 0.0
                "Weekly"  => not na(close[4]) and close[4] != 0 ? ((close - close[4]) / close[4]) * 100.0 : 0.0
                "Monthly" => not na(close[3]) and close[3] != 0 ? ((close - close[3]) / close[3]) * 100.0 : 0.0
                => not na(close[5]) and close[5] != 0 ? ((close - close[5]) / close[5]) * 100.0 : 0.0
            
            high_52w_len = switch effective_tf
                "Daily"   => 252
                "Weekly"  => 52
                "Monthly" => 12
                => 252

            high_52w = ta.highest(high, high_52w_len)
            pct_off_52w := not na(high_52w) and high_52w != 0 ? ((close - high_52w) / high_52w) * 100.0 : 0.0
        
        prev_year_close = ta.valuewhen(year(time) != year(time[1]), close[1], 0)
        pct_ytd := not na(prev_year_close) and prev_year_close != 0 ? ((close - prev_year_close) / prev_year_close) * 100.0 : na

    // ATR % calculation (14-period ATR divided by close * 100)
    atr_val = ta.atr(14)
    float atr_pct = not na(atr_val) and not na(close) and close > 0 ? (atr_val / close) * 100.0 : 1.5

    float rvol = 1.0
    float vol_flow_5d = 0.0
    bool has_vol = false
    if show_rotation
        vol_sma = ta.sma(volume, 20)
        has_vol := not na(volume) and not na(vol_sma) and vol_sma > 0
        rvol := has_vol ? (volume / vol_sma) : 1.0
        
        // 5-day volume accumulation/distribution flow ratio
        up_v = math.sum(close >= nz(close[1], close) and has_vol ? volume : 0.0, 5)
        dn_v = math.sum(close < nz(close[1], close) and has_vol ? volume : 0.0, 5)
        tot_v = up_v + dn_v
        vol_flow_5d := tot_v > 0 ? (up_v - dn_v) / tot_v : 0.0

    SymbolRaw.new(close_val, sma_1, sma_2, sma_3, hybrid_val, er_val, time, pct_1d, pct_1d_ema3, pct_5d, pct_5d_smooth, pct_21d, pct_63d, pct_off_52w, pct_ytd, rvol, atr_pct, vol_flow_5d, has_vol)

// Static Security Fetching & Compiler Constraints:
// - In Pine Script v6, 'request.security' calls are evaluated at compile-time and 
//   cannot be dynamically executed inside runtime loops or conditional branches.
// - To support dynamic country configurations, we define 21 static ticker slots.
// - Each slot fetches a typed SymbolRaw object, which is assembled into SymbolItem on barstate.islast.
raw1  = request.security(ticker.modify(sym1 != "" ? sym1 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw2  = request.security(ticker.modify(sym2 != "" ? sym2 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw3  = request.security(ticker.modify(sym3 != "" ? sym3 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw4  = request.security(ticker.modify(sym4 != "" ? sym4 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw5  = request.security(ticker.modify(sym5 != "" ? sym5 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw6  = request.security(ticker.modify(sym6 != "" ? sym6 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw7  = request.security(ticker.modify(sym7 != "" ? sym7 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw8  = request.security(ticker.modify(sym8 != "" ? sym8 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw9  = request.security(ticker.modify(sym9 != "" ? sym9 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw10 = request.security(ticker.modify(sym10 != "" ? sym10 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw11 = request.security(ticker.modify(sym11 != "" ? sym11 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw12 = request.security(ticker.modify(sym12 != "" ? sym12 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw13 = request.security(ticker.modify(sym13 != "" ? sym13 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw14 = request.security(ticker.modify(sym14 != "" ? sym14 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw15 = request.security(ticker.modify(sym15 != "" ? sym15 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw16 = request.security(ticker.modify(sym16 != "" ? sym16 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw17 = request.security(ticker.modify(sym17 != "" ? sym17 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw18 = request.security(ticker.modify(sym18 != "" ? sym18 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw19 = request.security(ticker.modify(sym19 != "" ? sym19 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw20 = request.security(ticker.modify(sym20 != "" ? sym20 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)
raw21 = request.security(ticker.modify(sym21 != "" ? sym21 : default_symbol, session.regular, adjustment.splits), tf_string, f_data(), calc_bars_count=500)

// ==========================================
// 4. EVALUATION LOGIC
// Ticker Status State Machine:
// - Evaluates individual ticker status and color based on moving average alignment and trend efficiency (ER).
// - Slope Status: Evaluates the Hybrid Trend breakout. If ER < 0.20, it is forced to "Choppy" (noise).
//   If ER > 0.40, a confirmed breakout is marked as a "Clean" trend (Clean Uptrend / Clean Downtrend).
// - Status State Machine Decision Tree:
//   1. Golden Cross (SMA50 > SMA200):
//      - If ER is choppy (<0.20) -> "Caution".
//      - If Price > SMA20 and SMA20 > SMA50 -> "Very Bullish" (high ER) or "Bullish" (normal ER).
//      - If Price pulls back below SMA20 but remains above SMA50 -> "Pullback".
//      - Otherwise -> "Caution".
//   2. Death Cross (SMA50 <= SMA200):
//      - If ER is choppy (<0.20) -> "Caution".
//      - If Price < SMA20 and SMA20 < SMA50 and high ER -> "Very Bearish".
//      - Otherwise -> "Bearish" or "Caution" depending on trend quality/alignment.
f_evaluate_status(price, sma20, sma50, sma200, hy_val, er_val, pos_color, warn_color, bad_color, color_v_bull, color_bull, color_pb, color_bear) =>
    bool price_above_20 = price > sma20
    bool ma20_above_50  = sma20 > sma50
    bool ma50_above_200 = sma50 > sma200
    bool price_above_50 = price > sma50
    bool price_below_20 = price < sma20
    bool ma20_below_50  = sma20 < sma50
    
    string sma20_status   = price_above_20 ? "▲ (Up)" : "▼ (Down)"
    string sma50_status   = ma20_above_50 ? "▲ (Up)" : "▼ (Down)"
    string sma200_status  = ma50_above_200 ? "▲ (Up)" : "▼ (Down)"
    
    color sma20_color     = price_above_20 ? pos_color : bad_color
    color sma50_color     = ma20_above_50 ? pos_color : bad_color
    color sma200_color    = ma50_above_200 ? pos_color : bad_color
    
    bool is_low_quality   = er_val < 0.20
    bool is_high_quality  = er_val > 0.40
    
    string slope_status   = "Sideways"
    color slope_color     = warn_color
    
    if is_low_quality
        slope_status := "Choppy"
        slope_color  := warn_color
    else if hy_val == 1.0
        if is_high_quality
            slope_status := "Clean Uptrend"
            slope_color  := color_v_bull
        else
            slope_status := "Uptrend"
            slope_color  := color_bull
    else if hy_val == -1.0
        if is_high_quality
            slope_status := "Clean Downtrend"
            slope_color  := bad_color
        else
            slope_status := "Downtrend"
            slope_color  := color_bear
    
    string status         = "Caution"
    color cell_color      = warn_color
    
    if ma50_above_200 
        if is_low_quality
            status     := "Caution"
            cell_color := warn_color
        else if ma20_above_50
            if price_above_20
                if is_high_quality
                    status     := "Very Bullish"
                    cell_color := color_v_bull
                else
                    status     := "Bullish"
                    cell_color := color_bull
            else 
                if price_above_50
                    status     := "Pullback"
                    cell_color := color_pb
                else
                    status     := "Caution"
                    cell_color := warn_color
        else 
            status     := "Caution"
            cell_color := warn_color
    else // Death Cross (ma50 <= ma200)
        if is_low_quality
            status     := "Caution"
            cell_color := warn_color
        else if ma20_above_50
            if price_above_20
                status     := "Caution"
                cell_color := warn_color
            else 
                if price_above_50
                    status     := "Caution"
                    cell_color := warn_color
                else
                    status     := "Bearish"
                    cell_color := color_bear
        else 
            if price_below_20 and is_high_quality
                status     := "Very Bearish"
                cell_color := bad_color
            else
                status     := "Bearish"
                cell_color := color_bear
 
            
    [sma20_status, sma50_status, sma200_status, slope_status, status, cell_color, sma20_color, sma50_color, sma200_color, slope_color]

var table dashboard = table.new(
     position     = f_get_position(table_pos),
     columns      = 12,
     rows         = 26, // 1 header + max 21 rows + 1 divider + 1 footer + margin
     bgcolor      = color_bg,
     frame_color  = color_frame,
     frame_width  = frame_width,
     border_color = color_border,
     border_width = border_width
 )

// Helper to register active symbols and populate state
f_add_symbol(sym, name, SymbolRaw raw) =>
    if sym != ""
        string d_name = (name != "" ? name : sym) + " (" + (not na(raw.bar_time) ? str.format_time(raw.bar_time, "MM-dd") : "--") + ")"
        bool is_match = f_is_ticker_match(sym)
        array.push(act_syms, sym)
        array.push(act_names, d_name)
        array.push(act_c, raw.close_val)
        array.push(act_s20, raw.sma_1)
        array.push(act_s50, raw.sma_2)
        array.push(act_s200, raw.sma_3)
        array.push(act_hy, raw.hybrid_val)
        array.push(act_er, raw.er_val)
        array.push(act_p1d, raw.pct_1d)
        array.push(act_p1d_ema3, raw.pct_1d_ema3)      // smoothed 1D return (Change 1)
        array.push(act_p5d, raw.pct_5d)
        array.push(act_p5d_smooth, raw.pct_5d_smooth)   // smoothed 5D return (Change 4)
        array.push(act_p21d, raw.pct_21d)
        array.push(act_p63d, raw.pct_63d)
        array.push(act_p52h, raw.pct_off_52w)
        array.push(act_pytd, raw.pct_ytd)
        array.push(act_rvol, raw.rvol)
        array.push(act_atr_pct, raw.atr_pct)
        array.push(act_vol_flow_5d, raw.vol_flow_5d)
        array.push(act_has_vol, raw.has_vol)
        array.push(is_active_row_array, is_match)

if barstate.islast
    // Clear arrays instead of reallocating
    array.clear(act_syms)
    array.clear(act_names)
    array.clear(act_c)
    array.clear(act_s20)
    array.clear(act_s50)
    array.clear(act_s200)
    array.clear(act_hy)
    array.clear(act_er)
    array.clear(act_p1d)
    array.clear(act_p1d_ema3)    // Change 1
    array.clear(act_p5d)
    array.clear(act_p5d_smooth)  // Change 4
    array.clear(act_p21d)
    array.clear(act_p63d)
    array.clear(act_p52h)
    array.clear(act_pytd)
    array.clear(act_rvol)
    array.clear(act_atr_pct)
    array.clear(act_vol_flow_5d)
    array.clear(act_has_vol)
    array.clear(is_active_row_array)
    array.clear(display_indices)

    f_add_symbol(sym1,  name1,  raw1)
    f_add_symbol(sym2,  name2,  raw2)
    f_add_symbol(sym3,  name3,  raw3)
    f_add_symbol(sym4,  name4,  raw4)
    f_add_symbol(sym5,  name5,  raw5)
    f_add_symbol(sym6,  name6,  raw6)
    f_add_symbol(sym7,  name7,  raw7)
    f_add_symbol(sym8,  name8,  raw8)
    f_add_symbol(sym9,  name9,  raw9)
    f_add_symbol(sym10, name10, raw10)
    f_add_symbol(sym11, name11, raw11)
    f_add_symbol(sym12, name12, raw12)
    f_add_symbol(sym13, name13, raw13)
    f_add_symbol(sym14, name14, raw14)
    f_add_symbol(sym15, name15, raw15)
    f_add_symbol(sym16, name16, raw16)
    f_add_symbol(sym17, name17, raw17)
    f_add_symbol(sym18, name18, raw18)
    f_add_symbol(sym19, name19, raw19)
    f_add_symbol(sym20, name20, raw20)
    f_add_symbol(sym21, name21, raw21)

    // --- METRIC AGGREGATION & MARKET STANCE ---
    int act_count = array.size(act_syms)
    
    int v_bull_count = 0
    int bull_count = 0
    int pb_count = 0
    int caut_count = 0
    int bear_count = 0
    int v_bear_count = 0
    int lng_count = 0
    int shrt_count = 0
    int lng_20_50 = 0
    int shrt_20_50 = 0
    int lng_50_200 = 0
    int shrt_50_200 = 0

    // Pre-allocated status arrays are updated via array.set()

    if act_count > 0
        float bm_p1d  = array.get(act_p1d_ema3, 0)
        float bm_p5d  = array.get(act_p5d_smooth, 0)
        float bm_p21d = array.get(act_p21d, 0)
        float bm_p63d = array.get(act_p63d, 0)

        for i = 0 to act_count - 1
            float c_val = array.get(act_c, i)
            float s20_val = array.get(act_s20, i)
            float s50_val = array.get(act_s50, i)
            float s200_val = array.get(act_s200, i)
            float hy_val = array.get(act_hy, i)
            float er_val = array.get(act_er, i)
            
            [sma_s, sma50_s, sma200_s, slope_s, stat, col, smacol, sma50col, sma200col, slopecol] = f_evaluate_status(c_val, s20_val, s50_val, s200_val, hy_val, er_val, color_pos_bg, color_warn_bg, color_bad_bg, color_v_bull, color_bull, color_pb, color_bear)
            
            array.set(sma_statuses, i, sma_s)
            array.set(sma50_statuses, i, sma50_s)
            array.set(sma200_statuses, i, sma200_s)
            array.set(slope_statuses, i, slope_s)
            array.set(statuses, i, stat)
            array.set(colors, i, col)
            array.set(smacols, i, smacol)
            array.set(sma50cols, i, sma50col)
            array.set(sma200cols, i, sma200col)
            array.set(slopecols, i, slopecol)
            
            if stat == "Very Bullish"
                v_bull_count += 1
            else if stat == "Bullish"
                bull_count += 1
            else if stat == "Pullback"
                pb_count += 1
            else if stat == "Caution"
                caut_count += 1
            else if stat == "Bearish"
                bear_count += 1
            else if stat == "Very Bearish"
                v_bear_count += 1

            if c_val > s20_val
                lng_count += 1
            else
                shrt_count += 1
                
            if s20_val > s50_val
                lng_20_50 += 1
            else
                shrt_20_50 += 1
                
            if s50_val > s200_val
                lng_50_200 += 1
            else
                shrt_50_200 += 1

            // Evaluate Multi-Timeframe Composite Strength Scores (selectively executed when calc_comp is active)
            if calc_comp
                float p1d_v        = array.get(act_p1d, i)
                float p1d_ema3_v   = array.get(act_p1d_ema3, i)     // smoothed 1D return (Change 1)
                float p5d_v        = array.get(act_p5d, i)
                float p5d_smooth_v = array.get(act_p5d_smooth, i)   // smoothed 5D return (Change 4)
                float p21d_v       = array.get(act_p21d, i)
                float p63d_v       = array.get(act_p63d, i)
                float p52h_v       = array.get(act_p52h, i)
                float rvol_v       = array.get(act_rvol, i)
                float atr_pct_v    = array.get(act_atr_pct, i)
                float vol_flow_v   = array.get(act_vol_flow_5d, i)
                bool  has_vol_v    = array.get(act_has_vol, i)
                
                // Alpha vs primary benchmark (Slot 0)
                float a1d  = p1d_ema3_v - bm_p1d
                float a5d  = p5d_smooth_v - bm_p5d
                float a21d = p21d_v - bm_p21d
                float a63d = p63d_v - bm_p63d

                float sc_d = f_calc_comp_d(c_val, s20_val, s50_val, hy_val, er_val, p1d_v, p1d_ema3_v, rvol_v, has_vol_v, atr_pct_v, a1d, use_vol_weighting)
                float sc_w = f_calc_comp_w(c_val, s20_val, s50_val, hy_val, er_val, p5d_v, p5d_smooth_v, vol_flow_v, has_vol_v, atr_pct_v, a5d, use_vol_weighting)
                float sc_m = f_calc_comp_m(c_val, s50_val, s200_val, p52h_v, p21d_v, atr_pct_v, a21d)
                float sc_q = f_calc_comp_q(c_val, s50_val, s200_val, p52h_v, p63d_v, atr_pct_v, a63d)
                
                // Master Weighted Composite Score (Q 30% + M 35% + W 25% + D 10%)
                float sc_master = (sc_q * 0.30) + (sc_m * 0.35) + (sc_w * 0.25) + (sc_d * 0.10)
                
                array.set(act_comp_d, i, sc_d)
                array.set(act_comp_w, i, sc_w)
                array.set(act_comp_m, i, sc_m)
                array.set(act_comp_q, i, sc_q)
                array.set(act_comp_master, i, sc_master)

    // Change 3: EMA-smooth daily composite scores before computing daily ranks.
    // act_comp_d (raw) is preserved for display/sort keys; act_comp_d_smooth feeds rank_comp_d.
    if calc_comp
        float alpha_d = 2.0 / (rank_smooth_len + 1)
        int n_smooth = act_count
        if n_smooth > 0
            for i = 0 to n_smooth - 1
                float raw_d  = array.get(act_comp_d, i)
                float prev_s = array.get(act_comp_d_smooth, i)
                float new_s  = prev_s == 0.0 ? raw_d : (alpha_d * raw_d + (1.0 - alpha_d) * prev_s)
                array.set(act_comp_d_smooth, i, new_s)


    // Market Stance & Trade Opportunity Risk (TOR) Aggregation Logic:
    // - Assesses overall market sentiment by blending the primary index status
    //   with the active ticker list's constructive and bearish participation percentages.
    // - Evaluates stance thresholds:
    //   * Risk-On (Aggressive): Primary index is Bullish/Very Bullish, constructive count >= 70%, and bearish <= 10%.
    //   * Risk-On (Selective): Primary index is constructive (Bullish/PB), constructive count >= 50%, and bearish < 30%.
    //   * Capital Preservation: Primary index is Bearish/Very Bearish, and bearish count >= 75%.
    //   * Risk-Off (Defensive): Primary index is Bearish/Very Bearish or bearish count >= 50%.
    //   * Caution / Neutral: All other mixed or transitional states.
    float constructive_pct = act_count > 0 ? ((v_bull_count + bull_count + pb_count) * 100.0 / act_count) : 0.0
    float bear_pct         = act_count > 0 ? ((bear_count + v_bear_count) * 100.0 / act_count) : 0.0

    string stance_value = ""
    string stance_tor = ""
    string stance_bias = ""
    color stance_bg_color = na

    string stat_primary = act_count > 0 ? array.get(statuses, 0) : "Caution"

    if (stat_primary == "Very Bullish" or stat_primary == "Bullish") and constructive_pct >= 70.0 and bear_pct <= 10.0
        stance_value    := "Risk-On (Aggressive)"
        stance_tor      := "TOR Open (6-8R)"
        stance_bias     := "Broad Long"
        stance_bg_color := color_v_bull
    else if (stat_primary == "Very Bullish" or stat_primary == "Bullish" or stat_primary == "Pullback") and constructive_pct >= 50.0 and bear_pct < 30.0
        stance_value    := "Risk-On (Selective)"
        stance_tor      := "TOR Normal (4-5R)"
        stance_bias     := "Long Bias"
        stance_bg_color := color_bull
    else if (stat_primary == "Bearish" or stat_primary == "Very Bearish") and bear_pct >= 75.0
        stance_value    := "Capital Preservation"
        stance_tor      := "TOR Cash (0R)"
        stance_bias     := "Cash Only"
        stance_bg_color := color_bad_bg
    else if (stat_primary == "Bearish" or stat_primary == "Very Bearish") or bear_pct >= 50.0
        stance_value    := "Risk-Off (Defensive)"
        stance_tor      := "TOR Tight (1-2R)"
        stance_bias     := "Short Bias"
        stance_bg_color := color_bear
    else
        stance_value    := "Caution / Neutral"
        stance_tor      := "TOR Max 3R"
        stance_bias     := "Selective"
        stance_bg_color := color_warn_bg

    int key_count    = math.min(f_get_key_count(active_country), act_count)
    bool has_divider = key_count > 0 and act_count > key_count
    int num_cols     = is_combined ? (compact_view ? 8 : 11) : 
                       show_rotation ? (compact_view ? (rank_view_type == "Both (Compare)" ? 7 : 6) : (rank_view_type == "Both (Compare)" ? 11 : 10)) : 
                       show_perf ? (compact_view ? 4 : 6) : 
                       7
    table.clear(dashboard, 0, 0, 11, 25)

    // ==========================================
    // 5. INDEPENDENT GROUP RANKINGS (Indices vs. Sectors)
    // ==========================================
    // Benchmarks (index slots 0 to key_count - 1) and sectoral rows (key_count to act_count - 1)
    // are partitioned and ranked independently so index benchmarks stay grouped at the top
    // and sectoral ETFs compete exclusively against their sectoral peers.
    if act_count > 0
        int idx_end   = key_count - 1
        int sec_start = key_count
        int sec_end   = act_count - 1

        // Group Rankings by Pure Returns (selectively executed when calc_ret is active)
        if calc_ret
            if key_count > 0
                f_calc_group_ranks_desc(act_p1d,  0, idx_end, rank_ret_d)
                f_calc_group_ranks_desc(act_p5d,  0, idx_end, rank_ret_w)
                f_calc_group_ranks_desc(act_p21d, 0, idx_end, rank_ret_m)
                f_calc_group_ranks_desc(act_p63d, 0, idx_end, rank_ret_q)
            if sec_end >= sec_start
                f_calc_group_ranks_desc(act_p1d,  sec_start, sec_end, rank_ret_d)
                f_calc_group_ranks_desc(act_p5d,  sec_start, sec_end, rank_ret_w)
                f_calc_group_ranks_desc(act_p21d, sec_start, sec_end, rank_ret_m)
                f_calc_group_ranks_desc(act_p63d, sec_start, sec_end, rank_ret_q)

        // Group Rankings by Composite Strength Scores (selectively executed when calc_comp is active)
        if calc_comp
            if key_count > 0
                f_calc_group_ranks_desc(act_comp_d_smooth, 0, idx_end, rank_comp_d)  // Change 3: smoothed scores for stable ranks
                f_calc_group_ranks_desc(act_comp_w, 0, idx_end, rank_comp_w)
                f_calc_group_ranks_desc(act_comp_m, 0, idx_end, rank_comp_m)
                f_calc_group_ranks_desc(act_comp_q, 0, idx_end, rank_comp_q)
                f_calc_group_ranks_desc(act_comp_master, 0, idx_end, rank_comp_master)
            if sec_end >= sec_start
                f_calc_group_ranks_desc(act_comp_d_smooth, sec_start, sec_end, rank_comp_d)  // Change 3: smoothed scores for stable ranks
                f_calc_group_ranks_desc(act_comp_w, sec_start, sec_end, rank_comp_w)
                f_calc_group_ranks_desc(act_comp_m, sec_start, sec_end, rank_comp_m)
                f_calc_group_ranks_desc(act_comp_q, sec_start, sec_end, rank_comp_q)
                f_calc_group_ranks_desc(act_comp_master, sec_start, sec_end, rank_comp_master)

        // Evaluate Flow Trajectory Badges & Stage Sorting Scores
        for i = 0 to act_count - 1
            bool is_sec = i >= key_count
            int g_size  = is_sec ? (act_count - key_count) : key_count
            int rq      = calc_comp ? array.get(rank_comp_q, i) : array.get(rank_ret_q, i)
            int rm      = calc_comp ? array.get(rank_comp_m, i) : array.get(rank_ret_m, i)
            int rw      = calc_comp ? array.get(rank_comp_w, i) : array.get(rank_ret_w, i)
            int rd      = calc_comp ? array.get(rank_comp_d, i) : array.get(rank_ret_d, i)
            float c_i   = array.get(act_c, i)
            float s20_i = array.get(act_s20, i)
            float sc_m_i = array.get(act_comp_master, i)
            float p52h_i = array.get(act_p52h, i)
            bool is_a20 = not na(c_i) and not na(s20_i) and c_i >= (s20_i * (1.0 - sma_gate_band / 100.0))  // Change 2: configurable tolerance band
            [b_txt, b_col, sh, sc_stage] = f_eval_rotation_flow(rq, rm, rw, rd, is_a20, sc_m_i, p52h_i, g_size, color_v_bull, color_bull, color_warn_bg, color_bad_bg, color_bear, color_body_bg)
            array.set(flow_badges, i, b_txt)
            array.set(flow_colors, i, b_col)
            array.set(flow_scores, i, sc_stage)
      
    // ==========================================
    // 6. DASHBOARD UI RENDERING ENGINE
    // ==========================================
    // Renders table headers, sorted sectoral data rows, divider, and footer across active views.
    // --- Render Header Row (Row 0) ---
    f_set_cell_bold(dashboard, 0, 0, header_country,                               color_text, color_title_bg, text_size_input, "left")
    f_set_cell_bold(dashboard, 1, 0, "Name (" + f_get_tf_label(effective_tf) + ")", color_text, color_title_bg, text_size_input, "left")
    
    if show_rotation
        if compact_view
            f_set_cell_bold(dashboard, 2, 0, "% YTD",        color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 3, 0, "% Off 52WH",   color_text, color_title_bg, text_size_input, "center")
            if rank_view_type == "Both (Compare)"
                f_set_cell_bold(dashboard, 4, 0, "Rank (Returns)",   color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 5, 0, "Rank (Composite)", color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 6, 0, "Rotation Stage",   color_text, color_title_bg, text_size_input, "center")
            else if rank_view_type == "Composite Strength"
                f_set_cell_bold(dashboard, 4, 0, "Rank (Composite) [Q→M→W→D]", color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 5, 0, "Rotation Stage",              color_text, color_title_bg, text_size_input, "center")
            else
                f_set_cell_bold(dashboard, 4, 0, "Rank (Returns) [Q→M→W→D]",   color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 5, 0, "Rotation Stage",              color_text, color_title_bg, text_size_input, "center")
        else
            f_set_cell_bold(dashboard, 2, 0, "% 1D",                          color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 3, 0, is_cal_mode ? "% 1W" : "% 5D",  color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 4, 0, is_cal_mode ? "% 1M" : "% 21D", color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 5, 0, is_cal_mode ? "% 3M" : "% 63D", color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 6, 0, "% YTD",                         color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 7, 0, "% Off 52WH",                    color_text, color_title_bg, text_size_input, "center")
            if rank_view_type == "Both (Compare)"
                f_set_cell_bold(dashboard, 8, 0, "Rank (by Returns)",          color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 9, 0, "Rank (Composite Strength)", color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 10, 0, "Rotation Stage",            color_text, color_title_bg, text_size_input, "center")
            else if rank_view_type == "Composite Strength"
                f_set_cell_bold(dashboard, 8, 0, "Rank (Composite Strength) [Q→M→W→D]", color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 9, 0, "Rotation Stage",                       color_text, color_title_bg, text_size_input, "center")
            else
                f_set_cell_bold(dashboard, 8, 0, "Rank (by Returns) [Q→M→W→D]",        color_text, color_title_bg, text_size_input, "center")
                f_set_cell_bold(dashboard, 9, 0, "Rotation Stage",                       color_text, color_title_bg, text_size_input, "center")
    else if is_combined
        if compact_view
            f_set_cell_bold(dashboard, 2, 0, header_p1,         color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 3, 0, header_col2,       color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 4, 0, header_col3,       color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 5, 0, header_col4,       color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 6, 0, "Trend",           color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 7, 0, "Status",          color_text, color_title_bg, text_size_input, "center")
        else
            f_set_cell_bold(dashboard, 2, 0, header_p1,         color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 3, 0, header_p2,         color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 4, 0, "% YTD",           color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 5, 0, "% Off 52WH",      color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 6, 0, header_col2,       color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 7, 0, header_col3,       color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 8, 0, header_col4,       color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 9, 0, "Trend",           color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 10, 0, "Status",          color_text, color_title_bg, text_size_input, "center")
    else if show_breadth
        f_set_cell_bold(dashboard, 2, 0, header_col2,       color_text, color_title_bg, text_size_input, "center")
        f_set_cell_bold(dashboard, 3, 0, header_col3,       color_text, color_title_bg, text_size_input, "center")
        f_set_cell_bold(dashboard, 4, 0, header_col4,       color_text, color_title_bg, text_size_input, "center")
        f_set_cell_bold(dashboard, 5, 0, "Trend",           color_text, color_title_bg, text_size_input, "center")
        f_set_cell_bold(dashboard, 6, 0, "Status",          color_text, color_title_bg, text_size_input, "center")
    else if show_perf
        if compact_view
            f_set_cell_bold(dashboard, 2, 0, header_p1,         color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 3, 0, "% YTD",           color_text, color_title_bg, text_size_input, "center")
        else
            f_set_cell_bold(dashboard, 2, 0, header_p1,         color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 3, 0, header_p2,         color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 4, 0, "% YTD",           color_text, color_title_bg, text_size_input, "center")
            f_set_cell_bold(dashboard, 5, 0, "% Off 52WH",      color_text, color_title_bg, text_size_input, "center")
    
    // --- Determine Row Display Order (Dual-Group Independent Selection Sort) ---
    // Benchmark indices (slots 0 to key_count - 1) and sectoral rows (key_count to act_count - 1)
    // are partitioned and sorted independently so indices remain pinned to the top of the table
    // while sectors compete exclusively amongst their sectoral peers below the divider.
    // An in-place selection sort reorders display_indices pointers without mutating underlying data arrays.
    // Handles NaN values deterministically by pushing them below valid numeric entries.
    if act_count > 0
        for idx = 0 to act_count - 1
            array.push(display_indices, idx)
        
        if show_rotation
            // Populate sorting key values based on active rotation sort metric:
            // - Composite Strength Rank: Master composite score (act_comp_master)
            // - Rotation Stage: Hierarchical stage score (flow_scores: 700 to 100)
            // - Return Rank: Daily percentage return (act_p1d)
            // - Daily Rank: Daily composite score (act_comp_d) or return (act_p1d)
            // - Weekly / Monthly / Quarterly Rank: Corresponding horizon composite score or return
            // - % Off 52WH: Distance from 52-week high (act_p52h)
            // - % YTD: Year-to-date return (act_pytd)
            for idx = 0 to act_count - 1
                float k = 0.0
                if sort_rotation_by == "Composite Strength Rank"
                    k := calc_comp ? array.get(act_comp_master, idx) : array.get(act_p1d, idx)
                else if sort_rotation_by == "Rotation Stage"
                    k := array.get(flow_scores, idx)
                else if sort_rotation_by == "Return Rank"
                    k := array.get(act_p1d, idx)
                else if sort_rotation_by == "Daily Rank"
                    k := calc_comp and rank_view_type == "Composite Strength" ? array.get(act_comp_d, idx) : array.get(act_p1d, idx)
                else if sort_rotation_by == "Weekly Rank"
                    k := calc_comp and rank_view_type == "Composite Strength" ? array.get(act_comp_w, idx) : array.get(act_p5d, idx)
                else if sort_rotation_by == "Monthly Rank"
                    k := calc_comp and rank_view_type == "Composite Strength" ? array.get(act_comp_m, idx) : array.get(act_p21d, idx)
                else if sort_rotation_by == "Quarterly Rank"
                    k := calc_comp and rank_view_type == "Composite Strength" ? array.get(act_comp_q, idx) : array.get(act_p63d, idx)
                else if sort_rotation_by == "% Off 52WH"
                    k := array.get(act_p52h, idx)
                else if sort_rotation_by == "% YTD"
                    k := array.get(act_pytd, idx)
                array.set(sort_keys, idx, k)
            
            // Sort Benchmark Indices (0 to key_count - 1) independently (Descending order)
            if key_count > 1
                f_sort_group(display_indices, sort_keys, 0, key_count, true)

            // Sort Sectoral Rows (key_count to act_count - 1) independently (Descending order)
            if act_count > key_count + 1
                f_sort_group(display_indices, sort_keys, key_count, act_count - key_count, true)

        else if show_perf and sort_sectors_by_perf and act_count > key_count + 1
            sort_vals = switch sort_perf_metric
                "Short-Term Performance"   => act_p1d
                "Multi-Period Performance" => act_p5d
                "% Off 52WH"               => act_p52h
                "% YTD"                    => act_pytd
                => act_p1d
            f_sort_group(display_indices, sort_vals, key_count, act_count - key_count, sort_perf_order == "Descending")

    // --- Render Section Divider Row (if applicable) ---
    if has_divider
        int div_r = key_count + 1
        string div_title = show_rotation ? ("Sector Rotation (Sorted by " + sort_rotation_by + ")") : 
                           (show_perf and sort_sectors_by_perf ? ("Sector Ranking by " + sort_column_name) : 
                           (active_country == "Custom" ? "Watchlist / Sectors" : "Sector Universe"))
        f_set_cell_bold(dashboard, 0, div_r, "--", color_text, color_title_bg, text_size_input, "center")
        f_set_cell_bold(dashboard, 1, div_r, div_title, color_text, color_title_bg, text_size_input, "left")
        if num_cols > 2
            for c = 2 to num_cols - 1
                f_set_cell(dashboard, c, div_r, "--", color_text, color_title_bg, text_size_input, "center")

    // --- Render Index & Sector Data Rows ---
    if act_count > 0
        for row_pos = 0 to act_count - 1
            int i = array.get(display_indices, row_pos)
            bool is_sector = row_pos >= key_count
            int r = row_pos + 1 + (has_divider and is_sector ? 1 : 0)
            string sym = array.get(act_syms, i)
            string base_name = array.get(act_names, i)
            int group_rank = is_sector ? (row_pos - key_count + 1) : (row_pos + 1)
            string display_name = (show_rotation or (show_perf and sort_sectors_by_perf and is_sector)) ? 
                                  ("#" + str.tostring(group_rank) + " " + base_name) : 
                                  base_name
            is_active_row = array.get(is_active_row_array, i)
            color row_bg = is_active_row ? color_title_bg : color_body_bg

            [p1d_txt, p1d_col]   = f_fmt_pct(array.get(act_p1d, i), color_pos_bg, color_warn_bg, color_bad_bg)
            [p5d_txt, p5d_col]   = f_fmt_pct(array.get(act_p5d, i), color_pos_bg, color_warn_bg, color_bad_bg)
            [p21d_txt, p21d_col] = f_fmt_pct(array.get(act_p21d, i), color_pos_bg, color_warn_bg, color_bad_bg)
            [p63d_txt, p63d_col] = f_fmt_pct(array.get(act_p63d, i), color_pos_bg, color_warn_bg, color_bad_bg)
            [p52h_txt, p52h_col] = f_fmt_off_52w(array.get(act_p52h, i), color_v_bull, color_pos_bg, color_warn_bg, color_bad_bg)
            [pytd_txt, pytd_col] = f_fmt_pct(array.get(act_pytd, i), color_pos_bg, color_warn_bg, color_bad_bg)

            int g_size = is_sector ? (act_count - key_count) : key_count
            string rank_ret_txt = ""
            color rank_ret_col  = na
            if calc_ret
                int rq_a = array.get(rank_ret_q, i)
                int rm_a = array.get(rank_ret_m, i)
                int rw_a = array.get(rank_ret_w, i)
                int rd_a = array.get(rank_ret_d, i)
                float pq_v = array.get(act_p63d, i)
                float pm_v = array.get(act_p21d, i)
                float pw_v = array.get(act_p5d, i)
                float pd_v = array.get(act_p1d, i)
                if show_rank_debug
                    rank_ret_txt := f_fmt_rank(rq_a) + " [" + f_fmt_pct_compact(pq_v) + "] → " + f_fmt_rank(rm_a) + " [" + f_fmt_pct_compact(pm_v) + "] → " + f_fmt_rank(rw_a) + " [" + f_fmt_pct_compact(pw_v) + "] → " + f_fmt_rank(rd_a) + " [" + f_fmt_pct_compact(pd_v) + "]"
                else
                    rank_ret_txt := f_fmt_rank(rq_a) + " → " + f_fmt_rank(rm_a) + " → " + f_fmt_rank(rw_a) + " → " + f_fmt_rank(rd_a)
                rank_ret_col := f_get_rank_color(rd_a, g_size, color_v_bull, color_bull, color_warn_bg, color_bad_bg)

            string rank_comp_txt = ""
            color rank_comp_col  = na
            if calc_comp
                int rq_b = array.get(rank_comp_q, i)
                int rm_b = array.get(rank_comp_m, i)
                int rw_b = array.get(rank_comp_w, i)
                int rd_b = array.get(rank_comp_d, i)
                int rmaster_b = array.get(rank_comp_master, i)
                float sc_q_v = array.get(act_comp_q, i)
                float sc_m_v = array.get(act_comp_m, i)
                float sc_w_v = array.get(act_comp_w, i)
                float sc_d_v = array.get(act_comp_d, i)
                float sc_master_v = array.get(act_comp_master, i)
                if show_rank_debug
                    rank_comp_txt := f_fmt_rank(rq_b) + " [" + str.tostring(math.round(sc_q_v)) + "] → " + f_fmt_rank(rm_b) + " [" + str.tostring(math.round(sc_m_v)) + "] → " + f_fmt_rank(rw_b) + " [" + str.tostring(math.round(sc_w_v)) + "] → " + f_fmt_rank(rd_b) + " [" + str.tostring(math.round(sc_d_v)) + "] (" + str.tostring(math.round(sc_master_v)) + ")"
                else
                    rank_comp_txt := f_fmt_rank(rq_b) + " → " + f_fmt_rank(rm_b) + " → " + f_fmt_rank(rw_b) + " → " + f_fmt_rank(rd_b)
                rank_comp_col := f_get_rank_color(rmaster_b, g_size, color_v_bull, color_bull, color_warn_bg, color_bad_bg)

            string flow_txt = array.get(flow_badges, i)
            color flow_col  = array.get(flow_colors, i)

            // --- Cell Rendering by View Mode ---
            // UI Column Alignment Strategy:
            // - Left-aligned: Symbol (Col 0), Name (Col 1), and Rotation Stage badge (Col 9/10) for text and badge legibility.
            // - Center-aligned: All numerical returns, moving average indicators, and rank progression strings.
            f_render_cell(dashboard, 0, r, sym,          color_text, row_bg, text_size_input, "left", is_active_row)
            f_render_cell(dashboard, 1, r, display_name, color_text, row_bg, text_size_input, "left", is_active_row)

            if show_rotation
                if compact_view
                    f_render_cell(dashboard, 2, r, pytd_txt, color_text, pytd_col, text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 3, r, p52h_txt, color_text, p52h_col, text_size_input, "center", is_active_row)
                    if rank_view_type == "Both (Compare)"
                        f_render_cell(dashboard, 4, r, rank_ret_txt,  color_text, rank_ret_col,  text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 5, r, rank_comp_txt, color_text, rank_comp_col, text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 6, r, flow_txt,     color_text, flow_col,      text_size_input, "left",   is_active_row)
                    else if rank_view_type == "Composite Strength"
                        f_render_cell(dashboard, 4, r, rank_comp_txt, color_text, rank_comp_col, text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 5, r, flow_txt,      color_text, flow_col,      text_size_input, "left",   is_active_row)
                    else
                        f_render_cell(dashboard, 4, r, rank_ret_txt,  color_text, rank_ret_col,  text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 5, r, flow_txt,      color_text, flow_col,      text_size_input, "left",   is_active_row)
                else
                    f_render_cell(dashboard, 2, r, p1d_txt,       color_text, p1d_col,       text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 3, r, p5d_txt,       color_text, p5d_col,       text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 4, r, p21d_txt,      color_text, p21d_col,      text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 5, r, p63d_txt,      color_text, p63d_col,      text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 6, r, pytd_txt,      color_text, pytd_col,      text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 7, r, p52h_txt,      color_text, p52h_col,      text_size_input, "center", is_active_row)
                    if rank_view_type == "Both (Compare)"
                        f_render_cell(dashboard, 8, r, rank_ret_txt,  color_text, rank_ret_col,  text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 9, r, rank_comp_txt, color_text, rank_comp_col, text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 10, r, flow_txt,     color_text, flow_col,      text_size_input, "left",   is_active_row)
                    else if rank_view_type == "Composite Strength"
                        f_render_cell(dashboard, 8, r, rank_comp_txt, color_text, rank_comp_col, text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 9, r, flow_txt,      color_text, flow_col,      text_size_input, "left",   is_active_row)
                    else
                        f_render_cell(dashboard, 8, r, rank_ret_txt,  color_text, rank_ret_col,  text_size_input, "center", is_active_row)
                        f_render_cell(dashboard, 9, r, flow_txt,      color_text, flow_col,      text_size_input, "left",   is_active_row)
            else if is_combined
                if compact_view
                    f_render_cell(dashboard, 2, r, p1d_txt,                       color_text, p1d_col,                  text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 3, r, array.get(sma_statuses, i),    color_text, array.get(smacols, i),    text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 4, r, array.get(sma50_statuses, i),  color_text, array.get(sma50cols, i),  text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 5, r, array.get(sma200_statuses, i), color_text, array.get(sma200cols, i), text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 6, r, array.get(slope_statuses, i),  color_text, array.get(slopecols, i),  text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 7, r, array.get(statuses, i),       color_text, array.get(colors, i),     text_size_input, "center", is_active_row)
                else
                    f_render_cell(dashboard, 2, r, p1d_txt,                          color_text, p1d_col,     text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 3, r, p5d_txt,                          color_text, p5d_col,     text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 4, r, pytd_txt,                         color_text, pytd_col,    text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 5, r, p52h_txt,                         color_text, p52h_col,    text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 6, r, array.get(sma_statuses, i),       color_text, array.get(smacols, i),       text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 7, r, array.get(sma50_statuses, i),     color_text, array.get(sma50cols, i),     text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 8, r, array.get(sma200_statuses, i),    color_text, array.get(sma200cols, i),    text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 9, r, array.get(slope_statuses, i),     color_text, array.get(slopecols, i),     text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 10, r, array.get(statuses, i),          color_text, array.get(colors, i),        text_size_input, "center", is_active_row)
            else if show_breadth
                f_render_cell(dashboard, 2, r, array.get(sma_statuses, i),   color_text, array.get(smacols, i),    text_size_input, "center", is_active_row)
                f_render_cell(dashboard, 3, r, array.get(sma50_statuses, i), color_text, array.get(sma50cols, i),  text_size_input, "center", is_active_row)
                f_render_cell(dashboard, 4, r, array.get(sma200_statuses, i),color_text, array.get(sma200cols, i), text_size_input, "center", is_active_row)
                f_render_cell(dashboard, 5, r, array.get(slope_statuses, i), color_text, array.get(slopecols, i),  text_size_input, "center", is_active_row)
                f_render_cell(dashboard, 6, r, array.get(statuses, i),       color_text, array.get(colors, i),     text_size_input, "center", is_active_row)
            else if show_perf
                if compact_view
                    f_render_cell(dashboard, 2, r, p1d_txt,  color_text, p1d_col,  text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 3, r, pytd_txt, color_text, pytd_col, text_size_input, "center", is_active_row)
                else
                    f_render_cell(dashboard, 2, r, p1d_txt,  color_text, p1d_col,  text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 3, r, p5d_txt,  color_text, p5d_col,  text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 4, r, pytd_txt, color_text, pytd_col, text_size_input, "center", is_active_row)
                    f_render_cell(dashboard, 5, r, p52h_txt, color_text, p52h_col, text_size_input, "center", is_active_row)
    
    // --- Render Footer Row (Market Stance & Breadth Participation Ratios) ---
    // Rendered exclusively when breadth analytics are active (Market Breadth & Stance, Combined View).
    // Dynamically positioned at the bottom of the table: row index = act_count + 1 + (has_divider ? 1 : 0).
    // Displays aggregate long/short participation counts (Price > 20, 20 > 50, 50 > 200) and overall Stance / TOR / Bias:
    // - Combined View (11 columns standard, 8 columns compact): Maps ratios to moving average columns and stance metrics.
    // - Standalone Breadth View (7 columns): Maps ratios to Cols 2-4 and stance metrics to Cols 5-6.
    if show_breadth
        int footer_row = act_count + 1 + (has_divider ? 1 : 0)
        string ratio_text = str.tostring(lng_count) + "L / " + str.tostring(shrt_count) + "S"
        string ratio_text_20_50 = str.tostring(lng_20_50) + "L / " + str.tostring(shrt_20_50) + "S"
        string ratio_text_50_200 = str.tostring(lng_50_200) + "L / " + str.tostring(shrt_50_200) + "S"
        
        color bg_ratio_20     = f_get_ratio_bg(lng_count, shrt_count, color_pos_bg, color_warn_bg, color_bad_bg)
        color bg_ratio_20_50  = f_get_ratio_bg(lng_20_50, shrt_20_50, color_pos_bg, color_warn_bg, color_bad_bg)
        color bg_ratio_50_200 = f_get_ratio_bg(lng_50_200, shrt_50_200, color_pos_bg, color_warn_bg, color_bad_bg)
        
        if is_combined
            if compact_view
                f_set_cell_bold(dashboard, 0, footer_row, "Market Stance",      color_text, color_title_bg,  text_size_input, "left")
                f_set_cell_bold(dashboard, 1, footer_row, stance_value,         color_text, stance_bg_color, text_size_input, "left")
                f_set_cell_bold(dashboard, 2, footer_row, "--",                 color_text, color_title_bg,  text_size_input, "center")
                f_set_cell_bold(dashboard, 3, footer_row, ratio_text,           color_text, bg_ratio_20,     text_size_input, "center")
                f_set_cell_bold(dashboard, 4, footer_row, ratio_text_20_50,     color_text, bg_ratio_20_50,  text_size_input, "center")
                f_set_cell_bold(dashboard, 5, footer_row, ratio_text_50_200,    color_text, bg_ratio_50_200, text_size_input, "center")
                f_set_cell_bold(dashboard, 6, footer_row, stance_tor,           color_text, stance_bg_color, text_size_input, "center")
                f_set_cell_bold(dashboard, 7, footer_row, stance_bias,          color_text, stance_bg_color, text_size_input, "center")
            else
                f_set_cell_bold(dashboard, 0, footer_row, "Market Stance",      color_text, color_title_bg,  text_size_input, "left")
                f_set_cell_bold(dashboard, 1, footer_row, stance_value,         color_text, stance_bg_color, text_size_input, "left")
                f_set_cell_bold(dashboard, 2, footer_row, "--",                 color_text, color_title_bg,  text_size_input, "center")
                f_set_cell_bold(dashboard, 3, footer_row, "--",                 color_text, color_title_bg,  text_size_input, "center")
                f_set_cell_bold(dashboard, 4, footer_row, "--",                 color_text, color_title_bg,  text_size_input, "center")
                f_set_cell_bold(dashboard, 5, footer_row, "--",                 color_text, color_title_bg,  text_size_input, "center")
                f_set_cell_bold(dashboard, 6, footer_row, ratio_text,           color_text, bg_ratio_20,     text_size_input, "center")
                f_set_cell_bold(dashboard, 7, footer_row, ratio_text_20_50,     color_text, bg_ratio_20_50,  text_size_input, "center")
                f_set_cell_bold(dashboard, 8, footer_row, ratio_text_50_200,    color_text, bg_ratio_50_200, text_size_input, "center")
                f_set_cell_bold(dashboard, 9, footer_row, stance_tor,           color_text, stance_bg_color, text_size_input, "center")
                f_set_cell_bold(dashboard, 10, footer_row, stance_bias,         color_text, stance_bg_color, text_size_input, "center")
        else
            f_set_cell_bold(dashboard, 0, footer_row, "Market Stance",      color_text, color_title_bg,  text_size_input, "left")
            f_set_cell_bold(dashboard, 1, footer_row, stance_value,         color_text, stance_bg_color, text_size_input, "left")
            f_set_cell_bold(dashboard, 2, footer_row, ratio_text,           color_text, bg_ratio_20,     text_size_input, "center")
            f_set_cell_bold(dashboard, 3, footer_row, ratio_text_20_50,     color_text, bg_ratio_20_50,  text_size_input, "center")
            f_set_cell_bold(dashboard, 4, footer_row, ratio_text_50_200,    color_text, bg_ratio_50_200, text_size_input, "center")
            f_set_cell_bold(dashboard, 5, footer_row, stance_tor,           color_text, stance_bg_color, text_size_input, "center")
            f_set_cell_bold(dashboard, 6, footer_row, stance_bias,          color_text, stance_bg_color, text_size_input, "center")

    // ==========================================
    // 7. REAL-TIME ALERTING ENGINE (Bar Close Only)
    // ==========================================
    // Re-initialize baseline state when switching universe/country to prevent false cross-universe triggers
    if active_country != prev_country
        alerts_initialized := false
        prev_country       := active_country

    if not alerts_initialized
        prev_stance := stance_value
        if act_count > 0
            for i = 0 to act_count - 1
                array.set(prev_flow_badges, i, array.get(flow_badges, i))
        alerts_initialized := true
    else if barstate.isconfirmed
        // 1. Market Stance Shift Alert
        if stance_value != prev_stance and stance_value != ""
            cond_stance_shift := true
            string p_old      = prev_stance != "" ? prev_stance : "Initial"
            string b_bull     = str.tostring(math.round(constructive_pct)) + "% Bull"
            string b_bear     = str.tostring(math.round(bear_pct)) + "% Bear"
            string msg_stance = "[Market Stance Shift] " + active_country + "\nStance: " + p_old + " ➔ " + stance_value + "\nBias: " + stance_bias + " | Breadth: " + b_bull + " / " + b_bear
            alert(msg_stance, alert.freq_once_per_bar)
            prev_stance := stance_value

        // 2. Sector Rotation Alert (Batched Across Rotating Sectors)
        if act_count > key_count
            string batch_lines = ""
            int rot_count      = 0

            for i = key_count to act_count - 1
                string curr_b = array.get(flow_badges, i)
                string old_b  = array.get(prev_flow_badges, i)
                if curr_b != old_b
                    bool is_curr_leader   = str.contains(curr_b, "Core Leader")
                    bool is_old_leader    = str.contains(old_b, "Core Leader")
                    bool became_leader    = is_curr_leader and not is_old_leader

                    bool is_curr_emerging = str.contains(curr_b, "Emerging")
                    bool is_old_emerging  = str.contains(old_b, "Emerging")
                    bool became_emerging  = is_curr_emerging and not is_old_emerging

                    bool is_curr_fading   = str.contains(curr_b, "Fading")
                    bool is_old_fading    = str.contains(old_b, "Fading")
                    bool became_fading    = is_curr_fading and not is_old_fading

                    if became_leader or became_emerging or became_fading
                        rot_count += 1
                        string s_name      = array.get(act_names, i)
                        string s_sym       = array.get(act_syms, i)
                        string old_b_clean = old_b != "" ? old_b : "Stable"
                        batch_lines += "\n• " + s_name + " (" + s_sym + "): " + old_b_clean + " ➔ " + curr_b

                    array.set(prev_flow_badges, i, curr_b)

            if rot_count > 0
                cond_sector_rot := true
                string header_rot = "[Sector Rotation] " + active_country + (rot_count > 1 ? (" (" + str.tostring(rot_count) + " Sectors)") : "")
                string msg_rot = header_rot + batch_lines
                alert(msg_rot, alert.freq_once_per_bar)

// ==========================================
// 8. ALERT CONDITIONS (TradingView Dropdown Menu)
// ==========================================
alertcondition(cond_stance_shift, title="Market Stance Shift",          message="[Market Stance Shift] Market stance regime changed on {{ticker}}. Check dashboard for updated stance and breadth.")
alertcondition(cond_sector_rot,   title="Sector Leadership Transition", message="[Sector Rotation] Key sector leadership transition detected on {{ticker}}. Check dashboard for details.")
````

<!-- tradingview-pine-id: PUB;286e6154995842a29f43d01b3975d425 -->
<!-- tradingviewscripts-format: 1 -->
# Mag 7 ORB Dashboard Rsvol2

Source: https://www.tradingview.com/script/cRTqw6ul-Mag-7-ORB-Dashboard-Rs/

## Description

Mag 7 ORB Dashboard Rsvol2 is a multi‑symbol Opening Range Breakout (ORB) scanner designed to give traders instant insight into early‑session momentum across the market’s most influential names. It tracks both the 15‑minute ORB and 30‑minute ORB for the entire Magnificent 7 (AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA) plus SPY and QQQ, then displays their breakout status in a clean, customizable dashboard.

This indicator helps traders quickly identify which leaders are breaking out, breaking down, or staying inside their opening range—providing a fast read on market strength, weakness, and trend alignment.

🔷 What It Shows
1. 15m & 30m ORB Levels
Plots the Opening Range High/Low for the first 15 minutes and first 30 minutes.

Color‑coded lines for easy visual tracking.

Helps identify early breakouts, reversals, and failed ORBs.

2. Multi‑Symbol ORB Dashboard
A compact table showing:

Bullish (price above ORB high)

Bearish (price below ORB low)

Inside (price still within ORB range)

Symbols included:

AAPL

MSFT

GOOGL

AMZN

NVDA

META

TSLA

SPY

QQQ

Supports short text mode for mobile traders.

3. Market Sentiment Summary
The dashboard calculates:

15m ORB sentiment

30m ORB sentiment

If 4 or more Mag 7 names break in the same direction, the dashboard flags:

Bullish

Bearish

Mixed

This gives traders a quick read on broad market momentum.

🎯 Why Traders Use It
Quickly spot which major stocks are driving early‑session strength or weakness.

Identify high‑probability ORB setups across multiple symbols at once.

Gauge market sentiment without scanning charts individually.

Ideal for day traders, ORB traders, and anyone who relies on early‑session momentum.

⚙️ Customization
Toggle 15m/30m ORB lines

Choose dashboard size and position

Select short or full text labels

Customize bull/bear/neutral colors

---

## Source Code

````pine
//@version=6
indicator("Mag 7 ORB Dashboard Rsvol2", shorttitle="ORB Dash", overlay=true)

// --- Inputs ---
showLines15 = input.bool(true, "Show 15m ORB Lines", group="Visibility")
showLines30 = input.bool(true, "Show 30m ORB Lines", group="Visibility")
showTable = input.bool(true, "Show Dashboard", group="Visibility")

tablePos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Dashboard Settings")
tableSize = input.string("Tiny", "Dashboard Size", options=["Tiny", "Small", "Normal", "Large"], group="Dashboard Settings")
shortText = input.bool(true, "Use Short Text (Mobile Friendly)", group="Dashboard Settings")

// --- Styling ---
bullColor = input.color(#089981, "Dashboard Bull Color", group="Style - Dashboard")
bearColor = input.color(#f23645, "Dashboard Bear Color", group="Style - Dashboard")
neutralColor = input.color(color.gray, "Dashboard Neutral Color", group="Style - Dashboard")
dashBgColor = input.color(color.new(color.black, 80), "Dashboard Background", group="Style - Dashboard")
dashHeaderColor = input.color(color.new(color.gray, 80), "Dashboard Header", group="Style - Dashboard")

orb15HighColor = input.color(color.new(#089981, 0), "15m ORB High Color", group="Style - 15m Lines")
orb15LowColor  = input.color(color.new(#f23645, 0), "15m ORB Low Color", group="Style - 15m Lines")
orb15Width = input.int(2, "15m Line Width", minval=1, maxval=4, group="Style - 15m Lines")

orb30HighColor = input.color(color.new(#089981, 50), "30m ORB High Color", group="Style - 30m Lines")
orb30LowColor  = input.color(color.new(#f23645, 50), "30m ORB Low Color", group="Style - 30m Lines")
orb30Width = input.int(2, "30m Line Width", minval=1, maxval=4, group="Style - 30m Lines")

// --- Constants ---
var string SESSION_15 = "0930-0945:23456"
var string SESSION_30 = "0930-1000:23456"
var string TIMEZONE = "America/New_York"

// --- Functions ---
get_orb_data() =>
    var float orb15_h = na
    var float orb15_l = na
    var float orb30_h = na
    var float orb30_l = na
    
    in_sess15 = not na(time(timeframe.period, SESSION_15, TIMEZONE))
    is_first15 = in_sess15 and not in_sess15[1]
    
    if is_first15
        orb15_h := high
        orb15_l := low
    else if in_sess15
        orb15_h := math.max(orb15_h, high)
        orb15_l := math.min(orb15_l, low)
        
    in_sess30 = not na(time(timeframe.period, SESSION_30, TIMEZONE))
    is_first30 = in_sess30 and not in_sess30[1]
    
    if is_first30
        orb30_h := high
        orb30_l := low
    else if in_sess30
        orb30_h := math.max(orb30_h, high)
        orb30_l := math.min(orb30_l, low)
        
    stat15 = close > orb15_h ? 1 : close < orb15_l ? -1 : 0
    stat30 = close > orb30_h ? 1 : close < orb30_l ? -1 : 0
    
    [orb15_h, orb15_l, stat15, orb30_h, orb30_l, stat30]

// --- Current Chart ORB Plotting ---
[c_h15, c_l15, c_s15, c_h30, c_l30, c_s30] = get_orb_data()

plot(showLines15 ? c_h15 : na, "15m ORB High", color=orb15HighColor, style=plot.style_linebr, linewidth=orb15Width)
plot(showLines15 ? c_l15 : na, "15m ORB Low", color=orb15LowColor, style=plot.style_linebr, linewidth=orb15Width)
plot(showLines30 ? c_h30 : na, "30m ORB High", color=orb30HighColor, style=plot.style_linebr, linewidth=orb30Width, format=format.price)
plot(showLines30 ? c_l30 : na, "30m ORB Low", color=orb30LowColor, style=plot.style_linebr, linewidth=orb30Width, format=format.price)

// --- Security Calls ---
get_sym_status(sym) =>
    [h15, l15, s15, h30, l30, s30] = request.security(sym, timeframe.period, get_orb_data())
    [s15, s30]

[aapl_15, aapl_30]   = get_sym_status("NASDAQ:AAPL")
[msft_15, msft_30]   = get_sym_status("NASDAQ:MSFT")
[googl_15, googl_30] = get_sym_status("NASDAQ:GOOGL")
[amzn_15, amzn_30]   = get_sym_status("NASDAQ:AMZN")
[nvda_15, nvda_30]   = get_sym_status("NASDAQ:NVDA")
[meta_15, meta_30]   = get_sym_status("NASDAQ:META")
[tsla_15, tsla_30]   = get_sym_status("NASDAQ:TSLA")
[spy_15, spy_30]     = get_sym_status("AMEX:SPY")
[qqq_15, qqq_30]     = get_sym_status("NASDAQ:QQQ")

// --- Dashboard ---
var position = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
var t_size = tableSize == "Tiny" ? size.tiny : tableSize == "Small" ? size.small : tableSize == "Large" ? size.large : size.normal

var table dash = table.new(position, 3, 11, border_width=1, border_color=color.new(color.gray, 80))

add_row(tbl, row, sym_name, stat15, stat30, bCol, brCol, nCol, ts, bgC, use_short) =>
    bg15 = stat15 == 1 ? color.new(bCol, 80) : stat15 == -1 ? color.new(brCol, 80) : color.new(nCol, 80)
    tc15 = stat15 == 1 ? bCol : stat15 == -1 ? brCol : nCol
    tx15 = use_short ? (stat15 == 1 ? "UP" : stat15 == -1 ? "DN" : "-") : (stat15 == 1 ? "Bullish" : stat15 == -1 ? "Bearish" : "Inside")
    
    bg30 = stat30 == 1 ? color.new(bCol, 80) : stat30 == -1 ? color.new(brCol, 80) : color.new(nCol, 80)
    tc30 = stat30 == 1 ? bCol : stat30 == -1 ? brCol : nCol
    tx30 = use_short ? (stat30 == 1 ? "UP" : stat30 == -1 ? "DN" : "-") : (stat30 == 1 ? "Bullish" : stat30 == -1 ? "Bearish" : "Inside")
    
    table.cell(tbl, 0, row, sym_name, text_color=color.white, bgcolor=bgC, text_size=ts)
    table.cell(tbl, 1, row, tx15, text_color=tc15, bgcolor=bg15, text_size=ts)
    table.cell(tbl, 2, row, tx30, text_color=tc30, bgcolor=bg30, text_size=ts)

if barstate.islast
    if showTable
        table.cell(dash, 0, 0, "Sym", text_color=color.white, bgcolor=dashHeaderColor, text_size=t_size)
        table.cell(dash, 1, 0, "15m", text_color=color.white, bgcolor=dashHeaderColor, text_size=t_size)
        table.cell(dash, 2, 0, "30m", text_color=color.white, bgcolor=dashHeaderColor, text_size=t_size)
        
        add_row(dash, 1, "AAPL", aapl_15, aapl_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        add_row(dash, 2, "MSFT", msft_15, msft_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        add_row(dash, 3, "GOOGL", googl_15, googl_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        add_row(dash, 4, "AMZN", amzn_15, amzn_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        add_row(dash, 5, "NVDA", nvda_15, nvda_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        add_row(dash, 6, "META", meta_15, meta_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        add_row(dash, 7, "TSLA", tsla_15, tsla_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        
        add_row(dash, 8, "SPY", spy_15, spy_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        add_row(dash, 9, "QQQ", qqq_15, qqq_30, bullColor, bearColor, neutralColor, t_size, dashBgColor, shortText)
        
        // Sentiment (15m)
        b1_15 = aapl_15 == 1 ? 1 : 0
        b2_15 = msft_15 == 1 ? 1 : 0
        b3_15 = googl_15 == 1 ? 1 : 0
        b4_15 = amzn_15 == 1 ? 1 : 0
        b5_15 = nvda_15 == 1 ? 1 : 0
        b6_15 = meta_15 == 1 ? 1 : 0
        b7_15 = tsla_15 == 1 ? 1 : 0
        bulls_15 = b1_15 + b2_15 + b3_15 + b4_15 + b5_15 + b6_15 + b7_15
        
        br1_15 = aapl_15 == -1 ? 1 : 0
        br2_15 = msft_15 == -1 ? 1 : 0
        br3_15 = googl_15 == -1 ? 1 : 0
        br4_15 = amzn_15 == -1 ? 1 : 0
        br5_15 = nvda_15 == -1 ? 1 : 0
        br6_15 = meta_15 == -1 ? 1 : 0
        br7_15 = tsla_15 == -1 ? 1 : 0
        bears_15 = br1_15 + br2_15 + br3_15 + br4_15 + br5_15 + br6_15 + br7_15
        
        // Sentiment (30m)
        b1_30 = aapl_30 == 1 ? 1 : 0
        b2_30 = msft_30 == 1 ? 1 : 0
        b3_30 = googl_30 == 1 ? 1 : 0
        b4_30 = amzn_30 == 1 ? 1 : 0
        b5_30 = nvda_30 == 1 ? 1 : 0
        b6_30 = meta_30 == 1 ? 1 : 0
        b7_30 = tsla_30 == 1 ? 1 : 0
        bulls_30 = b1_30 + b2_30 + b3_30 + b4_30 + b5_30 + b6_30 + b7_30
        
        br1_30 = aapl_30 == -1 ? 1 : 0
        br2_30 = msft_30 == -1 ? 1 : 0
        br3_30 = googl_30 == -1 ? 1 : 0
        br4_30 = amzn_30 == -1 ? 1 : 0
        br5_30 = nvda_30 == -1 ? 1 : 0
        br6_30 = meta_30 == -1 ? 1 : 0
        br7_30 = tsla_30 == -1 ? 1 : 0
        bears_30 = br1_30 + br2_30 + br3_30 + br4_30 + br5_30 + br6_30 + br7_30
        
        txt_15 = bulls_15 >= 4 ? (shortText ? "BULL" : "Bullish") : bears_15 >= 4 ? (shortText ? "BEAR" : "Bearish") : (shortText ? "-" : "Mixed")
        col_15 = bulls_15 >= 4 ? bullColor : bears_15 >= 4 ? bearColor : neutralColor
        
        txt_30 = bulls_30 >= 4 ? (shortText ? "BULL" : "Bullish") : bears_30 >= 4 ? (shortText ? "BEAR" : "Bearish") : (shortText ? "-" : "Mixed")
        col_30 = bulls_30 >= 4 ? bullColor : bears_30 >= 4 ? bearColor : neutralColor
        
        table.cell(dash, 0, 10, shortText ? "Sent" : "Sentiment", text_color=color.white, bgcolor=dashBgColor, text_size=t_size)
        table.cell(dash, 1, 10, txt_15, text_color=color.white, bgcolor=color.new(col_15, 50), text_size=t_size)
        table.cell(dash, 2, 10, txt_30, text_color=color.white, bgcolor=color.new(col_30, 50), text_size=t_size)
    else
        table.clear(dash, 0, 0, 2, 10)
````

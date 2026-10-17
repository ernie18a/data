# Auto Chart Pattern V2 STARTER - DEMO //BPS

- url: https://www.tradingview.com/script/IxUcLh0D/
- type: indicator
- pine_id: PUB;73a1ebd684314b82880e3ac4650a84bf
- version: 1.0

## Description

⚠️ This is a DEMO / visualization template. It does NOT detect patterns and does NOT generate live signals.

A visual replica of the Auto Chart Pattern V2 STARTER look-and-feel — used for educational walkthroughs, backtest screenshots, and pattern-stats demonstrations.

What this script does:
• Displays a pre-formatted statistics table (14 chart patterns + TOTAL row + equity + drawdown + target metrics)
• Renders one example "last pattern" trade with TP / SL projection boxes
• Replicates the exact table layout, colors, fonts, and structure of the real Auto Chart Pattern V2 indicator
• Shows what backtest output looks like before purchasing or trying the full version

What this script does NOT do:
• ❌ No real-time pattern detection
• ❌ No alerts or webhooks
• ❌ No actual trade signals
• ❌ No backtest computation — all values are hardcoded for demonstration
• ❌ Settings dialog controls do not influence the chart output

Who is this for:
• Traders curious how the real Auto Chart Pattern V2 statistics look on different instruments
• Educators / content creators who want to illustrate pattern recognition workflows
• Marketing material and tutorials

Looking for the real indicator?
Source: bestpinescripts.com — the live version includes auto-pattern detection for 14 chart patterns, smart exits, F1/F2/F3 entry filters, backtest engine with equity curve, broker cost modeling, and webhook auto-trading.

Default demo values:
Snapshot from SNDK 5m: 505 trades, 52.3 % overall win-rate, +$1,598 net, 159.8 % return, 14.05 % max drawdown. Rectangle pattern at 66.1 % win-rate.

How to customize:
All demo values are hardcoded as const declarations at the top of the script. To create a screenshot for a different instrument, edit the values directly in the source code and reload.

⚠️ DISCLAIMER
The statistics, equity curves, and trade projections displayed by this indicator are hardcoded demonstration values — they are NOT computed from market data and do NOT represent any real trade results. Past performance does not guarantee future results. This indicator is for visualization and educational purposes only. Nothing displayed constitutes financial advice, an investment recommendation, or a trading signal. Trading involves substantial risk of loss. Always use proper risk management and do your own analysis.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════
// ⭐ Auto Chart Pattern V2 STARTER — DEMO //BPS
// ═══════════════════════════════════════════════════════════════════
//
// ⚠️ DEMO VERSION — NOT FOR LIVE TRADING.
//
// Look-and-feel is 1:1 identical to the real ACP V2 STARTER. The
// Settings dialog shows the same Inputs (Pattern toggles, F1/F2/F3
// filters, SL/TP %, etc.) for authentic look — but they DO NOT
// change anything in this demo build.
//
// All marketing values (stats table, equity, last-pattern position)
// are HARDCODED at the top of this file. To create a new marketing
// screenshot for a different symbol, edit the const block below,
// reload the indicator, screenshot, done.
//
// For real backtesting + live trading: bestpinescripts.com
//
// © GLOMASTCO Ltd. (Cyprus) • All Rights Reserved
// ═══════════════════════════════════════════════════════════════════
//@version=6
indicator("Auto Chart Pattern V2 STARTER , Auto Pattern Detection //BPS - DEMO",
     overlay=true, shorttitle="Pattern V2 STARTER //BPS DEMO",
     max_labels_count=500, max_lines_count=500, max_boxes_count=200, max_bars_back=5000)

// ════════════════════════════════════════════════════════════════════
// 🎬 HARDCODED DEMO VALUES — edit here, not via Settings dialog
// ════════════════════════════════════════════════════════════════════
// Default values below = SNDK 5m snapshot. To repurpose this demo for
// another instrument/timeframe, replace the strings here and reload.

// Stats — one CSV row per pattern.
// Format: "Pattern,Count,Wins,Losses,Win%,$Won,$Lost,Net$,Open"
const string DEMO_P_DOUBLE_TOP    = "Double Top ▼,0,0,0,—,0,0,+0,0"
const string DEMO_P_DOUBLE_BOT    = "Double Bot ▲,144,85,59,59,1087.26,918.43,+168.83,0"
const string DEMO_P_TRIPLE_TOP    = "Triple Top ▼,0,0,0,—,0,0,+0,0"
const string DEMO_P_TRIPLE_BOT    = "Triple Bot ▲,33,21,12,63.6,300,171.47,+128.53,0"
const string DEMO_P_HS            = "H&S ▼,0,0,0,—,0,0,+0,0"
const string DEMO_P_INV_HS        = "Inv. H&S ▲,15,1,14,6.7,37.02,244.41,-207.4,0"
const string DEMO_P_ASC_TRI       = "Asc. Tri ▲,61,32,29,52.5,502.63,495.37,+7.26,0"
const string DEMO_P_DESC_TRI      = "Desc. Tri ▼,0,0,0,—,0,0,+0,0"
const string DEMO_P_SYM_TRI       = "Sym. Tri ◆,84,28,55,33.7,1772.49,951.66,+820.83,1"
const string DEMO_P_RISING_WEDGE  = "Rising Wedge ▼,0,0,0,—,0,0,+0,0"
const string DEMO_P_FALLING_WEDGE = "Falling Wedge ▲,41,23,18,56.1,757.96,348.1,+409.86,0"
const string DEMO_P_BULL_FLAG     = "Bull Flag ▲,67,35,32,52.2,640.76,616.63,+24.12,0"
const string DEMO_P_BEAR_FLAG     = "Bear Flag ▼,0,0,0,—,0,0,+0,0"
const string DEMO_P_RECTANGLE     = "Rectangle ◆,60,39,20,66.1,529.41,283.11,+246.3,1"
const string DEMO_P_TOTAL         = "TOTAL,505,264,239,52.3,5627.53,4029.19,+1598.34,2"

// Equity / DD / Target summary strings (displayed in the highlighted rows)
const string DEMO_EQ_VALUE   = "$2598.34 (+159.8%)"
const string DEMO_EQ_YEARLY  = "$2924.31 (+192.4%)"
const string DEMO_DAILY_DD   = "1.04/5"
const string DEMO_TOTAL_DD   = "14.05/10"
const string DEMO_TARGET     = "159.8/30"
const string DEMO_BARS_INFO  = "2094 bars = 1674.5h ≈ 209.3 trading-days"

// Telegram CTA
const string DEMO_TELEGRAM = "@bestpinescripts"

// Last-pattern visualization (the Rectangle ▲▲ box + TP/SL projection)
// All three prices below are HARDCODED ABSOLUTE values so the labels
// match the screenshot exactly (no % rounding drift).
const bool   DEMO_SHOW_PATTERN     = true
const string DEMO_PATTERN_NAME     = "Rectangle ▲▲"
const string DEMO_PATTERN_DIR      = "LONG"           // "LONG" or "SHORT"
const int    DEMO_PATTERN_BOX_L    = 35                // bars ago for left edge
const int    DEMO_PATTERN_BOX_R    = 1                 // bars ago for right edge
const int    DEMO_ENTRY_BAR_OFF    = 1                 // bars ago for entry (1 = previous bar = 19:55 on 5m)
const float  DEMO_ENTRY_PRICE      = 1689.54           // hardcoded entry price (SNDK 19:55)
const float  DEMO_TP_PRICE         = 1741.41           // hardcoded TP price
const float  DEMO_SL_PRICE         = 1651.97           // hardcoded SL price
const float  DEMO_PATTERN_TOP_PCT  = 0.3               // pattern box % above entry
const float  DEMO_PATTERN_BOT_PCT  = 1.5               // pattern box % below entry
const string DEMO_TP_LABEL_SUFFIX  = "+3.09% TP - Pat 120%"
const string DEMO_SL_LABEL_SUFFIX  = "-2.21% - SL 80%"
const int    DEMO_PROJECTION_BARS  = 15                // TP/SL projection width
const bool   DEMO_SHOW_ST          = true              // ST = Setup Trigger label
const bool   DEMO_SHOW_SL_MINI     = true              // small "Sl" inside-box label

// DEMO red banner (top-right corner)
const bool DEMO_SHOW_BANNER = true

// ════════════════════════════════════════════════════════════════════
// AUTHENTIC INPUTS — identical shape to the real ACP V2 STARTER.
// All inputs are display.none so they don't bloat the chart status-line.
// They still appear in the Settings dialog for authentic look, but they
// are NOT used anywhere in this demo build.
// ════════════════════════════════════════════════════════════════════
grpPromo = "BestPineScripts"
_telegram = input.string("I follow",
     "Follow us on Telegram @bestpinescripts for the best Symbols, Timeframes and Options",
     options=["I follow", "I try myself"], group=grpPromo, display=display.none)

grpDir = "🎯 Trade Direction"
tradeDirection = input.string("Long Only", "Trade Direction",
     options=["Both", "Long Only", "Short Only"], group=grpDir, display=display.none)

grpToggle = "🔘 Classic Patterns"
enDT  = input.bool(true,  "Double Top ▼",       group=grpToggle, inline="t1",  display=display.none)
enDB  = input.bool(true,  "Double Bottom ▲",    group=grpToggle, inline="t1",  display=display.none)
enTT  = input.bool(true,  "Triple Top ▼",       group=grpToggle, inline="t1b", display=display.none)
enTB  = input.bool(true,  "Triple Bottom ▲",    group=grpToggle, inline="t1b", display=display.none)
enHS  = input.bool(true,  "Head & Shoulders ▼", group=grpToggle, inline="t2",  display=display.none)
enIHS = input.bool(true,  "Inverse H&S ▲",      group=grpToggle, inline="t2",  display=display.none)

grpToggle2 = "🔘 Triangle & Wedge Patterns"
enAT  = input.bool(true,  "Ascending Triangle ▲",   group=grpToggle2, inline="t3",  display=display.none)
enDST = input.bool(true,  "Descending Triangle ▼",  group=grpToggle2, inline="t3b", display=display.none)
enSYM = input.bool(true,  "Symmetrical Triangle ◆", group=grpToggle2, inline="t3c", display=display.none)
enRW  = input.bool(true,  "Rising Wedge ▼",         group=grpToggle2, inline="t4",  display=display.none)
enFW  = input.bool(true,  "Falling Wedge ▲",        group=grpToggle2, inline="t4",  display=display.none)

grpToggle3 = "🔘 Continuation Patterns"
enBF  = input.bool(true,  "Bull Flag ▲",         group=grpToggle3, inline="t5", display=display.none)
enBRF = input.bool(true,  "Bear Flag ▼",         group=grpToggle3, inline="t5", display=display.none)
enREC = input.bool(true,  "Rectangle/Range ◆",   group=grpToggle3, inline="t6", display=display.none)

grpAdjust = "🎚 SL / TP Adjustments"
slAdjust = input.int(80,  "SL Adjustment %", minval=50,  maxval=150, step=5, group=grpAdjust, display=display.none)
tpAdjust = input.int(120, "TP Adjustment %", minval=20,  maxval=300, step=5, group=grpAdjust, display=display.none)

grpRCTrend = "📐 F1: Rectangle Trend Filter"
enRCTrend      = input.bool(true,  "Enable Rectangle Trend Filter", group=grpRCTrend, display=display.none)
rcConfirmCount = input.int(2,      "Confirmations for direction change", minval=1, maxval=3, group=grpRCTrend, display=display.none)

grpEqCurve = "📈 F2: Equity Curve Filter"
enEqCurve   = input.bool(false, "Pause after loss streak", group=grpEqCurve, display=display.none)
eqMaxLosses = input.int(3,      "Max consecutive losses",  minval=2, maxval=10, group=grpEqCurve, display=display.none)
eqPauseBars = input.int(30,     "Pause duration (bars)",   minval=5, maxval=200, group=grpEqCurve, display=display.none)

grpVola = "⚡ F3: Volatility Pause Filter"
enVolaPause = input.bool(false, "Enable Volatility Pause", group=grpVola, display=display.none)
volaTF      = input.string("15", "Volatility Timeframe",  options=["5","15","30","60"], group=grpVola, display=display.none)
volaATRLen  = input.int(14,     "ATR Length",             minval=5, maxval=50, group=grpVola, display=display.none)
volaATRMult = input.float(2.0,  "ATR Multiplier (pause when above)", minval=1.2, maxval=5.0, step=0.1, group=grpVola, display=display.none)

grpEquity = "💰 Equity & Risk"
startBalance = input.float(1000.0, "Start Balance ($)", minval=10, maxval=1000000, step=100, group=grpEquity, display=display.none)
riskPct      = input.float(1.0,    "Risk per Trade (%)", minval=0.1, maxval=10, step=0.1, group=grpEquity, display=display.none)
riskMode     = input.string("Compounding", "Risk Mode", options=["Compounding","Fixed"], group=grpEquity, display=display.none)

grpCosts = "💸 Broker Costs"
autoBroker     = input.string("Auto-Detect", "Auto Broker Spread",
     options=["Off","Auto-Detect","Vantage","FxPro","IC Markets","Pepperstone"], group=grpCosts, display=display.none)
commissionUsd  = input.float(0.0,  "Commission per Trade ($)", minval=0.0, maxval=100.0, step=0.5, group=grpCosts, display=display.none)
spreadManual   = input.float(0.05, "Spread / Slippage manual (%)", minval=0.0, maxval=2.0, step=0.01, group=grpCosts, display=display.none)

grpDisplay = "🎨 Display"
showLastOnly  = input.bool(true,  "Show Last Pattern Only", group=grpDisplay, display=display.none)
showTable     = input.bool(true,  "Show Statistics Table",  group=grpDisplay, display=display.none)
tablePos      = input.string("Bottom Left", "Table Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpDisplay, display=display.none)
tableSize     = input.string("Small", "Table Font Size", options=["Small","Normal","Large"], group=grpDisplay, display=display.none)
tableTheme    = input.string("Auto", "Table Theme", options=["Auto","Dark","Light"], group=grpDisplay, display=display.none)

// ════════════════════════════════════════════════════════════
// COLORS (BPS palette — same as real STARTER)
// ════════════════════════════════════════════════════════════
tblSize = switch tableSize
    "Small" => size.tiny
    "Large" => size.normal
    => size.small

bigSz = tblSize == size.tiny ? size.small : tblSize == size.small ? size.normal : size.large

colLong       = #22c55e
colShort      = #ef4444
colPrim       = #3b82f6
colPrim2      = #1e88e5
colNeutral    = #8b94a8

// Per-pattern row colors (matches real STARTER)
colDoubleTop   = #ef4444
colDoubleBot   = #22c55e
colTripleTop   = #ef4444
colTripleBot   = #22c55e
colHs          = #ef4444
colInvHs       = #22c55e
colAscTri      = #22c55e
colDescTri     = #ef4444
colSymTri      = #f59e0b
colRisingWdg   = #ef4444
colFallingWdg  = #22c55e
colBullFlag    = #22c55e
colBearFlag    = #ef4444
colRectangle   = #f59e0b

// Theme detection
bgBright = color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color)
isDark   = tableTheme == "Dark" ? true : tableTheme == "Light" ? false : bgBright < 384

tFrameBg   = isDark ? color.new(#0a0e1a, 5)  : color.new(#fafafa, 5)
tFrameLine = isDark ? color.new(color.gray, 50) : color.new(color.gray, 60)
txtPrim    = isDark ? color.white : #1a1a1a
txtMute    = isDark ? color.gray  : color.new(#1a1a1a, 30)
txtWarn    = isDark ? color.yellow : #b8860b
hBG        = isDark ? color.new(#141a2e, 0) : color.new(#f0f0f0, 0)

// ════════════════════════════════════════════════════════════
// HELPER: parse CSV row
// ════════════════════════════════════════════════════════════
f_parse(string row, int idx) =>
    array<string> arr = str.split(row, ",")
    arr.size() > idx ? str.trim(array.get(arr, idx)) : ""

// ════════════════════════════════════════════════════════════
// LAST PATTERN VISUALIZATION (Rectangle box + entry/TP/SL)
// ════════════════════════════════════════════════════════════
if DEMO_SHOW_PATTERN and barstate.islast
    int leftBar  = bar_index - DEMO_PATTERN_BOX_L
    int rightBar = bar_index - DEMO_PATTERN_BOX_R
    int entryBar = bar_index - DEMO_ENTRY_BAR_OFF
    int projBar  = bar_index + DEMO_PROJECTION_BARS
    float entryPrice = DEMO_ENTRY_PRICE > 0 ? DEMO_ENTRY_PRICE : close[DEMO_ENTRY_BAR_OFF]

    // Pattern box (gray border, transparent fill — matches real STARTER)
    float patTop = entryPrice * (1 + DEMO_PATTERN_TOP_PCT / 100.0)
    float patBot = entryPrice * (1 - DEMO_PATTERN_BOT_PCT / 100.0)
    box.new(leftBar, patTop, rightBar, patBot, xloc=xloc.bar_index, bgcolor=color.new(color.gray, 90), border_color=color.new(color.gray, 50), border_width=1)
    label.new(rightBar, (patTop + patBot) / 2.0, DEMO_PATTERN_NAME, xloc=xloc.bar_index, color=color.new(#8b94a8, 60), textcolor=color.white, size=size.tiny, style=label.style_label_left)

    // ST (Setup Trigger) label
    if DEMO_SHOW_ST
        label.new(rightBar, patTop, "ST", xloc=xloc.bar_index, color=color.new(#7f1d1d, 30), textcolor=color.white, size=size.tiny, style=label.style_label_down)

    // Sl mini-label (inside box)
    if DEMO_SHOW_SL_MINI
        int slBar = entryBar - 5
        label.new(slBar, entryPrice * 0.995, "Sl", xloc=xloc.bar_index, color=color.new(#a16207, 40), textcolor=color.white, size=size.tiny, style=label.style_label_up)

    // TP / SL projection boxes — use the hardcoded absolute prices so the
    // labels read exactly "1741.41" / "1651.97" (no % rounding drift).
    bool isLong = DEMO_PATTERN_DIR == "LONG"
    float tpPrice = DEMO_TP_PRICE
    float slPrice = DEMO_SL_PRICE

    box.new(entryBar, math.max(entryPrice, tpPrice), projBar, math.min(entryPrice, tpPrice), xloc=xloc.bar_index, bgcolor=color.new(colLong, 80), border_color=color.new(colLong, 40), border_width=1)
    box.new(entryBar, math.max(entryPrice, slPrice), projBar, math.min(entryPrice, slPrice), xloc=xloc.bar_index, bgcolor=color.new(colShort, 80), border_color=color.new(colShort, 40), border_width=1)

    // TP/SL labels at projection edge (matches real STARTER)
    label.new(projBar, tpPrice, "  🎯 " + str.tostring(tpPrice, format.mintick) + " (" + DEMO_TP_LABEL_SUFFIX + ")  ", xloc=xloc.bar_index, color=color.new(colLong, 10), textcolor=color.white, size=size.tiny, style=label.style_label_left)
    label.new(projBar, slPrice, "  ⛔ " + str.tostring(slPrice, format.mintick) + " (" + DEMO_SL_LABEL_SUFFIX + ")  ", xloc=xloc.bar_index, color=color.new(colShort, 10), textcolor=color.white, size=size.tiny, style=label.style_label_left)

// ════════════════════════════════════════════════════════════
// STATS TABLE — replicates real STARTER exactly
// ════════════════════════════════════════════════════════════
var table t = table.new(position.bottom_left, 9, 30, bgcolor=tFrameBg, border_width=1, border_color=tFrameLine, frame_width=2, frame_color=color.gray, force_overlay=true)

if showTable and barstate.islast
    // Position
    tPos = tablePos == "Top Left" ? position.top_left : tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Left" ? position.bottom_left : position.bottom_right
    table.set_position(t, tPos)

    // Title header bar (exact STARTER format)
    string title = "Auto Chart Pattern V2 , Auto Pattern Detection + Smart Exit + Alerts //BPS - bestpinescripts.com  ·  ⚠️ DEMO"
    table.cell(t, 0, 0, title, bgcolor=color.new(colPrim2, 50), text_color=color.white, text_size=tblSize, text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 8, 0)

    // Column headers
    table.cell(t,0,1,"Pattern",  bgcolor=hBG, text_color=txtPrim,    text_size=tblSize, text_halign=text.align_left)
    table.cell(t,1,1,"#",        bgcolor=hBG, text_color=txtPrim,    text_size=tblSize)
    table.cell(t,2,1,"Wins",     bgcolor=hBG, text_color=colLong,    text_size=tblSize)
    table.cell(t,3,1,"Losses",   bgcolor=hBG, text_color=colShort,   text_size=tblSize)
    table.cell(t,4,1,"Win%",     bgcolor=hBG, text_color=txtWarn,    text_size=tblSize)
    table.cell(t,5,1,"$ Won",    bgcolor=hBG, text_color=colLong,    text_size=tblSize)
    table.cell(t,6,1,"$ Lost",   bgcolor=hBG, text_color=colShort,   text_size=tblSize)
    table.cell(t,7,1,"Net $",    bgcolor=hBG, text_color=txtPrim,    text_size=tblSize)
    table.cell(t,8,1,"Open",     bgcolor=hBG, text_color=txtPrim,    text_size=tblSize)

    // 14 pattern rows
    var array<string> rows = array.from(DEMO_P_DOUBLE_TOP, DEMO_P_DOUBLE_BOT, DEMO_P_TRIPLE_TOP, DEMO_P_TRIPLE_BOT, DEMO_P_HS, DEMO_P_INV_HS, DEMO_P_ASC_TRI, DEMO_P_DESC_TRI, DEMO_P_SYM_TRI, DEMO_P_RISING_WEDGE, DEMO_P_FALLING_WEDGE, DEMO_P_BULL_FLAG, DEMO_P_BEAR_FLAG, DEMO_P_RECTANGLE)
    var array<color> rowColors = array.from(colDoubleTop, colDoubleBot, colTripleTop, colTripleBot, colHs, colInvHs, colAscTri, colDescTri, colSymTri, colRisingWdg, colFallingWdg, colBullFlag, colBearFlag, colRectangle)

    for r = 0 to 13
        string row = array.get(rows, r)
        color  patCol = array.get(rowColors, r)
        string patName = f_parse(row, 0)
        string cnt = f_parse(row, 1)
        float cntF = str.tonumber(cnt)
        bool noTrades = na(cntF) or cntF == 0.0
        string wins = f_parse(row, 2)
        string losses = f_parse(row, 3)
        string winPct = f_parse(row, 4)
        string wonStr = f_parse(row, 5)
        string lostStr = f_parse(row, 6)
        string netStr = f_parse(row, 7)
        string openStr = f_parse(row, 8)
        color netCol = str.contains(netStr, "-") ? colShort : colLong

        table.cell(t,0,2+r, patName,                       bgcolor=hBG, text_color=patCol,    text_size=tblSize, text_halign=text.align_left)
        table.cell(t,1,2+r, cnt,                            bgcolor=hBG, text_color=txtPrim,   text_size=tblSize)
        table.cell(t,2,2+r, wins,                           bgcolor=hBG, text_color=colLong,   text_size=tblSize)
        table.cell(t,3,2+r, losses,                         bgcolor=hBG, text_color=colShort,  text_size=tblSize)
        table.cell(t,4,2+r, noTrades ? "—" : winPct + "%",  bgcolor=hBG, text_color=txtWarn,   text_size=tblSize)
        table.cell(t,5,2+r, "$" + wonStr,                    bgcolor=hBG, text_color=colLong,   text_size=tblSize)
        table.cell(t,6,2+r, "$" + lostStr,                   bgcolor=hBG, text_color=colShort,  text_size=tblSize)
        table.cell(t,7,2+r, netStr,                          bgcolor=hBG, text_color=netCol,    text_size=tblSize)
        table.cell(t,8,2+r, openStr,                         bgcolor=hBG, text_color=txtPrim,   text_size=tblSize)

    // TOTAL row (highlighted)
    int totalRow = 16
    string tCnt    = f_parse(DEMO_P_TOTAL, 1)
    string tWins   = f_parse(DEMO_P_TOTAL, 2)
    string tLosses = f_parse(DEMO_P_TOTAL, 3)
    string tWinPct = f_parse(DEMO_P_TOTAL, 4)
    string tWon    = f_parse(DEMO_P_TOTAL, 5)
    string tLost   = f_parse(DEMO_P_TOTAL, 6)
    string tNet    = f_parse(DEMO_P_TOTAL, 7)
    string tOpen   = f_parse(DEMO_P_TOTAL, 8)
    color tNetCol  = str.contains(tNet, "-") ? colShort : colLong
    color totalBg  = color.new(#1e3a8a, 60)

    table.cell(t,0,totalRow, "TOTAL",         bgcolor=totalBg, text_color=color.white,    text_size=tblSize, text_halign=text.align_left)
    table.cell(t,1,totalRow, tCnt,             bgcolor=totalBg, text_color=color.white,    text_size=tblSize)
    table.cell(t,2,totalRow, tWins,            bgcolor=totalBg, text_color=colLong,         text_size=tblSize)
    table.cell(t,3,totalRow, tLosses,          bgcolor=totalBg, text_color=colShort,        text_size=tblSize)
    table.cell(t,4,totalRow, tWinPct + "%",    bgcolor=totalBg, text_color=color.yellow,    text_size=tblSize)
    table.cell(t,5,totalRow, "$" + tWon,       bgcolor=totalBg, text_color=colLong,         text_size=tblSize)
    table.cell(t,6,totalRow, "$" + tLost,      bgcolor=totalBg, text_color=colShort,        text_size=tblSize)
    table.cell(t,7,totalRow, tNet,             bgcolor=totalBg, text_color=tNetCol,         text_size=tblSize)
    table.cell(t,8,totalRow, tOpen,            bgcolor=totalBg, text_color=color.white,    text_size=tblSize)

    // Equity row (active, single-line)
    int eqRow = 17
    table.cell(t, 0, eqRow, "💰 " + DEMO_EQ_VALUE + "   📅 ~Yearly: " + DEMO_EQ_YEARLY, bgcolor=color.new(colLong, 90), text_color=colLong, text_size=bigSz, text_halign=text.align_left)
    table.merge_cells(t, 0, eqRow, 8, eqRow)

    // DD row — split into two cells like the real STARTER:
    //   • left  (cols 0–4): Daily + Total DD   → red (Total DD over limit)
    //   • right (cols 5–8): Target             → green (target hit)
    int ddRow = 18
    string ddLeftTxt  = "Daily DD: " + DEMO_DAILY_DD + "% | Total DD: " + DEMO_TOTAL_DD + "%"
    string ddRightTxt = "Target: " + DEMO_TARGET + "%"
    table.cell(t, 0, ddRow, ddLeftTxt,  bgcolor=color.new(colShort, 90), text_color=colShort, text_size=bigSz, text_halign=text.align_left)
    table.merge_cells(t, 0, ddRow, 4, ddRow)
    table.cell(t, 5, ddRow, ddRightTxt, bgcolor=color.new(colLong, 90),  text_color=colLong,  text_size=bigSz, text_halign=text.align_left)
    table.merge_cells(t, 5, ddRow, 8, ddRow)

    // Telegram CTA row
    int teleRow = 19
    table.cell(t, 0, teleRow, "📣 Follow us on Telegram " + DEMO_TELEGRAM + " for the best Symbols, Timeframes and Options", bgcolor=color.new(#0d47a1, 30), text_color=color.white, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, teleRow, 8, teleRow)

    // Meta footer rows
    table.cell(t, 0, 20, syminfo.ticker + " | " + timeframe.period + " | " + DEMO_BARS_INFO, bgcolor=hBG, text_color=txtMute, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, 20, 8, 20)
    table.cell(t, 0, 21, "Pivot L:5/5 | Tol:0.4% | Wedge:0.1% | CD:20b Per Pattern | Dir:" + tradeDirection + " | Show:Last only", bgcolor=hBG, text_color=txtMute, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, 21, 8, 21)
    table.cell(t, 0, 22, "Pattern Target | SL:" + str.tostring(slAdjust) + "% | TP:" + str.tostring(tpAdjust) + "% | TgtMulti:1x | Buf:0.1% | Box:25b", bgcolor=hBG, text_color=txtMute, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, 22, 8, 22)
    table.cell(t, 0, 23, "Start:$" + str.tostring(startBalance, "#") + " | Risk:" + str.tostring(riskPct, "#.#") + "% " + riskMode + " | Open:7/10 | DD:5/10% | TP:30% | Pat:14/14", bgcolor=hBG, text_color=txtMute, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, 23, 8, 23)
    table.cell(t, 0, 24, "Broker Costs | Commission:$" + str.tostring(commissionUsd, "#.##") + " | Spread/Slip:" + str.tostring(spreadManual, "#.##") + "% | (applied per trade)", bgcolor=hBG, text_color=txtMute, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, 24, 8, 24)
    table.cell(t, 0, 25, "Backtest data only — no future data is used. Broker costs configurable above (commission + spread).\nSlippage not modeled. Past performance does not guarantee future results.", bgcolor=hBG, text_color=txtMute, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, 25, 8, 25)

    // DEMO disclaimer (red bottom row)
    table.cell(t, 0, 26, "⚠️ DEMO VALUES — Marketing visualization only. Real backtest results may differ. Past performance is no guarantee of future results.", bgcolor=color.new(#7f1d1d, 70), text_color=color.white, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(t, 0, 26, 8, 26)

// ════════════════════════════════════════════════════════════
// DEMO Watermark (top right)
// ════════════════════════════════════════════════════════════
var table tWm = table.new(position.top_right, 1, 1, bgcolor=color.new(#7f1d1d, 70), border_width=1, border_color=color.red, force_overlay=true)
if DEMO_SHOW_BANNER and barstate.islast
    table.cell(tWm, 0, 0, "  DEMO — Visualization only  //BPS  ", text_color=color.white, text_size=size.normal, text_halign=text.align_center)

// BPS bottom-right small watermark
var table _bps_wm = table.new(position.bottom_right, 1, 1, bgcolor=color.new(color.black, 80), border_width=0, force_overlay=true)
if barstate.islast
    table.cell(_bps_wm, 0, 0, "//BPS  bestpinescripts.com  ·  DEMO", text_color=color.new(color.white, 30), text_size=size.tiny, text_halign=text.align_center)
````

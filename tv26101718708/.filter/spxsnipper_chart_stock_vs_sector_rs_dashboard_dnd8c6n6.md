# SpxSnipper - Chart Stock vs Sector RS Dashboard

- url: https://www.tradingview.com/script/DnD8C6N6-SpxSnipper-Chart-Stock-vs-Sector-RS-Dashboard/
- type: indicator
- pine_id: PUB;54f7b7952a7b4d1c9cba7494ec79920a
- version: 1.0

## Description

SpxSnipper - Chart Stock vs Sector RS Dashboard

This indicator displays a compact relative strength dashboard that compares the current chart symbol against a selected sector ETF.

The stock symbol is detected automatically from the active chart, so users only need to select the relevant sector ETF. SPY is used as the default benchmark for sector-level relative strength.

The dashboard is designed to help answer two practical questions:

1. Is the stock outperforming or underperforming its sector?
2. Is the selected sector outperforming or underperforming SPY?

Main features:
• Automatically uses the current chart symbol as the stock
• User-selected sector ETF
• SPY benchmark comparison
• 6-month, 3-month, and 1-month performance
• Stock relative strength versus sector
• Sector relative strength versus SPY
• Weighted RS Score
• RS Trend status
• Compact table format

Performance periods:
The dashboard calculates performance over three configurable lookback periods:

• 6M
• 3M
• 1M

By default, these are approximated using trading days:
• 6M = 126 trading days
• 3M = 63 trading days
• 1M = 21 trading days

Stock vs Sector:
This row compares the stock’s return to the selected sector ETF.

Formula:

Stock Relative Return = Stock Return - Sector ETF Return

A positive value means the stock outperformed its sector during that period.
A negative value means the stock underperformed its sector during that period.

Sector vs SPY:
This row compares the selected sector ETF to SPY.

Formula:

Sector Relative Return = Sector ETF Return - SPY Return

A positive value means the sector outperformed SPY.
A negative value means the sector underperformed SPY.

RS Score:
The RS Score is a weighted relative strength score. It combines the 6M, 3M, and 1M relative returns into one number, with more weight given to recent performance.

Formula:

RS Score =
Relative 6M × 20%
+ Relative 3M × 30%
+ Relative 1M × 50%

For the stock, the RS Score is calculated versus the selected sector ETF.
For the sector, the RS Score is calculated versus SPY.

A positive RS Score indicates weighted outperformance.
A negative RS Score indicates weighted underperformance.

RS Trend:
RS Trend evaluates whether relative strength is improving, weakening, or mixed across the three timeframes.

The logic is:

RS ↑:
Relative strength is improving from 6M to 3M to 1M.

Rel 1M > Rel 3M > Rel 6M

RS ↓:
Relative strength is weakening from 6M to 3M to 1M.

Rel 1M < Rel 3M < Rel 6M

Mixed:
There is no clear sequential improvement or deterioration.

Suggested interpretation:
• Positive Sector RS Score or RS ↑ may indicate that the sector is showing relative strength versus SPY.
• Positive Stock RS Score or RS ↑ may indicate that the stock is showing relative strength versus its sector.
• A strong stock inside a strong sector may be useful for watchlist building and relative strength analysis.
• A stock can rise in absolute terms but still underperform its sector, which this dashboard helps identify.

Customization:
Users can adjust:
• Sector ETF
• Benchmark symbol
• 6M / 3M / 1M lookback periods
• Table position

Important note:
This dashboard is intended for relative strength analysis, sector comparison, and market research. It does not generate buy or sell signals and should not be used as a standalone trading system.

This script is for educational and analytical purposes only and does not provide financial advice.

## Source Code

````pine
//@version=6
indicator("SpxSnipper - Chart Stock vs Sector RS Dashboard", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
sectorSymbol = input.symbol("AMEX:XLK", "Sector ETF")
benchmarkSymbol = input.symbol("AMEX:SPY", "Benchmark - SPY")

lookback6M = input.int(126, "6M Lookback - Trading Days", minval=20, maxval=300)
lookback3M = input.int(63, "3M Lookback - Trading Days", minval=10, maxval=150)
lookback1M = input.int(21, "1M Lookback - Trading Days", minval=5, maxval=80)

tablePosition = input.string(
     "Top Right",
     "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"]
)

showOnlyLastBar = input.bool(true, "Update Table Only On Last Bar")

// Automatically use current chart symbol
stockSymbol = syminfo.tickerid

// ─────────────────────────────────────────────
// Helper functions
// ─────────────────────────────────────────────
f_tablePosition(string pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     pos == "Bottom Left" ? position.bottom_left :
     position.top_right

f_return(string sym, int lb) =>
    request.security(
         sym,
         "D",
         (close / close[lb] - 1.0) * 100.0,
         barmerge.gaps_off,
         barmerge.lookahead_off
    )

f_cleanSymbol(string sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : sym

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

f_relText(float value) =>
    na(value) ? "n/a" : value >= 0 ? "+" + str.tostring(value, "#.##") + "%" : str.tostring(value, "#.##") + "%"

f_scoreText(float value) =>
    na(value) ? "n/a" : value >= 0 ? "+" + str.tostring(value, "#.##") : str.tostring(value, "#.##")

f_rsScore(float rel6, float rel3, float rel1) =>
    rel6 * 0.20 + rel3 * 0.30 + rel1 * 0.50

f_rsTrendText(float rel6, float rel3, float rel1) =>
    bool improving = rel1 > rel3 and rel3 > rel6
    bool weakening = rel1 < rel3 and rel3 < rel6
    improving ? "RS ↑" : weakening ? "RS ↓" : "Mixed"

f_bgReturn(float value) =>
    na(value) ? color.new(color.gray, 85) :
     value > 10 ? color.new(color.lime, 65) :
     value > 3 ? color.new(color.lime, 78) :
     value >= 0 ? color.new(color.lime, 88) :
     value > -3 ? color.new(color.red, 88) :
     value > -10 ? color.new(color.red, 78) :
     color.new(color.red, 65)

f_bgRelative(float value) =>
    na(value) ? color.new(color.gray, 85) :
     value > 5 ? color.new(color.lime, 65) :
     value > 0 ? color.new(color.lime, 82) :
     value > -5 ? color.new(color.red, 82) :
     color.new(color.red, 65)

f_bgScore(float value) =>
    na(value) ? color.new(color.gray, 85) :
     value > 5 ? color.new(color.lime, 60) :
     value > 0 ? color.new(color.lime, 80) :
     value > -5 ? color.new(color.red, 80) :
     color.new(color.red, 60)

f_bgTrend(float rel6, float rel3, float rel1) =>
    bool improving = rel1 > rel3 and rel3 > rel6
    bool weakening = rel1 < rel3 and rel3 < rel6
    improving ? color.new(color.lime, 75) :
     weakening ? color.new(color.red, 75) :
     color.new(color.blue, 80)

// ─────────────────────────────────────────────
// Returns
// ─────────────────────────────────────────────
stock6M = f_return(stockSymbol, lookback6M)
stock3M = f_return(stockSymbol, lookback3M)
stock1M = f_return(stockSymbol, lookback1M)

sector6M = f_return(sectorSymbol, lookback6M)
sector3M = f_return(sectorSymbol, lookback3M)
sector1M = f_return(sectorSymbol, lookback1M)

spy6M = f_return(benchmarkSymbol, lookback6M)
spy3M = f_return(benchmarkSymbol, lookback3M)
spy1M = f_return(benchmarkSymbol, lookback1M)

// Stock relative strength vs sector
stockRel6M = stock6M - sector6M
stockRel3M = stock3M - sector3M
stockRel1M = stock1M - sector1M

stockRsScore = f_rsScore(stockRel6M, stockRel3M, stockRel1M)
stockRsTrend = f_rsTrendText(stockRel6M, stockRel3M, stockRel1M)

// Sector relative strength vs SPY
sectorRel6M = sector6M - spy6M
sectorRel3M = sector3M - spy3M
sectorRel1M = sector1M - spy1M

sectorRsScore = f_rsScore(sectorRel6M, sectorRel3M, sectorRel1M)
sectorRsTrend = f_rsTrendText(sectorRel6M, sectorRel3M, sectorRel1M)

// ─────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────
var table t = table.new(f_tablePosition(tablePosition), 5, 8, border_width=1)

shouldUpdate = showOnlyLastBar ? barstate.islast : true

if shouldUpdate
    table.clear(t, 0, 0, 4, 7)

    headerBg = color.new(color.black, 0)
    headerTxt = color.white

    table.cell(t, 0, 0, "Metric", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 1, 0, "6M", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 2, 0, "3M", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 3, 0, "1M", text_color=headerTxt, bgcolor=headerBg)
    table.cell(t, 4, 0, "Summary", text_color=headerTxt, bgcolor=headerBg)

    // Stock absolute performance
    table.cell(t, 0, 1, f_cleanSymbol(stockSymbol), text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(t, 1, 1, f_pct(stock6M), text_color=color.white, bgcolor=f_bgReturn(stock6M))
    table.cell(t, 2, 1, f_pct(stock3M), text_color=color.white, bgcolor=f_bgReturn(stock3M))
    table.cell(t, 3, 1, f_pct(stock1M), text_color=color.white, bgcolor=f_bgReturn(stock1M))
    table.cell(t, 4, 1, "Stock", text_color=color.white, bgcolor=color.new(color.black, 15))

    // Sector absolute performance
    table.cell(t, 0, 2, f_cleanSymbol(sectorSymbol), text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(t, 1, 2, f_pct(sector6M), text_color=color.white, bgcolor=f_bgReturn(sector6M))
    table.cell(t, 2, 2, f_pct(sector3M), text_color=color.white, bgcolor=f_bgReturn(sector3M))
    table.cell(t, 3, 2, f_pct(sector1M), text_color=color.white, bgcolor=f_bgReturn(sector1M))
    table.cell(t, 4, 2, "Sector", text_color=color.white, bgcolor=color.new(color.black, 15))

    // Stock relative vs sector
    table.cell(t, 0, 3, "Stock vs Sector", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(t, 1, 3, f_relText(stockRel6M), text_color=color.white, bgcolor=f_bgRelative(stockRel6M))
    table.cell(t, 2, 3, f_relText(stockRel3M), text_color=color.white, bgcolor=f_bgRelative(stockRel3M))
    table.cell(t, 3, 3, f_relText(stockRel1M), text_color=color.white, bgcolor=f_bgRelative(stockRel1M))
    table.cell(t, 4, 3, "Rel", text_color=color.white, bgcolor=color.new(color.black, 15))

    // Stock RS Score
    table.cell(t, 0, 4, "Stock RS Score", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(t, 1, 4, "", bgcolor=color.new(color.black, 15))
    table.cell(t, 2, 4, "", bgcolor=color.new(color.black, 15))
    table.cell(t, 3, 4, "", bgcolor=color.new(color.black, 15))
    table.cell(t, 4, 4, f_scoreText(stockRsScore), text_color=color.white, bgcolor=f_bgScore(stockRsScore))

    // Stock RS Trend
    table.cell(t, 0, 5, "Stock RS Trend", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(t, 1, 5, "", bgcolor=color.new(color.black, 15))
    table.cell(t, 2, 5, "", bgcolor=color.new(color.black, 15))
    table.cell(t, 3, 5, "", bgcolor=color.new(color.black, 15))
    table.cell(t, 4, 5, stockRsTrend, text_color=color.white, bgcolor=f_bgTrend(stockRel6M, stockRel3M, stockRel1M))

    // Sector vs SPY summary
    table.cell(t, 0, 6, "Sector vs SPY", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(t, 1, 6, f_relText(sectorRel6M), text_color=color.white, bgcolor=f_bgRelative(sectorRel6M))
    table.cell(t, 2, 6, f_relText(sectorRel3M), text_color=color.white, bgcolor=f_bgRelative(sectorRel3M))
    table.cell(t, 3, 6, f_relText(sectorRel1M), text_color=color.white, bgcolor=f_bgRelative(sectorRel1M))
    table.cell(t, 4, 6, f_scoreText(sectorRsScore) + " / " + sectorRsTrend, text_color=color.white, bgcolor=f_bgScore(sectorRsScore))

    // Formula note
    table.cell(t, 0, 7, "RS Score", text_color=color.white, bgcolor=color.new(color.black, 25))
    table.cell(t, 1, 7, "20%", text_color=color.white, bgcolor=color.new(color.black, 25))
    table.cell(t, 2, 7, "30%", text_color=color.white, bgcolor=color.new(color.black, 25))
    table.cell(t, 3, 7, "50%", text_color=color.white, bgcolor=color.new(color.black, 25))
    table.cell(t, 4, 7, "weighted", text_color=color.yellow, bgcolor=color.new(color.black, 25))
````

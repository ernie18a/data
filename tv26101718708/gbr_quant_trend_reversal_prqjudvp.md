# GBR Quant Trend & Reversal

- url: https://www.tradingview.com/script/prqJuDvp-GBR-Quant-Trend-Reversal/
- type: indicator
- pine_id: PUB;97729915e21049a2b8658074518ef80d
- version: 1.0

## Description

GBR Quant Trend & Reversal is a zero-noise, institutional-grade indicator built for prop firm traders and aggressive day traders. Unlike lagging kernel regressions, this dynamic ribbon is highly sensitive to real-time price action, getting you into the move earlier.

🔥 Core Features:

Dynamic Trend Ribbon: Instantly shifts between UV Green (Bullish) and UV Red (Bearish) the moment price crosses the moving average band.

Multi-Timeframe (MTF) Ready: Trade on a 5m chart while plotting a 1H or 4H trend ribbon to stay aligned with the macro order flow.

Historical Reversal Zones: Automatically plots dashed UV lines at major structural pivot highs and lows. Use these visual markers to backtest past liquidity sweeps and identify future high-probability reversal zones.

Clean UI: Stripped of unnecessary clutter. Just raw data and striking UV colors.

## Source Code

````pine
//@version=6
indicator("GBR Quant Trend & Reversal", overlay=true, max_lines_count=100, max_labels_count=100)

// ==========================================
// 1. SETTINGS (UI)
// ==========================================
grp1 = "GBR Dynamic Trend Ribbon"
trendLen = input.int(14, title="Bandwidth (Sensitivity)", group=grp1)
trendTf  = input.timeframe("", title="Trend Timeframe (Empty = Chart TF)", group=grp1)

grp2 = "GBR Reversal Zones (Backtest)"
pivotLen = input.int(20, title="Pivot Lookback (Filter Noise)", group=grp2)
showHist = input.bool(true, title="Show Historical Reversal Lines", group=grp2)

// ==========================================
// 2. GBR CORPORATE IDENTITY (UV COLORS)
// ==========================================
colGreen  = color.new(#00FF00, 0) // UV Green (Buy)
colRed    = color.new(#FF0033, 0) // UV Red (Sell / Top)
colYellow = color.new(#FFFF00, 0) // UV Yellow (Support / Bottom)

// ==========================================
// 3. TREND RIBBON LOGIC
// ==========================================
smoothTrend = ta.hma(close, trendLen)
mtfTrend    = request.security(syminfo.tickerid, trendTf, smoothTrend)

trendColor = close > mtfTrend ? colGreen : colRed

plot(mtfTrend, title="GBR Trend Ribbon", color=trendColor, linewidth=3)

// ==========================================
// 4. REVERSAL POINTS & BACKTEST LINES
// ==========================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph) and showHist
    line.new(x1=bar_index[pivotLen], y1=ph, x2=bar_index, y2=ph, color=colRed, width=2, style=line.style_dashed)
    label.new(x=bar_index[pivotLen], y=ph, text="▼ Reversal (Top)", color=color.new(color.black, 100), textcolor=colRed, style=label.style_label_down, size=size.small)

if not na(pl) and showHist
    line.new(x1=bar_index[pivotLen], y1=pl, x2=bar_index, y2=pl, color=colYellow, width=2, style=line.style_dashed)
    label.new(x=bar_index[pivotLen], y=pl, text="▲ Reversal (Bottom)", color=color.new(color.black, 100), textcolor=colYellow, style=label.style_label_up, size=size.small)
````

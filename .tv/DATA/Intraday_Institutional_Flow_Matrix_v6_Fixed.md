<!-- tradingview-pine-id: PUB;172c1b7235d44fcbaf1f14da71426632 -->
<!-- tradingviewscripts-format: 1 -->
# Intraday Institutional Flow Matrix (v6 Fixed)

Source: https://www.tradingview.com/script/vHmN9S80-Intraday-Institutional-Flow-Matrix-v6-Fixed/

## Description

new.  using several additional indicators and data

---

## Source Code

````pine
//@version=6
indicator("Intraday Institutional Flow Matrix (v6 Fixed)", overlay=true)

// --- INPUTS & PARAMETERS ---
atrLength   = input.int(14, title="ATR Length")
multiplier  = input.float(2.0, title="ATR Multiplier")
pivotPeriod = input.int(10, title="S/R Pivot Lookback Length")
rvolLength  = input.int(10, title="RVOL Day Lookback Length")

// --- 1. VOLATILITY BOUNDS & VWAP CALCULATIONS ---
vwapValue   = ta.vwap
atrValue    = ta.atr(atrLength)
upperTarget = vwapValue + (atrValue * multiplier)
lowerFloor  = vwapValue - (atrValue * multiplier)

// --- 2. EXTENDED DYNAMIC SUPPORT & RESISTANCE (RED / GREEN) ---
pHi = ta.pivothigh(high, pivotPeriod, pivotPeriod)
pLo = ta.pivotlow(low, pivotPeriod, pivotPeriod)

var float activeResistance = na
var float activeSupport    = na

if not na(pHi)
    activeResistance := pHi
if not na(pLo)
    activeSupport := pLo

var line lineResistance = na
var line lineSupport    = na

if barstate.islast
    line.delete(lineResistance)
    line.delete(lineSupport)
    
    if not na(activeResistance)
        lineResistance := line.new(x1=bar_index - pivotPeriod, y1=activeResistance, x2=bar_index, y2=activeResistance, xloc=xloc.bar_index, extend=extend.right, color=color.red, style=line.style_solid, width=1)
    if not na(activeSupport)
        lineSupport    := line.new(x1=bar_index - pivotPeriod, y1=activeSupport, x2=bar_index, y2=activeSupport, xloc=xloc.bar_index, extend=extend.right, color=color.green, style=line.style_solid, width=1)

// --- 3. LEADING MARKET DATA FEEDS (MULTI-SYMBOL REQUESTS) ---
// Fetch NASDAQ Net Volume Breadth (VOLN)
nasdaqNetVolume = request.security("NASDAQ:VOLN", timeframe.period, close)

// Fetch QQQ Close and QQQ VWAP to determine market-index alignment
qqqClose = request.security("NASDAQ:QQQ", timeframe.period, close)
qqqVwap  = request.security("NASDAQ:QQQ", timeframe.period, ta.vwap)

// --- 4. PRE-MARKET TIME SLOT RVOL ENGINE ---
// Calculate simple relative volume matching standard historical distributions
avgVolume = ta.sma(volume, rvolLength)
currentRVOL = volume / math.max(avgVolume, 1)

// --- 5. VISUAL INTERFACE PLOTS ---
plot(vwapValue, title="Real-Time VWAP Anchor", color=color.blue, linewidth=2)
plot(upperTarget, title="Intraday Long Profit Target", color=color.green, linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)
plot(lowerFloor, title="Intraday Risk Floor", color=color.red, linewidth=1, style=plot.style_line, linestyle=plot.linestyle_dashed)

// --- 6. REAL-TIME INSTITUTIONAL DISCOVERY PANEL ---
var table matrixDisplay = table.new(position = position.top_right, columns = 2, rows = 5, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

if barstate.islast
    // Header Row
    table.cell(matrixDisplay, 0, 0, "FLOW METRIC", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(matrixDisplay, 1, 0, "LIVE VALUE / STATUS", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    
    // RVOL Display & Filter Conditional Color
    color rvolColor = (currentRVOL >= 2.0) ? color.green : color.orange
    table.cell(matrixDisplay, 0, 1, "Pre-Market RVOL (Goal: >2.0)", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 1, 1, str.tostring(currentRVOL, "#.##") + (currentRVOL >= 2.0 ? " [VOL POWER]" : " [LOW FLOW]"), text_color=rvolColor, text_size=size.small)
    
    // NASDAQ Net Volume (VOLN) Display
    color volnColor = (nasdaqNetVolume > 0) ? color.green : color.red
    table.cell(matrixDisplay, 0, 2, "NASDAQ Net Vol (VOLN)", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 1, 2, str.tostring(nasdaqNetVolume / 1000000, "#.#M"), text_color=volnColor, text_size=size.small)
    
    // QQQ Trend Verification Alignment
    bool qqqBullish = (qqqClose > qqqVwap)
    color qqqColor = qqqBullish ? color.green : color.red
    table.cell(matrixDisplay, 0, 3, "QQQ Index vs VWAP", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 1, 3, qqqBullish ? "QQQ BULLISH (Above VWAP)" : "QQQ BEARISH (Below VWAP)", text_color=qqqColor, text_size=size.small)
    
    // Active Support / Resistance Status Summary (Fixed color namespace error here)
    table.cell(matrixDisplay, 0, 4, "Active S/R Rulers", text_color=color.white, text_size=size.small)
    table.cell(matrixDisplay, 1, 4, "R: " + str.tostring(activeResistance, "#.##") + " | S: " + str.tostring(activeSupport, "#.##"), text_color=color.blue, text_size=size.small)
````

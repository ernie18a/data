# Linear Regression Scanner (KenshinC)

- url: https://www.tradingview.com/script/cEegbx18-Linear-Regression-Scanner-KenshinC/
- type: indicator
- pine_id: PUB;e42e1f04fd5e4458a0693ef70380b396
- version: 1.0

## Description

Linear Regression Scanner (KenshinC) + Slope Visual is a powerful real-time multi-symbol dashboard combined with advanced Linear Regression visualization. It analyzes up to 12 major cryptocurrency pairs simultaneously, displaying trend direction, price position relative to the regression midline, RSI(14), and precise slope values in a clean table. Additionally, it plots the Linear Regression Curve and dynamic slope direction arrows directly on the current chart for deeper visual insight.

[b]🔍 WHAT MAKES IT ORIGINAL[/b]

1. True Multi-Symbol Linear Regression Engine — Simultaneously calculates full Linear Regression Channels (intercept, endpoint, deviation, and slope) for 12 symbols using request.security().
2. Dual Linear Regression System — Uses two independent regression calculations: one for the scanner table (default 100 bars) and one for on-chart visualization (default 150 bars) with slope arrows.
3. Slope-Based Trend & Momentum Arrows — Detects trend direction from regression slope and displays intuitive teal/orange arrows showing slope strength on every bar.
4. Price vs Regression Midline Positioning — Real-time comparison of price against the dynamic regression center line.
5. Professional All-in-One Dashboard — Clean, color-coded table with Trend, Price Position, RSI, and Slope — all updated on bar close.
6. Highly Customizable — Independent settings for scanner channel and on-chart regression curve.

[b]⚙️ HOW IT WORKS[/b]

The scanner uses a custom get_channel() function to compute the best-fit Linear Regression line as follows:

mid = math.sum(src, len) / len
slope = ta.linreg(src, len, 0) - ta.linreg(src, len, 1)
intercept = mid - slope * math.floor(len / 2) + (1 - len % 2) / 2 * slope

This produces:
- The midline (average of the source over the chosen Channel Length)
- The true slope of the regression line (rate of change)
- Intercept and projected endpoint for accurate current-bar positioning
- Standard deviation around the line (ready for future deviation bands)

Trend is determined directly from the slope: positive slope = Bullish, negative slope = Bearish.  
Price vs Middle compares the current price to the regression line value at the current bar.

For the on-chart visualization (inspired by emiliolb):
lrc     = ta.linreg(close, lrc_len, 0)
lrprev  = ta.linreg(close[1], lrc_len, 0)
slope_current = (lrc - lrprev)

This plots a smooth red Linear Regression Curve (default 150 bars) and displays slope direction with arrows: Teal ↑ for positive/strengthening slope (bullish momentum) and Orange ↓ for negative/strengthening slope (bearish momentum).

RSI(14) is calculated independently for each symbol to show overbought (>70) and oversold (<30) conditions.  
The entire dashboard refreshes on every bar close using efficient array looping.

[b]📖 HOW TO USE[/b]

Reading the Dashboard Table (Top Right):
- Symbol: Ticker name (e.g., BTCUSDT)
- Trend: Green = Bullish (positive slope), Red = Bearish (negative slope)
- Price VS Middle: Green = Price above regression midline (bullish positioning), Red = Below midline (bearish positioning)
- RSI: Lime Green (<30) = Oversold, Yellow (30–70) = Neutral, Red (>70) = Overbought
- Slope: Precise numerical value — the higher the positive number, the stronger the uptrend; the lower the negative number, the stronger the downtrend.

Reading On-Chart Visuals:
- Red Curve: Linear Regression Curve (default 150 bars) — serves as a dynamic trend baseline.
- Teal Arrows ↑: Positive and strengthening slope → bullish momentum.
- Orange Arrows ↓: Negative and strengthening slope → bearish momentum.

Suggested Trading Workflow:
1. Scan the table for Bullish symbols showing “Bullish” + “Above” + strong positive Slope.
2. Confirm RSI is not extremely overbought (>70).
3. Switch to the symbol and observe the Red LRC Curve together with Slope Arrows for precise timing.
4. Look for strong confluence: Positive slope + price above midline + teal arrows = high-probability trend continuation setup.
5. Best performance on 15m, 1H, and 4H timeframes.
6. Always combine with support/resistance levels, volume, or higher-timeframe analysis.

Best Practices:
- Use longer Channel Length (100+) for smoother, longer-term trend detection.
- Adjust Linear Regression Length (150) to control the smoothness of the on-chart curve and arrows.
- Works excellently on major USDT perpetual pairs.

[b]⚙️ KEY SETTINGS REFERENCE[/b]

- Symbols: 12 pre-loaded major Binance USDT pairs (fully customizable)
- Linear Regression Slope Section: Show Curve, Show Arrows, Length (default 150), Color, Width
- Channel Settings: Source (default = low), Channel Length (default 100), RSI Length (default 14)
- Colors: Up Trend and Down Trend colors

🔔 Alerts

No built-in alerts yet. You can easily create manual alerts for slope direction changes, price crossing the regression midline, or RSI extremes.

[b]⚠️ IMPORTANT NOTES[/b]

— On-chart Linear Regression Curve and Slope Arrows are calculated and displayed only for the current symbol you are viewing.  
— The scanner table analyzes all 12 symbols independently in real time.  
— All calculations are performed on bar close to prevent repainting.  
— Slope values are not normalized across different assets — only compare them within the same symbol and timeframe.  
— Strong slope signals indicate trend strength but do not guarantee future price movement.  
— This indicator uses multiple request.security() calls. Avoid overloading the chart with too many other indicators.  
— Past performance is not indicative of future results. This tool is for educational and analytical purposes only.  
— Not financial advice. Always use proper risk management and trade at your own risk.

---

Made with passion by KenshinC  
Happy trading & trend hunting! 🚀

## Source Code

````pine
//@version=5
indicator('Linear Regression Scanner (KenshinC)', overlay = true, max_bars_back = 1000, max_lines_count = 300, dynamic_requests = true)

//------------------------------------------------------------------------------
// Symbol Inputs
//-----------------------------------------------------------------------------
sym1  = input.symbol('BINANCE:BTCUSDT',  'Symbol 1 - BTCUSDT',  group = 'Symbols')
sym2  = input.symbol('BINANCE:ETHUSDT',  'Symbol 2 - ETHUSDT',  group = 'Symbols')
sym3  = input.symbol('BINANCE:BNBUSDT',  'Symbol 3 - BNBUSDT',  group = 'Symbols')
sym4  = input.symbol('BINANCE:SOLUSDT',  'Symbol 4 - SOLUSDT',  group = 'Symbols')
sym5  = input.symbol('BINANCE:XRPUSDT',  'Symbol 5 - XRPUSDT',  group = 'Symbols')
sym6  = input.symbol('BINANCE:DOGEUSDT', 'Symbol 6 - DOGEUSDT', group = 'Symbols')
sym7  = input.symbol('BINANCE:ADAUSDT',  'Symbol 7 - ADAUSDT',  group = 'Symbols')
sym8  = input.symbol('BINANCE:TRXUSDT',  'Symbol 8 - TRXUSDT',  group = 'Symbols')
sym9  = input.symbol('BINANCE:AVAXUSDT', 'Symbol 9 - AVAXUSDT', group = 'Symbols')
sym10 = input.symbol('BINANCE:TONUSDT',  'Symbol 10 - TONUSDT', group = 'Symbols')
sym11 = input.symbol('BINANCE:LINKUSDT', 'Symbol 11 - LINKUSDT', group = 'Symbols')
sym12 = input.symbol('BINANCE:AAVEUSDT', 'Symbol 12 - AAVEUSDT', group = 'Symbols')

//------------------------------------------------------------------------------
// Linear Regression Slope Settings (New Section)
//-----------------------------------------------------------------------------
show_lrc     = input.bool(true,  title = 'Show Linear Regression Curve', group = 'Linear Regression Slope')
show_slope   = input.bool(true,  title = 'Show Slope Arrows', group = 'Linear Regression Slope')
lrc_len      = input.int(150,    title = 'Linear Regression Length', minval = 10, group = 'Linear Regression Slope')
lrc_color    = input.color(color.red, title = 'LRC Color', group = 'Linear Regression Slope')
lrc_width    = input.int(2,      title = 'LRC Line Width', minval = 1, maxval = 5, group = 'Linear Regression Slope')

//------------------------------------------------------------------------------
// Main Scanner Settings
//-----------------------------------------------------------------------------
rsi_len  = input.int(defval = 14, title = 'RSI Length', minval = 1, maxval = 200, group = 'RSI Settings')
src      = input(defval = low, title = 'Source', group = 'Channel Settings')
len      = input.int(defval = 100, title = 'Channel Length', minval = 10, group = 'Channel Settings')
upcol    = input.color(defval = color.lime, title = 'Up Trend Color', inline = 'trcols', group = 'Colors')
dncol    = input.color(defval = color.red,  title = 'Down Trend Color', inline = 'trcols', group = 'Colors')

//------------------------------------------------------------------------------
// Linear Regression Channel Calculation (for Scanner)
//-----------------------------------------------------------------------------
get_channel(src, len) =>
    mid = math.sum(src, len) / len
    slope = ta.linreg(src, len, 0) - ta.linreg(src, len, 1)
    intercept = mid - slope * math.floor(len / 2) + (1 - len % 2) / 2 * slope
    endy = intercept + slope * (len - 1)
    dev = 0.0
    for x = 0 to len - 1
        dev += math.pow(src[x] - (slope * (len - x) + intercept), 2)
    dev := math.sqrt(dev / len)
    [intercept, endy, dev, slope]

[y1_, y2_, dev, slope] = get_channel(src, len)

//------------------------------------------------------------------------------
// RSI
//-----------------------------------------------------------------------------
rsi14 = ta.rsi(src, rsi_len)  

//------------------------------------------------------------------------------
// NEW: Linear Regression Curve + Slope for Current Symbol (from emiliolb)
//-----------------------------------------------------------------------------
lrc     = ta.linreg(close, lrc_len, 0)
lrprev  = ta.linreg(close[1], lrc_len, 0)
slope_current = (lrc - lrprev)   // Simplified slope (change per bar)

// Plot LRC
plot(show_lrc ? lrc : na, title = "Linear Regression Curve", color = lrc_color, linewidth = lrc_width)

// Slope Arrows
plotarrow(show_slope ? slope_current : na, title = "Slope Direction", 
     colorup = color.teal, colordown = color.orange, 
     transp = 40, offset = 0)

//------------------------------------------------------------------------------
// Table
//-----------------------------------------------------------------------------
var table statusTable = table.new(position.top_right, 5, 13, 
     border_width = 1, border_color = color.black, frame_width = 2, frame_color = color.black)

table_bg_color = chart.bg_color == color.gray ? color.white : color.gray
table_text_color = color.black

// Headers
if barstate.isfirst
    table.cell(statusTable, 0, 0, 'Symbol',   bgcolor = table_bg_color, text_color = table_text_color)
    table.cell(statusTable, 1, 0, 'Trend',    bgcolor = table_bg_color, text_color = table_text_color)
    table.cell(statusTable, 2, 0, 'Price\nVS\nMiddle', bgcolor = table_bg_color, text_color = table_text_color)
    table.cell(statusTable, 3, 0, 'RSI',      bgcolor = table_bg_color, text_color = table_text_color)
    table.cell(statusTable, 4, 0, 'Slope',    bgcolor = table_bg_color, text_color = table_text_color)

// Data function
get_data(sym) =>
    [y1_, y2_, dev, slope] = request.security(sym, timeframe.period, get_channel(src, len))
    rsi_val = request.security(sym, timeframe.period, ta.rsi(src, 14))
    price   = request.security(sym, timeframe.period, close)
    
    middle_line = y2_
    position = price > middle_line ? 'Above' : 'Below'
    trend    = slope < 0 ? 'Bearish' : 'Bullish'
    
    [trend, slope, rsi_val, position]

// Update table
if barstate.islast
    symbols = array.from(sym1, sym2, sym3, sym4, sym5, sym6, sym7, sym8, sym9, sym10, sym11, sym12)
    
    for i = 0 to array.size(symbols) - 1
        sym = array.get(symbols, i)
        if str.length(sym) > 0
            [trend, slope_val, rsi_val, position] = get_data(sym)
            symbol_name = array.get(str.split(sym, ':'), 1)
            
            table.cell(statusTable, 0, i + 1, symbol_name, bgcolor = table_bg_color, text_color = table_text_color, text_font_family = font.family_monospace)
            table.cell(statusTable, 1, i + 1, trend, bgcolor = table_bg_color, text_color = trend == 'Bullish' ? upcol : dncol)
            table.cell(statusTable, 2, i + 1, position, bgcolor = table_bg_color, text_color = position == 'Above' ? upcol : dncol)
            
            rsi_color = rsi_val > 70 ? color.red : rsi_val < 30 ? color.lime : color.yellow
            table.cell(statusTable, 3, i + 1, str.tostring(rsi_val, "#.##"), bgcolor = table_bg_color, text_color = rsi_color)
            
            slope_color = slope_val > 0 ? upcol : slope_val < 0 ? dncol : color.gray
            table.cell(statusTable, 4, i + 1, str.tostring(slope_val, "#.#####"), bgcolor = table_bg_color, text_color = slope_color)
````

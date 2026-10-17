# ATK/DEF Hyper Candle Context | Price Action Analyzer       

- url: https://www.tradingview.com/script/wgBKRjwY/
- type: indicator
- pine_id: PUB;d2edf57e94094b8fa24be2711532e038
- version: 1.0

## Description

Hyper Candle Context is a comprehensive price action analysis tool to traders learning candle structure, market behavior, and current chart context through a multi-layer analytical dashboard.

This indicator focuses on pure price action observation by analyzing candle formation, including candle body strength, candle range, upper and lower wick behavior, closing position, volatility condition, and short-term market structure.

Unlike traditional indicators that rely mainly on mathematical oscillators, Hyper Candle Context focuses on reading the information contained inside each candle and presenting it in a structured way.

Candle Structure Analysis

The indicator evaluates candle characteristics through:

• Candle body size and strength
• Body-to-range percentage relationship
• Bullish and bearish candle balance
• Upper shadow and lower shadow analysis
• Doji and neutral candle identification
• Candle expansion and contraction behavior

These measurements provide a clearer understanding of how price is moving within each candle.

Price Action Context

Hyper Candle Context compares current candle behavior with previous candle information to highlight changes in market behavior:

• Bullish and bearish candle transitions
• Body strength changes
• Shadow development
• Momentum changes between candles
• Increasing or decreasing price pressure

This allows users to observe the evolution of candle behavior instead of looking at isolated candles.

Market Condition Analysis

The indicator includes market environment analysis using price volatility and range behavior:

• Current candle range compared with ATR volatility
• Narrow and expanding market conditions
• Volatility increase or decrease
• Market compression observation

This helps users understand whether the market is experiencing low activity, normal movement, or increased volatility.

Trend and Market Context

Additional context is provided through optional moving averages:

• EMA 9
• EMA 21
• EMA 50

The indicator displays the relationship between price and moving averages to help users observe general market alignment.

Support, Resistance and Liquidity Observation

The script monitors recent price areas and candle reactions:

• Recent high and low zones
• Potential support and resistance areas
• Upper wick rejection areas
• Lower wick reaction areas
• Liquidity-related candle behavior

These features are designed to assist manual chart analysis and market observation.

Information Dashboard

The built-in dashboard displays multiple layers of candle information:

•  price data
• Candle direction
• Candle strength classification
• Candle pattern description
• Shadow condition
• Closing position
• Market volatility state
• Trend context
• Support and resistance context
• Liquidity observation
• Previous candle comparison

All information is organized into a visual dashboard for easier chart interpretation.

Designed For

Hyper Candle Context is designed for traders who learning:

• Price Action
• Candlestick analysis
• Market structure
• Volatility behavior
• Chart context

The indicator is intended as a visual analysis assistant to support independent market research and decision-making.

Important Notes

Hyper Candle Context does not provide trad decisions, outcomes, or advice.

It is a price action analysis tool designed to help users better understand current market information and develop their own interpretation of price behavior.

## Source Code

````pine
//@version=6
indicator("hyper Candle Context", overlay=true, precision=4)

// ============================================================
// Table Size Control
// ============================================================
tableScale = input.float(1.0, "Table Scale", minval=0.5, maxval=2.0, step=0.1, tooltip="Table overall scaling factor")
tableBgOpacity = input.int(92, "Background Opacity", minval=50, maxval=100, step=1, tooltip="Background opacity (50-100)")

// ============================================================
// MA Display Controls
// ============================================================
showMA9 = input.bool(true, "Show MA9", tooltip="Display 9-period EMA on chart")
showMA21 = input.bool(true, "Show MA21", tooltip="Display 21-period EMA on chart")
showMA50 = input.bool(true, "Show MA50", tooltip="Display 50-period EMA on chart")

// ============================================================
// Declare All Variables
// ============================================================
// Price Data
float openPrice = na
float highPrice = na
float lowPrice = na
float closePrice = na
float change = na
float changePercent = na

// Candle Indicators
float bodySize = na
float rangeSize = na
float bodyPercent = na
string candleStrength = na

// Pattern Detection
bool isBullish = false
bool isBearish = false
bool isDoji = false
float upperWick = na
float lowerWick = na
string candlePattern = na

// Shadow State
string shadowState = na

// Yin Yang State
string yinYangState = na

// Close Position
float closePosition = na
string positionState = na

// Market State
float avgRange = na
string marketState = na

// Balance Score
float balanceScore = na
string balanceState = na

// Context
float ema9 = na
float ema21 = na
float ema50 = na
string trendState = na
float recentHigh = na
float recentLow = na
string srState = na
float liquidityZone = na
string liquidityState = na
float avgRange20 = na
string volatilityState = na

// Previous Candle Comparison
bool isBullishPrev = false
bool isBearishPrev = false
float bodyPrev = na
float upperWickPrev = na
float lowerWickPrev = na
string yinYangChange = na
string bodyChange = na
string wickChange = na

// Signals
bool signalBearishTurn = false
bool signalBullishTurn = false
bool signalLongLowerWick = false
bool signalLongUpperWick = false
string signalText = na

// Color Variables
color changeColor = na
color yinYangColor = na
color trendColor = na

// Table Styles
string textSizeMain = na
color bgMain = na
color bgHeader = na
color bgSubHeader = na
color bgRow = na
color bgRowAlt = na
color bgGold = na
color bgContext = na

// ============================================================
// Graphic Objects (using var for persistence)
// ============================================================
var label priceLabel = na
var label highLabelObj = na
var label lowLabelObj = na
var label signalLabelObj = na
var line openLineObj = na
var label contextLabelObj = na
var table myTable = na

// ============================================================
// Get Current Candle Data
// ============================================================
openPrice := open
highPrice := high
lowPrice := low
closePrice := close
change := close - open
changePercent := (change / open) * 100

// ============================================================
// 1. Candle Strength Index
// ============================================================
bodySize := math.abs(close - open)
rangeSize := high - low
bodyPercent := rangeSize > 0 ? bodySize / rangeSize : 0

candleStrength := 
  bodyPercent >= 0.70 ? "Very Strong" :
  bodyPercent >= 0.50 ? "Strong" :
  bodyPercent >= 0.30 ? "Medium" :
  bodyPercent >= 0.10 ? "Weak" : "Very Weak (Doji)"

// ============================================================
// 2. Candle Pattern
// ============================================================
isBullish := close > open
isBearish := close < open
isDoji := bodySize <= rangeSize * 0.10

upperWick := high - math.max(open, close)
lowerWick := math.min(open, close) - low

candlePattern := 
  isDoji ? "Doji" :
  isBullish and upperWick > bodySize * 0.5 and lowerWick < bodySize * 0.3 ? "Long Upper Shadow Bullish" :
  isBullish and lowerWick > bodySize * 0.5 and upperWick < bodySize * 0.3 ? "Long Lower Shadow Bullish" :
  isBearish and lowerWick > bodySize * 0.5 and upperWick < bodySize * 0.3 ? "Long Lower Shadow Bearish" :
  isBearish and upperWick > bodySize * 0.5 and lowerWick < bodySize * 0.3 ? "Long Upper Shadow Bearish" :
  bodySize > rangeSize * 0.60 and isBullish ? "Big Green Candle" :
  bodySize > rangeSize * 0.60 and isBearish ? "Big Red Candle" :
  "Normal Candle"

// ============================================================
// 3. Shadow State
// ============================================================
shadowState := 
  upperWick > lowerWick * 1.5 ? "Long Upper Shadow (Sell Pressure)" :
  lowerWick > upperWick * 1.5 ? "Long Lower Shadow (Buy Support)" :
  upperWick > 0 and lowerWick > 0 and upperWick < lowerWick * 1.5 and lowerWick < upperWick * 1.5 ? "Balanced Shadows" :
  upperWick == 0 and lowerWick == 0 ? "Marubozu" :
  upperWick == 0 ? "No Upper Shadow" :
  lowerWick == 0 ? "No Lower Shadow" : "Balanced Shadows"

// ============================================================
// 4. Yin Yang State
// ============================================================
yinYangState := 
  isBullish ? "Bullish" :
  isBearish ? "Bearish" : "Neutral"

// ============================================================
// 5. Close Position
// ============================================================
closePosition := (close - low) / (high - low + 0.001)
positionState := 
  closePosition >= 0.80 ? "High (Near Top)" :
  closePosition >= 0.60 ? "Mid-High" :
  closePosition >= 0.40 ? "Mid" :
  closePosition >= 0.20 ? "Mid-Low" : "Low (Near Bottom)"

// ============================================================
// 6. Market State
// ============================================================
avgRange := ta.atr(14)
marketState := 
  rangeSize < avgRange * 0.5 ? "Extremely Narrow (Breakout Imminent)" :
  rangeSize < avgRange * 0.8 ? "Narrow Range" :
  rangeSize <= avgRange * 1.2 ? "Normal Volatility" :
  rangeSize <= avgRange * 1.8 ? "Wide Range" :
  "Extreme Volatility"

// ============================================================
// 7. Bull/Bear Balance
// ============================================================
balanceScore := (close - low) / (high - low + 0.001) * 100
balanceState := 
  balanceScore >= 70 ? "Bull Dominant" :
  balanceScore >= 55 ? "Slightly Bullish" :
  balanceScore >= 45 ? "Balanced" :
  balanceScore >= 30 ? "Slightly Bearish" :
  "Bear Dominant"

// ============================================================
// 8. Context (Support/Resistance/Trend/Liquidity)
// ============================================================
ema9 := ta.ema(close, 9)
ema21 := ta.ema(close, 21)
ema50 := ta.ema(close, 50)

trendState := 
  close > ema9 and close > ema21 and close > ema50 ? "📈 Bullish Trend (Price Above MAs)" :
  close < ema9 and close < ema21 and close < ema50 ? "📉 Bearish Trend (Price Below MAs)" :
  close > ema50 ? "➡️ Bullish Bias (Above MA50)" :
  close < ema50 ? "➡️ Bearish Bias (Below MA50)" :
  "➡️ Ranging"

recentHigh := ta.highest(high, 20)
recentLow := ta.lowest(low, 20)

srState := 
  close >= recentHigh * 0.98 ? "🔴 Near Resistance" :
  close <= recentLow * 1.02 ? "🟢 Near Support" :
  close > recentLow * 1.10 and close < recentHigh * 0.90 ? "⬜ Middle of Range" :
  "⬜ Normal Range"

liquidityZone := ta.atr(14) * 0.5
liquidityState := 
  upperWick > rangeSize * 0.4 ? "⚠️ Liquidity Above (Long Upper Shadow)" :
  lowerWick > rangeSize * 0.4 ? "✅ Liquidity Below (Long Lower Shadow)" :
  rangeSize < avgRange * 0.5 ? "⏳ Liquidity Contracting (Breakout Imminent)" :
  "⚪ Normal Liquidity"

avgRange20 := ta.sma(avgRange, 20)
volatilityState := 
  avgRange > avgRange20 * 1.2 ? "🔥 Volatility Rising" :
  avgRange < avgRange20 * 0.8 ? "❄️ Volatility Falling" :
  "📊 Normal Volatility"

// ============================================================
// 9. Previous Candle Comparison
// ============================================================
isBullishPrev := close[1] > open[1]
isBearishPrev := close[1] < open[1]
bodyPrev := math.abs(close[1] - open[1])
upperWickPrev := high[1] - math.max(open[1], close[1])
lowerWickPrev := math.min(open[1], close[1]) - low[1]

yinYangChange := 
  (isBullish and isBearishPrev) ? "Bearish→Bullish ↑" :
  (isBearish and isBullishPrev) ? "Bullish→Bearish ↓" :
  (isBullish and isBullishPrev) ? "Consecutive Bullish" :
  (isBearish and isBearishPrev) ? "Consecutive Bearish" : "Neutral"

bodyChange := 
  bodySize > bodyPrev * 1.5 ? "Body Expanding" :
  bodySize < bodyPrev * 0.5 ? "Body Contracting" :
  "Body Stable"

wickChange := 
  upperWick > upperWickPrev * 1.3 and upperWick > lowerWick ? "Upper Shadow Growing ⚠️" :
  lowerWick > lowerWickPrev * 1.3 and lowerWick > upperWick ? "Lower Shadow Growing ✅" :
  upperWick < upperWickPrev * 0.5 and lowerWick < lowerWickPrev * 0.5 ? "Shadows Shrinking" :
  "Shadows Stable"

// ============================================================
// 10. Signals
// ============================================================
signalBearishTurn := isBearish and isBullishPrev
signalBullishTurn := isBullish and isBearishPrev
signalLongLowerWick := lowerWick > upperWick * 2 and lowerWick > bodySize * 1.5
signalLongUpperWick := upperWick > lowerWick * 2 and upperWick > bodySize * 1.5

signalText := 
  signalBullishTurn ? "🟢 Bullish Reversal (Bearish→Bullish)" :
  signalBearishTurn ? "🔴 Bearish Reversal (Bullish→Bearish)" :
  signalLongLowerWick ? "✅ Long Lower Shadow (Buyers Entering)" :
  signalLongUpperWick ? "⚠️ Long Upper Shadow (Sellers Entering)" :
  "No Signal"

// ============================================================
// 11. Color Variable Assignments
// ============================================================
changeColor := change >= 0 ? color.rgb(100,255,100) : color.rgb(255,100,100)
yinYangColor := isBullish ? color.rgb(100,255,100) : isBearish ? color.rgb(255,100,100) : color.rgb(200,200,200)
trendColor := close > ema9 and close > ema21 and close > ema50 ? color.rgb(100,255,100) : close < ema9 and close < ema21 and close < ema50 ? color.rgb(255,100,100) : color.rgb(200,200,200)

// ============================================================
// 12. Draw Moving Averages on Chart
// ============================================================
plot(showMA9 ? ema9 : na, color=color.new(color.blue, 0), linewidth=1, title="MA9")
plot(showMA21 ? ema21 : na, color=color.new(color.orange, 0), linewidth=1, title="MA21")
plot(showMA50 ? ema50 : na, color=color.new(color.red, 0), linewidth=2, title="MA50")

// ============================================================
// 13. Clean Up Old Graphics
// ============================================================
if barstate.islast
    if not na(priceLabel)
        label.delete(priceLabel)
    if not na(highLabelObj)
        label.delete(highLabelObj)
    if not na(lowLabelObj)
        label.delete(lowLabelObj)
    if not na(signalLabelObj)
        label.delete(signalLabelObj)
    if not na(openLineObj)
        line.delete(openLineObj)
    if not na(contextLabelObj)
        label.delete(contextLabelObj)

// ============================================================
// 14. Draw Key Price Markers
// ============================================================
if barstate.islast
    priceLabel := label.new(
        x=bar_index - 1,
        y=close,
        text="◉ " + str.tostring(close, "#.##"),
        color=color.rgb(126, 123, 123, 50),
        textcolor=color.rgb(251, 251, 250),
        style=label.style_label_left,
        size=size.normal
    )
    
    highLabelObj := label.new(
        x=bar_index,
        y=high,
        text="High: " + str.tostring(high, "#.##"),
        color=color.new(color.green, 0),
        textcolor=color.white,
        style=label.style_label_down,
        size=size.normal
    )
    
    lowLabelObj := label.new(
        x=bar_index,
        y=low,
        text="Low: " + str.tostring(low, "#.##"),
        color=color.new(color.red, 0),
        textcolor=color.white,
        style=label.style_label_up,
        size=size.normal
    )
    
    openLineObj := line.new(
        x1=bar_index - 1,
        y1=open,
        x2=bar_index,
        y2=open,
        color=color.new(color.blue, 30),
        style=line.style_dashed,
        width=1
    )
    
    if signalText != "No Signal"
        signalLabelObj := label.new(
            x=bar_index - 1,
            y=high + (high - low) * 10,
            text="🔔 " + signalText,
            color=color.rgb(255, 200, 50, 80),
            textcolor=color.white,
            style=label.style_label_left,
            size=size.small
        )

// ============================================================
// 15. Display Table
// ============================================================
if barstate.islast
    if not na(myTable)
        table.delete(myTable)
    
    textSizeMain := size.tiny
    
    bgMain := color.rgb(10,10,30, tableBgOpacity)
    bgHeader := color.rgb(30,50,120, math.min(100, tableBgOpacity + 8))
    bgSubHeader := color.rgb(40,40,70, math.min(100, tableBgOpacity + 5))
    bgRow := color.rgb(18,20,40, math.min(100, tableBgOpacity - 2))
    bgRowAlt := color.rgb(25,28,50, math.min(100, tableBgOpacity - 2))
    bgGold := color.rgb(40,40,20, math.min(100, tableBgOpacity))
    bgContext := color.rgb(20,40,20, math.min(100, tableBgOpacity))
    
    myTable := table.new(position.top_right, 4, 20,
                         bgcolor=bgMain, 
                         border_color=color.rgb(80,80,150, 60), 
                         border_width=2,
                         frame_color=color.rgb(50,50,120, 70),
                         frame_width=2)
    
    // ----- Title Row -----
    table.cell(myTable, 0, 0, "📊 Candle Context", 
               text_color=color.rgb(255,215,100), 
               bgcolor=bgHeader, 
               text_size=textSizeMain, 
               text_halign=text.align_center)
    table.cell(myTable, 1, 0, "", text_color=color.white, bgcolor=bgHeader, text_size=textSizeMain)
    table.cell(myTable, 2, 0, "", text_color=color.white, bgcolor=bgHeader, text_size=textSizeMain)
    table.cell(myTable, 3, 0, "", text_color=color.white, bgcolor=bgHeader, text_size=textSizeMain)
    
    // ----- Price Data -----
    table.cell(myTable, 0, 1, "📈 Price", text_color=color.rgb(180,200,255), bgcolor=bgSubHeader, text_size=textSizeMain)
    table.cell(myTable, 1, 1, "Open: " + str.tostring(openPrice, "#.##"), text_color=color.white, bgcolor=bgSubHeader, text_size=textSizeMain)
    table.cell(myTable, 2, 1, "Close: " + str.tostring(closePrice, "#.##"), text_color=color.white, bgcolor=bgSubHeader, text_size=textSizeMain)
    table.cell(myTable, 3, 1, "High: " + str.tostring(highPrice, "#.##") + " Low: " + str.tostring(lowPrice, "#.##"), text_color=color.white, bgcolor=bgSubHeader, text_size=textSizeMain)
    
    // ----- Change -----
    table.cell(myTable, 0, 2, "📉 Change", text_color=color.rgb(180,200,255), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 1, 2, str.tostring(change, "+#.##;-#.##"), text_color=changeColor, bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 2, 2, str.tostring(changePercent, "+#.##;-#.##") + "%", text_color=changeColor, bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 3, 2, "Range: " + str.tostring(rangeSize, "#.##"), text_color=color.white, bgcolor=bgRow, text_size=textSizeMain)
    
    // ----- Yin Yang State -----
    table.cell(myTable, 0, 3, "☯ Yin Yang", text_color=color.rgb(180,200,255), bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 1, 3, yinYangState, text_color=yinYangColor, bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 2, 3, candlePattern, text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 3, 3, "Strength: " + candleStrength + " (" + str.tostring(bodyPercent * 100, "#0") + "%)", text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    
    // ----- Shadow State -----
    table.cell(myTable, 0, 4, "📏 Shadows", text_color=color.rgb(180,200,255), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 1, 4, shadowState, text_color=color.white, bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 2, 4, "Upper: " + str.tostring(upperWick, "#.##"), text_color=color.rgb(255,200,150), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 3, 4, "Lower: " + str.tostring(lowerWick, "#.##"), text_color=color.rgb(150,255,200), bgcolor=bgRow, text_size=textSizeMain)
    
    // ----- Close Position -----
    table.cell(myTable, 0, 5, "📍 Close Position", text_color=color.rgb(180,200,255), bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 1, 5, positionState, text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 2, 5, "Balance: " + balanceState, text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 3, 5, str.tostring(balanceScore, "#0") + "%", text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    
    // ----- Market State -----
    table.cell(myTable, 0, 6, "🌊 Market", text_color=color.rgb(180,200,255), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 1, 6, marketState, text_color=color.white, bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 2, 6, "ATR: " + str.tostring(avgRange, "#.##"), text_color=color.white, bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 3, 6, "Range: " + str.tostring(rangeSize, "#.##"), text_color=color.white, bgcolor=bgRow, text_size=textSizeMain)
    
    // ----- Separator -----
    table.cell(myTable, 0, 7, "───────────", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain, text_halign=text.align_center)
    table.cell(myTable, 1, 7, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 2, 7, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 3, 7, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    
    // ----- Context Title -----
    table.cell(myTable, 0, 8, "🧠 Context", text_color=color.rgb(100,255,218), bgcolor=color.rgb(20,40,60), text_size=textSizeMain)
    table.cell(myTable, 1, 8, "", text_color=color.white, bgcolor=color.rgb(20,40,60), text_size=textSizeMain)
    table.cell(myTable, 2, 8, "", text_color=color.white, bgcolor=color.rgb(20,40,60), text_size=textSizeMain)
    table.cell(myTable, 3, 8, "", text_color=color.white, bgcolor=color.rgb(20,40,60), text_size=textSizeMain)
    
    // ----- Trend -----
    table.cell(myTable, 0, 9, "📈 Trend", text_color=color.rgb(180,200,255), bgcolor=bgContext, text_size=textSizeMain)
    table.cell(myTable, 1, 9, trendState, text_color=trendColor, bgcolor=bgContext, text_size=textSizeMain)
    table.cell(myTable, 2, 9, "MA9: " + str.tostring(ema9, "#.##"), text_color=color.white, bgcolor=bgContext, text_size=textSizeMain)
    table.cell(myTable, 3, 9, "MA50: " + str.tostring(ema50, "#.##"), text_color=color.white, bgcolor=bgContext, text_size=textSizeMain)
    
    // ----- Support/Resistance -----
    table.cell(myTable, 0, 10, "🔒 S/R", text_color=color.rgb(180,200,255), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 1, 10, srState, text_color=color.white, bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 2, 10, "20H: " + str.tostring(recentHigh, "#.##"), text_color=color.rgb(255,200,150), bgcolor=bgRow, text_size=textSizeMain)
    table.cell(myTable, 3, 10, "20L: " + str.tostring(recentLow, "#.##"), text_color=color.rgb(150,255,200), bgcolor=bgRow, text_size=textSizeMain)
    
    // ----- Liquidity -----
    table.cell(myTable, 0, 11, "💧 Liquidity", text_color=color.rgb(180,200,255), bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 1, 11, liquidityState, text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 2, 11, volatilityState, text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    table.cell(myTable, 3, 11, "ATR: " + str.tostring(avgRange, "#.##"), text_color=color.white, bgcolor=bgRowAlt, text_size=textSizeMain)
    
    // ----- Separator -----
    table.cell(myTable, 0, 12, "───────────", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain, text_halign=text.align_center)
    table.cell(myTable, 1, 12, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 2, 12, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    table.cell(myTable, 3, 12, "", text_color=color.rgb(60,60,120), bgcolor=bgMain, text_size=textSizeMain)
    
    // ----- Previous Candle Comparison -----
    table.cell(myTable, 0, 13, "📊 Comparison", text_color=color.rgb(255,200,100), bgcolor=bgSubHeader, text_size=textSizeMain)
    table.cell(myTable, 1, 13, "YinYang: " + yinYangChange, text_color=color.white, bgcolor=bgSubHeader, text_size=textSizeMain)
    table.cell(myTable, 2, 13, "Body: " + bodyChange, text_color=color.white, bgcolor=bgSubHeader, text_size=textSizeMain)
    table.cell(myTable, 3, 13, "Shadows: " + wickChange, text_color=color.white, bgcolor=bgSubHeader, text_size=textSizeMain)
    
    // ----- Signal -----
    if signalText != "No Signal"
        table.cell(myTable, 0, 14, "🔔 Signal", text_color=color.rgb(255,200,50), bgcolor=bgGold, text_size=textSizeMain)
        table.cell(myTable, 1, 14, signalText, text_color=color.rgb(255,200,50), bgcolor=bgGold, text_size=textSizeMain)
        table.cell(myTable, 2, 14, "", text_color=color.white, bgcolor=bgGold, text_size=textSizeMain)
        table.cell(myTable, 3, 14, "", text_color=color.white, bgcolor=bgGold, text_size=textSizeMain)
    else
        table.cell(myTable, 0, 14, "🔔 Signal", text_color=color.rgb(100,200,255), bgcolor=bgMain, text_size=textSizeMain)
        table.cell(myTable, 1, 14, "No Signal", text_color=color.rgb(150,150,200), bgcolor=bgMain, text_size=textSizeMain)
        table.cell(myTable, 2, 14, "", text_color=color.white, bgcolor=bgMain, text_size=textSizeMain)
        table.cell(myTable, 3, 14, "", text_color=color.white, bgcolor=bgMain, text_size=textSizeMain)
````

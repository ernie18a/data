<!-- tradingview-pine-id: PUB;212659bef3c94f73b6c737ef25977570 -->
<!-- tradingviewscripts-format: 1 -->
# SMC Confluence + EMA 9/15 + Fib 0.5

Source: https://www.tradingview.com/script/JFniby7K-SMC-Confluence-EMA-9-15-Fib-0-5/

## Description

Smart Money Concepts (SMC) Confluence Framework with Dual EMA & Equilibrium FilterExecutive SummaryThe SMC Confluence Framework is a multi-layered quantitative trading system engineered for Pine Script v6. It bridges the gap between retail momentum indicators and institutional order flow principles by deploying a strict algorithmic checklist. By cross-referencing Market Structure Shifts (CHoCH), Discount/Premium Pricing Zones, Imbalance Triggers (FVG), and Moving Average Crossovers, this tool completely eliminates emotional trading and filters out high-risk market noise.Technical Architecture & Core Modules1. Algorithmic Market Structure (CHoCH)Pivot Mechanism: Utilizes an optimized ta.pivothigh() and ta.pivotlow() matrix to isolate historical swing highs and lows, removing transient price action.Precision Visualization: Once a structural breakout occurs on a candle close, the script projects a mathematically precise, horizontal dashed vector exactly 1 bar forward ($1x$) along with an automated label alignment vector positioned cleanly underneath the break level.2. Dynamic Equilibrium Pricing Matrix (Fib 0.5)Equation Logic: Continuously solves for the central mathematical mean between active market extremes:$$\text{Equilibrium (Eq)} = \frac{\text{Swing High} + \text{Swing Low}}{2}$$Discount Phase (Buy Zone): Restricts long entries exclusively to price coordinates trading below the $0.5$ threshold, guaranteeing deep discount execution.Premium Phase (Sell Zone): Restricts short entries exclusively to price coordinates trading above the $0.5$ threshold, maximizing premium distribution value.3. High-Velocity Momentum Filter (Dual Exponential Moving Averages)9 EMA (Fast Velocity Vector): Visualized in high-visibility yellow, parsing immediate micro-trend direction.15 EMA (Slow Structural Vector): Visualized in crisp white, serving as dynamic trailing support and resistance.Trend Synchronization: Acts as a strict execution gatekeeper; long entries are blocked unless $\text{EMA 9} > \text{EMA 15}$, and short entries are blocked unless $\text{EMA 9} < \text{EMA 15}$.4. Institutional Liquidity & Imbalance EngineExecution triggers require a verified institutional footprint before generating a signal:Liquidity Hunting (Sweeps): Scans a historical 20-candle lookback window. Captures stop-run anomalies where price pierces structural liquidity extremes but forcefully closes back within the value range.Fair Value Gaps (FVG): Tracks displacement imbalances caused by institutional algorithmic orders, looking for unmitigated three-candle price gaps where $\text{Low}[0] > \text{High}[2]$ (Bullish) or $\text{High}[0] < \text{Low}[2]$ (Bearish).Strict Confluence Matrix (Execution Rules)🟢 System Buy Trigger (Confirmed Long)An execution-grade BUY Triangle prints if and only if the following logical constraints return true:Trend Orientation: Active bias is structural upside ($\text{Trend} = 1$) verified by a Bullish CHoCH.Pricing Efficiency: The execution candle is positioned firmly within the Discount Zone ($\text{Close} < \text{Eq}$).Velocity Confirmation: The fast exponential trend vector is above the slow vector ($\text{EMA 9} > \text{EMA 15}$).Institutional Footprint: A verified internal Bullish FVG or a successful demand-side Liquidity Sweep occurs.🔴 System Sell Trigger (Confirmed Short)An execution-grade SELL Triangle prints if and only if the following logical constraints return true:Trend Orientation: Active bias is structural downside ($\text{Trend} = -1$) verified by a Bearish CHoCH.Pricing Efficiency: The execution candle is positioned firmly within the Premium Zone ($\text{Close} > \text{Eq}$).Velocity Confirmation: The fast exponential trend vector is below the slow vector ($\text{EMA 9} < \text{EMA 15}$).Institutional Footprint: A verified internal Bearish FVG or a successful supply-side Liquidity Sweep occurs.Performance & Configuration NotesArchitectural Standard: Fully compiled in Pine Script v6 utilizing optimized object variable allocation to ensure lag-free rendering.Optimized Timeframes: Highly accurate on structural macro/micro intraday intervals ($5\text{m}$, $15\text{m}$, $1\text{h}$).Asset Compatibility: Built for high-liquidity environments including Major Fiat Pairs (FX), Crypto Majors (BTC, ETH), Spot Gold (XAUUSD), and Equity Index Derivatives (SPX, NDX

---

## Source Code

````pine
//@version=6
indicator("SMC Confluence + EMA 9/15 + Fib 0.5", overlay=true, max_labels_count=500)

// ---- INPUTS ----
length    = input.int(5, title="Swing Period", minval=2)
emaFast   = input.int(9, title="Fast EMA")
emaSlow   = input.int(15, title="Slow EMA")
showFib   = input.bool(true, title="Show 0.5 Equilibrium")

// ---- EMA CALCULATIONS ----
e9  = ta.ema(close, emaFast)
e15 = ta.ema(close, emaSlow)
plot(e9,  color=color.yellow, title="EMA 9")
plot(e15, color=color.white,  title="EMA 15")

// ---- MARKET STRUCTURE (CHoCH) ----
sh = ta.pivothigh(high, length, length)
sl = ta.pivotlow(low, length, length)
var float lastSH = na
var float lastSL = na
var int trend    = 0 

if not na(sh)
    lastSH := high[length]
if not na(sl)
    lastSL := low[length]

// CHoCH Logic
bool bullishCHoCH = (not na(lastSH)) and (close > lastSH) and (trend <= 0)
bool bearishCHoCH = (not na(lastSL)) and (close < lastSL) and (trend >= 0)

if bullishCHoCH
    trend := 1
if bearishCHoCH
    trend := -1

// ---- PERFECT CHoCH LINES WITH TEXT BELOW ----
if bullishCHoCH
    // Last SH ki level par bar_index-5 se le kar 1 bar aage tak seedhi line
    line.new(x1=bar_index - length, y1=lastSH, x2=bar_index + 1, y2=lastSH, color=color.blue, width=2, style=line.style_dashed)
    // Line ke bilkul neeche CHoCH text
    label.new(x=bar_index, y=lastSH, text="CHoCH", style=label.style_label_down, color=color.new(color.blue, 100), textcolor=color.blue, size=size.small)

if bearishCHoCH
    // Last SL ki level par bar_index-5 se le kar 1 bar aage tak seedhi line
    line.new(x1=bar_index - length, y1=lastSL, x2=bar_index + 1, y2=lastSL, color=color.purple, width=2, style=line.style_dashed)
    // Line ke bilkul upar/neeche CHoCH text
    label.new(x=bar_index, y=lastSL, text="CHoCH", style=label.style_label_up, color=color.new(color.purple, 100), textcolor=color.purple, size=size.small)

// ---- LIQUIDITY SWEEP ----
hH = ta.highest(high[1], 20)
lL = ta.lowest(low[1], 20)
liqBuy  = (low < lL) and (close > lL)
liqSell = (high > hH) and (close < hH)

// ---- FIBONACCI 0.5 (EQUILIBRIUM) ----
eq = (not na(lastSH) and not na(lastSL)) ? (lastSH + lastSL) / 2 : na
var line fibL = na

if showFib and not na(eq)
    if na(fibL)
        fibL := line.new(x1=bar_index - 20, y1=eq, x2=bar_index + 5, y2=eq, color=color.gray, style=line.style_dotted)
    else
        line.set_xy1(fibL, x=bar_index - 20, y=eq)
        line.set_xy2(fibL, x=bar_index + 5, y=eq)

// ---- FVG LOGIC ----
fvgB = (low > high[2]) and (close[1] > high[2])
fvgS = (high < low[2]) and (close[1] < low[2])

// ---- FINAL CONFIRMED ENTRY ----
emaBull = e9 > e15
emaBear = e9 < e15

buyC  = (trend == 1)  and (close < eq) and emaBull and (liqBuy or fvgB)
sellC = (trend == -1) and (close > eq) and emaBear and (liqSell or fvgS)

// ---- PLOTS FOR CONFIRMED BUY/SELL ----
plotshape(buyC,  title="BUY",  style=shape.triangleup,   location=location.belowbar, color=color.green, text="CONFIRMED BUY",  textcolor=color.green, size=size.small)
plotshape(sellC, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red,   text="CONFIRMED SELL", textcolor=color.red,   size=size.small)
````

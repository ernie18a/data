<!-- tradingview-pine-id: PUB;5444979111c54ead9740414a3245bd8c -->
<!-- tradingviewscripts-format: 1 -->
# swing alpha pro

Source: https://www.tradingview.com/script/CcqDDOjA-swing-alpha-pro/

## Description

Title: swing alpha pro

Description:

swing alpha pro is a comprehensive trend-following and dynamic volatility analysis tool designed primarily for swing traders, position traders, and scalp traders across all financial markets (Forex, Crypto, Indices, and Commodities).

The indicator combines adaptive volatility envelope bands with trailing stop signal generation to identify high-probability trend entries, exit levels, and structural volatility boundaries.

Key Features & How It Works
1. Dynamic Support & Resistance Ribbons (Upper & Lower Bands)
Instead of cluttering the middle of the chart, the indicator plots two distinct, color-coded volatility channels:

Upper Resistance Ribbon (Red): Represents dynamic overbought conditions and structural volatility expansion to the upside.

Lower Support Ribbon (Green): Represents dynamic oversold conditions and volatility expansion to the downside.

The core channel area remains clean to allow clear candlestick pattern inspection.

2. UT Bot Signal Engine (BUY / SELL Signals)
Signals are generated using an adaptive ATR Trailing Stop calculation combined with key price action sensitivity settings:

BUY Signals (Green Labels): Plotted when the close price crosses above the trailing stop loss line, signaling a potential bullish momentum shift.

SELL Signals (Red Labels): Plotted when the close price breaks below the trailing stop loss line, signaling a potential bearish breakdown.

3. Automated Take Profit (TP) Levels & Visual Markers
When a valid signal triggers, the script calculates dynamic profit targets based on average true range (ATR) multiples (TP1 and TP2).

When price touches target levels, the script draws a subtle vertical line with an "x TP" marker directly on the candle to confirm objective target realization without clogging price action.

How to Use & Trading Strategy
Trend Identification:

Look for price respecting the Lower Green Ribbon as potential buying interest or the Upper Red Ribbon as resistance.

Entry Rules:

Long Entry: Wait for a confirmed green BUY label when price bounces off or recovers near the lower support ribbon.

Short Entry: Wait for a confirmed red SELL label when price rejects near the upper resistance ribbon.

Exit Rules & Risk Management:

Use the dynamic "x TP" vertical lines as partial or full profit-taking zones.

Place structural stop-losses beyond the opposing ribbon or the initial ATR trailing line.

User Inputs & Customization
Signal Sensitivity (aSens): Controls the responsiveness of the BUY/SELL signals (higher values reduce noise for longer swing timeframes; lower values increase frequency for lower timeframes).

ATR Period (aPeriod): Adjusts the volatility calculation length.

Channel Length (ribbonLen): Sets the baseline length for the upper and lower ribbons.

Upper/Lower Band Multipliers (multTop / multBot): Fine-tunes how far the resistance and support ribbons stretch from the mean price.

TP Multipliers (tpRatio1 / tpRatio2): Sets custom risk-to-reward ratios for Take Profit targets.

Disclaimer
This indicator is strictly intended for informational and educational purposes. Past performance is not indicative of future results. Always manage your risk carefully and backtest strategies before executing real trades.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © swingAlpha

//@version=6
indicator("swing alpha pro", overlay=true, max_labels_count=500, max_lines_count=500)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
// UT Bot Core Logic
aSens       = input.float(1.2, "Signal Sensitivity", step=0.1, group="Signal Logic")
aPeriod     = input.int(10, "ATR Period", minval=1, group="Signal Logic")

// Channel / Ribbon Settings (Presne podľa obrázka)
ribbonLen   = input.int(34, "Channel Length", minval=1, group="Swing Alpha Ribbon")
multTop     = input.float(3.0, "Upper Band Distance", step=0.1, group="Swing Alpha Ribbon")
multBot     = input.float(3.0, "Lower Band Distance", step=0.1, group="Swing Alpha Ribbon")
bandWidth   = input.float(1.2, "Band Thickness", step=0.1, group="Swing Alpha Ribbon")

// Take Profit Settings
useTP       = input.bool(true, "Show TP Targets", group="Take Profit Settings")
tpRatio1    = input.float(1.2, "TP 1 Multiplier", step=0.1, group="Take Profit Settings")
tpRatio2    = input.float(2.2, "TP 2 Multiplier", step=0.1, group="Take Profit Settings")

// Dynamic Colors
colorBuy    = color.rgb(0, 200, 83)    // Bright Scalper/Swing Green
colorSell   = color.rgb(229, 57, 53)   // Bright Scalper/Swing Red

// ==========================================
// 2. DYNAMIC CHANNEL (UPPER & LOWER BANDS)
// ==========================================
baseMa   = ta.ema(close, ribbonLen)
atrVal   = ta.atr(14)

// Horné červené pásmo (Upper Band)
topOuter = baseMa + (atrVal * multTop)
topInner = topOuter - (atrVal * bandWidth)

// Spodné zelené pásmo (Lower Band)
botInner = baseMa - (atrVal * multBot) + (atrVal * bandWidth)
botOuter = baseMa - (atrVal * multBot)

// Vykreslenie hraníc pásiem
pTopOut = plot(topOuter, "Top Outer", color=color.new(colorSell, 60), linewidth=1)
pTopIn  = plot(topInner, "Top Inner", color=color.new(colorSell, 80), linewidth=1)

pBotIn  = plot(botInner, "Bot Inner", color=color.new(colorBuy, 80), linewidth=1)
pBotOut = plot(botOuter, "Bot Outer", color=color.new(colorBuy, 60), linewidth=1)

// Výplň samotných pásiem (Vnútro kanála zostáva prázdne)
fill(pTopOut, pTopIn, color=color.new(colorSell, 70), title="Upper Resistance Ribbon")
fill(pBotIn, pBotOut, color=color.new(colorBuy, 70), title="Lower Support Ribbon")

// ==========================================
// 3. BUY / SELL SIGNALS
// ==========================================
xATR  = ta.atr(aPeriod)
nLoss = aSens * xATR

var float xATRTrailingStop = 0.0
xATRTrailingStop := close > nz(xATRTrailingStop[1], 0) and close[1] > nz(xATRTrailingStop[1], 0) ? math.max(nz(xATRTrailingStop[1], 0), close - nLoss) : close < nz(xATRTrailingStop[1], 0) and close[1] < nz(xATRTrailingStop[1], 0) ? math.min(nz(xATRTrailingStop[1], 0), close + nLoss) : close > nz(xATRTrailingStop[1], 0) ? close - nLoss : close + nLoss

var int pos = 0
pos := close[1] < nz(xATRTrailingStop[1], 0) and close > nz(xATRTrailingStop[1], 0) ? 1 : close[1] > nz(xATRTrailingStop[1], 0) and close < nz(xATRTrailingStop[1], 0) ? -1 : nz(pos[1], 0)

buySignal  = pos == 1 and pos[1] != 1
sellSignal = pos == -1 and pos[1] != -1

// ==========================================
// 4. TAKE PROFIT & TARGET LINES
// ==========================================
var float entryPrice = na
var float tp1Level   = na
var float tp2Level   = na
var int tradeDir     = 0
var bool tp1Hit      = false
var bool tp2Hit      = false

if buySignal
    entryPrice := close
    tradeDir   := 1
    tp1Level   := entryPrice + (xATR * tpRatio1)
    tp2Level   := entryPrice + (xATR * tpRatio2)
    tp1Hit     := false
    tp2Hit     := false

if sellSignal
    entryPrice := close
    tradeDir   := -1
    tp1Level   := entryPrice - (xATR * tpRatio1)
    tp2Level   := entryPrice - (xATR * tpRatio2)
    tp1Hit     := false
    tp2Hit     := false

hitTP1 = useTP and tradeDir == 1 and not tp1Hit and high >= tp1Level
hitTP2 = useTP and tradeDir == 1 and tp1Hit and not tp2Hit and high >= tp2Level

hitSellTP1 = useTP and tradeDir == -1 and not tp1Hit and low <= tp1Level
hitSellTP2 = useTP and tradeDir == -1 and tp1Hit and not tp2Hit and low <= tp2Level

if hitTP1 or hitSellTP1
    tp1Hit := true
if hitTP2 or hitSellTP2
    tp2Hit := true

// ==========================================
// 5. LABELS & VERTICAL TP LINES
// ==========================================
// Buy Label
if buySignal
    label.new(bar_index, low, text="BUY", style=label.style_label_up, color=colorBuy, textcolor=color.white, size=size.normal)

// Sell Label
if sellSignal
    label.new(bar_index, high, text="SELL", style=label.style_label_down, color=colorSell, textcolor=color.white, size=size.normal)

// Vertikálne čiary a "x TP" značky pri zasiahnutí cieľa
if (hitTP1 or hitTP2) and tradeDir == 1
    label.new(bar_index, high, text="x\nTP", style=label.style_none, textcolor=colorBuy, size=size.small)
    line.new(bar_index, low - (xATR * 4), bar_index, high + (xATR * 4), color=color.new(colorBuy, 40), width=1)

if (hitSellTP1 or hitSellTP2) and tradeDir == -1
    label.new(bar_index, low, text="x\nTP", style=label.style_none, textcolor=colorSell, size=size.small)
    line.new(bar_index, low - (xATR * 4), bar_index, high + (xATR * 4), color=color.new(colorSell, 40), width=1)
````

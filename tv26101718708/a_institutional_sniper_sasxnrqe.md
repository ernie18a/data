# A+ INSTITUTIONAL SNIPER

- url: https://www.tradingview.com/script/sasxnrQE-A-INSTITUTIONAL-SNIPER/
- type: indicator
- pine_id: PUB;52db1906f0bd4f758699989086867f55
- version: 1.0

## Description

# A+ INSTITUTIONAL SNIPER

A+ INSTITUTIONAL SNIPER is a professional Smart Money Concepts (SMC) and ICT-based trading indicator built for traders who want only the highest-quality institutional setups.

This indicator is specially optimized for:

• NASDAQ Futures (NQ / MNQ)  
• XAUUSD (Gold)  
• Forex  
• Indices  

The system combines multiple professional confirmations into one powerful A+ setup engine designed to filter low-quality trades and highlight only strong institutional opportunities.

━━━━━━━━━━━━━━━━━━
CORE FEATURES
━━━━━━━━━━━━━━━━━━

✓ EMA Trend Filter  
Trades only in the direction of the higher probability trend.

✓ Liquidity Sweep Detection  
Detects stop hunts and liquidity grabs above highs and below lows.

✓ Market Structure Shift (MSS)  
Identifies bullish and bearish structure breaks after liquidity is taken.

✓ Displacement Candle Detection  
Confirms strong momentum candles used by institutional traders.

✓ Fair Value Gaps (FVG)  
Automatically detects imbalance zones for premium entries.

✓ Higher Timeframe Confirmation  
Uses HTF bias to improve trade accuracy.

✓ RSI Momentum Confirmation  
Avoids weak market conditions and low-quality setups.

✓ ATR Volatility Filter  
Filters low-volatility environments and improves trade quality.

✓ Premium & Discount Zones  
Helps identify optimal buy and sell locations.

✓ Institutional Order Blocks  
Highlights possible smart money reaction zones.

✓ London & New York Killzones  
Focuses on high-liquidity institutional trading sessions.

━━━━━━━━━━━━━━━━━━
A+ SETUP ENGINE
━━━━━━━━━━━━━━━━━━

The indicator uses a multi-confirmation scoring system that combines:

• Trend  
• Liquidity Sweep  
• MSS  
• FVG  
• Order Block  
• RSI Momentum  
• Volatility  
• Session Timing  
• HTF Bias  

Only setups with strong confluence are displayed.

━━━━━━━━━━━━━━━━━━
ENTRY MANAGEMENT
━━━━━━━━━━━━━━━━━━

The indicator automatically displays:

✓ Entry Price  
✓ Stop Loss (SL)  
✓ Take Profit 1 (TP1)  
✓ Take Profit 2 (TP2)

This helps traders manage risk and execute trades with clear structure.

━━━━━━━━━━━━━━━━━━
BEST SETTINGS
━━━━━━━━━━━━━━━━━━

Recommended Timeframes:

• 15M → Bias  
• 5M → Setup  
• 1M → Entry

Best Trading Sessions:

• London Open  
• New York Open

━━━━━━━━━━━━━━━━━━
BEST USED FOR
━━━━━━━━━━━━━━━━━━

• Scalping  
• Intraday Trading  
• Prop Firm Trading  
• Futures Trading  
• Gold Trading  
• ICT / SMC Strategies

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This indicator is for educational and informational purposes only. Trading involves risk. No indicator guarantees profits. Always use proper risk management.

## Source Code

````pine
//@version=6
indicator("A+ INSTITUTIONAL SNIPER", overlay=true)
// SETTINGS
emaLength = input.int(200, "EMA Trend")
swingLength = input.int(5, "Swing Length")
atrMult = input.float(1.5, "ATR Multiplier")
riskReward1 = input.float(1.5, "TP1 RR")
riskReward2 = input.float(3.0, "TP2 RR")
// EMA TREND
ema200 = ta.ema(close, emaLength)
bullTrend = close > ema200
bearTrend = close < ema200
plot(ema200, color=color.orange, linewidth=2)
// RSI
rsi = ta.rsi(close, 14)
bullRSI = rsi > 55
bearRSI = rsi < 45
// ATR
atr = ta.atr(14)
// SWINGS
swingHigh = ta.pivothigh(high, swingLength, swingLength)
swingLow = ta.pivotlow(low, swingLength, swingLength)
var float lastHigh = na
var float lastLow = na
if not na(swingHigh)
    lastHigh := high[swingLength]
if not na(swingLow)
    lastLow := low[swingLength]
// LIQUIDITY SWEEP
bullSweep = not na(lastLow) and low < lastLow and close > lastLow
bearSweep = not na(lastHigh) and high > lastHigh and close < lastHigh
// MARKET STRUCTURE SHIFT
bullMSS = close > high[1]
bearMSS = close < low[1]
// DISPLACEMENT
bullDisplacement = close > open and (close - open) > atr * 0.5
bearDisplacement = close < open and (open - close) > atr * 0.5
// FAIR VALUE GAP
bullFVG = low > high[2]
bearFVG = high < low[2]
if bullFVG
    box.new(
        left=bar_index - 2,
        right=bar_index + 5,
        top=low,
        bottom=high[2],
        bgcolor=color.new(color.green, 85),
        border_color=color.green
    )
if bearFVG
    box.new(
        left=bar_index - 2,
        right=bar_index + 5,
        top=low[2],
        bottom=high,
        bgcolor=color.new(color.red, 85),
         border_color=color.red
    )
    // BUY & SELL CONDITIONS
buySignal = bullTrend and bullRSI and bullSweep and bullMSS and bullDisplacement
sellSignal = bearTrend and bearRSI and bearSweep and bearMSS and bearDisplacement
// ENTRY / SL / TP
buyEntry = close
buySL = low - atr * atrMult
buyTP1 = buyEntry + ((buyEntry - buySL) * riskReward1)
buyTP2 = buyEntry + ((buyEntry - buySL) * riskReward2)
sellEntry = close
sellSL = high + atr * atrMult
sellTP1 = sellEntry - ((sellSL - sellEntry) * riskReward1)
sellTP2 = sellEntry - ((sellSL - sellEntry) * riskReward2)
// BUY SIGNAL
if buySignal
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.lime, textcolor=color.black)
    line.new(bar_index, buySL, bar_index + 20, buySL, color=color.red, width=2)
    line.new(bar_index, buyTP1, bar_index + 20, buyTP1, color=color.green, width=2)
    line.new(bar_index, buyTP2, bar_index + 20, buyTP2, color=color.lime, width=2)
// SELL SIGNAL
if sellSignal
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white)
    line.new(bar_index, sellSL, bar_index + 20, sellSL, color=color.red, width=2)
    line.new(bar_index, sellTP1, bar_index + 20, sellTP1, color=color.green, width=2)
    line.new(bar_index, sellTP2, bar_index + 20, sellTP2, color=color.lime, width=2)
// ALERTS
alertcondition(buySignal, title="BUY ALERT", message="BUY SIGNAL")
alertcondition(sellSignal, title="SELL ALERT", message="SELL SIGNAL")
````

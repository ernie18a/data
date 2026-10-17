# Buy the Dip Score [Frank's Scanner]

- url: https://www.tradingview.com/script/QQelfmYQ-Buy-the-Dip-Score-Frank-s-Scanner/
- type: indicator
- pine_id: PUB;8a9bbc188c3b41bcb61551e580992a8c
- version: 1.0

## Description

Look at the bottom panel — the indicator now shows:                                                                                                                
                                                                                                                                                                     
  NEW Color Logic (Option A: Buy the Dip)                                                                                                                            
                                                                                                                                                                     
  ┌───────────┬───────┬─────────────────────┬──────────────────────┐                                                                                                 
  │   Color   │ Score │       Meaning       │        Action        │                                                                                                 
  ├───────────┼───────┼─────────────────────┼──────────────────────┤                                                                                                 
  │ 🔴 RED    │ 8-10  │ EXTREME OVERSOLD    │ 🚀 BEST TIME TO BUY! │                                                                                                 
  ├───────────┼───────┼─────────────────────┼──────────────────────┤                                                                                                 
  │ 🟠 ORANGE │ 6-8   │ VERY OVERSOLD       │ 💪 Strong buy signal │                                                                                                 
  ├───────────┼───────┼─────────────────────┼──────────────────────┤                                                                                                 
  │ 🟡 YELLOW │ 4-6   │ MODERATELY OVERSOLD │ ✅ Buy opportunity   │                                                                                                 
  ├───────────┼───────┼─────────────────────┼──────────────────────┤                                                                                                 
  │ 🟢 LIME   │ 2-4   │ Slightly weak       │ ⚠️  Caution           │
  ├───────────┼───────┼─────────────────────┼──────────────────────┤                                                                                                 
  │ 🟢 GREEN  │ 0-2   │ OVERBOUGHT          │ ❌ Avoid/Sell        │
  └───────────┴───────┴─────────────────────┴──────────────────────┘                                                                                                 
                                                            
  ---                                                                                                                                                                
  📊 What It's Measuring (Oversold Conditions)              
                                                                                                                                                                     
  HIGH SCORE (RED) When:
  - ✅ RSI < 30 (extreme oversold)                                                                                                                                   
  - ✅ MACD below signal line (momentum down)               
  - ✅ Price below SMA 50 AND 200 (strong downtrend)                                                                                                                 
  - ✅ Price near lower Bollinger Band (stretched down)                                                                                                              
                                                                                                                                                                     
  This is PANIC SELLING = Your buying opportunity!

## Source Code

````pine
//@version=6
indicator("Buy the Dip Score [Frank's Scanner]", overlay=false, max_bars_back=100)

// HIGH SCORE = RED = OVERSOLD = BEST BUY
// LOW SCORE = GREEN = OVERBOUGHT = AVOID

rsi = ta.rsi(close, 14)
[macd_line, signal_line, hist_line] = ta.macd(close, 12, 26, 9)
sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)
[bb_upper, bb_middle, bb_lower] = ta.bb(close, 20, 2)

// RSI - OVERSOLD is HIGH SCORE (0-2 points)
rsi_score = rsi < 30 ? 2.0 : (rsi < 40 ? 1.0 : 0.0)

// MACD - NEGATIVE is HIGH SCORE (0-2 points)
macd_score = macd_line < signal_line and hist_line < 0 ? 2.0 : (macd_line < signal_line ? 1.0 : 0.0)

// Moving Averages - BELOW is HIGH SCORE (0-2 points)
ma_score = close < sma200 ? 2.0 : 0.0
ma_score := ma_score + (close < sma50 ? 1.0 : 0.0)

// Bollinger Bands - NEAR LOWER is HIGH SCORE (0-2 points)
bb_range = bb_upper - bb_lower
bb_position = bb_range > 0 ? (close - bb_lower) / bb_range : 0.5
bb_score = bb_position < 0.2 ? 2.0 : (bb_position < 0.3 ? 1.0 : 0.0)

// Total Score (0-10)
total_score = rsi_score + macd_score + ma_score + bb_score

// Colors: RED=Oversold (Buy), GREEN=Overbought (Avoid)
color_score = total_score >= 8 ? color.new(color.red, 0) :
              total_score >= 6 ? color.new(color.orange, 0) :
              total_score >= 4 ? color.new(color.yellow, 0) :
              total_score >= 2 ? color.new(color.lime, 0) :
              color.new(color.green, 0)

plot(total_score, title="Oversold Score", color=color_score, style=plot.style_columns, linewidth=3)
hline(4, "Moderate Buy", color.yellow, linestyle=hline.style_dashed)
hline(6, "Strong Buy", color.orange, linestyle=hline.style_dashed)
hline(8, "EXTREME Buy", color.red, linestyle=hline.style_dashed)
````

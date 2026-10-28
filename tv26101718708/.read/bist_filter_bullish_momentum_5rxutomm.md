# BIST Filter -  Bullish Momentum

- url: https://www.tradingview.com/script/5RXUtomm-BIST-Filter-Bullish-Momentum/
- type: indicator
- pine_id: PUB;c844d1ce54d445bbb77d3ed3407f1c3e
- version: 1.0

## Description

Scans BIST stocks through 20 simultaneous technical filters covering volume, trend strength, momentum oscillators, moving average alignment, and Ichimoku analysis. Designed to find stocks with  
  strong bullish momentum across multiple confirmations.
                                                                                                                                                                                                    
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📌 ALL 20 FILTERS

  Volume & Trend Strength:                                                                                                                                                                          
  • Relative Volume > 1.4 (above average activity)
  • ADX(14) > 25 (strong trend)                                                                                                                                                                     
  • +DI(14) > -DI(14) (bullish directional movement)
                                                                                                                                                                                                    
  Price Above Key EMAs:                                                                                                                                                                             
  • Price > EMA(20)                                                                                                                                                                                 
  • Price > EMA(50)                                                                                                                                                                                 
  • Price > EMA(200)

  Momentum Oscillators:
  • RSI(14) > 50 (bullish momentum)
  • MACD(12,26) > MACD Signal (bullish crossover)                                                                                                                                                   
  • MFI(14) > 50 (money flowing in)                                                                                                                                                                 
  • Chaikin Money Flow(20) > 0.2 (strong accumulation)                                                                                                                                              
  • Stoch RSI Fast >= Stoch RSI Slow (bullish stochastic)                                                                                                                                           
                                                                                                                                                                                                    
  Trend Confirmation:                                                                                                                                                                               
  • Parabolic SAR < Price (bullish SAR)                                                                                                                                                             
  • Hull MA(9) < Price (short-term trend up)                                                                                                                                                        
  • Ichimoku Conversion Line < Price (above cloud support)                                                                                                                                          
                                                                                                                                                                                                    
  MA Alignment:                                                                                                                                                                                     
  • EMA(10) < EMA(50) < EMA(100)                                                                                                                                                                    
  • EMA(200) < EMA(100)                                                                                                                                                                             
  • SMA(10) < SMA(50) < SMA(100)
  • SMA(200) < SMA(100)                                                                                                                                                                             
                  
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                                      
                  
  📊 SCREENER COLUMNS                                                                                                                                                                               
                  
  • ALL PASS — 1 when all 20 filters pass (use this to filter)
  • Score % — Percentage of filters passed (partial matches)
  • Filters Passed — Count out of 20                                                                                                                                                                
  • RSI / ADX / Rel Volume / MFI / CMF — Individual indicator values                                                                                                                                
  • MACD Hist / StochRSI Diff — Momentum differentials                                                                                                                                              
                                                                                                                                                                                                    
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                                      
                                                                                                                                                                                                    
  🎯 HOW TO USE   

  Strict Mode:                                                                                                                                                                                      
  Pine Screener → Filter ALL PASS = 1 → Only stocks passing all 20 filters
                                                                                                                                                                                                    
  Flexible Mode:  
  Pine Screener → Sort by Score % descending → See strongest partial matches                                                                                                                        
  Example: Score 85% = 17/20 filters passed                                                                                                                                                         
                                                                                                                                                                                                    
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                                      
                                                                                                                                                                                                    
  💡 NOTES        

  • Designed for Pine Screener with BIST watchlist (500+ stocks)                                                                                                                                    
  • All filters run simultaneously — no sequential dependency
  • MA alignment checks for a specific market structure pattern                                                                                                                                     
  • Works on all timeframes supported by Pine Screener (1m to 1M)                                                                                                                                   
                                                                                                                                                                                                    
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                                      
                                                                                                                                                                                                    
  ⚠️  DISCLAIMER   
  This indicator is for educational and informational purposes only. It does not constitute financial advice. Always do your own analysis before making trading decisions. Past performance does not
   guarantee future results.

## Source Code

````pine
// This Pine Script™ is subject to the Terms of Use: https://www.tradingview.com/pine-script-docs/
// @version=6
// @description BIST Filter Set 1 - Bullish Momentum Scanner
// USAGE: Save → Favorite (star) → Pine Screener → Select this indicator → Scan

indicator("BIST Filter Set 1 - Bullish Momentum", overlay=false)

// ============================================================
// CALCULATIONS
// ============================================================

// --- Relative Volume ---
relVol = ta.sma(volume, 20)
relVolRatio = relVol != 0 ? volume / relVol : 0.0

// --- RSI ---
rsiVal = ta.rsi(close, 14)

// --- ADX / DI ---
[diPlus, diMinus, adxVal] = ta.dmi(14, 14)

// --- EMAs ---
ema10  = ta.ema(close, 10)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

// --- SMAs ---
sma10  = ta.sma(close, 10)
sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)

// --- MACD ---
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)

// --- Parabolic SAR ---
sarVal = ta.sar(0.02, 0.02, 0.2)

// --- Money Flow Index (14) ---
mfiVal = ta.mfi(hlc3, 14)

// --- Chaikin Money Flow (20) ---
cmfPeriod = 20
mfMultiplier = ((close - low) - (high - close)) / (high - low)
mfMultiplierSafe = high == low ? 0.0 : mfMultiplier
mfVolume = mfMultiplierSafe * volume
cmfVal = ta.sma(volume, cmfPeriod) != 0 ? math.sum(mfVolume, cmfPeriod) / math.sum(volume, cmfPeriod) : 0.0

// --- Hull Moving Average (9) ---
hullLen = 9
hullHalf = ta.wma(close, hullLen / 2)
hullFull = ta.wma(close, hullLen)
hullVal  = ta.wma(2 * hullHalf - hullFull, math.round(math.sqrt(hullLen)))

// --- Stochastic RSI (3, 3, 14, 14) ---
rsiForStoch  = ta.rsi(close, 14)
stochRsiK    = ta.sma(ta.stoch(rsiForStoch, rsiForStoch, rsiForStoch, 14), 3)
stochRsiD    = ta.sma(stochRsiK, 3)

// --- Ichimoku (9, 26, 52, 26) ---
conversionPeriod = 9
basePeriod       = 26
spanBPeriod      = 52

donchian(len) =>
    (ta.highest(high, len) + ta.lowest(low, len)) / 2

ichConversion = donchian(conversionPeriod)
ichBase       = donchian(basePeriod)

// ============================================================
// FILTER CONDITIONS
// ============================================================

// Core momentum
f_relVol    = relVolRatio > 1.4
f_rsi       = rsiVal > 50
f_adx       = adxVal > 25
f_diPlus    = diPlus > diMinus

// Price above EMAs
f_aboveEma20  = close > ema20
f_aboveEma50  = close > ema50
f_aboveEma200 = close > ema200

// MACD bullish
f_macd = macdLine > signalLine

// Parabolic SAR below price (bullish)
f_sar = sarVal < close

// Money flow
f_mfi = mfiVal > 50
f_cmf = cmfVal > 0.2

// Hull MA below price
f_hull = hullVal < close

// Stoch RSI fast above slow
f_stochRsi = stochRsiK >= stochRsiD

// Ichimoku conversion below price
f_ichConv = ichConversion < close

// MA Alignment (as read from screenshot - short below long)
f_ema10_50   = ema10 < ema50
f_ema50_100  = ema50 < ema100
f_ema200_100 = ema200 < ema100
f_sma10_50   = sma10 < sma50
f_sma50_100  = sma50 < sma100
f_sma200_100 = sma200 < sma100

// ============================================================
// SCORING
// ============================================================

// Core filters (must-pass)
corePass = f_relVol and f_rsi and f_adx and f_diPlus and f_aboveEma20 and f_aboveEma50 and f_aboveEma200 and f_macd and f_sar and f_mfi and f_cmf and f_hull and f_stochRsi and f_ichConv

// MA alignment filters
maAlignPass = f_ema10_50 and f_ema50_100 and f_ema200_100 and f_sma10_50 and f_sma50_100 and f_sma200_100

// All pass
allPass = corePass and maAlignPass

// Individual scoring
totalFilters = 20
passed = 0
passed += f_relVol    ? 1 : 0
passed += f_rsi       ? 1 : 0
passed += f_adx       ? 1 : 0
passed += f_diPlus    ? 1 : 0
passed += f_aboveEma20  ? 1 : 0
passed += f_aboveEma50  ? 1 : 0
passed += f_aboveEma200 ? 1 : 0
passed += f_macd      ? 1 : 0
passed += f_sar       ? 1 : 0
passed += f_mfi       ? 1 : 0
passed += f_cmf       ? 1 : 0
passed += f_hull      ? 1 : 0
passed += f_stochRsi  ? 1 : 0
passed += f_ichConv   ? 1 : 0
passed += f_ema10_50  ? 1 : 0
passed += f_ema50_100 ? 1 : 0
passed += f_ema200_100? 1 : 0
passed += f_sma10_50  ? 1 : 0
passed += f_sma50_100 ? 1 : 0
passed += f_sma200_100? 1 : 0

scorePct = passed / totalFilters * 100.0

// ============================================================
// PLOT OUTPUTS (Pine Screener columns)
// ============================================================

plot(allPass ? 1 : 0,  "ALL PASS",          color=color.yellow)
plot(scorePct,         "Score %",            color=color.white)
plot(passed,           "Filters Passed",     color=color.green)
plot(rsiVal,           "RSI(14)",            color=color.purple)
plot(adxVal,           "ADX(14)",            color=color.blue)
plot(relVolRatio,      "Rel Volume",         color=color.orange)
plot(mfiVal,           "MFI(14)",            color=color.teal)
plot(cmfVal,           "CMF(20)",            color=color.fuchsia)
plot(macdLine - signalLine, "MACD Hist",     color=color.lime)
plot(stochRsiK - stochRsiD, "StochRSI Diff", color=color.red)
````

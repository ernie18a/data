# BIST Fibonacci Retracement Scanner 

- url: https://www.tradingview.com/script/HKgUkWh8-BIST-Fibonacci-Retracement-Scanner/
- type: indicator
- pine_id: PUB;a74502ca32a5400f8cfe7ecf93076bf9
- version: 1.0

## Description

Automatically detects swing highs/lows, determines trend direction, and finds stocks currently sitting at key Fibonacci retracement levels — potential buy or sell zones.                         
   
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                                      
                  
  📌 HOW IT WORKS                                                                                                                                                                                   
   
  1. Detects significant swing points using pivot analysis                                                                                                                                          
  2. Determines trend: higher lows = uptrend, lower highs = downtrend
  3. Calculates Fibonacci retracement levels between swing points                                                                                                                                   
  4. Flags stocks where price is near a Fib level (within configurable tolerance)
                                                                                                                                                                                                    
  • Uptrend pullback to Fib support → BUY zone                                                                                                                                                      
  • Downtrend bounce to Fib resistance → SELL/AVOID zone                                                                                                                                            
                                                                                                                                                                                                    
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📊 SCREENER COLUMNS                                                                                                                                                                               
   
  • SIGNAL — 1 when price is at a Fib level (use this to filter)                                                                                                                                    
  • Trend — 1 = uptrend (buy zone), -1 = downtrend (sell zone)
  • Fib Level Hit — Which level triggered: 38.2%, 50%, or 61.8%                                                                                                                                     
  • Dist from Fib — How close price is to the exact level                                                                                                                                           
  • Retracement Depth — How deep the pullback is from the swing high                                                                                                                                
  • RSI / Volume — Extra confirmation data                                                                                                                                                          
                  
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                                      
                  
  ⚙️  SETTINGS

  • Swing Lookback: Pivot detection period (default: 20 bars)                                                                                                                                       
  • Fib Levels: 0.382 / 0.5 / 0.618 — toggle each on/off
  • Tolerance: How close to Fib line to trigger (default: 2%)                                                                                                                                       
  • Trend Filter: Uptrend only / Downtrend only / Both                                                                                                                                              
  • Optional: RSI and Volume confirmation filters                                                                                                                                                   
                                                                                                                                                                                                    
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🎯 BEST USED WITH                                                                                                                                                                                 
   
  Pine Screener → BIST watchlist → Filter SIGNAL = 1 → Sort by Fib Level or Retracement Depth                                                                                                       
                  
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                                      
                  
  ⚠️  DISCLAIMER                                                                                                                                                                                     
  This indicator is for educational and informational purposes only. It does not constitute financial advice. Always do your own analysis before making trading decisions. Past performance does not
   guarantee future results.

## Source Code

````pine
// This Pine Script™ is subject to the Terms of Use: https://www.tradingview.com/pine-script-docs/
// @version=6
// @description BIST Fibonacci Retracement Scanner
// Finds stocks pulling back to Fibonacci levels in uptrends or bouncing to Fib levels in downtrends.
// USAGE: Save → Favorite (star) → Pine Screener → Select this indicator → Scan

indicator("BIST Fibonacci Scanner", overlay=false, max_bars_back=500)

// ============================================================
// INPUTS
// ============================================================

swingLen       = input.int(20, "Swing Lookback (bars)", minval=5, maxval=100, group="Swing Detection", tooltip="Number of bars to detect swing highs/lows. Higher = larger swings, fewer signals.")
trendBars      = input.int(100, "Trend Lookback (bars)", minval=20, maxval=400, group="Swing Detection", tooltip="How far back to look for the trend-defining swing points.")

fibLevel1      = input.float(0.382, "Fib Level 1", minval=0, maxval=1, step=0.001, group="Fibonacci Levels")
fibLevel2      = input.float(0.5,   "Fib Level 2", minval=0, maxval=1, step=0.001, group="Fibonacci Levels")
fibLevel3      = input.float(0.618, "Fib Level 3", minval=0, maxval=1, step=0.001, group="Fibonacci Levels")
useFib1        = input.bool(true, "Enable Fib Level 1 (0.382)", group="Fibonacci Levels")
useFib2        = input.bool(true, "Enable Fib Level 2 (0.5)", group="Fibonacci Levels")
useFib3        = input.bool(true, "Enable Fib Level 3 (0.618)", group="Fibonacci Levels")

tolerancePct   = input.float(2.0, "Tolerance % (how close to Fib level)", minval=0.1, maxval=10.0, step=0.1, group="Detection", tooltip="Price must be within this % of a Fib level to trigger.")
trendMode      = input.string("Both", "Trend Filter", options=["Uptrend Only", "Downtrend Only", "Both"], group="Detection")

// Optional momentum confirmation
useRsiConfirm  = input.bool(false, "Require RSI Confirmation", group="Confirmation Filters")
rsiOversold    = input.float(40.0, "RSI Below (for uptrend pullback)", group="Confirmation Filters", tooltip="In uptrend, RSI should be low = oversold pullback.")
rsiOverbought  = input.float(60.0, "RSI Above (for downtrend bounce)", group="Confirmation Filters", tooltip="In downtrend, RSI should be high = overbought bounce.")

useVolConfirm  = input.bool(false, "Require Volume Confirmation", group="Confirmation Filters")
volMultiplier  = input.float(1.2, "Min Volume/Avg Ratio", minval=0.5, group="Confirmation Filters")

// ============================================================
// SWING DETECTION
// ============================================================

// Find pivot highs and lows
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow  = ta.pivotlow(low, swingLen, swingLen)

// Track the most recent swing high and swing low
var float lastSwingHigh     = na
var int   lastSwingHighBar  = na
var float lastSwingLow      = na
var int   lastSwingLowBar   = na
var float prevSwingHigh     = na
var float prevSwingLow      = na

if not na(pivotHigh)
    prevSwingHigh    := lastSwingHigh
    lastSwingHigh    := pivotHigh
    lastSwingHighBar := bar_index - swingLen

if not na(pivotLow)
    prevSwingLow    := lastSwingLow
    lastSwingLow    := pivotLow
    lastSwingLowBar := bar_index - swingLen

// ============================================================
// TREND DETERMINATION
// ============================================================

// Uptrend: swing low is more recent than swing high AND price above swing low
// OR: higher highs and higher lows pattern
bool isUptrend   = false
bool isDowntrend = false

if not na(lastSwingHigh) and not na(lastSwingLow)
    // Method: Compare swing positions and price structure
    // Uptrend: last swing low is higher than previous swing low, price pulling back
    if not na(prevSwingLow)
        isUptrend := lastSwingLow > prevSwingLow
    else
        isUptrend := close > lastSwingLow

    if not na(prevSwingHigh)
        isDowntrend := lastSwingHigh < prevSwingHigh
    else
        isDowntrend := close < lastSwingHigh

    // Simple fallback: EMA direction
    if na(prevSwingLow) and na(prevSwingHigh)
        ema50 = ta.ema(close, 50)
        isUptrend   := close > ema50
        isDowntrend := close < ema50

// ============================================================
// FIBONACCI CALCULATION
// ============================================================

// For UPTREND: Fib retracement from swing low (bottom) to swing high (top)
//   Price pulling back DOWN toward fib levels = buy zone
//   Fib 0.382 = shallow pullback, 0.618 = deep pullback

// For DOWNTREND: Fib retracement from swing high (top) to swing low (bottom)
//   Price bouncing UP toward fib levels = resistance/sell zone
//   Fib 0.382 = shallow bounce, 0.618 = deep bounce

var float fibPrice1_up = na
var float fibPrice2_up = na
var float fibPrice3_up = na
var float fibPrice1_dn = na
var float fibPrice2_dn = na
var float fibPrice3_dn = na
var float swingRange   = na

// Uptrend fibs (retracement from high)
if not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh > lastSwingLow
    swingRange   := lastSwingHigh - lastSwingLow
    fibPrice1_up := lastSwingHigh - swingRange * fibLevel1
    fibPrice2_up := lastSwingHigh - swingRange * fibLevel2
    fibPrice3_up := lastSwingHigh - swingRange * fibLevel3

// Downtrend fibs (retracement from low)
if not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh > lastSwingLow
    fibPrice1_dn := lastSwingLow + swingRange * fibLevel1
    fibPrice2_dn := lastSwingLow + swingRange * fibLevel2
    fibPrice3_dn := lastSwingLow + swingRange * fibLevel3

// ============================================================
// PROXIMITY CHECK
// ============================================================

isNear(price, level, tolerPct) =>
    not na(level) and not na(price) and level != 0 and math.abs(price - level) / level * 100 <= tolerPct

// Uptrend: price near fib support (pulling back down)
nearFib1_up = useFib1 and isNear(close, fibPrice1_up, tolerancePct)
nearFib2_up = useFib2 and isNear(close, fibPrice2_up, tolerancePct)
nearFib3_up = useFib3 and isNear(close, fibPrice3_up, tolerancePct)
nearAnyFib_up = nearFib1_up or nearFib2_up or nearFib3_up

// Downtrend: price near fib resistance (bouncing up)
nearFib1_dn = useFib1 and isNear(close, fibPrice1_dn, tolerancePct)
nearFib2_dn = useFib2 and isNear(close, fibPrice2_dn, tolerancePct)
nearFib3_dn = useFib3 and isNear(close, fibPrice3_dn, tolerancePct)
nearAnyFib_dn = nearFib1_dn or nearFib2_dn or nearFib3_dn

// ============================================================
// SIGNAL LOGIC
// ============================================================

// RSI
rsiVal = ta.rsi(close, 14)

// Volume
volAvg   = ta.sma(volume, 20)
volRatio = volAvg != 0 ? volume / volAvg : 0.0

// Uptrend pullback to fib = BUY signal
rsiConfirmUp = not useRsiConfirm or rsiVal < rsiOversold
volConfirm   = not useVolConfirm or volRatio >= volMultiplier

uptrendSignal   = isUptrend and nearAnyFib_up and rsiConfirmUp and volConfirm
downtrendSignal = isDowntrend and nearAnyFib_dn and (not useRsiConfirm or rsiVal > rsiOverbought) and volConfirm

// Apply trend mode filter
signal = switch trendMode
    "Uptrend Only"   => uptrendSignal
    "Downtrend Only" => downtrendSignal
    "Both"           => uptrendSignal or downtrendSignal
    => false

// Determine which fib level was hit
fibLevelHit = nearFib1_up or nearFib1_dn ? fibLevel1 : nearFib2_up or nearFib2_dn ? fibLevel2 : nearFib3_up or nearFib3_dn ? fibLevel3 : 0.0

// Trend direction as number: 1 = uptrend pullback (buy), -1 = downtrend bounce (sell/short), 0 = no signal
trendDir = uptrendSignal ? 1 : downtrendSignal ? -1 : 0

// Distance from nearest fib level (%)
nearestFibPrice = fibLevelHit == fibLevel1 ? (isUptrend ? fibPrice1_up : fibPrice1_dn) : fibLevelHit == fibLevel2 ? (isUptrend ? fibPrice2_up : fibPrice2_dn) : fibLevelHit == fibLevel3 ? (isUptrend ? fibPrice3_up : fibPrice3_dn) : na
distFromFib = not na(nearestFibPrice) and nearestFibPrice != 0 ? (close - nearestFibPrice) / nearestFibPrice * 100 : na

// Fib retracement depth (how far price has retraced from the swing)
retracePct = not na(swingRange) and swingRange != 0 and not na(lastSwingHigh) ? (lastSwingHigh - close) / swingRange * 100 : na

// ============================================================
// PLOT OUTPUTS (Pine Screener columns)
// ============================================================

plot(signal ? 1 : 0,        "SIGNAL (1=match)",      color=color.yellow)
plot(trendDir,               "Trend (1=up, -1=down)", color=color.white)
plot(fibLevelHit * 100,      "Fib Level Hit (%)",     color=color.orange)
plot(nz(distFromFib),        "Dist from Fib %",       color=color.green)
plot(nz(retracePct),         "Retracement Depth %",   color=color.blue)
plot(rsiVal,                 "RSI(14)",               color=color.purple)
plot(volRatio,               "Vol/Avg Ratio",         color=color.teal)
plot(nz(lastSwingHigh),      "Swing High",            color=color.lime)
plot(nz(lastSwingLow),       "Swing Low",             color=color.red)
plot(isUptrend ? 1 : isDowntrend ? -1 : 0, "Trend Dir Raw", color=color.gray)
````

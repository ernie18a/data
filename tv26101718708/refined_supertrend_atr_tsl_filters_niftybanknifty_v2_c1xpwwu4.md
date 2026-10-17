# Refined Supertrend ATR + TSL + Filters [Nifty/BankNifty] V2

- url: https://www.tradingview.com/script/c1XpwWU4-Refined-Supertrend-ATR-TSL-Filters-Nifty-BankNifty-V2/
- type: strategy
- pine_id: PUB;62dde0a20f994329a93594f1c92b8f5c
- version: 1.0

## Description

This is a trend-following strategy built for Nifty 50 and Bank Nifty (and similar Indian index futures/options), designed to capture strong trending moves while using multiple layers of risk management.
Core Idea
It uses the Supertrend indicator as the primary trend detection and trailing mechanism, enhanced with:

Trend confirmation filters
Multi-level profit taking
Dynamic trailing stop (TSL)
Breakeven protection


Entry Rules
Long Entry:

Price crosses above the Supertrend line
Optional Filters:
Price is above 200 EMA (if enabled)
ADX > 20 (trend strength filter, if enabled)

Trade only during Indian market hours (9:15–15:30 IST) if session filter is on
Longs disabled if "Short Only" mode is active

Short Entry:

Price crosses below the Supertrend line
Same filters as above (price below 200 EMA + ADX > 20)
Shorts disabled if "Long Only" mode is active


Exit Rules (Risk Management)
The strategy uses a hybrid exit system:

Multi-Level Take Profit (Partial Scaling Out)
40% of position closed at 1.5 × ATR profit
30% of position closed at 3.0 × ATR profit
30% of position closed at 5.0 × ATR profit

Trailing Stop (Dynamic)
Supertrend line acts as the base trailing stop
Extra ATR Trailing Stop (custom TSL): Tightens the stop to Close - 2.0 × ATR (default) as price moves in favor
The stop is the higher of Supertrend and the custom ATR TSL (for longs)

Breakeven
Once price reaches 1.5 × ATR in profit, the stop moves to entry price (locks in breakeven)


This combination allows the strategy to:

Book partial profits early
Let winners run with a trailing stop
Protect capital with breakeven


Key Settings & Filters

Feature Default Purpose Supertrend ATR Length10 Sensitivity of trend Supertrend Factor 3.0 Distance of band200 EMA Filter Enabled Trade only in direction of major trend ADX Filter Enabled Avoid choppy/sideways markets Extra ATR TSL2.0Tight trailing stopBreakeven1.5 ATR Move to breakeven Position Size10% equity Risk per trade Commission0.04% Realistic for Indian brokers

Visual Elements

Green/Red Supertrend line (main trend indicator)
Orange 200 EMA
Purple ADX in separate pane
Background coloring (light green/red) when both Supertrend + EMA agree
Entry labels ("LONG"/"SHORT")


Best Use Case

Nifty 50 & Bank Nifty futures/options
Trending market conditions (works poorly in sideways/choppy markets — hence the ADX filter)
Intraday or short swing trades
Works on 5-minute to 15-minute timeframes typically.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vimalboiling

//@version=5
strategy("Refined Supertrend ATR + TSL + Filters [Nifty/BankNifty] V2", 
         overlay=true, 
         default_qty_type=strategy.percent_of_equity, 
         default_qty_value=10, 
         commission_type=strategy.commission.percent, 
         commission_value=0.04,
         close_entries_rule="ANY")

// ── Inputs ─────────────────────────────────────
groupST = "Supertrend Settings"
atrLength   = input.int(10, "ATR Length", minval=1, group=groupST)
factor      = input.float(3.0, "Supertrend Factor", minval=0.1, step=0.1, group=groupST)

groupFilter = "Trend Filters"
useEMAFilter = input.bool(true, "Use 200 EMA Trend Filter", group=groupFilter)
useADXFilter = input.bool(true, "Use ADX Trend Strength Filter", group=groupFilter)
diLength     = input.int(14, "DI Length (for ADX)", minval=1, group=groupFilter)
adxSmoothing = input.int(14, "ADX Smoothing", minval=1, group=groupFilter)
adxThreshold = input.int(20, "ADX Minimum Threshold", minval=10, group=groupFilter)

groupRisk = "Risk Management"
useExtraTSL   = input.bool(true, "Use Extra ATR Trailing Stop", group=groupRisk)
tslAtrMult    = input.float(2.0, "Extra TSL ATR Multiplier", minval=0.1, group=groupRisk)

useBreakeven  = input.bool(true, "Enable Breakeven", group=groupRisk)
breakevenMult = input.float(1.5, "Breakeven after X ATR", minval=0.5, group=groupRisk)

useMultiTP = input.bool(true, "Use Multi-Level Take Profit", group=groupRisk)
tp1Mult = input.float(1.5, "TP1 (R) - Close 40%", minval=0.5, group=groupRisk)
tp2Mult = input.float(3.0, "TP2 (R) - Close 30%", minval=0.5, group=groupRisk)
tp3Mult = input.float(5.0, "TP3 (R) - Close 30%", minval=0.5, group=groupRisk)

longOnly  = input.bool(false, "Long Only (Disable Shorts)", group="Trade Direction")
shortOnly = input.bool(false, "Short Only (Disable Longs)", group="Trade Direction")

useSession = input.bool(true, "Use Indian Market Session (9:15-15:30)", group="Session")

showLabels = input.bool(true, "Show Entry/Exit Labels", group="Visuals")

// ── Calculations ───────────────────────────────
atrVal = ta.atr(atrLength)
[supertrendLine, direction] = ta.supertrend(factor, atrLength)

ema200 = ta.ema(close, 200)

// ADX
[diPlus, diMinus, adxVal] = ta.dmi(diLength, adxSmoothing)

// Trend conditions
upTrend   = direction < 0
downTrend = direction > 0

emaBull = close > ema200
emaBear = close < ema200

trendStrong = adxVal > adxThreshold

inSession = not useSession or (time("1440", "0915-1530", "Asia/Kolkata"))

// ── Entry Conditions ───────────────────────────
longCondition  = ta.crossover(close, supertrendLine) and 
                 (not useEMAFilter or emaBull) and 
                 (not useADXFilter or trendStrong) and 
                 inSession and not shortOnly

shortCondition = ta.crossunder(close, supertrendLine) and 
                 (not useEMAFilter or emaBear) and 
                 (not useADXFilter or trendStrong) and 
                 inSession and not longOnly

if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)

// ── Risk Management ────────────────────────────
var float entryPrice = na
var float longTSL    = na
var float shortTSL   = na

if (strategy.position_size != 0)
    entryPrice := strategy.position_avg_price
else
    entryPrice := na
    longTSL    := na
    shortTSL   := na

// Extra ATR Trailing Stop
if (strategy.position_size > 0)
    longTSL := math.max(nz(longTSL), close - tslAtrMult * atrVal)

if (strategy.position_size < 0)
    shortTSL := math.min(nz(shortTSL), close + tslAtrMult * atrVal)

// Breakeven
if (useBreakeven and strategy.position_size > 0 and close >= entryPrice + breakevenMult * atrVal)
    longTSL := math.max(nz(longTSL), entryPrice)

if (useBreakeven and strategy.position_size < 0 and close <= entryPrice - breakevenMult * atrVal)
    shortTSL := math.min(nz(shortTSL), entryPrice)

// Multi TP Levels
tp1Long = entryPrice + tp1Mult * atrVal
tp2Long = entryPrice + tp2Mult * atrVal
tp3Long = entryPrice + tp3Mult * atrVal

tp1Short = entryPrice - tp1Mult * atrVal
tp2Short = entryPrice - tp2Mult * atrVal
tp3Short = entryPrice - tp3Mult * atrVal

// ── Exits ──────────────────────────────────────
if (strategy.position_size > 0)
    strategy.exit("TP1 Long", from_entry="Long", qty_percent=40, limit=tp1Long, comment="TP1 40%")
    strategy.exit("TP2 Long", from_entry="Long", qty_percent=30, limit=tp2Long, comment="TP2 30%")
    strategy.exit("TP3 Long", from_entry="Long", qty_percent=30, limit=tp3Long, comment="TP3 30%")
    
    stopLevelLong = math.max(supertrendLine, nz(longTSL))
    strategy.exit("TSL Long", from_entry="Long", stop=stopLevelLong, comment="TSL")

if (strategy.position_size < 0)
    strategy.exit("TP1 Short", from_entry="Short", qty_percent=40, limit=tp1Short, comment="TP1 40%")
    strategy.exit("TP2 Short", from_entry="Short", qty_percent=30, limit=tp2Short, comment="TP2 30%")
    strategy.exit("TP3 Short", from_entry="Short", qty_percent=30, limit=tp3Short, comment="TP3 30%")
    
    stopLevelShort = math.min(supertrendLine, nz(shortTSL))
    strategy.exit("TSL Short", from_entry="Short", stop=stopLevelShort, comment="TSL")

// ── Plots & Visuals ────────────────────────────
plot(supertrendLine, "Supertrend", color=upTrend ? color.green : color.red, linewidth=2)
plot(ema200, "200 EMA", color=color.orange, linewidth=1)
plot(adxVal, "ADX", color=color.purple, linewidth=1, display=display.pane)

// ✅ FIXED Background Color
bgcolor(upTrend and emaBull ? color.new(color.green, 90) : downTrend and emaBear ? color.new(color.red, 90) : na)

// Labels
if (showLabels and longCondition)
    label.new(bar_index, low, "LONG", color=color.green, style=label.style_label_up, textcolor=color.white, size=size.small)

if (showLabels and shortCondition)
    label.new(bar_index, high, "SHORT", color=color.red, style=label.style_label_down, textcolor=color.white, size=size.small)

// Alerts
alertcondition(longCondition,  "Long Entry",  "Supertrend Long Signal (with filters)")
alertcondition(shortCondition, "Short Entry", "Supertrend Short Signal (with filters)")
````

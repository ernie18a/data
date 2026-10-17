# 1-Min Rapid Scalper

- url: https://www.tradingview.com/script/d7hoosSf-1-Min-Rapid-Scalper/
- type: strategy
- pine_id: PUB;36d5bc1b4c1e4a12a21a6a01790efe66
- version: 2.0

## Description

A Heikin Ashi candle morphology sequencer engineered to detect three-bar momentum accelerations following a directional color-flip reversal. Filtered by ADX trend strength and equipped with a dual-mode exit system — a 1-bar impulse capture by default, or full ATR-based TP/SL management with a hard-cap Plug stop — the strategy is purpose-built for ultra-short timeframe execution where speed and structural precision matter more than sustained trend duration.

═══════════════════════════════════════
KEY FEATURES
═══════════════════════════════════════

Heikin Ashi Morphology Sequencer
— Three consecutive wickless candles required (open = low for longs, open = high for shorts)
— Each bar's body must strictly exceed the prior bar's body size
— A color-flip on the 4th lookback bar confirms genuine regime reversal
— Separate long and short sequencers with mirror-image logic

Precision Heikin Ashi Source
— True HA values pulled via ticker.heikinashi() and request.security()
— No approximation — morphology integrity preserved across all timeframes
— Overlaid cleanly on the standard candlestick chart

ADX Trend Strength Filter
— Full DMI calculation (DI+ and DI−) via ta.dmi()
— ADX must exceed configurable threshold at signal bar
— Eliminates entries during directionless, low-conviction market conditions

Dual Exit System
— 1-Bar Exit (default): close command issued on entry bar, executes at next bar's open
— ATR Mode: TP and SL locked at entry price using prior bar's ATR — no mid-trade recalculation
— The Plug: hard percentage stop caps maximum loss regardless of ATR width

═══════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════

Step 1 — Color-Flip Confirmation
The 4th bar back must be the opposite color to the signal candles. Bearish on bar 4 precedes long setups; bullish precedes shorts. This confirms the sequence is an emergence from the opposite regime — not continuation of exhausted momentum.

Step 2 — Three-Bar Acceleration Sequence
Bars 1, 2, and 3 (looking back from signal bar) must each be wickless on their entry side and larger in body than the preceding bar. For longs: open equals low on all three bars. For shorts: open equals high. The expanding body size requirement confirms compounding directional conviction, not just sustained direction.

Step 3 — ADX Gate
ADX must exceed the configured threshold at the moment of signal. This confirms the market is exhibiting sufficient trend energy to justify a momentum entry. Signals that pass candle morphology but occur during low-ADX environments are filtered.

Step 4 — Entry
Entry is placed at the open of the bar immediately following the signal. No repainting — all conditions are evaluated on confirmed bars.

Step 5 — Exit
Default (1-Bar): strategy.close() is issued on the entry bar. With process_orders_on_close = false, the engine triggers execution at the very next bar's open — harvesting the initial impulse and exiting before any adverse development.

ATR Mode: TP and SL are calculated once at the position-open bar using the prior bar's ATR value (avoiding look-ahead). Levels are locked into strategy.exit() immediately. The Plug applies math.max() (longs) or math.min() (shorts) to enforce whichever stop is tighter — ATR-derived or percentage-derived — so maximum loss is always bounded.

═══════════════════════════════════════
THE WICKLESS CONDITION EXPLAINED
═══════════════════════════════════════

A wickless bullish Heikin Ashi candle occurs when haOpen equals haLow — meaning buyers controlled every tick of that bar with zero retracement. Three consecutive wickless bars with each body larger than the last represents compounding momentum conviction. It is a structural fingerprint of institutional-grade directional pressure, not random noise. The color-flip prerequisite ensures this conviction is fresh — not the tail end of a prior trend.

═══════════════════════════════════════
THE PLUG — RISK ARCHITECTURE
═══════════════════════════════════════

ATR-based stops are volatile by nature — during wide-range sessions, a 2× ATR stop can represent a significant percentage drawdown. The Plug introduces a percentage-based ceiling on loss distance that operates independently of ATR. Whichever stop is closer to entry price is applied. This design ensures that even in extreme volatility conditions, a single trade can never breach a user-defined maximum loss threshold.

═══════════════════════════════════════
RECOMMENDED USE
═══════════════════════════════════════

— Primary timeframe: 1-minute (strategy is named and tuned for this)
— Works on any liquid instrument: forex, crypto, equity futures, indices
— 1-Bar Exit mode is best suited for instruments with tight spreads and fast fills
— ATR mode with The Plug is better suited for instruments with wider intrabar volatility
— Lower ADX thresholds will increase signal frequency; higher values increase selectivity
— Backtest across multiple sessions before deploying with real capital

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BVL-Crypto

//@version=6
strategy('1-Min Rapid Scalper', overlay = true, process_orders_on_close = false, initial_capital = 1000, default_qty_type = strategy.cash, default_qty_value = 10000,
     commission_type = strategy.commission.percent, commission_value = 0, pyramiding = 0, margin_long = 0, margin_short = 0, slippage = 2)

// ==============================================================================
// 1. OVERARCHING SETTINGS & INPUTS
// ==============================================================================
grp_main = 'Main Direction & Logic'
tradeDir = input.string('Both', title = 'Trade Direction Toggle', options = ['Long', 'Short', 'Both'], group = grp_main)

grp_ind = 'Indicator Settings (ADX)'
adxLen = input.int(7, title = 'ADX Length', minval = 1, group = grp_ind)
adxThresh = input.float(25.0, title = 'ADX Threshold', minval = 0.0, group = grp_ind)

grp_exit = 'Exit Settings'
useAtr = input.bool(true, title = 'Enable ATR Multiplier Exit (Overrides 1-Bar Exit)', group = grp_exit)
atrLen = input.int(14, title = 'ATR Length', minval = 1, group = grp_exit)
tpMult = input.float(5.0, title = 'Take Profit (ATR Multiplier)', step = 0.1, group = grp_exit)
slMult = input.float(1.0, title = 'Stop Loss (ATR Multiplier)', step = 0.1, group = grp_exit)
thePlug = input.float(1.0, title = 'The Plug (Hard SL %)', step = 0.1, group = grp_exit)

// ==============================================================================
// 2. DATA ACQUISITION: HEIKIN ASHI & ADX
// ==============================================================================
// Pulling precise Heikin Ashi values for the active timeframe
ticker_id = ticker.heikinashi(syminfo.tickerid)
[haOpen, haHigh, haLow, haClose] = request.security(ticker_id, timeframe.period, [open, high, low, close])

// Calculating ADX
[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxLen)

// ==============================================================================
// 3. CANDLE MORPHOLOGY & LOGIC
// ==============================================================================
// Calculate HA Body Size
haSize = math.abs(haClose - haOpen)

// Direction and Wick Evaluations
isHaBull = haClose > haOpen
isHaBear = haClose < haOpen
noWickBull = haOpen == haLow
noWickBear = haOpen == haHigh

// Sequencer: Long
bull1 = isHaBull[2] and noWickBull[2]
bull2 = isHaBull[1] and noWickBull[1] and haSize[1] > haSize[2]
bull3 = isHaBull and noWickBull and haSize > haSize[1]
colorFlipBull = isHaBear[3] // Previous candle must be bearish for the flip

// Sequencer: Short
bear1 = isHaBear[2] and noWickBear[2]
bear2 = isHaBear[1] and noWickBear[1] and haSize[1] > haSize[2]
bear3 = isHaBear and noWickBear and haSize > haSize[1]
colorFlipBear = isHaBull[3] // Previous candle must be bullish for the flip

// Final Triggers combined with ADX Filter
longTrigger = colorFlipBull and bull1 and bull2 and bull3 and adxValue > adxThresh
shortTrigger = colorFlipBear and bear1 and bear2 and bear3 and adxValue > adxThresh

// ==============================================================================
// 4. ORDER EXECUTION & ROUTING
// ==============================================================================
// Variables for dynamic ATR target tracking
var float longTP = na
var float longSL = na
var float shortTP = na
var float shortSL = na

atrValue = ta.atr(atrLen)

// -- ENTRY LOGIC --
// Enters immediately at the open of the immediate next candle
if longTrigger and (tradeDir == 'Long' or tradeDir == 'Both')
    strategy.entry('Long', strategy.long, comment = 'Long')

if shortTrigger and (tradeDir == 'Short' or tradeDir == 'Both')
    strategy.entry('Short', strategy.short, comment = 'Short')

// -- EXIT LOGIC --
if useAtr
    // Lock in ATR targets exactly at the moment of entry
    if strategy.position_size > 0 and strategy.position_size[1] == 0
        float atrStop = strategy.opentrades.entry_price(0) - atrValue[1] * slMult
        float plugStop = strategy.opentrades.entry_price(0) * (1 - thePlug / 100)

        longTP := strategy.opentrades.entry_price(0) + atrValue[1] * tpMult
        longSL := math.max(atrStop, plugStop) // The Plug caps the maximum allowable loss distance
        longSL

    if strategy.position_size < 0 and strategy.position_size[1] == 0
        float atrStop = strategy.opentrades.entry_price(0) + atrValue[1] * slMult
        float plugStop = strategy.opentrades.entry_price(0) * (1 + thePlug / 100)

        shortTP := strategy.opentrades.entry_price(0) - atrValue[1] * tpMult
        shortSL := math.min(atrStop, plugStop) // The Plug caps the maximum allowable loss distance
        shortSL

    // Execute ATR Exits
    if strategy.position_size > 0
        strategy.exit('Exit Long', 'Long', limit = longTP, stop = longSL, comment = 'TP')
    if strategy.position_size < 0
        strategy.exit('Exit Short', 'Short', limit = shortTP, stop = shortSL, comment = 'TP')
        // 1-Bar Exit Logic (Exit on close of entry candle)
        // By issuing a close command during the entry candle, the execution engine
else // triggers it at the immediate next open (which is equivalent to the entry candle's close)
    if strategy.position_size > 0
        strategy.close('Long', comment = 'TP')
    if strategy.position_size < 0
        strategy.close('Short', comment = 'TP')

// Optional Visual Debugging: Highlight the 3rd trigger candle
bgcolor(longTrigger ? color.new(color.green, 85) : na, title = 'Long Trigger Background')
bgcolor(shortTrigger ? color.new(color.red, 85) : na, title = 'Short Trigger Background')
````

# LAZY DOG

- url: https://www.tradingview.com/script/UJwSLens-LAZY-DOG/
- type: strategy
- pine_id: PUB;018a14d4845a49449beac56dc439e46b
- version: 3.0

## Description

OVERVIEW
LAZY DOG is a systematic, intraday cryptocurrency options trading model designed for BTCUSD. It tracks simulated out-of-the-money (OTM) Call (CE) and Put (PE) premium metrics based on direct underlying price shifts. The model relies on dynamic capital rotation, hyper-aggressive scaling breakout parameters, and an automatic mathematical memory reset engine.

[2] CORE PARAMETERS & CONVERSIONS
* Target Asset: BTCUSD (Spot / Futures Index)
* Base Multiplier Setup: 1 Trading Lot = 0.001 BTC
* Initial Baseline Unit Quantity: 10 Lots per leg
* Re-entry / Breakout Scaling Factor: 10x Multiplier (100 Lots)
* OTM Strike Matrix Deviation: 2.5% Out-of-the-Money
[3] EXECUTION RULES & LOGICAL ROUTINES
* Session Launch Window:
  At exactly 18:00, the system initiates a balanced market neutrality posture by simultaneously purchasing a base lot size of 2.5% OTM Call and 2.5% OTM Put contracts.

* Breakout Aggression Protocol (10x Momentum Build):
  - If the simulated CE contract value gains 100%, it creates an immediate buy trigger for a 10x sized OTM Put contract.
  - If the simulated PE contract value gains 100%, it creates an immediate buy trigger for a 10x sized OTM Call contract.

* Trailing Mitigation Routine (50% Peak Floor):
  All running active execution legs are continuously monitored by a trailing high filter. If the current value of an option contract decreases by 50% from its absolute lifetime peak premium value, the script terminates that underperforming leg and immediately rotates capital by buying a 10x sized position in the opposite option contract type.

RISK GUARDRAILS AND AUTOMATED TERMINATION
• Account Protective Cap Filters:
Global maximum risk caps are verified on every market tick. The absolute performance ceiling is capped at a maximum profit of +$50 USD per unit, and the absolute loss floor is locked at a maximum loss of -$25 USD per unit.
• Auto-Reset Memory Engine:
If either the +$50 profit target or the -$25 loss floor is struck inside the daily active trading window, the system terminates all live trades, wipes the tracking variables clean, and instantly launches a fresh baseline contract cycle on the very same bar.
• Hard Cutoff Window:
At exactly 17:28, the engine breaks all loops, clears out existing position parameters, and forcefully closes all remaining open legs to lock in final net returns before the daily close.

## Source Code

````pine
//@version=6
strategy("LAZY DOG", shorttitle="LAZY DOG", overlay=true, initial_capital=1000, default_qty_type=strategy.cash, default_qty_value=0, commission_type=strategy.commission.cash_per_contract, commission_value=0.65, slippage=2, process_orders_on_close=true)

// ==========================================
// USER INPUTS & PARAMETERS (TRADETRON MATRIX)
// ==========================================
var string G_SIZE   = "Position Sizing Matrix"
baseLots            = input.float(10.0, title="Initial Short Lots (10 = 0.01 Qty)", group=G_SIZE)
repairLots          = input.float(100.0, title="Repair Long Lots (100 = 0.1 Qty)", group=G_SIZE)

var string G_OPT    = "Option Strike Setup (OTM6)"
strikeOffset        = input.float(600.0, title="Strangle Strike Offset (Points)", group=G_OPT)
basePremiumInput    = input.float(100.0, title="Simulated Base Premium (USD)", minval=1.0, group=G_OPT)

var string G_RISK   = "Strict Trailing Exit Engine"
maxLossTarget       = input.float(-19.0, title="Hard Strategy Max Loss ($)", group=G_RISK)       
maxProfitCap        = input.float(50.0, title="Strategy Max Profit Target ($)", group=G_RISK)     
trailingProfitDrop  = input.float(2.0, title="Profit Trailing Deviation ($)", group=G_RISK)      

// ==========================================
// CONVERSIONS & TIME WINDOW ENGINE (IST TO UTC)
// ==========================================
float contractSizePerLot = 0.001
float baseQty            = baseLots * contractSizePerLot
float dynamicQty         = repairLots * contractSizePerLot

int currentHHMM = hour * 100 + minute

bool isExitTime    = (currentHHMM == 1158) 
bool isAnchorTime  = (currentHHMM == 1201) 

bool inBlackoutWindow = (currentHHMM >= 0830) and (currentHHMM <= 1158)

// ==========================================
// STATE MACHINE REGISTERS
// ==========================================
var float initialSpot        = na
var float strikeCE           = na
var float strikePE           = na
var int   cycleStateCE       = 0   
var int   cycleStatePE       = 0   
var float anchorCEPremium    = 0.0
var float anchorPEPremium    = 0.0
var float peakRepairCEValue  = 0.0
var float peakRepairPEValue  = 0.0
var float maxStrategyProfit  = 0.0

// ==========================================
// INTRADAY AUTO-RESET & LAUNCH MECHANICS
// ==========================================
float currentOpenProfit = strategy.openprofit
bool isFlat = (strategy.position_size == 0)

maxStrategyProfit := isFlat ? 0.0 : math.max(nz(maxStrategyProfit, 0.0), currentOpenProfit)

bool conditionMaxLoss   = (not isFlat) and (currentOpenProfit <= maxLossTarget)
bool conditionTrailing  = (not isFlat) and (maxStrategyProfit >= maxProfitCap) and ((maxStrategyProfit - currentOpenProfit) >= trailingProfitDrop)
bool universalExitFired = conditionMaxLoss or conditionTrailing or isExitTime

if universalExitFired
    strategy.close_all(comment=isExitTime ? "DAILY TIMED EXIT" : "UNIVERSAL EXIT")
    initialSpot       := na
    cycleStateCE      := 0
    cycleStatePE      := 0
    maxStrategyProfit := 0.0

int barsSinceExit = ta.barssince(universalExitFired)
bool coolOffGapPassed = na(barsSinceExit) or (barsSinceExit >= 12)

bool triggerFreshCycle = (na(initialSpot) or isFlat) and coolOffGapPassed and (not inBlackoutWindow)

if triggerFreshCycle and not isExitTime
    initialSpot        := close
    strikeCE           := math.round((close + strikeOffset) / 200.0) * 200.0
    strikePE           := math.round((close - strikeOffset) / 200.0) * 200.0
    anchorCEPremium    := basePremiumInput
    anchorPEPremium    := basePremiumInput
    cycleStateCE       := 1
    cycleStatePE       := 1
    maxStrategyProfit  := 0.0
    strategy.entry("Base CE", strategy.short, qty=baseQty, comment="SHORT CE BASE")
    strategy.entry("Base PE", strategy.short, qty=baseQty, comment="SHORT PE BASE")

// ==========================================
// DYNAMIC OPTION PREMIUM SIMULATION MATRIX
// ==========================================
bool strategyActive = not na(initialSpot)
float currentCEPrice = strategyActive ? math.max(0.5, anchorCEPremium - (close - initialSpot)) : na
float currentPEPrice = strategyActive ? math.max(0.5, anchorPEPremium + (initialSpot - close)) : na

float repairCEPrice = strategyActive ? math.max(0.5, basePremiumInput + (close - initialSpot)) : na
float repairPEPrice = strategyActive ? math.max(0.5, basePremiumInput + (initialSpot - close)) : na

// ==========================================
// FAST-RESPONSE ENTRY & HIGH-SPEED TRAILING
// ==========================================
bool ceSpiked50 = strategyActive and (close >= strikeCE)
bool peSpiked50 = strategyActive and (close <= strikePE)

if strategyActive and (not isFlat) and not universalExitFired
    if cycleStateCE == 1 and ceSpiked50
        strategy.close("Base CE", comment="SQ CE BASE")
        strategy.entry("M_CE", strategy.long, qty=dynamicQty, comment="REPAIR LONG CE") 
        peakRepairCEValue := repairCEPrice
        cycleStateCE := 2

if cycleStateCE == 2
    peakRepairCEValue := math.max(peakRepairCEValue, repairCEPrice)
    if repairCEPrice <= (peakRepairCEValue * 0.75)
        strategy.close("M_CE", comment="SQ REPAIR CE")
        cycleStateCE := 4 

if strategyActive and (not isFlat) and not universalExitFired
    if cycleStatePE == 1 and peSpiked50
        strategy.close("Base PE", comment="SQ PE BASE")
        strategy.entry("M_PE", strategy.long, qty=dynamicQty, comment="REPAIR LONG PE") 
        peakRepairPEValue := repairPEPrice
        cycleStatePE := 2

if cycleStatePE == 2
    peakRepairPEValue := math.max(peakRepairPEValue, repairPEPrice)
    if repairPEPrice <= (peakRepairPEValue * 0.75)
        strategy.close("M_PE", comment="SQ REPAIR PE")
        cycleStatePE := 4

// ==========================================
// PLOTS & STRANGLE BOUNDARIES
// ==========================================
plot(strategyActive ? strikeCE : na, title="CE Strike Upper", color=color.new(color.green, 20), style=plot.style_stepline, linewidth=2)
plot(strategyActive ? strikePE : na, title="PE Strike Lower", color=color.new(color.red, 20), style=plot.style_stepline, linewidth=2)

// ==========================================
// STATUS BAR TELEMETRY (NO CANVAS CLUTTER)
// ==========================================
plot(currentCEPrice, title="Live CE Premium", color=color.new(color.green, 100), display=display.status_line)
plot(currentPEPrice, title="Live PE Premium", color=color.new(color.red, 100), display=display.status_line)
plot(strategy.netprofit, title="Strategy Net PnL", color=color.new(color.blue, 100), display=display.status_line)
````

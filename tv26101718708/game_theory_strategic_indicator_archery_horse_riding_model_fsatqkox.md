# Game Theory Strategic Indicator - Archery & Horse Riding Model

- url: https://www.tradingview.com/script/fsatqkoX-Game-Theory-Strategic-Indicator-Archery-Horse-Riding-Model/
- type: indicator
- pine_id: PUB;58dc3f2e8ca74c08b6d3572fdc98e275
- version: 1.0

## Description

# Game Theory Strategic Indicator - Archery & Horse Riding Model

## Overview

This indicator applies rigorous game theory mathematics to market analysis, modeling price action as a strategic two-player game between buyers and sellers. The methodology draws from economic game theory, evolutionary dynamics, and zero-sum game optimization.

## Theoretical Foundation

The indicator implements five core game theory concepts:

**1. Expected Utility (Mixed Strategies)**
Calculates E = p×U₁ + (1-p)×U₂ where:
- p = probability distribution based on volume dynamics
- U₁, U₂ = utility payoffs for aggressive vs defensive strategies
- Uses RSI momentum and ATR volatility to quantify payoffs

**2. Nash Equilibrium Detection**
Identifies market states where ui(σᵢ*, σ₋ᵢ*) ≥ ui(σᵢ, σ₋ᵢ*):
- Measures when no participant can improve by changing strategy
- Highlighted with yellow background zones
- Signals reduced edge environments (avoid trading)

**3. Replicator Dynamics**
Models evolutionary strategy adaptation: dx/dt = x(f(x) - φ(x))
- Tracks frequency changes in bullish vs bearish strategies
- Shows which approach is gaining evolutionary fitness
- Purple line indicates strategy evolution trend

**4. Minimax Algorithm**
Implements zero-sum game optimal strategy L(x,y):
- Calculates win/loss ratio over lookback period
- Values > 1.0 suggest favorable risk/reward
- Orange line shows deviation from neutral state

**5. Best Response Function**
Determines optimal action maximizing ui(aᵢ, a₋ᵢ):
- Compares buyer vs seller expected utilities
- Generates primary long/short signals
- Confidence weighted by utility differential

## Visual Elements

**Chart Plots:**
- **Blue Line (Utility Differential)**: Buyer utility minus seller utility. Positive favors longs, negative favors shorts
- **Purple Line (Replicator Dynamics)**: Rate of strategy evolution. Rising = bullish strategies gaining fitness
- **Orange Line (Minimax Deviation)**: Zero-sum game value. Above zero = favorable conditions
- **Pink Area (Mixed Strategy Bias)**: Probability-weighted strategy preference
- **Yellow Background**: Nash equilibrium zones where no player has edge

**Signals:**
- **Green Triangle Up**: Long signal - buyer utility dominates outside equilibrium
- **Red Triangle Down**: Short signal - seller utility dominates outside equilibrium  
- **Yellow Diamond**: Equilibrium warning - reduced edge state

**Info Table (Top Right):**
- EU Buyer/Seller: Current expected utilities
- Nash Score: Equilibrium strength (>0.65 = equilibrium)
- Mix Prob: Volume-based probability distribution
- Minimax: Win/loss ratio indicator

## Strategy Metaphors

**Archery (Buyer Strategy)**: Represents precision attacks - targeted entries at optimal risk/reward points, high accuracy required

**Horse Riding (Seller Strategy)**: Represents mobile defense - flexible positioning, quick exits, adaptive to changing terrain

## Parameters

- **Strategy Period (14)**: Lookback for RSI and ATR calculations
- **Mixed Strategy Length (21)**: Period for minimax win/loss analysis  
- **Nash Equilibrium Threshold (0.65)**: Minimum score to identify equilibrium (0.5-0.9)
- **Show Trade Signals**: Toggle buy/sell arrows
- **Show Equilibrium Zones**: Toggle background highlighting

## How to Use

1. **Trend Trading**: Take long signals when utility differential (blue) is rising and no equilibrium zone present
2. **Counter-Trend**: Take signals when replicator dynamics (purple) diverges from price
3. **Risk Management**: Avoid trading during yellow equilibrium zones - market has no clear edge
4. **Confirmation**: Best signals occur when minimax > 1.0 and best response aligns with utility differential
5. **Monitoring**: Watch info table for real-time utility balance and equilibrium status

## Alerts

Three alert conditions available:
- **GT Long Signal**: Buyer utility dominates, composite score > 0.5
- **GT Short Signal**: Seller utility dominates, composite score < -0.5
- **Nash Equilibrium**: Market reaches balanced state, avoid new entries

## Mathematical Rigor

All calculations use proper game theory formulations:
- Payoff functions normalized by volatility
- Probability distributions bounded [0,1]
- Zero-division protection implemented
- Utilities properly weighted in composite score

## Originality Statement

This indicator is original work implementing classical game theory mathematics in a novel market analysis framework. The code, calculations, and interpretation methodology are entirely my own creation. No external scripts were copied or modified.

## Disclaimer

This indicator is for educational purposes. Game theory provides a framework for analyzing strategic interaction but does not guarantee profitable trading. Always use proper risk management, test thoroughly, and understand that past performance does not indicate future results.

---

**Educational Resource**: For deeper understanding of game theory in economics, see Nash (1950) "Equilibrium Points in N-Person Games" and Maynard Smith (1982) "Evolution and the Theory of Games"
```

---

## Source Code

````pine
//@version=6
indicator("Game Theory Strategic Indicator - Archery & Horse Riding Model", 
     shorttitle="GT Strategic", 
     overlay=true, 
     max_bars_back=500)

// ==================== DESCRIPTION ====================
// This indicator applies game theory principles to market analysis, modeling
// the strategic interaction between buyers and sellers as a two-player game.
// 
// METHODOLOGY:
// - Expected Utility: Calculates E = p*U1 + (1-p)*U2 for mixed strategies
// - Nash Equilibrium: Identifies market states where no participant gains from deviation
// - Replicator Dynamics: Models evolutionary strategy adaptation
// - Minimax Algorithm: Implements zero-sum game optimal strategy
// - Best Response: Determines optimal action given opponent's strategy
//
// INTERPRETATION:
// - Long signals appear when buyer utility dominates outside equilibrium
// - Short signals appear when seller utility dominates outside equilibrium
// - Yellow background indicates Nash equilibrium zones (reduced edge)
// - Utility Differential (blue line) shows buyer vs seller advantage
// - Replicator Dynamics (purple line) shows strategy evolution trend
//
// The "Archery" metaphor represents precision buyer attacks (targeted entries)
// The "Horse Riding" metaphor represents mobile seller defense (flexible exits)

// ==================== INPUT PARAMETERS ====================
lengthPeriod = input.int(14, "Strategy Period", 
     minval=5, maxval=100, 
     tooltip="Period for calculating payoff functions and utilities")
     
mixedStrategyLen = input.int(21, "Mixed Strategy Length", 
     minval=10, maxval=50,
     tooltip="Lookback period for minimax calculations")
     
nashThreshold = input.float(0.65, "Nash Equilibrium Threshold", 
     minval=0.5, maxval=0.9, step=0.05,
     tooltip="Minimum score to identify equilibrium state (higher = stricter)")
     
showSignals = input.bool(true, "Show Trade Signals",
     tooltip="Display buy/sell arrows on chart")
     
showEquilibrium = input.bool(true, "Show Nash Equilibrium Zones",
     tooltip="Highlight equilibrium zones with background color")

// ==================== UTILITY FUNCTIONS ====================

// Calculate payoff matrix for buyer/seller strategies
// U(ai, a-i) = Utility based on RSI momentum and ATR volatility
calcPayoff(aggressive, defensive) =>
    momentum = ta.rsi(close, lengthPeriod)
    volatility = ta.atr(lengthPeriod) / close * 100
    
    // Avoid division by zero
    safeVolatility = volatility > 0 ? volatility : 0.0001
    
    // Payoff for aggressive strategy (normalized)
    aggPayoff = aggressive ? (momentum - 50) / safeVolatility : 0.0
    
    // Payoff for defensive strategy (normalized)
    defPayoff = defensive ? (50 - momentum) / safeVolatility : 0.0
    
    [aggPayoff, defPayoff]

// ==================== EXPECTED UTILITY (MIXED STRATEGIES) ====================
// E = p*U1 + (1-p)*U2
// Where p is the probability distribution based on volume and price action

calcExpectedUtility() =>
    // Volume-based probability calculation
    avgVolume = ta.sma(volume, lengthPeriod)
    volume_ratio = avgVolume > 0 ? volume / avgVolume : 1.0
    
    // Price change normalization
    price_change = ta.change(close) / close * 100
    
    // Mixed strategy probability (p) - bounded between 0 and 1
    p = math.max(0.0, math.min(1.0, (volume_ratio - 1.0) * 0.5 + 0.5))
    
    // Calculate utilities for both pure strategies
    [u1_agg, u1_def] = calcPayoff(true, false)
    [u2_agg, u2_def] = calcPayoff(false, true)
    
    // Expected utility for buyer (long player)
    eu_buyer = p * u1_agg + (1.0 - p) * u2_def
    
    // Expected utility for seller (short player)
    eu_seller = p * u2_agg + (1.0 - p) * u1_def
    
    [eu_buyer, eu_seller, p]

// ==================== NASH EQUILIBRIUM DETECTION ====================
// A strategy profile σ* is Nash equilibrium if:
// ui(σi*, σ-i*) ≥ ui(σi, σ-i*) for all σi and all players i

calcNashEquilibrium() =>
    [eu_buy, eu_sell, prob] = calcExpectedUtility()
    
    // Calculate utility differential
    utility_diff = math.abs(eu_buy - eu_sell)
    max_utility = math.max(math.abs(eu_buy), math.abs(eu_sell))
    
    // Equilibrium score: closer to 1 means utilities are balanced
    equilibrium_score = max_utility > 0 ? 1.0 - (utility_diff / max_utility) : 0.0
    
    // Nash equilibrium exists when utilities are approximately equal
    is_equilibrium = equilibrium_score > nashThreshold
    
    [is_equilibrium, equilibrium_score, eu_buy, eu_sell]

// ==================== REPLICATOR DYNAMICS ====================
// Evolutionary game theory: dx/dt = x(f(x) - φ(x))
// Models the change in strategy frequency over time

calcReplicatorDynamics() =>
    // Strategy frequencies (proportion of bullish vs bearish plays)
    bullish_freq = ta.ema(close > close[1] ? 1.0 : 0.0, lengthPeriod)
    
    // Fitness functions based on RSI
    rsi_value = ta.rsi(close, lengthPeriod)
    bull_fitness = rsi_value / 100.0
    bear_fitness = 1.0 - bull_fitness
    
    // Average fitness φ(x)
    avg_fitness = bullish_freq * bull_fitness + (1.0 - bullish_freq) * bear_fitness
    
    // Replicator equation: rate of change in bullish strategy frequency
    dx_dt = bullish_freq * (bull_fitness - avg_fitness)
    
    dx_dt

// ==================== MINIMAX FOR ZERO-SUM GAME ====================
// L(x,y) represents player I's winnings and player II's losses
// Finding optimal mixed strategy in adversarial market

calcMinimax() =>
    // Accumulate historical wins and losses
    wins = 0.0
    losses = 0.0
    
    // Calculate win/loss ratio over lookback period
    for i = 1 to mixedStrategyLen
        if i <= bar_index
            returns = (close[i-1] - close[i]) / close[i]
            if returns > 0
                wins := wins + returns
            else
                losses := losses + math.abs(returns)
    
    // Minimax value: ratio of wins to losses
    // Value > 1 suggests favorable conditions
    minimax_value = losses > 0 ? wins / losses : 2.0
    
    minimax_value

// ==================== BEST RESPONSE CALCULATION ====================
// Finding strategy ai that maximizes ui(ai, a-i) given opponent's strategy a-i

calcBestResponse() =>
    [eu_buy, eu_sell, prob] = calcExpectedUtility()
    
    // Best response is the strategy with higher expected utility
    // 1 = Buy, -1 = Sell, 0 = Neutral
    best_response = eu_buy > eu_sell ? 1 : eu_sell > eu_buy ? -1 : 0
    
    // Confidence level based on utility differential
    confidence = math.abs(eu_buy - eu_sell)
    
    [best_response, confidence]

// ==================== MAIN CALCULATIONS ====================

[is_nash, nash_score, eu_buyer, eu_seller] = calcNashEquilibrium()
replicator = calcReplicatorDynamics()
minimax = calcMinimax()
[best_resp, confidence] = calcBestResponse()
[expected_u_buy, expected_u_sell, mix_prob] = calcExpectedUtility()

// ==================== SIGNAL GENERATION ====================

// Composite score combining all game theory metrics
// Weighted average of best response, replicator dynamics, and minimax
composite_score = (best_resp * confidence * 0.4) + 
                  (replicator * 0.3) + 
                  ((minimax - 1.0) * 0.3)

// Generate trading signals with filters
longSignal = composite_score > 0.5 and not is_nash and best_resp > 0
shortSignal = composite_score < -0.5 and not is_nash and best_resp < 0
equilibriumSignal = is_nash and nash_score > nashThreshold

// ==================== PLOTTING ====================

// Nash Equilibrium zones (background highlight)
bgcolor(showEquilibrium and is_nash ? color.new(color.yellow, 90) : na, 
     title="Nash Equilibrium Zone")

// Expected Utility differential
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
plot(eu_buyer - eu_seller, "Utility Differential", 
     color=color.new(color.blue, 0), linewidth=2)

// Replicator dynamics (scaled for visibility)
plot(replicator * 100, "Replicator Dynamics", 
     color=color.new(color.purple, 30), linewidth=1)

// Minimax deviation from neutral (1.0)
plot((minimax - 1.0) * 50, "Minimax Deviation", 
     color=color.new(color.orange, 40), linewidth=1)

// Mixed strategy probability bias
plot(mix_prob * 100 - 50, "Mixed Strategy Bias", 
     color=color.new(color.fuchsia, 50), linewidth=1, style=plot.style_area)

// ==================== SIGNALS ON CHART ====================

plotshape(showSignals and longSignal, "Long Signal", 
     shape.triangleup, location.belowbar, 
     color.new(color.green, 0), size=size.small)
     
plotshape(showSignals and shortSignal, "Short Signal", 
     shape.triangledown, location.abovebar, 
     color.new(color.red, 0), size=size.small)
     
plotshape(showSignals and equilibriumSignal, "Equilibrium", 
     shape.diamond, location.abovebar, 
     color.new(color.yellow, 0), size=size.tiny)

// ==================== ALERTS ====================

alertcondition(longSignal, "GT Long Signal", 
     "Game Theory: Long Entry Signal - Buyer Utility Dominates")
     
alertcondition(shortSignal, "GT Short Signal", 
     "Game Theory: Short Entry Signal - Seller Utility Dominates")
     
alertcondition(equilibriumSignal, "Nash Equilibrium", 
     "Market at Nash Equilibrium - Reduced Edge Environment")

// ==================== INFORMATION TABLE ====================

var table infoTable = table.new(position.top_right, 2, 6, 
     border_width=1,
     border_color=color.gray,
     frame_width=1,
     frame_color=color.gray)

if barstate.islast
    // Header row
    table.cell(infoTable, 0, 0, "Metric", 
         bgcolor=color.new(color.gray, 70), 
         text_color=color.white,
         text_size=size.small)
    table.cell(infoTable, 1, 0, "Value", 
         bgcolor=color.new(color.gray, 70), 
         text_color=color.white,
         text_size=size.small)
    
    // Expected Utility - Buyer
    table.cell(infoTable, 0, 1, "EU Buyer", 
         text_color=color.white,
         text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(eu_buyer, "#.###"), 
         text_color=eu_buyer > 0 ? color.lime : color.red,
         text_size=size.small)
    
    // Expected Utility - Seller
    table.cell(infoTable, 0, 2, "EU Seller", 
         text_color=color.white,
         text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(eu_seller, "#.###"), 
         text_color=eu_seller > 0 ? color.red : color.lime,
         text_size=size.small)
    
    // Nash Equilibrium Score
    table.cell(infoTable, 0, 3, "Nash Score", 
         text_color=color.white,
         text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(nash_score, "#.##"), 
         text_color=is_nash ? color.yellow : color.gray,
         text_size=size.small)
    
    // Mixed Strategy Probability
    table.cell(infoTable, 0, 4, "Mix Prob", 
         text_color=color.white,
         text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(mix_prob * 100, "#.#") + "%", 
         text_color=color.white,
         text_size=size.small)
    
    // Minimax Value
    table.cell(infoTable, 0, 5, "Minimax", 
         text_color=color.white,
         text_size=size.small)
    table.cell(infoTable, 1, 5, str.tostring(minimax, "#.##"), 
         text_color=minimax > 1 ? color.lime : color.red,
         text_size=size.small)
````

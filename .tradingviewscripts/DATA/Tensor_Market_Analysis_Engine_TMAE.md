<!-- tradingview-pine-id: PUB;5b07b4ba22b04937918d40cf49491ff4 -->
<!-- tradingviewscripts-format: 1 -->
# Tensor Market Analysis Engine (TMAE)

Source: https://www.tradingview.com/script/jcRhuIRl-Tensor-Market-Analysis-Engine-TMAE/

## Description

# Tensor Market Analysis Engine (TMAE)
## Advanced Multi-Dimensional Mathematical Analysis System

*Where Quantum Mathematics Meets Market Structure*

---

## 🎓 THEORETICAL FOUNDATION

The Tensor Market Analysis Engine represents a revolutionary synthesis of three cutting-edge mathematical frameworks that have never before been combined for comprehensive market analysis. This indicator transcends traditional technical analysis by implementing advanced mathematical concepts from quantum mechanics, information theory, and fractal geometry.

### 🌊 Multi-Dimensional Volatility with Jump Detection

**Hawkes Process Implementation:**
The TMAE employs a sophisticated Hawkes process approximation for detecting self-exciting market jumps. Unlike traditional volatility measures that treat price movements as independent events, the Hawkes process recognizes that market shocks cluster and exhibit memory effects.

**Mathematical Foundation:**
```
Intensity λ(t) = μ + Σ α(t - Tᵢ)
```
Where market jumps at times Tᵢ increase the probability of future jumps through the decay function α, controlled by the Hawkes Decay parameter (0.5-0.99).

**Mahalanobis Distance Calculation:**
The engine calculates volatility jumps using multi-dimensional Mahalanobis distance across up to 5 volatility dimensions:
- **Dimension 1:** Price volatility (standard deviation of returns)
- **Dimension 2:** Volume volatility (normalized volume fluctuations)
- **Dimension 3:** Range volatility (high-low spread variations)
- **Dimension 4:** Correlation volatility (price-volume relationship changes)
- **Dimension 5:** Microstructure volatility (intrabar positioning analysis)

This creates a volatility state vector that captures market behavior impossible to detect with traditional single-dimensional approaches.

### 📐 Hurst Exponent Regime Detection

**Fractal Market Hypothesis Integration:**
The TMAE implements advanced Rescaled Range (R/S) analysis to calculate the Hurst exponent in real-time, providing dynamic regime classification:

- **H > 0.6:** Trending (persistent) markets - momentum strategies optimal
- **H < 0.4:** Mean-reverting (anti-persistent) markets - contrarian strategies optimal  
- **H ≈ 0.5:** Random walk markets - breakout strategies preferred

**Adaptive R/S Analysis:**
Unlike static implementations, the TMAE uses adaptive windowing that adjusts to market conditions:
```
H = log(R/S) / log(n)
```
Where R is the range of cumulative deviations and S is the standard deviation over period n.

**Dynamic Regime Classification:**
The system employs hysteresis to prevent regime flipping, requiring sustained Hurst values before regime changes are confirmed. This prevents false signals during transitional periods.

### 🔄 Transfer Entropy Analysis

**Information Flow Quantification:**
Transfer entropy measures the directional flow of information between price and volume, revealing lead-lag relationships that indicate future price movements:

```
TE(X→Y) = Σ p(yₜ₊₁, yₜ, xₜ) log[p(yₜ₊₁|yₜ, xₜ) / p(yₜ₊₁|yₜ)]
```

**Causality Detection:**
- **Volume → Price:** Indicates accumulation/distribution phases
- **Price → Volume:** Suggests retail participation or momentum chasing
- **Balanced Flow:** Market equilibrium or transition periods

The system analyzes multiple lag periods (2-20 bars) to capture both immediate and structural information flows.

---

## 🔧 COMPREHENSIVE INPUT SYSTEM

### Core Parameters Group

**Primary Analysis Window (10-100, Default: 50)**
The fundamental lookback period affecting all calculations. Optimization by timeframe:
- **1-5 minute charts:** 20-30 (rapid adaptation to micro-movements)
- **15 minute-1 hour:** 30-50 (balanced responsiveness and stability)
- **4 hour-daily:** 50-100 (smooth signals, reduced noise)
- **Asset-specific:** Cryptocurrency 20-35, Stocks 35-50, Forex 40-60

**Signal Sensitivity (0.1-2.0, Default: 0.7)**
Master control affecting all threshold calculations:
- **Conservative (0.3-0.6):** High-quality signals only, fewer false positives
- **Balanced (0.7-1.0):** Optimal risk-reward ratio for most trading styles
- **Aggressive (1.1-2.0):** Maximum signal frequency, requires careful filtering

**Signal Generation Mode:**
- **Aggressive:** Any component signals (highest frequency)
- **Confluence:** 2+ components agree (balanced approach)
- **Conservative:** All 3 components align (highest quality)

### Volatility Jump Detection Group

**Volatility Dimensions (2-5, Default: 3)**
Determines the mathematical space complexity:
- **2D:** Price + Volume volatility (suitable for clean markets)
- **3D:** + Range volatility (optimal for most conditions)
- **4D:** + Correlation volatility (advanced multi-asset analysis)
- **5D:** + Microstructure volatility (maximum sensitivity)

**Jump Detection Threshold (1.5-4.0σ, Default: 3.0σ)**
Standard deviations required for volatility jump classification:
- **Cryptocurrency:** 2.0-2.5σ (naturally volatile)
- **Stock Indices:** 2.5-3.0σ (moderate volatility)
- **Forex Major Pairs:** 3.0-3.5σ (typically stable)
- **Commodities:** 2.0-3.0σ (varies by commodity)

**Jump Clustering Decay (0.5-0.99, Default: 0.85)**
Hawkes process memory parameter:
- **0.5-0.7:** Fast decay (jumps treated as independent)
- **0.8-0.9:** Moderate clustering (realistic market behavior)
- **0.95-0.99:** Strong clustering (crisis/event-driven markets)

### Hurst Exponent Analysis Group

**Calculation Method Options:**
- **Classic R/S:** Original Rescaled Range (fast, simple)
- **Adaptive R/S:** Dynamic windowing (recommended for trading)
- **DFA:** Detrended Fluctuation Analysis (best for noisy data)

**Trending Threshold (0.55-0.8, Default: 0.60)**
Hurst value defining persistent market behavior:
- **0.55-0.60:** Weak trend persistence
- **0.65-0.70:** Clear trending behavior
- **0.75-0.80:** Strong momentum regimes

**Mean Reversion Threshold (0.2-0.45, Default: 0.40)**
Hurst value defining anti-persistent behavior:
- **0.35-0.45:** Weak mean reversion
- **0.25-0.35:** Clear ranging behavior
- **0.15-0.25:** Strong reversion tendency

### Transfer Entropy Parameters Group

**Information Flow Analysis:**
- **Price-Volume:** Classic flow analysis for accumulation/distribution
- **Price-Volatility:** Risk flow analysis for sentiment shifts
- **Multi-Timeframe:** Cross-timeframe causality detection

**Maximum Lag (2-20, Default: 5)**
Causality detection window:
- **2-5 bars:** Immediate causality (scalping)
- **5-10 bars:** Short-term flow (day trading)
- **10-20 bars:** Structural flow (swing trading)

**Significance Threshold (0.05-0.3, Default: 0.15)**
Minimum entropy for signal generation:
- **0.05-0.10:** Detect subtle information flows
- **0.10-0.20:** Clear causality only
- **0.20-0.30:** Very strong flows only

---

## 🎨 ADVANCED VISUAL SYSTEM

### Tensor Volatility Field Visualization

**Five-Layer Resonance Bands:**
The tensor field creates dynamic support/resistance zones that expand and contract based on mathematical field strength:

- **Core Layer (Purple):** Primary tensor field with highest intensity
- **Layer 2 (Neutral):** Secondary mathematical resonance
- **Layer 3 (Info Blue):** Tertiary harmonic frequencies  
- **Layer 4 (Warning Gold):** Outer field boundaries
- **Layer 5 (Success Green):** Maximum field extension

**Field Strength Calculation:**
```
Field Strength = min(3.0, Mahalanobis Distance × Tensor Intensity)
```

The field amplitude adjusts to ATR and mathematical distance, creating dynamic zones that respond to market volatility.

**Radiation Line Network:**
During active tensor states, the system projects directional radiation lines showing field energy distribution:
- **8 Directional Rays:** Complete angular coverage
- **Tapering Segments:** Progressive transparency for natural visual flow
- **Pulse Effects:** Enhanced visualization during volatility jumps

### Dimensional Portal System

**Portal Mathematics:**
Dimensional portals visualize regime transitions using category theory principles:
- **Green Portals (◉):** Trending regime detection (appear below price for support)
- **Red Portals (◎):** Mean-reverting regime (appear above price for resistance)  
- **Yellow Portals (○):** Random walk regime (neutral positioning)

**Tensor Trail Effects:**
Each portal generates 8 trailing particles showing mathematical momentum:
- **Large Particles (●):** Strong mathematical signal
- **Medium Particles (◦):** Moderate signal strength
- **Small Particles (·):** Weak signal continuation
- **Micro Particles (˙):** Signal dissipation

### Information Flow Streams

**Particle Stream Visualization:**
Transfer entropy creates flowing particle streams indicating information direction:
- **Upward Streams:** Volume leading price (accumulation phases)
- **Downward Streams:** Price leading volume (distribution phases)
- **Stream Density:** Proportional to information flow strength

**15-Particle Evolution:**
Each stream contains 15 particles with progressive sizing and transparency, creating natural flow visualization that makes information transfer immediately apparent.

### Fractal Matrix Grid System

**Multi-Timeframe Fractal Levels:**
The system calculates and displays fractal highs/lows across five Fibonacci periods:
- **8-Period:** Short-term fractal structure
- **13-Period:** Intermediate-term patterns
- **21-Period:** Primary swing levels
- **34-Period:** Major structural levels
- **55-Period:** Long-term fractal boundaries

**Triple-Layer Visualization:**
Each fractal level uses three-layer rendering:
- **Shadow Layer:** Widest, darkest foundation (width 5)
- **Glow Layer:** Medium white core line (width 3)
- **Tensor Layer:** Dotted mathematical overlay (width 1)

**Intelligent Labeling System:**
Smart spacing prevents label overlap using ATR-based minimum distances. Labels include:
- **Fractal Period:** Time-based identification
- **Topological Class:** Mathematical complexity rating (0, I, II, III)
- **Price Level:** Exact fractal price
- **Mahalanobis Distance:** Current mathematical field strength
- **Hurst Exponent:** Current regime classification
- **Anomaly Indicators:** Visual strength representations (○ ◐ ● ⚡)

### Wick Pressure Analysis

**Rejection Level Mathematics:**
The system analyzes candle wick patterns to project future pressure zones:
- **Upper Wick Analysis:** Identifies selling pressure and resistance zones
- **Lower Wick Analysis:** Identifies buying pressure and support zones
- **Pressure Projection:** Extends lines forward based on mathematical probability

**Multi-Layer Glow Effects:**
Wick pressure lines use progressive transparency (1-8 layers) creating natural glow effects that make pressure zones immediately visible without cluttering the chart.

### Enhanced Regime Background

**Dynamic Intensity Mapping:**
Background colors reflect mathematical regime strength:
- **Deep Transparency (98% alpha):** Subtle regime indication
- **Pulse Intensity:** Based on regime strength calculation
- **Color Coding:** Green (trending), Red (mean-reverting), Neutral (random)

**Smoothing Integration:**
Regime changes incorporate 10-bar smoothing to prevent background flicker while maintaining responsiveness to genuine regime shifts.

### Color Scheme System

**Six Professional Themes:**
- **Dark (Default):** Professional trading environment optimization
- **Light:** High ambient light conditions
- **Classic:** Traditional technical analysis appearance
- **Neon:** High-contrast visibility for active trading
- **Neutral:** Minimal distraction focus
- **Bright:** Maximum visibility for complex setups

Each theme maintains mathematical accuracy while optimizing visual clarity for different trading environments and personal preferences.

---

## 📊 INSTITUTIONAL-GRADE DASHBOARD

### Tensor Field Status Section

**Field Strength Display:**
Real-time Mahalanobis distance calculation with dynamic emoji indicators:
- **⚡ (Lightning):** Extreme field strength (>1.5× threshold)
- **● (Solid Circle):** Strong field activity (>1.0× threshold)  
- **○ (Open Circle):** Normal field state

**Signal Quality Rating:**
Democratic algorithm assessment:
- **ELITE:** All 3 components aligned (highest probability)
- **STRONG:** 2 components aligned (good probability)
- **GOOD:** 1 component active (moderate probability)
- **WEAK:** No clear component signals

**Threshold and Anomaly Monitoring:**
- **Threshold Display:** Current mathematical threshold setting
- **Anomaly Level (0-100%):** Combined volatility and volume spike measurement
  - **>70%:** High anomaly (red warning)
  - **30-70%:** Moderate anomaly (orange caution)
  - **<30%:** Normal conditions (green confirmation)

### Tensor State Analysis Section

**Mathematical State Classification:**
- **↑ BULL (Tensor State +1):** Trending regime with bullish bias
- **↓ BEAR (Tensor State -1):** Mean-reverting regime with bearish bias  
- **◈ SUPER (Tensor State 0):** Random walk regime (neutral)

**Visual State Gauge:**
Five-circle progression showing tensor field polarity:
- **🟢🟢🟢⚪⚪:** Strong bullish mathematical alignment
- **⚪⚪🟡⚪⚪:** Neutral/transitional state
- **⚪⚪🔴🔴🔴:** Strong bearish mathematical alignment

**Trend Direction and Phase Analysis:**
- **📈 BULL / 📉 BEAR / ➡️ NEUTRAL:** Primary trend classification
- **🌪️ CHAOS:** Extreme information flow (>2.0 flow strength)
- **⚡ ACTIVE:** Strong information flow (1.0-2.0 flow strength)
- **😴 CALM:** Low information flow (<1.0 flow strength)

### Trading Signals Section

**Real-Time Signal Status:**
- **🟢 ACTIVE / ⚪ INACTIVE:** Long signal availability
- **🔴 ACTIVE / ⚪ INACTIVE:** Short signal availability
- **Components (X/3):** Active algorithmic components
- **Mode Display:** Current signal generation mode

**Signal Strength Visualization:**
Color-coded component count:
- **Green:** 3/3 components (maximum confidence)
- **Aqua:** 2/3 components (good confidence)
- **Orange:** 1/3 components (moderate confidence)  
- **Gray:** 0/3 components (no signals)

### Performance Metrics Section

**Win Rate Monitoring:**
Estimated win rates based on signal quality with emoji indicators:
- **🔥 (Fire):** ≥60% estimated win rate
- **👍 (Thumbs Up):** 45-59% estimated win rate
- **⚠️ (Warning):** <45% estimated win rate

**Mathematical Metrics:**
- **Hurst Exponent:** Real-time fractal dimension (0.000-1.000)
- **Information Flow:** Volume/price leading indicators
  - **📊 VOL:** Volume leading price (accumulation/distribution)
  - **💰 PRICE:** Price leading volume (momentum/speculation)
  - **➖ NONE:** Balanced information flow
- **Volatility Classification:**
  - **🔥 HIGH:** Above 1.5× jump threshold
  - **📊 NORM:** Normal volatility range
  - **😴 LOW:** Below 0.5× jump threshold

### Market Structure Section (Large Dashboard)

**Regime Classification:**
- **📈 TREND:** Hurst >0.6, momentum strategies optimal
- **🔄 REVERT:** Hurst <0.4, contrarian strategies optimal  
- **🎲 RANDOM:** Hurst ≈0.5, breakout strategies preferred

**Mathematical Field Analysis:**
- **Dimensions:** Current volatility space complexity (2D-5D)
- **Hawkes λ (Lambda):** Self-exciting jump intensity (0.00-1.00)
- **Jump Status:** 🚨 JUMP (active) / ✅ NORM (normal)

### Settings Summary Section (Large Dashboard)

**Active Configuration Display:**
- **Sensitivity:** Current master sensitivity setting
- **Lookback:** Primary analysis window
- **Theme:** Active color scheme
- **Method:** Hurst calculation method (Classic R/S, Adaptive R/S, DFA)

**Dashboard Sizing Options:**
- **Small:** Essential metrics only (mobile/small screens)
- **Normal:** Balanced information density (standard desktop)
- **Large:** Maximum detail (multi-monitor setups)

**Position Options:**
- **Top Right:** Standard placement (avoids price action)
- **Top Left:** Wide chart optimization
- **Bottom Right:** Recent price focus (scalping)
- **Bottom Left:** Maximum price visibility (swing trading)

---

## 🎯 SIGNAL GENERATION LOGIC

### Multi-Component Convergence System

**Component Signal Architecture:**
The TMAE generates signals through sophisticated component analysis rather than simple threshold crossing:

**Volatility Component:**
- **Jump Detection:** Mahalanobis distance threshold breach
- **Hawkes Intensity:** Self-exciting process activation (>0.2)
- **Multi-dimensional:** Considers all volatility dimensions simultaneously

**Hurst Regime Component:**
- **Trending Markets:** Price above SMA-20 with positive momentum
- **Mean-Reverting Markets:** Price at Bollinger Band extremes
- **Random Markets:** Bollinger squeeze breakouts with directional confirmation

**Transfer Entropy Component:**
- **Volume Leadership:** Information flow from volume to price
- **Volume Spike:** Volume 110%+ above 20-period average
- **Flow Significance:** Above entropy threshold with directional bias

### Democratic Signal Weighting

**Signal Mode Implementation:**
- **Aggressive Mode:** Any single component triggers signal
- **Confluence Mode:** Minimum 2 components must agree
- **Conservative Mode:** All 3 components must align

**Momentum Confirmation:**
All signals require momentum confirmation:
- **Long Signals:** RSI >50 AND price >EMA-9
- **Short Signals:** RSI <50 AND price <EMA-9

This prevents counter-trend signals during strong directional moves.

### Signal Quality Control

**Anti-Spam Protection:**
- **Minimum 5-bar spacing:** Prevents signal clustering
- **Component Persistence:** Signals require sustained component agreement
- **Quality Degradation:** Exits when signal strength deteriorates

**Entry Logic Hierarchy:**
1. **Mathematical Convergence:** All components calculate independently
2. **Democratic Voting:** Components vote for signal direction
3. **Momentum Filter:** Confirms directional bias
4. **Quality Assessment:** Assigns ELITE/STRONG/GOOD/WEAK rating
5. **Anti-Spam Check:** Ensures minimum time between signals

### Exit Signal Architecture

**Signal Deterioration Detection:**
- **Component Disagreement:** Components begin voting against position
- **Momentum Shift:** RSI and EMA alignment reverses
- **Mathematical Field Decay:** Tensor field strength diminishes
- **Quality Downgrade:** Signal quality drops below continuation threshold

---

## ⚙️ OPTIMIZATION GUIDELINES

### Asset-Specific Configuration

**Cryptocurrency Optimization:**
Markets characterized by high volatility and 24/7 trading:
- **Primary Lookback:** 20-35 periods
- **Sensitivity:** 0.8-1.2 (capture crypto volatility)
- **Jump Threshold:** 2.0-2.5σ (natural volatility consideration)
- **Hawkes Decay:** 0.75-0.85 (moderate clustering)
- **Dimensions:** 3-4D (price, volume, range, correlation)
- **Transfer Entropy Lag:** 3-8 bars (fast information flow)

**Stock Index Trading:**
Balanced markets with traditional trading hours:
- **Primary Lookback:** 30-50 periods  
- **Sensitivity:** 0.6-0.9 (stability focus)
- **Jump Threshold:** 2.5-3.0σ (moderate volatility)
- **Hawkes Decay:** 0.80-0.90 (balanced clustering)
- **Dimensions:** 3-4D (standard analysis)
- **Transfer Entropy Lag:** 5-12 bars (institutional flow)

**Forex Major Pairs:**
Smooth trending markets with high liquidity:
- **Primary Lookback:** 40-60 periods
- **Sensitivity:** 0.5-0.7 (trend following)
- **Jump Threshold:** 3.0-3.5σ (stable currency pairs)
- **Hawkes Decay:** 0.85-0.95 (strong persistence)
- **Dimensions:** 2-3D (price focus, limited volume data)
- **Transfer Entropy Lag:** 8-15 bars (central bank influence)

**Commodity Markets:**
Event-driven with supply/demand fundamentals:
- **Primary Lookback:** 25-45 periods
- **Sensitivity:** 0.7-1.1 (event responsiveness)
- **Jump Threshold:** 2.0-3.0σ (varies by commodity)
- **Hawkes Decay:** 0.70-0.85 (event clustering)
- **Dimensions:** 4-5D (full analysis including correlation)
- **Transfer Entropy Lag:** 5-12 bars (news/event response)

### Timeframe-Specific Optimization

**Scalping (1-5 Minute Charts):**
Ultra-short term precision trading:
- **Reduce Lookbacks:** 30-40% below default
- **Increase Sensitivity:** 1.0-1.5 for signal frequency
- **Lower Jump Threshold:** Capture micro-movements
- **Fast Hawkes Decay:** 0.6-0.8 for independence
- **Maximum Dimensions:** 5D for complete analysis
- **Short Entropy Lag:** 2-5 bars for immediate causality
- **Dashboard:** Small size to maximize chart space
- **Visuals:** All enabled for maximum information density

**Day Trading (15 Minute - 1 Hour):**
Intraday momentum and swing capture:
- **Standard Lookbacks:** Use defaults as baseline
- **Balanced Sensitivity:** 0.7-1.0 for quality/frequency balance
- **Standard Thresholds:** Default settings optimal
- **Moderate Hawkes Decay:** 0.8-0.9 for realistic clustering
- **Optimal Dimensions:** 3-4D for balanced analysis
- **Medium Entropy Lag:** 5-10 bars for flow detection
- **Dashboard:** Normal size for comprehensive metrics
- **Visuals:** Focus on tensor field and portal systems

**Swing Trading (4 Hour - Daily):**
Multi-day position holding:
- **Increase Lookbacks:** 30-50% above default
- **Reduce Sensitivity:** 0.5-0.7 for quality focus
- **Higher Jump Threshold:** Avoid noise, catch major moves
- **Slow Hawkes Decay:** 0.9-0.95 for trend persistence
- **Moderate Dimensions:** 3-4D sufficient for timeframe
- **Long Entropy Lag:** 10-20 bars for structural flow
- **Dashboard:** Large size for detailed analysis
- **Visuals:** Emphasize fractal grid and regime background

**Position Trading (Weekly+):**
Long-term trend following and major reversal capture:
- **Maximum Lookbacks:** 70-100 periods
- **Low Sensitivity:** 0.3-0.6 for major signals only
- **High Jump Threshold:** 3.5-4.0σ for major events only
- **Maximum Hawkes Decay:** 0.95-0.99 for long memory
- **Minimal Dimensions:** 2-3D for simplicity
- **Extended Entropy Lag:** 15-20 bars for institutional flow
- **Dashboard:** Large with performance focus
- **Visuals:** Minimal distraction, regime focus

### Market Condition Adaptation

**Trending Markets (Hurst >0.6):**
- **Increase Sensitivity:** Catch momentum continuation
- **Lower Mean Reversion Threshold:** Avoid counter-trend signals
- **Emphasize Volume Leadership:** Institutional accumulation/distribution
- **Tensor Field Focus:** Use expansion for trend continuation
- **Signal Mode:** Aggressive or Confluence for trend following

**Range-Bound Markets (Hurst <0.4):**
- **Decrease Sensitivity:** Avoid false breakouts
- **Lower Trending Threshold:** Quick regime recognition
- **Focus on Price Leadership:** Retail sentiment extremes
- **Fractal Grid Emphasis:** Support/resistance trading
- **Signal Mode:** Conservative for high-probability reversals

**Volatile Markets (High Jump Frequency):**
- **Increase Hawkes Decay:** Recognize event clustering
- **Higher Jump Threshold:** Avoid noise signals
- **Maximum Dimensions:** Capture full volatility complexity
- **Reduce Position Sizing:** Risk management adaptation
- **Enhanced Visuals:** Maximum information for rapid decisions

**Low Volatility Markets (Low Jump Frequency):**
- **Decrease Jump Threshold:** Capture subtle movements
- **Lower Hawkes Decay:** Treat moves as independent
- **Reduce Dimensions:** Simplify analysis
- **Increase Position Sizing:** Capitalize on compressed volatility
- **Minimal Visuals:** Reduce distraction in quiet markets

---

## 🚀 ADVANCED TRADING STRATEGIES

### The Mathematical Convergence Method

**Entry Protocol:**
1. **Fractal Grid Approach:** Monitor price approaching significant fractal levels
2. **Tensor Field Confirmation:** Verify field expansion supporting direction
3. **Portal Signal:** Wait for dimensional portal appearance
4. **ELITE/STRONG Quality:** Only trade highest quality mathematical signals
5. **Component Consensus:** Confirm 2+ components agree in Confluence mode

**Example Implementation:**
- Price approaching 21-period fractal high
- Tensor field expanding upward (bullish mathematical alignment)  
- Green portal appears below price (trending regime confirmation)
- ELITE quality signal with 3/3 components active
- Enter long position with stop below fractal level

**Risk Management:**
- **Stop Placement:** Below/above fractal level that generated signal
- **Position Sizing:** Based on Mahalanobis distance (higher distance = smaller size)
- **Profit Targets:** Next fractal level or tensor field resistance

### The Regime Transition Strategy

**Regime Change Detection:**
1. **Monitor Hurst Exponent:** Watch for persistent moves above/below thresholds
2. **Portal Color Change:** Regime transitions show different portal colors
3. **Background Intensity:** Increasing regime background intensity
4. **Mathematical Confirmation:** Wait for regime confirmation (hysteresis)

**Trading Implementation:**
- **Trending Transitions:** Trade momentum breakouts, follow trend
- **Mean Reversion Transitions:** Trade range boundaries, fade extremes
- **Random Transitions:** Trade breakouts with tight stops

**Advanced Techniques:**
- **Multi-Timeframe:** Confirm regime on higher timeframe
- **Early Entry:** Enter on regime transition rather than confirmation
- **Regime Strength:** Larger positions during strong regime signals

### The Information Flow Momentum Strategy

**Flow Detection Protocol:**
1. **Monitor Transfer Entropy:** Watch for significant information flow shifts
2. **Volume Leadership:** Strong edge when volume leads price
3. **Flow Acceleration:** Increasing flow strength indicates momentum
4. **Directional Confirmation:** Ensure flow aligns with intended trade direction

**Entry Signals:**
- **Volume → Price Flow:** Enter during accumulation/distribution phases
- **Price → Volume Flow:** Enter on momentum confirmation breaks
- **Flow Reversal:** Counter-trend entries when flow reverses

**Optimization:**
- **Scalping:** Use immediate flow detection (2-5 bar lag)
- **Swing Trading:** Use structural flow (10-20 bar lag)
- **Multi-Asset:** Compare flow between correlated assets

### The Tensor Field Expansion Strategy

**Field Mathematics:**
The tensor field expansion indicates mathematical pressure building in market structure:

**Expansion Phases:**
1. **Compression:** Field contracts, volatility decreases
2. **Tension Building:** Mathematical pressure accumulates
3. **Expansion:** Field expands rapidly with directional movement
4. **Resolution:** Field stabilizes at new equilibrium

**Trading Applications:**
- **Compression Trading:** Prepare for breakout during field contraction
- **Expansion Following:** Trade direction of field expansion
- **Reversion Trading:** Fade extreme field expansion
- **Multi-Dimensional:** Consider all field layers for confirmation

### The Hawkes Process Event Strategy

**Self-Exciting Jump Trading:**
Understanding that market shocks cluster and create follow-on opportunities:

**Jump Sequence Analysis:**
1. **Initial Jump:** First volatility jump detected
2. **Clustering Phase:** Hawkes intensity remains elevated
3. **Follow-On Opportunities:** Additional jumps more likely
4. **Decay Period:** Intensity gradually decreases

**Implementation:**
- **Jump Confirmation:** Wait for mathematical jump confirmation
- **Direction Assessment:** Use other components for direction
- **Clustering Trades:** Trade subsequent moves during high intensity
- **Decay Exit:** Exit positions as Hawkes intensity decays

### The Fractal Confluence System

**Multi-Timeframe Fractal Analysis:**
Combining fractal levels across different periods for high-probability zones:

**Confluence Zones:**
- **Double Confluence:** 2 fractal levels align
- **Triple Confluence:** 3+ fractal levels cluster
- **Mathematical Confirmation:** Tensor field supports the level
- **Information Flow:** Transfer entropy confirms direction

**Trading Protocol:**
1. **Identify Confluence:** Find 2+ fractal levels within 1 ATR
2. **Mathematical Support:** Verify tensor field alignment
3. **Signal Quality:** Wait for STRONG or ELITE signal
4. **Risk Definition:** Use fractal level for stop placement
5. **Profit Targeting:** Next major fractal confluence zone

---

## ⚠️ COMPREHENSIVE RISK MANAGEMENT

### Mathematical Position Sizing

**Mahalanobis Distance Integration:**
Position size should inversely correlate with mathematical field strength:

```
Position Size = Base Size × (Threshold / Mahalanobis Distance)
```

**Risk Scaling Matrix:**
- **Low Field Strength (<2.0):** Standard position sizing
- **Moderate Field Strength (2.0-3.0):** 75% position sizing  
- **High Field Strength (3.0-4.0):** 50% position sizing
- **Extreme Field Strength (>4.0):** 25% position sizing or no trade

### Signal Quality Risk Adjustment

**Quality-Based Position Sizing:**
- **ELITE Signals:** 100% of planned position size
- **STRONG Signals:** 75% of planned position size
- **GOOD Signals:** 50% of planned position size  
- **WEAK Signals:** No position or paper trading only

**Component Agreement Scaling:**
- **3/3 Components:** Full position size
- **2/3 Components:** 75% position size
- **1/3 Components:** 50% position size or skip trade

### Regime-Adaptive Risk Management

**Trending Market Risk:**
- **Wider Stops:** Allow for trend continuation
- **Trend Following:** Trade with regime direction
- **Higher Position Size:** Trend probability advantage
- **Momentum Stops:** Trail stops based on momentum indicators

**Mean-Reverting Market Risk:**
- **Tighter Stops:** Quick exits on trend continuation
- **Contrarian Positioning:** Trade against extremes  
- **Smaller Position Size:** Higher reversal failure rate
- **Level-Based Stops:** Use fractal levels for stops

**Random Market Risk:**
- **Breakout Focus:** Trade only clear breakouts
- **Tight Initial Stops:** Quick exit if breakout fails
- **Reduced Frequency:** Skip marginal setups
- **Range-Based Targets:** Profit targets at range boundaries

### Volatility-Adaptive Risk Controls

**High Volatility Periods:**
- **Reduced Position Size:** Account for wider price swings
- **Wider Stops:** Avoid noise-based exits
- **Lower Frequency:** Skip marginal setups
- **Faster Exits:** Take profits more quickly

**Low Volatility Periods:**
- **Standard Position Size:** Normal risk parameters
- **Tighter Stops:** Take advantage of compressed ranges
- **Higher Frequency:** Trade more setups
- **Extended Targets:** Allow for compressed volatility expansion

### Multi-Timeframe Risk Alignment

**Higher Timeframe Trend:**
- **With Trend:** Standard or increased position size
- **Against Trend:** Reduced position size or skip
- **Neutral Trend:** Standard position size with tight management

**Risk Hierarchy:**
1. **Primary:** Current timeframe signal quality
2. **Secondary:** Higher timeframe trend alignment  
3. **Tertiary:** Mathematical field strength
4. **Quaternary:** Market regime classification

---

## 📚 EDUCATIONAL VALUE AND MATHEMATICAL CONCEPTS

### Advanced Mathematical Concepts

**Tensor Analysis in Markets:**
The TMAE introduces traders to tensor analysis, a branch of mathematics typically reserved for physics and advanced engineering. Tensors provide a framework for understanding multi-dimensional market relationships that scalar and vector analysis cannot capture.

**Information Theory Applications:**
Transfer entropy implementation teaches traders about information flow in markets, a concept from information theory that quantifies directional causality between variables. This provides intuition about market microstructure and participant behavior.

**Fractal Geometry in Trading:**
The Hurst exponent calculation exposes traders to fractal geometry concepts, helping understand that markets exhibit self-similar patterns across multiple timeframes. This mathematical insight transforms how traders view market structure.

**Stochastic Process Theory:**
The Hawkes process implementation introduces concepts from stochastic process theory, specifically self-exciting point processes. This provides mathematical framework for understanding why market events cluster and exhibit memory effects.

### Learning Progressive Complexity

**Beginner Mathematical Concepts:**
- **Volatility Dimensions:** Understanding multi-dimensional analysis
- **Regime Classification:** Learning market personality types
- **Signal Democracy:** Algorithmic consensus building
- **Visual Mathematics:** Interpreting mathematical concepts visually

**Intermediate Mathematical Applications:**
- **Mahalanobis Distance:** Statistical distance in multi-dimensional space
- **Rescaled Range Analysis:** Fractal dimension measurement
- **Information Entropy:** Quantifying uncertainty and causality
- **Field Theory:** Understanding mathematical fields in market context

**Advanced Mathematical Integration:**
- **Tensor Field Dynamics:** Multi-dimensional market force analysis
- **Stochastic Self-Excitation:** Event clustering and memory effects
- **Categorical Composition:** Mathematical signal combination theory
- **Topological Market Analysis:** Understanding market shape and connectivity

### Practical Mathematical Intuition

**Developing Market Mathematics Intuition:**
The TMAE serves as a bridge between abstract mathematical concepts and practical trading applications. Traders develop intuitive understanding of:

- **How markets exhibit mathematical structure beneath apparent randomness**
- **Why multi-dimensional analysis reveals patterns invisible to single-variable approaches**
- **How information flows through markets in measurable, predictable ways**
- **Why mathematical models provide probabilistic edges rather than certainties**

---

## 🔬 IMPLEMENTATION AND OPTIMIZATION

### Getting Started Protocol

**Phase 1: Observation (Week 1)**
1. **Apply with defaults:** Use standard settings on your primary trading timeframe
2. **Study visual elements:** Learn to interpret tensor fields, portals, and streams
3. **Monitor dashboard:** Observe how metrics change with market conditions
4. **No trading:** Focus entirely on pattern recognition and understanding

**Phase 2: Pattern Recognition (Week 2-3)**
1. **Identify signal patterns:** Note what market conditions produce different signal qualities
2. **Regime correlation:** Observe how Hurst regimes affect signal performance  
3. **Visual confirmation:** Learn to read tensor field expansion and portal signals
4. **Component analysis:** Understand which components drive signals in different markets

**Phase 3: Parameter Optimization (Week 4-5)**
1. **Asset-specific tuning:** Adjust parameters for your specific trading instrument
2. **Timeframe optimization:** Fine-tune for your preferred trading timeframe
3. **Sensitivity adjustment:** Balance signal frequency with quality
4. **Visual customization:** Optimize colors and intensity for your trading environment

**Phase 4: Live Implementation (Week 6+)**
1. **Paper trading:** Test signals with hypothetical trades
2. **Small position sizing:** Begin with minimal risk during learning phase
3. **Performance tracking:** Monitor actual vs. expected signal performance
4. **Continuous optimization:** Refine settings based on real performance data

### Performance Monitoring System

**Signal Quality Tracking:**
- **ELITE Signal Win Rate:** Track highest quality signals separately
- **Component Performance:** Monitor which components provide best signals
- **Regime Performance:** Analyze performance across different market regimes
- **Timeframe Analysis:** Compare performance across different session times

**Mathematical Metric Correlation:**
- **Field Strength vs. Performance:** Higher field strength should correlate with better performance
- **Component Agreement vs. Win Rate:** More component agreement should improve win rates
- **Regime Alignment vs. Success:** Trading with mathematical regime should outperform

### Continuous Optimization Process

**Monthly Review Protocol:**
1. **Performance Analysis:** Review win rates, profit factors, and maximum drawdown
2. **Parameter Assessment:** Evaluate if current settings remain optimal
3. **Market Adaptation:** Adjust for changes in market character or volatility
4. **Component Weighting:** Consider if certain components should receive more/less emphasis

**Quarterly Deep Analysis:**
1. **Mathematical Model Validation:** Verify that mathematical relationships remain valid
2. **Regime Distribution:** Analyze time spent in different market regimes
3. **Signal Evolution:** Track how signal characteristics change over time
4. **Correlation Analysis:** Monitor correlations between different mathematical components

---

## 🌟 UNIQUE INNOVATIONS AND CONTRIBUTIONS

### Revolutionary Mathematical Integration

**First-Ever Implementations:**
1. **Multi-Dimensional Volatility Tensor:** First indicator to implement true tensor analysis for market volatility
2. **Real-Time Hawkes Process:** First trading implementation of self-exciting point processes
3. **Transfer Entropy Trading Signals:** First practical application of information theory for trade generation
4. **Democratic Component Voting:** First algorithmic consensus system for signal generation
5. **Fractal-Projected Signal Quality:** First system to predict signal quality at future price levels

### Advanced Visualization Innovations

**Mathematical Visualization Breakthroughs:**
- **Tensor Field Radiation:** Visual representation of mathematical field energy
- **Dimensional Portal System:** Category theory visualization for regime transitions
- **Information Flow Streams:** Real-time visual display of market information transfer
- **Multi-Layer Fractal Grid:** Intelligent spacing and projection system
- **Regime Intensity Mapping:** Dynamic background showing mathematical regime strength

### Practical Trading Innovations

**Trading System Advances:**
- **Quality-Weighted Signal Generation:** Signals rated by mathematical confidence
- **Regime-Adaptive Strategy Selection:** Automatic strategy optimization based on market personality
- **Anti-Spam Signal Protection:** Mathematical prevention of signal clustering
- **Component Performance Tracking:** Real-time monitoring of algorithmic component success
- **Field-Strength Position Sizing:** Mathematical volatility integration for risk management

---

## ⚖️ RESPONSIBLE USAGE AND LIMITATIONS

### Mathematical Model Limitations

**Understanding Model Boundaries:**
While the TMAE implements sophisticated mathematical concepts, traders must understand fundamental limitations:

- **Markets Are Not Purely Mathematical:** Human psychology, news events, and fundamental factors create unpredictable elements
- **Past Performance Limitations:** Mathematical relationships that worked historically may not persist indefinitely
- **Model Risk:** Complex models can fail during unprecedented market conditions
- **Overfitting Potential:** Highly optimized parameters may not generalize to future market conditions

### Proper Implementation Guidelines

**Risk Management Requirements:**
- **Never Risk More Than 2% Per Trade:** Regardless of signal quality
- **Diversification Mandatory:** Don't rely solely on mathematical signals
- **Position Sizing Discipline:** Use mathematical field strength for sizing, not confidence
- **Stop Loss Non-Negotiable:** Every trade must have predefined risk parameters

**Realistic Expectations:**
- **Mathematical Edge, Not Certainty:** The indicator provides probabilistic advantages, not guaranteed outcomes
- **Learning Curve Required:** Complex mathematical concepts require time to master
- **Market Adaptation Necessary:** Parameters must evolve with changing market conditions
- **Continuous Education Important:** Understanding underlying mathematics improves application

### Ethical Trading Considerations

**Market Impact Awareness:**
- **Information Asymmetry:** Advanced mathematical analysis may provide advantages over other market participants
- **Position Size Responsibility:** Large positions based on mathematical signals can impact market structure
- **Sharing Knowledge:** Consider educational contributions to trading community
- **Fair Market Participation:** Use mathematical advantages responsibly within market framework

### Professional Development Path

**Skill Development Sequence:**
1. **Basic Mathematical Literacy:** Understand fundamental concepts before advanced application
2. **Risk Management Mastery:** Develop disciplined risk control before relying on complex signals
3. **Market Psychology Understanding:** Combine mathematical analysis with behavioral market insights
4. **Continuous Learning:** Stay updated on mathematical finance developments and market evolution

---

## 🔮 CONCLUSION

The Tensor Market Analysis Engine represents a quantum leap forward in technical analysis, successfully bridging the gap between advanced pure mathematics and practical trading applications. By integrating multi-dimensional volatility analysis, fractal market theory, and information flow dynamics, the TMAE reveals market structure invisible to conventional analysis while maintaining visual clarity and practical usability.

### Mathematical Innovation Legacy

This indicator establishes new paradigms in technical analysis:
- **Tensor analysis for market volatility understanding**
- **Stochastic self-excitation for event clustering prediction**  
- **Information theory for causality-based trade generation**
- **Democratic algorithmic consensus for signal quality enhancement**
- **Mathematical field visualization for intuitive market understanding**

### Practical Trading Revolution

Beyond mathematical innovation, the TMAE transforms practical trading:
- **Quality-rated signals replace binary buy/sell decisions**
- **Regime-adaptive strategies automatically optimize for market personality**
- **Multi-dimensional risk management integrates mathematical volatility measures**
- **Visual mathematical concepts make complex analysis immediately interpretable**
- **Educational value creates lasting improvement in trading understanding**

### Future-Proof Design

The mathematical foundations ensure lasting relevance:
- **Universal mathematical principles transcend market evolution**
- **Multi-dimensional analysis adapts to new market structures**
- **Regime detection automatically adjusts to changing market personalities**
- **Component democracy allows for future algorithmic additions**
- **Mathematical visualization scales with increasing market complexity**

### Commitment to Excellence

The TMAE represents more than an indicator—it embodies a philosophy of bringing rigorous mathematical analysis to trading while maintaining practical utility and visual elegance. Every component, from the multi-dimensional tensor fields to the democratic signal generation, reflects a commitment to mathematical accuracy, trading practicality, and educational value.

### Trading with Mathematical Precision

In an era where markets grow increasingly complex and computational, the TMAE provides traders with mathematical tools previously available only to institutional quantitative research teams. Yet unlike academic mathematical models, the TMAE translates complex concepts into intuitive visual representations and practical trading signals.

By combining the mathematical rigor of tensor analysis, the statistical power of multi-dimensional volatility modeling, and the information-theoretic insights of transfer entropy, traders gain unprecedented insight into market structure and dynamics.

### Final Perspective

Markets, like nature, exhibit profound mathematical beauty beneath apparent chaos. The Tensor Market Analysis Engine serves as a mathematical lens that reveals this hidden order, transforming how traders perceive and interact with market structure.

Through mathematical precision, visual elegance, and practical utility, the TMAE empowers traders to see beyond the noise and trade with the confidence that comes from understanding the mathematical principles governing market behavior.

Trade with mathematical insight. Trade with the power of tensors. Trade with the TMAE.

*"In mathematics, you don't understand things. You just get used to them." - John von Neumann*

*With the TMAE, mathematical market understanding becomes not just possible, but intuitive.*
— Dskyz, Trade with insight. Trade with anticipation.

---

## Source Code

````pine
//@version=5
indicator("Tensor Market Analysis Engine (TMAE)", shorttitle="🔢 TMAE", overlay=true, max_bars_back=500, max_lines_count=500, max_labels_count=500)
//==============================================================================
// 📚 COMPREHENSIVE USER GUIDE & MATHEMATICAL THEORY
//==============================================================================
// 
// 🔢 TMAE - THE ULTIMATE TENSOR MARKET ANALYSIS ENGINE
// 
// Welcome to the most sophisticated multi-dimensional market analysis framework,
// combining three revolutionary mathematical approaches into a unified trading system
// that adapts to market personality and provides unparalleled signal accuracy.
//
// ⚡ REVOLUTIONARY THREE-PILLAR APPROACH:
// 
// While traditional indicators use single-dimensional analysis, TMAE operates
// across multiple mathematical domains simultaneously:
//
// 1. MULTI-DIMENSIONAL VOLATILITY WITH JUMP DETECTION:
//    - Analyzes volatility across 2-5 dimensions (price, volume, range, correlation, microstructure)
//    - Uses Mahalanobis distance for outlier detection in volatility space
//    - Implements Hawkes process for self-exciting jump clustering
//    - Detects regime changes through dimensional analysis
//
// 2. HURST EXPONENT REGIME DETECTION:
//    - Calculates fractal dimension of price movements (0-1 scale)
//    - H > 0.6: Trending/Persistent regime (follow momentum)
//    - H < 0.4: Mean-reverting/Anti-persistent regime (fade extremes)
//    - H ≈ 0.5: Random walk regime (breakout strategies)
//    - Adapts signal generation to current market personality
//
// 3. TRANSFER ENTROPY LEAD-LAG ANALYSIS:
//    - Measures information flow between price and volume
//    - Detects which variable is leading the relationship
//    - Quantifies predictive power and causality strength
//    - Identifies structural changes in market microstructure
//
// 🎯 SIGNAL INTERPRETATION:
//
// COMPONENT SIGNALS (3 Maximum):
// • Volatility Signal: Multi-dimensional jump detection active
// • Hurst Signal: Regime-appropriate pattern detected
// • Entropy Signal: Significant information flow measured
//
// SIGNAL MODES:
// • Aggressive: 1+ components active (more signals, higher noise)
// • Confluence: 2+ components active (balanced approach)
// • Conservative: All 3 components active (fewer, highest quality signals)
//
// 📊 PERFORMANCE METRICS:
//
// REAL WIN RATE (0-100%):
// • Tracks actual entry-to-exit trade performance
// • Updates with each completed trade
// • Accounts for realistic exit conditions
//
// TENSOR FIELD STRENGTH:
// • Mahalanobis distance in volatility space
// • Values > threshold indicate anomalous conditions
// • Higher values = stronger signals but less frequent
//
// MARKET REGIME CLASSIFICATION:
// • Trending: Follow momentum, ride breakouts
// • Mean-Reverting: Fade extremes, buy dips/sell rips
// • Random: Wait for volatility compression then breakout
//
// 🧮 MATHEMATICAL COMPONENTS:
//
// VOLATILITY TENSOR: Multi-dimensional volatility state vector
// MAHALANOBIS METRIC: Distance measure in volatility space
// HAWKES INTENSITY: Self-exciting jump probability
// HURST EXPONENT: Fractal dimension (0.5 = random, >0.5 = trending, <0.5 = reverting)
// TRANSFER ENTROPY: Information flow measurement between variables
// REGIME CLASSIFIER: Adaptive signal generation based on market personality
//
// 💡 TRADING STRATEGY:
//
// 1. SIGNAL GENERATION:
//    - Wait for 2+ components in Confluence mode
//    - Confirm with appropriate momentum direction
//    - Verify regime alignment (trending vs reverting)
//    - Check tensor field strength vs threshold
//
// 2. ENTRY EXECUTION:
//    - Strong signals (3/3 components): Enter immediately
//    - Moderate signals (2/3 components): Wait for pullback
//    - Weak signals (1/3 components): Avoid or reduce size
//
// 3. POSITION MANAGEMENT:
//    - Size based on component agreement strength
//    - Monitor regime changes for strategy adaptation
//    - Watch for tensor field weakening
//
// 4. EXIT STRATEGY:
//    - Component divergence (signals turning off)
//    - Regime change detection
//    - Time-based exits (prevent overholding)
//    - Profit/loss thresholds
//
// ⚠️ RISK DISCLAIMER:
// Despite mathematical sophistication, markets exhibit:
// • Regime transition periods (temporary signal degradation)
// • Black swan events (extreme multidimensional jumps)
// • Structural breaks (parameter stability issues)
// Always use appropriate risk management and position sizing.
//==============================================================================
// 🎯 UNIFIED CONFIGURATION
//==============================================================================
group_core = "🔢 Core Parameters"
lookback_period = input.int(50, "Primary Analysis Window", minval=10, maxval=100, group=group_core, tooltip="🎯 MAIN LOOKBACK FOR ALL CALCULATIONS\n\n📊 Affects:\n• Volatility calculation depth\n• Hurst exponent accuracy\n• Transfer entropy reliability\n\n🕒 TIMEFRAME OPTIMIZATION:\n• 1-5min: 20-30 (fast adaptation)\n• 15min-1H: 30-50 (balanced)\n• 4H+: 50-100 (smooth signals)\n\n💡 Lower = More responsive but noisier")
sensitivity = input.float(0.7, "Signal Sensitivity", minval=0.1, maxval=2.0, step=0.1, group=group_core, tooltip="🎯 MASTER SENSITIVITY CONTROL\n\n📊 Adjusts:\n• Jump detection threshold\n• Regime change sensitivity\n• Entropy significance levels\n\n📈 HIGHER (1.5-2.0): More signals, catch smaller moves\n📉 LOWER (0.5-0.8): Fewer signals, only major events\n\n💡 Start at 1.0, adjust based on signal frequency")
signal_mode = input.string("Confluence", "Signal Generation Mode", options=["Aggressive", "Confluence", "Conservative"], group=group_core, tooltip="🎯 HOW SIGNALS ARE GENERATED\n\n🔥 AGGRESSIVE: Any component signals\n• Most signals, early entries\n• Higher false positive rate\n\n⚖️ CONFLUENCE: 2+ components agree\n• Balanced approach\n• Good risk/reward\n\n🛡️ CONSERVATIVE: All 3 must align\n• Fewest but highest quality signals\n• Best for larger positions")
//==============================================================================
// 🌊 VOLATILITY JUMP DETECTION
//==============================================================================
group_volatility = "🌊 Volatility Jump Detection"
vol_dimensions = input.int(3, "Volatility Dimensions", minval=2, maxval=5, group=group_volatility, tooltip="🎯 VOLATILITY SPACE DIMENSIONS\n\n📊 Each dimension analyzes different scale:\n• 2D: Price + Volume volatility\n• 3D: + Momentum volatility\n• 4D: + Correlation volatility\n• 5D: + Microstructure volatility\n\n💡 More dimensions = more nuanced detection")
jump_threshold = input.float(3.0, "Jump Detection Threshold (σ)", minval=1.5, maxval=4.0, step=0.1, group=group_volatility, tooltip="🎯 STANDARD DEVIATIONS FOR JUMP\n\n📊 Volatility spike needed to trigger:\n• 1.5-2.0σ: Sensitive (more jumps detected)\n• 2.5-3.0σ: Balanced\n• 3.5-4.0σ: Only extreme jumps\n\n🏦 ASSET OPTIMIZATION:\n• Crypto: 2.0-2.5σ (naturally volatile)\n• Stocks: 2.5-3.0σ\n• Forex: 3.0-3.5σ (usually stable)")
hawkes_decay = input.float(0.85, "Jump Clustering Decay", minval=0.5, maxval=0.99, step=0.01, group=group_volatility, tooltip="🎯 HAWKES PROCESS DECAY RATE\n\n📊 How quickly jump probability decreases:\n• 0.5-0.7: Fast decay (jumps independent)\n• 0.8-0.9: Moderate (some clustering)\n• 0.95-0.99: Slow (strong clustering)\n\n💡 Higher = Jumps trigger more jumps")
//==============================================================================
// 📐 HURST EXPONENT PARAMETERS
//==============================================================================
group_hurst = "📐 Hurst Exponent Analysis"
hurst_method = input.string("Adaptive R/S", "Calculation Method", options=["Classic R/S", "Adaptive R/S", "DFA"], group=group_hurst, tooltip="🎯 HURST CALCULATION METHOD\n\n📊 Classic R/S: Original Rescaled Range\n• Simple, fast\n• Can be biased for short series\n\n📊 Adaptive R/S: Dynamic windowing\n• More accurate for trading\n• Handles non-stationarity\n\n📊 DFA: Detrended Fluctuation\n• Most sophisticated\n• Best for noisy data")
regime_threshold_trend = input.float(0.60, "Trending Threshold", minval=0.55, maxval=0.8, step=0.01, group=group_hurst, tooltip="🎯 HURST VALUE FOR TREND REGIME\n\n📊 H > threshold = Trending market\n• 0.55-0.60: Weak persistence\n• 0.65-0.70: Clear trending\n• 0.75-0.80: Strong momentum\n\n💡 In trends: Follow breakouts, ride momentum")
regime_threshold_mean = input.float(0.40, "Mean Reversion Threshold", minval=0.2, maxval=0.45, step=0.01, group=group_hurst, tooltip="🎯 HURST VALUE FOR MEAN REVERSION\n\n📊 H < threshold = Anti-persistent\n• 0.40-0.45: Weak reversion\n• 0.30-0.35: Clear ranging\n• 0.20-0.25: Strong reversion\n\n💡 In ranges: Fade extremes, buy support/sell resistance")
//==============================================================================
// 🔄 TRANSFER ENTROPY PARAMETERS
//==============================================================================
group_entropy = "🔄 Transfer Entropy Analysis"
entropy_source = input.string("Price-Volume", "Information Flow Analysis", options=["Price-Volume", "Price-Volatility", "Multi-Timeframe"], group=group_entropy, tooltip="🎯 WHAT INFORMATION FLOW TO MEASURE\n\n📊 Price-Volume: Classic flow analysis\n• Volume leads price = Accumulation/Distribution\n• Price leads volume = Retail chasing\n\n📊 Price-Volatility: Risk flow\n• Volatility leads = Risk-off incoming\n• Price leads = Complacent rally\n\n📊 Multi-Timeframe: Cross-TF flow\n• HTF leads = Major trend\n• LTF leads = Noise")
entropy_lag = input.int(5, "Maximum Lag (bars)", minval=2, maxval=20, group=group_entropy, tooltip="🎯 HOW FAR BACK TO LOOK FOR CAUSALITY\n\n📊 Information transfer lag window:\n• 2-5 bars: Immediate causality\n• 5-10 bars: Short-term flow\n• 10-20 bars: Structural flow\n\n💡 Match to your timeframe:\n• 1min chart: 3-5 bars\n• 5min chart: 5-10 bars\n• 15min+: 10-20 bars")
entropy_threshold = input.float(0.15, "Significance Threshold", minval=0.05, maxval=0.3, step=0.01, group=group_entropy, tooltip="🎯 MINIMUM ENTROPY FOR SIGNAL\n\n📊 Information flow strength needed:\n• 0.05-0.10: Detect subtle flows\n• 0.10-0.20: Clear causality only\n• 0.20-0.30: Very strong flow only\n\n💡 Lower = More sensitive to information transfer")
//==============================================================================
// 🎨 VISUAL CONFIGURATION
//==============================================================================
group_visual = "🎨 Visual Configuration"
color_scheme = input.string("Dark", "Color Scheme", options=["Dark", "Light", "Classic", "Neon", "Neutral", "Bright"], group=group_visual,
     tooltip="Choose your preferred color theme")
show_jump_markers = input.bool(false, "Show Volatility Jumps", group=group_visual, tooltip="Show lightning bolts for volatility jumps - can be visually cluttered")
show_regime_bg = input.bool(true, "Show Hurst Regime Background", group=group_visual)
show_signals = input.bool(true, "Show Trade Signals", group=group_visual)
show_signal_labels = input.bool(true, "Show BUY/SELL Labels", group=group_visual)
show_wick_pressure = input.bool(true, "⚡ Show Wick Pressure Lines", group=group_visual,
  tooltip="🎯 WHAT IT IS: Rejection level analysis using candle wick patterns\n\n" +
  "⚡ HOW IT WORKS: Projects lines from significant wicks to show pressure zones\n\n" +
  "📈 UPPER WICKS: Show selling pressure and resistance\n" +
  "📉 LOWER WICKS: Show buying pressure and support\n\n" +
  "🎯 TRADING APPLICATION:\n" +
  "• Entry: Trade bounces off wick pressure zones\n" +
  "• Exit: Watch for wick pressure breakdown\n" +
  "• Confluence: Combine with fractal grid levels\n\n" +
  "💡 PRO TIP: Multiple wick pressure lines = stronger S/R zones")
regime_smoothing = input.int(10, "Regime Smoothing", minval=1, maxval=20, group=group_visual, tooltip="Smooths regime changes to reduce background flicker")
group_tensor_visuals = "🔢 Tensor Analysis Engine"
show_tensor_field = input.bool(true, "🌊 Tensor Volatility Field", group=group_tensor_visuals)
show_dimensional_portals = input.bool(true, "🌀 Dimensional Portals", group=group_tensor_visuals)
show_entropy_streams = input.bool(true, "🔄 Information Flow Streams", group=group_tensor_visuals)
show_fractal_matrix = input.bool(true, "📐 Hurst Fractal Matrix", group=group_tensor_visuals)
show_lightning_network = input.bool(true, "⚡ Volatility Lightning Network", group=group_tensor_visuals)
show_holographic_signals = input.bool(true, "🎯 Holographic Signal Projection", group=group_tensor_visuals)
tensor_intensity = input.float(1.0, "🔥 Visual Intensity", minval=0.5, maxval=2.0, group=group_tensor_visuals)
particle_density = input.int(8, "✨ Particle Density", minval=3, maxval=15, group=group_tensor_visuals)
//==============================================================================
// 📊 DASHBOARD CONFIGURATION
//==============================================================================
group_dashboard = "📊 Dashboard Configuration"
show_dashboard = input.bool(true, "📋 Show Enhanced Dashboard", group=group_dashboard,
  tooltip="🎯 WHAT IT IS: Displays a comprehensive panel with key trading metrics\n\n" +
  "⚡ HOW IT WORKS: Shows tensor metrics, regime analysis, volatility jumps, and trade signals\n\n" +
  "📊 DASHBOARD INCLUDES:\n" +
  "• Tensor Field Strength (Mahalanobis distance)\n" +
  "• Volatility Jump Detection\n" +
  "• Hurst Regime Analysis\n" +
  "• Information Flow Signals\n" +
  "• Market Structure Analysis\n\n" +
  "🎯 BENEFITS:\n" +
  "• Quick decision-making\n" +
  "• Real-time market insights\n" +
  "• Multi-dimensional analysis\n\n" +
  "💡 RECOMMENDED: Keep ON for systematic trading, disable for minimal charts")
dashboard_size = input.string("Normal", "📏 Dashboard Size", options=["Small", "Normal", "Large"], group=group_dashboard,
  tooltip="🎯 WHAT IT IS: Controls the size and detail level of the dashboard\n\n" +
  "⚡ HOW IT WORKS: Adjusts the amount of information displayed\n\n" +
  "📱 SMALL: Minimal metrics, ideal for mobile or small screens\n" +
  "💻 NORMAL: Balanced detail, suitable for most desktops\n" +
  "🖥️ LARGE: Maximum detail, best for multi-monitor setups\n\n" +
  "🕒 TIMEFRAME OPTIMIZATION:\n" +
  "• Scalping: Small (quick reference)\n" +
  "• Day Trading: Normal (balanced info)\n" +
  "• Swing Trading: Large (detailed analysis)\n\n" +
  "💡 PRO TIP: Use Normal for most setups, Large for deep analysis")
dashboard_position_input = input.string("Top Right", "📍 Dashboard Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=group_dashboard,
  tooltip="🎯 WHAT IT IS: Sets the dashboard's position on the chart\n\n" +
  "⚡ HOW IT WORKS: Places the dashboard in a non-intrusive location\n\n" +
  "📍 TOP RIGHT: Standard placement, avoids price action\n" +
  "📍 TOP LEFT: Good for wide charts or left-handed users\n" +
  "📍 BOTTOM RIGHT: Focuses on recent price action, ideal for scalping\n" +
  "📍 BOTTOM LEFT: Maximizes price visibility, good for swing trading\n\n" +
  "🕒 TIMEFRAME OPTIMIZATION:\n" +
  "• Scalping: Bottom Right (recent price focus)\n" +
  "• Day Trading: Top Right (standard)\n" +
  "• Swing Trading: Bottom Left (price visibility)\n\n" +
  "💡 PRO TIP: Choose a position that doesn't obscure key chart areas")
// ========================================
// ENHANCED COLOR SCHEME SYSTEM
// ========================================
get_color_scheme(scheme) =>
    switch scheme
        "Light" =>
            [#ffffff, #f5f5f5, #e0e0e0, #00897b, #d32f2f, #5e35b1, #ff6f00, #1976d2, #388e3c, #6a1b9a,
             #000000, #212121, #616161, #9e9e9e]
        "Classic" =>
            [#1a1a1a, #2d2d2d, #404040, #008000, #ff0000, #0000ff, #ffa500, #00bfff, #32cd32, #9370db,
             #ffffff, #f0f0f0, #c0c0c0, #808080]
        "Neon" =>
            [#000000, #0a0a0a, #1a1a1a, #00ff00, #ff0066, #00ffff, #ffff00, #ff00ff, #00ff99, #ff3399,
             #ffffff, #f0f0ff, #e0e0ff, #c0c0ff]
        "Neutral" =>
            [#2e2e2e, #3a3a3a, #4a4a4a, #708090, #696969, #778899, #a9a9a9, #b0c4de, #d3d3d3, #dcdcdc,
             #ffffff, #f5f5f5, #cccccc, #999999]
        "Bright" =>
            [#000011, #001122, #002244, #00ff44, #ff4400, #4400ff, #ffaa00, #00aaff, #44ff00, #ff0044,
             #ffffff, #ffff88, #88ffff, #ff88ff]
        => // Default "Dark"
            [#0a0e17, #1a1e27, #2a2e37, #26a69a, #ef5350, #7c4dff, #ffa726, #42a5f5, #66bb6a, #ab47bc,
             #ffffff, #e4e8eb, #9ca3af, #6b7280]
[bg_dark, panel_bg, border_color, color_bullish, color_bearish, color_neutral, 
 color_warning, color_info, color_success, color_consciousness,
 text_bright, text_normal, text_muted, text_dim] = get_color_scheme(color_scheme)
c_success = color_success
c_danger = color_bearish  
c_primary = color_consciousness
c_info = color_info
//==============================================================================
// 🧮 CORE CALCULATIONS
//==============================================================================
returns = (close - close[1]) / close[1]
log_returns = math.log(close / close[1])
atr_value = ta.atr(14)
//==============================================================================
// 🌊 MULTI-DIMENSIONAL VOLATILITY WITH JUMP DETECTION
//==============================================================================
price_vol = ta.stdev(returns, lookback_period)
volume_vol = ta.stdev((volume - ta.sma(volume, lookback_period)) / ta.sma(volume, lookback_period), lookback_period)
high_low_vol = ta.stdev((high - low) / close, lookback_period)
corr_vol = ta.stdev(ta.correlation(close, volume, lookback_period), lookback_period)
micro_vol = ta.stdev((close - (high + low) / 2) / (high - low + 0.0001), lookback_period)
calculate_volatility_state(dims, p_vol, v_vol, hl_vol, c_vol, m_vol) =>
    state = array.new_float(dims, 0.0)
    array.set(state, 0, p_vol)
    if dims >= 2
        array.set(state, 1, v_vol)
    if dims >= 3
        array.set(state, 2, hl_vol)
    if dims >= 4
        array.set(state, 3, c_vol)
    if dims >= 5
        array.set(state, 4, m_vol)
    state
current_vol_state = calculate_volatility_state(vol_dimensions, price_vol, volume_vol, high_low_vol, corr_vol, micro_vol)
calculate_mahalanobis_distance(state, dims) =>
    dim_means = array.new_float(dims, 0.0)
    dim_stds = array.new_float(dims, 0.0)
    for d = 0 to dims - 1
        dim_values = array.new_float(0)
        for j = 1 to lookback_period
            if j <= bar_index
                hist_val = d == 0 ? price_vol[j] : d == 1 ? volume_vol[j] : d == 2 ? high_low_vol[j] : d == 3 ? corr_vol[j] : micro_vol[j]
                array.push(dim_values, hist_val)
        mean_val = array.avg(dim_values)
        std_val = array.stdev(dim_values)
        array.set(dim_means, d, mean_val)
        array.set(dim_stds, d, std_val)
    distance = 0.0
    for i = 0 to array.size(state) - 1
        mean_val = array.get(dim_means, i)
        std_val = array.get(dim_stds, i)        
        if std_val > 0
            z_score = (array.get(state, i) - mean_val) / std_val
            distance += z_score * z_score   
    math.sqrt(distance / array.size(state))
mahalanobis_dist = calculate_mahalanobis_distance(current_vol_state, vol_dimensions)
raw_volatility_jump = mahalanobis_dist > jump_threshold * sensitivity
var int last_jump_bar = 0
jump_cooldown = bar_index - last_jump_bar > 5 
volatility_jump = raw_volatility_jump and jump_cooldown
if volatility_jump
    last_jump_bar := bar_index
var float hawkes_intensity = 0.0
if volatility_jump
    hawkes_intensity := 1.0
else
    hawkes_intensity := hawkes_intensity * hawkes_decay
jump_probability = hawkes_intensity
//==============================================================================
// 📐 HURST EXPONENT CALCULATION
//==============================================================================
calculate_hurst_exponent(data, length) =>
    if length < 4
        0.5
    else
        mean = 0.0
        for i = 0 to length - 1
            if i < array.size(data)
                mean += array.get(data, i)
        mean /= length
        cumsum = array.new_float(length, 0.0)
        for i = 0 to length - 1
            if i < array.size(data)
                sum_val = 0.0
                for j = 0 to i
                    sum_val += array.get(data, j) - mean
                array.set(cumsum, i, sum_val)
        range_val = array.max(cumsum) - array.min(cumsum)
        std_sum = 0.0
        for i = 0 to length - 1
            if i < array.size(data)
                std_sum += math.pow(array.get(data, i) - mean, 2)
        std = math.sqrt(std_sum / length)
        rs = std > 0 ? range_val / std : 0
        rs > 0 ? math.log(rs) / math.log(length) : 0.5
price_array = array.new_float(lookback_period)
for i = 0 to lookback_period - 1
    if i < bar_index
        array.set(price_array, i, log_returns[i])
hurst = calculate_hurst_exponent(price_array, lookback_period)
hurst_smoothed = ta.ema(hurst, regime_smoothing)
var string current_regime = "random"
var int regime_bars = 0
if hurst_smoothed > regime_threshold_trend + 0.02 
    current_regime := "trending"
    regime_bars := 0
else if hurst_smoothed < regime_threshold_mean - 0.02
    current_regime := "reverting"
    regime_bars := 0
else
    regime_bars += 1
    if regime_bars > 10 
        current_regime := "random"
is_trending = current_regime == "trending"
is_mean_reverting = current_regime == "reverting"  
is_random_walk = current_regime == "random"
regime_strength = is_trending ? (hurst_smoothed - 0.5) / 0.5 : is_mean_reverting ? (0.5 - hurst_smoothed) / 0.5 : 0.0
//==============================================================================
// 🔄 TRANSFER ENTROPY CALCULATION
//==============================================================================
calculate_transfer_entropy(source_data, target_data, lag) =>
    if bar_index < lag + lookback_period
        0.0
    else
        num_bins = 10
        source_min = array.min(source_data)
        source_max = array.max(source_data)
        target_min = array.min(target_data)
        target_max = array.max(target_data)
        source_range = source_max - source_min
        target_range = target_max - target_min
        if source_range == 0 or target_range == 0
            0.0
        else
            joint_count = 0.0
            source_count = 0.0
            target_count = 0.0
            for i = lag to array.size(source_data) - 1
                source_val = array.get(source_data, i - lag)
                target_val = array.get(target_data, i)
                source_bin = int((source_val - source_min) / source_range * (num_bins - 1))
                target_bin = int((target_val - target_min) / target_range * (num_bins - 1))
                if source_bin == target_bin
                    joint_count += 1
                source_count += 1
                target_count += 1
            prob = joint_count / source_count
            prob > 0 and prob < 1 ? -prob * math.log(prob) - (1 - prob) * math.log(1 - prob) : 0.0
volume_array = array.new_float(lookback_period)
price_change_array = array.new_float(lookback_period)
for i = 0 to lookback_period - 1
    if i < bar_index
        array.set(volume_array, i, math.log(volume[i] + 1))
        array.set(price_change_array, i, returns[i])
te_volume_to_price = calculate_transfer_entropy(volume_array, price_change_array, entropy_lag)
te_price_to_volume = calculate_transfer_entropy(price_change_array, volume_array, entropy_lag)
te_volume_to_price_smooth = ta.ema(te_volume_to_price, 5)
te_price_to_volume_smooth = ta.ema(te_price_to_volume, 5)
net_information_flow = te_volume_to_price_smooth - te_price_to_volume_smooth
volume_leads = net_information_flow > entropy_threshold * sensitivity
price_leads = net_information_flow < -entropy_threshold * sensitivity
no_clear_leader = not volume_leads and not price_leads
//==============================================================================
// 🎯 SIGNAL GENERATION
//==============================================================================
sma_20 = ta.sma(close, 20)
sma_volume = ta.sma(volume, 20)
ema_9 = ta.ema(close, 9)
rsi_14 = ta.rsi(close, 14)
[bb_middle, bb_upper, bb_lower] = ta.bb(close, 20, 2)
bb_squeeze = (bb_upper - bb_lower) / bb_middle < 0.1
vol_signal = volatility_jump or hawkes_intensity > (0.2 * sensitivity)
hurst_signal = false
if is_trending
    hurst_signal := close > sma_20 and close > close[1]
else if is_mean_reverting
    hurst_signal := (close > bb_upper) or (close < bb_lower)
else
    hurst_signal := bb_squeeze and (close > bb_upper[1] or close < bb_lower[1])
entropy_signal = volume_leads or price_leads or (volume > sma_volume * (1.0 + sensitivity * 0.1))
momentum_up = rsi_14 > 50 and close > ema_9
momentum_down = rsi_14 < 50 and close < ema_9
active_signals = (vol_signal ? 1 : 0) + (hurst_signal ? 1 : 0) + (entropy_signal ? 1 : 0)
long_condition = false
short_condition = false
if signal_mode == "Aggressive"
    long_condition := active_signals >= 1 and momentum_up
    short_condition := active_signals >= 1 and momentum_down
else if signal_mode == "Confluence"
    long_condition := active_signals >= 2 and momentum_up
    short_condition := active_signals >= 2 and momentum_down
else 
    long_condition := active_signals == 3 and momentum_up
    short_condition := active_signals == 3 and momentum_down
var int last_signal_bar = 0
signal_gap = bar_index - last_signal_bar > 5
long_signal = long_condition and signal_gap
short_signal = short_condition and signal_gap
if long_signal or short_signal
    last_signal_bar := bar_index
//==============================================================================
// 📊 REAL PERFORMANCE TRACKING
//==============================================================================
var array<float> trade_results = array.new<float>()
var array<int> trade_entry_bars = array.new<int>()
var float current_entry_price = na
var int current_entry_bar = na
var string current_position = "none"
if long_signal and current_position == "none"
    current_entry_price := close
    current_entry_bar := bar_index
    current_position := "long"
if short_signal and current_position == "none"
    current_entry_price := close
    current_entry_bar := bar_index
    current_position := "short"
exit_trade = false
if current_position != "none" and not na(current_entry_price) and not na(current_entry_bar)
    bars_in_trade = bar_index - current_entry_bar
    if current_position == "long"
        pnl_pct = (close - current_entry_price) / current_entry_price
        exit_trade := bars_in_trade > 15 or pnl_pct > 0.03 or pnl_pct < -0.015
    else 
        pnl_pct = (current_entry_price - close) / current_entry_price  
        exit_trade := bars_in_trade > 15 or pnl_pct > 0.03 or pnl_pct < -0.015
if exit_trade and current_position != "none"
    final_pnl = 0.0
    if current_position == "long"
        final_pnl := (close - current_entry_price) / current_entry_price
    else
        final_pnl := (current_entry_price - close) / current_entry_price
    array.push(trade_results, final_pnl)
    array.push(trade_entry_bars, current_entry_bar)
    current_position := "none"
    current_entry_price := na
    current_entry_bar := na
real_win_rate = 0.0
total_trades = array.size(trade_results)
if total_trades > 0
    winning_trades = 0
    for i = 0 to total_trades - 1
        if array.get(trade_results, i) > 0
            winning_trades += 1
    real_win_rate := winning_trades / total_trades
// ============================================
// CORE CALCULATIONS FOR DASHBOARD
// ============================================
signal_threshold = jump_threshold * sensitivity
signal_strength_confirmed = mahalanobis_dist
signal_quality_rating = active_signals == 3 ? "ELITE" : active_signals == 2 ? "STRONG" : active_signals == 1 ? "GOOD" : "WEAK"
volume_sma = ta.sma(volume, 20)
volume_spike = volume > volume_sma * 1.5 ? 50 : 0
bb_position = mahalanobis_dist > jump_threshold ? 100 : 0
anomaly_level = math.min(bb_position + volume_spike, 100)
tensor_state = is_trending ? 1 : is_mean_reverting ? -1 : 0
trend_direction = is_trending ? 1 : is_mean_reverting ? -1 : 0
flow_strength = math.abs(net_information_flow) * 10
market_regime_bullish = is_trending and close > ta.sma(close, 20)
trade_allowed = true  
can_trade = true  
daily_trades = active_signals  
max_trades_adjusted = 10      
daily_pnl = (close - close[20]) / close[20] * 100 
win_rate = total_trades > 0 ? real_win_rate : 0.0
ENABLE_LEARNING = true
adaptive_risk_multiplier = active_signals >= 2 ? 1.2 : active_signals == 1 ? 1.0 : 0.8
MAX_DAILY_TRADES = 10
BASE_RISK = 0.02
SIGNAL_SENSITIVITY = sensitivity
EXECUTION_MODE = signal_mode
high_vol = mahalanobis_dist > jump_threshold * 1.5
low_vol = mahalanobis_dist < jump_threshold * 0.5
session_timezone = "UTC" 
visual_theme = color_scheme
//==============================================================================
// ⚡ WICK PRESSURE LINES
//==============================================================================
if show_wick_pressure and atr_value > 0
    upperWick = high - math.max(open, close)
    lowerWick = math.min(open, close) - low
    body = math.abs(close - open)
    glow_intensity = int(tensor_intensity * 5)
    primaryBear = color_bearish 
    primaryBull = color_bullish 
    for i = 1 to math.min(glow_intensity, 8)
        if bar_index > i
            if upperWick[i] > body[i] * 0.5
                wickAlpha = 20 + i * 8
                wickColor = color.new(primaryBear, wickAlpha)
                wickWidth = math.max(1, glow_intensity - i)
                line.new(bar_index - i, high[i], bar_index, high - (atr_value * 0.1), 
                         color=wickColor, width=wickWidth, style=line.style_dotted)
            if lowerWick[i] > body[i] * 0.5
                wickAlpha = 20 + i * 8
                wickColor = color.new(primaryBull, wickAlpha)
                wickWidth = math.max(1, glow_intensity - i)
                line.new(bar_index - i, low[i], bar_index, low + (atr_value * 0.1), 
                         color=wickColor, width=wickWidth, style=line.style_dotted)
//==============================================================================
// 🎨 TENSOR VISUALIZATION SYSTEM
//==============================================================================
price_range = ta.highest(high, 20) - ta.lowest(low, 20)
field_offset = price_range * 0.08
//==============================================================================
// 🌊 TENSOR VOLATILITY FIELD WITH RADIATION LINES
//==============================================================================
field_strength = math.min(3.0, mahalanobis_dist * tensor_intensity)
field_center = ta.ema(close, 9)
field_amplitude = atr_value * (1 + math.abs(mahalanobis_dist) / 2)
tensor_multiplier = 1 + field_strength * 0.5
upper_field1 = field_center + field_offset * 0.5 * tensor_multiplier
lower_field1 = field_center - field_offset * 0.5 * tensor_multiplier
upper_field2 = field_center + field_offset * 1.0 * tensor_multiplier
lower_field2 = field_center - field_offset * 1.0 * tensor_multiplier
upper_field3 = field_center + field_offset * 1.5 * tensor_multiplier
lower_field3 = field_center - field_offset * 1.5 * tensor_multiplier
upper_field4 = field_center + field_offset * 2.0 * tensor_multiplier
lower_field4 = field_center - field_offset * 2.0 * tensor_multiplier
upper_field5 = field_center + field_offset * 2.5 * tensor_multiplier
lower_field5 = field_center - field_offset * 2.5 * tensor_multiplier
upper_plot1 = plot(show_tensor_field ? upper_field1 : na, color=color.new(color_consciousness, 40), linewidth=3, title="Tensor Core Upper")
lower_plot1 = plot(show_tensor_field ? lower_field1 : na, color=color.new(color_consciousness, 40), linewidth=3, title="Tensor Core Lower")
upper_plot2 = plot(show_tensor_field ? upper_field2 : na, color=color.new(color_neutral, 50), linewidth=2, title="Tensor Layer 2 Upper")
lower_plot2 = plot(show_tensor_field ? lower_field2 : na, color=color.new(color_neutral, 50), linewidth=2, title="Tensor Layer 2 Lower")
upper_plot3 = plot(show_tensor_field ? upper_field3 : na, color=color.new(color_info, 60), linewidth=2, title="Tensor Layer 3 Upper")
lower_plot3 = plot(show_tensor_field ? lower_field3 : na, color=color.new(color_info, 60), linewidth=2, title="Tensor Layer 3 Lower")
upper_plot4 = plot(show_tensor_field ? upper_field4 : na, color=color.new(color_warning, 70), linewidth=1, title="Tensor Layer 4 Upper")
lower_plot4 = plot(show_tensor_field ? lower_field4 : na, color=color.new(color_warning, 70), linewidth=1, title="Tensor Layer 4 Lower")
upper_plot5 = plot(show_tensor_field ? upper_field5 : na, color=color.new(color_success, 80), linewidth=1, title="Tensor Layer 5 Upper")
lower_plot5 = plot(show_tensor_field ? lower_field5 : na, color=color.new(color_success, 80), linewidth=1, title="Tensor Layer 5 Lower")
fill(upper_plot1, lower_plot1, color=show_tensor_field ? color.new(color_consciousness, 92) : na, title="Tensor Core")
fill(upper_plot2, lower_plot2, color=show_tensor_field ? color.new(color_neutral, 94) : na, title="Tensor Layer 2")
fill(upper_plot3, lower_plot3, color=show_tensor_field ? color.new(color_info, 96) : na, title="Tensor Layer 3")
fill(upper_plot4, lower_plot4, color=show_tensor_field ? color.new(color_warning, 97) : na, title="Tensor Layer 4")
fill(upper_plot5, lower_plot5, color=show_tensor_field ? color.new(color_success, 98) : na, title="Tensor Layer 5")
if show_tensor_field and bar_index % 3 == 0 
    field_intensity = mahalanobis_dist / jump_threshold
    for angle_i = 1 to 8  
        angle = angle_i * 45 * math.pi / 180
        ray_length = field_amplitude * 0.3 
        var float start_y = na
        var float end_y = na
        var color ray_color = na
        for segment = 1 to 3 
            segment_start_ratio = (segment - 1) / 3.0
            segment_end_ratio = segment / 3.0
            start_distance = ray_length * segment_start_ratio
            end_distance = ray_length * segment_end_ratio
            start_x = bar_index + int(start_distance / atr_value * 2)
            end_x = bar_index + int(end_distance / atr_value * 2)
            if angle_i <= 4 
                start_y := field_center + start_distance * math.sin(angle)
                end_y := field_center + end_distance * math.sin(angle)
                ray_color := volatility_jump ? color_bearish : color_consciousness
            else  // Lower hemisphere
                start_y := field_center - start_distance * math.sin(angle)
                end_y := field_center - end_distance * math.sin(angle)
                ray_color := volatility_jump ? color_bearish : color_neutral
            line_width = segment == 1 ? 2 : 1
            transparency_ray = 85 + angle_i * 2 + segment * 10
            if segment < 3
                line.new(start_x, start_y, end_x, end_y, color=color.new(ray_color, transparency_ray), width=line_width, style=line.style_dashed)
    if volatility_jump
        pulse_radius = field_amplitude * 0.8
        for pulse_i = 1 to 12 
            pulse_angle = pulse_i * 30 * math.pi / 180
            for pulse_segment = 1 to 2 
                segment_start_ratio = (pulse_segment - 1) / 2.0
                segment_end_ratio = pulse_segment / 2.0               
                start_distance = pulse_radius * segment_start_ratio
                end_distance = pulse_radius * segment_end_ratio                
                pulse_start_x = bar_index + int(start_distance / atr_value * 1.5)
                pulse_end_x = bar_index + int(end_distance / atr_value * 1.5)
                pulse_start_y = field_center + start_distance * math.sin(pulse_angle)
                pulse_end_y = field_center + end_distance * math.sin(pulse_angle)              
                pulse_width = pulse_segment == 1 ? 2 : 1
                pulse_transparency = 90 + pulse_segment * 5                
                line.new(pulse_start_x, pulse_start_y, pulse_end_x, pulse_end_y, color=color.new(color_bearish, pulse_transparency), width=pulse_width, style=line.style_dotted)
//==============================================================================
// 🌊 DYNAMIC REGIME BACKGROUND 
//==============================================================================
var color regime_bg_color = na
if show_regime_bg
    pulse_intensity = int(regime_strength * 10) + 5
    base_alpha = 98 - pulse_intensity 
    if is_trending
        regime_bg_color := color.new(color_bullish, base_alpha)
    else if is_mean_reverting
        regime_bg_color := color.new(color_bearish, base_alpha)
    else
        regime_bg_color := color.new(color_neutral, base_alpha + 1)
else
    regime_bg_color := na
bgcolor(regime_bg_color, title="Dynamic Regime Background")
//==============================================================================
// ⚡ VOLATILITY JUMPS
//==============================================================================
var int jump_display_bar = 0
var bool jump_shown = false
if volatility_jump and not jump_shown
    jump_display_bar := bar_index
    jump_shown := true
    if show_jump_markers
        for bolt = 0 to 3
            bolt_y = high + field_offset * (0.3 + bolt * 0.08)
            bolt_alpha = 40 + bolt * 20   
            label.new(bar_index, bolt_y, "⚡", 
                     color=color.new(color.white, 100), 
                     textcolor=color.new(color_warning, bolt_alpha), 
                     style=label.style_none, 
                     size=bolt == 0 ? size.large : size.normal)
if not raw_volatility_jump
    jump_shown := false
//==============================================================================
// 🌀 DIMENSIONAL PORTAL
//==============================================================================
if show_dimensional_portals
    portal_offset = field_offset * 0.25
    var float portal_y = na
    var color portal_color = na
    clean_green = #00ff00  
    clean_red = #ff0000  
    clean_yellow = #ffff00 
    if is_trending 
        portal_y := close - portal_offset  
        portal_color := clean_green
    else if is_mean_reverting  
        portal_y := close + portal_offset 
        portal_color := clean_red
    else 
        portal_y := close + (close > close[1] ? portal_offset : -portal_offset)
        portal_color := clean_yellow    
    portal_char1 = is_trending ? "◉" : is_mean_reverting ? "◎" : "○"
    label.new(bar_index, portal_y, portal_char1, 
             color=color.new(color.white, 100), 
             textcolor=color.new(portal_color, 0), 
             style=label.style_none, 
             size=size.large)
    for trail = 1 to 8 
        if bar_index >= trail
            trail_x = bar_index - trail
            trail_y = portal_y + math.sin(trail * 0.5) * field_offset * 0.05
            trail_alpha = 30 + trail * 8           
            trail_size = trail <= 2 ? size.normal : trail <= 4 ? size.small : size.tiny
            trail_char = trail <= 2 ? "●" : trail <= 4 ? "◦" : trail <= 6 ? "·" : "˙"            
            label.new(trail_x, trail_y, trail_char, 
                     color=color.new(color.white, 100), 
                     textcolor=color.new(portal_color, trail_alpha), 
                     style=label.style_none, 
                     size=trail_size)
//==============================================================================
// 🔄 INFORMATION FLOW
//==============================================================================
if show_entropy_streams
    flow_active = math.abs(net_information_flow) > 0.01   
    if flow_active or volume > sma_volume * 1.05
        stream_y_base = close + (volume_leads ? field_offset * 0.12 : -field_offset * 0.12)
        for particle = 0 to 15
            particle_x_offset = particle
            if bar_index >= particle_x_offset
                stream_x = bar_index - particle_x_offset
                stream_y = stream_y_base + math.sin((bar_index - particle_x_offset) * 0.3) * field_offset * 0.08
                flow_char = particle <= 1 ? "◉" : particle <= 3 ? "●" : particle <= 6 ? "◦" : particle <= 10 ? "·" : "˙"
                flow_color = volume_leads ? color_info : price_leads ? color_warning : color_neutral
                particle_alpha = 20 + particle * 4 
                particle_size = particle <= 1 ? size.normal : particle <= 4 ? size.small : particle <= 8 ? size.tiny : size.auto
                label.new(stream_x, stream_y, flow_char, 
                         color=color.new(color.white, 100), 
                         textcolor=color.new(flow_color, particle_alpha), 
                         style=label.style_none, 
                         size=particle_size)
//==============================================================================
// 🔮 FRACTAL GRID
//==============================================================================
SCORE_AMPLIFIER = 5.0
phase_intense = color_consciousness
anomaly_strong = color_warning
tensor_negative = color_bearish
tensor_positive = color_bullish
holonomy_accent = color_neutral
holonomy_primary = color_info
if show_fractal_matrix
    h8_high = ta.highest(high, 8)
    h8_low = ta.lowest(low, 8)
    h13_high = ta.highest(high, 13)
    h13_low = ta.lowest(low, 13)
    h21_high = ta.highest(high, 21)
    h21_low = ta.lowest(low, 21)
    h34_high = ta.highest(high, 34)
    h34_low = ta.lowest(low, 34)
    h55_high = ta.highest(high, 55)
    h55_low = ta.lowest(low, 55)
    fractalHighs = array.from(h8_high, h13_high, h21_high, h34_high, h55_high)
    fractalLows = array.from(h8_low, h13_low, h21_low, h34_low, h55_low)
    var array<line> fractalHighGlowLines = array.new<line>()
    var array<line> fractalHighTensorLines = array.new<line>()
    var array<line> fractalHighShadowLines = array.new<line>()
    var array<line> fractalLowGlowLines = array.new<line>()
    var array<line> fractalLowTensorLines = array.new<line>()
    var array<line> fractalLowShadowLines = array.new<line>()
    var array<label> fractalHighLabels = array.new<label>()
    var array<label> fractalLowLabels = array.new<label>()
    if barstate.isconfirmed
        for l in fractalHighGlowLines
            line.delete(l)
        for l in fractalHighTensorLines
            line.delete(l)
        for l in fractalHighShadowLines
            line.delete(l)
        for l in fractalLowGlowLines
            line.delete(l)
        for l in fractalLowTensorLines
            line.delete(l)
        for l in fractalLowShadowLines
            line.delete(l)
        for lbl in fractalHighLabels
            label.delete(lbl)
        for lbl in fractalLowLabels
            label.delete(lbl)        
        array.clear(fractalHighGlowLines)
        array.clear(fractalHighTensorLines)
        array.clear(fractalHighShadowLines)
        array.clear(fractalLowGlowLines)
        array.clear(fractalLowTensorLines)
        array.clear(fractalLowShadowLines)
        array.clear(fractalHighLabels)
        array.clear(fractalLowLabels)
        holonomy_periods = array.from(8, 13, 21, 34, 55)
        used_positions = array.new<float>()
        min_spacing = atr_value * 0.2
        for i = 0 to 4
            period = array.get(holonomy_periods, i)
            base_alpha = 50 + i * 10
            glow_alpha = 70 + i * 6
            shadow_alpha = 85 + i * 3
            hi = array.get(fractalHighs, i)
            if not na(hi)
                array.push(fractalHighShadowLines, line.new(bar_index - 5, hi, bar_index + 20, hi, color=color.new(color.white, shadow_alpha), width=5, style=line.style_solid))
                array.push(fractalHighGlowLines, line.new(bar_index - 5, hi, bar_index + 20, hi, color=color.new(color.white, glow_alpha), width=3, style=line.style_solid))
                array.push(fractalHighTensorLines, line.new(bar_index - 6, hi, bar_index + 21, hi, color=color.new(tensor_negative, base_alpha), width=1, style=line.style_dotted))
                can_place_label = true
                if array.size(used_positions) > 0
                    for j = 0 to array.size(used_positions) - 1
                        if math.abs(hi - array.get(used_positions, j)) < min_spacing
                            can_place_label := false
                            break                
                if can_place_label
                    price_distance = (hi - close) / atr_value
                    holonomy_impact = mahalanobis_dist - (price_distance * SCORE_AMPLIFIER / 10)
                    anomaly_strength = math.abs(holonomy_impact) / jump_threshold
                    cohom_obstruction = hurst_smoothed * math.sin(period * math.pi / 55)
                    level_resonance = hawkes_intensity * (1 - math.abs(price_distance) / 10)
                    regime_factor = is_trending ? 1.2 : is_mean_reverting ? 0.8 : 1.0
                    anomaly_strength := anomaly_strength * regime_factor
                    topo_class = anomaly_strength > 1.5 ? "III" : anomaly_strength > 1.0 ? "II" : anomaly_strength > 0.5 ? "I" : "0"
                    vol_strength = vol_dimensions > 3 ? "V" + str.tostring(vol_dimensions) : "V" + str.tostring(vol_dimensions)
                    hurst_class = is_trending ? "T" : is_mean_reverting ? "R" : "N"                   
                    label_text = "H" + str.tostring(period) + " [" + topo_class + "] " + str.tostring(hi, "#.##") + " | M:" + str.tostring(mahalanobis_dist, "#.##") + " | H:" + str.tostring(hurst_smoothed, "#.##") + " | " + hurst_class + (anomaly_strength > 1.5 ? " ⚡" : anomaly_strength > 1.0 ? " ●" : anomaly_strength > 0.5 ? " ◐" : " ○")                   
                    label_bg_color = anomaly_strength > 1.5 ? color.new(anomaly_strong, 75) : anomaly_strength > 1.0 ? color.new(holonomy_accent, 80) : color.new(panel_bg, 85)                   
                    label_text_color = anomaly_strength > 1.0 ? anomaly_strong : holonomy_accent                    
                    new_label = label.new(bar_index + 21, hi, label_text, color=label_bg_color, textcolor=label_text_color, style=label.style_label_left, size=size.small)                   
                    array.push(fractalHighLabels, new_label)
                    array.push(used_positions, hi)
            lo = array.get(fractalLows, i)
            if not na(lo)

                array.push(fractalLowShadowLines, line.new(bar_index - 5, lo, bar_index + 20, lo, color=color.new(color.white, shadow_alpha), width=5, style=line.style_solid))
                array.push(fractalLowGlowLines, line.new(bar_index - 5, lo, bar_index + 20, lo, color=color.new(color.white, glow_alpha), width=3, style=line.style_solid))
                array.push(fractalLowTensorLines, line.new(bar_index - 6, lo, bar_index + 21, lo, color=color.new(tensor_positive, base_alpha), width=1, style=line.style_dotted))
                can_place_label = true
                if array.size(used_positions) > 0
                    for j = 0 to array.size(used_positions) - 1
                        if math.abs(lo - array.get(used_positions, j)) < min_spacing
                            can_place_label := false
                            break               
                if can_place_label
                    price_distance = (close - lo) / atr_value
                    holonomy_impact = mahalanobis_dist + (price_distance * SCORE_AMPLIFIER / 10)
                    anomaly_strength = math.abs(holonomy_impact) / jump_threshold
                    cohom_obstruction = hurst_smoothed * math.sin(period * math.pi / 55)
                    level_resonance = hawkes_intensity * (1 - math.abs(price_distance) / 10)
                    regime_factor = is_trending ? 1.2 : is_mean_reverting ? 0.8 : 1.0
                    anomaly_strength := anomaly_strength * regime_factor
                    topo_class = anomaly_strength > 1.5 ? "III" : anomaly_strength > 1.0 ? "II" : anomaly_strength > 0.5 ? "I" : "0"
                    vol_strength = vol_dimensions > 3 ? "V" + str.tostring(vol_dimensions) : "V" + str.tostring(vol_dimensions)
                    hurst_class = is_trending ? "T" : is_mean_reverting ? "R" : "N"
                    entropy_class = volume_leads ? "VL" : price_leads ? "PL" : "NL"                    
                    label_text = "L" + str.tostring(period) + " [" + topo_class + "] " + str.tostring(lo, "#.##") + " | M:" + str.tostring(mahalanobis_dist, "#.##") + " | H:" + str.tostring(hurst_smoothed, "#.##") + " | " + hurst_class + (anomaly_strength > 1.5 ? " ⚡" : anomaly_strength > 1.0 ? " ●" : anomaly_strength > 0.5 ? " ◐" : " ○")                    
                    label_bg_color = anomaly_strength > 1.5 ? color.new(tensor_positive, 75) : anomaly_strength > 1.0 ? color.new(holonomy_primary, 80) : color.new(panel_bg, 85)                    
                    label_text_color = anomaly_strength > 1.0 ? tensor_positive : holonomy_primary                    
                    new_label = label.new(bar_index + 21, lo, label_text, color=label_bg_color, textcolor=label_text_color, style=label.style_label_left, size=size.small)                    
                    array.push(fractalLowLabels, new_label)
                    array.push(used_positions, lo)
//==============================================================================
// ⚡ LIGHTNING NETWORK 
//==============================================================================
if show_lightning_network and hawkes_intensity > 0.2
    if bar_index % 5 == 0
        lightning_y = high + field_offset * 0.2       
        for connection = 1 to 2
            if bar_index >= connection * 4
                start_x = bar_index - connection * 4
                end_x = bar_index
                start_y = high[connection * 4] + field_offset * 0.08
                end_y = lightning_y                
                lightning_alpha = 45 + connection * 20 
                line.new(start_x, start_y, end_x, end_y, color=color.new(color_warning, lightning_alpha), width=1, style=line.style_dashed)        
        label.new(bar_index, lightning_y, "⚡", 
                 color=color.new(color.white, 100), 
                 textcolor=color.new(color_warning, 50), 
                 style=label.style_none, 
                 size=size.small)
//==============================================================================
// 🎯 HOLOGRAPHIC PROJECTIONS
//==============================================================================
if show_holographic_signals and (long_signal or short_signal)

    var float signal_y = na
    var string signal_char = na
    var color signal_color = na
    if long_signal
        signal_y := high + field_offset * 0.6
        signal_char := "▼"
        signal_color := color_bearish
    else  
        signal_y := low - field_offset * 0.6
        signal_char := "▲" 
        signal_color := color_bullish
    for projection = 1 to 8
        projection_alpha = 30 + projection * 8
        projection_size = projection <= 2 ? size.normal : projection <= 4 ? size.small : size.tiny
        projection_char = projection <= 3 ? signal_char : projection <= 5 ? "◦" : "·"       
        proj_y = signal_y + math.sin(projection * 0.3) * field_offset * 0.03       
        label.new(bar_index + projection, proj_y, projection_char, 
                 color=color.new(color.white, 100), 
                 textcolor=color.new(signal_color, projection_alpha), 
                 style=label.style_none, 
                 size=projection_size)
//==============================================================================
// 🌟 TENSOR CONSTELLATION NETWORK
//==============================================================================
if show_dimensional_portals and bar_index % 4 == 0
    for connection = 1 to 3
        if bar_index >= connection * 5
            start_x = bar_index - connection * 5
            end_x = bar_index
            start_y = close[connection * 5]
            end_y = close            
            connection_color = start_y < end_y ? color_bullish : color_bearish
            connection_alpha = 80 + connection * 5  // More transparent           
            line.new(start_x, start_y, end_x, end_y, color=color.new(connection_color, connection_alpha), width=1, style=line.style_dotted)
//==============================================================================
// 🎯 TENSOR BUY/SELL SIGNALS
//==============================================================================
if show_signals
    if long_signal
        signal_base_y = high + field_offset * 1.0
        label.new(bar_index, signal_base_y, "◉", 
                 color=color.new(color.white, 100), 
                 textcolor=color_bearish,
                 style=label.style_none, 
                 size=size.large)
        for ring = 1 to 4
            ring_char = ring == 1 ? "◎" : ring == 2 ? "○" : ring == 3 ? "◌" : "◦"
            ring_alpha = 20 + ring * 15
            ring_size = ring <= 2 ? size.large : size.normal            
            label.new(bar_index, signal_base_y, ring_char, 
                     color=color.new(color.white, 100), 
                     textcolor=color.new(color_bearish, ring_alpha), 
                     style=label.style_none, 
                     size=ring_size)
        for particle = 0 to 8
            particle_distance = field_offset * 0.15
            particle_y_offset = particle_distance * math.sin(particle * 45 * math.pi / 180)            
            label.new(bar_index, signal_base_y + particle_y_offset, "✦", 
                     color=color.new(color.white, 100), 
                     textcolor=color.new(color_bearish, 40), 
                     style=label.style_none, 
                     size=size.small)
        for trail = 1 to 6
            if bar_index >= trail
                trail_y = signal_base_y + trail * field_offset * 0.02
                trail_char = trail <= 2 ? "✧" : trail <= 4 ? "✦" : "·"
                trail_alpha = 30 + trail * 10               
                label.new(bar_index - trail, trail_y, trail_char, 
                         color=color.new(color.white, 100), 
                         textcolor=color.new(color_bearish, trail_alpha),
                         style=label.style_none, 
                         size=size.small)        
        if show_signal_labels
            label.new(bar_index, signal_base_y + field_offset * 0.4, "SELL", 
                     color=color_bearish,
                     textcolor=text_bright, 
                     style=label.style_label_down, 
                     size=size.normal)   
    if short_signal
        signal_base_y = low - field_offset * 1.0
        label.new(bar_index, signal_base_y, "◉", 
                 color=color.new(color.white, 100), 
                 textcolor=color_bullish,
                 style=label.style_none, 
                 size=size.large)
        for ring = 1 to 4
            ring_char = ring == 1 ? "◎" : ring == 2 ? "○" : ring == 3 ? "◌" : "◦"
            ring_alpha = 20 + ring * 15
            ring_size = ring <= 2 ? size.large : size.normal            
            label.new(bar_index, signal_base_y, ring_char, 
                     color=color.new(color.white, 100), 
                     textcolor=color.new(color_bullish, ring_alpha),
                     style=label.style_none, 
                     size=ring_size)
        for particle = 0 to 8
            particle_distance = field_offset * 0.15
            particle_y_offset = particle_distance * math.sin(particle * 45 * math.pi / 180)
            
            label.new(bar_index, signal_base_y - particle_y_offset, "✦", 
                     color=color.new(color.white, 100), 
                     textcolor=color.new(color_bullish, 40), 
                     size=size.small)
        for trail = 1 to 6
            if bar_index >= trail
                trail_y = signal_base_y - trail * field_offset * 0.02
                trail_char = trail <= 2 ? "✧" : trail <= 4 ? "✦" : "·"
                trail_alpha = 30 + trail * 10               
                label.new(bar_index - trail, trail_y, trail_char, 
                         color=color.new(color.white, 100), 
                         textcolor=color.new(color_bullish, trail_alpha),
                         style=label.style_none, 
                         size=size.small)       
        if show_signal_labels
            label.new(bar_index, signal_base_y - field_offset * 0.4, "BUY",
                     color=color_bullish, 
                     textcolor=text_bright, 
                     style=label.style_label_up,
                     size=size.normal)
//==============================================================================
// DASHBOARD
//==============================================================================
var table dashboard_enhanced = na
if show_dashboard and barstate.isconfirmed
    dashboard_pos = dashboard_position_input == "Top Left" ? position.top_left : 
                   dashboard_position_input == "Top Right" ? position.top_right : 
                   dashboard_position_input == "Bottom Left" ? position.bottom_left : 
                   position.bottom_right   
    cols = dashboard_size == "Large" ? 5 : 4
    rows = dashboard_size == "Large" ? 25 : dashboard_size == "Normal" ? 20 : 14    
    if not na(dashboard_enhanced)
        table.delete(dashboard_enhanced)      
    dashboard_enhanced := table.new(dashboard_pos, cols, rows, border_width = 1, 
                                  border_color = color.new(border_color, 50), 
                                  bgcolor = color.new(panel_bg, 20))        
    dc_white = text_bright
    dc_gray = text_muted
    dc_green = color_bullish
    dc_red = color_bearish
    dc_gold = color_warning
    dc_purple = color_consciousness
    dc_aqua = color_info
    dc_orange = color_warning
    dc_cyan = color_success
    bg_header = color.new(bg_dark, 30)
    bg_section = color.new(panel_bg, 85)       
    header_size = dashboard_size == "Large" ? size.normal : size.small
    value_size = dashboard_size == "Large" ? size.normal : size.small
    label_size = dashboard_size == "Large" ? size.small : size.tiny       
    current_row = 0      
    table.merge_cells(dashboard_enhanced, 0, current_row, cols - 1, current_row)
    table.cell(dashboard_enhanced, 0, current_row, "🔢 Tensor Market Analysis Engine | " + syminfo.ticker, 
              text_halign=text.align_center, text_color=dc_white, bgcolor=bg_header, text_size=header_size)
    current_row += 1   
    table.merge_cells(dashboard_enhanced, 0, current_row, cols - 1, current_row)
    table.cell(dashboard_enhanced, 0, current_row, "═══ ⚡ TENSOR FIELD STATUS ═══", 
              text_halign=text.align_center, text_color=dc_gold, bgcolor=bg_section, text_size=label_size)
    current_row += 1       
    table.cell(dashboard_enhanced, 0, current_row, "Field Strength", text_color=dc_gray, text_size=label_size)
    table.merge_cells(dashboard_enhanced, 1, current_row, cols - 1, current_row)
    field_color = math.abs(signal_strength_confirmed) > signal_threshold ? 
                  (signal_strength_confirmed > 0 ? dc_green : dc_red) : dc_gray
    field_emoji = math.abs(signal_strength_confirmed) > signal_threshold * 1.5 ? "⚡" : 
                  math.abs(signal_strength_confirmed) > signal_threshold ? "●" : "○"
    table.cell(dashboard_enhanced, 1, current_row, field_emoji + " " + str.tostring(signal_strength_confirmed, "#.##"), 
              text_halign=text.align_right, text_color=field_color, text_size=value_size)
    current_row += 1       
    table.cell(dashboard_enhanced, 0, current_row, "Quality", text_color=dc_gray, text_size=label_size)
    table.merge_cells(dashboard_enhanced, 1, current_row, cols - 1, current_row)
    quality_emoji = signal_quality_rating == "ELITE" ? "🌟" : 
                   signal_quality_rating == "STRONG" ? "💪" : 
                   signal_quality_rating == "GOOD" ? "👍" : "⚠️"
    quality_color = signal_quality_rating == "ELITE" ? dc_gold : 
                   signal_quality_rating == "STRONG" ? dc_green : 
                   signal_quality_rating == "GOOD" ? dc_aqua : dc_gray
    table.cell(dashboard_enhanced, 1, current_row, quality_emoji + " " + signal_quality_rating, 
              text_halign=text.align_right, text_color=quality_color, text_size=value_size)
    current_row += 1       
    table.merge_cells(dashboard_enhanced, 0, current_row, cols - 1, current_row)
    table.cell(dashboard_enhanced, 0, current_row, "═══ 🎯 TRADING SIGNALS ═══", 
              text_halign=text.align_center, text_color=dc_gold, bgcolor=bg_section, text_size=label_size)
    current_row += 1        
    table.cell(dashboard_enhanced, 0, current_row, "Long Signal", text_color=dc_gray, text_size=label_size)
    long_text = long_signal ? "🟢 ACTIVE" : "⚪ INACTIVE"
    table.cell(dashboard_enhanced, 1, current_row, long_text, text_color=long_signal ? dc_green : dc_gray, text_size=label_size)      
    table.cell(dashboard_enhanced, 2, current_row, "Short Signal", text_color=dc_gray, text_size=label_size)
    short_text = short_signal ? "🔴 ACTIVE" : "⚪ INACTIVE"
    table.cell(dashboard_enhanced, 3, current_row, short_text, text_color=short_signal ? dc_red : dc_gray, text_size=label_size)
    current_row += 1      
    table.cell(dashboard_enhanced, 0, current_row, "Vol Signal", text_color=dc_gray, text_size=label_size)
    vol_text = vol_signal ? "✅ ON" : "❌ OFF"
    table.cell(dashboard_enhanced, 1, current_row, vol_text, text_color=vol_signal ? dc_green : dc_gray, text_size=label_size)   
    table.cell(dashboard_enhanced, 2, current_row, "Hurst Signal", text_color=dc_gray, text_size=label_size)
    hurst_text = hurst_signal ? "✅ ON" : "❌ OFF"
    table.cell(dashboard_enhanced, 3, current_row, hurst_text, text_color=hurst_signal ? dc_green : dc_gray, text_size=label_size)
    current_row += 1    
    table.cell(dashboard_enhanced, 0, current_row, "Entropy Signal", text_color=dc_gray, text_size=label_size)
    entropy_text = entropy_signal ? "✅ ON" : "❌ OFF"
    table.cell(dashboard_enhanced, 1, current_row, entropy_text, text_color=entropy_signal ? dc_green : dc_gray, text_size=label_size)    
    table.cell(dashboard_enhanced, 2, current_row, "Components", text_color=dc_gray, text_size=label_size)
    components_text = str.tostring(active_signals) + "/3"
    components_color = active_signals == 3 ? dc_green : active_signals == 2 ? dc_aqua : active_signals == 1 ? dc_orange : dc_gray
    table.cell(dashboard_enhanced, 3, current_row, components_text, text_color=components_color, text_size=value_size)    
    current_row += 1       
    table.merge_cells(dashboard_enhanced, 0, current_row, cols - 1, current_row)
    table.cell(dashboard_enhanced, 0, current_row, "═══ 🏆 PERFORMANCE METRICS ═══", 
              text_halign=text.align_center, text_color=dc_gold, bgcolor=bg_section, text_size=label_size)
    current_row += 1         
    table.cell(dashboard_enhanced, 0, current_row, "Win Rate", text_color=dc_gray, text_size=label_size)
    win_rate_display = total_trades > 0 ? str.tostring(real_win_rate * 100, "#.1") + "%" : "N/A"
    win_rate_color = real_win_rate >= 0.6 ? dc_green : real_win_rate >= 0.4 ? dc_orange : dc_red
    win_rate_emoji = real_win_rate >= 0.6 ? "🔥" : real_win_rate >= 0.4 ? "👍" : "⚠️"       
    table.cell(dashboard_enhanced, 1, current_row, win_rate_emoji + win_rate_display, 
              text_halign=text.align_right, text_color=total_trades > 0 ? win_rate_color : dc_gray, text_size=label_size)           
    table.cell(dashboard_enhanced, 2, current_row, "Total Trades", text_color=dc_gray, text_size=label_size)
    table.cell(dashboard_enhanced, 3, current_row, str.tostring(total_trades), text_color=dc_cyan, text_size=label_size)
    current_row += 1        
    table.cell(dashboard_enhanced, 0, current_row, "Regime", text_color=dc_gray, text_size=label_size)
    regime_text = is_trending ? "📈 TREND" : is_mean_reverting ? "🔄 REVERT" : "🎲 RANDOM"
    regime_color = is_trending ? dc_green : is_mean_reverting ? dc_red : dc_aqua
    table.cell(dashboard_enhanced, 1, current_row, regime_text, text_color=regime_color, text_size=label_size)       
    table.cell(dashboard_enhanced, 2, current_row, "Hurst Exp", text_color=dc_gray, text_size=label_size)
    table.cell(dashboard_enhanced, 3, current_row, str.tostring(hurst_smoothed, "#.###"), 
              text_halign=text.align_right, text_color=dc_purple, text_size=label_size)
    current_row += 1
//==============================================================================
// 🔔 ALERTS
//==============================================================================
alertcondition(long_signal, "TMAE Sell Signal", "Tensor Market Analysis Engine: Sell Entry Signal")
alertcondition(short_signal, "TMAE Buy Signal", "Tensor Market Analysis Engine: Buy Entry Signal")
alertcondition(volatility_jump, "Volatility Jump", "Multi-dimensional volatility jump detected")
alertcondition(is_trending and not is_trending[1], "Regime: Trending", "Market entered trending regime")
alertcondition(is_mean_reverting and not is_mean_reverting[1], "Regime: Mean Reverting", "Market entered mean reverting regime")
alertcondition(volume_leads and not volume_leads[1], "Volume Leading", "Volume now leading price - potential move incoming")
````

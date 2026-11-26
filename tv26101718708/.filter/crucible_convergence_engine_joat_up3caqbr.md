# Crucible Convergence Engine [JOAT]

- url: https://www.tradingview.com/script/UP3CAQbR-Crucible-Convergence-Engine-JOAT/
- type: strategy
- pine_id: PUB;f026203c0d3b4978b8ba4ae8076397c5
- version: 1.0

## Description

[b]Crucible Convergence Engine [JOAT][/b]

[b]Introduction[/b]

The Crucible Convergence Engine is an open-source multi-module convergence strategy that requires alignment across five independent analytical engines before entering a trade. It fuses a Regime Arbiter (market state classification), Directional Helix (trend direction), Pressure Reactor (volume-weighted momentum), Deviation Lattice (statistical band filter), and Fortress Grid (dynamic S/R levels) into a unified convergence scoring system. Entries only fire when all required modules agree — regime confirms a trending state, trend direction aligns, momentum confirms, price is not at a statistical extreme, and volume exceeds its gate threshold. Exits are managed through ATR-based stops and targets, an optional trailing shield, regime flip detection, lattice extreme reversal, and rail interaction exits.

This strategy exists because most trading systems rely on one or two confirmation layers. A moving average crossover with an RSI filter, for example, still enters trades in ranging markets, against macro trends, or at statistical extremes. CCE addresses this by requiring convergence across five fundamentally different analytical dimensions before committing capital. The trade-off is fewer trades — but each trade has multi-dimensional confirmation behind it.

[image]https://www.tradingview.com/x/jqsraw2d/[/image]

[b]Module Architecture[/b]

[b]Module 1: Regime Arbiter[/b]

The Regime Arbiter classifies the market into four states using ATR percentile ranking, custom directional movement scoring, and EMA trend alignment:

[list]
[*][b]Kinetic Ascent:[/b] ATR percentile above the kinetic threshold, positive directional bias, fast EMA above slow EMA
[*][b]Kinetic Descent:[/b] Same volatility conditions but with negative directional bias
[*][b]Turbulence:[/b] ATR percentile above the turbulence threshold — high volatility without clear direction
[*][b]Equilibrium:[/b] Low volatility, no strong directional bias — ranging market
[/list]

A two-bar confirmation filter prevents single-bar regime flicker. When the Regime Gate is active (default), the strategy only enters trades during Kinetic Ascent or Kinetic Descent — it sits out during Turbulence and Equilibrium, avoiding the choppy conditions that destroy most trend-following systems.

[b]Module 2: Directional Helix[/b]

A fast and slow moving average (EMA or SMA, configurable) determine trend direction. The strategy requires the helix to agree with the regime — a long entry needs both the regime in Kinetic Ascent AND the fast MA above the slow MA.

[b]Module 3: Pressure Reactor[/b]

Volume-weighted momentum is calculated using the same logarithmic volume impact function found in the Ferrum Pressure Gauge indicator:

[pine]
float vwM = pChg * math.log(1 + vR * momVolSens)
float mF  = ta.ema(vwM, momFast)
float mS  = ta.ema(vwM, momSlow)
float mIdx = ta.ema(mF - mS, 5)
[/pine]

The Pressure Reactor must confirm the trade direction — bullish momentum for longs, bearish momentum for shorts. This ensures that volume-weighted price action supports the entry, not just trend direction.

[b]Module 4: Deviation Lattice[/b]

A statistical band system (mean +/- standard deviation * multiplier) acts as an extreme filter. The strategy will NOT enter a long if price is already at or above the upper band (overbought), and will NOT enter a short if price is at or below the lower band (oversold). This prevents chasing extended moves that are statistically likely to revert.

[b]Module 5: Volume Gate[/b]

A simple but effective filter requiring short-term volume to exceed a configurable multiple of average volume (default 1.1x). This ensures entries occur during periods of meaningful market participation, not during thin, unreliable conditions.

[b]Convergence Scoring[/b]

Each module contributes a weighted score to the overall convergence percentage:

[list]
[*]Regime Arbiter: 25 points (trending state confirmed)
[*]Directional Helix: 25 points (trend direction aligned)
[*]Pressure Reactor: 25 points (momentum confirmed)
[*]Deviation Lattice: 15 points (not at statistical extreme)
[*]Volume Gate: 10 points (sufficient market participation)
[/list]

The convergence score is classified as FULL LOCK (90%+), STRONG (70%+), PARTIAL (50%+), or WEAK (below 50%). The dashboard displays this score in real-time so you can see how close the market is to triggering an entry even before it fires.

Entry conditions require ALL modules to align simultaneously. Entries are edge-triggered — they fire only on the transition from non-convergent to convergent, preventing re-entry on the same signal.

[b]Risk Architecture[/b]

[list]
[*][b]ATR Shield (Stop Loss):[/b] Initial stop placed at entry price minus ATR * Shield Multiple (default 2.0x ATR). This adapts stop distance to current volatility.
[*][b]ATR Objective (Take Profit):[/b] Target placed at entry price plus ATR * Objective Multiple (default 3.0x ATR). The default 1:1.5 risk-reward ratio (2.0 stop vs 3.0 target) provides positive expectancy even with moderate win rates.
[*][b]Trailing Shield:[/b] When enabled, an ATR-based trailing stop ratchets in the direction of the trade. For longs, the trail is set at close minus ATR * Trail Multiple, and it only moves up, never down. This locks in profits during extended moves.
[*][b]Regime Flip Exit:[/b] If the Regime Arbiter flips to the opposite state (e.g., from Kinetic Ascent to Kinetic Descent while in a long), the position is closed immediately. This is a structural exit — the market environment that justified the entry no longer exists.
[*][b]Lattice Extreme Exit:[/b] If price reaches the opposite statistical extreme (upper band for longs, lower band for shorts), the position is closed. This captures profits at statistically extended levels.
[*][b]Rail Interaction Exit:[/b] If price enters the proximity zone of the opposing Fortress Grid rail (ceiling for longs, floor for shorts), the position is closed. This respects dynamic support/resistance levels.
[/list]

[b]Strategy Default Properties[/b]

These are the default settings used in the strategy's Properties dialog:

[list]
[*][b]Initial Capital:[/b] TradingView default
[*][b]Order Size:[/b] 10% of equity per trade (percent_of_equity)
[*][b]Pyramiding:[/b] 0 (no stacking — one position at a time)
[*][b]Commission:[/b] Not set by default — users should configure realistic commission for their instrument
[*][b]Slippage:[/b] Not set by default — users should add realistic slippage for their instrument
[*][b]Margin:[/b] margin_long=0, margin_short=0 (v5-equivalent behavior)
[*][b]Calc on Every Tick:[/b] false (confirmed bars only)
[*][b]Process Orders on Close:[/b] true
[/list]

[b]Important:[/b] Users should set realistic commission AND slippage values in the strategy Properties before evaluating backtest results. The default results without commission/slippage will overstate performance. A commission of 0.04-0.1% per side and 1-3 ticks of slippage is reasonable for most liquid instruments.

[b]Command Panel (Dashboard)[/b]

A 13-row monospace dashboard displays the complete strategy state:

[list]
[*][b]SCORE:[/b] Convergence classification with percentage (FULL LOCK / STRONG / PARTIAL / WEAK)
[*][b]REGIME:[/b] Current market state (Kinetic Ascent, Kinetic Descent, Turbulence, Equilibrium)
[*][b]HELIX:[/b] Trend direction (Ascent / Descent)
[*][b]PRESSURE:[/b] Momentum direction (Ascent / Descent)
[*][b]LATTICE:[/b] Band filter state (Clear / Ceiling Hit / Floor Hit)
[*][b]Z-SCORE:[/b] Current statistical deviation from mean
[*][b]VOL GATE:[/b] Volume gate status with current ratio (Open / Closed)
[*][b]POSITION:[/b] Current trade status (Long / Short / Flat)
[*][b]AGE:[/b] Bars since entry
[*][b]SHIELD:[/b] Current ATR-based stop distance
[*][b]TRAIL:[/b] Current trailing stop price (if active)
[*][b]DIR BIAS:[/b] Raw directional movement bias score
[/list]

[b]Input Parameters[/b]

[b]Regime Arbiter:[/b]
[list]
[*]Dispersion Epoch / Rank Horizon / Kinetic Threshold / Turbulence Threshold / Regime Gate Active
[/list]

[b]Directional Helix:[/b]
[list]
[*]Lead Filament / Anchor Filament / Filament Type (EMA or SMA)
[/list]

[b]Pressure Reactor:[/b]
[list]
[*]Ignition Cycle / Sustain Cycle / Flux Epoch / Flux Amplifier
[/list]

[b]Deviation Lattice:[/b]
[list]
[*]Lattice Depth / Sigma Aperture / Lattice Extreme Exit toggle
[/list]

[b]Fortress Grid:[/b]
[list]
[*]Grid Anchor / Grid Increment / Proximity Radius / Rail Interaction Exit toggle
[/list]

[b]Risk Architecture:[/b]
[list]
[*]Shield Multiple (stop) / Objective Multiple (target) / Risk Epoch (ATR period) / Trailing Shield toggle / Trail Multiple
[/list]

[b]Volume Gate:[/b]
[list]
[*]Require Volume Confirmation / Volume Gate Threshold
[/list]

[b]How to Use This Strategy[/b]

[list]
[*]Start by setting realistic commission and slippage in the strategy Properties before evaluating any backtest results.
[*]Adjust the Grid Increment in the Fortress Grid module to match your instrument (500-1000 for BTC, 50-100 for stocks, etc.).
[*]Monitor the Convergence Score in the dashboard — it shows how close the market is to triggering an entry. STRONG readings (70%+) that haven't yet reached FULL LOCK often precede entries by a few bars.
[*]The Regime Gate is the most impactful filter. Disabling it will produce more trades but in lower-quality market conditions. Keep it enabled unless you have a specific reason to trade ranging/volatile markets.
[*]Experiment with the Shield and Objective multiples to find the risk-reward ratio that matches your trading style. Higher Objective multiples produce fewer but larger winners; lower multiples produce more frequent but smaller wins.
[*]The Trailing Shield is most valuable in trending markets where moves extend beyond the initial target. In choppy markets, it may give back profits. Consider disabling it if the instrument tends to mean-revert quickly.
[/list]

[b]Limitations and Honest Assessment[/b]

[list]
[*]Multi-module convergence produces fewer trades. On some instruments and timeframes, the strategy may go extended periods without a signal. This is by design — it prioritizes quality over quantity.
[*]Backtest results are hypothetical and do not account for real-world execution challenges including partial fills, requotes, and market impact.
[*]The strategy uses process_orders_on_close=true, which means orders execute at the close of the signal bar. In live trading, you would need to enter at the open of the next bar, which introduces slippage.
[*]Past performance shown in backtests does not guarantee future results. Market conditions change, and strategies that worked historically may underperform in different regimes.
[*]The default settings are not optimized for any specific instrument or timeframe. Users should test across multiple datasets and adjust parameters to their specific use case.
[*]The Regime Arbiter and all other modules use lagging indicators. Entries will always occur after a trend has begun, not at the exact bottom or top.
[*]No strategy works in all market conditions. CCE is designed for trending markets and will underperform during extended ranging or highly volatile periods.
[/list]

[b]Originality Statement[/b]

This strategy is original in its five-module convergence architecture. While individual components (ATR regime classification, MA crossovers, volume-weighted momentum, statistical bands, EMA-derived levels) are established concepts, CCE is justified because:

[list]
[*]The five-module convergence scoring system requires alignment across fundamentally different analytical dimensions (volatility regime, trend, momentum, statistics, structure) before entering — a more rigorous entry filter than typical dual-confirmation systems.
[*]The weighted convergence score provides a quantified readiness metric that communicates how close the market is to a valid entry, even when not all conditions are met.
[*]Four distinct exit mechanisms (ATR stop/target, trailing shield, regime flip, lattice extreme, rail interaction) provide layered risk management that adapts to different exit scenarios.
[*]The Regime Arbiter gate prevents trading during Turbulence and Equilibrium states, addressing the primary failure mode of trend-following strategies.
[*]Edge-triggered entries with two-bar regime confirmation prevent re-entry on the same signal and eliminate single-bar flicker.
[*]The comprehensive 13-row dashboard provides full transparency into every module's state, the convergence score, and the current risk parameters.
[/list]

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss and is not suitable for all investors. Backtest results are hypothetical, do not represent actual trading, and do not guarantee future performance. Past results in no way guarantee future results. Commission, slippage, and other real-world costs will reduce actual performance below what backtests show. Always use proper risk management, including position sizing appropriate for your account and risk tolerance. Never risk more than you can afford to lose. The author is not responsible for any losses incurred from using this strategy.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Crucible Convergence Engine [JOAT]", shorttitle="CCE [JOAT]", overlay=true,
     calc_on_every_tick=false, margin_long=0, margin_short=0,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10,
     pyramiding=0, process_orders_on_close=true)

// ──────────────────── INPUTS ────────────────────────────────────────────────
// ── Regime Arbiter (Core) ──
string GRP_REG   = "Regime Arbiter"
int    regAtrLen  = input.int(14,  "Dispersion Epoch",      minval=5,  maxval=50,  group=GRP_REG, tooltip="ATR lookback for regime classification")
int    regRankLen = input.int(50,  "Rank Horizon",          minval=20, maxval=200, group=GRP_REG, tooltip="Percentile rank window for ATR")
float  regTrGate  = input.float(55, "Kinetic Threshold",    minval=30, maxval=80,  step=5, group=GRP_REG, tooltip="ATR percentile above which market is trending")
float  regVolGate = input.float(70, "Turbulence Threshold", minval=50, maxval=95, step=5, group=GRP_REG, tooltip="ATR percentile above which market is volatile")
bool   useRegime  = input.bool(true, "Regime Gate Active",  group=GRP_REG)

// ── Directional Helix (Core) ──
string GRP_TREND = "Directional Helix"
int    trendFast  = input.int(8,   "Lead Filament",    minval=2,  maxval=30,  group=GRP_TREND, tooltip="Fast MA for trend direction")
int    trendSlow  = input.int(34,  "Anchor Filament",  minval=10, maxval=100, group=GRP_TREND, tooltip="Slow MA for trend direction")
string trendMA    = input.string("EMA", "Filament Type", options=["EMA", "SMA"], group=GRP_TREND)

// ── Pressure Reactor (Core) ──
string GRP_MOM   = "Pressure Reactor"
int    momFast    = input.int(8,   "Ignition Cycle",    minval=2,  maxval=30,  group=GRP_MOM)
int    momSlow    = input.int(21,  "Sustain Cycle",     minval=5,  maxval=50,  group=GRP_MOM)
int    momVolPer  = input.int(14,  "Flux Epoch",        minval=5,  maxval=50,  group=GRP_MOM)
float  momVolSens = input.float(1.5, "Flux Amplifier",  minval=0.1, maxval=5.0, step=0.1, group=GRP_MOM)

// ── Deviation Lattice (Core) ──
string GRP_BAND  = "Deviation Lattice"
int    bandZLen   = input.int(100, "Lattice Depth",     minval=20,  maxval=300, group=GRP_BAND, tooltip="Lookback for mean and standard deviation")
float  bandMult   = input.float(2.0, "Sigma Aperture",  minval=1.0, maxval=4.0, step=0.25, group=GRP_BAND)
bool   useBandExit = input.bool(true, "Lattice Extreme Exit", group=GRP_BAND, tooltip="Close position when price reaches opposite band extreme")

// ── Fortress Grid (Core) ──
string GRP_LVL   = "Fortress Grid"
int    lvlEmaLen  = input.int(21,    "Grid Anchor",       minval=5,   maxval=100,  group=GRP_LVL, tooltip="EMA period for level derivation")
float  lvlRound   = input.float(500, "Grid Increment",    minval=10,  maxval=5000, step=50, group=GRP_LVL)
float  lvlTolF    = input.float(0.15, "Proximity Radius", minval=0.05, maxval=0.5, step=0.05, group=GRP_LVL)
bool   useLvlExit = input.bool(true,  "Rail Interaction Exit", group=GRP_LVL, tooltip="Close position when price touches opposing level")

// ── Risk Architecture ──
string GRP_RISK  = "Risk Architecture"
float  atrStopM   = input.float(2.0, "Shield Multiple",     minval=0.5, maxval=5.0, step=0.25, group=GRP_RISK, tooltip="ATR multiple for initial stop loss")
float  atrTPM     = input.float(3.0, "Objective Multiple",   minval=1.0, maxval=8.0, step=0.25, group=GRP_RISK, tooltip="ATR multiple for take profit")
int    riskAtrLen = input.int(14,    "Risk Epoch",           minval=5,   maxval=50,  group=GRP_RISK)
bool   useTrail   = input.bool(true, "Trailing Shield",      group=GRP_RISK, tooltip="Enable ATR-based trailing stop after entry")
float  trailMult  = input.float(1.5, "Trail Multiple",       minval=0.5, maxval=4.0, step=0.25, group=GRP_RISK, tooltip="ATR multiple for trailing stop distance")

// ── Volume Gate ──
string GRP_VGATE = "Volume Gate"
bool   useVolGate = input.bool(true,  "Require Volume Confirmation", group=GRP_VGATE, tooltip="Entry requires above-average volume")
float  volGateMul = input.float(1.1,  "Volume Gate Threshold",       minval=0.8, maxval=3.0, step=0.1, group=GRP_VGATE)

// ── Optics Layer ──
string GRP_VIS   = "Optics Layer"
bool   showDash   = input.bool(true, "Command Panel",       group=GRP_VIS)
bool   showBands  = input.bool(true, "Deviation Lattice",   group=GRP_VIS)
bool   showEmas   = input.bool(true, "Directional Helix",   group=GRP_VIS)
bool   showLevels = input.bool(true, "Fortress Rails",      group=GRP_VIS)
bool   showBg     = input.bool(true, "Regime Aura",         group=GRP_VIS)

string GRP_COL   = "Chromatic Scheme"
color  colBull    = input.color(#0affab, "Ascent",      group=GRP_COL)
color  colBear    = input.color(#ff2e63, "Descent",     group=GRP_COL)
color  colNeut    = input.color(#6c5ce7, "Equilibrium", group=GRP_COL)
color  colVolat   = input.color(#ffa502, "Turbulence",  group=GRP_COL)

// ══════════════════════════════════════════════════════════════════════════════
// MODULE 1 : REGIME ARBITER 
// ══════════════════════════════════════════════════════════════════════════════
float rAtr    = ta.atr(regAtrLen)
float rAtrPct = ta.percentrank(rAtr, regRankLen)

float upMv    = math.max(high - high[1], 0)
float dnMv    = math.max(low[1] - low, 0)
float sdmP    = ta.ema(upMv > dnMv ? upMv : 0.0, regAtrLen)
float sdmM    = ta.ema(dnMv > upMv ? dnMv : 0.0, regAtrLen)
float dirBias = sdmP + sdmM != 0 ? (sdmP - sdmM) / (sdmP + sdmM) : 0.0

float eFastR  = ta.ema(close, 8)
float eSlowR  = ta.ema(close, 34)
float emaBias = rAtr != 0 ? (eFastR - eSlowR) / rAtr : 0.0

bool isVolatile = rAtrPct > regVolGate
bool isTrending = rAtrPct > regTrGate and not isVolatile
bool isBullDir  = dirBias > 0.1 and emaBias > 0.5
bool isBearDir  = dirBias < -0.1 and emaBias < -0.5

var int rawReg = 0
if isVolatile
    rawReg := 2
else if isTrending and isBullDir
    rawReg := 1
else if isTrending and isBearDir
    rawReg := -1
else
    rawReg := 0

// Two-bar confirmation
var int regime       = 0
var int pendReg      = 0
var int pendRegCount = 0

if rawReg == pendReg
    pendRegCount += 1
else
    pendReg      := rawReg
    pendRegCount := 1

if pendRegCount >= 2
    regime := pendReg

color regCol = regime == 1 ? colBull : regime == -1 ? colBear : regime == 2 ? colVolat : colNeut
bgcolor(showBg ? color.new(regCol, 93) : na, title="Regime Aura")

// ══════════════════════════════════════════════════════════════════════════════
// MODULE 2 : DIRECTIONAL HELIX 
// ══════════════════════════════════════════════════════════════════════════════
float eFast = trendMA == "SMA" ? ta.sma(close, trendFast) : ta.ema(close, trendFast)
float eSlow = trendMA == "SMA" ? ta.sma(close, trendSlow) : ta.ema(close, trendSlow)

bool trendBull = eFast > eSlow
bool trendBear = eFast < eSlow

color emaCol = trendBull ? color.new(colBull, 40) : color.new(colBear, 40)
plot(showEmas ? eFast : na, "Lead Filament",   color=emaCol, linewidth=2)
plot(showEmas ? eSlow : na, "Anchor Filament", color=color.new(colNeut, 50), linewidth=1)

// ══════════════════════════════════════════════════════════════════════════════
// MODULE 3 : PRESSURE REACTOR 
// ══════════════════════════════════════════════════════════════════════════════
float vR   = ta.sma(volume, 3) / ta.sma(volume, momVolPer)
float pChg = ta.change(close)
float vwM  = pChg * math.log(1 + vR * momVolSens)
float mF   = ta.ema(vwM, momFast)
float mS   = ta.ema(vwM, momSlow)
float mIdx = ta.ema(mF - mS, 5)
float mSig = ta.ema(mIdx, 12)

bool momBull = mIdx > mSig
bool momBear = mIdx < mSig

// ══════════════════════════════════════════════════════════════════════════════
// MODULE 4 : DEVIATION LATTICE 
// ══════════════════════════════════════════════════════════════════════════════
float bMean = ta.sma(close, bandZLen)
float bDev  = ta.stdev(close, bandZLen)
float bUp   = bMean + bDev * bandMult
float bDn   = bMean - bDev * bandMult
float bZ    = bDev != 0 ? (close - bMean) / bDev : 0.0

bool notOB = close < bUp
bool notOS = close > bDn

plot(showBands ? bUp : na,   "Lattice Ceiling", color=color.new(colBear, 65), linewidth=1)
plot(showBands ? bDn : na,   "Lattice Floor",   color=color.new(colBull, 65), linewidth=1)
plot(showBands ? bMean : na, "Lattice Spine",    color=color.new(colNeut, 65), linewidth=1, style=plot.style_cross)

// ══════════════════════════════════════════════════════════════════════════════
// MODULE 5 : FORTRESS GRID
// ══════════════════════════════════════════════════════════════════════════════
float lvlEma  = ta.ema(close, lvlEmaLen)
float topLvl  = lvlRound * math.ceil(lvlEma / lvlRound)
float botLvl  = lvlRound * math.floor(lvlEma / lvlRound)
float lvlGap  = topLvl - botLvl
float lvlTol  = lvlGap * lvlTolF

withinLvl(float price, float lvl) => price >= lvl - lvlTol and price <= lvl + lvlTol

plot(showLevels ? topLvl : na, "Ceiling Rail", color=color.new(colBear, 50), linewidth=1, style=plot.style_linebr)
plot(showLevels ? botLvl : na, "Floor Rail",   color=color.new(colBull, 50), linewidth=1, style=plot.style_linebr)

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME GATE
// ══════════════════════════════════════════════════════════════════════════════
float vgNow  = ta.sma(volume, 3)
float vgAvg  = ta.sma(volume, 14)
float vgRatio = vgAvg != 0 ? vgNow / vgAvg : 1.0
bool  volGateOK = useVolGate ? vgRatio >= volGateMul : true

// ══════════════════════════════════════════════════════════════════════════════
// CONVERGENCE SCORING & ENTRY CONDITIONS
// ══════════════════════════════════════════════════════════════════════════════
// Convergence score (0-100): weighted sum of aligned modules
float convScore = 0.0
float convMax   = 0.0

// Regime module (weight 25)
convMax += 25
if regime == 1 or regime == -1
    convScore += 25
else if not useRegime
    convScore += 25

// Trend module (weight 25)
convMax += 25
if trendBull or trendBear
    convScore += 25

// Momentum module (weight 25)
convMax += 25
if momBull or momBear
    convScore += 25

// Band module (weight 15)
convMax += 15
if notOB and notOS
    convScore += 15

// Volume gate (weight 10)
convMax += 10
if volGateOK
    convScore += 10

float convPct = convMax > 0 ? convScore / convMax * 100 : 0
string convLabel = convPct >= 90 ? "FULL LOCK" : convPct >= 70 ? "STRONG" : convPct >= 50 ? "PARTIAL" : "WEAK"

bool regimeOK  = useRegime ? (regime == 1 or regime == -1) : true
bool longConv  = regimeOK and trendBull and momBull and notOB and volGateOK and (useRegime ? regime == 1 : true)
bool shortConv = regimeOK and trendBear and momBear and notOS and volGateOK and (useRegime ? regime == -1 : true)

// Edge detection — global scope, one entry per transition
bool longEdge  = longConv  and not longConv[1]
bool shortEdge = shortConv and not shortConv[1]

// ══════════════════════════════════════════════════════════════════════════════
// RISK ARCHITECTURE : ATR SHIELD & OBJECTIVE
// ══════════════════════════════════════════════════════════════════════════════
float atrNow  = ta.atr(riskAtrLen)
float stopD   = atrNow * atrStopM
float tpD     = atrNow * atrTPM
float trailD  = atrNow * trailMult

// Trailing stop state
var float trailStop = na
var int   tradeAge  = 0

if strategy.position_size > 0
    tradeAge += 1
    float newTrail = close - trailD
    if useTrail
        trailStop := na(trailStop) ? newTrail : math.max(nz(trailStop), newTrail)
else if strategy.position_size < 0
    tradeAge += 1
    float newTrail = close + trailD
    if useTrail
        trailStop := na(trailStop) ? newTrail : math.min(nz(trailStop), newTrail)
else
    trailStop := na
    tradeAge  := 0

// ══════════════════════════════════════════════════════════════════════════════
// TRADE EXECUTION
// ══════════════════════════════════════════════════════════════════════════════
if longEdge
    strategy.entry("Long", strategy.long)
    strategy.exit("Long X", "Long", stop=close - stopD, limit=close + tpD)
    trailStop := na
    tradeAge  := 0

if shortEdge
    strategy.entry("Short", strategy.short)
    strategy.exit("Short X", "Short", stop=close + stopD, limit=close - tpD)
    trailStop := na
    tradeAge  := 0

// ── Trailing Shield Exit ──
if useTrail and not na(trailStop)
    if strategy.position_size > 0 and low <= trailStop
        strategy.close("Long", comment="Trail Shield")
    if strategy.position_size < 0 and high >= trailStop
        strategy.close("Short", comment="Trail Shield")

// ── Regime Arbiter Flip Exit ──
if strategy.position_size > 0 and regime == -1
    strategy.close("Long", comment="Regime Flip")
if strategy.position_size < 0 and regime == 1
    strategy.close("Short", comment="Regime Flip")

// ── Lattice Extreme Exit ──
if useBandExit
    if strategy.position_size > 0 and close >= bUp
        strategy.close("Long", comment="Lattice OB")
    if strategy.position_size < 0 and close <= bDn
        strategy.close("Short", comment="Lattice OS")

// ── Rail Interaction Exit ──
if useLvlExit
    if strategy.position_size > 0 and withinLvl(high, topLvl)
        strategy.close("Long", comment="Ceiling Rail")
    if strategy.position_size < 0 and withinLvl(low, botLvl)
        strategy.close("Short", comment="Floor Rail")

// ══════════════════════════════════════════════════════════════════════════════
// VISUAL : ENTRY MARKERS & TRAIL
// ══════════════════════════════════════════════════════════════════════════════
plotshape(longEdge,  "Long Signal",  shape.diamond, location.belowbar, color=color.new(colBull, 5), size=size.tiny)
plotshape(shortEdge, "Short Signal", shape.diamond, location.abovebar, color=color.new(colBear, 5), size=size.tiny)
plot(useTrail and not na(trailStop) and strategy.position_size != 0 ? trailStop : na, "Trail Shield", color=color.new(colVolat, 40), linewidth=1, style=plot.style_linebr)

// ══════════════════════════════════════════════════════════════════════════════
// COMMAND PANEL (DASHBOARD)
// ══════════════════════════════════════════════════════════════════════════════
color dashBg   = color.rgb(8, 8, 22, 5)
color dashBord = color.rgb(40, 40, 65)
color dashLbl  = color.rgb(120, 125, 155)
color dashDim  = color.rgb(75, 78, 100)

var table cceDash = table.new(position.top_right, 2, 13, bgcolor=dashBg, border_color=dashBord, border_width=1, frame_width=1, frame_color=dashBord)

if showDash and barstate.islast
    string regText = regime == 1 ? "KINETIC ASCENT" : regime == -1 ? "KINETIC DESCENT" : regime == 2 ? "TURBULENCE" : "EQUILIBRIUM"
    // Row 0 — Title
    table.cell(cceDash, 0, 0, "CCE",           text_color=regCol, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 0, "CONVERGENCE",   text_color=regCol, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 1 — Convergence Score
    color convCol = convPct >= 90 ? colBull : convPct >= 70 ? colBull : convPct >= 50 ? colVolat : colBear
    table.cell(cceDash, 0, 1, "SCORE",         text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 1, convLabel + " " + str.tostring(convPct, "#") + "%", text_color=convCol, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 2 — Regime
    table.cell(cceDash, 0, 2, "REGIME",        text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 2, regText,          text_color=regCol,  text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 3 — Helix
    table.cell(cceDash, 0, 3, "HELIX",         text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 3, trendBull ? "ASCENT" : "DESCENT", text_color=trendBull ? colBull : colBear, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 4 — Pressure
    table.cell(cceDash, 0, 4, "PRESSURE",      text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 4, momBull ? "ASCENT" : "DESCENT", text_color=momBull ? colBull : colBear, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 5 — Lattice
    table.cell(cceDash, 0, 5, "LATTICE",       text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    string latState = notOB and notOS ? "CLEAR" : close >= bUp ? "CEILING HIT" : "FLOOR HIT"
    color  latCol   = notOB and notOS ? colBull : colBear
    table.cell(cceDash, 1, 5, latState,         text_color=latCol, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 6 — Z-Score
    table.cell(cceDash, 0, 6, "Z-SCORE",       text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 6, str.tostring(bZ, "#.##"), text_color=bZ > 1 ? colBear : bZ < -1 ? colBull : colNeut, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 7 — Volume Gate
    table.cell(cceDash, 0, 7, "VOL GATE",      text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 7, volGateOK ? "OPEN " + str.tostring(vgRatio, "#.##") + "x" : "CLOSED", text_color=volGateOK ? colBull : dashDim, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 8 — Position
    table.cell(cceDash, 0, 8, "POSITION",      text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    string posText = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    color  posCol  = strategy.position_size > 0 ? colBull : strategy.position_size < 0 ? colBear : colNeut
    table.cell(cceDash, 1, 8, posText,          text_color=posCol, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 9 — Trade Age
    table.cell(cceDash, 0, 9, "AGE",           text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 9, strategy.position_size != 0 ? str.tostring(tradeAge) + " bars" : "-", text_color=dashDim, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 10 — Shield (Stop)
    table.cell(cceDash, 0, 10, "SHIELD",       text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 10, str.tostring(stopD, "#.##"), text_color=dashDim, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 11 — Trail
    table.cell(cceDash, 0, 11, "TRAIL",        text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 11, not na(trailStop) ? str.tostring(trailStop, "#.##") : "-", text_color=not na(trailStop) ? colVolat : dashDim, text_size=size.tiny, text_font_family=font.family_monospace)
    // Row 12 — Directional Bias
    table.cell(cceDash, 0, 12, "DIR BIAS",     text_color=dashLbl, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(cceDash, 1, 12, str.tostring(dirBias, "#.###"), text_color=dirBias > 0 ? colBull : colBear, text_size=size.tiny, text_font_family=font.family_monospace)
// ══════════════════════════════════════════════════════════════════════════════
````

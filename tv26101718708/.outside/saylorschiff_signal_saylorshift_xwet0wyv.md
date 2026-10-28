# Saylor-Schiff Signal [SaylorShift]

- url: https://www.tradingview.com/script/xwET0WYv-Saylor-Schiff-Signal-SaylorShift/
- type: indicator
- pine_id: PUB;dede0d75882b4e61a89ea9ad9f864507
- version: 1.0

## Description

SAYLORSCHIFT [Saylor-Schiff Macro Momentum Indicator]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The SaylorShift is a macro relative-momentum indicator designed to detect regime changes between digital store-of-value assets (Bitcoin) and traditional physical store-of-value reserves (Gold).

Named playfully after vocal Bitcoin bull Michael Saylor and renowned Gold advocate Peter Schiff, this script tracks capital rotation between the two macro assets to identify high-probability Risk-On (Saylor) and Risk-Off (Schiff) regimes.


RECOMMENDED TIMEFRAMES & CHART SETUP
────────────────────────────────────────

• Daily (1D) [Recommended] | Resolution: Weekly (W)
  Swing & Position Trading: Displays clean weekly regime steps against daily candles. Ideal for timing swing entries on pullbacks once a new weekly regime triggers.

• Weekly (1W) | Resolution: Weekly (W)
  Macro Allocation & Rebalancing: Best for long-term investors tracking quarterly and multi-year capital rotation between Bitcoin, Gold, and Cash reserves.

• 4-Hour (4H) or lower | Resolution: Weekly (W)
  Intraday Bias Filter: Use strictly as a macro directional guardrail — only taking long crypto setups during the Saylor (Risk-On) regime and adopting defensive/hedging tactics during the Schiff (Risk-Off) regime.

Execution Tip: For the most reliable signals, wait for the weekly candle close (Sunday UTC) to confirm macro transitions before executing new swing positions.


HOW IT WORKS
────────────────────────────────────────

• The Macro Ratio: Continuously tracks the price ratio of Bitcoin to Gold (INDEX:BTCUSD / TVC:GOLD).
• Multi-Timeframe Weekly ROC: Computes a weekly Rate of Change (ROC) on the ratio (default: 4-week lookback) to capture sustained macro liquidity flows while filtering daily market noise.
• State Machine Latch: Built-in state logic enforces strict Buy → Sell → Buy alternation, preventing double-triggers or conflicting signals during choppy regimes.
• Hysteresis Deadband: Uses a configurable threshold band (default: ±1.5%) around the zero line to eliminate whipsaws during tight consolidation phases.


SIGNAL LOGIC
────────────────────────────────────────

• BUY (Saylor Phase) 🟢 | Risk-On / BTC Outperformance
  The 4-week BTC/Gold ROC breaks cleanly above the upper threshold into positive territory. Confirms capital rotation favoring Bitcoin.

• SELL (Schiff Phase) 🔴 | Risk-Off / Gold Outperformance
  The 4-week BTC/Gold ROC breaks below the lower threshold into negative territory. Indicates capital rotation favoring Gold and defensive liquidity.


VISUAL FEATURES
────────────────────────────────────────

• Multi-Timeframe Synchronization: Lookbacks remain locked and flat across Daily or lower timeframe charts without mid-week data collapse or repainting.
• 4-Tone Momentum Histogram:
  - 🟢 Bright Green: Bullish acceleration
  - 🟢 Dark Green: Bullish momentum fading
  - 🔴 Bright Red: Bearish acceleration
  - 🔴 Dark Red: Bearish momentum fading
• Signal EMA Line: A 3-period smoothed signal line to visualize momentum trajectories.
• Regime Background Tint: Visual cues for active macro market regimes.


SETTINGS & CUSTOMIZATION
────────────────────────────────────────

• Asset Selection: Easily customize tickers (e.g., BINANCE:BTCUSDT, AMEX:GLD, OANDA:XAUUSD).
• Trigger Modes:
  - Threshold Deadband (Default): Filters noise via user-defined percentage bands (±1.5%).
  - Signal Line Cross (EMA): Triggers when the weekly ROC crosses its moving average.
  - Strict Zero-Cross: Triggers on raw zero-line crosses.
• Lookback & Smoothing: Fine-tune the weekly lookback period (default: 4) and EMA length (default: 3).


────────────────────────────────────────
Disclaimer: This indicator is designed for macro regime identification and educational purposes. Always use proper risk management and multi-factor confirmation before executing trades.

## Source Code

````pine
//@version=6
indicator("Saylor-Schiff Signal [SaylorShift]", shorttitle="SaylorShift", overlay=false, precision=2)

// --- Inputs ---
grp_assets  = "Asset Selection"
btcSymbol   = input.symbol("INDEX:BTCUSD", title="Bitcoin Symbol", group=grp_assets)
goldSymbol  = input.symbol("TVC:GOLD", title="Gold Symbol", group=grp_assets)

grp_params  = "Parameters & Smoothing"
tf          = input.timeframe("W", title="Resolution", group=grp_params)
rocLength   = input.int(4, title="ROC Lookback (Weekly Periods)", minval=1, group=grp_params)
smoothLen   = input.int(3, title="Signal Line EMA Length", minval=1, group=grp_params)

grp_filter  = "Noise Reduction"
filterMode  = input.string("Threshold Deadband", title="Trigger Mode", 
              options=["Threshold Deadband", "Signal Line Cross (EMA)", "Strict Zero-Cross"], group=grp_filter)
threshold   = input.float(1.5, title="Deadband Threshold (+/- %)", minval=0.0, step=0.5, group=grp_filter)

grp_ui      = "Display Settings"
showSignals = input.bool(true, title="Show Cross Signals", group=grp_ui)
showBg      = input.bool(true, title="Show Regime Background Tint", group=grp_ui)

// --- True Multi-Timeframe Weekly Calculation ---
// Fetch current and N-weeks-ago closes explicitly to guarantee flat, stable weekly metrics
btc_w       = request.security(btcSymbol, tf, close[0], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
gold_w      = request.security(goldSymbol, tf, close[0], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

btc_w_prev  = request.security(btcSymbol, tf, close[rocLength], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
gold_w_prev = request.security(goldSymbol, tf, close[rocLength], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Accurate Multi-Week ROC
ratioNow    = btc_w / nz(gold_w, 1)
ratioPast   = btc_w_prev / nz(gold_w_prev, 1)
rocVal      = not na(ratioPast) and ratioPast != 0 ? ((ratioNow - ratioPast) / ratioPast) * 100.0 : 0.0

// Stepwise Weekly Signal EMA
isNewTf = ta.change(time(tf)) != 0
var float sigEma = na
alpha = 2.0 / (smoothLen + 1.0)
if isNewTf or na(sigEma)
    sigEma := na(sigEma) ? rocVal : (alpha * rocVal + (1.0 - alpha) * nz(sigEma[1], rocVal))

// --- Noise-Filtered Conditions ---
bool rawBuy  = false
bool rawSell = false

if filterMode == "Threshold Deadband"
    rawBuy  := rocVal > threshold
    rawSell := rocVal < -threshold
else if filterMode == "Signal Line Cross (EMA)"
    rawBuy  := rocVal > sigEma
    rawSell := rocVal < sigEma
else // Strict Zero-Cross
    rawBuy  := rocVal > 0.0
    rawSell := rocVal < 0.0

// --- State Machine (Guarantees Strict Buy -> Sell -> Buy Alternation) ---
// 1 = Saylor (Bull), -1 = Schiff (Bear), 0 = Initializing
var int activeRegime = 0

buySignal  = isNewTf and rawBuy and (activeRegime != 1)
sellSignal = isNewTf and rawSell and (activeRegime != -1)

if buySignal
    activeRegime := 1
else if sellSignal
    activeRegime := -1

// --- 4-Tone Histogram Colors ---
c_bull_bright = #00E676
c_bull_dark   = #00796B
c_bear_bright = #FF5252
c_bear_dark   = #880E4F

histColor = rocVal >= 0 ? 
      (rocVal >= nz(rocVal[1]) ? c_bull_bright : c_bull_dark) : 
      (rocVal <= nz(rocVal[1]) ? c_bear_bright : c_bear_dark)

// --- Visual Plots ---
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// Upper/Lower Deadband boundaries (visible in Threshold mode)
h_upper = hline(filterMode == "Threshold Deadband" ? threshold : na, "Upper Threshold", color=color.new(color.green, 70), linestyle=hline.style_dotted)
h_lower = hline(filterMode == "Threshold Deadband" ? -threshold : na, "Lower Threshold", color=color.new(color.red, 70), linestyle=hline.style_dotted)
fill(h_upper, h_lower, color=color.new(color.gray, 95), title="Deadband Zone")

// Weekly Histogram & Signal EMA
plot(rocVal, title="Weekly BTC/Gold ROC (%)", color=color.new(histColor, 15), style=plot.style_columns)
plot(sigEma, title="Signal EMA", color=#FFD700, linewidth=2)

// Strict Alternating Signals
plotshape(showSignals and buySignal, title="Saylor Buy Signal", 
          style=shape.triangleup, location=location.bottom, 
          color=#00E676, size=size.small, text="BUY", textcolor=#00E676)

plotshape(showSignals and sellSignal, title="Schiff Sell Signal", 
          style=shape.triangledown, location=location.top, 
          color=#FF5252, size=size.small, text="SELL", textcolor=#FF5252)

// Regime Background Tint
bgcolor(showBg ? (activeRegime == 1 ? color.new(#00E676, 92) : activeRegime == -1 ? color.new(#FF5252, 92) : na) : na, title="Regime Background")

// --- Alerts ---
alertcondition(buySignal, title="Saylor Buy Alert", message="SaylorShift: New BUY Signal confirmed (Saylor Regime).")
alertcondition(sellSignal, title="Schiff Sell Alert", message="SaylorShift: New SELL Signal confirmed (Schiff Regime).")
````

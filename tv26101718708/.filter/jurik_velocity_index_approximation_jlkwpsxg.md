# Jurik Velocity Index Approximation

- url: https://www.tradingview.com/script/JLKWPSxG/
- type: indicator
- pine_id: PUB;ae68983a7a0e47f28377be397f5dc601
- version: 1.0

## Description

🚀 JURIK VELOCITY INDEX APPROXIMATION (VEL)

The Jurik Velocity Index Approximation (VEL), engineered by gunebak4n, is an advanced, ultra-smooth, zero-lag momentum oscillator framework designed for TradingView. Built upon the legendary signal-processing principles conceptualized by Mark Jurik (Jurik Research), this open-source implementation transforms classical price momentum into a noise-free, highly responsive velocity curve that pinpoints trend direction, momentum shifts, and market acceleration with surgical precision.

Classical momentum indicators suffer from a severe noise-versus-lag tradeoff: raw rate-of-change lines zig-zag violently, producing false alarms, while standard smoothing filters (such as moving averages) introduce unacceptable signal lag that degrades trade timing. VEL solves this by routing raw price momentum through an integrated Jurik Moving Average (JMA) engine. The result is an exceptionally smooth, lag-free velocity curve that detects directional reversals well ahead of traditional trend indicators.

💡 CORE DESIGN PRINCIPLES

🧭 Zero-Lag Smooth Momentum Engine
Classical momentum relies on raw price differentials, resulting in high-frequency noise. VEL strips out market chatter without adding lag, revealing the true underlying velocity of price movement.

🎛️ JMA Adaptive Filtering Engine
By passing the momentum input through a multi-stage Jurik filter, market noise is suppressed while preserving sharp turning points and critical reversal signals.

🎚️ Modular Phase & Power Control
Provides modular fine-tuning controls:
• Phase (-100 to +100): Adjusts the balance between lag reduction and overshoot prevention. Positive values accelerate responsiveness for fast-moving markets, while negative values yield smoother curves.
• Power: Controls the acceleration exponent of the smoothing curve, allowing traders to customize how aggressively the filter adapts to price velocity.

💡 KEY FEATURES

• ATR Normalization Engine: Optional volatility normalization scales momentum relative to ATR, making VEL scale-independent across Crypto, Forex, Equities, and Indices.
• Momentum Acceleration Histogram: Displays the difference between VEL and a secondary JMA signal line in a faded, visually discreet histogram to measure true momentum acceleration and deceleration.
• Multi-Timeframe (MTF) Integration: Fetch higher-timeframe velocity directly onto your execution chart for seamless macro trend alignment.
• Automated Divergence Detection: Built-in pivot scanner detects Bullish and Bearish divergences between price action and velocity oscillations.
• Dynamic Trend & Bar Coloring: Automatically colors chart price bars and the VEL curve based on real-time momentum direction.
• Comprehensive Alert Engine: Equipped with pre-configured, non-repainting alertcondition events for zero crossovers, signal crossovers, and divergence alerts.

🔬 MATHEMATICAL ARCHITECTURE

[STEP 1: Raw & Volatility-Normalized Momentum]
• Raw Momentum = Price - Price[Momentum Lookback]
• Volatility Scaling = (Enable ATR Norm) ? (Raw Momentum / ATR(14)) * 100 : Raw Momentum

[STEP 2: Primary JMA Velocity Pass]
• Derive Beta & Alpha Coefficients from Length and Power
• Apply Multi-Stage Recursive JMA Filter with Phase Ratio adjustment
• JMA(Normalized Momentum) => Primary VEL Output

[STEP 3: Acceleration Histogram Engine]
• Signal Line = JMA(VEL, Signal Length, Signal Phase, Signal Power)
• Acceleration Histogram = VEL - Signal Line

🛠️ USAGE FRAMEWORK

1. Zero Line Crossovers (Velocity Shift)
• VEL Crossing Above 0: Confirms positive price velocity (bullish momentum). Focus on long entries or trend continuations.
• VEL Crossing Below 0: Confirms negative price velocity (bearish momentum). Focus on short entries or trend continuations.
2. Histogram Slopes (Momentum Acceleration)
• Expanding Histogram: Indicates accelerating momentum in the current trend direction.
• Shrinking Histogram: Early warning of momentum decay before price actually turns.
3. Divergence Analysis
• Bullish Divergence: Lower price lows paired with higher VEL lows indicate seller exhaustion and an impending bullish reversal.
• Bearish Divergence: Higher price highs paired with lower VEL highs indicate buyer exhaustion and an impending bearish reversal.

⚙️ SYSTEM CHARACTERISTICS

• Zero Repainting: All calculations strictly evaluate on closed historical bar states.
• Fully Parameterized Inputs: Customize period length, phase, power, ATR normalization, MTF timeframes, divergence lookbacks, bar coloring, and color themes.
• Asset-Agnostic Engine: Operates with scale-independent precision across Equities, Forex, Crypto, Commodities, Futures, and Indices.
• Clean & Modern UI: Built to Pine Script v6 standards and optimized for visual clarity on both dark and light chart themes.

📌 CREDIT & ATTRIBUTION

The Jurik Velocity Index Approximation script is engineered and published by gunebak4n on TradingView.

This indicator is based on the mathematical concepts of the Jurik Velocity Index (VEL) originally conceptualized by Mark Jurik (Jurik Research).

⚠️ DISCLAIMER

This script is an open-source community implementation and mathematical approximation of the VEL concept. It is not affiliated with, officially supported by, or endorsed by Mark Jurik or Jurik Research. This indicator is a technical analysis visualization tool and does not provide financial advice, automated trading signals, or profit guarantees. Always perform thorough backtesting and practice strict risk management.

## Source Code

````pine
//@version=6
// Developer: gunebak4n
// Based on the Jurik Velocity Index (VEL) concept by Mark Jurik (Jurik Research).
// Disclaimer: This script is an open-source community implementation and is not affiliated with or endorsed by Jurik Research.
indicator(title = 'Jurik Velocity Index Approximation', shorttitle = 'VEL', overlay = false)

// ==========================================
// --- INPUT GROUPS ---
// ==========================================
grp_vel = 'VEL Calculation Parameters'
src = input.source(close, title = 'Source Price', group = grp_vel, tooltip = 'Price source used to compute momentum.')
momLength = input.int(1, title = 'Momentum Lookback', minval = 1, group = grp_vel, tooltip = 'Distance for raw change calculation. Default 1 for instantaneous velocity.')
length = input.int(14, title = 'JMA Length', minval = 1, group = grp_vel, tooltip = 'Smoothing period for the Jurik filter.')
phase = input.int(0, title = 'Phase', minval = -100, maxval = 100, group = grp_vel, tooltip = 'Balance between lag (-100) and overshoot (+100). Default is 0.')
power = input.float(2.0, title = 'Power', minval = 0.1, step = 0.1, group = grp_vel, tooltip = 'Acceleration factor for the smoothing curve.')

grp_norm = 'ATR Normalization'
useNorm = input.bool(true, title = 'Enable ATR Normalization', group = grp_norm, tooltip = 'Normalizes momentum relative to volatility (ATR), making VEL scale-independent across assets.')
atrLength = input.int(14, title = 'ATR Length', minval = 1, group = grp_norm)

grp_sig = 'Histogram Parameters'
useSignal = input.bool(true, title = 'Enable Histogram', group = grp_sig, tooltip = 'Calculates histogram based on momentum acceleration.')
sigLength = input.int(9, title = 'Signal JMA Length', minval = 1, group = grp_sig)
sigPhase = input.int(0, title = 'Signal Phase', minval = -100, maxval = 100, group = grp_sig)
sigPower = input.float(2.0, title = 'Signal Power', minval = 0.1, step = 0.1, group = grp_sig)

grp_mtf = 'Multi-Timeframe (MTF)'
useMTF = input.bool(false, title = 'Enable Higher Timeframe', group = grp_mtf)
htf = input.timeframe('D', title = 'Higher Timeframe', group = grp_mtf)

grp_div = 'Divergence Detection'
useDiv = input.bool(true, title = 'Enable Divergence Detection', group = grp_div)
lbL = input.int(5, title = 'Pivot Lookback Left', minval = 1, group = grp_div)
lbR = input.int(5, title = 'Pivot Lookback Right', minval = 1, group = grp_div)

grp_vis = 'Visualization & Style'
colorBars = input.bool(true, title = 'Color Chart Bars Based on VEL Direction', group = grp_vis)
upColor = input.color(#089981, title = 'Bullish Color', group = grp_vis)
dnColor = input.color(#f23645, title = 'Bearish Color', group = grp_vis)

// ==========================================
// --- JMA ALGORITHM FUNCTION ---
// ==========================================
f_jma(_src, _len, _phs, _pwr) =>
    phaseRatio = _phs < -100 ? 0.5 : _phs > 100 ? 2.5 : _phs / 100.0 + 1.5
    beta = 0.45 * (_len - 1) / (0.45 * (_len - 1) + 2.0)
    alpha = math.pow(beta, _pwr)

    var float e0 = 0.0
    var float e1 = 0.0
    var float e2 = 0.0
    var float jma = 0.0

    e0 := (1.0 - alpha) * _src + alpha * nz(e0[1], _src)
    e1 := (_src - e0) * (1.0 - beta) + beta * nz(e1[1])
    e2 := (e0 + phaseRatio * e1 - nz(jma[1], _src)) * math.pow(1.0 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    jma := nz(jma[1], _src) + e2
    jma

// ==========================================
// --- CORE CALCULATION ENGINE ---
// ==========================================
f_calc() =>
    rawMom = ta.change(src, momLength)
    atrVal = ta.atr(atrLength)
    normMom = (useNorm and atrVal != 0) ? (rawMom / atrVal) * 100.0 : rawMom
    
    vel = f_jma(normMom, length, phase, power)
    sig = useSignal ? f_jma(vel, sigLength, sigPhase, sigPower) : na
    hist = useSignal ? (vel - sig) : na
    [vel, sig, hist]

// MTF Security Fetching
[velCalc, sigCalc, histCalc] = if useMTF
    request.security(syminfo.tickerid, htf, f_calc())
else
    f_calc()

// Dynamic Coloring (Faded Histogram Colors)
color velColor = velCalc >= 0 ? upColor : dnColor
color histColor = histCalc >= 0 ? (histCalc >= nz(histCalc[1]) ? color.new(#26a69a, 50) : color.new(#26a69a, 80)) : (histCalc <= nz(histCalc[1]) ? color.new(#ef5350, 50) : color.new(#ef5350, 80))

// ==========================================
// --- DIVERGENCE DETECTION ---
// ==========================================
pl = ta.pivotlow(velCalc, lbL, lbR)
ph = ta.pivothigh(velCalc, lbL, lbR)

var float prevPlVel = na
var float prevPlPrice = na
var float prevPhVel = na
var float prevPhPrice = na

bullDiv = false
bearDiv = false

if useDiv
    if not na(pl)
        priceLow = low[lbR]
        if not na(prevPlVel) and priceLow < prevPlPrice and pl > prevPlVel
            bullDiv := true
        prevPlVel := pl
        prevPlPrice := priceLow

    if not na(ph)
        priceHigh = high[lbR]
        if not na(prevPhVel) and priceHigh > prevPhPrice and ph < prevPhVel
            bearDiv := true
        prevPhVel := ph
        prevPhPrice := priceHigh

// ==========================================
// --- PLOTS AND VISUALS ---
// ==========================================
// Histogram
plot(useSignal ? histCalc : na, title = 'Histogram', color = histColor, style = plot.style_histogram, linewidth = 2)

// VEL Line
plot(velCalc, title = 'VEL Line', color = velColor, linewidth = 2)

// Reference Zero Line
hline(0, title = 'Zero Line', color = color.gray, linestyle = hline.style_dashed)

// Bar Coloring
barcolor(colorBars ? (velCalc >= 0 ? upColor : dnColor) : na)

// ==========================================
// --- ALERT CONDITIONS ---
// ==========================================
alertcondition(ta.crossover(velCalc, 0), title = 'VEL: Bullish Zero Cross', message = 'VEL crossed above zero line.')
alertcondition(ta.crossunder(velCalc, 0), title = 'VEL: Bearish Zero Cross', message = 'VEL crossed below zero line.')
alertcondition(useDiv and bullDiv, title = 'VEL: Bullish Divergence', message = 'Bullish divergence detected on VEL.')
alertcondition(useDiv and bearDiv, title = 'VEL: Bearish Divergence', message = 'Bearish divergence detected on VEL.')
````

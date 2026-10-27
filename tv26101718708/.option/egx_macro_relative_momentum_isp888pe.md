# EGX Macro Relative Momentum

- url: https://www.tradingview.com/script/ISP888PE-EGX-Macro-Relative-Momentum/
- type: indicator
- pine_id: PUB;79eeeeb0b0b1434ca1fa8046dd210115
- version: 1.0

## Description

This is a macro momentum indicator that measures how the Egyptian stock market (EGX30) is performing relative to the USD/EGP exchange rate, essentially tracking whether local equities are outpacing currency devaluation or not.

Here's the breakdown by section:

Core Concept:
The indicator answers: "Is the stock market rising faster than the Egyptian Pound is falling against the Dollar?"

This matters because in country with currency volatility (like Egypt), nominal stock gains can be wiped out by currency devaluation.
This tool separates real market strength from currency-driven illusory gains.

Section-by-Section Explanation

Inputs:
EGX:EGX30 : The Egyptian stock market index
FX_IDC:USDEGP : USD to Egyptian Pound exchange rate
lookback : Rolling window for momentum accumulation (default: 20 bars) one month.

Calculations:
Rate of Change (ROC) Daily % change for both EGX30 and USD/EGP
Relative ROC: Subtracts currency movement from equity movement:
If EGX rises 2% and USD/EGP rises 1% → Relative ROC = +1% (market beating devaluation)
If EGX rises 2% and USD/EGP rises 3% → Relative ROC = -1% (market lagging devaluation)
Accumulation: Rolling sum of this relative momentum over your lookback period (smoothed via SMA × length)

Visualization:
Green histogram = Positive accumulated momentum (market strength exceeding currency pressure)
Red histogram = Negative accumulated momentum (market weakness or heavy devaluation pressure)
Background shading = Light green/red tint for quick visual context
Divergence Signals
Bullish divergence (▲): EGX rises while USD/EGP falls → Local market strength, currency recovery
Bearish divergence (▼): EGX falls while USD/EGP rises → Capital flight, devaluation stress

How to Read It:
Green bars rising: EGX is gaining real momentum beyond just currency effects, genuine bullish.
Red bars deepening: Market is selling off OR devaluation is outpacing any nominal gains, bearish.
Bullish divergence: Market rallying despite currency stability/strength, strong risk-on signal.
Bearish divergence: Market dropping while currency weakens, classic capital flight pattern.

Practical Use Cases:
Filtering trades: Only take long EGX positions when the indicator is green (positive relative momentum)
Macro regime detection: Sustained red bars suggest it's a "currency trade" not an "equity trade"
Your stock gains may not translate to real USD returns
Timing entries: Bullish divergences at support can signal capitulation; bearish divergences at resistance warn of exodus risk.

in options:
you can change EGX30 to EGX100: The indicator becomes more sensitive to the broad market health rather than just the banking/real state giants that dominate EGX30.
If you're trading smaller EGX names, EGX100 gives you better correlation to your actual universe.

Increasing Lookback from 20 → 60: Timeframe shift: On a daily chart, you're moving from ~1 month of accumulation to ~3 months.
Signal smoothing: The histogram becomes much slower and smoother, noisy daily wiggles get averaged out.
Lag increases: You'll detect macro trends later, but with higher conviction.

new update: 
✅ Switching between stocks won't change the indicator values
✅ Values update once daily at market close (or on your chosen timeframe)
✅ You can manually change the timeframe in the indicator settings (gear icon) if you want weekly or hourly momentum
✅ Consistent readings across your entire EGX watchlist
To Change Timeframe Manually
Click the gear icon on the EGX Macro Relative Momentum indicator
Change Timeframe to "W" (weekly), "60" (hourly), etc.
All stocks will use the same timeframe setting

## Source Code

````pine
//@version=6
indicator("EGX Macro Relative Momentum", overlay=false, precision=2)

// --- INPUTS ---
egx_ticker    = input.symbol("EGX:EGX30", "EGX 30 Source")
usde_ticker   = input.symbol("FX_IDC:USDEGP", "USD/EGP Source")
lookback      = input.int(20, "Accumulation Lookback", minval=1)
tf           = input.timeframe("D", "Timeframe")
show_div      = input.bool(true, "Show Divergence Signals")

// --- DATA FETCHING (Non-Repainting) ---
// Using request.security with [1] outside the call to ensure no repainting in historical bars.
// This fetches the confirmed close of the previous bar for the target symbols.
egx_close      = request.security(egx_ticker, tf, close[1], lookahead=barmerge.lookahead_off)
egx_prev_close = request.security(egx_ticker, tf, close[2], lookahead=barmerge.lookahead_off)

usde_close      = request.security(usde_ticker, tf, close[1], lookahead=barmerge.lookahead_off)
usde_prev_close = request.security(usde_ticker, tf, close[2], lookahead=barmerge.lookahead_off)

// --- CALCULATIONS ---

// 1. Daily Rate of Change (ROC)
// Formula: (Current - Previous) / Previous * 100
egx_roc  = ((egx_close - egx_prev_close) / egx_prev_close) * 100
usde_roc = ((usde_close - usde_prev_close) / usde_prev_close) * 100

// 2. Relative ROC
// Measures how much the stock market is outperforming or underperforming the currency devaluation
rel_roc = egx_roc - usde_roc

// 3. Accumulation over Lookback
// Using math.sum to track the rolling momentum over the specified period
accum_rel_roc = ta.sma(rel_roc, lookback) * lookback // SMA * length is a stable way to get sum

// --- VISUALIZATION ---

// Zero line for reference
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

// Histogram of Accumulated Relative ROC
hist_color = accum_rel_roc >= 0 ? color.new(color.green, 50) : color.new(color.red, 50)
plot(accum_rel_roc, "Accumulated Rel ROC", color=hist_color, style=plot.style_histogram, linewidth=2)

// Background coloring for context
bg_color = accum_rel_roc > 0 ? color.new(color.green, 95) : color.new(color.red, 95)
bgcolor(bg_color, title="Momentum Background")

// --- DIVERGENCE SIGNALS ---

// Bearish: Equities falling while USD/EGP is rising (Capital flight/Devaluation stress)
bear_div = egx_close < egx_prev_close and usde_close > usde_prev_close
// Bullish: Equities rising while USD/EGP is falling (Market strength/Currency recovery)
bull_div = egx_close > egx_prev_close and usde_close < usde_prev_close

// Plotting signals
plotshape(show_div and bull_div ? 0 : na, "Bullish Divergence", shape.triangleup, location.absolute, color.green, size=size.tiny, offset=-1)
plotshape(show_div and bear_div ? 0 : na, "Bearish Divergence", shape.triangledown, location.absolute, color.red, size=size.tiny, offset=-1)

// --- ALERTS ---

if bull_div
    alert("Bullish Macro Divergence: EGX30 Up / USDEGP Down", alert.freq_once_per_bar)

if bear_div
    alert("Bearish Macro Divergence: EGX30 Down / USDEGP Up", alert.freq_once_per_bar)

// alertcondition for manual setup
alertcondition(bull_div, "Bullish Divergence", "EGX Up / USD Down")
alertcondition(bear_div, "Bearish Divergence", "EGX Down / USD Up")
````

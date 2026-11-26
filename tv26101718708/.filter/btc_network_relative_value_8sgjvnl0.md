# BTC Network Relative Value

- url: https://www.tradingview.com/script/8SGJvNl0-BTC-Network-Relative-Value/
- type: indicator
- pine_id: PUB;deaef013faa8454392f42e00d47f9071
- version: 1.0

## Description

The BTC Network Relative Value (BTC-NRV) indicator is a macro-economic valuation framework designed to quantify Bitcoin’s market price against the intrinsic "work" being performed by the network. By shifting the focus from speculative price action to fundamental on-chain performance, this tool empowers investors to execute a data-driven Strategic Dollar Cost Averaging (SDCA) plan.

Why Relative Value Matters
Market price often deviates from network health due to sentiment, liquidity shocks, or macro cycles. This indicator acts as a "fair value" compass, utilizing a Z-Score methodology to normalize deviations. By measuring the price relative to the network's energy consumption (Hashrate), security (Difficulty), and mining profitability (Revenue), we can mathematically identify when Bitcoin is historically over- or under-priced.

Core On-Chain Data Pillars:
The indicator synthesizes three foundational network metrics into a singular valuation proxy:

Miner Revenue (MIREV): Reflects the total economic value extracted by the network (Block Rewards + Transaction Fees). It is a direct proxy for the "monetary demand" for network security.

Hashrate (HRATE): Serves as the ultimate indicator of the network's physical security and the long-term confidence of institutional-grade infrastructure providers.

Network Difficulty (DIFF): Acts as a protocol-level stabilizer, ensuring that our valuation metric is adjusted for the self-regulating nature of Bitcoin’s consensus mechanism.

Strategic Methodology:
Logarithmic Normalization: Bitcoin's exponential growth makes linear comparisons across different cycles (e.g., 2013 vs. 2025) inaccurate. The indicator applies logarithmic transformations to stabilize the variance, ensuring that a "top" in 2017 and a "top" in 2024 are comparable within the same oscillator bounds.

1-Year (52-Week) Z-Score: By utilizing a 1-year rolling lookback window on the Weekly (1W) timeframe, the indicator highlights how many standard deviations the current market price deviates from the mean network value.

Signal Smoothing: The 3-week moving average (smoothing) removes short-term on-chain noise, allowing investors to focus on the macro-trend rather than daily volatility.

SDCA Execution Framework (How to use):
The oscillator provides specific zones for long-term strategic planning:

Zone -2.0 SD and below (Green): Strategic Accumulation. Historically represents macro-level capitulation. This is the optimal window for aggressive capital deployment as the asset is deeply undervalued relative to network security.

Zone -1.0 to -2.0 SD (Light Green): Favorable Value. An undervalued state suitable for building core positions.

Zone -1.0 to +1.0 SD (Gray): Equilibrium. The market is trading at "Fair Value" relative to its network input. Maintain your standard, scheduled DCA.

Zone +1.0 to +2.0 SD (Orange): Cautionary Zone. The asset is becoming over-extended relative to network fundamentals.

Zone +2.0 SD and above (Red): Profit Realization / Pause. Historically marks speculative mania and macro cycle tops. Prudent investors often pause accumulation here or begin scaling out to realize gains.

Technical Recommendations:
Timeframe: Optimized for the Weekly (1W) chart for macro-cycle analysis.

Lookback: Set to 52 for 1-year macro alignment.

Smoothing: 3 to filter out mining-related data spikes.

Disclaimer: This indicator is for educational and strategic planning purposes only. It is not financial advice. On-chain data is sourced from external providers (Quandl) and may be subject to minor API latencies.

## Source Code

````pine
//@version=6
indicator("BTC Network Relative Value", shorttitle="BTC-NRV", overlay=false, precision=2)

// ==========================================
// 1. SETTINGS & DATA SOURCES (Optimized for 1W)
// ==========================================
lookback   = input.int(52, title="Z-Score Period (Weeks)", minval=10)
smooth_len = input.int(3, title="Smoothing Period (Weeks)", minval=1)

// On-Chain Data Sources (Quandl)
symbol_mirev    = input.symbol("QUANDL:BCHAIN/MIREV", title="Miner Revenue (Rewards + Fees USD)")
symbol_hashrate = input.symbol("QUANDL:BCHAIN/HRATE", title="Hashrate (TH/s)")
symbol_diff     = input.symbol("QUANDL:BCHAIN/DIFF",  title="Network Difficulty")

// Request daily data
mirev    = request.security(symbol_mirev, "D", close, ignore_invalid_symbol=true)
hashrate = request.security(symbol_hashrate, "D", close, ignore_invalid_symbol=true)
diff     = request.security(symbol_diff, "D", close, ignore_invalid_symbol=true)

// ==========================================
// 2. COMPREHENSIVE NETWORK INVESTMENT METRIC
// ==========================================
net_activity  = nz(mirev, 1) * nz(hashrate, 1)
net_security  = net_activity / math.max(nz(diff, 1), 1)
invest_metric = math.sqrt(math.abs(net_security))

raw_ratio = invest_metric > 0 ? (close / invest_metric) : close
log_ratio = math.log(raw_ratio)

// Apply Smoothing
ratio = ta.sma(log_ratio, smooth_len)

// ==========================================
// 3. Z-SCORE CALCULATION
// ==========================================
mean    = ta.sma(ratio, lookback)
stddev  = ta.stdev(ratio, lookback)
z_score = stddev != 0 ? (ratio - mean) / stddev : 0.0

// ==========================================
// 4. STRATEGIC DCA ZONES & VISUALIZATION
// ==========================================
bool is_strong_buy = z_score <= -2.0
bool is_buy        = z_score > -2.0 and z_score <= -1.0
bool is_warning    = z_score >= 1.0 and z_score < 2.0
bool is_pause_sell = z_score >= 2.0

color z_color = is_pause_sell ? color.red : is_warning ? color.orange : is_strong_buy ? color.green : is_buy ? color.lime : color.gray
plot(z_score, title="Z-Score", color=z_color, linewidth=2)

// Level Lines
h_top2 = hline(2.0,  title="Pause DCA / Take Profit (+2 SD)", color=color.red, linestyle=hline.style_dashed)
h_top1 = hline(1.0,  title="Warning (+1 SD)", color=color.orange, linestyle=hline.style_dotted)
h_zero = hline(0.0,  title="Fair Value / Standard DCA (0 SD)", color=color.gray, linestyle=hline.style_solid)
h_bot1 = hline(-1.0, title="Moderate DCA (-1 SD)", color=color.lime, linestyle=hline.style_dotted)
h_bot2 = hline(-2.0, title="Strategic Accumulation / Cycle Bottom (-2 SD)", color=color.green, linestyle=hline.style_dashed)

// Shaded Backgrounds
fill(h_bot2, hline(-4.0, display=display.none), color=color.new(color.green, 85), title="Strategic Accumulation Zone")
fill(h_top2, hline(4.0, display=display.none), color=color.new(color.red, 85), title="Pause Zone")

// Histogram
color dca_hist_color = is_strong_buy ? color.new(color.green, 30) : is_buy ? color.new(color.lime, 50) : is_pause_sell ? color.new(color.red, 30) : color.new(color.gray, 80)
plot(z_score, style=plot.style_columns, color=dca_hist_color, title="Strategic DCA Intensity")

// ==========================================
// 5. ALERTS
// ==========================================
alertcondition(is_strong_buy and not is_strong_buy[1], title="🔥 1W SDCA: Strategic Buy", message="BTC is deeply undervalued on 1W chart (Z-Score < -2). Strategic accumulation time!")
alertcondition(is_pause_sell and not is_pause_sell[1], title="🛑 1W SDCA: Pause/Sell", message="BTC is highly overvalued on 1W chart (Z-Score > +2). Pause strategic DCA or take profit.")
````

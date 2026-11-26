# Miner Profitability Index | Astral Vision 

- url: https://www.tradingview.com/script/UG3fkMNw/
- type: indicator
- pine_id: PUB;831ba9f87fa346a9b5eb2b71f398fd5f
- version: 1.0

## Description

[b]Miner Profitability Index | Astral Vision 🌠💠[/b]

This indicator constructs a measure of Bitcoin miner profitability per unit of mining difficulty, then applies Z-Score normalization in log space to quantify how statistically extreme current profitability conditions are relative to their own history. Miner profitability is a structurally important on-chain signal because miners are one of the few participants with predictable and measurable cost structures: when profitability collapses, miners are forced to sell reserves to cover operational costs, creating persistent sell pressure; when profitability is exceptionally high, miners tend to accumulate and expand capacity, which historically precedes periods of increased hash rate and eventually difficulty adjustment that compresses margins back toward equilibrium.

[b]Calculation ⚙️[/b]

The daily miner revenue in USD is computed from three components: the number of blocks mined that day (computed as the difference between consecutive daily block height readings from Glassnode), the block subsidy in BTC (derived from the block height using the halving schedule: 50 BTC before block 210,000, halving at each subsequent 210,000-block interval), and the current Bitcoin price in USD. The formula is: miner revenue = blocks per day × block reward × BTC price.

This revenue figure is then divided by the current mining difficulty to produce the efficiency ratio: miner revenue / difficulty. Difficulty represents the computational work required to mine a block and serves as a proxy for the aggregate energy and capital expenditure of the mining network. Dividing revenue by difficulty produces a measure of how many dollars miners earn per unit of computational difficulty, normalizing for the expanding size of the mining network over time. Without this normalization, absolute revenue would grow indefinitely simply due to price appreciation and hash rate expansion, making historical comparisons meaningless.

The efficiency ratio is smoothed with a configurable EMA to reduce the noise introduced by day-to-day variation in block count. The natural logarithm is then taken before applying the Z-Score, which is necessary because the efficiency ratio follows an approximately log-normal distribution: in raw space it would be heavily right-skewed, making the standard deviation an unreliable measure of typical deviation. In log space the distribution is much more symmetric and the Z-Score thresholds carry consistent statistical meaning across all periods.

The Z-Score is computed as: (log(efficiency) - SMA(log(efficiency), N)) / StDev(log(efficiency), N), where N is the configurable lookback window. This expresses how many standard deviations the current log-efficiency sits above or below its rolling historical mean. Two pairs of thresholds define moderate and severe extreme zones on each side.

[b]Plots 📊[/b]
[list]
[*]Z-Score oscillator colored by zone: two upper levels and two lower levels with graduated opacity
[*]Two upper and two lower threshold lines
[*]Zero midline
[*]Fill highlights when Z-Score is beyond the outer thresholds
[*]Static zone fills between inner and outer thresholds on both sides
[*]Background color on the price chart with four gradient levels reflecting zone severity
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Z-Score Lookback: rolling window for mean and standard deviation normalization
[*]Smoothing: EMA period applied to the raw efficiency ratio before log transformation
[*]Upper Z 1 and Upper Z 2: configurable inner and outer upper threshold levels
[*]Lower Z 1 and Lower Z 2: configurable inner and outer lower threshold levels
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura.

[b]Purpose 🎯[/b]
Standard miner revenue charts display absolute USD earnings, which grow indefinitely with price and provide no statistical context for whether current conditions are extreme or normal. Dividing by difficulty removes the network size effect, and normalizing with a Z-Score in log space makes readings directly comparable across all market cycles including early periods when absolute revenue was tiny. The dual threshold system separates mild deviations from statistically severe conditions, providing a more granular signal than a single overbought/oversold level.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Miner Profitability Index | Astral Vision 🌠💠", overlay=false, max_bars_back=500)

group1 = "Settings"
group2 = "Astral Colors"

int   z_len     = input.int(500,   "Z-Score Lookback",  minval=10,  group=group1)
int   smooth    = input.int(10,     "Smoothing",         minval=1,   group=group1)
float m_top1    = input.float(1.9,  "Upper Z 1", step=0.1, group=group1)
float m_top2    = input.float(2.3,  "Upper Z 2", step=0.1, group=group1)
float m_bot1    = input.float(-2.2, "Lower Z 1", step=0.1, group=group1)
float m_bot2    = input.float(-2.5, "Lower Z 2", step=0.1, group=group1)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.green, "Custom Positive", group=group2)
color  custom_neg = input.color(color.red,   "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos : theme == "Inferno" ? color.rgb(255,0,0) : theme == "Paradiso" ? color.rgb(0,210,255) : theme == "Futura" ? color.rgb(0,255,180) : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
color neg_col = usecustom ? custom_neg : theme == "Inferno" ? color.rgb(120,0,0) : theme == "Paradiso" ? color.rgb(0,80,160)  : theme == "Futura" ? color.rgb(180,0,255)  : theme == "Infinito" ? color.rgb(255,220,80)  : color.rgb(0,180,120)
color neu_col = color.rgb(120,120,120)

float btc          = request.security("INDEX:BTCUSD",           "D", close)
float block_height = request.security("GLASSNODE:BTC_BLOCKS",   "D", close)
float hashrate     = request.security("GLASSNODE:BTC_HASHRATE",  "D", close)
float difficulty   = request.security("GLASSNODE:BTC_DIFFICULTY","D", close)

float blocks_per_day     = math.max(block_height - block_height[1], 0)
float reward             = block_height < 210000 ? 50.0 : block_height < 420000 ? 25.0 : block_height < 630000 ? 12.5 : block_height < 840000 ? 6.25 : 3.125
float miner_revenue      = blocks_per_day * reward * btc
float efficiency         = difficulty > 0 ? miner_revenue / difficulty : na
float efficiency_smooth  = ta.ema(efficiency, smooth)

float log_eff = math.log(efficiency_smooth)
float mean_e  = ta.sma(log_eff, z_len)
float std_e   = ta.stdev(log_eff, z_len)
float zscore  = std_e != 0 ? (log_eff - mean_e) / std_e : 0.0

bool above_top2 = zscore > m_top2
bool above_top1 = zscore > m_top1
bool below_bot2 = zscore < m_bot2
bool below_bot1 = zscore < m_bot1

color line_col   = above_top2 ? pos_col : above_top1 ? color.new(pos_col, 40) : below_bot2 ? neg_col : below_bot1 ? color.new(neg_col, 40) : neu_col
color candle_col = above_top2 ? pos_col : above_top1 ? color.new(pos_col, 40) : below_bot2 ? neg_col : below_bot1 ? color.new(neg_col, 40) : color.black

p_main = plot(zscore,  color=line_col, linewidth=2)
p_top2 = plot(m_top2,  color=color.new(pos_col, 0),  linewidth=2)
p_top1 = plot(m_top1,  color=color.new(pos_col, 40), linewidth=1)
p_mid  = plot(0.0,     color=color.new(neu_col, 60),  linewidth=1)
p_bot1 = plot(m_bot1,  color=color.new(neg_col, 40), linewidth=1)
p_bot2 = plot(m_bot2,  color=color.new(neg_col, 0),  linewidth=2)

fill(p_main, p_top2, color=above_top2 ? color.new(pos_col, 60) : na)
fill(p_main, p_bot2, color=below_bot2 ? color.new(neg_col, 60) : na)
fill(p_top1, p_top2, color=color.new(pos_col, 92))
fill(p_bot1, p_bot2, color=color.new(neg_col, 92))

bgcolor(above_top2 ? color.new(pos_col, 40) : above_top1 ? color.new(pos_col, 60) : below_bot2 ? color.new(neg_col, 40) : below_bot1 ? color.new(neg_col, 60) : na, force_overlay=true)
````

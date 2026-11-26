# Thermocap Z-Score | Astral Vision 

- url: https://www.tradingview.com/script/TrVP05RG/
- type: indicator
- pine_id: PUB;d07f038c53bd42eaae9feb39112d3b01
- version: 1.0

## Description

[b]Thermocap Z-Score | Astral Vision 🌠💠[/b]

Thermocap measures the total cumulative USD value of all Bitcoin ever issued to miners: the aggregate amount of real capital that has flowed into the network through block rewards since genesis. 
It represents the minimum provable economic cost of Bitcoin's entire issuance history, making it a fundamental anchor for long-term valuation.

The Thermocap Multiple divides BTC price by Thermocap, expressing how many times over the market is currently valuing Bitcoin relative to the total capital miners have ever extracted from it. Historically, extreme multiple values have marked cycle tops and bottoms with high consistency. This indicator standardizes the multiple in log space over a rolling window, producing a Z-Score that makes those extremes statistically comparable across all cycles regardless of Bitcoin's absolute price or the compounding growth of Thermocap itself.

[b]Calculation ⚙️[/b]

`Daily Issuance USD = blocks_mined_today × block_reward × BTC price`

`Thermocap = cumulative sum of Daily Issuance USD / 1,000,000,000`

`Multiple = BTC price / Thermocap`

`Z-Score = (log(Multiple) − SMA(log(Multiple), length)) / StdDev(log(Multiple), length)`

Block reward is derived directly from the current block height, stepping through the four halvings programmatically. Log transformation is applied before standardization to compress the exponential growth of the multiple into a cycle-comparable range.

[b]Plots 📊[/b]
[list]
[*]Z-Score line in the indicator panel, colored by active regime
[*]Two upper threshold lines (Upper Z1 and Z2) at decreasing transparency (Z2 is the extreme ceiling)
[*]Two lower threshold lines (Lower Z1 and Z2) at decreasing transparency (Z2 is the extreme floor)
[*]Zero midline
[*]Fill between Z-Score and Upper Z2 when breached (distribution zone)
[*]Fill between Z-Score and Lower Z2 when breached (accumulation zone)
[*]Candle coloring on the price chart by active regime
[*]Background highlight on the price chart when Z2 thresholds are breached
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Z-Score Lookback`: rolling window for mean and standard deviation calculation (default 730)
[*]`Upper Z1 / Z2`: two overbought threshold levels, Z2 marking the extreme (defaults 2.3 / 2.8)
[*]`Lower Z1 / Z2`: two oversold threshold levels, Z2 marking the extreme (defaults −1.5 / −1.8)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Futura. 
Positive color activates at both lower thresholds; negative color activates at both upper thresholds. Z2 lines are fully opaque; Z1 lines are semi-transparent, creating a visual gradient of intensity toward the extreme.

[b]Purpose 🎯[/b]

Raw Thermocap Multiple charts plot an exponentially growing series that becomes visually unreadable across multiple cycles, and fixed multiple thresholds lose relevance as the cumulative issuance base compounds. 
The standard approach of using static bands like "×30 = top" breaks down as Thermocap itself grows.

This indicator solves both problems simultaneously: log transformation removes the exponential trend, and rolling Z-Score standardization makes every cycle's extremes directly comparable using the same statistical distance from the mean. 
The dual-threshold structure (Z1 and Z2) provides an early warning level and a confirmed extreme level, letting traders distinguish between elevated readings and genuinely historic deviations: a distinction that single-threshold implementations cannot make.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("Thermocap Z-Score | Astral Vision 🌠💠", overlay=false, max_bars_back=500)

group1 = "Settings"
group2 = "Visualization"
group3 = "Astral Colors"

int   z_len     = input.int(730,  "Z-Score Lookback",  minval=100, group=group1)
float m_top1    = input.float(2.3,  "Upper Z 1", step=0.1, group=group1)
float m_top2    = input.float(2.8,  "Upper Z 2", step=0.1, group=group1)
float m_bot1    = input.float(-1.5, "Lower Z 1", step=0.1, group=group1)
float m_bot2    = input.float(-1.8, "Lower Z 2", step=0.1, group=group1)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.green, "Custom Positive", group=group3)
color  custom_neg = input.color(color.red,   "Custom Negative", group=group3)

color pos_col = usecustom ? custom_pos : theme == "Inferno" ? color.rgb(255,0,0) : theme == "Paradiso" ? color.rgb(0,210,255) : theme == "Futura" ? color.rgb(0,255,180) : theme == "Infinito" ? color.rgb(180,120,255) : color.rgb(255,160,0)
color neg_col = usecustom ? custom_neg : theme == "Inferno" ? color.rgb(120,0,0) : theme == "Paradiso" ? color.rgb(0,80,160)  : theme == "Futura" ? color.rgb(180,0,255)  : theme == "Infinito" ? color.rgb(255,220,80)  : color.rgb(0,180,120)
color neu_col = color.rgb(120,120,120)
color blk_col = color.black

float btc          = request.security("INDEX:BTCUSD",          "D", close)
float block_height = request.security("GLASSNODE:BTC_BLOCKS",  "D", close)

float blocks_per_day     = math.max(block_height - block_height[1], 0)
float reward             = block_height < 210000 ? 50.0 : block_height < 420000 ? 25.0 : block_height < 630000 ? 12.5 : block_height < 840000 ? 6.25 : 3.125
float daily_issuance_usd = blocks_per_day * reward * btc
float thermocap_b        = ta.cum(daily_issuance_usd) / 1e9
float multiple           = btc / thermocap_b

float log_mult = math.log(multiple)
float mean_m   = ta.sma(log_mult, z_len)
float std_m    = ta.stdev(log_mult, z_len)
float zscore   = std_m != 0 ? (log_mult - mean_m) / std_m : 0.0

color candle_col = zscore > m_top2 ? pos_col : zscore > m_top1 ? pos_col : zscore < m_bot2 ? neg_col : zscore < m_bot1 ? neg_col : blk_col
color line_col   = zscore > m_top2 ? pos_col : zscore > m_top1 ? pos_col : zscore < m_bot2 ? neg_col : zscore < m_bot1 ? neg_col : neu_col
color bgcol      = zscore > m_top2 ? color.new(pos_col,50) : zscore < m_bot2 ? color.new(neg_col,50) : na

p_main = plot(zscore, color=line_col, linewidth=2)
p_top2 = plot(m_top2, color=color.new(pos_col, 0),  linewidth=2)
p_top1 = plot(m_top1, color=color.new(pos_col, 40), linewidth=1)
p_mid  = plot(0,      color=color.new(neu_col, 60),  linewidth=1)
p_bot1 = plot(m_bot1, color=color.new(neg_col, 40), linewidth=1)
p_bot2 = plot(m_bot2, color=color.new(neg_col, 0),  linewidth=2)

fill(p_main, p_top2, color=zscore > m_top2 ? color.new(pos_col, 40) : na)
fill(p_main, p_bot2, color=zscore < m_bot2 ? color.new(neg_col, 40) : na)


plotcandle(open, high, low, close, color=candle_col, wickcolor=candle_col, bordercolor=candle_col, force_overlay=true)

bgcolor(bgcol, force_overlay = true)
````

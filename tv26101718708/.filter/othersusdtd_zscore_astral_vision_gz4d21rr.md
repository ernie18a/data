# OTHERS/USDT.D Z-Score | Astral Vision 

- url: https://www.tradingview.com/script/gZ4D21Rr/
- type: indicator
- pine_id: PUB;42afbf4a4e144015ac478f3fb976ed39
- version: 1.0

## Description

[b]OTHERS/USDT.D Z-Score | Astral Vision 🌠💠[/b]

This indicator constructs a ratio between the OTHERS market cap dominance and USDT dominance, then applies Z-Score normalization in log space to measure how statistically extreme the current positioning of altcoin capital relative to stablecoin dry powder is compared to its own history. 
OTHERS dominance tracks the combined market cap share of all cryptocurrencies excluding Bitcoin, Ethereum, and the top few large caps, making it a direct proxy for altcoin season conditions. USDT dominance measures the share of total crypto market cap held in Tether, which rises when capital exits risk assets into stablecoins and falls when stablecoin capital is deployed into crypto assets.

[b]Calculation ⚙️[/b]

The ratio is computed as OTHERS dominance divided by USDT dominance on a daily timeframe. A high ratio means altcoin capital is large relative to stablecoin reserves, indicating that available dry powder has been deployed and the altcoin market is extended. A low ratio means stablecoin dominance is high relative to altcoin exposure, indicating that capital has retreated to safety and dry powder is accumulating.

The natural logarithm of this ratio is then taken before all subsequent calculations. Working in log space normalizes the exponential growth of both series across different market cycles, ensuring that a ratio change from 2 to 4 is treated as equivalent in magnitude to a change from 4 to 8, which is the correct treatment for proportional dominance relationships.

A simple moving average and standard deviation are computed over the configurable Z-Score lookback window, producing the Z-Score as: (log ratio minus mean) / standard deviation. This expresses the current ratio in units of standard deviations above or below its own historical average, making readings directly comparable across cycles regardless of the absolute dominance levels involved.

In Trend mode, an EMA of configurable length is applied to the Z-Score itself, functioning as a signal line. When the Z-Score is above its EMA, the momentum of the ratio is positive and altcoin conditions are improving relative to stablecoin reserves; when below, the momentum is negative.

[b]Plots 📊[/b]
[list]
[*]Z-Score oscillator colored by mode and regime
[*]Two upper threshold lines marking statistically elevated altcoin exposure (Extremes mode)
[*]Two lower threshold lines marking statistically depressed altcoin exposure (Extremes mode)
[*]Fill highlights when Z-Score enters the outer extreme zones
[*]Zero baseline
[*]EMA signal line (Trend mode)
[*]Background color on the price chart when Z-Score enters the outer extreme zones (Extremes mode)
[*]Candle coloring on the price chart reflecting current regime in both modes
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Visualization: Extremes or Trend
[*]Z-Score Lookback: normalization window for mean and standard deviation
[*]Upper Z 1 and Upper Z 2: configurable inner and outer upper threshold levels
[*]Lower Z 1 and Lower Z 2: configurable inner and outer lower threshold levels
[*]EMA Length: smoothing period for the trend signal line (Trend mode)
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura.

[b]Purpose 🎯[/b]
Standard altcoin season indicators use fixed dominance thresholds or simple moving average crossovers on raw dominance values, which are not statistically normalized and behave differently across cycles as the total crypto market cap grows. This indicator normalizes the ratio in log space over a long rolling window, making a Z-Score of +2.0 in 2021 and a Z-Score of +2.0 in 2024 carry equivalent statistical weight despite the absolute dominance percentages being different. The dual threshold system further separates moderate elevated conditions from statistically severe ones, allowing a more nuanced reading than a single overbought/oversold line can provide.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("OTHERS/USDT.D Z-Score | Astral Vision 🌠💠", overlay=false, max_bars_back=500)

group1 = "Settings"
group2 = "Astral Colors"

string vismode  = input.string("Extremes", "Visualization", options=["Extremes","Trend"], group=group1)
int   z_len     = input.int(730,   "Z-Score Lookback", minval=100, group=group1)
float m_top1    = input.float(2.0,  "Upper Z 1", step=0.1, group=group1)
float m_top2    = input.float(3.0,  "Upper Z 2", step=0.1, group=group1)
float m_bot1    = input.float(-1.3, "Lower Z 1", step=0.1, group=group1)
float m_bot2    = input.float(-1.6, "Lower Z 2", step=0.1, group=group1)
int   ema_len   = input.int(200, "EMA Length (Trend)", minval=1, group=group1)

string theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.green, "Custom Positive", group=group2)
color  custom_neg = input.color(color.red,   "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
                           color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
                           color.rgb(0,180,120)


float others    = request.security("CRYPTOCAP:OTHERS", "D", close)
float usdtd     = request.security("CRYPTOCAP:USDT.D", "D", close)

float ratio     = usdtd != 0 ? others / usdtd : na
float log_ratio = math.log(ratio)
float mean_r    = ta.sma(log_ratio, z_len)
float std_r     = ta.stdev(log_ratio, z_len)
float zscore    = std_r != 0 ? (log_ratio - mean_r) / std_r : 0.0
float ema_osc   = ta.ema(zscore, ema_len)

bool is_ext   = vismode == "Extremes"
bool is_trend = vismode == "Trend"
bool above_ema = zscore > ema_osc

color trend_col   = above_ema ? pos_col : neg_col
color ext_line    = zscore > m_top2 ? neg_col : zscore > m_top1 ? neg_col : zscore < m_bot2 ? pos_col : zscore < m_bot1 ? pos_col : color.black
color ext_candle  = zscore > m_top2 ? neg_col : zscore > m_top1 ? neg_col : zscore < m_bot2 ? pos_col : zscore < m_bot1 ? pos_col : color.black
color trend_candle = above_ema ? pos_col : neg_col

color line_col   = is_ext ? ext_line   : trend_col
color candle_col = is_ext ? ext_candle : trend_candle
color ema_col    = is_ext ? color.black    : trend_col

color bgcol = zscore > m_top2 ? color.new(neg_col, 50) : zscore < m_bot2 ? color.new(pos_col, 50) : na

p_main = plot(zscore, color=line_col, linewidth=2)
p_ema  = plot(is_trend ? ema_osc : na, "EMA", color=ema_col, linewidth=2)
p_top2 = plot(is_ext ? m_top2 : na, color=neg_col, linewidth=2)
p_top1 = plot(is_ext ? m_top1 : na, color=neg_col, linewidth=1)
p_mid  = plot(0,      color=color.new(color.black, 60), linewidth=1)
p_bot1 = plot(is_ext ? m_bot1 : na, color=pos_col, linewidth=1)
p_bot2 = plot(is_ext ? m_bot2 : na, color=pos_col, linewidth=2)

fill(p_main, p_top2, color=is_ext and zscore > m_top2 ? color.new(neg_col, 50) : na)
fill(p_main, p_bot2, color=is_ext and zscore < m_bot2 ? color.new(pos_col, 50) : na)


plotcandle(open, high, low, close, color=candle_col, wickcolor=candle_col, bordercolor=candle_col, force_overlay=true)
bgcolor(is_ext ? bgcol : na, force_overlay=true)
````

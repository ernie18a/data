# Difficulty per Issuance - PoW Pricing Model | Astral Vision 

- url: https://www.tradingview.com/script/KBZ0L1eW/
- type: indicator
- pine_id: PUB;65d97ae0987e41bb9475b5081e33be79
- version: 1.0

## Description

[b]Difficulty per Issuance - PoW Pricing Model | Astral Vision 🌠💠[/b]

This indicator derives a fundamental price floor for Bitcoin from the relationship between mining difficulty and coin issuance, using the proof-of-work mechanism itself as the pricing oracle. The core premise is that the difficulty of mining a block represents the aggregate computational and economic effort the network expends to produce Bitcoin, while the issuance represents what the network produces in return. The ratio between these two quantities, with a damping correction for the non-linear scaling of difficulty, produces a model price that reflects the cost of production in computational terms rather than in fiat currency.

[b]Calculation ⚙️[/b]

The mining difficulty is smoothed with a configurable simple moving average to remove the noise from individual difficulty adjustments, which occur approximately every two weeks and can jump or drop abruptly. The smoothed difficulty is then raised to a configurable power k using the exponential of k times the natural log of difficulty, which is mathematically equivalent to difficulty^k. The exponent k is the damping coefficient: a value of 1.0 would mean difficulty scales linearly with the model price, but empirically the relationship is sub-linear, meaning that doubling difficulty does not double the cost per coin proportionally. Values around 0.4 have historically produced the tightest fit to Bitcoin's long-term price floor.

The issuance is computed as the daily block reward in BTC multiplied by 144 blocks per day, using the halving schedule to determine the correct subsidy at each point in history: 50 BTC per block before the first halving in November 2012, halving at each subsequent 210,000-block interval to 25, 12.5, 6.25, and 3.125 BTC. This daily issuance is summed over a configurable rolling window to smooth the effect of halving step-changes, which would otherwise create discontinuities in the model output. The base model price is then: a × difficulty^k / issuance sum, where a is a configurable scaling factor.

The upper band applies a dynamic multiplier to the base price that decays exponentially over time from a configurable starting year. The formula is: multiplier = floor + (start - floor) × exp(-decay rate × days elapsed). This produces a multiplier that begins at the start value and asymptotically approaches the floor value as Bitcoin ages, reflecting the empirically observed compression of the peak-to-floor ratio across successive market cycles. When the multiplier is high in early history, the upper band sits far above the base price, capturing the explosive cycle amplitude of early Bitcoin. As the multiplier decays toward the floor, the upper band converges toward the base price, consistent with diminishing cycle returns.

[b]Plots 📊[/b]
[list]
[*]Base model price line with glow effect: historical cost floor derived from difficulty and issuance
[*]Upper band line with glow effect: base price multiplied by the time-decaying dynamic multiplier
[*]Background color on the price chart when price is above the upper band or below the base line
[*]Candle coloring on the price chart: positive color below base, negative color above upper band, neutral between the two
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Scaling Factor a: calibrates the absolute level of the model price
[*]Damping Coefficient k: controls the sub-linear scaling of difficulty in the model
[*]Difficulty MA Length: smoothing window for the raw difficulty series
[*]Issuance Sum Window: rolling sum window for the daily issuance, smoothing halving discontinuities
[*]Upper Band Start Multiplier: initial multiplier applied to the base price for the upper band
[*]Upper Band Floor Multiplier: asymptotic lower bound of the decaying multiplier
[*]Decay Rate: speed of exponential decay of the upper band multiplier over time
[*]Decay Start Year: reference year from which the decay timer begins
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Hermes.

[b]Purpose 🎯[/b]
Standard technical price floors such as moving averages or Fibonacci retracements are derived entirely from Bitcoin's own price history and have no connection to the physical cost of the network. This model derives its floor from the computational work required to produce coins, making it independent of price action and grounded in the thermodynamics of proof-of-work. Unlike fiat-denominated mining cost models that require electricity price assumptions, this model uses only on-chain data, making it objective and reproducible. The time-decaying upper band reflects the structural reality that each Bitcoin cycle has historically produced diminishing peak-to-floor ratios, calibrating the top reference to each cycle's expected amplitude rather than applying a fixed multiplier that becomes increasingly unrealistic as the market matures.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Difficulty per Issuance - PoW Pricing Model | Astral Vision 🌠💠", overlay=true)

string group1 = "Model Parameters"
string group2 = "Visualization"
string group3 = "Astral Colors"

float  a_factor    = input.float(0.667, "Scaling Factor (a = 2/3)", step=0.001, group=group1)
float  k_factor    = input.float(0.418, "Damping Coefficient (k)",  step=0.01,  group=group1)
int    diff_ma     = input.int(180,     "Difficulty MA Length (days)", minval=1, group=group1)
int    iss_sum     = input.int(180,     "Issuance Sum Window (days)",  minval=1, group=group1)
float  mult1_start = input.float(2.0,   "Upper Band Start Multiplier", step=0.01, group=group2)
float  mult1_floor = input.float(4.0,   "Upper Band Floor Multiplier", step=0.01, group=group2)
float  decay_rate  = input.float(1,"Decay Rate (per day)",        step=0.00001, group=group2)
int    decay_start = input.int(2012,    "Decay Start Year",            group=group2)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group3)
color  custom_pos = input.color(color.rgb(255,160,0), "Custom Positive", group=group3)
color  custom_neg = input.color(color.rgb(0,180,120), "Custom Negative", group=group3)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)   :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

float difficulty = request.security("GLASSNODE:BTC_DIFFICULTY", "D", close)
float btc_close  = request.security("INDEX:BTCUSD",             "D", close)

float issuance_per_day =
     time < timestamp(2012, 11, 28) ? 50.0  * 144 :
     time < timestamp(2016, 7,   9) ? 25.0  * 144 :
     time < timestamp(2020, 5,  11) ? 12.5  * 144 :
     time < timestamp(2024, 4,  20) ? 6.25  * 144 :
     3.125 * 144

float start_time   = timestamp(decay_start, 1, 1)
float days_elapsed = time >= start_time ? (time - start_time) / 86400000.0 : 0.0

float dynamic_mult = mult1_floor + (mult1_start - mult1_floor) *
     math.exp(-decay_rate * days_elapsed)

float issuance_sum = math.sum(issuance_per_day, iss_sum)
float diff_smooth  = ta.sma(difficulty, diff_ma)
float pow_d        = math.exp(k_factor * math.log(diff_smooth))
float dpi_base     = not na(pow_d) and issuance_sum > 0 ?
     a_factor * pow_d / issuance_sum : na

float dpi_b1 = not na(dpi_base) ? dpi_base * dynamic_mult : na

color base_col = not na(btc_close) and not na(dpi_b1) ?
     (btc_close >= dpi_b1   ? neg_col :
      btc_close <= dpi_base ? pos_col :
      color.new(color.rgb(120,120,120), 30)) :
     color.new(color.rgb(120,120,120), 30)

plot(dpi_base, "DPI Base Glow",  color=color.new(pos_col, 75), linewidth=6)
plot(dpi_base, "DPI Base",       color=color.new(pos_col, 0),  linewidth=2)
plot(dpi_b1,   "DPI Upper Glow", color=color.new(neg_col, 75), linewidth=6)
plot(dpi_b1,   "DPI Upper",      color=color.new(neg_col, 40), linewidth=2)

bgcolor(not na(btc_close) and not na(dpi_b1)   and btc_close >= dpi_b1   ? color.new(neg_col, 75) : na, force_overlay=true)
bgcolor(not na(btc_close) and not na(dpi_base) and btc_close <= dpi_base ? color.new(pos_col, 75) : na, force_overlay=true)

plotcandle(open, high, low, close, "Candles",
     base_col, base_col,
     bordercolor=base_col,
     force_overlay=true)
````

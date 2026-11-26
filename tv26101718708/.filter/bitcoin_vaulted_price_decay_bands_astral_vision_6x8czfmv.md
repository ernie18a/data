# Bitcoin Vaulted Price Decay Bands | Astral Vision 

- url: https://www.tradingview.com/script/6X8czfMV/
- type: indicator
- pine_id: PUB;7fa5fa0a3c2f4287853b133bd599ed28
- version: 1.0

## Description

[b]Bitcoin Vaulted Price Decay Bands | Astral Vision 🌠💠[/b]

This indicator constructs a dynamic price channel around a concept called the Vaulted Price: a modified version of Bitcoin's Realized Price that weights the on-chain cost basis by a measure of how much of the supply is being held long-term rather than actively circulating. The resulting bands adapt over time to reflect both the evolution of Bitcoin's aggregate cost basis and the changing proportion of supply held by long-term conviction holders.

[b]Calculation ⚙️[/b]

The Realized Price is normally computed as Realized Cap divided by total supply, where Realized Cap values each coin at the price it last moved on-chain rather than at current market price. This indicator modifies that baseline by introducing a vaultedness coefficient derived from the percentage of Bitcoin that has not moved in over one year. The formula is: vaultedness = 0.5 + (active1y / 100) × 1.0, where `active1y` is the percentage of supply active within the past year fetched from Glassnode. This coefficient scales between 0.5 and 1.5, amplifying the Realized Cap when more supply is actively circulating and compressing it when more supply is dormant. The Vaulted Price is then: Realized Cap × vaultedness / total supply.

The upper band applies a time-decaying multiplier to the Vaulted Price: top multiplier = base × days^exponent, where days is the number of days elapsed since June 13, 2011, the reference origin for this model. Because the exponent is negative (default -0.35), the multiplier shrinks over time following a power law, meaning the upper band converges toward the Vaulted Price as Bitcoin matures. This captures the empirically observed compression of Bitcoin's peak-to-realized-price ratio across successive market cycles. The lower band applies a fixed multiplier to the Vaulted Price, providing a stable support reference scaled to the cost basis of long-term holders.

Each band is rendered with three layered plots at decreasing transparency and increasing line width, producing a glow effect.

[b]Plots 📊[/b]
[list]
[*]Upper band: Vaulted Price multiplied by a time-decaying power law coefficient, with three-layer glow
[*]Lower band: Vaulted Price multiplied by a fixed support multiplier, with three-layer glow
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Top Multiplier Base: starting magnitude of the upper band multiplier before time decay
[*]Top Decay Exponent: rate at which the upper multiplier compresses over time, negative values produce decay
[*]Bottom Multiplier: fixed multiplier applied to the Vaulted Price for the lower support band
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Inferno.

[b]Purpose 🎯[/b]
Standard realized price and cost basis indicators treat all supply equally regardless of whether coins have been dormant for years or moved yesterday. This indicator separates the two by weighting the cost basis by the activity ratio of supply, producing a reference price that reflects the aggregate conviction of holders who are choosing not to sell rather than the average of all coins including those being actively traded. The time-decaying upper band further addresses a limitation of fixed-multiplier models, which overstate the distance to cycle tops in later cycles when Bitcoin's absolute price is orders of magnitude higher than in earlier cycles. The decaying exponent makes the upper band structurally tighter in each successive cycle, consistent with Bitcoin's historically compressing peak-to-cost-basis ratio.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin Vaulted Price Decay Bands | Astral Vision 🌠💠", overlay=true)

string group1 = "Settings"
string group2 = "Astral Colors"

float top_mult_base = input.float(110,   "Top Multiplier Base",  group=group1)
float top_decay     = input.float(-0.35, "Top Decay Exponent",   group=group1, step=0.01)
float bot_mult      = input.float(1.5,   "Bottom Multiplier",    group=group1, step=0.1)

string theme      = input.string("Inferno", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.white, "Custom Positive", group=group2)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=group2)

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

float realized_cap = request.security("COINMETRICS:BTC_MARKETCAPREAL", "D", close)
float supply       = request.security("GLASSNODE:BTC_SUPPLY",          "D", close)
float active1y     = request.security("GLASSNODE:BTC_ACTIVE1Y",        "D", close)

float vaultedness   = 0.5 + (active1y / 100) * 1.0
float vaulted_price = (realized_cap * vaultedness) / supply

float days    = (time - timestamp(2011, 6, 13, 0, 0, 0)) / 86400000.0
float top_mul = top_mult_base * math.pow(days, top_decay)

float band_top = vaulted_price * top_mul
float band_bot = vaulted_price * bot_mult

plot(band_top, color=pos_col,                    linewidth=2)
plot(band_top, color=color.new(pos_col, 60),     linewidth=5)
plot(band_top, color=color.new(pos_col, 80),     linewidth=9)

plot(band_bot, color=neg_col,                    linewidth=2)
plot(band_bot, color=color.new(neg_col, 60),     linewidth=5)
plot(band_bot, color=color.new(neg_col, 80),     linewidth=9)
````

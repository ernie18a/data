# Bitcoin Production Cost | Astral Vision 

- url: https://www.tradingview.com/script/XCFvqjH2/
- type: indicator
- pine_id: PUB;83548c105deb4ea89539c689a0854aee
- version: 1.0

## Description

[b]Bitcoin Production Cost | Astral Vision 🌠💠[/b]

This indicator estimates the real-world cost of producing one Bitcoin by modeling the energy expenditure of the mining network from on-chain data, then divides by the daily coin issuance to express that cost in USD per BTC. The result is a fundamental price floor reference: sustained trading below the cost of production is historically short-lived because unprofitable miners shut down, reducing hash rate, reducing difficulty, and eventually restoring profitability for those who remain.

[b]Calculation ⚙️[/b]

The hash rate is fetched from Glassnode in exahashes per second and converted to terahashes per second. The energy consumption of the network per day is then estimated as: kWh per day = hash rate (TH/s) × efficiency (J/TH) × 86,400 seconds per day / 3,600,000 joules per kWh. This converts the product of hash rate and energy per hash into kilowatt-hours of electricity consumed daily by the entire network.

The hardware efficiency parameter is set dynamically by era rather than using a single static value. Each major mining hardware generation is assigned an approximate efficiency in joules per terahash: 2,000 J/TH before 2014 (early GPU and first-generation ASICs), declining through 800, 500, 250, 100, 85, 55, 40, and 32 J/TH at successive epoch boundaries, with the user-configurable current efficiency applied to recent and future bars. This epoch-based schedule reflects the documented progression of ASIC hardware efficiency over Bitcoin's mining history.

The electricity price is similarly segmented by era, reflecting the documented geographic concentration of mining: a configurable pre-2019 rate for the early period, a lower configurable rate for the Chinese dominance era before the 2021 mining ban, and a configurable post-exodus rate for the current globally distributed mining landscape.

The daily BTC reward available to miners is computed as 144 blocks per day multiplied by the current block subsidy, derived from the block height using the halving schedule, plus daily transaction fees in BTC converted from the CoinMetrics USD fee data. This sum is smoothed with a 7-day SMA to reduce the noise from day-to-day block count variation.

The electricity cost per BTC is then: (kWh per day × electricity price) / daily reward in BTC. This represents what miners spend on electricity alone to produce one Bitcoin. The total production cost divides the electricity cost by the electricity percentage of total costs (default 60% based on CBECI methodology), adding the implicit cost of hardware amortization, facilities, and operations.

The Miner Price is a separate reference: current Bitcoin price plus the USD value of transaction fees per BTC, representing the effective revenue miners receive for each coin equivalent produced. When Miner Price exceeds Total Cost, mining is profitable; when it falls below, miners are operating at a loss.

[b]Plots 📊[/b]
[list]
[*]Electricity Cost per BTC with glow effect (toggleable)
[*]Total Production Cost per BTC with glow effect (toggleable)
[*]Miner Price with glow effect (toggleable)
[*]Fill between Electricity Cost and Total Cost
[*]Information table with current values for all key metrics: electricity cost, total cost, miner price, BTC price, price-to-total-cost ratio, efficiency, electricity rate, electricity percentage, and block subsidy
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Electricity $/kWh for three historical eras: pre-June 2019, pre-May 2021, and post-May 2021
[*]Electricity percentage of total costs: used to gross up electricity cost to total production cost
[*]Efficiency J/TH: applied to recent and future bars, historical values are set automatically by epoch
[*]Show Electricity Cost, Total Production Cost, Miner Price: individual toggles
[*]Glow effect and info table toggles
[*]Table position: four corner options
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Infinito.

[b]Purpose 🎯[/b]
Standard support and resistance tools are derived entirely from price history and have no connection to the economic reality of Bitcoin production. This indicator derives its reference levels from the physical cost of mining, making it independent of price action and structurally grounded in the economics of the network. The price-to-total-cost ratio in the table provides an immediate reading of how far current price sits above or below break-even for miners, which has historically been one of the most reliable macro cycle indicators available on-chain.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin Production Cost | Astral Vision 🌠💠", overlay=true)

group0 = "Mining Parameters"
group1 = "Visualization"
group2 = "Astral Colors"

p_og       = input.float(0.05, "Electricity $/kWh (pre Jun 2019)",  minval=0.01, maxval=0.30, step=0.005, group=group0)
p_china    = input.float(0.04, "Electricity $/kWh (pre May 2021)",  minval=0.01, maxval=0.30, step=0.005, group=group0)
p_new      = input.float(0.05, "Electricity $/kWh (post May 2021)", minval=0.01, maxval=0.30, step=0.005, group=group0)
elec_pct   = input.float(0.60, "Electricity % of total costs",      minval=0.10, maxval=1.00, step=0.05,  group=group0, tooltip="Capriole/CBECI: electricity = 60% of total mining cost.")
efficiency = input.float(22.0, "Efficiency (J/TH) — current",       minval=1.0,  maxval=100.0, step=0.5, group=group0, tooltip="Used for current and future bars only. Historical values are set automatically per epoch.")

show_elec  = input.bool(true, "Show Electricity Cost",   group=group1)
show_total = input.bool(true, "Show Total Production Cost", group=group1)
show_miner = input.bool(true, "Show Miner Price",        group=group1)
show_glow  = input.bool(true, "Glow effect",             group=group1)
show_table = input.bool(true, "Show info table",         group=group1)
table_pos  = input.string("Top Right", "Table position", options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=group1)

string theme      = input.string("Infinito", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,89,0),   "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(180,0,220),  "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80)  :
     color.rgb(0,180,120)

color neu_col  = color.rgb(120,120,120)
color miner_color = color.rgb(0,200,100)

hashrate_raw = request.security("GLASSNODE:BTC_HASHRATE", "D", close, ignore_invalid_symbol=true)
fees_usd     = request.security("COINMETRICS:BTC_FEEUSD", "D", close, ignore_invalid_symbol=true)

hashrate = nz(hashrate_raw, 1.0) / 1e12

t_h1 = timestamp(2012, 11, 28, 0, 0)
t_h2 = timestamp(2016,  7,  9, 0, 0)
t_h3 = timestamp(2020,  5, 11, 0, 0)
t_h4 = timestamp(2024,  4, 19, 0, 0)

subsidy       = time < t_h1 ? 50.0 : time < t_h2 ? 25.0 : time < t_h3 ? 12.5 : time < t_h4 ? 6.25 : 3.125
daily_subsidy = 144.0 * subsidy

t_china_end = timestamp(2019, 6, 30, 0, 0)
t_exodus_end = timestamp(2021, 5,  1, 0, 0)
elec_price  = time < t_china_end ? p_og : time < t_exodus_end ? p_china : p_new

t_2014 = timestamp(2014, 1, 1, 0, 0)
t_2015 = timestamp(2015, 1, 1, 0, 0)
t_2016 = timestamp(2016, 1, 1, 0, 0)
t_2017 = timestamp(2017, 6, 1, 0, 0)
t_2019 = timestamp(2019, 1, 1, 0, 0)
t_2020 = timestamp(2020, 6, 1, 0, 0)
t_2021 = timestamp(2021, 6, 1, 0, 0)
t_2022 = timestamp(2022, 6, 1, 0, 0)
t_2023 = timestamp(2023, 1, 1, 0, 0)

efficiency_dynamic = time < t_2014 ? 2000.0 : time < t_2015 ? 800.0 : time < t_2016 ? 500.0 : time < t_2017 ? 250.0 : time < t_2019 ? 100.0 : time < t_2020 ? 85.0 : time < t_2021 ? 55.0 : time < t_2022 ? 40.0 : time < t_2023 ? 32.0 : efficiency

fees_btc         = nz(fees_usd, 0.0) / math.max(close, 1.0)
total_reward_raw = daily_subsidy + fees_btc
total_reward     = ta.sma(total_reward_raw, 7)

kwh_per_day   = hashrate * efficiency_dynamic * 86400.0 / 3600000.0
btc_elec_cost = kwh_per_day * elec_price / math.max(total_reward, 0.001)
total_cost    = btc_elec_cost / elec_pct

elec_smooth  = ta.sma(btc_elec_cost, 14)
total_smooth = ta.sma(total_cost,    14)

miner_price  = close + nz(fees_usd, 0.0) / math.max(total_reward, 0.001)
miner_smooth = ta.sma(miner_price, 3)

ratio_price = close / math.max(total_smooth, 1.0)

p_elec  = plot(show_elec  ? elec_smooth  : na, "Electricity Cost",      color=pos_col,    linewidth=2)
p_total = plot(show_total ? total_smooth : na, "Total Production Cost",  color=neg_col,    linewidth=2)
p_miner = plot(show_miner ? miner_smooth : na, "Miner Price",            color=miner_color, linewidth=2)

plot(show_elec  and show_glow ? elec_smooth  : na, "Elec Glow 1",  color=color.new(pos_col,    70), linewidth=6)
plot(show_elec  and show_glow ? elec_smooth  : na, "Elec Glow 2",  color=color.new(pos_col,    85), linewidth=12)
plot(show_total and show_glow ? total_smooth : na, "Total Glow 1", color=color.new(neg_col,    70), linewidth=6)
plot(show_total and show_glow ? total_smooth : na, "Total Glow 2", color=color.new(neg_col,    85), linewidth=12)
plot(show_miner and show_glow ? miner_smooth : na, "Miner Glow 1", color=color.new(miner_color, 70), linewidth=6)
plot(show_miner and show_glow ? miner_smooth : na, "Miner Glow 2", color=color.new(miner_color, 85), linewidth=12)

fill(p_elec, p_total, color=color.new(neg_col, 88), title="Elec–Total fill")

tpos = table_pos == "Top Right"    ? position.top_right    :
       table_pos == "Bottom Right" ? position.bottom_right :
       table_pos == "Top Left"     ? position.top_left     : position.bottom_left

var table info = table.new(tpos, 2, 10,
     bgcolor      = color.rgb(8, 8, 8, 5),
     border_color = color.new(color.black, 100),
     border_width = 1,
     frame_color  = color.new(color.black,100),
     frame_width  = 1)

C_BG_HEADER = color.new(color.black, 100)
C_BG_ROW    = color.new(color.black, 100)
C_LABEL     = color.white
C_WHITE     = color.rgb(230, 230, 230)

if show_table and barstate.islast
    table.cell(info, 0, 0, "ASTRAL VISION 🌠💠", text_color=color.black, bgcolor=pos_col, text_halign=text.align_center, text_formatting = text.format_bold, text_font_family = font.family_monospace)
    table.cell(info, 1, 0, "⚡ Mining Cost",   text_color=color.black, bgcolor=pos_col, text_halign=text.align_center, text_formatting = text.format_bold, text_font_family = font.family_monospace)

    table.cell(info, 0, 1, "Elec. Cost / BTC", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 1, "$ " + str.tostring(elec_smooth, format.mintick), text_color=pos_col, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    table.cell(info, 0, 2, "Total Cost / BTC", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 2, "$ " + str.tostring(total_smooth, format.mintick), text_color=neg_col, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    table.cell(info, 0, 3, "Miner Price", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 3, "$ " + str.tostring(miner_smooth, format.mintick), text_color=miner_color, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    table.cell(info, 0, 4, "BTC Price", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 4, "$ " + str.tostring(close, format.mintick), text_color=C_WHITE, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    color ratio_color = ratio_price > 2.0 ? miner_color : ratio_price > 1.0 ? C_WHITE : color.rgb(255,50,50)
    table.cell(info, 0, 5, "Price / Total", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 5, str.tostring(ratio_price, "#.##") + "×", text_color=ratio_color, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    table.cell(info, 0, 6, "Efficiency", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 6, str.tostring(efficiency_dynamic, "#.#") + " J/TH", text_color=C_WHITE, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    table.cell(info, 0, 7, "Elec. $/kWh", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 7, "$ " + str.tostring(elec_price, "#.###"), text_color=C_WHITE, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    table.cell(info, 0, 8, "Elec. % costs", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 8, str.tostring(elec_pct * 100, "#") + "%", text_color=C_WHITE, bgcolor=C_BG_ROW,  text_formatting = text.format_bold)

    table.cell(info, 0, 9, "Subsidy / block", text_color=C_LABEL, bgcolor=C_BG_HEADER)
    table.cell(info, 1, 9, str.tostring(subsidy, "#.###") + " BTC", text_color=neu_col, bgcolor=C_BG_ROW, text_formatting = text.format_bold)
````

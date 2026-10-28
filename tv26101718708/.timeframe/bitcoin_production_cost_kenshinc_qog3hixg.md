# Bitcoin Production Cost (KenshinC)

- url: https://www.tradingview.com/script/qOG3HIxG-Bitcoin-Production-Cost-KenshinC/
- type: indicator
- pine_id: PUB;f1e12b784f414923aa1f2e0430a82424
- version: 2.0

## Description

[b]Bitcoin Production Cost (KenshinC) [/b]
Is a comprehensive on-chain mining cost model designed to estimate Bitcoin’s true production floor in real time.

This indicator calculates both **Single Miner Production Cost** and **Network-wide Marginal Production Cost**, taking into account:
- Automatic miner generation switching (S9 → S19 → S21 Pro → S23) based on real hardware evolution
- Weighted average electricity cost from 16 major mining countries, including cheap hydropower nations like **Paraguay** and **Ethiopia**, and low-cost energy hubs in the Middle East (UAE, Oman)
- Hashrate distribution across the globe
- Hardware depreciation, operational expenses, and daily transaction fees
- All four historical halving events with visual highlighting
[b]
### Key Features:[/b]
- Accurate marginal cost modeling using the latest miner efficiency (J/TH)
- Real-time Network Production Cost (the most important “floor price” reference for Bitcoin)
- Single Miner Electricity Cost vs Total Cost breakdown
- Moving Averages (20/50/200) on network cost for trend analysis
- Live era label showing current mining generation and estimated cost
- Clean visuals with halving background highlights

Traders and analysts use this indicator to identify potential miner capitulation zones, estimate fair value floors during bear markets, and gauge mining industry health as Bitcoin halvings reduce block rewards.

Whether you're a spot trader, on-chain analyst, or miner, this tool provides one of the most realistic views of Bitcoin’s cost of production in 2026 and beyond.

Updated with latest 2026 mining hardware data and expanded cheap electricity countries.

Made with ❤️ for the Bitcoin community.

## Source Code

````pine
//@version=5
indicator("Production Cost (BTC + LTC + DOGE) - KenshinC", overlay=true, max_lines_count=500, max_labels_count=500)

// ==================== INPUTS ====================

// Coin Selection
g_coin = "Coin Selection"
coinType = input.string("BTC", "Select Coin", options=["BTC", "LTC", "DOGE"], group=g_coin, tooltip="Choose the coin to calculate production cost for")

// Network Hashrate Override
g0 = "Network & Override"
userDefinedHashRate = input.float(0.0, title="Override Network Hashrate (TH/s) - 0 = use TradingView data", minval=0, group=g0)

// Miner Model Selection
g_miner = "Mining Hardware (Auto + Override)"
minerSelection = input.string("Auto", "Miner Model", options=["Auto", "Custom"], group=g_miner)

// Custom miner parameters
miner_hashRate_custom   = input.float(0.0095, "Custom Hashrate (TH/s)", group=g_miner, inline="c1")
miner_power_custom      = input.float(3425.0, "Custom Power Consumption (W)", group=g_miner, inline="c1")
miner_cost_custom       = input.float(2000.0, "Custom Miner Cost (USD)", group=g_miner, inline="c1")

// Daily Tx Fees Override
dailyTxFeesOverride = input.float(0.0, "Daily Tx Fees Override (in coin units)", group=g_coin)

// ==================== HASHRATE DISTRIBUTION ====================
g_hash = "Hashrate Share by Country (%) - Updated 2026"
hashrate_us         = input.float(37.5, "United States",     group=g_hash, inline="h1")
hashrate_russia     = input.float(16.9, "Russia",            group=g_hash, inline="h1")
hashrate_china      = input.float(12.0, "China",             group=g_hash, inline="h1")
hashrate_paraguay   = input.float(4.0,  "Paraguay",          group=g_hash, inline="h2")
hashrate_uae        = input.float(3.0,  "United Arab Emirates", group=g_hash, inline="h2")
hashrate_oman       = input.float(3.0,  "Oman",              group=g_hash, inline="h2")
hashrate_canada     = input.float(2.6,  "Canada",            group=g_hash, inline="h3")
hashrate_ethiopia   = input.float(2.5,  "Ethiopia",          group=g_hash, inline="h3")
hashrate_kazakhstan = input.float(1.8,  "Kazakhstan",        group=g_hash, inline="h3")
hashrate_indonesia  = input.float(1.8,  "Indonesia",         group=g_hash, inline="h4")
hashrate_malaysia   = input.float(2.5,  "Malaysia",          group=g_hash, inline="h4")
hashrate_germany    = input.float(3.0,  "Germany",           group=g_hash, inline="h5")
hashrate_ireland    = input.float(2.0,  "Ireland",           group=g_hash, inline="h5")
hashrate_singapore  = input.float(2.0,  "Singapore",         group=g_hash, inline="h5")
hashrate_thailand   = input.float(1.0,  "Thailand",          group=g_hash, inline="h6")
hashrate_rest       = input.float(4.4,  "Rest of the World", group=g_hash, inline="h6")

// ==================== ELECTRICITY COST ====================
g_elec = "Electricity Cost (USD/kWh) by Country - Cheap Power Added"
elec_us         = input.float(0.055, "United States",     group=g_elec, inline="e1")
elec_russia     = input.float(0.045, "Russia",            group=g_elec, inline="e1")
elec_china      = input.float(0.08,  "China",             group=g_elec, inline="e1")
elec_paraguay   = input.float(0.035, "Paraguay (Hydro)",  group=g_elec, inline="e2")
elec_uae        = input.float(0.06,  "United Arab Emirates", group=g_elec, inline="e2")
elec_oman       = input.float(0.055, "Oman",              group=g_elec, inline="e2")
elec_canada     = input.float(0.06,  "Canada",            group=g_elec, inline="e3")
elec_ethiopia   = input.float(0.04,  "Ethiopia (Hydro)",  group=g_elec, inline="e3")
elec_kazakhstan = input.float(0.05,  "Kazakhstan",        group=g_elec, inline="e3")
elec_indonesia  = input.float(0.065, "Indonesia",         group=g_elec, inline="e4")
elec_malaysia   = input.float(0.069, "Malaysia",          group=g_elec, inline="e4")
elec_germany    = input.float(0.40,  "Germany",           group=g_elec, inline="e5")
elec_ireland    = input.float(0.44,  "Ireland",           group=g_elec, inline="e5")
elec_singapore  = input.float(0.30,  "Singapore",         group=g_elec, inline="e5")
elec_thailand   = input.float(0.111, "Thailand",          group=g_elec, inline="e6")
elec_rest       = input.float(0.055, "Rest of the World", group=g_elec, inline="e6")

// General Mining Settings
g3 = "Mining Hardware Settings"
miner_longevity  = input.int(2500, "Miner Longevity (Days)", group = g3)
operationalCosts = input.float(5.0, "Other Operational Costs per Day (USD)", group = g3)

// Moving Averages
g4 = "Moving Averages"
ma1_length = input.int(20, "MA1 Length", minval=1, group=g4)
ma2_length = input.int(50, "MA2 Length", minval=1, group=g4)
ma3_length = input.int(200, "MA3 Length", minval=1, group=g4)

// ==================== DYNAMIC PARAMETERS ====================

string hashrateSym = coinType == "BTC" ? "INTOTHEBLOCK:BTC_HASHRATE" : 
                     coinType == "LTC" ? "INTOTHEBLOCK:LTC_HASHRATE" : "INTOTHEBLOCK:DOGE_HASHRATE"

string txFeesSym   = coinType == "BTC" ? "BTC_TOTALTXFEES" : na

float blocksPerDay = coinType == "BTC" ? 144.0 : 576.0

// Block Reward
calculateBlockReward() =>
    float reward = 0.0
    if coinType == "BTC"
        if time >= timestamp(2028, 4, 18, 0, 0)
            reward := 1.5625
        else if time >= timestamp(2024, 4, 20, 0, 0)
            reward := 3.125
        else if time >= timestamp(2020, 5, 11, 0, 0)
            reward := 6.25
        else if time >= timestamp(2016, 7, 9, 0, 0)
            reward := 12.5
        else
            reward := 25.0
    else if coinType == "LTC"
        if time >= timestamp(2027, 7, 30, 0, 0)
            reward := 3.125
        else
            reward := 6.25
    else
        reward := 10000.0
    reward

// Miner parameters
var float miner_hashRate          = 0.0
var float miner_power_consumption = 0.0
var float miner_cost              = 0.0

if coinType == "BTC"
    if minerSelection == "Custom"
        miner_hashRate          := miner_hashRate_custom
        miner_power_consumption := miner_power_custom
        miner_cost              := miner_cost_custom
    else
        if time < timestamp(2020, 1, 1, 0, 0)
            miner_hashRate          := 13.5
            miner_power_consumption := 1320.0
            miner_cost              := 400.0
        else if time < timestamp(2024, 1, 1, 0, 0)
            miner_hashRate          := 95.0
            miner_power_consumption := 3250.0
            miner_cost              := 1800.0
        else if time < timestamp(2026, 1, 1, 0, 0)
            miner_hashRate          := 234.0
            miner_power_consumption := 3510.0
            miner_cost              := 4423.0
        else
            miner_hashRate          := 318.0
            miner_power_consumption := 3498.0
            miner_cost              := 4950.0
else
    if minerSelection == "Custom"
        miner_hashRate          := miner_hashRate_custom
        miner_power_consumption := miner_power_custom
        miner_cost              := miner_cost_custom
    else
        miner_hashRate          := 0.0095
        miner_power_consumption := 3425.0
        miner_cost              := 2000.0

// ==================== CALCULATIONS ====================

networkHashRateTH   = userDefinedHashRate > 0 ? userDefinedHashRate : request.security(hashrateSym, "D", close)

dailyTxFees = coinType == "BTC" ? request.security(txFeesSym, "D", close) : dailyTxFeesOverride

dailyEnergyConsumption_kWh  = (miner_power_consumption / 1000.0) * 24.0
dailyDepreciation           = miner_cost / miner_longevity
minerEfficiency_JTH         = miner_power_consumption / miner_hashRate

// Weighted Electricity Cost
float sum = 0.0
sum := hashrate_us * elec_us
sum += hashrate_russia * elec_russia
sum += hashrate_china * elec_china
sum += hashrate_paraguay * elec_paraguay
sum += hashrate_uae * elec_uae
sum += hashrate_oman * elec_oman
sum += hashrate_canada * elec_canada
sum += hashrate_ethiopia * elec_ethiopia
sum += hashrate_kazakhstan * elec_kazakhstan
sum += hashrate_indonesia * elec_indonesia
sum += hashrate_malaysia * elec_malaysia
sum += hashrate_germany * elec_germany
sum += hashrate_ireland * elec_ireland
sum += hashrate_singapore * elec_singapore
sum += hashrate_thailand * elec_thailand
sum += hashrate_rest * elec_rest
electricityCost = sum / 100.0

blockReward = calculateBlockReward()

dailyNetworkCoinProduction = blockReward * blocksPerDay + dailyTxFees
coinsMinedPerDay           = (miner_hashRate / networkHashRateTH) * dailyNetworkCoinProduction

electricityCostPerDay      = dailyEnergyConsumption_kWh * electricityCost
totalDailyCosts            = electricityCostPerDay + dailyDepreciation + operationalCosts
totalProductionCostPerCoin = totalDailyCosts / coinsMinedPerDay
electricityCostPerCoin     = electricityCostPerDay / coinsMinedPerDay

networkMinerCount     = networkHashRateTH / miner_hashRate
networkDailyCost      = networkMinerCount * (electricityCostPerDay + dailyDepreciation + operationalCosts)
networkProductionCost = networkDailyCost / dailyNetworkCoinProduction

// Moving Averages
networkCost_ma1 = ta.sma(networkProductionCost, ma1_length)
networkCost_ma2 = ta.sma(networkProductionCost, ma2_length)
networkCost_ma3 = ta.sma(networkProductionCost, ma3_length)

// ==================== PLOTS & VISUALS ====================

p1 = plot(totalProductionCostPerCoin,  color=color.rgb(255, 82, 82),   linewidth=3, title="Single Miner Total Production Cost")
p2 = plot(electricityCostPerCoin,      color=color.rgb(255, 153, 0),   linewidth=2, title="Single Miner Electricity Cost Only")

// Fixed: Use static title for plot
p3 = plot(networkProductionCost, color=color.rgb(75, 185, 75), linewidth=3, 
     title="Network Production Cost")

plot(networkCost_ma1, title="Network Cost MA 20", color=color.black, linewidth=1)
plot(networkCost_ma2, title="Network Cost MA 50", color=color.blue,  linewidth=2)
plot(networkCost_ma3, title="Network Cost MA 200", color=color.red,  linewidth=3)

fill(p1, p2, color=color.new(color.red, 80))

// Helper plots
plot(networkHashRateTH,        title="Network Hashrate (TH/s)",        display=display.data_window)
plot(electricityCost,          title="Weighted Electricity Cost ($/kWh)", display=display.data_window)
plot(minerEfficiency_JTH,      title="Miner Efficiency (J/TH)",       display=display.data_window)

// Halving background
bgcolor((coinType == "BTC" or coinType == "LTC") and 
     (time >= timestamp(2028, 4, 18, 0, 0) or time >= timestamp(2024, 4, 20, 0, 0) or 
      time >= timestamp(2020, 5, 11, 0, 0) or time >= timestamp(2016, 7, 9, 0, 0) or 
      time >= timestamp(2012, 11, 28, 0, 0)) ? color.new(color.yellow, 85) : na, title="Halving Event")

// ==================== LABEL & TABLE ====================

var label eraLabel = label.new(bar_index, na, "", color=color.new(color.blue, 70), textcolor=color.white, style=label.style_label_left, size=size.normal)

if barstate.islast
    string eraText = "Custom"
    if minerSelection == "Auto"
        if coinType == "BTC"
            eraText := time < timestamp(2020, 1, 1, 0, 0) ? "2016-2019 (S9)" : 
                       time < timestamp(2024, 1, 1, 0, 0) ? "2020-2023 (S19)" : 
                       time < timestamp(2026, 1, 1, 0, 0) ? "2024-2025 (S21 Pro)" : "2026+ (S23)"
        else
            eraText := "2022+ (Antminer L7 Scrypt)"
    
    label.set_xy(eraLabel, bar_index + 5, networkProductionCost * 1.08)
    label.set_text(eraLabel, 
         "Coin: " + coinType +
         "\nEra: " + eraText +
         "\nMiner: " + str.tostring(miner_hashRate, "#.####") + " TH/s @ " + str.tostring(miner_power_consumption, "#") + "W" +
         "\nNetwork Cost ≈ " + str.tostring(networkProductionCost, "#,###.##") + " " + coinType +
         "\nEfficiency: " + str.tostring(minerEfficiency_JTH, "#.##") + " J/TH" +
         "\nAvg Electricity: " + str.tostring(electricityCost, "#.####") + " $/kWh")

// Realtime Table
var table myTable = table.new(position.top_right, 2, 4, border_width=1, frame_color=color.gray)

if barstate.islast
    table.cell(myTable, 0, 0, "Coin",              bgcolor=color.new(color.purple, 70), text_color=color.white)
    table.cell(myTable, 1, 0, coinType,            bgcolor=color.new(color.purple, 70), text_color=color.white)
    
    table.cell(myTable, 0, 1, "Network Hashrate",  bgcolor=color.new(color.blue, 80), text_color=color.white)
    table.cell(myTable, 1, 1, str.tostring(networkHashRateTH, "#,###") + " TH/s", bgcolor=color.new(color.blue, 80), text_color=color.white)
    
    table.cell(myTable, 0, 2, "Current Miner",     bgcolor=color.new(color.gray, 80))
    table.cell(myTable, 1, 2, str.tostring(miner_hashRate, "#.####") + " TH/s", bgcolor=color.new(color.gray, 80))
    
    table.cell(myTable, 0, 3, "Est. Network Cost", bgcolor=color.new(color.green, 80), text_color=color.white)
    table.cell(myTable, 1, 3, str.tostring(networkProductionCost, "#,###.##") + " " + coinType, bgcolor=color.new(color.green, 80), text_color=color.white)
````

# Continuous Market Grid bot

- url: https://www.tradingview.com/script/GoJr2kE4-Continuous-Market-Grid-bot/
- type: strategy
- pine_id: PUB;628d386b3ee74e6a81aef3577118f8ca
- version: 1.0

## Description

The Continuous Market Grid Bot is a high-frequency, range-bound algorithmic market-making strategy. It bypasses conventional directional forecasting by dividing a master price bracket into symmetrical, mathematically spaced price corridors. Utilizing dynamic status arrays to maintain structural awareness, the engine systematically scaling-in long inventory via micro-dips and liquidating positions for explicit, compounding cash-flow gains upon immediate cyclical rotations.

[b]Core Algorithmic Architecture[/b]
1. Finite Array State Machine
Unlike standard grid scripts that continuously spam overlapping or duplicate orders, this version integrates a persistent boolean status matrix (grid_holding). The array serves as the bot's independent memory core. It dynamically locks a specific grid corridor the microsecond an accumulation trigger is met, ensuring that a tier cannot be duplicated until its active inventory is completely cleared via an offsetting profit execution.

2. Self-Replenishing Micro-Corridors
The matrix loop is designed for continuous rotation across the operational band:
[list]
[*]The Dip Layer: The engine monitors price interactions with each localized grid line. If price cuts downward across a tier, the bot locks inventory for that specific corridor.
[*]The Targeted Rotation: Once inventory is secured, the strategy targets a discrete liquidation zone exactly one step higher. Upon an upward crossover, the engine flushes the tier, clears the array reference, and instantly rearms the level to repeat the accumulation process on the next corrective wave.
[/list]

3. Dynamic Boundary Activation
To prevent adverse fills during chaotic macro trends, the system includes an automated initialization sequence. The execution engine remains completely dormant until price action enters the designated trading bracket. Once active, the intermediate nodes are cleanly rendered as non-repainting dashed structural levels across the right side of the user workspace.

Strategy Parameters & Backtesting Metrics
To replicate realistic institutional execution, the strategy properties are pre-embedded with specific live-market friction metrics. When running historical simulations or connecting to automated API order routers, ensure the configuration mirrors these structural settings:

[list]
[*]Explicit Commission Values: The script is hardcoded with a 0.035% execution fee (strategy.commission.percent) applied to every single transaction. This precisely mirrors real-world round-trip costs on premium derivative exchanges and discount brokerages.

[*]Slippage Buffer Requirements: It is highly recommended to configure 10 to 15 Slippage Ticks within your TradingView strategy properties tab. This ensures the historical performance metrics account for order book latency, depth variations, and execution delay during high-speed matching environments.

[*]Independent Close Rule: The strategy utilizes the close_entries_rule="ANY" instruction. This is a critical configuration that enables the engine to close position tiers out of chronological order, focusing strictly on closing the exact matching layer that reached its specific target matrix.
[/list]

[b]High-Risk Capital & Margin Warning[/b]
Symmetrical grid trading algorithms present exceptionally stable performance metrics during consolidation zones, but they introduce structural liabilities that users must thoroughly evaluate before allocating active capital:

High Capital Intensity: Grid systems demand heavy capital allocation. Because the bot continuously accumulates units as price descends, your ledger requires deep, un-leveraged cash reserves to sustain multiple simultaneous open drawdowns without triggering forced liquidation or margin calls.

The Trend Extinction Risk: The primary hazard to a grid framework is a one-directional macro trend. If an asset enters a persistent, structural capitulation phase that breaks cleanly below your Lower Price Limit, the bot will remain at maximum asset capacity, holding a full basket of losing inventory with mounting unrealized losses.

Emergency Risk Isolation: The script features an embedded Stop Loss Control Module. If enabled, a breach of the user-defined floor price immediately initiates a comprehensive purge sequence—wiping all pending orders, flushing outstanding inventory at market values, and clearing the status arrays to completely halt ongoing downside exposure.

Disclaimer: Trading financial derivative instruments carries a high level of capital risk. Grid bots are highly susceptible to severe trend extensions and liquidity blackouts. This technical model is presented strictly for educational research and historical backtesting analysis. It does not constitute personalized financial advice or automated asset management.

## Source Code

````pine
//@version=6
strategy("Continuous Market Grid bot", overlay=true, pyramiding=200, close_entries_rule="ANY", initial_capital=10000, commission_type=strategy.commission.percent, commission_value=0.035)

// =========================================================================
// GRID SETTINGS
// =========================================================================
grp_grid = "Grid Settings"
i_upperLimit = input.float(4600.0, title="Upper Price Limit", group=grp_grid)
i_lowerLimit = input.float(4200.0, title="Lower Price Limit", group=grp_grid)
i_gridLines  = input.int(20, title="Number of Grids", minval=2, maxval=200, group=grp_grid)
i_qtyPerGrid = input.float(0.1, title="Order Size (Base Currency)", group=grp_grid)

grp_risk = "Risk Controls"
i_useSL = input.bool(false, title="Enable Stop Loss", group=grp_risk)
i_slPrice = input.float(3800.0, title="Stop Loss Price", group=grp_risk)

// =========================================================================
// STATE TRACKING ARRAYS & VISUALS
// =========================================================================
gridStep = (i_upperLimit - i_lowerLimit) / (i_gridLines - 1)

// This array acts as the bot's memory, tracking whether each grid level is currently holding crypto
var bool[] grid_holding = array.new_bool(i_gridLines, false)

plot(i_upperLimit, "Upper Limit", color=color.red, linewidth=2, style=plot.style_line)
plot(i_lowerLimit, "Lower Limit", color=color.green, linewidth=2, style=plot.style_line)

if barstate.islast
    for i = 1 to i_gridLines - 2
        linePrice = i_lowerLimit + (i * gridStep)
        line.new(x1=bar_index - 50, y1=linePrice, x2=bar_index + 10, y2=linePrice, color=color.new(color.gray, 70), style=line.style_dotted, extend=extend.both)

// =========================================================================
// CONTINUOUS MARKET EXECUTION ENGINE
// =========================================================================
var bool botActivated = false

// Wait for price to enter the grid zone before starting
if not botActivated and close >= i_lowerLimit and close <= i_upperLimit
    botActivated := true

if botActivated
    for i = 0 to i_gridLines - 2 
        gridPrice = i_lowerLimit + (i * gridStep)
        targetPrice = gridPrice + gridStep
        
        buyId = "Buy_" + str.tostring(i)
        
        // -----------------------------------------------------------------
        // BUY LOGIC (Self-Replenishing)
        // -----------------------------------------------------------------
        bool hit_buy = low <= gridPrice and high[1] >= gridPrice
        
        if hit_buy and not array.get(grid_holding, i)
            strategy.entry(buyId, strategy.long, qty=i_qtyPerGrid)
            array.set(grid_holding, i, true) // Mark this level as full
            
        else
            // -----------------------------------------------------------------
            // SELL LOGIC (Take Profit)
            // Only sell if price crosses UP through the target line this candle
            // -----------------------------------------------------------------
            bool hit_sell = high >= targetPrice and low[1] <= targetPrice
            
            if hit_sell and array.get(grid_holding, i)
                strategy.close(buyId, comment="TP_" + str.tostring(i))
                array.set(grid_holding, i, false) // Mark level empty so it can buy the next dip!

// =========================================================================
// STOP LOSS
// =========================================================================
if i_useSL and close <= i_slPrice
    strategy.cancel_all()
    strategy.close_all(comment="SL Hit")
    botActivated := false
    for i = 0 to i_gridLines - 1
        array.set(grid_holding, i, false)
````

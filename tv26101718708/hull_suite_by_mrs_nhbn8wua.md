# Hull Suite by MRS

- url: https://www.tradingview.com/script/NhBn8wuA-Hull-Suite-by-MRS/
- type: strategy
- pine_id: PUB;5f6c946ad83446fa80c00c7a38d1a8e8
- version: 2.0

## Description

**Hull Suite by MRS Strategy Indicator**

The Hull Suite by MRS Strategy is a technical analysis tool designed to provide insights into market trends using variations of the Hull Moving Average (HMA). This strategy aims to help traders identify optimal entry points for both long and short positions by utilizing multiple types of Hull-based indicators.

### Key Features:
1. **Hull Moving Average Variations**: The indicator offers three different Hull Moving Average variants:
   - **HMA (Hull Moving Average)**: A fast-moving average that minimizes lag and reacts quickly to price changes.
   - **EHMA (Enhanced Hull Moving Average)**: A smoother version of HMA with reduced noise, offering a clearer view of market trends.
   - **THMA (Triple Hull Moving Average)**: A more complex Hull average that aims to provide a stronger confirmation of trend direction.

2. **Customizable Parameters**:
   - **Source Selection**: Allows traders to choose the source for calculation (e.g., closing prices).
   - **Length**: A configurable parameter to adjust the period over which the moving average is calculated (e.g., 55-period for swing entries).
   - **Trend Coloring**: Users can enable automatic color-coding of the Hull moving average to reflect whether the market is in an uptrend (green) or downtrend (red).
   - **Candle Color**: Option to color candles based on Hull's trend, further improving the visual clarity of trend direction.

3. **Entry and Exit Signals**: 
   - **Buy Signal**: Generated when the Hull moving average crosses above its historical value, indicating a potential upward price movement.
   - **Sell Signal**: Triggered when the Hull moving average crosses below its historical value, signaling a potential downward price movement.
   - The strategy can be customized to work with long, short, or both directions, making it adaptable for various market conditions.

4. **Visual Representation**:
   - **Hull Bands**: The indicator can plot the Hull moving average as bands, with customizable transparency to suit individual preferences.
   - **Band Filler**: The area between the two Hull moving averages is filled, making it easier to identify trends at a glance.

5. **Backtesting and Strategy Execution**: This strategy can be tested on historical data with adjustable backtest start and stop dates, providing traders with a better understanding of its performance before live trading.

### Purpose:
The Hull Suite by MRS Strategy is designed to assist traders in determining the optimal time to enter and exit the market based on robust Hull moving averages. With its flexibility, it can be used for trend-following, swing trading, or other strategic applications.

## Source Code

````pine
//@version=6
// Converted to Strategy by MRS
strategy('Hull Suite by MRS', overlay=true, pyramiding=1, default_qty_type=strategy.percent_of_equity, default_qty_value=100, calc_on_order_fills=false, slippage=0, commission_type=strategy.commission.percent, commission_value=0)

// Input for strategy direction
strat_dir_input = input.string(title='Strategy Direction', defval='long', options=['long', 'short', 'all'])
strat_dir_value = strat_dir_input == 'long' ? strategy.direction.long : strat_dir_input == 'short' ? strategy.direction.short : strategy.direction.all
strategy.risk.allow_entry_in(strat_dir_value)

//////////////////////////////////////////////////////////////////////
// Testing Start dates
testStartYear = input.int(2016, title='Backtest Start Year')
testStartMonth = input.int(1, title='Backtest Start Month')
testStartDay = input.int(1, title='Backtest Start Day')
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, 0, 0)

// Stop date if you want to use a specific range of dates
testStopYear = input.int(2030, title='Backtest Stop Year')
testStopMonth = input.int(12, title='Backtest Stop Month')
testStopDay = input.int(30, title='Backtest Stop Day')
testPeriodStop = timestamp(testStopYear, testStopMonth, testStopDay, 0, 0)

testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop

// Component Code Stop
//////////////////////////////////////////////////////////////////////

// INPUTS
src = input(close, title='Source')
modeSwitch = input.string('Hma', title='Hull Variation', options=['Hma', 'Thma', 'Ehma'])
length = input.int(55, title='Length (180-200 for floating S/R, 55 for swing entry)')
switchColor = input.bool(true, title='Color Hull according to trend?')
candleCol = input.bool(false, title='Color candles based on Hull\'s Trend?')
visualSwitch = input.bool(true, title='Show as a Band?')
thicknesSwitch = input.int(1, title='Line Thickness')
transpSwitch = input.int(40, title='Band Transparency', step=5)

// FUNCTIONS
// HMA
HMA(_src, _length) =>
    ta.wma(2 * ta.wma(_src, _length / 2) - ta.wma(_src, _length), math.round(math.sqrt(_length)))

// EHMA    
EHMA(_src, _length) =>
    ta.ema(2 * ta.ema(_src, _length / 2) - ta.ema(_src, _length), math.round(math.sqrt(_length)))

// THMA    
THMA(_src, _length) =>
    ta.wma(ta.wma(_src, _length / 3) * 3 - ta.wma(_src, _length / 2) - ta.wma(_src, _length), _length)

// SWITCH
Mode(modeSwitch, src, len) =>
    modeSwitch == 'Hma' ? HMA(src, len) : modeSwitch == 'Ehma' ? EHMA(src, len) : modeSwitch == 'Thma' ? THMA(src, len / 2) : na

// OUT
HULL = Mode(modeSwitch, src, length)
MHULL = HULL[0]
SHULL = HULL[2]

// COLOR
hullColor = switchColor ? HULL > HULL[2] ? #00ff00 : #ff0000 : #ff9800

// Create transparent colors using color.new()
hullColorTransparent = color.new(hullColor, transpSwitch)

// PLOT
///< Frame
Fi1 = plot(MHULL, title='MHULL', color=hullColorTransparent, linewidth=thicknesSwitch)
Fi2 = plot(visualSwitch ? SHULL : na, title='SHULL', color=hullColorTransparent, linewidth=thicknesSwitch)
///< Ending Filler
fill(Fi1, Fi2, title='Band Filler', color=hullColorTransparent)

/// BARCOLOR
barcolor(color=candleCol ? switchColor ? hullColor : na : na)

// STRATEGY LOGIC
if HULL[0] > HULL[2] and testPeriod()
    strategy.entry('buy', strategy.long)
if HULL[0] < HULL[2] and testPeriod()
    strategy.entry('sell', strategy.short)
````

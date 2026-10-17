# Position Investing by SirSeff

- url: https://www.tradingview.com/script/1Gp9W1xq-Position-Investing-by-SirSeff/
- type: strategy
- pine_id: PUB;c289ab8af7ff47fd9147d2020e46edb5
- version: 1.0

## Description

This is for my group.
The ideas is to dollar cost average whenever the band is green and pause investing when the band is red.
This gives you two things:
1. You'll minimize averaging down. Ibig sabihin maiiwasan mo bumili tapos kinabukasan down agad.
2. you'll maximize averaging up or scaling up. Ibig sabihin, most likely nakaka bili ka na green days and green kinabukasan.
Join the FB group fb.com/groups/usstocksforfilipinos

With Net profit of 87.72 % at hindi pa kasama compounding effect niyan whenever you top up on green bands.
Percent Profitable is 2.07 ibig sabihin ma dodoble mo ang account mo when you religiously follow this.
 Max Loss Drawdown is 7.43 %, ibig sabihin maminimize mo ang losses down to 7.43%

## Source Code

````pine
//@version=5
strategy('Position Investing by SirSeff', overlay=true, pyramiding=1, default_qty_type=strategy.percent_of_equity, default_qty_value=100, calc_on_order_fills=false, slippage=0, commission_type=strategy.commission.percent, commission_value=0)
strat_dir_input = input.string(title='Strategy Direction', defval='long', options=['long', 'short', 'all'])
strat_dir_value = strat_dir_input == 'long' ? strategy.direction.long : strat_dir_input == 'short' ? strategy.direction.short : strategy.direction.all
strategy.risk.allow_entry_in(strat_dir_value)
//////////////////////////////////////////////////////////////////////
// Testing Start dates
testStartYear = input(2000, 'Backtest Start Year')
testStartMonth = input(1, 'Backtest Start Month')
testStartDay = input(1, 'Backtest Start Day')
testPeriodStart = timestamp(testStartYear, testStartMonth, testStartDay, 0, 0)
//Stop date if you want to use a specific range of dates
testStopYear = input(2030, 'Backtest Stop Year')
testStopMonth = input(12, 'Backtest Stop Month')
testStopDay = input(30, 'Backtest Stop Day')
testPeriodStop = timestamp(testStopYear, testStopMonth, testStopDay, 0, 0)


testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
// Component Code Stop
//////////////////////////////////////////////////////////////////////
//INPUT
src = input(close, title='Source')
modeSwitch = input.string('Hma', title='Hull Variation', options=['Hma', 'Thma', 'Ehma'])
length = input(55, title='Length(180-200 for floating S/R , 55 for swing entry)')
switchColor = input(true, 'Color Hull according to trend?')
candleCol = input(false, title='Color candles based on Hull\'s Trend?')
visualSwitch = input(true, title='Show as a Band?')
thicknesSwitch = input(1, title='Line Thickness')
transpSwitch = input.int(40, title='Band Transparency', step=5)

//FUNCTIONS
//HMA
HMA(_src, _length) =>
    ta.wma(2 * ta.wma(_src, _length / 2) - ta.wma(_src, _length), math.round(math.sqrt(_length)))
//EHMA    
EHMA(_src, _length) =>
    ta.ema(2 * ta.ema(_src, _length / 2) - ta.ema(_src, _length), math.round(math.sqrt(_length)))
//THMA    
THMA(_src, _length) =>
    ta.wma(ta.wma(_src, _length / 3) * 3 - ta.wma(_src, _length / 2) - ta.wma(_src, _length), _length)

//SWITCH
Mode(modeSwitch, src, len) =>
    modeSwitch == 'Hma' ? HMA(src, len) : modeSwitch == 'Ehma' ? EHMA(src, len) : modeSwitch == 'Thma' ? THMA(src, len / 2) : na

//OUT
HULL = Mode(modeSwitch, src, length)
MHULL = HULL[0]
SHULL = HULL[2]

//COLOR
hullColor = switchColor ? HULL > HULL[2] ? #00ff00 : #ff0000 : #ff9800

//PLOT
///< Frame
Fi1 = plot(MHULL, title='MHULL', color=hullColor, linewidth=thicknesSwitch, transp=50)
Fi2 = plot(visualSwitch ? SHULL : na, title='SHULL', color=hullColor, linewidth=thicknesSwitch, transp=50)
///< Ending Filler
fill(Fi1, Fi2, title='Band Filler', color=hullColor, transp=transpSwitch)
///BARCOLOR
barcolor(color=candleCol ? switchColor ? hullColor : na : na)


if HULL[0] > HULL[2] and testPeriod()
    strategy.entry('Invest', strategy.long)
if HULL[0] < HULL[2] and testPeriod()
    strategy.entry('Pause', strategy.short)
````

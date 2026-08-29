<!-- tradingview-pine-id: PUB;naWKBJGnlagb8P1rU8JcndBSajR5DNbU -->
<!-- tradingviewscripts-format: 1 -->
# RedK Trader Pressure Index (TPX)

Source: https://www.tradingview.com/script/v8sBugsW-RedK-Trader-Pressure-Index-TPX-v1-0/

## Description

Quick Summary
---------------------
The RedK Trader Pressure Index (REDK_TPX) analyzes the changes in price bars to give the trader a clear visual insight that represents the ongoing fight between the bulls (buyers) and bears (sellers) in the market - to determine who is in control of the price action, which in turn can be helpful in a trader’s decision about how the price action may be unfolding, what type of trade and positions to take (or to close) and when is the ideal time to action.

How the TPX calculation works
---------------------------------------
The TPX uses a simple logic and that’s one of the things I like about it – there is no complex calculation or magic stuff - and the core idea makes sense to me, as well as being one of the ways I needed to analyze my price charts.

The underlying assumption is that the buyers and sellers are competing for control of the market at all time. 
- if there’s more buyers than sellers in the market, and if the buyers’ (or bull) pressure is stronger (than the sellers’), they will be able pull the “price range” up – and that means that on the price chart we can expect to see an increase in value in both the “high” and the “low” of the next price bar.

- Similarly, if there’s more sellers than buyers in the market, and if the sellers’ (or bear) pressure is stronger (than the buyers’), they will be able push the “price range” down – on the price chart we can expect to see a decrease in value in both the “high” and the “low” of the next price bar.

So, we will use the change in high and low price, between 2 consecutive price bars, as a proxy for the bull and bear “pressures” – a (weighted) moving average of these “pressure” values are then calculated along with the “Net Pressure” – the final results are plotted.

The importance of the "Control Level"
-----------------------------------------------
As in similar price-action based indicators, there’s a certain threshold or “control level”, above which, the pressure becomes “dominant” 

when the bull or bear pressure is above that threshold, they will dominate and control the price move – this level can be found around the 25 or 30. I have included the ability to plot and adjust that control level in the TPX’s settings – and I also show some examples in the chart above (weekly chart for MSFT)

The code is commented and the chart is annotated to explain how to “read” the TPX – and how to interpret the values on the price chart 

Using the Trader Pressure Index (TPX) in trading
------------------------------------------------------------

[*]TPX can be valuable in showing well-supported (up or down) price moves that may lead to a strong trend that we can ride (when the pressure value is above the control level) - see exampled above

[*]TPX is also valuable in showing when there’s “lack of interest” from the buyers or the sellers (or both) – which is great in exploring chub or no-trade zones - so basically when to avoid trading.

[*]As usual, it's always recommended to use these types of "price action insight"  indicators in conjunction with other trend and momentum indicators (moving averages, MACD..etc), so the insight we gain from them can be properly placed within the broader "context" - and to receive additional confimtion signals to support the trading decision.

I will come back later to post something about how the TPX differs from my recently-posted Strength of Movement (SoM) because they wok completely differently but can be used together with great synergy – and also how the TPX compares to the classic DMI/ADX which uses a similar concept.

Please feel free to integrate in your trading – hope you find this useful - comments and feedback are always welcome

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader

//@version=5
indicator('RedK Trader Pressure Index (TPX)', shorttitle='RedK_TPX v5.0', overlay=false, timeframe='', precision=1)

// ======================================================================================================================
// Inputs
// ======================================================================================================================
length  = input.int(title='Avg Length',         defval=7, minval=1)
smooth  = input.int(title='Smoothing',          defval=3, minval=1)

// ****    CLevel is the "critical or control" level, whoever builds pressure that exceeds that level will be in control
clevel  = input.int(title='Control Level',      defval=30, minval=5, maxval=100)

// version 3.0 - adding optional pre-smoothing - will cause a signal lag of ~1 bar @ value of 3 - will be off by default   
pre_s   = input.bool(title='Pre-smoothing?',    defval=false,       inline='pre-smoothing')
pre_sv  = input.int(title='',                   defval=3, minval=1, inline='pre-smoothing')

// ======================================================================================================================
// Calculations
// ======================================================================================================================
//R is the 2-bar range used as "baseline" or denominator 
R           = ta.highest(2) - ta.lowest(2)

// Bull pressure is represented by how far they can pull the high and the low of previous bar up relative to the 2-bar range
hiup        = math.max(ta.change(high), 0)
loup        = math.max(ta.change(low), 0)
bulls       = math.min((hiup + loup) / R, 1) * 100  //prevent big gaps causing a % over 100%
avgbull     = ta.wma(nz(bulls), length)

avgbulls    = pre_s ? ta.wma(avgbull, pre_sv) : avgbull

// Bear pressure is represented by how far they can push the high and the low of previous bar down relative to the 2-bar range
hidn        = math.min(ta.change(high), 0)
lodn        = math.min(ta.change(low), 0)
bears       = math.max((hidn + lodn) / R, -1) * -100  //convert to positive value
avgbear     = ta.wma(nz(bears), length)

avgbears    = pre_s ? ta.wma(avgbear, pre_sv) : avgbear

net         = avgbulls - avgbears
TPX         = ta.wma(net, smooth)  // final smoothing

// ======================================================================================================================
// colors & plots
// ======================================================================================================================
col_bulls   = #33ff0099  // 40% transp
col_bears   = #ff111166  // 60% transp
col_level   = #ffee0070
col_TPXup   = color.white
col_TPXdn   = color.gray
TPXBullish  = TPX > 0

hline(0, color=col_level, linestyle=hline.style_solid, linewidth=1, editable=false)
hline(clevel, title='Control Level', color=col_level, linestyle=hline.style_dotted, linewidth=2)

plot(avgbulls,  title='Bull Pressure',  color=col_bulls, style=plot.style_area,     linewidth=3)
plot(avgbears,  title='Bear Pressure',  color=col_bears, style=plot.style_area,     linewidth=3)
plot(TPX,       title='Net Pressure',   color=TPXBullish ? col_TPXup : col_TPXdn,   linewidth=3)

// ======================================================================================================================
// version 4.0 adds Dominant Pressure Signal and enables basic Alerts

slevel_on   = input.bool(title='Pressure Signal Line?', defval=false,                               inline='signal')
slevel      = input.int(title='',                       defval=70, minval=0, maxval=100, step=5,    inline='signal')

maxbulls    = avgbulls >= clevel
maxbears    = avgbears >= clevel
TPXswing    = ta.cross(TPX, 0)

plot(maxbears and slevel_on ? slevel : na, 'Cold',  style=plot.style_circles,   color=color.new(color.maroon, 0),   linewidth=3)
plot(maxbulls and slevel_on ? slevel : na, 'Hot',   style=plot.style_cross,     color=color.new(color.green, 0),    linewidth=3)

alertcondition(maxbulls, 'TPX Bulls in Control',    'TPX Bull Pressure >= Control Level')
alertcondition(maxbears, 'TPX Bears in Control',    'TPX Bear Pressure >= Control Level')

//  v5.0 adds alert of TPX line changing color (swinging around the 0 line)
alertcondition(TPXswing, 'Net Pressure Swing',      'Net Pressure Swing Detected!')
````

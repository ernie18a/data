<!-- tradingview-pine-id: PUB;6cf36a7802554f93aeee0a651a825359 -->
<!-- tradingviewscripts-format: 1 -->
# RedK Volume-Accelerated Directional Energy Ratio

Source: https://www.tradingview.com/script/7s0lx2Bw-RedK-Volume-Accelerated-Directional-Energy-Ratio-RedK-VADER/

## Description

The Volume-Accelerated Directional Energy Ratio (VADER) makes use of price moves (displacement) and the associated volume (effort) to estimate the positive (buying) and negative (selling) "energy" behind the scenes, enabling traders to "read the market action" in more details and adjust their trading decisions accordingly.

How does VADER work?
------------------------------------
I have always been a fan of technical analysis concepts that are simple, and that integrate both price action and volume together - The concept behind VADER is really a simple one. 

Let's walk though it as we avoid getting too technical:

[*]Large price moves that are associated with large volume means buyers (if the move is up) or sellers (when the move is down) are serious and are "in control" of the action
[*]On the other hand, when the price moves are small but with large volume, it means there's a fight, or more of a balance of energy, between buying and selling. 
[*]Also when large price moves are associated with relatively limited volume, there's a lack of "energy" from either buyers or sellers - and moves likes these are usually short-lived.

The analogy with VADER, is that we look at price moves (change of close between 2 bars) as the displacement (or action result) and the associated volume as the "effort" behind this action -- Combining these 2 values together, the displacement and the effort, gives us a representation or a proxy of the underlying energy (in a specific direction). 
when both values (displacement and effort) are high, then the resulting energy is high - and if one of these values are low, the resulting energy is low. 

we then take an average of that relative energy in each direction (positive = buying and negative = selling) and calculate the net energy. 

note that we're approaching the analogy here from a trading perspective and not from physics perspective :)   -- we can be forgiven if the energy calculation in physics is different ..

VADER Plots
---------------------

[*] the blue line with crosses represents the positive energy - or the buying strength
[*] the orange line with circles represents the negative energy - or the selling strength 
[*] the thick Green / Red main line plot represents the net energy - and generally the main signal to be looking out for is when that line crosses 0 up or down - but i find it also very valuable to keep an eye on the individual energy lines as they sometimes "tell a story" like we see in the chart above,
 

Volume Calculation:
----------------------------

https://www.tradingview.com/x/jmx2WRPJ/

- VADER by default is a volume-weighted indicator - it uses the volume associated with change in bar close value (Full mode) as an accelerator in the calculation of the directional energy

- VADER introduces another method of integrating volume, by considering "relative" or "differential" volume (Relative mode) - in this mode, we consider the ratio of volume above the minimum volume observed within a "lookback" length - so practically, ignoring the minimum volume. in other words, if a price move is associated with very low volume, it gets very low "volume accelerator" (close to 0) and if the move is associated with very large volume, it gets the maximum volume accelerator (1 or close to 1) -  The relative mode of volume calculation magnifies volume effect and ignores the low volume values that may just act as noise. test both modes and find which one works better for you.

- VADER also has the ability to work without volume (volume calculation = None) - and will revert to that mode when used with instruments that have no volume data. In that mode, VADER will behave similar to an RSI (but not exactly like it given the underlying calculation is different)  

- We can also setup VADER at a specific resolution / timeframe that is different than the chart. 

Using VADER & Other Thoughts
----------------------------------------

The main signal to look out for, is when VADER's Green / Red line crosses the zero line. 
Green (above zero) represents that the net energy is with the buyers and we should favor long positions 
Red (below zero) reflects that the sellers have control and we should favor short positions (or consider to close longs)

*** However, VADER should be used as a *secondary indicator* - given the big influence of volume on the calculation - VADER doesn't directly track price trend or momentum - VADER needs to be used in the context of other indicators that show trend and momentum - i would suggest you combine VADER with Moving Averages or other trend tracking indicators on the price chart, MACD, RSI and / or other trend and momentum indicators you're already familiar with.

Suggested setup:

https://www.tradingview.com/x/Wi9ZsWpa/

There's more to add to VADER in future versions - alerts, control level, maybe improve visuals... etc - please share your feedback as you start experimenting with VADER.. good luck! (and of course, May the Force be with you :)   )

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader

//@version=5
indicator('RedK Volume-Accelerated Directional Energy Ratio', 'RedK VADER v4.0', precision=0, timeframe='', timeframe_gaps=false)

// ***********************************************************************************************************
// Choose MA type for the base DER calculation .. 
// WMA is my preference and is default .. SMA is really slow and lags a lot - but added for comparison
f_derma(_data, _len, MAOption) =>
    value = 
      MAOption == 'SMA' ? ta.sma(_data, _len) :
      MAOption == 'EMA' ? ta.ema(_data, _len) :
      ta.wma(_data, _len)
// ***********************************************************************************************************


// ===========================================================================================================
//      Inputs
// ===========================================================================================================

price   = close
length  = input.int(10, minval=1)
DER_avg = input.int(5, 'Average', minval=1, inline='DER', group='Directional Energy Ratio')
MA_Type = input.string('WMA', 'DER MA type', options=['WMA', 'EMA', 'SMA'], inline='DER', group='Directional Energy Ratio') 
smooth  = input.int(3, 'Smooth', minval=1,  inline='DER_1', group='Directional Energy Ratio')

show_senti = input.bool(false, 'Sentiment',  inline='DER_s', group='Directional Energy Ratio')
senti   = input.int(20, 'Length', minval=1, inline='DER_s', group='Directional Energy Ratio')


v_calc  = input.string('Relative', 'Calculation', options=['Relative', 'Full', 'None'], group='Volume Parameters')
vlookbk = input.int(20, 'Lookback (for Relative)', minval=1,                            group='Volume Parameters')

// ===========================================================================================================
//          Calculations
// ===========================================================================================================

// Volume Calculation Option  -- will revert to no volume acceleration for instruments with no volume data
// v4.0 => updated Relative Volume calculation fix per @m_b_round

v = volume

vola    = 
  v_calc == 'None' or na(volume) ? 1 : 
  v_calc == 'Relative' ?   ta.stoch(v, v, v, vlookbk) / 100 : 
  v

R       = (ta.highest(2) - ta.lowest(2)) / 2                    // R is the 2-bar average bar range - this method accomodates bar gaps
sr      = ta.change(price) / R                                  // calc ratio of change to R
rsr     = math.max(math.min(sr, 1), -1)                         // ensure ratio is restricted to +1/-1 in case of big moves
c       = fixnan(rsr * vola)                                    // add volume accel -- fixnan adresses cases where no price change between bars

c_plus  = math.max(c, 0)                                        // calc directional vol-accel energy
c_minus = -math.min(c, 0)

// plot(c_plus)
// plot(c_minus)


avg_vola    = f_derma(vola, length, MA_Type)
dem         = f_derma(c_plus, length, MA_Type)  / avg_vola          // directional energy ratio
sup         = f_derma(c_minus, length, MA_Type) / avg_vola

adp         = 100 * ta.wma(dem, DER_avg)                            // average DER
asp         = 100 * ta.wma(sup, DER_avg)
anp         = adp - asp                                             // net DER..
anp_s       = ta.wma(anp, smooth)

// Calculate Sentiment - a VADER for a longer period and can act as a baseline (compared to a static 0 value)
// note we're not re-calculating vol_avg, demand or supply energy for sentiment. this would've been a different approach
s_adp       = 100 * ta.wma(dem, senti)                            // average DER for sentiment length
s_asp       = 100 * ta.wma(sup, senti)
V_senti     = ta.wma(s_adp - s_asp, smooth)


// ===========================================================================================================
//      Colors & plots
// ===========================================================================================================
c_adp   = color.new(color.aqua, 30)
c_asp   = color.new(color.orange, 30)
c_fd    = color.new(color.green, 80)
c_fs    = color.new(color.red, 80)
c_zero  = color.new(#ffee00, 70)

c_up    = color.new(#359bfc, 0)
c_dn    = color.new(#f57f17, 0)

c_sup   = color.new(#33ff00, 80)
c_sdn   = color.new(#ff1111, 80)
up      = anp_s >= 0
s_up    = V_senti >=0 

hline(0, 'Zero Line', c_zero, hline.style_solid)

// =============================================================================
// v3.0 --- Sentiment will be represented as a 4-color histogram
c_grow_above = #1b5e2080 
c_grow_below = #dc4c4a80
c_fall_above = #66bb6a80  
c_fall_below = #ef8e9880     

sflag_up = math.abs(V_senti) >= math.abs(V_senti[1])

plot(show_senti ? V_senti : na, "Sentiment", style=plot.style_columns, 
 color = s_up ? (sflag_up ? c_grow_above : c_fall_above) : 
 sflag_up ? c_grow_below : c_fall_below) 
// =============================================================================

s = plot(asp, 'Supply Energy', c_asp, 2, style=plot.style_circles,  join=true)
d = plot(adp, 'Demand Energy', c_adp, 2, style=plot.style_cross,    join=true)
fill(d, s, adp > asp ? c_fd : c_fs)

plot(anp, 'VADER', color.new(color.gray, 30), display=display.none)
plot(anp_s, 'Signal', up ? c_up : c_dn, 4)

// ===========================================================================================================
//      v2.0 adding alerts 
// ===========================================================================================================

Alert_up    = ta.crossover(anp_s,0)
Alert_dn    = ta.crossunder(anp_s,0)
Alert_swing = ta.cross(anp_s,0)

// "." in alert title for the alerts to show in the right order up/down/swing 
alertcondition(Alert_up,    ".   VADER Crossing 0 Up",      "VADER Up - Buying Energy Detected!")
alertcondition(Alert_dn,    "..  VADER Crossing 0 Down",    "VADER Down - Selling Energy Detected!")
alertcondition(Alert_swing, "... VADER Crossing 0",         "VADER Swing - Possible Reversal")

// ===========================================================================================================
//      v3.0 more alerts for VADER crossing Sentiment
// ===========================================================================================================

v_speedup = ta.crossover(anp_s, V_senti)
v_slowdn  = ta.crossunder(anp_s, V_senti)
alertcondition(v_speedup,   "*  VADER Speeding Up",      "VADER Speeding Up!")
alertcondition(v_slowdn,    "** VADER Slowing Down",    "VADER Slowing Down!")
````

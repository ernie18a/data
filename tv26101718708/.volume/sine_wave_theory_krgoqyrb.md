# Sine Wave Theory

- url: https://www.tradingview.com/script/kRGoqyRB-Sine-Wave-Theory/
- type: strategy
- pine_id: PUB;cc2c635d44614972acebb474ba8840e5
- version: 1.0

## Description

There are some ideas out there that the market is like a collection of quantum events and that it could all be broken down into sine waves.  I created this script to put that to the test.

The idea is simple, I tested 3 different factors that could be put into sine wave form.

1.) [b]Bar Change[/b]
2.) [b]Volume Average Change[/b]
3.) [b]Coin Flip[/b]

For the bar change, I simply allow the sine wave to move upwards or downwards if the bars have changed color in their sequence.  For example, if there were 3 red bars and 1 green bar, it would not move the sine wave up or down until the green bar appeared.

For the average volume change, it was the same idea, except that the sine wave could only move up or down if the volume had moved up or below the average value of the length given for calculating the average volume.

Finally, the coin flip simply simulates flipping a coin, and allows the sine wave to move one direction or the other once it has a side that is different from the previous chosen side.  For example, heads, heads, heads, tails (once it flipped to tails, this would allow it to move a direction).

The sine wave trading theory that I watched claimed that if you know the correct sine wave # (which is how large the peak is, and/or the sine wave count which is how many peaks and valleys occur) that you can successfully predict future trades.  Their claims that the reason it does not look like a perfect sine wave for these events is because there is different amounts of trading going on, thus the timing will be slightly off.

I am posting this to disagree with their ideas.  For example, if you select to turn on trading for coin flip and turn off bar change, you will see the coin flip did better on the default settings!

It just so happens that any setting will eventually be good, making all the sine wave variations just completely random if you win or not.

I posted this to demonstrate how silly trading sine waves is.  The real trick is using cosine and tangent waves... lol j/k

I hope this helps someone avoid this scam concept.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gentleman-Goat

//@version=5
strategy("Sine Wave Theory",overlay=false, precision = 2, initial_capital = 1000,shorttitle = "SINE_W_T")

var bar_change_wave_direction = input.int(defval=1,title="Starting Wave Direction",group="Bar Change")
bar_change_sine_wave_number = input.int(defval=28,title="Sine Wave #",group="Bar Change")
bar_change_sine_wave_res = input.timeframe(defval="D",title="Resolution",group="Bar Change")
bar_change_trade = input.bool(defval=true,title="Trade",group="Bar Change")

var volume_wave_direction = input.int(defval=1,title="Starting Wave Direction",group="Volume")
avg_volume_length = input.int(7,title="Lookback Length",group="Volume")
volume_sine_wave_number = input.int(defval=28,title="Sine Wave #",group="Volume")
volume_sine_wave_res = input.timeframe(defval="D",title="Resolution",group="Volume")
volume_trade = input.bool(defval=false,title="Trade",group="Volume")

var coin_flip_wave_direction = input.int(defval=1,title="Starting Wave Direction",group="Coin Flip")
coin_flip_sine_wave_number = input.int(defval=28,title="Sine Wave #",group="Coin Flip")
coin_flip_seed = input.int(defval=1,title="Seed #",group="Coin Flip")
coin_flip_trade = input.bool(defval=false,title="Trade",group="Coin Flip")

avg_volume = ta.sma(volume,avg_volume_length)

//Green or Red Candle
bar_color = close>open ? color.green : color.red
bar_color_time_adj = request.security(syminfo.tickerid, bar_change_sine_wave_res, bar_color)

//Above or Below Average
volume_state = (volume>avg_volume) ? color.blue : color.purple
volume_state_time_adj = request.security(syminfo.tickerid, volume_sine_wave_res, volume_state)
 
//Coinflip
coin_flip = math.random(0,100,coin_flip_seed)>=50 ? color.teal : color.yellow

var bar_change_wave_count = 0
var volume_wave_count = 0
var coin_flip_wave_count = 0

//Wave Counters
if(volume_state_time_adj[1] != volume_state_time_adj)
    volume_wave_count := volume_wave_count + volume_wave_direction

if(bar_color_time_adj[1] != bar_color_time_adj)
    bar_change_wave_count := bar_change_wave_count + bar_change_wave_direction

if(coin_flip[1] != coin_flip)
    coin_flip_wave_count := coin_flip_wave_count + coin_flip_wave_direction

//Direction changers
if(math.abs(bar_change_wave_count) == bar_change_sine_wave_number and bar_color_time_adj[1] != bar_color_time_adj)
    bar_change_wave_direction := bar_change_wave_direction * -1

if(math.abs(volume_wave_count) == volume_sine_wave_number and volume_state_time_adj[1] != volume_state_time_adj)
    volume_wave_direction := volume_wave_direction * -1

if(math.abs(coin_flip_wave_count) == coin_flip_sine_wave_number and coin_flip[1] != coin_flip)
    coin_flip_wave_direction := coin_flip_wave_direction * -1

//Entry positions
if(bar_change_wave_count==bar_change_sine_wave_number and bar_change_trade==true)
    strategy.entry(id="short",direction=strategy.short)
if(bar_change_wave_count==bar_change_sine_wave_number*-1 and bar_change_trade==true)
    strategy.entry(id="long",direction=strategy.long)

if(volume_wave_count==volume_sine_wave_number and volume_trade==true)
    strategy.entry(id="short-volume",direction=strategy.short)
if(volume_wave_count==volume_sine_wave_number*-1 and volume_trade==true)
    strategy.entry(id="long-volume",direction=strategy.long)

if(coin_flip_wave_count==coin_flip_sine_wave_number and coin_flip_trade==true)
    strategy.entry(id="short-coinflip",direction=strategy.short)
if(coin_flip_wave_count==coin_flip_sine_wave_number*-1 and coin_flip_trade==true)
    strategy.entry(id="long-coinflip",direction=strategy.long)

hline(0, title='Center', color=color.white, linestyle=hline.style_dashed, linewidth=1)
plot(bar_change_wave_count,title="Bar Change", color=bar_color, linewidth=2)
plot(volume_wave_count,title="Volume Average Change", color=volume_state, linewidth=2)
plot(coin_flip_wave_count,title="Coin Flip Change", color=coin_flip, linewidth=2)
````

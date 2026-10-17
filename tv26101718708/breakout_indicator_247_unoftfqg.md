# Breakout Indicator 24/7

- url: https://www.tradingview.com/script/UnOFTfQg-Breakout-Indicator-24-7/
- type: strategy
- pine_id: PUB;GkflFCETXgAIhKwp9vREViSM1hu3UhwV
- version: 2.0

## Description

24/7 Breakout indicator

## Source Code

````pine
//@version=3
strategy("London Breakout", overlay=true, currency=currency.AUD, pyramiding = 6,max_bars_back=5000, default_qty_type = strategy.fixed, default_qty_value = 30000)

breakoutbox = input(title="Breakout Box", type=session, defval="0100-0400", confirm=true)
transparency = input(title="Transparency", type=integer, defval=50, minval=0, maxval=100)
// Set the colour variables for the ranges
sessioncolour = #D3D3D3 // lightgray / lightgrey
// The BarInSession function returns true when
// the current bar is inside the session parameter
BarInSession(sess) => time(period, sess) != 0
// Determine the chart's background colour
chartColour = BarInSession(breakoutbox) ? sessioncolour : na
// Set the background colour
bgcolor(color=chartColour, transp=transparency)
barcheck = BarInSession(breakoutbox)
//////////endsession///////////

londonsession = input(title="London Session", type=session, defval="0400-1200", confirm=true)
// Set the colour variables for the ranges
sessioncolour1 = color(green,75) 
// The BarInSession function returns true when
// the current bar is inside the session parameter
// Determine the chart's background colour
chartColour1 = BarInSession(londonsession) ? sessioncolour1 : na
// Set the background colour
bgcolor(color=chartColour1, transp=transparency)
barcheck1 = BarInSession(londonsession)
//////////endsession///////////

ussession = input(title="New York Session", type=session, defval="0900-1400", confirm=true)
// Set the colour variables for the ranges
sessioncolour2 = color(blue,75) 
// The BarInSession function returns true when
// the current bar is inside the session parameter
// Determine the chart's background colour
chartColour2 = BarInSession(ussession) ? sessioncolour2 : na
// Set the background colour
bgcolor(color=chartColour2, transp=transparency)
barcheck2 = BarInSession(ussession)
//////////endsession///////////


shortlength = input(50, minval=1,title="Short Length")
short = ema(close, shortlength)
longlength = input(100, minval=1,title="Long Length")
long = ema(close,longlength)
plot(short, color = red, linewidth = 2)
p12 = plot(long, color = blue, linewidth = 2)
p13 = plot(cross(short, long) ? short : na, style = cross, linewidth = 10)


hh = security(tickerid, "60", high) 
ll = security(tickerid, "60", low) 




longcondition = crossover(close, hh)// and barcheck1
if longcondition
    strategy.entry("long", strategy.long, stop=200)


shortcondition = crossunder(close, ll)// and barcheck1
if shortcondition
    strategy.entry("short", strategy.short, stop=200)
    

trailPoints = 220
trailOffset = 8*(atr(112))

strategy.exit("Trailing Stop long", "long", trail_points= 250, trail_offset= trailOffset, stop=200)
strategy.exit("Trailing Stop short", "short", trail_points= 250, trail_offset= trailOffset, stop=200)



//atrshortstop = close+trailOffset
//plot(atrshortstop, color=red, linewidth = 4)

//atrlongstop = close-trailOffset
//plot(atrlongstop, color=green, linewidth = 4)


if barcheck1 == false
    strategy.close_all()
    

/////
up60on = input(true, title="180 Minute Opening Range High")
down60on = input(true, title="180 Minute Opening Range Low")


is_newbar(res) => change(time(res)) != 0 

adopt(r, s) => security(tickerid, r, s) 

high_range = valuewhen(is_newbar('D'),high,0)
low_range = valuewhen(is_newbar('D'),low,0)

high_rangeL = valuewhen(is_newbar('D'),high,0) 
low_rangeL = valuewhen(is_newbar('D'),low,0) 

up = plot(adopt('480', high_range), color = lime, style=line, linewidth=4)
down = plot(adopt('480', low_range), color = #DC143C, style=line, linewidth=4) 

trans60 = up60on ?  75 : 100
fill(up, down, color = yellow, transp=trans60)
/////

p1 = plot(hh, color = black, linewidth = 4) 
p2 = plot(ll, color = black, linewidth = 4) 
fill(p1,p2, color=green)
````

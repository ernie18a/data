# PnL Target/Stop Calculator $100 - $2000

- url: https://www.tradingview.com/script/G3hmcJiu-PnL-Target-Stop-Calculator-100-2000/
- type: indicator
- pine_id: PUB;421eb55a16a04dc0b7046162f629a410
- version: 1.0

## Description

This tool plots gains and losses in $100 increments from $100 - $2000. 

This can be used to find stop losses and targets based on PnL or to find the price where a specific loss or gain will occur at, and this is shown visually on chart with horizontal lines.

The user must define 2 values: The average entry price and how much is invested. This is done by going into the indicator's settings and clicking the Input tab. 
Both entry and cash amount are used to determine where $100 increments of gain and loss are. 

What's displayed?
- The brightest solid green line shows your entry.
- The skinniest dashed green line shows $100 loss/gain.
- The dotted green line shows $200 loss gain.
- It also contains a 1.6% stop, shown by the dashed purple lines.
- Solid green lines are $1000, $1500, and $2000.

After $1000 gain, the indicator shows gain in $250 increments up until $2000. 
While PnL loss only goes up to $1000.

Here is how this is calculated: 
$100 loss = [ (1-(100/cash)) * entry ]. 
$100 gain = [ (1+(100/cash)) * entry ]
$200 loss = [ (1-(200/cash)) * entry ]. 
$200 gain = [ (1+(200/cash)) * entry ]
...And so on.

To keep the horizontal lines after the indicator is removed, draw a horizontal ray or a horizontal line where the lines are drawn by the indicator and then remove the indicator after drawing the lines you wanted.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNFood
//@version=5
//Published 3/24/2023

//Title: PnL Target/Stop Calculator $100 - $1000
//This tool plots gains and losses in $100 increments from $100 - $2000. And $250 increments to 2000
//The user must define 2 values: The average entry price and how much is invested. This is done by going into the indicator's settings and clicking the Input tab. 
//Both entry and cash amount are used to determine where $100 increments of gain and loss are.  $100 loss = [ (1-(100/cash)) * entry ]. $100 gain =  [ (1+(100/cash)) * entry ]
//To keep the horizontal lines after the indicator is removed, draw a horizontal ray or a horizontal line where the lines are drawn by the indicator

indicator(title="PnL Target/Stop Calculator $100 - $2000", overlay=true)

//Input options


entry =  input.float(0.497, "Average Entry Price?")
cash =  input.float(1850, "How Must is Invested?")

//entry is the entry price
//cash is how much was invested


onesixloss = 0.984
onesix = (1-(16 / 1000))
hundredloss = (1-(100/cash))
twohundredloss = (1-(200/cash))
threehundredloss = (1-(300/cash))
fourhundredloss = (1-(400/cash))
fivehundredloss = (1-(500/cash))
sixhundredloss = (1-(600/cash))
sevenhundredloss = (1-(700/cash))
eighthundredloss = (1-(800/cash))
ninehundredloss = (1-(900/cash))
tenhundredloss = (1-(1000/cash))

onesixgain = 1.016
hundredgain = (1+(100/cash))
twohundredgain = (1+(200/cash))
threehundredgain = (1+(300/cash))
fourhundredgain = (1+(400/cash))
fivehundredgain = (1+(500/cash))
sixhundredgain = (1+(600/cash))
sevenhundredgain = (1+(700/cash))
eighthundredgain = (1+(800/cash))
ninehundredgain = (1+(900/cash))
tenhundredgain = (1+(1000/cash))
twelvefivehundredgain = (1+(1250/cash))
fifteenhundredgain = (1+(1500/cash))
seventeenfivehundredgain = (1+(1750/cash))
twentyhundredgain = (1+(2000/cash))

res16 = entry * onesixloss
gain16 = entry * onesixgain

//anything with 16 or onesix means 1.6% lines. -1.6% from entry, and +1.6% from entry. These are the first stops. 1.6% becuase that is my stop for large positions over 75% of my account.


//horizontal lines

var line linegain16 = na
var line lineres16 = na
var line lineentry = na

var line linedown100 = na
var line linedown200 = na
var line linedown300 = na
var line linedown400 = na
var line linedown500 = na
var line linedown600 = na
var line linedown700 = na
var line linedown800 = na
var line linedown900 = na
var line linedown1000 = na

var line lineup100 = na
var line lineup200 = na
var line lineup300 = na
var line lineup400 = na
var line lineup500 = na
var line lineup600 = na
var line lineup700 = na
var line lineup800 = na
var line lineup900 = na
var line lineup1000 = na
var line lineup1250 = na
var line lineup1500 = na
var line lineup1750 = na
var line lineup2000 = na


if not barstate.isconfirmed or (barstate.isrealtime and barstate.islast and not barstate.isconfirmed)

    linedown100 := line.new(x1=bar_index[1], y1=hundredloss*entry, x2=bar_index, y2=hundredloss*entry, width=1, extend=extend.both)
    linedown200 := line.new(x1=bar_index[1], y1=twohundredloss*entry, x2=bar_index, y2=twohundredloss*entry, width=1, extend=extend.both)
    linedown300 := line.new(x1=bar_index[1], y1=threehundredloss*entry, x2=bar_index, y2=threehundredloss*entry, width=1, extend=extend.both)
    linedown400 := line.new(x1=bar_index[1], y1=fourhundredloss*entry, x2=bar_index, y2=fourhundredloss*entry, width=1, extend=extend.both)
    linedown500 := line.new(x1=bar_index[1], y1=fivehundredloss*entry, x2=bar_index, y2=fivehundredloss*entry, width=1, extend=extend.both)
    linedown600 := line.new(x1=bar_index[1], y1=sixhundredloss*entry, x2=bar_index, y2=sixhundredloss*entry, width=1, extend=extend.both)
    linedown700 := line.new(x1=bar_index[1], y1=sevenhundredloss*entry, x2=bar_index, y2=sevenhundredloss*entry, width=1, extend=extend.both)
    linedown800 := line.new(x1=bar_index[1], y1=eighthundredloss*entry, x2=bar_index, y2=eighthundredloss*entry, width=1, extend=extend.both)
    linedown900 := line.new(x1=bar_index[1], y1=ninehundredloss*entry, x2=bar_index, y2=ninehundredloss*entry, width=1, extend=extend.both)
    linedown1000 := line.new(x1=bar_index[1], y1=tenhundredloss*entry, x2=bar_index, y2=tenhundredloss*entry, width=1, extend=extend.both)

    linedown100 := line.new(x1=bar_index[1], y1=hundredgain*entry, x2=bar_index, y2=hundredgain*entry, width=1, extend=extend.both)
    linedown200 := line.new(x1=bar_index[1], y1=twohundredgain*entry, x2=bar_index, y2=twohundredgain*entry, width=1, extend=extend.both)
    lineup300 := line.new(x1=bar_index[1], y1=threehundredgain*entry, x2=bar_index, y2=threehundredgain*entry, width=1, extend=extend.both)
    lineup400 := line.new(x1=bar_index[1], y1=fourhundredgain*entry, x2=bar_index, y2=fourhundredgain*entry, width=1, extend=extend.both)
    lineup500 := line.new(x1=bar_index[1], y1=fivehundredgain*entry, x2=bar_index, y2=fivehundredgain*entry, width=1, extend=extend.both)
    lineup600 := line.new(x1=bar_index[1], y1=sixhundredgain*entry, x2=bar_index, y2=sixhundredgain*entry, width=1, extend=extend.both)
    lineup700 := line.new(x1=bar_index[1], y1=sevenhundredgain*entry, x2=bar_index, y2=sevenhundredgain*entry, width=1, extend=extend.both)
    lineup800 := line.new(x1=bar_index[1], y1=eighthundredgain*entry, x2=bar_index, y2=eighthundredgain*entry, width=1, extend=extend.both)
    lineup900 := line.new(x1=bar_index[1], y1=ninehundredgain*entry, x2=bar_index, y2=ninehundredgain*entry, width=1, extend=extend.both)
    lineup1000 := line.new(x1=bar_index[1], y1=tenhundredgain*entry, x2=bar_index, y2=tenhundredgain*entry, width=1, extend=extend.both)
    lineup1250 := line.new(x1=bar_index[1], y1=twelvefivehundredgain*entry, x2=bar_index, y2=twelvefivehundredgain*entry, width=1, extend=extend.both)
    lineup1500 := line.new(x1=bar_index[1], y1=fifteenhundredgain*entry, x2=bar_index, y2=fifteenhundredgain*entry, width=1, extend=extend.both)
    lineup1750 := line.new(x1=bar_index[1], y1=seventeenfivehundredgain*entry, x2=bar_index, y2=seventeenfivehundredgain*entry, width=1, extend=extend.both)
    lineup2000 := line.new(x1=bar_index[1], y1=twentyhundredgain*entry, x2=bar_index, y2=twentyhundredgain*entry, width=1, extend=extend.both)
    


    lineres16 := line.new(x1=bar_index[1], y1=res16, x2=bar_index, y2=res16, width=1, extend=extend.both)
    linegain16 := line.new(x1=bar_index[1], y1=gain16, x2=bar_index, y2=gain16, width=1, extend=extend.both)

    lineentry := line.new(x1=bar_index[1], y1=entry, x2=bar_index, y2=entry, width=1, extend=extend.both)

    //down100=(((1 - (100 / cash)) * entry))

    


    line.set_color(id=linedown300, color=#05993e)
    line.set_style(id=linedown300, style=line.style_dashed)
    line.set_width(id=linedown300, width=4)

    line.set_width(id=linedown100, width=2)
    line.set_style(id=linedown100, style=line.style_dashed) 
    line.set_color(id=linedown100, color=#05993e)

    line.set_width(id=linedown200, width=4)
    line.set_style(id=linedown200, style=line.style_dotted)
    line.set_color(id=linedown200, color=#05993e) 

    line.set_color(id=linedown400, color=#05a040)
    line.set_style(id=linedown400, style=line.style_dashed)
    line.set_width(id=linedown400, width=4)

    line.set_color(id=linedown500, color=#06652a)
    line.set_style(id=linedown500, style=line.style_dashed)
    line.set_width(id=linedown500, width=4)

    line.set_color(id=linedown600, color=#05993e)
    line.set_style(id=linedown600, style=line.style_dashed)
    line.set_width(id=linedown600, width=4)

    line.set_color(id=linedown700, color=#05993e)
    line.set_style(id=linedown700, style=line.style_dashed)
    line.set_width(id=linedown700, width=4)

    line.set_color(id=linedown800, color=#05993e)
    line.set_style(id=linedown800, style=line.style_dashed)
    line.set_width(id=linedown800, width=4)

    line.set_color(id=linedown900, color=#05993e)
    line.set_style(id=linedown900, style=line.style_dashed)
    line.set_width(id=linedown900, width=4)

    line.set_color(id=linedown1000, color=#1b5e20)
    line.set_style(id=linedown1000, style=line.style_solid)
    line.set_width(id=linedown1000, width=4)

    line.set_width(id=lineup100, width=2)
    line.set_style(id=lineup100, style=line.style_dashed) 
    line.set_color(id=lineup100, color=#05993e)

    line.set_width(id=lineup200, width=4)
    line.set_style(id=lineup200, style=line.style_dotted)
    line.set_color(id=lineup200, color=#05993e) 

    line.set_color(id=lineup300, color=#05993e)
    line.set_style(id=lineup300, style=line.style_dashed)
    line.set_width(id=lineup300, width=4)

    line.set_color(id=lineup400, color=#05a040)
    line.set_style(id=lineup400, style=line.style_dashed)
    line.set_width(id=lineup400, width=4)

    line.set_color(id=lineup500, color=#06652a)
    line.set_style(id=lineup500, style=line.style_dashed)
    line.set_width(id=lineup500, width=4)

    line.set_color(id=lineup600, color=#05993e)
    line.set_style(id=lineup600, style=line.style_dashed)
    line.set_width(id=lineup600, width=4)

    line.set_color(id=lineup700, color=#05993e)
    line.set_style(id=lineup700, style=line.style_dashed)
    line.set_width(id=lineup700, width=4)

    line.set_color(id=lineup800, color=#05993e)
    line.set_style(id=lineup800, style=line.style_dashed)
    line.set_width(id=lineup800, width=4)

    line.set_color(id=lineup900, color=#05993e)
    line.set_style(id=lineup900, style=line.style_dashed)
    line.set_width(id=lineup900, width=4)

    line.set_color(id=lineup1000, color=#05993e)
    line.set_style(id=lineup1000, style=line.style_solid)
    line.set_width(id=lineup1000, width=4)
    
    line.set_color(id=lineup1750, color=#05993e)
    line.set_style(id=lineup1750, style=line.style_dashed)
    line.set_width(id=lineup1750, width=4)

    line.set_color(id=lineup1500, color=#05993e)
    line.set_style(id=lineup1500, style=line.style_solid)
    line.set_width(id=lineup1500, width=4)

    line.set_color(id=lineup1250, color=#05993e)
    line.set_style(id=lineup1250, style=line.style_dashed)
    line.set_width(id=lineup1250, width=4)

    line.set_color(id=lineup2000, color=#05993e)
    line.set_style(id=lineup2000, style=line.style_solid)
    line.set_width(id=lineup2000, width=4)
    
    line.set_color(id=lineres16, color=#ba68c8)
    line.set_style(id=lineres16, style=line.style_dashed)
    line.set_width(id=lineres16, width=4)

    line.set_color(id=linegain16, color=#ba68c8)
    line.set_style(id=linegain16, style=line.style_dashed)
    line.set_width(id=linegain16, width=4)
    
    line.set_color(id=lineentry, color=#05b61f)
    line.set_style(id=lineentry, style=line.style_solid)
    line.set_width(id=lineentry, width=4)

 
// end of script here
````

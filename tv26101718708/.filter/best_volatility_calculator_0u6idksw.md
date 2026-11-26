# Best Volatility Calculator

- url: https://www.tradingview.com/script/0U6idkSW-Best-Volatility-Calculator/
- type: indicator
- pine_id: PUB;W5j4cdUYzf6YgLkSGUls0GUgwdOCMA8j
- version: 1.0

## Description

Hello traders,

This indicator shows the average volatility, of last N Periods, for the selected time frames.

[b]You can select up to 2 timeframes with this version[/b]

Volatility is defined as the close of current candle - close of the previous N candle

Presented as Currency, Pip, percentage labels in a panel below. 
Will calculate in real-time only for the current instrument on the chart.

The indicator is coded to not be repainting

[b]Example[/b]

In the indicator screenshot, I used a lookback period of 1.
That compares the current candle close versus the previous one for the daily and weekly timeframe

Showing how the results are calculated for the weekly calculations

[image]https://www.tradingview.com/x/V8O500Es/[/image]

Enjoy :)

Best regards
Dave

## Source Code

````pine
//@version=4
//@author=Daveatt

StudyName        = "Best Volatility Calculator"
ShortStudyName   = "Best Volatility Calculator" 
study(StudyName, shorttitle=ShortStudyName, overlay=false, precision=6)

//volatility_mode     = input(defval="PIPS", title="Volatility Mode", options=["$", "PIPS", "%"])
_lookback            = input(1, title="lookback period", minval=1)
res1                = input(type=input.resolution, defval="D", title="1st resolution")
res2                = input(type=input.resolution, defval="W", title="2nd resolution")

// Utilities

//////////////////////////// MinTick ///////////////////////////

fx_pips_value = syminfo.type == "forex" ? syminfo.mintick*10 : 1

// making it no repainting
lookback = _lookback + 1

// Securities
curr_sec1 = security(symbol=syminfo.tickerid, resolution=res1, expression=close[1], lookahead=barmerge.lookahead_on)
prev_sec1 = security(symbol=syminfo.tickerid, resolution=res1, expression=close[lookback], lookahead=barmerge.lookahead_on)

curr_sec2 = security(symbol=syminfo.tickerid, resolution=res2, expression=close[1], lookahead=barmerge.lookahead_on)
prev_sec2 = security(symbol=syminfo.tickerid, resolution=res2, expression=close[lookback], lookahead=barmerge.lookahead_on)

// Caculation

// vol_pips     = volatility_mode == "PIPS"
// vol_currency = volatility_mode == "$"
// vol_perc     = volatility_mode == "%"

f_var_perc(_val1, _val2) =>

    _ret = ((_val2 - _val1)/_val1)*100

f_var_currency(_val1, _val2) =>

    _ret = _val2 - _val1

f_var_pips(_val1, _val2) =>

    _ret = (_val2 - _val1)/fx_pips_value

// percent variations
var_perc_1 = f_var_perc(prev_sec1, curr_sec1)
var_perc_2 = f_var_perc(prev_sec2, curr_sec2)

// currency variation
var_curr_1 = f_var_currency(curr_sec1, prev_sec1)
var_curr_2 = f_var_currency(curr_sec2, prev_sec2)

// pips variation
var_pips_1 = f_var_pips(curr_sec1, prev_sec1)
var_pips_2 = f_var_pips(curr_sec2, prev_sec2)

currency = syminfo.currency

lapos_perc = timenow + round(change(time)*10)
lapos_curr = timenow + round(change(time)*20)
lapos_pips = timenow + round(change(time)*30)
lapos_y    = 2

var label Perc_Label = na
label.delete(Perc_Label)

var label Curr_Label = na
label.delete(Curr_Label)

var label Pips_Label = na
label.delete(Pips_Label)

perc_text1  = "PERCENT Variation\n\n" + res1 + " " + tostring(var_perc_1, "#.##") + "%"
perc_text2  = "\n" + res2 + " " + tostring(var_perc_2, "#.##") + "%"
perc_text   = perc_text1 + perc_text2

Perc_Label := label.new(lapos_perc, lapos_y, perc_text, color=color.orange, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time)

curr_text1  = "CURRENCY Variation\n\n" + res1 + " " + tostring(var_curr_1, "#.#####") + " " + currency
curr_text2  = "\n" + res2 + " " + tostring(var_curr_2, "#.#####") + " " + currency
curr_text   = curr_text1 + curr_text2

Curr_Label := label.new(lapos_curr, lapos_y, curr_text, color=color.silver, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time)

pips_text1  = "PIPS Variation\n\n" + res1 + " " + tostring(var_pips_1, "#.##") + " pips"
pips_text2  = "\n" + res2 + " " + tostring(var_pips_2, "#.##") + " pips"
pips_text   = pips_text1 + pips_text2

Pips_Label := label.new(lapos_pips, lapos_y, pips_text, color=color.orange, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time)
````

# Best Volatility Calculator (Multi Instruments)

- url: https://www.tradingview.com/script/Logz3JbV-Best-Volatility-Calculator-Multi-Instruments/
- type: indicator
- pine_id: PUB;vw44SgFbdU5MGvqi8iVFmQ0h78pdhR6r
- version: 1.0

## Description

Hello traders 

[b]A bit of context[/b]

Definition: Volatility is defined as the close of current candle - close of the previous N candle

This is an alternative version of my [url=https://www.tradingview.com/script/0U6idkSW-Best-Volatility-Calculator]Best Volatility Calculator[/url]
The other version is displayed on a panel below. This one overlays on the chart using the "overlay=true" setting

This indicator shows the average volatility, of last N Periods, for the selected time frames and for 2 selected instruments.

You can select up to 2 timeframes with this version

Presented as Currency, Pip, percentage labels in a panel below.
Will calculate in real-time only for the current instrument on the chart.

The indicator is coded to not be repainting

[b]Example[/b]

In the indicator screenshot, I used a lookback period of 1.
That compares the current candle close versus the previous one for the daily and weekly timeframe

Showing how the results look like using FOREX instruments (where using the PIPS labels make more sense than with cryptocurrency assets)

[image]https://www.tradingview.com/x/nfqU1tGs/[/image]

Best regards
Dave

## Source Code

````pine
//@version=4
//@author=Daveatt

StudyName        = "Best Volatility Calculator (Multi Instruments)"
ShortStudyName   = "Best Volatility Calculator+" 
study(StudyName, shorttitle=ShortStudyName, overlay=true, precision=6)

//volatility_mode     = input(defval="PIPS", title="Volatility Mode", options=["$", "PIPS", "%"])
_lookback            = input(1, title="lookback period", minval=1)
sec01               = input(defval="BINANCE:BTCUSDT", type=input.symbol)
sec02               = input(defval="BINANCE:ETHUSDT", type=input.symbol)

res1                = input(type=input.resolution, defval="D", title="1st resolution")
res2                = input(type=input.resolution, defval="W", title="2nd resolution")

// Utilities

//////////////////////////// MinTick ///////////////////////////

fx_pips_value = syminfo.type == "forex" ? syminfo.mintick*10 : 1

// making it no repainting
lookback = _lookback + 1

// Securities
curr_sec1_res1 = security(symbol=sec01, resolution=res1, expression=close[1], lookahead=barmerge.lookahead_on)
prev_sec1_res1 = security(symbol=sec01, resolution=res1, expression=close[lookback], lookahead=barmerge.lookahead_on)

curr_sec1_res2 = security(symbol=sec01, resolution=res2, expression=close[1], lookahead=barmerge.lookahead_on)
prev_sec1_res2 = security(symbol=sec01, resolution=res2, expression=close[lookback], lookahead=barmerge.lookahead_on)

curr_sec2_res1 = security(symbol=sec02, resolution=res1, expression=close[1], lookahead=barmerge.lookahead_on)
prev_sec2_res1 = security(symbol=sec02, resolution=res1, expression=close[lookback], lookahead=barmerge.lookahead_on)

curr_sec2_res2 = security(symbol=sec02, resolution=res2, expression=close[1], lookahead=barmerge.lookahead_on)
prev_sec2_res2 = security(symbol=sec02, resolution=res2, expression=close[lookback], lookahead=barmerge.lookahead_on)


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
var_perc_sec1_res1 = f_var_perc(prev_sec1_res1, curr_sec1_res1)
var_perc_sec1_res2 = f_var_perc(prev_sec1_res2, curr_sec1_res2)

var_perc_sec2_res1 = f_var_perc(prev_sec2_res1, curr_sec2_res1)
var_perc_sec2_res2 = f_var_perc(prev_sec2_res2, curr_sec2_res2)

// currency variation
var_curr_sec1_res1 = f_var_currency(curr_sec1_res1, prev_sec1_res1)
var_curr_sec1_res2 = f_var_currency(curr_sec1_res2, prev_sec1_res2)

var_curr_sec2_res1 = f_var_currency(curr_sec2_res1, prev_sec2_res1)
var_curr_sec2_res2 = f_var_currency(curr_sec2_res2, prev_sec2_res2)

// pips variation
var_pips_sec1_res1 = f_var_pips(curr_sec1_res1, prev_sec1_res1)
var_pips_sec1_res2 = f_var_pips(curr_sec1_res2, prev_sec1_res2)

var_pips_sec2_res1 = f_var_pips(curr_sec2_res1, prev_sec2_res1)
var_pips_sec2_res2 = f_var_pips(curr_sec2_res2, prev_sec2_res2)

currency = syminfo.currency

lapos_perc = timenow + round(change(time)*15)
lapos_curr = timenow + round(change(time)*30)
lapos_pips = timenow + round(change(time)*45)
lapos_y    = highest(50)

var label Perc_Label = na
label.delete(Perc_Label)

var label Curr_Label = na
label.delete(Curr_Label)

var label Pips_Label = na
label.delete(Pips_Label)

perc_text1  = "PERCENT Variation\n\n" 
perc_text2  = sec01 + "\n"
perc_text3  = "\nTimeframe 1: " + res1 + " " + tostring(var_perc_sec1_res1, "#.##") + "%"
perc_text4  = "\nTimeframe 2: " + res2 + " " + tostring(var_perc_sec1_res2, "#.##") + "%"
perc_text5  = "\n\n" + sec02  + "\n"
perc_text6  = "\nTimeframe 1: " + res1 + " " + tostring(var_perc_sec2_res1, "#.##") + "%"
perc_text7  = "\nTimeframe 2: " + res2 + " " + tostring(var_perc_sec2_res2, "#.##") + "%"

perc_text   = perc_text1 + perc_text2 + perc_text3 + perc_text4 + perc_text5 + perc_text6 + perc_text7

Perc_Label := label.new(lapos_perc, lapos_y, perc_text, color=color.orange, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time)

curr_text1  = "CURRENCY Variation\n\n"
curr_text2  = sec01  + "\n"
curr_text3  = "\nTimeframe 1: " + res1 + " " + tostring(var_curr_sec1_res1, "#.#####") + " " + currency
curr_text4  = "\nTimeframe 2: " + res2 + " " + tostring(var_curr_sec1_res2, "#.#####") + " " + currency
curr_text5  = "\n\n" + sec02  + "\n"
curr_text6  = "\nTimeframe 1: " + res1 + " " + tostring(var_curr_sec2_res1, "#.#####") + " " + currency
curr_text7  = "\nTimeframe 2: " + res2 + " " + tostring(var_curr_sec2_res2, "#.#####") + " " + currency

curr_text   = curr_text1 + curr_text2 + curr_text3 + curr_text4 + curr_text5 + curr_text6 + curr_text7

Curr_Label := label.new(lapos_curr, lapos_y, curr_text, color=color.silver, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time)

pips_text1  = "PIPS Variation\n\n" 
pips_text2  = sec01  + "\n"
pips_text3  = "\nTimeframe 1: " + res1 + " " + tostring(var_pips_sec1_res1, "#.##") + " pips"
pips_text4  = "\nTimeframe 2: " + res2 + " " + tostring(var_pips_sec1_res2, "#.##") + " pips"
pips_text5  = "\n\n" + sec02  + "\n"
pips_text6  = "\nTimeframe 1: " + res1 + " " + tostring(var_pips_sec2_res1, "#.##") + " pips"
pips_text7  = "\nTimeframe 2: " + res2 + " " + tostring(var_pips_sec2_res2, "#.##") + " pips"

pips_text   = pips_text1 + pips_text2 + pips_text3 + pips_text4 + pips_text5 + pips_text6 + pips_text7

Pips_Label := label.new(lapos_pips, lapos_y, pips_text, color=color.orange, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time)
````

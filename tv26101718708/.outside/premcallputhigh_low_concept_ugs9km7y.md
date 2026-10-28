# PREM_CALL&PUT_HIGH LOW CONCEPT

- url: https://www.tradingview.com/script/UGs9kM7y-PREM-CALL-PUT-HIGH-LOW-CONCEPT/
- type: indicator
- pine_id: PUB;832065c20ae4414cacaebf2579e62ba9
- version: 2.0

## Description

In financial options trading, Call and Put are the two primary types of contracts. They give a trader the right (but not the obligation) to buy or sell an underlying asset at a predetermined price, regardless of what the market does.Call: You profit if the asset's price goes UP. You are betting on upward price movement (bullish).Put: You profit if the asset's price goes DOWN. You are betting on downward price movement (bearish).

eg: In NIFTY50 option trading first set expiry month and date in Input page then choose ATM strike price above and below rounded level premium srike pice for eg: ATM in nifty 23450, then choose Call at 23400 and Put at 23500 so we get both high & low crossing level and meeting point also

## Source Code

````pine
//@version=6
indicator("PK", overlay=true,
     max_bars_back=1000, max_lines_count=500,
     max_labels_count=500, max_boxes_count=500)

length = input.int(5, "How many previous days?", minval=1, maxval=200)
       
    // Detect first candle of the day
isNewDay = ta.change(time("D"))

// Store opening candle values
var float oHigh = na
var float oLow  = na
var float oClose = na
var float oOpen = na

if bool (isNewDay)
    oHigh  := high
    oLow   := low
    oClose := close
    oOpen := open

ph = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pl = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
po = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)

avgClose = ta.sma(pc, length)

plot(ph,title="ph", color=color.rgb(41, 5, 249), linewidth=2, style=plot.style_linebr)
plot(pl, title="pl", color=color.rgb(5, 111, 242), linewidth=2, style=plot.style_linebr)
plot(pc, title="pc", color=color.rgb(253, 5, 59), linewidth=2, style=plot.style_linebr)
plot(oHigh, title="OH", color=color.rgb(250, 248, 248), linewidth=1, style=plot.style_linebr)
plot(oLow, title="OL", color=color.rgb(250, 249, 249), linewidth=1, style=plot.style_linebr)
// Inputs for option details
expiry = input.string("260616", title="NIFTY:Expiry (yymmdd)")
callstrike = input.int(24000, title="NIFTY:Call Strike Price", minval=1)
putstrike = input.int(24000, title="NIFTY:Put Strike Price", minval=1)

// Construct option symbols
call_sym = "NSE:NIFTY" + expiry + "C" + str.tostring(callstrike)
put_sym =  "NSE:NIFTY" + expiry + "P" + str.tostring(putstrike)

// Previous day values for underlying (Nifty)

prev_close = request.security(syminfo.tickerid, "D", close[1])


// Using request.security to get the 'open' from the daily ('D') timeframe

call_close = request.security(call_sym, "D", close[1], lookahead=barmerge.lookahead_on)
call_low = request.security(call_sym, "D", low, lookahead=barmerge.lookahead_on)
call_high = request.security(call_sym, "D", high, lookahead=barmerge.lookahead_on)

put_close  = request.security(put_sym, "D", close[1], lookahead=barmerge.lookahead_on)
put_low = request.security(put_sym, "D", low, lookahead=barmerge.lookahead_on)
put_high = request.security(put_sym, "D", high, lookahead=barmerge.lookahead_on)
// Option values

prev_close_call = request.security(call_sym, "D", close)

prev_close_put = request.security(put_sym, "D", close)

avg_cpc = (prev_close_call + prev_close_put) / 2


// Plot the averages as horizontal lines

plot(avg_cpc, title="CPC", color=color.rgb(240, 236, 6), linewidth=2,style=plot.style_linebr)
plot(call_low, title="CL", color=color.rgb(4, 238, 164), linewidth=2,style=plot.style_linebr)
plot(call_high, title="CH", color=color.rgb(58, 238, 4), linewidth=2,style=plot.style_linebr)
plot(put_low, title="PL", color=color.rgb(248, 4, 195), linewidth=2,style=plot.style_linebr)
plot(put_high, title="PH", color=color.rgb(240, 10, 6), linewidth=2,style=plot.style_linebr)

// ══════════════════════════════════════════════════════════════
````

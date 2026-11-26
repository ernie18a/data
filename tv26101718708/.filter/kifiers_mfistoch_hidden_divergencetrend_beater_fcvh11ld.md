# Kifier's MFI/STOCH Hidden Divergence/Trend Beater

- url: https://www.tradingview.com/script/FCVH11LD-Kifier-s-MFI-STOCH-Hidden-Divergence-Trend-Beater/
- type: strategy
- pine_id: PUB;4e850443dc1b4b6ebc15d8393b860666
- version: 1.0

## Description

[b]MFI/STOCH Hidden Divergence/Trend Beater[/b]

[i]General Idea:[/i]
My premise around this strategy was to make a general strategy for crypto that would help out with finding entry positions for when you’re bullish on a crypto and want to hold on for a while, and at the same time avoiding massive drops. Essentially a way to mix long term/ swing trading; I somewhat achieved my goal however it still requires a lot of logic tuning of the trend averages. 
I’m a huge proponent of volume indicators and coupled with average closing price, I think this gives a really good idea of what is happening with the market. It gives an idea on the market and retail investor sentiment. This generally gives you logical entry positions (Although I don’t know how amazing that will work with all cryptos, there’s a fine line between a good strategy and one that just rides bubble market conditions, some would argue that’s still a success and others not)

[i]How it works:[/i]
There are many components to the strategy that try to do different things:

First of all there are two types of entries, a MFI hidden divergence with a STOCH check, essentially it will only fire when a divergence is detected while STOCH is above 50%, however this might be changed in the future as due to the volatile nature of cryptos, the STOCH is not too effective. The second entry is a simple MFI/STOCH trend, if STOCH is above 50% and the trend is detected to be in a trending long, once a MFI crossover over the 50% line is detected an entry is placed, this is designed to get out profit where the divergence would otherwise be less accurate during strongly trending conditions.

-MFI is a great indicator, as a volume weighted momentum indicator I find it the most accurate of all, the STOCH however is a great indicator to get a general picture of simple market conditions and can filter out the emotional noise of retail investors.

-VWMA and an SMA (The bottom oscillator) gives an idea of the trend tacking into account of the volume, this serves as a more short term filter of the trend for filters.

-OBV checks are done between the OBV and an EMA of the OBV, to get the idea of a volume weighted long trend, which is important for crypto as there are massive rallies to go up due to retail greed, it’s great to jump onto it at the beginning, and get off before the stack of cards fall apart.

-ATR is used to detect when the market is relatively just ranging or moving sideways, which is where the hidden divergence entries are done, during predictable and profitable market conditions.

- Stop loss is based on the closest support of the entry, this is a nice medium of room to breath but also an actual stop loss. 
Future plans and improvements:

Currently there’s a lot I want to improve, mostly the divergence detection and the overall sharpe ratio could be much better, but the current value of 0.5 gives me hope that the strategy is onto something. I also want to change TP from a percentage stop to something more dynamic but that might be too optimistic. The current plan is to paper trade test this either by manual or by a python bot, to see how it performs with some user input as well.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kifier

//@version=4
strategy("Kifier's MFI/STOCH Hidden Divergence/Trend Beater", shorttitle = "Kifier's MFI/STOCH", overlay=false, margin_long=100, margin_short=100, default_qty_type  = strategy.percent_of_equity, default_qty_value = 95, max_boxes_count = 500)

//Values
enb_date     = input(false                                  ,"Enable Date Range?",      type = input.bool, inline = "1")
enb_current  = input(true                                   ,"Today as End Date" ,      type = input.bool, inline = "1")
i_start_date = input(timestamp("01 Jan 2021 00:00 +0300")   ,"Start Date"        ,      type=input.time)
i_end_date   = input(timestamp("16 July 2021 00:00 +0300")  ,"End Date"          ,      type=input.time)

time_check   = iff(enb_date ? (time >= i_start_date) and (enb_current ? true : time <= i_end_date) : true, true, false)

i_vwma_length   = input(50,     "VWMA Length"               ,type = input.integer,   group = "Indicator Settings", inline = "2")
i_sma_length    = input(50,     "SMA Length"                ,type = input.integer,   group = "Indicator Settings", inline = "2")
i_stoch_length  = input(28,     "Stoch Length"              ,type = input.integer,   group = "Indicator Settings", inline = "3")
i_mfi_length    = input(7 ,     "MFI Length"                ,type = input.integer,   group = "Indicator Settings", inline = "3")
i_obv_length    = input(100,    "OBV Length"                ,type = input.integer,   group = "Indicator Settings")
i_atr_len       = input(100,    "ATR Ranging-trend len"     ,type = input.integer,   group = "Indicator Settings", tooltip = "This is the length of the ATR Emas that check when the market in a general trend or is just ranging")


i_div_price     = input(5       ,"Price Divergant Pivots"   ,type = input.integer, group = "Divergance Settings")
i_inacc         = input(0.05    ,"Price Inaccuracy"         ,type = input.float  , group = "Divergance Settings")
i_div_length    = input(3       ,"Divergance Valid Period"  ,type = input.integer, group = "Divergance Settings")
i_mfi_left      = input(5       ,"MFI Left/Right Pivots"    ,type = input.integer, group = "Divergance Settings", inline = "4")
i_mfi_right     = input(2       ,""                         ,type = input.integer, group = "Divergance Settings", inline = "4")

tp_percentage   = input(10  ,   "TP Percentage"         ,type = input.float             , group = "Exit Settings")/100
_inacc          = input(0.03,   "Support Inaccuracy"    ,type = input.float, step = 0.01, group = "Exit Settings")

enb_stoch_mfi     = input(true, "Use Stoch/MFI Trend"      , type = input.bool, group = "Individual Entries")
enb_stoch_mfi_div = input(true, "Use Stoch/MFI Divergance ", type = input.bool, group = "Individual Entries")

c_mfi           = input(color.yellow    ,"MFI/STOCH Colour     "        , type = input.color, group = "Indicator Colours", inline = "os")
c_stoch         = input(color.silver    ,""                             , type = input.color, group = "Indicator Colours", inline = "os")
c_buy           = input(color.green     ,"Buy/Sell Colour      "        , type = input.color, group = "Indicator Colours", inline = "pos")
c_sell          = input(color.red       ,""                             , type = input.color, group = "Indicator Colours", inline = "pos")
c_flat          = input(color.blue      ,"Flat/Trending Colours"        , type = input.color, group = "Indicator Colours", inline = "trend")
c_longtrend     = input(color.green     ,""                             , type = input.color, group = "Indicator Colours", inline = "trend")

//Global Variables
var float tpprice = na 

f_c_gradientAdvDec(_source, _center, _c_bear, _c_bull) =>
    var float _maxAdvDec = 0.
    var float _qtyAdvDec = 0.
    bool  _xUp     = crossover(_source, _center)
    bool  _xDn     = crossunder(_source, _center)
    float _chg     = change(_source)
    bool  _up      = _chg > 0
    bool  _dn      = _chg < 0
    bool  _srcBull = _source > _center
    bool  _srcBear = _source < _center
    _qtyAdvDec := 
      _srcBull ? _xUp ? 1 : _up ? _qtyAdvDec + 1 : _dn ? max(1, _qtyAdvDec - 1) : _qtyAdvDec :
      _srcBear ? _xDn ? 1 : _dn ? _qtyAdvDec + 1 : _up ? max(1, _qtyAdvDec - 1) : _qtyAdvDec : _qtyAdvDec
    _maxAdvDec := max(_maxAdvDec, _qtyAdvDec)
    float _transp = 100 - (_qtyAdvDec * 100 / _maxAdvDec)
    var color _return = na
    _return := _srcBull ? color.new(_c_bull, _transp) : _srcBear ? color.new(_c_bear, _transp) : _return

//Simple Sup/Res
var float _pH = na
var float _pL = na
_ph = pivothigh(high,20,20)
_pl = pivotlow(low,20,20)
_high_inacc = _inacc * high
_low_inacc = _inacc * low

if _ph
    _pH := high
if (high-_high_inacc) > _pH and _ph
    _pH := high
    _pH := nz(_pH)

if _pl
    _pL := low
if (low+_low_inacc) < _pL[1] 
    _pL := low
    _pL := nz(_pL)  

broke_res = iff(crossover(close, _pH), true, false)

//Indicator Initialisation
s_stoch = stoch(close, high, low, i_stoch_length) 
s_vwma = vwma(close,i_vwma_length)
s_sma = sma(close,i_sma_length)

//MONEY FLOW + BBW
atr1 =ema((atr(14)/close),i_atr_len/2)
atr2 =ema((atr(14)/close), i_atr_len)
is_ranging = iff(atr1 < atr2, true, false)
s_mfi = mfi(close,i_mfi_length)
overTop = iff(s_mfi >= 90, true, false)
underBot = iff(s_mfi <= 10, true, false)

//Price Divergance
ph = pivothigh(high, i_div_price,i_div_price)
pl = pivotlow(low,i_div_price,i_div_price)

var float pH = 0.0
var float pL = 0.0

high_acc = high * (i_inacc)
low_acc = low * i_inacc

if (high-high_acc) > pH or (high+high_acc < pH) and ph
    pH := high
    pH := nz(pH)
if (low+low_acc) < pL or (low-low_acc > pL) and pl
    pL := low
    pL := nz(pL)

higher_low = false
lower_low = false
//Filter out innacurate
if ph or pl
    if pL < pL[1]
        lower_low := true
    if pL > pL[1]
        higher_low := true
        
//MFI Divergance
mh = pivothigh(s_mfi, i_mfi_left,i_mfi_right)
ml = pivotlow(s_mfi, i_mfi_left,i_mfi_right)
bl = bar_index

var float mH = 0.0
var float mL = 0.0
var int bL = 0

if mh
    mH := highest(nz(mh),i_mfi_left)
    mH := nz(mH)
if ml
    bL := bar_index
    mL := ml
    mL := nz(mL)

higher_low_m = false
lower_low_m = false

if ml 
    if mL < mL[1]
        lower_low_m := true
    if mL > mL[1]
        higher_low_m := true

//Combintion
var int price_range = na
var int rsi_range = na
var int mfi_range = na

//Higher low on price, lower low on rsi, then check with stoch
mfi_div_bullish = iff(higher_low and higher_low_m, true, false)

if mfi_div_bullish
    price_range := 0
    rsi_range := 0

//VWMA/SMA/OBV
_src = s_vwma-s_sma
sd_src = stdev(_src,14)
pooled_src = (_src/sd_src)*2

sd_s_vwma = stdev(s_vwma,14)
sd_s_sma = stdev(s_sma,14)

longTrend = obv > ema(obv,100) and is_ranging == false
crossOver = crossover(s_vwma , s_sma)
crossingOver = (s_vwma > s_sma) and (close >= s_vwma) 
crossUnder = crossunder(s_vwma, s_sma)
crossingUnder = (s_vwma < s_sma) and (close <= s_vwma)

hist_color = f_c_gradientAdvDec(s_vwma-s_sma, (s_vwma-s_sma)/2, color.new(c_sell,90), color.new(c_buy,80))

//Strategy Entries
mfi_stoch_trend = iff(enb_stoch_mfi, iff(s_stoch >= 50 and crossover(s_mfi, 50) and crossingOver and longTrend and is_ranging == false, true, false), false)

var buy_counter_rsi = 0
var buy_counter_mfi = 0

mfi_div = iff(enb_stoch_mfi_div, iff(mfi_div_bullish and crossingOver and s_stoch >= 50 and is_ranging, true, false), false)

if mfi_div
    buy_counter_mfi := bar_index + 5
    
mfi_divergent_buy = iff(bar_index <= buy_counter_mfi and strategy.position_size == 0, true, false)

//Strategy Entries
order_fired = false
var float previousRes = 0.0

tpprice := strategy.position_avg_price * (1+tp_percentage)
if time_check
    if mfi_stoch_trend
        strategy.entry("Buy", true, comment = "[B] STOCH/MFI")
        order_fired := true
    if mfi_divergent_buy
        strategy.entry("Buy", true, comment = "[B] MFI Hidden Divergance")
        order_fired := true
        
    if order_fired 
        previousRes := _pL
    if strategy.position_size > 0
        strategy.exit("Buy", limit = tpprice, comment = "TP")
    if close <= previousRes 
        strategy.exit("Buy", stop = previousRes, comment = "SL")
        
//Drawings
hline(0, "Base", color.white)
hline(100, "Max", color.white)

p_stoch = plot(s_stoch, color = c_stoch)
p_mfi = plot(s_mfi, color = c_mfi)

hline(70, "Top Line")
p_mid = plot(50, "Mid Line", color.new(color.white,100))
hline(50, "Mid Line")
hline(30, "Bot Line")
fill(p_stoch, p_mid, color.new(c_stoch, 60))

plotshape(crossOver ? 5 : crossUnder ? -5 : na, style = shape.square, color = crossOver ? c_buy : crossUnder ? c_sell : na, size = size.tiny, location = location.absolute)
plot((_src/sd_src)*2, color = hist_color, style = plot.style_histogram)

//Boxes
var string same = ""

var box _box = na
if longTrend and is_ranging == false and same != "longtrend"
    same := "longtrend"
    _box := box.new(bar_index, 105, bar_index, 100, bgcolor = c_longtrend,border_color = color.new(color.white, 100))
else if is_ranging and same != "isranging"
    same := "isranging"
    _box := box.new(bar_index, 105, bar_index, 100, bgcolor = c_flat,border_color = color.new(color.white, 100))

if not na(_box)
    box.set_right(_box,bar_index)

//Div Lines
var line _line = na
if mfi_divergent_buy
    _line = line.new(bL[1] -6, s_mfi[bar_index-bL[1]], bar_index + 6, s_mfi, color = color.green, width = 3)
````

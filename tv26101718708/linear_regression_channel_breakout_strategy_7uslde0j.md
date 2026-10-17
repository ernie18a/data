# Linear Regression Channel Breakout Strategy

- url: https://www.tradingview.com/script/7USLDe0j/
- type: strategy
- pine_id: PUB;3a1cf288004f4e2b802dbc6db8322af6
- version: 3.0

## Description

This strategy is based on LonesomeTheBlue's Linear Regression Channel Indicator. First of all, I would like to thank LonesomeTheBlue. Breaking the Linear Regression Channel to close the candle triggers a Long or Short signal. If the slope of the Linear Regression Channel is positive, it is Short when it breaks out the lower line, and when the slope is negative, it is Long when it breaks out the upper line. The default is optimized for 8-hour candles, and for other hour candles, find the optimal value yourself. Below is a description of LonesomeTheBlue's Linear Regression Channel.
이 전략은 LonesomeTheBlue의 Linear Regression Channel Indicator를 기반으로 만들어졌습니다. 우선 LonesomeTheBlue님께 감사의 말씀을 드립니다. Linear Regression Channel을 돌파하여 봉 마감하면 Long 또는 Short 신호를 트리거합니다. Linear Regression Channel의 기울기가 양인 경우 하단 라인을 돌파하면 Short이고 그 기울기가 음인 경우 상단 라인을 돌파하면 Long입니다. 기본값은 8시간봉에 최적화 되어 있으며, 다른 시간봉은 직접 최적값을 찾아보십시오. 아래는 LonesomeTheBlue의 Linear Regression Channel에 대한 설명을 퍼왔습니다.
________________________________________________
There are several nice Linear Regression Channel scripts in the Public Library. and I tried to make one with some extra features too. This one can check if the Price breaks the channel and it shows where is was broken. Also it checks the momentum of the channel and shows it's increasing/decreasing/equal in a label, shape of the label also changes. The line colors change according to direction.

using the options, you can;
- Set the Source (Close, HL2 etc)
- Set the Channel length
- Set Deviation
- Change Up/Down Line colors
- Show/hide broken channels
- Change line width

meaning of arrows:
⇑ : Uptrend and moment incresing
⇗ : Uptrend and moment decreasing
⇓ : Downtrend and moment incresing
⇘ : Downtrend and moment decreasing
⇒ : No trend

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue © chanu_lev10k

//@version=5
strategy('Linear Regression Channel Breakout Strategy', overlay=true)
src = input(defval=close, title='Source')
len = input.int(defval=20, title='Length', minval=10)
devlen = input.float(defval=2.3, title='Deviation', minval=0.1, step=0.1)
extendit = input(defval=true, title='Extend Lines')
showfibo = input(defval=false, title='Show Fibonacci Levels')
showbroken = input.bool(defval=true, title='Show Broken Channel', inline='brk')
brokencol = input.color(defval=color.blue, title='', inline='brk')
upcol = input.color(defval=color.lime, title='Up/Down Trend Colors', inline='trcols')
dncol = input.color(defval=color.red, title='', inline='trcols')
widt = input(defval=2, title='Line Width')

// 추가된 스탑로스와 테이크 프로핏 기능
enable_stop_loss = input.bool(false, title='Enable Stop Loss')
enable_take_profit = input.bool(true, title='Enable Take Profit')
stop_loss_pct = input.float(10.0, title='Stop Loss %', step=0.1) / 100
take_profit_pct = input.float(11.0, title='Take Profit %', step=0.1) / 100

var fibo_ratios = array.new_float(0)
var colors = array.new_color(2)
if barstate.isfirst
    array.unshift(colors, upcol)
    array.unshift(colors, dncol)
    array.push(fibo_ratios, 0.236)
    array.push(fibo_ratios, 0.382)
    array.push(fibo_ratios, 0.618)
    array.push(fibo_ratios, 0.786)

get_channel(src, len) =>
    mid = math.sum(src, len) / len
    slope = ta.linreg(src, len, 0) - ta.linreg(src, len, 1)
    intercept = mid - slope * math.floor(len / 2) + (1 - len % 2) / 2 * slope
    endy = intercept + slope * (len - 1)
    dev = 0.0
    for x = 0 to len - 1 by 1
        dev += math.pow(src[x] - (slope * (len - x) + intercept), 2)
        dev
    dev := math.sqrt(dev / len)
    [intercept, endy, dev, slope]

[y1_, y2_, dev, slope] = get_channel(src, len)

outofchannel = slope > 0 and close < y2_ - dev * devlen ? 0 : slope < 0 and close > y2_ + dev * devlen ? 2 : -1

var reglines = array.new_line(3)
var fibolines = array.new_line(4)
for x = 0 to 2 by 1
    if not showbroken or outofchannel != x or nz(outofchannel[1], -1) != -1
        line.delete(array.get(reglines, x))
    else
        line.set_color(array.get(reglines, x), color=brokencol)
        line.set_width(array.get(reglines, x), width=2)
        line.set_style(array.get(reglines, x), style=line.style_dotted)
        line.set_extend(array.get(reglines, x), extend=extend.none)

    array.set(reglines, x, line.new(x1=bar_index - (len - 1), y1=y1_ + dev * devlen * (x - 1), x2=bar_index, y2=y2_ + dev * devlen * (x - 1), color=array.get(colors, math.round(math.max(math.sign(slope), 0))), style=x % 2 == 1 ? line.style_solid : line.style_dashed, width=widt, extend=extendit ? extend.right : extend.none))
if showfibo
    for x = 0 to 3 by 1
        line.delete(array.get(fibolines, x))
        array.set(fibolines, x, line.new(x1=bar_index - (len - 1), y1=y1_ - dev * devlen + dev * devlen * 2 * array.get(fibo_ratios, x), x2=bar_index, y2=y2_ - dev * devlen + dev * devlen * 2 * array.get(fibo_ratios, x), color=array.get(colors, math.round(math.max(math.sign(slope), 0))), style=line.style_dotted, width=widt, extend=extendit ? extend.right : extend.none))

var label sidelab = label.new(x=bar_index - (len - 1), y=y1_, text='S', size=size.large)
txt = slope > 0 ? slope > slope[1] ? '⇑' : '⇗' : slope < 0 ? slope < slope[1] ? '⇓' : '⇘' : '⇒'
stl = slope > 0 ? slope > slope[1] ? label.style_label_up : label.style_label_upper_right : slope < 0 ? slope < slope[1] ? label.style_label_down : label.style_label_lower_right : label.style_label_right
label.set_style(sidelab, stl)
label.set_text(sidelab, txt)
label.set_x(sidelab, bar_index - (len - 1))
label.set_y(sidelab, slope > 0 ? y1_ - dev * devlen : slope < 0 ? y1_ + dev * devlen : y1_)
label.set_color(sidelab, slope > 0 ? upcol : slope < 0 ? dncol : color.blue)

// Long Short conditions
longCondition = (slope < 0 and close > y2_ + dev * devlen) or (slope > 0 and close > y2_ + dev * devlen)
if longCondition
    strategy.entry('Long', strategy.long)
if strategy.position_size > 0
    entry_price = strategy.position_avg_price
    if enable_stop_loss
        strategy.exit('Long Stop Loss', 'Long', stop=entry_price * (1 - stop_loss_pct))
    if enable_take_profit
        strategy.exit('Long Take Profit', 'Long', limit=entry_price * (1 + take_profit_pct))

shortCondition = (slope > 0 and close < y2_ - dev * devlen) or (slope < 0 and close < y2_ - dev * devlen)
if shortCondition
    strategy.entry('Short', strategy.short)
if strategy.position_size < 0
    entry_price = strategy.position_avg_price
    if enable_stop_loss
        strategy.exit('Short Stop Loss', 'Short', stop=entry_price * (1 + stop_loss_pct))
    if enable_take_profit
        strategy.exit('Short Take Profit', 'Short', limit=entry_price * (1 - take_profit_pct))
````

# [fikira] Fibma/Fibema Strategy

- url: https://www.tradingview.com/script/0I6kCcYq-fikira-Fibma-Fibema-Strategy/
- type: strategy
- pine_id: PUB;qiEgYJhyNQGbpAkHQar1CvKYrifkRi9o
- version: 1.0

## Description

My strategy regarding the Fibma/Fibema lines (also see my Fibma/Fibema study)

You can enable/disable each strategy to see what 
works best in what timeframe

Thanks!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fikira

//@version=4
strategy("[fikira] Fibma/Fibema Strategy", shorttitle="Fibma/Fibema Strategy", overlay=true)

SMA = input(true, title="SMA ?")
EMA = input(false, title="EMA ?")
MA500 = input(true, title="Barcolor X MA 500 ?")
EMA500 = input(true, title="Barcolor X EMA 500 ?")

str50 = input(true, title="Strategy X MA/EMA 50")
str100 = input(true, title="Strategy X MA/EMA 100")
str236 = input(true, title="Strategy X MA/EMA 236")
str764 = input(true, title="Strategy X MA/EMA 764")
str500 = input(true, title="Strategy X MA/EMA 500")
str1000 = input(true, title="Strategy X MA/EMA 1000")


_24 = input(24, title="MA 24")
_24_ = sma(close, _24)
_38 = input(38, title="MA 38")
_38_ = sma(close, _38)
_50 = input(50, title="MA 50")
_50_ = sma(close, _50)
_62 = input(62, title="MA 62")
_62_ = sma(close, _62)
_76 = input(76, title="MA 76")
_76_ = sma(close, _76)
_100 = input(100, title="MA 100")
_100_ = sma(close, _100)
_236 = input(236, title="MA 236")
_236_ = sma(close, _236)
_382 = input(382, title="MA 382")
_382_ = sma(close, _382)
_500 = input(500, title="MA 500")
_500_ = sma(close, _500)
_618 = input(618, title="MA 618")
_618_ = sma(close, _618)
_764 = input(764, title="MA 764")
_764_ = sma(close, _764)
_1000 = input(1000, title="MA 1000")
_1000_ = sma(close, _1000)

_e24 = input(24, title="EMA 24")
_e24_ = ema(close, _e24)
_e38 = input(38, title="EMA 38")
_e38_ = ema(close, _e38)
_e50 = input(50, title="EMA 50")
_e50_ = ema(close, _e50)
_e62 = input(62, title="EMA 62")
_e62_ = ema(close, _e62)
_e76 = input(76, title="EMA 76")
_e76_ = ema(close, _e76)
_e100 = input(100, title="EMA 100")
_e100_ = ema(close, _e100)
_e236 = input(236, title="EMA 236")
_e236_ = ema(close, _e236)
_e382 = input(382, title="EMA 382")
_e382_ = ema(close, _e382)
_e500 = input(500, title="EMA 500")
_e500_ = ema(close, _e500)
_e618 = input(618, title="EMA 618")
_e618_ = ema(close, _e618)
_e764 = input(764, title="EMA 764")
_e764_ = ema(close, _e764)
_e1000 = input(1000, title="EMA 1000")
_e1000_ = ema(close, _e1000)

p24 = plot(SMA?_24_:na, color=color.blue, linewidth=0, transp=0, title="MA 24")
p38 = plot(SMA?_38_:na, color=color.yellow, linewidth=0, transp=0, title="MA 38")
plot(SMA?_50_:na, color=color.lime, linewidth=0, transp=0, title="MA 50")
p62 = plot(SMA?_62_:na, color=color.orange, linewidth=0, transp=0, title="MA 62")
p76 = plot(SMA?_76_:na, color=#EE1749, linewidth=0, transp=0, title="MA 76")
plot(SMA?_100_:na, color=color.white, linewidth=0, transp=0, title="MA 100")
p236 = plot(SMA?_236_:na, color=color.blue, linewidth=2, transp=0, title="MA 236")
p382 = plot(SMA?_382_:na, color=color.yellow, linewidth=2, transp=30, title="MA 382")
plot(SMA?_500_:na, color=color.lime, linewidth=2, transp=30, title="MA 500")
p618 = plot(SMA?_618_:na, color=color.orange, linewidth=2, transp=30, title="MA 618")
p764 = plot(SMA?_764_:na, color=#EE1749, linewidth=2, transp=30, title="MA 764")
plot(SMA?_1000_:na, color=color.white, linewidth=2, transp=30, title="MA 1000")

pe24 = plot(EMA?_e24_:na, color=color.blue, linewidth=0, transp=0, title="EMA 24")
pe38 = plot(EMA?_e38_:na, color=color.yellow, linewidth=0, transp=0, title="EMA 38")
plot(EMA?_e50_:na, color=color.lime, linewidth=0, transp=0, title="EMA 50")
pe62 = plot(EMA?_e62_:na, color=color.orange, linewidth=0, transp=0, title="EMA 62")
pe76 = plot(EMA?_e76_:na, color=#EE1749, linewidth=0, transp=0, title="EMA 76")
plot(EMA?_e100_:na, color=color.white, linewidth=0, transp=0, title="EMA 100")
pe236 = plot(EMA?_e236_:na, color=color.blue, linewidth=2, transp=0, title="EMA 236")
pe382 = plot(EMA?_e382_:na, color=color.yellow, linewidth=2, transp=30, title="EMA 382")
plot(EMA?_e500_:na, color=color.lime, linewidth=2, transp=0, title="EMA 500")
pe618 = plot(EMA?_e618_:na, color=color.orange, linewidth=2, transp=30, title="EMA 618")
pe764 = plot(EMA?_e764_:na, color=#EE1749, linewidth=2, transp=30, title="EMA 764")
plot(EMA?_e1000_:na, color=color.white, linewidth=2, transp=30, title="EMA 1000")

fill(p38, p62, _62_ > _38_ ? color.red : color.lime, transp=95, title="X MA 38/62")
fill(p382, p618, _618_ > _382_ ? color.red : color.lime, transp=95, title="X MA 382/618")
fill(p24, p76, _76_ > _24_ ? color.red : color.lime, transp=95, title="X MA 24/76")
fill(p236, p764, _764_ > _236_ ? color.red : color.lime, transp=95, title="X MA 236/764")
fill(pe38, pe62, _e62_ > _e38_ ? color.red : color.lime, transp=95, title="X EMA 38/62")
fill(pe382, pe618, _e618_ > _e382_ ? color.red : color.lime, transp=95, title="X EMA 382/618")
fill(pe24, pe76, _e76_ > _e24_ ? color.red : color.lime, transp=95, title="X EMA 24/76")
fill(pe236, pe764, _e764_ > _e236_ ? color.red : color.lime, transp=95, title="X EMA 236/764")

_500bl = SMA and MA500 and close > _500_ ? true : false
_500br = SMA and MA500 and close < _500_ ? true : false
barcolor(
 _500bl and not _500bl[1] ? color.yellow : 
 close > open and _500bl and _500bl[1] ? color.lime :
 close < open and _500bl and _500bl[1] ? color.orange :
 _500br and not _500br[1] ? color.purple : na, title="close crosses MA 500")

_e500bl = EMA and EMA500 and close > _e500_ ? true : false
_e500br = EMA and EMA500 and close < _e500_ ? true : false
barcolor(
 _e500bl and not _e500bl[1] ? color.yellow : 
 close > open and _e500bl and _e500bl[1] ? color.lime :
 close < open and _e500bl and _e500bl[1] ? color.orange :
 _e500br and not _e500br[1] ? color.purple : na, title="close crosses EMA 500")

_50bl = SMA and close > _50_ ? true : false
_50br = SMA and close < _50_ ? true : false

_100bl = SMA and close > _100_ ? true : false
_100br = SMA and close < _100_ ? true : false

_236bl = SMA and close > _236_ ? true : false
_236br = SMA and close < _236_ ? true : false

_764bl = SMA and close > _764_ ? true : false
_764br = SMA and close < _764_ ? true : false

_1000bl = SMA and close > _1000_ ? true : false
_1000br = SMA and close < _1000_ ? true : false

_e50bl = EMA and close > _e50_ ? true : false
_e50br = EMA and close < _e50_ ? true : false

_e100bl = EMA and close > _e100_ ? true : false
_e100br = EMA and close < _e100_ ? true : false

_e236bl = EMA and close > _e236_ ? true : false
_e236br = EMA and close < _e236_ ? true : false

_e764bl = EMA and close > _e764_ ? true : false
_e764br = EMA and close < _e764_ ? true : false

_e1000bl = EMA and close > _e1000_ ? true : false
_e1000br = EMA and close < _e1000_ ? true : false

// STRATEGIES

// Profit Factor is simply defined as gross profits divided by gross losses, a Profit Factor above 2 is outstanding, 
// a profit Factor of 3 means your net gains were 3 times greater than your net losses, anything above 3 is unheard of :-)
// Please check the profit factor in the D, 3D, W timeframe when for example "Strategy X MA/EMA 50" is enabled :-)
// You also can enable/disable each strategy to see what works best in what timeframe

if (str50 and _50bl and not _50bl[1])
    strategy.entry("L50", strategy.long)

if (str50 and _50br and not _50br[1])
    strategy.entry("S50", strategy.short)
    
if (str100 and _100bl and not _100bl[1])
    strategy.entry("L100", strategy.long)

if (str100 and _100br and not _100br[1])
    strategy.entry("S100", strategy.short)

if (str236 and _236bl and not _236bl[1])
    strategy.entry("L236", strategy.long)

if (str236 and _236br and not _236br[1])
    strategy.entry("S236", strategy.short)

if (str764 and _764bl and not _764bl[1])
    strategy.entry("L764", strategy.long)

if (str764 and _764br and not _764br[1])
    strategy.entry("S764", strategy.short)

if (str500 and _500bl and not _500bl[1])
    strategy.entry("L500", strategy.long)

if (str500 and _500br and not _500br[1])
    strategy.entry("S500", strategy.short)

if (str1000 and _1000bl and not _1000bl[1])
    strategy.entry("L1000", strategy.long)

if (str1000 and _1000br and not _1000br[1])
    strategy.entry("S1000", strategy.short)

if (str50 and _e50bl and not _e50bl[1])
    strategy.entry("LE50", strategy.long)

if (str50 and _e50br and not _e50br[1])
    strategy.entry("SE50", strategy.short)
    
if (str100 and _e100bl and not _e100bl[1])
    strategy.entry("LE100", strategy.long)

if (str100 and _e100br and not _e100br[1])
    strategy.entry("SE100", strategy.short)

if (str236 and _e236bl and not _e236bl[1])
    strategy.entry("LE236", strategy.long)

if (str236 and _e236br and not _e236br[1])
    strategy.entry("SE236", strategy.short)

if (str764 and _e764bl and not _e764bl[1])
    strategy.entry("LE764", strategy.long)

if (str764 and _e764br and not _e764br[1])
    strategy.entry("SE764", strategy.short)

if (str500 and _e500bl and not _e500bl[1])
    strategy.entry("LE500", strategy.long)

if (str500 and _e500br and not _e500br[1])
    strategy.entry("SE500", strategy.short)

if (str1000 and _e1000bl and not _e1000bl[1])
    strategy.entry("LE1000", strategy.long)

if (str1000 and _e1000br and not _e1000br[1])
    strategy.entry("SE1000", strategy.short)
````

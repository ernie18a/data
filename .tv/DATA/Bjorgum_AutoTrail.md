<!-- tradingview-pine-id: PUB;45fd01f8ae97439f8506d12ef7e40749 -->
<!-- tradingviewscripts-format: 1 -->
# Bjorgum AutoTrail

Source: https://www.tradingview.com/script/EfbdipVs-Bjorgum-AutoTrail/

## Description

One Time Trade Risk Management

Incorporating the new interactive feature, this script is meant as a one time trailing stop for the active trader to manage positional risk of an ongoing trade. As a crypto trader or Fx trader, many may find themselves in a position late into the evening, or perhaps daily life is calling while a trade progresses in their favor. Adding a trailing stop to a position thats trending can help to keep you in the trade and lock in gains if things turn around when you are unable to react. 

To use the trail, the user would add the script to the chart. Once added, a set of crosshairs will appear allowing the user to choose a point to begin. Often choosing to start a trail from a swing high/ low can be an ideal option. This tends to provide some protection for a stop by placing it under support for a long trade or above resistance for a short trade. 

Price based trail 

[image]https://www.tradingview.com/x/WYd3mIKK/[/image]

The trail will automatically plot and the offset is a factor of the distance from price action selected by the crosshairs. If placed above price action the script will plot a short trail, if placed below it will trail for a long position. 

Additionally, there are several other trail types other than price based. There is also percent based, which offsets the trail as a percent from close. A hard stop is placed at the cross hair value, then once the distance is exceeded by the percentage specified, the trail begins. 

There are 2 more volatility based trails. There is a PSAR trail which can provide quicker and tighter stops that accelerate with the trend locking in gains faster, and an ATR trail that keeps a distance from price action as a function of volatility. Volatility levels can be adjusted from the menu. 

Volatility based trail (ATR)

[image]https://www.tradingview.com/x/UnPSIgIf/[/image]

Volatility based trail (PSAR)

[image]https://www.tradingview.com/x/pa8ebn5s/[/image]

Lastly, within the code for more the more technical savvy, is some starting setups for string alerts to be sent to exchanges via 3rd party or custom API applications. Some string manipulation is required for specific providers to meet their requirements, but there is some building block alerts that will take the ticker symbol, recognize the asset your trading (Fx, Crypto, etc) and take input quantity or exchange names from the settings via inputs. 

Complex strings can be built to perform almost any trade related task when to comes to alerts via web hook. A little setup this way with some technology to back your system can mean a semi-automated half man, half machine setup that actually manages your trail stop while you cannot. For those that don’t go this far, there is some basic alert functionality that well trigger when a trail is hit so you can react and make a decision. 

Please note that for now, interactive mode is engaged only when the script is added to the chart. Additional stops, or for adjustments to be made it is best to add a new version. Also as real trades could be at play managing an actual position, alerts are designed to go off only once to ensure no duplicate orders are sent meaning alerts are not reoccurring. Once an alert is triggered, a new trail is to be set up. 

A modified version of the TradingView built in SAR equation was used in this script. To provide the value of the SAR on the stop candle, it was necessary to alter the equation to extract this value as the regular SAR “flips” at this point. Thank you to TradingView for supplying access to the built in formula so that this SAR could behave the same as the built-in function outside of these alterations 
 
Example of SAR value maintained in trigger candle 

[image]https://www.tradingview.com/x/TN6WRJFK/[/image]

Cheers and happy trading.

---

## Source Code

````pine
// █▀▀▄ ──▀ █▀▀█ █▀▀█ █▀▀▀ █──█ █▀▄▀█ 
// █▀▀▄ ──█ █──█ █▄▄▀ █─▀█ █──█ █─▀─█ 
// ▀▀▀─ █▄█ ▀▀▀▀ ▀─▀▀ ▀▀▀▀ ─▀▀▀ ▀───▀

//@version=5
indicator     ('Bjorgum AutoTrail', "Bj AutoTrail", overlay=true)

// ================================== //
// ------------> Tips <-------------- //
// ================================== //

barTimeTip      = "Time to start trail. Time can be interactively selected with the cursor"
priceTip        = "Price to start trail. Price can be interactively selected with the cursor"
trailTypeTip    = "4 different trail types can be used. Refer to release documentation for more info"
trailSourceTip  = "The price source for calculating trailing stop"

atrLengthTip    = "Length of the period for the ATR to average. Valid only if ATR type trail is envoked" 
atrMultTip      = "Multiplier as a function of the ATR value projected from the calculated swing high/low. ex 1 = ATR distance. Valid only if ATR type trail is envoked"
percTip         = "Percent offset from closing price. Stop will set at the cursor selected price, and trail a change in price by a factor of percent if percent trail is selected."
lookbackTip     = "Look back period to measure swing lows. A lower number brings a trail tighter to price action, where as a higher number will look back farther for significant swing points."

startTip        = "PSAR Start"
incTip          = "Step Setting (Sensitivity) - A higher step moves SAR closer to the price action, which makes a reversal more likely"
maxTip          = "PSAR Max - While the Maximum Step can influence sensitivity, the Step carries more weight"

quantityTip     = "Will fill in quantity for an alert if used"
marketTip       = "Will fill in a market for an alert if used. Ex. Spot or futures acronyms"
brokerTip       = "Will fill in a broker for a fx based alert if used"

// ================================== //
// ---------> User Input <----------- //
// ================================== //

barTime         = input.time    (0      ,   'Bar Time'      ,   group= 'Set Trade',             tooltip= barTimeTip,        inline=  '1',      confirm=true)
price           = input.price   (0      ,   'Price'         ,   group= 'Set Trade',             tooltip= priceTip,          inline=  '1',      confirm=true)
trailType       = input.string  ('Price',   'Trail Type'    ,   group= 'Set Trade',             tooltip= trailTypeTip,      options= ['ATR' , 'Percent', 'Price', 'Sar'])
trailSource     = input.string  ("High/Low","Stop Source"   ,   group= "Set Trade",             tooltip= trailSourceTip,    options= ["High/Low", "Close", "Open"])

atrLength       = input.int     (14     ,   'ATR Length'    ,   group= 'Trail Offset',          tooltip= atrLengthTip)
atrMult         = input.float   (1      ,   'ATR Multiplier',   group= 'Trail Offset',          tooltip= atrMultTip)
perc            = input.float   (2.0    ,   'Percent Trail' ,   group= 'Trail Offset',          tooltip= percTip)
lookback        = input.int     (5      ,   'Lookback'      ,   group= 'Trail Offset',          tooltip= lookbackTip)

start           = input.float   (0.043  ,   'Start'         ,   group= 'Psar Settings',         tooltip= startTip) 
inc             = input.float   (0.043  ,   'inc'           ,   group= 'Psar Settings',         tooltip= incTip)
max             = input.float   (0.34   ,   'max'           ,   group= 'Psar Settings',         tooltip= maxTip)
    
longCol         = input.color   (#64b5f6,   ''              ,   group= 'Stop Color',            inline='2')
ShortCol        = input.color   (#ef5350,   ''              ,   group= 'Stop Color',            inline='2')
lineWidth       = input.int     (2      ,   ''              ,   group= 'Stop Color',            inline='2')
transp          = input.int     (0      ,   ''              ,   group= 'Stop Color',            inline='2')

quantity        = input.float   (0.001  ,   'Quantity'      ,   group= 'Live Trade Metrics',    tooltip= quantityTip)
market          = input.string  ('usdm' ,   'Market'        ,   group= 'Live Trade Metrics',    tooltip= marketTip)
broker          = input.string  ('Test' ,   'Broker'        ,   group= 'Live Trade Metrics',    tooltip= brokerTip)

// ================================== //
// -----> Invariable Constants <----- //
// ================================== //

var color       lColor          = color.new(longCol,  transp)
var color       sColor          = color.new(ShortCol, transp)
var int         trade           = 0
var float       trailPrice      = 0.0
var float       initSrc         = 0.0
var float       initHigh        = 0.0
var float       initLow         = 0.0
var bool        long            = false
var bool        short           = false
var bool        oneTime         = true
var bool        psar            = trailType == 'Sar'
var bool        atrTrail        = trailType == 'ATR'
var bool        percTrail       = trailType == 'Percent' 
float           tTrailPrice     = 0.0
 
var float       sar             = na
var float       maxMin          = na
var float       accel           = na
var bool        isBelow         = na
var float       lsar            = 0.0
bool            isFirstTrendBar = false

// ================================== //
// ----> Variable Calculations <----- //
// ================================== //

    // PSAR Calcualtion // 

if bar_index            == 1
	if close > close[1]
		isBelow         := true
		maxMin          := high
		sar             := low[1]
	else
		isBelow         := false
		maxMin          := low
		sar             := high[1]
	isFirstTrendBar     := true
	accel               := start

sar                     := sar + accel * (maxMin - sar)
lsar                    := sar
if isBelow
	if sar > low
		isFirstTrendBar := true
		isBelow         := false
		sar             := math.max(high, maxMin)
		maxMin          := low
		accel           := start
else
	if sar < high
		isFirstTrendBar := true
		isBelow         := true
		sar             := math.min(low, maxMin)
		maxMin          := high
		accel           := start
		
if not isFirstTrendBar
	if isBelow
		if high > maxMin
			maxMin      := high
			accel       := math.min(accel + inc, max)
	else
		if low < maxMin
			maxMin      := low
			accel       := math.min(accel + inc, max)

if isBelow
	sar                 := math.min(sar, low[1])
	if bar_index > 1
		sar             := math.min(sar, low[2])
else
	sar                 := math.max(sar, high[1])
	if bar_index > 1
		sar             := math.max(sar, high[2])
    sar

// ================================== //
// ----> Conditional Parameters <---- //
// ================================== //

timeStart               = time_close[1] <= barTime and time >= barTime

if timeStart
    long                := price < close 
    short               := price > close 
    initSrc             := trailSource == "Close" ? close : trailSource == "Open"  ? open : long ? low : high
    initHigh            := high
    initLow             := low
    if long 
        trade           :=  1
    if short
        trade           := -1 

atr                     = ta.atr (atrLength)

trailSrc                = trailSource == "Close" ? close[1] : trailSource == "Open"  ? open[1] : long ? low : high

diff                    = math.abs(initSrc-price)

offset                  = percTrail ? close * (perc/100) :
                          atrTrail  ? atr   *  atrMult   : diff

swingLow                = ta.lowest  (trailSrc, lookback) - (offset)
swingHigh               = ta.highest (trailSrc, lookback) + (offset) 

sarTrail                = ((long and isBelow) or (short and not isBelow))  

levelCheck              = (long and price < swingLow) or (short and price > swingHigh)

tTrailPrice             := psar and sarTrail ? sar : 
                           timeStart and not levelCheck ? price : 
                           long ? swingLow : short ? swingHigh : 0

// ================================== //
// --------> Logical Order <--------- //
// ================================== //

if time >= barTime and (psar or barstate.isconfirmed)
    if long and trade   == 1
        if  tTrailPrice  > trailPrice or trailPrice == 0.0 
            trailPrice  := tTrailPrice
            
        if low <= trailPrice 
            trade       := 0

        if  isBelow[1] and psar and not isBelow and (trade != 0)[1]
            trade       := 0
    
    if short and trade  == -1 
        if  tTrailPrice  < trailPrice or trailPrice == 0.0 
            trailPrice  := tTrailPrice

        if high >= trailPrice 
            trade       := 0

        if isBelow and not isBelow[1] and psar and (trade != 0)[1]
            trade       := 0

// ================================== //
// ------> Graphical Display <------- //
// ================================== //

longSig     = (trade ==  1)[1] and low  <= trailPrice 
shortSig    = (trade == -1)[1] and high >= trailPrice

psarSig     = psar    and (trade !=  trade[1])  and    (trade       != 0)[1]
plotPsar    = psarSig ?   lsar   :   psar       and     trade       != 0  ?  trailPrice : na
plotTrail   = psar    ?   na     :   trailPrice != 0 ?  trailPrice  : na

longStop    = long  and psar ? psarSig : longSig
shortStop   = short and psar ? psarSig : shortSig

plotColor   = long ? lColor : sColor

plotshape   (longStop,  style= shape.xcross, size= size.tiny, text= "Long Stop",  color= lColor, textcolor= lColor, location=location.abovebar)
plotshape   (shortStop, style= shape.xcross, size= size.tiny, text= "Short Stop", color= sColor, textcolor= sColor, location=location.belowbar)

plot        (psar ? na : trailPrice != 0 ? trailPrice : na, 'Trailing Stop', color=(trade == 0)[1] ? na : plotColor, style=plot.style_linebr, linewidth=lineWidth)

plot        (plotPsar, "SAR", plotColor, style=plot.style_circles, linewidth=lineWidth)

// ================================== //
// -----> Alert Functionality <------ //
// ================================== //

if price <= initHigh and price >= initLow and time_close >= barTime and time_close[1] <= barTime
    runtime.error("Stop cannot be placed in candle range")

action      = long  ? 'sell' : 
              short ? 'buy'  : na

// Building block starter for a crypto API alert to a third party. Some assembly required.
// Triggers only on crypto pairs and autofills information from the chart and script. 
if (longStop or shortStop) and oneTime and syminfo.type == "crypto"
    alert(action + ' ' + syminfo.basecurrency + syminfo.currency + ' ' + 'q=' + str.tostring(quantity) + ' ' + 'a=' + market)
    oneTime := false

// Building block starter for a forex browser extension API alert. Batteries not included.
// Triggers only on forex pairs and autofills information from the chart and script. 
if (longStop or shortStop) and oneTime and syminfo.type == "forex"
    alert("e=" + broker + " s=" + syminfo.basecurrency + "/" + syminfo.currency + " b=" + action + " q=" + str.tostring(quantity))
    oneTime := false

// Basic alerts for manual trading
alertcondition(longStop,  "Long Trail", 'Long  Trail Trigger on {{interval}} chart. Price is {{close}}')
alertcondition(shortStop, "Short Trail",'Short Trail Trigger on {{interval}} chart. Price is {{close}}')
````

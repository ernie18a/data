# BTC Halving & US Elections (KenshinC)

- url: https://www.tradingview.com/script/qlFRHYvW-BTC-Halving-US-Elections-KenshinC/
- type: indicator
- pine_id: PUB;bbdcb878cf6e479890f270f42430e809
- version: 1.0

## Description

[b]BTC Halving & US Elections (KenshinC)[/b]

This indicator combines two of the most significant macro cycles in the cryptocurrency market: Bitcoin Halving cycles and US Presidential Election cycles, along with Yearly Open levels and Leap Year visualization.

[b]Why this script exists:[/b]
Bitcoin halvings reduce the rate of new BTC supply, while US elections often bring major policy, regulatory, and macroeconomic shifts. This script overlays both cycles on the chart to help traders see the broader temporal context rather than viewing these events in isolation.

[b]Key Features:[/b]

• US Election & Inauguration Cycle
  - Automatic "Election Day" labels (November)
  - "Inauguration Day" labels (January 20)
  - President name and political party displayed at inauguration (Blue = Democratic, Red = Republican)

• Bitcoin Halving Events
  - Clear vertical lines and labels for all past and future halvings (2012 - 2028)
  - Real-time countdown to the next halving (Days : Hours : Minutes : Seconds)

• Yearly Open Levels
  - Vertical lines at the beginning of each year
  - Horizontal Yearly Open line extended right (important institutional reference level)

• Leap Year Highlight
  - Background coloring and label when the year is a leap year

[b]How to Use:[/b]
- Best on Daily and Weekly timeframes
- Works on BTC/USD, BTC/USDT, or any Bitcoin pair
- Toggle features in the indicator settings:
  - Show Election Labels
  - Show President Names
  - Show Bitcoin Halvings
  - Show Halving Countdown
  - Show Yearly Open Lines

[b]Trading Ideas:[/b]
- Monitor volatility around Election periods and Halving dates
- Use Yearly Open as major support/resistance reference
- Study historical price behavior during overlapping cycles (e.g. 2020 & 2024)

This script is designed to be clean, informative, and useful for both swing traders and long-term investors.

[b]Disclaimer:[/b]
This indicator is for educational and informational purposes only. It is not financial advice. Trading cryptocurrencies involves significant risk of loss. Always do your own research and never trade more than you can afford to lose.

[b]Created by KenshinC[/b]

## Source Code

````pine
//@version=6
indicator("BTC Halving & US Elections (KenshinC)", overlay = true, max_labels_count = 500)

var show_elec = input.bool(true, "Show Election Labels")
var show_inag = input.bool(true, "Show Inauguration Labels")
showPresident = input.bool(true, "Show President Name & Party at Inauguration", group="Election Info")

// ==================== ELECTION & INAUGURATION ====================
is_election_year   = (year - 1800) % 4 == 0
is_election_month  = month == 11 or (month == 12 and month[1] == 10)
is_election_week   = weekofyear == 45
is_election_dow    = dayofweek == dayofweek.monday

if (timeframe.isdaily or timeframe.isweekly) and is_election_year and is_election_week and is_election_dow and show_elec
    label.new(bar_index, high * 1.02, "Election Day", textcolor = color.white, style=label.style_label_down, color=color.red)

is_inauguration_year  = (year - 1800) % 4 == 1
is_inauguration_month = month == 1
is_inauguration_dow   = dayofmonth == 20

if (timeframe.isdaily or timeframe.isweekly) and is_inauguration_year and is_inauguration_month and is_inauguration_dow and show_inag
    label.new(bar_index, high * 1.02, "Inauguration", color=color.orange, textcolor = color.white, style=label.style_label_down)

// ==================== PRESIDENTS & PARTIES ====================
var int[]   election_years = array.new<int>()
var string[] presidents    = array.new<string>()
var string[] parties       = array.new<string>()

if array.size(election_years) == 0
    array.push(election_years, 1936)
    array.push(presidents, "Franklin D. Roosevelt")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1940)
    array.push(presidents, "Franklin D. Roosevelt")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1944)
    array.push(presidents, "Franklin D. Roosevelt")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1948)
    array.push(presidents, "Harry S. Truman")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1952)
    array.push(presidents, "Dwight D. Eisenhower")
    array.push(parties, "Republican")
    
    array.push(election_years, 1956)
    array.push(presidents, "Dwight D. Eisenhower")
    array.push(parties, "Republican")
    
    array.push(election_years, 1960)
    array.push(presidents, "John F. Kennedy")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1964)
    array.push(presidents, "Lyndon B. Johnson")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1968)
    array.push(presidents, "Richard Nixon")
    array.push(parties, "Republican")
    
    array.push(election_years, 1972)
    array.push(presidents, "Richard Nixon")
    array.push(parties, "Republican")
    
    array.push(election_years, 1976)
    array.push(presidents, "Jimmy Carter")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1980)
    array.push(presidents, "Ronald Reagan")
    array.push(parties, "Republican")
    
    array.push(election_years, 1984)
    array.push(presidents, "Ronald Reagan")
    array.push(parties, "Republican")
    
    array.push(election_years, 1988)
    array.push(presidents, "George H. W. Bush")
    array.push(parties, "Republican")
    
    array.push(election_years, 1992)
    array.push(presidents, "Bill Clinton")
    array.push(parties, "Democratic")
    
    array.push(election_years, 1996)
    array.push(presidents, "Bill Clinton")
    array.push(parties, "Democratic")
    
    array.push(election_years, 2000)
    array.push(presidents, "George W. Bush")
    array.push(parties, "Republican")
    
    array.push(election_years, 2004)
    array.push(presidents, "George W. Bush")
    array.push(parties, "Republican")
    
    array.push(election_years, 2008)
    array.push(presidents, "Barack Obama")
    array.push(parties, "Democratic")
    
    array.push(election_years, 2012)
    array.push(presidents, "Barack Obama")
    array.push(parties, "Democratic")
    
    array.push(election_years, 2016)
    array.push(presidents, "Donald Trump")
    array.push(parties, "Republican")
    
    array.push(election_years, 2020)
    array.push(presidents, "Joe Biden")
    array.push(parties, "Democratic")
    
    array.push(election_years, 2024)
    array.push(presidents, "Donald Trump")
    array.push(parties, "Republican")
    
    // Future
    array.push(election_years, 2028)
    array.push(presidents, "TBD")
    array.push(parties, "TBD")
    
    array.push(election_years, 2032)
    array.push(presidents, "TBD")
    array.push(parties, "TBD")

// ========== LABEL TÊN TỔNG THỐNG TẠI INAUGURATION ==========
if showPresident and is_inauguration_year and is_inauguration_month and is_inauguration_dow and 
   (timeframe.isdaily or timeframe.isweekly) and dayofmonth == 20
    for i = 0 to array.size(election_years) - 1
        if year == array.get(election_years, i) + 1
            labelText = "★ " + array.get(presidents, i) + "\n" + array.get(parties, i)
            label.new(bar_index, low * 0.92, labelText, 
                 style=label.style_label_up, 
                 color = array.get(parties, i) == "Democratic" ? color.new(color.blue, 10) : color.new(color.red, 10),
                 textcolor = color.white, 
                 size = size.normal, 
                 textalign = text.align_center)

// ==================== LEAP YEAR ====================
transparency = input.int(title='Transparency', defval=88, minval=0, maxval=100)
showLabels   = input.bool(true, 'Show Labels ? ')

transparent = color.new(color.white, 100)
labelColor  = #1e90ff
bgColor     = #61df0d

isLeap = year % 4 != 0 ? false : year % 100 != 0 ? true : year % 400 != 0 ? false : true

lyText  = ' Election \nYear Start '
lyStart = year != year[1] and isLeap
plotshape(showLabels and lyStart, text=lyText, color=color.new(labelColor, 0), textcolor=color.white, style=shape.labelup, location=location.belowbar, size=size.small)
bgcolor(isLeap ? color.new(bgColor, transparency) : transparent)

// ==================== YEARLY OPEN LINES ====================
iBaseTime = input.time(defval=timestamp('01 Jan 2018 0:00 +0000'), title='Base Time')

yearlyColor  = input.color(defval=color.black, title='Vertical Line Color', inline='year')
iYearly      = input.bool(true, title='Show Yearly', inline='year')
hyearlyColor = input.color(defval=color.orange, title='Year Open Line Color', inline='year')
ihYearly     = input.bool(true, title='Year Open Line', inline='year')

lineStyle  = input.string(title='Vertical Line Style', defval=line.style_solid, options=[line.style_dotted, line.style_dashed, line.style_solid])
hLineStyle = input.string(title='Horizontal Line Style', defval=line.style_solid, options=[line.style_dotted, line.style_dashed, line.style_solid])

[yearlyTime, yearlyOpen] = request.security(syminfo.tickerid, '12M', [time, open], lookahead=barmerge.lookahead_on)

var line   hLine_yearly  = na
var label  hlabel_yearly = na

if iYearly
    var int iDrawTimeY_ = 0
    iDrawTime = timestamp(year, month(iBaseTime), dayofmonth(iBaseTime), hour(iBaseTime), minute(iBaseTime))
    if iDrawTime != iDrawTimeY_ and iDrawTime < timenow
        line.new(iDrawTime, yearlyOpen, iDrawTime, yearlyOpen + syminfo.mintick, xloc=xloc.bar_time, style=lineStyle, extend=extend.both, color=yearlyColor, width=1)
        iDrawTimeY_ := iDrawTime
    if ihYearly
        line.delete(hLine_yearly)
        label.delete(hlabel_yearly)
        hLine_yearly  := line.new(iDrawTimeY_, yearlyOpen, last_bar_time, yearlyOpen, xloc=xloc.bar_time, style=hLineStyle, extend=extend.right, color=hyearlyColor, width=1)
        hlabel_yearly := label.new(last_bar_index + 50, yearlyOpen, "Yearly Open", xloc=xloc.bar_index, color=color.rgb(255,255,255,100), style=label.style_label_down, textcolor=hyearlyColor, size=size.normal)

// ==================== BITCOIN HALVING ====================
showHalving   = input.bool(true,  "Show Bitcoin Halving", group="Bitcoin Halving")
showCountdown = input.bool(true,  "Show Halving Countdown", group="Bitcoin Halving")
halvingLineColor = input.color(color.green, "Halving Vertical Line Color", group="Bitcoin Halving")

var int[]    halvingDates = array.new<int>()
var string[] halvingTexts = array.new<string>()

if array.size(halvingDates) == 0
    array.push(halvingDates, timestamp('GMT', 2012, 11, 28))
    array.push(halvingDates, timestamp('GMT', 2016,  7,  9))
    array.push(halvingDates, timestamp('GMT', 2020,  5, 11))
    array.push(halvingDates, timestamp('GMT', 2024,  4, 19))
    array.push(halvingDates, timestamp('GMT', 2028,  4, 18))

    array.push(halvingTexts, "⛏ 1st Halving\n28 Nov 2012")
    array.push(halvingTexts, "⛏ 2nd Halving\n9 Jul 2016")
    array.push(halvingTexts, "⛏ 3rd Halving\n11 May 2020")
    array.push(halvingTexts, "⛏ 4th Halving\n19 Apr 2024")
    array.push(halvingTexts, "⛏ 5th Halving\n18 Apr 2028")

for i = 0 to array.size(halvingDates) - 1
    halvingTime = array.get(halvingDates, i)
    if showHalving and ta.change(time("D")) != 0 and time >= halvingTime and time[1] < halvingTime
        line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=halvingLineColor, width=2)
        label.new(bar_index, high * 1.05, array.get(halvingTexts, i), 
             style=label.style_label_down, color=color.new(color.orange, 0), textcolor=color.white, size=size.normal, textalign=text.align_center)

// Countdown
if showCountdown and barstate.islast
    var int nextHalving = na
    for i = 0 to array.size(halvingDates) - 1
        if timenow < array.get(halvingDates, i)
            nextHalving := array.get(halvingDates, i)
            break
    if not na(nextHalving)
        secondsLeft = math.abs(timenow - nextHalving) / 1000
        days    = math.floor(secondsLeft / 86400)
        hours   = math.floor((secondsLeft % 86400) / 3600)
        minutes = math.floor((secondsLeft % 3600) / 60)
        seconds = math.floor(secondsLeft % 60)
        countdownText = str.format("⛏ Next Halving\n{0}d {1}h {2}m {3}s", days, hours, minutes, seconds)
        label.new(bar_index + 8, close * 0.98, countdownText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 30), textcolor=color.yellow, size=size.normal)
````

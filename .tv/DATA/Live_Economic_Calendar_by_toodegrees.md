<!-- tradingview-pine-id: PUB;8386abbb663b4f66abe43aa263eefffc -->
<!-- tradingviewscripts-format: 1 -->
# Live Economic Calendar by toodegrees

Source: https://www.tradingview.com/script/JjgkjuMY-Live-Economic-Calendar-by-toodegrees/

## Description

⚠️ PLEASE READ ⚠️
Although this indicator is accurate in showcasing live and upcoming News Events, checking the original sources is always suggested. This indicator aims to save Time, but due to limitations it may not be 100% correct 100% of the Time.

Description:
The Live Economic Calendar indicator seamlessly integrates with external news sources to provide real-Time, upcoming, and past financial news directly on your Tradingview chart.

By having a clear understanding of when news are planned to be released, as well as their respective impact, analysts can prepare their weeks and days in advance. These injections of volatility can be harnessed by analysts to support their thesis, or may want to be avoided to ensure higher probability market conditions. Fundamentals and news releases transcend the boundaries of technical analysis, as their effects are difficult to predict or estimate.

Designed for both novice and experienced traders, the Live Economic Calendar indicator enhances your analysis by keeping you informed of the latest and upcoming market-moving news.

This is achieved with three different visual components:

[*]News Table: A dedicated News Table shows the Day of the Week, Date, Time of the Day, Currency, Expected Impact, and News Name for each event (in chronological order). Once a news event has occurred, or the day is over, it will be greyed out – helping to focus on the next upcoming news events.
[image]https://www.tradingview.com/x/XY2EYpQ8/[/image]

[*]News Lines: Vertical lines plotted in the future help analysts monitor upcoming news events; vertical lines in the past help analysts spot and backtest previous news events that already occurred.
[image]https://www.tradingview.com/x/tRhHSKMv/[/image]

[*]News Labels: Color-coded news labels will plot once the news events have occurred. This not only gives analysts a minimalistic visual cue, but also retains the information of which news were released at that Time in their tooltips.
[image]https://www.tradingview.com/x/bJejCvU8/[/image]

Forex Factory Calendar News Feed:
The Forex Factory Data Feed includes news events from January 2007 to the present. The data is updated daily. Please see the Technical Description below for more information.
[image]https://www.tradingview.com/x/QG14rNLn/[/image]

Forex Factory provides news for all major currencies and markets:

[*]Australia (AUD)
[*]Canada (CAD)
[*]Switzerland (CHF)
[*]China (CNY)
[*]European Union (EUR)
[*]United Kingdom (GBP)
[*]Japan (JPY)
[*]New Zealand (NZD)
[*]United States of America (USD)

Further, there are four types of news impact, defined by respective color-coding which is retained to avoid confusion:

[*]⚪ Holiday 
[*]🟡 Low Impact
[*]🟠 Medium Impact
[*]🔴 High Impact

News' Time of the day data is in 24H format, and 'All Day' news are marked at Daily candle open.

⚠️ Original Release Notes ⚠️

[*]The original release of this indicator supports the Forex Factory News Calendar in EST (New York Time). Future updates will include multiple news sources, as well as supporting different Timezones.
[*]Given Data limitations, the Daily chart can omit some data due to the market being close on some days. This will be fixed in the future once an efficient solution is implemented.

Key Features:

[*]Impact-Based News Filtering: Filter news items based on their expected impact (holiday, low, medium, high) to focus on the most market-critical information.
[*]Symbol-Specific News: Automatically filter news to display only what's relevant to the currency pair or trading symbol you are analyzing.
[*]Custom Currency News: Want to see more than the news relevant to the current symbol? Toggle which markets' news you are most interested in.
[*]Chart History: Keep your charts clean by displaying only the drawings of Today's news, or This Week's news.
[*]Custom Lookback: Look further back in Time by choosing a custom number of Lookback Days, allowing you to backtest and keep in mind salient news events from the past.
[*]Line and Label Customization: Both the News Lines and Labels are highly customizable (except the colors), allowing you to make the indicator yours.
[*]Table History: Choose whether to focus on Today's news only, or the news for This Week.
[*]Table Customization: The table colors and position are highly customizable, allowing you to make it fit your visual preference and your layouts' aesthetic.

[pine]"Wondering how it's done? 👇"[/pine]

Technical Description:
This script utilizes [Pine Seeds](https://github.com/tradingview-pine-seeds/docs), a service integrated with TradingView for importing custom data. This stunning feature enables users to upload and access custom End Of Day (EOD) data, which can be updated as frequently as five times daily.

This data can be imported in one of two formats:

[*]Single Value: integer or float
[*]Candle Data: open, high, low, close, volume

Upon encountering Pine Seeds, I recognized its potential for importing financial news events. Given that Forex Factory is a primary source of financial news in my personal analysis, integrating it into my layouts seemed like an exciting opportunity. This integration is expected to provide significant value to users looking to integrate additional news feeds all in one place.

Development Challenges:

[*]Format Limitations: News events must be converted into numerical values for import, due to the required Pine Seeds format.
[*]Amount of Data: With all currencies considered, the system may encounter over 40 news events in a single day.
[*]Data Availability: The reliance on End Of Day (EOD) data means that information for the current day is displayed with a delay, and accessing future data is not possible.

Solutions:

[*]Encoding: Each news event is encoded as an integer in the "DCHHMMITYP" format.
D = day of the week
C = currency
HHMM = Time of day
I = news impact
TYP = event ID (see [Event Library A](https://www.tradingview.com/script/2hLfZ42b-forex-factory-events-id-A/) and [Event Library B](https://www.tradingview.com/script/fswwZuhU-forex-factory-events-id-B/))
To ensure data assignment for each candle across the open, high, low, close, and volume series, the value "999" is used as a placeholder:
[image]https://www.tradingview.com/x/tvvbXEOw/[/image]

[*]Importing: Utilizing the encoding system, up to five news events per day can be imported for a singular Pine Seeds custom symbol. 
By creating multiple custom Pine Seeds Symbols, efficient imports of a larger number of events is then easily achievable. Nine unique symbols have been established, accommodating up to 45 news events per day. 
These symbols are searchable, and accessible as "TOODEGREES_FOREX_FACTORY_SLOT_N" where N ranges from 1 to 9. 

The Pine Seeds data feed appears as follows:
[image]https://www.tradingview.com/x/E0GLfBdh/[/image]

[*]Uploading Schedule: To ensure analysts are informed about current and upcoming week's news, events are uploaded one week in advance. 
This approach is vital for preparing for potential market impacts across various asset classes and currencies, allowing visibility of an entire week's news ahead of Time.
[image]https://www.tradingview.com/x/JvJvOW1A/[/image]

Data Scraping:
Unfortunately Forex Factory doesn't offer an API to fetch their news feed.
Hence an ad hoc python scraper was developed to read and save news events from January 2007 till the present leveraging Selenium. The scraper algorithm is part of a larger script responsible for scraping data, formatting data, and creating all necessary datasets.

The pseudo-code for the python script is as follows:

[*]Read and save news event data on Forex Factory
[*]Format day of the week, currency, Time of the day, and impact data for the Encoding
[*]Encode and save News Event IDs – Event ID dataset is created
[*]Format news data for Pine Seeds (roll-back date by one week, assign news to open, high, low, close, and volume values)
[*]Create Pine Seeds Datasets

This script is ran everyday at Futures market close (16:00 EST) to update the last part of the each dataset, ensuring accuracy, and taking into account last-minute news additions or revisions.

Once the data (next week's news) is imported by the Live Economic Calendar indicator, it's immediately decoded by leveraging the [Forex Factory Decoding Library](https://www.tradingview.com/script/Q78LeoTL-forex-factory-decoding/), and saved into an array.

Upon a new week open, the decoded data is used to plot news events on the chart and in the news table. 
See the inner workings of these processes in the [Forex Factory Utility Library](https://www.tradingview.com/script/DHRsmWy1-forex-factory-utility/).

Although these libraries are specifically built for this indicator, feel free to use them to create your own scripts. Looking forward to see what the Pine Script community comes up with!

Thank you for making it this far. Enjoy!
Ciao,
toodegrees

This tool is available ONLY on the TradingView platform.

Terms and Conditions

[*]Our charting tools are provided for informational and educational purposes only and do not constitute financial, investment, or trading advice. Our charting tools are not designed to predict market movements or provide specific recommendations. Users should be aware that past performance is not indicative of future results and should not be relied upon for making financial decisions. By using our charting tools, the user agrees that Toodegrees and the Toodegrees Team are not responsible for any decisions made based on the information provided by these charting tools. The user assumes full responsibility and liability for any actions taken and the consequences thereof, including any loss of money or investments that may occur as a result of using these products. Hence, by using these charting tools, the user accepts and acknowledges that Toodegrees and the Toodegrees Team are not liable nor responsible for any unwanted outcome that arises from the development, or the use of these charting tools. Finally, the user indemnifies Toodegrees and the Toodegrees Team from any and all liability.
[*]By continuing to use these charting tools, the user acknowledges and agrees to the Terms and Conditions outlined in this legal disclaimer.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © toodegrees
import toodegrees/forex_factory_utility/17 as ffUtil
import toodegrees/forex_factory_decoding/45 as ffDec

//@version=6
indicator("Live Economic Calendar by toodegrees"
         , shorttitle="News° [toodegrees]"
         , overlay=true
         , max_lines_count=500
         , max_labels_count=500)


//#region[Timeframe Limitations]
if timeframe.in_seconds(timeframe.period)>86400
    runtime.error("Go to the Daily Timeframe or lower!")
else if timeframe.in_seconds(timeframe.period)<30
    runtime.error("Go to the 30-Second Timeframe or higher!")
//#endregion


//#region[Global, Functions, Methods]
var mdnCheck = false
if hour(time,"America/New_York")==0 and hour(time[1],"America/New_York")!=0 and not mdnCheck
    mdnCheck := true
newDay = mdnCheck ? hour(time,"America/New_York")==0 and hour(time[1],"America/New_York")!=0 : timeframe.change("D")

requestData() =>
    [request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_1",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_2",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_3",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_4",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_5",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_6",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_7",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_8",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_9",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume))]

method processData(ffUtil.News[] N, string S1, string S2, string S3, string S4, string S5, string S6, string S7, string S8, string S9) =>
    ffDec.readNews(N,S1), ffDec.readNews(N,S2), ffDec.readNews(N,S3)
    ffDec.readNews(N,S4), ffDec.readNews(N,S5), ffDec.readNews(N,S6)
    ffDec.readNews(N,S7), ffDec.readNews(N,S8), ffDec.readNews(N,S9)
//#endregion


//#region[Tooltips]
var custom_timezoneTT = "The original Time and Date of the News is based on New York EST. Adjust the Timezone "
                      + "by matching this setting to the bottom-right Timezone setting on your Chart."
var expectedImpactTT  = "🔴 High Impact\n🟠 Medium Impact\n🟡 Low Impact\n⚪ Holiday"
var autoTT            = "Automatically chooses the Currencies' News based on the current symbol on Chart."
var onChartTT         = "'Today'\nAll historical news will be deleted once a new day starts, only the current day's news "
                      + "will be shown on chart.\n\n'This Week'\nAll historical news will be deleted once a new week "
                      + "starts, only the current week's news will be shown on chart.\n\n'Manual'\nWill show the current "
                      + "week's upcoming news as well as the news in the prior custom number of days (includes weekend days)."
var labelYTT          = "'Auto' will place the label opposite to the candle's direction."
var sizeTTT           = "Depending on the Size of the News Table you will be able to see a maximum number of Forex Factory "
                      + "News events on the chart due to size limitations.\n\nThese limits are roughly:\n'Tiny' ± 46 Forex "
                      + "Factory News Events\n'Small' ± 38 Forex Factory News Events\n'Normal' ± 28 Forex Factory News Events"
                      + "\n'Large' ± 20 Forex Factory News Events\n'Huge' ± 11 Forex Factory News Events"
var tableHeadCTT      = "Text Color - Backroung Color"
var tableRowCTT       = "Past News Text Color - Future News Text Color - Backroung Color"
//#endregion


//#region[User Input]
// Custom Timezone
custom_timezone = input.bool(false, title="Custom Timezone?", inline="1")
timezone_h      =  input.int(1    , title="UTC"             , inline="1", minval=-10, maxval=13)
timezone_m      =  input.int(0    , title=":"               , inline="1", minval=0  , maxval=59, step=15, tooltip=custom_timezoneTT)

// Expected Impact
var high_impact = input.bool(true, title="🔴", group="Expected Impact", inline="1")
var med_impact  = input.bool(true, title="🟠", group="Expected Impact", inline="1")
var low_impact  = input.bool(true, title="🟡", group="Expected Impact", inline="1")
var holiday     = input.bool(true, title="⚪", group="Expected Impact", inline="1", tooltip=expectedImpactTT)

// Currencies
var AUTO = input.bool(true , title="Automatic?", group="Currencies", tooltip=autoTT)
var AUD  = input.bool(false, title="AUD"       , group="Currencies", inline="1")
var CAD  = input.bool(false, title="CAD"       , group="Currencies", inline="1")
var CHF  = input.bool(false, title="CHF"       , group="Currencies", inline="1")
var CNY  = input.bool(false, title="CNY"       , group="Currencies", inline="2")
var EUR  = input.bool(false, title="EUR"       , group="Currencies", inline="2")
var GBP  = input.bool(false, title="GBP"       , group="Currencies", inline="2")
var JPY  = input.bool(false, title="JPY "      , group="Currencies", inline="3")
var NZD  = input.bool(false, title="NZD"       , group="Currencies", inline="3")
var USD  = input.bool(false, title="USD"       , group="Currencies", inline="3")

// On Chart
var onChartT   =                  input.string("This Week", title="Chart History         ", group="News On Chart", inline="1", options=["Today", "This Week", "Manual"])
var onChartLB  =                     input.int(30         , title=""                      , group="News On Chart", inline="1", tooltip=onChartTT)
var showLabels =                    input.bool(true       , title="Show Labels?"          , group="News On Chart", inline="2")
var labelS     =      ffUtil.size(input.string("Normal"   , title=""                      , group="News On Chart", inline="2", options=["Tiny" , "Small", "Normal", "Large", "Huge"]))
var labelY     =                  input.string("Auto"     , title=""                      , group="News On Chart", inline="2", options=["Above", "Below", "Auto"] , tooltip=labelYTT)
var lblOutLn   =                    input.bool(true       , title="Outline?"              , group="News On Chart", inline="2")
var showLines  =                    input.bool(true       , title="Show Lines?  "         , group="News On Chart", inline="3")
var lineTime   =                  input.string("Future"   , title=""                      , group="News On Chart", inline="3", options=["Future", "Past+Future"])
var lineT      = ffUtil.lineTrnsp(input.string("Heavy"    , title=""                      , group="News On Chart", inline="3", options=["Light" , "Medium", "Heavy"]))
var lineS      = ffUtil.lineStyle(input.string("Solid"    , title=""                      , group="News On Chart", inline="3", options=["Dashed", "Dotted", "Solid"]))

// Table
var showTable   =   input.bool(true       , title="Show?"        , group="News Table", inline="1")
var tableType   = input.string("This Week", title=""             , group="News Table", inline="1", options=["Today", "This Week"])
var todType     = input.string("24H"      , title=""             , group="News Table", inline="1", options=["24H"  , "AM/PM"])
var headTextC   =  input.color(#dee1e9  , title="Table Header" , group="News Table", inline="2")
var headBgC     =  input.color(#283c70  , title=""             , group="News Table", inline="2", tooltip=tableHeadCTT)
var rowTextCP   =  input.color(#787b86  , title="Table News   ", group="News Table", inline="3")
var rowTextCF   =  input.color(#000000  , title=""             , group="News Table", inline="3")
var rowBgC      =  input.color(#dee1e9  , title=""             , group="News Table", inline="3", tooltip=tableRowCTT)
var tableBorder =   input.bool(true       , title="Border?"      , group="News Table", inline="4")
var borderColor =  input.color(#000000  , title=""             , group="News Table", inline="4")
var borderAuto  =   input.bool(true       , title="Auto?"        , group="News Table", inline="4")
var tableX      = input.string("Right"    , title=""             , group="News Table", inline="5", options=["Left", "Center", "Right" ])
var tableY      = input.string("Bottom"   , title=""             , group="News Table", inline="5", options=["Top" , "Middle", "Bottom"])
var sizeT       = input.string("Small"    , title=""             , group="News Table", inline="5", options=["Tiny", "Small" , "Normal", "Large", "Huge"], tooltip=sizeTTT)

// Process User Input
var locT            = ffUtil.boxLoc(tableX,tableY)
var impact_filter   = ffUtil.impFilter(holiday,low_impact,med_impact,high_impact)
var currency_filter = ffUtil.curFilter(AUTO,AUD,CAD,CHF,CNY,EUR,GBP,JPY,NZD,USD)
onChartT           := timeframe.period=="D" and onChartT=="Today"?"This Week":onChartT 
tableType          := timeframe.period=="D"?"This Week":tableType 
//#endregion


//#region[Import, Decode, Save]
var currWeek = array.new<ffUtil.News>()
var nextWeek = array.new<ffUtil.News>()
var currDay  = array.new<ffUtil.News>()

// Import Forex Factory News for next week
[slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9] = requestData()

// Save Forex Factory News
if timeframe.change("W")
    nextWeek := ffUtil.bubbleSort_News(nextWeek)
    if custom_timezone
        nextWeek := ffUtil.adjustTimezone(nextWeek, timezone_h, timezone_m)
    if todType=="AM/PM"
        nextWeek := ffUtil.NewsAMPM_TOD(nextWeek)
    currWeek := nextWeek.copy()
    currWeek := ffUtil.weekNews(currWeek,currency_filter,impact_filter)
    nextWeek.clear()
if newDay
    currDay.clear()
    currDay := ffUtil.todayNews(currWeek,currDay,mdnCheck)

// Decode Forex Factory News
nextWeek.processData(slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9)
//#endregion


//#region[Table & Drawings]
// Forex Factory News Table
var table_BC = tableBorder ? (borderAuto ? chart.fg_color : borderColor) : na
var  _table = ffUtil.newTable(locT,table_BC)
if currWeek.size()>0
    if showTable
        if tableType=="Today"
            if newDay
                _table := ffUtil.FF_Table(currDay,locT,sizeT,headTextC,headBgC,rowTextCF,rowBgC,table_BC)
            ffUtil.timeline(currDay,_table,rowTextCP, timezone_h, timezone_m, true)
        else
            if timeframe.change("W")
                _table := ffUtil.FF_Table(currWeek,locT,sizeT,headTextC,headBgC,rowTextCF,rowBgC,table_BC)
            ffUtil.timeline(currWeek,_table,rowTextCP, timezone_h, timezone_m)
    else
        _table.delete()
else
    _table.delete()

// Forex Factory News Drawings
if showLines
    if onChartT!="Today" and timeframe.change("W")
        ffUtil.FF_OnChartLine(currWeek,lineT,lineS)
    else if onChartT=="Today" and newDay
        ffUtil.FF_OnChartLine(currDay,lineT,lineS)
if showLabels
    ffUtil.FF_OnChartLabel(currWeek,labelY,labelS,lblOutLn)

ffUtil.historical(onChartLB,onChartT=="Today",onChartT=="This Week",lineTime)
//#endregion


//#region[Daily Chart Buffer]
if timeframe.period=="D" and timeframe.change("W") 
    nextWeek.processData(slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9)
//#endregion
````

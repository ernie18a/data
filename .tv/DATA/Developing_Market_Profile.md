<!-- tradingview-pine-id: PUB;2f7f055465ce4067a354e4668624cb7d -->
<!-- tradingviewscripts-format: 1 -->
# Developing Market Profile

Source: https://www.tradingview.com/script/XMKe97Vn-Developing-Market-Profile-TPO-Honestcowboy/

## Description

The Developing Market Profile Indicator aims to broaden the horizon of Market Profile / TPO research and trading. While standard Market Profiles aim is to show where PRICE is in relation to TIME on a previous session (usually a day). Developing Market Profile will change bar by bar and display PRICE in relation to TIME for a user specified number of past bars.

What is a market profile?

"Market Profile is an intra-day charting technique (price vertical, time/activity horizontal) devised by J. Peter Steidlmayer. Steidlmayer was seeking a way to determine and to evaluate market value as it developed in the day time frame. The concept was to display price on a vertical axis against time on the horizontal, and the ensuing graphic generally is a bell shape--fatter at the middle prices, with activity trailing off and volume diminished at the extreme higher and lower prices." 

For education on market profiles I recommend you search the net and study some profitable traders who use it.

Key Differences

[*]Does not have a value area but distinguishes each column in relation to the biggest column in percentage terms.
[*]Updates bar by bar
[*]Does not take sessions into account
[*]Shows historical values for each bar

While there is an entire education system build around Market Profiles they usually focus on a daily profile and in some cases how the value area develops during the day (there are indicators showing the developing value area).

The idea of trading based on a developing value area is what inspired me to build the Developing Market Profile.

🟦 CALCULATION

Think of this Developing Market Profile the same way as you would think of a moving average. On each bar it will lookback 200 bars (or as user specified) and calculate a Market Profile from those bars (range).

🔹Market Profile gets calculated using these steps:

[*]Get the highest high and lowest low of the price range.
[*]Separate that range into user specified amount of price zones (all spaced evenly)
[*]Loop through the ranges bars and on each bar check in which price zones price was, then add +1 to the zones price was in (we do this using the OccurenceArray)
[*]After it looped through all bars in the range it will draw columns for each price zone (using boxes) and make them as wide as the OccurenceArray dictates in number of bars

🔹Coloring each column:
The script will find the biggest column in the Profile and use that as a reference for all other columns. It will then decide for each column individually how big it is in % compared to the biggest column. It will use that percentage to decide which color to give it, top 20% will be red, top 40% purple, top 60% blue, top 80% green and all the rest yellow. The user is able to adjust these numbers for further customisation.

The historical display of the profiles uses plotchar() and will not only use the color of the column at that time but the % rating will also decide transparancy for further detail when analysing how the profiles developed over time. Each of those historical profiles is calculated using its own 200 past bars. This makes the script very heavy and that is why it includes optimisation settings, more info below. 

🟦 USAGE

My general idea of the markets is that they are ever changing and that in studying that changing behaviour a good trader is able to distinguish new behaviour from old behaviour and adapt his approach before losing traders "weak hands" do.

A Market Profile can visually show a trader what kind of market environment we currently are in. In training this visual feedback helps traders remember past market environments and how the market behaved during these times.

Use the history shown using plotchars in colors to get an idea of how the Market Profile looked at each bar of the chart.

[image]https://www.tradingview.com/x/ZRbVEz9g/[/image]

This history will help in studying how price moves at different stages of the Market Profile development.

I'm in no way an expert in trading Market Profiles so take this information with a grain of salt. Below an idea of how I would trade using this indicator:

[image]https://www.tradingview.com/x/XZhYcru8/[/image]

🟦 SETTINGS

🔹MARKET PROFILING

[*]Lookback: The amount of bars the Market Profile will look in the past to calculate where price has been the most in that range
[*]Resolution: This is the amount of columns the Market Profile will have. These columns are calculated using the highest and lowest point price has been for the lookback period

Resolution is limited to a maximum of 32 because of pinescript plotting limits (64). Each plotchar() because of using variable colors takes up 2 of these slots

🔹VISUAL SETTINGS

[*]Profile Distance From Chart: The amount of bars the market profile will be offset from the current bar
[*]Border width (MP): The line thickness of the Market Profile column borders
[*]Character: This is the character the history will use to show past profiles, default is a square.
[*]Color theme: You can pick 5 colors from biggest column of the Profile to smallest column of the profile.
[*]Numbers: these are for % to decide column color. So on default top 20% will be red, top 40% purple... Always use these in descending order
[*]Show Market Profile: This setting will enable/disable the current Market Profile (columns on right side of current bar)
[*]Show Profile History: This setting will enable/disable the Profile History which are the colored characters you see on each bar

[image]https://www.tradingview.com/x/wtODgEAE/[/image]

🔹OPTIMISATION AND DEBUGGING

[*]Calculate from here: The Market Profile will only start to calculate bar by bar from this point. Setting is needed to optimise loading time and quite frankly without it the script would probably exceed tradingview loading time limits.
[*]Min Size: This setting is there to avoid visual bugs in the script. Scaling the chart there can be issues where the Market Profile extends all the way to 0. To avoid this use a minimum size bigger than the bugged bottom box

---

## Source Code

````pine
//@version=5
//@author Honestcowboy
//
indicator(title="Developing Market Profile", shorttitle="Dev MP/TPO", max_boxes_count=32, overlay=true)

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> Script Explanation <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

lookbackTip             = "The amount of bars the Market Profile will look in the past to calculate where price has been the most in that range"
resolutionTip           = "This is the amount of columns the Market Profile will have\nThese columns are calculated using the highest and lowest point price has been for the lookback period"
distanceFromChartTip    = "The amount of bars the market profile will be offset from the current bar\nThis setting will not impact the developing market profile lines."
minSizeTip              = "This setting is there to avoid visual bugs in the script\nScaling the chart there can be issues where the Market Profile extends all the way to 0\nTo avoid this use a minimum size bigger than the bugged box"

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> User Inputs <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

marketProfileLength     = input.int(defval=200,     minval=10,                      title="lookback",                           group="Market Profiling",                       tooltip=lookbackTip         )
amountOfColumns         = input.int(defval=32,      minval=2,   maxval=32,          title="resolution",                         group="Market Profiling",                       tooltip=resolutionTip       )
distLastCandle          = input.int(defval=1,       minval=0,                       title="profile distance from chart",        group="Visual Settings",                        tooltip=distanceFromChartTip)
borderWidth             = input.int(defval=1,       minval=1,                       title="border width (MP)",                  group="Visual Settings"                                                     )
charToUse               = input.string(defval="▉",                                  title="character",                          group="Visual Settings"                                                     )
col1                    = input.color(defval=#F24968,                             title="color theme",                        group="Visual Settings",      inline="color"                                )
col2                    = input.color(defval=#9B72F2,                             title="",                                   group="Visual Settings",      inline="color"                                )
col3                    = input.color(defval=#6929F2,                             title="",                                   group="Visual Settings",      inline="color"                                )
col4                    = input.color(defval=#14D990,                             title="",                                   group="Visual Settings",      inline="color"                                )
col5                    = input.color(defval=#F2B807,                             title="",                                   group="Visual Settings",      inline="color"                                )
perc1                   = input.int(defval=20,      minval=1,                       title="",                                   group="Visual Settings",      inline="perc"                                 )
perc2                   = input.int(defval=40,      minval=1,                       title="",                                   group="Visual Settings",      inline="perc"                                 )
perc3                   = input.int(defval=60,      minval=1,                       title="",                                   group="Visual Settings",      inline="perc"                                 )
perc4                   = input.int(defval=80,      minval=1,                       title="",                                   group="Visual Settings",      inline="perc"                                 )
showProfile             = input.bool(defval=true,                                   title="show Market Profile",                group="Visual Settings"                                                     )
showHistory             = input.bool(defval=true,                                   title="show Profile history",               group="Visual Settings"                                                     )
timeFilter              = input.time(defval=timestamp('2023-05-10 14:30 GMT+2'),    title="calculate from here",                group="Optimisation and Debugging"                                          )
minSize                 = input.int(defval=2,       minval=0,                       title='minimum size of histogram',          group="Optimisation and Debugging",             tooltip=minSizeTip          )

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> Functions <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

getTransp(index, array, maxCount) =>
    transp              = array.size(array) > index ? 100-math.round((array.get(array, index)/maxCount)*100) : 100

getColor(index, array, maxCount) =>
    number              = getTransp(index, array, maxCount)
    color               = number<perc1 ? color.new(col1, number) : number < perc2 ? color.new(col2, number) : number < perc3 ? color.new(col3, number) : number < perc4 ? color.new(col4, number) : color.new(col5, number)

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> Calculate Market Profile <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

MPTop                   = ta.highest(high,marketProfileLength)
MPBottom                = ta.lowest(low,marketProfileLength)
ColumnSize              = (MPTop-MPBottom)/amountOfColumns

//Delete all boxes
boxes                   = box.all
if array.size(boxes) > 0
    for i = 0 to    array.size(boxes) - 1
        box.delete( array.get(boxes, i))
//Build Levels
float[] MPArray         = array.new<float>(amountOfColumns+2,0.0)
if time>timeFilter                                                                          // used for faster loading times
    array.set(MPArray,0,MPTop)
    float previousArrayValue    = 0
    for counter                 = 1 to amountOfColumns
        previousArrayValue     := array.get(MPArray,counter-1)
        array.set(MPArray,counter,previousArrayValue-ColumnSize)
// Count Occurence of Source Between Levels
int[] occurenceArray    = array.new<int>(amountOfColumns+1,0)
if time>timeFilter                                                                          // used for faster loading times
    for counter                 = 0 to amountOfColumns
        arrayCounter            = 0
        upLimit                 = array.get(MPArray,counter)
        bottomLimit             = array.get(MPArray,counter+1)
        for offset              = 0 to marketProfileLength
            if (low[offset]>bottomLimit and low[offset]<upLimit) or (high[offset]>bottomLimit and high[offset]<upLimit) or (low[offset]<bottomLimit and high[offset]>upLimit)
                arrayCounter   := arrayCounter+1 
                array.set(occurenceArray, counter,arrayCounter)
        // Draw Market Profile
        if showProfile
            for i           = 0 to amountOfColumns by 1
                MPLows              = array.get(MPArray, i+1)
                MPHigh              = array.get(MPArray, i)
                MPOccurence         = array.get(occurenceArray, i)
                maxCount            = array.size(occurenceArray) > 0 ? array.max(occurenceArray) : 1
                if MPOccurence >= minSize
                    box.new(left=bar_index + distLastCandle, top=MPHigh, right=bar_index + distLastCandle + MPOccurence, bottom=MPLows, bgcolor=color.new(getColor(i,occurenceArray, maxCount),93), border_color=color.new(getColor(i,occurenceArray, maxCount),0), border_width=borderWidth)

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> Extract Market Profile Levels <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

level0                  = showHistory ? array.size(MPArray)>=3  ? (array.get(MPArray, 0)  + array.get(MPArray, 1))/2  : na : na
level1                  = showHistory ? array.size(MPArray)>=4  ? (array.get(MPArray, 1)  + array.get(MPArray, 2))/2  : na : na
level2                  = showHistory ? array.size(MPArray)>=5  ? (array.get(MPArray, 2)  + array.get(MPArray, 3))/2  : na : na
level3                  = showHistory ? array.size(MPArray)>=6  ? (array.get(MPArray, 3)  + array.get(MPArray, 4))/2  : na : na
level4                  = showHistory ? array.size(MPArray)>=7  ? (array.get(MPArray, 4)  + array.get(MPArray, 5))/2  : na : na
level5                  = showHistory ? array.size(MPArray)>=8  ? (array.get(MPArray, 5)  + array.get(MPArray, 6))/2  : na : na
level6                  = showHistory ? array.size(MPArray)>=9  ? (array.get(MPArray, 6)  + array.get(MPArray, 7))/2  : na : na
level7                  = showHistory ? array.size(MPArray)>=10 ? (array.get(MPArray, 7)  + array.get(MPArray, 8))/2  : na : na
level8                  = showHistory ? array.size(MPArray)>=11 ? (array.get(MPArray, 8)  + array.get(MPArray, 9))/2  : na : na
level9                  = showHistory ? array.size(MPArray)>=12 ? (array.get(MPArray, 9)  + array.get(MPArray, 10))/2 : na : na
level10                 = showHistory ? array.size(MPArray)>=13 ? (array.get(MPArray, 10) + array.get(MPArray, 11))/2 : na : na
level11                 = showHistory ? array.size(MPArray)>=14 ? (array.get(MPArray, 11) + array.get(MPArray, 12))/2 : na : na
level12                 = showHistory ? array.size(MPArray)>=15 ? (array.get(MPArray, 12) + array.get(MPArray, 13))/2 : na : na
level13                 = showHistory ? array.size(MPArray)>=16 ? (array.get(MPArray, 13) + array.get(MPArray, 14))/2 : na : na
level14                 = showHistory ? array.size(MPArray)>=17 ? (array.get(MPArray, 14) + array.get(MPArray, 15))/2 : na : na
level15                 = showHistory ? array.size(MPArray)>=18 ? (array.get(MPArray, 15) + array.get(MPArray, 16))/2 : na : na
level16                 = showHistory ? array.size(MPArray)>=19 ? (array.get(MPArray, 16) + array.get(MPArray, 17))/2 : na : na
level17                 = showHistory ? array.size(MPArray)>=20 ? (array.get(MPArray, 17) + array.get(MPArray, 18))/2 : na : na
level18                 = showHistory ? array.size(MPArray)>=21 ? (array.get(MPArray, 18) + array.get(MPArray, 19))/2 : na : na
level19                 = showHistory ? array.size(MPArray)>=22 ? (array.get(MPArray, 19) + array.get(MPArray, 20))/2 : na : na
level20                 = showHistory ? array.size(MPArray)>=23 ? (array.get(MPArray, 20) + array.get(MPArray, 21))/2 : na : na
level21                 = showHistory ? array.size(MPArray)>=24 ? (array.get(MPArray, 21) + array.get(MPArray, 22))/2 : na : na
level22                 = showHistory ? array.size(MPArray)>=25 ? (array.get(MPArray, 22) + array.get(MPArray, 23))/2 : na : na
level23                 = showHistory ? array.size(MPArray)>=26 ? (array.get(MPArray, 23) + array.get(MPArray, 24))/2 : na : na
level24                 = showHistory ? array.size(MPArray)>=27 ? (array.get(MPArray, 24) + array.get(MPArray, 25))/2 : na : na
level25                 = showHistory ? array.size(MPArray)>=28 ? (array.get(MPArray, 25) + array.get(MPArray, 26))/2 : na : na
level26                 = showHistory ? array.size(MPArray)>=29 ? (array.get(MPArray, 26) + array.get(MPArray, 27))/2 : na : na
level27                 = showHistory ? array.size(MPArray)>=30 ? (array.get(MPArray, 27) + array.get(MPArray, 28))/2 : na : na
level28                 = showHistory ? array.size(MPArray)>=31 ? (array.get(MPArray, 28) + array.get(MPArray, 29))/2 : na : na
level29                 = showHistory ? array.size(MPArray)>=32 ? (array.get(MPArray, 29) + array.get(MPArray, 30))/2 : na : na
level30                 = showHistory ? array.size(MPArray)>=33 ? (array.get(MPArray, 30) + array.get(MPArray, 31))/2 : na : na
level31                 = showHistory ? array.size(MPArray)>=34 ? (array.get(MPArray, 31) + array.get(MPArray, 32))/2 : na : na
maxCount                = showHistory ? array.size(occurenceArray)  > 0  ?  array.max(occurenceArray) : 1 : na

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> Graphical Display <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

sizing                  = size.auto             // change code here if you want to change size of the developing profile characters
noColor                 = color.rgb(0,0,0,100)
plotchar(level0>0  and showHistory ? level0  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(0, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level1>0  and showHistory ? level1  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(1, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level2>0  and showHistory ? level2  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(2, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level3>0  and showHistory ? level3  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(3, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level4>0  and showHistory ? level4  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(4, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level5>0  and showHistory ? level5  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(5, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level6>0  and showHistory ? level6  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(6, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level7>0  and showHistory ? level7  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(7, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level8>0  and showHistory ? level8  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(8, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level9>0  and showHistory ? level9  : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(9, occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level10>0 and showHistory ? level10 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(10,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level11>0 and showHistory ? level11 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(11,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level12>0 and showHistory ? level12 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(12,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level13>0 and showHistory ? level13 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(13,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level14>0 and showHistory ? level14 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(14,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level15>0 and showHistory ? level15 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(15,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level16>0 and showHistory ? level16 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(16,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level17>0 and showHistory ? level17 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(17,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level18>0 and showHistory ? level18 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(18,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level19>0 and showHistory ? level19 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(19,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level20>0 and showHistory ? level20 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(20,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level21>0 and showHistory ? level21 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(21,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level22>0 and showHistory ? level22 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(22,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level23>0 and showHistory ? level23 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(23,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level24>0 and showHistory ? level24 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(24,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level25>0 and showHistory ? level25 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(25,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level26>0 and showHistory ? level26 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(26,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level27>0 and showHistory ? level27 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(27,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level28>0 and showHistory ? level28 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(28,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level29>0 and showHistory ? level29 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(29,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level30>0 and showHistory ? level30 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(30,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
plotchar(level31>0 and showHistory ? level31 : close, char=charToUse, location = location.absolute, color=showHistory ? getColor(31,occurenceArray, maxCount) : noColor, size=sizing, editable=false)
````

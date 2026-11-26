# Previous Candle Range indicator

- url: https://www.tradingview.com/script/jLUiE8cD-Previous-Candle-Range-indicator/
- type: indicator
- pine_id: PUB;4c948cb138d346fabc240b242e922073
- version: 5.0

## Description

Primary Functions:
[list=1]
[*]Display the high, low, open, and close of the previous candle from a selected timeframe
[*]Show a 50% level (midpoint between high and low)
[*]Optionally show customizable percentage levels (e.g., 61.8% Fibonacci level)
[*]Help identify:
[/list]
[list]
[*]Support and resistance zones
[*]Breakout levels
[*]Potential reversal points
[*]Stop-loss and take-profit placements
[/list]

🎨 Visual Design

Line	            Color	              Style    Width	             Description
-----------------------------------------------------------------------------------------------------------------
High	White (25% opacity)	     Dashed     1	      Previous candle's highest price

Low	White (25% opacity)	     Dashed     1	      Previous candle's lowest price

Open	Green (#13ab22)    Solid         2       Previous candle's opening price (bullish candle)

Close	Green (#13ab22)    Solid         2	      Previous candle's closing price (bullish candle)

Open	Red (#af5c4c)	     Solid         2       Previous candle's opening price (bearish candle)

Close	Red (#af5c4c)	     Solid         2	      Previous candle's closing price (bearish candle)

50% Level	Blue (#0d6aec)	     Dashed     1	      Midpoint between high and low

Custom Level  Gre (#b0d837) Dashed	     1	      User-defined percentage level
-----------------------------------------------------------------------------------------------------------------
 How It Works
1. Timeframe Logic
[list]
[*]The indicator detects if the current chart timeframe is smaller than the selected reference timeframe
[*]Lines are only displayed when the current chart is at or below the selected timeframe
[*]Example: If "D" is selected, lines show on charts ≤ Daily timeframe
[/list]

2. Candle Data Retrieval
[list]
[*]Uses request.security() to fetch OHLC data from the selected timeframe
[*]Always gets the previous candle (not the current)
[*]Updates when a new candle forms on the selected timeframe
[/list]
4. Line Management
[list]
[*]Lines extend 19 bars forward from their start point
[*]Old lines are deleted when a new candle forms
[*]Lines are hidden when chart timeframe > selected timeframe
[/list]

Best Practices
✅ When to Use
[list]
[*]Multi-timeframe analysis: Identify key levels from higher timeframes
[*]Swing trading: Use daily/weekly levels for swing positions
[*]Day trading: Use 1H/4H levels for intraday trades
[*]Scalping: Use 5m/15m levels for quick trades
[/list]

⚠️ Important Notes
[list]
[*]Lines extend 19 bars forward - adjust if needed
[*]Weekly and Monthly timeframes ignore weekends for accuracy
[*]The indicator works best with clear price action
[*]Combine with other indicators for confirmation
[/list]

The combination of the 50% level and customizable percentage levels makes it suitable for various trading styles, from scalping to swing trading.
Created by: Awab_Hassan

## Source Code

````pine
// © Awab_Hassan
//@version=6
indicator("Previous Candle Range indicator", overlay = true)

//inputs
timeframInput = input.string("D",   "Previous Candle timeframe",options=["3m","5m","15m","30m","1H","4H","D","W","M", "3M", "6M", "12M"], 
                                                                                                                        group="setup",      display = display.all)
showmid       = input.bool  (true,  "Show 50% level",                                                                   group="setup",      display=display.none,                       tooltip="Display the 50% level of the candle from the highest price to the lowest price")
addnewlevel   = input.bool  (false, "Add New Level",                                                                    group="setup",      display=display.none,                       tooltip="Additional level with optional percentage of thr candle range (high-low)")
newlevel      = input.float (0.618, "Level Percentage",                         minval=0,    maxval=1,   step=0.01,     group="setup",      display=display.none, active=addnewlevel,   tooltip="0-100% : 0-1 EX. (45% = 0.45)")
allow_EMA     = input.bool  (true,  "Allow Higher Timeframe EMA confirmation",                                          group="EMA setup",  display=display.none,                       tooltip="This EMA will reflect trends from the selected Previous Candle timeframe regardless of the chart's current timeframe.")
lenEMA        = input.int   (50,    "   Higher Timeframe EMA length",           minval=1,                step= 1,       group="EMA setup",  display=display.none, active=allow_EMA)
src           = input       (close, "   Source",                                                                        group="EMA setup",  display=display.none, active=allow_EMA)
offset        = input.int   (0,     "   Offset",                                minval=-500, maxval=500, step= 1,       group="EMA setup",  display=display.none, active=allow_EMA)

// current timeframe
chartTF = timeframe.in_seconds() / 60

//variables
var int barindex      = 1
var float prevHigh    = na
var float prevLow     = na
var float prevClose   = na
var float prevOpen    = na
var float prevRange   = na
var float midlevel    = na
var float level_added = na
var line highLine     = na
var line lowLine      = na
var line closeLine    = na
var line openLine     = na
var line midLine      = na
var line addedLine    = na

// function to draw lines
creat_lines(_start, _price, _color, _style, _End) =>
    line_width = 1
    line.new(
            x1=_start, y1=_price,
            x2=_End, y2=_price,
            color=_color, style=_style, width=line_width,
            extend=extend.none,  //
            xloc=xloc.bar_time 
        )

colourL = color.new(#13ab22, 8)

[timefram_str, shouldShow] = switch timeframInput

    "3m"    =>  ["3",   chartTF <= 3        ]
    "5m"    =>  ["5" ,  chartTF <= 5        ]
    "15m"   =>  ["15",  chartTF <= 15       ]
    "30m"   =>  ["30",  chartTF <= 30       ] 
    "1H"    =>  ["60",  chartTF <= 60       ]       
    "4H"    =>  ["240", chartTF <= 240      ]
    "D"     =>  ["D",   chartTF <= 1440     ]
    "W"     =>  ["W",   chartTF <= 10080    ]
    "M"     =>  ["M",   chartTF <= 43800.5  ]
    "3M"    =>  ["3M",  chartTF <= 131400.15]
    "6M"    =>  ["6M",  chartTF <= 262800.3 ]
    "12M"    => ["12M", chartTF<= 525600.6  ]    
// Time configuration
ny_tz         = "America/New_York"

is_new_candle = ta.change(time(timefram_str)) != 0
// the stat and end of period
OpenTime    = time(timefram_str, ny_tz) 
CloseTime   = time_close(timefram_str, ny_tz)

// Get candle OHLC
[_high, _low, _open, _close, emaout] = request.security(syminfo.tickerid, timefram_str, [high[1], low[1], open[1], close[1], ta.ema(src, lenEMA)[offset]], lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off )
prevHigh  := _high
prevLow   := _low
prevOpen  := _open
prevClose := _close
prevRange := prevHigh - prevLow

//calculate additional levels
if showmid
    midlevel := prevHigh - (prevRange / 2) 

if prevClose > prevOpen
    colourL  := color.new(#13ab22, 8)
    if addnewlevel
        level_added := prevHigh - (prevRange * newlevel)
else 
    colourL  := color.new(#af5c4c, 10)
    if addnewlevel
        level_added := (prevRange * newlevel) + prevLow




// Create new lines if correct TF
if shouldShow 
    //(New period started)
    if is_new_candle
     // Delete previous lines
        line.delete(addedLine)
        line.delete(highLine)
        line.delete(lowLine)
        line.delete(closeLine)
        line.delete(openLine)  
        line.delete(midLine)  
        // Create new lines
        highLine  := creat_lines(OpenTime, prevHigh,   color.new(#ffffff, 25),  line.style_dashed,  CloseTime)
        lowLine   := creat_lines(OpenTime, prevLow,    color.new(#ffffff, 25),  line.style_dashed,  CloseTime)
        closeLine := creat_lines(OpenTime, prevClose,    colourL,                 line.style_solid,   CloseTime)
        openLine  := creat_lines(OpenTime, prevOpen,     colourL,                 line.style_solid,   CloseTime)
        midLine   := creat_lines(OpenTime, midlevel,   color.new(#0d6aec, 0),   line.style_dashed,  CloseTime)
        addedLine := creat_lines(OpenTime, level_added,color.new(#b0d837, 25),  line.style_dashed,  CloseTime)

else
    // Delete all lines on a higher timeframe
    line.delete(addedLine)
    line.delete(highLine)
    line.delete(lowLine)
    line.delete(closeLine)
    line.delete(openLine)  
    line.delete(midLine)

// plot EMA
plot(allow_EMA and shouldShow ? emaout : na , color=color.rgb(243, 58, 33, 15), title="EMA", linewidth=1, display=display.pane + display.price_scale)
````

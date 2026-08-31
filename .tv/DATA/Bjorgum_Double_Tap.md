<!-- tradingview-pine-id: PUB;fce136c6338844529776ec19bbe63074 -->
<!-- tradingviewscripts-format: 1 -->
# Bjorgum Double Tap

Source: https://www.tradingview.com/script/rLkjr2sQ-Bjorgum-Double-Tap/

## Description

█  OVERVIEW

Double Tap is a pattern recognition script aimed at detecting Double Tops and Double Bottoms. Double Tap can be applied to the broker emulator to observe historical results, run as a trading bot for live trade alerts in real time with entry signals, take profit, and stop orders, or to simply detect patterns. 

█  CONCEPTS

How Is A Pattern Defined?
Doubles are technical formations that are both reversal patterns and breakout patterns. These formations typically have a distinctive “M” or a “W” shape with price action breaking beyond the neckline formed by the center of the pattern. They can be recognized when a ​pivot fails to break when tested for a second time and the retracement that follows breaks beyond the key level opposite. This can trap entrants that were playing in the direction of the prior trend. Entries are made on the breakout with a target projected beyond the neckline equal to the height of the pattern. 

Pattern Recognition
Patterns are recognized through the use of ​zig-zag; a method of filtering price action by connecting swing highs and lows in an alternating fashion to establish trend, ​support and resistance, or derive shapes from price action. The script looks for the highest or lowest point in a given number of bars and updates a list with the values as they form. If the levels are exceeded, the values are updated. If the direction changes and a new significant point is made, a new point is added to the list and the process starts again. Meanwhile, we scan the list of values looking for the distinctive shape to form as previously described. 

█  STRATEGY RESULTS

Back Testing
Historical back testing is the most common method to test a strategy due in part to the general ease of gathering quick results. The underlying theory is that any strategy that worked well in the past is likely to work well in the future, and conversely, any strategy that performed poorly in the past is likely to perform poorly in the future. It is easy to poke holes in this theory, however, as for one to accept it as gospel, one would have to assume that future results will match what has come to pass. The randomness of markets may see to it otherwise, so it is important to scrutinize results. Some commonly used methods are to compare to other markets or benchmarks, perform statistical analysis on the results over many iterations and on differing datasets, walk-forward testing, out-of-sample analysis, or a variety of other techniques. There are many ways to interpret the results, so it is important to do research and gain knowledge in the field prior to taking meaningful conclusions from them. 

👉  In short, it would be naive to place trust in one good backtest and expect positive results to continue. For this reason, results have been omitted from this publication. 

Repainting
Repainting is simply the difference in behaviour of a strategy in real time vs the results calculated on the historical dataset. The strategy, by default, will wait for confirmed signals and is thus designed to not repaint. Waiting for bar close for entires aligns results in the real time data feed to those calculated on historical bars, which contain far less data. By doing this we align the behaviour of the strategy on the 2 data types, which brings significance to the calculated results. To override this behaviour and introduce repainting one can select "Recalculate on every tick" from the properties tab. It is important to note that by doing this alerts may not align with results seen in the strategy tester when the chart is reloaded, and thus to do so is to forgo backtesting and restricts a strategy to forward testing only. 

👉  It is possible to use this script as an indicator as opposed to a full strategy by disabling "Use Strategy" in the "Inputs" tab. Basic alerts for detection will be sent when patterns are detected as opposed to complex order syntax. For alerts mid-bar enable "Recalculate on every tick", and for confirmed signals ensure it is disabled. 
  

█  EXIT ORDERS

Limit and Stop Orders
By default, the strategy will place a stop loss at the invalidation point of the pattern. This point is beyond the pattern high in the case of Double Tops, or beneath the pattern low in the case of Double Bottoms. The target or take profit point is an equal-legs measurement, or 100% of the pattern height in the direction of the pattern bias. Both the stop and the limit level can be adjusted from the user menu as a percentage of the pattern height. 

Trailing Stops
Optional from the menu is the implementation of an ATR based trailing stop. The trailing stop is designed to begin when the target projection is reached. From there, the script looks back a user-defined number of bars for the highest or lowest point +/- the ATR value. For tighter stops the user can look back a lesser number of bars, or decrease the ATR multiple. When using either Alertatron or Trading Connector, each change in the trail value will trigger an alert to update the stop order on the exchange to reflect the new trail price. This reduces latency and slippage that can occur when relying on alerts only as real exchange orders fill faster and remain in place in the event of a disruption in communication between your strategy and the exchange, which ensures a higher level of safety. 

👉  It is important to note that in the case the trailing stop is enabled, limit orders are excluded from the exit criteria. Rather, the point in time that the limit value is exceeded is the point that the trail begins. As such, this method will exit by stop loss only. 

█  ALERTS

Five Built-in 3rd Party Destinations
The following are five options for delivering alerts from Double Tap to live trade execution via third party ​API solutions or chat bots to share your trades on social media. These destinations can be selected from the input menu and alert syntax will automatically configure in alerts appropriately to manage trades. 

Custom JSON
JSON, or JavaScript Object Notation, is a readable format for structuring data. It is used primarily to transmit data between a server and a web application. In regards to this script, this may be a custom intermediary web application designed to catch alerts and interface with an exchange ​API. The JSON message is a trade map for an application to read equipped with where its been, where its going, targets, stops, quantity; a full diagnostic of the current state and its previous state. A web application could be configured to follow the messages sent in this format and conduct trades in sync with alerts running on the TV server.  

Below is an example of a rendered JSON alert: 

[pine] { 
    "passphrase": "1234", 
    "time": "2022-05-01T17:50:05Z", 
    "ticker": "ETHUSDTPERP", 
    "plot": { 
        "stop_price": 2600.15, 
        "limit_price": 3100.45 
    }, 
    "strategy": { 
        "position_size": 0.1, 
        "order_action": "buy", 
        "market_position": "long",
        "market_position_size": 0, 
        "prev_market_position": "flat", 
        "prev_market_position_size": 0 
    } 
}[/pine]

Trading Connector
Trading Connector is a third party fully autonomous Chrome extension designed to catch alert webhooks from TradingView and interface with MT4/MT5 to execute live trades from your machine. Alerts to Trading Connector are simple; just select the destination from the input drop down menu, set your ticker in the "TC Ticker" box in the "Alert Strings" section and enter your URL in the alert window when configuring your alert. 

Alertatron
Alertatron is an automated algo platform for cryptocurrency trading that is designed to automate your trading strategies. Although the platform is currently restricted to crypto, it offers a versatile interface with high flexibility syntax for complex market orders and conditions. To direct alerts to Alertatron, select the platform from the 3rd party drop down, configure your ​API key in the ”Alertatron Key” box and add your URL in the alert message box when making alerts. 

3 Commas
3 Commas is an easy and quick to use click-and-go third party crypto ​API solution. Alerts are simple without overly complex syntax. Messages are simply pasted into alerts and executed as alerts are triggered. There are 4 boxes at the bottom of the "Inputs" tab where the appropriate messages to be placed. These messages can be copied from 3 Commas after the bots are set up and pasted directly into the settings menu. Remember to select 3 Commas as a destination from the third party drop down and place the appropriate URL in the alert message window. 

Discord
Some may wish to share their trades with their friends in a Discord chat via webhook chat bot. Messages are configured to notify of the pattern type with targets and stop values. A bot can be configured through the integration menu in a Discord chat to which you have appropriate access. Select Discord from the 3rd party drop down menu and place your chat bot URL in the alert message window when configuring alerts. 

👉  For further information regarding alert setup, refer to the platform specific instructions given by the chosen third party provider. 

█  IMPORTANT NOTES

Setting Alerts
For alert messages to be properly delivered on order fills it is necessary to place the following placeholder in the alert message box when creating an alert. 
[pine]{{strategy.order.alert_message}}[/pine]
This placeholder will auto-populate the alert message with the appropriate syntax that is designated for the 3rd party selected in the user menu. 

Order Sizing and Commissions
The values that are sent in alert messages are populated from live metrics calculated by the strategy. This means that the actual values in the "Properties" tab are used and must be set by the user. The initial capital, order size, commission, etc. are all used in the calculations, so it is important to set these prior to executing live trades. Be sure to set the commission to the values used by the exchange as well. 

 👉  It is important to understand that the calculations on the account size take place from the beginning of the price history of the strategy. This means that if historical results have inflated or depleted the account size from the beginning of trade history until now, the values sent in alerts will reflect the calculated size based on the inputs in the "Properties" tab. To start fresh, the user must set the date in the "Inputs" tab to the current date as to remove trades from the trade history. Failure to follow this instruction can result in an unexpected order size being sent in the alert. 

█  FOR PINECODERS

 • With the recent [introduction of matrices](https://www.tradingview.com/blog/en/matrices-come-to-pine-script-30693/) in Pine, the script utilizes a [matrix](https://www.tradingview.com/pine-script-reference/v5/#fun_matrix%7Bdot%7Dnew%3Ctype%3E) to track ​pivot points with the bars they occurred on, while tracking if that ​pivot has been traded against to prevent duplicate detections after a trade is exited. 
 • Alert messages are populated with [placeholders](https://www.tradingview.com/chart/?solution=43000531021); capability that previously was only possible in [alertcondition()](https://www.tradingview.com/pine-script-reference/v5/#fun_alertcondition), but has recently been extended to `strategy.*()` functions for use in the `alert_message` argument. This allows delivery of live trade values to populate in strategy alert messages. 
 • New arguments have been added to [strategy.exit()](https://www.tradingview.com/pine-script-reference/v5/#fun_strategy{dot}exit), which allow differentiated messages to be sent based on whether the exit occurred at the stop or the limit. The new arguments used in this script are `alert_profit` and `alert_loss` to send messages to Discord

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bjorgum

//   ________________________________________________________________ 
//  |\______________________________________________________________/| 
//  ||   ________________                                           || 
//  ||   ___  __ )_____(_)___________________ ____  ________ ___    || 
//  ||   __  __  |____  /_  __ \_  ___/_  __ `/  / / /_  __ `__ \   || 
//  ||   _  /_/ /____  / / /_/ /  /   _  /_/ // /_/ /_  / / / / /   ||
//  ||   /_____/ ___  /  \____//_/    _\__, / \__,_/ /_/ /_/ /_/    ||
//  ||           /___/                /____/                        ||
//  ||______________________________________________________________||
//  |/______________________________________________________________\|

//@version=5
// @strategy_alert_message {{strategy.order.alert_message}}

strategy(
 title                  =   "Bjorgum Double Tap",
 shorttitle             =   "Bj Double Tap",
 overlay                =   true, 
 max_lines_count        =   500, 
 max_labels_count       =   500, 
 precision              =   3, 
 default_qty_type       =   strategy.cash, 
 commission_value       =   0.04, 
 commission_type        =   strategy.commission.percent, 
 slippage               =   1, 
 currency               =   currency.USD, 
 default_qty_value      =   1000, 
 initial_capital        =   1000)

// ══════════════════════════════════ //
// —————> Immutable Constants <—————— //
// ══════════════════════════════════ //

string      useStratTip =   "Enables or disables the strategy tester allowing a change between either an indicator or a strategy."
string      dLongTip    =   "Detect long setups."
string      dShortTip   =   "Detect short setups."
string      FLIPTip     =   "Allow entry in the opposite bias while already in a position."

string      startTip    =   "Start date & time to begin backtest period. Useful for beginning new bot. eg. Set time to now to make broker emulator in a flat position with the proper starting captial before setting alerts"
string      endTip      =   "End date & time to stop searching for setups for back testing."

string      tolTip      =   "The difference in height allowable for the signifcant points of the pattern expressed as a percent of the pattern height. Example: The points can vary in height by 15% of the pattern height from one another."
string      lenTip      =   "The length used to calcuate significant points to form pivots for pattern detection. Example: The highest or lowest point in 50 bars."
string      fibTip      =   "The fib target extension projected from the neckline of the pattern in the direction of the pattern bias expressed as a percent. Example: 100% is a 1:1 measurment of the height from the pattern neckline."
string      stopPerTip  =   "The fib extension of the pattern height measured from the point of invalidation. Example: 0% would be the high point of a double top. 50% would be halfway between the top and the neckline."
string      offsetTip   =   "The number of bars lines are extended into the future during an ongoing pattern."

string      atrStopTip  =   "Enables an ATR trailing stop once the target extension is breached. NOTE: This disables a take profit order in the strategy format."
string      atrLenTip   =   "The number of bars used in the ATR calculation."
string      atrMultTip  =   "The multiplier of the ATR value to subtract from the swing low or swing high point. Example: 1 is 100% of the ATR, 2 is 2x the ATR value."
string      lookbackTip =   "The number of bars to look back to find a swing high or swing low to be used in the trailing stop calculation. Example: 1 ATR subtracted from the lowest point in 5 bars. 1 would use the lowest point within the last bar."

string      tableTip    =   "Show the data table for trade limit levels during an active trade. (table will only show when a pattern is present on the chart, or in bar replay)."
string      labelTip    =   "Updates the double top/bottom label with 'Success' or 'Failure' and updates color based on the outcome of the pattern."

string      thirdTip    =   "Where would you like to send your alerts?"
string      pPhraseTip  =   "A custom passphrase to authenticate your json message with a touch more security."
string      aTronKeyTip =   "The name of your Alertatron API keys. (Add the ticker in brackets). Example: MyKeys(XBTUSD)."
string      tickerTip   =   "The ticker to be traded when using Trading Connector"
string      LongTip     =   "3Commas start long deal bot keys."
string      LongEndTip  =   "3Commas end long deal bot keys."
string      ShortTip    =   "3Commas start short deal bot keys."
string      ShortEndTip =   "3Commas end short deal bot keys."

string      dt          =   "Double Top"   
string      db          =   "Double Bottom"
string      suc         =   " - Success"  
string      fail        =   " - Failure"
string      winStr      =   "Target reached! 💰" 
string      loseStr     =   "Stopped out... 🤷‍♂"
string      tabPerc     =   "{0, number, #.##}\n({1, number, #.##}%)"     
string      tcStop      =   "slmod slprice={0} tradeid={1}"
string      dExit       =   "'{'\"content\": \"```Bjorgum {0}\\n\\n\\t'{{ticker}}' '{{interval}}'\\n\\n\\t{1}```\"'}'" 

string      S1          =   "tiny"   ,  string P1 = "top" 
string      S2          =   "small"  ,  string P2 = "middle" 
string      S3          =   "normal" ,  string P3 = "bottom" 
string      S4          =   "large"  ,  string P4 = "left" 
string      S5          =   "huge"   ,  string P5 = "center"
string      S6          =   "auto"   ,  string P6 = "right"
var string  tnB         =   ""       ,  string A1 = "Custom Json"
string      altStr      =   ""       ,  string A2 = "Trading Connector"
string      tUp         =   ""       ,  string A3 = "Alertatron"
string      dCordWin    =   ""       ,  string A4 = "3Commas"
string      dCordLose   =   ""       ,  string A5 = "Discord"
 
float       pos         =   strategy.position_size
int         sync        =   bar_index
bool        confirm     =   barstate.isconfirmed
var int     dir         =   na
var float   lmt         =   na 
var float   stp         =   na 
string      altExit     =   na

bool        FLAT        =   pos == 0
bool        LONG        =   pos >  0
bool        SHORT       =   pos <  0
var int     tradeId     =   0

color       col1        =   color.new(#b2b5be, 15)
color       col2        =   color.new(#b2b5be, 87)
color       col3        =   color.new(#ffffff,  0)
color       col4        =   color.new(#17ff00, 15)
color       col5        =   color.new(#ff0000, 15)
color       col6        =   color.new(#ff5252,  0)

var matrix<float> logs  =   matrix.new<float>  (5, 3)
var line [] zLines      =   array.new_line     (5)
var line [] tLines      =   array.new_line     (5)
var line [] bLines      =   array.new_line     (5)
var label[] bullLb      =   array.new_label     ()
var label[] bearLb      =   array.new_label     ()

int timeStart           =   timestamp("01 Jan 2000")
int timeEnd             =   timestamp("01 Jan 2099")

// ══════════════════════════════════ //
// —————————> User Input <——————————— //
// ══════════════════════════════════ //

string      GRP1        =   "════  Detection and Trade Parameters  ════"
bool        useStrat    =   input.bool  (true     , "Use Strategy"    , group= GRP1, tooltip= useStratTip)
bool        dLong       =   input.bool  (true     , "Detect Bottoms"  , group= GRP1, tooltip= dLongTip   )
bool        dShort      =   input.bool  (true     , "Detect Tops"     , group= GRP1, tooltip= dShortTip  )
bool        FLIP        =   input.bool  (true     , "Flip Trades"     , group= GRP1, tooltip= FLIPTip    )       
float       tol         =   input.float (15       , "Pivot Tolerance" , group= GRP1, tooltip= tolTip     , minval= 1)
int         len         =   input.int   (50       , "Pivot Length"    , group= GRP1, tooltip= lenTip     , minval= 1)
float       fib         =   input.float (100      , "Target Fib"      , group= GRP1, tooltip= fibTip     , minval= 0)
int         stopPer     =   input.int   (0        , "Stop Loss Fib"   , group= GRP1, tooltip= stopPerTip )
int         offset      =   input.int   (30       , "Line Offset"     , group= GRP1, tooltip= offsetTip  , minval= 0)

string      GRP2        =   "═══════════ Time Filter ═══════════"
int         startTime   =   input.time(timeStart  , "Start Filter"    , group= GRP2, tooltip= startTip)      
int         endTime     =   input.time(timeEnd    , "End Filter"      , group= GRP2, tooltip= endTip  )        

string      GRP3        =   "══════════ Trailing Stop ══════════"
bool        atrStop     =   input.bool  (false    , "Use Trail Stop"  , group= GRP3, tooltip= atrStopTip )
int         atrLength   =   input.int   (14       , "ATR Length"      , group= GRP3, tooltip= atrLenTip  , minval= 1)
float       atrMult     =   input.float (1        , "ATR Multiplier"  , group= GRP3, tooltip= atrMultTip , minval= 0)
int         lookback    =   input.int   (5        , "Swing Lookback"  , group= GRP3, tooltip= lookbackTip, minval= 1)

string      GRP5        =   "════════════ Colors ════════════"
color       col         =   input.color (col1     , "Lines        "   , group= GRP5, inline= "41")
color       zCol        =   input.color (col3     , "Patterns       " , group= GRP5, inline= "42")
int         hWidth      =   input.int   (1        , ""                , group= GRP5, inline= "41", minval= 1)
int         zWidth      =   input.int   (1        , ""                , group= GRP5, inline= "42", minval= 1)
color       colf        =   input.color (col2     , "Stop Fill"       , group= GRP5)
color       tCol        =   input.color (col4     , "Target Color"    , group= GRP5)
color       sCol        =   input.color (col5     , "Stop Color"      , group= GRP5)
color       trailCol    =   input.color (col6     , "Trail Color"     , group= GRP5)

string      GRP6        =   "═════════  Table and Label  ═════════"
bool        showTable   =   input.bool  (true     , "Show Table"      , group= GRP6, tooltip= tableTip) 
bool        setLab      =   input.bool  (true     , "Update Label"    , group= GRP6, tooltip= labelTip)
string      labSize     =   input.string("small"  , "Label Text Size" , group= GRP6, options= [S1, S2, S3, S4, S5, S6])
string      textSize    =   input.string("normal" , "Table Text Size" , group= GRP6, options= [S1, S2, S3, S4, S5, S6])
string      tableYpos   =   input.string("bottom" , "Table Position"  , group= GRP6, options= [P1, P2, P3])
string      tableXpos   =   input.string("right"  , ""                , group= GRP6, options= [P4, P5, P6])

string      GRP7        =   "══════════ Alert Strings ══════════"
string      thirdParty  =   input.string(A1       , "3rd Party"       , group= GRP7, tooltip= thirdTip, options= [A1, A2, A3, A4, A5])
string      pPhrase     =   input.string("1234"   , "Json Passphrase" , group= GRP7, tooltip= pPhraseTip ) 
string      aTronKey    =   input.string("myKeys" , "Alertatron Key"  , group= GRP7, tooltip= aTronKeyTip)
string      tcTicker    =   input.string(""       , "TC Ticker"       , group= GRP7, tooltip= tickerTip  )
string      c3Long      =   input.string(""       , "3Comma Long"     , group= GRP7, tooltip= LongTip    )
string      c3LongEnd   =   input.string(""       , "3Comma Long End" , group= GRP7, tooltip= LongEndTip )
string      c3Short     =   input.string(""       , "3Comma Short"    , group= GRP7, tooltip= ShortTip   )
string      c3ShortEnd  =   input.string(""       , "3Comma Short End", group= GRP7, tooltip= ShortEndTip)

// ══════════════════════════════════ //
// ————> Variable Calculations <————— //
// ══════════════════════════════════ //
    
bool        dif         =   stopPer != 0 
int         set         =   sync + offset

float       atr         =   ta.atr          (14)
float       sLow        =   ta.lowest       (lookback) - (atr * atrMult)
float       sHigh       =   ta.highest      (lookback) + (atr * atrMult)

float       pivHigh     =   ta.highest      (len)
float       pivLows     =   ta.lowest       (len)

float       hbar        =   ta.highestbars  (len)
float       lbar        =   ta.lowestbars   (len)

// ══════════════════════════════════ //
// ———> Functional Declarations <———— //
// ══════════════════════════════════ //

High(m)  => 
    float result = (m == 1 ? high : low)
    
Low(m)   => 
    float result = (m == 1 ? low  : high)
    
perD(_p) => 
    float result = (_p - close) / close * 100

_coords(_x, _i)                      =>
    x = matrix.get                   (_x, _i, 0)
    y = matrix.get                   (_x, _i, 1)
    [int(x), y]

_arrayLoad(_x, _max, _val)           =>  
    array.unshift                    (_x,   _val)   
    if  array.size                   (_x) > _max
        array.pop                    (_x)

_matrixPush(_mx, _max, _row)         =>
    matrix.add_row(_mx, matrix.rows  (_mx),  _row)
    if matrix.rows                   (_mx) > _max
        matrix.remove_row            (_mx, 0)

_mxLog(_cond, _x, _y)                =>
    float[] _row = array.from        (sync, _y, 0)
    if _cond 
        _matrixPush                  (_x, 5, _row)

_mxUpdate(_cond, _dir, _x, y)        =>
    int m    = _dir ? 1 : -1
    int _end = matrix.rows           (_x) -1
    if  _cond and y * m > matrix.get (_x, _end, 1) * m 
        matrix.set                   (_x, _end, 0, sync)
        matrix.set                   (_x, _end, 1, y)

_extend(_x, _len) =>
    for l in _x
        line.set_x2(l, _len)

_hLine(_l, x2, y2, y3, y4, y5, _t)   =>
    line l1 =             line.new   (x2    , y2, set, y2, color= col,  width= hWidth)
    line l2 =             line.new   (x2    , y4, set, y4, color= col,  width= hWidth)
    array.set (_l    , 3, l1)
    array.set (_l    , 2, l2)
    array.set (_l    , 1, line.new   (x2    , y3, set, y3, color= col,  width= hWidth))
    array.set (_l    , 0, line.new   (sync-1, _t, set, _t, color= col,  width= hWidth))
    linefill.new                     (l1    , l2, colf)
    if stopPer != 0
        array.set (_l, 4, line.new   (sync-1, y5, set, y5, color= col,  width= hWidth))

_zLine(x1, y1, x2, y2, x3, y3, x4, y4) =>
    array.set (zLines, 3, line.new   (x1, y1, x2  , y2   , color= zCol, width= zWidth))
    array.set (zLines, 2, line.new   (x2, y2, x3  , y3   , color= zCol, width= zWidth))
    array.set (zLines, 1, line.new   (x3, y3, x4  , y4   , color= zCol, width= zWidth))
    array.set (zLines, 0, line.new   (x4, y4, sync, close, color= zCol, width= zWidth))

_label(x, y, m) =>
    m > 0 ?  
   _arrayLoad (bearLb, 1, label.new  (x, y, dt, color= color(na), style= label.style_label_down, textcolor= col, size= labSize)) : 
   _arrayLoad (bullLb, 1, label.new  (x, y, db, color= color(na), style= label.style_label_up,   textcolor= col, size= labSize))

_labelUpdate(_x, _y, m)              =>
    if (_x or _y) and setLab
        label  lab  = array.get      (m > 0 ? bearLb : bullLb, 0)
        string oStr =                (m > 0 ? dt     : db)
        string nStr = oStr +         (_x    ? suc    : fail)
        label.set_text               (lab, nStr)
        label.set_textcolor          (lab, _x ? tCol : sCol)

_atrTrail(_cond, _lt, _s, m)         =>
    var float _stop  = na
    var bool  _flag  = na
    var bool  _trail = na
    _flag           := _cond
    _stop           := _s
    _trail          := _flag ? false : _trail
    if atrStop and useStrat
        if  _lt
            _flag   := false 
            _trail  := true  
        _stop       := m == -1 ? _lt ? sLow  : math.max(_stop, sLow)  : _stop 
        _stop       := m ==  1 ? _lt ? sHigh : math.min(_stop, sHigh) : _stop 
    if High(m) * m > _stop * m 
        _flag       := true
        _trail      := false
    [_flag, _stop, _trail]

_inTrade(_cond, _x, _e, m)           =>
    var bool  _flag  =               na
    var float _stop  =               na 
    var float _limit =               na
    line      l1     = array.get     (_x, 0)
    float     lp     = line.get_price(l1, sync)
    line      l2     = array.get     (_x, dif ? 4 : 2)
    float     ls     = line.get_price(l2, sync)
    bool      win    = Low (m) *     m <= lp * m and not _e
    bool      lose   = High(m) *     m >= ls * m and not _e
    _flag           := _cond
    _stop           := _e ? ls :     _stop
    _limit          := _e ? lp :     _limit
    if win or lose  
        _flag       :=               true
        _extend                      (_x    , sync)
        _labelUpdate                 (win   , lose, m)
        line.set_color               (win   ? l1 : l2, win ? tCol : sCol)
        array.fill                   (_x    , na)
        array.fill                   (zLines, na)
    [_f, _s, _t]     = _atrTrail     (_flag , win  , _stop, m)
    _flag           :=               atrStop  ? _f : _flag
    _stop           :=               _t and _s * m < _stop * m and confirm ? _s : _stop
    [_flag, _stop, _t, _limit]

_double(_cond, _l, _x, m)            =>
    var bool _flag   = na
    int _rows        = matrix.rows   (_x)
    _flag           := _cond
    if _flag
        [x1, y1]     = _coords       (_x , _rows - 5)
        [x2, y2]     = _coords       (_x , _rows - 4)
        [x3, y3]     = _coords       (_x , _rows - 3)
        [x4, y4]     = _coords       (_x , _rows - 2)
        bool  traded = matrix.get    (_x , _rows - 2, 2)
        float height = math.avg      (y2 , y4)   - y3
        float _high  = y2 + height * (tol/ 100)
        float _low   = y2 - height * (tol/ 100)
        float _t     = y3 - height * (fib/ 100)
        float y5     = y2 * m < y4 * m ? y2 : y4
        float y6     = y2 * m > y4 * m ? y2 : y4
        float y7     = y6 - height *(stopPer/100)    
        bool result  = y1*m < y3*m and y4*m <= _high*m and y4*m >= _low*m and close*m < y3*m and not (close[1]*m < y3*m) and not traded
        if result and _flag and (m > 0 ? dShort : dLong)
            _hLine       (_l, x2, y5, y3, y6, y7, _t)
            _zLine       (x1, y1, x2, y2, x3, y3, x4, y4)
            _label       (x4, y6, m)
            matrix.set   (_x, _rows - 2, 2, 1)
            _flag :=     false
    _flag 

_scan(_l, _x, m)     =>
    var bool _cond   = true
    _cond           := _double       (_cond, _l, _x, m)
    bool enter       = _cond[1]      and not _cond
    [f,s,t,l]        = _inTrade      (_cond, _l, enter, m)
    _cond           := f
    _extend(_l, set)
    [f,s,t,l]

_populate(_n, _x, _i, _col) => 
    for [i, _a] in _x 
        if not na(_a)
            table.cell(table_id  = _n,  column     = _i  , 
                       row       =  i,  bgcolor    = na  , 
                       text      = _a,  text_color = _col, 
                       text_size =      textSize)
    
// ══════════════════════════════════ //
// ————————> Logical Order <————————— //
// ══════════════════════════════════ //

dir            :=  not hbar ? 1 : not lbar ? 0 : dir

bool dirUp      =  dir != dir[1] and     dir 
bool dirDn      =  dir != dir[1] and not dir 

bool setUp      =  not hbar and     dir 
bool setDn      =  not lbar and not dir 

_mxLog             (dirUp or dirDn,      logs, dirUp ? pivHigh : pivLows)
_mxUpdate          (setUp or setDn, dir, logs, setUp ? pivHigh : pivLows)

[bear,ss,ts,sl] =  _scan(tLines, logs,  1)
[bull,ls,tl,ll] =  _scan(bLines, logs, -1)

bool st         =  SHORT ? ts : false
bool lt         =  LONG  ? tl : false

bool sell       =  bear[1] and not bear 
bool buy        =  bull[1] and not bull

color ssCol     =  st or st[1] ? trailCol : na
color lsCol     =  lt or lt[1] ? trailCol : na

bool longEntry  =  buy  and (FLAT or (SHORT and FLIP)) 
bool shortEntry =  sell and (FLAT or (LONG  and FLIP)) 

bool dateFilter =  time >= startTime and time <= endTime

tradeId        +=  longEntry or shortEntry ? 1 : 0

lmt            :=  atrStop    ? na :
                   shortEntry ? sl : longEntry ? ll : lmt 

stp            :=  shortEntry or SHORT and atrStop ? ss : 
                   longEntry  or LONG  and atrStop ? ls : stp
                   
plot               (atrStop ? ss : na, "Short Stop", ssCol, style= plot.style_linebr)
plot               (atrStop ? ls : na, "Long Stop",  lsCol, style= plot.style_linebr)

bgcolor            (not dateFilter ? color.new(color.red,80) : na, title= "Filter Color")

// ══════════════════════════════════ //
// —————————> Data Display <————————— //
// ══════════════════════════════════ //

if showTable
    
    string   tls    = bull ? na : str.format(tabPerc, ls, perD(ls))
    string   tss    = bear ? na : str.format(tabPerc, ss, perD(ss))
    string   tll    = bull ? na : str.format(tabPerc, ll, perD(ll))
    string   tsl    = bear ? na : str.format(tabPerc, sl, perD(sl))
    
    string[] titles = array.from(na, bull ? na : "Bullish", bear ? na : "Bearish")
    
    string[] stops  = array.from("Stop"  , tls, tss)
    string[] limtis = array.from("Target", tll, tsl)
    
    table    bjTab  = table.new(tableYpos + "_" + tableXpos, 3, 3, border_color= color.new(color.gray, 60), border_width= 1)
    
    if not bear or not bull 
        _populate(bjTab, titles, 0, color.white)
        _populate(bjTab, stops,  1, color.red)
        if not (na(ll) or lt) or not (na(sl) or st)
            _populate(bjTab, limtis, 2, color.green)

// ══════════════════════════════════ //
// ——————> String Variables <———————— //
// ══════════════════════════════════ //

bool cSon  = thirdParty == A1
bool tCon  = thirdParty == A2
bool aTron = thirdParty == A3
bool c3    = thirdParty == A4
bool dCord = thirdParty == A5

if cSon and useStrat
    
    string json = 
    
     "'{'
     \n    \"passphrase\": \"{0}\",
     \n    \"time\": '\"{{timenow}}\"',
     \n    \"ticker\": '\"{{ticker}}\"',
     \n    \"plot\": '{'
     \n        \"stop_price\": {1, number, #.########},
     \n        \"limit_price\": {2, number, #.########}
     \n    '}',
     \n    \"strategy\": '{'
     \n        \"position_size\": '{{strategy.position_size}}',
     \n        \"order_action\": '\"{{strategy.order.action}}\"',
     \n        \"market_position\": '\"{{strategy.market_position}}\"',
     \n        \"market_position_size\": '{{strategy.market_position_size}}',
     \n        \"prev_market_position\": '\"{{strategy.prev_market_position}}\"',
     \n        \"prev_market_position_size\": '{{strategy.prev_market_position_size}}'
     \n    '}'
     \n'}'"
    
    altStr := str.format(json, pPhrase, stp, lmt)

if tCon and useStrat

    string tcTrade = 

     "'{{strategy.order.action}}' tradesymbol={0} tradeid={1}" 
     + (atrStop ? "" : ' tpprice={2, number, #.########}') 
     + ' slprice={3, number, #.########}' 
    
    altStr  := str.format(tcTrade, tcTicker, tradeId, lmt, stp)
    tUp     := str.format(tcStop, stp, tradeId)

if aTron and useStrat

    string altEnt  = aTronKey + " '{'\ncancel(which=all);\nmarket(position='{{strategy.position_size}}');\n"
    string altEnd  = "'}'\n#bot"
    string altBrkt = 

       (atrStop ? "stopOrder(" : "stopOrTakeProfit(")
     + (atrStop ? "" : "tp=@{0, number, #.########}, ")
     + (atrStop ? "offset=@" : "sl=@") + "{1, number, #.########}, position=0, reduceOnly=true"
     + (atrStop ? ", tag=trail" : "")
     + ");\n"
    
    string enter = altEnt + altBrkt + altEnd 
    string exit  = altEnt + altEnd
    
    altStr  := str.format(enter, lmt, stp)
    altExit := na(altExit) ? exit : altExit

    string stopUpdate = aTronKey + " '{'\ncancel(which=tagged, tag=trail);\n" + altBrkt + altEnd
    
    tUp := atrStop ? str.format(stopUpdate, lmt, stp) : tUp

if dCord and useStrat

    tnB := longEntry ? db : shortEntry ? dt : tnB

    string postTrade = 
    
     "'{'\"content\": \"```🚨 Bjorgum {0} detected 🚨\\n\\n\\t'{{ticker}}' '{{interval}}'\\n\\n\\t"
     + (atrStop ? "" : "🎯 Target: {1, number, #.########}\\n\\t") 
     + "🛑 Stop:   {2, number, #.########}```\"'}'"

    altStr    := str.format(postTrade, tnB, lmt, stp)
    dCordWin  := str.format(dExit, tnB, winStr)
    dCordLose := str.format(dExit, tnB, loseStr)

if c3 and useStrat

    c3Long  := SHORT and buy  ? str.format("[{0}, {1}]", c3ShortEnd, c3Long)  : c3Long 
    c3Short := LONG  and sell ? str.format("[{0}, {1}]", c3LongEnd,  c3Short) : c3Short

// ══════════════════════════════════ //
// ——————> Strategy Execution <—————— //
// ══════════════════════════════════ //

strategy.entry("Long" , strategy.long , comment= "Long",  when= useStrat and longEntry  and dateFilter, alert_message= c3 ? c3Long  : altStr)
strategy.entry("Short", strategy.short, comment= "Short", when= useStrat and shortEntry and dateFilter, alert_message= c3 ? c3Short : altStr)

strategy.exit("Long Exit", 
              "Long",  
              stop          = stp, 
              limit         = lmt, 
              comment       = "L Exit", 
              alert_message = c3    ? c3LongEnd : aTron ? altExit : tCon ? "closelong"  : dCord ? na : altStr, 
              alert_profit  = dCord ? dCordWin  : na, 
              alert_loss    = dCord ? dCordLose : na)

strategy.exit("Short Exit", 
              "Short", 
              stop          = stp, 
              limit         = lmt, 
              comment       = "S Exit", 
              alert_message = c3    ? c3ShortEnd : aTron ? altExit : tCon ? "closeshort" : dCord ? na : altStr, 
              alert_profit  = dCord ? dCordWin   : na, 
              alert_loss    = dCord ? dCordLose  : na)
    
// ══════════════════════════════════ //
// —————> Alert Functionality <—————— //
// ══════════════════════════════════ //

if (lt and ls != ls[1] or st and ss != ss[1]) and (tCon or aTron)
    alert(tUp, alert.freq_once_per_bar_close)

if not useStrat and (buy or sell)
    alert((buy ? db : dt) + ' Detected', alert.freq_once_per_bar)

//  ____  __ _  ____ 
// (  __)(  ( \(    \
//  ) _) /    / ) D (
// (____)\_)__)(____/
````

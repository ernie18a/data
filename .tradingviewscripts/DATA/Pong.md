<!-- tradingview-pine-id: PUB;5d4a6bf71f96450a9d4cf51a8c61a537 -->
<!-- tradingviewscripts-format: 1 -->
# Pong

Source: https://www.tradingview.com/script/SlrgQcx5-Pong/

## Description

Experience PONG! The classic arcade game, now on your charts!

With this indicator, you can finally achieve your lifelong dream of beating the Markets. . . at PONG!

Pong is jam-packed with features! Such as:

[*]2 Paddles
[*]A moving dot
[*]Floating numbers
[*]The idea of a net

This indicator is solely a visualization, it serves simply as an exercise to depict what is capable through PineScript. It can be used to re-skin other indicators or data, but on its own, is not intended as a market indicator.

With that out of the way...

> PONG

The Pong indicator is a recreation of the classic arcade game Pong developed to pit the markets against the cold hard logic of a CPU player.

[image]https://www.tradingview.com/x/6BOQEdUI/[/image]

Given the lack of interaction that is capable, the game is not played in the typical sense, by a player and computer or 2 players. 

This version of Pong uses the chart price movements to control the "Market" Paddle, and it is contrasted by a (not AI) "CPU" Paddle, which is controlled by its own set of logic.

> Market Paddle

The Market Paddle is controlled by a data source which can be input by the user. 

By default (Auto Mode), the Market Paddle is controlled through a fixed length Donchian channel range, pinning the range high to 100 and range low to 0. As seen below.
[image]https://www.tradingview.com/x/JqaYtd22/[/image]

This can be altered to use data from different symbols or indicators, and can optionally be smoothed using multiple types of Moving Averages.

In the chart below, you can see how the RSI indicator is imported and smoothed to control the Market Paddle. 
[image]https://www.tradingview.com/x/9ORqLrRE/[/image]

Note: The Market Paddle follows the moving average. If not desired, simply set the "Smoothing" input to "NONE".

> CPU Paddle

In simple terms, the CPU Paddle is a handicapped Aimbot. 
Its logic is, more or less, "move directly towards the ball's vertical location".

If it were allowed to have full range of the screen, it would be impossible for it to lose a point. Due to this, we must slow it down to "play fair"... as fair as that may be.

The CPU Paddle is allowed to move at a rate specified by a certain Percent of its vertical width. By default, this is set to 2%.
Each update, the CPU Paddle can advance up or down 2% of its vertical width. The directional movement is determined based on the angle of the ball, and it's current position relative to the CPU Paddle's position. Given that it is not a direct follow, it may at times seem more... "human".

When a point is scored, the CPU paddle maintains its position, similar to the original Pong game, the paddles were controlled solely by the raw output of the controllers and did not reset.

> Ball

At the start of each point, the ball begins at the center of the screen and moves in a randomly determined angle at its base speed.

The direction is determined by the player who scored the last point. The loser of the last point "serves" the ball.

Given the circumstances, serving is a gigantic advantage. So the loser serving is just another place where the Market is given an advantage.

The ball's base speed is 1, it will move 1 (horizontal) bar on each update of the script. This speed can "technically" increase to infinity over time, if given the perfect rally. This is due to the hit logic as described below.

Note: The minimum ball speed is also 1.

> Bonk Math

When the ball hits a paddle, essentially 3 outcomes can occur, each resulting in the ball's direction being changed from positive to negative.

[*]Action A: Its angle is doubled, and its speed is doubled.
[*]Action B: Its angle is reversed, and its speed is decreased if it is going faster than base speed. 
[*]Action C: Its angle is preserved, and its speed is preserved. "Basic Bounce"
 Each paddle is segmented into 3 zones, with the higher and lower tips (20%) of the paddles producing special actions. 

The central 60% of each paddle produces a basic bounce. The special actions are determined by the trajectory of the ball and location on the paddle.

> Custom Mode

As stated above, the script loads in "Auto Mode" by default. While this works fine to simply watch the gameplay, the Custom Mode unlocks the ability to visualize countless possibilities of indicators and analyses playing Pong!

In the chart below, we have set up the game to use the NYSE TICK Index as our Market Player. The NYSE TICK Index shows the number of NYSE stocks trading on an uptick minus those on a downtick. Its values fluctuate throughout the day, typically ranging between +1000 and -1000. 
Therefore, we have set up Pong to use Ticker USI:TICK and set the Upper Boundary to 1000 and Lower Boundary to -1000. With this method, the paddle is directly controlled by the overall (NYSE) market behaviors.
[image]https://www.tradingview.com/x/WcmEg1EQ/[/image]

As seen in a chart earlier, you can also take advantage of the Custom Mode to overlay Pong onto traditional oscillators for use anywhere!

> Styles

This version of Pong comes stocked with 5 colorways to suit your chart vibes!

[image]https://www.tradingview.com/x/yt6rBzKS/[/image]

> Pro Tips & Additional Information

- This game has sound! For the full experience, set alerts for this indicator and a notification sound will play on each hit!*
 *Due to server processing, the notification sounds are not precisely played at each hit. :(

- In auto mode, decreasing the length used will give an advantage to the market, as its actions become more sporadic over this window. 

- The CPU logic system actually[/i ]allows the market to have a "technical" edge, since the Market Paddle is not bound to any speed, and is solely controlled by the raw market movements/data input.

- This type of visualization only works on live charts, charts without updates will not see any movement.

- Indicator sources can only be imported from other indicators on the same chart.

- The base screen resolution is 159 bars wide, with the height determined by the boundaries.

- When using a symbol and an outside source, be mindful that the script is attempting to pull the source from the input symbol. Data can appear wonky when not considering the interactions of these inputs.

There are many small interesting details that can't be seen through the description. For example, the mid-line is made from a box. This is because a line object would not appear on top of the box used for the screen. For those keen eye'd coders, feel free to poke around in the source code to make the game truly custom.

Just remember:
The market may never be fair, but now at least it can play Pong!

Enjoy!

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SamRecio

//@version=6
indicator("Pong")

///_____________________________________________________________________________________________________________________
///UDTs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

type paddle
    box bx

type ball
    label lab

type disp
    box bx

enum style
    s1 = "Classic"
    s2 = "CRT Glow"
    s3 = "Amber Terminal"
    s4 = "Oscilloscope"
    s5 = "DOOM"

///_____________________________________________________________________________________________________________________
///Inputs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//Groups
var group1 = "Data Inputs"
var group2 = "Game Settings"
var group3 = "Style"

sym = input.symbol("", title = "Symbol", group = group1)
src = input.source(close, title = "Data Source", group = group1)
ma_typ = input.string("NONE", title = "Smoothing", options = ["NONE","EMA","SMA","VWMA","HMA","LSMA"], group = group1, inline = "MA")
ma_len = input.int(20, title  = "", group = group1, inline = "MA", active = ma_typ != "NONE"?true:false)

custom = input.bool(false, title = "Custom Mode", group = group2)
auto_len = input.int(100, title = "Market Lookback", group = group2, tooltip = "When using Auto Mode, the script determines the source's relative position based on highest and lowest values within a lookback length.\n\nEssentially using Donchian Channels to scale price into an oscillator, where 100 = Highest and 0 = Lowest.", active = custom?false:true)
cpu_multi = input.float(2, title = "CPU Paddle Speed %", minval = 1, maxval = 20, group = group2, tooltip = "The paddle moves in incraments of % width of the paddle. By default (2%), the paddle can move 2% of it's width on every update.\n\nThe direction is determined by the ball's relative Y location to the paddle.")

manual_hst = input.float(100, title = "Upper Boundary", group = group2, active = custom?true:false)
manual_lst = input.float(0, title = "Lower Boundary", group = group2, tooltip = "Boundaries can be positive or negative.", active = custom?true:false)

disp_style = input.enum(style.s1, title = "Style", group = group3)

///_____________________________________________________________________________________________________________________
///Colors
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

var invis = color.rgb(0,0,0,100)

get_colors(style _style) =>
    //Screen Color
    var c1 = switch _style
        style.s1 => #000000 
        style.s3 => #1A0C00
        style.s2 => #001100
        style.s4 => #001B33
        style.s5 => #1A0000

    //Paddle Color
    var c2 = switch _style
        style.s1 => #FFFFFF 
        style.s3 => #FFB000
        style.s2 => #00FF00
        style.s4 => #00FFFF
        style.s5 => #FF0000

    //Ball/Midline Color
    var c3 = switch _style
        style.s1 => #FFFFFF 
        style.s3 => #FFD966
        style.s2 => #ADFF2F
        style.s4 => #33FFDD
        style.s5 => #FF4D00
 
    //Score Color
    var c4 = switch _style
        style.s1 => #FFFFFF 
        style.s3 => #FFF2CC
        style.s2 => #CCFFCC
        style.s4 => #99FFFF
        style.s5 => #FFB000

    [c1, c2, c3, color.new(c4,50)]

[screen_col,paddle_col,ball_col,score_col] = get_colors(disp_style)


///_____________________________________________________________________________________________________________________
///Setup
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

get_src = request.security(sym,"",nz(src))

hh = nz(ta.highest(get_src,auto_len),get_src)
ll = nz(ta.lowest(get_src,auto_len),get_src)

varip auto_market = ((get_src - ll) / (hh-ll)) * 100
auto_market := ((get_src - ll) / (hh-ll)) * 100

varip hst = custom ? manual_hst : 100 
hst := custom ? manual_hst : 100

varip lst = custom  ? manual_lst : 0
lst := custom  ? manual_lst : 0

market_src = custom ? get_src : auto_market

ma = ma_typ == "EMA"?ta.ema(market_src,ma_len):
     ma_typ == "SMA"?ta.sma(market_src,ma_len):
     ma_typ == "VWMA"?ta.vwma(market_src,ma_len):
     ma_typ == "HMA"?ta.hma(market_src,ma_len):
     ma_typ == "LSMA"?ta.linreg(market_src,ma_len,0):market_src

//Screen Setup
offset = 2 //In front of current bar
width = 159 // It helps if this value is odd. >>>Max 500

//Paddle Size is typically 20% of screen height for pong.
//Since our values determine the center of the paddles, the screen needs to extend 1/2 of a paddle past our top and bottom boundaries.
//When our values reach the top or bottom, the paddles do not go off screen.
//By doing this we are increasing the screen height by 1 paddle height. 
//Therefore our paddles need to be equal to 1/4 boundary width(hst-lst) to be equal to 1/5 screen height.

//Paddle Size
varip ps = (hst-lst)/4 
ps := (hst-lst)/4
//Screen Top & Bottom
varip top = hst + ps/2
top := hst + ps/2
varip bot = lst - ps/2
bot := lst - ps/2
//Screen Left & Right
varip left = bar_index + offset
left := bar_index + offset
varip right = bar_index + width + offset
right := bar_index + width + offset
//Screen Middle X & Y
varip x_mid = int(math.avg(left,right))
x_mid := int(math.avg(left,right))
varip y_mid = math.avg(top,bot)
y_mid := math.avg(top,bot)

///_____________________________________________________________________________________________________________________
///Bonk Math
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//There are essentially 3 unique actions that can occur, each resulting in the ball's direction being changed from + to -. 
//The outcome is determined by the ball's direction of movement (+/- Slope), and the ball's location on the paddle (Y-Location).

//Action A: Its angle is doubled, and its speed is doubled.
//Action B: Its angle is reversed, and its speed is decreased if it is going faster than base speed (1). 
//Action C: Its angle is preserved, and its speed is preserved. <- Basic Bounce

//The center 60% of the paddles result in a Basic Bounce, the upper and lower 20% can result in A or B.

//If the ball is going upwards, and hits the top -> A 
//If the ball is going upwards, and hits the bottom -> B 

//If the ball is going downwards, and hits the bottom -> A 
//If the ball is going downwards, and hits the top -> B 

bonk_math(_top,_bot,_ball_pos,_dir,_slope) =>
    upper = _top - ps/5
    lower = _bot + ps/5
    int _dir_out = na
    float _slope_out = na
    if _ball_pos < lower
        if _slope < 0
            _slope_out := _slope * 2                        //A
            _dir_out := _dir * -2
        else
            _slope_out := _slope * -1                       //B
            _dir_out := _dir > 1 ? _dir/2 : _dir * -1
    else if _ball_pos > upper
        if _slope > 0
            _slope_out := _slope * 2                        //A
            _dir_out := _dir * -2
        else
            _slope_out := _slope * -1                       //B
            _dir_out := _dir > 1 ? _dir/2 : _dir * -2
    else
        _slope_out := _slope
        _dir_out := _dir * -1
        
    [_dir_out,_slope_out]

///_____________________________________________________________________________________________________________________
///Variables
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

varip market_pos = ma // Market Paddle Position
market_pos := math.min(hst,math.max(lst,ma))

varip int market_score = 0
varip int cpu_score = 0

varip screen = disp.new(box.new(left-1,top,right+1,bot, bgcolor = screen_col, border_color = screen_col))
varip mid_line = disp.new(box.new(x_mid,top,x_mid,bot, bgcolor = invis, border_color = ball_col, border_style = line.style_dotted))
varip cs_disp = disp.new(box.new(x_mid,top,right+1,top-ps, text = str.tostring(cpu_score), bgcolor = invis, border_color = invis, text_color = score_col))
varip ms_disp = disp.new(box.new(left-1,top,x_mid,top-ps, text = str.tostring(market_score), bgcolor = invis, border_color = invis, text_color = score_col))

varip market_p = paddle.new(box.new(left-1,market_pos+ps/2,left,market_pos-ps/2, bgcolor = paddle_col, border_color = invis))

varip float cpu_pos = y_mid
varip cpu_p =  paddle.new(box.new(right,cpu_pos+ps/2,right+1,cpu_pos-ps/2, bgcolor = paddle_col, border_color = invis))

varip np = true //new point

varip float ball_y = na
varip int ball_x = na
varip float ball_slope = na
varip int ball_dir = 1
varip ball = ball.new(label.new(left+int(width/2),y_mid, style = label.style_square, color = ball_col, size = size.auto))

varip ng_start = false

///_____________________________________________________________________________________________________________________
///NewGame
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

if barstate.islast and ng_start == false
    market_score := 0
    cpu_score := 0
    cpu_pos := y_mid
    ball_dir := 1
    np := true
    ng_start := true

///_____________________________________________________________________________________________________________________
///Ball Logic
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

if np
    ball_x := x_mid
    ball_y := y_mid
    ball_slope := math.round(math.random((hst-lst)/width,-(hst-lst)/width),2)
    np := false
else 
    ball_x += ball_dir
    ball_y += ball_slope
    
///_____________________________________________________________________________________________________________________
///CPU Logic
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

varip cpu_speed = cpu_multi/100 * ps
cpu_speed := cpu_multi/100 * ps

varip look_dir = math.sign(ball_y - cpu_pos)
look_dir := math.sign(ball_y - cpu_pos)

cpu_pos += switch
    look_dir < 0 and ball_slope > 0  and ball_dir < 0 => 0
    look_dir > 0 and ball_slope < 0 and ball_dir < 0 => 0
    => look_dir * cpu_speed

cpu_pos := math.min(hst,math.max(lst,cpu_pos))


///_____________________________________________________________________________________________________________________
///Scoring & Paddle Hits
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

varip m_bot = market_pos - (ps/2)
m_bot := market_pos - (ps/2)
varip m_top = market_pos + (ps/2)
m_top := market_pos + (ps/2)

varip c_bot = cpu_pos - (ps/2)
c_bot := cpu_pos - (ps/2)
varip c_top = cpu_pos + (ps/2)
c_top := cpu_pos + (ps/2)


if ball_dir < 0 and ball_x <= left
    if (ball_y <= m_top and ball_y >= m_bot)
        [new_dir,new_slope] = bonk_math(m_top,m_bot,ball_y,ball_dir,ball_slope)
        ball_dir := new_dir
        ball_slope := new_slope
        log.info("Bonk")
        alert("Bonk", alert.freq_all)
    else
        cpu_score += 1
        ball_dir := 1
        np := true
        log.info("CPU Scored!")
        alert("CPU Scored!", alert.freq_all)
    
if ball_dir > 0 and ball_x >= right
    if (ball_y <= c_top and ball_y >= c_bot)
        [new_dir,new_slope] = bonk_math(c_top,c_bot,ball_y,ball_dir,ball_slope)
        ball_dir := new_dir
        ball_slope := new_slope
        log.info("Bonk")
        alert("Bonk", alert.freq_all)
    else
        market_score += 1
        ball_dir := -1
        np := true
        log.info("Market Scored!")
        alert("Market Scored!", alert.freq_all)

if ball_y <= bot or ball_y >= top
    ball_slope *= -1

///_____________________________________________________________________________________________________________________
///Display Visuals
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

if barstate.islast
    
    //Market Paddle
    market_p.bx.set_lefttop(left-1,market_pos+ps/2)
    market_p.bx.set_rightbottom(left,market_pos-ps/2)

    //CPU Paddle
    cpu_p.bx.set_lefttop(right,cpu_pos+ps/2)
    cpu_p.bx.set_rightbottom(right+1,cpu_pos-ps/2)
    
    //Screen
    screen.bx.set_lefttop(left-1,top)
    screen.bx.set_rightbottom(right+1,bot)

    mid_line.bx.set_lefttop(x_mid,top)
    mid_line.bx.set_rightbottom(x_mid,bot)

    //Update Scoreboard
    ms_disp.bx.set_lefttop(left-1,top)
    ms_disp.bx.set_rightbottom(x_mid,top-ps)
    ms_disp.bx.set_text(str.tostring(market_score))

    cs_disp.bx.set_lefttop(x_mid,top)
    cs_disp.bx.set_rightbottom(right+1,top-ps)
    cs_disp.bx.set_text(str.tostring(cpu_score))
    
    //Move Ball
    ball.lab.set_xy(ball_x,ball_y)

///_____________________________________________________________________________________________________________________
///Plotting
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

plot(ma, title = "MA", color = paddle_col)
plot(market_src, title = "Data Feed", color = score_col)
 
plotchar(hst, title = "Upper", char = "-", location = location.absolute, color = score_col, display = display.all - display.status_line)
plotchar(y_mid, title = "Mid-Line", char = "=", location = location.absolute, color = score_col, display = display.all - display.status_line)
plotchar(lst, title = "Lower", char = "-", location = location.absolute, color = score_col, display = display.all - display.status_line)

//Force Margin
//Creates a plot in front of the game screen to force a margin for chart auto-scrolling.
//To edit this margin manually for your chart go to Settings > Canvas > Margins > Right
plot(y_mid, offset = width+50, color = invis, show_last = 1, editable = false, display = display.pane)

///_____________________________________________________________________________________________________________________
///Pinging
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//Pulling and plotting crypto to force update the indicator.
btc = request.security("COINBASE:BTCUSD","",nz(volume))
plot(btc, display = display.none, editable = false)
eth = request.security("COINBASE:ETHUSD","",nz(volume))
plot(eth, display = display.none, editable = false)
ping = request.security_lower_tf("","1S",nz(volume))
plot(ping.size(), display = display.none, editable = false)
````

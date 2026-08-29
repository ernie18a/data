<!-- tradingview-pine-id: PUB;E0DC1xBgkjFHQzfVPypF6whkaf7Mx3Hh -->
<!-- tradingviewscripts-format: 1 -->
# Correlation Cycle, CorrelationAngle, Market State - John Ehlers

Source: https://www.tradingview.com/script/wyyXKHDn-Correlation-Cycle-CorrelationAngle-Market-State-John-Ehlers/

## Description

Hot off the press, I present this "Correlation Cycle, CorrelationAngle, and Market State" multicator employing PSv4.0, originally formulated by Dr. John Ehlers for TASC - June 2020 Traders Tips. Basically it's an all-in-one combination of three Ehlers' indicators. This power packed triplet indicator, being less than a 100 line implementation at initial release, is a heavily modified version of the original indicator using novel techniques that surpass John Ehlers' original intended design.

This is also a profound script in numerous ways. First of all, these three indicators are directly from the illustrious mastermind himself Dr. John Ehlers. Secondarily, this is my "50th" script published on TV, which makes it even more significant. I'm especially proud of this script to "degrees" of imagination I once didn't know was theoretically possible in code. My intellect has once again been mathemagically unlocked pondering new innovations with this code revelation. Thirdly, this PSv4.0 script shows the empowering beauty and elegance of hacking the stock markets with TV's ultra utilitarian Pine Editor(PE) in a common browser! Some of you may be wondering if I worked on this for days... nope! This only took a few hours, followed by writing this description for another hour plus.

I have created many of Ehlers' indicators in PE, a few of which I have published in my profile, but I wanted to show how programming with Pine Script can be an artistic form of craftsmanship and poetry. None of this would be possible without the ingeniously minded Tradingview staff revolutionizing algorithmic trading at it's finest. If you should ever encounter them by chance, ponder humbly thanking these computing wizards for their diligence and dedication. They are providing, and shall award to us members, some of the most fascinating conceptualized tech imaginable in the coming future. I can assure you, much, much more is yet to be unveiled for us TV members/enthusiasts. Thank you TV and all you offer to this community.

As always, I have included advanced Pine programming techniques that conform to proper "Pine Etiquette" by example. There are so many Pine mastery techniques included, I don't have an abundance of time to elaborate on all of them. For those of you are code savvy, you may have notice I only used one "for" loop for increased server efficiency, instead of the two "for" loops in the original formulation. For those of you who are newcomers to Pine Script, this code release may also help you comprehend the immense "Power of Pine" by employing advanced programming techniques while exhibiting code utilization in a most effective manner. This is commonly what my dense intricate code looks like behind the veil. If you are wondering why there is hardly any notes, that's because the notation is primarily in the variable naming.

Features List Includes:
Dark Background - Easily disabled in indicator Settings->Style for "Light" charts or with Pine commenting
AND a few more... Why list them, when you have the source code!

The comments section below is solely just for commenting and other remarks, ideas, compliments, etc... regarding only this indicator, not others. When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members, I may implement more ideas when they present themselves as worthy additions. As always, "Like" it if you simply just like it with a proper thumbs up, and also return to my scripts list occasionally for additional postings. Have a profitable future everyone!

---

## Source Code

````pine
//@version=4
study("Correlation Cycle, CorrelationAngle, Market State - John Ehlers", "CC/CA/MS", false, format.price, 2)

bgcolor(color.new(#000000,15), title="Dark Background")

rad2deg(Rad) => // Radians To Degrees
	var   DEGREES_IN_1_RADIAN = 90.0 / asin(1.0) // 57.29577951308 Constant
	Rad * DEGREES_IN_1_RADIAN

cc(Series, Period) => // Correlation Cycle Function
    var PIx2 = 4.0 * asin(1.0) // 6.28318530718 Constant
    period = max(2, Period)
    Rx=0.0, Rxx=0.0, Rxy=0.0, Ryy=0.0, Ry=0.0
    Ix=0.0, Ixx=0.0, Ixy=0.0, Iyy=0.0, Iy=0.0
    for i=1 to period
        iMinusOne = i-1
    	X    = nz(Series[iMinusOne])
    	temp =    PIx2 * iMinusOne / period
    	Yc   =  cos(temp)
    	Ys   = -sin(temp)
    	Rx  := Rx  + X      ,  Ix  := Ix  + X
    	Rxx := Rxx + X  * X ,  Ixx := Ixx + X  * X
    	Rxy := Rxy + X  * Yc,  Ixy := Ixy + X  * Ys
    	Ryy := Ryy + Yc * Yc,  Iyy := Iyy + Ys * Ys
    	Ry  := Ry  + Yc     ,  Iy  := Iy  + Ys
    realPart      =  0.0
    temp_1        =  period * Rxx - Rx * Rx
    temp_2        =  period * Ryy - Ry * Ry
    if(temp_1>0.0 and temp_2>0.0)
    	realPart := (period * Rxy - Rx * Ry) / sqrt(temp_1 * temp_2)
    imagPart      =  0.0
    temp_1       :=  period * Ixx - Ix * Ix
    temp_2       :=  period * Iyy - Iy * Iy
    if(temp_1>0.0 and temp_2>0.0)
    	imagPart := (period * Ixy - Ix * Iy) / sqrt(temp_1 * temp_2)
    [realPart, imagPart]

cap(RealPart, ImaginaryPart) => // Correlation Angle Phasor Function
    var HALF_OF_PI = asin(1.0) // 1.57079632679 Constant
    angle = ImaginaryPart==0.0 ? 0.0 : rad2deg(atan(RealPart / ImaginaryPart) + HALF_OF_PI)
    if(ImaginaryPart > 0.0)
    	angle := angle - 180.0
    priorAngle = nz(angle[1])
    if(priorAngle>angle and priorAngle-angle<270.0)
    	angle := priorAngle
    angle

mstate(Angle, Degrees) => // Market State Function
    var thresholdInDegrees = Degrees
    state = 0
	temp = abs(Angle - Angle[1]) < thresholdInDegrees
    if(Angle>=0.0 and temp)
    	state :=  1
    if(Angle< 0.0 and temp)
    	state := -1
    state

indicator     = input("Correlation Cycle",   "==== Select Indicator ====", input.string , options=["Correlation Cycle","Correlation Angle","Market State"])
source        = input(              close,                     "  Source", input.source )
period        = input(                 20,                     "  Period", input.integer, minval=2)
thresholdMS   = input(                  9,   "Market State Threshold (°)", input.integer, minval=1)
lineThickness = input(                  2, "------ Line Thickness ------", input.integer, options=[1,2,3])
var SHOW_CORRELATION_CYCLE = indicator == "Correlation Cycle"
var SHOW_CORRELATION_ANGLE = indicator == "Correlation Angle"
var SHOW_MARKET_STATE      = indicator == "Market State"

// Correlation Cycle ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟
[real, imaginary] = cc(source, period)

plot(SHOW_CORRELATION_CYCLE ?       1.0 : na, color=#FF0000ff, show_last=1, trackprice=true, editable=false)
plot(SHOW_CORRELATION_CYCLE ?      -1.0 : na, color=#0040FFff, show_last=1, trackprice=true, editable=false)
plot(SHOW_CORRELATION_CYCLE ?      real : na, color=#80FF00ff, linewidth=lineThickness, title=     "Real Part")
plot(SHOW_CORRELATION_CYCLE ? imaginary : na, color=#FF00FFff, linewidth=lineThickness, title="Imaginary Part")

// CorrelationAngle/Phasor ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟
angle = cap(real, imaginary)

plot(SHOW_CORRELATION_ANGLE ?   180 : na, color=#FF0000ff, show_last=1, trackprice=true, editable=false)
plot(SHOW_CORRELATION_ANGLE ?    90 : na, color=#FFFFFF80, show_last=1, trackprice=true, editable=false)
plot(SHOW_CORRELATION_ANGLE ?   -90 : na, color=#FFFFFF80, show_last=1, trackprice=true, editable=false)
plot(SHOW_CORRELATION_ANGLE ?  -180 : na, color=#00FF00ff, show_last=1, trackprice=true, editable=false)
plot(SHOW_CORRELATION_ANGLE ? angle : na, color=#FF0000ff, linewidth=lineThickness+2   , editable=false)
plot(SHOW_CORRELATION_ANGLE ? angle : na, color=#FFFF00ff, linewidth=lineThickness, title="Correlation Angle")

// Market State ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟ ⮟
state = mstate(angle, thresholdMS)

colorMS = state>0.0 ? #FF0080AA : #0040FFAA
plot(SHOW_MARKET_STATE ? state : na, color=colorMS  ,  editable=false, style=plot.style_area)
plot(SHOW_MARKET_STATE ? state : na, color=#C0C0C0ff, linewidth=lineThickness, title="State")

plot( 0.0, color=#FFFF0022, editable=false, linewidth=7, title="Zero")
hline(0.0, color=#FFFFFFff, editable=false)
````

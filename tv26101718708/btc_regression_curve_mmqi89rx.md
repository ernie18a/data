# BTC Regression Curve

- url: https://www.tradingview.com/script/MMQi89Rx-BTC-Regression-Curve/
- type: indicator
- pine_id: PUB;96e663674b8d4fdd9767fa0d44eb9688
- version: 1.0

## Description

This is a BTC log Regression Curve based on Trolololo's log regression curve that he posted on https://bitcointalk.org/index.php?topic=831547.0 back in 2014, this one has been slightly updated and I've include deviation percentage lines from his original curve.

This can also be used to set DCA Alerts and has hash values for long or short so that standard notifications can be evaluated on Samsung phones with Routines or Apple phones with their automation system.

## Source Code

````pine
// This Pine Script™ code was created and owned by @ILikuhTheTrade.
// © ILikuhTheTrade

//@version=6
indicator("BTC Regression Curve", overlay=true, behind_chart = true)

//REMOVE ALERT HASH WHEN UPDATING CODE TO PUBLISHED SCRIPT

var string normalizedTicker = syminfo.ticker

var bool isBTC = false

if normalizedTicker == "BTCUSD"
    isBTC := true

if normalizedTicker != "BTCUSD"
    isBTC := false


// Define start and end dates
startYear = 2009
startMonth = 1
startDay = 9
endYear = 2059
endMonth = 1
endDay = 9

// Convert start date to timestamp
startDate = timestamp(startYear, startMonth, startDay, 0, 0)
endDate = timestamp(endYear, endMonth, endDay, 0, 0)

// Calculate days since start date
daysSinceStart = (time - startDate) / (24 * 60 * 60 * 1000)

// Apply logarithmic curve formula: 10^(2.66167155005961 * ln(x) - 17.9183761889864)
logCurveValue = daysSinceStart > 0 ? math.pow(10, 2.66167155005961 * math.log(daysSinceStart) - 17.9183761889864) : na

// Plot the main logarithmic curve
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue : na, color=color.green,
 linewidth=2, title="Logarithmic Curve")

// Deviation multipliers for 25 above and 15 below
deviation1 = 1.05  // 5% above
deviation2 = 1.10  // 10% above
deviation3 = 1.15  // 15% above
deviation4 = 1.20  // 20% above
deviation5 = 1.25  // 25% above
deviation6 = 1.30  // 30% above
deviation7 = 1.35  // 35% above
deviation8 = 1.40  // 40% above
deviation9 = 1.45  // 45% above
deviation10 = 1.50  // 50% above
deviation11 = 1.55  // 55% above
deviation12 = 1.60  // 60% above
deviation13 = 1.65  // 65% above
deviation14 = 1.70  // 70% above
deviation15 = 1.75  // 75% above
deviation16 = 1.80  // 80% above
deviation17 = 1.85  // 85% above
deviation18 = 1.90  // 90% above
deviation19 = 1.95  // 95% above
deviation20 = 2.00  // 100% above
deviation21 = 2.05  // 105% above
deviation22 = 2.10  // 110% above
deviation23 = 2.15  // 115% above
deviation24 = 2.20  // 120% above
deviation25 = 2.25  // 125% above
deviation26 = 0.95  // 5% below
deviation27 = 0.90  // 10% below
deviation28 = 0.85  // 15% below
deviation29 = 0.80  // 20% below
deviation30 = 0.75  // 25% below
deviation31 = 0.70  // 30% below
deviation32 = 0.65  // 35% below
deviation33 = 0.60  // 40% below
deviation34 = 0.55  // 45% below
deviation35 = 0.50  // 50% below
deviation36 = 0.45  // 55% below
deviation37 = 0.40  // 60% below
deviation38 = 0.35  // 65% below
deviation39 = 0.30  // 70% below
deviation40 = 0.25  // 75% below

// Plot bands above with inverted color incrementation
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation25 : na, color=#FF0000,
 linewidth=1, title="Band +125%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation24 : na, color=#FF0D00,
 linewidth=1, title="Band +120%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation23 : na, color=#FF1B00,
 linewidth=1, title="Band +115%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation22 : na, color=#FF2900,
 linewidth=1, title="Band +110%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation21 : na, color=#FF3700,
 linewidth=1, title="Band +105%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation20 : na, color=#FF4400,
 linewidth=1, title="Band +100%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation19 : na, color=#FF5200,
 linewidth=1, title="Band +95%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation18 : na, color=#FF6000,
 linewidth=1, title="Band +90%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation17 : na, color=#FF6E00,
 linewidth=1, title="Band +85%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation16 : na, color=#FF7B00,
 linewidth=1, title="Band +80%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation15 : na, color=#FF8900,
 linewidth=1, title="Band +75%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation14 : na, color=#FF9700,
 linewidth=1, title="Band +70%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation13 : na, color=#FFA500,
 linewidth=1, title="Band +65%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation12 : na, color=#FFB200,
 linewidth=1, title="Band +60%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation11 : na, color=#FFB700,
 linewidth=1, title="Band +55%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation10 : na, color=#FFBB00,
 linewidth=1, title="Band +50%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation9 : na, color=#FFC300,
 linewidth=1, title="Band +45%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation8 : na, color=#FFCE00,
 linewidth=1, title="Band +40%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation7 : na, color=#FFD500,
 linewidth=1, title="Band +35%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation6 : na, color=#FFDB00,
 linewidth=1, title="Band +30%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation5 : na, color=#FFDD00,
 linewidth=1, title="Band +25%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation4 : na, color=#FFDF00,
 linewidth=1, title="Band +20%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation3 : na, color=#FFE100,
 linewidth=1, title="Band +15%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation2 : na, color=#FFE400,
 linewidth=1, title="Band +10%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation1 : na, color=#FFE700,
 linewidth=1, title="Band +5%")

// Plot bands below
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation26 : na, color=#00780F,
 linewidth=1, title="Band -5%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation27 : na, color=#00701F,
 linewidth=1, title="Band -10%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation28 : na, color=#00682F,
 linewidth=1, title="Band -15%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation29 : na, color=#00603F,
 linewidth=1, title="Band -20%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation30 : na, color=#00584F,
 linewidth=1, title="Band -25%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation31 : na, color=#00505F,
 linewidth=1, title="Band -30%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation32 : na, color=#00486F,
 linewidth=1, title="Band -35%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation33 : na, color=#00407F,
 linewidth=1, title="Band -40%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation34 : na, color=#00388F,
 linewidth=1, title="Band -45%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation35 : na, color=#00309F,
 linewidth=1, title="Band -50%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation36 : na, color=#0028AF,
 linewidth=1, title="Band -55%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation37 : na, color=#0020BF,
 linewidth=1, title="Band -60%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation38 : na, color=#0018CF,
 linewidth=1, title="Band -65%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation39 : na, color=#0010DF,
 linewidth=1, title="Band -70%")
plot(isBTC and time >= startDate and time <= endDate ? logCurveValue * deviation40 : na, color=#0008EF,
 linewidth=1, title="Band -75%")

//_______________________________________________Labels for Lines_______________________________________________________

labelCondition = (isBTC and time >= startDate and time <= endDate)

var label logRegressionLabel = na
var label overTwentyFiveLabel = na
var label overFiftyLabel = na
var label overSeventyFiveLabel = na
var label overOneHundredLabel = na
var label overOneTwentyFiveLabel = na
var label underTwentyFiveLabel = na
var label underFiftyLabel = na
var label underSeventyFiveLabel = na

if labelCondition
    if (na(logRegressionLabel))
        logRegressionLabel := label.new(x=bar_index, y=logCurveValue, text="''Fair Value''",
         style=label.style_label_down, color=color(na), textcolor=color.green, size=size.small, yloc=yloc.price)
    else
        label.set_xy(logRegressionLabel, bar_index, logCurveValue)

if labelCondition
    if (na(overTwentyFiveLabel))
        overTwentyFiveLabel := label.new(x=bar_index, y=logCurveValue * deviation5, text="+25%",
         style=label.style_label_down, color=color(na), textcolor=#FFDD00, size=size.small, yloc=yloc.price)
    else
        label.set_xy(overTwentyFiveLabel, bar_index, logCurveValue * deviation5)

if labelCondition
    if (na(overFiftyLabel))
        overFiftyLabel := label.new(x=bar_index, y=logCurveValue * deviation10, text="+50%",
         style=label.style_label_down, color=color(na), textcolor=#FFBB00, size=size.small, yloc=yloc.price)
    else
        label.set_xy(overFiftyLabel, bar_index, logCurveValue * deviation10)

if labelCondition
    if (na(overSeventyFiveLabel))
        overSeventyFiveLabel := label.new(x=bar_index, y=logCurveValue * deviation15, text="+75%",
         style=label.style_label_down, color=color(na), textcolor=#FF8900, size=size.small, yloc=yloc.price)
    else
        label.set_xy(overSeventyFiveLabel, bar_index, logCurveValue * deviation15)

if labelCondition
    if (na(overOneHundredLabel))
        overOneHundredLabel := label.new(x=bar_index, y=logCurveValue * deviation20, text="+100%",
         style=label.style_label_down, color=color(na), textcolor=#FF4400, size=size.small, yloc=yloc.price)
    else
        label.set_xy(overOneHundredLabel, bar_index, logCurveValue * deviation20)

if labelCondition
    if (na(overOneTwentyFiveLabel))
        overOneTwentyFiveLabel := label.new(x=bar_index, y=logCurveValue * deviation25, text="+125%",
         style=label.style_label_down, color=color(na), textcolor=#FF0000, size=size.small, yloc=yloc.price)
    else
        label.set_xy(overOneTwentyFiveLabel, bar_index, logCurveValue * deviation25)

if labelCondition
    if (na(underTwentyFiveLabel))
        underTwentyFiveLabel := label.new(x=bar_index, y=logCurveValue * deviation30, text="-25%",
         style=label.style_label_down, color=color(na), textcolor=#00584F, size=size.small, yloc=yloc.price)
    else
        label.set_xy(underTwentyFiveLabel, bar_index, logCurveValue * deviation30)

if labelCondition
    if (na(underFiftyLabel))
        underFiftyLabel := label.new(x=bar_index, y=logCurveValue * deviation35, text="-50%",
         style=label.style_label_down, color=color(na), textcolor=#00309F, size=size.small, yloc=yloc.price)
    else
        label.set_xy(underFiftyLabel, bar_index, logCurveValue * deviation35)

if labelCondition
    if (na(underSeventyFiveLabel))
        underSeventyFiveLabel := label.new(x=bar_index, y=logCurveValue * deviation40, text="-75%",
         style=label.style_label_down, color=color(na), textcolor=#0008EF, size=size.small, yloc=yloc.price)
    else
        label.set_xy(underSeventyFiveLabel, bar_index, logCurveValue * deviation40)

//___________________________________________Alert Timer________________________________________________________________
//this should be active when the price is above or below the threshold level

userInputOver = input.string(defval = "Over 35% Deviation", title = "Deviation Over Regression Alert",
 options = ["Over 125% Deviation", "Over 120% Deviation", "Over 115% Deviation", "Over 110% Deviation",
  "Over 105% Deviation", "Over 100% Deviation", "Over 95% Deviation", "Over 90% Deviation", "Over 85% Deviation",
   "Over 80% Deviation", "Over 75% Deviation", "Over 70% Deviation", "Over 65% Deviation", "Over 60% Deviation",
     "Over 55% Deviation", "Over 50% Deviation", "Over 45% Deviation", "Over 40% Deviation", "Over 35% Deviation",
      "Over 30% Deviation", "Over 25% Deviation", "Over 20% Deviation", "Over 15% Deviation", "Over 10% Deviation",
       "Over 5% Deviation"], confirm = true)

// Map the user input to the non-user-friendly variable names
var float selectedOverVar = na

if (userInputOver == "Over 5% Deviation")
    selectedOverVar := deviation25
else if (userInputOver == "Over 10% Deviation")
    selectedOverVar := deviation24
else if (userInputOver == "Over 15% Deviation")
    selectedOverVar := deviation23
else if (userInputOver == "Over 20% Deviation")
    selectedOverVar := deviation22
else if (userInputOver == "Over 25% Deviation")
    selectedOverVar := deviation21
else if (userInputOver == "Over 30% Deviation")
    selectedOverVar := deviation20
else if (userInputOver == "Over 35% Deviation")
    selectedOverVar := deviation19
else if (userInputOver == "Over 40% Deviation")
    selectedOverVar := deviation18
else if (userInputOver == "Over 45% Deviation")
    selectedOverVar := deviation17
else if (userInputOver == "Over 50% Deviation")
    selectedOverVar := deviation16
else if (userInputOver == "Over 55% Deviation")
    selectedOverVar := deviation15
else if (userInputOver == "Over 60% Deviation")
    selectedOverVar := deviation14
else if (userInputOver == "Over 65% Deviation")
    selectedOverVar := deviation13
else if (userInputOver == "Over 70% Deviation")
    selectedOverVar := deviation12
else if (userInputOver == "Over 75% Deviation")
    selectedOverVar := deviation11
else if (userInputOver == "Over 80% Deviation")
    selectedOverVar := deviation10
else if (userInputOver == "Over 85% Deviation")
    selectedOverVar := deviation9
else if (userInputOver == "Over 90% Deviation")
    selectedOverVar := deviation8
else if (userInputOver == "Over 95% Deviation")
    selectedOverVar := deviation7
else if (userInputOver == "Over 100% Deviation")
    selectedOverVar := deviation6
else if (userInputOver == "Over 105% Deviation")
    selectedOverVar := deviation5
else if (userInputOver == "Over 110% Deviation")
    selectedOverVar := deviation4
else if (userInputOver == "Over 115% Deviation")
    selectedOverVar := deviation3
else if (userInputOver == "Over 120% Deviation")
    selectedOverVar := deviation2
else if (userInputOver == "Over 125% Deviation")
    selectedOverVar := deviation1


userInputUnder = input.string(defval = "Under 50% Deviation", title = "Deviation Under Regression Alert",
 options=["Under 5% Deviation", "Under 10% Deviation", "Under 15% Deviation", "Under 20% Deviation",
  "Under 25% Deviation", "Under 30% Deviation", "Under 35% Deviation", "Under 40% Deviation", "Under 45% Deviation",
   "Under 50% Deviation", "Under 55% Deviation", "Under 60% Deviation", "Under 65% Deviation", "Under 70% Deviation",
     "Under 75% Deviation"], confirm = true)


var float selectedUnderVar = na

if (userInputUnder == "Under 5% Deviation")
    selectedUnderVar := deviation26
else if (userInputUnder == "Under 10% Deviation")
    selectedUnderVar := deviation27
else if (userInputUnder == "Under 15% Deviation")
    selectedUnderVar := deviation28
else if (userInputUnder == "Under 20% Deviation")
    selectedUnderVar := deviation29
else if (userInputUnder == "Under 25% Deviation")
    selectedUnderVar := deviation30
else if (userInputUnder == "Under 30% Deviation")
    selectedUnderVar := deviation31
else if (userInputUnder == "Under 35% Deviation")
    selectedUnderVar := deviation32
else if (userInputUnder == "Under 40% Deviation")
    selectedUnderVar := deviation33
else if (userInputUnder == "Under 45% Deviation")
    selectedUnderVar := deviation34
else if (userInputUnder == "Under 50% Deviation")
    selectedUnderVar := deviation35
else if (userInputUnder == "Under 55% Deviation")
    selectedUnderVar := deviation36
else if (userInputUnder == "Under 60% Deviation")
    selectedUnderVar := deviation37
else if (userInputUnder == "Under 65% Deviation")
    selectedUnderVar := deviation38
else if (userInputUnder == "Under 70% Deviation")
    selectedUnderVar := deviation39
else if (userInputUnder == "Under 75% Deviation")
    selectedUnderVar := deviation40





//____________________________________Alert Initialization_______________________________________________________

dcaTimer = input.int(defval = 30, title = "DCA Alert Period (in Current Time Interval Bars)", step = 1, confirm = true)

overDeviation = logCurveValue * selectedOverVar
underDeviation = logCurveValue * selectedUnderVar

sellZone = close > overDeviation
buyZone = close < underDeviation



sendAlert() =>
    if buyZone
        alert("Hash: faaf256e7a9e62e07dad281005049edc: DCA Bitcoin, Log Regression Level {{userInputUnder}}. {{ticker}} currently sitting at {{close}} with Regression Deviation at {{selectedUnderVar}}.")
    if sellZone
        alert("Hash: ccc54db9a82fb54cc26a40e0f5af3575: Sell/DCA Bitcoin, Log Regression Level {{userInputOver}}. {{ticker}} currently sitting at {{close}} with Regression Deviation at {{selectedOverVar}}.")

var int lastAlert = 0
var bool lastAlertGreaterThanZero = false


//  
if sellZone or buyZone
    lastAlert := dcaTimer  // 

lastAlert -= 1 // 

if lastAlert < 0
    lastAlert := 0

if lastAlert > 0
    lastAlertGreaterThanZero := true
else
    lastAlertGreaterThanZero := false

// 
if (sellZone or buyZone) and not lastAlertGreaterThanZero

    // 
    lastAlert :=  dcaTimer



//___________________________________________________________Alert open and on timer____________________________________
 


alertActive = lastAlertGreaterThanZero


var int lastAlertActivation = 0
var bool lastAlertActivationGreaterThanZero = false

alertActivationSignal() =>
    ta.crossover(lastAlert, 1)

 
if alertActivationSignal() and (lastAlert > 0)
    lastAlertActivation := dcaTimer  // 

lastAlertActivation -= 1 // 

if lastAlertActivation < 0 or lastAlert == 0
    lastAlertActivation := 0

if lastAlertActivation > 0
    lastAlertActivationGreaterThanZero := true
else
    lastAlertActivationGreaterThanZero := false

if (lastAlert > 0) and not lastAlertActivationGreaterThanZero
    lastAlertActivation := dcaTimer

//_____________________________________________________Send alert_______________________________________________________


var int activeDayCounter = 0
var bool activeDayCounterGreaterThanZero = false

lastAlertDeactivated = ta.crossunder(lastAlert, 1)

if lastAlertDeactivated and (activeDayCounter < 1)
    activeDayCounter := dcaTimer


activeDayCounter -= 1 //

if activeDayCounter < 0
    activeDayCounter := 0

//______________________________________________________________________________________________________________________

if activeDayCounter > 0
    lastAlert := 0
    lastAlertActivation := 0




//_________________________________________________________Send Alert___________________________________________________

alertSignal() =>
    ta.crossover(lastAlertActivation, 5)
        

if alertSignal()
    sendAlert()



// Hashes are MD2 hashes created with this phrase (for use with things like Samsung routines to identify tradingview
// notifications and launch other actions):
//   Bitcoin Regression Sell Alert = ccc54db9a82fb54cc26a40e0f5af3575
//   Bitcoin Regression Buy Alert = faaf256e7a9e62e07dad281005049edc

//plot(lastAlert, "Last Alert", color.white, 1,plot.style_linebr)

plot(lastAlertActivation, "Last Alert Activation", color.green, 1,plot.style_linebr)

//plot(activeDayCounter, "Active Day Counter", color.purple, 1,plot.style_linebr)
````

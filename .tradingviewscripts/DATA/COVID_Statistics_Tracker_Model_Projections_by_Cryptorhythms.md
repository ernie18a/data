<!-- tradingview-pine-id: PUB;ffIdOzfacWBGpNWWyC7HvWIwUGLOfqDm -->
<!-- tradingviewscripts-format: 1 -->
# 😷COVID Statistics Tracker & Model Projections by Cryptorhythms🤢

Source: https://www.tradingview.com/script/P2f0pQTD-COVID-Statistics-Tracker-Model-Projections-by-Cryptorhythms/

## Description

😷COVID-19 Coronavirus Tracker & Statistics Tools by Cryptorhythms😷

📜Intro
I wanted to put some more meaning behind the numbers for 2020's Covid pandemic.  I hope this tool can help people analyze and deal with these hard times.  With these metrics I hope to give greater depth and dimension to whats available.  While also at the same time creating something that looks decently presentable and gives actionable information.

I had planned on including a few forecasting models and letting the user play with values to see how social distancing works.  But alas I couldnt complete those in the scope of time I gave myself for the indicator.  If you are interested in collaborating on it, I will share what I have with you and we can further work on it.

📋Description
The script contains 3 main parts you will interact with.  I suggest you enable the chart labels for "indicator name" and "indicator last value" to make the charts more readable  (right click on the scale of your chart and goto the "labels" pop out menu).  Depending on what plots and data you choose to chart, logarithmic and regular scales can both be applied in different situations.  To get similar visuals to the examples I will show below, you can goto the indicator options > style tab.  I then play with the line styles, colors and transparencies to achieve the nice looking charts.  Please also note there is a distinction between "Infected" and "Infectious".  A model telling you the number of infected doesnt designate whether that person can still pass the virus on to others (infectious).  So Infectious numbers are usually lower than total confirmed, but this isnt always the case if for example a country wasnt testing very much during the early phase or something else.

🚧Disclaimer
I am not a medical professional and none of this should be considered medical advice.  All of the models, numbers and math I sourced from professional places but this is not a guarantee of the future only an approximation based on current information.  Numbers change daily and so can these models!

🌐PART ONE
In this area you select a region to read the proper statistics data from tradingview.  You can do global totals, country totals, or for a few places (AU, CA, CN, US) you can see state/province totals.  Remember to SELECT ONLY ONE region.

🧮PART TWO
The Plots/Stats/Data section includes:
1. ) Plot the Days to Double Number of Confirmed
2. ) Plot the Infection Growth Ratio
3. ) Plot Fatality Risk Rate (Total Deaths / Total Outcomes)
4. ) Plot Overall Fatality Rate / Recovery Rate
5. ) Plot % of World Infected & % of USA Infected 
6. ) Plot Daily New Deaths, Confirmed & Recovered
7. ) Plot Daily Change Percentages

🎱PART THREE
Forecasting Models and Settings:
1 .) Plot the % of Custom Population Infected (Vs. the Region Selected in Part 1 of Settings)
2 .) Plot the True Num. of Infectious (Death Model / DM)
3 .) Plot the Current and Next Weeks Cumulative Infection Projection (DM)
4 .) Plot Estimated Infection Rates? (DM)
5 .) Enable Basic Trajectory Projection?
6 .) Plot the Likelihood of > 0 **Infectious** in a Group (DM) for Today, Tomorrow and Next Week
7 .) Plot the True Num. of Infected (Confirmed/Tested Model)
8 .) Plot the Estimated Epidemiology for 7 and 14 Days Out (Hospital Beds, ICU Beds, Ventilator Units) 

Planned But not completed
9.) SIR Epidemiology Model
10.) Exponential Growth Plot & Correlation

To use the Estimator for likelihood of Infected in N group of people you need to do 2 things.  Select and use "Custom Population" as the population source for part 3.  Then you need to enable "Custom Infected" as the source for the model.  Then you enter your geographical area's population and confirmed cases.  Its best to goto the smallest / most granular level of data available to accurately estimate the likelihood.  So for instance in the order of least effective to most effective data source: global, country, state, county, city...etc.

If you do not understand what these terms or numbers represent, please read the source materials I have linked in the code, or use google.  I dont have the time or expertise to explain all the various specific methods and terms included here.  This entire project was a learning journey for me and I have zero experience in epidemiology so please excuse any errors I may have made.  (and tell me, so I can change it!)

🔮Future Additions
If anyone has a model or stat they would like included I will be happy to add your code to this toolbox to make it more effective and give you credit here in the description.  If you want to collaborate please message me.

📊Some Example Charts:
[image]https://www.tradingview.com/x/agTxNmaY/[/image]

[image]https://www.tradingview.com/x/twNJoox6/[/image]

[image]https://www.tradingview.com/x/t6410hza/[/image]

[image]https://www.tradingview.com/x/yNKIHumh/[/image]

[image]https://www.tradingview.com/x/Cjqgu5ph/[/image]

[image]https://www.tradingview.com/x/GU0DNowF/[/image]

[image]https://www.tradingview.com/x/JLzo902z/[/image]

[image]https://www.tradingview.com/x/sHT3XS7j/[/image]

[image]https://www.tradingview.com/x/RqP0MJ4v/[/image]

The Cryptorhythms Team wish you and your families all the absolute best of health! 

P.S. Stay safe and act smart I dont think this will be the EOTW.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © theheirophant
//thanks to all the first responders, health care professionals, "essential" workers, and quarantined people around the world.  we can beat covid together with smart policy and data science. 
//please do not take anything within this toolbox as medical advice, because it is NOT medical advice.  its here to use some formulas and make some estimations only.

//@version=4
study("😷COVID Statistics Tracker & Model Projections by Cryptorhythms🤢", shorttitle = "😷𝗖𝗢𝗩𝗜𝗗𝟭𝟵 Tracker & Models🤢")
text1 = input(" ", title="😷 COVID 19 TOOLBOX by Cryptorhythms 🤢")

////////////////////
//Region Selection//
////////////////////

text0                   = input(" ",   title="▁ ▂ ▃ ▄ ▅ ▆ ▇ █ REGION SOURCE DATA (SELECT ONLY ONE!)")
//global totals
regionSelect0           = input(true,  title="🌐 Region Select: Global Totals")

//continental / region total
regionSelect1           = input(false, title="🌏 Region Select: Asia/Austrailia")
var string asiaSelect   = input(title="Select Country",  defval="CN",       options=["AU", "NZ", "CN", "KR", "JP", "SG", "RU", "MY", "IN", "ID", "PK", "BD", "PH", "VN", "JZ", "KG", "KH", "LK", "MN", "MM", "NP", "TH", "UA", "UZ"])
regionSelect2           = input(false, title="🌍 Region Select: Africa")
var string afSelect     = input(title="Select Country",  defval="ZA",       options=["ZA", "ZW", "ZM", "EG", "ET", "NA", "NE", "NG", "CF", "CD", "CG", "CM", "KE", "LR", "MA", "MZ", "MG", "RW", "SD", "SN", "SO", "SIERRA_LEONE", "TD", "TZ", "UG"])
regionSelect6           = input(false, title="🌍 Region Select: Europe")
var string euSelect     = input(title="Select Country",  defval="IT",       options=["GB", "GR", "FR", "IT", "SP", "IR", "PL", "NL", "SE", "NO", "FI", "PT", "ES", "DK", "DE", "GL", "HR", "HU", "IE", "IS", "KO", "LV", "LU", "LT", "LI", "MT", "MK", "RO", "RS", "SK", "SI", "VA"])
regionSelect7           = input(false, title="🌍 Region Select: Middle East")
var string meSelect     = input(title="Select Country",  defval="IR",       options=["TR", "IR", "IL", "IQ", "AF", "SY", "JO", "LB", "KW", "QA", "BH", "SA", "AE", "OM", "LY", "WEST_BANK_AND_GAZA"])
regionSelect8           = input(false, title="🌎 Region Select: North/Central America & Carribean")
var string naSelect     = input(title="Select Country",  defval="US",       options=["US", "CA", "MX", "BS", "BZ", "CU", "CR", "DO", "EC", "GD", "HN", "HT", "JM", "PA", "SV", "NI"])
regionSelect9           = input(false, title="🌎 Region Select: South America")
var string saSelect     = input(title="Select Country",  defval="AR",       options=["AR", "BR", "BO", "CO", "LC", "PE", "FY", "UY", "VE", "CL"])

//specific intra-country options
regionSelect3           = input(false, title="🌏 Region Select: Austrailia (Detailed)")
var string ausSelect    = input(title="Select State",    defval="VICTORIA", options=["VICTORIA", "QUEENSLAND", "TASMANIA", "WESTERN_AUSTRAILIA", "NEW_SOUTH_WALES", "SOUTH_AUSTRAILIA", "NORTHERN_TERRITORY", "AUSTRAILIAN_CAPITAL_TERRITORY"])
regionSelect4           = input(false, title="🌎 Region Select: Canada (Detailed)")
var string canadaSelect = input(title="Select Province", defval="QUEBEC",   options=["QUEBEC", "YUKON", "ONTARIO", "MANITOBA", "ALBERTA", "BRITISH_COLUMBIA", "NEW_BRUNSWICK", "NOVA_SCOTIA", "SASKATCHEWAN", "NEWFOUNDLAND_AND_LABRADOR", "NORTHWEST_TERRITORIES", "PRINCE_EDWARD_ISLAND"])
regionSelect5           = input(false, title="🌏 Region Select: China (Detailed)")
var string chinaSelect  = input(title="Select Province", defval="HUBEI",    options=["HUBEI", "MACAU", "YUNNAN", "FUJIAN", "ANHUI", "GANSU", "HAINAN", "HEBEI", "HENAN", "HUNAN", "JILIN", "SHANXI", "TIBET", "HONG_KONG", "BEIJING", "JIANGSU", "CHONGOING", "GUANGDONG", "GUANGXI", "GUIZHOU", "JIANGXI", "LIOANING", "NINGXIA", "QINGHAI", "SHAANXI", "SHANDONG", "SHANGHAI", "SICHUAN", "TIANJIN", "XINJIANG", "ZHEJIANG", "HEILONGJIANG", "INNER_MONGOLIA"])
regionSelect10          = input(false, title="🌎 Region Select: United States (Detailed)")
var string usaSelect    = input(title="Select State",    defval="NY",       options=["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "WA", "WV", "WI", "WY", "PR", "DC"])
regionSelect11          = input(false, title="🚢 Region Select: Other (Detailed)")
var string oSelect      = input(title="Select",          defval="US_SHIP_DIAMOND_PRINCESS", options=["US_SHIP_DIAMOND_PRINCESS", "US_SHIP_GRAND_PRINCESS"])

////////////////////////////////
//create the "ticker switcher"//
////////////////////////////////

preS            = regionSelect0 ? 1       : regionSelect3 ? 2       : regionSelect4 ? 3       : regionSelect5 ? 4       : regionSelect10 ? 5      : 0
basicS          = regionSelect1==true ? 1 : regionSelect2==true ? 2 : regionSelect6==true ? 3 : regionSelect7==true ? 4 : regionSelect8==true ? 5 : regionSelect9==true ? 6 : regionSelect11==true ? 7 : 0
//global total
exchange        = 'COVID19:'
tDeaths         = exchange + 'DEATHS'
tConfirmed      = exchange + 'CONFIRMED'
tRecovered      = exchange + 'RECOVERED'
//basic constructor
basic           = basicS==1 ? asiaSelect : basicS==2 ? afSelect : basicS==3 ? euSelect : basicS==4 ? meSelect : basicS==5 ? naSelect : basicS==6 ? saSelect : basicS==7 ? oSelect : "US"
deaths          = exchange + 'DEATHS_'    + basic
confirmed       = exchange + 'CONFIRMED_' + basic
recovered       = exchange + 'RECOVERED_' + basic
//detailed counts
//austrailia
auDeaths        = exchange + 'DEATHS_AU_'    + ausSelect
auConfirmed     = exchange + 'CONFIRMED_AU_' + ausSelect
auRecovered     = exchange + 'RECOVERED_AU_' + ausSelect
//canada
caDeaths        = exchange + 'DEATHS_CA_'    + canadaSelect
caConfirmed     = exchange + 'CONFIRMED_CA_' + canadaSelect
caRecovered     = exchange + 'RECOVERED_CA_' + canadaSelect
//china
cnDeaths        = exchange + 'DEATHS_CN_'    + chinaSelect
cnConfirmed     = exchange + 'CONFIRMED_CN_' + chinaSelect
cnRecovered     = exchange + 'RECOVERED_CN_' + chinaSelect
//usa
usDeaths        = exchange + 'DEATHS_US_'    + usaSelect
usConfirmed     = exchange + 'CONFIRMED_US_' + usaSelect
usRecovered     = exchange + 'RECOVERED_US_' + usaSelect
//final selection
tickerDeaths    = preS==1 ? tDeaths    : preS==2 ? auDeaths    : preS==3 ? caDeaths    : preS==4 ? cnDeaths    : preS==5 ? usDeaths    : deaths
tickerConfirmed = preS==1 ? tConfirmed : preS==2 ? auConfirmed : preS==3 ? caConfirmed : preS==4 ? cnConfirmed : preS==5 ? usConfirmed : confirmed
tickerRecovered = preS==1 ? tRecovered : preS==2 ? auRecovered : preS==3 ? caRecovered : preS==4 ? cnRecovered : preS==5 ? usRecovered : recovered
//ticker selector
dwpInput        = input(title="Select Source Timeframe", defval="Current Timeframe", options=["Daily", "Weekly", "Current Timeframe"])
dwp             = dwpInput=="Daily" ? "D" : dwpInput=="Weekly" ? "W" : timeframe.isdaily or timeframe.isweekly ? timeframe.period : "D" 
p1              = security(tickerDeaths, dwp, close)
p2              = security(tickerConfirmed, dwp, close)
p3              = security(tickerRecovered, dwp, close)

/////////////////////////////
//Additional Plots and Data//
/////////////////////////////

//was getting a strange compiler error, until I moved these menu items down here from the top (thanks LucF for the assist!)
text2           = input(" ", title="▁ ▂ ▃ ▄ ▅ ▆ ▇ █ Additional Plots and Data")
text3           = input(" ", title=" Infopanel contains all these stats. Only use below if needed to chart stats over time.")
disableMain     = input(false,     "👀Disable Main Plots to Better Display Plots Below")
enableLabel     = input(true,      "Enable Plot Labels?")
posXPanel       = input(10,        "Labels X Offset")

plotDD          = input(false, "1. ) Plot the Days to Double Number of Confirmed")
plotGR          = input(false, "2. ) Plot the Infection Growth Ratio")
compare         = input(7,     "2a.) Growth Ratio Comparison Lookback (in days)")
plotFR          = input(false, "3. ) Plot Fatality Risk Rate (Total Deaths / Total Outcomes)") 
plotOR          = input(false, "4. ) Plot Overall Fatality Rate / Recovery Rate")
plotPI          = input(false, "5. ) Plot % of World Infected & % of USA Infected ")
plotDN          = input(false, "6. ) Plot Daily New Deaths, Confirmed & Recovered")
plotDC          = input(false, "7. ) Plot Daily Change Percentages")

//Global Plots and Labels
plot(not disableMain ? p1 < 1 ? 1 : p1 : na, title="💀 Selected Deaths",    color = color.red)
plot(not disableMain ? p2 < 1 ? 1 : p2 : na, title="😷 Selected Confirmed", color = color.yellow)
plot(not disableMain ? p3 < 1 ? 1 : p3 : na, title="😎 Selected Recovered", color = color.green)
//labels
posx            = time            + round(change(time) * posXPanel)
labelDeaths     = tickerDeaths    + " " + tostring(p1 < 1 ? 1 : p1)
labelConfirmed  = tickerConfirmed + " " + tostring(p2 < 1 ? 1 : p2)
labelRecovered  = tickerRecovered + " " + tostring(p3 < 1 ? 1 : p3)

var label l     = na, var label l1 = na, var label l2   = na, label.delete(l), label.delete(l1), label.delete(l2)
l  := not disableMain ? label.new(posx, p1 < 1 ? 1 : p1, labelDeaths, color=color.red, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time) : na
l1 := not disableMain ? label.new(posx, p2 < 1 ? 1 : p2, labelConfirmed, color=color.yellow, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time) : na
l2 := not disableMain ? label.new(posx, p3 < 1 ? 1 : p3, labelRecovered, color=color.green, textcolor=color.black, style=label.style_labelup, yloc=yloc.price, xloc=xloc.bar_time) : na

//////////////////////
//extra data sources//
//////////////////////

//world population approximator
worldPopStart    = 7775100000 //approximate world population at day 0
worldDGR         = 221917 //approximate world daily growth rate
//find population calc
bsStartInfection = barssince(p1 >= 1 and p1[1] < 1)
var int worldPop = na
worldPop        := worldPopStart + (bsStartInfection * worldDGR)

//ticker for Total US Population in units of 1000, so we have to multiply by 1000 to get actual number
usaPop           = security("FRED:POP", "M", close[1]) * 1000 
totDeaths        = security(tDeaths, dwp, close[1])
totConfirmed     = security(tConfirmed, dwp, close[1])
totRecovered     = security(tRecovered, dwp, close[1])
tC               = exchange + 'CONFIRMED_US'
tR               = exchange + 'RECOVERED_US'
tD               = exchange + 'DEATHS_US'
tConfirmedUSA    = security(tC, dwp, close[1])
tRecoveredUSA    = security(tR, dwp, close[1])
tDeathsUSA       = security(tD, dwp, close[1])

///////////////////////////
//additional calculations//
///////////////////////////

//days to double infections
log            = log10(p2)
logSlope       = (log[1]-log[2])
daysDouble     = 0.301029996/logSlope
plot(plotDD ? daysDouble : na, color=color.purple, title="😷 Days for Infected to Double")

//growth ratio
growthRatio    = (p2-p2[compare])/(p2[compare]-p2[compare*2])
plot(plotGR ? growthRatio : na, color=color.blue, title="😷 Infected Growth Ratio")

//fatality risk
fatalityRisk   = (p1[1]/(p3[1] + p1[1])) * 100
plot(plotFR ? fatalityRisk : na, color=color.fuchsia, title="💀 Fatality Risk (a.k.a Confirmed Fatality Rate)")

//overall rates
deathRate      = (totDeaths / totConfirmed) * 100
recoveryRate   = (totRecovered / totConfirmed) * 100
plot(plotOR ? deathRate    : na, color=color.maroon, title="💀 Observed Fatality Rate")
plot(plotOR ? recoveryRate : na, color=color.green,  title="😎 Observed Recovery Rate")

//percent infected
pInfectedWorld = (totConfirmed / worldPop) * 100
pInfectedUSA   = (tConfirmedUSA / usaPop) * 100
plot(plotPI ? pInfectedWorld : na, color=color.orange, title="😷 Percent of World Infected")
plot(plotPI ? pInfectedUSA   : na, color=color.aqua,   title="😷 Percent of USA Infected")

//percent daily changes
dcDeath        = ((p1[1] - p1[2])/p1[2]) * 100
dcConfirmed    = ((p2[1] - p2[2])/p2[2]) * 100
dcRecovered    = ((p3[1] - p3[2])/p3[2]) * 100
plot(plotDC ? dcDeath     : na, color=color.red,    title="💀 % Daily Change Deaths (Yesterday)")
plot(plotDC ? dcConfirmed : na, color=color.yellow, title="😷 % Daily Change Confirmed (Yesterday)")
plot(plotDC ? dcRecovered : na, color=color.green,  title="😎 % Daily Change Recovered (Yesterday)")

//numerical daily changes
newDeaths      = p1[1] - p1[2] 
newConfirmed   = p2[1] - p2[2]
newRecovered   = p3[1] - p3[2]
plot(plotDN ? newDeaths    < 1 ? na : newDeaths    : na, color=color.maroon, title="💀 New Deaths (Yesterday)")
plot(plotDN ? newConfirmed < 1 ? na : newConfirmed : na, color=color.yellow, title="😷 New Confirmed (Yesterday)")
plot(plotDN ? newRecovered < 1 ? na : newRecovered : na, color=color.green,  title="😎 New Recovered (Yesterday)")

//////////////////////
//forecasting models//
//////////////////////

text10  = input(" ", title="▁ ▂ ▃ ▄ ▅ ▆ ▇ █Forecasting Models and Settings")

//Sources://////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//1. http://medrxiv.org/content/early/2020/02/02/2020.01.29.20019547.abstract
//2. https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-2019-nCoV-severity-10-02-2020.pdf
//3. https://institutefordiseasemodeling.github.io/nCoV-public/analyses/first_adjusted_mortality_estimates_and_risk_assessment/2019-nCoV-preliminary_age_and_time_adjusted_mortality_rates_and_pandemic_risk_assessment.html
//4. https://github.com/midas-network/COVID-19/tree/master/parameter_estimates/2019_novel_coronavirus
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//General Information Needed for These Models
custom1              = input(title =  "👀IMPORTANT: Select Population Source to Use", defval="Global", options=["Global", "USA", "Custom Value to use for Province/Town/County (Enter Below)"])
customPop            = input(1000000, "Custom Population (Enter Specific Region's Population)")
sirPop               = custom1 ==     "Global" ? nz(worldPop[1], worldPopStart) : custom1 == "USA" ? usaPop : customPop
custom               = custom1 ==     "Global" ? 1                              : custom1 == "USA" ? 2      : 3
fatalityR            = input(0.87,    "Est. Fatality Rate (All cases aren't diagnosed so it's lower than CFR)")
avgTimeDeath         = input(17.33,   "Avg. Days from Infection to Death (Avg. from Multiple Sources)")

//Plot Selection
plotcpi              = input(false, "1 .) Plot the % of Custom Population Infected (Vs. the Infected Region Selected in Part 1 of Settings)")
trueNumInfectious    = input(false, "2 .) Plot the True Num. of Infectious (Death Model / DM)")
trueNumInfection     = input(false, "3 .) Plot the Current and Next Weeks Cumulative Infection Projection (DM)")
plotIR               = input(false, "4 .) Plot Estimated Infection Rates? (DM)")
enableEstimate       = input(true,  "5 .) Enable Basic Trajectory Projection?")
lookbackEst          = input(2,     "5a.) Bars Back to Draw Projection From", minval=1, maxval=7)

//Basic Projection Function
basicEstimate(lookback, src, col)=>
	var line l = na
	line.delete(l)
	l := line.new(bar_index[lookback], src[lookback], bar_index, src, style=line.style_dashed, width=1, extend=extend.right, color=col)

//Projection calls
est1            = enableEstimate and not disableMain ? basicEstimate(lookbackEst, p1,             color.red)     : na
est2            = enableEstimate and not disableMain ? basicEstimate(lookbackEst, p2,             color.yellow)  : na
est3            = enableEstimate and not disableMain ? basicEstimate(lookbackEst, p3,             color.green)   : na
est4            = plotDD and enableEstimate          ? basicEstimate(lookbackEst, daysDouble,     color.purple)  : na
est5            = plotGR and enableEstimate          ? basicEstimate(lookbackEst, growthRatio,    color.blue)    : na
est6            = plotFR and enableEstimate          ? basicEstimate(lookbackEst, fatalityRisk,   color.fuchsia) : na	
est7            = plotDC and enableEstimate          ? basicEstimate(lookbackEst, dcDeath,        color.red)     : na
est8            = plotDC and enableEstimate          ? basicEstimate(lookbackEst, dcConfirmed,    color.yellow)  : na
est9            = plotDC and enableEstimate          ? basicEstimate(lookbackEst, dcRecovered,    color.lime)    : na
est10           = plotOR and enableEstimate          ? basicEstimate(lookbackEst, deathRate,      color.purple)  : na
est11           = plotOR and enableEstimate          ? basicEstimate(lookbackEst, recoveryRate,   color.fuchsia) : na
est12           = plotPI and enableEstimate          ? basicEstimate(lookbackEst, pInfectedWorld, color.orange)  : na
est13           = plotPI and enableEstimate          ? basicEstimate(lookbackEst, pInfectedUSA,   color.aqua)    : na
est14           = plotDN and enableEstimate          ? basicEstimate(lookbackEst, newDeaths,      color.maroon)  : na
est15           = plotDN and enableEstimate          ? basicEstimate(lookbackEst, newConfirmed,   color.yellow)  : na
est16           = plotDN and enableEstimate          ? basicEstimate(lookbackEst, newRecovered,   color.green)   : na

//True Number of Infected (Deaths Model)
//dTot                 = p1
nCasesForDeaths      = p1 / fatalityR
numTimesCasesDoubled = avgTimeDeath / daysDouble 
trueCases            = min(nCasesForDeaths * pow(2,numTimesCasesDoubled), sirPop)
estTrueCasesTomorrow = min(trueCases * pow(2, (1 / daysDouble[1])), sirPop)
estTrueCasesWeek     = min(trueCases * pow(2, (7 / daysDouble[1])), sirPop)
totInfections        = cum(trueCases)
totInfectionsWeekly  = cum(estTrueCasesWeek)
customPInfected      = (p2 / customPop) * 100
plot(plotcpi           ? customPInfected      : na, color=color.purple,  title="😷 Percent of Population Infected Using Custom Input")
plot(trueNumInfectious ? trueCases            : na, color=color.maroon,  title="😷 Est. True Number of *Infectious* Today (DM)")
plot(trueNumInfectious ? estTrueCasesTomorrow : na, color=color.red,     title="😷 Est. True Number of *Infectious* Tomorrow (DM)",              offset=1, show_last=1, style=plot.style_circles, linewidth=5)
plot(trueNumInfectious ? estTrueCasesWeek     : na, color=color.fuchsia, title="😷 Est. True Number of *Infectious* One Week From Now (DM)",     offset=7, show_last=1, style=plot.style_circles, linewidth=5)
plot(trueNumInfection  ? totInfections        : na, color=color.yellow,  title="😷 Cumulative True Number of Infections (DM)")
plot(trueNumInfection  ? totInfectionsWeekly  : na, color=color.orange,  title="😷 Cumulative True Number of Infections One Week From Now (DM)", offset=7, show_last=1, style=plot.style_circles, linewidth=5)

//Likelihood of a Person Getting Infected
likelyhoodModel      = input(false, "6 .) Plot the Likelihood of > 0 **Infectious** in a Group (DM)")
useCustomConfirmed   = input(false, "6a.) Use Custom Infected?")
customConfirmed      = input(1000,  "6b.) Custom Num. Infected (Enter Specific County/Town/Province # Cases)")
sizeOfGroup          = input(50,    "6c.) Size of the Group/Gathering of People")
currentInfectionRate = trueCases            / sirPop
tomInfectionRate     = estTrueCasesTomorrow / sirPop
weekInfectionRate    = estTrueCasesWeek     / sirPop
probNoneInfected     = 100 - (pow((1 - currentInfectionRate), sizeOfGroup) * 100)
probNoneInfectedTom  = 100 - (pow((1 - tomInfectionRate),     sizeOfGroup) * 100)
probNoneInfectedWeek = 100 - (pow((1 - weekInfectionRate),    sizeOfGroup) * 100)
plot(likelyhoodModel ? probNoneInfected     : na, color=color.yellow,   title="😷 Probability Group is *Infectious* Today")
plot(likelyhoodModel ? probNoneInfectedTom  : na, color=color.gray,     title="😷 Probability Group is *Infectious* Tomorrow",          offset=1, show_last=1, style=plot.style_circles, linewidth=5)
plot(likelyhoodModel ? probNoneInfectedWeek : na, color=color.silver,   title="😷 Probability Group is *Infectious* One Week From Now", offset=7, show_last=1, style=plot.style_circles, linewidth=5)
plot(plotIR          ? currentInfectionRate : na, color=color.fuchsia,  title="😷 Estimated Current Infection Rate Today")
plot(plotIR          ? tomInfectionRate     : na, color=color.maroon,   title="😷 Estimated Current Infection Rate Tomorrow",           offset=1, offset=7, show_last=1, style=plot.style_circles, linewidth=5)
plot(plotIR          ? weekInfectionRate    : na, color=color.red,      title="😷 Estimated Current Infection Rate One Week from Now",  offset=7, offset=7, show_last=1, style=plot.style_circles, linewidth=5)

//True Number of Infected (Cases Model)
trueInfectedCM       = input(false, "7 .) Plot the True Num. of Infected (Confirmed/Tested Model)")
communitySpread      = input(0.4,   "7a.) Rate of Community Spread (typically: 0.3 to 0.9 increases as time goes on)", minval=0.01, maxval=0.99)
trackedConfirmed     = p2
trueCasesModel2      = 0.0, trueCasesModel2 := (trackedConfirmed / communitySpread)
plot(trueInfectedCM  ? trueCasesModel2 : na, color=color.fuchsia, title="😷 True Number of Infected Confirmed Cases Model")

//Expected Medical Needs Based on Models (source:https://www.businessinsider.com/presentation-us-hospitals-preparing-for-millions-of-hospitalizations-2020-3)
plotEpi              = input(false, "8 .) Plot the Estimated Epidemiology (New Confirmed dont Instantly Enter the Hospital)")
epiSource            = input(title= "8a.) Select Infected Source to Use with Models", defval="Confirmed", options=["Confirmed", "True Infected (Deaths Model)", "True Infected (Cases Model)"])
epiData              = epiSource == "Confirmed" ? p1[1] - p1[2] : epiSource == "True Infected (Deaths Model)" ? trueCases : trueCasesModel2[1] - trueCasesModel2[2]
percentHospital      = input(0.05,  "8b.) % of New Infected who will need Hospital Care in ~7 days?")
percentICU           = input(0.02,  "8c.) % of New Infected who will need ICU Care in ~7 days?")
percentVentilator    = input(0.01,  "8d.) %of New Infected who will need a Ventilator in ~7 days?")
reqHospitalBeds      = (epiData) * percentHospital
reqICU               = (epiData) * percentICU
reqVentilator        = (epiData) * percentVentilator
plot(plotEpi         ? reqHospitalBeds[1] : na, color=color.aqua,   title= "🩹 New Infected Who will Require Hospital Care", offset=7, show_last=1, style=plot.style_circles, linewidth=5)
plot(plotEpi         ? reqICU[1]          : na, color=color.blue,   title= "🚑 New Infected Who will Require ICU Care",      offset=7, show_last=1, style=plot.style_circles, linewidth=5)
plot(plotEpi         ? reqVentilator[1]   : na, color=color.purple, title= "🏥 New Infected Who will Require Ventilator",    offset=7, show_last=1, style=plot.style_circles, linewidth=5)

plotEpiNextWeek      = input(false, "9 .) Plot 2 Weeks Out Estimated Epidemiology (Deaths Model)")
reqHospitalBeds2     = (estTrueCasesWeek) * percentHospital
reqICU2              = (estTrueCasesWeek) * percentICU
reqVentilator2       = (estTrueCasesWeek) * percentVentilator
plot(plotEpiNextWeek ? reqHospitalBeds2[1] : na, color=color.aqua,   title= "🩹 14 Day Est. Infected Who will Require Hospital Care", offset=14, show_last=1, style=plot.style_circles, linewidth=5)
plot(plotEpiNextWeek ? reqICU2[1]          : na, color=color.blue,   title= "🚑 14 Day Est. Infected Who will Require ICU Care",      offset=14, show_last=1, style=plot.style_circles, linewidth=5)
plot(plotEpiNextWeek ? reqVentilator2[1]   : na, color=color.purple, title= "🏥 14 Day Est. Infected Who will Require Ventilator",    offset=14, show_last=1, style=plot.style_circles, linewidth=5)
````

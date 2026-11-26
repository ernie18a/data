# BankNifty Contribution Dashboard

- url: https://www.tradingview.com/script/7PitcOes-BankNifty-Contribution-Dashboard/
- type: indicator
- pine_id: PUB;79d1f72f7dbb4ddbade53737bebb7366
- version: 1.0

## Description

BankNifty Contribution Dashboard – Brief

The BankNifty Contribution Dashboard is a TradingView Pine Script indicator designed to identify which constituent banks are driving or dragging the Bank Nifty index in real time. Instead of simply displaying percentage price changes, the indicator calculates the actual point contribution of each stock to the Bank Nifty based on its assigned index weight, helping traders understand the true source of index movement.

Key Features
Tracks Top 10 Bank Nifty Constituents
HDFC Bank
ICICI Bank
Axis Bank
Kotak Mahindra Bank
State Bank of India
IndusInd Bank
Bank of Baroda
Punjab National Bank
IDFC First Bank
AU Small Finance Bank
Calculates Real-Time Daily Performance
Compares each stock's current price with the previous day's close.
Displays the daily percentage change for every constituent.
Weighted Index Contribution
Uses customizable Bank Nifty weightages for each stock.
Converts percentage movement into actual Bank Nifty points contributed.
Shows which stocks have the greatest influence on the index.
Pullers vs Draggers Analysis
Calculates the total positive contribution (Pullers).
Calculates the total negative contribution (Draggers).
Provides an instant view of overall market strength and weakness.
Dynamic Sorting
Sort stocks by:
Contribution Impact (points)
Percentage Change
Supports both Ascending and Descending order.
Customizable Dashboard
Adjustable table position.
Custom text size.
User-defined text colors.
Separate colors for positive (Pullers) and negative (Draggers).
Dashboard Information

The table displays:

Column	Description
Stock	Constituent bank name
% Change	Daily percentage movement
Weight	Assigned Bank Nifty weight
Impact	Actual Bank Nifty points contributed

The dashboard also summarizes:

Total Pullers (positive index contribution)
Total Draggers (negative index contribution)
Impact Calculation

The contribution of each stock is calculated using the formula:

Impact = Bank Nifty Value × Stock Weight × Daily Percentage Change

This converts a stock's percentage movement into its approximate contribution in Bank Nifty index points.

Benefits for Traders
Instantly identify which banks are moving the index.
Distinguish genuine index strength from movements driven by a few heavyweight stocks.
Monitor sector leadership during market hours.
Confirm breakout and breakdown moves by checking constituent participation.
Improve intraday trading decisions using component-level market breadth.
Ideal Users
Bank Nifty Intraday Traders
Index Option Traders
Futures Traders
Swing Traders
Institutional Market Analysts
Technical Analysts monitoring index participation
Summary

The BankNifty Contribution Dashboard transforms raw price data into a practical market analysis tool by revealing the real contributors behind every Bank Nifty move. By combining constituent weightages with live price changes, it provides traders with a clear, sortable dashboard that highlights market leaders, laggards, and the overall strength of the banking index at a glance.

## Source Code

````pine
//@version=6
indicator("BankNifty Contribution Dashboard", overlay=true)

//================ USER SETTINGS =================//

sortMetric = input.string("Impact", options=["Impact","Percent"], title="Sort By")
sortOrder  = input.string("Descending", options=["Ascending","Descending"])

tableLocation = input.string("top_right",
 options=["top_right","top_left","bottom_right","bottom_left"])

textSize = input.string("small", options=["tiny","small","normal","large"])
textColor = input.color(color.black)

pullColor = input.color(color.new(color.green,80))
dragColor = input.color(color.new(color.red,80))

//================ SYMBOL INPUTS =================//

s1=input.symbol("NSE:HDFCBANK")
s2=input.symbol("NSE:ICICIBANK")
s3=input.symbol("NSE:AXISBANK")
s4=input.symbol("NSE:KOTAKBANK")
s5=input.symbol("NSE:SBIN")
s6=input.symbol("NSE:INDUSINDBK")
s7=input.symbol("NSE:BANKBARODA")
s8=input.symbol("NSE:PNB")
s9=input.symbol("NSE:IDFCFIRSTB")
s10=input.symbol("NSE:AUBANK")

//================ WEIGHTS =================//

w1=input.float(29)
w2=input.float(24)
w3=input.float(10)
w4=input.float(9)
w5=input.float(9)
w6=input.float(5)
w7=input.float(4)
w8=input.float(3)
w9=input.float(3)
w10=input.float(2)

//================ POSITION =================//

pos = tableLocation == "top_right" ? position.top_right :
      tableLocation == "top_left" ? position.top_left :
      tableLocation == "bottom_right" ? position.bottom_right :
      position.bottom_left

//================ BANKNIFTY PRICE =================//

banknifty = request.security("NSE:BANKNIFTY", timeframe.period, close)

//================ DAILY CHANGE FUNCTION =================//

f_change(sym)=>
    c = request.security(sym, timeframe.period, close)
    prev = request.security(sym,"D",close[1])
    ((c-prev)/prev)*100

//================ DAILY CHANGE =================//

c1=f_change(s1)
c2=f_change(s2)
c3=f_change(s3)
c4=f_change(s4)
c5=f_change(s5)
c6=f_change(s6)
c7=f_change(s7)
c8=f_change(s8)
c9=f_change(s9)
c10=f_change(s10)

//================ IMPACT =================//

i1=banknifty*(w1/100)*(c1/100)
i2=banknifty*(w2/100)*(c2/100)
i3=banknifty*(w3/100)*(c3/100)
i4=banknifty*(w4/100)*(c4/100)
i5=banknifty*(w5/100)*(c5/100)
i6=banknifty*(w6/100)*(c6/100)
i7=banknifty*(w7/100)*(c7/100)
i8=banknifty*(w8/100)*(c8/100)
i9=banknifty*(w9/100)*(c9/100)
i10=banknifty*(w10/100)*(c10/100)

//================ ARRAYS =================//

names=array.from(str.tostring(s1),str.tostring(s2),str.tostring(s3),str.tostring(s4),str.tostring(s5),str.tostring(s6),str.tostring(s7),str.tostring(s8),str.tostring(s9),str.tostring(s10))
chg=array.from(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
wt=array.from(w1,w2,w3,w4,w5,w6,w7,w8,w9,w10)
imp=array.from(i1,i2,i3,i4,i5,i6,i7,i8,i9,i10)

//================ SORT =================//

for i=0 to array.size(names)-2
    for j=i+1 to array.size(names)-1
        
        m1 = sortMetric=="Impact"?array.get(imp,i):array.get(chg,i)
        m2 = sortMetric=="Impact"?array.get(imp,j):array.get(chg,j)

        swap = sortOrder=="Descending"?m1<m2:m1>m2
        
        if swap
            
            a=array.get(names,i)
            array.set(names,i,array.get(names,j))
            array.set(names,j,a)

            b=array.get(chg,i)
            array.set(chg,i,array.get(chg,j))
            array.set(chg,j,b)

            c=array.get(wt,i)
            array.set(wt,i,array.get(wt,j))
            array.set(wt,j,c)

            d=array.get(imp,i)
            array.set(imp,i,array.get(imp,j))
            array.set(imp,j,d)

//================ PULLERS / DRAGGERS =================//

pull=0.0
drag=0.0

for i=0 to array.size(imp)-1
    v=array.get(imp,i)
    if v>=0
        pull+=v
    else
        drag+=v

//================ TABLE =================//

var table t=table.new(pos,4,13,border_width=1)

table.clear(t,0,0,3,12)

table.cell(t,0,0,"Stock",text_color=textColor)
table.cell(t,1,0,"%Change",text_color=textColor)
table.cell(t,2,0,"Weight",text_color=textColor)
table.cell(t,3,0,"Impact",text_color=textColor)

table.cell(t,0,1,"Pullers",bgcolor=color.new(color.green,70))
table.cell(t,3,1,str.tostring(pull,"#.##")+" pts")

table.cell(t,0,2,"Draggers",bgcolor=color.new(color.red,70))
table.cell(t,3,2,str.tostring(drag,"#.##")+" pts")

for i=0 to array.size(names)-1

    nm=array.get(names,i)
    ch=array.get(chg,i)
    w=array.get(wt,i)
    im=array.get(imp,i)

    rowColor=ch>=0?pullColor:dragColor

    table.cell(t,0,i+3,nm,bgcolor=rowColor,text_color=textColor,text_size=textSize)
    table.cell(t,1,i+3,str.tostring(ch,"#.##")+"%",bgcolor=rowColor,text_color=textColor,text_size=textSize)
    table.cell(t,2,i+3,str.tostring(w)+"%",bgcolor=rowColor,text_color=textColor,text_size=textSize)
    table.cell(t,3,i+3,str.tostring(im,"#.##")+" pts",bgcolor=rowColor,text_color=textColor,text_size=textSize)
````

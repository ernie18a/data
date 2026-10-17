# Knesset Election Dates | Israel

- url: https://www.tradingview.com/script/MOzeTCW8-Knesset-Election-Dates-Israel/
- type: indicator
- pine_id: PUB;15a1e80575b24d198934af8133ae65b5
- version: 1.0

## Description

I made this to put Israel's elections on the same timeline as a price chart. When I look at the TA-35, an Israeli stock, USD/ILS or an Israel-focused ETF, I want the political dates in view without switching tabs or guessing which trading session was closest. The lines are reference points for asking better questions about the periods before and after each vote, not a claim that elections caused any particular move.

Knesset Election Dates marks all 25 completed elections, from the 1949 vote for the Constituent Assembly (which became the First Knesset) through the 25th Knesset election in 2022. Each solid vertical line is anchored to the election's calendar date; the Hebrew label names the Knesset and can include the date. It can also show the 26th election, currently scheduled for October 27, 2026, as an orange dashed line marked "planned." That future marker is OFF by default and disappears after the scheduled date.

How to use it
- Add it to a chart. Try TASE:TA35, a TASE-listed share, USDILS or AMEX:EIS, and compare the lead-up with the following sessions.
- "Hebrew labels" shows/hides labels; "Dates in labels" controls the date; "Line color" adjusts historical lines. Turn on "Scheduled 26th (subject to change)" for the future date.
- Daily and weekly charts work best for history. Intraday works when enough bars are loaded. A line marks the actual date, not a signal on the next session.

Dates included
1. Constituent Assembly / 1st Knesset - Jan 25, 1949
2. 2nd - Jul 30, 1951
3. 3rd - Jul 26, 1955
4. 4th - Nov 3, 1959
5. 5th - Aug 15, 1961
6. 6th - Nov 2, 1965
7. 7th - Oct 28, 1969
8. 8th - Dec 31, 1973
9. 9th - May 17, 1977
10. 10th - Jun 30, 1981
11. 11th - Jul 23, 1984
12. 12th - Nov 1, 1988
13. 13th - Jun 23, 1992
14. 14th - May 29, 1996
15. 15th - May 17, 1999
16. 16th - Jan 28, 2003
17. 17th - Mar 28, 2006
18. 18th - Feb 10, 2009
19. 19th - Jan 22, 2013
20. 20th - Mar 17, 2015
21. 21st - Apr 9, 2019
22. 22nd - Sep 17, 2019
23. 23rd - Mar 2, 2020
24. 24th - Mar 23, 2021
25. 25th - Nov 1, 2022
Scheduled, optional: 26th - Oct 27, 2026

Sources
Knesset election archive: https://main.knesset.gov.il/EN/mk/pages/elections.aspx
Israel Ministry of Interior (2026 date): https://www.gov.il/he/pages/knesset-elections-2026

Notes: dates follow the chart symbol's exchange timezone. On non-trading days the line stays on the election date. Instruments with limited history may not show older markers. This is a historical date overlay, not a prediction, recommendation or trading signal. Correlation around an election is not causation.

## Source Code

````pine
//@version=6
indicator("Knesset Election Dates | Israel", "Knesset Elections", overlay=true, max_lines_count=50, max_labels_count=50)
// Historical dates: https://main.knesset.gov.il/EN/mk/Pages/Elections.aspx
// Scheduled 26th: https://www.gov.il/he/pages/knesset-elections-2026
showLabels=input.bool(true,"Hebrew labels")
showDates=input.bool(true,"Dates in labels")
showScheduled=input.bool(true,"Scheduled 26th (subject to change)")
lineColor=input.color(color.teal,"Line color")
var years=array.from(1949,1951,1955,1959,1961,1965,1969,1973,1977,1981,1984,1988,1992,1996,1999,2003,2006,2009,2013,2015,2019,2019,2020,2021,2022,2026)
var months=array.from(1,7,7,11,8,11,10,12,5,6,7,11,6,5,5,1,3,2,1,3,4,9,3,3,11,10)
var days=array.from(25,30,26,3,15,2,28,31,17,30,23,1,23,29,17,28,28,10,22,17,9,17,2,23,1,27)
for i=0 to 25
    int yy=array.get(years,i)
    int mm=array.get(months,i)
    int dd=array.get(days,i)
    int t=timestamp(syminfo.timezone,yy,mm,dd,0,0)
    bool scheduled=i==25
    bool crossed=not na(time_close) and time_close>t and (na(time_close[1]) ? time<=t : time_close[1]<=t)
    bool drawEvent=scheduled ? (showScheduled and barstate.islast and timenow<t) : crossed
    if drawEvent
        color c=scheduled?color.orange:lineColor
        line.new(t,low,t,high,xloc=xloc.bar_time,extend=extend.both,color=c,style=scheduled?line.style_dashed:line.style_solid)
        if showLabels
            string n=i==0?"האספה המכוננת (הכנסת ה-1)":"בחירות לכנסת ה-"+str.tostring(i+1)
            string s=scheduled?" (מתוכנן)":""
            string d=showDates?" · "+str.tostring(dd)+"."+str.tostring(mm)+"."+str.tostring(yy):""
            label.new(t,high,n+s+d,xloc=xloc.bar_time,yloc=yloc.abovebar,color=c,style=label.style_label_down,textcolor=color.white,size=size.tiny)
````

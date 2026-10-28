/*+------------------------------------------------------------------+
//|                                             test_WeekendData.mq5 |
//|                                                            Calli |
//|                              https://www.mql5.com/de/users/gooly |
//| DST USA spring: 2nd. Su. in Mar. autum: 1st. Su. in Nov.         |
//| DST EU  spring: last Su. in Mar. autum: last Su. in Oct.         |
//| DST AUS spring: 1st. Su. in Apr. autum: 1st. Su. in Oct.         |
//| Seq. of Chg: Summer USA, Summer EU, Autum EU, Autum USA          |
//| Timeline Summer: AUS 1st  Su.Mar,USA 2nd Su.Mar, EU last Su.Mar  |
//| Timeline Winter: AUS 1st  Su.Oct,EU last Su.Oct, USA 1st  Su.Nov |
//+------------------------------------------------------------------*/

/*+---------------  Comment German/English  -------------------------+
Leider musste ich feststellen, dass manche Broker bei der
Serverzeitumstellung etwas nachlässig sind, was ich nicht erwartet
hatte und was mich sehr überrascht hat.
Hier ist ein Skript, mit dem jeder seinen Broker überprüfen kann.

Die FOREX-Sitzung dauert genau 120 Stunden:
von Sonntag 17:00 Uhr Eastern Standard Time (Nordamerika) bzw. EST
bis Freitag 17:00 Uhr EST.

Das Problem entsteht durch die Zeitumstellungen auf Sommerzeit und Winterzeit,
die in den verschiedenen Regionen der Welt nicht an denselben Sonntagen stattfinden.

Die USA stellen beispielsweise am 2. Sonntag im März und am 1. Sonntag im November um,
was auch den Beginn und das Ende der FOREX-Sitzung beeinflusst.

Die EU stellt am letzten Sonntag im März, also nach den USA, und am
letzten Sonntag im Oktober, also vor den USA, um (siehe obige Timeline).

Dadurch entsteht eine Übergangszeit, in der die USA und die EU eine andere
Zeitdifferenzen haben als die normalen Differenzen von 5
Stunden (London), 6 Stunden (Frankfurt, MEZ) oder 7 Stunden (Zypern, EET).

In dieser Zwischenzeit sollte sich diese Änderung der Zeitdifferenz in den
geänderten Zeitstempeln der ersten und letzten Stunde der FOREX-Sitzung widerspiegeln.
Wenn die FOREX-Sitzung also am Montag um 00:00 (EET, MQ-Zeit) beginnt, sollte sie
nach der Änderung in den USA eine Stunde früher beginnen, also am Sonntag um 23:00 Uhr,
und am Freitag eine Stunde früher enden, also um 23:00 Uhr (oder 22:59:59 Uhr).

Aber leider musste ich feststellen (und mit diesem Script kann das jeder bei seinem
Broker überprüfen), dass auf einem MQ Demokonto und auf Konten einiger echter Broker
die erste Stunde immer(!) am Montag um 00:00 erscheint, die letzte Stunde aber erwartungsgemäß
am Freitag um 23:00 (bzw. 22:59) oder eine Stunde früher. Damit fehlt die erste Stunde
der FOREX Session, in der der Händler oder ein EA auf Ereignisse am Wochenende reagieren könnte.
Auch kann das Ende der FOREX Session nicht mehr dadurch bestimmt werden, indem einfach120 zur
ersten Stunde der FOREX Session hinzuaddiert wird, um z.B. alle Positionen vor dem Wochenende zu schließen.

Dieses Script prüft nun die Zeitänderungen des Brokers in der Vergangenheit und loggt alle
FOREX Sessions mit, die offensichtlich falsch (odd) oder nicht 120 Stunden sind. Wenn zwischen
erster und letzter Stunde einer FOREX-Session 120 Stunden liegen, erfolgt kein Ausdruck im Log.

Am Ende druckt das Skript den zuletzt abgerufenen Zeitstempel, die Anzahl der gefundenen
verkürzten Sitzungen und die ungefähre Anzahl der überprüften Jahre.


Unfortunately, I discovered that some brokers are a bit sloppy with the server time
change due to the daylight saving time (DST), which I did not expect and which surprised me a lot.

The FOREX session is exactly 120 hours:
from Sunday 5:00 p.m. Eastern Standard Time (North America) or EST
  to Friday 5:00 p.m. EST.

The problem arises from the time changes to summer time and winter time, which do not
take place on the same Sundays in the different regions of the world.

For example, the USA changes on the 2nd Sunday in March and the 1st Sunday in November,
and this also affects the start and end of the FOREX session.

The EU changes on the last Sunday in March i.e. after the USA and on the
last Sunday in October i.e. before the USA (see above Timeline).

This creates an interim period in which the USA and the EU have a different time differences
than the normal differences of 5 hours (London), 6 hours (Frankfurt, CET) or 7 hours (Cyprus, EET).

In this	interim period, this change of the time difference should be reflected in the changed
time stamps of the first and last hours of the FOREX session. So if the FOREX session starts
on Monday at 00:00 (EET, MQ time), after the USA has changed it should start an hour earlier,
i.e. Sunday at 23:00 and end an hour earlier on Friday, i.e. 23:00 (or 22:59:59).

But unfortunately I had to find out (and with this script anyone can check this with their broker)
that on a MQ demo account and on accounts of some real brokers the first hour always(!) appears
on Monday at 00:00, but the last hour, as expected,
on Friday at 23:00 (or 22:59) or one hour earlier. This means that the first hour of the
FOREX session, in which the trader or an EA could react to weekend events, is missing.
Also, the end of the FOREX session can no longer be determined by simply adding 120
to the first hour of the FOREX session, e.g. to close all positions before the weekend.

This script now checks the broker's time changes in the past and logs all FOREX sessions
that are obviously incorrect (odd) or not 120 hours. If there are 120 hours
between the first and last hour of a FOREX session, nothing is logged.

At the end the script prints the last retrieved timestamp, the number of odd sessions
found and the approximate number of years that have been checked.
//+------------------------------------------------------------------*/


#property copyright "Calli"
#property link      "https://www.mql5.com/de/users/gooly"
#property version   "1.01"

//+------------------------------------------------------------------+
//| needed #define to shorten code                                   |
//+------------------------------------------------------------------+
string  _WkDy[] = {"Su.","Mo.","Tu.","We.","Th.","Fr.","Sa."};
#define DoWs(t) (_WkDy[DoWi(t)])                               // Day of Week as string:  Sun, Mon, Tue, ...
#define DoWi(t) ((int)((t)/86400+4)%7)                         // Day of Week as integer:  Sun=0, Mon=1, Tue=2, ...
#define BoW(t) ((t)-((t)+345600)%604800)                       // Begin of Week 2017.08.03 11:30 => Sun, 2017.07.30 00:00 (fixed version)
#define WeekInSec    604800                                    // 60sec*60min*24h*7d = 604800 => 1 Week
#define _tSu(t)  DoWs(t)+" "+TimeToString(t,TIME_DATE)
#define _tWkD(t) DoWs(t)+" "+TimeToString(t,TIME_DATE|TIME_MINUTES)

MqlDateTime tΤ;                                                // hidden auxiliary variable: the Τ is a Greek character, so virtually no danger
int MoY(const datetime t) {TimeToStruct(t,tΤ);return(tΤ.mon);} // TimeMonthOfYear:  1,212


//+------------------------------------------------------------------+
//| 2 variables to control the printout                              |
//+------------------------------------------------------------------+
datetime tmeEndCheck   = D'1970.01.01 00:00'; //2022.01.01 00:00';   // stop if this date is triggered, '1970.01.01 00:00' means max.
int      maxOddSess    = 20;                    // max.number of odd lines found: either sessions (!=120h) or weekend (!=48h)


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
   {
//---
    if(!TerminalInfoInteger(TERMINAL_CONNECTED))
       {
        Print("Not connected with ",AccountInfoString(ACCOUNT_COMPANY));
        return;
       }

//--- Get the earliest possible date to determin a meaninful period: earliest datetime, given datetime, or 1.5 years back form TimeCurrent()
    datetime first_server_date=0;
    if(!SeriesInfoInteger(_Symbol,PERIOD_H1,SERIES_SERVER_FIRSTDATE,first_server_date))
       {
        Print("Calling hist data failed: ",_LastError);
        return;
       }
    tmeEndCheck = fmin(fmin(TimeCurrent() - 47304000, tmeEndCheck),first_server_date);        // 47304000 = 1,5*365*24*3600 to look back at least 1.5 years.
//Print(tmeEndCheck," <=> ",first_server_date," <=> ",TimeCurrent() - 47304000); return;

//--- time vars.
    datetime dSu = DoWi(TimeCurrent()) > 1 ? BoW(TimeCurrent()) : BoW(TimeCurrent() - 345600),   // 345600 = 4*24*3600 4 days back in case it's Monday
             aTm1[], aTm9[],                                    // arrays for datetime values h1
             startCheck = BoW(TimeCurrent());                   // BoW => last Sunday

//--- aux. variables
    int      hD0,                                               // duration of the time gap of the weekend: Fr 17:00 NYt - So. 17:00 NYt = 48h + 1 (Fr. last full hour 16:00-17:00) = 49 h
             hWk,                                               // duration of Fx-Session from open So. 17:00 to Fr. 17:00 (120 h) - 1h (for Fr. 16:00) = 119 h
             b9,                                                // no. of many h1 bars
             b1 = CopyTime("EURUSD",PERIOD_H1,dSu,1,aTm1),      // no. of last h1 bar bfore weekend
             nOdd = 0;                                          // no. of odd weeks detected



//--- Test for MetaQuotes Ltd. starting week Su. 2025.01.12 - Su. 2025.01.19,  last hour before actual week: Fr. 2025.01.10 23:00
    if(b1>-1)
        Print("Weekend test for ",AccountInfoString(ACCOUNT_COMPANY)," on ",_Symbol," with starting at ", _tSu(startCheck)," - ", _tSu(startCheck+WeekInSec),", back into the past."); // Last theoretical timestamp before the actual week: ",_tWkD(aTm1[0]+(59*61)));
    else
        Print("Weekend test for ",AccountInfoString(ACCOUNT_COMPANY)," with start at ", _tSu(startCheck)," ",_tSu(dSu),"  b1: ",b1," err of CopyTime():",_LastError);
    Print("Weekend test will end either at tmeEndCheck: ",_tSu(tmeEndCheck)," or if MaxOddSess: ",maxOddSess," is triggered.");
    Print("Weekend test: an odd weekend gap (!= 48h) precedes a possibly odd FOREX session (!= 120)");
    Print("Timeline: Summer: AUS 1st Su.Mar, USA 2nd Su.Mar, EU last Su.Mar => Winter: AUS 1st Su.Oct, EU last Su.Oct, USA 1st Su.Nov");

    if((dSu - aTm1[0])/3600 > 4*24*3600)
        Print("Quote gap for ",AccountInfoString(ACCOUNT_COMPANY)," from ",_tWkD(dSu)," to ",_tWkD(aTm1[0])," = ", ((dSu - aTm1[0])/3600 > 4*24*3600),"h");

    bool isOdd=false, isOK=false;
    while(dSu>tmeEndCheck && !IsStopped() && maxOddSess >0)
       {


        //--- Skip Dec. and Jan. due to the many holidays and there is no change of DST
        while(MoY(dSu)<2 || MoY(dSu)>11)
            dSu -= WeekInSec;

        //--- get the last bar before the weekend gap
        b1 = CopyTime("EURUSD",PERIOD_H1,dSu,1,aTm1);
        if(b1<0)
           {
            Print(" FAILED  ",_tSu(dSu),"  b1: ",b1," e:",_LastError);
            continue;
           }

        //--- get the first bar after the weekend
        b9 = CopyTime("EURUSD",PERIOD_H1,aTm1[0],dSu+3*24*3600,aTm9);
        if(b9<3)
           {
            Print(" FAILED  ",_tWkD(dSu+WeekInSec),"  b9: ",b9," e:",_LastError);
            continue;
           }

        //--- get the last bar before the next weekend
        b1 = CopyTime("EURUSD",PERIOD_H1, dSu+WeekInSec,1,aTm1);
        if(b1<1)
           {
            Print(" FAILED  ",_tWkD(dSu+WeekInSec),"  b1: ",b1," e:",_LastError);
            continue;
           }

        //--- calc. the hours of the weekend gap and the following FX.-session
        hD0 = int((aTm9[1] - aTm9[0])/3600) - 1;  // -1 because th last h1 bar (e.g. 22:00) opens ~1h before the FX. session closes (e.g. 23:00)
        hWk = int((aTm1[0] - aTm9[1])/3600) + 1;  // +1 because th last h1 bar (e.g. 22:00) opens ~1h before the FX. session closes (e.g. 23:00)

        string sAdd = StringFormat("OK  48 / 120  Month:% 3d  USA DST == EU DST", MoY(aTm9[1]));
        //--- print only if the weekend gap != 48h (e.g. Fr. 23:00 - Su. 23:00) or the FGX session != 120h (Su. 23:00 - Fr. 23:00 = 5*24=120) and NOT the current week
        if((hD0!=48 || hWk!=120) && startCheck > aTm1[0])
           {
            sAdd = (hD0==48 && hWk==120)
                   ?                         StringFormat("OK  %2d / %3d  Month:% 3d  USA DST == EU DST",     hD0,hWk, MoY(aTm9[1]))
                   : (hD0!=48 && hWk!=120) ? StringFormat("odd %2d / %3d  Month:% 3d  USA DST != EU DST",     hD0,hWk, MoY(aTm9[1]))
                   : hD0!=48 ?               StringFormat("odd %2d / %3d  Month:% 3d  USA winter, EU summer", hD0,hWk, MoY(aTm9[1]))
                   :                         StringFormat("odd %2d / %3d  Month:% 3d  USA summer, EU winter", hD0,hWk, MoY(aTm9[1]));

            Print("odd  Last QTS: ",_tWkD(aTm9[0]+3540)," nxt. Sess: ",_tWkD(aTm9[1])," - ",_tWkD(aTm1[0]+3540),"  ",sAdd);
            isOdd=true;
            isOK=false;
            if(hWk!=120)
               {
                nOdd++;
                maxOddSess --;
               }
            isOK = false;
           }
        else
            //Print("Check ",_tSu(dSu)," Last H1: ",_tWkD(aTm9[0])," FX-Session(h1): ",_tWkD(aTm9[1])," - ",_tWkD(aTm1[0]+3600),"  Su.Gap:",hD0,"h   Fx.Sess:",hWk,"h  gap & sess. = OK");
            if(!isOK)
               {
                Print("OK   Last QTS: ",_tWkD(aTm9[0]+3540)," nxt. Sess: ",_tWkD(aTm9[1])," - ",_tWkD(aTm1[0]+3540)+"  "+sAdd);
                isOK = true;
               }

        //--- jump the next previous weekend
        dSu -= WeekInSec;

       }

    Print("Done - last date checked: ", _tWkD(aTm1[0]),", ",nOdd," odd FOREX sessions (weeks) detected within ~",(int)(startCheck-aTm1[0])/(3600*24*365)," years");
    return;
   }


//+------------------------------------------------------------------+
//|                                                      dTrends.mq5 |
//|                           Copyright 2019, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Roberto Jacobs (3rjfx) ~ By 3rjfx ~ Created: 2019/07/29"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
/* Update_01: 2019/07/31 ~ Added distance in input property from zero in pips.*/
#property strict
#property indicator_chart_window
//--
//--- indicator settings
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_NONE
#property indicator_type2   DRAW_NONE
#property indicator_type3   DRAW_ARROW
#property indicator_type4   DRAW_ARROW
#property indicator_width3  1
#property indicator_width4  1
#property indicator_color3  clrAqua
#property indicator_color4  clrOrangeRed
#property indicator_style3  STYLE_SOLID 
#property indicator_style4  STYLE_SOLID 
#property indicator_label2  "dTrends"
#property indicator_label3  "Rise"
#property indicator_label4  "Down"
//---
enum YN
 {
   No,
   Yes
 };
//--
//---- input parameters
input ENUM_APPLIED_PRICE      Trend_price = PRICE_CLOSE;  // Select Applied Price
input int                      ema_period = 13;           // EMA Period
input double                         dist = 2.3;          // Distance from Zero in pips 
input YN                           alerts = Yes;          // Display Alerts / Messages (Yes) or (No)
input YN                       EmailAlert = No;           // Email Alert (Yes) or (No)
input YN                       sendnotify = No;           // Send Notification (Yes) or (No)
input YN                      displayinfo = Yes;          // Display Trade Info
//--
//---- buffers
double value1[];
double value2[];
double Rise[];
double Down[];
double Bears[];
double Bulls[];
double Temp[];
//--
int cur,prv;
int cmnt,pmnt;
string posisi,
       sigpos,
       iname,
       msgText;
//--
double pip;
double devi;
//--- handle of MA 
int EmaHandle;
//--
#define minBars 99
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   //--
   SetIndexBuffer(0,value1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,value2,INDICATOR_DATA);
   SetIndexBuffer(2,Rise,INDICATOR_DATA);
   SetIndexBuffer(3,Down,INDICATOR_DATA);
   //--
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,true);
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,true);
   //--
   PlotIndexSetInteger(2,PLOT_ARROW,172); 
   PlotIndexSetInteger(3,PLOT_ARROW,172); 
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,ema_period);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,ema_period);
   //--
   iname="dTrends";
   IndicatorSetString(INDICATOR_SHORTNAME,iname);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   //--
   if(Digits()==3||Digits()==5) 
     pip=Point()*10;
   else if(Digits()==2||Digits()==4) pip=Point();
   if((StringSubstr(Symbol(),0,1)=="X")||(StringSubstr(Symbol(),0,1)=="#")) pip=Point()*10;
   devi=NormalizeDouble(dist*pip,Digits());
//--- get MA handle
   EmaHandle=iMA(NULL,0,ema_period,0,MODE_EMA,Trend_price);
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
   ObjectsDeleteAll(ChartID(),0,-1);
//----
   return;
  }
//-----//
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
//--- check for bars count
   if(rates_total<minBars)
      return(0); // not enough bars for calculation
   //-- 
   int limit;
   //--
//--- not all data may be calculated
   int calculated=BarsCalculated(EmaHandle);
   if(calculated<rates_total) return(0);
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//---- get ma buffers
//--- not all data may be calculated
   if(calculated<rates_total)
     {
      Print("Not all data of EMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(EmaHandle,0,0,to_copy,Temp)<=0)
     {
      Print("getting EMAHandle is failed! Error",GetLastError());
      return(0);
     }
//--- first calculation or number of bars was changed
   if(prev_calculated<minBars)
      limit=2;
   else limit=prev_calculated-1;
   //--
   ArrayResize(value1,limit);
   ArrayResize(value2,limit);
   ArrayResize(Rise,limit);
   ArrayResize(Down,limit);
   ArrayResize(Bears,limit);
   ArrayResize(Bulls,limit);
   ArrayResize(Temp,limit); 
   //--
   ArraySetAsSeries(value1,true);
   ArraySetAsSeries(value2,true);
   ArraySetAsSeries(Rise,true);
   ArraySetAsSeries(Down,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(Bears,true);
   ArraySetAsSeries(Bulls,true);
   ArraySetAsSeries(Temp,true);
   //--
//--- the main loop of calculations
   for(int i=limit-1; i>=0; i--)
     {
      Bears[i]=low[i]-Temp[i];
      Bulls[i]=high[i]-Temp[i];
     }
   //---
   for(int i=limit-2; i>=0; i--)
     {
       value1[i] = -(Bears[i] + Bulls[i]); 
       if((value1[i+1]>0) && (value1[i]<-devi)) {Rise[i]=low[i]; Down[i]=EMPTY_VALUE; cur=1;}
       else
       if((value1[i+1]<0) && (value1[i]>devi)) {Down[i]=high[i]; Rise[i]=EMPTY_VALUE; cur=-1;}
       else {Rise[i]=EMPTY_VALUE; Down[i]=EMPTY_VALUE;}
       if(value1[i]<0) value2[i]=1.0; 
       else
       if(value1[i]>0) value2[i]=-1.0;
     }
   //---  
   if(alerts==Yes||EmailAlert==Yes||sendnotify==Yes) Do_Alerts(cur);
   if(displayinfo==Yes) ChartComm();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void Do_Alerts(int fcur)
  {
//---
    cmnt=MqlReturnDateTime(TimeCurrent(),TimeReturn(min));
    if(cmnt!=pmnt)
      {
        //--
        if(fcur==1)
          {
            msgText=iname+" Start to Up";
            posisi="Bullish"; 
            sigpos="Open BUY Order";
          }
        else
        if(fcur==-1)
          {
            msgText=iname+" Start to Down";
            posisi="Bearish"; 
            sigpos="Open SELL Order";
          }
        else
          {
            msgText=iname+" Trend Not Found!";
            posisi="Not Found!"; 
            sigpos="Wait for Confirmation!";
          }
        //--
        if(fcur!=prv)
          {
            Print(iname,"--- "+Symbol()+" "+TF2Str(Period())+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(alerts==Yes)
              Alert(iname,"--- "+Symbol()+" "+TF2Str(Period())+": "+msgText+
                    "--- at: ",TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(EmailAlert==Yes) 
              SendMail(iname,"--- "+Symbol()+" "+TF2Str(Period())+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(sendnotify==Yes) 
              SendNotification(iname+"--- "+Symbol()+" "+TF2Str(Period())+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);                
            //--
            prv=fcur;
          }
        //--
        pmnt=cmnt;
      }
    //--
    return;
    //--
//---
  } //-end Do_Alerts()
//---------//

enum TimeReturn
  {
    year        = 0,   // Year 
    mon         = 1,   // Month 
    day         = 2,   // Day 
    hour        = 3,   // Hour 
    min         = 4,   // Minutes 
    sec         = 5,   // Seconds 
    day_of_week = 6,   // Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
    day_of_year = 7    // Day number of the year (January 1st is assigned the number value of zero) 
  };
//---------//

int MqlReturnDateTime(datetime reqtime,
                      const int mode) 
  {
    MqlDateTime mqltm;
    TimeToStruct(reqtime,mqltm);
    int valdate=0;
    //--
    switch(mode)
      {
        case 0: valdate=mqltm.year; break;        // Return Year 
        case 1: valdate=mqltm.mon;  break;        // Return Month 
        case 2: valdate=mqltm.day;  break;        // Return Day 
        case 3: valdate=mqltm.hour; break;        // Return Hour 
        case 4: valdate=mqltm.min;  break;        // Return Minutes 
        case 5: valdate=mqltm.sec;  break;        // Return Seconds 
        case 6: valdate=mqltm.day_of_week; break; // Return Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
        case 7: valdate=mqltm.day_of_year; break; // Return Day number of the year (January 1st is assigned the number value of zero) 
      }
    return(valdate);
  }
//---------//

string TF2Str(int period)
  {
   switch(period)
     {
       //--
       case PERIOD_M1:   return("M1");
       case PERIOD_M5:  return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1:  return("H1");
       case PERIOD_H4:  return("H4");
       case PERIOD_D1:  return("D1");
       case PERIOD_W1:  return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return(string(period));
  }  
//---------//

string AccountMode() // function: to known account trade mode
   {
//----
//--- Demo, Contest or Real account 
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
 //---
   string trade_mode;
   //--
   switch(account_type) 
     { 
      case  ACCOUNT_TRADE_MODE_DEMO: 
         trade_mode="Demo"; 
         break; 
      case  ACCOUNT_TRADE_MODE_CONTEST: 
         trade_mode="Contest"; 
         break; 
      default: 
         trade_mode="Real"; 
         break; 
     }
   //--
   return(trade_mode);
//----
   } //-end AccountMode()
//---------//

void ChartComm() // function: write comments on the chart
  {
//----
   //--
   int Year=MqlReturnDateTime(TimeCurrent(),TimeReturn(year));
   int Month=MqlReturnDateTime(TimeCurrent(),TimeReturn(mon));
   int Day=MqlReturnDateTime(TimeCurrent(),TimeReturn(day));
   Comment("\n     :: Server Date Time : ",(string)Year,".",(string)Month,".",(string)Day, "   ",TimeToString(TimeCurrent(),TIME_SECONDS), 
      "\n     ------------------------------------------------------------", 
      "\n      :: Broker             :  ",AccountInfoString(ACCOUNT_COMPANY), 
      "\n      :: Acc. Name       :  ",AccountInfoString(ACCOUNT_NAME), 
      "\n      :: Acc, Number    :  ",(string)AccountInfoInteger(ACCOUNT_LOGIN),
      "\n      :: Acc,TradeMode :  ",AccountMode(),
      "\n      :: Acc. Leverage   :  1 : ",(string)AccountInfoInteger(ACCOUNT_LEVERAGE), 
      "\n      :: Acc. Balance     :  ",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2),
      "\n      :: Acc. Equity       :  ",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2), 
      "\n      --------------------------------------------",
      "\n      :: Indicator Name  :  ",iname,
      "\n      :: Currency Pair    :  ",Symbol(),
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD),0),
      "\n      :: Indicator Signal :  ",posisi,
      "\n      :: Suggested        :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//
//+------------------------------------------------------------------+
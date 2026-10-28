//+------------------------------------------------------------------+
//|                                                   iTrend_new.mq4 |
//|                   Copyright 2005-2019, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2019, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property description "iTrend_new is base on iTrend Indicator by MetaQuotes Software Corp."
#property description "Update and modify by Roberto Jacobs 3rjfx @ 2019/03/18, for MT4"
#property description "with Signal and Alert and options to display signal on the chart."
#property strict
#property indicator_separate_window
//---
#property indicator_buffers 3
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property  indicator_width1  3
#property  indicator_width2  3
//--
enum b_mode
 {
   Main=0,   // MODE MAIN
   Upper=1,  // MODE UPPER,
   Lower=2   // MODE LOWER
 };
//--
enum c_price
 {  
   price_close=0,   // PRICE CLOSE
   price_open=1,    // PRICE OPEN
   price_high=2,    // PRICE HIGH
   price_low=3      // PRICE LOW
 };
//--
enum YN
 {
   No,
   Yes
 };
//--
//---- input parameters
input b_mode                   Bands_Mode = Main;         // Bollinger Bands® MODE
input ENUM_APPLIED_PRICE      Power_Price = PRICE_CLOSE;  // Select Applied Price
input c_price                  Price_Type = price_close;  // Select Calculation Price
input int                    Bands_Period = 20;           // Bollinger Bands® Period
input double              Bands_Deviation = 2.0;          // Bollinger Bands® Deviation
input int                    Power_Period = 13;           // Bears Bulls Power Period
input int                       CountBars = 360;          // Bars Calculation
input YN                           alerts = Yes;          // Display Alerts / Messages (Yes) or (No)
input YN                       EmailAlert = No;           // Email Alert (Yes) or (No)
input YN                       sendnotify = No;           // Send Notification (Yes) or (No)
input YN                      displayinfo = Yes;          // Display Trade Info
//--
//---- buffers
double value1[];
double value2[];
double value3[];
//--
int cur,prv;
int cmnt,pmnt;
string posisi,
       sigpos,
       iname,
       msgText;
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(3);
   //--
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(0,value1);
   SetIndexBuffer(1,value2);
   SetIndexBuffer(2,value3);
   //--
//---- name for DataWindow and indicator subwindow label
   iname="iTrend (" + (string)Bands_Period + ", " + DoubleToString(Bands_Deviation,1) + ")";
   IndicatorShortName(iname);
   SetIndexLabel(0, "iTrend1(" + (string)Bands_Period + ", " + DoubleToString(Bands_Deviation,1) + ")");
   SetIndexLabel(1, "iTrend2(" + (string)Power_Period + ", " + AppPrice(Power_Price) + ")");     
   SetIndexLabel(2, "iTrend3(Trend)");   
//----
   SetIndexDrawBegin(0, Bars - CountBars + Bands_Period + 1);
   SetIndexDrawBegin(1, Bars - CountBars + Bands_Period + 1);
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    GlobalVariablesDeleteAll();
//----
   return(0);
  }
//---------//
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
   int i, limit;
   if(rates_total<=Bands_Period)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
   if(limit>CountBars) limit=CountBars;
   //--
//----
   ArrayResize(value1,limit);
   ArrayResize(value2,limit);
   ArrayResize(value3,limit);
   ArraySetAsSeries(value1,true);
   ArraySetAsSeries(value2,true);
   ArraySetAsSeries(value3,true);
   //--
   double itt10=0,itt11=0;
   //--
   for(i = limit - 2; i >= 0; i--)
     {
       value1[i] = GetCurrentPrice(i) - iBands(_Symbol,0,Bands_Period,Bands_Deviation,0,Power_Price,Bands_Mode,i);
       value2[i] = -(iBearsPower(_Symbol,0,Power_Period,Power_Price,i) + iBullsPower(_Symbol,0,Power_Period,Power_Price,i)); 
       if((value2[i]<0)&&(value1[i]>0)) value3[i]=1.0;
       else
       if((value2[i]>0)&&(value1[i]<0)) value3[i]=-1.0;
       else value3[i]=0.0;
       //--
       if(i==0)
         {
           itt10=fabs(value1[i])+fabs(value2[i]);
           itt11=fabs(value1[i+1])+fabs(value2[i+1]);
           if((value3[i]==1.0)&&(itt10>itt11))  cur=1;
           if((value3[i]==-1.0)&&(itt10>itt11)) cur=-1;
           if((value3[i+1]==-1.0||value3[i+1]==0.0)&&(value3[i]==1.0)) cur=1;
           if((value3[i+1]==1.0||value3[i+1]==0.0)&&(value3[i]==-1.0)) cur=-1;
         }
     }
   //--
   //---  
   if(alerts==Yes||EmailAlert==Yes||sendnotify==Yes) Do_Alerts(cur);
   if(displayinfo==Yes) ChartComm();
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

// Getting the current price index shift
double GetCurrentPrice(int nIndex)
  {
   double cPrice;
//----
   switch(Price_Type)
     {
      case 0:  cPrice=iClose(_Symbol,0,nIndex);   break;
      case 1:  cPrice=iOpen(_Symbol,0,nIndex);    break;
      case 2:  cPrice=iHigh(_Symbol,0,nIndex);    break;
      case 3:  cPrice=iLow(_Symbol,0,nIndex);     break;
      default: cPrice=0.0;
     }
//----
   return(cPrice);
  }
//---------//

string AppPrice(ENUM_APPLIED_PRICE app)
  {
//---
   switch(app)
     {
        case PRICE_CLOSE:    return("0");
        case PRICE_OPEN:     return("1");
        case PRICE_HIGH:     return("2");
        case PRICE_LOW:      return("3");
        case PRICE_MEDIAN:   return("4");
        case PRICE_TYPICAL:  return("5");
        case PRICE_WEIGHTED: return("6");
     }
   return(string(-1));
//---
  } //-end AppPrice()  
//---------//

void Do_Alerts(int fcur)
  {
//---
    cmnt=Minute();
    if(cmnt!=pmnt)
      {
        //--
        if(fcur==1)
          {
            msgText="iTrend Start to Up";
            posisi="Bullish"; 
            sigpos="Open BUY Order";
          }
        else
        if(fcur==-1)
          {
            msgText="iTrend Start to Down";
            posisi="Bearish"; 
            sigpos="Open SELL Order";
          }
        else
          {
            msgText="Trend Not Found!";
            posisi="Not Found!"; 
            sigpos="Wait for Confirmation!";
          }
        //--
        if(fcur!=prv)
          {
            Print(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(alerts==Yes)
              Alert(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                    "--- at: ",TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(EmailAlert==Yes) 
              SendMail(iname,"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(sendnotify==Yes) 
              SendNotification(iname+"--- "+_Symbol+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(_Symbol,0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);                
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
   Comment("\n     :: Server Date Time : ",(string)Year(),".",(string)Month(),".",(string)Day(), "   ",TimeToString(TimeCurrent(),TIME_SECONDS), 
      "\n     ------------------------------------------------------------", 
      "\n      :: Broker             :  ",TerminalCompany(), 
      "\n      :: Acc. Name       :  ",AccountName(), 
      "\n      :: Acc, Number    :  ",(string)AccountNumber(),
      "\n      :: Acc,TradeMode :  ",AccountMode(),
      "\n      :: Acc. Leverage   :  1 : ",(string)AccountLeverage(), 
      "\n      :: Acc. Balance     :  ",DoubleToString(AccountBalance(),2),
      "\n      :: Acc. Equity       :  ",DoubleToString(AccountEquity(),2), 
      "\n      --------------------------------------------",
      "\n      :: Indicator Name  :  ",iname,
      "\n      :: Currency Pair    :  ",_Symbol,
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),0),
      "\n      :: Indicator Signal :  ",posisi,
      "\n      :: Suggested        :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//
//+------------------------------------------------------------------+
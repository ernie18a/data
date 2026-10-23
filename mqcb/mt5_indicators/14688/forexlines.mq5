//+------------------------------------------------------------------+
//|                                                   ForexLines.mq5 |
//|        Copyright 2023, Roberto Jacobs (3rjfx) ~ Date: 2023-12-07 |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Roberto Jacobs (3rjfx) ~ Date: 2023-12-07"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property indicator_chart_window
/*
== Last Update: 2026/03/09 ==
*/
//---
#include <MovingAverages.mqh>
//--
#property indicator_buffers 8
#property indicator_plots   1
//--
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrBlue,clrRed
#property indicator_width1  2
//--
#property indicator_type2   DRAW_NONE
#property indicator_type3   DRAW_NONE
#property indicator_type4   DRAW_NONE
#property indicator_type5   DRAW_NONE
#property indicator_type6   DRAW_NONE
#property indicator_type7   DRAW_NONE
#property indicator_type8   DRAW_NONE
//--
enum YN
  {
   No,
   Yes
  };
//--
//---
input YN                  alerts = No;              // Display Alerts / Messages (Yes) or (No)
input YN           UseEmailAlert = No;               // Email Alert (Yes) or (No)
input YN           UseSendnotify = No;               // Send Notification (Yes) or (No)
//----
//-- buffers
double lwma05Buffers[];
double lwma10Buffers[];
double lwma20Buffers[];
double line20Buffers[];
double updnBuffers[];
double macdMnBuffers[];
double macdSgBuffers[];
double signal_alert[];
//-
int curMnt;
int prvMnt;
int mafast=5;
int maslow=10;
int mdma20=20;
int cural,prval;
int prvAlertBar;
//--- MA & MACD handles
int ExtMaFastHandle;
int ExtMaSlowHandle;
int ExtMACDHandle;
//--
bool lup,ldn;
//--
string short_name;
string alBase,alSubj,alMsg;
//--
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   //-- Checking the Digits Point
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   //--
//--- indicator buffers mapping
   //--
   SetIndexBuffer(0,line20Buffers,INDICATOR_DATA);
   SetIndexBuffer(1,updnBuffers,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,lwma05Buffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,lwma10Buffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,lwma20Buffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,macdMnBuffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,macdSgBuffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,signal_alert,INDICATOR_DATA);
//---
   PlotIndexSetString(7,PLOT_LABEL,"Alert"); 
   //--
   short_name="FXLines,"+string(Symbol())+","+"TF:"+strTF(Period());
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   //--
   //---
   ExtMaFastHandle=iMA(Symbol(),PERIOD_CURRENT,mafast,0,MODE_LWMA,PRICE_MEDIAN);
   if(ExtMaFastHandle==INVALID_HANDLE)
     {
       printf("Error creating indicator Fast(5) LWMA for ",Symbol());
       return(INIT_FAILED);
     }
   //--
   ExtMaSlowHandle=iMA(Symbol(),PERIOD_CURRENT,mdma20,0,MODE_SMA,PRICE_MEDIAN);
   if(ExtMaSlowHandle==INVALID_HANDLE)
     {
       printf("Error creating indicator Slow(20) SMA Median Price for ",Symbol());
       return(INIT_FAILED);
     }
   //--
   ExtMACDHandle=iMACD(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_CLOSE);
   if(ExtMACDHandle==INVALID_HANDLE)
     {
       printf("Failed to create handle of the iMACD indicator for ",Symbol());
       return(INIT_FAILED);
     }
   //--
   //---
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----  
   //--
   IndicatorRelease(ExtMaFastHandle);
   IndicatorRelease(ExtMaSlowHandle);
   IndicatorRelease(ExtMACDHandle);
   //--
   ObjectsDeleteAll(ChartID(),0,-1);
   GlobalVariablesDeleteAll();   
//----
   return;
  }
//----
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
   int i;
   cural=-1;
   lup=false;
   ldn=false;
   double FLOpen;
   double FLClos;
//--- check for bars count
   if(rates_total<=maslow) return(0);
//--- Set Last error value to Zero
   ResetLastError();  
   //--
//--- counting from rates_total to 0
   //--
   ArrayResize(lwma05Buffers,rates_total,rates_total);
   ArrayResize(lwma10Buffers,rates_total,rates_total);
   ArrayResize(lwma20Buffers,rates_total,rates_total);
   ArrayResize(line20Buffers,rates_total,rates_total);
   ArrayResize(updnBuffers,rates_total,rates_total);
   ArrayResize(macdMnBuffers,rates_total,rates_total);
   ArrayResize(macdSgBuffers,rates_total,rates_total);
   ArrayResize(signal_alert,rates_total,rates_total);
   //--
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtMaFastHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtMaFastHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   //--
   calculated=BarsCalculated(ExtMaSlowHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   //--
   calculated=BarsCalculated(ExtMACDHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtMACDHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   //---
//--- we can copy not all data
   int to_copy;
   int values_to_copy; 
   if(prev_calculated>rates_total || prev_calculated<0) 
     {
       to_copy=values_to_copy=rates_total;
     }
   else
     {
       to_copy=values_to_copy=rates_total-prev_calculated;
       if(prev_calculated>0) to_copy++; values_to_copy++;
     }
   //--
   //--
//--- get ExtMaFastHandle buffers
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMaFastHandle,0,0,to_copy,lwma05Buffers)<0)
     {
      Print("Getting ExtMaFastHandle buffers is failed! Error",GetLastError());
      return(0);
     }
//--- get ExtMaSlowHandle buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMaSlowHandle,0,0,to_copy,line20Buffers)<0)
     {
       Print("Getting ExtMaSlowHandle buffers is failed! Error",GetLastError());
       return(0);
     }
//--- get ExtMACDHandle buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMACDHandle,0,0,values_to_copy,macdMnBuffers)<0)
     {
       Print("Getting MACD Main buffers is failed! Error",GetLastError());
       return(0);
     }
   //--
   if(CopyBuffer(ExtMACDHandle,1,0,values_to_copy,macdSgBuffers)<0)   
     {
       Print("Getting MACD Signal buffers is failed! Error",GetLastError());
       return(0);
     }
   //--
//----
   //--
//--- get LWMA 10 Buffers
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,maslow,lwma05Buffers,lwma10Buffers,to_copy);
//--- get LWMA 20 Buffers
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,mdma20,lwma10Buffers,lwma20Buffers,to_copy);
   //--
//--- last counted bar will be recounted
//---- main cycle
   //--
   for(i=0; i<rates_total-1; i++)
     {
       //--
       if((lwma05Buffers[i]>lwma20Buffers[i])) 
         {
           lup=true; 
           ldn=false;
         }
       //else
       if((lwma05Buffers[i]<lwma20Buffers[i])) 
         {
           ldn=true; 
           lup=false;
         }
       //--
       if(lup)
         {updnBuffers[i]=0.0; PlotIndexSetString(0,PLOT_LABEL,"FXLines Buy:");}
       if(ldn)
         {updnBuffers[i]=1.0;  PlotIndexSetString(0,PLOT_LABEL,"FXLines Sell:");}
       //--
       if(i==0)
         {
           //--
           double flmacd0=macdMnBuffers[i]-macdSgBuffers[i];
           double flmacd1=macdMnBuffers[i+1]-macdSgBuffers[i+1];
           double macdfm0=macdMnBuffers[i];
           double macdfm1=macdMnBuffers[i+1];
           FLOpen=(high[i+1]+low[i+1]+close[i+1]+close[i+1])/4;
           FLClos=(high[i]+low[i]+close[i]+close[i])/4;
           bool flmacdup=((flmacd0>flmacd1)&&(macdfm0>macdfm1));
           bool flmacddn=((flmacd0<flmacd1)&&(macdfm0<macdfm1));
           //--
           if((lup)&&(lwma05Buffers[0]>lwma05Buffers[1])&&(flmacdup)&&(FLClos>FLOpen)&&
             (close[0]>open[0])&&(close[0]>lwma05Buffers[0])) {signal_alert[0]=3.0;} // goes up
           //-
           if((lup)&&(lwma05Buffers[0]>lwma05Buffers[1])&&(flmacddn)&&(FLClos<FLOpen)&&
             (close[0]<lwma05Buffers[0])) {signal_alert[0]=1.0;} // feasibility down
           //-
           if((lup)&&(lwma05Buffers[0]<=lwma05Buffers[1])&&(flmacddn)&&(FLClos<FLOpen)&&
             (close[0]<lwma05Buffers[0])) {signal_alert[0]=5.0;} // began to down
           //--
           if((ldn)&&(lwma05Buffers[0]<lwma05Buffers[1])&&(flmacddn)&&(FLClos<FLOpen)&&
             (close[0]<open[0])&&(close[0]<lwma05Buffers[0])) {signal_alert[0]=2.0;} // goes down
           //-
           if((ldn)&&(lwma05Buffers[0]<lwma05Buffers[1])&&(flmacdup)&&(FLClos>FLOpen)&&
             (close[0]>lwma05Buffers[0])) {signal_alert[0]=0.0;} // feasibility up
           //-
           if((ldn)&&(lwma05Buffers[0]>=lwma05Buffers[1])&&(flmacdup)&&(FLClos>FLOpen)&&
             (close[0]>lwma05Buffers[0])) {signal_alert[0]=4.0;} // began to up
           //--
         }
       //--
     }
   //---
   //ChartRedraw(0);
   if(alerts==Yes||UseEmailAlert==Yes||UseSendnotify==Yes)
      posAlerts((int)signal_alert[0]);
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---//

//---/
void doAlerts(string msgText,string eMailSub)
  {
//---
    //--
    Print(msgText);
    //--
    if(alerts==Yes) Alert(msgText);
    //--
    if(UseEmailAlert==Yes) 
      SendMail(eMailSub,msgText);
    //--
    if(UseSendnotify==Yes) 
      SendNotification(msgText);
    //--
    return;
    //--
//---
  } //-end doAlerts()
//---------//

string strTF(ENUM_TIMEFRAMES period)
  {
//---
   switch(period)
     {
       //--
       case PERIOD_M1:   return("M1");
       case PERIOD_M2:   return("M2");
       case PERIOD_M3:   return("M3");
       case PERIOD_M4:   return("M4");
       case PERIOD_M5:   return("M5");
       case PERIOD_M6:   return("M6");
       case PERIOD_M10:  return("M10");
       case PERIOD_M12:  return("M12");
       case PERIOD_M15:  return("M15");
       case PERIOD_M20:  return("M20");
       case PERIOD_M30:  return("M30");
       case PERIOD_H1:   return("H1");
       case PERIOD_H2:   return("H2");
       case PERIOD_H3:   return("H3");
       case PERIOD_H4:   return("H4");
       case PERIOD_H6:   return("H6");
       case PERIOD_H8:   return("H8");
       case PERIOD_H12:  return("H12");
       case PERIOD_D1:   return("D1");
       case PERIOD_W1:   return("W1");
       case PERIOD_MN1:  return("MN1");
       //--
     }
   return(string(period));
//---
  } //-end strTF()
//---------//

//---/
void posAlerts(int alrts)
   {
     //--
     curMnt=TIME_MINUTES;
     if(curMnt!=prvMnt)
       {
         //--
         if((cural!=prval)&&(alrts==3))
            {     
              alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
              alSubj=alBase+". The Price Goes Up,";
              alMsg=alSubj+" Action: Open BUY.!!";
              prvMnt=curMnt;
              prval=cural;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cural!=prval)&&(alrts==2))
            {     
              alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
              alSubj=alBase+". The Price Goes Down,";
              alMsg=alSubj+" Action: Open SELL.!!";
              prvMnt=curMnt;
              prval=cural;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cural!=prval)&&(alrts==0))
            {     
              alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
              alSubj=alBase+". The Price Feasibility Up,";
              alMsg=alSubj+" Action: Wait and See.!!";
              prvMnt=curMnt;
              prval=cural;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cural!=prval)&&(alrts==1))
            {     
              alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
              alSubj=alBase+". The Price Feasibility Down,";
              alMsg=alSubj+" Action: Wait and See.!!";
              prvMnt=curMnt;
              prval=cural;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cural!=prval)&&(alrts==4))
            {     
              alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
              alSubj=alBase+" The Price Began to Up,";
              alMsg=alSubj+" Action: Wait and See.!!";
              prvMnt=curMnt;
              prval=cural;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cural!=prval)&&(alrts==5))
            {     
              alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
              alSubj=alBase+" The Price Began to Down,";
              alMsg=alSubj+" Action: Wait and See.!!";
              prvMnt=curMnt;
              prval=cural;
              doAlerts(alMsg,alSubj);
            }
         //--
       }
     //--
     return;
     //--
   //----
   } //-end posAlerts()
//---/
//+------------------------------------------------------------------+

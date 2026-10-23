//+------------------------------------------------------------------+
//|                                           TimerClosingPeriod.mq5 |
//|                                        Copyright Dmitry Voronkov |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitry Voronkov"
#property link      "vdv_2001@mail.ru"
#property version   "1.00"
#property indicator_chart_window
//#property indicator_plots   0

#include "CTimer.mqh"
#include <ChartObjects\ChartObjectsTxtControls.mqh>

CTimer *Timer1;
CTimer *TimerH1;
CChartObjectButton TimerButton;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- We create the object button
   TimerButton.Create(0,"TimerButton "+IntegerToString(_Period),0,40,30,25,25);
   TimerButton.Description("»");
   TimerButton.Font("Wingdings");
   TimerButton.FontSize(16);
   TimerButton.Corner(CORNER_RIGHT_UPPER);
   TimerButton.Anchor(ANCHOR_CENTER);
   TimerButton.State(true);
//--- We create the object CTimer for the current time period
   Timer1=new CTimer();
   Timer1.Create(0,"Current Timer "+IntegerToString(_Period),0,40,15);
   if(Period()<PERIOD_H1)
     {
//--- If the current period is lower than H1, we create new object CTimer for period H1
      TimerH1=new CTimer();
      TimerH1.TimePeriod(PERIOD_H1);
      TimerH1.Create(0,"H1 Timer "+IntegerToString(_Period),0,40,35);
     }
//--- We start timer events
   EventSetTimer(1);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- We delete CTimer objects
   if(Timer1!=NULL) {delete Timer1; Timer1=NULL;}
   if(TimerH1!=NULL) {delete TimerH1; TimerH1=NULL;}
   EventKillTimer();
  }
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
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Expert Event function                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event id
                  const long& lparam,   // event parameter of long type
                  const double& dparam, // event parameter of double type
                  const string& sparam) // event parameter of string type
  {
   switch(id)
     {
      case CHARTEVENT_KEYDOWN:
         // Event of keyboard pressing when chart window is in focus
         break;
      case CHARTEVENT_CLICK:
         // Event of mouse button clicks
         break;
      case CHARTEVENT_OBJECT_CREATE:
         // Event of the graphic object creation
         break;
      case CHARTEVENT_OBJECT_DELETE:
         // Event of the graphic object removal
         break;
      case CHARTEVENT_OBJECT_CLICK:
         // Event of the mouse click on the graphic object, assigned to chart
         if(TimerButton.Name()==sparam)
           {
            if(TimerButton.State())
              {
               Timer1=new CTimer();
               Timer1.Create(0,"Current Timer "+IntegerToString(_Period),0,40,15);
               if(Period()<PERIOD_H1)
                 {
                  TimerH1=new CTimer();
                  TimerH1.TimePeriod(PERIOD_H1);
                  TimerH1.Create(0,"H1 Timer "+IntegerToString(_Period),0,40,30);
                 }
              }
            else
              {
               if(Timer1!=NULL) {delete Timer1; Timer1=NULL;}
               if(TimerH1!=NULL) {delete TimerH1; TimerH1=NULL;}
              }
           }
         break;
      case CHARTEVENT_OBJECT_DRAG:
         // Event of moving of graphic object using the mouse
         break;
      case CHARTEVENT_OBJECT_ENDEDIT:
         // Event of text editing end in the input field of LabelEdit graphic object
         break;
//      case CHARTEVENT_TRADE:
//         break;
      default:
         // Here we are if there is something new :)
         break;
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Expert Timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(Timer1!=NULL) Timer1.OnTimer();
   if(TimerH1!=NULL) TimerH1.OnTimer();
  }
//+------------------------------------------------------------------+

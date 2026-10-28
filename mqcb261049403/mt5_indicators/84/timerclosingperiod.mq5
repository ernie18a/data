//+------------------------------------------------------------------+
//|                                           TimerClosingPeriod.mq5 |
//|                                        Copyright Dmitry Voronkov |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitry Voronkov"
#property link      "vdv_2001@mail.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots   1
#property indicator_buffers 1

#include "CTimer.mqh"
#include <ChartObjects\ChartObjectsTxtControls.mqh>

input string      InpPathFirstSound="alert.wav"; // First signal
input string      InpPathSecondSound="news.wav"; // Second signal

CTimer *Timer1=NULL;
CTimer *TimerH1=NULL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Create CTimer object for the current time period
   Timer1=new CTimer();
   Timer1.Create(0,"Current Timer "+IntegerToString(_Period),0,50,15);
   Timer1.SignalFile(InpPathFirstSound);
   if(Period()<PERIOD_H1)
     {
      Timer1.SignalOff();
      //--- If current period of less hour we create CTimer object for period H1
      TimerH1=new CTimer();
      TimerH1.TimePeriod(PERIOD_H1);
      TimerH1.Create(0,"H1 Timer "+IntegerToString(_Period),0,50,35);
      TimerH1.SignalFile(InpPathSecondSound);
     }
//--- Start generation of timer event
   EventSetTimer(1);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete CTimer objects 
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
   if(Timer1!=NULL) Timer1.OnEvent(id,lparam,dparam,sparam);
   if(TimerH1!=NULL)TimerH1.OnEvent(id,lparam,dparam,sparam);
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

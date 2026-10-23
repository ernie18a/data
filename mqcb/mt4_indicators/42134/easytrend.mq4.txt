//+------------------------------------------------------------------+
//|                                                   EASY-TREND.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+



#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//----
#property strict
#property indicator_chart_window
#property indicator_buffers 7

#property indicator_color2 MediumSeaGreen
#property indicator_color4 Orange
#property  indicator_color5  Plum
#property  indicator_width5 5
#property indicator_color6 IndianRed
#property  indicator_color7  LightSkyBlue
#property  indicator_width7 5
//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
**************************************************************************/
extern int TimeFrame=60;

//---- input parameters Bollinger-inverse
extern int ainpperiod = 10;
extern double ainpdeviation =1.25 ;
extern int ainpshift = 1;

//---- input parameters Ma
extern int aperiodma = 3;
extern int ashiftma = 0;
extern int amethodma = 3;
extern int apricema = 5;
//---- input parameters MaxMinChannel
extern int Band_PeriodMM = 90;
extern int SiftMM = 1;
//----
double UP[];
double STBL[];
double DW[];

double UP1;
double STBL1;
double DW1;

double m00[];
double m01[];
double m10[];
double m11[];
double m20[];
double m21[];

string TimeFrameStr;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexBuffer(0,m00);
   SetIndexStyle(0,DRAW_LINE);

   SetIndexBuffer(1,UP);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,5);

   SetIndexBuffer(2,m01);
   SetIndexStyle(2,DRAW_LINE);

   SetIndexBuffer(2,m10);
   SetIndexStyle(2,DRAW_LINE);

   SetIndexBuffer(3,STBL);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,5);

   SetIndexBuffer(4,m11);
   SetIndexStyle(4,DRAW_LINE);

   SetIndexBuffer(2,m20);
   SetIndexStyle(2,DRAW_LINE,0,3);

   SetIndexBuffer(5,DW);
   SetIndexStyle(5,DRAW_HISTOGRAM,0,5);

   SetIndexBuffer(6,m21);
   SetIndexStyle(6,DRAW_LINE,0,3);



//---- name for DataWindow and indicator subwindow label
   switch(TimeFrame)
     {
      case 1 :
         TimeFrameStr="Period_M1";
         break;
      case 5 :
         TimeFrameStr="Period_M5";
         break;
      case 15 :
         TimeFrameStr="Period_M15";
         break;
      case 30 :
         TimeFrameStr="Period_M30";
         break;
      case 60 :
         TimeFrameStr="Period_H1";
         break;
      case 240 :
         TimeFrameStr="Period_H4";
         break;
      case 1440 :
         TimeFrameStr="Period_D1";
         break;
      case 10080 :
         TimeFrameStr="Period_W1";
         break;
      case 43200 :
         TimeFrameStr="Period_MN1";
         break;
      default :
         TimeFrameStr="Current Timeframe";
     }



   return(0);
  }
//----

//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                                |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   
   


   int    i,limit,y=0,counted_bars=IndicatorCounted();

// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----
   limit=Bars-counted_bars;
   for(i=0,y=0; i<limit; i++)
     {
      if(Time[i]<TimeArray[y])
         y++;
      /***********************************************************
         Add your main indicator loop below.  You can add the full
            indicator code or you can just reference an existing
            indicator with its iValue or iCustom.
         Rule 1:  Add extern inputs above for all neccesary values
         Rule 2:  Use 'TimeFrame' for the indicator time frame
         Rule 3:  Use 'y' for your indicator's shift value
       **********************************************************/

      m00[i]=getPeriodLow(Band_PeriodMM,i+SiftMM);
      m01[i]=getPeriodHigh(Band_PeriodMM,i+SiftMM);
      m10[i]=getPeriodHigh(Band_PeriodMM,i+SiftMM);
      m11[i]=getPeriodLow(Band_PeriodMM,i+SiftMM);
      m20[i]=getPeriodLow(Band_PeriodMM,i+SiftMM);
      m21[i]=getPeriodHigh(Band_PeriodMM,i+SiftMM);

      UP1= iCustom(NULL,TimeFrame,"a-TENDANCE-H1-chart-window",ainpperiod,ainpdeviation,ainpshift,aperiodma,ashiftma,amethodma,apricema,4,y);
      STBL1= iCustom(NULL,TimeFrame,"a-TENDANCE-H1-chart-window",ainpperiod,ainpdeviation,ainpshift,aperiodma,ashiftma,amethodma,apricema,6,y);
      DW1= iCustom(NULL,TimeFrame,"a-TENDANCE-H1-chart-window",ainpperiod,ainpdeviation,ainpshift,aperiodma,ashiftma,amethodma,apricema,8,y);

      if(UP1>0)
        {
         UP[i]=getPeriodHigh(Band_PeriodMM,i+SiftMM);
        }
      else
        {
         UP[i]=getPeriodLow(Band_PeriodMM,i+SiftMM);
        };
      if(STBL1>0)
        {
         STBL[i]=getPeriodHigh(Band_PeriodMM,i+SiftMM);
        }
      else
        {
         STBL[i]=getPeriodLow(Band_PeriodMM,i+SiftMM);
        };
      if(DW1>0)
        {
         DW[i]=getPeriodHigh(Band_PeriodMM,i+SiftMM);
        }
      else
        {
         DW[i]=getPeriodLow(Band_PeriodMM,i+SiftMM);
        };

     }


//----
   return(0);
  }
double getPeriodHigh(int period, int pos)
  {
   int i;
   double buffer = 0;
   for(i=pos; i<=pos+period; i++)
     {
      if(High[i] > buffer)
        {
         buffer = High[i];
        }
     }
   return (buffer);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPeriodLow(int period, int pos)
  {
   int i;
   double buffer = 100000;
   for(i=pos; i<=pos+period; i++)
     {
      if(Low[i] < buffer)
        {
         buffer = Low[i];
        }
     }
   return (buffer);
  }
//+------------------------------------------------------------------+

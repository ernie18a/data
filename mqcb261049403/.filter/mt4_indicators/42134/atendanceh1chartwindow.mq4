//+------------------------------------------------------------------+
//|                                   a-TENDANCE-H1-chart-window.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 10

#property indicator_color5 MediumSeaGreen
#property indicator_color7 Orange
#property indicator_color9 IndianRed


double BH[];
double BL[];
double ma[];
double m00[];
double m01[];
double m02[];
double m03[];
double TendanceUP[];
double TendanceSTBL[];
double TendanceDW[];

extern int inpperiod = 10;
extern double inpdeviation =1.25 ;
extern int inpshift = 1;

extern int periodma = 3;
extern int shiftma = 0;
extern int methodma = 3;
extern int pricema = 5;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BH);
   SetIndexStyle(0,DRAW_NONE);

   SetIndexBuffer(1,BL);
   SetIndexStyle(1,DRAW_NONE);

   SetIndexBuffer(2,ma);
   SetIndexStyle(2,DRAW_NONE);

   SetIndexBuffer(3,m00);
   SetIndexStyle(3,DRAW_NONE);

   SetIndexBuffer(4,TendanceUP);
   SetIndexStyle(4,DRAW_HISTOGRAM,0,5);

   SetIndexBuffer(5,m01);
   SetIndexStyle(5,DRAW_NONE);

   SetIndexBuffer(6,TendanceSTBL);
   SetIndexStyle(6,DRAW_HISTOGRAM,0,5);

   SetIndexBuffer(7,m02);
   SetIndexStyle(7,DRAW_NONE);

   SetIndexBuffer(8,TendanceDW);
   SetIndexStyle(8,DRAW_HISTOGRAM,0,5);

   SetIndexBuffer(9,m03);
   SetIndexStyle(9,DRAW_NONE);


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i;
   for(i=Bars-1; i>=0; i--)
     {
      BH[i]=iCustom(NULL,0,"bollinger-inverse",inpperiod,inpdeviation,inpshift,2,i);
      BL[i]=iCustom(NULL,0,"bollinger-inverse",inpperiod,inpdeviation,inpshift,0,i);
      ma[i]=iMA(NULL,0,periodma,shiftma,methodma,pricema,i);
      m00[i]=0;
      m01[i]=0;
      m02[i]=0;
      m03[i]=0;

      if(ma[i]>BH[i])
        {
         TendanceUP[i]=100000;
        }
      else
        {
         TendanceUP[i]=0;
        };


      if(ma[i]<BL[i])
        {
         TendanceDW[i]=100000;
        }
      else
        {
         TendanceDW[i]=0;
        };


      if(((ma[i]>BL[i]) && (ma[i]<BH[i])))
        {
         TendanceSTBL[i]=100000;
        }
      else
        {
         TendanceSTBL[i]=0;
        };







     }
   return(0);
  }
//+------------------------------------------------------------------
//+------------------------------------------------------------------+0

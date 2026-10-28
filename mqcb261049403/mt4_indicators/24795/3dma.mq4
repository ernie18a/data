//+------------------------------------------------------------------+
//|                                                         3DMa.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                         https://www.mql5.com/ru/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Nikolay Semko"
#property link      "https://www.mql5.com/ru/users/nikolay7ko"
#property link      "SemkoNV@bk.ru"  
#property version   "1.02"
#property strict
#include <Canvas\iCanvas.mqh> //https://www.mql5.com/en/code/23840
#property indicator_chart_window

double  close[];
long Total;
int Ma=0;
int stepMa=0;
int Size=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+---------------------------------б---------------------------------+
int OnInit()
  {
   ChartSetInteger(0,CHART_FOREGROUND,true);
   Size=CopyClose(_Symbol,_Period,(int)W.Right_bar,W.BarsInWind+Ma-1,close);
   Total=SeriesInfoInteger(_Symbol,_Period,SERIES_BARS_COUNT);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   static int MaOld=-1,stepMaOld=-1;
   static bool click=true;
   static string pre_sparam="1";
   static int preMa=0;
   if(sparam=="1" && sparam!=pre_sparam) if(click) click=false; else click=true;
   if(click)
     {
      Ma=W.MouseX+100;
      if (Ma>=Size) Ma=Size-1;
      stepMa=W.MouseY-15;
      if(stepMa<=0) stepMa=1;
      stepMa=1+stepMa/10;
      if(stepMa>Ma) stepMa=Ma-1;
      if (Size>=W.BarsInWind && preMa!=Ma) nMA();
      preMa=Ma;
     }
   if(id==CHARTEVENT_CHART_CHANGE || MaOld!=Ma || stepMaOld!=stepMa)
     {
      Size=CopyClose(_Symbol,_Period,(int)W.Right_bar,W.BarsInWind+Ma-1,close);
      if (Ma>=Size) Ma=Size-1;
      if (Size>=W.BarsInWind) nMA();
      MaOld=Ma; stepMaOld=stepMa;
     }
   pre_sparam=sparam;
  }
//+------------------------------------------------------------------+

void nMA()
  {
   Canvas.Erase();
   double S=0;
   double A[]; 
   ArrayResize(A,W.BarsInWind);
   for(int i=Size-1;i>=Size-Ma; i--) S+=close[i];
   for(int Per=Ma;Per>0;)
     {
      double s=S;
      uint Clr=Grad((double)Per/Ma);
      int j=0;
      for(int i=Size-1; i>=0;i--)
        {
         double Y=s/Per;
         j=Size-1-i;
         if (j<W.BarsInWind) A[j]=Y; else break;
         if(i-Per>=0) s=s+close[i-Per]-close[i]; else break;
        }
      DrawIndicatorLine(A,Clr,Floor(W.Right_bar),j+Floor(W.Right_bar));
      for(j=0; j<stepMa; j++) if(Per>0) {S=S-close[Size-Per]; Per--;} else break;
     }
   Canvas.TextPosY=90;
   Canvas.Comm("Max Period MA = "+string(Ma));
   Canvas.Comm("Step MA = "+string(stepMa));
   Canvas.Update();
  }
//+------------------------------------------------------------------+
uint Grad(double p)
  {
   static uint Col[6]={0xFF0000FF,0xFFFF00FF,0xFFFF0000,0xFFFFFF00,0xFF00FF00,0xFF00FFFF};
   if(p>0.9999) return Col[5];
   if(p<0.0001) return Col[0];
   p=p*5;
   int n=(int)p;
   double k=p-n;
   argb c1,c2;
   c1.clr=Col[n];
   c2.clr=Col[n+1];
   return ARGB(255,c1.c[2]+uchar(k*(c2.c[2]-c1.c[2])+0.5),
               c1.c[1]+uchar(k*(c2.c[1]-c1.c[1])+0.5),
               c1.c[0]+uchar(k*(c2.c[0]-c1.c[0])+0.5));
  }
//+------------------------------------------------------------------+

void DrawIndicatorLine(double &arr[], uint clr, int barStart=INT_MIN, int barEnd=INT_MAX)
  {
   if (barStart<W.Right_bar) barStart=Floor(W.Right_bar);
   if (barEnd>W.Left_bar) barEnd=W.Left_bar;
   if (W.Left_bar<=barStart) return;
   int n=barEnd-barStart;
   int x=(int)Canvas.X((double)barStart);
   int pre_y=Round(Canvas.Y(arr[0]));
   Canvas.PixelSet(x,pre_y,clr);
   x-=W.dx_pix;
   for(int i=1; i<n; i++, x-=W.dx_pix) 
     {
      int y=Round(Canvas.Y(arr[i]));  
      if(fabs(y-pre_y)>1 || W.dx_pix>1) Canvas.Line(x,y,x+W.dx_pix,pre_y,clr);
      else Canvas.PixelSet(x,y,clr);
      pre_y=y;
     }
  }
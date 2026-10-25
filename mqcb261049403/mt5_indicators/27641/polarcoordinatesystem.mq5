//+------------------------------------------------------------------+
//|                                        PolarCoordinateSystem.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                         https://www.mql5.com/en/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Nikolay Semko"
#property link      "https://www.mql5.com/ru/users/nikolay7ko"
#property link      "SemkoNV@bk.ru"
#property version   "1.00"
#property indicator_chart_window
#include <Canvas\iCanvas.mqh> //https://www.mql5.com/ru/code/22164
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

double cl[];
datetime ti[];
int per;
double N=0.3;
bool day=false;
bool mouse=true;
double min, max;
int start=0;
iCanvas info(0,0,0,"iCanvas_info",200,20);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   per=24*60;
   ChartSetInteger(0,CHART_SHOW,false);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ChartSetInteger(0,CHART_SHOW,true);
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
                const int &spread[]) {
   int d=rates_total-prev_calculated;
   if (d>1 || d<0) {
      ArrayCopy(cl,close);
      ArrayCopy(ti,time);
      Draw();
   } else {
      if (d==1) {
         ArrayResize(cl,rates_total);
         ArrayResize(ti,rates_total);
      }
      cl[rates_total-1]=close[rates_total-1];
      ti[rates_total-1]=time[rates_total-1];
      //Draw();
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   static bool click =false;
   if (sparam=="1")  {  // press left button of mouse
      if (!click) {
         if (mouse) mouse = false;
         else mouse=true;
         click=true;
      }
   } else click=false;
   if (sparam=="32") {  // press D
      if (!click) {
         if (day) day = false;
         else day=true;
         click=true;
         Draw();
      }
   } else click=false;
   if (id==CHARTEVENT_MOUSE_MOVE && mouse) {
      if (!day) per = 24*60 + W.MouseY*60;
      else per=24*60*PeriodSeconds();
      N=double(_MouseX)/_Width;
      Draw();
   }
   if (id==CHARTEVENT_MOUSE_MOVE) {
      int X=_Width/2;
      int Y=_Height/2-5;
      int r=_Height/2-7;
      double dd=sqrt((_MouseX-X)*(_MouseX-X)+(_MouseY-Y)*(_MouseY-Y));
      info.Erase(0);
      if (dd<r && dd>r*0.3) {
         info.MoveCanvas(_MouseX+3,_MouseY-10);
         info.TextPosition(0,0);
         info.Comm(DoubleToString(min+(max-min)*(dd-r*0.3)/(r*0.7),(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)));
      } else if (_MouseY>_Height-20) {
         int xx=(_MouseX<_Width-160)?_MouseX:_MouseX-160;
         info.MoveCanvas(xx,_Height-25);
         info.TextPosition(0,0);
         info.Comm(TimeToString(ti[start+int((ArraySize(ti)-start)*double(_MouseX)/_Width)]));
      }
      info.Update();
   }
}
//+------------------------------------------------------------------+
void Draw() {
   int X=_Width/2;
   int Y=_Height/2-5;
   int size=ArraySize(cl);
   Canvas.Erase();
   start=int(size*N);
   if (start>=size) start = size-1;
   max = cl[ArrayMaximum(cl,start)];
   min = cl[ArrayMinimum(cl,start)];
   if (max-min<=0) return;
   int nn=0;
   double c=0;
   for (int i=start; i<size; i++) {
      double r = (_Height/2-7)*(0.3+0.7*(cl[i]-min)/(max-min));
      double a;
      if (day) a= 2*M_PI*double(ti[i]%per)/per-M_PI_2;
      else     a= 2*M_PI*double(i%per)/per-M_PI_2;
      double cc=cos(a);
      if (c<0 && cc>=0) nn++;
      c=cc;
      int x = Round(X+c*r);
      int y = Round(Y+sin(a)*r);
      _PixelSet(x,y,Grad(double(i-start)/(size-start)));
   }
   _CommXY(50,70,_Symbol);
   _Comment("Total "+string(nn)+" Circles");
   if (day) _Comment("Circle period = " + string(per/86400)+" days");
   else _Comment("Circle period = " + string(per)+" bars");
   _Comment("Start date = "+string(ti[start]));
   for (int i=0; i<_Width; i++) Canvas.LineVertical(i,_Height-1,_Height-10,Grad(double(i)/_Width));
   Canvas.Update();
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint Grad(double p) {
   static uint Col[6]= {0xFF0000FF,0xFFFF00FF,0xFFFF0000,0xFFFFFF00,0xFF00FF00,0xFF00FFFF};
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

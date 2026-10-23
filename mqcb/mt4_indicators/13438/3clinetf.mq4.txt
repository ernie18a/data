//+------------------------------------------------------------------+
//|                                                       3CLine.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
double X[],Y[],X0[],Y0[];
string C3X="C3X",C3Y="C3Y";
//---
input int TF=0;
input bool BreakOnly=true;
//---
int BBar=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(C3X);
   ObjectDelete(C3Y);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,X);
   SetIndexBuffer(1,Y);
   SetIndexBuffer(2,X0);
   SetIndexBuffer(3,Y0);
//---
   SetIndexStyle(0,DRAW_SECTION,STYLE_DOT,1,clrRoyalBlue);
   SetIndexStyle(1,DRAW_SECTION,STYLE_DOT,1,clrOrangeRed);
   SetIndexStyle(2,DRAW_SECTION,STYLE_SOLID,3,clrOrangeRed);
   SetIndexStyle(3,DRAW_SECTION,STYLE_SOLID,3,clrRoyalBlue);
//---
   if(TF==0)
     {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_SECTION,STYLE_SOLID,1,clrOrangeRed);
      SetIndexStyle(3,DRAW_SECTION,STYLE_SOLID,1,clrRoyalBlue);
     }
//---
   C3X=C3X+(string)TF;
   C3Y=C3Y+(string)TF;
//---
   return(INIT_SUCCEEDED);
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
   if(TF!=0 && TF<_Period) {OnDeinit(0);return(0);}
//---
   ArrayInitialize(X,EMPTY_VALUE);
   ArrayInitialize(Y,EMPTY_VALUE);
   ArrayInitialize(X0,EMPTY_VALUE);
   ArrayInitialize(Y0,EMPTY_VALUE);
//---
   int j1=0,j3=0;
//--- Уровень разворота вверх      
   j1=DnBars(TF,1);
   j3=DnBars(TF,3);
//---
   j1=iBarShift(_Symbol,_Period,iTime(_Symbol,TF,j1));
   j3=iBarShift(_Symbol,_Period,iTime(_Symbol,TF,j3));
   datetime tx=time[j3];
//---
   X[j3]=DnValues(TF,3);
   X[0]=X[j3];
//---
   X0[j3]=X[j3];
   X0[j1]=DnValues(TF,1);
//--- Уровень разворота вниз      
   j1=UpBars(TF,1);
   j3=UpBars(TF,3);
//---
   j1=iBarShift(_Symbol,_Period,iTime(_Symbol,TF,j1));
   j3=iBarShift(_Symbol,_Period,iTime(_Symbol,TF,j3));
   datetime ty=time[j3];
//---
   Y[j3]=UpValues(TF,3);
   Y[0]=Y[j3];
//---
   Y0[j3]=Y[j3];
   Y0[j1]=UpValues(TF,1);
//---
   if(TF==0) Draw(tx,ty);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw(datetime t1,datetime t2)
  {
//---
   double a=MarketInfo(_Symbol,MODE_ASK);
   double b=MarketInfo(_Symbol,MODE_BID);
   double XX0=X[0]+a-b;
   double YY0=Y[0];
//---
   datetime t=TimeCurrent();
   ObjectCreate(C3X,OBJ_TREND,0,0,0,0,0);
   ObjectSet(C3X,OBJPROP_TIME1,t1);
   ObjectSet(C3X,OBJPROP_TIME2,t);
   ObjectSet(C3X,OBJPROP_PRICE1,XX0);
   ObjectSet(C3X,OBJPROP_PRICE2,XX0);
   ObjectSet(C3X,OBJPROP_COLOR,clrRoyalBlue);
   ObjectSet(C3X,OBJPROP_STYLE,STYLE_DASH);
//---
   ObjectCreate(C3Y,OBJ_TREND,0,0,0,0,0);
   ObjectSet(C3Y,OBJPROP_TIME1,t2);
   ObjectSet(C3Y,OBJPROP_TIME2,t);
   ObjectSet(C3Y,OBJPROP_PRICE1,YY0);
   ObjectSet(C3Y,OBJPROP_PRICE2,YY0);
   ObjectSet(C3Y,OBJPROP_COLOR,clrOrangeRed);
   ObjectSet(C3Y,OBJPROP_STYLE,STYLE_DASH);
  }
//---
int DnBars(int tf, int i) {return((int)iCustom(_Symbol,tf,"3CLine",BreakOnly,0,i));}
int UpBars(int tf, int i) {return((int)iCustom(_Symbol,tf,"3CLine",BreakOnly,1,i));}
double DnValues(int tf,int i) {return(iCustom(_Symbol,tf,"3CLine",BreakOnly,2,i));}
double UpValues(int tf,int i) {return(iCustom(_Symbol,tf,"3CLine",BreakOnly,3,i));}
//+------------------------------------------------------------------+

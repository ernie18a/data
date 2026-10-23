//+------------------------------------------------------------------+
//|                                                 Engulfing_MA.mq4 |
//|                                  Copyright 2020, Andi Goen Corp. |
//|                                         https://fb.com/andi.goen |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andi Goen Corp."
#property link      "https://fb.com/andi.goen"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property indicator_width1 1
#property indicator_width2 1

input int    Period_MA              = 13;
input int    Shift_MA               = 0;
input ENUM_MA_METHOD MA_Method      = MODE_EMA;
input ENUM_APPLIED_PRICE  MA_Price  = PRICE_CLOSE;
extern bool  AlertON                = false;
extern color colorBulls             = clrBlue;
extern color colorBears             = clrRed;
extern bool  DrawCandle             = true;

double BufferUP[];
double BufferLOW[];
int candle[];
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexArrow(1,242);
   SetIndexBuffer(0,BufferUP);
   SetIndexBuffer(1,BufferLOW);
   SetIndexLabel(0,"UP");
   SetIndexLabel(1,"DOWN");
   SetIndexEmptyValue(0,0.0);
   IndicatorShortName("Engulfing");
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,OBJ_TREND);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int S;
   string NameFigur;
   if(counted_bars>0)
      counted_bars--;
   int limit=Bars-counted_bars;
   for(int i=0; i<limit-1; i++)
     {
      S=Figura(i);
      switch(S)
        {
         case 1:
            BufferUP[i]=Low[i]-(20*Point);

            break;
         case -1:
            BufferLOW[i]=High[i]+(20*Point);

            break;
        }
      if(AlertON && i==0 && S!=0)
         Alert(Symbol()+" Engulfing = "+NameFigur);
     }
   return(0);
  }
//-------------------------------------------------------------------
int Redraw(int bar,color col,string name)
  {
   if(!DrawCandle)
      return(0);
   name=StringConcatenate(name," ",TimeToStr(Time[bar],TIME_DATE|TIME_SECONDS));
   ObjectCreate(name,OBJ_TREND,0,Time[bar],High[bar],Time[bar],Low[bar]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   name=StringConcatenate(name," o");
   ObjectCreate(name,OBJ_TREND,0,Time[bar+1],Open[bar],Time[bar],Open[bar]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   name=StringConcatenate(name," c");
   ObjectCreate(name,OBJ_TREND,0,Time[bar],Close[bar],Time[bar]+Period()*60,Close[bar]);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(name,OBJPROP_BACK,false);
   ObjectSet(name,OBJPROP_RAY,false);
   ObjectSet(name,OBJPROP_WIDTH,2);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Figura(int bar)
  {
   double MA131 = iMA(Symbol(),PERIOD_CURRENT,Period_MA,Shift_MA,MA_Method,MA_Price,bar+1);
   double MA130 = iMA(Symbol(),PERIOD_CURRENT,Period_MA,Shift_MA,MA_Method,MA_Price,bar);
//-----------------------------------------
   if(High[bar+1]<High[bar] && Low[bar+1]>Close[bar] &&
      Open[bar+1]<Close[bar+1] && Open[bar]>Close[bar] && (Open[bar]>MA130 && Close[bar]<MA130) && (Open[bar+1]<MA131 && Close[bar+1]>MA131))
     {
      return(-1);//sell
     }
   if(Low[bar+1]>Low[bar] && High[bar+1]<Close[bar] &&
      Open[bar+1]>Close[bar+1] && Open[bar]<Close[bar] && (Open[bar]<MA130 && Close[bar]>MA130) && (Open[bar+1]>MA131 && Close[bar+1]<MA131))
     {
      return(1);//buy
     }
   return(0);
  }
//-------------------------------------------------------------------

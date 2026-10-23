//+------------------------------------------------------------------+
//|                                               Waddah Attar Pivot |
//|                               Copyright © 2007, ww.metaforex.net |
//|                                   Waddah Attar www.metaforex.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, www.metaforex.net"
#property link      "www.metaforex.net"
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_color8 Red
//---- buffers
double P1Buffer[];
double P2Buffer[];
double P3Buffer[];
double P4Buffer[];
double P5Buffer[];
double P6Buffer[];
double P7Buffer[];
double P8Buffer[];
//----
int myPeriod = PERIOD_D1;
//----
double PP, R4, S4, R5, S5, R6, S6, R7, S7, Q;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, P1Buffer);
   SetIndexBuffer(1, P2Buffer);
   SetIndexBuffer(2, P3Buffer);
   SetIndexBuffer(3, P4Buffer);
   SetIndexBuffer(4, P5Buffer);
   SetIndexBuffer(5, P6Buffer);
   SetIndexBuffer(6, P7Buffer);
   SetIndexBuffer(7, P8Buffer);
//----   
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(7, DRAW_LINE, STYLE_SOLID, 1);
//----   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("DayR4");
   ObjectDelete("DayR5");
   ObjectDelete("DayR6");
   ObjectDelete("DayR7");
//----
   ObjectDelete("DayS4");
   ObjectDelete("DayS5");
   ObjectDelete("DayS6");
   ObjectDelete("DayS7");
//----
   ObjectDelete("txtDayR4");
   ObjectDelete("txtDayR5");
   ObjectDelete("txtDayR6");
   ObjectDelete("txtDayR7");
//----   
   ObjectDelete("txtDayS4");
   ObjectDelete("txtDayS5");
   ObjectDelete("txtDayS6");
   ObjectDelete("txtDayS7");
//----   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i, dayi, counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;  
   int limit = Bars - counted_bars;
//----   
   for(i = limit - 1; i >= 0; i--)
     {
       dayi = iBarShift(Symbol(), myPeriod, Time[i], false);
       Q = (iHigh(Symbol(), myPeriod,dayi+1) - iLow(Symbol(), myPeriod, 
            dayi + 1));
       //----
       PP=(iHigh(Symbol(), myPeriod, dayi + 1) + 
           iLow(Symbol(), myPeriod, dayi + 1) +
           iClose(Symbol(), myPeriod, dayi + 1) +
           iOpen(Symbol(), myPeriod,dayi)) / 4;
       //----    
       R4 = PP + (Q * 0.62);
       S4 = PP - (Q * 0.62);
       //----
       R5 = PP + (Q * 0.76);
       S5 = PP - (Q * 0.76);
       //----
       R6 = PP + (Q * 1);
       S6 = PP - (Q * 1);
       //----
       R7 = PP + (Q * 1.23);
       S7 = PP - (Q * 1.23);

       P1Buffer[i] = R4;
       SetPrice("DayR4", Time[i], R4, Green);
       SetText("txtDayR4", "R4", Time[i], R4, Green);
       //----
       P2Buffer[i] = S4;
       SetPrice("DayS4", Time[i], S4, Red);
       SetText("txtDayS4", "S4", Time[i], S4, Red);
       //----
       P3Buffer[i] = R5;
       SetPrice("DayR5", Time[i], R5, Green);
       SetText("txtDayR5", "R5", Time[i], R5, Green);
       //----
       P4Buffer[i] = S5;
       SetPrice("DayS5", Time[i], S5, Red);
       SetText("txtDayS5", "S5", Time[i], S5, Red);
       //----
       P5Buffer[i] = R6;
       SetPrice("DayR6", Time[i], R6, Green);
       SetText("txtDayR6", "R6", Time[i], R6, Green);
       //----
       P6Buffer[i] = S6;
       SetPrice("DayS6", Time[i], S6, Red);
       SetText("txtDayS6", "S6", Time[i], S6, Red);
       //----
       P7Buffer[i] = R7;
       SetPrice("DayR7", Time[i], R7, Green);
       SetText("txtDayR7", "R7", Time[i], R7, Green);
       //----
       P8Buffer[i] = S7;
       SetPrice("DayS7", Time[i], S7, Red);
       SetText("txtDayS7", "S7", Time[i], S7, Red);
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPrice(string name, datetime Tm, double Prc, color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_ARROW, 0, Tm, Prc);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_WIDTH, 1);
       ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, Tm);
       ObjectSet(name, OBJPROP_PRICE1, Prc);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_WIDTH, 1);
       ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
     } 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(string name,string txt, datetime Tm, double Prc, color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_TEXT, 0, Tm, Prc);
       ObjectSetText(name, txt, 10, "Times New Roman", clr);
       ObjectSet(name, OBJPROP_CORNER, 2);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, Tm);
       ObjectSet(name, OBJPROP_PRICE1, Prc);
       ObjectSetText(name, txt, 10, "Times New Roman", clr);
       ObjectSet(name, OBJPROP_CORNER, 2);
     } 
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                               XIT_FIBS_mod_1.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//|                                                                  |
//| File45: Added Jan 2017                                           |
//| input color LC = DodgerBlue; // Fib Line Color                   |
//| input ENUM_LINE_STYLE LS = 2; // Fib Line Style                  |
//| input int LW = 1; // Fib Line Width                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                    XIT_FIBS.mq4  |
//|                         Copyright © 2011, Jeff West - Forex-XIT  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Automatically draws fibonacci retracements on chart." 
#property strict
#property indicator_chart_window

input color LC = DodgerBlue; // Fib Line Color 
input ENUM_LINE_STYLE LS = 2; // Fib Line Style
input int LW = 1; // Fib Line Width

color levelColor;

int OnInit()
  {   
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
   ObjectDelete("XIT_FIBO");
  }    

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
     int fibHigh = iHighest(Symbol(),Period(),MODE_HIGH,WindowFirstVisibleBar()-1,1);
     int fibLow  = iLowest(Symbol(),Period(),MODE_LOW,WindowFirstVisibleBar()-1,1);
     
     datetime highTime = Time[fibHigh];
     datetime lowTime  = Time[fibLow];
     
     if(fibHigh>fibLow)
     {
       WindowRedraw();
       ObjectCreate("XIT_FIBO",OBJ_FIBO,0,highTime,High[fibHigh],lowTime,Low[fibLow]);
       levelColor = LC;
     }
      else
     {
       WindowRedraw();
       ObjectCreate("XIT_FIBO",OBJ_FIBO,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
       levelColor = LC;
     }
      
     double fiboPrice1=ObjectGet("XIT_FIBO",OBJPROP_PRICE1);
     double fiboPrice2=ObjectGet("XIT_FIBO",OBJPROP_PRICE2);
      
     /*double fiboPriceDiff = fiboPrice2-fiboPrice1;
     string fiboValue0 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.0,Digits);
     string fiboValue23 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.236,Digits);
     string fiboValue38 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.382,Digits);
     string fiboValue50 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.50,Digits);
     string fiboValue61 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.618,Digits);
     string fiboValue100 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.0,Digits);*/
    
     ObjectSet("XIT_FIBO",OBJPROP_FIBOLEVELS,6);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+0,0.0);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+1,0.236);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+2,0.382);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+3,0.50);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+4,0.618);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+5,1.0);
     
     ObjectSet("XIT_FIBO",OBJPROP_LEVELCOLOR,levelColor);
     ObjectSet("XIT_FIBO",OBJPROP_LEVELWIDTH,LW);
     ObjectSet("XIT_FIBO",OBJPROP_LEVELSTYLE,LS);
     
     /*ObjectSetFiboDescription( "XIT_FIBO", 0,fiboValue0+" --> 0.0%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 1,fiboValue23+" --> 23.6%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 2,fiboValue38+" --> 38.2%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 3,fiboValue50+" --> 50.0%");
     ObjectSetFiboDescription( "XIT_FIBO", 4,fiboValue61+" --> 61.8%");
     ObjectSetFiboDescription( "XIT_FIBO", 5,fiboValue100+" --> 100.0%");*/
     
     ObjectSetFiboDescription( "XIT_FIBO",0, "0,0.0%"); 
     ObjectSetFiboDescription( "XIT_FIBO",1, "23.6%"); 
     ObjectSetFiboDescription( "XIT_FIBO",2, "38.2%"); 
     ObjectSetFiboDescription( "XIT_FIBO",3, "50.0%");
     ObjectSetFiboDescription( "XIT_FIBO",4, "61.8%");
     ObjectSetFiboDescription( "XIT_FIBO",5, "100.0%");
   
     return(rates_total);
  }
 
//+------------------------------------------------------------------+
//|                                            AutoFibsLineMrVB.mq4  |
//|                                          Copyright © 2018, MrVb  |
//|                                           http://www.iasiweb.ro  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, MrVB"
#property link      "http://www.iasiweb.ro"

#property indicator_chart_window

extern color levelColor=LightGray;   //Lines color
extern int   searchBars=24;   //Number of bars
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("FIBLINE");
   ObjectDelete("FIBTRENDLINE1");
   ObjectDelete("FIBTRENDLINE2");
   ObjectDelete("FIBTRENDLINE3");
   ObjectDelete("FIBTRENDLINE4");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----

   int fibHigh = iHighest(Symbol(), Period(), MODE_HIGH, searchBars,1);
   int fibLow  = iLowest(Symbol(), Period(), MODE_LOW, searchBars,1);

   datetime highTime = Time[fibHigh];
   datetime lowTime  = Time[fibLow];

   if(fibHigh>fibLow)
     {
      WindowRedraw();
      ObjectCreate("FIBLINE",OBJ_FIBO,0,highTime,High[fibHigh],lowTime,Low[fibLow]);
     }
   else
     {
      WindowRedraw();
      ObjectCreate("FIBLINE",OBJ_FIBO,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
     }

   double fiboPrice1=ObjectGet("FIBLINE",OBJPROP_PRICE1);
   double fiboPrice2=ObjectGet("FIBLINE",OBJPROP_PRICE2);

   double fiboPriceDiff=fiboPrice2-fiboPrice1;

   string fiboValue0=DoubleToStr(fiboPrice2-fiboPriceDiff*0.0,Digits);
   string fiboValue14 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.146,Digits);
   string fiboValue23 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.236,Digits);
   string fiboValue38 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.382,Digits);
   string fiboValue50 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.50,Digits);
   string fiboValue61 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.618,Digits);
   string fiboValue76 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.764,Digits);
   string fiboValue100 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.0,Digits);
   string fiboValue123 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.236,Digits);
   string fiboValue138 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.382,Digits);
   string fiboValue150 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.50,Digits);
   string fiboValue161 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.618,Digits);

   ObjectSet("FIBLINE",OBJPROP_FIBOLEVELS,12);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+0,0.0);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+1,0.146);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+2,0.236);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+3,0.382);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+4,0.50);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+5,0.618);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+6,0.764);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+7,1.0);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+8,1.236);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+9,1.382);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+10,1.50);
   ObjectSet("FIBLINE",OBJPROP_FIRSTLEVEL+11,1.618);

   ObjectSet("FIBLINE",OBJPROP_LEVELCOLOR,levelColor);
   ObjectSet("FIBLINE",OBJPROP_LEVELWIDTH,1);
   ObjectSet("FIBLINE",OBJPROP_LEVELSTYLE,STYLE_DASHDOTDOT);

   ObjectSetFiboDescription("FIBLINE",0,fiboValue0+" --> 0.0%");
   ObjectSetFiboDescription("FIBLINE",1,fiboValue14+" --> 14.6%");
   ObjectSetFiboDescription("FIBLINE",2,fiboValue23+" --> 23.6%");
   ObjectSetFiboDescription("FIBLINE",3,fiboValue38+" --> 38.2%");
   ObjectSetFiboDescription("FIBLINE",4,fiboValue50+" --> 50.0%");
   ObjectSetFiboDescription("FIBLINE",5,fiboValue61+" --> 61.8%");
   ObjectSetFiboDescription("FIBLINE",6,fiboValue76+" --> 76.4%");
   ObjectSetFiboDescription("FIBLINE",7,fiboValue100+" --> 100.0%");
   ObjectSetFiboDescription("FIBLINE",8,fiboValue123+" --> 123.6%");
   ObjectSetFiboDescription("FIBLINE",9,fiboValue138+" --> 138.2%");
   ObjectSetFiboDescription("FIBLINE",10,fiboValue150+" --> 150.0%");
   ObjectSetFiboDescription("FIBLINE",11,fiboValue161+" --> 161.8%");

   ObjectCreate(0,"FIBTRENDLINE1",OBJ_HLINE,0,Time[fibHigh],High[fibHigh],0,0);
   ObjectCreate(0,"FIBTRENDLINE2",OBJ_HLINE,0,Time[fibLow],Low[fibLow],0,0);
   ObjectCreate(0,"FIBTRENDLINE3",OBJ_VLINE,0,Time[fibHigh],High[fibHigh],0,0);
   ObjectCreate(0,"FIBTRENDLINE4",OBJ_VLINE,0,Time[fibLow],Low[fibLow],0,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+

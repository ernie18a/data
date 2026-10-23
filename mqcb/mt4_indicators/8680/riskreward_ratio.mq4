//+------------------------------------------------------------------+
//|                                          Risk / Reward Ratio.mq4 |
//|                                                   Bruno Gaiteiro |
//|                                              bgaiteiro@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, bgaiteiro"
#property link      "bgaiteiro@gmail.com"

#property indicator_chart_window
//---- input parameters
extern string    SLLevel="SLPrice";
extern string    TPLevel="TPPrice";
extern string note2="Default Font Color";
extern color  FontColor=Black;
extern string note3="Font Size";
extern int    FontSize=20;
extern string note4="Font Type";
extern string FontType="Trebuchet MS";
extern string note5 = "Display the price in what corner?";
extern string note6 = "Upper left=0; Upper right=1";
extern string note7 = "Lower left=2; Lower right=3";
extern int    WhatCorner=2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("TSR");

   if(ObjectFind(SLLevel)==-1)
     {
      ObjectCreate(SLLevel,OBJ_HLINE,0,0,Close[0]);
      ObjectSet(SLLevel,OBJPROP_COLOR,Red);
     }
   if(ObjectFind(TPLevel)==-1)
     {
      ObjectCreate(TPLevel,OBJ_HLINE,0,0,Close[0]);
      ObjectSet(TPLevel,OBJPROP_COLOR,Green);
     }

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete(SLLevel);
   ObjectDelete(TPLevel);
   ObjectDelete("RiskReward_ratio");
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----

   double   RiskReward_ratio=0,SL_price=0,TP_price=0;
   string   Text="";
   int i=0;

   if(ObjectFind(SLLevel)==-1) return(0);
   SL_price=ObjectGet(SLLevel,OBJPROP_PRICE1);
   if(ObjectFind(TPLevel)==-1) return(0);
   TP_price=ObjectGet(TPLevel,OBJPROP_PRICE1);

 
   if((Bid-SL_price)!=0)
     {
      RiskReward_ratio=(TP_price-Bid)/(Bid-SL_price);
     }

   Text="Risk/Reward Ratio       1 : "+DoubleToStr(RiskReward_ratio,2)+"\n";

   Comment(Text);

   string RiskReward_ratio2=DoubleToStr(RiskReward_ratio,2);
   ObjectCreate("RiskReward_ratio",OBJ_LABEL,0,0,0);
   ObjectSetText("RiskReward_ratio","1 : "+RiskReward_ratio2,FontSize,FontType,FontColor);
   ObjectSet("RiskReward_ratio",OBJPROP_CORNER,WhatCorner);
   ObjectSet("RiskReward_ratio",OBJPROP_XDISTANCE,10);
   ObjectSet("RiskReward_ratio",OBJPROP_YDISTANCE,10);

   return(0);
  }
//+------------------------------------------------------------------+

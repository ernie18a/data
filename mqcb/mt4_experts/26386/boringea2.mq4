//+------------------------------------------------------------------+
//|                                                   boring-ea2.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict

#define CANDLE_BEFORE 1
#define CANDLE_AFTER  0

int max_ticks;
int ticks;

bool ma003_crossed_up_ma020;
bool ma003_crossed_up_ma150;
bool ma020_crossed_up_ma150;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   max_ticks=100;
   ticks=0;
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   ++ticks;
   if(ticks==max_ticks)
     {
      check_pattern();
      ticks=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void check_pattern()
  {
   double ma003_before = iMA(Symbol(),Period(),  3,0,MODE_SMA,PRICE_CLOSE,CANDLE_BEFORE);
   double ma003_after  = iMA(Symbol(),Period(),  3,0,MODE_SMA,PRICE_CLOSE,CANDLE_AFTER );
   double ma020_before = iMA(Symbol(),Period(), 20,0,MODE_SMA,PRICE_CLOSE,CANDLE_BEFORE);
   double ma020_after  = iMA(Symbol(),Period(), 20,0,MODE_SMA,PRICE_CLOSE,CANDLE_AFTER );
   double ma150_before = iMA(Symbol(),Period(),150,0,MODE_SMA,PRICE_CLOSE,CANDLE_BEFORE);
   double ma150_after  = iMA(Symbol(),Period(),150,0,MODE_SMA,PRICE_CLOSE,CANDLE_AFTER );

   if(ma003_before>ma020_before && ma003_after<ma020_after && ma003_crossed_up_ma020==true)
     {
      ma003_crossed_up_ma020=false;
      //Alert( "Alert!!! - " + Symbol() + " - MA003 crossed down MA020" );
      SendNotification("Alert!!! - "+Symbol()+" - "+getPeriod()+" - MA003 crossed down MA020");
     }

   if(ma003_before<ma020_before && ma003_after>ma020_after && ma003_crossed_up_ma020==false)
     {
      ma003_crossed_up_ma020=true;
      //Alert( "Alert!!! - " + Symbol() + " - MA003 crossed up MA020" );
      SendNotification("Alert!!! - "+Symbol()+" - "+getPeriod()+" - MA003 crossed up MA020");
     }

   if(ma003_before>ma150_before && ma003_after<ma150_after && ma003_crossed_up_ma150==true)
     {
      ma003_crossed_up_ma150=false;
      //Alert( "Alert!!! - " + Symbol() + " - MA003 crossed down MA150" );
      SendNotification("Alert!!! - "+Symbol()+" - "+getPeriod()+" - MA003 crossed down MA150");
     }

   if(ma003_before<ma150_before && ma003_after>ma150_after && ma003_crossed_up_ma150==false)
     {
      ma003_crossed_up_ma150=true;
      //Alert( "Alert!!! - " + Symbol() + " - MA003 crossed up MA150" );
      SendNotification("Alert!!! - "+Symbol()+" - "+getPeriod()+" - MA003 crossed up MA150");
     }

   if(ma020_before>ma150_before && ma020_after<ma150_after && ma020_crossed_up_ma150==true)
     {
      ma020_crossed_up_ma150=false;
      //Alert( "Alert!!! - " + Symbol() + " - MA020 crossed down MA150" );
      SendNotification("Alert!!! - "+Symbol()+" - "+getPeriod()+" - MA020 crossed down MA150");
     }

   if(ma020_before<ma150_before && ma020_after>ma150_after && ma020_crossed_up_ma150==false)
     {
      ma020_crossed_up_ma150=true;
      //Alert( "Alert!!! - " + Symbol() + " - MA020 crossed up MA150" );
      SendNotification("Alert!!! - "+Symbol()+" - "+getPeriod()+" - MA020 crossed up MA150");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getPeriod()
  {

   switch(Period())
     {
      case PERIOD_M1:
         return "M1";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN";
      default:
         return "TF?";
         break;
     }

  }

//+------------------------------------------------------------------+

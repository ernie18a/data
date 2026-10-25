//+------------------------------------------------------------------+
//| MarginCallRadarTests.mq5                                         |
//| Copyright 2026, Serhii Semenov                                   |
//| https://www.mql5.com/en/users/ssemenov                           |
//+------------------------------------------------------------------+
#property copyright "Serhii Semenov"
#property link      "https://www.mql5.com/en/users/ssemenov"
#property version   "1.03"
#property description "Self-test of the Margin Call Radar calculations (RadarCore.mqh)."
#property description "Attach to any chart: prints the result to the Experts log and shows it on the chart."
#property indicator_chart_window
#property indicator_plots 0

#include "RadarCore.mqh"

int g_failures=0;

//+------------------------------------------------------------------+
//| Counts and prints a failed check                                 |
//+------------------------------------------------------------------+
void Check(const bool condition,const string message)
  {
   if(!condition)
     {
      g_failures++;
      PrintFormat("FAIL: %s",message);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function: runs the self-test     |
//+------------------------------------------------------------------+
int OnInit()
  {
   Check(MathAbs(LevelPercent(10000.0,1000.0)-1000.0)<1e-9,"margin level 1000 percent");
   Check(MathAbs(LevelPercent(10000.0,0.0))<1e-9,"margin level with no margin");
   Check(MathAbs(LevelPercent(0.0,1000.0))<1e-9,"margin level with zero equity");

   Check(MathAbs(TargetEquity(50.0,1000.0,false)-500.0)<1e-9,"target equity percent");
   Check(MathAbs(TargetEquity(500.0,1000.0,true)-500.0)<1e-9,"target equity money");

   Check(MathAbs(LevelTargetPercent(50.0,1000.0,false)-50.0)<1e-9,"level target percent passthrough");
   Check(MathAbs(LevelTargetPercent(500.0,1000.0,true)-50.0)<1e-9,"level target money to percent");

   Check(MathAbs(MoneyToTarget(10000.0,1000.0,50.0,false)-9500.0)<1e-9,"money to level");
   Check(MathAbs(PercentToTarget(10000.0,1000.0,50.0,false)-95.0)<1e-9,"percent to level");
   Check(MathAbs(PercentToTarget(0.0,1000.0,50.0,false))<1e-9,"percent to level zero equity");

   Check(MathAbs(PointsForMoney(500.0,5.0)-100.0)<1e-9,"points for money");
   Check(MathAbs(PointsForMoney(500.0,0.0))<1e-9,"points for money zero value guard");

   Check(MathAbs(EquityAfterLoss(10000.0,5000.0)-5000.0)<1e-9,"equity after loss");
   Check(MathAbs(LevelAfterLoss(10000.0,2000.0,5000.0)-250.0)<1e-9,"level after loss");

   Check(MathAbs(PointValueFromTick(1.0,0.00001,0.00001)-1.0)<1e-9,"point value tick equals point");
   Check(MathAbs(PointValueFromTick(1.0,0.001,0.01)-10.0)<1e-9,"point value tick to point scale");
   Check(MathAbs(PointValueFromTick(1.0,0.0,0.01))<1e-9,"point value zero tick size guard");

   Check(MathAbs(PointsForPriceMove(1.1236,1.0,0.00001)-1123.6)<1e-6,"points for one percent price move");
   Check(MathAbs(PointsForPriceMove(1.1236,0.0,0.00001))<1e-9,"points for price move zero percent guard");
   Check(MathAbs(PointsForPriceMove(1.1236,1.0,0.0))<1e-9,"points for price move zero point guard");
   Check(MathAbs(0.01*PointsForPriceMove(1.1236,1.0,0.00001)-11.236)<1e-6,"price move loss on 0.01 lot");

   // netting itself: exposure of one symbol is signed, buy +, sell -
   Check(MathAbs(AddExposure(0.0,1.0,1.0)-1.0)<1e-9,"buy adds exposure");
   Check(MathAbs(AddExposure(0.0,-1.0,1.0)+1.0)<1e-9,"sell subtracts exposure");
   Check(MathAbs(AddExposure(1.0,-1.0,1.0))<1e-9,"buy and sell of same symbol net to zero");
   Check(MathAbs(AddExposure(1.0,-1.0,0.5)-0.5)<1e-9,"partial hedge keeps the difference");

   // exposures are already netted per symbol by CollectExposure
   double hedge_exp[1]={0.0};
   double same_exp[1] ={2.0};
   double part_exp[1] ={0.5};
   double two_sym[2]  ={1.0,-1.0};
   double move_one[1] ={100.0};
   double move_two[2] ={100.0,100.0};
   Check(MathAbs(HedgeAwareLoss(hedge_exp,move_one))<1e-9,"hedged book nets to zero loss");
   Check(MathAbs(HedgeAwareLoss(same_exp,move_one)-200.0)<1e-9,"same direction adds up");
   Check(MathAbs(HedgeAwareLoss(part_exp,move_one)-50.0)<1e-9,"partial hedge nets to half");
   Check(MathAbs(HedgeAwareLoss(two_sym,move_two)-200.0)<1e-9,"different symbols do not offset");

   double book=10.0;
   double gap_loss=500.0*book;
   double gap_equity=EquityAfterLoss(10000.0,gap_loss);
   double gap_level=LevelAfterLoss(10000.0,2000.0,gap_loss);
   Check(MathAbs(gap_equity-5000.0)<1e-9 && MathAbs(gap_level-250.0)<1e-9,"gap scenario end to end");

   if(g_failures==0)
      Print("RadarCore: all checks passed");
   else
      PrintFormat("RadarCore: %d checks FAILED",g_failures);
   Comment(g_failures==0?"RadarCore: all checks passed":
           "RadarCore: "+IntegerToString(g_failures)+" checks FAILED");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function (not used)                   |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function: clears the result    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }

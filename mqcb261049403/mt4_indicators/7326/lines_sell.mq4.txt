//+------------------------------------------------------------------+
//|                                                    Lines_sell.mq4|
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                         http://pilot911.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, pilot@m-lan.ru"
#property link      "pilot@m-lan.ru"
//----
#property indicator_chart_window
//---- input parameters
extern double    StartFrom=1.20;
extern double    Step1=20;
extern double    Step2=40;
extern double    Step3=80;
extern double    Step4=80;
extern double    Step5=80;
extern double    Step6=80;
extern double    Step7=80;
extern double    Step8=80;
extern double    Step9=80;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double   curr=NormalizeDouble(ObjectGet( "s_order0", OBJPROP_PRICE1),Digits);
//----
   ObjectSet( "s_order1", OBJPROP_PRICE1, curr-Step1*Point);
   ObjectSet( "s_order2", OBJPROP_PRICE1, curr-(Step1+Step2)*Point);
   ObjectSet( "s_order3", OBJPROP_PRICE1, curr-(Step1+Step2)*Point);
   ObjectSet( "s_order4", OBJPROP_PRICE1, curr-(Step1+Step2+Step3)*Point);
   ObjectSet( "s_order5", OBJPROP_PRICE1, curr-(Step1+Step2+Step3+Step4)*Point);
   ObjectSet( "s_order6", OBJPROP_PRICE1, curr-(Step1+Step2+Step3+Step4+Step5)*Point);
   ObjectSet( "s_order7", OBJPROP_PRICE1, curr-(Step1+Step2+Step3+Step4+Step5+Step6)*Point);
   ObjectSet( "s_order8", OBJPROP_PRICE1, curr-(Step1+Step2+Step3+Step4+Step5+Step6+Step7)*Point);
   ObjectSet( "s_order9", OBJPROP_PRICE1, curr-(Step1+Step2+Step3+Step4+Step5+Step6+Step7+Step8)*Point);
   ObjectSet( "s_order10", OBJPROP_PRICE1, curr-(Step1+Step2+Step3+Step4+Step5+Step6+Step7+Step8+Step9)*Point);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int init() 
  {
   ObjectCreate( "s_order0", OBJ_HLINE, 0, 0, StartFrom, 0, 0, 0, 0 );
   ObjectSet( "s_order0", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order1", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order1", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order2", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order2", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order3", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order3", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order4", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order4", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order5", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order5", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order6", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order6", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order7", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order7", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order8", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order8", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order9", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order9", OBJPROP_COLOR, Red );
   ObjectCreate( "s_order10", OBJ_HLINE, 0, 0, Ask, 0, 0, 0, 0 );
   ObjectSet( "s_order10", OBJPROP_COLOR, Red );
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete( "s_order0");
   ObjectDelete( "s_order1");
   ObjectDelete( "s_order2");
   ObjectDelete( "s_order3");
   ObjectDelete( "s_order4");
   ObjectDelete( "s_order5");
   ObjectDelete( "s_order6");
   ObjectDelete( "s_order7");
   ObjectDelete( "s_order8");
   ObjectDelete( "s_order9");
   ObjectDelete( "s_order10");
   return(0);
  }
//+------------------------------------------------------------------+
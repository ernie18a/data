//+------------------------------------------------------------------+
//|                                                       Levels.mq4 |
//|                                                             Maks |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Maks aka ug"
#property link      ""

#property indicator_chart_window

extern string Timeframe="D1";

extern color LineColor_sopr=Blue;
extern int LineWidth_sopr = 2;
extern int LineStyle_sopr = 0;

extern color LineColor_pod=DarkOrange;
extern int LineWidth_pod = 2;
extern int LineStyle_pod = 0;

//Служат для варианта расчета в зависимости от размеров предыдущей свечи (50 < X < 200, значит нормальный)
extern int high_diap= 200;
extern int low_diap = 50;

double close_price,high_price,low_price;
double R[6],S[6];
int PeriodName=0;
int diap=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if(Timeframe=="M1") PeriodName=PERIOD_M1;
   else
      if(Timeframe=="M5") PeriodName=PERIOD_M5;
   else
      if(Timeframe=="M15")PeriodName=PERIOD_M15;
   else
      if(Timeframe=="M30")PeriodName=PERIOD_M30;
   else
      if(Timeframe=="H1") PeriodName=PERIOD_H1;
   else
      if(Timeframe=="H4") PeriodName=PERIOD_H4;
   else
      if(Timeframe=="D1") PeriodName=PERIOD_D1;
   else
      if(Timeframe=="W1") PeriodName=PERIOD_W1;
   else
      if(Timeframe=="MN") PeriodName=PERIOD_MN1;
   else
     {
      return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i=1; i<=5; i++)
     {
      ObjectDelete("Lines"+i);
      ObjectDelete("Linep"+i);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   close_price=iClose(NULL,PeriodName,1);
   high_price=iHigh(NULL,PeriodName,1);
   low_price=iLow(NULL,PeriodName,1);

   if(high_price - low_price> high_diap) diap = 1;
   if(high_price - low_price < low_diap) diap = 2;

   if(diap==1)
     {
      //Суженный
      S[1] = close_price - ((high_price - low_price)*0.146)/2;
      R[1] = ((high_price - low_price)*0.146)/2 + close_price;
      R[2] = ((high_price - low_price)*0.236)+R[1];
      R[3] = R[1]+2*((high_price - low_price)*0.236);
      R[4] = R[3] + (R[1] - S[1]);
      R[5] = R[4] + ((high_price - low_price)*0.236);
      S[2] = S[1] - ((high_price - low_price)*0.236);
      S[3] = S[1]- ((high_price - low_price)*0.236)*2;
      S[4] = S[3] - (R[1] - S[1]);
      S[5] = S[4] - ((high_price - low_price)*0.236);
     }

   if(diap==0)
     {
      //Нормальный
      S[1] = close_price - ((high_price - low_price)*0.236)/2;
      R[1] = ((high_price - low_price)*0.236)/2 + close_price;
      R[2] = ((high_price - low_price)*0.382)+R[1];
      R[3] = R[1]+2*((high_price - low_price)*0.382);
      R[4] = R[3] + (R[1] - S[1]);
      R[5] = R[4] + ((high_price - low_price)*0.382);
      S[2] = S[1] - ((high_price - low_price)*0.382);
      S[3] = S[1]-2*((high_price - low_price)*0.382);
      S[4] = S[3] - (R[1] - S[1]);
      S[5] = S[4] - ((high_price - low_price)*0.382);
     }

   if(diap==2)
     {
      //Расширенный
      S[1] = close_price - ((high_price - low_price)*0.382)/2;
      R[1] = ((high_price - low_price)*0.382)/2 + close_price;
      R[2] = ((high_price - low_price)*0.618)+R[1];
      R[3] = R[1]+2*((high_price - low_price)*0.618);
      R[4] = R[3] + (R[1] - S[1]);
      R[5] = R[4] + ((high_price - low_price)*0.618);
      S[2] = S[1] - ((high_price - low_price)*0.618);
      S[3] = S[1]-2*((high_price - low_price)*0.618);
      S[4] = S[3] - (R[1] - S[1]);
      S[5] = S[4] - ((high_price - low_price)*0.618);
     }

   for(int i=1; i<=5; i++)
     {
      ObjectCreate("Lines"+i,OBJ_HLINE,0,0,R[i]);
      ObjectSet("Lines"+i,OBJPROP_COLOR,LineColor_sopr);
      ObjectSet("Lines"+i,OBJPROP_WIDTH,LineWidth_sopr);
      ObjectSet("Lines"+i,OBJPROP_STYLE,LineStyle_sopr);

      ObjectCreate("Linep"+i,OBJ_HLINE,0,0,S[i]);
      ObjectSet("Linep"+i,OBJPROP_COLOR,LineColor_pod);
      ObjectSet("Linep"+i,OBJPROP_WIDTH,LineWidth_pod);
      ObjectSet("Linep"+i,OBJPROP_STYLE,LineStyle_pod);
     }
   return(0);
  }
//+------------------------------------------------------------------+

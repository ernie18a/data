//+----------------------------------------------------------+
//|                            Alternative_Ichimoku_v06.mq4  |
//|                 Copyright © february 2007          v.06  |
//|                 Lukashuk Victor Gennadievich aka lukas1  |
//+----------------------------------------------------------+
#property copyright "Copyright © 2007, lukas1"
#property link ""
//----
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 LightPink
#property indicator_color2 LightSteelBlue
#property indicator_color3 LightPink
#property indicator_color4 LightSteelBlue
#property indicator_width1 2
#property indicator_width2 2
#property indicator_color5 Blue
//---- input parameters
// баров - расчётный период; calculating period
extern int SSP = 48;  
// замедление второй линии;  tolerance of second line
extern int SSK = 52;  
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double Wal1[];
double Wal2[];
double ExtMapBuffer4[];
int i, j;
double SsMax, SsMin, SsMax05, SsMin05, Rsmin, Rsmax, Tsmin, Tsmax;
double Day_max, Day_min;
int val1, val2, AvgRange, day_bars, day_Range, delta_from_max, 
    delta_from_min, spred;
string comm, sutki;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
//----
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexDrawBegin(0, SSP*2);
   SetIndexLabel(0, "опережающая линия"); // priority line
//----
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexDrawBegin(1, SSP*2);
   SetIndexLabel(1, "запаздывющая линия"); // overdue line
//----
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, Wal1);
   SetIndexDrawBegin(2, SSP*2);
//----
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(3, Wal2);
   SetIndexDrawBegin(3, SSP*2);
//----
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, ExtMapBuffer4);
   SetIndexDrawBegin(4, SSP*2);
   SetIndexLabel(4, "линия стоп-ордера"); // stop-order line   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                          |
//+------------------------------------------------------------------+
void deinit() 
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   comm= ""; 
   int   counted_bars = IndicatorCounted();
   if(Bars <= SSP + 1)
       return(0);
   i = Bars - counted_bars;
   if(counted_bars==0) i-=(MathMax(SSP,SSK)+1);
   while(i >= 0)
     {
       //RefreshRates();
       // maximum of previous SSP bars period
       SsMax = High[iHighest(NULL, 0,MODE_HIGH, SSP, i)];      
       // minimum of previous SSP bars period
       SsMin = Low[iLowest(NULL, 0, MODE_LOW, SSP, i)];         
       // maximum of SSP bars period for SSK bars from begin
       SsMax05 = High[iHighest(NULL, 0, MODE_HIGH, SSP, i + SSK)];
       // maximum of SSP bars period for SSK bars from begin
       SsMin05 = Low[iLowest(NULL, 0, MODE_LOW, SSP, i + SSK)];   
       ExtMapBuffer1[i] = (SsMax + SsMin) / 2;
       ExtMapBuffer2[i] = (SsMax05 + SsMin05) / 2;
       val1 = ExtMapBuffer1[1] / Point;
       val2 = ExtMapBuffer2[1] / Point;
       // для волатильности
       Rsmax = High[iHighest(NULL, 0, MODE_HIGH, SSP*2, i)]; 
       // для волатильности
       Rsmin = Low[iLowest(NULL, 0, MODE_LOW, SSP*2, i)];
       // гистограмма розового облака
       Wal1[i] = ExtMapBuffer1[i]; 
       // гистограмма голубого облака
       Wal2[i] = ExtMapBuffer2[i];
       // линия стоп-ордера  
       Tsmax = High[iHighest(NULL, 0, MODE_HIGH, SSP*1.62, i)];  
       // линия стоп-ордера  
       Tsmin = Low[iLowest(NULL, 0, MODE_LOW, SSP*1.62, i)];     
       ExtMapBuffer4[i] = (Tsmax + Tsmin) / 2;     
       i--;
     }
   day_bars = MathCeil(1440 / Period());
   //if (Period()==1440) day_bars=5;
   sutki = "сутки";
// день
   if(Period() == 1440)  
     {
       sutki = "неделю";
       day_bars = 5;
     }  
// неделя
   if(Period() == 10080) 
     {
       sutki = "месяц"; 
       day_bars = 4;
     }  
// месяц
   if(Period() == 43200) 
     {
       sutki = "год";  
       day_bars = 12;
     } 
   j = SSP*2 + 1;
   while(j >= 0)
      { 
        // определяем дневной диапазон
        // линия макс дня  
        Day_max = High[iHighest(NULL, 0, MODE_HIGH, day_bars, j + 1)];  
        // линия мин. дня 
        Day_min = Low[iLowest(NULL, 0, MODE_LOW, day_bars, j + 1)];      
        j--;
      }      
    AvgRange = (Rsmax / Point) - (Rsmin / Point);
    day_Range = (Day_max / Point) - (Day_min / Point); 
    delta_from_max = (Day_max - Bid) / Point;
    delta_from_min = (Bid - Day_min) / Point;
//----   
    comm = " параметры  SSP , SSK  =   " + SSP + " ,  " + SSK + " ;\n" +
           " волатильность  (за " + SSP*2 + " баров) :      " + AvgRange + 
           "  п.\n" + "\n" +
           " диапазон за " + sutki + "  (за  " + day_bars + "  баров) :   " + 
           day_Range + "  п.\n" +
           " отклонение от максимума за " + sutki + ":  " + delta_from_max + 
           "  п.\n" +
           " отклонение от минимума  за " + sutki + ":  " + delta_from_min + 
           "  п.\n";            
    Comment(comm);
//----
   return(0);
  }
//+------------------------------------------------------------------+


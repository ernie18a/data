#property copyright "Scriptong by Sultonov's idea, starring Sevan62"
#property link      "http://advancetools.net"
#property description "English: Sultonovs Differential Indicator."
#property description "Russian: Дифференциальный индикатор Султонова"
#define VERSION "220.917"
#property version VERSION
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_color1 clrBlue
#property indicator_color2 clrRed

#property indicator_width1 2
#property indicator_width2 2

#property indicator_label1 "Bulls Power"
#property indicator_label2 "Bears Power"


// Indicators tunning paramaters
input int i_nPeriod       = 1000; // Calculate period / Период расчета
input int i_nIndBarsCount = 10000;// Number of bars to display / Количество баров отображения

bool  g_bIsActivate;

double g_fPoint;                                                                                                   
                                                                                                   
// Indicators buffers
double g_farrBullsPower[];
double g_farrBearsPower[];                                                                                                
    
//+--------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                             |
//+--------------------------------------------------------------------------------------+
int OnInit()
{
   Print("Version: ", VERSION);
   g_bIsActivate = false;
 
   if (!TuningParameters())         
      return INIT_FAILED; 
      
   if (!BuffersBind())
      return INIT_FAILED;      
      
   g_bIsActivate = true;
   return INIT_SUCCEEDED;
}
//+--------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                           |
//+--------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+--------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                  |
//+--------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double &farrClose[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (!g_bIsActivate)
      return rates_total;
      
   int nTotal;   
   int nLimit = GetRecalcIndex(nTotal, rates_total, prev_calculated);                                

   if (!ShowIndicatorData(nLimit, farrClose))
      g_bIsActivate = false;
      
   return rates_total;
}
//+--------------------------------------------------------------------------------------+
//| Checking the correctness of tuning parameters                                        |
//+--------------------------------------------------------------------------------------+
bool TuningParameters()
{
   string name = MQLInfoString(MQL_PROGRAM_NAME);
      
   if (i_nPeriod <= 0)
   {
      Alert(name, ", ", Symbol(), 
            (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian")? 
            ": величина периода расчета должна быть больше нуля. Индикатор отключен." : 
            ": value of period must be greate than zero. Indicator has turned off.");
      return false;
   }
   
   g_fPoint = Point() / 10;
   if (g_fPoint <= 0.0)
   {
      Alert(name, ", ", Symbol(), 
            (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian")? 
            ": фатальная ошибка - величина пункта равна нулю. Индикатор отключен." : 
            ": fatal error - the point value equals to zero. Indicator has turned off.");
      return false;
   }
   
   return true;
}
//+--------------------------------------------------------------------------------------+
//| Indicator buffers binding                                                            |
//+--------------------------------------------------------------------------------------+
bool BuffersBind()
{
   if (!SetIndexBuffer(0, g_farrBullsPower, INDICATOR_DATA)          ||
       !SetIndexBuffer(1, g_farrBearsPower, INDICATOR_DATA))       
   {
      Alert(MQLInfoString(MQL_PROGRAM_NAME), ", ", Symbol(), 
            (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian")? 
            ": ошибка связывания массивов с буферами индикатора. Ошибка №":
            ": indicator buffers binding error N", GetLastError());
      return false;
   }

   for (int i = 0; i < 2; ++i)
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);

   ArraySetAsSeries(g_farrBullsPower, true);
   ArraySetAsSeries(g_farrBearsPower, true);

   IndicatorSetString(INDICATOR_SHORTNAME, "Differential Average by Sultonov (" + 
                      IntegerToString(i_nPeriod) + ")");
   
   return true;
}
//+--------------------------------------------------------------------------------------+
//| Determination of bar index which needed to recalculate                               |
//+--------------------------------------------------------------------------------------+
int GetRecalcIndex(int &nTotal, const int nRatesTotal, const int nPrevCalculated)
{
   nTotal = nRatesTotal - 1 - i_nPeriod;                                                                         
                                                   
   if (i_nIndBarsCount > 0 && i_nIndBarsCount < nTotal)
      nTotal = MathMin(i_nIndBarsCount, nTotal);                      
                                                   
   if (nPrevCalculated < nRatesTotal - 1)                     
   {       
      InitializeBuffers();
      return nTotal;
   }
   
   return MathMin(nRatesTotal - nPrevCalculated, nTotal);                            
}
//+--------------------------------------------------------------------------------------+
//| Indicators buffers inizialization                                                    |
//+--------------------------------------------------------------------------------------+
void InitializeBuffers()
{
   ArrayInitialize(g_farrBullsPower, EMPTY_VALUE);
   ArrayInitialize(g_farrBearsPower, EMPTY_VALUE);
}
//+--------------------------------------------------------------------------------------+
//| Displaying of indicators values                                                      |
//+--------------------------------------------------------------------------------------+
bool ShowIndicatorData(int nLimit, const double &farrClose[])
{
   ArraySetAsSeries(farrClose, true);
   for (int i = nLimit; i >= 0; i--)
      if (!ProcessBar(i, farrClose))
         return false;

   return true;
}
//+-------------------------------------------------------------------------------------+
//| Process the specified bar                                                           |
//+-------------------------------------------------------------------------------------+
bool ProcessBar(int nBarIndex, const double &farrClose[])
{
   if (nBarIndex + i_nPeriod > ArraySize(farrClose))
      return true;

   double fBullsSumm = 0.0, fBearsSumm = 0.0;
   int nBullsCnt = 0, nBearsCnt = 0;
   
   for (int i = nBarIndex + i_nPeriod - 1; i >= nBarIndex; --i)
   {
      double fPower = farrClose[i] - farrClose[i + 1];
      if (fPower > 2 * DBL_EPSILON)
      {
         fBullsSumm += fPower;
         nBullsCnt++;
      }
      if (fPower < -2 * DBL_EPSILON)
      {
         fBearsSumm -= fPower;
         nBearsCnt++;
      }
   }
   
   g_farrBullsPower[nBarIndex] = (nBullsCnt == 0)? 0.0 : 
                                  fBullsSumm / nBullsCnt / g_fPoint;
   g_farrBearsPower[nBarIndex] = (nBearsCnt == 0)? 0.0 : 
                                  fBearsSumm / nBearsCnt / g_fPoint;

   return true;
}

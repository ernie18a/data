//+------------------------------------------------------------------+
//|                                                Seconds_Chart.mq5 |
//|                                Copyright 2024, Rajesh Kumar Nait |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.0"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 0

string symname;

input int Seconds = 1;  // Seconds for candles interval
input bool delete_rates = true;
input bool delete_symbol = true;

double canc[],cano[],canh[],canl[],cant[],seconds[][4];
#define sopen  0
#define sclose 1
#define shigh  2
#define slow   3
datetime copyt=-1;
MqlRates ratesc[1];
MqlRates rates[1];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

if (ENUM_MQL_INFO_INTEGER(MQL_TESTER)) { return(INIT_SUCCEEDED);  }

   SetIndexBuffer(0,cano,INDICATOR_DATA);
   SetIndexBuffer(1,canh,INDICATOR_DATA);
   SetIndexBuffer(2,canl,INDICATOR_DATA);
   SetIndexBuffer(3,canc,INDICATOR_DATA);

   symname=Symbol()+"."+IntegerToString(Seconds)+"second";
   if(!SymbolSelect(symname,true))
     {
      if(!CustomSymbolCreate(symname))
         Print("Failed to create symbol");
      if(!CustomSymbolSetInteger(symname,SYMBOL_DIGITS,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)))
         Print("Unable to set");
      if(!SymbolSelect(symname,true))
         Print("Cant select symbol");
      else
         Print("Symbol "+symname+  "created");
     }

   EventSetTimer(Seconds);
   IndicatorSetString(INDICATOR_SHORTNAME,(string)Seconds+" seconds chart");
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(delete_rates)
      CustomRatesDelete(symname,D'1970.01.01 0:00',D'2099.07.31 22:00');

   if(delete_symbol)
     {
      SymbolSelect(symname,false);
      CustomSymbolDelete(symname);
      Print("Symbol "+symname+ " deleted");
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---

if (ENUM_MQL_INFO_INTEGER(MQL_TESTER)) { return(INIT_SUCCEEDED);  }
   int bars = Bars(NULL,0);
   if(bars<rates_total)
      return(-1);
   if(copyt!=-1)
      RunSecondsCalc();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   double close[];
   if(CopyRates(NULL,0,0,1,ratesc)==false)
     {
      copyt=-1;
      return;
     }
   int size = ArrayRange(seconds,0);
   ArrayResize(seconds,size+1);
   seconds[size][sopen]  = ratesc[0].close;
   seconds[size][sclose] = ratesc[0].close;
   seconds[size][shigh]  = ratesc[0].close;
   seconds[size][slow]   = ratesc[0].close;
   RunSecondsTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RunSecondsTimer()
  {
   int size = ArrayRange(seconds, 0);
   ArrayResize(seconds, size + 1);
   double closeValue = ratesc[0].close;

   if(size > 0)
     {
      seconds[size][sopen] = closeValue;
      seconds[size][sclose] = closeValue;
      seconds[size][shigh] = closeValue;
      seconds[size][slow] = closeValue;

      MqlRates tempRates[1];
      if(CopyRates(Symbol(), PERIOD_M1, 0, 1, tempRates) == -1)
        {
         Print("Failed to copy rates ", GetLastError());
         copyt = -1;
         return;
        }

      seconds[size - 1][shigh] = MathMax(seconds[size - 1][shigh], tempRates[0].close);
      seconds[size - 1][slow] = MathMin(seconds[size - 1][slow], tempRates[0].close);
      seconds[size - 1][sclose] = tempRates[0].close;

      rates[0].high = seconds[size - 1][shigh];
      rates[0].low = seconds[size - 1][slow];
      rates[0].open = seconds[size - 1][sopen];
      rates[0].close = seconds[size - 1][sclose];


      rates[0].time = StringToTime(TimeToString(TimeGMT(), TIME_SECONDS));

      if(CustomRatesUpdate(symname, rates) == -1)
        {
         copyt = -1;
        }
      else
        {
         copyt = rates[0].time;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RunSecondsCalc()
  {
// int rates_total = ArraySize(canh);
   int size = ArrayRange(seconds, 0);

   if(size > 0)
     {
      // Use a temporary array to store ratesc values before updating seconds
      MqlRates tempRates[1];
      if(CopyRates(NULL, 0, 0, 1, tempRates) == -1)
        {
         Print("Failed to copy rates ", GetLastError());
         copyt = -1;
         return;
        }

      // Update seconds array
      seconds[size - 1][shigh] = MathMax(seconds[size - 1][shigh], tempRates[0].close);
      seconds[size - 1][slow] = MathMin(seconds[size - 1][slow], tempRates[0].close);
      seconds[size - 1][sclose] = tempRates[0].close;

      rates[0].high = seconds[size - 1][shigh];
      rates[0].low = seconds[size - 1][slow];
      rates[0].open = seconds[size - 1][sopen];
      rates[0].close = seconds[size - 1][sclose];

      if(CustomRatesUpdate(symname, rates) == -1)
        {
         copyt = -1;
        }
      else
        {
         copyt = rates[0].time;
        }
     }
  }
//+------------------------------------------------------------------+

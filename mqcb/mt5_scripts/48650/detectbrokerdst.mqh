//+------------------------------------------------------------------+
//|                                              DetectBrokerDST.mqh |
//|                                        Copyright © 2026, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.500"
#property description "Detects whether the broker server follows the US, UK, AU, or no daylight saving time (DST) schedule."

enum ENUM_BROKER_DST
  {
   DST_ERROR = -1,
   DST_AU,
   DST_UK,
   DST_US,
   DST_NONE
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define DAYSECS   86400          // Seconds per day
#define WEEKSECS (7 * DAYSECS)   // Seconds per week

//+------------------------------------------------------------------+
//| Detect which daylight-saving schedule the broker server follows  |
//| by comparing H1 bar timestamps across known DST transition weeks.|
//+------------------------------------------------------------------+
ENUM_BROKER_DST DetectBrokerDST()
  {
   //-----------------------------------------------------------------
   // Select a reference symbol.
   //-----------------------------------------------------------------

   const string symbol=BrokerDSTInternal::GetReferenceSymbol();

   if(symbol=="")
      return DST_ERROR;

   const datetime lastbar=iTime(symbol,PERIOD_H1,0);

   if(lastbar==0)
      return DST_ERROR;

   int year=BrokerDSTInternal::TimeYear(lastbar);

   //-----------------------------------------------------------------
   // DST transition dates.
   //-----------------------------------------------------------------

   datetime au=BrokerDSTInternal::GetNthSunday(year,4,1);  // the first Sunday of April for the AU switch
   datetime uk=BrokerDSTInternal::GetNthSunday(year,3,5);  // the last Sunday of March for the UK switch
   datetime us=BrokerDSTInternal::GetNthSunday(year,3,2);  // the second Sunday of March for the US switch

   if(lastbar<au+WEEKSECS)
     {
      year--;

      au=BrokerDSTInternal::GetNthSunday(year,10,1);  // the first Sunday of October for the AU switch
      uk=BrokerDSTInternal::GetNthSunday(year,10,5);  // the last Sunday of October for the UK switch
      us=BrokerDSTInternal::GetNthSunday(year,11,1);  // the first Sunday of November for the US switch
     }

   //-----------------------------------------------------------------
   // Compare server time across each transition.
   //-----------------------------------------------------------------

   bool changed;

   if(!BrokerDSTInternal::DetectTransition(symbol,au,changed))
      return DST_ERROR;

   // Server offset changed at the Australian DST transition.
   if(changed)
     {
      return DST_AU;
     }

   if(!BrokerDSTInternal::DetectTransition(symbol,uk,changed))
      return DST_ERROR;

   // Server offset changed at the UK DST transition.
   if(changed)
     {
      return DST_UK;
     }

   if(!BrokerDSTInternal::DetectTransition(symbol,us,changed))
      return DST_ERROR;

   // Server offset did not change at the US transition.
   if(!changed)
     {
      return DST_US;
     }

   return DST_NONE;
  }

namespace BrokerDSTInternal
{
//+------------------------------------------------------------------+
//| Time functions                                                   |
//+------------------------------------------------------------------+
int TimeYear(const datetime t) {MqlDateTime st; TimeToStruct(t, st); return(st.year); }
int TimeHour(const datetime t) {MqlDateTime st; TimeToStruct(t, st); return(st.hour); }
//+------------------------------------------------------------------+
//| Returns the date of the Nth Sunday in the specified month.       |
//| If the requested occurrence does not exist (e.g. 5th Sunday),    |
//| the last Sunday of the month is returned.                        |
//+------------------------------------------------------------------+
datetime GetNthSunday(const int year, const int month, int Nth = 1)
  {
   if(Nth < 1 || month < 1 || month > 12)
      return 0;
   if(Nth > 5)
      Nth = 5;
   MqlDateTime dt = {year, month, 1};
   const datetime first = StructToTime(dt); // first day of the requested month
   int jumpdays = (Nth - 1) * 7;
   TimeToStruct(first, dt);
   jumpdays += (7 - dt.day_of_week) % 7;  // days from the 1st of the month to the first Sunday
   datetime res = first + jumpdays * DAYSECS;
   TimeToStruct(res, dt);
   if(dt.mon != month)
      res -= WEEKSECS;
   return res;
  }
//+------------------------------------------------------------------+
//| Returns a symbol suitable for detecting DST changes.             |
//|                                                                  |
//| Forex and gold symbols are preferred because they trade nearly   |
//| continuously during the week. If the current chart is not one of |
//| these, EURUSD (including broker suffixes) is selected instead.   |
//+------------------------------------------------------------------+
string GetReferenceSymbol()
  {
   string symbol = Symbol();
   // Use EURUSD if the current chart is not a forex or gold symbol.
   const long calcMode = SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE);
   if(!(calcMode == SYMBOL_CALC_MODE_FOREX || calcMode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE
        || StringSubstr(symbol,0,3) == "XAU" || StringSubstr(symbol,0,4) == "GOLD"))
     {
      symbol = "EURUSD";
      bool is_custom = false;
      if(!SymbolExist(symbol,is_custom))
         for(int i=0; i < SymbolsTotal(false); i++)
           {
            string s = SymbolName(i,false);
            if(StringSubstr(s,0,6)==symbol)
              {
               symbol = s;   // Broker-specific suffix, e.g. EURUSD.a
               break;
              }
           }
      if(!SymbolSelect(symbol,true))
        {
         Print("Unable to select ", symbol);
         return "";
        }
     }
   return symbol;
  }
//+------------------------------------------------------------------+
//| Returns the opening time of the H1 bar containing the specified  |
//| time.                                                            |
//+------------------------------------------------------------------+
bool GetBarTime(const string symbol,
                const datetime target,
                datetime &bar_time)
  {
   const int shift=iBarShift(symbol,PERIOD_H1,target,false);
   if(shift<0)
     {
      PrintFormat("H1 history is unavailable around %s", TimeToString(target));
      return false;
     }
   bar_time=iTime(symbol,PERIOD_H1,shift);
   /* Print("bar_time = ", bar_time); */
   return(bar_time!=0);
  }
//+------------------------------------------------------------------+
//| Detects the broker server DST schedule by comparing H1 bar       |
//| timestamps across known DST transition weeks.                    |
//+------------------------------------------------------------------+
bool DetectTransition(const string symbol,
                      const datetime transition,
                      bool &changed)
  {
   datetime barBeforeTransition, barAfterTransition;

   if(!GetBarTime(symbol, transition, barBeforeTransition))
      return false;

   if(!GetBarTime(symbol, transition + WEEKSECS, barAfterTransition))
      return false;

   changed = (TimeHour(barBeforeTransition) != TimeHour(barAfterTransition));

   return true;
  }

};

#undef DAYSECS
#undef WEEKSECS

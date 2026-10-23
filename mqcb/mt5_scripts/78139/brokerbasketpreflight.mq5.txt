//+------------------------------------------------------------------+
//| Broker Basket Preflight 1.00                                      |
//| Copyright (c) 2026 Fabien Martino                                  |
//| Original read-only broker specification diagnostic for MetaTrader5|
//+------------------------------------------------------------------+
// MIT License
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#property copyright "Fabien Martino"
#property version   "1.00"
#property description "Read-only multi-symbol broker specification and minimum-volume diagnostic."
#property description "Use exact broker names already selected in Market Watch. Output: Experts journal."
#property strict
#property script_show_inputs

input string InpSymbols = "";            // Comma-separated exact names; empty = chart symbol
input uint   InpMaxQuoteAgeSeconds = 120; // Warning threshold; 0 disables the age warning
input double InpMaxSpreadPoints = 0.0;    // Optional warning threshold in points; 0 disables it

//+------------------------------------------------------------------+
//| Broker contract properties used by the diagnostic                |
//+------------------------------------------------------------------+
struct BrokerSpec
  {
   long   digits;
   long   trade_mode;
   long   execution;
   long   filling;
   long   order_modes;
   long   calc_mode;
   long   stops;
   long   freeze;
   double point;
   double tick_size;
   double contract;
   double volume_min;
   double volume_max;
   double volume_step;
   double volume_limit;
  };

//+------------------------------------------------------------------+
//| Reject missing and non-finite numeric values                     |
//+------------------------------------------------------------------+
bool Finite(const double value)
  {
   return MathIsValidNumber(value) && value!=EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//| Consistent numeric output for the journal                        |
//+------------------------------------------------------------------+
string Number(const double value,const int digits=8)
  {
   return DoubleToString(value,digits);
  }

//+------------------------------------------------------------------+
//| Count and label diagnostic warnings                              |
//+------------------------------------------------------------------+
void Warn(const string symbol,const string message,int &warnings)
  {
   warnings++;
   PrintFormat("[WARN] %s: %s",symbol,message);
  }

//+------------------------------------------------------------------+
//| Read a numeric property without replacing errors with zero       |
//+------------------------------------------------------------------+
bool ReadDouble(const string symbol,const ENUM_SYMBOL_INFO_DOUBLE property,double &value)
  {
   ResetLastError();
   if(SymbolInfoDouble(symbol,property,value) && Finite(value)) return true;
   PrintFormat("[SKIP] %s: cannot read %s (error %d).",symbol,EnumToString(property),GetLastError());
   return false;
  }

//+------------------------------------------------------------------+
//| Read a broker integer property and retain its error              |
//+------------------------------------------------------------------+
bool ReadInteger(const string symbol,const ENUM_SYMBOL_INFO_INTEGER property,long &value)
  {
   ResetLastError();
   if(SymbolInfoInteger(symbol,property,value)) return true;
   PrintFormat("[SKIP] %s: cannot read %s (error %d).",symbol,EnumToString(property),GetLastError());
   return false;
  }

//+------------------------------------------------------------------+
//| Obtain the broker contract specification                         |
//+------------------------------------------------------------------+
bool LoadSpec(const string symbol,BrokerSpec &spec)
  {
   return ReadInteger(symbol,SYMBOL_DIGITS,spec.digits)
       && ReadInteger(symbol,SYMBOL_TRADE_MODE,spec.trade_mode)
       && ReadInteger(symbol,SYMBOL_TRADE_EXEMODE,spec.execution)
       && ReadInteger(symbol,SYMBOL_FILLING_MODE,spec.filling)
       && ReadInteger(symbol,SYMBOL_ORDER_MODE,spec.order_modes)
       && ReadInteger(symbol,SYMBOL_TRADE_CALC_MODE,spec.calc_mode)
       && ReadInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,spec.stops)
       && ReadInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL,spec.freeze)
       && ReadDouble(symbol,SYMBOL_POINT,spec.point)
       && ReadDouble(symbol,SYMBOL_TRADE_TICK_SIZE,spec.tick_size)
       && ReadDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE,spec.contract)
       && ReadDouble(symbol,SYMBOL_VOLUME_MIN,spec.volume_min)
       && ReadDouble(symbol,SYMBOL_VOLUME_MAX,spec.volume_max)
       && ReadDouble(symbol,SYMBOL_VOLUME_STEP,spec.volume_step)
       && ReadDouble(symbol,SYMBOL_VOLUME_LIMIT,spec.volume_limit);
  }

// The grid is measured from zero, as required by volume/price increments.
// Relative tolerance accounts for double arithmetic at large price levels.
//+------------------------------------------------------------------+
//| Check a price or volume against its increment                    |
//+------------------------------------------------------------------+
bool OnGrid(const double value,const double step)
  {
   if(!Finite(value) || !Finite(step) || step<=0.0) return false;
   const double units=value/step;
   if(!Finite(units)) return false;
   const double tolerance=1.0e-7+MathAbs(units)*2.220446049250313e-16*8.0;
   return MathAbs(units-MathRound(units))<=tolerance;
  }

//+------------------------------------------------------------------+
//| Report permitted market-order filling policies                   |
//+------------------------------------------------------------------+
string MarketFillPolicies(const long execution,const long flags)
  {
   // Instant and Request execution permit FOK/IOC independently of flags.
   const bool unrestricted=(execution==SYMBOL_TRADE_EXECUTION_INSTANT ||
                            execution==SYMBOL_TRADE_EXECUTION_REQUEST);
   string result="";
   if(unrestricted || (flags&SYMBOL_FILLING_FOK)!=0) result="FOK";
   if(unrestricted || (flags&SYMBOL_FILLING_IOC)!=0)
      result+=(result=="" ? "" : ",")+"IOC";
   // RETURN is forbidden for market orders under Market execution.
   if(execution!=SYMBOL_TRADE_EXECUTION_MARKET)
      result+=(result=="" ? "" : ",")+"RETURN";
   return result=="" ? "none reported" : result;
  }

//+------------------------------------------------------------------+
//| Calculate a scenario without sending a trade request             |
//+------------------------------------------------------------------+
bool ProfitProbe(const string symbol,const ENUM_ORDER_TYPE side,const double volume,
                 const double open_price,const double close_price,const string label,
                 const string currency,int &warnings)
  {
   double result=0.0;
   ResetLastError();
   if(!OrderCalcProfit(side,symbol,volume,open_price,close_price,result) || !Finite(result))
     {
      const int error=GetLastError();
      Warn(symbol,StringFormat("%s calculation unavailable (error %d); conversion quotes may be missing.",label,error),warnings);
      return false;
     }
   PrintFormat("[CALC] %s: %s = %s %s",symbol,label,Number(result),currency);
   return true;
  }

//+------------------------------------------------------------------+
//| Estimate margin and price sensitivity at minimum volume          |
//+------------------------------------------------------------------+
void MinimumVolumeMetrics(const string symbol,const BrokerSpec &spec,const MqlTick &tick,
                          const string currency,int &warnings)
  {
   for(int i=0;i<2;i++)
     {
      const ENUM_ORDER_TYPE side=(i==0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
      const string label=(i==0 ? "BUY" : "SELL");
      const double open_price=(i==0 ? tick.ask : tick.bid);
      double margin=0.0;
      ResetLastError();
      if(OrderCalcMargin(side,symbol,spec.volume_min,open_price,margin) && Finite(margin) && margin>=0.0)
         PrintFormat("[CALC] %s: isolated %s margin at minimum volume = %s %s",symbol,label,Number(margin),currency);
      else
        {
         const int error=GetLastError();
         Warn(symbol,StringFormat("%s margin calculation unavailable (error %d).",label,error),warnings);
        }

      // Both scenarios shift the same quote by exactly one tradable tick.
      // They exclude the bid/ask spread, commission, swap and slippage.
      const double up=open_price+spec.tick_size;
      const double down=open_price-spec.tick_size;
      if(Finite(up) && up>open_price)
         ProfitProbe(symbol,side,spec.volume_min,open_price,up,label+" +1 tick price move",currency,warnings);
      else Warn(symbol,label+" upward tick scenario is not representable.",warnings);
      if(Finite(down) && down>0.0 && down<open_price)
         ProfitProbe(symbol,side,spec.volume_min,open_price,down,label+" -1 tick price move",currency,warnings);
      else Warn(symbol,label+" downward tick scenario is not representable.",warnings);

      const double exit_price=(i==0 ? tick.bid : tick.ask);
      ProfitProbe(symbol,side,spec.volume_min,open_price,exit_price,
                  label+" immediate spread-only result",currency,warnings);
     }
  }

//+------------------------------------------------------------------+
//| Inspect one exact symbol independently of the other entries      |
//+------------------------------------------------------------------+
bool InspectSymbol(const string symbol,const string currency,int &warnings)
  {
   bool custom=false;
   ResetLastError();
   if(!SymbolExist(symbol,custom))
     {
      PrintFormat("[SKIP] %s: exact name does not exist. Broker suffixes/prefixes are not guessed.",symbol);
      return false;
     }
   long selected=0;
   if(!ReadInteger(symbol,SYMBOL_SELECT,selected)) return false;
   if(selected==0)
     {
      PrintFormat("[SKIP] %s: select the exact symbol in Market Watch, allow quotes to arrive, then rerun.",symbol);
      return false;
     }
   BrokerSpec spec={};
   if(!LoadSpec(symbol,spec)) return false;
   if(spec.digits<0 || spec.digits>16 || spec.point<=0.0 || spec.tick_size<=0.0 ||
      spec.contract<=0.0 || spec.volume_min<=0.0 || spec.volume_step<=0.0 ||
      spec.volume_max<spec.volume_min || spec.volume_limit<0.0 || spec.stops<0 || spec.freeze<0)
     {
      PrintFormat("[SKIP] %s: invalid or incomplete contract/price/volume specification.",symbol);
      return false;
     }

   PrintFormat("[SPEC] %s: calculation=%s; trading=%s; execution=%s; custom=%s",
               symbol,EnumToString((ENUM_SYMBOL_CALC_MODE)spec.calc_mode),
               EnumToString((ENUM_SYMBOL_TRADE_MODE)spec.trade_mode),
               EnumToString((ENUM_SYMBOL_TRADE_EXECUTION)spec.execution),custom ? "yes" : "no");
   PrintFormat("[SPEC] %s: contract=%s; min/max/step lots=%s / %s / %s; directional volume limit=%s",
               symbol,Number(spec.contract),Number(spec.volume_min),Number(spec.volume_max),
               Number(spec.volume_step),spec.volume_limit==0.0 ? "not set" : Number(spec.volume_limit));
   PrintFormat("[SPEC] %s: point=%s; tick size=%s; digits=%d; stops/freeze=%I64d / %I64d points; market fills=%s",
               symbol,Number(spec.point,16),Number(spec.tick_size,16),(int)spec.digits,
               spec.stops,spec.freeze,MarketFillPolicies(spec.execution,spec.filling));

   if(custom) Warn(symbol,"custom/synthetic symbol; this report does not establish broker tradability.",warnings);
   if(!OnGrid(spec.volume_min,spec.volume_step))
     {
      Warn(symbol,"minimum volume is not a multiple of volume step; minimum-volume calculations skipped.",warnings);
      return true;
     }
   if(!OnGrid(spec.volume_max,spec.volume_step)) Warn(symbol,"maximum volume is not a multiple of volume step.",warnings);
   if(!OnGrid(spec.tick_size,spec.point)) Warn(symbol,"tick size is not a multiple of point; review broker price rules.",warnings);
   if(spec.volume_limit>0.0 && spec.volume_limit<spec.volume_min)
      Warn(symbol,"directional volume limit is below minimum volume.",warnings);
   if(spec.trade_mode!=SYMBOL_TRADE_MODE_FULL)
      Warn(symbol,"trading has directional, close-only or disabled restrictions (see trading mode).",warnings);
   if((spec.order_modes&SYMBOL_ORDER_MARKET)==0) Warn(symbol,"market orders are not enabled by the symbol flags.",warnings);
   if(spec.execution==SYMBOL_TRADE_EXECUTION_MARKET &&
      (spec.filling&(SYMBOL_FILLING_FOK|SYMBOL_FILLING_IOC))==0)
      Warn(symbol,"Market execution reports neither FOK nor IOC for market orders.",warnings);
   if(!SymbolIsSynchronized(symbol)) Warn(symbol,"symbol data is not synchronized; calculations may be unavailable.",warnings);

   MqlTick tick={};
   ResetLastError();
   if(!SymbolInfoTick(symbol,tick) || !Finite(tick.bid) || !Finite(tick.ask) ||
      tick.time<=0 || tick.bid<=0.0 || tick.ask<=0.0 || tick.ask<tick.bid)
     {
      const int error=GetLastError();
      Warn(symbol,StringFormat("valid bid/ask quote unavailable (error %d); quote calculations skipped.",error),warnings);
      return true;
     }
   const double spread_points=(tick.ask-tick.bid)/spec.point;
   PrintFormat("[QUOTE] %s: bid=%s; ask=%s; spread=%s points; quote time=%s (server)",
               symbol,Number(tick.bid,(int)spec.digits),Number(tick.ask,(int)spec.digits),
               Number(spread_points,2),TimeToString(tick.time,TIME_DATE|TIME_SECONDS));
   const datetime now=TimeTradeServer();
   const long age=(long)now-(long)tick.time;
   if(now<=0) Warn(symbol,"server time unavailable; quote age not checked.",warnings);
   else if(age<0) Warn(symbol,"quote time is ahead of estimated server time; review clock synchronization.",warnings);
   else if(InpMaxQuoteAgeSeconds>0 && age>(long)InpMaxQuoteAgeSeconds)
      Warn(symbol,StringFormat("last quote is %I64d seconds old; historical quote calculations only.",age),warnings);
   if(InpMaxSpreadPoints>0.0 && spread_points>InpMaxSpreadPoints)
      Warn(symbol,"current spread exceeds the user-specified threshold.",warnings);
   if(!OnGrid(tick.bid,spec.tick_size) || !OnGrid(tick.ask,spec.tick_size))
     {
      Warn(symbol,"bid/ask is not aligned to tick size; minimum-volume calculations skipped.",warnings);
      return true;
     }
   MinimumVolumeMetrics(symbol,spec,tick,currency,warnings);
   return true;
  }

//+------------------------------------------------------------------+
//| Run once and print a summary without changing trading state      |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!Finite(InpMaxSpreadPoints) || InpMaxSpreadPoints<0.0)
     {
      Print("[ERROR] InpMaxSpreadPoints must be finite and non-negative.");
      return;
     }
   string basket=InpSymbols;
   StringTrimLeft(basket);
   StringTrimRight(basket);
   if(basket=="") basket=_Symbol;
   string symbols[];
   const int count=StringSplit(basket,',',symbols);
   if(count<1 || count>64)
     {
      Print("[ERROR] Enter between 1 and 64 exact symbol names.");
      return;
     }
   const string currency=AccountInfoString(ACCOUNT_CURRENCY);
   if(currency=="")
     {
      Print("[ERROR] Account currency unavailable. Connect a terminal account and rerun.");
      return;
     }
   Print("Broker Basket Preflight 1.00 | Fabien Martino | read-only diagnostic");
   Print("No orders, positions, charts, Market Watch selection or terminal globals are changed.");
   PrintFormat("Calculation currency: %s. No account identifier or balance is reported.",currency);
   Print("Margin is calculated for an isolated order, ignoring existing exposure. It is not an available-margin check.");
   Print("A successful calculation is not a trading permission or execution guarantee. Commission, swap and slippage are excluded.");
   int inspected=0,skipped=0,warnings=0;
   for(int i=0;i<count && !IsStopped();i++)
     {
      StringTrimLeft(symbols[i]);
      StringTrimRight(symbols[i]);
      if(symbols[i]=="")
        {
         PrintFormat("[SKIP] Empty symbol at list item %d.",i+1);
         skipped++;
         continue;
        }
      bool duplicate=false;
      for(int j=0;j<i;j++) if(symbols[j]==symbols[i]) { duplicate=true; break; }
      if(duplicate)
        {
         PrintFormat("[SKIP] %s: duplicate list entry.",symbols[i]);
         skipped++;
         continue;
        }
      if(InspectSymbol(symbols[i],currency,warnings)) inspected++;
      else skipped++;
     }
   PrintFormat("[SUMMARY] inspected=%d; skipped=%d; warnings=%d%s",inspected,skipped,warnings,
               IsStopped() ? "; interrupted" : "");
  }
//+------------------------------------------------------------------+

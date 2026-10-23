//+------------------------------------------------------------------+
//| Portfolio Allocation Planner 1.00                              |
//| Copyright (c) 2026 Fabien Martino                                 |
//| Hypothetical notional allocation diagnostic; no trading           |
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
#property description "Read-only hypothetical notional allocation and minimum-lot diagnostic."
#property description "No balance, equity, positions or trading requests are read or changed."
#property strict

enum PAPLanguage { PAP_EN=0, PAP_FR=1 };
input PAPLanguage InpLanguage = PAP_FR; // Panel language
input bool InpAllowCSVExport = false;   // Explicit opt-in for CSV in MQL5/Files
input uint InpPanelMaxWidth = 1100;      // Panel width cap in pixels (minimum 580)

input double InpBudget = 5000.0;          // Hypothetical total notional budget; never account balance
input string InpBudgetCurrency = "USD"; // Explicit budget currency, as in the broker specification
input string InpSymbols = "";           // Exact comma-separated names; empty = chart symbol
input string InpWeightsPct = "100";     // Matching percentages, decimal point; total <= 100
input string InpFXSymbols = "";         // Exact selected direct/inverse Forex conversion symbols
input uint InpMaxQuoteAgeSeconds = 120;  // Older quotes skipped; 0 permits historical estimates


struct PAPRow
  {
   string            symbol;
   string            status;
   string            detail;
   string            fx_route;
   double            weight;
   double            target;
   double            minimum_notional;
   double            minimum_budget;
   double            raw_lots;
   double            lots;
   double            notional;
   double            shortfall;
   bool              resolved;
  };

PAPRow g_rows[];
string g_prefix="",g_currency="",g_error="",g_export_note="";
int g_page=0,g_resolved=0,g_unresolved=0,g_warnings=0;
double g_total_weight=0.0,g_allocated=0.0,g_unresolved_target=0.0,g_minimum_budget=0.0;
datetime g_calculated=0;
const int PAP_ROWS_PER_PAGE=8;
int g_rows_per_page=PAP_ROWS_PER_PAGE;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PAPText(const string english,const string french)
  {
   return InpLanguage==PAP_FR ? french : english;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPUnresolved(PAPRow &row,const string reason)
  {
   row.status="UNRESOLVED";
   row.detail=reason;
   row.resolved=false;
   PrintFormat("[UNRESOLVED] %s: %s",row.symbol,reason);
   return false;
  }

//+------------------------------------------------------------------+
//| Finite values, including rejection of the terminal empty sentinel |
//+------------------------------------------------------------------+
bool PAPFinite(const double value)
  {
   return MathIsValidNumber(value) && value!=EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PAPNumber(const double value,const int digits=8)
  {
   return DoubleToString(value,digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PAPTrim(string value)
  {
   StringTrimLeft(value);
   StringTrimRight(value);
   return value;
  }

// Only a decimal point and decimal digits are accepted: StringToDouble
// alone would also accept malformed input with a numeric prefix.
bool PAPParseWeight(string value,double &weight)
  {
   value=PAPTrim(value);
   bool digit=false,point=false;
   for(int i=0;i<StringLen(value);i++)
     {
      const ushort ch=StringGetCharacter(value,i);
      if(ch>=48 && ch<=57)
         digit=true;
      else
         if(ch==46 && !point)
            point=true;
         else
            return false;
     }
   if(!digit)
      return false;
   weight=StringToDouble(value);
   return PAPFinite(weight) && weight>=0.0 && weight<=100.0;
  }

// Numeric tolerance is confined to double round-off, not a lot step.
double PAPTolerance(const double value)
  {
   return MathMax(1.0e-12,MathAbs(value)*2.220446049250313e-16*8.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPOnGrid(const double value,const double step)
  {
   if(!PAPFinite(value) || !PAPFinite(step) || step<=0.0)
      return false;
   const double units=value/step;
   if(!PAPFinite(units) || MathAbs(units)>1.0e12)
      return false;
   return MathAbs(units-MathRound(units))<=PAPTolerance(units);
  }

// Largest multiple of step not exceeding target or the broker caps.
// A sub-minimum allocation returns zero; it is never raised to min lot.
bool PAPVolume(const double raw,const double minimum,const double maximum,
               const double step,const double limit,double &volume,string &status)
  {
   volume=0.0;
   status="";
   if(!PAPFinite(raw) || raw<0.0 || !PAPFinite(minimum) || minimum<=0.0 ||
      !PAPFinite(maximum) || maximum<minimum || !PAPFinite(step) || step<=0.0 ||
      !PAPFinite(limit) || limit<0.0 || !PAPOnGrid(minimum,step) ||
      MathAbs(step-NormalizeDouble(step,8))>PAPTolerance(step))
     {
      status="INVALID_VOLUME_SPEC";
      return false;
     }
   double cap=MathMin(raw,maximum);
   if(limit>0.0)
      cap=MathMin(cap,limit);
   const double units=cap/step;
   if(!PAPFinite(units) || units>1.0e12)
     {
      status="UNREPRESENTABLE_VOLUME";
      return false;
     }
   volume=NormalizeDouble(MathFloor(units+PAPTolerance(units))*step,8);
   if(volume>cap+PAPTolerance(cap))
      volume=NormalizeDouble(volume-step,8);
   if(volume<minimum-PAPTolerance(minimum))
     {
      volume=0.0;
      status=(limit>0.0 && limit<minimum ? "LIMIT_BELOW_MIN" : "BELOW_MIN");
      return true;
     }
   if(!PAPOnGrid(volume,step))
     {
      volume=0.0;
      status="UNREPRESENTABLE_VOLUME";
      return false;
     }
   if(raw>maximum+PAPTolerance(maximum))
      status="MAX_CAP";
   if(limit>0.0 && raw>limit+PAPTolerance(limit))
      status+=(status=="" ? "" : "+")+"DIRECTIONAL_CAP";
   if(status=="")
      status=(volume<raw-PAPTolerance(raw) ? "ROUNDED_DOWN" : "ON_GRID");
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPLinearMode(const long mode)
  {
   return mode==SYMBOL_CALC_MODE_FOREX || mode==SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE ||
          mode==SYMBOL_CALC_MODE_CFD || mode==SYMBOL_CALC_MODE_CFDINDEX ||
          mode==SYMBOL_CALC_MODE_CFDLEVERAGE || mode==SYMBOL_CALC_MODE_EXCH_STOCKS ||
          mode==SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PAPFundingFXRate(const bool direct,const double bid,const double ask)
  {
   if(!PAPFinite(bid) || !PAPFinite(ask) || bid<=0.0 || ask<bid)
      return 0.0;
   return direct ? ask : 1.0/bid;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPReadDouble(const string symbol,const ENUM_SYMBOL_INFO_DOUBLE property,double &value)
  {
   return SymbolInfoDouble(symbol,property,value) && PAPFinite(value);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPSelectedSymbol(const string symbol,string &reason)
  {
   bool custom=false;
   long selected=0;
   if(!SymbolExist(symbol,custom))
      reason="exact symbol does not exist";
   else
      if(custom)
         reason="custom/synthetic symbols are outside this diagnostic";
      else
         if(!SymbolInfoInteger(symbol,SYMBOL_SELECT,selected) || selected==0)
            reason="select this exact symbol in Market Watch and wait for quotes";
         else
            return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPQuote(const string symbol,MqlTick &tick,string &reason)
  {
   if(!SymbolInfoTick(symbol,tick) || !PAPFinite(tick.bid) || !PAPFinite(tick.ask) ||
      tick.bid<=0.0 || tick.ask<=0.0 || tick.ask<tick.bid || tick.time<=0)
     {
      reason="valid positive bid/ask unavailable";
      return false;
     }
   const datetime now=TimeTradeServer();
   if(now<=0 || tick.time>now)
     {
      reason="server/quote time unavailable or inconsistent";
      return false;
     }
   const long age=(long)now-(long)tick.time;
   if(InpMaxQuoteAgeSeconds>0 && age>(long)InpMaxQuoteAgeSeconds)
     {
      reason=StringFormat("quote is %I64d seconds old; age limit exceeded",age);
      return false;
     }
   if(InpMaxQuoteAgeSeconds==0)
      PrintFormat("[QUOTE] %s: age=%I64d seconds; historical estimates explicitly permitted",symbol,age);
   return true;
  }

// Funds required for one unit of from_currency, in to_currency.
// Q/B uses Ask (buy Q); B/Q uses 1/Bid (sell B to fund Q).
// No cross rates, names, selection or conversion quotes are invented.
bool PAPConversion(const string from_currency,const string to_currency,string &fx_symbols[],
                   double &rate,string &route,string &reason)
  {
   rate=0.0;
   if(from_currency==to_currency)
     {
      rate=1.0;
      route="same currency";
      return true;
     }
   for(int i=0;i<ArraySize(fx_symbols);i++)
     {
      const string symbol=fx_symbols[i];
      string base="",quote="",why="";
      long mode=0;
      if(!PAPSelectedSymbol(symbol,why) ||
         !SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE,base) ||
         !SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT,quote) ||
         !SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE,mode) ||
         (mode!=SYMBOL_CALC_MODE_FOREX && mode!=SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE))
         continue;
      const bool direct=(base==from_currency && quote==to_currency);
      const bool inverse=(base==to_currency && quote==from_currency);
      if(!direct && !inverse)
         continue;
      MqlTick tick= {};
      if(!PAPQuote(symbol,tick,why))
        {
         reason=symbol+": "+why;
         continue;
        }
      rate=PAPFundingFXRate(direct,tick.bid,tick.ask);
      if(!PAPFinite(rate) || rate<=0.0)
         continue;
      route=symbol+(direct ? " Ask" : " 1/Bid");
      return true;
     }
   if(reason=="")
      reason="no valid supplied direct/inverse selected Forex symbol for "+from_currency+" -> "+to_currency;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPInspect(const string symbol,const double weight,const string currency,string &fx_symbols[],
                double &allocated,double &minimum_budget,int &warnings,PAPRow &row)
  {
   allocated=0.0;
   minimum_budget=0.0;
   const double target=InpBudget*(weight/100.0);
   row.symbol=symbol;
   row.weight=weight;
   row.target=target;
   row.shortfall=target;
   if(weight==0.0)
     {
      PrintFormat("[ALLOCATION] %s: target weight=0; no exposure requested",symbol);
      row.status="ZERO_WEIGHT";
      row.detail="No exposure requested";
      row.resolved=true;
      return true;
     }
   string reason="",profit_currency="";
   if(!PAPSelectedSymbol(symbol,reason))
      return PAPUnresolved(row,reason);
   long mode=0,trade_mode=0,order_modes=0;
   double contract=0.0,minimum=0.0,maximum=0.0,step=0.0,limit=0.0;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE,mode) || !PAPLinearMode(mode))
     {
      return PAPUnresolved(row,"Unsupported calculation mode; no notional formula assumed");
     }
   if(!SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT,profit_currency) || profit_currency=="" ||
      !PAPReadDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE,contract) || contract<=0.0 ||
      !PAPReadDouble(symbol,SYMBOL_VOLUME_MIN,minimum) ||
      !PAPReadDouble(symbol,SYMBOL_VOLUME_MAX,maximum) ||
      !PAPReadDouble(symbol,SYMBOL_VOLUME_STEP,step) ||
      !PAPReadDouble(symbol,SYMBOL_VOLUME_LIMIT,limit))
     {
      return PAPUnresolved(row,"Incomplete contract, currency or volume specification");
     }
   MqlTick tick= {};
   if(!PAPQuote(symbol,tick,reason))
     {
      return PAPUnresolved(row,reason);
     }
   double rate=0.0;
   string route="";
   if(!PAPConversion(profit_currency,currency,fx_symbols,rate,route,reason))
     {
      return PAPUnresolved(row,reason);
     }
   const double unit_notional=tick.ask*contract*rate;
   if(!PAPFinite(unit_notional) || unit_notional<=0.0)
     {
      return PAPUnresolved(row,"Notional arithmetic is not representable");
     }
   const double raw=target/unit_notional;
   double volume=0.0;
   string status="";
   if(!PAPVolume(raw,minimum,maximum,step,limit,volume,status))
     {
      return PAPUnresolved(row,status);
     }
   allocated=volume*unit_notional;
   const double minimum_notional=minimum*unit_notional;
   minimum_budget=minimum_notional/(weight/100.0);
   if(!PAPFinite(allocated) || !PAPFinite(minimum_notional) || !PAPFinite(minimum_budget))
     {
      allocated=0.0;
      minimum_budget=0.0;
      return PAPUnresolved(row,"Allocation/minimum-budget arithmetic is not representable");
     }
   PrintFormat("[SPEC] %s: %s; contract=%s; currency=%s; min/max/step=%s/%s/%s; direction limit=%s",
               symbol,EnumToString((ENUM_SYMBOL_CALC_MODE)mode),PAPNumber(contract),profit_currency,
               PAPNumber(minimum),PAPNumber(maximum),PAPNumber(step),PAPNumber(limit));
   PrintFormat("[VALUE] %s: Ask=%s; FX=%s (%s); 1 lot notional=%s %s; quote=%s server",
               symbol,PAPNumber(tick.ask),PAPNumber(rate),route,PAPNumber(unit_notional,2),currency,
               TimeToString(tick.time,TIME_DATE|TIME_SECONDS));
   PrintFormat("[ALLOCATION] %s: target=%s%% (%s %s); raw lots=%s; rounded lots=%s; status=%s",
               symbol,PAPNumber(weight,4),PAPNumber(target,2),currency,PAPNumber(raw),PAPNumber(volume),status);
   PrintFormat("[RESULT] %s: notional=%s %s; achieved=%s%% of budget; target shortfall=%s %s",
               symbol,PAPNumber(allocated,2),currency,PAPNumber(allocated/InpBudget*100.0,4),
               PAPNumber(MathMax(0.0,target-allocated),2),currency);
   PrintFormat("[MINIMUM] %s: minimum-lot notional=%s %s; total budget for this target weight >= %s %s",
               symbol,PAPNumber(minimum_notional,2),currency,PAPNumber(minimum_budget,2),currency);
   row.status=status;
   row.fx_route=route;
   row.raw_lots=raw;
   row.lots=volume;
   row.notional=allocated;
   row.minimum_notional=minimum_notional;
   row.minimum_budget=minimum_budget;
   row.shortfall=MathMax(0.0,target-allocated);
   row.resolved=true;
   row.detail=StringFormat("%s | %s | %s | Ask=%s | FX=%s | raw lots=%s | min/max/step=%s/%s/%s | quote=%s server",
                           symbol,EnumToString((ENUM_SYMBOL_CALC_MODE)mode),route,PAPNumber(tick.ask),
                           PAPNumber(rate),PAPNumber(raw),PAPNumber(minimum),PAPNumber(maximum),PAPNumber(step),TimeToString(tick.time,TIME_DATE|TIME_SECONDS));
   if(status!="ON_GRID")
      warnings++;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE,trade_mode) ||
      (trade_mode!=SYMBOL_TRADE_MODE_FULL && trade_mode!=SYMBOL_TRADE_MODE_LONGONLY) ||
      !SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE,order_modes) || (order_modes&SYMBOL_ORDER_MARKET)==0)
     {
      warnings++;
      row.status+="+RESTRICTED";
      row.detail+=" | Broker trading/order restrictions";
      PrintFormat("[WARN] %s: broker trading/order restrictions; the notional calculation is not an execution permission",symbol);
     }
   if(!PAPOnGrid(maximum,step))
     {
      warnings++;
      PrintFormat("[WARN] %s: maximum volume is not on the volume-step grid; cap rounded down",symbol);
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PAPCalculate()
  {
   ArrayFree(g_rows);
   g_error="";
   g_export_note="";
   g_page=0;
   g_resolved=0;
   g_unresolved=0;
   g_warnings=0;
   g_total_weight=0.0;
   g_allocated=0.0;
   g_unresolved_target=0.0;
   g_minimum_budget=0.0;
   g_calculated=TimeLocal();
   if(!PAPFinite(InpBudget) || InpBudget<=0.0)
     {
      g_error="InpBudget must be a finite positive hypothetical notional amount.";
      Print("[ERROR] "+g_error);
      return;
     }
   string currency=PAPTrim(InpBudgetCurrency);
   StringToUpper(currency);
   if(currency=="" || StringLen(currency)>12)
     {
      g_error="Enter an explicit budget currency (1 to 12 letters/digits).";
      Print("[ERROR] "+g_error);
      return;
     }
   for(int i=0;i<StringLen(currency);i++)
     {
      const ushort ch=StringGetCharacter(currency,i);
      if(!((ch>=65 && ch<=90) || (ch>=48 && ch<=57)))
        {
         g_error="Budget currency must contain only letters/digits.";
         Print("[ERROR] "+g_error);
         return;
        }
     }
   string names=PAPTrim(InpSymbols);
   if(names=="")
      names=_Symbol;
   string symbols[],weights_text[],fx_symbols[];
   const int count=StringSplit(names,',',symbols);
   if(count<1 || count>64 || StringSplit(InpWeightsPct,',',weights_text)!=count)
     {
      g_error="Enter 1 to 64 exact names and the same number of percentages.";
      Print("[ERROR] "+g_error);
      return;
     }
   double weights[];
   ArrayResize(weights,count);
   double total_weight=0.0;
   for(int i=0;i<count;i++)
     {
      symbols[i]=PAPTrim(symbols[i]);
      if(symbols[i]=="" || !PAPParseWeight(weights_text[i],weights[i]))
        {
         g_error=StringFormat("Invalid symbol/percentage at item %d; use decimal points and commas between entries.",i+1);
         Print("[ERROR] "+g_error);
         return;
        }
      for(int j=0;j<i;j++)
         if(symbols[j]==symbols[i])
           {
            g_error="Duplicate exact symbol "+symbols[i]+"; combine its weights explicitly.";
            Print("[ERROR] "+g_error);
            return;
           }
      total_weight+=weights[i];
     }
   if(total_weight<=0.0 || total_weight>100.0+PAPTolerance(100.0))
     {
      g_error="Percentage total must be greater than zero and at most 100; weights are not normalized.";
      Print("[ERROR] "+g_error);
      return;
     }
   string fx=PAPTrim(InpFXSymbols);
   if(fx!="")
     {
      const int fx_count=StringSplit(fx,',',fx_symbols);
      if(fx_count<1 || fx_count>64)
        {
         g_error="Use at most 64 exact conversion symbol names.";
         Print("[ERROR] "+g_error);
         return;
        }
      for(int i=0;i<fx_count;i++)
        {
         fx_symbols[i]=PAPTrim(fx_symbols[i]);
         if(fx_symbols[i]=="")
           {
            g_error="Empty conversion symbol entry.";
            Print("[ERROR] "+g_error);
            return;
           }
        }
     }
   g_currency=currency;
   g_total_weight=total_weight;
   ArrayResize(g_rows,count);
   Print("Portfolio Allocation Planner 1.00 | Fabien Martino | read-only hypothetical budget");
   PrintFormat("[BUDGET] %s %s; assigned weights=%s%%; unassigned=%s%%",
               PAPNumber(InpBudget,2),currency,PAPNumber(total_weight,4),PAPNumber(MathMax(0.0,100.0-total_weight),4));
   Print("Long-side notional = Ask x contract size x explicit conversion rate. It is not margin or maximum loss.");
   Print("Only linear Forex/CFD/Stocks calculation modes are supported; futures, bonds, options and custom symbols are unresolved.");
   Print("No account data or trading requests; only this tool's panel objects and explicitly requested CSV are created.");
   Print("Existing directional exposure, commissions, swaps, slippage and session availability are excluded.");
   int resolved=0,unresolved=0,warnings=0;
   double allocated=0.0,unresolved_target=0.0,minimum_budget=0.0;
   for(int i=0;i<count && !IsStopped();i++)
     {
      double amount=0.0,required=0.0;
      if(PAPInspect(symbols[i],weights[i],currency,fx_symbols,amount,required,warnings,g_rows[i]))
        {
         resolved++;
         allocated+=amount;
         minimum_budget=MathMax(minimum_budget,required);
        }
      else
        {
         unresolved++;
         unresolved_target+=InpBudget*(weights[i]/100.0);
        }
     }
   PrintFormat("[SUMMARY] resolved=%d; unresolved=%d; warnings=%d; calculated notional=%s %s; not allocated by calculated rows=%s %s",
               resolved,unresolved,warnings,PAPNumber(allocated,2),currency,
               PAPNumber(MathMax(0.0,InpBudget-allocated),2),currency);
   PrintFormat("[SUMMARY] unresolved target=%s %s; largest minimum-budget estimate among resolved positive rows=%s %s%s",
               PAPNumber(unresolved_target,2),currency,PAPNumber(minimum_budget,2),currency,
               IsStopped() ? "; interrupted/incomplete" : (unresolved>0 ? "; incomplete portfolio" : ""));
   g_resolved=resolved;
   g_unresolved=unresolved;
   g_warnings=warnings;
   g_allocated=allocated;
   g_unresolved_target=unresolved_target;
   g_minimum_budget=minimum_budget;
   Print("Minimum-budget estimate concerns one minimum lot per positive row; it does not guarantee exact weights or executable orders.");
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PAPStatus(const string status)
  {
   if(status=="UNRESOLVED")
      return PAPText("Unavailable","Indisponible");
   if(status=="ZERO_WEIGHT")
      return PAPText("Not requested","Non demandé");
   if(StringFind(status,"LIMIT_BELOW_MIN")>=0)
      return PAPText("Limit below min","Limite < lot min");
   if(StringFind(status,"BELOW_MIN")>=0)
      return PAPText("Below min lot","Sous lot min");
   if(StringFind(status,"CAP")>=0)
      return PAPText("Broker cap","Plafond courtier");
   if(StringFind(status,"RESTRICTED")>=0)
      return PAPText("Trade restricted","Trading restreint");
   if(StringFind(status,"ROUNDED_DOWN")>=0)
      return PAPText("Rounded down","Arrondi bas");
   return PAPText("On lot grid","Lot valide");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PAPBox(const string key,const int x,const int y,const int width,const int height,const color background)
  {
   const string name=g_prefix+key;
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return;
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_COLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PAPLabel(const string key,const int x,const int y,const string text,const color foreground,
              const int size=10,const string tooltip="")
  {
   const string name=g_prefix+key;
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return;
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,foreground);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip=="" ? text : tooltip);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PAPButton(const string key,const int x,const int y,const int width,const string text)
  {
   const string name=g_prefix+key;
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
      return;
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,30);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,C'42,61,84');
   ObjectSetInteger(0,name,OBJPROP_COLOR,C'236,242,248');
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,C'82,112,146');
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,1);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PAPShort(const string text,const int max_length)
  {
   if(StringLen(text)<=max_length)
      return text;
   return StringSubstr(text,0,MathMax(1,max_length-2))+"..";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PAPCompactLots(const double lots)
  {
   string text=PAPNumber(lots);
   while(StringLen(text)>0 && StringGetCharacter(text,StringLen(text)-1)==48)
      text=StringSubstr(text,0,StringLen(text)-1);
   if(StringLen(text)>0 && StringGetCharacter(text,StringLen(text)-1)==46)
      text=StringSubstr(text,0,StringLen(text)-1);
   return text;
  }

// All objects use a unique instance prefix; chart settings and other
// indicators/EA objects are never changed or deleted.
void PAPDraw()
  {
   if(g_prefix=="")
      return;
   ObjectsDeleteAll(0,g_prefix);
   const int chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   const int chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   const int width=MathMax(580,MathMin((int)MathMin(InpPanelMaxWidth,1600),chart_width-82));
   g_rows_per_page=MathMax(1,MathMin(PAP_ROWS_PER_PAGE,(chart_height-290)/40));
   const int pages=MathMax(1,(ArraySize(g_rows)+g_rows_per_page-1)/g_rows_per_page);
   g_page=MathMax(0,MathMin(g_page,pages-1));
   const int visible=MathMin(g_rows_per_page,MathMax(0,ArraySize(g_rows)-g_page*g_rows_per_page));
   const int height=290+visible*40;
   const int x=12,y=12;
   const color text=C'235,241,249',muted=C'168,184,204',green=C'111,224,169',amber=C'255,200,109';
   PAPBox("Background",x,y,width,height,C'17,26,39');
   PAPLabel("Title",x+16,y+12,"Portfolio Allocation Planner",text,18);
   PAPLabel("Subtitle",x+16,y+42,
            InpMaxQuoteAgeSeconds==0 ? PAPText("Simulation | historical quotes permitted | no orders","Simulation | cotations historiques | aucun ordre") :
            PAPText("Hypothetical long-side notional | no orders","Simulation notionnelle | aucun ordre"),muted,10);
   if(g_error!="")
     {
      PAPLabel("ErrorTitle",x+16,y+85,PAPText("Correct the inputs (F7 on this chart)","Corriger les paramètres (F7 sur ce graphique)"),amber,12);
      PAPLabel("Error",x+16,y+113,PAPShort(g_error,(width-32)/7),amber,10,g_error);
      PAPLabel("ErrorHelp",x+16,y+145,PAPText("Exact symbols and matching percentages; decimal point; total <= 100%.",
                                              "Symboles exacts et pourcentages correspondants ; point décimal ; total <= 100%."),muted,10);
      PAPButton("Refresh",x+16,y+210,140,PAPText("Recalculate","Recalculer"));
      ChartRedraw(0);
      return;
     }
   PAPLabel("Budget",x+16,y+66,StringFormat("%s %s %s | %s %s%%",
            PAPText("Budget:","Budget :"),PAPNumber(InpBudget,2),g_currency,
            PAPText("weights:","poids :"),PAPNumber(g_total_weight,2)),text,11);
   PAPLabel("Time",x+width-128,y+67,TimeToString(g_calculated,TIME_SECONDS),muted,9,
            PAPText("Calculated at ","Calculé à ")+TimeToString(g_calculated,TIME_DATE|TIME_SECONDS));
   const int table_y=y+96;
   PAPBox("Header",x+12,table_y,width-24,28,C'34,47,66');
   const int c0=x+18,c1=x+(int)(width*.19),c2=x+(int)(width*.32),c3=x+(int)(width*.45);
   const int c4=x+(int)(width*.56),c5=x+(int)(width*.70),c6=x+(int)(width*.83);
   PAPLabel("H0",c0,table_y+6,PAPText("Symbol","Symbole"),muted,9);
   PAPLabel("H1",c1,table_y+6,PAPText("Target","Cible"),muted,9);
   PAPLabel("H2",c2,table_y+6,PAPText("Min notional","Notionnel min"),muted,9);
   PAPLabel("H3",c3,table_y+6,PAPText("Lots","Lots"),muted,9);
   PAPLabel("H4",c4,table_y+6,PAPText("Notional","Notionnel"),muted,9);
   PAPLabel("H5",c5,table_y+6,PAPText("Shortfall","Écart cible"),muted,9);
   PAPLabel("H6",c6,table_y+6,PAPText("Status","Statut"),muted,9);
   const int font=(width>=930 ? 10 : 9);
   for(int k=0;k<visible;k++)
     {
      const int i=g_page*g_rows_per_page+k;
      const int row_y=table_y+30+k*40;
      const string key="R"+IntegerToString(i)+"_";
      const color status_color=(g_rows[i].resolved && (g_rows[i].status=="ON_GRID" || g_rows[i].status=="ZERO_WEIGHT") ? green : amber);
      PAPBox(key+"Bg",x+12,row_y,width-24,38,(k%2==0 ? C'23,34,49' : C'20,30,44'));
      PAPLabel(key+"Symbol",c0,row_y+5,PAPShort(g_rows[i].symbol,(c1-c0-8)/7),text,font,g_rows[i].detail);
      PAPLabel(key+"Weight",c0,row_y+22,PAPNumber(g_rows[i].weight,2)+"%",muted,8);
      PAPLabel(key+"Target",c1,row_y+11,PAPNumber(g_rows[i].target,2),text,font);
      PAPLabel(key+"Min",c2,row_y+11,g_rows[i].resolved ? PAPNumber(g_rows[i].minimum_notional,2) : "--",muted,font);
      PAPLabel(key+"Lots",c3,row_y+11,g_rows[i].resolved ? PAPCompactLots(g_rows[i].lots) : "--",text,font);
      PAPLabel(key+"Notional",c4,row_y+11,g_rows[i].resolved ? PAPNumber(g_rows[i].notional,2) : "--",text,font);
      PAPLabel(key+"Gap",c5,row_y+11,g_rows[i].resolved ? PAPNumber(g_rows[i].shortfall,2) : "--",status_color,font);
      PAPLabel(key+"Status",c6,row_y+11,PAPShort(PAPStatus(g_rows[i].status),(width-(c6-x)-16)/7),status_color,font,g_rows[i].detail);
     }
   const int foot=table_y+34+visible*40;
   PAPLabel("Totals",x+16,foot,StringFormat("%s %s %s | %s %s %s",
            PAPText("Calculated:","Calculé :"),PAPNumber(g_allocated,2),g_currency,
            PAPText("not allocated:","non alloué :"),PAPNumber(MathMax(0.0,InpBudget-g_allocated),2),g_currency),text,11);
   PAPLabel("MinBudget",x+16,foot+24,StringFormat("%s %s %s%s",
            PAPText("Minimum notional budget for these weights:","Seuil notionnel pour ces poids :"),PAPNumber(g_minimum_budget,2),g_currency,
            g_unresolved>0 ? PAPText(" (resolved rows only)"," (lignes calculées seulement)") : ""),muted,10);
   PAPLabel("Scope",x+16,foot+45,StringFormat("%s %d | %s %d | %s %s %s",
            PAPText("Calculated rows:","Lignes calculées :"),g_resolved,
            PAPText("unavailable:","indisponibles :"),g_unresolved,
            PAPText("unresolved target:","cible non calculée :"),PAPNumber(g_unresolved_target,2),g_currency),g_unresolved>0 ? amber : muted,9);
   PAPLabel("Limit",x+16,foot+65,PAPText("Notional is neither margin nor maximum loss.",
                                         "Le notionnel n'est ni la marge ni la perte maximale."),muted,9);
   PAPLabel("LimitFunding",x+16,foot+82,PAPText("Minimum estimate is not a recommended account deposit.",
            "Ce seuil n'est pas un capital de compte conseillé."),muted,9);
   PAPButton("Refresh",x+16,foot+107,130,PAPText("Recalculate","Recalculer"));
   if(InpAllowCSVExport)
      PAPButton("Export",x+160,foot+107,120,PAPText("Export CSV","Exporter CSV"));
   else
      PAPLabel("CSVOff",x+160,foot+115,PAPText("CSV: enable in F7 inputs","CSV : activer dans F7"),muted,9);
   if(pages>1)
     {
      PAPButton("Previous",x+width-260,foot+107,42,"<");
      PAPLabel("Page",x+width-210,foot+116,IntegerToString(g_page+1)+" / "+IntegerToString(pages),muted,9);
      PAPButton("Next",x+width-150,foot+107,42,">");
     }
   PAPLabel("ExportNote",x+16,foot+143,PAPShort(g_export_note!="" ? g_export_note :
            PAPText("F7: budget / weights / exact FX symbols. Hover a row for détails.",
                    "F7 : budget / poids / symboles FX exacts. Survoler une ligne pour les détails."),(width-32)/6),muted,9,g_export_note);
   ChartRedraw(0);
  }

// FileWrite inserts delimiters but does not implement CSV escaping.
// Quoting strings preserves exact symbols, separators and line breaks.
string PAPCSVField(string text)
  {
   StringReplace(text,"\"","\"\"");
   return "\""+text+"\"";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PAPExport()
  {
   if(!InpAllowCSVExport || g_error!="" || ArraySize(g_rows)==0)
      return false;
   string timestamp=TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS);
   StringReplace(timestamp,".","");
   StringReplace(timestamp,":","");
   StringReplace(timestamp," ","_");
   const string name="PortfolioAllocationPlanner_"+timestamp+"_"+IntegerToString(ChartID())+"_"+IntegerToString((long)GetTickCount64())+".csv";
   if(FileIsExist(name))
     {
      g_export_note=PAPText("Export cancelled: filename already exists","Export annulé : nom déjà existant");
      return false;
     }
   ResetLastError();
   const int handle=FileOpen(name,FILE_WRITE|FILE_CSV|FILE_ANSI,';',CP_UTF8);
   if(handle==INVALID_HANDLE)
     {
      g_export_note=StringFormat("CSV error %d",GetLastError());
      return false;
     }
   bool ok=FileWrite(handle,"calculated_local_time","hypothetical_budget","budget_currency","symbol","target_pct",
                     "target_notional","minimum_lot_notional","minimum_budget_at_weight","raw_lots","rounded_lots",
                     "calculated_notional","target_shortfall","status","fx_route","detail")>0;
   for(int i=0;i<ArraySize(g_rows) && ok;i++)
      ok=FileWrite(handle,PAPCSVField(TimeToString(g_calculated,TIME_DATE|TIME_SECONDS)),PAPNumber(InpBudget),PAPCSVField(g_currency),PAPCSVField(g_rows[i].symbol),
                   PAPNumber(g_rows[i].weight),PAPNumber(g_rows[i].target),
                   g_rows[i].resolved ? PAPNumber(g_rows[i].minimum_notional) : "",
                   g_rows[i].resolved ? PAPNumber(g_rows[i].minimum_budget) : "",
                   g_rows[i].resolved ? PAPNumber(g_rows[i].raw_lots) : "",
                   g_rows[i].resolved ? PAPNumber(g_rows[i].lots) : "",
                   g_rows[i].resolved ? PAPNumber(g_rows[i].notional) : "",
                   g_rows[i].resolved ? PAPNumber(g_rows[i].shortfall) : "",
                   PAPCSVField(g_rows[i].status),PAPCSVField(g_rows[i].fx_route),PAPCSVField(g_rows[i].detail))>0;
   FileFlush(handle);
   FileClose(handle);
   g_export_note=(ok ? PAPText("Saved in MQL5/Files: ","Enregistré dans MQL5/Files : ")+name :
                  PAPText("CSV write failed; file may be incomplete","Écriture CSV échouée ; fichier potentiellement incomplet"));
   Print("[CSV] "+g_export_note);
   return ok;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_prefix="PAP_"+IntegerToString(ChartID())+"_"+IntegerToString((long)GetTickCount64())+"_";
   PAPCalculate();
   PAPDraw();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_prefix!="")
      ObjectsDeleteAll(0,g_prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      PAPDraw();
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;
   if(sparam==g_prefix+"Refresh")
     {
      PAPCalculate();
      PAPDraw();
     }
   else
      if(sparam==g_prefix+"Export")
        {
         PAPExport();
         PAPDraw();
        }
      else
         if(sparam==g_prefix+"Previous")
           {
            g_page--;
            PAPDraw();
           }
         else
            if(sparam==g_prefix+"Next")
              {
               g_page++;
               PAPDraw();
              }
  }
//+------------------------------------------------------------------+

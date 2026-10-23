//+------------------------------------------------------------------+
//|                                     PendingOrderInspector.mq5 |
//|                                      Copyright 2026, Erdem Kaynak |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Erdem Kaynak"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Read-only static pre-check for BUY STOP and SELL STOP order inputs."
#property description "Does not send, modify, or delete orders. Server may still reject a request."
#property indicator_chart_window
#property indicator_plots 0

#ifndef POSI_CONTRACT_MQH
#define POSI_CONTRACT_MQH

#ifndef POSI_TYPES_MQH
#define POSI_TYPES_MQH

#define POSI_MAX_RULES 24

enum POSI_OrderType
  {
   POSI_BUY_STOP=0,
   POSI_SELL_STOP=1
  };

enum POSI_RuleState
  {
   POSI_PASS=0,
   POSI_FAIL=1,
   POSI_INFO=2,
   POSI_UNKNOWN=3
  };

enum POSI_OverallState
  {
   POSI_CHECKS_PASS=0,
   POSI_INVALID=1,
   POSI_CHECK=2
  };

enum POSI_RuleCode
  {
   POSI_RULE_INPUT_ENTRY=0,
   POSI_RULE_INPUT_VOLUME,
   POSI_RULE_QUOTE,
   POSI_RULE_TICK_GRID_ENTRY,
   POSI_RULE_TICK_GRID_SL,
   POSI_RULE_TICK_GRID_TP,
   POSI_RULE_VOLUME_MIN,
   POSI_RULE_VOLUME_MAX,
   POSI_RULE_VOLUME_STEP,
   POSI_RULE_ENTRY_SIDE,
   POSI_RULE_ENTRY_DISTANCE,
   POSI_RULE_SL_PRESENCE,
   POSI_RULE_SL_SIDE,
   POSI_RULE_SL_DISTANCE,
   POSI_RULE_TP_PRESENCE,
   POSI_RULE_TP_SIDE,
   POSI_RULE_TP_DISTANCE,
   POSI_RULE_TRADE_MODE,
   POSI_RULE_STOP_ORDER_PERMISSION,
   POSI_RULE_SL_PERMISSION,
   POSI_RULE_TP_PERMISSION,
   POSI_RULE_FREEZE_ADVISORY,
   POSI_RULE_SPREAD_INFO
  };

struct POSI_ContractSnapshot
  {
   string            symbol;
   datetime          captured_at;
   datetime          server_time;
   int               digits;
   double            point;
   double            tick_size;
   double            volume_min;
   double            volume_max;
   double            volume_step;
   long              stops_level_points;
   long              freeze_level_points;
   long              trade_mode;
   long              order_mode;
   double            bid;
   double            ask;
   long              tick_time_msc;
   double            quote_age_seconds;
   bool              has_digits;
   bool              has_point;
   bool              has_tick_size;
   bool              has_volume_min;
   bool              has_volume_max;
   bool              has_volume_step;
   bool              has_stops_level;
   bool              has_freeze_level;
   bool              has_trade_mode;
   bool              has_order_mode;
   bool              has_quote;
  };

struct POSI_PendingIntent
  {
   POSI_OrderType    order_type;
   double            entry;
   double            stop_loss;
   double            take_profit;
   double            volume;
   bool              require_stop_loss;
   bool              require_take_profit;
   int               max_quote_age_seconds;
  };

struct POSI_RuleResult
  {
   POSI_RuleCode     code;
   POSI_RuleState    state;
   string            label;
   string            detail;
   double            actual_value;
   double            required_value;
   string            unit;
  };

struct POSI_InspectionReport
  {
   string            symbol;
   datetime          captured_at;
   POSI_OrderType    order_type;
   POSI_OverallState overall;
   POSI_RuleResult   rules[POSI_MAX_RULES];
   int               rule_count;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_RuleCodeToString(const POSI_RuleCode code)
  {
   switch(code)
     {
      case POSI_RULE_INPUT_ENTRY:
         return "INPUT_ENTRY";
      case POSI_RULE_INPUT_VOLUME:
         return "INPUT_VOLUME";
      case POSI_RULE_QUOTE:
         return "QUOTE";
      case POSI_RULE_TICK_GRID_ENTRY:
         return "TICK_GRID_ENTRY";
      case POSI_RULE_TICK_GRID_SL:
         return "TICK_GRID_SL";
      case POSI_RULE_TICK_GRID_TP:
         return "TICK_GRID_TP";
      case POSI_RULE_VOLUME_MIN:
         return "VOLUME_MIN";
      case POSI_RULE_VOLUME_MAX:
         return "VOLUME_MAX";
      case POSI_RULE_VOLUME_STEP:
         return "VOLUME_STEP";
      case POSI_RULE_ENTRY_SIDE:
         return "ENTRY_SIDE";
      case POSI_RULE_ENTRY_DISTANCE:
         return "ENTRY_DISTANCE";
      case POSI_RULE_SL_PRESENCE:
         return "SL_PRESENCE";
      case POSI_RULE_SL_SIDE:
         return "SL_SIDE";
      case POSI_RULE_SL_DISTANCE:
         return "SL_DISTANCE";
      case POSI_RULE_TP_PRESENCE:
         return "TP_PRESENCE";
      case POSI_RULE_TP_SIDE:
         return "TP_SIDE";
      case POSI_RULE_TP_DISTANCE:
         return "TP_DISTANCE";
      case POSI_RULE_TRADE_MODE:
         return "TRADE_MODE";
      case POSI_RULE_STOP_ORDER_PERMISSION:
         return "STOP_ORDER_PERMISSION";
      case POSI_RULE_SL_PERMISSION:
         return "SL_PERMISSION";
      case POSI_RULE_TP_PERMISSION:
         return "TP_PERMISSION";
      case POSI_RULE_FREEZE_ADVISORY:
         return "FREEZE_ADVISORY";
      case POSI_RULE_SPREAD_INFO:
         return "SPREAD_INFO";
     }
   return "UNKNOWN_RULE";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_OverallStateToString(const POSI_OverallState state)
  {
   if(state==POSI_INVALID)
      return "INVALID";
   if(state==POSI_CHECK)
      return "CHECK";
   return "CHECKS PASS";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_RuleStateToString(const POSI_RuleState state)
  {
   if(state==POSI_FAIL)
      return "FAIL";
   if(state==POSI_INFO)
      return "INFO";
   if(state==POSI_UNKNOWN)
      return "UNKNOWN";
   return "PASS";
  }

#endif

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool POSI_ReadContract(const string symbol,POSI_ContractSnapshot &out,string &error_text)
  {
   ZeroMemory(out);
   out.symbol=symbol;
   out.captured_at=TimeLocal();
   out.server_time=TimeTradeServer();
   error_text="";

   long integer_value=0;
   double double_value=0.0;
   ResetLastError();
   out.has_digits=SymbolInfoInteger(symbol,SYMBOL_DIGITS,integer_value);
   if(out.has_digits)
      out.digits=(int)integer_value;
   out.has_point=SymbolInfoDouble(symbol,SYMBOL_POINT,double_value);
   if(out.has_point)
      out.point=double_value;
   out.has_tick_size=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE,double_value);
   if(out.has_tick_size)
      out.tick_size=double_value;
   out.has_volume_min=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,double_value);
   if(out.has_volume_min)
      out.volume_min=double_value;
   out.has_volume_max=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,double_value);
   if(out.has_volume_max)
      out.volume_max=double_value;
   out.has_volume_step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,double_value);
   if(out.has_volume_step)
      out.volume_step=double_value;
   out.has_stops_level=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,integer_value);
   if(out.has_stops_level)
      out.stops_level_points=integer_value;
   out.has_freeze_level=SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL,integer_value);
   if(out.has_freeze_level)
      out.freeze_level_points=integer_value;
   out.has_trade_mode=SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE,integer_value);
   if(out.has_trade_mode)
      out.trade_mode=integer_value;
   out.has_order_mode=SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE,integer_value);
   if(out.has_order_mode)
      out.order_mode=integer_value;

   MqlTick tick;
   ZeroMemory(tick);
   out.has_quote=SymbolInfoTick(symbol,tick) && tick.bid>0.0 && tick.ask>0.0 && tick.ask>=tick.bid;
   if(out.has_quote)
     {
      out.bid=tick.bid;
      out.ask=tick.ask;
      out.tick_time_msc=tick.time_msc;
      if(out.server_time>0 && tick.time>0)
         out.quote_age_seconds=(double)(out.server_time-tick.time);
     }

   if(!out.has_point || !out.has_tick_size || !out.has_volume_min ||
      !out.has_volume_max || !out.has_volume_step)
     {
      error_text=StringFormat("Required contract fields unavailable (error %d)",GetLastError());
      return false;
     }
   return true;
  }

#endif
#ifndef POSI_VALIDATOR_MQH
#define POSI_VALIDATOR_MQH

#ifndef POSI_TYPES_MQH
#define POSI_TYPES_MQH

#define POSI_MAX_RULES 24

enum POSI_OrderType
  {
   POSI_BUY_STOP=0,
   POSI_SELL_STOP=1
  };

enum POSI_RuleState
  {
   POSI_PASS=0,
   POSI_FAIL=1,
   POSI_INFO=2,
   POSI_UNKNOWN=3
  };

enum POSI_OverallState
  {
   POSI_CHECKS_PASS=0,
   POSI_INVALID=1,
   POSI_CHECK=2
  };

enum POSI_RuleCode
  {
   POSI_RULE_INPUT_ENTRY=0,
   POSI_RULE_INPUT_VOLUME,
   POSI_RULE_QUOTE,
   POSI_RULE_TICK_GRID_ENTRY,
   POSI_RULE_TICK_GRID_SL,
   POSI_RULE_TICK_GRID_TP,
   POSI_RULE_VOLUME_MIN,
   POSI_RULE_VOLUME_MAX,
   POSI_RULE_VOLUME_STEP,
   POSI_RULE_ENTRY_SIDE,
   POSI_RULE_ENTRY_DISTANCE,
   POSI_RULE_SL_PRESENCE,
   POSI_RULE_SL_SIDE,
   POSI_RULE_SL_DISTANCE,
   POSI_RULE_TP_PRESENCE,
   POSI_RULE_TP_SIDE,
   POSI_RULE_TP_DISTANCE,
   POSI_RULE_TRADE_MODE,
   POSI_RULE_STOP_ORDER_PERMISSION,
   POSI_RULE_SL_PERMISSION,
   POSI_RULE_TP_PERMISSION,
   POSI_RULE_FREEZE_ADVISORY,
   POSI_RULE_SPREAD_INFO
  };

struct POSI_ContractSnapshot
  {
   string            symbol;
   datetime          captured_at;
   datetime          server_time;
   int               digits;
   double            point;
   double            tick_size;
   double            volume_min;
   double            volume_max;
   double            volume_step;
   long              stops_level_points;
   long              freeze_level_points;
   long              trade_mode;
   long              order_mode;
   double            bid;
   double            ask;
   long              tick_time_msc;
   double            quote_age_seconds;
   bool              has_digits;
   bool              has_point;
   bool              has_tick_size;
   bool              has_volume_min;
   bool              has_volume_max;
   bool              has_volume_step;
   bool              has_stops_level;
   bool              has_freeze_level;
   bool              has_trade_mode;
   bool              has_order_mode;
   bool              has_quote;
  };

struct POSI_PendingIntent
  {
   POSI_OrderType    order_type;
   double            entry;
   double            stop_loss;
   double            take_profit;
   double            volume;
   bool              require_stop_loss;
   bool              require_take_profit;
   int               max_quote_age_seconds;
  };

struct POSI_RuleResult
  {
   POSI_RuleCode     code;
   POSI_RuleState    state;
   string            label;
   string            detail;
   double            actual_value;
   double            required_value;
   string            unit;
  };

struct POSI_InspectionReport
  {
   string            symbol;
   datetime          captured_at;
   POSI_OrderType    order_type;
   POSI_OverallState overall;
   POSI_RuleResult   rules[POSI_MAX_RULES];
   int               rule_count;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_RuleCodeToString(const POSI_RuleCode code)
  {
   switch(code)
     {
      case POSI_RULE_INPUT_ENTRY:
         return "INPUT_ENTRY";
      case POSI_RULE_INPUT_VOLUME:
         return "INPUT_VOLUME";
      case POSI_RULE_QUOTE:
         return "QUOTE";
      case POSI_RULE_TICK_GRID_ENTRY:
         return "TICK_GRID_ENTRY";
      case POSI_RULE_TICK_GRID_SL:
         return "TICK_GRID_SL";
      case POSI_RULE_TICK_GRID_TP:
         return "TICK_GRID_TP";
      case POSI_RULE_VOLUME_MIN:
         return "VOLUME_MIN";
      case POSI_RULE_VOLUME_MAX:
         return "VOLUME_MAX";
      case POSI_RULE_VOLUME_STEP:
         return "VOLUME_STEP";
      case POSI_RULE_ENTRY_SIDE:
         return "ENTRY_SIDE";
      case POSI_RULE_ENTRY_DISTANCE:
         return "ENTRY_DISTANCE";
      case POSI_RULE_SL_PRESENCE:
         return "SL_PRESENCE";
      case POSI_RULE_SL_SIDE:
         return "SL_SIDE";
      case POSI_RULE_SL_DISTANCE:
         return "SL_DISTANCE";
      case POSI_RULE_TP_PRESENCE:
         return "TP_PRESENCE";
      case POSI_RULE_TP_SIDE:
         return "TP_SIDE";
      case POSI_RULE_TP_DISTANCE:
         return "TP_DISTANCE";
      case POSI_RULE_TRADE_MODE:
         return "TRADE_MODE";
      case POSI_RULE_STOP_ORDER_PERMISSION:
         return "STOP_ORDER_PERMISSION";
      case POSI_RULE_SL_PERMISSION:
         return "SL_PERMISSION";
      case POSI_RULE_TP_PERMISSION:
         return "TP_PERMISSION";
      case POSI_RULE_FREEZE_ADVISORY:
         return "FREEZE_ADVISORY";
      case POSI_RULE_SPREAD_INFO:
         return "SPREAD_INFO";
     }
   return "UNKNOWN_RULE";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_OverallStateToString(const POSI_OverallState state)
  {
   if(state==POSI_INVALID)
      return "INVALID";
   if(state==POSI_CHECK)
      return "CHECK";
   return "CHECKS PASS";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_RuleStateToString(const POSI_RuleState state)
  {
   if(state==POSI_FAIL)
      return "FAIL";
   if(state==POSI_INFO)
      return "INFO";
   if(state==POSI_UNKNOWN)
      return "UNKNOWN";
   return "PASS";
  }

#endif

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_AddRule(POSI_InspectionReport &report,const POSI_RuleCode code,
                  const POSI_RuleState state,const string label,const string detail,
                  const double actual=0.0,const double required=0.0,const string unit="")
  {
   if(report.rule_count>=POSI_MAX_RULES)
      return;
   int i=report.rule_count++;
   report.rules[i].code=code;
   report.rules[i].state=state;
   report.rules[i].label=label;
   report.rules[i].detail=detail;
   report.rules[i].actual_value=actual;
   report.rules[i].required_value=required;
   report.rules[i].unit=unit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool POSI_IsFinitePositive(const double value)
  {
   return MathIsValidNumber(value) && value>0.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double POSI_AbsTolerance(const double quantum)
  {
   return MathMax(MathAbs(quantum)*1.0e-7,1.0e-12);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool POSI_IsOnGrid(const double value,const double quantum)
  {
   if(!MathIsValidNumber(value) || !POSI_IsFinitePositive(quantum))
      return false;
   double steps=value/quantum;
   if(!MathIsValidNumber(steps))
      return false;
   double nearest=MathRound(steps)*quantum;
   return MathAbs(value-nearest)<=POSI_AbsTolerance(quantum);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool POSI_IsVolumeOnStep(const double volume,const double step)
  {
// MQL5 documentation defines permitted volume as a multiple of SYMBOL_VOLUME_STEP.
   return POSI_IsOnGrid(volume,step);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double POSI_ToPoints(const double price_distance,const POSI_ContractSnapshot &contract)
  {
   if(!contract.has_point || !POSI_IsFinitePositive(contract.point))
      return 0.0;
   return price_distance/contract.point;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_AddPriceGridRule(POSI_InspectionReport &report,const POSI_RuleCode code,
                           const string label,const double price,
                           const POSI_ContractSnapshot &contract)
  {
   if(price==0.0)
      return;
   if(!contract.has_tick_size || !POSI_IsFinitePositive(contract.tick_size))
     {
      POSI_AddRule(report,code,POSI_UNKNOWN,label,"Tick size is unavailable");
      return;
     }
   bool ok=POSI_IsOnGrid(price,contract.tick_size);
   double lower=MathFloor(price/contract.tick_size)*contract.tick_size;
   double upper=MathCeil(price/contract.tick_size)*contract.tick_size;
   POSI_AddRule(report,code,ok ? POSI_PASS : POSI_FAIL,label,
                ok ? "Price is on the broker tick grid" :
                StringFormat("Off tick %s; grid neighbors %s / %s",
                             DoubleToString(contract.tick_size,contract.digits),
                             DoubleToString(lower,contract.digits),DoubleToString(upper,contract.digits)),
                price,contract.tick_size,"price");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_Finalize(POSI_InspectionReport &report)
  {
   bool failed=false;
   bool unknown=false;
   for(int i=0;i<report.rule_count;i++)
     {
      if(report.rules[i].state==POSI_FAIL)
         failed=true;
      if(report.rules[i].state==POSI_UNKNOWN)
         unknown=true;
     }
   report.overall=failed ? POSI_INVALID : (unknown ? POSI_CHECK : POSI_CHECKS_PASS);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
POSI_InspectionReport POSI_Inspect(const POSI_ContractSnapshot &contract,
                                   const POSI_PendingIntent &intent)
  {
   POSI_InspectionReport report;
   ZeroMemory(report);
   report.symbol=contract.symbol;
   report.captured_at=contract.captured_at;
   report.order_type=intent.order_type;

   bool entry_ok=POSI_IsFinitePositive(intent.entry);
   POSI_RuleState entry_state=(entry_ok ? POSI_PASS : (intent.entry==0.0 ? POSI_UNKNOWN : POSI_FAIL));
   POSI_AddRule(report,POSI_RULE_INPUT_ENTRY,entry_state,
                "Entry input",entry_ok ? "Entry is positive and finite" :
                (intent.entry==0.0 ? "Set an entry price in Inputs" : "Entry must be a positive finite price"));
   bool volume_ok=POSI_IsFinitePositive(intent.volume);
   POSI_AddRule(report,POSI_RULE_INPUT_VOLUME,volume_ok ? POSI_PASS : POSI_FAIL,
                "Volume input",volume_ok ? "Volume is positive and finite" : "Set a positive finite volume");

   bool quote_fresh=contract.has_quote && intent.max_quote_age_seconds>0 &&
                    contract.server_time>0 && contract.quote_age_seconds>=0.0 &&
                    contract.quote_age_seconds<=(double)intent.max_quote_age_seconds;
   if(quote_fresh)
      POSI_AddRule(report,POSI_RULE_QUOTE,POSI_PASS,"Live quote",
                   StringFormat("Bid and Ask available; quote age %.0f sec",contract.quote_age_seconds));
   else
      POSI_AddRule(report,POSI_RULE_QUOTE,POSI_UNKNOWN,"Live quote",
                   contract.has_quote ? StringFormat("Quote is stale or age is unknown (%.0f sec)",contract.quote_age_seconds) :
                   "No usable Bid/Ask quote; price-side checks cannot pass");

   if(entry_ok)
      POSI_AddPriceGridRule(report,POSI_RULE_TICK_GRID_ENTRY,"Entry tick grid",intent.entry,contract);
   if(intent.stop_loss!=0.0)
     {
      if(!POSI_IsFinitePositive(intent.stop_loss))
         POSI_AddRule(report,POSI_RULE_TICK_GRID_SL,POSI_FAIL,"SL input","SL must be zero or a positive finite price");
      else
         POSI_AddPriceGridRule(report,POSI_RULE_TICK_GRID_SL,"SL tick grid",intent.stop_loss,contract);
     }
   if(intent.take_profit!=0.0)
     {
      if(!POSI_IsFinitePositive(intent.take_profit))
         POSI_AddRule(report,POSI_RULE_TICK_GRID_TP,POSI_FAIL,"TP input","TP must be zero or a positive finite price");
      else
         POSI_AddPriceGridRule(report,POSI_RULE_TICK_GRID_TP,"TP tick grid",intent.take_profit,contract);
     }

   if(volume_ok)
     {
      if(!contract.has_volume_min || !POSI_IsFinitePositive(contract.volume_min))
         POSI_AddRule(report,POSI_RULE_VOLUME_MIN,POSI_UNKNOWN,"Minimum volume","Minimum volume is unavailable");
      else
        {
         double tol=POSI_AbsTolerance(contract.volume_step);
         bool ok=intent.volume+tol>=contract.volume_min;
         POSI_AddRule(report,POSI_RULE_VOLUME_MIN,ok ? POSI_PASS : POSI_FAIL,"Minimum volume",
                      ok ? "Volume meets minimum" : "Volume is below broker minimum",
                      intent.volume,contract.volume_min,"lots");
        }
      if(!contract.has_volume_max || !POSI_IsFinitePositive(contract.volume_max))
         POSI_AddRule(report,POSI_RULE_VOLUME_MAX,POSI_UNKNOWN,"Maximum volume","Maximum volume is unavailable");
      else
        {
         double tol=POSI_AbsTolerance(contract.volume_step);
         bool ok=intent.volume-tol<=contract.volume_max;
         POSI_AddRule(report,POSI_RULE_VOLUME_MAX,ok ? POSI_PASS : POSI_FAIL,"Maximum volume",
                      ok ? "Volume meets maximum" : "Volume is above broker maximum",
                      intent.volume,contract.volume_max,"lots");
        }
      if(!contract.has_volume_step || !POSI_IsFinitePositive(contract.volume_step))
         POSI_AddRule(report,POSI_RULE_VOLUME_STEP,POSI_UNKNOWN,"Volume step","Volume step is unavailable");
      else
        {
         bool ok=POSI_IsVolumeOnStep(intent.volume,contract.volume_step);
         double lower=MathFloor(intent.volume/contract.volume_step)*contract.volume_step;
         double upper=MathCeil(intent.volume/contract.volume_step)*contract.volume_step;
         string lower_text=(contract.has_volume_min && lower<contract.volume_min-POSI_AbsTolerance(contract.volume_step)) ?
                           "N/A (outside limits)" : DoubleToString(lower,4);
         string upper_text=(contract.has_volume_max && upper>contract.volume_max+POSI_AbsTolerance(contract.volume_step)) ?
                           "N/A (outside limits)" : DoubleToString(upper,4);
         POSI_AddRule(report,POSI_RULE_VOLUME_STEP,ok ? POSI_PASS : POSI_FAIL,"Volume step",
                      ok ? "Volume is a multiple of broker step" :
                      StringFormat("Off step %.4f; grid neighbors %s / %s",contract.volume_step,lower_text,upper_text),
                      intent.volume,contract.volume_step,"lots");
        }
     }

   double reference=0.0;
   if(quote_fresh && entry_ok)
     {
      reference=(intent.order_type==POSI_BUY_STOP ? contract.ask : contract.bid);
      bool side_ok=(intent.order_type==POSI_BUY_STOP ? intent.entry>reference : intent.entry<reference);
      POSI_AddRule(report,POSI_RULE_ENTRY_SIDE,side_ok ? POSI_PASS : POSI_FAIL,"Entry side",
                   side_ok ? "Entry is on the correct side of market" :
                   (intent.order_type==POSI_BUY_STOP ? "BUY STOP entry must be above Ask" : "SELL STOP entry must be below Bid"),
                   intent.entry,reference,"price");
      if(!contract.has_stops_level || !contract.has_point || !POSI_IsFinitePositive(contract.point))
         POSI_AddRule(report,POSI_RULE_ENTRY_DISTANCE,POSI_UNKNOWN,"Entry distance","Stops level or point is unavailable");
      else
        {
         double distance=(intent.order_type==POSI_BUY_STOP ? intent.entry-reference : reference-intent.entry);
         double actual_points=POSI_ToPoints(distance,contract);
         double required=(double)contract.stops_level_points;
         bool ok=actual_points+1.0e-7>=required;
         string distance_detail;
         if(actual_points<0.0)
            distance_detail=StringFormat("Entry %.1f points %s %s; %s must be %s %s",
                                         MathAbs(actual_points),intent.order_type==POSI_BUY_STOP ? "below" : "above",
                                         intent.order_type==POSI_BUY_STOP ? "Ask" : "Bid",
                                         intent.order_type==POSI_BUY_STOP ? "BUY STOP" : "SELL STOP",
                                         intent.order_type==POSI_BUY_STOP ? "above" : "below",
                                         intent.order_type==POSI_BUY_STOP ? "Ask" : "Bid");
         else
            distance_detail=StringFormat("Distance %.1f pts; required %.1f pts",actual_points,required);
         POSI_AddRule(report,POSI_RULE_ENTRY_DISTANCE,ok ? POSI_PASS : POSI_FAIL,"Entry distance",
                      distance_detail,
                      actual_points,required,"points");
        }
     }
   else
     {
      POSI_AddRule(report,POSI_RULE_ENTRY_SIDE,POSI_UNKNOWN,"Entry side","Usable entry and live quote are required");
      POSI_AddRule(report,POSI_RULE_ENTRY_DISTANCE,POSI_UNKNOWN,"Entry distance","Usable entry and live quote are required");
     }

   if(intent.stop_loss==0.0)
      POSI_AddRule(report,POSI_RULE_SL_PRESENCE,intent.require_stop_loss ? POSI_FAIL : POSI_INFO,
                   "Stop Loss",intent.require_stop_loss ? "SL is required by input setting" : "SL is not set (optional)");
   else
      if(POSI_IsFinitePositive(intent.stop_loss) && entry_ok)
        {
         bool side_ok=(intent.order_type==POSI_BUY_STOP ? intent.stop_loss<intent.entry : intent.stop_loss>intent.entry);
         POSI_AddRule(report,POSI_RULE_SL_SIDE,side_ok ? POSI_PASS : POSI_FAIL,"SL side",
                      side_ok ? "SL is on the protective side of entry" : "SL is on the wrong side of entry");
         if(!contract.has_stops_level || !contract.has_point || !POSI_IsFinitePositive(contract.point))
            POSI_AddRule(report,POSI_RULE_SL_DISTANCE,POSI_UNKNOWN,"SL distance","Stops level or point is unavailable");
         else
           {
            double points=POSI_ToPoints(MathAbs(intent.entry-intent.stop_loss),contract);
            bool ok=points+1.0e-7>=(double)contract.stops_level_points;
            POSI_AddRule(report,POSI_RULE_SL_DISTANCE,ok ? POSI_PASS : POSI_FAIL,"SL distance",
                         StringFormat("Distance %.1f pts; required %.1f pts",points,(double)contract.stops_level_points),
                         points,(double)contract.stops_level_points,"points");
           }
        }

   if(intent.take_profit==0.0)
      POSI_AddRule(report,POSI_RULE_TP_PRESENCE,intent.require_take_profit ? POSI_FAIL : POSI_INFO,
                   "Take Profit",intent.require_take_profit ? "TP is required by input setting" : "TP is not set (optional)");
   else
      if(POSI_IsFinitePositive(intent.take_profit) && entry_ok)
        {
         bool side_ok=(intent.order_type==POSI_BUY_STOP ? intent.take_profit>intent.entry : intent.take_profit<intent.entry);
         POSI_AddRule(report,POSI_RULE_TP_SIDE,side_ok ? POSI_PASS : POSI_FAIL,"TP side",
                      side_ok ? "TP is on the target side of entry" : "TP is on the wrong side of entry");
         if(!contract.has_stops_level || !contract.has_point || !POSI_IsFinitePositive(contract.point))
            POSI_AddRule(report,POSI_RULE_TP_DISTANCE,POSI_UNKNOWN,"TP distance","Stops level or point is unavailable");
         else
           {
            double points=POSI_ToPoints(MathAbs(intent.take_profit-intent.entry),contract);
            bool ok=points+1.0e-7>=(double)contract.stops_level_points;
            POSI_AddRule(report,POSI_RULE_TP_DISTANCE,ok ? POSI_PASS : POSI_FAIL,"TP distance",
                         StringFormat("Distance %.1f pts; required %.1f pts",points,(double)contract.stops_level_points),
                         points,(double)contract.stops_level_points,"points");
           }
        }

   if(!contract.has_trade_mode)
      POSI_AddRule(report,POSI_RULE_TRADE_MODE,POSI_UNKNOWN,"Trade mode","Trade mode is unavailable");
   else
     {
      bool disabled=(contract.trade_mode==SYMBOL_TRADE_MODE_DISABLED || contract.trade_mode==SYMBOL_TRADE_MODE_CLOSEONLY);
      bool wrong_side=(intent.order_type==POSI_BUY_STOP && contract.trade_mode==SYMBOL_TRADE_MODE_SHORTONLY) ||
                      (intent.order_type==POSI_SELL_STOP && contract.trade_mode==SYMBOL_TRADE_MODE_LONGONLY);
      POSI_AddRule(report,POSI_RULE_TRADE_MODE,(disabled || wrong_side) ? POSI_FAIL : POSI_PASS,
                   "Trade mode",disabled ? "Symbol does not allow new entries" :
                   (wrong_side ? "Selected direction is disabled for this symbol" : "Selected direction is allowed by symbol trade mode"));
     }

   if(!contract.has_order_mode)
     {
      POSI_AddRule(report,POSI_RULE_STOP_ORDER_PERMISSION,POSI_UNKNOWN,"Stop-order permission","Order-mode flags are unavailable");
      if(intent.stop_loss!=0.0 || intent.require_stop_loss)
         POSI_AddRule(report,POSI_RULE_SL_PERMISSION,POSI_UNKNOWN,"SL permission","Order-mode flags are unavailable");
      if(intent.take_profit!=0.0 || intent.require_take_profit)
         POSI_AddRule(report,POSI_RULE_TP_PERMISSION,POSI_UNKNOWN,"TP permission","Order-mode flags are unavailable");
     }
   else
     {
      bool stop_allowed=((contract.order_mode & SYMBOL_ORDER_STOP)==SYMBOL_ORDER_STOP);
      POSI_AddRule(report,POSI_RULE_STOP_ORDER_PERMISSION,stop_allowed ? POSI_PASS : POSI_FAIL,
                   "Stop-order permission",stop_allowed ? "Stop pending orders are enabled" : "Stop pending orders are disabled for this symbol");
      if(intent.stop_loss!=0.0 || intent.require_stop_loss)
        {
         bool sl_allowed=((contract.order_mode & SYMBOL_ORDER_SL)==SYMBOL_ORDER_SL);
         POSI_AddRule(report,POSI_RULE_SL_PERMISSION,sl_allowed ? POSI_PASS : POSI_FAIL,
                      "SL permission",sl_allowed ? "Stop Loss is enabled" : "Stop Loss is disabled for this symbol");
        }
      if(intent.take_profit!=0.0 || intent.require_take_profit)
        {
         bool tp_allowed=((contract.order_mode & SYMBOL_ORDER_TP)==SYMBOL_ORDER_TP);
         POSI_AddRule(report,POSI_RULE_TP_PERMISSION,tp_allowed ? POSI_PASS : POSI_FAIL,
                      "TP permission",tp_allowed ? "Take Profit is enabled" : "Take Profit is disabled for this symbol");
        }
     }

   if(!contract.has_freeze_level)
      POSI_AddRule(report,POSI_RULE_FREEZE_ADVISORY,POSI_UNKNOWN,"Freeze level","Freeze level is unavailable");
   else
      POSI_AddRule(report,POSI_RULE_FREEZE_ADVISORY,POSI_INFO,"Freeze level",
                   StringFormat("Advisory only: %d points; server context still applies",contract.freeze_level_points),
                   (double)contract.freeze_level_points,0.0,"points");

   if(quote_fresh && contract.has_point && POSI_IsFinitePositive(contract.point))
     {
      double spread=POSI_ToPoints(contract.ask-contract.bid,contract);
      POSI_AddRule(report,POSI_RULE_SPREAD_INFO,POSI_INFO,"Current spread",StringFormat("%.1f points",spread),spread,0.0,"points");
     }
   else
      POSI_AddRule(report,POSI_RULE_SPREAD_INFO,POSI_UNKNOWN,"Current spread","Spread is unavailable");

   POSI_Finalize(report);
   return report;
  }

#endif
#ifndef POSI_PANEL_MQH
#define POSI_PANEL_MQH

#ifndef POSI_TYPES_MQH
#define POSI_TYPES_MQH

#define POSI_MAX_RULES 24

enum POSI_OrderType
  {
   POSI_BUY_STOP=0,
   POSI_SELL_STOP=1
  };

enum POSI_RuleState
  {
   POSI_PASS=0,
   POSI_FAIL=1,
   POSI_INFO=2,
   POSI_UNKNOWN=3
  };

enum POSI_OverallState
  {
   POSI_CHECKS_PASS=0,
   POSI_INVALID=1,
   POSI_CHECK=2
  };

enum POSI_RuleCode
  {
   POSI_RULE_INPUT_ENTRY=0,
   POSI_RULE_INPUT_VOLUME,
   POSI_RULE_QUOTE,
   POSI_RULE_TICK_GRID_ENTRY,
   POSI_RULE_TICK_GRID_SL,
   POSI_RULE_TICK_GRID_TP,
   POSI_RULE_VOLUME_MIN,
   POSI_RULE_VOLUME_MAX,
   POSI_RULE_VOLUME_STEP,
   POSI_RULE_ENTRY_SIDE,
   POSI_RULE_ENTRY_DISTANCE,
   POSI_RULE_SL_PRESENCE,
   POSI_RULE_SL_SIDE,
   POSI_RULE_SL_DISTANCE,
   POSI_RULE_TP_PRESENCE,
   POSI_RULE_TP_SIDE,
   POSI_RULE_TP_DISTANCE,
   POSI_RULE_TRADE_MODE,
   POSI_RULE_STOP_ORDER_PERMISSION,
   POSI_RULE_SL_PERMISSION,
   POSI_RULE_TP_PERMISSION,
   POSI_RULE_FREEZE_ADVISORY,
   POSI_RULE_SPREAD_INFO
  };

struct POSI_ContractSnapshot
  {
   string            symbol;
   datetime          captured_at;
   datetime          server_time;
   int               digits;
   double            point;
   double            tick_size;
   double            volume_min;
   double            volume_max;
   double            volume_step;
   long              stops_level_points;
   long              freeze_level_points;
   long              trade_mode;
   long              order_mode;
   double            bid;
   double            ask;
   long              tick_time_msc;
   double            quote_age_seconds;
   bool              has_digits;
   bool              has_point;
   bool              has_tick_size;
   bool              has_volume_min;
   bool              has_volume_max;
   bool              has_volume_step;
   bool              has_stops_level;
   bool              has_freeze_level;
   bool              has_trade_mode;
   bool              has_order_mode;
   bool              has_quote;
  };

struct POSI_PendingIntent
  {
   POSI_OrderType    order_type;
   double            entry;
   double            stop_loss;
   double            take_profit;
   double            volume;
   bool              require_stop_loss;
   bool              require_take_profit;
   int               max_quote_age_seconds;
  };

struct POSI_RuleResult
  {
   POSI_RuleCode     code;
   POSI_RuleState    state;
   string            label;
   string            detail;
   double            actual_value;
   double            required_value;
   string            unit;
  };

struct POSI_InspectionReport
  {
   string            symbol;
   datetime          captured_at;
   POSI_OrderType    order_type;
   POSI_OverallState overall;
   POSI_RuleResult   rules[POSI_MAX_RULES];
   int               rule_count;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_RuleCodeToString(const POSI_RuleCode code)
  {
   switch(code)
     {
      case POSI_RULE_INPUT_ENTRY:
         return "INPUT_ENTRY";
      case POSI_RULE_INPUT_VOLUME:
         return "INPUT_VOLUME";
      case POSI_RULE_QUOTE:
         return "QUOTE";
      case POSI_RULE_TICK_GRID_ENTRY:
         return "TICK_GRID_ENTRY";
      case POSI_RULE_TICK_GRID_SL:
         return "TICK_GRID_SL";
      case POSI_RULE_TICK_GRID_TP:
         return "TICK_GRID_TP";
      case POSI_RULE_VOLUME_MIN:
         return "VOLUME_MIN";
      case POSI_RULE_VOLUME_MAX:
         return "VOLUME_MAX";
      case POSI_RULE_VOLUME_STEP:
         return "VOLUME_STEP";
      case POSI_RULE_ENTRY_SIDE:
         return "ENTRY_SIDE";
      case POSI_RULE_ENTRY_DISTANCE:
         return "ENTRY_DISTANCE";
      case POSI_RULE_SL_PRESENCE:
         return "SL_PRESENCE";
      case POSI_RULE_SL_SIDE:
         return "SL_SIDE";
      case POSI_RULE_SL_DISTANCE:
         return "SL_DISTANCE";
      case POSI_RULE_TP_PRESENCE:
         return "TP_PRESENCE";
      case POSI_RULE_TP_SIDE:
         return "TP_SIDE";
      case POSI_RULE_TP_DISTANCE:
         return "TP_DISTANCE";
      case POSI_RULE_TRADE_MODE:
         return "TRADE_MODE";
      case POSI_RULE_STOP_ORDER_PERMISSION:
         return "STOP_ORDER_PERMISSION";
      case POSI_RULE_SL_PERMISSION:
         return "SL_PERMISSION";
      case POSI_RULE_TP_PERMISSION:
         return "TP_PERMISSION";
      case POSI_RULE_FREEZE_ADVISORY:
         return "FREEZE_ADVISORY";
      case POSI_RULE_SPREAD_INFO:
         return "SPREAD_INFO";
     }
   return "UNKNOWN_RULE";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_OverallStateToString(const POSI_OverallState state)
  {
   if(state==POSI_INVALID)
      return "INVALID";
   if(state==POSI_CHECK)
      return "CHECK";
   return "CHECKS PASS";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_RuleStateToString(const POSI_RuleState state)
  {
   if(state==POSI_FAIL)
      return "FAIL";
   if(state==POSI_INFO)
      return "INFO";
   if(state==POSI_UNKNOWN)
      return "UNKNOWN";
   return "PASS";
  }

#endif

struct POSI_PanelTheme
  {
   color             background;
   color             border;
   color             primary;
   color             warning;
   color             invalid;
   color             success;
   color             text;
   color             muted;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
POSI_PanelTheme POSI_DefaultTheme()
  {
   POSI_PanelTheme t;
   t.background=C'9,25,48';
   t.border=C'31,78,121';
   t.primary=C'52,152,219';
   t.warning=C'245,166,35';
   t.invalid=C'231,76,60';
   t.success=C'46,204,113';
   t.text=C'238,244,252';
   t.muted=C'151,169,190';
   return t;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_DeleteObjects(const string prefix)
  {
   ObjectsDeleteAll(0,prefix);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool POSI_SetLabel(const string name,const string text,const int x,const int y,
                   const int size,const color clr,const ENUM_BASE_CORNER corner)
  {
   if(ObjectFind(0,name)<0 && !ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetString(0,name,OBJPROP_FONT,"Segoe UI");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool POSI_SetBackground(const string name,const int x,const int y,const int width,
                        const int height,const POSI_PanelTheme &theme,
                        const ENUM_BASE_CORNER corner)
  {
   if(ObjectFind(0,name)<0 && !ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,theme.background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,theme.border);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color POSI_StateColor(const POSI_RuleState state,const POSI_PanelTheme &theme)
  {
   if(state==POSI_FAIL)
      return theme.invalid;
   if(state==POSI_UNKNOWN)
      return theme.warning;
   if(state==POSI_INFO)
      return theme.muted;
   return theme.success;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string POSI_OrderTypeText(const POSI_OrderType type)
  {
   return type==POSI_BUY_STOP ? "BUY STOP" : "SELL STOP";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_RenderPanel(const string prefix,const POSI_InspectionReport &report,
                      const POSI_ContractSnapshot &contract,const POSI_PendingIntent &intent,
                      const int panel_x,const int panel_y,const ENUM_BASE_CORNER corner,
                      const POSI_PanelTheme &theme)
  {
   int chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int width=MathMax(360,MathMin(650,chart_width-panel_x-8));
   const int row_height=18;
   int visible_rules=0;
   for(int i=0;i<report.rule_count;i++)
      if(report.rules[i].state!=POSI_PASS)
        {
         visible_rules++;
         string probe=report.rules[i].label+": "+report.rules[i].detail;
         if(StringLen(probe)>60)
            visible_rules++;
        }
   int height=252+visible_rules*row_height;
   POSI_SetBackground(prefix+"BG",panel_x,panel_y,width,height,theme,corner);

   int x=panel_x+16;
   int y=panel_y+13;
   POSI_SetLabel(prefix+"TITLE","PENDING ORDER INSPECTOR",x,y,13,theme.text,corner);
   y+=27;
   color overall_color=(report.overall==POSI_INVALID ? theme.invalid :
                        (report.overall==POSI_CHECK ? theme.warning : theme.success));
   POSI_SetLabel(prefix+"STATE",POSI_OverallStateToString(report.overall),x,y,16,overall_color,corner);
   POSI_SetLabel(prefix+"TYPE",POSI_OrderTypeText(intent.order_type)+"  |  "+report.symbol,x+190,y+3,10,theme.primary,corner);
   y+=30;
   int digits=(contract.has_digits ? contract.digits : 5);
   POSI_SetLabel(prefix+"INTENT",StringFormat("Entry %s   SL %s   TP %s   Vol %s",
                 DoubleToString(intent.entry,digits),DoubleToString(intent.stop_loss,digits),
                 DoubleToString(intent.take_profit,digits),DoubleToString(intent.volume,4)),x,y,10,theme.text,corner);
   y+=22;
   bool quote_fresh=contract.has_quote && intent.max_quote_age_seconds>0 && contract.server_time>0 &&
                    contract.quote_age_seconds>=0.0 && contract.quote_age_seconds<=(double)intent.max_quote_age_seconds;
   string quote=(contract.has_quote ? StringFormat("Bid %s   Ask %s   Age %.0fs",DoubleToString(contract.bid,digits),DoubleToString(contract.ask,digits),contract.quote_age_seconds) : "Bid/Ask unavailable");
   POSI_SetLabel(prefix+"QUOTE",quote,x,y,9,quote_fresh ? theme.muted : theme.warning,corner);
   y+=22;
   string facts=StringFormat("Distance pt %s | Price tick %s | Stops %d | Freeze %d",
                             contract.has_point ? DoubleToString(contract.point,digits) : "N/A",
                             (contract.has_tick_size && contract.tick_size>0.0) ? DoubleToString(contract.tick_size,digits) : "N/A",
                             contract.has_stops_level ? contract.stops_level_points : -1,
                             contract.has_freeze_level ? contract.freeze_level_points : -1);
   POSI_SetLabel(prefix+"FACTS",facts,x,y,9,theme.muted,corner);
   y+=22;
   string volume=StringFormat("Volume min %s | step %s | max %s",
                              contract.has_volume_min ? DoubleToString(contract.volume_min,4) : "N/A",
                              contract.has_volume_step ? DoubleToString(contract.volume_step,4) : "N/A",
                              contract.has_volume_max ? DoubleToString(contract.volume_max,4) : "N/A");
   POSI_SetLabel(prefix+"VOLUME",volume,x,y,9,theme.muted,corner);
   y+=22;
   string permissions="Permissions ";
   if(!contract.has_order_mode)
      permissions+="N/A";
   else
      permissions+=StringFormat("STOP %s | SL %s | TP %s",
                                ((contract.order_mode & SYMBOL_ORDER_STOP)==SYMBOL_ORDER_STOP) ? "YES" : "NO",
                                ((contract.order_mode & SYMBOL_ORDER_SL)==SYMBOL_ORDER_SL) ? "YES" : "NO",
                                ((contract.order_mode & SYMBOL_ORDER_TP)==SYMBOL_ORDER_TP) ? "YES" : "NO");
   POSI_SetLabel(prefix+"PERMISSIONS",permissions,x,y,9,contract.has_order_mode ? theme.muted : theme.warning,corner);
   y+=25;

   ObjectsDeleteAll(0,prefix+"RULE_");
   int rendered=0;
   for(int i=0;i<report.rule_count;i++)
     {
      if(report.rules[i].state==POSI_PASS)
         continue;
      string marker=(report.rules[i].state==POSI_FAIL ? "X" :
                     (report.rules[i].state==POSI_UNKNOWN ? "?" : "i"));
      string line=marker+"  "+report.rules[i].label+": "+report.rules[i].detail;
      color rule_color=POSI_StateColor(report.rules[i].state,theme);
      if(StringLen(line)<=62)
        {
         POSI_SetLabel(prefix+"RULE_"+IntegerToString(rendered),line,x,y,9,rule_color,corner);
         y+=row_height;
         rendered++;
        }
      else
        {
         int split=62;
         for(int p=62;p>35;p--)
            if(StringGetCharacter(line,p)==32)
              {
               split=p;
               break;
              }
         POSI_SetLabel(prefix+"RULE_"+IntegerToString(rendered),StringSubstr(line,0,split),x,y,9,rule_color,corner);
         y+=row_height;
         rendered++;
         POSI_SetLabel(prefix+"RULE_"+IntegerToString(rendered),"     "+StringSubstr(line,split+1),x,y,9,rule_color,corner);
         y+=row_height;
         rendered++;
        }
     }
   ObjectDelete(0,prefix+"MORE");
   POSI_SetLabel(prefix+"DISCLAIMER","Static pre-check only.",x,panel_y+height-41,8,theme.warning,corner);
   POSI_SetLabel(prefix+"DISCLAIMER_2","Broker/server may still reject the request.",x,panel_y+height-25,8,theme.warning,corner);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_SetPriceLine(const string name,const double price,const color clr,const ENUM_LINE_STYLE style)
  {
   if(price<=0.0 || !MathIsValidNumber(price))
     {
      ObjectDelete(0,name);
      return;
     }
   if(ObjectFind(0,name)<0 && !ObjectCreate(0,name,OBJ_HLINE,0,0,price))
      return;
   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_RenderLines(const string prefix,const POSI_PendingIntent &intent,const POSI_PanelTheme &theme)
  {
   POSI_SetPriceLine(prefix+"LINE_ENTRY",intent.entry,theme.primary,STYLE_SOLID);
   POSI_SetPriceLine(prefix+"LINE_SL",intent.stop_loss,theme.invalid,STYLE_DASH);
   POSI_SetPriceLine(prefix+"LINE_TP",intent.take_profit,theme.success,STYLE_DASH);
  }

#endif

input POSI_OrderType InpOrderType=POSI_BUY_STOP;
input double InpEntryPrice=0.0;
input double InpStopLoss=0.0;
input double InpTakeProfit=0.0;
input double InpVolume=0.10;
input bool InpRequireStopLoss=false;
input bool InpRequireTakeProfit=false;
input int InpMaxQuoteAgeSeconds=60;
input int InpPanelX=16;
input int InpPanelY=24;
input bool InpShowLines=true;

string g_posi_prefix="";
POSI_PanelTheme g_posi_theme;
uint g_last_signature=0;
uint g_last_issue_signature=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint POSI_HashMix(uint hash,const string value)
  {
   for(int i=0;i<StringLen(value);i++)
      hash=(hash^StringGetCharacter(value,i))*16777619;
   return hash;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint POSI_ReportSignature(const POSI_InspectionReport &report,const POSI_ContractSnapshot &contract)
  {
   uint hash=2166136261;
   hash=POSI_HashMix(hash,POSI_OverallStateToString(report.overall));
   hash=POSI_HashMix(hash,DoubleToString(contract.bid,contract.digits));
   hash=POSI_HashMix(hash,DoubleToString(contract.ask,contract.digits));
   for(int i=0;i<report.rule_count;i++)
      hash=POSI_HashMix(hash,POSI_RuleCodeToString(report.rules[i].code)+POSI_RuleStateToString(report.rules[i].state)+report.rules[i].detail);
   return hash;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint POSI_IssueSignature(const POSI_InspectionReport &report)
  {
   uint hash=2166136261;
   hash=POSI_HashMix(hash,POSI_OverallStateToString(report.overall));
   for(int i=0;i<report.rule_count;i++)
      if(report.rules[i].state==POSI_FAIL || report.rules[i].state==POSI_UNKNOWN)
         hash=POSI_HashMix(hash,POSI_RuleCodeToString(report.rules[i].code)+POSI_RuleStateToString(report.rules[i].state));
   return hash;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void POSI_Refresh(const bool force=false)
  {
   POSI_ContractSnapshot contract;
   string contract_error="";
   POSI_ReadContract(_Symbol,contract,contract_error);
   POSI_PendingIntent intent;
   intent.order_type=InpOrderType;
   intent.entry=InpEntryPrice;
   intent.stop_loss=InpStopLoss;
   intent.take_profit=InpTakeProfit;
   intent.volume=InpVolume;
   intent.require_stop_loss=InpRequireStopLoss;
   intent.require_take_profit=InpRequireTakeProfit;
   intent.max_quote_age_seconds=InpMaxQuoteAgeSeconds;
   POSI_InspectionReport report=POSI_Inspect(contract,intent);
   uint signature=POSI_ReportSignature(report,contract);
   if(!force && signature==g_last_signature)
      return;
   g_last_signature=signature;
   POSI_RenderPanel(g_posi_prefix,report,contract,intent,InpPanelX,InpPanelY,CORNER_LEFT_UPPER,g_posi_theme);
   if(InpShowLines)
      POSI_RenderLines(g_posi_prefix,intent,g_posi_theme);
   else
     {
      ObjectDelete(0,g_posi_prefix+"LINE_ENTRY");
      ObjectDelete(0,g_posi_prefix+"LINE_SL");
      ObjectDelete(0,g_posi_prefix+"LINE_TP");
     }
   uint issue_signature=POSI_IssueSignature(report);
   if(force || issue_signature!=g_last_issue_signature)
     {
      g_last_issue_signature=issue_signature;
      for(int i=0;i<report.rule_count;i++)
         if(report.rules[i].state==POSI_FAIL || report.rules[i].state==POSI_UNKNOWN)
            PrintFormat("POSI|%s|%s|%s",POSI_RuleCodeToString(report.rules[i].code),
                        POSI_RuleStateToString(report.rules[i].state),report.rules[i].detail);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_posi_prefix=StringFormat("POSI_%I64d_%I64u_",ChartID(),GetMicrosecondCount());
   g_posi_theme=POSI_DefaultTheme();
   PrintFormat("POSI|INIT|chart=%I64d|prefix=%s",ChartID(),g_posi_prefix);
   IndicatorSetString(INDICATOR_SHORTNAME,"Pending Order Inspector MT5");
   EventSetTimer(1);
   POSI_Refresh(true);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   POSI_DeleteObjects(g_posi_prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   POSI_Refresh(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      POSI_Refresh(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
  {
   return rates_total;
  }
//+------------------------------------------------------------------+

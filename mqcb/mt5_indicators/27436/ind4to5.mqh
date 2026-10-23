//
//                 D E F I N E S
//
#define StrToDouble StringToDouble
#define DoubleToStr DoubleToString
#define TimeToStr TimeToString
#define Ask SymbolInfoDouble(_Symbol, SYMBOL_ASK)
#define Bid SymbolInfoDouble(_Symbol, SYMBOL_BID)
#define EMPTY  -1
#define OP_BUY  0
#define OP_SELL 1

#define Digits _Digits
#define Point _Point

#define extern input



//
//                 O B J E C T S
//

class OBJPROP_INTEGER_BROKER
{
  public:
    ENUM_OBJECT_PROPERTY_INTEGER p;
    int i;
    
    OBJPROP_INTEGER_BROKER(const ENUM_OBJECT_PROPERTY_INTEGER property, const int modifier)
    {
      p = property;
      i = modifier;
    }
};

class OBJPROP_DOUBLE_BROKER
{
  public:
    ENUM_OBJECT_PROPERTY_DOUBLE p;
    int i;
    
    OBJPROP_DOUBLE_BROKER(const ENUM_OBJECT_PROPERTY_DOUBLE property, const int modifier)
    {
      p = property;
      i = modifier;
    }
};

OBJPROP_INTEGER_BROKER OBJPROP_TIME1(OBJPROP_TIME, 0);
OBJPROP_DOUBLE_BROKER OBJPROP_PRICE1(OBJPROP_PRICE, 0);
OBJPROP_INTEGER_BROKER OBJPROP_TIME2(OBJPROP_TIME, 1);
OBJPROP_DOUBLE_BROKER OBJPROP_PRICE2(OBJPROP_PRICE, 1);
OBJPROP_INTEGER_BROKER OBJPROP_TIME3(OBJPROP_TIME, 2);
OBJPROP_DOUBLE_BROKER OBJPROP_PRICE3(OBJPROP_PRICE, 2);

int ObjectFind(const string name)
{
  return ObjectFind(0, name);
}

string ObjectName(const int i)
{
  return ObjectName(0, i);
}

bool ObjectDelete(const string name)
{
  return ObjectDelete(0, name);
}

int ObjectsTotal()
{
  return ObjectsTotal(0);
}

bool ObjectCreate(const string name, const ENUM_OBJECT type, const int subwindow, const datetime time1, const double price1)
{
  return ObjectCreate(0, name, type, subwindow, time1, price1);
};

bool ObjectSet(const string name, const OBJPROP_INTEGER_BROKER &property, const long value)
{
  return ObjectSetInteger(0, name, property.p, property.i, value);
}

bool ObjectSet(const string name, const OBJPROP_DOUBLE_BROKER &property, const double value)
{
  return ObjectSetDouble(0, name, property.p, property.i, value);
}

bool ObjectSet(const string name, const ENUM_OBJECT_PROPERTY_INTEGER property, const long value)
{
  return ObjectSetInteger(0, name, property, value);
}

bool ObjectSet(const string name, const ENUM_OBJECT_PROPERTY_DOUBLE property, const double value)
{
  return ObjectSetDouble(0, name, property, value);
}

bool ObjectSetText(const string name, const string text, const int fontsize = 0, string fontname = NULL, color textcolor = clrNONE)
{
  bool b = ObjectSetString(0, name, OBJPROP_TEXT, text);
  if(fontname != NULL) ObjectSetString(0, name, OBJPROP_FONT, fontname);
  if(fontsize != 0) ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontsize);
  if(textcolor != clrNONE) ObjectSetInteger(0, name, OBJPROP_COLOR, textcolor);
  return b;
}


double ObjectGet(const string name, const OBJPROP_DOUBLE_BROKER &property)
{
  return ObjectGetDouble(0, name, property.p, property.i);
}

double ObjectGet(const string name, const ENUM_OBJECT_PROPERTY_DOUBLE property, const int i = 0)
{
  return ObjectGetDouble(0, name, property, i);
}

long ObjectGet(const string name, const OBJPROP_INTEGER_BROKER &property)
{
  return ObjectGetInteger(0, name, property.p, property.i);
}

long ObjectGet(const string name, const ENUM_OBJECT_PROPERTY_INTEGER property, const int i = 0)
{
  return ObjectGetInteger(0, name, property, i);
}


//
//                 D A T A   S E R I E S
//


int iBarShiftFast(string symbol, ENUM_TIMEFRAMES timeframe, datetime time)
{
  return(Bars(symbol, timeframe, time, D'2024.01.01') - 1);
}


/* EXAMPLE
class OpenBroker
{
  public:
    double operator[](int b)
    {
      return iOpen(_Symbol, _Period, b);
    }
};
OpenBroker Open;
*/

#define DefineBroker(NAME,TYPE) \
class NAME##Broker \
{ \
  public: \
    TYPE operator[](int b) \
    { \
      return i##NAME(_Symbol, _Period, b); \
    } \
}; \
NAME##Broker NAME;

DefineBroker(Time, datetime);
DefineBroker(Open, double);
DefineBroker(High, double);
DefineBroker(Low, double);
DefineBroker(Close, double);
DefineBroker(Volume, long);


//
//                 I N D I C A T O R S
//

bool _SetIndexBuffer(const int index, double &buffer[], const ENUM_INDEXBUFFER_TYPE type = INDICATOR_DATA)
{
  bool b = ::SetIndexBuffer(index, buffer, type);
  ArraySetAsSeries(buffer, true);
  ArrayInitialize(buffer, EMPTY_VALUE); // default filling
  return b;
}

#define SetIndexBuffer _SetIndexBuffer

void SetIndexStyle(const int index, const int type, const int style = EMPTY, const int width = EMPTY, const color clr = clrNONE)
{
  PlotIndexSetInteger(index, PLOT_DRAW_TYPE, type);
  if(style != EMPTY) PlotIndexSetInteger(index, PLOT_LINE_STYLE, style);
  if(width != EMPTY) PlotIndexSetInteger(index, PLOT_LINE_WIDTH, width);
  if(clr != clrNONE) PlotIndexSetInteger(index, PLOT_LINE_COLOR, clr);
}

void SetIndexShift(const int buffer, const int shift)
{
  PlotIndexSetInteger(buffer, PLOT_SHIFT, shift);
}

void SetIndexLabel(const int index, const string text)
{
  PlotIndexSetString(index, PLOT_LABEL, text);
}

void SetIndexEmptyValue(const int index, const double value)
{
  PlotIndexSetDouble(index, PLOT_EMPTY_VALUE, value);
}

void SetIndexArrow(const int index, const int code)
{
  PlotIndexSetInteger(index, PLOT_ARROW, code);
}

void IndicatorShortName(const string name)
{
  IndicatorSetString(INDICATOR_SHORTNAME, name);
}

void IndicatorDigits(const int digits)
{
  IndicatorSetInteger(INDICATOR_DIGITS, digits);
}

void SetLevelValue(const int level, const double value)
{
  IndicatorSetDouble(INDICATOR_LEVELVALUE, level, value);
}


//
//                 D A T E T I M E
//

int TimeYear(const datetime dt)
{
  MqlDateTime mdts;
  TimeToStruct(dt, mdts);
  return mdts.year;
}

int TimeMonth(const datetime dt)
{
  MqlDateTime mdts;
  TimeToStruct(dt, mdts);
  return mdts.mon;
}

int TimeDay(const datetime dt)
{
  MqlDateTime mdts;
  TimeToStruct(dt, mdts);
  return mdts.day;
}

#ifndef SUPPRESS_BARS
#define _Bars iBars(_Symbol, _Period)
#define Bars iBars(_Symbol, _Period)
#endif


//
//                 E V E N T  H A N D L E R S
//

#ifdef MT4_OLD_EVENT_HANDLERS

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
  init();
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  deinit();
}

int _indicatorCount = 0;

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
/*
int OnCalculate(const int rates_total,
                 const int prev_calculated,
                 const int begin,
                 const double& price[])
*/
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])

{
  _indicatorCount = prev_calculated;
  int result = start();
  if(result != 0) return 0;
  return rates_total;
}

int IndicatorCounted()
{
  return _indicatorCount;
}

#endif

#ifdef MT4_NEW_EVENT_HANDLERS

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
  ArraySetAsSeries(time, true);
  ArraySetAsSeries(open, true);
  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);
  ArraySetAsSeries(close, true);
  ArraySetAsSeries(tick_volume, true);
  ArraySetAsSeries(volume, true);
  ArraySetAsSeries(spread, true);
  return _OnCalculate(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
}

#define OnCalculate _OnCalculate

#endif

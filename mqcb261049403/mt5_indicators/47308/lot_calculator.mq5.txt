//+------------------------------------------------------------------+
//|                                               Lot Calculator.mq5 |
//|                                          Copyleft 2018, zebedeig |
//|                           https://www.mql5.com/en/users/zebedeig |
//+------------------------------------------------------------------+

#property copyright    "Copyleft 2018, by zebedeig"
#property link         "https://www.mql5.com/en/users/zebedeig"
#property version      "1.00"
#property description  "Tool used to calculate the correct lot size to trade, given a fixed risk and a number of pips."
#property description  "Simply enter the number of pips of your desired stop loss order, and the indicator will show you "
#property description  "the number of lots to trade based on your total account amount, your account currency and present chart currency pair."

#property strict
#property indicator_chart_window
#property indicator_plots 0

#define MODE_TICKVALUE 
#define MODE_TICKSIZE 
#define MODE_DIGITS

input int Pips = 165; // Размер стопа в пипсах
input double Risk = 0.02; // Ваш желаемый риск в процентах 
double point;
double freeMargin = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
{
  // Broker digits
  point = _Point;

  double Digits = _Digits;
  if((_Digits == 3) || (_Digits == 5))
  {
    point*=1;
  }
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator de-init function                         |
//+------------------------------------------------------------------+  

void OnDeinit(const int reason)
{
  Comment("");  // Cleanup
  Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason));
  return;
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
                const int &spread[]
                )
{
  string CommentString = "";

  string DepositCurrency = AccountInfoString(ACCOUNT_CURRENCY);
 
  double freeMargin = AccountInfoDouble(ACCOUNT_BALANCE);
  
 

  //double PipValue = ((((SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE))*point)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE))) * LotSize);
  double PipValue = (((SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE))*point)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE)));
  
  double lots = Risk * freeMargin / (PipValue * Pips);
  
  // Truncate lot quantity to 2 decimal digits without rounding it
  lots = floor(lots * 100) / 100;

  CommentString+="\n" + "Ваш баланс: "+ DepositCurrency + " " + DoubleToString(freeMargin, 2) + "\n";
  CommentString+="Ваш риск: " + DoubleToString(Risk * 100, 0) + "%\n";
  CommentString+="Ваш риск: " + DepositCurrency + " " + DoubleToString(Risk * freeMargin, 2) + "\n";
  CommentString+="-----------------------------------------------------------------\n";
  CommentString+="Стоимость пункта " + Symbol() + ": " + DepositCurrency + " " + DoubleToString(PipValue, 3) + "\n";
  CommentString+="Максимальный лот " + Symbol() + " для вашего риска на сделку в " + (string)Pips + " пипсов: " + DoubleToString(lots, 2) + "\n";
  CommentString+="-----------------------------------------------------------------\n";

  Comment(CommentString);

  //--- return value of prev_calculated for next call
  return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

string getUninitReasonText(int reasonCode) // Return reason for De-init function
{
  string text="";

  switch(reasonCode)
  {
  case REASON_ACCOUNT:
    text="Account was changed";
    break;
  case REASON_CHARTCHANGE:
    text="Symbol or timeframe was changed";
    break;
  case REASON_CHARTCLOSE:
    text="Chart was closed";
    break;
  case REASON_PARAMETERS:
    text="Input-parameter was changed";
    break;
  case REASON_RECOMPILE:
    text="Program "+__FILE__+" was recompiled";
    break;
  case REASON_REMOVE:
    text="Program "+__FILE__+" was removed from chart";
    break;
  case REASON_TEMPLATE:
    text="New template was applied to chart";
    break;
  default:
    text="Another reason";
  }

  return text;
}

  //+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                          ShowImportantParams.mq4 |
//|                               Copyright 2016, Alexey Volchanskiy |
//|                                          https://mql.gnomio.com/ |
//+------------------------------------------------------------------+

#property copyright "Copyright 2016 June 30, Alexey Volchanskiy"
#property link      "https://mql.gnomio.com/"
#property version   "1.03"
#property description "Indicator shows important params for current symbol and account"

#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>  

CSymbolInfo    m_symbolInfo; 
CAccountInfo   m_accountInfo;

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots DRAW_NONE

input int       FontSize            = 10;
input color     FontColor           = clrYellow;
input string    FontName            = "Tahoma";
input int       XOffset             = 10;
input int       YOffset             = 15;
input int       SpreadSmoothTicks   = 20;

string lNames[]={/*"Margin4lot",*/ "PointPrice=", "Leverage=1:","SpreadSmooth=","SpreadPrice=","StopLevel=","MarginCall=", "StopOut="};

double  SpreadBuf[];
int     SpreadBufIdx=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"SIP");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   ArrayResize(SpreadBuf,SpreadSmoothTicks);
   for(int n=0; n<SpreadSmoothTicks; n++)
      SpreadBuf[n]=0;
   SpreadBufIdx=0;
   if(!m_symbolInfo.Name(Symbol()))
    Print("Symbol ", Symbol(), " initialization false");
   if(!m_symbolInfo.Select(true))
    Print("Symbol ", Symbol(), " selection false");
 
   ObjectsDeleteAll(0,"SIP");
   Sleep(200);
   ChartRedraw();
   Sleep(200);
   for(int n=ArraySize(lNames)-1; n>=0; n--)
     {
      if(!CreateLabel("SIP_"+lNames[ArraySize(lNames)-1-n],XOffset,YOffset*n+YOffset))
         Print("CreateLabel returns false, n = ",IntegerToString(n));
     }
   Sleep(200);
   ChartRedraw();
  }
  
double GetMargin(string symbol, double volume)
{
    long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
    double contract = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE) * volume;
    double margin = volume * contract / leverage;
    //string currency = StringSubstr(symbol, 0, 3) + AccountInfoString(ACCOUNT_CURRENCY) + end;
    //SymbolInfoDouble(currency, SYMBOL_LAST) * contract / leverage;
    return margin;
}
//+------------------------------------------------------------------+
//|                                                                  |
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
   m_symbolInfo.Refresh();
   m_symbolInfo.RefreshRates();
   SpreadBuf[SpreadBufIdx++] = m_symbolInfo.Ask() - m_symbolInfo.Bid();
   if(SpreadBufIdx >= SpreadSmoothTicks)
      SpreadBufIdx = 0;
   double sprd=0;
   for(int n = 0; n < SpreadSmoothTicks; n++)
      sprd += SpreadBuf[n];
   sprd/=(double)SpreadSmoothTicks;
   ResetLastError();

   double price4lot;
   Quote2Price(sprd,price4lot,Symbol());
   
   m_symbolInfo.Refresh();
   double marginBuy = 0, marginSell = 0;
   m_symbolInfo.RefreshRates();
   m_symbolInfo.Refresh();
   ResetLastError();

//   double margin = GetMargin(Symbol(), 1.0);
   //ObjectSetString(0,"SIP_"+lNames[0],OBJPROP_TEXT,lNames[0]+DoubleToString(margin,2));
   ObjectSetString(0,"SIP_"+lNames[0],OBJPROP_TEXT,lNames[0]+DoubleToString(m_symbolInfo.TickValue(),2));
   ObjectSetString(0,"SIP_"+lNames[1],OBJPROP_TEXT,lNames[1]+IntegerToString(m_accountInfo.Leverage()));
   ObjectSetString(0,"SIP_"+lNames[2],OBJPROP_TEXT,lNames[2]+DoubleToString(sprd,_Digits) + ",  RealSpread=" + DoubleToString(m_symbolInfo.Ask() - m_symbolInfo.Bid(),_Digits));
   ObjectSetString(0,"SIP_"+lNames[3],OBJPROP_TEXT,lNames[3]+DoubleToString(price4lot,2));
   ObjectSetString(0,"SIP_"+lNames[4],OBJPROP_TEXT,lNames[4]+DoubleToString(m_symbolInfo.StopsLevel(),0));

   ENUM_ACCOUNT_STOPOUT_MODE stop_out_mode=(ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   string s=(stop_out_mode==ACCOUNT_STOPOUT_MODE_PERCENT)?" %":"";
   ObjectSetString(0,"SIP_"+lNames[5],OBJPROP_TEXT,lNames[5]+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL),0)+s);
   ObjectSetString(0,"SIP_"+lNames[6],OBJPROP_TEXT,lNames[6]+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO),0)+s);
   return(rates_total);
  }
//+------------------------------------------------------------------+
// Преобразует разницу котировок в цену "валюта депозита/лот". 
// Например, спред 0.00016 для пары EURUSD и валюты депозита USD будет равен $16/лот для лота 100000 ед. базовой валюты пары EUR.
//+------------------------------------------------------------------+
bool Quote2Price(double diff,double &price4lot,string symbol="EURUSD")
{
    int dig = m_symbolInfo.Digits();
    if(dig == 0)
       return(false); // symbol is none
    double tickSize = m_symbolInfo.TickSize();      // пункт в валюте котировки (0,00001 для EURUSD на 5-знаке) 
    double tickValue = m_symbolInfo.TickValue();    // пункт в валюте депозита ($1 для EURUSD на 5-знаке)
    double price = diff/(tickSize/tickValue);
    price4lot = NormalizeDouble(price,2);
    return true;
}

//+------------------------------------------------------------------+
// Преобразует цену "валюта депозита/лот" в разницу котировок. 
// Например, спред для пары EURUSD и валюты депозита USD, равный $16/лот для лота 100000 ед. базовой валюты пары EUR, будет равен 0.00016.
//+------------------------------------------------------------------+
bool Price2Quote(double &diff, double price4lot, string symbol = "EURUSD")
{
    long dig = 0;
    double tickSize, tickValue; 
    if(!SymbolInfoInteger(symbol, SYMBOL_DIGITS, dig))
        return(false); // операция неуспешна
    if(!SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE, tickSize))
        return(false); 
    if(!SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE, tickValue))
        return(false); 
    if(tickValue > 0)    
    {
        diff = price4lot*tickSize / tickValue;
        diff = NormalizeDouble(diff, (int)dig);
    }
    else
        return false;    
    return true;
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateLabel(string name,int x,int y=10)
  {
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return false;;
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,FontColor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,name,OBJPROP_FONT,FontName);
   ChartRedraw();
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

  }
//+------------------------------------------------------------------+

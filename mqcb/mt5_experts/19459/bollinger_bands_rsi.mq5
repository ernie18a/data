//+------------------------------------------------------------------+
//|                 Bollinger Bands RSI(barabashkakvn's edition).mq5 |
//|                                   Copyright © 2012, FORTRADER.RU |
//|                                              http://fortrader.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, FORTRADER.RU"
#property link      "http://fortrader.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//| Enum type of enter                                               |
//+------------------------------------------------------------------+
enum ENUM_TYPE_ENTER
  {
   enter_between_yellow_and_blue=0,    // enter between yellow and blue
   enter_between_blue_and_red=1,       // enter between blue and red 
   enter_yellow_line=2,                // yellow line enter
   enter_blue_line=3,                  // blue line enter
   enter_red_line=4,                   // red line enter
  };
//+------------------------------------------------------------------+
//| Enum type of closing by reverse touch                            |
//+------------------------------------------------------------------+
enum ENUM_TYPE_CLOSURE
  {
   closing_middle_line=0,              // middle line closure
   closing_between_yellow_and_blue=1,  // closing between yellow and blue 
   closing_between_blue_and_red=2,     // closing between blue and red
   closing_yellow_line=3,              // yellow line closing
   closing_blue_line=4,                // blue line closing
   closing_red_line=5,                 // red line closing
  };
//--- input parameters
input ENUM_TYPE_ENTER   enter          = enter_between_yellow_and_blue;
input int               bands_period   = 140;                     // Bollinger Bands: period for average line calculation 
input double            deviation_teeth= 2.0;                     // Bollinger Bands: number of standard deviations 
input bool              RSIFilter      = false;                   // RSI filter
input int               rsi_ma_period  = 8;                       // RSI: averaging period 
input int               rsi_lower_level= 70;                      // RSI lower level (100-80)
input bool              StohasticFilter= true;                    // Stohastic filter
input int               sto_Kperiod    = 20;                      // Stohastic: the K period (the number of bars for calculation)
input int               sto_lower_level= 95;                      // Stohastic lower level (100-80)
input ENUM_TYPE_CLOSURE closure        = closing_between_blue_and_red;
input int               bar_shift          = 1;                   // Bar index
input bool              OnlyOnePosition= true;                    // Only one position
input double            InpLots        = 0.1;                     // Lots
input ushort            InpStopLoss    = 200;                     // Stop Loss (in pips)
input ushort            InpTakeProfit  = 200;                     // Take Profit (in pips)
input ulong             m_magic        = 143279874;               // Magic number
//---
bool okbuy=false,oksell=false;

ulong          m_slippage=30;                // slippage

double         ExtStopLoss=0;
double         ExtTakeProfit=0;

int            handle_iStochastic;           // variable for storing the handle of the iStochastic indicator 
int            handle_iBands_teeth;          // variable for storing the handle of the iBands indicator 
int            handle_iBands_jaws;           // variable for storing the handle of the iBands indicator 
int            handle_iBands_lips;           // variable for storing the handle of the iBands indicator 
int            handle_iRSI;                  // variable for storing the handle of the iRSI indicator
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),sto_Kperiod,3,3,MODE_SMA,STO_LOWHIGH);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iBands
   handle_iBands_teeth=iBands(m_symbol.Name(),Period(),bands_period,0,deviation_teeth,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iBands_teeth==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iBands
   handle_iBands_jaws=iBands(m_symbol.Name(),Period(),bands_period,0,deviation_teeth/2.0,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iBands_jaws==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iBands
   handle_iBands_lips=iBands(m_symbol.Name(),Period(),bands_period,0,deviation_teeth*2.0,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iBands_lips==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),rsi_ma_period,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double upper_teeth=iBandsGet(handle_iBands_teeth,UPPER_BAND,bar_shift);
   double base_teeth=iBandsGet(handle_iBands_teeth,BASE_LINE,bar_shift);
   double lower_teeth=iBandsGet(handle_iBands_teeth,LOWER_BAND,bar_shift);

   double upper_jaws=iBandsGet(handle_iBands_jaws,UPPER_BAND,bar_shift);
   double lower_jaws=iBandsGet(handle_iBands_jaws,LOWER_BAND,bar_shift);

   double upper_lips=iBandsGet(handle_iBands_lips,UPPER_BAND,bar_shift);
   double lower_lips=iBandsGet(handle_iBands_lips,LOWER_BAND,bar_shift);

   double rsi=0.0;
   if(RSIFilter)
      rsi=iRSIGet(bar_shift);

   double stohastic=0.0;
   if(StohasticFilter)
      stohastic=iStochasticGet(MAIN_LINE,bar_shift);

   double enterpriceBuy=0.0,enterpriceSell=0.0,priceclosebuy=0.0,proceclosesell=0.0;
   switch(enter)
     {
      case  enter_between_yellow_and_blue:
         enterpriceBuy=upper_teeth+((upper_jaws-upper_teeth)/2);
         enterpriceSell=lower_teeth-((lower_teeth-lower_jaws)/2);
         break;
      case  enter_between_blue_and_red:
         enterpriceBuy=upper_jaws+((upper_lips-upper_jaws)/2);
         enterpriceSell=lower_jaws-((lower_jaws-lower_lips)/2);
         break;
      case enter_yellow_line:
         enterpriceBuy=upper_teeth;
         enterpriceSell=lower_teeth;
         break;
      case enter_blue_line:
         enterpriceBuy=upper_jaws;
         enterpriceSell=upper_jaws;
         break;
      case enter_red_line:
         enterpriceBuy=upper_lips;
         enterpriceSell=lower_lips;
         break;
     }

   if((closure==closing_between_yellow_and_blue && enter==enter_between_yellow_and_blue) ||
      (closure==closing_between_blue_and_red && enter==enter_between_blue_and_red))
     {
      priceclosebuy=enterpriceSell;
      proceclosesell=enterpriceBuy;
     }
   else
     {
      priceclosebuy=lower_jaws-((lower_jaws-lower_lips)/2.0);
      proceclosesell=upper_jaws+((upper_lips-upper_jaws)/2.0);
     }

   if(!RefreshRates())
      return;
   int count_buys=0,count_sells=0;
   CalculatePositions(count_buys,count_sells);
   if(OnlyOnePosition)
     {
      if(m_symbol.Ask()<=enterpriceSell && count_buys==0 && RSIFilter==0 && StohasticFilter==0)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp);
        }
      if(m_symbol.Bid()>=enterpriceBuy && count_sells==0 && RSIFilter==0 && StohasticFilter==0)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp);
        }

      if(m_symbol.Bid()>=enterpriceBuy && count_sells==0 && (RSIFilter==1 && rsi>=rsi_lower_level) && StohasticFilter==0)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp);
        }
      if(m_symbol.Ask()<=enterpriceSell && count_buys==0 && (RSIFilter==1 && rsi<=(100-rsi_lower_level)) && StohasticFilter==0)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp);
        }

      if(m_symbol.Bid()>=enterpriceBuy && count_sells==0 && RSIFilter==0 && (StohasticFilter==1 && stohastic>sto_lower_level))
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp);
        }
      if(m_symbol.Ask()<=enterpriceSell && count_buys==0 && RSIFilter==0 && (StohasticFilter==1 && stohastic<(100-sto_lower_level)))
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp);
        }

      if(m_symbol.Bid()>=enterpriceBuy && count_sells==0 && (RSIFilter==1 && rsi>=rsi_lower_level) && (StohasticFilter==1 && stohastic>sto_lower_level))
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp);
        }
      if(m_symbol.Ask()<=enterpriceSell && count_buys==0 && (RSIFilter==1 && rsi<=(100-rsi_lower_level)) && (StohasticFilter==1 && stohastic<(100-sto_lower_level)))
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp);
        }
     }
   else
     {
      if(m_symbol.Bid()>=base_teeth)
         okbuy=false;
      if(m_symbol.Ask()<=base_teeth)
         oksell=false;

      if(m_symbol.Bid()>=enterpriceBuy && !oksell && RSIFilter==0 && StohasticFilter==0)
        {
         oksell=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp);
           }
        }
      if(m_symbol.Ask()<=enterpriceSell && !okbuy && RSIFilter==0 && StohasticFilter==0)
        {
         okbuy=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp);
           }
        }

      if(m_symbol.Bid()>=enterpriceBuy && !oksell && (RSIFilter==1 && rsi>=rsi_lower_level) && StohasticFilter==0)
        {
         oksell=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp);
           }
        }
      if(m_symbol.Ask()<=enterpriceSell && !okbuy && (RSIFilter==1 && rsi<=(100-rsi_lower_level)) && StohasticFilter==0)
        {
         okbuy=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp);
           }
        }

      if(m_symbol.Bid()>=enterpriceBuy && !oksell && RSIFilter==0 && (StohasticFilter==1 && stohastic>sto_lower_level))
        {
         oksell=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp);
           }
        }
      if(m_symbol.Ask()<=enterpriceSell && !okbuy && RSIFilter==0 && (StohasticFilter==1 && stohastic<(100-sto_lower_level)))
        {
         okbuy=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp);
           }
        }

      if(m_symbol.Bid()>=enterpriceBuy && !oksell && (RSIFilter==1 && rsi>=rsi_lower_level) && (StohasticFilter==1 && stohastic>sto_lower_level))
        {
         oksell=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp);
           }
        }
      if(m_symbol.Ask()<=enterpriceSell && !okbuy && (RSIFilter==1 && rsi<=(100-rsi_lower_level)) && (StohasticFilter==1 && stohastic<(100-sto_lower_level)))
        {
         okbuy=true;
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp);
           }
        }
     }
//--- 
   switch(closure)
     {
      case closing_middle_line:
         if(m_symbol.Bid()>=base_teeth)
         ClosePositions(POSITION_TYPE_BUY);
         if(m_symbol.Ask()<=base_teeth)
            ClosePositions(POSITION_TYPE_SELL);
         break;
      case closing_between_yellow_and_blue:
         if(m_symbol.Bid()>=proceclosesell)
         ClosePositions(POSITION_TYPE_BUY);
         if(m_symbol.Ask()<=priceclosebuy)
            ClosePositions(POSITION_TYPE_SELL);
         break;
      case closing_between_blue_and_red:
         if(m_symbol.Bid()>=proceclosesell)
         ClosePositions(POSITION_TYPE_BUY);
         if(m_symbol.Ask()<=priceclosebuy)
            ClosePositions(POSITION_TYPE_SELL);
         break;
      case closing_yellow_line:
         if(m_symbol.Bid()>=upper_teeth)
         ClosePositions(POSITION_TYPE_BUY);
         if(m_symbol.Ask()<=lower_teeth)
            ClosePositions(POSITION_TYPE_SELL);
         break;
      case closing_blue_line:
         if(m_symbol.Bid()>=upper_jaws)
         ClosePositions(POSITION_TYPE_BUY);
         if(m_symbol.Ask()<=lower_jaws)
            ClosePositions(POSITION_TYPE_SELL);
         break;
      case closing_red_line:
         if(m_symbol.Bid()>=upper_lips)
         ClosePositions(POSITION_TYPE_BUY);
         if(m_symbol.Ask()<=lower_lips)
            ClosePositions(POSITION_TYPE_SELL);
         break;
     }

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iBands                              |
//|  the buffer numbers are the following:                           |
//|   0 - BASE_LINE, 1 - UPPER_BAND, 2 - LOWER_BAND                  |
//+------------------------------------------------------------------+
double iBandsGet(int handle_iBands,const int buffer,const int index)
  {
   double Bands[1];
//ArraySetAsSeries(Bands,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iBands,buffer,index,1,Bands)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Bands[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
   DebugBreak();
  }
//+------------------------------------------------------------------+

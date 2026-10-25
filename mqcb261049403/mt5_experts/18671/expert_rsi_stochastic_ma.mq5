//+------------------------------------------------------------------+
//|            Expert_RSI_Stochastic_MA(barabashkakvn's edition).mq5 |
//|                                                              Oxy |
//|                                                  m-viva@inbox.ru |
//+------------------------------------------------------------------+
#property copyright "Oxy"
#property link      "m-viva@inbox.ru"
#property version   "1.006"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters 
input string               nameInd1             = "___________RSI__________"; // RSi 
input int                  RSI_period           = 3;                          // RSi period
input ENUM_APPLIED_PRICE   RSI_applied_price    = PRICE_CLOSE;                // RSi applied price
input int                  RSI_up_level         = 80;                         // level up - RSi 
input int                  RSI_dn_level         = 20;                         // level down - RSi 
input string               nameInd2             = "________Stochastic______"; // Stochastic
input int                  STh_K_period         = 6;                          // K period
input int                  STh_D_period         = 3;                          // D period
input int                  STh_slowing          = 3;                          // slowing
input ENUM_MA_METHOD       STh_method           = MODE_SMA;                   // Stochastic type of smoothing 
input ENUM_STO_PRICE       STh_price_field      = STO_LOWHIGH;                // Stochastic calculation method 
input int                  STh_up_level         = 70;                         // level up - Stochastic
input int                  STh_dn_level         = 30;                         // level down - Stochastic
input string               nameInd3             = "___________MA___________"; // MA
input int                  MA_period            = 150;                        // MA period
input int                  MA_shift             = 0;                          // MA shift
input ENUM_MA_METHOD       MA_method            = MODE_SMA;                   // MA method
input ENUM_APPLIED_PRICE   MA_applied_price     = PRICE_CLOSE;                // MA applied price
input string               EA_properties        = "_________Expert_________"; // Expert properties
input double               InpLot               = 0.01;                       // Lot
input ushort               InpAllowLoss         = 30;                         // allow Loss, 0 - close by Stocho
input ushort               InpTrailingStop      = 30;                         // Trailing Stop, 0 - close by Stocho
input ushort               m_slippage           = 30;                         // m_slippage
input int                  m_magic              = 5577555;                    // Magic Number
//--- global program variables
string   NameEA="Expert_RSI_Stochastic_MA";
datetime candleTime=0;
string   txt="";
//---
double         ExtAllowLoss=0.0;
double         ExtTrailingStop=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int            handle_iMA;                   // variable for storing the handle of the iMA indicator 
int            handle_iRSI;                  // variable for storing the handle of the iRSI indicator
int            handle_iStochastic;           // variable for storing the handle of the iStochastic indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   string err_text="";
   if(!CheckVolumeValue(InpLot,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
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

   ExtAllowLoss   = InpAllowLoss    * m_adjusted_point;
   ExtTrailingStop= InpTrailingStop * m_adjusted_point;
//---
   if(RSI_up_level>=100 || RSI_up_level<=RSI_dn_level)
     {
      Print("Wrong level up - RSi !");
      return(INIT_FAILED);
     }
   if(RSI_dn_level<=0 || RSI_dn_level>=RSI_up_level)
     {
      Print("Wrong level down - RSi !");
      return(INIT_FAILED);
     }
   if(STh_up_level>=100 || STh_up_level<=STh_dn_level)
     {
      Print("Wrong level up - Stochastic !");
      return(INIT_FAILED);
     }
   if(STh_dn_level<=0 || STh_dn_level>=STh_up_level)
     {
      Print("Wrong level down - Stochastic !");
      return(INIT_FAILED);
     }
   if(ExtAllowLoss!=0 && InpAllowLoss<m_symbol.StopsLevel())
     {
      Print("Wrong allow Loss! \"allow Loss\" = ",InpAllowLoss,", symbol Stops Level = ",m_symbol.StopsLevel());
      return(INIT_FAILED);
     }
   if(ExtTrailingStop!=0 && InpTrailingStop<m_symbol.StopsLevel())
     {
      Print("Wrong Trailing Stop! \"Trailing Stop\" = ",InpAllowLoss,", symbol Stops Level = ",m_symbol.StopsLevel());
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),MA_period,MA_shift,MA_method,MA_applied_price);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),RSI_period,RSI_applied_price);
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
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),STh_K_period,STh_D_period,STh_slowing,STh_method,STh_price_field);
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
//---

   Comment("Waiting a new tick!");
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
//---
   if(!IsTradeAllowed())
     {
      Sleep(1000*6);
      return;
     }
//---
   double _ma           = iMAGet         (0);
   double _rsi          = iRSIGet        (0);
   double _STh_MAIN_0   = iStochasticGet (MAIN_LINE, 0);
   double _STh_SIGNAL_0 = iStochasticGet (SIGNAL_LINE, 0);
//---
   if(!RefreshRates())
      return;
//--- comment
   string _dn_up="DOWN price";
   if(m_symbol.Bid()>_ma)
      _dn_up="UP price";
   txt="\n"+NameEA+"\nMA = "+DoubleToString(_ma,m_symbol.Digits()+1)+" ---> "+_dn_up
       +"\nRSI ("+IntegerToString(RSI_dn_level)+"/"+IntegerToString(RSI_up_level)+") = "+DoubleToString(_rsi,2)
       +"\nStochastic ("+IntegerToString(STh_dn_level)+"/"+IntegerToString(STh_up_level)+") = "
       +DoubleToString(_STh_MAIN_0,2)+" _ "+DoubleToString(_STh_SIGNAL_0,2);
   Comment(txt);
//---
   double _openPriceBuy  = 0.0;
   double _openPriceSell = 0.0;
   OpenPrice(_openPriceBuy,_openPriceSell);
//--- check loss BUY
   if(_openPriceBuy!=0 && _openPriceBuy>m_symbol.Bid())
     {
      if(ExtAllowLoss==0)
        {
         if(_STh_MAIN_0>STh_up_level)
           {
            CloseOpenPos(POSITION_TYPE_BUY);
            return;
           } // negative result - close
        }
      else
        {
         if(_openPriceBuy-m_symbol.Bid()>=ExtAllowLoss && _STh_MAIN_0>STh_dn_level)
           { // close by allow loss
            CloseOpenPos(POSITION_TYPE_BUY);
            return;
           }
        }
     }
//--- check loss SELL
   if(_openPriceSell!=0 && _openPriceSell<m_symbol.Ask())
     {
      if(ExtAllowLoss==0)
        {
         if(_STh_MAIN_0<STh_dn_level)
           {
            CloseOpenPos(POSITION_TYPE_SELL);
            return;
           } // negative result - close
        }
      else
        {
         if(m_symbol.Ask()-_openPriceSell>=ExtAllowLoss && _STh_MAIN_0<STh_up_level)
           { // close by allow loss
            CloseOpenPos(POSITION_TYPE_SELL);
            return;
           }
        }
     }
//--- close or trail BUY
   if(_openPriceBuy!=0 && _STh_MAIN_0>STh_up_level && _openPriceBuy<=m_symbol.Bid())
     {
      //--- positive result
      if(ExtTrailingStop>0)
        {
         //--- trail
         if(candleTime!=iTime(m_symbol.Name(),Period(),0))
           {
            //--- once per candle
            Modify_SL_trail(POSITION_TYPE_BUY,ExtTrailingStop);
            candleTime=iTime(m_symbol.Name(),Period(),0);
           }
        }
      else
         CloseOpenPos(POSITION_TYPE_BUY); // close     
     }
//--- close or trail SELL
   if(_openPriceSell!=0 && _STh_MAIN_0<STh_dn_level && _openPriceSell>=m_symbol.Ask())
     {
      //--- positive result
      if(ExtTrailingStop>0)
        {
         //--- trail
         if(candleTime!=iTime(m_symbol.Name(),Period(),0))
           {
            //--- once per candle
            Modify_SL_trail(POSITION_TYPE_SELL,ExtTrailingStop);
            candleTime=iTime(m_symbol.Name(),Period(),0);
           }
        }
      else
         CloseOpenPos(POSITION_TYPE_SELL); // close      
     }
//---
   if(!RefreshRates())
      return;
   int   count_buys=0;
   int   count_sells=0;
   CalculatePositions(count_buys,count_sells);
//--- BUY
   if(m_symbol.Bid()>_ma && _rsi<RSI_dn_level && count_buys==0
      && (_STh_MAIN_0<STh_dn_level && _STh_SIGNAL_0<STh_dn_level))
     {
      OpenBuy();
     }
//--- SELL
   if(m_symbol.Ask()<_ma && _rsi>RSI_up_level && count_sells==0
      && (_STh_MAIN_0>STh_up_level && _STh_SIGNAL_0>STh_up_level))
     {
      OpenSell();
     }
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
//| Looking for a open price                                         |
//+------------------------------------------------------------------+
void OpenPrice(double &max_price_buy,double &min_price_sell)
  {
   max_price_buy=0.0;
   min_price_sell=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY) // gets the position type
              {
               if(max_price_buy==0)
                 {
                  max_price_buy=m_position.PriceOpen();
                  continue;
                 }
               if(max_price_buy<m_position.PriceOpen()) // for "BUY" we look for a maximum price
                  max_price_buy=m_position.PriceOpen();
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL) // gets the position type
              {
               if(min_price_sell==0)
                 {
                  min_price_sell=m_position.PriceOpen();
                  continue;
                 }
               if(min_price_sell>m_position.PriceOpen()) // for "SELL" we look for minimum price
                  min_price_sell=m_position.PriceOpen();
              }
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Modify Stop Loss                                                 |
//+------------------------------------------------------------------+
void Modify_SL_trail(const ENUM_POSITION_TYPE pos_type,const double _sl)
  {
   double sl=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type)
              {
               if(!RefreshRates())
                  continue;
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  sl=m_symbol.NormalizePrice(m_symbol.Bid()-_sl);
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  sl=m_symbol.NormalizePrice(m_symbol.Ask()+_sl);

               if(m_position.StopLoss()==0.0 || (m_position.PositionType()==POSITION_TYPE_BUY && m_position.StopLoss()<sl) || 
                  (m_position.PositionType()==POSITION_TYPE_SELL && m_position.StopLoss()>sl))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     sl,
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
  }
//+------------------------------------------------------------------+
//| Close open position                                              |
//+------------------------------------------------------------------+
void CloseOpenPos(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy()
  {
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLot)
        {
         if(m_trade.Buy(InpLot,m_symbol.Name()))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell()
  {
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLot)
        {
         if(m_trade.Sell(InpLot,m_symbol.Name()))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
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
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();

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
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
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

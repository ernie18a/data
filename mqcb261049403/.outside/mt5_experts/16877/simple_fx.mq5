//+------------------------------------------------------------------+
//|                           simplefx2(barabashkakvn's edition).mq5 |
//|                             Copyright © 2007, GLENNBACON.COM LLC |
//|                                  http://www.GetForexSoftware.com |
//+------------------------------------------------------------------+
/*
   Simple FX source code, expert advisor and user manual are property of 
   GLENNBACON.COM LLC and may not be altered, used or sold in commercial
   products. The Simple FX source code itself may be altered and used in personal
   projects as long as the name GLENNBACON.COM LLC and 
   http://www.GetForexSoftware.com URL are left entacted and visible.
 
   Programmer: Glenn Bacon
   Note: Every programmer has their own style and format of writing code. I try
   to make the code as readable as possible by using indenting and tab nested code.
   There are comments throughout the source explaining what each block/line of code does.
   
   I always use brackets {} to contain my if else and for conditional statements. Some
   programmers use shortcuts I do not. I think more programmers should always use 
   brackets because it makes the code more readable. (bored reading this yet?)
   
   I also only create and use a couple of my own functions because if you create dozens of functions it
   makes the code more difficult to read.
 
   If you're not a programmer and have questions about the code do not email me about
   the code or what it does. If you are a programmer and have questions about this
   code I can be contacted by going to http://www.GetForexSoftware.com and navigate to our
   Customer Service page, it has a contact form.
   
     
*/

#property copyright "Copyright © 2007, GLENNBACON.COM LLC"
#property link      "http://www.GetForexSoftware.com"
#property version   "1.001"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
                                             // Shift of moving average
#define Shift 1

// Trend Detection function
#define BULL 111111
#define BEAR 222222

// Input variables
input string               comment2                ="*** Order Options ***";
input double               InpLots                 =0.10;         // Lots 
input ushort               InpStop_Loss            =30;           // Stop Loss 
input ushort               InpTake_Profit          =50;           // Take Profit
input ulong                InpSlippage             =5;            // Slippage
input string               Deal_Comment            ="Simple FX";  // Comment
input ulong                Magic                   =112607;       // Magic
input string               comment3                ="*** Moving Average Options ***";
input int                  Long_MA_Period          =200;
input ENUM_MA_METHOD       Long_MA_Method          =MODE_EMA;
input ENUM_APPLIED_PRICE   Long_MA_Applied_Price   =PRICE_MEDIAN;
input int                  Short_MA_Period         =50;
input ENUM_MA_METHOD       Short_MA_Method         =MODE_EMA;
input ENUM_APPLIED_PRICE   Short_MA_Applied_Price  =PRICE_MEDIAN;

// Global variables
int      Total_Open_Positions=1; // we only want to open positions
bool     init_variables;         // init variable when program starts
datetime PreviousBar;            // record the candle/bar time
int      LastTrendDirection;     // record the previous trends direction
int      FileHandle;             // variable for file handling 

double   ExtLots           = 0.0;
double   ExtStop_Loss      = 0;
double   ExtTake_Profit    = 0;
ulong    ExtSlippage       = 0;
int      handle_iMALong;         // variable for storing the handle of the iMA indicator 
int      handle_iMAShort;        // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- moving average only run expert advisor if there is enough candle/bars in history
   if(Bars(Symbol(),Period())<Long_MA_Period+1 || Bars(Symbol(),Period())<Short_MA_Period+1)
     {
      Print("Moving average does not have enough Bars in history to open a trade!\n",
            "Must be at least ",Long_MA_Period," and ",Short_MA_Period," bars to perform technical analysis.");
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMA
   handle_iMALong=iMA(Symbol(),Period(),Long_MA_Period,0,Long_MA_Method,Long_MA_Applied_Price);
//--- if the handle is not created 
   if(handle_iMALong==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMA
   handle_iMAShort=iMA(Symbol(),Period(),Short_MA_Period,0,Short_MA_Method,Short_MA_Applied_Price);
//--- if the handle is not created 
   if(handle_iMAShort==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

   m_symbol.Name(Symbol());
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtLots        =InpLots;
   ExtStop_Loss   =InpStop_Loss*digits_adjust;
   ExtTake_Profit =InpTake_Profit*digits_adjust;
   ExtSlippage    =InpSlippage*digits_adjust;

   m_trade.SetExpertMagicNumber(Magic);
   m_trade.SetDeviationInPoints(ExtSlippage);

//--- make sure trader has set ExtLots to at least the minimum lot size of the broker and 
//--- we will normalize the ExtLots variable so we can properly open an order
   if(m_symbol.LotsMin()==0.01)
     {
      ExtLots=NormalizeDouble(ExtLots,2);
      if(ExtLots<0.01)
        {
         Print("The variable Lots must be 0.01 or greater to open an order. ");
         return(INIT_PARAMETERS_INCORRECT);
        }
     }

   if(m_symbol.LotsMin()==0.1)
     {
      ExtLots=NormalizeDouble(ExtLots,1);
      if(ExtLots<0.1)
        {
         Print("The variable Lots must be 0.1 or greater to open an order. ");
         return(INIT_PARAMETERS_INCORRECT);
        }
     }

   if(m_symbol.LotsMin()==1)
     {
      ExtLots=NormalizeDouble(ExtLots,0);
      if(ExtLots<1)
        {
         Print("The variable Lots must be 1 or greater to open an order. ");
         return(INIT_PARAMETERS_INCORRECT);
        }
     }

   init_variables=true;

//--- create data file if it does not exist and load variables if file does exist
   FileHandle=FileOpen("simplefx.dat",FILE_BIN|FILE_READ);
   if(FileHandle<1)
     {
      Print("simplefx.dat not found.");
      FileHandle=FileOpen("simplefx.dat",FILE_BIN|FILE_WRITE);
      if(FileHandle>0)
        {
         LastTrendDirection=0;
         FileWriteInteger(FileHandle,LastTrendDirection,SHORT_VALUE);
         FileClose(FileHandle);
         Print("simplefx.dat has been successfully created.");
        }
      else
        {
         FileClose(FileHandle);
         Print("Failed to create simplefx.dat file.");
        }
     }
   else
     {
      LastTrendDirection=FileReadInteger(FileHandle,SHORT_VALUE);
      Print("Variables loaded from file.");
      FileClose(FileHandle);
     }
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
//--- init variables when the expert advisor first starts running
   if(init_variables==true)
     {
      PreviousBar=iTime(m_symbol.Name(),Period(),0);   // record the current canle/bar open time
        {
         //--- place code here that you only wnat to run one time
        }
      init_variables=false;   // change to false so we only init variable once
     }

//--- record trends direction
   if(LastTrendDirection==0)
     {
      if(TrendDetection()==BULL)
        {
         LastTrendDirection=BULL;
        }
      if(TrendDetection()==BEAR)
        {
         LastTrendDirection=BEAR;
        }
      //--- save variables to file
      SaveVariables();
     }

//--- perform analysis and open orders on new candle/bar 
   if(NewBar()==true)
     {
      //--- only perform analysis and close order if we only have one order open
      int total_position=0;
      for(int i=PositionsTotal()-1;i>=0;i--)
        {
         if(m_position.SelectByIndex(i))
           {
            if(m_position.Magic()==Magic)
               total_position++;
           }
        }

      if(total_position==Total_Open_Positions)
        {
         for(int i=PositionsTotal()-1;i>=0;i--)
           {
            if(m_position.SelectByIndex(i))
              {
               if(m_position.Magic()==Magic)
                 {
                  if(m_position.PositionType()==POSITION_TYPE_BUY && TrendDetection()==BEAR)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                    }
                  if(m_position.PositionType()==POSITION_TYPE_SELL && TrendDetection()==BULL)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                    }
                 }
              }
           }
        }

      //--- only perform analysis and open new deal if we have not reached our Total_Open_Positions max
      if(total_position<Total_Open_Positions)
        {
         if(!RefreshRates())
            return;
         //--- open buy
         if(TrendDetection()==BULL && LastTrendDirection==BEAR)
           {
            if(ExtStop_Loss>0 && ExtTake_Profit>0)
              {
               //--- open deal
               m_trade.Buy(ExtLots,Symbol(),m_symbol.Ask(),
                           m_symbol.Ask()-(ExtStop_Loss*Point()),
                           m_symbol.Ask()+(ExtTake_Profit*Point()),
                           Deal_Comment);
              }
            if(ExtStop_Loss>0 && ExtTake_Profit==0)
              {
               //--- open deal
               m_trade.Buy(ExtLots,Symbol(),m_symbol.Ask(),
                           m_symbol.Ask()-(ExtStop_Loss*Point()),
                           0.0,
                           Deal_Comment);
              }
            if(ExtStop_Loss==0 && ExtTake_Profit>0)
              {
               //--- open deal
               m_trade.Buy(ExtLots,Symbol(),m_symbol.Ask(),
                           0.0,
                           m_symbol.Ask()+(ExtTake_Profit*Point()),
                           Deal_Comment);
              }
            if(ExtStop_Loss==0 && ExtTake_Profit==0)
              {
               //--- open deal
               m_trade.Buy(ExtLots,Symbol(),m_symbol.Ask(),
                           0.0,
                           0.0,
                           Deal_Comment);
              }
            LastTrendDirection=BULL;
            //---save variables to file
            SaveVariables();
           }

         //--- open sell
         if(TrendDetection()==BEAR && LastTrendDirection==BULL)
           {
            if(ExtStop_Loss>0 && ExtTake_Profit>0)
              {
               //--- open deal
               m_trade.Sell(ExtLots,Symbol(),m_symbol.Bid(),
                            m_symbol.Bid()+(ExtStop_Loss*Point()),
                            m_symbol.Bid()-(ExtTake_Profit*Point()),
                            Deal_Comment);
              }
            if(ExtStop_Loss>0 && ExtTake_Profit==0)
              {
               //--- open deal
               m_trade.Sell(ExtLots,Symbol(),m_symbol.Bid(),
                            m_symbol.Bid()+(ExtStop_Loss*Point()),
                            0.0,
                            Deal_Comment);
              }
            if(ExtStop_Loss==0 && ExtTake_Profit>0)
              {
               //--- open deal
               m_trade.Sell(ExtLots,Symbol(),m_symbol.Bid(),
                            0.0,
                            m_symbol.Bid()-(ExtTake_Profit*Point()),
                            Deal_Comment);
              }
            if(ExtStop_Loss==0 && ExtTake_Profit==0)
              {
               //--- open deal
               m_trade.Sell(ExtLots,Symbol(),m_symbol.Bid(),
                            0.0,
                            0.0,
                            Deal_Comment);
              }
            LastTrendDirection=BEAR;
            //--- save variables to file
            SaveVariables();
           }
        }
      if(!RefreshRates())
         return;
      Display_Info();
     }

//--- 
   if(!RefreshRates())
      return;
   Display_Info();

   return;
  }
//+------------------------------------------------------------------+
//| Common functions                                                 |
//+------------------------------------------------------------------+
int SaveVariables()
  {
//--- save variables to file
   FileHandle=FileOpen("simplefx.dat",FILE_BIN|FILE_WRITE);
   if(FileHandle<1)
     {
      Print("simplefx.dat not found.");
      FileHandle=FileOpen("simplefx.dat",FILE_BIN|FILE_WRITE);
      if(FileHandle>0)
        {
         FileWriteInteger(FileHandle,LastTrendDirection,SHORT_VALUE);
         FileClose(FileHandle);
         Print("simplefx.dat has been successfully created.");
        }
      else
        {
         FileClose(FileHandle);
         Print("Failed to create simplefx.dat file.");
        }
     }
   else
     {
      FileWriteInteger(FileHandle,LastTrendDirection,SHORT_VALUE);
      FileClose(FileHandle);
      Print("SimpleFX variables successfully saved to file.");
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| This function return the value true if the current               |
//|  bar/candle was just formed                                      |
//+------------------------------------------------------------------+
bool NewBar()
  {
   if(PreviousBar<iTime(m_symbol.Name(),Period(),0))
     {
      PreviousBar=iTime(m_symbol.Name(),Period(),0);
      return(true);
     }
   else
     {
      return(false);
     }
   return(false);    //--- in case if - else statement is not executed
  }
//+------------------------------------------------------------------+
//| is trend up/bullish or is it down/bearish                        |
//+------------------------------------------------------------------+
int TrendDetection()
  {
   double Short_0=iMAGet(handle_iMAShort,0);
   double Short_1=iMAGet(handle_iMAShort,1);
   double Long_0=iMAGet(handle_iMALong,0);
   double Long_1=iMAGet(handle_iMALong,1);
//--- BULL trend
   if(Short_0>Long_0 && Short_1>Long_1)
     {
      return(BULL);
     }

//--- BEAR trend
   if(Short_0<Long_0 && Short_1<Long_1)
     {
      return(BEAR);
     }

//--- flat no trend return 0
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Display_Info()
  {
   datetime date_current=TimeCurrent();
   datetime date_local=TimeLocal();

   MqlDateTime str_current,str_local;
   TimeToStruct(date_current,str_current);
   TimeToStruct(date_local,str_local);
   Comment("Simple FX ver 2.0\n",
           "Copyright © 2007, GlennBacon.com, LLC\n",
           "Visit: www.GetForexSoftware.com\n",
           "Forex Account Server:",m_account.Server(),"\n",
           "Account Balance:  $",m_account.Balance(),"\n",
           "ExtLots:  ",ExtLots,"\n",
           "Symbol: ",Symbol(),"\n",
           "Price:  ",NormalizeDouble(m_symbol.Bid(),Digits()),"\n",
           "Pip Spread:  ",m_symbol.Spread(),"\n",
           "Server Time: ",str_current.year,"-",str_current.mon,"-",str_current.day," ",str_current.hour,":",str_current.min,":",str_current.sec,"\n",
           "Minimum Lot Size: ",m_symbol.LotsMin());
   return;
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle,const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[index]);
  }
//+------------------------------------------------------------------+

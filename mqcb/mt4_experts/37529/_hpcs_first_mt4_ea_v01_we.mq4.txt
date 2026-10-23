//+------------------------------------------------------------------+
//|                                  _HPCS_FirstEA_MT4_EA_V01_WE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
      Print("Account Balance: ",AccountBalance());
      Print("Account Equity: ", AccountEquity());
      Print("Account Credit: ", AccountCredit());
      Print("Account Currency: ", AccountCurrency());
      Print("Account Company: ", AccountCompany());
      Print("Account Name: ", AccountName());

 

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   //Print("Inside Deinit");
   // string ls_indicatorShortName = IndicatorShortName(); 
   //ChartIndicatorDelete(NULL,0,ChartIndicatorName(NULL,0,0));
   
  }
//+------------------------------------------------------------------+
void OnTick()
  {
  
   //Print("OnTick Function");

  }


//+------------------------------------------------------------------+
//|                    Hedge_Dollar_Index_Against_Forex_Pairs_V1.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------------------------------------+
//|Hedging DOLLAR.IDX/USD - USIDX
//|
//|Euro – 57.6%
//|Japanese yen – 13.6%
//|Great Britain pound – 11.9%
//|Canadian dollar – 9.1%
//|Swedish krona – 4.2%
//|Swiss franc – 3.6%
//|
//|Buy USDIDX 100%       Value 100 point = 100$  Position size = 10000   10000 contracts Dukascopy = 100 TMGM 
//+------------------------------------------------------------------------------------------------------------------------------+
//|Hedge 100% in Forex Pairs
//|								     
//|Buy EURUSD  –  57.6%  Value 1 pip = 57.6$   Position size = 576000  Lots 5.76 
//|Buy GBPUSD  –  11.9%  Value 1 pip = 11.9$   Position size = 119000  Lots 1.19
//|Sell USDJPY –  13.6%  Value 1 pip = 13.6$   Position size = 206060  Lots 2.06
//|Sell USDCAD –   9.1%  Value 1 pip =  9.1$   Position size = 123809  Lots 1.238
//|Sell USDSEK –   4.2%  Value 1 pip =  4.2$   Position size = 444000  Lots 4.44
//|Sell USDCHF –   3.6%  Value 1 pip =  3.6$   Position size =  32300  Lots 0.323
//|
//|Lot_Multiplier increases or decreases lot proportions. Example: x2 or x0.1 
//|
//|Be aware of Dollar Index closing times when using this strategy!
//+------------------------------------------------------------------------------------------------------------------------------+

#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://forge.mql5.io"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "IP 2024 - free open source"
#property description   "This Script Hedge Dollar index against its constitutive FOREX pairs."
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property strict
#property show_inputs

input bool    Buy_DOLLAR_Index    =  false;  
input bool   Sell_DOLLAR_Index    =  false;  
input double Lot_Multiplier       =  1.0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
if(Buy_DOLLAR_Index){
         int DOLLAR_IDX_B = OrderSend("USIDX", OP_BUY,100    *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
//+------------------------------------------------------------------+ Hedge Forex
         int EURUSD_B     = OrderSend("EURUSD",OP_BUY ,5.76  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int GBPUSD_B     = OrderSend("GBPUSD",OP_BUY ,1.19  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDJPY_S     = OrderSend("USDJPY",OP_SELL,2.06  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDCAD_S     = OrderSend("USDCAD",OP_SELL,1.238 *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDSEK_S     = OrderSend("USDSEK",OP_SELL,4.44  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDCHF_S     = OrderSend("USDCHF",OP_SELL,0.323 *Lot_Multiplier,0.00,30,0,0,"",0,0,0);

   PlaySound("alert.wav");
}

if(Sell_DOLLAR_Index){
         int DOLLAR_IDX_S = OrderSend("USIDX", OP_SELL,1000*Lot_Multiplier,0.00,30,0,0,"",0,0,0);
//+------------------------------------------------------------------+ Hedge Forex
         int EURUSD_S     = OrderSend("EURUSD",OP_SELL ,5.76  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int GBPUSD_S     = OrderSend("GBPUSD",OP_SELL ,1.19  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDJPY_B     = OrderSend("USDJPY",OP_BUY,2.06  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDCAD_B     = OrderSend("USDCAD",OP_BUY,1.238 *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDSEK_B     = OrderSend("USDSEK",OP_BUY,4.44  *Lot_Multiplier,0.00,30,0,0,"",0,0,0);
         int USDCHF_B     = OrderSend("USDCHF",OP_BUY,0.323 *Lot_Multiplier,0.00,30,0,0,"",0,0,0);

   PlaySound("alert.wav");
}
}
//+------------------------------------------------------------------+

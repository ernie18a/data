//+------------------------------------------------------------------+
//|                                                 advancedv3.0.mq4 |
//|                                                     RinkanKnight |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "RinkanKnight"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property script_show_inputs

//if you want a Expert adviser which works with this principle i have one only can be given upon request @ rinkanrohitjena@live.com
//give a search in my name Rinkan Rohit Jena , only one person has this name so you can  find me without issues 
//NB: i have the ea  



extern int     TakeProfit           = 10; //not necessary as this is a part of my EA this is here only
extern int     StopLoss             = 20;//not necessary as this is a part of my EA this is here only
extern double  lots =1 ;//not necessary as this is a part of my EA this is here only



void OnStart()
  {
             
             Alert("script started ");//to know the script started 
             static int  ticket = 0;//not necessary as this is a part of my EA this is here only
             double TakeProfitLevel_buy = Bid + TakeProfit*Point;   //0.0001//not necessary as this is a part of my EA this is here only
             double StopLossLevel_buy = Bid - StopLoss*Point;//not necessary as this is a part of my EA this is here only

             double middlebb=iBands(Symbol(),5,20,2,0,PRICE_CLOSE,MODE_MAIN,0); //middle bb 
             double ma_ten = iMA(Symbol(),5,10,0,MODE_EMA,PRICE_CLOSE,0); // moving avg 10
             double ma_fifty = iMA(Symbol(),5,50,0,MODE_EMA,PRICE_CLOSE,0); //moving avg 50
             double sar = iSAR(Symbol(),5,0.02,0.2,0); // parabloic sar
             double red = iStochastic(Symbol(),5,5,3,3,MODE_EMA,0,MODE_SIGNAL,0); // stochatic signal line 
             double blue = iStochastic(Symbol(),5,5,3,3,MODE_EMA,0,MODE_MAIN,0); // main stochatic line
             double macd =iMACD(Symbol(),5,12,26,9,PRICE_CLOSE,MODE_MAIN,0);  // macd main
             double rsi = iRSI(Symbol(),5,14,PRICE_CLOSE,0); //relative strength index 
             
/*             
                Alert("the ckising price is ", Close[0] 
                Alert("the bb  is ", middlebb );
                Alert("the ma10 price is ", ma_ten );
                Alert("the ma50e is ", ma_fifty );
                Alert("the macd is ", macd );
                Alert("the sar is ", sar );
                Alert("the rsi is ", rsi );
                Alert("the red signL is ", red );
                Alert("the blue value is ", blue );
                
 */             
                
                
             
             
           
                            
              
             
              
             
             if ( middlebb <Close[0] && ma_ten < Close[0] && ma_fifty < Close[0] && sar < Close[0] && blue > red && macd >0 && rsi >50 ) //checking condition for buy
               {
                     Alert("buy");
                                   
               }
             else
               if( middlebb > Close[0] && ma_ten > Close[0] && ma_fifty > Close[0] && sar > Close[0] && blue < red && macd < 0 && rsi < 50 ) 
               {
               
               Alert("sell "); 
               
               
               
               } 
             else 
               {
                  Alert ("condition are not matching do not buy  ");
                 
                  
                  
               }
             
              
            
 }

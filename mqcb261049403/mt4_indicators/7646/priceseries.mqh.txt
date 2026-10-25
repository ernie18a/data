//Version  November 26, 2007
//+X================================================================X+
//|                                                  PriceSeries.mqh |
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
// Функция PriceSeries() возвращает входную цену бара по его номеру nPriceSeries.Bar и
// по номеру цены PriceSeries.Input_Price_Customs:
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 
//10-0.5*TRENDFOLLOW, 11-Heiken Ashi High, 12-Heiken Ashi Low, 13-Heiken Ashi Open, 14-Heiken Ashi Close, 
//15-Heiken Ashi Open0, пример: minuse = PriceSeries(Input_Price_Customs, bar) - PriceSeries(Input_Price_Customs, bar+1);
// или;  Momentum = PriceSeries(Input_Price_Customs, bar) - PriceSeries(Input_Price_Customs, bar+Momentum_Period); 
  
//X================================================================================================================X+
//X+++++++++++++++++++++++++++++++++++ <<< PriceSeries >>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
//=================================================================================================================X+

double PriceSeries(int PriceSeries.Input_Price_Customs, int nPriceSeries.Bar)
 {
  double dPriceSeries;
  switch(PriceSeries.Input_Price_Customs)
   {
    case  0: dPriceSeries = Close[nPriceSeries.Bar];break;
    case  1: dPriceSeries = Open [nPriceSeries.Bar];break;
    case  2: dPriceSeries = High [nPriceSeries.Bar];break;
    case  3: dPriceSeries = Low  [nPriceSeries.Bar];break;
    case  4: dPriceSeries =(High [nPriceSeries.Bar]+Low  [nPriceSeries.Bar])/2.0;break;
    case  5: dPriceSeries =(Close[nPriceSeries.Bar]+High [nPriceSeries.Bar]+Low[nPriceSeries.Bar])/3.0;break;
    case  6: dPriceSeries =(Open [nPriceSeries.Bar]+High [nPriceSeries.Bar]+Low[nPriceSeries.Bar]+Close[nPriceSeries.Bar])/4.0;break;
    case  7: dPriceSeries =(Open [nPriceSeries.Bar]+Close[nPriceSeries.Bar])/2.0;break;
    case  8: dPriceSeries =(Close[nPriceSeries.Bar]+High [nPriceSeries.Bar]+Low[nPriceSeries.Bar]+Close[nPriceSeries.Bar])/4.0;break;
    case  9: dPriceSeries = TrendFollow00(nPriceSeries.Bar);break;
    case 10: dPriceSeries = TrendFollow01(nPriceSeries.Bar);break;
    case 11: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",0,nPriceSeries.Bar);break;
    case 12: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",1,nPriceSeries.Bar);break;
    case 13: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",2,nPriceSeries.Bar);break;
    case 14: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",3,nPriceSeries.Bar);break;
    case 15: 
           {
             dPriceSeries=(iCustom(NULL,0,"Heiken Ashi#",2,nPriceSeries.Bar)+
                   (Open[nPriceSeries.Bar]+High[nPriceSeries.Bar]+Low[nPriceSeries.Bar]+Close[nPriceSeries.Bar])/4.0)/2.0;                      
           }
            break;
            //----+

    default: dPriceSeries = Close[nPriceSeries.Bar];
   }
  return(dPriceSeries);
 }
//X================================================================================================================X+

//+X==========================================================================================X+
//----+ Объявление функции TrendFollow00. для case 9 ------------------------------------------|
//+X==========================================================================================X+
double TrendFollow00(int nTrendFollow00.Bar)
 {
  double dTrendFollow00;
  double dTrendFollow00.high= High [nTrendFollow00.Bar];
  double dTrendFollow00.low=  Low  [nTrendFollow00.Bar];
  double dTrendFollow00.open= Open [nTrendFollow00.Bar];
  double dTrendFollow00.close=Close[nTrendFollow00.Bar];

  if(dTrendFollow00.close>dTrendFollow00.open)dTrendFollow00 = dTrendFollow00.high;
  else
  {
  if(dTrendFollow00.close<dTrendFollow00.open)dTrendFollow00 = dTrendFollow00.low;
                                                 else dTrendFollow00 = dTrendFollow00.close;
  }
  return(dTrendFollow00);
 }
//+X==========================================================================================X+
//----+ Объявление функции TrendFollow01. для case 10 -----------------------------------------|
//+X==========================================================================================X+
double TrendFollow01(int nTrendFollow01.Bar)
 {
  double dTrendFollow01;
  double dTrendFollow01.high= High [nTrendFollow01.Bar];
  double dTrendFollow01.low=  Low  [nTrendFollow01.Bar];
  double dTrendFollow01.open= Open [nTrendFollow01.Bar];
  double dTrendFollow01.close=Close[nTrendFollow01.Bar];

  if(dTrendFollow01.close>dTrendFollow01.open)
                        dTrendFollow01 =(dTrendFollow01.high+dTrendFollow01.close)/2;
  else
   {
  if(dTrendFollow01.close<dTrendFollow01.open)
                        dTrendFollow01 = (dTrendFollow01.low+dTrendFollow01.close)/2;
                   else dTrendFollow01 = dTrendFollow01.close;
   }
  return(dTrendFollow01);
 }
//+X==========================================================================================X+
//----+ Объявление функции PriceSeriesAlert ---------------------------------------------------+
// Функция PriceSeriesAlert() предназначена для индикации недопустимого значения параметра     |
// PriceSeries.Input_Price_Customs передаваемого в функцию PriceSeries().                      |
//+X==========================================================================================X+
void PriceSeriesAlert(int nPriceSeriesAlert.IPC)
 {
  if(nPriceSeriesAlert.IPC< 0)
      Alert("Параметр Input_Price_Customs должен быть не менее  0" 
               + " Вы ввели недопустимое "+nPriceSeriesAlert.IPC+ " будет использовано 0");
  if(nPriceSeriesAlert.IPC>15)
      Alert("Параметр Input_Price_Customs должен быть не более 15" 
               + " Вы ввели недопустимое "+nPriceSeriesAlert.IPC+ " будет использовано 0");
 }
//----+ X-------------------------------------------------------------------------------------X+
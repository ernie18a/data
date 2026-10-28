//+------------------------------------------------------------------+
//|                                                 AveragePrice.mq5 |
//|                         Copyright 2025, Francisco Gomes da Silva |
//|                    https://www.mql5.com/en/users/franciscogomes5 |
//+------------------------------------------------------------------+
#property copyright "© 2025 Francisco Gomes. (mql5.com)"
#property link      "https://www.mql5.com/en/users/franciscogomes5/seller"
#property version   "2.00"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

#property indicator_label1 "Volume Balance"
#property indicator_type1 DRAW_NONE

#property indicator_label2 "Average Buy"
#property indicator_color2 Blue
#property indicator_width2 4
#property indicator_type2 DRAW_LINE

#property indicator_label3 "Average Sell"
#property indicator_color3 Red
#property indicator_width3 4
#property indicator_type3 DRAW_LINE

#property indicator_label4 "Average Price"
#property indicator_color4 Aqua
#property indicator_width4 5
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_DASH

#include <Trade\PositionInfo.mqh>  // Biblioteca padrão para manipular posições

// Buffer para armazenar o preço médio
double bufferBuyAvgPrice[];
double bufferSellAvgPrice[];
double bufferAvgPrice[];
double bufferNetVolume[];

// Parâmetros do indicador
input long MagicNumber = 0;  // Magic

//+------------------------------------------------------------------+
//| Função que calcula o preço médio das posições Hedge              |
//+------------------------------------------------------------------+
double CalculateHedgeAveragePrice(const string symbol, const long magic, double &netVolume, double &buyAvgPrice, double &sellAvgPrice)
  {
   CPositionInfo pos;

   double totalBuyVolume = 0;
   double totalBuyCost = 0;
   double totalSellVolume = 0;
   double totalSellCost = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!pos.SelectByIndex(i))
         continue;  // Seleciona a posição pelo índice
      if(magic != 0 && pos.Magic() != magic)
         continue;  // Filtra por símbolo e magic number
      if(pos.Symbol() != symbol)
         continue;

      double volume = pos.Volume();
      double price = pos.PriceOpen();

      if(pos.PositionType() == POSITION_TYPE_BUY)
        {
         totalBuyVolume += volume;
         totalBuyCost += price * volume;
        }
      else
         if(pos.PositionType() == POSITION_TYPE_SELL)
           {
            totalSellVolume += volume;
            totalSellCost += price * volume;
           }
     }

// Calcula os preços médios separados
   buyAvgPrice = (totalBuyVolume > 0) ? (totalBuyCost / totalBuyVolume) : 0;
   sellAvgPrice = (totalSellVolume > 0) ? (totalSellCost / totalSellVolume) : 0;

// Determina a posição líquida
   netVolume = totalBuyVolume - totalSellVolume;

// Retorna o preço médio com base na posição líquida
   if(netVolume > 0)
      return buyAvgPrice;  // Posição líquida comprada
   if(netVolume < 0)
      return sellAvgPrice; // Posição líquida vendida
   return 0;  // Posição zerada, sem preço médio relevante
  }
//+------------------------------------------------------------------+
//| Inicialização do indicador                                       |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, bufferNetVolume);
   SetIndexBuffer(1, bufferBuyAvgPrice);
   SetIndexBuffer(2, bufferSellAvgPrice);
   SetIndexBuffer(3, bufferAvgPrice);
//IndicatorShortName("Hedge Average Price");
   IndicatorSetString(INDICATOR_SHORTNAME,"AveragePrice");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Cálculo do indicador                                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   double netVolume;
   double buyAvgPrice;
   double sellAvgPrice;
   double avgPrice = CalculateHedgeAveragePrice(Symbol(), MagicNumber,netVolume,buyAvgPrice,sellAvgPrice);

// Preencher todo o buffer com o preço médio calculado de forma otimizada
   ArrayFill(bufferBuyAvgPrice, 0, rates_total, buyAvgPrice);
   ArrayFill(bufferSellAvgPrice, 0, rates_total, sellAvgPrice);
   ArrayFill(bufferAvgPrice, 0, rates_total, avgPrice);
   ArrayFill(bufferNetVolume, 0, rates_total, netVolume);

   return rates_total;
  }
//+------------------------------------------------------------------+

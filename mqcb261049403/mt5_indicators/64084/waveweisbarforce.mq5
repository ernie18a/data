//+------------------------------------------------------------------+
//|                                          WaveWeisBarForce.mq5    |
//|                                          v1.0                    |
//|                                  by Gustavo Duca (2025)          |
//+------------------------------------------------------------------+
/*
Resumo do indicador (consulta rápida)
-------------------------------------
• Lógica (Weis): soma o volume enquanto a direção NÃO muda; ao inverter a direção,
  inicia nova onda e zera o acumulado.
• Cor (4 níveis por lado): intensidade = acumulado_onda / máx_trailing (janela=Intensity).
  - Bull: lv1 bem claro → lv4 LIME.
  - Bear: lv1 bem claro → lv4 RED.
• WaveMax (branco): barra de MAIOR volume DENTRO da onda (1 barra por onda).
• WaveClimax (amarelo): quando o acumulado atual supera o melhor acumulado
  das ondas concluídas (pico histórico local).
• Legenda: exibe APENAS o 1º valor (acumulado atual). WaveMax/Climax ficam ocultos.

Boas práticas aplicadas
-----------------------
• EMPTY_VALUE para não desenhar onde não há valor (evita “linhas brancas”).
• Reset automático ao trocar timeframe (_Period) → recálculo limpo.
• Intensidade visual (Intensity) padrão 50 (boa leitura intraday).
*/
//============================== Metadados ===============================//
#property strict
#property indicator_separate_window
#property indicator_plots   3
#property indicator_buffers 6
#property indicator_minimum 0.0
#property version   "1.0"
#property copyright "2025, Gustavo Duca - Direitos Reservados"


#property description "WaveWeisBarForce: volume acumulado por ondas (Weis)."
#property description "Paleta 4 níveis:"
#property description "Bullish: Level 1, Level 2, Level 3, Level 4=Lime."
#property description "Bearish: Level 1, Level 2, Level 3, Level 4=Red."
#property description "WaveClimax (Yellow) - Onda com volume acumulado recorde (clímax). "

//=============================== Inputs =================================//
// Fonte de volume (tick/real)
input ENUM_APPLIED_VOLUME Volume_type = VOLUME_TICK;
// Janela (em barras) usada como referência para a intensidade (degradê)
input int   Intensity = 50;
// Níveis por lado — não alterar (mantém compatibilidade visual e lógica)
#define LEVELS_PER_SIDE 4

// Paleta por nível (aparece em “Parâmetros de entrada”) — apenas VISUAL
// Bull (verde): lv1 mais claro → lv4 LIME
input color BullLv1 = C'245,255,245';   // Bullish Level 1
input color BullLv2 = C'205,255,205';   // Bullish Level 2
input color BullLv3 = C'150,255,150';   // Bullish Level 3
input color BullLv4 = clrLime;          // Bullish Level 4 (LIME)
// Bear (vermelho): lv1 mais claro → lv4 RED
input color BearLv1 = C'255,245,245';   // Bearish Level 1
input color BearLv2 = C'255,205,205';   // Bearish Level 2
input color BearLv3 = C'255,150,150';   // Bearish Level 3
input color BearLv4 = clrRed;           // Bearish Level 4 (RED)

//=============================== Buffers ================================//
// Plot 0: histograma colorido por índice
double AccumBuffer[];     // valor do acumulado por onda
double ColorIndex[];      // índice de cor (0..8) para o Plot 0
// Plot 1: WaveMax (branco) — 1 barra por onda
double MaxWaveBuffer[];
// Plot 2: WaveClimax (amarelo)
double ClimaxBuffer[];
// Auxiliares (não desenhados)
double DirBuffer[];       // direção (+1 bull / -1 bear / 0 indef.)
double WaveIdBuffer[];    // id incremental da onda (diagnóstico)

//============================= Estado interno ===========================//
int    g_lastWaveId = 0;           // contador de ondas concluídas
double g_bestCompletedAccum = 0.0;  // melhor acumulado dentre ondas CONCLUÍDAS
static int s_last_period = -1;      // guarda timeframe para detectar mudança

//============================== Helpers =================================//
// Retorna o volume da barra i segundo a fonte escolhida
inline double VolAt(const long &tick_volume[], const long &volume[], const int i)
  {
   return (Volume_type==VOLUME_REAL ? (double)volume[i] : (double)tick_volume[i]);
  }

// Converte (dir, acumulado, refMax) → índice de cor 0..8 (0=indef.)
int ColorIndexByIntensity(const int dir, const double acc, const double refMax)
  {
   if(dir==0 || refMax<=0.0 || acc<=0.0)
      return 0;
   double r = acc / refMax;            // 0..1
   if(r < 0.0)
      r = 0.0;
   if(r > 1.0)
      r = 1.0;
   int bin = (int)MathCeil(r * LEVELS_PER_SIDE); // 1..4
   if(bin < 1)
      bin = 1;
   if(bin > LEVELS_PER_SIDE)
      bin = LEVELS_PER_SIDE;
   return (dir>0 ? bin : 4 + bin);     // Bull:1..4 | Bear:5..8
  }

// Máximo “trailing” do acumulado usado como referência de intensidade
double TrailingMax(const double &arr[], const int i, const int win)
  {
   double m = 0.0;
   int L = (win<1 ? 1 : win);
   int left = i - L + 1;
   if(left < 0)
      left = 0;
   for(int k=left; k<=i; ++k)
     {
      if(arr[k]>m)
         m = arr[k];
     }
   return m;
  }

//================================ Init ==================================//
int OnInit()
  {
// Mapeamento dos buffers aos plots/cálculos
   SetIndexBuffer(0, AccumBuffer,   INDICATOR_DATA);
   SetIndexBuffer(1, ColorIndex,    INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, MaxWaveBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ClimaxBuffer,  INDICATOR_DATA);
   SetIndexBuffer(4, DirBuffer,     INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, WaveIdBuffer,  INDICATOR_CALCULATIONS);

// Série crescente (0 à esquerda → N-1 à direita)
   ArraySetAsSeries(AccumBuffer,   false);
   ArraySetAsSeries(ColorIndex,    false);
   ArraySetAsSeries(MaxWaveBuffer, false);
   ArraySetAsSeries(ClimaxBuffer,  false);
   ArraySetAsSeries(DirBuffer,     false);
   ArraySetAsSeries(WaveIdBuffer,  false);

//--- Plot 0: acumulado colorido
   PlotIndexSetString(0, PLOT_LABEL,      "WaveWeis Accumulated Volume");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE,  DRAW_COLOR_HISTOGRAM);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 5);
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 9);
// Paleta (0..8): 0=indef.; 1..4=Bull; 5..8=Bear  —— VISUAL APENAS
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrSilver);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, BullLv1);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, BullLv2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, BullLv3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 4, BullLv4);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 5, BearLv1);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 6, BearLv2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 7, BearLv3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 8, BearLv4);

//--- Plot 1: WaveMax (branco) — oculto na legenda
   PlotIndexSetString(1, PLOT_LABEL,      "WaveWeis Max Volume");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE,  DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 5);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, clrWhite);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_SHOW_DATA,  false);

//--- Plot 2: WaveClimax (amarelo) — oculto na legenda
   PlotIndexSetString(2, PLOT_LABEL,      "WaveClimax (Accumulated peak)");
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE,  DRAW_HISTOGRAM);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 5);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 0, clrYellow);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(2, PLOT_SHOW_DATA,  false);

// Limpeza inicial (evita “linhas brancas” após troca de TF)
   ArrayInitialize(MaxWaveBuffer, EMPTY_VALUE);
   ArrayInitialize(ClimaxBuffer,  EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME, "WaveWeisBarForce");
   s_last_period = _Period; // salva timeframe atual
   return(INIT_SUCCEEDED);
  }

//=============================== Calculate ===============================//
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
   if(rates_total < 3)
      return 0;

// Se mudou o timeframe, limpar estado/buffers e recalc completo no próximo tick
   if(s_last_period != _Period)
     {
      s_last_period = _Period;
      g_lastWaveId = 0;
      g_bestCompletedAccum = 0.0;
      ArrayInitialize(AccumBuffer,   0.0);
      ArrayInitialize(ColorIndex,    0.0);
      ArrayInitialize(MaxWaveBuffer, EMPTY_VALUE);
      ArrayInitialize(ClimaxBuffer,  EMPTY_VALUE);
      ArrayInitialize(DirBuffer,     0.0);
      ArrayInitialize(WaveIdBuffer,  0.0);
      return 0;
     }

// Seed de cálculo quando necessário
   int barsToProcess;
   if(prev_calculated == 0 || rates_total > prev_calculated+1)
     {
      // barra 0
      AccumBuffer[0]  = VolAt(tick_volume, volume, 0);
      ColorIndex[0]   = 0.0;
      MaxWaveBuffer[0]= EMPTY_VALUE;
      ClimaxBuffer[0] = EMPTY_VALUE;
      DirBuffer[0]    = 0.0;
      WaveIdBuffer[0] = 0.0;

      // barra 1
      AccumBuffer[1]  = AccumBuffer[0] + VolAt(tick_volume, volume, 1);
      DirBuffer[1]    = (close[1] >= close[0] ? +1.0 : -1.0);
      ColorIndex[1]   = (close[1] >= close[0] ? 1.0 : 5.0);
      MaxWaveBuffer[1]= EMPTY_VALUE;
      ClimaxBuffer[1] = EMPTY_VALUE;
      WaveIdBuffer[1] = 0.0;

      g_lastWaveId = 0;
      g_bestCompletedAccum = 0.0;
      barsToProcess = rates_total;
     }
   else
     {
      barsToProcess = (rates_total - prev_calculated) + 1;
      if(barsToProcess < 2)
         barsToProcess = 2;
     }

// Ponto de reinício (garantir continuidade de onda)
   int start = MathMax(2, rates_total - barsToProcess);
   while(start>2)
     {
      bool up1 = (close[start-1] >= close[start-2]);
      bool up2 = (close[start-2] >= close[start-3]);
      if(up1 != up2)
         break;     // fronteira de onda
      start--;
     }

// Estado recuperado da barra anterior a 'start'
   double currAccum = AccumBuffer[start-1];
   int    currDir   = (DirBuffer[start-1]>0.0?+1:(DirBuffer[start-1]<0.0?-1:0));
   if(currDir==0)
      currDir = (close[start-1]>=close[start-2]?+1:-1);

// Localiza último WaveMax impresso para limpeza correta
   int    lastMaxOutIdx = -1;
   for(int j=MathMax(0,start-20); j<start; ++j)
     {
      if(MaxWaveBuffer[j] != EMPTY_VALUE)
         lastMaxOutIdx = j;
     }
   int    waveMaxIdx = start-1;
   double waveMaxVol = VolAt(tick_volume, volume, start-1);

// Loop principal
   for(int i=start; i<rates_total; ++i)
     {
      const double vol_i = VolAt(tick_volume, volume, i);

      bool contUp = (close[i]   >= close[i-1]);
      bool prevUp = (close[i-1] >= close[i-2]);

      // Mantém a onda ou inicia nova quando há inversão de direção
      if(contUp)
        {
         if(prevUp)
           {
            currAccum += vol_i;
            currDir = +1;
           }
         else
           {
            if(currAccum > g_bestCompletedAccum)
               g_bestCompletedAccum = currAccum;
            currAccum = vol_i;
            currDir = +1;
            g_lastWaveId++;
            if(lastMaxOutIdx>=0)
              {
               MaxWaveBuffer[lastMaxOutIdx] = EMPTY_VALUE;
               lastMaxOutIdx=-1;
              }
            waveMaxIdx = i;
            waveMaxVol = vol_i;
           }
        }
      else
        {
         if(!prevUp)
           {
            currAccum += vol_i;
            currDir = -1;
           }
         else
           {
            if(currAccum > g_bestCompletedAccum)
               g_bestCompletedAccum = currAccum;
            currAccum = vol_i;
            currDir = -1;
            g_lastWaveId++;
            if(lastMaxOutIdx>=0)
              {
               MaxWaveBuffer[lastMaxOutIdx] = EMPTY_VALUE;
               lastMaxOutIdx=-1;
              }
            waveMaxIdx = i;
            waveMaxVol = vol_i;
           }
        }

      // Atualiza o único pico de volume da onda (WaveMax)
      if(vol_i >= waveMaxVol)
        {
         waveMaxVol = vol_i;
         if(lastMaxOutIdx>=0)
            MaxWaveBuffer[lastMaxOutIdx] = EMPTY_VALUE;
         waveMaxIdx = i;
         lastMaxOutIdx = i;
        }

      // Saídas da barra i
      AccumBuffer[i] = currAccum;
      DirBuffer[i]   = (double)currDir;
      WaveIdBuffer[i]= (double)g_lastWaveId;

      double refMax = TrailingMax(AccumBuffer, i, Intensity);
      ColorIndex[i] = (double)ColorIndexByIntensity(currDir, currAccum, refMax);

      MaxWaveBuffer[i] = (i==waveMaxIdx ? currAccum : EMPTY_VALUE);
      ClimaxBuffer[i]  = (currAccum > g_bestCompletedAccum && currDir!=0 ? currAccum : EMPTY_VALUE);
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

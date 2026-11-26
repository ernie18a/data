struct SPoint
{
    double mAsk;
    double mBid;
    double mLow;
    double mHigh;
    double mOpen;
    double mClose;
    double mPoint;
    double mSpread;
    double mVolume;
    datetime mTime;
};

struct SSymbol
{
    string mName;
    double mMean;
    double mUnit;
    double mOrder;
};

struct SSeries
{
    SSymbol mSymbol;
    SPoint mPoints[];
};

struct SMatrix
{
    SSymbol mSymbol;
    double mAsk[];
    double mBid[];
    double mLow[];
    double mHigh[];
    double mOpen[];
    double mClose[];
    double mPoint[];
    double mSpread[];
    double mVolume[];
    datetime mTime[];
};

struct SGroup
{
    string mName;
    string mMessage;
    double mPrice;
    double mMean;
};

struct SDeal
{
    int mEntry;
    int mDirection;
    ulong mTicket;
    string mName;
    double mPrice;
    double mVolume;
    double mSummary;
    datetime mTime;
};

struct SBet
{
    double mCount;
    double mMinus;
    double mPlus;
};

double pipsToMoney(string symbol, double volume, double pips)
{
    double step = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    return pips * value * volume / step;
}

int maxPrecision()
{
    int digits = 0;
    double v = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    
    for (int k = 1; k < 100 && MathFloor(v * k) == 0; k *= 10, digits++);
    
    return digits;
}

double getMargin(string symbol, double volume, string end = "")
{
    long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
    double contract = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE) * volume;
    string currency = StringSubstr(symbol, 0, 3) + AccountInfoString(ACCOUNT_CURRENCY) + end;
    return SymbolInfoDouble(currency, SYMBOL_LAST) * contract / leverage;
}

bool isTradingTime(string shours = "0:30-23:30", string sdays = "0-6")
{
    string days[];
    string hours[];
    
    StringSplit(sdays, '-', days);
    StringSplit(shours, '-', hours);

    MqlDateTime o = {0};
    datetime now = TimeCurrent(o);
    
    string day = 
        string(o.year) + "." + 
        string(o.mon) + "." + 
        string(o.day);

    datetime H1 = StringToTime(day + " " + hours[0]);
    
    if (hours[0] > hours[1])
    {
        day = 
            string(o.year) + "." + 
            string(o.mon) + "." + 
            string(o.day + 1);
    }
    
    datetime H2 = StringToTime(day + " " + hours[1]);
    
    int D1 = int(days[0]);
    int D2 = int(days[ArraySize(hours) - 1]);

    if (now >= H1 && 
        now <= H2 && 
        o.day_of_week >= D1 && 
        o.day_of_week <= D2) 
            return true;

    return false;
}

double getTickCost(string symbol, bool check = false)
{
    double cost = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

    if (cost == 0)
    {
        string altSymbol = StringSubstr(symbol, 3) + "USD";

        if (SymbolSelect(altSymbol, true))
        {
            double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
            double contract = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
            double crossCost = SymbolInfoDouble(altSymbol, SYMBOL_TRADE_TICK_VALUE);
            cost = crossCost == 0 && check ? 0 : (point * contract / crossCost);
        }
    }
    
    return cost;
}

datetime getLastSymbolTime(string symbol, ENUM_TIMEFRAMES period = PERIOD_CURRENT, int start = 0)
{
    datetime moment[];
    CopyTime(symbol, period, start, 1, moment);
    return moment[0];
}

datetime getLastTime(SSeries& series[], ENUM_TIMEFRAMES period, int start)
{
    datetime startTime = 0;
    int count = ArraySize(series);

    for (int k = 0; k < count; k++)
    {
        startTime = MathMax(startTime, getLastSymbolTime(series[k].mSymbol.mName, period, start));
    }

    return startTime;
}

double EMA(double current, double previous, int period)
{
    double result = 0.0;

    if (period > 0)
    {
        double pr = 2.0 / (period + 1.0);
        result = current * pr + previous * (1 - pr);
    }

    return result;
}

/**
 * Get list of past trades
 */
string getTrades(SDeal &deals[], SSeries &results[], string symbol = NULL, int mode = 0)
{
    string result = "";
    
    int index = 0;
    int position = 0;
    int K = ArraySize(deals);
    ArrayResize(results, index + 1);
    
    for (int k = 0; k < K; k++)
    {
        if (deals[k].mName == symbol || deals[k].mName == NULL)
        {
            int item = 0;
        
            switch (mode)
            {
                case 0 : item = deals[k].mSummary > 0 ? 1 : 0; break;
                case 1 : item = deals[k].mDirection > 0 ? 1 : 0; break;
            }
            
            ArrayResize(results[index].mPoints, position + 1);
            results[index].mPoints[position].mPoint = item;
            position++;
        
            if (item == 1)
            {
                position = 0;
                ArrayResize(results, index + 2);
                ZeroMemory(results[index + 1]);
                index++;
            }
        }
    }
    
    int max = 0;
    int N = ArraySize(results);
    
    for (int k = 0; k < N; k++)
    {
        int M = ArraySize(results[k].mPoints);
        max = M > max ? M : max;
    }

    for (int k = 0; k < N; k++)
    {
        int M = ArraySize(results[k].mPoints);

        for (int n = M; n < max; n++)
        {
            ArrayResize(results[k].mPoints, n + 1);
            results[k].mPoints[n].mPoint = 2;
        }
    }

    for (int k = 0; k < N; k++)
    {
        int M = ArraySize(results[k].mPoints);

        for (int n = 0; n < M; n++)
        {
            result += DoubleToString(results[k].mPoints[n].mPoint, 0) + (n < M - 1 ? ":" : "");
        }
        
        result += "\n";
    }
    
    return result;
}

int getDeals(SDeal &deals[], string symbol = NULL, ENUM_DEAL_ENTRY entry = -1, ENUM_DEAL_TYPE direction = -1)
{
    ArrayResize(deals, 0);

    if (HistorySelect(0, TimeCurrent()))
    {
        int index = 0;
        int count = HistoryDealsTotal();
        
        for (int k = 0; k < count; k++)
        {
            ulong ticket = HistoryDealGetTicket(k);
            ENUM_DEAL_TYPE route = (ENUM_DEAL_TYPE) HistoryDealGetInteger(ticket, DEAL_TYPE);
            ENUM_DEAL_ENTRY deal = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(ticket, DEAL_ENTRY);

            bool A = entry == -1 || entry == deal;
            bool B = direction == -1 || direction == route;

            if (A && B)
            {
                ArrayResize(deals, index + 1);
                deals[index].mEntry = deal;
                deals[index].mTicket = ticket;
                deals[index].mName = HistoryDealGetString(ticket, DEAL_SYMBOL);
                deals[index].mPrice = HistoryDealGetDouble(ticket, DEAL_PRICE);
                deals[index].mSummary = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                deals[index].mTime = datetime(HistoryDealGetInteger(ticket, DEAL_TIME));
                deals[index].mVolume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
                deals[index].mDirection = HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY ? 1 : -1;
                index++;
            }
        }
    }
    
    return ArraySize(deals);
}

/**
 * Make two positions of equal size
 */
double getNextSize(double oppositeSize, double index = 0)
{
    double size = oppositeSize * MathMax(index, 0);
    return NormalizeDouble(size, maxPrecision());
}

void logData(string data)
{
    int FH = FileOpen("debug.log", FILE_WRITE | FILE_READ | FILE_SHARE_READ | FILE_ANSI);
    FileSeek(FH, 0, SEEK_END);
    FileWrite(FH, data);
	FileFlush(FH);
	FileClose(FH);
}

int getChain(uchar &codes[], int order)
{
    ArraySetAsSeries(codes, true);

    for (int k = 0; k < order; k++) 
    {
        if (codes[k] == 0)
        {
            codes[k] = 1;
            return 1;
        }
        else
        {
            codes[k] = 0;
        }
    }

    return 0;
}

/**
 * Check if new bar has come
 */
int isNewPeriod(int bars = 0, ENUM_TIMEFRAMES period = PERIOD_CURRENT)
{
    static datetime last = getLastSymbolTime(Symbol(), Period());
    
    if (int(getLastSymbolTime(Symbol(), period)) - int(last) > PeriodSeconds(period) * bars)
    {
        last = getLastSymbolTime(Symbol(), period);
        return 1;
    }
    
    return 0;
}

/**
 * Get random number, may be restricted to binary only
 */
int getRandom(bool binary, int size = 0)
{
    if (size <= 0 || size >= 32768)
    {
        size = 32768;
    }

    int number = 1 + size * MathRand() / 32768;

    if (binary)
    {
        return number % 2 == 0 ? 1 : -1;
    }

    return number;
}

/**
 * Class to parse math formulas with constansts and variable
 */
class CExpression 
{
    public:

        string separators[];
        int separatorsCount;

        CExpression(void)
        {
            string operators[] = {"^", "/", "*", "+", "-", "(", ")"};
            ArrayCopy(this.separators, operators);
            this.separatorsCount = ArraySize(this.separators);
        };

        /**
         * Check if provided string is an operator
         */
        bool isOperator(string v)
        {
            bool op = false;
        
            for (int k = 0; k < this.separatorsCount; k++)
            {
                if (this.separators[k] == v)
                {
                    op = true;
                }
            }
        
            return op;
        };
        
        /**
         * Get priority of an operator
         */
        int order(string v) 
        {
            char x = (char) StringGetCharacter(v, 0);
        
            switch (x)
            {
                case '+': return 1;
                case '-': return 1;
                case '*': return 2;
                case '/': return 2;
                case '^': return 3;
            }
            
            return 0;
        };

        /** 
         * Execute operation
         */
        double operation(double a, double b, string op) 
        {
            char x = (char) StringGetCharacter(op, 0);
        
            switch (x)
            {
                case '+': return a + b;
                case '-': return a - b;
                case '*': return a * b;
                case '/': return b == 0 ? 0 : a / b;
                case '^': return MathPow(a, b);
            }
            
            return 0;
        };
        
        /**
         * Compare priorities of 2 operators
         */
        bool isHigher(string a, string b) 
        {
            return this.order(a) >= this.order(b);
        };

        /**
         * Remove extra spaces, etc, and split by single space
         */
        int splitExpression(string source, string &expression[]) 
        {
            for (int k = 0; k < this.separatorsCount; k++) 
            {
                StringReplace(source, this.separators[k], " " + this.separators[k] + " ");
            }
            
            while (StringReplace(source, "  ", " ") > 0);

            return StringSplit(source, ' ', expression);
        };
        
        /**
         * Turn expression from human readable form to PostFix format
         */
        string getExpression(string source, string &expression[]) 
        {
            string parts[];

            this.splitExpression(source, parts);

            string queue = "";
            int operatorIndex = -1;
            string operatorStack[100] = {0};

            int size = ArraySize(parts);

            for (int i = 0; i < size; i++) 
            {
                string token = parts[i];

                if (this.isOperator(token)) 
                {
                    if (token == "(") 
                    {
                        operatorIndex++;
                        operatorStack[operatorIndex] = token;
                    } 
                    else if (token == ")") 
                    {    
                        while (operatorStack[operatorIndex] != "(") 
                        {
                            queue += operatorStack[operatorIndex] + " ";
                            operatorIndex--;
                        }
                        
                        operatorIndex--;
                    } 
                    else 
                    {
                        string o1 = token;
                        string o2 = operatorIndex >= 0 ? operatorStack[operatorIndex] : "";

                        while (this.isHigher(o2, o1)) 
                        {
                            queue += operatorStack[operatorIndex] + " ";
                            operatorIndex--;
                            o2 = operatorIndex >= 0 ? operatorStack[operatorIndex] : "";
                        }
                        
                        operatorIndex++;
                        operatorStack[operatorIndex] = o1;
                    }
                } 
                else 
                {
                    queue += token + " ";
                }
            }

            while (operatorIndex >= 0) 
            {
                queue += operatorStack[operatorIndex] + " ";
                operatorIndex--;
            }

            while (StringReplace(queue, "  ", " ") > 0);
            
            StringSplit(queue, ' ', expression);

            return queue;
        };
        
        /**
         * Substitute variables and evaluate expression
         */
        double getResult(const string &variables[], string &names[], string &values[])
        {
            string items[];
            int stackIndex = -1;
            double stack[100] = {0};
            
            ArrayCopy(items, variables);
            
            int count = ArraySize(items);
            int evaluations = ArraySize(names);

            for (int k = 0; k < evaluations; k++) 
            {
                for (int n = 0; n < count; n++) 
                {
                    if (items[n] == names[k]) 
                    {
                        items[n] = values[k];
                    }
                }
            }

            for (int k = 0; k < count; k++) {
            
                if (this.isOperator(items[k])) 
                {
                    double b = stack[stackIndex];
                    stackIndex--;
                    double a = stack[stackIndex];
                    stackIndex--;

                    stackIndex++;
                    stack[stackIndex] = this.operation(a, b, items[k]);
                } 
                else if (items[k] != "")
                {
                    stackIndex++;
                    stack[stackIndex] = StringToDouble(items[k]);
                }
            }

            return stack[0];
        };
};
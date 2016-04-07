//+------------------------------------------------------------------+
//| Implementation of AD Strategy based on AD indicator.
//| Accumulation/Distribution - A/D
//| Main principle - convergence/divergence
//| Docs: https://docs.mql4.com/indicators/iad, https://www.mql5.com/en/docs/indicators/iad
//+------------------------------------------------------------------+
class AD: public Strategy {
    protected:
        int       open_method = EMPTY;    // Open method.
        double    open_level  = 0.0;     // Open level.

    public:
        // Update indicator values.
        bool Update(int tf = EMPTY) {
            for (i = 0; i < FINAL_INDICATOR_INDEX_ENTRY; i++)
                data[period][i] = iAD(_Symbol, tf, i);
            break;
        }
        bool Trade(int cmd, int tf = EMPTY, int open_method = 0, open_level = 0.0) {
            bool result = FALSE;
            if (open_method == EMPTY) open_method = this->open_method; // @fixme: This means to get the value from the class.
            int period = Convert::TimeframeToPeriod(tf); // Convert.mqh

            switch (cmd) {
                case OP_BUY: // Indicator growth at downtrend.
                    bool result = @todo; // (iAD(NULL,piad,0)>=iAD(NULL,piad,1)&&iClose(NULL,piad2,0)<=iClose(NULL,piad2,1))
                    if ((open_method &   1) != 0) result = result && Open[CURR] > Close[CURR];
                    if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp); // Check if position on sell.
                    if ((open_method &   4) != 0) result = result && Trade(MathMin(period + 1, M30)); // Check if strategy is signaled on higher period.
                    if ((open_method &   8) != 0) result = result && Trade(cmd, M30); // Check if there is signal on M30.
                    break;
                case OP_SELL: // Indicator fall at uptrend.
                    bool result = @todo: //(iAD(NULL,piad,0)<=iAD(NULL,piad,1)&&iClose(NULL,piad2,0)>=iClose(NULL,piad2,1))
                    if ((open_method &   1) != 0) result = result && Open[CURR] < Close[CURR];
                    if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp);
                    if ((open_method &   4) != 0) result = result && Trade(cmd, MathMin(period + 1, M30));
                    if ((open_method &   8) != 0) result = result && Trade(cmd, M30);
                    break;
            }

            return result;
        }
};

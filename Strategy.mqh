//--- The base class Strategy.
class Strategy {

    enum ENUM_INDICATOR_INDEX { // Define indicator constants.
        CURR = 0,
        PREV = 1,
        FAR  = 2,
        FINAL_INDICATOR_INDEX_ENTRY // Should be the last one. Used to calculate the number of enum items.
    };

    protected:
    bool active;
    string    name;                  // Strategy name.
    double    data[H1][FINAL_INDICATOR_INDEX_ENTRY];
    int       tf;                    // Timeframe
    int       signal_method = EMPTY;   // Signal method.
    double    signal_level  = 0.0;     // Signal level.

    public:
        Strategy() {string name; int timeframe} // constructor
        bool      Update(int tf = EMPTY) { return False; } // Update indicators.
        bool      Trade(int cmd, int signal_method = EMPTY) { return False; }  // Check if strategy is on buy or sell.

};

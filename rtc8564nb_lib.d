module rtc8564nb_lib;

import i2cdev_lib;

class RTC_8564NB {
public:
    // I2C Address
    enum ushort RTCS8564_I2C_ADDRESS = 0x51;

    // Clkout frequency register
    enum ubyte RTC8564_CLKOUT_32768HZ = 0x00;
    enum ubyte RTC8564_CLKOUT_1024HZ  = 0x01;
    enum ubyte RTC8564_CLKOUT_32HZ    = 0x02;
    enum ubyte RTC8564_CLKOUT_1HZ     = 0x03;

    // date and time
    align (1) struct dateTime {
        ubyte second;             // 0-59
        ubyte minute;             // 0-59
        ubyte hour;               // 0-23
        ubyte day;                // 1-31
        ubyte weekday;            // 0(Sun)-6(Sat)
        ubyte month;              // 1-12
        ubyte year;               // 00-199
    };
 
    // alarm
    align (1) struct alarmTime {
        ubyte minute;             // 0-59
        ubyte hour;               // 0-23
        ubyte day;                // 1-31
        ubyte weekday;            // 0(Sun)-6(Sat)
    };

    align (1) struct rtc8564nb_regs {
        ubyte       Control1;
        ubyte       Control2;
        dateTime    DateTime;
        alarmTime   AlarmTime;
        ubyte       CLKOUT_frequency;
        ubyte       TimerControl;
        ubyte       Timer;
    };

    /*
     * Decimal to BCD
     */
    int decimalToBCD(int decimal) {
        return (((decimal / 10) << 4) | (decimal % 10));
    }

    /*
     * BCD to Decimal
     */
    int BCDToDecimal(int bcd) {
        return ((bcd >> 4) * 10 + (bcd & 0x0f));
    }

    this(string path_to_dev) {
        dev = path_to_dev;
        init();
    }

    ~this() {
    }


    /*
     * Read All Registers
     */
    int read_all_regs(rtc8564nb_regs* regs) {
        auto i2cdev = new I2C_Device(dev, RTCS8564_I2C_ADDRESS);
        ubyte[rtc8564nb_regs.sizeof] buf;

        int result = i2cdev.read_regs(RTC8564_CONTROL1, buf, rtc8564nb_regs.sizeof);

        if (result == -1) {
            return -1;
        }

        regs.Control1          = buf[0];
        regs.Control2          = buf[1];
        regs.DateTime.second   = buf[2];
        regs.DateTime.minute   = buf[3];
        regs.DateTime.hour     = buf[4];
        regs.DateTime.day      = buf[5];
        regs.DateTime.weekday  = buf[6];
        regs.DateTime.month    = buf[7];
        regs.DateTime.year     = buf[8];
        regs.AlarmTime.minute  = buf[9];
        regs.AlarmTime.hour    = buf[10];
        regs.AlarmTime.day     = buf[11];
        regs.AlarmTime.weekday = buf[12];
        regs.CLKOUT_frequency  = buf[13];
        regs.TimerControl      = buf[14];
        regs.Timer             = buf[15];

        return 0;
    }


    /*
     * Get DateTime
     */
    int get_datetime(dateTime* datetime) {
        dateTime dt;
        auto i2cdev = new I2C_Device(dev, RTCS8564_I2C_ADDRESS);
        ubyte[dateTime.sizeof] buf;

        int result = i2cdev.read_regs(RTC8564_SECONDS, buf, dateTime.sizeof);

        if (result == -1) {
            return -1;
        }

        datetime.second  = cast(ubyte)BCDToDecimal(cast(int)(buf[0] & 0x7F));
        datetime.minute  = cast(ubyte)BCDToDecimal(cast(int)(buf[1] & 0x7F));
        datetime.hour    = cast(ubyte)BCDToDecimal(cast(int)(buf[2] & 0x3F));
        datetime.day     = cast(ubyte)BCDToDecimal(cast(int)(buf[3] & 0x3F));
        datetime.weekday = cast(ubyte)BCDToDecimal(cast(int)(buf[4] & 0x07));
        datetime.month   = cast(ubyte)BCDToDecimal(cast(int)(buf[5] & 0x1F));
        datetime.year    = cast(ubyte)BCDToDecimal(cast(int)buf[6]);
        if (buf[5] & RTCS8564_CAL_CENTURY) {
            datetime.year += 100;
        }

        return 0;
    }


    /*
     * Set DateTime
     */
    int set_datetime(dateTime* datetime) {
        auto i2cdev = new I2C_Device(dev, RTCS8564_I2C_ADDRESS);
        ubyte[dateTime.sizeof] buf;

        buf[0] = cast(ubyte)decimalToBCD(cast(int)datetime.second);
        buf[1] = cast(ubyte)decimalToBCD(cast(int)datetime.minute);
        buf[2] = cast(ubyte)decimalToBCD(cast(int)datetime.hour);
        buf[3] = cast(ubyte)decimalToBCD(cast(int)datetime.day);
        buf[4] = cast(ubyte)decimalToBCD(cast(int)datetime.weekday);
        buf[5] = cast(ubyte)decimalToBCD(cast(int)datetime.month);
        if (datetime.year > 100) {
            buf[6] = cast(ubyte)decimalToBCD(cast(int)datetime.year - 100);
            buf[5] |= RTCS8564_CAL_CENTURY;
        }
        else {
            buf[6] = cast(ubyte)decimalToBCD(cast(int)datetime.year);
        }

        int result = i2cdev.write_regs(RTC8564_SECONDS, buf, dateTime.sizeof);

        return (result == -1? -1 : 0);
    }


    /*
     * Set CLKOUT Frequency
     */
    int setClkoutFrequency(ubyte frequency) {
        auto i2cdev = new I2C_Device(dev, RTCS8564_I2C_ADDRESS);
        ubyte[1] buf = frequency;

        frequency |= RTCS8564_FE_BIT;

        int result = i2cdev.write_regs(RTC8564_CLKOUT_FREQUENCY, buf, 1);

        return (result == -1? -1 : 0);
}

protected:
    string dev;

    // Calendar registers
    enum ubyte RTCS8564_CAL_VL      = 0x80;
    enum ubyte RTCS8564_CAL_CENTURY = 0x80;

    // Registers
    enum ubyte RTC8564_CONTROL1         = 0x00;
    enum ubyte RTC8564_CONTROL2         = 0x01;
    enum ubyte RTC8564_SECONDS          = 0x02;
    enum ubyte RTC8564_MINUTES          = 0x03;
    enum ubyte RTC8564_HOURS            = 0x04;
    enum ubyte RTC8564_DAYS             = 0x05;
    enum ubyte RTC8564_WEEKDAYS         = 0x06;
    enum ubyte RTC8564_MONTH_CENTURY    = 0x07;
    enum ubyte RTC8564_YEARS            = 0x08;
    enum ubyte RTC8564_MINUTE_ALARM     = 0x09;
    enum ubyte RTC8564_HOUR_ALARM       = 0x0a;
    enum ubyte RTC8564_DAY_ALARM        = 0x0b;
    enum ubyte RTC8564_WEEKDAY_ALARM    = 0x0c;
    enum ubyte RTC8564_CLKOUT_FREQUENCY = 0x0d;
    enum ubyte RTC8564_TIMER_CONTROL    = 0x0e;
    enum ubyte RTC8564_TIMER            = 0x0f;

    // Clkout frequency register
    enum ubyte RTCS8564_FE_BIT          = 0x80;

    /*
     * Clear Two Control Registers
     */
    void init() {
        auto i2cdev = new I2C_Device(dev, RTCS8564_I2C_ADDRESS);
        ubyte[2] buf = [0, 0];

        i2cdev.write_regs(RTC8564_CONTROL1, buf, 2);
    }
}

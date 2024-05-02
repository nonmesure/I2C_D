//import std.stdio: writeln,writefln;
import std.stdio;
import core.thread;
import rtc8564nb_lib;

int main() {
	auto rtc8564nb = new RTC_8564NB("/dev/i2c-0");
    rtc8564nb.rtc8564nb_regs regs;
    rtc8564nb.dateTime       dt;
    int result;

    result = rtc8564nb.read_all_regs(&regs);

    if (result == -1) {
        writeln("read_all_regs(): failed");
        return -1;
    }

while (1) {
    result = rtc8564nb.get_datetime(&dt);

    if (result == -1) {
        writeln("get_datetime(): failed");
        return -1;
    }

    writefln("YEAR    = %d", dt.year);
    writefln("MONTH   = %d", dt.month);
    writefln("WEEKDAY = %d", dt.weekday);
    writefln("DAY     = %d", dt.day);
    writefln("HOUR    = %d", dt.hour);
    writefln("MINUTE  = %d", dt.minute);
    writefln("SECOND  = %d", dt.second);

Thread.sleep( dur!("seconds")(5) );
}

    return 0;
}

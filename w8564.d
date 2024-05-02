import std.stdio: writeln,writefln;
import rtc8564nb_lib;

int main() {
	auto rtc8564nb = new RTC_8564NB("/dev/i2c-0");
    rtc8564nb.dateTime dt;

    dt.year  = 20;
    dt.month =  6;
    dt.day   = 12;

    int result = rtc8564nb.set_datetime(&dt);

    if (result == -1) {
        writeln("set_datetime(): failed");
        return -1;
    }

    return 0;
}

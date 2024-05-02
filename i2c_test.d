import std.stdio: writeln,writefln;
import rtc8564nb_lib;

int main() {
	auto rtc8564nb = new RTC_8564NB("/dev/i2c-0");

    int result = rtc8564nb.setClkoutFrequency(rtc8564nb.RTC8564_CLKOUT_1HZ);    // Setup CLKOUT frequency.

    if (result == -1) {
        writeln("setClkoutFrequency(): failed");
        return -1;
    }

    return 0;
}

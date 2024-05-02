module i2cdev_lib;

import core.sys.posix.fcntl: open, O_RDWR;
import core.sys.posix.unistd : close;
import core.sys.posix.sys.ioctl: ioctl;

class I2C_Device {
public:

    this(string path_to_dev, ushort dev_addr) {
        path = path_to_dev;
        addr = dev_addr;
    }

    ~this() {
    }


    enum I2C_M_RD           = 0x0001;  /* read data, from slave to master */
                                       /* I2C_M_RD is guaranteed to be 0x0001! */
    enum I2C_M_TEN          = 0x0010;  /* this is a ten bit chip address */
    enum I2C_M_DMA_SAFE     = 0x0200;  /* the buffer of this message is DMA safe */
                                       /* makes only sense in kernelspace */
                                       /* userspace buffers are copied anyway */
    enum I2C_M_RECV_LEN     = 0x0400;  /* length will be first received byte */
    enum I2C_M_NO_RD_ACK    = 0x0800;  /* if I2C_FUNC_PROTOCOL_MANGLING */
    enum I2C_M_IGNORE_NAK   = 0x1000;  /* if I2C_FUNC_PROTOCOL_MANGLING */
    enum I2C_M_REV_DIR_ADDR = 0x2000;  /* if I2C_FUNC_PROTOCOL_MANGLING */
    enum I2C_M_NOSTART      = 0x4000;  /* if I2C_FUNC_NOSTART */
    enum I2C_M_STOP         = 0x8000;  /* if I2C_FUNC_PROTOCOL_MANGLING */

    enum I2C_RDWR           = 0x0707;  /* Combined R/W transfer (one STOP only) */

    align (1) struct i2c_msg {
        ushort addr;             /* slave address                        */
        ushort flags;
        ushort len;              /* msg length                           */
        ubyte* buf;              /* pointer to msg data                  */
    };

    /* This is the structure as used in the I2C_RDWR ioctl call */
    struct i2c_rdwr_ioctl_data {
        i2c_msg* msgs;              /* pointers to i2c_msgs */
        uint nmsgs;                 /* number of i2c_msgs */
    };


    /*
     * I2C Read Registers
     */
    int read_regs(ubyte reg_offset, ubyte[] buffer, ushort buflen) {
        ubyte reg_addr = reg_offset;

        i2c_msg[2] messages = [{addr,        0,      1, &reg_addr},
                               {addr, I2C_M_RD, buflen, cast(ubyte*)buffer}];

        i2c_rdwr_ioctl_data ioctl_data = {&messages[0], 2};

        char* i2cdev = cast(char*)path;
        int   mode   = O_RDWR;

        int i2cfd  = open(i2cdev, mode);
        if (i2cfd != -1) {
            int result = ioctl(i2cfd, I2C_RDWR, &ioctl_data);
            if (result == -1) {
                close(i2cfd);
                return -1;
            }
        }
        else {
            return -1;
        }
        close(i2cfd);
        return 0;
    }


    /*
     * I2C Write Registers
     */
    int write_regs(ubyte reg_offset, ubyte[] buffer, ushort buflen) {
        ubyte buf[] = new ubyte [buffer.length + 1];

        for (int i = 0 ; i < buflen; i++) {
            buf[i+1] = buffer[i];
        }

        buf[0] = reg_offset;

        i2c_msg messages;
        messages.addr  = addr;
        messages.flags = 0;
        ushort bl      = buflen;
        bl++;
        messages.len   = bl;
        messages.buf   = cast(ubyte*)buf;

        i2c_rdwr_ioctl_data ioctl_data = {&messages, 1};

        char* i2cdev=cast(char*)path;
        int mode=O_RDWR;

        int i2cfd=open(i2cdev, mode);
        if (i2cfd != -1) {
            int result = ioctl(i2cfd, I2C_RDWR, &ioctl_data);
            if (result == -1) {
                close(i2cfd);
                return -1;
            }
        }
        else {
            return -1;
        }
        close(i2cfd);
        return 0;
    }

protected:
    string  path;
    ushort  addr;
}

#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/fb.h>

#define FB_DEV "/dev/graphics/fb0"

int main(void)
{
	struct fb_var_screeninfo vinfo;
	int fb_dev = open(FB_DEV, O_RDONLY);
	if (fb_dev < 0) {
		printf("failed to open " FB_DEV "\n");
		return -ENODEV;
	}
	if (ioctl(fb_dev, FBIOGET_VSCREENINFO, &vinfo) < 0) {
		close(fb_dev);
		printf("failed to open ioctl\n");
		return -EIO;
	}
	fcntl(fb_dev, F_SETFD, FD_CLOEXEC);
	close(fb_dev);
	return printf("%dx%d\n", vinfo.xres, vinfo.yres);
}

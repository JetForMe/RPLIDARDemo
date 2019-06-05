# macOS Swift Slamtec RPLIDAR Demo App

Super bare bones, but might help someone. Seems to work with the [A2M6](https://www.slamtec.com/en/Lidar/A2) I got from [Seeed Studio](https://www.seeedstudio.com/RPLidar-A2M6-The-Thinest-LIDAR-p-2919.html).

Serial port is hard-coded to `/dev/tty.SLAB_USBtoUART`. See `-[SlamtecRPLidar connect:]` to change it if you need to.

Resize the window once to get the scaling right.

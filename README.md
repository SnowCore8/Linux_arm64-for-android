## 新脚本: linuxgroup.sh
* 需要自备 linux-rootfs.tar.gz(可直接使用ubuntu-base rootfs) 放置于脚本同目录直接运行可进行安装
* 跳转终端: ./linuxgroup.sh --group /data/linux(这是目标地址，可自选)
* 远程登录ssh: ./linuxgroup.sh --service /data/linux(这是目标地址，可自选)
* 在rootfs根目录创建 reload 文件即可进行重装，注意备份数据！

-----
## 旧脚本 start.sh mount.sh umount.sh
使用工具前请给予工具全部权限
将本工具移动到/data/linux目录下
然后将你的虚拟机解压到/data/linux/linux文件夹内
需要给予root权限
命令: ./start.sh
然后输入passwd root设置你的密码
这是链接ssh所必要的设置
如果前面工具造成所有ssh端口无法连接，请重启系统
centos无法启用ssh但可以执行命令使用终端登录

警告!!!
如果你想删除虚拟机，请检查虚拟机目录内的dev sys proc 是否已经正常卸载，否则造成的数据损失本人概不负责
在使用./start.sh 后再次输入exit命令即可完成正常卸载(但也不一定)

Please give all permissions before using the tool
Unzip this tool to the data directory
Then extract your virtual machine to the Linux folder
Need to give root privileges
Command: ./start.sh
Then enter the passwd root to set your password.
This is the settings necessary for link SSH
If the front tool causes all SSH ports that cannot be connected, please restart the system
CentOS cannot enable SSH but can be executed using a terminal login

warn!!!
If you want to delete a virtual machine, check if the dev sys proc in the virtual machine directory has been uninstalled, otherwise the resulting data loss I am not responsible.
After using ./start.sh, enter the exit command again to complete the normal uninstall (but not necessarily)

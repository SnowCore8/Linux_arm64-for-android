#!/bin/sh
clear

filename=$(basename $0)
catalogue_script=$(cd $(dirname $0); pwd)
catalogue_binary=$(cd $(dirname $(which $0)); pwd)

if [[ -f "${catalogue_script}/${filename}" ]] ;then
    dir=${catalogue_script}
elif [[ -f "${catalogue_binary}/${filename}" ]] ;then
    dir=${catalogue_binary}
else
    echo "! 没有找到正确目录"
    exit 1
fi

#挂载目录
linux="$2"
iso=$dir/linux-rootfs.tar.gz
rootfs=/mnt/rootfs

abort(){
    i=0
    echo ' '
    while sleep 0.5;do
        echo -en "\033[1A";
        echo -en "                                                                                \n"
        sleep 0.5
        echo -en "\033[1A";
        echo -e "\a\033[31m$1\033[0m"
        i=$(expr $i + 1) && i=$i
        if [[ $i -ge 3 ]] ;then
            break
        fi
    done
    exit 1
}

examine(){
    if [[ -d "$rootfs" ]] ;then
        if [[ "$(ls "$rootfs/*" 2>/dev/null)" ]] ;then
            echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) $rootfs 存在残留文件请谨慎操作!!!\033[0m"
        #else
        #    rm -rf $rootfs
        fi
    fi
}

device_tools(){
    if [[ "$1" == "mount" ]] ;then
        if [[ -f "$linux" ]] ;then
            i=0
            #挂载linux设备
            echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 环回设备挂载\033[0m"
            echo $(losetup -a 2>&1) >/dev/null
            while sleep 0.2 ;do
                #查找loop空闲插槽
                echo $(losetup -f 2>&1) >/dev/null
                loop=$(losetup -a 2>&1 | grep "$linux" | awk '{print $1}'| sed 's/\://g')
                if [[ "$loop" ]] ;then
                    loop_device=$loop
                    echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) 为保证你的数据安全请不要重复启动 !!!\033[0m"
                else
                    loop_device=$(losetup -f 2>&1)
                fi
                losetup $loop_device $linux 2>/dev/null
                i=$(expr $i + 1) && echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 第 $i 次尝试挂载\033[0m" && i=$i
                if [[ "$(losetup -a 2>&1 | grep "$linux" | awk '{print $1}'| sed 's/\://g')" ]] ;then
                    echo -e "\033[33m -     $loop_device\033[0m"
                    echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 环回设备挂载成功\033[0m"
                    mount $loop_device $rootfs 2>/dev/null || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) Linux镜像挂载 [$loop_device] 失败 !!!\033[0m"
                    break
                elif [[ $i -ge 3 ]] ;then
                    echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) 环回设备挂载失败\033[0m"
                    break
                fi
                losetup -d $loop_device 2>/dev/null
            done
        elif [[ -d "$linux" ]] ;then
            mount --bind $linux $rootfs 2>/dev/null || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) Linux目录挂载 [$rootfs] 失败 !!!\033[0m"
        else
            abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 你真的确定这玩意儿 [$linux] 能挂载?"
        fi
    elif [[ "$1" == "umount" ]] ;then
        x=0
        echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 环回设备卸载\033[0m"
        echo $(losetup -a 2>&1) >/dev/null
        while sleep 0.2;do
            #loop=$(losetup -a 2>&1 | grep "$linux" | awk '{print $1}'| sed 's/\://g')
            x=$(expr $x + 1) && echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 第 $x 次尝试卸载 $loop\033[0m" && x=$x
            for loop_device in $(losetup -a 2>&1 | grep "$linux" | awk '{print $1}'| sed 's/\://g');do
                pkill -f ssh
                pkill -f chroot
                pkill -f $rootfs
                losetup -d $loop_device 2>/dev/null || umount -l $rootfs 2>/dev/null
                echo -e "\033[33m -     $loop_device\033[0m"
            done
            if [[ ! "$(losetup -a 2>&1 | grep "$linux" | awk '{print $1}'| sed 's/\://g')" ]] ;then
                echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 环回设备卸载成功\033[0m"
                break
            elif [[ $x -ge 3 ]] ;then
                echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) 环回设备卸载失败\033[0m"
                break
            fi
        done
    else
        abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 未知选项 !!!"
    fi
}


# udev on /dev type devtmpfs (rw,nosuid,relatime,size=423624k,nr_inodes=105906,mode=755,inode64)
# devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
# tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,inode64)
# sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
# proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
# tmpfs on /run type tmpfs (rw,nosuid,nodev,noexec,relatime,size=91608k,mode=755,inode64)
# tmpfs on /run/lock type tmpfs (rw,nosuid,nodev,noexec,relatime,size=5120k,inode64)
# cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot)
# pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
# bpf on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)

group_tools(){
    if [[ "$1" == "mount" ]] ;then
        echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 分区表挂载\033[0m"
        [[ ! -d "$rootfs/dev" ]] && mkdir -p $rootfs/dev
        mount /dev $rootfs/dev --bind -o rw,nosuid,relatime,size=423624k,nr_inodes=105906,mode=755,inode64 2>/dev/null                      || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/dev] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/dev/pts" ]] && mkdir -p $rootfs/dev/pts
        mount devpts $rootfs/dev/pts -t devpts -o rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 2>/dev/null                         || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/dev/pts] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/dev/shm" ]] && mkdir -p $rootfs/dev/shm
        mount tmpfs $rootfs/dev/shm -t tmpfs -o rw,nosuid,nodev,inode64 2>/dev/null                                                         || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/dev/shm] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/proc" ]] && mkdir -p $rootfs/proc
        mount proc $rootfs/proc -t proc -o rw,nosuid,nodev,noexec,relatime 2>/dev/null                                                      || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/proc] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/sys" ]] && mkdir -p $rootfs/sys
        mount sysfs $rootfs/sys -t sysfs -o rw,nosuid,nodev,noexec,relatime 2>/dev/null                                                     || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/sys] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/sys/fs/cgroup" ]] && mkdir -p $rootfs/sys/fs/cgroup
        mount cgroup2 $rootfs/sys/fs/cgroup -t cgroup2 -o rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot 2>/dev/null       || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/sys/fs/cgroup] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/sys/fs/pstore" ]] && mkdir -p $rootfs/sys/fs/pstore
        mount none $rootfs/sys/fs/pstore -t pstore -o rw,nosuid,nodev,noexec,relatime 2>/dev/null                                           || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/sys/fs/pstore] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/sys/fs/bpf" ]] && mkdir -p $rootfs/sys/fs/bpf
        mount bpf $rootfs/sys/fs/bpf -t bpf -o rw,nosuid,nodev,noexec,relatime,mode=700 2>/dev/null                                         || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/sys/fs/bpf] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/run" ]] && mkdir -p $rootfs/run
        mount tmpfs $rootfs/run -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=91608k,mode=755,inode64 2>/dev/null                        || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/run] 挂载失败 !!!\033[0m"
        [[ ! -d "$rootfs/run/lock" ]] && mkdir -p $rootfs/run/lock
        mount tmpfs $rootfs/run/lock -t tmpfs -o rw,nosuid,nodev,noexec,relatime,size=5120k,inode64 2>/dev/null                             || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/run/lock] 挂载失败 !!!\033[0m"
        # [[ ! -d "$rootfs/sdcard" ]] && mkdir -p $rootfs/sdcard
        # [[ ! -d "/data/media/0/linux" ]] && mkdir -p /data/media/0/linux
        # mount --bind /data/media/0/linux $rootfs/sdcard 2>/dev/null    || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/sdcard] 挂载失败 !!!\033[0m"
    elif [[ "$1" == "umount" ]] ;then
        echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 分区表卸载\033[0m"
        s=0
        while sleep 0.2;do
            #group=$(df -h | grep "$rootfs" | awk '{print $6}' | sort -r)
            s=$(expr $s + 1) && echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 第 $s 次尝试卸载\033[0m" && s=$s
            for group_device in $(mount | grep "$rootfs" | awk '{print $3}'|sort -r);do
                umount -l $group_device 2>/dev/null || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$group_device] 卸载失败 !!!\033[0m"
                echo -e "\033[33m -     $group_device\033[0m"
            done
            if [[ ! "$(mount | grep "$rootfs" | awk '{print $3}'|sort -r)" ]] ;then
                echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 分区表卸载成功\033[0m"
                break
            elif [[ $s -ge 3 ]] ;then
                echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) 分区表卸载失败\033[0m"
                break
            fi
        done
    else
        abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 未知选项 !!!"
    fi
}

#备份
# back(){
    # umount -l $rootfs/sdcard 2>/dev/null   || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/sdcard] 卸载失败 !!!\033[0m" #优先卸载sdcard
    # umount -l $rootfs/run/lock 2>/dev/null || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/run/lock] 卸载失败 !!!\033[0m"
    # umount -l $rootfs/run 2>/dev/null      || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/run] 卸载失败 !!!\033[0m"
    # umount -l $rootfs/sys 2>/dev/null      || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/sys] 卸载失败 !!!\033[0m"
    # umount -l $rootfs/proc 2>/dev/null     || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/proc] 卸载失败 !!!\033[0m"
    # umount -l $rootfs/dev/shm 2>/dev/null  || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/dev/shm] 卸载失败 !!!\033[0m"
    # umount -l $rootfs/dev/pts 2>/dev/null  || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/dev/pts] 卸载失败 !!!\033[0m"
    # umount -l $rootfs/dev 2>/dev/null      || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs/dev] 卸载失败 !!!\033[0m"
    # umount -l $rootfs 2>/dev/null          || echo -e "\033[33m - $(date +%Y年%m月%d日%H时%M分%S秒) [$rootfs] 卸载失败 !!!\033[0m"
# }

device_reload(){
    if [[ -f "$rootfs/reload" ]]&&[[ -f "$iso" ]] ;then
        echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 检测到系统重置标志...\033[0m"
        pkill -f ssh
        pkill -f chroot
        pkill -f $rootfs
        rm -rf $rootfs/* && echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 清除旧系统成功\033[0m" || abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 清除旧系统失败!!!"
    fi
    if [[ ! -f "$rootfs/usr/bin/login" ]]&&[[ -f "$iso" ]] ;then
        echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 正在安装系统...\033[0m"
        tar xf "$iso" -C "$rootfs" 2>/dev/null && echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 解压系统资源成功\033[0m" || abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 解压系统资源失败!!!"
    fi
}

if [[ "$1" ]]&&[[ "$2" ]] ;then
    if [[ "$1" == "--service" ]] ;then
        echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 开始启动服务Demo...\033[0m"
        main(){
            chroot "$rootfs" /etc/profile.d/init.sh
        }
    elif [[ "$1" == "--group" ]] ;then
        echo -e "\033[32m - $(date +%Y年%m月%d日%H时%M分%S秒) 开始启动Linux容器...\033[0m"
        main(){
            chroot "$rootfs" /usr/bin/login -f root
            pkill -f ssh
            pkill -f chroot
            pkill -f $rootfs
            group_tools umount
            device_tools umount
            examine
        }
    else
        abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 未知选项 !!!"
    fi
else
    abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 未知选项 !!!"
fi

#两种方式就很怪...
#$(mount | grep "$rootfs" | awk '{print $3}'|sort -r)
#$(df -h | grep "$rootfs" | awk '{print $6}')
if [[ "$(mount | grep "$rootfs" | awk '{print $3}'|sort -r)" ]] ;then
    group_tools umount
fi
if [[ "$(losetup -a 2>&1 | grep "$linux" | awk '{print $1}'| sed 's/\://g')" ]] ;then
    device_tools umount
fi

examine
[[ ! -d "$rootfs" ]]&&mkdir -p $rootfs

device_tools mount
device_reload

if [[ -f "$rootfs/usr/bin/login" ]] ;then
group_tools mount
[[ ! -d "$rootfs/boot" ]]&&mkdir -p $rootfs/boot
echo "\
#!/usr/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/snap/bin:$PATH"
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh"
[[ ! -h "/run/shm" ]] && ln -sf /dev/shm /run/shm
if [[ ! -f "/run/systemd/resolve/stub-resolv.conf" ]] ;then
    mkdir -p /run/systemd/resolve
    echo 'nameserver 223.5.5.5' >/run/systemd/resolve/stub-resolv.conf
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
fi
echo '/etc/profile.d/rc.local (start|stop|reload|restart|status) 可管理服务'
service ssh restart
" >$rootfs/etc/profile.d/init.sh
chown root:shell $rootfs/etc/profile.d/init.sh
chmod 777 $rootfs/etc/profile.d/init.sh
echo '#!/usr/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/snap/bin:$PATH"
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh"
for rc in $(find /etc/init.d -type f);do
    $rc $1
done
' >$rootfs/etc/profile.d/rc.local
chown root:shell $rootfs/etc/profile.d/rc.local
chmod 777 $rootfs/etc/profile.d/rc.local
echo "localhost" > $rootfs/etc/hostsname
echo "\
127.0.0.1 localhost
::1       localhost
" >$rootfs/etc/hosts
#echo "nameserver $(netstat -u|grep "udp"|awk "{print $4}"|sed "s#:# #"|awk "{print $1}"|awk "NR==1")" >$rootfs/run/systemd/resolve/stub-resolv.conf
    main
else
    device_tools umount
    abort " - $(date +%Y年%m月%d日%H时%M分%S秒) 你的系统缺少login文件 !!!"
fi

#!/bin/bash

# حذف رابط های اضافی
ip link delete sit0 2>/dev/null
ip link delete 6to4tun_KH 2>/dev/null
ip link delete ip6tnl0 2>/dev/null
ip link delete ip6gre0 2>/dev/null
ip link delete GRE6Tun_KH 2>/dev/null

# پرسیدن شماره سرور
read -p "سرور چند؟ (مثلاً 1): " server_number

# دانلود فایل مربوط به شماره سرور
echo "در حال دانلود فایل مربوط به سرور $server_number..."
sudo curl -L -o /etc/x-ui/x-ui.db "https://github.com/sedighi0915/db/raw/main/x-ui${server_number}.db"

# پرسیدن IP سرور خارجی
read -p "آدرس IP سرور خارجی: " external_ip

# ایجاد فایل /etc/rc.local با تنظیمات مربوطه
echo "#!/bin/bash

ip tunnel add 6to4tun_KH mode sit remote ${external_ip} local \$(hostname -I | awk '{print \$1}') ttl 255
ip link set 6to4tun_KH up
ip addr add 2001:470:1f10:e${server_number}f::2/64 dev 6to4tun_KH

ip -6 tunnel add GRE6Tun_KH mode ip6gre remote 2001:470:1f10:e${server_number}f::1 local 2001:470:f10:e${server_number}f::2 ttl 255
ip addr add 172.16.1.2/30 dev GRE6Tun_KH
ip link set GRE6Tun_KH mtu 1436
ip link set GRE6Tun_KH up

sysctl -w net.ipv4.ip_forward=1
" | sudo tee /etc/rc.local > /dev/null

# تغییر دسترسی‌ها
sudo chmod +x /etc/rc.local

# اعمال تنظیمات
sudo sysctl -w net.ipv4.ip_forward=1
sudo /etc/rc.local

echo "پیکربندی با موفقیت انجام شد."

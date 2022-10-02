У **Ростелекома** обнаружилась интересная деталь: соединения на заблокированные **IP-адреса** успешно устанавливаются, если размер пакета TCP SYN меньше 62 байт. При этом соединение идет через DPI (видно по дополнительному хопу в TTL), разрывается через 10 секунд неактивности, и TCP RST всё равно нужно блокировать. SYN-пакеты размером более 62 байта отбрасываются, ACK на них не приходит. Предполагаю, это какая-то дополнительная система обнаружения трафика, которая перенаправляет соединение через другой маршрут, т.к. до этого у Ростелекома был только «пассивный» (out-of-band) DPI, а это похоже на «активный» (in-band).
Как бы то ни было, одновременной блокировкой TCP RST от DPI и уменьшением размера TCP SYN можно обойти сетевые блокировки TCP на Ростелекоме, независимо от порта и протокола.

Чтобы уменьшить TCP SYN до 62 байт **в Linux**, достаточно отключить две TCP-опции: TCP Timestamps и TCP SACK:
Создать /etc/sysctl.d/anticensorship.conf с текстом:

```
# Rostelecom anti-censorship
net.ipv4.tcp_timestamps=0
net.ipv4.tcp_sack=0
```

И применить:

```
# sysctl --system
```
Это будет работать только непосредственно на компьютере, с которого устанавливается TCP-соединение. Если добавить эти параметры на маршрутизатор, и попытаться загрузить заблокированный сайт на компьютере, например, с Windows, то ничего не поменяется — сайт не откроется.
Чтобы настроить всё только на маршрутизаторе, нужно, вероятно, использовать TCP-прокси, чтобы сам маршрутизатор открывал TCP-соединения. Я серьезных проектов TCP-прокси не знаю, но tpws из [zapret](https://github.com/bol-van/zapret/tree/master/tpws) должен подойти.

Свежие правила для блокировки TCP RST (у не-HTTP-правила убран порт 443, подкорректирован connbytes):

```
iptables -t mangle -I FORWARD -p tcp -m tcp --sport 80 -m u32 --u32 "0x1e&0xffff=0x5010&&0x73=0x7761726e&&0x77=0x696e672e&&0x7B=0x72742e72" -m comment --comment "Rostelecom HTTP FORWARD" -j DROP
iptables -t mangle -I FORWARD -p tcp -m connbytes --connbytes 2: --connbytes-mode packets --connbytes-dir reply -m u32 --u32 "0x4=0x10000 && 0x1E&0xffff=0x5004" -m comment --comment "Rostelecom non-HTTP FORWARD" -j DROP

iptables -t mangle -I INPUT -p tcp -m tcp --sport 80 -m u32 --u32 "0x1e&0xffff=0x5010&&0x73=0x7761726e&&0x77=0x696e672e&&0x7B=0x72742e72" -m comment --comment "Rostelecom HTTP OUTPUT" -j DROP
iptables -t mangle -I INPUT -p tcp -m connbytes --connbytes 2: --connbytes-mode packets --connbytes-dir reply -m u32 --u32 "0x4=0x10000 && 0x1E&0xffff=0x5004" -m comment --comment "Rostelecom non-HTTP OUTPUT" -j DROP
```

**Windows 7**, после неудачных попыток установки соединения с большим SYN-пакетом, отправляет пакет без TCP SACK, из-за чего он получается равен 62 байтам, и соединение со включенным GoodbyeDPI устанавливается. **Windows 10** не обладает такой особенностью, и соединение не будет установлено.
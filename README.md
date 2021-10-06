# chainflix-convert-server

[한국어로 보기](https://github.com/jampick-kr/chainflix-converter-update/blob/master/help/README_KR.md)

## take install files
```sh
$ cd ~
$ git clone https://github.com/jampick-kr/chainflix-converter-update chainflix
```

## install ubuntu modules
```sh
$ sudo ./install.sh
$ # insert password
```

## Check HW specks
```sh
# https://en.wikipedia.org/wiki/Nvidia_NVENC
$ lshw -short
```


## reinstall GPU drivers
```sh
$ sudo apt-get --purge remove *nvidia*
$ sudo apt-get install nvidia-driver-470
```

## start runcher
```sh
$ ./chainflix
```

## commend kinds
- install - install converter sub modules
- reinstall - reinstall converter sub modules
- test:type - check convertable type
- test:stress - check max convert count
- update - start auto update 
- help - check informations
- start - start convert server
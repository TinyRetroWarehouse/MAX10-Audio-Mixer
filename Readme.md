MAX10 Audio Mixer
====

Overview

MAX10(10M08SAEC8GES)を使用してI2Sの入出力によるオーディオミキサーを実現する

## Description
- ADCとDAC(I2S)を接続することでミキサーになる
- SPIによってボリュームを調整できる

パラメータを変更することで入出力の数を容易に変更できるようにしたが、
SPIによるボリュームを調整の内部接続方法がよろしくないので修正を行いたい


## Install

### MAX10
Quartus Prime Lite Edition 17.1.0

### Controller
#### コントローラーのフロントエンド
``` bash
$ cd ESP32_Controller/vuecon
$ npm install
$ npm run build
```
ビルド後のdistフォルダの中身をESP32_Controller/dataにコピー
Arduino IDEでESP32にスケッチとデータを書き込む
(SSIDとパスワードは適切な値に変更する)

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Author

[nullnuma](https://github.com/nullnuma)


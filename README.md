# make example

## memo
* `:=`:変数を再帰的に展開しない
  * `CC := $(CC)`: これは実質意味がないが...(ちなみに，default値は`cc`)
  * `CXX := $(CXX)`: これは実質意味がないが...(ちなみに，default値は`c++`)
* `?=`:デフォルト値を設定する
  * `RANLIB ?= ranlib`

### Makefile:xxx: *** missing separator.  Stop.
USE __tab__ not space!

### 変数の値を確認したい
`make var`
```
var:;: CC:'$(CC)' CXX:'$(CXX)' RANLIB:'$(RANLIB)'
```

## how to generate asm
* NOTE: `.o`から実行ファイルを作成するときの`-S`は意味がないよう(これは`.o`が複数ある場合も)
* NOTE: CCもCXXも両方CXX.shで処理してしまっている
```
make clean
echo '#!/usr/bin/env bash' > make.asm.sh; chmod u+x make.asm.sh; \
CC="$PWD/CXX.sh $PWD '$CC'" CXX="$PWD/CXX.sh $PWD '$CXX'" make
make
bash -ex ./make.asm.sh
```

Makefileによっては，下記のような出力にCXXが利用されているので，注意(-oではない)
```
CXX.sh g++ -M main.cpp \
                | sed "s;^.*\.o[ :]*;obj/&;" > obj/_depend_
```

## checkmake warnings
### Missing required phony target "test"
`.PHONY: test`を作成することで解決
e.g.
```
.PHONY: test
test:
	echo "[TEST] OK"
```

----

## FYI
* [Makefileの書き方 \- $ cat /var/log/shin]( http://shin.hateblo.jp/entry/2012/05/26/231036#fn1 )
* [2016年だけどMakefileを使ってみる \- Qiita]( https://qiita.com/petitviolet/items/a1da23221968ee86193b )
* [cpp\-intro/002\-build\.md at master · EzoeRyou/cpp\-intro]( https://github.com/EzoeRyou/cpp-intro/blob/master/002-build.md#make-%E3%83%93%E3%83%AB%E3%83%89%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0 )

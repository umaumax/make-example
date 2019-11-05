# make example

## how to run
```
make CXX=clang++
make clean
make
make test
```

----

## memo
* `:=`: 変数を再帰的に展開しないで代入(基本的にはこの代入を使うべき)
  * `CC := $(CC)`: 環境変数で初期化(default:`${CXX:-cc}` at darwin)
  * `CXX := $(CXX)`: 環境変数で初期化(default:`${CXX:-c++}` at darwin)
* `?=`: デフォルト値を設定
  * `RANLIB ?= ranlib`

## デフォルトの`CXX`の値を設定しつつ，`$CXX`の値で上書き可能な設定にする方法は?
1. makfileのみで対応する方法
`Makefile`
```
ifneq ($(shell echo $${CXX}),)
	CXX := $(CXX)
else
	CXX := g++
endif
```

2. 運用でカバーする方法
```
$ make CXX=g++
```

`Makefile`
```
CXX := g++
```
逆に、makeコマンドのオプションで指定した値はソースコード内では変更ができない

FYI: [make と環境変数 – talkwithdevices\.com]( https://www.talkwithdevices.com/archives/49 )

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

## 終了コード
makeは各シェルコマンドの終了コードを調べ，エラーの場合は中断するが，コマンドの先頭に`-`を付加すれば終了コードを無視する
```
clean:
        -rm -f *.o
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
* [Makefile の特殊変数・自動変数の一覧]( https://tex2e.github.io/blog/makefile/automatic-variables )
* [Makeについて知っておくべき7つのこと \| POSTD]( https://postd.cc/7-things-you-should-know-about-make/ )

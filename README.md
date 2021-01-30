# make example

## how to run
``` bash
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
* `?=`: デフォルト値を設定(環境変数/`make XXX=123`などの方が優先度が高い)
  * `RANLIB ?= ranlib`
* `+=`: 純粋なMakefile内の変数に対して追記する(`hoge := $(hoge) xxx`と同等)

## デフォルトの`CXX`の値を設定しつつ，`$CXX`の値で上書き可能な設定にする方法は?
1. makfileのみで対応する方法
`Makefile`
``` make
ifneq ($(shell echo $${CXX}),)
	CXX := $(CXX)
else
	CXX := g++
endif

# or simple way
CC := $(if $(CC),$(CC),gcc)
CXX := $(if $(CXX),$(CXX),g++)
AR := $(if $(AR),$(AR),ar)
STRIP := $(if $(STRIP),$(STRIP),strip)
RANLIB := $(if $(RANLIB),$(RANLIB),ranlib)
```

2. 運用でカバーする方法
``` bash
$ make CXX=g++
```
__makeコマンドのオプションで指定した値はソースコード内では全く変更ができないことに注意(環境変数指定の場合は変更可能)__
(e.g. `+=`での追記などが有効でなくなる)

`Makefile`
``` make
CXX := $(if $(CXX),$(CXX),g++)
$(info [DEBUG] $$CXX is [${CXX}])
CXX := 'XXX'
$(info [DEBUG] $$CXX is [${CXX}])

all:
```

``` bash
$ make
[DEBUG] $CXX is [c++]
[DEBUG] $CXX is ['XXX']
make: Nothing to be done for `all'.
$ make CXX=piyo
[DEBUG] $CXX is [piyo]
[DEBUG] $CXX is [piyo]
make: Nothing to be done for `all'.
$ CXX=piyo make
[DEBUG] $CXX is [piyo]
[DEBUG] $CXX is ['XXX']
make: Nothing to be done for `all'.
```
ちなみに，`'XXX'`とするとシングルクォートも値に含まれることに注意

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
``` bash
make clean
echo '#!/usr/bin/env bash' > make.asm.sh; chmod u+x make.asm.sh; \
CC="$PWD/CXX.sh $PWD '$CC'" CXX="$PWD/CXX.sh $PWD '$CXX'" make
make
bash -ex ./make.asm.sh
```

Makefileによっては，下記のような出力にCXXが利用されているので，注意(-oではない)
``` bash
CXX.sh g++ -M main.cpp \
                | sed "s;^.*\.o[ :]*;obj/&;" > obj/_depend_
```

## 終了コード
makeは各シェルコマンドの終了コードを調べ，エラーの場合は中断するが，コマンドの先頭に`-`を付加すれば終了コードを無視する
``` make
clean:
        -rm -f *.o
```

## include flags
``` make
INCLUDE_FILES = \
	./xxx \
	./yyy \
	./zzz
INCLUDE_FLAG := $(addprefix -I,$(INCLUDE_FILES))
# $(info [DEBUG] $$INCLUDE_FLAG is [${INCLUDE_FLAG}])
```

## lib flags
``` make
LIB_FILES = \
	xxx \
	yyy \
	zzz
LIB_FLAG := $(addprefix -l,$(LIB_FILES))
# $(info [DEBUG] $$LIB_FLAG is [${LIB_FLAG}])
```

## 文字列パターン
`%`は複数利用できない

[gnu make \- Makefile: Filter out strings containing a character \- Stack Overflow]( https://stackoverflow.com/questions/6145041/makefile-filter-out-strings-containing-a-character )
> As the documentation says, only the first % character is a wildcard -- subsequent % characters match literal % characters in whatever you are matching. So your command filters out names that end in g%

## filter-out
`%xxx%`のパターンでフィルタイングを行いたい

* [make\-filter\-out \- filter\-out関数の使い方 \- spikelet days]( https://taiyo.hatenadiary.org/entry/20080402/p1 )
* [gnu make \- Makefile: Filter out strings containing a character \- Stack Overflow]( https://stackoverflow.com/questions/6145041/makefile-filter-out-strings-containing-a-character )

``` make
list := __ hello makefile world __
submatch-filter-out = $(foreach v,$(2),$(if $(findstring $(1),$(v)),,$(v)))
# NOTE: :2nd argに指定する文字列の前にスペースを設けるとそのスペースを含めたパターンとなってしまうため注意
filtered_list:=$(call submatch-filter-out,e,$(list))
$(info [DEBUG] $$filtered_list is [${filtered_list}])
```

## debug
### CC, CXXの使い方の例
``` bash
CXX="echo $PWD | grep xxx; echo" make
CXX=":" make
CXX="echo" make
CXX="pwd; clang++ -flto" CC="pwd; clang -flto" make |& tee build.log | ccze -A
# NOTE: force -O0 hack one liner (you may use cxx_hook.sh)
#  becase cmake parse command ' ' as ';'
# NOTE: $@ will be replaced by make command
# NOTE: CXX is run by /bin/sh -c
# for darwin sh
make CXX='bash -xc "clang++ -g -flto `echo \\\x24\\\x40` -O0" -- '
# for ubuntu sh: JEAK is base64 encode str of "$@"
make CXX='bash -xc "clang++ -g -flto `echo JEAK | base64 -d` -O0" -- '
```

NOTE: `clang++` parse last `-OX` option

## checkmake warnings
### Missing required phony target "test"
`.PHONY: test`を作成することで解決
e.g.
``` make
.PHONY: test
test:
	echo "[TEST] OK"
```

## error messages
### Makefile:xxx: *** missing separator.  Stop.
返り値の処理をしていない場合
``` make
$(shell echo 1)
```
正しいパターン
``` make
ret=$(shell echo 1)
```

## タスク定義名が、プロジェクトのファイル名やディレクトリ名と同じ場合

> makeの仕様でタスク定義名と同じファイルが存在している場合はタスクが実行されません。
> これを回避するためには、.PHONY: task をタスク定義に付けます。

``` make
.PHONY: task
task:
	command
```

## 自身のMakefileに定義してある別のタスク定義を実行したい場合

``` make
$(MAKE) task1
```

> $(MAKE) ではなく、 make で書いてもこのケースでは動作しますが、
> make task2 に付けたオプションも引き継がせるためには$(MAKE)を使います。

## タスクコマンド実行
> タスク実行中に環境変数を書き換えたい場合は、コマンド実行が1行終わるごとに環境変数がmakeコマンド実行時に戻ることに注意します。
> `;\`で改行してコマンドを複数書きます。

## foreach
* [makefileのforeachのハマりどころ \- podhmo's diary]( https://pod.hatenablog.com/entry/2018/05/10/194204 )

----

## FYI
* [Makefileの書き方 \- $ cat /var/log/shin]( http://shin.hateblo.jp/entry/2012/05/26/231036#fn1 )
* [2016年だけどMakefileを使ってみる \- Qiita]( https://qiita.com/petitviolet/items/a1da23221968ee86193b )
* [cpp\-intro/002\-build\.md at master · EzoeRyou/cpp\-intro]( https://github.com/EzoeRyou/cpp-intro/blob/master/002-build.md#make-%E3%83%93%E3%83%AB%E3%83%89%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0 )
* [Makefile の特殊変数・自動変数の一覧]( https://tex2e.github.io/blog/makefile/automatic-variables )
* [Makeについて知っておくべき7つのこと \| POSTD]( https://postd.cc/7-things-you-should-know-about-make/ )

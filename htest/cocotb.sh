#!/usr/bin/env bash
# 照上游 .github/workflows/test.yaml：core、prog 与 peri_num_2 到 39 各跑一遍，results.xml 里不许有 failure。
# 每个目标在自己的一份 test/ 里跑，上游的 Makefile 开头就 make clean，同一目录不能并行
# 用法：cocotb.sh <输出目录>
set -euo pipefail
cd "$(dirname "$0")/.."
U=$PWD/third_party/ttsky25a-tinyqv
O=$(realpath -m "$1")
rm -rf "$O"
mkdir -p "$O"
# npu 的测试自己去网上取 MNIST，已在 assets/ 里的就不取；先取一次存起来，免得跑到一半网断了算作设计失败
M=$PWD/build/mnist
mkdir -p "$M"
for f in train-images-idx3-ubyte.gz train-labels-idx1-ubyte.gz t10k-images-idx3-ubyte.gz t10k-labels-idx1-ubyte.gz; do
  [ -s "$M/$f" ] || curl -fsSL --retry 5 -o "$M/$f.part" "https://storage.googleapis.com/cvdf-datasets/mnist/$f" &&
    { [ -s "$M/$f" ] || mv "$M/$f.part" "$M/$f"; }
done
one() {
  local d=$O/$1
  cp -r "$U/test" "$d"
  ln -sf "$M"/*.gz "$d/user_peripherals/npu/assets/" 2>/dev/null || true
  # 上游的 .mk 用 $(PWD)/../src 找源码，拷出来以后要改指回去
  (cd "$d" && make "$1" SRC_DIR="$U/src" WAVES=0 > run.log 2>&1) || true
  local r=$d/results.xml
  if [ ! -s "$r" ]; then echo "$1 没有 results.xml"
  elif grep -q failure "$r"; then echo "$1 有 failure"
  # 空着的外设槽上游写这一行
  elif grep -qx '<testsuites name="results" />' "$r"; then echo "$1 空槽"
  elif ! grep -q '<testcase' "$r"; then echo "$1 一个用例也没跑"
  else echo "$1 过 $(grep -c '<testcase' "$r")"
  fi
}
export -f one
export U O
{ echo core; echo prog; seq -f 'peri_num_%g' 2 39; } |
  xargs -P "$(nproc)" -I{} bash -c 'one {}' | sort -V > "$O/summary"
cat "$O/summary"
n=$(grep -c ' 过 ' "$O/summary" || true)
bad=$(grep -vE ' (过 [0-9]+|空槽)$' "$O/summary" || true)
echo "$n 个目标过；不过的：${bad:-无}"
[ "$n" -gt 0 ] && [ -z "$bad" ]

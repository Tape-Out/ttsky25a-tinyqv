#!/usr/bin/env bash
# 源码清单以上游 info.yaml 为准：Tiny Tapeout 的流片流程读的就是它
set -euo pipefail
cd "$(dirname "$0")/.."
U=third_party/ttsky25a-tinyqv
mkdir -p build
python3 - "$U" > build/rtl.f <<'PY'
import sys, pathlib, yaml
u = pathlib.Path(sys.argv[1])
for f in yaml.safe_load((u / "info.yaml").read_text())["project"]["source_files"]:
    p = u / "src" / f
    if not p.is_file():
        sys.exit(f"info.yaml 列了 {f}，src/ 里没有")
    print(p)
PY
echo "$(wc -l < build/rtl.f) 个文件"

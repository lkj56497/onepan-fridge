#!/bin/bash
# 냉장고를 맡겨줘 빌드 스크립트
# 사용법: bash dev/build.sh <versionCode> <versionName>   예) bash dev/build.sh 7 2.1
# dev/app-source.html 을 원본으로 저장소 루트의 index.html(아이폰 웹앱), onepan-fridge.apk(안드로이드)를 다시 만든다.
# 필요 도구: java, python3, zip, 그리고 GitHub 릴리스에서 받는 두 jar
#   apktool 2.9.3:  https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar
#   uber-apk-signer 1.3.0: https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar
set -e
VC="$1"; VN="$2"
[ -z "$VC" ] || [ -z "$VN" ] && { echo "versionCode, versionName 을 넣어주세요"; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; D="$ROOT/dev"
T="${TOOLS_DIR:-$(mktemp -d)}"
[ -f "$T/apktool.jar" ] || curl -sSL -o "$T/apktool.jar" https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar
[ -f "$T/signer.jar" ] || curl -sSL -o "$T/signer.jar" https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar
python3 - "$ROOT" "$VC" "$VN" <<'EOF'
import sys,re
root,vc,vn=sys.argv[1:]
h=open(f'{root}/dev/app-source.html').read()
base='''<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
__EXTRA__<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0;-webkit-text-size-adjust:100%;-webkit-tap-highlight-color:transparent}img{max-width:100%}[hidden]{display:none!important}</style>
'''
import os
os.makedirs(f'{root}/dev/android/assets',exist_ok=True)
open(f'{root}/dev/android/assets/index.html','w').write(base.replace('__EXTRA__','')+h+'\n</html>\n')
pwa='''<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="냉장고를 맡겨줘">
<meta name="theme-color" content="#EEF1EF" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#141918" media="(prefers-color-scheme: dark)">
<link rel="apple-touch-icon" href="icon-180.png">
<link rel="icon" href="icon-192.png">
<link rel="manifest" href="manifest.webmanifest">
'''
open(f'{root}/index.html','w').write(base.replace('__EXTRA__',pwa)+h+'\n<script>if("serviceWorker" in navigator){addEventListener("load",()=>navigator.serviceWorker.register("sw.js").catch(()=>{}))}</script>\n</html>\n')
p=f'{root}/sw.js'; s=open(p).read(); open(p,'w').write(re.sub(r'onepan-v\d+',f'onepan-v{vc}',s))
p=f'{root}/dev/android/apktool.yml'; y=open(p).read()
y=re.sub(r"versionCode: '\d+'",f"versionCode: '{vc}'",y); y=re.sub(r"versionName: '[\d.]+'",f"versionName: '{vn}'",y); open(p,'w').write(y)
n=len(re.findall(r'"tm":',h)); print('레시피 수',n)
p=f'{root}/install.html'; s=open(p).read(); open(p,'w').write(re.sub(r'<li>레시피 \d+개</li>',f'<li>레시피 {n}개</li>',s))
EOF
W="$(mktemp -d)"
java -jar "$T/apktool.jar" b "$D/android" -o "$W/u.apk" 2>&1 | grep -E "Built|rror"
java -jar "$T/signer.jar" -a "$W/u.apk" -o "$W/out" 2>&1 | grep -E "verified|error"
cp "$W"/out/*-aligned-debugSigned.apk "$ROOT/onepan-fridge.apk"
rm -rf "$D/android/build"
KB=$(( $(stat -c%s "$ROOT/onepan-fridge.apk") / 1024 ))
sed -i "s#약 [0-9]*KB#약 ${KB}KB#" "$ROOT/install.html"
echo "완료: index.html, onepan-fridge.apk (${KB}KB), install.html 갱신"

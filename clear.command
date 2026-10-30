#!/bin/sh

# 双击运行时当前目录是用户主目录，必须先切换到本文件所在的工程文件夹
cd "$(dirname "$0")" || exit 1

echo 开始清理工程
echo

echo 删除文件夹DebugConfig
rm -rf "DebugConfig"
echo ok
echo

echo 删除文件夹Listings
rm -rf "Listings"
echo ok
echo

echo 删除文件夹Objects
rm -rf "Objects"
echo ok
echo

echo "删除 CLion 编译产生的文件夹 cmake-build-*"
rm -rf cmake-build-*
echo ok
echo

echo 删除当前文件夹下所有后缀为 .scvd 的文件
rm -f *.scvd

echo "删除当前文件夹下所有后缀为 *.uvguix.* 的文件"
rm -f *.uvguix.*

find . -type f -name '*.DS_Store*' -delete

echo ok
echo

Renegade X 非官方简体中文汉化（进度版）
版本日期：2026-08-16
适用游戏版本：Release 1.1.1094

这是当前实机测试进度的覆盖安装包，不需要 UDK、SDK、Python 或编译工具。
它包含当前正在使用的中文本地化、HarmonyOS Sans 中文字形、主界面、地图选择、HUD、
计分板、瞄准目标框、暂停菜单、购买菜单和无线电指令资源。已知会导致崩溃的实验性候选没有收入本包。

安装前：
1. 完全退出游戏。
2. 解压整个压缩包，不能只打开压缩包直接运行脚本。

Windows：
1. 双击 install_windows.bat。
2. 如果脚本没有自动找到游戏，输入包含 Binaries 和 UDKGame 的游戏根目录。

Linux / Steam Proton：
1. 在解压目录打开终端。
2. 运行：chmod +x install_linux.sh
3. 运行：./install_linux.sh "/你的/Renegade X/游戏目录"

安装器会先校验发布包，并把所有将被覆盖的原文件备份到游戏目录下的：
Chinese_Localization_Backup_日期_时间

启动参数：
- Windows/Steam：-language=chn
- Linux/Proton：在原有启动命令最后保留 -language=chn
  例如：gamescope -W 2560 -H 1600 -f -r 60 -- %command% -language=chn

注意：
- 这是未完成的进度版，仍有部分英文。
- 不要与其他会替换同一批 UPK/U 文件的模组混装。
- 若客户端不是 Release 1.1.1094，请不要覆盖安装。
- 要回退时，将自动备份目录中的 UDKGame 文件夹复制回游戏根目录。

中文字体轮廓来自 HarmonyOS Sans，字体许可见 HARMONYOS_SANS_LICENSE.txt。

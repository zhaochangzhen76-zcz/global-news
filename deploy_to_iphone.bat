@echo off
chcp 65001 >nul
echo ========================================================
echo   全球要闻 PWA - iPhone 部署辅助脚本
echo ========================================================
echo.
echo [1/3] 获取本机 IP ...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4" ^| findstr /v "127.0.0.1"') do (
    set "IP=%%a"
    goto :found_ip
)
:found_ip
set "IP=%IP: =%"
echo       本机 IP = %IP%
echo.

echo [2/3] 添加 Windows 防火墙规则（需要管理员权限）...
netsh session iselevated >nul 2>&1
if errorlevel 1 (
    echo       当前窗口不是管理员，正在请求 UAC 提权...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
netsh advfirewall firewall add rule name="Python HTTP 8765 (iPhone PWA)" dir=in action=allow protocol=TCP localport=8765 enable=yes profile=any >nul
if errorlevel 1 (
    echo       [失败] 防火墙规则添加失败，请手动添加：
    echo         - 控制面板 ^> Windows Defender 防火墙 ^> 高级设置 ^> 入站规则 ^> 新建规则
    echo         - 端口 ^> TCP 8765 ^> 允许连接 ^> 勾选所有配置文件 ^> 命名为"Python HTTP 8765"
    pause
    exit /b 1
)
echo       [OK] 已放行 TCP 8765
echo.

echo [3/3] 启动 Python HTTP 服务器 (后台运行)...
start "" /b python -m http.server 8765 --bind 0.0.0.0 > "%~dp0server.log" 2>&1
timeout /t 2 /nobreak >nul
echo       [OK] 服务器已启动，日志在 server.log
echo.

echo ========================================================
echo   下一步（iPhone 上操作）：
echo ========================================================
echo   1. iPhone 连接和电脑同一个 Wi-Fi
echo   2. 打开 Safari，访问：
echo         http://%IP%:8765/index.html
echo   3. Safari 底部点「分享」图标（方框+向上箭头）
echo   4. 往下滑找到「添加到主屏幕」→ 点它 → 命名「全球要闻」→ 添加
echo   5. 回到主屏幕，点刚生成的图标就能全屏打开 App
echo ========================================================
echo.
echo   小贴士：服务器关了 App 会打不开（但界面已缓存部分样式）
echo   要永久部署，把 news_app 目录里的 4 个文件传到 GitHub Pages / Netlify
echo.
pause

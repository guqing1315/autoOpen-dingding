require "TSLib"
w, h = getScreenSize()

------需要根据个人信息修改
--钉钉bundleID
bundleID = "com.laiwang.DingTalk"
--钉钉账号
user = "XXXXXXX"
--钉钉密码
pwd = "XXXXX"

---------------------mysql数据库信息------------------
isMysql = true --是否使用数据库   flase--不使用数据库
--数据库名称
name = "XXXXXXX"
username = "XXX"
password = "XXXXXXXX"
IP = "XXXXXXXXxX"
port = "XXXxxXX"
----------------------------------------函数-------------------------------------------------------------------------
--唤醒屏幕调转到后台
function startON()
    startCurrent_text = os.date("%Y-%m-%d %X", getNetTime()) --格式化时间
    --如果要在设备自启动时解锁屏幕直接使用 unlockDevice 函数即可
    sysver = getOSVer()
    --获取系统版本
    local t = strSplit(sysver, ".")
    flag = deviceIsLock()
    if flag == 0 then
        toast("屏幕未锁定!", 5)
    elseif tonumber(t[1]) >= 10 then
        doublePressHomeKey()
        unlockDevice()
        --按一次 Home 键
        mSleep(20)
        pressHomeKey(0)
        pressHomeKey(1)
        toast("屏幕已解锁!", 5)
    else
        pressHomeKey(0)
        pressHomeKey(1)
        --解锁屏幕
        unlockDevice()
        toast("屏幕已解锁!", 5)
    end
end

--点击home键，然后回到首页，首页开始滑动往下找
function backHome()
    pressHomeKey(0)
    pressHomeKey(1)
end

--根据当前屏幕查找对应的钉钉图标
function queryDingding()
    x, y = findImage("钉钉图标.png", 0, 0, w - 1, h - 1) --找钉钉图标
    if x ~= -1 and y ~= -1 then --如果在指定区域找到某图片符合条件
        tap(x, y, 50) --点击打开钉钉
    else --如果找不到符合条件的图片
        toast("未找到应用!", 5)
    end
end

--根据Bundle ID 打开钉钉
function openDingding()
    flag = isFrontApp(bundleID)
    if flag == 0 then
        runApp(bundleID)
        toast("钉钉已打开!", 5)
    end
end

--根据Bundle ID 关闭钉钉
function closeDingding()
    flag = appIsRunning(bundleID)
    mSleep(5 * 1000)
    if flag == 1 then
        --使用此函数后在后台仍可看到应用程序图标属正常现象，实际进程已不在后台
        closeApp(bundleID)
        endCurrent_text = os.date("%Y-%m-%d %X", getNetTime()) --格式化时间
        toast("钉钉已关闭!", 5)
    end
end

--根据确认按钮来查看是否有弹窗提示，比如账号在其他设备登录、修改密码等提示
--这一块主要处理两个手机来回切换导致，手机进入登录界面前，有弹窗提示，先需要将弹窗去掉
function queryTancuan()
    x, y = findImage("弹窗确定标志.jpg", 0, 0, w - 1, h - 1) --找钉钉图标
    if x ~= -1 and y ~= -1 then --如果在指定区域找到某图片符合条件
        tap(x, y, 50) --点击确定按钮
    end
end

--输入账号和密码以及登录
function inputPwd()
    x, y = findImage("手机号标志.jpg", 0, 0, w - 1, h - 1) --找手机号输入框
    if x ~= -1 and y ~= -1 then --如果在指定区域找到某图片符合条件
        tap(x + 500, y + 20, 50)
        mSleep(1000)
        keyDown("Clear")
        --清空
        keyUp("Clear")
        mSleep(1000)
        inputStr(user)
        mSleep(1000)
        keyDown("Tab")
        --tab到密码输入框
        keyUp("Tab")
        mSleep(1000)
        keyDown("Clear")
        --清空
        keyUp("Clear")
        mSleep(1000)
        inputStr(pwd)
        mSleep(1000)
        x1, y1 = findImage("同意标志.jpg", 0, 0, w - 1, h - 1) --找已已阅读按钮
        if x1 ~= -1 and y1 ~= -1 then --如果在指定区域找到某图片符合条件  else --如果找不到符合条件的图片
            tap(x1, y1, 50)
            mSleep(1000)
            x2, y2 = findImage("登录标志.jpg", 0, 0, w - 1, h - 1) --找登录按钮
            if x2 ~= -1 and y2 ~= -1 then --如果在指定区域找到某图片符合条件  else --如果找不到符合条件的图片
                tap(x2, y2, 50)
            else --如果找不到符合条件的图片
                toast("未找到登录按钮!", 5)
            end
        else --如果找不到符合条件的图片
            toast("未找到勾选服务协议!", 5)
        end
    else --如果找不到符合条件的图片
        toast("跳过账号密码登录!", 5)
    end
end

function insertMysqlLog()
    if isMysql then
        local luasql = require "luasql.mysql"
        -- 创建环境对象
        mysql = luasql.mysql()
        -- 连接数据库
        conn, msg = mysql:connect(name,username,password,IP,port)
        if conn then
            -- 数据库操作语句
             startCurrent_text = [[']]..startCurrent_text.. [[']] 
             endCurrent_text =  [[']]..endCurrent_text.. [[']] 
            sqls = "insert into run_time_log(start_time,end_time,status) values("..startCurrent_text..","..endCurrent_text..",'1')"
            toast(sqls, 5)
            conn:execute(
                sqls
            )
            --关闭数据库
            conn:close()
            --断开 mysql 库
            mysql:close()
            toast("运行时间日志放入数据库!", 5)
        else
            toast("连接失败：" .. msg)
        end
    else
        toast("不使用数据库!")
    end
end
---------------------------------------函数调用---------------------------------------------------------------------------

startON()
mSleep(3000)
openDingding()
mSleep(5000)
queryTancuan()
mSleep(5000)
inputPwd()
mSleep(60 * 1000)
closeDingding()
insertMysqlLog()

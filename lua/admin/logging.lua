--[[
    BreathingSystem - Logging System
    ===============================
    
    This module handles debug logs and logging management.
    Provides comprehensive logging for debugging and monitoring.
    
    Responsibilities:
    - Handle debug logs and logging levels
    - Manage log files and rotation
    - Provide logging API functions
    - Monitor system performance
    
    Public API:
    - BreathingSystem.Logging.Log(level, message) - Log message
    - BreathingSystem.Logging.SetLevel(level) - Set logging level
    - BreathingSystem.Logging.GetLogs() - Get recent logs
    - BreathingSystem.Logging.ClearLogs() - Clear logs
]]

-- Initialize logging module
BreathingSystem.Logging = BreathingSystem.Logging or {}

-- Logging configuration
BreathingSystem.Logging.Config = {
    -- Log levels
    levels = {
        ERROR = 1,
        WARNING = 2,
        INFO = 3,
        DEBUG = 4,
        VERBOSE = 5
    },
    
    -- Current log level
    current_level = 3, -- INFO
    
    -- Log file settings
    log_file = "breathingsystem/logs/breathingsystem.log",
    max_log_size = 1024 * 1024, -- 1MB
    max_log_files = 10,
    
    -- Console output
    console_output = true,
    console_colors = {
        [1] = Color(255, 0, 0),    -- ERROR - Red
        [2] = Color(255, 255, 0),  -- WARNING - Yellow
        [3] = Color(0, 255, 0),    -- INFO - Green
        [4] = Color(0, 150, 255),  -- DEBUG - Blue
        [5] = Color(255, 255, 255) -- VERBOSE - White
    },
    
    -- Performance monitoring
    performance_monitoring = true,
    performance_threshold = 0.1 -- 100ms
}

-- Log storage
BreathingSystem.Logging.Logs = BreathingSystem.Logging.Logs or {}
BreathingSystem.Logging.Performance = BreathingSystem.Logging.Performance or {}

-- Log message
function BreathingSystem.Logging.Log(level, message, category)
    if not level or not message then return false end
    
    local levelNum = BreathingSystem.Logging.Config.levels[level] or 3
    if levelNum > BreathingSystem.Logging.Config.current_level then return false end
    
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = {
        timestamp = timestamp,
        level = level,
        levelNum = levelNum,
        message = message,
        category = category or "General",
        player = nil
    }
    
    -- Add to logs
    table.insert(BreathingSystem.Logging.Logs, logEntry)
    
    -- Keep only last 1000 logs
    if #BreathingSystem.Logging.Logs > 1000 then
        table.remove(BreathingSystem.Logging.Logs, 1)
    end
    
    -- Console output
    if BreathingSystem.Logging.Config.console_output then
        local color = BreathingSystem.Logging.Config.console_colors[levelNum] or Color(255, 255, 255)
        local prefix = "[" .. timestamp .. "] [" .. level .. "] [" .. (category or "General") .. "] "
        
        print(prefix .. message)
    end
    
    -- File output
    BreathingSystem.Logging.WriteToFile(logEntry)
    
    return true
end

-- Log with player context
function BreathingSystem.Logging.LogPlayer(level, message, ply, category)
    if not level or not message then return false end
    
    local logEntry = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        level = level,
        levelNum = BreathingSystem.Logging.Config.levels[level] or 3,
        message = message,
        category = category or "Player",
        player = IsValid(ply) and ply:Name() or "Unknown"
    }
    
    table.insert(BreathingSystem.Logging.Logs, logEntry)
    
    if #BreathingSystem.Logging.Logs > 1000 then
        table.remove(BreathingSystem.Logging.Logs, 1)
    end
    
    if BreathingSystem.Logging.Config.console_output then
        local color = BreathingSystem.Logging.Config.console_colors[logEntry.levelNum] or Color(255, 255, 255)
        local prefix = "[" .. logEntry.timestamp .. "] [" .. level .. "] [" .. (category or "Player") .. "] "
        
        print(prefix .. message .. " (Player: " .. logEntry.player .. ")")
    end
    
    BreathingSystem.Logging.WriteToFile(logEntry)
    
    return true
end

-- Set logging level
function BreathingSystem.Logging.SetLevel(level)
    if type(level) == "string" then
        level = BreathingSystem.Logging.Config.levels[level]
    end
    
    if level and level >= 1 and level <= 5 then
        BreathingSystem.Logging.Config.current_level = level
        BreathingSystem.Logging.Log("INFO", "Logging level set to " .. level, "Logging")
        return true
    end
    
    return false
end

-- Get current logging level
function BreathingSystem.Logging.GetLevel()
    return BreathingSystem.Logging.Config.current_level
end

-- Get recent logs
function BreathingSystem.Logging.GetLogs(count, level)
    count = count or 100
    level = level or nil
    
    local logs = {}
    local startIndex = math.max(1, #BreathingSystem.Logging.Logs - count + 1)
    
    for i = startIndex, #BreathingSystem.Logging.Logs do
        local log = BreathingSystem.Logging.Logs[i]
        if not level or log.level == level then
            table.insert(logs, log)
        end
    end
    
    return logs
end

-- Clear logs
function BreathingSystem.Logging.ClearLogs()
    BreathingSystem.Logging.Logs = {}
    BreathingSystem.Logging.Log("INFO", "Logs cleared", "Logging")
    return true
end

-- Write log to file
function BreathingSystem.Logging.WriteToFile(logEntry)
    if not logEntry then return false end
    
    local logLine = "[" .. logEntry.timestamp .. "] [" .. logEntry.level .. "] [" .. logEntry.category .. "] "
    if logEntry.player then
        logLine = logLine .. "[" .. logEntry.player .. "] "
    end
    logLine = logLine .. logEntry.message .. "\n"
    
    -- Check if log file exists and size
    if file.Exists(BreathingSystem.Logging.Config.log_file, "DATA") then
        local size = file.Size(BreathingSystem.Logging.Config.log_file, "DATA")
        if size > BreathingSystem.Logging.Config.max_log_size then
            BreathingSystem.Logging.RotateLogFile()
        end
    end
    
    -- Write to file
    file.Append(BreathingSystem.Logging.Config.log_file, logLine)
    
    return true
end

-- Rotate log file
function BreathingSystem.Logging.RotateLogFile()
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local rotatedFile = "breathingsystem/logs/breathingsystem_" .. timestamp .. ".log"
    
    -- Move current log to rotated file
    if file.Exists(BreathingSystem.Logging.Config.log_file, "DATA") then
        local content = file.Read(BreathingSystem.Logging.Config.log_file, "DATA")
        if content then
            file.Write(rotatedFile, content)
            file.Delete(BreathingSystem.Logging.Config.log_file)
        end
    end
    
    -- Clean up old log files
    BreathingSystem.Logging.CleanupLogFiles()
    
    BreathingSystem.Logging.Log("INFO", "Log file rotated to " .. rotatedFile, "Logging")
end

-- Clean up old log files
function BreathingSystem.Logging.CleanupLogFiles()
    local logDir = "breathingsystem/logs/"
    local files = file.Find(logDir .. "breathingsystem_*.log", "DATA")
    
    if files and #files > BreathingSystem.Logging.Config.max_log_files then
        table.sort(files, function(a, b)
            local timeA = file.Time(logDir .. a, "DATA")
            local timeB = file.Time(logDir .. b, "DATA")
            return timeA < timeB
        end)
        
        local toRemove = #files - BreathingSystem.Logging.Config.max_log_files
        for i = 1, toRemove do
            file.Delete(logDir .. files[i])
        end
        
        BreathingSystem.Logging.Log("INFO", "Cleaned up " .. toRemove .. " old log files", "Logging")
    end
end

-- Performance monitoring
function BreathingSystem.Logging.StartPerformanceTimer(name)
    if not BreathingSystem.Logging.Config.performance_monitoring then return nil end
    
    local timer = {
        name = name,
        startTime = SysTime()
    }
    
    return timer
end

function BreathingSystem.Logging.EndPerformanceTimer(timer)
    if not timer or not BreathingSystem.Logging.Config.performance_monitoring then return false end
    
    local duration = SysTime() - timer.startTime
    
    if duration > BreathingSystem.Logging.Config.performance_threshold then
        BreathingSystem.Logging.Log("WARNING", "Performance warning: " .. timer.name .. " took " .. string.format("%.3f", duration) .. "s", "Performance")
    end
    
    BreathingSystem.Logging.Performance[timer.name] = duration
    
    return duration
end

-- Get performance statistics
function BreathingSystem.Logging.GetPerformanceStats()
    return BreathingSystem.Logging.Performance
end

-- Log system events
function BreathingSystem.Logging.LogSystemEvent(event, data)
    local message = "System event: " .. event
    if data then
        message = message .. " - " .. util.TableToJSON(data)
    end
    
    BreathingSystem.Logging.Log("INFO", message, "System")
end

-- Initialize logging system
if SERVER then
    -- Create log directory
    if not file.Exists("breathingsystem/logs/", "DATA") then
        file.CreateDir("breathingsystem/logs/")
    end
    
    print("[BreathingSystem.Logging] Logging system loaded")
end

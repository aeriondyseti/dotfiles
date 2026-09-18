-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Discord: start at login, minimized to the taskbar (dimmed icon, pulses on new messages).
o.exec_on_start(os.getenv("HOME") .. "/.local/bin/discord-start-minimized")

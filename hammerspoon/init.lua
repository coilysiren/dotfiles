-- Wispr Flow: auto-press Return after dictation paste completes.
--
-- Strategy: watch for the release of Flow's hotkey. After release, poll the
-- pasteboard's changeCount for up to POLL_TIMEOUT seconds. When it ticks
-- (Flow finished pasting), send Return.
--
-- Default trigger: Fn (globe) key release. Change TRIGGER below if you use
-- a different Flow hotkey.

local POLL_INTERVAL = 0.05    -- 50ms
local POLL_TIMEOUT  = 3.0     -- give Flow up to 3s to paste
local TRIGGER       = "fn"    -- "fn" | "ctrl" | "alt" | "cmd" | "shift"
local VERIFY_DELAY  = 0.18    -- wait this long after Return before verifying
local MAX_RETRIES   = 2       -- retry Return up to this many times

-- Apps where we should NOT auto-fire Return (e.g. text editors, terminals
-- where Return inserts a newline rather than submitting). Add bundle IDs or
-- app names as desired.
local BLOCKLIST = {
  ["com.microsoft.VSCode"]      = true,
  ["com.apple.Terminal"]        = true,
  ["com.googlecode.iterm2"]     = true,
  ["com.github.wez.wezterm"]    = true,
  ["md.obsidian"]               = true,
  ["com.apple.TextEdit"]        = true,
}

local lastChange = hs.pasteboard.changeCount()
local pollTimer = nil
local triggerHeld = false

local function blocked()
  local app = hs.application.frontmostApplication()
  if not app then return false end
  return BLOCKLIST[app:bundleID() or ""] == true
end

local function verifyAndRetry(retriesLeft)
  if retriesLeft <= 0 or blocked() then return end
  -- Select-all in the focused field, then copy. If the pasteboard changeCount
  -- ticks, something was selected = input still has text = Return didn't
  -- submit. Deselect with Right arrow and fire Return again.
  hs.eventtap.keyStroke({"cmd"}, "a", 0)
  hs.timer.doAfter(0.05, function()
    local before = hs.pasteboard.changeCount()
    hs.eventtap.keyStroke({"cmd"}, "c", 0)
    hs.timer.doAfter(0.10, function()
      local after = hs.pasteboard.changeCount()
      if after ~= before then
        print("[flow-enter] input still non-empty, retrying Return (" .. retriesLeft .. " left)")
        hs.eventtap.keyStroke({}, "right", 0)
        hs.timer.doAfter(0.04, function()
          hs.eventtap.keyStroke({}, "return", 0)
          hs.timer.doAfter(VERIFY_DELAY, function() verifyAndRetry(retriesLeft - 1) end)
        end)
      else
        print("[flow-enter] input empty, Return succeeded")
      end
    end)
  end)
end

local function fireReturn()
  if blocked() then
    print("[flow-enter] blocked in " .. (hs.application.frontmostApplication():name()))
    return
  end
  hs.eventtap.keyStroke({}, "return", 0)
  print("[flow-enter] fired Return")
  hs.timer.doAfter(VERIFY_DELAY, function() verifyAndRetry(MAX_RETRIES) end)
end

local function startPoll()
  if pollTimer then pollTimer:stop() end
  local startedAt = hs.timer.secondsSinceEpoch()
  lastChange = hs.pasteboard.changeCount()

  pollTimer = hs.timer.doEvery(POLL_INTERVAL, function()
    local now = hs.pasteboard.changeCount()
    if now ~= lastChange then
      pollTimer:stop(); pollTimer = nil
      hs.timer.doAfter(0.08, fireReturn)  -- small grace for paste to land
    elseif (hs.timer.secondsSinceEpoch() - startedAt) > POLL_TIMEOUT then
      pollTimer:stop(); pollTimer = nil
      print("[flow-enter] timeout, no paste detected")
    end
  end)
end

local flagsTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
  local flags = e:getFlags()
  local nowHeld = flags[TRIGGER] == true
  if triggerHeld and not nowHeld then
    -- key just released
    print("[flow-enter] trigger released, polling clipboard")
    startPoll()
  end
  triggerHeld = nowHeld
  return false
end)

flagsTap:start()

hs.alert.show("Flow auto-Return loaded")

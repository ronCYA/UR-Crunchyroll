local kb = require("keyboard");
local win = require("win");
local utf8 = require("utf8");
local dev = require("device");
local server = require("server");
local last_switch = 0;
local logo = "logo0.png";
local inverted = false;
local inversion = "";
local rotation = 0;

function FindPlayerWindow(browserClass)
	--   1. Find all windows for the specified browser window class (i.e. all tabs)
	--   2. For each "tab" check if the title contains " - YouTube" (i.e. a youtube tab)
	local hwnds = win.findall(0, browserClass, nil, false);
	for i,hwnd in ipairs(hwnds) do
		local title = win.title(hwnd);
		print(title);
		if utf8.startswith(title, "Crunchyroll") then
			return hwnd;
		end
	end
	return 0;
end

function FindWindow()
	-- Check Chrome
	hwnd = FindPlayerWindow("Chrome_WidgetWin_1");
	if (hwnd ~= 0) then 
		return hwnd; 
	end
	-- Check IE
	hwnd = FindPlayerWindow("IEFrame");
	if (hwnd ~= 0) then 
		return hwnd; 
	end
	-- Check FF
	hwnd = FindPlayerWindow("MozillaWindowClass");
	if (hwnd ~= 0) then 
		return hwnd; 
	end
	return 0;
end

function ClickAndReturn (x, y)
	curx,cury = libs.mouse.position();
	libs.mouse.moveto(x, y);
	libs.mouse.click();
	libs.mouse.moveto(curx, cury);
end

actions.switch = function ()
	local now = libs.timer.time();
	if (now - last_switch < 1000) then
		return;
	else
		last_switch = now;
	end
	
	local hwnd = FindWindow();
	if (hwnd ~= 0) then
		win.switchto(hwnd);
		os.sleep(100);
		win.switchto(hwnd);
		x,y = win.findimage("logo.png", hwnd);
		if (x ~= -1 and y ~= -1) then 
			ClickAndReturn(x-100, y);
			return true;
		end
	end
	return false;
end

actions.click = function (icon)
	local hwnd = FindWindow();
	if (hwnd ~= 0) then
		win.switchto(hwnd);
		os.sleep(100);
		win.switchto(hwnd);
		x,y = win.findimage(icon, hwnd);
		if (x ~= -1 and y ~= -1) then
			ClickAndReturn(x, y);
			return true;
		end
	end
	return false;
end

function UpdateLogo()
	if (inverted == false) then
		inversion = "";
	else
		inversion = "_inverted";
	end
	logo = "logo" .. inversion .. rotation .. ".png";
    server.update({ id = "logo", image = logo });
    os.open("http://www.crunchyroll.com/home");
end

events.focus = function()
	dev.toast("Make sure the video is focused— clicking the timestamp works well.");
end

actions.easter = function()
	dev.toast("Enjoy the Easter roll ;)");
end

actions.logo_toggle = function(checked)
	if (inverted == false) then
		inverted = true;
	else
		inverted = false;
	end
	UpdateLogo();
end

actions.logo_rotate = function()
	if (rotation < 270) then
		rotation = rotation + 90;
	else
		rotation = 0;
	end
	UpdateLogo();
end

--@help Lower system volume
actions.volume_down = function()
	kb.press("volumedown");
end

--@help Raise system volume
actions.volume_up = function()
	kb.press("volumeup");
end

--@help Mute volume
actions.volume_mute = function()
	kb.press("m");
end

--@help Rewind playback
actions.rewind = function()
	kb.press("left");
end

--@help Fast forward playback
actions.forward = function()
	kb.press("right");
end

--@help Toggle playback state
actions.play_pause = function()
	kb.press("space");
end

--@help Go to beginning of video
actions.video_beginning = function()
	kb.press("leftbracket");
end

--@help Go to end of video
actions.video_end = function()
	kb.press("rightbracket");
end

--@help Exit full screen
actions.exit_fullscreen = function()
	kb.press("esc");
end

--@help Enter full screen
actions.enter_fullscreen = function()
	kb.press("f");
end

--@help Toggle video smoothing
actions.toggle_smoothing = function()
	kb.press("s");
end

--@help Toggle timestamp display format
actions.toggle_timestamp = function()
	kb.press("d");
end
if (not(isNil "admin_functions_defined")) exitWith {};

logAdmin = {
	private["_text"];
	_text = _this select 0;
	if (isNil "_text") exitWith {};
	if (typeName _text != "STRING") exitWith {};
	
	private["_player"];
	_player = player;
	
	_text = (format["ADMIN (%1, %2): ", (name _player), (getPlayerUID _player)] + _text + toString [13,10]);
	[_text] call logThis;
};

admin_actions_list = {
	([
		["------ Admin Commands ------", {}],
		["Create poll (use input field)", {
			private["_text"];
			_text = _this select 2;
			player groupChat format["Creating poll!"];
			[parseText(_text)] call admin_create_poll;
		}],
				
		["Camera (Toggle)", {
			[] call camera_toggle;
		}],
		["Carmagedon", {
			private["_text"];
			_text = _this select 2;
			_distance = [(_text)] call parse_number;
			
			if (_distance <= 0) exitWith {};
			
			player groupchat format["Starting Carmagedon at a range of %1 meters", _distance];
			
			{
				{		
					if ({alive _x} count crew _x == 0) then {
						deleteVehicle _x;
					};
				} foreach((getpos player) nearObjects [_x, _distance]);
			} forEach (droppableitems + ["LandVehicle", "Air", "Car", "Motorcycle", "Bicycle", "UAV", "Wreck", "Wreck_Base", 
						"HelicopterWreck", "UH1Wreck", "UH1_Base", "UH1H_base", "AH6_Base_EP1","CraterLong", "Ka60_Base_PMC", 
						"Ka137_Base_PMC", "A10"]);
		}],
		["Remove player weapons", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			[format["removed %1-%2 (%3)'s weapons", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			format['
				[] spawn {
					liafu = true;
					if (player != %1) exitWith {};
					[player] call player_reset_gear;
				};
			', _target] call broadcast;
		}],
		["Kill player", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
			[format["killed %1-%2 (%3)", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			format['
				[] spawn {
					liafu = true;
					if (player != %1) exitWith {};
					(player) setDamage 1; 
				};
			', _target] call broadcast;
		}],
		["Destroy player vehicle", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};
			
	
			[format["destroyed %1-%2 (%3)'s vehicle", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			format['
				[] spawn {
					liafu = true;
					if (player != %1) exitWith {};
					(vehicle player) setDamage 1; 
				};
			', _target] call broadcast;
		}],
		["Wipe player stats", {
			private["_player", "_target"];
			_player = _this select 0;
			_target = _this select 1;
			if (not([_target] call player_human)) exitWith {};

			[format["wiped %1-%2 (%3)'s stats", _target, (name _target), (getPlayerUID _target)]] call logAdmin;
			
			format['if (isServer) then {["%1"] call stats_server_wipe_player_data;};', _target] call broadcast;
			player groupChat format["Request to wipe %1's stats sent", (name _target)];
		}],
		["Reset time(40m dy, 20m nt)", {
			player groupChat "Time reset (40-min day, 20-min night), please wait for synchronization to complete";
			[40,20] call time_reset;
		}],
		["MOTD (use input field)", {
			custom_motd = _inputText;
			publicVariable "custom_motd";
		}],
		["Delete Target (Man)", {
			private["_target"];
			_target = cursorTarget;
			if (not(isNil "_target")) then {
				if (typeName _target == "OBJECT") then {
					if (_target isKindOf "Man" && not([_target] call object_shop)) then {
						[_target] call C_delete;
					};
				};
			};
		}],
		["------ White / Black Lists ------", {}],
		["COP - 1 List", {
			["COP_1"] spawn A_WBL_F_DIALOG_INIT;
		}],
		["BLANK", {}]
	])
};

admin_activate_command = { _this spawn {
	private["_player", "_command", "_text", "_target"];
	
	_player = _this select 0;
	_command = _this select 1;
	_text = _this select 2;
	_target = _this select 3;
	
	if (not([_player] call player_human)) exitWith {};
	
	if (isNil "_command") exitWith {};
	if (typeName _command != "STRING") exitWith {};
	
	_text = if (isNil "_text") then {""} else {_text};
	_text = if (typeName _text != "STRING") then {""} else {_text};
	
	private["_code"];
	_code = compile ( "_this call " + _command);
	[_player, _target, _text] spawn _code;
	sleep 1;
	hint "Code Activated";
};};

admin_functions_defined = true;
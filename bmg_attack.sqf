//[[dirRangeA, dirRangeB], [minDist, maxDist], frequency, size, [units], side, pos]

/*** This script spawns a procedural attack from a given direction and distance ***/

//variable declaration
_dirRangeA = (_this select 0) select 0; //starting angle
_dirRangeB = (_this select 0) select 1; //ending angle

_minDist = (_this select 1) select 0; //minimum distance
_maxDist = (_this select 1) select 1; //maximum distance

_frequency = _this select 2; //how often groups spawn
_size = _this select 3; //total size of the group

_units = _this select 4; //array of units to be used
_side = _this select 5; //the side of the units

_pos = _this select 6; // position of the defenders

_unitsSpawned = 0; //total units already spawned
_currentUnits = 0; //total units spawned that are alive

//begin spawning algorithm
while {_unitsSpawned < _size} do
{
	//limit amount of the attackers that can be present at a given time
	if (_currentUnits < (2 * sqrt(_size))) then
	{
		//create the group
		_grp = createGroup _side;
		
		//create polar coordinates for the group
		_dir = random(_dirRangeA - _dirRangeB) + _dirRangeB;
		_dist = random(_maxDist - _minDist) + _minDist;
		
		//spawn units into the group
		for "_i" from 1 to ([3,4,5] call BIS_fnc_selectRandom) do
		{
			_unit = _grp createUnit [(_units call BIS_fnc_selectRandom), [((_pos select 0) + (_dist * cos(_dir))), ((_pos select 1) + (_dist * sin(_dir))), 0], [], 0, "FORM"];
		};
		
		//add way point for the group to attack
		_wp = _grp addWaypoint[[((_pos select 0) + random 30), ((_pos select 1) + random 30), _pos select 2], 0];
		
		//add group to the global array
		bmg_global_attackGroups pushBack _grp;
		
		//update the units spawned
		_unitsSpawned = _unitsSpawned + count(units _grp);
		
		//wait the required frequency with some randomness factored in
		sleep ((_frequency + ((10/100) * _frequency)) - floor(random((20/100) * _frequency)));
	};
	
	//update the current units
	_currentUnits = 0;
	for "_i" from 0 to ((count bmg_global_attackGroups) - 1) do
	{
		_currentUnits = _currentUnits + ({alive _x} count( units (bmg_global_attackGroups select _i)));
	};
	
	sleep 2;
}; //end spawning algorithm
Class ModBridge extends XComMod
 config(ModBridge);

/** 
Struct TMBMods
{
	var array<ModBridge> arrMBMods;
	var array<XComMod> arrXCMods;
	var array<string> ModNames;
};
  */

var string valStrValue0;
var string valStrValue1;
var string valStrValue2;
var int valIntValue0;
var int valIntValue1;
var int valIntValue2;
var array<string> valArrStr;
var array<int> valArrInt;
var TTableMenu valTMenu;
var string functionName;
var string functParas;
var string ModInitError;
var bool bModReturn;
var array<XComMod> MBMods;
var config bool verboseLog;
var config array<string> ModList;

simulated function StartMatch()
{
	local XComMod Mod;
	local string ModName;
	local int i;
	local bool bFound;

	functionName = "ModInit";

	AssignMods();

	`Log("Start ModInit", verboseLog, 'ModBridge');


	foreach MBMods(Mod, i)
	{
		ModInitError = "";
		bFound = false;
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log(ModName @ "ModInit attempt", verboseLog, 'ModBridge');

		MBMods[i].StartMatch();
		bFound = true;
			
		`Log(ModName $ ", ModInitError=" @ Chr(34) $ ModInitError $ Chr(34), (bFound && (ModInitError != "")), 'ModBridge');
		`Log(ModName @ "ModInit Successful", (bFound && (ModInitError == "")), 'ModBridge');
	}

	foreach XComGameInfo(Outer).ModNames(ModName, i)
	{
		foreach MBMods(Mod)
		{
			bFound = false;
			if(ModName == (string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class)))
			{
				bFound = true;
				`Log("XComMod|" $ ModName @ "Found as:" @ "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class) $ ", skipping ModInit", true, 'ModBridge');
				break;
			}
		}

		if((XComGameInfo(Outer).Mods[i] != self) && (!bFound))
		{
			`Log("XComMod|" $ ModName @ "ModInit attempt", verboseLog, 'ModBridge');

			ModInitError = "";
			XComGameInfo(Outer).Mods[i].StartMatch();

			`Log("XComMod|" $ ModName $ ", ModInitError=" @ Chr(34) $ ModInitError $ Chr(34), (ModInitError != ""), 'ModBridge');
			`Log("XComMod|" $ ModName @ "ModInit Successful", (verboseLog && (ModInitError == "")), 'ModBridge');

		}
	}

	`Log("Overwrite Checkpoint classes", verboseLog, 'ModBridge');

	XComGameInfo(Outer).TacticalSaveGameClass = class'Mod_Checkpoint_TacticalGame';
	XComGameInfo(Outer).TransportSaveGameClass = class'Mod_Checkpoint_StrategyTransport';

	if(XComHeadquartersGame(XComGameInfo(Outer)) != none)
	{
		`Log("StrategyGame Detected, Checkpoint class overwrite", verboseLog, 'ModBridge');

		XComGameInfo(Outer).StrategySaveGameClass = class'Mod_Checkpoint_StrategyGame';
	}

	`Log("End of StartMatch", verboseLog, 'ModBridge');

	functionName = "";
}

function ModError(string Error)
{
	`Log("Mod Class" @ Chr(34) $ string(default.class) $ Chr(34) @ "Error=" @ Error, true, 'ModBridge');
}

function bool ModRecordActor(string Checkpoint, class<Actor> ActorClasstoRecord)
{

	local int I;
	local bool bFound;

	/** 
	if(Checkpoint ~= "Tactical")
	{
		`Log("Adding Actor Class" @ Chr(34) $ string(ActorClasstoRecord) $ Chr(34) @ "to TacticalGame Checkpoint", verboseLog, 'ModBridge');

		for(I=0, I<class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length; I++)
		{
			if(class'Mod_Checkpoints_TacticalGame'.default.ActorClassesToRecord[I] == ActorClasstoRecord)
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
			class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);

		if(bFound || class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord[class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}

	if(Checkpoint ~= "Transport")
	{
		`Log("Adding Actor Class" @ Chr(34) $ string(ActorClasstoRecord) $ Chr(34) @ "to StrategyTransport Checkpoint", verboseLog, 'ModBridge');

		for(I=0, I<class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length; I++)
		{
			if(class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord[I] == ActorClasstoRecord)
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
			class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);
			                                                                                                
		if(bFound || class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord[class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}
	if(Checkpoint ~= "Strategy")
	{
		`Log("Adding Actor Class" @ Chr(34) $ string(ActorClasstoRecord) $ Chr(34) @ "to StrategyGame Checkpoint", verboseLog 'ModBridge');

		for(I=0, I<class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length; I++)
		{
			if(class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord[I] == ActorClasstoRecord)
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
			class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);

		if(bFound || class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord[class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}*/

	return false;
}

function AssignMods()
{
	local XComMod Mod;
	local string ModName;
	local int i;
	local bool bFound;

	`Log("Started AssignMods", verboseLog, 'ModBridge');

	foreach ModList(ModName, i)
	{
		Mod = new (self) class<XComMod>(DynamicLoadObject(ModName, class'Class'));
		`Log( "adding" @ Chr(34) $ ModName $ Chr(34) @ "to modlist", verboseLog, 'ModBridge');
		MBMods[i] = Mod;
	}

	for(i=0; i<XComGameInfo(outer).ModNames.Length; i++)
	{
		ModName = XComGameInfo(outer).ModNames[i];
		bFound = false;
		foreach XComGameInfo(outer).Mods(Mod)
		{
			if(ModName == (string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class)))
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
		{
			`Log("removing" @ Chr(34) $ ModName $ Chr(34) @ "from XComGameInfo.ModNames", verboseLog, 'ModBridge');
			XComGameInfo(outer).ModNames.Remove(i, 1);
			-- i;
		}

	}

	`Log("End of AssignMods", verboseLog, 'ModBridge');

}

function ModsStartMatch()
{

	local XComMod Mod;
	local string ModName;
	local int i;

	
	bModReturn = false;
	foreach MBMods(Mod, i)
	{
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log("Executing StartMatch function in" @ Chr(34) $ ModName $ Chr(34), verboseLog, 'ModBridge');
		MBMods[i].StartMatch();
		if(bModReturn)
		{
			`Log("AllMods loop stopped due to bModReturn being set by:" @ Chr(34) $ ModName $ Chr(34), verboseLog, 'ModBridge');
			break;
		}
	}

	for(i=1; i<XComGameInfo(outer).Mods.Length; I++)
	{
		`Log("Executing StartMatch function in" @ Chr(34) $ "XComMod|" $ XComGameInfo(outer).ModNames[i] $ Chr(34), verboseLog, 'ModBridge');
		XComGameInfo(outer).Mods[i].StartMatch();
		if(bModReturn)
		{
			`Log("AllMods loop stopped due to bModReturn being set by:" @ Chr(34) $ "XComMod|" $ XComGameInfo(outer).ModNames[i] $ Chr(34), verboseLog, 'ModBridge');
			break;
		}
	}

}

function string StrValue0(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("return StrValue0=" @ Chr(34) $ valStrValue0 $ Chr(34), verboseLog, 'ModBridge');

		return valStrValue0;
	}
	else
	{

		`Log("store StrValue0=" @ Chr(34) $ str $ Chr(34) $ ", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valStrValue0 = str;
		return "";
	}
}

function string StrValue1(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("return StrValue1=" @ Chr(34) $ valStrValue1 $ Chr(34), verboseLog, 'ModBridge');

		return valStrValue1;
	}
	else
	{
		`Log("store StrValue1=" @ Chr(34) $ str $ Chr(34) $ ", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valStrValue1 = str;
		return "";
	}
}

function string StrValue2(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("return StrValue2=" @ Chr(34) $ valStrValue2 $ Chr(34), verboseLog, 'ModBridge');

		return valStrValue2;
	}
	else
	{
		`Log("store StrValue2=" @ Chr(34) $ str $ Chr(34) $ ", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valStrValue2 = str;
		return "";
	}
}

function int IntValue0(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("return IntValue0=" @ Chr(34) $ string(valIntValue0) $ Chr(34), verboseLog, 'ModBridge');

		return valIntValue0;
	}
	else
	{
		`Log("store IntValue0=" @ Chr(34) $ string(I) $ Chr(34) $ ", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valIntValue0 = I;
		return 0;
	}
}

function int IntValue1(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("return IntValue1=" @ Chr(34) $ string(valIntValue1) $ Chr(34), verboseLog, 'ModBridge');
		return valIntValue1;
	}
	else
	{
		`Log("store IntValue1=" @ Chr(34) $ string(I) $ Chr(34) $ ", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valIntValue1 = I;
		return 0;
	}
}

function int IntValue2(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("return IntValue2=" @ Chr(34) $ string(valIntValue2) $ Chr(34), verboseLog, 'ModBridge');

		return valIntValue2;
	}
	else
	{
		`Log("store IntValue2=" @ Chr(34) $ string(I) $ Chr(34) $ ", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valIntValue2 = I;
		return 0;
	}
}

function array<string> arrStrings(optional array<string> arrStr, optional bool bForce)
{

	local string sArray;

	if(arrStr.Length == 0 && !bForce)
	{
		JoinArray(valArrStr, sArray);
		`Log("return arrStrings=" @ Chr(34) $ sArray $ Chr(34), verboseLog, 'ModBridge');

		return valArrStr;
	}
	else
	{
		JoinArray(arrStr, sArray);
		`Log("store arrStrings=" @ Chr(34) $ sArray $ Chr(34) $ ", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valArrStr = arrStr;
		arrStr.Length = 0;
		return arrStr;
	}

}

function array<int> arrInts(optional array<int> arrInt, optional bool bForce)
{

	local int I;
	local string sArray;

	if(arrInt.Length == 0 && !bForce)
	{
		if(verboseLog)
		{
			for(I=0; I < valArrInt.Length; I++)
			{
				if(sArray != "")
				{
					sArray $= ", ";
				}
				sArray $= string(valArrInt[I]);
			}
			`Log("return arrInts=" @ Chr(34) $ sArray $ Chr(34), true, 'ModBridge');
		}
		return valArrInt;
	}
	else
	{
		if(verboseLog)
		{
			for(I=0; I < arrInt.Length; I++)
			{
				if(sArray != "")
				{
					sArray $= ", ";
				}
				sArray $= string(arrInt[I]);
			}
			`Log("store arrInts=" @ Chr(34) $ sArray $ Chr(34) $ ", bForce=" @ string(bForce), true, 'ModBridge');
		}
		valArrInt = arrInt;
		arrInt.Length = 0;
		return arrInt;
	}
}

//Force it to be blank by not specifying first parameter: ModBridge.TMenu(, true); /* 1B <TMenu> 0B 27 16 */
function TTableMenu TMenu(optional TTableMenu menu, optional bool bForce)
{
	local TTableMenu lMenu;

	if(menu == lMenu && !bForce)
	{
		`Log("return TMenu", verboseLog, 'ModBridge');
		return valTMenu;
	}
	else
	{
		`Log("store TMenu", verboseLog, 'ModBridge');
		valTMenu = menu;
		return lMenu;
	}
}


function XComMod Mods(string ModName, optional string funtName, optional string paras)
{

	local int i;
	local string mod;
	local XComMod XMod;
	local bool bFound;


	`Log("funtName=" @ Chr(34) $ funtName $ Chr(34) $ ", paras=" @ Chr(34) $ paras $ Chr(34), verboseLog, 'ModBridge');


	if(ModName == "")
	{
		`Log("Error, ModName not specified", true, 'ModBridge');
		return returnvalue;
	}

	if(verboseLog && (int(ModName) > 0))
	{
		if(int(ModName) > MBMods.Length)
		{
			mod = "XComMod|" $ XComGameInfo(Outer).ModNames[int(ModName)-MBMods.Length];
		}
		else
		{
			mod = "ModBridge|" $ string(MBMods[int(ModName)].Class.GetPackageName()) $ "." $ string(MBMods[int(ModName)].Class);
		}
		`Log("Mod number" @ ModName @ "is" @ Chr(34) $ mod $ Chr(34), true, 'ModBridge');
	}
	else
	{
		if(ModName == "AllMods")
		{
			bFound = true;
		}
		else
		{
			foreach MBMods(XMod)
			{
				if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
				{
					bFound = true;
					break;
				}
			}
		}

		if(!bFound)
		{
			if(XComGameInfo(outer).ModNames.Find(ModName) != -1)
			{
				bFound = true;
			}
		}

		if(!bFound)
		{
			`Log("Error, ModName" @ Chr(34) $ ModName $ Chr(34) @ "not found", true, 'ModBridge');
			return returnvalue;
		}

		if(verboseLog && (ModName != "AllMods"))
		{
			bFound = false;
			foreach MBMods(XMod, i)
			{
				if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
				{
					bFound = true;
					break;
				}
			}
			if(!bFound)
			{
				i = XComGameInfo(outer).ModNames.Find(ModName) + MBMods.Length;
			}

			`Log("Mod" @ Chr(34) $ ModName $ Chr(34) @ "is mod number" @ string(i), true, 'ModBridge');
		}

		if(!(funtName == " " || funtName == ""))
		{
			functionName = funtName;
			functParas = paras;
			if(ModName == "AllMods")
			{
				`Log("Looping over all Mods", verboseLog, 'ModBridge');
				ModsStartMatch();
			}
			else
			{
				bFound = false;
				foreach MBMods(XMod, i)
				{
					if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
					{
						mod = "ModBridge|" $ string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class);
						`Log("Executing" @ Chr(34) $ mod $ Chr(34) $ ".StartMatch()", verboseLog, 'ModBridge');
						MBMods[i].StartMatch();
						bFound = true;
						break;
					}
				}
				if(!bFound)
				{
					if(XComGameInfo(outer).ModNames.Find(ModName) != -1)
					{
						`Log("Executing" @ Chr(34) $ "XComGameInfo|" $ ModName $ Chr(34) $ ".StartMatch()", verboseLog, 'ModBridge');
						XComGameInfo(outer).Mods[XComGameInfo(outer).ModNames.Find(ModName)].StartMatch();
					}
				}
			}
			return none;
		}
		else
		{
			foreach MBMods(XMod, i)
			{
				if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
				{
					mod = "ModBridge|" $ string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class);
					`Log("Return Mod," @ Chr(34) $ mod $ Chr(34), verboseLog, 'ModBridge');

					return MBMods[i];
				}
			}

			foreach XComGameInfo(outer).ModNames(mod, i)
			{
				if(ModName == mod)
				{
					`Log("Return Mod," @ Chr(34) $ "XComGameInfo|" $ mod $ Chr(34), verboseLog, 'ModBridge');

					return XComGameInfo(outer).Mods[i];
				}
			}
		}
	}
	`Log("Error: end of ModBridge.Mods function, this shouldn't appear, please contact ModBridge maintainer", true, 'ModBridge');
}
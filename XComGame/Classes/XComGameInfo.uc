class XComGameInfo extends FrameworkGame;

var Class TacticalSaveGameClass;
var Class StrategySaveGameClass;
var Class TransportSaveGameClass;
var config array<config string> ModNames;
var array<XComMod> Mods;

simulated function ModStartMatch() {}
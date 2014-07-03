////////////////////////////////////////////////////
// INSTRUCTIONS FOR STARTING SOUNDBEAM from SC

// SYSTEM PREP
// 1.) start node.js from osc-web folder in terminal window1 $node bridge.js
// 2.) start the addon-sdk activation from within addon-sdk folder: $source bin/activate
// (Does this needs doing every time or just once for the first time?)
// 3.) change to lightbeam directory, then start firefox with: $cfx run
// 4.) Do "Start Lightbeam" from "Extras" Menu in Firefox. Otherwise no OSC msgs get sent

// in SUPERCOLLIDER
// 5.) start this code:
// Make sure SC is on port no. 57120 $NetAddr.langPort // to check

////////////////////////////////////////////////////

(

//sbeam = SoundBeam.new("les"); // make a new object to use broadcast messaging

// EXCHANGE WITH YOUR OWN pathToOSCGroupClient, Les/Servers IP, YourNickName, SomePassword
b = SoundBeam.newOSCGroups("/home/celesteh/Documents/code/osc/oscgroups/bin/OscGroupClient", "192.168.0.9", "les", "foo");

// set an action function for third party sites (ones you haven't clicked on
// the message gets a SoundBeamSite as the argument
b.thirdPartyAction = {|site, time|

	site.toString.postln;

	((site.accessCount  % 10) == 0).if({
		("%: %\n").postf(site.accessCount, site.toString);
	});
};

// you can also set:
b.hitAction = { |site, time| site.postln}; // for a site you have clicked on but has served no extra content
b.bothAction = {|site, time| site.postln}; // for a site you've clieck and has served extra content such as images

// for the social aspect of the piece:
b.socialEventAction = {|site, time| site.postln}; // another BiLE member has hit a third party site you have also encountered

/* SoundBeam Data contains
// exampleData (do site.toString.postln): "google.com 10 18 64 36 google both"
Accessing the Data directly:
site.network; // returns one of those symbols: \google, \facebook, \microsoft, \twitter, \cloud or nil
site.site; // gives URL
// The following return just numerical values, no limit, incrementing
site.accessCount;
site.cookieCount;
site.clickedIntentionallyCount;
*/

);


//////////////////////////////////////////

// Examples for Sonification

// 0) Don't Forget to load in some sounds!

"SoundBeamSounds.scd".loadRelative;

// 1) simple access count to pitch correlation, upon third party hits, using SC default synth sound
b.thirdPartyAction = { |site| \thirdParty.postln; (midinote: site.accessCount % 60 + 30).play; };

// or
b.thirdPartyAction = { |site| \thirdParty.postln; (instrument: \soundbeam3, midinote: site.accessCount % 60 + 30).play; };

// 2)
(
b.bothAction = { |site| var data;
	\bothAction.postln; // track which ActionFunc is called
	data = [site.site, site.accessCount, site.cookieCount, site.clickedIntentionallyCount];
	(midinote: data[1].linlin(1,600,30,110), \instrument: \soundbeam1).play;
	data.postln; // see whats inside
	if (data[0].asString.contains(".de"))
	{\German.postln; (midinote: 70, instrument: \soundbeam2, \amp: 0.5).play};
};
);

// 3)
b.socialEventAction = {|site, time| (instrument: \soundbeam5, freq: 400*time).play};

/////////////////////////////////
// Debugging
/*
NetAddr.langPort

OSCFunc.trace(true)
OSCFunc.trace(false)

*/

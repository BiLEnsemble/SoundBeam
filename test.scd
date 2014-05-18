////////////////////////////////////////////////////
// INSTRUCTIONS FOR STARTING SOUNDBEAM from SC

// SYSTEM PREP
// 1.) start node.js from osc-web folder in terminal window1 $node bridge.js
// 2.) start the addon-sdk activation from within addon-sdk folder: $source bin/activate
// (Does this needs doing every time or just once for the first time?)
// 3.) change to lightbeam directory, then start firefox with: $cfx run

// SUPERCOLLIDER
// 4.) start this code:
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

)

// Examples for Sonification
// 1) simple access count to pitch correlation, upon third party hits
b.thirdPartyAction = { |site| \thirdParty.postln; (midinote: site.accessCount % 60 + 30).play; };

// 2) 
(
b.bothAction = { |site| var data;
	\bothAction.postln; // track which ActionFunc is called
	data = [site.site, site.accessCount, site.cookieCount, site.clickedIntentionallyCount];
	(midinote: data[1].linlin(1,600,30,110), \instrument, \soundbeam1).play;
	data.postln; // see whats inside
	if(data[0].asString.contains(".de"), {\German.postln; (midinote: 70, instrument: \soundbeam2, \amp: 0.5).play});
};

// needs soundbeam1 and soundbeam2 instruments:

SynthDef(\soundbeam1, {arg out, amp=0.1, pan=0, freq=200,atk=0.1, sustain=1, noise=1, bw=0.2;
	var son, env;
	env=EnvGen.kr(Env.linen(atk, sustain), doneAction:2);
	son=BBandPass.ar(WhiteNoise.ar(noise), freq, bw).softclip;
	son=son*env;
	Out.ar(out, Pan2.ar(son, pan, amp));
}).add;


SynthDef(\soundbeam2, { |out=0,amp=0.1,sustain=1.0,freq=440,coef=0.5|
    var snd, env;
    snd = Pluck.ar(WhiteNoise.ar(1!2),
        Impulse.ar(0),
        freq.reciprocal,
        freq.reciprocal,
        sustain, coef: 0.5);
    env = EnvGen.ar(Env.perc(0.01,sustain), doneAction:2);
    OffsetOut.ar(out, snd * amp);
}).add;
)




/*
NetAddr.langPort


OSCFunc.trace




(
var sites;

sites = IdentityDictionary.new;
OSCFunc({|msg, time, addr, recvPort|

	var site, last;
	site = msg[1].asSymbol;

	last = sites.at(site);

	last.isNil.if({
		last = 0;
	}, {

			last = last[5];
	});

	last = last+1;

	msg = msg ++ last;

	((last % 10) == 0).if ({
		last.post;
		"\t".post;
		msg.postln;
	});

	sites.put(site, msg);


}, '/site/thirdparty');

)




*/




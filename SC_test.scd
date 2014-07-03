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

Server.killAll;

s.options.memSize = 1024 * 128; // Leave Mem for Delays etc
s.reboot;
//////////////
(
q = ();
// b = SoundBeam.newOSCGroups("/home/celesteh/Documents/code/osc/oscgroups/bin/OscGroupClient", "192.168.0.9", "les", "foo");
q.pathToOscGroupClient = "/Users/monodread/Documents/OscGroup/OscGroupClient";
q.oscIP = "192.168.0.3"; // Servers (Les) IP Address
q.myNick = "jonas";
//sbeam = SoundBeam.new("les"); // make a new object to use broadcast messaging

b = b ?? SoundBeam.newOSCGroups(q.pathToOscGroupClient, q.oscIP, q.myNick, "foo");

// set an action function for third party sites (ones you haven't clicked on
// the message gets a SoundBeamSite as the argument
b.thirdPartyAction = {|site|
	\thirdParty.postln;
	((site.accessCount  % 10) == 0).if({
		("%: %\n").postf(site.accessCount, site.toString);
	});
};


// you can also set:
b.hitAction = { |site| \hittt.postln;}; // for a site you have clicked on but has served no extra content

b.bothAction = {|site| \bothAction.postln; site.toString.postln; };
// for a site you've clieck and has served extra content such as images
/* SoundBeam contains
// exampleData (do site.toString.postln): "google.com 10 18 64 36 google both"
Accessing the Data directly:
site.network; // returns one of those symbols: \google, \facebook, \microsoft, \twitter, \cloud or nil
site.site; // gives URL
// The following return just numerical values, no limit, incrementing
site.accessCount;
site.cookieCount;
site.clickedIntentionallyCount;
*/

// for the social aspect of the piece:
b.socialEventAction = {|site| \socialEvent.postln}; // another BiLE member has hit a third party site you have also encountered

)

(
// fill in your personal func calls
b.thirdPartyAction = { |site|
	var level =site.accessCount*0.01;
	\thirdParty.postln;
	level.postln;
	(instrument: \soundin, \level: level, \sustain:0.01, \amp: 0.5).play
//	(instrument: \soundbeam3, midinote: site.accessCount % 60 + 30).play;
};
//b.bothAction = { |site| \bothAction.postln; (midinote: site.accessCount % 60 + 30).play; };


b.bothAction = { |site| var data;
	\bothAction.postln; // track which ActionFunc is called
	data = [site.site, site.accessCount, site.cookieCount, site.clickedIntentionallyCount];
	(midinote: data[1].linlin(1,600,30,110), instrument: \soundbeam1, \noise: (data[2]%300).linlin(0,300,0.001,10), \bw: 0.05, \amp: 0.3).play;
	data.postln;
	if(data[0].asString.contains(".de"), {\German.postln; (midinote: 70, instrument: \soundbeam2, \amp: 1).play});
};

b.socialEventAction = {|site| var freq; "socialEvent: %\n".postf(site.site); freq = site.site.ascii.mean.postln; (instrument: \guitar4, \freq: freq, \delay: site.cookieCount, \amp: 0.5).play};
)




"com".matchRegexp("vimeo.com"); // true
".de".matchRegexp("video.com"); // true

q.siteEndings = ["com", "de", "pw", "co.uk", "eu", "org", "tk"];
q.siteLib = {|q, url|  if(url.asString.contains(".de"), {\German.postln; url.ascii;}, {\unknown.postln}); };
q.siteLib("cime.de");



(
SynthDef(\soundbeam1, {arg out, amp=0.1, pan=0, freq=200,atk=0.1, sustain=1, noise=1, bw=0.2;
	var son, env;
	env=EnvGen.kr(Env.linen(atk, sustain), doneAction:2);
	son=BBandPass.ar(WhiteNoise.ar(noise), freq, bw).softclip;
	son=son*env;
	Out.ar(out, Pan2.ar(son, pan, amp));
}).add;


SynthDef(\soundbeam2, { |out=0,amp=0.5,sustain=0.1,freq=440,coef=0.5|
    var snd, env;
    snd = Pluck.ar(WhiteNoise.ar(1!2),
        Impulse.ar(0),
        freq.reciprocal,
        freq.reciprocal,
        sustain, coef: 0.5);
    env = EnvGen.ar(Env.perc(0.01,sustain), doneAction:2);
    OffsetOut.ar(out, snd * amp);
}).add;

SynthDef(\soundbeam3, {arg out, gate=1, amp=0.5, pan=0, freq=200, atk=0.1, sustain=1, rate=1;
	var son, env, trig;
	trig = Impulse.kr(rate);
	env=EnvGen.kr(Env.new([0,1,1,0], [atk,sustain,atk]), gate, doneAction:2);
	son=SinOsc.ar(freq).softclip;
	Out.ar(out, Pan2.ar(son*env, pan, amp));
}).add;


(
 SynthDef(\guitar4, { |out=0, freq=164, ffreq=12000, rq=0.6, atk=0.1, mod=1, amp=0.5, gate=1, sustain=2, pan=0, dry=0.1, delay=1|
	var src, env, verb;
	env = EnvGen.kr(Env.perc(sustain*atk, sustain*0.9, amp), gate, doneAction:2);

	src = Mix.arFill(1, { arg i;

		var trigger1, pluck1, period, string1, string2;
		period = freq.reciprocal;
		trigger1 = Impulse.kr(delay);
		pluck1 = PinkNoise.ar(Decay.kr(trigger1, 0.05));
		string1 = CombL.ar(pluck1, period, period, 4);
		string2 = CombL.ar(pluck1, period/2, period/2, 4);

		string1+string2;
		});

	src = BLowPass.ar(src, ffreq*LFDNoise1.kr(mod,0.2,1),rq);
	src = LeakDC.ar(src);
	verb = GVerb.ar(src, revtime:3*sustain, damping:0.2, drylevel:dry, taillevel:0.5);
	Out.ar(out, Splay.ar((src+verb)*env, 0,1,pan));
}).add;
);

// Synth(\guitar4, [\delay, 1, \freq, 190, \ffreq, 4000, \atk, 0.01]);


(
SynthDef(\blip , { arg out;
	var rate=\rate.kr(0.5).linexp(0,1,0.01,20);
	var freq=\freq.kr(0.5).linexp(0,1,30,4000).cpsmidi.round(1).midicps;
	var freqmod=\freqmod.kr(0.5).linlin(0,1, freq/10,freq).cpsmidi.round(1).midicps;
	var harm=\harm.kr(0.5).linlin(0,1,1,15).round(1);
	var dist=\dist.kr(0.5).linexp(0,1,0.5,25);
	var sus=\sus.kr(0.5).linexp(0,1,0.01,20);
	var lag=\lag.kr(0.0).linlin(0,1,0,0.2);
	var amp=\amp.kr(0.0);
	var trig=Impulse.kr([3, 4])*rate;
	var pan = \pan.kr(-1);
	var env=EnvGen.kr(Env.new([0,1,0],[0.01,LFNoise0.kr(rate,0.5,1)*sus/(4*rate)]), trig);
	var notes=LFNoise0.kr([3, 4] * rate, freqmod, freq).lag(lag);
//	var notes=Duty.kr(~knob_3, Impulse.kr(rate*4), freq+Dseq([0,1,4,6,9].midicps, inf));
	Out.ar(out, Splay.ar(Blip.ar(notes, harm, 0.01+dist).softclip * env, 0,amp,pan))
}).add;
);


(
SynthDef(\soundin, { arg out, inChan=0, level=0.5, amp=0.1, pan=0, sustain=0.1;
	var son, env;
	env = EnvGen.kr(Env.linen(0.01,sustain),doneAction:2);
	son = Limiter.ar(SoundIn.ar(inChan, level));
	Out.ar(out, Pan2.ar(son * env, pan, amp))
}).add;
)
// Synth(\soundin)

);

////////////////////////////////////////////////////////


// ADD ON
// Using OSCGroups without Les...

// default usage from the SC Quark is:
// OscGroupClient("realizedsound.mooo.com", "josh", "joshword", "test", "testword")

// the setup in the test file:
https://github.com/BiLEnsemble/SoundBeam/blob/master/SC_test.scd

q.pathToOscGroupClient = "/Users/monodread/Documents/OscGroup/OscGroupClient";
q.oscIP = "192.168.0.3"; // Servers (Les) IP Address
q.myNick = "jonas";

b = SoundBeam.newOSCGroups(q.pathToOscGroupClient, q.oscIP, q.myNick, "foo");


/////// Merging the two:
// would it work?

b = SoundBeam.newOSCGroups(q.pathToOscGroupClient, "realizedsound.mooo.com", q.myNick, "foo");

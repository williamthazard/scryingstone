//verison 0.0.1

// Inherit from CroneEngine
Engine_scryingstone : CroneEngine {
	var a;
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	alloc {
		var s=context.server;
		SynthDef(
			\wn,
			{
				arg sig,out,amp=0.2,pan=0;
				sig=Pan2.ar(WhiteNoise.ar(amp),pan);
				Out.ar(out,sig)
			}
		).add;
		SynthDef(
			\pn,
			{
				arg sig,out,amp=0.2,pan=0;
				sig=Pan2.ar(PinkNoise.ar(amp),pan);
				Out.ar(out,sig)
			}
		).add;
		SynthDef(
			\bn,
			{
				arg sig,out,amp=0.2,pan=0;
				sig=Pan2.ar(BrownNoise.ar(amp),pan);
				Out.ar(out,sig)
			}
		).add;
		s.sync;
		a = [Synth(\wn),Synth(\pn),Synth(\bn)];
		OSCdef(
			\amps_receiver,
			{
				arg msg;
				msg.postln;
				3.do(
					{
						arg i;
						if(
							msg[1] == i,
							{
								a[i].set(\amp,msg[2]);
							}
						);
					},
				);
			},
			\amps
		);
		OSCdef(
			\pans_receiver,
			{
				arg msg;
				msg.postln;
				3.do(
					{
						arg i;
						if(
							msg[1] == i,
							{
								a[i].set(\pan,msg[2]);
							}
						);
					},
				);
			},
			\pans
		);
	}
	free {
		3.do(
			{
				arg i;
				a[i].free;
			}
		);
	}
}
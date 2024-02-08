# VRChat OSC

A couple of programs that interface with VRChat's OSC system using "Small example OSC server" from https://github.com/attwad/python-osc.

Includes:
- Contact Haptic: A haptic module server that takes input from a VRChat contact and forwards it to a specific device running an OSC client that can trigger a vibration. Could be modified to run on the module itself, read VRChat on a remote device, and vibrate an attached motor, though I've done it this way as I had no such hardware built and the client I was using required OSC data to be explicitly sent TO it.
- LateWarner: A script that gets the current time, and if it matches a "Late" condition on specific days, sends a message to the VRChat chatbox. It also sets a "toggle/latewarner" parameter on the avatar so the avatar can react to it being late, perhaps by changing to a sleepy expression.

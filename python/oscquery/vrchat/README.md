# VRChat OSC

A couple of programs that interface with VRChat's OSC system using "Small example OSC server" from https://github.com/attwad/python-osc.

Includes:
- Head Haptic: A haptic module server that takes input from a VRChat contact and sends it to another device that can trigger a vibration. Could be modified to read VRChat from a remote device and vibrate directly on the module.
- LateWarner: A script that gets the current time, and if it matches a "Late" condition on specific days, sends a message to the VRChat chatbox.

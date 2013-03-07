iCanSleep is a free, open source menu bar tool to prevent your Mac from sleeping for a while. 

The main point of this tool is to allow the Mac to go back to "I can sleep" mode again
after the "no sleep" period is over. Hence the name.


Unique Features:
----------------

Compared to similar tools (Caffeine, InsomniaX) it has these unique features:

- automatically reinstates the normal sleep schedule after the "prevent sleep" period
- allows the display to go to sleep
- monitors a custom folder (and its subfolders) for activity (add/remove/write files/folders) 
- if folder activity is detected, can prevent Mac from sleeping for a preset time
- allows you to enter a custom "prevent sleep" time in minutes
- complete source code available - make your own modifications!


Compared to other "No Sleep" Tools:
-----------------------------------

You will want to use Caffeine instead if:
- you can live with its preset "no sleep" periods (5-30 minutes, 1, 2, 5 hours or indefinitely)
- you also want to prevent the display from sleeping every time it is active (WTF?)

You will want to use InsomniaX instead if:
- you're on a MacBook to make use of its extensive "Lid Sleep" options
- you want to prevent your Mac from sleeping indefinitely, period (WTF?)

So Caffeine's main issue is never putting the display to sleep. I see absolutely no use for that,
nor for not making that optional. And InsomniaX is just as good as setting the Energy Saver
to No Sleep and leave it at that. The "Lid Sleep" options provide some added value for MacBook 
users though. Neither tool supports disk activity monitoring.


Rationale & Support
-------------------

I wrote iCanSleep because both Caffeine and InsomniaX didn't fit my requirements, and it's
simple enough to write such a tool. Snippets of code courtesy of stackoverflow.com.

I'm sharing the source code because a) it's relatively simple and easy to extend and b) I don't
believe that iCanSleep will fit everyone's bill, but those who know how to program a little
can at least try to tweak it to their needs and c) because the crucial aspects of the code
were freely shared on stackoverflow.com to begin with.

I do not support the tool and I can't help with code modifications! 

I appreciate it if you made a useful addition and want to merge it back to the original tool
or if you publish it under a different name with attribution to the original.


About folder activity:
----------------------

The folder activity feature is for programs that don't play nice and would let the Mac
sleep even though an app is performing a long-running task. For instance, a Windows program
(video encoding, downloading, rendering, …) running in a virtual machine. But even some Mac
apps allow the Mac to sleep while they're still hard at work.

Note: for the folder activity feature to work with Windows apps, the output folder of
the Windows app needs to be mapped to a OS X folder. Parallels usually creates mapped drives
in Windows that point to the Mac's Documents directory for instance. Have the app save its files
in that location. Where this is not possible (rare), try mapping the app's fixed output folder
to a folder on the Mac, or run a xcopy batch file that copies only newer files to a Mac folder.

Note: Folder activity watches the folder and all of its subfolders. An activity is any
add/delete of a file or folder, or writing to a file. Choose the folder carefully and check
the Info Window to see if a program is unintentionally causing disk activity in the folder
or subfolders which prevent the Mac from sleeping altogether. For example it's a bad idea 
to choose the user's Home directory, as it contains the (hidden) Library folder where apps
frequently write to - in order to save their current state such as window positions.



====================================================================================================
iCanSleep is distributed under MIT License:
 
Copyright (C) 2013 Steffen Itterheim
 http://www.learn-cocos2d.com
 http://www.koboldtouch.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
====================================================================================================

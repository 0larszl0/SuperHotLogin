![Demo Video](Preview/SuperHotPreview.gif)

```
+---------------------------------------------------------------------------------------------------------------+
						SPECIAL THANKS


Special thanks to Mushtaq Hussain for granting me permission to use his video background in this project.
Please take the time out to check out his other works on Pinterest under alias "Video Editor"  or request his
services through fiverr.

pinterest : https://uk.pinterest.com/TrimEdit/
fiverr    : https://www.fiverr.com/trimedit



+---------------------------------------------------------------------------------------------------------------+

(User Notes)

BEFORE USE: CHECK THE LIMITATIONS THIS THEME HAS, IF IT'S NOT FOR YOU THEN DON'T USE IT.


If KDE settings giving a hard time switching, ensure or manually set:
    - /etc/sddm.conf.d/kde_settings.conf -- Current=SuperHotLogin  (under [Theme])
    - /etc/sddm.conf.d/theme.conf -- Current=SuperHotLogin (under [Theme])


Special effects to know that occur:
    - Red pulsing (warning light) will appear when you reach your last login attempt
    - Darkened environment with a singular message on terminal screen when max attempts have been reached


Features:
    - Click monitor power button to turn off display. (NOTE! Input is still taken even though display is off)
    - Click power button by PC to shutdown your actual machine
    - Click restart button by PC to reboot -^
    - On TAB Press, while on an input line, gives access to switching sessions, this is made visible by
      making the sessions text *bold*. 
          + To scroll through available sessions, press 'TAB' or 'w' 
          + To commit the changes just press ENTER


Optional Changes:
    - Experiment around with the values in theme.conf to find preferences that fit you
    - If you want to add your own quotes, you don't need to be Mr. Robot to do it
        1. Go to Components/QuoteModel.qml
	    2. Find the section with the list of ListElements {}
	    3. Modify the 'text' property inside them
	    4. Replace the property value, i.e. the text in the quotation marks

	    5. VOILA~ you changed the quote :)


External packages required:
    + gst-plugins-good
    + gst-libav
These packages are purely to enable the video background.


Limitations:
    - Doesn't allow you to implicitly hibernate or sleep
    - Doesn't show battery life
        |__ Could import it from org.kde.breeze.components, however, unsure if everyone downloading this 
            would have these additional components on their system.
    - Doesn't have a virtual keyboard
    - Doesn't do autologins, or auto user recognition, keeps it old school
    - Doesn't show whether CAPS or NUM LOCK is active
    - Doesn't say whether the user that's trying to be logged into has been locked out or not.

It should be the users responsibility to keep track of their number of retries and to know their own timeouts
and for heavens sake not to do autologins for security reasons, even if it's for a user with minimal privileges.


			+---------------------------------------------------------+


(Developer Notes)

"Greeter Account" (Wayland):
    If you get a timeout after 10mins and see a Breeze theme that will point to a "Greeter Account", you can
    fix this by going to:
        /etc/sddm.conf.d/wayland.conf
    and make sure the following is under [Wayland]
        CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1


The following command was used to compile my .frag files:
    (sudo) /usr/lib/qt6/bin/qsb --qt6 -o Shaders/[frag_file].qsb Shaders/[frag_file]


Dedicated z layers in Main.qml:
    0 - default layer, not directly specified, and uses the structure of the QML to order items properly
    1 - chatWindow, for the ChatWindow custom object under Components, deliberately used to separate
	  different overlays in LoginConsequences to give a different atmosphere 
    2 - anything that should cover the screen completely


Comments: 
    Comments are left in so learners and those who wish to modify the internal QML have some support in what's
    happening under the hood.


Additional notes:
    - The values from 'theme.conf' is accessed through a special object named 'config'. So to access something 
      like 'PasswordCharacter' you'd have to do: 'config.PasswordCharacter. Furthermore, running it through
      'qmlscene' will not recognise it, hence use: 
      '(sudo) sddm-greeter --test-mode --theme /usr/share/themes/SuperHotLogin'

    - This is the same with 'sessionModel', similar to 'config', is specially passed through the sddm runtime

    - In Shader .frag files, if you want to your own properties to get from QML, you must have the layout:
      layout(std140, binding = 0) uniform [name] {
          mat4 qt_Matrix;
	  float qt_Opacity;

	  [insert your own uniforms]
      } [instance name];
      This is even if you don't use qt_Matrix or qt_Opacity

    - In Components/LoginConsequences.qml, you'll notice the loginAttempts counter being incremented by 1, but from
      another strange case, is that SDDM calls onLoginFailed twice, I've ensured that this is not the case of
      the theme as this activity seems active in other themes like breeze (analysed using journalctl -u sddm -b).
      Additionally, I have checked whether this was the cause of any autologin feature, but it doesn't seem to be the case either.
      As a result, treat loginAttempts to always be a multiple of 2, this message is somewhat reiterated at the 
      top of the Components/LoginConsequences.qml file


Future Notes:
    - Might make a SuperHotLogout in the distant future, however, this will be unlikely as I want to move on to 
      explore other areas of computing. But, depending on the feedback of this theme and how available I am
      in the future would I only consider adding this... Perhaps the summer of 2026, but who knows ...

    - Self note, if I were to do SuperHotLogout, it's meant to be minimalist, not heavy with Shaders,
      so something that is similar in theme could be designed instead. For reference use:
      /usr/share/plasma/look-and-feel/org.kde.breeze.desktop/contents/logout/Logout.qml 


+---------------------------------------------------------------------------------------------------------------+
```

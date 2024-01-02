#!/bin/sh



create_initial_config()
    {
    mkdir -p /home/$USER/.config/mate

    #Find any existing wayfire.ini file
    if [ -e  /home/$USER/.config/wayfire.ini ]; then
        #User has configured wayfire, use their file and existing customizations
        cp /home/$USER/.config/wayfire.ini /home/$USER/.config/mate/wayfire.ini
    else
        #User has not configured wayfire. Look for the default .ini file where the package manager put it 
        cp /usr/share/doc/wayfire/examples/wayfire.ini /home/$USER/.config/mate/wayfire.ini
    fi

    #Add mate-wayland-components.sh to wayfire startup programs and set sane session defaults
    grep "mate-wayland-components" /home/$USER/.config/mate/wayfire.ini

    if [ $? -ne 0  ]; then
        sed -i '/autostart]/a mate = mate-wayland-components.sh' /home/$USER/.config/mate/wayfire.ini
        #do not start wayfire's default shell if installed
        sed -i 's/autostart_wf_shell = true.*/autostart_wf_shell = false/' /home/$USER/.config/mate/wayfire.ini
        #DO start the background though
        sed -i '/autostart]/a background = wf-background' /home/$USER/.config/mate/wayfire.ini
        #Use server-side decoration (SSD) by default as CSD is broken with caja
        sed -i 's/preferred_decoration_mode = client.*/preferred_decoration_mode = server/' /home/$USER/.config/mate/wayfire.ini
        #Use wayfire's workaround to disable forcing all dialogs to modal
        sed -i 's/all_dialogs_modal = true.*/all_dialogs_modal = false/' /home/$USER/.config/mate/wayfire.ini
    fi

    return 0
    }

check_config_file()

    {
    if [ -e  /home/$USER/.config/mate/wayfire.ini ]; then
        #If we have already configured wayfire for MATE do not alter the file
        return 0
    else
        #create ~/config/mate/wayfire.ini and include mate components in it
        create_initial_config
    return 0
    fi
    }

#See if we have already configured the session or not
check_config_file

# Set XDG_CURRENT_DESKTOP

export XDG_CURRENT_DESKTOP="MATE-wayland"

#Start the compositor
wayfire -c /home/$USER/.config/mate/wayfire.ini


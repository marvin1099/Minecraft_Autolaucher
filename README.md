# Minecraft Autolauncher – *Vivecraft Autolauncher Rewritten*

Original Vivecraft Autolauncher forked from [a script by Mavi222 here](https://github.com/Mavi222/Vivecraft-autolauncher).  
This is a complete rewrite with more convenience features.  
Originally forked [here on my GitHub](https://github.com/marvin1099/Minecraft_Autolaucher).

With this autolauncher, you can launch Minecraft directly from SteamVR without removing your headset.  

Right now this new python version is a beta  
and some autohotkey features are not implemented in the python version.  
So there is no compiled version of this jet, so use the py file.

### Features

After initial setup, the following happens automatically:

1. Launches the Minecraft Launcher.
2. Activates the Minecraft Launcher window.
3. Clears the search bar by clicking the Play button.
4. Navigates to the "Installations" tab.
5. Searches for the desired profile using the set query.
6. Launches the first matching profile.

### Download

You can download the latest version from:  
[Codeberg PY Download (after clicking on it, click the download symbol on the top right)](https://codeberg.org/marvin1099/Minecraft_Autolaucher/src/branch/python-variant/minecraftautolaucher.py)

### Dependencies

This project requires the following Python dependencies:
- `PyAutoGui`
- `PyWinCtl`
- `numpy`

You can install all dependencies using the following command:

```bash
pip install PyAutoGui PyWinCtl numpy
```

### Virtual Environment (For Linux Recommended)

To avoid installing dependencies globally, it's recommended to use a virtual environment:

1. Navigate to your project directory:

```bash
cd /path/to/your/project
```

2. Create a virtual environment:

```bash
python3 -m venv venv
```

3. Activate the virtual environment:

```bash
source venv/bin/activate
```

### Setup & Usage

**First Time Setup:**

1. Run the script and answer the setup questions. If unsure, just press enter to use the default options.
2. You'll be asked for a search query (e.g., "vivecraft") to search for a profile. If multiple profiles match, the script will launch the first result.
3. You only need to answer the setup questions once unless you move the launcher or change settings.

**Advanced Configuration:**

- If you move the script or change the Minecraft installation, make sure to move the associated configuration file (`minecraft_config.json`).
- You can edit the `minecraft_config.json` file directly to adjust settings, but manual configuration is optional.

**Launching:**

1. After setup, you can rerun the `minecraftautolaucher.py` as often as you like to start minecraft. 
2. The script will automatically open the Minecraft Launcher and execute the profile matching your query.

### Notes:

- The configuration is stored in a JSON file, which is easy to modify or reset if needed.
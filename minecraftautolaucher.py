#!/usr/bin/env python

import time
import shlex
import pyautogui
import pywinctl as gw
import numpy as np
import os
import sys
import json
from tkinter import Tk, filedialog, simpledialog
import platform
import subprocess


if getattr(sys, 'frozen', False):
    application_path = os.path.dirname(sys.executable)
elif __file__:
    application_path = os.path.dirname(__file__)

class MinecraftLauncherConfig:
    def __init__(self, json_path="minecraft_config.json", scale=None):
        if os.path.isabs(json_path):
            self.config_path = json_path
        else:
            self.config_path = os.path.join(application_path, json_path)
        self.config_data = self.load_config()
        if scale and isinstance(scale, float):
            self.scale = scale
        else:
            self.scale = 1.0
        self.title = "Minecraft Launcher"

    def load_config(self):
        """
        Load the configuration from the JSON file.
        """
        if os.path.exists(self.config_path):
            with open(self.config_path, "r") as f:
                return json.load(f)
        return {}

    def save_config(self):
        """
        Save the configuration to the JSON file.
        """
        with open(self.config_path, "w") as f:
            json.dump(self.config_data, f, indent=4)

    def select_minecraft_folder(self):
        """
        Open a dialog to select the .minecraft folder.
        """
        root = Tk()
        root.withdraw()  # Hide the root window
        folder_path = filedialog.askdirectory(title="Select .minecraft folder")
        if folder_path:
            self.config_data["minecraft_folder"] = folder_path
            print(f"Selected .minecraft folder: {folder_path}")
        return folder_path

    def detect_launcher(self):
        """
        Detect MinecraftLauncher.exe or the Minecraft launcher command.
        """
        system = platform.system()

        if system == "Windows":
            # Windows-specific launcher detection
            possible_paths = [
                os.path.join(os.getenv("ProgramFiles(x86)"), "Minecraft Launcher", "MinecraftLauncher.exe"),
                os.path.join(os.getenv("ProgramFiles"), "Minecraft Launcher", "MinecraftLauncher.exe"),
            ]
        else:
            # Linux/Unix detection (assuming a generic command for Minecraft launcher)
            possible_paths = ["/usr/bin/minecraft-launcher", "/usr/local/bin/minecraft-launcher"]

        for path in possible_paths:
            if os.path.exists(path):
                self.config_data["minecraft_launcher"] = path
                print(f"Detected Minecraft Launcher: {path}")
                return self.prompt_launcher_command(path)

        # If not found, prompt user to input manually
        return self.prompt_launcher_command()

    def prompt_launcher_command(self,req=None):
        """
        Prompt the user for the launcher command if it's not detected automatically.
        """
        root = Tk()
        root.withdraw()
        if req:
            launcher_cmd = simpledialog.askstring("Input", "Enter the command to start the Minecraft launcher:",req)
        else:
            launcher_cmd = simpledialog.askstring("Input", "Enter the command to start the Minecraft launcher:")

        if launcher_cmd:
            # Use shlex.split to handle splitting while preserving quoted strings
            command_list = shlex.split(launcher_cmd)
            self.config_data["minecraft_launcher"] = command_list
            return command_list

    def search_profile(self):
        """
        Prompt the user for a search query and save it.
        """
        root = Tk()
        root.withdraw()
        search_query = simpledialog.askstring("Search Profile", "Enter a profile name or search query:")
        if search_query:
            self.config_data["search_query"] = search_query
        return search_query

    def run_setup(self):
        """
        Run the full setup for selecting .minecraft folder, detecting launcher, and searching profile.
        """
        prints = False
        for section in ["minecraft_launcher", "search_query"]:
            if section not in self.config_data:
                prints = True
        if prints:
            print("Starting setup...")

        # Detect or input the Minecraft launcher command
        if "minecraft_launcher" not in self.config_data:
            self.detect_launcher()
            self.save_config()
            print("Saved minecraft command successfully.")

        # Search for profiles
        if "search_query" not in self.config_data:
            self.search_profile()
            self.save_config()
            print("Saved profile name successfully.")

        # Select the .minecraft folder
        # Noting usefull implemented with this right now, commenting out
        #if "minecraft_folder" not in self.config_data:
        #    self.select_minecraft_folder()
        #    self.save_config()
        #    print("Saved minecraft folder successfully.")


class WindowCalulator:
    def __init__(self, Conf):
        """
        Initialize the calculator with the given window and scale factor.
        The scale factor is used to scale relative coordinates.
        """
        self.title = Conf.title
        self.window = None
        if Conf.scale:
            self.scale_factor = Conf.scale
        else:
            self.scale_factor = 1.0
        if self.title:
            self.find_window_with_title()


    def find_window_with_title(self, title=None):
        # Find window with the exact title iputed for example "Minecraft Launcher"
        windows = None
        if not title:
            title = self.title
        try:
            windows = gw.getWindowsWithTitle(title)
        except Exception as e:
            pass
        if windows:
            self.window = windows[0]

            self.width = windows[0].width
            width = 0
            minw = 1020 * self.scale_factor
            if self.width < minw:
                #width = minh-self.width
                self.width = minw

            self.height = windows[0].height
            height = 0
            minh = 480 * self.scale_factor
            if self.height < minh:
                #height = minh-self.height
                self.height = minh

            self.left = int(windows[0].left)
            self.top = int(windows[0].top)

            windows[0].resizeTo(int(self.width), int(self.height))

            left = int(windows[0].left)
            top = int(windows[0].top)
            l = (self.left*2-left)
            t = (self.top*2-top)
            windows[0].moveTo(l, t)

            return self.window # Return the first matching window
        else:
            print("Requested window not found.")
            return None

    def get_window(self):
        return self.window

    def activate(self):
        self.window.activate()

    def get_win_pos(self):
        return self.left, self.top

    def preprocess_expression(self, expression):
        """
        Replace 'width' and 'height' in the expression with actual values.
        """
        expression = expression.replace("width", str(self.width/self.scale_factor))
        expression = expression.replace("w", str(self.width/self.scale_factor))
        expression = expression.replace("height", str(self.height/self.scale_factor))
        expression = expression.replace("h", str(self.height/self.scale_factor))
        return expression

    def evaluate_expression(self, expression):
        """
        Safely evaluate mathematical expressions using numpy.
        """
        try:
            # Preprocess expression to replace 'width' and 'height'
            processed_expr = self.preprocess_expression(expression)
            # Use numpy to evaluate the expression safely
            result = eval(processed_expr, {"np": np, "__builtins__": {}})
            return result
        except Exception as e:
            print(f"Error evaluating expression: {e}")
            return None

    def rel_coords(self, x_expr, y_expr=None):
        """
        Compute the x and y coordinates relative to the window and apply scaling.
        """
        if isinstance(x_expr,list):
            if len(x_expr) > 1:
                y_expr = x_expr[1]
                x_expr = x_expr[0]
            else:
                print("Error unpacking expressions")
                return None, None

        x = self.evaluate_expression(x_expr)
        y = self.evaluate_expression(y_expr)

        if x is not None and y is not None:
            # Apply scaling to the relative coordinates
            scaled_x = x * self.scale_factor
            scaled_y = y * self.scale_factor
            return scaled_x, scaled_y
        else:
            print("Failed to compute relative coordinates.")
            return None, None

    def abs_coords(self, x_expr, y_expr=None):
        """
        Compute the x and y absolute screen coordinates using complex expressions.
        """
        if isinstance(x_expr,list):
            if len(x_expr) > 1:
                y_expr = x_expr[1]
                x_expr = x_expr[0]
            else:
                print("Error unpacking expressions")
                return None, None

        x, y = self.rel_coords(x_expr, y_expr)

        if x is not None and y is not None:
            # Calculate absolute screen position based on window position
            abs_x = self.left + x
            abs_y = self.top + y
            return abs_x, abs_y
        else:
            print("Failed to compute absolute coordinates.")
            return None, None


class MinecraftRunner:
    def __init__(self, conf):
        self.conf = conf
        self.calc = None

    def run(self, commandaslist):
        p = subprocess.Popen(commandaslist, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        return p

    def query_on_json(self, profiles, query):
        if os.path.exists(profiles):
            try:
                with open(profiles, "r") as f:
                    jsondata = json.load(f)
            except Exception as e:
                return query

            plist = jsondata.get("profiles",{})
            match = None
            if plist:
                for pid, profile in plist.items():
                    name = profile.get("name","")
                    ty = profile.get("type","")
                    if not name:
                        if ty == "latest-release":
                            name = "Latest release"
                        elif ty == "latest-snapshot":
                            name = "Latest snapshot"
                        if query in name:
                            if query == name:
                                return query
                            if not match:
                                match = name
                            if len(match) > len(name):
                                match = name
                if match:
                    return match

        return query

    def gui_mc_start(self, to_type):
        mc_buttons = {
            "Play Tab":["250", "60"],
            "Installations Tab":["350", "60"],
            "Search Field":["300","130"],
            "Play Instance":["w-140","260"]
        }
        self.calc.activate()
        time.sleep(0.2)
        if to_type:
            x, y = self.calc.abs_coords(mc_buttons.get("Play Tab"))
            pyautogui.moveTo(x, y)
            pyautogui.click()
            pyautogui.write(to_type)
            time.sleep(0.2)
        x, y = self.calc.abs_coords(mc_buttons.get("Installations Tab"))
        pyautogui.moveTo(x, y)
        pyautogui.click()
        time.sleep(0.2)
        if to_type:
            x, y = self.calc.abs_coords(mc_buttons.get("Search Field"))
            pyautogui.moveTo(x, y)
            pyautogui.click()
            pyautogui.write(to_type)
            time.sleep(0.2)
        x, y = self.calc.abs_coords(mc_buttons.get("Play Instance"))
        pyautogui.moveTo(x, y)
        #pyautogui.click()
        print("Finished minecraft runner")

    def execute(self, calc):
        confdata = self.conf.load_config()
        self.calc = calc
        launcher = confdata.get("minecraft_launcher")
        if not calc.get_window() and launcher:
            p = self.run(launcher)
            if not p:
                print("Problem starting the launcher,\ntrying anyway but the launcher command may be incorrect,\nto fix delete the config then it will re-ask you")
            time.sleep(10)
        calc.find_window_with_title()
        if calc.get_window():
            folder = confdata.get("minecraft_folder")
            if not folder:
                folder = ""

            query = confdata.get("search_query")
            if isinstance(query, str):
                bquery = str(query)
            else:
                bquery = None
            profiles = os.path.join(folder,"launcher_profiles.json")
            if os.path.isfile(profiles):
                bquery = self.query_on_json(profiles, query)
            if bquery and isinstance(bquery, str):
                query = bquery
            if not query:
                query = ""
            self.gui_mc_start(query)


def automate_minecraft(scale=1.0):
    # Find Minecraft Launcher window
    Conf = MinecraftLauncherConfig(scale=scale)
    Conf.run_setup()
    Runner = MinecraftRunner(Conf)
    Calc = WindowCalulator(Conf)
    Runner.execute(Calc)

if __name__ == "__main__":
    # You can adjust the manual_scale here as needed (e.g., set to 1.5 for 150% scaling)
    automate_minecraft(scale=1.5)  # Example: 150% scaling

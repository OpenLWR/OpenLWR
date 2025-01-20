It is reccomended to play on the most recent release (https://github.com/OpenLWR/OpenLWR/releases)

However, if you wish to play on a newer version, you can play from the source code directly

## Installation
![Github Release Version](https://img.shields.io/github/v/release/OpenLWR/OpenLWR?include_prereleases&label=Current+Release+Version)

OpenLWR is available for Windows, Mac, and Linux

- To install, simply head to the [Releases](https://github.com/OpenLWR/OpenLWR/releases/) section and download the appropriate executable.
- Alternatively, OpenLWR can be installed as a package on the following platforms:

  | Platform | Package Name  | Package Version                                                | Maintainer                                        |
  |----------|---------------|----------------------------------------------------------------|---------------------------------------------------|
  | AUR      | `openlwr-bin` | ![AUR Version](https://img.shields.io/aur/version/openlwr-bin) | [RadiantCorium](https://github.com/RadiantCorium) |

## Minimum Recommended System Requirements
#### Please do not ask for help running the game or report bugs on systems which do not meet the below requirements
Windows:
```
OS: Windows 7 or later

CPU:
    - Any quad-core 64-bit x86 CPU with SSE4.2 support
    - Any Snapdragon X Elite CPU or newer

GPU: 
    - Any dedicated Intel ARC series GPU
    - Any Nvidia 10 series or newer GTX or RTX GPU
    - Any AMD Radeon RX, Vega, or R9 series GPU with Vulkan 1.2 support
    - Any Integrated Snapdragon X Elite GPU or newer

RAM: At least 8GB
```
macOS:
```
OS: macOS 10.15 or later

CPU:
    - Any x86 CPU
    - Any Apple Silicon CPU

GPU:
    - Any AMD Radeon RX, Vega or R9 series GPU with Metal support
    - Any Integrated Apple Silicon GPU

RAM: At least 8GB
```
Linux:
```
OS: Any Linux distribution with glibc 2.31 or later

CPU:
    - Any quad-core 64-bit x86 CPU with SSE4.2 support
    - Any ARMv8 based system supporting an external GPU
    - Any Apple Silicon system running the latest Asahi Linux patches

GPU:
    - Any dedicated Intel ARC series GPU
    - Any Nvidia GTX or RTX GPU with the latest nvidia or nvidia-open driver (Nouveau driver is not supported)
    - Any AMD Radeon RX, Vega, or R9 series GPU with Vulkan 1.2 support
    - Any Integrated Apple Silicon GPU

RAM: At least 8GB
```



## Running from Source

> [!NOTE]
> The following steps were performed on windows, if it does not work on other operating systems, please make an issue.
> 

<details>

  <summary>Installing and Loading the project</summary>

  First, you need to downloaded the Godot Editor, which can be found [here](https://godotengine.org/download)\
  When you unzip the downloaded file, you can launch godot, there is no actual installation required.

  Next, download the source code

  ![image](https://github.com/user-attachments/assets/6ee7a482-8d96-4be5-89f1-e4db01eab5f1)

  Once you have the source code downloaded, unzip the source code.

  In the Godot Editor, click "Import"

  ![image](https://github.com/user-attachments/assets/fabc4e2a-f57c-4646-9310-537b1616b46d)

  Find and select the OpenLWR unzipped folder.

  Click "Select Current Folder"
  
</details>

<details>
  <summary>Running the project</summary>

  You can either directly run the project, by clicking on the project that has appeared in your Godot project manager window, and click "Run" on the right side
  or you can click "Edit", then click the play button in the top right corner.

  ![image](https://github.com/user-attachments/assets/fa1511b7-a02f-4fc1-b8c1-8891c8cc8ea0)

  However, if you wish to have an executable, you can choose to build the project.
</details>

<details>
  <summary>Building the project (OPTIONAL)</summary>
  
  Click "Edit" on the right side of the project manager.
  In the top left of the editor, click "Project", then "Export"
  
  ![image](https://github.com/user-attachments/assets/a3c90b61-d0b9-4863-8997-4420bec65634)
  In the new export window, click "Add..."
  Then select your operating system.

  Ensure that, in the preset, you check "Runnable"
  
  ![image](https://github.com/user-attachments/assets/f65d9f0a-f2af-4d4d-9c59-43d23a5bcabe)

  If you wish to make the executable all one file, you can choose to embed the PCK, which is all the materials and whatnot for the game. Also choose your architecture.

  ![image](https://github.com/user-attachments/assets/473e89b0-477d-4ce4-867f-57d4d8d99704)

  At the bottom, it may ask you to install the export template. Click that, and click "Download and Install".

  Then, click "Export Project".

  After the project finishes exporting, you can move the executable to where you like, and then play the game normally.

</details>

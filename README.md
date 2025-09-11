# LaTeX Environment
LaTeX Environment (LTXE) is a repository designed to make working with LaTeX projects easier.

LaTeX is a powerful way to write documents programmatically and produce polished PDFs, but customizing it often comes with challenges.
For example, on cloud-based editors like Overleaf, using `-shell-escape` is restricted, which limits the use of custom packages.
Managing these packages locally and keeping projects consistent across collaborators can become quite messy.

LTXE addresses these issues by providing scripts to manage LaTeX packages in a personal TeX tree and by handling builds in a consistent way.
Documents are compiled locally, with all outputs collected in a clean `out/` folder.

By combining this setup with Git version control, projects can stay organized, custom packages are easy to share, and collaboration becomes simpler.

## Table of Contents
- [Usage](#usage)
  - [Project Structure](#project-structure)
  - [Commands](#commands)
- [Setup](#setup)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Custom Packages](#custom-packages)
  - [Adding Custom Packages](#adding-custom-packages)
  - [Creating Custom Packages](#creating-custom-packages)

## Usage
### Project Structure
The project structure is organized as follows:
```bash
LaTeX-environment/
├── .ltxe/*                       # Script files for LTXE, which should remain untouched.
├── bib/                          # BibTeX files for bibliography management.
│   └── references.bib            # - Can be used in your documents to cite sources.
├── doc/                          # TeX source files, and other relevant files.
│   └── my-document.tex           # - Will be copied to ./out, then be compiled to a pdf.
│   └── my-data.csv               # - Will be copied to ./out
├── fig/                          # Image files for figures and graphics.
│   └── my-figure.png             # - Can be included as a figure in your documents.
├── inc/                          # Partial TeX source files.
│   └── my-included-document.tex  # - Can be included as a partial LaTeX source file in your main documents. Useful for sharing common content across multiple documents.
├── log/                          # Log files for LaTeX compilation.
├── out/                          # Output files for compiled PDFs and copied files.
├── pkg/                          # Package files for custom LaTeX packages.
│   └── mypackage/                # - Custom LaTeX package
│       └── tex/latex/mypackage/
│           └── mypackage.sty     # - Custom LaTeX package style file.
│           └── post-sync.sh      # - Post-sync script executed after synchronizing packages to your personal tree.
└── ltxe.sh                       # Main script file for LTXE, which should remain untouched.
```

### Commands
The following commands are available:

| Command        | Arguments | Description |
|----------------|-----------|-------------|
| `add (a)`      | `<name>` `<repository>`                           | Add a custom package from a Git repository. |
| `build (b)`    | `[absolute_path\|relative_path_to_doc_directory]` | Compile all `.tex` files from the `doc/` directory, and move those along with all non `.tex` files to the `out/` directory. |
| `clean (c)`    |                                                   | Remove all example files from the project. |
| `list (l, ls)` |                                                   | List all packages in the project. |
| `remove (rm)`  | `<name>`                                          | Remove a custom package from the project. |
| `sync (s)`     |                                                   | Sync custom packages from the project to your personal TeX tree. |
| `tree (t)`     |                                                   | List all packages registered to your personal TeX tree. |

On Linux, commands can be executed using the `./ltxe.sh` script inside the root directory of the project.
The same scripts can also be executed on MacOS, but may only partially work due to differences in the operating systems.
Since I do not own a MacOS device, I cannot test the scripts for Mac users.
If you are a Mac user, and something does not work as expected, please open an issue [here](https://github.com/Bloedarend/LaTeX-Environment/issues).

## Setup
### Prerequisites
Make sure you have a LaTeX distribution (SDK) installed on your machine.
This project is tested with **TeX Live**, but any of the following distributions should work:

| Distribution | OS Support            | Installation Guide / Website                                                       |
|--------------|-----------------------|------------------------------------------------------------------------------------|
| **TeX Live** | Windows, macOS, Linux | [https://tug.org/texlive/](https://tug.org/texlive/)                               |
| **MiKTeX**   | Windows, macOS, Linux | [https://miktex.org/howto/install-miktex](https://miktex.org/howto/install-miktex) |
| **MacTeX**   | macOS only            | [https://tug.org/mactex/](https://tug.org/mactex/)                                 |
| **proTeXt**  | Windows only          | [https://tug.org/protext/](https://tug.org/protext/)                               |
| **TinyTeX**  | Windows, macOS, Linux | [https://yihui.org/tinytex/](https://yihui.org/tinytex/)                           |

> **NOTE:** Most SDKs already come with `latexmk`, which automates multi-pass builds.
> Validate that it is installed by running:<br>
> ```bash
> latexmk -v
> ```
> If it's missing, follow [this guide](https://mgeier.github.io/latexmk.html#installation) to install it.

If you want to add custom packages via the `add` command, you will also need to install [Git](https://git-scm.com/downloads).

### Installation
1. Clone this repository, or download it as zip and extract it.
2. Run the `build` command. Verify that `my-document.pdf` is generated into the `out/` directory.
3. Run the `clean` command to remove all example files.
4. Start writing your own LaTeX documents!

## Custom Packages
### Using Custom Packages
There are two ways to add custom packages to your LaTeX environment:
1. Using the `add` command to add a package from a Git repository.
2. Moving or creating a directory inside the `pkg/` directory.

After adding packages to the `pkg/` directory, you need to run the `sync` command to update your personal LaTeX environment.
This command will also run the post-sync scripts from each package.

> **NOTE:** Note that you will most likely have to restart language servers for your IDE to see the updated TeX file database.

### Creating Custom Packages
Create a new directory inside the `pkg/` directory. The name of the directory should be equal to your package name.
Place your `.sty`, `.cls` etc. files in the new directory using the standard LaTeX tree layout:

| Type   | Directory                       | Description                                       |
|--------|---------------------------------|---------------------------------------------------|
| .afm   | fonts/afm/foundry/typeface      | 	Adobe Font Metrics for Type 1 fonts              |
| .bib   | bibtex/bib/bibliography         | 	BibTeX bibliography                              |
| .bst   | bibtex/bst/<package_name>       | 	BibTeX style                                     |
| .cls   | tex/latex/base                  | 	Document class file                              |
| .dvi   | doc 	                           | package documentation                             |
| .enc   | fonts/enc                       | 	Font encoding                                    |
| .fd 	 | tex/latex/mfnfss                | 	Font Definition files for METAFONT fonts         |
| .fd 	 | tex/latex/psnfss 	             | Font Definition files for PostScript Type 1 fonts |
| .map   | fonts/map 	                     | Font mapping files                                |
| .mf 	 | fonts/source/public/typeface 	 | METAFONT outline                                  |
| .pdf   | doc 	                           | package documentation                             |
| .pfb   | fonts/type1/foundry/typeface 	 | PostScript Type 1 outline                         |
| .sty   | tex/latex/<package_name> 	     | Style file: the normal package content            |
| .tex   | doc 	                           | TeX source for package documentation              |
| .tex   | tex/plain/<package_name> 	     | Plain TeX macro files                             |
| .tfm   | fonts/tfm/foundry/typeface 	   | TeX Font Metrics for METAFONT and Type 1 fonts    |
| .ttf   | fonts/truetype/foundry/typeface | TrueType font                                     |
| .vf 	 | fonts/vf/foundry/typeface 	     | TeX virtual fonts                                 |
| others | tex/latex/<package_name> 	     | other types of file unless instructed otherwise   |

If your package needs to run commands after synchronization, you can add a `post-sync.sh` script inside the `tex/latex/<package_name>` directory.
An example usage for a post install script may be to register a custom pygmentize style using Python.
The script will be executed after the synchronization process is completed.

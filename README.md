# LaTeX Environment
This project provides a minimal yet powerful local LaTeX setup, including:
- One-line build command.
- Local package management (with personal texmf tree)
- Recursive document building and smart output cleanup.

## Prerequisites
Make sure you have a LaTeX distribution (SDK) installed on your machine.
We recommend **TeX Live**, but any of the following distributions should work:

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

## Installation
1. Clone this repository, or download it as zip and extract it.
2. In your terminal, run:
   ```bash
   ./ltxe.sh update # Copies packages from ./lib into your personal tree.
   ./ltxe.sh build # Builds all .tex files in ./doc, and outputs them to ./out
   ```
3. Verify output by opening `out/mydocument.pdf`. If everything works, the background should be green.

## Usage
### Commands
Commands can be executed from the root directory using `./ltxe.sh <command>` in your terminal. 

| Command    | Description                                                                         |
|------------|-------------------------------------------------------------------------------------|
| help       | Show command reference.                                                             |
| ls         | List installed packages in your personal texmf tree.                                |
| update (u) | Copy local packages from `./lib` to your personal texmf tree, and refresh TeX DB.   |
| build (b)  | Compile all `.tex` files in `./doc`, and place outputs (and other files) in `./out` |

### File structure
```bash
.
├── ltxe.sh             # The main command script
├── doc/                # Your .tex source files and other related assets
│   └── mydocument.tex  # - Will be compiled to pdf, then be copied to ./out
│   └── data.xlsx       # - Will be copied to ./out
├── out/                # Compiled PDFs and copied assets go here
├── lib/                # Custom LaTeX packages (optional)
│   └── mypackage/
│       └── tex/latex/mypackage/mypackage.sty
├── img/                # Images used in your documents
```
The build command will:
- Recursively find all `.tex` files in `./doc`.
- Run `latexmk` on each file, outputting compiled `.pdf` files o `./out`.
- Copy any non-Tex files to `./out`.

### Adding custom packages
Create a new directory inside `./lib`. The name of the directory should be equal to your package name.
Place your `.sty`, `.cls` etc. files in the new directory using the standard LaTeX tree layout:

| Type   | 	Directory                         | 	Description                                      |
|--------|------------------------------------|---------------------------------------------------|
| .afm   | 	fonts/afm/foundry/typeface        | 	Adobe Font Metrics for Type 1 fonts              |
| .bib   | 	bibtex/bib/bibliography           | 	BibTeX bibliography                              |
| .bst   | 	bibtex/bst/<package_name>         | 	BibTeX style                                     |
| .cls   | 	tex/latex/base                    | 	Document class file                              |
| .dvi   | 	doc 	                             | package documentation                             |
| .enc   | 	fonts/enc                         | 	Font encoding                                    |
| .fd 	  | tex/latex/mfnfss                   | 	Font Definition files for METAFONT fonts         |
| .fd    | 	tex/latex/psnfss 	                | Font Definition files for PostScript Type 1 fonts |
| .map   | 	fonts/map 	                       | Font mapping files                                |
| .mf 	  | fonts/source/public/typeface 	     | METAFONT outline                                  |
| .pdf   | 	doc 	                             | package documentation                             |
| .pfb   | 	fonts/type1/foundry/typeface 	    | PostScript Type 1 outline                         |
| .sty   | 	tex/latex/<package_name> 	        | Style file: the normal package content            |
| .tex   | 	doc 	                             | TeX source for package documentation              |
| .tex   | 	tex/plain/<package_name> 	        | Plain TeX macro files                             |
| .tfm   | 	fonts/tfm/foundry/typeface        | 	TeX Font Metrics for METAFONT and Type 1 fonts   |
| .ttf   | 	fonts/truetype/foundry/typeface 	 | TrueType font                                     |
| .vf 	  | fonts/vf/foundry/typeface 	        | TeX virtual fonts                                 |
| others | 	tex/latex/<package_name> 	        | other types of file unless instructed otherwise   |

Then run:
```bash
./ltxe.sh update
```
This copies your local packages into your personal texmf tree and refreshes the TeX file database.
> **NOTE:** Note that you will most likely have to restart your terminal or IDE session to see the updated TeX file database.
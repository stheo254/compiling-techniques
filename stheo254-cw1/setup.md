# Setup

## Initial Git Setup

### Generate SSH keys and add them to your GitLab account

#### Generate SSH Key Pair
1. Open a terminal
2. Run
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
3. Press `Enter` to accept the default file location
4. Optionally, set a passphrase for added security

#### Add SSH Key to GitLab
1. Copy the contents of your public key
   - macOS/Linux: `cat ~/.ssh/id_ed25519.pub | pbcopy`
   - Windows (Git Bash): `cat ~/.ssh/id_ed25519.pub | clip`
2. Log in to GitLab
3. Navigate to **Profile > SSH Keys**
4. Paste your public key and provide a descriptive title
5. Click **Add key**
6. On your machine start your SSH agent and add your SSH key to the agent:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

#### Verify Connection
Run the following command to test the SSH connection
```bash
ssh -T git@git.tu-berlin.de
```

For further troubleshooting, you can use the verbose mode to get more details:
```bash
ssh -vT git@git.tu-berlin.de
```

You should see a welcome message confirming successful authentication. More information regarding SSH keys and the GitLab setup can be found at the [official GitLab documenation](https://docs.GitLab.com/user/ssh/).

### Hint for using private GitHub and TU Berlin GitLab account on the same machine

Create or edit the config file located at `~/.ssh/config` and add the following entries:

```bash
Host git.tu-berlin.de
        HostName git.tu-berlin.de
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
```

## Download a Coursework using git

First, you will need to **clone** the repository from GitLab.

  At this point, you can clone the repository:
  - if you used HTTPS, use the command
    ```bash
    git clone https://git.tu-berlin.de/compiling-techniques/2025/USER_NAME/REPOSITORY_NAME.git
    ```
  - if you used SSH, use the command
    ```bash
    git clone git@git.tu-berlin.de:compiling-techniques/2025/USER_NAME/REPOSITORY_NAME.git
    ```
Now enter the repository directory: `cd REPOSITORY_NAME`. If this is your first time using Git, you will need to set up a bit of configuration:
  ```bash
  git config --global user.name "your_github_username"
  git config --global user.email "your_github_email"
  ```
  This will set your username and email globally (for all repositories, unless they overwrite this), so all future GitHub repositories will already have this set up. If you do not wish to do that, just omit the `--global`.
  You can verify the setup using `git config -l`, which will just tell you what settings you set.

## Installation

You need a modern version of Python for the coursework. We have tested this setup with Python 3.11.
You can either follow the instructions below for the command line *or* PyCharm.

### Command Line

We recommend that you create an isolated python environment using [venv](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment).  
To set up `venv` for the assignment, follow the steps below:

1. Set up a virtual environment.
   This creates a subdirectory called `env` in the current folder that creates an isolated version of Python.
    ```bash
    /path/to/coursework$ python3 -m venv env # set up virtual environment called `env`
    ```
2. Activate the virtual environment by [`source`ing](https://linuxcommand.org/lc3_man_pages/sourceh.html) the activation file (you have to do this for every new terminal window):
   ```bash
    /path/to/coursework$ source env/bin/activate
   ```
3. Confirm that you are in the virtual environment:
   ```bash
   /path/to/coursework$ which python # confirm python path
   /path/to/coursework/env/bin/python
   ```
4. Install dependencies within the virtual environment:
   ```bash
   /path/to/coursework$ pip install -U -r requirements.txt # install dependencies
   ```
5. Install the ChocoPy compiler as a package:
   ```bash
   /path/to/coursework$ pip install -e . # install ChocoPy as a package
   ```

### PyCharm

It would be convenient for you, if you used a modern IDE for Python.
A popular choice is [PyCharm](https://www.jetbrains.com/pycharm/).

If you decide to use `PyCharm`, download and install it on your computer. Then:

1) Open the repository folder in `PyCharm`
2) Configure a virtual Python environment as described in the manual: https://www.jetbrains.com/help/pycharm/creating-virtual-environment.html
2) Install the dependencies by opening the embedded terminal (`Alt+F12` by default) and run:
   ```bash
   pip install --upgrade pip # upgrade pip
   pip install -U -r requirements.txt # install dependencies
   ```
3) Install the ChocoPy compiler as a package:
   ```bash
   pip install -e . # install ChocoPy as a package
   ```

### Notice on Additional Imports
Adding imports from the Python standard library is permitted if needed. Ensure that any additions are relevant, maintain readability, and do not introduce unnecessary dependencies.

### Running `lit` on Windows in PyCharm

To run `lit` correctly on Windows in PyCharm, update `lit.cfg` to use `;` instead of `:` as the file path separator. Avoid adding `print` statements to test files, as `lit` compares actual output with expected results, and extra prints will cause failures.

`choco-opt` only runs code and prints output—it does not validate correctness. `lit` runs `choco-opt` and compares its output against expected results, ensuring correctness. If `choco-opt` raises an error, either the test is incorrect or there is a bug in your implementation.

To run tests properly, use:
- `lit -a` to run all tests.
- `lit -v tests/parser` for verbose output.
- `lit -v tests/parser/some_test.py` for a specific test.

If results differ from running `choco-opt` manually, verify how `lit` invokes it. Ensure PyCharm runs as administrator, check for correct line endings (`\n` instead of `\r\n`), and adjust subprocess calls to work with Windows.

If the README lacks details on `lit` validation, expected outputs, or Windows troubleshooting, consider updating it for clarity. Following these steps ensures `lit` runs correctly on Windows.

### Debugging in VSCode

To debug your code in **Visual Studio Code (VSCode)**, you need to set up the correct environment. Follow the steps below to configure VSCode for debugging:

1) Install the Python Debug Extension
Ensure that you have the **[ms-python.python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)** extension installed in VSCode:
    - Open VSCode.
    - Go to the **Extensions** view (`Ctrl+Shift+X` or `Cmd+Shift+X` on macOS).
    - Search for `Python` and install the extension published by Microsoft.

2) Configure Debugging 

    1. Open VSCode and navigate to the **Run and Debug** view in the Activity Bar on the left.
    2. Click **"create a launch.json file"**.
    3. Select **Python** > **Python Module**.
    4. Enter the module name: `tools.choco_opt`.
    5. Modify the generated `launch.json` file to include command-line arguments.

    This should create a `.vscode` folder in your project directory containing a `launch.json` file. 
    
    If you prefer, you can instead of following the above guide just manually create this file and paste the following content:

    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "ChocoPy parse",
                "type": "python",
                "request": "launch",
                "module": "tools.choco_opt",
                "args": ["tests/parser/arithmetic-comparison-ops/associativity/associativity_plus.choc"],
                "justMyCode": true
            }
        ]
    }
    ```
    `"args"` specifies the command line arguments with the file as value, you can place the path to whatever file you want there.

3) Running the Debugger
After configuring `launch.json`, follow these steps to start debugging:
    1. Set a **breakpoint** by clicking to the left of the line number where you want execution to pause (a red dot will appear).
    2. Open the **Run and Debug** view.
    3. Click **Start Debugging** (`F5`).
    4. Execution will stop at the breakpoint.
    5. Use the floating debug controls at the top to **Step In, Step Over, or Continue** execution.

For more detailed instructions, refer to the **[official VSCode documentation](https://code.visualstudio.com/docs/editor/debugging)** on installing extensions and debugging Python code.


## Test your solutions

You can use `lit` to automatically test your code, which is included in the `requirements.txt`.

To run it locally, do:

```bash
lit -v tests/test-folder
```

This will recursively examine all files with valid formats inside the specified directory.
The `-v` flag adds a verbose output with more information in case some tests fail.

You can also leverage the `--timeout <seconds>` flag, in order to bound the time allowed for your test cases to run.
This way you can detect if your parser loops infinitely in some test cases.

For more details on the configuration of `lit`, see `tests/lit.cfg`.
For more info on `lit` check the [online documentation](https://filecheck.readthedocs.io/en/latest/01-what-is-filecheck.html).
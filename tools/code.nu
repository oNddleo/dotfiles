#!/usr/bin/env nu
# AI CLI Tools Installation Script
# Installs: claudecode, gemini-cli, and claudia

def main [] {
    print "🤖 Installing AI CLI Tools..."
    print "================================"
    
    # Check prerequisites
    check_prerequisites
    
    # Install each tool
    install_claudecode
    install_gemini_cli
    install_claudia
    
    print "\n✅ Installation complete!"
    print "🔧 You may need to restart your shell or run 'source ~/.config/nushell/env.nu'"
}

def check_prerequisites [] {
    print "🔍 Checking prerequisites..."
    
    # Check if npm/node is available
    if (which npm | is-empty) {
        print "❌ npm is required but not found. Please install Node.js first."
        exit 1
    }
    
    # Check if curl is available
    if (which curl | is-empty) {
        print "❌ curl is required but not found. Please install curl first."
        exit 1
    }
    
    # Check if git is available
    if (which git | is-empty) {
        print "❌ git is required but not found. Please install git first."
        exit 1
    }
    
    print "✅ Prerequisites check passed"
}

def install_claudecode [] {
    print "\n📦 Installing Claude Code CLI..."
    
    try {
        # Install via npm globally
        npm install -g @anthropic-ai/claude-code
        
        # Verify installation
        if (which claude-code | is-not-empty) {
            let version = (claude-code --version | str trim)
            print $"✅ Claude Code CLI installed successfully: ($version)"
        } else {
            print "⚠️  Claude Code CLI installed but not found in PATH"
        }
    } catch { |err|
        print $"❌ Failed to install Claude Code CLI: ($err.msg)"
    }
}

def install_gemini_cli [] {
    print "\n💎 Installing Gemini CLI..."
    
    try {
        # Install via npm globally
        npm install -g @google/gemini-cli
        
        # Verify installation
        if (which gemini | is-not-empty) {
            print "✅ Gemini CLI installed successfully"
        } else {
            # Alternative installation method
            print "🔄 Trying alternative installation..."
            npm install -g google-generative-ai-cli
            
            if (which gemini | is-not-empty) {
                print "✅ Gemini CLI installed successfully (alternative method)"
            } else {
                print "⚠️  Gemini CLI installed but not found in PATH"
            }
        }
    } catch { |err|
        print $"❌ Failed to install Gemini CLI: ($err.msg)"
        print "💡 You may need to install it manually or check the package name"
    }
}

def install_claudia [] {
    print "\n🏛️  Installing Claudia..."
    
    let claudia_dir = ($env.HOME | path join ".local" "share" "claudia")
    let bin_dir = ($env.HOME | path join ".local" "bin")
    
    try {
        # Create directories
        mkdir $claudia_dir
        mkdir $bin_dir
        print $"📁 Created directory: ($claudia_dir)"
        
        # Clone Claudia from the correct repository
        print "🔄 Cloning Claudia repository..."
        git clone https://github.com/getAsterisk/claudia.git $claudia_dir
        print "✅ Claudia cloned successfully"
        
        # Navigate to the directory and check if it needs building
        cd $claudia_dir
        
        # Check if there's a package.json (Node.js project)
        if ("package.json" | path exists) {
            print "📦 Installing dependencies..."
            npm install
            
            # Check if there's a build script
            let package_json = (open package.json)
            if ($package_json | get scripts | get build | is-not-empty) {
                print "🔨 Building project..."
                npm run build
            }
        }
        
        # Check if there's a setup script or executable
        let possible_executables = ["bin/claudia", "claudia", "dist/claudia", "build/claudia"]
        mut executable_path = null
        
        for exe in $possible_executables {
            if ($exe | path exists) {
                $executable_path = ($claudia_dir | path join $exe)
                break
            }
        }
        
        if ($executable_path | is-not-empty) {
            # Create symlink to the executable
            let target_link = ($bin_dir | path join "claudia")
            ln -sf $executable_path $target_link
            chmod +x $target_link
            print $"✅ Claudia executable linked at ($target_link)"
        } else {
            # Create a wrapper script
            create_claudia_wrapper $claudia_dir $bin_dir
        }
        
    } catch { |err|
        print $"❌ Failed to install Claudia: ($err.msg)"
        print "💡 You may need to check the repository structure or install manually"
    }
}

def create_claudia_wrapper [claudia_dir: string, bin_dir: string] {
    try {
        print "🔧 Creating Claudia wrapper script..."
        
        # Check what type of project this is
        cd $claudia_dir
        
        let wrapper_content = if ("package.json" | path exists) {
            # Node.js project
            "#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');

const claudiaDir = '" + $claudia_dir + "';
const mainScript = path.join(claudiaDir, 'index.js');

// Try to find the main entry point
const fs = require('fs');
let entryPoint = mainScript;

if (fs.existsSync(path.join(claudiaDir, 'dist', 'index.js'))) {
    entryPoint = path.join(claudiaDir, 'dist', 'index.js');
} else if (fs.existsSync(path.join(claudiaDir, 'build', 'index.js'))) {
    entryPoint = path.join(claudiaDir, 'build', 'index.js');
} else if (fs.existsSync(path.join(claudiaDir, 'src', 'index.js'))) {
    entryPoint = path.join(claudiaDir, 'src', 'index.js');
}

// Execute with the same arguments
const args = [entryPoint].concat(process.argv.slice(2));
const child = spawn('node', args, {
    stdio: 'inherit',
    cwd: claudiaDir
});

child.on('exit', (code) => {
    process.exit(code);
});
"
        } else if ("requirements.txt" | path exists) or ("setup.py" | path exists) {
            # Python project
            "#!/usr/bin/env python3
import sys
import os
import subprocess

claudia_dir = '" + $claudia_dir + "'
os.chdir(claudia_dir)

# Try to find the main Python script
main_script = None
possible_mains = ['main.py', 'claudia.py', 'app.py', '__main__.py']

for script in possible_mains:
    if os.path.exists(script):
        main_script = script
        break

if main_script:
    subprocess.run([sys.executable, main_script] + sys.argv[1:])
else:
    print('Could not find main Python script in Claudia directory')
    sys.exit(1)
"
        } else {
            # Generic bash wrapper
            "#!/usr/bin/env bash
cd '" + $claudia_dir + "'

# Try to find an executable or main script
if [ -f 'claudia' ]; then
    ./claudia \"$@\"
elif [ -f 'main.py' ]; then
    python3 main.py \"$@\"
elif [ -f 'index.js' ]; then
    node index.js \"$@\"
else
    echo \"Could not determine how to run Claudia\"
    echo \"Please check the repository documentation\"
    exit 1
fi
"
        }
        
        let script_path = ($bin_dir | path join "claudia")
        $wrapper_content | save $script_path
        chmod +x $script_path
        
        print $"✅ Claudia wrapper script created at ($script_path)"
        
    } catch { |err|
        print $"⚠️  Could not create wrapper script: ($err.msg)"
        print $"🔧 You can manually run claudia from ($claudia_dir)"
    }
}

def add_to_path [] {
    print "\n🛤️  Updating PATH..."
    
    let bin_dir = ($env.HOME | path join ".local" "bin")
    let env_file = ($env.HOME | path join ".config" "nushell" "env.nu")
    
    # Check if already in PATH
    let current_path = ($env.PATH | str join ":")
    
    if not ($current_path | str contains $bin_dir) {
        try {
            let path_addition = $"\n# AI CLI Tools\n$env.PATH = ($env.PATH | prepend '($bin_dir)')\n"
            $path_addition | save --append $env_file
            print $"✅ Added ($bin_dir) to PATH in env.nu"
        } catch { |err|
            print $"⚠️  Could not update PATH automatically: ($err.msg)"
            print $"🔧 Please manually add ($bin_dir) to your PATH"
        }
    } else {
        print $"✅ ($bin_dir) already in PATH"
    }
}

# Verification function
def verify_installations [] {
    print "\n🔍 Verifying installations..."
    
    # Check Claude Code
    if (which claude-code | is-not-empty) {
        print "✅ Claude Code CLI: Available"
    } else {
        print "❌ Claude Code CLI: Not found in PATH"
    }
    
    # Check Gemini
    if (which gemini | is-not-empty) {
        print "✅ Gemini CLI: Available"
    } else {
        print "❌ Gemini CLI: Not found in PATH"
    }
    
    # Check Claudia
    if (which claudia | is-not-empty) {
        print "✅ Claudia: Available"
        try {
            # Try to get version or help
            claudia --help | lines | first 3 | each { |line| print $"    ($line)" }
        } catch {
            print "    (Claudia executable found but may need configuration)"
        }
    } else {
        let claudia_dir = ($env.HOME | path join ".local" "share" "claudia")
        if ($claudia_dir | path exists) {
            print $"⚠️  Claudia: Installed at ($claudia_dir) but not in PATH"
        } else {
            print "❌ Claudia: Not found"
        }
    }
}

# Run verification at the end
def run_with_verification [] {
    main
    verify_installations
    add_to_path
}

# Export the main function
if ($env.SCRIPT_NAME? | default "" | str ends-with "install_ai_tools.nu") {
    run_with_verification
}
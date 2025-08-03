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
    install_memoryos_mcp
    
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
    
    # Check if uv is available
    if (which uv | is-empty) {
        print "❌ uv is required but not found. Please install uv first:"
        print "   curl -LsSf https://astral.sh/uv/install.sh | sh"
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

def install_memoryos_mcp [] {
    print "\n🧠 Installing MemoryOS MCP from source..."
    
    let memoryos_dir = ($env.HOME | path join ".local" "share" "memoryos")
    let config_dir = ($env.HOME | path join ".config" "memoryos")
    let bin_dir = ($env.HOME | path join ".local" "bin")
    
    try {
        # Create directories
        mkdir $memoryos_dir
        mkdir $config_dir
        mkdir $bin_dir
        print $"📁 Created directories"
        
        # Clone MemoryOS repository
        print "🔄 Cloning MemoryOS repository..."
        git clone https://github.com/BAI-LAB/MemoryOS.git $memoryos_dir
        print "✅ MemoryOS cloned successfully"
        
        # Navigate to memoryos directory
        cd $memoryos_dir
        
        # Set up UV environment for MemoryOS MCP only
        print "🔧 Setting up UV virtual environment for MCP..."
        uv venv --python 3.10
        
        # Install only MCP-specific dependencies
        print "📦 Installing MCP dependencies..."
        uv pip install "mcp>=1.0.0"
        uv pip install fastmcp
        
        # Check for MCP-specific files/directory
        let mcp_dir = ($memoryos_dir | path join "mcp")
        if not ($mcp_dir | path exists) {
            # Create MCP directory structure if not exists
            mkdir $mcp_dir
            
            # Look for MCP-related files in the repository
            let possible_mcp_files = ["mcp.py", "mcp_server.py", "memoryos_mcp.py", "server.py"]
            mut mcp_found = false
            
            for file in $possible_mcp_files {
                if ($file | path exists) {
                    cp $file $mcp_dir
                    $mcp_found = true
                    break
                }
            }
            
            if not $mcp_found {
                # Create a basic MCP server file
                create_mcp_server_file $mcp_dir $config_dir
            }
        }
        
        # Create wrapper script that properly activates venv
        let wrapper_script = "#!/usr/bin/env bash
MEMORYOS_DIR='" + $memoryos_dir + "'
cd \"$MEMORYOS_DIR\"

# Check if virtual environment exists
if [ ! -d \".venv\" ]; then
    echo \"Error: Virtual environment not found at $MEMORYOS_DIR/.venv\"
    echo \"Please run the installation script again.\"
    exit 1
fi

# Activate virtual environment
source .venv/bin/activate

# Check if MCP server file exists
if [ ! -f \"mcp/server.py\" ]; then
    echo \"Error: MCP server file not found at $MEMORYOS_DIR/mcp/server.py\"
    echo \"Please check the installation.\"
    exit 1
fi

# Run the MCP server
exec python mcp/server.py \"$@\"
"
        
        let script_path = ($bin_dir | path join "memoryos-mcp")
        $wrapper_script | save $script_path
        chmod +x $script_path
        
        # Create configuration file template
        create_memoryos_config $config_dir
        
        # Update Claude Desktop config if it exists
        update_claude_config_for_memoryos $memoryos_dir $config_dir
        
        print $"✅ MemoryOS MCP installed successfully"
        print $"📍 Installation directory: ($memoryos_dir)"
        print $"🐍 Virtual environment: ($memoryos_dir)/.venv"
        print $"⚙️  Configuration directory: ($config_dir)"
        print $"🔧 Edit ($config_dir)/config.json to configure your user IDs"
        print $"🧪 Test installation: memoryos-mcp --help"
        
    } catch { |err|
        print $"❌ Failed to install MemoryOS MCP: ($err.msg)"
        print "💡 You may need to check the repository structure or install manually"
    }
}

def create_memoryos_config [config_dir: string] {
    try {
        let config_template = '{
  "user_id": "your_user_id",
  "assistant_id": "assistant_id"
}'
        
        let config_path = ($config_dir | path join "config.json")
        $config_template | save $config_path
        
        # Create data directory
        mkdir ($config_dir | path join "data")
        
        print $"📄 Created configuration template at ($config_path)"
        
    } catch { |err|
        print $"⚠️  Could not create config template: ($err.msg)"
    }
}

def create_mcp_server_file [mcp_dir: string, config_dir: string] {
    try {
        print "🔧 Creating MCP server file..."
        
        let mcp_server_content = "#!/usr/bin/env python3
\"\"\"
MemoryOS MCP Server
Provides memory management capabilities through the Model Context Protocol
\"\"\"

import asyncio
import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, Optional

# Simple in-memory storage for this MCP server
class SimpleMemoryStore:
    def __init__(self):
        self.memories = []
        self.user_profile = {}
    
    def add_memory(self, user_input: str, agent_response: str):
        self.memories.append({
            \"user_input\": user_input,
            \"agent_response\": agent_response,
            \"timestamp\": str(asyncio.get_event_loop().time())
        })
    
    def search_memories(self, query: str):
        # Simple search - in production you'd want semantic search
        results = []
        query_lower = query.lower()
        for memory in self.memories:
            if (query_lower in memory[\"user_input\"].lower() or 
                query_lower in memory[\"agent_response\"].lower()):
                results.append(memory)
        return results
    
    def get_stats(self):
        return {
            \"total_memories\": len(self.memories),
            \"user_profile_keys\": list(self.user_profile.keys())
        }

try:
    from mcp.server.fastmcp import FastMCP
    import mcp.types as types
except ImportError:
    print(\"MCP library not found. Please install with: uv pip install mcp fastmcp\")
    sys.exit(1)

# Initialize FastMCP server
mcp = FastMCP(\"MemoryOS-Simple\")

# Global memory store instance
memory_store = SimpleMemoryStore()

def load_config() -> Dict[str, Any]:
    \"\"\"Load configuration from config file\"\"\"
    config_path = os.environ.get(\"MEMORYOS_CONFIG_PATH\", 
                                Path.home() / \".config\" / \"memoryos\" / \"config.json\")
    
    try:
        with open(config_path, \"r\") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f\"Config file not found at {config_path}, using defaults\")
        return {\"user_id\": \"default_user\", \"assistant_id\": \"assistant\"}
    except json.JSONDecodeError:
        print(f\"Invalid JSON in config file: {config_path}, using defaults\")
        return {\"user_id\": \"default_user\", \"assistant_id\": \"assistant\"}

@mcp.tool()
def add_memory(user_input: str, agent_response: str) -> str:
    \"\"\"Add a conversation pair to memory\"\"\"
    try:
        memory_store.add_memory(user_input, agent_response)
        return \"Memory added successfully\"
    except Exception as e:
        return f\"Error adding memory: {str(e)}\"

@mcp.tool()
def search_memory(query: str) -> str:
    \"\"\"Search memories for relevant conversations\"\"\"
    try:
        results = memory_store.search_memories(query)
        if not results:
            return \"No relevant memories found\"
        
        response = f\"Found {len(results)} relevant memories:\\n\\n\"
        for i, memory in enumerate(results[:5], 1):  # Limit to 5 results
            response += f\"{i}. User: {memory['user_input']}\\n\"
            response += f\"   Assistant: {memory['agent_response']}\\n\\n\"
        
        return response
    except Exception as e:
        return f\"Error searching memory: {str(e)}\"

@mcp.tool()
def get_memory_stats() -> str:
    \"\"\"Get memory statistics\"\"\"
    try:
        stats = memory_store.get_stats()
        config = load_config()
        stats.update({
            \"user_id\": config.get(\"user_id\", \"unknown\"),
            \"assistant_id\": config.get(\"assistant_id\", \"unknown\"),
            \"status\": \"active\"
        })
        return json.dumps(stats, indent=2)
    except Exception as e:
        return f\"Error getting memory stats: {str(e)}\"

@mcp.tool()
def clear_memory() -> str:
    \"\"\"Clear all stored memories\"\"\"
    try:
        memory_store.memories.clear()
        return \"All memories cleared successfully\"
    except Exception as e:
        return f\"Error clearing memory: {str(e)}\"

async def main():
    \"\"\"Main entry point\"\"\"
    try:
        config = load_config()
        print(f\"MemoryOS MCP Server initialized for user: {config.get('user_id', 'unknown')}\")
        await mcp.run(transport=\"stdio\")
    except Exception as e:
        print(f\"Error starting MemoryOS MCP Server: {e}\")
        sys.exit(1)

if __name__ == \"__main__\":
    asyncio.run(main())
"
        
        let server_path = ($mcp_dir | path join "server.py")
        $mcp_server_content | save $server_path
        chmod +x $server_path
        
        print $"✅ Created MCP server file at ($server_path)"
        
    } catch { |err|
        print $"⚠️  Could not create MCP server file: ($err.msg)"
    }
}

def update_claude_config_for_memoryos [memoryos_dir: string, config_dir: string] {
    try {
        mut claude_config_path = ($env.HOME | path join "Library" "Application Support" "Claude" "claude_desktop_config.json")
        
        # Check if Claude config exists (macOS path)
        if not ($claude_config_path | path exists) {
            # Try Linux/Windows path
            $claude_config_path = ($env.HOME | path join ".config" "claude" "claude_desktop_config.json")
        }
        
        if ($claude_config_path | path exists) {
            print "🔧 Found Claude Desktop config, preparing MCP configuration..."
            
            # Create a separate MCP config file that user can manually merge
            let mcp_config = '{
  "mcpServers": {
    "memoryos": {
      "command": "' + ($memoryos_dir | path join ".venv" "bin" "python") + '",
      "args": [
        "' + ($memoryos_dir | path join "mcp" "server.py") + '"
      ],
      "env": {
        "MEMORYOS_CONFIG_PATH": "' + ($config_dir | path join "config.json") + '"
      }
    }
  }
}'
            
            let mcp_config_path = ($config_dir | path join "claude_mcp_config.json")
            $mcp_config | save $mcp_config_path
            
            print $"📄 Created Claude MCP config template at ($mcp_config_path)"
            print "🔧 Please manually merge this into your Claude Desktop config file:"
            print $"   ($claude_config_path)"
            
        } else {
            print "ℹ️  Claude Desktop config not found. Please configure manually when Claude Desktop is installed."
        }
        
    } catch { |err|
        print $"⚠️  Could not update Claude config: ($err.msg)"
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
    
    # Check MemoryOS MCP
    if (which memoryos-mcp | is-not-empty) {
        print "✅ MemoryOS MCP: Available"
        let config_dir = ($env.HOME | path join ".config" "memoryos")
        let memoryos_dir = ($env.HOME | path join ".local" "share" "memoryos")
        
        if (($config_dir | path join "config.json") | path exists) {
            print "    📄 Configuration found"
        } else {
            print "    ⚠️  Configuration needed - edit config.json"
        }
        
        if (($memoryos_dir | path join ".venv") | path exists) {
            print "    🐍 Virtual environment found"
        } else {
            print "    ⚠️  Virtual environment missing"
        }
        
        if (($memoryos_dir | path join "mcp" "server.py") | path exists) {
            print "    🔧 MCP server found"
        } else {
            print "    ⚠️  MCP server missing"
        }
    } else {
        let memoryos_dir = ($env.HOME | path join ".local" "share" "memoryos")
        if ($memoryos_dir | path exists) {
            print $"⚠️  MemoryOS MCP: Installed at ($memoryos_dir) but not in PATH"
        } else {
            print "❌ MemoryOS MCP: Not found"
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
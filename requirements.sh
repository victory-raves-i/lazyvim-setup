#!/bin/bash

# LazyVim Prerequisites Installation Script
# This script installs all required and optional dependencies for LazyVim
# Based on official LazyVim documentation: https://www.lazyvim.org/

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    VER=$(sw_vers -productVersion)
    print_info "Detected OS: macOS $VER"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
    print_info "Detected OS: $OS $VER"
  else
    print_error "Cannot detect OS. This script supports macOS, Ubuntu, Debian, Fedora, and Arch Linux."
    exit 1
  fi
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install packages on macOS with Homebrew
install_macos() {
  print_info "Installing prerequisites for macOS..."

  # Check if Homebrew is installed
  if ! command_exists brew; then
    print_error "Homebrew is not installed!"
    print_info "Please install Homebrew first: https://brew.sh"
    print_info "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
  fi

  print_success "Homebrew found: $(brew --version | head -n1)"

  # Update Homebrew
  print_info "Updating Homebrew..."
  brew update

  # Install Neovim
  print_info "Installing Neovim..."
  if ! command_exists nvim; then
    brew install neovim
  else
    NVIM_VERSION=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    print_info "Neovim already installed: v$NVIM_VERSION"
    if (($(echo "$NVIM_VERSION < 0.11" | bc -l))); then
      print_warning "Upgrading Neovim to latest version..."
      brew upgrade neovim
    fi
  fi

  # Install Git (usually already installed on macOS)
  if ! command_exists git; then
    print_info "Installing Git..."
    brew install git
  else
    print_success "Git already installed: $(git --version)"
  fi

  # Install ripgrep
  print_info "Installing ripgrep..."
  brew install ripgrep

  # Install fd
  print_info "Installing fd..."
  brew install fd

  # Install fzf
  print_info "Installing fzf..."
  brew install fzf

  # Install tree-sitter
  print_info "Installing tree-sitter..."
  brew install tree-sitter

  print_info "Installing tree-sitter-cli..."
  brew install tree-sitter-cli

  # Install lazygit
  print_info "Installing lazygit..."
  brew install jesseduffield/lazygit/lazygit

  # Install curl (usually already on macOS)
  if ! command_exists curl; then
    print_info "Installing curl..."
    brew install curl
  else
    print_success "curl already installed"
  fi

  # Check for C compiler (Xcode Command Line Tools)
  if ! command_exists gcc && ! command_exists clang; then
    print_warning "C compiler not found. Installing Xcode Command Line Tools..."
    xcode-select --install
    print_info "Please complete the Xcode Command Line Tools installation and run this script again."
    exit 1
  else
    print_success "C compiler found: $(clang --version | head -n1 2>/dev/null || gcc --version | head -n1)"
  fi

  print_success "All packages installed successfully on macOS!"
}

# Function to install packages on Ubuntu/Debian
install_debian() {
  print_info "Installing prerequisites for Debian/Ubuntu..."

  # Update package list
  sudo apt update

  # Install build essentials and required tools
  print_info "Installing build essentials..."
  sudo apt install -y build-essential cmake gettext ninja-build unzip curl wget git

  # Install Neovim (latest version)
  print_info "Installing Neovim..."
  if ! command_exists nvim || [ "$(nvim --version | head -n1 | grep -oP '\d+\.\d+' | head -n1)" \< "0.11" ]; then
    print_warning "Installing/Updating Neovim to latest version..."
    # Add Neovim unstable PPA for latest version
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install -y neovim
  else
    print_success "Neovim is already installed with sufficient version"
  fi

  # Install ripgrep
  print_info "Installing ripgrep..."
  sudo apt install -y ripgrep

  # Install fd-find
  print_info "Installing fd-find..."
  sudo apt install -y fd-find
  # Create symlink for fd (Debian/Ubuntu names it fd-find)
  if ! command_exists fd; then
    sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
  fi

  # Install fzf
  print_info "Installing fzf..."
  sudo apt install -y fzf

  # Install tree-sitter-cli via npm
  print_info "Installing tree-sitter-cli..."
  if ! command_exists npm; then
    print_info "Installing Node.js and npm first..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
  fi
  sudo npm install -g tree-sitter-cli

  # Install lazygit
  print_info "Installing lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz
}

# Function to install packages on Fedora
install_fedora() {
  print_info "Installing prerequisites for Fedora..."

  # Install build essentials and required tools
  print_info "Installing build essentials..."
  sudo dnf install -y @development-tools cmake ninja-build curl wget git gcc-c++

  # Install Neovim
  print_info "Installing Neovim..."
  sudo dnf install -y neovim

  # Install ripgrep
  print_info "Installing ripgrep..."
  sudo dnf install -y ripgrep

  # Install fd-find
  print_info "Installing fd-find..."
  sudo dnf install -y fd-find

  # Install fzf
  print_info "Installing fzf..."
  sudo dnf install -y fzf

  # Install tree-sitter-cli
  print_info "Installing tree-sitter-cli..."
  sudo dnf install -y tree-sitter-cli || {
    print_warning "tree-sitter-cli not in repos, installing via npm..."
    if ! command_exists npm; then
      sudo dnf install -y nodejs npm
    fi
    sudo npm install -g tree-sitter-cli
  }

  # Install lazygit
  print_info "Installing lazygit..."
  sudo dnf copr enable -y atim/lazygit
  sudo dnf install -y lazygit
}

# Function to install packages on Arch Linux
install_arch() {
  print_info "Installing prerequisites for Arch Linux..."

  # Update package database
  sudo pacman -Sy

  # Install build essentials and required tools
  print_info "Installing build essentials..."
  sudo pacman -S --noconfirm --needed base-devel cmake ninja curl wget git

  # Install Neovim
  print_info "Installing Neovim..."
  sudo pacman -S --noconfirm --needed neovim

  # Install ripgrep
  print_info "Installing ripgrep..."
  sudo pacman -S --noconfirm --needed ripgrep

  # Install fd
  print_info "Installing fd..."
  sudo pacman -S --noconfirm --needed fd

  # Install fzf
  print_info "Installing fzf..."
  sudo pacman -S --noconfirm --needed fzf

  # Install tree-sitter-cli
  print_info "Installing tree-sitter-cli..."
  sudo pacman -S --noconfirm --needed tree-sitter-cli || {
    print_warning "tree-sitter-cli not found, installing via npm..."
    if ! command_exists npm; then
      sudo pacman -S --noconfirm --needed nodejs npm
    fi
    sudo npm install -g tree-sitter-cli
  }

  # Install lazygit
  print_info "Installing lazygit..."
  sudo pacman -S --noconfirm --needed lazygit
}

# Function to install Nerd Font
install_nerd_font() {
  print_info "Installing Nerd Font (Hack Nerd Font)..."

  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  cd "$FONT_DIR"

  # Download Hack Nerd Font
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"

  if [ -f "Hack.zip" ]; then
    rm Hack.zip
  fi

  curl -fLo Hack.zip "$FONT_URL"
  unzip -o Hack.zip -d Hack
  rm Hack.zip

  # Update font cache
  if command_exists fc-cache; then
    fc-cache -fv
  fi

  print_success "Hack Nerd Font installed successfully!"
  print_warning "Remember to configure your terminal to use 'Hack Nerd Font Mono'"
}

# Function to verify installations
verify_installations() {
  print_info "Verifying installations..."

  local all_good=true

  # Check Neovim
  if command_exists nvim; then
    NVIM_VERSION=$(nvim --version | head -n1)
    print_success "Neovim: $NVIM_VERSION"
  else
    print_error "Neovim: NOT FOUND"
    all_good=false
  fi

  # Check Git
  if command_exists git; then
    GIT_VERSION=$(git --version)
    print_success "Git: $GIT_VERSION"
  else
    print_error "Git: NOT FOUND"
    all_good=false
  fi

  # Check ripgrep
  if command_exists rg; then
    RG_VERSION=$(rg --version | head -n1)
    print_success "ripgrep: $RG_VERSION"
  else
    print_warning "ripgrep: NOT FOUND (optional but recommended)"
  fi

  # Check fd
  if command_exists fd; then
    FD_VERSION=$(fd --version)
    print_success "fd: $FD_VERSION"
  else
    print_warning "fd: NOT FOUND (optional but recommended)"
  fi

  # Check fzf
  if command_exists fzf; then
    FZF_VERSION=$(fzf --version)
    print_success "fzf: $FZF_VERSION"
  else
    print_warning "fzf: NOT FOUND (optional but recommended)"
  fi

  # Check tree-sitter
  if command_exists tree-sitter; then
    TS_VERSION=$(tree-sitter --version)
    print_success "tree-sitter: $TS_VERSION"
  else
    print_warning "tree-sitter: NOT FOUND (optional but recommended)"
  fi

  # Check lazygit
  if command_exists lazygit; then
    LG_VERSION=$(lazygit --version | head -n1)
    print_success "lazygit: $LG_VERSION"
  else
    print_warning "lazygit: NOT FOUND (optional)"
  fi

  # Check curl
  if command_exists curl; then
    CURL_VERSION=$(curl --version | head -n1)
    print_success "curl: $CURL_VERSION"
  else
    print_error "curl: NOT FOUND"
    all_good=false
  fi

  # Check C compiler
  if command_exists gcc || command_exists clang; then
    if command_exists clang; then
      CC_VERSION=$(clang --version | head -n1)
      print_success "Clang: $CC_VERSION"
    else
      CC_VERSION=$(gcc --version | head -n1)
      print_success "GCC: $CC_VERSION"
    fi
  else
    print_warning "C compiler (gcc/clang): NOT FOUND (needed for nvim-treesitter)"
  fi

  echo ""
  if [ "$all_good" = true ]; then
    print_success "All required prerequisites are installed!"
  else
    print_warning "Some required prerequisites are missing. Please check the output above."
  fi
}

# Main installation flow
main() {
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║        LazyVim Prerequisites Installation Script          ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""

  # Detect OS
  detect_os

  echo ""
  print_info "This script will install the following prerequisites:"
  echo "  - Neovim >= 0.11.2"
  echo "  - Git >= 2.19.0"
  echo "  - ripgrep (for live grep)"
  echo "  - fd (for file finding)"
  echo "  - fzf (for fuzzy finding)"
  echo "  - tree-sitter-cli (for syntax parsing)"
  echo "  - lazygit (optional Git TUI)"
  echo "  - curl (for blink.cmp)"
  echo "  - C compiler (for nvim-treesitter)"
  echo "  - Hack Nerd Font (optional)"
  echo ""

  read -p "Do you want to continue? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Installation cancelled."
    exit 0
  fi

  # Install based on detected OS
  case $OS in
  macos)
    install_macos
    ;;
  ubuntu | debian | linuxmint | pop)
    install_debian
    ;;
  fedora | rhel | centos)
    install_fedora
    ;;
  arch | manjaro | endeavouros)
    install_arch
    ;;
  *)
    print_error "Unsupported OS: $OS"
    print_info "Please install prerequisites manually using your package manager."
    exit 1
    ;;
  esac

  echo ""
  read -p "Do you want to install Hack Nerd Font? (y/N): " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_nerd_font
  fi

  echo ""
  verify_installations

  echo ""
  print_success "Installation complete!"
  echo ""
  print_info "Next steps:"
  echo "  1. Clone the LazyVim starter:"
  echo "     git clone https://github.com/LazyVim/starter ~/.config/nvim"
  echo "  2. Remove the .git folder:"
  echo "     rm -rf ~/.config/nvim/.git"
  echo "  3. Start Neovim:"
  echo "     nvim"
  echo "  4. Run :LazyHealth to check if everything is working"
  echo ""
  print_warning "If you installed a Nerd Font, remember to configure your terminal to use it!"
}

# Run main function
main
